*&---------------------------------------------------------------------*
*&  Include           MZITSEWM_PICKINGI01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  NEW_TRAN  INPUT
*&---------------------------------------------------------------------*
*       Save log and leave to new transaction
*----------------------------------------------------------------------*
MODULE new_tran INPUT.
  CASE sy-ucomm.
    WHEN 'NTRA'.
      CALL TRANSACTION 'ZMDE'.
  ENDCASE.
ENDMODULE.                 " NEW_TRAN  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_OUTB_DELIVERY  INPUT
*&---------------------------------------------------------------------*
*       Outbound delivery check
*----------------------------------------------------------------------*
MODULE check_outb_delivery INPUT.
  PERFORM user_command_9001.
  PERFORM check_outb_delivery.
ENDMODULE.                 " CHECK_OUTB_DELIVERY  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_SCAN_LABEL  INPUT
*&---------------------------------------------------------------------*
*       Scanned label check
*----------------------------------------------------------------------*
MODULE check_scan_label INPUT.
  PERFORM check_label.
ENDMODULE.                 " CHECK_SCAN_LABEL  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_9002 INPUT.

  DATA: lv_okcode TYPE syst-ucomm.

  lv_okcode = ok_code.
  CLEAR ok_code.

  CASE lv_okcode.
    WHEN 'ZBACK'.
      CLEAR: zsits_scan_dynp-zzoutb_delivery,
             zsits_scan_dynp-zzbarcode.

      CALL FUNCTION 'DEQUEUE_ALL'.
      LEAVE TO SCREEN 0.
    WHEN 'P-'.
*--Decrement the counter
      gv_index = gv_index - 1.

*--Page Down
    WHEN 'P+'.
*--Increment the counter
      gv_index = gv_index + 1.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9003  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9003 INPUT.
  DATA: lv_okcode3      TYPE syst-ucomm,
        "Begin of change by Pratik EICR 603155 TR #D10K9A44XO
        lv_lh01_flag    TYPE flag,
        lt_hus          TYPE /spe/ret_carr_hu_t,
        lv_hus          TYPE exidv,
        lt_msg          TYPE epic_t_bdcmsgcoll,
        cs_msg          TYPE bdcmsgcoll,
        ls_message      TYPE ts_msg,
        lt_message      TYPE tt_msg,
        ls_ewmpick_data TYPE zlscan_ewmpick_data,
        lv_display_msg  TYPE flag,
        lv_vbeln        TYPE vbeln_vl.
  "End of change by Pratik EICR 603155 TR #D10K9A44XO

  lv_okcode3 = ok_code.

  CLEAR: ok_code,lv_dummy.

  CASE lv_okcode3.
    WHEN 'ZBACK'.
      CLEAR: zsits_scan_dynp-zzoutb_delivery,
             zsits_scan_dynp-zzbarcode,
             gv_su1, gv_su2, gv_su3,
             it_su, wa_su,
             gt_zlscan_ewmpick_data.

      CALL FUNCTION 'DEQUEUE_ALL'.
      LEAVE TO SCREEN 0.
    WHEN 'P-'.
*--Decrement the counter
      gv_index = gv_index - 1.

*--Page Down
    WHEN 'P+'.
