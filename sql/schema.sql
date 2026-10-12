CREATE SCHEMA IF NOT EXISTS "sentinel_demo";

REVOKE ALL ON SCHEMA "sentinel_demo" FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo"._dataset (singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton), dataset_id text NOT NULL, manifest_sha256 text NOT NULL, version text NOT NULL);

CREATE TABLE IF NOT EXISTS "sentinel_demo"._load_log (path text PRIMARY KEY, sha256 text NOT NULL, row_count bigint NOT NULL, loaded_at timestamptz NOT NULL DEFAULT now());

CREATE TABLE IF NOT EXISTS "sentinel_demo".customers (
  customer_id text PRIMARY KEY,
  created_at timestamptz NOT NULL,
  customer_age integer NOT NULL,
  home_city text NOT NULL,
  region text NOT NULL,
  is_synthetic boolean NOT NULL
);

ALTER TABLE "sentinel_demo".customers ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".customers FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".merchants (
  merchant_id text PRIMARY KEY,
  synthetic_name text NOT NULL,
  merchant_category text NOT NULL,
  merchant_location jsonb NOT NULL,
  is_synthetic boolean NOT NULL
);

ALTER TABLE "sentinel_demo".merchants ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".merchants FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".devices (
  device_id text PRIMARY KEY,
  device_kind text NOT NULL,
  is_synthetic boolean NOT NULL
);

ALTER TABLE "sentinel_demo".devices ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".devices FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".transactions (
  transaction_id text PRIMARY KEY,
  customer_id text NOT NULL,
  merchant_id text NOT NULL,
  device_id text,
  amount_paise bigint NOT NULL CHECK (amount_paise > 0),
  transaction_amount numeric(14,2) NOT NULL,
  payment_channel text NOT NULL,
  merchant_category text NOT NULL,
  transaction_time timestamptz NOT NULL,
  customer_age integer NOT NULL,
  customer_location jsonb,
  merchant_location jsonb NOT NULL,
  account_age integer NOT NULL,
  previous_transactions integer NOT NULL,
  average_transaction_value numeric(14,2),
  failed_transactions integer NOT NULL,
  split text NOT NULL,
  is_synthetic boolean NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES "sentinel_demo".customers (customer_id),
  FOREIGN KEY (merchant_id) REFERENCES "sentinel_demo".merchants (merchant_id),
  FOREIGN KEY (device_id) REFERENCES "sentinel_demo".devices (device_id),
  CHECK (amount_paise = transaction_amount * 100),
  CHECK (account_age >= 0),
  CHECK (customer_age BETWEEN 18 AND 120),
  CHECK (split IN ('warmup','train','validation','holdout'))
);

ALTER TABLE "sentinel_demo".transactions ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".transactions FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".payment_outcomes (
  transaction_id text PRIMARY KEY,
  outcome_time timestamptz NOT NULL,
  status text NOT NULL,
  failure_code text,
  is_synthetic boolean NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES "sentinel_demo".transactions (transaction_id)
);

ALTER TABLE "sentinel_demo".payment_outcomes ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".payment_outcomes FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".labels (
  transaction_id text PRIMARY KEY,
  fraud_label smallint NOT NULL CHECK (fraud_label IN (0,1)),
  label_source text NOT NULL,
  label_available_at timestamptz NOT NULL,
  split text NOT NULL,
  eligible_at_next_split_start boolean NOT NULL,
  is_synthetic boolean NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES "sentinel_demo".transactions (transaction_id)
);

