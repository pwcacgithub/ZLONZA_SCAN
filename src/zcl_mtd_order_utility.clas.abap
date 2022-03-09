class ZCL_MTD_ORDER_UTILITY definition
  public
  final
  create public .

public section.

  constants GC_DBT_INDICATOR type SHKZG value 'H' ##NO_TEXT.

  class-methods IS_ORDER_RELEASED
    importing
      !IV_AUFNR type AUFNR
    returning
      value(RV_RESULT) type BOOLEAN .
  class-methods GET_PROCORD_BY_BATCH
    importing
      !IS_KEY type ZSITS_BATCH_KEY
    exporting
      !EV_AUFNR type AUFNR .
  class-methods ORDER_READ
    importing
      !IS_ORDER_KEY type ZSMTD_ORDER_SEL
      !IV_READ_DB type XFELD default ABAP_FALSE
    exporting
      !ES_DETAIL type ZSMTD_ORDER_DETAIL .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MTD_ORDER_UTILITY IMPLEMENTATION.


METHOD get_procord_by_batch.
************************************************************************
************************************************************************
* Program ID:                        GET_PROCORD_BY_BATCH
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
  DATA: lv_dummy_order  TYPE char12,
        lv_len          TYPE i,
        lv_dummy        TYPE string.

  CHECK is_key-charg IS NOT INITIAL.

  SELECT SINGLE licha INTO lv_dummy_order FROM mch1 WHERE matnr = is_key-matnr AND charg = is_key-charg.
  IF sy-subrc NE 0 OR lv_dummy_order IS INITIAL.
    lv_len = strlen( is_key-charg ).

    IF lv_len LE 3.
      RETURN.
    ENDIF.
* try to truncate the last 3 digit of batch
    lv_len = lv_len - 3.

    lv_dummy_order = is_key-charg+0(lv_len).

  ENDIF.

  CHECK lv_dummy_order IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lv_dummy_order
    IMPORTING
      output = lv_dummy_order.

  SELECT SINGLE aufnr INTO ev_aufnr FROM afko WHERE aufnr = lv_dummy_order.
  IF sy-subrc NE 0.
* Order does not exist
    MESSAGE e017(co) WITH lv_dummy_order INTO lv_dummy.
    RETURN.
  ENDIF.

ENDMETHOD.


  method IS_ORDER_RELEASED.

    DATA: ls_key    TYPE zsits_status_key,
        lt_status TYPE zttits_status,
        lv_aufnr  TYPE aufnr,
        lv_dummy  TYPE bapi_msg.

  FIELD-SYMBOLS: <fs_status> TYPE zsits_status.

  CHECK iv_aufnr IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = iv_aufnr
    IMPORTING
      output = lv_aufnr.

*Get object number for the process order
  SELECT SINGLE objnr
  FROM aufk
  INTO ls_key-zzobjnr
  WHERE aufnr = lv_aufnr.

  IF sy-subrc = 0.

*Get the active system status
    ls_key-zzonly_syst = 'X'.

    CALL METHOD zcl_its_utility=>object_status_read
      EXPORTING
        is_key    = ls_key
      RECEIVING
        rt_status = lt_status.

    READ TABLE lt_status ASSIGNING <fs_status> WITH KEY txt04 = 'REL'.
    IF sy-subrc <> 0.

      MESSAGE e017(zits) WITH iv_aufnr INTO lv_dummy.
      RETURN.

    ENDIF.

    rv_result = abap_true.
  ELSE.
* Order & not found
    MESSAGE e047(zits) INTO lv_dummy.

  ENDIF.
  endmethod.


METHOD order_read.
************************************************************************
************************************************************************
* Program ID:
* Created By:                        Kripa S Patil
* Creation Date:                     02.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:                      This method reads detail data of
*                                    production order or process order
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 02.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
* This method reads detail data of production order or process order

  DATA: lv_aufnr                TYPE aufnr,
        lwa_proc_order_objects  TYPE bapi_pi_order_objects,
        lwa_prod_order_objects  TYPE bapi_pp_order_objects,
        lwa_return              TYPE bapiret2,
        ls_bapi_header          TYPE bapi_order_header1,
        ls_mvt_his              TYPE LINE OF zttmtd_order_mvt_data,
        lv_line                 TYPE i,
        lv_dummy                TYPE bapi_msg.

  CHECK is_order_key IS NOT INITIAL.

* Check the existence of the order

  CLEAR es_detail.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = is_order_key-aufnr
    IMPORTING
      output = lv_aufnr.

  IF iv_read_db = abap_false. " If iv_read_db = 'X' means we should ignore the buffer but to read from DB
* Try to get data from buffer
    CALL FUNCTION 'ZITS_GET_ORDER_DATA_BUFFER'
      EXPORTING
        iv_order_num  = lv_aufnr
      IMPORTING
        es_order_data = es_detail.
  ENDIF.

