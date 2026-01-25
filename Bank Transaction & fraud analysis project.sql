-- =========================================
-- Bank Transaction & Fraud Analytics (MySQL)
-- =========================================

-- ======================
-- STEP 0: Create Tables
-- ======================

CREATE DATABASE bank_analytics;
USE bank_analytics;


CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(30),
    risk_score INT
);

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(20),
    balance DECIMAL(12,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE transactions (
    txn_id INT PRIMARY KEY,
    account_id INT,
    txn_date DATETIME,
    amount DECIMAL(10,2),
    txn_type VARCHAR(10), -- credit/debit
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);


-- ======================
-- STEP 1: Insert Data
-- ======================

INSERT INTO customers VALUES
(1,'Shreyash','Delhi',20),
(2,'Shreya','Noida',80),
(3,'Aradhya','Gurgaon',60),
(4,'Amit','Delhi',30),
(5,'Neha','Mumbai',75),
(6,'Rohit','Pune',40),
(7,'Karan','Bangalore',90),
(8,'Priya','Hyderabad',55);

INSERT INTO accounts VALUES
(101,1,'Savings',500000),
(102,2,'Savings',120000),
(103,3,'Current',300000),
(104,4,'Savings',250000),
(105,5,'Current',180000),
(106,6,'Savings',90000),
(107,7,'Savings',400000),
(108,8,'Current',220000);

SELECT * from accounts;

INSERT INTO transactions VALUES
(1,101,'2024-01-01 10:00',5000,'debit'),
(2,101,'2024-01-01 10:05',45000,'debit'),
(3,101,'2024-01-02 11:00',60000,'credit'),
(4,102,'2024-01-05 09:00',90000,'debit'),
(5,102,'2024-01-05 09:03',85000,'debit'),
(6,103,'2024-01-10 14:00',150000,'debit'),
(7,104,'2024-01-12 10:00',70000,'debit'),
(8,104,'2024-01-12 10:04',65000,'debit'),
(9,105,'2024-01-15 11:30',120000,'debit'),
(10,105,'2024-01-16 12:00',50000,'credit'),
(11,107,'2024-01-18 09:00',200000,'debit'),
(12,107,'2024-01-18 09:05',180000,'debit');



-- ======================
-- Q1: Running Balance per Account
-- ======================

SELECT account_id, txn_date, txn_type, amount,
SUM(
  CASE 
    When txn_type='credit' THEN +amount 
    ELSE -amount 
  End) OVER (PARTITION BY account_id ORDER BY txn_date) AS running_balance
FROM transactions;

-- ======================
-- Q2: High Value Debit Transactions
-- ======================


SELECT * from transactions
where amount > 50000 AND txn_type='debit';


-- ======================
-- Q3: Multiple Transactions in Short Time Window
-- ======================

SELECT t1.account_id, t1.txn_id, t1.txn_date
FROM transactions t1
JOIN transactions t2
ON t1.account_id = t2.account_id
AND t1.txn_id <> t2.txn_id #(Not equal to)
AND ABS(TIMESTAMPDIFF(MINUTE, t1.txn_date, t2.txn_date)) <= 10;


-- ======================
-- Q4: High Risk Customers with Large Transactions
-- ======================

SELECT c.customer_name, c.risk_score, t.amount
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
WHERE c.risk_score > 70 AND t.amount > 50000;



-- ======================
-- Q5: Inactive Accounts That Suddenly Became Active (Fraud Detector).
-- ======================

SELECT 
  account_id,
  MAX(txn_date) AS last_transaction_date
FROM transactions
GROUP BY account_id
HAVING MAX(txn_date) < DATE_SUB(CURDATE(), INTERVAL 30 DAY);


-- ======================
-- Q6: Accounts with Only Debit Transactions
-- ======================

SELECT account_id
FROM transactions
GROUP BY account_id
HAVING SUM(
  CASE 
    WHEN txn_type = 'credit' THEN 1
    ELSE 0
  END ) = 0;
  
  
-- ======================
-- Q7: Daily Transaction Count
-- ======================
  
SELECT account_id, 
DATE(txn_date) AS txn_day,
COUNT(*) AS total_transactions
FROM transactions
GROUP BY account_id, DATE(txn_date)
ORDER BY account_id, txn_day;



-- ======================
-- Q8: Rank Accounts by Total Transaction Amount
-- ======================

-- (STEP 1: Calculate total amount per account)

SUM(
  CASE 
    WHEN txn_type = 'credit' THEN amount
    ELSE amount
  END
);

-- [STEP 2: Final Query and Apply RANK()]

SELECT 
  account_id,
  SUM(amount) AS total_transaction_amount,
  RANK() OVER (ORDER BY SUM(amount) DESC) AS account_rank
FROM transactions
GROUP BY account_id;



-- ======================
-- Q9: Top 10% High Value Transactions
-- ======================

SELECT *
FROM (
SELECT 
txn_id, account_id, txn_date, amount,
NTILE(10) OVER (ORDER BY amount DESC) AS bucket
FROM transactions
) t
WHERE bucket = 1;



-- ======================
-- Q10: Fraud Risk Score per Account
-- ======================

-- (STEP 1: High-Value Debit Transactions)

SELECT 
account_id,
COUNT(*) * 2 AS high_value_score
FROM transactions
WHERE txn_type = 'debit'
  AND amount > 50000
GROUP BY account_id;

--  (STEP 2: Only Debit Accounts)

SELECT 
account_id, 1 AS only_debit_score
FROM transactions
GROUP BY account_id
HAVING SUM(CASE WHEN txn_type='credit' THEN 1 ELSE 0 END) = 0;

-- STEP 3: (Inactive Accounts)

SELECT 
account_id, 1 AS inactive_score
FROM transactions
GROUP BY account_id
HAVING MAX(txn_date) < DATE_SUB(CURDATE(), INTERVAL 30 DAY);


-- STEP 4: Combine Everything (FINAL QUERY)

SELECT 
  a.account_id,
  COALESCE(h.high_value_score, 0)
+ COALESCE(o.only_debit_score, 0)
+ COALESCE(i.inactive_score, 0) AS fraud_risk_score
FROM accounts a
LEFT JOIN (
  SELECT account_id, COUNT(*) * 2 AS high_value_score
  FROM transactions
  WHERE txn_type='debit' AND amount > 50000
  GROUP BY account_id
) h ON a.account_id = h.account_id
LEFT JOIN (
  SELECT account_id, 1 AS only_debit_score
  FROM transactions
  GROUP BY account_id
  HAVING SUM(CASE WHEN txn_type='credit' THEN 1 ELSE 0 END) = 0
) o ON a.account_id = o.account_id
LEFT JOIN (
  SELECT account_id, 1 AS inactive_score
  FROM transactions
  GROUP BY account_id
  HAVING MAX(txn_date) < DATE_SUB(CURDATE(), INTERVAL 30 DAY)
) i ON a.account_id = i.account_id;


-- What is COALESCE()?

-- If value is NULL, treat it as 0.
