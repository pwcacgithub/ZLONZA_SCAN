*&---------------------------------------------------------------------*
*&  Include           MZITSEBREAK_PALLETI01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  NEW_TRAN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE new_tran INPUT.
  CALL TRANSACTION 'ZMDE'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  SPLIT_HU  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE split_hu INPUT. " ASAH

  DATA: ls_label_content TYPE zsits_label_content,
        lv_exidv         TYPE exidv,
        lv_barcode1      TYPE string,
        lv_uname         TYPE xubname,
        lt_param         TYPE STANDARD TABLE OF bapiparam,
        lt_return_user   TYPE STANDARD TABLE OF bapiret2,
        lv_barcode2      TYPE string.

  CLEAR : ls_label_content ,gs_hu,gv_barcode1,
          lv_exidv, gs_return, lv_barcode1 , gv_flg_us ,lv_barcode2.

*--Create Class Object for validation
  CREATE OBJECT go_hu.
  gv_barcode = zsits_scan_dynp-zzbarcode(100).

  lv_uname = sy-uname.
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username  = lv_uname
    TABLES
      parameter = lt_param
      return    = lt_return_user.

  READ TABLE lt_param ASSIGNING FIELD-SYMBOL(<lfs_param>)
  WITH KEY parid = 'ZGELATIN'.
  IF sy-subrc = 0 AND <lfs_param>-parva = abap_true.
    gv_flg_us = abap_true.
  ENDIF.

*--Read the HU number enter one is with Prefix or not
*--If not prefix of HU number then add Prefix with below code
*--Create Class Object for validation
* CREATE OBJECT go_hu.
  IF gv_flg_us = abap_false.

    CALL METHOD go_hu->hubarcode_value
      EXPORTING
        iv_exidv    = gv_barcode
      IMPORTING
        ev_hunumber = gv_barcode1.

*REad the barcode
    CALL METHOD zcl_mde_barcode=>disolve_barcode
      EXPORTING
        iv_barcode       = gv_barcode1
        iv_werks         = ' '
      IMPORTING
        es_label_content = ls_label_content.

    IF ls_label_content-zzhu_exid IS INITIAL.
      RETURN.
    ENDIF.
    gs_hu-exidv = ls_label_content-zzhu_exid .
    zsits_scan_dynp-zzbarcode = gv_barcode1.
*    ****************
  ELSE.
    lv_barcode1 = gv_barcode.
    CALL FUNCTION 'ZWM_HU_VALIDATE'
      EXPORTING
        iv_barcode       = lv_barcode1
      IMPORTING
        ev_exidv         = lv_exidv
        es_return        = gs_return
        ev_barcode       = lv_barcode2
        es_label_content = ls_label_content.

    IF lv_exidv IS NOT INITIAL.
      gs_hu-exidv = lv_exidv.
      zsits_scan_dynp-zzbarcode = lv_barcode2.
    ENDIF.
    CLEAR: lv_barcode1.
  ENDIF.

*        lv_dummy1        TYPE bapi_msg,
*        lv_msg           TYPE string.


*  ELSEIF gs_return-type = 'E'.
*    lv_msgid = gs_return-id.
*    lv_msgno = gs_return-number.
*    lv_msgv1 = gs_return-message_v1.
*    IF lv_msgno = '249'.
*      MESSAGE e249(zlone_hu) WITH lv_msgv1 INTO lv_dummy1.
*      PERFORM log USING zcl_its_utility=>gc_objid_palcarton
*                      lv_msgv1
*                      abap_true.
*    ELSEIF lv_msgno = '072'.
*      MESSAGE e072(zlone_hu) WITH lv_msgv1 INTO lv_dummy1.
*      PERFORM log USING zcl_its_utility=>gc_objid_palcarton
*                      lv_msgv1
*                      abap_true.
*    ENDIF.
**    PERFORM error_message USING lv_msgid lv_msgno lv_msgv1.
*    CLEAR : lv_barcode , lv_msgid, lv_msgno , lv_msgv1.
*  ENDIF.

  """""""""""""""""""""
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  BREAK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE break INPUT.
  PERFORM break_pallet.
ENDMODULE.