*--Increment the counter
      gv_index = gv_index + 1.
    WHEN zcl_its_utility=>gc_okcode_save.

      "Begin of change by Pratik EICR 603155 TR #D10K9A44XO
      IF ( ( gv_su1 IS NOT INITIAL OR gv_su2 IS NOT INITIAL OR gv_su3 IS NOT INITIAL )
       AND zsits_scan_dynp-zzoutb_delivery IS NOT INITIAL ).

        CLEAR ls_zlscan_ewmpick_data.
        SORT gt_zlscan_ewmpick_data BY lgnum tanum tapos scan_flag DESCENDING.
        CLEAR lt_hus.

        LOOP AT gt_zlscan_ewmpick_data INTO ls_zlscan_ewmpick_data.
          ls_ewmpick_data = ls_zlscan_ewmpick_data .

          IF ls_zlscan_ewmpick_data-scan_flag = abap_true.
            "Begin of change for defect 80, 04.03.2020
            "check QA status of scan HUs
            SELECT SINGLE zzqa_status
            FROM vekp
            INTO @DATA(lv_qa_status)
            WHERE exidv = @lv_hus.
            IF lv_qa_status IS NOT INITIAL.
              MESSAGE ID 'ZITS'
                     TYPE 'E'
                     NUMBER 529
                     INTO lv_dummy
                     WITH lv_hus lv_qa_status.

              PERFORM add_message USING zcl_its_utility=>gc_objid_palt_cart "Object ID = 'Pallet/ Carton'
                              lv_hus
                              abap_true
                              abap_true.
              "End of change for defect 80, 04.03.2020
            ELSE.
              IF ls_ewmpick_data-lower_hu IS INITIAL. " Single carton scenario
                lv_hus = ls_ewmpick_data-vlenr .
                APPEND lv_hus TO lt_hus .
                CLEAR lv_hus.
              ELSE.                                   " Pallet
                lv_hus = ls_ewmpick_data-lower_hu .
                APPEND lv_hus TO lt_hus .
                CLEAR lv_hus.
              ENDIF.
            ENDIF.
          ELSE.
            lv_lh01_flag = abap_true.
          ENDIF.

          AT END OF tapos.
            IF lv_lh01_flag = abap_true.    "LH01 logic + LT11 Logic
              PERFORM confirm_partial_to USING lt_hus
                                               ls_ewmpick_data
                                         CHANGING lt_msg.
              SORT lt_msg BY msgtyp.
              CLEAR: lt_hus.
            ELSE.                           "Direct LT11 logic
              "First dequeue/ unlock delivery no.
              CLEAR lv_vbeln.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = zsits_scan_dynp-zzoutb_delivery
                IMPORTING
                  output = lv_vbeln.

              CALL FUNCTION 'DEQUEUE_EVVBLKE'
                EXPORTING
                  mode_likp = 'E'
                  mandt     = sy-mandt
                  vbeln     = lv_vbeln
                  _scope    = '3'
                  _synchron = 'X'
                .

              CALL FUNCTION 'ZL_PARTIAL_TO_CONFIRM'
                EXPORTING
                  iv_tanum    = ls_ewmpick_data-tanum
                  iv_tapos    = ls_ewmpick_data-tapos
                  iv_lgnum    = ls_ewmpick_data-lgnum
                  iv_pallethu = ls_ewmpick_data-vlenr
                IMPORTING
                  et_msg      = lt_msg.
              SORT lt_msg BY msgtyp.
              clear lt_hus.
              COMMIT WORK AND WAIT.
            ENDIF.

            READ TABLE lt_msg INTO DATA(ls_msg) WITH KEY msgtyp = 'A'.
            IF sy-subrc = 0.
              MESSAGE ID ls_msg-msgid
                TYPE ls_msg-msgtyp
                NUMBER ls_msg-msgnr
                INTO lv_dummy_a
                WITH ls_msg-msgv1 ls_msg-msgv2 ls_msg-msgv3 ls_msg-msgv4.
              lv_display_msg = abap_true.
            ENDIF.
            CLEAR ls_msg.
            READ TABLE lt_msg INTO ls_msg WITH KEY msgtyp = 'E'.
            IF sy-subrc = 0.
              MESSAGE ID ls_msg-msgid
                TYPE ls_msg-msgtyp
                NUMBER ls_msg-msgnr
                INTO lv_dummy_e
                WITH ls_msg-msgv1 ls_msg-msgv2 ls_msg-msgv3 ls_msg-msgv4.
              lv_display_msg = abap_true.
            ENDIF.
            CLEAR ls_msg.
            READ TABLE lt_msg INTO ls_msg WITH KEY msgtyp = 'I'.
            IF sy-subrc = 0.
              MESSAGE ID ls_msg-msgid
                TYPE ls_msg-msgtyp
                NUMBER ls_msg-msgnr
                INTO lv_dummy_i
                WITH ls_msg-msgv1 ls_msg-msgv2 ls_msg-msgv3 ls_msg-msgv4.
              lv_display_msg = abap_true.
            ENDIF.
            CLEAR ls_msg.
            READ TABLE lt_msg INTO ls_msg WITH KEY msgtyp = 'S'.
            IF sy-subrc = 0.
              MESSAGE ID ls_msg-msgid
                TYPE ls_msg-msgtyp
                NUMBER ls_msg-msgnr
                INTO lv_dummy_s
                WITH ls_msg-msgv1 ls_msg-msgv2 ls_msg-msgv3 ls_msg-msgv4.
              lv_display_msg = abap_true.

            ENDIF.

            CLEAR: lv_lh01_flag.
          ENDAT.
        ENDLOOP.
        CLEAR: it_su, gv_su1, gv_su2, gv_su3,zsits_scan_dynp-zzbarcode,
                            ls_msg,lt_msg.

        IF lv_display_msg = abap_true.
          CLEAR lv_dummy.

          IF lv_dummy_a IS NOT INITIAL.
            lv_dummy = lv_dummy_a.
          ELSEIF lv_dummy_e IS NOT INITIAL.
            lv_dummy = lv_dummy_e.
          ELSEIF lv_dummy_i IS NOT INITIAL.
            lv_dummy = lv_dummy_i.
          ELSEIF lv_dummy_s IS NOT INITIAL.
            lv_dummy = lv_dummy_s.
          ENDIF.
          PERFORM add_message USING zcl_its_utility=>gc_objid_palt_cart "Object ID = 'Pallet/ Carton'
                          lv_dummy
                          lv_display_msg
                          lv_display_msg.
        ENDIF.

      ENDIF.

    WHEN 'CLEAR'.
      CLEAR: it_su, gv_su1, gv_su2, gv_su3,
             zsits_scan_dynp-zzbarcode, gt_zlscan_ewmpick_data.
      "End of change by Pratik EICR 603155 TR #D10K9A44XO
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_PATIAL_TO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_partial_to USING it_hus TYPE /spe/ret_carr_hu_t
                              is_ewmpick TYPE zlscan_ewmpick_data
                        CHANGING ct_msg TYPE epic_t_bdcmsgcoll .

  TYPES: BEGIN OF ty_ltap,
           lgnum TYPE lgnum,
           tanum TYPE tanum,
           tapos TYPE tapos,
           nltyp TYPE ltap_nltyp,
           nlber TYPE ltap_nlber,
           nlpla TYPE ltap_nlpla,
           vbeln TYPE vbeln_vl,
         END OF ty_ltap.

  DATA: lv_commit        TYPE boolean,
        lv_result        TYPE boolean VALUE abap_true,
        lwa_to_conf      TYPE zsits_to_conf,
        lwa_to_conf_item TYPE zsits_to_conf_item,
        lt_lthu_creat    TYPE TABLE OF lthu_creat,
        lwa_lthu_creat   TYPE lthu_creat,
        ls_ltap          TYPE ty_ltap,
        lv_lenum         TYPE lenum,
        lv_msg           TYPE char70,
        lv_cnt           TYPE i.

  DATA: lv_scan_object     TYPE string,
        lv_display_msg     TYPE boolean,
        lv_confirmed_lines TYPE i,
        lv_total_to_lines  TYPE i,
        ls_dlv_item        TYPE zsits_dlv_item,
        ls_msg             TYPE bdcmsgcoll.


  lv_result = abap_true.

  PERFORM frm_get_to_lines USING     zsits_scan_dynp-zzoutb_delivery
                           CHANGING  lv_confirmed_lines
                                     lv_total_to_lines.


  "Confirm partial TO logic using 2 FMs.
  "Fetch destination sotrage bin details for passing to FM
  CLEAR: lwa_to_conf, lv_dummy, lv_display_msg.

  SELECT SINGLE lgnum tanum tapos nltyp nlber nlpla vbeln
    FROM ltap
    INTO ls_ltap
    WHERE lgnum = is_ewmpick-lgnum AND
          tanum = is_ewmpick-tanum AND
          tapos = is_ewmpick-tapos.
  IF sy-subrc NE 0.
    CLEAR ls_ltap.
  ELSE.
    READ TABLE x_to_data-dlv_item INTO ls_dlv_item WITH KEY vbeln =  ls_ltap-vbeln.
    IF sy-subrc = 0.
      PERFORM fetch_pak_mat       USING x_label_content-zzlenum
                                  CHANGING ls_ltap-vbeln
                                           ls_dlv_item-posnr
                                           gv_pak_mat.
    ENDIF.
    IF gv_pak_mat IS NOT INITIAL.
      lwa_lthu_creat-vhilm = gv_pak_mat.
    ENDIF.

    lwa_lthu_creat-anzhu = ls_ltap-nlber.
    lwa_lthu_creat-lgtyp = ls_ltap-nltyp.
    lwa_lthu_creat-lgpla = ls_ltap-nlpla.
    lwa_lthu_creat-vbeln = ls_ltap-vbeln.
    APPEND lwa_lthu_creat TO lt_lthu_creat.
    CLEAR lwa_lthu_creat.

    "For LH01
    CALL FUNCTION 'L_TO_PICKHU_ASSIGN'
      EXPORTING
        i_lgnum               = ls_ltap-lgnum
        i_tanum               = ls_ltap-tanum
        i_nidru               = 'X'
        i_commit_work         = ''
      TABLES
        t_lthu_creat          = lt_lthu_creat
      EXCEPTIONS
        no_lthu_created       = 1
        update_without_commit = 2
        no_authority          = 3
        foreign_lock          = 4
        to_doesnt_exist       = 5
        no_pick_ta_pos        = 6
        wrong_bin             = 7
        anz_hu_to_large       = 8
        wrong_hu_type         = 9
        hu_number_twice       = 10
        vhilm_must_fit        = 11
        hu_is_sub_hu          = 12
        blocked_hu            = 13
        fatal_hu_check        = 14
        hu_is_no_hu           = 15
        used_in_another_doc   = 16
        too_less_data         = 17
        pick_to_confirmed     = 18
        hu_gi_posted          = 19
        hu_deleted            = 20
        hu_phys_inventory     = 21
        OTHERS                = 22.
    IF sy-subrc <> 0.
