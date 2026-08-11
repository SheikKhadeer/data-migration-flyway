-- V3: real DATA migration, not just schema — split existing full_name values
-- into first_name/last_name for every row already in the table.

ALTER TABLE customer ADD COLUMN first_name VARCHAR(120);
ALTER TABLE customer ADD COLUMN last_name VARCHAR(120);

-- backfill from the existing full_name column for all pre-existing rows
UPDATE customer
SET first_name = split_part(full_name, ' ', 1),
    last_name  = NULLIF(substring(full_name FROM position(' ' IN full_name) + 1), '');

-- now that data is backfilled, make first_name required going forward
ALTER TABLE customer ALTER COLUMN first_name SET NOT NULL;

-- keep full_name for now (don't drop yet) — see V5 for the safe drop after a
-- deploy cycle confirms nothing still reads it
