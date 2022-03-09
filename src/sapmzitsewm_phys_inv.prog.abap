***********************************************************************
* PROGRAM DECLARATION
***********************************************************************
* PROGRAM ID:         SAPMZITSEWM_PHYS_INV
* AUTHOR Name:        Li, Xiao
* OWNER(Process Team):Scanning
* CREATE DATE:        11/06/2014
* ECC RELEASE VERSION 6.0
* BASED-ON PROGRAM:   none
* Object ID:          E0145
* DESCRIPTION :       Capsugel’s HC and DFS business require an ITS
*                     transaction that will allow them to perform
*                     annual physical inventory of finished goods,
*                     intermediates and raw materials in the DC.
***********************************************************************
* VERSION CONTROL (Most recent on top):
* DATE             AUTHOR       CTS REQ        DESCRIPTION
*----------------------------------------------------------------------
* 11/06/2014       Li, Xiao/May ED2K901099    Original Version
***********************************************************************
INCLUDE mzitsewm_phys_invtop                  .  " Global Data
INCLUDE mzitsewm_phys_invo01                  .  " PBO-Modules
INCLUDE mzitsewm_phys_invi01                  .  " PAI-Modules
INCLUDE mzitsewm_phys_invf01                  .  " FORM-Routines
