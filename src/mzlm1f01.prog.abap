*----------------------------------------*
*       FORM process_ok_codes_0100                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form process_ok_codes_0100.

  case save_ok_code.
    when 'BUCH'.
      if sw_test = ' '.
        perform daten_verbuchen.
      else.
        call screen '0200'.
      endif.
  endcase.

endform.                               " PROCESS_OK_CODES_0100

*&---------------------------------------------------------------------*
*&      Form  DATEN_LESEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form daten_lesen.

* FAUF zu FERT + HALB suchen
  clear: zz_fert_fauf,
         zz_halb_fauf,
         zz_objnr,
         ls_afpo,
         ls_afko,
         jest.

* order found by barcode?
  if lv_fauf is initial.

* 1. find order for FERT with BATCH
    select * from afpo into ls_afpo
                       where matnr = zz_matnr and
                             charg = zz_charg and
                             ( dauat = 'PP01' or
                             dauat = 'PI01' ) order by aufnr.

      select single * from afko into ls_afko
                                where aufnr = ls_afpo-aufnr
                                  and gstrp le zz_budat
                                  and gltrp ge zz_budat.
      if sy-subrc ne 0.
        call function 'DATE_TO_DAY'
          exporting
            date    = zz_budat
          importing
            weekday = zz_wochentag.

        if zz_wochentag = text-t04 or
           zz_wochentag = text-t05.
          if zz_budat+6(2) < 3.
            zz_monatsanfang = 'X'.
          else.
            zz_monatsanfang = ' '.
          endif.
          if zz_budat+4(2) = sy-datum+4(2) and
             zz_monatsanfang = 'X'.
*         * Falls Monat vom Buchungsmonat = aktueller Monat +
*         * Monatsanfang, FAUF in der Zukunft suchen
*         * +1 bis +3 Tage
            zz_budatp1 = zz_budat + 1.
            zz_budatp2 = zz_budat + 2.
            zz_budatp3 = zz_budat + 3.
            select single * from afko into ls_afko
                                      where aufnr = ls_afpo-aufnr
                                        and gltrp ge zz_budat
                                        and ( gstrp le zz_budatp1 or
                                              gstrp le zz_budatp2 or
                                              gstrp le zz_budatp3 ).
          else.
*         * Falls Monat vom Buchungsmonat = Vormonat oder Monatsende
*         * FAUF in der Vergangenheit suchen
*         * -1 bis -3 Tage
            zz_budatm1 = zz_budat - 1.
            zz_budatm2 = zz_budat - 2.
            zz_budatm3 = zz_budat - 3.
            select single * from afko into ls_afko
                                      where aufnr = ls_afpo-aufnr
                                        and gstrp le zz_budat
                                        and ( gltrp ge zz_budatm1 or
                                              gltrp ge zz_budatm2 or
                                              gltrp ge zz_budatm3 ).
          endif.
        else.
          sy-subrc = 4.
        endif.
      endif.

      if sy-subrc eq 0.
        clear zz_objnr.
        zz_objnr = 'OR'.
        zz_objnr+2(12) = ls_afko-aufnr.

        perform check_order_status using '1'.

      endif.
    endselect.

  else.
*   * check material in order
    select * from afpo into ls_afpo
                       where aufnr = lv_fauf and
                             matnr = zz_matnr and
                           ( dauat = 'PP01' or
                             dauat = 'PI01' ) order by aufnr.

      if ls_afpo-charg is not initial.
        if ls_afpo-charg ne zz_charg.
          clear ok_code.
          perform show_message using '208' zz_charg lv_fauf '' ''.
          zz_cursor_feld = 'ZZ_CHARG'.
          call screen '0999'.
        endif.
      endif.
    endselect.

    if sy-subrc eq 0.
*     get additional data from FERT FAUF
      select single * from afko into ls_afko
                     where aufnr = lv_fauf.
      if sy-subrc eq 0.
        zz_fert_rsnum = ls_afko-rsnum.
        zz_stlal      = ls_afko-stlal.
        zz_stlan      = ls_afko-stlan.
      endif.
*     set order from Barcode
      zz_fert_fauf = lv_fauf.
    else.
      clear ok_code.
      perform show_message using '207' zz_matnr lv_fauf '' ''.
      zz_cursor_feld = 'ZZ_MATNR_LANG'.
      call screen '0999'.
    endif.
  endif.

  if not zz_fert_fauf is initial.
*   find order for HALB with BATCH
    select * from afpo into ls_afpo
                       where matnr = zz_halb and
                             charg = space   and
                           ( dauat = 'PP01' or
                             dauat = 'PI01' ) order by aufnr.

      select single * from afko into ls_afko
                                where aufnr = ls_afpo-aufnr
                                  and gstrp le zz_budat
                                  and gltrp ge zz_budat.
      if sy-subrc ne 0.
        call function 'DATE_TO_DAY'
          exporting
            date    = zz_budat
          importing
            weekday = zz_wochentag.

        if zz_wochentag = text-t04 or
           zz_wochentag = text-t05.
          if zz_budat+6(2) < 3.
            zz_monatsanfang = 'X'.
          else.
            zz_monatsanfang = ' '.
          endif.
          if zz_budat+4(2) = sy-datum+4(2) and
             zz_monatsanfang = 'X'.
*         * Falls Monat vom Buchungsmonat = aktueller Monat +
*         * Monatsanfang, FAUF in der Zukunft suchen
*         * +1 bis +3 Tage
            zz_budatp1 = zz_budat + 1.
            zz_budatp2 = zz_budat + 2.
            zz_budatp3 = zz_budat + 3.
            select single * from afko into ls_afko
                                      where aufnr = ls_afpo-aufnr
                                        and gltrp ge zz_budat
                                        and ( gstrp le zz_budatp1 or
                                              gstrp le zz_budatp2 or
                                              gstrp le zz_budatp3 ).
          else.
*         * Falls Monat vom Buchungsmonat = Vormonat oder Monatsende
*         * FAUF in der Vergangenheit suchen
*         * -1 bis -3 Tage
            zz_budatm1 = zz_budat - 1.
            zz_budatm2 = zz_budat - 2.
            zz_budatm3 = zz_budat - 3.
            select single * from afko into ls_afko
                                     where aufnr = ls_afpo-aufnr
                                        and gstrp le zz_budat
                                        and ( gltrp ge zz_budatm1 or
                                              gltrp ge zz_budatm2 or
                                              gltrp ge zz_budatm3 ).
          endif.
        else.
          sy-subrc = 4.
        endif.
      endif.

      if sy-subrc eq 0.
        clear zz_objnr.
        zz_objnr = 'OR'.
        zz_objnr+2(12) = ls_afko-aufnr.

        perform check_order_status using '2'.

      endif.
    endselect.
  endif.

  if zz_fert_fauf is initial and zz_halb_fauf is initial.
*   2. Find Order for FERT and HALB without BATCH
    select * from afpo into ls_afpo
                       where ( matnr = zz_matnr  or
                               matnr = zz_halb ) and
                               charg = space     and
                             ( dauat = 'PP01' or
                               dauat = 'PI01' ) order by aufnr.

      select single * from afko into ls_afko
                                where aufnr = ls_afpo-aufnr
                                   and gstrp le zz_budat
                                   and gltrp ge zz_budat.

      if sy-subrc ne 0.
        call function 'DATE_TO_DAY'
          exporting
            date    = zz_budat
          importing
            weekday = zz_wochentag.

        if zz_wochentag = text-t04 or
           zz_wochentag = text-t05.
          if zz_budat+6(2) < 3.
            zz_monatsanfang = 'X'.
          else.
            zz_monatsanfang = ' '.
          endif.
          if zz_budat+4(2) = sy-datum+4(2) and
             zz_monatsanfang = 'X'.
*         * Falls Monat vom Buchungsmonat = aktueller Monat +
*         * Monatsanfang, FAUF in der Zukunft suchen
*         * +1 bis +3 Tage
            zz_budatp1 = zz_budat + 1.
            zz_budatp2 = zz_budat + 2.
            zz_budatp3 = zz_budat + 3.
            select single * from afko into ls_afko
                                      where aufnr = ls_afpo-aufnr
                                        and gltrp ge zz_budat
                                        and ( gstrp le zz_budatp1 or
                                              gstrp le zz_budatp2 or
                                              gstrp le zz_budatp3 ).
          else.
*         * Falls Monat vom Buchungsmonat = Vormonat oder Monatsende
*         * FAUF in der Vergangenheit suchen
*         * -1 bis -3 Tage
            zz_budatm1 = zz_budat - 1.
            zz_budatm2 = zz_budat - 2.
            zz_budatm3 = zz_budat - 3.
            select single * from afko into ls_afko
                                      where aufnr = ls_afpo-aufnr
                                        and gstrp le zz_budat
                                        and ( gltrp ge zz_budatm1 or
                                              gltrp ge zz_budatm2 or
                                              gltrp ge zz_budatm3 ).
          endif.
        else.
          sy-subrc = 4.
        endif.
      endif.
      if sy-subrc eq 0.
        clear zz_objnr.
        zz_objnr = 'OR'.
        zz_objnr+2(12) = ls_afpo-aufnr.

        perform check_order_status using '3'.

      endif.
    endselect.
  endif.

  if sw_halb = 'J'.
    zz_halb_fauf = zz_fert_fauf.
    clear zz_fert_fauf.
    if zz_halb_fauf is initial.
      clear ok_code.
      perform show_message using '004' zz_halb '' '' ''.
      zz_cursor_feld = 'ZZ_MATNR_LANG'.
      call screen '0999'.
    endif.
  else.
    if zz_fert_fauf is initial.
      clear ok_code.
      perform show_message using '005' zz_matnr '' '' ''.
      zz_cursor_feld = 'ZZ_MATNR_LANG'.
      call screen '0999'.
    else.
      if zz_halb_fauf is initial.
        clear ok_code.
        perform show_message using '004' zz_halb '' '' ''.
        zz_cursor_feld = 'ZZ_MATNR_LANG'.
        call screen '0999'.
      endif.
    endif.

