*----------------------------------------------------------------------*
*   INCLUDE MZLMXTOP                                                   *
*----------------------------------------------------------------------*

tables: mara,
        makt,
        marc,
        mard,
        mbew,
        mlgn,
        mlgt,
        mch1,
        mchb,
        ekko,
        ekpo,
        eket,
        lagp,
        lqua,
        ltak,
        ltap,
        lein,
        rkpf,
        resb,
        aufk,
        afko,
        afpo,
        afwi,
        jest,
        csks,
        mkpf,
        mseg,
        qals,
        pa0105,
        pa0050,
        t005,
        t001,
        t001w,
        t001l,
        t300,
        t301,
        t9m18,
        rlmob,
        usr05,
        stko,
        stpo,
        t100,
        t340d,
        t320,
        nriv,
        cabn.

data: ls_tka02 type tka02,
      ls_prps  type prps,
      ls_t001k type t001k,
      ls_mch1  type mch1,
      ls_mard  type mard,
      ls_mchb  type mchb,
      ls_cabn  type cabn,
      ls_cawnt type cawnt.

data: sw_test(1)    type c value 'X',
      sw_ohne_ta(1) type c,
      sw_ndr(1)     type c,
      sw_ok(1)      type c,
      sw_halb(1)    type c,
      sw_mit_lvs(1) type c.

data: ok_code                 like sy-ucomm, save_ok_code like sy-ucomm,
      zz_dynnr_alt            like sy-dynnr,

