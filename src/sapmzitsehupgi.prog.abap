**********************************************************
* PROGRAM DECLARATION
**********************************************************
* PROGRAM ID:         SAPMZITSEHUPGI
* AUTHOR Name:
* OWNER(Process Team):Scanning
* CREATE DATE:
* ECC RELEASE VERSION 6.0
* BASED-ON PROGRAM:   none
* Object ID:
* DESCRIPTION :       Business requires an ITS transaction scan transaction
*                     that issues raw material to a process order.
*                     Most raw materials are managed in Handling
*                     Unit and have 2-D Data Matrix barcode label on
*                     each handling unit (HU). The barcode will contains
*                     HU number, material, batch and quantity in base
*                     Unit of Measure. For materials that are not
*                     managed in handling unit. It will only
*                     contains material, batch and quantity. .

**********************************************************
* VERSION CONTROL (Most recent on top):
* DATE            AUTHOR                TR No
**********************************************************

INCLUDE MZITSEHUPGITOP.

INCLUDE MZITSEHUPGII01.

INCLUDE MZITSEHUPGIO01.

INCLUDE MZITSEHUPGIF01.
