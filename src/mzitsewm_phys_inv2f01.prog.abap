*&---------------------------------------------------------------------*
*&  Include           MZITSEWM_PHYS_INVF01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FRM_GET_USER_PROFILE
*&---------------------------------------------------------------------*
*       Obtain user profile
*----------------------------------------------------------------------*
FORM frm_get_user_profile.

  CHECK x_profile IS INITIAL.

  CALL METHOD zcl_its_utility=>get_user_profile
    RECEIVING
      rs_user_profile = x_profile.

ENDFORM.                    " FRM_GET_USER_PROFILE

*&---------------------------------------------------------------------*
*&      Form  FRM_NEW_TRAN
*&---------------------------------------------------------------------*
*       Leave to new transaction
*----------------------------------------------------------------------*
FORM frm_new_tran .

  CALL METHOD zcl_its_utility=>leave_2_new_trans( CHANGING co_log = o_log ).

ENDFORM.                    " FRM_NEW_TRAN

*&---------------------------------------------------------------------*
*&      Form  FRM_INV_DOC_CHECK
*&---------------------------------------------------------------------*
*       Check inv doc existence
*----------------------------------------------------------------------*
FORM frm_inv_doc_check CHANGING cv_error_ind TYPE xfeld.
  DATA :lv_auth_msg TYPE c LENGTH 100,
        lc_e        TYPE c VALUE 'E'.


  DATA: lx_key TYPE zsits_wm_inv_doc.

  DATA: lv_wminvdoc TYPE string.

  cv_error_ind = abap_true.

  CLEAR lx_key.
  lx_key-zzlgnum    = x_profile-zzlgnum.
  lx_key-zzwminvdoc = zsits_scan_dynp-zzwminvdoc.

  CALL METHOD zcl_its_utility=>wm_inv_doc_exist
    EXPORTING
      is_key          = lx_key
    IMPORTING
      ev_su_managed   = v_su_m_bool   " if SU managed?
      ev_error_bool   = cv_error_ind
      ev_storage_type = v_storage_type.

*** Authority check on LGNUM and LGTYP
  AUTHORITY-CHECK OBJECT 'L_LGNUM'
    ID 'LGNUM' FIELD x_profile-zzlgnum
    ID 'LGTYP' FIELD v_storage_type.

  IF sy-subrc <> 0.
*     MESSAGE e531(zits) WITH x_profile-zzlgnum v_storage_type.
    CONCATENATE text-001 x_profile-zzlgnum text-002 v_storage_type INTO lv_auth_msg SEPARATED BY space.
    MESSAGE lv_auth_msg TYPE lc_e.
  ENDIF.


* Delete all items for inventory doc scanned before.
  lv_wminvdoc = zsits_scan_dynp-zzwminvdoc.

  CALL METHOD zcl_its_utility=>physinv_content_operation
    EXPORTING
      iv_mode = 'D'
      iv_id   = lv_wminvdoc.

ENDFORM.                    " FRM_INV_DOC_CHECK

*&---------------------------------------------------------------------*
*&      Form  FRM_MESSAGE_ADD
*&---------------------------------------------------------------------*
*       Add message and display log
*----------------------------------------------------------------------*
FORM frm_message_add USING uv_objid   TYPE zzscan_objid
                           uv_content TYPE any
                           uv_bool    TYPE boolean.

  CALL METHOD o_log->log_message_add
    EXPORTING
      iv_object_id    = uv_objid
      iv_content      = uv_content
      iv_with_message = uv_bool.

  IF uv_bool = abap_true.
*---Display error message
    CALL METHOD zcl_its_utility=>message_display( ).
  ENDIF.

ENDFORM.                    " FRM_MESSAGE_ADD

*&---------------------------------------------------------------------*
*&      Form  FRM_BIN_CHECK
*&---------------------------------------------------------------------*
*       Check if bin is on inv doc
*----------------------------------------------------------------------*
FORM frm_bin_check CHANGING cv_error_ind TYPE xfeld.

  DATA: lit_linp TYPE STANDARD TABLE OF linp_vb,
        lwa_linv TYPE linv_vb,
        lv_dummy TYPE bapi_msg.

  CHECK zsits_scan_dynp-zzsbin IS NOT INITIAL.

* Check if Bin is existed in table LAGP.
  PERFORM frm_is_bin_exist CHANGING cv_error_ind.
  CHECK cv_error_ind EQ abap_false.

  cv_error_ind = abap_true.
  CLEAR: lwa_linv,
         lv_dummy,
         v_bin_on_doc.
  REFRESH: lit_linp.

  CALL FUNCTION 'L_INV_READ'
    EXPORTING
      i01_lgnum                 = x_profile-zzlgnum
      i01_ivnum                 = zsits_scan_dynp-zzwminvdoc
    TABLES
      t_linp                    = lit_linp
      t_linv                    = it_linv
    EXCEPTIONS
      link_missing              = 1
      linp_missing              = 2
      linv_missing              = 3
      system_error_when_locking = 4
      locked_by_user            = 5
      OTHERS                    = 6.

  CHECK sy-subrc EQ 0.
  SORT it_linv BY lgpla. "by sbin

  READ TABLE it_linv TRANSPORTING NO FIELDS WITH KEY lgpla = zsits_scan_dynp-zzsbin BINARY SEARCH.
  IF sy-subrc EQ 0.
    LOOP AT it_linv INTO lwa_linv FROM sy-tabix WHERE lgpla = zsits_scan_dynp-zzsbin.
*-----check if at least one bin on doc is not cancelled, cleared.
      IF lwa_linv-istat NE 'S' AND lwa_linv-istat NE 'L' AND lwa_linv-istat NE 'Z'.
        v_bin_on_doc = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
  ELSE.
    " Bin not assigned to count on phys. inv. doc. &1 !
    MESSAGE e100(zits) WITH zsits_scan_dynp-zzwminvdoc INTO lv_dummy.
    RETURN.
  ENDIF.

  IF v_bin_on_doc EQ abap_false.
    " Bin &1 on doc &2 was cancelled or cleared !
    MESSAGE e356(zits) WITH zsits_scan_dynp-zzsbin zsits_scan_dynp-zzwminvdoc INTO lv_dummy.
    RETURN.
  ELSE.
    SORT it_completed_bin BY lgpla.
    READ TABLE it_completed_bin TRANSPORTING NO FIELDS WITH KEY lgpla = zsits_scan_dynp-zzsbin BINARY SEARCH.
    IF sy-subrc EQ 0.
      " Count for Bin &1 already completed.
      MESSAGE e427(zits) WITH zsits_scan_dynp-zzsbin INTO lv_dummy.
      RETURN.
    ENDIF.

*---if not SU managed, go to screen 9200.
*---If SU managed, remain on screen 9400
    IF v_su_m_bool = abap_false.
      CALL SCREEN 9200.
    ELSE.
      CALL SCREEN 9400.
    ENDIF.
    IF v_back_flag EQ abap_true.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.

  cv_error_ind = abap_false.

ENDFORM.                    " FRM_BIN_CHECK

*&---------------------------------------------------------------------*
*&      Form  FRM_IS_BIN_EXIST
*&---------------------------------------------------------------------*
*       Check if bin exist
*----------------------------------------------------------------------*
FORM frm_is_bin_exist  CHANGING cv_error_ind TYPE xfeld.

  DATA: lv_lagp  TYPE lagp,
        lv_dummy TYPE bapi_msg.

  SELECT SINGLE *
    FROM lagp
    INTO lv_lagp
   WHERE lgnum EQ x_profile-zzlgnum
     AND lgtyp EQ v_storage_type
     AND lgpla EQ zsits_scan_dynp-zzsbin.
  IF sy-subrc EQ 0.
    cv_error_ind = abap_false.
  ELSE.
    MESSAGE e129(zits) WITH zsits_scan_dynp-zzsbin INTO lv_dummy.
    cv_error_ind = abap_true.
  ENDIF.

ENDFORM.                    " FRM_IS_BIN_EXIST

*&---------------------------------------------------------------------*
*&      Form  FRM_CHECK_SU
*&---------------------------------------------------------------------*
*       Check if SU on inv doc
*----------------------------------------------------------------------*
FORM frm_check_su CHANGING cv_error_ind TYPE boolean.

  DATA: lv_dummy TYPE string.

  DATA: lwa_linv    LIKE LINE OF it_linv,
        lit_linv    TYPE STANDARD TABLE OF linv_vb.



  DATA: lit_label_type_range TYPE ztlabel_type_range,
        lwa_label_range      TYPE zslabel_type_range,
        lv_label_type        TYPE zdits_label_type,

*       begin of inser rvenugopal
        lo_hu                TYPE REF TO zcl_rfscanner_packunpack,
        lo_auth_check        TYPE REF TO zcl_auth_check,
        ls_return            TYPE bapiret2,
        lv_barcode           TYPE char100.
*       end of insert rvenugopal

  cv_error_ind = abap_true.

* Generate label type range
  PERFORM frm_add_label_type USING    zcl_its_utility=>gc_label_su      "SU Label
                             CHANGING lit_label_type_range.

  CLEAR: lv_label_type, s_label_content.

*--Read the HU number enter one is with Prefix or not
  GET PARAMETER ID 'ZGELATIN' FIELD lv_flag.
  IF lv_flag <> abap_true.
*--Read the HU number enter one is with Prefix or not
*--If not prefix of HU number then add Prefix with below code
*--Create Class Object for validation
    CREATE OBJECT go_hu.
    CALL METHOD go_hu->hubarcode_value
      EXPORTING
        iv_exidv    = zsits_scan_dynp-zzbarcode
      IMPORTING
        ev_hunumber = zsits_scan_dynp-zzbarcode.
* Set label type
    lwa_label_range-sign   = 'I'.
    lwa_label_range-zoption = 'EQ'.
    lwa_label_range-low    = zcl_its_utility=>gc_label_hu.
    APPEND lwa_label_range TO lit_label_type_range.
* Read barcode
*REad the barcode
    CALL METHOD zcl_mde_barcode=>disolve_barcode
      EXPORTING
        iv_barcode          = zsits_scan_dynp-zzbarcode
        iv_werks            = ' '
        it_label_type_range = lit_label_type_range
      IMPORTING
        es_label_content    = s_label_content.
  ELSE.
    CLEAR lv_barcode1.
    lv_barcode1 = zsits_scan_dynp-zzbarcode.
    CALL FUNCTION 'ZWM_HU_VALIDATE'
      EXPORTING
        iv_barcode          = lv_barcode1
        it_label_type_range = lit_label_type_range
      IMPORTING
        ev_exidv            = lv_exidv
        es_return           = ls_return
        ev_barcode          = lv_barcode1
        es_label_content    = s_label_content.

    zsits_scan_dynp-zzbarcode = lv_barcode1.
    CLEAR lv_flag.

  ENDIF.

  IF s_label_content-su_content IS NOT INITIAL.
    MOVE s_label_content-su_content TO is_su_data.
  ELSE.
    RETURN.
  ENDIF.
