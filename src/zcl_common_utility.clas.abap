class ZCL_COMMON_UTILITY definition
  public
  final
  create public .

public section.

  constants GC_AUFTYP_PROCORD type AUFTYP value '40' ##NO_TEXT.
  constants GC_AUFTYP_PRODORD type AUFTYP value '10' ##NO_TEXT.
  constants GC_BBSRT_ZBM type BBSRT value 'ZBM' ##NO_TEXT.
  constants GC_BSAKZ_STO type BSAKZ value 'T' ##NO_TEXT.
  constants GC_BSTYP_PO type BSTYP value 'F' ##NO_TEXT.
  constants GC_BWART_101 type BWART value '101' ##NO_TEXT.
  constants GC_BWART_102 type BWART value '102' ##NO_TEXT.
  constants GC_BWART_261 type BWART value '261' ##NO_TEXT.
  constants GC_BWART_262 type BWART value '262' ##NO_TEXT.
  constants GC_BWART_551 type BWART value '551' ##NO_TEXT.
  constants GC_BWART_641 type BWART value '641' ##NO_TEXT.
  constants GC_BWART_642 type BWART value '642' ##NO_TEXT.
  constants GC_CHARA_ARTWORK1 type ATNAM value 'ARTWORK1' ##NO_TEXT.
  constants GC_CHARA_ARTWORK2 type ATNAM value 'ARTWORK2' ##NO_TEXT.
  constants GC_CHARA_BODY_COLOR type ATNAM value 'BODY_COLOR' ##NO_TEXT.
  constants GC_CHARA_CAPSUGEL_TYPE type ATNAM value 'CAPSUGEL_TYPE' ##NO_TEXT.
  constants GC_CHARA_CAPSULE_SIZE type ATNAM value 'CAPSULE_SIZE' ##NO_TEXT.
  constants GC_CHARA_CAP_COLOR type ATNAM value 'CAP_COLOR' ##NO_TEXT.
  constants GC_CHARA_CAP_WEIGHT_TOL type ATNAM value 'CAP_WEIGHT_TOL' ##NO_TEXT.
  constants GC_CHARA_CERTIFICATE type ATNAM value 'CERTIFICATIONS' ##NO_TEXT.
  constants GC_CHARA_COLORTYPE type ATNAM value 'COLOR_TYPE' ##NO_TEXT.
  constants GC_CHARA_COUNTRY_OF_ORIGIN type ATNAM value 'COUNTRY_OF_ORIGIN' ##NO_TEXT.
  constants GC_CHARA_CTRY_OF_ORIG type ATNAM value 'LOBM_HERKL' ##NO_TEXT.
  constants GC_CHARA_CUSTOMERNAME type ATNAM value 'CUSTOMER_NAME' ##NO_TEXT.
  constants GC_CHARA_CUSTOMERNO type ATNAM value 'CUSTOMER_NUMBER' ##NO_TEXT.
  constants GC_CHARA_GELTYPE type ATNAM value 'GEL_TYPE' ##NO_TEXT.
  constants GC_CHARA_INK1 type ATNAM value 'INK1' ##NO_TEXT.
  constants GC_CHARA_INK2 type ATNAM value 'INK2' ##NO_TEXT.
  constants GC_CHARA_LOBM_HERKL type ATNAM value 'LOBM_HERKL' ##NO_TEXT.
  constants GC_CHARA_LOSS_ON_DRYING type ATNAM value 'LOSS_ON_DRYING' ##NO_TEXT.
  constants GC_CHARA_MANUFACTURING_PLANT type ATNAM value 'MANUFACTURING_PLANT' ##NO_TEXT.
  constants GC_CHARA_MICRO type ATNAM value 'MICRO' ##NO_TEXT.
  constants GC_CHARA_OPERS_CONFIRM type ATNAM value 'OPERATIONS_CONFIRMED' ##NO_TEXT.
  constants GC_CHARA_OPER_CONFIRM type ATNAM value 'OPERATION_CONFIRMED' ##NO_TEXT.
  constants GC_CHARA_PACKAGING_KIT type ATNAM value 'PACKAGING_KIT' ##NO_TEXT.
  constants GC_CHARA_PALLETID type ATNAM value 'PALLET_ID' ##NO_TEXT.
  constants GC_CHARA_PARENT_BATCH type ATNAM value 'PARENT_BATCH' ##NO_TEXT.
  constants GC_CHARA_PIN_TREATMENT type ATNAM value 'PIN_TREATMENT' ##NO_TEXT.
  constants GC_CHARA_POLYMER_FORM type ATNAM value 'POLYMER_FORMULATION' ##NO_TEXT.
  constants GC_CHARA_PRINTTYPE type ATNAM value 'PRINT_TYPE' ##NO_TEXT.
  constants GC_CHARA_PROCESSORDER type ATNAM value 'PROCESS_ORDER' ##NO_TEXT.
  constants GC_CHARA_QI_STATUS type ATNAM value 'QUALITY_STATUS' ##NO_TEXT.
  constants GC_CHARA_QUALITY_LVL type ATNAM value 'VISUAL_QUALITY_LEVEL' ##NO_TEXT.
  constants GC_CHARA_QUALITY_STATUS type ATNAM value 'QUALITY_STATUS' ##NO_TEXT.
  constants GC_CHARA_QUANTYPE type ATNAM value 'CAP_QUALITY' ##NO_TEXT.
  constants GC_CHARA_QUAN_LEVEL type ATNAM value 'VISUAL_QUALITY_LEVEL' ##NO_TEXT.
  constants GC_CHARA_REP_SAMPLE_TRACK type ATNAM value 'REPRESENTATIVE_SAMPLE_TRACK' ##NO_TEXT.
  constants GC_CHARA_SALESORDER type ATNAM value 'SALES_ORDER' ##NO_TEXT.
  constants GC_SUBROUTE type ATNAM value 'SUBROUTING' ##NO_TEXT.
  constants GC_CHARA_SIZE_DESIGN type ATNAM value 'SIZE_DESIGN' ##NO_TEXT.
  constants GC_CHARA_SPEC_TEST type ATNAM value 'SPECIAL_TESTING' ##NO_TEXT.
  constants GC_CHARA_SURFACE_TREAT type ATNAM value 'SURFACE_TREATMENT' ##NO_TEXT.
  constants GC_CHARA_WEIGHT type ATNAM value 'WEIGHT' ##NO_TEXT.
  constants GC_CLTYPE_001 type KLASSENART value '001' ##NO_TEXT.
  constants GC_CLTYPE_023 type KLASSENART value '023' ##NO_TEXT.
  constants GC_COMMIT_WORK type CHAR01 value '1' ##NO_TEXT.
  constants GC_COMMIT_WORK_WAIT type CHAR01 value '2' ##NO_TEXT.
  constants GC_CREDIT_IND type SHKZG value 'H' ##NO_TEXT.
  constants GC_GFT_TANK_NUMBER type ATNAM value 'GFT_TANK_NUMBER' ##NO_TEXT.
  constants GC_INTSYS_CP type STRING value 'CP' ##NO_TEXT.
  constants GC_INTSYS_SAS type STRING value 'SAS' ##NO_TEXT.
  constants GC_INTSYS_SFDC type STRING value 'SFDC' ##NO_TEXT.
  constants GC_MSGTY_ABORT type MSGTY value 'A' ##NO_TEXT.
  constants GC_MSGTY_ERROR type MSGTY value 'E' ##NO_TEXT.
  constants GC_MSGTY_INFORMATION type MSGTY value 'I' ##NO_TEXT.
  constants GC_MSGTY_SUCCESS type MSGTY value 'S' ##NO_TEXT.
  constants GC_MTART_ZHIN type MTART value 'ZHIN' ##NO_TEXT.
  constants GC_MTART_ZHFG type MTART value 'ZHFG' ##NO_TEXT.
  constants GC_MTART_ZDFG type MTART value 'ZDFG' ##NO_TEXT.
  constants GC_PAKAGING_KIT_TYPE type MTART value 'ZICA' ##NO_TEXT.
  constants GC_SAMPLE_TRACK_YES type CHAR3 value 'YES' ##NO_TEXT.
  constants GC_STRGR_Z1 type STRGR value 'Z1' ##NO_TEXT.
  constants GC_STRGR_Z2 type STRGR value 'Z2' ##NO_TEXT.
  constants GC_UOM_TS type MSEHI value 'TH' ##NO_TEXT.
  constants GC_UPDMODE_DELETE type CDCHNGIND value 'D' ##NO_TEXT.
  constants GC_UPDMODE_FLD_DEL type CDCHNGIND value 'E' ##NO_TEXT.
  constants GC_UPDMODE_INSERT type CDCHNGIND value 'I' ##NO_TEXT.
  constants GC_UPDMODE_UPDATE type CDCHNGIND value 'U' ##NO_TEXT.
  constants GC_CHARA_LOBM_VFDAT type ATNAM value 'LOBM_VFDAT' ##NO_TEXT.
  constants GC_CHARA_CAPSULE_TYPE type ATNAM value 'CAPSULE_TYPE' ##NO_TEXT.
  constants GC_CP_REJ_REASON type ABGRU value 'Y0' ##NO_TEXT.
  constants GC_CHARA_ECC_NUMBER type ATNAM value 'ECC_NUMBER' ##NO_TEXT.
  constants GC_CHARA_CLOSURE_TYPE type ATNAM value 'CLOSURE_TYPE' ##NO_TEXT.
  constants GC_CHARA_COLOR_MATCH type ATNAM value 'COLOR_MATCH' ##NO_TEXT.
  constants GC_CHARA_ITEM_CLASS type ATNAM value 'ITEM_CLASS' ##NO_TEXT.
  constants GC_CHARA_ITEM_TYPE type ATNAM value 'ITEM_TYPE' ##NO_TEXT.
  constants GC_CHARA_GEL_FORMULA type ATNAM value 'GEL_FORMULA' ##NO_TEXT.
  constants GC_CHARA_GEL_COMP_CODE type ATNAM value 'GEL_COMP_CODE' ##NO_TEXT.
  constants GC_CHARA_VISUAL_MATCH_COLOR type ATNAM value 'VISUAL_MATCH_COLOR' ##NO_TEXT.
  constants GC_CHARA_COMP_EQUIVALENT type ATNAM value 'COMPOSITIONAL_EQUIVALENT' ##NO_TEXT.
  constants GC_CHARA_LEGACY_SIZE type ATNAM value 'LEGACY_SIZE' ##NO_TEXT.
  constants GC_CHARA_EEC_CD type ATNAM value 'EEC_CD' ##NO_TEXT.
  constants GC_CHARA_GEL_COMPOSITION_CODE type ATNAM value 'GEL_COMPOSITION_CODE' ##NO_TEXT.
  constants GC_CHARA_DEMAND_TYPE type ATNAM value 'DEMAND_TYPE' ##NO_TEXT.
  constants GC_CHARA_MARKET_TYPE type ATNAM value 'MARKET_TYPE' ##NO_TEXT.
  constants GC_SET_AUOM type SETNAMENEW value 'ZPTP_AUOM' ##NO_TEXT.
  constants GC_CHARA_PHARMACOPOEIA type ATNAM value 'PHARMACOPOEIA' ##NO_TEXT.
  constants GC_MAT_GRP_ZMTS type MTPOS_MARA value 'ZMTS' ##NO_TEXT.
  constants GC_MAT_GRP_ZMTO type MTPOS_MARA value 'ZMTO' ##NO_TEXT.
  constants GC_MAT_GRP_ZHTN type MTPOS_MARA value 'ZHTN' ##NO_TEXT.
  constants GC_MAT_GRP_ZHMO type MTPOS_MARA value 'ZHMO' ##NO_TEXT.
  constants GC_SAS_STOCK type CHAR10 value 'FG STOCK' ##NO_TEXT.
  constants GC_SAS_CUSTOM type CHAR10 value 'FG CUSTOM' ##NO_TEXT.
  constants GC_CHARA_MACHINE_TYPE type ATNAM value 'MACHINE_TYPE' ##NO_TEXT.
  constants GC_SUBROUTING type ATNAM value 'SUBROUTING' ##NO_TEXT.
  constants GC_CHARA_WEIGHT_C type ATNAM value 'WEIGHT_C' ##NO_TEXT.

  class-methods CONVERT_MATERIAL_UNIT
    importing
      !IV_MATNR type MATNR
      !IV_UNIT type VRKME
      !IV_QUAN type BSTMG
    exporting
      !EV_UNIT type VRKME
      !EV_QUAN type BSTMG
      !EV_SUBRC type SYSUBRC .
  class-methods CURR_DECIMAL_FORMATTING
    importing
      !IV_AMOUNT type ZD_CURR_DECIMAL_FOUR
    exporting
      !EV_AMOUNT type STRING .
  class-methods MATNR_CHAR_READ
    importing
      !IV_MATNR type MATNR
      !IV_KLART type KLASSENART
    exporting
      !ET_CLOBJDAT type ZTTOTC_CLOBJDAT
      !ET_CLASSIFICATION type ZTTOTC_CLASSIFICATION .
  class-methods CMIR_READ
    importing
      !IV_VKORG type VKORG optional
      value(IV_KUNAG) type KUNAG
      value(IV_KUNNR) type KUNWE optional
      value(IV_CMIR) type ZD_CMIR
      value(IV_MATNR) type MATNR optional
      value(IV_DATE) type ZD_BEGDA
    exporting
      value(ES_CMIR) type ZTOTC_CMIS
      value(EV_RETURN) type BAPI_MTYPE .
  class-methods PROTEAN_MAPPING_MAT
    importing
      value(IV_BISMT) type BISMT
    exporting
      value(EV_MATNR) type MATNR
      value(EV_RETURN) type BAPI_MTYPE .
  class-methods PROTEAN_MAPPING_BATCH
    importing
      value(IV_LOT) type ZD_LOT
      value(IV_SUBLOT) type ZD_SUBLOT
    changing
      value(EV_MATNR) type MATNR
      value(EV_CHARG) type CHARG_D
      value(EV_RETURN) type BOOLEAN .
  class-methods PARAMETER_READ
    importing
      !IV_NAME type RVARI_VNAM
      !IV_TYPE type RSSCR_KIND
    exporting
      !ET_TVARVC type RSELOPTION
      !EV_RETURN type BAPI_MTYPE .
  class-methods DATE_TIME_CONVERT_TIMEZONE
    importing
      !IV_DATE type E_EDMDATEFROM default SY-DATUM
      !IV_TIME type E_EDMTIMEFROM default SY-UZEIT
      !IV_SALES_ORG type VKORG optional
      !IV_PLANT type WERKS_D optional
      !IV_FLAG type BOOLEAN default SPACE
    exporting
      !EV_DATE type E_EDMDATEFROM
      !EV_TIME type E_EDMTIMEFROM .
  class-methods BATCH_CHAR_READ
    importing
      !IS_BATCH type ZSOTC_BATCH
    exporting
      !ES_CLASSIFICATION type ZSOTC_CLASSIFICATION
      !ET_CLOBJDAT type ZTTOTC_CLOBJDAT .
  class-methods COMMIT_WORK
    importing
      !IV_OPTION type CHAR01 default ABAP_FALSE .
  class-methods BATCH_CHAR_ADD
    importing
      !IS_BATCH type ZSOTC_BATCH
      !IT_VALUESNUM type TT_BAPI1003_ALLOC_VALUES_NUM optional
      !IT_VALUESCHAR type TT_BAPI1003_ALLOC_VALUES_CHAR optional
      !IT_VALUESCURR type TT_BAPI1003_ALLOC_VALUES_CURR optional
      !IV_SAVE_OPTION type CHAR01 default ABAP_FALSE
    returning
      value(RV_RESULT) type BOOLEAN .
  class-methods BATCH_CHAR_UPDATE
    importing
      !IS_BATCH type ZSOTC_BATCH
      !IT_VALUESNUM type TT_BAPI1003_ALLOC_VALUES_NUM optional
      !IT_VALUESCHAR type TT_BAPI1003_ALLOC_VALUES_CHAR optional
      !IT_VALUESCURR type TT_BAPI1003_ALLOC_VALUES_CURR optional
    exporting
      !ET_RETURN type BAPIRET2_T .
  class-methods ITEMS_CALCULATE
    changing
      !CT_DEL_ITEMS type ZTPTP_DEL_ITEMS .
  class-methods PLANT_VALIDATE
    importing
      !IV_PLANT type WERKS_D
    returning
      value(RV_RESULT) type BOOLEAN .
  class-methods ITEMS_CALCULATE_PACKINGSLIP
    changing
      !CT_DEL_ITEMS type ZTPTP_DEL_ITEMS_PACKINGSLIP
      !CT_TO_DFSC type ZTPTP_DFS_CARTONS .
  class-methods CONVERT_MATERIAL_UNIT_PACKSLIP
    importing
      value(IV_MATNR) type MATNR
      !IV_UNIT type VRKME
      value(IV_QUAN) type BSTMG
    exporting
      value(EV_UNIT) type VRKME
      value(EV_QUAN) type BSTMG
      value(EV_SUBRC) type SYSUBRC .
  class-methods CUSTOM_MAT_FROM_KDMAT
    importing
      !IV_VKORG type VKORG
      !IV_AUART type AUART
      value(IV_KUNAG) type KUNAG
      value(IV_KUNNR) type KUNWE optional
      value(IV_CMIR) type ZD_CMIR
      value(IV_MATNR) type MATNR optional
      value(IV_DATE) type ZD_BEGDA
    exporting
      value(ES_CMIR) type ZTOTC_CMIS
      value(EV_RETURN) type BAPI_MTYPE .
  class-methods WAREHOUSE_VALIDATE
    importing
      !IV_WAREHOUSE type LGNUM
    returning
      value(RV_RESULT) type BOOLEAN .
  class-methods STATUS_READ .
  class-methods STATUS_CHANGE
    importing
      !IV_OBJNR type J_OBJNR
      !IV_FLAG type XFELD
      !IT_STATUS type ZTTOTC_JSTAT
    exporting
      !EV_RETURN type BAPI_MTYPE .
