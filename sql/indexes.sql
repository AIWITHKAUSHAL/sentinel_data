CREATE INDEX IF NOT EXISTS transactions_customer_time ON "sentinel_demo".transactions(customer_id,transaction_time);
CREATE INDEX IF NOT EXISTS transactions_split_time ON "sentinel_demo".transactions(split,transaction_time);
CREATE INDEX IF NOT EXISTS labels_available ON "sentinel_demo".labels(label_available_at);
CREATE INDEX IF NOT EXISTS documents_transaction ON "sentinel_demo".documents(transaction_id);
CREATE INDEX IF NOT EXISTS documents_cpt_split ON "sentinel_demo".documents(split,cpt_eligible);
CREATE INDEX IF NOT EXISTS chunks_document ON "sentinel_demo".document_chunks(document_id);
CREATE INDEX IF NOT EXISTS chunks_search ON "sentinel_demo".document_chunks USING gin(to_tsvector('english',content));
CREATE INDEX IF NOT EXISTS audit_decision ON "sentinel_demo".decision_audit(decision,scored_at);
