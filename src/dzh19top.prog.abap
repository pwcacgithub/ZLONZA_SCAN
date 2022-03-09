*&---------------------------------------------------------------------*
*&  Include           DZH19TOP
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ts_vekp,
         venum             TYPE vekp-venum,
         exidv             TYPE vekp-exidv,
         zztruck           TYPE vekp-zztruck,
         zzqa_status       TYPE zl_de_qastatus,
         zzqareason_code   TYPE zl_de_qareason_code,
         zzrep_sample_insi TYPE zl_de_rep_sample_ins,
         zztemp_reco       TYPE zl_de_temp_rec,
         zztemp_rec_numb   TYPE zl_de_temp_rec_numb,
       END OF ts_vekp.

TYPES:    BEGIN OF ts_message,
            message1 TYPE char20,
            message2 TYPE char20,
            message3 TYPE char20,
            message4 TYPE char20,
            message5 TYPE char20,
            message6 TYPE char20,
            message7 TYPE char20,
            message8 TYPE char20,
          END OF ts_message .

DATA: go_hu              TYPE REF TO zcl_rfscanner_packunpack,
      gs_hu              TYPE zcl_rfscanner_packunpack=>ts_phu,
      gt_vekp            TYPE STANDARD TABLE OF vekp,
      gs_vekp            LIKE LINE OF gt_vekp,
      gv_qa_status       TYPE char10,
      gv_hu              TYPE char100,
      gv_qa_reason       TYPE char10,
      gv_exidv           TYPE exidv,
      gv_lbarcode        TYPE char100,
      gv_message1        TYPE char50,
      gv_message2        TYPE char50,
      gv_message3        TYPE char50,
      gv_message4        TYPE char50,
      gv_message5        TYPE char50,
      gv_message6        TYPE char50,
      gv_message7        TYPE char50,
      gv_message8        TYPE char50,
      gv_rep             TYPE vekp-zzrep_sample_insi,
      gv_truck           TYPE vekp-zztruck,
      gv_zztemp_reco     TYPE vekp-zztemp_reco,
      gv_zztemp_rec_numb TYPE vekp-zztemp_rec_numb.

DATA : ls_zl_vekp_cust_upd   TYPE zl_vekp_cust_upd,
       ls_zl_vekp_cust_upd_x TYPE zls_vekp_cust_upd_x.

CONSTANTS: gc_next     TYPE char4 VALUE 'NEXT',
           gc_save     TYPE char4 VALUE 'SAVE',
           gc_enter    TYPE char5 VALUE 'ENT',
           gc_back     TYPE char4 VALUE 'BACK',
           gc_quit     TYPE char4 VALUE 'QUIT',
           gc_f2       TYPE char2 VALUE 'F2',
           gc_f3       TYPE char2 VALUE 'F3',
           gc_f4       TYPE char2 VALUE 'F4',
           gc_f5       TYPE char2 VALUE 'F5',
           gc_f8       TYPE char2 VALUE 'F8',
           gc_f9       TYPE char2 VALUE 'F9',
           gc_back2    TYPE char5 VALUE 'BACK',
           gc_back3    TYPE char5 VALUE 'BACK',
           gc_ok       TYPE char2 VALUE 'OK',
           gc_dis_chng TYPE char4 VALUE 'DISPLAY/CHANGE',
           gc_msgid    TYPE msgid VALUE 'ZLONE_HU',
           gc_msgno3   TYPE msgno VALUE '138',
           gc_msgno6   TYPE msgno VALUE '148',
           gc_msgno7   TYPE msgno VALUE '149',
           gc_msgno8   TYPE msgno VALUE '150',
           gc_msgno9   TYPE msgno VALUE '151',
           gc_msgno10  TYPE msgno VALUE '152'.

DATA : lv_msgv1 TYPE msgv1,
       lv_msgno TYPE msgno,
       lv_msgid TYPE msgid.