*     Check authorization
  CREATE OBJECT lo_auth_check.
  ls_return = lo_auth_check->auth_check_lgnum( iv_lgnum = is_su_data-su_header-lgnum ).
  IF ls_return IS NOT INITIAL.
    MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number
    WITH ls_return-message_v1 INTO lv_dummy.
    RETURN.
  ENDIF.

  IF is_su_data-su_header-lgpla <> zsits_scan_dynp-zzsbin.
    lv_su_str = is_su_data-su_header-lenum."zsits_scan_dynp-zzsu.
    SHIFT lv_su_str LEFT DELETING LEADING '0'.

*   Storage unit &1 is already in storage bin &2 &3.
    MESSAGE e423(zits) WITH lv_su_str
                            is_su_data-su_header-lgtyp
                            is_su_data-su_header-lgpla
                       INTO lv_dummy.

    PERFORM add_su2report USING zsits_scan_dynp
                                is_su_data-su_header
                          CHANGING gt_zlwminvdoc.

    RETURN.
  ENDIF.

  lv_wminvdoc = zsits_scan_dynp-zzwminvdoc.

  CALL METHOD zcl_its_utility=>physinv_content_operation
    EXPORTING
      iv_mode    = 'G'
      iv_id      = lv_wminvdoc
    CHANGING
      ct_content = lit_linv.

  READ TABLE lit_linv INTO lwa_linv WITH KEY lgnum = x_profile-zzlgnum
                                             ivnum = zsits_scan_dynp-zzwminvdoc
                                             lgpla = zsits_scan_dynp-zzsbin
                                             lenum = is_su_data-su_header-lenum."zsits_scan_dynp-zzsu.
  IF sy-subrc = 0.
    lv_su_str = is_su_data-su_header-lenum."zsits_scan_dynp-zzsu.
    SHIFT lv_su_str LEFT DELETING LEADING '0'.

*   &1 already counted.
    MESSAGE e432(zits) WITH lv_su_str INTO lv_dummy.
    RETURN.
  ENDIF.

  SORT it_linv BY lgpla lenum. "by storage unit
*-----get info for the scanned SU if it is active on phys inv doc
  READ TABLE it_linv TRANSPORTING NO FIELDS WITH KEY lgpla = zsits_scan_dynp-zzsbin
                                                     lenum = is_su_data-su_header-lenum"zsits_scan_dynp-zzsu
                                                     BINARY SEARCH.
  IF sy-subrc EQ 0.
    LOOP AT it_linv INTO lwa_linv FROM sy-tabix WHERE lgpla EQ zsits_scan_dynp-zzsbin
                                                  AND lenum EQ is_su_data-su_header-lenum"zsits_scan_dynp-zzsu
                                                  AND istat NE 'S'  "cancelled
                                                  AND istat NE 'Z'  "counted
                                                  AND istat NE 'L'. "cleared
*-----if records satisfy the selection criteria ==> pass lit_linv data
*       to global structure for database this is inside the loop because
*       lit_linv might have multiple records that would satisfy the
*       selection criteria
      lwa_linv-menga = lwa_linv-gesme. "set counted quantity equals SAP total stock
*      lwa_linv-lgpla = zsits_scan_dynp-zzsbin. "overwrite system storage bin with scanned sbin
      PERFORM frm_pass_data USING    abap_false " overwrite
                            CHANGING lwa_linv.
      CLEAR: zsits_scan_dynp-zzbarcode."zsits_scan_dynp-zzsu.
    ENDLOOP.
  ELSE.
**-----if su not on current doc, check if it is on other doc.
*    PERFORM frm_su_on_other_doc CHANGING cv_error_ind.
    PERFORM add_su2report USING zsits_scan_dynp
                                is_su_data-su_header
                          CHANGING gt_zlwminvdoc.
  ENDIF.

  MESSAGE s426(zits) WITH is_su_data-su_header-lenum INTO zsits_scan_dynp-zzsuccess_msg.

  cv_error_ind = abap_false.

ENDFORM.                    " FRM_CHECK_SU

**&---------------------------------------------------------------------*
**&      Form  FRM_SU_ON_OTHER_DOC
**&---------------------------------------------------------------------*
**       Check if SU is on other active inv doc
**----------------------------------------------------------------------*
                   " FRM_SU_ON_OTHER_DOC

*&---------------------------------------------------------------------*
*&      Form  FRM_PASS_DATA
*&---------------------------------------------------------------------*
*       Save inv doc data to database
*----------------------------------------------------------------------*
FORM frm_pass_data USING    uv_aggregate TYPE boolean
                   CHANGING cv_linv      TYPE linv_vb.

*-----update selected data to database
  DATA: lit_linv    TYPE STANDARD TABLE OF linv_vb,
        lv_wminvdoc TYPE string.
  FIELD-SYMBOLS: <fs_linv> LIKE LINE OF lit_linv.

  lv_wminvdoc = zsits_scan_dynp-zzwminvdoc.

  CALL METHOD zcl_its_utility=>physinv_content_operation
    EXPORTING
      iv_mode    = 'G'
      iv_id      = lv_wminvdoc
    CHANGING
      ct_content = lit_linv.

  IF lit_linv IS NOT INITIAL.
    SORT lit_linv BY charg matnr lenum lgpla ivnum.
    READ TABLE lit_linv ASSIGNING <fs_linv> WITH KEY charg = cv_linv-charg
                                                     matnr = cv_linv-matnr
                                                     lenum = cv_linv-lenum
                                                     lgpla = cv_linv-lgpla
                                                     ivnum = cv_linv-ivnum
                                                     BINARY SEARCH.
    IF sy-subrc EQ 0.
*-----overwrite or aggregate quantity for duplicate records
      IF uv_aggregate = abap_true."aggregate
        <fs_linv>-menga = cv_linv-menga + <fs_linv>-menga.
      ELSE."overwiate
        <fs_linv>-menga = cv_linv-menga.
      ENDIF.

**-----overwrite quantity for duplicate records
    ELSE.
*-----if no duplicates found, append directly
      APPEND cv_linv TO lit_linv.
    ENDIF.
  ELSE.
*---if database is empty, append directly
    APPEND cv_linv TO lit_linv.
  ENDIF.

  CALL METHOD zcl_its_utility=>physinv_content_operation
    EXPORTING
      iv_mode    = 'S'
      iv_id      = lv_wminvdoc
    CHANGING
      ct_content = lit_linv.

  IF sy-subrc = 0.
    CLEAR: cv_linv.
  ENDIF.

ENDFORM.                    " FRM_PASS_DATA

*&---------------------------------------------------------------------*
*&      Form  FRM_LABEL_RECOG
*&---------------------------------------------------------------------*
*       Break down bar code lingo to useful info
*----------------------------------------------------------------------*
FORM frm_label_recog CHANGING cv_error_ind TYPE xfeld.

  DATA:
    lx_read_option TYPE zsits_batch_read_option,
    lv_label_type  TYPE zdits_label_type,
    lt_label_type  TYPE ztlabel_type_range,
    lv_is_exist    TYPE boolean.

  cv_error_ind = abap_true.

  " FG Batch
  PERFORM frm_add_label_type  USING    zcl_its_utility=>gc_label_fg_batch
                              CHANGING lt_label_type.
  " Batch managed. RM
  PERFORM frm_add_label_type  USING    zcl_its_utility=>gc_label_rm_batch
                              CHANGING lt_label_type.
  " Non-Batch managed.RM
  PERFORM frm_add_label_type  USING    zcl_its_utility=>gc_label_rm_nob
                              CHANGING lt_label_type.

  "Material - Non Batch
  PERFORM frm_add_label_type  USING    zcl_its_utility=>gc_label_mat_nob
                              CHANGING lt_label_type.

  CLEAR: lv_label_type, s_label_content.
*
  lx_read_option-zzstock_read = abap_true.
  lx_read_option-zzcharact_read = abap_true.

* Read bar code, get label type and content
*--Read the Barcode value
  CALL METHOD zcl_mde_barcode=>disolve_barcode
    EXPORTING
      iv_barcode          = zsits_scan_dynp-zzbchmtr
      iv_werks            = space
      iv_exist_check      = abap_true
      is_read_option      = lx_read_option
      it_label_type_range = lt_label_type
    IMPORTING
      ev_label_type       = lv_label_type
      es_label_content    = s_label_content.

  IF lv_label_type IS NOT INITIAL.

    CASE lv_label_type.
      WHEN zcl_its_utility=>gc_label_fg_batch.
        PERFORM frm_populate_fg CHANGING cv_error_ind.

      WHEN zcl_its_utility=>gc_label_rm_batch.
        CLEAR lv_is_exist.
        lv_is_exist = abap_true.
        PERFORM frm_populate_rm_batch USING    lv_is_exist
                                      CHANGING cv_error_ind.

      WHEN zcl_its_utility=>gc_label_rm_nob.
        PERFORM frm_populate_rm_nob CHANGING cv_error_ind.

        "Material - Non Batch
      WHEN zcl_its_utility=>gc_label_mat_nob.  " Material with NO Batch
        PERFORM frm_populate_rm_nob CHANGING cv_error_ind.

    ENDCASE.

  ELSE." Check whether is RM Container batch and batch record not exist.
    IF sy-msgid = 'ZITS' AND sy-msgno = '107'."RM batch &1 does not exist!.
      REFRESH lt_label_type.

      " Batch managed. RM
      PERFORM frm_add_label_type  USING    zcl_its_utility=>gc_label_rm_batch
                                  CHANGING lt_label_type.

      CLEAR: lv_label_type, s_label_content.

*     Read bar code, get label type and content
      CALL METHOD zcl_mde_barcode=>disolve_barcode
        EXPORTING
          iv_barcode          = zsits_scan_dynp-zzbchmtr
          iv_werks            = space
          iv_exist_check      = abap_false
          is_read_option      = lx_read_option
          it_label_type_range = lt_label_type
        IMPORTING
          ev_label_type       = lv_label_type
          es_label_content    = s_label_content.


      CHECK lv_label_type IS NOT INITIAL.
      CLEAR lv_is_exist.
      lv_is_exist = abap_false.
      PERFORM frm_populate_rm_batch USING    lv_is_exist
                                    CHANGING cv_error_ind.
    ENDIF.
  ENDIF.

ENDFORM.                    " FRM_LABEL_RECOG
*&---------------------------------------------------------------------*
*&      Form  FRM_POPULATE_FG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_populate_fg CHANGING cv_error_ind TYPE xfeld.

  DATA: lv_dummy TYPE bapi_msg,
        ls_linv  TYPE linv_vb.

  DATA: lit_linv           TYPE STANDARD TABLE OF linv_vb,
        lv_wminvdoc        TYPE string,
        lx_batch_char      TYPE bapi1003_alloc_values_char,
        lwa_batch_stock_wm TYPE zsits_batch_wm_stock.

  FIELD-SYMBOLS: <fs_linv> LIKE LINE OF it_linv.

  cv_error_ind = abap_true.

