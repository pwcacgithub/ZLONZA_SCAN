*&---------------------------------------------------------------------*
*& Include MZITSEBREAK_PALLETTOP                             Module Pool      SAPMZITSEBREAK_PALLET
*&
*&---------------------------------------------------------------------*



*----------------------------------------------------------------------*
* Table Work Areas
*----------------------------------------------------------------------*
TABLES: zsits_scan_dynp.

*----------------------------------------------------------------------*
* Local Data Types in Program
*----------------------------------------------------------------------*


*----------------------------------------------------------------------*
* Global Internal Tables Declaration
*----------------------------------------------------------------------*


*----------------------------------------------------------------------*
* Global Variants Declaration
*----------------------------------------------------------------------*
DATA: o_log          TYPE REF TO zcl_its_utility,
      x_profile      TYPE zsits_user_profile,
      ok_code        TYPE sy-ucomm,
      v_cursor_field TYPE char50.
***  BEGIN: EICR:603155 SRAWAT- Project ONE: HC & DFS Implementation US & MX****
CONSTANTS:  lc_capus_type   TYPE t313g-aityp VALUE 'GS1',
            lc_error_type   TYPE c VALUE 'E',
            lc_sign_i       TYPE c VALUE 'I',
            lc_option_eq(2) TYPE c VALUE 'EQ'.
DATA : lv_barcode           TYPE char100 ##NEEDED,
       iv_exist_check       TYPE xfeld ##NEEDED,
       iv_skip_or_bch_check TYPE xfeld ##NEEDED,
       iv_read_10_only      TYPE boolean ##NEEDED.
***  END: EICR:603155 SRAWAT- Project ONE: HC & DFS Implementation US & MX****

" Begin of change by ASAH for global change of scan objects
DATA : gs_hu       TYPE zcl_rfscanner_packunpack=>ts_phu,
       go_hu       TYPE REF TO zcl_rfscanner_packunpack,
       gv_barcode  TYPE char100,
       gv_barcode1 TYPE char100,
       gv_flg_us   TYPE flag,
       gs_return   TYPE bapiret2.
" End of change by ASAH for global change of scan objects
*&---------------------------------------------------------------------*
*&  Include           MZITSEBREAK_PALLETTOP
*&---------------------------------------------------------------------*
