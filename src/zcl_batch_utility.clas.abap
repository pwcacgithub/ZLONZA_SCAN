class ZCL_BATCH_UTILITY definition
  public
  final
  create public .

public section.

  constants GC_CHARA_SAMPLE_ASSIGNED type ATNAM value '' ##NO_TEXT.
  constants GC_HUITEM_TYPE_MAT type VELIN value '1' ##NO_TEXT.
  constants GC_INSP_LOT_DELETED type J_ISTAT value 'I0224' ##NO_TEXT.
  constants GC_QM_USER_STATUS_OK type J_ESTAT value 'E0037' ##NO_TEXT.
  constants GC_IM_STATUS_UNRESTRICT type CHAR01 value 'U' ##NO_TEXT.
  constants GC_IM_STATUS_BLOCK type CHAR01 value 'B' ##NO_TEXT.
  constants GC_IM_STATUS_RESTRICT type CHAR01 value 'R' ##NO_TEXT.
  constants GC_IM_STATUS_QI type CHAR01 value 'Q' ##NO_TEXT.
  constants GC_IM_STATUS_RETURN type CHAR01 value 'T' ##NO_TEXT.
  constants GC_BATCH_TYPE_FG type CHAR01 value 'F' ##NO_TEXT.
  constants GC_BATCH_TYPE_RM type CHAR01 value 'R' ##NO_TEXT.
  constants GC_BATCH_TYPE_WIP type CHAR01 value 'W' ##NO_TEXT.
  constants GC_BATCH_TYPE_PT type CHAR01 value 'P' ##NO_TEXT.
  constants GC_BATCH_TYPE_SAMPLE type CHAR01 value 'S' ##NO_TEXT.
  constants GC_BATCH_TYPE_ORIGIN type CHAR01 value 'O' ##NO_TEXT.
  constants GC_MTART_FG type MTART value 'ZHFG' ##NO_TEXT.
  constants GC_MTART_SEMI_FG type MTART value 'ZI*' ##NO_TEXT.
  constants GC_SAMPLE_IDENTIFIER type CHAR01 value 'Z' ##NO_TEXT.
  constants GC_UNRESTRICT_BATCH type CHAR01 value 'U' ##NO_TEXT.
  constants GC_ZERO_SUBLOT type CHAR03 value '000' ##NO_TEXT.
  constants GC_MEM_BATCH_CHAR_UPD type CHAR20 value 'ZITS_BATCH_CHAR_UPD' ##NO_TEXT.
  constants GC_RESTRICT_BATCH type CHAR01 value 'R' ##NO_TEXT.

  class-methods BATCH_LOCK
    importing
      !IS_BATCH_KEY type ZSITS_BATCH_KEY
      !IV_LOCK_MODE type ENQMODE default 'S'
      !IV_LOCK_PLANT type XFELD default ABAP_FALSE
    returning
      value(RV_RESULT) type BOOLEAN .
  class-methods BATCH_READ_HU
    importing
      !IV_BATCH type ZZBATCH
      !IS_READ_OPTION type ZSITS_BATCH_READ_OPTION optional
      !IV_LOGON_PLANT type WERKS_D optional
      !IV_LOGON_WAREHOUSE type LGNUM optional
    returning
      value(RS_BATCH_DATA) type ZSITS_BATCH_DATA .
  class-methods BATCH_STOCK_READ_HU
    importing
      !IV_PLANT type WERKS_D optional
      !IV_WAREHOUSE type LGNUM optional
    changing
      !CT_BATCH_DATA type ZSITS_BATCH_DATA_TAB .
  class-methods BATCH_UNLOCK
    importing
      !IS_BATCH_KEY type ZSITS_BATCH_KEY
      !IV_SYNCHRON type XFELD default ABAP_TRUE
      !IV_LOCK_MODE type ENQMODE default 'E'
      !IV_LOCK_PLANT type XFELD default ABAP_FALSE .
  class-methods GET_IM_STATUS
    importing
      !IS_BATCH_DATA type ZSITS_BATCH_DATA
    returning
      value(RV_STATUS) type CHAR1 .
  class-methods GET_QI_STATUS
    importing
      !IS_BATCH_DATA type ZSITS_BATCH_DATA
    returning
      value(RS_STATUS) type ZSITS_STATUS .
  class-methods INSPEC_LOC_LOCK_PROCESS
    importing
      !IV_UNLOCK type BOOLEAN default ABAP_FALSE
      !IV_INSPEC_LOT_NUMBER type QPLOS
    returning
      value(RV_RESULT) type BOOLEAN .
  class-methods IS_ZERO_BATCH
    importing
      !IS_BATCH_DATA type ZSITS_BATCH_DATA
    returning
      value(RV_RESULT) type XFELD .
  class-methods IS_FG_BATCH
    importing
      !IV_BATCH type ZZBATCH
      !IV_UNEXIST_CHECK type XFELD default ABAP_FALSE
      !IV_VENDOR_BATCH_CHECK type XFELD default ABAP_FALSE
      !IS_READ_OPTION type ZSITS_BATCH_READ_OPTION optional
      !IV_SKIP_OR_BATCH_CHECK type XFELD default ABAP_FALSE
      !IV_LOGON_PLANT type WERKS_D optional
      !IV_LOGON_WAREHOUSE type LGNUM optional
    returning
      value(RS_BATCH_DATA) type ZSITS_BATCH_DATA .
  class-methods BATCH_READ
    importing
      !IV_BATCH type ZZBATCH
      !IS_READ_OPTION type ZSITS_BATCH_READ_OPTION optional
      !IV_LOGON_PLANT type WERKS_D optional
      !IV_LOGON_WAREHOUSE type LGNUM optional
    returning
      value(RS_BATCH_DATA) type ZSITS_BATCH_DATA .
  class-methods BATCH_STOCK_READ
    importing
      !IV_PLANT type WERKS_D optional
      !IV_WAREHOUSE type LGNUM optional
    changing
      !CT_BATCH_DATA type ZSITS_BATCH_DATA_TAB .
  class-methods INSPEC_LOT_READ
    importing
      !IS_KEY type ZSITS_BATCH_KEY
    returning
      value(RS_INSPEC_LOT) type ZSITS_INSPEC_LOT .
  class-methods IS_WIP_BATCH
    importing
      !IV_BATCH type ZZBATCH
      !IV_UNEXIST_CHECK type XFELD default ABAP_FALSE
      !IV_VENDOR_BATCH_CHECK type XFELD default ABAP_FALSE
      !IS_READ_OPTION type ZSITS_BATCH_READ_OPTION optional
      !IV_LOGON_PLANT type WERKS_D optional
      !IV_LOGON_WAREHOUSE type LGNUM optional
    returning
      value(RS_BATCH_DATA) type ZSITS_BATCH_DATA .
  class-methods BATCH_FORMAT_CHECK
    importing
      !IV_BATCH type ZZBATCH
      !IV_BATCH_CATEGORY type CHAR01
    returning
      value(RV_RESULT) type XFELD .
  class-methods GET_ORIGIN_BATCH_BY_BATCH
    importing
      !IS_BATCH_DATA type ZSITS_BATCH_DATA
    returning
      value(RV_ORIGINAL_BATCH) type ZD_ORIGINAL_BATCH .
  class-methods IS_ORIGIN_BATCH
    importing
      !IV_BATCH type ZZBATCH
    returning
      value(ES_BATCH_DATA) type ZSITS_BATCH_DATA .
  class-methods IS_SAMPLE_BATCH
    importing
      !IV_BATCH type ZZBATCH
    returning
      value(RS_BATCH_DATA) type ZSITS_BATCH_DATA .
  class-methods IS_RW_BATCH
    importing
      !IV_BATCH type ZZBATCH
      !IV_MATNR type MATNR optional
      !IV_PARENT_BATCH type ZD_ORIGIN_BATCH
      !IS_READ_OPTION type ZSITS_BATCH_READ_OPTION optional
      !IV_UNEXIST_CHECK type XFELD default ABAP_FALSE
      !IV_LOGON_PLANT type WERKS_D optional
      !IV_LOGON_WAREHOUSE type LGNUM optional
    returning
      value(RS_BATCH_DATA) type ZSITS_BATCH_DATA .
  class-methods BATCH_READ_DFS
    importing
      !IV_BATCH type ZZBATCH
      !IV_MATNR type MATNR
      !IS_READ_OPTION type ZSITS_BATCH_READ_OPTION optional
      !IV_LOGON_PLANT type WERKS_D optional
      !IV_LOGON_WAREHOUSE type LGNUM optional
    returning
      value(RS_BATCH_DATA) type ZSITS_BATCH_DATA .
  class-methods BATCH_STOCK_READ_DFS
    importing
      !IV_PLANT type WERKS_D optional
      !IV_WAREHOUSE type LGNUM optional
    changing
      !CT_BATCH_DATA type ZSITS_BATCH_DATA_TAB .
  class-methods BATCH_OFF_PALLET
    importing
      !IS_BATCH_KEY type ZSITS_BATCH_KEY
      !IS_HU_W_EXTID type ZSITS_HU_ITEM optional
      !IV_SAVE_OPTION type CHAR01 optional
    returning
      value(RV_RESULT) type XFELD .
  class-methods IS_BATCH_ON_PALLET
    importing
      !IS_BATCH_DATA type ZSITS_BATCH_DATA
    returning
      value(RV_HU_ID) type EXIDV .
  class-methods BATCH_STATUS_UPDATE
    importing
      !IS_BATCH_DATA type ZSITS_BATCH_DATA
      !IV_BATCH_STATUS type CHAR01
      !IV_SAVE_OPTION type CHAR01 optional
    changing
      value(RV_RESULT) type BOOLEAN
      value(RV_MESSAGE) type STRING .
  class-methods BATCH_UPDATE
    importing
      !IS_BATCH_STR type ZSITS_BATCH_MASTER_DATAA
      !IV_SAVE_OPTION type CHAR01
    exporting
      !ET_RETURN type BAPIRET2_T .
protected section.
private section.
ENDCLASS.



CLASS ZCL_BATCH_UTILITY IMPLEMENTATION.


METHOD batch_format_check.
************************************************************************
************************************************************************
* Program ID:                        BATCH_FORMAT_CHECK
* Created By:                        Kripa S Patil
* Creation Date:                     02.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:
*
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 02.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
  DATA: lv_batch     TYPE charg_d,
        lv_dummy     TYPE string,
        lv_len       TYPE i,
        ls_mch1_data TYPE mch1,
        ls_batch_key TYPE zsits_batch_key,
        lv_order_num TYPE aufnr.

  rv_result = abap_false.

  lv_batch = iv_batch+0(10).

  TRANSLATE lv_batch TO UPPER CASE.

  lv_len = strlen( lv_batch ).

  IF lv_len LE 3.
    RETURN.
  ENDIF.
* get the start position
  lv_len = lv_len - 3 .

  CASE iv_batch_category .
    WHEN  gc_batch_type_fg.
* the 9th and 10th character should be number only
*------------------------------------------------------------------------------------------
      IF  lv_batch+lv_len(3) CN '0123456789'.
* It's not a WIP batch
        MESSAGE e014(zits) WITH iv_batch INTO lv_dummy.
        RETURN.
      ENDIF.

    WHEN  gc_batch_type_wip OR gc_batch_type_sample. " WIP or sample batch
* the 9th and 10th character should be number only
*------------------------------------------------------------------------------------------
      lv_len = lv_len + 1. " last 2
      IF  lv_batch+lv_len(2) CN '0123456789'.
* It's not a WIP batch
        MESSAGE e016(zits) WITH iv_batch INTO lv_dummy.
        RETURN.
      ENDIF.

* the 8th character of batch# is the specified WIP ID.
*------------------------------------------------------------------------------------------
      lv_len = lv_len - 1.   " the 3rd from right to left

*--Allow '-' character for 8th posstion on BatchID - Formweigh preptank (WIP) format
      IF lv_batch+lv_len(1) CN 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-'.
*      IF lv_batch+lv_len(1) CN 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.

* It's not a WIP batch
        MESSAGE e016(zits) WITH iv_batch INTO lv_dummy.
        RETURN.
      ENDIF.

      IF iv_batch_category  =  gc_batch_type_wip.
        IF lv_batch+lv_len(1) EQ gc_sample_identifier. " Sample Batch
* It's not a WIP batch
          MESSAGE e016(zits) WITH iv_batch INTO lv_dummy.
          RETURN.
        ENDIF.
      ELSEIF iv_batch_category  =  gc_batch_type_sample.
        IF lv_batch+lv_len(1) NE gc_sample_identifier. " Sample Batch
* It's not a sample batch
          MESSAGE e013(zits) WITH iv_batch INTO lv_dummy.
          RETURN.
        ENDIF.
      ENDIF.
    WHEN gc_batch_type_rm.

      rv_result = abap_true.

    WHEN  OTHERS.

      RETURN.

  ENDCASE.

  ls_batch_key-charg = lv_batch.
* Get the process/product# base on the importing batch#
*------------------------------------------------------------------------------------------
  CALL METHOD zcl_mtd_order_utility=>get_procord_by_batch
    EXPORTING
      is_key   = ls_batch_key
    IMPORTING
      ev_aufnr = lv_order_num.

  rv_result = abap_true.

ENDMETHOD.


METHOD batch_lock.

*--Begin of  ED2K906235 08/03/2015 HEGDEA INC2783004
* Locking material at header, plant and valuation level is causing cross plant locking
* between Greenwood and Pubela for FG materials. Hence a this control is introduced to
* bring flexibility to configure it based on behaviour

  DATA: lv_dummy   TYPE string,
        lv_name    TYPE rvari_vnam VALUE 'ZITS_LOCK_PARAMETERS',
        lv_type    TYPE rsscr_kind VALUE 'S',
        et_tvarvc  TYPE rseloption,
        ev_return  TYPE bapi_mtype.

  FIELD-SYMBOLS:
       <fs_tvarvc> TYPE rsdsselopt.

*--Read update control parameters
  CALL METHOD zcl_common_utility=>parameter_read
    EXPORTING
      iv_name   = lv_name
      iv_type   = lv_type
    IMPORTING
      et_tvarvc = et_tvarvc
      ev_return = ev_return.

*--Set results false
  rv_result = abap_false.

*--Loop the parameter list
  LOOP AT et_tvarvc ASSIGNING <fs_tvarvc>.

    CASE <fs_tvarvc>-low.
      WHEN 'MARA'.
        IF iv_lock_plant = abap_true AND is_batch_key-werks IS NOT INITIAL.
*--Lock material
          CALL FUNCTION 'ENQUEUE_EMMARAE'
            EXPORTING
              mode_mara      = iv_lock_mode
              matnr          = is_batch_key-matnr
              _scope         = '1'
            EXCEPTIONS
              foreign_lock   = 1
              system_failure = 2
              OTHERS         = 3.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.
            RETURN.
          ENDIF.
        ENDIF.

      WHEN 'MARC'.
        IF iv_lock_plant = abap_true AND is_batch_key-werks IS NOT INITIAL.
