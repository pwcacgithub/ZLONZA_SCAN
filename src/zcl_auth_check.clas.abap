class ZCL_AUTH_CHECK definition
  public
  final
  create public .

public section.

  methods AUTH_CHECK_PLANT
    importing
      !IV_WERKS type WERKS_D
      !IV_ACTIVITY type CHAR2 optional
    returning
      value(ES_BAPIRET2) type BAPIRET2 .
  methods AUTH_CHECK_LGNUM
    importing
      !IV_LGNUM type LGNUM
      !IV_LGTYP type LGTYP optional
    returning
      value(ES_BAPIRET2) type BAPIRET2 .
  methods AUTH_CHECK_MVMT
    importing
      !IV_BWART type BWART
      !IV_ACTIVITY type ACTIV_AUTH
    returning
      value(ES_BAPIRET2) type BAPIRET2 .
  methods AUTH_CHECK_PLANT_DISP
    importing
      !IV_WERKS type WERKS_D
      !IV_ACTIVITY type CHAR2 optional
    returning
      value(ES_BAPIRET2) type BAPIRET2 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AUTH_CHECK IMPLEMENTATION.


  method AUTH_CHECK_LGNUM.
    DATA : lv_dummy TYPE string.
    CLEAR es_bapiret2.
*   These authorization checks are being used in scanner transactions created for DFDS Business.
*    Check Authorization plant and activity
    AUTHORITY-CHECK OBJECT 'L_LGNUM'
             ID 'LGNUM' FIELD iv_lgnum
             ID 'LGTYP' FIELD iv_lgtyp.
    IF sy-subrc <> 0.
      MESSAGE e058(zlone_hu) WITH iv_lgnum INTO lv_dummy.
      es_bapiret2-type = sy-msgty.
      es_bapiret2-id   = sy-msgid.
      es_bapiret2-number = sy-msgno.
      es_bapiret2-message_v1  = sy-msgv1.
      es_bapiret2-message_v2  = sy-msgv2.
      es_bapiret2-message_v3  = sy-msgv3.
      es_bapiret2-message_v4  = sy-msgv4.
    ENDIF.
  endmethod.


  method AUTH_CHECK_MVMT.
    DATA : lv_dummy TYPE string.
    CLEAR es_bapiret2.
*   These authorization checks are being used in scanner transactions created for DFDS Business.
*    Check Authorization plant and activity
    AUTHORITY-CHECK OBJECT 'M_MSEG_BWA'
             ID 'ACTVT' FIELD iv_activity
             ID 'BWART' FIELD iv_bwart.
    IF sy-subrc <> 0.
      MESSAGE e059(zlone_hu) WITH iv_bwart INTO lv_dummy.
      es_bapiret2-type = sy-msgty.
      es_bapiret2-id   = sy-msgid.
      es_bapiret2-number = sy-msgno.
      es_bapiret2-message_v1  = sy-msgv1.
      es_bapiret2-message_v2  = sy-msgv2.
      es_bapiret2-message_v3  = sy-msgv3.
      es_bapiret2-message_v4  = sy-msgv4.
    ENDIF.
  endmethod.


  METHOD auth_check_plant.
    DATA : lv_dummy TYPE string.
    CLEAR es_bapiret2.
*   These authorization checks are being used in scanner transactions created for DFDS Business.
*    Check Authorization plant and activity
    AUTHORITY-CHECK OBJECT 'M_MSEG_WWA'
             ID 'ACTVT' FIELD iv_activity
             ID 'WERKS' FIELD iv_werks.
    IF sy-subrc <> 0.
      MESSAGE e056(zlone_hu) WITH iv_werks INTO lv_dummy.
      es_bapiret2-type = sy-msgty.
      es_bapiret2-id   = sy-msgid.
      es_bapiret2-number = sy-msgno.
      es_bapiret2-message_v1  = sy-msgv1.
      es_bapiret2-message_v2  = sy-msgv2.
      es_bapiret2-message_v3  = sy-msgv3.
      es_bapiret2-message_v4  = sy-msgv4.
    ENDIF.

  ENDMETHOD.


  METHOD AUTH_CHECK_PLANT_DISP.
    DATA : lv_dummy TYPE string.
    CLEAR es_bapiret2.
*   These authorization checks are being used in scanner transactions created for DFDS Business.
*    Check Authorization plant and activity
    AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
             ID 'ACTVT' FIELD iv_activity
             ID 'WERKS' FIELD iv_werks.
    IF sy-subrc <> 0.
      MESSAGE e056(zlone_hu) WITH iv_werks INTO lv_dummy.
      es_bapiret2-type = sy-msgty.
      es_bapiret2-id   = sy-msgid.
      es_bapiret2-number = sy-msgno.
      es_bapiret2-message_v1  = sy-msgv1.
      es_bapiret2-message_v2  = sy-msgv2.
      es_bapiret2-message_v3  = sy-msgv3.
      es_bapiret2-message_v4  = sy-msgv4.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