protected section.
private section.

  constants GC_OBTAB_MARA type TABELLE value 'MARA' ##NO_TEXT.
  data GT_BATCH type ZTTPTP_BATCH_MAP .
ENDCLASS.



CLASS ZCL_COMMON_UTILITY IMPLEMENTATION.


METHOD batch_char_add.

  DATA: lwa_class         TYPE                   zsotc_classification,
        lwa_valuesnum     TYPE LINE OF           tt_bapi1003_alloc_values_num,
        lwa_valueschar    TYPE LINE OF           tt_bapi1003_alloc_values_char,
        lwa_valuescurr    TYPE LINE OF           tt_bapi1003_alloc_values_curr,
        lv_dummy          TYPE                   bapi_msg,
        lit_return        TYPE                   bapiret2_t.

  FIELD-SYMBOLS: <fs_return>  TYPE bapiret2.



  rv_result = abap_false.

  CALL METHOD zcl_common_utility=>batch_char_read
    EXPORTING
      is_batch          = is_batch
    IMPORTING
      es_classification = lwa_class.

  IF lwa_class IS INITIAL.
    MESSAGE e239(zits) WITH is_batch-charg INTO lv_dummy.
    RETURN.
  ENDIF.

*Adding the inputed numeric char to the existing batch numeric char
  IF it_valuesnum IS NOT INITIAL.
    LOOP AT it_valuesnum INTO lwa_valuesnum.
      READ TABLE lwa_class-valuesnum TRANSPORTING NO FIELDS WITH KEY charact = lwa_valuesnum-charact.
