# SQL Reconciliation Lab

PostgreSQL queries that reconcile synthetic invoices against duplicated and out-of-order payment events.

[Guia em português](README.pt-BR.md) · [Architecture and tradeoffs](ARCHITECTURE.md)

## Run locally

Node.js 24+ and npm. PGlite runs PostgreSQL locally in WebAssembly; no database account or Docker required.

```sh
npm ci
npm test
npm run demo
```

## How it works

```text
raw arrivals → tenant-scoped deduplication → latest provider version → invoice totals → differences
```

The SQL first chooses the earliest ingestion for each (tenant,event_id). It then chooses the highest provider sequence for each (tenant,payment), independently of arrival time. A settled latest state contributes its full amount; pending and fully refunded latest states contribute zero. A LEFT JOIN keeps invoices without any events.

Expected results: north/i-1 matches 1200 cents; north/i-2 is short 800 after a refund; south/i-1 is over by 50; south/i-3 is short 300. The same payment and event identifiers appear in separate tenants to exercise isolation.

`schema.sql` and `reconcile.sql` are plain PostgreSQL SQL. The Node harness is only a portable execution wrapper. `npm run demo` prints results and EXPLAIN output. The indexes demonstrate access-path considerations; the tiny fixture is not a performance benchmark.

## Verification

The PostgreSQL integration test asserts exact balances, ignores a repeated provider event, checks a negative-amount constraint, obtains EXPLAIN output and proves transaction rollback.

## Scope and limitations

The model assumes immutable provider events and a monotonic sequence per payment. Duplicate payload disagreement is not resolved here: first ingestion wins. It models full refunds, one invoice per payment and integer cents in one currency. It does not support partial refunds, chargeback ledgers, currency conversion or operational payment processing. PGlite is not a production PostgreSQL deployment.

## Provenance

This is an original portfolio demonstration created for Douglas Chiodi with AI assistance. All fixtures, identities, identifiers, amounts and examples are synthetic. No customer code, production configuration, credentials, proprietary assets or existing repository history are included. It does not claim deployment experience or business outcomes from these sample applications.

MIT applies to the original source in this repository; third-party dependencies retain their own licenses.

## Portfolio

- [Durable Job Queue](https://github.com/douglaschiodi/python-durable-job-queue)
- [AI Code Review Benchmark Lab](https://github.com/douglaschiodi/ai-code-review-benchmark)
- [Tenant Access Demo](https://github.com/douglaschiodi/typescript-tenant-access-demo)
- [Reliable Webhooks Lab](https://github.com/douglaschiodi/dotnet-reliable-webhooks)
