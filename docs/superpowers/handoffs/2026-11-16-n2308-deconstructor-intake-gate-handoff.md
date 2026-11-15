# Handoff N2308 — Deconstructor intake full-gate wiring

## What this slice did

Wired the Deconstructor intake through the N2297 acceptPayload verdict: the tick
builds a descriptor from the incoming dict and evaluates the pure; the push
applies only when it accepts. Missing `block_size` → reject; non-dict push →
reject; rejected push still consumed. 6 files, +875/−19, commit `2726c503` on
`slice/N2308-deconstructor-intake-gate`.

## Key facts for the next agent

- The incoming dict carries `requirements` as an ARRAY (N2233 contract); the
  pure reads `requirements_length` (int) — the intake derives the length.
  Only `block_size` is a new incoming-dict contract key.
- The pure's `payload_empty` / `deconstructing_empty` terms replace the old
  frame-null check outright. The offer verdict still governs
  `frame["accepts_payload"]` — the intake never overwrites it.
- The handle pure's `block_size` param at the call site is the DECONSTRUCTOR's
  own size (5/3), NOT the payload's.
- **The N2291 test's pushes live in the PROOF file**, not the test module — the
  worker updated the N2291 proof fixture (+`block_size: 2`), load-bearing.
  → N2291 proof is a RE-RUN.
- Brief self-contradiction: "+0/+0/+0/+0" vs "register a ledger entry" — the
  entry wins (slices +1). Coordinator kept the entry.
- SSOT +0/+1/+0/+0 (shared ownership of the N2297 pure's 5 symbols). DEFERRED
  324 (−1+0).

## Godot debt (this slice)

- NEW proof `C07PayloadDeconstructorIntakeGateProof` (6 keys) — never run.
- RE-RUN of proof N2291 (`C07PayloadDeconstructorDeconstructingFillProof`).
