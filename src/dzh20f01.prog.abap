*&---------------------------------------------------------------------*
*&  Include           DZH00F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_EXIDV  text
*----------------------------------------------------------------------*
FORM validation  USING    p_gv_exidv TYPE exidv.

  DATA : lv_check TYPE boolean,
         lv_msgv1 TYPE msgv1,
         lv_msgno TYPE msgno.
  DATA : lv_venum TYPE venum.
  DATA : lv_werks TYPE werks_d.
  DATA : lo_auth_chk TYPE REF TO zcl_auth_check.
*
  DATA :      ls_return TYPE bapiret2.
  CLEAR: lv_check,
         lv_msgno,
         lv_venum,
         lv_msgv1.


*--Check External Handaling unit is not initial.
  IF p_gv_exidv IS NOT INITIAL.
*--Convert HU to internal format
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = p_gv_exidv
      IMPORTING
        output = p_gv_exidv.
  ENDIF.

*--Validate the Physical Handling Unit is valid or not
  SELECT venum
      INTO lv_venum
     FROM vekp
     UP TO 1 ROWS
     WHERE exidv = p_gv_exidv.
  ENDSELECT.
  IF sy-subrc NE 0.

    CLEAR : lv_msgv1.
    lv_msgv1 = p_gv_exidv.
    lv_msgno = gc_msgno1.
*--Show an error message
    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1.

  ELSE.
    PERFORM count_hu USING gv_exidv CHANGING gv_count_vepo
                                              gs_vekp
                                              gt_vepo
                                              gv_nested_pack.

    IF gs_vekp-werks IS NOT INITIAL.
      lv_werks = gs_vekp-werks.
    ELSE.
      READ TABLE gt_vepo INTO DATA(ls_vepo) INDEX 1.
      IF sy-subrc EQ 0.
        lv_werks = ls_vepo-werks.
      ENDIF.
    ENDIF.

  ENDIF.

  IF lv_werks IS NOT INITIAL.
*--check User Authorization check on Plant level.
    CREATE OBJECT lo_auth_chk.
    CALL METHOD lo_auth_chk->auth_check_plant_disp
      EXPORTING
        iv_werks    = lv_werks
        iv_activity = '03'
      RECEIVING
        es_bapiret2 = ls_return.

    IF ls_return IS NOT INITIAL.
      CLEAR : lv_msgv1.
      lv_msgv1 = ls_return-message_v1.
      lv_msgno = ls_return-number.
*--Show an error message for Authorization for User
      PERFORM error_message USING  ls_return-id lv_msgno lv_msgv1.
    ENDIF.


  ENDIF.

ENDFORM.                    " VALIDATION
*&---------------------------------------------------------------------*
*&      Form  ERROR_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GC_MSGID  text
*      -->P_LV_MSGNO  text
*      -->P_LV_MSGV1  text
*----------------------------------------------------------------------*
FORM error_message  USING    p_gc_msgid TYPE msgid
                             p_lv_msgno TYPE msgno
                             p_gv_msgv1 TYPE msgv1.

  DATA      : lv_prevno TYPE sy-dynnr.

  CONSTANTS : lc_msgno1  TYPE msgno  VALUE '003',
              lc_initial TYPE char1 VALUE '0'.

*--Call error message screen with message
*--Set Message id
  SET PARAMETER ID text-016 FIELD p_gc_msgid.
*--Set Message No
  SET PARAMETER ID text-017 FIELD p_lv_msgno.
*--Set Message variable
  SET PARAMETER ID text-018 FIELD p_gv_msgv1.
*--Set Message for screen number call back
  CLEAR : lv_prevno.
  lv_prevno = sy-dynnr.
*--Change if the successful message go back to initial screen
  IF p_lv_msgno = lc_msgno1.
    lv_prevno = lc_initial.
  ENDIF.
  SET PARAMETER ID text-020 FIELD lv_prevno.

*--Call Display message screen
  CALL SCREEN 300.

ENDFORM.                    " ERROR_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  CHECK_HU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_EXIDV  text
*----------------------------------------------------------------------*
FORM check_hu  USING    p_gs_vekp TYPE ts_vekp
               CHANGING p_gv_ind   TYPE boolean.
  DATA : lv_fieldset TYPE zfieldset.
  DATA : lv_werks TYPE werks_d.
  IF p_gs_vekp-werks IS INITIAL.
    READ TABLE gt_vepo INTO DATA(ls_vepo) INDEX 1.
    IF sy-subrc EQ 0.
      lv_werks = ls_vepo-werks.
    ENDIF.
  ELSE.
    lv_werks = p_gs_vekp-werks.
  ENDIF.
  SELECT SINGLE field_set INTO lv_fieldset FROM zlhu_info WHERE werks = lv_werks
                                                            AND  vhart = p_gs_vekp-vhart.

  IF lv_fieldset  =  '1'.
    p_gv_ind = abap_true.
  ELSE.
    p_gv_ind = abap_false.
  ENDIF.
  CLEAR : lv_fieldset.
