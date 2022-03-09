class ZCL_ITS_UTILITY definition
  public
  final
  create public .

public section.
  type-pools ABAP .

  types:
    BEGIN OF ty_hu,
        typ(1) TYPE c,
        hu    TYPE zd_hu_exid,
        qty(14)   TYPE c,
        batch  TYPE charg_d,
        flag  TYPE flag,
      END OF ty_hu .
  types:
    BEGIN OF ty_batch,
       batch TYPE charg_d,
   END OF ty_batch .
  types:
    ty_hut TYPE TABLE OF ty_hu .
  types:
    ty_batcht TYPE TABLE OF ty_batch .

  constants GC_GM_TYPE_322 type BWART value '322' ##NO_TEXT.
  constants GC_GM_TYPE_344 type BWART value '344' ##NO_TEXT.
  constants GC_GM_CODE_04 type GM_CODE value '04' ##NO_TEXT.
  constants GC_MATCAT_WIP type ZD_MAT_CATEGORY value 'I' ##NO_TEXT.
  constants GC_OBJTP_FIELD type ZZSCAN_OBJTP value 'F' ##NO_TEXT.
  data GV_SCAN_CODE type ZZSCAN_CODE .
  constants GC_TRAN_AREA_IM type ZZSCAN_AREA value 'IM' ##NO_TEXT.
  constants GC_TRAN_AREA_WM type ZZSCAN_AREA value 'WM' ##NO_TEXT.
  constants GC_TRAN_AREA_NA type ZZSCAN_AREA value 'NA' ##NO_TEXT.
  constants GC_OBJID_SHIP_LANE type ZZSCAN_OBJID value '015' ##NO_TEXT.
  constants GC_OBJID_PALT_CART type ZZSCAN_OBJID value '017' ##NO_TEXT.
  constants GC_OBJID_DELIVERY type ZZSCAN_OBJID value '010' ##NO_TEXT.
  constants GC_OBJID_SLOC type ZZSCAN_OBJID value '013' ##NO_TEXT.
  constants GC_OBJID_PROC type ZZSCAN_OBJID value '009' ##NO_TEXT.
  constants GC_OBJID_PLANT type ZZSCAN_OBJID value '011' ##NO_TEXT.
  constants GC_OBJID_WAREHOUSE type ZZSCAN_OBJID value '012' ##NO_TEXT.
  constants GC_OBJID_WIP_BATCH type ZZSCAN_OBJID value '002' ##NO_TEXT.
  constants GC_OBJID_SAMPLE_BATCH type ZZSCAN_OBJID value '004' ##NO_TEXT.
  constants GC_ACTIVITY_CHANGE type ACTIV_AUTH value '02' ##NO_TEXT.
  constants GC_OBJID_LABEL type ZZSCAN_OBJID value '005' ##NO_TEXT.
  constants GC_OBJID_TO type ZZSCAN_OBJID value '023' ##NO_TEXT.
  constants GC_OBJID_INVDOC type ZZSCAN_OBJID value '024' ##NO_TEXT.
  constants GC_OBJID_USER_STATUS type ZZSCAN_OBJID value '025' ##NO_TEXT.
  constants GC_OBJID_SERIALNO type ZZSCAN_OBJID value '026' ##NO_TEXT.
  constants GC_OBJID_BATCH type ZZSCAN_OBJID value '027' ##NO_TEXT.
  constants GC_OBJID_RESOURCE type ZZSCAN_OBJID value '028' ##NO_TEXT.
  constants GC_VBTYP_TO type VBTYP value 'Q' ##NO_TEXT.
  constants GC_VBTYP_OUTB_DELIVERY type VBTYP value 'J' ##NO_TEXT.
  constants GC_DOC_STATUS_COMPLETE type STATV value 'C' ##NO_TEXT.
  constants GC_OKCODE_BACK type SY-UCOMM value 'BACK' ##NO_TEXT.
  constants GC_OKCODE_LOGOFF type SY-UCOMM value 'LOFF' ##NO_TEXT.
  constants GC_OKCODE_ADD type SY-UCOMM value 'ADD' ##NO_TEXT.
  constants GC_NEW_TRAN type TCODE value 'ZLS_EWMPICK' ##NO_TEXT.
  constants GC_SOBKZ_SALES_ORD type SOBKZ value 'E' ##NO_TEXT.
  constants GC_GM_CODE_01 type GM_CODE value '01' ##NO_TEXT.
  constants GC_GM_CODE_02 type GM_CODE value '02' ##NO_TEXT.
  constants GC_GM_CODE_03 type GM_CODE value '03' ##NO_TEXT.
  constants GC_GM_TYPE_309 type BWART value '309' ##NO_TEXT.
  constants GC_GM_TYPE_101 type BWART value '101' ##NO_TEXT.
  constants GC_GM_TYPE_102 type BWART value '102' ##NO_TEXT.
  constants GC_GM_TYPE_315 type BWART value '315' ##NO_TEXT.
  constants GC_GM_TYPE_311 type BWART value '311' ##NO_TEXT.
  constants GC_GM_TYPE_321 type BWART value '321' ##NO_TEXT.
  constants GC_GM_TYPE_325 type BWART value '325' ##NO_TEXT.
  constants GC_GM_TYPE_343 type BWART value '343' ##NO_TEXT.
  constants GC_GM_TYPE_350 type BWART value '350' ##NO_TEXT.
  constants GC_GM_TYPE_411 type BWART value '411' ##NO_TEXT.
  constants GC_GM_TYPE_455 type BWART value '455' ##NO_TEXT.
  constants GC_GM_TYPE_551 type BWART value '551' ##NO_TEXT.
  constants GC_GM_TYPE_555 type BWART value '555' ##NO_TEXT.
  constants GC_GM_TYPE_556 type BWART value '556' ##NO_TEXT.
  constants GC_GM_TYPE_521 type BWART value '521' ##NO_TEXT.
  constants GC_GM_TYPE_261 type BWART value '261' ##NO_TEXT.
  constants GC_GM_TYPE_262 type BWART value '262' ##NO_TEXT.
  constants GC_GM_TYPE_561 type BWART value '561' ##NO_TEXT.
  constants GC_GM_TYPE_919 type BWART value '919' ##NO_TEXT.
  constants GC_GM_TYPE_NON type BWART value 'NON' ##NO_TEXT.
  constants GC_GM_TYPE_999_WM type BWART value '999' ##NO_TEXT.
  constants GC_GM_TYPE_996_WM type BWART value '996' ##NO_TEXT.
  constants GC_BSART_STO type BSART value 'ZUB1' ##NO_TEXT.
  constants GC_AUTYP_ZS01 type AUFTYP value 'ZS01' ##NO_TEXT.
  constants GC_VGABE_STO_DELIVERY type VGABE value '8' ##NO_TEXT.
  constants GC_LOG_PREFIX_STO type CHAR4 value 'STO-' ##NO_TEXT.
  constants GC_LOG_PREFIX_INLINE type CHAR7 value 'INLINE-' ##NO_TEXT.
  constants GC_LOG_PREFIX_RM_MVT type CHAR4 value 'RWM-' ##NO_TEXT.
  constants GC_LOG_PREFIX_WM_SUADD type CHAR4 value '141-' ##NO_TEXT.
  constants GC_LOG_PREFIX_WM_SUCREATE type CHAR9 value 'SUCREATE-' ##NO_TEXT.
  constants GC_VBTYP_INB_DELIVERY type VBTYP value '7' ##NO_TEXT.
  constants GC_USER_STATUS_OK type J_TXT04 value 'OK' ##NO_TEXT.
  constants GC_USER_STATUS_BOTK type J_TXT04 value 'BOTK' ##NO_TEXT.
  constants GC_USER_STATUS_RCYL type J_TXT04 value 'RCYL' ##NO_TEXT.
  constants GC_USER_STATUS_SCRAP type J_TXT04 value 'SCRP' ##NO_TEXT.
  constants GC_USER_STATUS_AVL type J_TXT04 value 'AVL' ##NO_TEXT.
  constants GC_INSP_STATUS_BDINSP type J_TXT04 value 'BDIN' ##NO_TEXT.
  constants GC_USER_STATUS_VALUE_BDINSPECT type ATWRT value 'BDINSPT' ##NO_TEXT.
  constants GC_STATUS_COMPLETE type WBSTK value 'C' ##NO_TEXT.
  constants GC_OBJID_DEST_BIN type ZZSCAN_OBJID value '007' ##NO_TEXT.
  constants GC_VPOBJ_INBDLV type VPOBJ value '3' ##NO_TEXT.
  constants GC_PICK_STATUS_H type FIELDNAME value 'KOSTK' ##NO_TEXT.
  constants GC_PACK_STATUS_H type FIELDNAME value 'PKSTK' ##NO_TEXT.
  constants GC_MATERIAL_HC type ZD_BUSOPERA value 'H' ##NO_TEXT.
  constants GC_MATERIAL_DFS type ZD_BUSOPERA value 'D' ##NO_TEXT.
  constants GC_MATERIAL_MTC type ZD_BUSOPERA value 'M' ##NO_TEXT.
  constants GC_MATCAT_FG type ZD_MAT_CATEGORY value 'F' ##NO_TEXT.
  constants GC_LGTYP_SHP_LANE type LGTYP value 'SHP' ##NO_TEXT.
  constants GC_MVT_IND_FOR_ORDER type KZBEW value 'F' ##NO_TEXT.
  constants GC_LABEL_SAMPLE_BATCH type ZDITS_LABEL_TYPE value 'SAM' ##NO_TEXT.
  constants GC_LABEL_FG_BATCH type ZDITS_LABEL_TYPE value 'FG' ##NO_TEXT.
  constants GC_LABEL_RM_BATCH type ZDITS_LABEL_TYPE value 'RAW' ##NO_TEXT.
  constants GC_LABEL_RM_NOB type ZDITS_LABEL_TYPE value 'NON' ##NO_TEXT.
  constants GC_LABEL_MAT_BATCH type ZDITS_LABEL_TYPE value 'MWB' ##NO_TEXT.
  constants GC_LABEL_MAT_NOB type ZDITS_LABEL_TYPE value 'MNB' ##NO_TEXT.
  constants GC_LABEL_HU type ZDITS_LABEL_TYPE value 'PAL' ##NO_TEXT.
  constants GC_LABEL_SERIAL type ZDITS_LABEL_TYPE value 'SER' ##NO_TEXT.
  constants GC_LABEL_SU type ZDITS_LABEL_TYPE value 'SU' ##NO_TEXT.
  constants GC_STOUT_WT type LVS_LETYP value 'WT' ##NO_TEXT.
  constants GC_LOG_PREFIX_HCM_RECEIPT type CHAR8 value 'HCM_RCV-' ##NO_TEXT.
  constants GC_PROCORDER_ZWCL type CHAR4 value 'ZWCL' ##NO_TEXT.
  constants GC_LOG_PREFIX_FG_PACK type CHAR4 value 'FGP-' ##NO_TEXT.
  constants GC_ORIBATCH_SUFFIX_PO type CHAR3 value '-OR' ##NO_TEXT.
  constants GC_LOG_PREFIX_INSP_LOT type CHAR9 value 'INSP_LOT-' ##NO_TEXT.
  constants GC_LOG_PREFIX_OPERATION type CHAR4 value 'OPR-' ##NO_TEXT.
  constants GC_IN_BOOTH type ZD_BOOTH_TYPE value 'I' ##NO_TEXT.
  constants GC_RECEIVING_BOOTH type ZD_BOOTH_TYPE value 'R' ##NO_TEXT.
  constants GC_MVT_REASON_10 type MB_GRBEW value '0010' ##NO_TEXT.
  constants GC_MVT_REASON_01 type MB_GRBEW value '0001' ##NO_TEXT.
  constants GC_MVT_REASON_8 type MB_GRBEW value '0008' ##NO_TEXT.
  constants GC_LOG_PREFIX_B2B_TRANSFER type CHAR8 value 'B2B_XFE-' ##NO_TEXT.
  constants GC_TCODE_COR2 type CHAR4 value 'COR2' ##NO_TEXT.
  constants GC_MSGID_40 type CHAR2 value '40' ##NO_TEXT.
  constants GC_MSGID_CO type CHAR2 value 'CO' ##NO_TEXT.
  constants GC_MSGNR_581 type CHAR3 value '581' ##NO_TEXT.
  constants GC_TABLE_SER03 type CHAR5 value 'SER03' ##NO_TEXT.
  constants GC_OPERATION_START type ZDOPER_STATUS value '1' ##NO_TEXT.
  constants GC_OPERATION_FINISH type ZDOPER_STATUS value '2' ##NO_TEXT.
  constants GC_OPERATION_1STTANKON type ZDOPER_STATUS value '3' ##NO_TEXT.
  constants GC_OPERATION_TANKON type ZDOPER_STATUS value '4' ##NO_TEXT.
  constants GC_LOG_PREFIX_FG_ESTABLISH type CHAR4 value 'FGE-' ##NO_TEXT.
  constants GC_LOG_PREFIX_FG_SCRAP type CHAR6 value 'SCRAP-' ##NO_TEXT.
  constants GC_VAR_E0243_COSTCTR type VARIANT value 'E0243-COSTCTR' ##NO_TEXT.
  constants GC_VAR_E0166_COSTCTR type VARIANT value 'E0166-COSTCTR' ##NO_TEXT.
  constants GC_VAR_E0243_MVTREASON type VARIANT value 'E0243-REASONCD' ##NO_TEXT.
  constants GC_VAR_E0166_MVTREASON type VARIANT value 'E0166-REASONCD' ##NO_TEXT.
  constants GC_VAR_OR_BATCH_CHECK_REQUIRED type VARIANT value 'ORBATCH_CHECK' ##NO_TEXT.
  constants GC_VAR_ALLOWED_OPERA type VARIANT value 'ALLOWED_OPER' ##NO_TEXT.
  constants GC_VAR_REWORK_BATCH_IND type VARIANT value 'REWORK_BATCH' ##NO_TEXT.
  constants GC_VAR_IGNORE_MESSAGE type VARIANT value 'IGORE_MESSAGE' ##NO_TEXT.
  constants GC_VAR_996_SRC_BIN type VARIANT value '996_SRC_BIN' ##NO_TEXT.
  constants GC_VPRSV_MVAG_PRICE type VPRSV value 'V' ##NO_TEXT.
  constants GC_VPRSV_STD_PRICE type VPRSV value 'S' ##NO_TEXT.
  constants GC_PROCESS_ORDER type CHAR1 value '1' ##NO_TEXT.
  constants GC_OPERATION type CHAR1 value '2' ##NO_TEXT.
  constants GC_STORAGE_TYPE_FIN type CHAR3 value 'FIN' ##NO_TEXT.
  constants GC_POST_CHNG_COMPLETE type LUBU_STATU value 'U' ##NO_TEXT.
  constants GC_POST_CHNG_PARTIAL type LUBU_STATU value 'T' ##NO_TEXT.
  constants GC_DISPLAY_NA type CHAR3 value 'N/A' ##NO_TEXT.
  constants GC_ACC_ASSIGNMENT_M type KNTTP value 'M' ##NO_TEXT.
  constants GC_LOG_PREFIX_CHANGE_WIP_QTY type CHAR5 value 'WIPQ-' ##NO_TEXT.
  constants GC_INSPLOT_STS_OK type J_TXT04 value 'OK' ##NO_TEXT.
  constants GC_STORAGE_TYPE_LOC type LGTYP value 'LOC' ##NO_TEXT.
  constants GC_VAR_ALLOWED_QI_STATUS type VARIANT value 'QISTATUS_ALLOW' ##NO_TEXT.
  constants GC_STORAGE_TYPE_TRF type LGTYP value 'TRF' ##NO_TEXT.
  constants GC_STORAGE_BIN_TEMPSTORAG type LGPLA value 'TEMPSTORAG' ##NO_TEXT.
  constants GC_REQUIREMENT_TYPE_Z type LVS_BETYP value 'Z' ##NO_TEXT.
  constants GC_VAR_E0146_COSTCTR type VARIANT value 'E0146-COSTCTR' ##NO_TEXT.
  constants GC_E0146_TRIGGER type XFELD value 'ZITS_E0146_TRIGGER' ##NO_TEXT.
  constants GC_DOC_HEADER_VOID type BKTXT value 'VOID' ##NO_TEXT.
  constants GC_MEM_HU_LOC_UPD type CHAR20 value 'HU_LOC_UPDATE' ##NO_TEXT.
  constants GC_VAR_E0131_DEFAULT_LOC type VARIANT value 'E0131_BCH_LOC' ##NO_TEXT.
  constants GC_WRITE_LOCK type ENQMODE value 'E' ##NO_TEXT.
  constants GC_VARIANT_LOG_TYPE type VARIANT value 'REPROCESS_PRE' ##NO_TEXT.
  constants GC_DCRECV_VLTYP type LTAP_VLTYP value 'REC' ##NO_TEXT.
  constants GC_DCRECV_VLPLA type LTAP_VLPLA value 'DCREC' ##NO_TEXT.
  constants GC_STOCK_CAT_AVL type BESTQ value SPACE ##NO_TEXT.
  constants GC_STOCK_CAT_QI type BESTQ value 'Q' ##NO_TEXT.
  constants GC_STOCK_CAT_RTN type BESTQ value 'R' ##NO_TEXT.
  constants GC_STOCK_CAT_BLK type BESTQ value 'S' ##NO_TEXT.
  constants GC_LOG_PREFIX_GITPO type CHAR6 value 'GITPO-' ##NO_TEXT.
  constants GC_LOG_PREFIX_REPACK type CHAR7 value 'REPACK-' ##NO_TEXT.
  constants GC_LOG_PREFIX_HUMOVE type CHAR7 value 'HUMOVE-' ##NO_TEXT.
  constants GC_LABEL_WIP_BATCH type ZDITS_LABEL_TYPE value 'WIP' ##NO_TEXT.
  constants GC_OBJID_PALCARTON type ZZSCAN_OBJID value '017' ##NO_TEXT.
  constants GC_OBJID_TRUCK type ZZSCAN_OBJID value '018' ##NO_TEXT.
  constants GC_OBJID_MATERIAL type ZZSCAN_OBJID value '019' ##NO_TEXT.
  constants GC_OBJID_BIN type ZZSCAN_OBJID value '020' ##NO_TEXT.
  constants GC_OBJID_QUANTITY type ZZSCAN_OBJID value '014' ##NO_TEXT.
  data GT_LOG_DATA type ZTITS_SCAN_LOG_TAB .
  class-data GC_GM_TYPE_331 type BWART value '331' ##NO_TEXT.
  data GS_LOG_KEY type ZSITS_SCAN_LOG_KEY .
  data GS_LOGON_PROFILE type ZSITS_USER_PROFILE .
  constants GC_VAR_LOG_SAVE_DELAY type VARIANT value 'LOG_SAVE_DELAY' ##NO_TEXT.
  constants GC_MATCAT_ROW_MAT type ZD_MAT_CATEGORY value 'R' ##NO_TEXT.
  constants GC_OKCODE_SAVE type SY-UCOMM value 'SAVE' ##NO_TEXT.
  constants GC_OKCODE_NEWTRAN type SY-UCOMM value 'NTRA' ##NO_TEXT.
  constants GC_OBJTP_COMMAND type ZZSCAN_OBJTP value 'O' ##NO_TEXT.
  constants GC_UMVKZ type UMVKZ value '1' ##NO_TEXT.
  constants GC_UMVKN type UMVKN value '1' ##NO_TEXT.
  constants GC_CAR type ZDITS_LABEL_TYPE value 'CAR' ##NO_TEXT.

  class-methods GET_CARTONS_BY_SU
    importing
      !IS_SU_CONTENT type ZSITS_SU_CONTENT
      !IV_COUNT_ONLY type XFELD optional
    exporting
      !ET_BATCH_DATA type ZSITS_BATCH_DATA_TAB .
  class-methods POST_GOODS_MOVEMENT
    importing
      !IS_GOODS_MVT type ZSITS_GOODS_MOVEMENT
      !IV_SAVE_OPTION type CHAR01 default ABAP_FALSE
    returning
      value(RV_DOCUMENT) type MBLNR .
  class-methods POST_GOODS_MOVEMENT_DFDS
    importing
      !IS_GOODS_MVT type ZSITS_GOODS_MOVEMENT
      !IV_SAVE_OPTION type CHAR01 default ABAP_FALSE
    exporting
      value(ET_RETURN) type BAPIRET2_T
    returning
      value(RV_DOCUMENT) type MBLNR .
  class-methods MATERIAL_READ
    importing
      !IS_KEY type ZSITS_MATERIAL_READ_PARA
    returning
      value(RS_MATERIAL_DATA) type ZSITS_MATERIAL_DATA
    exceptions
      ILLEGAL_BAR_CODE
      CONVERSION_ERROR
      SYSTEM_ERROR
      NUMERIC_ERROR .
  class-methods MATERIAL_READ_DFDS
    importing
      !IS_KEY type ZSITS_MATERIAL_READ_PARA
      !IV_BATCH type CHARG_D optional
    returning
      value(RS_MATERIAL_DATA) type ZSITS_MATERIAL_DATA
    exceptions
      ILLEGAL_BAR_CODE
      CONVERSION_ERROR
      SYSTEM_ERROR
      NUMERIC_ERROR .
  class-methods AUTHORITY_CHECK_DFS
    importing
      value(IV_PLANT) type WERKS_D optional
      value(IV_WAREHOUSE) type LGNUM optional
      value(IV_MOVE_TYPE) type T156-BWART optional
    returning
      value(RV_SUBRC) type I .
  class-methods GET_USER_PROFILE
    returning
      value(RS_USER_PROFILE) type ZSITS_USER_PROFILE .
  class-methods MESSAGE_DISPLAY .
  class-methods BARCODE_READ_DFS
    importing
      !IV_BARCODE type ZD_BARCODE
      !IS_READ_OPTION type ZSITS_BATCH_READ_OPTION optional
      !IV_EXIST_CHECK type XFELD default ABAP_TRUE
      !IT_LABEL_TYPE_RANGE type ZTLABEL_TYPE_RANGE optional
      !IV_READ_10_ONLY type BOOLEAN default ABAP_FALSE
      !IV_SKIP_OR_BCH_CHECK type XFELD default ABAP_FALSE
      !IV_APPID_TYPE type T313DAITYP optional
    exporting
      !EV_LABEL_TYPE type ZDITS_LABEL_TYPE
      !ES_LABEL_CONTENT type ZSITS_LABEL_CONTENT
      !ES_MATERIAL_DATA type ZSITS_MATERIAL_DATA_DFS .
  class-methods BAR_CODE_TRANSLATION_DFS
    importing
      value(I_BAR_CODE_STRING) type STRING
      value(I_APPID_TYPE) type T313DAITYP default 'GS1'
      !I_SU_LABEL type XFELD default ABAP_FALSE
      !IV_APPID_TYPE type T313DAITYP optional
    exporting
      value(O_RETURN) type ZTITS_BARCODE_RETURN
      value(O_LABEL_TYPE) type ZDITS_LABEL_TYPE
      value(O_LABEL_CONTENT) type ZSITS_LABEL_CONTENT
    exceptions
      ILLEGAL_BAR_CODE
      CONVERSION_ERROR
      SYSTEM_ERROR
      NUMERIC_ERROR .
  class-methods BARCODE_READ
    importing
      !IV_BARCODE type ZD_BARCODE
      !IS_READ_OPTION type ZSITS_BATCH_READ_OPTION
      !IV_EXIST_CHECK type XFELD default ABAP_TRUE
      !IT_LABEL_TYPE_RANGE type ZTLABEL_TYPE_RANGE
      !IV_READ_10_ONLY type BOOLEAN default ABAP_FALSE
      !IV_SKIP_OR_BCH_CHECK type XFELD default ABAP_FALSE
    exporting
      !EV_LABEL_TYPE type ZDITS_LABEL_TYPE
      !ES_LABEL_CONTENT type ZSITS_LABEL_CONTENT .
  class-methods SU_CONTENT_READ
    importing
      !IV_SU_ID type LENUM
      !IV_LGNUM type LGNUM optional
    returning
      value(RS_SU_DATA) type ZSITS_SU_CONTENT .
  class-methods SN_READ
    importing
      !IV_SERIAL_NUMBER type ZD_SERLNO
    exporting
      !ES_EQUI type EQUI
      !ES_EQBS type EQBS .
  class-methods MATERIAL_READ_DFS
    importing
      !IS_KEY type ZSITS_MATERIAL_READ_PARA
      !IV_PLANT type WERKS_D optional
      !IV_WAREHOUSE type LGNUM optional
    returning
      value(RS_MATERIAL_DATA) type ZSITS_MATERIAL_DATA_DFS .
  class-methods ITS_VARIABLE_VALUE_GET
    importing
      !IV_VARIANT type VARIANT
      !IV_PARA1 type ANY optional
      !IV_PARA2 type ANY optional
      !IV_PARA3 type ANY optional
      !IV_PARA4 type ANY optional
    returning
      value(RT_VALUE) type ZTITS_SCAN_VAR_TAB .
  class-methods IS_SU
    importing
      !IV_SU_ID type LENUM
    returning
      value(RV_RESULT) type BOOLEAN .
  class-methods IS_ORBATCH_CHECK_REQUIRED
    importing
      !IV_TRAN_CODE type TCODE
    returning
      value(RV_RESULT) type XFELD .
  class-methods IS_LOCATION_MATCH_DFS
    importing
      !IS_BATCH_DATA type ZSITS_BATCH_DATA optional
      !IS_HU_DATA type ZSHU_CONTENT optional
      !IS_SU_DATA type ZSITS_SU_CONTENT optional
      !IV_TRANSACTION_CODE type TCODE optional
    returning
      value(RV_RESULT) type XFELD .
  class-methods IS_LOCATION_MATCH
    importing
      !IS_BATCH_DATA type ZSITS_BATCH_DATA optional
      !IS_HU_DATA type ZSHU_CONTENT optional
      !IS_SU_DATA type ZSITS_SU_CONTENT optional
      !IV_TRANSACTION_CODE type TCODE optional
    returning
      value(RV_RESULT) type XFELD .
  class-methods IS_HU_IN_INV
    importing
      !IV_HU_ID type EXIDV
    returning
      value(RV_RESULT) type BOOLEAN .
  class-methods HU_CONTENT_READ_DFS
    importing
      !IV_HU_ID type EXIDV
    returning
      value(ES_HU_CONTENT) type ZSHU_CONTENT .
  class-methods CONV_BAPIRET_TO_MSG
    importing
      !IT_BAPI_RET type BAPIRET2_T
    returning
      value(RV_NO_ERROR) type XFELD .
  class-methods BAR_CODE_TRANSLATION
    importing
      !I_BAR_CODE_STRING type STRING
      !I_APPID_TYPE type T313DAITYP default 'ZEAN128'
      !I_SU_LABEL type XFELD default ABAP_FALSE
    exporting
      !O_RETURN type ZTITS_BARCODE_RETURN
      !O_LABEL_TYPE type ZDITS_LABEL_TYPE
      !O_LABEL_CONTENT type ZSITS_LABEL_CONTENT
    exceptions
      ILLEGAL_BAR_CODE
      CONVERSION_ERROR
      SYSTEM_ERROR
      NUMERIC_ERROR .
  methods LOG_SAVE .
  methods LOG_MESSAGE_ADD
    importing
      !IV_OBJECT_TYPE type ZZSCAN_OBJTP optional
      !IV_OBJECT_ID type ZZSCAN_OBJID optional
      !IV_CONTENT type ANY
      !IV_WITH_MESSAGE type BOOLEAN optional .
  methods CONSTRUCTOR
    importing
      !IV_SCAN_CODE type ZZSCAN_CODE .
  class-methods HU_CONTENT_READ
    importing
      !IV_HU_ID type EXIDV
    returning
      value(ES_HU_CONTENT) type ZSHU_CONTENT .
  class-methods LOG_OFF
    changing
      !CO_LOG type ref to ZCL_ITS_UTILITY optional .
  class-methods LOG_OBJECT_CLEAR
    changing
      !CO_LOG type ref to ZCL_ITS_UTILITY .
  class-methods TRAN_CHECK
    importing
      !IV_SCAN_CODE type ZZSCAN_CODE
    returning
      value(RV_RESULT) type XFELD .
  class-methods LEAVE_2_NEW_TRANS
    changing
      !CO_LOG type ref to ZCL_ITS_UTILITY .
  class-methods IS_QTY_VALID
    importing
      !IV_QTY type ZD_QUAN
    returning
      value(RV_RESULT) type BOOLEAN .
  class-methods WM_INV_DOC_EXIST
    importing
      !IS_KEY type ZSITS_WM_INV_DOC
    exporting
      !EV_SU_MANAGED type BOOLEAN
      !EV_ERROR_BOOL type BOOLEAN
      !EV_STORAGE_TYPE type LGTYP .
  class-methods PHYSINV_CONTENT_OPERATION
    importing
      !IV_MODE type CHAR1
      !IV_ID type STRING optional
    changing
      !CT_CONTENT type ANY optional .
  class-methods MESSAGE_CONFIRM
    exporting
      !EV_RESULT type CHAR01 .
  class-methods PHYSINV_WM_COUNT
    importing
      !IT_LINV type ZTTITS_LINV
    returning
      value(RV_RESULT) type BOOLEAN .
  class-methods IS_PROC_ORDER_EXIST
    importing
      value(IS_SCAN_DYNP) type ZSITS_SCAN_DYNP
    returning
      value(RV_RESULT) type BOOLEAN .
  class-methods IS_HU_MANAGED_SLOC
    importing
      value(IV_LGORT) type LGORT_D
      value(IV_WERKS) type WERKS_D
    exceptions
      HU_MANAGED .
  class-methods DELIVERY_READ
    importing
      !IV_DELIVERY type ZD_OUTB_DELIVERY
      !IV_PICK_GET type BOOLEAN default ABAP_FALSE
    exporting
      !ES_DELIVERY_HEADER type ZSITS_DLV_HEADER
      !ET_PICKING_QTY type VBFA_T
      !ET_DELIVERY_ITEM type ZTTITS_DLV_ITEM .
  class-methods GET_TO_BY_OUTB_DLV
    importing
      !IS_DLV_KEY type ZSITS_DLV_KEY
    exporting
      !ES_DETAIL type ZSITS_TO_DATA .
  class-methods TO_CONFIRM
    importing
      !IS_TO_CONF type ZSITS_TO_CONF
      !IV_CONFIRM_OPTION type BOOLEAN default ABAP_TRUE
    returning
      value(RV_RESULT) type BOOLEAN .
  class-methods OUTB_DELIVERY_VALIDATE
    importing
      !IS_SCAN_DYNP type ZSITS_SCAN_DYNP
      !IV_SHIP_LANE_CHECK type XFELD default ABAP_FALSE
      !IV_PICK_COMPLETE type XFELD default ABAP_FALSE
    returning
      value(RV_RESULT) type BOOLEAN .
  class-methods DELIVERY_LOCK
    importing
      !IV_DELIVERY type ZD_OUTB_DELIVERY
    returning
      value(RV_RESULT) type BOOLEAN .
  class-methods TO_READ
    importing
      !IS_TO_KEY type ZSITS_TO_KEY
    exporting
      !EV_STORAGE_TYPE type LGTYP
    returning
      value(RS_TO_DATA) type ZSITS_TO_DATA .
  class-methods GET_DOC_STATUS
    importing
      !IV_STATUS_NAME type FIELDNAME
      !IV_CHECK_ITEM type POSNR optional
      !IV_DOC_NUM type VBELN
    returning
      value(RV_STATUS) type CHAR01 .
  class-methods IS_RES_BATCH_ALLOWED_FOR_SHIP
    importing
      !IV_WERKS type WERKS_D optional
      !IV_LGORT type LGORT_D optional
      !IS_DELIVERY type ZSITS_DLV_HEADER optional
      !IS_BATCH_DATA type ZSITS_BATCH_DATA optional
    returning
      value(RV_ALLOWED) type XFELD .
  class-methods OBJECT_STATUS_READ
    importing
      !IS_KEY type ZSITS_STATUS_KEY
    returning
      value(RT_STATUS) type ZTTITS_STATUS .
  class-methods BIN_READ
    importing
      !IS_BIN_KEY type ZSITS_BIN_KEY
    returning
      value(RS_BIN_DATA) type ZSITS_BIN_DATA .
  class-methods SET_USER_PROFILE
    importing
      !IS_USER_PROFILE type ZSITS_USER_PROFILE
    returning
      value(RV_RESULT) type BOOLEAN .
  class-methods IS_BATCH_ALLOWED_FOR_SHIP_HU
    importing
      !IV_WERKS type WERKS_D optional
      !IV_LGORT type LGORT_D optional
      !IS_DELIVERY type ZSITS_DLV_HEADER optional
      !IS_BATCH_DATA type ZSITS_BATCH_DATA optional
    returning
      value(RV_ALLOWED) type XFELD .
  class-methods GET_PICKED_TO
    importing
      !IT_TO_ITEM type ZTTITS_TO_ITEM
    exporting
      !ET_PICKED_TO type ZTTITS_PICK .
  class-methods BARCODE_READ_DFS_2
    importing
      !IV_BARCODE type ZD_BARCODE
      !IS_READ_OPTION type ZSITS_BATCH_READ_OPTION optional
      !IV_EXIST_CHECK type XFELD default ABAP_TRUE
      !IT_LABEL_TYPE_RANGE type ZTLABEL_TYPE_RANGE optional
      !IV_READ_10_ONLY type BOOLEAN default ABAP_FALSE
      !IV_SKIP_OR_BCH_CHECK type XFELD default ABAP_FALSE
      !IV_APPID_TYPE type T313DAITYP
    exporting
      !EV_LABEL_TYPE type ZDITS_LABEL_TYPE
      !ES_LABEL_CONTENT type ZSITS_LABEL_CONTENT
      !ES_MATERIAL_DATA type ZSITS_MATERIAL_DATA_DFS .
  class-methods HU_CONTENT_READ_DFS_2
    importing
      !IV_HU_ID type EXIDV
    returning
      value(ES_HU_CONTENT) type ZSHU_CONTENT .
  class-methods INB_DELIVERY_UPDATE2
    importing
      !BATCH type CHARG_D optional
      !DELIVERY type VBELN
      !POSNR type POSNR
      !IT_HU type TY_HUT optional
      !IT_BATCH type TY_BATCHT optional
    changing
      value(RETURN) type CHAR50
      value(MESSAGE) type CHAR20
    exceptions
      BATCH_FAILED
      CARTON_FAILED
      PALLET_FAILED
      BATCH_CREATE_FAILED .
  class-methods READ_BARCODE_GELATIN
    importing
      !BARCODE type STRING
      !PALLET type FLAG optional
    exporting
      value(TYPE) type CHAR3
      value(IT_HU) type TY_HUT
      value(O_LABEL_CONTENT) type ZSITS_LABEL_CONTENT
    exceptions
      ILLEGAL_BAR_CODE .
  class-methods READ_VENDOR_LABEL
    importing
      !IV_BARCODE type STRING
    exporting
      !HU_BARCODE type STRING
      !VALID_BARCODE type FLAG
      !HU_EXISTS type FLAG .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ITS_UTILITY IMPLEMENTATION.


