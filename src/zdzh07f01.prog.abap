*&---------------------------------------------------------------------*
*&  Include           DZH07F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VALIDATIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validations .

  DATA: lv_msgv1    TYPE msgv1,
        lv_msgno    TYPE msgno,
        lv_return   TYPE bapiret2,
        lv_msgid    TYPE msgid,
        lv_invalide TYPE boolean,
        lv_vbeln    TYPE vbeln_vl,
        lv_vstel    TYPE vstel,
        lv_dummy    TYPE string.

  CONSTANTS:lc_msgno1 TYPE msgno VALUE '026',
            lc_msgno2 TYPE msgno VALUE '027',
            lc_msgno3 TYPE msgno VALUE '028'.

  IF go_hu IS NOT BOUND.
    CREATE OBJECT go_hu
      EXPORTING
        iv_vbeln = gs_hu-vbeln.
  ENDIF.

* validate delivery entered
  CALL METHOD go_hu->validate_delivery
    IMPORTING
      ev_return   = lv_return
    RECEIVING
      ev_invalide = lv_invalide.
  IF lv_invalide = abap_true OR lv_return IS NOT INITIAL.
    gv_error1 = abap_true.
  ELSEIF LV_INVALIDE <> ABAP_TRUE OR LV_RETURN IS INITIAL.
*Authorization check on Shipping point
* conver input delivery number to internal format
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input         = gs_hu-vbeln
     IMPORTING
       output        = lv_vbeln.
    SELECT SINGLE vbeln vstel
  FROM likp
  INTO (lv_vbeln,lv_vstel)
  WHERE vbeln = lv_vbeln.
    if sy-subrc = 0 and not lv_vstel is INITIAL.
      AUTHORITY-CHECK OBJECT 'V_LIKP_VST'
   ID 'ACTVT' FIELD '02'
   ID 'ACTVT' FIELD '03'
   ID 'VSTEL' FIELD lv_vstel.
      IF SY-SUBRC <> 0.
        gv_error1 = abap_true.
        MESSAGE e007(ZONE_O2C) WITH lv_vstel INTO lv_dummy.
        lv_return-type = sy-msgty.
        lv_return-id   = sy-msgid.
        lv_return-number = sy-msgno.
        lv_return-message_v1  = sy-msgv1.
        lv_return-message_v2  = sy-msgv2.
        lv_return-message_v3  = sy-msgv3.
        lv_return-message_v4  = sy-msgv4.
      ENDIF.
    endif.

** Validate for custom table entries.
* Check for Picking complete
  ELSEIF go_hu->check_picking( ) EQ abap_false.
    IF go_hu->check_wm_relevant( ) EQ abap_true.
      gv_error3 = abap_true.
    ENDIF.
  ENDIF.

* display error.
  IF gv_error1 IS NOT INITIAL.
    CLEAR : lv_msgv1.
    lv_msgv1 = gs_hu-vbeln.
    lv_msgno = lc_msgno1.
    IF lv_return IS NOT INITIAL.
*--Show an error message
      lv_msgno = lv_return-number.
      lv_msgv1 = lv_return-message_v1.
      lv_msgid = lv_return-id.
      PERFORM error_message USING  lv_msgid lv_msgno lv_msgv1.
    ELSE.
*--Show an error message
      PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1.
    ENDIF.

  ELSEIF gv_error3 IS NOT INITIAL.
    CLEAR : lv_msgv1.
    lv_msgv1 = gs_hu-vbeln.
    lv_msgno = lc_msgno3.
*--Show an error message
    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1.
  ELSE.
    gv_noerror = abap_true.
  ENDIF.
ENDFORM.                    " VALIDATIONS
*&---------------------------------------------------------------------*
*&      Form  ERROR_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GC_MSGID  text
*      -->P_LV_MSGNO  text
*      -->P_LV_MSGV1  text
*----------------------------------------------------------------------*
FORM error_message  USING  p_gc_msgid TYPE msgid
                           p_lv_msgno TYPE msgno
                           p_gv_msgv1 TYPE msgv1.
  DATA      : lv_prevno TYPE sy-dynnr,
              lv_msgid  TYPE msgid.

  CONSTANTS : lc_msgno1  TYPE msgno  VALUE '029',
              lc_msgno2  TYPE msgno  VALUE '030',
              lc_msgno3  TYPE msgno  VALUE '023',
              lc_initial TYPE char1 VALUE '0'.

*--Call error message screen with message
*--Set Message id
  SET PARAMETER ID text-001 FIELD p_gc_msgid.
*--Set Message No
  SET PARAMETER ID text-002 FIELD p_lv_msgno.
*--Set Message variable
  SET PARAMETER ID text-003 FIELD p_gv_msgv1.
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

