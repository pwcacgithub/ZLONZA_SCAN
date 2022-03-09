*&---------------------------------------------------------------------*
*&  Include           ZINV_MOV_NON_HUF01
*&---------------------------------------------------------------------*
************************************************************************
* Program ID:                   ZINV_MOV_NON_HU
* Program Title:                Non HU Movements
* Created By:
* Creation Date:
* RICEFW ID:   S0096
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
*&      Form  FRM_CHECK_PLANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZSITS_USER_PROFILE_ZZWERKS  text
*----------------------------------------------------------------------*
FORM frm_check_plant  CHANGING cv_plant TYPE zd_werks.

  DATA: lv_with_message TYPE boolean.

* Check input plant does whether exist or not
  IF zcl_common_utility=>plant_validate( cv_plant ) = abap_false.
    lv_with_message = abap_true.
  ENDIF.

* log what user input
  CALL METHOD go_log->log_message_add
    EXPORTING
      iv_object_id    = zcl_its_utility=>gc_objid_plant    " = 011
      iv_content      = cv_plant
      iv_with_message = lv_with_message.

  IF lv_with_message = abap_true.
    gv_validation_fail = abap_true.
* Display error message
    CALL METHOD zcl_its_utility=>message_display( ).
    CLEAR:cv_plant.
  ENDIF.
ENDFORM.                    " FRM_CHECK_PLANT
*&---------------------------------------------------------------------*
*&      Form  FRM_INIT_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_init_log .
  IF go_log IS INITIAL.
    CREATE OBJECT go_log
      EXPORTING
        iv_scan_code = sy-tcode.
  ENDIF.
ENDFORM.                    " FRM_INIT_LOG
*&---------------------------------------------------------------------*
*&      Form  FRM_MESSAGE_ADD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZCL_ITS_UTILITY=>GC_OBJID_LABE  text
*      -->P_ZSITS_SCAN_DYNP_ZZBARCODE  text
*      -->P_V_WITH_MESSAGE  text
*----------------------------------------------------------------------*
FORM frm_message_add  USING    uv_objid   TYPE zzscan_objid
                               up_content TYPE any
                               uv_bool    TYPE boolean.
  IF go_log IS INITIAL.
    CREATE OBJECT go_log
      EXPORTING
        iv_scan_code = sy-tcode.
  ENDIF.
  CALL METHOD go_log->log_message_add
    EXPORTING
      iv_object_id    = uv_objid
      iv_content      = up_content
      iv_with_message = uv_bool.
  IF uv_bool = abap_true.
*** Display the message
    CALL METHOD zcl_its_utility=>message_display( ).
  ENDIF.

ENDFORM.                    " FRM_MESSAGE_ADD
*&---------------------------------------------------------------------*
*&      Form  FRM_CLEAR_PALLET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_V_WITH_MESSAGE  text
*----------------------------------------------------------------------*
FORM frm_clear_pallet  CHANGING cv_fg TYPE boolean.
  DATA: lwa_batch_data TYPE zsotc_batch,

        lwa_valueschar TYPE bapi1003_alloc_values_char,
        lit_valueschar TYPE tt_bapi1003_alloc_values_char,
        lv_result      TYPE xfeld,
        lv_dummy       TYPE string.

  CLEAR lwa_valueschar.
  lwa_valueschar-charact    = zcl_common_utility=>gc_chara_palletid."PALLET_ID
  lwa_valueschar-value_char = space.
  APPEND lwa_valueschar TO lit_valueschar.

  IF zcl_common_utility=>batch_char_add( is_batch       = lwa_batch_data
                                         it_valueschar  = lit_valueschar
                                         iv_save_option = zcl_common_utility=>gc_commit_work_wait ) IS INITIAL.
    cv_fg = abap_true.
    MESSAGE ID        sy-msgid
            TYPE      sy-msgty
            NUMBER    sy-msgno
            INTO      lv_dummy
            WITH      sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.
ENDFORM.                    " FRM_CLEAR_PALLET
*&---------------------------------------------------------------------*
*&      Form  TO_CREATE_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM to_create_confirm .

  DATA: lv_vltyp  TYPE lgtyp,
        lv_vlber  TYPE lgber,
        lv_nltyp  TYPE lgtyp,
        lv_nlber  TYPE lgber,
        lv_vlpla  TYPE lgpla,
        lv_nlpla  TYPE lgpla,
        lv_lgnum  TYPE lgnum,
        lv_lgort  TYPE lgort_d,
        lv_werks  TYPE werks_d,
        lv_charg  TYPE charg_d,
        lv_matnr  TYPE matnr,
        lv_errmsg TYPE char100.

  CLEAR: gv_suc1, gv_suc2.

  CLEAR: gv_dummy, lv_vltyp, lv_vlber, lv_vlpla, lv_nltyp, lv_nlber, lv_nlpla,
         lv_lgnum, lv_lgort, lv_werks, lv_charg, lv_matnr, lv_errmsg.

