class ZCL_MDE_BARCODE definition
  public
  final
  create public .

public section.

  types TS_AI type ZMDE_S_AI_DETAIL .

  class-methods DISOLVE_BARCODE
    importing
      !IV_BARCODE type DATA
      !IV_WERKS type WERKS_D
      !IS_READ_OPTION type ZSITS_BATCH_READ_OPTION optional
      !IV_EXIST_CHECK type XFELD default ABAP_TRUE
      !IT_LABEL_TYPE_RANGE type ZTLABEL_TYPE_RANGE optional
      !IV_READ_10_ONLY type BOOLEAN default ABAP_FALSE
      !IV_SKIP_OR_BCH_CHECK type XFELD default ABAP_FALSE
    exporting
      !EV_MATNR type DATA
      !EV_CHARG type DATA
      !EV_FAUF type DATA
      !EV_MENGE type DATA
      !EV_FEHLER type DATA
      !EV_SHIPCODE type DATA
      !ET_DATA type STANDARD TABLE
      !EV_LABEL_TYPE type ZDITS_LABEL_TYPE
      !ES_LABEL_CONTENT type ZSITS_LABEL_CONTENT
      !ES_MATERIAL_DATA type ZSITS_MATERIAL_DATA_DFS .
  class-methods PARTITION_BARCODE
    importing
      !IV_BARCODE type DATA
      !IV_STRLEN type DATA
      !IS_T313G type DATA
    exporting
      !ET_AI type STANDARD TABLE
      !EV_FEHLER type DATA .
  class-methods FILL_FIELDS
    importing
      !IV_AIVAL type DATA
      !IV_AILEN type DATA
      !IV_AINKL type DATA
      !IV_DATA type DATA
    exporting
      !EV_MATNR type DATA
      !EV_CHARG type DATA
      !EV_FAUF type DATA
      !EV_MENGE type DATA
      !EV_SHIPCODE type DATA .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MDE_BARCODE IMPLEMENTATION.


METHOD disolve_barcode.

  DATA: lv_barcode       TYPE char200,
        lv_strlen        TYPE i,
        ls_t313g         TYPE t313g,
        lv_fehler        TYPE flag,
        lv_matnr         TYPE matnr,
        lv_matnr_num(18) TYPE n,
        lv_charg         TYPE charg_d,
        lv_menge         TYPE char11,
        lv_fauf          TYPE aufnr,
        lv_werks         TYPE werks_d,
        lv_shipcode      TYPE char14,
        lv_91_exist      TYPE abap_bool,
        lv_barcode100    TYPE ZD_BARCODE.

  DATA: lv_exist         TYPE flag.

  DATA: lc_ean128  TYPE t313daityp VALUE 'EAN128'." Should be declared as constant??

  DATA: ls_ai TYPE ts_ai,
        lt_ai TYPE STANDARD TABLE OF ts_ai.
*Begin of insert rvenugopal - Application identifier logic
  CONSTANTS: lc_lonza_type TYPE t313g-aityp VALUE 'EAN128',
             lc_capus_type TYPE t313g-aityp VALUE 'GS1'.
  DATA : lt_t313g       TYPE STANDARD TABLE OF t313g,
         lv_barcodetype TYPE t313g-aityp.


  IF iv_barcode IS INITIAL.
*      issue error  return
    RETURN.
  ENDIF.

*  fetch the AI types from the T313G table
  SELECT * FROM t313g INTO TABLE lt_t313g.
  IF sy-subrc NE 0.
    RETURN.
  ENDIF.

*End of insert rvenugopal - Application identifier logic
  lv_barcode = iv_barcode.
  lv_werks   = iv_werks.

  CLEAR lv_exist.

* Determine the application identifier and decide the logic CAP VS LONZA
  LOOP AT lt_t313g ASSIGNING FIELD-SYMBOL(<ls_t313g>).
    DATA(lv_pf_len) = strlen( <ls_t313g>-prefix  ) .
    IF iv_barcode+0(lv_pf_len) = <ls_t313g>-prefix.
      lv_exist = abap_true ." prefix exists in the configuration
      EXIT.
    ENDIF.
  ENDLOOP.

  IF lv_exist IS INITIAL.
*   This is a onza specific logic . 93 identifier is not used everywhere.
    lv_barcodetype = lc_lonza_type .
  ENDIF.

