*&---------------------------------------------------------------------*
*&  Include           SAPMZITSE_PICKING_SCAN_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9100 INPUT.

DATA : lo_author TYPE REF TO zcl_auth_check,
       ls_return TYPE bapiret2,
       lv_msgv1  TYPE msgv1,
       lv_msgno  TYPE zzscan_objid. "msgno.

  CLEAR:v_flag,
        v_dummy,
        v_kquit,
        v_tanum_tmp.

  v_code = sy-ucomm.

  CASE v_code.
    WHEN 'OKAY'.
      IF zsits_scan_pick-tanum IS INITIAL.
*Because it is the first step in the tcode and in this time we don't have
*TO number, so we don't need to log the error message
        MESSAGE e038(zlone_hu) INTO v_dummy.
        CALL METHOD zcl_its_utility=>message_display( ).
      ELSE.
        v_tanum_tmp = zsits_scan_pick-tanum.
        PERFORM convert_to_number_input CHANGING v_tanum_tmp.
*Check whether the TO is exist
        SELECT SINGLE kquit
        FROM ltak
        INTO v_kquit
        WHERE lgnum = wa_user_profile-zzlgnum
        AND   tanum = v_tanum_tmp.
        IF sy-subrc <> 0.
          v_flag = abap_true.
          MESSAGE e039(zlone_hu) INTO v_dummy.
          PERFORM add_message USING zcl_its_utility=>gc_objid_to
                                    zsits_scan_pick-tanum
                                    abap_true.
        ELSEIF v_kquit = abap_true.
*Check whether the TO has been confirmed or cancelled
          v_flag = abap_true.
          MESSAGE e040(zlone_hu) INTO v_dummy.
          PERFORM add_message USING zcl_its_utility=>gc_objid_to
                                    zsits_scan_pick-tanum
                                    abap_true.
*Fetch TO data
        ELSE.
          SELECT tanum  ##too_many_itab_fields
                 tapos
                 werks     " added by skotturu
                 pquit
                 nsola
                 altme
                 vlenr
          FROM ltap
          INTO TABLE it_ltap
          WHERE lgnum = wa_user_profile-zzlgnum
          AND   tanum = v_tanum_tmp.
          IF sy-subrc = 0.
*--Begin of changes by skotturu
*--Check Authorization on plant for TO

*--create class object for Authorizations
       CREATE OBJECT lo_author.
       CLEAR : lv_msgv1, ls_return, lv_msgno.
*--check User Authorization check on Plant level.
          CALL METHOD lo_author->auth_check_lgnum
            EXPORTING
              iv_lgnum    = wa_user_profile-zzlgnum
            RECEIVING
              es_bapiret2 = ls_return.

         IF ls_return IS NOT INITIAL.
           lv_msgv1 = ls_return-message_v1.
           lv_msgno = ls_return-number.
*--Show an error message for Authorization for User
           v_flag = abap_true.
           MESSAGE id ls_return-id TYPE ls_return-type NUMBER ls_return-number
           INTO v_dummy WITH ls_return-message_v1.
           PERFORM add_message USING lv_msgno
                                     lv_msgv1
                                     abap_true.
        ENDIF.
*--End of changes by skotturu

            LOOP AT it_ltap TRANSPORTING NO FIELDS WHERE pquit <> abap_true.
              zsits_scan_pick-quantity = zsits_scan_pick-quantity + 1.
            ENDLOOP.
            IF sy-subrc <> 0.
              v_flag = abap_true.
              MESSAGE e041(zlone_hu) INTO v_dummy.
              PERFORM add_message USING zcl_its_utility=>gc_objid_to
                                        zsits_scan_pick-tanum
                                        abap_true.
            ENDIF.
          ELSE.
            v_flag = abap_true.
            MESSAGE e041(zlone_hu) INTO v_dummy.
            PERFORM add_message USING zcl_its_utility=>gc_objid_to
                                      zsits_scan_pick-tanum
                                      abap_true.
          ENDIF.
        ENDIF.
      ENDIF.

      IF v_flag = abap_false.
        LEAVE TO SCREEN 9200.
      ELSE.
        CLEAR:zsits_scan_pick-tanum.
      ENDIF.
    WHEN 'BACK' OR 'F3'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_9100  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'DISPLAY_SU'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9200 INPUT.

DATA : ls_final TYPE ty_su_number. "ts_final."       TYPE REF TO zcl_rfscanner_packunpack.

  REFRESH:it_label_type.

  CLEAR:v_lenum_output,
        v_lenum_input,
        wa_ltap_conf,
        wa_ltap_conf_hu,
        v_flag,
        v_dummy,
        zsits_scan_pick-message,
        wa_label_type,
        v_label_type,
        wa_label_content,
        wa_material_data,
        wa_su_number.

  v_code = sy-ucomm.

  CASE v_code.
    WHEN 'OKAY'.
*Check whether the SU number is initial
      IF zsits_scan_pick-zzbarcode IS INITIAL.
        v_flag = abap_true.
        MESSAGE e042(zlone_hu) INTO v_dummy.
        PERFORM add_message USING zcl_its_utility=>gc_objid_to
                                  zsits_scan_pick-tanum
                                  abap_true.
      ELSE.
*--Begin of changes by skotturu
*        Logic to split the barcode
*--End of changes by skotturu

        wa_label_type-sign   = 'I'.
        wa_label_type-zoption = 'EQ'.
        wa_label_type-low    = zcl_its_utility=>gc_label_hu.    "Handling Unit Label
        APPEND wa_label_type TO it_label_type.

