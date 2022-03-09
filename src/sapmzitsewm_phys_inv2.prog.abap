***********************************************************************
* PROGRAM DECLARATION
***********************************************************************
* PROGRAM ID:         SAPMZITSEWM_PHYS_INV
* AUTHOR Name:
* OWNER(Process Team):Scanning
* CREATE DATE:
* ECC RELEASE VERSION 6.0
* BASED-ON PROGRAM:   none
* Object ID:
* DESCRIPTION :       Business require an ITS
*                     transaction that will allow them to perform
*                     annual physical inventory of finished goods,
*                     intermediates and raw materials in the DC.
***********************************************************************
* VERSION CONTROL (Most recent on top):
* DATE             AUTHOR       CTS REQ        DESCRIPTION
*----------------------------------------------------------------------
***********************************************************************
INCLUDE MZITSEWM_PHYS_INV2TOP.
*INCLUDE mzitsewm_phys_invtop                  .  " Global Data
INCLUDE MZITSEWM_PHYS_INV2O01.
*INCLUDE mzitsewm_phys_invo01                  .  " PBO-Modules
INCLUDE MZITSEWM_PHYS_INV2I01.
*INCLUDE mzitsewm_phys_invi01                  .  " PAI-Modules
INCLUDE MZITSEWM_PHYS_INV2F01.
*INCLUDE mzitsewm_phys_invf01                  .  " FORM-Routines
