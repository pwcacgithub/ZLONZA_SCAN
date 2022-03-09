*&---------------------------------------------------------------------*
*&  Include           MZITSEMTC_PUTAWAYI01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  NEW_TRAN  INPUT
*&---------------------------------------------------------------------*

MODULE new_tran INPUT.

  DATA: lv_code TYPE sy-ucomm.
  lv_code = ok_code.
  CLEAR ok_code.

  CASE lv_code.
    WHEN zcl_its_utility=>gc_okcode_newtran.
      PERFORM frm_new_tran.
    WHEN 'BCK'.
      CLEAR zsits_scan_dynp.
      LEAVE TO SCREEN 9000.
  ENDCASE.

ENDMODULE.                 " NEW_TRAN  INPUT
*&---------------------------------------------------------------------*
*&      Module  TO_CHECK  INPUT
*&---------------------------------------------------------------------*
MODULE to_check INPUT.
  CLEAR zsits_scan_dynp-zzsuccess_msg.
  PERFORM user_command_9000.
  IF zsits_scan_dynp-zzto_num IS NOT INITIAL.
    PERFORM frm_to_check.
  ENDIF.
ENDMODULE.                 " TO_CHECK  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9100 OUTPUT.
  SET CURSOR FIELD v_cursor_field.
  SET PF-STATUS 'S9100'.
ENDMODULE.                 " STATUS_9100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MATERIAL_UPDATE  INPUT
*&---------------------------------------------------------------------*
MODULE material_update INPUT.
  CLEAR zsits_scan_dynp-zzsuccess_msg.
  IF zsits_scan_dynp-zzmaterial <> '' AND zsits_scan_dynp-zzto_num <> ''.
    PERFORM frm_material_update.
  ENDIF.
ENDMODULE.                 " MATERIAL_UPDATE  INPUT
" QTY_UPDATE  INPUT
*&---------------------------------------------------------------------*
*&      Module  DBIN_UPDATE  INPUT
*&---------------------------------------------------------------------*
MODULE dbin_update INPUT.
  CLEAR zsits_scan_dynp-zzsuccess_msg.

  IF zsits_scan_dynp-zzto_num <> '' AND zsits_scan_dynp-zzmaterial <> ''
                                    AND zsits_scan_dynp-zzdestbin_upd <> ''.
    PERFORM frm_dbin_update.
  ENDIF.
ENDMODULE.                 " DBIN_UPDATE  INPUT
*&---------------------------------------------------------------------*
*&      Module  TO_CONFIRM  INPUT
*&---------------------------------------------------------------------*
MODULE to_confirm INPUT.
  IF zsits_scan_dynp-zzto_num <> '' AND zsits_scan_dynp-zzmaterial <> ''
                                    AND zsits_scan_dynp-zzdestbin_upd <> ''
                                    AND zsits_scan_dynp-zzquantity_upd <> ''.
    PERFORM frm_to_confirm.
  ENDIF.
ENDMODULE.                 " TO_CONFIRM  INPUT
*&---------------------------------------------------------------------*
*&      Module  QUANTITY_UPDATE  INPUT
*&---------------------------------------------------------------------*
MODULE quantity_update INPUT.
  CLEAR zsits_scan_dynp-zzsuccess_msg.

  DATA: lv_numeric_characters(11) TYPE c VALUE '1234567890 ',
        lv_dummy                  TYPE bapi_msg.

  IF zsits_scan_dynp-zzto_num <> '' AND zsits_scan_dynp-zzmaterial <> ''
                                    AND zsits_scan_dynp-zzquantity_upd <> ''.
*Check if the quantity entered is in numeric format
    IF zsits_scan_dynp-zzquantity_upd CO lv_numeric_characters.
      IF x_to_item-vsola GE zsits_scan_dynp-zzquantity_upd.
        PERFORM frm_set_cursor.
      ELSE.
        MESSAGE e309(zits) INTO lv_dummy.
        PERFORM frm_message_add USING zsits_scan_dynp-zzquantity_upd
                                      zcl_its_utility=>gc_objid_quantity
                                      abap_true.
        CLEAR zsits_scan_dynp-zzquantity_upd.
      ENDIF.
    ELSE.
      MESSAGE e136(zits) INTO lv_dummy.
      PERFORM frm_message_add USING zsits_scan_dynp-zzquantity_upd
                                    zcl_its_utility=>gc_objid_quantity
                                    abap_true.
      CLEAR zsits_scan_dynp-zzquantity_upd.
    ENDIF.
  ENDIF.

ENDMODULE.                 " QUANTITY_UPDATE  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  PERFORM user_command_9000.
ENDMODULE.
