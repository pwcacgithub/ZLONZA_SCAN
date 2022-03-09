*&---------------------------------------------------------------------*
*&  Include           ZINV_MOV_NON_HUI01
*&---------------------------------------------------------------------*
************************************************************************
* Program ID:                   ZINV_MOV_NON_HU
* Program Title:                Non HU Movements
* Created By:
* Creation Date:
* Capsugel / Lonza RICEFW ID:   S0096
* Description:                  Non HU Inventory movements using SCAN
* Tcode     :                   ZNONHU
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* Initial version
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PAI_CHECK_PLANT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_plant INPUT.

  zsits_scan_dynp-zzplant = zsits_user_profile-zzwerks.
  CLEAR gv_validation_fail.

  CHECK zsits_user_profile-zzwerks IS NOT INITIAL.

  PERFORM frm_check_plant CHANGING zsits_user_profile-zzwerks.

***** Authorization check for plant *****
  PERFORM auth_check_plant.
ENDMODULE.                 " PAI_CHECK_PLANT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_CURSOR_DETERMINE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_cursor_determine INPUT.
* if validation faiule, the cursor should be processed already. not need

  GET CURSOR FIELD gv_cursor_field.

  CASE gv_cursor_field.
    WHEN 'ZSITS_USER_PROFILE-ZZWERKS'.
      gv_cursor_field = 'ZSITS_USER_PROFILE-ZZLGNUM'.
    WHEN 'ZSITS_USER_PROFILE-ZZLGNUM'.
      gv_cursor_field = 'ZSITS_SCAN_DYNP-ZZSOURCESLOC'.
    WHEN 'ZSITS_SCAN_DYNP-ZZSOURCEBIN'.
      gv_cursor_field = 'ZSITS_SCAN_DYNP-ZZBARCODE'.
    WHEN 'ZSITS_SCAN_DYNP-ZZSOURCESLOC'.
    WHEN 'ZSITS_SCAN_DYNP-ZZBARCODE'.
      gv_cursor_field = 'BTN_NEXT'.
    WHEN 'ZSITS_SCAN_DYNP-ZZQTY'.
      gv_cursor_field = 'NEXT'.
    WHEN 'ZSITS_SCAN_DYNP-ZZDESTLOC'.
      gv_cursor_field = 'ZSITS_SCAN_DYNP-ZZDESTBIN'.
    WHEN 'ZSITS_SCAN_DYNP-ZZDESTBIN'.
      gv_cursor_field = 'SAVE'.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " PAI_CURSOR_DETERMINE  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_user_command INPUT.

  CHECK gv_validation_fail IS INITIAL.

  CASE sy-ucomm.
    WHEN gc_okcode_clear .
      CLEAR: zsits_user_profile-zzlgnum, zsits_user_profile-zzwerks,
             zsits_scan_dynp-zzsourcesloc.
      CALL SCREEN '0100'.
    WHEN 'B2B' OR 'B2L' OR 'L2B'.
      gv_button = sy-ucomm.
      CALL SCREEN '2000'.
    WHEN 'WBACK' OR 'EXIT' OR 'BACK'.
      LEAVE PROGRAM.
  ENDCASE.

*-- Fill values to global structure
  zsits_scan_dynp-zzplant     = zsits_user_profile-zzwerks.
  zsits_scan_dynp-zzwarehouse = zsits_user_profile-zzlgnum.


