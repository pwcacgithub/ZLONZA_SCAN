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

  CONSTANTS : lc_msgno6  TYPE msgno VALUE '006',
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
*--Change if successful message go back to initial screen/leave program
  IF p_lv_msgno = lc_msgno6.
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
FORM validate_lowerhu  USING  p_gs_hu TYPE zcl_rfscanner_packunpack=>ts_phu
                              p_gv_exidv TYPE exidv.

  DATA : lv_msgv1            TYPE msgv1,
         lv_vhilm            TYPE vhilm,
         lv_highest_level_hu TYPE exidv,
         lv_exidv            TYPE exidv,
         lv_venum            TYPE venum,
         lv_matnr            TYPE matnr,
         ls_final            TYPE ts_final,
         lt_header_detail    TYPE TABLE OF vekpvb.

  CONSTANTS :  lc_msgno1  TYPE msgno VALUE '001',
               lc_msgno2  TYPE msgno VALUE '015',
               lc_msgno3  TYPE msgno VALUE '005',
               lc_msgno52 TYPE msgno VALUE '052'.

  CLEAR : lv_msgv1, lv_vhilm, lv_highest_level_hu,
          lv_exidv, lv_venum, lv_matnr.
*--Conver HU with leading Zero's
  PERFORM convert_huto_internal USING p_gv_exidv
                                CHANGING lv_exidv.

  IF p_gv_exidv IS NOT INITIAL.

*--Get Lower level HU's from Higher Level HU
    CALL FUNCTION 'HU_GET_ONE_HU_DB'
      EXPORTING
        if_hu_number        = p_gs_hu-exidv
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
*     Implement handling here
      SORT lt_header_detail BY exidv.
*--Remove Header HU number from internal table
      DELETE lt_header_detail WHERE exidv = gs_hu-exidv.
    ENDIF.
  ENDIF.
*--Vlaidate enter HU is valid or not and
*--Packed Material not initial from VEKP table
  SELECT venum exidv vhilm FROM vekp UP TO 1 ROWS
           INTO (lv_venum, gv_exidv, lv_vhilm)
           WHERE exidv EQ lv_exidv.
  ENDSELECT.
  IF sy-subrc EQ 0 AND lv_exidv IS NOT INITIAL.
*--Begin of changes added by skotturu
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
    IF sy-subrc EQ 0 AND lv_matnr IS NOT INITIAL AND lv_exidv IS NOT INITIAL.
*--Check Enter Lower Level HU is respective Higher Level HU or not?
      READ TABLE lt_header_detail ASSIGNING
                       FIELD-SYMBOL(<lfs_header_detail>)
                       WITH KEY exidv = lv_exidv.
      IF sy-subrc EQ 0 AND lv_exidv IS NOT INITIAL.
        IF gv_exidv1 IS INITIAL AND lv_exidv IS NOT INITIAL.
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
          CLEAR : ls_final.
*--End of changes

        ELSEIF gv_exidv2 IS INITIAL AND lv_exidv IS NOT INITIAL.
*--Second lower level HU
*--Begin of changes added by skotturu
          IF gv_ch2 IS NOT INITIAL.
            ls_final-checkbox = gc_flag.
          ENDIF.
          ls_final-vhilm    = lv_vhilm.
*--Conver HU with leading Zero's
          PERFORM convert_huto_internal USING lv_exidv
                                     CHANGING ls_final-exidv.
          APPEND ls_final TO gt_final.
          CLEAR : ls_final.
*--End of changes

        ELSEIF gv_exidv3 IS INITIAL AND lv_exidv IS NOT INITIAL.
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
          CLEAR : ls_final.
*--End of changes
        ENDIF.
        CLEAR : lv_vhilm.

      ELSE.  " Lower level No not in Higher HU
        CLEAR :  lv_msgv1.
        lv_msgv1 = lv_exidv.
*--Show an error message if HU is not valid
        PERFORM error_message USING gc_msgid
                                    lc_msgno3
                                    lv_msgv1.
      ENDIF.

    ELSE.
      IF GV_RPACKMAT IS INITIAL.
        SELECT SINGLE VALUE1
                 FROM ZVV_PARAM
                 INTO @DATA(LV_PACKMAT)
                WHERE  LOOKUP_NAME = @GC_LOOKUP
                  AND  INDICATOR1 = @GC_FLAG.
        IF SY-SUBRC = 0.
          CONDENSE LV_PACKMAT.
          GV_RPACKMAT = LV_PACKMAT.
          CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
            EXPORTING
              INPUT        = GV_RPACKMAT
            IMPORTING
              OUTPUT       = GV_RPACKMAT
            EXCEPTIONS
              LENGTH_ERROR = 1
              OTHERS       = 2.
        ENDIF.
      ENDIF.
      IF LV_VHILM = GV_RPACKMAT. " '000000000005920603'.
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
    lv_msgv1 = lv_exidv.
