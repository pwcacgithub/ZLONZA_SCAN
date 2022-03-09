*----------------------------------------------------------------------*
***INCLUDE MZLS_HUTRANSFERF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHECK_OUTB_DELIVERY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_OUTB_DELIVERY .
  DATA: lx_dlv_key        TYPE zsits_dlv_key  ##NEEDED,
        lv_lock_result    TYPE boolean,
        lv_valid          TYPE boolean,
        lwa_delivery_item TYPE zsits_dlv_item,
        lv_display_msg    TYPE boolean,
        lv_dummy          TYPE bapi_msg ##NEEDED.

  CLEAR: x_delivery_header,
         it_delivery_pick,
         it_delivery_item,
         it_picking_item,
         v_scan_object,
         zsits_scan_dynp-zzsuccess_msg,
         lv_valid,
         lv_lock_result,
         lwa_delivery_item.

  CHECK zsits_scan_dynp-zzoutb_delivery IS NOT INITIAL.

* Outbound delivery validation
  CALL METHOD zcl_its_utility=>outb_delivery_validate
    EXPORTING
      is_scan_dynp = zsits_scan_dynp
    RECEIVING
      rv_result    = lv_valid.

  IF lv_valid = abap_true.
*   Lock delivery
    CALL METHOD zcl_its_utility=>delivery_lock
      EXPORTING
        iv_delivery = zsits_scan_dynp-zzoutb_delivery
      RECEIVING
        rv_result   = lv_lock_result.

    IF lv_lock_result = abap_true.
*     Get Delivery data
      CALL METHOD zcl_its_utility=>delivery_read
        EXPORTING
          iv_delivery        = zsits_scan_dynp-zzoutb_delivery
          iv_pick_get        = abap_true
        IMPORTING
          es_delivery_header = x_delivery_header
          et_picking_qty     = it_delivery_pick
          et_delivery_item   = it_delivery_item.

      SORT it_delivery_item BY matnr charg.
      SORT it_delivery_pick BY vbelv posnv vbeln posnn.
**Authority Check for Warehouse number Starts
      LOOP AT IT_DELIVERY_PICK INTO DATA(LS_PICK) WHERE LGNUM IS NOT INITIAL.
        AUTHORITY-CHECK OBJECT 'L_LGNUM'
                 ID 'LGNUM' FIELD LS_PICK-LGNUM
                 ID 'LGTYP' DUMMY.
        IF SY-SUBRC <> 0.
          MESSAGE e058(zlone_hu) WITH LS_PICK-LGNUM INTO lv_dummy.
        ENDIF.
        CLEAR: LV_DUMMY, LS_PICK.
      ENDLOOP.
**Authority Check for Warehouse number Ends

      IF it_delivery_item IS INITIAL.
*       Delivery &1 has no item to pick.
        MESSAGE e274(zits) WITH zsits_scan_dynp-zzoutb_delivery INTO lv_dummy.
        lv_display_msg = abap_true.
      ELSE.
* getting plants from table ZVV_PARAM entry

        SELECT SINGLE value1 FROM zvv_param INTO lv_param  WHERE lookup_name = lv_lookup_plant ##WARN_OK.
        IF sy-subrc = 0.
          IF NOT lv_param IS INITIAL.
            SPLIT lv_param AT ',' INTO TABLE lit_plant.
            LOOP AT lit_plant INTO lwa_plant.
              lr_werks-sign = 'I'.
              lr_werks-option = 'EQ'.
              lr_werks-low = lwa_plant-werks.
              APPEND lr_werks TO lit_plant_val.
              CLEAR lr_werks.
            ENDLOOP.
          ENDIF.
        ENDIF.

        READ TABLE it_delivery_item INTO lwa_delivery_item INDEX 1.
        IF sy-subrc = 0.

* checking the plant against the ZVV_PARAM entry
          IF lwa_delivery_item-werks NOT IN lit_plant_val OR lwa_delivery_item-werks IS INITIAL.
*           Please check plant in your delivery
            MESSAGE e511(zits) INTO lv_dummy.
            lv_display_msg = abap_true.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
