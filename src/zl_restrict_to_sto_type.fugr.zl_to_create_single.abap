FUNCTION zl_to_create_single.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_LGNUM) LIKE  LTAK-LGNUM
*"     VALUE(I_BWLVS) LIKE  LTAK-BWLVS
*"     VALUE(I_BETYP) LIKE  LTAK-BETYP DEFAULT SPACE
*"     VALUE(I_BENUM) LIKE  LTAK-BENUM DEFAULT SPACE
*"     VALUE(I_MATNR) LIKE  LTAP-MATNR
*"     VALUE(I_WERKS) LIKE  LTAP-WERKS
*"     VALUE(I_LGORT) LIKE  LTAP-LGORT DEFAULT SPACE
*"     VALUE(I_CHARG) LIKE  LTAP-CHARG DEFAULT SPACE
*"     VALUE(I_BESTQ) LIKE  LTAP-BESTQ DEFAULT SPACE
*"     VALUE(I_SOBKZ) LIKE  LTAP-SOBKZ DEFAULT SPACE
*"     VALUE(I_SONUM) LIKE  LTAP-SONUM DEFAULT SPACE
*"     VALUE(I_LETYP) LIKE  LTAP-LETYP DEFAULT SPACE
*"     VALUE(I_ANFME) LIKE  RL03T-ANFME
*"     VALUE(I_ALTME) LIKE  LTAP-ALTME
*"     VALUE(I_WDATU) LIKE  LTAP-WDATU DEFAULT SY-DATUM
*"     VALUE(I_VFDAT) LIKE  LTAP-VFDAT DEFAULT SY-DATUM
*"     VALUE(I_ZEUGN) LIKE  LTAP-ZEUGN DEFAULT SPACE
*"     VALUE(I_LZNUM) LIKE  LTAK-LZNUM DEFAULT SPACE
*"     VALUE(I_SQUIT) LIKE  RL03T-SQUIT DEFAULT SPACE
*"     VALUE(I_NIDRU) LIKE  RL03A-NIDRU DEFAULT SPACE
*"     VALUE(I_DRUKZ) LIKE  T329F-DRUKZ DEFAULT SPACE
*"     VALUE(I_LDEST) LIKE  LTAP-LDEST DEFAULT SPACE
*"     VALUE(I_WEMPF) LIKE  LTAP-WEMPF DEFAULT SPACE
*"     VALUE(I_ABLAD) LIKE  LTAP-ABLAD DEFAULT SPACE
*"     VALUE(I_VLTYP) LIKE  LTAP-VLTYP DEFAULT SPACE
*"     VALUE(I_VLBER) LIKE  LTAP-VLBER DEFAULT SPACE
*"     VALUE(I_VLPLA) LIKE  LTAP-VLPLA DEFAULT SPACE
*"     VALUE(I_VPPOS) LIKE  LTAP-VPPOS DEFAULT SPACE
*"     VALUE(I_VLENR) LIKE  LTAP-VLENR DEFAULT SPACE
*"     VALUE(I_VLQNR) LIKE  LTAP-VLQNR DEFAULT SPACE
*"     VALUE(I_NLTYP) LIKE  LTAP-NLTYP DEFAULT SPACE
*"     VALUE(I_NLBER) LIKE  LTAP-NLBER DEFAULT SPACE
*"     VALUE(I_NLPLA) LIKE  LTAP-NLPLA DEFAULT SPACE
*"     VALUE(I_NPPOS) LIKE  LTAP-NPPOS DEFAULT SPACE
*"     VALUE(I_NLENR) LIKE  LTAP-NLENR DEFAULT SPACE
*"     VALUE(I_NLQNR) LIKE  LTAP-NLQNR DEFAULT SPACE
*"     VALUE(I_RLTYP) LIKE  LTAP-RLTYP DEFAULT SPACE
*"     VALUE(I_RLBER) LIKE  LTAP-RLBER DEFAULT SPACE
*"     VALUE(I_RLPLA) LIKE  LTAP-RLPLA DEFAULT SPACE
*"     VALUE(I_RLQNR) LIKE  LTAP-RLQNR DEFAULT SPACE
*"     VALUE(I_UPDATE_TASK) LIKE  RL03A-VERBU DEFAULT SPACE
*"     VALUE(I_COMMIT_WORK) LIKE  RL03B-COMIT DEFAULT 'X'
*"     VALUE(I_BNAME) LIKE  LTAK-BNAME DEFAULT SY-UNAME
*"     VALUE(I_KOMPL) LIKE  RL03B-KOMPL DEFAULT 'X'
*"     VALUE(I_SOLEX) LIKE  LTAK-SOLEX DEFAULT 0
*"     VALUE(I_PERNR) LIKE  LTAK-PERNR DEFAULT 0
*"     VALUE(I_AUSFB) LIKE  LTAK-AUSFB DEFAULT SPACE
*"     VALUE(I_SGT_SCAT) LIKE  LTAP-SGT_SCAT DEFAULT SPACE
*"  EXPORTING
*"     VALUE(E_TANUM) LIKE  LTAK-TANUM
*"     VALUE(E_LTAP) LIKE  LTAP STRUCTURE  LTAP
*"     VALUE(E_ERRMSG) TYPE  CHAR100
*"  TABLES
*"      T_LTAK STRUCTURE  LTAK_VB OPTIONAL
*"      T_LTAP_VB STRUCTURE  LTAP_VB OPTIONAL
*"  EXCEPTIONS
*"      NO_TO_CREATED
*"      BWLVS_WRONG
*"      BETYP_WRONG
*"      BENUM_MISSING
*"      BETYP_MISSING
*"      FOREIGN_LOCK
*"      VLTYP_WRONG
*"      VLPLA_WRONG
*"      VLTYP_MISSING
*"      NLTYP_WRONG
*"      NLPLA_WRONG
*"      NLTYP_MISSING
*"      RLTYP_WRONG
*"      RLPLA_WRONG
*"      RLTYP_MISSING
*"      SQUIT_FORBIDDEN
*"      MANUAL_TO_FORBIDDEN
*"      LETYP_WRONG
*"      VLPLA_MISSING
*"      NLPLA_MISSING
*"      SOBKZ_WRONG
*"      SOBKZ_MISSING
*"      SONUM_MISSING
*"      BESTQ_WRONG
*"      LGBER_WRONG
*"      XFELD_WRONG
*"      DATE_WRONG
*"      DRUKZ_WRONG
*"      LDEST_WRONG
*"      UPDATE_WITHOUT_COMMIT
*"      NO_AUTHORITY
*"      MATERIAL_NOT_FOUND
*"      LENUM_WRONG
*"----------------------------------------------------------------------
************************************************************************
* Program ID:                   ZINV_MOV_NON_HU
* Program Title:                Transfer order creation
* Created By:                   Nagaraju Polisetty
* Creation Date:                18.MAR.2019
* Capsugel / Lonza RICEFW ID:   E0099
* Description:                  Create a transfer order with one item and with
*                               sto type validation check
* Tcode     :                   N/A
* Additional Information:       This is a wrapper fm for the L_TO_CREATE_SINGLE fm
*                               to add the Storage type check valodation which will
*                               restrict the TO creation  based on some checks..
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
*18.MAR.2019    NPOLISETTY      1         D10K9A3CB8  /  Initial version
*&---------------------------------------------------------------------*

  DATA: lv_msg TYPE char100.

