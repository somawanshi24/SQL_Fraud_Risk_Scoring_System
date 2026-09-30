

create function calculated_risk_score(
    p_type_id int,
    p_amount decimal(18,2),
    p_oldbalance_org decimal(18,2),
    p_newbalance_orig decimal(18,2)
)
returns int
deterministic
begin
    declare v_score int default 0;
    declare v_type_name varchar(20);

    select type_name into v_type_name
    from transaction_types
    where type_id = p_type_id;

    if v_type_name in ('transfer', 'cash_out') then
        set v_score = v_score + 30;
    end if;

    if p_newbalance_orig = 0 and p_oldbalance_org > 0 and p_amount > 10000 then
        set v_score = v_score + 40;
    end if;

    if p_amount > 200000 then
        set v_score = v_score + 15;
    end if;

    if (p_oldbalance_org - p_amount) <> p_newbalance_orig then
        set v_score = v_score + 10;
    end if;

    return v_score;
end;