* Check whether batch was rolled up
*----------------------------------------------------------------------
  IF s_label_content-batch_data-batch_stock IS INITIAL.
    READ TABLE s_label_content-batch_data-batch_charact-valueschar
      INTO lx_batch_char
      WITH KEY charact = zcl_common_utility=>gc_chara_palletid.

*   if PALLET ID char is not initial, FG batch was rolled up
    IF sy-subrc EQ 0 AND lx_batch_char-value_char IS NOT INITIAL.
*     &1 Rolled-up!
      MESSAGE e221(zits) WITH s_label_content-batch_data-charg INTO lv_dummy.
      RETURN.
    ELSE.
*     Batch &1 has no available stock!
      MESSAGE e346(zits) WITH s_label_content-batch_data-charg INTO lv_dummy.
      RETURN.
    ENDIF.
  ENDIF.

* Check batch have WM stock
  IF s_label_content-batch_data-batch_stock_wm IS INITIAL.
*   Entered batch &1 has no WM stock.
    MESSAGE e435(zits) WITH s_label_content-batch_data-charg INTO lv_dummy.
    RETURN.
  ELSE.
    READ TABLE s_label_content-batch_data-batch_stock_wm TRANSPORTING NO FIELDS
         WITH KEY lgnum = x_profile-zzlgnum
                  lgtyp = v_storage_type.
    IF sy-subrc NE 0.
*     Entered batch &1 has no stock in Warehouse &2 with storage type &3.
      MESSAGE e436(zits) WITH s_label_content-batch_data-charg
                              x_profile-zzlgnum
                              v_storage_type
                         INTO lv_dummy.
      RETURN.
    ENDIF.
  ENDIF.

* Check whether batch was scanned before
*----------------------------------------------------------------------
  lv_wminvdoc = zsits_scan_dynp-zzwminvdoc.

  CALL METHOD zcl_its_utility=>physinv_content_operation
    EXPORTING
      iv_mode    = 'G'
      iv_id      = lv_wminvdoc
    CHANGING
      ct_content = lit_linv.

  READ TABLE lit_linv ASSIGNING <fs_linv> WITH KEY lgnum = x_profile-zzlgnum
                                                   ivnum = zsits_scan_dynp-zzwminvdoc
                                                   lgpla = zsits_scan_dynp-zzsbin
                                                   matnr = s_label_content-batch_data-matnr
                                                   charg = s_label_content-batch_data-charg.
  IF sy-subrc = 0.
*   &1 already counted.
    MESSAGE e432(zits) WITH s_label_content-batch_data-charg INTO lv_dummy.
    RETURN.
  ENDIF.

  READ TABLE it_linv ASSIGNING <fs_linv> WITH KEY lgnum = x_profile-zzlgnum
                                                  ivnum = zsits_scan_dynp-zzwminvdoc
                                                  lgpla = zsits_scan_dynp-zzsbin
                                                  matnr = s_label_content-batch_data-matnr
                                                  charg = s_label_content-batch_data-charg.
  IF sy-subrc EQ 0.
    IF <fs_linv>-istat EQ 'S' OR <fs_linv>-istat EQ 'L' OR <fs_linv>-istat EQ 'Z'   .
*     &1 on doc &2 was cancelled, counted or cleared !
      MESSAGE e429(zits) WITH s_label_content-batch_data-charg
                              zsits_scan_dynp-zzwminvdoc
                         INTO lv_dummy.
      RETURN.
    ENDIF.

    CLEAR ls_linv.
    ls_linv = <fs_linv>.
    ls_linv-menga = s_label_content-zzquantity.
    ls_linv-wdatu = sy-datlo.
  ELSE.
    CLEAR ls_linv.
    ls_linv-ivnum = zsits_scan_dynp-zzwminvdoc.
    ls_linv-lgpla = zsits_scan_dynp-zzsbin.
    ls_linv-menga = s_label_content-zzquantity.
    ls_linv-matnr = s_label_content-batch_data-matnr.
    ls_linv-meins = s_label_content-batch_data-meins.
    ls_linv-charg = s_label_content-batch_data-charg.
    ls_linv-wdatu = sy-datlo.

    READ TABLE s_label_content-batch_data-batch_stock_wm INTO lwa_batch_stock_wm
                                                         WITH KEY lgnum = x_profile-zzlgnum
                                                                  lgtyp = v_storage_type.
    IF sy-subrc = 0.
      ls_linv-lgnum = lwa_batch_stock_wm-lgnum.
      ls_linv-werks = lwa_batch_stock_wm-werks.
      ls_linv-lgort = lwa_batch_stock_wm-lgort.
      ls_linv-lgtyp = lwa_batch_stock_wm-lgtyp.

      IF lwa_batch_stock_wm-sobkz IS NOT INITIAL."Special stock indicator
        ls_linv-sobkz = lwa_batch_stock_wm-sobkz.
        ls_linv-sonum = lwa_batch_stock_wm-sonum.
      ENDIF.

      IF lwa_batch_stock_wm-bestq IS NOT INITIAL."Stock Category ('Q' = Stock in Quality Control; 'R' = Returns Stock; 'S' = Blocked Stock)
        ls_linv-bestq = lwa_batch_stock_wm-bestq.
      ENDIF.
    ENDIF.

  ENDIF.

  PERFORM frm_pass_data USING    abap_false " overwrite
                        CHANGING ls_linv.

  MESSAGE s452(zits) WITH s_label_content-batch_data-charg INTO zsits_scan_dynp-zzsuccess_msg.

  cv_error_ind = abap_false.

ENDFORM.                    " FRM_POPULATE_FG
*&---------------------------------------------------------------------*
*&      Form  FRM_POPULATE_RM_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_populate_rm_batch USING    uv_is_exist  TYPE boolean
                           CHANGING cv_error_ind TYPE xfeld.

  DATA: ls_linv              TYPE linv_vb,
        lit_linv             TYPE STANDARD TABLE OF linv_vb,
        lv_wminvdoc          TYPE string,
        lwa_counted_batch    TYPE ty_batch,
        lwa_batch_stock_wm   TYPE zsits_batch_wm_stock,
        lit_batch_stock_wm   TYPE STANDARD TABLE OF zsits_batch_wm_stock,
        lit_batch_stock_wm_c TYPE STANDARD TABLE OF zsits_batch_wm_stock,
        lv_stock_wm_num      TYPE i,
        lv_stock_cat_num     TYPE i.

  DATA: lv_batch       TYPE zzbatch,
        lx_read_option TYPE zsits_batch_read_option,
        lx_batch       TYPE zsits_batch_data,
        lv_dummy       TYPE bapi_msg.

  FIELD-SYMBOLS: <fs_linv> LIKE LINE OF it_linv.

  cv_error_ind = abap_true.

  IF uv_is_exist = abap_true."Exist Batch
    lx_batch = s_label_content-batch_data.
  ELSE."No exist batch - Get parent batch
    lx_read_option-zzstock_read = abap_true.
    lv_batch = s_label_content-zzorigin_batch.

    CALL METHOD zcl_batch_utility=>is_rw_batch
      EXPORTING
        iv_batch         = lv_batch
        iv_matnr         = s_label_content-batch_data-matnr
        iv_parent_batch  = s_label_content-zzorigin_batch
        is_read_option   = lx_read_option
        iv_unexist_check = abap_false
      RECEIVING
        rs_batch_data    = lx_batch.
    IF lx_batch IS INITIAL."Get parent batch error
      RETURN.
    ENDIF.
  ENDIF.

* Check whether batch was empty
  IF lx_batch-batch_stock IS INITIAL.
*   Batch &1 has no available stock!
    MESSAGE e346(zits) WITH lx_batch-charg INTO lv_dummy.
    RETURN.
  ENDIF.

* Check batch have WM stock
  IF lx_batch-batch_stock_wm IS INITIAL.
*   Entered batch &1 has no WM stock.
    MESSAGE e435(zits) WITH lx_batch-charg INTO lv_dummy.
    RETURN.
  ELSE.
    READ TABLE it_linv ASSIGNING <fs_linv> WITH KEY lgnum = x_profile-zzlgnum
                                                    ivnum = zsits_scan_dynp-zzwminvdoc
                                                    lgpla = zsits_scan_dynp-zzsbin
                                                    matnr = lx_batch-matnr
                                                    charg = lx_batch-charg.
    IF sy-subrc NE 0.
*     Check whether the batch was in more than one plant
      READ TABLE lx_batch-batch_stock_wm TRANSPORTING NO FIELDS
           WITH KEY lgnum = x_profile-zzlgnum
                    lgtyp = v_storage_type.
      IF sy-subrc NE 0.
*       Entered batch &1 has no stock in Warehouse &2 with storage type &3.
        MESSAGE e436(zits) WITH lx_batch-charg
                                x_profile-zzlgnum
                                v_storage_type
                           INTO lv_dummy.
        RETURN.
      ELSE.


        SORT lit_batch_stock_wm BY werks.
        DELETE ADJACENT DUPLICATES FROM lit_batch_stock_wm COMPARING werks.

        DESCRIBE TABLE lit_batch_stock_wm LINES lv_stock_wm_num.
        IF lv_stock_wm_num GT 1.
*         &1 has stock in multiple plants.
          MESSAGE e437(zits) WITH lx_batch-charg INTO lv_dummy.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF s_label_content-zzsublot IS INITIAL OR s_label_content-zzsublot EQ '000'.
    " Not Container RM Batch
    CLEAR ls_linv.
    READ TABLE it_linv ASSIGNING <fs_linv> WITH KEY lgnum = x_profile-zzlgnum
                                                    ivnum = zsits_scan_dynp-zzwminvdoc
                                                    lgpla = zsits_scan_dynp-zzsbin
                                                    matnr = s_label_content-batch_data-matnr
                                                    charg = s_label_content-batch_data-charg.
    IF sy-subrc EQ 0.
      IF <fs_linv>-istat EQ 'S' OR <fs_linv>-istat EQ 'L' OR <fs_linv>-istat EQ 'Z'   .
