-- V2: additive change — safe, backward compatible (existing rows just get NULL/default)
ALTER TABLE customer ADD COLUMN phone_number VARCHAR(20);
