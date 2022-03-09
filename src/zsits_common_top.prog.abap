*&---------------------------------------------------------------------*
*&  Include           ZSITS_COMMON_TOP
*&---------------------------------------------------------------------*
TABLES:
  zsits_scan_dynp_key,
  zsits_scan_dynp.

*----------------------------------------------------------------------*
* Global Variants Declaration
*----------------------------------------------------------------------*
DATA: o_log           TYPE REF TO zcl_its_utility,
      x_profile       TYPE zsits_user_profile,
      it_bin          TYPE STANDARD TABLE OF zsits_scan_dynp,
      it_original     TYPE STANDARD TABLE OF zsits_scan_dynp,
      it_pallet       TYPE STANDARD TABLE OF zsits_scan_dynp,
      it_batch        TYPE STANDARD TABLE OF zsits_scan_dynp.

CONSTANTS:
  gc_okcode_save       TYPE syucomm   VALUE 'SAVE',
  gc_okcode_back       TYPE syucomm   VALUE 'BACK',
  gc_okcode_add        TYPE syucomm   VALUE 'ADD',
  gc_okcode_newtran    TYPE syucomm   VALUE 'NTRAN',
  gc_okcode_clear      TYPE syucomm   VALUE 'CLEAR',
  gc_okcode_enter      TYPE syucomm   VALUE 'ENTR',
  gc_okcode_logoff     TYPE syucomm   VALUE 'LOFF',
  gc_okcode_upd_loc    TYPE syucomm   VALUE 'UPDL',
  gc_okcode_yes        TYPE syucomm   VALUE 'CYES',
  gc_okcode_no         TYPE syucomm   VALUE 'CNO'.