ENDFORM.                    " CHECK_HU
*&---------------------------------------------------------------------*
*&      Form  COUNT_HU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_EXIDV  text
*      <--P_GV_COUNT_VEPO  text
*----------------------------------------------------------------------*
FORM count_hu  USING    p_gv_exidv TYPE exidv
               CHANGING p_gv_count_vepo TYPE i
                        p_gs_vekp       TYPE ts_vekp
                        p_gt_vepo       TYPE gtt_vepo
                        ev_nested_pack  TYPE char1.

  DATA ls_vepo LIKE LINE OF p_gt_vepo.
  CLEAR ev_nested_pack.
  SELECT venum
          exidv
          vhilm
          vhart
          werks
          vegr1
          brgew
          ntgew
          magew
          tarag
          gewei
          lgnum
          uevel
          zzsublot
          zztruck
          zzqa_status
          zzqareason_code
          zztemp_rec_numb
          zzrep_sample_insi
          zzmts
  INTO p_gs_vekp
   FROM vekp
   UP TO 1 ROWS
  WHERE exidv = p_gv_exidv.

  ENDSELECT.
  IF gs_vekp IS NOT INITIAL.
    SELECT venum
          vepos
          vemng
          vemeh
          matnr
          charg
          werks
          lgort
          sobkz
          unvel
          bestq
      INTO TABLE p_gt_vepo
      FROM vepo
      WHERE venum = gs_vekp-venum
        AND velin IN ( 1, 3 ).
    IF p_gt_vepo IS NOT INITIAL.
      CLEAR p_gv_count_vepo.
      LOOP AT p_gt_vepo INTO DATA(ls_gt_vepo) WHERE unvel IS NOT INITIAL.
        p_gv_count_vepo = p_gv_count_vepo  + 1.
      ENDLOOP.
      IF p_gv_count_vepo = 0.
        p_gv_count_vepo = 1.
      ENDIF.

      IF p_gv_count_vepo EQ 1.
        READ TABLE p_gt_vepo INTO ls_vepo INDEX 1.
        IF sy-subrc EQ 0.
          IF ls_vepo-unvel IS NOT INITIAL.
            ev_nested_pack = abap_true.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.                    " COUNT_HU
*&---------------------------------------------------------------------*
*&      Form  PACK_HU_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_EXIDV  text
*      -->P_GT_VEPO  text
*      -->P_GS_VEKP  text
*----------------------------------------------------------------------*
FORM pack_hu_details  USING    p_gv_exidv TYPE exidv
                               p_gv_vepos TYPE vepos
                               p_gt_vepo  TYPE gtt_vepo
                               p_gs_vekp TYPE ts_vekp.
  DATA : lv_prevno TYPE sy-dynnr.

  gv_exidv4 = gv_exidv.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = gv_exidv4
    IMPORTING
      output = gv_exidv4.

*--Fetching HU details
  LOOP AT p_gt_vepo INTO DATA(ls_vepo) WHERE werks IS NOT INITIAL
                                         AND charg IS NOT INITIAL." INDEX 1." WITH KEY venum = gs_vekp-venum
    gv_material  = ls_vepo-matnr.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = gv_material
      IMPORTING
        output = gv_material.
    gv_batch     = ls_vepo-charg.
    gv_sobkz     = ls_vepo-sobkz.
    gv_quantity  = ls_vepo-vemng.
    gv_uom       = ls_vepo-vemeh.

  ENDLOOP.
  IF p_gs_vekp-zzsublot IS NOT INITIAL.
    gv_sublot = p_gs_vekp-zzsublot.
  ELSE.
    gv_sublot = p_gs_vekp-vegr1.
  ENDIF.
  CLEAR : gv_bestq.
  IF ls_vepo-bestq = 'S'.
    gv_bestq = 'Blocked'(001).
  ENDIF.
  IF ls_vepo-bestq = ' '.
    gv_bestq = 'Available'(002).
  ENDIF.
  IF ls_vepo-bestq = 'Q'.
    gv_bestq = 'Quality'(003).
  ENDIF.
  IF ls_vepo-bestq = 'R'.
    gv_bestq = 'Returns'(004).
  ENDIF.
