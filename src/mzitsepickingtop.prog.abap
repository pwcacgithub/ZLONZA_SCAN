*&---------------------------------------------------------------------*
*& Include MZITSEPICKINGTOP                                  Module Pool      SAPMZITSEPICKING
*&
*&---------------------------------------------------------------------*
PROGRAM SAPMZITSEPICKING.

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
DATA: o_log                 TYPE REF TO zcl_its_utility,
      x_profile             TYPE zsits_user_profile,
      ok_code               TYPE sy-ucomm,
      v_code                TYPE sy-ucomm,
      v_cursor_field        TYPE char50,
      x_detail              TYPE zsits_to_data,
      x_delivery_header     TYPE zsits_dlv_header,
      x_delivery_to         TYPE vbfa_t,
      wa_to_item            TYPE zsits_to_item,
      x_to_conf             TYPE zsits_to_conf,
      v_material            TYPE matnr,
      v_quantity            TYPE ltap_vsolm,
      v_quantity_upd        TYPE ltap_vsolm.