*       &1 on doc &2 was cancelled, counted or cleared !
        MESSAGE e429(zits) WITH s_label_content-batch_data-charg
                                zsits_scan_dynp-zzwminvdoc
                           INTO lv_dummy.
        RETURN.
      ENDIF.

      ls_linv = <fs_linv>.
      ls_linv-menga = s_label_content-zzquantity.
      ls_linv-wdatu = sy-datlo.              " ED2K904823 Localization
    ELSE.
      "Check if the current batch has multiple stock status
      lit_batch_stock_wm_c = s_label_content-batch_data-batch_stock_wm.
      SORT lit_batch_stock_wm_c BY bestq.
      DELETE ADJACENT DUPLICATES FROM lit_batch_stock_wm_c COMPARING bestq.
      DESCRIBE TABLE lit_batch_stock_wm_c LINES lv_stock_cat_num.
      IF lv_stock_cat_num GT 1.
        MESSAGE e453(zits) WITH s_label_content-batch_data-charg
                                zsits_scan_dynp-zzwminvdoc
                           INTO lv_dummy.
        RETURN.

      ELSE.
        ls_linv-ivnum = zsits_scan_dynp-zzwminvdoc.
        ls_linv-lgpla = zsits_scan_dynp-zzsbin.
        ls_linv-menga = s_label_content-zzquantity.
        ls_linv-matnr = s_label_content-batch_data-matnr.
        ls_linv-meins = s_label_content-batch_data-meins.
        ls_linv-charg = s_label_content-batch_data-charg.
        ls_linv-wdatu = sy-datlo.              " ED2K904823 Localization

        READ TABLE s_label_content-batch_data-batch_stock_wm INTO lwa_batch_stock_wm
                                                             WITH KEY lgnum = x_profile-zzlgnum
                                                                      lgtyp = v_storage_type.
        IF sy-subrc = 0.
          ls_linv-lgnum = lwa_batch_stock_wm-lgnum.
          ls_linv-werks = lwa_batch_stock_wm-werks.
          ls_linv-lgort = lwa_batch_stock_wm-lgort.
          ls_linv-lgtyp = lwa_batch_stock_wm-lgtyp.

          IF lwa_batch_stock_wm-sobkz IS NOT INITIAL."Special stock indicator
            ls_linv-sobkz = lwa_batch_stock_wm-sobkz.
            ls_linv-sonum = lwa_batch_stock_wm-sonum.
          ENDIF.

          IF lwa_batch_stock_wm-bestq IS NOT INITIAL."Stock Category ('Q' = Stock in Quality Control; 'R' = Returns Stock; 'S' = Blocked Stock)
            ls_linv-bestq = lwa_batch_stock_wm-bestq.
          ENDIF.
        ENDIF.

      ENDIF.
      PERFORM frm_pass_data USING    abap_true " aggregate
                            CHANGING ls_linv.
    ENDIF.
  ENDIF.

  IF NOT ( s_label_content-zzsublot IS INITIAL OR s_label_content-zzsublot EQ '000'). " Container RM Batch
    IF uv_is_exist = abap_true."Exist Container Batch
*     Check whether the container batch was scanned or not
      lv_wminvdoc = zsits_scan_dynp-zzwminvdoc.

      CALL METHOD zcl_its_utility=>physinv_content_operation
        EXPORTING
          iv_mode    = 'G'
          iv_id      = lv_wminvdoc
        CHANGING
          ct_content = lit_linv.

      READ TABLE lit_linv ASSIGNING <fs_linv> WITH KEY lgnum = x_profile-zzlgnum
                                                       ivnum = zsits_scan_dynp-zzwminvdoc
                                                       lgpla = zsits_scan_dynp-zzsbin
                                                       matnr = s_label_content-batch_data-matnr
                                                       charg = s_label_content-batch_data-charg.
      IF sy-subrc = 0.
*       &1 already counted.
        MESSAGE e432(zits) WITH s_label_content-batch_data-charg INTO lv_dummy.
        RETURN.
      ENDIF.

      zsits_scan_dynp-zzbchmtr = s_label_content-zzbatch.
      zsits_scan_dynp-zzsuom   = s_label_content-batch_data-meins.
      CLEAR zsits_scan_dynp-zzquantity.
      CALL SCREEN 9300.
      IF v_back_flag EQ abap_true.
        LEAVE TO SCREEN 0.
      ENDIF.
    ELSE." Container RM batch not exist in SAP
*     Check whether the container batch was scanned or not
      SORT it_counted_rm_batch BY charg.
      READ TABLE it_counted_rm_batch INTO lwa_counted_batch
                                     WITH KEY charg = s_label_content-batch_data-charg BINARY SEARCH.
      IF sy-subrc = 0.
*       &1 already counted.
        MESSAGE e432(zits) WITH s_label_content-batch_data-charg INTO lv_dummy.
        RETURN.
      ENDIF.

      CLEAR lwa_counted_batch.
      lwa_counted_batch-charg = s_label_content-batch_data-charg.
      APPEND lwa_counted_batch TO it_counted_rm_batch.

      READ TABLE it_linv ASSIGNING <fs_linv> WITH KEY lgnum = x_profile-zzlgnum
                                                      ivnum = zsits_scan_dynp-zzwminvdoc
                                                      lgpla = zsits_scan_dynp-zzsbin
                                                      matnr = s_label_content-batch_data-matnr
                                                      charg = lx_batch-charg."s_label_content-zzorigin_batch.
      IF sy-subrc EQ 0.
        IF <fs_linv>-istat EQ 'S' OR <fs_linv>-istat EQ 'L' OR <fs_linv>-istat EQ 'Z'   .
*         &1 on doc &2 was cancelled, counted or cleared !
          MESSAGE e429(zits) WITH lx_batch-charg"s_label_content-batch_data-charg
                                  zsits_scan_dynp-zzwminvdoc
                             INTO lv_dummy.
          RETURN.
        ENDIF.

        ls_linv = <fs_linv>.
        ls_linv-menga = s_label_content-zzquantity.
        ls_linv-wdatu = sy-datlo.              " ED2K904823 Localization
      ELSE.
        "Check if the current batch has multiple stock status
        lit_batch_stock_wm_c = lx_batch-batch_stock_wm.
        SORT lit_batch_stock_wm_c BY bestq.
        DELETE ADJACENT DUPLICATES FROM lit_batch_stock_wm_c COMPARING bestq.
        DESCRIBE TABLE lit_batch_stock_wm_c LINES lv_stock_cat_num.
        IF lv_stock_cat_num GT 1.
          MESSAGE e453(zits) WITH lx_batch-charg
                                  zsits_scan_dynp-zzwminvdoc
                             INTO lv_dummy.
          RETURN.

        ELSE.

          ls_linv-ivnum = zsits_scan_dynp-zzwminvdoc.
          ls_linv-lgpla = zsits_scan_dynp-zzsbin.
          ls_linv-menga = s_label_content-zzquantity.
          ls_linv-matnr = s_label_content-batch_data-matnr.
          ls_linv-meins = lx_batch-meins.
          ls_linv-charg = lx_batch-charg.
          ls_linv-wdatu = sy-datlo.

          READ TABLE lx_batch-batch_stock_wm INTO lwa_batch_stock_wm
                                             WITH KEY lgnum = x_profile-zzlgnum
                                                      lgtyp = v_storage_type.
          IF sy-subrc = 0.
            ls_linv-lgnum = lwa_batch_stock_wm-lgnum.
            ls_linv-werks = lwa_batch_stock_wm-werks.
            ls_linv-lgort = lwa_batch_stock_wm-lgort.
            ls_linv-lgtyp = lwa_batch_stock_wm-lgtyp.

            IF lwa_batch_stock_wm-sobkz IS NOT INITIAL."Special stock indicator
              ls_linv-sobkz = lwa_batch_stock_wm-sobkz.
              ls_linv-sonum = lwa_batch_stock_wm-sonum.
            ENDIF.

            IF lwa_batch_stock_wm-bestq IS NOT INITIAL."Stock Category ('Q' = Stock in Quality Control; 'R' = Returns Stock; 'S' = Blocked Stock)
              ls_linv-bestq = lwa_batch_stock_wm-bestq.
            ENDIF.
          ENDIF.

        ENDIF.

        PERFORM frm_pass_data USING    abap_true " aggregate
                              CHANGING ls_linv.
      ENDIF.
    ENDIF.

  ENDIF.

  MESSAGE s452(zits) WITH lx_batch-charg INTO zsits_scan_dynp-zzsuccess_msg.

  cv_error_ind = abap_false.

ENDFORM.                    " FRM_POPULATE_RM_BATCH
*&---------------------------------------------------------------------*
*&      Form  FRM_POPULATE_RM_NOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_CV_ERROR_IND  text
*----------------------------------------------------------------------*
FORM frm_populate_rm_nob CHANGING cv_error_ind TYPE xfeld.

  DATA: ls_linv           TYPE linv_vb,
        lwa_material_data TYPE zsits_material_data,
        lwa_mat_wm_stock  TYPE LINE OF zttits_material_wm_stock,
        lv_material_str   TYPE string,
        lv_dummy          TYPE bapi_msg.

  FIELD-SYMBOLS: <fs_linv> LIKE LINE OF it_linv.

  cv_error_ind = abap_true.

  READ TABLE it_linv ASSIGNING <fs_linv> WITH KEY lgnum = x_profile-zzlgnum
                                                  ivnum = zsits_scan_dynp-zzwminvdoc
                                                  lgpla = zsits_scan_dynp-zzsbin
                                                  matnr = s_label_content-zzmatnr.
  IF sy-subrc = 0.
    IF <fs_linv>-istat EQ 'S' OR <fs_linv>-istat EQ 'L' OR <fs_linv>-istat EQ 'Z'.
      lv_material_str = s_label_content-zzmatnr.
      SHIFT lv_material_str LEFT DELETING LEADING '0'.

*     &1 on doc &2 was cancelled, counted or cleared !
      MESSAGE e429(zits) WITH lv_material_str
                              zsits_scan_dynp-zzwminvdoc
                         INTO lv_dummy.
      RETURN.
    ENDIF.

    CLEAR ls_linv.
    ls_linv = <fs_linv>.
    ls_linv-menga = s_label_content-zzquantity.
    ls_linv-wdatu = sy-datlo.
  ELSE.
*   Check WM stock
    PERFORM frm_check_rm_stock USING    s_label_content-zzmatnr
                               CHANGING cv_error_ind
                                        lwa_material_data.

    IF cv_error_ind = abap_true.
      RETURN.
    ENDIF.

    CLEAR ls_linv.
    ls_linv-ivnum = zsits_scan_dynp-zzwminvdoc.
    ls_linv-lgpla = zsits_scan_dynp-zzsbin.
    ls_linv-menga = s_label_content-zzquantity.
    ls_linv-matnr = s_label_content-zzmatnr.
    SELECT SINGLE meins INTO ls_linv-meins FROM mara WHERE matnr = s_label_content-zzmatnr.
    ls_linv-wdatu = sy-datlo.

    READ TABLE lwa_material_data-wm_stock INTO lwa_mat_wm_stock
                                          WITH KEY lgnum = x_profile-zzlgnum
                                                   lgtyp = v_storage_type.
    IF sy-subrc = 0.
      ls_linv-lgnum = lwa_mat_wm_stock-lgnum.
      ls_linv-werks = lwa_mat_wm_stock-werks.
      ls_linv-lgort = lwa_mat_wm_stock-lgort.
      ls_linv-lgtyp = lwa_mat_wm_stock-lgtyp.

      IF lwa_mat_wm_stock-sobkz IS NOT INITIAL."Special stock indicator
        ls_linv-sobkz = lwa_mat_wm_stock-sobkz.
        ls_linv-sonum = lwa_mat_wm_stock-sonum.
      ENDIF.

      IF lwa_mat_wm_stock-bestq IS NOT INITIAL."Stock Category ('Q' = Stock in Quality Control; 'R' = Returns Stock; 'S' = Blocked Stock)
        ls_linv-bestq = lwa_mat_wm_stock-bestq.
      ENDIF.
    ENDIF.

  ENDIF.

  PERFORM frm_pass_data USING    abap_true " aggregate
                        CHANGING ls_linv.

  MESSAGE s452(zits) WITH s_label_content-zzmatnr INTO zsits_scan_dynp-zzsuccess_msg.

  cv_error_ind = abap_false.