*--Fetching Material description
  SELECT SINGLE maktx INTO gv_desc2 FROM makt WHERE matnr = ls_vepo-matnr
                                               AND spras = sy-langu.
  IF sy-subrc EQ 0.
    gv_desc1 = gv_desc2+0(20).
    gv_desc  = gv_desc2+20(20).
  ENDIF.
*--Fetching data for batches
  SELECT SINGLE matnr
                charg
                vfdat
                hsdat
           FROM mch1
       INTO  gs_mch1
             WHERE matnr = ls_vepo-matnr
             AND charg = ls_vepo-charg.
  IF gs_mch1 IS NOT INITIAL.
    gv_hsdat    = gs_mch1-hsdat.
    gv_exp     = gs_mch1-vfdat.

  ENDIF.
  " ASAH
  CLEAR : lv_exidv.
  SELECT SINGLE exidv FROM vekp INTO lv_exidv WHERE venum = p_gs_vekp-uevel.
  IF lv_exidv IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = lv_exidv
      IMPORTING
        output = lv_exidv.

    gv_exidv_p = lv_exidv.
  ENDIF.
  " ASAH

  PERFORM get_system_status USING p_gs_vekp-venum.
  CLEAR : lv_prevno.
  lv_prevno = sy-dynnr.

  SET PARAMETER ID text-020 FIELD lv_prevno.
ENDFORM.                    " PACK_HU_DETAILS
*&---------------------------------------------------------------------*
*&      Form  PALLET_HU_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_EXIDV  text
*      -->P_GT_VEPO  text
*      -->P_GS_VEKP  text
*----------------------------------------------------------------------*
FORM pallet_hu_details  USING    p_gv_exidv TYPE exidv
                                 p_gv_vepos TYPE vepos
                                 p_gt_vepo TYPE gtt_vepo
                                 p_gs_vekp TYPE ts_vekp.

  DATA : lv_msgv1            TYPE msgv1,
         lv_vhilm            TYPE vhilm,
         lv_rec              TYPE i,
         lv_highest_level_hu TYPE exidv,
         ls_vepo             TYPE ts_vepo,
         lv_exidv            TYPE exidv,
         lv_venum            TYPE venum,
         lt_header_detail    TYPE TABLE OF vekpvb,
         ls_higherhu         TYPE ts_higherhu.

  DATA : lv_prevno TYPE sy-dynnr.
  CLEAR : lv_msgv1, lv_vhilm, lv_highest_level_hu,
          lv_exidv, lv_venum.

  gv_vhilm = p_gs_vekp-vhilm.
*--Get all Lower level HU's from Higher Level Pallet HU
  CALL FUNCTION 'HU_GET_ONE_HU_DB'
    EXPORTING
      if_hu_number        = p_gv_exidv
      if_all_levels       = abap_true
    IMPORTING
      ef_highest_level_hu = lv_highest_level_hu
      et_hu_header        = lt_header_detail
    EXCEPTIONS
      hu_not_found        = 1
      hu_locked           = 2
      fatal_error         = 3
      OTHERS              = 4.
  IF sy-subrc EQ 0.

    SORT lt_header_detail BY exidv.
*--Remove Header HU number from internal table
    DELETE lt_header_detail WHERE exidv = p_gv_exidv.

    SORT lt_header_detail BY vegr1.
    DESCRIBE TABLE lt_header_detail LINES lv_rec.
    gv_nested = lv_rec.
*   Reading the lower value
    READ TABLE lt_header_detail INTO DATA(ls_header_detail) INDEX 1.
    IF sy-subrc EQ 0.
      gv_vegr1_l = ls_header_detail-vegr1.
    ENDIF.
*   Reading the higher value
    CLEAR : ls_header_detail.
    READ TABLE lt_header_detail INTO ls_header_detail INDEX lv_rec.
    IF sy-subrc EQ 0.
      gv_vegr1_h = ls_header_detail-vegr1.
    ENDIF.
  ENDIF.

  READ TABLE p_gt_vepo INTO ls_vepo INDEX 1.

  IF sy-subrc EQ 0.
*   Reading the material description
    SELECT SINGLE maktx INTO gv_maktx1 FROM makt WHERE matnr = ls_vepo-matnr
                                             AND spras = sy-langu.
  ENDIF.

  gv_tw = p_gs_vekp-brgew.
  gv_lw = p_gs_vekp-ntgew.
  gv_al_lw = p_gs_vekp-magew.
  gv_tawe = p_gs_vekp-tarag.
  gv_tawe = p_gs_vekp-tarag.
  gv_gewei = p_gs_vekp-gewei.

  CLEAR : lv_prevno.
  lv_prevno = sy-dynnr.

  SET PARAMETER ID text-020 FIELD lv_prevno.