*     Lock error
      lv_display_msg = abap_true.
    ENDIF.
  ELSE.
*   Error Scenario 1: Delivery &1 does not exist in the database or in the archive
*   Error Scenario 2: Document &1 is not an outbound delivery !
*   Error Scenario 3: O/B delivery &1 already picked
*   Error Scenario 4: PGI of delivery &1 has been completed
    lv_display_msg = abap_true.
  ENDIF.

  PERFORM add_message USING zcl_its_utility=>gc_objid_delivery "Object ID = 'Delivery'
                             zsits_scan_dynp-zzoutb_delivery
                             lv_display_msg
                             lv_display_msg.
  IF lv_display_msg = abap_true.
    CLEAR zsits_scan_dynp-zzoutb_delivery.
  ELSE.
    CALL SCREEN 9001.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZCL_ITS_UTILITY=>GC_OBJID_DELI  text
*      -->P_ZSITS_SCAN_DYNP_ZZOUTB_DELIVER  text
*      -->P_LV_DISPLAY_MSG  text
*      -->P_LV_DISPLAY_MSG  text
*----------------------------------------------------------------------*
FORM add_message  USING    uv_object_id    TYPE zzscan_objid
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

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_LABEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_LABEL .
  DATA: lit_label_type_range TYPE ztlabel_type_range,
        lwa_read_option      TYPE zsits_batch_read_option,
        lv_display_msg       TYPE boolean,
        LV_FLAG              TYPE C,
        lv_exidv             TYPE exidv,
        lv_barcode1          TYPE string,
        lv_barcode2          TYPE string,
        ls_return            TYPE bapiret2.

  CLEAR: v_label_type,
         x_label_content,
         it_picking_item,
         v_scan_object,
         zsits_scan_dynp-zzsuccess_msg,
         lv_flag.

  CHECK zsits_scan_dynp-zzbarcode IS NOT INITIAL.
* Generate label type range
  PERFORM generate_label_type_range USING    zcl_its_utility=>gc_label_fg_batch"FG Carton Label
                                    CHANGING lit_label_type_range.
  PERFORM generate_label_type_range USING    zcl_its_utility=>gc_label_hu      "Pallet Label
                                    CHANGING lit_label_type_range.
  GET PARAMETER ID 'ZGELATIN' FIELD LV_FLAG.

  IF LV_FLAG <> ABAP_TRUE.
*BEGIN: Scan Global Change
*--Read the HU number enter one is with Prefix or not
*--If not prefix of HU number then add Prefix with below code
*--Create Class Object for validation
    CREATE OBJECT go_bc.
    CALL METHOD go_bc->hubarcode_value
      EXPORTING
        iv_exidv    = zsits_scan_dynp-zzbarcode
      IMPORTING
        ev_hunumber = zsits_scan_dynp-zzbarcode.


*END: Scan Global Change

* Barcode read
    lwa_read_option-zzstock_read = abap_true."batch data read
*BEGIN: EICR:603155 - Project ONE: HC & DFS Implementation US & MX May 1st 2020 ****

    lv_barcode = zsits_scan_dynp-zzbarcode(100).
    CALL METHOD zcl_its_utility=>barcode_read_dfs_2
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
  else.
    LV_BARCODE1 = zsits_scan_dynp-zzbarcode.
    CALL FUNCTION 'ZWM_HU_VALIDATE'
      EXPORTING
        IV_BARCODE          = LV_BARCODE1
        IT_LABEL_TYPE_RANGE = lit_label_type_range
      IMPORTING
        EV_EXIDV            = LV_EXIDV
        ES_RETURN           = LS_RETURN
        EV_BARCODE          = LV_BARCODE2
        ES_LABEL_CONTENT    = x_label_content.
    zsits_scan_dynp-zzbarcode = lv_barcode2.
    v_label_type = x_label_content-ZZLABEL_TYPE.
    CLEAR lv_flag.
  endif.