ENDFORM.                    " FRM_POPULATE_RM_NOB
*&---------------------------------------------------------------------*
*&      Form  FRM_POPULATE_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_populate_container CHANGING cv_error_ind TYPE xfeld.

  DATA:
    ls_linv   TYPE linv_vb.
  FIELD-SYMBOLS:
    <fs_linv> LIKE LINE OF it_linv.

  cv_error_ind = abap_true.

  READ TABLE it_linv ASSIGNING <fs_linv> WITH KEY lgnum = x_profile-zzlgnum
                                                  ivnum = zsits_scan_dynp-zzwminvdoc
                                                  lgpla = zsits_scan_dynp-zzsbin
                                                  matnr = s_label_content-batch_data-matnr
                                                  charg = s_label_content-batch_data-charg.
  IF sy-subrc = 0.
    ls_linv = <fs_linv>.
    ls_linv-menga = zsits_scan_dynp-zzquantity.
    ls_linv-meins = zsits_scan_dynp-zzsuom.
    ls_linv-wdatu = sy-datlo.
  ELSE.
    READ TABLE it_linv ASSIGNING <fs_linv> WITH KEY lgnum = x_profile-zzlgnum
                                                    ivnum = zsits_scan_dynp-zzwminvdoc
                                                    lgpla = zsits_scan_dynp-zzsbin.
    IF sy-subrc EQ 0.
      ls_linv-werks = <fs_linv>-werks.
      ls_linv-lgort = <fs_linv>-lgort.
      ls_linv-lgtyp = <fs_linv>-lgtyp.
      ls_linv-lgnum = x_profile-zzlgnum.
      ls_linv-ivnum = zsits_scan_dynp-zzwminvdoc.
      ls_linv-lgpla = zsits_scan_dynp-zzsbin.
      ls_linv-menga = zsits_scan_dynp-zzquantity.
      ls_linv-matnr = s_label_content-batch_data-matnr.
      ls_linv-meins = zsits_scan_dynp-zzsuom.
      ls_linv-charg = s_label_content-zzbatch.
      ls_linv-wdatu = sy-datlo.
    ENDIF.
  ENDIF.

  PERFORM frm_pass_data USING    abap_false " overwrite
                        CHANGING ls_linv.

  MESSAGE s357(zits) INTO zsits_scan_dynp-zzsuccess_msg.
  LEAVE TO SCREEN 0.

  cv_error_ind = abap_false.

ENDFORM.                    " FRM_POPULATE_CONTAINER

**&---------------------------------------------------------------------*
**&      Form  FRM_SET_QUANTITY
**&---------------------------------------------------------------------*
**       Set quantity
**----------------------------------------------------------------------*
                  " FRM_SET_QUANTITY

*&---------------------------------------------------------------------*
*&      Form  FRM_USER_COMMAND_9100
*&---------------------------------------------------------------------*
*       User command 9100
*----------------------------------------------------------------------*
FORM frm_user_command_9100.

  v_code = ok_code.
  CLEAR ok_code.

  CASE v_code.
    WHEN 'ZBACK'.
      CLEAR: zsits_scan_dynp, v_bin_on_doc, v_su_m_bool.
      LEAVE TO SCREEN 0.
    WHEN 'ZDOC'.
      PERFORM frm_doc_comp.
  ENDCASE.

ENDFORM.                    " FRM_USER_COMMAND_9100

*&---------------------------------------------------------------------*
*&      Form  FRM_USER_COMMAND_9200
*&---------------------------------------------------------------------*
*       User command 9200
*----------------------------------------------------------------------*
FORM frm_user_command_9200.
  v_code = ok_code.
  CLEAR ok_code.

  CASE v_code.
    WHEN 'ZBACK'. " Back
      CLEAR zsits_scan_dynp-zzbchmtr.
      CLEAR zsits_scan_dynp-zzsbin.
      CLEAR zsits_scan_dynp-zzsuccess_msg.
      CLEAR : zsits_scan_dynp-zzquantity.

      LEAVE TO SCREEN 0.
    WHEN 'ZEBIN'. " Empty Bin
      PERFORM frm_bin_empty.

      CLEAR: zsits_scan_dynp-zzbchmtr,
             zsits_scan_dynp-zzquantity,
             zsits_scan_dynp-zzsbin,
             zsits_scan_dynp-zzsuom,
             zsits_scan_dynp-zzsuccess_msg.
      CLEAR:
                   zsits_scan_dynp-zzsuccess_msg.
      LEAVE TO SCREEN 0.                                    " c_9100.
    WHEN 'ZCBIN'. " Bin Complete
      PERFORM frm_bin_comp_9200.

    WHEN 'ZDOC'.  " Doc. Completed
      PERFORM frm_doc_comp_9200.

  ENDCASE.
ENDFORM.                    " FRM_USER_COMMAND_9200

*&---------------------------------------------------------------------*
*&      Form  FRM_USER_COMMAND_9300
*&---------------------------------------------------------------------*
*       User command 9300
*----------------------------------------------------------------------*
FORM frm_user_command_9300.
  v_code = ok_code.
  CLEAR ok_code.

  CASE v_code.
    WHEN 'ZBACK'.
      CLEAR zsits_scan_dynp-zzbchmtr.
      CLEAR zsits_scan_dynp-zzquantity.
      LEAVE TO SCREEN 0.
    WHEN 'ZNEXT'.
      CLEAR: zsits_scan_dynp-zzbchmtr,
             zsits_scan_dynp-zzquantity,
             zsits_scan_dynp-zzsuom.
      LEAVE TO SCREEN c_9200.
    WHEN 'ZEBIN'.
      PERFORM frm_bin_empty.

      CLEAR: zsits_scan_dynp-zzbchmtr,
             zsits_scan_dynp-zzquantity,
             zsits_scan_dynp-zzsbin,
             zsits_scan_dynp-zzsuom.
      LEAVE TO SCREEN c_9100.
    WHEN 'ZCBIN'."Bin Complete
      PERFORM frm_bin_comp.

      CLEAR: zsits_scan_dynp-zzbchmtr,
             zsits_scan_dynp-zzquantity,
             zsits_scan_dynp-zzsbin,
             zsits_scan_dynp-zzsuom.
      LEAVE TO SCREEN c_9100.
    WHEN 'ZDOC'.
      PERFORM frm_doc_comp.
  ENDCASE.
ENDFORM.                    " FRM_USER_COMMAND_9300

*&---------------------------------------------------------------------*
*&      Form  FRM_DOC_COMP
*&---------------------------------------------------------------------*
*       Doc complete confirmation page
*----------------------------------------------------------------------*
FORM frm_doc_comp .

  DATA: lv_confirm TYPE char01,                             "#EC NEEDED
        lv_dummy   TYPE bapi_msg,                           "#EC NEEDED
        c_y        TYPE char01 VALUE 'Y',                   "#EC NEEDED
        c_n        TYPE char01 VALUE 'N'.                   "#EC NEEDED

  MESSAGE e113(zits) WITH zsits_scan_dynp-zzwminvdoc INTO lv_dummy.

  CALL METHOD zcl_its_utility=>message_confirm
    IMPORTING
      ev_result = lv_confirm.

  IF lv_confirm = c_y.
    PERFORM frm_commit_count.
  ELSEIF lv_confirm = c_n.
    CLEAR:
      zsits_scan_dynp-zzbarcode,
      zsits_scan_dynp-zzquantity,
      zsits_scan_dynp-zzsuom.                                    " c_9100.
  ENDIF.

ENDFORM.                    " FRM_DOC_COMP

*&---------------------------------------------------------------------*
*&      Form  FRM_COMMIT_COUNT
*&---------------------------------------------------------------------*
*       Commit count
*----------------------------------------------------------------------*
FORM frm_commit_count .
  DATA: lv_bool     TYPE boolean,
        lv_dummy    TYPE bapi_msg,                          "#EC NEEDED
        lv_wminvdoc TYPE string,
        lit_linv    TYPE STANDARD TABLE OF linv_vb,
        lit_linv_ag TYPE STANDARD TABLE OF linv_vb,
        lwa_linv    TYPE linv_vb.

  DATA: lv_wminvdoc_str TYPE string.

  DATA: lv_uncomplete_bin TYPE lgpla.

  lv_wminvdoc = zsits_scan_dynp-zzwminvdoc.

  CALL METHOD zcl_its_utility=>physinv_content_operation
    EXPORTING
      iv_mode    = 'G'
      iv_id      = lv_wminvdoc
    CHANGING
      ct_content = lit_linv.

*----------------------------------------------------------------------
* Check whether all storage bin was completed
  IF it_completed_bin IS NOT INITIAL.
    SORT it_completed_bin BY lgpla.
    CLEAR lv_uncomplete_bin.

    LOOP AT it_linv INTO lwa_linv WHERE istat NE 'S'  "cancelled
                                    AND istat NE 'Z'  "counted
                                    AND istat NE 'L'. "cleared
      READ TABLE it_completed_bin TRANSPORTING NO FIELDS WITH KEY lgpla = lwa_linv-lgpla BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_uncomplete_bin = lwa_linv-lgpla.
        EXIT.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT it_linv INTO lwa_linv WHERE istat NE 'S'  "cancelled
                                    AND istat NE 'Z'  "counted
                                    AND istat NE 'L'. "cleared
      lv_uncomplete_bin = lwa_linv-lgpla.
      EXIT.
    ENDLOOP.
  ENDIF.

  IF lv_uncomplete_bin IS NOT INITIAL.
*   Bin &1 was not completed yet.
    MESSAGE e428(zits) WITH lv_uncomplete_bin INTO lv_dummy.
    PERFORM frm_message_add USING zcl_its_utility=>gc_objid_invdoc
                                  lv_bool
                                  abap_true.
    RETURN.
  ENDIF.

