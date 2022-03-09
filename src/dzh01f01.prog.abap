*&---------------------------------------------------------------------*
*&  Include           DZH01F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ERROR_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GC_MSGID  text
*      -->P_GC_MSGNO1  text
*      -->P_GV_MSGV1  text
*----------------------------------------------------------------------*
FORM error_message  USING    p_gc_msgid TYPE msgid
                             p_lv_msgno TYPE msgno
                             p_gv_msgv1 TYPE msgv1.

  DATA      : lv_prevno TYPE sy-dynnr.

  CONSTANTS : lc_msgno1  TYPE msgno  VALUE '003',
              lc_initial TYPE char1  VALUE '0'.

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
*&      Form  VALIDATE_LOWERHU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_EXIDV  text
*----------------------------------------------------------------------*
FORM validate_lowerhu  USING  p_gv_exidv TYPE exidv.

  DATA : lv_msgv1 TYPE msgv1,
         lv_vhilm TYPE vhilm,
         lv_exidv TYPE exidv,
         lv_venum TYPE venum,
         lv_matnr TYPE matnr,
         ls_final TYPE ts_final.

  CONSTANTS : lc_msgno2  TYPE msgno VALUE '015',
              lc_msgno52 TYPE msgno VALUE '052',
              LC_LOOKUP  TYPE ZLOOKUP_NAME VALUE 'ZV_REPSALES'.

  CLEAR : lv_msgv1, lv_vhilm, lv_exidv, lv_venum, lv_matnr.
*--Conver HU with leading Zero's
  PERFORM convert_huto_internal USING p_gv_exidv
                                CHANGING lv_exidv.

*--Vlaidate enter HU is valid or not and
*--Packed Material not initial from VEKP table
  SELECT venum exidv vhilm FROM vekp UP TO 1 ROWS
           INTO (lv_venum, gv_exidv, lv_vhilm)
           WHERE exidv EQ lv_exidv.
  ENDSELECT.
  IF sy-subrc EQ 0.
*--Begin of changes added by skotturu new desgin
    IF gv_exidv3 IS NOT INITIAL.
      CLEAR : gv_exidv1, gv_ch1, gv_ch2, gv_ch3, gv_vhilm3,
              gv_exidv2, gv_exidv3, gv_vhilm1, gv_vhilm2.
    ENDIF.
*--Check duplicate record or not
    READ TABLE gt_final TRANSPORTING NO FIELDS WITH KEY exidv = gv_exidv.
    IF sy-subrc EQ 0.
*--Show an error message if HU is already exist
      lv_msgv1 = gv_exidv.
      PERFORM error_message USING gc_msgid
                                  lc_msgno52
                                  lv_msgv1.
    ENDIF.
*--End changes added by skotturu

*--Get Material Number from Item data
    SELECT SINGLE matnr FROM vepo
           INTO lv_matnr
           WHERE venum EQ lv_venum.
    IF sy-subrc EQ 0 AND lv_matnr IS NOT INITIAL.
      IF gv_exidv1 IS INITIAL AND p_gv_exidv IS NOT INITIAL. " added
*--First lower level HU
*--Begin of changes added by skotturu
        IF gv_ch1 IS NOT INITIAL.
          ls_final-checkbox = gc_flag.
        ENDIF.
        ls_final-vhilm    = lv_vhilm.
*--Conver HU with leading Zero's
        PERFORM convert_huto_internal USING lv_exidv
                                   CHANGING ls_final-exidv.
        APPEND ls_final TO gt_final.
*--End of changes

      ELSEIF gv_exidv2 IS INITIAL.
**--Second lower level HU
*--Begin of changes added by skotturu
        IF gv_ch2 IS NOT INITIAL.
          ls_final-checkbox = gc_flag.
        ENDIF.
        ls_final-vhilm    = lv_vhilm.
*--Conver HU with leading Zero's GV_EXIDV2
        PERFORM convert_huto_internal USING lv_exidv
                                   CHANGING ls_final-exidv.
        APPEND ls_final TO gt_final.
*--End of changes

      ELSEIF gv_exidv3 IS INITIAL.