*--Lock the plant material
          CALL FUNCTION 'ENQUEUE_EMMARCE'
            EXPORTING
              mode_marc      = iv_lock_mode
              matnr          = is_batch_key-matnr
              werks          = is_batch_key-werks
              _scope         = '1'
            EXCEPTIONS
              foreign_lock   = 1
              system_failure = 2
              OTHERS         = 3.

          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.
            RETURN.
          ENDIF.
        ENDIF.

      WHEN 'MBEW'.
        IF iv_lock_plant = abap_true AND is_batch_key-werks IS NOT INITIAL.
*--Lock the material valuation table
          CALL FUNCTION 'ENQUEUE_EMMBEWE'
            EXPORTING
              mode_mbew      = iv_lock_mode
              matnr          = is_batch_key-matnr
              bwkey          = is_batch_key-werks
              _scope         = '1'
            EXCEPTIONS
              foreign_lock   = 1
              system_failure = 2
              OTHERS         = 3.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.
            RETURN.
          ENDIF.
        ENDIF.
      WHEN 'MCH1'.
*--Lock the batch
        CALL FUNCTION 'ENQUEUE_EMMCH1E'
          EXPORTING
            mode_mch1      = iv_lock_mode
            matnr          = is_batch_key-matnr
            charg          = is_batch_key-charg
            _scope         = '1'
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.
          RETURN.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

*--Mark results as successfull
  rv_result = abap_true.

ENDMETHOD.


METHOD batch_off_pallet.

  DATA: lt_return         TYPE bapiret2_t,
        lv_dummy          TYPE string,
        ls_hu_w_extid     TYPE zsits_hu_item,
        ls_hu_content     TYPE zshu_content,
        lv_no_of_cartons  TYPE i,
        ls_huitem         TYPE bapihuitmunpack,
        ls_batch_line     TYPE zsotc_batch,              "Batch Structure
        ls_num_value      TYPE bapi1003_alloc_values_num,
        lv_result         TYPE xfeld,
        lt_num_value      TYPE tt_bapi1003_alloc_values_num,
        ls_char_value     TYPE bapi1003_alloc_values_char,
        lt_char_value     TYPE tt_bapi1003_alloc_values_char.

  FIELD-SYMBOLS: <fs_hu_item> LIKE LINE OF ls_hu_content-hu_content.
*--------------------------------------------------------------------------
* Main functiona :     (1) Unpack the specify batch from HU
*                      (2) Clear the character value of Pallet_ID of batch

  CLEAR: rv_result.

* 1> Get the pallet# of HU which carton HU is packed on
*--------------------------------------------------------------------------
  IF is_hu_w_extid IS INITIAL.
*Start of change by Pete @ Aug 15 2015           ED2K906244
    DATA: ls_batch_data TYPE zsits_batch_data.
    MOVE-CORRESPONDING is_batch_key TO ls_batch_data.
*    ls_hu_w_extid = get_hu_id_by_batch( is_batch_key ).
    ls_hu_w_extid-exidv = zcl_batch_utility=>is_batch_on_pallet( ls_batch_data ).
*End of change by Pete @ Aug 15 2015             ED2K906244
  ELSE.
    ls_hu_w_extid = is_hu_w_extid.
  ENDIF.

* HU ID is initial ,stand for no HU assigned
  CHECK ls_hu_w_extid IS NOT INITIAL.

* Begin of change by Pete ED2K906244
  CALL METHOD zcl_its_utility=>hu_content_read
    EXPORTING
      iv_hu_id      = ls_hu_w_extid-exidv
    RECEIVING
      es_hu_content = ls_hu_content.

* We have location match logic during above method call.
  CHECK ls_hu_content IS NOT INITIAL.

* End  of change by Pete
* 2> Unpack the specify batch from HU
*--------------------------------------------------------------------------

  READ TABLE ls_hu_content-hu_content ASSIGNING <fs_hu_item> WITH KEY material =  is_batch_key-matnr
                                                                      batch    =  is_batch_key-charg.
  IF sy-subrc NE 0.
    MESSAGE e447(ZITS) WITH is_batch_key-charg ls_hu_w_extid-exidv INTO lv_dummy.
    RETURN.

  ENDIF.

  ls_huitem-hu_item_type   = zcl_batch_utility=>gc_huitem_type_mat. " 1 = Material Item
  ls_huitem-material       = is_batch_key-matnr.
  ls_huitem-batch          = is_batch_key-charg.
  ls_huitem-hu_item_number = <fs_hu_item>-hu_item_number.
  ls_huitem-pack_qty       = <fs_hu_item>-pack_qty.

  CALL FUNCTION 'BAPI_HU_UNPACK'
    EXPORTING
      hukey      = ls_hu_w_extid-exidv
      itemunpack = ls_huitem
    TABLES
      return     = lt_return.

  IF zcl_its_utility=>conv_bapiret_to_msg( lt_return ) = abap_false.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    RETURN.
  ENDIF.

* 3> Remove the HU# from the characteristic of batch master
*--------------------------------------------------------------------------

  ls_batch_line-matnr = is_batch_key-matnr.
  ls_batch_line-charg = is_batch_key-charg.

  ls_char_value-charact    = zcl_common_utility=>gc_chara_palletid.  " PALLET_ID
  " clear the value

  APPEND ls_char_value TO lt_char_value.

* Update classsification to batch to clear the value of character HU_ID
  CALL METHOD zcl_common_utility=>batch_char_add
    EXPORTING
      is_batch      = ls_batch_line
      it_valueschar = lt_char_value
    RECEIVING
      rv_result     = lv_result.

  IF lv_result = abap_false.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    RETURN.
  ENDIF.

*4 Commit Work
*--------------------------------------------------------------------------
  CALL METHOD zcl_common_utility=>commit_work
    EXPORTING
      iv_option = iv_save_option.

  DESCRIBE TABLE ls_hu_content-hu_content LINES lv_no_of_cartons.

  lv_no_of_cartons = lv_no_of_cartons - 1.  " ED2K906244

**Batch &1 has been unpacked from the pallet!
  MESSAGE s174(ZITS) WITH is_batch_key-charg ls_hu_w_extid-exidv lv_no_of_cartons INTO lv_dummy.

  rv_result = abap_true.

  CLEAR: lt_return,
         lv_dummy,
         ls_hu_w_extid,
         ls_huitem,
         ls_batch_line,
         ls_num_value,
         lt_num_value.

ENDMETHOD.


METHOD batch_read.
************************************************************************
************************************************************************
* Program ID:                        BATCH_READ
* Created By:                        Kripa S Patil
* Creation Date:                     03.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:
*
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 03.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
  DATA: lv_batch_length   TYPE i,
        ls_batch_key      TYPE zsits_batch_key,
        ls_legacy_batch   TYPE ztptp_batch,
        lv_dummy          TYPE string,
        lt_batch_data     TYPE zsits_batch_data_tab,
        lv_table_cnt      TYPE i,
        ls_order_key      TYPE zsmtd_order_sel,
        ls_order_detail   TYPE zsmtd_order_detail,
        ls_batch_char_key TYPE zsotc_batch,
        lv_stock_read     TYPE boolean.

  FIELD-SYMBOLS: <fs_order_hdr> TYPE LINE OF zttmtd_order_header.

  lv_batch_length = strlen( iv_batch ).

  CLEAR rs_batch_data.

  IF lv_batch_length > 10.  " Legacy batch number
*-------------------------------------------------------------------------------------------
* Convert the legacy batch# to SAP batch#
    SELECT * INTO CORRESPONDING FIELDS OF ls_legacy_batch
      UP TO 1 ROWS FROM ztptp_batch
      WHERE conc_key = iv_batch.
    ENDSELECT.

    IF sy-subrc EQ 0.

      SELECT SINGLE * INTO CORRESPONDING FIELDS OF  rs_batch_data FROM mch1 WHERE matnr = ls_legacy_batch-matnr
                                                                              AND charg = ls_legacy_batch-charg.
    ENDIF.

  ELSE.
*-------------------------------------------------------------------------------------------
    SELECT  * INTO CORRESPONDING FIELDS OF TABLE   lt_batch_data FROM mch1 WHERE charg = iv_batch+0(10).

    IF sy-subrc EQ 0.

      DESCRIBE TABLE lt_batch_data LINES lv_table_cnt.

      IF lv_table_cnt NE 1.
* In case of WIP material , there will be 1:N relationship between batch and material , so we have to get
* the material which have the stock ( assume only  one WIP material will have stock)

        CALL METHOD batch_stock_read
          EXPORTING
            iv_plant      = iv_logon_plant               " ED2K906454
            iv_warehouse  = iv_logon_warehouse           " ED2K906454
          CHANGING
            ct_batch_data = lt_batch_data.
* For WIP batch, anyway we will read bath stock.
        lv_stock_read  = abap_true.

      ENDIF.

      READ TABLE lt_batch_data INTO rs_batch_data INDEX 1.

    ENDIF.

  ENDIF.

  IF rs_batch_data IS INITIAL.
* Batch does not exist
    MESSAGE e015(ZITS) WITH iv_batch INTO lv_dummy.
    RETURN.
  ENDIF.

* Get basic uom from material master
*-------------------------------------------------------------------------------------------
  SELECT SINGLE mtart meins
    INTO (rs_batch_data-mtart,rs_batch_data-meins)
    FROM mara
   WHERE matnr = rs_batch_data-matnr.

* Batch Expire date check
*-------------------------------------------------------------------------------------------
  IF is_read_option-zzexpire_check = abap_true.

    IF rs_batch_data-vfdat IS INITIAL.
      CLEAR rs_batch_data.
      MESSAGE e389(ZITS) WITH iv_batch INTO lv_dummy.
      RETURN.
    ENDIF.

*    IF rs_batch_data-vfdat < sy-datum AND rs_batch_data-vfdat IS NOT INITIAL.    " ED2K904823 Localization
    IF rs_batch_data-vfdat < sy-datlo AND rs_batch_data-vfdat IS NOT INITIAL.     " ED2K904823 Localization
      CLEAR rs_batch_data.
      MESSAGE e045(ZITS) WITH iv_batch INTO lv_dummy.
      RETURN.

    ENDIF.

  ENDIF.

  MOVE-CORRESPONDING rs_batch_data TO ls_batch_key.

* caller requires the stock data (WIP batch stock retrieved above, not need to handle here)
*-------------------------------------------------------------------------------------------
  IF is_read_option-zzstock_read = abap_true AND lv_stock_read = abap_false.

    CLEAR lt_batch_data.

    APPEND rs_batch_data TO lt_batch_data.

    CALL METHOD batch_stock_read
      EXPORTING
        iv_plant      = iv_logon_plant               " ED2K906454
        iv_warehouse  = iv_logon_warehouse           " ED2K906454
      CHANGING
        ct_batch_data = lt_batch_data.

*  for batch, alway one line
    READ TABLE lt_batch_data INTO rs_batch_data INDEX 1.

  ENDIF.

* caller requires the stock data (WIP batch stock retrieved above, not need to handle here)
*-------------------------------------------------------------------------------------------
  IF is_read_option-zzprod_order_read = abap_true.

* Convert the batch to process order#
    CALL METHOD zcl_mtd_order_utility=>get_procord_by_batch
      EXPORTING
        is_key   = ls_batch_key
      IMPORTING
        ev_aufnr = ls_order_key-aufnr.

    ls_order_key-get_header = abap_true.

* Get the head info of process/product order
    CALL METHOD zcl_mtd_order_utility=>order_read
      EXPORTING
        is_order_key = ls_order_key
        iv_read_db   = abap_true
      IMPORTING
        es_detail    = ls_order_detail.

    READ TABLE ls_order_detail-header INDEX 1 ASSIGNING <fs_order_hdr>.

    IF sy-subrc EQ 0.
      MOVE:<fs_order_hdr>-order_number     TO rs_batch_data-production_data-aufnr,
           <fs_order_hdr>-order_type       TO rs_batch_data-production_data-auart,
           <fs_order_hdr>-sales_order      TO rs_batch_data-production_data-kdauf,
           <fs_order_hdr>-sales_order_item TO rs_batch_data-production_data-kdpos.
* Get the order category
      SELECT SINGLE autyp INTO rs_batch_data-production_data-autyp
        FROM aufk
       WHERE aufnr = rs_batch_data-production_data-aufnr.

    ENDIF.

  ENDIF.

  IF is_read_option-zzinsp_lot = abap_true.
* caller requires the inspection lot basic data
*-------------------------------------------------------------------------------------------
    rs_batch_data-insp_lot_data = zcl_batch_utility=>inspec_lot_read( ls_batch_key ).
  ENDIF.

  IF is_read_option-zzcharact_read = abap_true.
* Read Batch Characteristic
*-------------------------------------------------------------------------------------------

    ls_batch_char_key-charg = rs_batch_data-charg.
    ls_batch_char_key-werks = rs_batch_data-werks.
    ls_batch_char_key-matnr = rs_batch_data-matnr.

    CALL METHOD zcl_common_utility=>batch_char_read
      EXPORTING
        is_batch          = ls_batch_char_key
      IMPORTING
        es_classification = rs_batch_data-batch_charact.

  ENDIF.

ENDMETHOD.


METHOD BATCH_READ_DFS.
************************************************************************
************************************************************************
* Program ID:                        BATCH_READ_DFS
* Created By:                        Kripa S Patil
* Creation Date:                     02.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:                       Read batch data for DFS roll-out
*                           Copy from method BATCH_READ and make changes.
*
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 02.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*



  DATA: lv_batch_length   TYPE i,
        ls_batch_key      TYPE zsits_batch_key,
        ls_legacy_batch   TYPE ztptp_batch,
        lv_dummy          TYPE string,
        lt_batch_data     TYPE zsits_batch_data_tab,
        lv_table_cnt      TYPE i,
        ls_order_key      TYPE zsmtd_order_sel,
        ls_order_detail   TYPE zsmtd_order_detail,
        ls_batch_char_key TYPE zsotc_batch,
        lv_stock_read     TYPE boolean.

  FIELD-SYMBOLS: <fs_order_hdr> TYPE LINE OF zttmtd_order_header.

  lv_batch_length = strlen( iv_batch ).

  CLEAR rs_batch_data.

  IF lv_batch_length > 10.  " Legacy batch number
