load data infile 'ps_20174392719_1491204439457_log.csv'
into table staging_transactions
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

insert into transaction_types (type_name)
select distinct type from staging_transactions;

insert into accounts (account_id, account_type)
select distinct nameorig, left(nameorig, 1)
from staging_transactions;

insert ignore into accounts (account_id, account_type)
select distinct namedest, left(namedest, 1)
from staging_transactions;

set foreign_key_checks = 0;

insert into transaction (
    step, type_id, amount, orig_account_id, oldbalance_org, newbalance_orig,
    dest_account_id, oldbalance_dest, newbalance_dest, is_fraud, is_flagged_fraud
)
select s.step, t.type_id, s.amount, s.nameorig, s.oldbalanceorg, s.newbalanceorig,
       s.namedest, s.oldbalancedest, s.newbalancedest, s.isfraud, s.isflaggedfraud
from staging_transactions s
join transaction_types t on s.type = t.type_name;

set foreign_key_checks = 1;