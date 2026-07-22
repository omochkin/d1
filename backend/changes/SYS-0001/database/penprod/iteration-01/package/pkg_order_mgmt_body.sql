
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "G1DEV"."PKG_ORDER_MGMT" AS
    
    -- ========================================================================
    -- INSERT_ORDER
    -- ========================================================================
    
    PROCEDURE INSERT_ORDER(
        p_customer_id IN NUMBER,
        p_order_date IN DATE,
        p_total_amount IN NUMBER,
        p_order_id OUT NUMBER,
        p_status OUT VARCHAR2,
        p_message OUT VARCHAR2
    ) AS
        v_customer_exists NUMBER;
    BEGIN
        -- Validate customer exists
        SELECT COUNT(*) INTO v_customer_exists
        FROM CUSTOMERS
        WHERE CUSTOMER_ID = p_customer_id;

        IF v_customer_exists = 0 THEN
            p_status := 'ERROR';
            p_message := 'Customer ID ' || p_customer_id || ' does not exist';
            RETURN;
        END IF;

        -- Get next order ID
        SELECT SEQ_ORDER_ID.NEXTVAL INTO p_order_id FROM DUAL;

        -- Insert order
        INSERT INTO ORDERS (
            ORDER_ID, CUSTOMER_ID, ORDER_DATE, TOTAL_AMOUNT,
            CREATED_DATE, LAST_UPDATED_DATE
        ) VALUES (
            p_order_id, p_customer_id, p_order_date, p_total_amount,
            SYSDATE, SYSDATE
        );

        COMMIT;

        p_status := 'SUCCESS';
        p_message := 'Order ' || p_order_id || ' created successfully';

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_status := 'ERROR';
            p_message := 'Error creating order: ' || SQLERRM;
    END INSERT_ORDER;

    -- ========================================================================
    -- UPDATE_ORDER
    -- ========================================================================

    PROCEDURE UPDATE_ORDER(
        p_order_id IN NUMBER,
        p_total_amount IN NUMBER,
        p_status OUT VARCHAR2,
        p_message OUT VARCHAR2
    ) AS
        v_order_exists NUMBER;
    BEGIN
        -- Validate order exists
        SELECT COUNT(*) INTO v_order_exists
        FROM ORDERS
        WHERE ORDER_ID = p_order_id;

        IF v_order_exists = 0 THEN
            p_status := 'ERROR';
            p_message := 'Order ID ' || p_order_id || ' does not exist';
            RETURN;
        END IF;

        -- Update order
        UPDATE ORDERS
        SET TOTAL_AMOUNT = p_total_amount,
            LAST_UPDATED_DATE = SYSDATE
        WHERE ORDER_ID = p_order_id;

        COMMIT;

        p_status := 'SUCCESS';
        p_message := 'Order ' || p_order_id || ' updated successfully';

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_status := 'ERROR';
            p_message := 'Error updating order: ' || SQLERRM;
    END UPDATE_ORDER;

    -- ========================================================================
    -- DELETE_ORDER
    -- ========================================================================

    PROCEDURE DELETE_ORDER(
        p_order_id IN NUMBER,
        p_status OUT VARCHAR2,
        p_message OUT VARCHAR2
    ) AS
        v_order_exists NUMBER;
    BEGIN
        -- Validate order exists
        SELECT COUNT(*) INTO v_order_exists
        FROM ORDERS
        WHERE ORDER_ID = p_order_id;

        IF v_order_exists = 0 THEN
            p_status := 'ERROR';
            p_message := 'Order ID ' || p_order_id || ' does not exist';
            RETURN;
        END IF;

        -- Delete order (cascade to order items)
        DELETE FROM ORDERS
        WHERE ORDER_ID = p_order_id;

        COMMIT;

        p_status := 'SUCCESS';
        p_message := 'Order ' || p_order_id || ' deleted successfully';

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_status := 'ERROR';
            p_message := 'Error deleting order: ' || SQLERRM;
    END DELETE_ORDER;

-->>> BEGIN CHANGE: bugfix/SYS-0001
    PROCEDURE GET_ORDER_STATUS(p_order_id IN NUMBER,
        p_status OUT VARCHAR2, p_message OUT VARCHAR2) AS
        v_order_status VARCHAR2(100);
    BEGIN
        SELECT NVL(STATUS,'UNKNOWN') INTO v_order_status
        FROM   ORDERS WHERE ORDER_ID = p_order_id;
        p_status  := v_order_status;
        p_message := 'Order ' || p_order_id || ' status: ' || v_order_status;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_status := 'NOT_FOUND';
            p_message := 'Order ' || p_order_id || ' does not exist';
        WHEN OTHERS THEN p_status := 'ERROR'; p_message := SQLERRM;
    END GET_ORDER_STATUS;
    --<<< END CHANGE: bugfix/SYS-0001

END PKG_ORDER_MGMT;
/
