
CREATE VIEW fraud_detection_comparison AS
SELECT
    is_fraud,
    is_flagged_fraud,
    CASE
        WHEN calculated_risk_score(type_id, amount, oldbalance_org, newbalance_orig, oldbalance_dest, newbalance_dest) >= 95 THEN 'Critical'
        WHEN calculated_risk_score(type_id, amount, oldbalance_org, newbalance_orig, oldbalance_dest, newbalance_dest) >= 70 THEN 'High'
        ELSE 'Not flagged'
    END AS my_tier,
    COUNT(*) AS count
FROM transaction
GROUP BY is_fraud, is_flagged_fraud, my_tier;

CREATE VIEW high_risk_transactions AS
SELECT
    transaction_id, step, amount, orig_account_id, dest_account_id,
    is_fraud, is_flagged_fraud,
    calculated_risk_score(type_id, amount, oldbalance_org, newbalance_orig, oldbalance_dest, newbalance_dest) AS risk_score,
    CASE
        WHEN calculated_risk_score(type_id, amount, oldbalance_org, newbalance_orig, oldbalance_dest, newbalance_dest) >= 95 THEN 'Critical'
        ELSE 'High'
    END AS risk_tier
FROM transaction
WHERE calculated_risk_score(type_id, amount, oldbalance_org, newbalance_orig, oldbalance_dest, newbalance_dest) >= 70;