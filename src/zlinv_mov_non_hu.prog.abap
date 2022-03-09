*&---------------------------------------------------------------------*
*& Module Pool       ZINV_MOV_NON_HU
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
************************************************************************
* Program ID:                   ZINV_MOV_NON_HU
* Program Title:                Non HU Movements
* Created By:
* Creation Date:
* RICEFW ID:   S0096
* Description:                  Non HU Inventory movements using SCAN
* Tcode     :                   ZNONHU
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* Initial version
*&---------------------------------------------------------------------*

INCLUDE ZINV_MOV_NON_HUTOP                      .    " global Data

 INCLUDE ZINV_MOV_NON_HUO01                      .  " PBO-Modules
 INCLUDE ZINV_MOV_NON_HUI01                      .  " PAI-Modules
 INCLUDE ZINV_MOV_NON_HUF01                      .  " FORM-Routines
