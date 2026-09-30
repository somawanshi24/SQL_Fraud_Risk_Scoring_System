

CREATE FUNCTION calculated_risk_score(
    p_type_id INT,
    p_amount DECIMAL(18,2),
    p_oldbalance_org DECIMAL(18,2),
    p_newbalance_orig DECIMAL(18,2),
    p_oldbalance_dest DECIMAL(18,2),
    p_newbalance_dest DECIMAL(18,2)
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_score INT DEFAULT 0;
    DECLARE v_type_name VARCHAR(20);

    SELECT type_name INTO v_type_name
    FROM transaction_types
    WHERE type_id = p_type_id;

    IF v_type_name IN ('TRANSFER', 'CASH_OUT') THEN
        SET v_score = v_score + 30;
    END IF;

    IF p_newbalance_orig = 0 AND p_oldbalance_org > 0 AND p_amount > 10000 THEN
        SET v_score = v_score + 40;
    END IF;

    IF p_amount > 200000 THEN
        SET v_score = v_score + 15;
    END IF;

    IF (p_oldbalance_org - p_amount) <> p_newbalance_orig THEN
        SET v_score = v_score + 10;
    END IF;

    IF v_type_name = 'TRANSFER' AND (p_oldbalance_dest + p_amount) <> p_newbalance_dest THEN
        SET v_score = v_score + 25;
    END IF;

    RETURN v_score;
END;