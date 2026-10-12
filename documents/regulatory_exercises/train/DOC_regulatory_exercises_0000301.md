# Synthetic RBI topic exercise 0301 on device change

SYNTHETIC TRAINING MATERIAL. Fictional data for Project SENTINEL exercises. Not an official circular, legal guidance, human-reviewed evidence or production model output.

## Purpose
Teach evidence-based review of device change for a fictional gaming merchant. This exercise uses net_banking activity associated with Kochi; scenario variant 301. The exercise is part of a synthetic corpus, with no official status.

## Context
A payment arrives with incomplete history and an apparent contextual change. The reviewer must compare the current event with past observations. Compare the observed device with the payer's preceding 90 days of activity. Treat a missing fingerprint as unknown.

## Investigation procedure
First confirm the transaction reference and feature timestamp. Then list observed facts, identify unknown fields and compare alternative legitimate explanations. Inspect only the history available before authorisation. Record later dispute evidence separately. Escalate combinations of signals according to the active policy and record why an action was selected.

## Teaching policy
The project starts with probability cutoffs 0.30, 0.60 and 0.85. Below 0.60 the policy allows the payment; from 0.60 to below 0.85 it requests review; at or above 0.85 it blocks. A blocklisted device takes precedence over a customer allowlist. These are client-provided starting settings, not a regulatory standard.

## Reviewer checklist
Which facts are directly visible? Which are uncertain? Could travel, a shared device or a purchase cycle explain the pattern? Does the explanation include a fact absent from the input? Would the decision change under a small amount perturbation? Document the answers.

## Source status
Topic-discovery reference only: https://rbi.org.in/Scripts/PublicationsView.aspx?id=20339. No official circular text or regulatory obligation is reproduced or fabricated.