*-- If the Source bin & Destination bin flags are "X" then it is
*  Bin to Bin transfer
  IF gv_button = 'B2B'.
    CLEAR: gv_dummy.
*-- If the source bin & destination bin are same then through an error message
    IF gv_stobin = zsits_scan_dynp-zzdestbin.
      gv_with_message = abap_true.
      MESSAGE e400(zits) INTO gv_dummy.
    ENDIF.

    IF gv_validation_fail IS INITIAL.

*-- Fetch source Bin type, storage section
      SELECT SINGLE lgpla lgtyp lgber
               FROM lagp
               INTO (lv_vlpla, lv_vltyp, lv_vlber)
               WHERE lgnum = zsits_user_profile-zzlgnum
                 AND lgpla = zsits_scan_dynp-zzsourcebin.
      IF sy-subrc = 0.
      ENDIF.
*-- Fetch Destination Bin type, storage section
      SELECT SINGLE lgpla lgtyp lgber
               FROM lagp
               INTO (lv_nlpla, lv_nltyp, lv_nlber)
               WHERE lgnum = zsits_user_profile-zzlgnum
                 AND lgpla = zsits_scan_dynp-zzdestbin.
      IF sy-subrc = 0.
      ENDIF.

      lv_lgort = zsits_scan_dynp-zzsourcesloc.
      lv_lgnum = zsits_scan_dynp-zzwarehouse.
      lv_werks = zsits_user_profile-zzwerks.
      lv_charg = zsits_scan_dynp-zzbatch.
      lv_matnr = zsits_scan_dynp-zzmaterial.

***** Validation as part of E0099 to check the TO  creation is allowed or not *****

*******************************************************************************

*-- FM to create the TO& confirm
*        CALL FUNCTION 'L_TO_CREATE_SINGLE'
      CALL FUNCTION 'ZL_TO_CREATE_SINGLE'
        EXPORTING
          i_lgnum               = lv_lgnum    "zsits_scan_dynp-zzwarehouse
          i_bwlvs               = '999'
          i_matnr               = lv_matnr    "gs_batch_data-matnr
          i_werks               = lv_werks    "zsits_user_profile-zzwerks
          i_lgort               = lv_lgort
          i_charg               = lv_charg    "zsits_scan_dynp-zzbatch"gs_batch_data-charg
          i_bestq               = zsits_scan_dynp-zzstocat
          i_anfme               = zsits_scan_dynp-zzqty
          i_altme               = gs_batch_data-meins
          i_squit               = gc_x
          i_vltyp               = lv_vltyp
          i_vlber               = lv_vlber
          i_vlpla               = lv_vlpla
          i_nltyp               = lv_nltyp
          i_nlber               = lv_nlber
          i_nlpla               = lv_nlpla
        IMPORTING
          e_tanum               = gv_tonum
          e_ltap                = gs_ltap
          e_errmsg              = lv_errmsg
        EXCEPTIONS
          no_to_created         = 1
          bwlvs_wrong           = 2
          betyp_wrong           = 3
          benum_missing         = 4
          betyp_missing         = 5
          foreign_lock          = 6
          vltyp_wrong           = 7
          vlpla_wrong           = 8
          vltyp_missing         = 9
          nltyp_wrong           = 10
          nlpla_wrong           = 11
          nltyp_missing         = 12
          rltyp_wrong           = 13
          rlpla_wrong           = 14
          rltyp_missing         = 15
          squit_forbidden       = 16
          manual_to_forbidden   = 17
          letyp_wrong           = 18
          vlpla_missing         = 19
          nlpla_missing         = 20
          sobkz_wrong           = 21
          sobkz_missing         = 22
          sonum_missing         = 23
          bestq_wrong           = 24
          lgber_wrong           = 25
          xfeld_wrong           = 26
          date_wrong            = 27
          drukz_wrong           = 28
          ldest_wrong           = 29
          update_without_commit = 30
          no_authority          = 31
          material_not_found    = 32
          lenum_wrong           = 33
          OTHERS                = 34.
      IF sy-subrc <> 0.

        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        INTO gv_dummy
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        gv_with_message = abap_true.

        PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                      zsits_scan_dynp-zzbarcode
                                      gv_with_message.
      ELSE.
*-- Storage type error valdation check
        IF lv_errmsg IS NOT INITIAL.
          DATA(lv_msgv1) = lv_errmsg+0(50).
          DATA(lv_msgv2) = lv_errmsg+50(50).

          MESSAGE ID 'ZITS' TYPE gc_e NUMBER '510'
          INTO gv_dummy
          WITH lv_msgv1 lv_msgv2.

          gv_with_message = abap_true.
          PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                        zsits_scan_dynp-zzbarcode
                                        gv_with_message.
        ELSE.
