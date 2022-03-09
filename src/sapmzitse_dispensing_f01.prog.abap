*&---------------------------------------------------------------------*
*&  Include           ZITSEE0301_DISPENSING_F01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
 FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                          p_table_name
                          p_mark_name
                 CHANGING p_ok      LIKE sy-ucomm.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA: l_ok     TYPE sy-ucomm,
         l_offset TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
   SEARCH p_ok FOR p_tc_name.
   IF sy-subrc <> 0.
     EXIT.
   ENDIF.
   l_offset = strlen( p_tc_name ) + 1.
   l_ok = p_ok+l_offset.
*&SPWIZARD: execute general and TC specific operations                 *
   CASE l_ok.
     WHEN 'INSR'.                      "insert row
       PERFORM fcode_insert_row USING    p_tc_name
                                         p_table_name.
       CLEAR p_ok.

     WHEN 'DELE'.                      "delete row
       PERFORM fcode_delete_row USING    p_tc_name
                                         p_table_name
                                         p_mark_name.
       CLEAR p_ok.

     WHEN 'P--' OR                     "top of list
          'P-'  OR                     "previous page
          'P+'  OR                     "next page
          'P++'.                       "bottom of list
       PERFORM compute_scrolling_in_tc USING p_tc_name
                                             l_ok.
       CLEAR p_ok.
*
     WHEN 'MARK'.                      "mark all filled lines
       PERFORM fcode_tc_mark_lines USING p_tc_name
                                         p_table_name
                                         p_mark_name   .
       CLEAR p_ok.

     WHEN 'DMRK'.                      "demark all filled lines
       PERFORM fcode_tc_demark_lines USING p_tc_name
                                           p_table_name
                                           p_mark_name .
       CLEAR p_ok.

   ENDCASE.

 ENDFORM.                              " USER_OK_TC

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
         entry_act      = <tc>-top_line
         entry_from     = 1
         entry_to       = <tc>-lines
         last_page_full = 'X'
         loops          = <lines>
         ok_code        = p_ok
         overlapping    = 'X'
       IMPORTING
         entry_new      = l_tc_new_top_line
       EXCEPTIONS
         OTHERS         = 0.
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
*&      Form  CONVERT_MATERIAL_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_WA_HEADERPROPOSAL_PACK_MAT  text
*----------------------------------------------------------------------*
 FORM convert_material_input CHANGING cv_matnr TYPE matnr.

   CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
     EXPORTING
       input        = cv_matnr
     IMPORTING
       output       = cv_matnr
     EXCEPTIONS
       ##fm_subrc_ok
       length_error = 1
       OTHERS       = 2.
   IF sy-subrc <> 0.
   ENDIF.

 ENDFORM.                    " CONVERT_MATERIAL_INPUT
*&---------------------------------------------------------------------*
*&      Form  CONVERT_HUNUMBER_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_WA_DESTHU_EXIDV  text
*----------------------------------------------------------------------*
 FORM convert_hunumber_output CHANGING cv_exidv TYPE exidv.

   CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
     EXPORTING
       input  = cv_exidv
     IMPORTING
       output = cv_exidv.

 ENDFORM.                    " CONVERT_HUNUMBER_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  INITIAL_LOGON_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM initial_logon_data.

   IF or_log IS INITIAL.
     CREATE OBJECT or_log
       EXPORTING
         iv_scan_code = sy-tcode.
   ENDIF.

 ENDFORM.                    " INITIAL_LOGON_DATA
*&---------------------------------------------------------------------*
*&      Form  CONVERT_HUNUMBER_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_EXIDV  text
*----------------------------------------------------------------------*
 FORM convert_hunumber_input CHANGING cv_exidv TYPE exidv.

   CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
     EXPORTING
       input  = cv_exidv
     IMPORTING
       output = cv_exidv.

 ENDFORM.                    " CONVERT_HUNUMBER_INPUT
