*----------------------------------------------------------------------*
***INCLUDE MZPPE0163_WMPGIF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FRM_USER_COMMAND
*&---------------------------------------------------------------------*

************************************************************************
* VERSION CONTROL (Most recent on top):
* DATE           AUTHOR     TR
************************************************************************
FORM frm_user_command .

  DATA: lv_code  TYPE sy-ucomm,
        lv_dummy TYPE string,
        lv_subrc TYPE i.

  IF iv_validation_fail = abap_true.

    RETURN.

  ELSE.

    lv_code = ok_code.
    CLEAR ok_code.

    CASE lv_code.
      WHEN zcl_its_utility=>gc_okcode_newtran.
        CALL TRANSACTION 'ZMDE'.
      WHEN 'BACK'.
        CALL FUNCTION 'DEQUEUE_ALL'
          EXPORTING
            _synchron = 'X'.
        PERFORM frm_clear_screen_fields.
        SET SCREEN 9100.
      WHEN 'CLEAR'.
        PERFORM frm_clear_screen_fields.

      WHEN 'PROC'.
      WHEN 'SAVE'.
        lv_subrc = zcl_its_utility=>authority_check_dfs( iv_plant = x_profile-zzwerks
                                                         iv_move_type = zcl_its_utility=>gc_gm_type_261 ).
        IF lv_subrc <> 0.
          PERFORM frm_message_add USING zcl_its_utility=>gc_objid_proc
                                        zsits_scan_dynp-zzprocord
                                        abap_true.
          RETURN.
        ENDIF.
*   Case 1    If HU quantity not changed Just assign HU to Proc Order, the post Goods issue
        IF zsits_scan_dynp-zzpallet IS NOT INITIAL AND v_label_type = zcl_its_utility=>gc_label_hu." AND v_unpack IS INITIAL.
          PERFORM process_hu_pgi.

*   Case 2    If HU Quantity Changed, then Unpack HU to Partner SL, and call Goods issue BAPI to Post Goods movement

*    Case 3  If scanned label is Material, then call BAPI to post goods movement
        ELSEIF zsits_scan_dynp-zzmaterial IS NOT INITIAL AND
          ( v_label_type = zcl_its_utility=>gc_label_mat_batch
          OR v_label_type = zcl_its_utility=>gc_label_mat_nob ).
*       Material goods issue
          PERFORM process_mat_pgi.
        ENDIF.
      WHEN 'CHANGEQTY'.
*        Check if use has authorization to change the Quantity
        CLEAR v_changeqty.

        v_changeqty = 'X'.
    ENDCASE.

  ENDIF.

ENDFORM.                    " FRM_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  FRM_INIT_LOG
*&---------------------------------------------------------------------*
FORM frm_init_log .

  IF io_log IS INITIAL.
    CREATE OBJECT io_log
      EXPORTING
        iv_scan_code = sy-tcode.
  ENDIF.

ENDFORM.                    " FRM_INIT_LOG

*&---------------------------------------------------------------------*
*&      Form  FRM_CURSOR_DETERMINE
*&---------------------------------------------------------------------*
FORM frm_cursor_determine .
* if validation faiule, the cursor should be processed already. not need
* to
  CHECK iv_validation_fail = abap_false.

  GET CURSOR FIELD iv_cursor_field.

  CASE iv_cursor_field.
    WHEN 'ZSITS_SCAN_DYNP-ZZPROCORD'.
      iv_cursor_field = 'BTN_SAVE'.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " FRM_CURSOR_DETERMINE
*&---------------------------------------------------------------------*
*&      Form  FRM_GET_USER_PROFILE
*&---------------------------------------------------------------------*
FORM frm_get_user_profile .

  IF x_profile IS INITIAL.

    CALL METHOD zcl_its_utility=>get_user_profile
      RECEIVING
        rs_user_profile = x_profile.
  ENDIF.

ENDFORM.                    " FRM_GET_USER_PROFILE
*&---------------------------------------------------------------------*
*&      Form  add_label_type
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_LABEL_TYPE   text
*      <--CT_LABEL_RANGE  text
*----------------------------------------------------------------------*
FORM add_label_type  USING    uv_label_type  TYPE zdits_label_type
                     CHANGING ct_label_range TYPE ztlabel_type_range.

  DATA: lwa_label_range LIKE LINE OF ct_label_range.

  lwa_label_range-sign   = 'I'.
  lwa_label_range-zoption = 'EQ'.
  lwa_label_range-low    = uv_label_type.
  APPEND lwa_label_range TO ct_label_range.
