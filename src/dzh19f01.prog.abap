*----------------------------------------------------------------------*
***INCLUDE DZH19O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  Update HU status  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
*--PF status
  SET PF-STATUS '0100'.
*--Title
  SET TITLEBAR '100'.

  IF  gv_zztemp_reco = '0' or gv_zztemp_reco = ' ' . " Uncomment later
    LOOP AT SCREEN .
      IF screen-name EQ 'GV_ZZTEMP_REC_NUMB'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN .
      IF screen-name EQ 'GV_ZZTEMP_REC_NUMB'.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  "End of changes NAHMED1 28.8.2019
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.



  DATA : lv_msgid_d TYPE char20,
         lv_value   TYPE char20,
         lv_num     TYPE char3,
         ls_message TYPE ts_message, "ts_message,
         lo_hu      TYPE REF TO zcl_rfscanner_packunpack.

  SET PF-STATUS '0300'.

  CLEAR : ls_message, lv_msgid_d, lv_value, lv_num,
          gv_message1, gv_message2, gv_message3, gv_message4,
          gv_message5, gv_message6, gv_message7, gv_message8.


*--Read Parametre message ID
  GET PARAMETER ID text-001 FIELD lv_msgid_d.
*--Read Parametre message ID
  GET PARAMETER ID text-003 FIELD lv_value.
*--Read Parametre message ID
  GET PARAMETER ID text-002 FIELD lv_num.


  CREATE OBJECT lo_hu.
*--Populate error message details
  CALL METHOD lo_hu->message_display
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
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS '0200'.
*  SET TITLEBAR 'xxx'.
  CONSTANTS : gc_msgno5 TYPE msgno VALUE '142'.

  "Begin of change NAHMED1 28.8.2019
* Pass the value from the HU to the screen fields
  gv_qa_status = gs_vekp-zzqa_status.
  gv_qa_reason = gs_vekp-zzqareason_code.
  "End of change NAHMED1 28.8.2019

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  VAIDATE_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM vaidate_input .

  DATA : ls_zlqa_status_text TYPE zlqa_status_text .
  DATA : ls_zlqa_reascod_txt TYPE zlqa_reascod_txt.

  CONSTANTS : lc_msgno  TYPE msgno VALUE '001',
              lc_msgno1 TYPE msgno VALUE '139',
              lc_msgno2 TYPE msgno VALUE '140'.

  IF gs_hu-exidv IS INITIAL.
    lv_msgid = gc_msgid.
    lv_msgno = lc_msgno.
    lv_msgv1 = gs_hu-exidv.
    PERFORM error_message USING lv_msgid lv_msgno lv_msgv1.
    CLEAR: gv_hu.
  ENDIF.

  SELECT SINGLE *
      FROM vekp INTO gs_vekp WHERE exidv = gs_hu-exidv.

  IF sy-subrc <> 0."Invalid HU number
    lv_msgid = gc_msgid.
    lv_msgno = lc_msgno.
    lv_msgv1 = gs_hu-exidv.
    PERFORM error_message USING lv_msgid lv_msgno lv_msgv1.
    CLEAR: gv_hu.
  ENDIF.

  CLEAR : ls_zlqa_status_text.
  IF gv_qa_status IS NOT INITIAL.
      gs_vekp-zzqa_status = gv_qa_status.
  ENDIF.


  CLEAR : ls_zlqa_reascod_txt.
  IF gv_qa_reason IS NOT INITIAL.
      gs_vekp-zzqareason_code = gv_qa_reason .
  ENDIF.


ENDFORM.