ENDFORM.                    " PALLET_HU_DETAILS
*&---------------------------------------------------------------------*
*&      Form  GET_STOR_LOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_EXIDV  text
*      -->P_GT_VEPO  text
*      -->P_GS_VEKP  text
*----------------------------------------------------------------------*
FORM get_stor_loc  USING    p_gv_exidv TYPE exidv
                            p_gv_vepos TYPE vepos
                            p_gt_vepo  TYPE gtt_vepo
                            p_gs_vekp  TYPE ts_vekp.


  DATA : ls_lein TYPE ts_lein.
  DATA : ls_lagp TYPE ts_lagp.
  DATA : lv_exidv TYPE exidv.
  DATA : lv_prevno TYPE sy-dynnr.

  gv_exidv5 = gv_exidv.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = gv_exidv5
    IMPORTING
      output = gv_exidv5.

  READ TABLE p_gt_vepo INTO DATA(ls_vepo) INDEX 1." WITH KEY venum = p_gs_vekp-venum
  "vepos = p_gv_vepos BINARY SEARCH.
  IF sy-subrc EQ 0.
    gv_werks = ls_vepo-werks.
    gv_lgort = ls_vepo-lgort.
  ENDIF.
*--Fetching storage unit header records
*  " Begin of CHange by ASAH on 27/04/2020 for Location details
  """""""""""""""""
  IF gv_ind = abap_true.
    " End of change for Project one ASAH
    SELECT SINGLE exidv FROM vekp INTO lv_exidv WHERE venum = p_gs_vekp-uevel.
    IF sy-subrc EQ 0.
      SELECT SINGLE lenum
                    lgnum
                    letyp
                    lgtyp
                    lgpla
        INTO ls_lein
        FROM   lein
        WHERE lenum = lv_exidv.
    ELSE.
      SELECT SINGLE lenum
                    lgnum
                    letyp
                    lgtyp
                    lgpla
                    INTO ls_lein
                    FROM   lein
                    WHERE lenum = p_gs_vekp-exidv.
    ENDIF.
  ELSE.
    """""""""""""""""
    SELECT SINGLE lenum
            lgnum
            letyp
            lgtyp
            lgpla
        INTO ls_lein
        FROM   lein
        WHERE lenum = p_gs_vekp-exidv.
  ENDIF.

  IF sy-subrc EQ 0.
    gv_lgnum = ls_lein-lgnum.
    gv_lgtyp = ls_lein-lgtyp.
    gv_lgpla = ls_lein-lgpla.

*-Fetching storage bins
    SELECT SINGLE lgnum
            lgtyp
            lgpla
            lgber
      FROM lagp
      INTO ls_lagp
      WHERE lgnum = ls_lein-lgnum
        AND lgtyp = ls_lein-lgtyp
        AND lgpla = ls_lein-lgpla.
    IF sy-subrc EQ 0.
      gv_lgber = ls_lagp-lgber.
    ENDIF.
  ENDIF.

  CLEAR : ls_lagp,ls_lein.

  CLEAR : lv_prevno.
  lv_prevno = sy-dynnr.

  SET PARAMETER ID text-020 FIELD lv_prevno.
ENDFORM.                    " GET_STOR_LOC
*&---------------------------------------------------------------------*
*&      Form  Y_F_HIDE_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0142   text
*----------------------------------------------------------------------*
FORM y_f_hide_field  USING    VALUE(p_0142) TYPE any.
  LOOP AT SCREEN.
    IF screen-name = p_0142.
      screen-active    = '0'.
      screen-invisible = '1'.
      MODIFY SCREEN.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " Y_F_HIDE_FIELD
*&---------------------------------------------------------------------*
*&      Form  Y_F_SHOW_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0158   text
*----------------------------------------------------------------------*
FORM y_f_show_field  USING    VALUE(p_0158) TYPE any.
  LOOP AT SCREEN.
    IF screen-name = p_0158.
      screen-active = '1'.
      MODIFY SCREEN.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " Y_F_SHOW_FIELD