METHOD authority_check_dfs.
************************************************************************
************************************************************************
* Program ID:                        AUTHORITY_CHECK_DFS
* Created By:                        Kripa S Patil
* Creation Date:                     29.Dec.2018
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
* 29.DEC.18   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
  DATA:lv_dummy TYPE string,
       lx_logon_profile  TYPE zsits_user_profile,
       lv_plant          TYPE werks_d,
       lv_warehouse      TYPE lgnum.

  CLEAR rv_subrc.

  IF iv_plant IS INITIAL AND iv_warehouse IS INITIAL.
*   If no Plant or warehouse passed, then get from user profile
    CALL METHOD zcl_its_utility=>get_user_profile
      RECEIVING
        rs_user_profile = lx_logon_profile.

    lv_plant     = lx_logon_profile-zzwerks.
    lv_warehouse = lx_logon_profile-zzlgnum.
  ELSE.
    lv_plant     = iv_plant.
    lv_warehouse =  iv_warehouse.
  ENDIF.

*   If only passed warehouse but no Plant, get assigned plant for warehouse from T320
  IF lv_plant IS INITIAL AND lv_warehouse IS NOT INITIAL.
    SELECT SINGLE werks INTO lv_plant
      FROM t320
      WHERE lgnum = lv_warehouse.
  ENDIF.


  AUTHORITY-CHECK OBJECT 'M_MSEG_WWA'
           ID 'ACTVT' FIELD gc_activity_change
           ID 'WERKS' FIELD lv_plant.
  IF sy-subrc <> 0.
    MESSAGE e199(ien) WITH lv_plant INTO lv_dummy.
    rv_subrc = 4.
    RETURN.
  ENDIF.

  IF iv_move_type IS NOT INITIAL.
    AUTHORITY-CHECK OBJECT 'M_MSEG_BWA'
                  ID 'ACTVT' FIELD gc_activity_change
                  ID 'BWART' FIELD iv_move_type.
    IF sy-subrc <> 0.
      MESSAGE e198(ien) WITH iv_move_type INTO lv_dummy.
      rv_subrc = 4.
    ENDIF.
  ENDIF.


ENDMETHOD.


METHOD barcode_read.
************************************************************************
************************************************************************
* Program ID:                        BARCODE_READ
* Created By:                        Kripa S Patil
* Creation Date:                     29.Dec.2018
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
* 29.DEC.18   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
  DATA: lv_label_type     TYPE zdits_label_type,
        lt_return_data    TYPE ztits_barcode_return,
        lv_lenum          TYPE lenum,
        lv_exidv          TYPE exidv,
        lv_matnr          TYPE matnr,
        lv_matnr1         TYPE matnr,
        lv_batch          TYPE charg_d,
        lv_result         TYPE boolean,
        lv_dummy          TYPE string,
        lv_barcode_string TYPE string,
        ls_read_option    TYPE zsits_batch_read_option,
        lv_unexist_check  TYPE boolean,
        lv_su_label_ind   TYPE xfeld,
        lv_batch_length   TYPE int4,
        lv_bismt          TYPE bismt,
        ls_su_content     TYPE zsits_su_content.

  FIELD-SYMBOLS: <fs_barcode_return> LIKE LINE OF lt_return_data.

* Clear all the exporing parameters:
  CLEAR: ev_label_type,  es_label_content.

  LOOP AT it_label_type_range TRANSPORTING NO FIELDS WHERE low = gc_label_su.
* Coz SU & HU share the same label type , hence we have to do the judgement base on the
* user input
* If User specify SU, we only check SU
* Otherwise we will take the label as HU
    lv_su_label_ind = abap_true.
  ENDLOOP.

* 1> Convert the EAN128 to SAP recogiziabe data
*---------------------------------------------------------------------------
  lv_barcode_string = iv_barcode.

  CALL METHOD bar_code_translation
    EXPORTING
      i_bar_code_string = lv_barcode_string
      i_su_label        = lv_su_label_ind
    IMPORTING
      o_label_type      = ev_label_type
      o_label_content   = es_label_content
    EXCEPTIONS
      illegal_bar_code  = 1
      conversion_error  = 2
      system_error      = 3
      numeric_error     = 4.

  IF sy-subrc NE 0.
* Any error during barcode translation, get error message and exit
    MESSAGE ID sy-msgid  TYPE   sy-msgty  NUMBER sy-msgno INTO lv_dummy WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    CLEAR: es_label_content,ev_label_type.
    RETURN.
  ENDIF.

* 2>  Check Label Type
*---------------------------------------------------------------------------

  IF ev_label_type NOT IN it_label_type_range.
* Label type is not allowed by this transaction
    MESSAGE e128 WITH ev_label_type INTO lv_dummy.
    CLEAR: es_label_content,ev_label_type.
    RETURN.
  ENDIF.


  IF es_label_content-zzmatnr IS NOT INITIAL.
    lv_bismt = es_label_content-zzmatnr.
    CALL METHOD zcl_common_utility=>protean_mapping_mat
      EXPORTING
        iv_bismt = lv_bismt
      IMPORTING
        ev_matnr = lv_matnr.

    IF lv_matnr IS INITIAL.

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          input  = es_label_content-zzmatnr
        IMPORTING
          output = lv_matnr.

    ENDIF.

    SELECT SINGLE matnr INTO es_label_content-zzmatnr FROM mara WHERE matnr = lv_matnr.
    IF sy-subrc NE 0.
      MESSAGE e305(m3) WITH es_label_content-zzmatnr INTO lv_dummy.
      CLEAR ev_label_type .
      RETURN.
    ENDIF.
  ENDIF.

  IF es_label_content-zzorigin_batch IS NOT INITIAL.

    CALL METHOD zcl_common_utility=>protean_mapping_batch
      EXPORTING
        iv_lot    = es_label_content-zzorigin_batch
        iv_sublot = es_label_content-zzsublot
      CHANGING
        ev_charg  = lv_batch
        ev_matnr  = lv_matnr
        ev_return = lv_result.

    IF lv_batch IS INITIAL.
      IF iv_read_10_only = abap_false.
*     For concatenate log # and sublot # in general
        CONCATENATE es_label_content-zzorigin_batch es_label_content-zzsublot INTO es_label_content-zzbatch.
        CONDENSE  es_label_content-zzbatch.
      ELSE.
*     Exclusive for E0217 (special lable: only read the batch # after identifier 10)
        es_label_content-zzbatch = es_label_content-zzorigin_batch.
      ENDIF.
      lv_batch_length = strlen( es_label_content-zzbatch ).
    ELSE.
      es_label_content-zzbatch = lv_batch.
    ENDIF.

  ENDIF.

  IF es_label_content-zzhu_exid IS NOT INITIAL.

    SELECT SINGLE exidv INTO lv_exidv FROM ztits_hu_conv WHERE zzlegacy_hu = es_label_content-zzhu_exid.  " CR 251

    IF sy-subrc NE 0.                                                                                     " CR 251

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = es_label_content-zzhu_exid
        IMPORTING
          output = lv_exidv.

      SELECT exidv INTO lv_exidv UP TO 1 ROWS FROM vekp WHERE exidv = lv_exidv.
      ENDSELECT.

    ENDIF.                                                                                                " CR 251

    IF sy-subrc EQ 0 .
      es_label_content-zzhu_exid = lv_exidv.
    ELSE.
      MESSAGE e003(hudialog) INTO lv_dummy.
      CLEAR ev_label_type.
      RETURN.
    ENDIF.
  ENDIF.

  IF es_label_content-zzlenum IS NOT INITIAL.

    SELECT SINGLE exidv INTO lv_lenum FROM ztits_hu_conv WHERE zzlegacy_hu = es_label_content-zzlenum.  " CR 251

    IF sy-subrc NE 0.                                                                                   " CR 251

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = es_label_content-zzlenum
        IMPORTING
          output = lv_lenum.

      SELECT lenum INTO lv_lenum UP TO 1 ROWS FROM lein WHERE lenum = lv_lenum.
      ENDSELECT.

      IF sy-subrc EQ 0 .
        es_label_content-zzlenum = lv_lenum.
      ELSE.
        MESSAGE e158(zits) INTO lv_dummy.
        CLEAR ev_label_type.
        RETURN.
      ENDIF.

    ENDIF.                                                                                             " CR 251

  ENDIF.

  IF iv_exist_check = abap_true.
    lv_unexist_check = abap_false.
  ELSE.
    lv_unexist_check = abap_true.
  ENDIF.

  CASE ev_label_type.
    WHEN gc_label_fg_batch.
*   Get Finish Batch Data
*     If it's an FG batch, check if its length is larger than 10.
      IF lv_batch_length GT 10.
        MESSAGE e368(zits) WITH es_label_content-zzbatch INTO lv_dummy.
        CLEAR ev_label_type.
        RETURN.
      ENDIF.

      DATA: lv_skip_or_bch_check TYPE xfeld.                                   " ED2K905509

      IF iv_skip_or_bch_check EQ abap_true OR iv_read_10_only = abap_true.     " ED2K905509
        lv_skip_or_bch_check = abap_true.                                      " ED2K905509
      ENDIF.                                                                   " ED2K905509

      es_label_content-batch_data = zcl_batch_utility=>is_fg_batch( iv_batch              = es_label_content-zzbatch
                                                                    iv_unexist_check      = lv_unexist_check
                                                                    iv_vendor_batch_check = abap_true
                                                                    is_read_option        = is_read_option
*                                                                    iv_zwcl_special       = iv_read_10_only ).       " ED2K905509
                                                                    iv_skip_or_batch_check = lv_skip_or_bch_check ).  " ED2K905509
    WHEN gc_label_wip_batch.
*   Get WIP Batch Data
*     If it's an WIP batch, check if its length is larger than 10.
      IF lv_batch_length GT 10.
        MESSAGE e368(zits) WITH es_label_content-zzbatch INTO lv_dummy.
        CLEAR ev_label_type.
        RETURN.
      ENDIF.

      es_label_content-batch_data = zcl_batch_utility=>is_wip_batch( iv_batch              = es_label_content-zzbatch
                                                                     iv_unexist_check      = lv_unexist_check
                                                                     iv_vendor_batch_check = abap_true
                                                                     is_read_option        = is_read_option ).
    WHEN gc_label_sample_batch.
*   Get Sample Batch Data
      es_label_content-batch_data = zcl_batch_utility=>is_sample_batch( iv_batch = es_label_content-zzbatch ).

    WHEN gc_label_rm_batch.
*   Get Row Materail Batch Data
      lv_matnr1 = es_label_content-zzmatnr.
      es_label_content-batch_data = zcl_batch_utility=>is_rw_batch( iv_batch         = es_label_content-zzbatch
                                                                    iv_matnr         = lv_matnr1
                                                                    iv_parent_batch  = es_label_content-zzorigin_batch
                                                                    iv_unexist_check = lv_unexist_check
                                                                    is_read_option   = is_read_option ).
    WHEN gc_label_hu.
*   Get Handling Unit Data
      es_label_content-hu_content = zcl_its_utility=>hu_content_read( iv_hu_id = lv_exidv ).

    WHEN gc_label_su.

*   Get Storage Unit Data
      es_label_content-su_content = zcl_its_utility=>su_content_read( iv_su_id = lv_lenum ).

    WHEN gc_label_serial.
*    Get serial number master
      CALL METHOD zcl_its_utility=>sn_read
        EXPORTING
          iv_serial_number = es_label_content-zzsernr
        IMPORTING
          es_equi          = es_label_content-sn_data-zzequi_data
          es_eqbs          = es_label_content-sn_data-zzeqbs_data.

  ENDCASE.

  IF ( ev_label_type EQ gc_label_fg_batch  OR
       ev_label_type EQ gc_label_wip_batch OR
       ev_label_type EQ gc_label_rm_batch OR
       ev_label_type EQ gc_label_sample_batch ) AND
       es_label_content-batch_data IS INITIAL.
    CLEAR ev_label_type.
  ENDIF.

  IF  ev_label_type EQ gc_label_hu  AND es_label_content-hu_content IS INITIAL.
    CLEAR ev_label_type.
  ENDIF.

  IF  ev_label_type EQ gc_label_su  AND es_label_content-su_content IS INITIAL.
    CLEAR ev_label_type.
  ENDIF.

  IF ev_label_type EQ gc_label_serial AND es_label_content-sn_data IS INITIAL.
    CLEAR ev_label_type.
  ENDIF.

  IF ev_label_type IS NOT  INITIAL.
    es_label_content-zzlabel_type = ev_label_type.
  ENDIF.

ENDMETHOD.


METHOD barcode_read_dfs.
************************************************************************
************************************************************************
* Program ID:                        BARCODE_READ_DFS
* Created By:                        Kripa S Patil
* Creation Date:                     29.Dec.2018
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:                       Decode barcode for US DFS roll-out.
*                                    Copy from method BARCODE_READ and make changes.
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 29.DEC.18   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*

  DATA: lv_label_type     TYPE zdits_label_type,
        lt_return_data    TYPE ztits_barcode_return,
        lv_lenum          TYPE lenum,
        lv_exidv          TYPE exidv,
        lv_matnr          TYPE matnr,
        lv_matnr1         TYPE matnr,
        lv_batch          TYPE charg_d,
        lv_result         TYPE boolean,
        lv_dummy          TYPE string,
        lv_barcode_string TYPE string,
        ls_read_option    TYPE zsits_batch_read_option,
        lv_unexist_check  TYPE boolean,
        lv_su_label_ind   TYPE xfeld,
        lv_batch_length   TYPE int4,
*Begin of insert for EICR 603155 HC-DFS II by sghosh1 03/30/2020
        lv_hu_barcode     TYPE string,
        lv_converted_hu   TYPE string,
        lv_hu_exist       TYPE flag,
        lv_valid          TYPE flag,
*End of insert for EICR 603155 HC-DFS II by sghosh1 03/30/2020
        ls_su_content     TYPE zsits_su_content,
*Begin of add for DFS roll-out by wangf on 4/1/2016
        ls_hu_item        TYPE bapihuitem,
        lv_zzbatch        TYPE zzbatch,
        lv_bismt          TYPE bismt,
        ls_key            TYPE zsits_material_read_para.
*End of add for DFS roll-out by wangf on 4/1/2016

  FIELD-SYMBOLS: <fs_barcode_return> LIKE LINE OF lt_return_data.

* Clear all the exporing parameters:
  CLEAR: ev_label_type,  es_label_content.

  LOOP AT it_label_type_range TRANSPORTING NO FIELDS WHERE low = gc_label_su.
* Coz SU & HU share the same label type , hence we have to do the judgement base on the
* user input
* If User specify SU, we only check SU
* Otherwise we will take the label as HU
    lv_su_label_ind = abap_true.
  ENDLOOP.

* 1> Convert the EAN128 to SAP recogiziabe data
*---------------------------------------------------------------------------
*Begin of insert for EICR 603155 HC-DFS II by sghosh1 03/30/2020
*  lv_barcode_string = iv_barcode.
  lv_hu_barcode = iv_barcode.
  CALL METHOD read_vendor_label
    EXPORTING
      iv_barcode    = lv_hu_barcode
    IMPORTING
      hu_barcode    = lv_converted_hu
      valid_barcode = lv_valid
      hu_exists     = lv_hu_exist.
  IF lv_valid EQ abap_true AND lv_converted_hu IS NOT INITIAL.
    lv_barcode_string = lv_converted_hu.
  ELSE.
    lv_barcode_string = iv_barcode.
  ENDIF.
*End of insert for EICR 603155 HC-DFS II by sghosh1 03/30/2020

*Begin of change for DFS roll-out by wangf on 3/31/2016
*  CALL METHOD bar_code_translation
  CALL METHOD bar_code_translation_dfs
*End of change for DFS roll-out by wangf on 3/31/2016
    EXPORTING
      i_bar_code_string = lv_barcode_string
      i_appid_type      = iv_appid_type "GS1 "RVENUGOPAL
      i_su_label        = lv_su_label_ind
    IMPORTING
      o_label_type      = ev_label_type
      o_label_content   = es_label_content
    EXCEPTIONS
      illegal_bar_code  = 1
      conversion_error  = 2
      system_error      = 3
      numeric_error     = 4.

  IF sy-subrc NE 0.
* Any error during barcode translation, get error message and exit
    MESSAGE ID sy-msgid  TYPE   sy-msgty  NUMBER sy-msgno INTO lv_dummy WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    CLEAR: es_label_content,ev_label_type.
    RETURN.
  ENDIF.

* 2>  Check Label Type
*---------------------------------------------------------------------------

  IF ev_label_type NOT IN it_label_type_range.
* Label type is not allowed by this transaction
    MESSAGE e128 WITH ev_label_type INTO lv_dummy.
    CLEAR: es_label_content,ev_label_type.
    RETURN.
  ENDIF.


  IF es_label_content-zzmatnr IS NOT INITIAL.
    CLEAR: lv_bismt.
    lv_bismt = es_label_content-zzmatnr.
    CALL METHOD zcl_common_utility=>protean_mapping_mat
      EXPORTING
        iv_bismt = lv_bismt
      IMPORTING
        ev_matnr = lv_matnr.

    IF lv_matnr IS INITIAL.

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          input  = es_label_content-zzmatnr
        IMPORTING
          output = lv_matnr.

    ENDIF.

    SELECT SINGLE matnr INTO es_label_content-zzmatnr FROM mara WHERE matnr = lv_matnr.
    IF sy-subrc NE 0.
      MESSAGE e305(m3) WITH es_label_content-zzmatnr INTO lv_dummy.
      CLEAR ev_label_type .
      RETURN.
    ENDIF.
  ENDIF.

  IF es_label_content-zzorigin_batch IS NOT INITIAL.

    CALL METHOD zcl_common_utility=>protean_mapping_batch
      EXPORTING
        iv_lot    = es_label_content-zzorigin_batch
        iv_sublot = es_label_content-zzsublot
      CHANGING
        ev_charg  = lv_batch
        ev_matnr  = lv_matnr
        ev_return = lv_result.

    IF lv_batch IS INITIAL.
      IF iv_read_10_only = abap_false.
*     For concatenate log # and sublot # in general
        CONCATENATE es_label_content-zzorigin_batch es_label_content-zzsublot INTO es_label_content-zzbatch.
        CONDENSE  es_label_content-zzbatch.
      ELSE.
*     Exclusive for E0217 (special lable: only read the batch # after identifier 10)
        es_label_content-zzbatch = es_label_content-zzorigin_batch.
      ENDIF.
      lv_batch_length = strlen( es_label_content-zzbatch ).
    ELSE.
      es_label_content-zzbatch = lv_batch.
    ENDIF.

  ENDIF.

  IF es_label_content-zzhu_exid IS NOT INITIAL.

    SELECT SINGLE exidv INTO lv_exidv FROM ztits_hu_conv WHERE zzlegacy_hu = es_label_content-zzhu_exid.  " CR 251

    IF sy-subrc NE 0.                                                                                     " CR 251

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = es_label_content-zzhu_exid
        IMPORTING
          output = lv_exidv.

      SELECT exidv INTO lv_exidv UP TO 1 ROWS FROM vekp WHERE exidv = lv_exidv.
      ENDSELECT.

    ENDIF.                                                                                                " CR 251

    IF sy-subrc EQ 0 .
      es_label_content-zzhu_exid = lv_exidv.
    ELSE.
      MESSAGE e003(hudialog) INTO lv_dummy.
      CLEAR ev_label_type.
      RETURN.
    ENDIF.
  ENDIF.

  IF es_label_content-zzlenum IS NOT INITIAL.

    SELECT SINGLE exidv INTO lv_lenum FROM ztits_hu_conv WHERE zzlegacy_hu = es_label_content-zzlenum.  " CR 251

    IF sy-subrc NE 0.                                                                                   " CR 251

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = es_label_content-zzlenum
        IMPORTING
          output = lv_lenum.

      SELECT lenum INTO lv_lenum UP TO 1 ROWS FROM lein WHERE lenum = lv_lenum.
      ENDSELECT.

      IF sy-subrc EQ 0 .
        es_label_content-zzlenum = lv_lenum.
      ELSE.
        MESSAGE e158(zits) INTO lv_dummy.
        CLEAR ev_label_type.
        RETURN.
      ENDIF.

    ENDIF.                                                                                             " CR 251

  ENDIF.

  IF iv_exist_check = abap_true.
    lv_unexist_check = abap_false.
  ELSE.
    lv_unexist_check = abap_true.
  ENDIF.

  CASE ev_label_type.
    WHEN gc_label_fg_batch.
*   Get Finish Batch Data
*     If it's an FG batch, check if its length is larger than 10.
      IF lv_batch_length GT 10.
        MESSAGE e368(zits) WITH es_label_content-zzbatch INTO lv_dummy.
        CLEAR ev_label_type.
        RETURN.
      ENDIF.

      DATA: lv_skip_or_bch_check TYPE xfeld.                                   " ED2K905509

      IF iv_skip_or_bch_check EQ abap_true OR iv_read_10_only = abap_true.     " ED2K905509
        lv_skip_or_bch_check = abap_true.                                      " ED2K905509
      ENDIF.                                                                   " ED2K905509

      es_label_content-batch_data = zcl_batch_utility=>is_fg_batch( iv_batch              = es_label_content-zzbatch
                                                                    iv_unexist_check      = lv_unexist_check
                                                                    iv_vendor_batch_check = abap_true
                                                                    is_read_option        = is_read_option
*                                                                    iv_zwcl_special       = iv_read_10_only ).       " ED2K905509
                                                                    iv_skip_or_batch_check = lv_skip_or_bch_check ).  " ED2K905509
    WHEN gc_label_wip_batch.
*   Get WIP Batch Data
*     If it's an WIP batch, check if its length is larger than 10.
      IF lv_batch_length GT 10.
        MESSAGE e368(zits) WITH es_label_content-zzbatch INTO lv_dummy.
        CLEAR ev_label_type.
        RETURN.
      ENDIF.

      es_label_content-batch_data = zcl_batch_utility=>is_wip_batch( iv_batch              = es_label_content-zzbatch
                                                                     iv_unexist_check      = lv_unexist_check
                                                                     iv_vendor_batch_check = abap_true
                                                                     is_read_option        = is_read_option ).
    WHEN gc_label_sample_batch.
*   Get Sample Batch Data
      es_label_content-batch_data = zcl_batch_utility=>is_sample_batch( iv_batch = es_label_content-zzbatch ).

    WHEN gc_label_rm_batch.
*   Get Row Materail Batch Data
      lv_matnr1 = es_label_content-zzmatnr.
      es_label_content-batch_data = zcl_batch_utility=>is_rw_batch( iv_batch         = es_label_content-zzbatch
                                                                    iv_matnr         = lv_matnr1
                                                                    iv_parent_batch  = es_label_content-zzorigin_batch
                                                                    iv_unexist_check = lv_unexist_check
                                                                    is_read_option   = is_read_option ).
    WHEN gc_label_hu.
*Begin of change for DFS roll-out by wangf on 4/1/2016
*   Get Handling Unit Data
*      es_label_content-hu_content = zcl_its_utility=>hu_content_read( iv_hu_id = lv_exidv ).

      "As SU itself is HU as well, so always read HU content as above even if it's SU
      es_label_content-hu_content = zcl_its_utility=>hu_content_read_dfs( iv_hu_id = lv_exidv ).
*End of change for DFS roll-out by wangf on 4/1/2016

*Begin of add for DFS roll-out by wangf on 3/31/2016
      IF es_label_content-hu_content-hu_content IS NOT INITIAL. "HU has packed material which is in inventory
*       Get batch status. The assumption is that there is only one material packed in the HU
        READ TABLE es_label_content-hu_content-hu_content INTO ls_hu_item INDEX 1.
        CLEAR: lv_matnr1.
        lv_zzbatch = ls_hu_item-batch.
        lv_matnr1 = es_label_content-zzmatnr.
        es_label_content-batch_data =
            zcl_batch_utility=>batch_read_dfs( iv_batch = lv_zzbatch iv_matnr = lv_matnr1 ).

*       If it's SU, then get Storage Unit Data as well
        IF is_su( iv_su_id = lv_exidv ) EQ abap_true. "Is a Storage Unit
          es_label_content-su_content = zcl_its_utility=>su_content_read( iv_su_id = lv_exidv ).
        ENDIF.
      ENDIF.
*End of add for DFS roll-out by wangf on 3/31/2016

    WHEN gc_label_su.

*   Get Storage Unit Data
      es_label_content-su_content = zcl_its_utility=>su_content_read( iv_su_id = lv_lenum ).

    WHEN gc_label_serial.
*    Get serial number master
      CALL METHOD zcl_its_utility=>sn_read
        EXPORTING
          iv_serial_number = es_label_content-zzsernr
        IMPORTING
          es_equi          = es_label_content-sn_data-zzequi_data
          es_eqbs          = es_label_content-sn_data-zzeqbs_data.

*Begin of add for DFS roll-out by wangf on 4/1/2016
    WHEN gc_label_mat_batch. "Batch magaged material
      CLEAR: lv_matnr1.
      lv_zzbatch = es_label_content-zzorigin_batch.
      lv_matnr1 =  es_label_content-zzmatnr.
      es_label_content-batch_data =
        zcl_batch_utility=>batch_read_dfs( iv_batch       = lv_zzbatch
                                           iv_matnr       = lv_matnr1
                                           is_read_option = is_read_option ).
    WHEN gc_label_mat_nob. "Non-Batch magaged material
*     Get stock for non-batch managed material
      CLEAR ls_key.
      ls_key-matnr = es_label_content-zzmatnr.
      ls_key-stock_read = 'X'.
      es_material_data = material_read_dfs( ls_key ).
*End of add for DFS roll-out by wangf on 4/1/2016
  ENDCASE.

  IF ( ev_label_type EQ gc_label_fg_batch  OR
       ev_label_type EQ gc_label_wip_batch OR
       ev_label_type EQ gc_label_rm_batch OR
       ev_label_type EQ gc_label_sample_batch ) AND
       es_label_content-batch_data IS INITIAL.
    CLEAR ev_label_type.
  ENDIF.

  IF  ev_label_type EQ gc_label_hu  AND es_label_content-hu_content IS INITIAL.
    CLEAR ev_label_type.
  ENDIF.

  IF  ev_label_type EQ gc_label_su  AND es_label_content-su_content IS INITIAL.
    CLEAR ev_label_type.
  ENDIF.

  IF ev_label_type EQ gc_label_serial AND es_label_content-sn_data IS INITIAL.
    CLEAR ev_label_type.
  ENDIF.

*Begin of add for DFS roll-out by wangf on 4/1/2016
  IF ev_label_type EQ gc_label_mat_batch AND es_label_content-batch_data IS INITIAL.
    CLEAR ev_label_type.
  ENDIF.

  IF ev_label_type EQ gc_label_mat_nob AND es_material_data IS INITIAL.
    CLEAR ev_label_type.
  ENDIF.
*End of add for DFS roll-out by wangf on 4/1/2016

  IF ev_label_type IS NOT  INITIAL.
    es_label_content-zzlabel_type = ev_label_type.
  ENDIF.

ENDMETHOD.


  METHOD barcode_read_dfs_2.
************************************************************************
************************************************************************
* Program ID:                        BARCODE_READ_DFS_2
* Created By:                        Subhashini Rawat
* Creation Date:                     12.18.2019
* Capsugel / Lonza RICEFW ID:        S101
* Description:                       Decode barcode for US DFS roll-out. (IM HU PICKING)
*                                    Copy from method BARCODE_READ and make changes.
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 12.18.2019  SRAWAT         1           D10K9A3RUB  /  Initial version
*&---------------------------------------------------------------------*

    DATA: lv_label_type     TYPE zdits_label_type,
          lt_return_data    TYPE ztits_barcode_return,
          lv_lenum          TYPE lenum,
          lv_exidv          TYPE exidv,
          lv_matnr          TYPE matnr,
          lv_matnr1         TYPE matnr,
          lv_batch          TYPE charg_d,
          lv_result         TYPE boolean,
          lv_dummy          TYPE string,
          lv_barcode_string TYPE string,
*Begin of insert for EICR 603155 HC-DFS II by sghosh1 03/30/2020
          lv_hu_barcode     TYPE string,
          lv_hu_exist       TYPE flag,
          lv_valid          TYPE flag,
*End of insert for EICR 603155 HC-DFS II by sghosh1 03/30/2020
          ls_read_option    TYPE zsits_batch_read_option,
          lv_unexist_check  TYPE boolean,
          lv_su_label_ind   TYPE xfeld,
          lv_batch_length   TYPE int4,
          ls_su_content     TYPE zsits_su_content,
*Begin of add for DFS roll-out by wangf on 4/1/2016
          ls_hu_item        TYPE bapihuitem,
          lv_zzbatch        TYPE zzbatch,
          lv_bismt          TYPE bismt,
          ls_key            TYPE zsits_material_read_para.
*End of add for DFS roll-out by wangf on 4/1/2016

    FIELD-SYMBOLS: <fs_barcode_return> LIKE LINE OF lt_return_data.

* Clear all the exporing parameters:
    CLEAR: ev_label_type,  es_label_content.

    LOOP AT it_label_type_range TRANSPORTING NO FIELDS WHERE low = gc_label_su.
* Coz SU & HU share the same label type , hence we have to do the judgement base on the
* user input
* If User specify SU, we only check SU
* Otherwise we will take the label as HU
      lv_su_label_ind = abap_true.
    ENDLOOP.

* 1> Convert the EAN128 to SAP recogiziabe data
*---------------------------------------------------------------------------
*Begin of insert for EICR 603155 HC-DFS II by sghosh1 03/30/2020
*    lv_barcode_string = iv_barcode.
    lv_hu_barcode = iv_barcode.
    CALL METHOD read_vendor_label
      EXPORTING
        iv_barcode    = lv_hu_barcode
      IMPORTING
        hu_barcode    = lv_barcode_string
        valid_barcode = lv_valid
        hu_exists     = lv_hu_exist.
    IF lv_barcode_string IS INITIAL.
      lv_barcode_string = iv_barcode.
    ENDIF.
