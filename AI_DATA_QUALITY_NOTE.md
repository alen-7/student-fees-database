# AI data-quality note

## Why data quality matters for AI
AI systems learn from or answer using the data we give them. If the data is
wrong, the AI gives wrong answers confidently ("garbage in, garbage out").
Imagine this fees database powering a chatbot that tells parents what they
owe, or a model that predicts which students will pay late. Bad data would
cause real harm: a parent told they owe nothing when they do, or a student
wrongly flagged as a defaulter.

## Data problems and how this design reduces them

| Possible problem | Effect on an AI system | How this database helps |
|------------------|------------------------|-------------------------|
| Payment recorded for an invoice that does not exist | Chatbot quotes money that belongs to nobody | Foreign keys block it (tested) |
| A receipt entered twice | Totals look higher, so balances are wrong | `reference` is UNIQUE (tested) |
| Negative or zero amounts | Wrong totals and wrong predictions | CHECK rules on every amount (tested) |
| Typos in the payment method ("Transfr") | Reports and models split one method into many | CHECK limits it to cash, transfer, card (tested) |
| Same student typed two ways ("Ada Okafor", "A. Okafor") | The AI treats one student as two people | Students have one ID, and other tables use only that ID |
| Fee price changed later | Old invoices silently change | The invoice keeps its own copy of the amount |
| Stored balance not matching payments | Chatbot gives an outdated balance | Balance is calculated from payments, never typed |
| Dates in different formats | Overdue calculations break | One format (YYYY-MM-DD) used throughout |

## Problems this database does NOT catch
- **Wrong but valid data.** A cashier entering 15000 instead of 150000 passes
  every rule. Review and reconciliation against bank statements are needed.
- **Overpayment.** Nothing stops payments adding up to more than the invoice.
  `test_no_invoice_is_overpaid` checks the sample data, but a real system
  should check this when a payment is saved.
- **Missing records.** A payment that was never entered cannot be found by
  any rule.
- **Bias.** If an AI learned from this data, patterns such as "students with
  scholarships pay late" could be unfair or just reflect timing.

## Privacy
This data identifies children and their families' finances. The sample data is
invented. Real student data should be anonymised before AI use, shared only
with permission, and protected under Nigerian data-protection requirements
(check with the school's privacy officer).

## Conclusion
Good AI starts with good data. Constraints, one source of truth for each fact,
calculated balances and regular checks make the data trustworthy before any
AI is built on it.