* *** Positionen zu FAUF-Auftrag holen und in Tabelle laden ***
    clear komp_tab.
    refresh komp_tab.

    select * from resb where rsnum = zz_fert_rsnum and
                             aufnr = zz_fert_fauf and
                             baugr = zz_matnr.
      if resb-rgekz ne 'X'.
        clear ok_code.
        perform show_message using '006' zz_fert_fauf '' '' ''.
        zz_cursor_feld = 'ZZ_MATNR_LANG'.
        call screen '0999'.
        exit.
      endif.

      select single * from mara where matnr = resb-matnr.

      if sy-subrc eq 0.
        if mara-mtart = 'HALB'.
          komp_tab-charg = zz_charg.
        else.
          komp_tab-charg = ' '.
        endif.
        komp_tab-mtart = mara-mtart.
        komp_tab-idnrk = resb-matnr.
        komp_tab-lgpro = resb-lgort.
        komp_tab-menge = resb-bdmng.
        komp_tab-meins = resb-meins.
        komp_tab-rsnum = resb-rsnum.
        komp_tab-rspos = resb-rspos.
        append komp_tab.
      endif.

    endselect.

    sort komp_tab by mtart idnrk.

    loop at komp_tab.
      zz_tabix = sy-tabix.
      if komp_tab-mtart = 'HALB'.
        if zz_halb ne komp_tab-idnrk.
          clear ok_code.
          perform show_message using '007' zz_halb zz_matnr '' ''.
          zz_cursor_feld = 'ZZ_MATNR_LANG'.
          call screen '0999'.
        endif.
        zz_lgpro_halb = komp_tab-lgpro.
        select single * from mard where matnr = zz_halb and
                                        werks = zz_werks and
                                        lgort = zz_lgpro_halb.
        if sy-subrc ne 0.
          clear ok_code.
          perform show_message using '008' zz_halb zz_lgpro_halb '' ''.
          zz_cursor_feld = 'ZZ_MATNR_LANG'.
          call screen '0999'.
        endif.

*     *** Faktor zum Umrechnen der Verpackungen bestimmen ***
        if komp_tab-meins ne zz_meins.
          if komp_tab-meins = 'TO' and zz_meins = 'KG'.
            komp_tab-menge = komp_tab-menge * 1000.
            komp_tab-meins = 'KG'.
            zz_faktor = zz_menge_p / komp_tab-menge.
          else.
            if komp_tab-meins = 'KG' and zz_meins  = 'TO'.
              komp_tab-menge = komp_tab-menge / 1000.
              komp_tab-meins = 'TO'.
              zz_faktor = zz_menge_p / komp_tab-menge.
            endif.
          endif.
        else.
          zz_faktor = zz_menge_p / komp_tab-menge.
        endif.
        komp_tab-menge = zz_menge_p.
        modify komp_tab index zz_tabix.

      else.
        if komp_tab-mtart = 'VERP'.
          if komp_tab-meins = 'ST'.
            zz_gerade_zahl = komp_tab-menge * 1.
            zz_diff = komp_tab-menge - zz_gerade_zahl.
            if zz_faktor > 0.
              komp_tab-menge = komp_tab-menge * zz_faktor.
            else.
              komp_tab-menge = 0.
            endif.
            if zz_diff eq 0.
*             die ursprüngliche Komponentenmenge ist
*             eine gerade Zahl
              zz_gerade_zahl = komp_tab-menge * 1.
              zz_diff = komp_tab-menge - zz_gerade_zahl.
              if zz_diff > 0 and zz_diff < zz_nullkomafuenf.
                zz_gerade_zahl = zz_gerade_zahl + 1.
              endif.
              komp_tab-menge = zz_gerade_zahl.

            endif.
          else.
            if zz_faktor > 0.
              komp_tab-menge = komp_tab-menge * zz_faktor.
            else.
              komp_tab-menge = 0.
            endif.
          endif.

          modify komp_tab index zz_tabix.

          select single * from marc where matnr eq komp_tab-idnrk and
                                          werks eq zz_werks.

          if sy-subrc eq 0.
            select single * from mard where matnr eq komp_tab-idnrk and
                                            werks eq zz_werks and
                                            lgort eq komp_tab-lgpro.
            if sy-subrc eq 0.
            else.
              clear ok_code.
              perform show_message using '009' komp_tab-idnrk komp_tab-lgpro '' ''.
              zz_cursor_feld = 'ZZ_MATNR_LANG'.
              call screen '0999'.
            endif.
          else.
            clear ok_code.
            perform show_message using '010' komp_tab-idnrk zz_werks '' ''.
            zz_cursor_feld = 'ZZ_MATNR_LANG'.
            call screen '0999'.
          endif.
        endif.
      endif.

    endloop.

    if komp_tab[] is initial.
      clear ok_code.
      perform show_message using '011' zz_fert_fauf '' '' ''.
      zz_cursor_feld = 'ZZ_MATNR_LANG'.
      call screen '0999'.
    endif.

  endif.

* *** Sperreinträge setzen ***
  perform sperreintraege_setzen.

endform.                               " DATEN_LESEN

*&---------------------------------------------------------------------*
*&      Form  process_ok_codes_0200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form process_ok_codes_0200.

  case save_ok_code.

    when 'BUCH'.
      if sw_test = 'X'.
        perform daten_verbuchen.
      endif.
  endcase.

endform.                    " process_ok_codes_0200

*&---------------------------------------------------------------------*
*&      Form  daten_verbuchen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form daten_verbuchen.

  if lc_log_active = 'X' and lv_log_handle is initial.

    clear ls_s_log.
*   LOG soll 60 Tage im System bleiben
    ls_s_log-aldate_del = sy-datum + 60.
    ls_s_log-altcode = sy-tcode.
    ls_s_log-alprog = sy-cprog.
    ls_s_log-extnumber = zz_lenum.

    ls_s_log-object = lc_zmde.

    if sy-uname = 'NIACIN'.
      ls_s_log-subobject = lc_zmde_niacin.
    else.
      ls_s_log-subobject = lc_zmde_zlm1.
    endif.

    clear lt_log_handle.

    perform create_application_log changing lt_log_handle
                                            ls_s_log
                                            lv_log_handle.
    if lv_log_handle is not initial.

*     add transaction data
      clear ls_s_msg.
      clear ls_zmde_appl_log.
      ls_zmde_appl_log-werks = zz_werks.
      ls_zmde_appl_log-lgort = zz_lgort.
      ls_zmde_appl_log-lgnum = zz_lgnum.
      ls_zmde_appl_log-lgtyp = zz_lgtyp.
      ls_zmde_appl_log-matnr = zz_matnr.
      ls_zmde_appl_log-charg = zz_charg.
      write zz_menge to ls_zmde_appl_log-menge unit zz_meins.
      ls_zmde_appl_log-order_fert = zz_fert_fauf.
      ls_zmde_appl_log-order_halb = zz_halb_fauf.
      ls_zmde_appl_log-lenum = zz_lenum.
      ls_zmde_appl_log-prod_dat = zz_prod.
      ls_zmde_appl_log-budat = zz_budat.

      ls_s_msg-context-tabname = 'ZMDE_APPL_LOG'.
      field-symbols: <l_s_my_context>  type c.
      assign ls_zmde_appl_log to <l_s_my_context> casting.
      ls_s_msg-context-value = <l_s_my_context>.

      ls_s_msg-msgty = 'I'.
      ls_s_msg-msgid = 'ZMDE'.
      ls_s_msg-msgno = '999'.
      ls_s_msg-msgv1 = text-i00.

      call function 'BAL_LOG_MSG_ADD'
        exporting
          i_log_handle     = ls_log_handle
          i_s_msg          = ls_s_msg
        exceptions
          log_not_found    = 1
          msg_inconsistent = 2
          log_is_full      = 3
          others           = 4.

      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.

    endif.

  endif.

  if sw_halb = 'N'.
*   Sperreintrag FERT löschen
    perform fert_entsperren.

*   Sperreintrag FERT-FAUF löschen
    perform fert_fauf_entsperren.
*   BAPI FERT-Buchung
    perform bapi_we_fert.
  endif.

* Sperreintrag HALB löschen
  perform halb_entsperren.

* Sperreintrag HALB-FAUF löschen
  perform halb_fauf_entsperren.

* BAPI WE-Buchung HALB
  perform bapi_we_halb.

* Erfolgte HALB-Buchung feststellen
  perform buchung_halb_feststellen.

  if sw_halb = 'N'.
*   BAPI WA-Buchungen
    perform bapi_wa_alle.
  endif.

* Alle Sperreinträge löschen ***
  perform sperreintraege_loeschen.

  if sw_halb = 'N'.
*   Erfolgte FERT-Buchung feststellen
    perform buchung_fert_feststellen.
  else.
*   Erfolgte HALB-Buchung feststellen
    perform buchung_halb_feststellen.
  endif.

  if sw_mit_lvs = 'J'.
