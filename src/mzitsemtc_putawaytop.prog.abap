*&---------------------------------------------------------------------*
*& Include          MZITSEMTC_PUTAWAYTOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Table Work Areas
*----------------------------------------------------------------------*
TABLES: zsits_scan_dynp.


*----------------------------------------------------------------------*
* Global Variants Declaration
*----------------------------------------------------------------------*
DATA:  x_to_data      TYPE        zsits_to_data,         ##NEEDED
       x_to_item      TYPE        zsits_to_item,         ##NEEDED
       x_to_key       TYPE        zsits_to_key,          ##NEEDED
       o_log          TYPE REF TO zcl_its_utility,       ##NEEDED
       x_profile      TYPE        zsits_user_profile,    ##NEEDED
       ok_code        TYPE        sy-ucomm,              ##NEEDED
       v_cursor_field TYPE        char50.                ##NEEDED
