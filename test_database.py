import sqlite3

import pytest

from run_queries import build_database


@pytest.fixture
def db():
    connection = build_database(":memory:")
    yield connection
    connection.close()


def test_seed_data_loaded(db):
    assert db.execute("SELECT COUNT(*) FROM students").fetchone()[0] == 8
    assert db.execute("SELECT COUNT(*) FROM invoices").fetchone()[0] == 20
    assert db.execute("SELECT COUNT(*) FROM payments").fetchone()[0] == 15


def test_payment_for_missing_invoice_is_rejected(db):
    with pytest.raises(sqlite3.IntegrityError):
        db.execute(
            "INSERT INTO payments (invoice_id, amount_paid, payment_date, method, reference) "
            "VALUES (999, 100, '2026-11-01', 'cash', 'PAY-9999')"
        )


def test_negative_payment_is_rejected(db):
    with pytest.raises(sqlite3.IntegrityError):
        db.execute(
            "INSERT INTO payments (invoice_id, amount_paid, payment_date, method, reference) "
            "VALUES (1, -50, '2026-11-01', 'cash', 'PAY-9998')"
        )


def test_duplicate_payment_reference_is_rejected(db):
    with pytest.raises(sqlite3.IntegrityError):
        db.execute(
            "INSERT INTO payments (invoice_id, amount_paid, payment_date, method, reference) "
            "VALUES (1, 100, '2026-11-01', 'cash', 'PAY-0001')"
        )


def test_invalid_payment_method_is_rejected(db):
    with pytest.raises(sqlite3.IntegrityError):
        db.execute(
            "INSERT INTO payments (invoice_id, amount_paid, payment_date, method, reference) "
            "VALUES (1, 100, '2026-11-01', 'bitcoin', 'PAY-9997')"
        )


def test_no_invoice_is_overpaid(db):
    overpaid = db.execute(
        "SELECT COUNT(*) FROM invoice_balances WHERE balance < 0"
    ).fetchone()[0]
    assert overpaid == 0


def test_balance_for_part_paid_invoice(db):
    # Invoice 3: 150000 fee, paid 100000 + 30000, so 20000 is left.
    balance = db.execute(
        "SELECT balance FROM invoice_balances WHERE invoice_id = 3"
    ).fetchone()[0]
    assert balance == 20000


def test_discount_is_applied_to_net_amount(db):
    # Invoice 4 has a 50% scholarship: 150000 becomes 75000.
    net = db.execute(
        "SELECT net_amount FROM invoice_balances WHERE invoice_id = 4"
    ).fetchone()[0]
    assert net == 75000


def test_total_collected_matches_sum_of_payments(db):
    from_view = db.execute("SELECT SUM(total_paid) FROM invoice_balances").fetchone()[0]
    direct = db.execute("SELECT SUM(amount_paid) FROM payments").fetchone()[0]
    assert from_view == direct
