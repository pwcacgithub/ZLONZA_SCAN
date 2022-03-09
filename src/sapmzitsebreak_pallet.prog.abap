***********************************************************
* PROGRAM DECLARATION
**********************************************************
* PROGRAM ID:         SAPMZITSEBATCH_OFF_PALLET
* AUTHOR Name:        Shiladitya Ghosh
* OWNER(Process Team):
* CREATE DATE:        08/24/2020
* ECC RELEASE VERSION 6.0
* BASED-ON PROGRAM:   none
* DESCRIPTION :       business require an SAP ITS transaction that
*                     will allow them to break a pallet or
*                     unit in to individual cartons (FG
*                     batches) in their respective plants.
**********************************************************
* VERSION CONTROL (Most recent on top):
* DATE        AUTHOR    CTS         DESCRIPTION
*---------------------------------------------------------
*
***********************************************************
PROGRAM sapmzitsebreak_pallet.

INCLUDE mzitsebreak_pallettop                   .  " global Data
INCLUDE mzitsebreak_palleto01                   .  " PBO-Modules
INCLUDE mzitsebreak_palleti01                   .  " PAI-Modules
INCLUDE mzitsebreak_palletf01                   .  " FORM-Routines
