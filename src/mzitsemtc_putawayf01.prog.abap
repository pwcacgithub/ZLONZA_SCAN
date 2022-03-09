*&---------------------------------------------------------------------*
*&  Include           MZITSEMTC_PUTAWAYF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FRM_GET_USER_PROFILE
*&---------------------------------------------------------------------*
*       Form to get the user's profile (warehouse #, plant, etc.)
*----------------------------------------------------------------------*
FORM frm_get_user_profile .

  IF x_profile IS INITIAL.
    CALL METHOD zcl_its_utility=>get_user_profile
      RECEIVING
        rs_user_profile = x_profile.
  ENDIF.

ENDFORM.                    " FRM_GET_USER_PROFILE

*&---------------------------------------------------------------------*
*&      Form  FRM_TO_CHECK
*&---------------------------------------------------------------------*
*       Form to check TO validity and display details
*----------------------------------------------------------------------*
FORM frm_to_check .

  DATA: lv_fg    TYPE          boolean,
        lv_dummy TYPE          bapi_msg.

  DATA :lv_auth_msg     TYPE c LENGTH 100,
        lc_e            TYPE c VALUE 'E',
        lv_storage_type TYPE lgtyp.

  CLEAR: x_to_data.

  x_to_key-lgnum                   = x_profile-zzlgnum.
  x_to_key-tanum                   = zsits_scan_dynp-zzto_num.

  CLEAR lv_storage_type.
*Call method to check the validity of the TO number
  CALL METHOD zcl_its_utility=>to_read
    EXPORTING
      is_to_key       = x_to_key
    IMPORTING
      ev_storage_type = lv_storage_type
    RECEIVING
      rs_to_data      = x_to_data.

  IF x_to_data IS NOT INITIAL."If the TO exists
    IF x_to_data-kquit IS NOT INITIAL."If the TO is confirmed already
      lv_fg = abap_true.
      MESSAGE e050(zits) WITH zsits_scan_dynp-zzto_num INTO lv_dummy.
    ENDIF.
  ELSE.
    lv_fg = abap_true."if the TO number does not exist
  ENDIF.

*** Authority check on LGNUM and LGTYP
  AUTHORITY-CHECK OBJECT 'L_LGNUM'
    ID 'LGNUM' FIELD x_profile-zzlgnum
    ID 'LGTYP' FIELD lv_storage_type.

  IF sy-subrc <> 0.
    CONCATENATE text-001 x_profile-zzlgnum text-002 lv_storage_type INTO lv_auth_msg SEPARATED BY space.
    MESSAGE lv_auth_msg TYPE lc_e.
  ENDIF.


*Add log and display error message if required.
  PERFORM frm_message_add USING zsits_scan_dynp-zzto_num
                                 zcl_its_utility=>gc_objid_to
                                 lv_fg.

*Clear the balnk in case of any error.
  IF lv_fg = abap_true.
    GET CURSOR FIELD v_cursor_field.
    CLEAR zsits_scan_dynp-zzto_num.
  ELSE.
    v_cursor_field = 'ZSITS_SCAN_DYNP-ZZMATERIAL'.
    LEAVE TO SCREEN 9100.
  ENDIF.

ENDFORM.                    " FRM_TO_CHECK
*&---------------------------------------------------------------------*
*&      Form  FRM_MESSAGE_ADD
*&---------------------------------------------------------------------*
*       Form to add log and display error message if required
*----------------------------------------------------------------------*
*      -->uv_content
*      -->uv_objid
*      -->uv_boolean
*----------------------------------------------------------------------*
FORM frm_message_add  USING    uv_content TYPE any
                               uv_objid   TYPE zzscan_objid
                               uv_bool    TYPE boolean.

  CALL METHOD o_log->log_message_add
    EXPORTING
      iv_object_id    = uv_objid
      iv_content      = uv_content
      iv_with_message = uv_bool.

  IF uv_bool = abap_true.
* Display error message
    CALL METHOD zcl_its_utility=>message_display( ).

  ENDIF.

ENDFORM.                    " FRM_MESSAGE_ADD
*&---------------------------------------------------------------------*
*&      Form  FRM_SET_CURSOR
*&---------------------------------------------------------------------*
*       Form to move the cursor
*----------------------------------------------------------------------*
FORM frm_set_cursor .

  DATA: lv_cursor_field  TYPE char50.

  GET CURSOR FIELD lv_cursor_field.

  CASE lv_cursor_field.
    WHEN 'ZSITS_SCAN_DYNP-ZZTO_NUM'.

      v_cursor_field  = 'ZSITS_SCAN_DYNP-ZZMATERIAL'.

    WHEN 'ZSITS_SCAN_DYNP-ZZMATERIAL'.

      v_cursor_field  = 'ZSITS_SCAN_DYNP-ZZQUANTITY_UPD'.

    WHEN 'ZSITS_SCAN_DYNP-ZZQUANTITY_UPD'.

      v_cursor_field  = 'ZSITS_SCAN_DYNP-ZZDESTBIN_UPD'.

    WHEN 'ZSITS_SCAN_DYNP-ZZDESTBIN_UPD'.

      v_cursor_field  = 'ZSITS_SCAN_DYNP-ZZQUANTITY_UPD'.

  ENDCASE.

