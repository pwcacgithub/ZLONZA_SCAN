*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 24.08.2020 at 08:40:59
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZTOTC_CMIS_CTRL.................................*
DATA:  BEGIN OF STATUS_ZTOTC_CMIS_CTRL               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTOTC_CMIS_CTRL               .
CONTROLS: TCTRL_ZTOTC_CMIS_CTRL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTOTC_CMIS_CTRL               .
TABLES: ZTOTC_CMIS_CTRL                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
