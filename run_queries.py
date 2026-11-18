"""Builds the database, runs every query in queries.sql, saves the results.

Run:  python run_queries.py
Optional: python run_queries.py 2026-11-16   (use a different "today")
"""

import csv
import re
import sqlite3
import sys
from datetime import date
from pathlib import Path

BASE_DIR = Path(__file__).parent
DB_PATH = BASE_DIR / "fees.db"


def build_database(db_path=DB_PATH):
    """Create a fresh database from schema.sql and seed.sql."""
    if db_path != ":memory:" and Path(db_path).exists():
        Path(db_path).unlink()
    connection = sqlite3.connect(db_path)
    connection.execute("PRAGMA foreign_keys = ON")
    connection.executescript((BASE_DIR / "schema.sql").read_text(encoding="utf-8"))
    connection.executescript((BASE_DIR / "seed.sql").read_text(encoding="utf-8"))
    connection.commit()
    return connection


def read_queries():
    """Split queries.sql into (title, sql) pairs. Each starts with '-- Qn: title'."""
    text = (BASE_DIR / "queries.sql").read_text(encoding="utf-8")
    blocks = re.split(r"^-- (?=Q\d+:)", text, flags=re.MULTILINE)[1:]
    queries = []
    for block in blocks:
        title, _, sql = block.partition("\n")
        queries.append((title.strip(), sql.strip()))
    return queries


def to_markdown_table(columns, rows):
    lines = ["| " + " | ".join(columns) + " |"]
    lines.append("|" + "|".join(["---"] * len(columns)) + "|")
    for row in rows:
        lines.append("| " + " | ".join("" if v is None else str(v) for v in row) + " |")
    return "\n".join(lines)


def export_payments(connection):
    cursor = connection.execute("SELECT * FROM payments ORDER BY payment_id")
    columns = [c[0] for c in cursor.description]
    with open(
        BASE_DIR / "sample_payments.csv", "w", newline="", encoding="utf-8"
    ) as file:
        writer = csv.writer(file)
        writer.writerow(columns)
        writer.writerows(cursor.fetchall())


def main():
    today = sys.argv[1] if len(sys.argv) > 1 else date.today().isoformat()
    connection = build_database()
    params = {"today": today, "student_id": 3}

    output = [
        "# Query results",
        "",
        f"Run with today = {today} and student_id = 3.",
        "",
    ]
    for title, sql in read_queries():
        cursor = connection.execute(sql, params)
        columns = [c[0] for c in cursor.description]
        rows = cursor.fetchall()
        print(f"\n{title}")
        for row in rows:
            print("  ", row)
        output += [
            f"## {title}",
            "",
            "```sql",
            sql,
            "```",
            "",
            to_markdown_table(columns, rows),
            "",
        ]

    (BASE_DIR / "query_results.md").write_text("\n".join(output), encoding="utf-8")
    export_payments(connection)
    connection.close()
    print("\nSaved query_results.md and sample_payments.csv")


if __name__ == "__main__":
    main()