ALTER TABLE "sentinel_demo".labels ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".labels FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".features (
  transaction_id text PRIMARY KEY,
  feature_as_of timestamptz NOT NULL,
  amount_to_avg_ratio double precision,
  is_new_device boolean,
  customer_merchant_distance_km double precision,
  is_new_city boolean,
  hour_of_day integer NOT NULL,
  is_night boolean NOT NULL,
  has_recent_failures boolean NOT NULL,
  is_new_account boolean NOT NULL,
  txn_count_last_1h integer NOT NULL,
  txn_amount_last_24h_paise bigint NOT NULL,
  distinct_customers_per_device_7d integer,
  combined_risk_flags integer NOT NULL,
  mcc_target_encoded_rate double precision NOT NULL,
  mcc_encoding_as_of timestamptz NOT NULL,
  mcc_encoding_count integer NOT NULL,
  missing_customer_location boolean NOT NULL,
  missing_device boolean NOT NULL,
  cold_start boolean NOT NULL,
  reason_codes jsonb NOT NULL,
  feature_version text NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES "sentinel_demo".transactions (transaction_id)
);

ALTER TABLE "sentinel_demo".features ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".features FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".legacy_cases (
  legacy_case_id text PRIMARY KEY,
  customer_id text NOT NULL,
  transaction_time timestamptz NOT NULL,
  closed_at timestamptz NOT NULL,
  amount_paise bigint NOT NULL,
  payment_channel text NOT NULL,
  fraud_label smallint NOT NULL,
  evidence jsonb NOT NULL,
  is_synthetic boolean NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES "sentinel_demo".customers (customer_id)
);

ALTER TABLE "sentinel_demo".legacy_cases ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".legacy_cases FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".documents (
  document_id text PRIMARY KEY,
  kind text NOT NULL,
  title text NOT NULL,
  transaction_id text,
  legacy_case_id text,
  split text NOT NULL,
  published_at timestamptz NOT NULL,
  content text NOT NULL,
  content_sha256 text NOT NULL,
  template_family text NOT NULL,
  cpt_eligible boolean NOT NULL,
  review_status text NOT NULL,
  storage_path text NOT NULL,
  record_in_shard integer NOT NULL,
  metadata jsonb NOT NULL,
  is_synthetic boolean NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES "sentinel_demo".transactions (transaction_id),
  FOREIGN KEY (legacy_case_id) REFERENCES "sentinel_demo".legacy_cases (legacy_case_id)
);

ALTER TABLE "sentinel_demo".documents ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".documents FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".document_chunks (
  chunk_id text PRIMARY KEY,
  document_id text NOT NULL,
  chunk_index integer NOT NULL,
  content text NOT NULL,
  word_count integer NOT NULL,
  split text NOT NULL,
  cpt_eligible boolean NOT NULL,
  is_synthetic boolean NOT NULL,
  FOREIGN KEY (document_id) REFERENCES "sentinel_demo".documents (document_id)
);

ALTER TABLE "sentinel_demo".document_chunks ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".document_chunks FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".gold_explanations (
  example_id text PRIMARY KEY,
  transaction_id text NOT NULL,
  split text NOT NULL,
  prompt text NOT NULL,
  target jsonb NOT NULL,
  fraud_label smallint NOT NULL,
  review_status text NOT NULL,
  is_synthetic boolean NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES "sentinel_demo".transactions (transaction_id)
);

ALTER TABLE "sentinel_demo".gold_explanations ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".gold_explanations FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".preference_pairs (
  pair_id text PRIMARY KEY,
  transaction_id text NOT NULL,
  split text NOT NULL,
  prompt text NOT NULL,
  chosen jsonb NOT NULL,
  rejected jsonb NOT NULL,
  rejection_reason text NOT NULL,
  review_status text NOT NULL,
  is_synthetic boolean NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES "sentinel_demo".transactions (transaction_id)
);