*End of insert for EICR 603155 HC-DFS II by sghosh1 03/30/2020

*Begin of change for DFS roll-out by wangf on 3/31/2016
*  CALL METHOD bar_code_translation
    CALL METHOD bar_code_translation_dfs
*End of change for DFS roll-out by wangf on 3/31/2016
      EXPORTING
        i_bar_code_string = lv_barcode_string
        i_appid_type      = iv_appid_type "GS1 "RVENUGOPAL
        i_su_label        = lv_su_label_ind
      IMPORTING
        o_label_type      = ev_label_type
        o_label_content   = es_label_content
      EXCEPTIONS
        illegal_bar_code  = 1
        conversion_error  = 2
        system_error      = 3
        numeric_error     = 4.

    IF sy-subrc NE 0.
* Any error during barcode translation, get error message and exit
      MESSAGE ID sy-msgid  TYPE   sy-msgty  NUMBER sy-msgno INTO lv_dummy WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      CLEAR: es_label_content,ev_label_type.
      RETURN.
    ENDIF.

* 2>  Check Label Type
*---------------------------------------------------------------------------

    IF ev_label_type NOT IN it_label_type_range.
* Label type is not allowed by this transaction
      MESSAGE e128 WITH ev_label_type INTO lv_dummy.
      CLEAR: es_label_content,ev_label_type.
      RETURN.
    ENDIF.


    IF es_label_content-zzmatnr IS NOT INITIAL.
      lv_bismt = es_label_content-zzmatnr.
      CALL METHOD zcl_common_utility=>protean_mapping_mat
        EXPORTING
          iv_bismt = lv_bismt
        IMPORTING
          ev_matnr = lv_matnr.

      IF lv_matnr IS INITIAL.

        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            input  = es_label_content-zzmatnr
          IMPORTING
            output = lv_matnr.

      ENDIF.

      SELECT SINGLE matnr INTO es_label_content-zzmatnr FROM mara WHERE matnr = lv_matnr.
      IF sy-subrc NE 0.
        MESSAGE e305(m3) WITH es_label_content-zzmatnr INTO lv_dummy.
        CLEAR ev_label_type .
        RETURN.
      ENDIF.
    ENDIF.

    IF es_label_content-zzorigin_batch IS NOT INITIAL.

      CALL METHOD zcl_common_utility=>protean_mapping_batch
        EXPORTING
          iv_lot    = es_label_content-zzorigin_batch
          iv_sublot = es_label_content-zzsublot
        CHANGING
          ev_charg  = lv_batch
          ev_matnr  = lv_matnr
          ev_return = lv_result.

      IF lv_batch IS INITIAL.
        IF iv_read_10_only = abap_false.
*     For concatenate log # and sublot # in general
          CONCATENATE es_label_content-zzorigin_batch es_label_content-zzsublot INTO es_label_content-zzbatch.
          CONDENSE  es_label_content-zzbatch.
        ELSE.
*     Exclusive for E0217 (special lable: only read the batch # after identifier 10)
          es_label_content-zzbatch = es_label_content-zzorigin_batch.
        ENDIF.
        lv_batch_length = strlen( es_label_content-zzbatch ).
      ELSE.
        es_label_content-zzbatch = lv_batch.
      ENDIF.

    ENDIF.

    IF es_label_content-zzhu_exid IS NOT INITIAL.

      SELECT SINGLE exidv INTO lv_exidv FROM ztits_hu_conv WHERE zzlegacy_hu = es_label_content-zzhu_exid.  " CR 251

      IF sy-subrc NE 0.                                                                                     " CR 251

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = es_label_content-zzhu_exid
          IMPORTING
            output = lv_exidv.

        SELECT exidv INTO lv_exidv UP TO 1 ROWS FROM vekp WHERE exidv = lv_exidv.
        ENDSELECT.

      ENDIF.                                                                                                " CR 251

      IF sy-subrc EQ 0 .
        es_label_content-zzhu_exid = lv_exidv.
      ELSE.
        MESSAGE e003(hudialog) INTO lv_dummy.
        CLEAR ev_label_type.
        RETURN.
      ENDIF.
    ENDIF.

    IF es_label_content-zzlenum IS NOT INITIAL.

      SELECT SINGLE exidv INTO lv_lenum FROM ztits_hu_conv WHERE zzlegacy_hu = es_label_content-zzlenum.  " CR 251

      IF sy-subrc NE 0.                                                                                   " CR 251

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = es_label_content-zzlenum
          IMPORTING
            output = lv_lenum.

        SELECT lenum INTO lv_lenum UP TO 1 ROWS FROM lein WHERE lenum = lv_lenum.
        ENDSELECT.

        IF sy-subrc EQ 0 .
          es_label_content-zzlenum = lv_lenum.
        ELSE.
          MESSAGE e158(zits) INTO lv_dummy.
          CLEAR ev_label_type.
          RETURN.
        ENDIF.

      ENDIF.                                                                                             " CR 251

    ENDIF.

    IF iv_exist_check = abap_true.
      lv_unexist_check = abap_false.
    ELSE.
      lv_unexist_check = abap_true.
    ENDIF.

    CASE ev_label_type.
      WHEN gc_label_fg_batch.
*   Get Finish Batch Data
*     If it's an FG batch, check if its length is larger than 10.
        IF lv_batch_length GT 10.
          MESSAGE e368(zits) WITH es_label_content-zzbatch INTO lv_dummy.
          CLEAR ev_label_type.
          RETURN.
        ENDIF.

        DATA: lv_skip_or_bch_check TYPE xfeld.                                   " ED2K905509

        IF iv_skip_or_bch_check EQ abap_true OR iv_read_10_only = abap_true.     " ED2K905509
          lv_skip_or_bch_check = abap_true.                                      " ED2K905509
        ENDIF.                                                                   " ED2K905509

        es_label_content-batch_data = zcl_batch_utility=>is_fg_batch( iv_batch              = es_label_content-zzbatch
                                                                      iv_unexist_check      = lv_unexist_check
                                                                      iv_vendor_batch_check = abap_true
                                                                      is_read_option        = is_read_option
*                                                                    iv_zwcl_special       = iv_read_10_only ).       " ED2K905509
                                                                      iv_skip_or_batch_check = lv_skip_or_bch_check ).  " ED2K905509
      WHEN gc_label_wip_batch.
*   Get WIP Batch Data
*     If it's an WIP batch, check if its length is larger than 10.
        IF lv_batch_length GT 10.
          MESSAGE e368(zits) WITH es_label_content-zzbatch INTO lv_dummy.
          CLEAR ev_label_type.
          RETURN.
        ENDIF.

        es_label_content-batch_data = zcl_batch_utility=>is_wip_batch( iv_batch              = es_label_content-zzbatch
                                                                       iv_unexist_check      = lv_unexist_check
                                                                       iv_vendor_batch_check = abap_true
                                                                       is_read_option        = is_read_option ).
      WHEN gc_label_sample_batch.
*   Get Sample Batch Data
        es_label_content-batch_data = zcl_batch_utility=>is_sample_batch( iv_batch = es_label_content-zzbatch ).

      WHEN gc_label_rm_batch.
*   Get Row Materail Batch Data
        lv_matnr1 =  es_label_content-zzmatnr.
        es_label_content-batch_data = zcl_batch_utility=>is_rw_batch( iv_batch         = es_label_content-zzbatch
                                                                      iv_matnr         = lv_matnr1
                                                                      iv_parent_batch  = es_label_content-zzorigin_batch
                                                                      iv_unexist_check = lv_unexist_check
                                                                      is_read_option   = is_read_option ).
      WHEN gc_label_hu.
*Begin of change for DFS roll-out by wangf on 4/1/2016
*   Get Handling Unit Data
*      es_label_content-hu_content = zcl_its_utility=>hu_content_read( iv_hu_id = lv_exidv ).

        "As SU itself is HU as well, so always read HU content as above even if it's SU
        es_label_content-hu_content = zcl_its_utility=>hu_content_read_dfs_2( iv_hu_id = lv_exidv ).
*End of change for DFS roll-out by wangf on 4/1/2016

*Begin of add for DFS roll-out by wangf on 3/31/2016
        IF es_label_content-hu_content-hu_content IS NOT INITIAL. "HU has packed material which is in inventory
*       Get batch status. The assumption is that there is only one material packed in the HU
          READ TABLE es_label_content-hu_content-hu_content INTO ls_hu_item INDEX 1.
          lv_zzbatch = ls_hu_item-batch.
          lv_matnr1 = ls_hu_item-material.
          es_label_content-batch_data =
              zcl_batch_utility=>batch_read_dfs( iv_batch = lv_zzbatch iv_matnr = lv_matnr1 ).

*       If it's SU, then get Storage Unit Data as well
          IF is_su( iv_su_id = lv_exidv ) EQ abap_true. "Is a Storage Unit
            es_label_content-su_content = zcl_its_utility=>su_content_read( iv_su_id = lv_exidv ).
          ENDIF.
        ENDIF.
*End of add for DFS roll-out by wangf on 3/31/2016

      WHEN gc_label_su.

*   Get Storage Unit Data
        es_label_content-su_content = zcl_its_utility=>su_content_read( iv_su_id = lv_lenum ).

      WHEN gc_label_serial.
*    Get serial number master
        CALL METHOD zcl_its_utility=>sn_read
          EXPORTING
            iv_serial_number = es_label_content-zzsernr
          IMPORTING
            es_equi          = es_label_content-sn_data-zzequi_data
            es_eqbs          = es_label_content-sn_data-zzeqbs_data.

*Begin of add for DFS roll-out by wangf on 4/1/2016
      WHEN gc_label_mat_batch. "Batch magaged material
        lv_zzbatch = es_label_content-zzorigin_batch.
        lv_matnr1 = es_label_content-zzmatnr.
        es_label_content-batch_data =
          zcl_batch_utility=>batch_read_dfs( iv_batch       = lv_zzbatch
                                             iv_matnr       = lv_matnr1
                                             is_read_option = is_read_option ).
      WHEN gc_label_mat_nob. "Non-Batch magaged material
*     Get stock for non-batch managed material
        CLEAR ls_key.
        ls_key-matnr = es_label_content-zzmatnr.
        ls_key-stock_read = 'X'.
        es_material_data = material_read_dfs( ls_key ).
*End of add for DFS roll-out by wangf on 4/1/2016
    ENDCASE.

    IF ( ev_label_type EQ gc_label_fg_batch  OR
         ev_label_type EQ gc_label_wip_batch OR
         ev_label_type EQ gc_label_rm_batch OR
         ev_label_type EQ gc_label_sample_batch ) AND
         es_label_content-batch_data IS INITIAL.
      CLEAR ev_label_type.
    ENDIF.

    IF  ev_label_type EQ gc_label_hu  AND es_label_content-hu_content IS INITIAL.
      CLEAR ev_label_type.
    ENDIF.

    IF  ev_label_type EQ gc_label_su  AND es_label_content-su_content IS INITIAL.
      CLEAR ev_label_type.
    ENDIF.

    IF ev_label_type EQ gc_label_serial AND es_label_content-sn_data IS INITIAL.
      CLEAR ev_label_type.
    ENDIF.

*Begin of add for DFS roll-out by wangf on 4/1/2016
    IF ev_label_type EQ gc_label_mat_batch AND es_label_content-batch_data IS INITIAL.
      CLEAR ev_label_type.
    ENDIF.

    IF ev_label_type EQ gc_label_mat_nob AND es_material_data IS INITIAL.
      CLEAR ev_label_type.
    ENDIF.
*End of add for DFS roll-out by wangf on 4/1/2016

    IF ev_label_type IS NOT  INITIAL.
      es_label_content-zzlabel_type = ev_label_type.
    ENDIF.
  ENDMETHOD.


METHOD bar_code_translation.
************************************************************************
************************************************************************
* Program ID:                        BAR_CODE_TRANSLATION
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
  DATA: f_t313c TYPE t313c,
        f_t313g TYPE t313g.

  DATA: bar_length                    TYPE i,
        c_pos                         TYPE i VALUE 0,
        bar_data(100)                 TYPE c,
        seg_data(100)                 TYPE c,
        prefix(100)                   TYPE c,
        seg_aitype                    TYPE t313daityp,
        seg_len                       TYPE t313dailen,
        seg_del                       TYPE t313daidel,
        seg_mask                      TYPE t313damask,
        lf_ai                         TYPE t313daival,
        lf_found                      TYPE boole_d,
        lf_ai_l                       TYPE i,
        lf_rc                         TYPE i,
        lt_t313d                      TYPE TABLE OF t313d,
        lv_lenum                      TYPE lenum,
        lv_exidv                      TYPE exidv,
        lv_matnr                      TYPE matnr,
        lv_batch                      TYPE charg_d,
        lv_sublot                     TYPE zd_sublot,
        lv_su_number                  TYPE lenum,
        lv_result                     TYPE boolean.
  DATA: ls_ai_data                    TYPE t313d.
  DATA: lf_ai_add                     TYPE t313daival.
  DATA: lf_more_data                  TYPE boole_d.
  DATA: lf_ai_value                   TYPE barcode_aidata.
  DATA: lf_barcode                    TYPE barcode.
  DATA  l_oref                        TYPE REF TO cx_root.

  DATA: lv_qty_length                 TYPE int4.


  FIELD-SYMBOLS:
        <fs_t313d>                    TYPE t313d,
        <fs_barcode_return>           TYPE zsits_barcode_return.

************************************************************************

  seg_aitype = i_appid_type.

************************************************************************

  CALL FUNCTION 'LE_BARCODE_AI_READ'
    EXPORTING
      if_aityp        = seg_aitype
      if_aival        = space
      if_aisub        = 0
    IMPORTING
      es_bc_data      = f_t313g
    EXCEPTIONS
      barcode_unknown = 01
      no_ai_defined   = 02
      ai_unknown      = 03
      param_invalid   = 04
      OTHERS          = 99.

  CASE sy-subrc.

    WHEN 00.
      SELECT * FROM t313d INTO TABLE lt_t313d
        WHERE aityp = seg_aitype.
      SORT lt_t313d BY aival.

*     For testing purpose, hardcode delimitor to :
      f_t313g-aidel = ':'.
    WHEN OTHERS.
*...Bar code string is not in one of the defined formats in the system.*
      MESSAGE e130 RAISING system_error.

  ENDCASE.


  IF f_t313g-mandt IS INITIAL.
*........Error in conversion of bar code string........................*
    MESSAGE e121 WITH i_bar_code_string RAISING conversion_error.
  ENDIF.

************************************************************************

  bar_data = i_bar_code_string.
  bar_length = strlen( bar_data ).

  IF bar_length = 0.
*........Invalid bar code..............................................*
    MESSAGE e121 WITH bar_data RAISING illegal_bar_code.
  ENDIF.

  IF NOT ( f_t313g-prefix IS INITIAL ).
    c_pos = c_pos + strlen( f_t313g-prefix ).

    prefix = bar_data+0(c_pos).
    IF f_t313g-prefix <> prefix.
*........Invalid bar code..............................................*
      MESSAGE e121 WITH bar_data RAISING illegal_bar_code.
    ENDIF.

    IF c_pos > bar_length.
*........Invalid bar code..............................................*
      MESSAGE e121 WITH bar_data RAISING illegal_bar_code.
    ENDIF.

  ENDIF.

************************************************************************
*

  TRY.

      bar_length = bar_length - c_pos.
      lf_barcode = bar_data.
      WHILE  bar_length > 0.

*   Get Identifier
        CLEAR: lf_ai, lf_found, lf_rc.
        lf_ai_l = f_t313g-minle.

        WHILE ( lf_found = ' '
          AND lf_ai_l <= f_t313g-maxle
          AND lf_rc = 0 ).
*     Invalid length
          IF lf_ai_l > bar_length.
            lf_rc = 1.
          ENDIF.

          lf_ai = lf_barcode+c_pos(lf_ai_l).
          READ TABLE lt_t313d ASSIGNING <fs_t313d>
            WITH KEY aival = lf_ai
            BINARY SEARCH.
          IF sy-subrc = 0.
            lf_found = 'X'.
          ELSE.
            lf_ai_l = lf_ai_l + 1.
          ENDIF.
        ENDWHILE.

        TRY .
            CALL FUNCTION 'LE_BARCODE_AI_SCAN'
              EXPORTING
                if_barcode            = lf_barcode
                is_bc_data            = f_t313g
              IMPORTING
                ef_ai_value           = lf_ai_value
                ef_ai_add             = lf_ai_add
              CHANGING
                cs_ai_data            = ls_ai_data
                cf_bc_o               = c_pos
                cf_bc_l               = bar_length
                cf_more_data          = lf_more_data
              EXCEPTIONS
                ai_not_found          = 01
                barcode_too_short     = 02
                error_in_subfunctions = 03
                OTHERS                = 99.
          CATCH cx_sy_no_handler INTO l_oref.
*  ........Error in conversion of bar code string........................*
            MESSAGE e121 WITH i_bar_code_string RAISING conversion_error.
        ENDTRY.

        IF sy-subrc <> 0.
*........Error in conversion of bar code string........................*
          MESSAGE e121 WITH i_bar_code_string RAISING conversion_error.
        ENDIF.

*      CATCH SYSTEM-EXCEPTIONS convt_no_number = 9.
        UNPACK lf_ai_add TO seg_mask.
*      ENDCATCH.
        IF sy-subrc = 9.
*.....Cannot convert entry to number................................
          MESSAGE e134 WITH seg_mask RAISING numeric_error.
        ENDIF.

        seg_data = lf_ai_value.

        IF lf_rc = 1.
*     Unindentified AI
          MESSAGE e121 WITH bar_data RAISING illegal_bar_code.
        ELSE.
*     Append value to return table
          APPEND INITIAL LINE TO o_return ASSIGNING <fs_barcode_return>.
          <fs_barcode_return>-ai = <fs_t313d>-aival.
          <fs_barcode_return>-value = seg_data.
          IF <fs_t313d>-aifor = 'N'.
*        CATCH SYSTEM-EXCEPTIONS conversion_errors = 9.
            IF seg_data CO '1234567890 '.
              <fs_barcode_return>-quantity = seg_data.
            ENDIF.
*        ENDCATCH.
            IF sy-subrc = 9.
*  ........Cannot convert entry to number................................*
              MESSAGE e134 WITH seg_data RAISING numeric_error.
            ENDIF.
            <fs_barcode_return>-quantity =  <fs_barcode_return>-quantity / ( 10 ** seg_mask ).
*            o_label_content-zzquantity = <fs_barcode_return>-value.
          ENDIF.
        ENDIF.

        c_pos = c_pos + seg_len + strlen( seg_del ).

      ENDWHILE.

    CATCH cx_sy_conversion_no_number INTO l_oref.
      MESSAGE e121 WITH bar_data RAISING illegal_bar_code.
    CATCH  cx_sy_range_out_of_bounds INTO l_oref.
      MESSAGE e121 WITH bar_data RAISING illegal_bar_code.
  ENDTRY.



  LOOP AT o_return ASSIGNING <fs_barcode_return>.
    CASE <fs_barcode_return>-ai.
      WHEN '10'.                                "Orginal Batch
        o_label_content-zzorigin_batch = <fs_barcode_return>-value.
      WHEN '21'.
        o_label_type = gc_label_fg_batch.      "FG Carton Label
        o_label_content-zzsublot = <fs_barcode_return>-value.
      WHEN '90'.
        o_label_type = gc_label_rm_batch.      "RAW Carton label
* For row material, sublot = 000 mean this is the virtual parent batch of container batch, in such ,we should ignore 000
        IF <fs_barcode_return>-value NE zcl_batch_utility=>gc_zero_sublot.
          o_label_content-zzsublot = <fs_barcode_return>-value.
        ENDIF.
      WHEN '91'.
        IF <fs_barcode_return>-value+0(1) EQ zcl_batch_utility=>gc_sample_identifier. "Changed by Johnny Sun based on client's new requirement
          o_label_type = gc_label_sample_batch.  " Sample label
        ELSE.
          o_label_type = gc_label_wip_batch.     " WIP Carton label
        ENDIF.
        o_label_content-zzsublot = <fs_barcode_return>-value.
      WHEN '240'.
        DATA: lv_pallet_id TYPE exidv.                                                              " CR 251

        lv_su_number = <fs_barcode_return>-value+0(20).

        CONDENSE  lv_su_number .

        SELECT SINGLE exidv INTO lv_pallet_id FROM ztits_hu_conv WHERE zzlegacy_hu  = lv_su_number. " CR 251

        IF sy-subrc NE 0.                                                                           " CR 251

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_su_number
            IMPORTING
              output = lv_su_number.

        ENDIF.                                                                                      " CR 251

        IF i_su_label = abap_true.
* Coz SU & HU share the same label type , hence we have to do the judgement base on the
* user input
* If User specify SU, we only check SU

          o_label_type = gc_label_su.            "Storage Unit
          IF lv_pallet_id IS NOT INITIAL.                                                          " CR 251
            o_label_content-zzlenum = lv_pallet_id.                                                " CR 251
          ELSE.
            o_label_content-zzlenum = <fs_barcode_return>-value.                                   " CR 251
          ENDIF.
        ELSE.
* Otherwise we will take the label as HU
          o_label_type = gc_label_hu.            "Pallet label

          IF lv_pallet_id IS NOT INITIAL.                                                          " CR 251
            o_label_content-zzhu_exid = lv_pallet_id.                                              " CR 251
          ELSE.                                                                                    " CR 251
            SELECT SINGLE exidv INTO lv_su_number FROM vekp WHERE exidv EQ lv_su_number.
            IF sy-subrc EQ 0.

              o_label_content-zzhu_exid = <fs_barcode_return>-value.
            ENDIF.
          ENDIF.                                                                                   " CR 251
        ENDIF.

      WHEN '93'.
        o_label_type = gc_label_serial.        "Serial label
        o_label_content-zzsernr = <fs_barcode_return>-value.
      WHEN '241'.
        IF o_label_content-zzorigin_batch IS INITIAL OR o_label_content-zzorigin_batch EQ '0000000'.
          o_label_type = gc_label_rm_nob.      "Non-batch managed material label
        ENDIF.
        o_label_content-zzmatnr = <fs_barcode_return>-value.
      WHEN '30' OR '310'.
        o_label_content-zzquantity = <fs_barcode_return>-quantity.
        lv_qty_length              = strlen( <fs_barcode_return>-value ).
        IF lv_qty_length NE 6 AND <fs_barcode_return>-ai = '310'.
          MESSAGE e369(zits) RAISING illegal_bar_code.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

ENDMETHOD.


METHOD bar_code_translation_dfs.
************************************************************************
************************************************************************
* Program ID:                        BAR_CODE_TRANSLATION_DFS
* Created By:                        Kripa S Patil
* Creation Date:                     29.Dec.2018
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:                       Decode barcode for US DFS roll-out.
*                                    Copy from method BAR_CODE_TRANSLATION and make changes.
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 29.DEC.18   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*



  DATA: f_t313c TYPE t313c,
        f_t313g TYPE t313g.

  DATA: bar_length                    TYPE i,
        c_pos                         TYPE i VALUE 0,
        bar_data(100)                 TYPE c,
        seg_data(100)                 TYPE c,
        prefix(100)                   TYPE c,
        seg_aitype                    TYPE t313daityp,
        seg_len                       TYPE t313dailen,
        seg_del                       TYPE t313daidel,
        seg_mask                      TYPE t313damask,
        lf_ai                         TYPE t313daival,
        lf_found                      TYPE boole_d,
        lf_ai_l                       TYPE i,
        lf_rc                         TYPE i,
        lt_t313d                      TYPE TABLE OF t313d,
        lv_lenum                      TYPE lenum,
        lv_exidv                      TYPE exidv,
        lv_matnr                      TYPE matnr,
        lv_batch                      TYPE charg_d,
        lv_sublot                     TYPE zd_sublot,
        lv_su_number                  TYPE lenum,
        lv_result                     TYPE boolean.
  DATA: ls_ai_data                    TYPE t313d.
  DATA: lf_ai_add                     TYPE t313daival.
  DATA: lf_more_data                  TYPE boole_d.
  DATA: lf_ai_value                   TYPE barcode_aidata.
  DATA: lf_barcode                    TYPE barcode.
  DATA  l_oref                        TYPE REF TO cx_root.

  DATA: lv_qty_length                 TYPE int4.


  FIELD-SYMBOLS:
        <fs_t313d>                    TYPE t313d,
        <fs_barcode_return>           TYPE zsits_barcode_return.

************************************************************************

  seg_aitype = i_appid_type.

************************************************************************

  CALL FUNCTION 'LE_BARCODE_AI_READ'
    EXPORTING
      if_aityp        = seg_aitype
      if_aival        = space
      if_aisub        = 0
    IMPORTING
      es_bc_data      = f_t313g
    EXCEPTIONS
      barcode_unknown = 01
      no_ai_defined   = 02
      ai_unknown      = 03
      param_invalid   = 04
      OTHERS          = 99.

  CASE sy-subrc.

    WHEN 00.
      SELECT * FROM t313d INTO TABLE lt_t313d
        WHERE aityp = seg_aitype.
      SORT lt_t313d BY aival.
*Begin of delete for DFS roll-out by wangf on 4/1/2016
**     For testing purpose, hardcode delimitor to :
*      f_t313g-aidel = ':'.
*End of delete for DFS roll-out by wangf on 4/1/2016
    WHEN OTHERS.
*...Bar code string is not in one of the defined formats in the system.*
      MESSAGE e130 RAISING system_error.

  ENDCASE.


  IF f_t313g-mandt IS INITIAL.
*........Error in conversion of bar code string........................*
    MESSAGE e121(ZITS) WITH i_bar_code_string RAISING conversion_error.
  ENDIF.

************************************************************************

  bar_data = i_bar_code_string.
  bar_length = strlen( bar_data ).

  IF bar_length = 0.
*........Invalid bar code..............................................*
    MESSAGE e121 WITH bar_data RAISING illegal_bar_code.
  ENDIF.

  IF NOT ( f_t313g-prefix IS INITIAL ).
    c_pos = c_pos + strlen( f_t313g-prefix ).

    prefix = bar_data+0(c_pos).
    IF f_t313g-prefix <> prefix.
*........Invalid bar code..............................................*
      MESSAGE e121 WITH bar_data RAISING illegal_bar_code.
  ENDIF.

    IF c_pos > bar_length.
*........Invalid bar code..............................................*
      MESSAGE e121 WITH bar_data RAISING illegal_bar_code. ##MG_MISSING
    ENDIF.

  ENDIF.

************************************************************************
*

  TRY.

      bar_length = bar_length - c_pos.
      lf_barcode = bar_data.
      WHILE  bar_length > 0.

*   Get Identifier
        CLEAR: lf_ai, lf_found, lf_rc.
        lf_ai_l = f_t313g-minle.

        WHILE ( lf_found = ' '
          AND lf_ai_l <= f_t313g-maxle
          AND lf_rc = 0 ).
*     Invalid length
          IF lf_ai_l > bar_length.
            lf_rc = 1.
          ENDIF.

          lf_ai = lf_barcode+c_pos(lf_ai_l).
          READ TABLE lt_t313d ASSIGNING <fs_t313d>
            WITH KEY aival = lf_ai
            BINARY SEARCH.
          IF sy-subrc = 0.
            lf_found = 'X'.
          ELSE.
            lf_ai_l = lf_ai_l + 1.
          ENDIF.
        ENDWHILE.

        TRY .
            CALL FUNCTION 'LE_BARCODE_AI_SCAN'
              EXPORTING
                if_barcode            = lf_barcode
                is_bc_data            = f_t313g
              IMPORTING
                ef_ai_value           = lf_ai_value
                ef_ai_add             = lf_ai_add
              CHANGING
                cs_ai_data            = ls_ai_data
                cf_bc_o               = c_pos
                cf_bc_l               = bar_length
                cf_more_data          = lf_more_data
              EXCEPTIONS
                ai_not_found          = 01
                barcode_too_short     = 02
                error_in_subfunctions = 03
                OTHERS                = 99.
          CATCH cx_sy_no_handler INTO l_oref.
*  ........Error in conversion of bar code string........................*
            MESSAGE e121 WITH i_bar_code_string RAISING conversion_error.  ##MG_MISSING
        ENDTRY.

        IF sy-subrc <> 0.
*........Error in conversion of bar code string........................*
          MESSAGE e121 WITH i_bar_code_string RAISING conversion_error.   ##MG_MISSING
        ENDIF.

*      CATCH SYSTEM-EXCEPTIONS convt_no_number = 9.
        UNPACK lf_ai_add TO seg_mask.
*      ENDCATCH.
        IF sy-subrc = 9.
*.....Cannot convert entry to number................................
          MESSAGE e134 WITH seg_mask RAISING numeric_error.   ##MG_MISSING
        ENDIF.

        seg_data = lf_ai_value.

        IF lf_rc = 1.
*     Unindentified AI
          MESSAGE e121 WITH bar_data RAISING illegal_bar_code.
        ELSE.
*     Append value to return table
          APPEND INITIAL LINE TO o_return ASSIGNING <fs_barcode_return>.
          <fs_barcode_return>-ai = <fs_t313d>-aival.
          <fs_barcode_return>-value = seg_data.
*Begin of change for DFS roll-out by wangf on 4/19/2016
*          IF <fs_t313d>-aifor = 'N'.
          IF <fs_t313d>-aifor = 'N' AND ( <fs_t313d>-aival = '30' OR <fs_t313d>-aival = '310').
*End of change for DFS roll-out by wangf on 4/19/2016
*        CATCH SYSTEM-EXCEPTIONS conversion_errors = 9.
            IF seg_data CO '1234567890 '.
              <fs_barcode_return>-quantity = seg_data.
            ENDIF.
*        ENDCATCH.
            IF sy-subrc = 9.
*  ........Cannot convert entry to number................................*
              MESSAGE e134 WITH seg_data RAISING numeric_error.
            ENDIF.
            <fs_barcode_return>-quantity =  <fs_barcode_return>-quantity / ( 10 ** seg_mask ).
*            o_label_content-zzquantity = <fs_barcode_return>-value.
          ENDIF.
        ENDIF.

        c_pos = c_pos + seg_len + strlen( seg_del ).

      ENDWHILE.

    CATCH cx_sy_conversion_no_number INTO l_oref.
      MESSAGE e121 WITH bar_data RAISING illegal_bar_code.
    CATCH  cx_sy_range_out_of_bounds INTO l_oref.
      MESSAGE e121 WITH bar_data RAISING illegal_bar_code.
  ENDTRY.

*Begin of add for DFS roll-out by wangf on 4/19/2016
*Need to sort the internal table by AI because if batch AI 10 comes after material AI 241,
*then wrong label type will be determined by the following logic
  SORT o_return BY ai ASCENDING.
*End of add for DFS roll-out by wangf on 4/19/2016

  LOOP AT o_return ASSIGNING <fs_barcode_return>.
    CASE <fs_barcode_return>-ai.
      WHEN '10'.                                "Orginal Batch
        o_label_content-zzorigin_batch = <fs_barcode_return>-value.
      WHEN '21'.
        o_label_type = gc_label_fg_batch.      "FG Carton Label
        o_label_content-zzsublot = <fs_barcode_return>-value.
      WHEN '90'.
        o_label_type = gc_label_rm_batch.      "RAW Carton label
* For row material, sublot = 000 mean this is the virtual parent batch of container batch, in such ,we should ignore 000
        IF <fs_barcode_return>-value NE zcl_batch_utility=>gc_zero_sublot.
          o_label_content-zzsublot = <fs_barcode_return>-value.
        ENDIF.
      WHEN '91'.
        IF <fs_barcode_return>-value+0(1) EQ zcl_batch_utility=>gc_sample_identifier. "Changed by Johnny Sun based on client's new requirement
          o_label_type = gc_label_sample_batch.  " Sample label
        ELSE.
          o_label_type = gc_label_wip_batch.     " WIP Carton label
        ENDIF.
        o_label_content-zzsublot = <fs_barcode_return>-value.
*Begin of change for DFS roll-out by wangf on 3/31/2016
*      WHEN '240'.
      WHEN '240' OR '00'.