*if we are trying to update the values of an existing batch char
      IF sy-subrc = 0.
        MODIFY lwa_class-valuesnum FROM lwa_valuesnum INDEX sy-tabix.
      ELSE.
*if there's no existing batch char that matches with the char name we provided
        APPEND lwa_valuesnum TO lwa_class-valuesnum.
      ENDIF.
    ENDLOOP.
  ENDIF.

*Adding the inputed characteristic char to the existing batch characteristic char
  IF it_valueschar IS NOT INITIAL.
    LOOP AT it_valueschar INTO lwa_valueschar.
      READ TABLE lwa_class-valueschar TRANSPORTING NO FIELDS WITH KEY charact = lwa_valueschar-charact.
*if we are trying to update the values of an existing batch char
      IF sy-subrc = 0.
        MODIFY lwa_class-valueschar FROM lwa_valueschar INDEX sy-tabix.
      ELSE.
*if there's no existing batch char that matches with the char name we provided
        APPEND lwa_valueschar TO lwa_class-valueschar.
      ENDIF.
    ENDLOOP.
  ENDIF.

*Adding the inputed currency char to the existing batch currency char
  IF it_valuescurr IS NOT INITIAL.
    LOOP AT it_valuescurr INTO lwa_valuescurr.
      READ TABLE lwa_class-valuescurr TRANSPORTING NO FIELDS WITH KEY charact = lwa_valuescurr-charact.
*if we are trying to update the values of an existing batch char
      IF sy-subrc = 0.
        MODIFY lwa_class-valuescurr FROM lwa_valuescurr INDEX sy-tabix.
      ELSE.
*if there's no existing batch char that matches with the char name we provided
        APPEND lwa_valuescurr TO lwa_class-valuescurr.
      ENDIF.
    ENDLOOP.
  ENDIF.


  CALL METHOD zcl_common_utility=>batch_char_update
    EXPORTING
      is_batch      = is_batch
      it_valuesnum  = lwa_class-valuesnum
      it_valueschar = lwa_class-valueschar
      it_valuescurr = lwa_class-valuescurr
    IMPORTING
      et_return     = lit_return.


  IF zcl_its_utility=>conv_bapiret_to_msg( lit_return ) = abap_false.

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

  ELSE.

    CALL METHOD zcl_common_utility=>commit_work
      EXPORTING
        iv_option = iv_save_option.

    rv_result = abap_true.

  ENDIF.


ENDMETHOD.


METHOD batch_char_read.

  DATA: lv_objek          TYPE objnum,
        lv_obtab          TYPE tabelle,
        lv_klart          TYPE klassenart,
        lv_class          TYPE klasse_d,
        lv_status         TYPE bapi1003_key-status,
        lv_stdclass       TYPE bapi1003_key-stdclass.

  DATA: lit_valuesnum	    TYPE TABLE OF bapi1003_alloc_values_num,
        lit_valueschar    TYPE TABLE OF bapi1003_alloc_values_char,
        lit_valuescurr    TYPE TABLE OF bapi1003_alloc_values_curr,
        lit_return        TYPE TABLE OF bapiret2,
        lit_class	        TYPE TABLE OF	sclass,
        lit_objectdata    TYPE TABLE OF clobjdat.


  DATA: lwa_clobjdat      TYPE zsotc_clobjdat.

  DATA: lv_object         TYPE ausp-objek.

  FIELD-SYMBOLS:<ls_clobjdat> TYPE clobjdat.

  DATA: lv_matnr TYPE matnr,
        lv_matnr1 TYPE mara-matnr.

*This change has been created due to the mismatch of material no's length in Capsugel and Lonza system.
*Following logic will change the existing material type to the output type
    CLEAR lv_matnr1.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = is_batch-matnr
      IMPORTING
        output = lv_matnr1.
* Begin Of I- D10K9A3B44
    IF lv_matnr1 IS INITIAL.
      lv_matnr1 = is_batch-matnr.
    ENDIF.

* Convert Material Number to internal
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input  = lv_matnr1
    IMPORTING
      output = lv_matnr.

* Get class objects
  CALL FUNCTION 'VB_BATCH_2_CLASS_OBJECT'
    EXPORTING
      i_matnr = lv_matnr
      i_charg = is_batch-charg
      i_werks = is_batch-werks
    IMPORTING
      e_objek = lv_objek
      e_obtab = lv_obtab
      e_klart = lv_klart
      e_class = lv_class.

* Get Characteristic Value Description
  CALL FUNCTION 'CLAF_CLASSIFICATION_OF_OBJECTS'
    EXPORTING
      class              = lv_class
      classtype          = lv_klart
      object             = lv_objek
      objecttable        = lv_obtab
    TABLES
      t_class            = lit_class
      t_objectdata       = lit_objectdata
    EXCEPTIONS
      no_classification  = 1
      no_classtypes      = 2
      invalid_class_type = 3
      OTHERS             = 4.
  IF sy-subrc <> 0.

  ENDIF.

* Get source batch object detail
  CALL FUNCTION 'BAPI_OBJCL_GETDETAIL'
    EXPORTING
      objectkey       = lv_objek
      objecttable     = lv_obtab
      classnum        = lv_class
      classtype       = lv_klart
      keydate         = sy-datlo     "  ED2K904822 Local timezone
      language        = sy-langu
    IMPORTING
      status          = lv_status
      standardclass   = lv_stdclass
    TABLES
      allocvaluesnum  = lit_valuesnum
      allocvalueschar = lit_valueschar
      allocvaluescurr = lit_valuescurr
      return          = lit_return.

  es_classification-klart = lv_klart.
  es_classification-class = lv_class.
  APPEND LINES OF lit_valuesnum  TO es_classification-valuesnum.
  APPEND LINES OF lit_valueschar TO es_classification-valueschar.
  APPEND LINES OF lit_valuescurr TO es_classification-valuescurr.


  LOOP AT lit_objectdata ASSIGNING <ls_clobjdat>.

    MOVE-CORRESPONDING <ls_clobjdat> TO lwa_clobjdat.

    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        input        = <ls_clobjdat>-atnam
     IMPORTING
       OUTPUT        = lwa_clobjdat-atinn
              .

    APPEND lwa_clobjdat TO et_clobjdat.

  ENDLOOP.

ENDMETHOD.


METHOD batch_char_update.

  DATA: lv_objek          TYPE objnum,
        lv_obtab          TYPE tabelle,
        lv_matnr          TYPE matnr,
        lv_klart          TYPE klassenart,
        lv_class          TYPE klasse_d,
        lv_status         TYPE bapi1003_key-status,
        lv_stdclass       TYPE bapi1003_key-stdclass.

  DATA: lit_valuesnum     TYPE tt_bapi1003_alloc_values_num,
        lit_valueschar    TYPE tt_bapi1003_alloc_values_char,
        lit_valuescurr    TYPE tt_bapi1003_alloc_values_curr,
        lit_return        TYPE STANDARD TABLE OF bapiret2.


  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input  = is_batch-matnr
    IMPORTING
      output = lv_matnr.

* Get object key of target batch
  CALL FUNCTION 'VB_BATCH_2_CLASS_OBJECT'
    EXPORTING
      i_matnr = lv_matnr
      i_charg = is_batch-charg
      i_werks = is_batch-werks
    IMPORTING
      e_objek = lv_objek
      e_obtab = lv_obtab
      e_klart = lv_klart
      e_class = lv_class.

* Copy Characteristic
  APPEND LINES OF it_valuesnum  TO lit_valuesnum.
  APPEND LINES OF it_valueschar TO lit_valueschar.
  APPEND LINES OF it_valuescurr TO lit_valuescurr.

  CALL FUNCTION 'BAPI_OBJCL_CHANGE'
    EXPORTING
      objectkey          = lv_objek
      objecttable        = lv_obtab
      classnum           = lv_class
      classtype          = lv_klart
    TABLES
      allocvaluesnumnew  = lit_valuesnum
      allocvaluescharnew = lit_valueschar
      allocvaluescurrnew = lit_valuescurr
      return             = lit_return.

  et_return = lit_return.