* Implement suitable error handling here
      ls_msg-msgid = sy-msgid.
      ls_msg-msgtyp = sy-msgty.
      ls_msg-msgnr = sy-msgno.
      ls_msg-msgv1 = sy-msgv1.
      ls_msg-msgv2 = sy-msgv2.
      ls_msg-msgv3 = sy-msgv3.
      ls_msg-msgv4 = sy-msgv4.
      APPEND ls_msg TO ct_msg.
      RETURN.
    ELSE.
      COMMIT WORK AND WAIT.

      WHILE lv_cnt LE 5000.
        SELECT COUNT(*)
        FROM lthu
        WHERE lgnum = ls_ltap-lgnum AND
              tanum = ls_ltap-tanum AND
              vbeln = ls_ltap-vbeln.
        IF sy-subrc = 0.
          CALL FUNCTION 'DEQUEUE_ELLTAKE'
            EXPORTING
              mode_ltak = 'E'
              mandt     = sy-mandt
              lgnum     = ls_ltap-lgnum
              tanum     = ls_ltap-tanum
              _synchron = 'X'.
          EXIT.
        ENDIF.
        lv_cnt = lv_cnt + 1.
      ENDWHILE.

      "For LT12
      CALL FUNCTION 'ZL_PARTIAL_TO_CONFIRM'
        EXPORTING
          iv_tanum    = is_ewmpick-tanum
          iv_tapos    = is_ewmpick-tapos
          iv_lgnum    = is_ewmpick-lgnum
          iv_pallethu = lt_lthu_creat[ 1 ]-exidv " Virtual HU
          it_hu       = it_hus
        IMPORTING
          et_msg      = ct_msg.


    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9999  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9999 INPUT.
  CASE sy-ucomm.
    WHEN 'ZBACK'.
      CLEAR: gv_error_txt, gv_msgid, gv_msgno.
      CALL SCREEN 9003.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  PERFORM user_command_9001.

ENDMODULE.