*End of change for DFS roll-out by wangf on 3/31/2016
        DATA: lv_pallet_id TYPE exidv.                                                              " CR 251

        lv_su_number = <fs_barcode_return>-value+0(20).

        CONDENSE  lv_su_number .

        SELECT SINGLE exidv INTO lv_pallet_id FROM ztits_hu_conv WHERE zzlegacy_hu  = lv_su_number. " CR 251

        IF sy-subrc NE 0.                                                                           " CR 251

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_su_number
            IMPORTING
              output = lv_su_number.

        ENDIF.                                                                                      " CR 251

        IF i_su_label = abap_true.
* Coz SU & HU share the same label type , hence we have to do the judgement base on the
* user input
* If User specify SU, we only check SU

          o_label_type = gc_label_su.            "Storage Unit
          IF lv_pallet_id IS NOT INITIAL.                                                          " CR 251
            o_label_content-zzlenum = lv_pallet_id.                                                " CR 251
          ELSE.
            o_label_content-zzlenum = <fs_barcode_return>-value.                                   " CR 251
          ENDIF.
        ELSE.
* Otherwise we will take the label as HU
          o_label_type = gc_label_hu.            "Pallet label

          IF lv_pallet_id IS NOT INITIAL.                                                          " CR 251
            o_label_content-zzhu_exid = lv_pallet_id.                                              " CR 251
          ELSE.                                                                                    " CR 251
*Begin of delete for DFS roll-out by wangf on 4/19/2016
*HU check is performed in method HU_CONTENT_READ_DFS
*            SELECT SINGLE exidv INTO lv_su_number FROM vekp WHERE exidv EQ lv_su_number.
*            IF sy-subrc EQ 0.
*End of delete for DFS roll-out by wangf on 4/19/2016
              o_label_content-zzhu_exid = <fs_barcode_return>-value.
*Begin of delete for DFS roll-out by wangf on 4/19/2016
*            ENDIF.
*End of delete for DFS roll-out by wangf on 4/19/2016
          ENDIF.                                                                                   " CR 251
        ENDIF.

      WHEN '93'.
        o_label_type = gc_label_serial.        "Serial label
        o_label_content-zzsernr = <fs_barcode_return>-value.
      WHEN '241'.
*Begin of add for DFS roll-out by wangf on 4/14/2016
        "For DFS roll-out, it's possbile that HU/Material/Batch all come in one barcode
        "If that's the case then just get HU number to get the packed material
        "So the label type is determined by AI 00 or 240
        IF o_label_type IS INITIAL.
*  End of add for DFS roll-out by wangf on 4/14/2016
          IF o_label_content-zzorigin_batch IS INITIAL OR o_label_content-zzorigin_batch EQ '0000000'.
*  Begin of change for DFS roll-out by wangf on 3/31/2016
*            o_label_type = gc_label_rm_nob.      "Non-batch managed material label
            o_label_type = gc_label_mat_nob.      "Non-batch managed material label
*  End of change for DFS roll-out by wangf on 3/31/2016
*  Begin of add for DFS roll-out by wangf on 3/31/2016
          ELSE.
            o_label_type = gc_label_mat_batch.      "Batch managed material label
*  End of add for DFS roll-out by wangf on 3/31/2016
          ENDIF.
*Begin of add for DFS roll-out by wangf on 4/14/2016
        ENDIF.
*End of add for DFS roll-out by wangf on 4/14/2016
        o_label_content-zzmatnr = <fs_barcode_return>-value.
      WHEN '30' OR '310'.
        o_label_content-zzquantity = <fs_barcode_return>-quantity.
        lv_qty_length              = strlen( <fs_barcode_return>-value ).
        IF lv_qty_length NE 6 AND <fs_barcode_return>-ai = '310'.
          MESSAGE e369(zits) RAISING illegal_bar_code.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

ENDMETHOD.


METHOD bin_read.

  DATA: lv_dummy            TYPE              bapi_msg.

  SELECT SINGLE * FROM lagp INTO CORRESPONDING FIELDS OF rs_bin_data
                                                   WHERE lgnum = is_bin_key-lgnum
                                                     AND lgtyp = is_bin_key-lgtyp
                                                     AND lgpla = is_bin_key-lgpla.

  IF sy-subrc NE 0.
    MESSAGE e129(zits) WITH is_bin_key-lgpla INTO lv_dummy.
  ENDIF.

ENDMETHOD.


METHOD constructor.
************************************************************************
************************************************************************
* Program ID:                        CONSTRUCTOR
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
  TYPES: BEGIN OF lty_bus_oper,
           sign   TYPE char01,
           option TYPE char02,
           low    TYPE zd_busopera,
           high   TYPE zd_busopera,
         END OF lty_bus_oper.

  DATA:ls_tcode_attribute TYPE ztits_scan_code,
       lt_bus_oper        TYPE STANDARD TABLE OF lty_bus_oper,
       ls_bus_oper        LIKE LINE OF lt_bus_oper,
       lt_allowed_mtart   TYPE zttits_mtart_tab.

  FREE:  gt_log_data.
  CLEAR: gs_log_key,gv_scan_code.

  CALL FUNCTION 'GUID_CREATE'     ##FM_OLDED
    IMPORTING
      ev_guid_16 = gs_log_key-zzscan_id.

  gv_scan_code = iv_scan_code.

* get logon profile
  gs_logon_profile =  get_user_profile( ).

* get allowed material type

  SELECT SINGLE * INTO ls_tcode_attribute FROM ztits_scan_code WHERE tcode = iv_scan_code.

  CHECK sy-subrc EQ 0.

  ls_bus_oper-sign   = 'I'.
  ls_bus_oper-option = 'EQ'.

  IF ls_tcode_attribute-zzusefor_hc = abap_true.
    ls_bus_oper-low  = gc_material_hc.   " H
    APPEND ls_bus_oper TO lt_bus_oper.
  ENDIF.

  IF ls_tcode_attribute-zzusefor_dfs = abap_true.
    ls_bus_oper-low  = gc_material_dfs.  " D
    APPEND ls_bus_oper TO lt_bus_oper.
  ENDIF.

  IF ls_tcode_attribute-zzusefor_mtc = abap_true.
    ls_bus_oper-low  = gc_material_mtc.  " M
    APPEND ls_bus_oper TO lt_bus_oper.
  ENDIF.

  CHECK lt_bus_oper IS NOT INITIAL.

  SELECT * INTO TABLE lt_allowed_mtart FROM ztits_mtart WHERE zzbusopera IN lt_bus_oper.

  CALL FUNCTION 'ZITS_ALLOWED_MTART_SET'
    EXPORTING
      it_allowed_mtart = lt_allowed_mtart.

ENDMETHOD.


METHOD conv_bapiret_to_msg.
************************************************************************
************************************************************************
* Program ID:                        CONV_BAPIRET_TO_MSG
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
  DATA:    lv_dummy     TYPE string,
           lt_bapi_ret  TYPE bapiret2_t,
           ls_msg_line  LIKE LINE OF lt_bapi_ret.

  STATICS: lt_var_data  TYPE ztits_scan_var_tab.

  FIELD-SYMBOLS: <fs_var_line> LIKE LINE OF lt_var_data.

  FIELD-SYMBOLS: <fs_ret_line> LIKE LINE OF it_bapi_ret.

  rv_no_error = abap_true.

  lt_bapi_ret = it_bapi_ret.

  IF lt_var_data IS INITIAL.
* get the error message type/id which should be ignored
    lt_var_data = zcl_its_utility=>its_variable_value_get( iv_variant = zcl_its_utility=>gc_var_ignore_message ).
  ENDIF.

  LOOP AT  lt_bapi_ret ASSIGNING <fs_ret_line> WHERE type = 'E' OR type = 'A'.
* Usually the last error item contain the most meaningfule message
    CLEAR rv_no_error.

    READ TABLE lt_var_data ASSIGNING <fs_var_line> WITH KEY zzpara1 = <fs_ret_line>-id
                                                            zzpara2 = <fs_ret_line>-number.
    IF sy-subrc EQ 0.
* If any error messge in the predefined list , we should ignore this,but still act as error message
      DELETE lt_bapi_ret.
    ENDIF.

  ENDLOOP.

  IF rv_no_error = abap_false.
* In case any error message found
    IF <fs_ret_line> IS ASSIGNED.
      UNASSIGN <fs_ret_line>.
    ENDIF.

    LOOP AT  lt_bapi_ret ASSIGNING <fs_ret_line> WHERE type = 'E' OR type = 'A'.
* Usually the last error item contain the most meaningfule message
      CLEAR rv_no_error.
    ENDLOOP.

    IF <fs_ret_line> IS NOT ASSIGNED.
* In case no error message found except the one in the exclude list
      MESSAGE e459 WITH <fs_var_line>-zzpar_value INTO lv_dummy.
    ENDIF.

  ENDIF.

  IF rv_no_error = abap_true.
* Get the success message
    READ TABLE lt_bapi_ret ASSIGNING <fs_ret_line> WITH KEY type = 'S'.
    IF sy-subrc NE 0.
      READ TABLE it_bapi_ret ASSIGNING <fs_ret_line> INDEX 1.
    ENDIF.
  ENDIF.

  IF <fs_ret_line> IS ASSIGNED.
    ls_msg_line-id         = <fs_ret_line>-id.
    ls_msg_line-type       = <fs_ret_line>-type.
    ls_msg_line-number     = <fs_ret_line>-number.
    ls_msg_line-message_v1 = <fs_ret_line>-message_v1.
    ls_msg_line-message_v2 = <fs_ret_line>-message_v2.
    ls_msg_line-message_v3 = <fs_ret_line>-message_v3.
    ls_msg_line-message_v4 = <fs_ret_line>-message_v4.

  ELSE.
    ls_msg_line-id         = sy-msgid.
    ls_msg_line-type       = sy-msgty.
    ls_msg_line-number     = sy-msgno.
    ls_msg_line-message_v1 = sy-msgv1.
    ls_msg_line-message_v2 = sy-msgv2.
    ls_msg_line-message_v3 = sy-msgv3.
    ls_msg_line-message_v4 = sy-msgv4.
  ENDIF.

  CHECK ls_msg_line-type IS NOT INITIAL.

  MESSAGE ID   ls_msg_line-id
        TYPE   ls_msg_line-type
        NUMBER ls_msg_line-number
        INTO   lv_dummy
        WITH   ls_msg_line-message_v1
               ls_msg_line-message_v2
               ls_msg_line-message_v3
               ls_msg_line-message_v4.

ENDMETHOD.


  method DELIVERY_LOCK.
      DATA: lv_vbeln TYPE vbeln_vl,
        lv_dummy TYPE string.

  rv_result = abap_false.

  lv_vbeln = iv_delivery.

* Format Conversion External -> Internal
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lv_vbeln
    IMPORTING
      output = lv_vbeln.

  CALL FUNCTION 'ENQUEUE_EVVBLKE'
    EXPORTING
      vbeln          = lv_vbeln
    EXCEPTIONS
      foreign_lock   = 2
      system_failure = 3.

  CASE sy-subrc.
    WHEN 0.
      rv_result = abap_true.
    WHEN 2.
*This delivery (&1) is currently being processed by another user (&2)
      MESSAGE e046(vl) WITH iv_delivery sy-msgv1 INTO lv_dummy.
    WHEN 3.
*You cannot block the transaction at the moment
      MESSAGE e047(vl) INTO lv_dummy.
  ENDCASE.

  endmethod.


  method DELIVERY_READ.

     DATA: lv_vbeln TYPE vbeln_vl.

  DATA: lit_delivery_item TYPE zttits_dlv_item,
        lwa_delivery_item LIKE LINE OF lit_delivery_item,
        lv_batch_num      TYPE zzbatch,
        lwa_read_option   TYPE zsits_batch_read_option,
        lx_batch_data     TYPE zsits_batch_data,
        lv_batch_status   TYPE c.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = iv_delivery
    IMPORTING
      output = lv_vbeln.

* Delivery header
  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF es_delivery_header
    FROM likp
   WHERE vbeln = lv_vbeln.

  IF iv_pick_get = abap_true.
*   Delivery item
    SELECT vbeln
           posnr
           matnr
           werks
           lgort
           charg
           lgmng
           meins
      INTO CORRESPONDING FIELDS OF TABLE et_delivery_item "lit_delivery_item
      FROM lips
     WHERE vbeln = lv_vbeln
       AND lgmng NE 0.
*    IF sy-subrc = 0.
*      LOOP AT lit_delivery_item INTO lwa_delivery_item.
*        lv_batch_num = lwa_delivery_item-charg.
*        lwa_read_option-zzstock_read = abap_true."batch stock read
*
*        CALL METHOD zcl_batch_utility=>batch_read
*          EXPORTING
*            iv_batch       = lv_batch_num
*            is_read_option = lwa_read_option
*          RECEIVING
*            rs_batch_data  = lx_batch_data.
*
*        IF lx_batch_data IS NOT INITIAL.
*          CALL METHOD zcl_batch_utility=>get_im_status
*            EXPORTING
*              is_batch_data = lx_batch_data
*            RECEIVING
*              rv_status     = lv_batch_status.
*
*          IF lv_batch_status <> zcl_batch_utility=>gc_im_status_qi.
*            APPEND lwa_delivery_item TO et_delivery_item.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.

*   Picking quantity
    SELECT *
      INTO TABLE et_picking_qty
      FROM vbfa
     WHERE vbelv   = lv_vbeln
       AND vbtyp_n = zcl_its_utility=>gc_vbtyp_to                    "WMS transfer order
       AND vbtyp_v = zcl_its_utility=>gc_vbtyp_outb_delivery        "Delivery
       AND rfmng > 0.                                               "quantity
  ENDIF.

  endmethod.


METHOD get_cartons_by_su.
* This method fethces batches that were moved onto and rolled up on SU

  TYPES: BEGIN OF lty_source_obj,
            matnr TYPE matnr,
            charg TYPE charg_d,
            objek TYPE cuobn,
         END   OF lty_source_obj,

         BEGIN OF lty_conv_objek,
            cuobj TYPE cuobj,
            objek TYPE objnum,
         END   OF lty_conv_objek.

  DATA: ls_lqua        TYPE lqua,
        lit_mch1       TYPE STANDARD TABLE OF mch1,
        lv_batch       TYPE zzbatch,
        ls_read_option TYPE zsits_batch_read_option,
        ls_batch_data  TYPE zsits_batch_data.



  DATA: lt_ausp_data    TYPE STANDARD TABLE OF ausp,
        lt_inob_data    TYPE STANDARD TABLE OF inob,
        lt_source_obj   TYPE STANDARD TABLE OF lty_source_obj,
        lt_conv_objek   TYPE STANDARD TABLE OF lty_conv_objek.

  FIELD-SYMBOLS:<fs_ausp_line>   LIKE LINE OF lt_ausp_data,
                <fs_inob_line>   LIKE LINE OF lt_inob_data,
                <fs_mch1_line>   LIKE LINE OF lit_mch1,
                <fs_source_line> LIKE LINE OF lt_source_obj,
                <fs_conv_objek>  LIKE LINE OF lt_conv_objek.

  DATA: lv_atwrt_su              TYPE atwrt,
        lv_atinn_pallet_id       TYPE atinn,
        lv_parent_batch          TYPE zzbatch,
        lv_dummy                 TYPE bapi_msg.

* End of change   ED2K906478
  IF is_su_content-su_item IS INITIAL.
    RETURN.
  ENDIF.

* direct to get the SU content
* Get parent batch that's on SU
  READ TABLE is_su_content-su_item INTO ls_lqua INDEX 1.

* Get batches that have the parent batch as vendor batch
  SELECT matnr charg licha                            "#EC CI_NOFIELD
    FROM mch1
    INTO CORRESPONDING FIELDS OF TABLE lit_mch1
*   WHERE licha = ls_lqua-charg
   WHERE charg = ls_lqua-charg
     AND lvorm = ''.

  CHECK sy-subrc = 0.

* Start of change   ED2K906478
*---------------------------------------------------------------------------------------------------------------------

* Prepare the convert table bewteen material/batch & the object in INOB
  LOOP AT lit_mch1 ASSIGNING <fs_mch1_line>.
    APPEND INITIAL LINE TO lt_source_obj ASSIGNING <fs_source_line>.
    MOVE: <fs_mch1_line>-matnr TO <fs_source_line>-matnr,
          <fs_mch1_line>-charg TO <fs_source_line>-charg,
          <fs_mch1_line>-matnr TO <fs_source_line>-objek+0(18),
          <fs_mch1_line>-charg TO <fs_source_line>-objek+18(10).

  ENDLOOP.

* Get all the batch's classifiation object ID
*---------------------------------------------------------------------------------------------------------------------
*  SELECT * INTO TABLE lt_inob_data FROM inob FOR ALL ENTRIES IN lt_source_obj WHERE obtab = 'MCH1'
*                                                                                AND objek = lt_source_obj-objek
*                                                                                AND klart = '023'.
*  CHECK sy-subrc EQ 0.
*
** Prepare the conversion tab between INOB-CUOBJ and AUSP-OBJEK
**---------------------------------------------------------------------------------------------------------------------
*  LOOP AT lt_inob_data ASSIGNING <fs_inob_line>.
*    APPEND INITIAL LINE TO lt_conv_objek ASSIGNING <fs_conv_objek>.
*    MOVE: <fs_inob_line>-cuobj TO <fs_conv_objek>-cuobj,
*          <fs_inob_line>-cuobj TO <fs_conv_objek>-objek.
*  ENDLOOP.
*
** Get the pallet ID
**---------------------------------------------------------------------------------------------------------------------
*  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*    EXPORTING
*      input  = zcl_common_utility=>gc_chara_palletid
*    IMPORTING
*      output = lv_atinn_pallet_id.
*
** Get all objects which has the same value of 'Pallet_ID' as the scanned SU#
**---------------------------------------------------------------------------------------------------------------------
** Get the output format SU first
*
*  CALL FUNCTION 'CONVERSION_EXIT_LENUM_OUTPUT'
*    EXPORTING
*      input           = is_su_content-su_header-lenum
*    IMPORTING
*      output          = lv_atwrt_su
*    EXCEPTIONS
*      t344_get_failed = 1
*      OTHERS          = 2.
*
*  IF sy-subrc NE 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.
*    RETURN.
*  ENDIF.
*
*  SELECT * INTO TABLE lt_ausp_data FROM ausp FOR ALL ENTRIES IN lt_conv_objek WHERE objek   = lt_conv_objek-objek
*                                                                                 AND atinn  = lv_atinn_pallet_id
*                                                                                 AND atwrt  = lv_atwrt_su.
*  CHECK sy-subrc EQ 0.
*
*  SORT: lt_ausp_data  BY objek,
*         lt_conv_objek BY objek,
*         lt_inob_data  BY cuobj,
*         lt_source_obj BY objek.

  ls_read_option-zzstock_read = abap_true.

*  LOOP AT lt_ausp_data ASSIGNING <fs_ausp_line>.
*
*    READ TABLE lt_conv_objek ASSIGNING <fs_conv_objek> WITH KEY objek = <fs_ausp_line>-objek BINARY SEARCH.
*
*    CHECK sy-subrc EQ 0.
*
*    READ TABLE lt_inob_data  ASSIGNING <fs_inob_line> WITH KEY cuobj = <fs_conv_objek>-cuobj BINARY SEARCH.
*
*    CHECK sy-subrc EQ 0.
*
*    READ TABLE lt_source_obj ASSIGNING <fs_source_line> WITH KEY objek = <fs_inob_line>-objek BINARY SEARCH.
*
*    CHECK sy-subrc EQ 0.
*
    lv_batch = ls_lqua-charg.

    CLEAR ls_batch_data.

    CALL METHOD zcl_batch_utility=>batch_read
      EXPORTING
        iv_batch       = lv_batch
        is_read_option = ls_read_option
      RECEIVING
        rs_batch_data  = ls_batch_data.

*    IF ls_batch_data-charg NE ls_batch_data-licha.
** For parent batch, no need following check
*      IF ls_batch_data-batch_stock IS NOT INITIAL
*      OR ls_batch_data-batch_stock_wm IS NOT INITIAL.
**   Batch has stock, meaning batch is not rolled up on SU
*        CONTINUE.
*      ENDIF.
*
*    ENDIF.

    lv_parent_batch = ls_lqua-charg.

    APPEND ls_batch_data TO et_batch_data.

*  ENDLOOP.

*  IF iv_count_only = abap_false.
** Except the count , we usually need to return the parent batch data for warehouse activity.
** because the carton batch on SU should be rolled up, only parent batch has value.
*    SORT et_batch_data BY charg.
*
*    READ TABLE et_batch_data TRANSPORTING NO FIELDS WITH KEY charg = lv_parent_batch BINARY SEARCH.
*
*    IF sy-subrc EQ 0.
*      CLEAR ls_batch_data.
*
*      CALL METHOD zcl_batch_utility=>batch_read
*        EXPORTING
*          iv_batch       = lv_batch
*          is_read_option = ls_read_option
*        RECEIVING
*          rs_batch_data  = ls_batch_data.
** Append the parent batch data to the result
*      APPEND ls_batch_data TO et_batch_data.
*    ENDIF.
*
*  ENDIF.

* End of change     ED2K906478

*  LOOP AT lit_mch1 INTO ls_mch1.
*
*    lv_batch = ls_mch1-charg.
*    ls_read_option-zzstock_read = abap_true.
*    ls_read_option-zzcharact_read = abap_true.
*    ls_read_option-zzinsp_lot = abap_true.
*
*    CALL METHOD zcl_batch_utility=>batch_read
*      EXPORTING
*        iv_batch       = lv_batch
*        is_read_option = ls_read_option
*      RECEIVING
*        rs_batch_data  = ls_batch_data.
*
*
*    IF ls_batch_data-charg NE ls_batch_data-licha.
** For parent batch, no need following check
*      IF ls_batch_data-batch_stock IS NOT INITIAL
*      OR ls_batch_data-batch_stock_wm IS NOT INITIAL.
**   Batch has stock, meaning batch is not rolled up on SU
*        CONTINUE.
*      ENDIF.
** Start-of-Change @ July 9th          ED2K905807  TBD
**    ELSE.
*** For parent batch, we should skip the pallet_ID comparision,and add into the return table as long as its on the scanned SU
**      READ TABLE is_su_content-su_item TRANSPORTING NO FIELDS WITH KEY matnr = ls_batch_data-matnr
**                                                                       charg = ls_batch_data-charg.
**      IF sy-subrc EQ 0.
**
**        APPEND ls_batch_data TO et_batch_data.
**
**      ENDIF.
**
**      CONTINUE.
**
*** End-of-change @ July 9th            ED2K905807
*    ENDIF.
*
*    READ TABLE ls_batch_data-batch_charact-valueschar INTO ls_batch_char
*    WITH KEY charact = zcl_common_utility=>gc_chara_palletid.
*
*    IF sy-subrc <> 0.
**   PALLET ID char is blank
*      CONTINUE.
*    ENDIF.
*
*    lv_su = is_su_content-su_header-lenum.
*
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*      EXPORTING
*        input  = lv_su
*      IMPORTING
*        output = lv_su.
*
*    IF ls_batch_char-value_char <> lv_su.
**   Batch char PALLET ID does not equal to the input su #
*      CONTINUE.
*    ENDIF.
*
*    APPEND ls_batch_data TO et_batch_data.
*
*  ENDLOOP.

*** inactive new ***
ENDMETHOD.


METHOD get_doc_status.
  DATA: ls_head_status TYPE vbuk,
        ls_item_status TYPE vbup.

  FIELD-SYMBOLS: <fs_status> TYPE char01.

  CLEAR rv_status.

  IF iv_check_item IS INITIAL.
* Get header status
    SELECT SINGLE * INTO ls_head_status FROM vbuk WHERE vbeln = iv_doc_num.
    IF sy-subrc EQ 0.
      ASSIGN COMPONENT iv_status_name OF STRUCTURE ls_head_status TO <fs_status>.
    ENDIF.
  ELSE.
* Get Item Status
    SELECT SINGLE * INTO ls_item_status FROM vbup WHERE vbeln = iv_doc_num AND posnr = iv_check_item.
    IF sy-subrc EQ 0.
      ASSIGN COMPONENT iv_status_name OF STRUCTURE ls_item_status TO <fs_status>.
    ENDIF.
  ENDIF.

  IF <fs_status> IS ASSIGNED.

    rv_status = <fs_status>.

  ENDIF.
ENDMETHOD.


  method GET_PICKED_TO.

  DATA: lit_to_item TYPE zttits_to_item.

  MOVE it_to_item[] TO lit_to_item[].
  SORT lit_to_item BY lgnum tanum tapos.
  DELETE ADJACENT DUPLICATES FROM lit_to_item COMPARING lgnum tanum tapos.

  CHECK lit_to_item IS NOT INITIAL.

  SELECT *
    INTO TABLE et_picked_to
    FROM ztits_pick
     FOR ALL ENTRIES IN lit_to_item
   WHERE lgnum = lit_to_item-lgnum
     AND tanum = lit_to_item-tanum
     AND tapos = lit_to_item-tapos.

  endmethod.


  method GET_TO_BY_OUTB_DLV.

  DATA: lv_dlv TYPE vbeln_vl.

  DATA: lit_to_item TYPE STANDARD TABLE OF ZSITS_TO_ITEM,
        lwa_to_item TYPE ZSITS_TO_ITEM,
        lv_posnn    TYPE vbfa-posnn.

  FIELD-SYMBOLS: <ls_dlv_item> TYPE zsits_dlv_item.

  CHECK is_dlv_key-vbeln <> ''.

* Leading zero
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = is_dlv_key-vbeln
    IMPORTING
      output = lv_dlv.

* Get delivery items
  SELECT vbeln
         posnr
         matnr
         werks
         lgort
         charg
 FROM lips
 INTO CORRESPONDING FIELDS OF TABLE es_detail-dlv_item
 WHERE vbeln = lv_dlv.

  IF sy-subrc = 0.

    SORT es_detail-dlv_item BY posnr.

* Get TO items
    IF es_detail-dlv_item[] IS NOT INITIAL.
      SELECT a~vbelv
             a~posnv
             a~vbeln
             a~posnn
             a~lgnum
             b~tanum
             b~tapos
             b~matnr
             b~charg
             b~vlpla
             b~vsolm
             b~nlpla
             b~nsolm
             b~meins
             b~lgort
             b~werks
             b~vlenr AS lenum
      FROM vbfa AS a
      INNER JOIN ltap AS b ON b~lgnum = a~lgnum AND b~tanum = a~vbeln "AND b~tapos = a~posnn+2(4)
      INTO CORRESPONDING FIELDS OF TABLE lit_to_item"es_detail-to_item
      FOR ALL ENTRIES IN es_detail-dlv_item
      WHERE a~vbelv = es_detail-dlv_item-vbeln
        AND a~posnv = es_detail-dlv_item-posnr
        AND a~vbtyp_v = 'J'
        AND a~vbtyp_n = 'Q'
        AND b~pquit   = ''.        "Canceled or already confirmed
      IF sy-subrc = 0.
        LOOP AT lit_to_item INTO lwa_to_item.
          lv_posnn = lwa_to_item-tapos.

          IF lv_posnn = lwa_to_item-posnn.
            APPEND lwa_to_item to es_detail-to_item.
          ENDIF.
        ENDLOOP.

        SORT es_detail-to_item BY lgnum vbelv posnv.
      ENDIF.

    ENDIF.
  ENDIF.

  endmethod.


METHOD get_user_profile.
************************************************************************
************************************************************************
* Program ID:                        GET_USER_PROFILE
* Created By:                        Kripa S Patil
* Creation Date:                     29.Dec.2018
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
* 29.DEC.18   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
  DATA: lv_dummy TYPE string.

  CLEAR rs_user_profile.

* 1> Get data from buffer
*----------------------------------------------------------------------------------
  CALL FUNCTION 'ZITS_GET_USER_PROFILE_BUFFER'
    IMPORTING
      es_user_profile = rs_user_profile.

  IF rs_user_profile IS INITIAL.

* 2> Get data from parameter ID
*----------------------------------------------------------------------------------
    SELECT SINGLE werks lgnum INTO (rs_user_profile-zzwerks,rs_user_profile-zzlgnum)
      FROM ztits_uprofile
     WHERE bname = sy-uname.

  ENDIF.

  IF rs_user_profile-zzwerks IS INITIAL AND rs_user_profile-zzlgnum IS INITIAL.
* request user to maintain values in User Parameter ID
    MESSAGE e508(zits) INTO lv_dummy.
    CLEAR rs_user_profile.
  ENDIF.

ENDMETHOD.


METHOD hu_content_read.
************************************************************************
************************************************************************
* Program ID:                        HU_CONTENT_READ
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
  DATA: lv_hu_id       TYPE exidv,
        lv_dummy       TYPE string,
        lt_hu_header   TYPE STANDARD TABLE OF bapihuheader,
        lt_hu_number   TYPE STANDARD TABLE OF bapihunumber,
        lt_hu_item     TYPE zthu_item_tab,
        lt_bapi_ret    TYPE bapiret2_t,
        ls_hu_content  TYPE LINE OF zthu_item_tab,
        lv_index       TYPE i,
        ls_batch_data  TYPE LINE OF zsits_batch_data_tab,
        lt_batch_data  TYPE zsits_batch_data_tab,
        ls_batch_stock TYPE zsits_batch_stock.

  FIELD-SYMBOLS: <fs_huno_line>  LIKE LINE OF lt_hu_number,
                 <fs_bapi_ret>   LIKE LINE OF lt_bapi_ret,
                 <fs_hu_header>  LIKE LINE OF lt_hu_header.


  CLEAR es_hu_content.

  CHECK iv_hu_id IS NOT INITIAL.

* Convert the import HU# into internal format
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = iv_hu_id
    IMPORTING
      output = lv_hu_id.

* Check the HU# whether exist or not

  SELECT exidv INTO lv_hu_id UP TO 1 ROWS FROM vekp WHERE exidv = lv_hu_id.
  ENDSELECT.

  IF sy-subrc NE 0.
*Required handling units could not be found
    MESSAGE e010(huselect) INTO lv_dummy.
    RETURN.
  ENDIF.

* Prepare the external HU id for BAPI-call
  APPEND INITIAL LINE TO lt_hu_number ASSIGNING <fs_huno_line>.
  <fs_huno_line>-hu_exid = lv_hu_id.

* Call BAPI to get the HU content
  CALL FUNCTION 'BAPI_HU_GETLIST'
    EXPORTING
      notext    = abap_true
      onlykeys  = abap_false
    TABLES
      hunumbers = lt_hu_number
      huheader  = lt_hu_header
      huitem    = lt_hu_item
      return    = lt_bapi_ret.

  IF zcl_its_utility=>conv_bapiret_to_msg( lt_bapi_ret ) = abap_true.

    LOOP AT lt_hu_header ASSIGNING <fs_hu_header> WHERE hu_exid = lv_hu_id.
* HU Header
      MOVE-CORRESPONDING <fs_hu_header> TO es_hu_content-hu_header.
* HU Item
      MOVE lt_hu_item TO  es_hu_content-hu_content.

      DELETE es_hu_content-hu_content WHERE hu_exid NE lv_hu_id.

    ENDLOOP.

  ENDIF.

* Check the logon location is whether match with the scanned object
*------------------------------------------------------------------------------------------
  IF zcl_its_utility=>is_location_match( is_hu_data  = es_hu_content ) = abap_false.

    CLEAR es_hu_content.
    RETURN.

  ENDIF.

*if HU content is restricted sales order stock or other special stock
*HU item will not hav storage location. In this case, read batch stock to get storage location



  CLEAR: lt_bapi_ret, lt_hu_header, lt_hu_number, lt_hu_item.

ENDMETHOD.