* Mark the inv doc. item which was not scanned as zero count
  SORT lit_linv BY lgnum ivnum ivpos lqnum nanum.
  LOOP AT it_linv INTO lwa_linv WHERE istat NE 'S'  "cancelled
                                  AND istat NE 'Z'  "counted
                                  AND istat NE 'L'. "cleared
    READ TABLE lit_linv TRANSPORTING NO FIELDS WITH KEY lgnum = lwa_linv-lgnum
                                                        ivnum = lwa_linv-ivnum
                                                        ivpos = lwa_linv-ivpos
                                                        lqnum = lwa_linv-lqnum
                                                        nanum = lwa_linv-nanum
                                                        BINARY SEARCH.
    IF sy-subrc NE 0.
      lwa_linv-menga = 0."zero count
      APPEND lwa_linv TO lit_linv_ag.
    ENDIF.
  ENDLOOP.

  LOOP AT lit_linv INTO lwa_linv.
    APPEND lwa_linv TO lit_linv_ag.
  ENDLOOP.

  IF gt_zlwminvdoc IS NOT INITIAL.
    PERFORM update_zlwminvdoc_final USING gt_zlwminvdoc.
  ENDIF.
* Update the custom table


*-----Count physical inv doc. LI11.
  IF zcl_its_utility=>physinv_wm_count( it_linv = lit_linv_ag ) EQ abap_false.

    CALL METHOD zcl_its_utility=>physinv_content_operation
      EXPORTING
        iv_mode    = 'S'
        iv_id      = lv_wminvdoc
      CHANGING
        ct_content = lit_linv_ag.

    PERFORM frm_message_add USING zcl_its_utility=>gc_objid_invdoc
                                  lv_bool
                                  abap_true.
    CLEAR zsits_scan_dynp.
    v_back_flag = abap_true.
    LEAVE TO SCREEN 0.                                      " c_9000.
  ELSE.
    CALL METHOD zcl_its_utility=>physinv_content_operation
      EXPORTING
        iv_mode = 'D'
        iv_id   = lv_wminvdoc.

    lv_wminvdoc_str = zsits_scan_dynp-zzwminvdoc.
    SHIFT lv_wminvdoc_str LEFT DELETING LEADING '0'.

*   &1 counted.
    MESSAGE s426(zits) WITH lv_wminvdoc_str INTO zsits_scan_dynp-zzsuccess_msg.

    v_back_flag = abap_true.
    LEAVE TO SCREEN 0.
  ENDIF.

ENDFORM.                    " FRM_COMMIT_COUNT

*&---------------------------------------------------------------------*
*&      Form  frm_add_label_type
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_LABEL_TYPE   text
*      <--CT_LABEL_RANGE  text
*----------------------------------------------------------------------*
FORM frm_add_label_type  USING    uv_label_type  TYPE zdits_label_type
                         CHANGING ct_label_range TYPE ztlabel_type_range.

  DATA: ls_label_range LIKE LINE OF ct_label_range.

  ls_label_range-sign   = 'I'.
  ls_label_range-zoption = 'EQ'.
  ls_label_range-low    = uv_label_type.
  APPEND ls_label_range TO ct_label_range.

ENDFORM.                    " FRM_ADD_LABEL_TYPE

*&---------------------------------------------------------------------*
*&      Form  FRM_BIN_COMP
*&---------------------------------------------------------------------*
FORM frm_bin_comp .

  DATA: lwa_completed_bin TYPE ty_bin,
        lwa_linv          LIKE LINE OF it_linv.

  DATA: lit_linv    TYPE STANDARD TABLE OF linv_vb,
        lv_wminvdoc TYPE string.

* Step 1: Add Bin to internal table
*----------------------------------------------------------------------
  CLEAR lwa_completed_bin.
  lwa_completed_bin-lgpla = zsits_scan_dynp-zzsbin.
  APPEND lwa_completed_bin TO it_completed_bin.

* Step 2: Mark other items of the same bin as zero count
*----------------------------------------------------------------------
  lv_wminvdoc = zsits_scan_dynp-zzwminvdoc.

  CALL METHOD zcl_its_utility=>physinv_content_operation
    EXPORTING
      iv_mode    = 'G'
      iv_id      = lv_wminvdoc
    CHANGING
      ct_content = lit_linv.

  SORT lit_linv BY lgnum ivnum ivpos lqnum nanum.

  LOOP AT it_linv INTO lwa_linv WHERE lgpla EQ zsits_scan_dynp-zzsbin
                                  AND istat NE 'S'  "cancelled
                                  AND istat NE 'Z'  "counted
                                  AND istat NE 'L'. "cleared

    READ TABLE lit_linv TRANSPORTING NO FIELDS WITH KEY lgnum = lwa_linv-lgnum
                                                        ivnum = lwa_linv-ivnum
                                                        ivpos = lwa_linv-ivpos
                                                        lqnum = lwa_linv-lqnum
                                                        nanum = lwa_linv-nanum
                                                        BINARY SEARCH.
    IF sy-subrc NE 0.
      lwa_linv-menga = 0. "set counted quantity to 0
      PERFORM frm_pass_data USING    abap_false " overwrite
                            CHANGING lwa_linv.
    ENDIF.
  ENDLOOP.

  PERFORM add_su2report USING zsits_scan_dynp
                              is_su_data-su_header
                                CHANGING gt_zlwminvdoc.




ENDFORM.                    " FRM_BIN_COMP

*&---------------------------------------------------------------------*
*&      Form  FRM_CHECK_RM_STOCK
*&---------------------------------------------------------------------*
FORM frm_check_rm_stock  USING    uv_matnr         TYPE matnr
                         CHANGING cv_error_ind     TYPE boolean
                                  cs_material_data TYPE zsits_material_data.

  DATA: lwa_key          TYPE zsits_material_read_para,
        lit_mat_wm_stock TYPE zttits_material_wm_stock,
        lwa_mat_wm_stock TYPE LINE OF zttits_material_wm_stock,
        lv_stock_wm_num  TYPE i,
        lv_material_str  TYPE string,
        lv_dummy         TYPE string.

  cv_error_ind = abap_true.

  lv_material_str = uv_matnr.
  SHIFT lv_material_str LEFT DELETING LEADING '0'.

  lwa_key-matnr      = uv_matnr.
  lwa_key-stock_read = abap_true.

  CALL METHOD zcl_its_utility=>material_read
    EXPORTING
      is_key           = lwa_key
    RECEIVING
      rs_material_data = cs_material_data.

  IF cs_material_data-wm_stock IS INITIAL.
*   &1 has no WM stock.
    MESSAGE e435(zits) WITH lv_material_str INTO lv_dummy.
    RETURN.
  ELSE.
    READ TABLE cs_material_data-wm_stock TRANSPORTING NO FIELDS
                                         WITH KEY lgnum = x_profile-zzlgnum
                                                  lgtyp = v_storage_type.
    IF sy-subrc NE 0.
*     &1 has no stock in Warehouse &2 with storage type &3.
      MESSAGE e436(zits) WITH lv_material_str
                              x_profile-zzlgnum
                              v_storage_type
                         INTO lv_dummy.
      RETURN.
    ELSE.
      LOOP AT cs_material_data-wm_stock INTO lwa_mat_wm_stock WHERE lgnum = x_profile-zzlgnum
                                                                AND lgtyp = v_storage_type.
        APPEND lwa_mat_wm_stock TO lit_mat_wm_stock.
      ENDLOOP.

      SORT lit_mat_wm_stock BY werks.
      DELETE ADJACENT DUPLICATES FROM lit_mat_wm_stock COMPARING werks.

      DESCRIBE TABLE lit_mat_wm_stock LINES lv_stock_wm_num.
      IF lv_stock_wm_num GT 1.
*       &1 has stock in multiple plants.
        MESSAGE e437(zits) WITH lv_material_str INTO lv_dummy.
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

  cv_error_ind = abap_false.

ENDFORM.                    " FRM_CHECK_RM_STOCK

*&---------------------------------------------------------------------*
*&      Form  FRM_BIN_EMPTY
*&---------------------------------------------------------------------*
FORM frm_bin_empty .

  DATA: lwa_completed_bin TYPE ty_bin,
        lwa_linv          LIKE LINE OF it_linv.

  DATA: lit_linv    TYPE STANDARD TABLE OF linv_vb,
        lv_wminvdoc TYPE string.

  DATA: lv_dummy TYPE string.

* Step 1: Check whether the bin can be emptied or not
*----------------------------------------------------------------------
  lv_wminvdoc = zsits_scan_dynp-zzwminvdoc.

  CALL METHOD zcl_its_utility=>physinv_content_operation
    EXPORTING
      iv_mode    = 'G'
      iv_id      = lv_wminvdoc
    CHANGING
      ct_content = lit_linv.

  SORT lit_linv BY lgpla.
  READ TABLE lit_linv TRANSPORTING NO FIELDS WITH KEY lgpla = zsits_scan_dynp-zzsbin
                                                      BINARY SEARCH.
  IF sy-subrc = 0.
*   Bin &1 can not be emptied because it has been counted.
    MESSAGE e439(zits) WITH zsits_scan_dynp-zzsbin INTO lv_dummy.

    PERFORM frm_message_add  USING zcl_its_utility=>gc_objid_bin
                                   zsits_scan_dynp-zzsbin
                                   abap_true.

    RETURN.
  ENDIF.

* Step 2: Add Bin to internal table
*----------------------------------------------------------------------
  CLEAR lwa_completed_bin.
  lwa_completed_bin-lgpla = zsits_scan_dynp-zzsbin.
  APPEND lwa_completed_bin TO it_completed_bin.

* Step 3: Mark other items of the same bin as zero count
*----------------------------------------------------------------------
  LOOP AT it_linv INTO lwa_linv WHERE lgpla EQ zsits_scan_dynp-zzsbin
                                  AND istat NE 'S'  "cancelled
                                  AND istat NE 'Z'  "counted
                                  AND istat NE 'L'. "cleared
    lwa_linv-menga = 0. "set counted quantity to 0
    PERFORM frm_pass_data USING    abap_false " overwrite
                          CHANGING lwa_linv.
  ENDLOOP.

ENDFORM.                    " FRM_BIN_EMPTY
*&---------------------------------------------------------------------*
*&      Form  ADD_SU2REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZSITS_SCAN_DYNP  text
*      -->P_IS_SU_DATA_SU_HEADER_LENUM  text
*----------------------------------------------------------------------*
FORM add_su2report  USING    i_zsits_scan_dynp TYPE zsits_scan_dynp
                             i_su_header TYPE lein
                    CHANGING ct_zlwminvdoc TYPE tt_zlwminvdoc.

