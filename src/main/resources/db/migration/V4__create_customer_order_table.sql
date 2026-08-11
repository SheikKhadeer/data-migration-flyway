-- V4: new table with a foreign key to the existing customer table, plus an index
CREATE TABLE customer_order (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customer(id),
    total_amount NUMERIC(10, 2) NOT NULL,
    placed_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_customer_order_customer_id ON customer_order(customer_id);
