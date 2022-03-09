FUNCTION zl_restrict_to_sto_type.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_MATNR) TYPE  MATNR OPTIONAL
*"     REFERENCE(I_LGNUM) TYPE  LGNUM OPTIONAL
*"     REFERENCE(I_BESTQ) TYPE  BESTQ OPTIONAL
*"     REFERENCE(I_LGTYP) TYPE  LGTYP OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_MSG) TYPE  CHAR100
*"----------------------------------------------------------------------
************************************************************************
* Program ID:                   ZL_RESTRICT_TO_STO_TYPE
* Program Title:                Restrict the TO creation based on storage types
* Created By:                   Nagaraju Polisetty
* Creation Date:                13.MAR.2019
* Capsugel / Lonza RICEFW ID:   E0099
* Description:                  This fm will do the validation againest the
*                               storage type and restrict the creation of TO
*                               by giving the error message
* Tcode     :                   N/A
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 13.MAR.19    NPOLISETTY      1          D10K9A3CB8  /  Initial version
* 01.APR.19    NPOLISETTY      1          D10K9A3HAH / Open item #617
*&---------------------------------------------------------------------*

  TABLES: tvarvc.

  DATA: lt_tvarvc TYPE TABLE OF tvarvc,
        ls_t334t  TYPE t334t,
        lv_matnr  TYPE matnr,
        lv_ltkze  TYPE mlgn_ltkze,
        lv_des    TYPE lvs_ltypt.

  RANGES: lr_name FOR tvarvc-name,
          lr_lgnum FOR lqua-lgnum,
          lr_lgtyp FOR lqua-lgtyp.

*-- Fill the range table
  lr_name-sign   = 'I'.
  lr_name-option = 'EQ'.
  lr_name-low    = 'WH_STORAGE_TYPE_CHECK'.
  APPEND lr_name.

  lr_name-low = 'WH_STORAGE_TYPE_ENH_FLAG'.
  APPEND lr_name.
  CLEAR: lr_name.

*-- Fetch the TVARVC entries
  SELECT * FROM tvarvc
           INTO TABLE lt_tvarvc
           WHERE name IN lr_name.

*-- Warehouse numbers to be allowed for this enhancemnt
  LOOP AT lt_tvarvc INTO DATA(ls_tvarvc) WHERE name = 'WH_STORAGE_TYPE_CHECK'.
    lr_lgnum-sign = 'I'.
    lr_lgnum-option = 'EQ'.
    lr_lgnum-low = ls_tvarvc-low.
    APPEND lr_lgnum.
    CLEAR: lr_lgnum.
  ENDLOOP.

*-- Flag to trigger the enahncement
  READ TABLE lt_tvarvc INTO ls_tvarvc WITH KEY name = 'WH_STORAGE_TYPE_ENH_FLAG'.
  IF sy-subrc = 0.
    DATA(lv_flag) = abap_true.
  ENDIF.
******** If the TVARVC flag is 'X' and the warehouse should be maintained in TVARVC **********
  IF lv_flag = abap_true AND i_lgnum IN lr_lgnum.
*-- Convert the material to internal format
    DATA(lv_len) = strlen( i_matnr ).
    IF lv_len LT 18.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          input        = i_matnr
        IMPORTING
          output       = lv_matnr
        EXCEPTIONS
          length_error = 1
          OTHERS       = 2.
      IF sy-subrc <> 0.
      ENDIF.
    ELSE.
      lv_matnr = i_matnr.
    ENDIF.

*-- Fetch the Stock placement from MLGN
    SELECT SINGLE ltkze
            FROM mlgn
            INTO lv_ltkze
            WHERE matnr = lv_matnr
              AND lgnum = i_lgnum.
    IF sy-subrc = 0 and lv_ltkze is NOT INITIAL.
*-- Fetch the Storage types for the storage types to be allowed for the validations
      SELECT SINGLE *
              FROM t334t
              INTO ls_t334t
              WHERE lgnum = i_lgnum
                AND kzear = 'E'
                AND lgtkz = lv_ltkze
                AND bestq = i_bestq.
      IF sy-subrc = 0.

      ENDIF.

*-- Fetch the description for the storage type
      SELECT SINGLE ltypt
              FROM t301t
              INTO lv_des
              WHERE spras = sy-langu
                AND lgnum = i_lgnum
                AND lgtyp = i_lgtyp.
      IF sy-subrc = 0.
      ENDIF.
    ELSE.  " MLGN table check
*-- Validation is not required if we do not have the entry in MLGN table
      RETURN.
    ENDIF.

***** If the storage type is not in the table T334T or not starts with '9' then raise the error message
    IF ( i_lgtyp = ls_t334t-lgty0 OR i_lgtyp = ls_t334t-lgty1 OR i_lgtyp = ls_t334t-lgty2 OR i_lgtyp = ls_t334t-lgty3 OR
         i_lgtyp = ls_t334t-lgty4 OR i_lgtyp = ls_t334t-lgty5 OR i_lgtyp = ls_t334t-lgty6 OR i_lgtyp = ls_t334t-lgty7 OR
         i_lgtyp = ls_t334t-lgty8 OR i_lgtyp = ls_t334t-lgty9 ) OR ( i_lgtyp+0(1) = '9' ).
*-- Success Do nothing so that the system will allow to create the Transfer order
    ELSE.
      MESSAGE e509(zits) WITH i_matnr i_lgtyp lv_des INTO e_msg.
    ENDIF.
  ELSE.   "TVARVC flag
    EXIT.
  ENDIF.
  CLEAR: lv_flag, lr_name[], lr_name, lr_lgnum, lr_lgnum[].
ENDFUNCTION.
