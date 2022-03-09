*----------------------------------------------------------------------*
***INCLUDE LZSCANF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FRM_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_user_command .

  DATA: lv_data TYPE sy-ucomm.

  lv_data = ok_code.

  CLEAR ok_code.

  CASE lv_data.
    WHEN gc_okcode_enter.
      LEAVE TO SCREEN 0.
    WHEN gc_okcode_yes.
      gv_confirm_result = 'Y'.
      LEAVE TO SCREEN 0.
    WHEN gc_okcode_no.
      gv_confirm_result = 'N'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " FRM_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  FRM_MODIFY_SCREEN_100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_modify_screen_100 .

  CONSTANTS: lc_grp_msg TYPE char3  VALUE 'NCO',
             lc_grp_cnf TYPE char3  VALUE 'CNF'.

  LOOP AT SCREEN.

    CHECK  screen-group1 = lc_grp_msg OR screen-group1 = lc_grp_cnf.

    IF gv_confirm_ind = abap_true.
      IF screen-group1 = lc_grp_msg.
        screen-invisible = gc_dynp_enable.
      ELSE.
        screen-invisible = gc_dynp_disable.
      ENDIF.
    ELSE.
      IF screen-group1 = lc_grp_msg.
        screen-invisible = gc_dynp_disable.
      ELSE.
        screen-invisible = gc_dynp_enable.
      ENDIF.

    ENDIF.

    MODIFY SCREEN.

  ENDLOOP.

  IF gv_confirm_ind = abap_true.
     SET CURSOR FIELD 'BTN_NO'.
  ELSE.
     SET CURSOR FIELD 'BTN_BACK'.
  ENDIF.

ENDFORM.                    " FRM_MODIFY_SCREEN_100
