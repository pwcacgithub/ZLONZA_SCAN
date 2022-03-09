*&---------------------------------------------------------------------*
*&  Include           DZH09F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ERROR_MESSAGE
*&---------------------------------------------------------------------*
*       Issue error message for scanners
*----------------------------------------------------------------------*
FORM error_message  USING    ic_msgid TYPE msgid
                             ic_msgno TYPE msgno
                             iv_msgv1 TYPE msgv1.

  DATA      : lv_prevno TYPE sy-dynnr.
  CONSTANTS : lc_msgid1 TYPE char8 VALUE 'ZLONE_HU',
              lc_msgno1 TYPE char6 VALUE 'MSG_NO',
              lc_msgv11 TYPE char5 VALUE 'MSGV1',
              lc_screen TYPE char5 VALUE 'DYNNR'.

*--Call error message screen with message
*--Set Message id
  ##EXISTS
  SET PARAMETER ID lc_msgid1 FIELD ic_msgid.
*--Set Message No
  ##EXISTS
  SET PARAMETER ID lc_msgno1 FIELD ic_msgno.
*--Set Message variable
  ##EXISTS
  SET PARAMETER ID lc_msgv11 FIELD iv_msgv1.
*--Set Message for screen number call back
  CLEAR : lv_prevno.
  lv_prevno = 0100.
* Set previous screen
  ##EXISTS
  SET PARAMETER ID lc_screen FIELD lv_prevno.

*--Call Display message screen
  CALL SCREEN 300.

ENDFORM.                    " ERROR_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  DELETE_HU
*&---------------------------------------------------------------------*
*       Delete HU
*----------------------------------------------------------------------*
FORM delete_hu  USING  i_gs_hu TYPE zcl_rfscanner_packunpack=>ts_phu.
  CONSTANTS: lc_msgid      TYPE msgid VALUE 'ZLONE_HU',
             lc_packed     TYPE msgno  VALUE '004',
             lc_markdel    TYPE msgno VALUE '007',
             lc_deleted    TYPE msgno VALUE '057',
             lc_carton     TYPE msgno VALUE '175',
             lc_invalid_hu TYPE msgno VALUE '001'.

  " ASAH Begin of change for Unpacking pallete

  TYPES : BEGIN OF lty_vepo,
            venum TYPE vepo-venum,
            unvel TYPE vepo-unvel,
          END OF lty_vepo.

  " ASAH End of change for Day warehouse

  DATA: lt_child_hu TYPE STANDARD TABLE OF ts_child_hu,
        lv_count    TYPE i,
        lv_msgv1    TYPE msgv1,
        ls_return   TYPE bapiret2,
        lv_number   TYPE msgno,
        lv_vhart    TYPE vekp-vhart,
        lv_exidv    TYPE vekp-exidv,
        lv_delete   TYPE char1,
        lv_msgno    TYPE msgno,
        lv_uevel    TYPE vekp-uevel,
        lt_lower_hu TYPE STANDARD TABLE OF ts_child_hu,
        lt_vepo     TYPE STANDARD TABLE OF lty_vepo.

  IF i_gs_hu-venum IS NOT INITIAL. " it will always be the case

*    "Start of Change for Day Warehouse "ASAH
    IF gv_unpack IS INITIAL.
      " End of Change for Day Warehouse "ASAH
      " fetch the packaging materialtype from VEKP
      SELECT SINGLE vhart INTO lv_vhart
        FROM vekp WHERE venum = i_gs_hu-venum .
      IF sy-subrc EQ 0.
* Check if the packaging material type is marked for deletion.
        SELECT SINGLE del_hu FROM zlscan_del INTO
          lv_delete WHERE vhart = lv_vhart.
        IF sy-subrc = 0 AND lv_delete EQ abap_true.
* Check if the child HUs exist
          SELECT venum,exidv
          INTO TABLE @lt_child_hu
          FROM vekp WHERE uevel = @i_gs_hu-venum .
          IF sy-subrc NE 0.
*   if no child HU exists.
*   check if the HU is packed with material
            CLEAR lv_count.
            SELECT COUNT(*) FROM vepo INTO @lv_count
            WHERE venum = @i_gs_hu-venum.
            IF lv_count EQ 0.
