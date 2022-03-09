*&---------------------------------------------------------------------*
*&  Include           DZH09I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       Act on user command
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  DATA: lv_msgid TYPE msgid,
        lv_msgno TYPE msgno,
        lv_msgv1 TYPE msgv1.

*--Based on OK system command it will check
  CASE sy-ucomm.
    WHEN gc_back OR gc_f3. "'BACK'.
      LEAVE PROGRAM. " Leave the scanning TCODE
    WHEN gc_clear . "Clears the HU number on the screen
      CLEAR : gs_hu,gv_barcode.
    WHEN gc_enter. "'ENTER'.
      IF gv_flg_us = abap_true
        AND gs_return-type = 'E'.
        lv_msgid = gs_return-id.
        lv_msgno = gs_return-number.
        lv_msgv1 = gs_return-message_v1.
        CLEAR : gv_barcode .
        PERFORM error_message USING lv_msgid lv_msgno lv_msgv1.
      ENDIF.
*     Perform validation on ENTER
      IF gs_hu-exidv IS NOT INITIAL.
        PERFORM validation CHANGING gs_hu.
      ENDIF.
    WHEN gc_delete. "DELETE
      IF gv_flg_us = abap_true
        AND gs_return-type = 'E'.
        lv_msgid = gs_return-id.
        lv_msgno = gs_return-number.
        lv_msgv1 = gs_return-message_v1.
        CLEAR : gv_barcode .
        PERFORM error_message USING lv_msgid lv_msgno lv_msgv1.
      ENDIF.
**--Call screen 200 to go to next screen
      IF gs_hu-exidv IS NOT INITIAL.
        PERFORM validation CHANGING gs_hu.
      ENDIF.

      IF gs_hu-exidv IS NOT INITIAL.
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
  CASE sy-ucomm.
    WHEN gc_back .
      LEAVE TO SCREEN 0.
    WHEN gc_yes.
*     Handle the HU deletion logic here
      PERFORM delete_hu USING gs_hu.
    WHEN gc_no." Go to screen 100
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
*     don't do anything here
  ENDCASE.


ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       Handle OK
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.



  CLEAR : gv_no.
  CASE sy-ucomm.
    WHEN gc_back OR gc_ok.
*--recollect previous screen number
      ##EXISTS
      GET PARAMETER ID gc_screen FIELD gv_no.
*navigate to the previous screen
      IF gv_no IS NOT  INITIAL.
        LEAVE TO SCREEN gv_no.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT
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
