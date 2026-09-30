create view fraud_detection_comparison as
select
    is_fraud,
    is_flagged_fraud,
    case when calculated_risk_score(type_id, amount, oldbalance_org, newbalance_orig) >= 70
         then 1 else 0 end as my_flag,
    case
        when is_fraud = 0 and is_flagged_fraud = 0 and calculated_risk_score(type_id, amount, oldbalance_org, newbalance_orig) < 70
            then 'correctly ignored by both'
        when is_fraud = 0 and is_flagged_fraud = 0 and calculated_risk_score(type_id, amount, oldbalance_org, newbalance_orig) >= 70
            then 'false positive (my system only)'
        when is_fraud = 0 and is_flagged_fraud = 1
            then 'false positive (old system)'
        when is_fraud = 1 and is_flagged_fraud = 0 and calculated_risk_score(type_id, amount, oldbalance_org, newbalance_orig) >= 70
            then 'fraud caught only by my system'
        when is_fraud = 1 and is_flagged_fraud = 1 and calculated_risk_score(type_id, amount, oldbalance_org, newbalance_orig) >= 70
            then 'fraud caught by both systems'
        when is_fraud = 1 and is_flagged_fraud = 1 and calculated_risk_score(type_id, amount, oldbalance_org, newbalance_orig) < 70
            then 'fraud caught only by old system'
        else 'fraud missed by both systems'
    end as result_label,
    count(*) as count
from transaction
group by is_fraud, is_flagged_fraud, my_flag, result_label;

create view high_risk_transactions as
select
    transaction_id, step, amount, orig_account_id, dest_account_id,
    is_fraud, is_flagged_fraud,
    calculated_risk_score(type_id, amount, oldbalance_org, newbalance_orig) as risk_score
from transaction
where calculated_risk_score(type_id, amount, oldbalance_org, newbalance_orig) >= 70;