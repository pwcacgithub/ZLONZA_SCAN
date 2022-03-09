*&---------------------------------------------------------------------*
*&  Include           MZITSEHUMOVE_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FRM_GET_USER_PROFILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_get_user_profile .

  IF x_profile IS INITIAL.
    CALL METHOD zcl_its_utility=>get_user_profile
      RECEIVING
        rs_user_profile = x_profile.
  ENDIF.

ENDFORM.                    " FRM_GET_USER_PROFILE

*&---------------------------------------------------------------------*
*&      Form  FRM_INITIAL_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_initial_log .

  IF o_log IS INITIAL.
    CREATE OBJECT o_log
      EXPORTING
        iv_scan_code = sy-tcode.
  ENDIF.

ENDFORM.                    " FRM_INITIAL_LOG

*&---------------------------------------------------------------------*
*&      Form  FRM_ADD_MESSAGE
*&---------------------------------------------------------------------*
*       Add message and display log
*----------------------------------------------------------------------*
FORM frm_add_message  USING    uv_objid   TYPE zzscan_objid
                               uv_content TYPE any
                               uv_err_fg  TYPE boolean.

  CALL METHOD o_log->log_message_add
    EXPORTING
      iv_object_id    = uv_objid
      iv_content      = uv_content
      iv_with_message = uv_err_fg.

  IF uv_err_fg = abap_true.
    CALL METHOD zcl_its_utility=>message_display( ).
  ENDIF.

ENDFORM.                    " FRM_ADD_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  FRM_NEW_TRAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_new_tran .

  CALL METHOD zcl_its_utility=>leave_2_new_trans( CHANGING co_log = o_log ).

ENDFORM.                    " FRM_NEW_TRAN

*&---------------------------------------------------------------------*
*&      Form  FRM_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_user_command .

  DATA: lv_code TYPE sy-ucomm.

  lv_code = ok_code.
  CLEAR ok_code.

  CASE lv_code.
    WHEN  'P-' .
*      PERFORM table_scroll USING lv_code.
      PERFORM previous1.
    WHEN  'P+'.
      PERFORM next.
    WHEN zcl_its_utility=>gc_okcode_save.
      " HU movement
      PERFORM frm_hu_movement.

* Display success message on current screen
      IF v_err_fg EQ abap_false.
        IF v_hu_counter = 1.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = x_label_content-zzhu_exid
            IMPORTING
              output = x_label_content-zzhu_exid.
          MESSAGE s039 WITH x_label_content-zzhu_exid INTO zsits_scan_dynp-zzsuccess_msg.
        ELSEIF v_hu_counter GT 1.
          MESSAGE s050 WITH v_hu_counter INTO zsits_scan_dynp-zzsuccess_msg.
        ENDIF.
        CLEAR : zsits_scan_humove ,
                wa_su, gv_cart1, gv_cart2, gv_cart3, gv_cart4, gv_cart5,
                it_su.
        REFRESH it_su.
      ELSE.
* Update log and display error message on next screen if error occurs
        PERFORM frm_add_message USING zcl_its_utility=>gc_objid_label
                                      zsits_scan_dynp-zzbarcode
                                      v_err_fg.
        CLEAR : zsits_scan_humove ,
                wa_su, gv_cart1, gv_cart2, gv_cart3, gv_cart4, gv_cart5,
                it_su.
        REFRESH it_su.
      ENDIF.
    WHEN 'CLR'.
      CLEAR zsits_scan_humove.
  ENDCASE.

ENDFORM.                    " FRM_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  FRM_CHECK_LGORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_check_lgort.

  DATA: lv_lgort      TYPE t001l-lgort,
        ls_param      TYPE zvv_param,
        lv_xhupf      TYPE t001l-xhupf,
        lv_sloc_check TYPE char1.

  IF zsits_scan_humove-zzlgort IS INITIAL.
    IF sy-ucomm = 'SAVE'.
      v_err_fg = abap_true.
    ENDIF.
  ELSE.
    IF x_profile-zzwerks IS NOT INITIAL.
      SELECT SINGLE lgort xhupf INTO ( lv_lgort, lv_xhupf ) FROM t001l
        WHERE werks = x_profile-zzwerks
          AND lgort = zsits_scan_humove-zzlgort.
      IF sy-subrc NE 0.
        v_err_fg = abap_true.
      ENDIF.
    ELSEIF x_profile-zzlgnum IS NOT INITIAL.
      SELECT SINGLE lgort INTO lv_lgort FROM t320           "#EC WARNOK
        WHERE lgort = zsits_scan_humove-zzlgort
          AND lgnum = x_profile-zzlgnum.
    ENDIF.

  ENDIF.