*--Third lower level HU convert
*--Begin of changes added by skotturu
        IF gv_ch3 IS NOT INITIAL.
          ls_final-checkbox = gc_flag.
        ENDIF.
        ls_final-vhilm    = lv_vhilm.
*--Conver HU with leading Zero's
        PERFORM convert_huto_internal USING lv_exidv
                                   CHANGING ls_final-exidv.
        APPEND ls_final TO gt_final.

*--End of changes
      ENDIF.
      CLEAR : lv_vhilm.
    ELSE.
      SELECT SINGLE VALUE1 FROM ZVV_PARAM INTO @DATA(LV_RSAL) WHERE LOOKUP_NAME = @LC_LOOKUP AND INDICATOR1 = @ABAP_TRUE.
      IF SY-SUBRC = 0.
        CONDENSE LV_RSAL.
        GV_RMATNR = LV_RSAL.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            INPUT        = GV_RMATNR
          IMPORTING
            OUTPUT       = GV_RMATNR
          EXCEPTIONS
            LENGTH_ERROR = 1
            OTHERS       = 2.
      ENDIF.
      IF LV_VHILM = GV_RMATNR. " '000000000005920603'.
        LS_FINAL-EXIDV = LV_EXIDV.
        LS_FINAL-VHILM = LV_VHILM.
        APPEND LS_FINAL TO GT_FINAL.
        CLEAR LS_FINAL.
      ELSE.
        CLEAR :  lv_msgv1.
        lv_msgv1 = gv_exidv.
*--Show an error message if HU is not valid
*--Material Doesn't exist for HU
        PERFORM error_message USING gc_msgid
                                    lc_msgno2
                                    lv_msgv1.
      ENDIF.
    ENDIF. " vepo
  ELSE.
    CLEAR :  lv_msgv1.
    lv_msgv1 = gv_exidv.
*--Show an error message if HU is not valid
    PERFORM error_message USING gc_msgid
                                gc_msgno1
                                lv_msgv1.
  ENDIF. " VEKP
  CLEAR : lv_exidv,gv_exidv, gv_lbarcode, ls_final.

ENDFORM.                    " VALIDATE_LOWERHU
*&---------------------------------------------------------------------*
*&      Form  CONVERT_HUTO_INTERNAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_GV_EXIDV  text
*----------------------------------------------------------------------*
FORM convert_huto_internal  USING p_gv_exidv      TYPE exidv
                            CHANGING  p_gv_exidv1 TYPE exidv.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_gv_exidv
    IMPORTING
      output = p_gv_exidv1.
ENDFORM.                    " CONVERT_HUTO_INTERNAL
*&---------------------------------------------------------------------*
*&      Form  CONVERT_REMOVEZEROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_GV_EXIDV  text
*      <--P_GV_EXIDV1  text
*----------------------------------------------------------------------*
FORM convert_removezeros  USING    p_gv_exidv TYPE exidv
                          CHANGING p_gv_exidv1.
*--convert : remove leading zero's
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = p_gv_exidv
    IMPORTING
      output = p_gv_exidv1.

ENDFORM.                    " CONVERT_REMOVEZEROS
*&---------------------------------------------------------------------*
*&      Form  NEXT_SCREEN_PAGEDOWN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_PG_CNT  text
*----------------------------------------------------------------------*
FORM next_screen_pagedown.

*--Increment the counter
  gv_index = gv_index + 1.

ENDFORM.                    " NEXT_SCREEN_PAGEDOWN
*&---------------------------------------------------------------------*
*&      Form  PAGUP_PREVIOUSSCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_PG_CNT  text
*----------------------------------------------------------------------*
FORM pagup_previousscreen.

*--Decrement the counter
  gv_index = gv_index - 1.

ENDFORM.                    " PAGUP_PREVIOUSSCREEN
*&---------------------------------------------------------------------*
*&      Form  CHEKBOX_VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_PG_CNT  text
*----------------------------------------------------------------------*
FORM chekbox_validation.

*--Check box validation
  DATA : lv_exidv TYPE exidv.

*---Only for First Checkbox1
  IF sy-ucomm EQ gc_ch1.
    IF gv_exidv1 IS INITIAL.
      CLEAR gv_ch1.
    ENDIF.

    CLEAR : lv_exidv.
