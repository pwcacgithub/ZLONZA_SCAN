class ZCL_RFSCANNER_POSTGI definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ts_message,
             message1 TYPE char50,
             message2 TYPE char50,
             message3 TYPE char50,
             message4 TYPE char50,
             message5 TYPE char50,
             message6 TYPE char50,
             message7 TYPE char50,
             message8 TYPE char50,
          END OF ts_message .
  types:
    BEGIN OF ts_likp,
          vbeln TYPE vbeln_vl,
          vstel TYPE vstel,
          lfart TYPE lfart,
          kunnr TYPE kunwe,
          lgnum TYPE lgnum,
          lifnr TYPE elifn,
          werks TYPE empfw,
         END OF ts_likp .
  types:
    BEGIN OF ts_vbuk,
           vbeln TYPE vbeln,
           lvstk TYPE lvstk,
           pkstk TYPE pkstk,
         END OF ts_vbuk .
  types:
    tt_vbuk TYPE STANDARD TABLE OF ts_vbuk .

  data GS_LIKP type TS_LIKP .
  data GS_VBUK type TS_VBUK .
  data GT_VBUK type TT_VBUK .

  methods CONSTRUCTOR
    importing
      value(IV_VBELN) type TS_LIKP-VBELN .
  methods CHECK_ZLPOSTGOODS
    returning
      value(EV_CHECK) type BOOLEAN .
  methods CHECK_WM_RELEVANT
    returning
      value(EV_WM_RELEVANT) type BOOLEAN .
  methods CHECK_PICKING
    returning
      value(EV_PICKING) type BOOLEAN .
  methods POST_GOODS_ISSUE
    exporting
      !EV_MESG type BAPI_MSG
    returning
      value(EV_ERROR) type BOOLEAN .
  methods VALIDATE_DELIVERY
    exporting
      value(EV_RETURN) type BAPIRET2
    returning
      value(EV_INVALIDE) type BOOLEAN .
  methods GET_ITEM_DISPLAY
    exporting
      !ES_LIKP type TS_LIKP
      !EV_VENDOR_NAME type NAME1_GP
      !EV_SHP_NAME type NAME1_GP .
  methods MESSAGE_DISPLAY
    importing
      value(LV_ID) type CHAR20
      value(LV_VALUE) type CHAR20
      value(LV_NO) type CHAR3
    exporting
      !ES_MESSAGE type TS_MESSAGE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_RFSCANNER_POSTGI IMPLEMENTATION.


  method CHECK_PICKING.
    READ TABLE gt_vbuk INTO DATA(ls_pick) WITH KEY vbeln = gs_likp-vbeln.
* check if the delivery is vaild Packing
    IF sy-subrc IS INITIAL.
      IF ls_pick-pkstk = 'C'.
        ev_picking = abap_true.
      ELSE.
        ev_picking = abap_false.
      ENDIF.
    ELSE.
      ev_picking = abap_false.
    ENDIF.
  endmethod.


  method CHECK_WM_RELEVANT.
    READ TABLE gt_vbuk INTO DATA(ls_vbuk) WITH KEY vbeln = gs_likp-vbeln.
* check if the Delivery is vaild for WM or not
    IF sy-subrc IS INITIAL.
      IF ls_vbuk-lvstk IS NOT INITIAL.
        ev_wm_relevant = abap_true."'R'.
      ELSE.
        ev_wm_relevant = abap_false."'NR'.
      ENDIF.
    ENDIF.
  endmethod.


  METHOD check_zlpostgoods.
    DATA: lv_werks TYPE werks_d,"vstel,
          lv_lfart TYPE lfart,
          lv_vstel TYPE werks_d.
*-- check if the Delivery is valid for process if the entry exists in ZLPOSTGOODS
    IF gs_likp IS NOT INITIAL.
      CLEAR: lv_werks,lv_lfart,lv_vstel.
      lv_vstel = gs_likp-vstel.
      SELECT SINGLE werks
                    lfart
        FROM zlpostgoods
        INTO ( lv_werks,lv_lfart )
        WHERE werks = lv_vstel
        AND   lfart = gs_likp-lfart.
        IF sy-subrc IS NOT INITIAL.
          ev_check = abap_true.
        ENDIF.
    ELSE.
      ev_check = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD constructor.
* conver input delivery number to internal format
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input         = iv_vbeln
     IMPORTING
       output        = iv_vbeln.
* get the delivery headder details
    SELECT SINGLE vbeln
                  vstel
                  lfart
                  kunnr
                  lgnum
                  lifnr
                  werks
      FROM likp
      INTO gs_likp
      WHERE vbeln = iv_vbeln.
      IF sy-subrc IS INITIAL.
* get status for the delivery
            SELECT vbeln
                   lvstk
                   pkstk
              FROM vbuk
              INTO TABLE gt_vbuk
              WHERE vbeln = gs_likp-vbeln.
              IF sy-subrc IS INITIAL.
                SORT gt_vbuk BY vbeln.
              ENDIF.
      ENDIF.
  ENDMETHOD.


  METHOD get_item_display.

    es_likp = gs_likp.

* get the Vendor name
    SELECT SINGLE name1
      FROM lfa1
      INTO ev_vendor_name
      WHERE lifnr = gs_likp-lifnr.
      IF sy-subrc IS NOT INITIAL.
        CLEAR ev_vendor_name.
      ENDIF.
