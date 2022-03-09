*----------------------------------------------------------------------*
***INCLUDE MZLM1I01 .
*----------------------------------------------------------------------*
module exit_command input.

  case sy-dynnr.
    when '0100' or '0300'.
      case ok_code.
        when 'BACK'.
          leave to transaction 'ZLM0'.
      endcase.
    when '0200' or '0400'.
      case ok_code.
        when 'BACK'.
*         *** Alle Sperreinträge löschen ***
          perform sperreintraege_loeschen.
          leave to screen 0.
      endcase.
    when '0999'.
      case ok_code.
        when 'BACK'.
          if ( zz_dynnr_alt = '0100' or zz_dynnr_alt = '0300' ) and
             zz_alles_freigeben = 'J'.
            leave to current transaction.
          else.
            case zz_dynnr_alt.
              when '0100' or '0200'.
                leave to screen 0100.
              when '0300' or '0400'.
                leave to screen 0300.
            endcase.
          endif.
      endcase.
    when '1001'.
      case ok_code.
        when 'BACK'.
          perform show_message using '022' zz_beleg_nr zz_beleg_nr_halb '' ''.
          case sy-tcode.
            when 'ZLM1' or 'ZLM1H'.
              zz_dynnr_alt = '0100'.
            when 'ZLM1S'.
              zz_dynnr_alt = '0300'.
          endcase.
          zz_alles_freigeben = 'J'.
          call screen 999.
      endcase.
  endcase.

endmodule.                             " EXIT_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_D100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module check_d100 input.

* Barcode bearbeiten und evtl. aufloesen
  call method zcl_mde_barcode=>disolve_barcode
    exporting
      iv_barcode = zz_matnr_lang
      iv_werks   = zz_werks
    importing
      ev_matnr   = zz_matnr
      ev_charg   = zz_charg
      ev_menge   = zz_menge
      ev_fauf    = lv_fauf
      ev_fehler  = lv_fehler.

  select single * from t320 where werks = zz_werks and
                                  lgort = zz_lgort and
                                  lgnum = zz_lgnum.
  if sy-subrc eq 0.
    sw_mit_lvs = 'J'.
  else.
    sw_mit_lvs = 'N'.
  endif.

* * Falls gew. Felder schon da sind ohne Fehler auf LE-Nr. springen *
  if not zz_matnr is initial and
     not zz_charg is initial and
     not zz_menge is initial.
    if zz_lenum is initial and sw_mit_lvs = 'J'.
      zz_cursor_feld = 'ZZ_LENUM'.
      call screen '0100'.
    endif.
  endif.
* Mussfelder testen
  if zz_werks is initial.
    clear ok_code.
*     * Fehlertext aufsplitten *
    m_fehler text-e01 25.
    zz_cursor_feld = 'ZZ_WERKS'.
    call screen '0999'.
  else.
    if zz_lgort is initial.
      clear ok_code.
*       * Fehlertext aufsplitten *
      m_fehler text-e02 25.
      zz_cursor_feld = 'ZZ_LGORT'.
      call screen '0999'.
    else.
      if zz_lgnum is initial and sw_mit_lvs = 'J'.
        perform show_message using '024' '' '' '' ''.
        zz_cursor_feld = 'ZZ_LGNUM'.
        call screen '0999'.
      else.
        if zz_matnr is initial.
          clear ok_code.
          perform show_message using '025' '' '' '' ''.
          zz_cursor_feld = 'ZZ_MATNR_LANG'.
          call screen '0999'.
        else.
          if zz_menge is initial.
            clear ok_code.
            perform show_message using '002' zz_menge '' '' ''.
            zz_cursor_feld = 'ZZ_MENGE'.
            call screen '0999'.
          else.
            if zz_prod is initial.
              clear ok_code.
              perform show_message using '026' '' '' '' ''.
              zz_cursor_feld = 'ZZ_PROD'.
              call screen '0999'.
            else.
              if zz_budat is initial.
                clear ok_code.
                perform show_message using '027' '' '' '' ''.
                zz_cursor_feld = 'ZZ_BUDAT'.
                call screen '0999'.
              endif.
            endif.
          endif.
        endif.
      endif.
    endif.
  endif.

  if sw_mit_lvs = 'N'.
    zz_lgnum = '   '.
  endif.