*--Conver HU with leading Zero's
    PERFORM convert_huto_internal USING gv_exidv1
                               CHANGING lv_exidv.

    READ TABLE gt_final ASSIGNING FIELD-SYMBOL(<lfs_final>)
                     WITH KEY exidv = lv_exidv.
    IF sy-subrc EQ 0.
      IF gv_ch1 IS NOT INITIAL.
        <lfs_final>-checkbox = abap_true.
      ELSE.
        <lfs_final>-checkbox = abap_false.
      ENDIF.
    ENDIF.
  ENDIF.

*---Only for Second Checkbox2
  IF sy-ucomm EQ gc_ch2.
    IF gv_exidv2 IS INITIAL.
      CLEAR gv_ch2.
    ENDIF.
    CLEAR : lv_exidv.
*--Conver HU with leading Zero's
    PERFORM convert_huto_internal USING gv_exidv2
                               CHANGING lv_exidv.

    READ TABLE gt_final ASSIGNING <lfs_final>
                     WITH KEY exidv = lv_exidv.
    IF sy-subrc EQ 0.
      IF gv_ch2 IS NOT INITIAL.
        <lfs_final>-checkbox = abap_true.
      ELSE.
        <lfs_final>-checkbox = abap_false.
      ENDIF.
    ENDIF.
  ENDIF.
*---Only for Third Checkbox3
  IF sy-ucomm EQ gc_ch3.
    IF gv_exidv2 IS INITIAL.
      CLEAR gv_ch3.
    ENDIF.
    CLEAR :lv_exidv.
*--Conver HU with leading Zero's
    PERFORM convert_huto_internal USING gv_exidv3
                               CHANGING lv_exidv.

    READ TABLE gt_final ASSIGNING <lfs_final>
                     WITH KEY exidv = lv_exidv.
    IF sy-subrc EQ 0.
      IF gv_ch3 IS NOT INITIAL.
        <lfs_final>-checkbox = abap_true.
      ELSE.
        <lfs_final>-checkbox = abap_false.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHEKBOX_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  PACK_BOXONPALLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FINAL  text
*----------------------------------------------------------------------*
FORM pack_boxonpalle  TABLES   p_gt_final TYPE tt_final.

  DATA:   ls_header         TYPE bapihuheader,
          lv_headehu        TYPE exidv,
          lv_msgv1          TYPE msgv1,
          lv_flagset        TYPE char1,
          ls_lhu            TYPE bapihuitmproposal,
          lt_return         TYPE TABLE OF bapiret2,
          lv_messageno      TYPE msgnr,
          ls_vekp_upd_cus   TYPE ZL_VEKP_CUST_UPD,
          ls_vekp_upd_cus_x TYPE ZLS_VEKP_CUST_UPD_X.

  CONSTANTS : lc_msgno1   TYPE msgno VALUE '003',
              lc_msgno53  TYPE msgno VALUE '053',
              lc_itemtype TYPE velin VALUE '3',
              lc_s        TYPE char1 VALUE 'S'.

  CLEAR :lv_flagset, lt_return,  lv_headehu, ls_header.

*--Preparing Higher level HU
  IF gs_hu-exidv IS NOT INITIAL.
    lv_headehu = gs_hu-exidv.
  ENDIF.

*--Deleting duplicate values from final table
  DELETE ADJACENT DUPLICATES FROM p_gt_final COMPARING checkbox exidv.

***  BEGIN: EICR:603155 - Project ONE: HC & DFS Implementation US/MX - ATHOMAS3
** Requirement : Multiple HU entered (in 2nd screen 200) for Packing
** And in that few cartons may have already been packed in other HUs/Pallents.
** For those items (already packed) currently the program stops and doesn't allow to pack to continue for good ones.
** Requirement now is to allow the ones that can be packed to be packed to pallet
** And also to show a error message (screen 300) for the ones that are already packed and cannot be packed here.
**

