-- Student fees database (Module B3)
-- SQLite. Run with: python run_queries.py

PRAGMA foreign_keys = ON;

-- One row per student.
CREATE TABLE students (
    student_id   INTEGER PRIMARY KEY,
    first_name   TEXT NOT NULL,
    last_name    TEXT NOT NULL,
    email        TEXT NOT NULL UNIQUE,
    class_level  TEXT NOT NULL,
    enrolled_on  TEXT NOT NULL            -- date as YYYY-MM-DD
);

-- The kinds of fee the school charges (tuition, exam fee, ...).
CREATE TABLE fee_types (
    fee_type_id  INTEGER PRIMARY KEY,
    name         TEXT NOT NULL UNIQUE,
    amount       REAL NOT NULL CHECK (amount > 0),
    description  TEXT
);

-- Discounts a student can receive (sibling, scholarship, ...).
CREATE TABLE discounts (
    discount_id  INTEGER PRIMARY KEY,
    name         TEXT NOT NULL UNIQUE,
    percent      REAL NOT NULL CHECK (percent > 0 AND percent <= 100)
);

-- A bill sent to a student for one fee.
-- amount is copied from the fee at billing time, so a later change to the
-- fee price does not change old invoices.
CREATE TABLE invoices (
    invoice_id   INTEGER PRIMARY KEY,
    student_id   INTEGER NOT NULL REFERENCES students (student_id),
    fee_type_id  INTEGER NOT NULL REFERENCES fee_types (fee_type_id),
    discount_id  INTEGER REFERENCES discounts (discount_id),   -- NULL = no discount
    issue_date   TEXT NOT NULL,
    due_date     TEXT NOT NULL,
    amount       REAL NOT NULL CHECK (amount > 0),
    CHECK (due_date >= issue_date)
);

-- Money received against an invoice. One invoice can have many payments
-- (part payments).
CREATE TABLE payments (
    payment_id    INTEGER PRIMARY KEY,
    invoice_id    INTEGER NOT NULL REFERENCES invoices (invoice_id),
    amount_paid   REAL NOT NULL CHECK (amount_paid > 0),
    payment_date  TEXT NOT NULL,
    method        TEXT NOT NULL CHECK (method IN ('cash', 'transfer', 'card')),
    reference     TEXT NOT NULL UNIQUE      -- receipt number: blocks double posting
);

-- Indexes make joins and searches faster on the columns we filter by.
CREATE INDEX idx_invoices_student ON invoices (student_id);
CREATE INDEX idx_invoices_due_date ON invoices (due_date);
CREATE INDEX idx_payments_invoice ON payments (invoice_id);

-- A view is a saved query. This one works out, for every invoice, how much
-- was owed after discount, how much has been paid and what is left.
CREATE VIEW invoice_balances AS
SELECT *, ROUND(net_amount - total_paid, 2) AS balance
FROM (
    SELECT
        i.invoice_id,
        i.student_id,
        i.fee_type_id,
        i.due_date,
        ROUND(i.amount * (1 - COALESCE(d.percent, 0) / 100.0), 2) AS net_amount,
        COALESCE((SELECT SUM(p.amount_paid)
                  FROM payments p
                  WHERE p.invoice_id = i.invoice_id), 0) AS total_paid
    FROM invoices i
    LEFT JOIN discounts d ON d.discount_id = i.discount_id
);
