*----------------------------------------------------------------------*
***MZITSEHUPGII01
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  PAI_USER_COMMAND_200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_user_command_9100 INPUT.

  PERFORM frm_user_command.

ENDMODULE.                 " PAI_USER_COMMAND_200  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_USER_COMMAND_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_user_command_9200 INPUT.

  PERFORM frm_user_command.

ENDMODULE.                 " PAI_USER_COMMAND_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_NEWTRAN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_newtran INPUT.

  CALL TRANSACTION 'ZMDE'.
ENDMODULE.                 " PAI_NEWTRAN  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_CURSOR_DETERMINE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_cursor_determine INPUT.

  PERFORM frm_cursor_determine.

ENDMODULE.                 " PAI_CURSOR_DETERMINE  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_PROCESS_ORDER_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_process_order_check INPUT.

  CLEAR: iv_validation_fail,zsits_scan_dynp-zzsuccess_msg.

  CHECK zsits_scan_dynp-zzprocord IS NOT INITIAL.
* Process Order Validation
  IF zcl_its_utility=>is_proc_order_exist( is_scan_dynp = zsits_scan_dynp ) = abap_false.
*   Error Handling of validaiton failure
    PERFORM frm_message_add USING zcl_its_utility=>gc_objid_proc
                                  zsits_scan_dynp-zzprocord
                                  abap_true.

    CLEAR zsits_scan_dynp-zzprocord.
    LEAVE TO SCREEN 9100.
  ELSE.
    PERFORM frm_message_add USING zcl_its_utility=>gc_objid_proc
                                  zsits_scan_dynp-zzprocord
                                  abap_false.
  ENDIF.

ENDMODULE.                 " PAI_PROCESS_ORDER_CHECK  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_GET_DETAIL_INFO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_get_detail_info INPUT.
  DATA:   lx_read_option TYPE zsits_batch_read_option,
          lit_label_type TYPE ztlabel_type_range,
          lv_err_fg      TYPE boolean,
          lit_hu_content TYPE zthu_item_tab,
          lwa_hu_content TYPE bapihuitem.

  CLEAR: x_label_content,
         x_material_data.

  REFRESH lit_hu_content[].

  PERFORM add_label_type USING zcl_its_utility=>gc_label_hu "Handling Unit label
                         CHANGING lit_label_type.
  PERFORM add_label_type USING zcl_its_utility=>gc_label_mat_batch "Batch magaged material label
                         CHANGING lit_label_type.
  PERFORM add_label_type USING zcl_its_utility=>gc_label_mat_nob "Non-Batch magaged material
                         CHANGING lit_label_type.

*--Read the Barcode value
  CALL METHOD zcl_mde_barcode=>disolve_barcode
    EXPORTING
      iv_barcode          = zsits_scan_dynp-zzbarcode
      iv_werks            = ' '
      it_label_type_range = lit_label_type
    IMPORTING
      ev_label_type       = v_label_type
      es_label_content    = x_label_content
      es_material_data    = x_material_data.

  REFRESH lit_label_type.
  IF v_label_type IS INITIAL.
    lv_err_fg = abap_true.
  ELSE.
    CLEAR lv_err_fg.
  ENDIF.


  IF lv_err_fg = abap_false.
    CASE v_label_type.
      WHEN zcl_its_utility=>gc_label_hu..
        IF x_label_content-hu_content-hu_header-warehouse_number IS NOT INITIAL.
          lv_err_fg = abap_true.
          CLEAR v_dummy.
          MESSAGE e499(zits) WITH x_label_content-hu_content-hu_header-warehouse_number INTO v_dummy.
        ENDIF.

        lit_hu_content = x_label_content-hu_content-hu_content.
        READ TABLE lit_hu_content INTO lwa_hu_content INDEX 1.
        IF sy-subrc = 0.
          IF lwa_hu_content-stock_cat IS NOT INITIAL.
            lv_err_fg = abap_true.
            CLEAR v_dummy.
            MESSAGE e500(zits) INTO v_dummy.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDIF.

*   Process message, add scanned barcode to Log table with error message
  PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                zsits_scan_dynp-zzbarcode
                                lv_err_fg.

  PERFORM frm_clear_screen_fields.
  IF lv_err_fg = abap_false.
    PERFORM fill_screen_fields USING v_label_type.
  ENDIF.

ENDMODULE.                 " PAI_GET_DETAIL_INFO  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_UPDATE_FOR_QTY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_update_for_qty INPUT.

  PERFORM frm_update_for_changed_qty.

ENDMODULE.                 " PAI_UPDATE_FOR_QTY  INPUT
