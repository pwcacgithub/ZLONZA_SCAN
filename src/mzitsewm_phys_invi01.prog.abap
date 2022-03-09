*&---------------------------------------------------------------------*
*&  Include           MZITSEWM_PHYS_INVI01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  NEW_TRAN  INPUT
*&---------------------------------------------------------------------*
*       New Transcation
*----------------------------------------------------------------------*
MODULE new_tran INPUT.

   LEAVE TO SCREEN 0.

ENDMODULE.                 " NEW_TRAN  INPUT

*&---------------------------------------------------------------------*
*&      Module  INV_DOC_CHECK  INPUT
*&---------------------------------------------------------------------*
*       Inv Doc existence check
*----------------------------------------------------------------------*
MODULE inv_doc_check INPUT.

  CLEAR: zsits_scan_dynp-zzsuccess_msg,
         v_su_m_bool,
         v_error_ind,
         v_back_flag,
         it_completed_bin,
         it_counted_rm_batch.

  CHECK zsits_scan_dynp-zzwminvdoc IS NOT INITIAL.

  PERFORM frm_inv_doc_check CHANGING v_error_ind.

  PERFORM frm_message_add  USING zcl_its_utility=>gc_objid_invdoc
                                 zsits_scan_dynp-zzwminvdoc
                                 v_error_ind.

  IF v_error_ind = abap_true.
    CLEAR zsits_scan_dynp.
  ELSE.
    CALL SCREEN 9100.
  ENDIF.

ENDMODULE.                 " INV_DOC_CHECK  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9100  INPUT
*&---------------------------------------------------------------------*
*       User Command
*----------------------------------------------------------------------*
MODULE user_command_9100 INPUT.

  PERFORM frm_user_command_9100.

ENDMODULE.                 " USER_COMMAND_9100  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_BIN  INPUT
*&---------------------------------------------------------------------*
*       Bin Check
*----------------------------------------------------------------------*
MODULE check_bin INPUT.

  CLEAR: v_error_ind.

  CHECK zsits_scan_dynp-zzsbin IS NOT INITIAL.

  PERFORM frm_bin_check CHANGING v_error_ind.

  PERFORM frm_message_add  USING zcl_its_utility=>gc_objid_bin
                                 zsits_scan_dynp-zzsbin
                                 v_error_ind.
  IF v_error_ind EQ abap_true.
    CLEAR zsits_scan_dynp-zzsbin.
  ENDIF.

ENDMODULE.                 " CHECK_BIN  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_SU  INPUT
*&---------------------------------------------------------------------*
*       SU Check
*----------------------------------------------------------------------*
MODULE check_su INPUT.

  CLEAR zsits_scan_dynp-zzsuccess_msg.

  CHECK zsits_scan_dynp-zzbarcode IS NOT INITIAL.

  PERFORM frm_check_su CHANGING v_error_ind.

  PERFORM frm_message_add USING zcl_its_utility=>gc_objid_sloc
                                zsits_scan_dynp-zzbarcode"zsits_scan_dynp-zzsu
                                v_error_ind.

  CLEAR zsits_scan_dynp-zzbarcode.

ENDMODULE.                 " CHECK_SU  INPUT

*&---------------------------------------------------------------------*
*&      Module  LABEL_RECOGNISION  INPUT
*&---------------------------------------------------------------------*
*       Break down label
*----------------------------------------------------------------------*
MODULE label_recog INPUT.

  CLEAR zsits_scan_dynp-zzsuccess_msg.

  CHECK zsits_scan_dynp-zzbchmtr IS NOT INITIAL.

  CLEAR v_error_ind.

  PERFORM frm_label_recog CHANGING v_error_ind.

  PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                zsits_scan_dynp-zzbchmtr
                                v_error_ind.
  CLEAR zsits_scan_dynp-zzbchmtr.

ENDMODULE.                 " LABEL_RECOGNISION  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9300  INPUT
*&---------------------------------------------------------------------*
*       User command
*----------------------------------------------------------------------*
MODULE user_command_9300 INPUT.

  PERFORM frm_user_command_9300.

ENDMODULE.                 " USER_COMMAND_9300  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9200  INPUT
*&---------------------------------------------------------------------*
*       User Command
*----------------------------------------------------------------------*
MODULE user_command_9200 INPUT.

  PERFORM frm_user_command_9200.

ENDMODULE.                 " USER_COMMAND_9200  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9400 INPUT.

  PERFORM frm_user_command_9200.

ENDMODULE.                 " USER_COMMAND_9400  INPUT

*&---------------------------------------------------------------------*
*&      Module  UOM_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE uom_check INPUT.

  DATA lv_dummy TYPE bapi_msg.

  CHECK zsits_scan_dynp-zzsuom IS NOT INITIAL.

  SELECT COUNT(*) FROM t006 WHERE msehi EQ zsits_scan_dynp-zzsuom.
  IF sy-subrc NE 0.
    " Invalid UoM &1.
    MESSAGE e338(zits) WITH zsits_scan_dynp-zzsuom INTO lv_dummy.
    PERFORM frm_message_add  USING zcl_its_utility=>gc_objid_quantity
                                   zsits_scan_dynp-zzquantity
                                   abap_true.

  ENDIF.

ENDMODULE.                 " UOM_CHECK  INPUT

*&---------------------------------------------------------------------*
*&      Module  QTY_CHECK  INPUT
*&---------------------------------------------------------------------*
*      Set quantity
*----------------------------------------------------------------------*
MODULE qty_check INPUT.

  CHECK zsits_scan_dynp-zzquantity IS NOT INITIAL.

  IF zcl_its_utility=>is_qty_valid( iv_qty = zsits_scan_dynp-zzquantity ) EQ abap_false.

    PERFORM frm_message_add  USING zcl_its_utility=>gc_objid_quantity
                                   zsits_scan_dynp-zzquantity
                                   abap_true.
    CLEAR zsits_scan_dynp-zzquantity.
  ELSEIF zsits_scan_dynp-zzsuom IS INITIAL.
*   Set curspr to button of 'ADD'
    v_cursor_field = 'ZSITS_SCAN_DYNP-ZZSUOM'.
  ENDIF.

ENDMODULE.                 " QTY_CHECK  INPUT

*&---------------------------------------------------------------------*
*&      Module  POPULATE_CONTAINER_BATCH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE populate_container_batch INPUT.

  CHECK zsits_scan_dynp-zzquantity IS NOT INITIAL AND zsits_scan_dynp-zzsuom IS NOT INITIAL.

  PERFORM frm_populate_container CHANGING v_error_ind.
  PERFORM frm_message_add USING zcl_its_utility=>gc_objid_quantity
                                zsits_scan_dynp-zzquantity
                                v_error_ind.
  IF v_error_ind EQ abap_true.
    CLEAR zsits_scan_dynp-zzquantity.
  ENDIF.

ENDMODULE.                 " POPULATE_CONTAINER_BATCH  INPUT
