*&---------------------------------------------------------------------*
*&  Include           MZITSEHUMOVE_O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  PBO_INITIALIZATION  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_initialization OUTPUT.

**  IF v_err_fg EQ abap_false.
**    CLEAR zsits_scan_humove.
**  ENDIF.

  CLEAR: zsits_scan_dynp-zzbarcode,
         v_err_fg.

  SET PF-STATUS 'SCAN_STATUS'.
  PERFORM frm_get_user_profile.
  PERFORM frm_initial_log.

ENDMODULE.                 " PBO_INITIALIZATION  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PBO_CHECK_HUWBEVENT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_check_huwbevent OUTPUT.

  CLEAR: v_pid, v_err_fg, v_huwbevent.


** Get process code
*fetch the process code from the tcode. This transaction takes care of other
*process codes also .To enable it , create the tcode as following 'ZSHUM<PROCESS CODE>'.
  v_huwbevent = sy-tcode+5(4).
  IF v_huwbevent EQ space.
    v_err_fg = abap_true.
  ELSE.
    " Add process code back to the transaction code
* Set screen
    CASE v_huwbevent.
      WHEN '0003' OR '0004'.
        CALL SCREEN 9100.
      WHEN '0005'.
        CALL SCREEN 9110.
      WHEN '0006'.
        CALL SCREEN 9200.
      WHEN '0011'.
        CALL SCREEN 9200.
      WHEN '0012'.
        CALL SCREEN 9100.
      WHEN '0013'.
        CALL SCREEN 9300.
      WHEN '0014'.
        CALL SCREEN 9400.
      WHEN '0021' OR '0022' OR '0023'.
        CALL SCREEN 9100.
      WHEN '0024' OR '0025'.
        CALL SCREEN 9200.
      WHEN 'Z001'.
        CALL SCREEN 9500.
      WHEN 'Z002'.
        CALL SCREEN 9600.
      WHEN OTHERS.
        v_err_fg = abap_true.
    ENDCASE.
  ENDIF.
* Add log and display message
  IF v_err_fg EQ abap_true.
    "Proccess code is not given or invalid
    MESSAGE e011 INTO v_dummy.
    PERFORM frm_add_message USING zcl_its_utility=>gc_objid_label
                               zsits_scan_dynp-zzbarcode
                               v_err_fg.
    LEAVE TO SCREEN 0.
  ENDIF.

ENDMODULE.                 " PBO_CHECK_HUWBEVENT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISP_SU  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE disp_su OUTPUT.

  DESCRIBE TABLE it_su LINES sy-dbcnt.
  v_hu_counter = sy-dbcnt.
  IF v_hu_counter IS NOT INITIAL.
    v_hu_txt = 'HUs'.
  ENDIF.
  IF sy-subrc EQ 0.
    ztblctrl_su-lines        = sy-dbcnt.
    ztblctrl_su-current_line = sy-loopc.
    zsits_scan_dynp-zzsu = wa_su.
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
*&      Module  DSP_HU  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE dsp_hu OUTPUT.
  DATA: lv_count1 TYPE i,
        lw_su     TYPE zsits_scan_dynp-zzsu.
  IF gv_index1 IS INITIAL AND gv_index2 IS INITIAL.
    gv_index1 = 1.
    gv_index2 = 5.
  ENDIF.
  CLEAR: lw_su, lv_count1.
  LOOP AT it_su INTO lw_su FROM gv_index1 TO gv_index2.
    lv_count1 = lv_count1 + 1.
    CASE lv_count1.
      WHEN 1.
        gv_cart1 = lw_su.
        SHIFT gv_cart1 LEFT DELETING LEADING '0'.
      WHEN 2.
        gv_cart2 = lw_su.
        SHIFT gv_cart2 LEFT DELETING LEADING '0'.
      WHEN 3.
        gv_cart3 = lw_su.
        SHIFT gv_cart3 LEFT DELETING LEADING '0'.
      WHEN 4.
        gv_cart4 = lw_su.
        SHIFT gv_cart4 LEFT DELETING LEADING '0'.
      WHEN 5.
        gv_cart5 = lw_su.
        SHIFT gv_cart5 LEFT DELETING LEADING '0'.
    ENDCASE.
    CLEAR: lw_su.
  ENDLOOP.
  DESCRIBE TABLE IT_SU LINES V_HU_COUNTER.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'ZG1'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.
