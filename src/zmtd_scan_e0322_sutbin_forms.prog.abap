*&---------------------------------------------------------------------*
*&  Include           ZMTD_SCAN_E0322_SUTBIN_FORMS
*&---------------------------------------------------------------------*
***********************************************************************
* VERSION CONTROL (Most recent on top):
* DATE             AUTHOR       CTS REQ        DESCRIPTION
*----------------------------------------------------------------------

***********************************************************************

*&---------------------------------------------------------------------*
*&      Form  GET_USER_PROFILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_user_profile .

  IF wa_profile IS INITIAL.
    CALL METHOD zcl_its_utility=>get_user_profile
      RECEIVING
        rs_user_profile = wa_profile.
  ENDIF.

ENDFORM.                    " GET_USER_PROFILE
*&---------------------------------------------------------------------*
*&      Form  INITIAL_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM initial_log .
  IF o_log IS INITIAL.
    CREATE OBJECT o_log
      EXPORTING
        iv_scan_code = sy-tcode.
  ENDIF.
ENDFORM.                    " INITIAL_LOG
*&---------------------------------------------------------------------*
*&      Form  FRM_NEW_TRAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_new_tran .
  LEAVE TO SCREEN 0.
*  CALL METHOD zcl_its_utility=>leave_2_new_trans( CHANGING co_log = o_log ).
ENDFORM.                    " FRM_NEW_TRAN
*&---------------------------------------------------------------------*
*&      Form  CREATE_TO
*&---------------------------------------------------------------------*
*       Create Transfer Orders
*----------------------------------------------------------------------*
FORM create_to .
  DATA         :
    lv_to_no          TYPE            tanum,
    lt_to_no          TYPE TABLE OF   tanum,
    lit_ltap          TYPE TABLE OF ltap_creat,
    ls_su_content     TYPE            zsits_su_content,
    ls_su_header      TYPE            lein,
    lt_su_item        TYPE            lqua_t,
    ls_su_item        TYPE            lqua,
    lwa_to_create     TYPE            zsits_to_create,
    lt_ltap_crt_item  TYPE            zttits_to_crt_item,
    lwa_ltap_crt_item TYPE            zsits_to_crt_item,
    lt_ltap_move_su   TYPE            zttits_ltap_move_su,
    lwa_ltap_move_su  TYPE            zsits_ltap_move_su.


  FIELD-SYMBOLS : <ls_item> TYPE zsits_to_crt_item,
                  <ls_ltap> TYPE ltap_creat.

