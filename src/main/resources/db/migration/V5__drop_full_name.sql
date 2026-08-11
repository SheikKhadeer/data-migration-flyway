-- V5: now that V3 has run in every environment and nothing reads full_name
-- anymore (application code was updated to use first_name/last_name and
-- deployed first), it's safe to drop the old column.
--
-- This two-step pattern (add+backfill in one migration, drop later) is the
-- standard way to change a column without downtime: you never want a
-- migration that both removes a column AND deploys code that stops using it
-- in the same release — there's no rollback window if something's wrong.

ALTER TABLE customer DROP COLUMN full_name;
