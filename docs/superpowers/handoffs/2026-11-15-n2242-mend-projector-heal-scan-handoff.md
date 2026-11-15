# N2242 MendProjector Heal Scan — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-5, coordinator lượt 5).

## What this slice did

- MendProjector heal scan as a pure advance in `SourceMendProjectorBuildState.gd` (MendProjector.java:106-122): realRange fold, indexer scan predicate, heal formula, `any` flag, branch-taken flag.
- 4 result symbols: real_range, heal_amounts, any, scanned. The driver captures `charge_before` before the N2193 advance (N2193 resets charge to 0 inside its branch); frame key `last_heal_scan`.

## Key facts for the next agent

- **The brief's 12f/12f/50f are CLASS defaults only**: mender 40f/4f/4f/20f, mend-projector 85f/11f/15f (phaseRangeBoost NOT overridden there, so class 50f applies). The pure function takes all five per-def values as explicit params.
- **`any` is a FIELD** (MendProjector.java:35), not a local. Predicate: damaged() (HealthComp.java:47-49) + isHealSuppressed() (BuildingComp.java:487-489).
- **N2193's advance mutates and returns the frame itself** (not an advance dict) — the scan recomputes the crossing from charge_before; do NOT "fix" this into a dict return without updating both functions.
- Register: 33 exact exprs, 0 missing. DEFERRED: 286 (283 − 1 + 4 new: heal effect rows, mendSound rows, recentlyHealed rows, heal scan range query). **Defense shard CHANGED**.
- Slice commit `b0bc1971` (branch `slice/N2242-mend-projector-heal-scan`, đã push 19:48); integration cherry-pick `ac09e99f`; SSOT gộp `9296c64f` (11706/1698/1620/3031).

## Godot debt (this slice)

- `C07MendProjectorHealScanProof` — 6 keys (`real_range_folds_phase_heat`, `heal_amount_formula`, `damaged_only_predicate`, `heal_suppressed_excluded`, `no_scan_below_reload`, `live_tick_scans_when_charged`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