*--Read the Barcode value
        CALL METHOD zcl_mde_barcode=>disolve_barcode
          EXPORTING
            iv_barcode           = v_barcode
            iv_werks             = ' '
            it_label_type_range  = it_label_type
          IMPORTING
            ev_label_type        = v_label_type
            es_label_content     = wa_label_content
            es_material_data     = wa_material_data.


        IF wa_label_content-ZZHU_EXID IS INITIAL.
          v_flag = abap_true.
          MESSAGE e043(zlone_hu) INTO v_dummy.
          PERFORM add_message USING zcl_its_utility=>gc_objid_to
                                    zsits_scan_pick-tanum
                                    abap_true.
          CLEAR:zsits_scan_pick-zzbarcode.
        ELSE.
          v_lenum_input  = wa_label_content-ZZHU_EXID.
          PERFORM convert_su_number_input CHANGING v_lenum_input.
          v_lenum_output = wa_label_content-ZZHU_EXID.
          PERFORM convert_su_number_output CHANGING v_lenum_output.
        ENDIF.

        CHECK v_flag = abap_false.

*Read the TO data
        READ TABLE it_ltap ASSIGNING <s_ltap> WITH KEY vlenr = v_lenum_input.
        IF sy-subrc <> 0.
          v_flag = abap_true.
          MESSAGE e044(zlone_hu) INTO v_dummy.
          PERFORM add_message USING zcl_its_utility=>gc_objid_to
                                    zsits_scan_pick-tanum
                                    abap_true.
        ELSEIF <s_ltap>-pquit = abap_true.
          v_flag = abap_true.
          MESSAGE e045(zlone_hu) INTO v_dummy.
          PERFORM add_message USING zcl_its_utility=>gc_objid_to
                                    zsits_scan_pick-tanum
                                    abap_true.
        ELSEIF <s_ltap>-flag = abap_true.
          v_flag = abap_true.
          MESSAGE e046(zlone_hu) INTO v_dummy.
          PERFORM add_message USING zcl_its_utility=>gc_objid_to
                                    zsits_scan_pick-tanum
                                    abap_true.
        ELSE.
          wa_ltap_conf-tanum = v_tanum_tmp.
          wa_ltap_conf-tapos = <s_ltap>-tapos.
          wa_ltap_conf-squit = abap_true.
          APPEND wa_ltap_conf TO it_ltap_conf.

          wa_ltap_conf_hu-tanum = v_tanum_tmp.
          wa_ltap_conf_hu-tapos = <s_ltap>-tapos.
          wa_ltap_conf_hu-huent = abap_true.
          wa_ltap_conf_hu-vonhu = v_lenum_input.
          wa_ltap_conf_hu-nachu = v_lenum_input.
          wa_ltap_conf_hu-menga = <s_ltap>-nsola.
          wa_ltap_conf_hu-altme = <s_ltap>-altme.
          APPEND wa_ltap_conf_hu TO it_ltap_conf_hu.

          wa_su_number-lenum = <s_ltap>-vlenr.
          PERFORM convert_su_number_output CHANGING wa_su_number-lenum.
          APPEND wa_su_number TO it_su_number.

          zsits_scan_pick-quantity = zsits_scan_pick-quantity - 1.
          <s_ltap>-flag = abap_true.

        ENDIF.
      ENDIF.

      CLEAR:zsits_scan_pick-zzbarcode.
    WHEN 'PROC'.
*Confirm the transfer order
      IF it_ltap_conf[] IS NOT INITIAL.
        v_tanum = zsits_scan_pick-tanum.
        PERFORM convert_to_number_input CHANGING v_tanum.
        PERFORM confirm_transfer_order USING    wa_user_profile-zzlgnum
                                                v_tanum
                                                it_ltap_conf
                                                it_ltap_conf_hu
                                       CHANGING v_flag.
        IF v_flag = abap_true.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          PERFORM add_message USING zcl_its_utility=>gc_objid_to
                                    zsits_scan_pick-tanum
                                    abap_true.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = abap_true.

          v_clear = abap_true.
          MESSAGE s047(zlone_hu) INTO v_dummy.
          PERFORM add_message USING zcl_its_utility=>gc_objid_to
                                    zsits_scan_pick-tanum
                                    abap_false.
          zsits_scan_pick-message = v_dummy.
          LEAVE TO SCREEN 9100.
        ENDIF.
      ELSE.
        v_flag = abap_true.
        MESSAGE e036(zitsus) INTO v_dummy.
        PERFORM add_message USING zcl_its_utility=>gc_objid_to
                                  zsits_scan_pick-tanum
                                  abap_true.
      ENDIF.
    WHEN 'BACK' OR 'F3'.
      v_clear = abap_true.
      LEAVE TO SCREEN 9100.

*--Page Up
    WHEN gc_pgup.
*--Decrement the counter
       gv_index = gv_index - 1.

*--Page Down
    WHEN gc_pgdn.
*--Increment the counter
     gv_index = gv_index + 1.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_9200  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOWER_HU  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE lower_hu INPUT.
*--Begin of changes by skotturu
DATA : lo_hu       TYPE REF TO zcl_rfscanner_packunpack.

*--Read the HU number enter one is with Prefix or not
*--If not prefix of HU number then add Prefix with below code
*--Create Class Object for validation
          CREATE OBJECT lo_hu.
          CALL METHOD lo_hu->hubarcode_value
            EXPORTING
             iv_exidv    = zsits_scan_pick-zzbarcode
           IMPORTING
             ev_hunumber = v_barcode.
*--End of changes by skotturu
ENDMODULE.