ENDMETHOD.


  METHOD cmir_read.

    DATA: lr_matnr  TYPE RANGE OF ztotc_cmis-matnr,
          lr_cmis   TYPE RANGE OF ztotc_cmis-zzcmir,
          lwa_matnr LIKE LINE OF lr_matnr,
          lwa_cmis  LIKE LINE OF lr_cmis,
          lv_matnr  TYPE mara-matnr.

* Range for material
    IF iv_matnr IS NOT INITIAL.
      lwa_matnr-sign   = 'I'.
      lwa_matnr-option = 'EQ'.
      lwa_matnr-low    = iv_matnr.
      APPEND lwa_matnr TO lr_matnr.
    ELSE.
      IMPORT lv_matnr TO lv_matnr
      FROM MEMORY ID 'ZOTCE0178_CODE_BREAKER_MATNR'.
      IF sy-subrc EQ 0 AND lv_matnr IS NOT INITIAL.
        CLEAR lwa_matnr.
        IF lv_matnr IS NOT INITIAL.
          lwa_matnr-sign   = 'I'.
          lwa_matnr-option = 'EQ'.
          lwa_matnr-low    = lv_matnr.
          APPEND lwa_matnr TO lr_matnr.
        ENDIF.
      ENDIF.
    ENDIF.

* Range for custom material
    IF iv_cmir IS NOT INITIAL.
      lwa_cmis-sign    = 'I'.
      lwa_cmis-option  = 'EQ'.
      lwa_cmis-low     = iv_cmir.
      APPEND lwa_cmis TO lr_cmis.
    ENDIF.

* Search Strategy - find record with both sold-to/ship-to
    SELECT SINGLE *
      FROM ztotc_cmis
      INTO es_cmir
     WHERE vkorg  = iv_vkorg
*     AND vtweg  = iv_vtweg
*     AND spart  = iv_spart
       AND kunag  = iv_kunag
       AND kunnr  = iv_kunnr
       AND zzcmir IN lr_cmis
       AND matnr  IN lr_matnr
       AND zzbegda LE iv_date
       AND zzendda GE iv_date
       AND zzlevel EQ '2'.

    IF sy-subrc NE 0.
* If no records found, find record with sold-to only
      SELECT SINGLE *
        FROM ztotc_cmis
        INTO es_cmir
     WHERE vkorg  = iv_vkorg
*       AND vtweg  = iv_vtweg
*       AND spart  = iv_spart
         AND kunag  = iv_kunag
         AND zzcmir IN lr_cmis
         AND matnr  IN lr_matnr
         AND zzbegda LE iv_date
         AND zzendda GE iv_date
         AND zzlevel EQ '2'.

      IF sy-subrc NE 0.
        ev_return = abap_false.
      ELSE.
        ev_return = abap_true.
      ENDIF.

    ELSE.

      ev_return = abap_true.

    ENDIF.
  ENDMETHOD.


METHOD commit_work.

  CASE iv_option.
    WHEN gc_commit_work.      " 1
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    WHEN gc_commit_work_wait. " 2
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
    WHEN OTHERS.
  ENDCASE.

ENDMETHOD.


  METHOD convert_material_unit.

    TYPES: BEGIN OF ty_meins,
             meins TYPE meins,
           END OF ty_meins.

    DATA: lv_uom      TYPE vrkme,
          lv_auom     TYPE vrkme,
          lit_meins   TYPE TABLE OF ty_meins,
          lv_set_id   TYPE setid,
          lv_mat_type TYPE mtart,
          lt_values   TYPE TABLE OF rgsb4.

    FIELD-SYMBOLS: <ls_valus> TYPE rgsb4.

* Get Unit of Measure
    SELECT SINGLE meins
      FROM mara
      INTO lv_uom
     WHERE matnr = iv_matnr.

* Get Alternative Unit of Measure
    SELECT meinh
      FROM marm
      INTO TABLE lit_meins
     WHERE matnr = iv_matnr.

    CALL FUNCTION 'G_SET_GET_ID_FROM_NAME'
      EXPORTING
        shortname                = gc_set_auom
      IMPORTING
        new_setid                = lv_set_id
      EXCEPTIONS
        no_set_found             = 1
        no_set_picked_from_popup = 2
        wrong_class              = 3
        wrong_subclass           = 4
        table_field_not_found    = 5
        fields_dont_match        = 6
        set_is_empty             = 7
        formula_in_set           = 8
        set_is_dynamic           = 9
        OTHERS                   = 10.
    IF  sy-subrc = 0.
      CALL FUNCTION 'G_SET_GET_ALL_VALUES'
        EXPORTING
          setnr         = lv_set_id
        TABLES
          set_values    = lt_values
        EXCEPTIONS
          set_not_found = 1
          OTHERS        = 2.

      IF sy-subrc = 0.
        LOOP AT lt_values ASSIGNING <ls_valus>.
          READ TABLE lit_meins TRANSPORTING NO FIELDS WITH KEY meins = <ls_valus>-from
                                                               BINARY SEARCH.
          IF sy-subrc = 0.
            lv_auom = <ls_valus>-from.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
      EXPORTING
        i_matnr              = iv_matnr
        i_in_me              = iv_unit
        i_out_me             = lv_auom
        i_menge              = iv_quan
      IMPORTING
        e_menge              = ev_quan
      EXCEPTIONS
        error_in_application = 1
        error                = 2
        OTHERS               = 3.

    IF sy-subrc EQ 0.
      ev_quan = ceil( ev_quan ).
      ev_unit = lv_auom.
    ELSE.
      ev_subrc = 4.
    ENDIF.

  ENDMETHOD.


  method CONVERT_MATERIAL_UNIT_PACKSLIP.

  TYPES: BEGIN OF ty_meins,
           meins TYPE meins,
         END OF ty_meins.

  DATA: lv_uom           TYPE vrkme,
        lv_auom          TYPE vrkme,
        lit_meins     TYPE TABLE OF ty_meins,
        lv_set_id     TYPE setid,
        lv_mat_type   TYPE mtart,
        lt_values     TYPE TABLE OF rgsb4.

  FIELD-SYMBOLS: <ls_valus> TYPE rgsb4.

* Get Unit of Measure
  SELECT SINGLE meins
    FROM mara
    INTO lv_uom
   WHERE matnr = iv_matnr.

  SELECT meinh
    FROM marm
    INTO TABLE lit_meins
   WHERE matnr = iv_matnr.
    IF sy-subrc = 0.
      SORT lit_meins BY meins.
    ENDIF.

  CALL FUNCTION 'G_SET_GET_ID_FROM_NAME'
    EXPORTING
      shortname                = gc_set_auom
    IMPORTING
      new_setid                = lv_set_id
    EXCEPTIONS
      no_set_found             = 1
      no_set_picked_from_popup = 2
      wrong_class              = 3
      wrong_subclass           = 4
      table_field_not_found    = 5
      fields_dont_match        = 6
      set_is_empty             = 7
      formula_in_set           = 8
      set_is_dynamic           = 9
      OTHERS                   = 10.
  IF  sy-subrc = 0.
    CALL FUNCTION 'G_SET_GET_ALL_VALUES'
      EXPORTING
        setnr         = lv_set_id
      TABLES
        set_values    = lt_values
      EXCEPTIONS
        set_not_found = 1
        OTHERS        = 2.

    IF sy-subrc = 0.
      LOOP AT lt_values ASSIGNING <ls_valus>.
        READ TABLE lit_meins TRANSPORTING NO FIELDS WITH KEY meins = <ls_valus>-from
                                                             BINARY SEARCH.
        IF sy-subrc = 0.
          lv_auom = <ls_valus>-from.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      i_matnr              = iv_matnr
      i_in_me              = iv_unit
      i_out_me             = lv_auom
      i_menge              = iv_quan
    IMPORTING
      e_menge              = ev_quan
    EXCEPTIONS
      error_in_application = 1
      error                = 2
      OTHERS               = 3.

  IF sy-subrc EQ 0.
    ev_quan = ev_quan .
    ev_unit = lv_auom.
  ELSE.
    ev_subrc = 4.
  ENDIF.

  endmethod.


METHOD curr_decimal_formatting.
***********************************************************************
* AUTHOR Name:        GAOJ02
* CREATE DATE:        05/20/2015
* ECC RELEASE VERSION 6.0
* BASED-ON PROGRAM:   none
* DESCRIPTION :       Currency decimal formatting
***********************************************************************
* VERSION CONTROL (Most recent on top):
* DATE             AUTHOR       CTS REQ        DESCRIPTION
*----------------------------------------------------------------------
* 06/08/2015       Jays         ED2K905276     Correct for negtive value
* 05/12/2015       Joe          ED2K905151     Currency decimal formatting
***********************************************************************

  DATA: lv_cnt        TYPE i,        " number of decimal digit
        lv_decimal    TYPE string,   " decimal part
        lv_interger   TYPE string,   " interger part
        lv_dummy_amt  TYPE string,   " dummy string
        lv_dummy_amt2 TYPE char20,   " dummy char
        lv_sign       TYPE sybatch.  " decimal point format

  WRITE iv_amount TO lv_dummy_amt2.

  lv_dummy_amt = lv_dummy_amt2.