** Find HU that are already packed & mark error flag for them
** Build a internal table with errored HU (already packed) to show error in Error Message screen(300)

  TYPES: BEGIN OF ts_wh,
           lgnum TYPE lgnum,  " Warehouse
         END OF ts_wh.

  DATA: ls_vv_param TYPE zvv_param,
        lt_wh       tYPE TABLE OF ts_wh,
        ws_wh       TYPE ts_wh.


  CONSTANTS: lc_lookup   TYPE zlookup_name 	VALUE 'ZLPACK_WH', " 'ZLPACK_PLANTS', " ZVV_PARAM Lookup Name
             lc_free_key TYPE zfree_key VALUE 'LGNUM', " 'WERKS',
             lc_true     TYPE zindicator VALUE 'X'.

* ZVV_PARAM - Plants for which this logic should work (US/MX plants)
  CLEAR ls_vv_param.
  SELECT SINGLE *
           FROM zvv_param
           INTO ls_vv_param
          WHERE lookup_name = lc_lookup
            AND free_key = lc_free_key
            AND indicator1 = abap_true.
  IF NOT ls_vv_param-value1 IS INITIAL.
    refresh lt_wh.
    SPLIT ls_vv_param-value1 AT ',' INTO TABLE lt_wh. "lt_plant.
  ENDIF.
  CLEAR gv_flg_huerr.

*    READ TABLE lt_plant INTO ws_plant WITH KEY werks = gs_hu-werks.
  READ TABLE lt_wh INTO ws_wh WITH KEY lgnum = gs_hu-lgnum.
  IF sy-subrc = 0.
    gv_flg_huerr = abap_true.

    DESCRIBE TABLE p_gt_final LINES DATA(lv_tothu).
    REFRESH gt_huerr.
    CLEAR gv_success.
    LOOP AT p_gt_final ASSIGNING FIELD-SYMBOL(<lfs_final1>).
      SELECT SINGLE uevel FROM vekp INTO @DATA(lv_uevel)
                          WHERE exidv = @<lfs_final1>-exidv.
      IF sy-subrc EQ 0 AND lv_uevel IS NOT INITIAL.
        <lfs_final1>-errflg = abap_true.  " Mark the HU with error flag - to show that it is already packed elsewhere
        APPEND <lfs_final1> TO gt_huerr.
      ENDIF.
    ENDLOOP.
    DESCRIBE TABLE gt_huerr LINES DATA(lv_toterr).

** Check if all lines items are in error, if yes clear 1st line to process to pack (&to show error with that)
    IF lv_tothu = lv_toterr.
      READ TABLE p_gt_final ASSIGNING <lfs_final1> INDEX 1.
      IF sy-subrc EQ 0.
        <lfs_final1>-errflg = abap_false.
      ENDIF.
    ENDIF.
  ENDIF.

***  END: EICR:603155 - Project ONE: HC & DFS Implementation US/MX - ATHOMAS3


***  BEGIN: EICR:603155 - Project ONE: HC & DFS Implementation US/MX - ATHOMAS3
*--Preparing Lower level HU's
  LOOP AT p_gt_final ASSIGNING FIELD-SYMBOL(<lfs_final>) WHERE errflg IS INITIAL.
***  END: EICR:603155 - Project ONE: HC & DFS Implementation US/MX - ATHOMAS3

    ls_lhu-hu_item_type = lc_itemtype.
*--Begin of changes by skotturu
*--Convert with leading zero's
    PERFORM convert_huto_internal USING  <lfs_final>-exidv
                               CHANGING  ls_lhu-lower_level_exid.
*--End of chagnes by skotturu

*--Pack Lower Level HU's to Higher Level
    CALL FUNCTION 'BAPI_HU_PACK'
      EXPORTING
        hukey        = lv_headehu
        itemproposal = ls_lhu
      IMPORTING
        huheader     = ls_header
      TABLES
        return       = lt_return.

    IF lt_return[] IS NOT INITIAL.
      READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<ls_log>)
                            WITH KEY type = lc_s.
      IF sy-subrc EQ 0.
*--Commit if successfully pack
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = gc_flag.
        CLEAR : lt_return, ls_header.
***  BEGIN: EICR:603155 - Project ONE: HC & DFS Implementation US/MX - ATHOMAS3
        gv_success = gc_flag.
***  END: EICR:603155 - Project ONE: HC & DFS Implementation US/MX - ATHOMAS3
      ELSE.
        lv_flagset = gc_flag.
      ENDIF.
    ELSE.
      IF lt_return[] IS INITIAL AND ls_header IS NOT INITIAL.
