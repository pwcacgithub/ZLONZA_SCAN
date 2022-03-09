*&---------------------------------------------------------------------*
*&  Include           MZITSEBREAK_PALLETF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BREAK_PALLET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM break_pallet .
  DATA: lv_dummy         TYPE bapi_msg,
        lv_result        TYPE boolean,
        lv_batch         TYPE zzbatch,
        lv_label_type    TYPE zdits_label_type,
        ls_label_content TYPE zsits_label_content,
        ls_batch_data    TYPE zsits_batch_data,
        ls_batch_key     TYPE zsits_batch_key,
        lwa_hu_header    TYPE bapihuheader,
        ls_read_option   TYPE zsits_batch_read_option,
        lt_label_type    TYPE ztlabel_type_range.

  DATA: lv_msgid TYPE msgid,
        lv_msgno TYPE msgno,
        lv_msgv1 TYPE msgv1.

  FIELD-SYMBOLS: <fs_hu_content> TYPE LINE OF zthu_item_tab.
*  CLEAR zsits_scan_dynp-zzsuccess_msg.
*  CHECK gs_return-type NE 'E'.
  IF gv_flg_us = abap_true
        AND gs_return-type = 'E'.
    lv_msgid = gs_return-id.
    lv_msgno = gs_return-number.
    lv_msgv1 = gs_return-message_v1.
    IF lv_msgno = '249'.
      MESSAGE e249(zlone_hu) WITH lv_msgv1 INTO lv_dummy.
      PERFORM log USING zcl_its_utility=>gc_objid_palcarton
                      lv_msgv1
                      abap_true.
      CLEAR :lv_dummy, lv_msgid, lv_msgno , lv_msgv1.
    ELSEIF lv_msgno = '072'.
      MESSAGE e072(zlone_hu) WITH lv_msgv1 INTO lv_dummy.
      PERFORM log USING zcl_its_utility=>gc_objid_palcarton
                      lv_msgv1
                      abap_true.
      CLEAR :lv_dummy, lv_msgid, lv_msgno , lv_msgv1.
    ENDIF.
  ENDIF.
*  *     Perform validation on ENTER
  IF gs_hu-exidv IS NOT INITIAL.
    PERFORM frm_add_label_type USING zcl_its_utility=>gc_label_hu lt_label_type.
    lv_barcode = zsits_scan_dynp-zzbarcode(100).
    CALL METHOD zcl_its_utility=>barcode_read_dfs
      EXPORTING
        iv_barcode           = lv_barcode
        is_read_option       = ls_read_option
        iv_exist_check       = iv_exist_check
        it_label_type_range  = lt_label_type
        iv_read_10_only      = iv_read_10_only
        iv_skip_or_bch_check = iv_skip_or_bch_check
        iv_appid_type        = lc_capus_type   "AT Added
      IMPORTING
        ev_label_type        = lv_label_type
        es_label_content     = ls_label_content.

    IF lv_label_type IS INITIAL OR lv_label_type NE zcl_its_utility=>gc_label_hu.
* Invalid pallet label or required handling unit could not be found
      PERFORM log USING zcl_its_utility=>gc_objid_label
                        zsits_scan_dynp-zzbarcode
                        abap_true.
      RETURN.
    ENDIF.

    CLEAR lwa_hu_header.
    MOVE-CORRESPONDING ls_label_content-hu_content-hu_header TO lwa_hu_header.

    IF ls_label_content-hu_content-hu_content[] IS INITIAL.
* If pallet is empty, display error message
      MESSAGE e126(zits) WITH lwa_hu_header-hu_exid INTO lv_dummy.
      PERFORM log USING zcl_its_utility=>gc_objid_palcarton
                        lwa_hu_header-hu_exid
                        abap_true.
      RETURN.
    ENDIF.

    SORT ls_label_content-hu_content-hu_content BY hu_item_number.
    ls_read_option-zzstock_read = abap_true.

    LOOP AT ls_label_content-hu_content-hu_content ASSIGNING <fs_hu_content>.
* Remove each batch and update characteristics

      CLEAR: ls_batch_data,
             ls_batch_key.

      lv_batch = <fs_hu_content>-batch.
*   Convert the SAP batch length(10) to Capsugel Batch length(15)
      CALL METHOD zcl_batch_utility=>is_fg_batch
        EXPORTING
          iv_batch       = lv_batch
          is_read_option = ls_read_option
        RECEIVING
          rs_batch_data  = ls_batch_data.

      IF ls_batch_data IS INITIAL.
*   One batch on pallet is not a FG batch
        PERFORM log USING zcl_its_utility=>gc_objid_palcarton
                          lwa_hu_header-hu_exid
                          abap_true.
        RETURN.
      ENDIF.
      MOVE-CORRESPONDING ls_batch_data TO ls_batch_key.

      CALL METHOD zcl_batch_utility=>batch_off_pallet
*   Remove single batch from pallet without commit work
        EXPORTING
          is_batch_key = ls_batch_key
        RECEIVING
          rv_result    = lv_result.

      IF lv_result NE abap_true.
*   If unpack fails, display error message
        PERFORM log USING zcl_its_utility=>gc_objid_palcarton
                          lwa_hu_header-hu_exid
                          abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
* Commit work to unpack all batches from pallet
    MESSAGE s127(zits) WITH lwa_hu_header-hu_exid INTO zsits_scan_dynp-zzsuccess_msg.
    PERFORM log USING zcl_its_utility=>gc_objid_palcarton
                      lwa_hu_header-hu_exid
                      abap_false.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_ADD_LABEL_TYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZCL_ITS_UTILITY=>GC_LABEL_HU  text
*      -->P_LT_LABEL_TYPE  text
*----------------------------------------------------------------------*
FORM frm_add_label_type  USING    uv_label_type  TYPE zdits_label_type
                         CHANGING ct_label_range TYPE ztlabel_type_range.

  DATA: lwa_label_type_range TYPE zslabel_type_range.

  CLEAR lwa_label_type_range.
  lwa_label_type_range-sign   = lc_sign_i.
  lwa_label_type_range-zoption = lc_option_eq.
  lwa_label_type_range-low    = uv_label_type.
  APPEND lwa_label_type_range TO ct_label_range.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZCL_ITS_UTILITY=>GC_OBJID_LABE  text
*      -->P_ZSITS_SCAN_DYNP_ZZBARCODE  text
*      -->P_ABAP_TRUE  text
*----------------------------------------------------------------------*
FORM log  USING uv_object_id     TYPE zzscan_objid
               uv_content       TYPE any
               uv_with_message  TYPE boolean.
  CALL METHOD o_log->log_message_add
    EXPORTING
      iv_object_id    = uv_object_id
      iv_content      = uv_content
      iv_with_message = uv_with_message.

  IF uv_with_message = abap_true.
* Display error message
    CALL METHOD zcl_its_utility=>message_display( ).
  ENDIF.

  CLEAR zsits_scan_dynp-zzbarcode.
  GET CURSOR FIELD v_cursor_field.


ENDFORM.
