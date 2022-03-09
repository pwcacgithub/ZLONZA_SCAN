*&---------------------------------------------------------------------*
*& Include DZH00TOP                                          Module Pool      SAPDZH00
*&
*&---------------------------------------------------------------------*

*PROGRAM sapdzh00.

DATA : gv_exidv TYPE exidv.
DATA : gv_count_vepo  TYPE i,
       gv_nested_pack TYPE char1. " RVENUGOPAL EICR 573542

TYPES : BEGIN OF ts_menu0,
          matnr TYPE matnr,
          maktx TYPE maktx,
          vegr1 TYPE vegr1,
        END OF ts_menu0,

        BEGIN OF ts_multiple_hu,
          ch1   TYPE boolean,
          exidv TYPE exidv,
          venum TYPE venum,
          vepos TYPE vepos,
        END OF ts_multiple_hu,

        BEGIN OF ts_lower_hu,
          venum TYPE venum,
          exidv TYPE exidv,
        END OF ts_lower_hu,


        BEGIN OF ts_vekp,
          venum             TYPE venum,
          exidv             TYPE exidv,
          vhilm             TYPE vhilm,
          vhart             TYPE vhart,
          werks             TYPE hum_werks,
          vegr1             TYPE vegr1,
          brgew             TYPE brgew,
          ntgew             TYPE ntgew,
          magew             TYPE magew_vekp,
          tarag             TYPE tarag,
          gewei             TYPE gewei,
          lgnum	            TYPE hum_lgnum,
          uevel	            TYPE uevel,
          zzsublot          TYPE  zl_de_sublot,
          zztruck           TYPE  zl_de_truck,
          zzqa_status	      TYPE zl_de_qastatus,
          zzqareason_code	  TYPE zl_de_qareason_code,
          zztemp_rec_numb	  TYPE zl_de_temp_rec_numb,
          zzrep_sample_insi TYPE  zl_de_rep_sample_ins,
          zzmts	            TYPE zl_de_mts,
        END OF ts_vekp,


        BEGIN OF ts_higherhu,
          higherhu TYPE exidv,
          venum    TYPE venum,
          exidv    TYPE exidv,
        END OF ts_higherhu ,
        BEGIN OF ts_vepo,
          venum	TYPE venum,
          vepos	TYPE vepos,
          vemng TYPE vemng,
          vemeh	TYPE vemeh,
          matnr TYPE matnr,
          charg TYPE charg_d,
          werks	TYPE werks_d,
          lgort	TYPE lgort_d,
          sobkz TYPE sobkz,
          unvel TYPE unvel,
          bestq TYPE bestq,
        END OF ts_vepo,

        BEGIN OF ts_mch1,
          matnr TYPE  matnr,
          charg	TYPE charg_d,
          vfdat TYPE vfdat,
          hsdat TYPE hsdat,
        END OF ts_mch1,

        BEGIN OF ts_mard,
          matnr TYPE  matnr,
          werks	TYPE werks_d,
          lgort	TYPE lgort_d,
          labst	TYPE labst,
          umlme	TYPE umlmd,
          insme	TYPE insme,
          einme	TYPE einme,
          speme	TYPE speme,
        END OF ts_mard,

        BEGIN OF ts_mchb,
          matnr TYPE  matnr,
          werks	TYPE werks_d,
          lgort	TYPE lgort_d,
          charg	TYPE charg_d,
          cumlm	TYPE umlmd,
          cinsm	TYPE insme,
          cspem	TYPE speme,
        END OF ts_mchb,

        BEGIN OF ts_lagp,
          lgnum TYPE  lgnum,
          lgtyp TYPE  lgtyp,
          lgpla TYPE  lgpla,
          lgber TYPE lgber,
        END OF ts_lagp,

        BEGIN OF ts_lein,
          lenum	TYPE lenum,
          lgnum	TYPE lgnum,
          letyp	TYPE lvs_letyp,
          lgtyp	TYPE lgtyp,
          lgpla TYPE lgpla,
        END OF ts_lein,

        BEGIN OF ts_message,
          message1 TYPE char20,
          message2 TYPE char20,
          message3 TYPE char20,
          message4 TYPE char20,
          message5 TYPE char20,
          message6 TYPE char20,
          message7 TYPE char20,
          message8 TYPE char20,
        END OF ts_message ,

        BEGIN OF ts_hustat,
          objnr TYPE  j_objnr,
          stat  TYPE  j_status,
          inact	TYPE hu_inact,
        END OF ts_hustat,

        BEGIN OF ts_hustat_i,
          istat TYPE  j_istat,

        END OF ts_hustat_i,

        BEGIN OF ts_hustat_e,
          estat TYPE  j_estat,

        END OF ts_hustat_e,

        BEGIN OF ts_tj30t,
          stsma TYPE  j_stsma,
          estat	TYPE j_estat,
          spras TYPE  spras,
          txt04	TYPE j_txt04,
          txt30	TYPE j_txt30,

        END OF ts_tj30t,

        BEGIN OF ts_tj02t,
          istat TYPE  j_istat,
          spras	TYPE spras,
          txt04	TYPE j_txt04,
          txt30	TYPE j_txt30,

        END OF ts_tj02t,

        BEGIN OF ts_venum,
          venum TYPE venum,

        END OF ts_venum,

        BEGIN OF ts_totquan,
          venum TYPE venum,
          vemng TYPE vemng,

        END OF ts_totquan.




