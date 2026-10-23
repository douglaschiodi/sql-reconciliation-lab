WITH arrivals AS (
  SELECT *, row_number() OVER (
    PARTITION BY tenant, event_id ORDER BY ingestion_id
  ) AS arrival_rank
  FROM payment_events
), versions AS (
  SELECT *, row_number() OVER (
    PARTITION BY tenant, payment
    ORDER BY provider_sequence DESC, ingestion_id DESC
  ) AS version_rank
  FROM arrivals WHERE arrival_rank = 1
), totals AS (
  SELECT tenant, invoice,
    sum(CASE WHEN state = 'settled' THEN amount_cents ELSE 0 END)::integer AS observed_cents
  FROM versions WHERE version_rank = 1
  GROUP BY tenant, invoice
), balances AS (
  SELECT i.*, coalesce(t.observed_cents,0)::integer AS observed_cents
  FROM invoices i LEFT JOIN totals t USING(tenant, invoice)
)
SELECT tenant, invoice, expected_cents, observed_cents,
       observed_cents - expected_cents AS difference_cents,
       CASE WHEN observed_cents = expected_cents THEN 'matched'
            WHEN observed_cents < expected_cents THEN 'short' ELSE 'over' END AS outcome
FROM balances
ORDER BY tenant, invoice;
