    -- backend/changes/SYS-0003/deploy.sql
    -- Usage: sql penprod/password@<env> @backend/changes/SYS-0003/deploy.sql
    -- DEV: backup optional.  QA/UAT/STAGE/PROD: backup mandatory (runs automatically).
    SET ECHO ON SERVEROUTPUT ON

    PROMPT ============================================
    PROMPT SYS-0003: Step 1 -- Backup current state
    PROMPT ============================================
    @backend/changes/SYS-0003/backup.sql

    PROMPT ============================================
    PROMPT SYS-0003: Step 2 -- Deploy package
    PROMPT ============================================
    @backend/changes/SYS-0003/database/penprod/iteration-01/package/pkg_order_mgmt_spec.sql
    @backend/changes/SYS-0003/database/penprod/iteration-01/package/pkg_order_mgmt_body.sql

    PROMPT ============================================
    PROMPT SYS-0003: Step 3 -- Register in TICKET_OBJECTS
    PROMPT ============================================
    DECLARE
        v_db  VARCHAR2(20) := SYS_CONTEXT('USERENV','DB_NAME');
        v_env VARCHAR2(20);
    BEGIN
        v_env := CASE v_db
                     WHEN 'd4_g1dev' THEN 'DEV4'
                     WHEN 'd4_g1qa'  THEN 'QA'
                     WHEN 'd4_g1uat' THEN 'UAT'
                     WHEN 'd4_g1stg' THEN 'STAGE'
                     WHEN 'd4_g1prd' THEN 'PROD'
                     ELSE v_db
                 END;
        INSERT INTO TICKET_OBJECTS
            (TICKET_ID,OBJECT_NAME,OBJECT_TYPE,CHANGE_TYPE,
             ITERATION,DEVELOPER,BRANCH,ENVIRONMENT,NOTES)
        VALUES
        -- Package spec: CANCEL_ORDER declaration added
            ('SYS-0003','PKG_ORDER_MGMT','PACKAGE','MODIFY',
             'iteration-01','User B','bugfix/SYS-0003',v_env,
             'Added CANCEL_ORDER declaration');
		INSERT INTO TICKET_OBJECTS
            (TICKET_ID,OBJECT_NAME,OBJECT_TYPE,CHANGE_TYPE,
             ITERATION,DEVELOPER,BRANCH,ENVIRONMENT,NOTES)
        VALUES
        -- Package body: CANCEL_ORDER implementation added
            ('SYS-0003','PKG_ORDER_MGMT','PACKAGE BODY','MODIFY',
             'iteration-01','User B','bugfix/SYS-0003',v_env,
             'Added CANCEL_ORDER implementation');
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Registered 2 objects in TICKET_OBJECTS');
    END;
    /

    -- Verify registration
    SELECT ticket_id, object_name, object_type, change_type, notes
    FROM   ticket_objects
    WHERE  ticket_id = 'SYS-0003'
    AND    environment = SYS_CONTEXT('USERENV','DB_NAME')
    ORDER  BY object_type;
    -- Expected 2 rows:
    --   SYS-0003  PKG_ORDER_MGMT    PACKAGE       MODIFY
    --   SYS-0003  PKG_ORDER_MGMT    PACKAGE BODY  MODIFY

    PROMPT ============================================
    PROMPT SYS-0003: Step 4 -- Verify
    PROMPT ============================================
    SELECT object_name, object_type, status FROM user_objects
    WHERE  object_name='PKG_ORDER_MGMT' ORDER BY object_type;
    SELECT name, type, line, text FROM user_errors WHERE name='PKG_ORDER_MGMT';

    -- Verify TICKET_OBJECTS
    SELECT ticket_id, object_name, object_type, change_type FROM ticket_objects
    WHERE  ticket_id='SYS-0003' AND environment=SYS_CONTEXT('USERENV','DB_NAME')
    ORDER  BY object_type;

    PROMPT SYS-0003 deploy complete.
    PROMPT Rollback: @backend/changes/SYS-0003/rollback.sql