***  END: EICR:603155 - Project ONE: HC & DFS Implementation US & MX May 1st 2020 ****
  IF v_label_type IS NOT INITIAL.
    CASE v_label_type.
      WHEN zcl_its_utility=>gc_label_hu.      "Pallet Label
        PERFORM validate_pallet_label CHANGING lv_display_msg.
      WHEN zcl_its_utility=>gc_label_fg_batch."FG Carton Label
        PERFORM validate_fg_batch     CHANGING lv_display_msg.
      WHEN OTHERS.
    ENDCASE.
  ELSE.
*   Error Scenario 1: Error in barcode translation
*   Error Scenario 2: Label type is not allowed by this transaction
*   Error Scenario 3: Required handling units could not be found.
*   Error Scenario 4: Not a FG batch
    lv_display_msg = abap_true.
  ENDIF.

  PERFORM add_message USING zcl_its_utility=>gc_objid_label "Object ID = 'Label'
                            zsits_scan_dynp-zzbarcode
                            lv_display_msg
                            lv_display_msg.

  IF lv_display_msg = abap_true.
    PERFORM frm_clear_variables.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPDATE_PICKING_QTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_PICKING_QTY .
  DATA: lx_vbkok        TYPE vbkok,
        lwa_picking_log TYPE prott,
        lit_picked_list TYPE STANDARD TABLE OF vbfa,
        lit_picking_log TYPE STANDARD TABLE OF prott.

  DATA: lv_dummy        TYPE bapi_msg ##NEEDED,
        lv_display_msg  TYPE boolean,
        lv_picked_items TYPE i,
        lv_total_items  TYPE i.

  CLEAR: lx_vbkok, lwa_picking_log.

  CHECK zsits_scan_dynp-zzbarcode IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = zsits_scan_dynp-zzoutb_delivery
    IMPORTING
      output = lx_vbkok-vbeln_vl.

* Update picking
  CALL FUNCTION 'WS_DELIVERY_UPDATE'
    EXPORTING
      vbkok_wa          = lx_vbkok
      delivery          = lx_vbkok-vbeln_vl
      update_picking    = abap_true
    TABLES
      vbpok_tab         = it_picking_item
      prot              = lit_picking_log
      it_handling_units = it_hu_1
    EXCEPTIONS
      error_message     = 1.

  IF sy-subrc <> 0.
    MESSAGE ID     sy-msgid
            TYPE   sy-msgty
            NUMBER sy-msgno
            INTO   lv_dummy
            WITH   sy-msgv1
                   sy-msgv2
                   sy-msgv3
                   sy-msgv4.

    lv_display_msg = abap_true.
  ELSE.
*

    READ TABLE lit_picking_log INTO lwa_picking_log WITH KEY msgty = lc_error_type.
    IF sy-subrc = 0.
*     Update failed
      MESSAGE ID     lwa_picking_log-msgid
              TYPE   lwa_picking_log-msgty
              NUMBER lwa_picking_log-msgno
              INTO   lv_dummy
              WITH   lwa_picking_log-msgv1
                     lwa_picking_log-msgv2
                     lwa_picking_log-msgv3
                     lwa_picking_log-msgv4.

      lv_display_msg = abap_true.
    ELSE.
      COMMIT WORK AND WAIT.

      CALL METHOD zcl_its_utility=>delivery_lock
        EXPORTING
          iv_delivery = zsits_scan_dynp-zzoutb_delivery.
*     Count total # of items on delivery
      DESCRIBE TABLE it_delivery_item LINES lv_total_items.

      PERFORM update_picked_qty_table.
*     Count # of items that's already picked
      lit_picked_list = it_delivery_pick.
      SORT lit_picked_list BY vbelv posnv.
      DELETE ADJACENT DUPLICATES FROM lit_picked_list COMPARING vbelv posnv.
      DESCRIBE TABLE lit_picked_list LINES lv_picked_items.

*     Success
      MESSAGE s267(zits) WITH v_scan_object lv_picked_items lv_total_items INTO zsits_scan_dynp-zzsuccess_msg."&1 Picked!
    ENDIF.
  ENDIF.

  PERFORM add_message USING zcl_its_utility=>gc_objid_label "Object ID = 'Label'
                            zsits_scan_dynp-zzbarcode
                            abap_true
                            lv_display_msg.
  PERFORM frm_clear_variables.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_CLEAR_VARIABLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FRM_CLEAR_VARIABLES .
  CLEAR: zsits_scan_dynp-zzbarcode,
           it_hu_1,
           it_picking_item,
           v_label_type,
           v_scan_object,
           x_label_content.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GENERATE_LABEL_TYPE_RANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZCL_ITS_UTILITY=>GC_LABEL_FG_B  text
