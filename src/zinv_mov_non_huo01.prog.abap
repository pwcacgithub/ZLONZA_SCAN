*&---------------------------------------------------------------------*
*&  Include           ZINV_MOV_NON_HUO01
*&---------------------------------------------------------------------*
************************************************************************
* Program ID:                   ZINV_MOV_NON_HU
* Program Title:                Non HU Movements
* Created By:
* Creation Date:
* Capsugel / Lonza RICEFW ID:   S0096
* Description:                  Non HU Inventory movements using SCAN
* Tcode     :                   ZNONHU
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* Initial version
*&---------------------------------------------------------------------*
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
  CHECK gv_cursor_field IS NOT INITIAL.

  SET CURSOR FIELD gv_cursor_field.
ENDMODULE.                 " PBO_SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_4000  OUTPUT
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE 4000_modify_screen OUTPUT.

  LOOP AT SCREEN.
    IF gv_button = 'B2B'.
      IF screen-name = 'ZSITS_SCAN_DYNP-ZZDESTLOC'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF gv_button = 'B2L'.
      IF screen-name = 'ZSITS_SCAN_DYNP-ZZDESTBIN'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " STATUS_4000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE modify_screen OUTPUT.

  LOOP AT SCREEN.
    IF gv_button = 'L2B'.
      IF screen-name = 'ZSITS_SCAN_DYNP-ZZSOURCEBIN'.
        screen-input = 0.
        MODIFY SCREEN.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PBO_GET_USR_DETAILS  OUTPUT
*&---------------------------------------------------------------------*
*    *-- Get the user profile details for Plant, Wrh. number
*----------------------------------------------------------------------*
MODULE pbo_get_usr_details OUTPUT.

  DATA: ls_usr_param TYPE zsits_user_profile,
        lo_util      TYPE REF TO zcl_its_utility.

  IF lo_util IS INITIAL.
    CREATE OBJECT lo_util
      EXPORTING
        iv_scan_code = sy-tcode.
  ENDIF.

*-- Get the user profile parameters
  CALL METHOD zcl_its_utility=>get_user_profile
    RECEIVING
      rs_user_profile = ls_usr_param.

  zsits_user_profile-zzwerks   = ls_usr_param-zzwerks.
  zsits_user_profile-zzlgnum   = ls_usr_param-zzlgnum.
  zsits_scan_dynp-zzsourcesloc = ls_usr_param-zzcurr_loc.

ENDMODULE.