* Werk testen
  select single * from t001w where werks = zz_werks.
  if sy-subrc ne 0.
    clear ok_code.
    perform show_message using '028' zz_werks '' '' ''.
    zz_cursor_feld = 'ZZ_WERKS'.
    call screen '0999'.
  else.
    set parameter id 'WRK' field zz_werks.
  endif.

* Lagerort testen
  if not zz_lgort is initial.
    select single * from t001l where werks = zz_werks
                         and lgort = zz_lgort.
    if sy-subrc ne 0.
      clear ok_code.
      perform show_message using '029' zz_lgort '' '' ''.
      zz_cursor_feld = 'ZZ_LGORT'.
      call screen '0999'.
    else.
      set parameter id 'LAG' field zz_lgort.
    endif.
  endif.

* Material-Stamm lesen
  select single * from mara
  where matnr = zz_matnr.
  if sy-subrc ne 0.
    clear ok_code.
    perform show_message using '003' zz_matnr '' '' ''.
    zz_cursor_feld = 'ZZ_MATNR_LANG'.
    clear zz_matnr.
    call screen '0999'.
  endif.
  zz_meins = mara-meins.

  if sw_mit_lvs = 'N' and mara-mtart = 'FERT'.
    clear ok_code.
    perform show_message using '030' '' '' '' ''.
    zz_cursor_feld = 'ZZ_LGORT'.
    call screen '0999'.
  endif.

* nur Materialart FERT und HALB sind gültig
  if sy-subrc = 0 and
   ( mara-mtart = 'FERT' or
     mara-mtart = 'HALB' ).
    if mara-mtart = 'FERT'.
      sw_halb = 'N'.
    else.
      sw_halb = 'J'.
    endif.
  else.
    clear ok_code.
    perform show_message using '031' zz_matnr '' '' ''.
    zz_cursor_feld = 'ZZ_MATNR_LANG'.
    clear zz_matnr.
    call screen '0999'.
  endif.

* Material-C-Segment lesen
  select single * from marc
  where matnr = zz_matnr
  and   werks = zz_werks.

  zz_dispo = marc-dispo.
  zz_fevor = marc-fevor.

* Material muss im selektierten Werk eröffnet sein
  if sy-subrc ne 0.
    clear ok_code.
    perform show_message using '032' zz_matnr zz_werks '' ''.
    zz_cursor_feld = 'ZZ_MATNR_LANG'.
    call screen '0999'.
  endif.

* Material-D-Segment lesen
  select single * from mard
  where matnr = zz_matnr
  and   werks = zz_werks
  and   lgort = zz_lgort.

* Material muss im selektierten Lagerort eröffnet sein
  if sy-subrc ne 0.
    clear ok_code.
    perform show_message using '033' zz_matnr zz_lgort '' ''.
    zz_cursor_feld = 'ZZ_MATNR_LANG'.
    call screen '0999'.
  endif.

  if sw_mit_lvs = 'J'.
*   Lagernummer-Segment lesen
    select single * from mlgn
    where matnr = zz_matnr
    and   lgnum = zz_lgnum.

*   Material muss für selektierte Lagernummer eröffnet sein
    if sy-subrc ne 0.
      clear ok_code.
      perform show_message using '034' zz_matnr zz_lgnum '' ''.
      zz_cursor_feld = 'ZZ_MATNR_LANG'.
      call screen '0999'.
    endif.

*   Einlagertyp-Kennzeichen muss gepflegt sein
    if mlgn-ltkze is initial.
      clear ok_code.
      perform show_message using '035' zz_matnr '' '' ''.
      zz_cursor_feld = 'ZZ_MATNR_LANG'.
      call screen '0999'.
    endif.
*   LHM-Menge muss > 0 sein
    if mlgn-lhmg1 is initial.
      clear ok_code.
      perform show_message using '036' zz_matnr '' '' ''.
      zz_cursor_feld = 'ZZ_MATNR_LANG'.
      call screen '0999'.
    endif.
*   LHM-ME muss gepflegt sein
    if mlgn-lhme1 is initial.
      clear ok_code.
      perform show_message using '037' zz_matnr '' '' ''.
      zz_cursor_feld = 'ZZ_MATNR_LANG'.
      call screen '0999'.
    endif.
