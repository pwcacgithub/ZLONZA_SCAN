FUNCTION zcfe_message_display.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LINE_SIZE) TYPE  I DEFAULT 40
*"     REFERENCE(IV_LINES) TYPE  I DEFAULT 5
*"     REFERENCE(IV_FOR_CONFIRM) TYPE  XFELD DEFAULT ' '
*"  EXPORTING
*"     REFERENCE(EV_CONFIRM_RESULT) TYPE  CHAR01
*"----------------------------------------------------------------------
  DATA:
        lv_line_in            LIKE sprot-line,
        lv_line_out           LIKE sprot-line,
        lv_field_name         LIKE dd03d-fieldname,
        lv_message_length     TYPE i,
        lv_line_count         TYPE i VALUE 1,
        lv_line_count_c(2)    TYPE c,
        lv_mess_pos           TYPE i VALUE 0,
        lv_line_pos           TYPE i,
        lv_from_pos           TYPE i,
        lv_length             TYPE i,
        lv_test_char(1)       TYPE c,
        lv_line_offset        TYPE i,
        ls_msg_text           TYPE t100.

  FIELD-SYMBOLS:
                 <fs_mess_field>.

  CLEAR gv_confirm_result.

  gv_confirm_ind = iv_for_confirm.

  CLEAR:zsits_scan_message,gs_message.

  MOVE: sy-msgid TO zsits_scan_message-zzmsg_id,
        sy-msgno TO zsits_scan_message-zzmsg_no.

  SELECT SINGLE * FROM t100 INTO ls_msg_text
        WHERE  sprsl   =  sy-langu
        AND    arbgb   =  sy-msgid
        AND    msgnr   =  sy-msgno.

  MOVE ls_msg_text-text TO lv_line_in.

* insert message variables
  CALL FUNCTION 'TRINT_PUT_VARS_INTO_LINE'
    EXPORTING
      iv_line          = lv_line_in
      iv_var1          = sy-msgv1
      iv_var2          = sy-msgv2
      iv_var3          = sy-msgv3
      iv_var4          = sy-msgv4
    IMPORTING
      ev_line          = lv_line_out.

  lv_message_length  =  strlen( lv_line_out ).

* split message text into lines.........................................
  lv_line_offset = iv_line_size - 1.

  WHILE lv_line_count <= iv_lines AND lv_mess_pos < lv_message_length.

    lv_line_count_c = lv_line_count.
    CONCATENATE 'gs_message-message' lv_line_count_c INTO lv_field_name.
    ASSIGN (lv_field_name) TO <fs_mess_field>.
    lv_line_pos = 0.

    WHILE lv_line_pos < iv_line_size AND lv_mess_pos < lv_message_length.

      <fs_mess_field>+lv_line_pos(1) = lv_line_out+lv_mess_pos(1).

      lv_line_pos = lv_line_pos + 1.
      lv_mess_pos = lv_mess_pos + 1.

    ENDWHILE.

    IF  lv_mess_pos < lv_message_length.

      lv_test_char = 'X'.

      WHILE ( NOT ( lv_test_char IS INITIAL ) ) AND  ( lv_line_pos > 0 ).

        lv_line_pos = lv_line_pos - 1.
        lv_mess_pos = lv_mess_pos - 1.
        lv_test_char = <fs_mess_field>+lv_line_pos(1).

      ENDWHILE.

      IF lv_line_pos > 0 AND lv_line_pos < lv_line_offset.

        CLEAR <fs_mess_field>.
        lv_from_pos = lv_mess_pos - lv_line_pos.
        lv_length   = lv_line_pos + 1.
        <fs_mess_field> =  lv_line_out+lv_from_pos(lv_length).

      ELSEIF lv_line_pos = 0.
        lv_mess_pos = lv_mess_pos + lv_line_offset.
      ENDIF.
      lv_mess_pos = lv_mess_pos + 1.

      IF NOT ( <fs_mess_field> IS INITIAL ).
        lv_line_count = lv_line_count + 1.
      ENDIF.

    ENDIF.
  ENDWHILE.

  CALL SCREEN 100.

  ev_confirm_result = gv_confirm_result.

ENDFUNCTION.