** check if Sloc if HU managed or not
  CLEAR lv_sloc_check.
  IF v_err_fg NE abap_true AND zsits_scan_humove-zzlgort IS NOT INITIAL.
    SELECT  SINGLE *
      INTO  ls_param
      FROM  zvv_param
      WHERE lookup_name = 'HU_MOVE_TO_HU_MANAGED_SLOC'
        AND free_key = 'WERKS'
        AND free_key_value = x_profile-zzwerks
        AND indicator1 = 'X'.
    IF ls_param IS NOT INITIAL.
      IF ( ls_param-value1 IS INITIAL ) OR ( ls_param-value1 IS NOT INITIAL AND
                      ls_param-value1 CS zsits_scan_humove-zzlgort ).

        IF lv_xhupf IS INITIAL.
          v_err_fg = abap_true.
          lv_sloc_check = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF v_err_fg EQ abap_true.
    " Storage location is not given or invalid
    IF lv_sloc_check = 'X'.
      MESSAGE e059 INTO v_dummy.
    ELSE.
      MESSAGE e013 INTO v_dummy.
    ENDIF.
* Update log and display error message on next screen if error occurs
    PERFORM frm_add_message USING zcl_its_utility=>gc_objid_label
                                  zsits_scan_dynp-zzbarcode
                                  v_err_fg.
  ENDIF.

ENDFORM.                    " FRM_CHECK_LGORT

*&---------------------------------------------------------------------*
*&      Form  FRM_CHECK_KOSTL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_check_kostl .

  DATA lv_kostl TYPE csks-kostl.
  IF zsits_scan_humove-zzkostl IS INITIAL.
    IF v_huwbevent EQ '0013'.
      v_err_fg = abap_true.
    ENDIF.
  ELSE.
    SELECT SINGLE kostl INTO lv_kostl FROM csks "#EC WARNOK "#EC CI_GENBUFF
      WHERE kostl = zsits_scan_humove-zzkostl
        AND datbi > sy-datum.
    IF sy-subrc NE 0.
      v_err_fg = abap_true.
    ENDIF.
  ENDIF.

  IF v_err_fg EQ abap_true.
    " Cost center is not given or invalid
    MESSAGE e014 INTO v_dummy.
  ENDIF.

ENDFORM.                    " FRM_CHECK_KOSTL

*&---------------------------------------------------------------------*
*&      Form  FRM_CHECK_GRUND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_check_grund .

  DATA lv_grund TYPE t157d-grund.
  IF zsits_scan_humove-zzgrund IS INITIAL.
    v_err_fg = abap_true.
  ELSE.
    SELECT SINGLE grund INTO lv_grund FROM t157d            "#EC WARNOK
      WHERE grund = zsits_scan_humove-zzgrund.
    IF sy-subrc NE 0.
      v_err_fg = abap_true.
    ENDIF.
  ENDIF.

  IF v_err_fg EQ abap_true.
    " Reason for movement is not given or invalid
    MESSAGE e015 INTO v_dummy.
  ENDIF.

ENDFORM.                    " FRM_CHECK_GRUND

*&---------------------------------------------------------------------*
*&      Form  FRM_CHECK_WBSCD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_check_wbscd .

  DATA lv_wbscd TYPE prps-posid.
  IF zsits_scan_humove-zzwbscd IS INITIAL.
    v_err_fg = abap_true.
  ELSE.
    SELECT SINGLE posid INTO lv_wbscd FROM prps             "#EC WARNOK
      WHERE posid = zsits_scan_humove-zzwbscd.
    IF sy-subrc NE 0.
      v_err_fg = abap_true.
    ENDIF.
  ENDIF.

  IF v_err_fg EQ abap_true.
    " WBS element is not given or invalid
    MESSAGE e023 INTO v_dummy.
  ENDIF.

ENDFORM.                    " FRM_CHECK_WBSCD

*&---------------------------------------------------------------------*
*&      Form  FRM_CHECK_QUANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_check_quant .

  CHECK v_err_fg EQ abap_false.

* Copy/check quantity
  IF zsits_scan_humove-zzquant EQ 0.
    v_err_fg = abap_true.
    " Please input the quantity
    MESSAGE e035 INTO v_dummy.
  ELSEIF zsits_scan_humove-zzquant GT x_hu_item-pack_qty.
    v_err_fg = abap_true.
    " HU does not contain so much quantity
    MESSAGE e026 WITH x_label_content-zzhu_exid INTO v_dummy.
  ENDIF.

ENDFORM.                    " FRM_CHECK_QUANT

*&---------------------------------------------------------------------*
*&      Form  FRM_READ_BARCODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_read_barcode .

  DATA: lv_label_type   TYPE zdits_label_type,
        lx_read_option  TYPE zsits_batch_read_option,
        lwa_label_range TYPE zslabel_type_range,
        lit_label_type  TYPE ztlabel_type_range,
        ls_return       TYPE bapiret2,
        lo_auth_check   TYPE REF TO zcl_auth_check,
        go_hu           TYPE REF TO zcl_rfscanner_packunpack,
        lv_flag         TYPE c,
        lv_exidv        TYPE exidv,
        lv_exidv1       TYPE c LENGTH 100,
        lv_barcode1     TYPE string,
        lv_barcode      TYPE string.

  CHECK v_err_fg EQ abap_false.
  CLEAR: x_label_content, lv_flag.