*check if the HU has already been sfcanned
  READ TABLE ct_zlwminvdoc TRANSPORTING NO FIELDS
                           WITH KEY lgnum = i_su_header-lgnum
                                    ivnum = i_zsits_scan_dynp-zzwminvdoc
                                    zsbin = i_zsits_scan_dynp-zzsbin
                                    lgtyp = i_su_header-lgtyp
                                    lenum = i_su_header-lenum
                                    idatu = sy-datum
                            BINARY SEARCH.
  IF sy-subrc NE 0.
    APPEND INITIAL LINE TO ct_zlwminvdoc ASSIGNING FIELD-SYMBOL(<ls_zlwminvdoc>).
    <ls_zlwminvdoc>-mandt = sy-mandt.
    <ls_zlwminvdoc>-lgnum = i_su_header-lgnum.
    <ls_zlwminvdoc>-ivnum = i_zsits_scan_dynp-zzwminvdoc.
    <ls_zlwminvdoc>-zsbin = i_zsits_scan_dynp-zzsbin.
    <ls_zlwminvdoc>-lgtyp = i_su_header-lgtyp.
    <ls_zlwminvdoc>-lenum = i_su_header-lenum.
    <ls_zlwminvdoc>-idatu = sy-datum.
    <ls_zlwminvdoc>-uname = sy-uname.
    <ls_zlwminvdoc>-zabin = i_su_header-lgpla.

    SORT ct_zlwminvdoc BY lgnum ivnum zsbin lgtyp lenum idatu.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZLWMINVDOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM update_zlwminvdoc  USING    it_zlwminvdoc TYPE tt_zlwminvdoc
                                 is_zsits_scan_dynp  TYPE zsits_scan_dynp.
*Update the custom table with the additional HUs scanned in a bin
  DATA: lt_zlwminvdoc TYPE tt_zlwminvdoc,
        lv_tabix      TYPE sy-tabix.


  READ TABLE it_zlwminvdoc TRANSPORTING NO FIELDS
                           WITH KEY ivnum = is_zsits_scan_dynp-zzwminvdoc
                                    zsbin = is_zsits_scan_dynp-zzsbin
                           BINARY SEARCH.
  IF sy-subrc EQ 0.
    lv_tabix = sy-tabix.

    LOOP AT it_zlwminvdoc ASSIGNING FIELD-SYMBOL(<ls_zlwminvdoc>) FROM lv_tabix.
      IF <ls_zlwminvdoc>-zsbin NE  is_zsits_scan_dynp-zzsbin.
        EXIT.
      ENDIF.
      IF <ls_zlwminvdoc>-ivnum NE is_zsits_scan_dynp-zzwminvdoc.
        EXIT.
      ENDIF.
      APPEND <ls_zlwminvdoc> TO lt_zlwminvdoc.
    ENDLOOP.
  ENDIF.

  IF lt_zlwminvdoc IS INITIAL .
    RETURN.
  ENDIF.

  READ TABLE  lt_zlwminvdoc ASSIGNING <ls_zlwminvdoc> INDEX 1.
  IF sy-subrc EQ 0.
*Update the table
    CALL FUNCTION 'ENQUEUE_EZLWMINVDOC'
      EXPORTING
        mode_zlwminvdoc = 'E'
        mandt           = sy-mandt
        lgnum           = <ls_zlwminvdoc>-lgnum
        ivnum           = <ls_zlwminvdoc>-ivnum
        x_lgnum         = 'X '
        x_ivnum         = 'X'
      EXCEPTIONS
        foreign_lock    = 1
        system_failure  = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    MODIFY zlwminvdoc FROM TABLE lt_zlwminvdoc.

    CALL FUNCTION 'DEQUEUE_EZLWMINVDOC'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZLWMINVDOC_FINAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM update_zlwminvdoc_final  USING it_zlwminvdoc TYPE tt_zlwminvdoc.

*Update the custom table with the additional HUs scanned in warehouse
  IF it_zlwminvdoc IS INITIAL.
    RETURN.
  ENDIF.

*  READ TABLE it_zlwminvdoc ASSIGNING FIELD-SYMBOL(<ls_zlwminvdoc>) INDEX 1.
  LOOP AT it_zlwminvdoc ASSIGNING FIELD-SYMBOL(<ls_zlwminvdoc>).
    CALL FUNCTION 'ENQUEUE_EZLWMINVDOC'
      EXPORTING
        mode_zlwminvdoc = 'E'
        mandt           = sy-mandt
        lgnum           = <ls_zlwminvdoc>-lgnum
        ivnum           = <ls_zlwminvdoc>-ivnum
        x_lgnum         = 'X '
        x_ivnum         = 'X'
      EXCEPTIONS
        foreign_lock    = 1
        system_failure  = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    MODIFY zlwminvdoc FROM TABLE it_zlwminvdoc.

    CALL FUNCTION 'DEQUEUE_EZLWMINVDOC'.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_PASS_DATA_9200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ABAP_FALSE  text
*      <--P_LS_LINV  text
*----------------------------------------------------------------------*
FORM frm_pass_data_9200  USING    uv_aggregate TYPE boolean
                         CHANGING cv_linv      TYPE linv_vb.

*-----update selected data to database
  DATA: lit_linv    TYPE STANDARD TABLE OF linv_vb,
        lv_wminvdoc TYPE string.
  TYPES:tt_linv_vb    TYPE STANDARD TABLE OF linv_vb.
  FIELD-SYMBOLS: <fs_linv> LIKE LINE OF lit_linv.

  lv_wminvdoc = zsits_scan_dynp-zzwminvdoc.

  IF it_completed_bin IS NOT INITIAL.
    CALL METHOD zcl_its_utility=>physinv_content_operation
      EXPORTING
        iv_mode    = 'G'
        iv_id      = lv_wminvdoc
      CHANGING
        ct_content = lit_linv.
  ELSE.
    SELECT *
    FROM linv
    INTO TABLE lit_linv
    WHERE lgnum = x_profile-zzlgnum
    AND ivnum = lv_wminvdoc.
  ENDIF.


  IF lit_linv IS NOT INITIAL.
    SORT lit_linv BY matnr lgpla ivnum.
*    READ TABLE lit_linv ASSIGNING <fs_linv> WITH KEY charg = cv_linv-charg
    READ TABLE lit_linv ASSIGNING <fs_linv> WITH KEY matnr = cv_linv-matnr
*
                                                     lgpla = cv_linv-lgpla
                                                     ivnum = cv_linv-ivnum
                                                     BINARY SEARCH.
    IF sy-subrc EQ 0.
*-----overwrite or aggregate quantity for duplicate records
      IF uv_aggregate = abap_true."aggregate
        <fs_linv>-menga = cv_linv-menga + <fs_linv>-menga.
      ELSE."overwiate
        <fs_linv>-menga = cv_linv-menga.
      ENDIF.
    ELSE.
*-----if no duplicates found, append directly
      APPEND cv_linv TO lit_linv.
    ENDIF.
  ELSE.
*---if database is empty, append directly
    APPEND cv_linv TO lit_linv.
  ENDIF.

  CALL METHOD zcl_its_utility=>physinv_content_operation
    EXPORTING
      iv_mode    = 'S'
      iv_id      = lv_wminvdoc
    CHANGING
      ct_content = lit_linv.

  IF sy-subrc = 0.
    CLEAR: cv_linv.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPDATE_TASK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LIT_LINV  text
*----------------------------------------------------------------------*
FORM update_task  USING  lit_linv TYPE tt_linv_vb .

  DATA:  BEGIN OF z_inv OCCURS 80.       " Zählergebnisse pro Quant
          INCLUDE STRUCTURE linv_vbz.
  DATA:  END OF z_inv.

  DATA : BEGIN OF inp OCCURS 50.
          INCLUDE STRUCTURE linp_vb.
  DATA:  END OF inp.

  DATA : BEGIN OF inv OCCURS 80.
          INCLUDE STRUCTURE linv_vb.
  DATA:  END OF inv.

  TABLES: link.

  CALL FUNCTION 'L_ZAEHLUNG_BUCHEN' IN UPDATE TASK
    EXPORTING
      xlink = link
    TABLES
      inp   = inp
      inv   = inv
      z_inv = z_inv.
  COMMIT WORK.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LIT_LINV  text
*      <--P_GT_ZLWMINVDOC  text
*----------------------------------------------------------------------*
FORM add_data  USING    lit_linv TYPE linv_vb
               CHANGING it_zlwminvdoc TYPE tt_zlwminvdoc.

  APPEND INITIAL LINE TO it_zlwminvdoc ASSIGNING FIELD-SYMBOL(<ls_zlwminvdoc>).

  <ls_zlwminvdoc>-mandt = sy-mandt.
  <ls_zlwminvdoc>-lgtyp = lit_linv-lgtyp.
  <ls_zlwminvdoc>-idatu = sy-datum.
  <ls_zlwminvdoc>-uname = sy-uname.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_USER_COMMAND_9400
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_user_command_9400 .
  v_code = ok_code.
  CLEAR ok_code.

  CASE v_code.
    WHEN 'ZBACK'. " Back
      CLEAR zsits_scan_dynp-zzbchmtr.
      CLEAR zsits_scan_dynp-zzsbin.
      CLEAR zsits_scan_dynp-zzsuccess_msg.
      LEAVE TO SCREEN 0.
    WHEN 'ZEBIN'. " Empty Bin
      PERFORM frm_bin_empty.
      CLEAR: zsits_scan_dynp-zzbchmtr,
             zsits_scan_dynp-zzquantity,
             zsits_scan_dynp-zzsbin,
             zsits_scan_dynp-zzsuom,
             zsits_scan_dynp-zzsuccess_msg.
      LEAVE TO SCREEN 0.                                    " c_9100.
    WHEN 'ZCBIN'. " Bin Complete
      PERFORM frm_bin_comp.

      CLEAR: zsits_scan_dynp-zzbchmtr,
             zsits_scan_dynp-zzquantity,
             zsits_scan_dynp-zzsuom,
             zsits_scan_dynp-zzsuccess_msg.

      LEAVE TO SCREEN 0.

    WHEN 'ZDOC'.  " Doc. Completed
      PERFORM frm_doc_comp.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_DOC_COMP_9200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_doc_comp_9200 .
  DATA: lv_confirm TYPE char01,                             "#EC NEEDED
        lv_dummy   TYPE bapi_msg.                           "#EC NEEDED


  MESSAGE e113(zits) WITH zsits_scan_dynp-zzwminvdoc INTO lv_dummy.

  CALL METHOD zcl_its_utility=>message_confirm
    IMPORTING
      ev_result = lv_confirm.

  IF lv_confirm = lc_y.
    PERFORM frm_commit_count_9200.
  ELSEIF lv_confirm = lc_n.
    CLEAR:
      zsits_scan_dynp-zzbarcode,
      zsits_scan_dynp-zzquantity,
      zsits_scan_dynp-zzsuom.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_COMMIT_COUNT_9200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_commit_count_9200 .
  DATA: lv_bool     TYPE boolean,
        lv_dummy    TYPE bapi_msg,                          "#EC NEEDED
        lv_wminvdoc TYPE string,
        lit_linv    TYPE STANDARD TABLE OF linv_vb,
        lit_linv_ag TYPE STANDARD TABLE OF linv_vb,
        lwa_linv    TYPE linv_vb.

  DATA: lv_wminvdoc_str TYPE string.

  DATA: lv_uncomplete_bin TYPE lgpla.

  lv_wminvdoc = zsits_scan_dynp-zzwminvdoc.

  CALL METHOD zcl_its_utility=>physinv_content_operation
    EXPORTING
      iv_mode    = 'G'
      iv_id      = lv_wminvdoc
    CHANGING
      ct_content = lit_linv.

