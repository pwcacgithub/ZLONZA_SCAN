*&---------------------------------------------------------------------*
*& Include MZITSENEWTRAN_TOP                                 Module Pool      SAPMZITSE_NEWTRAN
*&
*&---------------------------------------------------------------------*

* Common Top
INCLUDE zsits_common_top.

TABLES: zsits_user_profile.

DATA:   io_log             TYPE REF TO ZCL_ITS_UTILITY,
        ok_code            TYPE sy-ucomm,
        iv_cursor_field    TYPE char50,
        iv_validation_fail TYPE boolean.
