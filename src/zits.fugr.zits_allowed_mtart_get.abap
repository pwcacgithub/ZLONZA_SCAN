FUNCTION ZITS_ALLOWED_MTART_GET.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(ET_ALLOWED_MTART) TYPE  ZTTITS_MTART_TAB
*"----------------------------------------------------------------------


  et_allowed_mtart = gt_allowed_mtart.


*???? Below logic will be removed
  if et_allowed_mtart is initial.
     select * into table et_allowed_mtart from ZTITS_MTART.
 endif.

ENDFUNCTION.