*     *** Felder für Selektionsbild ***
      scr_zeile(2)            type n,
      scr_lgnum               like lagp-lgnum,
      scr_matnr               like lqua-matnr,
      scr_tanum               like ltak-tanum,
      scr_halb(8)             type c,
      scr_charg               like lqua-charg,
      scr_menge(13)           type c,
      scr_meins               like mara-meins,
      scr_lgtyp               like lagp-lgtyp,
      scr_lgpla               like lagp-lgpla,
      zz_mandt                like sy-mandt,
      zz_bukrs                like aufk-bukrs,
      zz_werks                like marc-werks,
      lv_werks                type werks_d,
      zz_werks_v              like marc-werks,
      zz_werks_n              like marc-werks,
      zz_qndat                like mcha-qndat,
      zz_ebeln                like ekko-ebeln,
      zz_ebelp                like ekpo-ebelp,
      zz_lgort                like mard-lgort,
      zz_lgort_v              like mard-lgort,
      zz_lgort_n              like mard-lgort,
      zz_matnr                like mara-matnr,
      zz_matnr_lang(60)       type c,
      zz_matnr_num(18)        type n,
      zz_sperr_mat            like mara-matnr,
      zz_sperr_fauf           like aufk-aufnr,
      zz_meins_verp           like mara-meins,
      zz_matnr_verp           like mara-matnr,
      zz_dispo                like marc-dispo,
      zz_fevor                like marc-fevor,
      zz_lenum                like lein-lenum,
      zz_rsnum                like resb-rsnum,
      zz_rspos                like resb-rspos,
      zz_kont(16)             type c,
      zz_aufnr_n(12)          type n,
      zz_pspnr                type ps_intnr,
      zz_kont2(1)             type c,
      zz_kostl                type kostl,
      zz_aufnr                like aufk-aufnr,
      zz_aufps                like afpo-posnr,
      zz_lgnum                like lagp-lgnum,
      zz_lgnum_v              like lagp-lgnum,
      zz_lgtyp                like lagp-lgtyp,
      zz_lgtyp_v              like lagp-lgtyp,
      zz_lgpla_v              like lagp-lgpla,
      zz_lgnum_n              like lagp-lgnum,
      zz_lgtyp_n              like lagp-lgtyp,
      zz_lgpla_n              like lagp-lgpla,
      zz_lgpla                like lagp-lgpla,
      zz_lgpla2               like lagp-lgpla,
      zz_lqnum                like lqua-lqnum,
      zz_text_1(12)           type c,
      zz_text_2(12)           type c,
      zz_text_3(12)           type c,
      zz_feld_1(10)           type c,
      zz_feld_2(10)           type c,
      zz_feld_21(10)          type c,
      zz_feld_22(10)          type c,
      zz_feld_23(10)          type c,
      zz_feld_3(10)           type c,
      zz_feld_4(10)           type c,
      zz_feld_5(10)           type c,
      zz_maktx(40)            type c,
      zz_mattext(40)          type c,
      zz_mattext1(40)         type c,
      zz_zeile(2)             type n,
      zz_zeile2(1)            type n,
      zz_ausw(1)              type n,
      zz_bestq                type c,
      zz_tcode                like sy-tcode,
      zz_charg                like lqua-charg,
      lv_fauf                 type aufnr,
      lv_fehler               type flag,
      zz_charg_lief(15)       type c,
      zz_charg_2              like lqua-charg,
      zz_halb                 like mara-matnr,
      zz_halb_fauf            like afpo-aufnr,
      zz_lgpro_halb           like marc-lgpro,
      zz_lgpro_verp           like marc-lgpro,
      zz_fert_fauf            like afpo-aufnr,
      zz_fert_rsnum           like afko-rsnum,
      zz_wedat                like sy-datum,
      zz_budat                like sy-datum,
      zz_budatm1              like sy-datum,
      zz_budatm2              like sy-datum,
      zz_budatm3              like sy-datum,
      zz_budatp1              like sy-datum,
      zz_budatp2              like sy-datum,
      zz_budatp3              like sy-datum,
      zz_wochentag(10)        type c,
      zz_monatsanfang         type c,
      zz_prod                 like sy-datum,
      zz_wempf                like resb-wempf,
      zz_wempf2(80)           type c,
      zz_zausw(8)             type n,
      zz_ablad                like ekkn-ablad,
      zz_akt_monat            like sy-datum,
      zz_vor_monat            like sy-datum,
      zz_menge(10)            type c,
      zz_menge_2(8)           type c,
      zz_menge_n(11)          type c,
      lv_vfdat                type vfdat,
      zz_menge_3(10)          type c,
      zz_menge_p              type p decimals 3 value 0,
      zz_faktor               type f,
      zz_menge_verp           like zz_menge_p,
      zz_meins                like mara-meins,
      zz_lfsnr(16)            type c,
      zz_anzgeb(4)            type n,
      zz_anzpal(4)            type n,
      zz_anzpal_2(4)          type n,
      zz_cursor_feld(15)      type c,
      antwort(1)              type c,
      varc1(1)                type c,
      zz_tabix                like sy-tabix,
      zz_objnr(22)            type c,
      zz_status(40)           type c,
      zz_beleg_nr(10)         type c,
      zz_wa_beleg_nr(10)      type c,
      zz_beleg_pos            like mseg-zeile,
      zz_beleg_jahr(4)        type c,
      zz_wa_beleg_jahr(4)     type c,
      zz_beleg_nr_halb(10)    type c,
      zz_beleg_jahr_halb(4)   type c,
      zz_beleg_nr_halb_2(10)  type c,
      zz_beleg_jahr_halb_2(4) type c,
      zz_beleg_nr_verp(10)    type c,
      zz_beleg_jahr_verp(4)   type c,
      zz_beleg_nr_2(10)       type c,
      zz_beleg_jahr_2(4)      type c,
      zz_status_text(40)      type c,
      zz_tanum                type tanum,
      zz_tapos(4)             type c,
      zz_bwart                like mseg-bwart,
      zz_feld1(10)            type c,
      zz_feld2                like zz_feld1,
      zz_feld3                like zz_feld1,
      zz_stlal                like afko-stlal value '01',
      zz_stlan                like afko-stlan value '1',
      zz_fehler_text(100)     type c,
      zz_text1(110)           type c,
      zz_text2(110)           type c,
      zz_fert_xchpf           like mara-xchpf,
      zz_halb_xchpf           like mara-xchpf,
      zz_kupl_xchpf           like mara-xchpf,
      zz_alles_freigeben(1)   type c value 'N',
      zz_anz_quant(4)         type n,
      zz_gerade_zahl          type i,
      zz_diff                 type p decimals 3,
      zz_nullkomafuenf        type p decimals 3 value '0.5'.

