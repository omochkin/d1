-- backend/changes/SYS-0001/rollback.sql
-- Run: ls backend/changes/SYS-0001/backup/  to list available timestamps
SET ECHO ON SERVEROUTPUT ON
DEFINE v_ts = '20250115_143022'   -- set to your backup timestamp
PROMPT Rolling back SYS-0001 to timestamp: &v_ts
@backend/changes/SYS-0001/backup/pkg_order_mgmt_spec_&v_ts..bkp
@backend/changes/SYS-0001/backup/pkg_order_mgmt_body_&v_ts..bkp
SELECT object_name,object_type,status FROM user_objects
WHERE  object_name='PKG_ORDER_MGMT' ORDER BY object_type;
PROMPT Rollback complete.

