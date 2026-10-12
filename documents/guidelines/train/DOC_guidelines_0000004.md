# Supabase synthetic environment guide

SYNTHETIC TRAINING MATERIAL. Fictional data for Project SENTINEL exercises. Not an official circular, legal guidance, human-reviewed evidence or production model output.

Load into a dedicated PostgreSQL schema using COPY over an encrypted direct or session-pooler connection. Dataset tables have RLS enabled and no anonymous or authenticated policy. Use private Storage buckets and service-side credentials. Keep a separate evaluation bucket for holdout artifacts. A private Supabase bucket does not implement the AWS Object Lock requirement in the production design. The hosted dataset is a teaching environment; the production architecture remains a separate client decision.
