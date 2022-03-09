*&---------------------------------------------------------------------*
*&  Include           MZITSENEWTRAN_F01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FRM_TRAN_CODE_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZSPP_SCAN_DYNP_ZZSCAN_CODE  text
*----------------------------------------------------------------------*
FORM frm_tran_code_check  CHANGING  cv_scan_code TYPE zzscan_code.

  CHECK cv_scan_code IS NOT INITIAL.

*--Transaction ZSHUM is input as ZSHUMNNNN. NNNN denotes the activity
*--to be performed. So ZSHUMNNNN is trimmed and process code NNNN
*--is sent to ZSHUM for further process.
  IF cv_scan_code(5) EQ 'ZSHUM'.
    DATA: lv_pid TYPE tpara-paramid.
    CONCATENATE 'ZPC' sy-uname INTO lv_pid.
    SET PARAMETER ID lv_pid FIELD cv_scan_code+5(4).
    cv_scan_code = cv_scan_code(5).
  ENDIF.

  IF zcl_its_utility=>tran_check( cv_scan_code ) = abap_true.

    CALL TRANSACTION cv_scan_code.

  ELSE.

    zcl_its_utility=>message_display( ).

    CLEAR cv_scan_code.

  ENDIF.

ENDFORM.                    " FRM_TRAN_CODE_CHECK
*&---------------------------------------------------------------------*
*&      Form  FRM_CHECK_PLANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZSITS_USER_PROFILE_ZZWERKS  text
*----------------------------------------------------------------------*
FORM frm_check_plant  CHANGING cv_plant TYPE zd_werks.

  DATA: lv_with_message TYPE boolean.

* Check input plant does whether exist or not
  IF zcl_common_utility=>plant_validate( cv_plant ) = abap_false.

    lv_with_message = abap_true.

  ENDIF.
* log what user input
  CALL METHOD io_log->log_message_add
    EXPORTING
      iv_object_id    = zcl_its_utility=>gc_objid_plant    " = 011
      iv_content      = cv_plant
      iv_with_message = lv_with_message.

  IF lv_with_message = abap_true.

    iv_validation_fail = abap_true.

* Display error message
    CALL METHOD zcl_its_utility=>message_display( ).

    CLEAR:cv_plant.

  ENDIF.

ENDFORM.                    " FRM_CHECK_PLANT
*&---------------------------------------------------------------------*
*&      Form  FRM_CHECK_WAREHOUSE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZSITS_USER_PROFILE_ZZLGNUM  text
*----------------------------------------------------------------------*
FORM frm_check_warehouse  CHANGING cv_warehouse TYPE zd_lgnum.

  DATA: lv_with_message TYPE boolean.

* Check input warehouse# does whether exist or not
  IF zcl_common_utility=>warehouse_validate( cv_warehouse ) = abap_false.  " AS

    lv_with_message = abap_true.

  ENDIF. "AS
* log what user input
  CALL METHOD io_log->log_message_add
    EXPORTING
      iv_object_id    = zcl_its_utility=>gc_objid_warehouse    " = 012
      iv_content      = cv_warehouse
      iv_with_message = lv_with_message.

  IF lv_with_message = abap_true.

    iv_validation_fail = abap_true.

* Display error message
    CALL METHOD zcl_its_utility=>message_display( ).

    CLEAR cv_warehouse.

  ENDIF.
ENDFORM.                    " FRM_CHECK_WAREHOUSE
*&---------------------------------------------------------------------*
*&      Form  FRM_PRE_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_ERROR  text
*----------------------------------------------------------------------*
FORM frm_pre_save CHANGING cv_error TYPE boolean.

  DATA: lv_dummy TYPE string.

  cv_error =  abap_true.

  IF zsits_user_profile-zzlgnum IS INITIAL AND
     zsits_user_profile-zzwerks IS INITIAL.
*Plant or Warehouse# could not be blank neither!
    MESSAGE e024 INTO lv_dummy.

    RETURN.

  ENDIF.

  IF zsits_user_profile-zzlgnum IS NOT INITIAL AND
     zsits_user_profile-zzwerks IS NOT INITIAL.
*You could not logon ITS both for plant & warehouse
    MESSAGE e025 INTO lv_dummy.

    RETURN.

  ENDIF.

  IF zsits_user_profile-zzlgnum IS NOT INITIAL.
* Authority check on warehouse
    AUTHORITY-CHECK OBJECT 'L_LGNUM'
         ID 'LGNUM' FIELD zsits_user_profile-zzlgnum
         ID 'LGTYP' DUMMY.
    IF sy-subrc <> 0.
