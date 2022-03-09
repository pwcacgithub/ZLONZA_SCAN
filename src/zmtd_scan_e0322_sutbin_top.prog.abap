*&---------------------------------------------------------------------*
*& Include ZMTD_SCAN_E0322_SUTBIN_TOP                        Module Pool      ZMTD_SCAN_E0322_SUTBIN
*&
*&---------------------------------------------------------------------*
***********************************************************************
* PROGRAM DECLARATION
***********************************************************************
* PROGRAM ID:         ZMTD_SCAN_E0322_SUTBIN
* AUTHOR Name:        Anup Varghese
* OWNER(Process Team) Lakshmikumar Reddy
* CREATE DATE:        11/11/2016
* ECC RELEASE VERSION 6.0
* BASED-ON PROGRAM:   None
* Object ID:          E0322
* DESCRIPTION :       This SCAN development is required to move storage
*                     units between storage bins
***********************************************************************
* VERSION CONTROL (Most recent on top):
* DATE             AUTHOR       CTS REQ        DESCRIPTION
*----------------------------------------------------------------------

***********************************************************************

PROGRAM  zmtd_scan_e0322_sutbin.

***********************************************************************
* Tables
***********************************************************************
TABLES :
  zsits_scan_dynp.

***********************************************************************
* Structures
***********************************************************************
DATA :
  wa_profile TYPE zsits_user_profile,
  wa_label   TYPE zsits_label_content,
  wa_su      TYPE zsits_scan_dynp-zzsu.

***********************************************************************
* Internal Tables
***********************************************************************
DATA :
  it_label TYPE TABLE OF zsits_label_content,
  it_su    TYPE TABLE OF zsits_scan_dynp-zzsu.

***********************************************************************
* Variables
***********************************************************************

DATA :
  ok_code      TYPE sy-ucomm,
  v_dummy      TYPE string,
  v_flag       TYPE c,
  v_hu_counter TYPE i,
  v_hu_txt     TYPE char3,
  v_lgtyp      TYPE lagp-lgtyp,
  v_barcode    TYPE zsits_scan_dynp-zzbarcode,
  o_log        TYPE REF TO zcl_its_utility.



***********************************************************************
* Controls
***********************************************************************

CONTROLS ztblctrl_su TYPE TABLEVIEW USING SCREEN 9010.

*--Begin of changes added by MMEHTA
TYPES :       BEGIN OF ts_lenum,
                su1 TYPE lenum,
                su2 TYPE lenum,
                su3 TYPE lenum,
              END OF ts_lenum.

DATA : go_hu    TYPE REF TO zcl_rfscanner_packunpack,

       gv_su1   TYPE lein-lenum,
       gv_su2   TYPE lein-lenum,
       gv_su3   TYPE lein-lenum,
       gt_lenum TYPE TABLE OF ts_lenum,
       gv_index TYPE sy-index,
*--End of changes  by MMEHT.
*  Begin of changes by rvenugopalan EICR 603418
       GV_DESTBINNO type zsits_scan_dynp-zzdestbin.
*  Endo of changes by rvenugopalan EICR 603418