*      mark it for deletion
              lv_delete = abap_true.
            ENDIF.
          ELSE. " If child HU exists
            IF lt_child_hu IS NOT INITIAL.
              CLEAR lv_count.
              SELECT COUNT(*) FROM vepo INTO lv_count
              FOR ALL ENTRIES IN lt_child_hu
              WHERE venum = lt_child_hu-venum.
              IF lv_count EQ 0.
                lv_delete =  abap_true.
              ENDIF.
            ENDIF.

            IF lv_delete IS INITIAL.
              lv_msgno = lc_packed.
              lv_msgv1 = i_gs_hu-exidv.
            ENDIF.
          ENDIF.
        ELSE.
          lv_msgno = lc_markdel.
          lv_msgv1 = lv_vhart.
        ENDIF.
      ELSE.
        CLEAR lv_delete.
        lv_msgno = lc_deleted.
      ENDIF.
      CASE lv_delete.
        WHEN space. " Can not be deleted.
*--Show an error message if HU is already packed       .
          PERFORM error_message USING lc_msgid
                                      lv_msgno
                                      lv_msgv1.
        WHEN abap_true.
          PERFORM call_bapi_delete USING i_gs_hu-exidv
                                   CHANGING ls_return.

          CLEAR lv_number.
          lv_number = ls_return-number.
*     issuing message on success
          PERFORM error_message USING ls_return-id
                                      lv_number
                                      ls_return-message_v1.
          CLEAR : gv_barcode , gs_hu.
        WHEN OTHERS.
      ENDCASE.
    ELSEIF gv_unpack EQ abap_true.

      SELECT venum unvel
        INTO TABLE lt_vepo
        FROM vepo
        WHERE venum = i_gs_hu-venum.
      IF sy-subrc = 0.
        SELECT venum
         exidv
           INTO TABLE lt_lower_hu
           FROM   vekp
           FOR ALL ENTRIES IN lt_vepo
           WHERE venum = lt_vepo-unvel.
      ENDIF.
    ENDIF.
  ENDIF.
  IF lt_lower_hu IS NOT INITIAL.
    PERFORM unpack_hu TABLES lt_lower_hu
                      USING i_gs_hu-exidv .

  ELSE.
    lv_msgv1 = i_gs_hu-exidv.
    PERFORM error_message USING  lc_msgid lc_invalid_hu lv_msgv1.
  ENDIF.

ENDFORM.                    " DELETE_HU
*&---------------------------------------------------------------------*
*&      Form  CALL_BAPI_DELETE
*&---------------------------------------------------------------------*
*       delete HU
*----------------------------------------------------------------------*
FORM call_bapi_delete  USING   iv_exidv TYPE vekp-exidv
                       CHANGING cs_return TYPE bapiret2.

*delete the HU
  DATA :lv_exidv  TYPE vekp-exidv,
        lt_return TYPE STANDARD TABLE OF bapiret2.

  CONSTANTS: lc_success TYPE char1 VALUE 'S',
             lc_error   TYPE char1 VALUE 'E'.

  CLEAR lv_exidv.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = iv_exidv
    IMPORTING
      output = lv_exidv.

* Call BAPI to delete the HU
  CALL FUNCTION 'BAPI_HU_DELETE'
    EXPORTING
      hukey  = lv_exidv
    TABLES
      return = lt_return.


* Check for error or success - return the first message - which is displayed on the screen.
  LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<lfs_return>).
    CASE <lfs_return>-type.
      WHEN lc_success.
*        if it is success - commit the transaction
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.

        MOVE <lfs_return> TO cs_return.
        EXIT.
      WHEN lc_error.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        MOVE <lfs_return> TO cs_return.
        EXIT.
      WHEN OTHERS.
        MOVE <lfs_return> TO cs_return.
        EXIT.
    ENDCASE.
  ENDLOOP.

  CLEAR lt_return.

ENDFORM.                    " CALL_BAPI_DELETE
*&---------------------------------------------------------------------*
*&      Form  VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GS_HU  text
*----------------------------------------------------------------------*
FORM validation  CHANGING es_hu TYPE zcl_rfscanner_packunpack=>ts_phu.
  DATA : lv_msgv1 TYPE msgv1,
         lo_hu    TYPE REF TO zcl_rfscanner_packunpack,
         lv_fail  TYPE boolean,
         lv_msgid TYPE msgid,
         lv_msgno TYPE msgno.

  CONSTANTS: lc_msgid      TYPE  msgid VALUE 'ZLONE_HU',
             lc_invalid_hu TYPE msgno VALUE '001'.

  CREATE OBJECT lo_hu.

  PERFORM validate_nonhu CHANGING lv_fail es_hu. " ASAH
  " End of change by ASAH to allow child HUs to pass the parent validation 21.11.2019
  IF lv_fail IS NOT INITIAL.
*   The handling unit does not exist in VEKP. Issue an error
*   clear the global work area before issuing the error.,
    CLEAR: es_hu.