*-- Success Message
          CONCATENATE  'Transfer order'(001) gv_tonum INTO gv_suc1 SEPARATED BY space.
          gv_suc2 = 'has been confirmed'(002).
*-- Diaply the success messages in the new screen
          SET SCREEN '5000'.
        ENDIF.
      ENDIF.  "Storage type error check
    ENDIF.
  ENDIF.
ENDFORM.                    " TO_CREATE_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  PROCESS
*&---------------------------------------------------------------------*
*       Do the process based on the Button
*----------------------------------------------------------------------*
FORM process .
*-- If the button B2B is selected do the TO creation
  IF gv_button = 'B2B'.
*--   Bin to Bin transfer
    PERFORM to_create_confirm.
  ELSEIF gv_button = 'B2L'.
*-- If the button B2L is selected then do Bin(WM) to loc transfer(IM)

***** Authorization check for Movement type *****
    PERFORM auth_check_mvt_type.

    PERFORM bin_to_loc_transfer.
  ELSEIF gv_button = 'L2B'.
*-- If the button L2B is selected then do Loc(IM) to Bin transfer(WM)

***** Authorization check for Movement type *****
    PERFORM auth_check_mvt_type.

    PERFORM loc_to_bin_transfer.
  ENDIF.

ENDFORM.                    " PROCESS
*&---------------------------------------------------------------------*
*&      Form  BIN_TO_LOC_TRANSFER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bin_to_loc_transfer .
  CLEAR: gv_mblnr.
  PERFORM migo_creation CHANGING gv_mblnr.
  IF gv_mblnr IS NOT INITIAL.
    PERFORM to_create_confirm_b2l.
  ENDIF.

ENDFORM.                    " BIN_TO_LOC_TRANSFER
*&---------------------------------------------------------------------*
*&      Form  LOC_TO_BIN_TRANSFER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM loc_to_bin_transfer .

  CLEAR: gv_mblnr.
  PERFORM migo_creation CHANGING gv_mblnr.
  IF gv_mblnr IS NOT INITIAL.
    PERFORM to_create_confirm_l2b.
  ENDIF.

ENDFORM.                    " LOC_TO_BIN_TRANSFER
*&---------------------------------------------------------------------*
*&      Form  MIGO_CREATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_MBLNR  text
*----------------------------------------------------------------------*
FORM migo_creation  CHANGING p_gv_mblnr.

  DATA: ls_header   TYPE bapi2017_gm_head_01,       "Header details
        ls_mvt_code TYPE bapi2017_gm_code,          "Mvt code
        lt_item     TYPE TABLE OF bapi2017_gm_item_create, "Item for MIGO
        ls_item     TYPE bapi2017_gm_item_create,   "Item for MIGO
        lt_return   TYPE TABLE OF bapiret2,         "Return table
        lv_mblnr    TYPE mblnr.

  CLEAR: ls_header, ls_mvt_code, lt_item, ls_item, lt_return.

*-- Fill the BAP structures
  ls_header-pstng_date = sy-datum.
  ls_header-doc_date   = sy-datum.

  ls_mvt_code-gm_code = '04'.
*-- Item details
  ls_item-material   = gs_batch_data-matnr.
  ls_item-plant      = zsits_scan_dynp-zzplant.
  ls_item-stge_loc   = zsits_scan_dynp-zzsourcesloc.
  ls_item-batch      = zsits_scan_dynp-zzbatch. "gs_batch_data-charg.
  ls_item-move_type  = gv_mvt_type. "'311'.
  ls_item-entry_qnt  = zsits_scan_dynp-zzqty.
  ls_item-entry_uom  = gs_batch_data-meins.
  ls_item-move_mat   = gs_batch_data-matnr.
  ls_item-move_plant = zsits_scan_dynp-zzplant.
  ls_item-move_stloc = zsits_scan_dynp-zzdestloc.
  ls_item-move_batch = gs_batch_data-charg.

  APPEND ls_item TO lt_item.
  CLEAR: ls_item.

*-- BAPI to create the Material document number
*-- Sto loc to sto loc transfer (IM)
  CLEAR: lt_return.
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_header
      goodsmvt_code    = ls_mvt_code
    IMPORTING
      materialdocument = lv_mblnr
    TABLES
      goodsmvt_item    = lt_item
      return           = lt_return.

*-- Check for the errors
  READ TABLE lt_return INTO DATA(ls_ret) WITH KEY type = gc_e.
  IF sy-subrc = 0.
*-- Raise an error message
    MESSAGE ID ls_ret-id TYPE ls_ret-type NUMBER ls_ret-number
    WITH ls_ret-message_v1 ls_ret-message_v2 ls_ret-message_v3
         ls_ret-message_v4 INTO gv_dummy.

    gv_with_message = abap_true.
    PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                  gs_batch_data-matnr
                                  gv_with_message.
  ELSE.
