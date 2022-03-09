*&---------------------------------------------------------------------*
*&  Include           MZITSEPICKINGI01
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       Exit to either New Transaction screen or Scan Delivery screen
*----------------------------------------------------------------------*
MODULE exit INPUT.
  v_code = ok_code.
  CLEAR ok_code.

  CASE v_code.
    WHEN 'NTRA'.
      PERFORM new_tran.
    WHEN 'BACK'.
      PERFORM new_delivery.
  ENDCASE.
ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9010  INPUT
*&---------------------------------------------------------------------*
*       Users' commands
*----------------------------------------------------------------------*
MODULE user_command_9010 INPUT.
  PERFORM user_command.
ENDMODULE.                 " USER_COMMAND_9010  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       Users' commands
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  PERFORM user_command.
ENDMODULE.                 " USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*&      Module  NEXT_SCREEN  INPUT
*&---------------------------------------------------------------------*
*       Go to screen 9010
*----------------------------------------------------------------------*
MODULE next_screen INPUT.
  PERFORM user_command.
  PERFORM next_screen.
ENDMODULE.                 " NEXT_SCREEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  MATERIAL  INPUT
*&---------------------------------------------------------------------*
*       Scan material
*----------------------------------------------------------------------*
MODULE material INPUT.
  PERFORM material.
ENDMODULE.                 " MATERIAL  INPUT
*&---------------------------------------------------------------------*
*&      Module  SOURCE_BIN  INPUT
*&---------------------------------------------------------------------*
*       Scan source bin
*----------------------------------------------------------------------*
MODULE source_bin INPUT.
  PERFORM source_bin.
ENDMODULE.                 " SOURCE_BIN  INPUT
*&---------------------------------------------------------------------*
*&      Module  QUANTITY  INPUT
*&---------------------------------------------------------------------*
*       Enter/scan quantity
*----------------------------------------------------------------------*
MODULE quantity INPUT.
  PERFORM quantity.
ENDMODULE.                 " QUANTITY  INPUT
*&---------------------------------------------------------------------*
*&      Module  TO_CONFIRM  INPUT
*&---------------------------------------------------------------------*
*       Confirm TO item
*----------------------------------------------------------------------*
MODULE to_confirm INPUT.
  PERFORM to_confirm.
ENDMODULE.                 " TO_CONFIRM  INPUT