*--Show an error message if HU is not valid
    PERFORM error_message USING gc_msgid
                                lc_msgno1
                                lv_msgv1.
  ENDIF.
  CLEAR : lv_exidv, gv_exidv, gv_lbarcode." gs_exidv,.

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
FORM pagup_previousscreen .

*--Decrement the index
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
*---Only for Checkbox1
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

*---Only for Checkbox2
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
*---Only for Checkbox3
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
FORM unpack_boxonpalle  TABLES   p_gt_final TYPE tt_final.

  DATA:   ls_header         TYPE bapihuheader,
          lv_headehu        TYPE exidv,
          lv_msgv1          TYPE msgv1,
          lv_flagset        TYPE char1,
          ls_lhu            TYPE bapihuitmunpack,
          lt_return         TYPE TABLE OF bapiret2,
          lv_messageno      TYPE msgnr,
          ls_vekp_upd_cus   TYPE ZL_VEKP_CUST_UPD,
          ls_vekp_upd_cus_x TYPE ZLS_VEKP_CUST_UPD_X.

  CONSTANTS : lc_msgno6   TYPE msgno VALUE '006',
              lc_msgno54  TYPE msgno VALUE '054',
              lc_itemtype TYPE velin VALUE '3',
              lc_s        TYPE char1 VALUE 'S'.

  CLEAR :lv_flagset, lt_return,  lv_headehu.

  SORT p_gt_final[] BY checkbox exidv.
*--Deleting duplicate values from final table
  DELETE ADJACENT DUPLICATES FROM p_gt_final[] COMPARING checkbox exidv.

*--Preparing Higher level HU
  IF gs_hu-exidv IS NOT INITIAL.
    lv_headehu = gs_hu-exidv.
  ENDIF.
*--Preparing Lower level HU's
  LOOP AT p_gt_final ASSIGNING FIELD-SYMBOL(<lfs_final>).

    ls_lhu-hu_item_type = lc_itemtype.

*--Convert with leading zero's
    PERFORM convert_huto_internal USING  <lfs_final>-exidv
                               CHANGING  ls_lhu-unpack_exid.

*--UnPack Lower Level HU's from Higher Level pallet
    CALL FUNCTION 'BAPI_HU_UNPACK'
      EXPORTING
        hukey      = lv_headehu
        itemunpack = ls_lhu
      IMPORTING
        huheader   = ls_header
      TABLES
        return     = lt_return.

    IF lt_return[] IS NOT INITIAL.
      READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<ls_log>)
                            WITH KEY type = lc_s.
      IF sy-subrc EQ 0.
*--Commit if successfully pack
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = gc_flag.
        CLEAR : lt_return, ls_header, lv_flagset.
      ELSE.
        lv_flagset = gc_flag.
      ENDIF.
    ELSE.
      IF lt_return IS INITIAL AND ls_header IS NOT INITIAL.
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
    READ TABLE p_gt_final INTO <lfs_final> WITH KEY VHILM = GV_RPACKMAT.
    IF SY-SUBRC = 0. " Rep Sales HU Unpacked.
      ls_vekp_upd_cus-venum = ls_vekp_upd_cus_x-venum =  GS_HU-venum.
      ls_vekp_upd_cus-exidv = ls_vekp_upd_cus_x-exidv =  GS_HU-exidv.
      ls_vekp_upd_cus-ZZREP_SAMPLE_INSI = ''." Unpacked
      ls_vekp_upd_cus_x-ZZREP_SAMPLE_INSI = 'X'.
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
          ls_vekp_upd_cus-ZZREP_SAMPLE_INSI = ''." Unpacked
          ls_vekp_upd_cus_x-ZZREP_SAMPLE_INSI = 'X'.
          CALL FUNCTION 'ZL_VEKP_CUST_UPD'
            EXPORTING
              IS_VEKP_CUST_UPD   = ls_vekp_upd_cus
              IS_VEKP_CUST_UPD_X = ls_vekp_upd_cus_x
            .
          IF SY-SUBRC <> 0.
* Implement suitable error handling here
          ENDIF.
        endif.
      ENDIF.

    ENDIF.
* END: EICR:603155 SDHANANJAY - Project ONE: HC & DFS Implementation US & MX
    REFRESH : p_gt_final, lt_return.
