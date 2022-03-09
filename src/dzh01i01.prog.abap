*&---------------------------------------------------------------------*
*&  Include           DZH01I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

*--Based on OK system command it will check
  CASE sy-ucomm.
    WHEN gc_back OR gc_f3. "'BACK'.
      LEAVE PROGRAM .

    WHEN gc_clr OR gc_f2. "'CLR' OR 'F2'.
      CLEAR : gv_barcode, gs_hu.

    WHEN gc_enter. "'ENTER'.
      IF gs_hu-exidv IS NOT INITIAL.
        PERFORM validation CHANGING gs_hu.
      ENDIF.

    WHEN gc_next. "'NEXT'.
      CLEAR : gt_exidv.
*--Call screen 200 to go to next screen
      IF gs_hu-exidv IS NOT INITIAL.
        PERFORM validation CHANGING gs_hu.
        CALL SCREEN 0200.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  DATA : lv_msgv1 TYPE msgv1.
  CONSTANTS : lc_msgno8 TYPE msgno VALUE '014'.

*--Check User command action
  CASE sy-ucomm.

*--leave to screen Back
    WHEN gc_back OR gc_f3.
      REFRESH : gt_final, gt_exidv.
      LEAVE TO SCREEN 100 .

    WHEN gc_clr.
*--clear HU details
      CLEAR : gv_lbarcode, gv_exidv.

    WHEN gc_ent OR gc_save.
*--Validate Lower Level HU's and Save
      IF gv_exidv IS NOT INITIAL.
        PERFORM validate_lowerhu USING gv_exidv.
      ENDIF.

    WHEN gc_pgdn. "'PGDN'.
*--Pagedown for next screen
      PERFORM next_screen_pagedown.

    WHEN gc_pgup. "'PGUP'.
*--Pageup for back screen
      PERFORM pagup_previousscreen.

    WHEN gc_ch1 OR gc_ch2 OR gc_ch3. "'CH1' OR 'CH2' OR 'CH3'.
*--Check box selection validtion
      PERFORM chekbox_validation.

    WHEN gc_rem.
*--Remove selected check box entery box screen
      PERFORM remove_selctedentry.

    WHEN gc_pack. "'PACK'.
*--Pack box on Pallet validation and Pack on pallet
      IF gt_final[] IS NOT INITIAL.
        PERFORM packbox_pallethu TABLES gt_final.
      ELSE.

        CLEAR : lv_msgv1.
*--Show an error message if no lower level HU's
        PERFORM error_message USING gc_msgid
                                    lc_msgno8
                                    lv_msgv1.
      ENDIF.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  DATA : lv_no    TYPE dynnr,
         lv_dynnr TYPE sy-dynnr.

  CONSTANTS : lc_zero TYPE char1 VALUE '0'.
  CLEAR : lv_no, lv_dynnr.
  CASE sy-ucomm.
    WHEN gc_back OR gc_ok.
*--recollect previous screen number
      GET PARAMETER ID text-020 FIELD lv_no.
      lv_dynnr = lv_no.
*--Incase of screen no zero means successful message then leave program
      IF lv_no = lc_zero.
        LEAVE PROGRAM.
      ELSE.
*--another zero status move to previous screen only
        LEAVE TO SCREEN lv_dynnr.
      ENDIF.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validation INPUT.
*--validate input field value
  IF sy-ucomm EQ gc_enter.
    PERFORM validation CHANGING gs_hu.
  ENDIF.
*--Back to main screen
  IF sy-ucomm EQ gc_back OR
     sy-ucomm EQ gc_f3.
    LEAVE PROGRAM .
  ENDIF.
*--clear values
  IF sy-ucomm EQ gc_f2.
    CLEAR : gv_barcode,gs_hu.
  ENDIF.


ENDMODULE.                 " VALIDATION  INPUT
*&---------------------------------------------------------------------*
*&      Module  SPLIT_HU  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE split_hu INPUT .

  DATA: ls_label_content TYPE zsits_label_content,
        LV_FLAG          TYPE C,
        lv_exidv         TYPE exidv,
        lv_barcode1      TYPE string,
        lv_barcode       TYPE string,
        ls_return        TYPE bapiret2.
  CLEAR :  gs_hu, lv_flag.

  GET PARAMETER ID 'ZGELATIN' FIELD LV_FLAG.

  IF LV_FLAG <> ABAP_TRUE.
*--Read the HU number enter one is with Prefix or not
*--If not prefix of HU number then add Prefix with below code
*--Create Class Object for validation
    CREATE OBJECT go_hu.
    CALL METHOD go_hu->hubarcode_value
      EXPORTING
        iv_exidv    = gv_barcode
      IMPORTING
        ev_hunumber = gv_barcode.

*--Read the barcode values
    CALL METHOD zcl_mde_barcode=>disolve_barcode
      EXPORTING
        iv_barcode       = gv_barcode
        iv_werks         = ' '
      IMPORTING
        es_label_content = ls_label_content.
  ELSE.
    LV_BARCODE = gv_barcode.
    CALL FUNCTION 'ZWM_HU_VALIDATE'
      EXPORTING
        IV_BARCODE       = LV_BARCODE
      IMPORTING
        EV_EXIDV         = LV_EXIDV
        ES_RETURN        = LS_RETURN
        EV_BARCODE       = LV_BARCODE1
        ES_LABEL_CONTENT = ls_label_content.
    gv_barcode = lv_barcode1.
    CLEAR lv_flag.
  ENDIF.


  IF ls_label_content-zzhu_exid IS INITIAL.
    RETURN.
  ENDIF.

  gs_hu-exidv = ls_label_content-zzhu_exid .
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SPLIT_HU_LOWER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE split_hu_lower INPUT.
  CLEAR : ls_label_content.
  GET PARAMETER ID 'ZGELATIN' FIELD LV_FLAG.

  IF LV_FLAG <> ABAP_TRUE.
*--Barcode Prefix value for HU
    CALL METHOD go_hu->hubarcode_value
      EXPORTING
        iv_exidv    = gv_lbarcode
      IMPORTING
        ev_hunumber = gv_lbarcode.

*REad the barcode
    CALL METHOD zcl_mde_barcode=>disolve_barcode
      EXPORTING
        iv_barcode       = gv_lbarcode
        iv_werks         = ' '
      IMPORTING
        es_label_content = ls_label_content.
  ELSE.
    LV_BARCODE = gv_lbarcode.
    CALL FUNCTION 'ZWM_HU_VALIDATE'
      EXPORTING
        IV_BARCODE       = LV_BARCODE
      IMPORTING
        EV_EXIDV         = LV_EXIDV
        ES_RETURN        = LS_RETURN
        EV_BARCODE       = LV_BARCODE1
        ES_LABEL_CONTENT = ls_label_content.
    gv_barcode = lv_barcode1.
    CLEAR lv_flag.
  ENDIF.
  IF ls_label_content-zzhu_exid IS INITIAL.
    RETURN.
  ENDIF.

  gv_exidv = ls_label_content-zzhu_exid .
ENDMODULE.