* Mandatory check
  IF zsits_scan_dynp-zzbarcode IS INITIAL.
    v_err_fg = abap_true.
    " HU number is required
    MESSAGE e002 INTO v_dummy.
  ELSE.


    GET PARAMETER ID 'ZGELATIN' FIELD lv_flag.

    IF lv_flag <> abap_true.
*--Read the HU number enter one is with Prefix or not
*--If not prefix of HU number then add Prefix with below code
*--Create Class Object for validation
      lv_exidv1 = zsits_scan_dynp-zzbarcode.
      CONDENSE lv_exidv1.
      CREATE OBJECT go_hu.
      CALL METHOD go_hu->hubarcode_value
        EXPORTING
          iv_exidv    = lv_exidv1
        IMPORTING
          ev_hunumber = lv_exidv1.
      zsits_scan_dynp-zzbarcode = lv_exidv1.
* Set label type
      lwa_label_range-sign   = 'I'.
      lwa_label_range-zoption = 'EQ'.
      lwa_label_range-low    = zcl_its_utility=>gc_label_hu.
      APPEND lwa_label_range TO lit_label_type.
* Read barcode
*REad the barcode
      CALL METHOD zcl_mde_barcode=>disolve_barcode
        EXPORTING
          iv_barcode          = zsits_scan_dynp-zzbarcode
          iv_werks            = ' '
          is_read_option      = lx_read_option
          it_label_type_range = lit_label_type
        IMPORTING
          es_label_content    = x_label_content.
    ELSE.
      lv_barcode = zsits_scan_dynp-zzbarcode.
      CALL FUNCTION 'ZWM_HU_VALIDATE'
        EXPORTING
          iv_barcode       = lv_barcode
        IMPORTING
          ev_exidv         = lv_exidv
          es_return        = ls_return
          ev_barcode       = lv_barcode1
          es_label_content = x_label_content.
      zsits_scan_dynp-zzbarcode = lv_barcode1.
      CLEAR lv_flag.
    ENDIF.
    IF x_label_content-zzhu_exid IS INITIAL.
      v_err_fg = abap_true.
      " the barcode is not a HU
      MESSAGE e025(zitsus) WITH zsits_scan_dynp-zzbarcode INTO v_dummy.
    ELSE.
      READ TABLE x_label_content-hu_content-hu_content INDEX 1 INTO x_hu_item.
      IF sy-subrc NE 0.
        v_err_fg = abap_true.
        " HU is empty
        MESSAGE e287(zits) WITH x_label_content-zzhu_exid INTO v_dummy.
      ELSEIF x_profile-zzwerks IS NOT INITIAL.
        zsits_scan_humove-zzwerks = x_profile-zzwerks.
        IF zsits_scan_humove-zzwerks IS NOT INITIAL.
          CLEAR ls_return.
          CREATE OBJECT lo_auth_check.
          ls_return = lo_auth_check->auth_check_plant( EXPORTING iv_werks = zsits_scan_humove-zzwerks iv_activity = '02' ).
          IF ls_return IS NOT INITIAL.
            MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number INTO v_dummy
            WITH ls_return-message_v1.
            v_err_fg = abap_true.
          ENDIF.
        ENDIF.
      ELSEIF x_profile-zzlgnum IS NOT INITIAL.
** This check (Plant / Warehouse location) is not required for Bend " INC4872548
**        SELECT SINGLE werks FROM t320 INTO zsits_scan_humove-zzwerks
**          WHERE werks = x_hu_item-plant
**            AND lgort = x_hu_item-stge_loc
**            AND lgnum = x_profile-zzlgnum.
**        IF sy-subrc NE 0.
**          v_err_fg = abap_true.
**          " Your current location &1 is not match with the &2
**          MESSAGE e442(zits) WITH x_profile-zzlgnum x_label_content-zzhu_exid INTO v_dummy.
**        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " FRM_READ_BARCODE

*&---------------------------------------------------------------------*
*&      Form  FRM_GET_MOVEMENT_TYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_get_movement_type .

  DATA: lv_stock_cat   TYPE bestq,
        lv_subrc       TYPE i,
        lx_thuwbbwart  TYPE thuwbbwart,
        lit_thuwbbwart TYPE hum_thuwbbwart_t,
        ls_return      TYPE bapiret2,
        lo_auth_check  TYPE REF TO zcl_auth_check.

  CHECK v_err_fg EQ abap_false.

* Get stock category from HU item
  lv_stock_cat = x_hu_item-stock_cat.
