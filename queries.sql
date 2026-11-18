-- Ten SQL queries for the student fees database.
-- run_queries.py runs each one and saves the output to query_results.md.
-- Named values: :today is the date used for "overdue", :student_id picks a student.

-- Q1: Unpaid fees - every invoice that still has a balance
SELECT s.first_name || ' ' || s.last_name AS student,
       f.name AS fee,
       b.net_amount,
       b.total_paid,
       b.balance,
       b.due_date
FROM invoice_balances b
JOIN students s   ON s.student_id = b.student_id
JOIN fee_types f  ON f.fee_type_id = b.fee_type_id
WHERE b.balance > 0
ORDER BY b.due_date, student;

-- Q2: Payment history for one student (change :student_id to see another)
SELECT p.payment_date,
       p.reference,
       f.name AS fee,
       p.amount_paid,
       p.method
FROM payments p
JOIN invoices i   ON i.invoice_id = p.invoice_id
JOIN fee_types f  ON f.fee_type_id = i.fee_type_id
WHERE i.student_id = :student_id
ORDER BY p.payment_date;

-- Q3: Total collections - all money received so far
SELECT COUNT(*) AS number_of_payments,
       SUM(amount_paid) AS total_collected
FROM payments;

-- Q4: Total collections for each fee type
SELECT f.name AS fee,
       COUNT(p.payment_id) AS payments,
       SUM(p.amount_paid) AS collected
FROM payments p
JOIN invoices i   ON i.invoice_id = p.invoice_id
JOIN fee_types f  ON f.fee_type_id = i.fee_type_id
GROUP BY f.name
ORDER BY collected DESC;

-- Q5: Overdue payments - past the due date and still not fully paid
SELECT s.first_name || ' ' || s.last_name AS student,
       f.name AS fee,
       b.due_date,
       CAST(julianday(:today) - julianday(b.due_date) AS INTEGER) AS days_overdue,
       b.balance
FROM invoice_balances b
JOIN students s   ON s.student_id = b.student_id
JOIN fee_types f  ON f.fee_type_id = b.fee_type_id
WHERE b.balance > 0 AND b.due_date < :today
ORDER BY days_overdue DESC;

-- Q6: Outstanding balance per student (largest debt first)
SELECT s.first_name || ' ' || s.last_name AS student,
       s.class_level,
       SUM(b.balance) AS outstanding_balance
FROM invoice_balances b
JOIN students s ON s.student_id = b.student_id
GROUP BY s.student_id
HAVING SUM(b.balance) > 0
ORDER BY outstanding_balance DESC;

-- Q7: Students who have not made any payment at all
SELECT s.student_id,
       s.first_name || ' ' || s.last_name AS student,
       s.class_level
FROM students s
WHERE s.student_id NOT IN (
    SELECT i.student_id
    FROM invoices i
    JOIN payments p ON p.invoice_id = i.invoice_id
);

-- Q8: How much each discount has reduced the fees
SELECT d.name AS discount,
       d.percent,
       COUNT(i.invoice_id) AS invoices,
       SUM(i.amount * d.percent / 100.0) AS total_discount_given
FROM discounts d
JOIN invoices i ON i.discount_id = d.discount_id
GROUP BY d.discount_id
ORDER BY total_discount_given DESC;

-- Q9: Collections per month
SELECT strftime('%Y-%m', payment_date) AS month,
       COUNT(*) AS payments,
       SUM(amount_paid) AS collected
FROM payments
GROUP BY month
ORDER BY month;

-- Q10: Collection rate - how much of the net fees billed has been paid
SELECT SUM(net_amount) AS total_billed_after_discounts,
       SUM(total_paid) AS total_paid,
       SUM(balance) AS total_outstanding,
       ROUND(100.0 * SUM(total_paid) / SUM(net_amount), 1) AS percent_collected
FROM invoice_balances;