*   TA aus FERT-Materialbeleg erstellen (LT06)
    perform ta_erstellen.
  endif.

  if sy-tcode = 'ZLM1S'.
*   get inspection lot
    select single * from qals into ls_qals
           where mblnr = zz_beleg_nr and
                 zeile = mseg-zeile and
                 mjahr = zz_beleg_jahr.
    if sy-subrc eq 0.
*     inspection lot posting with transaction QAC2
      perform inspection_lot_qac2 using ls_qals-prueflos
                                  changing lv_beleg_nr_uml
                                           lv_beleg_jahr_uml.
    else.
*     move quantity to plant 0001 storage location 3980 with movement type 301
      perform move_stock_to_0001_3980 changing lv_beleg_nr_uml
                                               lv_beleg_jahr_uml.
    endif.

  endif.

  if lc_log_active = abap_true.
*   save application log
    perform application_log_save using lt_log_handle
                              changing lt_new_lognumbers.
    clear lv_log_handle.
  endif.

* * Wurde die Transaktion ZLM1, ZLM1H über Call Transaction aufgerufen, braucht es die
* * restlichen Anzeigen nicht mehr. MWALKER 26.11.2008
  if sy-binpt = 'X' and ( sy-tcode = 'ZLM1' or sy-tcode = 'ZLMH' ).
    leave program.
  endif.


* Buchungsübersicht ausgeben
  if sw_halb = 'N'.

    if sw_ok = 'J'.
      clear zz_beleg_nr_2.
      clear zz_beleg_jahr_2.
*   *** Materialbeleg der Rückmeldung feststellen
      loop at z_detreturn into wa_detreturn.
        select * from afwi where rueck = wa_detreturn-conf_no and
                                 rmzhl = wa_detreturn-conf_cnt.
          zz_beleg_nr_2 = afwi-mblnr.
          zz_beleg_jahr_2 = afwi-mjahr.
          exit.
        endselect.
        exit.
      endloop.
      if zz_beleg_nr_2 = ' '.
        if sw_mit_lvs = 'J'.
          perform show_message using '012' zz_beleg_nr zz_beleg_nr_halb '' zz_tanum.
        else.
          perform show_message using '255' zz_beleg_nr zz_beleg_nr_halb '' ''.
        endif.
      else.
        clear zz_message4.
        clear zz_message5.
        if sw_mit_lvs = 'J'.

          perform show_message using '013' zz_beleg_nr zz_beleg_nr_halb zz_beleg_nr_2 zz_tanum.
        else.
          perform show_message using '257' zz_beleg_nr zz_beleg_nr_halb zz_beleg_nr_2 ''.
        endif.

      endif.
    else.
      if sw_mit_lvs = 'J'.
        perform show_message using '014' zz_beleg_nr zz_beleg_nr_halb '' zz_tanum.
      else.
        perform show_message using '256' zz_beleg_nr zz_beleg_nr_halb '' ''.
      endif.
    endif.
  else.
    if sw_mit_lvs = 'J'.
      perform show_message using '015' zz_beleg_nr_halb zz_tanum '' ''.
    else.
      perform show_message using '016' zz_beleg_nr_halb '' '' ''.
    endif.
  endif.

  case sy-tcode.
    when 'ZLM1' or 'ZLM1H'.
      zz_dynnr_alt = '0100'.
    when 'ZLM1S'.
      zz_dynnr_alt = '0300'.
  endcase.
  zz_alles_freigeben = 'J'.
  call screen '0999'.

endform.                    " daten_verbuchen

*&---------------------------------------------------------------------*
*&      Form  bapi_we_fert
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form bapi_we_fert.

  clear bapigmhead.

  bapigmhead-pstng_date = zz_budat.
  bapigmhead-doc_date   = sy-datum.

*Zuordnung Code zu Transaktion für BAPI Warenbewegung 02=MB31
  bapigmcode-gm_code    = '02'.
*Testlauf = Simulation
  bapitestrun = ' '.

  clear ximseg.
  refresh ximseg.
  clear xemseg.
  refresh ximseg.
*Bewegungsart (Bestandsführung)
  ximseg-move_type     = '101'.
*Menge in Erfassungsmengeneinheit
  ximseg-entry_qnt     = zz_menge_p.
*Erfassungsmengeneinheit
  ximseg-entry_uom     = zz_meins.
*Bewegungskennzeichen
  ximseg-mvt_ind       = 'F'.
*Material
  ximseg-material      = zz_matnr.
*Werk
  ximseg-plant         = zz_werks.
*Lagerort
  ximseg-stge_loc      = zz_lgort.
*Auftragsnummer
  ximseg-orderid       = zz_fert_fauf.
*Endlieferungskennzeichen
  ximseg-no_more_gr    = ' '.
* Bestandsart
  ximseg-stck_type     = ' '.

  if zz_fert_xchpf eq 'X'.
    ximseg-batch = zz_charg.
  endif.
  ximseg-prod_date = zz_prod.

  append ximseg.

  clear: zz_beleg_nr,
         zz_beleg_jahr.

  call function 'BAPI_GOODSMVT_CREATE'
    exporting
      goodsmvt_header  = bapigmhead
      goodsmvt_code    = bapigmcode
      testrun          = bapitestrun
    importing
      goodsmvt_headret = bapigmheadret
    tables
      return           = xemseg
      goodsmvt_item    = ximseg.

  if not bapigmheadret is initial.
*   Add success message to application log
    if lc_log_active = abap_true.

      clear ls_bapiret2.
      ls_bapiret2-type = 'S'.
      ls_bapiret2-id = 'ZMDE'.
      ls_bapiret2-number = '999'.
      ls_bapiret2-message_v1 = text-i01.
      concatenate bapigmheadret-mat_doc
                  bapigmheadret-doc_year
             into ls_bapiret2-message_v2 separated by ' '.

*     write application log entry
      perform application_log_add_message using lv_log_handle
                                                ls_bapiret2.
    endif.

    call function 'BAPI_TRANSACTION_COMMIT'
      exporting
        wait   = 'X'
      importing
        return = bapireturn.

    set parameter id 'MBN' field bapigmheadret-mat_doc.
    set parameter id 'MJA' field bapigmheadret-doc_year.
    zz_beleg_nr = bapigmheadret(10).
    zz_beleg_jahr = bapigmheadret+10(4).

  else.
    call function 'BAPI_TRANSACTION_ROLLBACK'
      importing
        return = bapireturn.

    clear t9m18.
    t9m18-mandt = sy-mandt.
    t9m18-datum = sy-datum.
    t9m18-zeit  = sy-uzeit.
    t9m18-transaktion = 'BAPI_GOODSMVT_CREATE/WE-FERT'(t01).
    t9m18-code = '02'.
    t9m18-bwart = '101'.
    t9m18-kzbew = 'F'.

    t9m18-werks = zz_werks.
    t9m18-lgort = zz_lgort.
    t9m18-matnr = zz_matnr.
    t9m18-meins = zz_meins.
    t9m18-menge = zz_menge_p.
    t9m18-charg = zz_charg.
    t9m18-stlal = zz_stlal.
    t9m18-stlan = zz_stlan.
    t9m18-lenum = zz_lenum.
    t9m18-fert_fauf = zz_fert_fauf.
    t9m18-halb_fauf = zz_halb_fauf.
    t9m18-prod_dat = zz_budat.
    t9m18-bu_dat = sy-datum.

    loop at xemseg.
      t9m18-msgid = xemseg-id.
      t9m18-msgno = xemseg-number.

      message id xemseg-id type xemseg-type number xemseg-number
              with xemseg-message_v1 xemseg-message_v2 xemseg-message_v3
                   xemseg-message_v4
              into zz_fehler_text.
      t9m18-message = zz_fehler_text.
      exit.
    endloop.

    insert t9m18.
    if sy-binpt is initial.
      perform show_message using '017' zz_fehler_text '' '' ''.

      call screen 999.
    endif.

*   Add message to application log
    if lc_log_active = abap_true.

      loop at xemseg into ls_bapiret2.
*     write log entry
        perform application_log_add_message using lv_log_handle
                                                  ls_bapiret2.
      endloop.
    endif.
  endif.

  if lc_log_active = abap_true.
*   save application log
    perform application_log_save using lt_log_handle
                              changing lt_new_lognumbers.
  endif.

endform.                    " bapi_we_fert

*&---------------------------------------------------------------------*
*&      Form  bapi_we_halb
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form bapi_we_halb.

  clear bapigmhead.

  bapigmhead-pstng_date = zz_budat.
  bapigmhead-doc_date   = sy-datum.

*Zuordnung Code zu Transaktion für BAPI Warenbewegung 02=MB31
  bapigmcode-gm_code    = '02'.
*Testlauf = Simulation
  bapitestrun = ' '.

  clear ximseg.
  refresh ximseg.
  clear xemseg.
  refresh xemseg.
*Bewegungsart (Bestandsführung)
  ximseg-move_type     = '101'.
*Menge in Erfassungsmengeneinheit
  ximseg-entry_qnt     = zz_menge_p.
*Erfassungsmengeneinheit
  ximseg-entry_uom     = zz_meins.
*Bewegungskennzeichen
  ximseg-mvt_ind       = 'F'.
*Material
  ximseg-material      = zz_halb.
*Werk
  ximseg-plant         = zz_werks.
  if sw_halb = 'N'.
*Lagerort
    ximseg-stge_loc      = zz_lgpro_halb.
  else.
*Lagerort
    ximseg-stge_loc      = zz_lgort.
  endif.