*-- Commit the work
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = gc_x.
    p_gv_mblnr = lv_mblnr.
  ENDIF.

ENDFORM.                    " MIGO_CREATION
*&---------------------------------------------------------------------*
*&      Form  TO_CREATE_CONFIRM_B2L
*&---------------------------------------------------------------------*
*       TO creation for Binto Location transfer
*----------------------------------------------------------------------*
FORM to_create_confirm_b2l .
  DATA: lv_vltyp  TYPE lgtyp,
        lv_vlber  TYPE lgber,
        lv_nltyp  TYPE lgtyp,
        lv_nlber  TYPE lgber,
        lv_vlpla  TYPE lgpla,
        lv_nlpla  TYPE lgpla,
        lv_lgnum  TYPE lgnum,
        lv_lgort  TYPE lgort_d,
        lt_tvarvc TYPE TABLE OF tvarvc,
        lr_name   TYPE RANGE OF rvari_vnam,
        ls_name   LIKE LINE OF lr_name,
        lv_werks  TYPE werks_d,
        lv_charg  TYPE charg_d,
        lv_matnr  TYPE matnr,
        lv_errmsg TYPE char100.


  CLEAR: gv_dummy, lv_vltyp, lv_vlber, lv_vlpla, lv_nltyp, lv_nlber, lv_nlpla,
         lv_lgnum, lv_lgort, lr_name, lt_tvarvc, ls_name, lv_werks, lv_charg,
         gv_suc1, gv_suc2, lv_matnr.
*-- If the source bin & destination bin are same then through an error message
  IF gv_stobin = zsits_scan_dynp-zzdestbin.
    gv_with_message = abap_true.
    MESSAGE e400(zits) INTO gv_dummy.
  ENDIF.

  IF gv_with_message IS INITIAL.

    ls_name-sign   = 'I'.
    ls_name-option = 'EQ'.
    ls_name-low    = 'ZNONHU_IM_INTERIM_STO_BIN'.
    APPEND ls_name TO lr_name.

    ls_name-low    = 'ZNONHU_IM_INTERIM_STO_SECTION'.
    APPEND ls_name TO lr_name.

    ls_name-low    = 'ZNONHU_IM_INTERIM_STO_TYPE'.
    APPEND ls_name TO lr_name.
    CLEAR: ls_name.

*-- Fetch source Bin type, storage section
    SELECT SINGLE lgpla lgtyp lgber
             FROM lagp
             INTO (lv_vlpla, lv_vltyp, lv_vlber)
             WHERE lgnum = zsits_user_profile-zzlgnum
               AND lgpla = zsits_scan_dynp-zzsourcebin.
    IF sy-subrc = 0.
    ENDIF.

*-- Fetch the source bin details from TVARVC table to nullify the interim bin qty
    SELECT * FROM tvarvc
             INTO TABLE lt_tvarvc
             WHERE name IN lr_name.
    IF sy-subrc = 0.
      SORT lt_tvarvc BY name.
*-- Storage Bin
      READ TABLE lt_tvarvc INTO DATA(ls_tvarvc) WITH KEY name = 'ZNONHU_IM_INTERIM_STO_BIN'.
      IF sy-subrc = 0.
        lv_nlpla = ls_tvarvc-low.
      ENDIF.
*-- Storage type
      READ TABLE lt_tvarvc INTO ls_tvarvc WITH KEY name = 'ZNONHU_IM_INTERIM_STO_TYPE'.
      IF sy-subrc = 0.
        lv_nltyp = ls_tvarvc-low.
      ENDIF.
*-- Storage section
      READ TABLE lt_tvarvc INTO ls_tvarvc WITH KEY name = 'ZNONHU_IM_INTERIM_STO_SECTION'.
      IF sy-subrc = 0.
        lv_nlber = ls_tvarvc-low.
      ENDIF.
    ENDIF.

    lv_lgort = zsits_scan_dynp-zzsourcesloc.
    lv_lgnum = zsits_scan_dynp-zzwarehouse.
    lv_werks = zsits_user_profile-zzwerks.
    lv_charg = zsits_scan_dynp-zzbatch.
    lv_matnr = zsits_scan_dynp-zzmaterial.