*&---------------------------------------------------------------------*
*&      Form  FILL_HU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_VEPO  text
*----------------------------------------------------------------------*
FORM fill_hu  USING    p_gt_vepo TYPE gtt_vepo.

  DATA : lt_lower_hu TYPE STANDARD TABLE OF ts_lower_hu.
  DATA : ls_lower_hu TYPE ts_lower_hu.
  DATA : lt_totquan TYPE STANDARD TABLE OF ts_totquan.
  DATA : ls_totquan TYPE  ts_totquan.
  DATA : lv_total   TYPE vepo-vemng.
  CLEAR : gt_multiple_hu.

  DATA :  ls_vepo TYPE ts_vepo.
*--Filling the global table if there are multiple records
  CLEAR : gv_vemng,
          gv_count.
  IF p_gt_vepo IS NOT INITIAL.
    SELECT venum
           exidv
      INTO TABLE lt_lower_hu
      FROM   vekp
      FOR ALL ENTRIES IN p_gt_vepo
      WHERE venum = p_gt_vepo-unvel.

    SELECT venum
            vemng
      FROM vepo
      INTO TABLE lt_totquan
      FOR ALL ENTRIES IN p_gt_vepo
      WHERE venum = p_gt_vepo-unvel.
    IF sy-subrc EQ 0.

      LOOP AT lt_totquan INTO ls_totquan.
        lv_total =  lv_total + ls_totquan-vemng.
      ENDLOOP.
    ENDIF.

    gv_vemng = lv_total.

  ENDIF.
  CLEAR : gs_multi, gv_idx.
  LOOP AT p_gt_vepo INTO ls_vepo.
    gs_multi-ch1 = ' '.
    READ TABLE lt_lower_hu INTO ls_lower_hu WITH KEY venum = ls_vepo-unvel.
    IF sy-subrc EQ 0.
      gs_multi-exidv = ls_lower_hu-exidv.
    ENDIF.
    gs_multi-venum = ls_vepo-venum.
    gs_multi-vepos = ls_vepo-vepos.

    APPEND gs_multi TO gt_multiple_hu.

  ENDLOOP.
  DELETE gt_multiple_hu WHERE exidv IS INITIAL.
  DESCRIBE TABLE gt_multiple_hu[] LINES gv_n2.
  DESCRIBE TABLE gt_multiple_hu[] LINES gv_count.
ENDFORM.                    " FILL_HU
*&---------------------------------------------------------------------*
*&      Form  CHECK_MULTIPLE_HU_SEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_MULTIPLE_HU  text
*      <--P_LV_CHK  text
*----------------------------------------------------------------------*
FORM check_multiple_hu_sel  USING    p_gt_multiple_hu TYPE gtt_multiple_hu
                            CHANGING p_ls_multiple_hu TYPE ts_multiple_hu
                                      p_lv_chk         TYPE boolean.

  DATA : ls_multiple_hu TYPE ts_multiple_hu.
  DATA : lv_count TYPE i.
  CLEAR : lv_count.
  LOOP AT p_gt_multiple_hu INTO ls_multiple_hu WHERE ch1 = abap_true.
    lv_count = lv_count + 1.
  ENDLOOP.
  IF lv_count = 1.
    p_lv_chk = abap_false.
    p_ls_multiple_hu = ls_multiple_hu.
  ELSE.
    p_lv_chk = abap_true.
  ENDIF.


ENDFORM.                    " CHECK_MULTIPLE_HU_SEL
*&---------------------------------------------------------------------*
*&      Form  CHEKBOX_VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_PG_CNT  text
*----------------------------------------------------------------------*
FORM chekbox_validation  CHANGING p_gv_pg_cnt TYPE i.

*--check page count is grater than 1 then decrease count
  IF p_gv_pg_cnt GT 1.
    p_gv_pg_cnt   =   p_gv_pg_cnt - 1.
  ENDIF.

  READ TABLE  gt_multiple_hu  ASSIGNING FIELD-SYMBOL(<ls_multiple_hu>)
    WITH KEY  exidv  =  gv_exidv.
  IF sy-subrc IS INITIAL.
    IF gv_ch1 IS NOT INITIAL.
      <ls_multiple_hu>-ch1 = gc_flag.
    ELSE.
      CLEAR :<ls_multiple_hu>-ch1.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHEKBOX_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  PACK_HU_DETAILS_MULT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_EXIDV  text