* Reset movement type
*-VLMOVE automatically changes the process code & stock category. The following
*-changes of process code & stock category are the same as the hard-coded logic
*-in standard program.
  CASE v_huwbevent.
    WHEN '0005'.
      lv_stock_cat = zcl_its_utility=>gc_stock_cat_qi.
    WHEN '0021'.
      v_huwbevent  = '0004'.
      lv_stock_cat = zcl_its_utility=>gc_stock_cat_blk.
    WHEN '0022'.
      v_huwbevent  = '0003'.
      lv_stock_cat = zcl_its_utility=>gc_stock_cat_blk.
    WHEN '0023'.
      v_huwbevent  = '0005'.
      lv_stock_cat = zcl_its_utility=>gc_stock_cat_avl.
    WHEN '0024'.
      v_huwbevent  = '0006'.
      lv_stock_cat = zcl_its_utility=>gc_stock_cat_qi.
    WHEN '0025'.
      v_huwbevent  = '0006'.
      lv_stock_cat = zcl_its_utility=>gc_stock_cat_blk.
    WHEN OTHERS.
  ENDCASE.
* Get possible movement types from standard table
  CALL FUNCTION 'HUGM_THUWBBWART_SELECT'
    EXPORTING
      if_event      = v_huwbevent
    IMPORTING
      et_thuwbbwart = lit_thuwbbwart.
* Get possible movement types from custom table
  SELECT * FROM ztits_thuwbbwart APPENDING TABLE lit_thuwbbwart
    WHERE huwbevent = v_huwbevent
      AND stock_cat = lv_stock_cat.
* Get movement type by stock category
  READ TABLE lit_thuwbbwart WITH KEY stock_cat = lv_stock_cat INTO lx_thuwbbwart.
  IF sy-subrc NE 0.
    v_err_fg = abap_true.
    " Movement type not maintained with activity &1, stock cat. &2
    MESSAGE e012 WITH v_huwbevent lv_stock_cat INTO v_dummy.
  ELSE.
* Check authority
*    lv_subrc = zcl_its_utility=>authority_check_dfs( iv_plant = zsits_scan_humove-zzwerks
*                                                     iv_move_type = lx_thuwbbwart-move_type ).
*    IF lv_subrc NE 0.
*      v_err_fg = abap_true.
*    ELSE.
    zsits_scan_humove-zzbwart = lx_thuwbbwart-move_type.
    IF lx_thuwbbwart-move_type IS NOT INITIAL.
      CLEAR ls_return.
      CREATE OBJECT lo_auth_check.
      ls_return =  lo_auth_check->auth_check_mvmt( EXPORTING iv_bwart = lx_thuwbbwart-move_type
                                                             iv_activity = '01').
      IF ls_return IS NOT INITIAL.
        MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number INTO v_dummy
        WITH ls_return-message_v1.
        v_err_fg = abap_true.
      ENDIF.
    ENDIF.
*    ENDIF.
  ENDIF.

ENDFORM.                    " FRM_GET_MOVEMENT_TYPE

*&---------------------------------------------------------------------*
*&      Form  FRM_HU_MOVEMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_hu_movement .
  CONSTANTS: lc_dloc     TYPE zlookup_name
                      VALUE 'DLOC',
             lc_lgort    TYPE zfree_key_value
                      VALUE 'LGORT',
             lc_itemtype TYPE velin VALUE '3',
             lc_s        TYPE char1 VALUE 'S',
             lc_flag     TYPE char1  VALUE 'X'.
  DATA: lv_posted       TYPE sysubrc,
        lx_message      TYPE huitem_messages,
        lx_emkpf        TYPE emkpf,
        lwa_move_to     TYPE hum_data_move_to,
        lwa_external_id TYPE hum_exidv,
        lit_move_to     TYPE hum_data_move_to_t,
        lit_external_id TYPE hum_exidv_t,
        lit_messages    TYPE huitem_messages_t,
        lv_zvv_param    TYPE zvv_param.
  DATA: ls_return   TYPE bapiret2.
  DATA:   ls_header  TYPE bapihuheader,
          lv_headehu TYPE exidv,
          lv_msgv1   TYPE msgv1,
          lv_flagset TYPE char1,
          ls_lhu     TYPE bapihuitmunpack,
          lt_return  TYPE TABLE OF bapiret2,
          ls_barcode TYPE exidv.
  CHECK v_err_fg EQ abap_false.

* Prepare BAPI input
  lwa_move_to-huwbevent = v_huwbevent." Process code
  lwa_move_to-bwart = zsits_scan_humove-zzbwart." Movement type
  lwa_move_to-werks = zsits_scan_humove-zzwerks." Plant
  lwa_move_to-lgort = zsits_scan_humove-zzlgort." Storage location
  IF v_huwbevent EQ '0013'.                                               "EICR 637326
    lwa_move_to-kostl = zsits_scan_humove-zzkostl." Cost center      ""EICR 637326
  ENDIF.                                                               "EICR 637326
