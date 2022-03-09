*&---------------------------------------------------------------------*
*&  Include           MZITSEIM_PICKINGI01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  NEW_TRAN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE new_tran INPUT.
  CALL TRANSACTION 'ZMDE'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_OUTB_DELIVERY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_outb_delivery INPUT.
  PERFORM user_command_9001.


  PERFORM check_outb_delivery.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_SCAN_LABEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_scan_label INPUT.
  PERFORM check_label.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_PICKING_QTY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_picking_qty INPUT.
  PERFORM update_picking_qty.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9002 INPUT.
  DATA: lv_okcode TYPE syst-ucomm ##DECL_MODUL ##NEEDED.

  lv_okcode = ok_code.
  CLEAR ok_code.

  CASE lv_okcode.
    WHEN 'ZBACK'.
      CLEAR: zsits_scan_dynp-zzoutb_delivery.

      PERFORM frm_clear_variables.

      CALL FUNCTION 'DEQUEUE_ALL'.

      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  PERFORM user_command_9001.


ENDMODULE.