*--Remove leadering zeros of HU
    PERFORM convert_removezeros USING   lv_headehu "ls_header-hu_exid
                                CHANGING lv_msgv1.

*--Show an successful message once HU is Unpacked
    PERFORM error_message USING gc_msgid
                                lc_msgno6
                                lv_msgv1.
  ELSE.
*--flagset is not initial show an error message
*--Read error message of first index
    IF  lt_return[] IS NOT INITIAL.
      READ TABLE lt_return ASSIGNING <ls_log>
                                     INDEX 1.
      IF sy-subrc EQ 0.
        CLEAR : lv_messageno, lv_msgv1.
        lv_messageno = <ls_log>-number.

*--Show an error message if lt_return values
        PERFORM error_message USING <ls_log>-id
                                    lv_messageno
                                    lv_msgv1.
      ENDIF.
    ELSE.
*--Show an error message if HU is not valid
      PERFORM error_message USING gc_msgid
                                  lc_msgno54
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
FORM unpackbox_pallethu  TABLES p_gt_final TYPE tt_final.


  IF p_gt_final[] IS NOT INITIAL.
**--Prepare final table
*--UnPack box on Pallet
    PERFORM unpack_boxonpalle TABLES p_gt_final.
  ENDIF.

ENDFORM.                    " PACKBOX_PALLETHU
*&---------------------------------------------------------------------*
*&      Form  VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GS_HU  text
*----------------------------------------------------------------------*
FORM validation  CHANGING p_gs_hu TYPE zcl_rfscanner_packunpack=>ts_phu.

  DATA : lv_check  TYPE boolean,
         lv_msgv1  TYPE msgv1,
         lv_msgno  TYPE msgno,
         lo_author TYPE REF TO zcl_auth_check,
         ls_return TYPE bapiret2.

  CONSTANTS : lc_msgno1 TYPE msgno VALUE '001'.


  CLEAR: lv_check, lv_msgno, ls_return.
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
    SELECT SINGLE VALUE1
             FROM ZVV_PARAM
             INTO @DATA(LV_PACKMAT)
            WHERE  LOOKUP_NAME = @GC_LOOKUP
              AND  INDICATOR1 = @GC_FLAG.
    IF SY-SUBRC = 0.
      CONDENSE LV_PACKMAT.
      GV_RPACKMAT = LV_PACKMAT.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          INPUT        = GV_RPACKMAT
        IMPORTING
          OUTPUT       = GV_RPACKMAT
        EXCEPTIONS
          LENGTH_ERROR = 1
          OTHERS       = 2.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

    ENDIF.
    IF NOT GV_RPACKMAT IS INITIAL.
      PERFORM valid_hu_rep CHANGING lv_check p_gs_hu. " Validate for Rep Samples HU
    ENDIF.
  ENDIF.

* BEGIN: EICR:603155 SDHANANJAY - Project ONE: HC & DFS Implementation US & MX
*--Check variable is not empty then show an error message


  IF p_gs_hu-werks IS NOT INITIAL.
*--check User Authorization check on Plant level.
    CALL METHOD lo_author->auth_check_plant
      EXPORTING
        iv_werks    = p_gs_hu-werks
        iv_activity = '02'
      RECEIVING
        es_bapiret2 = ls_return.

    IF ls_return IS NOT INITIAL.
      CLEAR : lv_msgv1,p_gs_hu.
      lv_msgv1 = ls_return-message_v1.
      lv_msgno = ls_return-number.
*--Show an error message for Authorization for User
      PERFORM error_message USING  gc_msgid lv_msgno lv_msgv1.
    ENDIF.
    CLEAR : ls_return.
  ENDIF.

  IF lv_check IS NOT INITIAL.
    CLEAR : lv_msgv1.
    lv_msgv1 = p_gs_hu-exidv.
    lv_msgno = lc_msgno1.
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
*--Remove if selected first check box and HU

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

*--Fetch Carton details if Rep Sample HU is Packed in it
    SELECT venum exidv vhilm werks lgort lgnum UP TO 1 ROWS
           FROM vekp
           INTO ls_vekp
           WHERE exidv = cs_phu-exidv.
    ENDSELECT.
    IF sy-subrc = 0.
      SELECT SINGLE vhilm INTO @data(ls_vhilm) FROM vekp WHERE vhilm = @GV_RPACKMAT and uevel = @ls_vekp-venum.
      IF SY-SUBRC = 0. " and ls_vhilm = '000000000005920603'.
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
  ELSE.
*--show an error message
    ev_check = abap_true.
  ENDIF.
ENDFORM.
