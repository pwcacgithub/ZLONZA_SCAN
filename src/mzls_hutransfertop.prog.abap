*&---------------------------------------------------------------------*
*&  Include           ZLMHUGR001TOP
*&---------------------------------------------------------------------*


*----------------------------------------------------------------------*
* Tables
*----------------------------------------------------------------------*
TABLES: zsits_scan_dynp.

*----------------------------------------------------------------------*
* Global Variants Declaration
*----------------------------------------------------------------------*
TYPES:    BEGIN OF ts_message,
            message1 TYPE char50,
            message2 TYPE char50,
            message3 TYPE char50,
            message4 TYPE char50,
            message5 TYPE char50,
            message6 TYPE char50,
            message7 TYPE char50,
            message8 TYPE char50,
          END OF ts_message .
DATA: o_log       TYPE REF TO zcl_its_utility ##NEEDED,
      go_hu       TYPE REF TO zcl_rfscanner_postgi,
      go_bc       TYPE REF TO zcl_rfscanner_packunpack,
      gs_likp     TYPE zcl_rfscanner_postgi=>ts_likp,
      gv_error1   TYPE xfeld,
      gv_error2   TYPE xfeld,
      gv_error3   TYPE xfeld,
      gv_noerror  TYPE xfeld,
      gv_message1 TYPE char50,
      gv_message2 TYPE char50,
      gv_message3 TYPE char50,
      gv_message4 TYPE char50,
      gv_message5 TYPE char50,
      gv_message6 TYPE char50,
      gv_message7 TYPE char50,
      gv_message8 TYPE char50,
      flag_pal    TYPE c VALUE ' ',
      gv_ibd      TYPE vbeln, " Inbound Delivery
      x_profile   TYPE zsits_user_profile ##NEEDED.

DATA: x_delivery_header TYPE zsits_dlv_header ##NEEDED,
      it_delivery_item  TYPE zttits_dlv_item ##NEEDED,
      it_delivery_pick  TYPE vbfa_t ##NEEDED.

DATA: v_label_type    TYPE zdits_label_type ##NEEDED,
      x_label_content TYPE zsits_label_content ##NEEDED.

DATA: v_scan_object   TYPE string ##NEEDED,
      it_picking_item TYPE STANDARD TABLE OF vbpok ##NEEDED,
      it_hu_1         TYPE STANDARD TABLE OF hum_rehang_hu ##NEEDED.

DATA: ok_code TYPE sy-ucomm.


TYPES:  BEGIN OF ty_plant,
          werks TYPE werks_d,
        END OF ty_plant.
CONSTANTS:  lc_capus_type TYPE t313g-aityp VALUE 'GS1',
            lc_error_type TYPE c VALUE 'E',
            gc_back       TYPE char4 VALUE 'BACK',
            gc_ok         TYPE char2 VALUE 'OK',
            gc_f3         TYPE char2 VALUE 'F3',
            gc_f2         TYPE char2 VALUE 'F2',
            gc_msgid      TYPE msgid VALUE 'ZLONE_HU',
            gc_pgr        TYPE char4 VALUE 'CONF',
            gc_f5         TYPE char2 VALUE 'F5',
            gc_nxt        TYPE char4 VALUE 'NEXT',
            gc_vt         TYPE VBTYP_N VALUE '7',
            gc_x          TYPE c VALUE 'X'.
DATA : lv_barcode           TYPE char100 ##NEEDED,
       iv_exist_check       TYPE xfeld ##NEEDED,
       iv_skip_or_bch_check TYPE xfeld ##NEEDED,
       iv_read_10_only      TYPE boolean ##NEEDED,
       lit_plant            TYPE TABLE OF ty_plant ##NEEDED,
       lwa_plant            LIKE LINE OF lit_plant ##NEEDED,
       lit_plant_val        TYPE RANGE OF werks_d ##NEEDED,
       lv_lookup_plant      TYPE char30 VALUE 'ZL_HUSCAN_PLANTS' ##NEEDED,
       lv_param             TYPE c LENGTH 50 ##NEEDED.
*       Batchinputdata of single transaction
DATA:   BDCDATA LIKE BDCDATA    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

RANGES : lr_werks FOR marc-werks ##NEEDED.