ENDFORM.                    " ADD_LABEL_TYPE
*&---------------------------------------------------------------------*
*&      Form  frm_message_add
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_OBJID   text
*      -->UV_CONTENT text
*      -->UV_ERR_FG  text
*----------------------------------------------------------------------*
FORM frm_message_add  USING    uv_objid   TYPE zzscan_objid
                               uv_content TYPE any
                               uv_err_fg  TYPE boolean.

  CALL METHOD io_log->log_message_add
    EXPORTING
      iv_object_id    = uv_objid
      iv_content      = uv_content
      iv_with_message = uv_err_fg.

  IF uv_err_fg = abap_true.
*-----Display error message
    CALL METHOD zcl_its_utility=>message_display( ).
  ENDIF.

ENDFORM.                    " FRM_MESSAGE_ADD
*&---------------------------------------------------------------------*
*&      Form  FILL_SCREEN_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_screen_fields USING iv_type TYPE zdits_label_type.

  DATA: lwa_hu_item TYPE bapihuitem,
        lwa_su_item TYPE lqua.
  CASE iv_type.
    WHEN zcl_its_utility=>gc_label_hu.

      IF x_label_content-hu_content-hu_content IS NOT INITIAL.
*   The assumption is that only one material is packed in the handling unit
        READ TABLE x_label_content-hu_content-hu_content INTO lwa_hu_item INDEX 1.
      ENDIF.

      IF x_label_content-su_content-su_item IS NOT INITIAL.
        READ TABLE x_label_content-su_content-su_item INTO lwa_su_item INDEX 1.
      ENDIF.
      zsits_scan_dynp-zzpallet =
      zsits_scan_dynp-zzbarcode = x_label_content-zzhu_exid.
      zsits_scan_dynp-zzmaterial =   lwa_hu_item-material.
      zsits_scan_dynp-zzbatch = lwa_hu_item-batch.
      zsits_scan_dynp-zzsloc = lwa_hu_item-stge_loc.
      zsits_pgitopo-zzmeins = lwa_hu_item-base_unit_qty.
      zsits_pgitopo-zzqty  = lwa_hu_item-pack_qty.

    WHEN zcl_its_utility=>gc_label_mat_batch OR zcl_its_utility=>gc_label_mat_nob.
      CLEAR: zsits_scan_dynp-zzbarcode.
      zsits_scan_dynp-zzmaterial =   x_label_content-zzmatnr.
      zsits_scan_dynp-zzbatch = x_label_content-zzbatch.
      zsits_scan_dynp-zzsloc = lwa_hu_item-stge_loc.
      zsits_pgitopo-zzmeins = lwa_hu_item-base_unit_qty.
      zsits_pgitopo-zzqty  = x_label_content-zzquantity.
      PERFORM frm_get_resb_data .

    WHEN OTHERS.
  ENDCASE.

  IF zsits_scan_dynp-zzmaterial IS NOT INITIAL.
* Get material description
    SELECT SINGLE maktx
    FROM makt INTO zsits_scan_dynp-zzlabel
    WHERE matnr = zsits_scan_dynp-zzmaterial
      AND spras = sy-langu.
  ENDIF.
  PERFORM convert_output CHANGING zsits_scan_dynp-zzmaterial.
  PERFORM convert_output CHANGING zsits_scan_dynp-zzbarcode.
ENDFORM.                    " FILL_SCREEN_FIELDS
*&---------------------------------------------------------------------*
*&      Form  CONVERT_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_STRING  text
*----------------------------------------------------------------------*
FORM convert_output  CHANGING cv_string.
*  Convert data to output format
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = cv_string
    IMPORTING
      output = cv_string.
ENDFORM.                    " CONVERT_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  convert_input
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--CV_STRING  text
*----------------------------------------------------------------------*
FORM convert_input  CHANGING cv_string.
*  Convert data to output format
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = cv_string
    IMPORTING
      output = cv_string.
