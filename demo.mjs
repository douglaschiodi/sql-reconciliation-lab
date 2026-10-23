import { PGlite } from '@electric-sql/pglite';
import { readFile } from 'node:fs/promises';
const db = new PGlite();
try {
  for (const name of ['schema.sql', 'fixtures.sql'])
    await db.exec(await readFile(new URL(name, import.meta.url), 'utf8'));
  const query = await readFile(new URL('reconcile.sql', import.meta.url), 'utf8');
  console.table((await db.query(query)).rows);
  console.log((await db.query('EXPLAIN ' + query)).rows);
} finally { await db.close(); }
