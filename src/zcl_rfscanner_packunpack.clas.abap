class ZCL_RFSCANNER_PACKUNPACK definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ts_message,
             message1 TYPE char20,
             message2 TYPE char20,
             message3 TYPE char20,
             message4 TYPE char20,
             message5 TYPE char20,
             message6 TYPE char20,
             message7 TYPE char20,
             message8 TYPE char20,
          END OF ts_message .
  types:
    BEGIN OF ts_phu,
          venum TYPE venum,       " Internal Handling Unit
          exidv  TYPE exidv,      " External Handling Unit Identification
          vhilm  TYPE vhilm,      " packing material
          maktx  TYPE maktx,      " material text
          werks  TYPE hum_werks,  " plant
          lgort  TYPE hum_lgort,  " stor. loca
          lgnum  TYPE hum_lgnum,  " whr. no
          lgpla  TYPE lgpla,      " stor. Bin
        END OF ts_phu .
  types:
    BEGIN OF ts_vekp,
          venum TYPE vekp-venum," Internal Handling Unit Number
          exidv TYPE exidv,      " External Handling Unit Identification
          vhilm TYPE vhilm,      " packing material
          werks  TYPE hum_werks, " plant
          lgort  TYPE hum_lgort, " stor. loca
          lgnum  TYPE hum_lgnum, " whr. no
        END OF ts_vekp .
  types:
    BEGIN OF ts_lein,
          lenum  TYPE lenum,
*          lgnum  TYPE hum_lgnum, " whr. no
          lgpla  TYPE lgpla,     " stor. Bin
        END OF ts_lein .
  types:
    BEGIN OF ts_makt,
          matnr TYPE matnr,
          maktx TYPE maktx,
        END OF ts_makt .
  types:
    BEGIN OF ts_hhu,
         venum type venum,
         exidv TYPE exidv,
         werks TYPE werks_d,
         matnr TYPE matnr,
         lgort TYPE lgort_d,
         charg TYPE charg_d,
         magrv TYPE magrv,   " packaging material group
         bestq TYPE bestq, " stock catogery type
         flag  TYPE XFELD,
         lgtyp TYPE lgtyp,
         lgpla TYPE lgpla,
         lgber TYPE lgber,
         pvenum TYPE venum,
         pexidv TYPE exidv,
         pallethu  TYPE char1,
      END OF ts_hhu .
  types:
    tt_hhu TYPE STANDARD TABLE OF ts_hhu .
  types:
    tt_hphu TYPE STANDARD TABLE OF ts_phu .
  types:
    tt_lein TYPE STANDARD TABLE OF ts_lein .
  types:
    tt_vekp TYPE STANDARD TABLE OF ts_vekp .
  types:
    tt_makt TYPE STANDARD TABLE OF ts_makt .

  methods VALIDATION_NONHU
    exporting
      !EV_CHECK type BOOLEAN
    changing
      !CS_PHU type TS_PHU .
  methods MESSAGE_DISPLAY
    importing
      value(LV_ID) type CHAR20
      value(LV_VALUE) type CHAR20
      value(LV_NO) type CHAR3
    exporting
      !ES_MESSAGE type TS_MESSAGE .
  methods PHYSCIALHU_EXIST
    exporting
      !EV_CHECK type BOOLEAN
    changing
      !CS_PHHUSTATUS type TS_PHU .
  methods RECEIVERHU_PALLET
    importing
      value(IV_EXIDV) type EXIDV
      value(IV_PLANT) type HUM_WERKS
      value(IV_STORLOC) type HUM_LGORT
    exporting
      !EV_CHECK type BOOLEAN
      !EV_PLANT type HUM_WERKS
      !EV_STORLOC type HUM_LGORT .
  methods HUBARCODE_VALUE
    importing
      value(IV_EXIDV) type CHAR100
    exporting
      !EV_HUNUMBER type CHAR100 .
  methods GET_VALIDATE_HU
    exporting
      !EV_PCHECK type BOOLEAN
      !EV_LCHECK type BOOLEAN
      !EV_LERROR type BOOLEAN
      !EV_WERKS type WERKS_D
      !EV_BATCH type CHARG_D
      !EV_SLGORT type LGORT_D
      !EV_SMATNR type MATNR
      !EV_STOCK_TYPE type BESTQ
      !EV_MAGRV type MAGRV
    changing
      !CS_PEXIDV type TS_HHU
      !CS_LEXIDV type TS_HHU .
