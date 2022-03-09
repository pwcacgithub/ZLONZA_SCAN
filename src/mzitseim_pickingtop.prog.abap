*&---------------------------------------------------------------------*
*&  Include           MZITSEIM_PICKINGTOP
*&---------------------------------------------------------------------*

PROGRAM  sapmzitseim_picking.

*----------------------------------------------------------------------*
* Tables
*----------------------------------------------------------------------*
TABLES: zsits_scan_dynp.

*----------------------------------------------------------------------*
* Global Variants Declaration
*----------------------------------------------------------------------*
DATA: o_log     TYPE REF TO zcl_its_utility ##NEEDED,
      x_profile TYPE zsits_user_profile ##NEEDED.

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
            gc_clear      TYPE char3 VALUE 'CLR'.
DATA : lv_barcode           TYPE char100 ##NEEDED,
       iv_exist_check       TYPE xfeld ##NEEDED,
       iv_skip_or_bch_check TYPE xfeld ##NEEDED,
       iv_read_10_only      TYPE boolean ##NEEDED,
       lit_plant            TYPE TABLE OF ty_plant ##NEEDED,
       lwa_plant            LIKE LINE OF lit_plant ##NEEDED,
       lit_plant_val        TYPE RANGE OF werks_d ##NEEDED,
       lv_lookup_plant      TYPE char30 VALUE 'ZL_HUSCAN_PLANTS' ##NEEDED,
       lv_param             TYPE c LENGTH 50 ##NEEDED,
       flag_pal             TYPE c VALUE ' '.

RANGES : lr_werks FOR marc-werks ##NEEDED..
