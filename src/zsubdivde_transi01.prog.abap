*&---------------------------------------------------------------------*
*&  Include           ZSUBDIVDE_TRANSI01
*&---------------------------------------------------------------------*
MODULE user_command_9500 INPUT.
  CASE sy-ucomm.
    WHEN 'ZCONS'.
      CALL TRANSACTION 'ZSAMPL_CONSUMED'.
    WHEN 'ZDISP'.
      CALL TRANSACTION 'ZSUBDIV'.
    WHEN 'ZEXIT'.
      CALL TRANSACTION 'ZMDE'.
    WHEN OTHERS.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