*  lwa_move_to-kostl = zsits_scan_humove-zzkostl." Cost center      "
  lwa_move_to-grund = zsits_scan_humove-zzgrund." Reason for movement
  APPEND lwa_move_to TO lit_move_to.

  LOOP AT it_su INTO wa_su.
    lwa_external_id-exidv = wa_su.
    APPEND lwa_external_id TO lit_external_id.
  ENDLOOP.
  IF sy-subrc NE 0.
    lwa_external_id-exidv = x_label_content-zzhu_exid.
    APPEND lwa_external_id TO lit_external_id.
  ENDIF.

* Unpack Carton if it is in a Pallet
  IF NOT x_label_content-hu_content-hu_header-higher_level_hu IS INITIAL. " Carton
    SELECT SINGLE exidv
            FROM vekp
            INTO @DATA(ls_exidv)
           WHERE venum = @x_label_content-hu_content-hu_header-higher_level_hu.
    IF sy-subrc = 0.
      ls_lhu-unpack_exid = x_label_content-zzhu_exid.
      ls_lhu-hu_item_type = lc_itemtype.
      lv_headehu = ls_exidv. " Pallet
      CALL FUNCTION 'BAPI_HU_UNPACK'
        EXPORTING
          hukey      = lv_headehu
          itemunpack = ls_lhu
        IMPORTING
          huheader   = ls_header
        TABLES
          return     = lt_return.
      IF lt_return[] IS NOT INITIAL.
        READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<ls_log>)
                              WITH KEY type = lc_s.
        IF sy-subrc EQ 0.
*Commit if successfully unpacked
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = lc_flag.
          CLEAR : lt_return, ls_header, lv_flagset, lv_headehu.
        ELSE.
          lv_flagset = lc_flag.
        ENDIF.
      ELSE.
        IF lt_return IS INITIAL AND ls_header IS NOT INITIAL.
*Commit if successfully unpacked
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = lc_flag.
          CLEAR : lt_return, ls_header, lv_flagset,lv_headehu.
        ELSE.
          lv_flagset = lc_flag.
          lv_msgv1 = ls_header-hu_exid.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.


* END: EICR:603155 SDHANANJAY - Project ONE: HC & DFS Implementation US & MX


* Post goods movement
  CALL FUNCTION 'HU_CREATE_GOODS_MOVEMENT'
    EXPORTING
      if_event       = v_huwbevent
      if_tcode       = 'VLMOVE'
      it_move_to     = lit_move_to
      it_external_id = lit_external_id
    IMPORTING
      ef_posted      = lv_posted
      es_message     = lx_message
      et_messages    = lit_messages
      es_emkpf       = lx_emkpf.
* Get result
  IF lv_posted EQ 1 AND lx_emkpf IS NOT INITIAL.
    COMMIT WORK AND WAIT.
    SELECT SINGLE * FROM zvv_param INTO lv_zvv_param WHERE lookup_name = lc_dloc
                                                       AND free_key = lc_lgort
                                                       AND free_key_value = lwa_move_to-lgort.
    IF sy-subrc = 0.
      PERFORM frm_hu_upack USING lwa_external_id-exidv
                         CHANGING ls_return.
    ENDIF.
  ELSE.
    v_err_fg = abap_true.
    ROLLBACK WORK.
  ENDIF.
* Get result message
  IF lx_message IS INITIAL.
    READ TABLE lit_messages INDEX 1 INTO lx_message.
  ENDIF.
  IF lx_message IS NOT INITIAL.
    MESSAGE ID lx_message-msgid TYPE lx_message-msgty NUMBER lx_message-msgno
      WITH lx_message-msgv1 lx_message-msgv2
           lx_message-msgv3 lx_message-msgv4 INTO v_dummy.
  ENDIF.

ENDFORM.                    " FRM_HU_MOVEMENT

*&---------------------------------------------------------------------*
*&      Form  FRM_HU_UNPACK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_hu_unpack  USING    uv_quantity TYPE zsits_scan_humove-zzquant.

  DATA: lv_hukey      TYPE bapihukey-hu_exid,
        lx_itemunpack TYPE bapihuitmunpack,
        lx_return     TYPE bapiret2,
        lit_return    TYPE STANDARD TABLE OF bapiret2.

  CHECK v_err_fg EQ abap_false.

* Prepare BAPI input
  lv_hukey = x_label_content-zzhu_exid.
  lx_itemunpack-hu_item_type   = x_hu_item-hu_item_type.
  lx_itemunpack-hu_item_number = x_hu_item-hu_item_number.
  lx_itemunpack-pack_qty       = uv_quantity.
