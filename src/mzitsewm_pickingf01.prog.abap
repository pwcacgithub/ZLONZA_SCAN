*&---------------------------------------------------------------------*
*&  Include           MZITSEWM_PICKINGF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ADD_MESSAGE
*&---------------------------------------------------------------------*
*       Log and display message if there is one
*----------------------------------------------------------------------*
*  -->  uv_object_id      Object ID
*  -->  uv_content        Object content
*  -->  uv_with_message   With message or not
*----------------------------------------------------------------------*
FORM add_message  USING uv_object_id    TYPE zzscan_objid
                        uv_content      TYPE any
                        uv_with_message TYPE boolean
                        uv_display_msg  TYPE boolean.

  CALL METHOD o_log->log_message_add
    EXPORTING
      iv_object_id    = uv_object_id
      iv_content      = uv_content
      iv_with_message = uv_with_message.

  IF uv_display_msg = abap_true.
*   Display error message
    CALL METHOD zcl_its_utility=>message_display( ).
  ENDIF.

ENDFORM.                    " ADD_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  CHECK_OUTB_DELIVERY
*&---------------------------------------------------------------------*
*       Outbound delivery check
*----------------------------------------------------------------------*
FORM check_outb_delivery .

  DATA: lx_dlv_key         TYPE zsits_dlv_key.

  DATA: lv_display_msg TYPE boolean,
        lv_dummy       TYPE bapi_msg.
  DATA :lv_auth_msg TYPE c LENGTH 100,
        lc_e        TYPE c VALUE 'E',
        ls_lips     TYPE lips.

  CLEAR: x_delivery_to,
         x_to_data,
         it_scanned_batch_list,
         zsits_scan_dynp-zzsuccess_msg.

  IF zsits_scan_dynp-zzoutb_delivery IS INITIAL.
    RETURN.
  ENDIF.

* Outbound delivery validation
  IF zcl_its_utility=>outb_delivery_validate( is_scan_dynp = zsits_scan_dynp ) = abap_true.

*** Authority check on LGNUM and LGTYP
    CLEAR ls_lips.
    SELECT SINGLE * FROM lips
      INTO ls_lips
      WHERE vbeln = zsits_scan_dynp-zzoutb_delivery.
    IF sy-subrc = 0.
      AUTHORITY-CHECK OBJECT 'L_LGNUM'
        ID 'LGNUM' FIELD ls_lips-lgnum
        ID 'LGTYP' FIELD ls_lips-lgtyp.

      IF sy-subrc <> 0.
        CONCATENATE text-001 ls_lips-lgnum text-002 ls_lips-lgtyp INTO lv_auth_msg SEPARATED BY space.
        MESSAGE lv_auth_msg TYPE lc_e.
      ENDIF.
    ENDIF.

*   Get shipping lane
    CALL METHOD zcl_its_utility=>delivery_read
      EXPORTING
        iv_delivery        = zsits_scan_dynp-zzoutb_delivery
        iv_pick_get        = abap_true
      IMPORTING
        es_delivery_header = s_delivery_header
        et_picking_qty     = x_delivery_to
        et_delivery_item   = it_delivery_item. "MMUKHERJEE++ EICR 603155 TR #D10K9A44XO

*   Lock delivery
    IF zcl_its_utility=>delivery_lock( iv_delivery = zsits_scan_dynp-zzoutb_delivery ) = abap_true.
      lx_dlv_key-vbeln = zsits_scan_dynp-zzoutb_delivery.

*     Get Transfer Order details by outbound delivery
      CALL METHOD zcl_its_utility=>get_to_by_outb_dlv
        EXPORTING
          is_dlv_key = lx_dlv_key
        IMPORTING
          es_detail  = x_to_data.

      IF x_to_data-to_item IS NOT INITIAL.
*       Get batches which have been picked bu not confirmed
        CALL METHOD zcl_its_utility=>get_picked_to
          EXPORTING
            it_to_item   = x_to_data-to_item
          IMPORTING
            et_picked_to = it_scanned_batch_list.
      ELSE.
*       No open TO could be found for scanned O/B Delivery &1 !
        MESSAGE e133(zits) WITH zsits_scan_dynp-zzoutb_delivery INTO lv_dummy.
        lv_display_msg = abap_true.
      ENDIF.
    ELSE.
*     Lock error
      lv_display_msg = abap_true.
    ENDIF.
  ELSE.
*   Error Scenario 1: Delivery &1 does not exist in the database or in the archive
*   Error Scenario 2: Document &1 is not an outbound delivery !
*   Error Scenario 3: PGI of delivery &1 has been completed
    lv_display_msg = abap_true.
  ENDIF.

  PERFORM add_message USING zcl_its_utility=>gc_objid_delivery "Object ID = 'Delivery'
                            zsits_scan_dynp-zzoutb_delivery
                            lv_display_msg
                            lv_display_msg.

  IF lv_display_msg = abap_true.
    CLEAR zsits_scan_dynp-zzoutb_delivery.
  ELSE.
    CALL SCREEN 9003.
  ENDIF.

ENDFORM.                    " CHECK_OUTB_DELIVERY
*&---------------------------------------------------------------------*
*&      Form  CHECK_LABEL
*&---------------------------------------------------------------------*
*       Scanned label check
*----------------------------------------------------------------------*
FORM check_label .

  DATA: lit_label_type_range TYPE ztlabel_type_range,
        lwa_read_option      TYPE zsits_batch_read_option.

  DATA: lv_barcode_string TYPE string.

  DATA: lv_display_msg TYPE boolean,
        lv_dummy       TYPE string,
        lv_uname       TYPE xubname,
        lt_param       TYPE STANDARD TABLE OF bapiparam,
        lt_return_user TYPE STANDARD TABLE OF bapiret2.


  CLEAR: v_label_type,
         x_label_content,
         v_batch_gt_10,
         it_to_conf,
         zsits_scan_dynp-zzsuccess_msg.

  IF zsits_scan_dynp-zzbarcode IS INITIAL.
    RETURN.
  ENDIF.
.
**--Read the HU number enter one is with Prefix or not
**--If not prefix of HU number then add Prefix with below code
**--Create Class Object for validation

  lv_uname = sy-uname.
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username  = lv_uname
    TABLES
      parameter = lt_param
      return    = lt_return_user.

  READ TABLE lt_param ASSIGNING FIELD-SYMBOL(<lfs_param>)
  WITH KEY parid = 'ZGELATIN'.
  IF sy-subrc = 0 AND <lfs_param>-parva = abap_true.
    gv_flg_us = abap_true.
  ENDIF.

  IF gv_flg_us = abap_true.
    SELECT SINGLE prefix
         FROM t313g
         INTO gv_prefix
         WHERE aityp EQ 'GS1'.
    IF sy-subrc EQ 0 AND  zsits_scan_dynp-zzbarcode(3) <> gv_prefix.
      CONCATENATE gv_prefix '240' zsits_scan_dynp-zzbarcode INTO zsits_scan_dynp-zzbarcode.
    ENDIF.
  ENDIF.

* Generate label type range
  PERFORM generate_label_type_range USING    zcl_its_utility=>gc_label_rm_batch"RAW Carton Label
                                    CHANGING lit_label_type_range.
  PERFORM generate_label_type_range USING    zcl_its_utility=>gc_label_fg_batch"FG Carton Label
                                    CHANGING lit_label_type_range.
  PERFORM generate_label_type_range USING    zcl_its_utility=>gc_label_rm_nob  "Non-batch Managed Label
                                    CHANGING lit_label_type_range.
  PERFORM generate_label_type_range USING    zcl_its_utility=>gc_label_su      "SU Label
                                    CHANGING lit_label_type_range.
  PERFORM generate_label_type_range USING    zcl_its_utility=>gc_label_hu      "HU Label
                                    CHANGING lit_label_type_range.

* Barcode read
  lwa_read_option-zzstock_read   = abap_true."batch stock read
  lwa_read_option-zzinsp_lot     = abap_true."inspection lot read
  lwa_read_option-zzcharact_read = abap_true."batch char read

  lv_barcode = zsits_scan_dynp-zzbarcode(100).

  CALL METHOD zcl_its_utility=>barcode_read_dfs
    EXPORTING
      iv_barcode           = lv_barcode
      is_read_option       = lwa_read_option
      iv_exist_check       = iv_exist_check
      it_label_type_range  = lit_label_type_range
      iv_read_10_only      = iv_read_10_only
      iv_skip_or_bch_check = iv_skip_or_bch_check
      iv_appid_type        = lc_capus_type   "AT Added
    IMPORTING
      ev_label_type        = v_label_type
      es_label_content     = x_label_content.

  IF v_label_type IS NOT INITIAL.
    CASE v_label_type.
      WHEN zcl_its_utility=>gc_label_hu.      "Pallet Label
        PERFORM validate_pallet_label CHANGING lv_display_msg.
      WHEN zcl_its_utility=>gc_label_su.      "SU Label
        "***Important Note***"
        " for the two cases, validate_su subroutine is called when HU in TO line-item matches with the scan HU
        "i.e, when whole Pallet is scanned or single free carton is scanned. Here direct LT11 is called.
        " i.e. for pick-HU case, this is only for the partial picking of cartons, when LH01 is required in addition to LT11.
        PERFORM validate_su_label     CHANGING lv_display_msg.
      WHEN zcl_its_utility=>gc_label_fg_batch."FG Carton Label
        PERFORM validate_fg_batch     CHANGING lv_display_msg.
      WHEN zcl_its_utility=>gc_label_rm_batch."RAW Carton Label
        PERFORM validate_rm_batch     CHANGING lv_display_msg.
      WHEN zcl_its_utility=>gc_label_rm_nob.  "Non-batch Managed Label
        PERFORM validate_rm_nob       CHANGING lv_display_msg.
    ENDCASE.
  ELSE.
    IF sy-msgid = 'ZITS' AND sy-msgno = '107'."RM batch &1 does not exist!
      CLEAR: v_label_type, x_label_content.

      CALL METHOD zcl_its_utility=>barcode_read
        EXPORTING
          iv_barcode          = zsits_scan_dynp-zzbarcode
          is_read_option      = lwa_read_option
          iv_exist_check      = abap_false
          it_label_type_range = lit_label_type_range
        IMPORTING
          ev_label_type       = v_label_type
          es_label_content    = x_label_content.

      IF v_label_type = zcl_its_utility=>gc_label_rm_batch."RAW Carton Label
*       Check if batch type is container batch
        IF zcl_batch_utility=>is_zero_batch( x_label_content-batch_data ) EQ abap_true.
*         RM batch &1 does not exist!
          MESSAGE e107(zits) WITH x_label_content-zzbatch INTO lv_dummy.
          lv_display_msg = abap_true.
        ELSE.
*         Container batch that was not established
          PERFORM validate_rm_batch_virtual CHANGING lv_display_msg.
        ENDIF.
      ELSE.
*       Read container batch that was not established error
        lv_display_msg = abap_true.
      ENDIF.
    ELSEIF sy-msgid = 'ZITS' AND sy-msgno = '368'."Batch &1 has length larger than 10!
*     Check whether FG label or not
      lv_barcode_string = zsits_scan_dynp-zzbarcode.

      CALL METHOD zcl_its_utility=>bar_code_translation
        EXPORTING
          i_bar_code_string = lv_barcode_string
        IMPORTING
          o_label_type      = v_label_type
        EXCEPTIONS
          illegal_bar_code  = 1
          conversion_error  = 2
          system_error      = 3
          numeric_error     = 4.

      IF v_label_type = zcl_its_utility=>gc_label_fg_batch."FG Carton Label
        CLEAR: v_label_type, x_label_content.

        CALL METHOD zcl_its_utility=>barcode_read
          EXPORTING
            iv_barcode          = zsits_scan_dynp-zzbarcode
            is_read_option      = lwa_read_option
            iv_exist_check      = abap_true
            it_label_type_range = lit_label_type_range
            iv_read_10_only     = abap_true
          IMPORTING
            ev_label_type       = v_label_type
            es_label_content    = x_label_content.

        IF v_label_type = zcl_its_utility=>gc_label_fg_batch."FG Carton Label
          v_batch_gt_10 = abap_true.
          PERFORM validate_fg_batch CHANGING lv_display_msg.
        ELSE.
*         Read special FG batch error
          lv_display_msg = abap_true.
        ENDIF.
      ELSE.
*       Batch &1 has length larger than 10!
        MESSAGE e368(zits) WITH x_label_content-zzbatch INTO lv_dummy.
        lv_display_msg = abap_true.
      ENDIF.

    ELSEIF sy-msgid = 'ZITS' AND sy-msgno = '158'."Storage Unit could not be found or picked!
      "***Important Note***"
      " i.e. this is only for the partial picking of cartons case, when LH01 is required in addition to LT11
      " for the other two cases, validate_su subroutuine is called, when direct LT11 is called.
      lv_barcode_string = zsits_scan_dynp-zzbarcode.
      CALL METHOD zcl_its_utility=>bar_code_translation_dfs
        EXPORTING
          i_bar_code_string = lv_barcode_string
          i_appid_type      = 'GS1'
          i_su_label        = abap_true
*         iv_appid_type     =
        IMPORTING
          o_return          = v_return
          o_label_type      = v_label_type
          o_label_content   = x_label_content
        EXCEPTIONS
          illegal_bar_code  = 1
          conversion_error  = 2
          system_error      = 3
          numeric_error     = 4
          OTHERS            = 5.
      IF sy-subrc <> 0.
*       Implement suitable error handling here
        lv_display_msg = abap_true.
      ELSE.
*       Check whether carton HU or not
        PERFORM check_pallet_carton USING x_label_content-zzlenum
                                    CHANGING gv_plt_flg.
      ENDIF.
    ELSE.
      IF gv_flg_us = abap_true.
        PERFORM get_hu_new USING zsits_scan_dynp-zzbarcode
                           CHANGING lv_display_msg.
      ENDIF.

*     Barcode read error
    ENDIF.
  ENDIF.

  PERFORM add_message USING zcl_its_utility=>gc_objid_label "Object ID = 'Label'
                            zsits_scan_dynp-zzbarcode
                            lv_display_msg
                            lv_display_msg.

  IF lv_display_msg = abap_true.
    CLEAR: zsits_scan_dynp-zzbarcode, x_label_content-zzlenum.
  ENDIF.