ENDMODULE.                 " PAI_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2000 INPUT.
  DATA: lv_ucomm TYPE sy-ucomm.
  CLEAR: lv_ucomm.
  lv_ucomm = sy-ucomm.
  CASE lv_ucomm.
    WHEN 'CLEAR'.
      CLEAR: zsits_scan_dynp-zzsourcebin,
             zsits_scan_dynp-zzbarcode.
      CALL SCREEN '2000'.
    WHEN 'NEXT'.
      PERFORM populate_screen_values.
      IF gv_validation_fail IS INITIAL.
        CALL SCREEN '3000'.
      ENDIF.
    WHEN 'WBACK' OR 'BACK'.
      CLEAR: zsits_scan_dynp-zzsourcebin,
             zsits_scan_dynp-zzbarcode.
      CALL SCREEN '0100'.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_4000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_4000 INPUT.
  DATA: lv_comm TYPE sy-ucomm.

  CLEAR: lv_comm.

  lv_comm = sy-ucomm.
  CASE lv_comm.
    WHEN 'CLEAR'.
      CLEAR: zsits_scan_dynp-zzdestbinloc, zsits_scan_dynp-zzdestloc.
      CALL SCREEN '4000'.
    WHEN 'BACK'.
      CLEAR: zsits_scan_dynp-zzdestbinloc, zsits_scan_dynp-zzdestloc.
      CALL SCREEN '3000'.
    WHEN 'WBACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      SET SCREEN '0100'.
    WHEN 'SAVE'.
      IF gv_validation_fail IS INITIAL.
        PERFORM process.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_4000  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_3000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_3000 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      CLEAR: zsits_scan_dynp-zzquantity, zsits_scan_dynp-zzqty,
             gv_stoloc, gv_batch, gv_material, gv_sto_cat, gv_qty_zero.
      CALL SCREEN '2000'.
    WHEN 'NEXT'.
      IF gv_qty_zero = gc_x.
        gv_validation_fail = gc_x.
        gv_with_message = abap_true.
        MESSAGE e506(zits) INTO gv_dummy.
        PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                      zsits_scan_dynp-zzqty
                                      gv_with_message.
      ELSEIF zsits_scan_dynp-zzqty IS INITIAL.
        gv_with_message = abap_true.
        MESSAGE e273(zits) INTO gv_dummy.
        PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                      zsits_scan_dynp-zzqty
                                      gv_with_message.
      ELSE.
        IF zsits_scan_dynp-zzqty GT gv_qty.
          gv_with_message = abap_true.
          MESSAGE e494(zits) INTO gv_dummy.
          PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                    zsits_scan_dynp-zzqty
                                    gv_with_message.
        ELSE.
          CALL SCREEN '4000'.
        ENDIF.
      ENDIF.
    WHEN 'CLEAR'.
      CLEAR: zsits_scan_dynp-zzqty.
      CALL SCREEN '3000'.
    WHEN 'WBACK'.
      SET SCREEN '2000'.
    WHEN 'EXIT'.
      SET SCREEN '0100'.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_3000  INPUT
*&---------------------------------------------------------------------*
*&      Module  BARCODE_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE barcode_check INPUT.

  DATA: lv_batch         TYPE charg_d,
        lv_material      TYPE matnr,
        ls_read          TYPE zsits_batch_read_option,
        ls_mat           TYPE zsits_material_read_para,
        lo_obj           TYPE REF TO zcl_mde_barcode,
        ls_label_content TYPE zsits_label_content.

  CLEAR: zsits_scan_dynp-zzbatch.

**-- Object instantiation
  IF go_log IS INITIAL.
    CREATE OBJECT go_log
      EXPORTING
        iv_scan_code = sy-tcode.
  ENDIF.

  IF lo_obj IS INITIAL.
    CREATE OBJECT lo_obj.
  ENDIF.

  IF zsits_scan_dynp-zzbarcode IS NOT INITIAL.
    TRANSLATE zsits_scan_dynp-zzbarcode TO UPPER CASE.
    CLEAR : zsits_scan_dynp-zzsuccess_msg, gv_batch, gv_material,
            lv_batch, lv_material.

*-- Seggrigate the Batch & Material Number from the Barcode
    CALL METHOD zcl_mde_barcode=>disolve_barcode
      EXPORTING
        iv_barcode       = zsits_scan_dynp-zzbarcode
        iv_werks         = zsits_user_profile-zzwerks
      IMPORTING
        es_label_content = ls_label_content.

*-- Get the batch details(Material & qty) if they give batch
    lv_batch = zsits_scan_dynp-zzbatch = ls_label_content-zzorigin_batch.
    lv_material = ls_label_content-zzmatnr.
    zsits_scan_dynp-zzbatch = lv_batch.

*-- Input parameters to read the material details
    IF zsits_scan_dynp-zzbarcode CA ':'.
      SPLIT zsits_scan_dynp-zzbarcode AT ':' INTO DATA(lv_sbatch) DATA(lv_scan_mat).
      SPLIT lv_scan_mat AT '241' INTO DATA(lv_dummy) DATA(lv_scan_material).
      IF lv_material NE lv_scan_material.
        lv_material = lv_scan_material.
      ENDIF.
    ENDIF.

    ls_mat-matnr      = lv_material.
    ls_mat-stock_read = gc_x.
*-- Get the Material qty, sloc....
    CALL METHOD zcl_its_utility=>material_read_dfds
      EXPORTING
        is_key           = ls_mat
        iv_batch         = lv_batch
      RECEIVING
        rs_material_data = gs_mat_data
      EXCEPTIONS
        illegal_bar_code = 1
        conversion_error = 2
        system_error     = 3
        numeric_error    = 4
        OTHERS           = 5.
    IF sy-subrc = 0.
      gs_batch_data-matnr = zsits_scan_dynp-zzmaterial = gs_mat_data-matnr.
      gs_batch_data-meins = gs_mat_data-meins.
    ELSE.

    ENDIF.


  ELSE.
    gv_with_message = abap_true.
    MESSAGE e504(zits) INTO gv_dummy.
    PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                  zsits_scan_dynp-zzqty
                                  gv_with_message.
  ENDIF.

  CLEAR: lv_sbatch, lv_scan_mat, lv_dummy, lv_scan_material.