data: scr_ebelp1(5)       type c,
      scr_ebelp2          like scr_ebelp1,
      scr_ebelp3          like scr_ebelp1,
      scr_matnr1          like scr_matnr,
      scr_matnr2          like scr_matnr,
      scr_matnr3          like scr_matnr,
      scr_matnr4          like scr_matnr,
      scr_matnr_lang1(20) type c,
      scr_matnr_lang2(20) type c,
      scr_matnr_lang3(20) type c,
      scr_kont1(1)        type c,
      scr_kont2           like scr_kont1,
      scr_kont3           like scr_kont1,
      scr_lgpla1          like scr_lgpla,
      scr_lgpla2          like scr_lgpla,
      scr_lgpla3          like scr_lgpla,
      scr_mengec(10)      type c,
      scr_menge1(10)      type c,
      scr_menge2(10)      type c,
      scr_menge3(10)      type c,
      scr_menge4(10)      type c,
      scr_menget(10)      type c,
      scr_meins1          like zz_meins,
      scr_meins2          like scr_meins1,
      scr_meins3          like scr_meins1,
      scr_meins4          like scr_meins1,
      scr_meinst          like scr_meins1,
      scr_charg1          like zz_charg,
      scr_charg2          like scr_charg1,
      scr_charg3          like scr_charg1,
      scr_zust1(1)        type c,
      scr_zust2           like scr_zust1,
      scr_zust3           like scr_zust1,
      scr_zeile1(3)       type c,
      scr_zeile2          like scr_zeile1,
      scr_zeile3          like scr_zeile1,
      scr_zeile4          like scr_zeile1,
      scr_zeile11(2)      type c,
      scr_zeile12         like scr_zeile11,
      scr_zeile13         like scr_zeile11,
      scr_zeile14         like scr_zeile11,
      scr_lenum1(10)      type c,
      scr_lenum2(10)      type c,
      scr_lenum3(10)      type c,
      scr_bdatu1(10)      type c,
      scr_bdatu2(10)      type c,
      scr_bdatu3(10)      type c,
      scr_lgtyp1(10)      type c,
      scr_lgtyp2(10)      type c,
      scr_lgtyp3(10)      type c,
      scr_ausw1           type flag,
      scr_ausw2           type flag,
      scr_ausw3           type flag.

data: zz_sper_a          like jest-stat value 'E0002',         "E0002   1     LKD   Locked (for Production ORD, status profile is 00000004)
      zz_sper_i          like jest-stat value 'I0043',         "I0043   E     LKD   Locked
      zz_tabg_i          like jest-stat value 'I0045',         "I0045   E     TECO  Technically completed
      zz_lovm            like jest-stat value 'I0076',         "I0076   E     DLFL  Deletion Flag
      zz_abgs            like jest-stat value 'I0046',         "I0046   E     CLSD  Closed
      zz_tabg_a          like jest-stat value 'E0007',         "E0007   D     TABG  finished (for Production ORD, status profile is 00000004)
      zz_frei            like jest-stat value 'I0002',         "I0002   E     REL   Released
      zz_abrv            like jest-stat value 'I0028',         "I0028   E     SETC  Settlement rule created
      lc_nobatch         type j_status value 'E0001',
      lc_recipe_allowed  type j_status value 'E0003',
      lc_manufact_closed type j_status value 'E0004',
      lc_techn_compl     type j_status value 'E0005'.

data:              zz_teco like jest-stat value 'E0004',         "User Status Technically Coml. (status profile Z_PI01)
                   zz_dlt  like jest-stat value 'I0013'.         "Deletion indicator

data: zz_decim     type i,
      zz_expon     type i,
      zz_flstr(22),
      zz_ivalu(1).

data: begin of matnr_tab occurs 1,
        sign(1)   type c,
        option(2) type c,
        low(18)   type c,
        high(18)  type c,
      end of matnr_tab.

data: begin of komp_tab occurs 1,
        mtart like mara-mtart,
        idnrk like mara-matnr,
        lgpro like marc-lgpro,
        charg like resb-charg,
        menge like stpo-menge,
        meins like stpo-meins,
        rsnum like resb-rsnum,
        rspos like resb-rspos,
      end of komp_tab.