*---- Added new code to create one TO for multiple SUs
  lwa_to_create-crt_for_general = 'X'.
  lwa_to_create-lgnum = wa_profile-zzlgnum.
  lwa_to_create-bwlvs  = zcl_its_utility=>gc_gm_type_999_wm.

  LOOP AT it_label INTO wa_label.

    ls_su_content = wa_label-su_content.
    ls_su_header = ls_su_content-su_header.
    lt_su_item = ls_su_content-su_item.
    LOOP AT lt_su_item INTO ls_su_item.

      lwa_ltap_crt_item-matnr  = ls_su_item-matnr .
      lwa_ltap_crt_item-werks   = ls_su_item-werks .
      lwa_ltap_crt_item-lgort  = ls_su_item-lgort .
      lwa_ltap_crt_item-charg  = ls_su_item-charg .
      lwa_ltap_crt_item-sobkz  = ls_su_item-sobkz .
      lwa_ltap_crt_item-sonum  = ls_su_item-sonum .
      lwa_ltap_crt_item-bestq  = ls_su_item-bestq .
      lwa_ltap_crt_item-vltyp  = ls_su_item-lgtyp.
      lwa_ltap_crt_item-vlpla  = ls_su_item-lgpla.
      lwa_ltap_crt_item-nltyp  = v_lgtyp.
      lwa_ltap_crt_item-nlpla  = zsits_scan_dynp-zzdestbin.
      lwa_ltap_crt_item-anfme  = ls_su_item-gesme.
      lwa_ltap_crt_item-altme  = ls_su_item-meins.
      lwa_ltap_crt_item-nlenr  = ls_su_item-lenum.
      lwa_ltap_crt_item-squit  = 'X'.
      APPEND lwa_ltap_crt_item  TO lt_ltap_crt_item  .
      CLEAR lwa_ltap_crt_item .
    ENDLOOP.
    CLEAR wa_label.
  ENDLOOP.

  lwa_to_create-to_item = lt_ltap_crt_item.

  CLEAR lv_to_no.

  LOOP AT lt_ltap_crt_item ASSIGNING <ls_item>.
    APPEND INITIAL LINE TO lit_ltap ASSIGNING <ls_ltap>.
    MOVE-CORRESPONDING <ls_item> TO <ls_ltap>.
    <ls_ltap>-vlenr = <ls_item>-nlenr. " Populate source storage bin
  ENDLOOP.

  CALL FUNCTION 'L_TO_CREATE_MULTIPLE'
    EXPORTING
      i_lgnum                = lwa_to_create-lgnum
      i_bwlvs                = lwa_to_create-bwlvs
      i_update_task          = 'X'
      i_commit_work          = 'X'
    IMPORTING
      e_tanum                = lv_to_no
    TABLES
      t_ltap_creat           = lit_ltap
    EXCEPTIONS
      no_to_created          = 1
      bwlvs_wrong            = 2
      betyp_wrong            = 3
      benum_missing          = 4
      betyp_missing          = 5
      foreign_lock           = 6
      vltyp_wrong            = 7
      vlpla_wrong            = 8
      vltyp_missing          = 9
      nltyp_wrong            = 10
      nlpla_wrong            = 11
      nltyp_missing          = 12
      rltyp_wrong            = 13
      rlpla_wrong            = 14
      rltyp_missing          = 15
      squit_forbidden        = 16
      manual_to_forbidden    = 17
      letyp_wrong            = 18
      vlpla_missing          = 19
      nlpla_missing          = 20
      sobkz_wrong            = 21
      sobkz_missing          = 22
      sonum_missing          = 23
      bestq_wrong            = 24
      lgber_wrong            = 25
      xfeld_wrong            = 26
      date_wrong             = 27
      drukz_wrong            = 28
      ldest_wrong            = 29
      update_without_commit  = 30
      no_authority           = 31
      material_not_found     = 32
      lenum_wrong            = 33
      matnr_missing          = 34
      werks_missing          = 35
      anfme_missing          = 36
      altme_missing          = 37
      lgort_wrong_or_missing = 38
      error_message          = 99
      OTHERS                 = 39.

  IF sy-subrc <> 0.

    MESSAGE ID       sy-msgid
           TYPE      sy-msgty
           NUMBER    sy-msgno
           INTO      v_dummy
           WITH      sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.


  IF lv_to_no IS NOT INITIAL.
    MESSAGE e000(zmtdus) WITH lv_to_no text-003 INTO v_dummy.

    PERFORM add_message USING zcl_its_utility=>gc_objid_to
                              v_barcode
                              abap_true.
    PERFORM clear_su.
  ELSE.
    MESSAGE ID   sy-msgid
       TYPE      sy-msgty
       NUMBER    sy-msgno
       INTO      v_dummy
       WITH      sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

    PERFORM add_message USING zcl_its_utility=>gc_objid_to
                              v_barcode
                              abap_true.
  ENDIF.

ENDFORM.                    " CREATE_TO
*&---------------------------------------------------------------------*
*&      Form  NEXT_SCREEN
*&---------------------------------------------------------------------*
*       Next Screen
*----------------------------------------------------------------------*
FORM next_screen .

  CHECK v_flag IS INITIAL.   " No Errors
* Next Screen
  SET SCREEN 9010.

ENDFORM.                    " NEXT_SCREEN
*&---------------------------------------------------------------------*
*&      Form  CHECK_DEST_BIN
*&---------------------------------------------------------------------*
*       Validate Destination Bin
*----------------------------------------------------------------------*
FORM check_dest_bin .
  DATA : lo_auth_check TYPE REF TO zcl_auth_check,
         ls_result     TYPE bapiret2.
  CONSTANTS: LC_LGN(3) TYPE C VALUE 'LGN'.
  CLEAR v_flag.

  IF zsits_scan_dynp-zzdestbin IS INITIAL.
    " Enter a valid bin
    v_flag = 'X'.
    MESSAGE e000(zmtdus) WITH text-001 INTO v_dummy.
    PERFORM add_message USING zcl_its_utility=>gc_objid_to
                              zsits_scan_dynp-zzdestbin
                              abap_true.
  ELSE.
