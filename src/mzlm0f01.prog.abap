*----------------------------------------------------------------------*
***INCLUDE MZLM0F01 .
*----------------------------------------------------------------------*

form process_ok_codes_0100.

  case save_ok_code.
    when 'NEXT'.
      clear ok_code.
      lv_index = zz_ausw.
      read table lt_menu into ls_menu index lv_index.
      if sy-subrc eq 0.
        if ls_menu-tcode is initial.
          perform stufe_setzen using ls_menu-stufe
                                     ls_menu-zeile
                                     lv_stufe
                                     '+'.
        else.
          call transaction ls_menu-tcode.
        endif.
      endif.
  endcase.

endform.                               " PROCESS_OK_CODES_0100