DATA gs_menu0 TYPE ts_menu0.
DATA : gs_vepo TYPE ts_vepo.
DATA : gt_vepo TYPE STANDARD TABLE OF ts_vepo.
DATA : gs_vekp TYPE  ts_vekp.
DATA : gv_truck TYPE  zl_de_truck.
DATA : gv_qa_stat TYPE  zl_de_qastatus.
DATA : gv_temp_rec TYPE  zl_de_temp_rec_numb.
DATA : gv_temp_rec1 TYPE  zl_de_temp_rec_numb.
DATA : gv_qa_reasn TYPE  zl_de_qareason_code.
DATA : gv_rep_sam TYPE  char3.
DATA : gv_mts TYPE  char3.
DATA : gv_ind TYPE  boolean.
DATA : gt_vekp TYPE STANDARD TABLE OF ts_vekp.
DATA : go_hu        TYPE REF TO zcl_rfscanner_packunpack.

CONSTANTS : gc_back    TYPE char4 VALUE 'BACK',
            gc_clr     TYPE char3 VALUE 'CLR',
            gc_f2      TYPE char2 VALUE 'F2',
            gc_f3      TYPE char2 VALUE 'F3',
            gc_enter   TYPE char5 VALUE 'ENTER',
            gc_next    TYPE char4 VALUE 'NEXT',
            gc_ent     TYPE char3 VALUE 'ENT',
            gc_save    TYPE char4 VALUE 'SAVE',
            gc_ok      TYPE char2 VALUE 'OK',
            gc_ch1     TYPE char3 VALUE 'CH1',
            gc_msgno33 TYPE msgno VALUE '033',
            gc_ch2     TYPE char3 VALUE 'CH2',
            gc_ch3     TYPE char3 VALUE 'CH3',
            gc_rem     TYPE char3 VALUE 'REM',
            gc_up      TYPE char11 VALUE 'RLMOB-PPGUP',
            gc_dn      TYPE char11 VALUE 'RLMOB-PPGDN',
            gc_pack    TYPE char4 VALUE 'PACK',
            gc_pgdn    TYPE char4 VALUE 'PGDN',

            gc_pgup    TYPE char4 VALUE 'PGUP',
            gc_hu      TYPE char2 VALUE 'HU',
            gc_af      TYPE char2 VALUE 'AF',
            gc_lo      TYPE char2 VALUE 'LO',
            gc_bs      TYPE char2 VALUE 'BS',
            gc_1       TYPE char2 VALUE '1',
            gc_ms      TYPE char2 VALUE 'MS',
            gc_st      TYPE char2 VALUE 'ST',
            gc_qu      TYPE char2 VALUE 'QU',
            gc_flag    TYPE char1 VALUE 'X',
            gc_msgid   TYPE msgid VALUE 'ZLONE_HU',
            gc_msgno1  TYPE msgno VALUE '001'.