*&---------------------------------------------------------------------*
*&      Form  ADD_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZCL_ITS_UTILITY=>GC_OBJID_LABE  text
*      -->P_GV_BARCODE  text
*      -->P_GV_ERR_FG  text
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
*&---------------------------------------------------------------------*
*&      Form  CREATE_TO_MOVE_SU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_LENUM  text
*      -->P_GV_BWLVS  text
*      -->P_GV_NLTYP  text
*      -->P_GV_NLBER  text
*      -->P_GV_NLPLA  text
*      <--P_GV_FLAG  text
*----------------------------------------------------------------------*
 FORM create_to_move_su  USING    uv_lenum TYPE lein-lenum
                                  uv_bwlvs TYPE ltak-bwlvs
                                  uv_nltyp TYPE ltap-nltyp
                                  uv_nlpla TYPE ltap-nlpla
                         CHANGING cv_flag  TYPE c.

   CALL FUNCTION 'L_TO_CREATE_MOVE_SU'
     EXPORTING
       i_lenum               = uv_lenum
       i_bwlvs               = uv_bwlvs
       i_nltyp               = uv_nltyp
       i_nlpla               = uv_nlpla
       i_squit               = abap_true
       i_commit_work         = abap_true
     EXCEPTIONS
       not_confirmed_to      = 1
       foreign_lock          = 2
       bwlvs_wrong           = 3
       betyp_wrong           = 4
       nltyp_wrong           = 5
       nlpla_wrong           = 6
       nltyp_missing         = 7
       nlpla_missing         = 8
       squit_forbidden       = 9
       lgber_wrong           = 10
       xfeld_wrong           = 11
       drukz_wrong           = 12
       ldest_wrong           = 13
       no_stock_on_su        = 14
       su_not_found          = 15
       update_without_commit = 16
       no_authority          = 17
       benum_required        = 18
       ltap_move_su_wrong    = 19
       lenum_wrong           = 20
       error_message         = 21
       OTHERS                = 22.
   IF sy-subrc <> 0.
     cv_flag = abap_true.
   ENDIF.

 ENDFORM.                    " CREATE_TO_MOVE_SU


 FORM process1.
*   *Check the field number and HU number
   IF zsits_scan_repack_barcode-quantity = space.
     v_flag = abap_true.
     MESSAGE e001(zitsus) INTO v_dummy.
*Because it is the first step in the tcode and in this step we don't have
*barcode, so we just display the error message and don't need to log the
*error message
     CALL METHOD zcl_its_utility=>message_display( ).
   ELSEIF zsits_scan_repack_barcode-zzbarcode = space.
     v_flag = abap_true.
     MESSAGE e002(zitsus) INTO v_dummy.
     CALL METHOD zcl_its_utility=>message_display( ).
   ELSE.
*Authority Check
     CALL METHOD zcl_its_utility=>authority_check_dfs
       RECEIVING
         rv_subrc = v_subrc.
     IF v_subrc <> 0.
       v_flag = abap_true.
       PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                 v_barcode
                                 abap_true.
     ENDIF.


     CHECK v_flag = abap_false.
*Call method to read barcode
     v_barcode = zsits_scan_repack_barcode-zzbarcode.
     wa_label_type-sign = 'I'.
     wa_label_type-zoption = 'EQ'.
     wa_label_type-low    = zcl_its_utility=>gc_label_hu.    "Handling Unit Label
     APPEND wa_label_type TO it_label_type.


*-- Seggrigate the Batch & Material Number from the Barcode
     CALL METHOD zcl_mde_barcode=>disolve_barcode
       EXPORTING
         iv_barcode       = v_barcode
         iv_werks         = lv_werksd
       IMPORTING
         es_label_content = wa_label_content.

     "Check for warehouse authorization
     AUTHORITY-CHECK OBJECT 'L_LGNUM'
         ID 'LGTYP' FIELD '*'
         ID 'LGNUM' FIELD wa_label_content-su_content-su_header-lgnum.
     IF sy-subrc <> 0.
       MESSAGE e063(zone_msg) WITH wa_label_content-su_content-su_header-lgnum INTO v_dummy.
       v_flag = abap_true.
       PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                 v_barcode
                                 abap_true.
     ENDIF.

     CHECK v_flag = abap_false.

     IF wa_label_content IS INITIAL.
       v_flag = abap_true.
       MESSAGE e003(zitsus) INTO v_dummy.
       PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                 v_barcode
                                 abap_true.
     ELSE.
