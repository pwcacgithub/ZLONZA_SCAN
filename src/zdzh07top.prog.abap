*&---------------------------------------------------------------------*
*&  Include           DZH07TOP
*&---------------------------------------------------------------------*


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


DATA: go_hu       TYPE REF TO zcl_rfscanner_postgi,
      gs_hu       TYPE zcl_rfscanner_postgi=>ts_likp,
      gs_likp     TYPE zcl_rfscanner_postgi=>ts_likp,
      gv_error1   TYPE xfeld,
      gv_error3   TYPE xfeld,
      gv_noerror  TYPE xfeld,
      gv_venname  TYPE name1_gp,
      gv_shname   TYPE name1_gp,
      gv_message1 TYPE char50,
      gv_message2 TYPE char50,
      gv_message3 TYPE char50,
      gv_message4 TYPE char50,
      gv_message5 TYPE char50,
      gv_message6 TYPE char50,
      gv_message7 TYPE char50,
      gv_message8 TYPE char50.
*       Batchinputdata of single transaction
DATA:   BDCDATA LIKE BDCDATA    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

CONSTANTS:  gc_back  TYPE char4 VALUE 'BACK',
            gc_ok    TYPE char2 VALUE 'OK',
            gc_clr   TYPE char3 VALUE 'CLR',
            gc_f2    TYPE char2 VALUE 'F2',
            gc_f3    TYPE char2 VALUE 'F3',
            gc_enter TYPE char5 VALUE 'ENTER',
            gc_next  TYPE char4 VALUE 'NEXT',
            gc_ent   TYPE char3 VALUE 'ENT',
            gc_i     TYPE c     VALUE 'I',
            gc_e     TYPE c     VALUE 'E',
            gc_pgi   TYPE char3 VALUE 'PGI',
            gc_cre   TYPE char3 VALUE 'CRE',
            gc_msgid TYPE msgid VALUE 'ZLONE_HU',
            gc_pgibu TYPE char6 VALUE 'F1_PGI',
            gc_x     TYPE c VALUE 'X'..
