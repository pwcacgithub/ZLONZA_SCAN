*&---------------------------------------------------------------------*
*&  Include           SAPDZH24_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
  DATA: lv_text(20) TYPE c.

  DATA: lt_tvarvc TYPE rseloption,
        lv_retu   TYPE bapi_mtype.
  CONSTANTS: lc_tcode TYPE rvari_vnam VALUE 'Z_GELATIN_SCAN',
             lc_type  TYPE rsscr_kind VALUE 'P'.
  gv_gelatin = sy-tcode.
  CLEAR: lt_tvarvc[], lv_return.
  CALL METHOD zcl_common_utility=>parameter_read
    EXPORTING
      iv_name   = lc_tcode
      iv_type   = lc_type
    IMPORTING
      et_tvarvc = lt_tvarvc
      ev_return = lv_retu.

  IF lv_retu EQ abap_true AND lt_tvarvc IS NOT INITIAL.
    READ TABLE lt_tvarvc INTO DATA(lw_tvarvc) INDEX 1.
    IF sy-subrc EQ gc_0.
      gv_tcode = lw_tvarvc-low.
    ENDIF.
  ENDIF.
  CLEAR: lt_tvarvc[], lv_retu.

  IF gv_gelatin EQ gv_tcode.
    lv_text = text-001.
    SET TITLEBAR '0100'.
    gv_text = text-001.
  ELSE.
    SET TITLEBAR '900'.
    gv_text = text-024.
  ENDIF.

  CASE lv_cursor_n.
    WHEN 'ZSITS_SCAN_DYNP-ZZOUTB_DELIVERY'.
      SET CURSOR FIELD 'ZSITS_SCAN_DYNP-ZZOBD_ITEM'.
    WHEN ''.
      SET CURSOR FIELD 'ZSITS_SCAN_DYNP-ZZOUTB_DELIVERY'.
  ENDCASE.

*  gv_text = 'BLOB_Scan'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE initialize OUTPUT.
  PERFORM get_constants.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '900' WITH '-' zsits_scan_dynp-zzoutb_delivery.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.

  TYPES :BEGIN OF ts_line,
           text_split(20) TYPE c,
         END OF ts_line.

  DATA : lv_msgid   TYPE char20,
         lv_value   TYPE char20,
         lv_value2  TYPE char20,
         lv_value3  TYPE char20,
         lv_value4  TYPE char20,
         lv_num     TYPE char3,
         ls_message TYPE ts_message.

  DATA : lv_message TYPE string,
         lv_mes     TYPE char255,
         lt_lines   TYPE STANDARD TABLE OF ts_line.

  CONSTANTS : lc_lang TYPE spras VALUE 'E'.

  SET PF-STATUS '0300'.

  CLEAR : ls_message, lv_msgid, lv_value, lv_num,
          gv_message1, gv_message2, gv_message3, gv_message4,
          gv_message5, gv_message6, gv_message7, gv_message8.

*--Read Parametre message ID
  GET PARAMETER ID text-016 FIELD lv_msgid.
*--Read Parametre message ID
  GET PARAMETER ID text-018 FIELD lv_value.
  GET PARAMETER ID text-021 FIELD lv_value2.
  GET PARAMETER ID text-022 FIELD lv_value3.
  GET PARAMETER ID text-023 FIELD lv_value4.
*--Read Parametre message ID
  GET PARAMETER ID text-017 FIELD lv_num.

*--Populate error message details

*--Get the message from message id
  CALL FUNCTION 'FORMAT_MESSAGE'
    EXPORTING
      id        = lv_msgid
      lang      = lc_lang
      no        = lv_num "'001'
      v1        = lv_value
      v2        = lv_value2
      v3        = lv_value3
      v4        = lv_value4
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
            ls_message-message1 = <lfs_lines>-text_split.
          WHEN 2.
            ls_message-message2 = <lfs_lines>-text_split.
          WHEN 3.
            ls_message-message3 = <lfs_lines>-text_split.
          WHEN 4.
            ls_message-message4 = <lfs_lines>-text_split.
          WHEN 5.
            ls_message-message5 = <lfs_lines>-text_split.
          WHEN 6.
            ls_message-message6 = <lfs_lines>-text_split.
          WHEN 7.
            ls_message-message7 = <lfs_lines>-text_split.
          WHEN 8.
            ls_message-message8 = <lfs_lines>-text_split.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDIF.

*--Display message
  gv_message1 = ls_message-message1.
  gv_message2 = ls_message-message2.
  gv_message3 = ls_message-message3.
  gv_message4 = ls_message-message4.
  gv_message5 = ls_message-message5.
  gv_message6 = ls_message-message6.
  gv_message7 = ls_message-message7.
  gv_message8 = ls_message-message8.

  CLEAR: lv_message, lv_mes, lt_lines, lv_msgid,
  lv_num, lv_value, lv_value2, lv_value3, lv_value4, ls_message.
ENDMODULE.