* Unpack HU
  CALL FUNCTION 'BAPI_HU_UNPACK'
    EXPORTING
      hukey      = lv_hukey
      itemunpack = lx_itemunpack
    TABLES
      return     = lit_return.
* Get result message
  LOOP AT lit_return INTO lx_return WHERE type EQ 'E' OR type EQ 'A'.
    ROLLBACK WORK.
    v_err_fg = abap_true.
    MESSAGE ID lx_return-id TYPE lx_return-type NUMBER lx_return-number
      WITH lx_return-message_v1 lx_return-message_v2
           lx_return-message_v3 lx_return-message_v4 INTO v_dummy.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
    COMMIT WORK AND WAIT.
  ENDIF.

ENDFORM.                    " FRM_HU_UNPACK

*&---------------------------------------------------------------------*
*&      Form  FRM_MATERIAL_MOVEMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_material_movement  USING    uv_quantity TYPE zsits_scan_humove-zzquant.

  DATA: lv_parlg            TYPE t001l-parlg,
        lx_goodsmvt_header  TYPE bapi2017_gm_head_01,
        lx_goodsmvt_code    TYPE bapi2017_gm_code,
        lx_goodsmvt_headret TYPE bapi2017_gm_head_ret,
        lx_return           TYPE bapiret2,
        lwa_goodsmvt_item   TYPE bapi2017_gm_item_create,
        lit_goodsmvt_item   TYPE STANDARD TABLE OF bapi2017_gm_item_create,
        lit_return          TYPE STANDARD TABLE OF bapiret2.

  CHECK v_err_fg EQ abap_false.

* Prepare BAPI input
  lx_goodsmvt_header-pstng_date   = sy-datlo. "local date for current user
  lx_goodsmvt_code-gm_code        = zcl_its_utility=>gc_gm_code_03.
  lwa_goodsmvt_item-plant         = x_hu_item-plant.
  lwa_goodsmvt_item-stge_loc      = x_hu_item-stge_loc.
  lwa_goodsmvt_item-material      = x_hu_item-material.
  lwa_goodsmvt_item-batch         = x_hu_item-batch.
  lwa_goodsmvt_item-entry_uom     = x_hu_item-base_unit_qty.
  lwa_goodsmvt_item-entry_uom_iso = x_hu_item-base_unit_qty_iso.
  lwa_goodsmvt_item-move_type     = zsits_scan_humove-zzbwart.
  lwa_goodsmvt_item-wbs_elem      = zsits_scan_humove-zzwbscd.
  lwa_goodsmvt_item-entry_qnt     = uv_quantity.
* If HU is in HU-managed storage location, do posting from partner storage location.
  SELECT SINGLE parlg INTO lv_parlg FROM t001l
    WHERE werks = x_hu_item-plant
      AND lgort = x_hu_item-stge_loc
      AND xhupf = abap_true.
  IF sy-subrc EQ 0.
    lwa_goodsmvt_item-stge_loc = lv_parlg.
  ENDIF.
  APPEND lwa_goodsmvt_item TO lit_goodsmvt_item.
* Post goods movment
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = lx_goodsmvt_header
      goodsmvt_code    = lx_goodsmvt_code
    IMPORTING
      goodsmvt_headret = lx_goodsmvt_headret
    TABLES
      goodsmvt_item    = lit_goodsmvt_item
      return           = lit_return.
* Get return message
  LOOP AT lit_return INTO lx_return WHERE type EQ 'E' OR type EQ 'A'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
* Record data into INDX table for reprocess
    MESSAGE ID lx_return-id TYPE lx_return-type NUMBER lx_return-number
      WITH lx_return-message_v1 lx_return-message_v2
           lx_return-message_v3 lx_return-message_v4 INTO v_dummy.
    PERFORM frm_reprocess_log USING v_dummy.
* Set error message for reprocess
    v_err_fg = abap_true.
    MESSAGE e041 INTO v_dummy.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
    MESSAGE s309(hugeneral) WITH lx_goodsmvt_headret-mat_doc INTO v_dummy.
  ENDIF.

ENDFORM.                    " FRM_MATERIAL_MOVEMENT

*&---------------------------------------------------------------------*
*&      Form  FRM_REPROCESS_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_reprocess_log   USING uv_msg TYPE string.

  DATA: lv_log_handler TYPE indx_srtfd,
        lx_post_log    TYPE zsits_post_log,
        lr_srtfd       TYPE RANGE OF indx-srtfd,
        lwa_srtfd      LIKE LINE OF lr_srtfd,
        lit_indx       TYPE STANDARD TABLE OF indx.         "#EC NEEDED

* Set post log
  lx_post_log-message = uv_msg.
  lx_post_log-erdat = sy-datlo.
  lx_post_log-ernam = sy-uname.
  lx_post_log-uzeit = sy-timlo.
* Convert HU number to output
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = x_label_content-zzhu_exid
    IMPORTING
      output = x_label_content-zzhu_exid.
