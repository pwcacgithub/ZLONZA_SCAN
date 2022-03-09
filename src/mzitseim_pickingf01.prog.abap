*&---------------------------------------------------------------------*
*&  Include           MZITSEIM_PICKINGF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHECK_OUTB_DELIVERY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_outb_delivery .
  DATA: lx_dlv_key        TYPE zsits_dlv_key  ##NEEDED,
        lv_lock_result    TYPE boolean,
        lv_valid          TYPE boolean,
        lwa_delivery_item TYPE zsits_dlv_item,
        lv_display_msg    TYPE boolean,
        lv_dummy          TYPE bapi_msg ##NEEDED,
        lv_vstel          TYPE vstel,
        lv_message_auth   TYPE c LENGTH 100.

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
    PERFORM auth_check CHANGING lv_display_msg lv_vstel.
    IF lv_display_msg = abap_true.
      CONCATENATE text-001 lv_vstel INTO lv_message_auth SEPARATED BY space.
      MESSAGE lv_message_auth TYPE lc_error_type.
    ELSE.

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
    CALL SCREEN 9002.
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
FORM check_label .
  DATA: lit_label_type_range TYPE ztlabel_type_range,
        lwa_read_option      TYPE zsits_batch_read_option,
        lv_display_msg       TYPE boolean,
        go_hu                TYPE REF TO zcl_rfscanner_packunpack,
        lv_flag              TYPE c,
        lv_exidv             TYPE exidv,
        lv_barcode1          TYPE string,
        lv_barcode2          TYPE string,
        ls_return            TYPE bapiret2.

  CLEAR: v_label_type,
         x_label_content,
         it_picking_item,
         v_scan_object,
         zsits_scan_dynp-zzsuccess_msg.


  CHECK zsits_scan_dynp-zzbarcode IS NOT INITIAL.
*** changing  according to new logic to get barcode read properly

* Generate label type range
  PERFORM generate_label_type_range USING    zcl_its_utility=>gc_label_fg_batch"FG Carton Label
                                    CHANGING lit_label_type_range.
  PERFORM generate_label_type_range USING    zcl_its_utility=>gc_label_hu      "Pallet Label
                                    CHANGING lit_label_type_range.

  GET PARAMETER ID 'ZGELATIN' FIELD lv_flag.

  IF lv_flag <> abap_true.
*--Read the HU number enter one is with Prefix or not
*--If not prefix of HU number then add Prefix with below code
*--Create Class Object for validation
    CREATE OBJECT go_hu.
    CALL METHOD go_hu->hubarcode_value
      EXPORTING
        iv_exidv    = zsits_scan_dynp-zzbarcode
      IMPORTING
        ev_hunumber = zsits_scan_dynp-zzbarcode.

* Barcode read
    lwa_read_option-zzstock_read = abap_true."batch data read

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

  ELSE.

    lv_barcode1 = zsits_scan_dynp-zzbarcode.
    CALL FUNCTION 'ZWM_HU_VALIDATE'
      EXPORTING
        iv_barcode          = lv_barcode1
        it_label_type_range = lit_label_type_range
      IMPORTING
        ev_exidv            = lv_exidv
        es_return           = ls_return
        ev_barcode          = lv_barcode2
        es_label_content    = x_label_content.

    zsits_scan_dynp-zzbarcode = lv_barcode2.
    v_label_type = x_label_content-zzlabel_type.
    CLEAR lv_flag.

  ENDIF.
* Generate label type range
*  lwa_read_option-zzstock_read = abap_true."batch data read

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
*&      Form  GENERATE_LABEL_TYPE_RANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZCL_ITS_UTILITY=>GC_LABEL_FG_B  text
*      <--P_LIT_LABEL_TYPE_RANGE  text
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

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPDATE_PICKING_QTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_picking_qty .
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
*&      Form  UPDATE_PICKED_QTY_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_picked_qty_table .
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
*&      Form  FRM_CLEAR_VARIABLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_clear_variables .
  CLEAR: zsits_scan_dynp-zzbarcode,
           it_hu_1,
           it_picking_item,
           v_label_type,
           v_scan_object,
           x_label_content.
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
        lv_flag_pal         TYPE c VALUE ' ',
        lv_count            TYPE c VALUE ' '.


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

      IF flag_pal = 'X'..
        CONTINUE.
      ELSE.
