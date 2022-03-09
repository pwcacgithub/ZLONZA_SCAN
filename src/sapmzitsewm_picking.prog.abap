***********************************************************************
* PROGRAM DECLARATION
***********************************************************************
* PROGRAM ID:         SAPMZITSEWM_PICKING
* AUTHOR Name:
* OWNER(Process Team):SCANNING
* CREATE DATE:
* ECC RELEASE VERSION 6.0
* BASED-ON PROGRAM:   none
* Object ID:
* DESCRIPTION :       Buisness requires an SAP ITS
*                     transaction that will allow them to pick pallets,
*                     partial pallets, loose cartons and
*                     rolled up cartons (RM) to the shipping lane in DC.
***********************************************************************
* VERSION CONTROL (Most recent on top):
* DATE             AUTHOR       CTS REQ        DESCRIPTION
*----------------------------------------------------------------------
***********************************************************************
INCLUDE mzitsewm_pickingtop. "global Data
INCLUDE mzitsewm_pickingo01. "PBO-Modules
INCLUDE mzitsewm_pickingi01. "PAI-Modules
INCLUDE mzitsewm_pickingf01. "FORM-Routines
