begin; -- Wrap the test run in a transaction so the DB is left unchanged.

select plan(1); -- Declare how many tests we expect to run in this file.

select ok(
  true,
  'db smoke test' -- A simple sanity check: if the test framework runs, this passes.
);

select * from finish(); -- Output the TAP summary (must be called at the end).

rollback; -- Always rollback so this test never persists changes.