*      -->P_LS_MULTI_VENUM  text
*      -->P_LS_MULTI_VEPOS  text
*      -->P_GT_VEPO  text
*      -->P_GS_VEKP  text
*----------------------------------------------------------------------*
FORM pack_hu_details_mult  USING    p_gv_exidv TYPE exidv.

  DATA : lv_venum TYPE venum.
  DATA : lv_vegr1 TYPE vegr1.
  DATA : lv_zzsublot TYPE zl_de_sublot.
  DATA : lv_prevno TYPE sy-dynnr.
  DATA : lt_vepo TYPE STANDARD TABLE OF ts_vepo.
  DATA : lv_ind TYPE boolean.

  gv_exidv4 = p_gv_exidv.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = gv_exidv4
    IMPORTING
      output = gv_exidv4.
  CLEAR : lv_vegr1, lv_venum, lt_vepo, lv_ind.
  SELECT venum
         vegr1
         zzsublot
      INTO ( lv_venum , lv_vegr1 , lv_zzsublot )
     FROM vekp
     UP TO 1 ROWS
     WHERE exidv = p_gv_exidv.
  ENDSELECT.
  IF sy-subrc EQ 0.
*--Fetching HU details
    SELECT venum
          vepos
          vemng
          vemeh
          matnr
          charg
          werks
          lgort
          sobkz
          unvel
          bestq
      INTO TABLE lt_vepo
      FROM vepo
      WHERE venum = lv_venum.
    LOOP AT lt_vepo INTO DATA(ls_vepo) WHERE werks IS NOT INITIAL
                                          AND charg IS NOT INITIAL.
      IF lv_ind = abap_true.
        EXIT.
      ENDIF.
      gv_material  = ls_vepo-matnr.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          input  = gv_material
        IMPORTING
          output = gv_material.
      gv_batch     = ls_vepo-charg.
      gv_sobkz     = ls_vepo-sobkz.
      gv_quantity  = ls_vepo-vemng.
      gv_uom       = ls_vepo-vemeh.

      lv_ind = abap_true.

    ENDLOOP.
    IF lv_zzsublot IS NOT INITIAL.
      gv_sublot = lv_zzsublot.
    ELSE.
      gv_sublot = lv_vegr1.
    ENDIF.
  ENDIF.
  CLEAR : gv_bestq.
  IF ls_vepo-bestq = 'S'.
    gv_bestq = text-001.
  ENDIF.
  IF ls_vepo-bestq = ' '.
    gv_bestq = text-002.
  ENDIF.
  IF ls_vepo-bestq = 'Q'.
    gv_bestq = text-003.
  ENDIF.
  IF ls_vepo-bestq = 'R'.
    gv_bestq = text-004.
  ENDIF.
  CLEAR : gv_desc2.
*--Fetching Material description
  SELECT SINGLE maktx INTO gv_desc2 FROM makt WHERE matnr = ls_vepo-matnr
                                               AND spras = sy-langu.
  IF sy-subrc EQ 0.
    gv_desc1 = gv_desc2+0(20).
    gv_desc  = gv_desc2+20(20).
  ENDIF.

  "ASAH
  CLEAR : lv_exidv.
  IF gv_exidv IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = gv_exidv
      IMPORTING
        output = lv_exidv.
    gv_exidv_p = lv_exidv.
  ENDIF.
  "ASAH

*--Fetching data for batches
  SELECT SINGLE matnr
                charg
                vfdat
                hsdat
           FROM mch1
       INTO  gs_mch1
             WHERE matnr = ls_vepo-matnr
             AND charg = ls_vepo-charg.
  IF gs_mch1 IS NOT INITIAL.
    gv_hsdat    = gs_mch1-hsdat.
    gv_exp     = gs_mch1-vfdat.

  ENDIF.
  PERFORM get_system_status USING lv_venum.
  CLEAR : lv_prevno.
  lv_prevno = sy-dynnr.

  SET PARAMETER ID text-020 FIELD lv_prevno.

ENDFORM.                    " PACK_HU_DETAILS_MULT
*&---------------------------------------------------------------------*
*&      Form  GET_STOR_LOC_MULT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_MULTI_EXIDV  text
*----------------------------------------------------------------------*
FORM get_stor_loc_mult  USING    p_ls_multi_exidv TYPE exidv
                                 p_gs_vekp_exidv  TYPE exidv.


  DATA : ls_lein TYPE ts_lein.
  DATA : ls_lagp TYPE ts_lagp.
  DATA : lv_exidv TYPE exidv.
  DATA : lv_prevno TYPE sy-dynnr.
  DATA : lv_ind TYPE boolean.



  DATA : lv_venum TYPE venum.
  DATA : lv_vegr1 TYPE vegr1.
  DATA : lt_vepo TYPE STANDARD TABLE OF ts_vepo.

  CLEAR : gv_exidv5 .
  gv_exidv5 = p_ls_multi_exidv.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = gv_exidv5
    IMPORTING
      output = gv_exidv5.
  CLEAR : lv_vegr1, lv_venum, lt_vepo , lv_ind.
  SELECT venum

      INTO lv_venum
     FROM vekp
     UP TO 1 ROWS
     WHERE exidv = p_ls_multi_exidv.
  ENDSELECT.
  IF sy-subrc EQ 0.
