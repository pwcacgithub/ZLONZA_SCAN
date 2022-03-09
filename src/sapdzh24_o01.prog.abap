*&---------------------------------------------------------------------*
*&  Include           SAPDZH24_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FRM_NEW_TRAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_new_tran .
  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CLEAR_DEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_del .
  CLEAR : zsits_scan_dynp-zzbarcode ,
          v_barcode ,
          ls_hu     .
*          wa_label  .

  REFRESH : it_hu , it_hu_link_obd.
*            it_label .

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  NEXT_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM next_screen .
*  CHECK v_flag IS INITIAL.   " No Errors
* Next Screen
  SET SCREEN 0200.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CLEAR_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_all .
  CLEAR: zsits_scan_dynp-zzoutb_delivery, zsits_scan_dynp-zzobd_item,
         v_barcode , lwa_lips,
          ls_hu.

  REFRESH : it_hu , it_hu_link_obd  .

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_OB_DEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  ERROR_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GC_MSGID  text
*      -->P_LV_MSGNO  text
*      -->P_LV_MSGV1  text
*----------------------------------------------------------------------*
FORM error_message  USING    p_gc_msgid TYPE msgid
                             p_lv_msgno TYPE syst_msgno  "msgno
                             p_gv_msgv1 TYPE msgv1
                             p_gv_msgv2 TYPE msgv2
  p_gv_msgv3 TYPE msgv3
  p_gv_msgv4 TYPE msgv4.
  DATA      : lv_prevno TYPE sy-dynnr.

  CONSTANTS : lc_msgno6  TYPE msgno VALUE '006',
              lc_initial TYPE char1 VALUE '0'.

*--Call error message screen with message
*--Set Message id
  SET PARAMETER ID text-016 FIELD p_gc_msgid.
*--Set Message No
  SET PARAMETER ID text-017 FIELD p_lv_msgno.
*--Set Message variable
  SET PARAMETER ID text-018 FIELD p_gv_msgv1.
  SET PARAMETER ID text-021 FIELD p_gv_msgv2.
  SET PARAMETER ID text-022 FIELD p_gv_msgv3.
  SET PARAMETER ID text-023 FIELD p_gv_msgv4.
*--Set Message for screen number call back
  CLEAR : lv_prevno.
  lv_prevno = sy-dynnr.
*--Change if successful message go back to initial screen/leave program
  IF p_lv_msgno = lc_msgno6.
    lv_prevno = lc_initial.
  ENDIF.
  SET PARAMETER ID text-020 FIELD lv_prevno.

*--Call Display message screen
  CALL SCREEN 300.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  READ_BARCODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_barcode .
  DATA: ls_label_content TYPE zsits_label_content.
  DATA:  ls_vekp_cust_upd   TYPE zl_vekp_cust_upd,
         return             TYPE bapiret2_t,
         ls_header          TYPE bapihuhdrproposal,
         ls_huheader        TYPE bapihuheader,
         lv_hukey           TYPE exidv,
         ls_vekp_cust_upd_x TYPE zls_vekp_cust_upd_x,
         return_n           TYPE bapiret2_t.

  CLEAR : ls_label_content ,gs_hu,gv_barcode1.
*--Read the HU number enter one is with Prefix or not
*--If not prefix of HU number then add Prefix with below code
*--Create Class Object for validation
  CHECK zsits_scan_dynp-zzbarcode IS NOT INITIAL.
  CREATE OBJECT go_hu.
  CALL METHOD go_hu->hubarcode_value
    EXPORTING
      iv_exidv    = zsits_scan_dynp-zzbarcode
    IMPORTING
      ev_hunumber = gv_barcode1.

*Read the barcode
  CALL METHOD zcl_mde_barcode=>disolve_barcode
    EXPORTING
      iv_barcode       = gv_barcode1
      iv_werks         = ' '
    IMPORTING
      es_label_content = ls_label_content.

  IF ls_label_content-zzhu_exid IS INITIAL.
    RETURN.
  ENDIF.
  gs_hu-exidv = ls_label_content-zzhu_exid . " External HU number

  CLEAR: lv_check, lv_msgno.
*--Create Class Object for validation
  CREATE OBJECT go_hu.

*--Validate the Physical Handling Unit is valid or not
  CALL METHOD go_hu->validation_nonhu
    IMPORTING
      ev_check = lv_check
    CHANGING
      cs_phu   = gs_hu.
*  *--Check variable is not empty then show an error message
  IF lv_check IS NOT INITIAL.
    CLEAR : lv_msgv1.
    lv_msgv1 = gs_hu-exidv.
    lv_msgno = gc_msgno1.
*--Show an error message
*    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1.

  ELSE.
    IF ls_label_content-hu_content-hu_header-higher_level_hu IS NOT INITIAL.  " Uevel is not initial it is CARTON HU
      ls_hu-hu = ls_label_content-zzhu_exid.
      ls_hu-label = 'C'. " Carton HU

*Begin of MM++
      SELECT vhilm
        UP TO 1 ROWS
        FROM vekp
        INTO @DATA(lv_vhilm)
        WHERE exidv = @ls_label_content-zzhu_exid.
      ENDSELECT.
**Create hu if Uevel is not initial for carton
      ls_header-pack_mat = lv_vhilm.
      CALL FUNCTION 'BAPI_HU_CREATE'
        EXPORTING
          headerproposal = ls_header
        IMPORTING
          huheader       = ls_huheader
          hukey          = lv_hukey
        TABLES
          return         = return.
      IF ls_huheader IS NOT INITIAL
          AND lv_hukey IS NOT INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        CLEAR return[].
        ls_hu-hu = lv_hukey.
* Update VEKP - ZZOLD_HU
        ls_vekp_cust_upd-venum = ls_huheader-hu_id.
        ls_vekp_cust_upd-exidv = lv_hukey.

        ls_vekp_cust_upd_x-venum = ls_huheader-hu_id.
        ls_vekp_cust_upd_x-exidv = lv_hukey.

        ls_vekp_cust_upd-zzold_hu = zsits_scan_dynp-zzbarcode.
        ls_vekp_cust_upd_x-zzold_hu = abap_true.

        CALL FUNCTION 'ZL_VEKP_CUST_UPD'
          EXPORTING
            is_vekp_cust_upd   = ls_vekp_cust_upd
            is_vekp_cust_upd_x = ls_vekp_cust_upd_x
          IMPORTING
            et_return          = return_n
          EXCEPTIONS
            invalid_hu         = 1
            invalid_qa         = 2
            invalid_reason     = 3
            invalid_temp       = 4
            invalid_picktxt    = 5
            hu_missing         = 6
            lock_error         = 7
            update_error       = 8
            OTHERS             = 9.
        IF sy-subrc <> 0.
        ENDIF.
      ENDIF.
*End of MM++

      APPEND ls_hu TO it_hu.
      APPEND ls_hu TO it_hu_link_obd.

      CLEAR : zsits_scan_dynp-zzbarcode , ls_hu.
    ELSE.  " It is a pallete HU
      gs_label_content = ls_label_content.
      CLEAR zsits_scan_dynp-zzbarcode.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_HU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_hu . "Add contents of Pallete HU to the screen table
  CHECK lv_check IS INITIAL.
  READ TABLE it_hu INTO ls_hu WITH KEY p_hu = gs_hu-exidv.
  IF sy-subrc EQ 0.
    " HU already added
  ELSE.
    ls_hu-hu = gs_label_content-zzhu_exid.
    ls_hu-label = 'P'. " Pallete HU
    APPEND ls_hu TO it_hu_link_obd.
    APPEND ls_hu TO it_hu.
    CLEAR : ls_hu.
*    IF zsits_scan_dynp-zzsu IS NOT INITIAL.
    IF gs_label_content-hu_content-hu_content[] IS NOT INITIAL.
*      wa_su = zsits_scan_dynp-zzsu.
      LOOP AT gs_label_content-hu_content-hu_content[] INTO DATA(wa_hu_content).
        ls_hu-hu = wa_hu_content-lower_level_exid.
        ls_hu-p_hu = gs_label_content-zzhu_exid.
        ls_hu-label = 'P'. " Pallete HU

*        wa_su = wa_label-su_content-su_header-lenum.
        APPEND ls_hu TO it_hu.

        CLEAR : ls_hu.

      ENDLOOP.
      CLEAR : gs_label_content.
    ELSE.

    ENDIF.
  ENDIF.
  CLEAR : gs_label_content, ls_hu.
  DELETE it_hu[] WHERE hu IS INITIAL.
ENDFORM.

FORM link_hu_to_obd.
*  USING lt_hu TYPE STANDARD TABLE OF lty_hu
*            CHANGING lv_flg_error TYPE flag
*              lv_message TYPE char255.

  DATA: lt_handling_units TYPE TABLE OF hum_rehang_hu,
        ls_handling_units TYPE hum_rehang_hu,
        ls_vbkok_wa       TYPE vbkok,
        lt_verko          TYPE STANDARD TABLE OF verko,
        ls_verko          TYPE verko,
        lt_verpo          TYPE STANDARD TABLE OF verpo,
        ls_verpo          TYPE verpo,
        lv_error_any      TYPE xfeld,
        lt_prot           TYPE TABLE OF prott.

  ls_vbkok_wa-vbeln = zsits_scan_dynp-zzoutb_delivery.
*  ls_vbkok_wa-packing_final = 'X'.
*  ls_vbkok_wa-vbeln_vl = zsits_scan_dynp-zzoutb_delivery.

*Link only Pallet & loose cartons
  SORT lt_scan_det BY vbeln posnr matnr counter hu_type.

*  LOOP AT lt_scan_det ASSIGNING FIELD-SYMBOL(<lfs_hu>).
***    ls_verko-exidv = <lfs_hu>-hu.
***    APPEND ls_verko TO lt_verko.
***    CLEAR ls_verko.
*
***    ls_verpo-exidv    = <lfs_hu>-hu .
***    ls_verpo-velin    = '1' .
***    ls_verpo-vbeln    = zsits_scan_dynp-zzoutb_delivery .
****               lst_verpo-tmeng    = material quantity to be packed.
****               lst_verpo-matnr    = material no.
****               lst_verpo-werks    = plant.
****               lst_verpo-lgort    = storage location.
***    APPEND ls_verpo TO lt_verpo.
***    CLEAR ls_verpo.
*    IF <lfs_hu>-hu_type = 'PALLET'.
*      ls_handling_units-top_hu_external = <lfs_hu>-hu_no.
*    ENDIF.
**    ls_handling_units-top_hu_external = <lfs_hu>-hu_no.
*    AT END OF counter.
*      IF ls_handling_units-top_hu_external IS INITIAL.
*        ls_handling_units-top_hu_external = <lfs_hu>-hu_no.
*      ENDIF.
*      APPEND ls_handling_units TO lt_handling_units.
*      CLEAR ls_handling_units.
*    ENDAT.
*  ENDLOOP.

  LOOP AT lt_scan_det ASSIGNING FIELD-SYMBOL(<lfs_hu>) WHERE hu_type = 'CARTON'.

    ls_handling_units-top_hu_external = <lfs_hu>-hu_no.
    APPEND ls_handling_units TO lt_handling_units.
    CLEAR ls_handling_units.

  ENDLOOP.

  CALL FUNCTION 'WS_DELIVERY_UPDATE'
    EXPORTING
      vbkok_wa                 = ls_vbkok_wa
      synchron                 = abap_true
*     NO_MESSAGES_UPDATE       = 'X' "ASAH
      commit                   = abap_true
      delivery                 = zsits_scan_dynp-zzoutb_delivery
*     UPDATE_PICKING           = ' '
      nicht_sperren            = abap_true
*     IF_CONFIRM_CENTRAL       = ' '
*     IF_WMPP                  = ' '
*     IF_GET_DELIVERY_BUFFERED = ABAP_TRUE
*     IF_NO_GENERIC_SYSTEM_SERVICE       = ABAP_TRUE
      if_database_update       = '1'
*     IF_NO_INIT               = ' '
*     IF_NO_READ               = ' '
      if_error_messages_send_0 = 'X'
*     IF_NO_BUFFER_REFRESH     = ' '
*     IT_PARTNER_UPDATE        =
*     IT_SERNR_UPDATE          =
*     IF_NO_REMOTE_CHG         = ' '
*     IF_NO_MES_UPD_PACK       = ' '
*     IF_LATE_DELIVERY_UPD     = ' '
    IMPORTING
      ef_error_any_0           = lv_error_any
*     ef_error_in_item_deletion_0 = lv_error_itm_del
*     ef_error_in_pod_update_0 = lv_error_pod_upd
*     ef_error_in_interface_0  = lv_error_interfc
*     ef_error_in_goods_issue_0   = lv_error_gi
*     ef_error_in_final_check_0   = lv_error_final_chk
*     ef_error_partner_update  = lv_partner_upd
*     ef_error_sernr_update    = lv_error_sernr_upd
    TABLES
*     VBPOK_TAB                =
      prot                     = lt_prot
      verko_tab                = lt_verko
      verpo_tab                = lt_verpo
*     VBSUPCON_TAB             =
*     IT_VERPO_SERNR           =
*     IT_PACKING               =
*     IT_PACKING_SERNR         =
*     IT_REPACK                =
      it_handling_units        = lt_handling_units
*     IT_OBJECTS               =
*     ET_CREATED_HUS           =
*     TVPOD_TAB                =
*     IT_TMSTMP                =
*     IT_BAPIADDR1             =
*     IT_TEXTL                 =
*     IT_TEXTH                 =
*     IT_AAC_ITEM_BLOCK        =
*     IT_HU_HEADER_EPC         =
*     IT_HU_ITEMS_EPC          =
    EXCEPTIONS
      error_message            = 1.

  IF sy-subrc = 1 OR lv_error_any IS NOT INITIAL .
    lv_msgno = '190'.
*  ENDIF.
    PERFORM error_message USING sy-msgid sy-msgno sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ELSEIF lv_error_any IS NOT INITIAL.

*    lv_message = 'HU has not been linked to OBD'.
*    lv_msgno = '190'.
  ELSE.
*    lv_message = 'HU Successfully linked to OBD'.
*    lv_msgno = '189'.
*    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
  ENDIF.
*  PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_CONSTANTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_constants .
  SELECT * FROM zvv_param INTO TABLE lt_param
                WHERE ( lookup_name    = gc_lookup_name ) AND
                  vkorg          = space    AND
                  vtweg          = space     AND
                  spart          = space    AND
                  free_key     = gc_ob_type AND
                  indicator1     = 'X'.
  IF sy-subrc = 0.
    LOOP AT lt_param INTO ls_param .
      IF ls_param-lookup_name = gc_lookup_name.
        CASE ls_param-free_key.
          WHEN gc_ob_type.
            REFRESH: lit_lfart_all.
            IF NOT ls_param-value1 IS INITIAL.
              REFRESH lit_lfart.
              SPLIT ls_param-value1 AT ',' INTO TABLE lit_lfart.
              APPEND LINES OF lit_lfart TO lit_lfart_all.
            ENDIF.
            IF NOT ls_param-value2 IS INITIAL.
              REFRESH lit_lfart.
              SPLIT ls_param-value2 AT ',' INTO TABLE lit_lfart.
              APPEND LINES OF lit_lfart TO lit_lfart_all.
            ENDIF.
            IF NOT ls_param-value3 IS INITIAL.
              REFRESH lit_lfart.
              SPLIT ls_param-value3 AT ',' INTO TABLE lit_lfart.
              APPEND LINES OF lit_lfart TO lit_lfart_all.
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    LOOP AT lit_lfart_all INTO ls_lfart.
      ls_lfart_r-option = 'EQ'.
      ls_lfart_r-sign = 'I'.
      ls_lfart_r-low = ls_lfart-lfart.
      APPEND ls_lfart_r TO lit_lfart_r.
      CLEAR : ls_lfart_r , ls_lfart.
    ENDLOOP.

  ENDIF.

ENDFORM.

FORM get_pallet .
  TYPES: BEGIN OF ty_vekp,
           exidv TYPE exidv,
         END OF ty_vekp.
  DATA: lwa_scan_det TYPE zlscan_detail.
  DATA: lv_barcode_string TYPE string.
  DATA:  ls_vekp_cust_upd   TYPE zl_vekp_cust_upd,
         return             TYPE bapiret2_t,
         lv_mod             TYPE i,
         ls_header          TYPE bapihuhdrproposal,
         ls_huheader        TYPE bapihuheader,
         lv_qty(14)         TYPE c,
         lv_exidv           TYPE exidv,
         lt_vekp            TYPE TABLE OF ty_vekp,
         lw_vekp            TYPE ty_vekp,
         lv_venum1          TYPE venum,
         lv_flag            TYPE flag,
         lv_hukey           TYPE exidv,
         lv_pallet          TYPE exidv,
         ls_vekp_cust_upd_x TYPE zls_vekp_cust_upd_x,
         return_n           TYPE bapiret2_t.

  DATA: v_label_type     TYPE zdits_label_type,
        ls_label_content TYPE zsits_label_content,
        lt_return        TYPE ztits_barcode_return.

  DATA: lt_husstat TYPE husstat_t,
        lv_objnr   TYPE j_objnr.

* Start of Insert by EICR 603155 Gelatin Scan sghosh1
  CONSTANTS: lc_c(1)      TYPE c VALUE 'C',
             lc_p(1)      TYPE c VALUE 'P',
             lc_525(3)    TYPE c VALUE '525',
             lc_526(3)    TYPE c VALUE '526',
             lc_527(3)    TYPE c VALUE '527',
             lc_528(3)    TYPE c VALUE '528',
             lc_pallet(6) TYPE c VALUE 'PALLET',
             lc_carton(6) TYPE c VALUE 'CARTON'.
* End of Insert   by EICR 603155 Gelatin Scan sghosh1
  IF zsits_scan_dynp-zzbarcode IS NOT INITIAL.
    CLEAR: it_hu[], lw_hu, ls_label_content.

