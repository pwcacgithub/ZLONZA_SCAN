*----------------------------------------------------------------------*
***INCLUDE ZMTD_SCAN_E0322_SUTBIN_PBO .
*----------------------------------------------------------------------*
***********************************************************************
* VERSION CONTROL (Most recent on top):
* DATE             AUTHOR       CTS REQ        DESCRIPTION
*----------------------------------------------------------------------

***********************************************************************


*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS '9000'.
  SET TITLEBAR '900'.
ENDMODULE.                 " STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9010  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9010 OUTPUT.
  SET PF-STATUS '9000'.
  SET TITLEBAR '900' WITH '-' zsits_scan_dynp-zzdestbin.
  gv_destbinno = zsits_scan_dynp-zzdestbin.
ENDMODULE.                 " STATUS_9010  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE initialize OUTPUT.
*
  PERFORM get_user_profile.
*
  PERFORM initial_log.

ENDMODULE.                 " INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISP_SU  OUTPUT
*&---------------------------------------------------------------------*
*       Display SU in Table view
*----------------------------------------------------------------------*
MODULE disp_su OUTPUT.
  DESCRIBE TABLE it_su LINES sy-dbcnt.
  v_hu_counter = sy-dbcnt.
  ztblctrl_su-lines        = sy-dbcnt.
  ztblctrl_su-current_line = sy-loopc.
  zsits_scan_dynp-zzsu = wa_su.
  IF zsits_scan_dynp-zzsu IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_LENUM_OUTPUT'
      EXPORTING
        input           = zsits_scan_dynp-zzsu
      IMPORTING
        output          = zsits_scan_dynp-zzsu
      EXCEPTIONS
        t344_get_failed = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF.
ENDMODULE.                 " DISP_SU  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISP_SET  OUTPUT
*&---------------------------------------------------------------------*

MODULE disp_set OUTPUT.
*--Begin of changes BY MMEHTA
  DESCRIBE TABLE it_su LINES v_hu_counter.
*--End of changes BY MMEHTA
  IF v_hu_counter IS NOT INITIAL.
    v_hu_txt = 'HUs'.
  ENDIF.
*Begin of insert rvenugopal EICR 603418
  gv_destbinno = zsits_scan_dynp-zzdestbin.
*End of insert rvenugopal EICR 603418

*--Begin of changes BY MMEHTA
  DATA : lv_tabix TYPE sy-tabix.

  CLEAR lv_tabix.
  CLEAR :  gv_su1, gv_su2, gv_su3.

*---Read the values before screen display and populate accordingly on index based
  IF sy-ucomm NE 'P+' AND sy-ucomm NE 'P-'.

    CLEAR : gt_lenum.
*--loop will run for each record for count of entries in internal table
    LOOP AT it_su ASSIGNING FIELD-SYMBOL(<lfs_final>).
      ADD 1 TO lv_tabix.
      IF lv_tabix GT 3.
        lv_tabix =  1.
      ENDIF.
      CASE lv_tabix.
        WHEN 1.
          APPEND INITIAL LINE TO gt_lenum ASSIGNING FIELD-SYMBOL(<lfs_exidv>).
          <lfs_exidv>-su1 = <lfs_final>.
        WHEN 2.
          DESCRIBE TABLE gt_lenum LINES DATA(lv_lines).
          READ TABLE gt_lenum ASSIGNING <lfs_exidv> INDEX lv_lines.
          IF sy-subrc EQ 0.
            <lfs_exidv>-su2 = <lfs_final>.
          ENDIF.
        WHEN 3.
          DESCRIBE TABLE gt_lenum LINES lv_lines.
          READ TABLE gt_lenum ASSIGNING <lfs_exidv> INDEX lv_lines.
          IF sy-subrc EQ 0.
            <lfs_exidv>-su3 = <lfs_final>.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDIF.


*--Increament the index value below condition not sasified.
  IF sy-ucomm EQ 'P+' OR sy-ucomm = 'P-'.
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
*--End of changes by MMEHTA.
ENDMODULE.                 " DISP_SET  OUTPUT