data: begin of stpo_tab occurs 1,
        mtart like mara-mtart,
        idnrk like mara-matnr,
        lgpro like marc-lgpro,
        menge like stpo-menge,
        meins like stpo-meins,
      end of stpo_tab.

data: begin of resb_tab occurs 1,
        matnr like resb-matnr,
        rsnum like resb-rsnum,
        rspos like resb-rspos,
        rsart like resb-rsart,
        lgort like resb-lgort,
      end of resb_tab.

data: begin of ekpo_tab occurs 5,
        ebelp      like ekpo-ebelp,
        matnr      like ekpo-matnr,
        lgort      like ekpo-lgort,
        lgnum      like zz_lgnum,
        kont2(1)   type c,
        lgtyp      like mlgn-ltkze,
        lgpla      like zz_lgpla,
        menge      like ekpo-menge,
        meins      like ekpo-meins,
        ohne_ta(1) type c,
        buch(1)    type c,
      end of ekpo_tab,
      max_ekpo_tab like sy-tabix,
      akt_ekpo_tab like sy-tabix.

data: begin of wa_tab occurs 5,
        zeile(3) type n,
        matnr    like ekpo-matnr,
        lgpla    like zz_lgpla,
        menge    like ekpo-menge,
        meins    like ekpo-meins,
        charg    like zz_charg,
        werks    type werks_d,
        buch(1)  type c,
      end of wa_tab,
      max_wa_tab like sy-tabix,
      akt_wa_tab like sy-tabix.

data: begin of ltak_tab occurs 5,
        tanum like ltak-tanum,
        tapos like ltap-tapos,
        matnr like ltap-matnr,
      end of ltak_tab,
      max_ltak_tab like sy-tabix,
      akt_ltak_tab like sy-tabix.

data: begin of lgpla_tab occurs 1,
        sign(1)   type c,
        option(2) type c,
        low(18)   type c,
        high(18)  type c,
      end of lgpla_tab.

data: begin of itab occurs 10,
        lgpla like lqua-lgpla,
        matnr like lqua-matnr,
        charg like lqua-charg,
        bestq like lqua-bestq,
        vfdat type vfdat,
        lenum like lqua-lenum,
        gesme like lqua-gesme,
        meins like lqua-meins,
      end of itab,
      max_itab  like sy-tabix,
      akt_itab  like sy-tabix,
      tab_index like sy-tabix,
      zz_stepl  like sy-stepl.

data: begin of lagp_tab occurs 5,
        lgnum like lqua-lgnum,
        matnr like lqua-matnr,
        lgtyp like lqua-lgtyp,
        lgpla like lqua-lgpla,
        charg like lqua-charg,
        menge like lqua-verme,
        meins like ekpo-meins,
        vfdat	type vfdat,
      end of lagp_tab,
      max_lagp_tab like sy-tabix,
      akt_lagp_tab like sy-tabix.

data: begin of lqua_tab occurs 5,
        lqnum like lqua-lqnum,
        lgtyp like lqua-lgtyp,
        lgpla like lqua-lgpla,
        matnr like lqua-matnr,
        charg like lqua-charg,
        bestq like lqua-bestq,
        sobkz like lqua-sobkz,
        sonum like lqua-sonum,
        gesme like lqua-gesme,
        meins like lqua-meins,
      end of lqua_tab,
      max_lqua_tab like sy-tabix,
      akt_lqua_tab like sy-tabix.

data: begin of ta_tab occurs 5,
        tanum like ltak-tanum,
      end of ta_tab,
      max_ta_tab like sy-tabix,
      akt_ta_tab like sy-tabix.

data: begin of ta_pos_tab occurs 5,
        bdatu like ltak-bdatu,
        bzeit like ltak-bzeit,
        tanum like ltak-tanum,
        tapos like ltap-tapos,
        vlenr like ltap-vlenr,
        matnr like ltap-matnr,
        charg like ltap-charg,
        vlpla like ltap-vlpla,
        nlpla like ltap-nlpla,
        nltyp like ltap-nltyp,
        vsolm like ltap-vsolm,
        meins like ltap-meins,
      end of ta_pos_tab,
      max_ta_pos_tab like sy-tabix,
      akt_ta_pos_tab like sy-tabix.

