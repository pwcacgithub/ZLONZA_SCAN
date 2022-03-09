*&---------------------------------------------------------------------*
*&  Include           ZITSEE0301_DISPENSING_T01
*&---------------------------------------------------------------------*

TABLES:zsits_scan_repack_barcode,
       zsits_scan_repack_input,
       zsits_scan_repack_display.

TYPES:BEGIN OF ty_vepo,
        velin TYPE vepo-velin,
        vepos TYPE vepo-vepos,
        vemng TYPE vepo-vemng,
        vemeh TYPE vepo-vemeh,
        matnr TYPE vepo-matnr,
        charg TYPE vepo-charg,
        werks TYPE vepo-werks,
        lgort TYPE vepo-lgort,
        bestq TYPE bestq,
        sobkz TYPE sobkz,
        sonum TYPE lvs_sonum,
      END OF ty_vepo,

      BEGIN OF ty_warehouse,
        lgtyp TYPE lein-lgtyp,
        lgpla TYPE lein-lgpla,
      END OF ty_warehouse,

      BEGIN OF ty_wh,
        lenum TYPE lqua-lenum,
        lgtyp TYPE lqua-lgtyp,
        lgpla TYPE lqua-lgpla,
        lgnum TYPE lqua-lgnum,
        matnr TYPE lqua-matnr,
        werks TYPE lqua-werks,
        charg TYPE lqua-charg,
        letyp TYPE lqua-letyp,
        meins TYPE lqua-meins,
        bestq TYPE lqua-bestq,
      END OF ty_wh.

DATA: lt_wh              TYPE TABLE OF ty_wh,
      ls_wh              TYPE ty_wh,
      or_log             TYPE REF TO zcl_its_utility,
      v_clear            TYPE c,
      v_subrc            TYPE sy-subrc,
      wa_user_profile    TYPE zsits_user_profile,
      v_barcode          TYPE zd_barcode,

      it_label_type      TYPE ztlabel_type_range,
      wa_label_type      TYPE LINE OF ztlabel_type_range,
      v_label_type       TYPE zdits_label_type ##needed,
      wa_label_content   TYPE zsits_label_content,
      wa_material_data   TYPE zsits_material_data_dfs ##needed,
      v_create_to        TYPE c,
      v_code             TYPE sy-ucomm,
      it_container       TYPE TABLE OF zsits_scan_repack_input,
      wa_container       TYPE zsits_scan_repack_input,
      ls_itemunpack      TYPE bapihuitmunpack,
      lt_return_up       TYPE TABLE OF bapiret2,
      v_flag             TYPE c,
      v_flag_tmp         TYPE c,
      v_lenum(20)        TYPE c,
      v_lgnum            TYPE t320-lgnum,
      v_hu_status_init   TYPE hu_st_init,
      v_vhilm            TYPE vekp-vhilm,
      wa_lein            TYPE ty_warehouse,
      wa_t340d           TYPE ty_warehouse,
      wa_vepo            TYPE ty_vepo,
      v_qty              TYPE p DECIMALS 3,
      v_difference       TYPE p DECIMALS 3,
      it_return          TYPE TABLE OF bapiret2,
      v_mtart            TYPE mara-mtart,
      v_hukey            TYPE bapihukey-hu_exid,
      wa_headerproposal  TYPE bapihuhdrproposal,
      wa_repack          TYPE bapihurepack,
      it_repack          TYPE TABLE OF bapihurepack,
      it_desthu          TYPE TABLE OF zsits_scan_repack_display,
      wa_desthu          TYPE zsits_scan_repack_display,
      v_dummy            TYPE string ##needed,
      it_desthu_tmp      TYPE TABLE OF bapihunumber,
      v_log_handler      TYPE indx_srtfd,
      it_reprocess       TYPE TABLE OF zsits_repack,
      wa_reprocess       TYPE zsits_repack,
      wa_move_su         TYPE zsits_create_to_move_su,
      v_exid_tmp         TYPE exidv,
      v_move_original_su TYPE c,
      wa_post_log        TYPE zsits_post_log,
      lv_werksd          TYPE werks_d.


FIELD-SYMBOLS:<s_huitem>    TYPE bapihuitem,
              <s_container> TYPE zsits_scan_repack_input,
              <s_return>    TYPE bapiret2,
              <s_desthu>    TYPE bapihunumber.


CONSTANTS:c_error            TYPE c VALUE 'E',
          c_abortion         TYPE c VALUE 'A',
          c_in_warehouse     TYPE c VALUE 'C',
          c_not_in_warehouse TYPE c VALUE 'B',
          c_movement_type    TYPE bwlvs VALUE '999',
          c_movement_type_sc TYPE bwlvs VALUE '331',
          c_hu_exid          TYPE bapihukey-hu_exid VALUE '$1'.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'CONTAINER001' ITSELF
CONTROLS: container001 TYPE TABLEVIEW USING SCREEN 9200.

*&SPWIZARD: LINES OF TABLECONTROL 'CONTAINER001'
DATA:     g_container001_lines  LIKE sy-loopc ##needed.

DATA:     ok_code LIKE sy-ucomm.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'CONTAINER002' ITSELF
CONTROLS: container002 TYPE TABLEVIEW USING SCREEN 9300.

*&SPWIZARD: LINES OF TABLECONTROL 'CONTAINER002'
DATA:     g_container002_lines  LIKE sy-loopc ##needed.


DATA: gv_qty1    TYPE zzqty,
      gv_qty2    TYPE zzqty,
      gv_qty3    TYPE zzqty,
      gv_qty4    TYPE zzqty,
      gv_qty5    TYPE zzqty,
      gv_number1 TYPE i,
      gv_number2 TYPE i,
      gv_number3 TYPE i,
      gv_number4 TYPE i,
      gv_number5 TYPE i,
      gv_uom1    TYPE meins,
      gv_uom2    TYPE meins,
      gv_uom3    TYPE meins,
      gv_uom4    TYPE meins,
      gv_uom5    TYPE meins,

      gv_hu1     TYPE exidv,
      gv_hu2     TYPE exidv,
      gv_hu3     TYPE exidv,
      gv_hu4     TYPE exidv,
      gv_hu5     TYPE exidv,
      gv_huqty1  TYPE zzqty,
      gv_huqty2  TYPE zzqty,
      gv_huqty3  TYPE zzqty,
      gv_huqty4  TYPE zzqty,
      gv_huqty5  TYPE zzqty.


.