*      <--P_LIT_LABEL_TYPE_RANGE  text
*----------------------------------------------------------------------*
FORM GENERATE_LABEL_TYPE_RANGE  USING    iv_label_type       TYPE zdits_label_type
                                CHANGING ct_label_type_range TYPE ztlabel_type_range.
  DATA: lwa_label_type_range TYPE zslabel_type_range.

  CONSTANTS: lc_sign_i       TYPE c VALUE 'I',
             lc_option_eq(2) TYPE c VALUE 'EQ'.

  CLEAR lwa_label_type_range.
  lwa_label_type_range-sign   = lc_sign_i.
  lwa_label_type_range-zoption = lc_option_eq.
  lwa_label_type_range-low    = iv_label_type.
  APPEND lwa_label_type_range TO ct_label_type_range.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPDATE_PICKED_QTY_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_PICKED_QTY_TABLE .
  DATA: lwa_picking_item TYPE vbpok.

  FIELD-SYMBOLS: <fs_delivery_pick> TYPE vbfa.
  CLEAR : lwa_picking_item.
  LOOP AT it_picking_item INTO lwa_picking_item.
    READ TABLE it_delivery_pick ASSIGNING <fs_delivery_pick>
                                WITH KEY vbelv = lwa_picking_item-vbeln_vl
                                         posnv = lwa_picking_item-posnr_vl
                                         vbeln = lwa_picking_item-vbeln
                                         posnn = lwa_picking_item-posnn
                                BINARY SEARCH.
    IF sy-subrc = 0.
      <fs_delivery_pick>-rfmng = lwa_picking_item-lgmng.
    ELSE.
      APPEND INITIAL LINE TO it_delivery_pick ASSIGNING <fs_delivery_pick>.
      <fs_delivery_pick>-vbelv = lwa_picking_item-vbeln_vl.
      <fs_delivery_pick>-posnv = lwa_picking_item-posnr_vl.
      <fs_delivery_pick>-vbeln = lwa_picking_item-vbeln.
      <fs_delivery_pick>-posnn = lwa_picking_item-posnn.
      <fs_delivery_pick>-rfmng = lwa_picking_item-lgmng.
      <fs_delivery_pick>-meins = lwa_picking_item-meins.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  VALIDATE_PALLET_LABEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_DISPLAY_MSG  text
*----------------------------------------------------------------------*
FORM validate_pallet_label  CHANGING cv_display_msg TYPE boolean.

  DATA: lwa_hu_item         TYPE bapihuitem,
        lwa_content         TYPE bapihuitem,
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
        lx_batch_data       TYPE zsits_batch_data,
        lv_venum            TYPE venum,
        lv_flag_pal         TYPE c VALUE ' '.


