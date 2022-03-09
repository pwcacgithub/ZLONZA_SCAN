
*&---------------------------------------------------------------------*
*&      Module  SPLIT_HU  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE split_hu INPUT.
  DATA: ls_label_content TYPE zsits_label_content.
*--Checking if the entered HU number is with Prefix(Scanned) or without prefix(manually entered)
*--If manually entred add prefix to the HU number
*--Create Class Object for validation

  IF gv_hu IS NOT INITIAL.
    CREATE OBJECT go_hu.
    CALL METHOD go_hu->hubarcode_value
      EXPORTING
        iv_exidv    = gv_hu
      IMPORTING
        ev_hunumber = gv_hu.
*Read the barcode
    CALL METHOD zcl_mde_barcode=>disolve_barcode
      EXPORTING
        iv_barcode       = gv_hu
        iv_werks         = ' '
      IMPORTING
        es_label_content = ls_label_content.

    IF ls_label_content-zzhu_exid IS INITIAL.
      RETURN.
    ENDIF.
    gs_hu-exidv = ls_label_content-zzhu_exid .
  ENDIF.
ENDMODULE.

MODULE split_hu_lower INPUT.
  CLEAR : ls_label_content.
*--Barcode Prefix value for HU
  CALL METHOD go_hu->hubarcode_value
    EXPORTING
      iv_exidv    = gv_lbarcode
    IMPORTING
      ev_hunumber = gv_lbarcode.
*REad the barcode
  CALL METHOD zcl_mde_barcode=>disolve_barcode
    EXPORTING
      iv_barcode       = gv_lbarcode
      iv_werks         = ' '
    IMPORTING
      es_label_content = ls_label_content.

  IF ls_label_content-zzhu_exid IS INITIAL.
    RETURN.
  ENDIF.

  gv_exidv = ls_label_content-zzhu_exid .
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

*--Based on OK system command it will check
  CASE sy-ucomm.
*--Go to next screen.
    WHEN gc_next OR gc_f5."NEXT
      "Screen is not being used QA status will not be updated via scan
    WHEN gc_save OR gc_f8.
      IF gs_hu-exidv IS INITIAL.
        RETURN.
      ENDIF.

      gs_vekp-zzrep_sample_insi = gv_rep.
      gs_vekp-zztruck = gv_truck.
      gs_vekp-zztemp_reco = gv_zztemp_reco.
      gs_vekp-zztemp_rec_numb = gv_zztemp_rec_numb.

      PERFORM update.
      IF sy-subrc = 0.
        lv_msgid = gc_msgid.
        lv_msgno = gc_msgno3.
        lv_msgv1 = gs_hu-exidv.
        "Display Message
        PERFORM error_message USING lv_msgid lv_msgno lv_msgv1.
        CLEAR:gs_hu,gv_qa_status,gv_qa_reason,gv_rep,gv_zztemp_reco,
        gv_truck,gv_zztemp_rec_numb,gs_hu,gs_vekp,ls_zl_vekp_cust_upd,ls_zl_vekp_cust_upd_x.
      ENDIF.

*--Go back to main screen or leave program
    WHEN gc_quit OR gc_f2.
      CLEAR:gs_hu,gv_qa_status,gv_qa_reason,gv_rep,gv_zztemp_reco,
      gv_truck,gv_zztemp_rec_numb,gs_hu,gs_vekp.
      LEAVE PROGRAM.
    WHEN gc_back OR gc_f3.
      LEAVE TO SCREEN 0.
    WHEN gc_enter OR gc_f9.
      PERFORM validations.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  VALIDATIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validations.

  CONSTANTS : lc_msgno  TYPE msgno VALUE '001',
              lc_msgno1 TYPE msgno VALUE '139',
              lc_msgno2 TYPE msgno VALUE '140'.

  DATA :     lo_author TYPE REF TO zcl_auth_check,
             ls_return TYPE bapiret2.
  DATA : lv_msgv1 TYPE msgv1,
         lv_msgno TYPE msgno.

  DATA : lv_werks TYPE werks_d.
  DATA : lv_venum TYPE venum.
  CREATE OBJECT lo_author.
  IF gs_vekp-exidv EQ gs_hu-exidv.
    RETURN.
  ENDIF.

  SELECT SINGLE *
      FROM vekp INTO gs_vekp WHERE exidv = gs_hu-exidv.

  IF sy-subrc <> 0."Invalid HU number
    lv_msgid = gc_msgid.
    lv_msgno = lc_msgno.
    lv_msgv1 = gs_hu-exidv.
    PERFORM error_message USING lv_msgid lv_msgno lv_msgv1.
    CLEAR: gv_hu.
  ELSE.
    SELECT venum FROM vekp INTO lv_venum UP TO 1 ROWS
       WHERE exidv  = gs_hu-exidv.
      ENDSELECT.
      IF sy-subrc EQ 0.
        SELECT werks INTO lv_werks FROM vepo UP TO 1 ROWS
           WHERE venum = lv_venum
          and velin  = '1'.
        ENDSELECT.
        IF lv_werks IS NOT INITIAL.
