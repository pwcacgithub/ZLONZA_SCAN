FUNCTION ZITS_GET_ORDER_DATA_BUFFER.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_ORDER_NUM) TYPE  AUFNR
*"  EXPORTING
*"     REFERENCE(ES_ORDER_DATA) TYPE  ZSMTD_ORDER_DETAIL
*"----------------------------------------------------------------------

  CHECK iv_order_num = gs_order_data-header_line-order_number.

  MOVE gs_order_data TO es_order_data .

ENDFUNCTION.