METHOD hu_content_read_dfs.
************************************************************************
************************************************************************
* Program ID:
* Created By:                        Kripa S Patil
* Creation Date:                     02.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:                       Read Handling Unit content for US DFS roll-out.
*                                    Copy from method HU_CONTENT_READ and make changes.
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 02.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
***********************************************************************
* PROGRAM DECLARATION
***********************************************************************
* Method:             HU_CONTENT_READ_DFS
* AUTHOR Name:        Frank Wang
* OWNER(Process Team):Lakshmikumar Reddy
* CREATE DATE:        4/1/2016
* ECC RELEASE VERSION 6.0
* BASED-ON PROGRAM:   none
* Object ID:          E0300,E0301,E0302,E0303,E0305
* DESCRIPTION :       Read Handling Unit content for US DFS roll-out.
*                     Copy from method HU_CONTENT_READ and make changes.
***********************************************************************
* VERSION CONTROL (Most recent on top):
* DATE             AUTHOR       CTS REQ        DESCRIPTION
*----------------------------------------------------------------------
* 4/1/2016      Frank Wang    ED2K908004       Initial
  DATA: lv_hu_id       TYPE exidv,
        lv_dummy       TYPE string,
        lt_hu_header   TYPE STANDARD TABLE OF bapihuheader,
        lt_hu_number   TYPE STANDARD TABLE OF bapihunumber,
        lt_hu_item     TYPE zthu_item_tab,
        lt_bapi_ret    TYPE bapiret2_t,
        ls_hu_content  TYPE LINE OF zthu_item_tab,
        lv_index       TYPE i,
        ls_batch_data  TYPE LINE OF zsits_batch_data_tab,
        lt_batch_data  TYPE zsits_batch_data_tab,
        ls_batch_stock TYPE zsits_batch_stock.

  FIELD-SYMBOLS: <fs_huno_line>  LIKE LINE OF lt_hu_number,
                 <fs_bapi_ret>   LIKE LINE OF lt_bapi_ret,
                 <fs_hu_header>  LIKE LINE OF lt_hu_header.


  CLEAR es_hu_content.

  CHECK iv_hu_id IS NOT INITIAL.

* Convert the import HU# into internal format
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = iv_hu_id
    IMPORTING
      output = lv_hu_id.

* Check the HU# whether exist or not

  SELECT exidv INTO lv_hu_id UP TO 1 ROWS FROM vekp WHERE exidv = lv_hu_id.
  ENDSELECT.

  IF sy-subrc NE 0.
*Required handling units could not be found
    MESSAGE e010(huselect) INTO lv_dummy.
    RETURN.
  ENDIF.

*Begin of add for DFS roll-out by wangf on 4/1/2016
* Check if the handling unit status is in inventory
  IF is_hu_in_inv( iv_hu_id ) EQ abap_false. "handling unit not in inventory(e.g. Goods Issued)
    MESSAGE e000(zitsus) WITH iv_hu_id INTO lv_dummy.
*   HU &1 not in inventory
    RETURN.
  ENDIF.
*End of add for DFS roll-out by wangf on 4/1/2016

* Prepare the external HU id for BAPI-call
  APPEND INITIAL LINE TO lt_hu_number ASSIGNING <fs_huno_line>.
  <fs_huno_line>-hu_exid = lv_hu_id.

* Call BAPI to get the HU content
  CALL FUNCTION 'BAPI_HU_GETLIST'
    EXPORTING
      notext    = abap_true
      onlykeys  = abap_false
    TABLES
      hunumbers = lt_hu_number
      huheader  = lt_hu_header
      huitem    = lt_hu_item
      return    = lt_bapi_ret.

  IF zcl_its_utility=>conv_bapiret_to_msg( lt_bapi_ret ) = abap_true.

    LOOP AT lt_hu_header ASSIGNING <fs_hu_header> WHERE hu_exid = lv_hu_id.
* HU Header
      MOVE-CORRESPONDING <fs_hu_header> TO es_hu_content-hu_header.
* HU Item
      MOVE lt_hu_item TO  es_hu_content-hu_content.

      DELETE es_hu_content-hu_content WHERE hu_exid NE lv_hu_id.

    ENDLOOP.

  ENDIF.

* Check the logon location is whether match with the scanned object
*------------------------------------------------------------------------------------------
*Begin of change for DFS roll-out by wangf on 4/1/2016
*  IF zcl_its_utility=>is_location_match( is_hu_data  = es_hu_content ) = abap_false.
  IF zcl_its_utility=>is_location_match_dfs( is_hu_data  = es_hu_content ) = abap_false.
*End of change for DFS roll-out by wangf on 4/1/2016
    CLEAR es_hu_content.
    RETURN.

  ENDIF.

*---------------Added by Fei Tang on 2/13/15-----------------------------
*if HU content is restricted sales order stock or other special stock
*HU item will not hav storage location. In this case, read batch stock to get storage location

*  IF es_hu_content-hu_content IS NOT INITIAL.
*
*   LOOP AT es_hu_content-hu_content INTO ls_hu_content.
*    lv_index = lv_index + 1.
*
*      IF ls_hu_content-stge_loc IS INITIAL.
*        ls_batch_data-charg = ls_hu_content-batch.
*        ls_batch_data-matnr = ls_hu_content-material.
*        ls_batch_data-werks = ls_hu_content-plant.
*        APPEND ls_batch_data TO lt_batch_data.
*        CLEAR ls_batch_data.
*
*        CALL METHOD zcl_batch_utility=>batch_stock_read
*          CHANGING
*            ct_batch_data = lt_batch_data.
*
*        READ TABLE lt_batch_data INTO ls_batch_data INDEX 1.
*        READ TABLE ls_batch_data-batch_stock INTO ls_batch_stock INDEX 1.
*        ls_hu_content-stge_loc = ls_batch_stock-lgort.
*        MODIFY es_hu_content-hu_content INDEX lv_index FROM ls_hu_content TRANSPORTING stge_loc.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*---------------Added by Fei Tang on 2/13/15-----------------------------

  CLEAR: lt_bapi_ret, lt_hu_header, lt_hu_number, lt_hu_item.

ENDMETHOD.


  METHOD hu_content_read_dfs_2.
************************************************************************
************************************************************************
* Program ID:
* Methid Name :                      HU_CONTENT_READ_DFS_2
* Created By:                        SRAWAT
* Creation Date:                     12.18.2019
* Capsugel / Lonza RICEFW ID:        S101
* Description:                       Read Handling Unit content for US DFS roll-out.
*                                    Copy from method HU_CONTENT_READ and make changes for IM HU Picking.
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 12.18.2019   SRAWAT        1           D10K9A3RUB /  Initial version
*&---------------------------------------------------------------------*
***********************************************************************
* PROGRAM DECLARATION
***********************************************************************
* Method:             HU_CONTENT_READ_DFS
* AUTHOR Name:        Frank Wang
* OWNER(Process Team):Lakshmikumar Reddy
* CREATE DATE:        4/1/2016
* ECC RELEASE VERSION 6.0
* BASED-ON PROGRAM:   none
* Object ID:          E0300,E0301,E0302,E0303,E0305
* DESCRIPTION :       Read Handling Unit content for US DFS roll-out.
*                     Copy from method HU_CONTENT_READ and make changes.
***********************************************************************
* VERSION CONTROL (Most recent on top):
* DATE             AUTHOR       CTS REQ        DESCRIPTION
*----------------------------------------------------------------------
* 4/1/2016      Frank Wang    ED2K908004       Initial
    TYPES : BEGIN OF ty_hu,
              exidv TYPE exidv,
            END OF ty_hu.
    DATA: lv_hu_id       TYPE exidv,
          lv_hu_venum    TYPE venum,
          flag_pal       TYPE c,
          lv_dummy       TYPE string,
          lt_hu_header   TYPE STANDARD TABLE OF bapihuheader,
          lt_hu_number   TYPE STANDARD TABLE OF bapihunumber,
          lt_hu_item     TYPE zthu_item_tab,
          lt_bapi_ret    TYPE bapiret2_t,
          ls_hu_content  TYPE LINE OF zthu_item_tab,
          lv_index       TYPE i,
          ls_batch_data  TYPE LINE OF zsits_batch_data_tab,
          lt_batch_data  TYPE zsits_batch_data_tab,
          ls_batch_stock TYPE zsits_batch_stock,
          lv_uevel       TYPE uevel,
          lit_hu         TYPE STANDARD TABLE OF ty_hu,
          lwa_hu         TYPE ty_hu.

    FIELD-SYMBOLS: <fs_huno_line> LIKE LINE OF lt_hu_number,
                   <fs_bapi_ret>  LIKE LINE OF lt_bapi_ret,
                   <fs_hu_header> LIKE LINE OF lt_hu_header.


    CLEAR es_hu_content.

    CHECK iv_hu_id IS NOT INITIAL.

* Convert the import HU# into internal format
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = iv_hu_id
      IMPORTING
        output = lv_hu_id.

* Check the HU# whether exist or not

    SELECT exidv venum INTO (lv_hu_id, lv_hu_venum) UP TO 1 ROWS FROM vekp WHERE exidv = lv_hu_id.
    ENDSELECT.

    IF sy-subrc NE 0.
*Required handling units could not be found
      MESSAGE e010(huselect) INTO lv_dummy.
      RETURN.
    ENDIF.

*Begin of add for DFS roll-out by wangf on 4/1/2016
* Check if the handling unit status is in inventory
    IF is_hu_in_inv( iv_hu_id ) EQ abap_false. "handling unit not in inventory(e.g. Goods Issued)
      MESSAGE e000(zitsus) WITH iv_hu_id INTO lv_dummy.
*   HU &1 not in inventory
      RETURN.
    ENDIF.
*End of add for DFS roll-out by wangf on 4/1/2016



**** check if the HU is carton or Pallet HU
    CLEAR : lt_hu_number.
    SELECT SINGLE uevel "UEVEL higher level HU
      FROM vekp
      INTO lv_uevel
      WHERE exidv = iv_hu_id.
    IF sy-subrc = 0 AND lv_uevel IS NOT INITIAL.  "it means its a carton HU
*Prepare the external HU id for BAPI-call* SINGLE CARTON HU
      flag_pal = ' '.
      APPEND INITIAL LINE TO lt_hu_number ASSIGNING <fs_huno_line>.
      <fs_huno_line>-hu_exid = lv_hu_id.
    ELSE.  "empty means a pallet HU
*Prepare the external HU id for BAPI-call* For all the cartons and pallet as well.
      flag_pal = 'X'.

      "this is the pallet level hu addition
      APPEND INITIAL LINE TO lt_hu_number ASSIGNING <fs_huno_line>.
      <fs_huno_line>-hu_exid = lv_hu_id.
      APPEND <fs_huno_line> TO lt_hu_number.
      SELECT exidv
        FROM vekp
        INTO TABLE lit_hu
        WHERE uevel = lv_hu_venum.
      IF sy-subrc = 0.
        LOOP AT lit_hu INTO lwa_hu. "this is the carton level hu addition
*          APPEND INITIAL LINE TO lt_hu_number ASSIGNING <fs_huno_line>.
          <fs_huno_line>-hu_exid = lwa_hu-exidv.
          APPEND <fs_huno_line> TO lt_hu_number.
        ENDLOOP.
      ENDIF.
    ENDIF.

********************
*Prepare the external HU id for BAPI-call*
*    APPEND INITIAL LINE TO lt_hu_number ASSIGNING <fs_huno_line>.
*    <fs_huno_line>-hu_exid = lv_hu_id.

* Call BAPI to get the HU content
    CALL FUNCTION 'BAPI_HU_GETLIST'
      EXPORTING
        notext    = abap_true
        onlykeys  = abap_false
      TABLES
        hunumbers = lt_hu_number
        huheader  = lt_hu_header
        huitem    = lt_hu_item
        return    = lt_bapi_ret.

    IF zcl_its_utility=>conv_bapiret_to_msg( lt_bapi_ret ) = abap_true.

      LOOP AT lt_hu_header ASSIGNING <fs_hu_header> WHERE hu_exid = lv_hu_id.
* HU Header
        MOVE-CORRESPONDING <fs_hu_header> TO es_hu_content-hu_header.
* HU Item
        MOVE lt_hu_item TO  es_hu_content-hu_content.
        IF flag_pal <> 'X'. "if carton , then only keep HU data,
          DELETE es_hu_content-hu_content WHERE hu_exid NE lv_hu_id.
        ENDIF.

      ENDLOOP.

    ENDIF.

* Check the logon location is whether match with the scanned object
*------------------------------------------------------------------------------------------
*Begin of change for DFS roll-out by wangf on 4/1/2016
*  IF zcl_its_utility=>is_location_match( is_hu_data  = es_hu_content ) = abap_false.
    IF zcl_its_utility=>is_location_match_dfs( is_hu_data  = es_hu_content ) = abap_false.
*End of change for DFS roll-out by wangf on 4/1/2016
      CLEAR es_hu_content.
      RETURN.

    ENDIF.

    CLEAR: lt_bapi_ret, lt_hu_header, lt_hu_number, lt_hu_item, flag_pal.
  ENDMETHOD.


  METHOD inb_delivery_update2.

    TYPES: BEGIN OF ty_split,
             string TYPE char40,
           END OF ty_split,
           BEGIN OF ty_hukey,
             hukey TYPE bapihukey-hu_exid,
           END OF ty_hukey.

    DATA: lv_vbeln          TYPE vbeln_vl,
          lit_delivery_item TYPE TABLE OF bapiibdlvitemchg,
          lw_item           TYPE bapiibdlvitemchg,
          lit_item_control  TYPE TABLE OF bapiibdlvitemctrlchg,
          lw_item_control   TYPE bapiibdlvitemctrlchg,
          lw_header_data    TYPE bapiibdlvhdrchg,
          lw_vendor         TYPE bapibatchatt,
          lw_attribute      TYPE bapibatchatt,
          lv_batch1         TYPE bapibatchkey-batch,
          lv_vendor         TYPE lifnr,
          lw_header_control TYPE bapiibdlvhdrctrlchg,
          lv_delivery       TYPE bapiibdlvhdrchg-deliv_numb,
          lt_split          TYPE TABLE OF ty_split,
          lw_split          TYPE ty_split,
          lv_posnr          TYPE posnr_vl VALUE '900001',
          lt_batch_log      TYPE STANDARD TABLE OF prott,
          x_label_content   TYPE zsits_label_content,
          lv_dummy          TYPE string.

    DATA: lt_dsp            TYPE TABLE OF ty_hu,
          lt_hu             TYPE TABLE OF ty_hu,
          lw_dsp            TYPE ty_hu,
          lw_hu             TYPE ty_hu,
          lv_qty            TYPE lfimg,
          lv_lfimg          TYPE lfimg,
          lt_batch          TYPE TABLE OF ty_batch,
          gs_headerproposal TYPE bapihuhdrproposal,
          gt_itemsproposal  TYPE STANDARD TABLE OF bapihuitmproposal,
          gs_itemsproposal  LIKE LINE OF gt_itemsproposal,
          gt_return         TYPE TABLE OF bapiret2,
          gt_return1        TYPE TABLE OF bapiret2,
          gt_return2        TYPE TABLE OF bapiret2,
          lv_car_mat        TYPE vhilm,
          lv_pal_mat        TYPE vhilm,
          ls_header         TYPE bapihuheader,
          lt_header         TYPE TABLE OF bapihuheader,
          lv_hukey          TYPE bapihukey-hu_exid,
          lt_hukey          TYPE TABLE OF ty_hukey,
          lw_hukey          TYPE ty_hukey,
          lv_lines          TYPE i,
          lv_tabix          TYPE i,
          lv_index          TYPE i,
          lv_vhilm          TYPE vhilm,
          lv_flag           TYPE flag,
          lv_exidv          TYPE exidv,
          lv_batch          TYPE charg_d.

    CONSTANTS: lc_exidv     TYPE memoryid VALUE 'EXIDV',
               lc_id        TYPE zd_hu VALUE '1',
               lc_id1       TYPE zd_hu VALUE '2',
               lv_cart_type TYPE c VALUE '3',
               lv_pal_type  TYPE c VALUE '1',
               lc_p(1)      TYPE c VALUE 'P',
               lc_c(1)      TYPE c VALUE 'C',
               lc_b(1)      TYPE c VALUE 'B',
               lc_e(1)      TYPE c VALUE 'E',
               lc_zero(1)   TYPE c VALUE '0'.

    CLEAR: lt_dsp[], lw_item, gs_itemsproposal, gs_headerproposal, lv_vhilm, lv_batch, lv_flag, gt_return[], lt_batch[], lv_lines, lv_batch, lv_lfimg, lt_hu[],
           lit_delivery_item[], lw_header_data, lw_header_control, lv_delivery, lit_item_control[], lw_item_control, lv_tabix, lv_index, lw_hu, lv_qty.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = delivery
      IMPORTING
        output = lv_vbeln.

    lv_delivery = lv_vbeln.
    lv_flag = abap_false.
    lt_batch[] = it_batch[].
    lt_hu[] = it_hu[].
    DESCRIBE TABLE lt_batch LINES lv_lines.
** get item details
    SELECT SINGLE vbeln,
                  posnr,
                  matnr,
                  werks,
                  lgort,
                  charg,
                  lfimg,
                  meins,
                  vrkme,
                  umvkz,
                  umvkn,
                  lgmng
            INTO @DATA(lw_lips) FROM lips
            WHERE vbeln = @lv_vbeln
            AND   posnr = @posnr.
** Update Batch
    IF sy-subrc EQ lc_zero.
      lw_header_data-deliv_numb = lv_delivery.
      lw_header_control-deliv_numb = lv_delivery.
      lw_item-deliv_numb = lv_delivery.
      lw_item-material = lw_lips-matnr.
      IF lw_lips-umvkz IS NOT INITIAL AND lw_lips-umvkn IS NOT INITIAL.
        lw_item-fact_unit_nom = lw_lips-umvkz.
        lw_item-fact_unit_denom = lw_lips-umvkn.
      ELSE.
        lw_item-fact_unit_nom = gc_umvkz.
        lw_item-fact_unit_denom = gc_umvkn.
      ENDIF.
      lw_item_control-deliv_numb = lv_delivery.
      lw_item_control-chg_delqty = abap_true.

      IF lv_lines > 1.  "For batch split cases, batches has to be created first
        SELECT SINGLE lifnr FROM likp INTO lv_vendor
                                      WHERE vbeln = lv_vbeln.
        LOOP AT lt_batch INTO DATA(lw_batch).
          CLEAR: lv_batch.
          lv_batch = lw_batch-batch.
          SELECT SINGLE charg INTO @DATA(lv_charg)
                              FROM mch1 WHERE matnr = @lw_lips-matnr
                                         AND  charg = @lv_batch.
          IF sy-subrc <> lc_zero.
            lw_vendor-vendor_no = lv_vendor.
            CALL FUNCTION 'BAPI_BATCH_CREATE'
              EXPORTING
                material        = lw_lips-matnr
                batch           = lv_batch
                plant           = lw_lips-werks
                batchattributes = lw_vendor
              IMPORTING
                batch           = lv_batch1
                batchattributes = lw_attribute
              TABLES
                return          = gt_return.

            READ TABLE gt_return INTO DATA(lw_return1) WITH KEY type = lc_e.
            IF sy-subrc EQ lc_zero.
              RAISE batch_create_failed.
              lv_flag = abap_true.
            ELSE.
              CLEAR: gt_return[].
              COMMIT WORK AND WAIT.
            ENDIF.

          ENDIF.
        ENDLOOP.
      ENDIF.
      CLEAR: lv_batch, lv_batch1.

      IF lv_flag IS INITIAL.
        IF lv_lines EQ 1. " in case of only header batch
          lw_item-deliv_item = lw_lips-posnr.
          IF batch IS NOT INITIAL.
            lw_item-batch = batch.
          ELSE.
            READ TABLE it_hu INTO lw_dsp WITH KEY typ = lc_p.
            IF sy-subrc EQ lc_zero.
              lw_item-batch = lw_dsp-batch.
            ENDIF.
          ENDIF.
          lw_item-dlv_qty = lw_lips-lfimg.
          lw_item-dlv_qty_imunit = lw_lips-lfimg.
          APPEND lw_item TO lit_delivery_item[].
          lw_item_control-deliv_item = lw_lips-posnr.
          APPEND lw_item_control TO lit_item_control[].

        ELSEIF lv_lines > 1. " in case of batch split
          SELECT vbeln,
                 posnr,
                 uecha
            INTO TABLE @DATA(lt_lips) FROM lips WHERE vbeln = @lw_lips-vbeln
                                                AND   uecha <> '000000'.  " checking the last batch split for a delivery
          IF sy-subrc EQ lc_zero.
            SORT lt_lips BY posnr DESCENDING.
            READ TABLE lt_lips INTO DATA(lw_lips1) INDEX 1.
            IF sy-subrc EQ lc_zero.
              CLEAR: lv_posnr.
              lv_posnr = lw_lips1-posnr + 1.
            ENDIF.
          ENDIF.
          SORT lt_hu BY batch.

          LOOP AT lt_batch INTO lw_batch.
            lv_batch = lw_batch-batch.
            SELECT SINGLE charg INTO @lv_batch1
                          FROM lips WHERE vbeln = @lv_vbeln
                                     AND  charg = @lv_batch
                                     AND  uecha = @posnr.  " check if batch is already updated for batch split
            IF sy-subrc <> lc_zero.
              lv_tabix = lv_tabix + 1.
              IF lv_tabix > 1.
                lv_posnr = lv_posnr + 1.
              ENDIF.
              lw_item-deliv_item = lw_item_control-deliv_item = lv_posnr.
              lw_item-batch = lw_batch-batch.
              READ TABLE lt_hu INTO lw_hu WITH KEY batch = lw_batch-batch. " calculating the quantity for a batch
              IF sy-subrc EQ lc_zero.
                lv_index = sy-tabix.
                LOOP AT lt_hu INTO lw_hu FROM lv_index.
                  IF lw_hu-batch <> lw_batch-batch.
                    EXIT.
                  ELSE.
                    lv_lfimg = lw_hu-qty.
                    lv_qty = lv_qty + lv_lfimg.
                  ENDIF.
                  CLEAR: lv_lfimg.
                ENDLOOP.
              ENDIF.
              lw_item-dlv_qty = lv_qty .
              lw_item-dlv_qty_imunit = lv_qty.
              lw_item-hieraritem = lw_lips-posnr.
              lw_item-usehieritm = lc_id.
              APPEND lw_item TO lit_delivery_item[].
              APPEND lw_item_control TO lit_item_control[].
              CLEAR: lv_qty, lw_hu.
            ENDIF.
            CLEAR: lv_batch, lv_batch1.
          ENDLOOP.

        ENDIF.

        IF lw_lips-charg IS INITIAL AND lit_delivery_item[] IS NOT INITIAL.
          CALL FUNCTION 'BAPI_INB_DELIVERY_CHANGE'
            EXPORTING
              header_data    = lw_header_data
              header_control = lw_header_control
              delivery       = lv_delivery
            TABLES
              item_data      = lit_delivery_item[]
              item_control   = lit_item_control[]
              return         = gt_return[].

          IF gt_return[] IS INITIAL.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = abap_true.
          ELSEIF gt_return[] IS NOT INITIAL.
            READ TABLE gt_return INTO DATA(lw_return) WITH KEY type = lc_e.
            IF sy-subrc <> lc_zero.
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait = abap_true.
            ELSEIF sy-subrc EQ lc_zero.
              lv_flag = abap_true.
              MESSAGE e515 RAISING batch_failed.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF lv_flag IS INITIAL.
        IF it_hu[] IS NOT INITIAL.
          lt_dsp[] = it_hu[].
        ENDIF.

        SELECT SINGLE mtart FROM mara
                INTO @DATA(lv_mtart) WHERE matnr = @lw_lips-matnr.
        IF lv_mtart IS NOT INITIAL.
          SELECT SINGLE pack_matnr
                      FROM zlpack_mat
                      INTO lv_pal_mat
                      WHERE werks = lw_lips-werks
                      AND  mtart = lv_mtart
                      AND  hu_id = lc_id1.
        ELSE.
          SELECT SINGLE pack_matnr
                     FROM zlpack_mat
                     INTO lv_pal_mat
                     WHERE werks = lw_lips-werks
                     AND  hu_id = lc_id1.
        ENDIF.

        gs_headerproposal-hu_exid_type  = lv_pal_type.
        lv_vhilm = gs_headerproposal-pack_mat = lv_pal_mat.
        gs_headerproposal-plant = lw_lips-werks.
        gs_headerproposal-stge_loc = lw_lips-lgort.
        gs_headerproposal-hu_status_init = lc_b.

        gs_itemsproposal-stge_loc = lw_lips-lgort.
**Create PaLlet HU
        LOOP AT lt_dsp INTO lw_dsp WHERE typ = lc_p.
          lv_exidv = lw_dsp-hu.

          FREE MEMORY ID lc_exidv.
          EXPORT lv_exidv FROM lv_exidv TO MEMORY ID lc_exidv.
          CLEAR: gt_return1[], ls_header, lv_hukey.

          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
            EXPORTING
              percentage = 50
              text       = 'HU Creation in Progress:'(001)
            EXCEPTIONS
              OTHERS     = 1.

          CALL FUNCTION 'BAPI_HU_CREATE'
            EXPORTING
              headerproposal = gs_headerproposal
            IMPORTING
              huheader       = ls_header
              hukey          = lv_hukey
            TABLES
              return         = gt_return1.

          IF ls_header IS NOT INITIAL AND lv_hukey IS NOT INITIAL.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = abap_true.
            APPEND ls_header TO lt_header[].
            APPEND lv_hukey TO lt_hukey[].
          ELSE.
            MESSAGE e524 RAISING pallet_failed.
            RETURN.
          ENDIF.
        ENDLOOP.
***Create Carton HU
        IF lv_mtart IS NOT INITIAL.
          SELECT SINGLE pack_matnr
                      FROM zlpack_mat
                      INTO lv_car_mat
                      WHERE werks = lw_lips-werks
                      AND   mtart = lv_mtart
                      AND  hu_id = lc_id.
        ELSE.
          SELECT SINGLE pack_matnr
                      FROM zlpack_mat
                      INTO lv_car_mat
                      WHERE werks = lw_lips-werks
                      AND  hu_id = lc_id.
        ENDIF.

        LOOP AT lt_dsp INTO lw_dsp WHERE typ = lc_c.
          CLEAR: gs_headerproposal, gs_itemsproposal,gt_return1[], ls_header, lv_hukey.
          gs_headerproposal-pack_mat = lv_car_mat.
          gs_headerproposal-hu_status_init = lc_b.
          gs_itemsproposal-hu_item_type = lv_cart_type.
          gs_itemsproposal-material = lw_lips-matnr.
          IF lv_lines > 1.
            gs_itemsproposal-batch = lw_dsp-batch.
          ENDIF.
          gs_itemsproposal-plant = lw_lips-werks.
          gs_itemsproposal-hu_item_type = lc_id.
          gs_itemsproposal-pack_qty = lw_dsp-qty.
          APPEND gs_itemsproposal TO gt_itemsproposal.
          lv_exidv = lw_dsp-hu.
          FREE MEMORY ID lc_exidv.
          EXPORT lv_exidv FROM lv_exidv TO MEMORY ID lc_exidv.

          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
            EXPORTING
              percentage = 50
              text       = 'HU Creation in Progress:'(001)
            EXCEPTIONS
              OTHERS     = 1.

          CALL FUNCTION 'BAPI_HU_CREATE'
            EXPORTING
              headerproposal = gs_headerproposal
            IMPORTING
              huheader       = ls_header
              hukey          = lv_hukey
            TABLES
              itemsproposal  = gt_itemsproposal
              return         = gt_return1.

          IF ls_header IS NOT INITIAL AND lv_hukey IS NOT INITIAL.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = abap_true.
            APPEND ls_header TO lt_header[].
            APPEND lv_hukey TO lt_hukey[].
            CLEAR: gt_itemsproposal.
          ELSE.
            MESSAGE e523 RAISING carton_failed.
            RETURN.
          ENDIF.
        ENDLOOP.

      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD is_batch_allowed_for_ship_hu.

    DATA: ls_t001l           TYPE t001l,
          ls_line            TYPE ztotc_res_batch,
          ls_batch_key       TYPE zsits_batch_key,
          lv_inspec_lot_lock TYPE boolean,
          lv_im_status       TYPE char1,
          ls_qi_status       TYPE zsits_status,
          lit_res_batch      TYPE STANDARD TABLE OF ztotc_res_batch,
          ls_res_batch       TYPE ztotc_res_batch,
          lv_dummy           TYPE bapi_msg.

    rv_allowed =  abap_false.

    IF is_delivery IS INITIAL AND iv_werks IS NOT INITIAL AND iv_lgort IS NOT INITIAL.
* -------1> For STO batch check, plant and storage location is imported

      SELECT SINGLE * INTO ls_t001l FROM t001l WHERE werks = iv_werks AND lgort = iv_lgort.

      CHECK sy-subrc EQ 0.

      SELECT * INTO ls_line
        FROM ztotc_res_batch
       WHERE vkorg = ls_t001l-vkorg
         AND vtweg = ls_t001l-vtweg
         AND spart = ls_t001l-spart
         AND kunnr = ls_t001l-kunnr
         AND werks = ls_t001l-werks.
      ENDSELECT.

      IF sy-subrc EQ 0.
        rv_allowed =  abap_true.
      ENDIF.

    ENDIF.

    IF is_delivery IS NOT INITIAL AND is_batch_data IS NOT INITIAL AND iv_werks IS NOT INITIAL.

* ---------2> For delivery batch check, delivery header, and plant is imported

* Lock carton batch (in case another user tries to change batch status)
*----------------------------------------------------------------------
      ls_batch_key-charg = is_batch_data-charg.
      ls_batch_key-matnr = is_batch_data-matnr.

      MOVE-CORRESPONDING is_batch_data TO ls_batch_key.
      IF zcl_batch_utility=>batch_lock( is_batch_key = ls_batch_key ) IS INITIAL.
*   Lock batch failed
        RETURN.
      ENDIF.

*lock inspection lot
*----------------------------------------------------------------------
      IF is_batch_data-insp_lot_data IS NOT INITIAL.
        CALL METHOD zcl_batch_utility=>inspec_loc_lock_process
          EXPORTING
            iv_unlock            = abap_false
            iv_inspec_lot_number = is_batch_data-insp_lot_data-prueflos
          RECEIVING
            rv_result            = lv_inspec_lot_lock.

        IF lv_inspec_lot_lock = abap_false.
*     Lock inspection lot falied
          RETURN.
        ENDIF.
      ENDIF.

* Check IM/batch/QI status : skipping

* checking from the custom table for status:

      SELECT * FROM ztotc_res_batch
        INTO TABLE lit_res_batch
        WHERE kunnr = is_delivery-kunnr
        AND werks = iv_werks.

      IF sy-subrc = 0.
        LOOP AT lit_res_batch INTO ls_res_batch.
          IF ls_res_batch-qi_status = '0'.
            rv_allowed = abap_false.
            MESSAGE e434(zits) WITH is_batch_data-charg INTO lv_dummy.

          ELSE.
            rv_allowed = abap_true.
          ENDIF.
        ENDLOOP.
      ELSE.
        rv_allowed =  abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.


METHOD is_hu_in_inv.
************************************************************************
************************************************************************
* Program ID:
* Created By:                        Kripa S Patil
* Creation Date:                     02.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:                       Check if the HU status is in inventory for DFS roll-out
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


*  TYPES: BEGIN OF lty_stat,
*           stat  TYPE j_status,
*         END OF lty_stat.

  DATA: lv_hu_number  TYPE exidv,
        lv_hu_status  TYPE hu_status.
*        lv_venum      TYPE venum,
*        lv_objnr      TYPE j_objnr,
*        lwa_stat     TYPE lty_stat,
*        lit_stat     TYPE STANDARD TABLE OF lty_stat,
*        lit_var TYPE rseloption, "Variant table
*        lr_in_inv_stat TYPE RANGE OF j_status.

*  FIELD-SYMBOLS: <ls_stat> TYPE lty_stat.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = iv_hu_id
    IMPORTING
      output = lv_hu_number.


* Should not get system status of HU to check if it's in inventory or not
* Instead should check field vepo-hu_lgort. If it's blank then it's not in inventory.

*  SELECT SINGLE venum INTO lv_venum FROM vekp WHERE exidv = lv_hu_number.
*  IF sy-subrc EQ 0. "HU exist
**   Get object number for the handling unit
*    CONCATENATE 'HU' lv_venum INTO lv_objnr.
**   Select active system status of the handling unit
*    SELECT stat INTO TABLE lit_stat FROM husstat
*      WHERE objnr = lv_objnr AND inact = space.
*    IF sy-subrc EQ 0.
**     Get the handling unit in inventory status defined in TVARVC
*      CALL METHOD zcl_common_utility=>parameter_read
*        EXPORTING
*          iv_name   = gc_vname_hu_in_inv
*          iv_type   = 'S'
*        IMPORTING
*          et_tvarvc = lit_var
**         ev_return =
*        .
*      IF lit_var IS INITIAL. "handling unit in inventory status NOT defined in TVARVC
*        rv_result = abap_false.
*        RETURN.
*      ENDIF.
*      lr_in_inv_stat = lit_var.
**     Check if any of the active system status is not in inventory
*      LOOP AT lit_stat ASSIGNING <ls_stat>.
*        IF <ls_stat>-stat NOT IN lr_in_inv_stat.
*          rv_result = abap_false.
*          RETURN.
*        ENDIF.
*      ENDLOOP.
*      rv_result = abap_true.
*      RETURN.
*    ELSE. "No active system status
*      rv_result = abap_false.
*      RETURN.
*    ENDIF.
*
*  ELSE."HU NOT exist
*    rv_result = abap_false.
*    RETURN.
*  ENDIF.

  SELECT SINGLE status INTO lv_hu_status FROM vekp WHERE exidv = lv_hu_number.
  IF sy-subrc = 0. "HU exist
    CASE lv_hu_status.
      WHEN '0050' OR '0060'. "HU NOT in inventory.
        rv_result = abap_false.
      WHEN OTHERS. "HU is in inventory
        rv_result = abap_true.
    ENDCASE.

  ELSE. "HU NOT exist
    rv_result = abap_false.
  ENDIF.

