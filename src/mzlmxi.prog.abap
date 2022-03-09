*----------------------------------------------------------------------*
***INCLUDE MZLMXI .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  org_daten  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module org_daten output.

  zz_mandt = sy-mandt.

  refresh:z_user_parameters,z_user_return.

  call function 'BAPI_USER_GET_DETAIL'
    exporting
      username  = sy-uname
    tables
      parameter = z_user_parameters
      return    = z_user_return.

  loop at z_user_parameters where parid = 'WRK'.
    if zz_werks is initial.
      zz_werks = z_user_parameters-parva.
    endif.
  endloop.
  if zz_werks is initial.
    get parameter id 'WRK' field zz_werks.
    if zz_werks is initial.
*   Bitte Parameter WRK (Werk) im Benutzerstamm pflegen!
      perform show_message using '148' '' '' '' ''.
      call screen '0999'.
    endif.
  endif.

* BUKRS anhand Werk feststellen
  loop at z_user_parameters where parid = 'BUK'.
    if zz_bukrs is initial.
      zz_bukrs = z_user_parameters-parva.
    endif.
  endloop.
  if zz_bukrs is initial.
    select single * from t001k into ls_t001k where bwkey = zz_werks.
    if sy-subrc eq 0.
      zz_bukrs = ls_t001k-bukrs.
      set parameter id 'BUK' field zz_bukrs.
    endif.
    if zz_bukrs is initial.
*   Buchungskreis konnte nicht anhand vom Werk ermittelt werden!
      perform show_message using '179' zz_werks '' '' ''.
      call screen '0999'.
    endif.
  endif.

  loop at z_user_parameters where parid = 'LAG'.
    if zz_lgort is initial.
      zz_lgort = z_user_parameters-parva.
    endif.
  endloop.
  if zz_lgort is initial.
    get parameter id 'LAG' field zz_lgort.
    if zz_lgort is initial.
*   Bitte Parameter LAG (Lagerort) im Benutzerstamm pflegen!
      perform show_message using '149' '' '' '' ''.
      call screen '0999'.
    endif.
  endif.

  loop at z_user_parameters where parid = 'LGN'.
    if zz_lgnum is initial.
      zz_lgnum = z_user_parameters-parva.
    endif.
  endloop.
  if zz_lgnum is initial.
    get parameter id 'LGN' field zz_lgnum.
    if zz_lgnum is initial.
*   Bitte Parameter LGN (Lagernummer) im Benutzerstamm pflegen!
      perform show_message using '150' '' '' '' ''.
      call screen '0999'.
    endif.
  endif.

  if zz_lgtyp is initial.
    get parameter id 'LGT' field zz_lgtyp.
  endif.

endmodule.                 " org_daten  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  org_daten_test  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module org_daten_test output.

* * Vorschlagswerte aus dem Benutzerstamm holen
  if zz_werks is initial or
     zz_lgort is initial or
     zz_lgnum is initial.

    call function 'BAPI_USER_GET_DETAIL'
      exporting
        username  = sy-uname
      tables
        parameter = z_user_parameters
        return    = z_user_return.

    loop at z_user_parameters.
      case z_user_parameters-parid.
        when 'WRK'.
          zz_werks = z_user_parameters-parva.
        when 'LAG'.
          zz_lgort = z_user_parameters-parva.
        when 'LGN'.
          zz_lgnum = z_user_parameters-parva.
      endcase.
    endloop.

  endif.


  if zz_bukrs is initial.
    get parameter id 'BUK' field zz_bukrs.
    if zz_bukrs is initial.
*     Bitte Parameter BUK (Buchnungskreis) im Benutzerstamm pflegen!
      perform show_message using '147' '' '' '' ''.
      call screen '0999'.
    endif.
  endif.
  if zz_werks is initial.
    get parameter id 'WRK' field zz_werks.
    if zz_werks is initial.
*     Bitte Parameter WRK (Werk) im Benutzerstamm pflegen!
      perform show_message using '148' '' '' '' ''.
      call screen '0999'.
    endif.
  endif.
  if zz_lgort is initial.
    get parameter id 'LAG' field zz_lgort.
    if zz_lgort is initial.
*     Bitte Parameter LAG (Lagerort) im Benutzerstamm pflegen!
      perform show_message using '149' '' '' '' ''.
      call screen '0999'.
    endif.
  endif.
  if zz_lgnum is initial.
    get parameter id 'LGN' field zz_lgnum.
    if zz_lgnum is initial.
*     Bitte Parameter LGN (Lagernummer) im Benutzerstamm pflegen!
      perform show_message using '150' '' '' '' ''.
      call screen '0999'.
    endif.
  endif.

endmodule.                 " org_daten_test  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_MENU_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module get_menu_data output.

  clear: lt_menu,
         lv_line_1,
         lv_line_2,
         lv_line_3,
         lv_line_4,
         lv_line_5,
         lv_line_6,
         lv_line_7,
         lv_line_8.
  if lv_stufe is initial.
    if lv_stufe is initial.
      lv_stufe = 1.
    endif.
  endif.

  select * from zmde_menu into corresponding fields of table lt_menu
                          where werks = zz_werks and
                                stufe = lv_stufe.

  loop at lt_menu into ls_menu.

    select single * from zmde_menu_text into ls_zmde_menu_text
                    where nummer = ls_menu-nummer and
                          spras = sy-langu.
    if sy-subrc ne 0.
      clear ls_zmde_menu_text.
    endif.
    concatenate ls_menu-zeile '.' into ls_menu-text2.
    concatenate ls_menu-text2 ls_zmde_menu_text-text into ls_menu-text2 separated by ' '.
    modify lt_menu from ls_menu.

    case sy-tabix.
      when 1.
        lv_line_1 = ls_menu-text2.
      when 2.
        lv_line_2 = ls_menu-text2.
      when 3.
        lv_line_3 = ls_menu-text2.
      when 4.
        lv_line_4 = ls_menu-text2.
      when 5.
        lv_line_5 = ls_menu-text2.
      when 6.
        lv_line_6 = ls_menu-text2.
      when 7.
        lv_line_7 = ls_menu-text2.
      when 8.
        lv_line_8 = ls_menu-text2.
    endcase.

  endloop.

  if lv_stufe = 1.
    loop at screen.
      case screen-name.
        when 'RLMOB-PBACK'.
          screen-invisible = '1'.
          modify screen.
      endcase.
    endloop.
  endif.

endmodule.                 " GET_MENU_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ORG_DATEN_CLEAR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module org_daten_clear output.
*User want to clear the data from previous operation. Gerry Li
  if zz_alles_freigeben = 'J'.
    clear:   zz_lgpla_v,      "
             zz_matnr,
             zz_meins,
             zz_menge,
             zz_matnr_lang,
             scr_charg.
    zz_alles_freigeben = 'N'.
  endif.

endmodule.                 " ORG_DATEN_CLEAR  OUTPUT