* Initialize log handler ID
  lv_log_handler = zcl_its_utility=>gc_log_prefix_humove && x_label_content-zzhu_exid.
* Check existing IDs with same HU number
  lwa_srtfd-sign   = 'I'.
  lwa_srtfd-option = 'CP'.
  lwa_srtfd-low    = lv_log_handler && |*|.
  APPEND lwa_srtfd TO lr_srtfd.
  SELECT * FROM indx INTO TABLE lit_indx WHERE srtfd IN lr_srtfd. "#EC CI_NOFIRST
* Set sequence number of log handler ID
  lv_log_handler = lv_log_handler && |(| && sy-dbcnt && |)|.
* Export data to table INDX
  EXPORT p1 = lx_post_log
         p2 = x_label_content
         p3 = zsits_scan_humove
  TO DATABASE indx(z8) ID lv_log_handler.

ENDFORM.                    " FRM_REPROCESS_LOG
*Begin of change ED2K909551 INC4811658/1 VARGHA 01/24/2017
*&---------------------------------------------------------------------*
*&      Form  CHECK_BIN
*&---------------------------------------------------------------------*
*       Check HU Bin and Packing Bin
* find packing bin details from table T340D using warehouse default values
*    LGNUM -  T340D-EATYP, T340D-EAPLA
* if HU Bin is different from Packing Bin, then move the HU to
* Packing Bin and then only proceed with UnPack and Post Material movement
*----------------------------------------------------------------------*
FORM check_bin .

  DATA :
    lv_eatyp TYPE t340d-eatyp,
    lv_eapla TYPE t340d-eapla.

  SELECT SINGLE eatyp eapla INTO (lv_eatyp, lv_eapla)
         FROM t340d WHERE lgnum = x_profile-zzlgnum.

  CHECK sy-subrc EQ 0 AND lv_eapla IS NOT INITIAL.
  IF x_label_content-su_content-su_header-lgpla NE lv_eapla.
    PERFORM create_to_move_su USING x_label_content-zzhu_exid
                                    lv_eatyp
                                    lv_eapla.
  ENDIF.
*  CALL FUNCTION 'L_IM_RELEASE_BUFFER' .
ENDFORM.                    " CHECK_BIN
*&---------------------------------------------------------------------*
*&      Form  CREATE_TO_MOVE_SU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_lenum  HU Number
*      -->p_nltyp  Destination Bin Type
*      -->p_nlpla  Destination Bin
*----------------------------------------------------------------------*
FORM create_to_move_su  USING    p_lenum TYPE lein-lenum
                                 p_nltyp TYPE ltap-nltyp
                                 p_nlpla TYPE ltap-nlpla.

  DATA : lv_tanum TYPE ltak-tanum .

  CALL FUNCTION 'L_TO_CREATE_MOVE_SU' IN BACKGROUND TASK
    EXPORTING
      i_lenum               = p_lenum
      i_bwlvs               = '999'
      i_nltyp               = p_nltyp
      i_nlpla               = p_nlpla
      i_squit               = 'X'
      i_update_task         = 'X'
      i_commit_work         = 'X'
    IMPORTING
      e_tanum               = lv_tanum
    EXCEPTIONS
      not_confirmed_to      = 1
      foreign_lock          = 2
      bwlvs_wrong           = 3
      betyp_wrong           = 4
      nltyp_wrong           = 5
      nlpla_wrong           = 6
      nltyp_missing         = 7
      nlpla_missing         = 8
      squit_forbidden       = 9
      lgber_wrong           = 10
      xfeld_wrong           = 11
      drukz_wrong           = 12
      ldest_wrong           = 13
      no_stock_on_su        = 14
      su_not_found          = 15
      update_without_commit = 16
      no_authority          = 17
      benum_required        = 18
      ltap_move_su_wrong    = 19
      lenum_wrong           = 20
      OTHERS                = 21.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    WAIT UP TO 1 SECONDS.
    CALL FUNCTION 'DEQUEUE_ALL'
      EXPORTING
        _synchron = 'X'.
  ENDIF.
ENDFORM.                    " CREATE_TO_MOVE_SU
*End of change ED2K909551 INC4811658/1 VARGHA 01/24/2017
*&---------------------------------------------------------------------*
*&      Form  ADD_SU
*&---------------------------------------------------------------------*
*       ADD SU
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM add_su .
  CHECK sy-dynnr = '9100' OR sy-dynnr = '9200'.
  READ TABLE it_su INTO wa_su WITH KEY x_label_content-zzhu_exid.
  IF sy-subrc EQ 0.
    " SU already added
  ELSE.
    IF v_err_fg IS INITIAL.
      wa_su = x_label_content-zzhu_exid.
      APPEND wa_su TO it_su.
      CLEAR : wa_su.
    ENDIF.
  ENDIF.