ENDFORM.                    " CHECK_LABEL
*&---------------------------------------------------------------------*
*&      Form  GENERATE_LABEL_TYPE_RANGE
*&---------------------------------------------------------------------*
*       Generate label type range
*----------------------------------------------------------------------*
*      -->iv_label_type        label type
*      <--ct_label_type_range  label type range
*----------------------------------------------------------------------*
FORM generate_label_type_range  USING    iv_label_type       TYPE zdits_label_type
                                CHANGING ct_label_type_range TYPE ztlabel_type_range.

  DATA: lwa_label_type_range TYPE zslabel_type_range.

  CONSTANTS: lc_sign_i       TYPE c VALUE 'I',
             lc_option_eq(2) TYPE c VALUE 'EQ'.

  CLEAR lwa_label_type_range.
  lwa_label_type_range-sign   = lc_sign_i.
  lwa_label_type_range-zoption = lc_option_eq.
  lwa_label_type_range-low    = iv_label_type.
  APPEND lwa_label_type_range TO ct_label_type_range.

ENDFORM.                    " GENERATE_LABEL_TYPE_RANGE
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_SU_LABEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM validate_su_label  CHANGING cv_display_msg TYPE xfeld.

  TYPES: BEGIN OF ts_ltap,
           lgnum TYPE lgnum,
           tanum TYPE tanum,
           tapos TYPE tapos,
           vlenr TYPE ltap_vlenr,
           vsolm TYPE ltap_vsolm,
         END OF ts_ltap.

  DATA: lv_lenum   TYPE exidv,
        lv_allowed TYPE boolean.

  DATA: ls_batch_key     TYPE zsits_batch_key,
        lwa_carton_data  TYPE zsits_batch_data,
        lit_batch_data   TYPE TABLE OF zsits_batch_data,
        lit_to_item      TYPE zttits_to_item,
        lwa_to_conf      TYPE zsits_to_conf,
        lwa_to_conf_item TYPE zsits_to_conf_item.

  DATA: lv_dummy          TYPE bapi_msg,
        ls_to_conf_item   TYPE zsits_to_conf,
        lv_vsolm          TYPE ltap_vsolm,
        lv_tot_qty        TYPE ltap_vsolm,
        lv_vlenr          TYPE ltap_vlenr,
        lt_hus            TYPE hum_exidv_t,
        ls_hus            TYPE hum_exidv,
        lt_header         TYPE hum_hu_header_t,
        lt_header_temp    TYPE hum_hu_header_t,
        lt_items          TYPE hum_hu_item_t,
        lw_header         TYPE vekpvb,
        lt_highest_levels TYPE hum_venum_t,
        lt_to_item        TYPE zttits_to_conf_item,
        lt_messages       TYPE huitem_messages_t,
        lt_ltap           TYPE TABLE OF ts_ltap,
        ls_ltap           TYPE ts_ltap,
        lv_parent         TYPE venum,
        lv_qty_flag       TYPE flag,
        lv_display_msg    TYPE flag.

  FIELD-SYMBOLS: <fs_to_line> LIKE LINE OF lit_to_item,
                 <fs_su_line> LIKE LINE OF x_label_content-su_content-su_item.

  lv_lenum = x_label_content-su_content-su_header-lenum.

  MOVE x_to_data-to_item[] TO lit_to_item[].
  SORT lit_to_item BY lenum.

  " To remove the pallet row which is already present
  " After delete the table should contain only underlying cartons
  DELETE lit_to_item WHERE lenum NE lv_lenum OR pquit = abap_true.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = lv_lenum
    IMPORTING
      output = lv_lenum.

  " If lit_to_item is initial, then no underlying cartons present
  " It is then a single HU
  IF lit_to_item IS INITIAL.
*   No items could be found on Pallet &1 for scanned O/B Delivery &2 !
    MESSAGE e137(zits) WITH lv_lenum
                            zsits_scan_dynp-zzoutb_delivery
                       INTO lv_dummy.

    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

  SORT lit_to_item BY matnr charg ASCENDING.

  LOOP AT x_label_content-su_content-su_item ASSIGNING <fs_su_line>.
    READ TABLE lit_to_item ASSIGNING <fs_to_line> WITH KEY   matnr = <fs_su_line>-matnr
                                                             charg = <fs_su_line>-charg BINARY SEARCH.
    IF sy-subrc = 0.

      CLEAR lwa_to_conf.
      lwa_to_conf-lgnum = <fs_to_line>-lgnum.
      lwa_to_conf-tanum = <fs_to_line>-vbeln.

      CLEAR lwa_to_conf_item.
      lwa_to_conf_item-tanum = <fs_to_line>-vbeln.
      lwa_to_conf_item-tapos = <fs_to_line>-posnn.
      ls_batch_key-charg = <fs_su_line>-charg.
      ls_batch_key-matnr = <fs_su_line>-matnr.
      ls_batch_key-werks = <fs_su_line>-werks.
      IF zcl_batch_utility=>batch_lock( is_batch_key  =  ls_batch_key
                                        iv_lock_mode  =  zcl_its_utility=>gc_write_lock
                                        iv_lock_plant =  abap_true ) = abap_true.
*       Lock succeeds
        lwa_to_conf_item-squit = abap_true.
      ELSE.
*       Lock fails
        cv_display_msg = abap_true.
        EXIT.
      ENDIF.

      APPEND lwa_to_conf_item TO lwa_to_conf-to_conf_item.
      APPEND lwa_to_conf TO it_to_conf.
    ELSE.
*     Pallet &1 not allowed to pick
      MESSAGE e138(zits) WITH lv_lenum INTO lv_dummy.
      cv_display_msg = abap_true.
      EXIT.
    ENDIF.
  ENDLOOP.

  lt_to_item = lwa_to_conf-to_conf_item[] .
  SORT lt_to_item BY tanum tapos.
  DELETE ADJACENT DUPLICATES FROM lt_to_item COMPARING tanum tapos.

  " Should contain one TO Line item
  IF lt_to_item IS NOT INITIAL.
    "Set GT_ZLSCAN_EWMPICK_DATA for population
    SELECT lgnum
           tanum
           tapos
           vlenr
           vsolm
           FROM ltap
           INTO ls_ltap
           UP TO 1 ROWS
           FOR ALL ENTRIES IN lt_to_item
           WHERE lgnum = lwa_to_conf-lgnum AND
                 tanum = lt_to_item-tanum AND
                 tapos = lt_to_item-tapos AND
                 pquit = '' .
    ENDSELECT.
    IF sy-subrc = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ls_ltap-vlenr
        IMPORTING
          output = ls_ltap-vlenr.
      IF ls_ltap-vlenr = lv_lenum.  " HU in TO line-item = HU in scan (eligible HU)
        "Check whether gt_zlscan_ewmpick_data is already populated,
        "only populate if not done already
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_lenum
          IMPORTING
            output = lv_lenum.
        CLEAR ls_zlscan_ewmpick_data.
        READ TABLE gt_zlscan_ewmpick_data INTO ls_zlscan_ewmpick_data WITH KEY vlenr = lv_lenum. "check for pallet
        IF sy-subrc NE 0.
          READ TABLE gt_zlscan_ewmpick_data INTO ls_zlscan_ewmpick_data WITH KEY lower_hu  = lv_lenum "check for carton
                                                                                 scan_flag = abap_true.
          IF sy-subrc NE 0.
            "End of change for defect 80, 04.03.2020
            "Populate lower level HUs if any
            ls_hus-exidv = lv_lenum.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_hus-exidv
              IMPORTING
                output = ls_hus-exidv.

            APPEND ls_hus TO lt_hus.

            IF lt_hus IS NOT INITIAL.
              CALL FUNCTION 'HU_GET_HUS'
                EXPORTING
                  if_no_loop        = 'X'
                  if_more_hus       = 'X'
                  it_hus            = lt_hus
                IMPORTING
                  et_header         = lt_header
                  et_items          = lt_items
                  et_highest_levels = lt_highest_levels
                  et_messages       = lt_messages
                EXCEPTIONS
                  hus_locked        = 1
                  no_hu_found       = 2
                  fatal_error       = 3
                  OTHERS            = 4.
              IF sy-subrc <> 0.

              ELSE.
                IF lt_header IS NOT INITIAL.
                  "Find VENUM for parent HU
                  lv_parent = lt_highest_levels[ 1 ]-venum.
                  "Delete duplicate HU now
                  IF lv_parent IS NOT INITIAL.
                    SORT lt_header BY venum. " Pallet HU with Carton HUs
                    DELETE lt_header WHERE venum = lv_parent.
                    SORT lt_items BY venum ASCENDING.

                    IF lt_header IS NOT INITIAL. "Whole pallet
                      CLEAR: lv_tot_qty.

                      "It have all the Carton HUs
                      LOOP AT lt_header INTO lw_header.
                        ls_zlscan_ewmpick_data-lgnum = ls_ltap-lgnum. " Warehouse
                        ls_zlscan_ewmpick_data-tanum = ls_ltap-tanum. " TO
                        ls_zlscan_ewmpick_data-tapos = ls_ltap-tapos. " TO ITEM
                        ls_zlscan_ewmpick_data-vsolm = ls_ltap-vsolm. " TO Item qty

                        ls_zlscan_ewmpick_data-vlenr = lv_lenum.      " Pallet HU
                        "Zero pad parent HU to avoid errors in comparison later
                        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                          EXPORTING
                            input  = ls_zlscan_ewmpick_data-vlenr
                          IMPORTING
                            output = ls_zlscan_ewmpick_data-vlenr.

                        ls_zlscan_ewmpick_data-lower_hu = lw_header-exidv. " Carton HU
                        READ TABLE lt_items INTO DATA(ls_items) WITH KEY venum = lw_header-venum BINARY SEARCH.
                        IF sy-subrc = 0.
                          ls_zlscan_ewmpick_data-scan_hu_qty = ls_items-vemng.
                        ENDIF.
                        ls_zlscan_ewmpick_data-scan_flag = abap_true.
                        PERFORM check_to_n_hu_qty USING  ls_zlscan_ewmpick_data-tanum " TO no.
                                                         ls_zlscan_ewmpick_data-tapos " TO item no.
                                                         ls_zlscan_ewmpick_data-vsolm  " TO Item qty
                                                         ls_zlscan_ewmpick_data-scan_hu_qty " HU qty
                                                  CHANGING lv_qty_flag.
*                                                           lv_tot_qty.  "Cumulative HU qty
                        IF lv_qty_flag = abap_true.
                          APPEND ls_zlscan_ewmpick_data TO gt_zlscan_ewmpick_data.
                        ELSE. "populate error
                          CLEAR: lv_tot_qty , gt_zlscan_ewmpick_data.
                          " Error Message Pallet qty more then TO Item qty
                          MESSAGE e521(zits) WITH lv_lenum INTO lv_dummy.
                          lv_display_msg = abap_true.
                          EXIT.
                        ENDIF.

                        CLEAR: ls_zlscan_ewmpick_data, lv_qty_flag.
                      ENDLOOP.
                      IF lv_display_msg = abap_false.
                        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                          EXPORTING
                            input  = lv_lenum
                          IMPORTING
                            output = lv_lenum.
                        READ TABLE gt_zlscan_ewmpick_data INTO ls_zlscan_ewmpick_data WITH KEY vlenr = lv_lenum.
                        IF sy-subrc = 0.
                          CLEAR wa_su.
                          wa_su = ls_zlscan_ewmpick_data-vlenr. " Append Pallet first
                          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                            EXPORTING
                              input  = wa_su
                            IMPORTING
                              output = wa_su.
                          READ TABLE it_su WITH KEY table_line = wa_su TRANSPORTING NO FIELDS.
                          IF sy-subrc = 0.
                            MESSAGE e530(zits) WITH lv_lenum INTO lv_dummy.
                            lv_display_msg = abap_true.
                          ELSE.
                            APPEND wa_su TO it_su.
                          ENDIF.
                        ENDIF.
                        CLEAR: lv_tot_qty, ls_zlscan_ewmpick_data, wa_su.
                      ENDIF.

                    ELSE.
                      PERFORM check_pallet_carton USING x_label_content-zzlenum
                                        CHANGING gv_plt_flg.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ELSE. "Carton HU already exits in box
            READ TABLE it_su WITH KEY table_line = lv_lenum TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
              MESSAGE e530(zits) WITH lv_lenum INTO lv_dummy.
              lv_display_msg = abap_true.
            ENDIF.
          ENDIF.
        ELSE. "Palet HU already exits in box
          READ TABLE it_su WITH KEY table_line = lv_lenum TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            MESSAGE e530(zits) WITH lv_lenum INTO lv_dummy.
            lv_display_msg = abap_true.
          ENDIF.
        ENDIF.
      ELSE.
        " Error Message "Scanned Pallet &1 not present in TO Item &2
        MESSAGE e522(zits) WITH lv_lenum lt_to_item[ 1 ]-tanum lt_to_item[ 1 ]-tapos INTO lv_dummy.
        lv_display_msg = abap_true.
      ENDIF.
    ENDIF.
  ELSE.
    " Error Message "Scanned Pallet &1 not present in TO Item &2
    MESSAGE e522(zits) WITH lv_lenum lt_to_item[ 1 ]-tanum lt_to_item[ 1 ]-tapos INTO lv_dummy.
    lv_display_msg = abap_true.
  ENDIF.
  IF lv_display_msg =  abap_true.
    PERFORM add_message USING zcl_its_utility=>gc_objid_palt_cart "Object ID = 'Pallet/ Carton'
                            lv_lenum
                            lv_display_msg
                            lv_display_msg.

  ENDIF.
  CLEAR zsits_scan_dynp-zzbarcode.