*   Lagereinheitentyp muss gepflegt sein
    if mlgn-lety1 is initial.
      clear ok_code.
      perform show_message using '038' zz_matnr '' '' ''.
      zz_cursor_feld = 'ZZ_MATNR_LANG'.
      call screen '0999'.
    endif.

    zz_lgtyp = mlgn-ltkze.
  endif.

* Falls Material chargenpflichtig ist, so ist Batch-Nr. obligatorisch
  if mara-xchpf ne ' '.
    zz_fert_xchpf = mara-xchpf.
    if zz_charg is initial.
      clear ok_code.
      perform show_message using '039' zz_matnr '' '' ''.
      zz_cursor_feld = 'ZZ_CHARG'.
      call screen '0999'.
    endif.
    select single * from mch1 into ls_mch1
                 where matnr = zz_matnr and
                       charg = zz_charg.
    if sy-subrc eq 0 and ls_mch1-hsdat is not initial.
*     falls charge existiert wird existierendes Produktionsdatum vorgegeben
      zz_prod = ls_mch1-hsdat.
    endif.
  endif.

* Menge testen
  perform menge_testen.

* LE-Nummer-Verwaltung aktiv??
  select single * from t340d where lgnum = zz_lgnum and
                                   lenvw = 'X'.
  if sy-subrc eq 0.
    if not zz_lenum is initial.
* LE-Nummer testen
      perform le_testen.
    else.
      clear ok_code.
      perform show_message using '040' '' '' '' ''.
      zz_cursor_feld = 'ZZ_LENUM'.
      call screen '0999'.
    endif.
  endif.

  zz_akt_monat = sy-datum.
  zz_akt_monat+6(2) = 01.
  zz_akt_monat = zz_akt_monat + 31.
  zz_akt_monat+6(2) = 01.
  zz_akt_monat = zz_akt_monat - 01.
  zz_vor_monat = sy-datum.
  zz_vor_monat+6(2) = 01.
  zz_vor_monat = zz_vor_monat - 1.
  zz_vor_monat+6(2) = 01.

* Produktionsdatum Laufender- oder Vormonat
  if zz_prod le zz_akt_monat.
  else.
    clear ok_code.
    perform show_message using '206' zz_prod '' '' ''.
    zz_cursor_feld = 'ZZ_PROD'.
    call screen '0999'.
  endif.

* Buchungsdatum Laufender- oder Vormonat
  if zz_budat ge zz_vor_monat and
  zz_budat le zz_akt_monat.
  else.
    clear ok_code.
    perform show_message using '041' zz_budat '' '' ''.
    zz_cursor_feld = 'ZZ_BUDAT'.
    call screen '0999'.
  endif.

  if sw_halb = 'N'.

*   *** Halb_Nr. feststellen ***
    perform halb_nr_feststellen using mara-matnr
                                changing zz_halb.
    if zz_halb is initial.
*      Gerry Li, add the conversion Exit for the materila converting from old materailal number to the SAP internal number.
      call function 'CONVERSION_EXIT_MATN1_INPUT'
        exporting
          input        = mara-bismt
        importing
          output       = zz_halb
        exceptions
          length_error = 1
          others       = 2.

    endif.

    select single * from mara where matnr = zz_halb.
    if sy-subrc ne 0.
      clear ok_code.
      perform show_message using '042' '' '' '' ''.
      zz_cursor_feld = 'ZZ_MATNR_LANG'.
      call screen '0999'.
    endif.

    zz_halb_xchpf = mara-xchpf.

*   MARC für HALB lesen um Produktionslagerort zu holen
    select single * from marc where matnr = zz_halb and
                                    werks = zz_werks.

    if sy-subrc ne 0.
      clear ok_code.
      perform show_message using '042' '' '' '' ''.
      zz_cursor_feld = 'ZZ_MATNR_LANG'.
      call screen '0999'.
    endif.

  else.
    zz_halb = mara-matnr.
    zz_halb_xchpf = mara-xchpf.
  endif.

* Daten lesen und vorbereiten
  perform daten_lesen.

endmodule.                             " CHECK_D100  INPUT