* BEGIN: EICR:603155 SDHANANJAY - Project ONE: HC & DFS Implementation US & MX
* When the GET PARAMETER ID Fails, fetch from USR05 table directly
    IF wa_profile-zzlgnum IS INITIAL.
      SELECT SINGLE PARVA
               FROM USR05
               INTO @DATA(LS_PARVA)
              WHERE BNAME = @SY-UNAME
                AND PARID = @LC_LGN.
      IF SY-SUBRC = 0.
        wa_profile-zzlgnum = LS_PARVA.
      ENDIF.
    ENDIF.
* END: EICR:603155 SDHANANJAY - Project ONE: HC & DFS Implementation US & MX
    SELECT SINGLE lgtyp INTO v_lgtyp FROM lagp
                   WHERE lgnum = wa_profile-zzlgnum
                   AND   lgpla = zsits_scan_dynp-zzdestbin.
    IF sy-subrc NE 0.
      " Enter a valid bin
      v_flag = 'X'.
      MESSAGE e000(zmtdus) WITH text-001 INTO v_dummy.
      PERFORM add_message USING zcl_its_utility=>gc_objid_to
                                zsits_scan_dynp-zzdestbin
                                abap_true.
    ELSE.
      CREATE OBJECT lo_auth_check .
      ls_result = lo_auth_check->auth_check_lgnum( EXPORTING iv_lgnum = wa_profile-zzlgnum ).
      IF ls_result IS NOT INITIAL.
        v_flag = 'X'.
        MESSAGE ID ls_result-id TYPE ls_result-type NUMBER ls_result-number
        WITH ls_result-message_v1 INTO v_dummy.

        PERFORM add_message USING zcl_its_utility=>gc_objid_to
                                  wa_profile-zzlgnum
                                  abap_true.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.                    " CHECK_DEST_BIN
*&---------------------------------------------------------------------*
*&      Form  CLEAR_ALL
*&---------------------------------------------------------------------*
*       Clear All
*----------------------------------------------------------------------*
FORM clear_all .

  CLEAR zsits_scan_dynp-zzdestbin.
  PERFORM clear_su.

ENDFORM.                    " CLEAR_ALL
*&---------------------------------------------------------------------*
*&      Form  CLEAR_SU
*&---------------------------------------------------------------------*
*       Clear Storage Units
*----------------------------------------------------------------------*
FORM clear_su .

  CLEAR : zsits_scan_dynp-zzbarcode ,
          v_barcode ,
          wa_su     ,
          wa_label  .

  REFRESH : it_su ,
            it_label .

ENDFORM.                    " CLEAR_SU
*&---------------------------------------------------------------------*
*&      Form  READ_BARCODE
*&---------------------------------------------------------------------*
*       Read SU Barcode
*----------------------------------------------------------------------*
FORM read_barcode .

  DATA :
    ls_label_type TYPE zslabel_type_range,
    lt_label_type TYPE ztlabel_type_range,
    ls_label      TYPE zsits_label_content,
    lt_su_item    TYPE lqua_t,
    lv_msg        TYPE char100,
    ls_su_item    LIKE LINE OF lt_su_item,
    lv_dest_lgtyp TYPE lagp-lgtyp.
**Begin of changes by MMEHTA
  DATA : lv_lgnum TYPE lgnum.
  DATA : lo_author   TYPE REF TO zcl_auth_check,
         ls_return   TYPE bapiret2,
         lv_msgv1    TYPE msgv1,
         LV_FLAG     TYPE C,
         lv_exidv    TYPE exidv,
         lv_barcode1 TYPE string,
         lv_barcode  TYPE string,
         lv_msgno    TYPE zzscan_objid. "msgno.
**  End of changes by MMEHTA
  CHECK zsits_scan_dynp-zzbarcode IS NOT INITIAL.
  IF v_barcode NE zsits_scan_dynp-zzbarcode.
    v_barcode = zsits_scan_dynp-zzbarcode.
