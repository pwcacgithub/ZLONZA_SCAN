*&---------------------------------------------------------------------*
*&  Include           SAPDZH24_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  NEW_TRAN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE new_tran INPUT.
  CASE ok_code.
    WHEN 'NTRA'.
      PERFORM frm_new_tran.

    WHEN 'CLEAR'.
      PERFORM clear_del.

  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = zsits_scan_dynp-zzoutb_delivery
    IMPORTING
      output = zsits_scan_dynp-zzoutb_delivery.

  CASE ok_code.
    WHEN zcl_its_utility=>gc_okcode_back.
      LEAVE PROGRAM.

    WHEN 'ENTR'.

      PERFORM check_delivery.

    WHEN 'CLEAR'.
      PERFORM clear_all.

    WHEN 'PAL'.
      PERFORM check_delivery.
      CLEAR: gv_index1, gv_index2.
      SET SCREEN 0400.

    WHEN 'CAR'.
      PERFORM check_delivery.
      gv_flg_pallet = abap_false.
      CLEAR: lt_hu4[], gv_index1, gv_index2.
      SET CURSOR FIELD ''.
      SET SCREEN 0500.

  ENDCASE.

  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE ok_code.
    WHEN zcl_its_utility=>gc_okcode_back.
      PERFORM clear_all.
      SET SCREEN 0100.
      LEAVE SCREEN.


    WHEN zcl_its_utility=>gc_okcode_save.
*      **Link HU to OBD
      PERFORM link_hu_to_obd.

    WHEN 'CLEAR'.
      PERFORM clear_del.
    WHEN 'P-'.
*--Decrement the counter
      gv_index = gv_index - 1.

*--Page Down
    WHEN 'P+'.
*--Increment the counter
      gv_index = gv_index + 1.
    WHEN OTHERS.

  ENDCASE.

  CLEAR ok_code.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  DATA : lv_no    TYPE dynnr,
         lv_dynnr TYPE sy-dynnr.

  CONSTANTS : lc_zero TYPE char1 VALUE '0'.

  CLEAR : lv_no, lv_dynnr.
  CASE sy-ucomm.
    WHEN gc_back OR gc_ok.
*--Get previous screen number
      GET PARAMETER ID text-020 FIELD lv_no.
      lv_dynnr = lv_no.
*--Incase of screen no zero means successful message then leave program
      IF lv_no = lc_zero.
        LEAVE PROGRAM.
      ELSE.
*--another zero status move to previous screen only
        LEAVE TO SCREEN lv_dynnr.
      ENDIF.

    WHEN OTHERS.
**        Create hu if does not exist

*

  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  READ_BARCODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE read_barcode INPUT.
  CHECK ok_code = 'ENTR'.
  PERFORM read_barcode.

  PERFORM add_hu.

ENDMODULE.


MODULE user_command_0400 INPUT.
  CASE ok_code .
    WHEN 'ENTR'.
      PERFORM get_pallet.
    WHEN 'BACK'.

      CLEAR: zsits_scan_dynp-zzbarcode,
             gv_flg_pallet, gv_qty.
      SET SCREEN '0100'.

  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

