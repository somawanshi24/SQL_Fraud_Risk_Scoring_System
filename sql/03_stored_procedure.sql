create procedure process_transaction(
    p_orig_account varchar(20),
    p_dest_account varchar(20),
    p_amount decimal(18,2),
    p_type_id int,
    p_step int
)
begin
    declare v_old_balance decimal(18,2);
    declare v_new_balance decimal(18,2);

    declare exit handler for sqlexception
    begin
        rollback;
        insert into failed_transactions (orig_account_id, dest_account_id, amount, attempted_at, failure_reason)
        values (p_orig_account, p_dest_account, p_amount, p_step, 'insufficient balance');
    end;

    start transaction;

    select newbalance_orig into v_old_balance
    from transaction
    where orig_account_id = p_orig_account
    order by transaction_id desc
    limit 1;

    if v_old_balance < p_amount then
        signal sqlstate '45000'
        set message_text = 'balance is insufficient';
    end if;

    set v_new_balance = v_old_balance - p_amount;

    insert into transaction (step, type_id, amount, orig_account_id, oldbalance_org, newbalance_orig, dest_account_id)
    values (p_step, p_type_id, p_amount, p_orig_account, v_old_balance, v_new_balance, p_dest_account);

    commit;
end;

-- call process_transaction('c1231006815', 'm1979787155', 500.00, 2, 745);
-- call process_transaction('c1231006815', 'm1979787155', 99999999.00, 2, 746);