*Check whehter the HU number is exist
       IF wa_label_content-zzhu_exid = space
       OR wa_label_content-hu_content IS INITIAL.
         v_flag = abap_true.
         MESSAGE e003(zitsus) INTO v_dummy.
         PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                   v_barcode
                                   abap_true.
       ELSE.
         READ TABLE wa_label_content-hu_content-hu_content ASSIGNING <s_huitem> INDEX 1.
         IF sy-subrc = 0.
           wa_vepo-velin = <s_huitem>-hu_item_type.
           wa_vepo-vepos = <s_huitem>-hu_item_number.
           wa_vepo-vemng = <s_huitem>-pack_qty.
           IF <s_huitem>-pack_qty = 0.
             v_flag = abap_true.
             MESSAGE e004(zitsus) INTO v_dummy.
             PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                       v_barcode
                                       abap_true.
           ENDIF.
           wa_vepo-vemeh = <s_huitem>-base_unit_qty.
           wa_vepo-matnr = <s_huitem>-material.
           wa_vepo-charg = <s_huitem>-batch.
           wa_vepo-werks = <s_huitem>-plant.
           wa_vepo-lgort = <s_huitem>-stge_loc.
           wa_vepo-bestq = <s_huitem>-stock_cat.
           wa_vepo-sobkz = <s_huitem>-spec_stock.
           wa_vepo-sonum = <s_huitem>-sp_stck_no.

*Check if the handling unit is WM managed or IM managed
           IF wa_label_content-su_content IS NOT INITIAL.
             v_hu_status_init = c_in_warehouse.
             wa_lein-lgtyp = wa_label_content-su_content-su_header-lgtyp.
             wa_lein-lgpla = wa_label_content-su_content-su_header-lgpla.
             v_lgnum       = wa_label_content-su_content-su_header-lgnum.

             SELECT SINGLE eatyp
                           eapla
             FROM t340d
             INTO wa_t340d
             WHERE lgnum = v_lgnum.
             IF sy-subrc = 0.
               IF wa_lein-lgtyp <> wa_t340d-lgtyp
               OR wa_lein-lgtyp <> wa_t340d-lgtyp.
                 v_create_to = abap_true.
               ENDIF.
             ELSE.
               v_flag = abap_true.
               MESSAGE e005(zitsus) WITH v_lgnum INTO v_dummy.
               PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                         v_barcode
                                         abap_true.
             ENDIF.
           ELSE.
             v_hu_status_init = c_not_in_warehouse.
           ENDIF.
         ENDIF.
       ENDIF.
     ENDIF.
   ENDIF.

   IF v_flag = abap_false.
     REFRESH:it_container.
     CLEAR:wa_container.

     DATA : lv_qty TYPE p DECIMALS 3.
     IF sy-tcode = 'ZSUBDIV'..
       DO zsits_scan_repack_barcode-quantity TIMES.
         wa_container-number = wa_container-number + 1.
         wa_container-unit   = wa_vepo-vemeh.
         APPEND wa_container TO it_container.
       ENDDO.
     ELSEIF sy-tcode = 'ZSAMPL_CONSUMED'.
       wa_container-number = wa_container-number + 1.
       wa_container-unit   = wa_vepo-vemeh.
       lv_qty = zsits_scan_repack_barcode-quantity.
       wa_container-quantity = lv_qty.
       APPEND wa_container TO it_container.
     ENDIF.

   ENDIF.

 ENDFORM.

 FORM process2. "unpack packing and creating new conatiners
*  Begin of insert rvenugopal : EICR 573542
   DATA: lv_plant_check TYPE char1.
*  End of insert rvenugopal : EICR 573542
   LOOP AT it_container ASSIGNING <s_container>.
     IF <s_container>-quantity = space.
       v_flag = abap_true.
       MESSAGE e007(zitsus) INTO v_dummy.
       PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                 v_barcode
                                 abap_true.
       EXIT.
     ENDIF.
     v_qty = v_qty + <s_container>-quantity.
   ENDLOOP.
*Check whether the input quantity is larger than the original quantity
   CHECK v_flag = abap_false.
   IF v_qty > wa_vepo-vemng.
     v_flag = abap_true.
     v_difference = v_qty - wa_vepo-vemng.
     MESSAGE e008(zitsus) WITH v_difference INTO v_dummy.
     PERFORM add_message USING zcl_its_utility=>gc_objid_label
                               v_barcode
                               abap_true.
   ELSE.
     v_difference = wa_vepo-vemng - v_qty.
   ENDIF.