*Auftragsnummer
  ximseg-orderid       = zz_halb_fauf.
*Endlieferungskennzeichen
  ximseg-no_more_gr    = ' '.
* Bestandsart
  ximseg-stck_type     = ' '.

  if zz_halb_xchpf eq 'X'.
    ximseg-batch = zz_charg.
  endif.
  ximseg-prod_date = zz_prod.

  append ximseg.

  clear: zz_beleg_nr_halb,
         zz_beleg_jahr_halb.

  call function 'BAPI_GOODSMVT_CREATE'
    exporting
      goodsmvt_header  = bapigmhead
      goodsmvt_code    = bapigmcode
      testrun          = bapitestrun
    importing
      goodsmvt_headret = bapigmheadret
    tables
      return           = xemseg
      goodsmvt_item    = ximseg.

  if not bapigmheadret is initial.
*   Add success message to application log
    if lc_log_active = abap_true.

      clear ls_bapiret2.
      ls_bapiret2-type = 'S'.
      ls_bapiret2-id = 'ZMDE'.
      ls_bapiret2-number = '999'.
      ls_bapiret2-message_v1 = text-i02.
      concatenate bapigmheadret-mat_doc
                  bapigmheadret-doc_year
             into ls_bapiret2-message_v2 separated by ' '.

*     write application log entry
      perform application_log_add_message using lv_log_handle
                                                ls_bapiret2.
    endif.

    call function 'BAPI_TRANSACTION_COMMIT'
      exporting
        wait   = 'X'
      importing
        return = bapireturn.

    zz_beleg_nr_halb = bapigmheadret(10).
    zz_beleg_jahr_halb = bapigmheadret+10(4).

  else.
    call function 'BAPI_TRANSACTION_ROLLBACK'
      importing
        return = bapireturn.

    clear t9m18.
    t9m18-mandt = sy-mandt.
    t9m18-datum = sy-datum.
    t9m18-zeit  = sy-uzeit.
    t9m18-transaktion = 'BAPI_GOODSMVT_CREATE/WE-HALB'(t02).
    t9m18-code = '02'.
    t9m18-bwart = '101'.
    t9m18-kzbew = 'F'.

    t9m18-werks = zz_werks.
    t9m18-lgort = zz_lgpro_halb.
    t9m18-halbnr = zz_halb.
    t9m18-matnr = zz_matnr.
    t9m18-meins = zz_meins.
    t9m18-menge = zz_menge_p.
    t9m18-charg = zz_charg.
    t9m18-lenum = zz_lenum.
    t9m18-stlal = zz_stlal.
    t9m18-stlan = zz_stlan.
    t9m18-fert_fauf = zz_fert_fauf.
    t9m18-halb_fauf = zz_halb_fauf.
    t9m18-prod_dat = zz_budat.
    t9m18-bu_dat = sy-datum.

    loop at xemseg.
      t9m18-msgid = xemseg-id.
      t9m18-msgno = xemseg-number.

      message id xemseg-id type xemseg-type number xemseg-number
              with xemseg-message_v1 xemseg-message_v2 xemseg-message_v3
                   xemseg-message_v4
              into zz_fehler_text.
      t9m18-message = zz_fehler_text.
      exit.
    endloop.
    insert t9m18.

    if sy-binpt is initial.
      perform show_message using '017' zz_fehler_text '' '' ''.

      call screen 999.
    endif.
  endif.

* Add message to application log
  if lc_log_active = abap_true.

    loop at xemseg into ls_bapiret2.
*     write log entry
      perform application_log_add_message using lv_log_handle
                                                ls_bapiret2.
    endloop.
*   save application log
    perform application_log_save using lt_log_handle
                              changing lt_new_lognumbers.
  endif.

  if lc_log_active = abap_true.
*   save application log
    perform application_log_save using lt_log_handle
                              changing lt_new_lognumbers.
  endif.
endform.                    " bapi_we_halb

*&---------------------------------------------------------------------*
*&      Form  process_ok_codes_1001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form process_ok_codes_1001.

  case save_ok_code.
    when 'NEXT'.
      clear ok_code.
      select single * from mkpf where
                           mblnr = zz_beleg_nr and
                           mjahr = zz_beleg_jahr.
      if sy-subrc eq 0.
        select * from mseg where
                      mblnr = mkpf-mblnr and
                      mjahr = mkpf-mjahr.
        endselect.
        leave to screen 0.
      endif.

  endcase.

endform.                    " process_ok_codes_1001

*&---------------------------------------------------------------------*
*&      Form  buchung_fert_feststellen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form buchung_fert_feststellen.

  select single * from mkpf where
                       mblnr = zz_beleg_nr and
                       mjahr = zz_beleg_jahr.

  if sy-subrc eq 0.
    select * from mseg where
                  mblnr = mkpf-mblnr and
                  mjahr = mkpf-mjahr.
      exit.
    endselect.
  else.
    call screen 1001.
  endif.

endform.                    " buchung_fert_feststellen
*&---------------------------------------------------------------------*
*&      Form  ta_erstellen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form ta_erstellen_lt06.

  refresh bdcdata.
  clear bdcdata.

* *** Dynpro 0203 ***
  bdcdata-program = 'SAPML02B'.
  bdcdata-dynpro = '0203'.
  bdcdata-dynbegin = 'X'.
  append bdcdata.
  clear bdcdata.
  bdcdata-fnam = 'BDC_CURSOR'.
  bdcdata-fval = 'RL02B-MBLNR'.
  append bdcdata.
  bdcdata-fnam = 'BDC_OKCODE'.
  bdcdata-fval = '/00'.
  append bdcdata.
  if sw_halb = 'N'.
    bdcdata-fnam = 'RL02B-MBLNR'.
    bdcdata-fval = zz_beleg_nr.
    append bdcdata.
    bdcdata-fnam = 'RL02B-MJAHR'.
    bdcdata-fval = zz_beleg_jahr.
    append bdcdata.
  else.
    bdcdata-fnam = 'RL02B-MBLNR'.
    bdcdata-fval = zz_beleg_nr_halb.
    append bdcdata.
    bdcdata-fnam = 'RL02B-MJAHR'.
    bdcdata-fval = zz_beleg_jahr_halb.
    append bdcdata.
  endif.
  bdcdata-fnam = 'RL02B-LGNUM'.
  bdcdata-fval = zz_lgnum.
  append bdcdata.
  bdcdata-fnam = 'RL02B-DUNKL'.
  bdcdata-fval = 'H'.
  append bdcdata.

* *** Dynpro 0132 ***
  clear bdcdata.
  bdcdata-program = 'SAPML03T'.
  bdcdata-dynpro = '0132'.
  bdcdata-dynbegin = 'X'.
  append bdcdata.
  clear bdcdata.
  bdcdata-fnam = 'BDC_CURSOR'.
  bdcdata-fval = 'LTBP1-OFMEA(01)'.
  append bdcdata.
  bdcdata-fnam = 'BDC_OKCODE'.
  bdcdata-fval = '=LEBL'.
  append bdcdata.

* *** Dynpro 0171 ***
  clear bdcdata.
  bdcdata-program = 'SAPML03T'.
  bdcdata-dynpro = '0171'.
  bdcdata-dynbegin = 'X'.
  append bdcdata.
  clear bdcdata.
  bdcdata-fnam = 'BDC_CURSOR'.
  bdcdata-fval = 'LEIN-LETYP'.
  append bdcdata.
  bdcdata-fnam = 'BDC_OKCODE'.
  bdcdata-fval = '=LT01'.
  append bdcdata.
  bdcdata-fnam = 'LEIN-LENUM'.
  bdcdata-fval = zz_lenum+10(10).
  append bdcdata.
  bdcdata-fnam = 'LEIN-LETYP'.
  bdcdata-fval = mlgn-lety1.
  append bdcdata.

* *** Dynpro 0132 ***
  clear bdcdata.
  bdcdata-program = 'SAPML03T'.
  bdcdata-dynpro = '0132'.
  bdcdata-dynbegin = 'X'.
  append bdcdata.
  clear bdcdata.
  bdcdata-fnam = 'BDC_CURSOR'.
  bdcdata-fval = 'LTBK-BWLVS'.
  append bdcdata.
  bdcdata-fnam = 'BDC_OKCODE'.
  bdcdata-fval = '=BU'.
  append bdcdata.

  clear otab.
  refresh otab.

  call transaction 'LT06' using bdcdata mode 'N'
                          messages into otab.

  loop at otab where msgtyp = 'A' or
                     msgtyp = 'E'.
    zz_tanum = 'Fehler'(001).
    zz_tapos = ' '.

    clear t9m18.
    t9m18-mandt = sy-mandt.
    t9m18-datum = sy-datum.
    t9m18-zeit  = sy-uzeit.
    t9m18-transaktion = 'LT06'.

    t9m18-lenum = zz_lenum.
    t9m18-lgnum = zz_lgnum.
    t9m18-mblnr = zz_beleg_nr.
    t9m18-mjahr = zz_beleg_jahr.

    t9m18-msgid = otab-msgid.
    t9m18-msgno = otab-msgnr.

    message id otab-msgid type otab-msgtyp number otab-msgnr
            with otab-msgv1 otab-msgv2 otab-msgv3 otab-msgv4
            into t9m18-message.

    insert t9m18.
    exit.
  endloop.

  if sy-subrc ne 0.
    zz_tanum = sy-msgv1(10).
    zz_tapos = '0001'.

    clear ls_bapiret2.
    ls_bapiret2-type = 'S'.
    ls_bapiret2-id = 'ZMDE'.
    ls_bapiret2-number = '999'.
    ls_bapiret2-message_v1 = text-i04.
    concatenate zz_tanum
                zz_tapos
                text-i07
           into ls_bapiret2-message_v2 separated by ' '.