* Start of Insert by EICR 603155 Gelatin Scan sghosh1
    gv_flg_pallet = abap_true.
    IF gv_gelatin EQ gv_tcode.
      lv_flag = abap_false.
      lv_barcode_string = zsits_scan_dynp-zzbarcode.
      CALL METHOD zcl_its_utility=>read_barcode_gelatin
        EXPORTING
          barcode          = lv_barcode_string
          pallet           = gv_flg_pallet
        IMPORTING
          it_hu            = lt_hu1
          o_label_content  = ls_label_content
          type             = lv_type
        EXCEPTIONS
          illegal_bar_code = 1.

      IF sy-subrc EQ gc_0.
        gv_palqty = ls_label_content-zzquantity.
        lv_lfimg = lv_lfimg + gv_palqty.
        CONDENSE lv_lfimg.
        gv_pal = ls_label_content-zzhu_exid.

        LOOP AT lt_hu1 INTO DATA(lw_hu1).
          lw_vekp-exidv = lw_hu1-hu.
          APPEND lw_vekp TO lt_vekp[].
        ENDLOOP.
        SELECT venum,
               exidv
               INTO TABLE @DATA(lt_venum) FROM vekp
               FOR ALL ENTRIES IN @lt_vekp
               WHERE exidv = @lt_vekp-exidv.
        CLEAR: lw_hu1.

        LOOP AT lt_hu1 INTO lw_hu1.
          CLEAR: lv_exidv, lv_venum1.
          lv_exidv = lw_hu1-hu.
          READ TABLE lt_venum INTO DATA(lw_venum) WITH KEY exidv = lv_exidv.
          IF sy-subrc = gc_0 AND lw_venum-venum IS NOT INITIAL.
            lv_flag = abap_true.
            IF lw_hu1-typ = lc_c.
              lv_msgno = lc_525.
            ELSEIF lw_hu1-typ = lc_p.
              lv_msgno = lc_526.
            ENDIF.
            lv_msgv1 = lv_exidv.
            CLEAR: zsits_scan_dynp-zzbarcode.
            PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
            EXIT.
          ELSE.
            SELECT SINGLE hu_no FROM zlscan_detail INTO @DATA(lv_exidv1) WHERE hu_no = @lv_exidv.
            IF sy-subrc EQ gc_0.
              lv_flag = abap_true.
              lv_msgno = lc_528.
              lv_msgv1 = lv_exidv.
              CLEAR: zsits_scan_dynp-zzbarcode.
              PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
            ELSE.
              READ TABLE lt_hu INTO lw_hu WITH KEY hu = lw_hu1-hu TRANSPORTING NO FIELDS.
              IF sy-subrc EQ gc_0.
                lv_flag = abap_true.
                lv_msgno = lc_527.
                lv_msgv1 = lw_hu1-hu.
                CLEAR: zsits_scan_dynp-zzbarcode.
                PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF lv_flag EQ abap_false.
          LOOP AT lt_hu1 INTO lw_hu1.
            READ TABLE lt_hu INTO lw_hu WITH KEY hu = lw_hu1-hu.
            IF sy-subrc <> gc_0.
              APPEND lw_hu1 TO lt_hu[].
            ELSE.
            ENDIF.
          ENDLOOP.

          IF lv_count IS INITIAL.
            lv_count = 1.
          ELSE.
            lv_count = lv_count + 1.
          ENDIF.
          READ TABLE lt_scan_det[] INTO DATA(lw_scan) WITH KEY hu_no = gv_pal TRANSPORTING NO FIELDS.
          IF sy-subrc <> gc_0.
            lwa_scan_det-applc = 'GELATIN'.
            lwa_scan_det-vbeln = zsits_scan_dynp-zzoutb_delivery.
            lwa_scan_det-posnr = zsits_scan_dynp-zzobd_item.
            lwa_scan_det-matnr = lwa_lips-matnr.
            lwa_scan_det-counter = lv_count.
            lwa_scan_det-hu_type = lc_pallet.
            lwa_scan_det-hu_no = gv_pal.
            READ TABLE lt_hu1 INTO lw_hu1 WITH KEY hu = gv_pal.
            IF sy-subrc EQ gc_0.
              lwa_scan_det-batch = lw_hu1-batch.
            ENDIF.
            APPEND lwa_scan_det TO lt_scan_det.
          ELSE.
          ENDIF.

          IF lt_hu1 IS NOT INITIAL.
            LOOP AT lt_hu1 INTO lw_hu1 WHERE typ = lc_c.
              READ TABLE lt_scan_det[] INTO lw_scan WITH KEY hu_no = lw_hu1-hu TRANSPORTING NO FIELDS.
              IF sy-subrc <> gc_0.
                lwa_scan_det-applc = 'GELATIN'.
                lwa_scan_det-hu_type = lc_carton.
                lwa_scan_det-hu_no = lw_hu1-hu.
                lwa_scan_det-lfimg = lw_hu1-qty.
                APPEND lwa_scan_det TO lt_scan_det.
              ELSE.
              ENDIF.
            ENDLOOP.
          ENDIF.

          CLEAR: lwa_scan_det, lv_pallet, lv_hukey.
          SET CURSOR FIELD ' '.
          SET SCREEN 0500.
        ENDIF.
      ELSE.
        CLEAR: zsits_scan_dynp-zzbarcode.
        lv_msgno = sy-msgno.
        lv_msgv1 = lv_barcode_string.
        CONDENSE lv_msgv1.
        PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
      ENDIF.
* End of Insert   by EICR 603155 Gelatin Scan sghosh1
    ELSE.
      lv_barcode_string = zsits_scan_dynp-zzbarcode.
      CALL METHOD zcl_its_utility=>bar_code_translation_dfs
        EXPORTING
          i_bar_code_string = lv_barcode_string
          i_appid_type      = 'GS1'
*         i_su_label        = abap_true
*         iv_appid_type     =
        IMPORTING
          o_return          = lt_return
          o_label_type      = v_label_type
          o_label_content   = ls_label_content
        EXCEPTIONS
          illegal_bar_code  = 1
          conversion_error  = 2
          system_error      = 3
          numeric_error     = 4
          OTHERS            = 5.
      IF sy-subrc = 0.
        lv_pallet = ls_label_content-zzhu_exid.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_pallet
          IMPORTING
            output = lv_pallet.

        SELECT venum , status
          UP TO 1 ROWS
          FROM vekp
          INTO ( @DATA(lv_venum) , @DATA(lv_status) )
          WHERE exidv = @lv_pallet.
        ENDSELECT.
        IF sy-subrc <> 0.
          CLEAR: zsits_scan_dynp-zzbarcode.
          lv_msgno = '219'.
          PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
        ELSE.

          "*****************************
**          CONCATENATE 'HU' lv_venum INTO lv_objnr.
**          SELECT * FROM husstat
**            INTO TABLE @lt_husstat
**            WHERE objnr = @lv_objnr.
**          IF sy-subrc = 0
**            AND lt_husstat IS NOT INITIAL.
**            "Begin of BLOB New CR 03.08.2020
**
**            PERFORM status_to_phex USING  lv_objnr
**                                          lv_venum
**                                          lv_pallet
**                                          lv_status
**                                  CHANGING lt_husstat.
**            CLEAR: lt_husstat.
**
**          ENDIF.
          "*****************************
        ENDIF.
      ELSE.
        lv_msgno = '219'.
        PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.

      ENDIF.

      IF lv_count IS INITIAL.
        lv_count = 1.
      ELSE.
        lv_count = lv_count + 1.
      ENDIF.


*    SELECT SINGLE pack_matnr
*      INTO @DATA(lv_pack_mat)
*      FROM zlpack_mat
*      WHERE werks = @lwa_lips-werks
*      AND mtart = @lwa_lips-mtart
*      AND hu_id = '2'.

*    SELECT
*      exidv
*      UP TO 1 ROWS
*      FROM vekp
*      INTO @DATA(lv_exidv)
*      WHERE zzold_hu = @zsits_scan_dynp-zzbarcode.
*    ENDSELECT.

*    IF sy-subrc <> 0.
*  **Create hu
*      ls_header-pack_mat = lv_pack_mat.
*      ls_header-hu_status_init = 'B'.
*
*      CALL FUNCTION 'BAPI_HU_CREATE'
*        EXPORTING
*          headerproposal = ls_header
*        IMPORTING
*          huheader       = ls_huheader
*          hukey          = lv_hukey
*        TABLES
*          return         = return.
*      IF ls_huheader IS NOT INITIAL
*          AND lv_hukey IS NOT INITIAL.
*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*        CLEAR return[].
*
** Update VEKP - ZZOLD_HU
*        ls_vekp_cust_upd-venum = ls_huheader-hu_id.
*        ls_vekp_cust_upd-exidv = lv_hukey.
*
*        ls_vekp_cust_upd_x-venum = ls_huheader-hu_id.
*        ls_vekp_cust_upd_x-exidv = lv_hukey.
*
*
*        ls_vekp_cust_upd-zzold_hu = zsits_scan_dynp-zzbarcode.
*        ls_vekp_cust_upd_x-zzold_hu = abap_true.
*
*        CALL FUNCTION 'ZL_VEKP_CUST_UPD'
*          EXPORTING
*            is_vekp_cust_upd   = ls_vekp_cust_upd
*            is_vekp_cust_upd_x = ls_vekp_cust_upd_x
*          IMPORTING
*            et_return          = return_n
*          EXCEPTIONS
*            invalid_hu         = 1
*            invalid_qa         = 2
*            invalid_reason     = 3
*            invalid_temp       = 4
*            invalid_picktxt    = 5
*            hu_missing         = 6
*            lock_error         = 7
*            update_error       = 8
*            OTHERS             = 9.
*        IF sy-subrc <> 0.
*        ENDIF.
*      ENDIF.
*    ELSE.
*      lv_hukey = lv_exidv.
*    ENDIF.

      lwa_scan_det-vbeln = zsits_scan_dynp-zzoutb_delivery.
      lwa_scan_det-posnr = zsits_scan_dynp-zzobd_item.
      lwa_scan_det-matnr = lwa_lips-matnr.
      lwa_scan_det-counter = lv_count.
      lwa_scan_det-hu_type = 'PALLET'.
      lwa_scan_det-hu_no = lv_pallet.
*    lwa_scan_det-lfimg = lwa_lips-lfimg.
      lwa_scan_det-zzold_hu = zsits_scan_dynp-zzbarcode.
      APPEND lwa_scan_det TO lt_scan_det.
      CLEAR: lwa_scan_det, lv_pallet, lv_hukey.
*    lv_exidv,
*     return_n,
*    ls_vekp_cust_upd, ls_vekp_cust_upd_x , ls_huheader,
**    lv_pack_mat,
*     return.
*  INSERT zlscan_detail FROM lwa_scan_det.
*
*  IF sy-subrc = 0.
*    COMMIT WORK.
*  ENDIF.
      SET CURSOR FIELD ' '.
      SET SCREEN 0500.
    ENDIF.
  ELSE.

    lv_msgno = '218'.
    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.

  ENDIF.

ENDFORM.
FORM get_carton.

  IF lv_indx IS INITIAL.
    lv_indx = 1.
  ENDIF.

  SELECT SINGLE umrez
    FROM marm
    INTO @DATA(lv_umrez)
    WHERE matnr = @lwa_lips-matnr
    AND meinh = 'KAR'.

  CLEAR lv_lfimg.

  LOOP AT lt_cart ASSIGNING FIELD-SYMBOL(<lfs_cart>).
    lv_lfimg = lv_lfimg + <lfs_cart>-lfimg .
  ENDLOOP.
  DATA(lv_remain_qty) = lwa_lips-lfimg - lv_lfimg.
  CLEAR lv_lfimg.

  IF gv_cart1 IS NOT INITIAL.

    READ TABLE lt_cart_all ASSIGNING FIELD-SYMBOL(<lfs_cart_all>)
    WITH KEY barcode = gv_cart1.
    IF sy-subrc = 0.

      IF gv_cart1_qty IS INITIAL.

        IF <lfs_cart_all>-lfimg IS NOT INITIAL.
          gv_cart1_qty = <lfs_cart_all>-lfimg.
        ELSE.
          IF gv_gelatin NE gv_tcode.
            IF lv_umrez GT lv_remain_qty.
              gv_cart1_qty = lv_remain_qty.
            ELSE.
              gv_cart1_qty = lv_umrez.
            ENDIF.
          ENDIF.
        ENDIF.

      ELSE.

        IF <lfs_cart_all>-lfimg IS NOT INITIAL.

          IF gv_cart1_qty <> <lfs_cart_all>-lfimg.

            gv_cart1_qty = <lfs_cart_all>-lfimg.
            lv_msgno = '222'.
*            SET CURSOR FIELD ''.
            lv_cursor = ''.
            lv_msgv1 = gv_cart1.
            PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.

          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.
*        **********************
* Start of Insert by EICR 603155 Gelatin Scan sghosh1
    IF gv_gelatin EQ gv_tcode.
      IF gv_cart1_barcode IS NOT INITIAL.
        READ TABLE lt_cart ASSIGNING <lfs_cart> WITH KEY zzbarcode = gv_cart1_barcode.
        IF sy-subrc <> gc_0.
          lwa_final-zzbarcode = gv_cart1_barcode.
          lwa_final-lfimg = gv_cart1_qty.

          IF gv_flg_pallet = abap_false.
            lv_count = lv_count + 1.
          ENDIF.
          lwa_final-count = lv_count.
          APPEND lwa_final TO lt_cart.
          CLEAR lwa_final.
        ELSE.
          <lfs_cart>-lfimg = gv_cart1_qty.
        ENDIF.
      ENDIF.
    ELSE.
* End of Insert   by EICR 603155 Gelatin Scan sghosh1
      READ TABLE lt_cart ASSIGNING <lfs_cart> WITH KEY zzbarcode = gv_cart1.
      IF sy-subrc <> 0.
        lwa_final-zzbarcode = gv_cart1 .
        lwa_final-lfimg = gv_cart1_qty.

        IF gv_flg_pallet = abap_false.
          lv_count = lv_count + 1.
        ENDIF.
        lwa_final-count = lv_count.
        APPEND lwa_final TO lt_cart.
        CLEAR lwa_final.
      ELSE.
        <lfs_cart>-lfimg = gv_cart1_qty.
      ENDIF.
    ENDIF.
*        ***************************
*      ENDIF.

    CONDENSE gv_cart1_qty.
  ENDIF.

*for cart2
  IF gv_cart2 IS NOT INITIAL.

    READ TABLE lt_cart_all ASSIGNING <lfs_cart_all>
    WITH KEY barcode = gv_cart2.
    IF sy-subrc = 0.

      IF gv_cart2_qty IS INITIAL.

        IF <lfs_cart_all>-lfimg IS NOT INITIAL.
          gv_cart2_qty = <lfs_cart_all>-lfimg.
        ELSE.
          IF gv_gelatin NE gv_tcode.
            IF lv_umrez GT lv_remain_qty.
              gv_cart2_qty = lv_remain_qty.
            ELSE.
              gv_cart2_qty = lv_umrez.
            ENDIF.
          ENDIF.
        ENDIF.

      ELSE.

        IF <lfs_cart_all>-lfimg IS NOT INITIAL.

          IF gv_cart2_qty <> <lfs_cart_all>-lfimg.
            gv_cart2_qty = <lfs_cart_all>-lfimg.
            lv_msgno = '222'.
*            SET CURSOR FIELD 'GV_CART1'.
            lv_cursor = 'GV_CART1'.
            lv_msgv1 = gv_cart2.
            PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.

          ENDIF.

        ENDIF.
      ENDIF.
* *        **********************
* Start of Insert by EICR 603155 Gelatin Scan sghosh1
      IF gv_gelatin EQ gv_tcode.
        IF gv_cart2_barcode IS NOT INITIAL.
          READ TABLE lt_cart ASSIGNING <lfs_cart> WITH KEY zzbarcode = gv_cart2_barcode.
          IF sy-subrc <> gc_0.
            lwa_final-zzbarcode = gv_cart2_barcode .
            lwa_final-lfimg = gv_cart2_qty.

            IF gv_flg_pallet = abap_false.
              lv_count = lv_count + 1.
            ENDIF.
            lwa_final-count = lv_count.
            APPEND lwa_final TO lt_cart.
            CLEAR lwa_final.
          ELSE.
            <lfs_cart>-lfimg = gv_cart1_qty.
          ENDIF.
        ENDIF.
* End of Insert   by EICR 603155 Gelatin Scan sghosh1
      ELSE.
        READ TABLE lt_cart ASSIGNING <lfs_cart> WITH KEY zzbarcode = gv_cart2.
        IF sy-subrc <> 0.
          lwa_final-zzbarcode = gv_cart2 .
          lwa_final-lfimg = gv_cart2_qty.

          IF gv_flg_pallet = abap_false.
            lv_count = lv_count + 1.
          ENDIF.
          lwa_final-count = lv_count.
          APPEND lwa_final TO lt_cart.
          CLEAR lwa_final.
        ELSE.
          <lfs_cart>-lfimg = gv_cart2_qty.
        ENDIF.
      ENDIF.
*        ***************************
*      ENDIF.
    ENDIF.

    CONDENSE gv_cart2_qty.
  ENDIF.