*-------------------------------------------------------------------------------------------
* Convert the legacy batch# to SAP batch#
    SELECT * INTO CORRESPONDING FIELDS OF ls_legacy_batch
      UP TO 1 ROWS FROM ztptp_batch
      WHERE conc_key = iv_batch.
    ENDSELECT.

    IF sy-subrc EQ 0.

      SELECT SINGLE * INTO CORRESPONDING FIELDS OF  rs_batch_data FROM mch1 WHERE matnr = ls_legacy_batch-matnr
                                                                              AND charg = ls_legacy_batch-charg.
    ENDIF.

  ELSE.
*-------------------------------------------------------------------------------------------

*    SELECT  * INTO CORRESPONDING FIELDS OF TABLE   lt_batch_data FROM mch1 WHERE charg = iv_batch+0(10).

    SELECT  * INTO CORRESPONDING FIELDS OF TABLE lt_batch_data FROM mch1
      WHERE matnr = iv_matnr AND charg = iv_batch+0(10).

    IF sy-subrc EQ 0.

      READ TABLE lt_batch_data INTO rs_batch_data INDEX 1.

    ENDIF.

  ENDIF.

  IF rs_batch_data IS INITIAL.
* Batch does not exist
    MESSAGE e015(ZITS) WITH iv_batch INTO lv_dummy.
    RETURN.
  ENDIF.

* Get basic uom from material master
*-------------------------------------------------------------------------------------------
  SELECT SINGLE mtart meins
    INTO (rs_batch_data-mtart,rs_batch_data-meins)
    FROM mara
   WHERE matnr = rs_batch_data-matnr.

* Batch Expire date check
*-------------------------------------------------------------------------------------------
  IF is_read_option-zzexpire_check = abap_true.

    IF rs_batch_data-vfdat IS INITIAL.
      CLEAR rs_batch_data.
      MESSAGE e389(ZITS) WITH iv_batch INTO lv_dummy.
      RETURN.
    ENDIF.

    IF rs_batch_data-vfdat < sy-datlo AND rs_batch_data-vfdat IS NOT INITIAL.
      CLEAR rs_batch_data.
      MESSAGE e045(ZITS) WITH iv_batch INTO lv_dummy.
      RETURN.

    ENDIF.

  ENDIF.

  MOVE-CORRESPONDING rs_batch_data TO ls_batch_key.

* caller requires the stock data (WIP batch stock retrieved above, not need to handle here)
*-------------------------------------------------------------------------------------------
  IF is_read_option-zzstock_read = abap_true AND lv_stock_read = abap_false.

    CLEAR lt_batch_data.

    APPEND rs_batch_data TO lt_batch_data.


*    CALL METHOD batch_stock_read
    CALL METHOD batch_stock_read_dfs

      EXPORTING
        iv_plant      = iv_logon_plant
        iv_warehouse  = iv_logon_warehouse
      CHANGING
        ct_batch_data = lt_batch_data.

*  for batch, alway one line
    READ TABLE lt_batch_data INTO rs_batch_data INDEX 1.

  ENDIF.

* caller requires the stock data (WIP batch stock retrieved above, not need to handle here)
*-------------------------------------------------------------------------------------------
  IF is_read_option-zzprod_order_read = abap_true.

* Convert the batch to process order#
    CALL METHOD zcl_mtd_order_utility=>get_procord_by_batch
      EXPORTING
        is_key   = ls_batch_key
      IMPORTING
        ev_aufnr = ls_order_key-aufnr.

    ls_order_key-get_header = abap_true.

* Get the head info of process/product order
    CALL METHOD zcl_mtd_order_utility=>order_read
      EXPORTING
        is_order_key = ls_order_key
        iv_read_db   = abap_true
      IMPORTING
        es_detail    = ls_order_detail.

    READ TABLE ls_order_detail-header INDEX 1 ASSIGNING <fs_order_hdr>.

    IF sy-subrc EQ 0.
      MOVE:<fs_order_hdr>-order_number     TO rs_batch_data-production_data-aufnr,
           <fs_order_hdr>-order_type       TO rs_batch_data-production_data-auart,
           <fs_order_hdr>-sales_order      TO rs_batch_data-production_data-kdauf,
           <fs_order_hdr>-sales_order_item TO rs_batch_data-production_data-kdpos.
* Get the order category
      SELECT SINGLE autyp INTO rs_batch_data-production_data-autyp
        FROM aufk
       WHERE aufnr = rs_batch_data-production_data-aufnr.

    ENDIF.

  ENDIF.

  IF is_read_option-zzinsp_lot = abap_true.
* caller requires the inspection lot basic data
*-------------------------------------------------------------------------------------------
    rs_batch_data-insp_lot_data = zcl_batch_utility=>inspec_lot_read( ls_batch_key ).
  ENDIF.

  IF is_read_option-zzcharact_read = abap_true.
* Read Batch Characteristic
*-------------------------------------------------------------------------------------------

    ls_batch_char_key-charg = rs_batch_data-charg.
    ls_batch_char_key-werks = rs_batch_data-werks.
    ls_batch_char_key-matnr = rs_batch_data-matnr.

    CALL METHOD zcl_common_utility=>batch_char_read
      EXPORTING
        is_batch          = ls_batch_char_key
      IMPORTING
        es_classification = rs_batch_data-batch_charact.

  ENDIF.

ENDMETHOD.


  METHOD batch_read_hu.
************************************************************************
************************************************************************
* Program ID:                        BATCH_READ_HU
* Created By:                        Subhashini Rawat
* Creation Date:                     09.OCT.2019
* Capsugel / Lonza RICEFW ID:        S0101
* Description:                       IM MANAGED HU FOR DELIVERY
*
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date          User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 09.OCT.2019   SRAWAT          1          D10K9A3RUB / EICR_603155:WM:US:HCDFS:MTC-NonHU SCAN 4 Dir Pick_38,39,101
*&---------------------------------------------------------------------*

    DATA: lv_batch_length   TYPE i,
          ls_batch_key      TYPE zsits_batch_key,
          ls_legacy_batch   TYPE ztptp_batch,
          lv_dummy          TYPE string,
          lt_batch_data     TYPE zsits_batch_data_tab,
          lv_table_cnt      TYPE i,
          ls_order_key      TYPE zsmtd_order_sel,
          ls_order_detail   TYPE zsmtd_order_detail,
          ls_batch_char_key TYPE zsotc_batch,
          lv_stock_read     TYPE boolean.

    FIELD-SYMBOLS: <fs_order_hdr> TYPE LINE OF zttmtd_order_header.

    lv_batch_length = strlen( iv_batch ).

    CLEAR rs_batch_data.

    IF lv_batch_length > 10.  " Legacy batch number
*-------------------------------------------------------------------------------------------
* Convert the legacy batch# to SAP batch#
      SELECT * INTO CORRESPONDING FIELDS OF ls_legacy_batch
        UP TO 1 ROWS FROM ztptp_batch
        WHERE conc_key = iv_batch.
      ENDSELECT.

      IF sy-subrc EQ 0.

        SELECT SINGLE * INTO CORRESPONDING FIELDS OF  rs_batch_data FROM mch1 WHERE matnr = ls_legacy_batch-matnr
                                                                                AND charg = ls_legacy_batch-charg.
      ENDIF.

    ELSE.
*-------------------------------------------------------------------------------------------
      SELECT  * INTO CORRESPONDING FIELDS OF TABLE   lt_batch_data FROM mch1 WHERE charg = iv_batch+0(10).

      IF sy-subrc EQ 0.

        DESCRIBE TABLE lt_batch_data LINES lv_table_cnt.

        IF lv_table_cnt NE 1.
* In case of WIP material , there will be 1:N relationship between batch and material , so we have to get
* the material which have the stock ( assume only  one WIP material will have stock)

          CALL METHOD batch_stock_read_hu
            EXPORTING
              iv_plant      = iv_logon_plant
            CHANGING
              ct_batch_data = lt_batch_data.
* For WIP batch, anyway we will read bath stock.
          lv_stock_read  = abap_true.

        ENDIF.
        READ TABLE lt_batch_data INTO rs_batch_data INDEX 1.
      ENDIF.
    ENDIF.

    IF rs_batch_data IS INITIAL.
* Batch does not exist
      MESSAGE e015(zits) WITH iv_batch INTO lv_dummy.
      RETURN.
    ENDIF.

* Get basic uom from material master
*-------------------------------------------------------------------------------------------
    SELECT SINGLE mtart meins
      INTO (rs_batch_data-mtart,rs_batch_data-meins)
      FROM mara
     WHERE matnr = rs_batch_data-matnr.

* Batch Expire date check
*-------------------------------------------------------------------------------------------
    IF is_read_option-zzexpire_check = abap_true.

      IF rs_batch_data-vfdat IS INITIAL.
        CLEAR rs_batch_data.
        MESSAGE e389(zits) WITH iv_batch INTO lv_dummy.
        RETURN.
      ENDIF.

      IF rs_batch_data-vfdat < sy-datlo AND rs_batch_data-vfdat IS NOT INITIAL.     " ED2K904823 Localization
        CLEAR rs_batch_data.
        MESSAGE e045(zits) WITH iv_batch INTO lv_dummy.
        RETURN.

      ENDIF.

    ENDIF.

    MOVE-CORRESPONDING rs_batch_data TO ls_batch_key.

* caller requires the stock data (WIP batch stock retrieved above, not need to handle here)
*-------------------------------------------------------------------------------------------
    IF is_read_option-zzstock_read = abap_true AND lv_stock_read = abap_false.

      CLEAR lt_batch_data.

      APPEND rs_batch_data TO lt_batch_data.

      CALL METHOD batch_stock_read_hu
        EXPORTING
          iv_plant      = iv_logon_plant               " ED2K906454
        CHANGING
          ct_batch_data = lt_batch_data.

*  for batch, alway one line
      READ TABLE lt_batch_data INTO rs_batch_data INDEX 1.

    ENDIF.

* caller requires the stock data (wip batch stock retrieved above, not need to handle here)
*-------------------------------------------------------------------------------------------
    IF is_read_option-zzprod_order_read = abap_true.

* Convert the batch to process order#
      CALL METHOD zcl_mtd_order_utility=>get_procord_by_batch
        EXPORTING
          is_key   = ls_batch_key
        IMPORTING
          ev_aufnr = ls_order_key-aufnr.

      ls_order_key-get_header = abap_true.

* Get the head info of process/product order
      CALL METHOD zcl_mtd_order_utility=>order_read
        EXPORTING
          is_order_key = ls_order_key
          iv_read_db   = abap_true
        IMPORTING
          es_detail    = ls_order_detail.

      READ TABLE ls_order_detail-header INDEX 1 ASSIGNING <fs_order_hdr>.

      IF sy-subrc EQ 0.
        MOVE:<fs_order_hdr>-order_number     TO rs_batch_data-production_data-aufnr,
             <fs_order_hdr>-order_type       TO rs_batch_data-production_data-auart,
             <fs_order_hdr>-sales_order      TO rs_batch_data-production_data-kdauf,
             <fs_order_hdr>-sales_order_item TO rs_batch_data-production_data-kdpos.
* Get the order category
        SELECT SINGLE autyp INTO rs_batch_data-production_data-autyp
          FROM aufk
         WHERE aufnr = rs_batch_data-production_data-aufnr.

      ENDIF.

    ENDIF.

    IF is_read_option-zzinsp_lot = abap_true.
* caller requires the inspection lot basic data
*-------------------------------------------------------------------------------------------
      rs_batch_data-insp_lot_data = zcl_batch_utility=>inspec_lot_read( ls_batch_key ).
    ENDIF.

    IF is_read_option-zzcharact_read = abap_true.
* Read Batch Characteristic
*-------------------------------------------------------------------------------------------

      ls_batch_char_key-charg = rs_batch_data-charg.
      ls_batch_char_key-werks = rs_batch_data-werks.
      ls_batch_char_key-matnr = rs_batch_data-matnr.

      CALL METHOD zcl_common_utility=>batch_char_read
        EXPORTING
          is_batch          = ls_batch_char_key
        IMPORTING
          es_classification = rs_batch_data-batch_charact.

    ENDIF.
  ENDMETHOD.


  METHOD batch_status_update.
** Method to change the batch status to restricted unrestricted
*
*
    DATA: ls_batch_update_line TYPE zsits_batch_master_dataa,
          lt_return            TYPE bapiret2_t.

    DATA : lv_return LIKE LINE OF lt_return.

    rv_result = abap_false.
* -------------------------------------------------------------------------------------
    CASE iv_batch_status.
      WHEN gc_restrict_batch.          " = 'R'.
        ls_batch_update_line-batch_status-restricted = abap_true.
      WHEN gc_unrestrict_batch.          " = 'U'.
        ls_batch_update_line-batch_status-restricted = abap_false.
    ENDCASE.

    ls_batch_update_line-batch_statusx-restricted = abap_true.  " Update the batch status
* -------------------------------------------------------------------------------------
    MOVE : is_batch_data-matnr TO ls_batch_update_line-batch_key-material,
           is_batch_data-charg TO ls_batch_update_line-batch_key-batch.

    CALL METHOD batch_update
      EXPORTING
        is_batch_str   = ls_batch_update_line
        iv_save_option = iv_save_option
      IMPORTING
        et_return      = lt_return.


    IF zcl_its_utility=>conv_bapiret_to_msg( lt_return ) = abap_false.
      LOOP AT lt_return INTO lv_return WHERE type = 'E' AND message IS NOT INITIAL.
        rv_message = lv_return-message.
        RETURN.
      ENDLOOP.
      RETURN.
    ENDIF.
* -------------------------------------------------------------------------------------

    rv_result = abap_true.
  ENDMETHOD.


METHOD batch_stock_read.
************************************************************************
************************************************************************
* Program ID:                        BATCH_STOCK_READ
* Created By:                        Kripa S Patil
* Creation Date:                     03.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:
*
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 03.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
  DATA: lt_batch_stock    TYPE STANDARD TABLE OF mchb,
        lt_batch_stock_wm TYPE STANDARD TABLE OF lqua,
        lt_t320_data      TYPE STANDARD TABLE OF t320,
        lt_batch_data     TYPE zsits_batch_data_tab,
        lv_tab_lines      TYPE i,
        ls_batch_key      TYPE zsits_batch_key,
        ls_order_key      TYPE zsmtd_order_sel,
        ls_order_detail   TYPE zsmtd_order_detail,
        lt_result         TYPE zstits_batch_wm_stock_tab,
        lt_so_stock       TYPE STANDARD TABLE OF mska.

  FIELD-SYMBOLS: <fs_stock_line> LIKE LINE OF lt_batch_stock,
                 <fs_batch_line> LIKE LINE OF ct_batch_data,
                 <fs_stock>      TYPE  zsits_batch_stock,
                 <fs_t320_line>  LIKE LINE OF lt_t320_data,
                 <fs_stock_wm>   LIKE LINE OF lt_batch_stock_wm,
                 <fs_result>     LIKE LINE OF lt_result,
                 <fs_so_stock>   LIKE LINE OF lt_so_stock,
                 <fs_order_mvt>  TYPE zsmtd_order_mvt_data.

  CHECK ct_batch_data IS NOT INITIAL.


