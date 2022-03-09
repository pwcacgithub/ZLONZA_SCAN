*&---------------------------------------------------------------------*
*&  Include           ZITSEE0301_DISPENSING_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_9100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9100 OUTPUT.
  IF v_clear = abap_true.
    CLEAR:zsits_scan_repack_barcode-zzbarcode,
          zsits_scan_repack_barcode-quantity,
          v_clear.
  ENDIF.
  SET PF-STATUS 'SCAN_STATUS_9100'.
  SET TITLEBAR 'SCAN_TITLEBAR'.

  PERFORM initial_logon_data.

ENDMODULE.                 " STATUS_9100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9200 OUTPUT.
  SET PF-STATUS 'SCAN_STATUS_9200'.
  SET TITLEBAR 'SCAN_TITLEBAR'.

ENDMODULE.                 " STATUS_9200  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'CONTAINER001'. DO NOT CHANGE THIS LINE
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE container001_change_tc_attr OUTPUT.
*  DESCRIBE TABLE gt_container LINES container001-lines.
  container001-lines = zsits_scan_repack_barcode-quantity.
ENDMODULE.                    "CONTAINER001_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'CONTAINER001'. DO NOT CHANGE THIS LINE
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE container001_get_lines OUTPUT.
  g_container001_lines = sy-loopc.
ENDMODULE.                    "CONTAINER001_GET_LINES OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9300 OUTPUT.
  SET PF-STATUS 'SCAN_STATUS_9300'.
  SET TITLEBAR 'SCAN_TITLEBAR'.

ENDMODULE.                 " STATUS_9300  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'CONTAINER002'. DO NOT CHANGE THIS LINE
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE container002_change_tc_attr OUTPUT.
  DESCRIBE TABLE it_desthu LINES container002-lines.
ENDMODULE.                    "CONTAINER002_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'CONTAINER002'. DO NOT CHANGE THIS LINE
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE container002_get_lines OUTPUT.
  g_container002_lines = sy-loopc.
ENDMODULE.                    "CONTAINER002_GET_LINES OUTPUT

MODULE status_9400 OUTPUT.
  IF v_clear = abap_true.
    CLEAR:zsits_scan_repack_barcode-zzbarcode,
          zsits_scan_repack_barcode-quantity,
          v_clear.
  ENDIF.
  SET PF-STATUS 'SCAN_STATUS_9400'.
  SET TITLEBAR 'SCAN_TITLEBAR2'.

  PERFORM initial_logon_data.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  FILL_CONTAINERS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_containers OUTPUT.

  CLEAR: gv_number1, gv_uom1, gv_number2, gv_uom2, gv_number3, gv_uom3,
         gv_number4, gv_uom4, gv_number5, gv_uom5.

  LOOP AT it_container INTO DATA(ls_cont).
    CASE sy-tabix.
      WHEN '1'.
        gv_number1 = ls_cont-number.
        gv_uom1    = ls_cont-unit.
      WHEN '2'.
        gv_number2 = ls_cont-number.
        gv_uom2    = ls_cont-unit.
      WHEN '3'.
        gv_number3 = ls_cont-number.
        gv_uom3    = ls_cont-unit.
      WHEN '4'.
        gv_number4 = ls_cont-number.
        gv_uom4    = ls_cont-unit.
      WHEN '5'.
        gv_number5 = ls_cont-number.
        gv_uom5    = ls_cont-unit.
      WHEN OTHERS.

    ENDCASE.
    CLEAR: ls_cont.
  ENDLOOP.


ENDMODULE.                 " FILL_CONTAINERS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_data OUTPUT.
  DATA: lv_dummy TYPE char11,
        lv_qty1 TYPE string.
CLEAR : gv_hu1, gv_hu2, gv_hu3, gv_hu4, gv_hu5.

  LOOP AT it_desthu INTO DATA(ls_desthu).

    CASE sy-tabix.
      WHEN '1'.
        IF ls_desthu-exidv IS NOT INITIAL.
          lv_qty1 = ls_desthu-quantity.
          CONCATENATE ls_desthu-exidv lv_qty1 INTO gv_hu1 SEPARATED BY '    ' ..
          CLEAR: lv_qty1.
        ENDIF.
      WHEN '2'.
        IF ls_desthu-exidv IS NOT INITIAL.
          lv_qty1 = ls_desthu-quantity.
          CONCATENATE ls_desthu-exidv lv_qty1 INTO gv_hu2 SEPARATED BY '    ' ..
          CLEAR: lv_qty1.
        ENDIF.
      WHEN '3'.
        IF ls_desthu-exidv IS NOT INITIAL.
          lv_qty1 = ls_desthu-quantity.
          CONCATENATE ls_desthu-exidv lv_qty1 INTO gv_hu3 SEPARATED BY '    ' ..
          CLEAR: lv_qty1.
        ENDIF.
      WHEN '4'.
        IF ls_desthu-exidv IS NOT INITIAL.
          lv_qty1 = ls_desthu-quantity.
          CONCATENATE ls_desthu-exidv lv_qty1 INTO gv_hu4 SEPARATED BY '    ' ..
          CLEAR: lv_qty1.
        ENDIF.
      WHEN '5'.
        IF ls_desthu-exidv IS NOT INITIAL.
          lv_qty1 = ls_desthu-quantity.
          CONCATENATE ls_desthu-exidv lv_qty1 INTO gv_hu5 SEPARATED BY '    ' .
          CLEAR: lv_qty1.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

ENDMODULE.                 " FILL_DATA  OUTPUT
