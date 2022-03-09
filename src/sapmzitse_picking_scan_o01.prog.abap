*&---------------------------------------------------------------------*
*&  Include           SAPMZITSE_PICKING_SCAN_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_9100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9100 OUTPUT.

  CLEAR:v_flag.

  IF v_clear = abap_true.
    REFRESH:it_su_number,
            it_ltap_conf,
            it_ltap_conf_hu.

    CLEAR:zsits_scan_pick-tanum,
          zsits_scan_pick-zzbarcode,
          zsits_scan_pick-quantity,
          v_clear,
          v_tanum.
  ENDIF.

  SET PF-STATUS 'SCAN_STATUS_9100'.
*  SET TITLEBAR 'SCAN_TITLEBAR'.

  PERFORM initial_logon_data.
  PERFORM get_user_profile.

ENDMODULE.                 " STATUS_9100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9200 OUTPUT.
  SET PF-STATUS 'SCAN_STATUS_9200'.
  SET TITLEBAR 'SCAN_TITLEBAR'.

ENDMODULE.                 " STATUS_9200  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'DISPLAY_SU'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE display_su_change_tc_attr OUTPUT.
*--Begin of changes bu SKOTTURU
*  DESCRIBE TABLE it_su_number LINES display_su-lines.
*--End of changes by skotturu.

*--Begin of changes bu SKOTTURU
DATA : lv_tabix TYPE sy-tabix.

  CLEAR lv_tabix.
  CLEAR :  gv_su1, gv_su2, gv_su3.

*---Read the values before screen display and populate accordingly on index based
  IF sy-ucomm NE gc_pgup AND sy-ucomm NE gc_pgdn.

    CLEAR : gt_lenum.
*--loop will run for each record for count of entries in internal table
    LOOP AT it_su_number ASSIGNING FIELD-SYMBOL(<lfs_final>).
      ADD 1 TO lv_tabix.
      IF lv_tabix GT 3.
        lv_tabix =  1.
      ENDIF.
      CASE lv_tabix.
        WHEN 1.
          APPEND INITIAL LINE TO gt_lenum ASSIGNING FIELD-SYMBOL(<lfs_exidv>).
          <lfs_exidv>-su1 = <lfs_final>-lenum.
        WHEN 2.
          DESCRIBE TABLE gt_lenum LINES DATA(lv_lines).
          READ TABLE gt_lenum ASSIGNING <lfs_exidv> INDEX lv_lines.
          IF sy-subrc EQ 0.
            <lfs_exidv>-su2 = <lfs_final>-lenum.
          ENDIF.
        WHEN 3.
          DESCRIBE TABLE gt_lenum LINES lv_lines.
          READ TABLE gt_lenum ASSIGNING <lfs_exidv> INDEX lv_lines.
          IF sy-subrc EQ 0.
            <lfs_exidv>-su3 = <lfs_final>-lenum.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDIF.


*--Increament the index value below condition not sasified.
      IF sy-ucomm EQ gc_pgup OR sy-ucomm = gc_pgdn.
        ELSE.
          DESCRIBE TABLE gt_lenum LINES lv_lines.
          gv_index = lv_lines.
      ENDIF.


*--Initially index value is zero
        IF gv_index = 0.
          gv_index = 1.
        ENDIF.

*--Read screen value from Index to populate on screen
  READ TABLE gt_lenum ASSIGNING <lfs_exidv> INDEX gv_index.
    IF sy-subrc EQ 0.
*--read SU number
      gv_su1 = <lfs_exidv>-su1.
      gv_su2 = <lfs_exidv>-su2.
      gv_su3 = <lfs_exidv>-su3.

*--First HU details
    READ TABLE it_su_number ASSIGNING <lfs_final> WITH KEY lenum = gv_su1.
    IF sy-subrc EQ 0.
*--Convert HU without leading zero's
      gv_su1 = <lfs_final>-lenum.
    ENDIF.

*--Second HU details
    READ TABLE it_su_number ASSIGNING <lfs_final> WITH KEY lenum = gv_su2.
    IF sy-subrc EQ 0.
*--Convert HU without leading zero's
      gv_su2 = <lfs_final>-lenum.
    ENDIF.

*--Third HU detail on Lower level HU's
    READ TABLE it_su_number ASSIGNING <lfs_final> WITH KEY lenum = gv_su3.
    IF sy-subrc EQ 0.
*--Convert HU without leading zero's
      gv_su3 = <lfs_final>-lenum.
    ENDIF.
  ENDIF.
*--End of changes by skotturu.
ENDMODULE.                    "DISPLAY_SU_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'DISPLAY_SU'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE display_su_get_lines OUTPUT.
  g_display_su_lines = sy-loopc.
ENDMODULE.                    "DISPLAY_SU_GET_LINES OUTPUT