ENDMETHOD.


METHOD is_hu_managed_sloc.
  DATA:lv_xhupf TYPE c.
* Check if the Storage location is HU managed
  SELECT SINGLE xhupf INTO lv_xhupf
    FROM t001l
    WHERE werks = iv_werks
      AND lgort = iv_lgort.
  IF sy-subrc = 0 AND lv_xhupf = abap_true.
    RAISE hu_managed.
  ENDIF.
ENDMETHOD.


METHOD is_location_match.
************************************************************************
************************************************************************
* Program ID:                        IS_LOCATION_MATCH
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
  DATA: lv_tcode        TYPE tcode,
        ls_tran_setting TYPE ztits_scan_code,
        ls_user_profile TYPE zsits_user_profile,
        lv_hu_id        TYPE exidv,
        lv_su_id        TYPE lenum,
        lv_dummy        TYPE bapi_msg.

*  IF sy-tcode = 'ZITSREPROCESS'.  " Deleted by May Huang - 20150805
  IF sy-tcode = 'ZITSREPROCESS' OR sy-cprog = 'ZITS_REPROCESS'.  " Inserted by May Huang - 20150805
*No need to do below check for Reprocess
    rv_result =  abap_true.
    RETURN.
  ENDIF.

  rv_result =  abap_false.

  IF iv_transaction_code IS NOT SUPPLIED.
    lv_tcode = sy-tcode.
  ELSE.
    lv_tcode = iv_transaction_code.
  ENDIF.

* Check the setting of scan transaction
  SELECT SINGLE * INTO ls_tran_setting FROM ztits_scan_code WHERE tcode = lv_tcode.
  IF sy-subrc NE 0.
* Transaction & is not a scanning program
    MESSAGE e001 WITH lv_tcode INTO lv_dummy.
    RETURN.
  ENDIF.

  IF ls_tran_setting-zzloc_check EQ abap_false.
* Not required to do the loction match check.
    rv_result =  abap_true.
    RETURN.
  ENDIF.

*Get user profile
  ls_user_profile = zcl_its_utility=>get_user_profile( ).

  IF is_batch_data IS SUPPLIED.

    IF ls_user_profile-zzwerks IS NOT INITIAL.

      IF is_batch_data-werks NE ls_user_profile-zzwerks OR
         is_batch_data-batch_stock_wm IS NOT INITIAL.
*Your current location is not match with the scan object
        MESSAGE e442 WITH ls_user_profile-zzwerks is_batch_data-charg INTO lv_dummy.
        RETURN.
      ENDIF.

    ELSEIF ls_user_profile-zzlgnum IS NOT INITIAL.

      READ TABLE is_batch_data-batch_stock_wm TRANSPORTING NO FIELDS WITH KEY lgnum = ls_user_profile-zzlgnum.
      IF sy-subrc NE 0.
*Batch located in warehouse and not allowed for this transaction
        MESSAGE e460 WITH ls_user_profile-zzlgnum is_batch_data-charg INTO lv_dummy.
        RETURN.
      ENDIF.

    ENDIF.

  ENDIF.
  IF is_hu_data IS SUPPLIED.

    lv_hu_id = is_hu_data-hu_header-hu_exid.

    SHIFT lv_hu_id LEFT DELETING LEADING '0'.

    CASE ls_tran_setting-zzscan_area .                                       " ED2K906244
      WHEN zcl_its_utility=>gc_tran_area_im .                                " ED2K906244

        IF ls_user_profile-zzwerks IS NOT INITIAL.

          IF ( is_hu_data-hu_header-plant NE  ls_user_profile-zzwerks AND
             is_hu_data-hu_header-plant            IS  NOT INITIAL  ) OR     " ED2K906244
             is_hu_data-hu_header-warehouse_number IS  NOT INITIAL .
*Your current location is not match with the scan object
            MESSAGE e442 WITH ls_user_profile-zzwerks lv_hu_id INTO lv_dummy.
            RETURN.
          ENDIF.

        ENDIF.

      WHEN zcl_its_utility=>gc_tran_area_wm .                                " ED2K906244
        IF ls_user_profile-zzlgnum IS NOT INITIAL.

          IF is_hu_data-hu_header-warehouse_number NE ls_user_profile-zzlgnum AND
             is_hu_data-hu_header-warehouse_number IS NOT INITIAL .          " ED2K906244
*Your current location is not match with the scan object
            MESSAGE e442 WITH ls_user_profile-zzlgnum lv_hu_id INTO lv_dummy.
            RETURN.
          ENDIF.
        ENDIF.

      WHEN OTHERS.

        IF ( is_hu_data-hu_header-warehouse_number NE ls_user_profile-zzlgnum AND
             is_hu_data-hu_header-warehouse_number IS NOT INITIAL ).

*Your current location is not match with the scan object
          MESSAGE e442 WITH ls_user_profile-zzlgnum lv_hu_id INTO lv_dummy.
          RETURN.

        ELSE.

          IF is_hu_data-hu_header-plant NE  ls_user_profile-zzwerks AND
             is_hu_data-hu_header-plant IS  NOT INITIAL.
*Your current location is not match with the scan object
            MESSAGE e442 WITH ls_user_profile-zzwerks lv_hu_id INTO lv_dummy.
            RETURN.
          ENDIF.
        ENDIF.

    ENDCASE.                                                                 " ED2K906244

  ENDIF.
  IF is_su_data IS SUPPLIED.
* SU is always WH managed
    lv_su_id = is_su_data-su_header-lenum.

    SHIFT lv_su_id LEFT DELETING LEADING '0'.

    IF is_su_data-su_header-lgnum NE ls_user_profile-zzlgnum.
*Your current location is not match with the scan object
      MESSAGE e442 WITH ls_user_profile-zzlgnum lv_su_id INTO lv_dummy.
      RETURN.
    ENDIF.

  ENDIF.

  rv_result = abap_true.

ENDMETHOD.


METHOD is_location_match_dfs.
************************************************************************
************************************************************************
* Program ID:
* Created By:                        Kripa S Patil
* Creation Date:                     03.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:                       Check location match for US DFS roll-out.
*                                    Copy from method IS_LOCATION_MATCH and make changes.
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 03.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*

  DATA: lv_tcode        TYPE tcode,
        ls_tran_setting TYPE ztits_scan_code,
        ls_user_profile TYPE zsits_user_profile,
        lv_hu_id        TYPE exidv,
        lv_su_id        TYPE lenum,
        lv_dummy        TYPE bapi_msg.

*  IF sy-tcode = 'ZITSREPROCESS'.  " Deleted by May Huang - 20150805
*Begin of change for DFS roll-out by wangf on 4/13/2016
*  IF sy-tcode = 'ZITSREPROCESS' OR sy-cprog = 'ZITS_REPROCESS'.  " Inserted by May Huang - 20150805
  IF sy-tcode = 'ZSRP' OR sy-cprog = 'ZITS_REPROCESS_DFS'.
*End of change for DFS roll-out by wangf on 4/13/2016
*No need to do below check for Reprocess
    rv_result =  abap_true.
    RETURN.
  ENDIF.

  rv_result =  abap_true.    ##STMNT_EXIT
  RETURN.
  rv_result =  abap_false.

  IF iv_transaction_code IS NOT SUPPLIED.
    lv_tcode = sy-tcode.
  ELSE.
    lv_tcode = iv_transaction_code.
  ENDIF.

* Check the setting of scan transaction
  SELECT SINGLE * INTO ls_tran_setting FROM ztits_scan_code WHERE tcode = lv_tcode.
  IF sy-subrc NE 0.
* Transaction & is not a scanning program
    MESSAGE e001 WITH lv_tcode INTO lv_dummy.
    RETURN.
  ENDIF.

  IF ls_tran_setting-zzloc_check EQ abap_false.
* Not required to do the loction match check.
    rv_result =  abap_true.
    RETURN.
  ENDIF.

*Get user profile
  ls_user_profile = zcl_its_utility=>get_user_profile( ).

  IF is_batch_data IS SUPPLIED.

    IF ls_user_profile-zzwerks IS NOT INITIAL.

      IF is_batch_data-werks NE ls_user_profile-zzwerks OR
         is_batch_data-batch_stock_wm IS NOT INITIAL.
*Your current location is not match with the scan object
*        MESSAGE e442 WITH ls_user_profile-zzwerks is_batch_data-charg INTO lv_dummy.
        RETURN.
      ENDIF.

    ELSEIF ls_user_profile-zzlgnum IS NOT INITIAL.

      READ TABLE is_batch_data-batch_stock_wm TRANSPORTING NO FIELDS WITH KEY lgnum = ls_user_profile-zzlgnum.
      IF sy-subrc NE 0.
*Batch located in warehouse and not allowed for this transaction
        MESSAGE e460 WITH ls_user_profile-zzlgnum is_batch_data-charg INTO lv_dummy.
        RETURN.
      ENDIF.

    ENDIF.

  ENDIF.
  IF is_hu_data IS SUPPLIED.

    lv_hu_id = is_hu_data-hu_header-hu_exid.

    SHIFT lv_hu_id LEFT DELETING LEADING '0'.

    CASE ls_tran_setting-zzscan_area .
      WHEN zcl_its_utility=>gc_tran_area_im .

        IF ls_user_profile-zzwerks IS NOT INITIAL.

          IF ( is_hu_data-hu_header-plant NE  ls_user_profile-zzwerks AND
             is_hu_data-hu_header-plant            IS  NOT INITIAL  ) OR
             is_hu_data-hu_header-warehouse_number IS  NOT INITIAL .
*Your current location is not match with the scan object
*            MESSAGE e442 WITH ls_user_profile-zzwerks lv_hu_id INTO lv_dummy.
            RETURN.
          ENDIF.

        ENDIF.

      WHEN zcl_its_utility=>gc_tran_area_wm .
        IF ls_user_profile-zzlgnum IS NOT INITIAL.

          IF is_hu_data-hu_header-warehouse_number NE ls_user_profile-zzlgnum AND
             is_hu_data-hu_header-warehouse_number IS NOT INITIAL .
*Your current location is not match with the scan object
*            MESSAGE e442 WITH ls_user_profile-zzlgnum lv_hu_id INTO lv_dummy.
            RETURN.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
*Begin of change for DFS roll-out by wangf on 4/1/2016

*        IF ( is_hu_data-hu_header-warehouse_number NE ls_user_profile-zzlgnum AND
*             is_hu_data-hu_header-warehouse_number IS NOT INITIAL ).
*
**Your current location is not match with the scan object
*          MESSAGE e442 WITH ls_user_profile-zzlgnum lv_hu_id INTO lv_dummy.
*          RETURN.
*
*        ELSE.
*
*          IF is_hu_data-hu_header-plant NE  ls_user_profile-zzwerks AND
*             is_hu_data-hu_header-plant IS  NOT INITIAL.
**Your current location is not match with the scan object
*            MESSAGE e442 WITH ls_user_profile-zzwerks lv_hu_id INTO lv_dummy.
*            RETURN.
*          ENDIF.
*        ENDIF.

        IF ls_user_profile-zzwerks IS NOT INITIAL.

          IF ( is_hu_data-hu_header-plant NE  ls_user_profile-zzwerks AND
             is_hu_data-hu_header-plant            IS  NOT INITIAL  ) OR
             is_hu_data-hu_header-warehouse_number IS  NOT INITIAL .
*Your current location is not match with the scan object
*            MESSAGE e442 WITH ls_user_profile-zzwerks lv_hu_id INTO lv_dummy.
            RETURN.
          ENDIF.

        ENDIF.

        IF ls_user_profile-zzlgnum IS NOT INITIAL.

          IF ( is_hu_data-hu_header-warehouse_number NE ls_user_profile-zzlgnum AND
             is_hu_data-hu_header-warehouse_number IS NOT INITIAL ) OR
             ( is_hu_data-hu_header-warehouse_number IS INITIAL AND
              is_hu_data-hu_header-plant IS NOT INITIAL ).
*Your current location is not match with the scan object
*            MESSAGE e442 WITH ls_user_profile-zzlgnum lv_hu_id INTO lv_dummy.
            RETURN.
          ENDIF.
        ENDIF.


    ENDCASE.

  ENDIF.
  IF is_su_data IS SUPPLIED.
* SU is always WH managed
    lv_su_id = is_su_data-su_header-lenum.

    SHIFT lv_su_id LEFT DELETING LEADING '0'.

    IF is_su_data-su_header-lgnum NE ls_user_profile-zzlgnum.
*Your current location is not match with the scan object
*      MESSAGE e442 WITH ls_user_profile-zzlgnum lv_su_id INTO lv_dummy.
      RETURN.
    ENDIF.

  ENDIF.

  rv_result = abap_true.

ENDMETHOD.


METHOD is_orbatch_check_required.
************************************************************************
************************************************************************
* Program ID:                        IS_ORBATCH_CHECK_REQUIRED
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
  DATA: lt_data TYPE ztits_scan_var_tab.
  FIELD-SYMBOLS:<fs_line> LIKE LINE OF lt_data.

  rv_result = abap_false.

  lt_data = zcl_its_utility=>its_variable_value_get( iv_variant = gc_var_or_batch_check_required )."

  IF lt_data IS NOT INITIAL.

    LOOP AT lt_data TRANSPORTING NO FIELDS WHERE zzpar_value = iv_tran_code.
      EXIT.
    ENDLOOP.

    IF sy-subrc EQ 0.
      rv_result = abap_true.
    ENDIF.

  ENDIF.

ENDMETHOD.


METHOD is_proc_order_exist.

  DATA: lv_aufnr TYPE aufnr,
        ls_afko TYPE afko,
        lv_dummy TYPE string.

  rv_result = abap_false.

  lv_aufnr = is_scan_dynp-zzprocord.
* Format Conversion External -> Internal
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lv_aufnr
    IMPORTING
      output = lv_aufnr.

  SELECT SINGLE * INTO ls_afko FROM afko WHERE aufnr = lv_aufnr.

  IF sy-subrc NE 0.
*Order & & & not found (check entry)
    MESSAGE e017(co) WITH is_scan_dynp-zzprocord INTO lv_dummy.
    RETURN.
  ENDIF.

  rv_result = abap_true.

ENDMETHOD.


  method IS_QTY_VALID.

  DATA: lv_dummy TYPE bapi_msg.

  rv_result = abap_false.

  CALL FUNCTION 'MOVE_CHAR_TO_NUM'
    EXPORTING
      chr             = iv_qty
    EXCEPTIONS
      convt_no_number = 1
      convt_overflow  = 2
      OTHERS          = 3.
  IF sy-subrc EQ 1.
    MESSAGE e352(zits) WITH iv_qty INTO lv_dummy.
    RETURN.
  ELSEIF sy-subrc EQ 2.
    MESSAGE e353(zits) WITH iv_qty INTO lv_dummy.
    RETURN.
  ENDIF.

  rv_result = abap_true.
  endmethod.


METHOD is_res_batch_allowed_for_ship.
* There are two scenarios that could use this method to check if batch is allowed
* 1> For STO batch check, plant and storage location is imported
* 2> For delivery batch check, delivery header, plant, and batch data is imported

  DATA: ls_t001l           TYPE t001l,
        ls_line            TYPE ztotc_res_batch,
        ls_batch_key       TYPE zsits_batch_key,
        lv_inspec_lot_lock TYPE boolean,
        lv_im_status       TYPE char1,
        ls_qi_status       TYPE zsits_status,
        lit_res_batch      TYPE STANDARD TABLE OF ztotc_res_batch,
        ls_res_batch       TYPE ztotc_res_batch,
        lv_dummy           TYPE bapi_msg.

  rv_allowed =  abap_false.

  IF is_delivery IS INITIAL AND iv_werks IS NOT INITIAL AND iv_lgort IS NOT INITIAL.
* -------1> For STO batch check, plant and storage location is imported

    SELECT SINGLE * INTO ls_t001l FROM t001l WHERE werks = iv_werks AND lgort = iv_lgort.

    CHECK sy-subrc EQ 0.

    SELECT * INTO ls_line
      FROM ztotc_res_batch
     WHERE vkorg = ls_t001l-vkorg
       AND vtweg = ls_t001l-vtweg
       AND spart = ls_t001l-spart
       AND kunnr = ls_t001l-kunnr
       AND werks = ls_t001l-werks.
    ENDSELECT.

    IF sy-subrc EQ 0.
      rv_allowed =  abap_true.
    ENDIF.

  ENDIF.

  IF is_delivery IS NOT INITIAL AND is_batch_data IS NOT INITIAL AND iv_werks IS NOT INITIAL.
* ---------2> For delivery batch check, delivery header, and plant is imported

* Lock carton batch (in case another user tries to change batch status)
*----------------------------------------------------------------------
    ls_batch_key-charg = is_batch_data-charg.
    ls_batch_key-matnr = is_batch_data-matnr.

    MOVE-CORRESPONDING is_batch_data TO ls_batch_key.
    IF zcl_batch_utility=>batch_lock( is_batch_key = ls_batch_key ) IS INITIAL.
*   Lock batch failed
      RETURN.
    ENDIF.

* Lock inspection lot
*----------------------------------------------------------------------
    IF is_batch_data-insp_lot_data IS NOT INITIAL.
      CALL METHOD zcl_batch_utility=>inspec_loc_lock_process
        EXPORTING
          iv_unlock            = abap_false
          iv_inspec_lot_number = is_batch_data-insp_lot_data-prueflos
        RECEIVING
          rv_result            = lv_inspec_lot_lock.

      IF lv_inspec_lot_lock = abap_false.
*     Lock inspection lot falied
        RETURN.
      ENDIF.
    ENDIF.

* Check IM/batch/QI status
*----------------------------------------------------------------------
    lv_im_status = zcl_batch_utility=>get_im_status( is_batch_data = is_batch_data ).
    ls_qi_status = zcl_batch_utility=>get_qi_status( is_batch_data = is_batch_data ).

    SELECT * FROM ztotc_res_batch INTO TABLE lit_res_batch WHERE kunnr = is_delivery-kunnr
      AND werks = iv_werks.
*   check if ship-to party and corresponding plant is maintained in the ZOTC table

    IF sy-subrc = 0.
*   if delivery ship-to party is maintained in table ZTOTC_RES_BATCH CUSTOMER field
      IF ( lv_im_status = zcl_batch_utility=>gc_im_status_unrestrict OR lv_im_status IS INITIAL )
        AND is_batch_data-zustd = abap_false
        AND ls_qi_status-txt04 = zcl_its_utility=>gc_user_status_avl.
        rv_allowed = abap_true.
        RETURN.
      ENDIF.

      LOOP AT lit_res_batch INTO ls_res_batch.
        IF (  lv_im_status        = zcl_batch_utility=>gc_im_status_restrict OR lv_im_status IS INITIAL )
        AND   is_batch_data-zustd = abap_true
        AND ( ls_qi_status-txt04  = ls_res_batch-qi_status OR ls_res_batch-qi_status IS INITIAL ).
          rv_allowed = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

    ELSE.
*   if delivery ship-to party is not maintained in the table
      IF ( lv_im_status = zcl_batch_utility=>gc_im_status_unrestrict OR lv_im_status IS INITIAL )
        AND is_batch_data-zustd = abap_false
        AND ls_qi_status-txt04 = zcl_its_utility=>gc_user_status_avl.
        rv_allowed = abap_true.
      ENDIF.
    ENDIF.

    IF rv_allowed = abap_false.
*   Batch &1 has IM/batch/QI lot status that's not allowed for picking
      MESSAGE e434(zits) WITH is_batch_data-charg INTO lv_dummy.
    ENDIF.

  ENDIF.
ENDMETHOD.


METHOD IS_SU.
************************************************************************
************************************************************************
* Program ID:                        IS_SU
* Created By:                        Kripa S Patil
* Creation Date:                     03.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:                       Check if the HU is a SU for DFS roll-out
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


  DATA: lv_su_number  TYPE lenum.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = iv_su_id
    IMPORTING
      output = lv_su_number.

  SELECT SINGLE lenum INTO lv_su_number FROM lein WHERE lenum = lv_su_number.
  IF sy-subrc NE 0. "Not a Storage unit
    rv_result = abap_false.
  ELSE. "Is a Storage unit.
    rv_result = abap_true.
  ENDIF.
ENDMETHOD.


METHOD its_variable_value_get.
************************************************************************
************************************************************************
* Program ID:                        ITS_VARIABLE_VALUE_GET
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
  TYPES: BEGIN OF lty_range_var,
           sign      TYPE char1,
           option    TYPE char2,
           low       TYPE zzpara1,
           high      TYPE zzpara2,
         END   OF lty_range_var.

  DATA: lv_variant   TYPE zzpara1,
        lt_r_var1    TYPE STANDARD TABLE OF lty_range_var,
        lt_r_var2    TYPE STANDARD TABLE OF lty_range_var,
        lt_r_var3    TYPE STANDARD TABLE OF lty_range_var,
        lt_r_var4    TYPE STANDARD TABLE OF lty_range_var,
        ls_r_line    TYPE lty_range_var.

  ls_r_line-sign   = 'I'.
  ls_r_line-option = 'EQ'.

  IF iv_para1 IS SUPPLIED.
    lv_variant    =  iv_para1.
    ls_r_line-low =  lv_variant.
    APPEND ls_r_line TO lt_r_var1.
  ENDIF.

  IF iv_para2 IS SUPPLIED.
    lv_variant    =  iv_para2.
    ls_r_line-low =  lv_variant.
    APPEND ls_r_line TO lt_r_var2.
  ENDIF.

  IF iv_para3 IS SUPPLIED.
    lv_variant    =  iv_para3.
    ls_r_line-low =  lv_variant.
    APPEND ls_r_line TO lt_r_var3.
  ENDIF.

  IF iv_para4 IS SUPPLIED.
    lv_variant    =  iv_para4.
    ls_r_line-low =  lv_variant.
    APPEND ls_r_line TO lt_r_var4.
  ENDIF.

  SELECT * INTO TABLE rt_value
    FROM ztits_scan_var
   WHERE variant = iv_variant
     AND zzpara1 IN lt_r_var1
     AND zzpara2 IN lt_r_var2
     AND zzpara3 IN lt_r_var3
     AND zzpara4 IN lt_r_var4.


ENDMETHOD.


METHOD leave_2_new_trans.

  CALL METHOD log_object_clear
    CHANGING
      co_log = co_log.
* Leave to new transaction
  LEAVE TO TRANSACTION gc_new_tran.  " ZTITS_NTRAN

ENDMETHOD.


METHOD log_message_add.
************************************************************************
************************************************************************
* Program ID:                        LOG_MESSAGE_ADD
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
  DATA: ls_line           TYPE ztits_scan_log,
        lt_data           TYPE ztits_scan_var_tab,
        lv_log_save_delay TYPE xfeld.

  FIELD-SYMBOLS: <fs_line> LIKE LINE OF lt_data.

* Step will be the sequetial number
  me->gs_log_key-zzscan_step = me->gs_log_key-zzscan_step + 1.

* Move the key
  MOVE-CORRESPONDING   me->gs_log_key TO ls_line.

  IF iv_object_type IS INITIAL.
    MOVE gc_objtp_field TO ls_line-zzscan_objtp. " Default as Field always
  ELSE.
    MOVE iv_object_type TO ls_line-zzscan_objtp.
  ENDIF.

  MOVE:
        iv_object_id   TO ls_line-zzscan_objid,
        iv_content     TO ls_line-zzscan_content.

  IF iv_with_message = abap_true.

    MOVE: sy-msgid TO ls_line-zzmsg_id,
          sy-msgty TO ls_line-zzmsg_type,
          sy-msgno TO ls_line-zzmsg_no.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = sy-msgid
        msgnr               = sy-msgno
        msgv1               = sy-msgv1
        msgv2               = sy-msgv2
        msgv3               = sy-msgv3
        msgv4               = sy-msgv4
      IMPORTING
        message_text_output = ls_line-zzmsg_line.

  ENDIF.

* Time of scan

  ls_line-zzcrdat = sy-datlo.   " Creation Date   ED2K904822 Local timezone
  ls_line-zzcrtim = sy-timlo.   " Creation Time   ED2K904822 Local timezone
  ls_line-zzcrnam = sy-uname.   " Creation By

* Scanning transaction
  ls_line-zzscan_code = me->gv_scan_code.

  APPEND ls_line TO me->gt_log_data.

* Try to get the variant value LOG_SAVE_DELAY, if abap_true, means the log save will be only
* triggered at time of the method-call LOG_OBJECT_CLEAR. Otherwise, everytime any input/action
* will save the log directly into DB

  lt_data = zcl_its_utility=>its_variable_value_get( iv_variant = gc_var_log_save_delay ).

  IF lt_data IS NOT INITIAL.

    READ TABLE lt_data INDEX 1 ASSIGNING <fs_line>.

    IF <fs_line> IS ASSIGNED.

      lv_log_save_delay = <fs_line>-zzpar_value.
    ENDIF.

  ENDIF.

  IF lv_log_save_delay = abap_false.

    me->log_save( ).

    CLEAR me->gt_log_data.

  ENDIF.

ENDMETHOD.


METHOD log_object_clear.
************************************************************************
************************************************************************
* Program ID:                        LOG_OBJECT_CLEAR
* Created By:                        Kripa S Patil
* Creation Date:                     08.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 09.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*

  DATA:   lt_data           TYPE ztits_scan_var_tab,
          lv_log_save_delay TYPE xfeld.

  FIELD-SYMBOLS: <fs_line> LIKE LINE OF lt_data.


  IF co_log IS BOUND.

* Try to get the variant value LOG_SAVE_DELAY, if abap_false, everytime any input/action
* will save the log directly into DB , otherwise the DB saving will only occur while method
* LOG_OBJECT_CLEAR is triggered

    lt_data = zcl_its_utility=>its_variable_value_get( iv_variant = gc_var_log_save_delay ).

    IF lt_data IS NOT INITIAL.

      READ TABLE lt_data INDEX 1 ASSIGNING <fs_line>.

      IF <fs_line> IS ASSIGNED.

        lv_log_save_delay = <fs_line>-zzpar_value.
      ENDIF.

    ENDIF.

    IF lv_log_save_delay = abap_true.
* Save the log data/
      CALL METHOD co_log->log_save( ).

    ENDIF.

* Free the log instance
    FREE co_log.
    CLEAR co_log.

  ENDIF.

  CALL FUNCTION 'DEQUEUE_ALL'.
ENDMETHOD.


METHOD LOG_OFF.
************************************************************************
************************************************************************
* Program ID:                        LOG_OFF
* Created By:                        Kripa S Patil
* Creation Date:                     08.JAN.2019
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
* 09.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*

  CALL METHOD log_object_clear
    CHANGING
      co_log = co_log.

  CALL FUNCTION 'DEQUEUE_ALL'.
*{ Changed by Raphael   2014/10/02  Logoff from system
  CALL 'SYST_LOGOFF'.
*} Changed by Raphael   2014/10/02  Logoff from system

ENDMETHOD.


METHOD LOG_SAVE.
************************************************************************
************************************************************************
* Program ID:                        LOG_SAVE
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
  CHECK me->gt_log_data IS NOT INITIAL.

* Scan log table is just to insert , no update/cancel will occurs except the periodically housekeeping
* hence not log required

  INSERT ztits_scan_log FROM TABLE me->gt_log_data ACCEPTING DUPLICATE KEYS.

ENDMETHOD.


METHOD material_read.
************************************************************************
************************************************************************
* Program ID:                        MATERIAL_READ
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
  DATA: lv_matnr TYPE matnr,
        lit_t320 TYPE STANDARD TABLE OF t320,
        lit_wm   TYPE zttits_material_wm_stock,
        lv_dummy TYPE bapi_msg.

  FIELD-SYMBOLS: <ls_t320> TYPE t320,
                 <ls_im_stock> TYPE zsits_material_im_stock,
                 <ls_wm_stock> TYPE zsits_material_wm_stock.

  CHECK is_key IS NOT INITIAL.

* Leading Zero
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = is_key-matnr
    IMPORTING
      output = lv_matnr.


* Get material master data
  SELECT SINGLE matnr
                lvorm
                mtart
                matkl
                meins
                xchpf
  FROM mara
  INTO CORRESPONDING FIELDS OF rs_material_data
  WHERE matnr = lv_matnr.

  IF sy-subrc = 0.

* try to fetch the material category from table ZTITS_MTART.
    SELECT SINGLE zzcap_mattype
    FROM ztits_mtart
    INTO CORRESPONDING FIELDS OF rs_material_data
    WHERE mtart = rs_material_data-mtart.

    IF sy-subrc NE 0.
      MESSAGE e374(zits) WITH rs_material_data-mtart INTO lv_dummy.
      CLEAR rs_material_data.
      RETURN.
    ENDIF.

* Get material stock
    CHECK is_key-stock_read = 'X'.


* IM Stock
    SELECT matnr
           werks
           lgort
           lvorm
           labst
           umlme
           insme
           einme
           speme
           retme
    FROM mard
    INTO CORRESPONDING FIELDS OF TABLE rs_material_data-im_stock
    WHERE matnr = lv_matnr
      AND lvorm <> 'X'.

    IF sy-subrc = 0.

* Get WM management plant and storage location
      SELECT *
      FROM t320
      INTO CORRESPONDING FIELDS OF TABLE lit_t320
      FOR ALL ENTRIES IN rs_material_data-im_stock
      WHERE werks = rs_material_data-im_stock-werks
        AND lgort = rs_material_data-im_stock-lgort.

      IF sy-subrc = 0.

        SORT lit_t320 BY werks lgort.

      ENDIF.

      LOOP AT rs_material_data-im_stock ASSIGNING <ls_im_stock>.

        READ TABLE lit_t320 ASSIGNING <ls_t320> WITH KEY werks = <ls_im_stock>-werks
                                                         lgort = <ls_im_stock>-lgort
                                                        BINARY SEARCH.
        IF sy-subrc = 0.

          APPEND INITIAL LINE TO lit_wm ASSIGNING <ls_wm_stock>.

          MOVE-CORRESPONDING <ls_im_stock> TO <ls_wm_stock>.
          MOVE-CORRESPONDING <ls_t320>     TO <ls_wm_stock>.

        ENDIF.

      ENDLOOP.


* WM Stock
      IF lit_wm[] IS NOT INITIAL.

        SELECT lgnum
               matnr
               werks
               lgort
               sobkz
               lgtyp
               lgpla
               gesme
               verme
               einme
               ausme
               bestq
        FROM lqua
        INTO CORRESPONDING FIELDS OF TABLE rs_material_data-wm_stock
        FOR ALL ENTRIES IN lit_wm
        WHERE lgnum = lit_wm-lgnum
          AND werks = lit_wm-werks
          AND lgort = lit_wm-lgort
          AND matnr = lit_wm-matnr.

      ENDIF.

    ENDIF.

  ENDIF.



ENDMETHOD.


  METHOD material_read_dfds.
************************************************************************
************************************************************************
* Program ID:                        MATERIAL_READ
* Created By:                        Nagaraju Polisetty
* Creation Date:                     07.FEB.2019
* Capsugel / Lonza RICEFW ID:        S0096
* Description:                       As the existing method has some custom
*    validations specific to Capsugel system, created the copy of that
*    method and removing those conditions
*    For WM stock: Added the batch in the where condition of the LQUA table query
*    For Im Stock: Since we need the stock batch wise replaced the MARD with MCHB
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 03.JAN.19   NPOLISETTY      1           D10K9A37KD  /  Initial version
* 03.MAY.19   NPOLISETTY      2           D10K9A3HEN / Hyper care ticket #84
*&---------------------------------------------------------------------*
    DATA: lv_matnr TYPE matnr,
          lit_t320 TYPE STANDARD TABLE OF t320,
          lit_wm   TYPE zttits_material_wm_stock,
          lv_dummy TYPE bapi_msg.

    DATA: ls_imstock TYPE zsits_material_im_stock.

    FIELD-SYMBOLS: <ls_t320>     TYPE t320,
                   <ls_im_stock> TYPE zsits_material_im_stock,
                   <ls_wm_stock> TYPE zsits_material_wm_stock.

    CHECK is_key IS NOT INITIAL.