*  For Cart3
  IF gv_cart3 IS NOT INITIAL.

    READ TABLE lt_cart_all ASSIGNING <lfs_cart_all>
    WITH KEY barcode = gv_cart3.
    IF sy-subrc = 0.

      IF gv_cart3_qty IS INITIAL.

        IF <lfs_cart_all>-lfimg IS NOT INITIAL.
          gv_cart3_qty = <lfs_cart_all>-lfimg.
        ELSE.
          IF gv_gelatin NE gv_tcode.
            IF lv_umrez GT lv_remain_qty.
              gv_cart3_qty = lv_remain_qty.
            ELSE.
              gv_cart3_qty = lv_umrez.
            ENDIF.
          ENDIF.
        ENDIF.

      ELSE.

        IF <lfs_cart_all>-lfimg IS NOT INITIAL.

          IF gv_cart3_qty <> <lfs_cart_all>-lfimg.

            gv_cart3_qty = <lfs_cart_all>-lfimg.
            lv_msgno = '222'.
*            SET CURSOR FIELD 'GV_CART2'.
            lv_cursor = 'GV_CART2'.
            lv_msgv1 = gv_cart3.
            PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.

          ENDIF.

        ENDIF.
      ENDIF.
*        **********************
* Start of Insert by EICR 603155 Gelatin Scan sghosh1
      IF gv_gelatin EQ gv_tcode.
        IF gv_cart3_barcode IS NOT INITIAL.
          READ TABLE lt_cart ASSIGNING <lfs_cart> WITH KEY zzbarcode = gv_cart3_barcode.
          IF sy-subrc <> gc_0.
            lwa_final-zzbarcode = gv_cart3_barcode.
            lwa_final-lfimg = gv_cart3_qty.

            IF gv_flg_pallet = abap_false.
              lv_count = lv_count + 1.
            ENDIF.
            lwa_final-count = lv_count.
            APPEND lwa_final TO lt_cart.
            CLEAR lwa_final.
          ELSE.
            <lfs_cart>-lfimg = gv_cart1_qty.
          ENDIF.
        ENDIF.
* End of Insert   by EICR 603155 Gelatin Scan sghosh1
      ELSE.
        READ TABLE lt_cart ASSIGNING <lfs_cart> WITH KEY zzbarcode = gv_cart3.
        IF sy-subrc <> 0.
          lwa_final-zzbarcode = gv_cart3 .
          lwa_final-lfimg = gv_cart3_qty.

          IF gv_flg_pallet = abap_false.
            lv_count = lv_count + 1.
          ENDIF.
          lwa_final-count = lv_count.
          APPEND lwa_final TO lt_cart.
          CLEAR lwa_final.
        ELSE.
          <lfs_cart>-lfimg = gv_cart3_qty.
        ENDIF.
      ENDIF.
*        ***************************
*      ENDIF.
    ENDIF.

    CONDENSE gv_cart3_qty.
  ENDIF.
*  For cart4
  IF gv_cart4 IS NOT INITIAL.

    READ TABLE lt_cart_all ASSIGNING <lfs_cart_all>
    WITH KEY barcode = gv_cart4.
    IF sy-subrc = 0.

      IF gv_cart4_qty IS INITIAL.

        IF <lfs_cart_all>-lfimg IS NOT INITIAL.
          gv_cart4_qty = <lfs_cart_all>-lfimg.
        ELSE.
          IF gv_gelatin NE gv_tcode.
            IF lv_umrez GT lv_remain_qty.
              gv_cart4_qty = lv_remain_qty.
            ELSE.
              gv_cart4_qty = lv_umrez.
            ENDIF.
          ENDIF.
        ENDIF.

      ELSE.

        IF <lfs_cart_all>-lfimg IS NOT INITIAL.

          IF gv_cart4_qty <> <lfs_cart_all>-lfimg.

            gv_cart4_qty = <lfs_cart_all>-lfimg.
            lv_msgno = '222'.
*            SET CURSOR FIELD 'GV_CART3'.
            lv_cursor = 'GV_CART3'.
            lv_msgv1 = gv_cart4.
            PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.

          ENDIF.

        ENDIF.
      ENDIF.
*        **********************
* Start of Insert by EICR 603155 Gelatin Scan sghosh1
      IF gv_gelatin EQ gv_tcode.
        IF gv_cart4_barcode IS NOT INITIAL.
          READ TABLE lt_cart ASSIGNING <lfs_cart> WITH KEY zzbarcode = gv_cart4_barcode.
          IF sy-subrc <> gc_0.
            lwa_final-zzbarcode = gv_cart4_barcode.
            lwa_final-lfimg = gv_cart4_qty.

            IF gv_flg_pallet = abap_false.
              lv_count = lv_count + 1.
            ENDIF.
            lwa_final-count = lv_count.
            APPEND lwa_final TO lt_cart.
            CLEAR lwa_final.
          ELSE.
            <lfs_cart>-lfimg = gv_cart1_qty.
          ENDIF.
        ENDIF.
* End of Insert by EICR 603155 Gelatin Scan sghosh1
      ELSE.
        READ TABLE lt_cart ASSIGNING <lfs_cart> WITH KEY zzbarcode = gv_cart4.
        IF sy-subrc <> 0.
          lwa_final-zzbarcode = gv_cart4 .
          lwa_final-lfimg = gv_cart4_qty.

          IF gv_flg_pallet = abap_false.
            lv_count = lv_count + 1.
          ENDIF.
          lwa_final-count = lv_count.
          APPEND lwa_final TO lt_cart.
          CLEAR lwa_final.
        ELSE.
          <lfs_cart>-lfimg = gv_cart4_qty.
        ENDIF.
      ENDIF.
*        ***************************
*      ENDIF.
    ENDIF.

    CONDENSE gv_cart4_qty.
  ENDIF.

  LOOP AT lt_cart ASSIGNING <lfs_cart>.
    lv_lfimg = lv_lfimg + <lfs_cart>-lfimg .
  ENDLOOP.
  GET CURSOR FIELD lv_cursor.
  IF lv_lfimg GT lwa_lips-lfimg.
    CLEAR lv_lfimg.
*    GET CURSOR FIELD lv_cursor.
    IF lv_cursor = 'GV_CART1' OR
      lv_cursor = 'GV_CART1_QTY'.
*      SET CURSOR FIELD ''.
      lv_cursor = ''.
      DELETE lt_cart WHERE zzbarcode = gv_cart1.
      DELETE lt_cart_all WHERE barcode = gv_cart1.
      CLEAR: gv_cart1, gv_cart1_qty.
    ELSEIF lv_cursor = 'GV_CART2' OR
    lv_cursor = 'GV_CART2_QTY'.
*      SET CURSOR FIELD 'GV_CART1'.
      lv_cursor = 'GV_CART1'.
      DELETE lt_cart WHERE zzbarcode = gv_cart2.
      DELETE lt_cart_all WHERE barcode = gv_cart2.
      CLEAR: gv_cart2, gv_cart2_qty.
    ELSEIF lv_cursor = 'GV_CART3' OR
    lv_cursor = 'GV_CART3_QTY'.
*      SET CURSOR FIELD 'GV_CART2'.
      lv_cursor = 'GV_CART2'.
      DELETE lt_cart WHERE zzbarcode = gv_cart3.
      DELETE lt_cart_all WHERE barcode = gv_cart3.
      CLEAR: gv_cart3, gv_cart3_qty.
    ELSE .
*      SET CURSOR FIELD 'GV_CART3'.
      lv_cursor = 'GV_CART3'.
      DELETE lt_cart WHERE zzbarcode = gv_cart4.
      DELETE lt_cart_all WHERE barcode = gv_cart4.
      CLEAR: gv_cart4, gv_cart4_qty.
    ENDIF.
*    No partial deliveries are allowed

*  ERROR MESSAGE

    lv_msgno = '220'.
    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
  ELSE.
    IF lv_cursor = 'GV_CART1' OR
        lv_cursor = 'GV_CART1_QTY'.
      lv_cursor = 'GV_CART1'.
    ELSEIF lv_cursor = 'GV_CART2' OR
  lv_cursor = 'GV_CART2_QTY'.
*      SET CURSOR FIELD 'GV_CART1'.
      lv_cursor = 'GV_CART2'.
    ELSEIF lv_cursor = 'GV_CART3' OR
  lv_cursor = 'GV_CART3_QTY'.
*      SET CURSOR FIELD 'GV_CART2'.
      lv_cursor = 'GV_CART3'.
    ELSE .
*      SET CURSOR FIELD 'GV_CART3'.
      lv_cursor = ''.
      PERFORM next.
    ENDIF.
  ENDIF.
  CLEAR lv_lfimg.


ENDFORM.

FORM confirm_det .

  DATA:  ls_vekp_cust_upd   TYPE zl_vekp_cust_upd,
         return             TYPE bapiret2_t,
         ls_header          TYPE bapihuhdrproposal,
         ls_huheader        TYPE bapihuheader,
         lv_hukey           TYPE exidv,
         lv_display         TYPE flag,
         lv_error           TYPE flag,
         lv_lfimg1          TYPE lips-lfimg,
         lv_return(50)      TYPE c,
         lv_msg(20)         TYPE c,
         lv_barcode         TYPE string,
         ls_vekp_cust_upd_x TYPE zls_vekp_cust_upd_x,
         lwa_scan_det       TYPE zlscan_detail,
         lwa_itemsproposal  TYPE bapihuitmproposal,
         lt_itemsproposal   TYPE STANDARD TABLE OF bapihuitmproposal,
         lc_exidv           TYPE memoryid VALUE 'EXIDV',
         lv_exidv           TYPE exidv,
         return_n           TYPE bapiret2_t,
         lv_r_qty_char      TYPE msgv1.

* Start of Insert by EICR 603155 Gelatin Scan sghosh1
  IF gv_gelatin EQ gv_tcode.
    LOOP AT lt_hu INTO lw_hu.
      lv_lfimg1 = lv_lfimg1 + lw_hu-qty.
    ENDLOOP.
    IF lv_lfimg1 < lwa_lips-lfimg.
      DATA(lv_r_qty) = lwa_lips-lfimg - lv_lfimg1.
      lv_r_qty_char = lv_r_qty .
      CONDENSE lv_r_qty_char.
      lv_msgno = '208'.
      lv_msgv1 = lwa_lips-posnr.
      lv_msgv2 = lv_r_qty_char .
      CLEAR lv_lfimg1.
      PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
    ENDIF.
    IF lv_lfimg1 > lwa_lips-lfimg.
      lv_msgno = '220'.
      SET CURSOR FIELD ''..
      PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
    ENDIF.

    PERFORM update.
* End of Insert by EICR 603155 Gelatin Scan sghosh1
  ELSE.

    LOOP AT lt_cart ASSIGNING FIELD-SYMBOL(<lfs_cart>).
      lv_lfimg = lv_lfimg + <lfs_cart>-lfimg .
    ENDLOOP.
    IF lv_lfimg <> lwa_lips-lfimg.

*    No partial deliveries are allowed

*  ERROR MESSAGE
      lv_r_qty = lwa_lips-lfimg - lv_lfimg .
      lv_r_qty_char = lv_r_qty .
      CONDENSE lv_r_qty_char.
      lv_msgno = '208'.
      lv_msgv1 = lwa_lips-posnr.
      lv_msgv2 = lv_r_qty_char .
      CLEAR lv_lfimg.
      PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
    ENDIF.
    CLEAR lv_lfimg.
*get packaging material for carton
    SELECT SINGLE pack_matnr
                 INTO @DATA(lv_pack_mat)
                 FROM zlpack_mat
                 WHERE werks = @lwa_lips-werks
                 AND mtart = @lwa_lips-mtart
                 AND hu_id = '1'.

*Create carton HU
    LOOP AT lt_cart_all  ASSIGNING FIELD-SYMBOL(<lfs_all>) .
      READ TABLE lt_cart ASSIGNING <lfs_cart> WITH KEY zzbarcode = <lfs_all>-barcode.
      IF sy-subrc = 0.
        IF sy-tcode EQ 'ZL_BLOB_SCAN'.
          IF <lfs_all>-exidv IS INITIAL.
*          SELECT SINGLE pack_matnr
*              INTO @DATA(lv_pack_mat)
*              FROM zlpack_mat
*              WHERE werks = @lwa_lips-werks
*              AND mtart = @lwa_lips-mtart
*              AND hu_id = '1'.

*  **Create hu
            ls_header-pack_mat = lv_pack_mat.
            ls_header-hu_status_init = 'B'.


            lwa_itemsproposal-hu_item_type = '1'.

            lwa_itemsproposal-pack_qty = <lfs_cart>-lfimg.

            lwa_itemsproposal-base_unit_qty = lwa_lips-meins.
            lwa_itemsproposal-material = lwa_lips-matnr.
            lwa_itemsproposal-batch = lwa_lips-charg.
            lwa_itemsproposal-plant = lwa_lips-werks.
            APPEND lwa_itemsproposal TO lt_itemsproposal.
            CLEAR lwa_itemsproposal.

            CALL FUNCTION 'BAPI_HU_CREATE'
              EXPORTING
                headerproposal = ls_header
              IMPORTING
                huheader       = ls_huheader
                hukey          = lv_hukey
              TABLES
                itemsproposal  = lt_itemsproposal
                return         = return.
            IF ls_huheader IS NOT INITIAL
                AND lv_hukey IS NOT INITIAL.
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait = abap_true.
              CLEAR: return[], lt_itemsproposal, ls_header.
*          ls_hu-hu = lv_hukey.
* Update VEKP - ZZOLD_HU

              ls_vekp_cust_upd-venum = ls_huheader-hu_id.
              ls_vekp_cust_upd-exidv = lv_hukey.

              ls_vekp_cust_upd_x-venum = ls_huheader-hu_id.
              ls_vekp_cust_upd_x-exidv = lv_hukey.

              ls_vekp_cust_upd-zzold_hu = <lfs_cart>-zzbarcode.
              ls_vekp_cust_upd_x-zzold_hu = abap_true.

              CALL FUNCTION 'ZL_VEKP_CUST_UPD'
                EXPORTING
                  is_vekp_cust_upd   = ls_vekp_cust_upd
                  is_vekp_cust_upd_x = ls_vekp_cust_upd_x
                IMPORTING
                  et_return          = return_n
                EXCEPTIONS
                  invalid_hu         = 1
                  invalid_qa         = 2
                  invalid_reason     = 3
                  invalid_temp       = 4
                  invalid_picktxt    = 5
                  hu_missing         = 6
                  lock_error         = 7
                  update_error       = 8
                  OTHERS             = 9.
              IF sy-subrc <> 0.
              ENDIF.
            ENDIF.
          ELSE.
            lv_hukey = <lfs_all>-exidv.
          ENDIF.
        ELSE.
          CLEAR: lv_barcode.
          lv_barcode = <lfs_cart>-zzbarcode.
          DATA: lv_lfimg   TYPE lfimg,
                lv_counter TYPE zl_de_counter.
          lv_lfimg = <lfs_cart>-lfimg.
          lv_counter = <lfs_cart>-count.
*        PERFORM update USING lv_barcode
*                             lwa_lips-matnr
*                             lv_lfimg
*                             lv_counter.

        ENDIF.

        lwa_scan_det-vbeln = zsits_scan_dynp-zzoutb_delivery.
        lwa_scan_det-posnr = zsits_scan_dynp-zzobd_item.
        lwa_scan_det-matnr = lwa_lips-matnr.
        lwa_scan_det-counter = <lfs_cart>-count.
        lwa_scan_det-hu_type = 'CARTON'.
        lwa_scan_det-hu_no = lv_hukey.
        lwa_scan_det-lfimg = <lfs_cart>-lfimg.
        lwa_scan_det-zzold_hu = <lfs_cart>-zzbarcode.
        lwa_scan_det-vrkme = lwa_lips-meins.
        APPEND lwa_scan_det TO lt_scan_det.
        CLEAR: lwa_scan_det, lv_hukey , return_n, ls_vekp_cust_upd,
               ls_vekp_cust_upd_x , ls_huheader , return .


      ENDIF.
    ENDLOOP.

*  UPDATE table
    MODIFY zlscan_detail FROM TABLE lt_scan_det.
    COMMIT WORK.
  ENDIF.

  CLEAR: li_hu_disp, lt_cart, lv_indx, zsits_scan_dynp-zzbarcode ,
  lt_cart_all, lt_scan_det , lv_pack_mat , gv_flg_pallet.

ENDFORM.
FORM complete_scan.
  DATA:  ls_vekp_cust_upd   TYPE zl_vekp_cust_upd,
         return             TYPE bapiret2_t,
         ls_header          TYPE bapihuhdrproposal,
         ls_huheader        TYPE bapihuheader,
         lv_hukey           TYPE exidv,
         ls_vekp_cust_upd_x TYPE zls_vekp_cust_upd_x,
         lwa_scan_det       TYPE zlscan_detail,
         lwa_itemsproposal  TYPE bapihuitmproposal,
         lt_itemsproposal   TYPE STANDARD TABLE OF bapihuitmproposal,
*         lt_scan_det        TYPE STANDARD TABLE OF zlscan_detail,
         return_n           TYPE bapiret2_t.

  PERFORM confirm_det.

*  **  ERROR MESSAGE
*  LOOP AT lt_scan_det ASSIGNING FIELD-SYMBOL(<lfs_scan>) WHERE hu_type = 'CARTON'.
*    lv_lfimg = lv_lfimg + <lfs_scan>-lfimg .
*  ENDLOOP.

  LOOP AT li_hu_disp_n ASSIGNING FIELD-SYMBOL(<lfs_hu_disp>).

    lv_lfimg = lv_lfimg + <lfs_hu_disp>-qty1 + <lfs_hu_disp>-qty2 +
    <lfs_hu_disp>-qty3 + <lfs_hu_disp>-qty4.

  ENDLOOP.
  IF lv_lfimg <> lwa_lips-lfimg.
    CLEAR lv_lfimg.
*    No partial deliveries are allowed

*  ERROR MESSAGE

    lv_msgno = '208'.
    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
  ENDIF.
  CLEAR lv_lfimg.