*   Issue the error message
*    pass the HU number as parameter
    lv_msgv1 = es_hu-exidv.
    PERFORM error_message USING  lc_msgid lc_invalid_hu lv_msgv1.

  ENDIF.
  " ASAH Begin of change for Unpack Pallete
  PERFORM check_unpack USING es_hu CHANGING gv_unpack.
  " ASAH End of change for Unpack Pallete

ENDFORM.                    " VALIDATION
*&---------------------------------------------------------------------*
*&      Form  MESSAGE_DISPLAY
*&---------------------------------------------------------------------*
*      Populate the message structure with appropriate messages
*----------------------------------------------------------------------*
FORM message_display  CHANGING cs_message TYPE ts_message.
  DATA : lv_msgid TYPE char20,
         lv_value TYPE char20,
         lv_num   TYPE char3,
         lo_hu    TYPE REF TO zcl_rfscanner_packunpack.

  CONSTANTS :   lc_msgid1 TYPE char8 VALUE 'ZLONE_HU',
                lc_msgno1 TYPE char6 VALUE 'MSG_NO',
                lc_msgv11 TYPE char5 VALUE 'MSGV1'.

  CLEAR : cs_message, lv_msgid, lv_value, lv_num.
*--Read Parametre message ID
  ##EXISTS
  GET PARAMETER ID lc_msgid1 FIELD lv_msgid.
  ##EXISTS
*--Read Parametre message ID
  GET PARAMETER ID lc_msgv11 FIELD lv_value.
  ##EXISTS
*--Read Parametre message ID
  GET PARAMETER ID lc_msgno1 FIELD lv_num.

  CREATE OBJECT lo_hu.
*--Populate error message details
  CALL METHOD lo_hu->message_display
    EXPORTING
      lv_id      = lv_msgid
      lv_value   = lv_value
      lv_no      = lv_num
    IMPORTING
      es_message = cs_message.

ENDFORM.                    " MESSAGE_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  VALIDATE_NONHU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_nonhu CHANGING ev_check TYPE boolean
                             cs_phu TYPE zcl_rfscanner_packunpack=>ts_phu.
*  METHOD validation_nonhu.

  DATA : ls_vekp             TYPE zcl_rfscanner_packunpack=>ts_vekp,
         ls_lein             TYPE zcl_rfscanner_packunpack=>ts_lein,
         ls_makt             TYPE zcl_rfscanner_packunpack=>ts_makt,
         lv_werks            TYPE werks_d,
         lv_lgort            TYPE lgort_d,
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
        input  = cs_phu-exidv
      IMPORTING
        output = cs_phu-exidv.

*--Fetch only Higher Level Handling Unit data from VEKP table and validate also
    SELECT venum exidv vhilm werks lgort lgnum UP TO 1 ROWS
           FROM vekp
           INTO ls_vekp
           WHERE exidv = cs_phu-exidv.
    ENDSELECT.
    IF sy-subrc = 0.
      cs_phu-venum = ls_vekp-venum.
      cs_phu-vhilm = ls_vekp-vhilm.
      cs_phu-lgnum = ls_vekp-lgnum.

