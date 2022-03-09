*&---------------------------------------------------------------------*
*&  Include           MZITSENEWTRAN_I01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PAI_TRAN_CODE_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_tran_code_check INPUT.

  PERFORM frm_tran_code_check CHANGING zsits_scan_dynp-zzscan_code.

ENDMODULE.                 " PAI_TRAN_CODE_CHECK  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_LOGOFF  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_logoff INPUT.

  CALL METHOD zcl_its_utility=>log_off( ).

ENDMODULE.                 " PAI_LOGOFF  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_USER_COMMAND_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_user_command INPUT.

  DATA: lv_code  TYPE sy-ucomm.



  lv_code = ok_code.

  CLEAR ok_code.

  CASE lv_code.
    WHEN gc_okcode_save.

      IF zsits_user_profile-zzwerks IS INITIAL AND zsits_user_profile-zzlgnum IS INITIAL.

        CALL METHOD zcl_its_utility=>message_display( ).

      ELSE.
* Set the parameter for logon
        PERFORM frm_logon_process USING lv_code.
      ENDIF.

    WHEN gc_okcode_logoff.

      CALL METHOD zcl_its_utility=>log_off( CHANGING co_log = io_log ).

    WHEN gc_okcode_upd_loc.

      CALL SCREEN 200.

    WHEN OTHERS.

  ENDCASE.


ENDMODULE.                 " PAI_USER_COMMAND_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_CHECK_PLANT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_plant INPUT.

  CLEAR iv_validation_fail.

  CHECK zsits_user_profile-zzwerks IS NOT INITIAL.

  PERFORM frm_check_plant CHANGING zsits_user_profile-zzwerks.

ENDMODULE.                 " PAI_CHECK_PLANT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_CHECK_WHNUM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_whnum INPUT.

  CLEAR iv_validation_fail.

  CHECK zsits_user_profile-zzlgnum IS NOT INITIAL.

  PERFORM frm_check_warehouse CHANGING zsits_user_profile-zzlgnum.

ENDMODULE.                 " PAI_CHECK_WHNUM  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI_CURSOR_DETERMINE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_cursor_determine INPUT.

  PERFORM frm_cursor_determine.

ENDMODULE.                 " PAI_CURSOR_DETERMINE  INPUT
