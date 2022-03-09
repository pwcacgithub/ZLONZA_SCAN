*----------------------------------------------------------------------*
***INCLUDE MZPPE0163_WMPGIO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PBO_INITIALIZATION  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_initialization OUTPUT.

  SET PF-STATUS 'SCAN_STATUS'.

ENDMODULE.                 " PBO_INITIALIZATION  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_set_cursor OUTPUT.

  CHECK iv_cursor_field IS NOT INITIAL.

  SET CURSOR FIELD iv_cursor_field.

ENDMODULE.                 " PBO_SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_LOG_INITIALIZATION  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_log_initialization OUTPUT.
  PERFORM frm_init_log.
ENDMODULE.                 " PBO_LOG_INITIALIZATION  OUTPUT
*----------------------------------------------------------------------*
*  MODULE get_user_profile OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE get_user_profile OUTPUT.
  PERFORM frm_get_user_profile.
ENDMODULE.                 " GET_USER_PROFILE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_FIELD_QTY  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_field_qty OUTPUT.
*  If user has authorization to change Quantity, set field Qty as an input field
  IF v_changeqty = abap_true.
    LOOP AT SCREEN.
      IF screen-group1 = 'GP1'.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " PBO_FIELD_QTY  OUTPUT