*--Get lower level HU's VENUM for get Plant and Storage location values
      CALL FUNCTION 'HU_GET_ONE_HU_DB'
        EXPORTING
          if_hu_number        = ls_vekp-exidv
          if_all_levels       = abap_true
        IMPORTING
          ef_highest_level_hu = lv_highest_level_hu
          et_hu_header        = lt_header_detail
        EXCEPTIONS
          hu_not_found        = 1
          hu_locked           = 2
          fatal_error         = 3
          OTHERS              = 4.
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
*  ENDMETHOD.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_UNPACK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_unpack USING cs_phu TYPE zcl_rfscanner_packunpack=>ts_phu
                   CHANGING ev_unpack TYPE boolean.
  "Start of Change for unpack pallete "ASAH

  TYPES : BEGIN OF lty_werks,
            werks TYPE werks_d,
          END OF lty_werks.

  DATA : lit_werks      TYPE STANDARD TABLE OF lty_werks,
         lit_werks_all  TYPE STANDARD TABLE OF lty_werks,
         ls_param_werks TYPE zvv_param,
         lv_msgv1       TYPE msgv1,
         lv_msgno       TYPE msgno.

  " ASAH End of change for Unpack Pallete
  CONSTANTS :  lc_msgid          TYPE msgid VALUE 'ZLONE_HU',
               lc_warehouse      TYPE msgno VALUE '181',
               lc_lookup_name    TYPE zlookup_name VALUE 'ZUNPACK_HU',
               lc_free_key_werks TYPE zfree_key VALUE 'WERKS'.

  SELECT SINGLE * FROM zvv_param INTO ls_param_werks
                  WHERE lookup_name    = lc_lookup_name AND
                    vkorg          = space    AND
                    vtweg          = space     AND
                    spart          = space    AND
                    free_key       = lc_free_key_werks  AND
                    indicator1     = 'X'.
  IF sy-subrc = 0.
    REFRESH: lit_werks_all.
    IF NOT ls_param_werks-value1 IS INITIAL.
      REFRESH lit_werks.
      SPLIT ls_param_werks-value1 AT ',' INTO TABLE lit_werks.
      APPEND LINES OF lit_werks TO lit_werks_all.
    ENDIF.
    IF NOT ls_param_werks-value2 IS INITIAL.
      REFRESH lit_werks.
      SPLIT ls_param_werks-value2 AT ',' INTO TABLE lit_werks.
      APPEND LINES OF lit_werks TO lit_werks_all.
    ENDIF.
    IF NOT ls_param_werks-value3 IS INITIAL.
      REFRESH lit_werks.
      SPLIT ls_param_werks-value3 AT ',' INTO TABLE lit_werks.
      APPEND LINES OF lit_werks TO lit_werks_all.
    ENDIF.
  ENDIF.
  READ TABLE lit_werks_all WITH KEY werks = cs_phu-werks TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    ev_unpack = abap_true.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UNPACK_HU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM unpack_hu TABLES   p_lt_lower_hu TYPE tt_child_hu
               USING p_exidv TYPE exidv.
  DATA:   ls_header    TYPE bapihuheader,
          lv_headehu   TYPE exidv,
          lv_msgv1     TYPE msgv1,
          lv_flagset   TYPE char1,
          lv_exidv     TYPE exidv,
          ls_lhu       TYPE bapihuitmunpack,
          lt_return    TYPE TABLE OF bapiret2,
          lv_messageno TYPE msgnr.

  CONSTANTS : lc_itemtype TYPE velin VALUE '3',
              lc_s        TYPE char1 VALUE 'S',
              lc_flag     TYPE char1  VALUE 'X',
              lc_msgno6   TYPE msgno VALUE '006',
              lc_msgno54  TYPE msgno VALUE '054',
              lc_msgid    TYPE msgid  VALUE 'ZLONE_HU'.

  CLEAR :     lt_return,  lv_headehu.

  SORT p_lt_lower_hu BY exidv.
  "--Preparing Higher level HU
  IF p_exidv IS NOT INITIAL.
    lv_headehu = p_exidv.
  ENDIF.
*--Preparing Lower level HU's
  LOOP AT p_lt_lower_hu ASSIGNING FIELD-SYMBOL(<lfs_final>).
    ls_lhu-hu_item_type = lc_itemtype.
    ls_lhu-unpack_exid = <lfs_final>-exidv.

    "--UnPack Lower Level HU's from Higher Level pallet
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
*--Commit if successfully pack
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = lc_flag.
        CLEAR : lt_return, ls_header, lv_flagset.
      ELSE.
        lv_flagset = lc_flag.
      ENDIF.
    ELSE.
      IF lt_return IS INITIAL AND ls_header IS NOT INITIAL.
*--Commit if successfully pack
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = lc_flag.
        CLEAR : lt_return, ls_header, lv_flagset.
      ELSE.
        lv_flagset = lc_flag.
        lv_msgv1 = ls_header-hu_exid.
      ENDIF.
    ENDIF.
    CLEAR : ls_header.

  ENDLOOP.

  "--Check if flagset is not initial then show an error message
*--else show successful message with Higher HU number
  IF lv_flagset IS INITIAL.
    REFRESH : p_lt_lower_hu, lt_return.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = lv_headehu
      IMPORTING
        output = lv_exidv.
    lv_msgv1 =  lv_exidv.
*--Show an successful message once HU is Unpacked
    PERFORM error_message USING lc_msgid
                                lc_msgno6
                                lv_msgv1.
  ELSE.
*--flagset is not initial show an error message
*--Read error message of first index
    IF  lt_return[] IS NOT INITIAL.
      READ TABLE lt_return ASSIGNING <ls_log>
                                     INDEX 1.
      IF sy-subrc EQ 0.
        CLEAR : lv_messageno, lv_msgv1.
        lv_messageno = <ls_log>-number.

*--Show an error message if lt_return values
        PERFORM error_message USING <ls_log>-id
                                    lv_messageno
                                    lv_msgv1.
      ENDIF.
    ELSE.
*--Show an error message if HU is not valid
      PERFORM error_message USING lc_msgid
                                  lc_msgno54
                                  lv_msgv1.
    ENDIF.
  ENDIF.
  CLEAR : lv_flagset.
  REFRESH : p_lt_lower_hu, lt_return.

ENDFORM.
