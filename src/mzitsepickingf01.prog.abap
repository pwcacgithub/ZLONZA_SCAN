*&---------------------------------------------------------------------*
*&  Include           MZITSEPICKINGF01
*&---------------------------------------------------------------------*

*&      Form  GET_USER_PROFILE
*&---------------------------------------------------------------------*
*       Get user's profile
*----------------------------------------------------------------------*
FORM get_user_profile .
  IF x_profile IS INITIAL.
    CALL METHOD zcl_its_utility=>get_user_profile
      RECEIVING
        rs_user_profile = x_profile.
  ENDIF.
ENDFORM.                    " GET_USER_PROFILE
*&---------------------------------------------------------------------*
*&      Form  NEW_TRAN
*&---------------------------------------------------------------------*
*       Go to new transaction screen
*----------------------------------------------------------------------*
FORM new_tran .
*  LEAVE TO TRANSACTION 'ZLS_NTRAN'.
  CALL TRANSACTION 'ZMDE'." ASAH
ENDFORM.                    " NEW_TRAN
*&---------------------------------------------------------------------*
*&      Form  NEW_DELIVERY
*&---------------------------------------------------------------------*
*       Go to screen 9000 to scan a new delivery #
*----------------------------------------------------------------------*
FORM new_delivery .
  CALL FUNCTION 'DEQUEUE_ALL'.
  CLEAR zsits_scan_dynp.
  CLEAR v_cursor_field.
  LEAVE TO SCREEN 9000.
ENDFORM.                    " NEW_DELIVERY
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       User command
*----------------------------------------------------------------------*
FORM user_command .
  CASE :  sy-ucomm.

    WHEN 'CLR'.
      CLEAR : zsits_scan_dynp-zzoutb_delivery, zsits_scan_dynp-zzmaterial,
            zsits_scan_dynp-zzsourcebin_upd, zsits_scan_dynp-zzquantity_upd.
    WHEN 'NTRA'.
      PERFORM new_tran.
    WHEN OTHERS.

  ENDCASE.
ENDFORM.                    " USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  NEXT_SCREEN
*&---------------------------------------------------------------------*
*       Scan delivery number and check if it is valid
*----------------------------------------------------------------------*
FORM next_screen .


  DATA: lx_dlv_key     TYPE zsits_dlv_key,
        lv_lock_result TYPE boolean,
        lv_valid       TYPE boolean,
        lv_error       TYPE boolean,
        lv_dummy       TYPE bapi_msg.

  DATA :lv_auth_msg TYPE c LENGTH 100,
        lc_e        TYPE c VALUE 'E',
        ls_lips     TYPE lips.

  CLEAR: x_detail,
         x_delivery_header,
         x_delivery_to,
         zsits_scan_dynp-zzsuccess_msg.

  CHECK zsits_scan_dynp-zzoutb_delivery IS NOT INITIAL.

  lv_error = abap_true.

* Outbound delivery validation
  IF zcl_its_utility=>outb_delivery_validate( is_scan_dynp = zsits_scan_dynp ) = abap_true.

*** Authority check on LGNUM and LGTYP
    CLEAR ls_lips.
    SELECT SINGLE * FROM lips
      INTO ls_lips
      WHERE vbeln = zsits_scan_dynp-zzoutb_delivery.
    IF sy-subrc = 0.
      AUTHORITY-CHECK OBJECT 'L_LGNUM'
        ID 'LGNUM' FIELD ls_lips-lgnum
        ID 'LGTYP' FIELD ls_lips-lgtyp.

      IF sy-subrc <> 0.
        CONCATENATE text-001 ls_lips-lgnum text-002 ls_lips-lgtyp INTO lv_auth_msg SEPARATED BY space.
        MESSAGE lv_auth_msg TYPE lc_e.
      ENDIF.
    ENDIF.

