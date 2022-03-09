*&---------------------------------------------------------------------*
*&  Include           DZH00I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  DATA : lv_vepos TYPE vepos.
  DATA : ls_vepo  TYPE ts_vepo.
  DATA: lv_msg_id TYPE msgid,
        lv_msg_no TYPE msgno,
        lv_msg_v1 TYPE msgv1.
*--Based on OK system command it will check
  CASE sy-ucomm.
    WHEN gc_back OR gc_f3 OR gc_qu.     "'BACK'.
      LEAVE PROGRAM .
    WHEN gc_clr OR gc_f2. "'CLR' OR 'F2'.
      CLEAR : gv_exidv.
      CLEAR : gv_barcode.
      CLEAR :
          gv_exidv5,
          gv_werks,
          gv_lgort,
          gv_lgnum ,
          gv_lgtyp,
          gv_lgpla,
          gv_lgber ,
          gv_lgpla,
          gv_exidv_p.

    WHEN gc_hu OR gc_ent. "'HU'.
      IF gv_flg_us = abap_true
        AND gs_return-type = 'E'.
        lv_msg_id = gs_return-id.
        lv_msg_no = gs_return-number.
        lv_msg_v1 = gs_return-message_v1.
        CLEAR : gv_barcode .
        PERFORM error_message USING lv_msg_id lv_msg_no lv_msg_v1.
      ENDIF.
*     Perform validation on ENTER or HU
      IF gv_exidv IS NOT INITIAL .
        CLEAR : gv_ind.
        PERFORM validation USING gv_exidv.
*--Check whether HU is a Pallet HU or Pack HU
        PERFORM check_hu USING gs_vekp
                         CHANGING gv_ind .
        IF gv_count_vepo = gc_1 AND  gv_nested_pack EQ abap_false."rvenugopal EICR 603418
          IF gv_ind = abap_true .
*--Pack HU screen
            PERFORM pack_hu_details USING gv_exidv lv_vepos gt_vepo gs_vekp.
            CALL SCREEN 0800.
          ELSE.
*--Pallet HU screen
            PERFORM pallet_hu_details USING gv_exidv lv_vepos gt_vepo gs_vekp.
            CALL SCREEN 0700.
          ENDIF.
        ELSE.
          PERFORM fill_hu USING gt_vepo.
          CALL SCREEN 0200.
        ENDIF.
      ENDIF.
    WHEN gc_lo. "'LO'.
      IF gv_flg_us = abap_true
  AND gs_return-type = 'E'.
        lv_msg_id = gs_return-id.
        lv_msg_no = gs_return-number.
        lv_msg_v1 = gs_return-message_v1.
        CLEAR : gv_barcode .
        PERFORM error_message USING lv_msg_id lv_msg_no lv_msg_v1.
      ENDIF.
*     Perform validation on LO
      IF gv_exidv IS NOT INITIAL .
        PERFORM validation USING gv_exidv.
        IF gv_count_vepo = gc_1.
          PERFORM check_hu USING gs_vekp
                   CHANGING gv_ind .
*--Storage location
          PERFORM validation USING gv_exidv.
          IF gt_vepo IS NOT INITIAL.
            CLEAR : ls_vepo.
            READ TABLE gt_vepo INTO ls_vepo INDEX 1.
          ENDIF.
          PERFORM get_stor_loc USING gv_exidv ls_vepo-vepos gt_vepo gs_vekp.
          CALL SCREEN 0400.
        ELSE.
          PERFORM fill_hu USING gt_vepo.
          CALL SCREEN 0200.
        ENDIF.
      ENDIF.
    WHEN gc_af.
      IF gv_flg_us = abap_true
  AND gs_return-type = 'E'.
        lv_msg_id = gs_return-id.
        lv_msg_no = gs_return-number.
        lv_msg_v1 = gs_return-message_v1.
        CLEAR : gv_barcode .
        PERFORM error_message USING lv_msg_id lv_msg_no lv_msg_v1.
      ENDIF.