protected section.
private section.
ENDCLASS.



CLASS ZCL_RFSCANNER_PACKUNPACK IMPLEMENTATION.


  METHOD get_validate_hu.

    DATA : lv_pexidv TYPE exidv,
           lv_venum  TYPE venum,
           lv_lexidv TYPE exidv.

    DATA : lt_hu         TYPE hum_exidv_t , " External HU
           ls_hu         TYPE hum_exidv,
           lt_hu_detail  TYPE hum_hu_header_t, " HU Details
           ls_hu_detail  TYPE vekpvb,
           lt_hu_items   TYPE hum_hu_item_t,
           ls_hu_items   TYPE vepovb,
           lt_hu_history TYPE hum_history_t,
           ls_hu_history TYPE vevwvb,
           lt_hl_hu_int  TYPE hum_venum_t, " High level HU - Internal
           ls_hl_hu_int  TYPE hum_venum,
           lv_lines      TYPE i.

    CLEAR : lv_pexidv, lv_lexidv, lv_venum.
*--Check External Handaling unit is not initial.
    IF cs_pexidv-exidv IS NOT INITIAL.
*--Convert HU to internal format
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = cs_pexidv-exidv
        IMPORTING
          output = cs_pexidv-exidv.

*--Fetch only Higher Level Handling Unit data from VEKP table and validate also
      SELECT SINGLE exidv
             FROM vekp
             INTO lv_pexidv
             WHERE exidv EQ cs_pexidv-exidv
               AND uevel EQ space.
      IF sy-subrc NE 0.
        ev_pcheck = abap_true.
        RETURN.
      ELSE.
*-- Check Higher level HU have lower HU or its empty pallet
        CLEAR : ls_hu .
        ls_hu-exidv = cs_pexidv-exidv.
        APPEND ls_hu TO lt_hu.
*  this is lower level hu, read it's higher level HU
        CALL FUNCTION 'HU_GET_HUS_DB'
          EXPORTING
            it_hu_numbers    = lt_hu
          IMPORTING
            et_hu_header     = lt_hu_detail
            et_hu_items      = lt_hu_items
            et_hu_history    = lt_hu_history
            et_highest_level = lt_hl_hu_int
          EXCEPTIONS
            no_hu_found      = 1
            fatal_error      = 2
            OTHERS           = 3.
*--Incase lt_hu_items there is no entries then its empty pallet
        IF sy-subrc = 0 AND lt_hu_items[] IS INITIAL.
*    No need to do anything
        ELSEIF lt_hu_items[] IS NOT INITIAL.
*--if nested HU found then get plant data, material, batch, stock type
          READ TABLE lt_hl_hu_int ASSIGNING FIELD-SYMBOL(<lfs_int>)
                                  INDEX 1.
          IF sy-subrc EQ 0 AND <lfs_int>-venum IS NOT INITIAL.
            DELETE lt_hu_items WHERE venum EQ <lfs_int>-venum.
            DELETE lt_hu_items WHERE velin NE 1 .
            READ TABLE lt_hu_items INTO ls_hu_items INDEX 1.
            IF sy-subrc EQ 0.
              cs_pexidv-matnr = ls_hu_items-matnr.
              ev_smatnr        = ls_hu_items-matnr.
              cs_pexidv-charg = ls_hu_items-charg.
              ev_batch        = ls_hu_items-charg.
              cs_pexidv-lgort = ls_hu_items-lgort.
              ev_slgort       = ls_hu_items-lgort.
              cs_pexidv-werks = ls_hu_items-werks.
              ev_werks        = ls_hu_items-werks.
              cs_pexidv-bestq = ls_hu_items-bestq.
              ev_stock_type   = ls_hu_items-bestq.
              READ TABLE lt_hu_detail ASSIGNING FIELD-SYMBOL(<lfs_header>)
                                      WITH KEY venum = <lfs_int>-venum.
              IF sy-subrc EQ 0 AND <lfs_header>-magrv IS NOT INITIAL.
                cs_pexidv-magrv = <lfs_header>-magrv.
                ev_magrv        = <lfs_header>-magrv.
                cs_pexidv-venum = <lfs_header>-venum.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.


