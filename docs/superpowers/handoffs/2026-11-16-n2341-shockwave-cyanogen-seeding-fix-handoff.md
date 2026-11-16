# Handoff N2341 — ShockwaveTower old-proof cyanogen seeding fix

## What this slice did

Seeded cyanogen 1.0 into the 4 old ShockwaveTower proof scenes gone stale
from the N2331 required liquid row (N2177/N2187/N2318/N2327). 4 files,
+116/−8, commit `bc00c12c` on
`slice/N2341-shockwave-cyanogen-seeding-fix`.

## Key facts for the next agent

- Pattern N2331 (NOT plain N2323): preload LiquidModule/PlacedBlock/
  ContentRegistry → resolve cyanogen_id → init liquids state →
  `source_set_state(store, cyanogen_id, 1.0)` before the live tick.
- Margins: N2177 80×, N2187 ~27×, N2318 40×/tower, N2327 40×
  (consumption/tick = 0.025 × eff).
- SSOT +0, DEFERRED −1 (#326 resolved — coordinator applied at merge, no
  register). No ledger entry (fix slice).
- Targeted 4 old modules Ran 16, identical before/after, 0 regression.

## Godot debt (this slice)

- NO new proof. The 4 proofs never ran before — NOT re-runs; the 4 STALE
  notes are removed from GOAL.md §5 in the advances-15 docs.