*     Perform validation on AF
      IF gv_exidv IS NOT INITIAL .
        PERFORM validation USING gv_exidv.
        IF gv_count_vepo = gc_1.
*--Fetching Material Stock Information
          PERFORM validation USING gv_exidv.
          IF gt_vepo IS NOT INITIAL.
            CLEAR : ls_vepo.
            READ TABLE gt_vepo INTO ls_vepo INDEX 1.
          ENDIF.
          PERFORM get_addition_fields.
          CLEAR : gv_exidv.
          CALL SCREEN 0600.
        ELSE.
          PERFORM fill_hu USING gt_vepo.
          CALL SCREEN 0200.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validation INPUT.

*--validate input field value
  IF sy-ucomm EQ gc_ent.
    IF gv_flg_us = abap_true
        AND gs_return-type = 'E'.
      lv_msg_id = gs_return-id.
      lv_msg_no = gs_return-number.
      lv_msg_v1 = gs_return-message_v1.
      CLEAR : gv_barcode .
      PERFORM error_message USING lv_msg_id lv_msg_no lv_msg_v1.
    ENDIF.
*      *     Perform validation on ENTER or HU
    IF gv_exidv IS NOT INITIAL .
      PERFORM validation USING gv_exidv.
    ENDIF.
  ENDIF.
*--Back to main screen
  IF sy-ucomm EQ gc_back OR
     sy-ucomm EQ gc_f3.
    LEAVE PROGRAM .
  ENDIF.
*--clear values
  IF sy-ucomm EQ gc_f2.
    CLEAR : gv_exidv.
  ENDIF.

ENDMODULE.                 " VALIDATION  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  DATA : lv_msgv1 TYPE msgv1.
  DATA : lv_chk TYPE boolean.

  DATA : lv_msgno1 TYPE msgno.
  DATA : lv_msgno2 TYPE msgno.
  DATA : ls_multiple_hu TYPE ts_multiple_hu.


*--Check User command
  CASE sy-ucomm.

*--leave to screen Back
    WHEN gc_back.
      LEAVE TO SCREEN 100.

*--leave to screen Back
    WHEN gc_f3.
      LEAVE TO SCREEN 100.

    WHEN gc_clr OR gc_f2.
*--clear HU details
      LOOP AT gt_multiple_hu INTO ls_multiple_hu.
        ls_multiple_hu-ch1 = ' '.
        MODIFY gt_multiple_hu FROM ls_multiple_hu INDEX sy-tabix TRANSPORTING ch1.
      ENDLOOP.

    WHEN gc_ent.
*--Fetch Lower Level HU's and Save

      PERFORM fill_hu USING gt_vepo.

    WHEN gc_qu.     "'BACK'.
      LEAVE PROGRAM .

    WHEN gc_pgdn. "'PGDN'.
      DESCRIBE TABLE gt_multiple_hu LINES gv_p_num.
*      gv_p_num = gv_n2.
* Number of screens required for output if 5 records per screen
      gv_lv_d = gv_p_num / 3.
      gv_lv_div = ceil( gv_lv_d ).
      gv_curr_p_num = gv_lv_div * 3.
      gv_v_index = gv_v_next + 1.
      IF gv_v_next < gv_lv_div.
        gv_v_next = gv_v_next + 1.
      ELSE.
        gv_v_next = gv_lv_div.
      ENDIF.
      gv_v_prev = gv_v_next.
      IF gv_v_next <> gv_lv_div.
        gv_n2 = gv_p_num - 3 *  gv_v_next.
        IF gv_n2 > 3.
          gv_n2 = 3 * gv_v_next.
        ENDIF.
        gv_n1 = 1.
        gv_line = gv_line + gv_lines.
        gv_limit = gv_curr_p_num - gv_lines.
        IF gv_line > gv_limit.
          gv_line = gv_limit.
        ENDIF.
      ELSE.
        gv_v_next = gv_v_next - 1.
      ENDIF.

    WHEN gc_pgup. "'PGUP'.