*Begin of add by Jays Zheng  ED2K905276  06/08/2015
  IF iv_amount < 0.
    CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
      CHANGING
        value         = lv_dummy_amt.
  ENDIF.
*End of add by Jays Zheng  ED2K905276  06/08/2015

  SHIFT lv_dummy_amt RIGHT DELETING TRAILING '0'.
  CONDENSE lv_dummy_amt.

  CALL FUNCTION 'CLSE_SELECT_USR01'
    EXPORTING
      username               = sy-uname
    IMPORTING
      decimal_sign           = lv_sign.

  SPLIT lv_dummy_amt AT lv_sign INTO lv_interger lv_decimal.

  lv_cnt = strlen( lv_decimal ).

*Begin of add by Jays Zheng  ED2K905276  06/08/2015
  IF iv_amount IS INITIAL.
    lv_interger = 0.
  ENDIF.
*End of add by Jays Zheng  ED2K905276  06/08/2015

  CASE lv_cnt.
    WHEN '0'.
      CONCATENATE lv_interger lv_sign '00' INTO ev_amount.
    WHEN '1'.
      CONCATENATE lv_dummy_amt '0' INTO ev_amount.
    WHEN OTHERS.
      ev_amount = lv_dummy_amt.
  ENDCASE.

  CONDENSE ev_amount NO-GAPS .

ENDMETHOD.


  METHOD custom_mat_from_kdmat.
    DATA: ls_cmis_ctrl  TYPE ztotc_cmis_ctrl,
          ls_cmir       TYPE ztotc_cmis,
*          lv_cmir       TYPE zd_cmir,
          lv_return     TYPE bapi_mtype,
          lt_value1     TYPE STANDARD TABLE OF zvv_param-value1,
          lt_auart_temp TYPE STANDARD TABLE OF vbak-auart,
          lt_auart      TYPE STANDARD TABLE OF vbak-auart.

    CONSTANTS:lc_zcmir_lookup TYPE zvv_param-lookup_name VALUE 'SD_ORDER_READ_ZCMIR',
              lc_coma         TYPE char1                 VALUE ',',
              lc_ordtype      TYPE zvv_param-free_key    VALUE 'AUART'.

*begin of insert : P1: EICR 559329 : rvenugopal
*    check if the data is maintained for Sales Org
    SELECT value1  FROM  zvv_param INTO TABLE lt_value1
                  WHERE  lookup_name = lc_zcmir_lookup
                    AND  vkorg = iv_vkorg
                    AND  free_key = lc_ordtype.
    IF sy-subrc EQ 0.
      LOOP AT lt_value1 ASSIGNING FIELD-SYMBOL(<ls_value1>).
        SPLIT <ls_value1> AT lc_coma INTO TABLE lt_auart_temp.
        APPEND LINES OF lt_auart_temp TO lt_auart.
        CLEAR lt_auart_temp.
      ENDLOOP.

      SORT lt_auart BY table_line.
*   Check if the ordertype is mantained for sales org
      READ TABLE lt_auart TRANSPORTING NO FIELDS
                          WITH KEY table_line = iv_auart
                          BINARY SEARCH.
      IF sy-subrc EQ 0.
*     Material Determination by new customizing ZCMIS
        CALL METHOD zcl_common_utility=>cmir_read
          EXPORTING
            iv_vkorg  = iv_vkorg
            iv_kunag  = iv_kunag
            iv_kunnr  = iv_kunnr
            iv_cmir   = Iv_cmir
            iv_matnr  = iv_matnr
            iv_date   = sy-datum
          IMPORTING
            es_cmir   = es_cmir
            ev_return = lv_return.
      ENDIF.
    ENDIF.
  ENDMETHOD.


METHOD date_time_convert_timezone.
***********************************************************************
* AUTHOR Name:        Navilesh Gowda H B
* CREATE DATE:        01/03/2019
* ECC RELEASE VERSION 7.4
* BASED-ON PROGRAM:   none
* DESCRIPTION :       Date time convert according to time zone
***********************************************************************
* VERSION CONTROL (Most recent on top):
* DATE             AUTHOR                      CTS REQ        DESCRIPTION
*----------------------------------------------------------------------
* 01/03/2019       Navilesh Gowda H B          D10K9A35SB     Date convert according
*                                              to time zone
***********************************************************************

  DATA: lv_time_zone TYPE timezone,
        lv_sev_tzone TYPE timezone,
        lv_tiemstamp TYPE timestamp.

  IF iv_flag = abap_true.

    SELECT SINGLE time_zone INTO lv_time_zone
      FROM tvko INNER JOIN adrc
      ON tvko~adrnr = adrc~addrnumber
      WHERE tvko~vkorg = iv_sales_org.

  ELSE.

    SELECT SINGLE time_zone INTO lv_time_zone
      FROM t001w INNER JOIN adrc
      ON t001w~adrnr = adrc~addrnumber
      WHERE t001w~werks = iv_plant.

  ENDIF.

  IF lv_time_zone IS NOT INITIAL.

*---Start of Change by Yanhui Yang on 20150512---
*    CALL FUNCTION 'ISU_DATE_TIME_CONVERT_TIMEZONE'
*      EXPORTING
*        x_date_utc    = iv_date
*        x_time_utc    = iv_time
*        x_timezone    = lv_time_zone
*      IMPORTING
*        y_date_lcl    = ev_date
*        y_time_lcl    = ev_time
*      EXCEPTIONS
*        general_fault = 1
*        OTHERS        = 2.
*    IF sy-subrc <> 0.
** Implement suitable error handling here
*    ENDIF.
*   Get Server time-zone
    SELECT SINGLE tzonesys
      FROM ttzcu
      INTO lv_sev_tzone.

    CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
      EXPORTING
        i_datlo     = iv_date
        i_timlo     = iv_time
        i_tzone     = lv_sev_tzone
      IMPORTING
        e_timestamp = lv_tiemstamp.


    CALL FUNCTION 'IB_CONVERT_FROM_TIMESTAMP'
      EXPORTING
        i_timestamp = lv_tiemstamp
        i_tzone     = lv_time_zone
      IMPORTING
        e_datlo     = ev_date
        e_timlo     = ev_time.

*---End of Change by Yanhui Yang on 20150512---
  ENDIF.

ENDMETHOD.


method items_calculate.

  types: begin of ty_vbuk,
         vbeln type vbeln,
         lvstk type lvstk,
         end of ty_vbuk,
         begin of ty_vbfa,
         vbelv   type vbeln_von,
         posnv   type posnr_von,
         vbeln   type vbeln_nach,
         posnn   type posnr_nach,
         vbtyp_v type vbtyp_v,
         lgnum   type lgnum,
         tanum   type tanum,
         tapos   type tapos,
         end of ty_vbfa.

  data: lit_vbuk type table of ty_vbuk,
        lit_del_items type ztptp_del_items,
        lit_vbfa type table of ty_vbfa,
        lit_ltap type ztptp_to_cartons,
        lv_index type sy-index,
        lv_auom  type vrkme,
        lv_auom_quan type bstmg,
        lv_subrc type sysubrc.

  field-symbols: <ls_del_items> type zsptp_del_items,
                 <ls_vbfa>      type ty_vbfa,
                 <ls_ltap>      type zsptp_to_cartons.

  check ct_del_items[] is not initial.

  lit_del_items[] = ct_del_items[].
  sort lit_del_items by vbeln.
  delete adjacent duplicates from lit_del_items comparing vbeln.

  if lit_del_items is not initial.
    "get Overa WM Status of delivery
    select vbeln
           lvstk
      from vbuk
      into table lit_vbuk
      for all entries in lit_del_items
      where vbeln = lit_del_items-vbeln.
    sort lit_vbuk by vbeln lvstk.
  endif.

  refresh lit_del_items.
  lit_del_items[] = ct_del_items[].
  sort lit_del_items by vbeln.

*--delete non-WM managerment delivery
  loop at lit_del_items assigning <ls_del_items>.
    read table lit_vbuk transporting no fields with key vbeln = <ls_del_items>-vbeln
                                                        lvstk = space
                                                        binary search.
    if sy-subrc = 0.
      delete lit_del_items.
    endif.
  endloop.

*--get TO of delivery
  if lit_del_items is not initial .
    select vbelv
           posnv
           vbeln
           posnn
           vbtyp_v
           lgnum
    into table lit_vbfa
    from vbfa
    for all entries in lit_del_items
    where vbelv   = lit_del_items-vbeln
      and posnv   = lit_del_items-posnr
      and vbtyp_n = 'Q'
      and vbtyp_v = 'J'.
    sort lit_vbfa by vbelv posnv.
  endif.

  if lit_vbfa is not initial.
    loop at lit_vbfa assigning <ls_vbfa>.
      <ls_vbfa>-tanum = <ls_vbfa>-vbeln.
      <ls_vbfa>-tapos = <ls_vbfa>-posnn.
    endloop.
    select tanum
           tapos
           matnr
           charg
           werks
           vlenr
           vsolm
           meins
           vltyp
           pquit
           pvqui
           vorga
      into table lit_ltap
      from ltap
      for all entries in lit_vbfa
      where tanum = lit_vbfa-tanum
        and tapos = lit_vbfa-tapos
        and lgnum = lit_vbfa-lgnum.