* If we could get data from buffer, no need to read order data again
  CHECK es_detail IS  INITIAL.

* Get order category
  SELECT SINGLE autyp
    FROM aufk
    INTO es_detail-header_line-autyp
    WHERE aufnr = lv_aufnr.

  IF sy-subrc NE 0.
* Order does not exist
    MESSAGE e017(co) WITH is_order_key-aufnr INTO lv_dummy.
    RETURN.
  ENDIF.

  IF es_detail-header_line-autyp = zcl_common_utility=>gc_auftyp_prodord.
* Order category is 10, production order

* Get production order detail
    lwa_prod_order_objects-header     = abap_true.   "is_order_key-get_header. we should get header info in any case
    lwa_prod_order_objects-positions  = abap_true.
    lwa_prod_order_objects-sequences  = abap_true.
    lwa_prod_order_objects-operations = abap_true.
    lwa_prod_order_objects-components = abap_true.

    CALL FUNCTION 'BAPI_PRODORD_GET_DETAIL'
      EXPORTING
        number        = lv_aufnr
        order_objects = lwa_prod_order_objects
      IMPORTING
        return        = lwa_return
      TABLES
        header        = es_detail-header
        position      = es_detail-item
        sequence      = es_detail-sequence
        operation     = es_detail-operation
        component     = es_detail-component.


  ELSEIF es_detail-header_line-autyp = zcl_common_utility=>gc_auftyp_procord.
* Order category is 40, process order

* Get process order detail
    lwa_proc_order_objects-header     = abap_true.   "is_order_key-get_header. we should get header info in any case
    lwa_proc_order_objects-positions  = abap_true.
    lwa_proc_order_objects-sequences  = abap_true.
    lwa_proc_order_objects-phases     = abap_true.
    lwa_proc_order_objects-components = abap_true.

    CALL FUNCTION 'BAPI_PROCORD_GET_DETAIL'
      EXPORTING
        number        = lv_aufnr
        order_objects = lwa_proc_order_objects
      IMPORTING
        return        = lwa_return
      TABLES
        header        = es_detail-header
        position      = es_detail-item
        sequence      = es_detail-sequence
        phase         = es_detail-phase
        component     = es_detail-component.

  ELSE.
* If order is neither production order nor process order,
* this method cannot read order detail
    MESSAGE e196(zits) WITH lv_aufnr INTO lv_dummy.
    RETURN.

  ENDIF.

  IF lwa_return-type = 'E'.

    MESSAGE ID         lwa_return-id
            TYPE       lwa_return-type
            NUMBER     lwa_return-number
            INTO       lv_dummy
            WITH       lwa_return-message_v1
                       lwa_return-message_v2
                       lwa_return-message_v3
                       lwa_return-message_v4.

  ELSE.

* Read header table into header line
    READ TABLE es_detail-header INTO ls_bapi_header
    WITH KEY order_number = lv_aufnr.
    CHECK sy-subrc = 0.

    MOVE-CORRESPONDING ls_bapi_header TO es_detail-header_line.

    es_detail-zzvalid = abap_true.

* Get order movement history ( GI and GR )
    SELECT a~mblnr
           a~mjahr
           a~zeile
           a~bldat
           a~budat
           a~bwart
           a~matnr
           c~mtart
           a~werks
           a~lgort
           a~charg
           a~sobkz
           a~shkzg
           a~menge
           a~meins
           a~rsnum
           a~rspos
           a~rsart
           b~bktxt
           b~cputm
           b~usnam
   INTO CORRESPONDING FIELDS OF TABLE es_detail-mvt_his
   FROM aufm AS a INNER JOIN mkpf AS b
     ON ( a~mblnr EQ b~mblnr
    AND a~mjahr EQ b~mjahr )
   INNER JOIN mara AS c
    ON a~matnr  EQ c~matnr
   WHERE a~aufnr = lv_aufnr.

    IF sy-subrc = 0.
      SORT   es_detail-mvt_his BY mblnr DESCENDING mjahr zeile."Sort decending by material doc # so we can get the latest GR doc
    ENDIF.

    LOOP AT es_detail-mvt_his INTO ls_mvt_his.
      lv_line = lv_line + 1.
      IF ls_mvt_his-shkzg = zcl_mtd_order_utility=>gc_dbt_indicator.
        ls_mvt_his-menge = ls_mvt_his-menge * ( -1 ).
        MODIFY es_detail-mvt_his FROM ls_mvt_his INDEX lv_line.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Save the data into buffer
  CALL FUNCTION 'ZITS_SET_ORDER_DATA_BUFFER'
    EXPORTING
      is_order_data = es_detail.

ENDMETHOD.
ENDCLASS.