ENDFORM.                    " ADD_SU
*&---------------------------------------------------------------------*
*&      Form  TABLE_SCROLL
*&---------------------------------------------------------------------*
*       <-- P_OK_CODE => User action (OK_CODE)
*----------------------------------------------------------------------*
*       Scrolling in table control
*----------------------------------------------------------------------*
FORM table_scroll USING p_ok_code TYPE sy-ucomm.

  DATA : l_tc_new_top_line     TYPE i .

  CASE p_ok_code.

    WHEN 'P++'.  " Last Page
      l_tc_new_top_line =  ztblctrl_su-lines - 4.
    WHEN 'P+'.   " Next Page
      l_tc_new_top_line =  ztblctrl_su-top_line + 5.
    WHEN 'P-'.   " Previous Page
      l_tc_new_top_line =  ztblctrl_su-top_line - 5.
    WHEN 'P--'.  " First Page
      l_tc_new_top_line = 1.
  ENDCASE.

  IF l_tc_new_top_line GT ztblctrl_su-lines.
    l_tc_new_top_line = ztblctrl_su-lines - 4.
  ELSEIF l_tc_new_top_line LT 1.
    l_tc_new_top_line = 1.
  ENDIF.

  ztblctrl_su-top_line = l_tc_new_top_line.
ENDFORM.                    " TABLE_SCROLL

* BEGIN: EICR:603155 SDHANANJAY - Project ONE: HC & DFS Implementation US & MX
*&---------------------------------------------------------------------*
*&      Form  FRM_HU_UNPACK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_hu_upack  USING iv_exidv TYPE vekp-exidv
                    CHANGING cs_return TYPE bapiret2.
*Unpack the Cartons HU
  DATA :lv_exidv  TYPE vekp-exidv,
        ls_lhu    TYPE bapihuitmunpack,
        lt_header TYPE bapihuheader,
        lt_return TYPE STANDARD TABLE OF bapiret2,
        lt_head   TYPE TABLE OF vekpvb,
        ls_head   TYPE vekpvb.

  CONSTANTS: lc_success  TYPE char1 VALUE 'S',
             lc_error    TYPE char1 VALUE 'E',
             lc_itemtype TYPE velin VALUE '3'.

  CLEAR lv_exidv.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = iv_exidv
    IMPORTING
      output = lv_exidv.

  SELECT SINGLE * FROM vekp
               INTO @DATA(ls_vekp)
               WHERE exidv = @iv_exidv.

  IF sy-subrc = 0 AND NOT ls_vekp-uevel IS INITIAL. " Carton is scanned
    MOVE-CORRESPONDING ls_vekp TO ls_head.
    APPEND ls_head TO lt_head.
  ELSEIF sy-subrc = 0 AND ls_vekp-uevel IS INITIAL. " Pallet is scanned
    CALL FUNCTION 'HU_GET_ONE_HU_DB'
      EXPORTING
        if_hu_number  = lv_exidv
        if_all_levels = abap_true
      IMPORTING
        et_hu_header  = lt_head
      EXCEPTIONS
        hu_not_found  = 1
        hu_locked     = 2
        fatal_error   = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
* lt_head will be blank which is handled in the next IF condition
    ELSE.
*--Remove Header HU number from internal table
      DELETE lt_head WHERE exidv = lv_exidv.
    ENDIF.
  ELSE.
    RETURN.
  ENDIF.
  IF NOT lt_head IS INITIAL.

    LOOP AT lt_head INTO ls_head.
      ls_lhu-hu_item_type = lc_itemtype.
      ls_lhu-unpack_exid = ls_head-exidv.
*--UnPack Lower Level HU's from Higher Level pallet
      CALL FUNCTION 'BAPI_HU_UNPACK'
        EXPORTING
          hukey      = lv_exidv
          itemunpack = ls_lhu
        IMPORTING
          huheader   = lt_header
        TABLES
          return     = lt_return.

* Error Handling
      IF lt_return[] IS NOT INITIAL.
        READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<lfs_return>)
                                           WITH KEY type = lc_success.
        IF sy-subrc EQ 0.
*--Commit if successfully pack
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = abap_true.
          MOVE <lfs_return> TO cs_return.
          CLEAR: <lfs_return>, lt_header.
        ELSE.
          v_err_fg = abap_true.
          ROLLBACK WORK.
        ENDIF.

      ELSE.
        IF lt_return IS INITIAL AND lt_header IS NOT INITIAL.
*--Commit if successfully pack
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = abap_true.
          CLEAR: lt_header.
        ELSE.
          v_err_fg = abap_true.
          ROLLBACK WORK.
        ENDIF.
      ENDIF.
      CLEAR: ls_head, ls_lhu, lt_return.
    ENDLOOP.
  ELSE. "Unpack not possible
    v_err_fg = abap_true.
  ENDIF.
ENDFORM.
