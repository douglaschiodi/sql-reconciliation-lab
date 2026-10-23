# Architecture and tradeoffs

## Data flow

```text
raw arrivals → tenant-scoped deduplication → latest provider version → invoice totals → differences
```

The SQL first chooses the earliest ingestion for each (tenant,event_id). It then chooses the highest provider sequence for each (tenant,payment), independently of arrival time. A settled latest state contributes its full amount; pending and fully refunded latest states contribute zero. A LEFT JOIN keeps invoices without any events.

Expected results: north/i-1 matches 1200 cents; north/i-2 is short 800 after a refund; south/i-1 is over by 50; south/i-3 is short 300. The same payment and event identifiers appear in separate tenants to exercise isolation.

`schema.sql` and `reconcile.sql` are plain PostgreSQL SQL. The Node harness is only a portable execution wrapper. `npm run demo` prints results and EXPLAIN output. The indexes demonstrate access-path considerations; the tiny fixture is not a performance benchmark.

## Why this shape

The repository keeps a small, inspectable core and exercises behavior through real storage or HTTP where applicable. No service account, customer environment or paid API is required.

## Boundaries

The model assumes immutable provider events and a monotonic sequence per payment. Duplicate payload disagreement is not resolved here: first ingestion wins. It models full refunds, one invoice per payment and integer cents in one currency. It does not support partial refunds, chargeback ledgers, currency conversion or operational payment processing. PGlite is not a production PostgreSQL deployment.

## Test strategy

The PostgreSQL integration test asserts exact balances, ignores a repeated provider event, checks a negative-amount constraint, obtains EXPLAIN output and proves transaction rollback.

Tests exercise behavior and failure cases; they do not certify readiness for production. Synthetic examples are intentionally small enough to review in one sitting.