*Create HUS
  LOOP AT li_hu_disp_n ASSIGNING <lfs_hu_disp>.

    IF <lfs_hu_disp>-hu1 IS NOT INITIAL.
      READ TABLE lt_cart ASSIGNING FIELD-SYMBOL(<lfs_cart>) WITH KEY zzbarcode = <lfs_hu_disp>-hu1.
      IF sy-subrc <> 0.
        lwa_final-zzbarcode = <lfs_hu_disp>-hu1.
        lwa_final-lfimg = <lfs_hu_disp>-qty1.

        IF gv_flg_pallet = abap_false.
          lv_count = lv_count + 1.
        ENDIF.
        lwa_final-count = lv_count.
        APPEND lwa_final TO lt_cart.
        CLEAR lwa_final.
      ENDIF.
    ENDIF.

    IF <lfs_hu_disp>-hu2 IS NOT INITIAL.
      READ TABLE lt_cart ASSIGNING <lfs_cart> WITH KEY zzbarcode = <lfs_hu_disp>-hu2.
      IF sy-subrc <> 0.
        lwa_final-zzbarcode = <lfs_hu_disp>-hu2.
        lwa_final-lfimg = <lfs_hu_disp>-qty2.

        IF gv_flg_pallet = abap_false.
          lv_count = lv_count + 1.
        ENDIF.
        lwa_final-count = lv_count.

        APPEND lwa_final TO lt_cart.
        CLEAR lwa_final.
      ENDIF.
    ENDIF.

    IF <lfs_hu_disp>-hu3 IS NOT INITIAL.
      READ TABLE lt_cart ASSIGNING <lfs_cart> WITH KEY zzbarcode = <lfs_hu_disp>-hu3.
      IF sy-subrc <> 0.
        lwa_final-zzbarcode = <lfs_hu_disp>-hu3.
        lwa_final-lfimg = <lfs_hu_disp>-qty3.

        IF gv_flg_pallet = abap_false.
          lv_count = lv_count + 1.
        ENDIF.
        lwa_final-count = lv_count.

        APPEND lwa_final TO lt_cart.
        CLEAR lwa_final.
      ENDIF.
    ENDIF.

    IF <lfs_hu_disp>-hu4 IS NOT INITIAL.
      READ TABLE lt_cart ASSIGNING <lfs_cart> WITH KEY zzbarcode = <lfs_hu_disp>-hu4.
      IF sy-subrc <> 0.
        lwa_final-zzbarcode = <lfs_hu_disp>-hu4.
        lwa_final-lfimg = <lfs_hu_disp>-qty4.

        IF gv_flg_pallet = abap_false.
          lv_count = lv_count + 1.
        ENDIF.
        lwa_final-count = lv_count.

        APPEND lwa_final TO lt_cart.
        CLEAR lwa_final.
      ENDIF.
    ENDIF.

  ENDLOOP.

  SELECT SINGLE pack_matnr
      INTO @DATA(lv_pack_mat)
      FROM zlpack_mat
      WHERE werks = @lwa_lips-werks
      AND mtart = @lwa_lips-mtart
      AND hu_id = '2'.

  IF lt_cart IS NOT INITIAL.

    SELECT
      exidv,
      zzold_hu
      FROM vekp
      INTO TABLE @DATA(li_exidv)
      FOR ALL ENTRIES IN @lt_cart
      WHERE zzold_hu = @lt_cart-zzbarcode.

*  **Create hu
    ls_header-pack_mat = lv_pack_mat.
    ls_header-hu_status_init = 'B'.

    LOOP AT lt_cart ASSIGNING <lfs_cart>.
      READ TABLE li_exidv ASSIGNING FIELD-SYMBOL(<lfs_exidv>) WITH KEY zzold_hu = <lfs_cart>-zzbarcode.
      IF sy-subrc <> 0.
        lwa_itemsproposal-hu_item_type = '1'.
        lwa_itemsproposal-pack_qty = <lfs_cart>-lfimg.
        lwa_itemsproposal-base_unit_qty = lwa_lips-meins.
        lwa_itemsproposal-material = lwa_lips-matnr.
        lwa_itemsproposal-batch = lwa_lips-charg.
        lwa_itemsproposal-plant = lwa_lips-werks.
        APPEND lwa_itemsproposal TO lt_itemsproposal.
        CLEAR lwa_itemsproposal.

        CALL FUNCTION 'BAPI_HU_CREATE'
          EXPORTING
            headerproposal = ls_header
          IMPORTING
            huheader       = ls_huheader
            hukey          = lv_hukey
          TABLES
            itemsproposal  = lt_itemsproposal
            return         = return.
        IF ls_huheader IS NOT INITIAL
            AND lv_hukey IS NOT INITIAL.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
          CLEAR return[].
*          ls_hu-hu = lv_hukey.
* Update VEKP - ZZOLD_HU
          ls_vekp_cust_upd-venum = ls_huheader-hu_id.
          ls_vekp_cust_upd-exidv = lv_hukey.

          ls_vekp_cust_upd_x-venum = ls_huheader-hu_id.
          ls_vekp_cust_upd_x-exidv = lv_hukey.

          ls_vekp_cust_upd-zzold_hu = <lfs_cart>-zzbarcode.
          ls_vekp_cust_upd_x-zzold_hu = abap_true.

          CALL FUNCTION 'ZL_VEKP_CUST_UPD'
            EXPORTING
              is_vekp_cust_upd   = ls_vekp_cust_upd
              is_vekp_cust_upd_x = ls_vekp_cust_upd_x
            IMPORTING
              et_return          = return_n
            EXCEPTIONS
              invalid_hu         = 1
              invalid_qa         = 2
              invalid_reason     = 3
              invalid_temp       = 4
              invalid_picktxt    = 5
              hu_missing         = 6
              lock_error         = 7
              update_error       = 8
              OTHERS             = 9.
          IF sy-subrc <> 0.
          ENDIF.
        ENDIF.
      ELSE.
        lv_hukey = <lfs_exidv>-exidv.
      ENDIF.

      lwa_scan_det-vbeln = zsits_scan_dynp-zzoutb_delivery.
      lwa_scan_det-posnr = zsits_scan_dynp-zzobd_item.
      lwa_scan_det-matnr = lwa_lips-matnr.
      lwa_scan_det-counter = <lfs_cart>-count.
      lwa_scan_det-hu_type = 'CARTON'.
      lwa_scan_det-hu_no = lv_hukey.
      lwa_scan_det-lfimg = <lfs_cart>-lfimg.
      lwa_scan_det-zzold_hu = <lfs_cart>-zzbarcode.
      APPEND lwa_scan_det TO lt_scan_det.
      CLEAR: lwa_scan_det, lv_hukey , return_n, ls_vekp_cust_upd,
             ls_vekp_cust_upd_x , ls_huheader , return .

    ENDLOOP.
  ENDIF.
*link HUs to OBD.
  PERFORM link_hu_to_obd.

*  UPDATE table
  INSERT zlscan_detail FROM TABLE lt_scan_det.

  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.


*  BACK TO SCREEN 100
  SET SCREEN 0100.

ENDFORM.
FORM modify_table.

  READ TABLE li_hu_disp ASSIGNING FIELD-SYMBOL(<lfs_hu_disp>)
  WITH KEY hu1 = gv_cart1.

  IF sy-subrc <> 0.

    lwa_hu-hu1 = gv_cart1.
    lwa_hu-hu2 = gv_cart2.
    lwa_hu-hu3 = gv_cart3.
    lwa_hu-hu4 = gv_cart4.
    lwa_hu-qty1 = gv_cart1_qty.
    lwa_hu-qty2 = gv_cart2_qty.
    lwa_hu-qty3 = gv_cart3_qty.
    lwa_hu-qty4 = gv_cart4_qty.
    APPEND lwa_hu TO li_hu_disp.
    CLEAR lwa_hu.
  ELSE.
    <lfs_hu_disp>-qty1 = gv_cart1_qty.
    <lfs_hu_disp>-qty2 = gv_cart2_qty.
    <lfs_hu_disp>-qty3 = gv_cart3_qty.
    <lfs_hu_disp>-qty4 = gv_cart4_qty.
  ENDIF.
  CLEAR : gv_cart1 , gv_cart2, gv_cart3, gv_cart4,
            gv_cart1_qty, gv_cart2_qty, gv_cart3_qty, gv_cart4_qty.
ENDFORM.
FORM next.
  lv_cursor = ''.
*  SET CURSOR FIELD ''.
*  CLEAR lv_cursor.
  PERFORM modify_table.
  lv_indx = lv_indx + 1.

  READ TABLE li_hu_disp ASSIGNING FIELD-SYMBOL(<lfs_hu_disp>) INDEX lv_indx.
  IF sy-subrc = 0.

    gv_cart1 = <lfs_hu_disp>-hu1.
    gv_cart2 = <lfs_hu_disp>-hu2.
    gv_cart3 = <lfs_hu_disp>-hu3.
    gv_cart4 = <lfs_hu_disp>-hu4.
    gv_cart1_qty = <lfs_hu_disp>-qty1.
    gv_cart2_qty = <lfs_hu_disp>-qty2.
    gv_cart3_qty = <lfs_hu_disp>-qty3.
    gv_cart4_qty = <lfs_hu_disp>-qty4.

    CONDENSE: gv_cart1_qty, gv_cart2_qty, gv_cart3_qty, gv_cart4_qty.
  ENDIF.
*  lwa_hu-hu1 = gv_cart1.
*  lwa_hu-hu2 = gv_cart2.
*  lwa_hu-hu3 = gv_cart3.
*  lwa_hu-hu4 = gv_cart4.
*  lwa_hu-qty1 = gv_cart1_qty.
*  lwa_hu-qty2 = gv_cart2_qty.
*  lwa_hu-qty3 = gv_cart3_qty.
*  lwa_hu-qty4 = gv_cart4_qty.
*  APPEND lwa_hu TO li_hu_disp.
*  CLEAR lwa_hu.
*  CLEAR : gv_cart1 , gv_cart2, gv_cart3, gv_cart4,
*          gv_cart1_qty, gv_cart2_qty, gv_cart3_qty, gv_cart4_qty.
  SET CURSOR FIELD ''.

*    READ TABLE li_hu_disp ASSIGNING FIELD-SYMBOL(<lfs_hu_disp>) INDEX lv_indx.
*    IF sy-subrc = 0.
*
*      gv_cart1 = <lfs_hu_disp>-hu1.
*      gv_cart2 = <lfs_hu_disp>-hu2.
*      gv_cart3 = <lfs_hu_disp>-hu3.
*      gv_cart4 = <lfs_hu_disp>-hu4.
*      gv_cart1_qty = <lfs_hu_disp>-qty1.
*      gv_cart2_qty = <lfs_hu_disp>-qty2.
*      gv_cart3_qty = <lfs_hu_disp>-qty3.
*      gv_cart4_qty = <lfs_hu_disp>-qty4.
*
*      CONDENSE: gv_cart1_qty, gv_cart2_qty, gv_cart3_qty, gv_cart4_qty.
*
*    ELSE.
*      CLEAR : gv_cart1 , gv_cart2, gv_cart3, gv_cart4,
*              gv_cart1_qty, gv_cart2_qty, gv_cart3_qty, gv_cart4_qty.
*    ENDIF.



ENDFORM.
FORM prev.
*  CLEAR lv_cursor.
*  SET CURSOR FIELD ''.
  PERFORM modify_table.
  lv_cursor = ''.
  lv_indx = lv_indx - 1.

  IF lv_indx IS INITIAL.
    lv_indx = 1.
  ENDIF.
  READ TABLE li_hu_disp ASSIGNING FIELD-SYMBOL(<lfs_hu_disp>) INDEX lv_indx.
  IF sy-subrc = 0.

    gv_cart1 = <lfs_hu_disp>-hu1.
    gv_cart2 = <lfs_hu_disp>-hu2.
    gv_cart3 = <lfs_hu_disp>-hu3.
    gv_cart4 = <lfs_hu_disp>-hu4.
    gv_cart1_qty = <lfs_hu_disp>-qty1.
    gv_cart2_qty = <lfs_hu_disp>-qty2.
    gv_cart3_qty = <lfs_hu_disp>-qty3.
    gv_cart4_qty = <lfs_hu_disp>-qty4.

    CONDENSE: gv_cart1_qty, gv_cart2_qty, gv_cart3_qty, gv_cart4_qty.
  ENDIF.
  SET CURSOR FIELD ''.
*  PERFORM modify_table.
*  lv_indx = lv_indx - 1.
*  IF lv_indx IS NOT INITIAL.
*    READ TABLE li_hu_disp ASSIGNING FIELD-SYMBOL(<lfs_hu_disp>) INDEX lv_indx.
*    IF sy-subrc = 0.
*
*      gv_cart1 = <lfs_hu_disp>-hu1.
*      gv_cart2 = <lfs_hu_disp>-hu2.
*      gv_cart3 = <lfs_hu_disp>-hu3.
*      gv_cart4 = <lfs_hu_disp>-hu4.
*      gv_cart1_qty = <lfs_hu_disp>-qty1.
*      gv_cart2_qty = <lfs_hu_disp>-qty2.
*      gv_cart3_qty = <lfs_hu_disp>-qty3.
*      gv_cart4_qty = <lfs_hu_disp>-qty4.
*
*      CONDENSE: gv_cart1_qty, gv_cart2_qty, gv_cart3_qty, gv_cart4_qty.
*    ENDIF.
*  ELSE.
*    lv_indx = 1.
*  ENDIF.
ENDFORM.
FORM check_delivery.

  IF zsits_scan_dynp-zzoutb_delivery IS INITIAL.
    " Enter a valid ob delivery number
*    v_flag = lc_x.
*   *--Show an error message
    " Add a new message to message class
    lv_msgno = '026'. "Enter Valid Delivery number
*    SET CURSOR FIELD ' '.
    lv_cursor_n = ''.
*    lv_msgv1 = zsits_scan_dynp-zzoutb_delivery.
    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
  ELSE.

    SELECT
        posnr,
        matnr,
        werks,
        charg,
        lfimg,
        meins,
        vrkme,
        lgnum,
        lgtyp,
        mtart
        FROM lips
        INTO TABLE @lt_lips
        WHERE vbeln = @zsits_scan_dynp-zzoutb_delivery.
    IF sy-subrc = 0.
      IF zsits_scan_dynp-zzobd_item IS INITIAL.
        DESCRIBE TABLE lt_lips LINES DATA(lv_lines_n).
        IF lv_lines_n = 1.
          READ TABLE lt_lips ASSIGNING FIELD-SYMBOL(<lfs_lips>) INDEX 1.
          IF sy-subrc = 0.

***  BEGIN: EICR:603155 MGS- Project ONE: HC & DFS Implementation US & MX****
*** Authority check on LGNUM and LGTYP
            PERFORM authority_check USING <lfs_lips>.
***  END: EICR:603155 MGS- Project ONE: HC & DFS Implementation US & MX****

            zsits_scan_dynp-zzobd_item = <lfs_lips>-posnr.
            lwa_lips = <lfs_lips>.
**************************
            SELECT * FROM zlscan_detail
              INTO TABLE @DATA(lt_zlscan)
              WHERE vbeln = @zsits_scan_dynp-zzoutb_delivery
              AND posnr = @zsits_scan_dynp-zzobd_item.
            IF  sy-subrc = 0.
              lv_msgno = '223'. "Scanning can't be done for Delivery & Item &
              lv_msgv1 = zsits_scan_dynp-zzoutb_delivery.
              lv_msgv2 = zsits_scan_dynp-zzobd_item.
*              SET CURSOR FIELD ''.
              lv_cursor_n = ''.
              PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.

            ENDIF.
****************************
          ENDIF.
        ELSE.
          lv_msgno = '216'. "Enter delivery item no
*            SET CURSOR FIELD 'ZSITS_SCAN_DYNP-ZZOUTB_DELIVERY'.
          lv_cursor_n = 'ZSITS_SCAN_DYNP-ZZOUTB_DELIVERY'.
          PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.

        ENDIF.
*        ENDIF.
      ELSE.
        READ TABLE lt_lips ASSIGNING <lfs_lips> WITH KEY posnr = zsits_scan_dynp-zzobd_item.
        IF sy-subrc = 0.
          lwa_lips = <lfs_lips>.

***  BEGIN: EICR:603155 MGS- Project ONE: HC & DFS Implementation US & MX****
*** Authority check on LGNUM and LGTYP
          PERFORM authority_check USING <lfs_lips>.
***  END: EICR:603155 MGS- Project ONE: HC & DFS Implementation US & MX****

**************************
          SELECT * FROM zlscan_detail
             INTO TABLE @lt_zlscan
             WHERE vbeln = @zsits_scan_dynp-zzoutb_delivery
             AND posnr = @zsits_scan_dynp-zzobd_item.
          IF  sy-subrc = 0.
            lv_msgno = '223'. "Scanning can't be done for Delivery & Item &
            lv_msgv1 = zsits_scan_dynp-zzoutb_delivery.
            lv_msgv2 = zsits_scan_dynp-zzobd_item.
*            SET CURSOR FIELD ''.
            lv_cursor_n = ''.
            PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.

          ENDIF.
****************************
        ELSE.
          lv_msgno = '0217'. "Enter valid delivery item no
*          SET CURSOR FIELD 'ZSITS_SCAN_DYNP-ZZOUTB_DELIVERY'.
          lv_cursor_n = 'ZSITS_SCAN_DYNP-ZZOUTB_DELIVERY'.
          CLEAR zsits_scan_dynp-zzobd_item.
          PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.

        ENDIF.
      ENDIF.
      IF sy-tcode EQ 'ZL_BLOB_SCAN'.
        IF lwa_lips IS NOT INITIAL.
          IF lwa_lips-charg IS INITIAL.
            lv_msgno = '0245'. "There's no batch in Delivery Item
            lv_cursor_n = 'ZSITS_SCAN_DYNP-ZZOUTB_DELIVERY'.
            PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.

      lv_msgno = '026'. "Enter Valid Delivery number