** checking if HU or Pallet
  PERFORM check_hu USING x_label_content-zzhu_exid CHANGING flag_pal. "flag_hu_carton
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

      IF flag_pal = gc_x. "'X'.
        CONTINUE.
      ELSE.
        CONTINUE.
      ENDIF.
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
    IF flag_pal = ABAP_TRUE.
      COLLECT lwa_picking_item INTO it_picking_item.
    ELSE.
      APPEND lwa_picking_item TO it_picking_item.
    ENDIF.

    CLEAR lwa_hu_1.
    PERFORM check_hu USING lwa_hu_item-hu_exid CHANGING lv_flag_pal. "

    IF lv_flag_pal EQ gc_x.
      lwa_hu_1-top_hu_internal = x_label_content-hu_content-hu_header-hu_id.
      lwa_hu_1-venum           = x_label_content-hu_content-hu_header-hu_id.
      lwa_hu_1-vepos           = lwa_hu_item-hu_item_number.
    ELSE.
      CLEAR lv_venum.
      PERFORM get_venum USING lwa_hu_item-hu_exid CHANGING lv_venum.
      lwa_hu_1-top_hu_internal = x_label_content-hu_content-hu_header-hu_id.
      lwa_hu_1-venum           = lv_venum.
      lwa_hu_1-vepos           = lwa_hu_item-hu_item_number.
      IF FLAG_PAL NE GC_X. " Not a Pallet only then Unpack
        PERFORM UNPACK_SU USING lwa_hu_item-hu_exid. " Unpack if the Carton is packed in a Pallet
      ENDIF.
    ENDIF.

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
*&      Form  VALIDATE_FG_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_DISPLAY_MSG  text
*----------------------------------------------------------------------*
FORM validate_fg_batch  CHANGING cv_display_msg TYPE boolean.
  DATA: lwa_delivery_item TYPE zsits_dlv_item,
        lwa_delivery_pick TYPE vbfa,
        lwa_picking_item  TYPE vbpok,
        lv_picked_qty     TYPE vbfa-rfmng,
        lv_pick_qty_max   TYPE vbfa-rfmng,
        lv_picking_qty    TYPE vbfa-rfmng,
        lv_dummy          TYPE bapi_msg ##NEEDED.

  DATA: lv_allowed_to_ship TYPE xfeld ##NEEDED.

  cv_display_msg = abap_true.

* Check if FG batch is involved in delivery
*----------------------------------------------------------------------
  SORT it_delivery_item BY matnr charg.
  CLEAR : lwa_delivery_item.
  READ TABLE it_delivery_item INTO     lwa_delivery_item
                              WITH KEY matnr = x_label_content-batch_data-matnr
                                       charg = x_label_content-batch_data-charg
                              BINARY SEARCH.
  IF sy-subrc NE 0.
*   FG batch &1 not allowed to pick !
    MESSAGE e146(zits) WITH x_label_content-zzbatch
                       INTO lv_dummy.

    RETURN.
  ENDIF.

* Check IM/batch/QI lot status
*----------------------------------------------------------------------
  IF zcl_its_utility=>is_batch_allowed_for_ship_hu(  iv_werks      = lwa_delivery_item-werks
                                                     iv_lgort      = lwa_delivery_item-lgort
                                                     is_delivery   = x_delivery_header
                                                     is_batch_data = x_label_content-batch_data ) = abap_false.
*   Batch &1 has IM/batch/QI lot status that's not allowed for picking
    RETURN.
  ENDIF.

* Check if overpicked
*----------------------------------------------------------------------
  CLEAR : lv_picked_qty, lwa_delivery_pick.
  LOOP AT it_delivery_pick INTO lwa_delivery_pick WHERE vbelv = lwa_delivery_item-vbeln
                                                    AND posnv = lwa_delivery_item-posnr.
    lv_picked_qty = lv_picked_qty + lwa_delivery_pick-rfmng.
  ENDLOOP.

  lv_pick_qty_max = lwa_delivery_item-lgmng - lv_picked_qty.

  IF x_label_content-zzquantity > lv_pick_qty_max.
*   FG batch &1 over picked !
    MESSAGE e147(zits) WITH x_label_content-zzbatch INTO lv_dummy.
    RETURN.
  ENDIF.

* Generate pick data
*----------------------------------------------------------------------
  CLEAR: lwa_delivery_pick.
  READ TABLE it_delivery_pick INTO     lwa_delivery_pick
                              WITH KEY vbelv = lwa_delivery_item-vbeln
                                       posnv = lwa_delivery_item-posnr
                                       vbeln = lwa_delivery_item-vbeln
                                       posnn = lwa_delivery_item-posnr
                              BINARY SEARCH.
  IF sy-subrc = 0.
    lv_picking_qty = x_label_content-zzquantity + lwa_delivery_pick-rfmng.
  ELSE.
    lv_picking_qty = x_label_content-zzquantity.
  ENDIF.

  CLEAR lwa_picking_item.
  lwa_picking_item-vbeln_vl = lwa_delivery_item-vbeln.
  lwa_picking_item-posnr_vl = lwa_delivery_item-posnr.
  lwa_picking_item-vbeln    = lwa_delivery_item-vbeln.
  lwa_picking_item-posnn    = lwa_delivery_item-posnr.
  lwa_picking_item-lgmng    = lv_picking_qty.
  lwa_picking_item-meins    = lwa_delivery_item-meins.
  APPEND lwa_picking_item TO it_picking_item.

  cv_display_msg = abap_false.

  v_scan_object = x_label_content-batch_data-charg.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CONVERT_REMOVEZEROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_HU_VBELN  text
