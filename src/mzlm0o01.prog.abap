*----------------------------------------------------------------------*
***INCLUDE MZLM0O01 .
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       Module  SET_STATUS  OUTPUT
*----------------------------------------------------------------------*
module set_status output.

  case sy-dynnr.
    when '0100'.
      set titlebar '100'.
      set pf-status '100'.
    when '0999'.
      set titlebar '999'.
      set pf-status '999'.
  endcase.

endmodule.                             " SET_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init_d100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module init_d100 output.

  clear: zz_ausw.

endmodule.                 " init_d100  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_MENU_2'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC_MENU_2_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE LT_MENU LINES TC_MENU_2-lines.
ENDMODULE.