*Fetching the packing material
   SELECT SINGLE mtart
   FROM mara
   INTO v_mtart
   WHERE matnr = wa_vepo-matnr.
   IF sy-subrc = 0.
     SELECT SINGLE vhilm
     FROM ztits_dispensing
     INTO v_vhilm
     WHERE mtart = v_mtart
     AND   matnr = wa_vepo-matnr.
     IF sy-subrc <> 0.
       SELECT SINGLE vhilm
       FROM ztits_dispensing
       INTO v_vhilm
       WHERE mtart = v_mtart
       AND   matnr = space.
       IF sy-subrc <> 0.
         SELECT SINGLE vhilm
         FROM ztits_dispensing
         INTO v_vhilm
         WHERE mtart = space
         AND   matnr = space.
         IF sy-subrc <> 0.
           v_flag = abap_true.
           MESSAGE e009(zitsus) INTO v_dummy.
           PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                     v_barcode
                                     abap_true.
         ENDIF.
       ENDIF.
     ENDIF.
   ENDIF.

   CHECK v_flag = abap_false.
   IF v_create_to = abap_true.
*Create TO to transfer original handling unit
     PERFORM create_to_move_su USING    wa_label_content-zzhu_exid
                                        c_movement_type
                                         wa_lein-lgtyp
                                         wa_lein-lgpla
                               CHANGING v_flag.
     IF v_flag = abap_true.
       v_lenum = wa_label_content-zzhu_exid.
       PERFORM convert_hunumber_output CHANGING v_lenum.
       MESSAGE e010(zitsus) WITH v_lenum INTO v_dummy.
       PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                 v_barcode
                                 abap_true.
     ENDIF.
   ENDIF.
*Repack the orginal handling unit
   CHECK v_flag = abap_false.
   LOOP AT it_container ASSIGNING <s_container>.

     IF sy-tcode = 'ZSUBDIV'.


       REFRESH:it_repack,
               it_desthu_tmp,
               it_return.

       CLEAR:v_hukey,
             wa_headerproposal,
             wa_repack,
             wa_desthu,
             wa_reprocess.

       v_hukey                          = c_hu_exid.
       wa_headerproposal-hu_status_init = v_hu_status_init.
       wa_headerproposal-pack_mat       = v_vhilm.
       wa_headerproposal-hu_exid        = c_hu_exid.
       wa_headerproposal-plant          = wa_label_content-hu_content-hu_header-plant.
       wa_headerproposal-stge_loc       = wa_label_content-hu_content-hu_header-stge_loc.

       wa_repack-source_hu              = wa_label_content-zzhu_exid.
       PERFORM convert_hunumber_input CHANGING wa_repack-source_hu.
       wa_repack-flag_packhu            = space.
       wa_repack-pack_qty               = <s_container>-quantity.
       wa_repack-base_uom               = wa_vepo-vemeh.
       wa_repack-material               = wa_vepo-matnr.
       PERFORM convert_material_input CHANGING wa_repack-material.
       wa_repack-stock_cat              = wa_vepo-bestq.
       wa_repack-batch                  = wa_vepo-charg.
       wa_repack-plant                  = wa_vepo-werks.
       wa_repack-stge_loc               = wa_vepo-lgort.
       wa_repack-spec_stock             = wa_vepo-sobkz.
       wa_repack-sp_stck_no             = wa_vepo-sonum.
       APPEND wa_repack TO it_repack.

       IF v_flag = abap_true.
         wa_reprocess-headerproposal = wa_headerproposal.
         wa_reprocess-repack         = it_repack.
         APPEND wa_reprocess TO it_reprocess.
         CONTINUE.
       ENDIF.

       CALL FUNCTION 'BAPI_HU_REPACK'
         EXPORTING
           hukey          = v_hukey
           headerproposal = wa_headerproposal
         TABLES
           repack         = it_repack
           return         = it_return
           desthu         = it_desthu_tmp.

       LOOP AT it_return ASSIGNING <s_return> WHERE type = c_abortion OR type = c_error.
         MESSAGE ID <s_return>-id TYPE <s_return>-type NUMBER <s_return>-number
         WITH <s_return>-message_v1 <s_return>-message_v2 <s_return>-message_v3 <s_return>-message_v4
         INTO v_dummy.
         EXIT.
       ENDLOOP.
       IF sy-subrc = 0.
         wa_reprocess-headerproposal = wa_headerproposal.
         wa_reprocess-repack         = it_repack.
         APPEND wa_reprocess TO it_reprocess.
         v_flag  = abap_true.
         PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                   v_barcode
                                   abap_true.
       ELSE.
         CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
           EXPORTING
             wait = abap_true.

         READ TABLE it_desthu_tmp ASSIGNING <s_desthu> INDEX 1.
         IF sy-subrc = 0.
           IF v_create_to = abap_true.
