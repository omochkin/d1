-- backend/changes/SYS-0002/deploy.sql
-- Usage: sql penprod/password@<env> @backend/changes/SYS-0002/deploy.sql
-- DEV: backup optional.  QA/UAT/STAGE/PROD: backup mandatory (runs automatically).
SET ECHO ON SERVEROUTPUT ON

PROMPT ============================================
PROMPT SYS-0002: Step 1 -- Backup current state
PROMPT ============================================
@backend/changes/SYS-0002/backup.sql

PROMPT ============================================
PROMPT SYS-0002: Step 2 -- Deploy package
PROMPT ============================================
@backend/changes/SYS-0002/database/penprod/iteration-01/package/pkg_order_mgmt_spec.sql
@backend/changes/SYS-0002/database/penprod/iteration-01/package/pkg_order_mgmt_body.sql

PROMPT ============================================
PROMPT SYS-0002: Step 3 -- Register in TICKET_OBJECTS
PROMPT ============================================
DECLARE v_env VARCHAR2(20) := SYS_CONTEXT('USERENV','DB_NAME');
BEGIN
    INSERT INTO TICKET_OBJECTS
        (TICKET_ID,OBJECT_NAME,OBJECT_TYPE,CHANGE_TYPE,
         ITERATION,DEVELOPER,BRANCH,ENVIRONMENT,NOTES)
    VALUES
    -- Package spec: GET_ORDERS_BY_CUSTOMER declaration added
        ('SYS-0002','PKG_ORDER_MGMT','PACKAGE','MODIFY',
         'iteration-01','User A','bugfix/SYS-0002',v_env,
         'Added GET_ORDERS_BY_CUSTOMER declaration');
    COMMIT;
    INSERT INTO TICKET_OBJECTS
        (TICKET_ID,OBJECT_NAME,OBJECT_TYPE,CHANGE_TYPE,
         ITERATION,DEVELOPER,BRANCH,ENVIRONMENT,NOTES)
    VALUES
    -- Package body: GET_ORDERS_BY_CUSTOMER implementation added
        ('SYS-0002','PKG_ORDER_MGMT','PACKAGE BODY','MODIFY',
         'iteration-01','User A','bugfix/SYS-0002',v_env,
         'Added GET_ORDERS_BY_CUSTOMER implementation');
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Registered 2 objects in TICKET_OBJECTS');
END;
/

-- Verify registration
SELECT ticket_id, object_name, object_type, change_type, notes
FROM   ticket_objects
WHERE  ticket_id = 'SYS-0002'
AND    environment = SYS_CONTEXT('USERENV','DB_NAME')
ORDER  BY object_type;
-- Expected 2 rows:
--   SYS-0002  PKG_ORDER_MGMT    PACKAGE       MODIFY
--   SYS-0002  PKG_ORDER_MGMT    PACKAGE BODY  MODIFY

PROMPT ============================================
PROMPT SYS-0002: Step 4 -- Verify
PROMPT ============================================
SELECT object_name, object_type, status FROM user_objects
WHERE  object_name='PKG_ORDER_MGMT' ORDER BY object_type;
SELECT name, type, line, text FROM user_errors WHERE name='PKG_ORDER_MGMT';
PROMPT SYS-0002 deploy complete.
PROMPT Rollback: @backend/changes/SYS-0002/rollback.sql