*--delete cancelled TO
    delete lit_ltap where ( pquit = 'X'  or pvqui = 'X' )
                      and ( vorga = 'ST'  or vorga = 'SL'  ) .
  endif.

*--calculate the items of every TO line
  call function 'ZPTP_CARTONS_CAL'
    tables
      it_to_cartons = lit_ltap.

  lv_index = 1.
  sort: ct_del_items by vbeln posnr,
        lit_vbfa by vbelv posnv,
        lit_ltap by tanum tapos.
  loop at ct_del_items assigning <ls_del_items>.

    read table lit_vbfa transporting no fields with key vbelv = <ls_del_items>-vbeln
                                                        posnv = <ls_del_items>-posnr
                                                        binary search.
    if sy-subrc = 0.
*--for devliery with TO, use items calculated from FM
      loop at lit_vbfa assigning <ls_vbfa> from lv_index where vbelv = <ls_del_items>-vbeln
                                                           and posnv = <ls_del_items>-posnr.
        lv_index = sy-tabix.
        read table lit_ltap assigning <ls_ltap> with key tanum = <ls_vbfa>-tanum
                                                         tapos = <ls_vbfa>-tapos
                                                         binary search.
        if sy-subrc = 0.
          if <ls_ltap>-vltyp = '916'."reverse TO
            <ls_del_items>-zzcarton = <ls_del_items>-zzcarton - <ls_ltap>-zzcarton.
          else.
            <ls_del_items>-zzcarton = <ls_ltap>-zzcarton + <ls_del_items>-zzcarton.
          endif.
          <ls_del_items>-meinh    = <ls_ltap>-meinh. " Alt UoM
        endif.
      endloop.

    else.
*---for delivery without TO, use AUOM to calculate items
      call method convert_material_unit
        exporting
          iv_matnr = <ls_del_items>-matnr
          iv_unit  = <ls_del_items>-vrkme
          iv_quan  = <ls_del_items>-lfimg
        importing
          ev_unit  = lv_auom
          ev_quan  = lv_auom_quan
          ev_subrc = lv_subrc.

      if lv_subrc eq 0.
        <ls_del_items>-zzcarton = lv_auom_quan.
        <ls_del_items>-meinh    = lv_auom.
*----add by Ethan 05/21/2015----Defect#1152------
*--For material without AUOM, use base UOM
      else.
        <ls_del_items>-zzcarton = <ls_del_items>-lfimg.
        <ls_del_items>-meinh    = <ls_del_items>-vrkme.
*----add by Ethan 05/21/2015----Defect#1152------
      endif.
    endif.
  endloop.

endmethod.


METHOD items_calculate_packingslip.


  CONSTANTS: c_1(1) TYPE c VALUE '1'.

  DATA : lc_para_werks TYPE char30 VALUE 'ZPTP_PLANT_DFS',
         lit_var TYPE rseloption,
         lr_werks TYPE RANGE OF werks_d,
         lv_licha TYPE mch1-licha,
         lw_ct_to_dfsc TYPE zsptp_dfs_cartons.

  FIELD-SYMBOLS :   <lw_ct_to_dfsc> TYPE zsptp_dfs_cartons.

  TYPES: BEGIN OF ty_vbuk,
         vbeln TYPE vbeln,
         lvstk TYPE lvstk,
         END OF ty_vbuk,
         BEGIN OF ty_vbfa,
         vbelv   TYPE vbeln_von,
         posnv   TYPE posnr_von,
         vbeln   TYPE vbeln_nach,
         posnn   TYPE posnr_nach,
         vbtyp_v TYPE vbtyp_v,
         lgnum   TYPE lgnum,
         tanum   TYPE tanum,
         tapos   TYPE tapos,
         END OF ty_vbfa,
        BEGIN OF ty_marm,
          matnr TYPE matnr,
          meinh TYPE lrmei,
          umrez TYPE umrez,
          record TYPE i,
        END OF ty_marm.

  DATA: lit_vbuk TYPE TABLE OF ty_vbuk,
        lit_del_items TYPE ztptp_del_items_packingslip,
        lit_vbfa TYPE TABLE OF ty_vbfa,
        lit_ltap TYPE ztptp_to_cartons_packingslip,
        lit_marm TYPE TABLE OF ty_marm,
        lv_index TYPE sy-index,
        lv_auom  TYPE vrkme,
        lv_auom_quan TYPE bstmg,
        lv_subrc TYPE sysubrc.


  FIELD-SYMBOLS:
                 <ls_del_items> TYPE zsptp_del_items_packingslip,
                 <ls_vbfa>      TYPE ty_vbfa,
                 <ls_ltap>      TYPE zsptp_to_cartons_packingslip,
                 <ls_marm> TYPE ty_marm.
  CHECK ct_del_items[] IS NOT INITIAL.

  lit_del_items[] = ct_del_items[].
  SORT lit_del_items BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lit_del_items COMPARING vbeln.

  IF lit_del_items IS NOT INITIAL.
    "get Overa WM Status of delivery
    SELECT vbeln
           lvstk
      FROM vbuk
      INTO TABLE lit_vbuk
      FOR ALL ENTRIES IN lit_del_items
      WHERE vbeln = lit_del_items-vbeln.
    SORT lit_vbuk BY vbeln lvstk.
  ENDIF.

  REFRESH lit_del_items.
  lit_del_items[] = ct_del_items[].
  SORT lit_del_items BY vbeln.

*--delete non-WM managerment delivery
  LOOP AT lit_del_items ASSIGNING <ls_del_items>.
    READ TABLE lit_vbuk TRANSPORTING NO FIELDS WITH KEY vbeln = <ls_del_items>-vbeln
                                                        lvstk = space
                                                        BINARY SEARCH.
    IF sy-subrc = 0.
      DELETE lit_del_items.
    ENDIF.
  ENDLOOP.

*--get TO of delivery
  IF lit_del_items IS NOT INITIAL .
    SELECT vbelv
           posnv
           vbeln
           posnn
           vbtyp_v
           lgnum
    INTO TABLE lit_vbfa
    FROM vbfa
    FOR ALL ENTRIES IN lit_del_items
    WHERE vbelv   = lit_del_items-vbeln
      AND posnv   = lit_del_items-posnr
      AND vbtyp_n = 'Q'
      AND vbtyp_v = 'J'.
    SORT lit_vbfa BY vbelv posnv.
  ENDIF.

  IF lit_vbfa IS NOT INITIAL.
    LOOP AT lit_vbfa ASSIGNING <ls_vbfa>.
      <ls_vbfa>-tanum = <ls_vbfa>-vbeln.
      <ls_vbfa>-tapos = <ls_vbfa>-posnn.
    ENDLOOP.
    SELECT tanum
           tapos
           matnr
           charg
           werks
           vlenr
           vsolm
           meins
           vltyp
           pquit
           pvqui
           vorga
      INTO TABLE lit_ltap
      FROM ltap
      FOR ALL ENTRIES IN lit_vbfa
      WHERE tanum = lit_vbfa-tanum
        AND tapos = lit_vbfa-tapos
        AND lgnum = lit_vbfa-lgnum.

*--delete cancelled TO
    DELETE lit_ltap WHERE ( pquit = 'X'  OR pvqui = 'X' )
                      AND ( vorga = 'ST'  OR vorga = 'SL'  ) .
  ENDIF.

*--calculate the items of every TO line
  CALL FUNCTION 'ZPTP_CARTONS_CAL_PACKINGSLIP'
    TABLES
      it_to_cartons = lit_ltap
      it_to_dfsc    = ct_to_dfsc.

  lv_index = 1.

  CLEAR lit_var.
  CALL METHOD zcl_common_utility=>parameter_read
    EXPORTING
      iv_name   = lc_para_werks
      iv_type   = 'S'
    IMPORTING
      et_tvarvc = lit_var.
  lr_werks = lit_var.
  SORT: ct_del_items BY vbeln posnr,
        lit_vbfa BY vbelv posnv,
        lit_ltap BY tanum tapos.
  LOOP AT ct_del_items ASSIGNING <ls_del_items>.

    READ TABLE lit_vbfa TRANSPORTING NO FIELDS WITH KEY vbelv = <ls_del_items>-vbeln
                                                        posnv = <ls_del_items>-posnr
                                                        BINARY SEARCH.
    IF sy-subrc = 0.
*--for devliery with TO, use items calculated from FM
      LOOP AT lit_vbfa ASSIGNING <ls_vbfa> FROM lv_index WHERE vbelv = <ls_del_items>-vbeln
                                                           AND posnv = <ls_del_items>-posnr.
        lv_index = sy-tabix.
        READ TABLE lit_ltap ASSIGNING <ls_ltap> WITH KEY tanum = <ls_vbfa>-tanum
                                                         tapos = <ls_vbfa>-tapos
                                                         BINARY SEARCH.
        IF sy-subrc = 0.
          IF <ls_ltap>-vltyp = '916'."reverse TO
            <ls_del_items>-zzcarton = <ls_del_items>-zzcarton - <ls_ltap>-zzcarton.
            <ls_del_items>-zzcartond = <ls_del_items>-zzcartond - <ls_ltap>-zzcartond.