*     Pallet &1 not allowed to pick!
        MESSAGE e138(zits) WITH x_label_content-zzhu_exid INTO lv_dummy.
        cv_display_msg = abap_true.
        EXIT.
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
    PERFORM check_hu USING lwa_hu_item-hu_exid CHANGING lv_flag_pal. "

    lwa_picking_item-vbeln_vl = lwa_delivery_item-vbeln.
    lwa_picking_item-posnr_vl = lwa_delivery_item-posnr.
    lwa_picking_item-vbeln    = lwa_delivery_item-vbeln.
    lwa_picking_item-posnn    = lwa_delivery_item-posnr.
    lwa_picking_item-lgmng    = lv_picking_qty.
    lwa_picking_item-lgort    = lwa_delivery_item-lgort.
    lwa_picking_item-meins    = lwa_delivery_item-meins.
    IF flag_pal EQ 'X'. "pallet
      COLLECT lwa_picking_item INTO it_picking_item.
    ELSE. "Carton
      APPEND lwa_picking_item TO it_picking_item.
    ENDIF.
    CLEAR lwa_hu_1.

    IF lv_flag_pal EQ 'X'.
      lwa_hu_1-top_hu_internal = x_label_content-hu_content-hu_header-hu_id.
      lwa_hu_1-venum           = x_label_content-hu_content-hu_header-hu_id.
      lwa_hu_1-vepos           = lwa_hu_item-hu_item_number.
    ELSE.
      CLEAR lv_venum.
      PERFORM get_venum USING lwa_hu_item-hu_exid CHANGING lv_venum.
      lwa_hu_1-top_hu_internal = x_label_content-hu_content-hu_header-hu_id.
      lwa_hu_1-venum           = lv_venum.
      lwa_hu_1-vepos           = lwa_hu_item-hu_item_number.
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
*                            zsits_scan_dynp-zzoutb_delivery
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
*&      Form  CHECK_HU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_X_LABEL_CONTENT_ZZHU_EXID  text
*----------------------------------------------------------------------*
FORM check_hu  USING    exid TYPE exidv CHANGING flag_pal  TYPE c.
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
    flag_pal = 'X'.
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
FORM get_venum  USING    uhu_exid TYPE exidv
                CHANGING uv_venum TYPE venum.
  DATA : lv_venum TYPE venum.
  SELECT SINGLE venum FROM vekp
    INTO lv_venum
    WHERE exidv = uhu_exid.
  IF sy-subrc = 0.
    uv_venum = lv_venum.
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
    WHEN gc_clear . "Clears the HU number on the screen
      CLEAR : zsits_scan_dynp-zzoutb_delivery , zsits_scan_dynp-zzbarcode.
    WHEN 'NTRA'.
      CALL TRANSACTION 'ZMDE'.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM auth_check CHANGING lv_message TYPE boolean
                lv_vstel TYPE vstel.
  DATA:lv_vbeln        TYPE vbeln_vl,

       lv_message_auth TYPE c LENGTH 100,
       lc_e            TYPE c VALUE 'E'.
  IF zsits_scan_dynp-zzoutb_delivery IS NOT INITIAL.

    lv_vbeln = zsits_scan_dynp-zzoutb_delivery.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_vbeln
      IMPORTING
        output = lv_vbeln.



    SELECT SINGLE vstel
    FROM likp
    INTO lv_vstel
    WHERE vbeln = lv_vbeln.
    IF sy-subrc = 0.
      AUTHORITY-CHECK OBJECT 'V_LIKP_VST'
           ID 'VSTEL' FIELD lv_vstel
           ID 'ACTVT' FIELD '02'.
      IF sy-subrc = 0. "02 is passsed
        AUTHORITY-CHECK OBJECT 'V_LIKP_VST'
        ID 'VSTEL' FIELD lv_vstel
        ID 'ACTVT' FIELD '03'.
        IF sy-subrc <> 0.
          lv_message = abap_true.

        ENDIF.
      ELSE. "02 is failed

        lv_message = abap_true.
      ENDIF.
    ENDIF.

  ENDIF.
ENDFORM.