ENDFORM.                    " VALIDATE_SU_LABEL
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_FG_BATCH
*&---------------------------------------------------------------------*
*       Validate batch and quantity with o/b delivery
*----------------------------------------------------------------------*
FORM validate_fg_batch CHANGING cv_display_msg TYPE boolean.

  DATA: lit_to_item TYPE zttits_to_item,
        lwa_to_item TYPE zsits_to_item,
        lv_allowed  TYPE boolean.

  DATA: lwa_to_conf_item TYPE zsits_to_conf_item,
        lwa_to_conf      TYPE zsits_to_conf,
        ls_batch_key     TYPE zsits_batch_key.

  DATA: lx_batch_char TYPE bapi1003_alloc_values_char,
        lv_lenum      TYPE exidv.

  DATA: lv_dummy TYPE bapi_msg.

  MOVE x_to_data-to_item[] TO lit_to_item[].

  IF   x_label_content-batch_data-batch_stock IS NOT INITIAL"Carton batch was not rolled up
    OR v_batch_gt_10 = abap_true."Special FG
    SORT lit_to_item BY charg.
    DELETE lit_to_item WHERE charg NE x_label_content-zzbatch
                          OR pquit EQ abap_true.
  ELSE.
*   carton batch was rolled up
    READ TABLE x_label_content-batch_data-batch_charact-valueschar
      INTO lx_batch_char
      WITH KEY charact = zcl_common_utility=>gc_chara_palletid.

*   if PALLET ID char is initial, FG batch is on neither HU nor SU, no need to do the following logic
    IF sy-subrc NE 0 OR lx_batch_char-value_char IS INITIAL.
*       Batch &1 has no available stock!
      MESSAGE e346(zits) WITH x_label_content-zzbatch INTO lv_dummy.
      cv_display_msg = abap_true.
      RETURN.
    ENDIF.

*   add leading zero for su number
    CALL FUNCTION 'CONVERSION_EXIT_LENUM_INPUT'
      EXPORTING
        input  = lx_batch_char-value_char
      IMPORTING
        output = lv_lenum.

    SORT lit_to_item BY lenum.
    DELETE lit_to_item WHERE lenum NE lv_lenum
                          OR charg NE x_label_content-batch_data-licha
                          OR pquit = abap_true.
  ENDIF.

  IF lit_to_item IS INITIAL.
*   &1 does not exist or already picked.
    MESSAGE e399(zits) WITH x_label_content-zzbatch INTO lv_dummy.
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

  SORT lit_to_item BY vsolm DESCENDING.
  READ TABLE lit_to_item INTO lwa_to_item INDEX 1.

* Check IM/batch/QI lot status
  CALL METHOD zcl_its_utility=>is_res_batch_allowed_for_ship
    EXPORTING
      iv_werks      = lwa_to_item-werks
      is_delivery   = s_delivery_header
      is_batch_data = x_label_content-batch_data
    RECEIVING
      rv_allowed    = lv_allowed.

  IF lv_allowed = abap_false.
*   Batch &1 has IM/batch/QI lot status that's not allowed for picking
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

* Check if over pick
  IF lwa_to_item-vsolm < x_label_content-zzquantity.
*   FG batch &1 over picked !
    MESSAGE e147(zits) WITH x_label_content-zzbatch INTO lv_dummy.
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

  IF    x_label_content-batch_data-batch_stock IS NOT INITIAL
    AND v_batch_gt_10 = abap_false."Container batch will only in one TO line item
*   Confirm the label quantity

    ls_batch_key-charg = lwa_to_item-charg.
    ls_batch_key-matnr = lwa_to_item-matnr.
    ls_batch_key-werks = lwa_to_item-werks.

    IF zcl_batch_utility=>batch_lock( is_batch_key  = ls_batch_key
                                      iv_lock_mode  = zcl_its_utility=>gc_write_lock
                                      iv_lock_plant = abap_true ) = abap_false.
*   Lock fails
      cv_display_msg = abap_true.
      RETURN.
    ENDIF.

    lwa_to_conf-lgnum = lwa_to_item-lgnum.
    lwa_to_conf-tanum = lwa_to_item-vbeln.

    lwa_to_conf_item-tanum = lwa_to_item-vbeln.
    lwa_to_conf_item-tapos = lwa_to_item-posnn.

    IF lwa_to_item-vsolm = x_label_content-zzquantity.
*     Full pick
      lwa_to_conf_item-squit = abap_true.
    ELSE.
*     Partial pick
      lwa_to_conf_item-nista = x_label_content-zzquantity.
      lwa_to_conf_item-ndifa = lwa_to_item-vsolm - x_label_content-zzquantity.
      lwa_to_conf_item-altme = lwa_to_item-meins.
    ENDIF.

    APPEND lwa_to_conf_item TO lwa_to_conf-to_conf_item.
    APPEND lwa_to_conf TO it_to_conf.

  ELSE.
*   carton batch was rolled up OR Special FG
    PERFORM validate_scanned_fg_batch_list USING    lit_to_item
                                           CHANGING cv_display_msg.
  ENDIF.

ENDFORM.                    " VALIDATE_FG_BATCH
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_SCANNED_FG_BATCH_LIST
*&---------------------------------------------------------------------*
*       Validate scanned carton batch list
*----------------------------------------------------------------------*
FORM validate_scanned_fg_batch_list  USING    ut_to_item     TYPE zttits_to_item
                                     CHANGING cv_display_msg TYPE boolean.

  DATA: lwa_to_item      TYPE zsits_to_item,
        lwa_to_conf_item TYPE zsits_to_conf_item,
        lwa_to_conf      TYPE zsits_to_conf.

  DATA: lv_picked_quantity  TYPE zsits_to_item-vsolm,
        lv_picking_quantity TYPE zsits_to_item-vsolm.

  DATA: lv_confirmed_lines TYPE i,
        lv_total_to_lines  TYPE i.

  DATA: lv_zzbatch      TYPE ztits_pick-charg,
        lv_parent_batch TYPE ztits_pick-licha,
        ls_batch_key    TYPE zsits_batch_key.

  DATA: lv_dummy TYPE string.

  FIELD-SYMBOLS: <fs_fg_batch_list> TYPE ztits_pick.

  READ TABLE ut_to_item INTO lwa_to_item INDEX 1.
  IF sy-subrc NE 0.
    RETURN.
  ENDIF.

  IF v_batch_gt_10 = abap_true."Special FG
    CONCATENATE x_label_content-zzbatch
                x_label_content-zzsublot
           INTO lv_zzbatch.
    lv_parent_batch = x_label_content-zzbatch.
  ELSE."Parent batch
    lv_zzbatch      = x_label_content-zzbatch.
    lv_parent_batch = x_label_content-batch_data-licha.
  ENDIF.

* Check whether the FG batch was scanned or not.
*----------------------------------------------------------------------
  READ TABLE it_scanned_batch_list ASSIGNING <fs_fg_batch_list>
                                    WITH KEY lgnum = lwa_to_item-lgnum
                                             tanum = lwa_to_item-tanum
                                             tapos = lwa_to_item-tapos
                                             matnr = x_label_content-batch_data-matnr
                                             charg = lv_zzbatch
                                             licha = lv_parent_batch.
  IF sy-subrc = 0.
*   &1 does not exist or already picked.
    MESSAGE e399(zits) WITH lv_zzbatch INTO lv_dummy.
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

* Check if over picked
*----------------------------------------------------------------------
  LOOP AT it_scanned_batch_list ASSIGNING <fs_fg_batch_list> WHERE lgnum = lwa_to_item-lgnum
                                                               AND tanum = lwa_to_item-tanum
                                                               AND tapos = lwa_to_item-tapos.
    lv_picked_quantity = lv_picked_quantity + <fs_fg_batch_list>-zzquantity.
  ENDLOOP.

  lv_picking_quantity = lv_picked_quantity + x_label_content-zzquantity.

  IF lv_picking_quantity > lwa_to_item-vsolm.
*   FG batch &1 over picked !
    MESSAGE e147(zits) WITH lv_zzbatch INTO lv_dummy.
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

  ls_batch_key-charg = lwa_to_item-charg.
  ls_batch_key-matnr = lwa_to_item-matnr.

  IF zcl_batch_utility=>batch_lock( is_batch_key  =  ls_batch_key ) = abap_false.
* Batch lock fails
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

* Insert new line to internal table 'IT_SCANNED_BATCH_LIST' and DB table 'ZTITS_PICK'
*----------------------------------------------------------------------
  CALL FUNCTION 'ENQUEUE_EZTITS_PICK'
    EXPORTING
      mode_ztits_pick = 'E'
      mandt           = sy-mandt
      lgnum           = lwa_to_item-lgnum
      tanum           = lwa_to_item-tanum
      tapos           = lwa_to_item-tapos
    EXCEPTIONS
      foreign_lock    = 1
      system_failure  = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
*   Lock table ZTITS_PICK failed
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

  APPEND INITIAL LINE TO it_scanned_batch_list ASSIGNING <fs_fg_batch_list>.
  <fs_fg_batch_list>-lgnum      = lwa_to_item-lgnum.
  <fs_fg_batch_list>-tanum      = lwa_to_item-tanum.
  <fs_fg_batch_list>-tapos      = lwa_to_item-tapos.
  <fs_fg_batch_list>-matnr      = x_label_content-batch_data-matnr.
  <fs_fg_batch_list>-charg      = lv_zzbatch.
  <fs_fg_batch_list>-licha      = lv_parent_batch.
  <fs_fg_batch_list>-zzquantity = x_label_content-zzquantity.
  <fs_fg_batch_list>-meins      = x_label_content-batch_data-meins.

  MODIFY ztits_pick FROM <fs_fg_batch_list>.

* If picked quantity is equal to quantity of TO line item, confirm that TO line item.
*----------------------------------------------------------------------
  IF lv_picking_quantity = lwa_to_item-vsolm.
*   Confirm
    CLEAR lwa_to_conf.
    lwa_to_conf-lgnum = lwa_to_item-lgnum.
    lwa_to_conf-tanum = lwa_to_item-vbeln.

    CLEAR lwa_to_conf_item.
    lwa_to_conf_item-tanum = lwa_to_item-vbeln.
    lwa_to_conf_item-tapos = lwa_to_item-posnn.
    lwa_to_conf_item-squit = abap_true.
    APPEND lwa_to_conf_item TO lwa_to_conf-to_conf_item.
    APPEND lwa_to_conf TO it_to_conf.
  ELSEIF lv_picking_quantity < lwa_to_item-vsolm.
*   Unlock batch
    CALL METHOD zcl_batch_utility=>batch_unlock
      EXPORTING
        is_batch_key = ls_batch_key.

    PERFORM frm_get_to_lines USING     zsits_scan_dynp-zzoutb_delivery
                             CHANGING  lv_confirmed_lines
                                       lv_total_to_lines.

*   &1 picked(&2 of &3)
    MESSAGE s151(zits) WITH lv_zzbatch
                            lv_confirmed_lines
                            lv_total_to_lines
                       INTO zsits_scan_dynp-zzsuccess_msg.

    CLEAR zsits_scan_dynp-zzbarcode.
  ENDIF.

ENDFORM.                    " VALIDATE_SCANNED_FG_BATCH_LIST
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_RM_BATCH
*&---------------------------------------------------------------------*
*       Validate batch, material and quantity with o/b delivery
*----------------------------------------------------------------------*
FORM validate_rm_batch CHANGING cv_display_msg TYPE boolean.

  DATA: lit_to_item TYPE zttits_to_item,
        lwa_to_item TYPE zsits_to_item.

  DATA: lwa_batch_stock  TYPE zsits_batch_stock,
        lwa_to_conf_item TYPE zsits_to_conf_item,
        lwa_to_conf      TYPE zsits_to_conf,
        ls_batch_key     TYPE zsits_batch_key.

  DATA: lv_parent_batch TYPE ztits_pick-licha.

  DATA: lv_dummy TYPE bapi_msg.

* Delete the invalid TO line items
*----------------------------------------------------------------------
  MOVE x_to_data-to_item[] TO lit_to_item[].
  SORT lit_to_item BY matnr charg.
  DELETE lit_to_item WHERE matnr NE x_label_content-zzmatnr
                        OR charg NE x_label_content-zzbatch
                        OR pquit EQ abap_true.

  IF lit_to_item IS INITIAL.
*   &1 does not exist or already picked.
    MESSAGE e421(zits) WITH x_label_content-zzbatch zsits_scan_dynp-zzoutb_delivery INTO lv_dummy.

    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

* Check whether the batch has stock or not
*----------------------------------------------------------------------
  IF x_label_content-batch_data-batch_stock IS INITIAL."container label/'0' label with stock = 0
*   Batch &1 has no available stock!
    MESSAGE e346(zits) WITH x_label_content-zzbatch INTO lv_dummy.
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

* Generate confirmation data
*----------------------------------------------------------------------
  IF zcl_batch_utility=>is_zero_batch( x_label_content-batch_data ) EQ abap_true."'0' label with stock > 0
    lv_parent_batch = x_label_content-zzbatch.

    PERFORM validate_scanned_rm_batch_list USING    lit_to_item
                                                    space "Container batch
                                                    lv_parent_batch
                                           CHANGING cv_display_msg.
  ELSE."container label with stock > 0
*   Container batch will have stock only in one storage location/bin/unit.
    READ TABLE x_label_content-batch_data-batch_stock INTO lwa_batch_stock INDEX 1.

*   If the container batch exists with >0 qty in inventory, it can only be in one TO
    READ TABLE lit_to_item INTO lwa_to_item INDEX 1.
    IF lwa_to_item-vsolm = lwa_batch_stock-clabs.

      ls_batch_key-charg = x_label_content-zzbatch.
      ls_batch_key-matnr = x_label_content-zzmatnr.
      ls_batch_key-werks = x_label_content-batch_data-werks.

      IF zcl_batch_utility=>batch_lock( is_batch_key  = ls_batch_key
                                        iv_lock_mode  = zcl_its_utility=>gc_write_lock
                                        iv_lock_plant = abap_true ) = abap_false.
        cv_display_msg = abap_true.
        RETURN.
      ENDIF.

*     Confirm TO
      CLEAR lwa_to_conf.
      lwa_to_conf-lgnum = lwa_to_item-lgnum.
      lwa_to_conf-tanum = lwa_to_item-vbeln.

      CLEAR lwa_to_conf_item.
      lwa_to_conf_item-tanum = lwa_to_item-vbeln.
      lwa_to_conf_item-tapos = lwa_to_item-posnn.
      lwa_to_conf_item-squit = abap_true.
      APPEND lwa_to_conf_item TO lwa_to_conf-to_conf_item.
      APPEND lwa_to_conf TO it_to_conf.

    ELSE.