*      <--P_LV_MSGV1  text
*----------------------------------------------------------------------*
FORM CONVERT_REMOVEZEROS  USING    p_gs_hu_vbeln TYPE vbeln
                          CHANGING p_lv_msgv1.
*--convert : remove leading zero's
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = p_gs_hu_vbeln
    IMPORTING
      output = p_lv_msgv1.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ERROR_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GC_MSGID  text
*      -->P_LC_MSGNO1  text
*      -->P_LV_MSGV1  text
*----------------------------------------------------------------------*
FORM ERROR_MESSAGE  USING  p_gc_msgid TYPE msgid
                           p_lv_msgno TYPE msgno
                           p_gv_msgv1 TYPE msgv1.
  DATA      : lv_prevno TYPE sy-dynnr,
              lv_msgid  TYPE msgid.

  CONSTANTS : lc_msgno1  TYPE msgno  VALUE '029',
              lc_msgno2  TYPE msgno  VALUE '030',
              lc_msgno3  TYPE msgno  VALUE '023',
              lc_initial TYPE char1 VALUE '0'.

*--Call error message screen with message
*--Set Message id
  SET PARAMETER ID text-001 FIELD p_gc_msgid.
*--Set Message No
  SET PARAMETER ID text-002 FIELD p_lv_msgno.
*--Set Message variable
  SET PARAMETER ID text-003 FIELD p_gv_msgv1.
*--Set Message for screen number call back
  CLEAR : lv_prevno.
  lv_prevno = sy-dynnr.
*--Change if the successful message go back to initial screen
  IF p_lv_msgno = lc_msgno1.
    lv_prevno = lc_initial.
  ENDIF.

  SET PARAMETER ID text-004 FIELD lv_prevno.

*--Call Display message screen
  CALL SCREEN 9003.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VALIDATIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDATIONS .

  DATA: lv_msgv1    TYPE msgv1,
        lv_msgno    TYPE msgno,
        lv_return   TYPE bapiret2,
        lv_msgid    TYPE msgid,
        lv_invalide TYPE boolean.

  CONSTANTS:lc_msgno1 TYPE msgno VALUE '026',
            lc_msgno2 TYPE msgno VALUE '027',
            lc_msgno3 TYPE msgno VALUE '028'.

  IF go_hu IS NOT BOUND.
    CREATE OBJECT go_hu
      EXPORTING
        iv_vbeln = zsits_scan_dynp-zzoutb_delivery. "gs_hu-vbeln.
  ENDIF.
* validate delivery entered
  CALL METHOD go_hu->validate_delivery
    IMPORTING
      ev_return   = lv_return
    RECEIVING
      ev_invalide = lv_invalide.
  IF lv_invalide = abap_true OR lv_return IS NOT INITIAL.
    gv_error1 = abap_true.
* Validate for custom table entries.
  ELSEIF go_hu->check_zlpostgoods( ) EQ abap_true.
    gv_error2 = abap_true.
* Check for Picking complete
  ELSEIF go_hu->check_picking( ) EQ abap_false.
    IF go_hu->check_wm_relevant( ) EQ abap_true.
      gv_error3 = abap_true.
    ENDIF.
  ENDIF.
* display error.
  IF gv_error1 IS NOT INITIAL.
    CLEAR : lv_msgv1.
    lv_msgv1 = zsits_scan_dynp-zzoutb_delivery. " gs_hu-vbeln.
    lv_msgno = lc_msgno1.
    IF lv_return IS NOT INITIAL.