DATA : gv_material TYPE char19.
DATA : gv_desc TYPE char20.
DATA : gv_desc1 TYPE char20.
DATA : gv_desc2 TYPE char40.
DATA : gv_batch TYPE char14.
DATA : gv_sublot TYPE char5.
DATA : gv_bestq TYPE char9.
DATA : gv_sobkz TYPE char1.
DATA : gv_hsdat TYPE char10.
DATA : gv_exp TYPE char10.
DATA : gv_quantity TYPE char15.
DATA : gv_uom TYPE char5.
DATA : gt_mch1 TYPE STANDARD TABLE OF ts_mch1.
DATA : gs_mch1 TYPE  ts_mch1.
DATA : gv_vhilm TYPE  char18.
DATA: gv_exidv_p TYPE char18. " Added by ASAH for Pallete HU for carton
DATA : gv_maktx1 TYPE  char20.
DATA : gv_nested TYPE  char3.
DATA : gv_vegr1_l TYPE  char5.
DATA : gv_barcode  TYPE char100,
       gv_barcode1 TYPE char100,
      gv_flg_us   TYPE flag,
      gs_return   TYPE bapiret2.
DATA : gv_vegr1_h TYPE  char5.
DATA : gv_tw TYPE  char15.
DATA : gv_lw TYPE  char15.
DATA : gv_al_lw TYPE  char15.
DATA : gv_tawe TYPE  char15.
DATA : gv_gewei TYPE  char15.
DATA : gv_werks TYPE  char4.
DATA : gv_lgort TYPE  char4.
DATA : gv_lgnum TYPE  char3.
DATA : gv_lgtyp TYPE  char3.
DATA : gv_lgber TYPE  char3.
DATA : gv_lgpla TYPE  char11.
DATA : gv_cinsm TYPE  char13.
DATA : gv_batch_stat TYPE char14.
DATA : gs_multi TYPE  ts_multiple_hu.
DATA : gt_multiple_hu TYPE STANDARD TABLE OF ts_multiple_hu.
DATA : gv_cspem TYPE  char13.
DATA : gv_cumlm TYPE  char13.
DATA : gv_labst TYPE  char13.
DATA : gv_umlme TYPE  char13.
DATA : gv_insme TYPE  char13.
DATA : gv_totquan TYPE  char15.
DATA : gv_vemng TYPE  char15.
DATA : gv_count TYPE i. " Added by ASAH for Carton count in pallete.
DATA : gv_syst_stat TYPE  char12.
DATA : gv_user_stat TYPE  char10.
DATA : gv_einme TYPE  char13.
DATA : gv_speme    TYPE  char13,
       gv_message1 TYPE char20,
       gv_message2 TYPE char20,
       gv_message3 TYPE char20,
       gv_message4 TYPE char20,
       gv_message5 TYPE char20,
       gv_message6 TYPE char20,
       gv_message7 TYPE char20,
       gv_message8 TYPE char20.

DATA : gv_ch1    TYPE char1,
       gv_exidv1 TYPE exidv,
       gv_vepos1 TYPE vepos,
       gv_ch2    TYPE char1,
       gv_exidv2 TYPE exidv,
       gv_exidv4 TYPE exidv,
       gv_exidv5 TYPE exidv,
       gv_exidv6 TYPE exidv,
       gv_vepos2 TYPE vepos,
       gv_ch3    TYPE char1,
       gv_exidv3 TYPE exidv,
       gv_vepos3 TYPE vepos,
       gv_pg_cnt TYPE  i      VALUE '1'.

DATA :
* Cursor position
  gv_c       TYPE i,
* Lower limit of the record index to be displayed on a page
  gv_n1      TYPE i VALUE 1,
* Upper limit of the record index to be displayed on a page
  gv_n2      TYPE i VALUE 3,
  gv_idx     TYPE i,
* Current Line to be displayed
  gv_line    TYPE i,
* Total Rows of step-loop to be displayed on single page
  gv_lines   TYPE i,
* Final Limit of step loop rows that can be displayed
  gv_limit   TYPE i,
* Variable to handle next page navigation
  gv_v_next  TYPE    i,
* Variable to handle previous page navigation
  gv_v_prev  TYPE    i,
  gv_v_limit TYPE i.

DATA : gv_v_index TYPE sy-index.
DATA : gv_lv_d       TYPE f,
       gv_lv_div     TYPE i,
       gv_curr_p_num TYPE i,
       gv_p_num      TYPE i.

TYPES : gtt_vepo TYPE STANDARD TABLE OF ts_vepo.
TYPES : gtt_multiple_hu TYPE STANDARD TABLE OF ts_multiple_hu.