*Move newly created handling unit to the original storage location
             PERFORM create_to_move_su USING    <s_desthu>-hu_exid
                                                c_movement_type
                                                wa_lein-lgtyp
                                                wa_lein-lgpla
                                       CHANGING v_flag.
             IF v_flag = abap_true.
               wa_reprocess-headerproposal = wa_headerproposal.
               wa_reprocess-repack         = it_repack.
               wa_reprocess-status_repack  = abap_true.
               wa_reprocess-lenum          = <s_desthu>-hu_exid.
               APPEND wa_reprocess TO it_reprocess.

               v_lenum = <s_desthu>-hu_exid.
               PERFORM convert_hunumber_output CHANGING v_lenum.
               MESSAGE e010(zitsus) WITH v_lenum INTO v_dummy.
               PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                         v_barcode
                                         abap_true.
             ENDIF.
           ENDIF.
           wa_desthu-exidv    = <s_desthu>-hu_exid.
           PERFORM convert_hunumber_output CHANGING wa_desthu-exidv.
           wa_desthu-quantity = <s_container>-quantity.
           APPEND wa_desthu TO it_desthu.


         ENDIF.
       ENDIF.
     ENDIF.

     IF sy-tcode = 'ZSAMPL_CONSUMED'.
*       *Unpack the orginal handling unit

       v_hukey = wa_label_content-zzhu_exid.   "HU number
       ls_itemunpack-hu_item_type = wa_vepo-velin.
       ls_itemunpack-hu_item_number =  wa_vepo-vepos .
       ls_itemunpack-material =  wa_vepo-matnr.
       ls_itemunpack-batch =  wa_vepo-charg.
       ls_itemunpack-pack_qty =  <s_container>-quantity .
       ls_itemunpack-base_unit_qty = wa_vepo-vemeh .
       ls_itemunpack-plant =  wa_vepo-werks.
       ls_itemunpack-stge_loc =  wa_vepo-lgort.
       ls_itemunpack-spec_stock =  wa_vepo-sobkz.
       ls_itemunpack-stock_cat =  wa_vepo-bestq.
       ls_itemunpack-sp_stck_no =  wa_vepo-sonum.


       CALL FUNCTION 'BAPI_HU_UNPACK'
         EXPORTING
           hukey      = v_hukey
           itemunpack = ls_itemunpack
         TABLES
           return     = lt_return_up.

       LOOP AT lt_return_up ASSIGNING <s_return> WHERE type = c_abortion OR type = c_error.
         MESSAGE ID <s_return>-id TYPE <s_return>-type NUMBER <s_return>-number
         WITH <s_return>-message_v1 <s_return>-message_v2 <s_return>-message_v3 <s_return>-message_v4
         .
         EXIT.
       ENDLOOP.
       CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
         EXPORTING
           wait = abap_true.
     ENDIF.

   ENDLOOP.


*If there is quantity left in the original handling unit, move it to
*the original storage bin
   IF v_flag = abap_false AND v_create_to = abap_true AND v_difference <> 0.
     IF sy-tcode = 'ZSUBDIV'.
       PERFORM create_to_move_su USING    wa_label_content-zzhu_exid
                                          c_movement_type
                                          wa_lein-lgtyp
                                          wa_lein-lgpla
                                 CHANGING v_flag_tmp.

     ENDIF.
     IF v_flag_tmp = abap_true.
       v_lenum = wa_label_content-zzhu_exid.
       PERFORM convert_hunumber_output CHANGING v_lenum.
       MESSAGE e010(zitsus) WITH v_lenum INTO v_dummy.
       PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                 v_barcode
                                 abap_true.
     ENDIF.
   ENDIF.

   IF v_flag = abap_true OR v_flag_tmp = abap_true.
     v_exid_tmp = wa_label_content-zzhu_exid.
     PERFORM convert_hunumber_output CHANGING v_exid_tmp.
     IF v_create_to = abap_true.
       wa_move_su-lenum   = wa_label_content-zzhu_exid.

       IF sy-tcode = 'ZSUBDIV'.
         wa_move_su-bwlvs   = c_movement_type.

       ELSEIF sy-tcode = 'ZSAMPL_CONSUMED'.
         wa_move_su-bwlvs   = c_movement_type_sc.
       ENDIF.

       wa_move_su-nltyp   = wa_lein-lgtyp.
       wa_move_su-nlpla   = wa_lein-lgpla.
       v_move_original_su = abap_true.
     ENDIF.
     CONCATENATE zcl_its_utility=>gc_log_prefix_repack v_exid_tmp
     INTO v_log_handler.

     EXPORT p1 = wa_post_log
            p2 = it_reprocess
            p3 = wa_move_su
            p4 = v_move_original_su
     TO DATABASE indx(z8) ID v_log_handler.
   ENDIF.

   IF v_flag = abap_false AND v_flag_tmp = abap_false.
     CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
     IF sy-subrc EQ 0.

