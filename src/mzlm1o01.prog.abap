*----------------------------------------------------------------------*
***INCLUDE MZLM1O01 .
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       Module  SET_STATUS  OUTPUT
*----------------------------------------------------------------------*
module set_status output.

  case sy-dynnr.
    when '0100' or '0300'.
      if sy-tcode = 'ZLM1' or
         sy-tcode = 'ZLM1S'.
        set titlebar '100'.
      else.
        set titlebar '100H'.
      endif.
      set pf-status '100'.
      zz_dynnr_alt = sy-dynnr.
    when '0200' or '0400'.
      if sy-tcode = 'ZLM1' or
         sy-tcode = 'ZLM1S'.
        set titlebar '200'.
      else.
        set titlebar '200H'.
      endif.
      set pf-status '200'.
      zz_dynnr_alt = sy-dynnr.
    when '0999'.
      set titlebar '999'.
      set pf-status '999'.
    when '1001'.
      set titlebar '1001'.
      set pf-status'1001'.
  endcase.

endmodule.                             " SET_STATUS  OUTPUT

*---------------------------------------------------------------------*
*       MODULE FILL_D100 OUTPUT                                       *
*---------------------------------------------------------------------*
module fill_d100 output.

*  clear: zz_lenum, zz_charg.
  if not zz_matnr is initial.
    write zz_matnr to zz_matnr_lang using edit mask '==MATN1'.
  else.
    clear zz_matnr_lang.
  endif.

  if zz_menge_p = 0 and not zz_menge is initial.
  else.
    write: zz_menge_p to zz_menge no-zero no-grouping
                                  no-sign decimals 3.
  endif.

  zz_prod = sy-datum.
  zz_budat = sy-datum.

  if zz_cursor_feld is initial.
*    zz_cursor_feld = 'ZZ_MATNR'.
    zz_cursor_feld = 'ZZ_MATNR_LANG'.
  endif.
  set cursor field zz_cursor_feld.

endmodule.                             " FILL_D100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init_d200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module init_d200 output.

  scr_matnr = zz_matnr+10(8).
  scr_halb = zz_halb+10(8).

  zz_cursor_feld = 'RLMOB-PENTER'.

  set cursor field zz_cursor_feld.

endmodule.                 " init_d200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_D300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module fill_d300 output.

*  clear: zz_lenum, zz_charg.
  if not zz_matnr is initial.
    write zz_matnr to zz_matnr_lang using edit mask '==MATN1'.
  else.
    clear zz_matnr_lang.
  endif.

  if zz_menge_p = 0 and not zz_menge is initial.
  else.
    write: zz_menge_p to zz_menge no-zero no-grouping
                                  no-sign decimals 3.
  endif.

  zz_prod = sy-datum.
  zz_budat = sy-datum.

  if zz_cursor_feld is initial.
    zz_cursor_feld = 'ZZ_MATNR_LANG'.
  endif.

  set cursor field zz_cursor_feld.

  if sy-tcode = 'ZLM1S'.

    zz_lgort = '0190'.
    lv_werks_n = '0001'.
    lv_lgort_n = '3980'.

  endif.

endmodule.                 " FILL_D300  OUTPUT