*--Lower level HU validation
*--Lower level HU does not pack into another Pallet HU , if yes show error
*--Check External Handaling unit is not initial.
    IF cs_lexidv-exidv IS NOT INITIAL.
*--Convert HU to internal format
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = cs_lexidv-exidv
        IMPORTING
          output = cs_lexidv-exidv.

      SELECT SINGLE exidv FROM vekp
                   INTO @DATA(lv_lexidv1)
                   WHERE exidv EQ @cs_lexidv-exidv.
      IF  sy-subrc NE 0.
        ev_lcheck = abap_true.
        RETURN.
      ENDIF.

*--check lower level Material, plant,  batch, storage location
*-- Check Higher level HU have lower HU or its empty pallet
      CLEAR : ls_hu .
      REFRESH : lt_hu, lt_hu_detail,lt_hu_items,
                lt_hu_history, lt_hl_hu_int.
      ls_hu-exidv = cs_lexidv-exidv.
      APPEND ls_hu TO lt_hu.
*--Check lower level HU is packed in another nested HU or not?
      CALL FUNCTION 'HU_GET_HUS_DB'
        EXPORTING
          it_hu_numbers    = lt_hu
        IMPORTING
          et_hu_header     = lt_hu_detail
          et_hu_items      = lt_hu_items
          et_hu_history    = lt_hu_history
          et_highest_level = lt_hl_hu_int
        EXCEPTIONS
          no_hu_found      = 1
          fatal_error      = 2
          OTHERS           = 3.
*--Incase lt_hu_items there is no entries then its empty pallet
      IF sy-subrc = 0 .
        CLEAR : lv_lines.
*--if nested HU found then get plant data, material, batch, stock type
        DESCRIBE TABLE lt_hu_detail LINES lv_lines.

        IF lv_lines NE 1.
*--if more than one records
          READ TABLE lt_hl_hu_int ASSIGNING <lfs_int> INDEX 1.
          IF sy-subrc EQ 0 AND <lfs_int>-venum IS NOT INITIAL.
*--If lower level HU already packed in same Pallet HU show an error message
            IF cs_pexidv-venum EQ <lfs_int>-venum.
              ev_lerror = abap_true.
            ENDIF.
            DELETE lt_hu_items WHERE venum EQ <lfs_int>-venum.
          ENDIF.
        ENDIF.

*--Check Higher level HU or not
        READ TABLE lt_hl_hu_int ASSIGNING <lfs_int>
                                  INDEX 1.
        IF sy-subrc EQ 0 AND <lfs_int>-venum IS NOT INITIAL.
*--Fetch Lower level HU and check its Single HU or Nested HU or Pallet HU
          SELECT SINGLE venum exidv
                  FROM vekp
                  INTO (lv_venum, lv_lexidv)
                  WHERE venum EQ <lfs_int>-venum
                    AND exidv EQ cs_lexidv-exidv
                    AND uevel EQ space.
          IF sy-subrc EQ 0 AND lv_lines NE 1.
*--If enter HU is Pallet HU and have carton then flag will set
*--this we will consider first unpack all carton from source then pack to reciver Pallet
            cs_lexidv-pallethu = abap_true.
          ELSEIF sy-subrc NE 0.
            SELECT SINGLE venum exidv
                     FROM vekp
                     INTO (lv_venum, lv_lexidv)
                     WHERE venum EQ <lfs_int>-venum
                       AND uevel EQ space.
