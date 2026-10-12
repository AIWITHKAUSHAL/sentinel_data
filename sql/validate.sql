-- Each violation count must be zero. Counts refer to all synthetic records.
SELECT 'money_mismatch' AS check_name, count(*) AS violations FROM "sentinel_demo".transactions WHERE amount_paise <> transaction_amount*100
UNION ALL SELECT 'label_delay',count(*) FROM "sentinel_demo".transactions t JOIN "sentinel_demo".labels l USING(transaction_id) WHERE l.label_available_at<>t.transaction_time+interval '60 days'
UNION ALL SELECT 'feature_timestamp',count(*) FROM "sentinel_demo".transactions t JOIN "sentinel_demo".features f USING(transaction_id) WHERE f.feature_as_of<>t.transaction_time OR f.mcc_encoding_as_of>t.transaction_time
UNION ALL SELECT 'account_creation',count(*) FROM "sentinel_demo".transactions t JOIN "sentinel_demo".customers c USING(customer_id) WHERE t.transaction_time<c.created_at
UNION ALL SELECT 'outcome_timing',count(*) FROM "sentinel_demo".transactions t JOIN "sentinel_demo".payment_outcomes o USING(transaction_id) WHERE o.outcome_time<=t.transaction_time
UNION ALL SELECT 'cpt_leakage',count(*) FROM "sentinel_demo".documents WHERE cpt_eligible AND (split<>'train' OR published_at>='2025-11-01T00:00:00+05:30')
UNION ALL SELECT 'document_before_label',count(*) FROM "sentinel_demo".documents d JOIN "sentinel_demo".labels l USING(transaction_id) WHERE d.published_at<l.label_available_at
UNION ALL SELECT 'preference_leakage',count(*) FROM "sentinel_demo".preference_pairs p JOIN "sentinel_demo".transactions t USING(transaction_id) WHERE p.split<>'train' OR t.split<>'train'
UNION ALL SELECT 'unknown_as_new',count(*) FROM "sentinel_demo".features WHERE (missing_device AND is_new_device IS NOT NULL) OR (missing_customer_location AND is_new_city IS NOT NULL)
UNION ALL SELECT 'validation_encoder_updated',count(*) FROM "sentinel_demo".features f JOIN "sentinel_demo".transactions t USING(transaction_id) WHERE t.split IN ('validation','holdout') AND f.mcc_encoding_as_of<>'2025-11-01T00:00:00+05:30';