*--Pageup for back screen

      gv_n2 = 3 * gv_v_next.
      IF gv_n1 < 0.
        gv_n1 = 1.
      ENDIF.
      IF gv_v_next > 0.
        gv_v_next = gv_v_next - 1.
      ELSE.
        gv_v_next = 0.
      ENDIF.
      gv_v_prev = gv_v_next.
      IF gv_line NE 0 AND gv_curr_p_num GT 3.
        gv_line = gv_v_next * 3.
      ELSE.
        gv_line = 0.
        gv_v_index = gv_v_next - 1.
      ENDIF.
      IF gv_line < 0.
        gv_line = 0.
      ENDIF.

    WHEN gc_ch1 OR gc_ch2 OR gc_ch3. "'CH1' OR 'CH2' OR 'CH3'.
*--Check box selection validtion
      PERFORM chekbox_validation CHANGING gv_pg_cnt.

    WHEN gc_hu.
      PERFORM check_multiple_hu_sel USING gt_multiple_hu CHANGING ls_multiple_hu lv_chk.
      IF lv_chk IS INITIAL.

        READ TABLE gt_multiple_hu INTO DATA(ls_multi) WITH KEY ch1 = abap_true.

        PERFORM pack_hu_details_mult USING ls_multi-exidv." ls_multi-unvel ls_multi-vepos  gt_vepo gs_vekp.
        CALL SCREEN 0800.

      ELSE.
        CLEAR : lv_msgv1,lv_msgno2.
        lv_msgv1 = gv_exidv.
        lv_msgno2 = gc_msgno33.
        PERFORM error_message  USING  gc_msgid lv_msgno2 lv_msgv1.
        CALL SCREEN 0300.

      ENDIF.

    WHEN gc_lo. "'LO'.
      PERFORM check_multiple_hu_sel USING gt_multiple_hu CHANGING ls_multiple_hu lv_chk.
      IF lv_chk IS INITIAL.
*--Storage location
        READ TABLE gt_multiple_hu INTO ls_multi WITH KEY ch1 = abap_true.
        PERFORM get_stor_loc_mult USING ls_multi-exidv gs_vekp-exidv." ls_multiple_hu-vepos gt_vepo gs_vekp.
        CALL SCREEN 0400.

      ELSE.
        CLEAR : lv_msgv1,lv_msgno2.
        lv_msgv1 = gv_exidv.
        lv_msgno2 = gc_msgno33.
        PERFORM error_message  USING  gc_msgid lv_msgno2 lv_msgv1.
        CALL SCREEN 0300.

      ENDIF.
    WHEN gc_af.
      PERFORM check_multiple_hu_sel USING gt_multiple_hu CHANGING ls_multiple_hu lv_chk.
      IF lv_chk IS INITIAL.
        READ TABLE gt_multiple_hu INTO ls_multi WITH KEY ch1 = abap_true.
        PERFORM get_additional_fields_mult USING ls_multi-exidv.
        CALL SCREEN 0600.
      ELSE.
        CLEAR : lv_msgv1,lv_msgno2.
        lv_msgv1 = gv_exidv.
        lv_msgno2 = gc_msgno33.
        PERFORM error_message  USING  gc_msgid lv_msgno2 lv_msgv1.
        CALL SCREEN 0300.
      ENDIF.

    WHEN OTHERS.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  TRANSP_ITAB_IN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE transp_itab_in INPUT.
  gv_lines = sy-loopc.
  gv_idx = sy-stepl + gv_line.
  MODIFY gt_multiple_hu FROM gs_multi INDEX gv_idx.

ENDMODULE.                 " TRANSP_ITAB_IN  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  DATA : lv_no    TYPE dynnr,
         lv_dynnr TYPE sy-dynnr.

  CLEAR : lv_no, lv_dynnr.
  CASE sy-ucomm.
    WHEN gc_back OR gc_ok.
*--recollect previous screen number
      GET PARAMETER ID text-020 FIELD lv_no.
      lv_dynnr = lv_no.
      LEAVE TO SCREEN lv_dynnr.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.


  CLEAR : lv_no, lv_dynnr.
  CASE sy-ucomm.
    WHEN gc_back OR gc_ok.