*--if it is a Nested HU that is already packed in another HU get that Pallet HU
            cs_lexidv-pvenum = lv_venum.
            cs_lexidv-pexidv = lv_lexidv.
          ENDIF.
*--Respective all item data move to respective fields
          DELETE lt_hu_items WHERE velin NE 1.
          READ TABLE lt_hu_items INTO ls_hu_items INDEX 1.
          IF sy-subrc EQ 0.
            cs_lexidv-matnr = ls_hu_items-matnr.
            IF ev_smatnr IS INITIAL.
              ev_smatnr       = ls_hu_items-matnr.
            ENDIF.
            cs_lexidv-charg = ls_hu_items-charg.
            IF ev_batch IS INITIAL.
              ev_batch       = ls_hu_items-charg.
            ENDIF.
            cs_lexidv-lgort = ls_hu_items-lgort.
            IF ev_slgort IS INITIAL.
              ev_slgort       = ls_hu_items-lgort.
            ENDIF.
            cs_lexidv-werks = ls_hu_items-werks.
            IF ev_werks IS INITIAL.
              ev_werks       = ls_hu_items-werks.
            ENDIF.
            cs_lexidv-bestq = ls_hu_items-bestq.
            IF ev_stock_type IS INITIAL.
              ev_stock_type = ls_hu_items-bestq.
            ENDIF.
            READ TABLE lt_hu_detail ASSIGNING <lfs_header>
                                    WITH KEY venum = <lfs_int>-venum.
            IF sy-subrc EQ 0 AND <lfs_header>-magrv IS NOT INITIAL.
              cs_lexidv-magrv = <lfs_header>-magrv.
              IF ev_magrv IS INITIAL.
                ev_magrv = <lfs_header>-magrv.
              ENDIF.
              cs_lexidv-venum = <lfs_header>-venum.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD hubarcode_value.
*--This method will use to add Prefix value to HU number
*--Incase of User not enter Prefix, even if enter also it will validate then proceed
    DATA : lv_low     TYPE rvari_val_255,
           lv_low1    TYPE rvari_val_255,
           lv_prefix  TYPE t313daityp,
           lv_fprefix TYPE char100,
           lv_exidv   TYPE char100.

    CONSTANTS : lc_barcode TYPE rvari_vnam VALUE 'Z_BARCODE_TYPE',
                lc_hupref  TYPE rvari_vnam VALUE 'Z_HU_PREFIX'.

    CLEAR : lv_low, lv_low1, lv_prefix,lv_fprefix.
    lv_exidv = iv_exidv.
*--Get Bar code value
    IF lv_exidv IS NOT INITIAL.
      CONDENSE lv_exidv NO-GAPS .
*  check if this is an old HU number
      SELECT SINGLE exidv FROM vekp INTO @DATA(lv_exidv_new)
      WHERE zzold_hu = @lv_exidv.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = lv_exidv_new
          IMPORTING
            output = lv_exidv_new.
        lv_exidv = lv_exidv_new. " Pass the respective SAP HU number
      ELSE.
        lv_exidv = iv_exidv. " This is not a old HU number
        " Old process continues
      ENDIF.

      SELECT SINGLE low FROM tvarvc INTO lv_low
                  WHERE name EQ lc_barcode.
      IF sy-subrc EQ 0.
        SELECT prefix FROM t313g INTO lv_prefix UP TO 1 ROWS
                      WHERE aityp EQ lv_low.
        ENDSELECT.
        IF sy-subrc EQ 0.
*--check if enter HU prefix is match with above value otherwise go to else part
          IF lv_prefix EQ lv_exidv+0(3).
*--with prefix same move to destination
            ev_hunumber = lv_exidv.
            CONDENSE ev_hunumber.
            RETURN.
          ELSE.
*--Get the prefix value of HU number from TVARVC table
            SELECT low FROM tvarvc INTO lv_low1 UP TO 1 ROWS
                WHERE name EQ lc_hupref.
            ENDSELECT.
            IF sy-subrc EQ 0.
