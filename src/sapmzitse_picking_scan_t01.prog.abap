*&---------------------------------------------------------------------*
*&  Include           SAPMZITSE_PICKING_SCAN_T01
*&---------------------------------------------------------------------*

TABLES:zsits_scan_pick.

TYPES:BEGIN OF ty_su_number,
        lenum TYPE lein-lenum,
      END OF ty_su_number,

*--Begin of changes added by skotturu
      BEGIN OF ts_lenum,
       su1  TYPE lenum,
       su2  TYPE lenum,
       su3  TYPE lenum,
      END OF ts_lenum,
*--End of changes added by skotturu

      BEGIN OF ty_ltap,
        tanum TYPE ltap-tanum,
        tapos TYPE ltap-tapos,
        werks TYPE werks_d,     " Plant added by SKotturu
        pquit TYPE ltap-pquit,
        nsola TYPE ltap-nsola,
        altme TYPE ltap-altme,
        vlenr TYPE ltap-vlenr,
        flag  TYPE c,
      END OF ty_ltap.

DATA:or_log           TYPE REF TO zcl_its_utility,
     wa_user_profile  TYPE zsits_user_profile,
     v_code           TYPE sy-ucomm,
     v_dummy          TYPE string ##needed,
     v_flag           TYPE c,
     it_su_number     TYPE TABLE OF ty_su_number,
     wa_su_number     TYPE ty_su_number,
     v_lenum_output   TYPE lein-lenum,
     v_lenum_input    TYPE lein-lenum,
     wa_ltap_conf     TYPE ltap_conf,
     it_ltap_conf     TYPE TABLE OF ltap_conf,
     wa_ltap_conf_hu  TYPE ltap_conf_hu,
     it_ltap_conf_hu  TYPE TABLE OF ltap_conf_hu,
     v_clear          TYPE c,
     v_kquit          TYPE ltak-kquit,
     v_tanum          TYPE ltak-tanum,
     v_tanum_tmp      TYPE ltap-tanum,
     it_label_type    TYPE ztlabel_type_range,
     wa_label_type    TYPE LINE OF ztlabel_type_range,
     v_barcode        TYPE zd_barcode,
     v_label_type     TYPE zdits_label_type ##needed,
     wa_label_content TYPE zsits_label_content,
     wa_material_data TYPE zsits_material_data_dfs ##needed,
     it_ltap          TYPE TABLE OF ty_ltap,
*--Begin of changes added by skotturu
     gv_su1           TYPE lein-lenum, "ltap_vlenr,
     gv_su2           TYPE lein-lenum, "ltap_vlenr,
     gv_su3           TYPE lein-lenum, "ltap_vlenr,
     gt_lenum         TYPE TABLE OF ts_lenum,
     gv_index         TYPE sy-index.
*--End of changes added by skotturu
FIELD-SYMBOLS:<s_ltap> TYPE ty_ltap.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'DISPLAY_SU' ITSELF
CONTROLS: display_su TYPE TABLEVIEW USING SCREEN 9200.

*&SPWIZARD: LINES OF TABLECONTROL 'DISPLAY_SU'
DATA:     g_display_su_lines  LIKE sy-loopc ##needed.

DATA:     ok_code LIKE sy-ucomm.


CONSTANTS : gc_pgdn   TYPE char4 VALUE 'PGDN',
            gc_pgup   TYPE char4 VALUE 'PGUP'.
