***********************************************************************
* PROGRAM DECLARATION
***********************************************************************
* PROGRAM ID:         SAPMZITSE_PICKING_SCAN
* AUTHOR Name:        Dragon He
* OWNER(Process Team):Lakshmikumar Reddy
* CREATE DATE:        4/18/2016
* ECC RELEASE VERSION 6.0
* BASED-ON PROGRAM:   none
* Object ID:          E0305
* DESCRIPTION :       This custom scan transaction to have capability to
*                     read a WM transfer order number printed on picking
*                     slip and user then scans individual storage units
*                     being picked
***********************************************************************
* VERSION CONTROL (Most recent on top):
* DATE             AUTHOR       CTS REQ        DESCRIPTION
*----------------------------------------------------------------------
* 4/18/2016      Dragon He      ED2K908112     Initial

PROGRAM  sapmzitse_picking_scan.

INCLUDE sapmzitse_picking_scan_t01.
INCLUDE sapmzitse_picking_scan_o01.
INCLUDE sapmzitse_picking_scan_i01.
INCLUDE sapmzitse_picking_scan_f01.