*   write log entry
    perform application_log_add_message using lv_log_handle
                                              ls_bapiret2.
  else.

*   Add message to application log
    if lc_log_active = abap_true.

      clear ls_bapiret2.
      ls_bapiret2-type = 'S'.
      ls_bapiret2-id = 'ZMDE'.
      ls_bapiret2-number = '999'.
      ls_bapiret2-message_v1 = text-i04.

*     write application log entry
      perform application_log_add_message using lv_log_handle
                                                ls_bapiret2.

      loop at otab into ls_otab.
        clear ls_bapiret2.
        ls_bapiret2-type = ls_otab-msgtyp.
        ls_bapiret2-id = ls_otab-msgid.
        ls_bapiret2-number = ls_otab-msgnr.
        ls_bapiret2-message_v1 = ls_otab-msgv1.
        ls_bapiret2-message_v2 = ls_otab-msgv2.
        ls_bapiret2-message_v3 = ls_otab-msgv3.
        ls_bapiret2-message_v4 = ls_otab-msgv4.
*       write log entry
        perform application_log_add_message using lv_log_handle
                                                  ls_bapiret2.
      endloop.
    endif.

  endif.

  if lc_log_active = abap_true.
*   save application log
    perform application_log_save using lt_log_handle
                              changing lt_new_lognumbers.
  endif.

endform.                    " ta_erstellen_lt06
*&---------------------------------------------------------------------*
*&      Form  le_testen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form le_testen.

* * LE-Nummer mit Nummernkreis verproben
  select single * from t340d where lgnum = zz_lgnum.
  if sy-subrc ne 0.
    clear t340d.
  endif.
  select * from nriv where object = 'LVS_LENUM'.
    if t340d-nukle = nriv-nrrangenr.
      if zz_lenum ge nriv-fromnumber and
         zz_lenum le nriv-tonumber.
      else.
        clear ok_code.
        perform show_message using '146' zz_lenum '' '' ''.
        zz_cursor_feld = 'ZZ_LENUM'.
        call screen '0999'.
        exit.
      endif.
    else.
      if zz_lenum ge nriv-fromnumber and
         zz_lenum le nriv-tonumber.
        clear ok_code.
        perform show_message using '146' zz_lenum '' '' ''.
        zz_cursor_feld = 'ZZ_LENUM'.
        call screen '0999'.
        exit.
      endif.
    endif.
  endselect.

  select single * from lein where lenum = zz_lenum.

  if sy-subrc eq 0.
    if lein-statu ne ' ' or lein-skzua ne ' ' or
       lein-skzue ne ' ' or lein-spgru ne ' '.
      clear ok_code.
      perform show_message using '018' '' '' '' ''.
      zz_cursor_feld = 'ZZ_LENUM'.
      call screen '0999'.
    endif.
    if lein-mgewi ne 0.
      clear ok_code.
      perform show_message using '019' '' '' '' ''.
      zz_cursor_feld = 'ZZ_LENUM'.
      call screen '0999'.
    endif.

    select * from lqua where lgnum = lein-lgnum and
                             lgtyp = lein-lgtyp and
                             lgpla = lein-lgpla and
                             lenum = lein-lenum.
      exit.
    endselect.

    if sy-subrc eq 0.
      clear ok_code.
      perform show_message using '019' '' '' '' ''.
      zz_cursor_feld = 'ZZ_LENUM'.
      call screen '0999'.
    else.
      select single * from ltak where lgnum = lein-lgnum and
                                      tanum = lein-btanr and
                                      kquit = ' '.
      if sy-subrc eq 0.
        clear ok_code.
        perform show_message using '019' '' '' '' ''.
        zz_cursor_feld = 'ZZ_LENUM'.
        call screen '0999'.
      endif.
    endif.
  endif.

endform.                    " le_testen
*&---------------------------------------------------------------------*
*&      Form  buchung_halb_feststellen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form buchung_halb_feststellen.

  select single * from mkpf where
                       mblnr = zz_beleg_nr_halb and
                       mjahr = zz_beleg_jahr_halb.

  if sy-subrc eq 0.
    select * from mseg where
                  mblnr = mkpf-mblnr and
                  mjahr = mkpf-mjahr.
      exit.
    endselect.
  else.
    call screen 1001.
  endif.

endform.                    " buchung_halb_feststellen

*&---------------------------------------------------------------------*
*&      Form  sperreintraege_setzen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form sperreintraege_setzen.

  if sw_halb = 'N'.

* *** FERT gesperrt ? ***
    clear: enq_tab,
           gobj,
           guname.
    refresh enq_tab.

    enq_tab-gname = 'MARC'.
    enq_tab-gmode = 'E'.
    concatenate zz_matnr zz_werks into enq_tab-garg.
    append enq_tab.
    enq_tab-gname = 'MBEW'.
    enq_tab-gmode = 'E'.
    concatenate zz_matnr zz_werks into enq_tab-garg.
    append enq_tab.
    zz_sperr_mat = zz_matnr.

    perform sperren.

* *** FERT-FAUF gesperrt ? ***
    clear: enq_tab,
           gobj,
           guname.
    refresh enq_tab.

    enq_tab-gname = 'AUFK'.
    enq_tab-gmode = 'E'.
    enq_tab-garg = zz_fert_fauf.
    append enq_tab.
    zz_sperr_fauf = zz_fert_fauf.

    perform sperren.

  endif.

* *** HALB gesperrt ? ***
  clear: enq_tab,
         gobj,
         guname.
  refresh enq_tab.

  enq_tab-gname = 'MARC'.
  enq_tab-gmode = 'E'.
  concatenate zz_halb zz_werks into enq_tab-garg.
  append enq_tab.
  enq_tab-gname = 'MBEW'.
  enq_tab-gmode = 'E'.
  concatenate zz_halb zz_werks into enq_tab-garg.
  append enq_tab.
  zz_sperr_mat = zz_halb.

  perform sperren.

* *** HALB-FAUF gesperrt ? ***
  clear: enq_tab,
         gobj,
         guname.
  refresh enq_tab.

  enq_tab-gname = 'AUFK'.
  enq_tab-gmode = 'E'.
  enq_tab-garg = zz_halb_fauf.
  append enq_tab.
  zz_sperr_fauf = zz_halb_fauf.

  perform sperren.

endform.                    " sperreintraege_setzen

*&---------------------------------------------------------------------*
*&      Form  sperren
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form sperren.

* *** sperren, falls möglich ***
  call function 'ENQUEUE_ARRAY'
    exporting
      dequeue          = ' '
      gobj             = 'ENQARRAY'
    importing
      collision_gobj   = gobj
      collision_guname = guname
    tables
      enq_array        = enq_tab
    exceptions
      argument_error   = 1
      foreign_lock     = 2
      own_lock         = 3
      system_failure   = 4
      table_overflow   = 5
      others           = 6.

  if sy-subrc <> 0.
    if enq_tab-gname = 'AUFK'.
      clear ok_code.
      perform show_message using '020' zz_sperr_fauf '' '' ''.
      zz_cursor_feld = 'ZZ_MATNR'.
      call screen '0999'.
    else.
      clear ok_code.
      perform show_message using '021' zz_sperr_mat '' '' ''.
      zz_cursor_feld = 'ZZ_MATNR'.
      call screen '0999'.
    endif.
  endif.

endform.                    " sperren
*&---------------------------------------------------------------------*
*&      Form  sperreintraege_loeschen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form sperreintraege_loeschen.

  if sw_halb = 'N'.

* Sperreintrag FERT löschen
    perform fert_entsperren.

* Sperreintrag FERT-FAUF löschen
    perform fert_fauf_entsperren.

  endif.

* Sperreintrag HALB löschen
  perform halb_entsperren.

* Sperreintrag HALB_FAUF löschen
  perform halb_fauf_entsperren.

endform.                    " sperreintraege_loeschen
*&---------------------------------------------------------------------*
*&      Form  entsperren
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form entsperren.

* *** entsperren  ***
  call function 'ENQUEUE_ARRAY'
    exporting
      dequeue        = 'X'
      gobj           = 'ENQARRAY'
    tables
      enq_array      = enq_tab
    exceptions
      argument_error = 1
      foreign_lock   = 2
      own_lock       = 3
      system_failure = 4
      table_overflow = 5
      others         = 6.

endform.                    " entsperren
*&---------------------------------------------------------------------*
*&      Form  halb_entsperren
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form halb_entsperren.

  clear: enq_tab.
  refresh enq_tab.

  enq_tab-gname = 'MARC'.
  enq_tab-gmode = 'E'.
  concatenate zz_halb zz_werks into enq_tab-garg.
  append enq_tab.
  enq_tab-gname = 'MBEW'.
  enq_tab-gmode = 'E'.
  concatenate zz_halb zz_werks into enq_tab-garg.
  append enq_tab.
  zz_sperr_mat = zz_halb.

  perform entsperren.

endform.                    " halb_entsperren
*&---------------------------------------------------------------------*
*&      Form  fert_entsperren
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form fert_entsperren.

  clear: enq_tab.
  refresh enq_tab.

  enq_tab-gname = 'MARC'.
  enq_tab-gmode = 'E'.
  concatenate zz_matnr zz_werks into enq_tab-garg.
  append enq_tab.
  enq_tab-gname = 'MBEW'.
  enq_tab-gmode = 'E'.
  concatenate zz_matnr zz_werks into enq_tab-garg.
  append enq_tab.
  zz_sperr_mat = zz_matnr.

  perform entsperren.

