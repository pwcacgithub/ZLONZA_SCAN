*----------------------------------------------------------------------*
*   INCLUDE MZLMXF01                                                   *
*----------------------------------------------------------------------*

* Include für Barcode Routinen

*&---------------------------------------------------------------------*
*&      Form  barcode_aufteilen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZZ_AI[]  text
*      -->P_ZZ_BARCODE  text
*----------------------------------------------------------------------*
form barcode_aufteilen tables   p_zz_ai structure zz_ai
                       using    p_zz_barcode
                                p_zz_begrenzer
                                p_zz_fehler.

  types: barcode like zz_matnr_lang.
  field-symbols: <bc> type barcode.

  assign p_zz_barcode to <bc>.

*  shift <bc> left deleting leading space.
  zz_strlen = strlen( <bc> ).
  zz_length = ls_t313g-minle.

  refresh: zz_ai.
  zz_startpos = 1.

  do.
    clear: zz_ai.
*   * Wird erst ab 6.20 verwendet
    zz_ai-ai = <bc>(zz_length).

    select * from t313d into ls_t313d where aityp = ls_t313g-aityp and
                                            aival = zz_ai-ai(zz_length) and
                                            aidef = 'X'.
      exit.
    endselect.

    if sy-subrc eq 0.
*   * Wird erst ab 6.20 verwendet
      zz_ai-length = ls_t313d-ailen.
      zz_ai-data = <bc>+zz_length(zz_ai-length).
      zz_ai-aichk = ls_t313d-aichk.
      zz_ai-fehler = ' '.
      append zz_ai.
      shift <bc> left by zz_length places.
      shift <bc> left by zz_ai-length places.
      zz_length = ls_t313g-minle.
      zz_startpos = 1.
    else.
      if ls_t313g-maxle > zz_length.
        zz_length = zz_length + 1.
      else.
*       * Fehler
        p_zz_fehler = 'X'.
        zz_startpos = 2.
        exit.
      endif.
    endif.

  enddo.

endform.                    " barcode_aufteilen
*&---------------------------------------------------------------------*
*&      Form  check_digit_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZZ_AI_DATA  text
*----------------------------------------------------------------------*
form check_digit_check using p_zz_ai_data
                             p_zz_ai_pruefziffer
                             p_zz_fehler.

  data: lf_ok        type boole_d,
        lf_ai_value(60) type c,
        lf_digit type barcode_aidata.
  constants gc_false(1)         type c value ' '.
  constants gc_true(1)          type c value 'X'.

  call function 'LE_CHECK_DIGIT_CALCULATION'
    exporting
      if_number_wo_check_digit = p_zz_ai_data
      if_calc_method           = 'A'
      if_only_checking         = gc_true
    importing
      ef_number_w_check_digit  = lf_ai_value
      ef_check_digit_ok        = lf_ok
      ef_check_digit           = lf_digit
    exceptions
      invalid_parameter        = 1
      others                   = 2.

  if sy-subrc <> 0 or lf_ok ne 'X'.
    p_zz_fehler = 'P'.
  else.
    p_zz_ai_pruefziffer = lf_digit.
  endif.

endform.                    " check_digit_check
*&---------------------------------------------------------------------*
*&      Form  barcode_in_felder_fuellen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZZ_AI_AI  text
*      -->P_ZZ_AI_LENGTH  text
*      -->P_ZZ_AI_DATA  text
*      <--P_ZZ_MATNR  text
*      <--P_ZZ_CHARG  text
*      <--P_z_mengE  text
*----------------------------------------------------------------------*
form barcode_in_felder_fuellen using    p_zz_ai_ai
                                        p_zz_ai_length
                                        p_zz_ai_data
                               changing p_zz_matnr
                                        p_zz_charg
                                        p_z_menge.

  case p_zz_ai_ai.
    when '93  '.
      p_zz_matnr = p_zz_ai_data(p_zz_ai_length).
      shift p_zz_matnr right deleting trailing space.
      do.
        replace ' ' with '0' into p_zz_matnr.
        if not p_zz_matnr ca ' '.
          exit.
        endif.
      enddo.
    when '10  '.
      p_zz_charg = p_zz_ai_data(p_zz_ai_length).
    when '3100'.
      p_z_menge = p_zz_ai_data(p_zz_ai_length).
      zz_menge_p = p_z_menge.
    when '91  '.
      p_z_menge = p_zz_ai_data(p_zz_ai_length).
      zz_menge_p = p_z_menge.
      zz_menge_p = zz_menge_p / 1000.
      p_z_menge = zz_menge_p.
  endcase.

endform.                    " barcode_in_felder_fuellen
*&---------------------------------------------------------------------*
*&      Form  pruefziffer_gesamter_barcode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form pruefziffer_gesamter_barcode.

  zz_barcode_op = zz_matnr_lang.
  do.
    replace zz_ean128_begrenzer with ' ' into zz_barcode_op.
    if sy-subrc ne 0.
      exit.
    endif.
  enddo.
  condense zz_barcode_op no-gaps.
  perform check_digit_check using zz_barcode_op
                                  zz_pruefziffer
                                  zz_fehler.
  if zz_fehler ne ' '.
    clear ok_code.
    perform show_message using '001' zz_barcode_op(50) zz_barcode_op+50(10) '' ''.
    zz_cursor_feld = 'ZZ_MATNR_LANG'.
    call screen '0999'.
  endif.


