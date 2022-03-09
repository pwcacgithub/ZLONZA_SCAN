*&---------------------------------------------------------------------*
*&  Include           MZITSEPICKINGO01
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       Status 9000
*----------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'S9000'.
  SET CURSOR FIELD v_cursor_field.
ENDMODULE.                 " STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9010  OUTPUT
*&---------------------------------------------------------------------*
*       Status 9010
*----------------------------------------------------------------------*
MODULE status_9010 OUTPUT.
  SET PF-STATUS 'S9010'.
  SET CURSOR FIELD v_cursor_field.
ENDMODULE.                 " STATUS_9010  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_USER_PROFILE  OUTPUT
*&---------------------------------------------------------------------*
*       Get user's profile
*----------------------------------------------------------------------*
MODULE get_user_profile OUTPUT.
  PERFORM get_user_profile.
ENDMODULE.                 " GET_USER_PROFILE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INITIAL_LOG  OUTPUT
*&---------------------------------------------------------------------*
*       Initial log
*----------------------------------------------------------------------*
MODULE initial_log OUTPUT.
*Create GUID
  IF o_log IS INITIAL.
    CREATE OBJECT o_log
      EXPORTING
        iv_scan_code = sy-tcode.
  ENDIF.
ENDMODULE.                 " INITIAL_LOG  OUTPUT
