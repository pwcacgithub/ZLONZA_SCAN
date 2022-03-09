*&---------------------------------------------------------------------*
*&  Include           MZITSEMTC_PUTAWAYO01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  GET_USER_PROFILE  OUTPUT
*&---------------------------------------------------------------------*

MODULE get_user_profile OUTPUT.
  PERFORM frm_get_user_profile.
ENDMODULE.                 " GET_USER_PROFILE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INITIAL_LOG  OUTPUT
*&---------------------------------------------------------------------*
MODULE initial_log OUTPUT.

  IF o_log IS INITIAL.
    CREATE OBJECT o_log
      EXPORTING
        iv_scan_code = sy-tcode.
  ENDIF.

ENDMODULE.                 " INITIAL_LOG  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET CURSOR FIELD v_cursor_field.
  SET PF-STATUS 'S9000'.
ENDMODULE.                 " STATUS_9000  OUTPUT