*--Commit if successfully pack
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = gc_flag.
        CLEAR : lt_return, ls_header, lv_flagset.
      ELSE.
        lv_flagset = gc_flag.
        lv_msgv1 = ls_header-hu_exid.
      ENDIF.
    ENDIF.
    CLEAR : ls_header.
  ENDLOOP.

*--Check if flagset is not initial then show an error message
*--else show successful message with Higher HU number
  IF lv_flagset IS INITIAL.
* BEGIN: EICR:603155 SDHANANJAY - Project ONE: HC & DFS Implementation US & MX
** If Rep Sample HU is Unpacked, then change the status of ZZREP_SAMPLE_INSI to blank
    READ TABLE p_gt_final INTO <lfs_final> WITH KEY VHILM = GV_RMATNR.
    IF SY-SUBRC = 0. " Rep Sales HU Unpacked.
      ls_vekp_upd_cus-venum = ls_vekp_upd_cus_x-venum =  GS_HU-venum.
      ls_vekp_upd_cus-exidv = ls_vekp_upd_cus_x-exidv =  GS_HU-exidv.
      ls_vekp_upd_cus-ZZREP_SAMPLE_INSI = abap_true." Rep Mat inside packed
      ls_vekp_upd_cus_x-ZZREP_SAMPLE_INSI = abap_true.
      CALL FUNCTION 'ZL_VEKP_CUST_UPD'
        EXPORTING
          IS_VEKP_CUST_UPD   = ls_vekp_upd_cus
          IS_VEKP_CUST_UPD_X = ls_vekp_upd_cus_x
        .
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.
      SELECT SINGLE UEVEL FROM VEKP INTO @DATA(LV_PALHU) WHERE VENUM = @GS_HU-VENUM.
      IF SY-SUBRC = 0. " It is a Carton, Update the Pallet HU also.
        CLEAR: ls_vekp_upd_cus, ls_vekp_upd_cus_x.
        SELECT SINGLE VENUM EXIDV FROM VEKP INTO (ls_vekp_upd_cus_x-venum,ls_vekp_upd_cus_x-exidv)  WHERE VENUM = LV_PALHU.
        if sy-subrc = 0.
          ls_vekp_upd_cus-venum = ls_vekp_upd_cus_x-venum.
          ls_vekp_upd_cus-exidv = ls_vekp_upd_cus_x-exidv.
          ls_vekp_upd_cus-ZZREP_SAMPLE_INSI = abap_true." packed
          ls_vekp_upd_cus_x-ZZREP_SAMPLE_INSI = abap_true.
          CALL FUNCTION 'ZL_VEKP_CUST_UPD'
            EXPORTING
              IS_VEKP_CUST_UPD   = ls_vekp_upd_cus
              IS_VEKP_CUST_UPD_X = ls_vekp_upd_cus_x.
          IF SY-SUBRC <> 0.
* Implement suitable error handling here
          ENDIF.
        endif.
      ENDIF.
    endif.
* END: EICR:603155 SDHANANJAY - Project ONE: HC & DFS Implementation US & MX

    REFRESH : p_gt_final, lt_return.
*--Remove leadering zeros of HU
    PERFORM convert_removezeros USING   lv_headehu
                                CHANGING lv_msgv1.

*--Show an Successful message with HU number
    PERFORM error_message USING gc_msgid
                                lc_msgno1
                                lv_msgv1.
  ELSE.
*--flagset is not initial show an error message
*--Read error message of first index
    IF lt_return[] IS NOT INITIAL.
      READ TABLE lt_return ASSIGNING <ls_log>
                               INDEX 1.
      IF sy-subrc EQ 0.
        CLEAR : lv_messageno, lv_msgv1.
        REFRESH : p_gt_final.
        lv_messageno = <ls_log>-number.

*--Show an error message if HU is not valid
        PERFORM error_message USING <ls_log>-id
                                    lv_messageno
                                    lv_msgv1.
      ENDIF.
    ELSE.
*--Show an error message if HU is not valid
      PERFORM error_message USING gc_msgid
                                  lc_msgno53
                                  lv_msgv1.

    ENDIF.
  ENDIF.
  CLEAR : lv_flagset.
  REFRESH : p_gt_final, lt_return.
