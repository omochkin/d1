-- ============================================================================
-- extract-baseline.sql
-- Usage: sql -name d4_g1dev @backend/scripts/database/extract-baseline.sql
-- ============================================================================

SET ECHO OFF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LONG 1000000
SET LINESIZE 32767
SET TRIMSPOOL ON
SET SERVEROUTPUT ON


BEGIN
  DBMS_METADATA.set_transform_param(DBMS_METADATA.session_transform, 'SEGMENT_ATTRIBUTES', TRUE);
  DBMS_METADATA.set_transform_param(DBMS_METADATA.session_transform, 'TABLESPACE', TRUE);
END;
/


-- Clean DDL transforms
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE',false);
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',true);
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',true);
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',true);
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform,'EMIT_SCHEMA',false);


PROMPT Extracting baseline for schema: penprod
PROMPT =========================================

-- ── TABLES ──────────────────────────────────────────────────────────────────
PROMPT Extracting tables...

DECLARE
    v_ddl CLOB;
BEGIN
    FOR t IN (SELECT table_name FROM user_tables ORDER BY table_name) LOOP
        v_ddl := dbms_metadata.get_ddl('TABLE', t.table_name);
        -- Write via UTL_FILE or use individual SPOOLs below
        DBMS_OUTPUT.PUT_LINE('-- Extracted: ' || t.table_name);
    END LOOP;
END;
/

-- Tables (explicit spool per object)
SPOOL backend/database/baseline/penprod/table/customers.sql
SELECT dbms_metadata.get_ddl('TABLE','CUSTOMERS') FROM dual;
SPOOL OFF

SPOOL backend/database/baseline/penprod/table/orders.sql
SELECT dbms_metadata.get_ddl('TABLE','ORDERS') FROM dual;
SPOOL OFF

SPOOL backend/database/baseline/penprod/table/order_items.sql
SELECT dbms_metadata.get_ddl('TABLE','ORDER_ITEMS') FROM dual;
SPOOL OFF

SPOOL backend/database/baseline/penprod/table/shipping_addresses.sql
SELECT dbms_metadata.get_ddl('TABLE','SHIPPING_ADDRESSES') FROM dual;
SPOOL OFF

-- ── SEQUENCES ───────────────────────────────────────────────────────────────
PROMPT Extracting sequences...

SPOOL backend/database/baseline/penprod/sequence/seq_customer_id.sql
SELECT dbms_metadata.get_ddl('SEQUENCE','SEQ_CUSTOMER_ID') FROM dual;
SPOOL OFF

SPOOL backend/database/baseline/penprod/sequence/seq_order_id.sql
SELECT dbms_metadata.get_ddl('SEQUENCE','SEQ_ORDER_ID') FROM dual;
SPOOL OFF

SPOOL backend/database/baseline/penprod/sequence/seq_order_item_id.sql
SELECT dbms_metadata.get_ddl('SEQUENCE','SEQ_ORDER_ITEM_ID') FROM dual;
SPOOL OFF

SPOOL backend/database/baseline/penprod/sequence/seq_address_id.sql
SELECT dbms_metadata.get_ddl('SEQUENCE','SEQ_ADDRESS_ID') FROM dual;
SPOOL OFF

-- ── INDEXES (custom only, skip PK/UK — recreated by table DDL) ──────────────
PROMPT Extracting indexes...

SPOOL backend/database/baseline/penprod/index/idx_orders_customer.sql
SELECT dbms_metadata.get_ddl('INDEX','IDX_ORDERS_CUSTOMER') FROM dual;
SPOOL OFF

SPOOL backend/database/baseline/penprod/index/idx_orders_date.sql
SELECT dbms_metadata.get_ddl('INDEX','IDX_ORDERS_DATE') FROM dual;
SPOOL OFF

SPOOL backend/database/baseline/penprod/index/idx_order_items_order.sql
SELECT dbms_metadata.get_ddl('INDEX','IDX_ORDER_ITEMS_ORDER') FROM dual;
SPOOL OFF

SPOOL backend/database/baseline/penprod/index/idx_shipping_customer.sql
SELECT dbms_metadata.get_ddl('INDEX','IDX_SHIPPING_CUSTOMER') FROM dual;
SPOOL OFF

-- ── PACKAGES ────────────────────────────────────────────────────────────────
PROMPT Extracting packages...

SPOOL backend/database/baseline/penprod/package/pkg_order_mgmt_spec.sql
ddl PKG_ORDER_MGMT PACKAGE
SPOOL OFF

echo '-----------------------------------------------------------------------'
SPOOL backend/database/baseline/penprod/package/pkg_order_mgmt_body.sql
ddl PKG_ORDER_MGMT 'PACKAGE BODY'
SPOOL OFF

PROMPT =========================================
PROMPT Baseline extraction complete.
PROMPT Review files in backend/database/baseline/penprod/
PROMPT Then: git add . 
PROMPT       git commit -m "baseline: extract current penprod schema"
PROMPT =========================================