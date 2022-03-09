FUNCTION zwm_hu_validate.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_BARCODE) TYPE  STRING OPTIONAL
*"     REFERENCE(IT_LABEL_TYPE_RANGE) TYPE  ZTLABEL_TYPE_RANGE OPTIONAL
*"  EXPORTING
*"     REFERENCE(EV_EXIDV) TYPE  EXIDV
*"     REFERENCE(ES_RETURN) TYPE  BAPIRET2
*"     REFERENCE(EV_BARCODE) TYPE  STRING
*"     REFERENCE(ES_LABEL_CONTENT) TYPE  ZSITS_LABEL_CONTENT
*"----------------------------------------------------------------------
  TYPES : BEGIN OF lty_exidv,
            exidv TYPE exidv,
          END OF lty_exidv.

  DATA : lv_barcode_string TYPE string,
         lv_barcode        TYPE string,
         lt_return         TYPE ztits_barcode_return,
         v_label_type      TYPE zdits_label_type,
         ls_label_content  TYPE zsits_label_content,
         lv_exidv          TYPE exidv,
         lv_exidv1         TYPE exidv,
         lt_exidv          TYPE STANDARD TABLE OF lty_exidv,
         lv_prefix         TYPE t313daityp,
         lv_count          TYPE i.

  CLEAR: ev_exidv, es_return, ev_barcode, es_label_content.

  IF iv_barcode IS NOT INITIAL.
    lv_barcode_string = iv_barcode.

    CONDENSE lv_barcode_string NO-GAPS.

    SELECT SINGLE prefix
      FROM t313g
      INTO lv_prefix
      WHERE aityp EQ 'GS1'.
    IF sy-subrc EQ 0 AND  lv_barcode_string(3) <> lv_prefix.
      CONCATENATE lv_prefix '240' lv_barcode_string INTO lv_barcode_string.
    ENDIF.

    CALL METHOD zcl_mde_barcode=>disolve_barcode
      EXPORTING
        iv_barcode          = lv_barcode_string
        iv_werks            = ' '
        it_label_type_range = it_label_type_range
      IMPORTING
        es_label_content    = ls_label_content.

    IF sy-subrc = 0.

      lv_exidv = ls_label_content-zzhu_exid.

      IF lv_exidv IS NOT INITIAL. "IF HU found in Barcode String
*      es_label_content = ls_label_content.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_exidv
          IMPORTING
            output = lv_exidv.
        SELECT exidv " check in VEKP
          UP TO 1 ROWS
          FROM vekp
          INTO lv_exidv1
          WHERE exidv = lv_exidv.
        ENDSELECT.
        IF sy-subrc <> 0.

          SELECT exidv
          FROM vekp
          INTO TABLE lt_exidv
          WHERE zzold_hu = lv_barcode_string.
          IF lt_exidv IS NOT INITIAL. " If barcode string is old barcode
            DESCRIBE TABLE lt_exidv LINES lv_count.
            IF lv_count = 1. " If there is only one entry, proceed with the HU.
              READ TABLE lt_exidv INTO DATA(lwa_exidv) INDEX 1.
              IF sy-subrc = 0.
                es_return-type = 'S'.
                ev_exidv = lwa_exidv-exidv.

                CLEAR lv_barcode_string.
                CONCATENATE lv_prefix '240' ev_exidv INTO lv_barcode_string.
                "get ls_label_content
                CALL METHOD zcl_mde_barcode=>disolve_barcode
                  EXPORTING
                    iv_barcode          = lv_barcode_string
                    iv_werks            = ' '
                    it_label_type_range = it_label_type_range
                  IMPORTING
                    es_label_content    = ls_label_content.

              ENDIF.
            ELSEIF lv_count > 1 . " “More than one HU found with the same barcode string”.
              es_return-type = 'E'.
              es_return-id = 'ZLONE_HU'.
              es_return-number = '249'.
              es_return-message_v1 = lv_barcode_string.
            ENDIF.
          ELSE.  "Not a valid barcode string, give error message “HU XXXXX does not exist
*        ERROR MESSAGE
            es_return-type = 'E'.
            es_return-id = 'ZLONE_HU'.
            es_return-number = '072'.
            es_return-message_v1 = lv_barcode_string.
          ENDIF.
*        ENDIF.
        ELSE. " Valid HU
          es_return-type = 'S'.
          ev_exidv = lv_exidv.
        ENDIF.
      ELSE. " HU not found in barcode string.

        """""""
        SELECT exidv
           FROM vekp
           INTO TABLE lt_exidv
           WHERE zzold_hu = lv_barcode_string.
        IF lt_exidv IS NOT INITIAL. " If barcode string is old barcode
          DESCRIBE TABLE lt_exidv LINES lv_count.
          IF lv_count = 1. " If there is only one entry, proceed with the HU.
            READ TABLE lt_exidv INTO lwa_exidv INDEX 1.
            IF sy-subrc = 0.
              es_return-type = 'S'.
              ev_exidv = lwa_exidv-exidv.
              CLEAR lv_barcode_string.
              CONCATENATE lv_prefix '240' ev_exidv INTO lv_barcode_string.
              "get ls_label_content
              CALL METHOD zcl_mde_barcode=>disolve_barcode
                EXPORTING
                  iv_barcode          = lv_barcode_string
                  iv_werks            = ' '
                  it_label_type_range = it_label_type_range
                IMPORTING
                  es_label_content    = ls_label_content.
            ENDIF.
          ELSEIF lv_count > 1 . " “More than one HU found with the same barcode string”.
            es_return-type = 'E'.
            es_return-id = 'ZLONE_HU'.
            es_return-number = '249'.
            es_return-message_v1 = lv_barcode_string.

          ENDIF.
          """"""""
        ELSE.  "Not a valid barcode string, give error message “HU XXXXX does not exist
*        error message
          es_return-type = 'E'.
          es_return-id = 'ZLONE_HU'.
          es_return-number = '072'.
          es_return-message_v1 = lv_barcode_string.
        ENDIF.
      ENDIF.

    ELSE. " If it's not a barcode string, it is exidv

    ENDIF.
    es_label_content = ls_label_content.
    ev_barcode = lv_barcode_string.
  ENDIF.
ENDFUNCTION.