endform.                    " fert_entsperren
*&---------------------------------------------------------------------*
*&      Form  fert_fauf_entsperren
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form fert_fauf_entsperren.

  clear: enq_tab.
  refresh enq_tab.

  enq_tab-gname = 'AUFK'.
  enq_tab-gmode = 'E'.
  enq_tab-garg = zz_fert_fauf.
  append enq_tab.
  zz_sperr_fauf = zz_fert_fauf.

  perform entsperren.

endform.                    " fert_fauf_entsperren
*&---------------------------------------------------------------------*
*&      Form  halb_fauf_entsperren
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form halb_fauf_entsperren.

  clear: enq_tab.
  refresh enq_tab.

  enq_tab-gname = 'AUFK'.
  enq_tab-gmode = 'E'.
  enq_tab-garg = zz_halb_fauf.
  append enq_tab.
  zz_sperr_fauf = zz_halb_fauf.

  perform entsperren.

endform.                    " halb_fauf_entsperren
*&---------------------------------------------------------------------*
*&      Form  bapi_wa_alle
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form bapi_wa_alle.

*   Add success message to application log
  if lc_log_active = abap_true.

    clear ls_bapiret2.
    ls_bapiret2-type = 'S'.
    ls_bapiret2-id = 'ZMDE'.
    ls_bapiret2-number = '999'.
    ls_bapiret2-message_v1 = text-i03.

*     write application log entry
    perform application_log_add_message using lv_log_handle
                                              ls_bapiret2.
  endif.

  clear: z_goodsmovements,
         wa_goodsmovements,
         z_link_conf_goodsmov,
         wa_link_conf_goodsmov,
         z_detreturn,
         z_bapireturn2,
         zz_beleg_nr_2,
         zz_beleg_jahr_2.

* get autyp
  select single autyp into lv_autyp from aufk
      where aufnr = zz_fert_fauf.
  if sy-subrc ne 0.
    clear lv_autyp.
  endif.

  case lv_autyp.

    when '10'.
      clear: z_athdrlevels, wa_athdrlevels.
*     *** Kopfdaten füllen ***
      wa_athdrlevels-postg_date = zz_budat.
      wa_athdrlevels-orderid = zz_fert_fauf.
      wa_athdrlevels-conf_quan_unit = zz_meins.
      wa_athdrlevels-yield = zz_menge_p.
      wa_athdrlevels-fin_conf = ' '.
      wa_athdrlevels-clear_res = ' '.

      append wa_athdrlevels to z_athdrlevels.

      call function 'BAPI_PRODORDCONF_CREATE_HDR'
        exporting
          post_wrong_entries = '2'
          testrun            = ' '
        importing
          return             = z_bapireturn2
        tables
          athdrlevels        = z_athdrlevels
          goodsmovements     = z_goodsmovements
          link_conf_goodsmov = z_link_conf_goodsmov
          detail_return      = z_detreturn.
    when '40'.
      clear: z_athdrlevels_pi, wa_athdrlevels_pi.
*     *** Kopfdaten füllen ***
      wa_athdrlevels_pi-postg_date = zz_budat.
      wa_athdrlevels_pi-orderid = zz_fert_fauf.
      wa_athdrlevels_pi-conf_quan_unit = zz_meins.
      wa_athdrlevels_pi-yield = zz_menge_p.
      wa_athdrlevels_pi-fin_conf = ' '.
      wa_athdrlevels_pi-clear_res = ' '.

      append wa_athdrlevels_pi to z_athdrlevels_pi.

      call function 'BAPI_PROCORDCONF_CREATE_HDR'
        exporting
          post_wrong_entries = '2'
          testrun            = ' '
        importing
          return             = z_bapireturn2
        tables
          athdrlevels        = z_athdrlevels_pi
          goodsmovements     = z_goodsmovements
          link_conf_goodsmov = z_link_conf_goodsmov
          detail_return      = z_detreturn.
  endcase.

  if z_bapireturn2-type ne 'E' and
     z_bapireturn2-type ne 'A'.
    sw_ok = 'J'.

    loop at z_detreturn into wa_detreturn.

*     Add success message to application log
      if lc_log_active = abap_true.
        clear ls_bapiret2.
        move-corresponding wa_detreturn to ls_bapiret2.
*       write application log entry
        perform application_log_add_message using lv_log_handle
                                                  ls_bapiret2.
      endif.

      if wa_detreturn-conf_no is initial.
        clear t9m18.
        t9m18-mandt = sy-mandt.
        t9m18-datum = sy-datum.
        t9m18-zeit  = sy-uzeit.
        t9m18-transaktion = 'BAPI_PRODORDCONF_CREATE_HDR/WA'(t03).
        t9m18-code = '  '.
        t9m18-bwart = '261'.
        t9m18-kzbew = ' '.

        t9m18-werks = zz_werks.
        t9m18-lgort = zz_lgpro_halb.
        t9m18-halbnr = zz_halb.
        t9m18-matnr = zz_matnr.
        t9m18-meins = zz_meins.
        t9m18-menge = zz_menge_p.
        t9m18-charg = zz_charg.
        t9m18-lenum = zz_lenum.
        t9m18-stlal = zz_stlal.
        t9m18-stlan = zz_stlan.
        t9m18-fert_fauf = zz_fert_fauf.
        t9m18-halb_fauf = zz_halb_fauf.
        t9m18-prod_dat = zz_budat.
        t9m18-bu_dat = sy-datum.

        t9m18-msgid = wa_detreturn-id.
        t9m18-msgno = wa_detreturn-number.

        message id wa_detreturn-id type wa_detreturn-type
                number wa_detreturn-number
                with wa_detreturn-message_v1 wa_detreturn-message_v2
                     wa_detreturn-message_v3 wa_detreturn-message_v4
                into t9m18-message.

        insert t9m18.
      endif.

    endloop.

    call function 'BAPI_TRANSACTION_COMMIT'
      exporting
        wait   = 'X'
      importing
        return = bapireturn.
  else.
    sw_ok = 'N'.
    call function 'BAPI_TRANSACTION_ROLLBACK'
      importing
        return = bapireturn.

    clear t9m18.
    t9m18-mandt = sy-mandt.
    t9m18-datum = sy-datum.
    t9m18-zeit  = sy-uzeit.
    t9m18-transaktion = 'BAPI_PRODORDCONF_CREATE_HDR/WA'(t03).
    t9m18-code = '  '.
    t9m18-bwart = '261'.
    t9m18-kzbew = ' '.

    t9m18-werks = zz_werks.
    t9m18-lgort = zz_lgpro_halb.
    t9m18-halbnr = zz_halb.
    t9m18-matnr = zz_matnr.
    t9m18-meins = zz_meins.
    t9m18-menge = zz_menge_p.
    t9m18-charg = zz_charg.
    t9m18-lenum = zz_lenum.
    t9m18-stlal = zz_stlal.
    t9m18-stlan = zz_stlan.
    t9m18-fert_fauf = zz_fert_fauf.
    t9m18-halb_fauf = zz_halb_fauf.
    t9m18-prod_dat = zz_budat.
    t9m18-bu_dat = sy-datum.

    t9m18-msgid = z_bapireturn2-id.
    t9m18-msgno = z_bapireturn2-number.

    message id z_bapireturn2-id type z_bapireturn2-type
            number z_bapireturn2-number
            with z_bapireturn2-message_v1 z_bapireturn2-message_v2
                 z_bapireturn2-message_v3 z_bapireturn2-message_v4
            into t9m18-message.

    insert t9m18.

*   Add message to application log
    if lc_log_active = abap_true.

      loop at z_detreturn into wa_detreturn.
        clear ls_bapiret2.
        move-corresponding wa_detreturn to ls_bapiret2.
*       write log entry
        perform application_log_add_message using lv_log_handle
                                                  ls_bapiret2.
      endloop.
    endif.
  endif.

  if lc_log_active = abap_true.
*   save application log
    perform application_log_save using lt_log_handle
                              changing lt_new_lognumbers.
  endif.

endform.                    " bapi_wa_alle
*&---------------------------------------------------------------------*
*&      Form  ta_erstellen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form ta_erstellen .
  do.
    if sw_halb = 'N'.
      select single * from mseg where mblnr = zz_beleg_nr and
                                      mjahr = zz_beleg_jahr and
                                      zeile = '0001'.
      if sy-subrc ne 0.
        wait up to 3 seconds.
      else.
        exit.
      endif.
    else.
      select single * from mseg where mblnr = zz_beleg_nr_halb and
                                     mjahr = zz_beleg_jahr_halb and
                                     zeile = '0001'.
      if sy-subrc ne 0.
        wait up to 3 seconds.
      else.
        exit.
      endif.
    endif.
  enddo.

  refresh: z_it_trite.
  clear: z_wa_it_trite.
  z_wa_it_trite-tbpos = mseg-tbpos.
  z_wa_it_trite-anfme = mseg-menge.
  z_wa_it_trite-altme = mseg-meins.
  z_wa_it_trite-charg = mseg-charg.
  z_wa_it_trite-nlenr = zz_lenum.
  z_wa_it_trite-letyp = mlgn-lety1.
  append z_wa_it_trite to z_it_trite.

  clear lt_wmgrp_msg.
  call function 'L_TO_CREATE_TR'
    exporting
      i_lgnum                        = zz_lgnum
      i_tbnum                        = mseg-tbnum
      i_nidru                        = ' '
      i_tbeli                        = ' '
      i_commit_work                  = ' '
      it_trite                       = z_it_trite
    importing
      e_tanum                        = z_tanum
    tables
      t_wmgrp_msg                    = lt_wmgrp_msg
    exceptions
      foreign_lock                   = 1
      qm_relevant                    = 2
      tr_completed                   = 3
      xfeld_wrong                    = 4
      ldest_wrong                    = 5
      drukz_wrong                    = 6
      tr_wrong                       = 7
      squit_forbidden                = 8
      no_to_created                  = 9
      update_without_commit          = 10
      no_authority                   = 11
      preallocated_stock             = 12
      partial_transfer_req_forbidden = 13
      input_error                    = 14
      others                         = 15.

  if sy-subrc = 0.
    call function 'BAPI_TRANSACTION_COMMIT'
      exporting
        wait   = 'X'
      importing
        return = bapireturn.

    zz_tanum = z_tanum.
    zz_tapos = '0001'.
