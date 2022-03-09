*&---------------------------------------------------------------------*
*&  Include           DZH01I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  DATA: lv_msg_id TYPE msgid,
        lv_msg_no TYPE msgno,
        lv_msg_v1 TYPE msgv1.

*--Based on OK system command it will check
  CASE sy-ucomm.
    WHEN gc_back OR gc_f3. "'BACK'.
      LEAVE PROGRAM.
    WHEN gc_f2. "'CLR' OR 'F2'.
      CLEAR : gs_hu.
    WHEN gc_enter. "'ENTER'.
      IF gv_flg_us = abap_true
       AND gs_return-type = 'E'.
        lv_msg_id = gs_return-id.
        lv_msg_no = gs_return-number.
        lv_msg_v1 = gs_return-message_v1.
        CLEAR : gv_barcode .
        PERFORM error_message USING lv_msg_id lv_msg_no lv_msg_v1.
      ENDIF.
*     Perform validation on ENTER
      IF gs_hu-exidv IS NOT INITIAL.
        PERFORM validation CHANGING gs_hu.
      ENDIF.
    WHEN gc_next. "'NEXT'.
      IF gv_flg_us = abap_true
       AND gs_return-type = 'E'.
        lv_msg_id = gs_return-id.
        lv_msg_no = gs_return-number.
        lv_msg_v1 = gs_return-message_v1.
        CLEAR : gv_barcode .
        PERFORM error_message USING lv_msg_id lv_msg_no lv_msg_v1.
      ENDIF.
*     Perform validation on ENTER
      CLEAR : gt_exidv.
*--Call screen 200 to go to next screen
      IF gs_hu-exidv IS NOT INITIAL.
        PERFORM validation CHANGING gs_hu.
        CALL SCREEN 0200.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  DATA : lv_msgv1 TYPE msgv1.
  DATA: lv_msgidl TYPE msgid,
        lv_msgnol TYPE msgno,
        lv_msgv1l TYPE msgv1.
  CONSTANTS : lc_msgno8 TYPE msgno VALUE '014'.

*--Check User command
  CASE sy-ucomm.

*--leave to screen Back
    WHEN gc_back.
      REFRESH : gt_final, gt_exidv.
      CLEAR   : gv_lbarcode, gv_exidv.
      LEAVE TO SCREEN 100.

    WHEN gc_clr.
*--clear HU details
      CLEAR : gv_lbarcode, gv_exidv.

    WHEN gc_ent OR gc_save.
*--Validate Lower Level HU's and Save
      IF gv_flg_us = abap_true
      AND gs_return-type = 'E'.
        lv_msgidl = gs_return-id.
        lv_msgnol = gs_return-number.
        lv_msgv1l = gs_return-message_v1.
        CLEAR : gv_barcode .
        PERFORM error_message USING lv_msgidl lv_msgnol lv_msgv1l.
      ENDIF.
*     Perform validation on ENTER or save
      IF gv_exidv IS NOT INITIAL.
        PERFORM validate_lowerhu USING gs_hu
                                       gv_exidv.
      ENDIF.
    WHEN gc_pgdn. "'PGDN'.
*--Pagedown for next screen
      PERFORM next_screen_pagedown.

    WHEN gc_pgup. "'PGUP'.
*--Pageup for back screen
      PERFORM pagup_previousscreen.

    WHEN gc_ch1 OR gc_ch2 OR gc_ch3. "'CH1' OR 'CH2' OR 'CH3'.
*--Check box selection validtion
      PERFORM chekbox_validation.

    WHEN gc_rem.
*--Remove selected check box entery box screen
      PERFORM remove_selctedentry.

    WHEN gc_unpack. "'UNPACK'.
*--Unpack box on Pallet validation and Pack on pallet
      IF gt_final[] IS NOT INITIAL.
        PERFORM unpackbox_pallethu TABLES gt_final.
      ELSE.
        CLEAR : lv_msgv1.
*--Show an error message if no lower level HU's
        PERFORM error_message USING gc_msgid
                                    lc_msgno8
                                    lv_msgv1.
      ENDIF.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0200  INPUT
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
* BEGIN: EICR:603155 SDHANANJAY - Project ONE: HC & DFS Implementation US & MX
        REFRESH : gt_final, gt_exidv.
        CLEAR   : gv_lbarcode, gv_exidv, GS_HU, GV_BARCODE.
        LEAVE TO SCREEN 100.
* END: EICR:603155 SDHANANJAY - Project ONE: HC & DFS Implementation US & MX
      ELSE.
*--another zero status move to previous screen only
        LEAVE TO SCREEN lv_dynnr.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validation INPUT.

*--if user command back or F3 leave program
  IF sy-ucomm EQ gc_back OR
     sy-ucomm EQ gc_f3.
    LEAVE PROGRAM.
  ENDIF.

*--if user command F2 clear HU details
  IF sy-ucomm EQ gc_f2.
    CLEAR : gv_barcode, gs_hu.
  ENDIF.

*--validate input field value
  IF sy-ucomm EQ gc_enter.
    IF gv_flg_us = abap_true
        AND gs_return-type = 'E'.
      lv_msg_id = gs_return-id.
      lv_msg_no = gs_return-number.
      lv_msg_v1 = gs_return-message_v1.
      CLEAR : gv_barcode .
      PERFORM error_message USING lv_msg_id lv_msg_no lv_msg_v1.
    ENDIF.
    IF gs_hu-exidv IS NOT INITIAL.
      PERFORM validation CHANGING gs_hu.
    ENDIF.
  ENDIF.


ENDMODULE.                 " VALIDATION  INPUT
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

  CLEAR : ls_label_content ,gs_hu,gv_barcode1,
          lv_exidv, gs_return, lv_barcode1 , gv_flg_us .
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
    gs_hu-exidv = ls_label_content-zzhu_exid .
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
      gs_hu-exidv = lv_exidv.
    ENDIF.
    CLEAR: lv_barcode.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SPLIT_HU_LOWER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE split_hu_lower INPUT.

  CLEAR : ls_label_content ,gv_exidv,gv_barcode1,lv_barcode1,
          lv_exidv, gs_return, lv_barcode1 , gv_flg_us ,lt_param,lt_return_user .
  CREATE OBJECT go_hu.

  lv_uname = sy-uname.
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username  = lv_uname
    TABLES
      parameter = lt_param
      return    = lt_return_user.

  READ TABLE lt_param ASSIGNING FIELD-SYMBOL(<lfs_param1>)
  WITH KEY parid = 'ZGELATIN'.
  IF sy-subrc = 0 AND <lfs_param1>-parva = abap_true.
    gv_flg_us = abap_true.
  ENDIF.

*--Read the HU number enter one is with Prefix or not
*--If not prefix of HU number then add Prefix with below code
*--Create Class Object for validation

  IF gv_flg_us = abap_false.
    CALL METHOD go_hu->hubarcode_value
      EXPORTING
        iv_exidv    = gv_lbarcode
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
    lv_barcode = gv_lbarcode.
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