data: begin of le_tab occurs 20,
        lenum like lein-lenum,
        lgtyp like lein-lgtyp,
        lgpla like lein-lgpla,
        bdatu like lein-bdatu,
        bzeit like lein-bzeit,
        gesme like lqua-gesme,
        meins like lqua-meins,
      end of le_tab,
      max_le_tab  like sy-tabix,
      akt_le_tab  like sy-tabix,
      zz_le_total like lqua-gesme.

* *** Tabelle für Sperreintragstest ***
data: begin of enq_tab occurs 2.
        include structure seqta.
data: end of enq_tab.

data: gobj like seqg3-gobj.

data: guname like seqg3-guname.

* *** Tabellen für Call Transaction Daten ***
data begin of bdcdata occurs 10.
        include structure bdcdata.
data end of bdcdata.

* *** Tabellen für Call Transaction Meldungen ***
data begin of otab occurs 10.
        include structure bdcmsgcoll.
data end of otab.

* *** Datendefinitionen für BAPI GOODSMOVEMENT

data: bapigmhead            like bapi2017_gm_head_01,
      bapigmcode            like bapi2017_gm_code,
      bapigmheadret         like bapi2017_gm_head_ret,
      bapitestrun           like bapi2017_gm_gen-testrun,
      bapiwait              like bapita-wait,
      bapireturn            like bapiret2,
      z_bapireturn2         type bapiret1,
      z_detreturn           type standard table
                            of bapi_coru_return
                            with default key,
      wa_detreturn          type bapi_coru_return,
      z_athdrlevels         type standard table
                              of bapi_pp_hdrlevel
                              with default key,
      wa_athdrlevels        type bapi_pp_hdrlevel,
      z_athdrlevels_pi      type standard table           "Order Confirmation for PP-PI, Gerry Li
                           of bapi_pi_hdrlevel
                           with default key,
      wa_athdrlevels_pi     type bapi_pi_hdrlevel,
      z_goodsmovements      type standard table
                           of bapi2017_gm_item_create
                           with default key,
      wa_goodsmovements     type bapi2017_gm_item_create,
      z_link_conf_goodsmov  type standard table
                       of bapi_link_conf_goodsmov
                       with default key,
      wa_link_conf_goodsmov type bapi_link_conf_goodsmov.

data: begin of ximseg occurs 1.
        include structure bapi2017_gm_item_create.
data: end of ximseg.

data: begin of xemseg occurs 1.
        include structure bapiret2.
data: end of xemseg.

data: zz_message1(40) type c,
      zz_message2     like zz_message1,
      zz_message3     like zz_message1,
      zz_message4     like zz_message1,
      zz_message5     like zz_message1,
      zz_message6     like zz_message1,
      zz_message7     like zz_message1,
      zz_message8     like zz_message1.

data: z_message(210) type c.

data: z_fehlertext type string.
types: begin of s_fehler,
         zeile(25) type c,
       end of s_fehler.
data: z_t_fehler  type table of s_fehler,
      z_wa_fehler type s_fehler.
data: l_line_tab    type table of sotr_line_range,
      l_line_tab_wa type sotr_line_range.

data: zz_sachmerkmal_id    like cabn-atinn,
      zz_charge_zustand(1) type c,
      zz_wert(8)           type n.

data: begin of auspx occurs 10.
        include structure ausp.
data: end of auspx.

data: begin of alloc occurs 10.
        include structure kssk.
data: end of alloc.

* Makro zum Fehlerzeilen sauber füllen
define m_fehler.

  clear: z_t_fehler,
         zz_message1,
         zz_message2,
         zz_message3,
         zz_message4,
         zz_message5,
         zz_message6,
         zz_message7,
         zz_message8.

  z_fehlertext = &1.
  condense z_fehlertext.

  call function 'SOTR_SERV_PREPARE_STRING'
    exporting
      text                = z_fehlertext
      flag_no_line_breaks = 'X'
      line_length         = &2
      langu               = sy-langu
    tables
      text_tab            = z_t_fehler.

  loop at z_t_fehler into z_wa_fehler.
    case sy-tabix.
      when 1.
        zz_message1 = z_wa_fehler-zeile.
      when 2.
        zz_message2 = z_wa_fehler-zeile.
      when 3.
        zz_message3 = z_wa_fehler-zeile.
      when 4.
        zz_message4 = z_wa_fehler-zeile.
      when 5.
        zz_message5 = z_wa_fehler-zeile.
      when 6.
        zz_message6 = z_wa_fehler-zeile.
      when 7.
        zz_message7 = z_wa_fehler-zeile.
      when 8.
        zz_message8 = z_wa_fehler-zeile.
    endcase.
  endloop.

