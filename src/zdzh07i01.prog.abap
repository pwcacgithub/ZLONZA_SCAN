*&---------------------------------------------------------------------*
*&  Include           DZH07I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.


*--Based on OK system command it will check
  CASE sy-ucomm.
    WHEN gc_back OR gc_f3. "'BACK'.
      LEAVE PROGRAM .
    WHEN gc_clr OR gc_f2. "'CLR' OR 'F2'.
      CLEAR : gs_likp, GS_HU.
    WHEN gc_enter. "'ENTER'.
      PERFORM validations.
    WHEN gc_next. "'NEXT'.
      PERFORM validations.
      go_hu->get_item_display( IMPORTING es_likp = gs_likp
                                         ev_vendor_name = gv_venname
                                         ev_shp_name = gv_shname ).
      IF gv_noerror IS NOT INITIAL.
        CALL SCREEN 0200.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  DATA: lv_msg     TYPE bapi_msg,
        lv_error   TYPE boolean,
        lv_err     TYPE boolean,
        lv_msgv1   TYPE msgv1,
        lv_togen   TYPE tanum,
        lv_msgid   TYPE msgid,
        lv_msgno   TYPE symsgno,
        lv_msg_p   TYPE bapi_msg,
        lv_error_p TYPE c.
  CONSTANTS : lc_msgno1 TYPE msgno VALUE '029',
              lc_msgno3 TYPE msgno VALUE '030',
              lc_tcode  TYPE sy-tcode VALUE 'VL02N',
              LC_N      TYPE C VALUE 'N',
              LC_S      TYPE C VALUE 'S'.


  CASE sy-ucomm.
*--leave to screen Back
    WHEN gc_back OR gc_f3.
      CLEAR GO_HU.
      LEAVE TO SCREEN 100 .

    WHEN gc_pgi.
*--Temperature recorder validation before PGI
      PERFORM temp_reco_validation USING gs_hu-vbeln
                                   CHANGING lv_msgv1.

      IF lv_err = abap_true.
*--Show error message
        PERFORM temp_reco_err_msg USING lv_msgv1.

      ELSE.
* BEGIN: EICR:603155 SDHANANJAY - Project ONE: HC & DFS Implementation US & MX
* Commented as this Method was not triggering the default Output type SPED
        perform bdc_dynpro      using 'SAPMV50A' '4004'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'LIKP-VBELN'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=WABU_T'.
        perform bdc_field       using 'LIKP-VBELN'
                                       gs_hu-vbeln. "zsits_scan_dynp-zzoutb_delivery.

        CALL TRANSACTION LC_TCODE USING BDCDATA
                                  MODE LC_N
                                  UPDATE LC_S
                                  MESSAGES INTO MESSTAB.
        READ TABLE MESSTAB WITH KEY MSGTYP = LC_S.
        IF SY-SUBRC = 0.
          CLEAR lv_error.
        ELSE.
          LV_ERROR = abap_true.
        ENDIF.
* END: EICR:603155 SDHANANJAY - Project ONE: HC & DFS Implementation US & MX
        IF lv_error IS INITIAL.
*--Remove leadering zeros of delivery
          PERFORM convert_removezeros USING  gs_hu-vbeln
                                      CHANGING lv_msgv1.
*--Show an Successful message with Delivery number
          PERFORM error_message USING gc_msgid
                                      lc_msgno1
                                      lv_msgv1.
        ELSE.
*--show error message
          lv_msgv1 = lv_msg.
          PERFORM error_message USING gc_msgid
                                      lc_msgno3
                                      lv_msgv1.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.
  DATA : lv_no    TYPE dynnr,
         lv_dynnr TYPE sy-dynnr.

  CONSTANTS : lc_zero TYPE char1 VALUE '0'.
  CLEAR : lv_no, lv_dynnr.
  CASE sy-ucomm.
    WHEN gc_back OR gc_ok.
*--recollect previous screen number
      GET PARAMETER ID text-004 FIELD lv_no.
      lv_dynnr = lv_no.
*--Incase of screen no zero means successful message then leave program
      IF lv_no = lc_zero.
        CLEAR go_hu.
        LEAVE TO SCREEN 100.
      ELSE.
*--another zero status move to previous screen only
        CLEAR go_hu.
        LEAVE TO SCREEN 100.
      ENDIF.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT
