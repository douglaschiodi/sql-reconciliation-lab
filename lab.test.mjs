import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { PGlite } from '@electric-sql/pglite';

test('PostgreSQL reconciliation resolves duplicates, late events and tenant collisions', async () => {
  const db = new PGlite();
  try {
    await db.exec(await readFile(new URL('schema.sql', import.meta.url), 'utf8'));
    await db.exec(await readFile(new URL('fixtures.sql', import.meta.url), 'utf8'));
    const sql = await readFile(new URL('reconcile.sql', import.meta.url), 'utf8');
    const rows = (await db.query(sql)).rows;
    assert.deepEqual(rows, [
      {tenant:'north', invoice:'i-1', expected_cents:1200, observed_cents:1200, difference_cents:0, outcome:'matched'},
      {tenant:'north', invoice:'i-2', expected_cents:800, observed_cents:0, difference_cents:-800, outcome:'short'},
      {tenant:'south', invoice:'i-1', expected_cents:500, observed_cents:550, difference_cents:50, outcome:'over'},
      {tenant:'south', invoice:'i-3', expected_cents:300, observed_cents:0, difference_cents:-300, outcome:'short'}
    ]);
    await db.exec("INSERT INTO payment_events VALUES(9,'north','e-refund','p-2','i-2',3,'refunded',800,'2026-01-03Z')");
    assert.deepEqual((await db.query(sql)).rows, rows, 'duplicate provider event cannot change amount');
    await assert.rejects(db.exec("INSERT INTO invoices VALUES('north','bad',-1)"));
    const plan = await db.query('EXPLAIN ' + sql);
    assert.ok(plan.rows.length > 0);
    await db.exec('BEGIN; DELETE FROM payment_events; DELETE FROM invoices; ROLLBACK;');
    assert.equal((await db.query('SELECT * FROM invoices')).rows.length, 4);
  } finally { await db.close(); }
});