ALTER TABLE "sentinel_demo".preference_pairs ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".preference_pairs FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".decision_audit (
  transaction_id text PRIMARY KEY,
  scored_at timestamptz NOT NULL,
  fraud_probability numeric(7,6) NOT NULL,
  decision text NOT NULL,
  risk_level text NOT NULL,
  reason_codes jsonb NOT NULL,
  explanation text NOT NULL,
  decision_source text NOT NULL,
  model_version text NOT NULL,
  rules_version text NOT NULL,
  latency_ms integer NOT NULL,
  explanation_latency_ms integer NOT NULL,
  prompt_format text NOT NULL,
  prompt_hash text NOT NULL,
  request jsonb NOT NULL,
  feature_vector jsonb NOT NULL,
  split text NOT NULL,
  is_synthetic boolean NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES "sentinel_demo".transactions (transaction_id)
);

ALTER TABLE "sentinel_demo".decision_audit ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".decision_audit FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".threshold_sets (
  threshold_id text PRIMARY KEY,
  version integer NOT NULL,
  mcc_group text,
  medium_from numeric(4,3) NOT NULL,
  high_from numeric(4,3) NOT NULL,
  critical_from numeric(4,3) NOT NULL,
  status text NOT NULL,
  is_synthetic boolean NOT NULL
);

ALTER TABLE "sentinel_demo".threshold_sets ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".threshold_sets FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".hard_rules (
  rule_id text PRIMARY KEY,
  code text NOT NULL,
  expression jsonb NOT NULL,
  action text NOT NULL,
  priority integer NOT NULL,
  enabled boolean NOT NULL,
  is_synthetic boolean NOT NULL
);

ALTER TABLE "sentinel_demo".hard_rules ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".hard_rules FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".list_entries (
  entry_id text PRIMARY KEY,
  list_type text NOT NULL,
  entity_id text NOT NULL,
  effective_from timestamptz NOT NULL,
  reason text NOT NULL,
  is_synthetic boolean NOT NULL
);

ALTER TABLE "sentinel_demo".list_entries ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".list_entries FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".config_changes (
  change_id text PRIMARY KEY,
  entity text NOT NULL,
  entity_id text NOT NULL,
  before_value jsonb,
  after_value jsonb NOT NULL,
  changed_by text NOT NULL,
  changed_at timestamptz NOT NULL,
  reason text NOT NULL,
  is_synthetic boolean NOT NULL
);

ALTER TABLE "sentinel_demo".config_changes ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".config_changes FROM PUBLIC;

CREATE TABLE IF NOT EXISTS "sentinel_demo".reviewer_feedback (
  feedback_id text PRIMARY KEY,
  transaction_id text NOT NULL,
  reviewed_at timestamptz NOT NULL,
  verdict text NOT NULL,
  corrected_explanation text NOT NULL,
  reviewer_id text NOT NULL,
  is_synthetic boolean NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES "sentinel_demo".transactions (transaction_id)
);

ALTER TABLE "sentinel_demo".reviewer_feedback ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo".reviewer_feedback FROM PUBLIC;

ALTER TABLE "sentinel_demo"._dataset ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo"._dataset FROM PUBLIC;

ALTER TABLE "sentinel_demo"._load_log ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON "sentinel_demo"._load_log FROM PUBLIC;

CREATE OR REPLACE VIEW "sentinel_demo".v_train_features WITH (security_barrier=true) AS SELECT t.transaction_id,t.transaction_time,t.transaction_amount,t.merchant_category,t.customer_age,t.account_age,t.previous_transactions,t.average_transaction_value,t.failed_transactions,f.feature_as_of, f.amount_to_avg_ratio, f.is_new_device, f.customer_merchant_distance_km, f.is_new_city, f.hour_of_day, f.is_night, f.has_recent_failures, f.is_new_account, f.txn_count_last_1h, f.txn_amount_last_24h_paise, f.distinct_customers_per_device_7d, f.combined_risk_flags, f.mcc_target_encoded_rate, f.mcc_encoding_as_of, f.mcc_encoding_count, f.missing_customer_location, f.missing_device, f.cold_start, f.feature_version,l.fraud_label,l.label_available_at,l.eligible_at_next_split_start FROM "sentinel_demo".transactions t JOIN "sentinel_demo".features f USING(transaction_id) JOIN "sentinel_demo".labels l USING(transaction_id) WHERE t.split='train';