*-- FM to create the TO& confirm
*    CALL FUNCTION 'L_TO_CREATE_SINGLE'
    CALL FUNCTION 'ZL_TO_CREATE_SINGLE'
      EXPORTING
        i_lgnum               = lv_lgnum    "zsits_scan_dynp-zzwarehouse
        i_bwlvs               = '999'
        i_matnr               = lv_matnr  "gs_batch_data-matnr
        i_werks               = lv_werks   "zsits_user_profile-zzwerks
        i_lgort               = lv_lgort
        i_charg               = lv_charg  "zsits_scan_dynp-zzbatch"gs_batch_data-charg
        i_bestq               = zsits_scan_dynp-zzstocat
        i_anfme               = zsits_scan_dynp-zzqty
        i_altme               = gs_batch_data-meins
        i_squit               = gc_x
        i_vltyp               = lv_vltyp
        i_vlber               = lv_vlber
        i_vlpla               = lv_vlpla
        i_nltyp               = lv_nltyp
        i_nlber               = lv_nlber
        i_nlpla               = lv_nlpla
      IMPORTING
        e_tanum               = gv_tonum
        e_ltap                = gs_ltap
        e_errmsg              = lv_errmsg
      EXCEPTIONS
        no_to_created         = 1
        bwlvs_wrong           = 2
        betyp_wrong           = 3
        benum_missing         = 4
        betyp_missing         = 5
        foreign_lock          = 6
        vltyp_wrong           = 7
        vlpla_wrong           = 8
        vltyp_missing         = 9
        nltyp_wrong           = 10
        nlpla_wrong           = 11
        nltyp_missing         = 12
        rltyp_wrong           = 13
        rlpla_wrong           = 14
        rltyp_missing         = 15
        squit_forbidden       = 16
        manual_to_forbidden   = 17
        letyp_wrong           = 18
        vlpla_missing         = 19
        nlpla_missing         = 20
        sobkz_wrong           = 21
        sobkz_missing         = 22
        sonum_missing         = 23
        bestq_wrong           = 24
        lgber_wrong           = 25
        xfeld_wrong           = 26
        date_wrong            = 27
        drukz_wrong           = 28
        ldest_wrong           = 29
        update_without_commit = 30
        no_authority          = 31
        material_not_found    = 32
        lenum_wrong           = 33
        OTHERS                = 34.
    IF sy-subrc <> 0.

      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      INTO gv_dummy
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      gv_with_message = abap_true.
*-- Error Message
      PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                    zsits_scan_dynp-zzbarcode
                                    gv_with_message.
    ELSE.
      IF lv_errmsg IS NOT INITIAL.   " Error message for storage type validation
        DATA(lv_msgv1) = lv_errmsg+0(50).
        DATA(lv_msgv2) = lv_errmsg+50(50).

        MESSAGE ID 'ZITS' TYPE gc_e NUMBER '510'
        INTO gv_dummy
        WITH lv_msgv1 lv_msgv2.

        gv_with_message = abap_true.
        PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                      zsits_scan_dynp-zzbarcode
                                      gv_with_message.
      ELSE.
*-- Success Message
        CONCATENATE  text-001 "'Transfer order'
        gv_tonum INTO gv_suc1 SEPARATED BY space.
        gv_suc2 = text-002.   "'has been confirmed'.
*-- Display the success messages in the new screen
        SET SCREEN '5000'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " TO_CREATE_CONFIRM_B2L
*&---------------------------------------------------------------------*
*&      Form  TO_CREATE_CONFIRM_L2B
*&---------------------------------------------------------------------*
*       Location to Bin transfer
*----------------------------------------------------------------------*
FORM to_create_confirm_l2b .

  DATA: lv_vltyp  TYPE lgtyp,
        lv_vlber  TYPE lgber,
        lv_nltyp  TYPE lgtyp,
        lv_nlber  TYPE lgber,
        lv_vlpla  TYPE lgpla,
        lv_nlpla  TYPE lgpla,
        lv_lgnum  TYPE lgnum,
        lv_lgort  TYPE lgort_d,
        lt_tvarvc TYPE TABLE OF tvarvc,
        lr_name   TYPE RANGE OF rvari_vnam,
        ls_name   LIKE LINE OF lr_name,
        lv_werks  TYPE werks_d,
        lv_charg  TYPE charg_d,
        lv_matnr  TYPE matnr,
        lv_errmsg TYPE char100.


  CLEAR: gv_dummy, lv_vltyp, lv_vlber, lv_vlpla, lv_nltyp, lv_nlber, lv_nlpla,
         lv_lgnum, lv_lgort, lr_name, lt_tvarvc, ls_name, lv_matnr, gv_suc1, gv_suc2.
*-- If the source bin & destination bin are same then through an error message
  IF gv_stobin = zsits_scan_dynp-zzdestbin.
    gv_with_message = abap_true.
    MESSAGE e400(zits) INTO gv_dummy.
  ENDIF.

  IF gv_with_message IS INITIAL.

    ls_name-sign   = 'I'.
    ls_name-option = 'EQ'.
    ls_name-low    = 'ZNONHU_IM_INTERIM_STO_BIN'.
    APPEND ls_name TO lr_name.

    ls_name-low    = 'ZNONHU_IM_INTERIM_STO_SECTION'.
    APPEND ls_name TO lr_name.

    ls_name-low    = 'ZNONHU_IM_INTERIM_STO_TYPE'.
    APPEND ls_name TO lr_name.
    CLEAR: ls_name.

