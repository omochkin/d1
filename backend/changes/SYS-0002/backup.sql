   -- backend/changes/SYS-0002/backup.sql
    -- Extracts PKG_ORDER_MGMT to timestamped .bkp files before any deployment
    -- Usage: sql penprod/password@<env> @backend/changes/SYS-0002/backup.sql
    -- Safe to run multiple times -- each run creates new timestamped pair

    SET TERMOUT ON ECHO OFF

    -- Generate timestamp for unique filenames
    COLUMN bkp_ts NEW_VALUE v_ts
    SELECT TO_CHAR(SYSDATE,'YYYYMMDD_HH24MISS') AS bkp_ts FROM DUAL;
    PROMPT Backing up PKG_ORDER_MGMT at &v_ts ...

    -- Configure DDL output: suppress EDITIONABLE and schema prefix
    SET DDL OFF
    SET DDL SQLTERMINATOR ON
    SET DDL PRETTY ON

    -- Backup spec
    SPOOL backend/changes/SYS-0002/backup/pkg_order_mgmt_spec_&v_ts..bkp
    DDL PKG_ORDER_MGMT PACKAGE
    SPOOL OFF

    -- Backup body
    SPOOL backend/changes/SYS-0002/backup/pkg_order_mgmt_body_&v_ts..bkp
    DDL PKG_ORDER_MGMT 'PACKAGE BODY' 
    SPOOL OFF

    PROMPT Backup saved:
    PROMPT   backend/changes/SYS-0002/backup/pkg_order_mgmt_spec_&v_ts..bkp
    PROMPT   backend/changes/SYS-0002/backup/pkg_order_mgmt_body_&v_ts..bkp
    PROMPT Run: ls backend/changes/SYS-0002/backup/ to see all available restore points