*   Begin of insert rvenugopal : EICR 573542
*   In case of GBAB, the process should stop here
       SELECT SINGLE indicator1 FROM zvv_param
         INTO lv_plant_check WHERE
         lookup_name EQ 'SAPMZITSE_DISPENSING'
         AND free_key EQ 'WERKS'
         AND free_key_value EQ wa_vepo-werks.
       IF lv_plant_check IS NOT INITIAL .
         MESSAGE s058(zitsus) WITH wa_label_content-zzhu_exid
                            zsits_scan_repack_barcode-quantity.
         PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                   v_barcode
                                   abap_true.
         RETURN.
       ELSE.
*   End of insert rvenugopal : EICR 573542
         MESSAGE s024(zitsus) INTO v_dummy.
         PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                   v_barcode
                                   abap_false.
       ENDIF.
     ELSE.
       ROLLBACK WORK.
     ENDIF.


     IF sy-tcode = 'ZSAMPL_CONSUMED'.
       TYPES : BEGIN OF ty_t001l,
                 lgort TYPE t001l-lgort,
                 parlg TYPE t001l-parlg,
               END OF ty_t001l.

       DATA: lwa_goods_mvt TYPE bapi2017_gm_head_01,
             lwa_gm_item   TYPE bapi2017_gm_item_create,
             lit_gm_item   TYPE TABLE OF bapi2017_gm_item_create,
             lwa_matnr_key TYPE zsits_material_read_para,
             lv_mjahr      TYPE bapi2017_gm_head_ret-doc_year,
             lwa_output    LIKE LINE OF it_repack,
             lv_msg        TYPE string,
             lit_return    TYPE TABLE OF bapiret2,
             lwa_gm_code   TYPE bapi2017_gm_code,
             lt_t001l      TYPE TABLE OF ty_t001l,
             ls_t001l      TYPE ty_t001l,
             lv_mblnr      TYPE mblnr.

       DATA :           lv_wh        TYPE ltak-lgnum,
                        lv_mat       TYPE ltap-matnr,
                        lv_plant     TYPE ltap-werks,
                        lv_unit      TYPE ltap-altme,
                        lv_batch     TYPE ltap-charg,
                        lv_quan      TYPE rl03t-anfme,
                        lv_stype     TYPE ltap-nltyp,
                        lv_sbin      TYPE ltap-nlpla,
                        lv_stunit    TYPE ltap-letyp,
                        lv_des_loc   TYPE ltap-lgort,
                        lv_to        TYPE ltak-tanum,
                        lv_stock_cat TYPE ltap-bestq.

       CLEAR:lwa_goods_mvt,lwa_gm_item.

* Goods movement header
       lwa_goods_mvt-pstng_date = sy-datum.
       lwa_goods_mvt-doc_date   = sy-datum.


       "Get destination storage loc
       SELECT lgort parlg FROM t001l
         INTO TABLE lt_t001l
         WHERE lgort = wa_vepo-lgort
           AND werks = wa_vepo-werks
           AND parlg NE ''.

       "Get get of HU
       SELECT lenum lgtyp
            lgpla lgnum matnr werks charg letyp meins bestq
            FROM lqua
            INTO TABLE lt_wh
            WHERE lenum = wa_label_content-zzhu_exid.
       IF sy-subrc EQ 0.
* Goods movement code
         lwa_gm_code = zcl_its_utility=>gc_gm_code_03.   " Transfer Posting
         lwa_gm_item-material  = wa_vepo-matnr..  " Material
         lwa_gm_item-plant     = wa_vepo-werks.  " Plant
         lwa_gm_item-batch     = wa_vepo-charg.  " Batch


         READ TABLE lt_t001l INTO ls_t001l WITH KEY lgort = wa_vepo-lgort.
         IF sy-subrc EQ 0.
           lwa_gm_item-stge_loc  = ls_t001l-parlg .
         ENDIF.