ENDMODULE.                 " BARCODE_CHECK  INPUT
*&---------------------------------------------------------------------*
*&      Form  FRM_ADD_LABEL_TYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZCL_ITS_UTILITY=>GC_LABEL_FG_B  text
*      <--P_LT_LABEL_TYPE  text
*----------------------------------------------------------------------*
FORM frm_add_label_type  USING   uv_label_type  TYPE zdits_label_type
                         CHANGING ct_label_range TYPE ztlabel_type_range.

  DATA: lwa_label_range LIKE LINE OF ct_label_range.

  lwa_label_range-sign   = 'I'.
  lwa_label_range-zoption = 'EQ'.
  lwa_label_range-low    = uv_label_type.
  APPEND lwa_label_range TO ct_label_range.

ENDFORM.                    " FRM_ADD_LABEL_TYPE
*&---------------------------------------------------------------------*
*&      Module  POPULATE_SCREEN_VALUES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*
*ENDMODULE.                 " POPULATE_SCREEN_VALUES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_CHECK_QTY  INPUT
*&---------------------------------------------------------------------*
*       Quantity Validation
*----------------------------------------------------------------------*
MODULE pai_check_qty INPUT.
  CLEAR: gv_qty_zero.
*--  Quantity Validation
  IF gv_qty IS NOT INITIAL.
    IF zsits_scan_dynp-zzqty IS INITIAL.
      gv_with_message = abap_true.
      MESSAGE e273(zits) INTO gv_dummy.
      PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                    zsits_scan_dynp-zzqty
                                    gv_with_message.
    ELSEIF zsits_scan_dynp-zzqty GT gv_qty.
      gv_with_message = abap_true.
      MESSAGE e494(zits) INTO gv_dummy.
      PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                zsits_scan_dynp-zzqty
                                gv_with_message.
    ENDIF.
  ELSE.
    gv_qty_zero = gc_x.
  ENDIF.
ENDMODULE.                 " PAI_CHECK_QTY  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_CHECK_WHNUM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_whnum INPUT.
  zsits_scan_dynp-zzwarehouse = zsits_user_profile-zzlgnum.
***** Authorization check for plant *****
  IF zsits_scan_dynp-zzwarehouse IS NOT INITIAL AND sy-ucomm = 'B2B'.
    PERFORM auth_check_whn.
  ENDIF.
ENDMODULE.                 " PAI_CHECK_WHNUM  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_CHECK_LOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_loc INPUT.
  CLEAR: gv_with_message.
ENDMODULE.                 " PAI_CHECK_LOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_CHECK_BIN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_bin INPUT.
  DATA: lv_bin TYPE lgpla.

  CLEAR: gv_validation_fail.

  IF gv_button = 'B2B' OR gv_button = 'B2L'.
    IF zsits_scan_dynp-zzsourcebin IS NOT INITIAL.
*-- Check whether the entry is in table or not..
      SELECT SINGLE lgpla
                FROM lagp
                INTO lv_bin
                WHERE lgnum = zsits_user_profile-zzlgnum
                  AND lgpla = zsits_scan_dynp-zzsourcebin.
      IF sy-subrc NE 0.
*-- Raise an error message
        gv_with_message = abap_true.
        MESSAGE e129(zits) WITH zsits_scan_dynp-zzsourcebin INTO gv_dummy.
        PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                      zsits_scan_dynp-zzsourcebin
                                      gv_with_message.
      ENDIF.
    ELSE.
*-- Raise an error message that the biun is required..
      gv_with_message = abap_true.
      MESSAGE e503(zits) INTO gv_dummy.
      PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                    zsits_scan_dynp-zzsourcebin
                                    gv_with_message.
    ENDIF.
  ENDIF.
ENDMODULE.                 " PAI_CHECK_BIN  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_BIN_CHK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_bin_chk INPUT.
  DATA: lv_dbin TYPE lgpla.

  CHECK zsits_scan_dynp-zzdestbin IS NOT INITIAL.
*-- Check whether the entry is in table or not..
  SELECT SINGLE lgpla
            FROM lagp
            INTO lv_dbin
            WHERE lgnum = zsits_user_profile-zzlgnum
              AND lgpla = zsits_scan_dynp-zzdestbin.
  IF sy-subrc NE 0.
    gv_validation_fail = gc_x.