*--Show an error message
      lv_msgno = lv_return-number.
      lv_msgv1 = lv_return-message_v1.
      lv_msgid = lv_return-id.
      PERFORM error_message USING  lv_msgid lv_msgno lv_msgv1.
    ELSE.
*--Show an error message
      PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1.
    ENDIF.

  ELSEIF gv_error2 IS NOT INITIAL.
    CLEAR : lv_msgv1.
    lv_msgv1 = zsits_scan_dynp-zzoutb_delivery. "gs_hu-vbeln.
    lv_msgno = lc_msgno2.
*--Show an error message
    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1.
  ELSEIF gv_error3 IS NOT INITIAL.
    CLEAR : lv_msgv1.
    lv_msgv1 = zsits_scan_dynp-zzoutb_delivery. " gs_hu-vbeln.
    lv_msgno = lc_msgno3.
*--Show an error message
    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1.
  ELSE.
    gv_noerror = abap_true.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  POST_GR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM POST_GR .

***Create PGR
  DATA: lv_vbkok     TYPE vbkok,
        lv_pgr_error TYPE xfeld,
        lt_messages  TYPE TABLE OF prott,
        lv_msgid     TYPE symsgid,
        lv_msgnumb   TYPE symsgno,
        lv_msgv1     TYPE bapiret2-message_v1,
        lv_msgv2     TYPE bapiret2-message_v2,
        lv_msgv3     TYPE bapiret2-message_v3,
        lv_msgv4     TYPE bapiret2-message_v4,
        ev_mesg      TYPE bapiret2-message.


  CONSTANTS: lc_textformat TYPE bapi_tfrmt VALUE 'NON',
             lc_lang       TYPE spras VALUE 'E',
             gc_msgno      TYPE msgno VALUE '137'.
  CLEAR: lv_vbkok.

  lv_vbkok-vbeln_vl = gv_ibd. " gs_hu-vbeln.
  lv_vbkok-wabuc = abap_true.
  lv_vbkok-wadat_ist = sy-datum.
  lv_vbkok-spe_auto_gr = gc_x. " abap_true. " 'X'.
* FM to create PGR

  CALL FUNCTION 'WS_DELIVERY_UPDATE_2'
    EXPORTING
      vbkok_wa               = lv_vbkok
      synchron               = abap_true
      commit                 = abap_true
      delivery               = gv_ibd "gs_hu-vbeln
      update_picking         = abap_true
      nicht_sperren_1        = abap_true
      if_error_messages_send = space
    IMPORTING
      ef_error_any           = lv_pgr_error
    TABLES
      prot                   = lt_messages.


* if any error then get the error message
  IF lv_pgr_error IS NOT INITIAL.
    READ TABLE lt_messages INTO DATA(lv_msg) WITH KEY vbeln = gv_ibd. "gs_hu-vbeln.
    IF sy-subrc IS INITIAL.
      lv_msgid = lv_msg-msgid.
      lv_msgnumb = lv_msg-msgno.
      lv_msgv1 = lv_msg-msgv1.
      lv_msgv2 = lv_msg-msgv2.
      lv_msgv3 = lv_msg-msgv3.
      lv_msgv4 = lv_msg-msgv4.
      CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
        EXPORTING
          id         = lv_msgid
          number     = lv_msgnumb
          textformat = lc_textformat
          message_v1 = lv_msgv1
          message_v2 = lv_msgv2
          message_v3 = lv_msgv3
          message_v4 = lv_msgv4
        IMPORTING
          message    = ev_mesg.

      lv_msgno = lv_msgnumb.
      PERFORM error_message USING lv_msgid lv_msgno lv_msgv1.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
*--Get the message from message id
      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          id        = sy-msgid
          lang      = lc_lang
          no        = sy-msgno
        IMPORTING
          msg       = ev_mesg
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc IS NOT INITIAL.
*         do nothing
      ENDIF.

      lv_msgno = sy-msgno.
      lv_msgid = sy-msgid.
      PERFORM error_message USING lv_msgid lv_msgno lv_msgv1.
    ENDIF.
  ELSE.

    lv_msgno = gc_msgno.