*--concatenate with prefix and HU prefix value and finaly merger with HU number
              CONCATENATE lv_prefix lv_low1 INTO lv_fprefix.
              CONDENSE lv_fprefix.

              CONCATENATE lv_fprefix lv_exidv INTO ev_hunumber.
              CONDENSE ev_hunumber.
            ENDIF.
          ENDIF.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD message_display.

    TYPES :BEGIN OF ts_line,
             text_split(20) TYPE c,
           END OF ts_line.

    DATA : lv_message TYPE string,
           lv_mes     TYPE char255,
           lv_msgid   TYPE syst_msgid,
           lv_num     TYPE msgno,
           lv_value1  TYPE msgv1,
           lt_lines   TYPE STANDARD TABLE OF ts_line.

    CONSTANTS : lc_lang TYPE spras VALUE 'E'.

    CLEAR : lv_message, lv_mes, lt_lines, lv_msgid, lv_value1.
*--message id
    lv_msgid = lv_id.
*--message Number
    lv_num    = lv_no.
*--Message Value
    lv_value1 = lv_value.


*--Get the message from message id
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        id        = lv_msgid
        lang      = lc_lang
        no        = lv_num "'001'
        v1        = lv_value1
      IMPORTING
        msg       = lv_message
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    lv_mes =      lv_message.
    IF sy-subrc EQ 0 AND lv_message IS NOT INITIAL.
*--Split message text into work area
      CALL FUNCTION 'RKD_WORD_WRAP'
        EXPORTING
          textline            = lv_mes
          outputlen           = 20
        TABLES
          out_lines           = lt_lines
        EXCEPTIONS
          outputlen_too_large = 1
          OTHERS              = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ELSE.
        LOOP AT lt_lines ASSIGNING FIELD-SYMBOL(<lfs_lines>).
          CASE sy-tabix.
            WHEN 1.
              es_message-message1 = <lfs_lines>-text_split.
            WHEN 2.
              es_message-message2 = <lfs_lines>-text_split.
            WHEN 3.
              es_message-message3 = <lfs_lines>-text_split.
            WHEN 4.
              es_message-message4 = <lfs_lines>-text_split.
            WHEN 5.
              es_message-message5 = <lfs_lines>-text_split.
            WHEN 6.
              es_message-message6 = <lfs_lines>-text_split.
            WHEN 7.
              es_message-message7 = <lfs_lines>-text_split.
            WHEN 8.
              es_message-message8 = <lfs_lines>-text_split.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD physcialhu_exist.
*--Check validation for Enter Physical HU is valid from VEKP table
*--Enter HU is Physically avilable in Warhouse or not. If yes, only allow
*--Enter Pallet HU should be Higher Level HU only


    DATA : ls_vekp   TYPE ts_vekp,
           ls_lein   TYPE ts_lein,
           ls_makt   TYPE ts_makt,
           lv_objnr  TYPE j_objnr,
           lv_objnr1 TYPE j_objnr,
           lv_werks  TYPE werks_d,
           lv_lgort  TYPE lgort_d,
           lv_highest_level_hu TYPE exidv,
           lt_header_detail    TYPE TABLE OF vekpvb..

    CONSTANTS : lc_lang  TYPE spras    VALUE 'E',
                lc_hu    TYPE char2    VALUE 'HU',
                lc_i0512 TYPE j_status VALUE 'I0512',
                lc_space TYPE char1    VALUE ' '.

    CLEAR : ls_vekp, ls_lein, ls_makt, lv_objnr, lv_objnr1,
            lv_werks, lv_lgort, lv_highest_level_hu, lt_header_detail.

*--Check External Handaling unit is not initial.
    IF cs_phhustatus-exidv IS NOT INITIAL.
*--Convert HU to internal format,
     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
       EXPORTING
         input         = cs_phhustatus-exidv
      IMPORTING
         output        = cs_phhustatus-exidv.

*--Fetch only Higher Level Handling Unit data from VEKP table and validate also
     SELECT venum exidv vhilm werks lgort lgnum UP TO 1 ROWS
            FROM vekp
            INTO ls_vekp
            WHERE exidv = cs_phhustatus-exidv
              AND uevel = space.
     ENDSELECT.
      IF sy-subrc = 0.
