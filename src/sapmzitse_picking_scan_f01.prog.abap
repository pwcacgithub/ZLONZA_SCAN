*&---------------------------------------------------------------------*
*&  Include           SAPMZITSE_PICKING_SCAN_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  INITIAL_LOGON_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initial_logon_data .

  IF or_log IS INITIAL.
    CREATE OBJECT or_log
      EXPORTING
        iv_scan_code = sy-tcode.
  ENDIF.

ENDFORM.                    " INITIAL_LOGON_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_USER_PROFILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_user_profile .

  IF wa_user_profile IS INITIAL.
    CALL METHOD zcl_its_utility=>get_user_profile
      RECEIVING
        rs_user_profile = wa_user_profile.
  ENDIF.

ENDFORM.                    " GET_USER_PROFILE
*&---------------------------------------------------------------------*
*&      Form  ADD_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZCL_ITS_UTILITY=>GC_OBJID_LABE  text
*      -->P_LTAK_TANUM  text
*      -->P_ABAP_TRUE  text
*----------------------------------------------------------------------*
FORM add_message  USING uv_objid   TYPE zzscan_objid
                        uv_content TYPE any
                        uv_err_fg  TYPE boolean.

  CALL METHOD or_log->log_message_add
    EXPORTING
      iv_object_id    = uv_objid
      iv_content      = uv_content
      iv_with_message = uv_err_fg.

  IF uv_err_fg = abap_true.
*-----Display error message
    CALL METHOD zcl_its_utility=>message_display( ).
  ENDIF.

ENDFORM.                    " ADD_MESSAGE

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_insert_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_lines_name       LIKE feld-name.
  DATA l_selline          LIKE sy-stepl.
  DATA l_lastline         TYPE i ##needed.
  DATA l_line             TYPE i.
  DATA l_table_name       LIKE feld-name.
  FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
  FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <lines>              TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
  ASSIGN (l_lines_name) TO <lines>.

*&SPWIZARD: get current line                                           *
  GET CURSOR LINE l_selline.
  IF sy-subrc <> 0.                   " append line to table
    l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line                                               *
    IF l_selline > <lines>.
      <tc>-top_line = l_selline - <lines> + 1 .
    ELSE.
      <tc>-top_line = 1.
    ENDIF.
  ELSE.                               " insert line into table
    l_selline = <tc>-top_line + l_selline - 1.
    l_lastline = <tc>-top_line + <lines> - 1.
  ENDIF.
*&SPWIZARD: set new cursor line                                        *
  l_line = l_selline - <tc>-top_line + 1.

*&SPWIZARD: insert initial line                                        *
  INSERT INITIAL LINE INTO <table> INDEX l_selline.
  <tc>-lines = <tc>-lines + 1.
*&SPWIZARD: set cursor                                                 *
  SET CURSOR LINE l_line.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name
                       p_mark_name   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    IF <mark_field> = 'X'.
      DELETE <table> INDEX syst-tabix.
      IF sy-subrc = 0.
        <tc>-lines = <tc>-lines - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM compute_scrolling_in_tc USING    p_tc_name
                                      p_ok.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_tc_new_top_line     TYPE i.
  DATA l_tc_name             LIKE feld-name.
  DATA l_tc_lines_name       LIKE feld-name.
  DATA l_tc_field_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <lines>      TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.
*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
  ASSIGN (l_tc_lines_name) TO <lines>.


*&SPWIZARD: is no line filled?                                         *
  IF <tc>-lines = 0.
*&SPWIZARD: yes, ...                                                   *
    l_tc_new_top_line = 1.
  ELSE.
*&SPWIZARD: no, ...                                                    *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        entry_act             = <tc>-top_line
        entry_from            = 1
        entry_to              = <tc>-lines
        last_page_full        = 'X'
        loops                 = <lines>
        ok_code               = p_ok
        overlapping           = 'X'
      IMPORTING
        entry_new             = l_tc_new_top_line
      EXCEPTIONS
        OTHERS                = 0.
  ENDIF.

*&SPWIZARD: get actual tc and column                                   *
  GET CURSOR FIELD l_tc_field_name
             AREA  l_tc_name.

  IF syst-subrc = 0.
    IF l_tc_name = p_tc_name.
*&SPWIZARD: et actual column                                           *
      SET CURSOR FIELD l_tc_field_name LINE 1.
    ENDIF.
  ENDIF.

*&SPWIZARD: set the new top line                                       *
  <tc>-top_line = l_tc_new_top_line.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_mark_lines USING p_tc_name
                               p_table_name
                               p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_demark_lines USING p_tc_name
                                 p_table_name
                                 p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = space.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  CONVERT_SU_NUMBER_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_V_LENUM_TMP  text
