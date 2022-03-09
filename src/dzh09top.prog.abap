*&---------------------------------------------------------------------*
*& Include DZH09TOP                                          Module Pool      SAPDZH09
*&
*&---------------------------------------------------------------------*

PROGRAM sapdzh09.

TYPES :   BEGIN OF ts_message,
            message1 TYPE char20,
            message2 TYPE char20,
            message3 TYPE char20,
            message4 TYPE char20,
            message5 TYPE char20,
            message6 TYPE char20,
            message7 TYPE char20,
            message8 TYPE char20,
          END OF ts_message .

TYPES : BEGIN OF ts_child_hu,
          venum TYPE vekp-venum,
          exidv TYPE vekp-exidv,
        END OF ts_child_hu.
TYPES : tt_child_hu TYPE STANDARD TABLE OF ts_child_hu.
DATA : gs_hu      TYPE zcl_rfscanner_packunpack=>ts_phu,
*Structure to hold the messages
       ##NEEDED
       gs_message TYPE ts_message.

DATA: gv_msg1     TYPE char18,
      gv_msg2     TYPE char18,
      gv_message1 TYPE char20,
      gv_message2 TYPE char20,
      gv_message3 TYPE char20,
      gv_message4 TYPE char20,
      gv_message5 TYPE char20,
      gv_message6 TYPE char20,
      gv_message7 TYPE char20,
      gv_message8 TYPE char20,
      ##NEEDED
      gv_no       TYPE dynnr,
      gv_barcode  TYPE char100,
      gv_barcode1 TYPE char100,
      go_hu       TYPE REF TO zcl_rfscanner_packunpack,
      gv_flg_us   TYPE flag,
      gs_return   TYPE bapiret2,
      gv_unpack   TYPE flag. "by ASAH for Unpacking Pallete

CONSTANTS : gc_back   TYPE char4 VALUE 'BACK',
            gc_clear  TYPE char3 VALUE 'CLR',
            gc_enter  TYPE char5 VALUE 'ENTER',
            gc_delete TYPE char6 VALUE 'DELETE',
            gc_yes    TYPE char3 VALUE 'YES',
            gc_no     TYPE char3 VALUE 'NO',
            gc_ok     TYPE char2 VALUE 'OK',
            gc_screen TYPE char5 VALUE 'DYNNR',
            gc_f3     TYPE char2 VALUE 'F3'.
* Check the response and proceed further