*--check User Authorization check on Plant level.
          CALL METHOD lo_author->auth_check_plant
            EXPORTING
              iv_werks    = lv_werks
              iv_activity = '02'
            RECEIVING
              es_bapiret2 = ls_return.

          IF ls_return IS NOT INITIAL.
            CLEAR : lv_msgv1.
            lv_msgv1 = ls_return-message_v1.
            lv_msgno = ls_return-number.
*--Show an error message for Authorization for User
            PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1.
          ENDIF.
          CLEAR : ls_return.

        ENDIF.
      ENDIF.

      gv_rep = gs_vekp-zzrep_sample_insi.
      gv_zztemp_reco = gs_vekp-zztemp_reco.
      gv_truck = gs_vekp-zztruck.
      gv_zztemp_rec_numb = gs_vekp-zztemp_rec_numb.

    ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ERROR_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_MSGID  text
*      -->P_LV_MSGNO  text
*      -->P_LV_MSGV1  text
*----------------------------------------------------------------------*
FORM error_message  USING    p_lv_msgid TYPE msgid
                             p_lv_msgno TYPE msgno
                             p_lv_msgv1 TYPE msgv1.

  DATA      : lv_prevno TYPE sy-dynnr,
              lv_msgid  TYPE msgid.

  CONSTANTS : lc_msgno1  TYPE msgno  VALUE '138',
              lc_msgno2  TYPE msgno  VALUE '030',
              lc_msgno3  TYPE msgno  VALUE '023',
              lc_initial TYPE char1 VALUE '100'.

*--Call error message screen with message
*--Set Message id
  SET PARAMETER ID text-001 FIELD p_lv_msgid.
*--Set Message No
  SET PARAMETER ID text-002 FIELD p_lv_msgno.
*--Set Message variable
  SET PARAMETER ID text-003 FIELD p_lv_msgv1.
*--Set Message for screen number call back
  CLEAR : lv_prevno.
  lv_prevno = sy-dynnr.
*--Change if the successful message go back to initial screen
  IF p_lv_msgno = lc_msgno1.
    lv_prevno = lc_initial.
  ENDIF.

  SET PARAMETER ID text-004 FIELD lv_prevno.

*--Call Display message screen
  CALL SCREEN 300.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update .


  DATA : lt_return             TYPE bapiret2_t.

  CLEAR : ls_zl_vekp_cust_upd,ls_zl_vekp_cust_upd_x.

  IF gv_rep IS NOT INITIAL.
    gs_vekp-zzrep_sample_insi = abap_true.
  ENDIF.
  gs_vekp-zztruck = gv_truck.
  gs_vekp-zztemp_reco = gv_zztemp_reco.
  gs_vekp-zztemp_rec_numb = gv_zztemp_rec_numb.

  " Update Custom Fields
  ls_zl_vekp_cust_upd-venum = gs_vekp-venum.
  ls_zl_vekp_cust_upd-exidv = gs_vekp-exidv.
  ls_zl_vekp_cust_upd-zztruck = gs_vekp-zztruck.
  ls_zl_vekp_cust_upd-zzrep_sample_insi = gs_vekp-zzrep_sample_insi.
  ls_zl_vekp_cust_upd-zztemp_reco = gs_vekp-zztemp_reco.
  ls_zl_vekp_cust_upd-zztemp_rec_numb = gs_vekp-zztemp_rec_numb.

  "Mark fields to be updated
  ls_zl_vekp_cust_upd_x-venum   = 'X'.
  ls_zl_vekp_cust_upd_x-exidv   = 'X'.
  ls_zl_vekp_cust_upd_x-zztruck   = 'X'.
  ls_zl_vekp_cust_upd_x-zzrep_sample_insi   = 'X'.
  ls_zl_vekp_cust_upd_x-zztemp_reco   = 'X'.
  ls_zl_vekp_cust_upd_x-zztemp_rec_numb   = 'X'.


  CALL FUNCTION 'ZL_VEKP_CUST_UPD'
    EXPORTING
      is_vekp_cust_upd   = ls_zl_vekp_cust_upd
      is_vekp_cust_upd_x = ls_zl_vekp_cust_upd_x
    IMPORTING
      et_return          = lt_return
    EXCEPTIONS
      invalid_hu         = 1
      invalid_qa         = 2
      invalid_reason     = 3
      invalid_temp       = 4
      invalid_picktxt    = 5
      hu_missing         = 6
      lock_error         = 7
      update_error       = 8
      OTHERS             = 9.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  DATA : lv_no     TYPE dynnr,
         lv_dynnr  TYPE sy-dynnr,
         lv_mesgno TYPE msgno.

  CONSTANTS : lc_zero TYPE char1 VALUE '0'.
  CLEAR : lv_no, lv_dynnr.
  CASE sy-ucomm.
    WHEN gc_back3 OR gc_ok.