MODULE status_0400 OUTPUT.

  SET PF-STATUS '0400'.
  SET TITLEBAR '900' WITH '-' zsits_scan_dynp-zzoutb_delivery.
ENDMODULE.

MODULE status_0500 OUTPUT.

  SET PF-STATUS '0500'.
  SET TITLEBAR '900' WITH '-' zsits_scan_dynp-zzoutb_delivery.
*  GET CURSOR FIELD lv_cursor.
  CASE lv_cursor.
    WHEN ' '.
      SET CURSOR FIELD 'GV_CART1'.
    WHEN 'GV_CART1'OR 'GV_CART1_QTY'.
      SET CURSOR FIELD 'GV_CART2'.
    WHEN 'GV_CART2' OR 'GV_CART2_QTY'.
      SET CURSOR FIELD 'GV_CART3'.
    WHEN 'GV_CART3' OR 'GV_CART3_QTY'.
      SET CURSOR FIELD 'GV_CART4'.

  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  DSP_HU  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE dsp_hu OUTPUT.
  DATA: lw_hu2 TYPE ty_hu.
  IF gv_gelatin EQ gv_tcode.
    IF lv_indx IS INITIAL.
      lv_indx = 1.
    ENDIF.
    DATA: lv_count1 TYPE i,
          lv_ucomm  TYPE sy-ucomm,
          lv_lines1 TYPE i,
          lw_hu     TYPE ty_hu.
    CLEAR: lv_count1, lv_ucomm, lv_lines1.
    IF gv_index1 IS INITIAL AND gv_index2 IS INITIAL.
      gv_index1 = 1.
      gv_index2 = 4.
    ENDIF.
    lv_ucomm = sy-ucomm.
    CLEAR: gv_cart1, gv_cart2, gv_cart3, gv_cart4, lw_hu2,
           gv_cart1_qty, gv_cart2_qty, gv_cart3_qty, gv_cart4_qty.
    IF gv_flg_pallet = abap_true.
      LOOP AT lt_hu1 INTO lw_hu2 FROM gv_index1 TO gv_index2.
        lv_count1 = lv_count1 + 1.
        CASE lv_count1.
          WHEN 1.
            gv_cart1 = lw_hu2-hu.
            gv_cart1_qty = lw_hu2-qty.
          WHEN 2.
            gv_cart2 = lw_hu2-hu.
            gv_cart2_qty = lw_hu2-qty.
          WHEN 3.
            gv_cart3 = lw_hu2-hu.
            gv_cart3_qty = lw_hu2-qty.
          WHEN 4.
            gv_cart4 = lw_hu2-hu.
            gv_cart4_qty = lw_hu2-qty.
        ENDCASE.
        CLEAR: lw_hu2.
      ENDLOOP.
    ENDIF.
    CLEAR: lw_hu2.
    IF gv_flg_pallet = abap_false.
      LOOP AT lt_hu4 INTO lw_hu2 FROM gv_index1 TO gv_index2.
        lv_count1 = lv_count1 + 1.
        CASE lv_count1.
          WHEN 1.
            gv_cart1 = lw_hu2-hu.
            gv_cart1_qty = lw_hu2-qty.
          WHEN 2.
            gv_cart2 = lw_hu2-hu.
            gv_cart2_qty = lw_hu2-qty.
          WHEN 3.
            gv_cart3 = lw_hu2-hu.
            gv_cart3_qty = lw_hu2-qty.
          WHEN 4.
            gv_cart4 = lw_hu2-hu.
            gv_cart4_qty = lw_hu2-qty.
        ENDCASE.
        CLEAR: lw_hu2.
      ENDLOOP.
    ENDIF.


    IF gv_flg_pallet EQ abap_false.
      DESCRIBE TABLE lt_hu1[] LINES lv_lines1.
      IF gv_cart3 = gv_cart4.
        CLEAR: gv_cart4, gv_cart4_qty.
      ENDIF.
      IF gv_cart2 = gv_cart3.
        CLEAR: gv_cart3, gv_cart3_qty.
      ENDIF.
      IF gv_cart1 = gv_cart2.
        CLEAR: gv_cart2, gv_cart2_qty.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen OUTPUT.
  IF gv_gelatin EQ gv_tcode.
    IF gv_flg_pallet IS NOT INITIAL.
      LOOP AT SCREEN.
        IF screen-group1 = 'ZG1'.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ELSE.

      LOOP AT SCREEN.
        IF gv_cart1 IS NOT INITIAL.
          IF screen-name = 'GV_CART1'.
            screen-input = '0'.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
        IF gv_cart2 IS NOT INITIAL.
          IF screen-name = 'GV_CART2'.
            screen-input = '0'.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
        IF gv_cart3 IS NOT INITIAL.
          IF screen-name = 'GV_CART3'.
            screen-input = '0'.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
        IF gv_cart4 IS NOT INITIAL.
          IF screen-name = 'GV_CART4'.
            screen-input = '0'.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.


    LOOP AT SCREEN.
      IF screen-group1 = 'ZG2'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.
