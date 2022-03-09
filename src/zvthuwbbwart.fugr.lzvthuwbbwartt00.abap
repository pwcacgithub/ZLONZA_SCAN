*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 27.08.2020 at 07:25:06
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZTITS_THUWBBWART................................*
DATA:  BEGIN OF STATUS_ZTITS_THUWBBWART              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITS_THUWBBWART              .
CONTROLS: TCTRL_ZTITS_THUWBBWART
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTITS_THUWBBWART              .
TABLES: ZTITS_THUWBBWART               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