*** If there is no source storage unit ( Pallet ID ), then consider the batch for counting number of Cartons only for DFS ( Plant - 1050 ).
          ELSEIF <ls_ltap>-vlenr IS INITIAL AND <ls_del_items>-werks IN lr_werks.
            <ls_del_items>-zzcarton = <ls_del_items>-zzcarton + c_1.
*** Get the vendot batch number based on Material and batch
            CLEAR lv_licha.
            SELECT SINGLE licha INTO lv_licha FROM mch1
                                WHERE matnr = <ls_ltap>-matnr
                                AND charg = <ls_ltap>-charg.
            IF sy-subrc = 0.
            ENDIF.
*** Update the table CT_TO_DFSC to display on the packing slip form based on Partial or full loose cartons
            IF ct_to_dfsc IS NOT INITIAL.

              CLEAR lw_ct_to_dfsc.
              READ TABLE ct_to_dfsc INTO lw_ct_to_dfsc WITH KEY menge = <ls_ltap>-vsolm
                                                                matnr = <ls_ltap>-matnr
                                                                charg = lv_licha.
              IF sy-subrc = 0.
                LOOP AT ct_to_dfsc ASSIGNING <lw_ct_to_dfsc>.
                  IF <ls_ltap>-vsolm = <lw_ct_to_dfsc>-menge AND <ls_ltap>-matnr = <lw_ct_to_dfsc>-matnr
                   AND <lw_ct_to_dfsc>-charg = lv_licha.
                    <lw_ct_to_dfsc>-cartons = <lw_ct_to_dfsc>-cartons + c_1.
                  ENDIF.
                ENDLOOP.
              ELSE.
                lw_ct_to_dfsc-matnr = <ls_ltap>-matnr.
                lw_ct_to_dfsc-charg = lv_licha.
                lw_ct_to_dfsc-menge = <ls_ltap>-vsolm.
                lw_ct_to_dfsc-cartons = c_1.
                lw_ct_to_dfsc-meins = <ls_ltap>-meins.
                APPEND lw_ct_to_dfsc TO ct_to_dfsc.
                CLEAR lw_ct_to_dfsc.
              ENDIF.
            ELSE.
              lw_ct_to_dfsc-matnr = <ls_ltap>-matnr.
              lw_ct_to_dfsc-charg = lv_licha.
              lw_ct_to_dfsc-menge = <ls_ltap>-vsolm.
              lw_ct_to_dfsc-cartons = c_1.
              lw_ct_to_dfsc-meins = <ls_ltap>-meins.
              APPEND lw_ct_to_dfsc TO ct_to_dfsc.
              CLEAR lw_ct_to_dfsc.
            ENDIF.
          ELSE.
            <ls_del_items>-zzcarton = <ls_ltap>-zzcarton + <ls_del_items>-zzcarton.
            <ls_del_items>-zzcartond = <ls_ltap>-zzcartond + <ls_del_items>-zzcartond. "No of cartons in decimals for hard capsules
          ENDIF.
          <ls_del_items>-meinh    = <ls_ltap>-meinh. " Alt UoM
          <ls_del_items>-werks    = <ls_ltap>-werks.                                   " plant to identify dfs and hard capsules in smart form layout
          <ls_del_items>-umrez    = <ls_ltap>-umrez.                                   " numerator to calculate Uom
        ENDIF.
      ENDLOOP.

    ELSEIF <ls_del_items>-werks IN lr_werks.
      <ls_del_items>-zzcarton = ''.
    ELSE.

*---for delivery without TO, use AUOM to calculate items
      CALL METHOD convert_material_unit_packslip
        EXPORTING
          iv_matnr = <ls_del_items>-matnr
          iv_unit  = <ls_del_items>-vrkme
          iv_quan  = <ls_del_items>-lfimg
        IMPORTING
          ev_unit  = lv_auom
          ev_quan  = lv_auom_quan
          ev_subrc = lv_subrc.
      IF lv_subrc EQ 0.
        <ls_del_items>-zzcarton = lv_auom_quan.
        <ls_del_items>-zzcartond = lv_auom_quan.
        <ls_del_items>-meinh    = lv_auom.
*--For material without AUOM, use base UOM
      ELSE.
        <ls_del_items>-zzcarton = <ls_del_items>-lfimg.
        <ls_del_items>-meinh    = <ls_del_items>-vrkme.
      ENDIF.
    ENDIF.
  ENDLOOP.
  SELECT matnr
         meinh
         umrez
    FROM marm
    INTO TABLE lit_marm
    FOR ALL ENTRIES IN ct_del_items
    WHERE matnr = ct_del_items-matnr
    AND meinh <> ct_del_items-meins.
  IF sy-subrc = 0.
    SORT lit_marm BY matnr meinh.
    LOOP AT ct_del_items ASSIGNING <ls_del_items>.
      READ TABLE lit_marm ASSIGNING <ls_marm> WITH KEY matnr = <ls_del_items>-matnr
                                                                       BINARY SEARCH.
      IF sy-subrc = 0.
        <ls_del_items>-umrez = <ls_marm>-umrez.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMETHOD.


  METHOD matnr_char_read.

    DATA: lit_class TYPE TABLE OF sclass,   "Class
          lit_chara TYPE TABLE OF clobjdat. "Characteristics

    DATA: lit_valuesnum	 TYPE TABLE OF bapi1003_alloc_values_num,
          lit_valueschar TYPE TABLE OF bapi1003_alloc_values_char,
          lit_valuescurr TYPE TABLE OF bapi1003_alloc_values_curr,
          lit_return     TYPE TABLE OF bapiret2.

    DATA: lwa_classification TYPE zsotc_classification,
          lwa_clobjdat       TYPE zsotc_clobjdat.

    DATA: lv_object          TYPE ausp-objek.

*  Begin - ONE - EICR 559329 - VMATHUR
    DATA: lv_matnr1     TYPE mara-matnr.
    CONSTANTS: c_x TYPE char1 VALUE 'X'.
*  end - ONE - EICR 559329 - VMATHUR
    FIELD-SYMBOLS:<ls_class> TYPE sclass,
                  <ls_chara> TYPE clobjdat.

*  Begin - ONE - EICR 559329 - VMATHUR
*This change has been created due to the mismatch of material no's length in Capsugel and Lonza system.
*Following logic will change the existing material type to the output type

    CLEAR lv_matnr1.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = iv_matnr
      IMPORTING
        output = lv_matnr1.
* Begin Of I- D10K9A3B44
    IF lv_matnr1 IS INITIAL.
      lv_matnr1 = iv_matnr.
    ENDIF.
* end Of I- D10K9A3B44
*  end - ONE - EICR 559329 - VMATHUR
* Convert Material Number to internal
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = lv_matnr1
      IMPORTING
        output       = lv_object
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.

    IF sy-subrc <> 0.
*   material conversion error
      MESSAGE e033(zone_msg)  .
    ENDIF.

* Get material class data
    CALL FUNCTION 'CLAF_CLASSIFICATION_OF_OBJECTS'
      EXPORTING
        classtype          = iv_klart
        language           = sy-langu
        object             = lv_object
*begin: code changed by vmathur EICR: 559451
        no_value_descript  = c_x

*end: code changed by vmathur EICR: 559451
        key_date           = sy-datlo "   ED2K904822 Local timezone
      TABLES
        t_class            = lit_class "no use
        t_objectdata       = lit_chara "contain material characteristics
      EXCEPTIONS
        no_classification  = 1
        no_classtypes      = 2
        invalid_class_type = 3
        OTHERS             = 4.

* Get Characteristic Detail Data
    LOOP AT lit_class ASSIGNING <ls_class>.

      CALL FUNCTION 'BAPI_OBJCL_GETDETAIL'
        EXPORTING
          objectkey       = lv_object
          objecttable     = 'MARA'
          classnum        = <ls_class>-class
          classtype       = iv_klart
          language        = 'E'
        TABLES
          allocvaluesnum  = lit_valuesnum
          allocvalueschar = lit_valueschar
          allocvaluescurr = lit_valuescurr
          return          = lit_return.

      lwa_classification-klart = <ls_class>-klart.
      lwa_classification-class = <ls_class>-class.