ENDFORM.                    " ERROR_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  CONVERT_REMOVEZEROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_HU_VBELN  text
*      <--P_LV_MSGV1  text
*----------------------------------------------------------------------*
FORM convert_removezeros  USING    p_gs_hu_vbeln TYPE vbeln
                          CHANGING p_lv_msgv1.
*--convert : remove leading zero's
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = p_gs_hu_vbeln
    IMPORTING
      output = p_lv_msgv1.

ENDFORM.                    " CONVERT_REMOVEZEROS
*&---------------------------------------------------------------------*
*&      Form  CONVERT_REMOVEZERO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_TOGEN  text
*      <--P_LV_MSGV1  text
*----------------------------------------------------------------------*
FORM convert_removezero  USING    p_lv_togen TYPE tanum
                         CHANGING p_lv_msgv1.
*--convert : remove leading zero's
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = p_lv_togen
    IMPORTING
      output = p_lv_msgv1.
ENDFORM.                    " CONVERT_REMOVEZERO
*&---------------------------------------------------------------------*
*&      Form  TEMP_RECO_VALIDATION
*&---------------------------------------------------------------------*
*      Temperature recorder validation
*----------------------------------------------------------------------*
FORM temp_reco_validation USING VALUE(iv_vbeln) TYPE vbeln
                           CHANGING cv_msgv1 TYPE msgv1.

*Conversion exit for delivery number
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = iv_vbeln
    IMPORTING
      output = iv_vbeln.

*Fetch delivery line items
  SELECT likp~vbeln, likp~vkorg, likp~kunnr, lips~posnr,lips~matnr
    FROM likp
    INNER JOIN lips
    ON likp~vbeln = lips~vbeln
    INTO TABLE @DATA(lt_likp)
    WHERE likp~vbeln = @iv_vbeln.

  IF sy-subrc EQ 0.
*Fetch Handling units
    SELECT venum,vepos,vbeln,posnr,matnr
      FROM vepo
       INTO TABLE @DATA(lt_vepo)
       FOR ALL ENTRIES IN @lt_likp
       WHERE vbeln = @lt_likp-vbeln
       AND posnr = @lt_likp-posnr.

    IF sy-subrc EQ 0.
      SORT lt_vepo BY venum.
    ENDIF.

* Fetch temperature recorder
    SELECT vkorg,kunag,kunnr,matnr,zztemp_rec
      FROM ztotc_cmis
      INTO TABLE @DATA(lt_ztotc_cmis)
      FOR ALL ENTRIES IN @lt_likp
      WHERE kunnr = @lt_likp-kunnr
      AND matnr = @lt_likp-matnr.

    IF sy-subrc EQ 0.
      SORT lt_ztotc_cmis BY matnr.
    ENDIF.
  ENDIF.

*Validate if the material is relevant to temperature recorder.
  LOOP AT lt_vepo INTO DATA(ls_vepo).
    READ TABLE lt_ztotc_cmis INTO DATA(ls_ztotc_cmis) WITH KEY matnr = ls_vepo-matnr BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF ls_ztotc_cmis-zztemp_rec IS INITIAL OR ls_ztotc_cmis-zztemp_rec = '00'.
        cv_msgv1 = ls_vepo-venum.  "Handling Unit
        lv_err = abap_true.
      ELSE.
        CONTINUE.
      ENDIF.
    ELSE.
      CONTINUE.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  TEMP_RECO_ERR_MSG
*&---------------------------------------------------------------------*
*     Populate temperature recorder error message
*----------------------------------------------------------------------*
FORM temp_reco_err_msg  USING p_lv_msgv1 TYPE msgv1.

  CONSTANTS : lc_msgid TYPE msgid VALUE 'ZWHL_MSG',
              lc_msgno TYPE msgno VALUE '000'.

  FREE MEMORY ID text-001.
  FREE MEMORY ID text-002.
  FREE MEMORY ID text-003.
*--Call error message screen with message
*--Set Message ID
  SET PARAMETER ID text-001 FIELD lc_msgid.
*--Set Message No
  SET PARAMETER ID text-002 FIELD lc_msgno.
*--Set Message variable
  SET PARAMETER ID text-003 FIELD p_lv_msgv1.

*--call display message screen
  CALL SCREEN 300.

ENDFORM.
*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROG DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROG.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = gc_x. " 'X'.
  APPEND BDCDATA.
ENDFORM.

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  IF FVAL IS NOT INITIAL.
    CLEAR BDCDATA.
    BDCDATA-FNAM = FNAM.
    BDCDATA-FVAL = FVAL.
    APPEND BDCDATA.
  ENDIF.
ENDFORM.
