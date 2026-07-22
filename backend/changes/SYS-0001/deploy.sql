-- backend/changes/SYS-0001/deploy.sql
SET ECHO ON SERVEROUTPUT ON
PROMPT == SYS-0001 Step 1: Backup ==
@backend/changes/SYS-0001/backup.sql
PROMPT == SYS-0001 Step 2: DDL ==
-- STATUS column block (shown above)
PROMPT == SYS-0001 Step 3: Package ==
@backend/changes/SYS-0001/database/penprod/iteration-01/package/pkg_order_mgmt_spec.sql
@backend/changes/SYS-0001/database/penprod/iteration-01/package/pkg_order_mgmt_body.sql
PROMPT == SYS-0001 Step 4: Register ==
DECLARE
    v_env VARCHAR2(20) := SYS_CONTEXT('USERENV','DB_NAME');
BEGIN
    INSERT INTO TICKET_OBJECTS(TICKET_ID,OBJECT_NAME,OBJECT_TYPE,CHANGE_TYPE,
        ITERATION,DEVELOPER,BRANCH,ENVIRONMENT,NOTES) VALUES
        ('SYS-0001','PKG_ORDER_MGMT','PACKAGE','MODIFY',
         'iteration-01','User A','bugfix/SYS-0001',v_env,'Added GET_ORDER_STATUS');

    INSERT INTO TICKET_OBJECTS(TICKET_ID,OBJECT_NAME,OBJECT_TYPE,CHANGE_TYPE,
        ITERATION,DEVELOPER,BRANCH,ENVIRONMENT,NOTES) VALUES
        ('SYS-0001','PKG_ORDER_MGMT','PACKAGE BODY','MODIFY',
         'iteration-01','User A','bugfix/SYS-0001',v_env,'GET_ORDER_STATUS impl');

    INSERT INTO TICKET_OBJECTS(TICKET_ID,OBJECT_NAME,OBJECT_TYPE,CHANGE_TYPE,
        ITERATION,DEVELOPER,BRANCH,ENVIRONMENT,NOTES) VALUES
        ('SYS-0001','ORDERS','TABLE','MODIFY',
         'iteration-01','User A','bugfix/SYS-0001',v_env,'Added STATUS column');

    COMMIT;
END;
/
PROMPT == SYS-0001 Step 5: Verify ==
SELECT object_name,object_type,status FROM user_objects
WHERE  object_name='PKG_ORDER_MGMT' ORDER BY object_type;
SELECT name,type,line,text FROM user_errors WHERE name='PKG_ORDER_MGMT';
PROMPT SYS-0001 complete. Rollback: @backend/changes/SYS-0001/rollback.sql

