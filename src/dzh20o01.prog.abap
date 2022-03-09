*&---------------------------------------------------------------------*
*&  Include           DZH00O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
*--PF status
  SET PF-STATUS '0100'.
*--Title
  SET TITLEBAR '100'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0800  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0800 OUTPUT.
  SET PF-STATUS '0800'.


ENDMODULE.                 " STATUS_0800  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

*--PF status of 200
  SET PF-STATUS '0200'.

*--Page Up and Page down button is enabled and disabled
  LOOP AT SCREEN.
    CASE screen-name.
*--Page up button enable
      WHEN gc_pgup OR gc_up. "'PGUP' OR 'RLMOB-PPGUP'.
        IF gv_exidv3 IS INITIAL AND
           gv_pg_cnt IS INITIAL.
*--Deactive button
          screen-active = 0.
        ELSEIF gv_pg_cnt IS NOT INITIAL.
*--Active button
          screen-active = 1.
        ENDIF.
*--Page down button
      WHEN gc_pgdn OR gc_dn. "'PGDN' OR 'RLMOB-PPGDN'.
        IF gv_exidv3 IS INITIAL AND
           gv_pg_cnt IS INITIAL .
*--Deactive button
          screen-active = 0.
        ELSEIF gv_pg_cnt IS NOT INITIAL.
*--Active button
          screen-active = 1.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TRANSP_ITAB_OUT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE transp_itab_out OUTPUT.

  gv_idx = sy-stepl + gv_line.
  READ TABLE gt_multiple_hu INTO gs_multi INDEX gv_idx.

ENDMODULE.                 " TRANSP_ITAB_OUT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PGUP_DOWN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pgup_down OUTPUT.

  DATA : lv_v_div  TYPE i,
         lv_v_d    TYPE f,
         lv_v_temp TYPE i.
  DESCRIBE TABLE gt_multiple_hu[] LINES gv_p_num.
  lv_v_d = gv_p_num / 3.
  gv_v_limit = ceil( lv_v_d ).
  lv_v_temp = gv_v_limit - 1.
  IF gv_p_num LE 5.
    PERFORM y_f_hide_field USING 'RLMOB-PPGDN'.
    PERFORM y_f_hide_field USING 'RLMOB-PPGUP'.
  ELSEIF gv_v_next  = gv_v_limit .
    PERFORM y_f_hide_field USING 'RLMOB-PPGDN'.
    PERFORM y_f_show_field USING 'RLMOB-PPGUP'.
  ELSEIF gv_v_prev IS INITIAL.
    PERFORM y_f_hide_field USING 'RLMOB-PPGUP'.
  ELSEIF gv_v_next GT gv_v_limit.
    PERFORM y_f_hide_field USING 'RLMOB-PPGDN'.
  ELSEIF lv_v_temp = gv_v_next.
    PERFORM y_f_hide_field USING 'RLMOB-PPGDN'.
  ENDIF.

ENDMODULE.                 " PGUP_DOWN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.


  DATA : lv_msgid   TYPE char20,
         lv_value   TYPE char20,
         lv_num     TYPE char3,
         ls_message TYPE ts_message.
  SET PF-STATUS '0300'.

  CLEAR : ls_message, lv_msgid, lv_value, lv_num,
          gv_message1, gv_message2, gv_message3, gv_message4,
          gv_message5, gv_message6, gv_message7, gv_message8.

*--Read Parametre message ID
  GET PARAMETER ID text-016 FIELD lv_msgid.
*--Read Parametre message ID
  GET PARAMETER ID text-018 FIELD lv_value.
*--Read Parametre message ID
  GET PARAMETER ID text-017 FIELD lv_num.
  CREATE OBJECT go_hu.
*--Populate error message details
  CALL METHOD go_hu->message_display
    EXPORTING
      lv_id      = lv_msgid
      lv_value   = lv_value
      lv_no      = lv_num
    IMPORTING
      es_message = ls_message.

*--Display message
  gv_message1 = ls_message-message1.
  gv_message2 = ls_message-message2.
  gv_message3 = ls_message-message3.
  gv_message4 = ls_message-message4.
  gv_message5 = ls_message-message5.
  gv_message6 = ls_message-message6.
  gv_message7 = ls_message-message7.
  gv_message8 = ls_message-message8.

ENDMODULE.                 " STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0400 OUTPUT.
  SET PF-STATUS '0400'.

ENDMODULE.                 " STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0500 OUTPUT.
  SET PF-STATUS '0500'.

ENDMODULE.                 " STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0600  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0600 OUTPUT.
  SET PF-STATUS '0600'.


ENDMODULE.                 " STATUS_0600  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0700  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0700 OUTPUT.
  SET PF-STATUS '700'.


ENDMODULE.                 " STATUS_0700  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0900  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0900 OUTPUT.
  SET PF-STATUS '0900'.
*  SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE initialize OUTPUT.
  PERFORM initialize.
ENDMODULE.