*      SET CURSOR FIELD ''.
      lv_cursor_n = ''.
      CLEAR zsits_scan_dynp-zzoutb_delivery.
*    lv_msgv1 = zsits_scan_dynp-zzoutb_delivery.
      PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.

    ENDIF.
  ENDIF.

ENDFORM.

FORM carton_validation.



  DATA: lv_barcode_string TYPE string.
  DATA:  ls_vekp_cust_upd   TYPE zl_vekp_cust_upd,
         lwa_cart_all       TYPE gty_cart_all,
         lv_vemng           TYPE vemng,
         lv_exidv           TYPE exidv,
         lv_label(3)        TYPE c,
         lv_venum1          TYPE venum,
         lv_flag            TYPE flag,
         return             TYPE bapiret2_t,
         ls_header          TYPE bapihuhdrproposal,
         ls_huheader        TYPE bapihuheader,
         lv_hukey           TYPE exidv,
         lv_carton          TYPE exidv,
         lv_venum           TYPE venum,
         lv_status          TYPE hu_status,
         lv_objnr           TYPE j_objnr,
         ls_vekp_cust_upd_x TYPE zls_vekp_cust_upd_x,
         return_n           TYPE bapiret2_t.

  DATA: v_label_type     TYPE zdits_label_type,
        ls_label_content TYPE zsits_label_content,
        lv_charg         TYPE charg_d,
        lv_werks         TYPE werks_d,
        lv_matnr         TYPE matnr,
        lt_husstat       TYPE husstat_t,
        lt_werks_r       TYPE tt_werks_r,
        lv_flg_allow     TYPE xflag,
        lt_return        TYPE ztits_barcode_return.

  CLEAR: lv_barcode_string, lt_return, v_label_type,ls_label_content,
  lv_carton,  lwa_cart_all.

  IF lt_werks_r IS INITIAL.
    PERFORM get_zvv_param CHANGING lt_werks_r.
  ENDIF.

  IF gv_cart1 IS NOT INITIAL.
    CLEAR: lv_charg , lv_werks, lv_matnr, lv_flg_allow.
    READ TABLE lt_cart_all ASSIGNING FIELD-SYMBOL(<lfs_cart_all>) WITH KEY barcode = gv_cart1.
    IF sy-subrc <> 0.
      lv_barcode_string = gv_cart1.
* Start of Insert by EICR 603155 Gelatin Scan sghosh1
      IF gv_gelatin EQ gv_tcode.
        READ TABLE lt_hu INTO lw_hu WITH KEY hu = gv_cart1 TRANSPORTING NO FIELDS.
        IF sy-subrc <> gc_0.
          gv_cart1_barcode = lv_barcode_string.
          CALL METHOD zcl_its_utility=>read_barcode_gelatin
            EXPORTING
              barcode          = lv_barcode_string
            IMPORTING
              it_hu            = lt_hu2
              o_label_content  = ls_label_content
              type             = lv_label
            EXCEPTIONS
              illegal_bar_code = 1.

          IF sy-subrc EQ 0.
            lv_flag = abap_false.
            CLEAR: lv_exidv, lv_venum1.
            lv_exidv = ls_label_content-zzhu_exid.
            SELECT SINGLE venum
              INTO lv_venum1 FROM vekp
              WHERE exidv = lv_exidv.
            IF lv_venum1 IS INITIAL.
              READ TABLE lt_hu INTO lw_hu WITH KEY hu = lv_exidv TRANSPORTING NO FIELDS.
              IF sy-subrc <> gc_0.
                SELECT SINGLE hu_no FROM zlscan_detail INTO @DATA(lv_exidv1) WHERE hu_no = @lv_exidv.
                IF sy-subrc <> gc_0.
                  lwa_cart_all-barcode = lv_barcode_string.
                  lwa_cart_all-exidv = ls_label_content-zzhu_exid.
                  lwa_cart_all-lfimg = ls_label_content-zzquantity.
                  lwa_cart_all-batch = ls_label_content-zzorigin_batch.
                  APPEND lwa_cart_all TO lt_cart_all.
                  CLEAR  lwa_cart_all.
                  APPEND LINES OF lt_hu2[] TO lt_hu[].
                  APPEND LINES OF lt_hu2[] TO lt_hu1[].
                  APPEND LINES OF lt_hu2[] TO lt_hu4[].
                ELSE.
                  lv_flag = abap_true.
                  lv_msgno = '528'.
                  lv_cursor = ''.
                  lv_msgv1 = lv_exidv.
                  CLEAR: gv_cart1.
                  PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                  EXIT.
                ENDIF.
              ELSE.
                lv_flag = abap_true.
                lv_msgno = '527'.
                lv_cursor = ''.
                lv_msgv1 = lv_exidv.
                CLEAR: gv_cart1.
                PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                EXIT.
              ENDIF.
            ELSEIF lv_venum1 IS NOT INITIAL.
              lv_flag = abap_true.
              lv_msgno = '525'.
              lv_cursor = ''.
              lv_msgv1 = lv_exidv.
              CLEAR: gv_cart1.
              PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
              EXIT.
            ENDIF.
          ELSE.
            CLEAR: gv_cart1.
            lv_msgno = sy-msgno.
            lv_msgv1 = lv_barcode_string.
            CONDENSE lv_msgv1.
            PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
          ENDIF.
        ENDIF.
* End of Insert   by EICR 603155 Gelatin Scan sghosh1
      ELSE.
        CALL METHOD zcl_its_utility=>bar_code_translation_dfs
          EXPORTING
            i_bar_code_string = lv_barcode_string
            i_appid_type      = 'GS1'
*           i_su_label        = abap_true
*           iv_appid_type     =
          IMPORTING
            o_return          = lt_return
            o_label_type      = v_label_type
            o_label_content   = ls_label_content
          EXCEPTIONS
            illegal_bar_code  = 1
            conversion_error  = 2
            system_error      = 3
            numeric_error     = 4
            OTHERS            = 5.
        IF sy-subrc = 0.
          lv_carton = ls_label_content-zzhu_exid.
        ENDIF.
        IF lv_carton IS NOT INITIAL.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_carton
            IMPORTING
              output = lv_carton.
          SELECT venum  status
            UP TO 1 ROWS
            FROM vekp
            INTO ( lv_venum , lv_status )
            WHERE exidv = lv_carton.
          ENDSELECT.
          IF sy-subrc <> 0.
            CLEAR: gv_cart1.
*            SET CURSOR FIELD ''.
            lv_cursor = ''.
            lv_msgno = '221'.
            PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
          ELSE.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lv_venum
              IMPORTING
                output = lv_venum.

            SELECT
              vemng,
              matnr,
              charg,
              werks
              FROM vepo
              INTO TABLE @DATA(lt_vepo)
              WHERE venum = @lv_venum.

            LOOP AT lt_vepo ASSIGNING FIELD-SYMBOL(<lfs_vepo>).
              lv_vemng = <lfs_vepo>-vemng + lv_vemng.
              IF lv_charg IS INITIAL.
                lv_charg = <lfs_vepo>-charg.
              ENDIF.
              IF lv_werks IS INITIAL.
                lv_werks = <lfs_vepo>-werks.
              ENDIF.
              IF lv_matnr IS INITIAL.
                lv_matnr = <lfs_vepo>-matnr.
              ENDIF.
            ENDLOOP.

            CONCATENATE 'HU' lv_venum INTO lv_objnr.
            SELECT * FROM husstat
              INTO TABLE @lt_husstat
              WHERE objnr = @lv_objnr.
            IF sy-subrc = 0
              AND lt_husstat IS NOT INITIAL.
              "Begin of BLOB New CR 03.08.2020
              IF lv_werks <> lwa_lips-werks AND lv_werks IN lt_werks_r
                AND lv_matnr = lwa_lips-matnr AND lv_charg = lwa_lips-charg.

                "Validate if the HU status is different than PSTD
                READ TABLE lt_husstat ASSIGNING FIELD-SYMBOL(<lfs_husstat1>)
                WITH KEY stat = 'I0522' inact = space.
                IF sy-subrc <> 0.
                  lv_flg_allow = abap_true.
                ENDIF.

              ENDIF.
              IF lv_flg_allow = abap_false.
                "End of BLOB New CR 03.08.2020
                READ TABLE lt_husstat ASSIGNING FIELD-SYMBOL(<lfs_husstat>)
                WITH KEY stat = 'I0522' inact = space.
                IF sy-subrc <> 0.
*                *********************************
                  READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0511' inact = space.
                  IF sy-subrc <> 0.
                    lv_cursor = ''.
                    lv_msgno = '244'.
                    lv_msgv1 = lv_carton.
                    CLEAR: gv_cart1, gv_cart1_qty,lv_objnr, lt_husstat.
                    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                  ELSE.
                    READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0512' inact = space.
                    IF sy-subrc = 0.
                      lv_cursor = ''.
                      lv_msgno = '244'.
                      lv_msgv1 = lv_carton.
                      CLEAR: gv_cart1, gv_cart1_qty,lv_objnr, lt_husstat.
                      PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.

            IF lv_charg <> lwa_lips-charg.
              lv_msgno = '243'.
              lv_msgv1 = lv_charg.
              lv_msgv2 = lwa_lips-charg.
              lv_cursor = ''.
              CLEAR: gv_cart1, gv_cart1_qty, lv_charg, lv_vemng .
              PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
            ENDIF.
            lwa_cart_all-barcode = lv_barcode_string.
            lwa_cart_all-exidv = lv_carton.
            lwa_cart_all-lfimg = lv_vemng.
            APPEND lwa_cart_all TO lt_cart_all.
            CLEAR  lwa_cart_all.
          ENDIF.
        ELSE.

          SELECT
            venum,
            exidv,
            status
            UP TO 1 ROWS
        FROM vekp
        INTO @DATA(lwa_exidv)
        WHERE zzold_hu = @gv_cart1.
          ENDSELECT.

          IF sy-subrc <> 0.
            "*Create Carton HU
*           " Check batch in barcode string
            READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<lfs_return>)
            WITH KEY ai = '10'.
            IF sy-subrc = 0.
              lv_charg = <lfs_return>-value.
              IF lv_charg <> lwa_lips-charg.
                lv_msgno = '243'.
                lv_msgv1 = lv_charg.
                lv_msgv2 = lwa_lips-charg.
                lv_cursor = ''.
                CLEAR: gv_cart1, gv_cart1_qty, lv_charg .
                PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
              ENDIF.
            ENDIF.
            " Check quantity in barcode string
            READ TABLE lt_return ASSIGNING <lfs_return>
            WITH KEY ai = '30'.
            IF sy-subrc = 0.
              lwa_cart_all-lfimg = <lfs_return>-quantity.
            ENDIF.
            lwa_cart_all-barcode = lv_barcode_string.
            APPEND lwa_cart_all TO lt_cart_all.
            CLEAR  lwa_cart_all.
          ELSE.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lwa_exidv-venum
              IMPORTING
                output = lwa_exidv-venum.

            SELECT
             vemng,
             matnr,
             charg,
             werks
            FROM vepo
            INTO TABLE @lt_vepo
            WHERE venum = @lwa_exidv-venum.

            LOOP AT lt_vepo ASSIGNING <lfs_vepo>.
              lv_vemng = <lfs_vepo>-vemng + lv_vemng.
              IF lv_charg IS INITIAL.
                lv_charg = <lfs_vepo>-charg.
              ENDIF.
              IF lv_werks IS INITIAL.
                lv_werks = <lfs_vepo>-werks.
              ENDIF.
              IF lv_matnr IS INITIAL.
                lv_matnr = <lfs_vepo>-matnr.
              ENDIF.
            ENDLOOP.

            CONCATENATE 'HU' lwa_exidv-venum INTO lv_objnr.
            SELECT * FROM husstat
              INTO TABLE @lt_husstat
              WHERE objnr = @lv_objnr.
            IF sy-subrc = 0
              AND lt_husstat IS NOT INITIAL.

              "Begin of BLOB New CR 03.08.2020
              IF lv_werks <> lwa_lips-werks AND lv_werks IN lt_werks_r
                AND lv_matnr = lwa_lips-matnr AND lv_charg = lwa_lips-charg.

                "Validate if the HU status is different than PSTD
                READ TABLE lt_husstat ASSIGNING <lfs_husstat1>
                WITH KEY stat = 'I0522' inact = space.
                IF sy-subrc <> 0.
                  lv_flg_allow = abap_true.
                ENDIF.

              ENDIF.
              IF lv_flg_allow = abap_false.
                "End of BLOB New CR 03.08.2020

                READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0522' inact = space.

                IF sy-subrc <> 0.
*                *********************************
                  READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0511' inact = space.
                  IF sy-subrc <> 0.
                    lv_cursor = ''.
                    lv_msgno = '244'.
                    lv_msgv1 = lwa_exidv-exidv.
                    CLEAR: gv_cart1, gv_cart1_qty,lv_objnr, lt_husstat.
                    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                  ELSE.
                    READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0512' inact = space.
                    IF sy-subrc = 0.
                      lv_cursor = ''.
                      lv_msgno = '244'.
                      lv_msgv1 = lwa_exidv-exidv.
                      CLEAR: gv_cart1, gv_cart1_qty,lv_objnr, lt_husstat.
                      PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.


            IF lv_charg <> lwa_lips-charg.
              lv_msgno = '243'.
              lv_msgv1 = lv_charg.
              lv_msgv2 = lwa_lips-charg.
              lv_cursor = ''.
              CLEAR: gv_cart1, gv_cart1_qty, lv_charg, lv_vemng .
              PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
            ENDIF.

            lwa_cart_all-barcode = lv_barcode_string.
            lwa_cart_all-exidv = lwa_exidv-exidv.
            lwa_cart_all-lfimg = lv_vemng.
            APPEND lwa_cart_all TO lt_cart_all.
            CLEAR  lwa_cart_all.

          ENDIF.
        ENDIF.
      ENDIF.
    ELSEIF sy-subrc = gc_0.
      IF gv_gelatin EQ gv_tcode.
        lv_exidv = <lfs_cart_all>-exidv.
        IF sy-subrc EQ gc_0.
          lv_flag = abap_true.
          lv_msgno = '527'.
          lv_cursor = ''.
          lv_msgv1 = lv_exidv.
          CLEAR: gv_cart1, gv_cart1_qty.
          PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR: lv_barcode_string, lt_return, v_label_type,ls_label_content, lv_exidv, lv_exidv1,
           lv_carton, lv_venum, lwa_cart_all, lwa_exidv, lv_vemng, lt_hu2[], lv_objnr, lt_husstat.
  ENDIF.

  IF gv_cart2 IS NOT INITIAL.
    CLEAR: lv_charg , lv_werks, lv_matnr , lv_flg_allow .
    READ TABLE lt_cart_all ASSIGNING <lfs_cart_all> WITH KEY barcode = gv_cart2.
    IF sy-subrc <> 0.
      lv_barcode_string = gv_cart2.
* Start of Insert by EICR 603155 Gelatin Scan sghosh1
      IF gv_gelatin EQ gv_tcode.
        READ TABLE lt_hu INTO lw_hu WITH KEY hu = gv_cart2 TRANSPORTING NO FIELDS.
        IF sy-subrc <> gc_0.
          gv_cart2_barcode = lv_barcode_string.
          CALL METHOD zcl_its_utility=>read_barcode_gelatin
            EXPORTING
              barcode         = lv_barcode_string
            IMPORTING
              it_hu           = lt_hu2
              o_label_content = ls_label_content
              type            = lv_label.
          IF sy-subrc EQ 0.
            lv_flag = abap_false.
            CLEAR: lv_exidv, lv_venum1.
            lv_exidv = ls_label_content-zzhu_exid.
            SELECT SINGLE venum
              INTO lv_venum1 FROM vekp
              WHERE exidv = lv_exidv.
            IF lv_venum1 IS INITIAL.
              READ TABLE lt_hu INTO lw_hu WITH KEY hu = lv_exidv TRANSPORTING NO FIELDS.
              IF sy-subrc <> gc_0.
                SELECT SINGLE hu_no FROM zlscan_detail INTO lv_exidv1 WHERE hu_no = lv_exidv.
                IF sy-subrc <> gc_0.
                  APPEND LINES OF lt_hu2[] TO lt_hu[].
                  APPEND LINES OF lt_hu2[] TO lt_hu1[].
                  APPEND LINES OF lt_hu2[] TO lt_hu4[].
                  lwa_cart_all-barcode = lv_barcode_string.
                  lwa_cart_all-exidv = ls_label_content-zzhu_exid.
                  lwa_cart_all-lfimg = ls_label_content-zzquantity.
                  lwa_cart_all-batch = ls_label_content-zzorigin_batch.
                  APPEND lwa_cart_all TO lt_cart_all.
                  CLEAR  lwa_cart_all.
                ELSE.
                  lv_flag = abap_true.
                  lv_msgno = '528'.
                  lv_cursor = ''.
                  lv_msgv1 = lv_exidv.
                  CLEAR: gv_cart1.
                  PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                  EXIT.
                ENDIF.
              ELSE.
                lv_flag = abap_true.
                lv_msgno = '527'.
                lv_cursor = ''.
                lv_msgv1 = lv_exidv.
                CLEAR: gv_cart1.
                PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                EXIT.
              ENDIF.
            ELSEIF lv_venum1 IS NOT INITIAL.
              lv_flag = abap_true.
              lv_msgno = '525'.
              lv_cursor = 'GV_CART1'.
              lv_msgv1 = lv_exidv.
              CLEAR: gv_cart2.
              PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
              EXIT.
            ENDIF.
          ELSE.
            CLEAR: gv_cart2.
            lv_msgno = sy-msgno.
            lv_msgv1 = lv_barcode_string.
            CONDENSE lv_msgv1.
            PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
          ENDIF.
        ENDIF.