*---------------------------------------------------------------------*
*       MODULE USER_COMMANDS INPUT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module user_commands input.

  case sy-dynnr.
    when '0100'.
      perform process_ok_codes_0100.
    when '0200' or '0400'.
      perform process_ok_codes_0200.
    when '0300'.
      perform process_ok_codes_0300.
    when '1001'.
      perform process_ok_codes_1001.
  endcase.

endmodule.                             " USER_COMMANDS  INPUT

*---------------------------------------------------------------------*
*       MODULE COPY_OK_CODE INPUT                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module copy_ok_code input.

  save_ok_code = ok_code.
  clear ok_code.

endmodule.                             " COPY_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_D300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module check_d300 input.

* Barcode bearbeiten und evtl. aufloesen
  call method zcl_mde_barcode=>disolve_barcode
    exporting
      iv_barcode = zz_matnr_lang
      iv_werks   = zz_werks
    importing
      ev_matnr   = zz_matnr
      ev_charg   = zz_charg
      ev_menge   = zz_menge
      ev_fauf    = lv_fauf
      ev_fehler  = lv_fehler.

*   with transaction ZLM1S allways without WM
  sw_mit_lvs = 'N'.

* Mussfelder testen
  if zz_werks is initial.
    clear ok_code.
*   * Fehlertext aufsplitten *
    m_fehler text-e01 25.
    zz_cursor_feld = 'ZZ_WERKS'.
    call screen '0999'.
  else.
    if zz_lgort is initial.
      clear ok_code.
*     * Fehlertext aufsplitten *
      m_fehler text-e02 25.
      zz_cursor_feld = 'ZZ_LGORT'.
      call screen '0999'.
    else.
      if zz_matnr is initial.
        clear ok_code.
        perform show_message using '025' '' '' '' ''.
        zz_cursor_feld = 'ZZ_MATNR_LANG'.
        call screen '0999'.
      else.
        if zz_menge is initial.
          clear ok_code.
          perform show_message using '002' zz_menge '' '' ''.
          zz_cursor_feld = 'ZZ_MENGE'.
          call screen '0999'.
        else.
          if zz_prod is initial.
            clear ok_code.
            perform show_message using '026' '' '' '' ''.
            zz_cursor_feld = 'ZZ_PROD'.
            call screen '0999'.
          else.
            if zz_budat is initial.
              clear ok_code.
              perform show_message using '027' '' '' '' ''.
              zz_cursor_feld = 'ZZ_BUDAT'.
              call screen '0999'.
            endif.
          endif.
        endif.
      endif.
    endif.
  endif.

  if sw_mit_lvs = 'N'.
    zz_lgnum = '   '.
  endif.

* Werk testen
  select single * from t001w where werks = zz_werks.
  if sy-subrc ne 0.
    clear ok_code.
    perform show_message using '028' zz_werks '' '' ''.
    zz_cursor_feld = 'ZZ_WERKS'.
    call screen '0999'.
  else.
    set parameter id 'WRK' field zz_werks.
  endif.

* Lagerort testen
  if not zz_lgort is initial.
    select single * from t001l where werks = zz_werks
                         and lgort = zz_lgort.
    if sy-subrc ne 0.
      clear ok_code.
      perform show_message using '029' zz_lgort '' '' ''.
      zz_cursor_feld = 'ZZ_LGORT'.
      call screen '0999'.
    else.
      set parameter id 'LAG' field zz_lgort.
    endif.
  endif.

* Material-Stamm lesen
  select single * from mara
  where matnr = zz_matnr.
  if sy-subrc ne 0.
    clear ok_code.
    perform show_message using '003' zz_matnr '' '' ''.
    zz_cursor_feld = 'ZZ_MATNR_LANG'.
    clear zz_matnr.
    call screen '0999'.
  endif.
  zz_meins = mara-meins.

* nur Materialart FERT und HALB sind gültig
  if sy-subrc = 0 and
   ( mara-mtart = 'FERT' or
     mara-mtart = 'HALB' ).
    if mara-mtart = 'FERT'.
      sw_halb = 'N'.
    else.
      sw_halb = 'J'.
    endif.
  else.
    clear ok_code.
    perform show_message using '031' zz_matnr '' '' ''.
    zz_cursor_feld = 'ZZ_MATNR_LANG'.
    clear zz_matnr.
    call screen '0999'.
  endif.