ENDFORM.                    " PACK_BOXONPALLE
*&---------------------------------------------------------------------*
*&      Form  PACKBOX_PALLETHU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EXIDV  text
*      -->P_GT_FINAL  text
*----------------------------------------------------------------------*
FORM packbox_pallethu  TABLES p_gt_final TYPE tt_final.

*--Prepare final table
  IF p_gt_final[] IS NOT INITIAL.
*--Pack box on Pallet
    PERFORM pack_boxonpalle TABLES p_gt_final.
  ENDIF.

ENDFORM.                    " PACKBOX_PALLETHU
*&---------------------------------------------------------------------*
*&      Form  VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GS_HU  text
*----------------------------------------------------------------------*
FORM validation  CHANGING p_gs_hu TYPE ts_phu.

  DATA : lv_check  TYPE boolean,
         lv_msgv1  TYPE msgv1,
         lv_msgno  TYPE msgno,
         lo_author TYPE REF TO zcl_auth_check,
         ls_return TYPE bapiret2.

  CLEAR: lv_check, lv_msgno.
*--Create Class Object for validation
  CREATE OBJECT go_hu.

*--create class object for Authorizations
  CREATE OBJECT lo_author.

*--Validate the Physical Handling Unit is valid or not
  CALL METHOD go_hu->validation_nonhu
    IMPORTING
      ev_check = lv_check
    CHANGING
      cs_phu   = p_gs_hu.

* BEGIN: EICR:603155 SDHANANJAY - Project ONE: HC & DFS Implementation US & MX
* Additional Validation for Rep Sales HU packed
  IF NOT lv_check IS INITIAL.
    p_gs_hu = gs_hu.
    PERFORM valid_hu_rep CHANGING lv_check p_gs_hu. " Validate for Rep Samples HU
  ENDIF.

* BEGIN: EICR:603155 SDHANANJAY - Project ONE: HC & DFS Implementation US & MX


  IF p_gs_hu-werks IS NOT INITIAL.
*--check User Authorization check on Plant level.
    CALL METHOD lo_author->auth_check_plant
      EXPORTING
        iv_werks    = p_gs_hu-werks
        iv_activity = '02'
      RECEIVING
        es_bapiret2 = ls_return.

    IF ls_return IS NOT INITIAL.
      CLEAR : lv_msgv1, p_gs_hu.
      lv_msgv1 = ls_return-message_v1.
      lv_msgno = ls_return-number.
*--Show an error message for Authorization for User
      PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1.
    ENDIF.

  ENDIF.

*--Check variable is not empty then show an error message
  IF lv_check IS NOT INITIAL.
    CLEAR : lv_msgv1.
    lv_msgv1 = p_gs_hu-exidv.
    lv_msgno = gc_msgno1.
*--Show an error message
    PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1.
  ENDIF.
ENDFORM.                    " VALIDATION
*&---------------------------------------------------------------------*
*&      Form  REMOVE_SELCTEDENTRY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_EXIDV1  text
*      -->P_GV_EXIDV2  text
*      -->P_GV_EXIDV3  text
*----------------------------------------------------------------------*
FORM remove_selctedentry.

*--Remove if selected check box of HU
  DELETE gt_final WHERE checkbox EQ abap_true.

ENDFORM.                    " REMOVE_SELCTEDENTRY

*&---------------------------------------------------------------------*
*&      Form  VALID_HU_REP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_CHECK  text
*      <--P_P_GS_HU  text
*----------------------------------------------------------------------*
FORM VALID_HU_REP  CHANGING ev_check
                            cs_phu TYPE zcl_rfscanner_packunpack=>ts_phu.
  types:
    BEGIN OF ts_vekp,
      venum TYPE vekp-venum, " Internal Handling Unit Number
      exidv TYPE exidv,      " External Handling Unit Identification
      vhilm TYPE vhilm,      " packing material
      werks TYPE hum_werks, " plant
      lgort TYPE hum_lgort, " stor. loca
      lgnum TYPE hum_lgnum, " whr. no
    END OF ts_vekp ,
    BEGIN OF ts_lein,
      lenum TYPE lenum,
      lgpla TYPE lgpla,     " stor. Bin
    END OF ts_lein ,

    BEGIN OF ts_makt,
      matnr TYPE matnr,
      maktx TYPE maktx,
    END OF ts_makt .

  DATA : ls_vekp             TYPE ts_vekp,
         ls_lein             TYPE ts_lein,
         ls_makt             TYPE ts_makt,
         lv_werks            TYPE werks_d,
         lv_lgort            TYPE lgort_d,
         lv_highest_level_hu TYPE exidv,
         lt_header_detail    TYPE TABLE OF vekpvb.

  CONSTANTS : lc_lang TYPE spras VALUE 'E'.

  CLEAR : ls_vekp, ls_lein, ls_makt, lv_lgort, lv_werks,
          lv_highest_level_hu, ev_check.

  REFRESH : lt_header_detail.