* End of Insert by EICR 603155 Gelatin Scan sghosh1
      ELSE.
        CALL METHOD zcl_its_utility=>bar_code_translation_dfs
          EXPORTING
            i_bar_code_string = lv_barcode_string
            i_appid_type      = 'GS1'
*           i_su_label        = abap_true
*           iv_appid_type     =
          IMPORTING
            o_return          = lt_return
            o_label_type      = v_label_type
            o_label_content   = ls_label_content
          EXCEPTIONS
            illegal_bar_code  = 1
            conversion_error  = 2
            system_error      = 3
            numeric_error     = 4
            OTHERS            = 5.
        IF sy-subrc = 0.
          lv_carton = ls_label_content-zzhu_exid.
        ENDIF.
        IF lv_carton IS NOT INITIAL.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_carton
            IMPORTING
              output = lv_carton.
          SELECT venum status
            UP TO 1 ROWS
            FROM vekp
            INTO ( lv_venum , lv_status )
            WHERE exidv = lv_carton.
          ENDSELECT.
          IF sy-subrc <> 0.
            CLEAR: gv_cart2.
*            SET CURSOR FIELD 'GV_CART1'.
            lv_cursor = 'GV_CART1'.
            lv_msgno = '221'.
            PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
          ELSE.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lv_venum
              IMPORTING
                output = lv_venum.

            SELECT vemng,
             matnr,
             charg,
             werks
             FROM vepo
             INTO TABLE @lt_vepo
             WHERE venum = @lv_venum.

            LOOP AT lt_vepo ASSIGNING <lfs_vepo>.
              lv_vemng = <lfs_vepo>-vemng + lv_vemng.
              IF lv_charg IS INITIAL.
                lv_charg = <lfs_vepo>-charg.
              ENDIF.
              IF lv_werks IS INITIAL.
                lv_werks = <lfs_vepo>-werks.
              ENDIF.
              IF lv_matnr IS INITIAL.
                lv_matnr = <lfs_vepo>-matnr.
              ENDIF.
            ENDLOOP.

            CONCATENATE 'HU' lv_venum INTO lv_objnr.
            SELECT * FROM husstat
              INTO TABLE @lt_husstat
              WHERE objnr = @lv_objnr.
            IF sy-subrc = 0
              AND lt_husstat IS NOT INITIAL.

              "Begin of BLOB New CR 03.08.2020
*              IF lv_werks <> lwa_lips-werks AND lv_werks IN lt_werks_r
*                AND lv_matnr = lwa_lips-matnr AND lv_charg = lwa_lips-charg.
*
*                PERFORM status_to_phex USING  lv_objnr
*                                               lv_venum
*                                               lv_carton
*                                               lv_status
*                                       CHANGING lt_husstat.
*
*              ENDIF.
              IF lv_werks <> lwa_lips-werks AND lv_werks IN lt_werks_r
                AND lv_matnr = lwa_lips-matnr AND lv_charg = lwa_lips-charg.

                "Validate if the HU status is different than PSTD
                READ TABLE lt_husstat ASSIGNING <lfs_husstat1>
                WITH KEY stat = 'I0522' inact = space.
                IF sy-subrc <> 0.
                  lv_flg_allow = abap_true.
                ENDIF.

              ENDIF.
              IF lv_flg_allow = abap_false.
                "End of BLOB New CR 03.08.2020

                READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0522' inact = space.

                IF sy-subrc <> 0.
*                *********************************
                  READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0511' inact = space.
                  IF sy-subrc <> 0.
                    lv_cursor = 'GV_CART1'.
                    lv_msgno = '244'.
                    lv_msgv1 = lv_carton.
                    CLEAR: gv_cart2, gv_cart2_qty,lv_objnr, lt_husstat.
                    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                  ELSE.
                    READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0512' inact = space.
                    IF sy-subrc = 0.
                      lv_cursor = 'GV_CART1'.
                      lv_msgno = '244'.
                      lv_msgv1 = lv_carton.
                      CLEAR: gv_cart2, gv_cart2_qty,lv_objnr, lt_husstat.
                      PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.

            IF lv_charg <> lwa_lips-charg.
              lv_msgno = '243'.
              lv_msgv1 = lv_charg.
              lv_msgv2 = lwa_lips-charg.
              lv_cursor = 'GV_CART1'.
              CLEAR: gv_cart2, gv_cart2_qty, lv_charg, lv_vemng .
              PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
            ENDIF.
            lwa_cart_all-barcode = lv_barcode_string.
            lwa_cart_all-exidv = lv_carton.
            lwa_cart_all-lfimg = lv_vemng.
            APPEND lwa_cart_all TO lt_cart_all.
            CLEAR  lwa_cart_all.
          ENDIF.
        ELSE.
          SELECT
            venum,
            exidv,
            status
            UP TO 1 ROWS
        FROM vekp
        INTO @lwa_exidv
        WHERE zzold_hu = @gv_cart2.
          ENDSELECT.

          IF sy-subrc <> 0.
*Create Carton HU
            " Check batch in barcode string
            READ TABLE lt_return ASSIGNING <lfs_return>
            WITH KEY ai = '10'.
            IF sy-subrc = 0.
              lv_charg = <lfs_return>-value.
              IF lv_charg <> lwa_lips-charg.
                lv_msgno = '243'.
                lv_msgv1 = lv_charg.
                lv_msgv2 = lwa_lips-charg.
                lv_cursor = 'GV_CART1'.
                CLEAR: gv_cart2, gv_cart2_qty, lv_charg .
                PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
              ENDIF.
            ENDIF.
            " Check quantity in barcode string
            READ TABLE lt_return ASSIGNING <lfs_return>
            WITH KEY ai = '30'.
            IF sy-subrc = 0.
              lwa_cart_all-lfimg = <lfs_return>-quantity.
            ENDIF.
            lwa_cart_all-barcode = lv_barcode_string.
            APPEND lwa_cart_all TO lt_cart_all.
            CLEAR  lwa_cart_all.

          ELSE.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lwa_exidv-venum
              IMPORTING
                output = lwa_exidv-venum.

            SELECT vemng,
            matnr,
            charg,
            werks
           FROM vepo
           INTO TABLE @lt_vepo
           WHERE venum = @lwa_exidv-venum.

            LOOP AT lt_vepo ASSIGNING <lfs_vepo>.
              lv_vemng = <lfs_vepo>-vemng + lv_vemng.
              IF lv_charg IS INITIAL.
                lv_charg = <lfs_vepo>-charg.
              ENDIF.
              IF lv_werks IS INITIAL.
                lv_werks = <lfs_vepo>-werks.
              ENDIF.
              IF lv_matnr IS INITIAL.
                lv_matnr = <lfs_vepo>-matnr.
              ENDIF.
            ENDLOOP.

            CONCATENATE 'HU' lwa_exidv-venum INTO lv_objnr.
            SELECT * FROM husstat
              INTO TABLE @lt_husstat
              WHERE objnr = @lv_objnr.
            IF sy-subrc = 0
              AND lt_husstat IS NOT INITIAL.
              "Begin of BLOB New CR 03.08.2020
              IF lv_werks <> lwa_lips-werks AND lv_werks IN lt_werks_r
                AND lv_matnr = lwa_lips-matnr AND lv_charg = lwa_lips-charg.

                "Validate if the HU status is different than PSTD
                READ TABLE lt_husstat ASSIGNING <lfs_husstat1>
                WITH KEY stat = 'I0522' inact = space.
                IF sy-subrc <> 0.
                  lv_flg_allow = abap_true.
                ENDIF.

              ENDIF.
              IF lv_flg_allow = abap_false.
                "End of BLOB New CR 03.08.2020
                READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0522' inact = space.

                IF sy-subrc <> 0.
*                *********************************
                  READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0511' inact = space.
                  IF sy-subrc <> 0.
                    lv_cursor = 'GV_CART1'.
                    lv_msgno = '244'.
                    lv_msgv1 = lwa_exidv-exidv.
                    CLEAR: gv_cart2, gv_cart2_qty,lv_objnr, lt_husstat.
                    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                  ELSE.
                    READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0512' inact = space.
                    IF sy-subrc = 0.
                      lv_cursor = 'GV_CART1'.
                      lv_msgno = '244'.
                      lv_msgv1 = lwa_exidv-exidv.
                      CLEAR: gv_cart2, gv_cart2_qty,lv_objnr, lt_husstat.
                      PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.


            IF lv_charg <> lwa_lips-charg.
              lv_msgno = '243'.
              lv_msgv1 = lv_charg.
              lv_msgv2 = lwa_lips-charg.
              lv_cursor = 'GV_CART1'.
              CLEAR: gv_cart2, gv_cart2_qty, lv_charg, lv_vemng .
              PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
            ENDIF.
            lwa_cart_all-barcode = lv_barcode_string.
            lwa_cart_all-exidv = lwa_exidv-exidv.
            lwa_cart_all-lfimg = lv_vemng.
            APPEND lwa_cart_all TO lt_cart_all.
            CLEAR  lwa_cart_all.

          ENDIF.
        ENDIF.
      ENDIF.
    ELSEIF sy-subrc = gc_0.
      IF gv_gelatin EQ gv_tcode.
        lv_exidv = <lfs_cart_all>-exidv.
        IF sy-subrc EQ gc_0.
          lv_flag = abap_true.
          lv_msgno = '527'.
          lv_msgv1 = lv_exidv.
          lv_cursor = 'GV_CART1'.
          CLEAR: gv_cart2, gv_cart2_qty.
          PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
        ENDIF.
      ENDIF.
    ENDIF.
    CLEAR: lv_barcode_string, lt_return, v_label_type,ls_label_content, lv_exidv, lv_exidv1,
           lv_carton, lv_venum, lwa_cart_all, lwa_exidv , lv_vemng, lt_hu2[], lv_objnr, lt_husstat.
  ENDIF.


  IF gv_cart3 IS NOT INITIAL.
    CLEAR: lv_charg , lv_werks, lv_matnr, lv_flg_allow .
    READ TABLE lt_cart_all ASSIGNING <lfs_cart_all> WITH KEY barcode = gv_cart3.
    IF sy-subrc <> gc_0.
      lv_barcode_string = gv_cart3.
* Start of Insert by EICR 603155 Gelatin Scan sghosh1
      IF gv_gelatin EQ gv_tcode.
        READ TABLE lt_hu INTO lw_hu WITH KEY hu = gv_cart3 TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          gv_cart3_barcode = lv_barcode_string.
          CALL METHOD zcl_its_utility=>read_barcode_gelatin
            EXPORTING
              barcode         = lv_barcode_string
            IMPORTING
              it_hu           = lt_hu2
              o_label_content = ls_label_content
              type            = lv_label.
          IF sy-subrc EQ gc_0.
            lv_flag = abap_false.
            CLEAR: lv_exidv, lv_venum1.
            lv_exidv = ls_label_content-zzhu_exid.
            SELECT SINGLE venum
              INTO lv_venum1 FROM vekp
              WHERE exidv = lv_exidv.
            IF lv_venum1 IS INITIAL.
              READ TABLE lt_hu INTO lw_hu WITH KEY hu = lv_exidv TRANSPORTING NO FIELDS.
              IF sy-subrc <> gc_0.
                SELECT SINGLE hu_no FROM zlscan_detail INTO lv_exidv1 WHERE hu_no = lv_exidv.
                IF sy-subrc <> gc_0.
                  APPEND LINES OF lt_hu2[] TO lt_hu[].
                  APPEND LINES OF lt_hu2[] TO lt_hu1[].
                  APPEND LINES OF lt_hu2[] TO lt_hu4[].
                  lwa_cart_all-barcode = lv_barcode_string.
                  lwa_cart_all-exidv = ls_label_content-zzhu_exid.
                  lwa_cart_all-lfimg = ls_label_content-zzquantity.
                  lwa_cart_all-batch = ls_label_content-zzorigin_batch.
                  APPEND lwa_cart_all TO lt_cart_all.
                  CLEAR  lwa_cart_all.
                ELSE.
                  lv_flag = abap_true.
                  lv_msgno = '528'.
                  lv_cursor = ''.
                  lv_msgv1 = lv_exidv.
                  CLEAR: gv_cart1.
                  PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                  EXIT.
                ENDIF.
              ELSE.
                lv_flag = abap_true.
                lv_msgno = '527'.
                lv_cursor = ''.
                lv_msgv1 = lv_exidv.
                CLEAR: gv_cart1.
                PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                EXIT.
              ENDIF.
            ELSEIF lv_venum1 IS NOT INITIAL.
              lv_flag = abap_true.
              lv_msgno = '525'.
              lv_cursor = 'GV_CART2'.
              lv_msgv1 = lv_exidv.
              CLEAR: gv_cart3.
              PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
              EXIT.
            ENDIF.
          ELSE.
            CLEAR: gv_cart3.
            lv_msgno = sy-msgno.
            lv_msgv1 = lv_barcode_string.
            CONDENSE lv_msgv1.
            PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
          ENDIF.
        ENDIF.
* End of Insert by EICR 603155 Gelatin Scan sghosh1
      ELSE.
        CALL METHOD zcl_its_utility=>bar_code_translation_dfs
          EXPORTING
            i_bar_code_string = lv_barcode_string
            i_appid_type      = 'GS1'
*           i_su_label        = abap_true
*           iv_appid_type     =
          IMPORTING
            o_return          = lt_return
            o_label_type      = v_label_type
            o_label_content   = ls_label_content
          EXCEPTIONS
            illegal_bar_code  = 1
            conversion_error  = 2
            system_error      = 3
            numeric_error     = 4
            OTHERS            = 5.
        IF sy-subrc = 0.
          lv_carton = ls_label_content-zzhu_exid.
        ENDIF.
        IF lv_carton IS NOT INITIAL.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_carton
            IMPORTING
              output = lv_carton.
          SELECT venum status
            UP TO 1 ROWS
            FROM vekp
            INTO ( lv_venum , lv_status )
            WHERE exidv = lv_carton.
          ENDSELECT.
          IF sy-subrc <> 0.
            CLEAR: gv_cart3.
*            SET CURSOR FIELD 'GV_CART2'.
            lv_cursor = 'GV_CART2'.
            lv_msgno = '221'.
            PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
          ELSE.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lv_venum
              IMPORTING
                output = lv_venum.

            SELECT vemng,
              matnr,
              charg,
              werks
              FROM vepo
              INTO TABLE @lt_vepo
              WHERE venum = @lv_venum.

            LOOP AT lt_vepo ASSIGNING <lfs_vepo>.
              lv_vemng = <lfs_vepo>-vemng + lv_vemng.
              IF lv_charg IS INITIAL.
                lv_charg = <lfs_vepo>-charg.
              ENDIF.
              IF lv_werks IS INITIAL.
                lv_werks = <lfs_vepo>-werks.
              ENDIF.
              IF lv_matnr IS INITIAL.
                lv_matnr = <lfs_vepo>-matnr.
              ENDIF.
            ENDLOOP.

            CONCATENATE 'HU' lv_venum INTO lv_objnr.
            SELECT * FROM husstat
              INTO TABLE @lt_husstat
              WHERE objnr = @lv_objnr.
            IF sy-subrc = 0
              AND lt_husstat IS NOT INITIAL.
              "Begin of BLOB New CR 03.08.2020
              IF lv_werks <> lwa_lips-werks AND lv_werks IN lt_werks_r
                AND lv_matnr = lwa_lips-matnr AND lv_charg = lwa_lips-charg.

                "Validate if the HU status is different than PSTD
                READ TABLE lt_husstat ASSIGNING <lfs_husstat1>
                WITH KEY stat = 'I0522' inact = space.
                IF sy-subrc <> 0.
                  lv_flg_allow = abap_true.
                ENDIF.

              ENDIF.
              IF lv_flg_allow = abap_false.
                "End of BLOB New CR 03.08.2020
                READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0522' inact = space.

                IF sy-subrc <> 0.
*                *********************************
                  READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0511' inact = space.
                  IF sy-subrc <> 0.
                    lv_cursor = 'GV_CART2'.
                    lv_msgno = '244'.
                    lv_msgv1 = lv_carton.
                    CLEAR: gv_cart3, gv_cart3_qty,lv_objnr, lt_husstat.
                    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                  ELSE.
                    READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0512' inact = space.
                    IF sy-subrc = 0.
                      lv_cursor = 'GV_CART2'.
                      lv_msgno = '244'.
                      lv_msgv1 = lv_carton.
                      CLEAR: gv_cart3, gv_cart3_qty,lv_objnr, lt_husstat.
                      PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.


            IF lv_charg <> lwa_lips-charg.
              lv_msgno = '243'.
              lv_msgv1 = lv_charg.
              lv_msgv2 = lwa_lips-charg.
              lv_cursor = 'GV_CART2'.
              CLEAR: gv_cart3, gv_cart3_qty, lv_charg, lv_vemng .
              PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
            ENDIF.
            lwa_cart_all-barcode = lv_barcode_string.
            lwa_cart_all-exidv = lv_carton.
            lwa_cart_all-lfimg = lv_vemng.
            APPEND lwa_cart_all TO lt_cart_all.
            CLEAR  lwa_cart_all.
          ENDIF.
        ELSE.
          SELECT
            venum,
            exidv,
            status
            UP TO 1 ROWS
        FROM vekp
        INTO @lwa_exidv
        WHERE zzold_hu = @gv_cart3.
          ENDSELECT.
*        ENDSELECT.
          IF sy-subrc <> 0.