*-- FM to validate whether we can do the TO creation or not
  CALL FUNCTION 'ZL_RESTRICT_TO_STO_TYPE'
    EXPORTING
      i_matnr = i_matnr
      i_lgnum = i_lgnum
      i_bestq = i_bestq
      i_lgtyp = i_nltyp
    IMPORTING
      e_msg   = e_errmsg.

  IF e_errmsg IS NOT INITIAL.
*-- If the valdation fails don't create transfer order
    RETURN.
  ELSE.
*-- Call the standard fm to create the transfer order
    CALL FUNCTION 'L_TO_CREATE_SINGLE'
      EXPORTING
        i_lgnum               = i_lgnum
        i_bwlvs               = i_bwlvs
        i_betyp               = i_betyp
        i_benum               = i_benum
        i_matnr               = i_matnr
        i_werks               = i_werks
        i_lgort               = i_lgort
        i_charg               = i_charg
        i_bestq               = i_bestq
        i_sobkz               = i_sobkz
        i_sonum               = i_sonum
        i_letyp               = i_letyp
        i_anfme               = i_anfme
        i_altme               = i_altme
        i_wdatu               = i_wdatu
        i_vfdat               = i_vfdat
        i_zeugn               = i_zeugn
        i_lznum               = i_lznum
        i_squit               = i_squit
        i_nidru               = i_nidru
        i_drukz               = i_drukz
        i_ldest               = i_ldest
        i_wempf               = i_wempf
        i_ablad               = i_ablad
        i_vltyp               = i_vltyp
        i_vlber               = i_vlber
        i_vlpla               = i_vlpla
        i_vppos               = i_vppos
        i_vlenr               = i_vlenr
        i_vlqnr               = i_vlqnr
        i_nltyp               = i_nltyp
        i_nlber               = i_nlber
        i_nlpla               = i_nlpla
        i_nppos               = i_nppos
        i_nlenr               = i_nlenr
        i_nlqnr               = i_nlqnr
        i_rltyp               = i_rltyp
        i_rlber               = i_rlber
        i_rlpla               = i_rlpla
        i_rlqnr               = i_rlqnr
        i_update_task         = i_update_task
        i_commit_work         = i_commit_work
        i_bname               = i_bname
        i_kompl               = i_kompl
        i_solex               = i_solex
        i_pernr               = i_pernr
        i_ausfb               = i_ausfb
        i_sgt_scat            = i_sgt_scat
      IMPORTING
        e_tanum               = e_tanum
        e_ltap                = e_ltap
      TABLES
        t_ltak                = t_ltak
        t_ltap_vb             = t_ltap_vb
      EXCEPTIONS
        no_to_created         = 1
        bwlvs_wrong           = 2
        betyp_wrong           = 3
        benum_missing         = 4
        betyp_missing         = 5
        foreign_lock          = 6
        vltyp_wrong           = 7
        vlpla_wrong           = 8
        vltyp_missing         = 9
        nltyp_wrong           = 10
        nlpla_wrong           = 11
        nltyp_missing         = 12
        rltyp_wrong           = 13
        rlpla_wrong           = 14
        rltyp_missing         = 15
        squit_forbidden       = 16
        manual_to_forbidden   = 17
        letyp_wrong           = 18
        vlpla_missing         = 19
        nlpla_missing         = 20
        sobkz_wrong           = 21
        sobkz_missing         = 22
        sonum_missing         = 23
        bestq_wrong           = 24
        lgber_wrong           = 25
        xfeld_wrong           = 26
        date_wrong            = 27
        drukz_wrong           = 28
        ldest_wrong           = 29
        update_without_commit = 30
        no_authority          = 31
        material_not_found    = 32
        lenum_wrong           = 33
        OTHERS                = 34.
    IF sy-subrc <> 0.
    ENDIF.
  ENDIF.
ENDFUNCTION.