*---------------------------------------------------------------------------------------------------------------------------------
  DATA: ls_logon_profile  TYPE zsits_user_profile,
        lv_plant          TYPE werks_d,
        lv_warehouse      TYPE lgnum,
        lt_r_plant        TYPE kk_werks_rtab,
        ls_plant_line     LIKE LINE OF lt_r_plant,
        lt_r_warehouse    TYPE mdg_bs_mat_t_range_lgnum,
        ls_warehouse_line LIKE LINE OF lt_r_warehouse.


  IF iv_plant IS INITIAL AND iv_warehouse IS INITIAL.
* We have to pass the logon plant or warehouse# to method BATCH_STOCK_READ,means the stock data
* will be only for the logon location
* 1> Assume call the scan transaction should be triggered thru ZITSELOGON scan .
* 2> For reprocess program, no logon data could be found, we have to use another approach to catch the original logon data
* 3> For programs other than ITS, no logon data could be find,the return stock is not correct.

    CALL METHOD zcl_its_utility=>get_user_profile
      RECEIVING
        rs_user_profile = ls_logon_profile.

    lv_plant     = ls_logon_profile-zzwerks.
    lv_warehouse = ls_logon_profile-zzlgnum.

  ELSEIF iv_plant IS NOT INITIAL AND iv_warehouse IS NOT INITIAL.
    RETURN.
  ELSE.
    lv_plant     = iv_plant.
    lv_warehouse =  iv_warehouse.
  ENDIF.

  IF lv_plant IS NOT INITIAL.
    ls_plant_line-sign   = 'I'.
    ls_plant_line-option = 'EQ'.
    ls_plant_line-low    = lv_plant.
    APPEND ls_plant_line TO lt_r_plant.
  ENDIF.

  IF lv_warehouse IS NOT INITIAL.
    ls_warehouse_line-sign   = 'I'.
    ls_warehouse_line-option = 'EQ'.
    ls_warehouse_line-low    = lv_warehouse.
    APPEND ls_warehouse_line TO lt_r_warehouse.
  ENDIF.


  SELECT * INTO TABLE lt_batch_stock
    FROM mchb
     FOR ALL ENTRIES IN ct_batch_data
   WHERE matnr     EQ ct_batch_data-matnr
     AND charg     EQ ct_batch_data-charg
     AND werks     IN lt_r_plant
     AND lvorm     EQ space.

  SORT lt_batch_stock BY matnr charg.

* remove the batch record which has zero stock

  DELETE lt_batch_stock WHERE clabs = 0    " Available
                          AND cumlm = 0    " In Transit
                          AND cinsm = 0    " Insp.
                          AND ceinm = 0    " Restricted
                          AND cspem = 0.    " Block


  IF lt_batch_stock IS INITIAL.
*Try to find the sales order stock
    SELECT * INTO TABLE lt_so_stock
      FROM mska
       FOR ALL ENTRIES IN ct_batch_data
     WHERE matnr       EQ ct_batch_data-matnr
       AND charg       EQ ct_batch_data-charg
       AND werks       IN lt_r_plant.

    IF sy-subrc EQ 0.
* Get plant+Storage location are WM relevant
      SELECT * INTO TABLE lt_t320_data
        FROM t320
        FOR ALL ENTRIES IN lt_so_stock
      WHERE werks  =  lt_so_stock-werks
        AND lgort  =  lt_so_stock-lgort
        AND lgnum IN  lt_r_warehouse.

      DELETE lt_so_stock WHERE kalab = 0
                           AND kains = 0
                           AND kaspe = 0
                           AND kaein = 0.

      SORT lt_so_stock BY matnr charg.

      LOOP AT ct_batch_data ASSIGNING <fs_batch_line>.

        READ TABLE lt_so_stock  TRANSPORTING NO FIELDS WITH KEY matnr = <fs_batch_line>-matnr
                                                                charg = <fs_batch_line>-charg.
        IF sy-subrc EQ 0.

          LOOP AT lt_so_stock ASSIGNING <fs_so_stock> WHERE matnr = <fs_batch_line>-matnr
                                                       AND  charg = <fs_batch_line>-charg.


            IF lt_r_warehouse IS NOT INITIAL.
* If warehouse import, we have to exclude the IM stock which plant/st. loc not assigned to the import warehouse
              READ TABLE lt_t320_data TRANSPORTING NO FIELDS WITH KEY werks = <fs_so_stock>-werks
                                                                      lgort = <fs_so_stock>-lgort.
              IF sy-subrc NE 0.
                DELETE lt_so_stock.
                CONTINUE.
              ENDIF.
            ENDIF.
*End  of
            <fs_batch_line>-werks = <fs_so_stock>-werks. " Plant.

            APPEND INITIAL LINE TO <fs_batch_line>-batch_stock ASSIGNING <fs_stock>.

            MOVE: <fs_so_stock>-lgort    TO <fs_stock>-lgort,
                  <fs_so_stock>-kalab    TO <fs_stock>-clabs,
                  <fs_so_stock>-kains    TO <fs_stock>-cinsm,
                  <fs_so_stock>-kaspe    TO <fs_stock>-cspem,
                  <fs_so_stock>-kaein    TO <fs_stock>-ceinm,
                  <fs_so_stock>-vbeln    TO <fs_stock>-vbeln,
                  <fs_so_stock>-posnr    TO <fs_stock>-posnr,
                  <fs_so_stock>-sobkz    TO <fs_stock>-sobkz.

* Total Stock:
            <fs_stock>-zztotal_stock =   <fs_stock>-clabs
                                        + <fs_stock>-cumlm
                                        + <fs_stock>-cinsm
                                        + <fs_stock>-ceinm
                                        + <fs_stock>-cspem.
*                                        + <fs_stock>-cretm.  " return stock is not used for the moment

            READ TABLE lt_t320_data ASSIGNING <fs_t320_line> WITH KEY werks = <fs_so_stock>-werks
                                                                      lgort = <fs_so_stock>-lgort.
            IF sy-subrc EQ 0.
              APPEND INITIAL LINE TO lt_batch_stock_wm ASSIGNING <fs_stock_wm>.
              MOVE-CORRESPONDING: <fs_t320_line>  TO <fs_stock_wm>,
                                  <fs_so_stock>   TO <fs_stock_wm>.

            ENDIF.

          ENDLOOP.

        ELSE.

          DELETE ct_batch_data.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDIF.

  IF lt_batch_stock IS NOT INITIAL.
* Get plant+Storage location are WM relevant
    SELECT * INTO TABLE lt_t320_data
      FROM t320
      FOR ALL ENTRIES IN lt_batch_stock
    WHERE werks = lt_batch_stock-werks
      AND lgort = lt_batch_stock-lgort
      AND lgnum IN lt_r_warehouse.

* move the batch stock by SL level to the batch data

    LOOP AT ct_batch_data ASSIGNING <fs_batch_line>.

      READ TABLE lt_batch_stock ASSIGNING <fs_stock_line> WITH KEY matnr = <fs_batch_line>-matnr
                                                                    charg = <fs_batch_line>-charg.

      IF sy-subrc = 0.
        LOOP AT lt_batch_stock ASSIGNING <fs_stock_line> WHERE matnr = <fs_batch_line>-matnr
                                                           AND charg = <fs_batch_line>-charg.


            IF lt_r_warehouse IS NOT INITIAL.
* If warehouse import, we have to exclude the IM stock which plant/st. loc not assigned to the import warehouse
              READ TABLE lt_t320_data TRANSPORTING NO FIELDS WITH KEY werks = <fs_stock_line>-werks
                                                                      lgort = <fs_stock_line>-lgort.
              IF sy-subrc NE 0.
                DELETE lt_batch_stock.
                CONTINUE.
              ENDIF.
            ENDIF.



          <fs_batch_line>-werks = <fs_stock_line>-werks. " Plant.

          APPEND INITIAL LINE TO <fs_batch_line>-batch_stock ASSIGNING <fs_stock>.

          MOVE-CORRESPONDING <fs_stock_line>  TO <fs_stock>.

* Total Stock:

          <fs_stock>-zztotal_stock =   <fs_stock>-clabs
                                      + <fs_stock>-cumlm
                                      + <fs_stock>-cinsm
                                      + <fs_stock>-ceinm
                                      + <fs_stock>-cspem.
*                                      + <fs_stock>-cretm." return stock is not used for the moment

          READ TABLE lt_t320_data ASSIGNING <fs_t320_line> WITH KEY werks = <fs_stock_line>-werks
                                                                    lgort = <fs_stock_line>-lgort.
          IF sy-subrc EQ 0.
            APPEND INITIAL LINE TO lt_batch_stock_wm ASSIGNING <fs_stock_wm>.
            MOVE-CORRESPONDING: <fs_t320_line>  TO <fs_stock_wm>,
                                <fs_stock_line> TO <fs_stock_wm>.
          ENDIF.

        ENDLOOP.
      ELSE.
        DELETE ct_batch_data.
      ENDIF.
    ENDLOOP.

  ENDIF.


* WM Stock Read.
*-----------------------------------------------------------------------------------------------------
  IF lt_batch_stock_wm IS NOT INITIAL.
* means there's plant+sl are WM relevant

    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_result
       FROM lqua
        FOR ALL ENTRIES IN lt_batch_stock_wm
     WHERE lgnum EQ lt_batch_stock_wm-lgnum  " Not need add lt_r_warehouse check here coz we use this criteria when reading T320 above
       AND matnr EQ lt_batch_stock_wm-matnr
       AND charg EQ lt_batch_stock_wm-charg
       AND werks EQ lt_batch_stock_wm-werks
       AND lgort EQ lt_batch_stock_wm-lgort.

    LOOP AT  ct_batch_data ASSIGNING <fs_batch_line>.

      MOVE lt_result TO <fs_batch_line>-batch_stock_wm.

    ENDLOOP.

  ENDIF.

  IF lt_batch_stock IS INITIAL AND lt_so_stock IS INITIAL.
* Means the all stocks of WIP batch have been issued , we should try to find out the  WIP material which has the last the issue mvt. record
    DESCRIBE TABLE ct_batch_data LINES lv_tab_lines.
    IF lv_tab_lines > 1.

      READ TABLE ct_batch_data ASSIGNING <fs_batch_line> INDEX 1.

      MOVE-CORRESPONDING <fs_batch_line> TO ls_batch_key.
* Get the process order# by batch
      CALL METHOD zcl_mtd_order_utility=>get_procord_by_batch
        EXPORTING
          is_key   = ls_batch_key
        IMPORTING
          ev_aufnr = ls_order_key-aufnr.

      ls_order_key-get_mvt    = abap_true.
      ls_order_key-get_header = abap_true.
* Get historical movement
      CALL METHOD zcl_mtd_order_utility=>order_read
        EXPORTING
          is_order_key = ls_order_key
        IMPORTING
          es_detail    = ls_order_detail.

      SORT ls_order_detail-mvt_his DESCENDING BY mjahr mblnr.

      LOOP AT ls_order_detail-mvt_his ASSIGNING <fs_order_mvt>.

        READ TABLE ct_batch_data ASSIGNING <fs_batch_line> WITH KEY matnr = <fs_order_mvt>-matnr
                                                                    charg = <fs_order_mvt>-charg.
        IF sy-subrc EQ 0.

          DELETE ct_batch_data WHERE matnr NE <fs_order_mvt>-matnr
                                  OR charg NE <fs_order_mvt>-charg.
          EXIT.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDIF.

ENDMETHOD.


METHOD batch_stock_read_dfs.
************************************************************************
************************************************************************
* Program ID:                        BATCH_STOCK_READ_DFS
* Created By:                        Kripa S Patil
* Creation Date:                     02.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:                       Read batch stock for DFS roll-out
*                     Copy from method BATCH_STOCK_READ and make changes.
*
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 02.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*



  DATA: lt_batch_stock    TYPE STANDARD TABLE OF mchb,
        lt_batch_stock_wm TYPE STANDARD TABLE OF lqua,
        lt_t320_data      TYPE STANDARD TABLE OF t320,
        lt_batch_data     TYPE zsits_batch_data_tab,
        lv_tab_lines      TYPE i,
        ls_batch_key      TYPE zsits_batch_key,
        ls_order_key      TYPE zsmtd_order_sel,
        ls_order_detail   TYPE zsmtd_order_detail,
        lt_result         TYPE zstits_batch_wm_stock_tab,
        lt_so_stock       TYPE STANDARD TABLE OF mska,

        lt_prj_stock      TYPE STANDARD TABLE OF mspr.


  FIELD-SYMBOLS: <fs_stock_line> LIKE LINE OF lt_batch_stock,
                 <fs_batch_line> LIKE LINE OF ct_batch_data,
                 <fs_stock>      TYPE  zsits_batch_stock,
                 <fs_t320_line>  LIKE LINE OF lt_t320_data,
                 <fs_stock_wm>   LIKE LINE OF lt_batch_stock_wm,
                 <fs_result>     LIKE LINE OF lt_result,
                 <fs_so_stock>   LIKE LINE OF lt_so_stock,
                 <fs_order_mvt>  TYPE zsmtd_order_mvt_data,

                 <fs_prj_stock>   LIKE LINE OF lt_prj_stock.


  CHECK ct_batch_data IS NOT INITIAL.


*---------------------------------------------------------------------------------------------------------------------------------
  DATA: ls_logon_profile  TYPE zsits_user_profile,
        lv_plant          TYPE werks_d,
        lv_warehouse      TYPE lgnum,
        lt_r_plant        TYPE kk_werks_rtab,
        ls_plant_line     LIKE LINE OF lt_r_plant,
        lt_r_warehouse    TYPE mdg_bs_mat_t_range_lgnum,
        ls_warehouse_line LIKE LINE OF lt_r_warehouse.


  IF iv_plant IS INITIAL AND iv_warehouse IS INITIAL.
