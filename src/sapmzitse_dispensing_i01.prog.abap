*&---------------------------------------------------------------------*
*&  Include           ZITSEE0301_DISPENSING_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

MODULE user_command_9100 INPUT.

  CLEAR:v_flag,v_create_to,v_barcode,v_label_type,wa_label_content,
        wa_material_data,wa_vepo,v_lgnum,v_hu_status_init,wa_lein,wa_t340d,
        wa_label_type,it_label_type,v_subrc.

  v_code = sy-ucomm.

  CASE v_code.
    WHEN 'OKAY' or 'NEW_TRANS' .
      PERFORM process1. " quantity and barcode
      LEAVE TO SCREEN 9200.

  WHEN 'BACK'.
    CALL TRANSACTION 'ZSCAN_SUBDIVHU'.
  WHEN 'BACK1'.
    CALL TRANSACTION 'ZSCAN_SUBDIVHU'.
  WHEN OTHERS.
ENDCASE.


  CLEAR:v_code.

ENDMODULE.                 " USER_COMMAND_9100  INPUT
MODULE user_command_9200 INPUT.

  REFRESH:it_desthu,
          it_reprocess.

  CLEAR:v_flag,v_flag_tmp,v_qty,v_difference,v_move_original_su,v_vhilm,
        v_lenum,v_log_handler,wa_move_su,v_mtart.

  v_code = sy-ucomm.

  CASE v_code.
    WHEN 'BACK'.
      CALL SCREEN 9100.
    WHEN 'OKAY' or 'NEW_TRANS'.
      PERFORM process2.
      LEAVE TO SCREEN 9300.
  WHEN 'BACK1'.
    CALL TRANSACTION 'ZSCAN_SUBDIVHU'.

  WHEN OTHERS.
ENDCASE.

CLEAR:v_code.

ENDMODULE.                 " USER_COMMAND_9200  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'CONTAINER001'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE container001_modify INPUT.
  MODIFY it_container
    FROM zsits_scan_repack_input
    INDEX container001-current_line.
ENDMODULE.                    "CONTAINER001_MODIFY INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'CONTAINER001'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE container001_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'CONTAINER001'
                              'IT_CONTAINER'
                              ' '
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "CONTAINER001_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9300 INPUT.

  CLEAR:v_flag,
        v_code.
  v_code = sy-ucomm.

  CASE v_code.
    WHEN 'NEW_TRANS'.
      CALL TRANSACTION 'ZMDE'.
    WHEN 'BACK'.
      v_clear = abap_true.
      LEAVE TO SCREEN 9100.
    WHEN 'BACK1'.
      CALL TRANSACTION 'ZSCAN_SUBDIVHU'.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_9300  INPUT


MODULE user_command_9400 INPUT.

  CLEAR:v_flag,v_create_to,v_barcode,v_label_type,wa_label_content,
        wa_material_data,wa_vepo,v_lgnum,v_hu_status_init,wa_lein,wa_t340d,
        wa_label_type,it_label_type,v_subrc,
*  Begin of insert rvenugopal : EICR 573542
        v_qty.
*  End of insert rvenugopal : EICR 573542

  v_code = sy-ucomm.

  CASE v_code.
    WHEN 'OKAY' or 'PROC'.
      PERFORM process1.
      PERFORM process2.


  WHEN 'BACK'.
    CALL TRANSACTION 'ZSCAN_SUBDIVHU'.
  WHEN 'BACK1'.
    CALL TRANSACTION 'ZSCAN_SUBDIVHU'.
  WHEN OTHERS.
ENDCASE.

CLEAR:v_code.
ENDMODULE.                 " USER_COMMAND_9400  INPUT


*&SPWIZARD: INPUT MODULE FOR TC 'CONTAINER002'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE container002_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'CONTAINER002'
                              'IT_DESTHU'
                              ' '
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "CONTAINER002_USER_COMMAND INPUT

*&---------------------------------------------------------------------*
*&      Module  CLEAR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear INPUT.
  CLEAR: gv_qty1, gv_qty2, gv_qty3, gv_qty4, gv_qty5.
ENDMODULE.                 " CLEAR  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_data INPUT.

  LOOP AT it_container ASSIGNING FIELD-SYMBOL(<lfs>).
    CASE sy-tabix.
      WHEN '1'.
        <lfs>-quantity = gv_qty1.
      WHEN '2'.
        <lfs>-quantity = gv_qty2.
      WHEN '3'.
        <lfs>-quantity = gv_qty3.
      WHEN '4'.
        <lfs>-quantity = gv_qty4.
      WHEN '5'.
        <lfs>-quantity = gv_qty5.
      WHEN OTHERS.
    ENDCASE.
    CLEAR: ls_cont.
  ENDLOOP.

  CLEAR: gv_qty1, gv_qty2, gv_qty3, gv_qty4, gv_qty5.
ENDMODULE.                 " MODIFY_DATA  INPUT