*--Concatenate the internal HU no with HU for Object number
        CONCATENATE lc_hu ls_vekp-venum INTO lv_objnr.
*---check Enter HU is Physically avialble in warhouse or not
       SELECT SINGLE objnr
              FROM husstat
              INTO lv_objnr1
              WHERE objnr EQ lv_objnr
                AND stat  EQ lc_i0512
                AND inact EQ lc_space.
        IF sy-subrc EQ 0.
          cs_phhustatus-venum = ls_vekp-venum.
          cs_phhustatus-vhilm = ls_vekp-vhilm.
          cs_phhustatus-lgnum = ls_vekp-lgnum.

*--Get lower level HU's VENUM for get Plant and Storage location values
     CALL FUNCTION 'HU_GET_ONE_HU_DB'
      EXPORTING
       if_hu_number              = ls_vekp-exidv
       if_all_levels             = abap_true
     IMPORTING
       ef_highest_level_hu       = lv_highest_level_hu
       et_hu_header              = lt_header_detail
     EXCEPTIONS
       hu_not_found              = 1
       hu_locked                 = 2
       fatal_error               = 3
       OTHERS                    = 4.
    IF sy-subrc EQ 0.
*--Implement handling here
     SORT lt_header_detail BY exidv.
*--Remove Header HU number from internal table
     DELETE lt_header_detail WHERE exidv = ls_vekp-exidv.
    ENDIF.


 READ TABLE lt_header_detail ASSIGNING FIELD-SYMBOL(<lfs_details>) INDEX 1.
  IF sy-subrc EQ 0.
*--Fetch Plant and storage location details from Item table VEPO
   SELECT SINGLE werks lgort FROM vepo
           INTO (lv_werks, lv_lgort)
           WHERE venum EQ <lfs_details>-venum.
    IF sy-subrc EQ 0.
      cs_phhustatus-werks = lv_werks.
      cs_phhustatus-lgort = lv_lgort.
    ENDIF.

  ELSE.
*--Get plant & stor.loc from single HU which in
     SELECT SINGLE werks lgort FROM vepo
           INTO (lv_werks, lv_lgort)
           WHERE venum EQ ls_vekp-venum.
    IF sy-subrc EQ 0.
      cs_phhustatus-werks = lv_werks.
      cs_phhustatus-lgort = lv_lgort.
    ENDIF.
   ENDIF.
   REFRESH :lt_header_detail.

*--Fetch Material description based on Packed Materials
         SELECT matnr maktx UP TO 1 ROWS FROM makt
                INTO ls_makt
                WHERE matnr = ls_vekp-vhilm
                  AND spras = lc_lang.
         ENDSELECT.
         IF sy-subrc EQ 0.
           cs_phhustatus-maktx = ls_makt-maktx.
         CLEAR : ls_makt.
         ENDIF.

*--Fetch Storage location details
         SELECT lenum lgpla FROM lein UP TO 1 ROWS
                INTO ls_lein
                WHERE lenum = ls_vekp-exidv.
         ENDSELECT.
         IF sy-subrc EQ 0.
          cs_phhustatus-lgpla = ls_lein-lgpla.
           CLEAR : ls_lein.
         ENDIF.

       ENDIF. "husstat
      ELSE.
*--show an error message
        ev_check = abap_true.

      ENDIF.  " sy-subrc
    ELSE.
*--show an error message
      ev_check = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD receiverhu_pallet.