*     RM batch &1 not allowed to pick!
      MESSAGE e142(zits) WITH x_label_content-zzbatch INTO lv_dummy.
      cv_display_msg = abap_true.
      RETURN.
    ENDIF.
  ENDIF.

ENDFORM.                    " VALIDATE_RM_BATCH
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_RM_BATCH_VIRTUAL
*&---------------------------------------------------------------------*
*       Validate container batch that was not established
*----------------------------------------------------------------------*
FORM validate_rm_batch_virtual  CHANGING cv_display_msg TYPE boolean.

  DATA: lit_to_item        TYPE zttits_to_item.
  DATA: lwa_scanned_label  TYPE ztits_pick.
  DATA: lv_parent_batch    TYPE ztits_pick-licha,
        lv_container_batch TYPE ztits_pick-charg.
  DATA: lv_dummy           TYPE string.

* Delete the invalid TO line items
*----------------------------------------------------------------------
  MOVE x_to_data-to_item[] TO lit_to_item[].
  SORT lit_to_item BY matnr charg.
  DELETE lit_to_item WHERE matnr NE x_label_content-zzmatnr
                        OR charg NE x_label_content-zzorigin_batch
                        OR pquit EQ abap_true.

  IF lit_to_item IS INITIAL.
*   &1 does not exist or already picked.
    MESSAGE e399(zits) WITH x_label_content-zzbatch INTO lv_dummy.
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

* Check whether the batch was scanned before
*----------------------------------------------------------------------
  lv_parent_batch    = x_label_content-zzorigin_batch.
  lv_container_batch = x_label_content-zzbatch.

  READ TABLE it_scanned_batch_list INTO lwa_scanned_label
                                   WITH KEY matnr = x_label_content-batch_data-matnr
                                            charg = lv_container_batch
                                            licha = lv_parent_batch.
  IF sy-subrc = 0.
*   &1 does not exist or already picked.
    MESSAGE e399(zits) WITH x_label_content-zzbatch INTO lv_dummy.
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

* Check if over pick
*----------------------------------------------------------------------
  PERFORM validate_scanned_rm_batch_list USING    lit_to_item
                                                  lv_container_batch
                                                  lv_parent_batch
                                         CHANGING cv_display_msg.

ENDFORM.                    " VALIDATE_RM_BATCH_VIRTUAL
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_SCANNED_RM_BATCH_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM validate_scanned_rm_batch_list USING    ut_to_item         TYPE zttits_to_item
                                             uv_container_batch TYPE ztits_pick-charg
                                             uv_parent_batch    TYPE ztits_pick-licha
                                    CHANGING cv_display_msg     TYPE boolean.

  DATA: lit_to_item       TYPE zttits_to_item,
        lit_to_item_valid TYPE zttits_to_item,
        lwa_to_item_valid TYPE zsits_to_item,
        lwa_to_item       TYPE zsits_to_item,
        lwa_to_conf_item  TYPE zsits_to_conf_item,
        lwa_to_conf       TYPE zsits_to_conf,
        lwa_scanned_label TYPE ztits_pick.

  DATA: ls_batch_key         TYPE zsits_batch_key,
        lx_parent_batch_data TYPE zsits_batch_data,
        lv_parent_batch      TYPE zd_origin_batch.

  DATA: lv_picking_quantity TYPE zsits_to_item-vsolm,
        lv_confirm_flag     TYPE boolean,
        lv_confirmed_lines  TYPE i,
        lv_total_to_lines   TYPE i.

  DATA: lv_dummy TYPE string.

  FIELD-SYMBOLS: <fs_scanned_label> TYPE ztits_pick.

  MOVE ut_to_item[] TO lit_to_item[].
  SORT lit_to_item BY lgnum tanum tapos.

* Check if over pick
*----------------------------------------------------------------------
  LOOP AT lit_to_item INTO lwa_to_item WHERE vsolm GE x_label_content-zzquantity.
    CLEAR lv_picking_quantity.

    LOOP AT it_scanned_batch_list INTO lwa_scanned_label WHERE lgnum = lwa_to_item-lgnum
                                                           AND tanum = lwa_to_item-tanum
                                                           AND tapos = lwa_to_item-tapos
                                                           AND matnr = x_label_content-batch_data-matnr
                                                           AND licha = uv_parent_batch.
      lv_picking_quantity = lv_picking_quantity + lwa_scanned_label-zzquantity.
    ENDLOOP.

    IF lv_picking_quantity IS NOT INITIAL.
*     parent batch was picked before
      lv_picking_quantity = lv_picking_quantity + x_label_content-zzquantity.

      IF lv_picking_quantity = lwa_to_item-vsolm.
        MOVE lwa_to_item TO lwa_to_item_valid.
        lv_confirm_flag = abap_true."confirm to
        EXIT.
      ELSEIF lv_picking_quantity > lwa_to_item-vsolm."over pick
        CONTINUE.
      ELSE.
        APPEND lwa_to_item TO lit_to_item_valid.
      ENDIF.
    ELSE.
*     batch was not picked
      IF x_label_content-zzquantity = lwa_to_item-vsolm.
        MOVE lwa_to_item TO lwa_to_item_valid.
        lv_confirm_flag = abap_true."confirm to
        EXIT.
      ELSE.
        APPEND lwa_to_item TO lit_to_item_valid.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lwa_to_item_valid IS INITIAL AND lit_to_item_valid IS INITIAL.
*   RM batch &1 over picked !
    MESSAGE e148(zits) WITH x_label_content-zzbatch INTO lv_dummy.
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

* Add valid TO line item into internal table 'IT_SCANNED_BATCH_LIST' and DB table 'ZTITS_PICK'
*----------------------------------------------------------------------
  IF lwa_to_item_valid IS INITIAL.
    SORT lit_to_item_valid BY lgnum tanum tapos.
    READ TABLE lit_to_item_valid INTO lwa_to_item_valid INDEX 1.
  ENDIF.

* Lock TABLE 'ZTITS_PICK'
  CALL FUNCTION 'ENQUEUE_EZTITS_PICK'
    EXPORTING
      mode_ztits_pick = 'E'
      mandt           = sy-mandt
      lgnum           = lwa_to_item_valid-lgnum
      tanum           = lwa_to_item_valid-tanum
      tapos           = lwa_to_item_valid-tapos
    EXCEPTIONS
      foreign_lock    = 1
      system_failure  = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
*   Lock table ZTITS_PICK failed
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

  ls_batch_key-charg = uv_parent_batch.
  ls_batch_key-matnr = x_label_content-batch_data-matnr.
  IF zcl_batch_utility=>batch_lock( ls_batch_key ) = abap_false.
* Batch lock fails
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

  IF uv_container_batch IS NOT INITIAL.
*   Scan container batch that was not established. Label content has no UoM.
*   Then we have to get that value from parent batch.
    lv_parent_batch = uv_parent_batch.

    lx_parent_batch_data = zcl_batch_utility=>is_rw_batch( iv_batch         = uv_parent_batch
                                                           iv_matnr         = x_label_content-batch_data-matnr
                                                           iv_parent_batch  = lv_parent_batch
                                                           iv_unexist_check = abap_false ).

    APPEND INITIAL LINE TO it_scanned_batch_list ASSIGNING <fs_scanned_label>.
    <fs_scanned_label>-lgnum      = lwa_to_item_valid-lgnum.
    <fs_scanned_label>-tanum      = lwa_to_item_valid-tanum.
    <fs_scanned_label>-tapos      = lwa_to_item_valid-tapos.
    <fs_scanned_label>-matnr      = x_label_content-batch_data-matnr.
    <fs_scanned_label>-charg      = uv_container_batch.
    <fs_scanned_label>-licha      = uv_parent_batch.
    <fs_scanned_label>-zzquantity = x_label_content-zzquantity.
    <fs_scanned_label>-meins      = lx_parent_batch_data-meins.
  ELSE.
*   Scanned '0' label
    READ TABLE it_scanned_batch_list ASSIGNING <fs_scanned_label> WITH KEY  lgnum = lwa_to_item_valid-lgnum
                                                                            tanum = lwa_to_item_valid-tanum
                                                                            tapos = lwa_to_item_valid-tapos
                                                                            matnr = x_label_content-batch_data-matnr
                                                                            charg = space
                                                                            licha = uv_parent_batch.
    IF sy-subrc = 0.
*     parent batch was scanned before
      <fs_scanned_label>-zzquantity = <fs_scanned_label>-zzquantity + x_label_content-zzquantity.
    ELSE.
      APPEND INITIAL LINE TO it_scanned_batch_list ASSIGNING <fs_scanned_label>.
      <fs_scanned_label>-lgnum      = lwa_to_item_valid-lgnum.
      <fs_scanned_label>-tanum      = lwa_to_item_valid-tanum.
      <fs_scanned_label>-tapos      = lwa_to_item_valid-tapos.
      <fs_scanned_label>-matnr      = x_label_content-batch_data-matnr.
      <fs_scanned_label>-charg      = space.
      <fs_scanned_label>-licha      = uv_parent_batch.
      <fs_scanned_label>-zzquantity = x_label_content-zzquantity.
      <fs_scanned_label>-meins      = x_label_content-batch_data-meins.
    ENDIF.
  ENDIF.

  MODIFY ztits_pick FROM <fs_scanned_label>.

* If picked quantity is equal to quantity of TO line item, confirm that TO line item.
*----------------------------------------------------------------------
  IF lv_confirm_flag = abap_true.
*   Confirm
    CLEAR lwa_to_conf.
    lwa_to_conf-lgnum = lwa_to_item_valid-lgnum.
    lwa_to_conf-tanum = lwa_to_item_valid-vbeln.

    CLEAR lwa_to_conf_item.
    lwa_to_conf_item-tanum = lwa_to_item_valid-vbeln.
    lwa_to_conf_item-tapos = lwa_to_item_valid-posnn.
    lwa_to_conf_item-squit = abap_true.
    APPEND lwa_to_conf_item TO lwa_to_conf-to_conf_item.
    APPEND lwa_to_conf TO it_to_conf.
  ELSE.
    PERFORM frm_get_to_lines USING     zsits_scan_dynp-zzoutb_delivery
                             CHANGING  lv_confirmed_lines
                                       lv_total_to_lines.

    CALL METHOD zcl_batch_utility=>batch_unlock
      EXPORTING
        is_batch_key = ls_batch_key.

*   &1 picked(&2 of &3)
    MESSAGE s151(zits) WITH x_label_content-zzbatch
                            lv_confirmed_lines
                            lv_total_to_lines
                       INTO zsits_scan_dynp-zzsuccess_msg.

    CLEAR zsits_scan_dynp-zzbarcode.
  ENDIF.

ENDFORM.                    " VALIDATE_SCANNED_RM_BATCH_LIST
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_RM_NOB
*&---------------------------------------------------------------------*
*       Validate material and quantity with o/b delivery
*----------------------------------------------------------------------*
FORM validate_rm_nob CHANGING cv_display_msg TYPE boolean.

  DATA: lit_to_item       TYPE zttits_to_item,
        lwa_to_item       TYPE zsits_to_item,
        lwa_to_item_valid TYPE zsits_to_item,
        lit_to_item_valid TYPE zttits_to_item.

  DATA: lwa_to_conf_item  TYPE zsits_to_conf_item,
        lwa_to_conf       TYPE zsits_to_conf,
        lwa_scanned_label TYPE ztits_pick.

  DATA: lv_picking_quantity TYPE zsits_to_item-vsolm,
        lv_confirmed_flag   TYPE boolean,
        lv_confirmed_lines  TYPE i,
        lv_total_to_lines   TYPE i.

  DATA: lv_dummy TYPE bapi_msg.

  FIELD-SYMBOLS: <fs_scanned_label> TYPE ztits_pick.

* Delete the invalid TO line items
*----------------------------------------------------------------------
  MOVE x_to_data-to_item[] TO lit_to_item[].
  SORT lit_to_item BY matnr.
  DELETE lit_to_item WHERE matnr NE x_label_content-zzmatnr OR pquit = abap_true.

  IF lit_to_item IS INITIAL.
*   Non-batch managed material &1 not allowed to pick !
    MESSAGE e141(zits) WITH x_label_content-zzmatnr INTO lv_dummy.
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

* Check if over pick
*----------------------------------------------------------------------
  SORT lit_to_item BY lgnum tanum tapos.

  LOOP AT lit_to_item INTO lwa_to_item WHERE vsolm GE x_label_content-zzquantity.
    CLEAR lv_picking_quantity.

    READ TABLE it_scanned_batch_list INTO lwa_scanned_label WITH KEY lgnum = lwa_to_item-lgnum
                                                                     tanum = lwa_to_item-tanum
                                                                     tapos = lwa_to_item-tapos
                                                                     matnr = x_label_content-zzmatnr.
    IF sy-subrc = 0.
*     Material was picked before
      lv_picking_quantity = x_label_content-zzquantity + lwa_scanned_label-zzquantity.

      IF lwa_to_item-vsolm = lv_picking_quantity.
*       Confirm to
        MOVE lwa_to_item TO lwa_to_item_valid.
        lv_confirmed_flag = abap_true.
        EXIT.
      ELSEIF lwa_to_item-vsolm < lv_picking_quantity."Over pick
        CONTINUE.
      ELSE."Partial
        APPEND lwa_to_item TO lit_to_item_valid.
      ENDIF.
    ELSE.
*     Material was not picked
      IF lwa_to_item-vsolm = x_label_content-zzquantity.
*       Confirm to
        MOVE lwa_to_item TO lwa_to_item_valid.
        lv_confirmed_flag = abap_true.
        EXIT.
      ELSE.
        APPEND lwa_to_item TO lit_to_item_valid.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lwa_to_item_valid IS INITIAL AND lit_to_item_valid IS INITIAL.
*   Non-batch managed material &1 over picked !
    MESSAGE e140(zits) WITH x_label_content-zzmatnr INTO lv_dummy.
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