MODULE user_command_0500 INPUT.
  IF gv_gelatin EQ gv_tcode AND gv_flg_pallet IS NOT INITIAL.
    CASE ok_code.
      WHEN 'P+'.
        PERFORM next1.
      WHEN 'P-'.
        PERFORM previous1.
      WHEN 'ENTR'.
        PERFORM validate_qty.
      WHEN 'BACK'.
        SET CURSOR FIELD ''.
        CLEAR: li_hu_disp, lv_indx .
        CLEAR : gv_cart1 , gv_cart2, gv_cart3, gv_cart4, gv_qty, gv_index1, gv_index2,
                gv_cart1_qty, gv_cart2_qty, gv_cart3_qty, gv_cart4_qty.
        CLEAR: zsits_scan_dynp-zzbarcode.
        SET SCREEN '0400'.
      WHEN 'CNF'.
        DATA: lv_barcode1 TYPE string,
              lv_matnr    TYPE matnr,
              lv_lfimg2   TYPE lfimg,
              lv_counter2 TYPE zl_de_counter.
        PERFORM validate_qty.
        PERFORM update.
        CLEAR : gv_cart1 , gv_cart2, gv_cart3, gv_cart4, zsits_scan_dynp-zzobd_item, zsits_scan_dynp-zzbarcode,
                gv_cart1_qty, gv_cart2_qty, gv_cart3_qty, gv_cart4_qty, lwa_lips.
        SET SCREEN 0100.
    ENDCASE.
  ELSE.
    CASE ok_code .
      WHEN 'ENTR'.
        IF sy-tcode NE gv_tcode.
          PERFORM duplicate_check.
        ENDIF.
        PERFORM carton_validation.
        PERFORM get_carton.
      WHEN 'BACK'.
        lv_cursor = ''.
        CLEAR: li_hu_disp, lv_indx .
        CLEAR : gv_cart1 , gv_cart2, gv_cart3, gv_cart4, gv_index1, gv_index2,
                gv_cart1_qty, gv_cart2_qty, gv_cart3_qty, gv_cart4_qty.
        lv_cursor = ''.
        IF gv_flg_pallet = abap_false.
          SET SCREEN '0100'.
        ELSE.
          CLEAR: zsits_scan_dynp-zzbarcode.
          SET SCREEN '0400'.
        ENDIF.
      WHEN 'CNF'.
        PERFORM carton_validation.
        PERFORM get_carton.
        PERFORM confirm_det.
        CLEAR : gv_cart1 , gv_cart2, gv_cart3, gv_cart4,
                gv_cart1_qty, gv_cart2_qty, gv_cart3_qty, gv_cart4_qty.
        IF gv_gelatin EQ gv_tcode.
          CLEAR: lwa_lips, zsits_scan_dynp-zzbarcode.
        ENDIF.
        lv_cursor = ''.
        SET SCREEN 0100.
      WHEN 'P+'.
        IF gv_gelatin EQ gv_tcode.
          PERFORM carton_validation.
          PERFORM get_carton.
          PERFORM next1.
        ELSE.
          PERFORM carton_validation.
          PERFORM get_carton.
          PERFORM next.
        ENDIF.
      WHEN 'P-'.
        IF gv_gelatin EQ gv_tcode.
          PERFORM previous1.
        ELSE.
          PERFORM prev.
        ENDIF.
    ENDCASE.
  ENDIF.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Form  NEXT1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM next1 .
  DATA: lv_lines TYPE i.
  CLEAR: lv_lines.
  IF gv_flg_pallet EQ abap_true.
    DESCRIBE TABLE lt_hu1[] LINES lv_lines.
  ELSE.
    DESCRIBE TABLE lt_hu4[] LINES lv_lines.
  ENDIF.
  IF gv_flg_pallet EQ abap_true..
    IF gv_index1 IS NOT INITIAL AND gv_index2 IS NOT INITIAL.
      IF lv_lines GE gv_index2 + 4.
        gv_index2 = gv_index2 + 4.
        IF gv_index1 + 4 < gv_index2 + 4.
          gv_index1 = gv_index1 + 4.
        ENDIF.
      ELSEIF lv_lines < gv_index2 + 4.
        gv_index2 = lv_lines.
        gv_index1 = gv_index2 - 3.
      ENDIF.
    ENDIF.
  ELSE.
    IF lv_lines < 4.
      gv_index2 = lv_lines + 4.
      gv_index1 = gv_index2 - 4.
    ELSEIF lv_lines GE 4.
      gv_index2 = gv_index2 + 4.
      gv_index1 = gv_index2 - 3.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  VALIDATE_QTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_qty .
  DATA: lv_lfimg1 TYPE lips-lfimg.
  CLEAR: lv_lfimg.
  IF lt_hu IS NOT INITIAL.
    LOOP AT lt_hu INTO lw_hu.
      lv_lfimg = lv_lfimg + lw_hu-qty.
    ENDLOOP.
    lv_lfimg1 = lv_lfimg.
  ENDIF.
  IF lv_lfimg1 < lwa_lips-lfimg.
    lv_msgno = '208'.
    SET CURSOR FIELD ''.
    lv_msgv1 = lwa_lips-posnr.
    lv_msgv2 = lwa_lips-lfimg - lv_lfimg1.
    CONDENSE: lv_msgv2, lv_msgv1.
    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
  ENDIF.
  IF lv_lfimg1 > lwa_lips-lfimg..
    lv_msgno = '220'.
    SET CURSOR FIELD ''.
    lv_msgv1 = gv_pal.
    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
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
  IF gv_flg_pallet EQ abap_true.
    IF gv_index1 IS NOT INITIAL AND gv_index2 IS NOT INITIAL.
      IF ( gv_index1 - 4 ) > 0.
        gv_index1 = gv_index1 - 4.
        IF ( gv_index2 - 4 ) > 0.
          gv_index2 = gv_index2 - 4.
        ENDIF.
      ELSEIF ( gv_index1 - 4 ) LE 0.
        gv_index1 = 1.
        gv_index2 = 4.
      ENDIF.
    ENDIF.
  ELSE.
    IF ( gv_index1 - 4 ) LE 0.
      gv_index1 = 1.
      gv_index2 = 4.
    ELSEIF ( gv_index1 - 4 ) > 0.
      gv_index1 = gv_index1 - 4.
      gv_index2 = gv_index2 - 4.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update .
  DATA: lv_display   TYPE flag,
        lv_barcode   TYPE string,
        lv_lfimg     TYPE lfimg,
        lv_matnr     TYPE matnr,
        lv_counter   TYPE zl_de_counter,
        lwa_scan_det TYPE zlscan_detail,
        lv_flag      TYPE flag,
        lv_batch     TYPE charg_d,
        lv_return    TYPE char50,
        lc_exidv     TYPE memoryid VALUE 'EXIDV',
        lv_hukey     TYPE exidv,
        lv_exidv     TYPE exidv,
        lv_msg       TYPE char20.
  CONSTANTS: lc_l(1)      TYPE c VALUE 'L',
             lc_carton(6) TYPE c VALUE 'CARTON'.

  IF lt_cart_all[] IS NOT INITIAL AND lt_cart[] IS NOT INITIAL.
    LOOP AT lt_cart_all  ASSIGNING FIELD-SYMBOL(<lfs_all1>).
      READ TABLE lt_cart ASSIGNING FIELD-SYMBOL(<lfs_cart1>) WITH KEY zzbarcode = <lfs_all1>-barcode.
      IF sy-subrc EQ gc_0.
        CLEAR: lv_matnr, lv_counter, lv_barcode, lv_lfimg, lv_batch.
        lv_counter = <lfs_cart1>-count.
        lv_lfimg = <lfs_cart1>-lfimg.
        lv_matnr = lwa_lips-matnr.
        lv_barcode = <lfs_cart1>-zzbarcode.
        lv_batch = <lfs_all1>-batch.
        lv_hukey = <lfs_all1>-exidv.
        lwa_scan_det-applc = 'GELATIN'.
        lwa_scan_det-vbeln = zsits_scan_dynp-zzoutb_delivery.
        lwa_scan_det-posnr = zsits_scan_dynp-zzobd_item.
        lwa_scan_det-matnr = lv_matnr.
        lwa_scan_det-counter = lv_counter.
        lwa_scan_det-hu_type = lc_carton.
        lwa_scan_det-hu_no = lv_hukey.
        lwa_scan_det-lfimg = lv_lfimg.
        lwa_scan_det-batch = lv_batch.
        APPEND lwa_scan_det TO lt_scan_det.
*        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF lt_hu IS NOT INITIAL.
    DELETE lt_hu[] WHERE typ = lc_l.
  ENDIF.
  IF lt_hu[] IS NOT INITIAL.
    CLEAR: lt_hu[].
  ENDIF.

  IF lt_scan_det IS NOT INITIAL AND lv_flag IS INITIAL.
    DELETE ADJACENT DUPLICATES FROM lt_scan_det COMPARING hu_no.
    MODIFY zlscan_detail FROM TABLE lt_scan_det.
    COMMIT WORK.
  ENDIF.
ENDFORM.