*--Fetching HU details
    SELECT venum
          vepos
          vemng
          vemeh
          matnr
          charg
          werks
          lgort
          sobkz
          unvel
      INTO TABLE lt_vepo
      FROM vepo
      WHERE venum = lv_venum.
    LOOP AT lt_vepo INTO DATA(ls_vepo) WHERE werks IS NOT INITIAL
                                       AND charg IS NOT INITIAL.
      IF lv_ind = abap_true.
        EXIT.
      ENDIF.

      gv_werks = ls_vepo-werks.
      gv_lgort = ls_vepo-lgort.
    ENDLOOP.
*--Fetching storage unit header records

    SELECT SINGLE lenum
                  lgnum
                  letyp
                  lgtyp
                  lgpla
      INTO ls_lein
      FROM   lein
      WHERE lenum = gs_vekp-exidv.


    IF sy-subrc EQ 0.
      gv_lgnum = ls_lein-lgnum.
      gv_lgtyp = ls_lein-lgtyp.
      gv_lgpla = ls_lein-lgpla.

*-Fetching storage bins
      SELECT SINGLE lgnum
              lgtyp
              lgpla
              lgber
        FROM lagp
        INTO ls_lagp
        WHERE lgnum = ls_lein-lgnum
          AND lgtyp = ls_lein-lgtyp
          AND lgpla = ls_lein-lgpla.
      IF sy-subrc EQ 0.
        gv_lgber = ls_lagp-lgber.
      ENDIF.
    ENDIF.
  ENDIF.
  CLEAR : ls_lagp,ls_lein.

  CLEAR : lv_prevno.
  lv_prevno = sy-dynnr.

  SET PARAMETER ID text-020 FIELD lv_prevno.


ENDFORM.                    " GET_STOR_LOC_MULT
*&---------------------------------------------------------------------*
*&      Form  GET_SYSTEM_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_VENUM  text
*----------------------------------------------------------------------*
FORM get_system_status  USING    p_lv_venum TYPE venum.

  DATA : lv_objnr TYPE j_objnr.
  DATA : lv_stat TYPE	j_status.
  DATA : lt_hustat TYPE STANDARD TABLE OF	ts_hustat.
  DATA : lt_tj02t TYPE STANDARD TABLE OF  ts_tj02t.
  DATA : lt_tj30t TYPE STANDARD TABLE OF  ts_tj30t.
  DATA : ls_tj02t TYPE 	ts_tj02t.
  DATA : ls_tj30t TYPE 	ts_tj30t.
  DATA : ls_hustat TYPE ts_hustat.
  DATA : lv_txt04 TYPE  j_txt04.
  DATA : lv_txt30 TYPE  j_txt30.
  DATA : lt_hustat_i TYPE STANDARD TABLE OF ts_hustat_i.
  DATA : lt_hustat_e TYPE STANDARD TABLE OF ts_hustat_e.
  DATA : ls_hustat_i TYPE  ts_hustat_i.
  DATA : ls_hustat_e TYPE  ts_hustat_e.
  CONCATENATE 'HU' p_lv_venum INTO lv_objnr.

  CLEAR : gv_syst_stat, lv_stat.

  SELECT objnr stat inact INTO TABLE lt_hustat FROM husstat  WHERE objnr = lv_objnr
                                                        AND  inact = ' '.
  IF sy-subrc EQ 0.
    LOOP AT lt_hustat INTO ls_hustat.
      CLEAR : ls_hustat_i, ls_hustat_e.
      IF ls_hustat-stat+0(1) = 'I'.
        ls_hustat_i-istat = ls_hustat-stat.
        APPEND ls_hustat_i TO lt_hustat_i.
      ELSEIF ls_hustat-stat+0(1) = 'E'.
        ls_hustat_e-estat = ls_hustat-stat.
        APPEND ls_hustat_e TO lt_hustat_e.
      ENDIF.

    ENDLOOP.
    IF lt_hustat_i IS NOT INITIAL.
      SORT lt_hustat_i BY istat.
      DELETE ADJACENT DUPLICATES FROM lt_hustat_i COMPARING istat.
      SELECT istat
            spras
            txt04
            txt30 INTO TABLE lt_tj02t
  FROM tj02t
        FOR ALL ENTRIES IN lt_hustat_i
         WHERE istat = lt_hustat_i-istat
  AND spras = sy-langu.
      CLEAR : gv_syst_stat.
      LOOP AT lt_tj02t INTO ls_tj02t.
        CONCATENATE gv_syst_stat ls_tj02t-txt04 INTO gv_syst_stat SEPARATED BY space.
      ENDLOOP.

    ENDIF.

    IF lt_hustat_e IS NOT INITIAL.
      SORT lt_hustat_e BY estat.
      DELETE ADJACENT DUPLICATES FROM lt_hustat_e COMPARING estat.
      SELECT stsma
            estat
             spras
              txt04