ENDFORM.                    "convert_input
*&---------------------------------------------------------------------*
*&      Form  FRM_GET_RESB_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_get_resb_data .
  DATA:lv_aufnr TYPE aufnr,
       lit_resb TYPE TABLE OF resb,
       lwa_resb LIKE LINE OF lit_resb,
       lv_rsnum TYPE rsnum,
       lv_dummy TYPE string ##needed.                     "
  lv_aufnr = zsits_scan_dynp-zzprocord.
  PERFORM convert_input CHANGING lv_aufnr.

  SELECT SINGLE rsnum INTO lv_rsnum
    FROM afko
    WHERE afko~aufnr = lv_aufnr.
  IF sy-subrc = 0.
    SELECT * INTO TABLE lit_resb
      FROM resb
      WHERE rsnum = lv_rsnum
        AND resb~matnr = zsits_scan_dynp-zzmaterial
        AND resb~charg = zsits_scan_dynp-zzbatch.
  ENDIF.

  LOOP AT lit_resb INTO lwa_resb WHERE lgort IS NOT INITIAL.
    CALL METHOD zcl_its_utility=>is_hu_managed_sloc
      EXPORTING
        iv_lgort   = lwa_resb-lgort
        iv_werks   = lwa_resb-werks
      EXCEPTIONS
        hu_managed = 1
        OTHERS     = 2.
    IF sy-subrc = 0.
      zsits_scan_dynp-zzsloc = lwa_resb-lgort.
      zsits_pgitopo-zzmeins = lwa_resb-meins.
    ENDIF.
  ENDLOOP.
  IF zsits_scan_dynp-zzsloc IS INITIAL OR sy-subrc <> 0.
    PERFORM convert_output CHANGING zsits_scan_dynp-zzmaterial.
    MESSAGE e017(zitsus) WITH zsits_scan_dynp-zzmaterial zsits_scan_dynp-zzbatch INTO lv_dummy.

* Add the response of action to the log (with message)
*----------------------------------------------------------------------
    CALL METHOD io_log->log_message_add
      EXPORTING
        iv_object_id    = zcl_its_utility=>gc_objid_proc
        iv_content      = zsits_scan_dynp-zzprocord
        iv_with_message = abap_true.

*  Display message
*----------------------------------------------------------------------
    CALL METHOD zcl_its_utility=>message_display( ).
    PERFORM frm_clear_screen_fields.
  ENDIF.
ENDFORM.                    " FRM_GET_RESB_DATA
*&---------------------------------------------------------------------*
*&      Form  FRM_CLEAR_SCREE_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_clear_screen_fields .
  CLEAR:
       zsits_scan_dynp-zzpallet,
       zsits_scan_dynp-zzmaterial,
       zsits_scan_dynp-zzlabel,
       zsits_pgitopo-zzqty,
       zsits_scan_dynp-zzsloc,
       zsits_pgitopo-zzmeins,
       zsits_scan_dynp-zzbatch,
       zsits_scan_dynp-zzsuccess_msg,
       zsits_scan_dynp-zzbarcode.
  CLEAR:v_changeqty,v_qtychanged.
ENDFORM.                    " FRM_CLEAR_SCREE_FIELDS
*&---------------------------------------------------------------------*
*&      Form  PROCESS_HU_PGI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_hu_pgi .
  DATA: lv_log_handler TYPE indx_srtfd,
        lx_blank_log   TYPE zsits_post_log,
        lv_aufnr       TYPE aufnr,
        lv_exidv       TYPE exidv_ob,
        lv_task        TYPE c LENGTH 8,
        lx_partqty     TYPE menge_d,
        lv_pallet      LIKE zsits_scan_dynp-zzpallet.


  CALL FUNCTION 'ZITS_ASSIGN_HU_TO_PROC_ORDER'
    EXPORTING
      iv_aufnr = zsits_scan_dynp-zzprocord
      iv_exidv = zsits_scan_dynp-zzpallet
    EXCEPTIONS
      error    = 1
      OTHERS   = 2.

  IF sy-subrc <> 0.
    PERFORM frm_message_add USING zcl_its_utility=>gc_objid_proc
                                  zsits_scan_dynp-zzprocord
                                  abap_true.
  ELSE.
*    Assign HU to Process Order successful.
*-----Create the log
    PERFORM convert_output CHANGING zsits_scan_dynp-zzpallet.
    CONCATENATE zcl_its_utility=>gc_log_prefix_gitpo
                zsits_scan_dynp-zzpallet
           INTO lv_log_handler.  " HUPGI-xxxxxxxxx

    IF v_qtychanged = abap_true.
*      Assign Changed Qty to database for reprocess
      lx_partqty = zsits_pgitopo-zzqty.
    ENDIF.

    EXPORT p1 = lx_blank_log
           p2 = lx_partqty
        TO DATABASE indx(z8) ID lv_log_handler.


    CALL FUNCTION 'ZITS_POST_PGI2PO'
      EXPORTING
        iv_exidv = zsits_scan_dynp-zzpallet
      EXCEPTIONS
        error    = 1
        OTHERS   = 2.
    IF sy-subrc <> 0.
      PERFORM frm_message_add USING zcl_its_utility=>gc_objid_proc
                                    zsits_scan_dynp-zzprocord
                                    abap_true.
    ELSE.
      lv_pallet = zsits_scan_dynp-zzpallet.
      lv_aufnr = zsits_scan_dynp-zzprocord.
      lv_exidv = zsits_scan_dynp-zzpallet.

      CALL FUNCTION 'ZITS_DEASSIGN_HU_FROM_PROC_ORD' STARTING NEW TASK lv_task  "Starting a new task in order to
        EXPORTING                                                               " avoid sap standard functionality associated with
          i_aufnr  = lv_aufnr                                                   " assigning and deassigning the same HU in same LUW
          iv_exidv = lv_exidv
        EXCEPTIONS
          error    = 1
          OTHERS   = 2.
      IF sy-subrc <> 0.
        PERFORM frm_message_add USING zcl_its_utility=>gc_objid_proc
                                      zsits_scan_dynp-zzprocord
                                      abap_true.
      ENDIF.

      PERFORM frm_clear_screen_fields.
      MESSAGE s016(zitsus) WITH lv_pallet INTO zsits_scan_dynp-zzsuccess_msg.
    ENDIF.
  ENDIF.

