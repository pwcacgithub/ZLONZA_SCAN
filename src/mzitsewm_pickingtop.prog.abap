*&---------------------------------------------------------------------*
*&  Include           MZITSEWM_PICKINGTOP
*&---------------------------------------------------------------------*

PROGRAM  sapmzitsewm_picking.

*----------------------------------------------------------------------*
* Tables
*----------------------------------------------------------------------*
TABLES: zsits_scan_dynp.

*----------------------------------------------------------------------*
* Constants
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Global Variants Declaration
*----------------------------------------------------------------------*
DATA: o_log     TYPE REF TO zcl_its_utility,
      x_profile TYPE zsits_user_profile.

DATA: x_delivery_to         TYPE vbfa_t,
      s_delivery_header     TYPE zsits_dlv_header,
      x_to_data             TYPE zsits_to_data,
      it_scanned_batch_list TYPE STANDARD TABLE OF ztits_pick.

DATA: v_label_type    TYPE zdits_label_type,
      x_label_content TYPE zsits_label_content,
      v_return        TYPE ztits_barcode_return,
      v_batch_gt_10   TYPE boolean, "Is length of batch greater than 10
      it_to_conf      TYPE STANDARD TABLE OF zsits_to_conf.

* Begin of change ED2K911347 INC0031176/1 VARGHA 04/30/2018
DATA : gt_tvarvc TYPE rseloption,
       gs_tvarvc TYPE LINE OF rseloption,
       gv_return TYPE bapi_mtype.
* End of change ED2K911347 INC0031176/1 VARGHA 04/30/2018

DATA: ok_code TYPE sy-ucomm.

DATA: lv_barcode           TYPE char100 ##NEEDED,
      iv_exist_check       TYPE xfeld ##NEEDED,
      iv_skip_or_bch_check TYPE xfeld ##NEEDED,
      iv_read_10_only      TYPE boolean ##NEEDED.

CONSTANTS:  lc_capus_type TYPE t313g-aityp VALUE 'GS1'.

DATA: v_scan_object   TYPE string ##NEEDED,
      it_picking_item TYPE STANDARD TABLE OF vbpok ##NEEDED,
      it_hu_1         TYPE STANDARD TABLE OF hum_rehang_hu ##NEEDED.

DATA: x_delivery_header TYPE zsits_dlv_header ##NEEDED,
      it_delivery_item  TYPE zttits_dlv_item ##NEEDED,
      it_delivery_pick  TYPE vbfa_t ##NEEDED,

      "Begin of change by Pratik EICR 603155 TR #D10K9A44XO
      "Start of Data declaration for screen 9003
      gv_index          TYPE sy-index,
      lv_hu_counter     TYPE i,
      lv_hu_txt         TYPE char3,
      it_su             TYPE TABLE OF zsits_scan_dynp-zzpalcarton,
      wa_su             TYPE  zsits_scan_dynp-zzpalcarton,
      wa_label          TYPE zsits_label_content,
      gv_su1            TYPE zd_palcarton,
      gv_su2            TYPE zd_palcarton,
      gv_su3            TYPE zd_palcarton.

TYPES: BEGIN OF ts_zd_palcarton,
         su1 TYPE zd_palcarton,
         su2 TYPE zd_palcarton,
         su3 TYPE zd_palcarton,
       END OF ts_zd_palcarton,

       BEGIN OF ts_msg,
         msgid TYPE sy-msgid,
         msgty TYPE sy-msgty,
         msgno TYPE sy-msgno,
         msgv1 TYPE sy-msgv1,
         msgv2 TYPE sy-msgv2,
         msgv3 TYPE sy-msgv3,
         msgv4 TYPE sy-msgv4,
       END OF ts_msg ,

       tt_msg TYPE STANDARD TABLE OF ts_msg.

DATA: gt_zd_palcarton        TYPE TABLE OF ts_zd_palcarton,
      lv_dummy               TYPE string,
      lv_dummy_a             TYPE string,
      lv_dummy_e             TYPE string,
      lv_dummy_i             TYPE string,
      lv_dummy_s             TYPE string,
      gv_plt_flg             TYPE flag,
      gv_pak_mat             TYPE matnr,
      gt_zlscan_ewmpick_data TYPE TABLE OF zlscan_ewmpick_data,
      ls_zlscan_ewmpick_data TYPE zlscan_ewmpick_data.

"End of Data declaration for screen 9003
"Start of Data declaration for screen 9999
DATA: gv_msgid     TYPE sy-msgid,
      gv_msgno     TYPE sy-msgno,
      gv_error_txt TYPE char100.
"End of Data declaration for screen 9999
"End of change by Pratik EICR 603155 TR #D10K9A44XO

DATA: gv_flg_us TYPE flag, "MMUKHERJEE++ EICR 603155 TR #D10K9A44XO
      gv_prefix TYPE t313daityp. "MMUKHERJEE++ EICR 603155 TR #D10K9A44XO
