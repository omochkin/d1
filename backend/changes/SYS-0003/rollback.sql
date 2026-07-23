    -- backend/changes/SYS-0003/rollback.sql
    -- Run: ls backend/changes/SYS-0003/backup/  to see available timestamps
    -- Usage: sql penprod/password@<env> @backend/changes/SYS-0003/rollback.sql
    SET ECHO ON SERVEROUTPUT ON

    -- Set timestamp to restore (from ls backend/changes/SYS-0003/backup/ output)
    DEFINE v_ts = '20250115_143022'

    PROMPT Rolling back SYS-0003 to backup timestamp: &v_ts
    @backend/changes/SYS-0003/backup/pkg_order_mgmt_spec_&v_ts..bkp
    @backend/changes/SYS-0003/backup/pkg_order_mgmt_body_&v_ts..bkp

    SELECT object_name, object_type, status FROM user_objects
    WHERE  object_name='PKG_ORDER_MGMT' ORDER BY object_type;
    SELECT name, type, line, text FROM user_errors WHERE name='PKG_ORDER_MGMT';
    PROMPT Rollback complete.