*-- Raise an error message
    gv_with_message = abap_true.
    MESSAGE e129(zits) WITH zsits_scan_dynp-zzdestbin INTO gv_dummy.
    PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                  zsits_scan_dynp-zzdestbin
                                  gv_with_message.
  ENDIF.
ENDMODULE.                 " PAI_BIN_CHK  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DESTLOC_CHK  INPUT
*&---------------------------------------------------------------------*
*       Source & Dest loc Validation
*----------------------------------------------------------------------*
MODULE pai_destloc_chk INPUT.

  CLEAR: gv_validation_fail.

  CHECK zsits_scan_dynp-zzdestloc IS NOT INITIAL.

  IF zsits_scan_dynp-zzsourcesloc = zsits_scan_dynp-zzdestloc AND gv_button NE 'B2B'.
    gv_validation_fail = gc_x.
*-- Raise an error message
    gv_with_message = abap_true.
    MESSAGE e283(zits) INTO gv_dummy.
    PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                  zsits_scan_dynp-zzdestloc
                                  gv_with_message.
  ENDIF.

ENDMODULE.                 " PAI_DESTLOC_CHK  INPUT
*&---------------------------------------------------------------------*
*&      Module  CLEAR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear INPUT.
  CLEAR: gv_validation_fail, gv_with_message.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_TVARVC_ENTRIES  INPUT
*&---------------------------------------------------------------------*
*       Get TVARVC entries
*----------------------------------------------------------------------*
MODULE get_tvarvc_entries INPUT.
  DATA: lv_name TYPE rvari_vnam.

*-- Movement type based on the Stock type to create the MIGO
  IF zsits_scan_dynp-zzstocat = ''.
    lv_name = 'ZNONHU_INV_MVT_TYPE_UTD'.
  ELSEIF zsits_scan_dynp-zzstocat = 'Q'.
    lv_name = 'ZNONHU_INV_MVT_TYPE_QTY'.
  ELSEIF zsits_scan_dynp-zzstocat = 'S'.
    lv_name = 'ZNONHU_INV_MVT_TYPE_BLKD'.
  ENDIF.

  SELECT SINGLE low
             FROM tvarvc
             INTO gv_mvt_type
             WHERE name = lv_name.
  IF sy-subrc = 0.
*-- DO nothing
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_VALIDATIONS  INPUT
*&---------------------------------------------------------------------*
* Validation for all the fields as all the fields in the screena are
* mandatory
*----------------------------------------------------------------------*
MODULE pai_validations INPUT.
  DATA: lv_empty TYPE string.
  IF sy-ucomm NE 'BACK' AND sy-ucomm NE 'CLEAR'.
    IF zsits_user_profile-zzwerks IS INITIAL OR
       zsits_user_profile-zzlgnum IS INITIAL OR
       zsits_scan_dynp-zzsourcesloc IS INITIAL.

      gv_validation_fail = gc_x.

      gv_with_message = abap_true.
      MESSAGE e505(zits) INTO gv_dummy.
      PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                    lv_empty
                                    gv_with_message.
    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_5000  INPUT
*&---------------------------------------------------------------------*
*       User command actions
*----------------------------------------------------------------------*
MODULE user_command_5000 INPUT.

  IF sy-ucomm = 'NEW'.
    CLEAR: gv_suc1, gv_suc2, zsits_user_profile, zsits_scan_dynp,
           gv_button, gv_button, gv_dummy, gv_material, gv_mblnr,
           gv_qty, gv_with_message, gv_tonum, gs_mat_data, gs_batch_data,
           gs_mat_data, gv_sto_cat, gv_mvt_type, gv_stoloc, gv_batch,
           gv_material, gv_sto_cat.
*-- call the transaction again to open the initial screen
    CALL TRANSACTION 'ZNONHU'.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_VALIDATIONS_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_validations_2000 INPUT.
  DATA: lv_null TYPE string.
  IF sy-ucomm NE 'BACK' AND sy-ucomm NE 'CLEAR'.
    IF gv_button = 'B2B' OR gv_button = 'B2L'.
      IF zsits_scan_dynp-zzsourcebin IS INITIAL OR
        zsits_scan_dynp-zzbarcode IS INITIAL.

        gv_validation_fail = gc_x.
        gv_with_message = abap_true.
        MESSAGE e505(zits) INTO gv_dummy.
        PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                      lv_null
                                      gv_with_message.
      ENDIF.
    ELSE.
      IF zsits_scan_dynp-zzbarcode IS INITIAL.

        gv_validation_fail = gc_x.
        gv_with_message = abap_true.
        MESSAGE e505(zits) INTO gv_dummy.
        PERFORM frm_message_add USING zcl_its_utility=>gc_objid_label
                                      lv_null
                                      gv_with_message.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.