* We have to pass the logon plant or warehouse# to method BATCH_STOCK_READ,means the stock data
* will be only for the logon location
* 1> Assume call the scan transaction should be triggered thru ZITSELOGON scan .
* 2> For reprocess program, no logon data could be found, we have to use another approach to catch the original logon data
* 3> For programs other than ITS, no logon data could be find,the return stock is not correct.

    CALL METHOD zcl_its_utility=>get_user_profile
      RECEIVING
        rs_user_profile = ls_logon_profile.

    lv_plant     = ls_logon_profile-zzwerks.
    lv_warehouse = ls_logon_profile-zzlgnum.

  ELSEIF iv_plant IS NOT INITIAL AND iv_warehouse IS NOT INITIAL.
    RETURN.
  ELSE.
    lv_plant     = iv_plant.
    lv_warehouse =  iv_warehouse.
  ENDIF.

  IF lv_plant IS NOT INITIAL.
    ls_plant_line-sign   = 'I'.
    ls_plant_line-option = 'EQ'.
    ls_plant_line-low    = lv_plant.
    APPEND ls_plant_line TO lt_r_plant.
  ENDIF.

  IF lv_warehouse IS NOT INITIAL.
    ls_warehouse_line-sign   = 'I'.
    ls_warehouse_line-option = 'EQ'.
    ls_warehouse_line-low    = lv_warehouse.
    APPEND ls_warehouse_line TO lt_r_warehouse.
  ENDIF.

  SELECT * INTO TABLE lt_batch_stock
    FROM mchb
     FOR ALL ENTRIES IN ct_batch_data
   WHERE matnr     EQ ct_batch_data-matnr
     AND charg     EQ ct_batch_data-charg
     AND werks     IN lt_r_plant
     AND lvorm     EQ space.

  SORT lt_batch_stock BY matnr charg.

* remove the batch record which has zero stock

  DELETE lt_batch_stock WHERE clabs = 0    " Available
                          AND cumlm = 0    " In Transit
                          AND cinsm = 0    " Insp.
                          AND ceinm = 0    " Restricted
                          AND cspem = 0.    " Block

  IF ct_batch_data IS NOT INITIAL.
*Try to find the sales order stock
    SELECT * INTO TABLE lt_so_stock
      FROM mska
       FOR ALL ENTRIES IN ct_batch_data
     WHERE matnr       EQ ct_batch_data-matnr
       AND charg       EQ ct_batch_data-charg
       AND werks       IN lt_r_plant.

    IF sy-subrc EQ 0.
* Get plant+Storage location are WM relevant
      SELECT * INTO TABLE lt_t320_data
        FROM t320
        FOR ALL ENTRIES IN lt_so_stock
      WHERE werks  =  lt_so_stock-werks
        AND lgort  =  lt_so_stock-lgort
        AND lgnum IN  lt_r_warehouse.

      DELETE lt_so_stock WHERE kalab = 0
                           AND kains = 0
                           AND kaspe = 0
                           AND kaein = 0.

      SORT lt_so_stock BY matnr charg.

      LOOP AT ct_batch_data ASSIGNING <fs_batch_line>.

        READ TABLE lt_so_stock  TRANSPORTING NO FIELDS WITH KEY matnr = <fs_batch_line>-matnr
                                                                charg = <fs_batch_line>-charg.
        IF sy-subrc EQ 0.

          LOOP AT lt_so_stock ASSIGNING <fs_so_stock> WHERE matnr = <fs_batch_line>-matnr
                                                       AND  charg = <fs_batch_line>-charg.


            IF lt_r_warehouse IS NOT INITIAL.
* If warehouse import, we have to exclude the IM stock which plant/st. loc not assigned to the import warehouse
              READ TABLE lt_t320_data TRANSPORTING NO FIELDS WITH KEY werks = <fs_so_stock>-werks
                                                                      lgort = <fs_so_stock>-lgort.
              IF sy-subrc NE 0.
                DELETE lt_so_stock.
                CONTINUE.
              ENDIF.
            ENDIF.
            <fs_batch_line>-werks = <fs_so_stock>-werks. " Plant.

            APPEND INITIAL LINE TO <fs_batch_line>-batch_stock ASSIGNING <fs_stock>.

            MOVE: <fs_so_stock>-lgort    TO <fs_stock>-lgort,
                  <fs_so_stock>-kalab    TO <fs_stock>-clabs,
                  <fs_so_stock>-kains    TO <fs_stock>-cinsm,
                  <fs_so_stock>-kaspe    TO <fs_stock>-cspem,
                  <fs_so_stock>-kaein    TO <fs_stock>-ceinm,
                  <fs_so_stock>-vbeln    TO <fs_stock>-vbeln,
                  <fs_so_stock>-posnr    TO <fs_stock>-posnr,
                  <fs_so_stock>-sobkz    TO <fs_stock>-sobkz.

* Total Stock:
            <fs_stock>-zztotal_stock =   <fs_stock>-clabs
                                        + <fs_stock>-cumlm
                                        + <fs_stock>-cinsm
                                        + <fs_stock>-ceinm
                                        + <fs_stock>-cspem.
*                                        + <fs_stock>-cretm.  " return stock is not used for the moment

            READ TABLE lt_t320_data ASSIGNING <fs_t320_line> WITH KEY werks = <fs_so_stock>-werks
                                                                      lgort = <fs_so_stock>-lgort.
            IF sy-subrc EQ 0.
              APPEND INITIAL LINE TO lt_batch_stock_wm ASSIGNING <fs_stock_wm>.
              MOVE-CORRESPONDING: <fs_t320_line>  TO <fs_stock_wm>,
                                  <fs_so_stock>   TO <fs_stock_wm>.

            ENDIF.

          ENDLOOP.

        ELSE.

          DELETE ct_batch_data.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDIF.

  IF lt_batch_stock IS NOT INITIAL.
* Get plant+Storage location are WM relevant
    SELECT * INTO TABLE lt_t320_data
      FROM t320
      FOR ALL ENTRIES IN lt_batch_stock
    WHERE werks = lt_batch_stock-werks
      AND lgort = lt_batch_stock-lgort
      AND lgnum IN lt_r_warehouse.

* move the batch stock by SL level to the batch data

    LOOP AT ct_batch_data ASSIGNING <fs_batch_line>.

      READ TABLE lt_batch_stock ASSIGNING <fs_stock_line> WITH KEY matnr = <fs_batch_line>-matnr
                                                                    charg = <fs_batch_line>-charg.

      IF sy-subrc = 0.
        LOOP AT lt_batch_stock ASSIGNING <fs_stock_line> WHERE matnr = <fs_batch_line>-matnr
                                                           AND charg = <fs_batch_line>-charg.


          IF lt_r_warehouse IS NOT INITIAL.
* If warehouse import, we have to exclude the IM stock which plant/st. loc not assigned to the import warehouse
            READ TABLE lt_t320_data TRANSPORTING NO FIELDS WITH KEY werks = <fs_stock_line>-werks
                                                                    lgort = <fs_stock_line>-lgort.
            IF sy-subrc NE 0.
              DELETE lt_batch_stock.
              CONTINUE.
            ENDIF.
          ENDIF.


          <fs_batch_line>-werks = <fs_stock_line>-werks. " Plant.

          APPEND INITIAL LINE TO <fs_batch_line>-batch_stock ASSIGNING <fs_stock>.

          MOVE-CORRESPONDING <fs_stock_line>  TO <fs_stock>.

* Total Stock:

          <fs_stock>-zztotal_stock =   <fs_stock>-clabs
                                      + <fs_stock>-cumlm
                                      + <fs_stock>-cinsm
                                      + <fs_stock>-ceinm
                                      + <fs_stock>-cspem.

          READ TABLE lt_t320_data ASSIGNING <fs_t320_line> WITH KEY werks = <fs_stock_line>-werks
                                                                    lgort = <fs_stock_line>-lgort.
          IF sy-subrc EQ 0.
            APPEND INITIAL LINE TO lt_batch_stock_wm ASSIGNING <fs_stock_wm>.
            MOVE-CORRESPONDING: <fs_t320_line>  TO <fs_stock_wm>,
                                <fs_stock_line> TO <fs_stock_wm>.
          ENDIF.

        ENDLOOP.
      ELSE.
        DELETE ct_batch_data.
      ENDIF.
    ENDLOOP.

  ENDIF.


*To read Project Stock
  IF ct_batch_data IS NOT INITIAL.
*Try to find the sales order stock
    SELECT * INTO TABLE lt_prj_stock
      FROM mspr
       FOR ALL ENTRIES IN ct_batch_data
     WHERE matnr       EQ ct_batch_data-matnr
       AND werks       IN lt_r_plant
       AND charg       EQ ct_batch_data-charg.


    IF sy-subrc EQ 0.
* Get plant+Storage location are WM relevant
      SELECT * INTO TABLE lt_t320_data
        FROM t320
        FOR ALL ENTRIES IN lt_prj_stock
      WHERE werks  =  lt_prj_stock-werks
        AND lgort  =  lt_prj_stock-lgort
        AND lgnum IN  lt_r_warehouse.

      DELETE lt_prj_stock WHERE prlab = 0
                           AND prins = 0
                           AND prspe = 0
                           AND prein = 0.

      SORT lt_prj_stock BY matnr charg.

      LOOP AT ct_batch_data ASSIGNING <fs_batch_line>.

        READ TABLE lt_prj_stock  TRANSPORTING NO FIELDS WITH KEY matnr = <fs_batch_line>-matnr
                                                                charg = <fs_batch_line>-charg.
        IF sy-subrc EQ 0.

          LOOP AT lt_prj_stock ASSIGNING <fs_prj_stock> WHERE matnr = <fs_batch_line>-matnr
                                                       AND  charg = <fs_batch_line>-charg.


            IF lt_r_warehouse IS NOT INITIAL.
* If warehouse import, we have to exclude the IM stock which plant/st. loc not assigned to the import warehouse
              READ TABLE lt_t320_data TRANSPORTING NO FIELDS WITH KEY werks = <fs_prj_stock>-werks
                                                                      lgort = <fs_prj_stock>-lgort.
              IF sy-subrc NE 0.
                DELETE lt_prj_stock.
                CONTINUE.
              ENDIF.
            ENDIF.
            <fs_batch_line>-werks = <fs_prj_stock>-werks. " Plant.

            APPEND INITIAL LINE TO <fs_batch_line>-batch_stock ASSIGNING <fs_stock>.

            MOVE: <fs_prj_stock>-lgort    TO <fs_stock>-lgort,
                  <fs_prj_stock>-prlab    TO <fs_stock>-clabs, "Valuated Unrestricted-Use Stock
                  <fs_prj_stock>-prins    TO <fs_stock>-cinsm, "Stock in Quality Inspection
                  <fs_prj_stock>-prspe    TO <fs_stock>-cspem, "Blocked Stock
                  <fs_prj_stock>-prein    TO <fs_stock>-ceinm, "Total Stock of All Restricted Batches
                  <fs_prj_stock>-sobkz    TO <fs_stock>-sobkz.

* Total Stock:
            <fs_stock>-zztotal_stock =   <fs_stock>-clabs
                                        + <fs_stock>-cumlm
                                        + <fs_stock>-cinsm
                                        + <fs_stock>-ceinm
                                        + <fs_stock>-cspem.
*                                        + <fs_stock>-cretm.  " return stock is not used for the moment

            READ TABLE lt_t320_data ASSIGNING <fs_t320_line> WITH KEY werks = <fs_prj_stock>-werks
                                                                      lgort = <fs_prj_stock>-lgort.
            IF sy-subrc EQ 0.
              APPEND INITIAL LINE TO lt_batch_stock_wm ASSIGNING <fs_stock_wm>.
              MOVE-CORRESPONDING: <fs_t320_line>  TO <fs_stock_wm>,
                                  <fs_prj_stock>   TO <fs_stock_wm>.

            ENDIF.

          ENDLOOP.

        ELSE.

          DELETE ct_batch_data.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDIF.


* WM Stock Read.
*-----------------------------------------------------------------------------------------------------
  IF lt_batch_stock_wm IS NOT INITIAL.
* means there's plant+sl are WM relevant

    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_result
       FROM lqua
        FOR ALL ENTRIES IN lt_batch_stock_wm
     WHERE lgnum EQ lt_batch_stock_wm-lgnum  " Not need add lt_r_warehouse check here coz we use this criteria when reading T320 above
       AND matnr EQ lt_batch_stock_wm-matnr
       AND charg EQ lt_batch_stock_wm-charg
       AND werks EQ lt_batch_stock_wm-werks
       AND lgort EQ lt_batch_stock_wm-lgort.

    LOOP AT  ct_batch_data ASSIGNING <fs_batch_line>.

      MOVE lt_result TO <fs_batch_line>-batch_stock_wm.


    ENDLOOP.

  ENDIF.

  IF lt_batch_stock IS INITIAL AND lt_so_stock IS INITIAL.
* Means the all stocks of WIP batch have been issued , we should try to find out the  WIP material which has the last the issue mvt. record
    DESCRIBE TABLE ct_batch_data LINES lv_tab_lines.
    IF lv_tab_lines > 1.

      READ TABLE ct_batch_data ASSIGNING <fs_batch_line> INDEX 1.

      MOVE-CORRESPONDING <fs_batch_line> TO ls_batch_key.
* Get the process order# by batch
      CALL METHOD zcl_mtd_order_utility=>get_procord_by_batch
        EXPORTING
          is_key   = ls_batch_key
        IMPORTING
          ev_aufnr = ls_order_key-aufnr.

      ls_order_key-get_mvt    = abap_true.
      ls_order_key-get_header = abap_true.
* Get historical movement
      CALL METHOD zcl_mtd_order_utility=>order_read
        EXPORTING
          is_order_key = ls_order_key
        IMPORTING
          es_detail    = ls_order_detail.

      SORT ls_order_detail-mvt_his DESCENDING BY mjahr mblnr.

      LOOP AT ls_order_detail-mvt_his ASSIGNING <fs_order_mvt>.

        READ TABLE ct_batch_data ASSIGNING <fs_batch_line> WITH KEY matnr = <fs_order_mvt>-matnr
                                                                    charg = <fs_order_mvt>-charg.
        IF sy-subrc EQ 0.

          DELETE ct_batch_data WHERE matnr NE <fs_order_mvt>-matnr
                                  OR charg NE <fs_order_mvt>-charg.
          EXIT.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDIF.

ENDMETHOD.


  METHOD batch_stock_read_hu.
************************************************************************
************************************************************************
* Program ID:                        BATCH_STOCK_READ_HU
* Created By:                        Subhashini Rawat
* Creation Date:                     09.OCT.2019
* Capsugel / Lonza RICEFW ID:        S0101
* Description:
*
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date          User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 09.OCT.2019   SRAWAT         1           D10K9A3RUB/EICR_603155:WM:US:HCDFS:MTC-NonHU SCAN 4 Dir Pick_38,39,101
*&---------------------------------------------------------------------*

    DATA: lt_batch_stock    TYPE STANDARD TABLE OF mchb,
          lt_batch_stock_wm TYPE STANDARD TABLE OF lqua,
          lt_batch_data     TYPE zsits_batch_data_tab,
          lv_tab_lines      TYPE i,
          ls_batch_key      TYPE zsits_batch_key,
          ls_order_key      TYPE zsmtd_order_sel,
          ls_order_detail   TYPE zsmtd_order_detail,
          lt_result         TYPE zstits_batch_wm_stock_tab,
          lt_so_stock       TYPE STANDARD TABLE OF mska.

    FIELD-SYMBOLS: <fs_stock_line> LIKE LINE OF lt_batch_stock,
                   <fs_batch_line> LIKE LINE OF ct_batch_data,
                   <fs_stock>      TYPE  zsits_batch_stock,
                   <fs_result>     LIKE LINE OF lt_result,
                   <fs_so_stock>   LIKE LINE OF lt_so_stock,
                   <fs_order_mvt>  TYPE zsmtd_order_mvt_data.

    CHECK ct_batch_data IS NOT INITIAL.

    DATA: ls_logon_profile  TYPE zsits_user_profile,
          lv_plant          TYPE werks_d,
          lv_warehouse      TYPE lgnum,
          lt_r_plant        TYPE kk_werks_rtab,
          ls_plant_line     LIKE LINE OF lt_r_plant,
          lt_r_warehouse    TYPE mdg_bs_mat_t_range_lgnum,
          ls_warehouse_line LIKE LINE OF lt_r_warehouse.

    IF iv_plant IS INITIAL.
