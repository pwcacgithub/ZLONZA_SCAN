class ZCL_MDE_START_TRANSACTION definition
  public
  final
  create public .

*"* public components of class ZCL_MDE_START_TRANSACTION
*"* do not include other source files here!!!
public section.

  class-methods RUN .
protected section.
*"* protected components of class ZCL_MDE_START_TRANSACTION
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_MDE_START_TRANSACTION
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_MDE_START_TRANSACTION IMPLEMENTATION.


method run.

  data: lt_parameters type standard table of bapiparam,
        ls_parameter type bapiparam,
        lt_return type standard table of bapiret2,
        ls_return type bapiret2,
        lv_transaction type tcode.

* get user parameters
  call function 'BAPI_USER_GET_DETAIL'
    exporting
      username  = sy-uname
    tables
      parameter = lt_parameters
      return    = lt_return.

* find user parameter Z_START_MDE
  loop at lt_parameters into ls_parameter.
    case ls_parameter-parid.
      when 'Z_START_MDE'.
        lv_transaction = ls_parameter-parva.
    endcase.
  endloop.

* start transaction
  if lv_transaction = 'ZRFM' or lv_transaction = 'ZRFMENU'.
    leave to transaction lv_transaction.
  else.
    leave to transaction 'ZLM0'.
  endif.

endmethod.
ENDCLASS.