ENDFORM.                    " FRM_SET_CURSOR
*&---------------------------------------------------------------------*
*&      Form  FRM_MATERIAL_UPDATE
*&---------------------------------------------------------------------*
*       Form to scan a different material for the same TO
*----------------------------------------------------------------------*
FORM frm_material_update .

  DATA: lv_fg          TYPE            boolean,
        lv_matnr_alpha TYPE            matnr,
        lv_qty         TYPE            ltap_nsola,
        lv_dummy       TYPE            bapi_msg,
        lv_str1        TYPE            string,
        lv_str2        TYPE            string.

  CLEAR x_to_item.
*Call the alpha conversion for the material to add leading 0 if required
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input  = zsits_scan_dynp-zzmaterial
    IMPORTING
      output = lv_matnr_alpha.

*Fetch the line item of the TO based on the material the user scanned
  SORT x_to_data-to_item BY matnr.
  READ TABLE x_to_data-to_item INTO x_to_item WITH KEY matnr = lv_matnr_alpha BINARY SEARCH.
  IF sy-subrc = 0."If the system is able to find a line item associated with the material
    IF x_to_item-pquit = abap_true."If the line item is already confirmed
      lv_fg = abap_true.
      MESSAGE e131(zits) INTO lv_dummy.
    ELSE. "Display the quantity and destination bin
      zsits_scan_dynp-zzquantity     = x_to_item-vsola.
      zsits_scan_dynp-zzdestbin      = x_to_item-nlpla.
      CONDENSE zsits_scan_dynp-zzquantity NO-GAPS.
      SPLIT zsits_scan_dynp-zzquantity AT '.' INTO lv_str1 lv_str2.
      SHIFT lv_str2 RIGHT DELETING TRAILING '0'.
      CONDENSE lv_str2.
      IF lv_str2 IS NOT INITIAL.
        CONCATENATE lv_str1 '.' lv_str2 INTO zsits_scan_dynp-zzquantity.
      ELSE.
        zsits_scan_dynp-zzquantity = lv_str1.
      ENDIF.
    ENDIF.
  ELSE."if the system is not able to find a line item associated with the material
    lv_fg = abap_true.
    MESSAGE e051(zits) WITH zsits_scan_dynp-zzmaterial INTO lv_dummy.
  ENDIF.
*Add log and display error message if required
  PERFORM frm_message_add USING zsits_scan_dynp-zzmaterial
                                zcl_its_utility=>gc_objid_material
                                lv_fg.
*In case of error, clear the input blanks
  IF lv_fg = abap_true.
    GET CURSOR FIELD v_cursor_field.
    CLEAR: zsits_scan_dynp-zzmaterial,
           zsits_scan_dynp-zzquantity,
           zsits_scan_dynp-zzquantity_upd,
           zsits_scan_dynp-zzdestbin,
           zsits_scan_dynp-zzdestbin_upd.
  ELSE.
    PERFORM frm_set_cursor.
  ENDIF.

ENDFORM.                    " FRM_MATERIAL_UPDATE
*&---------------------------------------------------------------------*
*&      Form  FRM_DBIN_UPDATE
*&---------------------------------------------------------------------*
*       Form to check validity of destination bin
*----------------------------------------------------------------------*
FORM frm_dbin_update .

  DATA: lv_fg        TYPE            boolean,
        lwa_bin_key  TYPE            zsits_bin_key,
        lwa_bin_data TYPE            zsits_bin_data,
        lv_dummy     TYPE            bapi_msg.

  lwa_bin_key-lgnum                = x_profile-zzlgnum.
  lwa_bin_key-lgtyp                = x_to_item-nltyp.
  lwa_bin_key-lgpla                = zsits_scan_dynp-zzdestbin_upd.
*Call method to check the validity of the destination bin
  CALL METHOD zcl_its_utility=>bin_read
    EXPORTING
      is_bin_key  = lwa_bin_key
    RECEIVING
      rs_bin_data = lwa_bin_data.

  IF lwa_bin_data IS INITIAL. "If no storage bin found
    lv_fg = abap_true.
  ENDIF.

  PERFORM frm_message_add USING zsits_scan_dynp-zzdestbin_upd
                                zcl_its_utility=>gc_objid_bin
                                lv_fg.

  IF lv_fg = abap_true.
    GET CURSOR FIELD v_cursor_field.
    CLEAR zsits_scan_dynp-zzdestbin_upd.
  ELSE.
    PERFORM frm_set_cursor.
  ENDIF.

ENDFORM.                    " FRM_DBIN_UPDATE
*&---------------------------------------------------------------------*
*&      Form  FRM_TO_CONFIRM
*&---------------------------------------------------------------------*
*       Form to confirm TO on a line-item level
*----------------------------------------------------------------------*
FORM frm_to_confirm .

  DATA: lv_fg         TYPE            boolean,
        lwa_to_conf   TYPE            zsits_to_conf,
        lwa_conf_item TYPE LINE OF    zttits_to_conf_item,
        lit_conf_item TYPE            zttits_to_conf_item,
        lv_qty_upd    TYPE            ltap_nsola,
        lv_dummy      TYPE            bapi_msg.