*If the material posted is of type "I", then it is a WIP material
         IF zcl_its_utility=>material_read( is_key = lwa_matnr_key )-zzcap_mattype = zcl_its_utility=>gc_matcat_wip.
           CLEAR lwa_gm_item-spec_stock.
         ENDIF.
         CLEAR lwa_matnr_key.
         DATA :
           lt_tvarvc  TYPE STANDARD TABLE OF tvarvc,
           ls_tvarvc  LIKE LINE OF lt_tvarvc,
           gr_name    TYPE RANGE OF rvari_vnam,
           gs_name    LIKE LINE OF gr_name,
           lv_mvt_typ TYPE ltak-bwlvs.

         gs_name-sign   = 'I'.
         gs_name-option = 'EQ'.
         gs_name-low    = 'Z_SAMP_MVTYPE_STOCKCAT_Q'.
         APPEND gs_name TO gr_name.

         gs_name-low    = 'Z_SAMP_MVTYPE_STOCKCAT_BLK'.
         APPEND gs_name TO gr_name.


         gs_name-low    = 'Z_SAMP_MVTYPE_STOCKCAT_S'.
         APPEND gs_name TO gr_name.

         gs_name-low    = 'Z_SAMP_MVTYPE_TO'.
         APPEND gs_name TO gr_name.

         gs_name-option = 'CP'.            "defect#451
         gs_name-low    = 'Z_SAMP_CC*'.    "defect#451
         APPEND gs_name TO gr_name.        "defect#451

         CLEAR: gs_name.

         SELECT * FROM tvarvc
           INTO TABLE lt_tvarvc
           WHERE name IN gr_name.

         READ TABLE lt_wh INTO ls_wh INDEX 1.
         IF sy-subrc EQ 0.

           IF ls_wh-bestq = ' '.
             READ TABLE lt_tvarvc INTO ls_tvarvc WITH KEY name = 'Z_SAMP_MVTYPE_STOCKCAT_BLK'.
             IF sy-subrc EQ 0.
               lwa_gm_item-move_type = ls_tvarvc-low.
             ENDIF.
           ELSEIF ls_wh-bestq  = 'Q'.
             READ TABLE lt_tvarvc INTO ls_tvarvc WITH KEY name = 'Z_SAMP_MVTYPE_STOCKCAT_Q'.
             IF sy-subrc EQ 0.
               lwa_gm_item-move_type = ls_tvarvc-low.
             ENDIF.
           ELSEIF ls_wh-bestq  = 'S'.
             READ TABLE lt_tvarvc INTO ls_tvarvc WITH KEY name = 'Z_SAMP_MVTYPE_STOCKCAT_S'.
             IF sy-subrc EQ 0.
               lwa_gm_item-move_type = ls_tvarvc-low.
             ENDIF.
           ENDIF.
         ENDIF.
         lwa_gm_item-entry_qnt = <s_container>-quantity.

*-- Begin of insert for defect#451 EICR 573542 NPOLISETTY on 29.May.2019
*-- Get the cost center
         CONCATENATE 'Z_SAMP_CC' lwa_gm_item-plant INTO DATA(lv_name) SEPARATED BY '_'.
         READ TABLE lt_tvarvc INTO ls_tvarvc WITH KEY name = lv_name.
         IF sy-subrc = 0.
           lwa_gm_item-costcenter = ls_tvarvc-low.
         ENDIF.
*-- End of insert for defect#451 EICR 573542 NPOLISETTY on 29.May.2019

         APPEND lwa_gm_item TO lit_gm_item.
         CLEAR lv_mblnr.