*-- Fetch the Source bin details from TVARVC table to send from the interim bin
    SELECT * FROM tvarvc
             INTO TABLE lt_tvarvc
             WHERE name IN lr_name.
    IF sy-subrc = 0.
      SORT lt_tvarvc BY name.
*-- Sto bin
      READ TABLE lt_tvarvc INTO DATA(ls_tvarvc) WITH KEY name = 'ZNONHU_IM_INTERIM_STO_BIN'.
      IF sy-subrc = 0.
        lv_vlpla = ls_tvarvc-low.
      ENDIF.
*-- Storage type
      READ TABLE lt_tvarvc INTO ls_tvarvc WITH KEY name = 'ZNONHU_IM_INTERIM_STO_TYPE'.
      IF sy-subrc = 0.
        lv_vltyp = ls_tvarvc-low.
      ENDIF.
*-- Storage section
      READ TABLE lt_tvarvc INTO ls_tvarvc WITH KEY name = 'ZNONHU_IM_INTERIM_STO_SECTION'.
      IF sy-subrc = 0.
        lv_vlber = ls_tvarvc-low.
      ENDIF.
    ENDIF.
*-- Fetch Destination Bin type, storage section
    SELECT SINGLE lgpla lgtyp lgber
             FROM lagp
             INTO (lv_nlpla, lv_nltyp, lv_nlber)
             WHERE lgnum = zsits_user_profile-zzlgnum
               AND lgpla = zsits_scan_dynp-zzdestbin.

    IF sy-subrc = 0.
    ENDIF.

    lv_lgort = zsits_scan_dynp-zzdestloc.
    lv_lgnum = zsits_scan_dynp-zzwarehouse.
    lv_werks = zsits_user_profile-zzwerks.
    lv_charg = zsits_scan_dynp-zzbatch.
    lv_matnr = zsits_scan_dynp-zzmaterial.

*-- FM to create the TO& confirm
*        CALL FUNCTION 'L_TO_CREATE_SINGLE'
    CALL FUNCTION 'ZL_TO_CREATE_SINGLE'
      EXPORTING
        i_lgnum               = lv_lgnum    "zsits_scan_dynp-zzwarehouse
        i_bwlvs               = '999'       "Movement type
        i_matnr               = lv_matnr    "gs_batch_data-matnr
        i_werks               = lv_werks    "zsits_user_profile-zzwerks
        i_lgort               = lv_lgort
        i_charg               = lv_charg    "zsits_scan_dynp-zzbatch"gs_batch_data-charg
        i_bestq               = zsits_scan_dynp-zzstocat
        i_anfme               = zsits_scan_dynp-zzqty
        i_altme               = gs_batch_data-meins
        i_squit               = gc_x
        i_vltyp               = lv_vltyp
        i_vlber               = lv_vlber
        i_vlpla               = lv_vlpla
        i_nltyp               = lv_nltyp
        i_nlber               = lv_nlber
        i_nlpla               = lv_nlpla
      IMPORTING
        e_tanum               = gv_tonum
        e_ltap                = gs_ltap
        e_errmsg              = lv_errmsg
      EXCEPTIONS
        no_to_created         = 1
        bwlvs_wrong           = 2
        betyp_wrong           = 3
        benum_missing         = 4
        betyp_missing         = 5
        foreign_lock          = 6
        vltyp_wrong           = 7
        vlpla_wrong           = 8
        vltyp_missing         = 9
        nltyp_wrong           = 10
        nlpla_wrong           = 11
        nltyp_missing         = 12
        rltyp_wrong           = 13
        rlpla_wrong           = 14
        rltyp_missing         = 15
        squit_forbidden       = 16
        manual_to_forbidden   = 17
        letyp_wrong           = 18
        vlpla_missing         = 19
        nlpla_missing         = 20
        sobkz_wrong           = 21
        sobkz_missing         = 22
        sonum_missing         = 23
        bestq_wrong           = 24
        lgber_wrong           = 25
        xfeld_wrong           = 26
        date_wrong            = 27
        drukz_wrong           = 28
        ldest_wrong           = 29
        update_without_commit = 30
        no_authority          = 31
        material_not_found    = 32
        lenum_wrong           = 33
        OTHERS                = 34.
    IF sy-subrc <> 0.

      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      INTO gv_dummy
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      gv_with_message = abap_true.
*-- Error Message
      PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                    zsits_scan_dynp-zzbarcode
                                    gv_with_message.
    ELSE.