*--Check validation for Enter Physical HU is valid from VEKP table
*--Enter HU is Physically avilable in Warhouse or not. If yes, only allow
*--Enter Pallet HU should be Higher Level HU only
*--Check IVported HU , plant & storage location combination only

    DATA : ls_vekp   TYPE ts_vekp,
           ls_lein   TYPE ts_lein,
           ls_makt   TYPE ts_makt,
           lv_objnr  TYPE j_objnr,
           lv_objnr1 TYPE j_objnr,
           lv_werks  TYPE werks_d,
           lv_lgort  TYPE lgort_d,
           lv_highest_level_hu TYPE exidv,
           lt_header_detail    TYPE TABLE OF vekpvb.

    CONSTANTS : lc_lang  TYPE spras    VALUE 'E',
                lc_hu    TYPE char2    VALUE 'HU',
                lc_i0512 TYPE j_status VALUE 'I0512',
                lc_space TYPE char1    VALUE ' '.

    CLEAR : ls_vekp, ls_lein, ls_makt, lv_objnr,lv_objnr1, lv_werks,
            lv_lgort, lv_highest_level_hu, lt_header_detail .

*--Check External Handaling unit is not initial.
    IF iv_exidv IS NOT INITIAL.
*--Convert HU to internal format
     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
       EXPORTING
         input         = iv_exidv
      IMPORTING
         output        = iv_exidv.

*--Fetch only Higher Level Handling Unit data from VEKP table and validate also
     SELECT venum exidv vhilm werks lgort lgnum UP TO 1 ROWS
            FROM vekp
            INTO ls_vekp
            WHERE exidv EQ iv_exidv
              AND uevel EQ space.
     ENDSELECT.
      IF sy-subrc = 0.
*--Get lower level HU's VENUM for get Plant and Storage location values
     CALL FUNCTION 'HU_GET_ONE_HU_DB'
      EXPORTING
       if_hu_number              = ls_vekp-exidv
       if_all_levels             = abap_true
     IMPORTING
       ef_highest_level_hu       = lv_highest_level_hu
       et_hu_header              = lt_header_detail
     EXCEPTIONS
       hu_not_found              = 1
       hu_locked                 = 2
       fatal_error               = 3
       OTHERS                    = 4.
    IF sy-subrc EQ 0.
*--Implement handling here
     SORT lt_header_detail BY exidv.
*--Remove Header HU number from internal table
     DELETE lt_header_detail WHERE exidv = ls_vekp-exidv.
    ENDIF.

*--Fetch Plant and storage location details from Item table VEPO
*  IF lt_header_detail IS NOT INITIAL.
 READ TABLE lt_header_detail ASSIGNING FIELD-SYMBOL(<lfs_details>) INDEX 1.
  IF sy-subrc EQ 0.
   SELECT SINGLE werks lgort FROM vepo
           INTO (lv_werks, lv_lgort)
           WHERE venum EQ <lfs_details>-venum
             AND werks eq iv_plant
             AND lgort eq iv_storloc..
    IF sy-subrc NE 0.
      CLEAR : lv_werks,lv_lgort.
    ENDIF.
   ELSE.
*--Get plant & stor.loc from single HU which in
     SELECT SINGLE werks lgort FROM vepo
           INTO (lv_werks, lv_lgort)
           WHERE venum EQ ls_vekp-venum
             AND werks eq iv_plant
             AND lgort eq iv_storloc.
    IF sy-subrc NE 0.
        CLEAR : lv_werks,lv_lgort.
    ENDIF.
   ENDIF.
   REFRESH :lt_header_detail.

*--Concatenate the internal HU no with HU for Object number
       CONCATENATE lc_hu ls_vekp-venum INTO lv_objnr.
*---check Enter HU is Physically avialble in warhouse or not
       SELECT SINGLE objnr
              FROM husstat
              INTO lv_objnr1
              WHERE objnr EQ lv_objnr
                AND stat  EQ lc_i0512
                AND inact EQ lc_space.
        IF sy-subrc EQ 0.
          ev_plant   = lv_werks."ls_vekp-werks.
          ev_storloc = lv_lgort. "ls_vekp-lgort.

       ENDIF. "husstat
      ELSE.
*--show an error message
        ev_check = abap_true.

      ENDIF.  " sy-subrc
    ELSE.
*--show an error message
      ev_check = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD validation_nonhu.