*   Get shipping lane
    CALL METHOD zcl_its_utility=>delivery_read
      EXPORTING
        iv_delivery        = zsits_scan_dynp-zzoutb_delivery
        iv_pick_get        = abap_true
      IMPORTING
        es_delivery_header = x_delivery_header
        et_picking_qty     = x_delivery_to.

*   Lock delivery
    IF zcl_its_utility=>delivery_lock( iv_delivery = zsits_scan_dynp-zzoutb_delivery ) = abap_true.

      lx_dlv_key-vbeln = zsits_scan_dynp-zzoutb_delivery.

*     Get Transfer Order details by outbound delivery
      CALL METHOD zcl_its_utility=>get_to_by_outb_dlv
        EXPORTING
          is_dlv_key = lx_dlv_key
        IMPORTING
          es_detail  = x_detail.

      IF x_detail-to_item IS NOT INITIAL.

        SORT x_detail-to_item BY vbeln posnn.

        lv_error = abap_false.

      ELSE.
*       No open TO could be found for scanned O/B Delivery &1 !
        MESSAGE e133(zits) WITH zsits_scan_dynp-zzoutb_delivery INTO lv_dummy.
      ENDIF.

    ELSE.
*   Error Scenario 1: Delivery &1 does not exist in the database or in the archive
*   Error Scenario 2: Document &1 is not an outbound delivery !
*   Error Scenario 3: PGI of delivery &1 has been completed

    ENDIF.
  ENDIF.

  PERFORM message_add USING zcl_its_utility=>gc_objid_delivery "Object ID = 'Delivery'
                            zsits_scan_dynp-zzoutb_delivery
                            lv_error.

  IF lv_error = abap_true.
    CLEAR zsits_scan_dynp-zzoutb_delivery.
  ELSE.
    CALL SCREEN 9010.
  ENDIF.

ENDFORM.                    " NEXT_SCREEN
*&---------------------------------------------------------------------*
*&      Form  MATERIAL
*&---------------------------------------------------------------------*
*       Display source bin and quantity if material is valid
*----------------------------------------------------------------------*
FORM material .
  DATA:  lv_dummy         TYPE bapi_msg,
         lv_dummy0        TYPE bapi_msg,
         lwa_dlv_item     TYPE zsits_dlv_item,
         lx_material_key  TYPE zsits_material_read_para,
         lx_material_data TYPE zsits_material_data,
         lwa_im_stock     TYPE zsits_material_im_stock.

* Check if material scanned is valid
  CLEAR: wa_to_item,
         v_material,
         zsits_scan_dynp-zzsuccess_msg.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
* Add leading zeros for material #
    EXPORTING
      input  = zsits_scan_dynp-zzmaterial
    IMPORTING
      output = v_material.

  READ TABLE x_detail-to_item INTO wa_to_item
  WITH KEY matnr = v_material.

  IF sy-subrc = 0.

    zsits_scan_dynp-zzsourcebin = wa_to_item-vlpla.

    v_quantity =   wa_to_item-vsolm.

    WRITE wa_to_item-vsolm TO zsits_scan_dynp-zzquantity UNIT wa_to_item-meins.

* Left alignnment
    SHIFT zsits_scan_dynp-zzquantity LEFT DELETING LEADING space.

* Convert the UOM to output format
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input  = wa_to_item-meins
      IMPORTING
        output = zsits_scan_dynp-zzbuom.

    PERFORM set_cursor.
    PERFORM message_add USING zcl_its_utility=>gc_objid_material
                              zsits_scan_dynp-zzmaterial
                              abap_false.
*      ENDIF.
*    ENDIF.

  ELSE.
    MESSAGE e051(zits) WITH zsits_scan_dynp-zzmaterial INTO lv_dummy.
*   Material not on TO, display error.
    PERFORM message_add USING zcl_its_utility=>gc_objid_material
                              zsits_scan_dynp-zzmaterial
                              abap_true.

    CLEAR: zsits_scan_dynp-zzmaterial,zsits_scan_dynp-zzbuom.

    GET CURSOR FIELD v_cursor_field.

  ENDIF.