* We have to pass the logon plant  to method BATCH_STOCK_READ,means the stock data
* will be only for the logon location
* 1> Assume call the scan transaction should be triggered thru ZITSELOGON scan .
* 2> For reprocess program, no logon data could be found, we have to use another approach to catch the original logon data
* 3> For programs other than ITS, no logon data could be find,the return stock is not correct.

      CALL METHOD zcl_its_utility=>get_user_profile
        RECEIVING
          rs_user_profile = ls_logon_profile.

      lv_plant     = ls_logon_profile-zzwerks.

    ELSEIF iv_plant IS NOT INITIAL.
      RETURN.
    ELSE.
      lv_plant     = iv_plant.
    ENDIF.

    IF lv_plant IS NOT INITIAL.
      ls_plant_line-sign   = 'I'.
      ls_plant_line-option = 'EQ'.
      ls_plant_line-low    = lv_plant.
      APPEND ls_plant_line TO lt_r_plant.
    ENDIF.

    SELECT * INTO TABLE lt_batch_stock
    FROM mchb
     FOR ALL ENTRIES IN ct_batch_data
       WHERE matnr   EQ ct_batch_data-matnr
       AND charg     EQ ct_batch_data-charg
       AND werks     IN lt_r_plant
       AND lvorm     EQ space.

    SORT lt_batch_stock BY matnr charg.
* remove the batch record which has zero stock

    DELETE lt_batch_stock WHERE clabs = 0    " Available
                            AND cumlm = 0    " In Transit
                            AND cinsm = 0    " Insp.
                            AND ceinm = 0    " Restricted
                            AND cspem = 0.    " Block

    IF lt_batch_stock IS INITIAL.
*Try to find the sales order stock
      SELECT * INTO TABLE lt_so_stock
        FROM mska
         FOR ALL ENTRIES IN ct_batch_data
       WHERE matnr       EQ ct_batch_data-matnr
         AND charg       EQ ct_batch_data-charg
         AND werks       IN lt_r_plant.

      IF sy-subrc EQ 0.
        DELETE lt_so_stock WHERE kalab = 0
                           AND kains = 0
                           AND kaspe = 0
                           AND kaein = 0.

        SORT lt_so_stock BY matnr charg.
        LOOP AT ct_batch_data ASSIGNING <fs_batch_line>.
          READ TABLE lt_so_stock  TRANSPORTING NO FIELDS WITH KEY matnr = <fs_batch_line>-matnr
                                                                  charg = <fs_batch_line>-charg.
          IF sy-subrc EQ 0.

            LOOP AT lt_so_stock ASSIGNING <fs_so_stock> WHERE matnr = <fs_batch_line>-matnr
                                                         AND  charg = <fs_batch_line>-charg.
              <fs_batch_line>-werks = <fs_so_stock>-werks. " Plant.
              APPEND INITIAL LINE TO <fs_batch_line>-batch_stock ASSIGNING <fs_stock>.

              MOVE: <fs_so_stock>-lgort    TO <fs_stock>-lgort,
                    <fs_so_stock>-kalab    TO <fs_stock>-clabs,
                    <fs_so_stock>-kains    TO <fs_stock>-cinsm,
                    <fs_so_stock>-kaspe    TO <fs_stock>-cspem,
                    <fs_so_stock>-kaein    TO <fs_stock>-ceinm,
                    <fs_so_stock>-vbeln    TO <fs_stock>-vbeln,
                    <fs_so_stock>-posnr    TO <fs_stock>-posnr,
                    <fs_so_stock>-sobkz    TO <fs_stock>-sobkz.

* Total Stock:
              <fs_stock>-zztotal_stock =   <fs_stock>-clabs
                                         + <fs_stock>-cumlm
                                         + <fs_stock>-cinsm
                                         + <fs_stock>-ceinm
                                         + <fs_stock>-cspem.
            ENDLOOP.
          ELSE.
            DELETE ct_batch_data.
          ENDIF.

        ENDLOOP.
      ENDIF.
    ENDIF.

    IF lt_batch_stock IS NOT INITIAL.
      LOOP AT ct_batch_data ASSIGNING <fs_batch_line>.
        READ TABLE lt_batch_stock ASSIGNING <fs_stock_line> WITH KEY matnr = <fs_batch_line>-matnr
                                                                        charg = <fs_batch_line>-charg.

        IF sy-subrc = 0.
          LOOP AT lt_batch_stock ASSIGNING <fs_stock_line> WHERE matnr = <fs_batch_line>-matnr
                                                             AND charg = <fs_batch_line>-charg.
            <fs_batch_line>-werks = <fs_stock_line>-werks. " Plant.

            APPEND INITIAL LINE TO <fs_batch_line>-batch_stock ASSIGNING <fs_stock>.

            MOVE-CORRESPONDING <fs_stock_line>  TO <fs_stock>.

* Total Stock:

            <fs_stock>-zztotal_stock =   <fs_stock>-clabs
                                        + <fs_stock>-cumlm
                                        + <fs_stock>-cinsm
                                        + <fs_stock>-ceinm
                                        + <fs_stock>-cspem.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF lt_batch_stock IS INITIAL AND lt_so_stock IS INITIAL.
* Means the all stocks of WIP batch have been issued , we should try to find out the  WIP material which has the last the issue mvt. record
      DESCRIBE TABLE ct_batch_data LINES lv_tab_lines.
      IF lv_tab_lines > 1.

        READ TABLE ct_batch_data ASSIGNING <fs_batch_line> INDEX 1.

        MOVE-CORRESPONDING <fs_batch_line> TO ls_batch_key.
* Get the process order# by batch
        CALL METHOD zcl_mtd_order_utility=>get_procord_by_batch
          EXPORTING
            is_key   = ls_batch_key
          IMPORTING
            ev_aufnr = ls_order_key-aufnr.

        ls_order_key-get_mvt    = abap_true.
        ls_order_key-get_header = abap_true.

* Get historical movement
        CALL METHOD zcl_mtd_order_utility=>order_read
          EXPORTING
            is_order_key = ls_order_key
          IMPORTING
            es_detail    = ls_order_detail.

        SORT ls_order_detail-mvt_his DESCENDING BY mjahr mblnr.

        LOOP AT ls_order_detail-mvt_his ASSIGNING <fs_order_mvt>.

          READ TABLE ct_batch_data ASSIGNING <fs_batch_line> WITH KEY matnr = <fs_order_mvt>-matnr
                                                                      charg = <fs_order_mvt>-charg.
          IF sy-subrc EQ 0.

            DELETE ct_batch_data WHERE matnr NE <fs_order_mvt>-matnr
                                    OR charg NE <fs_order_mvt>-charg.
            EXIT.

          ENDIF.

        ENDLOOP.
      ENDIF.
    ENDIF.


  ENDMETHOD.


METHOD batch_unlock.

*--Begin of  ED2K906235 08/03/2015 HEGDEA INC2783004
* Locking material at header, plant and valuation level is causing cross plant locking
* between Greenwood and Pubela for FG materials. Hence a this control is introduced to
* bring flexibility to configure it based on behaviour

  DATA:
      lv_name    TYPE rvari_vnam VALUE 'ZITS_LOCK_PARAMETERS',
      lv_type    TYPE rsscr_kind VALUE 'S',
      et_tvarvc  TYPE rseloption,
      ev_return  TYPE bapi_mtype.

  FIELD-SYMBOLS:
       <fs_tvarvc> TYPE rsdsselopt.

*--Read update control parameters
  CALL METHOD zcl_common_utility=>parameter_read
    EXPORTING
      iv_name   = lv_name
      iv_type   = lv_type
    IMPORTING
      et_tvarvc = et_tvarvc
      ev_return = ev_return.

*--Loop the parameter list
  LOOP AT et_tvarvc ASSIGNING <fs_tvarvc>.

    CASE <fs_tvarvc>-low.
      WHEN 'MARA'.
        IF iv_lock_plant = abap_true AND is_batch_key-werks IS NOT INITIAL.
*--Unlock material
          CALL FUNCTION 'DEQUEUE_EMMARAE'
            EXPORTING
              mode_mara = iv_lock_mode
              matnr     = is_batch_key-matnr
              _synchron = iv_synchron.
        ENDIF.

      WHEN 'MARC'.
        IF iv_lock_plant = abap_true AND is_batch_key-werks IS NOT INITIAL.
*--Unlock the plant material
          CALL FUNCTION 'DEQUEUE_EMMARCE'
            EXPORTING
              mode_marc = iv_lock_mode
              matnr     = is_batch_key-matnr
              werks     = is_batch_key-werks
              _synchron = iv_synchron.
        ENDIF.

      WHEN 'MBEW'.
        IF iv_lock_plant = abap_true AND is_batch_key-werks IS NOT INITIAL.
*--Unlock the material valuation table
          CALL FUNCTION 'DEQUEUE_EMMBEWE'
            EXPORTING
              mode_mbew = iv_lock_mode
              matnr     = is_batch_key-matnr
              bwkey     = is_batch_key-werks
              _synchron = iv_synchron.
        ENDIF.

      WHEN 'MCH1'.
*--Unlock the batch
        CALL FUNCTION 'DEQUEUE_EMMCH1E'
          EXPORTING
            mode_mch1 = iv_lock_mode
            matnr     = is_batch_key-matnr
            charg     = is_batch_key-charg
            _synchron = iv_synchron.
      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.


ENDMETHOD.                    "batch_lock


  METHOD batch_update.

    DATA: lv_batch   TYPE bapibatchkey-batch.
    FIELD-SYMBOLS: <ls_return> TYPE bapiret2.

    CALL FUNCTION 'BAPI_BATCH_SAVE_REPLICA'
      EXPORTING
        material            = is_batch_str-batch_key-material
        batch               = is_batch_str-batch_key-batch
        batchattributes     = is_batch_str-batch_attr
        batchattributesx    = is_batch_str-batch_attrx
        batchstatus         = is_batch_str-batch_status
        batchstatusx        = is_batch_str-batch_statusx
        batchcontrolfields  = is_batch_str-batch_ctrl
      TABLES
        classallocations    = is_batch_str-batch_cls_control[]
        classvaluationschar = is_batch_str-batch_characr_char[]
        classvaluationscurr = is_batch_str-batch_characr_curr[]
        classvaluationsnum  = is_batch_str-batch_characr_num[]
        return              = et_return.

    READ TABLE et_return ASSIGNING <ls_return> WITH KEY type  = 'E'.

    IF sy-subrc NE 0.

      CALL METHOD zcl_common_utility=>commit_work
        EXPORTING
          iv_option = iv_save_option.

    ENDIF.

  ENDMETHOD.


METHOD get_im_status.
* This method determines batch IM status by reading batch stock

  DATA: lv_dummy TYPE bapi_msg,
        lv_index TYPE i.

  FIELD-SYMBOLS: <fs_batch_stock>  LIKE LINE OF is_batch_data-batch_stock,
                 <fs_quantity>     TYPE p.

  CHECK is_batch_data IS NOT INITIAL.

  READ TABLE is_batch_data-batch_stock INDEX 1 ASSIGNING <fs_batch_stock>.
  IF sy-subrc NE 0.
    MESSAGE e075(ZITS) WITH is_batch_data-charg INTO lv_dummy.
    RETURN.
  ENDIF.

  lv_index = 2.
  DO 6 TIMES.
    ASSIGN COMPONENT lv_index OF STRUCTURE <fs_batch_stock> TO <fs_quantity>.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.
    IF <fs_quantity> GT 0.
      EXIT.
    ENDIF.
    lv_index = lv_index + 1.
  ENDDO.

* If unrestricted stock quantity is greater than 0, IM status is unrestricted
* If total rectricted stock quantity is greater than 0, IM status is restricted
* If blocked stock quantity is greater than 0, IM statis is blocked
* If one of other stock quantity is greather than 0, IM status is QI

  CASE lv_index.
    WHEN 2.
      rv_status = gc_im_status_unrestrict.
    WHEN 4.
      rv_status = gc_im_status_qi.
    WHEN 5.
      rv_status = gc_im_status_restrict.
    WHEN 6.
      rv_status = gc_im_status_block.
    WHEN 7.
      rv_status = gc_im_status_return.
    WHEN OTHERS.
      rv_status = gc_im_status_unrestrict.
  ENDCASE.

ENDMETHOD.


METHOD get_origin_batch_by_batch.
************************************************************************
************************************************************************
* Program ID:                        GET_ORIGIN_BATCH_BY_BATCH
* Created By:                        Kripa S Patil
* Creation Date:                     02.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:
*
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 02.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
  DATA: lv_original_batch TYPE zzbatch,
        lv_batch_prefix   TYPE aufnr,
        ls_batch_data     TYPE zsits_batch_data.

  CLEAR rv_original_batch.

  IF is_batch_data-zzparent_batch IS NOT INITIAL.
    lv_batch_prefix = is_batch_data-zzparent_batch.
  ELSE.
    lv_batch_prefix = is_batch_data-production_data-aufnr.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = lv_batch_prefix
      IMPORTING
        output = lv_batch_prefix.
  ENDIF.

  CONCATENATE lv_batch_prefix zcl_its_utility=>gc_oribatch_suffix_po INTO lv_original_batch.

  CONDENSE lv_original_batch.

  SHIFT lv_original_batch LEFT DELETING LEADING space.

  ls_batch_data = zcl_batch_utility=>is_origin_batch( lv_original_batch ).

  IF ls_batch_data IS NOT INITIAL.
    rv_original_batch = ls_batch_data-charg.
  ENDIF.

ENDMETHOD.


METHOD get_qi_status.

  DATA: ls_batch_key     TYPE zsits_batch_key,
        ls_insp_lot_data TYPE zsits_inspec_lot,
        ls_key           TYPE zsits_status_key,
        lt_status        TYPE zttits_status.

  FIELD-SYMBOLS: <fs_status> TYPE zsits_status.

  ls_insp_lot_data = is_batch_data-insp_lot_data.

  IF is_batch_data-insp_lot_data IS INITIAL.