* Barcode type determined and set to a variable
  IF <ls_t313g> IS ASSIGNED AND lv_exist EQ abap_true.
    lv_barcodetype = <ls_t313g>-aityp.
  ENDIF.

* *Split the barcode logic based on the barcode
  CASE lv_barcodetype.

    WHEN lc_lonza_type.

      CLEAR ls_t313g.

*     *Daten zu Barcode EAN128 lesen
      SELECT SINGLE * FROM t313g INTO ls_t313g WHERE aityp = lc_ean128.
      IF sy-subrc EQ 0 AND
         lv_barcode+0(2) EQ ls_t313g-prefix+0(2) AND
         lv_barcode      NE ls_t313g-prefix.
      ELSE.
        IF lv_barcode(2) = '01' AND sy-tcode = 'ZLMT1'.
          ls_t313g-prefix+0(2) = '01'.
        ELSE.
          sy-subrc = 4.
        ENDIF.
      ENDIF.

      IF sy-subrc EQ 0.
*       process EAN128
        CLEAR: lv_fehler,lv_matnr,lv_charg,lv_menge,lv_fauf,lv_shipcode.

        lv_strlen = strlen( lv_barcode ).

*       *** Prüfziffer des gesamten Barcodes abtesten
*       *** Barcode anhand Customizingtabellen aufteilen ***
        CALL METHOD zcl_mde_barcode=>partition_barcode
          EXPORTING
            iv_barcode = lv_barcode
            iv_strlen  = lv_strlen
            is_t313g   = ls_t313g
          IMPORTING
            et_ai      = lt_ai
            ev_fehler  = lv_fehler.

        lv_91_exist = abap_false.

        LOOP AT lt_ai INTO ls_ai.
          CALL METHOD zcl_mde_barcode=>fill_fields
            EXPORTING
              iv_aival    = ls_ai-aival
              iv_ailen    = ls_ai-ailen
              iv_ainkl    = ls_ai-ainkl
              iv_data     = ls_ai-data
            IMPORTING
              ev_matnr    = lv_matnr
              ev_charg    = lv_charg
              ev_fauf     = lv_fauf
              ev_menge    = lv_menge
              ev_shipcode = lv_shipcode.

*         Select quantity
          CASE ls_ai-aival.
            WHEN '91' OR '9100'.
*             Quantity with AI 91* is prefered quantity
              IF lv_menge > 0 AND lv_91_exist = abap_false.
                lv_91_exist = abap_true.
                ev_menge = lv_menge.
              ENDIF.
            WHEN '3100' OR '3101'.
              IF ev_menge = 0 AND lv_91_exist = abap_false.
                ev_menge = lv_menge.
              ENDIF.
          ENDCASE.

        ENDLOOP.

        ev_charg = lv_charg.
        ev_fauf  = lv_fauf.
      ELSE.
        IF lv_werks NE '5010' AND
           lv_werks NE '5020'.
          CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
            EXPORTING
              input        = lv_barcode
            IMPORTING
              output       = lv_matnr
            EXCEPTIONS
              length_error = 1
              OTHERS       = 2.
          IF sy-subrc <> 0.
*         Implement suitable error handling here
          ENDIF.
        ELSE.
*         Spezialfurz für Braine da die ja immer alles besser wissen
*         Dient nur dem lesen von alten Etiketten ohne AI,
*         die neuen werden mit AI gedruckt
          lv_matnr = lv_barcode(8).
          IF lv_matnr CO '0123456789 '.
            lv_matnr_num = lv_matnr.
            lv_matnr = lv_matnr_num.
          ENDIF.
          ev_charg = lv_barcode+8(10).
        ENDIF.
      ENDIF.

      ev_matnr    = lv_matnr.
      ev_fehler   = lv_fehler.
      ev_shipcode = lv_shipcode.
*Application Idetifiers Details
      et_data     = lt_ai.

    WHEN  lc_capus_type.
*     Capsugel is using 100 character length for barcode while
*     lonza is using 200 Char
      lv_barcode100 = lv_barcode(100).
      CALL METHOD zcl_its_utility=>barcode_read_dfs
        EXPORTING
          iv_barcode           = lv_barcode100
          is_read_option       = is_read_option
          iv_exist_check       = iv_exist_check
          it_label_type_range  = it_label_type_range
          iv_read_10_only      = iv_read_10_only
          iv_skip_or_bch_check = iv_skip_or_bch_check
          iv_appid_type        = lc_capus_type   "AT Added
        IMPORTING
          ev_label_type        = ev_label_type
          es_label_content     = es_label_content
          es_material_data     = es_material_data.
