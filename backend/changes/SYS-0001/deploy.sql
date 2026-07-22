-- backend/changes/SYS-0001/deploy.sql
-- Usage: sql penprod/password@<env> @backend/changes/SYS-0001/deploy.sql
-- DEV: backup optional.  QA/UAT/STAGE/PROD: backup mandatory (runs automatically).
SET ECHO ON SERVEROUTPUT ON

PROMPT ============================================
PROMPT SYS-0001: Step 1 -- Backup current state
PROMPT ============================================
@backend/changes/SYS-0001/backup.sql

PROMPT ============================================
PROMPT SYS-0001: Step 2 -- DDL (STATUS column)
PROMPT ============================================
DECLARE v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM user_tab_columns
    WHERE  table_name='ORDERS' AND column_name='STATUS';
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE
            'ALTER TABLE ORDERS ADD (STATUS VARCHAR2(50) DEFAULT ' ||
            ''' PENDING'' )' ;
        DBMS_OUTPUT.PUT_LINE('STATUS column added');
    ELSE DBMS_OUTPUT.PUT_LINE('STATUS column already exists');
    END IF;
END;
/
PROMPT ============================================
PROMPT SYS-0001: Step 3 -- Deploy package
PROMPT ============================================
@backend/changes/SYS-0001/database/penprod/iteration-01/package/pkg_order_mgmt_spec.sql
@backend/changes/SYS-0001/database/penprod/iteration-01/package/pkg_order_mgmt_body.sql

PROMPT ============================================
PROMPT SYS-0001: Step 4 -- Register in TICKET_OBJECTS
PROMPT ============================================
DECLARE v_env VARCHAR2(20) := SYS_CONTEXT('USERENV','DB_NAME'); BEGIN
    INSERT INTO TICKET_OBJECTS
        (TICKET_ID,OBJECT_NAME,OBJECT_TYPE,CHANGE_TYPE,
         ITERATION,DEVELOPER,BRANCH,ENVIRONMENT,NOTES)
    VALUES
        ('SYS-0001','PKG_ORDER_MGMT','PACKAGE','MODIFY',
         'iteration-01','User A','bugfix/SYS-0001',v_env,'Added GET_ORDER_STATUS');
    COMMIT; DBMS_OUTPUT.PUT_LINE('Registered in TICKET_OBJECTS');
	INSERT INTO TICKET_OBJECTS
        (TICKET_ID,OBJECT_NAME,OBJECT_TYPE,CHANGE_TYPE,
         ITERATION,DEVELOPER,BRANCH,ENVIRONMENT,NOTES)
    VALUES
        ('SYS-0001','PKG_ORDER_MGMT','PACKAGE','MODIFY',
         'iteration-01','User A','bugfix/SYS-0001',v_env,'Added GET_ORDER_STATUS');
    COMMIT; DBMS_OUTPUT.PUT_LINE('Registered in TICKET_OBJECTS');
	INSERT INTO TICKET_OBJECTS
        (TICKET_ID,OBJECT_NAME,OBJECT_TYPE,CHANGE_TYPE,
         ITERATION,DEVELOPER,BRANCH,ENVIRONMENT,NOTES)
    VALUES
        ('SYS-0001','ORDERS','TABLE','MODIFY',
         'iteration-01','User A','bugfix/SYS-0001',v_env,'Added STATUS column');
    COMMIT; DBMS_OUTPUT.PUT_LINE('Registered in TICKET_OBJECTS');
END;
/

PROMPT ============================================
PROMPT SYS-0001: Step 5 -- Verify
PROMPT ============================================
SELECT object_name, object_type, status FROM user_objects
WHERE  object_name='PKG_ORDER_MGMT' ORDER BY object_type;
SELECT name, type, line, text FROM user_errors WHERE name='PKG_ORDER_MGMT';

-- Verify DDL: STATUS column must exist
SELECT column_name, data_type, data_default FROM user_tab_columns
WHERE  table_name='ORDERS' AND column_name='STATUS';
-- Expected: STATUS  VARCHAR2(50)  PENDING

PROMPT SYS-0001 deploy complete.
PROMPT Rollback: @backend/changes/SYS-0001/rollback.sql