*   The characteristics ARTWORK1 and ARTWORK2 have new material number as their value. This has to be swapped
*   with the old material number
*      swap values - char value and char description
      READ TABLE lit_valueschar ASSIGNING FIELD-SYMBOL(<ls_valueschar>)
      WITH KEY charact = 'ARTWORK1'.
      IF sy-subrc EQ 0.
        READ TABLE lit_chara ASSIGNING <ls_chara> WITH KEY atnam = 'ARTWORK1'.
        IF sy-subrc EQ 0.
          <ls_chara>-ausp1 = <ls_valueschar>-value_char.
          <ls_valueschar>-value_char = <ls_valueschar>-value_neutral.
          <ls_valueschar>-value_neutral = <ls_chara>-ausp1.
        ENDIF.
      ENDIF.

      READ TABLE lit_valueschar ASSIGNING <ls_valueschar>
      WITH KEY charact = 'ARTWORK2'.
      IF sy-subrc EQ 0.
        READ TABLE lit_chara ASSIGNING <ls_chara> WITH KEY atnam = 'ARTWORK2'.
        IF sy-subrc EQ 0.
          <ls_chara>-ausp1 = <ls_valueschar>-value_char.
          <ls_valueschar>-value_char = <ls_valueschar>-value_neutral.
          <ls_valueschar>-value_neutral = <ls_chara>-ausp1.
        ENDIF.
      ENDIF.

      READ TABLE lit_valueschar ASSIGNING <ls_valueschar>
      WITH KEY charact = 'INK1'.
      IF sy-subrc EQ 0.
        READ TABLE lit_chara ASSIGNING <ls_chara> WITH KEY atnam = 'INK1'.
        IF sy-subrc EQ 0 .
          <ls_chara>-ausp1 = <ls_valueschar>-value_char.
          <ls_valueschar>-value_char = <ls_valueschar>-value_neutral.
          <ls_valueschar>-value_neutral = <ls_chara>-ausp1.
        ENDIF.
      ENDIF.

      READ TABLE lit_valueschar ASSIGNING <ls_valueschar>
      WITH KEY charact = 'INK2'.
      IF sy-subrc EQ 0 .
        READ TABLE lit_chara ASSIGNING <ls_chara> WITH KEY atnam = 'INK2'.
        IF sy-subrc EQ 0 .
          <ls_chara>-ausp1 = <ls_valueschar>-value_char.
          <ls_valueschar>-value_char = <ls_valueschar>-value_neutral.
          <ls_valueschar>-value_neutral = <ls_chara>-ausp1.
        ENDIF.
      ENDIF.

      APPEND LINES OF lit_valuesnum  TO lwa_classification-valuesnum.
      APPEND LINES OF lit_valueschar TO lwa_classification-valueschar.
      APPEND LINES OF lit_valuescurr TO lwa_classification-valuescurr.

      APPEND lwa_classification TO et_classification.

      REFRESH: lit_valuesnum,
               lit_valueschar,
               lit_valuescurr,
               lit_return.

      CLEAR: lwa_classification.
    ENDLOOP.

    LOOP AT lit_chara ASSIGNING <ls_chara>.

      MOVE-CORRESPONDING <ls_chara> TO lwa_clobjdat.

      CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
        EXPORTING
          input  = <ls_chara>-atnam
        IMPORTING
          output = lwa_clobjdat-atinn.

      APPEND lwa_clobjdat TO et_clobjdat.

    ENDLOOP.


  ENDMETHOD.


METHOD parameter_read.
  DATA: lt_tvarvc TYPE TABLE OF tvarvc.
  FIELD-SYMBOLS: <ls_tvarvc> TYPE rsdsselopt.

  SELECT sign
         opti
         low
         high
    FROM tvarvc
    INTO TABLE et_tvarvc
   WHERE name = iv_name
     AND type = iv_type.

  IF sy-subrc NE 0.
    ev_return = abap_false.
  ELSE.
    ev_return = abap_true.
  ENDIF.

* Add by Gordon 2015/05/07 Begin
* If option is not maintained when user maintain table Tvarvc
  IF iv_type = 'S'.
    LOOP AT et_tvarvc ASSIGNING <ls_tvarvc>.
      IF <ls_tvarvc>-sign IS INITIAL.
        <ls_tvarvc>-sign = 'I'.
      ENDIF.

      IF <ls_tvarvc>-option IS INITIAL.
        <ls_tvarvc>-option = 'EQ'.
      ENDIF.

      IF <ls_tvarvc>-low CA '*'.
        <ls_tvarvc>-option = 'CP'.
      ENDIF.
    ENDLOOP.
  ENDIF.
* Add by Gordon 2015/05/07 End
ENDMETHOD.


  METHOD plant_validate.

    DATA: ls_t001w_data TYPE t001w,
          lv_dummy      TYPE string.

    rv_result = abap_true.

    SELECT SINGLE * INTO ls_t001w_data FROM t001w WHERE werks = iv_plant.

    IF sy-subrc NE 0.
      rv_result = abap_false.
*Plant & not defined (please check your input)
      MESSAGE e003(me) WITH iv_plant INTO lv_dummy.
    ENDIF.

  ENDMETHOD.


method PROTEAN_MAPPING_BATCH.

** Fetch Batch with Lot/sublot
*  SELECT SINGLE matnr charg
*    INTO (ev_matnr, ev_charg)
*    FROM ztptp_batch
*   WHERE lot    = iv_lot
*     AND sublot = iv_sublot.
*
*  IF sy-subrc NE 0.
*    ev_return = abap_false.
*  ELSE.
*    ev_return = abap_true.
*  ENDIF.

endmethod.


METHOD protean_mapping_mat.

** Fetch SAP material by Protean resource
*  SELECT SINGLE matnr
*    FROM ztptp_material
*    INTO ev_matnr
*   WHERE bismt = iv_bismt.
*
*  IF sy-subrc NE 0.
*    ev_return = abap_false.
*  ELSE.
    ev_matnr = iv_bismt.
    ev_return = abap_true.
*  ENDIF.

ENDMETHOD.


  method STATUS_CHANGE.

    DATA: lwa_status TYPE jstat.

  IF iv_flag = 'U'. "Change user status

*   Change user status
    READ TABLE it_status INTO lwa_status INDEX 1.

    CALL FUNCTION 'STATUS_CHANGE_EXTERN'
      EXPORTING
        objnr               = iv_objnr
        user_status         = lwa_status-stat
        set_inact           = lwa_status-inact
      EXCEPTIONS
        object_not_found    = 1
        status_inconsistent = 2
        status_not_allowed  = 3
        OTHERS              = 4.

    IF sy-subrc NE 0.
      ev_return = abap_false.
    ELSE.
      ev_return = abap_true.
    ENDIF.

  ELSEIF iv_flag = 'S'. "Change system status

*   Change System status
    CALL FUNCTION 'STATUS_CHANGE_INTERN'
      EXPORTING
        objnr               = iv_objnr
      TABLES
        status              = it_status
      EXCEPTIONS
        object_not_found    = 1
        status_inconsistent = 2
        status_not_allowed  = 3
        OTHERS              = 4.

    IF sy-subrc NE 0.
      ev_return = abap_false.
    ELSE.
      ev_return = abap_true.
    ENDIF.

  ENDIF.
  endmethod.


  METHOD status_read.

***    DATA: lit_status        TYPE STANDARD TABLE OF jstat,
***          lit_system_status TYPE STANDARD TABLE OF jstat,
***          lit_user_status   TYPE STANDARD TABLE OF jstat.
***
***    DATA: lwa_status        TYPE zsits_status.
***
***    FIELD-SYMBOLS: <fs_status> TYPE jstat.
***
**** We have to refresh the status buffer before the read
***    CALL FUNCTION 'STATUS_BUFFER_REFRESH'.
***
**** Read Object System Status and User Status
***    CALL FUNCTION 'STATUS_READ'
***      EXPORTING
***        client           = sy-mandt
***        objnr            = is_key-zzobjnr
***        only_active      = is_key-zzonly_actv
***      TABLES
***        status           = lit_status
***      EXCEPTIONS
***        object_not_found = 1
***        OTHERS           = 2.
***
***    SORT lit_status BY stat.
***
**** Get System Status detail
***    IF is_key-zzonly_syst  = 'X'.
***
***      APPEND LINES OF lit_status TO lit_system_status.
***      DELETE lit_system_status WHERE stat+0(1) <> 'I'.
***
***      LOOP AT lit_system_status ASSIGNING <fs_status>.
***
***        lwa_status-stat = <fs_status>-stat.
***        lwa_status-inact = <fs_status>-inact.
***
***        SELECT SINGLE txt04 txt30
***          FROM tj02t
***          INTO (lwa_status-txt04, lwa_status-txt30)
***         WHERE istat = <fs_status>-stat
***           AND spras = sy-langu.
***
***        APPEND lwa_status TO rt_status.
***        CLEAR: lwa_status.
***
***      ENDLOOP.
***
***    ENDIF.
***
**** Get User Status detail
***    IF is_key-zzonly_user = 'X'.
***
***      APPEND LINES OF lit_status TO lit_user_status.
***      DELETE lit_user_status WHERE stat+0(1) <> 'E'.
***
***      LOOP AT lit_user_status ASSIGNING <fs_status>.
***
***        lwa_status-stat  = <fs_status>-stat.
***        lwa_status-inact = <fs_status>-inact.
***
***        SELECT SINGLE txt04 txt30
***          FROM tj30t
***          INTO (lwa_status-txt04, lwa_status-txt30)
***         WHERE stsma = is_key-zzstsma
***           AND estat = <fs_status>-stat
***           AND spras = sy-langu.
***
***        APPEND lwa_status TO rt_status.
***        CLEAR: lwa_status.
***
***      ENDLOOP.
***
***    ENDIF.
***
***    SORT rt_status BY stat.
  ENDMETHOD.


  METHOD warehouse_validate.
    DATA: ls_t300_data TYPE t300,
          lv_dummy     TYPE string.

    rv_result = abap_true.

    SELECT SINGLE * INTO ls_t300_data FROM t300 WHERE lgnum = iv_warehouse.
    IF sy-subrc NE 0.
      rv_result = abap_false.
*     Warehouse number & does not exist (new selection required)
      MESSAGE e080(l3) WITH iv_warehouse INTO lv_dummy.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