* Material-C-Segment lesen
  select single * from marc
  where matnr = zz_matnr
  and   werks = zz_werks.

  zz_dispo = marc-dispo.
  zz_fevor = marc-fevor.

* Material muss im selektierten Werk eröffnet sein
  if sy-subrc ne 0.
    clear ok_code.
    perform show_message using '032' zz_matnr zz_werks '' ''.
    zz_cursor_feld = 'ZZ_MATNR_LANG'.
    call screen '0999'.
  endif.

* Material-D-Segment lesen
  select single * from mard
  where matnr = zz_matnr
  and   werks = zz_werks
  and   lgort = zz_lgort.

* Material muss im selektierten Lagerort eröffnet sein
  if sy-subrc ne 0.
    clear ok_code.
    perform show_message using '033' zz_matnr zz_lgort '' ''.
    zz_cursor_feld = 'ZZ_MATNR_LANG'.
    call screen '0999'.
  endif.

* Falls Material chargenpflichtig ist, so ist Batch-Nr. obligatorisch
  if mara-xchpf ne ' '.
    zz_fert_xchpf = mara-xchpf.
    if zz_charg is initial.
      clear ok_code.
      perform show_message using '039' zz_matnr '' '' ''.
      zz_cursor_feld = 'ZZ_CHARG'.
      call screen '0999'.
    endif.
    select single * from mch1 into ls_mch1
                 where matnr = zz_matnr and
                       charg = zz_charg.
    if sy-subrc eq 0 and ls_mch1-hsdat is not initial.
*     falls charge existiert wird existierendes Produktionsdatum vorgegeben
      zz_prod = ls_mch1-hsdat.
    endif.
  endif.

* Menge testen
  perform menge_testen.

  zz_akt_monat = sy-datum.
  zz_akt_monat+6(2) = 01.
  zz_akt_monat = zz_akt_monat + 31.
  zz_akt_monat+6(2) = 01.
  zz_akt_monat = zz_akt_monat - 01.
  zz_vor_monat = sy-datum.
  zz_vor_monat+6(2) = 01.
  zz_vor_monat = zz_vor_monat - 1.
  zz_vor_monat+6(2) = 01.

* Produktionsdatum Laufender- oder Vormonat
  if zz_prod le zz_akt_monat.
  else.
    clear ok_code.
    perform show_message using '206' zz_prod '' '' ''.
    zz_cursor_feld = 'ZZ_PROD'.
    call screen '0999'.
  endif.

* Buchungsdatum Laufender- oder Vormonat
  if zz_budat ge zz_vor_monat and
  zz_budat le zz_akt_monat.
  else.
    clear ok_code.
    perform show_message using '041' zz_budat '' '' ''.
    zz_cursor_feld = 'ZZ_BUDAT'.
    call screen '0999'.
  endif.

  if sw_halb = 'N'.

*   *** Halb_Nr. feststellen ***
    perform halb_nr_feststellen using mara-matnr
                                changing zz_halb.
    if zz_halb is initial.
*      Gerry Li, add the conversion Exit for the materila converting from old materailal number to the SAP internal number.
      call function 'CONVERSION_EXIT_MATN1_INPUT'
        exporting
          input        = mara-bismt
        importing
          output       = zz_halb
        exceptions
          length_error = 1
          others       = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.

    endif.

    select single * from mara where matnr = zz_halb.
    if sy-subrc ne 0.
      clear ok_code.
      perform show_message using '042' '' '' '' ''.
      zz_cursor_feld = 'ZZ_MATNR_LANG'.
      call screen '0999'.
    endif.

    zz_halb_xchpf = mara-xchpf.

*   MARC für HALB lesen um Produktionslagerort zu holen
    select single * from marc where matnr = zz_halb and
                                    werks = zz_werks.

    if sy-subrc ne 0.
      clear ok_code.
      perform show_message using '042' '' '' '' ''.
      zz_cursor_feld = 'ZZ_MATNR_LANG'.
      call screen '0999'.
    endif.

  else.
    zz_halb = mara-matnr.
    zz_halb_xchpf = mara-xchpf.
  endif.

* Daten lesen und vorbereiten
  perform daten_lesen.

endmodule.                 " CHECK_D300  INPUT