* SU Label Type
    ls_label_type-sign = 'I'.
    ls_label_type-zoption = 'EQ'.
    ls_label_type-low = zcl_its_utility=>gc_label_su.
    APPEND ls_label_type TO lt_label_type.
    CLEAR: wa_label, lv_flag.
    GET PARAMETER ID 'ZGELATIN' FIELD LV_FLAG.

    IF LV_FLAG <> ABAP_TRUE.


*Begin of changes by MMEHTA
      CREATE OBJECT go_hu.
      CALL METHOD go_hu->hubarcode_value
        EXPORTING
          iv_exidv    = v_barcode
        IMPORTING
          ev_hunumber = v_barcode.
*    End of changees by MMEHTA
* Barcode read
      CALL METHOD zcl_mde_barcode=>disolve_barcode
        EXPORTING
          iv_barcode          = v_barcode
          iv_werks            = ' '
          it_label_type_range = lt_label_type
        IMPORTING
          es_label_content    = wa_label.
    else.
      LV_BARCODE = v_barcode.
      CALL FUNCTION 'ZWM_HU_VALIDATE'
        EXPORTING
          IV_BARCODE          = LV_BARCODE
          IT_LABEL_TYPE_RANGE = lt_label_type
        IMPORTING
          EV_EXIDV            = LV_EXIDV
          ES_RETURN           = LS_RETURN
          EV_BARCODE          = LV_BARCODE1
          ES_LABEL_CONTENT    = wa_label.
      v_barcode = lv_barcode1.
      CLEAR lv_flag.
    endif.
    IF wa_label-zzlenum IS NOT INITIAL.
**      Begin of changes by MMEHTA
      SELECT SINGLE lgnum INTO lv_lgnum FROM lein WHERE lenum = wa_label-zzlenum.
      IF sy-subrc EQ 0.
        CREATE OBJECT lo_author.
        CLEAR : lv_msgv1, ls_return, lv_msgno.
*--check User Authorization check on warehouse level.
        lo_author->auth_check_lgnum(
          EXPORTING
            iv_lgnum    = lv_lgnum    " Warehouse Number / Warehouse Complex

          RECEIVING
            es_bapiret2 = ls_return    " Return Parameter
        ).
        IF ls_return IS NOT INITIAL.
          lv_msgv1 = ls_return-message_v1.
          lv_msgno = ls_return-number.
*--Show an error message for Authorization for User
          MESSAGE e056(zlone_hu) WITH lv_msgv1 INTO v_dummy.
          PERFORM add_message USING lv_msgno
                                    lv_msgv1
                                    abap_true.
        ENDIF.
*       Begin of insert rvenugopal EICR 573543 : DFDS Support
*       CHECK if the movement is allowed
        lt_su_item = wa_label-su_content-su_item[] .
        CLEAR ls_su_item.
        READ TABLE lt_su_item INTO ls_su_item INDEX 1.
        IF sy-subrc EQ 0.
*          determine destination storage type
          SELECT lgtyp UP TO 1 ROWS FROM lagp INTO lv_dest_lgtyp
           WHERE lgnum = ls_su_item-lgnum
           AND   lgpla = zsits_scan_dynp-zzdestbin.
          ENDSELECT.
          IF sy-subrc EQ 0.
            CALL FUNCTION 'ZL_RESTRICT_TO_STO_TYPE'
              EXPORTING
                i_matnr = ls_su_item-matnr
                i_lgnum = ls_su_item-lgnum
                i_bestq = ls_su_item-bestq
                i_lgtyp = lv_dest_lgtyp
              IMPORTING
                e_msg   = lv_msg.
            IF lv_msg IS NOT INITIAL.
              PERFORM add_message USING 509 "message number from FM ZL_RESTRICT_TO_STO_TYPE
                                        lv_msg
                                        abap_true.
              CLEAR wa_label.
            ENDIF.
          ENDIF.
********-------------Begin of insert ATHOMAS3 EICR 603155 : P1 HC/DFS US-NA
*** Restrict TO - Bin to Bin movement - Check Batch
**  Only 1 Material - Batch combination allowed in a destination Bin.
          CLEAR lv_msg.
          CALL FUNCTION 'ZL_RESTRICT_TO_BATCH'
            EXPORTING
              i_matnr = ls_su_item-matnr
              i_charg = ls_su_item-charg
              i_lgnum = ls_su_item-lgnum
              i_nltyp = lv_dest_lgtyp
              i_nlpla = zsits_scan_dynp-zzdestbin
            IMPORTING
              e_msg   = lv_msg.
          IF lv_msg IS NOT INITIAL.
            PERFORM add_message USING 127 "message number from FM ZL_RESTRICT_TO_BATCH
                                      lv_msg
                                      abap_true.
            CLEAR wa_label.
          ENDIF.