DATA : ls_vekp  TYPE ts_vekp,
       ls_lein  TYPE ts_lein,
       ls_makt  TYPE ts_makt,
       lv_werks TYPE werks_d,
       lv_lgort TYPE lgort_d,
       lv_highest_level_hu TYPE exidv,
       lt_header_detail    TYPE TABLE OF vekpvb.

CONSTANTS : lc_lang TYPE spras VALUE 'E'.

CLEAR : ls_vekp, ls_lein, ls_makt, lv_lgort, lv_werks,
        lv_highest_level_hu.

REFRESH : lt_header_detail.

*--Check External Handaling unit is not initial.
IF cs_phu-exidv IS NOT INITIAL.
*--Convert HU to internal format
 CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
   EXPORTING
     input         = cs_phu-exidv
  IMPORTING
     output        = cs_phu-exidv.

*--Fetch only Higher Level Handling Unit data from VEKP table and validate also
 SELECT venum exidv vhilm werks lgort lgnum UP TO 1 ROWS
        FROM vekp
        INTO ls_vekp
        WHERE exidv = cs_phu-exidv
          AND uevel = space.
 ENDSELECT.
  IF sy-subrc = 0.
    cs_phu-venum = ls_vekp-venum.
    cs_phu-vhilm = ls_vekp-vhilm.
    cs_phu-lgnum = ls_vekp-lgnum.

*--Get lower level HU's VENUM for get Plant and Storage location values
     CALL FUNCTION 'HU_GET_ONE_HU_DB'
      EXPORTING
       if_hu_number              = ls_vekp-exidv
       if_all_levels             = abap_true
     IMPORTING
       ef_highest_level_hu       = lv_highest_level_hu
       et_hu_header              = lt_header_detail
     EXCEPTIONS
       hu_not_found              = 1
       hu_locked                 = 2
       fatal_error               = 3
       OTHERS                    = 4.
    IF sy-subrc EQ 0.
*--Implement handling here
     SORT lt_header_detail BY exidv.
*--Remove Header HU number from internal table
     DELETE lt_header_detail WHERE exidv = ls_vekp-exidv.
    ENDIF.

*--Fetch Plant and storage location details from Item table VEPO
*  IF lt_header_detail IS NOT INITIAL.
 READ TABLE lt_header_detail ASSIGNING FIELD-SYMBOL(<lfs_details>) INDEX 1.
  IF sy-subrc EQ 0.
   SELECT SINGLE werks lgort FROM vepo
           INTO (lv_werks, lv_lgort)
           WHERE venum EQ <lfs_details>-venum.
    IF sy-subrc EQ 0.
      cs_phu-werks = lv_werks.
      cs_phu-lgort = lv_lgort.
    ENDIF.
   ELSE.
*--Get plant & stor.loc from single HU which in
     SELECT SINGLE werks lgort FROM vepo
           INTO (lv_werks, lv_lgort)
           WHERE venum EQ ls_vekp-venum.
    IF sy-subrc EQ 0.
      cs_phu-werks = lv_werks.
      cs_phu-lgort = lv_lgort.
    ENDIF.
   ENDIF.
   REFRESH :lt_header_detail.
*--Fetch Material description based on Packed Materials
     SELECT matnr maktx UP TO 1 ROWS FROM makt
            INTO ls_makt
            WHERE matnr = ls_vekp-vhilm
              AND spras = lc_lang.
     ENDSELECT.
     IF sy-subrc EQ 0.
       cs_phu-maktx = ls_makt-maktx.
     CLEAR : ls_makt.
     ENDIF.

*--Fetch Storage location details
     SELECT lenum lgpla FROM lein UP TO 1 ROWS
            INTO ls_lein
            WHERE lenum = ls_vekp-exidv.
     ENDSELECT.
     IF sy-subrc EQ 0.
      cs_phu-lgpla = ls_lein-lgpla.
      CONDENSE cs_phu-lgpla.
       CLEAR : ls_lein.
     ENDIF.

  ELSE.
*--show an error message
    ev_check = abap_true.

  ENDIF.
ELSE.
*--show an error message
  ev_check = abap_true.
ENDIF.
  ENDMETHOD.
ENDCLASS.
