*&---------------------------------------------------------------------*
*&  Include           MZITSEWM_PHYS_INVTOP
*&---------------------------------------------------------------------*

PROGRAM  sapmzitsewm_phys_inv.

*----------------------------------------------------------------------*
* Table Work Areas
*----------------------------------------------------------------------*
TABLES: zsits_scan_dynp.

*----------------------------------------------------------------------*
* Local Data Types in Program
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_bin,
         lgpla TYPE lgpla, "Storage bin
       END   OF ty_bin,
       ty_t_bin TYPE STANDARD TABLE OF ty_bin.

TYPES: BEGIN OF ty_batch,
         charg TYPE charg_d, "Batch
       END   OF ty_batch,
       ty_t_batch TYPE STANDARD TABLE OF ty_batch.

TYPES : tt_zlwminvdoc TYPE STANDARD TABLE OF zlwminvdoc.
*----------------------------------------------------------------------*
* Global Internal Tables Declaration
*----------------------------------------------------------------------*
DATA:
  it_linv    TYPE STANDARD TABLE OF linv_vb,                "#EC NEEDED
  is_su_data TYPE zsits_su_content.                         "#EC NEEDED

DATA: it_completed_bin    TYPE ty_t_bin,                    "#EC NEEDED
      it_counted_rm_batch TYPE ty_t_batch,                  "#EC NEEDED
      gt_zlwminvdoc       TYPE STANDARD TABLE OF zlwminvdoc . "#EC NEEDED

*----------------------------------------------------------------------*
* Global Variants Declaration
*----------------------------------------------------------------------*
DATA: o_log           TYPE REF TO zcl_its_utility,          "#EC NEEDED
      ok_code         TYPE sy-ucomm,
      x_profile       TYPE zsits_user_profile,              "#EC NEEDED
      s_label_content TYPE zsits_label_content,
      v_su_m_bool     TYPE boolean,
      v_storage_type  TYPE lgtyp,
      v_bin_on_doc    TYPE boolean,
      v_back_flag     TYPE boolean,   " TRUE: back to 9000
      x_linv          TYPE linv_vb,
      v_code          TYPE sy-ucomm,
      v_batch_mgmt    TYPE boolean,
      v_error_ind     TYPE xfeld,
      v_cursor_field  TYPE char50,
      c_n             TYPE char1 VALUE 'N',
      c_010           TYPE char3 VALUE 10,
      c_021           TYPE char3 VALUE 21,
      c_030           TYPE char3 VALUE 30,
      c_090           TYPE char3 VALUE 90,
      c_240           TYPE char3 VALUE 240,
      c_241           TYPE char3 VALUE 241,
      c_310           TYPE char3 VALUE 310,
      c_9000          TYPE char4 VALUE 9000,
      c_9100          TYPE char4 VALUE 9100,
      c_9200          TYPE char4 VALUE 9200.
