# Entity Relationship Diagram

This diagram is written in Mermaid, which GitHub draws automatically.
(You can also paste the code into https://mermaid.live to export a PNG.)

```mermaid
erDiagram
    STUDENTS ||--o{ INVOICES : "is billed"
    FEE_TYPES ||--o{ INVOICES : "defines the fee"
    DISCOUNTS |o--o{ INVOICES : "may reduce"
    INVOICES ||--o{ PAYMENTS : "receives"

    STUDENTS {
        int student_id PK
        text first_name
        text last_name
        text email UK
        text class_level
        text enrolled_on
    }
    FEE_TYPES {
        int fee_type_id PK
        text name UK
        real amount
        text description
    }
    DISCOUNTS {
        int discount_id PK
        text name UK
        real percent
    }
    INVOICES {
        int invoice_id PK
        int student_id FK
        int fee_type_id FK
        int discount_id FK "optional"
        text issue_date
        text due_date
        real amount
    }
    PAYMENTS {
        int payment_id PK
        int invoice_id FK
        real amount_paid
        text payment_date
        text method
        text reference UK
    }
```

## How to read it
- One **student** can have many **invoices**. Each invoice belongs to one student.
- One **fee type** (like Tuition) can appear on many invoices.
- An invoice has **zero or one** discount. Many invoices can use the same discount.
- One **invoice** can receive many **payments** (part payments).

## Why this design
- **Normalisation:** each fact is stored once. A student's email lives only in
  `students`; a fee's price lives only in `fee_types`.
- **Part payments:** payments are a separate table, so an invoice can be paid
  in instalments and the outstanding balance is worked out, not typed in.
- **Balances are calculated, not stored.** The `invoice_balances` view adds up
  payments each time, so a balance can never drift out of step with the payments.
- **PK** = primary key, **FK** = foreign key, **UK** = unique key.