********-------------End of insert ATHOMAS3 EICR 603155 : P1 HC/DFS US-NA
        ENDIF.
*       End of insert rvenugopal EICR 573543 : DFDS Support

**      End of changes by MMEHTA
        IF  wa_label-zzlenum IS NOT INITIAL .
          READ TABLE it_label INTO ls_label WITH KEY zzlenum = wa_label-zzlenum.
          IF sy-subrc NE 0.
            APPEND wa_label TO it_label.
            zsits_scan_dynp-zzsu = wa_label-zzlenum.
          ENDIF.
        ENDIF.
        CLEAR zsits_scan_dynp-zzbarcode.
      ELSE.
        zsits_scan_dynp-zzsu = zsits_scan_dynp-zzbarcode.
      ENDIF.
**      Begin of changes by MMEHTA
    ENDIF.
**      End of changes by MMEHTA
  ELSE.
    CLEAR zsits_scan_dynp-zzbarcode.
  ENDIF.
ENDFORM.                    " READ_BARCODE
*&---------------------------------------------------------------------*
*&      Form  ADD_SU
*&---------------------------------------------------------------------*
*       Add Storage Unit to Table vuew
*----------------------------------------------------------------------*
FORM add_su .


  READ TABLE it_su INTO wa_su WITH KEY wa_label-zzlenum. " zsits_scan_dynp-zzsu.
  IF sy-subrc EQ 0.
    " SU already added
  ELSE.
    IF wa_label-su_content-su_header-lenum IS NOT INITIAL.
      wa_su = wa_label-su_content-su_header-lenum.
      APPEND wa_su TO it_su.
      CLEAR : wa_su.
    ELSE.
      IF zsits_scan_dynp-zzbarcode IS NOT INITIAL.
        " Storage unit doesn't exists
        MESSAGE e000(zmtdus) WITH wa_label-zzlenum text-002 INTO v_dummy.
        PERFORM add_message USING zcl_its_utility=>gc_objid_to
                                  v_barcode
                                  abap_true.

      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " ADD_SU
*&---------------------------------------------------------------------*
*&      Form  ADD_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->uv_objid      Object ID
*      -->uv_content    Object
*      -->uv_err_fg     Error Flag
*----------------------------------------------------------------------*
FORM add_message  USING uv_objid   TYPE zzscan_objid
                        uv_content TYPE any
                        uv_err_fg  TYPE boolean.

  CALL METHOD o_log->log_message_add
    EXPORTING
      iv_object_id    = uv_objid
      iv_content      = uv_content
      iv_with_message = uv_err_fg.

  IF uv_err_fg = abap_true.
*-----Display error message
    CALL METHOD zcl_its_utility=>message_display( ).
  ENDIF.

ENDFORM.                    "add_message
*&---------------------------------------------------------------------*
*&      Form  TABLE_SCROLL
*&---------------------------------------------------------------------*
*       Scrolling in table control
*----------------------------------------------------------------------*

FORM table_scroll .

  DATA : l_tc_new_top_line     TYPE i .

  CASE ok_code.

    WHEN 'P++'.  " Last Page
      l_tc_new_top_line =  ztblctrl_su-lines - 5.
    WHEN 'P+'.   " Next Page
      l_tc_new_top_line =  ztblctrl_su-top_line + 6.
    WHEN 'P-'.   " Previous Page
      l_tc_new_top_line =  ztblctrl_su-top_line - 6.
    WHEN 'P--'.  " First Page
      l_tc_new_top_line = 1.
  ENDCASE.

  IF l_tc_new_top_line GT ztblctrl_su-lines.
    l_tc_new_top_line = ztblctrl_su-lines - 5.
  ELSEIF l_tc_new_top_line LT 1.
    l_tc_new_top_line = 1.
  ENDIF.

  ztblctrl_su-top_line = l_tc_new_top_line.

ENDFORM.                    " TABLE_SCROLL
