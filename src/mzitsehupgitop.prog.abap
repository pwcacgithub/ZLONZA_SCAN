*&---------------------------------------------------------------------*
*& Include MZITSEHUPGITOP
**********************************************************
* VERSION CONTROL (Most recent on top):
* DATE             AUTHOR          TR
*&---------------------------------------------------------------------*
***********************************************************************

PROGRAM  sapmzitsehupgipgi.

TABLES: zsits_scan_dynp,
        zsits_pgitopo.

DATA:   io_log             TYPE REF TO zcl_its_utility,
        x_profile          TYPE zsits_user_profile,
        ok_code            TYPE sy-ucomm,
        iv_cursor_field    TYPE char50,
        iv_validation_fail TYPE boolean,
        v_label_type   TYPE zdits_label_type,
        x_label_content   TYPE zsits_label_content,
        x_material_data  TYPE zsits_material_data_dfs ##needed.

DATA:v_changeqty,
     v_qtychanged,
     v_dummy         TYPE bapi_msg.
