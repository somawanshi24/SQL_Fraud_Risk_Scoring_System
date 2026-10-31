# Business Requirements Document (BRD)

**Project:** SQL Driven Fraud Detection: Closing the Gap in Transaction Risk Scoring

This BRD was written for the simulated business scenario described in the README. The company, team and stakeholder roles are fictional; the dataset is PaySim.

## 1. Document control

| Item | Detail |
|---|---|
| Project | SQL Driven Fraud Detection: Closing the Gap in Transaction Risk Scoring |
| Author | Neha Somawanshi (Business Analyst) |
| Requested by | Risk and Fraud Analytics team (fictional) |
| Status | Delivered |

## 2. Purpose and scope

**Purpose.** Give the company a stronger way to find fraudulent payment transactions than its current fixed-rule flag, and show the results in a dashboard the review team can use.

**In scope**
- Loading and organizing the transaction data in MySQL
- A transaction validation procedure with error logging
- A rule based risk score and a high-risk threshold
- Views that compare the new system with the existing flag
- A Tableau dashboard built on those views

**Out of scope**
- Machine learning models
- Real-time scoring and integration with a live payment system
- Behavioral signals such as device, location and transaction velocity (not in the dataset)

## 3. Stakeholders

| Stakeholder | Role | Interest |
|---|---|---|
| Risk and Fraud Analytics team | Requester and sponsor | Catch more fraud and measure the gap in the current flag |
| Fraud review team | Dashboard users | A clear, prioritized list of transactions to review |
| Data and database team | Maintains the database | A clean schema and scripts they can rerun |

## 4. Business problem and objectives

The existing fraud flag is a single fixed rule and misses almost all fraud: it caught 16 of 8,213 fraud cases (0.19% recall).

| ID | Objective | Success measure |
|---|---|---|
| BO-1 | Detect far more real fraud than the current flag | Recall clearly above the 0.19% baseline (achieved: 94.36%) |
| BO-2 | Show how far the current flag falls short | Caught and missed fraud compared side by side for both systems |
| BO-3 | Give reviewers an actionable view | Dashboard and list of high-risk transactions |
| BO-4 | Keep the results trustworthy | Risk score never uses the true fraud label |

## 5. Functional requirements

| ID | Requirement | Priority | Delivered by |
|---|---|---|---|
| FR-1 | Load the full PaySim CSV (6.36M rows) into a staging table | Must | `staging_transactions` |
| FR-2 | Organize the data into related tables for transaction types, accounts and transactions, linked by keys | Must | `transaction_types`, `accounts`, `transaction` |
| FR-3 | Check that the sender has enough balance before a transaction is recorded | Must | `process_transaction` procedure |
| FR-4 | If a check fails, undo the transaction and log the failed attempt | Must | Rollback and `failed_transactions` |
| FR-5 | Calculate a risk score per transaction using business rules (risky type, drained balance, large amount, balance mismatch) | Must | `calculated_risk_score` function |
| FR-6 | Flag a transaction as high risk when its score is 70 or more | Must | Threshold in the views |
| FR-7 | Label every transaction as caught or missed by the existing flag and by the new system | Must | `fraud_detection_comparison` view |
| FR-8 | List all high-risk transactions for review | Must | `high_risk_transactions` view |
| FR-9 | Present the comparison and results in a dashboard | Should | Tableau dashboard |

## 6. Non-functional requirements

| ID | Requirement |
|---|---|
| NFR-1 | **No label leakage:** the risk score must not read the `isFraud` column |
| NFR-2 | **Data integrity:** foreign keys must be active again after the bulk load |
| NFR-3 | **Performance:** the bulk load runs in batches by `step` range to avoid client timeouts |
| NFR-4 | **Reproducibility:** scripts run in numbered order and rebuild the system from the raw CSV |

## 7. Business rules

| Rule | Points |
|---|---|
| Type is TRANSFER or CASH_OUT | 30 |
| Sender balance drained to 0 with amount above 10,000 | 40 |
| Amount above 200,000 | 15 |
| Balance arithmetic does not add up | 10 |

A score of 70 or more is high risk. This needs a risky type and a drained balance together.

## 8. Assumptions and constraints

- The data is synthetic, so results will not carry over directly to a real company.
- The rules were designed with knowledge of PaySim's fraud patterns and tested on the same data, with no train and test split.
- The CSV is too large for GitHub and must be downloaded from Kaggle.
- The company prefers catching fraud over keeping the review queue small.

## 9. Risks

| Risk | Impact | Response |
|---|---|---|
| Low precision (about 0.66%) creates a large review queue | Reviewer workload | Accepted as a trade-off; tiered risk bands and review capacity suggested as next steps |
| Rules overfit to PaySim patterns | Lower recall on unseen data | Stated as a limitation; ML scoring proposed |
| A stricter rule set lowers recall | More fraud missed | Tested a stricter drain rule and a 5-rule, 95-point version; kept the 70-point version live |

## 10. Acceptance criteria

- All 6,362,620 rows load into the database and relate correctly across tables.
- The procedure rejects an invalid transaction, rolls it back and logs it.
- The risk score runs without reading the fraud label.
- The comparison view reports recall for both systems, and the new system's recall is clearly above the baseline.
- The dashboard shows the comparison and the high-risk list.

---

Back to the [project README](README.md).