*--recollect previous screen number
      GET PARAMETER ID text-004 FIELD lv_no.
      GET PARAMETER ID text-002 FIELD lv_mesgno.
      lv_dynnr = lv_no.
*--Incase of screen no zero means successful message then leave program
      IF lv_no = lc_zero.
        CLEAR gv_hu.
        LEAVE TO SCREEN 100.
      ELSEIF lv_mesgno = '138'.
        CLEAR : gv_hu,gv_qa_status,gv_qa_reason,gv_rep,gv_zztemp_reco,gv_zztemp_rec_numb,gv_truck,gs_vekp.
        LEAVE TO SCREEN 100.
      ELSEIF lv_mesgno = '151' OR lv_mesgno =  '152'.
        LEAVE TO SCREEN 100.
      ELSEIF lv_mesgno = '149' OR lv_mesgno =  '150'.
        LEAVE TO SCREEN 200.
      ELSE.
*--another zero status move to previous screen only
        LEAVE TO SCREEN 100.
      ENDIF.

  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  VALIDATION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validation INPUT.
*--validate input field value
  PERFORM validations .
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  TEMP_REC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE temp_rec INPUT.

  DATA : ls_zltemp_reco_txt TYPE zltemp_reco_txt.
  CLEAR : ls_zltemp_reco_txt.
  IF gv_zztemp_reco IS NOT INITIAL.
    SELECT SINGLE * FROM zltemp_reco_txt INTO ls_zltemp_reco_txt WHERE zztemp_reco = gv_zztemp_reco.
      IF sy-subrc NE 0.
        lv_msgid = gc_msgid.
        lv_msgno = gc_msgno9.
        lv_msgv1 = gs_hu-exidv.
        "Display Message
        PERFORM error_message USING lv_msgid lv_msgno lv_msgv1.
      ENDIF.
    ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE sy-ucomm.
    WHEN gc_back2 OR gc_f3."*--Go back to previous screen.
      LEAVE TO SCREEN 0.
    WHEN gc_quit OR gc_f2. " *--Go back to main screen or leave program
      CLEAR:gs_hu,gv_qa_status,gv_qa_reason,gv_rep,gv_zztemp_reco,
        gv_truck,gv_zztemp_rec_numb,gs_hu,gs_vekp.
      LEAVE PROGRAM.
    WHEN gc_save OR gc_f8.
      "Begin of changes NAHMED1 28.8.2019
      PERFORM validations.
      PERFORM vaidate_input.
      "End of changes NAHMED1 28.8.2019

      " Validate for Rep. Sample inside,Temp. recorder,Temp. recorder Number and Truck number
      PERFORM update.
      IF sy-subrc = 0.
        lv_msgid = gc_msgid.
        lv_msgno = gc_msgno3.
        lv_msgv1 = gs_hu-exidv.
        "Display Message
        PERFORM error_message USING lv_msgid lv_msgno lv_msgv1.
      ELSE.
        lv_msgid = gc_msgid.
        lv_msgno = gc_msgno6.
        lv_msgv1 = gs_hu-exidv.
        "Display Message
        PERFORM error_message USING lv_msgid lv_msgno lv_msgv1.
      ENDIF.
      CLEAR:gs_hu,gv_qa_status,gv_qa_reason,gv_rep,gv_zztemp_reco,
      gv_truck,gv_zztemp_rec_numb,gs_hu.
    WHEN gc_enter OR gc_f5.
      PERFORM vaidate_input.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VAIDATE_INPUT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE vaidate_input INPUT.
  PERFORM vaidate_input.
ENDMODULE.
