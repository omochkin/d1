COLUMN bkp_ts NEW_VALUE v_ts
SELECT TO_CHAR(SYSDATE,'YYYYMMDD_HH24MISS') AS bkp_ts FROM DUAL;
PROMPT Backing up PKG_ORDER_MGMT at &v_ts ...
SPOOL backend/changes/SYS-0001/backup/pkg_order_mgmt_spec_&v_ts..bkp
DDL PKG_ORDER_MGMT PACKAGE
SPOOL OFF
SPOOL backend/changes/SYS-0001/backup/pkg_order_mgmt_body_&v_ts..bkp
DDL PKG_ORDER_MGMT 'PACKAGE BODY'
SPOOL OFF
PROMPT Backup complete: backup/pkg_order_mgmt_*_&v_ts..bkp

