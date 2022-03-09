*&---------------------------------------------------------------------*
*&  Include           DZH09O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
*--PF status
  SET PF-STATUS '0100'.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       Set PF status
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
* Set the screen status for 200
  SET PF-STATUS '0200'.
ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_MESSAGE  OUTPUT
*&---------------------------------------------------------------------*
*       Set screen message
*----------------------------------------------------------------------*
MODULE set_screen_message OUTPUT.
*Prompt the user to confirm if the user wants to continue
*with the deletion of HU
  IF gv_unpack EQ abap_true.
    gv_msg1 = text-008.
    gv_msg2 = text-010.
  ELSE.
    gv_msg1 = text-008.
    gv_msg2 = text-009.
  ENDIF.

ENDMODULE.                 " SET_SCREEN_MESSAGE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.

  CLEAR gs_message.
*To get the formatted error message
  PERFORM message_display CHANGING gs_message.


  CLEAR:gv_message1,gv_message2,gv_message3,gv_message4,
        gv_message5,gv_message6,gv_message7,gv_message8.


*To pass the screen data
  gv_message1 = gs_message-message1.
  gv_message2 = gs_message-message2.
  gv_message3 = gs_message-message3.
  gv_message4 = gs_message-message4.
  gv_message5 = gs_message-message5.
  gv_message6 = gs_message-message6.
  gv_message7 = gs_message-message7.
  gv_message8 = gs_message-message8.


ENDMODULE.                 " STATUS_0300  OUTPUT
