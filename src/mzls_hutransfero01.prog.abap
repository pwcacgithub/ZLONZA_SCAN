*----------------------------------------------------------------------*
***INCLUDE MZLMHUGR001O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  INITIALIZE_LOG  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INITIALIZE_LOG OUTPUT.
  IF o_log IS INITIAL.
    CREATE OBJECT o_log
      EXPORTING
        iv_scan_code = sy-tcode.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
  SET PF-STATUS '9000'.
*  SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9002  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9002 OUTPUT.
  SET PF-STATUS 'PGR'.
*  SET TITLEBAR ''.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9001 OUTPUT.
  SET PF-STATUS 'PGI'.
*  SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9003  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9003 OUTPUT.
  DATA : lv_msgid_d TYPE char20,
         lv_value   TYPE char20,
         lv_num     TYPE char3,
         ls_message TYPE ts_message.

  SET PF-STATUS '9003'.
*  SET TITLEBAR 'xxx'.
  CLEAR : ls_message, lv_msgid_d, lv_value, lv_num,
          gv_message1, gv_message2, gv_message3, gv_message4,
          gv_message5, gv_message6, gv_message7, gv_message8.
*--Read Parameter message ID
  GET PARAMETER ID text-001 FIELD lv_msgid_d.
*--Read Parameter message ID
  GET PARAMETER ID text-003 FIELD lv_value.
*--Read Parameter message ID
  GET PARAMETER ID text-002 FIELD lv_num.

*--Populate error message details
  CALL METHOD go_hu->message_display
    EXPORTING
      lv_id      = lv_msgid_d
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

ENDMODULE.
