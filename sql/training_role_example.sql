-- Optional: run as an administrator. This creates a NOLOGIN group, no password.
-- Grant membership only to a dedicated non-owner, non-BYPASSRLS training login.
-- Do not use postgres/service_role for training: those principals can read holdout.
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='sentinel_training') THEN CREATE ROLE sentinel_training NOLOGIN; END IF; END $$;
GRANT USAGE ON SCHEMA sentinel_demo TO sentinel_training;
GRANT SELECT ON sentinel_demo.v_train_features, sentinel_demo.v_train_documents,
 sentinel_demo.v_train_gold, sentinel_demo.v_train_preferences TO sentinel_training;
-- Owner-backed filtered views deliberately expose only training rows.
-- Validation access belongs to a separate calibration principal, holdout to evaluation.