txt30 INTO TABLE lt_tj30t
  FROM tj30t
        FOR ALL ENTRIES IN lt_hustat_e
         WHERE stsma = 'ZHUSER'
        AND estat = lt_hustat_e-estat
  AND spras = sy-langu.
      CLEAR : gv_user_stat.
      LOOP AT lt_tj30t INTO ls_tj30t.
        CONCATENATE gv_user_stat ls_tj30t-txt04 INTO gv_user_stat SEPARATED BY space.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_SYSTEM_STATUS
*&---------------------------------------------------------------------*
*&      Form  GET_ADDITION_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_addition_fields .
  gv_exidv6 = gv_exidv.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = gv_exidv6
    IMPORTING
      output = gv_exidv6.
  gv_truck = gs_vekp-zztruck.
  gv_qa_stat = gs_vekp-zzqa_status.
  gv_qa_reasn = gs_vekp-zzqareason_code.
  gv_temp_rec = gs_vekp-zztemp_rec_numb+0(20).
  gv_temp_rec1 = gs_vekp-zztemp_rec_numb+20(10).
  IF gs_vekp-zzrep_sample_insi = 'X'.
    gv_rep_sam = 'Yes'.
  ELSE.
    gv_rep_sam = 'No'.
  ENDIF.

  IF gs_vekp-zzmts = 'X'.
    gv_mts = 'Yes'.
  ELSE.
    gv_mts = 'No'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_ADDITIONAL_FIELDS_MULT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_MULTI_EXIDV  text
*----------------------------------------------------------------------*
FORM get_additional_fields_mult  USING     p_ls_multi_exidv TYPE exidv.
  DATA : lv_rep_sample TYPE zl_de_rep_sample_ins.
  DATA : lv_temp_rec TYPE zl_de_temp_rec_numb.
  DATA : lv_mts TYPE zl_de_mts.

  CLEAR : gv_exidv6.
  gv_exidv6 = p_ls_multi_exidv.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = gv_exidv6
    IMPORTING
      output = gv_exidv6.

  SELECT zztruck
         zzqa_status
         zzqareason_code
         zzrep_sample_insi
         zztemp_rec_numb
         zzmts

       INTO (gv_truck , gv_qa_stat , gv_qa_reasn , lv_temp_rec , lv_rep_sample , lv_mts)
      FROM vekp
      UP TO 1 ROWS
      WHERE exidv = p_ls_multi_exidv.
  ENDSELECT.
  IF lv_temp_rec IS NOT INITIAL.

    gv_temp_rec = lv_temp_rec+0(20).
    gv_temp_rec1 = lv_temp_rec+20(10).

  ENDIF.
  CLEAR : gv_rep_sam.
  IF lv_rep_sample = 'X'.
    gv_rep_sam  = 'Yes'.
  ELSE.
    gv_rep_sam  = 'No'.
  ENDIF.

  CLEAR : gv_mts.
  IF lv_mts = 'X'.
    gv_mts  = 'Yes'.
  ELSE.
    gv_mts  = 'No'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INITIALIZE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initialize .
  CLEAR : gv_werks, gv_lgort,gv_lgnum ,gv_lgtyp,  gv_lgpla,gv_lgber ,gv_lgpla,
          gv_exidv,gv_vemng,gv_count,gv_exidv5,
          gv_exidv6,gv_truck,gv_qa_stat,gv_qa_reasn,
          gv_temp_rec,gv_temp_rec1,gv_rep_sam,
          gv_mts,gv_vhilm,gv_maktx1,gv_nested,
          gv_vegr1_l,gv_vegr1_h,gv_tw,gv_lw,
          gv_al_lw,gv_tawe,gv_gewei,gv_exidv_p,
          gv_exidv4,gv_material,gv_desc1,
          gv_batch,gv_sublot,gv_bestq,gv_sobkz,gv_hsdat,
          gv_exp,gv_quantity,gv_uom,
          gv_syst_stat.

ENDFORM.
