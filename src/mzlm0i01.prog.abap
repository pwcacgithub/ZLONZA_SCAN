*----------------------------------------------------------------------*
***INCLUDE MZLM0I01 .
*----------------------------------------------------------------------*
module exit_command input.

  case sy-dynnr.
    when '0100'.
      case ok_code.
        when 'BACK'.
          perform stufe_setzen using ls_menu-stufe
                                     ls_menu-zeile
                                     lv_stufe
                                     '-'.
      endcase.
    when '0999'.
      case ok_code.
        when 'BACK'.
      endcase.
  endcase.

endmodule.                             " EXIT_COMMAND  INPUT


*---------------------------------------------------------------------*
*       MODULE USER_COMMANDS INPUT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module user_commands input.

  case sy-dynnr.
    when '0100'.
      perform process_ok_codes_0100.
  endcase.

endmodule.                             " USER_COMMANDS  INPUT

*---------------------------------------------------------------------*
*       MODULE COPY_OK_CODE INPUT                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module copy_ok_code input.

  save_ok_code = ok_code.
  clear ok_code.

endmodule.                             " COPY_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_d100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module check_d100 input.


endmodule.                 " check_d100  INPUT
