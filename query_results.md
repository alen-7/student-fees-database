# Query results

Run with today = 2026-11-18 and student_id = 3.

## Q1: Unpaid fees - every invoice that still has a balance

```sql
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
```

| student | fee | net_amount | total_paid | balance | due_date |
|---|---|---|---|---|---|
| Dayo Bello | Library | 5000.0 | 0 | 5000.0 | 2026-09-30 |
| Grace Okon | Library | 5000.0 | 2000.0 | 3000.0 | 2026-09-30 |
| Chidi Eze | Tuition | 150000.0 | 130000.0 | 20000.0 | 2026-10-31 |
| Emeka Nwosu | Tuition | 150000.0 | 80000.0 | 70000.0 | 2026-10-31 |
| Grace Okon | Tuition | 112500.0 | 56250.0 | 56250.0 | 2026-10-31 |
| Hassan Ibrahim | Tuition | 150000.0 | 0 | 150000.0 | 2026-10-31 |
| Chidi Eze | Examination | 15000.0 | 10000.0 | 5000.0 | 2026-11-10 |
| Emeka Nwosu | Examination | 15000.0 | 0 | 15000.0 | 2026-11-10 |
| Fatima Musa | Examination | 15000.0 | 0 | 15000.0 | 2026-11-10 |
| Chidi Eze | Sports and Clubs | 8000.0 | 0 | 8000.0 | 2026-12-15 |
| Emeka Nwosu | Sports and Clubs | 8000.0 | 0 | 8000.0 | 2026-12-15 |

## Q2: Payment history for one student (change :student_id to see another)

```sql
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
```

| payment_date | reference | fee | amount_paid | method |
|---|---|---|---|---|
| 2026-10-20 | PAY-0003 | Tuition | 100000.0 | transfer |
| 2026-11-05 | PAY-0004 | Tuition | 30000.0 | cash |
| 2026-11-09 | PAY-0011 | Examination | 10000.0 | cash |

## Q3: Total collections - all money received so far

```sql
SELECT COUNT(*) AS number_of_payments,
       SUM(amount_paid) AS total_collected
FROM payments;
```

| number_of_payments | total_collected |
|---|---|
| 15 | 846250.0 |

## Q4: Total collections for each fee type

```sql
SELECT f.name AS fee,
       COUNT(p.payment_id) AS payments,
       SUM(p.amount_paid) AS collected
FROM payments p
JOIN invoices i   ON i.invoice_id = p.invoice_id
JOIN fee_types f  ON f.fee_type_id = i.fee_type_id
GROUP BY f.name
ORDER BY collected DESC;
```

| fee | payments | collected |
|---|---|---|
| Tuition | 8 | 776250.0 |
| Examination | 4 | 55000.0 |
| Sports and Clubs | 1 | 8000.0 |
| Library | 2 | 7000.0 |

## Q5: Overdue payments - past the due date and still not fully paid

```sql
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
```

| student | fee | due_date | days_overdue | balance |
|---|---|---|---|---|
| Dayo Bello | Library | 2026-09-30 | 49 | 5000.0 |
| Grace Okon | Library | 2026-09-30 | 49 | 3000.0 |
| Chidi Eze | Tuition | 2026-10-31 | 18 | 20000.0 |
| Emeka Nwosu | Tuition | 2026-10-31 | 18 | 70000.0 |
| Grace Okon | Tuition | 2026-10-31 | 18 | 56250.0 |
| Hassan Ibrahim | Tuition | 2026-10-31 | 18 | 150000.0 |
| Chidi Eze | Examination | 2026-11-10 | 8 | 5000.0 |
| Emeka Nwosu | Examination | 2026-11-10 | 8 | 15000.0 |
| Fatima Musa | Examination | 2026-11-10 | 8 | 15000.0 |

## Q6: Outstanding balance per student (largest debt first)

```sql
SELECT s.first_name || ' ' || s.last_name AS student,
       s.class_level,
       SUM(b.balance) AS outstanding_balance
FROM invoice_balances b
JOIN students s ON s.student_id = b.student_id
GROUP BY s.student_id
HAVING SUM(b.balance) > 0
ORDER BY outstanding_balance DESC;
```

| student | class_level | outstanding_balance |
|---|---|---|
| Hassan Ibrahim | JSS3 | 150000.0 |
| Emeka Nwosu | SS3 | 93000.0 |
| Grace Okon | SS1 | 59250.0 |
| Chidi Eze | SS1 | 33000.0 |
| Fatima Musa | JSS1 | 15000.0 |
| Dayo Bello | SS2 | 5000.0 |

## Q7: Students who have not made any payment at all

```sql
SELECT s.student_id,
       s.first_name || ' ' || s.last_name AS student,
       s.class_level
FROM students s
WHERE s.student_id NOT IN (
    SELECT i.student_id
    FROM invoices i
    JOIN payments p ON p.invoice_id = i.invoice_id
);
```

| student_id | student | class_level |
|---|---|---|
| 8 | Hassan Ibrahim | JSS3 |

## Q8: How much each discount has reduced the fees

```sql
SELECT d.name AS discount,
       d.percent,
       COUNT(i.invoice_id) AS invoices,
       SUM(i.amount * d.percent / 100.0) AS total_discount_given
FROM discounts d
JOIN invoices i ON i.discount_id = d.discount_id
GROUP BY d.discount_id
ORDER BY total_discount_given DESC;
```

| discount | percent | invoices | total_discount_given |
|---|---|---|---|
| Scholarship | 50.0 | 1 | 75000.0 |
| Staff Child | 25.0 | 1 | 37500.0 |
| Sibling Discount | 10.0 | 1 | 15000.0 |

## Q9: Collections per month

```sql
SELECT strftime('%Y-%m', payment_date) AS month,
       COUNT(*) AS payments,
       SUM(amount_paid) AS collected
FROM payments
GROUP BY month
ORDER BY month;
```

| month | payments | collected |
|---|---|---|
| 2026-09 | 1 | 5000.0 |
| 2026-10 | 7 | 692000.0 |
| 2026-11 | 7 | 149250.0 |

## Q10: Collection rate - how much of the net fees billed has been paid

```sql
SELECT SUM(net_amount) AS total_billed_after_discounts,
       SUM(total_paid) AS total_paid,
       SUM(balance) AS total_outstanding,
       ROUND(100.0 * SUM(total_paid) / SUM(net_amount), 1) AS percent_collected
FROM invoice_balances;
```

| total_billed_after_discounts | total_paid | total_outstanding | percent_collected |
|---|---|---|---|
| 1201500.0 | 846250.0 | 355250.0 | 70.4 |