* Add the valid TO line item into internal table 'IT_SCANNED_BATCH_LIST' and DB table 'ZTITS_PICK'
*----------------------------------------------------------------------
  IF lwa_to_item_valid IS NOT INITIAL.
    lv_picking_quantity = lwa_to_item_valid-vsolm.
  ELSE.
    SORT lit_to_item_valid BY lgnum tanum tapos.
    READ TABLE lit_to_item_valid INTO lwa_to_item_valid INDEX 1.

    READ TABLE it_scanned_batch_list INTO lwa_scanned_label WITH KEY lgnum = lwa_to_item_valid-lgnum
                                                                     tanum = lwa_to_item_valid-tanum
                                                                     tapos = lwa_to_item_valid-tapos
                                                                     matnr = x_label_content-zzmatnr.
    IF sy-subrc = 0.
      lv_picking_quantity = x_label_content-zzquantity + lwa_scanned_label-zzquantity.
    ELSE.
      lv_picking_quantity = x_label_content-zzquantity.
    ENDIF.
  ENDIF.

* Lock TABLE 'ZTITS_PICK'
  CALL FUNCTION 'ENQUEUE_EZTITS_PICK'
    EXPORTING
      mode_ztits_pick = 'E'
      mandt           = sy-mandt
      lgnum           = lwa_to_item_valid-lgnum
      tanum           = lwa_to_item_valid-tanum
      tapos           = lwa_to_item_valid-tapos
    EXCEPTIONS
      foreign_lock    = 1
      system_failure  = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
*   Lock table ZTITS_PICK failed
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.

  READ TABLE it_scanned_batch_list ASSIGNING <fs_scanned_label> WITH KEY lgnum = lwa_to_item_valid-lgnum
                                                                         tanum = lwa_to_item_valid-tanum
                                                                         tapos = lwa_to_item_valid-tapos
                                                                         matnr = x_label_content-zzmatnr.
  IF sy-subrc = 0.
    <fs_scanned_label>-zzquantity = lv_picking_quantity.
  ELSE.
    APPEND INITIAL LINE TO it_scanned_batch_list ASSIGNING <fs_scanned_label>.
    <fs_scanned_label>-lgnum      = lwa_to_item_valid-lgnum.
    <fs_scanned_label>-tanum      = lwa_to_item_valid-tanum.
    <fs_scanned_label>-tapos      = lwa_to_item_valid-tapos.
    <fs_scanned_label>-matnr      = x_label_content-zzmatnr.
    <fs_scanned_label>-zzquantity = lv_picking_quantity.
*   Get Base UoM
    SELECT SINGLE meins
      INTO <fs_scanned_label>-meins
      FROM mara
     WHERE matnr = x_label_content-zzmatnr.
  ENDIF.

  MODIFY ztits_pick FROM <fs_scanned_label>.

* If picked quantity is equal to quantity of TO line item, confirm that TO line item.
*----------------------------------------------------------------------
  IF lv_confirmed_flag = abap_true.
*   Confirm
    CLEAR lwa_to_conf.
    lwa_to_conf-lgnum = lwa_to_item_valid-lgnum.
    lwa_to_conf-tanum = lwa_to_item_valid-vbeln.

    CLEAR lwa_to_conf_item.
    lwa_to_conf_item-tanum = lwa_to_item_valid-vbeln.
    lwa_to_conf_item-tapos = lwa_to_item_valid-posnn.
    lwa_to_conf_item-squit = abap_true.
    APPEND lwa_to_conf_item TO lwa_to_conf-to_conf_item.
    APPEND lwa_to_conf TO it_to_conf.
  ELSE.
    PERFORM frm_get_to_lines USING     zsits_scan_dynp-zzoutb_delivery
                             CHANGING  lv_confirmed_lines
                                       lv_total_to_lines.

    lv_dummy = x_label_content-zzmatnr.
    SHIFT lv_dummy LEFT DELETING LEADING '0'.

    MESSAGE s151(zits) WITH lv_dummy
                            lv_confirmed_lines
                            lv_total_to_lines
                       INTO zsits_scan_dynp-zzsuccess_msg."&1 picked(&2 of &3)

    CLEAR zsits_scan_dynp-zzbarcode.
  ENDIF.

ENDFORM.                    " VALIDATE_RM_NOB
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_TO
*&---------------------------------------------------------------------*
*       Transfer Order comfirm
*----------------------------------------------------------------------*
FORM confirm_to .

  DATA: lv_commit        TYPE boolean,
        lv_result        TYPE boolean VALUE abap_true,
        lwa_to_conf      TYPE zsits_to_conf,
        lwa_to_conf_item TYPE zsits_to_conf_item.

  DATA: lv_scan_object     TYPE string,
        lv_display_msg     TYPE boolean,
        lv_confirmed_lines TYPE i,
        lv_total_to_lines  TYPE i.

  lv_result = abap_true.

  PERFORM frm_get_to_lines USING     zsits_scan_dynp-zzoutb_delivery
                           CHANGING  lv_confirmed_lines
                                     lv_total_to_lines.

* For rolled up carton batch, commit work will be done after PALLET_ID was cleared.
  IF    v_label_type = zcl_its_utility=>gc_label_fg_batch "FG Carton Label
    AND x_label_content-batch_data-batch_stock IS INITIAL."carton batch was rolled up
    lv_commit = abap_false.
  ELSE.
    lv_commit = abap_true.
  ENDIF.

  LOOP AT it_to_conf INTO lwa_to_conf.
*   TO confirm
    IF zcl_its_utility=>to_confirm( is_to_conf        = lwa_to_conf
                                    iv_confirm_option = lv_commit ) =  abap_false.
      lv_result = abap_false.
      EXIT.
    ELSE.
      LOOP AT lwa_to_conf-to_conf_item INTO lwa_to_conf_item.
        PERFORM update_to_item USING lwa_to_conf-lgnum
                                     lwa_to_conf_item-tanum
                                     lwa_to_conf_item-tapos.

        lv_confirmed_lines = lv_confirmed_lines + 1.

*       Update Scanned label list
*       Clear PALLET_ID for carton batch that was rolled up.
        PERFORM update_after_confirm USING    lwa_to_conf-lgnum
                                              lwa_to_conf_item-tanum
                                              lwa_to_conf_item-tapos
                                     CHANGING lv_result.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'DEQUEUE_ALL'
    EXPORTING
      _synchron = abap_true.

  IF lv_result = abap_true.
    CASE v_label_type.
      WHEN zcl_its_utility=>gc_label_su.      "Pallet Label
        lv_scan_object = x_label_content-zzlenum.
      WHEN zcl_its_utility=>gc_label_fg_batch. "FG Carton Label
        IF x_label_content-batch_data-batch_stock IS NOT INITIAL."FG batch
          IF v_batch_gt_10 = abap_true."Special FG
            CONCATENATE x_label_content-zzbatch x_label_content-zzsublot INTO lv_scan_object.
          ELSE.
            lv_scan_object = x_label_content-zzbatch.
          ENDIF.
        ELSE."Parent batch
          lv_scan_object = x_label_content-batch_data-licha.
        ENDIF.
      WHEN zcl_its_utility=>gc_label_rm_batch."RAW Carton Label
        lv_scan_object = x_label_content-zzbatch.
      WHEN zcl_its_utility=>gc_label_rm_nob.  "Non-batch Managed Label
        lv_scan_object = x_label_content-zzmatnr.
    ENDCASE.

    SHIFT lv_scan_object LEFT DELETING LEADING '0'.

*   &1 picked(&2 of &3)
    MESSAGE s151(zits) WITH lv_scan_object
                            lv_confirmed_lines
                            lv_total_to_lines
                       INTO zsits_scan_dynp-zzsuccess_msg.
  ELSE.
    lv_display_msg = abap_true.
  ENDIF.

  PERFORM add_message USING zcl_its_utility=>gc_objid_to
                            lwa_to_conf-tanum
                            abap_true
                            lv_display_msg.

  CLEAR: zsits_scan_dynp-zzbarcode,
         it_to_conf.

* All locks will be removed after TO confirmation. So lock delivery again.
  IF zcl_its_utility=>delivery_lock( iv_delivery = zsits_scan_dynp-zzoutb_delivery ) = abap_false.
*   Lock delivery error
    RETURN.
  ENDIF.

ENDFORM.                    " CONFIRM_TO
*&---------------------------------------------------------------------*
*&      Form  FRM_GET_TO_LINES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_get_to_lines  USING    uv_delivery          TYPE vbeln
                       CHANGING cv_confirmed_lines   TYPE i
                                cv_total_to_lines    TYPE i.

  DATA: lv_delivery TYPE vbeln.

  FIELD-SYMBOLS:<fs_to_line> LIKE LINE OF x_delivery_to.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = uv_delivery
    IMPORTING
      output = lv_delivery.

* Note: cancelled item and cancel TO item are not excluded for now
  DELETE x_delivery_to WHERE vbelv NE lv_delivery.

  DESCRIBE TABLE x_delivery_to LINES cv_total_to_lines.

  LOOP AT x_delivery_to ASSIGNING <fs_to_line>." WHERE taqui = abap_true.
    IF <fs_to_line>-taqui = abap_true.
      cv_confirmed_lines  = cv_confirmed_lines  + 1.
      CONTINUE.
    ENDIF.

*   TO item confirmed in process of the transaction
    READ TABLE x_to_data-to_item WITH KEY vbeln = <fs_to_line>-vbeln
                                          posnn = <fs_to_line>-posnn
                                          pquit = abap_true
                                 TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      cv_confirmed_lines  = cv_confirmed_lines  + 1.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " FRM_GET_TO_LINES
*&---------------------------------------------------------------------*
*&      Form  UPDATE_TO_ITEM
*&---------------------------------------------------------------------*
*       Update confirm indicator after confirmation
*----------------------------------------------------------------------*
FORM update_to_item USING uv_lgnum TYPE lgnum
                          uv_tanum TYPE tanum
                          uv_tapos TYPE tapos.

  FIELD-SYMBOLS: <fs_to_item> TYPE zsits_to_item.

  SORT x_to_data-to_item BY lgnum tanum tapos.

  READ TABLE x_to_data-to_item ASSIGNING <fs_to_item>
                               WITH KEY  lgnum = uv_lgnum
                                         tanum = uv_tanum
                                         tapos = uv_tapos
                               BINARY SEARCH.
  IF sy-subrc = 0.
    <fs_to_item>-pquit = abap_true.
  ENDIF.

ENDFORM.                    " UPDATE_TO_ITEM
*&---------------------------------------------------------------------*
*&      Form  UPDATE_FG_AFTER_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM update_fg_after_confirm USING    uv_lgnum         TYPE lgnum
                                      uv_tanum         TYPE tanum
                                      uv_tapos         TYPE tapos
                             CHANGING cv_update_result TYPE boolean.

  DATA: lwa_fg_batch   LIKE LINE OF it_scanned_batch_list,
        lx_batch_line  TYPE zsotc_batch,
        lwa_char_value TYPE bapi1003_alloc_values_char,
        lit_char_value TYPE tt_bapi1003_alloc_values_char.

  cv_update_result = abap_true.

  LOOP AT it_scanned_batch_list INTO lwa_fg_batch WHERE lgnum = uv_lgnum
                                                    AND tanum = uv_tanum
                                                    AND tapos = uv_tapos.
    CLEAR lx_batch_line.
    lx_batch_line-matnr = lwa_fg_batch-matnr.
    lx_batch_line-charg = lwa_fg_batch-charg.

    CLEAR lwa_char_value.
    lwa_char_value-charact    = zcl_common_utility=>gc_chara_palletid.  " PALLET_ID
    lwa_char_value-value_char = ''.   " clear the value
    APPEND lwa_char_value TO lit_char_value.

*   Clear PALLET_ID
    CALL METHOD zcl_common_utility=>batch_char_add
      EXPORTING
        is_batch       = lx_batch_line
        it_valueschar  = lit_char_value
        iv_save_option = abap_false "zcl_common_utility=>gc_commit_work
      RECEIVING
        rv_result      = cv_update_result.

    IF cv_update_result = abap_false.
*     update batch characteristic error
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " UPDATE_FG_AFTER_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  UPDATE_AFTER_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM update_after_confirm  USING    uv_lgnum      TYPE lgnum
                                    uv_tanum      TYPE tanum
                                    uv_tapos      TYPE tapos
                           CHANGING cv_error_flag TYPE boolean.

  DATA: lv_update_fg_result TYPE boolean.

  DATA:
    lwa_fg_batch         LIKE LINE OF it_scanned_batch_list,
    lx_batch_line        TYPE zsotc_batch,
    lwa_char_value       TYPE bapi1003_alloc_values_char,
    lv_update_batch_delv TYPE boolean,
    lit_char_value       TYPE tt_bapi1003_alloc_values_char,
    lit_batch_data       TYPE TABLE OF zsits_batch_data,
    lwa_carton_data      TYPE zsits_batch_data..

  IF    v_label_type NE zcl_its_utility=>gc_label_fg_batch   "FG Carton Label
    AND v_label_type EQ zcl_its_utility=>gc_label_rm_batch   "RAW Carton Label
    AND v_label_type EQ zcl_its_utility=>gc_label_rm_nob.    "Non-batch Managed Label
    RETURN.
  ENDIF.

  cv_error_flag = abap_false.

* For FG batch which was rolled up, PALLET_ID should be removed
*----------------------------------------------------------------------
  IF    v_label_type = zcl_its_utility=>gc_label_fg_batch "FG Carton Label
    AND x_label_content-batch_data-batch_stock IS INITIAL."carton batch was rolled up
*   Clear PALLET_ID
    PERFORM update_fg_after_confirm USING    uv_lgnum
                                             uv_tanum
                                             uv_tapos
                                    CHANGING lv_update_fg_result.
    IF lv_update_fg_result = abap_false.
      RETURN.
    ELSE.
*     Commit work - TO confirmation and PALLET_ID clearing
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
    ENDIF.
  ENDIF.


  CLEAR :lwa_char_value, lit_char_value.
  lwa_char_value-charact    = gs_tvarvc-low.
  lwa_char_value-value_char = zsits_scan_dynp-zzoutb_delivery. " Delivery
  APPEND lwa_char_value TO lit_char_value.

  LOOP AT it_scanned_batch_list INTO lwa_fg_batch WHERE lgnum = uv_lgnum
                                                    AND tanum = uv_tanum
                                                    AND tapos = uv_tapos.
