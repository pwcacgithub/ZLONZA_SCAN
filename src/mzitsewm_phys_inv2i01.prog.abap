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

  PERFORM frm_user_command_9400.

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
  DATA : lv_meins TYPE meins.
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
*&---------------------------------------------------------------------*
*&      Module  POPULATE_CONTAINER_MATNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE populate_container_matnr INPUT.
  CHECK zsits_scan_dynp-zzquantity IS NOT INITIAL AND zsits_scan_dynp-zzsuom IS NOT INITIAL.

  PERFORM frm_populate_container_matnr CHANGING v_error_ind.
  PERFORM frm_message_add USING zcl_its_utility=>gc_objid_quantity
                                zsits_scan_dynp-zzquantity
                                v_error_ind.
  IF v_error_ind EQ abap_true.
    CLEAR zsits_scan_dynp-zzquantity.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  FRM_POPULATE_CONTAINER_MATNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_V_ERROR_IND  text
*----------------------------------------------------------------------*
FORM frm_populate_container_matnr  CHANGING cv_error_ind TYPE xfeld.

  DATA:ls_linv  TYPE linv_vb,
       lv_matnr TYPE matnr.

  FIELD-SYMBOLS:<fs_linv> LIKE LINE OF it_linv.

  cv_error_ind = abap_true.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT' "to check with the table value 18 digit
    EXPORTING
      input  = zsits_scan_dynp-zzbchmtr
    IMPORTING
      output = lv_matnr.

  READ TABLE it_linv ASSIGNING <fs_linv> WITH KEY lgnum = x_profile-zzlgnum
                                                  ivnum = zsits_scan_dynp-zzwminvdoc
                                                  lgpla = zsits_scan_dynp-zzsbin
                                                  matnr = lv_matnr.

  IF sy-subrc = 0.
    ls_linv = <fs_linv>.
    ls_linv-menga = zsits_scan_dynp-zzquantity.
    ls_linv-meins = zsits_scan_dynp-zzsuom.
    ls_linv-wdatu = sy-datlo.
  ELSE.
    READ TABLE it_linv ASSIGNING <fs_linv> WITH KEY lgnum = x_profile-zzlgnum
                                                    ivnum = zsits_scan_dynp-zzwminvdoc
                                                    lgpla = zsits_scan_dynp-zzsbin.
    IF sy-subrc EQ 0.
      ls_linv-werks = <fs_linv>-werks.
      ls_linv-lgort = <fs_linv>-lgort.
      ls_linv-lgtyp = <fs_linv>-lgtyp.
      ls_linv-lgnum = x_profile-zzlgnum.
      ls_linv-ivnum = zsits_scan_dynp-zzwminvdoc.
      ls_linv-lgpla = zsits_scan_dynp-zzsbin.
      ls_linv-menga = zsits_scan_dynp-zzquantity.
      ls_linv-matnr = lv_matnr.
      ls_linv-meins = zsits_scan_dynp-zzsuom.
      ls_linv-wdatu = sy-datlo.
    ENDIF.
  ENDIF.

  PERFORM frm_pass_data_9200 USING    abap_false " overwrite
                          CHANGING ls_linv.


  MESSAGE s357(zits) INTO zsits_scan_dynp-zzsuccess_msg.
  cv_error_ind = abap_false.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  DATA: lv_ucomm TYPE sy-ucomm.
  lv_ucomm = sy-ucomm.
  CASE lv_ucomm.
    WHEN 'NEXT'.
      PERFORM next.
  ENDCASE.
ENDMODULE.