*----------------------------------------------------------------------*
FORM convert_su_number_output  CHANGING cv_lenum TYPE lenum.

  CALL FUNCTION 'CONVERSION_EXIT_LENUM_OUTPUT'
    EXPORTING
      input           = cv_lenum
    IMPORTING
      output          = cv_lenum
    EXCEPTIONS
      ##fm_subrc_ok
      t344_get_failed = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.                    " CONVERT_SU_NUMBER_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  CONVERT_SU_NUMBER_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_V_LENUM_INPUT  text
*----------------------------------------------------------------------*
FORM convert_su_number_input  CHANGING cv_lenum TYPE lenum.

  CALL FUNCTION 'CONVERSION_EXIT_LENUM_INPUT'
    EXPORTING
      input           = cv_lenum
    IMPORTING
      output          = cv_lenum
    EXCEPTIONS
      ##fm_subrc_ok
      check_failed    = 1
      not_numeric     = 2
      t344_get_failed = 3
      wrong_length    = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.                    " CONVERT_SU_NUMBER_INPUT
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_TRANSFER_ORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_LENUM  text
*      -->P_LT_LTAP_CONF  text
*      <--P_V_FLAG  text
*----------------------------------------------------------------------*
FORM confirm_transfer_order  USING    uv_lgnum        TYPE lgnum
                                      uv_tanum        TYPE tanum
                                      ut_ltap_conf    TYPE pdt_t_ltap_conf
                                      ut_ltap_conf_hu TYPE pdt_t_ltap_conf_hu
                             CHANGING cv_flag         TYPE c.

  CALL FUNCTION 'L_TO_CONFIRM'
    EXPORTING
      i_lgnum                        = uv_lgnum
      i_tanum                        = uv_tanum
      i_commit_work                  = abap_false
    TABLES
      t_ltap_conf                    = ut_ltap_conf
      t_ltap_conf_hu                 = ut_ltap_conf_hu
    EXCEPTIONS
      to_confirmed                   = 1
      to_doesnt_exist                = 2
      item_confirmed                 = 3
      item_subsystem                 = 4
      item_doesnt_exist              = 5
      item_without_zero_stock_check  = 6
      item_with_zero_stock_check     = 7
      one_item_with_zero_stock_check = 8
      item_su_bulk_storage           = 9
      item_no_su_bulk_storage        = 10
      one_item_su_bulk_storage       = 11
      foreign_lock                   = 12
      squit_or_quantities            = 13
      vquit_or_quantities            = 14
      bquit_or_quantities            = 15
      quantity_wrong                 = 16
      double_lines                   = 17
      kzdif_wrong                    = 18
      no_difference                  = 19
      no_negative_quantities         = 20
      wrong_zero_stock_check         = 21
      su_not_found                   = 22
      no_stock_on_su                 = 23
      su_wrong                       = 24
      too_many_su                    = 25
      nothing_to_do                  = 26
      no_unit_of_measure             = 27
      xfeld_wrong                    = 28
      update_without_commit          = 29
      no_authority                   = 30
      lqnum_missing                  = 31
      charg_missing                  = 32
      no_sobkz                       = 33
      no_charg                       = 34
      nlpla_wrong                    = 35
      two_step_confirmation_required = 36
      two_step_conf_not_allowed      = 37
      pick_confirmation_missing      = 38
      quknz_wrong                    = 39
      hu_data_wrong                  = 40
      no_hu_data_required            = 41
      hu_data_missing                = 42
      hu_not_found                   = 43
      picking_of_hu_not_possible     = 44
      not_enough_stock_in_hu         = 45
      serial_number_data_wrong       = 46
      serial_numbers_not_required    = 47
      no_differences_allowed         = 48
      serial_number_not_available    = 49
      serial_number_data_missing     = 50
      to_item_split_not_allowed      = 51
      input_wrong                    = 52
      error_message                  = 53
      OTHERS                         = 54.
  IF sy-subrc <> 0.
    cv_flag = abap_true.
  ENDIF.


ENDFORM.                    " CONFIRM_TRANSFER_ORDER
*&---------------------------------------------------------------------*
*&      Form  CONVERT_TO_NUMBER_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_V_TANUM  text
*----------------------------------------------------------------------*
FORM convert_to_number_input  CHANGING cv_tanum TYPE tanum.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = cv_tanum
    IMPORTING
      output = cv_tanum.

ENDFORM.                    " CONVERT_TO_NUMBER_INPUT
*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM authority_check CHANGING cv_flag TYPE char1.

  DATA:lv_subrc TYPE sy-subrc.

  CALL METHOD zcl_its_utility=>authority_check_dfs
    RECEIVING
      rv_subrc = lv_subrc.
  IF lv_subrc <> 0.
    cv_flag = abap_true.
    CALL METHOD zcl_its_utility=>message_display( ).
  ENDIF.

ENDFORM.                    " AUTHORITY_CHECK