*   Process Material goods movement
*          Post goods movement
         CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
           EXPORTING
             goodsmvt_header  = lwa_goods_mvt
             goodsmvt_code    = lwa_gm_code
           IMPORTING
             materialdocument = lv_mblnr
             matdocumentyear  = lv_mjahr
           TABLES
             goodsmvt_item    = lit_gm_item
             return           = lit_return.

         "Unsuccessful commit
         IF sy-subrc NE 0.
           ROLLBACK WORK.
         ENDIF.

         IF lv_mblnr IS INITIAL .
           CALL FUNCTION 'MESSAGE_TEXT_BUILD'
             EXPORTING
               msgid               = sy-msgid
               msgnr               = sy-msgno
               msgv1               = sy-msgv1
               msgv2               = sy-msgv2
               msgv3               = sy-msgv3
               msgv4               = sy-msgv4
             IMPORTING
               message_text_output = lv_msg.

           SHIFT wa_label_content-zzhu_exid LEFT DELETING LEADING '0'.
           MESSAGE e054(zitsus) WITH wa_label_content-zzhu_exid
           zsits_scan_repack_barcode-quantity lv_msg INTO v_dummy .
           PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                     v_barcode
                                     abap_true.


         ELSE.
           CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'. "Defect 451
           READ TABLE lt_wh INTO ls_wh INDEX 1.
           IF sy-subrc EQ 0.


             lv_wh = ls_wh-lgnum.
             lv_mat = ls_wh-matnr.
             lv_plant = ls_wh-werks.
             lv_unit = ls_wh-meins.
             lv_batch = ls_wh-charg.
             lv_quan = <s_container>-quantity.
             lv_stype = ls_wh-lgtyp.
             lv_sbin = ls_wh-lgpla.
             lv_stunit = ls_wh-letyp.
             lv_des_loc = ls_t001l-parlg.
             lv_stock_cat = ls_wh-bestq.

             READ TABLE lt_tvarvc INTO ls_tvarvc WITH KEY name = 'Z_SAMP_MVTYPE_TO'.
             IF sy-subrc EQ 0.
               lv_mvt_typ = ls_tvarvc-low.
             ENDIF.

             "create To for quality
             CALL FUNCTION 'L_TO_CREATE_SINGLE'
               EXPORTING
                 i_lgnum               = lv_wh
                 i_bwlvs               = lv_mvt_typ
                 i_matnr               = lv_mat
                 i_werks               = lv_plant
                 i_lgort               = lv_des_loc
                 i_charg               = lv_batch
                 i_bestq               = lv_stock_cat
                 i_letyp               = lv_stunit
                 i_anfme               = lv_quan
                 i_altme               = lv_unit
                 i_squit               = 'X'
                 i_vltyp               = lv_stype
                 i_vlpla               = lv_sbin
                 i_nltyp               = '917'
                 i_nlpla               = 'QUALITY'
                 i_commit_work         = 'X'
                 i_bname               = sy-uname
                 i_kompl               = 'X'
               IMPORTING
                 e_tanum               = lv_to
               EXCEPTIONS
                 no_to_created         = 1
                 bwlvs_wrong           = 2
                 betyp_wrong           = 3
                 benum_missing         = 4
                 betyp_missing         = 5
                 foreign_lock          = 6
                 vltyp_wrong           = 7
                 vlpla_wrong           = 8
                 vltyp_missing         = 9
                 nltyp_wrong           = 10
                 nlpla_wrong           = 11
                 nltyp_missing         = 12
                 rltyp_wrong           = 13
                 rlpla_wrong           = 14
                 rltyp_missing         = 15
                 squit_forbidden       = 16
                 manual_to_forbidden   = 17
                 letyp_wrong           = 18
                 vlpla_missing         = 19
                 nlpla_missing         = 20
                 sobkz_wrong           = 21
                 sobkz_missing         = 22
                 sonum_missing         = 23
                 bestq_wrong           = 24
                 lgber_wrong           = 25
                 xfeld_wrong           = 26
                 date_wrong            = 27
                 drukz_wrong           = 28
                 ldest_wrong           = 29
                 update_without_commit = 30
                 no_authority          = 31
                 material_not_found    = 32
                 lenum_wrong           = 33
                 OTHERS                = 34.
             IF sy-subrc <> 0.
               MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                          INTO lv_dummy
                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
               lv_msg = abap_true.

               PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                     v_barcode
                                     abap_true.
             ELSE.
               SHIFT wa_label_content-zzhu_exid LEFT DELETING LEADING '0'.
               MESSAGE s053(zitsus) WITH wa_label_content-zzhu_exid
               zsits_scan_repack_barcode-quantity lv_mblnr INTO v_dummy.
               PERFORM add_message USING zcl_its_utility=>gc_objid_label
                                         v_barcode
                                         abap_true.
             ENDIF.
           ENDIF.




         ENDIF.

       ENDIF.
     ENDIF.
   ENDIF.

 ENDFORM.
*
