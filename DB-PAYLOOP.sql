-- ============================================================
-- STEP 1: CREATE THE DATABASE
-- GO after CREATE DATABASE is mandatory — SQL Server cannot
-- switch context (USE) in the same batch it creates the database.
-- ============================================================

IF DB_ID('PayLoopDBCourse') IS NULL
    CREATE DATABASE PayLoopDBCourse;
GO

USE PayLoopDBCourse;
GO


-- ============================================================
-- STEP 2: DROP EXISTING TABLES (safe re-run)
-- Must follow reverse FK dependency order so constraints are
-- satisfied before parent tables are removed.
-- ============================================================

IF OBJECT_ID('Payments',           'U') IS NOT NULL DROP TABLE Payments;
IF OBJECT_ID('Transactions',       'U') IS NOT NULL DROP TABLE Transactions;
IF OBJECT_ID('Wallets',            'U') IS NOT NULL DROP TABLE Wallets;
IF OBJECT_ID('Users',              'U') IS NOT NULL DROP TABLE Users;
IF OBJECT_ID('Merchants',          'U') IS NOT NULL DROP TABLE Merchants;
IF OBJECT_ID('AuditLog',           'U') IS NOT NULL DROP TABLE AuditLog;
IF OBJECT_ID('CityTransactions',   'U') IS NOT NULL DROP TABLE CityTransactions;
IF OBJECT_ID('MerchantSalesData',  'U') IS NOT NULL DROP TABLE MerchantSalesData;


-- ============================================================
-- STEP 3: CREATE CORE TABLES
-- ============================================================

-- Users: stores all registered wallet account holders
CREATE TABLE Users (
    user_id   INT           PRIMARY KEY IDENTITY(1,1),
    full_name VARCHAR(100)  NOT NULL,
    email     VARCHAR(150)  NOT NULL UNIQUE,
    phone     VARCHAR(20)   NOT NULL UNIQUE,
    password  VARCHAR(255)  NOT NULL,
    status    VARCHAR(20)   DEFAULT 'active'
);

