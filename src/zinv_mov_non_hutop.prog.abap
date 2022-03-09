*&---------------------------------------------------------------------*
*& Include ZINV_MOV_NON_HUTOP    Module Pool      ZINV_MOV_NON_HU
*&
*&---------------------------------------------------------------------*
************************************************************************
* Program ID:                   ZINV_MOV_NON_HU
* Program Title:                Non HU Movements
* Created By:
* Creation Date:
* RICEFW ID:                    S0096
* Description:                  Non HU Inventory movements using SCAN
* Tcode     :                   ZNONHU
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
*Initial version
*&---------------------------------------------------------------------*
PROGRAM zinv_mov_non_hu.

*&---------------------------------------------------------------------*
* Declaration for tables
*&---------------------------------------------------------------------*
TABLES: zsits_user_profile, zsits_scan_dynp.

*&---------------------------------------------------------------------*
*& Declaration for Constants
*&---------------------------------------------------------------------*
CONSTANTS: gc_okcode_clear TYPE syucomm   VALUE 'CLEAR',
           gc_x(1)         TYPE c VALUE 'X',
           gc_e(1)         TYPE c VALUE 'E'.

*&---------------------------------------------------------------------*
*& Declaration for Structures
*&---------------------------------------------------------------------*
DATA: gs_batch_data TYPE zsits_batch_data,      "For Batch read method
      gs_mat_data   TYPE zsits_material_data,   "For Material read method
      gs_ltap       TYPE ltap.                  "TO Item.

*&---------------------------------------------------------------------*
*& Declaration for variables
*&---------------------------------------------------------------------*
DATA: gv_cursor_field    TYPE char50,   "TO get & set the cursur position
      gv_validation_fail TYPE boolean,  "Flag to indicate errors
      gv_stoloc          TYPE char25,   "Source Location to diaplay on the screen
      gv_stobin          TYPE char25,   "Storage Bin to diaplay on the screen
      gv_batch           TYPE char25,   "Batch to diaplay on the screen
      gv_material        TYPE char25,   "Material to diaplay on the screen
      gv_sto_cat         TYPE char25,   "Stock category to diaplay on the screen
      gv_qty             TYPE menge_d,  "Quantity to diaplay on the screen
      gv_with_message    TYPE boolean,  "Flag to diaply the error mesages on the screen
      gv_dummy           TYPE string,   "Dummy variable to store the messages
      gv_suc_msg         TYPE string,   "Success message
      gv_suc1            TYPE string,   "Success message 1
      gv_suc2            TYPE string,   "Success message 1
      gv_tonum           TYPE ltak-tanum,  "TO Number
      gv_button          TYPE char10,      "Variable to store button value
      gv_mblnr           TYPE mblnr,       "Material Doc Number
      gv_mvt_type        TYPE bwart,       "Movement type for MIGO postings
      gv_qty_zero        TYPE flag.        "Flag to indicate the zero qty

*&---------------------------------------------------------------------*
*& Declaration for Objects
*&---------------------------------------------------------------------*
DATA: go_log  TYPE REF TO zcl_its_utility.    " Object for Utility class