* get the Shp to name
      SELECT SINGLE name1
        FROM kna1
        INTO ev_shp_name
        WHERE kunnr = gs_likp-kunnr.
        IF sy-subrc IS NOT INITIAL.
          CLEAR ev_shp_name.
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
     id              = lv_msgid
     lang            = lc_lang
     no              = lv_num "'001'
     v1              = lv_value1
   IMPORTING
     msg             = lv_message
   EXCEPTIONS
     not_found       = 1
     OTHERS          = 2.
  IF sy-subrc IS NOT INITIAL.
* do nothing
  ENDIF.
      lv_mes =      lv_message.
  IF sy-subrc EQ 0 AND lv_message IS NOT INITIAL.
*--Split message text into work area
    CALL FUNCTION 'RKD_WORD_WRAP'
      EXPORTING
       textline                  = lv_mes
       outputlen                 = 20
     TABLES
       out_lines                 = lt_lines
     EXCEPTIONS
       outputlen_too_large       = 1
       OTHERS                    = 2.
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
  ELSEIF sy-subrc IS NOT INITIAL or lv_message is INITIAL.
     es_message-message1 = lv_value.

  ENDIF.
  ENDMETHOD.


  METHOD post_goods_issue.
* Create PGI
    DATA: lv_vbkok     TYPE vbkok,
          lv_pgi_error TYPE xfeld,
          lt_messages  TYPE TABLE OF prott,
          lv_msgid     TYPE symsgid,
          lv_msgnumb   TYPE symsgno.
CONSTANTS: lc_textformat TYPE bapi_tfrmt VALUE 'NON',
           lc_lang TYPE spras VALUE 'E'.
    CLEAR lv_vbkok.
    lv_vbkok-vbeln_vl = gs_likp-vbeln.
    lv_vbkok-wabuc = abap_true.
    lv_vbkok-wadat_ist = sy-datum.
* FM to create PGI
    CALL FUNCTION 'WS_DELIVERY_UPDATE'
      EXPORTING
        vbkok_wa                           = lv_vbkok
        synchron                           = abap_true
        commit                             = abap_true
        delivery                           = gs_likp-vbeln
        update_picking                     = abap_true
        nicht_sperren                      = abap_true
        if_error_messages_send_0           = space
      IMPORTING
        ef_error_in_goods_issue_0          = lv_pgi_error
      TABLES
        prot                               = lt_messages.
* if any error then get the error message
    IF lv_pgi_error IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ev_error = abap_true.
      READ TABLE lt_messages INTO DATA(lv_msg) WITH KEY vbeln = gs_likp-vbeln.
      IF sy-subrc IS INITIAL.
        lv_msgid = lv_msg-msgid.
        lv_msgnumb = lv_msg-msgno.
        CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
          EXPORTING
            id                 = lv_msgid
            number             = lv_msgnumb
            textformat         = lc_textformat
          IMPORTING
            message            = ev_mesg.
      ELSE.
*--Get the message from message id
          CALL FUNCTION 'FORMAT_MESSAGE'
           EXPORTING
             id              = sy-msgid
             lang            = lc_lang
             no              = sy-msgno
           IMPORTING
             msg             = ev_mesg
           EXCEPTIONS
             not_found       = 1
             OTHERS          = 2.
          IF sy-subrc IS NOT INITIAL.
*         do nothing
          ENDIF.
          CLEAR lv_msg.
      ENDIF.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    ENDIF.
ENDMETHOD.


  METHOD validate_delivery.
    DATA: lv_vbeln TYPE vbeln_vl,
          lv_vstel TYPE vstel,
          lv_werks TYPE werks_d,
          lv_bwart TYPE bwart.
    DATA: lo_auth_check TYPE REF TO zcl_auth_check.
    DATA : lv_dummy TYPE string.
    SELECT SINGLE vbeln vstel
      FROM likp
      INTO (lv_vbeln,lv_vstel)
      WHERE vbeln = gs_likp-vbeln.

    IF sy-subrc IS NOT INITIAL.
      ev_invalide = abap_true.
    ELSE.
************************
*      "Begin of Change by MMUKHERJEE++
      SELECT SINGLE wbstk
        FROM vbuk
        INTO @DATA(lv_wbstk)
        WHERE vbeln = @gs_likp-vbeln.
      IF lv_wbstk = 'C'.
        MESSAGE e247(zlone_hu) INTO lv_dummy.
        ev_return-type = sy-msgty.
        ev_return-id   = sy-msgid.
        ev_return-number = sy-msgno.
        ev_return-message_v1  = sy-msgv1.
        ev_return-message_v2  = sy-msgv2.
        ev_return-message_v3  = sy-msgv3.
        ev_return-message_v4  = sy-msgv4.
      ENDIF.
      IF ev_return IS INITIAL.
*      "End of Change by MMUKHERJEE++
*      **************************
        SELECT posnr,
               werks,
               bwart
          FROM lips
          INTO TABLE @DATA(lt_item)
          WHERE vbeln = @lv_vbeln.
        IF sy-subrc IS INITIAL.
          READ TABLE lt_item INTO DATA(ls_item) INDEX 1.
          lv_werks = ls_item-werks.
          lv_bwart = ls_item-bwart.
        ENDIF.
        CLEAR ls_item.
        REFRESH lt_item.
        CREATE OBJECT lo_auth_check.
        CALL METHOD lo_auth_check->auth_check_plant
          EXPORTING
            iv_werks    = lv_werks
            iv_activity = '02'
          RECEIVING
            es_bapiret2 = ev_return.

        IF ev_return IS INITIAL  AND lv_bwart IS NOT INITIAL.
          CALL METHOD lo_auth_check->auth_check_mvmt
            EXPORTING
              iv_bwart    = lv_bwart
              iv_activity = '01' " create
            RECEIVING
              es_bapiret2 = ev_return.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