* Check to change the storage location of parent to child SU.
      SELECT SINGLE lgort FROM vepo INTO es_label_content-hu_content-hu_header-stge_loc
                                  WHERE venum = es_label_content-hu_content-hu_header-hu_id.
    WHEN OTHERS.
      RETURN.
  ENDCASE.

ENDMETHOD.


METHOD fill_fields.

  DATA: lv_aival   TYPE t313daival,
        lv_ailen   TYPE t313dailen,
        lv_ainkl   TYPE t313dainkl,
        lv_data    TYPE ts_ai-data,
        lv_matnr   TYPE matnr,
        lv_charg   TYPE charg_d,
        lv_menge   TYPE char11,
        lv_menge_p TYPE menge_d.

  DATA: lc_ainkl_3 TYPE t313dainkl VALUE 3,
        lc_ainkl_2 TYPE t313dainkl VALUE 2,
        lc_ainkl_1 TYPE t313dainkl VALUE 1.

  lv_aival = iv_aival.
  lv_ailen = iv_ailen.
  lv_ainkl = iv_ainkl.
  lv_data = iv_data.

  CASE lv_aival.
    WHEN '93  '.
      lv_matnr = lv_data(lv_ailen).
      SHIFT lv_matnr RIGHT DELETING TRAILING space.
      DO.
        REPLACE ' ' WITH '0' INTO lv_matnr.
        IF NOT lv_matnr CA ' '.
          EXIT.
        ENDIF.
      ENDDO.

      ev_matnr = lv_matnr.
    WHEN '94'.
      ev_fauf = lv_data(lv_ailen).
    WHEN '10  '.
      lv_charg = lv_data(lv_ailen).

      ev_charg = lv_charg.
    WHEN '91  ' OR '9100' OR '3100' OR '3101'.
      lv_menge = lv_data(lv_ailen).
      lv_menge_p = lv_menge.
      IF lv_ainkl = lc_ainkl_3.
        lv_menge_p = lv_menge_p / 1000.
      ELSE.
        IF lv_ainkl = lc_ainkl_2.
          lv_menge_p = lv_menge_p / 100.
        ELSE.
          IF lv_ainkl = lc_ainkl_1.
            lv_menge_p = lv_menge_p / 10.
          ENDIF.
        ENDIF.
      ENDIF.
      lv_menge = lv_menge_p.

      ev_menge = lv_menge.
    WHEN '01'.
      ev_shipcode = lv_data(lv_ailen).
  ENDCASE.


ENDMETHOD.


method partition_barcode.

  data: lv_barcode type char200,
        ls_t313g type t313g,
        ls_t313d type t313d.

  data: lv_strlen type i,
        lv_length(1) type n,
        lv_startpos like sy-fdpos,
        lv_fehler type flag.

  data: ls_ai type ts_ai,
        lt_ai type standard table of ts_ai.

  lv_barcode = iv_barcode.
  lv_strlen = iv_strlen.
  ls_t313g = is_t313g.

  lv_length = ls_t313g-minle.

  clear: lt_ai,
         ls_ai,
         lv_fehler.

  lv_startpos = 1.

  do.
    clear: ls_ai.
    ls_ai-aival = lv_barcode(lv_length).

    select single * from t313d into ls_t313d where aityp = ls_t313g-aityp and
                                                   aival = ls_ai-aival and
                                                   aidef = 'X'.
    if sy-subrc eq 0.
      move-corresponding ls_t313d to ls_ai.
      ls_ai-data = lv_barcode+lv_length(ls_ai-ailen).
      ls_ai-fehler = ' '.
      append ls_ai to lt_ai.

      shift lv_barcode left by lv_length places.
      shift lv_barcode left by ls_ai-ailen places.
      if lv_barcode is initial.
        exit.
      endif.
      lv_length = ls_t313g-minle.
      lv_startpos = 1.
    else.
      if ls_t313g-maxle > lv_length.
        lv_length = lv_length + 1.
      else.
*       * Fehler
        lv_fehler = 'X'.
        lv_startpos = 2.
        exit.
      endif.
    endif.

  enddo.

  et_ai = lt_ai.
  ev_fehler = lv_fehler.

endmethod.
ENDCLASS.
