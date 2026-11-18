-- Sample data. All names and emails are made up.

INSERT INTO students (student_id, first_name, last_name, email, class_level, enrolled_on) VALUES
(1, 'Ada',    'Okafor',  'ada.okafor@example.com',    'JSS1', '2026-09-07'),
(2, 'Bola',   'Adeyemi', 'bola.adeyemi@example.com',  'JSS2', '2025-09-08'),
(3, 'Chidi',  'Eze',     'chidi.eze@example.com',     'SS1',  '2025-09-08'),
(4, 'Dayo',   'Bello',   'dayo.bello@example.com',    'SS2',  '2024-09-09'),
(5, 'Emeka',  'Nwosu',   'emeka.nwosu@example.com',   'SS3',  '2023-09-11'),
(6, 'Fatima', 'Musa',    'fatima.musa@example.com',   'JSS1', '2026-09-07'),
(7, 'Grace',  'Okon',    'grace.okon@example.com',    'SS1',  '2025-09-08'),
(8, 'Hassan', 'Ibrahim', 'hassan.ibrahim@example.com','JSS3', '2024-09-09');

INSERT INTO fee_types (fee_type_id, name, amount, description) VALUES
(1, 'Tuition',          150000, 'Tuition for one term'),
(2, 'Examination',       15000, 'Examination fee for one term'),
(3, 'Sports and Clubs',   8000, 'Sports and clubs activities'),
(4, 'Library',            5000, 'Library access and books');

INSERT INTO discounts (discount_id, name, percent) VALUES
(1, 'Sibling Discount', 10),
(2, 'Scholarship',      50),
(3, 'Staff Child',      25);

-- Term 1 invoices. Columns: id, student, fee type, discount, issued, due, amount
INSERT INTO invoices (invoice_id, student_id, fee_type_id, discount_id, issue_date, due_date, amount) VALUES
(1,  1, 1, NULL, '2026-09-14', '2026-10-31', 150000),
(2,  2, 1, 1,    '2026-09-14', '2026-10-31', 150000),
(3,  3, 1, NULL, '2026-09-14', '2026-10-31', 150000),
(4,  4, 1, 2,    '2026-09-14', '2026-10-31', 150000),
(5,  5, 1, NULL, '2026-09-14', '2026-10-31', 150000),
(6,  6, 1, NULL, '2026-09-14', '2026-10-31', 150000),
(7,  7, 1, 3,    '2026-09-14', '2026-10-31', 150000),
(8,  8, 1, NULL, '2026-09-14', '2026-10-31', 150000),
(9,  1, 2, NULL, '2026-10-01', '2026-11-10', 15000),
(10, 2, 2, NULL, '2026-10-01', '2026-11-10', 15000),
(11, 3, 2, NULL, '2026-10-01', '2026-11-10', 15000),
(12, 4, 2, NULL, '2026-10-01', '2026-11-10', 15000),
(13, 5, 2, NULL, '2026-10-01', '2026-11-10', 15000),
(14, 6, 2, NULL, '2026-10-01', '2026-11-10', 15000),
(15, 1, 3, NULL, '2026-10-15', '2026-12-15', 8000),
(16, 3, 3, NULL, '2026-10-15', '2026-12-15', 8000),
(17, 5, 3, NULL, '2026-10-15', '2026-12-15', 8000),
(18, 2, 4, NULL, '2026-09-14', '2026-09-30', 5000),
(19, 4, 4, NULL, '2026-09-14', '2026-09-30', 5000),
(20, 7, 4, NULL, '2026-09-14', '2026-09-30', 5000);

-- Payments. Some invoices are paid in full, some in parts, some not at all.
INSERT INTO payments (payment_id, invoice_id, amount_paid, payment_date, method, reference) VALUES
(1,  1,  150000, '2026-10-10', 'transfer', 'PAY-0001'),
(2,  2,  135000, '2026-10-12', 'transfer', 'PAY-0002'),
(3,  3,  100000, '2026-10-20', 'transfer', 'PAY-0003'),
(4,  3,   30000, '2026-11-05', 'cash',     'PAY-0004'),
(5,  4,   75000, '2026-10-02', 'card',     'PAY-0005'),
(6,  5,   80000, '2026-10-25', 'transfer', 'PAY-0006'),
(7,  6,  150000, '2026-10-28', 'cash',     'PAY-0007'),
(8,  7,   56250, '2026-11-01', 'transfer', 'PAY-0008'),
(9,  9,   15000, '2026-11-02', 'cash',     'PAY-0009'),
(10, 10,  15000, '2026-11-08', 'transfer', 'PAY-0010'),
(11, 11,  10000, '2026-11-09', 'cash',     'PAY-0011'),
(12, 12,  15000, '2026-11-03', 'card',     'PAY-0012'),
(13, 15,   8000, '2026-11-12', 'transfer', 'PAY-0013'),
(14, 18,   5000, '2026-09-25', 'cash',     'PAY-0014'),
(15, 20,   2000, '2026-10-05', 'cash',     'PAY-0015');