*You are not authorized to work in warehouse &1
      MESSAGE e202(lxvas) WITH zsits_user_profile-zzlgnum INTO lv_dummy.

      RETURN.

    ENDIF.
  ENDIF.

  IF zsits_user_profile-zzwerks IS NOT INITIAL.
* Authority check on plant
    AUTHORITY-CHECK OBJECT 'M_MSEG_WWA'
             ID 'ACTVT' FIELD '*'
             ID 'WERKS' FIELD zsits_user_profile-zzwerks.
    IF sy-subrc <> 0.
*You have no authorization for this transaction in plant &
      MESSAGE e120(m7) WITH zsits_user_profile-zzwerks INTO lv_dummy.

      RETURN.

    ENDIF.
  ENDIF.

  cv_error = abap_false.

ENDFORM.                    " FRM_PRE_SAVE
*&---------------------------------------------------------------------*
*&      Form  FRM_LOGON_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_CODE  text
*----------------------------------------------------------------------*
FORM frm_logon_process  USING    iv_code TYPE sy-ucomm.

  DATA: lv_error TYPE boolean.

* Final Check before save
  PERFORM frm_pre_save CHANGING lv_error.

  IF lv_error IS INITIAL.

* Save the data
    PERFORM frm_save CHANGING lv_error.

  ENDIF.

  IF lv_error IS NOT INITIAL.
* Add the action to the  log with message
    CALL METHOD io_log->log_message_add
      EXPORTING
        iv_object_type  = zcl_its_utility=>gc_objtp_command
        iv_content      = iv_code
        iv_with_message = abap_true.

* Display error message
    CALL METHOD zcl_its_utility=>message_display( ).

  ELSE.
* Add the action to the  log
    CALL METHOD io_log->log_message_add
      EXPORTING
        iv_object_type = zcl_its_utility=>gc_objtp_command
        iv_content     = iv_code.
*
    CLEAR x_profile. " We should refresh the current login location

    CALL SCREEN 100.

  ENDIF.

ENDFORM.                    " FRM_LOGON_PROCESS
*&---------------------------------------------------------------------*
*&      Form  FRM_INIT_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_init_log .

  IF io_log IS INITIAL.
    CREATE OBJECT io_log
      EXPORTING
        iv_scan_code = sy-tcode.
  ENDIF.

ENDFORM.                    " FRM_INIT_LOG
*&---------------------------------------------------------------------*
*&      Form  FRM_CURSOR_DETERMINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_cursor_determine .

* if validation faiule, the cursor should be processed already. not need
* to
  CHECK iv_validation_fail = abap_false.

  GET CURSOR FIELD iv_cursor_field.

  CASE iv_cursor_field.
    WHEN 'ZSITS_USER_PROFILE-ZZWERKS'.
      iv_cursor_field = 'ZSITS_USER_PROFILE-ZZLGNUM'.
    WHEN 'ZSITS_USER_PROFILE-ZZLGNUM'.
      iv_cursor_field = 'BTN_SAVE'.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " FRM_CURSOR_DETERMINE

*&---------------------------------------------------------------------*
*&      Form  FRM_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_user_command .
  DATA: lv_code  TYPE sy-ucomm.

  IF iv_validation_fail = abap_true.

    CALL METHOD zcl_its_utility=>message_display( ).

  ELSE.

    lv_code = ok_code.

    CLEAR ok_code.

    CASE lv_code.
      WHEN zcl_its_utility=>gc_okcode_save.
* Set the parameter for logon
        PERFORM frm_logon_process USING lv_code.

      WHEN zcl_its_utility=>gc_okcode_logoff.

        CALL METHOD zcl_its_utility=>log_off( CHANGING co_log = io_log ).

    ENDCASE.

  ENDIF.
ENDFORM.                    " FRM_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  FRM_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_save CHANGING cv_error TYPE boolean.

*Save the LGN/WRK to the user profile of the log user, and the buffer
*   as well
*----------------------------------------------------------------------
  CALL METHOD zcl_its_utility=>set_user_profile
    EXPORTING
      is_user_profile = zsits_user_profile
    RECEIVING
      rv_result       = cv_error.

ENDFORM.                    " FRM_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_USER_PROFILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_user_profile .

  IF x_profile IS INITIAL.
    CALL METHOD zcl_its_utility=>get_user_profile
      RECEIVING
        rs_user_profile = x_profile.

    IF x_profile-zzwerks IS NOT INITIAL.
      x_profile-zzcurr_loc = x_profile-zzwerks .
    ELSEIF  x_profile-zzlgnum IS NOT INITIAL.
      x_profile-zzcurr_loc = x_profile-zzlgnum.
    ELSE.
      CALL SCREEN 200.
    ENDIF.

  ENDIF.

ENDFORM.                    " GET_USER_PROFILE