**
    lx_batch_line-matnr = lwa_fg_batch-matnr.
    lx_batch_line-charg = lwa_fg_batch-charg.

    CALL METHOD zcl_common_utility=>batch_char_add
      EXPORTING
        is_batch       = lx_batch_line
        it_valueschar  = lit_char_value
        iv_save_option = zcl_common_utility=>gc_commit_work
      RECEIVING
        rv_result      = lv_update_batch_delv.
  ENDLOOP.

  IF sy-subrc NE 0.
    IF v_label_type = 'SU'.

      CALL METHOD zcl_its_utility=>get_cartons_by_su
        EXPORTING
          is_su_content = x_label_content-su_content
        IMPORTING
          et_batch_data = lit_batch_data.

      LOOP AT lit_batch_data INTO lwa_carton_data.
        lx_batch_line-matnr =  lwa_carton_data-matnr.
        lx_batch_line-charg =  lwa_carton_data-charg.

        CALL METHOD zcl_common_utility=>batch_char_add
          EXPORTING
            is_batch       = lx_batch_line
            it_valueschar  = lit_char_value
            iv_save_option = zcl_common_utility=>gc_commit_work
          RECEIVING
            rv_result      = lv_update_batch_delv.

      ENDLOOP.

    ELSE.
      lx_batch_line-matnr = x_label_content-batch_data-matnr.
      lx_batch_line-charg = x_label_content-batch_data-charg.

      CALL METHOD zcl_common_utility=>batch_char_add
        EXPORTING
          is_batch       = lx_batch_line
          it_valueschar  = lit_char_value
          iv_save_option = zcl_common_utility=>gc_commit_work
        RECEIVING
          rv_result      = lv_update_batch_delv.

    ENDIF.
  ENDIF.
* Update internal table
*----------------------------------------------------------------------
  DELETE it_scanned_batch_list WHERE lgnum = uv_lgnum
                                 AND tanum = uv_tanum
                                 AND tapos = uv_tapos.

* When all items of TO were confirmed, records in table ZTITS_PICK should be deleted.
*----------------------------------------------------------------------
  READ TABLE x_to_data-to_item WITH KEY lgnum = uv_lgnum
                                        tanum = uv_tanum
                                        pquit = abap_false
                               TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
*   Add lock to table ZTITS_PICK
    CALL FUNCTION 'ENQUEUE_EZTITS_PICK'
      EXPORTING
        mode_ztits_pick = 'E'
        mandt           = sy-mandt
        lgnum           = uv_lgnum
        tanum           = uv_tanum
      EXCEPTIONS
        foreign_lock    = 1
        system_failure  = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
*     Lock table ZTITS_PICK failed
      RETURN.
    ENDIF.

    DELETE FROM ztits_pick WHERE lgnum = uv_lgnum
                             AND tanum = uv_tanum.

    CALL FUNCTION 'DEQUEUE_EZTITS_PICK'
      EXPORTING
        mode_ztits_pick = 'E'
        mandt           = sy-mandt
        lgnum           = uv_lgnum
        tanum           = uv_tanum.
  ENDIF.

  cv_error_flag = abap_true.

ENDFORM.                    " UPDATE_AFTER_CONFIRM

*&---------------------------------------------------------------------*
*&      Form  VALIDATE_PALLET_LABEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_DISPLAY_MSG  text
*----------------------------------------------------------------------*
FORM validate_pallet_label  CHANGING cv_display_msg TYPE boolean.

  DATA: lwa_hu_item         TYPE bapihuitem,
        lwa_delivery_item   TYPE zsits_dlv_item,
        lwa_delivery_pick   TYPE vbfa,
        lwa_picking_item    TYPE vbpok,
        lwa_hu_1            TYPE hum_rehang_hu,
        lwa_hu_content_item TYPE bapihuitem  ##NEEDED,
        lv_picked_qty       TYPE vbfa-rfmng,
        lv_pick_qty_max     TYPE vbfa-rfmng,
        lv_picking_qty      TYPE vbfa-rfmng,
        lv_dummy            TYPE bapi_msg ##NEEDED,
        lv_batch            TYPE zzbatch,
        lx_read_option      TYPE zsits_batch_read_option,
        lx_batch_data       TYPE zsits_batch_data.

  v_scan_object = x_label_content-zzhu_exid.
  SHIFT v_scan_object LEFT DELETING LEADING '0'.


* Check Pack status
*----------------------------------------------------------------------
  IF zcl_its_utility=>get_doc_status( iv_status_name = zcl_its_utility=>gc_pack_status_h  "PKSTK
                                      iv_doc_num     = zsits_scan_dynp-zzoutb_delivery )
    EQ zcl_its_utility=>gc_status_complete.
*   O/B delivery &1 already packed!
    MESSAGE e280(zits) WITH zsits_scan_dynp-zzoutb_delivery INTO lv_dummy.
    cv_display_msg = abap_true.
    RETURN.
  ENDIF.
  LOOP AT x_label_content-hu_content-hu_content INTO lwa_hu_item.
*---Check whether batch was assigned to delivery or not
*----------------------------------------------------------------------
    CLEAR : lwa_delivery_item.
    READ TABLE it_delivery_item INTO     lwa_delivery_item
                                WITH KEY matnr = lwa_hu_item-material
                                         charg = lwa_hu_item-batch
                                BINARY SEARCH.
    IF sy-subrc NE 0.
*     Pallet &1 not allowed to pick!
      MESSAGE e138(zits) WITH x_label_content-zzhu_exid INTO lv_dummy.
      cv_display_msg = abap_true.
      EXIT.
    ENDIF.

*---Check IM/batch/QI lot status
*----------------------------------------------------------------------
    CLEAR: lv_batch, lx_batch_data.

    lv_batch = lwa_hu_item-batch.
    lx_read_option-zzstock_read   = abap_true.
    lx_read_option-zzcharact_read = abap_true.
    lx_read_option-zzinsp_lot     = abap_true.

    CALL METHOD zcl_batch_utility=>batch_read_hu
      EXPORTING
        iv_batch       = lv_batch
        is_read_option = lx_read_option
      RECEIVING
        rs_batch_data  = lx_batch_data.

    IF zcl_its_utility=>is_batch_allowed_for_ship_hu(      iv_werks      = lwa_delivery_item-werks
                                                           iv_lgort      = lwa_delivery_item-lgort
                                                           is_delivery   = x_delivery_header
                                                           is_batch_data = lx_batch_data ) = abap_false.
*     Batch &1 has IM/batch/QI lot status that's not allowed for picking
      cv_display_msg = abap_true.
      EXIT.
    ENDIF.

*---Check if overpicked
*----------------------------------------------------------------------
    CLEAR : lv_picked_qty, lwa_delivery_pick.
    LOOP AT it_delivery_pick INTO lwa_delivery_pick WHERE vbelv = lwa_delivery_item-vbeln
                                                      AND posnv = lwa_delivery_item-posnr.
      lv_picked_qty = lv_picked_qty + lwa_delivery_pick-rfmng.
    ENDLOOP.

    lv_pick_qty_max = lwa_delivery_item-lgmng - lv_picked_qty.

    IF lwa_hu_item-pack_qty > lv_pick_qty_max.
*     Batch &1 on Pallet &2 over picked.
      MESSAGE e139(zits) WITH lwa_hu_item-batch x_label_content-zzhu_exid
                         INTO lv_dummy.
      cv_display_msg = abap_true.
      EXIT.
    ENDIF.

*---Generate pick data
*----------------------------------------------------------------------
    CLEAR lwa_delivery_pick.
    READ TABLE it_delivery_pick INTO     lwa_delivery_pick
                                WITH KEY vbelv = lwa_delivery_item-vbeln
                                         posnv = lwa_delivery_item-posnr
                                         vbeln = lwa_delivery_item-vbeln
                                         posnn = lwa_delivery_item-posnr
                                BINARY SEARCH.
    IF sy-subrc = 0.
      lv_picking_qty = lwa_hu_item-pack_qty + lwa_delivery_pick-rfmng.
    ELSE.
      lv_picking_qty = lwa_hu_item-pack_qty.
    ENDIF.

    CLEAR lwa_picking_item.
    lwa_picking_item-vbeln_vl = lwa_delivery_item-vbeln.
    lwa_picking_item-posnr_vl = lwa_delivery_item-posnr.
    lwa_picking_item-vbeln    = lwa_delivery_item-vbeln.
    lwa_picking_item-posnn    = lwa_delivery_item-posnr.
    lwa_picking_item-lgmng    = lv_picking_qty.
    lwa_picking_item-lgort    = lwa_delivery_item-lgort.
    lwa_picking_item-meins    = lwa_delivery_item-meins.
    APPEND lwa_picking_item TO it_picking_item.


    CLEAR lwa_hu_1.
    lwa_hu_1-top_hu_internal = x_label_content-hu_content-hu_header-hu_id.
    lwa_hu_1-venum           = x_label_content-hu_content-hu_header-hu_id.
    lwa_hu_1-vepos           = lwa_hu_item-hu_item_number.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = zsits_scan_dynp-zzoutb_delivery
      IMPORTING
        output = lwa_hu_1-rfbel.

    lwa_hu_1-rfpos = lwa_delivery_item-posnr.

    APPEND lwa_hu_1 TO it_hu_1.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ADD_HU_PALET_CARTON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_hu_palet_carton .
  DATA: lt_hus            TYPE hum_exidv_t,
        lw_hus            TYPE hum_exidv,
        lt_header         TYPE hum_hu_header_t,

        lt_header_temp    TYPE hum_hu_header_t,

        lw_header         TYPE vekpvb,
        lt_highest_levels TYPE hum_venum_t,
        lt_messages       TYPE huitem_messages_t,
        lv_venum          TYPE venum,
        lv_display_msg    TYPE boolean.

  CLEAR wa_su.
  READ TABLE it_su INTO wa_su WITH KEY x_label_content-zzlenum. " zsits_scan_dynp-zzsu.
  IF sy-subrc EQ 0.
    " HU already added
  ELSE.
*    IF zsits_scan_dynp-zzsu IS NOT INITIAL.
    IF x_label_content-zzlenum IS NOT INITIAL.
      "Check whether HU is a Pallet or Carton

      IF gv_plt_flg = abap_true. "HU is pallet HU
        "Call FM to get HU hirarchy
        lw_hus-exidv = x_label_content-zzlenum.
        APPEND lw_hus TO lt_hus.
        IF lt_hus IS NOT INITIAL.
          CALL FUNCTION 'HU_GET_HUS'
            EXPORTING
              if_no_loop        = 'X'
              it_hus            = lt_hus
            IMPORTING
              et_header         = lt_header
              et_highest_levels = lt_highest_levels
              et_messages       = lt_messages
            EXCEPTIONS
              hus_locked        = 1
              no_hu_found       = 2
              fatal_error       = 3
              OTHERS            = 4.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ELSE.
            IF lt_header IS NOT INITIAL.
              CLEAR lv_venum.
              "Find VENUM for parent HU
              lv_venum = lt_highest_levels[ 1 ]-venum.
              "Delete duplicate HU now
              lt_header_temp = lt_header.
              IF lv_venum IS NOT INITIAL.
                DELETE lt_header_temp WHERE venum = lv_venum.
                IF lt_header_temp IS NOT INITIAL.
                  LOOP AT lt_header_temp INTO lw_header.
                    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                      EXPORTING
                        input  = lw_header-exidv
                      IMPORTING
                        output = wa_su.
                    APPEND wa_su TO it_su.
                    CLEAR : wa_su, lw_header.
                  ENDLOOP.
                ELSE.  "Pallet HU contains no child Cartons

                  " HU contains no child HU case, still populate it_su and gv_su's
                  wa_su = x_label_content-zzlenum.
                  APPEND wa_su TO it_su.
                  CLEAR wa_su.
                ENDIF.
              ENDIF.
            ENDIF.

          ENDIF.
        ENDIF.
      ELSE. "HU is carton HU
        wa_su = x_label_content-zzlenum.
        APPEND wa_su TO it_su.
        CLEAR wa_su.
      ENDIF.
      CLEAR: lw_hus, lt_header, zsits_scan_dynp-zzbarcode.


    ELSE.
      IF zsits_scan_dynp-zzbarcode IS NOT INITIAL.
        " Handling unit doesn't exists
        MESSAGE e000(zmtdus) WITH x_label_content-zzlenum INTO lv_dummy.
        lv_display_msg = abap_true.
        PERFORM add_message USING zcl_its_utility=>gc_objid_to
                                  lv_barcode
                                  lv_display_msg
                                  lv_display_msg.
        CLEAR: zsits_scan_dynp-zzbarcode.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_PALLET_CARTON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_X_LABEL_CONTENT_ZZLENUM  text
