*&---------------------------------------------------------------------*
*&  Include           MZITSEWM_PHYS_INVO01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  GET_USER_PROFILE  OUTPUT
*&---------------------------------------------------------------------*
*       Obtain user profile
*----------------------------------------------------------------------*
MODULE get_user_profile OUTPUT.

  PERFORM frm_get_user_profile.

ENDMODULE.                 " GET_USER_PROFILE  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INITIAL_LOG  OUTPUT
*&---------------------------------------------------------------------*
*       Create initial log
*----------------------------------------------------------------------*
MODULE initial_log OUTPUT.

  CLEAR:
    zsits_scan_dynp-zzwminvdoc,
    zsits_scan_dynp-zzbarcode,"zsits_scan_dynp-zzsu,
    zsits_scan_dynp-zzbchmtr,
    zsits_scan_dynp-zzquantity,
    zsits_scan_dynp-zzsbin,
    zsits_scan_dynp-zzsuom.
*Create GUID
  IF o_log IS INITIAL.
    CREATE OBJECT o_log
      EXPORTING
        iv_scan_code = sy-tcode.
  ENDIF.

ENDMODULE.                 " INITIAL_LOG  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       STATUS_9000
*----------------------------------------------------------------------*
MODULE status_9000 OUTPUT.

  SET PF-STATUS 'STATUS_9000'.

ENDMODULE.                 " STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9100  OUTPUT
*&---------------------------------------------------------------------*
*       STATUS_9100
*----------------------------------------------------------------------*
MODULE status_9100 OUTPUT.

  SET PF-STATUS 'STATUS_9100'.

ENDMODULE.                 " STATUS_9100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_9300  OUTPUT
*&---------------------------------------------------------------------*
*       STATUS_9300
*----------------------------------------------------------------------*
MODULE status_9300 OUTPUT.

  SET PF-STATUS 'STATUS_9300'.

ENDMODULE.                 " STATUS_9300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_set_cursor OUTPUT.

  CHECK v_cursor_field IS NOT INITIAL.

  SET CURSOR FIELD v_cursor_field.

ENDMODULE.                 " PBO_SET_CURSOR  OUTPUT
