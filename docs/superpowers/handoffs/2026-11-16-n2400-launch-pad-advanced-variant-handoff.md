# Handoff N2400 — LaunchPad advanced variant verification

## What this slice did

Verification-only (the N2357 precedent): the advanced
launch-pad def rows are verified against the live driver — no
driver change. Verified: power 8f, size 4, launchTime 1800f
(sense 900/1800 = 0.5), oil row 0.15/tick, hitbox 32.0 vs 24.0.
3 files, +503/−0, commit `062a920e8` on
`slice/N2400-launch-pad-advanced-variant-verification`.

## Key facts for the next agent

- **⚠️ DISCREPANCY (reported, NOT fixed):** `liquidCapacity
  40f` (Blocks.java:6805) flows nowhere in the port — the catalog
  has no such key for either launch-pad def (31 other blocks HAVE
  it), and the driver never reads `liquidCapacity`. Follow-up
  slice: add `liquidCapacity` 40.0 to the catalog row
  `advanced-launch-pad` (+ check the plain def derives 10f per
  Block.init :1407-1419) and/or wire the cap into the liquid
  store.
- SSOT +0 (no ledger entry). DEFERRED #46 resolved.

## Godot debt (this slice)

- NEW proof `C07LaunchPadAdvancedVariantProof` (6 keys) — never
  run.