* Leading Zero
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = is_key-matnr
      IMPORTING
        output = lv_matnr.


* Get material master data
    SELECT SINGLE matnr
                  lvorm
                  mtart
                  matkl
                  meins
                  xchpf
    FROM mara
    INTO CORRESPONDING FIELDS OF rs_material_data
    WHERE matnr = lv_matnr.

    IF sy-subrc = 0.

* Get material stock
      CHECK is_key-stock_read = 'X'.

* IM Stock
*-- Begin of insert for Hypercare defect
*-- Uncommenting for hypercare defect
      IF iv_batch IS INITIAL.
        SELECT matnr
               werks
               lgort
               lvorm
               labst
               umlme
               insme
               einme
               speme
               retme
        FROM mard
        INTO CORRESPONDING FIELDS OF TABLE rs_material_data-im_stock
        WHERE matnr = lv_matnr
          AND lvorm <> 'X'.
*-- End of insert for Hyper care defect
      ELSE.
        SELECT matnr,
               werks,
               lgort,
               lvorm,
               clabs,      "labst, Unrestricted stock
               cumlm,      "umlme, stock in transfer
               cinsm,      "insme, In Quality Insp.
               ceinm,      "einme, Restricted-Use Stock
               cspem,      "speme, Blocked
               cretm       "retme, Returns
        FROM mchb
        INTO TABLE @DATA(lt_mchb)
          "CORRESPONDING FIELDS OF TABLE rs_material_data-im_stock
        WHERE matnr = @lv_matnr
          AND charg = @iv_batch
          AND lvorm <> 'X'.

        IF sy-subrc = 0.
********************
          LOOP AT lt_mchb INTO DATA(ls_mchb).
            ls_imstock-matnr = ls_mchb-matnr.
            ls_imstock-werks = ls_mchb-werks.
            ls_imstock-lgort = ls_mchb-lgort.
            ls_imstock-lvorm = ls_mchb-lvorm.
            ls_imstock-labst = ls_mchb-clabs.
            ls_imstock-umlme = ls_mchb-cumlm.
            ls_imstock-insme = ls_mchb-cinsm.
            ls_imstock-einme = ls_mchb-ceinm.
            ls_imstock-speme = ls_mchb-cspem.
            ls_imstock-retme = ls_mchb-cretm.
            APPEND ls_imstock TO rs_material_data-im_stock.
            CLEAR: ls_imstock.
          ENDLOOP.
        ENDIF. "MCHB check
      ENDIF.  "Batch check
*************************
* Get WM management plant and storage location
      IF rs_material_data-im_stock IS NOT INITIAL.
        SELECT *
        FROM t320
        INTO CORRESPONDING FIELDS OF TABLE lit_t320
        FOR ALL ENTRIES IN rs_material_data-im_stock
        WHERE werks = rs_material_data-im_stock-werks
          AND lgort = rs_material_data-im_stock-lgort.

        IF sy-subrc = 0.

          SORT lit_t320 BY werks lgort.

        ENDIF.

        LOOP AT rs_material_data-im_stock ASSIGNING <ls_im_stock>.

          READ TABLE lit_t320 ASSIGNING <ls_t320> WITH KEY werks = <ls_im_stock>-werks
                                                           lgort = <ls_im_stock>-lgort
                                                          BINARY SEARCH.
          IF sy-subrc = 0.

            APPEND INITIAL LINE TO lit_wm ASSIGNING <ls_wm_stock>.

            MOVE-CORRESPONDING <ls_im_stock> TO <ls_wm_stock>.
            MOVE-CORRESPONDING <ls_t320>     TO <ls_wm_stock>.

          ENDIF.

        ENDLOOP.


* WM Stock
        IF lit_wm[] IS NOT INITIAL.

          SELECT lgnum
                 matnr
                 werks
                 lgort
                 sobkz
                 lgtyp
                 lgpla
                 gesme
                 verme
                 einme
                 ausme
                 bestq
          FROM lqua
          INTO CORRESPONDING FIELDS OF TABLE rs_material_data-wm_stock
          FOR ALL ENTRIES IN lit_wm
          WHERE lgnum = lit_wm-lgnum
            AND werks = lit_wm-werks
            AND lgort = lit_wm-lgort
            AND matnr = lit_wm-matnr
            AND charg = iv_batch.

        ENDIF. "WM stock check
      ENDIF.  "IM stock check
    ENDIF.   "MARA select
  ENDMETHOD.


METHOD material_read_dfs.
************************************************************************
************************************************************************
* Program ID:
* Created By:                        Kripa S Patil
* Creation Date:                     03.JAN.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024
* Description:                       Read material data without batch as well as stock
*                                    for US DFS roll-out.
*                                    Copy from method MATERIAL_READ_DFS and make changes.
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


  DATA: lv_matnr TYPE matnr,
        lit_t320 TYPE STANDARD TABLE OF t320,
        lit_wm   TYPE zttits_material_wm_stock,
        lv_dummy TYPE bapi_msg,
        lx_logon_profile  TYPE zsits_user_profile,
        lv_plant          TYPE werks_d,
        lv_warehouse      TYPE lgnum,
        lr_plant          TYPE RANGE OF werks_d,
        lr_plant_line     LIKE LINE OF lr_plant,
        lr_warehouse      TYPE RANGE OF lgnum,
        lr_warehouse_line LIKE LINE OF lr_warehouse,
        lr_sloc           TYPE RANGE OF lgort_d,
        lr_sloc_line      LIKE LINE OF lr_sloc.


  FIELD-SYMBOLS: <ls_t320> TYPE t320,
                 <ls_im_stock> TYPE zsits_material_im_stock_dfs,
                 <ls_wm_stock> TYPE zsits_material_wm_stock.

  CHECK is_key IS NOT INITIAL.

* Leading Zero
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = is_key-matnr
    IMPORTING
      output = lv_matnr.


* Get material master data
  SELECT SINGLE matnr
                lvorm
                mtart
                matkl
                meins
                xchpf
  FROM mara
  INTO CORRESPONDING FIELDS OF rs_material_data
  WHERE matnr = lv_matnr.

  IF sy-subrc = 0.

*try to fetch the material category from table ZTITS_MTART.
    SELECT SINGLE zzcap_mattype
    FROM ztits_mtart
    INTO CORRESPONDING FIELDS OF rs_material_data
    WHERE mtart = rs_material_data-mtart.

    IF sy-subrc NE 0.
      MESSAGE e374(zits) WITH rs_material_data-mtart INTO lv_dummy.
      CLEAR rs_material_data.
      RETURN.
    ENDIF.

* Get material stock
    CHECK is_key-stock_read = 'X'.


    IF iv_plant IS INITIAL AND iv_warehouse IS INITIAL.
* The stock data will be only for the logon location
* 1> Assume call the scan transaction should be triggered thru ZITSELOGON scan .
* 2> For reprocess program, no logon data could be found, we have to use another approach to catch the original logon data
* 3> For programs other than ITS, no logon data could be find,the return stock is not correct.

      CALL METHOD zcl_its_utility=>get_user_profile
        RECEIVING
          rs_user_profile = lx_logon_profile.

      lv_plant     = lx_logon_profile-zzwerks.
      lv_warehouse = lx_logon_profile-zzlgnum.

    ELSEIF iv_plant IS NOT INITIAL AND iv_warehouse IS NOT INITIAL.
      RETURN.
    ELSE.
      lv_plant     = iv_plant.
      lv_warehouse =  iv_warehouse.
    ENDIF.

    IF lv_plant IS NOT INITIAL.
      lr_plant_line-sign   = 'I'.
      lr_plant_line-option = 'EQ'.
      lr_plant_line-low    = lv_plant.
      APPEND lr_plant_line TO lr_plant.
    ENDIF.

    IF lv_warehouse IS NOT INITIAL.
      lr_warehouse_line-sign   = 'I'.
      lr_warehouse_line-option = 'EQ'.
      lr_warehouse_line-low    = lv_warehouse.
      APPEND lr_warehouse_line TO lr_warehouse.
*     Get the Plant/Storage Location which the warehouse is assigned to
      CLEAR lit_t320.
      SELECT * INTO TABLE lit_t320 FROM t320 WHERE lgnum = lv_warehouse.
      LOOP AT lit_t320 ASSIGNING <ls_t320>.
        lr_plant_line-sign   = 'I'.
        lr_plant_line-option = 'EQ'.
        lr_plant_line-low    = <ls_t320>-werks.
        APPEND lr_plant_line TO lr_plant.

        lr_sloc_line-sign   = 'I'.
        lr_sloc_line-option = 'EQ'.
        lr_sloc_line-low    = <ls_t320>-lgort.
        APPEND lr_sloc_line TO lr_sloc.
      ENDLOOP.
      CLEAR lit_t320.
    ENDIF.

* IM Stock
    SELECT matnr
           werks
           lgort
           lvorm
           labst
           umlme
           insme
           einme
           speme
           retme
    FROM mard
    INTO CORRESPONDING FIELDS OF TABLE rs_material_data-im_stock
    WHERE matnr = lv_matnr

      AND werks IN lr_plant
      AND lgort IN lr_sloc
      AND lvorm <> 'X'.

    IF sy-subrc = 0.

      DELETE rs_material_data-im_stock WHERE labst = 0
                                         AND umlme = 0
                                         AND insme = 0
                                         AND speme = 0
                                         AND einme = 0.
      IF rs_material_data-im_stock IS INITIAL.
        RETURN.
      ENDIF.

* Get WM management plant and storage location
      SELECT *
      FROM t320
      INTO CORRESPONDING FIELDS OF TABLE lit_t320
      FOR ALL ENTRIES IN rs_material_data-im_stock
      WHERE werks = rs_material_data-im_stock-werks
        AND lgort = rs_material_data-im_stock-lgort.

      IF sy-subrc = 0.

        SORT lit_t320 BY werks lgort.

      ENDIF.

      LOOP AT rs_material_data-im_stock ASSIGNING <ls_im_stock>.

        <ls_im_stock>-zztotal_stock = <ls_im_stock>-labst
                                      + <ls_im_stock>-umlme
                                      + <ls_im_stock>-insme
                                      + <ls_im_stock>-einme
                                      + <ls_im_stock>-speme.

        READ TABLE lit_t320 ASSIGNING <ls_t320> WITH KEY werks = <ls_im_stock>-werks
                                                         lgort = <ls_im_stock>-lgort
                                                        BINARY SEARCH.
        IF sy-subrc = 0.

          APPEND INITIAL LINE TO lit_wm ASSIGNING <ls_wm_stock>.

          MOVE-CORRESPONDING <ls_im_stock> TO <ls_wm_stock>.
          MOVE-CORRESPONDING <ls_t320>     TO <ls_wm_stock>.

        ENDIF.

      ENDLOOP.


* WM Stock
      IF lit_wm[] IS NOT INITIAL.

        SELECT lgnum
               matnr
               werks
               lgort
               sobkz
               lgtyp
               lgpla
               gesme
               verme
               einme
               ausme
               bestq
               lenum
        FROM lqua
        INTO CORRESPONDING FIELDS OF TABLE rs_material_data-wm_stock
        FOR ALL ENTRIES IN lit_wm
        WHERE lgnum = lit_wm-lgnum
          AND werks = lit_wm-werks
          AND lgort = lit_wm-lgort
          AND matnr = lit_wm-matnr.

      ENDIF.

    ENDIF.

  ENDIF.

ENDMETHOD.


  method MESSAGE_CONFIRM.
*Popup for confirmation
  CALL FUNCTION 'ZCFE_MESSAGE_DISPLAY'
    EXPORTING
      iv_for_confirm    = abap_true
    IMPORTING
      ev_confirm_result = ev_result.
  endmethod.


  method MESSAGE_DISPLAY.
************************************************************************
************************************************************************
* Program ID:                        MESSAGE_DISPLAY
* Created By:                        Kripa S Patil
* Creation Date:                     29.Dec.2018
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
* 29.DEC.18   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
 CALL FUNCTION 'ZCFE_MESSAGE_DISPLAY'.
  endmethod.


METHOD OBJECT_STATUS_READ.

  DATA: lt_status        TYPE STANDARD TABLE OF jstat,
        lt_system_status TYPE STANDARD TABLE OF jstat,
        lt_user_status   TYPE STANDARD TABLE OF jstat.

  FIELD-SYMBOLS: <fs_status> TYPE jstat.

  CHECK is_key IS NOT INITIAL.

* We have to refresh the status buffer before the read
  CALL FUNCTION 'STATUS_BUFFER_REFRESH'.

  CALL FUNCTION 'STATUS_READ'
    EXPORTING
      client           = sy-mandt
      objnr            = is_key-zzobjnr
      only_active      = is_key-zzonly_actv
    TABLES
      status           = lt_status
    EXCEPTIONS
      object_not_found = 1
      OTHERS           = 2.

  SORT lt_status BY stat.

  IF is_key-zzonly_syst  = 'X'.

    APPEND LINES OF lt_status TO lt_system_status.
    DELETE lt_system_status WHERE stat+0(1) <> 'I'.
    IF lt_system_status[] IS NOT INITIAL.

      SELECT istat AS stat
             txt04
             txt30
      FROM tj02t
      INTO CORRESPONDING FIELDS OF TABLE rt_status
      FOR ALL ENTRIES IN lt_system_status
      WHERE istat = lt_system_status-stat
        AND spras = sy-langu.

    ENDIF.
  ENDIF.

  IF is_key-zzonly_user = 'X'.

    APPEND LINES OF lt_status TO lt_user_status.
    DELETE lt_user_status   WHERE stat+0(1) <> 'E'.
    IF NOT lt_user_status[] IS INITIAL.
      SELECT estat AS stat
             txt04
             txt30
      FROM tj30t
      APPENDING CORRESPONDING FIELDS OF TABLE rt_status
      FOR ALL ENTRIES IN lt_user_status
        WHERE stsma = is_key-zzstsma
          AND estat = lt_user_status-stat
          AND spras = sy-langu.

    ENDIF.
  ENDIF.

  SORT rt_status BY stat.

ENDMETHOD.


  method OUTB_DELIVERY_VALIDATE.

     DATA: ls_likp  TYPE likp,
        ls_vbuk  TYPE vbuk,
        lv_vbeln TYPE vbeln_vl,
        lv_dummy TYPE string.

  rv_result = abap_false.

  lv_vbeln = is_scan_dynp-zzoutb_delivery.
* Format Conversion External -> Internal
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lv_vbeln
    IMPORTING
      output = lv_vbeln.

  SELECT SINGLE * INTO ls_likp FROM likp WHERE vbeln = lv_vbeln.

  IF sy-subrc NE 0.
*Delivery &1 does not exist in the database or in the archive
    MESSAGE e559(vl) WITH is_scan_dynp-zzoutb_delivery INTO lv_dummy.
    RETURN.
  ENDIF.

  IF ls_likp-vbtyp NE gc_vbtyp_outb_delivery.  " VBTYP = 'J'.
*Document & 1 is not an outbound delivery
    MESSAGE e008 WITH is_scan_dynp-zzoutb_delivery INTO lv_dummy.
    RETURN.
  ENDIF.

  SELECT SINGLE * INTO ls_vbuk FROM vbuk WHERE vbeln = lv_vbeln.

  CHECK sy-subrc EQ 0.

  IF iv_pick_complete = abap_true.
* kostk = Overall picking / putaway status
* lvstk = Overall status of warehouse management activities
    IF ls_vbuk-kostk NE gc_doc_status_complete OR
       ls_vbuk-lvstk NE gc_doc_status_complete.     " lvstk is for WM only
* Pick of delivery &1 has not been completed yet
      MESSAGE e009 WITH is_scan_dynp-zzoutb_delivery INTO lv_dummy.
      RETURN.
    ENDIF.
  ELSE.
*--change by Ethan 01/22/2015----add WM status------------
*    IF ls_vbuk-kostk EQ gc_doc_status_complete .
    IF ( ls_vbuk-kostk EQ gc_doc_status_complete AND ls_vbuk-lvstk EQ space )
      OR ( ls_vbuk-kostk EQ gc_doc_status_complete AND ls_vbuk-lvstk EQ gc_doc_status_complete ).
*--change by Ethan 01/22/2015----add WM status------------
*     O/B delivery &1 already picked
      MESSAGE e266 WITH is_scan_dynp-zzoutb_delivery INTO lv_dummy.
      RETURN.
    ENDIF.
  ENDIF.

  IF ls_vbuk-wbstk EQ gc_doc_status_complete.
* PGI of delivery &1 has been completed
    MESSAGE e010 WITH is_scan_dynp-zzoutb_delivery INTO lv_dummy.
    RETURN.
  ENDIF.

  IF iv_ship_lane_check  EQ abap_true AND ls_likp-lgbzo NE is_scan_dynp-zzship_lane.
* Ship lane &1 doesn't match that of outb. delivery &2
    MESSAGE e011 WITH is_scan_dynp-zzship_lane  is_scan_dynp-zzoutb_delivery INTO lv_dummy.
    RETURN.
  ENDIF.

  rv_result = abap_true.

  endmethod.


  METHOD physinv_content_operation.
    DATA: lv_id TYPE char10.

    IF iv_id IS INITIAL.
      lv_id = 'ZIMPHYSINV'.
    ELSE.
      lv_id = iv_id.
    ENDIF.

    CASE iv_mode.

      WHEN 'S'.    "Save the contents

        EXPORT content = ct_content TO DATABASE indx(aa) ID lv_id.

      WHEN 'G'.    "Get the contents

        IMPORT content = ct_content FROM DATABASE indx(aa) ID lv_id.

      WHEN 'D'.    "Delete the contents

        DELETE FROM DATABASE indx(aa) ID lv_id.

    ENDCASE.
  ENDMETHOD.


  method PHYSINV_WM_COUNT.
  DATA:
    lv_dummy  TYPE bapi_msg,
    lt_linv_u TYPE TABLE OF  e1linvx.

  FIELD-SYMBOLS:
    <fs_linv>   LIKE LINE OF it_linv,
    <fs_linv_u> LIKE LINE OF lt_linv_u.

  rv_result = abap_false.

  LOOP AT it_linv ASSIGNING <fs_linv>.
    APPEND INITIAL LINE TO lt_linv_u ASSIGNING <fs_linv_u>.
    MOVE-CORRESPONDING <fs_linv> TO <fs_linv_u>.

*   zero count
    IF <fs_linv_u>-menga EQ 0.
      <fs_linv_u>-kznul = abap_true.
    ENDIF.

*   Special stock
    IF <fs_linv_u>-sobkz IS NOT INITIAL.
      <fs_linv_u>-lsonr = <fs_linv>-sonum.
    ENDIF.
  ENDLOOP.
  CALL FUNCTION 'L_INV_COUNT_EXT'
    TABLES
      s_linv                       = lt_linv_u
    EXCEPTIONS
      either_quantity_or_empty_bin = 1
      ivnum_not_found              = 2
      check_problem                = 3
      no_count_allowed             = 4
      l_inv_read                   = 5
      bin_not_in_ivnum             = 6
      counts_not_updated           = 7
      lock_error                   = 8
      OTHERS                       = 9.
  IF sy-subrc NE 0.
    MESSAGE ID     sy-msgid
            TYPE   sy-msgty
            NUMBER sy-msgno
            WITH   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            INTO   lv_dummy.

*    " Counted &1 failed.
*    MESSAGE e358(zits) INTO lv_dummy.
*    CASE sy-subrc.
*    	WHEN 1.
**        message
*    	WHEN 2.
*    	WHEN 3.
*    	WHEN 4.
*    	WHEN 5.
*    	WHEN 6.
*    	WHEN 7.
*    	WHEN 8.
*    	WHEN 9.
*    	WHEN OTHERS.
*    ENDCASE.
* Implement suitable error handling here
  ELSE.
    rv_result = abap_true.
  ENDIF.
*
  endmethod.


METHOD post_goods_movement.
************************************************************************
************************************************************************
* Program ID:                        POST_GOODS_MOVEMENT
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
  DATA: lwa_gm_header  TYPE bapi2017_gm_head_01,
        lwa_gm_code    TYPE bapi2017_gm_code,
        lwa_gm_item    TYPE bapi2017_gm_item_create,
        lwa_matnr_key  TYPE zsits_material_read_para,
        lit_gm_item    TYPE TABLE OF bapi2017_gm_item_create,
        lit_return     TYPE TABLE OF bapiret2,
        lv_mblnr       TYPE bapi2017_gm_head_ret-mat_doc,
        lv_mjahr       TYPE bapi2017_gm_head_ret-doc_year,
        lv_dummy       TYPE bapi_msg.

  FIELD-SYMBOLS: <ls_gm_item> TYPE zsits_gm_item,
                 <ls_return>  TYPE bapiret2.

*Goods movement header
  MOVE-CORRESPONDING is_goods_mvt TO lwa_gm_header.

*Goods movement code
  MOVE-CORRESPONDING is_goods_mvt TO lwa_gm_code.

*Goods movement item
  LOOP AT is_goods_mvt-gm_item ASSIGNING <ls_gm_item>.
    MOVE-CORRESPONDING <ls_gm_item> TO lwa_gm_item.

    lwa_matnr_key-matnr = lwa_gm_item-material.
*If the material posted is of type "I", then it is a WIP material
    IF zcl_its_utility=>material_read( is_key = lwa_matnr_key )-zzcap_mattype = zcl_its_utility=>gc_matcat_wip.
      CLEAR lwa_gm_item-spec_stock.
    ENDIF.
    CLEAR lwa_matnr_key.


    IF lwa_gm_item-sales_ord IS NOT INITIAL.
      lwa_gm_item-val_sales_ord  = lwa_gm_item-sales_ord.
      lwa_gm_item-val_s_ord_item = lwa_gm_item-s_ord_item.
    ENDIF.

    APPEND lwa_gm_item TO lit_gm_item.
    CLEAR lwa_gm_item.
  ENDLOOP.

*Post goods movement
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header       = lwa_gm_header
      goodsmvt_code         = lwa_gm_code
    IMPORTING
      materialdocument      = lv_mblnr
      matdocumentyear       = lv_mjahr
    TABLES
      goodsmvt_item         = lit_gm_item
      goodsmvt_serialnumber = is_goods_mvt-gm_serial
      return                = lit_return.

  READ TABLE lit_return ASSIGNING <ls_return> WITH KEY type = 'E'.

  IF sy-subrc = 0.

    MESSAGE ID         <ls_return>-id
            TYPE       <ls_return>-type
            NUMBER     <ls_return>-number
            INTO lv_dummy
            WITH       <ls_return>-message_v1
                       <ls_return>-message_v2
                       <ls_return>-message_v3
                       <ls_return>-message_v4.

  ELSE.

    CALL METHOD zcl_common_utility=>commit_work
      EXPORTING
        iv_option = iv_save_option.

    rv_document = lv_mblnr.

  ENDIF.

*** inactive new ***
ENDMETHOD.


  METHOD post_goods_movement_dfds.
************************************************************************
************************************************************************
* Program ID:                        POST_GOODS_MOVEMENT_DFDS
* Created By:                        Nagaraju Polisetty
* Creation Date:                     22.FEB.2019
* Capsugel / Lonza RICEFW ID:        E0301/S0024/E0092
* Description:                       To add return table in the export parameters
*                                    to send all the msgs coming form BAPI for
* Tcode     :
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 02.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
    DATA: lwa_gm_header TYPE bapi2017_gm_head_01,
          lwa_gm_code   TYPE bapi2017_gm_code,
          lwa_gm_item   TYPE bapi2017_gm_item_create,
          lwa_matnr_key TYPE zsits_material_read_para,
          lit_gm_item   TYPE TABLE OF bapi2017_gm_item_create,
          lit_return    TYPE TABLE OF bapiret2,
          lv_mblnr      TYPE bapi2017_gm_head_ret-mat_doc,
          lv_mjahr      TYPE bapi2017_gm_head_ret-doc_year,
          lv_dummy      TYPE bapi_msg.

    FIELD-SYMBOLS: <ls_gm_item> TYPE zsits_gm_item,
                   <ls_return>  TYPE bapiret2.

*Goods movement header
    MOVE-CORRESPONDING is_goods_mvt TO lwa_gm_header.

*Goods movement code
    MOVE-CORRESPONDING is_goods_mvt TO lwa_gm_code.

*Goods movement item
    LOOP AT is_goods_mvt-gm_item ASSIGNING <ls_gm_item>.
      MOVE-CORRESPONDING <ls_gm_item> TO lwa_gm_item.

      lwa_matnr_key-matnr = lwa_gm_item-material.
*If the material posted is of type "I", then it is a WIP material
      IF zcl_its_utility=>material_read( is_key = lwa_matnr_key )-zzcap_mattype = zcl_its_utility=>gc_matcat_wip.
        CLEAR lwa_gm_item-spec_stock.
      ENDIF.
      CLEAR lwa_matnr_key.


      IF lwa_gm_item-sales_ord IS NOT INITIAL.
        lwa_gm_item-val_sales_ord  = lwa_gm_item-sales_ord.
        lwa_gm_item-val_s_ord_item = lwa_gm_item-s_ord_item.
      ENDIF.

      APPEND lwa_gm_item TO lit_gm_item.
      CLEAR lwa_gm_item.
    ENDLOOP.

*Post goods movement
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header       = lwa_gm_header
        goodsmvt_code         = lwa_gm_code
      IMPORTING
        materialdocument      = lv_mblnr
        matdocumentyear       = lv_mjahr
      TABLES
        goodsmvt_item         = lit_gm_item
        goodsmvt_serialnumber = is_goods_mvt-gm_serial
        return                = lit_return.

    READ TABLE lit_return ASSIGNING <ls_return> WITH KEY type = 'E'.

    IF sy-subrc = 0.

      MESSAGE ID         <ls_return>-id
              TYPE       <ls_return>-type
              NUMBER     <ls_return>-number
              INTO lv_dummy
              WITH       <ls_return>-message_v1
                         <ls_return>-message_v2
                         <ls_return>-message_v3
                         <ls_return>-message_v4.

*-- Send the return table back incase of errors..
      et_return[] = lit_return[].

    ELSE.

      CALL METHOD zcl_common_utility=>commit_work
        EXPORTING
          iv_option = iv_save_option.

      rv_document = lv_mblnr.

    ENDIF.



