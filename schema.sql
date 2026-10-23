CREATE TABLE invoices (
  tenant text NOT NULL,
  invoice text NOT NULL,
  expected_cents integer NOT NULL CHECK(expected_cents >= 0),
  PRIMARY KEY(tenant, invoice)
);
-- Raw ingestion deliberately allows provider duplicates.
CREATE TABLE payment_events (
  ingestion_id integer PRIMARY KEY,
  tenant text NOT NULL,
  event_id text NOT NULL,
  payment text NOT NULL,
  invoice text NOT NULL,
  provider_sequence integer NOT NULL CHECK(provider_sequence > 0),
  state text NOT NULL CHECK(state IN ('pending','settled','refunded')),
  amount_cents integer NOT NULL CHECK(amount_cents >= 0),
  received_at timestamptz NOT NULL,
  FOREIGN KEY(tenant, invoice) REFERENCES invoices(tenant, invoice)
);
CREATE INDEX payment_order ON payment_events(tenant, payment, provider_sequence DESC);
CREATE INDEX event_dedup ON payment_events(tenant, event_id, ingestion_id);
