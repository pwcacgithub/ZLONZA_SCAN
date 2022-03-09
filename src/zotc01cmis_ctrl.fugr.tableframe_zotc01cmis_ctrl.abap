*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZOTC01CMIS_CTRL
*   generation date: 24.08.2020 at 08:40:58
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZOTC01CMIS_CTRL    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
