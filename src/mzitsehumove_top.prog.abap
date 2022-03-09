*&---------------------------------------------------------------------*
*&  Include           MZITSEHUMOVE_TOP
*&---------------------------------------------------------------------*

TABLES:
  zsits_scan_dynp,
  zsits_scan_humove.

*----------------------------------------------------------------------*
* Global Variants Declaration
*----------------------------------------------------------------------*
DATA: o_log           TYPE REF TO zcl_its_utility,
      ok_code         TYPE sy-ucomm,
      x_profile       TYPE zsits_user_profile,
      x_label_content TYPE zsits_label_content, "scanned label content except material without batch
      x_hu_item       LIKE LINE OF x_label_content-hu_content-hu_content.

DATA: v_pid           TYPE tpara-paramid,
      v_dummy         TYPE string,                          "#EC NEEDED
      v_hu_counter    TYPE i,
      v_hu_txt        TYPE char3,
      v_err_fg        TYPE boolean, "Error flag
      v_huwbevent     TYPE huwbevent. "Process code

DATA:
      wa_su                 TYPE zsits_scan_dynp-zzsu,
      it_su                 TYPE TABLE OF zsits_scan_dynp-zzsu,
      gv_index1             TYPE i,
      gv_index2             TYPE i,
      gv_cart1              TYPE zd_su,
      gv_cart2              TYPE zd_su,
      gv_cart3              TYPE zd_su,
      gv_cart4              TYPE zd_su,
      gv_cart5              TYPE zd_su.

***********************************************************************
* Controls
***********************************************************************
CONTROLS ztblctrl_su TYPE TABLEVIEW USING SCREEN 9100.