*Create Carton HU
            " Check batch in barcode string
            READ TABLE lt_return ASSIGNING <lfs_return>
            WITH KEY ai = '10'.
            IF sy-subrc = 0.
              lv_charg = <lfs_return>-value.
              IF lv_charg <> lwa_lips-charg.
                lv_msgno = '243'.
                lv_msgv1 = lv_charg.
                lv_msgv2 = lwa_lips-charg.
                lv_cursor = 'GV_CART2'.
                CLEAR: gv_cart3, gv_cart3_qty, lv_charg .
                PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
              ENDIF.
            ENDIF.
            " Check quantity in barcode string
            READ TABLE lt_return ASSIGNING <lfs_return>
            WITH KEY ai = '30'.
            IF sy-subrc = 0.
              lwa_cart_all-lfimg = <lfs_return>-quantity.
            ENDIF.
            lwa_cart_all-barcode = lv_barcode_string.
            APPEND lwa_cart_all TO lt_cart_all.
            CLEAR  lwa_cart_all.
          ELSE.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lwa_exidv-venum
              IMPORTING
                output = lwa_exidv-venum.

            SELECT
            vemng,
            matnr,
            charg,
            werks
           FROM vepo
           INTO TABLE @lt_vepo
           WHERE venum = @lwa_exidv-venum.

            LOOP AT lt_vepo ASSIGNING <lfs_vepo>.
              lv_vemng = <lfs_vepo>-vemng + lv_vemng.
              IF lv_charg IS INITIAL.
                lv_charg = <lfs_vepo>-charg.
              ENDIF.
              IF lv_werks IS INITIAL.
                lv_werks = <lfs_vepo>-werks.
              ENDIF.
              IF lv_matnr IS INITIAL.
                lv_matnr = <lfs_vepo>-matnr.
              ENDIF.
            ENDLOOP.

            CONCATENATE 'HU' lwa_exidv-venum INTO lv_objnr.
            SELECT * FROM husstat
              INTO TABLE @lt_husstat
              WHERE objnr = @lv_objnr.
            IF sy-subrc = 0
              AND lt_husstat IS NOT INITIAL.

              "Begin of BLOB New CR 03.08.2020
              IF lv_werks <> lwa_lips-werks AND lv_werks IN lt_werks_r
                AND lv_matnr = lwa_lips-matnr AND lv_charg = lwa_lips-charg.

                "Validate if the HU status is different than PSTD
                READ TABLE lt_husstat ASSIGNING <lfs_husstat1>
                WITH KEY stat = 'I0522' inact = space.
                IF sy-subrc <> 0.
                  lv_flg_allow = abap_true.
                ENDIF.

              ENDIF.
              IF lv_flg_allow = abap_false.
                "End of BLOB New CR 03.08.2020
                READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0522' inact = space.

                IF sy-subrc <> 0.
*                *********************************
                  READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0511' inact = space.
                  IF sy-subrc <> 0.
                    lv_cursor = 'GV_CART2'.
                    lv_msgno = '244'.
                    lv_msgv1 = lwa_exidv-exidv.
                    CLEAR: gv_cart3, gv_cart3_qty,lv_objnr, lt_husstat.
                    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                  ELSE.
                    READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0512' inact = space.
                    IF sy-subrc = 0.
                      lv_cursor = 'GV_CART2'.
                      lv_msgno = '244'.
                      lv_msgv1 = lwa_exidv-exidv.
                      CLEAR: gv_cart3, gv_cart3_qty,lv_objnr, lt_husstat.
                      PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.


            IF lv_charg <> lwa_lips-charg.
              lv_msgno = '243'.
              lv_msgv1 = lv_charg.
              lv_msgv2 = lwa_lips-charg.
              lv_cursor = 'GV_CART2'.
              CLEAR: gv_cart3, gv_cart3_qty, lv_charg, lv_vemng .
              PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
            ENDIF.
            lwa_cart_all-barcode = lv_barcode_string.
            lwa_cart_all-exidv = lwa_exidv-exidv.
            lwa_cart_all-lfimg = lv_vemng.
            APPEND lwa_cart_all TO lt_cart_all.
            CLEAR  lwa_cart_all.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSEIF sy-subrc = gc_0.
      IF gv_gelatin EQ gv_tcode.
        lv_exidv = <lfs_cart_all>-exidv.
        IF sy-subrc EQ gc_0.
          lv_flag = abap_true.
          lv_msgno = '527'.
          lv_msgv1 = lv_exidv.
          lv_cursor = 'GV_CART2'.
          CLEAR: gv_cart3, gv_cart3_qty.
          PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
        ENDIF.
      ENDIF.
    ENDIF.
    CLEAR: lv_barcode_string, lt_return, v_label_type,ls_label_content, lv_exidv, lv_exidv1,
           lv_carton, lv_venum, lwa_cart_all, lwa_exidv, lv_vemng, lt_hu2[],lv_objnr, lt_husstat.
  ENDIF.


  IF gv_cart4 IS NOT INITIAL.
    CLEAR: lv_charg , lv_werks, lv_matnr, lv_flg_allow.
    READ TABLE lt_cart_all ASSIGNING <lfs_cart_all> WITH KEY barcode = gv_cart4.
    IF sy-subrc <> 0.
      lv_barcode_string = gv_cart4.
* Start of Insert by EICR 603155 Gelatin Scan sghosh1
      IF gv_gelatin EQ gv_tcode.
        READ TABLE lt_hu INTO lw_hu WITH KEY hu = gv_cart4 TRANSPORTING NO FIELDS.
        IF sy-subrc <> gc_0.
          gv_cart4_barcode = lv_barcode_string.
          CALL METHOD zcl_its_utility=>read_barcode_gelatin
            EXPORTING
              barcode         = lv_barcode_string
            IMPORTING
              it_hu           = lt_hu2
              o_label_content = ls_label_content
              type            = lv_label.
          IF sy-subrc EQ gc_0.
            lv_flag = abap_false.
            CLEAR: lv_exidv, lv_venum1.
            lv_exidv = ls_label_content-zzhu_exid.
            SELECT SINGLE venum
              INTO lv_venum1 FROM vekp
              WHERE exidv = lv_exidv.
            IF lv_venum1 IS INITIAL.
              READ TABLE lt_hu INTO lw_hu WITH KEY hu = lv_exidv TRANSPORTING NO FIELDS.
              IF sy-subrc <> gc_0.
                SELECT SINGLE hu_no FROM zlscan_detail INTO lv_exidv1 WHERE hu_no = lv_exidv.
                IF sy-subrc <> gc_0.
                  APPEND LINES OF lt_hu2[] TO lt_hu[].
                  APPEND LINES OF lt_hu2[] TO lt_hu1[].
                  APPEND LINES OF lt_hu2[] TO lt_hu4[].
                  lwa_cart_all-barcode = lv_barcode_string.
                  lwa_cart_all-exidv = ls_label_content-zzhu_exid.
                  lwa_cart_all-lfimg = ls_label_content-zzquantity.
                  lwa_cart_all-batch = ls_label_content-zzorigin_batch.
                  APPEND lwa_cart_all TO lt_cart_all.
                  CLEAR  lwa_cart_all.
                ELSE.
                  lv_flag = abap_true.
                  lv_msgno = '528'.
                  lv_cursor = ''.
                  lv_msgv1 = lv_exidv.
                  CLEAR: gv_cart1.
                  PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                  EXIT.
                ENDIF.
              ELSE.
                lv_flag = abap_true.
                lv_msgno = '527'.
                lv_cursor = ''.
                lv_msgv1 = lv_exidv.
                CLEAR: gv_cart1.
                PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                EXIT.
              ENDIF.
            ELSEIF lv_venum1 IS NOT INITIAL.
              lv_flag = abap_true.
              lv_msgno = '525'.
              lv_cursor = 'GV_CART3'.
              lv_msgv1 = lv_exidv.
              CLEAR: gv_cart4.
              PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
              EXIT.
            ENDIF.
          ELSE.
            CLEAR: gv_cart4.
            lv_msgno = sy-msgno.
            lv_msgv1 = lv_barcode_string.
            CONDENSE lv_msgv1.
            PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
          ENDIF.
        ENDIF.
* End of Insert by EICR 603155 Gelatin Scan sghosh1
      ELSE.
        CALL METHOD zcl_its_utility=>bar_code_translation_dfs
          EXPORTING
            i_bar_code_string = lv_barcode_string
            i_appid_type      = 'GS1'
*           i_su_label        = abap_true
*           iv_appid_type     =
          IMPORTING
            o_return          = lt_return
            o_label_type      = v_label_type
            o_label_content   = ls_label_content
          EXCEPTIONS
            illegal_bar_code  = 1
            conversion_error  = 2
            system_error      = 3
            numeric_error     = 4
            OTHERS            = 5.
        IF sy-subrc = 0.
          lv_carton = ls_label_content-zzhu_exid.
        ENDIF.
        IF lv_carton IS NOT INITIAL.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_carton
            IMPORTING
              output = lv_carton.
          SELECT venum status
            UP TO 1 ROWS
            FROM vekp
            INTO ( lv_venum , lv_status )
            WHERE exidv = lv_carton.
          ENDSELECT.
          IF sy-subrc <> 0.
            CLEAR: gv_cart4.
*            SET CURSOR FIELD 'GV_CART3'.
            lv_cursor = 'GV_CART3'.
            lv_msgno = '221'.
            PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
          ELSE.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lv_venum
              IMPORTING
                output = lv_venum.

            SELECT vemng,
              matnr,
              charg,
              werks
              FROM vepo
              INTO TABLE @lt_vepo
              WHERE venum = @lv_venum.

            LOOP AT lt_vepo ASSIGNING <lfs_vepo>.
              lv_vemng = <lfs_vepo>-vemng + lv_vemng.
              IF lv_charg IS INITIAL.
                lv_charg = <lfs_vepo>-charg.
              ENDIF.
              IF lv_werks IS INITIAL.
                lv_werks = <lfs_vepo>-werks.
              ENDIF.
              IF lv_matnr IS INITIAL.
                lv_matnr = <lfs_vepo>-matnr.
              ENDIF.
            ENDLOOP.

            CONCATENATE 'HU' lv_venum INTO lv_objnr.
            SELECT * FROM husstat
              INTO TABLE @lt_husstat
              WHERE objnr = @lv_objnr.
            IF sy-subrc = 0
              AND lt_husstat IS NOT INITIAL.
              "Begin of BLOB New CR 03.08.2020
              IF lv_werks <> lwa_lips-werks AND lv_werks IN lt_werks_r
                AND lv_matnr = lwa_lips-matnr AND lv_charg = lwa_lips-charg.

                "Validate if the HU status is different than PSTD
                READ TABLE lt_husstat ASSIGNING <lfs_husstat1>
                WITH KEY stat = 'I0522' inact = space.
                IF sy-subrc <> 0.
                  lv_flg_allow = abap_true.
                ENDIF.

              ENDIF.
              IF lv_flg_allow = abap_false.
                "End of BLOB New CR 03.08.2020
                READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0522' inact = space.

                IF sy-subrc <> 0.
*                *********************************
                  READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0511' inact = space.
                  IF sy-subrc <> 0.
                    lv_cursor = 'GV_CART3'.
                    lv_msgno = '244'.
                    lv_msgv1 = lv_carton.
                    CLEAR: gv_cart4, gv_cart4_qty,lv_objnr, lt_husstat.
                    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                  ELSE.
                    READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0512' inact = space.
                    IF sy-subrc = 0.
                      lv_cursor = 'GV_CART3'.
                      lv_msgno = '244'.
                      lv_msgv1 = lv_carton.
                      CLEAR: gv_cart4, gv_cart4_qty,lv_objnr, lt_husstat.
                      PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.


            IF lv_charg <> lwa_lips-charg.
              lv_msgno = '243'.
              lv_msgv1 = lv_charg.
              lv_msgv2 = lwa_lips-charg.
              lv_cursor = 'GV_CART3'.
              CLEAR: gv_cart4, gv_cart4_qty, lv_charg, lv_vemng .
              PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
            ENDIF.
            lwa_cart_all-barcode = lv_barcode_string.
            lwa_cart_all-exidv = lv_carton.
            lwa_cart_all-lfimg = lv_vemng.
            APPEND lwa_cart_all TO lt_cart_all.
            CLEAR  lwa_cart_all.
          ENDIF.
        ELSE.
          SELECT
            venum,
            exidv,
            status
            UP TO 1 ROWS
        FROM vekp
        INTO @lwa_exidv
        WHERE zzold_hu = @gv_cart4.
          ENDSELECT.

          IF sy-subrc <> 0.
*Create Carton HU
            " Check batch in barcode string
            READ TABLE lt_return ASSIGNING <lfs_return>
            WITH KEY ai = '10'.
            IF sy-subrc = 0.
              lv_charg = <lfs_return>-value.
              IF lv_charg <> lwa_lips-charg.
                lv_msgno = '243'.
                lv_msgv1 = lv_charg.
                lv_msgv2 = lwa_lips-charg.
                lv_cursor = 'GV_CART3'.
                CLEAR: gv_cart4, gv_cart4_qty, lv_charg .
                PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
              ENDIF.
            ENDIF.
            " Check quantity in barcode string
            READ TABLE lt_return ASSIGNING <lfs_return>
            WITH KEY ai = '30'.
            IF sy-subrc = 0.
              lwa_cart_all-lfimg = <lfs_return>-quantity.
            ENDIF.
            lwa_cart_all-barcode = lv_barcode_string.
            APPEND lwa_cart_all TO lt_cart_all.
            CLEAR  lwa_cart_all.

          ELSE.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lwa_exidv-venum
              IMPORTING
                output = lwa_exidv-venum.

            SELECT vemng,
             matnr,
             charg,
             werks
           FROM vepo
           INTO TABLE @lt_vepo
           WHERE venum = @lwa_exidv-venum.
            LOOP AT lt_vepo ASSIGNING <lfs_vepo>.
              lv_vemng = <lfs_vepo>-vemng + lv_vemng.
              IF lv_charg IS INITIAL.
                lv_charg = <lfs_vepo>-charg.
              ENDIF.
              IF lv_werks IS INITIAL.
                lv_werks = <lfs_vepo>-werks.
              ENDIF.
              IF lv_matnr IS INITIAL.
                lv_matnr = <lfs_vepo>-matnr.
              ENDIF.
            ENDLOOP.

            CONCATENATE 'HU' lwa_exidv-venum INTO lv_objnr.
            SELECT * FROM husstat
              INTO TABLE @lt_husstat
              WHERE objnr = @lv_objnr.
            IF sy-subrc = 0
              AND lt_husstat IS NOT INITIAL.
              "Begin of BLOB New CR 03.08.2020
              IF lv_werks <> lwa_lips-werks AND lv_werks IN lt_werks_r
                AND lv_matnr = lwa_lips-matnr AND lv_charg = lwa_lips-charg.

                "Validate if the HU status is different than PSTD
                READ TABLE lt_husstat ASSIGNING <lfs_husstat1>
                WITH KEY stat = 'I0522' inact = space.
                IF sy-subrc <> 0.
                  lv_flg_allow = abap_true.
                ENDIF.

              ENDIF.
              IF lv_flg_allow = abap_false.
                "End of BLOB New CR 03.08.2020
                READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0522' inact = space.

                IF sy-subrc <> 0.
*                *********************************
                  READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0511' inact = space.
                  IF sy-subrc <> 0.
                    lv_cursor = 'GV_CART3'.
                    lv_msgno = '244'.
                    lv_msgv1 = lwa_exidv-exidv.
                    CLEAR: gv_cart4, gv_cart4_qty,lv_objnr, lt_husstat.
                    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                  ELSE.
                    READ TABLE lt_husstat ASSIGNING <lfs_husstat>
                WITH KEY stat = 'I0512' inact = space.
                    IF sy-subrc = 0.
                      lv_cursor = 'GV_CART3'.
                      lv_msgno = '244'.
                      lv_msgv1 = lwa_exidv-exidv.
                      CLEAR: gv_cart4, gv_cart4_qty,lv_objnr, lt_husstat.
                      PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.


            IF lv_charg <> lwa_lips-charg.
              lv_msgno = '243'.
              lv_msgv1 = lv_charg.
              lv_msgv2 = lwa_lips-charg.
              lv_cursor = 'GV_CART3'.
              CLEAR: gv_cart4, gv_cart4_qty, lv_charg, lv_vemng .
              PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
            ENDIF.
            lwa_cart_all-barcode = lv_barcode_string.
            lwa_cart_all-exidv = lwa_exidv-exidv.
            lwa_cart_all-lfimg = lv_vemng.
            APPEND lwa_cart_all TO lt_cart_all.
            CLEAR  lwa_cart_all.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSEIF sy-subrc = gc_0.
      IF gv_gelatin EQ gv_tcode.
        lv_exidv = <lfs_cart_all>-exidv.
        IF sy-subrc EQ gc_0.
          lv_flag = abap_true.
          lv_msgno = '527'.
          lv_msgv1 = lv_exidv.
          lv_cursor = 'GV_CART3'.
          CLEAR: gv_cart4, gv_cart4_qty.
          PERFORM error_message USING gc_msgid1 lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
        ENDIF.
      ENDIF.
    ENDIF.
    CLEAR: lv_barcode_string, lt_return, v_label_type,ls_label_content, lv_exidv, lv_exidv1,
           lv_carton, lv_venum, lwa_cart_all, lwa_exidv, lv_vemng, lt_hu2[], lv_objnr, lt_husstat.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_LIPS>  text
*----------------------------------------------------------------------*
FORM authority_check  USING  p_lips TYPE lty_lips.

  DATA :lv_auth_msg TYPE c LENGTH 100,
        lv_lgnum    TYPE lgnum,
        lv_lgtyp    TYPE lgtyp,
        lv_vbeln    TYPE vbeln_vl,
        lv_posnr    TYPE posnr_vl,
        lc_e        TYPE c VALUE 'E'.

*Check Warehouse Number and Storage Type for entered delivery is present in LIPS
  CLEAR: lv_lgnum,
  lv_lgtyp,
  lv_vbeln,
  lv_posnr
  .
  IF p_lips-lgnum IS NOT INITIAL AND p_lips-lgtyp IS NOT INITIAL.
    lv_lgnum = p_lips-lgnum.
    lv_lgtyp = p_lips-lgtyp.
  ELSE.