*** inactive new ***
  ENDMETHOD.


  METHOD read_barcode_gelatin.
    TYPES: BEGIN OF ty_split,
             string TYPE char40,
           END OF ty_split.
    DATA: lv_barcode      TYPE string,
          lt_split        TYPE TABLE OF ty_split,
          lw_split        TYPE ty_split,
          x_label_content TYPE zsits_label_content,
          lv_char         TYPE string,
          lv_char1        TYPE string,
          lv_char_31      TYPE string,
          lv_dec1         TYPE string,
          lv_dec2         TYPE string,
          lv_char_dec(2)  TYPE c,
          lv_lines        TYPE i,
          lv_mod          TYPE i,
          lv_i1(10)       TYPE c,
          lv_i2(10)       TYPE c,
          lv_c1(10)       TYPE c,
          lv_len          TYPE i,
          lv_ln           TYPE i,
          lv_diff         TYPE i,
          lv_ln_31        TYPE i,
          gv_palhu        TYPE zd_hu_exid,
          gv_tophu        TYPE zd_hu_exid,
          gv_bothu        TYPE zd_hu_exid,
          lt_hu           TYPE ty_hut,
          lv_qty          TYPE lfimg,
          lv_qty1         TYPE lfimg,
          lv_qty2         TYPE lfimg,
          lv_count        TYPE i,
          lv_hu           TYPE zd_hu_exid,
          lw_hu           TYPE ty_hu.

    CONSTANTS: lc_zero(1) TYPE c VALUE '0',
               lc_c(1)    TYPE c VALUE 'C',
               lc_p(1)    TYPE c VALUE 'P',
               lc_l(1)    TYPE c VALUE 'L'.

    DATA: lv_index     TYPE sy-index.
    CLEAR: lv_barcode, lt_split[], lw_split,
           x_label_content, lv_char, gv_palhu, gv_tophu, gv_bothu, lt_hu[], lw_hu, lv_qty, lv_qty2,
           lv_qty1, lv_lines, lv_len, lv_ln, lv_mod, lv_count.
    lv_barcode = barcode.
    SPLIT lv_barcode AT ':' INTO TABLE lt_split.
    IF pallet EQ abap_true.
      type = lc_p.
      LOOP AT lt_split INTO lw_split.
        CLEAR: lv_char.
        IF lw_split-string(5) EQ ']C110'.
          CLEAR: lv_len, lv_ln.
          lv_len = strlen( lw_split-string ).
          lv_ln = lv_len - 5.
          lv_char = lw_split-string+5(lv_ln).
          CONDENSE lv_char.
          x_label_content-zzorigin_batch = lv_char.
        ENDIF.
        IF lw_split-string(3) EQ '241'.
          CLEAR: lv_len, lv_ln.
          lv_len = strlen( lw_split-string ).
          lv_ln = lv_len - 3.
          lv_char = lw_split-string+3(lv_ln).
          CONDENSE lv_char.
          x_label_content-zzmatnr = lv_char.
        ENDIF.
        IF lw_split-string(2) EQ '30'.
          CLEAR: lv_len, lv_ln.
          lv_len = strlen( lw_split-string ).
          lv_ln = lv_len - 2.
          lv_char = lw_split-string+2(lv_ln).
          CONDENSE lv_char.
          lv_qty1 = x_label_content-zzquantity = lv_char.
        ENDIF.
        IF lw_split-string(2) EQ '31'. "310200745, qty would be 7.45
          CLEAR: lv_len, lv_ln.
          lv_len = strlen( lw_split-string ).
          lv_ln = lv_len - 2.
          lv_char_31 = lw_split-string+2(lv_ln).
          CONDENSE lv_char_31.
          lv_char_dec = lv_char_31(2).
          lv_ln_31 = lv_ln - 2.
          lv_char1 = lv_char_31+2(lv_ln_31).
          SHIFT lv_char1 LEFT DELETING LEADING lc_zero.
          SHIFT lv_char_dec LEFT DELETING LEADING lc_zero.
          CONDENSE: lv_char1, lv_char_dec.
          CLEAR: lv_len, lv_ln.
          lv_ln = lv_char_dec.
          lv_len = strlen( lv_char1 ).
          lv_len = lv_len - lv_ln.
          lv_dec1 = lv_char1(lv_len).
          lv_dec2 = lv_char1+lv_len(lv_ln).
          CONDENSE: lv_dec1, lv_dec2.
          CONCATENATE lv_dec1 lv_dec2 INTO lv_char SEPARATED BY '.'.
          CONDENSE lv_char.
          lv_qty1 = x_label_content-zzquantity = lv_char.
        ENDIF.
        IF lw_split-string(2) EQ '90'.
          CLEAR: lv_len, lv_ln.
          lv_len = strlen( lw_split-string ).
          lv_ln = lv_len - 2.
          lv_char = lw_split-string+2(lv_ln).
          CONDENSE lv_char.
          gv_tophu = lv_char.
        ENDIF.
        IF lw_split-string(2) EQ '92'.
          CLEAR: lv_len, lv_ln.
          lv_len = strlen( lw_split-string ).
          lv_ln = lv_len - 2.
          lv_char = lw_split-string+2(lv_ln).
          CONDENSE lv_char.
          gv_bothu = lv_char.
        ENDIF.
        IF lw_split-string(3) EQ '240'.
          CLEAR: lv_len, lv_ln.
          lv_len = strlen( lw_split-string ).
          lv_ln = lv_len - 3.
          lv_char = lw_split-string+3(lv_ln).
          CONDENSE lv_char.
          x_label_content-zzhu_exid = gv_palhu = lv_char.
        ENDIF.
      ENDLOOP.

      IF x_label_content-zzorigin_batch IS INITIAL
        OR x_label_content-zzmatnr IS INITIAL
        OR x_label_content-zzquantity IS INITIAL
        OR gv_tophu IS INITIAL
        OR gv_bothu IS INITIAL
        OR x_label_content-zzhu_exid IS INITIAL.

        MESSAGE e121 RAISING illegal_bar_code.
      ELSE.

        lw_hu-typ = lc_p.
        lw_hu-hu = gv_palhu.
        lw_hu-batch = x_label_content-zzorigin_batch.
        APPEND lw_hu TO lt_hu[].
        IF gv_tophu IS NOT INITIAL AND gv_bothu IS NOT INITIAL.
          IF gv_tophu(1) CA sy-abcde AND gv_bothu(1) CA sy-abcde.
            lv_len = strlen( gv_tophu ).
            lv_ln = lv_len - 1.
            lv_i1 = gv_tophu+1(lv_ln).
            CLEAR: lv_len, lv_ln.
            lv_len = strlen( gv_bothu ).
            lv_ln = lv_len - 1.
            lv_i2 = gv_bothu+1(lv_ln).
            CONDENSE: lv_i1, lv_i2.
            SHIFT lv_i1 LEFT DELETING LEADING lc_zero.
            SHIFT lv_i2 LEFT DELETING LEADING lc_zero.
            CONDENSE: lv_i1, lv_i2.
            lv_c1 = gv_tophu(1).
            CONDENSE lv_c1.
            DATA(lv_c) = lv_i2 - lv_i1 + 1.
            DO lv_c TIMES.
              CLEAR: lw_hu, gv_tophu, lv_index.
              lv_index = sy-index.
              IF lv_index > 1.
                lv_i1 = lv_i1 + 1.
                CONDENSE lv_i1.
                IF strlen( lv_i1 ) EQ 1.
                  CONCATENATE lv_c1 lc_zero lc_zero lv_i1 INTO gv_tophu.
                ELSEIF strlen( lv_i1 ) EQ 2.
                  CONCATENATE lv_c1 lc_zero lv_i1 INTO gv_tophu.
                ELSEIF strlen( lv_i1 ) > 2.
                  CONCATENATE lv_c1 lv_i1 INTO gv_tophu.
                ENDIF.
              ELSE.
                IF strlen( lv_i1 ) EQ 1.
                  CONCATENATE lv_c1 lc_zero lc_zero lv_i1 INTO gv_tophu.
                ELSEIF strlen( lv_i1 ) EQ 2.
                  CONCATENATE lv_c1 lc_zero lv_i1 INTO gv_tophu.
                ELSEIF strlen( lv_i1 ) > 2.
                  CONCATENATE lv_c1 lv_i1 INTO gv_tophu.
                ENDIF.
              ENDIF.
              lw_hu-typ = lc_c.
              CONCATENATE x_label_content-zzorigin_batch gv_tophu INTO lw_hu-hu.
              APPEND lw_hu TO lt_hu[].
            ENDDO.
            CLEAR: lv_c.

          ELSE.
            lv_c = gv_bothu - gv_tophu + 1.
            lv_len = strlen( gv_tophu ).
            DO lv_c TIMES.
              CLEAR: lw_hu, lv_index.
              lv_index = sy-index.
              IF lv_index > 1.
                gv_tophu = gv_tophu + 1.
                CONDENSE gv_tophu.
              ENDIF.
              lv_ln = strlen( gv_tophu ).
              lv_diff = lv_len - lv_ln.
              lw_hu-typ = lc_c.
              IF lv_len EQ lv_ln.
                CONCATENATE x_label_content-zzorigin_batch gv_tophu INTO lw_hu-hu.
              ELSEIF lv_len > lv_ln.
                DO lv_diff TIMES.
                  CONCATENATE lc_zero lv_hu INTO lv_hu.
                ENDDO.
                CONDENSE lv_hu.
                IF lv_ln = 1.
                  CONCATENATE x_label_content-zzorigin_batch lc_zero
                                                             lc_zero
                                                             lc_zero gv_tophu INTO lw_hu-hu.
                ELSEIF lv_ln = 2.
                  CONCATENATE x_label_content-zzorigin_batch lc_zero
                                                             lc_zero gv_tophu INTO lw_hu-hu.
                ELSEIF lv_ln = 3.
                  CONCATENATE x_label_content-zzorigin_batch lc_zero gv_tophu INTO lw_hu-hu.
                ENDIF.
              ENDIF.
              APPEND lw_hu TO lt_hu[].
            ENDDO.
          ENDIF.


          IF lt_hu[] IS NOT INITIAL.
            DESCRIBE TABLE lt_hu[] LINES lv_lines.
            IF lv_lines > 2.
              lv_mod = lv_qty1 MOD ( lv_lines - 1 ).
              lv_qty = lv_qty1 / ( lv_lines - 1 ).
              LOOP AT lt_hu ASSIGNING FIELD-SYMBOL(<ls_hu>) WHERE typ = lc_c.
                lv_count = lv_count + 1.
                IF lv_mod EQ lc_zero.
                  <ls_hu>-qty = lv_qty.
                  CONDENSE <ls_hu>-qty.
                ELSE.
                  IF lv_count = ( lv_lines - 1 ).
                    lv_qty2 = lv_qty1 - ( lv_qty * ( lv_lines - 2 ) ).
                    <ls_hu>-qty = lv_qty2.
                  ELSE.
                    <ls_hu>-qty = lv_qty.
                  ENDIF.
                  CONDENSE <ls_hu>-qty.
                ENDIF.
              ENDLOOP.
            ELSE.
              LOOP AT lt_hu ASSIGNING <ls_hu> WHERE typ = lc_c.
                <ls_hu>-qty = lv_qty1.
                CONDENSE <ls_hu>-qty.
              ENDLOOP.
            ENDIF.
          ENDIF.

        ENDIF.

      ENDIF.

    ELSE.
      type = lc_c.
      LOOP AT lt_split INTO lw_split.
        CLEAR: lv_char.
        IF lw_split-string(5) EQ ']C110'.
          CLEAR: lv_len, lv_ln.
          lv_len = strlen( lw_split-string ).
          lv_ln = lv_len - 5.
          lv_char = lw_split-string+5(lv_ln).
          CONDENSE lv_char.
          lw_hu-batch = x_label_content-zzorigin_batch = lv_char.
        ENDIF.
        IF lw_split-string(3) EQ '241'.
          CLEAR: lv_len, lv_ln.
          lv_len = strlen( lw_split-string ).
          lv_ln = lv_len - 3.
          lv_char = lw_split-string+3(lv_ln).
          CONDENSE lv_char.
          x_label_content-zzmatnr = lv_char.
        ENDIF.
        IF lw_split-string(2) EQ '30'.
          CLEAR: lv_len, lv_ln.
          lv_len = strlen( lw_split-string ).
          lv_ln = lv_len - 2.
          lv_char = lw_split-string+2(lv_ln).
          CONDENSE lv_char.
          lv_qty2 =  x_label_content-zzquantity = lv_char.
          lw_hu-qty = lv_qty2.
          CONDENSE lw_hu-qty.
        ENDIF.
        IF lw_split-string(2) EQ '31'.
          CLEAR: lv_len, lv_ln.
          lv_len = strlen( lw_split-string ).
          lv_ln = lv_len - 2.
          lv_char_31 = lw_split-string+2(lv_ln).
          CONDENSE lv_char_31.
          lv_char_dec = lv_char_31(2).
          lv_ln_31 = lv_ln - 2.
          lv_char1 = lv_char_31+2(lv_ln_31).
          SHIFT lv_char1 LEFT DELETING LEADING lc_zero.
          SHIFT lv_char_dec LEFT DELETING LEADING lc_zero.
          CONDENSE: lv_char1, lv_char_dec.
          CLEAR: lv_len, lv_ln.
          lv_ln = lv_char_dec.
          lv_len = strlen( lv_char1 ).
          lv_len = lv_len - lv_ln.
          lv_dec1 = lv_char1(lv_len).
          lv_dec2 = lv_char1+lv_len(lv_ln).
          CONDENSE: lv_dec1, lv_dec2.
          CONCATENATE lv_dec1 lv_dec2 INTO lv_char SEPARATED BY '.'.
          CONDENSE lv_char.
          lv_qty2 = x_label_content-zzquantity = lv_char.
          lw_hu-qty = lv_qty2.
          CONDENSE lw_hu-qty.
        ENDIF.
        IF lw_split-string(3) EQ '240'.
          CLEAR: lv_len, lv_ln.
          lv_len = strlen( lw_split-string ).
          lv_ln = lv_len - 3.
          lv_char = lw_split-string+3(lv_ln).
          CONDENSE lv_char.
          lw_hu-hu = x_label_content-zzhu_exid = lv_char.
        ENDIF.
      ENDLOOP.
      IF lv_barcode CS ':92'.
        CLEAR: x_label_content.
      ENDIF.
      IF x_label_content-zzorigin_batch IS INITIAL
        OR x_label_content-zzmatnr IS INITIAL
        OR x_label_content-zzquantity IS INITIAL
        OR x_label_content-zzhu_exid IS INITIAL.

        MESSAGE e121 RAISING illegal_bar_code.
      ELSE.
        lw_hu-typ = lc_l.
        APPEND lw_hu TO lt_hu[].
      ENDIF.
    ENDIF.

    IF x_label_content IS INITIAL.
      MESSAGE e121 RAISING illegal_bar_code.
    ELSE.
      it_hu[] = lt_hu[].
      o_label_content = x_label_content.
    ENDIF.
  ENDMETHOD.


  METHOD read_vendor_label.
    TYPES: BEGIN OF ty_split,
             string TYPE char40,
           END OF ty_split,
           BEGIN OF ty_werks1,
             sign   TYPE bapisign,
             option TYPE bapioption,
             low    TYPE werks_d,
             high   TYPE werks_d,
           END OF ty_werks1,
           BEGIN OF ty_werks,
             werks TYPE werks_d,
           END OF ty_werks.
    DATA: lv_barcode     TYPE string,
          lv_hubar       TYPE string,
          lv_hustr       TYPE string,
          lv_tabix       TYPE i,
          lv_vendor      TYPE flag,
          lv_active      TYPE flag,
          lv_len         TYPE i,
          lv_ln          TYPE i,
          lv_exidv       TYPE exidv,
          lw_split       TYPE ty_split,
          lt_werks       TYPE TABLE OF ty_werks,
          lt_plant       TYPE TABLE OF ty_werks,
          lt_werks_range TYPE RANGE OF werks_d,
          lt_split       TYPE TABLE OF ty_split.
    DATA: lr_werks_range TYPE ty_werks1.
    CONSTANTS: lc_lookup_name1 TYPE zlookup_name VALUE 'ZV_PLANT'.
    lv_vendor = abap_false.
    valid_barcode = abap_false.
    lv_barcode = iv_barcode.

    GET PARAMETER ID 'ZGELATIN' FIELD lv_active.

    IF lv_active EQ abap_true. " zvv_param for plants comparison with WRK paratmeter from SU3
      SPLIT lv_barcode AT ':' INTO TABLE lt_split[].
      LOOP AT lt_split INTO lw_split.
        lv_tabix = sy-tabix.
        CASE lv_tabix.
          WHEN 1.
            IF lw_split-string(5) EQ ']C110'.
              lv_vendor = abap_true.
            ELSE.
              lv_vendor = abap_false.
              EXIT.
            ENDIF.
          WHEN 2.
            IF lw_split-string(3) EQ '241'.
              lv_vendor = abap_true.
            ELSE.
              lv_vendor = abap_false.
              EXIT.
            ENDIF.
          WHEN 3.
            IF lw_split-string(2) EQ '30'.
              lv_vendor = abap_true.
            ELSEIF lw_split-string(2) EQ '31'.
              lv_vendor = abap_true.
            ELSE.
              lv_vendor = abap_false.
              EXIT.
            ENDIF.
          WHEN 4.
            IF lw_split-string(2) EQ '90'.
              lv_vendor = abap_true.
            ELSE.
              lv_vendor = abap_false.
              EXIT.
            ENDIF.
          WHEN 5.
            IF lw_split-string(2) EQ '92'.
              lv_vendor = abap_true.
            ELSEIF lw_split-string(3) EQ '240'.
              lv_vendor = abap_true.
              lv_hustr = lw_split-string.
              CONDENSE lv_hustr.
              CLEAR: lv_len, lv_ln.
              lv_len = strlen( lw_split-string ).
              lv_ln = lv_len - 3.
              lv_exidv = lw_split-string+3(lv_ln).
              CONDENSE lv_exidv.
            ELSE.
              lv_vendor = abap_false.
              EXIT.
            ENDIF.
          WHEN 6.
            IF lw_split-string(3) EQ '240'.
              lv_vendor = abap_true.
              lv_hustr = lw_split-string.
              CONDENSE lv_hustr.
              CLEAR: lv_len, lv_ln.
              lv_len = strlen( lw_split-string ).
              lv_ln = lv_len - 3.
              lv_exidv = lw_split-string+3(lv_ln).
              CONDENSE lv_exidv.
            ELSE.
              lv_vendor = abap_false.
              EXIT.
            ENDIF.
        ENDCASE.
      ENDLOOP.

      IF lv_vendor EQ abap_true.
        CONCATENATE ']C1' lv_hustr INTO lv_hubar.
        lv_hubar = lv_hubar.
        CONDENSE lv_hubar.
        hu_barcode = lv_hubar.
        valid_barcode = abap_true.
      ENDIF.
      IF lv_vendor EQ abap_false.
        hu_barcode = lv_barcode.
      ENDIF.

      IF lv_exidv IS NOT INITIAL.
        SELECT SINGLE venum,
                      exidv
               INTO @DATA(lw_venum) FROM vekp
               WHERE exidv = @lv_exidv.
        IF sy-subrc EQ 0.
          hu_exists = 'Y'.
        ELSE.
          hu_exists = 'N'.
        ENDIF.
      ENDIF.
    ENDIF.

    IF hu_barcode IS INITIAL.   "if not converted send back the input barcode string
      hu_barcode = lv_barcode.
    ENDIF.
  ENDMETHOD.


  METHOD set_user_profile.
    DATA: ls_profile_line TYPE ztits_uprofile,
          lv_dummy        TYPE string.

    rv_result = abap_false.

    ls_profile_line-bname = sy-uname.

    IF is_user_profile-zzwerks IS NOT INITIAL.

      ls_profile_line-werks = is_user_profile-zzwerks.
      CLEAR ls_profile_line-lgnum.

    ELSEIF is_user_profile-zzlgnum IS NOT INITIAL.


      ls_profile_line-lgnum = is_user_profile-zzlgnum.
      CLEAR ls_profile_line-werks.

    ELSE.
* *Plant or Warehouse# could not be blank neither!
      MESSAGE e024 INTO lv_dummy.

      rv_result = abap_true.

      RETURN.

    ENDIF.

* Update DB
    MODIFY ztits_uprofile FROM ls_profile_line.

    CALL FUNCTION 'ZITS_SET_USER_PROFILE_BUFFER'
      EXPORTING
        is_user_profile = is_user_profile.
  ENDMETHOD.


METHOD SN_READ.
************************************************************************
************************************************************************
* Program ID:                        SN_READ
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
  DATA: lv_sernr TYPE gernr,
        lv_dummy TYPE string.

  CLEAR: es_equi,es_eqbs.

  lv_sernr = iv_serial_number.

  CALL FUNCTION 'CONVERSION_EXIT_GERNR_INPUT'
    EXPORTING
      input  = lv_sernr
    IMPORTING
      output = lv_sernr.

* Get the material of serial#
  SELECT * INTO es_equi FROM equi UP TO 1 ROWS WHERE sernr = lv_sernr.
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE e801(is) WITH lv_sernr INTO lv_dummy.
    RETURN.
  ENDIF.

  CALL FUNCTION 'SERIALNUMBER_READ'
    EXPORTING
      i_lock               = abap_true
      sernr                = lv_sernr
      matnr                = es_equi-matnr
    IMPORTING
      equi                 = es_equi
      eqbs                 = es_eqbs
    EXCEPTIONS
      equi_not_found       = 1
      authority_is_missing = 2
      err_handle           = 3
      lock_failure         = 4
      OTHERS               = 5.
  IF sy-subrc <> 0.
    MESSAGE ID   sy-msgid
          TYPE   sy-msgty
          NUMBER sy-msgno
          INTO   lv_dummy
          WITH   sy-msgv1
                 sy-msgv2
                 sy-msgv3
                 sy-msgv4.
    RETURN.
  ENDIF.

ENDMETHOD.


METHOD su_content_read.
************************************************************************
************************************************************************
* Program ID:                        SU_CONTENT_READ
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
  DATA: lv_su_number  TYPE lenum,
        ls_su_header  TYPE lein,
        lv_dummy      TYPE string,
        lv_lgnum      TYPE lgnum,
        ls_hu_content TYPE zshu_content.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = iv_su_id
    IMPORTING
      output = lv_su_number.

  SELECT SINGLE * INTO ls_su_header FROM lein WHERE lenum = lv_su_number.
  IF sy-subrc NE 0.
*Storage unit does not exist (check your entry)
    MESSAGE e201(l1) INTO lv_dummy.
    RETURN.
  ENDIF.

  IF iv_lgnum IS NOT INITIAL.
    IF iv_lgnum NE ls_su_header-lgnum.
* Storge unit is not assigned to warehouse number (check your entry)
      MESSAGE e200(l1) INTO lv_dummy.
      RETURN.
    ENDIF.
  ENDIF.

  rs_su_data-su_header  = ls_su_header.

  SELECT * FROM lqua
    INTO TABLE rs_su_data-su_item
    WHERE lenum = lv_su_number
      AND lgnum = ls_su_header-lgnum.

* Check the logon location is whether match with the scanned object
*------------------------------------------------------------------------------------------
*  IF zcl_its_utility=>is_location_match( is_su_data  = rs_su_data ) = abap_false.
*
*    CLEAR rs_su_data.
*    RETURN.
*
*  ENDIF.

ENDMETHOD.


  method TO_CONFIRM.

     DATA: lit_conf TYPE STANDARD TABLE OF ltap_conf,
        lv_dummy TYPE bapi_msg,
        lv_tanum TYPE tanum.

  FIELD-SYMBOLS: <ls_conf> TYPE ltap_conf,
                 <ls_item> TYPE zsits_to_conf_item.


  LOOP AT is_to_conf-to_conf_item ASSIGNING <ls_item>.

    APPEND INITIAL LINE TO lit_conf ASSIGNING <ls_conf>.

    MOVE-CORRESPONDING <ls_item> TO <ls_conf>.

  ENDLOOP.

* Confirm transfer order item
  CALL FUNCTION 'L_TO_CONFIRM'
    EXPORTING
      i_lgnum                        = is_to_conf-lgnum
      i_tanum                        = is_to_conf-tanum
      i_squit                        = is_to_conf-squit
      i_commit_work                  = 'X'
    TABLES
      t_ltap_conf                    = lit_conf
    EXCEPTIONS
      to_confirmed                   = 1
      to_doesnt_exist                = 2
      item_confirmed                 = 3
      item_subsystem                 = 4
      item_doesnt_exist              = 5
      item_without_zero_stock_check  = 6
      item_with_zero_stock_check     = 7
      one_item_with_zero_stock_check = 8
      item_su_bulk_storage           = 9
      item_no_su_bulk_storage        = 10
      one_item_su_bulk_storage       = 11
      foreign_lock                   = 12
      squit_or_quantities            = 13
      vquit_or_quantities            = 14
      bquit_or_quantities            = 15
      quantity_wrong                 = 16
      double_lines                   = 17
      kzdif_wrong                    = 18
      no_difference                  = 19
      no_negative_quantities         = 20
      wrong_zero_stock_check         = 21
      su_not_found                   = 22
      no_stock_on_su                 = 23
      su_wrong                       = 24
      too_many_su                    = 25
      nothing_to_do                  = 26
      no_unit_of_measure             = 27
      xfeld_wrong                    = 28
      update_without_commit          = 29
      no_authority                   = 30
      lqnum_missing                  = 31
      charg_missing                  = 32
      no_sobkz                       = 33
      no_charg                       = 34
      nlpla_wrong                    = 35
      two_step_confirmation_required = 36
      two_step_conf_not_allowed      = 37
      pick_confirmation_missing      = 38
      quknz_wrong                    = 39
      hu_data_wrong                  = 40
      no_hu_data_required            = 41
      hu_data_missing                = 42
      hu_not_found                   = 43
      picking_of_hu_not_possible     = 44
      not_enough_stock_in_hu         = 45
      serial_number_data_wrong       = 46
      serial_numbers_not_required    = 47
      no_differences_allowed         = 48
      serial_number_not_available    = 49
      serial_number_data_missing     = 50
      to_item_split_not_allowed      = 51
      input_wrong                    = 52
      OTHERS                         = 53.

  IF sy-subrc <> 0.

    MESSAGE ID        sy-msgid
            TYPE      sy-msgty
            NUMBER    sy-msgno
            INTO      lv_dummy
            WITH      sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

  ELSE.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = is_to_conf-tanum
      IMPORTING
        output = lv_tanum.

    MESSAGE s218 WITH lv_tanum INTO lv_dummy.

    IF iv_confirm_option = abap_true.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
    ENDIF.

    rv_result = abap_true.

  ENDIF.


  endmethod.


METHOD to_read.

  DATA: lv_dummy      TYPE                   bapi_msg,
        lwa_to_header TYPE                   ltak,
        lit_to_header TYPE STANDARD TABLE OF ltak,
        lit_to_ltap   TYPE STANDARD TABLE OF ltap,
        lit_to_item   TYPE STANDARD TABLE OF zsits_to_item.

  FIELD-SYMBOLS: <ls_to_ltap> TYPE ltap,
                 <ls_to_item> TYPE zsits_to_item,
                 <ls_to_ltak> TYPE ltak.

  lwa_to_header-lgnum          = is_to_key-lgnum.
  lwa_to_header-tanum          = is_to_key-tanum.
  APPEND lwa_to_header TO lit_to_header.

  CALL FUNCTION 'LOCK_TO'
    EXPORTING
      i_lgnum            = is_to_key-lgnum
    TABLES
      t_to_items         = lit_to_ltap
      t_to_header        = lit_to_header
    EXCEPTIONS
      wrong_whs_id       = 1
      no_authority       = 2
      to_doesnt_exist    = 3
      to_is_locked       = 4
      internal_error     = 5
      tr_is_locked       = 6
      psch_is_locked     = 7
      dlvr_is_locked     = 8
      to_conf            = 9
      no_ship_doc        = 10
      material_error     = 11
      rsrv_lock          = 12
      wrong_mvtyp        = 13
      to_problem         = 14
      empty_header_table = 15
      OTHERS             = 16.
  IF sy-subrc <> 0.

    MESSAGE ID        sy-msgid
            TYPE      sy-msgty
            NUMBER    sy-msgno
            INTO      lv_dummy
            WITH      sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ELSE.
*Retrieving TO Header Info
    READ TABLE lit_to_header ASSIGNING <ls_to_ltak> INDEX 1.
    IF sy-subrc <> 0.
      MESSAGE e125(zits) INTO lv_dummy.
      RETURN.
    ENDIF.
    MOVE-CORRESPONDING <ls_to_ltak> TO rs_to_data.

*Retrieving TO Line Item Info
    LOOP AT lit_to_ltap ASSIGNING <ls_to_ltap>.

      ev_storage_type = <ls_to_ltap>-nltyp.

      APPEND INITIAL LINE TO rs_to_data-to_item ASSIGNING <ls_to_item>.

      MOVE-CORRESPONDING <ls_to_ltap> TO <ls_to_item>.

    ENDLOOP.
  ENDIF.

ENDMETHOD.


  method TRAN_CHECK.
************************************************************************
************************************************************************
* Program ID:                        TRAN_CHECK
* Created By:                        Kripa S Patil
* Creation Date:                     08.JAN.2019
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
* 08.JAN.19   KPATIL1        1           D10K9A37KD  /  Initial version
*&---------------------------------------------------------------------*
DATA: lv_dummy        TYPE bapi_msg,
        ls_tstc         TYPE tstc,
        ls_scan_code    TYPE ztits_scan_code,
        ls_scan_plant   TYPE ztits_scan_plt,
        ls_scan_wareh   TYPE ztits_scan_wareh,
        lv_tzone        TYPE tznzone,
        ls_user_profile TYPE zsits_user_profile.


  rv_result = abap_false.

* Check the existence of tcode
  SELECT SINGLE * INTO ls_tstc FROM tstc WHERE tcode   = iv_scan_code.
  IF sy-subrc NE 0.
* Transaction does not exit
    MESSAGE e343(s#) WITH iv_scan_code INTO lv_dummy.
    RETURN.
  ENDIF.

* Check the tcode whether scanning transaction
  SELECT SINGLE * INTO ls_scan_code FROM ztits_scan_code WHERE tcode = iv_scan_code.
  IF sy-subrc NE 0.
* Transaction & is not a scanning program
    MESSAGE e001 WITH iv_scan_code INTO lv_dummy.
    RETURN.
  ENDIF.

  IF ls_scan_code-zzblock = abap_true.
* Transaction & is blocked for using
    MESSAGE e002 WITH iv_scan_code INTO lv_dummy.
    RETURN.
  ENDIF.

  ls_user_profile = get_user_profile( ).

  IF ls_scan_code-zzscan_area = gc_tran_area_im AND  ls_user_profile-zzwerks IS INITIAL.
* Transaction & is for inventory operation, your login not match
    MESSAGE e003 WITH iv_scan_code INTO lv_dummy.
    RETURN.
  ELSEIF ls_scan_code-zzscan_area = gc_tran_area_wm AND  ls_user_profile-zzlgnum IS INITIAL.
* Transaction & is for warehouse operation, your login not match
    MESSAGE e004 WITH iv_scan_code INTO lv_dummy.
    RETURN.
  ENDIF.

  IF ls_scan_code-zzscan_area = gc_tran_area_im .    " IM
    SELECT SINGLE * INTO ls_scan_plant FROM ztits_scan_plt WHERE tcode = iv_scan_code
                                                              AND werks = ls_user_profile-zzwerks.
    IF sy-subrc NE 0.
* Login plant &1 is not workable for transaction &1
      MESSAGE e005 WITH ls_user_profile-zzwerks iv_scan_code INTO lv_dummy.
      RETURN.
    ENDIF.
  ENDIF.

  IF ls_scan_code-zzscan_area = gc_tran_area_wm .    " WM
    SELECT SINGLE * INTO ls_scan_wareh FROM ztits_scan_wareh WHERE tcode = iv_scan_code
                                                               AND lgnum = ls_user_profile-zzlgnum.
    IF sy-subrc NE 0.
* Login warehouse &1 is not workable for transaction &1
      MESSAGE e135 WITH ls_user_profile-zzlgnum iv_scan_code INTO lv_dummy.
      RETURN.
    ENDIF.
  ENDIF.

*--Added by Johnny Sun. For transaction ZITSEWMBTB & ZITSEWMSUBTB, we allow log on for both plant and warehouse.
*--If the user logged on using plant, then we check validity of plant.
*--If the user logged on using warehouse, then we check validity of the warehouse.

  IF ls_scan_code-zzscan_area = gc_tran_area_na .    " NA

    IF ls_user_profile-zzlgnum IS NOT INITIAL. "
      SELECT SINGLE * INTO ls_scan_wareh FROM ztits_scan_wareh WHERE tcode = iv_scan_code
                                                                 AND lgnum = ls_user_profile-zzlgnum.
      IF sy-subrc NE 0.
* Login warehouse &1 is not workable for transaction &1
        MESSAGE e135 WITH ls_user_profile-zzlgnum iv_scan_code INTO lv_dummy.
        RETURN.
      ENDIF.
    ELSEIF ls_user_profile-zzwerks IS NOT INITIAL.
      SELECT SINGLE * INTO ls_scan_plant FROM ztits_scan_plt WHERE tcode = iv_scan_code
                                                                AND werks = ls_user_profile-zzwerks.
      IF sy-subrc NE 0.
* Login plant &1 is not workable for transaction &1
        MESSAGE e005 WITH ls_user_profile-zzwerks iv_scan_code INTO lv_dummy.
        RETURN.
      ENDIF.
    ENDIF.

  ENDIF.

* authorization check
  CALL FUNCTION 'AUTH_CHECK_TCODE'
    EXPORTING
      tcode                          = iv_scan_code
    EXCEPTIONS
      parameter_error                = 1
      transaction_not_found          = 2
      transaction_locked             = 3
      transaction_is_menu            = 4
      menu_via_parameter_transaction = 5
      not_authorized                 = 6
      OTHERS                         = 7.

  IF sy-subrc NE 0.
* You are not authorized to use this transaction
    MESSAGE s172(00) WITH iv_scan_code INTO lv_dummy.
    RETURN.
  ENDIF.

* Start of change by Pete @ May 7th 2015

  SELECT SINGLE tzone INTO lv_tzone FROM usr02 WHERE bname = sy-uname.

  IF lv_tzone IS INITIAL.
* Personal timezone is not maintained.
    MESSAGE s450 INTO lv_dummy.
    RETURN.
  ENDIF.

* End   of change by Pete @ May 7th 2015

  rv_result = abap_true.
  endmethod.


  METHOD wm_inv_doc_exist.
    DATA: lv_dummy      TYPE bapi_msg,
          lit_link      TYPE STANDARD TABLE OF link,
          lwa_link      TYPE link,
          lv_su_m_bool  TYPE bool,
          lo_auth_check TYPE REF TO zcl_auth_check,
          ls_return     TYPE bapiret2.

    SELECT lgtyp AS lgtyp   "storage type
           istat AS istat   "inv status
           ivakt AS ivakt   "inv active
      FROM link
      INTO CORRESPONDING FIELDS OF TABLE lit_link
           WHERE lgnum = is_key-zzlgnum
             AND ivnum = is_key-zzwminvdoc.

    IF sy-subrc NE 0.
*-----&1 is not a valid inventory document number!
      MESSAGE e095(zits) WITH is_key-zzwminvdoc INTO lv_dummy.
      ev_error_bool = abap_true.
    ELSE.
*     Check authorization
      CREATE OBJECT lo_auth_check.
      ls_return = lo_auth_check->auth_check_lgnum( iv_lgnum = is_key-zzlgnum ).
      IF ls_return IS NOT INITIAL.
        MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number
        WITH ls_return-message_v1 INTO lv_dummy.
        ev_error_bool = abap_true.
      ENDIF.

      IF  ls_return IS INITIAL .
        READ TABLE lit_link INTO lwa_link INDEX 1.
        CASE lwa_link-ivakt.
          WHEN space.
            IF lwa_link-istat = 'L'.
              " Phys Inv Doc &1 has already cleared.
              MESSAGE e096(zits) WITH is_key-zzwminvdoc INTO lv_dummy.
              ev_error_bool = abap_true.
            ELSE.
              " Phys Inv Doc &1 is not active!
              MESSAGE e098(zits) WITH is_key-zzwminvdoc INTO lv_dummy.
              ev_error_bool = abap_true.
            ENDIF.

          WHEN OTHERS. "active phys inv
            IF lwa_link-istat = 'L'. "cleared
              MESSAGE e096(zits) WITH is_key-zzwminvdoc INTO lv_dummy.
              ev_error_bool = abap_true.
            ELSEIF lwa_link-istat = 'S'. "cancelled
              MESSAGE e097(zits) WITH is_key-zzwminvdoc INTO lv_dummy.
              ev_error_bool = abap_true.
            ELSEIF lwa_link-istat = 'Z'. "counted
              MESSAGE e111(zits) WITH is_key-zzwminvdoc INTO lv_dummy.
              ev_error_bool = abap_true.
            ELSE.
              ev_error_bool = abap_false.
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDIF.

    IF ev_error_bool NE abap_true.
      SELECT SINGLE prlet
        FROM t331
        INTO lv_su_m_bool
        WHERE lgnum = is_key-zzlgnum
          AND lgtyp = lwa_link-lgtyp.

      CASE lv_su_m_bool.
        WHEN abap_true.
          ev_su_managed = abap_true.
      ENDCASE.

      ev_storage_type = lwa_link-lgtyp.
* BE CAREFUL TO REMOVE BELOW LOCK FUNCTION-CALL !!!!!!!!!
*    Base on current design of E0145, there will be big change to allow
* multiple scanners  count the same WM PI document at the same time.
*   Lock the inventory document
      CALL FUNCTION 'ENQUEUE_ELLINKE'
        EXPORTING
          mode_link      = 'E'
          mandt          = sy-mandt
          lgnum          = is_key-zzlgnum
          ivnum          = is_key-zzwminvdoc
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
      IF sy-subrc NE 0.
        MESSAGE ID     sy-msgid
                TYPE   sy-msgty
                NUMBER sy-msgno
                WITH   sy-msgv1 sy-msgv2 sy-msgv4 sy-msgv4
                INTO   lv_dummy.

        ev_error_bool = abap_true.
      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