ENDFORM.                    " MATERIAL
*&---------------------------------------------------------------------*
*&      Form  SOURCE_BIN
*&---------------------------------------------------------------------*
*       Scan source bin and check the validity
*----------------------------------------------------------------------*
FORM source_bin .
  DATA: lv_dummy TYPE bapi_msg.

* Check if scanned source bin is the same as output source bin
  IF zsits_scan_dynp-zzsourcebin_upd = zsits_scan_dynp-zzsourcebin.
* If the two match, cusor goes to quantity input field
    PERFORM set_cursor.
    PERFORM message_add USING zcl_its_utility=>gc_objid_bin
                              zsits_scan_dynp-zzsourcebin_upd
                              abap_false.
  ELSE.
* If the two don't match, log and display error message
    MESSAGE e053(zits) WITH zsits_scan_dynp-zzmaterial INTO lv_dummy.
    PERFORM message_add USING zcl_its_utility=>gc_objid_bin
                              zsits_scan_dynp-zzsourcebin_upd
                              abap_true.
    CLEAR zsits_scan_dynp-zzsourcebin_upd.
    GET CURSOR FIELD v_cursor_field.
  ENDIF.
ENDFORM.                    " SOURCE_BIN
*&---------------------------------------------------------------------*
*&      Form  QUANTITY
*&---------------------------------------------------------------------*
*       Enter/scan quantity and vefiry
*----------------------------------------------------------------------*
FORM quantity .
  DATA: lv_dummy        TYPE bapi_msg.

* Convert dynpro fields from CHAR to INTEGER
  CALL FUNCTION 'MOVE_CHAR_TO_NUM'
    EXPORTING
      chr             = zsits_scan_dynp-zzquantity_upd
    IMPORTING
      num             = v_quantity_upd
    EXCEPTIONS
      convt_no_number = 1
      convt_overflow  = 2
      OTHERS          = 3.

* Check if quantity scanned is greater than output quantity
  IF v_quantity_upd > v_quantity.
* If scanned quantity is greater than TO quantity, log and display error message
    MESSAGE e054(zits) WITH zsits_scan_dynp-zzmaterial INTO lv_dummy.
    PERFORM message_add USING zcl_its_utility=>gc_objid_quantity
                              zsits_scan_dynp-zzquantity_upd
                              abap_true.
    CLEAR zsits_scan_dynp-zzquantity_upd.
    GET CURSOR FIELD v_cursor_field.
  ELSE.
    PERFORM set_cursor.
  ENDIF.
ENDFORM.                    " QUANTITY
*&---------------------------------------------------------------------*
*&      Form  TO_CONFIRM
*&---------------------------------------------------------------------*
*       Confirm TO item
*----------------------------------------------------------------------*
FORM to_confirm .
  DATA: lwa_to_conf_item   TYPE zsits_to_conf_item,
        lv_result          TYPE boolean,
        lx_dlv_key         TYPE zsits_dlv_key,
        lv_confirmed_lines TYPE i,
        lv_total_to_lines  TYPE i.

  CHECK:    zsits_scan_dynp-zzmaterial        IS NOT INITIAL,
            zsits_scan_dynp-zzsourcebin_upd   IS NOT INITIAL,
            zsits_scan_dynp-zzquantity_upd    IS NOT INITIAL.

* Fetch TO item data to be confirmed
  lwa_to_conf_item-tanum = wa_to_item-vbeln.
  lwa_to_conf_item-tapos = wa_to_item-posnn.

  IF v_quantity_upd = v_quantity.
*   Entered quantity equal to TO quantity
    lwa_to_conf_item-squit = abap_true.
  ELSE.
    lwa_to_conf_item-nista = v_quantity_upd.
    lwa_to_conf_item-ndifa = v_quantity - v_quantity_upd.
    lwa_to_conf_item-altme = wa_to_item-meins.
  ENDIF.

  CLEAR x_to_conf.
  APPEND lwa_to_conf_item TO x_to_conf-to_conf_item.
  x_to_conf-lgnum = wa_to_item-lgnum.
  x_to_conf-tanum = wa_to_item-vbeln.
  x_to_conf-squit = ''.