*   Add message to application log
    if lc_log_active = abap_true.

      clear ls_bapiret2.
      ls_bapiret2-type = sy-msgty.
      ls_bapiret2-id = sy-msgid.
      ls_bapiret2-number = sy-msgno.
      ls_bapiret2-message_v1 = sy-msgv1.
      ls_bapiret2-message_v2 = sy-msgv2.
      ls_bapiret2-message_v3 = sy-msgv3.
      ls_bapiret2-message_v4 = sy-msgv4.

*     write application log entry
      perform application_log_add_message using lv_log_handle
                                                ls_bapiret2.
    endif.
  else.
    call function 'BAPI_TRANSACTION_ROLLBACK'
      importing
        return = bapireturn.

    zz_tanum = 'Fehler'(001).
    zz_tapos = ' '.

    clear t9m18.
    t9m18-mandt = sy-mandt.
    t9m18-datum = sy-datum.
    t9m18-zeit  = sy-uzeit.
    t9m18-transaktion = 'L_TO_CREATE_TR'.

    t9m18-lenum = zz_lenum.
    t9m18-lgnum = zz_lgnum.
    t9m18-mblnr = mseg-mblnr.
    t9m18-mjahr = mseg-mjahr.

    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            into t9m18-message.

    insert t9m18.

*   Add message to application log
    if lc_log_active = abap_true.

      clear ls_bapiret2.
      ls_bapiret2-type = sy-msgty.
      ls_bapiret2-id = sy-msgid.
      ls_bapiret2-number = sy-msgno.
      ls_bapiret2-message_v1 = sy-msgv1.
      ls_bapiret2-message_v2 = sy-msgv2.
      ls_bapiret2-message_v3 = sy-msgv3.
      ls_bapiret2-message_v4 = sy-msgv4.

*     write application log entry
      perform application_log_add_message using lv_log_handle
                                                ls_bapiret2.
      loop at lt_wmgrp_msg into ls_wmgrp_msg.
        clear ls_bapiret2.
        ls_bapiret2-type = ls_wmgrp_msg-msgty.
        ls_bapiret2-id = ls_wmgrp_msg-msgid.
        ls_bapiret2-number = ls_wmgrp_msg-msgno.
        ls_bapiret2-message_v1 = ls_wmgrp_msg-msgtx.

*       write application log entry
        perform application_log_add_message using lv_log_handle
                                                  ls_bapiret2.
      endloop.

    endif.

  endif.

endform.                    " ta_erstellen
*&---------------------------------------------------------------------*
*&      Form  PROCESS_OK_CODES_0300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form process_ok_codes_0300 .

  case save_ok_code.
    when 'BUCH'.
      if sw_test = ' '.
        perform daten_verbuchen.
      else.
        call screen '0400'.
      endif.
  endcase.

endform.                    " PROCESS_OK_CODES_0300
*&---------------------------------------------------------------------*
*&      Form  INSPECTION_LOT_QAC2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form inspection_lot_qac2 using p_prueflos
                         changing p_beleg_nr
                                  p_beleg_jahr.

  clear: lt_bdcdata,
         ls_bdcdata.

* *** Dynpro 0100 ***
  ls_bdcdata-program = 'SAPLQPL1'.
  ls_bdcdata-dynpro = '0100'.
  ls_bdcdata-dynbegin = 'X'.
  append ls_bdcdata to lt_bdcdata.
  clear ls_bdcdata.
  ls_bdcdata-fnam = 'BDC_CURSOR'.
  ls_bdcdata-fval = 'QALS-PRUEFLOS'.
  append ls_bdcdata to lt_bdcdata.
  clear ls_bdcdata.
  ls_bdcdata-fnam = 'QALS-PRUEFLOS'.
  ls_bdcdata-fval = p_prueflos.
  append ls_bdcdata to lt_bdcdata.
  clear ls_bdcdata.
  ls_bdcdata-fnam = 'BDC_OKCODE'.
  ls_bdcdata-fval = '/00'.
  append ls_bdcdata to lt_bdcdata.
  clear ls_bdcdata.

* *** Dynpro 0300 ***
  ls_bdcdata-program = 'SAPLQPL1'.
  ls_bdcdata-dynpro = '0300'.
  ls_bdcdata-dynbegin = 'X'.
  append ls_bdcdata to lt_bdcdata.
  clear ls_bdcdata.
  ls_bdcdata-fnam = 'BDC_CURSOR'.
  ls_bdcdata-fval = 'QALS-PRUEFLOS'.
  append ls_bdcdata to lt_bdcdata.
  clear ls_bdcdata.
  ls_bdcdata-fnam = 'RMQEA-UMLWERK'.
  ls_bdcdata-fval = lv_werks_n.
  append ls_bdcdata to lt_bdcdata.
  clear ls_bdcdata.
  ls_bdcdata-fnam = 'RMQEA-UMLLGORT'.
  ls_bdcdata-fval = lv_lgort_n.
  append ls_bdcdata to lt_bdcdata.
  clear ls_bdcdata.
  ls_bdcdata-fnam = 'BDC_OKCODE'.
  ls_bdcdata-fval = '=BU'.
  append ls_bdcdata to lt_bdcdata.
  clear ls_bdcdata.

  clear: lt_otab,
         ls_otab.

  lv_mode = 'N'.

  call transaction 'QAC2' using lt_bdcdata mode lv_mode
                          messages into lt_otab.

  loop at otab where msgtyp = 'A' or
                     msgtyp = 'E'.

    clear t9m18.
    t9m18-mandt = sy-mandt.
    t9m18-datum = sy-datum.
    t9m18-zeit  = sy-uzeit.
    t9m18-transaktion = 'QAC2'.

    t9m18-mblnr = zz_beleg_nr.
    t9m18-mjahr = zz_beleg_jahr.

    t9m18-msgid = ls_otab-msgid.
    t9m18-msgno = ls_otab-msgnr.

    message id ls_otab-msgid type ls_otab-msgtyp number ls_otab-msgnr
            with ls_otab-msgv1 ls_otab-msgv2 ls_otab-msgv3 ls_otab-msgv4
            into t9m18-message.

    insert t9m18.

*     add title message to application log
    if lc_log_active = abap_true.
      if sy-tabix = 1.

        clear ls_bapiret2.
        ls_bapiret2-type = 'S'.
        ls_bapiret2-id = 'ZMDE'.
        ls_bapiret2-number = '999'.
        ls_bapiret2-message_v1 = text-i05.

*     write application log entry
        perform application_log_add_message using lv_log_handle
                                                  ls_bapiret2.
      endif.


      clear ls_bapiret2.
      ls_bapiret2-type = ls_otab-msgtyp.
      ls_bapiret2-id = ls_otab-msgid.
      ls_bapiret2-number = ls_otab-msgnr.
      ls_bapiret2-message_v1 = ls_otab-msgv1.
      ls_bapiret2-message_v2 = ls_otab-msgv2.
      ls_bapiret2-message_v3 = ls_otab-msgv3.
      ls_bapiret2-message_v4 = ls_otab-msgv4.
*     write log entry
      perform application_log_add_message using lv_log_handle
                                                ls_bapiret2.
    endif.

    if sy-binpt is initial.

      perform show_message using '258' p_prueflos t9m18-message '' ''.

      call screen 999.
      exit.
    endif.
  endloop.

  if sy-subrc ne 0.
    p_beleg_nr = sy-msgv1(10).
    p_beleg_jahr = sy-msgv1+10(4).

    if lc_log_active = abap_true.
      clear ls_bapiret2.
      ls_bapiret2-type = 'S'.
      ls_bapiret2-id = 'ZMDE'.
      ls_bapiret2-number = '999'.
      ls_bapiret2-message_v1 = text-i05.
      concatenate p_beleg_nr
                  p_beleg_jahr
                  text-i07
             into ls_bapiret2-message_v2 separated by ' '.

*     write application log entry
      perform application_log_add_message using lv_log_handle
                                                ls_bapiret2.
    endif.
  endif.

  if lc_log_active = abap_true.
*   save application log
    perform application_log_save using lt_log_handle
                              changing lt_new_lognumbers.
  endif.

endform.                    " INSPECTION_LOT_QAC2
*&---------------------------------------------------------------------*
*&      Form  MOVE_STOCK_TO_0001_3980
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form move_stock_to_0001_3980 changing p_beleg_nr
                                      p_beleg_jahr.

  clear bapigmhead.

  bapigmhead-pstng_date = zz_budat.
  bapigmhead-doc_date   = sy-datum.