* In case inspection lot data wasn't read in batch_read
    MOVE-CORRESPONDING is_batch_data TO ls_batch_key.
    CALL METHOD zcl_batch_utility=>inspec_lot_read
      EXPORTING
        is_key        = ls_batch_key
      RECEIVING
        rs_inspec_lot = ls_insp_lot_data.

  ENDIF.


  IF ls_insp_lot_data IS INITIAL.
* Batch really doesn't have inspection lot
    rs_status-txt04 = zcl_its_utility=>gc_user_status_ok.
    RETURN.
  ENDIF.

  ls_key-zzobjnr     = ls_insp_lot_data-objnr.
  ls_key-zzstsma     = ls_insp_lot_data-stsma.
  ls_key-zzonly_user = abap_true.
  ls_key-zzonly_actv = abap_true.

  CALL METHOD zcl_its_utility=>object_status_read
    EXPORTING
      is_key    = ls_key
    RECEIVING
      rt_status = lt_status.
  CHECK lt_status IS NOT INITIAL.

* Begin of update by Vicky - 20150126
  READ TABLE lt_status INTO rs_status INDEX 1.
* End of update by Vicky

ENDMETHOD.


METHOD inspec_loc_lock_process.
  DATA: lv_dummy TYPE string.

  rv_result =  abap_false.

  IF iv_unlock = abap_false.

    CALL FUNCTION 'ENQUEUE_EQQALS1'
      EXPORTING
        mode_qals      = 'E'
        mandant        = sy-mandt
        prueflos       = iv_inspec_lot_number
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              INTO lv_dummy
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

      RETURN.
    ENDIF.

  ELSE.
    CALL FUNCTION 'DEQUEUE_EQQALS1'
      EXPORTING
        mode_qals = 'E'
        mandant   = sy-mandt
        prueflos  = iv_inspec_lot_number.
  ENDIF.

  rv_result = abap_true.

ENDMETHOD.


METHOD inspec_lot_read.
************************************************************************
************************************************************************
* Program ID:                        INSPEC_LOT_READ
* Created By:                        Kripa S Patil
* Creation Date:                     02.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:
*
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 02.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
  DATA: lt_insp_lot  TYPE STANDARD TABLE OF qals,
        lwa_insp_lot TYPE                   qals.
  FIELD-SYMBOLS:<fs_insp_line> LIKE LINE OF lt_insp_lot.

  CHECK is_key IS NOT INITIAL.

*Get inspection lot data
  SELECT  prueflos
          objnr
          stsma
          charg
  INTO CORRESPONDING FIELDS OF TABLE lt_insp_lot
  FROM qals
  WHERE matnr = is_key-matnr
    AND charg = is_key-charg.

  CHECK sy-subrc EQ 0.

  LOOP AT lt_insp_lot ASSIGNING <fs_insp_line>.

* If the system status contain I0227 ,stad for this inspection lot deleted
    CALL FUNCTION 'QAST_STATUS_CHECK'
      EXPORTING
        i_objnr          = <fs_insp_line>-objnr
        i_status         = gc_insp_lot_deleted              " I0227
      EXCEPTIONS
        status_not_activ = 01.

    IF sy-subrc EQ 0.
      DELETE lt_insp_lot.
    ENDIF.

  ENDLOOP.

* Assume alwasy only one active inspection lot available.
  SORT lt_insp_lot BY prueflos DESCENDING.

  READ TABLE lt_insp_lot INDEX 1 INTO lwa_insp_lot.
  MOVE-CORRESPONDING lwa_insp_lot TO rs_inspec_lot.

ENDMETHOD.


METHOD is_batch_on_pallet.

  DATA: ls_batch_char_key TYPE zsotc_batch,
        ls_batch_charact  TYPE zsotc_classification.

  FIELD-SYMBOLS: <fs_charact_value> LIKE LINE OF ls_batch_charact-valueschar.

  CLEAR rv_hu_id.

  IF is_batch_data-batch_charact IS INITIAL.

    MOVE-CORRESPONDING is_batch_data TO ls_batch_char_key.

    CALL METHOD zcl_common_utility=>batch_char_read
      EXPORTING
        is_batch          = ls_batch_char_key
      IMPORTING
        es_classification = ls_batch_charact.

  ELSE.

    ls_batch_charact = is_batch_data-batch_charact.

  ENDIF.

  READ TABLE ls_batch_charact-valueschar ASSIGNING <fs_charact_value> WITH KEY charact = zcl_common_utility=>gc_chara_palletid.
  IF sy-subrc EQ 0.

    IF <fs_charact_value>-value_char IS NOT INITIAL.
      rv_hu_id = <fs_charact_value>-value_char.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = rv_hu_id
        IMPORTING
          output = rv_hu_id.
    ENDIF.

  ENDIF.
ENDMETHOD.


METHOD is_fg_batch.
************************************************************************
************************************************************************
* Program ID:                        IS_FG_BATCH
* Created By:                        Kripa S Patil
* Creation Date:                     03.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:
*
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 03.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
  DATA: lv_dummy         TYPE string,
        lv_matnr         TYPE matnr,
        lv_mtart         TYPE mtart,
        lt_allowed_mtart TYPE zttits_mtart_tab,
        ls_mch1_data     TYPE mch1,
        ls_read_option   TYPE zsits_batch_read_option,
        lv_order_num     TYPE aufnr,
        ls_order_key     TYPE zsmtd_order_sel,
        ls_order_data    TYPE zsmtd_order_detail,
        ls_batch_key     TYPE zsits_batch_key.

  MOVE is_read_option TO ls_read_option.

  ls_read_option-zzprod_order_read = abap_true. " For FG batch, we have to get the order info obligatory

  CLEAR rs_batch_data.

  IF iv_unexist_check = abap_false.
*------------------------------------------------------------------------------------------
*                  Assume the Batch should exist
*------------------------------------------------------------------------------------------

* 1>  Read Batch data ( including legacy batch conversion)
*---------------------------------------------------------------------------------
    CALL METHOD batch_read
      EXPORTING
        iv_batch            = iv_batch
        is_read_option      = is_read_option
        iv_logon_plant      = iv_logon_plant
        iv_logon_warehouse  = iv_logon_warehouse
      RECEIVING
        rs_batch_data  = rs_batch_data.

* Rs_batch _data is initial means error occurs in above method-call.
    CHECK rs_batch_data IS NOT INITIAL.

* 2> Check material type
*---------------------------------------------------------------------------------

    CALL FUNCTION 'ZITS_ALLOWED_MTART_GET'
      IMPORTING
        et_allowed_mtart = lt_allowed_mtart.

* Only keep the material type belong s to FG
    DELETE lt_allowed_mtart WHERE zzcap_mattype NE zcl_its_utility=>gc_matcat_fg.  " = F

    READ TABLE lt_allowed_mtart TRANSPORTING NO FIELDS WITH KEY mtart = rs_batch_data-mtart.
    IF sy-subrc NE 0.
*Finish goods:&1/&2 is not allowed to this T-code
      MESSAGE e106(zits) WITH rs_batch_data-matnr iv_batch INTO lv_dummy.

      CLEAR rs_batch_data.
      RETURN.

    ELSE.
      rs_batch_data-zzbatch_type = gc_batch_type_fg.  " Finishs Goods Batch
    ENDIF.

* 3> Get Parent batch
*------------------------------------------------------------------------------------------
    rs_batch_data-zzparent_batch =  rs_batch_data-licha. " Assume the vendor batch contain the parent batch

    IF iv_vendor_batch_check EQ abap_true
      AND iv_skip_or_batch_check = abap_false.
*   zwcl special receiving batch for E0217 does not need to have vendor batch maintained

      IF rs_batch_data-licha IS INITIAL.
* Vendor batch not maintained for material/batch
        CLEAR rs_batch_data.
        RETURN.
      ENDIF.

    ENDIF.

* 4 Check the logon location is whether match with the scanned object
*------------------------------------------------------------------------------------------
    IF zcl_its_utility=>is_location_match( is_batch_data  = rs_batch_data ) = abap_false.

      CLEAR rs_batch_data.
      RETURN.

    ENDIF.

  ELSE.
*------------------------------------------------------------------------------------------
*                       Assume the batch should not exist
*------------------------------------------------------------------------------------------
    SELECT * INTO ls_mch1_data UP TO 1 ROWS
      FROM mch1
     WHERE charg EQ iv_batch+0(10).
    ENDSELECT.
    IF sy-subrc EQ 0.
*   FG Batch &1 already exists.
      MESSAGE e206(zits) WITH iv_batch INTO lv_dummy.
      RETURN.
    ENDIF.

    IF batch_format_check( iv_batch  = iv_batch iv_batch_category = gc_batch_type_fg ) = abap_false.
* If batch format check failure, means not a qualified WIP batch, err msg should be raised from order_read
      CLEAR rs_batch_data.
      RETURN.
    ENDIF.

    ls_batch_key-charg = iv_batch+0(10).
* Get the process/product# base on the importing batch#
*------------------------------------------------------------------------------------------
    CALL METHOD zcl_mtd_order_utility=>get_procord_by_batch
      EXPORTING
        is_key   = ls_batch_key
      IMPORTING
        ev_aufnr = lv_order_num.

    ls_order_key-aufnr      = lv_order_num.

    CALL METHOD zcl_mtd_order_utility=>order_read
      EXPORTING
        is_order_key = ls_order_key
      IMPORTING
        es_detail    = ls_order_data.

    IF ls_order_data-header_line IS NOT INITIAL.
* For an unexist FG , the associated production order should exist anyway
      MOVE: ls_order_data-header_line-order_number     TO rs_batch_data-production_data-aufnr,
            ls_order_data-header_line-order_type       TO rs_batch_data-production_data-auart,
            ls_order_data-header_line-sales_order      TO rs_batch_data-production_data-kdauf,
            ls_order_data-header_line-sales_order_item TO rs_batch_data-production_data-kdpos,
            ls_order_data-header_line-material         TO rs_batch_data-production_data-matnr.
* Get the order category
      SELECT SINGLE autyp INTO rs_batch_data-production_data-autyp
        FROM aufk
       WHERE aufnr = rs_batch_data-production_data-aufnr.
    ELSE.
* If order not exits, means not a qualified WIP batch, err msg should be raised from order_read
      CLEAR rs_batch_data.
      RETURN.
    ENDIF.

*-to check if the FG material the user is trying to produce belongs to a allowed material type
    CALL FUNCTION 'ZITS_ALLOWED_MTART_GET'
      IMPORTING
        et_allowed_mtart = lt_allowed_mtart.

* Only keep the material type belong s to FG
    DELETE lt_allowed_mtart WHERE zzcap_mattype NE zcl_its_utility=>gc_matcat_fg.  " = F
    SELECT SINGLE mtart FROM mara INTO lv_mtart WHERE matnr = ls_order_data-header_line-material.
    IF sy-subrc = 0.
      READ TABLE lt_allowed_mtart TRANSPORTING NO FIELDS WITH KEY mtart = lv_mtart.
      IF sy-subrc NE 0.
*Finish goods:&1/&2 is not allowed to this T-code
        MESSAGE e106(zits) WITH ls_order_data-header_line-material iv_batch INTO lv_dummy.

        CLEAR rs_batch_data.
        RETURN.
      ENDIF.
    ENDIF.



    rs_batch_data-charg        = iv_batch+0(10).
    rs_batch_data-zzbatch_type = gc_batch_type_fg.
* Parent Batch

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = lv_order_num
      IMPORTING
        output = lv_order_num.

    rs_batch_data-zzparent_batch =  lv_order_num. " Assume the vendor batch contain the parent batch

  ENDIF.

  CHECK rs_batch_data IS NOT INITIAL.

  IF  iv_skip_or_batch_check = abap_false.
* Only ZWCL produced batch (E0217) does not need to check process order #
    rs_batch_data-zzoriginal_batch = zcl_batch_utility=>get_origin_batch_by_batch( rs_batch_data ).

    IF rs_batch_data-zzoriginal_batch IS INITIAL.
* No all RF programs require the original batch check, we will check the calling RF transaction is
* whether relevant with such check or not, we will do nothing the calling programs's tcode does not
* exist in the pre-congigured ITS varible table.
      IF zcl_its_utility=>is_orbatch_check_required( sy-tcode ) = abap_true.
* If original batch could not be determined out, should return error msg from above method-call
        CLEAR rs_batch_data.
      ENDIF.
    ENDIF.

  ELSE.
* For ZWCL order
    rs_batch_data-zzwcl_order = abap_true.
  ENDIF.



ENDMETHOD.


METHOD is_origin_batch.
************************************************************************
************************************************************************
* Program ID:                        IS_ORIGIN_BATCH
* Created By:                        Kripa S Patil
* Creation Date:                     02.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:
*
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 02.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
  DATA: lv_dummy       TYPE string,
        lv_result      TYPE boolean.

* 1>  Read Batch data ( original batch does not need legacy batch conversion)

  CALL METHOD batch_read
    EXPORTING
      iv_batch      = iv_batch
    RECEIVING
      rs_batch_data = es_batch_data.

* Rs_batch _data is initial means error occurs in above method-call.
  CHECK es_batch_data IS NOT INITIAL.

* 2> Check if it is original batch
  CALL FUNCTION 'BATCH_IS_ORIGINAL_BATCH'
    EXPORTING
      i_matnr                 = es_batch_data-matnr
      i_werks                 = es_batch_data-werks
      i_charg                 = es_batch_data-charg
    IMPORTING
      batch_is_original_batch = lv_result
    EXCEPTIONS
      no_plant                = 1
      OTHERS                  = 2.

  IF lv_result <> abap_true.
*Batch &1 is not original batch !

    MESSAGE e046(ZITS) WITH iv_batch INTO lv_dummy.

    CLEAR es_batch_data.

    RETURN.

  ELSE.

    es_batch_data-zzbatch_type = gc_batch_type_origin.  " Original Batch

  ENDIF.
ENDMETHOD.


METHOD is_rw_batch.
************************************************************************
************************************************************************
* Program ID:                        IS_RW_BATCH
* Created By:                        Kripa S Patil
* Creation Date:                     02.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:
*
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 02.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
  DATA: lv_dummy          TYPE bapi_msg,
        ls_mch1_data      TYPE mch1,
        lv_number_len     TYPE i,
        lt_allowed_mtart  TYPE zttits_mtart_tab,
        lv_original_batch TYPE zzbatch,
        ls_read_option    TYPE zsits_batch_read_option,
        lt_r_matnr        TYPE range_t_matnr,
        ls_matnr_line     LIKE LINE OF lt_r_matnr.


  MOVE is_read_option TO ls_read_option.

  CLEAR rs_batch_data.

  IF iv_unexist_check = abap_false.

