FUNCTION zits_set_order_data_buffer.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_ORDER_DATA) TYPE  ZSMTD_ORDER_DETAIL
*"----------------------------------------------------------------------

  CLEAR gs_order_data.

  MOVE is_order_data TO gs_order_data.

ENDFUNCTION.