*Zuordnung Code zu Transaktion für BAPI Warenbewegung 04=MB1B
  bapigmcode-gm_code    = '04'.
  bapitestrun = ' '.

  clear ximseg.
  refresh ximseg.
  clear xemseg.
  refresh xemseg.
*Bewegungsart (Bestandsführung)
  ximseg-move_type     = '301'.
*Menge in Erfassungsmengeneinheit
  ximseg-entry_qnt     = zz_menge_p.
*Erfassungsmengeneinheit
  ximseg-entry_uom     = zz_meins.
*Bewegungskennzeichen
  ximseg-mvt_ind       = ' '.
*Material
  ximseg-material      = zz_matnr.
*Werk
  ximseg-plant         = zz_werks.
  ximseg-move_plant    = lv_werks_n.
*Lagerort
  ximseg-stge_loc      = zz_lgort.
  ximseg-move_stloc     = lv_lgort_n.
*Auftragsnummer
  ximseg-orderid       = zz_halb_fauf.

  if zz_fert_xchpf eq 'X'.
    ximseg-batch = zz_charg.
  endif.

  append ximseg.

  clear: p_beleg_nr,
         p_beleg_jahr.

  call function 'BAPI_GOODSMVT_CREATE'
    exporting
      goodsmvt_header  = bapigmhead
      goodsmvt_code    = bapigmcode
      testrun          = bapitestrun
    importing
      goodsmvt_headret = bapigmheadret
    tables
      return           = xemseg
      goodsmvt_item    = ximseg.

  if not bapigmheadret is initial.
* Add title message to application log
    if lc_log_active = abap_true.

      clear ls_bapiret2.
      ls_bapiret2-type = 'S'.
      ls_bapiret2-id = 'ZMDE'.
      ls_bapiret2-number = '999'.
      ls_bapiret2-message_v1 = text-i06.
      concatenate bapigmheadret-mat_doc
                  bapigmheadret-doc_year
             into ls_bapiret2-message_v2 separated by ' '.

*     write application log entry
      perform application_log_add_message using lv_log_handle
                                                ls_bapiret2.
    endif.

    call function 'BAPI_TRANSACTION_COMMIT'
      exporting
        wait   = 'X'
      importing
        return = bapireturn.

    p_beleg_nr = bapigmheadret(10).
    p_beleg_jahr = bapigmheadret+10(4).
  else.
    call function 'BAPI_TRANSACTION_ROLLBACK'
      importing
        return = bapireturn.

    clear t9m18.
    t9m18-mandt = sy-mandt.
    t9m18-datum = sy-datum.
    t9m18-zeit  = sy-uzeit.
    t9m18-transaktion = 'BAPI_GOODSMVT_CREATE/WE-HALB'(t02).
    t9m18-code = '02'.
    t9m18-bwart = '301'.
    t9m18-kzbew = 'F'.

    t9m18-werks = zz_werks.
    t9m18-lgort = zz_lgpro_halb.
    t9m18-halbnr = zz_halb.
    t9m18-matnr = zz_matnr.
    t9m18-meins = zz_meins.
    t9m18-menge = zz_menge_p.
    t9m18-charg = zz_charg.
    t9m18-lenum = zz_lenum.
    t9m18-stlal = zz_stlal.
    t9m18-stlan = zz_stlan.
    t9m18-fert_fauf = zz_fert_fauf.
    t9m18-halb_fauf = zz_halb_fauf.
    t9m18-prod_dat = zz_budat.
    t9m18-bu_dat = sy-datum.

    loop at xemseg.
      t9m18-msgid = xemseg-id.
      t9m18-msgno = xemseg-number.

      message id xemseg-id type xemseg-type number xemseg-number
              with xemseg-message_v1 xemseg-message_v2 xemseg-message_v3
                   xemseg-message_v4
              into zz_fehler_text.
      t9m18-message = zz_fehler_text.
      exit.
    endloop.
    insert t9m18.

*   Add message to application log
    if lc_log_active = abap_true.

      loop at xemseg into ls_bapiret2.
*       write log entry
        perform application_log_add_message using lv_log_handle
                                                  ls_bapiret2.
      endloop.
    endif.

    if sy-binpt is initial.
      perform show_message using '259' zz_fehler_text '' '' ''.

      call screen 999.
    endif.
  endif.

  if lc_log_active = abap_true.
*   save application log
    perform application_log_save using lt_log_handle
                              changing lt_new_lognumbers.
  endif.

endform.                    " MOVE_STOCK_TO_0001_3980
*&---------------------------------------------------------------------*
*&      Form  CHECK_ORDER_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_order_status using p_variante.

  case ls_afpo-dauat.
    when 'PP01'.
      select * from jest where objnr = zz_objnr and
                               inact = space    and
                             ( stat eq zz_sper_a or         "Locked
                               stat eq zz_sper_i or         "Locked
                               stat eq zz_lovm   or         "Deletion Flag
                               stat eq zz_abgs   or         "Closed
                               stat eq zz_tabg_a or         "Finished
                               stat eq zz_tabg_i ).         "Technically Completed
      endselect.
    when 'PI01'.
      select * from jest where objnr = zz_objnr and
                               inact = space    and
                             ( stat eq lc_nobatch or        "No batch
                               stat eq lc_recipe_allowed or "Create control recipe allowed
                               stat eq lc_manufact_closed or"Manufacturing close completed
                               stat eq lc_techn_compl or    "User status technically completed
                               stat eq zz_sper_i or         "Locked
                               stat eq zz_lovm   or         "Deletion Flag
                               stat eq zz_abgs   or         "Closed
                               stat eq zz_tabg_a or         "Finished
                               stat eq zz_tabg_i ).         "Technically Completed
      endselect.
  endcase.

  if sy-subrc ne 0.
    select single * from aufk where aufnr = ls_afko-aufnr and
                                    werks = zz_werks.
    if sy-subrc eq 0.
      case p_variante.
        when '1'.
          if not ls_afko-stlnr is initial and
             not ls_afko-stlal is initial and
             not ls_afko-stlan is initial.
            zz_fert_fauf  = ls_afko-aufnr.
            zz_fert_rsnum = ls_afko-rsnum.
            zz_stlal      = ls_afko-stlal.
            zz_stlan      = ls_afko-stlan.
          endif.
        when '2'.
          if ls_afpo-matnr eq zz_halb.
            zz_halb_fauf = ls_afko-aufnr.
          endif.
        when '3'.
          if ls_afpo-matnr eq zz_matnr.
            if not ls_afko-stlnr is initial and
               not ls_afko-stlal is initial and
               not ls_afko-stlan is initial.
              zz_fert_fauf = ls_afpo-aufnr.
              zz_fert_rsnum = ls_afko-rsnum.
              zz_stlal = ls_afko-stlal.
              zz_stlan = ls_afko-stlan.
            endif.
          else.
            zz_halb_fauf = ls_afpo-aufnr.
          endif.
      endcase.
    endif.
  endif.

endform.
*&---------------------------------------------------------------------*
*&      Form  CREATE_APPLICATION_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LC_ZMDE  text
*----------------------------------------------------------------------*
form create_application_log changing p_lt_log_handle type bal_t_logh
                                     p_ls_s_log type bal_s_log
                                     p_log_handle.
  clear ls_log_handle.

  call function 'BAL_LOG_CREATE'
    exporting
      i_s_log                 = p_ls_s_log
    importing
      e_log_handle            = ls_log_handle
    exceptions
      log_header_inconsistent = 1
      others                  = 2.

  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    ls_log_handle = p_log_handle = ls_log_handle.
    append ls_log_handle to p_lt_log_handle.
  endif.

endform.
*&---------------------------------------------------------------------*
*&      Form  APPLICATION_LOG_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_LOG_HANDLE  text
*----------------------------------------------------------------------*
form application_log_save  using p_lt_log_handle type bal_t_logh
                           changing p_lt_new_lognumbers type bal_t_lgnm.

  call function 'BAL_DB_SAVE'
    exporting
      i_client         = sy-mandt
      i_save_all       = ' '
      i_t_log_handle   = p_lt_log_handle
    importing
      e_new_lognumbers = p_lt_new_lognumbers
    exceptions
      log_not_found    = 1
      save_not_allowed = 2
      numbering_error  = 3
      others           = 4.

  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.
*&---------------------------------------------------------------------*
*&      Form  APPLICATION_LOG_ADD_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_LOG_HANDLE  text
*      -->P_LS_BAPIRET2  text
*----------------------------------------------------------------------*
form application_log_add_message  using p_lv_log_handle
                                        p_ls_returnmessage type bapiret2.
  if p_ls_returnmessage is not initial.

    clear ls_s_msg.
    ls_s_msg-msgty = p_ls_returnmessage-type.
    ls_s_msg-msgid = p_ls_returnmessage-id.
    ls_s_msg-msgno = p_ls_returnmessage-number.
    ls_s_msg-msgv1 = p_ls_returnmessage-message_v1.
    ls_s_msg-msgv2 = p_ls_returnmessage-message_v2.
    ls_s_msg-msgv3 = p_ls_returnmessage-message_v3.
    ls_s_msg-msgv4 = p_ls_returnmessage-message_v4.

    call function 'BAL_LOG_MSG_ADD'
      exporting
        i_log_handle     = p_lv_log_handle
        i_s_msg          = ls_s_msg
      exceptions
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        others           = 4.

    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

  endif.

endform.