ENDFORM.                    " PROCESS_HU_PGI
*&---------------------------------------------------------------------*
*&      Form  PROCESS_MAT_PGI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_mat_pgi .
  DATA: lv_log_handler TYPE indx_srtfd,
        lx_blank_log   TYPE zsits_post_log,
        lx_goods_mvt   TYPE zsits_goods_movement,
        lv_pallet      LIKE zsits_scan_dynp-zzpallet.

  DATA: lwa_goods_mvt TYPE zsits_goods_movement,
        lwa_gm_item   TYPE zsits_gm_item,
        lv_mblnr      TYPE mblnr.

  CLEAR:lwa_goods_mvt,lx_goods_mvt,lwa_gm_item.
* Goods movement header
  lwa_goods_mvt-pstng_date = sy-datlo.
  lwa_goods_mvt-doc_date   = sy-datlo.

* Goods movement code
  lwa_goods_mvt-gm_code = zcl_its_utility=>gc_gm_code_03.   " GI
  lwa_gm_item-material  = zsits_scan_dynp-zzmaterial.  " Material
  lwa_gm_item-plant     = x_profile-zzwerks.  " Plant
  lwa_gm_item-batch     = zsits_scan_dynp-zzbatch.  " Batch
  lwa_gm_item-move_type = zcl_its_utility=>gc_gm_type_261.
  lwa_gm_item-stge_loc  = zsits_scan_dynp-zzsloc.
  lwa_gm_item-entry_qnt = zsits_pgitopo-zzqty.
  lwa_gm_item-orderid   = zsits_scan_dynp-zzprocord.
  PERFORM convert_input CHANGING lwa_gm_item-material.
  PERFORM convert_input CHANGING lwa_gm_item-orderid.
  APPEND lwa_gm_item TO lwa_goods_mvt-gm_item.
  CLEAR lv_mblnr.
*   Process Material Barcode goods issue

  lv_mblnr = zcl_its_utility=>post_goods_movement( is_goods_mvt   = lwa_goods_mvt
                                           iv_save_option = zcl_common_utility=>gc_commit_work ).
  IF lv_mblnr IS INITIAL .
    PERFORM frm_message_add USING zcl_its_utility=>gc_objid_proc
                                  zsits_scan_dynp-zzprocord
                                  abap_true.
  ELSE.
    PERFORM frm_clear_screen_fields.
    MESSAGE s018(zitsus) WITH lv_mblnr INTO zsits_scan_dynp-zzsuccess_msg.
  ENDIF.


ENDFORM.                    " PROCESS_MAT_PGI
*&---------------------------------------------------------------------*
*&      Form  FRM_UPDATE_FOR_CHANGED_QTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_update_for_changed_qty.
  DATA:lwa_huitem TYPE bapihuitem,
       lv_dummy   TYPE string.
  IF v_label_type = zcl_its_utility=>gc_label_hu.
    IF x_label_content-hu_content-hu_content[] IS NOT INITIAL.
*   The assumption is that only one material is packed in the handling unit
      READ TABLE x_label_content-hu_content-hu_content INTO lwa_huitem INDEX 1.
      IF lwa_huitem-pack_qty NE zsits_pgitopo-zzqty.
        IF zsits_pgitopo-zzqty > lwa_huitem-pack_qty.
          MESSAGE e026(zitsus) INTO lv_dummy.
          PERFORM frm_message_add USING zcl_its_utility=>gc_objid_proc
                                    zsits_scan_dynp-zzprocord
                                    abap_true.
          CLEAR zsits_pgitopo-zzqty.
          CLEAR ok_code.
          RETURN.
        ENDIF.
*        Check if the Quantity Changed, then check the flag V_qtychanged
        v_qtychanged = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " FRM_UPDATE_FOR_CHANGED_QTY
