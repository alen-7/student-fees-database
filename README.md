# Student Fees Database (Module B3)

A small relational database for managing students, fee types, invoices,
payments, discounts and outstanding balances. Built for the FlexiSAF
Internship Program, AI Engineering pathway, Module B3: Databases, SQL and
data modeling.

Author: Chinecherem Ude

## What is inside
| File | Purpose |
|------|---------|
| `ERD.md` | Entity relationship diagram and design reasons |
| `schema.sql` | Database schema: 5 tables, constraints, indexes, 1 view |
| `seed.sql` | Sample data (8 students, 20 invoices, 15 payments) |
| `sample_payments.csv` | The sample payment records as a spreadsheet file |
| `queries.sql` | Ten SQL queries |
| `query_results.md` | Each query with its results |
| `run_queries.py` | Builds the database, runs the queries, saves results |
| `test_database.py` | Automated checks on the rules and calculations |
| `AI_DATA_QUALITY_NOTE.md` | How data quality affects downstream AI systems |

## The ten queries
1. Unpaid fees (invoices with a balance)
2. Payment history for one student
3. Total collections
4. Total collections per fee type
5. Overdue payments
6. Outstanding balance per student
7. Students who have made no payment
8. Amount reduced by each discount
9. Collections per month
10. Collection rate

## Requirements
- Python 3.11 or newer (SQLite is built into Python, so nothing else is needed)
- Git

## Setup
```bash
git clone https://github.com/alen-7/student-fees-database.git
cd student-fees-database
python -m venv .venv
```

Activate the environment:
- Windows (Command Prompt): `.venv\Scripts\activate.bat`
- Windows (PowerShell): `.venv\Scripts\Activate.ps1`
- Mac/Linux: `source .venv/bin/activate`

Install the requirements:
```bash
python -m pip install -r requirements.txt
```

## Run it
```bash
python run_queries.py
```
This creates `fees.db`, runs all ten queries and refreshes `query_results.md`.
"Overdue" uses today's date. To use a fixed date:
```bash
python run_queries.py 2026-11-16
```

## Run the tests
```bash
python -m pytest
```

## Explore the database yourself
Open `fees.db` with [DB Browser for SQLite](https://sqlitebrowser.org/), or in
VS Code with a SQLite extension. In queries that use `:today` or
`:student_id`, replace them with a real value such as `'2026-11-16'` or `3`.