endform.                    " pruefziffer_gesamter_barcode

*&---------------------------------------------------------------------*
*&      Form  menge_testen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form menge_testen.

  call function 'CHAR_FLTP_CONVERSION'
    exporting
      string             = zz_menge
    importing
      decim              = zz_decim
      expon              = zz_expon
      flstr              = zz_flstr
      ivalu              = zz_ivalu
    exceptions
      exponent_too_big   = 1
      exponent_too_small = 2
      string_not_fltp    = 3
      too_many_decim     = 4.

  if sy-subrc ne 0.
    clear ok_code.
    perform show_message using '043' '' '' '' ''.
    zz_cursor_feld = 'ZZ_MENGE'.
    call screen '0999'.
  else.
    zz_menge = zz_flstr.
    zz_menge_p = zz_menge.
    write zz_menge_p to zz_menge no-zero no-grouping
                                 no-sign decimals 3.
    if zz_menge ca '*'.
      clear ok_code.
      perform show_message using '044' zz_menge '' '' ''.
      zz_cursor_feld = 'ZZ_MENGE'.
      call screen '0999'.
    endif.
  endif.

endform.                    " menge_testen

*&---------------------------------------------------------------------*
*&      Form  show_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0301   text
*      -->P_ZZ_BARCODE_OP  text
*      -->P_0303   text
*      -->P_0304   text
*      -->P_0305   text
*----------------------------------------------------------------------*
form show_message  using    iv_msgnr type msgnr
                            iv_var1 type any "symsgv
                            iv_var2 type any "symsgv
                            iv_var3 type any "symsgv
                            iv_var4 type any. "symsgv.
  clear: z_t_fehler,
         zz_message1,
         zz_message2,
         zz_message3,
         zz_message4,
         zz_message5,
         zz_message6,
         zz_message7,
         zz_message8.

  message id 'ZMDE' type 'I' number iv_msgnr into z_fehlertext
      with iv_var1 iv_var2 iv_var3 iv_var4.

  call function 'SOTR_SERV_PREPARE_STRING'
    exporting
      text                = z_fehlertext
      flag_no_line_breaks = 'X'
      line_length         = 25
      langu               = sy-langu
    tables
      text_tab            = z_t_fehler.
*   LINE_TAB                  =

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

  lv_error = 'X'.

endform.                    " show_message
*&---------------------------------------------------------------------*
*&      Form  STUFE_SETZEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_STUFE  text
*      -->P_0036   text
*----------------------------------------------------------------------*
form stufe_setzen  using p_stufe
                         p_zeile
                         p_lv_stufe
                         p_art.
  case p_art.
    when '+'.
      lv_stufe_1 = p_stufe.
      lv_stufe_2 = p_zeile.
      concatenate lv_stufe_1 lv_stufe_2 into lv_stufe_3.
      p_lv_stufe = lv_stufe_3.
    when '-'.
      lv_stufe_3 = p_lv_stufe.
      lv_stufe_2 = lv_stufe_3+4(1).
      lv_stufe_1 = lv_stufe(4).
      p_lv_stufe = lv_stufe_1.
  endcase.

endform.                    " STUFE_SETZEN
*&---------------------------------------------------------------------*
*&      Form  HALB_NR_FESTSTELLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form halb_nr_feststellen using p_matnr
                         changing p_halb.

  clear: lt_bapiret2,
         lt_alloclist,
         lt_allocvalueschar.

  lv_objectname = p_matnr.

  call function 'BAPI_OBJCL_GET_KEY_OF_OBJECT'
    exporting
      objectname               = lv_objectname
      objecttable              = 'MARA'
      classtype                = '001'
    importing
      clobjectkeyout           = lv_objectkey
    tables
      return                   = lt_bapiret2.

  call function 'BAPI_OBJCL_GETCLASSES_KEY'
    exporting
      clobjectkeyin         = lv_objectkey
      read_valuations       = 'X'
      keydate               = sy-datum
      language              = sy-langu
    tables
      alloclist             = lt_alloclist
      allocvalueschar       = lt_allocvalueschar
      return                = lt_bapiret2.

  loop at lt_allocvalueschar into ls_allocvalueschar.
    case ls_allocvalueschar-charact.
*      when lc_mc_lims_substance.
      when lc_mc_halb_4_mde.
        p_halb = ls_allocvalueschar-value_neutral.
        exit.
    endcase.
  endloop.

endform.                    " HALB_NR_FESTSTELLEN
*&---------------------------------------------------------------------*
*&      Form  BARCODE_AUFLOESEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZZ_MATNR_LANG  text
*      <--P_ZZ_MATNR  text
*      <--P_ZZ_CHARG  text
*      <--P_ZZ_MENGE  text
*----------------------------------------------------------------------*
form barcode_aufloesen  using    p_matnr_lang
                        changing p_matnr
                                 p_charg
                                 p_menge.

endform.                    " BARCODE_AUFLOESEN