*--Remove leading zeros of delivery
    PERFORM convert_removezeros USING  gv_ibd "gs_hu-vbeln
                                CHANGING lv_msgv1.
*--Show an Successful message with Delivery number

    PERFORM error_message USING gc_msgid lv_msgno lv_msgv1.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = gc_x.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_HU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_X_LABEL_CONTENT_ZZHU_EXID  text
*      <--P_FLAG_PAL  text
*----------------------------------------------------------------------*
FORM CHECK_HU  USING    exid TYPE exidv CHANGING flag_pal  TYPE c.
  DATA : lv_uevel TYPE uevel.

  SELECT SINGLE uevel "UEVEL higher level HU
        FROM vekp
        INTO lv_uevel
        WHERE exidv =  exid.
  IF sy-subrc = 0 AND lv_uevel IS NOT INITIAL.  "it means its a carton HU
*Prepare the external HU id for BAPI-call* SINGLE CARTON HU
    flag_pal = ' '.

  ELSE.  "empty means a pallet HU
*Prepare the external HU id for BAPI-call* For all the cartons and pallet as well.
    flag_pal = gc_x. " 'X'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_VENUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LWA_HU_ITEM_HU_EXID  text
*      <--P_LV_VENUM  text
*----------------------------------------------------------------------*
FORM GET_VENUM  USING    uhu_exid TYPE exidv
                CHANGING uv_venum TYPE venum.
  DATA : lv_venum TYPE venum.
  SELECT SINGLE venum FROM vekp
    INTO lv_venum
    WHERE exidv = uhu_exid.
  IF sy-subrc = 0.
    uv_venum = lv_venum.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROG DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROG.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = gc_x. " 'X'.
  APPEND BDCDATA.
ENDFORM.

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  IF FVAL IS NOT INITIAL.
    CLEAR BDCDATA.
    BDCDATA-FNAM = FNAM.
    BDCDATA-FVAL = FVAL.
    APPEND BDCDATA.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UNPACK_SU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UNPACK_SU using lv_carton.
  DATA:   ls_header  TYPE bapihuheader,
          lv_headehu TYPE exidv,
          lv_msgv1   TYPE msgv1,
          lv_flagset TYPE char1,
          ls_lhu     TYPE bapihuitmunpack,
          lt_return  TYPE TABLE OF bapiret2,
          ls_barcode TYPE exidv.
  CONSTANTS: lc_itemtype TYPE velin VALUE '3',
             lc_s        TYPE char1 VALUE 'S',
             lc_flag     TYPE char1  VALUE 'X'.

  ls_barcode = lv_carton.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = ls_barcode
    IMPORTING
      output = ls_barcode.

  SELECT SINGLE UEVEL FROM VEKP INTO @DATA(L_UEVEL) WHERE EXIDV = @ls_barcode.
  IF NOT L_UEVEL IS INITIAL. "Carton is packed, proceed to Unpack
    ls_lhu-hu_item_type = lc_itemtype.
    SELECT SINGLE EXIDV FROM VEKP INTO LV_HEADEHU WHERE VENUM = l_uevel.
    IF SY-SUBRC = 0.
      LS_LHU-UNPACK_EXID = ls_barcode.
      CALL FUNCTION 'BAPI_HU_UNPACK'
        EXPORTING
          hukey      = lv_headehu
          itemunpack = ls_lhu
        IMPORTING
          huheader   = ls_header
        TABLES
          return     = lt_return.
      IF lt_return[] IS NOT INITIAL.
        READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<ls_log>)
                              WITH KEY type = lc_s.
        IF sy-subrc EQ 0.
*Commit if successfully unpacked
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = lc_flag.
          CLEAR : lt_return, ls_header, lv_flagset, lv_headehu.
        ELSE.
          lv_flagset = lc_flag.
        ENDIF.
      ELSE.
        IF lt_return IS INITIAL AND ls_header IS NOT INITIAL.
*Commit if successfully unpacked
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = lc_flag.
          CLEAR : lt_return, ls_header, lv_flagset,lv_headehu.
        ELSE.
          lv_flagset = lc_flag.
          lv_msgv1 = ls_header-hu_exid.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
