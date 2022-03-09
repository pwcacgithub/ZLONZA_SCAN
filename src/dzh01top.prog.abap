*&---------------------------------------------------------------------*
*&  Include           DZH01TOP
*&---------------------------------------------------------------------*

TYPES :
       BEGIN OF ts_phu,
          venum  TYPE venum,
          exidv  TYPE exidv,      " External Handling Unit Identification
          vhilm  TYPE vhilm,      " packing material
          matktx TYPE maktx,      " material text
          werks  TYPE hum_werks,  " plant
          lgort  TYPE hum_lgort,  " stor. loca
          lgnum  TYPE hum_lgnum,  " whr. no
          lgpla  TYPE lgpla,      " stor. Bin
        END OF ts_phu,

        BEGIN OF ts_exidv,
          index     TYPE  i,
          checkbox1 TYPE char1,
          checkbox2 TYPE char1,
          checkbox3 TYPE char1,
          exidv1    TYPE exidv,
          exidv2    TYPE exidv,
          exidv3    TYPE exidv,
          vhilm1    TYPE vhilm,
          vhilm2    TYPE vhilm,
          vhilm3    TYPE vhilm,
        END OF ts_exidv,

        BEGIN OF ts_final,
          checkbox TYPE char1,
          exidv    TYPE exidv,
          vhilm    TYPE vhilm,
***  BEGIN: EICR:603155 - Project ONE: HC & DFS Implementation US/MX - ATHOMAS3
          errflg   TYPE char1,
***  END: EICR:603155 - Project ONE: HC & DFS Implementation US/MX - ATHOMAS3
        END OF ts_final,

         BEGIN OF ts_message,
             message1 TYPE char20,
             message2 TYPE char20,
             message3 TYPE char20,
             message4 TYPE char20,
             message5 TYPE char20,
             message6 TYPE char20,
             message7 TYPE char20,
             message8 TYPE char20,
          END OF ts_message .

TYPES : tt_phu     TYPE STANDARD TABLE OF ts_exidv,
        tt_final   TYPE STANDARD TABLE OF ts_final.

DATA : go_hu       TYPE REF TO zcl_rfscanner_packunpack,
       gt_exidv    TYPE STANDARD TABLE OF ts_exidv,
       gt_final    TYPE STANDARD TABLE OF ts_final,
***  BEGIN: EICR:603155 - Project ONE: HC & DFS Implementation US/MX - ATHOMAS3
       gt_huerr    TYPE STANDARD TABLE OF ts_final,
       gv_success  TYPE char1,  " Indicator - at least 1 sucessful packing
       gv_flg_huerr TYPE CHAR1,  " Flag -  additional logic for US/MX
***  END: EICR:603155 - Project ONE: HC & DFS Implementation US/MX - ATHOMAS3
       gs_hu       TYPE zcl_rfscanner_packunpack=>ts_phu,
       gv_exidv    TYPE exidv,
       gv_ch1      TYPE char1,
       gv_exidv1   TYPE exidv,
       gv_vhilm1   TYPE vhilm,
       gv_ch2      TYPE char1,
       gv_exidv2   TYPE exidv,
       gv_vhilm2   TYPE vhilm,
       gv_ch3      TYPE char1,
       gv_exidv3   TYPE exidv,
       gv_vhilm3   TYPE vhilm,
       gv_message1 TYPE char20,
       gv_message2 TYPE char20,
       gv_message3 TYPE char20,
       gv_message4 TYPE char20,
       gv_message5 TYPE char20,
       gv_message6 TYPE char20,
       gv_message7 TYPE char20,
       gv_message8 TYPE char20,
       gv_barcode  TYPE char100,
       gv_lbarcode TYPE char100,
       gv_rmatnr TYPE matnr,
       gv_index    TYPE sy-index.

CONSTANTS : gc_back   TYPE char4 VALUE 'BACK',
            gc_clr    TYPE char3 VALUE 'CLR',
            gc_f2     TYPE char2 VALUE 'F2',
            gc_f3     TYPE char2 VALUE 'F3',
            gc_enter  TYPE char5 VALUE 'ENTER',
            gc_next   TYPE char4 VALUE 'NEXT',
            gc_ent    TYPE char3 VALUE 'ENT',
            gc_save   TYPE char4 VALUE 'SAVE',
            gc_ok     TYPE char2 VALUE 'OK',
            gc_ch1    TYPE char3 VALUE 'CH1',
            gc_ch2    TYPE char3 VALUE 'CH2',
            gc_ch3    TYPE char3 VALUE 'CH3',
            gc_rem    TYPE char3 VALUE 'REM',
            gc_pack   TYPE char4 VALUE 'PACK',
            gc_pgdn   TYPE char4 VALUE 'PGDN',
            gc_pgup   TYPE char4 VALUE 'PGUP',
            gc_flag   TYPE char1 VALUE 'X',
            gc_msgid  TYPE msgid VALUE 'ZLONE_HU',
            gc_msgno1 TYPE msgno VALUE '001'.