*--recollect previous screen number
      GET PARAMETER ID text-020 FIELD lv_no.
      lv_dynnr = lv_no.
      LEAVE TO SCREEN lv_dynnr.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0500 INPUT.
*--Check User command

  CLEAR : lv_no, lv_dynnr.
  CASE sy-ucomm.
    WHEN gc_back OR gc_ok.
*--recollect previous screen number
      GET PARAMETER ID text-020 FIELD lv_no.
      lv_dynnr = lv_no.
      LEAVE TO SCREEN lv_dynnr.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0600 INPUT.

  CLEAR : lv_no, lv_dynnr.
  CASE sy-ucomm.
    WHEN gc_back OR gc_ok.
*--recollect previous screen number
      GET PARAMETER ID text-020 FIELD lv_no.
      lv_dynnr = lv_no.
      LEAVE TO SCREEN lv_dynnr.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0700 INPUT.

  CLEAR : lv_no, lv_dynnr.
  CASE sy-ucomm.
    WHEN gc_back OR gc_ok.
*--recollect previous screen number
      GET PARAMETER ID text-020 FIELD lv_no.
      lv_dynnr = lv_no.
      LEAVE TO SCREEN lv_dynnr.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0800 INPUT.

  CLEAR : lv_no, lv_dynnr.
  CASE sy-ucomm.
    WHEN gc_back OR gc_ok.
*--recollect previous screen number
      GET PARAMETER ID text-020 FIELD lv_no.
      lv_dynnr = lv_no.
      LEAVE TO SCREEN lv_dynnr.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0800  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0900 INPUT.

  CLEAR : lv_no, lv_dynnr.
  CASE sy-ucomm.
    WHEN gc_back OR gc_ok.
*--recollect previous screen number
      GET PARAMETER ID text-020 FIELD lv_no.
      lv_dynnr = lv_no.
      LEAVE TO SCREEN lv_dynnr.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SPLIT_HU  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE split_hu INPUT.

  DATA: ls_label_content TYPE zsits_label_content,
        lv_exidv         TYPE exidv,
        lv_barcode       TYPE string,
        lv_uname         TYPE xubname,
        lt_param         TYPE STANDARD TABLE OF bapiparam,
        lt_return_user   TYPE STANDARD TABLE OF bapiret2,
        lv_barcode1      TYPE string.

  CLEAR : ls_label_content ,gv_exidv,gv_barcode1,
          lv_exidv, gs_return, lv_barcode1, gv_flg_us.
  CREATE OBJECT go_hu.

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

*--Read the HU number enter one is with Prefix or not
*--If not prefix of HU number then add Prefix with below code
*--Create Class Object for validation

  IF gv_flg_us = abap_false.
    CALL METHOD go_hu->hubarcode_value
      EXPORTING
        iv_exidv    = gv_barcode
      IMPORTING
        ev_hunumber = gv_barcode1.

*REad the barcode
    CALL METHOD zcl_mde_barcode=>disolve_barcode
      EXPORTING
        iv_barcode       = gv_barcode1
        iv_werks         = ' '
      IMPORTING
        es_label_content = ls_label_content.

    IF ls_label_content-zzhu_exid IS INITIAL.
      RETURN.
    ENDIF.
    gv_exidv = ls_label_content-zzhu_exid .
*    ****************
  ELSE.
    lv_barcode = gv_barcode.
    CALL FUNCTION 'ZWM_HU_VALIDATE'
      EXPORTING
        iv_barcode       = lv_barcode
      IMPORTING
        ev_exidv         = lv_exidv
        es_return        = gs_return
        ev_barcode       = lv_barcode1
        es_label_content = ls_label_content.

    IF lv_exidv IS NOT INITIAL.
      gv_exidv = lv_exidv.
    ENDIF.
    CLEAR: lv_barcode.
  ENDIF.




ENDMODULE.