end-of-definition.

* *** Felder für erweiterten Barcode (EAN128) ***
tables: t313d,
        t313g.

data: ls_t313d               type t313d,
      ls_t313g               type t313g,
      zz_ean128_begrenzer(3) type c,
      zz_barcode_op(60)      type c,
      zz_fehler(1)           type c,
      zz_pruefziffer(1)      type c.

data: zz_strlen    type i,
      zz_length(1) type n,
      zz_startpos  like sy-fdpos.

data: begin of zz_ai occurs 3,
        ai(9)          type c,
        length(2)      type n,
        data(20)       type c,
        data_p(20)     type c,
        aichk(03)      type n,
        pruefziffer(1) type c,
        fehler(1)      type c,
      end of zz_ai.

* Selektionstabellen

data: begin of sel_lgpla occurs 0,
        sign(1)   type c,
        option(2) type c,
        low       like lqua-lgpla,
        high      like lqua-lgpla,
      end of sel_lgpla.
data: begin of sel_matnr occurs 0,
        sign(1)   type c,
        option(2) type c,
        low       like lqua-matnr,
        high      like lqua-matnr,
      end of sel_matnr.

* Spezialfelder für SAPMZLMU2
data: zz_wert1(10) type c,
      zz_wert2(10) type c,
      zz_text3(10) type c,
      zz_text4(10) type c,
      zz_matnr2    like lqua-matnr,
      zz_sobkz     like lqua-sobkz,
      zz_sonum     like lqua-sonum,
      zz_tbnum_v   like mseg-tbnum,
      zz_tbpos_v   like mseg-tbpos,
      zz_tbnum_n   like mseg-tbnum,
      zz_tbpos_n   like mseg-tbpos.

* *** Datendefinitionen für BAPI_MATERIAL_SAVEDATA ***
data: z_headdata             like bapimathead,
      z_clientdata           like bapi_mara,
      z_clientdatax          like bapi_marax,
      z_plantdata            like bapi_marc,
      z_plantdatax           like bapi_marcx,
      z_forecastparameters   like bapi_mpop,
      z_forecastparametersx  like bapi_mpopx,
      z_valuationdata        like bapi_mbew,
      z_valuationdatax       like bapi_mbewx,
      z_storagelocationdata  like bapi_mard,
      z_storagelocationdatax like bapi_mardx,
      z_warehousenumberdata  like bapi_mlgn,
      z_warehousenumberdatax like bapi_mlgnx,
      z_salesdata            like bapi_mvke,
      z_salesdatax           like bapi_mvkex,
      z_return               like bapiret2,
      z_subrc                like sy-subrc,
      z_materiallongtext     like bapi_mltx occurs 0 with header line,
      z_taxclassifications   like bapi_mlan occurs 0 with header line,
      z_materialdescription  like bapi_makt occurs 0 with header line,
      z_unitsofmeasure       like bapi_marm occurs 0 with header line,
      z_unitsofmeasurex      like bapi_marmx occurs 0 with header line,
      z_returnmessages       like bapi_matreturn2 occurs 0 with header line.

data: z_it_trite    type l03b_trite_t,
      z_wa_it_trite like line of z_it_trite,
      z_tanum       like ltak-tanum.

data: lt_wmgrp_msg type standard table of wmgrp_msg,
      ls_wmgrp_msg type wmgrp_msg.

data: z_user_parameters like bapiparam occurs 0 with header line,
      z_user_return     like bapiret2 occurs 0 with header line.

data: lv_menu_stufe type num4.

* Hilfsdaten für Transportauftrags FB's
data: z_ltap_conf type ltap_conf occurs 0 with header line.