-- Wallets: one wallet per user, tracks running balance
CREATE TABLE Wallets (
    wallet_id INT            PRIMARY KEY IDENTITY(1,1),
    user_id   INT            NOT NULL UNIQUE,
    balance   DECIMAL(10,2)  DEFAULT 0.00,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Transactions: every money movement (credit / debit / transfer)
CREATE TABLE Transactions (
    txn_id    INT            PRIMARY KEY IDENTITY(1,1),
    wallet_id INT            NOT NULL,
    txn_type  VARCHAR(20)    NOT NULL,
    amount    DECIMAL(10,2)  NOT NULL,
    note      VARCHAR(255),
    txn_date  DATETIME       DEFAULT GETDATE(),
    FOREIGN KEY (wallet_id) REFERENCES Wallets(wallet_id)
);

-- Merchants: businesses that accept PayLoop payments
CREATE TABLE Merchants (
    merchant_id   INT           PRIMARY KEY IDENTITY(1,1),
    merchant_name VARCHAR(150)  NOT NULL,
    category      VARCHAR(100),
    email         VARCHAR(150)  NOT NULL UNIQUE
);

-- Payments: records each merchant payment
CREATE TABLE Payments (
    payment_id  INT            PRIMARY KEY IDENTITY(1,1),
    wallet_id   INT            NOT NULL,
    merchant_id INT            NOT NULL,
    amount      DECIMAL(10,2)  NOT NULL,
    pay_date    DATETIME       DEFAULT GETDATE(),
    FOREIGN KEY (wallet_id)   REFERENCES Wallets(wallet_id),
    FOREIGN KEY (merchant_id) REFERENCES Merchants(merchant_id)
);

-- AuditLog: system-level event trail for security and compliance
CREATE TABLE AuditLog (
    log_id   INT           PRIMARY KEY IDENTITY(1,1),
    event    VARCHAR(100),
    details  VARCHAR(255),
    log_date DATETIME      DEFAULT GETDATE()
);


-- ============================================================
-- STEP 4: CREATE SECONDARY / BUSINESS INTELLIGENCE TABLES
-- ============================================================

-- CityTransactions: monthly aggregated transaction data by city
CREATE TABLE CityTransactions (
    city_txn_id        INT            PRIMARY KEY IDENTITY(1,1),
    city_name          VARCHAR(100)   NOT NULL,
    transaction_month  VARCHAR(20)    NOT NULL,
    transaction_volume DECIMAL(14,2)  DEFAULT 0,
    transaction_count  INT            DEFAULT 0,
    active_users       INT            DEFAULT 0
);

-- MerchantSalesData: monthly revenue snapshot per merchant
CREATE TABLE MerchantSalesData (
    sales_id          INT            PRIMARY KEY IDENTITY(1,1),
    merchant_name     VARCHAR(150)   NOT NULL,
    category          VARCHAR(100),
    sales_month       VARCHAR(20)    NOT NULL,
    revenue_generated DECIMAL(14,2)  DEFAULT 0,
    payment_count     INT            DEFAULT 0
);


-- ============================================================
-- STEP 5: INSERT CORE SAMPLE DATA
-- ============================================================

-- ----- Users -----
INSERT INTO Users (full_name, email, phone, password) VALUES
('Muhammad Musa',    'musa@payloop.pk',     '03001234501', 'password1'),
('Muhammad Ahmed',   'ahmed@payloop.pk',    '03001234502', 'password2'),
('Ibrahim Haider',   'ibrahim@payloop.pk',  '03001234503', 'password3'),
('Zakaullah Khan',   'zaka@payloop.pk',     '03001234504', 'password4'),
('Muhammad Ismaeel', 'ismaeel@payloop.pk',  '03001234505', 'password5'),
('Fatima Khuram',    'fatima@payloop.pk',   '03001234506', 'password6'),
('Salman Kashif',    'salman@payloop.pk',   '03001234507', 'password7'),
('Harris Amir',      'haris@payloop.pk',    '03001234508', 'password8'),
('Ezaan Ali',        'ezaan@payloop.pk',    '03001234509', 'password9'),
('Shameer Awan',     'shahmeer@payloop.pk', '03001234510', 'password10');

-- ----- Wallets -----
INSERT INTO Wallets (user_id, balance) VALUES
(1,  85000.00),
(2,  42500.00),
(3,  120000.00),
(4,  15000.00),
(5,  67000.00),
(6,  33500.00),
(7,  9800.00),
(8,  250000.00),
(9,  500.00),
(10, 18000.00);

-- ----- Merchants -----
INSERT INTO Merchants (merchant_name, category, email) VALUES
('Daily Deli',       'Food & Dining', 'dailydeli@biz.pk'),
('Daraz Online',     'E-Commerce',    'daraz@biz.pk'),
('Lesco',            'Utilities',     'lesco@biz.pk'),
('Netflix Pakistan', 'Entertainment', 'netflix@biz.pk'),
('Careem Rides',     'Transport',     'careem@biz.pk'),
('Gourmet Foods',    'Food & Dining', 'gourmet@biz.pk'),
('Telenor',          'Utilities',     'telenor@biz.pk'),
('Foodpanda',        'Food & Dining', 'foodpanda@biz.pk'),
('Amazon.pk',        'E-Commerce',    'amazon@biz.pk'),
('Uber Pakistan',    'Transport',     'uber@biz.pk');

-- ----- Transactions -----
INSERT INTO Transactions (wallet_id, txn_type, amount, note, txn_date) VALUES
(1,  'credit',       50000.00, 'Bank deposit',             '2025-01-05'),
(2,  'credit',       20000.00, 'Salary received',          '2025-01-10'),
(3,  'credit',       80000.00, 'Bank transfer',            '2025-01-12'),
(4,  'credit',       15000.00, 'Freelance payment',        '2025-01-15'),
(5,  'credit',       30000.00, 'Family sent money',        '2025-01-20'),
(6,  'credit',       25000.00, 'Online transfer received', '2025-02-01'),
(7,  'credit',       10000.00, 'Cash deposit',             '2025-02-05'),
(8,  'credit',      200000.00, 'Business income',          '2025-02-10'),
(9,  'credit',        1000.00, 'Gift money',               '2025-02-15'),
(10, 'credit',       18000.00, 'Freelance earning',        '2025-02-20'),
(1,  'debit',         1200.00, 'Paid Daily Deli',          '2025-01-06'),
(2,  'debit',          500.00, 'Careem ride',              '2025-01-11'),
(3,  'debit',         8000.00, 'Electricity bill',         '2025-01-13'),
(5,  'debit',          999.00, 'Netflix monthly',          '2025-01-21'),
(8,  'debit',         2500.00, 'Online shopping',          '2025-02-11'),
(1,  'debit',         3000.00, 'Lunch with team',          '2025-02-08'),
(3,  'debit',        15000.00, 'Paid phone bill',          '2025-02-12'),
(6,  'debit',         1800.00, 'Foodpanda order',          '2025-03-01'),
(7,  'debit',          700.00, 'Careem ride',              '2025-03-05'),
(4,  'debit',         2000.00, 'Grocery shopping',         '2025-03-08'),
(1,  'transfer_out',  5000.00, 'Sent to Ahmed',            '2025-01-25'),
(2,  'transfer_in',   5000.00, 'Received from Musa',       '2025-01-25'),
(3,  'transfer_out', 10000.00, 'Sent to Fatima',           '2025-02-18'),
(6,  'transfer_in',  10000.00, 'Received from Ibrahim',    '2025-02-18'),
(8,  'transfer_out', 60000.00, 'Business payment',         '2025-03-10'),
(5,  'transfer_in',  60000.00, 'Received business funds',  '2025-03-10');

-- ----- Payments -----
INSERT INTO Payments (wallet_id, merchant_id, amount, pay_date) VALUES
(1,  1,  1200.00, '2025-01-06'),
(2,  5,   500.00, '2025-01-11'),
(3,  3,  8000.00, '2025-01-13'),
(5,  4,   999.00, '2025-01-21'),
(8,  2,  2500.00, '2025-02-11'),
(1,  1,  3000.00, '2025-02-08'),
(3,  7, 15000.00, '2025-02-12'),
(6,  8,  1800.00, '2025-03-01'),
(7,  5,   700.00, '2025-03-05'),
(4,  1,  2000.00, '2025-03-08'),
(5,  4,   999.00, '2025-03-15'),
(8,  9,  5500.00, '2025-03-18'),
(2,  10,  800.00, '2025-03-20'),
(1,  6,  2200.00, '2025-03-22'),
(3,  8,  1500.00, '2025-03-25');


-- ============================================================
-- STEP 6: INSERT SECONDARY / BI SAMPLE DATA
-- ============================================================

-- ----- CityTransactions -----
INSERT INTO CityTransactions (city_name, transaction_month, transaction_volume, transaction_count, active_users) VALUES
('Lahore',     '2025-01', 520000.00,  85, 320),
('Karachi',    '2025-01', 740000.00, 120, 450),
('Islamabad',  '2025-01', 310000.00,  54, 180),
('Rawalpindi', '2025-01', 195000.00,  40, 130),
('Faisalabad', '2025-01', 145000.00,  30,  95),
('Lahore',     '2025-02', 610000.00,  98, 375),
('Karachi',    '2025-02', 890000.00, 145, 510),
('Islamabad',  '2025-02', 370000.00,  65, 210),
('Rawalpindi', '2025-02', 220000.00,  47, 150),
('Faisalabad', '2025-02', 175000.00,  38, 110),
('Lahore',     '2025-03', 695000.00, 112, 420),
('Karachi',    '2025-03', 980000.00, 162, 570),
('Islamabad',  '2025-03', 430000.00,  78, 245),
('Rawalpindi', '2025-03', 255000.00,  55, 168),
('Faisalabad', '2025-03', 210000.00,  45, 128);

-- ----- MerchantSalesData -----
INSERT INTO MerchantSalesData (merchant_name, category, sales_month, revenue_generated, payment_count) VALUES
('Daily Deli',       'Food & Dining', '2025-01',  45000.00, 38),
('Daraz Online',     'E-Commerce',    '2025-01',  85000.00, 62),
('Lesco',            'Utilities',     '2025-01', 120000.00, 95),
('Netflix Pakistan', 'Entertainment', '2025-01',  28000.00, 28),
('Careem Rides',     'Transport',     '2025-01',  35000.00, 70),
('Daily Deli',       'Food & Dining', '2025-02',  52000.00, 44),
('Daraz Online',     'E-Commerce',    '2025-02',  98000.00, 71),
('Lesco',            'Utilities',     '2025-02', 135000.00, 102),
('Netflix Pakistan', 'Entertainment', '2025-02',  30000.00, 30),
('Careem Rides',     'Transport',     '2025-02',  42000.00, 82),
('Daily Deli',       'Food & Dining', '2025-03',  60000.00, 51),
('Daraz Online',     'E-Commerce',    '2025-03', 115000.00, 83),
('Lesco',            'Utilities',     '2025-03', 148000.00, 114),
('Netflix Pakistan', 'Entertainment', '2025-03',  33000.00, 33),
('Careem Rides',     'Transport',     '2025-03',  50000.00, 95);


-- ============================================================
-- STEP 7: DML  (INSERT / UPDATE / DELETE)
-- ============================================================

-- Add a temporary user for testing (procedures not yet defined at this point)
INSERT INTO Users (full_name, email, phone, password)
VALUES ('Hamza Tariq', 'hamza@payloop.pk', '03009999001', 'password11');

INSERT INTO Wallets (user_id, balance)
VALUES (11, 0.00);

-- Top up Ezaan's low balance
UPDATE Wallets
SET    balance = balance + 5000.00
WHERE  wallet_id = 9;

-- Suspend the temporary user then clean up
UPDATE Users
SET    status = 'suspended'
WHERE  user_id = 11;

DELETE FROM Wallets WHERE user_id = 11;
DELETE FROM Users   WHERE user_id = 11;


-- ============================================================
-- STEP 8: JOINs
-- ============================================================

-- INNER JOIN: all users who have a wallet, sorted by balance
SELECT u.full_name, u.email, w.balance
FROM Users u
INNER JOIN Wallets w ON u.user_id = w.user_id
ORDER BY w.balance DESC;

-- 3-TABLE JOIN: transactions shown with the user's name
SELECT u.full_name, t.txn_type, t.amount, t.note, t.txn_date
FROM Transactions t
INNER JOIN Wallets w ON t.wallet_id = w.wallet_id
INNER JOIN Users   u ON w.user_id   = u.user_id
ORDER BY t.amount DESC;

-- LEFT JOIN: every user with their transaction count (zero counts included)
SELECT u.full_name, COUNT(t.txn_id) AS number_of_transactions
FROM Users u
LEFT JOIN Wallets      w ON u.user_id   = w.user_id
LEFT JOIN Transactions t ON w.wallet_id = t.wallet_id
GROUP BY u.user_id, u.full_name
ORDER BY number_of_transactions DESC;

-- RIGHT JOIN: every merchant shown even if they received no payments
SELECT m.merchant_name, m.category, p.amount
FROM Payments p
RIGHT JOIN Merchants m ON p.merchant_id = m.merchant_id;

-- FULL OUTER JOIN: all users and all wallets, NULLs where no match
SELECT u.full_name, w.wallet_id, w.balance
FROM Users u
FULL OUTER JOIN Wallets w ON u.user_id = w.user_id;

-- 4-TABLE JOIN: who paid which merchant, with full details
SELECT u.full_name, m.merchant_name, m.category, p.amount, p.pay_date
FROM Payments p
INNER JOIN Wallets   w ON p.wallet_id   = w.wallet_id
INNER JOIN Users     u ON w.user_id     = u.user_id
INNER JOIN Merchants m ON p.merchant_id = m.merchant_id
ORDER BY p.amount DESC;


-- ============================================================
-- STEP 9: SUBQUERIES
-- ============================================================

-- Users with an above-average wallet balance
SELECT u.full_name, w.balance
FROM Users u
INNER JOIN Wallets w ON u.user_id = w.user_id
WHERE w.balance > (SELECT AVG(balance) FROM Wallets)
ORDER BY w.balance DESC;

-- Users who made at least one transaction (using IN)
SELECT full_name, email
FROM Users
WHERE user_id IN (
    SELECT u.user_id
    FROM   Users u
    INNER JOIN Wallets      w ON u.user_id   = w.user_id
    INNER JOIN Transactions t ON w.wallet_id = t.wallet_id
);

-- Merchants who received more than PKR 5,000 in total payments
SELECT merchant_name, category
FROM Merchants
WHERE merchant_id IN (
    SELECT merchant_id
    FROM   Payments
    GROUP  BY merchant_id
    HAVING SUM(amount) > 5000
);


-- ============================================================
-- STEP 10: ADVANCED SELECT FEATURES
-- ============================================================

-- Users who spent over PKR 5,000 in total (GROUP BY + HAVING)
SELECT
    u.full_name,
    COUNT(t.txn_id) AS total_transactions,
    SUM(t.amount)   AS total_amount,
    AVG(t.amount)   AS average_amount
FROM Users u
INNER JOIN Wallets      w ON u.user_id   = w.user_id
INNER JOIN Transactions t ON w.wallet_id = t.wallet_id
GROUP BY u.user_id, u.full_name
HAVING SUM(t.amount) > 5000
ORDER BY total_amount DESC;

-- Transactions within a specific date range (BETWEEN)
SELECT txn_type, amount, note, txn_date
FROM Transactions
WHERE txn_date BETWEEN '2025-01-01' AND '2025-12-31';

-- Only credit and incoming transfers (IN)
SELECT txn_type, amount, note
FROM Transactions
WHERE txn_type IN ('credit', 'transfer_in')
ORDER BY amount DESC;

-- Each distinct transaction type that exists (DISTINCT)
SELECT DISTINCT txn_type
FROM Transactions;

-- Top 3 wealthiest wallet holders (TOP)
SELECT TOP 3 u.full_name, w.balance
FROM Users u
INNER JOIN Wallets w ON u.user_id = w.user_id
ORDER BY w.balance DESC;

-- Transaction volume summary grouped by type (GROUP BY)
SELECT
    txn_type,
    COUNT(txn_id) AS txn_count,
    SUM(amount)   AS total_amount,
    AVG(amount)   AS avg_amount
FROM Transactions
GROUP BY txn_type
ORDER BY total_amount DESC;


-- ============================================================
-- STEP 11: CORE VIEWS
-- ============================================================

IF OBJECT_ID('ShowBalances', 'V') IS NOT NULL DROP VIEW ShowBalances;
GO
CREATE VIEW ShowBalances AS
SELECT
    u.user_id, u.full_name, u.email, u.phone, u.status,
    w.wallet_id, w.balance
FROM Users u
INNER JOIN Wallets w ON u.user_id = w.user_id;
GO

IF OBJECT_ID('ShowTransactions', 'V') IS NOT NULL DROP VIEW ShowTransactions;
GO
CREATE VIEW ShowTransactions AS
SELECT
    t.txn_id, u.full_name, t.txn_type, t.amount, t.note, t.txn_date
FROM Transactions t
INNER JOIN Wallets w ON t.wallet_id = w.wallet_id
INNER JOIN Users   u ON w.user_id   = u.user_id;
GO

IF OBJECT_ID('MerchantTotals', 'V') IS NOT NULL DROP VIEW MerchantTotals;
GO
CREATE VIEW MerchantTotals AS
SELECT
    m.merchant_name,
    m.category,
    COUNT(p.payment_id)           AS number_of_payments,
    COALESCE(SUM(p.amount), 0.00) AS total_received
FROM Merchants m
LEFT JOIN Payments p ON m.merchant_id = p.merchant_id
GROUP BY m.merchant_id, m.merchant_name, m.category;
GO


-- ============================================================
-- STEP 12: BUSINESS INTELLIGENCE VIEWS
-- ============================================================

IF OBJECT_ID('MerchantPerformance', 'V') IS NOT NULL DROP VIEW MerchantPerformance;
GO
CREATE VIEW MerchantPerformance AS
SELECT
    m.merchant_id,
    m.merchant_name,
    m.category,
    COUNT(p.payment_id)        AS total_payments,
    COALESCE(SUM(p.amount), 0) AS total_revenue,
    COALESCE(AVG(p.amount), 0) AS avg_payment_amount
FROM Merchants m
LEFT JOIN Payments p ON m.merchant_id = p.merchant_id
GROUP BY m.merchant_id, m.merchant_name, m.category;
GO

IF OBJECT_ID('FraudMonitoring', 'V') IS NOT NULL DROP VIEW FraudMonitoring;
GO
CREATE VIEW FraudMonitoring AS
SELECT
    t.txn_id,
    u.full_name,
    u.email,
    t.txn_type,
    t.amount,
    t.note,
    t.txn_date,
    'Flagged - Exceeds PKR 50,000' AS alert_reason
FROM Transactions t
INNER JOIN Wallets w ON t.wallet_id = w.wallet_id
INNER JOIN Users   u ON w.user_id   = u.user_id
WHERE t.amount > 50000;
GO

IF OBJECT_ID('WalletDistribution', 'V') IS NOT NULL DROP VIEW WalletDistribution;
GO
CREATE VIEW WalletDistribution AS
SELECT
    u.full_name,
    w.balance,
    CASE
        WHEN w.balance >= 100000 THEN 'HIGH'
        WHEN w.balance >= 20000  THEN 'MEDIUM'
        ELSE                          'LOW'
    END AS balance_tier
FROM Users u
INNER JOIN Wallets w ON u.user_id = w.user_id;
GO


-- ============================================================
-- STEP 13: STORED PROCEDURES
-- ============================================================

IF OBJECT_ID('AddMoney', 'P') IS NOT NULL DROP PROCEDURE AddMoney;
GO
CREATE PROCEDURE AddMoney
    @wallet_num INT,
    @how_much   DECIMAL(10,2)
AS
BEGIN
    UPDATE Wallets
    SET    balance = balance + @how_much
    WHERE  wallet_id = @wallet_num;

    INSERT INTO Transactions (wallet_id, txn_type, amount, note)
    VALUES (@wallet_num, 'credit', @how_much, 'Money added');
END;
GO

IF OBJECT_ID('TakeMoney', 'P') IS NOT NULL DROP PROCEDURE TakeMoney;
GO
CREATE PROCEDURE TakeMoney
    @wallet_num INT,
    @how_much   DECIMAL(10,2)
AS
BEGIN
    UPDATE Wallets
    SET    balance = balance - @how_much
    WHERE  wallet_id = @wallet_num
    AND    balance   >= @how_much;

    IF @@ROWCOUNT > 0
        INSERT INTO Transactions (wallet_id, txn_type, amount, note)
        VALUES (@wallet_num, 'debit', @how_much, 'Money withdrawn');
END;
GO

IF OBJECT_ID('SendMoney', 'P') IS NOT NULL DROP PROCEDURE SendMoney;
GO
CREATE PROCEDURE SendMoney
    @from_wallet INT,
    @to_wallet   INT,
    @how_much    DECIMAL(10,2)
AS
BEGIN
    UPDATE Wallets
    SET    balance = balance - @how_much
    WHERE  wallet_id = @from_wallet
    AND    balance   >= @how_much
    AND    @from_wallet <> @to_wallet;

    IF @@ROWCOUNT > 0
    BEGIN
        UPDATE Wallets
        SET    balance = balance + @how_much
        WHERE  wallet_id = @to_wallet;

        INSERT INTO Transactions (wallet_id, txn_type, amount, note)
        VALUES (@from_wallet, 'transfer_out', @how_much,
                CONCAT('Sent to wallet ', @to_wallet));

        INSERT INTO Transactions (wallet_id, txn_type, amount, note)
        VALUES (@to_wallet, 'transfer_in', @how_much,
                CONCAT('Received from wallet ', @from_wallet));
    END
END;
GO

IF OBJECT_ID('PayShop', 'P') IS NOT NULL DROP PROCEDURE PayShop;
GO
CREATE PROCEDURE PayShop
    @wallet_num   INT,
    @merchant_num INT,
    @how_much     DECIMAL(10,2),
    @payment_note VARCHAR(255)
AS
BEGIN
    UPDATE Wallets
    SET    balance = balance - @how_much
    WHERE  wallet_id = @wallet_num
    AND    balance   >= @how_much;

    IF @@ROWCOUNT > 0
    BEGIN
        INSERT INTO Payments (wallet_id, merchant_id, amount)
        VALUES (@wallet_num, @merchant_num, @how_much);

        INSERT INTO Transactions (wallet_id, txn_type, amount, note)
        VALUES (@wallet_num, 'debit', @how_much, @payment_note);
    END
END;
GO

IF OBJECT_ID('NewUser', 'P') IS NOT NULL DROP PROCEDURE NewUser;
GO
CREATE PROCEDURE NewUser
    @user_name  VARCHAR(100),
    @user_email VARCHAR(150),
    @user_phone VARCHAR(20),
    @user_pass  VARCHAR(255)
AS
BEGIN
    INSERT INTO Users (full_name, email, phone, password)
    VALUES (@user_name, @user_email, @user_phone, @user_pass);

    INSERT INTO Wallets (user_id, balance)
    VALUES (SCOPE_IDENTITY(), 0.00);
END;
GO

IF OBJECT_ID('GetUserSummary', 'P') IS NOT NULL DROP PROCEDURE GetUserSummary;
GO
CREATE PROCEDURE GetUserSummary
    @user_id_input INT
AS
BEGIN
    SELECT u.full_name, u.email, u.phone, u.status, w.balance
    FROM Users u
    INNER JOIN Wallets w ON u.user_id = w.user_id
    WHERE u.user_id = @user_id_input;

    SELECT t.txn_type, t.amount, t.note, t.txn_date
    FROM Transactions t
    INNER JOIN Wallets w ON t.wallet_id = w.wallet_id
    WHERE w.user_id = @user_id_input
    ORDER BY t.txn_date DESC;

    SELECT m.merchant_name, m.category, p.amount, p.pay_date
    FROM Payments p
    INNER JOIN Merchants m ON p.merchant_id = m.merchant_id
    INNER JOIN Wallets   w ON p.wallet_id   = w.wallet_id
    WHERE w.user_id = @user_id_input
    ORDER BY p.pay_date DESC;
END;
GO


-- ============================================================
-- STEP 14: TRIGGERS
-- ============================================================

IF OBJECT_ID('WarnLargeAmount', 'TR') IS NOT NULL DROP TRIGGER WarnLargeAmount;
GO
CREATE TRIGGER WarnLargeAmount
ON Transactions
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditLog (event, details)
    SELECT
        'Large amount warning',
        CONCAT('PKR ', amount, ' on wallet ', wallet_id)
    FROM INSERTED
    WHERE amount > 50000;
END;
GO

IF OBJECT_ID('RecordBalanceChange', 'TR') IS NOT NULL DROP TRIGGER RecordBalanceChange;
GO
CREATE TRIGGER RecordBalanceChange
ON Wallets
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditLog (event, details)
    SELECT
        'Balance changed',
        CONCAT('Wallet ', i.wallet_id,
               ' was PKR ', d.balance,
               ' now PKR ', i.balance)
    FROM INSERTED i
    INNER JOIN DELETED d ON i.wallet_id = d.wallet_id;
END;
GO

IF OBJECT_ID('RecordNewUser', 'TR') IS NOT NULL DROP TRIGGER RecordNewUser;
GO
CREATE TRIGGER RecordNewUser
ON Users
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditLog (event, details)
    SELECT 'New user joined', CONCAT(full_name, ' - ', email)
    FROM INSERTED;
END;
GO


-- ============================================================
-- STEP 15: BUSINESS ANALYSIS QUERIES
-- ============================================================

-- ------------------------------------------------------------
-- 1. AVG TRANSACTION
-- Platform-wide transaction size: average, minimum, maximum
-- ------------------------------------------------------------
SELECT
    AVG(amount) AS platform_avg_transaction,
    MIN(amount) AS smallest_transaction,
    MAX(amount) AS largest_transaction
FROM Transactions;

-- ------------------------------------------------------------
-- 2. DEBIT V CREDIT
-- Compares total volume and count for debit vs credit flows
-- ------------------------------------------------------------
SELECT
    txn_type,
    COUNT(txn_id) AS txn_count,
    SUM(amount)   AS total_amount,
    AVG(amount)   AS avg_amount
FROM Transactions
WHERE txn_type IN ('debit', 'credit')
GROUP BY txn_type;

-- ------------------------------------------------------------
-- 3. SPENDING BEHAVIOR
-- Total outflow per user (debits + outgoing transfers)
-- ------------------------------------------------------------
SELECT
    u.full_name,
    SUM(t.amount) AS total_spent
FROM Users u
INNER JOIN Wallets      w ON u.user_id   = w.user_id
INNER JOIN Transactions t ON w.wallet_id = t.wallet_id
WHERE t.txn_type IN ('debit', 'transfer_out')
GROUP BY u.user_id, u.full_name
ORDER BY total_spent DESC;

-- ------------------------------------------------------------
-- 4. HIGH VALUE CUSTOMER (CTE)
-- Ranks users by total spending using a window RANK()
-- ------------------------------------------------------------
WITH CustomerSpending AS (
    SELECT
        u.full_name,
        SUM(t.amount) AS total_spending
    FROM Users u
    INNER JOIN Wallets      w ON u.user_id   = w.user_id
    INNER JOIN Transactions t ON w.wallet_id = t.wallet_id
    WHERE t.txn_type IN ('debit', 'transfer_out')
    GROUP BY u.full_name
)
SELECT
    full_name,
    total_spending,
    RANK() OVER (ORDER BY total_spending DESC) AS spending_rank
FROM CustomerSpending
ORDER BY total_spending DESC;

-- ------------------------------------------------------------
-- 5. MERCHANT REVENUE PERFORMANCE
-- Total revenue, payment count, and avg payment per merchant
-- ------------------------------------------------------------
SELECT
    merchant_name,
    category,
    total_revenue,
    total_payments,
    avg_payment_amount
FROM MerchantPerformance
ORDER BY total_revenue DESC;

-- ------------------------------------------------------------
-- 6. MOST POPULAR MERCHANT CATEGORY (CTE)
-- Aggregates payment value and count by merchant category
-- ------------------------------------------------------------

WITH CategoryPerformance AS (
    SELECT
        m.category,
        COUNT(p.payment_id) AS number_of_payments,
        SUM(p.amount)       AS total_payment_value
    FROM Merchants m
    LEFT JOIN Payments p ON m.merchant_id = p.merchant_id
    GROUP BY m.category
)
SELECT *
FROM CategoryPerformance
ORDER BY total_payment_value DESC;

-- ------------------------------------------------------------
-- 7. HIGH RISK TRANSFER (VIEW)
-- All transactions exceeding the PKR 50,000 alert threshold
-- ------------------------------------------------------------
SELECT *
FROM FraudMonitoring
ORDER BY amount DESC;


-- ------------------------------------------------------------
-- 8. MONTHLY PLATFORM GROWTH (CTE)
-- Month-by-month transaction count and volume from live data
-- ------------------------------------------------------------
WITH MonthlyTransactions AS (
    SELECT
        YEAR(txn_date)  AS transaction_year,
        MONTH(txn_date) AS transaction_month,
        COUNT(txn_id)   AS total_transactions,
        SUM(amount)     AS total_volume
    FROM Transactions
    GROUP BY
        YEAR(txn_date),
        MONTH(txn_date)
)
SELECT *
FROM MonthlyTransactions
ORDER BY transaction_year, transaction_month;

-- ------------------------------------------------------------
-- 9. WALLET BALANCE DISTRIBUTION (VIEW)
-- Counts users and total balance held in each tier: HIGH / MEDIUM / LOW
-- ------------------------------------------------------------
SELECT
    balance_tier,
    COUNT(*)     AS user_count,
    SUM(balance) AS tier_total_balance
FROM WalletDistribution
GROUP BY balance_tier;

-- ------------------------------------------------------------
-- 10. CITY LEVEL PERFORMANCE
-- Monthly transaction volume, count, and active users per city
-- ------------------------------------------------------------
SELECT
    city_name,
    transaction_month,
    transaction_volume,
    transaction_count,
    active_users
FROM CityTransactions
ORDER BY transaction_month, transaction_volume DESC;


-- ============================================================
-- STEP 16: TESTING
-- ============================================================

-- TEST 1: Add PKR 10,000 to Musa's wallet (wallet_id = 1)
EXEC AddMoney 1, 10000.00;
SELECT full_name, balance FROM ShowBalances WHERE wallet_id = 1;

-- TEST 2: Withdraw PKR 3,000 from Musa's wallet
EXEC TakeMoney 1, 3000.00;
SELECT full_name, balance FROM ShowBalances WHERE wallet_id = 1;

-- TEST 3: Transfer PKR 2,000 from Musa (wallet 1) to Ahmed (wallet 2)
EXEC SendMoney 1, 2, 2000.00;
SELECT full_name, balance FROM ShowBalances WHERE wallet_id IN (1, 2);

-- TEST 4: Pay Daily Deli PKR 1,500 from Musa's wallet
EXEC PayShop 1, 1, 1500.00, 'Lunch at Daily Deli';
SELECT * FROM MerchantTotals WHERE merchant_name = 'Daily Deli';

-- TEST 5: Register a new user (Bilal) and create his wallet
EXEC NewUser 'Bilal Ahmed', 'bilal@payloop.pk', '03110000001', 'mypassword';
SELECT full_name, email, balance FROM ShowBalances WHERE full_name = 'Bilal Ahmed';

-- TEST 6: Large deposit to Harris (wallet 8) -- should trigger WarnLargeAmount
EXEC AddMoney 8, 75000.00;
SELECT * FROM AuditLog WHERE event = 'Large amount warning';

-- FINAL CHECK: complete state of all core views
SELECT * FROM ShowBalances      ORDER BY balance DESC;
SELECT * FROM ShowTransactions  ORDER BY txn_date DESC;
SELECT * FROM FraudMonitoring   ORDER BY amount DESC;
SELECT * FROM MerchantTotals    ORDER BY total_received DESC;
SELECT * FROM AuditLog          ORDER BY log_date DESC;