*--Check External Handaling unit is not initial.
  IF cs_phu-exidv IS NOT INITIAL.
*--Convert HU to internal format
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = cs_phu-exidv
      IMPORTING
        output = cs_phu-exidv.

*--Fetch Carton details in which Rep Sales HU to be packed
    SELECT venum exidv vhilm werks lgort lgnum UP TO 1 ROWS
           FROM vekp
           INTO ls_vekp
           WHERE exidv = cs_phu-exidv.
    ENDSELECT.
    IF sy-subrc = 0.

      cs_phu-venum = ls_vekp-venum.
      cs_phu-vhilm = ls_vekp-vhilm.
      cs_phu-lgnum = ls_vekp-lgnum.

*--Get lower level HU's VENUM for get Plant and Storage location values
      CALL FUNCTION 'HU_GET_ONE_HU_DB'
        EXPORTING
          if_hu_number        = ls_vekp-exidv
        IMPORTING
          ef_highest_level_hu = lv_highest_level_hu
          et_hu_header        = lt_header_detail
        EXCEPTIONS
          hu_not_found        = 1
          hu_locked           = 2
          fatal_error         = 3
          OTHERS              = 4.
      IF sy-subrc EQ 0.
*--Implement handling here
        SORT lt_header_detail BY exidv.
*--Remove Header HU number from internal table
        DELETE lt_header_detail WHERE exidv = ls_vekp-exidv.
      ENDIF.

*--Fetch Plant and storage location details from Item table VEPO
      READ TABLE lt_header_detail ASSIGNING FIELD-SYMBOL(<lfs_details>) INDEX 1.
      IF sy-subrc EQ 0.
        SELECT SINGLE werks lgort FROM vepo
                INTO (lv_werks, lv_lgort)
                WHERE venum EQ <lfs_details>-venum.
        IF sy-subrc EQ 0.
          cs_phu-werks = lv_werks.
          cs_phu-lgort = lv_lgort.
        ENDIF.
      ELSE.
*--Get plant & stor.loc from single HU which in
        SELECT SINGLE werks lgort FROM vepo
              INTO (lv_werks, lv_lgort)
              WHERE venum EQ ls_vekp-venum.
        IF sy-subrc EQ 0.
          cs_phu-werks = lv_werks.
          cs_phu-lgort = lv_lgort.
        ENDIF.
      ENDIF.
      REFRESH :lt_header_detail.
*--Fetch Material description based on Packed Materials
      SELECT matnr maktx UP TO 1 ROWS FROM makt
             INTO ls_makt
             WHERE matnr = ls_vekp-vhilm
               AND spras = lc_lang.
      ENDSELECT.
      IF sy-subrc EQ 0.
        cs_phu-maktx = ls_makt-maktx.
        CLEAR : ls_makt.
      ENDIF.

*--Fetch Storage location details
      SELECT lenum lgpla FROM lein UP TO 1 ROWS
             INTO ls_lein
             WHERE lenum = ls_vekp-exidv.
      ENDSELECT.
      IF sy-subrc EQ 0.
        cs_phu-lgpla = ls_lein-lgpla.
        CONDENSE cs_phu-lgpla.
        CLEAR : ls_lein.
      ENDIF.

    ELSE.
*--show an error message
      ev_check = abap_true.

    ENDIF.
  ELSE.
*--show an error message
    ev_check = abap_true.
  ENDIF.
ENDFORM.
