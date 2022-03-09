*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 26.08.2020 at 05:21:03
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZTOTC_RES_BATCH.................................*
DATA:  BEGIN OF STATUS_ZTOTC_RES_BATCH               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTOTC_RES_BATCH               .
CONTROLS: TCTRL_ZTOTC_RES_BATCH
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTOTC_RES_BATCH               .
TABLES: ZTOTC_RES_BATCH                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