*      <--P_GV_PLT_FLG  text
*----------------------------------------------------------------------*
FORM check_pallet_carton  USING    iu_zzlenum TYPE zd_lenum
                          CHANGING gv_plt_flg.

  TYPES: BEGIN OF ts_ltap,
           lgnum TYPE lgnum,
           tanum TYPE tanum,
           tapos TYPE tapos,
           vlenr TYPE ltap_vlenr,
           vsolm TYPE ltap_vsolm,
         END OF ts_ltap.

  DATA: lv_exidv          TYPE exidv,
        lv_venum          TYPE venum,
        lv_uevel          TYPE uevel,
        lt_hus            TYPE hum_exidv_t,
        ls_hus            TYPE hum_exidv,
        lt_header         TYPE hum_hu_header_t,
        lt_header_t       TYPE hum_hu_header_t,
        ls_header         TYPE vekpvb,
        lt_items          TYPE hum_hu_item_t,
        lv_lgnum          TYPE lgnum,
        lv_parent         TYPE venum,
        lt_ltap           TYPE TABLE OF ts_ltap,
        ls_ltap           TYPE ts_ltap,
        lv_qty_flag       TYPE flag,
        lv_succ_flag      TYPE flag,
        lv_tot_qty        TYPE ltap_vsolm,
        lt_messages       TYPE huitem_messages_t,
        lt_highest_levels TYPE hum_venum_t.

  DATA: lv_display_msg TYPE boolean,
        lv_dummy       TYPE string.


  IF iu_zzlenum IS NOT INITIAL.
    CLEAR lv_exidv.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = iu_zzlenum
      IMPORTING
        output = lv_exidv.  "Carton HU scanned

    "Check whether gt_zlscan_ewmpick_data is already populated,
    "only populate if not done already
    CLEAR ls_zlscan_ewmpick_data.
    READ TABLE gt_zlscan_ewmpick_data INTO ls_zlscan_ewmpick_data WITH KEY vlenr = lv_exidv. "check for pallet
    IF sy-subrc NE 0.
      READ TABLE gt_zlscan_ewmpick_data INTO ls_zlscan_ewmpick_data WITH KEY lower_hu  = lv_exidv "check for carton
                                                                             scan_flag = abap_true.
      IF sy-subrc NE 0.
        CLEAR: ls_hus, lt_hus.
        ls_hus-exidv = lv_exidv.
        APPEND ls_hus TO lt_hus.

        IF lt_hus IS NOT INITIAL.
          CLEAR: lt_header, lt_items,
                 lt_highest_levels, lt_messages.
          CALL FUNCTION 'HU_GET_HUS'
            EXPORTING
              if_no_loop        = 'X'
              it_hus            = lt_hus
              if_more_hus       = 'X'
            IMPORTING
              et_header         = lt_header
              et_items          = lt_items
              et_highest_levels = lt_highest_levels
              et_messages       = lt_messages
            EXCEPTIONS
              hus_locked        = 1
              no_hu_found       = 2
              fatal_error       = 3
              OTHERS            = 4.
          IF sy-subrc <> 0.

          ELSE.
            IF lt_header IS NOT INITIAL.
              TRY .
                  "Find VENUM for parent HU
                  CLEAR lv_parent.
                  lv_parent = lt_highest_levels[ 1 ]-venum.

                CATCH cx_root.
                  CLEAR zsits_scan_dynp-zzbarcode.
                  RETURN.

              ENDTRY.

              SORT lt_header BY venum.
              lt_header_t = lt_header .
              DELETE lt_header_t WHERE venum = lv_parent.
            ENDIF.
            IF lt_items IS NOT INITIAL.
              SORT lt_items BY venum ASCENDING.
            ENDIF.

            IF lt_header_t IS NOT INITIAL.  " Carton(Part of Pallet) scanned
              CLEAR: lv_lgnum, ls_ltap.
              lv_lgnum = lt_header[ 1 ]-lgnum. " Warehouse
              SELECT SINGLE lgnum
                            tanum
                            tapos
                            vlenr
                            vsolm
                           FROM ltap
                           INTO ls_ltap
                           WHERE lgnum = lv_lgnum AND
                                 vlenr = lv_exidv AND
                                 pquit = '' .
              IF sy-subrc = 0.                   " Carton HU linked to TO ITem

                ls_zlscan_ewmpick_data-lgnum = ls_ltap-lgnum. " Warehouse
                ls_zlscan_ewmpick_data-tanum = ls_ltap-tanum. " TO
                ls_zlscan_ewmpick_data-tapos = ls_ltap-tapos. " TO ITEM
                ls_zlscan_ewmpick_data-vsolm = ls_ltap-vsolm. " TO Item qty

                CLEAR ls_header.
                READ TABLE lt_header INTO ls_header WITH KEY venum = lv_parent BINARY SEARCH.
                IF sy-subrc = 0.
                  ls_zlscan_ewmpick_data-vlenr = ls_header-exidv.  " Pallet HU
                  "Zero pad parent HU to avoid errors in comparison later
                  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                    EXPORTING
                      input  = ls_zlscan_ewmpick_data-vlenr
                    IMPORTING
                      output = ls_zlscan_ewmpick_data-vlenr.

                  READ TABLE lt_items INTO DATA(ls_items) WITH KEY venum = ls_header-venum BINARY SEARCH.
                  IF sy-subrc = 0.
                    ls_zlscan_ewmpick_data-scan_hu_qty = ls_items-vemng.
                  ENDIF.
                ENDIF.

                ls_zlscan_ewmpick_data-scan_flag = abap_true.
                PERFORM check_to_n_hu_qty USING  ls_zlscan_ewmpick_data-tanum " TO no
                                                 ls_zlscan_ewmpick_data-tapos " TO item no
                                                 ls_zlscan_ewmpick_data-vsolm  " TO Item qty
                                                 ls_zlscan_ewmpick_data-scan_hu_qty " HU qty
                                          CHANGING lv_qty_flag.
*                                                   lv_tot_qty .
                IF lv_qty_flag = abap_true.
                  APPEND ls_zlscan_ewmpick_data TO gt_zlscan_ewmpick_data.
                  "Populate sceen fields from Work area now
                  CLEAR wa_su.
                  wa_su = ls_zlscan_ewmpick_data-vlenr.
                  READ TABLE it_su WITH KEY table_line = wa_su TRANSPORTING NO FIELDS.
                  IF sy-subrc = 0.
                    MESSAGE e530(zits) WITH wa_su INTO lv_dummy.
                    lv_display_msg = abap_true.
                  ELSE.
                    APPEND wa_su TO it_su.
                  ENDIF.
                  CLEAR: lv_tot_qty, ls_zlscan_ewmpick_data, lv_qty_flag .
                ELSE. "populate error
                  " Error Message Carton qty more then TO Item qty
                  MESSAGE e521(zits) WITH iu_zzlenum INTO lv_dummy.
                  lv_display_msg = abap_true.
                  CLEAR: lv_tot_qty, ls_zlscan_ewmpick_data, lv_qty_flag .
                ENDIF.
              ELSE.                " Carton HU is not linked but Pallet HU is linked to TO ITem
                READ TABLE lt_header INTO ls_header WITH KEY venum = lv_parent.
                IF sy-subrc = 0.
                  SELECT SINGLE lgnum
                                tanum
                                tapos
                                vlenr
                                vsolm
                               FROM ltap
                               INTO ls_ltap
                               WHERE lgnum = lv_lgnum AND
                                     vlenr = ls_header-exidv AND " Pallet HU
                                     pquit = '' .
                  IF sy-subrc = 0.
                    lv_succ_flag = abap_true.
                  ELSE.
                    " Error Message Carton HU not linked to TO Item
                    MESSAGE e522(zits) WITH iu_zzlenum  INTO lv_dummy.
                    lv_display_msg = abap_true.
                  ENDIF.
                ENDIF.

                IF lv_succ_flag = abap_true.
                  CLEAR: lv_tot_qty.
                  LOOP AT gt_zlscan_ewmpick_data ASSIGNING FIELD-SYMBOL(<lfs_ewmpick>).
                    IF <lfs_ewmpick>-scan_flag = abap_true.
                      lv_tot_qty = lv_tot_qty + <lfs_ewmpick>-scan_hu_qty . " HU qty
                    ENDIF.
                  ENDLOOP.

                  LOOP AT lt_header_t INTO ls_header.  " Looping Carton HUs(Pallet HU is deleted)
                    ls_zlscan_ewmpick_data-lgnum = ls_ltap-lgnum. " Warehouse
                    ls_zlscan_ewmpick_data-tanum = ls_ltap-tanum. " TO
                    ls_zlscan_ewmpick_data-tapos = ls_ltap-tapos. " TO ITEM
                    ls_zlscan_ewmpick_data-vsolm = ls_ltap-vsolm. " TO Item qty

                    ls_zlscan_ewmpick_data-vlenr = ls_ltap-vlenr.      " Pallet HU
                    "Zero pad parent HU to avoid errors in comparison later
                    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                      EXPORTING
                        input  = ls_zlscan_ewmpick_data-vlenr
                      IMPORTING
                        output = ls_zlscan_ewmpick_data-vlenr.

                    ls_zlscan_ewmpick_data-lower_hu = ls_header-exidv. " Carton HU
                    CLEAR ls_items.
                    READ TABLE lt_items INTO ls_items WITH KEY venum = ls_header-venum BINARY SEARCH.
                    IF sy-subrc = 0.
                      ls_zlscan_ewmpick_data-scan_hu_qty = ls_items-vemng.
                    ENDIF.

                    IF lv_exidv = ls_header-exidv .
                      READ TABLE gt_zlscan_ewmpick_data ASSIGNING <lfs_ewmpick> WITH KEY vlenr = ls_ltap-vlenr
                                                                                         lower_hu = ls_header-exidv.
                      IF sy-subrc = 0.
                        IF <lfs_ewmpick>-scan_flag IS INITIAL.
                          PERFORM check_to_n_hu_qty USING  ls_zlscan_ewmpick_data-tanum  " TO Number
                                                           ls_zlscan_ewmpick_data-tapos  " TO Item
                                                           ls_zlscan_ewmpick_data-vsolm  " TO Item qty
                                                           ls_zlscan_ewmpick_data-scan_hu_qty " HU qty
                                                    CHANGING lv_qty_flag.
*                                                             lv_tot_qty.  "Cumulative HU qty
                          IF lv_qty_flag = abap_true.
                            <lfs_ewmpick>-scan_flag = abap_true.
                            " populate sceen fields from work area now
                            CLEAR wa_su.
                            wa_su = lv_exidv. " Append scanned Carton
                            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                              EXPORTING
                                input  = wa_su
                              IMPORTING
                                output = wa_su.
                            APPEND wa_su TO it_su.
                            CLEAR: zsits_scan_dynp-zzbarcode, wa_su.
                          ELSE.
                            " Error Message Carton qty more then TO Item qty
                            MESSAGE e521(zits) WITH iu_zzlenum INTO lv_dummy.
                            lv_display_msg = abap_true.
                            CLEAR zsits_scan_dynp-zzbarcode.
                          ENDIF.
                        ENDIF.
                      ELSE.
                        ls_zlscan_ewmpick_data-scan_flag = abap_true.
                        PERFORM check_to_n_hu_qty USING  ls_zlscan_ewmpick_data-tanum  " TO no
                                                         ls_zlscan_ewmpick_data-tapos  " To item no.
                                                         ls_zlscan_ewmpick_data-vsolm  " TO Item qty
                                                         ls_zlscan_ewmpick_data-scan_hu_qty " HU qty
                                                  CHANGING lv_qty_flag.
                        IF lv_qty_flag = abap_true.
                          APPEND ls_zlscan_ewmpick_data TO gt_zlscan_ewmpick_data.
                          "Populate sceen fields from Work area now
                          wa_su = lv_exidv. " Append scanned Carton
                          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                            EXPORTING
                              input  = lv_exidv
                            IMPORTING
                              output = wa_su.
                          APPEND wa_su TO it_su.
                          CLEAR: zsits_scan_dynp-zzbarcode, wa_su.
                        ELSE. "populate error
                          CLEAR: lv_tot_qty , gt_zlscan_ewmpick_data.
                          " Error Message Carton qty more then TO Item qty
                          MESSAGE e521(zits) WITH iu_zzlenum INTO lv_dummy.
                          lv_display_msg = abap_true.

                        ENDIF.
                      ENDIF.
                    ELSE.
                      READ TABLE gt_zlscan_ewmpick_data ASSIGNING <lfs_ewmpick> WITH KEY vlenr = ls_ltap-vlenr
                                                                                         lower_hu = ls_header-exidv.
                      IF sy-subrc NE 0.
                        APPEND ls_zlscan_ewmpick_data TO gt_zlscan_ewmpick_data.
*
                        CLEAR: zsits_scan_dynp-zzbarcode, wa_su.
                      ENDIF.

                    ENDIF.
                    CLEAR: ls_zlscan_ewmpick_data, ls_header.
                  ENDLOOP.
                ENDIF.
              ENDIF.
            ELSE. "New else part introduced for free carton case
              "Begin of change for defect 80, 16.03.2020
              CLEAR: lv_lgnum, ls_ltap.
              lv_lgnum = lt_header[ 1 ]-lgnum. " Warehouse
              SELECT SINGLE lgnum
                            tanum
                            tapos
                            vlenr
                            vsolm
                           FROM ltap
                           INTO ls_ltap
                           WHERE lgnum = lv_lgnum AND
                                 vlenr = lv_exidv AND
                                 pquit = '' .
              IF sy-subrc = 0.                   " Carton HU linked to TO ITem

                ls_zlscan_ewmpick_data-lgnum = ls_ltap-lgnum. " Warehouse
                ls_zlscan_ewmpick_data-tanum = ls_ltap-tanum. " TO
                ls_zlscan_ewmpick_data-tapos = ls_ltap-tapos. " TO ITEM
                ls_zlscan_ewmpick_data-vsolm = ls_ltap-vsolm. " TO Item qty
                CLEAR ls_header.
                READ TABLE lt_header INTO ls_header WITH KEY venum = lv_parent BINARY SEARCH.
                IF sy-subrc = 0.
                  ls_zlscan_ewmpick_data-vlenr = ls_header-exidv.  " Parent HU (here carton)
                  ls_zlscan_ewmpick_data-lower_hu = ls_header-exidv. " Child HU   (here carton)
                  CLEAR ls_items.
                  READ TABLE lt_items INTO ls_items WITH KEY venum = ls_header-venum BINARY SEARCH.
                  IF sy-subrc = 0.
                    ls_zlscan_ewmpick_data-scan_hu_qty = ls_items-vemng.
                  ENDIF.
                  ls_zlscan_ewmpick_data-scan_flag = abap_true.
                  "Begin of change for defect 80, 18.03.2020
                  PERFORM check_to_n_hu_qty USING  ls_zlscan_ewmpick_data-tanum "TO no.
                                                   ls_zlscan_ewmpick_data-tapos "TO line no.
                                                   ls_zlscan_ewmpick_data-vsolm  " TO Item qty
                                                   ls_zlscan_ewmpick_data-scan_hu_qty " HU qty
                                            CHANGING lv_qty_flag.
                  "End of change for defect 80, 18.03.2020
                  IF lv_qty_flag = abap_true.
                    APPEND ls_zlscan_ewmpick_data TO gt_zlscan_ewmpick_data.
                    "Populate sceen fields from Work area now
                    CLEAR wa_su.
                    wa_su = ls_zlscan_ewmpick_data-vlenr.
                    "Begin of change for defect 80, 04.03.2020
                    READ TABLE it_su WITH KEY table_line = wa_su TRANSPORTING NO FIELDS.
                    IF sy-subrc = 0.
                      MESSAGE e530(zits) WITH wa_su INTO lv_dummy.
                      lv_display_msg = abap_true.
                    ELSE.
                      APPEND wa_su TO it_su.
                    ENDIF.
                    "End of change for defect 80, 04.03.2020
                    CLEAR: lv_tot_qty, ls_zlscan_ewmpick_data, lv_qty_flag .
                  ELSE. "populate error
                    " Error Message Carton qty more then TO Item qty
                    MESSAGE e521(zits) WITH iu_zzlenum INTO lv_dummy.
                    lv_display_msg = abap_true.
                    CLEAR: lv_tot_qty, ls_zlscan_ewmpick_data, lv_qty_flag .
                  ENDIF.
                  "End of change for defect 80, 16.03.2020
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE. "Carton HU already exits in box
          "Begin of change for defect 80, 04.03.2020
          READ TABLE it_su WITH KEY table_line = lv_exidv TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            MESSAGE e530(zits) WITH lv_exidv INTO lv_dummy.
            lv_display_msg = abap_true.
          ENDIF.
          CLEAR zsits_scan_dynp-zzbarcode.
          "End of change for defect 80, 04.03.2020

        ENDIF.
      ELSE. "Pallet exists in HU box
        "Begin of change for defect 80, 04.03.2020
        READ TABLE it_su WITH KEY table_line = lv_exidv TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          MESSAGE e530(zits) WITH lv_exidv INTO lv_dummy.
          lv_display_msg = abap_true.
        ENDIF.
        CLEAR zsits_scan_dynp-zzbarcode.
        "End of change for defect 80, 04.03.2020
      ENDIF.
    ENDIF.
  ENDIF.
  IF  lv_display_msg =  abap_true.
    PERFORM add_message USING zcl_its_utility=>gc_objid_palt_cart "Object ID = 'Pallet/ Carton'
                            iu_zzlenum
                            lv_display_msg
                            lv_display_msg.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FETCH_PAK_MAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_PAK_MAT  text