* 1>  Read Batch data ( including legacy batch conversion)
*------------------------------------------------------------------------------------------
    CALL METHOD batch_read
      EXPORTING
        iv_batch           = iv_batch
        is_read_option     = is_read_option
        iv_logon_plant     = iv_logon_plant
        iv_logon_warehouse =  iv_logon_warehouse
      RECEIVING
        rs_batch_data      = rs_batch_data.

    IF rs_batch_data IS INITIAL .
* It's not a RW batch
      IF sy-msgid = 'ZITS' AND sy-msgno = '015'.  " Except ZITS-015, other error messages could be extracted from batch_read
        MESSAGE e107(zits) WITH iv_batch INTO lv_dummy.
      ENDIF.

      RETURN.

    ELSE.

*For RM batches, vendor batch field may or may not exist. We need to check the label content after indicator "10" instead
        rs_batch_data-zzoriginal_batch = iv_parent_batch.
        lv_original_batch              = iv_parent_batch.

        IF iv_parent_batch = iv_batch.
           rs_batch_data-zzzero_batch_ind = abap_true.  " For the parent batch of RM, it always exist and the sublot in lable is ZERO but will be ignored while readinng from DB
        ENDIF.
    ENDIF.
  ELSE.
*------------------------------------------------------------------------------------------
*                       Assume the batch should not exist
*------------------------------------------------------------------------------------------

    IF iv_matnr IS NOT INITIAL.

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          input  = iv_matnr
        IMPORTING
          output = rs_batch_data-matnr.

      SELECT SINGLE mtart meins INTO (rs_batch_data-mtart,rs_batch_data-meins) FROM mara WHERE matnr = rs_batch_data-matnr.

      IF sy-subrc NE 0.
        MESSAGE e305(m3) WITH iv_matnr INTO lv_dummy.
        RETURN.
      ENDIF.

      ls_matnr_line-sign   = 'I'.
      ls_matnr_line-option = 'EQ'.
      ls_matnr_line-low    = iv_matnr.
      APPEND ls_matnr_line TO lt_r_matnr.
    ENDIF.

    SELECT * INTO ls_mch1_data UP TO 1 ROWS
      FROM mch1
     WHERE matnr IN lt_r_matnr
       AND charg EQ iv_batch+0(10).
    ENDSELECT.
    IF sy-subrc EQ 0.
*   RW Batch &1 already exists.
      CLEAR: rs_batch_data.
      MESSAGE e244(zits) WITH iv_batch INTO lv_dummy.
      RETURN.
    ENDIF.

    IF batch_format_check( iv_batch  = iv_batch iv_batch_category = gc_batch_type_rm ) = abap_false.
* If batch format check failure, means not a qualified WIP batch, err msg should be raised from order_read
      CLEAR rs_batch_data.
      RETURN.
    ENDIF.

    rs_batch_data-charg =  iv_batch+0(10).

*  Try to get the original batch

    lv_number_len = strlen( iv_batch ).

    IF lv_number_len > 3.
      lv_number_len = lv_number_len - 3.

      lv_original_batch = iv_parent_batch.
    ENDIF.

  ENDIF.

* 2> Check the original batch whether exist in SAP or not
*------------------------------------------------------------------------------------------
  IF iv_batch NE iv_parent_batch. "If the user scans a container batch rather than a parent batch
    SELECT SINGLE charg INTO rs_batch_data-zzoriginal_batch FROM mch1 WHERE matnr = rs_batch_data-matnr
                                                                        AND charg = lv_original_batch .
    IF sy-subrc NE 0.
* Original batch doesn't exist
      MESSAGE e224(zits) WITH lv_original_batch  INTO lv_dummy.
      CLEAR rs_batch_data.
      RETURN.
    ENDIF.
  ENDIF.
* 3> Check material type
*------------------------------------------------------------------------------------------

  CALL FUNCTION 'ZITS_ALLOWED_MTART_GET'
    IMPORTING
      et_allowed_mtart = lt_allowed_mtart.

* Only keep the material type belong s to intermedia/WIP
  DELETE lt_allowed_mtart WHERE zzcap_mattype  NE zcl_its_utility=>gc_matcat_row_mat.  " = R

  READ TABLE lt_allowed_mtart TRANSPORTING NO FIELDS WITH KEY mtart = rs_batch_data-mtart.
  IF sy-subrc NE 0.
*Row Material:&1/&2 is not allowed to this T-code
    MESSAGE e105(zits) WITH rs_batch_data-matnr iv_batch INTO lv_dummy.

    CLEAR rs_batch_data.

  ELSE.

    rs_batch_data-zzbatch_type = gc_batch_type_rm. " Row material batch

  ENDIF.

ENDMETHOD.


METHOD is_sample_batch.
************************************************************************
************************************************************************
* Program ID:                        IS_SAMPLE_BATCH
* Created By:                        Kripa S Patil
* Creation Date:                     02.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:
*
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 02.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
  DATA: lv_dummy TYPE string.

  CLEAR rs_batch_data.
* 1>  Read Batch data ( including legacy batch conversion)

  CALL METHOD batch_read
    EXPORTING
      iv_batch      = iv_batch
    RECEIVING
      rs_batch_data = rs_batch_data.

  IF rs_batch_data IS INITIAL.
* For sample batch. might not exist in SAP at all, we should check the format whether corret or not if not exist
    IF batch_format_check( iv_batch = iv_batch iv_batch_category = gc_batch_type_sample ) = abap_false.
* iv_batch is not a sample batch
      CLEAR rs_batch_data.
      RETURN.
    ELSE.
* Get Parent/Original batch
*------------------------------------------------------
      rs_batch_data-charg            = iv_batch.
      rs_batch_data-zzparent_batch   = iv_batch+0(7).
      rs_batch_data-licha            = iv_batch+0(7).
      rs_batch_data-zzoriginal_batch = zcl_batch_utility=>get_origin_batch_by_batch( rs_batch_data ).

      rs_batch_data-zzbatch_type = gc_batch_type_sample. " Sample batch

    ENDIF.

  ELSE.
* 2>  Check sample batch identifier

*---It is the same as the WIP batch indicator
    IF rs_batch_data-charg+7(1) CN gc_sample_identifier.

      CLEAR rs_batch_data.
* iv_batch is not a sample batch

      MESSAGE e013(ZITS) WITH iv_batch INTO lv_dummy.

    ELSE.
* Get Parent/Original batch
*------------------------------------------------------
      rs_batch_data-zzparent_batch   = rs_batch_data-licha. " Assume the vendor batch contain the parent batch
      rs_batch_data-zzoriginal_batch = zcl_batch_utility=>get_origin_batch_by_batch( rs_batch_data ).

      rs_batch_data-zzbatch_type = gc_batch_type_sample. " Sample batch

    ENDIF.

    IF rs_batch_data-zzoriginal_batch IS INITIAL.
* If original batch could not be determined out, should return error msg from above method-call
      CLEAR rs_batch_data.
    ENDIF.
  ENDIF.
ENDMETHOD.


METHOD is_wip_batch.
************************************************************************
************************************************************************
* Program ID:                        IS_WIP_BATCH
* Created By:                        Kripa S Patil
* Creation Date:                     02.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:
*
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 02.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
  DATA: lv_dummy         TYPE bapi_msg,
        ls_mch1_data     TYPE mch1,
        lt_allowed_mtart TYPE zttits_mtart_tab,
        ls_batch_key     TYPE zsits_batch_key,
        lv_order_num     TYPE aufnr,
        ls_order_key     TYPE zsmtd_order_sel,
        ls_order_data    TYPE zsmtd_order_detail,
        ls_read_option   TYPE zsits_batch_read_option.

  IF iv_unexist_check = abap_false.
*------------------------------------------------------------------------------------------
*                  Assume the Batch should exist
*------------------------------------------------------------------------------------------
    MOVE is_read_option TO ls_read_option.

    ls_read_option-zzprod_order_read = abap_true. " For WIP batch, we have to get the order info obligatory

    ls_read_option-zzstock_read = abap_true.

    CLEAR rs_batch_data.

* 1>  Read Batch data ( including legacy batch conversion)
*------------------------------------------------------------------------------------------
    CALL METHOD batch_read
      EXPORTING
        iv_batch           = iv_batch
        is_read_option     = ls_read_option
        iv_logon_plant     = iv_logon_plant     " ED2K906454
        iv_logon_warehouse = iv_logon_warehouse " ED2K906454
      RECEIVING
        rs_batch_data  = rs_batch_data.

    IF rs_batch_data IS INITIAL.

      IF sy-msgid = 'ZITS' AND sy-msgno = '015'.  " Except ZITS-015, other error messages could be extracted from batch_read
* It's not a WIP batch
        MESSAGE e016(zits) WITH iv_batch INTO lv_dummy.
      ENDIF.

      RETURN.

    ENDIF.

* 2> Check material type
*------------------------------------------------------------------------------------------
    CALL FUNCTION 'ZITS_ALLOWED_MTART_GET'
      IMPORTING
        et_allowed_mtart = lt_allowed_mtart.

* Only keep the material type belong s to intermedia/WIP
* Add FG because FG will be issue to a process order as a WIP batch
    DELETE lt_allowed_mtart WHERE zzcap_mattype NE zcl_its_utility=>gc_matcat_wip  " = I
                              AND zzcap_mattype NE zcl_its_utility=>gc_matcat_fg . " = F

    READ TABLE lt_allowed_mtart TRANSPORTING NO FIELDS WITH KEY mtart = rs_batch_data-mtart.
    IF sy-subrc NE 0.
*WIP:&1/&2 is not allowed to this T-code
      MESSAGE e104(zits) WITH rs_batch_data-matnr iv_batch INTO lv_dummy.

      CLEAR rs_batch_data.

      RETURN.

    ENDIF.
* Because WIP batch might contain FG material, we need add format check here .
    IF batch_format_check( iv_batch  = iv_batch iv_batch_category = gc_batch_type_wip ) = abap_false.
* If batch format check failure, means not a qualified WIP batch, err msg should be raised from order_read
      CLEAR rs_batch_data.
      RETURN.
    ENDIF.

* 3> Get Parent batch
*------------------------------------------------------------------------------------------
    rs_batch_data-zzparent_batch =  rs_batch_data-licha. " Assume the vendor batch contain the parent batch

    IF iv_vendor_batch_check = abap_true.

      IF rs_batch_data-licha IS INITIAL.
* Vendor batch not maintained for material/batch
*        MESSAGE e331 INTO lv_dummy WITH rs_batch_data-matnr rs_batch_data-charg.
        CLEAR rs_batch_data.
        RETURN.
      ENDIF.

    ENDIF.

    rs_batch_data-zzbatch_type = gc_batch_type_wip.

* 4 Check the logon location is whether match with the scanned object
*------------------------------------------------------------------------------------------
    IF zcl_its_utility=>is_location_match( is_batch_data  = rs_batch_data ) = abap_false.

       CLEAR rs_batch_data.
       RETURN.

    ENDIF.

  ELSE.
*------------------------------------------------------------------------------------------
*                       Assume the batch should not exist
*------------------------------------------------------------------------------------------
    SELECT * INTO ls_mch1_data UP TO 1 ROWS
      FROM mch1
     WHERE charg EQ iv_batch+0(10).
    ENDSELECT.
    IF sy-subrc EQ 0.
*   WIP Batch &1 already exists.
      MESSAGE e194(zits) WITH iv_batch INTO lv_dummy.
      RETURN.
    ENDIF.

    IF batch_format_check( iv_batch  = iv_batch iv_batch_category = gc_batch_type_wip ) = abap_false.
* If batch format check failure, means not a qualified WIP batch, err msg should be raised from order_read
      CLEAR rs_batch_data.
      RETURN.
    ENDIF.

    rs_batch_data-charg        = iv_batch+0(10).
    rs_batch_data-zzbatch_type = gc_batch_type_wip." WIP Batch

* Parent Batch

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = lv_order_num
      IMPORTING
        output = lv_order_num.

    rs_batch_data-zzparent_batch =  lv_order_num. " Assume the vendor batch contain the parent batch

  ENDIF.

  ls_batch_key-charg = iv_batch+0(10).

  ls_batch_key-matnr = rs_batch_data-matnr.

* Get the process/product# base on the importing batch#
*------------------------------------------------------------------------------------------
  CALL METHOD zcl_mtd_order_utility=>get_procord_by_batch
    EXPORTING
      is_key   = ls_batch_key
    IMPORTING
      ev_aufnr = lv_order_num.

  ls_order_key-aufnr      = lv_order_num.

  CALL METHOD zcl_mtd_order_utility=>order_read
    EXPORTING
      is_order_key = ls_order_key
    IMPORTING
      es_detail    = ls_order_data.

  IF ls_order_data-header_line IS NOT INITIAL.
* For an unexist WIP , the associated production order should exist anyway
    MOVE: ls_order_data-header_line-order_number     TO rs_batch_data-production_data-aufnr,
          ls_order_data-header_line-order_type       TO rs_batch_data-production_data-auart,
          ls_order_data-header_line-sales_order      TO rs_batch_data-production_data-kdauf,
          ls_order_data-header_line-sales_order_item TO rs_batch_data-production_data-kdpos,
          ls_order_data-header_line-material         TO rs_batch_data-production_data-matnr.

* Get the order category
    SELECT SINGLE autyp INTO rs_batch_data-production_data-autyp
      FROM aufk
     WHERE aufnr = rs_batch_data-production_data-aufnr.
  ELSE.
* If order not exits, means not a qualified WIP batch, err msg should be raised from order_read
    CLEAR rs_batch_data.
    RETURN.
  ENDIF.

  CHECK rs_batch_data IS NOT INITIAL.

  rs_batch_data-zzoriginal_batch = zcl_batch_utility=>get_origin_batch_by_batch( rs_batch_data ).

  IF rs_batch_data-zzoriginal_batch IS INITIAL.
* No all RF programs require the original batch check, we will check the calling RF transaction is
* whether relevant with such check or not, we will do nothing the calling programs's tcode does not
* exist in the pre-congigured ITS varible table.
    IF zcl_its_utility=>is_orbatch_check_required( sy-tcode ) = abap_true.
* If original batch could not be determined out, should return error msg from above method-call
      CLEAR rs_batch_data.
      RETURN.
    ENDIF.
  ENDIF.


ENDMETHOD.


  method IS_ZERO_BATCH.

DATA: lv_dummy TYPE bapi_msg.

  IF is_batch_data-zzzero_batch_ind = abap_true.
* Zero batch is not allowed
    MESSAGE e379(zits) with is_batch_data-charg INTO lv_dummy.

    rv_result = abap_true.

  ENDIF.

  endmethod.
ENDCLASS.