CREATE OR REPLACE VIEW "sentinel_demo".v_validation_features WITH (security_barrier=true) AS SELECT t.transaction_id,t.transaction_time,t.transaction_amount,t.merchant_category,t.customer_age,t.account_age,t.previous_transactions,t.average_transaction_value,t.failed_transactions,f.feature_as_of, f.amount_to_avg_ratio, f.is_new_device, f.customer_merchant_distance_km, f.is_new_city, f.hour_of_day, f.is_night, f.has_recent_failures, f.is_new_account, f.txn_count_last_1h, f.txn_amount_last_24h_paise, f.distinct_customers_per_device_7d, f.combined_risk_flags, f.mcc_target_encoded_rate, f.mcc_encoding_as_of, f.mcc_encoding_count, f.missing_customer_location, f.missing_device, f.cold_start, f.feature_version,l.fraud_label,l.label_available_at,l.eligible_at_next_split_start FROM "sentinel_demo".transactions t JOIN "sentinel_demo".features f USING(transaction_id) JOIN "sentinel_demo".labels l USING(transaction_id) WHERE t.split='validation';

CREATE OR REPLACE VIEW "sentinel_demo".v_holdout_features WITH (security_barrier=true) AS SELECT t.transaction_id,t.transaction_time,t.transaction_amount,t.merchant_category,t.customer_age,t.account_age,t.previous_transactions,t.average_transaction_value,t.failed_transactions,f.feature_as_of, f.amount_to_avg_ratio, f.is_new_device, f.customer_merchant_distance_km, f.is_new_city, f.hour_of_day, f.is_night, f.has_recent_failures, f.is_new_account, f.txn_count_last_1h, f.txn_amount_last_24h_paise, f.distinct_customers_per_device_7d, f.combined_risk_flags, f.mcc_target_encoded_rate, f.mcc_encoding_as_of, f.mcc_encoding_count, f.missing_customer_location, f.missing_device, f.cold_start, f.feature_version,l.fraud_label,l.label_available_at,l.eligible_at_next_split_start FROM "sentinel_demo".transactions t JOIN "sentinel_demo".features f USING(transaction_id) JOIN "sentinel_demo".labels l USING(transaction_id) WHERE t.split='holdout';

CREATE OR REPLACE VIEW "sentinel_demo".v_labeled_transactions WITH (security_barrier=true) AS SELECT t.*, l.fraud_label,l.label_available_at FROM "sentinel_demo".transactions t JOIN "sentinel_demo".labels l USING(transaction_id);

CREATE OR REPLACE VIEW "sentinel_demo".v_train_documents WITH (security_barrier=true) AS SELECT document_id,kind,content,published_at,content_sha256 FROM "sentinel_demo".documents WHERE split='train' AND cpt_eligible;

CREATE OR REPLACE VIEW "sentinel_demo".v_train_gold WITH (security_barrier=true) AS SELECT * FROM "sentinel_demo".gold_explanations WHERE split='train';

CREATE OR REPLACE VIEW "sentinel_demo".v_train_preferences WITH (security_barrier=true) AS SELECT * FROM "sentinel_demo".preference_pairs WHERE split='train';

DO $$ DECLARE r text; BEGIN FOREACH r IN ARRAY ARRAY['anon','authenticated'] LOOP IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname=r) THEN EXECUTE format('REVOKE ALL ON SCHEMA %I FROM %I','sentinel_demo',r); EXECUTE format('REVOKE ALL ON ALL TABLES IN SCHEMA %I FROM %I','sentinel_demo',r); END IF; END LOOP; IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname='service_role') THEN EXECUTE 'GRANT USAGE ON SCHEMA "sentinel_demo" TO service_role'; EXECUTE 'GRANT SELECT ON ALL TABLES IN SCHEMA "sentinel_demo" TO service_role'; END IF; END $$;
