*&---------------------------------------------------------------------*
*&  Include           ZSUBDIVDE_TRANSO01
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
ENDMODULE.

MODULE status_9500 OUTPUT.
  SET PF-STATUS 'S9500'.
  GET CURSOR FIELD v_cursor_field.
ENDMODULE.                 " STATUS_9000  OUTPUT