*Assign value for TO confirmation header
  lwa_to_conf-lgnum                = x_profile-zzlgnum.
  lwa_to_conf-tanum                = x_to_data-tanum.
  lwa_to_conf-commit_work          = abap_true.

*Assign value for TO confirmation line item
  lwa_conf_item-tanum              = x_to_data-tanum.
  lwa_conf_item-tapos              = x_to_item-tapos.
  lwa_conf_item-squit              = abap_true.
*If we only assign the value of the dest. bin when it's different from what's already on the TO
  IF zsits_scan_dynp-zzdestbin_upd NE x_to_item-nlpla.
    lwa_conf_item-nlpla            = zsits_scan_dynp-zzdestbin_upd.
  ENDIF.

*If the user enters a different qty, assign value to the "difference" parameter of the method
  IF zsits_scan_dynp-zzquantity_upd NE x_to_item-vsola.
*Convert the char type to QUAN type
    lwa_conf_item-ndifa            = x_to_item-vsola - zsits_scan_dynp-zzquantity_upd.
    lwa_conf_item-nista            = zsits_scan_dynp-zzquantity_upd.
    lwa_conf_item-squit            = abap_false.
  ENDIF.
  lwa_conf_item-altme              = x_to_item-meins.

  APPEND lwa_conf_item TO lit_conf_item.
  lwa_to_conf-to_conf_item         = lit_conf_item.

*Call method to confirm the TO line item
  IF zcl_its_utility=>to_confirm( is_to_conf = lwa_to_conf ) IS NOT INITIAL.
*If the confirmation is successful
    MESSAGE s109(zits) WITH zsits_scan_dynp-zzdestbin_upd INTO zsits_scan_dynp-zzsuccess_msg.
    PERFORM frm_message_add USING zsits_scan_dynp-zzquantity_upd
                                  zcl_its_utility=>gc_objid_quantity
                                  abap_false.

    CALL METHOD zcl_its_utility=>to_read
      EXPORTING
        is_to_key  = x_to_key
      RECEIVING
        rs_to_data = x_to_data.
*If all items on the TO is confirmed, then go back to screen 9000
    IF x_to_data-kquit = abap_true.
      CLEAR: zsits_scan_dynp-zzmaterial,
             zsits_scan_dynp-zzquantity,
             zsits_scan_dynp-zzquantity_upd,
             zsits_scan_dynp-zzdestbin,
             zsits_scan_dynp-zzdestbin_upd,
             zsits_scan_dynp-zzto_num.
      LEAVE TO SCREEN 9000.
*If there's still item on the TO that's not confirmed, move the cursor to material field
    ELSE.
      v_cursor_field               = 'ZSITS_SCAN_DYNP-ZZMATERIAL'.
      MESSAGE s109(zits) WITH zsits_scan_dynp-zzmaterial zsits_scan_dynp-zzdestbin_upd INTO zsits_scan_dynp-zzsuccess_msg.
      CLEAR: zsits_scan_dynp-zzmaterial,
             zsits_scan_dynp-zzquantity,
             zsits_scan_dynp-zzquantity_upd,
             zsits_scan_dynp-zzdestbin,
             zsits_scan_dynp-zzdestbin_upd.

      PERFORM frm_message_add USING zsits_scan_dynp-zzquantity_upd
                                    zcl_its_utility=>gc_objid_quantity
                                    abap_false.
    ENDIF.
  ELSE.
    GET CURSOR FIELD v_cursor_field.
    PERFORM frm_message_add USING zsits_scan_dynp-zzquantity_upd
                                  zcl_its_utility=>gc_objid_quantity
                                  abap_true.
  ENDIF.

ENDFORM.                    " FRM_TO_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  FRM_NEW_TRAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_new_tran .

*  CALL METHOD zcl_its_utility=>leave_2_new_trans( CHANGING co_log = o_log ).
  CALL METHOD zcl_its_utility=>log_object_clear
    CHANGING
      co_log = o_log.

*  LEAVE TO TRANSACTION 'ZLS_NTRAN'.
  CALL TRANSACTION 'ZMDE'.
ENDFORM.                    " FRM_NEW_TRAN
*&---------------------------------------------------------------------*
*&      Form  TO_CLEAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM user_command_9000 .
  CASE sy-ucomm.
    WHEN 'CLR' . "Clears the HU number on the screen
      CLEAR : zsits_scan_dynp-zzto_num , zsits_scan_dynp-zzmaterial,
              zsits_scan_dynp-zzquantity_upd , zsits_scan_dynp-zzdestbin_upd.
    WHEN zcl_its_utility=>gc_okcode_newtran.
      PERFORM frm_new_tran.

    WHEN OTHERS.
  ENDCASE.
ENDFORM.