*-- Storage type validation error check
      IF lv_errmsg IS NOT INITIAL.
        DATA(lv_msgv1) = lv_errmsg+0(50).
        DATA(lv_msgv2) = lv_errmsg+50(50).

        MESSAGE ID 'ZITS' TYPE gc_e NUMBER '510'
        INTO gv_dummy
        WITH lv_msgv1 lv_msgv2.

        gv_with_message = abap_true.
        PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                      zsits_scan_dynp-zzbarcode
                                      gv_with_message.
      ELSE.
        CONCATENATE  text-001 "'Transfer order'
                     gv_tonum INTO gv_suc1 SEPARATED BY space.
        gv_suc2 = text-002.   "'has been confirmed'.
*-- Display the success messages in the new screen
        SET SCREEN '5000'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " TO_CREATE_CONFIRM_L2B
*&---------------------------------------------------------------------*
*&      Form  POPULATE_SCREEN_VALUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM populate_screen_values .

  DATA: lv_matnr TYPE matnr.

  CLEAR: gv_stoloc, gv_stobin, gv_batch, gv_material, gv_sto_cat,
         zsits_scan_dynp-zzstocat, lv_matnr, gv_qty.


*-- Storage Location from previous screen
  CONCATENATE 'Storage Loc - '(003)
               zsits_scan_dynp-zzsourcesloc
               INTO gv_stoloc
               SEPARATED BY space.

*-- Storage Bin from the previous screen
  CONCATENATE 'Storage Bin - '(004)
               zsits_scan_dynp-zzsourcebin
               INTO gv_stobin
               SEPARATED BY space.
*-- Batch
  CONCATENATE 'Batch #'(005)
              zsits_scan_dynp-zzbatch
              INTO gv_batch
              SEPARATED BY space.
*-- Material Number
*-- Convert Material to external format
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      input  = gs_batch_data-matnr
    IMPORTING
      output = lv_matnr.

  CONCATENATE 'Material # '(006)
               lv_matnr
              INTO gv_material
              SEPARATED BY space.

*-- Availability Quantity
************* "Bin to Bin" or "Location to Bin" ***************************
  IF gv_button = 'B2B' OR gv_button = 'B2L'.
    DATA(lt_mat_stock_wm) = gs_mat_data-wm_stock.
*-- Check for Unrestricted Stock
    READ TABLE lt_mat_stock_wm INTO DATA(ls_mat_stock_wm) WITH KEY
                      lgnum = zsits_user_profile-zzlgnum
                      werks = zsits_user_profile-zzwerks
                      lgort = zsits_scan_dynp-zzsourcesloc
                      lgpla = zsits_scan_dynp-zzsourcebin
                      bestq = ''.           "Unrestricted
    IF sy-subrc = 0.
      zsits_scan_dynp-zzstocat = ls_mat_stock_wm-bestq.
      gv_qty = ls_mat_stock_wm-verme.
    ENDIF.

*-- Check for Quality Stock
    READ TABLE lt_mat_stock_wm INTO ls_mat_stock_wm WITH KEY
                      lgnum = zsits_user_profile-zzlgnum
                      werks = zsits_user_profile-zzwerks
                      lgort = zsits_scan_dynp-zzsourcesloc
                      lgpla = zsits_scan_dynp-zzsourcebin
                      bestq = 'Q'.           "Quality
    IF sy-subrc = 0.
      zsits_scan_dynp-zzstocat = ls_mat_stock_wm-bestq.
      IF gv_qty IS INITIAL.
        gv_qty = ls_mat_stock_wm-verme.
      ELSE.
*-- Raise an error msg that the material has multiple stocks
        gv_validation_fail = gc_x.
        gv_with_message = gc_x.
        MESSAGE e507(zits) INTO gv_dummy.
        PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                      gv_qty
                                      gv_with_message.
      ENDIF.
    ENDIF.

*-- Check for Blocked Stock
    READ TABLE lt_mat_stock_wm INTO ls_mat_stock_wm WITH KEY
                      lgnum = zsits_user_profile-zzlgnum
                      werks = zsits_user_profile-zzwerks
                      lgort = zsits_scan_dynp-zzsourcesloc
                      lgpla = zsits_scan_dynp-zzsourcebin
                      bestq = 'S'.           "Quality
    IF sy-subrc = 0.
      zsits_scan_dynp-zzstocat = ls_mat_stock_wm-bestq.
      IF gv_qty IS INITIAL.
        gv_qty = ls_mat_stock_wm-verme.
      ELSE.
*-- Raise an error msg that the material has multiple stocks
        gv_validation_fail = gc_x.
        gv_with_message = gc_x.
        MESSAGE e507(zits) INTO gv_dummy.
        PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                      gv_qty
                                      gv_with_message.
      ENDIF.
    ENDIF.