* Confirm item
  CALL METHOD zcl_its_utility=>to_confirm
    EXPORTING
      is_to_conf = x_to_conf
    RECEIVING
      rv_result  = lv_result.

  IF lv_result = abap_true.
    CLEAR x_detail.

* 1. refresh the Open TO data after TO confirmation
    lx_dlv_key-vbeln = zsits_scan_dynp-zzoutb_delivery.

    CALL METHOD zcl_its_utility=>get_to_by_outb_dlv
      EXPORTING
        is_dlv_key = lx_dlv_key
      IMPORTING
        es_detail  = x_detail.

* get the open TO lines
    DESCRIBE TABLE  x_detail-to_item LINES lv_confirmed_lines.
* get total TO lines
    DESCRIBE TABLE  x_delivery_to    LINES lv_total_to_lines.
* confirmed TO lines
    lv_confirmed_lines = lv_total_to_lines - lv_confirmed_lines .

*Material picked
    MESSAGE s151(zits) WITH zsits_scan_dynp-zzmaterial
                            lv_confirmed_lines
                             lv_total_to_lines
                       INTO  zsits_scan_dynp-zzsuccess_msg.

    PERFORM message_add USING zcl_its_utility=>gc_objid_to
                              wa_to_item-tanum
                              abap_false.

  ELSE.

    PERFORM message_add USING zcl_its_utility=>gc_objid_to
                              wa_to_item-tanum
                              abap_true.

  ENDIF.

  CLEAR: zsits_scan_dynp-zzmaterial,
         zsits_scan_dynp-zzsourcebin,
         zsits_scan_dynp-zzsourcebin_upd,
         zsits_scan_dynp-zzquantity,
         zsits_scan_dynp-zzbuom,
         zsits_scan_dynp-zzquantity_upd.
ENDFORM.                    " TO_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  MESSAGE_ADD
*&---------------------------------------------------------------------*
*       Log and display message if there is one
*----------------------------------------------------------------------*
*  -->  uv_object_id      Object ID
*  <--  uv_content        Object content
*  -->  uv_with_message   With message or not
*----------------------------------------------------------------------*
FORM message_add USING uv_object_id    TYPE zzscan_objid
                       uv_content      TYPE any
                       uv_with_message TYPE boolean.

  CALL METHOD o_log->log_message_add
    EXPORTING
      iv_object_id    = uv_object_id
      iv_content      = uv_content
      iv_with_message = uv_with_message.

  IF uv_with_message = abap_true.
* Display error message
    CALL METHOD zcl_its_utility=>message_display( ).
  ENDIF.
ENDFORM.                    " MESSAGE_ADD
*&---------------------------------------------------------------------*
*&      Form  SET_CURSOR
*&---------------------------------------------------------------------*
*       Set cursor to the next input field
*----------------------------------------------------------------------*
FORM set_cursor .
  DATA: lv_cursor_field TYPE char50.
  GET CURSOR FIELD lv_cursor_field.
  CASE lv_cursor_field.
    WHEN 'ZSITS_SCAN_DYNP-ZZMATERIAL'.
      v_cursor_field = 'ZSITS_SCAN_DYNP-ZZSOURCEBIN_UPD'.
    WHEN 'ZSITS_SCAN_DYNP-ZZSOURCEBIN_UPD'.
      v_cursor_field = 'ZSITS_SCAN_DYNP-ZZQUANTITY_UPD'.
    WHEN 'ZSITS_SCAN_DYNP-ZZQUANTITY_UPD'.
      v_cursor_field = 'ZSITS_SCAN_DYNP-ZZMATERIAL'.
  ENDCASE.
ENDFORM.                    " SET_CURSOR
