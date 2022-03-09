*&---------------------------------------------------------------------*
*&  Include           DZH01O01
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

 DATA : lv_tabix TYPE sy-tabix.
*--PF status of 200
  SET PF-STATUS '0200'.

  CLEAR lv_tabix.
  CLEAR : gv_exidv1, gv_exidv2, gv_exidv3,
          gv_vhilm1, gv_vhilm2, gv_vhilm3,
          gv_ch1, gv_ch2, gv_ch3.

*---Read the values before screen display and populate accordingly on index based
  IF sy-ucomm NE gc_pgup AND sy-ucomm NE gc_pgdn AND sy-ucomm NE gc_ch1
    AND sy-ucomm NE gc_ch2 AND  sy-ucomm NE gc_ch3.

    CLEAR : gt_exidv.
    LOOP AT gt_final ASSIGNING FIELD-SYMBOL(<lfs_final>).
      ADD 1 TO lv_tabix.
      IF lv_tabix GT 3.
        lv_tabix =  1.
      ENDIF.
      CASE lv_tabix.
        WHEN 1.
          APPEND INITIAL LINE TO gt_exidv ASSIGNING FIELD-SYMBOL(<lfs_exidv>).
          <lfs_exidv>-checkbox1 = <lfs_final>-checkbox.
          <lfs_exidv>-exidv1 = <lfs_final>-exidv.
        WHEN 2.
          DESCRIBE TABLE gt_exidv LINES DATA(lv_lines).
          READ TABLE gt_exidv ASSIGNING <lfs_exidv> INDEX lv_lines.
          IF sy-subrc EQ 0.
            <lfs_exidv>-checkbox2 = <lfs_final>-checkbox.
            <lfs_exidv>-exidv2 = <lfs_final>-exidv.
          ENDIF.
        WHEN 3.
          DESCRIBE TABLE gt_exidv LINES lv_lines.
          READ TABLE gt_exidv ASSIGNING <lfs_exidv> INDEX lv_lines.
          IF sy-subrc EQ 0.
            <lfs_exidv>-checkbox3 = <lfs_final>-checkbox.
            <lfs_exidv>-exidv3 = <lfs_final>-exidv.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDIF.

*--Increament the index value below condition not sasified.
IF sy-ucomm EQ gc_pgup OR sy-ucomm = gc_pgdn OR sy-ucomm = gc_ch1
    OR sy-ucomm = gc_ch2 OR  sy-ucomm = gc_ch3.
  ELSE.
    DESCRIBE TABLE gt_exidv LINES lv_lines.
    gv_index = lv_lines.
  ENDIF.

*--Initially index value is zero
  IF gv_index = 0.
    gv_index = 1.
  ENDIF.

*--Read screen value from Index to populate
  READ TABLE gt_exidv ASSIGNING <lfs_exidv> INDEX gv_index.
  IF sy-subrc EQ 0.
    gv_exidv1 = <lfs_exidv>-exidv1.
    gv_exidv2 = <lfs_exidv>-exidv2.
    gv_exidv3 = <lfs_exidv>-exidv3.

*--First HU read
    READ TABLE gt_final ASSIGNING <lfs_final> WITH KEY exidv = gv_exidv1.
    IF sy-subrc EQ 0.
      gv_ch1     = <lfs_final>-checkbox.
      gv_vhilm1  = <lfs_final>-vhilm.
*--Convert HU without leading zero's
     PERFORM convert_removezeros USING    <lfs_final>-exidv
                                CHANGING gv_exidv1.
    ENDIF.

*--Second HU details populate
    READ TABLE gt_final ASSIGNING <lfs_final> WITH KEY exidv = gv_exidv2.
    IF sy-subrc EQ 0.
*--Convert HU without leading zero's
     PERFORM convert_removezeros USING    <lfs_final>-exidv
                                CHANGING gv_exidv2.
      gv_ch2     = <lfs_final>-checkbox.
      gv_vhilm2  = <lfs_final>-vhilm.
    ENDIF.

*--Third HU details populate
    READ TABLE gt_final ASSIGNING <lfs_final> WITH KEY exidv = gv_exidv3.
    IF sy-subrc EQ 0.
*--Convert HU without leading zero's
     PERFORM convert_removezeros USING    <lfs_final>-exidv
                                CHANGING gv_exidv3.
       gv_ch3     = <lfs_final>-checkbox.
       gv_vhilm3  = <lfs_final>-vhilm.
    ENDIF.
  ENDIF.
ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.

DATA : lv_msgid    TYPE char20,
       lv_value    TYPE char20,
       lv_num      TYPE char3,
       ls_message  TYPE ts_message.

  SET PF-STATUS '0300'.

  CLEAR : ls_message, lv_msgid, lv_value, lv_num,
          gv_message1, gv_message2, gv_message3, gv_message4,
          gv_message5, gv_message6, gv_message7, gv_message8.

*--Read Parametre message ID
  GET PARAMETER ID text-016 FIELD lv_msgid.
*--Read Parametre message ID
  GET PARAMETER ID text-018 FIELD lv_value.
*--Read Parametre message ID
  GET PARAMETER ID text-017 FIELD lv_num.

*--Populate error message details
 CALL METHOD go_hu->message_display
   EXPORTING
     lv_id      = lv_msgid
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
