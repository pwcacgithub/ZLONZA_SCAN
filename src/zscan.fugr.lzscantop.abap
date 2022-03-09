FUNCTION-POOL zscan   .
*MESSAGE-ID zscan. ##MG_MISSING

INCLUDE zsits_common_top.

TABLES: zsits_scan_message.

CONSTANTS: gc_dynp_enable  TYPE char01 VALUE '1',
           gc_dynp_disable TYPE char01 VALUE '0'.

DATA: gs_message TYPE rlmob,
      ok_code    TYPE sy-ucomm.

DATA: gv_confirm_ind    TYPE xfeld,
      gv_confirm_result TYPE char01.

* INCLUDE LZSCAND...                         " Local class definition
