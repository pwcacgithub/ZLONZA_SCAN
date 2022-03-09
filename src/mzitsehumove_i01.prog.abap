*&---------------------------------------------------------------------*
*&  Include           MZITSEHUMOVE_I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  PAI_NEWTRAN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_newtran INPUT.
  LEAVE TO TRANSACTION 'ZMDE'.
*  PERFORM frm_new_tran.

ENDMODULE.                 " PAI_NEWTRAN  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command INPUT.

  PERFORM frm_user_command.

ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI_PROCESS_MOVEMENT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_process_movement INPUT.

  CHECK sy-ucomm NE 'NTRA'  AND sy-ucomm NE 'CLR'.

  CLEAR zsits_scan_dynp-zzsuccess_msg.
* Read barcode information
  PERFORM frm_read_barcode.
* Get movement type
  PERFORM frm_get_movement_type.

* Process goods movement
  CASE sy-dynnr.
    WHEN 9100 OR 9110 OR 9200 OR 9300 OR 9400.
      IF sy-dynnr EQ '9100' OR sy-dynnr EQ '9200'.
        " Add SU
        PERFORM add_su.
      ELSE.
        " HU movement
        PERFORM frm_hu_movement.
      ENDIF.
    WHEN 9500.
      " Check Packing Bin and HU Bin
      PERFORM check_bin.
      " Unpack HU
      PERFORM frm_hu_unpack USING x_hu_item-pack_qty.
      " Post material movement
      PERFORM frm_material_movement USING x_hu_item-pack_qty.
    WHEN 9600.
      " Check quantity input
      PERFORM frm_check_quant.
      " Unpack part of HU
      PERFORM frm_hu_unpack USING zsits_scan_humove-zzquant.
      " Post material movement
      PERFORM frm_material_movement USING zsits_scan_humove-zzquant.
    WHEN OTHERS.
  ENDCASE.
* Update log and display error message on next screen if error occurs
  PERFORM frm_add_message USING zcl_its_utility=>gc_objid_label
                                zsits_scan_dynp-zzbarcode
                                v_err_fg.
* Display success message on current screen
  IF v_err_fg EQ abap_false.
    IF sy-dynnr NE '9100' AND sy-dynnr NE '9200'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = x_label_content-zzhu_exid
        IMPORTING
          output = x_label_content-zzhu_exid.
      MESSAGE s039 WITH x_label_content-zzhu_exid INTO zsits_scan_dynp-zzsuccess_msg.
    ENDIF.
  ENDIF.

ENDMODULE.                 " PAI_PROCESS_MOVEMENT  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI_CHECK_LGORT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_lgort INPUT.

  CHECK sy-ucomm NE 'NTRA' AND SY-UCOMM NE 'CLR'.
  PERFORM frm_check_lgort.

ENDMODULE.                 " PAI_CHECK_LGORT  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI_CHECK_KOSTL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_kostl INPUT.

  CHECK sy-ucomm NE 'NTRA' AND sy-ucomm NE 'CLR'.
  PERFORM frm_check_kostl.

ENDMODULE.                 " PAI_CHECK_KOSTL  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI_CHECK_GRUND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_grund INPUT.

  CHECK sy-ucomm NE 'NTRA' AND sy-ucomm NE 'CLR'.
  PERFORM frm_check_grund.

ENDMODULE.                 " PAI_CHECK_GRUND  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI_CHECK_ZZWBSCD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_wbscd INPUT.

  CHECK sy-ucomm NE 'NTRA'.
  PERFORM frm_check_wbscd.

ENDMODULE.                 " PAI_CHECK_ZZWBSCD  INPUT

*&---------------------------------------------------------------------*
*&      Form  NEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM next.
  DATA: lv_lines TYPE i.
  CLEAR: lv_lines.
  DESCRIBE TABLE it_su[] LINES lv_lines.
  break sghosh1.
  IF gv_index1 IS NOT INITIAL AND gv_index2 IS NOT INITIAL.
    IF lv_lines GE gv_index2 + 5.
      gv_index2 = gv_index2 + 5.
      IF gv_index1 + 5 < gv_index2 + 5.
        gv_index1 = gv_index1 + 5.
      ENDIF.
    ELSEIF lv_lines < gv_index2 + 5.
      gv_index2 = lv_lines.
      gv_index1 = gv_index2 - 4.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PREVIOUS1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM previous1 .
  IF gv_index1 IS NOT INITIAL AND gv_index2 IS NOT INITIAL.
    IF ( gv_index1 - 5 ) > 0.
      gv_index1 = gv_index1 - 5.
      IF ( gv_index2 - 5 ) > 0.
        gv_index2 = gv_index2 - 5.
      ENDIF.
    ELSEIF ( gv_index1 - 5 ) LE 0.
      gv_index1 = 1.
      gv_index2 = 5.
    ENDIF.
  ENDIF.
ENDFORM.
