*&---------------------------------------------------------------------*
*&  Include           MZITSEWM_PICKINGO01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  GET_USER_PROFILE  OUTPUT
*&---------------------------------------------------------------------*
*       Get user profile
*----------------------------------------------------------------------*
MODULE get_user_profile OUTPUT.
  IF x_profile IS INITIAL.
    CALL METHOD zcl_its_utility=>get_user_profile
      RECEIVING
        rs_user_profile = x_profile.
  ENDIF.
ENDMODULE.                 " GET_USER_PROFILE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INITIALIZE_LOG  OUTPUT
*&---------------------------------------------------------------------*
*       Initialize log
*----------------------------------------------------------------------*
MODULE initialize_log OUTPUT.
  IF o_log IS INITIAL.
    CREATE OBJECT o_log
      EXPORTING
        iv_scan_code = sy-tcode.
  ENDIF.

*Begin of change ED2K911347 INC0031176/1 VARGHA 04/30/2018
  CALL METHOD zcl_common_utility=>parameter_read
    EXPORTING
      iv_name   = 'ZWM_SCAN_PICK_BATCH_CHAR'
      iv_type   = 'P'
    IMPORTING
      et_tvarvc = gt_tvarvc
      ev_return = gv_return.

  READ TABLE gt_tvarvc INTO gs_tvarvc INDEX 1.
*End of change ED2K911347 INC0031176/1 VARGHA 04/30/2018

ENDMODULE.                 " INITIALIZE_LOG  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  SET PF-STATUS 'S9001'.
ENDMODULE.                 " STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9002  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_9002 OUTPUT.
  SET PF-STATUS 'S9002'.
ENDMODULE.                 " STATUS_9002  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISP_SET  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE disp_set OUTPUT.
  "Begin of change for defect 80, 04.03.2020
  clear lv_hu_counter.
  "End of change for defect 80, 04.03.2020
  DESCRIBE TABLE it_su LINES lv_hu_counter.
  IF lv_hu_counter IS NOT INITIAL.
    lv_hu_txt = 'HUs'.
  ENDIF.

*--Begin of changes BY MMEHTA
  DATA : lv_tabix TYPE sy-tabix.

  CLEAR lv_tabix.
  CLEAR :  gv_su1, gv_su2, gv_su3.

*---Read the values before screen display and populate accordingly on index based
  IF sy-ucomm NE 'P+' AND sy-ucomm NE 'P-'.

    CLEAR : gt_ZD_PALCARTON.
*--loop will run for each record for count of entries in internal table
    LOOP AT it_su ASSIGNING FIELD-SYMBOL(<lfs_final>).
      ADD 1 TO lv_tabix.
      IF lv_tabix GT 3.
        lv_tabix =  1.
      ENDIF.
      CASE lv_tabix.
        WHEN 1.
          APPEND INITIAL LINE TO gt_ZD_PALCARTON ASSIGNING FIELD-SYMBOL(<lfs_exidv>).
          <lfs_exidv>-su1 = <lfs_final>.
        WHEN 2.
          DESCRIBE TABLE gt_ZD_PALCARTON LINES DATA(lv_lines).
          READ TABLE gt_ZD_PALCARTON ASSIGNING <lfs_exidv> INDEX lv_lines.
          IF sy-subrc EQ 0.
            <lfs_exidv>-su2 = <lfs_final>.
          ENDIF.
        WHEN 3.
          DESCRIBE TABLE gt_ZD_PALCARTON LINES lv_lines.
          READ TABLE gt_ZD_PALCARTON ASSIGNING <lfs_exidv> INDEX lv_lines.
          IF sy-subrc EQ 0.
            <lfs_exidv>-su3 = <lfs_final>.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDIF.


*--Increament the index value below condition not sasified.
  IF sy-ucomm EQ 'P+' OR sy-ucomm = 'P-'.
  ELSE.
    DESCRIBE TABLE gt_ZD_PALCARTON LINES lv_lines.
    gv_index = lv_lines.
  ENDIF.


*--Initially index value is zero
  IF gv_index = 0.
    gv_index = 1.
  ENDIF.

*--Read screen value from Index to populate on screen
  READ TABLE gt_ZD_PALCARTON ASSIGNING <lfs_exidv> INDEX gv_index.
  IF sy-subrc EQ 0.
*--read SU number
    gv_su1 = <lfs_exidv>-su1.
    gv_su2 = <lfs_exidv>-su2.
    gv_su3 = <lfs_exidv>-su3.

*--First HU details
    READ TABLE it_su ASSIGNING <lfs_final> WITH KEY  gv_su1.
    IF sy-subrc EQ 0.
*--Convert HU without leading zero'
      gv_su1 = <lfs_final>.
    ENDIF.

*--Second HU details
    READ TABLE it_su ASSIGNING <lfs_final> WITH KEY  gv_su2.
    IF sy-subrc EQ 0.
*--Convert HU without leading zero's
      gv_su2 = <lfs_final>.
    ENDIF.

*--Third HU detail on Lower level HU's
    READ TABLE it_su ASSIGNING <lfs_final> WITH KEY  gv_su3.
    IF sy-subrc EQ 0.
*--Convert HU without leading zero's
      gv_su3 = <lfs_final>.
    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9003  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9003 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
ENDMODULE.
