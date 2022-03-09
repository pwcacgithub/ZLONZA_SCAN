*&---------------------------------------------------------------------*
*&  Include           DZH07O01
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
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

*--PF status of 200
  SET PF-STATUS '0200'.

ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  DATA : lv_msgid_d TYPE char20,
         lv_value   TYPE char20,
         lv_num     TYPE char3,
         ls_message TYPE ts_message.

  SET PF-STATUS '0300'.

  CLEAR : ls_message, lv_msgid_d, lv_value, lv_num, gv_error3, gv_error1,
          gv_message1, gv_message2, gv_message3, gv_message4,
          gv_message5, gv_message6, gv_message7, gv_message8.


*--Read Parametre message ID
  GET PARAMETER ID text-001 FIELD lv_msgid_d.
*--Read Parametre message ID
  GET PARAMETER ID text-003 FIELD lv_value.
*--Read Parametre message ID
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

ENDMODULE.                 " STATUS_0300  OUTPUT