*Get the original delivery number for this return delivery.
    SELECT
      vbelv
      posnv
      FROM vbfa
      INTO ( lv_vbeln, lv_posnr )
            UP TO 1 ROWS
      WHERE
      vbeln = zsits_scan_dynp-zzoutb_delivery
      AND posnn = p_lips-posnr
      AND vbtyp_v = 'J'.
    ENDSELECT.
    IF sy-subrc = 0.
      SELECT
        lgnum
        lgtyp
        FROM lips
        INTO ( lv_lgnum , lv_lgtyp )
         UP TO 1 ROWS
        WHERE
        vbeln = lv_vbeln
        AND posnr = lv_posnr.
      ENDSELECT.
    ENDIF.
  ENDIF.

  IF lv_lgnum IS NOT INITIAL AND lv_lgtyp IS NOT INITIAL.
    CLEAR: lv_auth_msg.
    AUTHORITY-CHECK OBJECT 'L_LGNUM'
      ID 'LGNUM' FIELD lv_lgnum
      ID 'LGTYP' FIELD lv_lgtyp.
    IF sy-subrc <> 0.
      CONCATENATE text-e01 lv_lgnum text-e02 lv_lgtyp INTO lv_auth_msg SEPARATED BY space.
      MESSAGE lv_auth_msg TYPE lc_e.
    ENDIF.
  ENDIF.

ENDFORM.
FORM duplicate_check.

  IF gv_cart1 IS NOT INITIAL
    AND gv_cart2 IS NOT INITIAL
    AND gv_cart1 = gv_cart2.
    CLEAR: gv_cart2, gv_cart2_qty.
    DATA(lv_flg_duplicate) = abap_true.
    lv_cursor = 'GV_CART1'.
    lv_msgv1 = gv_cart2.
  ENDIF.

  IF gv_cart1 IS NOT INITIAL
    AND gv_cart3 IS NOT INITIAL
    AND gv_cart1 = gv_cart3
    AND lv_flg_duplicate = abap_false.
    CLEAR: gv_cart3, gv_cart3_qty.
    lv_flg_duplicate = abap_true.
    lv_cursor = 'GV_CART2'.
    lv_msgv1 = gv_cart3.
  ENDIF.

  IF gv_cart1 IS NOT INITIAL
    AND gv_cart4 IS NOT INITIAL
    AND gv_cart1 = gv_cart4
    AND lv_flg_duplicate = abap_false.
    CLEAR: gv_cart4, gv_cart4_qty.
    lv_flg_duplicate = abap_true.
    lv_cursor = 'GV_CART3'.
    lv_msgv1 = gv_cart4.
  ENDIF.

  IF gv_cart2 IS NOT INITIAL
    AND gv_cart3 IS NOT INITIAL
    AND gv_cart2 = gv_cart3
    AND lv_flg_duplicate = abap_false.
    CLEAR: gv_cart3, gv_cart3_qty.
    lv_flg_duplicate = abap_true.
    lv_cursor = 'GV_CART2'.
    lv_msgv1 = gv_cart3.
  ENDIF.

  IF gv_cart2 IS NOT INITIAL
    AND gv_cart4 IS NOT INITIAL
    AND gv_cart2 = gv_cart4
    AND lv_flg_duplicate = abap_false.
    CLEAR: gv_cart4, gv_cart4_qty.
    lv_flg_duplicate = abap_true.
    lv_cursor = 'GV_CART3'.
    lv_msgv1 = gv_cart4.
  ENDIF.

  IF gv_cart3 IS NOT INITIAL
    AND gv_cart4 IS NOT INITIAL
    AND gv_cart3 = gv_cart4
    AND lv_flg_duplicate = abap_false.
    CLEAR: gv_cart4, gv_cart4_qty.
    lv_flg_duplicate = abap_true.
    lv_cursor = 'GV_CART3'.
    lv_msgv1 = gv_cart4.
  ENDIF.

  IF lv_flg_duplicate = abap_false
 AND li_hu_disp IS NOT INITIAL.

    DATA(lv_in) = lv_indx.
    lv_in = lv_in - 1.
    DATA(lv_ind) = lv_in.

    DO lv_in TIMES.

      READ TABLE li_hu_disp ASSIGNING FIELD-SYMBOL(<lfs_hu_disp>) INDEX lv_ind.
      IF sy-subrc = 0.
*        IF gv_cart1 = <lfs_hu_disp>-hu1.

        IF ( gv_cart1 IS NOT INITIAL
         AND <lfs_hu_disp>-hu1 IS NOT INITIAL
         AND gv_cart1 = <lfs_hu_disp>-hu1
         AND lv_flg_duplicate = abap_false )
          OR ( gv_cart1 IS NOT INITIAL
         AND <lfs_hu_disp>-hu2 IS NOT INITIAL
         AND gv_cart1 = <lfs_hu_disp>-hu2
         AND lv_flg_duplicate = abap_false )
          OR ( gv_cart1 IS NOT INITIAL
         AND <lfs_hu_disp>-hu3 IS NOT INITIAL
         AND gv_cart1 = <lfs_hu_disp>-hu3
         AND lv_flg_duplicate = abap_false )
          OR ( gv_cart1 IS NOT INITIAL
         AND <lfs_hu_disp>-hu4 IS NOT INITIAL
         AND gv_cart1 = <lfs_hu_disp>-hu4
         AND lv_flg_duplicate = abap_false ).
          CLEAR: gv_cart1, gv_cart1_qty.
          lv_flg_duplicate = abap_true.
          lv_cursor = ''.
          lv_msgv1 = gv_cart1.
          EXIT.
        ENDIF.

*        IF gv_cart1 IS NOT INITIAL
*         AND <lfs_hu_disp>-hu2 IS NOT INITIAL
*         AND gv_cart1 = <lfs_hu_disp>-hu2
*         AND lv_flg_duplicate = abap_false.
*          CLEAR: gv_cart1, gv_cart1_qty.
*          lv_flg_duplicate = abap_true.
*          lv_cursor = ''.
*          lv_msgv1 = gv_cart1.
*          EXIT.
*        ENDIF.
*
*        IF gv_cart1 IS NOT INITIAL
*         AND <lfs_hu_disp>-hu3 IS NOT INITIAL
*         AND gv_cart1 = <lfs_hu_disp>-hu3
*         AND lv_flg_duplicate = abap_false.
*          CLEAR: gv_cart1, gv_cart1_qty.
*          lv_flg_duplicate = abap_true.
*          lv_cursor = ''.
*          lv_msgv1 = gv_cart1.
*          EXIT.
*        ENDIF.
*
*        IF gv_cart1 IS NOT INITIAL
*         AND <lfs_hu_disp>-hu4 IS NOT INITIAL
*         AND gv_cart1 = <lfs_hu_disp>-hu4
*         AND lv_flg_duplicate = abap_false.
*          CLEAR: gv_cart1, gv_cart1_qty.
*          lv_flg_duplicate = abap_true.
*          lv_cursor = ''.
*          lv_msgv1 = gv_cart1.
*          EXIT.
*        ENDIF.

*        ELSEIF gv_cart2 = <lfs_hu_disp>-hu2.

        IF ( gv_cart2 IS NOT INITIAL
           AND <lfs_hu_disp>-hu1 IS NOT INITIAL
           AND gv_cart2 = <lfs_hu_disp>-hu1
           AND lv_flg_duplicate = abap_false )
          OR ( gv_cart2 IS NOT INITIAL
        AND <lfs_hu_disp>-hu2 IS NOT INITIAL
          AND gv_cart2 = <lfs_hu_disp>-hu2
          AND lv_flg_duplicate = abap_false )
          OR ( gv_cart2 IS NOT INITIAL
        AND <lfs_hu_disp>-hu3 IS NOT INITIAL
          AND gv_cart2 = <lfs_hu_disp>-hu3
          AND lv_flg_duplicate = abap_false )
          OR ( gv_cart2 IS NOT INITIAL
        AND <lfs_hu_disp>-hu4 IS NOT INITIAL
          AND gv_cart2 = <lfs_hu_disp>-hu4
          AND lv_flg_duplicate = abap_false ).
          CLEAR: gv_cart2, gv_cart2_qty.
          lv_flg_duplicate = abap_true.
          lv_cursor = 'GV_CART1'.
          lv_msgv1 = gv_cart2.
          EXIT.
        ENDIF.

*        IF gv_cart2 IS NOT INITIAL
*        AND <lfs_hu_disp>-hu2 IS NOT INITIAL
*          AND gv_cart2 = <lfs_hu_disp>-hu2
*          AND lv_flg_duplicate = abap_false .
*          CLEAR: gv_cart2, gv_cart2_qty.
*          lv_flg_duplicate = abap_true.
*          lv_cursor = 'GV_CART1'.
*          lv_msgv1 = gv_cart2.
*          EXIT.
*        ENDIF.

*        ELSEIF gv_cart3 = <lfs_hu_disp>-hu3.

        IF ( gv_cart3 IS NOT INITIAL
          AND <lfs_hu_disp>-hu1 IS NOT INITIAL
          AND gv_cart3 = <lfs_hu_disp>-hu1
          AND lv_flg_duplicate = abap_false )
          OR ( gv_cart3 IS NOT INITIAL
          AND <lfs_hu_disp>-hu2 IS NOT INITIAL
          AND gv_cart3 = <lfs_hu_disp>-hu2
          AND lv_flg_duplicate = abap_false )
          OR ( gv_cart3 IS NOT INITIAL
          AND <lfs_hu_disp>-hu3 IS NOT INITIAL
          AND gv_cart3 = <lfs_hu_disp>-hu3
          AND lv_flg_duplicate = abap_false )
          OR ( gv_cart3 IS NOT INITIAL
          AND <lfs_hu_disp>-hu4 IS NOT INITIAL
          AND gv_cart3 = <lfs_hu_disp>-hu4
          AND lv_flg_duplicate = abap_false ).
          CLEAR: gv_cart3, gv_cart3_qty.
          lv_flg_duplicate = abap_true.
          lv_cursor = 'GV_CART2'.
          lv_msgv1 = gv_cart3.
          EXIT.
        ENDIF.

*        ELSEIF gv_cart4 = <lfs_hu_disp>-hu4.

        IF ( gv_cart4 IS NOT INITIAL
          AND <lfs_hu_disp>-hu1 IS NOT INITIAL
          AND  gv_cart4 = <lfs_hu_disp>-hu1
          AND lv_flg_duplicate = abap_false )
          OR ( gv_cart4 IS NOT INITIAL
          AND <lfs_hu_disp>-hu2 IS NOT INITIAL
          AND  gv_cart4 = <lfs_hu_disp>-hu2
          AND lv_flg_duplicate = abap_false )
          OR ( gv_cart4 IS NOT INITIAL
          AND <lfs_hu_disp>-hu3 IS NOT INITIAL
          AND  gv_cart4 = <lfs_hu_disp>-hu3
          AND lv_flg_duplicate = abap_false )
          OR ( gv_cart4 IS NOT INITIAL
          AND <lfs_hu_disp>-hu4 IS NOT INITIAL
          AND  gv_cart4 = <lfs_hu_disp>-hu4
          AND lv_flg_duplicate = abap_false ).
          CLEAR: gv_cart4, gv_cart4_qty.
          lv_flg_duplicate = abap_true.
          lv_cursor = 'GV_CART3'.
          lv_msgv1 = gv_cart4.
          EXIT.
        ENDIF.

**        ENDIF.
      ENDIF.
      lv_ind = lv_ind - 1.

    ENDDO.
  ENDIF.

  IF lv_flg_duplicate = abap_true.
    lv_msgno = '248'.
    lv_flg_duplicate = abap_false.
    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
  ENDIF.

ENDFORM.

FORM status_to_phex USING pv_objnr TYPE j_objnr
                          pv_venum TYPE venum
                          pv_carton TYPE exidv
                          pv_status TYPE hu_status
                 CHANGING pt_husstat TYPE husstat_t.

  DATA: ls_venum     TYPE hum_venum,
        lt_venum     TYPE hum_venum_t,
        ls_newvalues TYPE hum_update_header,
        lt_newvalues TYPE hum_update_header_t,
        lt_ret       TYPE huitem_messages_t,
        lt_hustobj   TYPE vses_t_hustobj,
        lt_hustatus  TYPE vses_t_hustatus,
        ls_hustatus  TYPE vses_s_hustatus.

  "Validate if the HU status is different than PSTD
  READ TABLE pt_husstat ASSIGNING FIELD-SYMBOL(<lfs_husstat1>)
  WITH KEY stat = 'I0522' inact = space.
  IF sy-subrc <> 0.

    "change the status to PHEX
    READ TABLE pt_husstat ASSIGNING FIELD-SYMBOL(<lfs_husstat2>)
    WITH KEY stat = 'I0511'.
    IF sy-subrc = 0.
      IF <lfs_husstat2>-inact = abap_true.
        ls_hustatus-objnr = pv_objnr.
        ls_hustatus-stat = 'I0511'.
        ls_hustatus-inact = space.
        ls_hustatus-mod = 'U'.
        APPEND ls_hustatus TO lt_hustatus.
      ENDIF.
    ELSE.
      ls_hustatus-objnr = pv_objnr.
      ls_hustatus-stat = 'I0511'.
      ls_hustatus-inact = space.
      ls_hustatus-mod = 'I'.
      APPEND ls_hustatus TO lt_hustatus.
    ENDIF.

    CLEAR ls_hustatus.
    LOOP AT pt_husstat ASSIGNING FIELD-SYMBOL(<lfs_husstat3>)
      WHERE stat(1) = 'I' AND inact = space.
      IF <lfs_husstat3>-stat <> 'I0511'.
        ls_hustatus-objnr = pv_objnr.
        ls_hustatus-stat = <lfs_husstat3>-stat.
        ls_hustatus-inact = abap_true.
        ls_hustatus-mod = 'U'.
        APPEND ls_hustatus TO lt_hustatus.
        CLEAR ls_hustatus.
      ENDIF.
    ENDLOOP.

    IF lt_hustatus IS NOT INITIAL.
      CALL FUNCTION 'HU_STATUS_UPDATE'
        EXPORTING
          it_hustatus = lt_hustatus
          it_hustobj  = lt_hustobj.
    ENDIF.

    IF pv_status <> '0010'.
      "change VEKP-STATUS to '0010'
      ls_venum-venum = pv_venum.
      APPEND ls_venum TO lt_venum.
      CLEAR ls_venum.
      CALL FUNCTION 'V51P_FILL_GT'
        EXPORTING
          it_venum    = lt_venum
        IMPORTING
          et_messages = lt_ret
        EXCEPTIONS
          hu_locked   = 1
          no_hu_found = 2
          fatal_error = 3
          OTHERS      = 4.
      IF sy-subrc = 0.
        ls_newvalues-hdl_unit_itid = pv_venum.
        ls_newvalues-hdl_unit_exid = pv_carton.
        ls_newvalues-field_name = 'STATUS'.
        ls_newvalues-field_value = '0010'.
        APPEND ls_newvalues TO lt_newvalues.
        CLEAR: ls_newvalues , lt_ret.

        CALL FUNCTION 'HU_HEADER_UPDATE'
          EXPORTING
            it_new_values = lt_newvalues
          IMPORTING
            et_messages   = lt_ret
          EXCEPTIONS
            not_possible  = 1
            OTHERS        = 2.
        IF sy-subrc = 0.
          CALL FUNCTION 'HU_PACKING_UPDATE'
            EXPORTING
              if_synchron = abap_true.

        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR pt_husstat.
    SELECT * FROM husstat
              INTO TABLE @pt_husstat
              WHERE objnr = @pv_objnr.
  ENDIF.
  CLEAR: lt_hustatus, lt_hustobj, lt_venum, lt_ret, lt_newvalues.
ENDFORM.

FORM get_zvv_param CHANGING pt_werks_r TYPE tt_werks_r.

  TYPES: BEGIN OF ts_werks,
           werks TYPE werks_d,
         END OF ts_werks.

  DATA: lt_werks     TYPE TABLE OF ts_werks,
        lt_werks_all TYPE TABLE OF ts_werks,
        ls_param     TYPE zvv_param,
        ls_werks     TYPE ts_werks,
        ls_werks_r   TYPE ts_werks_r.

  SELECT SINGLE * FROM zvv_param
                INTO ls_param
                WHERE lookup_name    = 'ZZ_BLOB_SCAN_PLANT' AND
                      vkorg          = space         AND
                      vtweg          = space         AND
                      spart          = space         AND
                      indicator1     = 'X'.

  IF sy-subrc = 0.
    REFRESH: lt_werks_all.
    IF NOT ls_param-value1 IS INITIAL.
      REFRESH lt_werks.
      SPLIT ls_param-value1 AT ',' INTO TABLE lt_werks.
      APPEND LINES OF lt_werks TO lt_werks_all.
    ENDIF.
    IF NOT ls_param-value2 IS INITIAL.
      REFRESH lt_werks.
      SPLIT ls_param-value2 AT ',' INTO TABLE lt_werks.
      APPEND LINES OF lt_werks TO lt_werks_all.
    ENDIF.
    IF NOT ls_param-value3 IS INITIAL.
      REFRESH lt_werks.
      SPLIT ls_param-value3 AT ',' INTO TABLE lt_werks.
      APPEND LINES OF lt_werks TO lt_werks_all.
    ENDIF.

    LOOP AT lt_werks_all INTO ls_werks.
      ls_werks_r-sign = 'I'.
      ls_werks_r-option = 'EQ'.
      ls_werks_r-low = ls_werks-werks.
      APPEND ls_werks_r TO pt_werks_r.
      CLEAR ls_werks_r.
    ENDLOOP.
  ENDIF.

ENDFORM.
