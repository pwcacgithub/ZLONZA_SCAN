*&---------------------------------------------------------------------*
*&  Include           MZITSENEWTRAN_O01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PBO_INITIALIZATION  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_initialization OUTPUT.

  SET PF-STATUS 'SCAN_STATUS'.

  PERFORM frm_init_log.

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
*&      Module  PBO_GET_USER_PROFILE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_GET_USER_PROFILE OUTPUT.
  PERFORM get_user_profile.
ENDMODULE.                 " PBO_GET_USER_PROFILE  OUTPUT