* Datadefinitions for new menu control
data: lv_stufe(5) type n,
      lv_stufe_1  type char04,
      lv_stufe_2  type char01,
      lv_stufe_3  type char05,
      lv_index    type sy-index.

types: begin of tt_mde_menu.
        include structure zmde_menu.
types:  text2 type char25.
types: end of tt_mde_menu.

data:  lt_menu           type standard table of tt_mde_menu,
       ls_menu           type tt_mde_menu,
       ls_zmde_menu      type zmde_menu,
       ls_zmde_menu_text type zmde_menu_text.
* screen fields
data: lv_line_1 type tt_mde_menu-text2,
      lv_line_2 type tt_mde_menu-text2,
      lv_line_3 type tt_mde_menu-text2,
      lv_line_4 type tt_mde_menu-text2,
      lv_line_5 type tt_mde_menu-text2,
      lv_line_6 type tt_mde_menu-text2,
      lv_line_7 type tt_mde_menu-text2,
      lv_line_8 type tt_mde_menu-text2.

*MDE Visp -- Enhancement for daily created production orders
data: ls_afpo  type afpo,
      ls_afko  type afko,
      ls_ltak  type ltak,
      lv_error type flag.

*    Felder für Materialklassifizierung
data: lt_bapiret2          type table of bapiret2,
      ls_bapiret2          type bapiret2,
      lv_objectname        type bapi1003_key-object,
      lv_objectkey         type bapi1003_key-object_guid,
      lt_alloclist         type standard table of bapi1003_alloc_list,
      ls_alloclist         type bapi1003_alloc_list,
      lt_allocvalueschar   type standard table of bapi1003_alloc_values_char,
      ls_allocvalueschar   type bapi1003_alloc_values_char,
      lc_mc_lims_substance type klasse_d value 'MC_LIMS_SUBSTANCE',
      lc_mc_halb_4_mde     type klasse_d value 'MC_HALB_4_MDE'.

types: begin of tt_lqua,
         ausw type flag.
        include structure lqua.
types: end of tt_lqua.

data: ls_lein type lein,
      ls_lqua type tt_lqua.
data: lt_lqua type standard table of tt_lqua.

data: lv_akt_line type i,
      lv_index_1  type i,
      lv_index_2  type i,
      lv_index_3  type i,
      lv_tabix    type sytabix,
      lv_max_lqua type sytabix,
      scr_lenum_n type lenum.

data: lv_zustand        type char30,
      lv_zustand_id     type atinn,
      lv_expiry_date_id type atinn,
      lv_expiry_date    type date,
      lv_batch_status   type char15,
      lv_st_text1       type char19,
      lv_st_text2       type char22,
      lc_zustand        type atnam value 'ZUSTAND',
      lc_expiry_date    type atnam value 'AUTO_EXPIRY2',
      lv_wert(8)        type n,
      lv_obj            type objnum,
      lt_auspx          type standard table of ausp,
      ls_auspx          type ausp.

data: lv_werks_n type werks_d,
      lv_lgort_n type lgort_d,
      ls_qals    type qals.

data: lt_bdcdata        type standard table of bdcdata,
      ls_bdcdata        type bdcdata,
      lv_mode           type flag,
      lt_otab           type standard table of bdcmsgcoll,
      ls_otab           type bdcmsgcoll,
      lt_smesg          type table of smesg,
      ls_smesg          type smesg,
      lv_beleg_nr_uml   type mblnr,
      lv_beleg_jahr_uml type mjahr.

data lv_autyp type auftyp.

* data definitons for application log
data: lc_log_active  type flag value 'X',
      ls_s_log       type bal_s_log,
      ls_s_msg       type bal_s_msg,
      lv_log_handle  type balloghndl,
      lc_zmde        type balobj_d value 'ZMDE',
      lc_zmde_zlm1   type balsubobj value 'ZLM1',
      lc_zmde_niacin type balsubobj value 'NIACIN'.

data: lt_log_handle     type bal_t_logh,
      ls_log_handle     type balloghndl,
      ls_zmde_appl_log  type zmde_appl_log,
      lt_new_lognumbers type bal_t_lgnm,
      ls_new_lognumbers type bal_s_lgnm.
