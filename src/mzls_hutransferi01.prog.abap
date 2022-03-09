*----------------------------------------------------------------------*
***INCLUDE MZLS_HUTRANSFERI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.
  CASE OK_CODE.
    WHEN GC_F3.
      LEAVE PROGRAM.
    WHEN GC_F2.
      CLEAR ZSITS_SCAN_DYNP.
    WHEN gc_nxt or gc_f5.
      PERFORM check_outb_delivery.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_OUTB_DELIVERY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_OUTB_DELIVERY INPUT.
  IF OK_CODE = gc_nxt or OK_CODE = gc_f5.
    PERFORM check_outb_delivery.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_PICKING_QTY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE UPDATE_PICKING_QTY INPUT.
  PERFORM update_picking_qty.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_SCAN_LABEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_SCAN_LABEL INPUT.
  PERFORM check_label.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9001 INPUT.
  DATA: lv_okcode TYPE syst-ucomm ##DECL_MODUL ##NEEDED.
  DATA: lv_msg     TYPE bapi_msg,
        lv_error   TYPE boolean,
        lv_msgv1   TYPE msgv1,
        lv_togen   TYPE tanum,
        lv_msgid   TYPE msgid,
        lv_msgno   TYPE msgno, " symsgno,
        lv_msg_p   TYPE bapi_msg,
        lv_error_p TYPE c.
  CONSTANTS : lc_msgno1 TYPE msgno VALUE '029',
              lc_msgno3 TYPE msgno VALUE '030',
              lc_tcode  TYPE sy-tcode VALUE 'VL02N',
              LC_N      TYPE C VALUE 'N',
              LC_S      TYPE C VALUE 'S'.

  lv_okcode = ok_code.
  CLEAR ok_code.

  CASE lv_okcode.
    WHEN 'BACK'.
      CLEAR: zsits_scan_dynp-zzoutb_delivery.

      PERFORM frm_clear_variables.

      CALL FUNCTION 'DEQUEUE_ALL'.

      LEAVE TO SCREEN 0.

    WHEN 'ENT'.
      PERFORM check_label.
      PERFORM update_picking_qty.
    WHEN 'CSCA'. " PGI and call screen to confirm for PGR
      PERFORM validations.
      CHECK gv_noerror = ABAP_TRUE.
      CALL FUNCTION 'DEQUEUE_ALL'.

      perform bdc_dynpro      using 'SAPMV50A' '4004'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'LIKP-VBELN'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=WABU_T'.
      perform bdc_field       using 'LIKP-VBELN'
                                    zsits_scan_dynp-zzoutb_delivery.

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
      IF lv_error IS INITIAL.
*--Show an Successful message with Delivery number
*--Call PGR Confirmation Screen
*--BEGIN:Fetch Inbound delivery
        WAIT UP TO 1 SECONDS. " As Inbound delivery to be created through SPE function

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = zsits_scan_dynp-zzoutb_delivery
          IMPORTING
            OUTPUT = zsits_scan_dynp-zzoutb_delivery.

        SELECT SINGLE VBELN
                 FROM VBFA
                 INTO GV_IBD
                WHERE VBELV = zsits_scan_dynp-zzoutb_delivery
                  AND VBTYP_N = GC_VT.
*--Remove leadering zeros of delivery
        PERFORM convert_removezeros USING  zsits_scan_dynp-zzoutb_delivery "gs_hu-vbeln
                                    CHANGING lv_msgv1.
*--END:Fetch Inbound delivery
        CALL SCREEN 9002.
      ELSE.
*--show error message
        lv_msgv1 = lv_msg.
        PERFORM error_message USING gc_msgid
                                    lc_msgno3
                                    lv_msgv1.
      ENDIF.
  ENDCASE.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  NEW_TRAN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE NEW_TRAN INPUT.
  CALL TRANSACTION 'ZMDE'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9002 INPUT.
  CASE sy-ucomm.
    WHEN gc_f3 or gc_back. "'BACK'.
      LEAVE PROGRAM.
    WHEN gc_f5 OR gc_pgr. "F5 - Post Goods Receipt.
      PERFORM post_gr.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9003  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9003 INPUT.
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
        LEAVE TO SCREEN 9000.
      ELSE.
*--another zero status move to previous screen only
        CLEAR go_hu.
        LEAVE TO SCREEN 9000.
      ENDIF.

  ENDCASE.

ENDMODULE.