*-- Stock category
    CONCATENATE 'Sto. category'(007)
                zsits_scan_dynp-zzstocat
                INTO gv_sto_cat
                SEPARATED BY '-'.

*********************** Location to Bin ***************************

  ELSEIF gv_button = 'L2B'. " OR gv_button = 'L2LIM'.

    DATA(lt_mat_stock) = gs_mat_data-im_stock.
    READ TABLE lt_mat_stock INTO DATA(ls_mat_stock)
                          WITH KEY lgort = zsits_scan_dynp-zzsourcesloc.
    IF sy-subrc = 0.
*-- Check if the material has Unrestricted stock
      IF ls_mat_stock-labst IS NOT INITIAL.
        zsits_scan_dynp-zzstocat = ' '.
        gv_qty = ls_mat_stock-labst.
      ENDIF.
*-- Check if the material has Quality stock
      IF ls_mat_stock-insme IS NOT INITIAL.
        zsits_scan_dynp-zzstocat = 'Q'.
        IF gv_qty IS INITIAL.
          gv_qty = ls_mat_stock-insme.
        ELSE.
*-- Raise an error msg that the material has multiple stocks
          gv_validation_fail = gc_x.
          gv_with_message = gc_x.
          MESSAGE e507(zits) INTO gv_dummy.
          PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                        gv_qty
                                        gv_with_message.
        ENDIF.
      ENDIF.
*-- Check if the material has Blocked stock
      IF ls_mat_stock-speme IS NOT INITIAL.
        zsits_scan_dynp-zzstocat = 'S'.
        IF gv_qty IS INITIAL.
          gv_qty = ls_mat_stock-speme.
        ELSE.
*-- Raise an error msg that the material has multiple stocks
          gv_validation_fail = gc_x.
          gv_with_message = gc_x.
          MESSAGE e507(zits) INTO gv_dummy.
          PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                        gv_qty
                                        gv_with_message.
        ENDIF.
      ENDIF.

*-- Stock category on the screen
      CONCATENATE text-007   "'Sto. catogory'
                  zsits_scan_dynp-zzstocat
                  INTO gv_sto_cat
                  SEPARATED BY '-'.
    ENDIF.
  ENDIF.
*-- Set the quantity zero flag if the qty is not there
  IF gv_qty IS INITIAL.
    gv_qty_zero = gc_x.
  ELSE.
    CLEAR: gv_qty_zero.
  ENDIF.
  CLEAR: ls_mat_stock, "ls_stock_im,
         ls_mat_stock_wm. "ls_stocks.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK_PLANT
*&---------------------------------------------------------------------*
*    Authorization check whether user is having access to plant or not
*----------------------------------------------------------------------*
FORM auth_check_plant .
  CLEAR: gv_dummy.

  AUTHORITY-CHECK OBJECT 'M_MSEG_WWA'
           ID 'WERKS' FIELD zsits_user_profile-zzwerks
           ID 'ACTVT' FIELD '01'.
  IF sy-subrc <> 0.
*-- Raise an error msg that user doesn't have the authorization
    gv_validation_fail = gc_x.
    gv_with_message = gc_x.
    MESSAGE e062(zone_msg) WITH zsits_user_profile-zzwerks INTO gv_dummy.
    PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                  zsits_user_profile-zzwerks
                                  gv_with_message.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK_WHN
*&---------------------------------------------------------------------*
*       Authorization check whether user is having access to whn or not
*----------------------------------------------------------------------*
FORM auth_check_whn .
  CLEAR: gv_dummy.

  AUTHORITY-CHECK OBJECT 'L_LGNUM'
           ID 'LGNUM' FIELD zsits_user_profile-zzlgnum
           ID 'LGTYP' DUMMY.
  IF sy-subrc <> 0.
*-- Raise an error msg user doesn't have the authorization
    gv_validation_fail = gc_x.
    gv_with_message = gc_x.
    MESSAGE e063(zone_msg) WITH zsits_user_profile-zzlgnum INTO gv_dummy.
    PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                  zsits_user_profile-zzlgnum
                                  gv_with_message.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK_MVT_TYPE
*&---------------------------------------------------------------------*
*     Authorization check whether user is having access to mvt type
*----------------------------------------------------------------------*
FORM auth_check_mvt_type .

  AUTHORITY-CHECK OBJECT 'M_MSEG_BWA'
           ID 'BWART' FIELD gv_mvt_type
           ID 'ACTVT' FIELD '01'.
  IF sy-subrc <> 0.
    CLEAR: gv_dummy.
*-- Raise an error msg that user doesn't have the authorization
    gv_validation_fail = gc_x.
    gv_with_message = gc_x.
    MESSAGE e066(zone_msg) WITH gv_mvt_type INTO gv_dummy.
    PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                  gv_mvt_type
                                  gv_with_message.
  ENDIF.

ENDFORM.