* Begin of add by Vicky on 20150325
*----------------------------------------------------------------------
* Check whether all storage bin was completed
  IF it_completed_bin IS NOT INITIAL.
    SORT it_completed_bin BY lgpla.
    CLEAR lv_uncomplete_bin.

    LOOP AT it_linv INTO lwa_linv WHERE istat NE 'S'  "cancelled
                                    AND istat NE 'Z'  "counted
                                    AND istat NE 'L'. "cleared
      READ TABLE it_completed_bin TRANSPORTING NO FIELDS WITH KEY lgpla = lwa_linv-lgpla BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_uncomplete_bin = lwa_linv-lgpla.
        EXIT.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT it_linv INTO lwa_linv WHERE istat NE 'S'  "cancelled
                                    AND istat NE 'Z'  "counted
                                    AND istat NE 'L'. "cleared
      lv_uncomplete_bin = lwa_linv-lgpla.
      EXIT.
    ENDLOOP.
  ENDIF.

  IF lv_uncomplete_bin IS NOT INITIAL.
*   Bin &1 was not completed yet.
    MESSAGE e428(zits) WITH lv_uncomplete_bin INTO lv_dummy.
    PERFORM frm_message_add USING zcl_its_utility=>gc_objid_invdoc
                                  lv_bool
                                  abap_true.
    RETURN.
  ENDIF.

* Mark the inv doc. item which was not scanned as zero count
  SORT lit_linv BY lgnum ivnum ivpos lqnum nanum.
  LOOP AT it_linv INTO lwa_linv WHERE istat NE 'S'  "cancelled
                                  AND istat NE 'Z'  "counted
                                  AND istat NE 'L'. "cleared
    READ TABLE lit_linv TRANSPORTING NO FIELDS WITH KEY lgnum = lwa_linv-lgnum
                                                        ivnum = lwa_linv-ivnum
                                                        ivpos = lwa_linv-ivpos
                                                        lqnum = lwa_linv-lqnum
                                                        nanum = lwa_linv-nanum
                                                        BINARY SEARCH.
    IF sy-subrc NE 0.
      lwa_linv-menga = 0."zero count
      APPEND lwa_linv TO lit_linv_ag.
    ENDIF.
  ENDLOOP.

  LOOP AT lit_linv INTO lwa_linv.
    APPEND lwa_linv TO lit_linv_ag.
  ENDLOOP.

  LOOP AT lit_linv INTO lwa_linv.
    APPEND INITIAL LINE TO gt_zlwminvdoc ASSIGNING FIELD-SYMBOL(<ls_zlwminvdoc>).

    <ls_zlwminvdoc>-mandt = sy-mandt.
    <ls_zlwminvdoc>-lgnum = lwa_linv-lgnum.
    <ls_zlwminvdoc>-ivnum = zsits_scan_dynp-zzwminvdoc.
    <ls_zlwminvdoc>-zsbin = zsits_scan_dynp-zzsbin.
    <ls_zlwminvdoc>-lgtyp = lwa_linv-lgtyp.
    <ls_zlwminvdoc>-lenum = lwa_linv-lenum.
    <ls_zlwminvdoc>-idatu = sy-datum.
    <ls_zlwminvdoc>-uname = sy-uname.
    <ls_zlwminvdoc>-zabin = lwa_linv-lgpla.
  ENDLOOP.
  SORT gt_zlwminvdoc BY lgnum ivnum zsbin lgtyp lenum idatu.


* Update the custom table
  PERFORM update_zlwminvdoc_final USING gt_zlwminvdoc.

*-----Count physical inv doc. LI11.
  IF zcl_its_utility=>physinv_wm_count( it_linv = lit_linv_ag ) EQ abap_false.

    CALL METHOD zcl_its_utility=>physinv_content_operation
      EXPORTING
        iv_mode    = 'S'
        iv_id      = lv_wminvdoc
      CHANGING
        ct_content = lit_linv_ag.

    PERFORM frm_message_add USING zcl_its_utility=>gc_objid_invdoc
                                  lv_bool
                                  abap_true.
    CLEAR zsits_scan_dynp.
    v_back_flag = abap_true.
    LEAVE TO SCREEN 0.                                      " c_9000.
  ELSE.
    CALL METHOD zcl_its_utility=>physinv_content_operation
      EXPORTING
        iv_mode = 'D'
        iv_id   = lv_wminvdoc.

    lv_wminvdoc_str = zsits_scan_dynp-zzwminvdoc.
    SHIFT lv_wminvdoc_str LEFT DELETING LEADING '0'.

*   &1 counted.
    MESSAGE s426(zits) WITH lv_wminvdoc_str INTO zsits_scan_dynp-zzsuccess_msg.

    v_back_flag = abap_true.
    LEAVE TO SCREEN 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_BIN_COMP_9200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_bin_comp_9200.
  DATA: lwa_completed_bin TYPE ty_bin,
        lwa_linv          LIKE LINE OF it_linv.

  DATA: lit_linv    TYPE STANDARD TABLE OF linv_vb,
        lv_wminvdoc TYPE string.

* Step 1: Add Bin to internal table
*----------------------------------------------------------------------
  CLEAR lwa_completed_bin.
  lwa_completed_bin-lgpla = zsits_scan_dynp-zzsbin.
  APPEND lwa_completed_bin TO it_completed_bin.

* Step 2: Mark other items of the same bin as zero count
*----------------------------------------------------------------------
  lv_wminvdoc = zsits_scan_dynp-zzwminvdoc.

  CALL METHOD zcl_its_utility=>physinv_content_operation
    EXPORTING
      iv_mode    = 'G'
      iv_id      = lv_wminvdoc
    CHANGING
      ct_content = lit_linv.


  SORT lit_linv BY lgnum ivnum ivpos lqnum nanum.

  LOOP AT it_linv INTO lwa_linv WHERE lgpla EQ zsits_scan_dynp-zzsbin
                                  AND istat NE 'S'  "cancelled
                                  AND istat NE 'Z'  "counted
                                  AND istat NE 'L'. "cleared

    READ TABLE lit_linv TRANSPORTING NO FIELDS WITH KEY lgnum = lwa_linv-lgnum
                                                        ivnum = lwa_linv-ivnum
                                                        ivpos = lwa_linv-ivpos
                                                        lqnum = lwa_linv-lqnum
                                                        nanum = lwa_linv-nanum
                                                        BINARY SEARCH.

    IF sy-subrc NE 0.

      lwa_linv-menga = 0. "set counted quantity to 0
      PERFORM frm_pass_data_9200_2 USING    abap_false " overwrite
                            CHANGING lwa_linv.

    ELSE.
      lwa_linv-menga = zsits_scan_dynp-zzquantity.
      PERFORM frm_pass_data_9200_2 USING  abap_false
                            CHANGING lwa_linv.
      MESSAGE s357(zits) INTO zsits_scan_dynp-zzsuccess_msg.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_PASS_DATA_9200_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ABAP_FALSE  text
*      <--P_LWA_LINV  text
*----------------------------------------------------------------------*
FORM frm_pass_data_9200_2  USING    uv_aggregate TYPE boolean
                         CHANGING cv_linv      TYPE linv_vb.

*-----update selected data to database
  DATA: lit_linv    TYPE STANDARD TABLE OF linv_vb,
        lv_wminvdoc TYPE string.
  TYPES:tt_linv_vb    TYPE STANDARD TABLE OF linv_vb.
  FIELD-SYMBOLS: <fs_linv> LIKE LINE OF lit_linv.

  lv_wminvdoc = zsits_scan_dynp-zzwminvdoc.

  CALL METHOD zcl_its_utility=>physinv_content_operation
    EXPORTING
      iv_mode    = 'G'
      iv_id      = lv_wminvdoc
    CHANGING
      ct_content = lit_linv.



  IF lit_linv IS NOT INITIAL.
*    SORT lit_linv BY charg matnr lenum lgpla ivnum.
    SORT lit_linv BY matnr lgpla ivnum.

    READ TABLE lit_linv ASSIGNING <fs_linv> WITH KEY matnr = cv_linv-matnr
*
                                                     lgpla = cv_linv-lgpla
                                                     ivnum = cv_linv-ivnum
                                                     BINARY SEARCH.
    IF sy-subrc EQ 0.
*-----overwrite or aggregate quantity for duplicate records
      IF uv_aggregate = abap_true."aggregate
        <fs_linv>-menga = cv_linv-menga + <fs_linv>-menga.
      ELSE."overwiate
        <fs_linv>-menga = cv_linv-menga.
      ENDIF.
    ELSE.
*-----if no duplicates found, append directly
      APPEND cv_linv TO lit_linv.
    ENDIF.
  ELSE.
*---if database is empty, append directly
    APPEND cv_linv TO lit_linv.
  ENDIF.

  CALL METHOD zcl_its_utility=>physinv_content_operation
    EXPORTING
      iv_mode    = 'S'
      iv_id      = lv_wminvdoc
    CHANGING
      ct_content = lit_linv.

  IF sy-subrc = 0.
    CLEAR: cv_linv.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  NEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM next .
  CLEAR: zsits_scan_dynp-zzsuccess_msg,
         v_su_m_bool,
         v_error_ind,
         v_back_flag,
         it_completed_bin,
         it_counted_rm_batch.

  CHECK zsits_scan_dynp-zzwminvdoc IS NOT INITIAL.

  PERFORM frm_inv_doc_check CHANGING v_error_ind.

  PERFORM frm_message_add  USING zcl_its_utility=>gc_objid_invdoc
                                 zsits_scan_dynp-zzwminvdoc
                                 v_error_ind.

  IF v_error_ind = abap_true.
    CLEAR zsits_scan_dynp.
  ELSE.
    CALL SCREEN 9100.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_UOM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_uom .
  IF zsits_scan_dynp-zzwminvdoc IS NOT INITIAL.
    SELECT SINGLE meins
            INTO lv_meins
            FROM linv
            WHERE ivnum = zsits_scan_dynp-zzwminvdoc.
    IF sy-subrc = 0.
      zsits_scan_dynp-zzsuom = lv_meins.
    ENDIF.
  ENDIF.

ENDFORM.
