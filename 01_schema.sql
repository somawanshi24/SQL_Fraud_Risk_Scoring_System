create table staging_transactions (
    step int,
    type varchar(20),
    amount double,
    nameorig varchar(20),
    oldbalanceorg double,
    newbalanceorig double,
    namedest varchar(20),
    oldbalancedest double,
    newbalancedest double,
    isfraud int,
    isflaggedfraud int
);

create table transaction_types (
    type_id int primary key auto_increment,
    type_name varchar(20) unique not null
);

create table accounts (
    account_id varchar(20) primary key,
    account_type char(1)
);

create table transaction (
    transaction_id int primary key auto_increment,
    step int not null,
    type_id int not null,
    amount decimal(18,2) not null,
    orig_account_id varchar(20) not null,
    oldbalance_org decimal(18,2),
    newbalance_orig decimal(18,2),
    dest_account_id varchar(20) not null,
    oldbalance_dest decimal(18,2),
    newbalance_dest decimal(18,2),
    is_fraud tinyint not null default 0,
    is_flagged_fraud tinyint not null default 0,
    foreign key (type_id) references transaction_types(type_id),
    foreign key (orig_account_id) references accounts(account_id),
    foreign key (dest_account_id) references accounts(account_id)
);

create table failed_transactions (
    failed_id int primary key auto_increment,
    orig_account_id varchar(20),
    dest_account_id varchar(20),
    amount decimal(18,2),
    attempted_at int,
    failure_reason varchar(255)
);