*----------------------------------------------------------------------*
FORM fetch_pak_mat  USING uv_lenum TYPE zd_lenum
                    CHANGING cv_vbeln TYPE vbeln_vl
                             cv_posnr TYPE posnr_vl
                             cv_gv_pak_mat TYPE matnr.

  TYPES: BEGIN OF ty_lips,
           werks TYPE werks_d,
           mtart TYPE mtart,
         END OF ty_lips.

  DATA: ls_lips    TYPE ty_lips,
        lv_plt_flg TYPE flag.

  CONSTANTS: lc_2 TYPE n VALUE '2'.


  "Fetch data from LIPS first
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = cv_vbeln
    IMPORTING
      output = cv_vbeln.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = cv_posnr
    IMPORTING
      output = cv_posnr.

  SELECT SINGLE werks mtart
          FROM lips
          INTO ls_lips
          WHERE vbeln = cv_vbeln AND
                posnr = cv_posnr.
  IF ls_lips IS NOT INITIAL AND sy-subrc = 0.
    "Now fetch Packing material from z-table

    SELECT SINGLE pack_matnr
           FROM zlpack_mat
           INTO cv_gv_pak_mat
           WHERE werks = ls_lips-werks
           AND mtart = ls_lips-mtart
           AND  hu_id = lc_2. "hu pallet pack material

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = cv_gv_pak_mat
      IMPORTING
        output = cv_gv_pak_mat.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_CARTON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_DISPLAY_MSG  text
*----------------------------------------------------------------------*
FORM validate_carton  USING lv_carton TYPE zd_lenum
                      CHANGING c_lv_display_msg.


  TYPES:BEGIN OF ts_ltap,
          lgnum TYPE lgnum,
          tanum TYPE tanum,
          tapos TYPE tapos,
          vlenr TYPE ltap_vlenr,
          vbeln TYPE vbeln_vl,
        END OF ts_ltap.

  DATA: lv_pallet         TYPE zd_lenum,
        lw_hus            TYPE hum_exidv,
        lt_hus            TYPE hum_exidv_t,
        lt_header         TYPE hum_hu_header_t,
        lw_header         TYPE vekpvb,
        lv_vbeln          TYPE vbeln_vl,
        lt_highest_levels TYPE hum_venum_t,
        lt_messages       TYPE huitem_messages_t,
        lv_venum          TYPE venum,
        lt_ltap           TYPE TABLE OF ts_ltap,
        lt_return         TYPE TABLE OF  bapiret2,
        lt_hu             TYPE TABLE OF  bapihunumber,
        ls_hu             TYPE bapihunumber,
        lt_huitem         TYPE TABLE OF bapihuitem,
        lv_lgort          TYPE lgort_d,
        lwa_to_conf       TYPE zsits_to_conf,
        lwa_to_conf_item  TYPE zsits_to_conf_item.

  "First case: check whether carton belongs to same hierarchy as Pallet
  IF x_label_content-zzlenum IS NOT INITIAL.
    lw_hus-exidv = x_label_content-zzlenum.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lw_hus-exidv
      IMPORTING
        output = lw_hus-exidv.

    APPEND lw_hus TO lt_hus.
    IF lt_hus IS NOT INITIAL.
      CALL FUNCTION 'HU_GET_HUS'
        EXPORTING
          if_no_loop        = 'X'
          if_more_hus       = 'X'
          it_hus            = lt_hus
        IMPORTING
          et_header         = lt_header
          et_highest_levels = lt_highest_levels
          et_messages       = lt_messages
        EXCEPTIONS
          hus_locked        = 1
          no_hu_found       = 2
          fatal_error       = 3
          OTHERS            = 4.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ELSE.
        IF lt_header IS NOT INITIAL.
          CLEAR lv_venum.
          "Find VENUM for parent HU
          lv_venum = lt_highest_levels[ 1 ]-venum.
          CLEAR lw_header.
          READ TABLE lt_header INTO lw_header WITH KEY venum = lv_venum.
          IF sy-subrc = 0.
            lv_pallet = lw_header-exidv.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lv_pallet
              IMPORTING
                output = lv_pallet.

            "Now check whether parent Pallet is same as delivery pallet
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = zsits_scan_dynp-zzoutb_delivery
              IMPORTING
                output = lv_vbeln.

            SELECT lgnum tanum tapos vlenr vbeln
            FROM ltap
            INTO TABLE lt_ltap
            WHERE vbeln = lv_vbeln AND
                  lgnum = lw_header-lgnum AND
                  vlenr = lv_pallet AND
                  pquit = abap_false AND
                  nlqnr = ''.
            IF lt_ltap IS NOT INITIAL .
              READ TABLE lt_ltap INTO DATA(ls_ltap) INDEX 1.
              IF sy-subrc = 0.
                IF lv_pallet = ls_ltap-vlenr.
                  CLEAR lwa_to_conf.                    "Populate it_conf_to
                  lwa_to_conf-lgnum = lw_header-lgnum.
                  lwa_to_conf-tanum = ls_ltap-tanum.

                  CLEAR lwa_to_conf_item.
                  lwa_to_conf_item-tanum = ls_ltap-tanum.
                  lwa_to_conf_item-tapos = ls_ltap-tapos.

                  APPEND lwa_to_conf_item TO lwa_to_conf-to_conf_item.
                  APPEND lwa_to_conf TO it_to_conf.
                ELSE. "Populate error
                  c_lv_display_msg = abap_true.
                ENDIF.
              ELSE.   "Populate error
                c_lv_display_msg = abap_true.
              ENDIF.
            ELSE."Populate error
              c_lv_display_msg = abap_true.

            ENDIF.
          ELSEIF lv_venum IS INITIAL. "Isolated/ free carton case
            "Check for storage location of free carton
            ls_hu-hu_exid = x_label_content-zzlenum.
            APPEND ls_hu TO lt_hu.
            CALL FUNCTION 'BAPI_HU_GETLIST'
              TABLES
                hunumbers = lt_hu
                huitem    = lt_huitem
                return    = lt_return.

            IF lt_huitem IS NOT INITIAL.
              READ TABLE lt_huitem INTO DATA(ls_huitem) WITH KEY hu_exid = ls_hu-hu_exid.
              IF sy-subrc = 0.
                SELECT SINGLE lgort
                INTO lv_lgort
                FROM lips
                WHERE vbeln = zsits_scan_dynp-zzoutb_delivery.
                "check storage location
                IF lv_lgort = ls_huitem-stge_loc. "Populate it_conf_to
                  CLEAR lwa_to_conf.
                  lwa_to_conf-lgnum = lw_header-lgnum.
                  lwa_to_conf-tanum = ls_ltap-tanum.

                  CLEAR lwa_to_conf_item.
                  lwa_to_conf_item-tanum = ls_ltap-tanum.
                  lwa_to_conf_item-tapos = ls_ltap-tapos.

                  APPEND lwa_to_conf_item TO lwa_to_conf-to_conf_item.
                  APPEND lwa_to_conf TO it_to_conf.
                ELSE. "Populate error
                  c_lv_display_msg = abap_true.
                ENDIF.
              ENDIF.
            ELSE."Populate error
              c_lv_display_msg = abap_true.

            ENDIF.
          ELSE. "Populate error
            c_lv_display_msg = abap_true.



          ENDIF.
        ELSE.
          "Populate error
          c_lv_display_msg = abap_true.
        ENDIF.
      ENDIF.
    ELSE."Populate error
      c_lv_display_msg = abap_true.
    ENDIF.
  ELSE. "Populate error
    c_lv_display_msg = abap_true.
  ENDIF.

ENDFORM.
"End of change by Pratik EICR 603155 TR #D10K9A44XO
*&---------------------------------------------------------------------*
*&      Form  CHECK_TO_N_HU_QTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_ZLSCAN_EWMPICK_DATA_VSOLM  text
*      -->P_LS_ZLSCAN_EWMPICK_DATA_SCAN_HU  text
*      <--P_LV_QTY_FLAG  text
*----------------------------------------------------------------------*
FORM check_to_n_hu_qty  USING    uv_tanum TYPE tanum
                                 uv_tapos TYPE tapos
                                 uv_vsolm TYPE ltap_vsolm   " TO Item Qty
                                 uv_scan_hu_qty TYPE ltap_vsolm " HU scanned Qty
                        CHANGING cv_qty_flag TYPE flag.
*                                 cv_tot_qty TYPE ltap_vsolm.
  DATA: lv_tot_qty  TYPE ltap_vsolm.

  LOOP AT gt_zlscan_ewmpick_data INTO DATA(ls_ewnpick).
    IF ls_ewnpick-tanum = uv_tanum AND ls_ewnpick-tapos = uv_tapos
      AND ls_ewnpick-scan_flag = 'X'.
      lv_tot_qty = lv_tot_qty + ls_ewnpick-scan_hu_qty.
    ENDIF.
  ENDLOOP.


  " lv_tot_qty = Total scanned HU qty including the current HU qty
  lv_tot_qty = lv_tot_qty + uv_scan_hu_qty. " HU Qty sum

  IF lv_tot_qty LE uv_vsolm.
    cv_qty_flag =  abap_true.
  ELSE.
    cv_qty_flag =  abap_false.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_9001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM user_command_9001 .
  CASE sy-ucomm.

    WHEN 'CLR'.
      CLEAR: it_su, gt_zlscan_ewmpick_data , zsits_scan_dynp-zzoutb_delivery.

    WHEN 'NTRA'.
      CALL TRANSACTION 'ZMDE'.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.
"Begin of change by MMUKHERJEE EICR 603155 TR #D10K9A44XO
*&---------------------------------------------------------------------*
*&      Form  GET_HU_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_zsits_scan_dynp-zzbarcode  text
*      <--P_v_display_msg  text
*----------------------------------------------------------------------*
FORM get_hu_new USING uv_zzbarcode TYPE zd_barcode
                CHANGING cv_display_msg TYPE boolean.

  DATA: lv_count          TYPE i,
        lv_dummy          TYPE string,
        lv_barcode_string TYPE string.

  SELECT exidv
          FROM vekp
          INTO TABLE @DATA(lt_exidv)
          WHERE zzold_hu = @uv_zzbarcode.

  IF lt_exidv IS NOT INITIAL. " If barcode string is old barcode
    DESCRIBE TABLE lt_exidv LINES lv_count.
    IF lv_count = 1. " If there is only one entry, proceed with the HU.
      READ TABLE lt_exidv INTO DATA(lwa_exidv) INDEX 1.
      IF sy-subrc = 0.
        x_label_content-zzlenum = lwa_exidv-exidv.
*          *******************

        SELECT SINGLE lenum INTO @DATA(lv_lenum)
          FROM lein WHERE lenum = @x_label_content-zzlenum.

        IF sy-subrc EQ 0 .
          x_label_content-zzlenum = lv_lenum.
*                *   Get Storage Unit Data
          x_label_content-su_content = zcl_its_utility=>su_content_read( iv_su_id = lv_lenum ).
          PERFORM validate_su_label     CHANGING cv_display_msg.

        ELSE.
*        MESSAGE e158(zits) INTO lv_dummy.
          PERFORM check_pallet_carton USING x_label_content-zzlenum
                                   CHANGING gv_plt_flg.
        ENDIF.
        CLEAR: lwa_exidv, lt_exidv, lv_lenum, lv_count.
*          ******************
      ENDIF.
    ELSEIF lv_count > 1 . " “More than one HU found with the same barcode string”.

      MESSAGE e249(zlone_hu) WITH uv_zzbarcode INTO lv_dummy.
      cv_display_msg = abap_true.

    ENDIF.
  ELSE.  "Not a valid barcode string, give error message “HU XXXXX does not exist

    MESSAGE e072(zlone_hu) WITH uv_zzbarcode INTO lv_dummy.
    cv_display_msg = abap_true.

  ENDIF.

ENDFORM.
"End of change by MMUKHERJEE EICR 603155 TR #D10K9A44XO
