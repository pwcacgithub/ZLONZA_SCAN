*----------------------------------------------------------------------*
***INCLUDE ZMTD_SCAN_E0322_SUTBIN_PAI .
*----------------------------------------------------------------------*
***********************************************************************
* VERSION CONTROL (Most recent on top):
* DATE             AUTHOR       CTS REQ        DESCRIPTION
*----------------------------------------------------------------------

***********************************************************************

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.

  CASE ok_code.
    WHEN zcl_its_utility=>gc_okcode_back.
      PERFORM frm_new_tran.
*      SET SCREEN 0.
*      LEAVE SCREEN.

    WHEN 'NEXT'.
      PERFORM next_screen.

    WHEN 'ENTR'.
      PERFORM next_screen.

    WHEN 'CLEAR'.
      PERFORM clear_all.

  ENDCASE.

  CLEAR ok_code.
ENDMODULE.                 " USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9010 INPUT.
  CASE ok_code.
    WHEN zcl_its_utility=>gc_okcode_back.
      PERFORM clear_all.
      SET SCREEN 9000.
      LEAVE SCREEN.

**    WHEN zcl_its_utility=>gc_okcode_next.
**      PERFORM add_su.

    WHEN zcl_its_utility=>gc_okcode_save.
      PERFORM create_to.

    WHEN 'CLEAR'.
      PERFORM clear_su.
    WHEN 'P-'.
*--Decrement the counter
       gv_index = gv_index - 1.

*--Page Down
    WHEN 'P+'.
*--Increment the counter
     gv_index = gv_index + 1.
    WHEN OTHERS.
*    WHEN 'P--' OR 'P-' OR 'P+' OR 'P++'.
*      PERFORM table_scroll.
  ENDCASE.

  CLEAR ok_code.
ENDMODULE.                 " USER_COMMAND_9010  INPUT
*&---------------------------------------------------------------------*
*&      Module  NEW_TRAN  INPUT
*&---------------------------------------------------------------------*
MODULE new_tran INPUT.

  CASE ok_code.

*    WHEN zcl_its_utility=>gc_okcode_newtran.
    WHEN 'NTRA'.
      PERFORM frm_new_tran.

    WHEN 'CLEAR'.
      PERFORM clear_su.

  ENDCASE.

ENDMODULE.                 " NEW_TRAN  INPUT
*&---------------------------------------------------------------------*
*&      Module  NEXT_SCREEN  INPUT
*&---------------------------------------------------------------------*
*       Move to next screen
*----------------------------------------------------------------------*
MODULE next_screen INPUT.

  CHECK ok_code = 'NEXT'
   OR   ok_code = 'ENTR'.
* Check the destination bin entered
  PERFORM check_dest_bin.
ENDMODULE.                 " NEXT_SCREEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_BARCODE  INPUT
*&---------------------------------------------------------------------*
*       Read barcode
*----------------------------------------------------------------------*
MODULE read_barcode INPUT.

  PERFORM read_barcode.

  PERFORM add_su.
ENDMODULE.                 " READ_BARCODE  INPUT
