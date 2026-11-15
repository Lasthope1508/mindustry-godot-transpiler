# Report N2300 — BeamDrill N2195 proof fix (FIX slice)

**Slice:** N2300 — BeamDrill N2195 proof fix (FIX slice, N2196/N2290 precedent).
**Wave:** advances-9.
**Commit:** `0ae8a739` on `slice/N2300-beam-drill-n2195-proof-fix` (base `9ca87a72`).
**Files:** 1, +52/−6 (proof file only).

## Source

The `C07BeamDrillUpdateTileProof` (N2195) went STALE when N2256 landed the hydrogen
booster row: the live tick asserted multiplier 1.75 / time 0.875 at power_status 0.5,
but with NO hydrogen in the frame the booster row folds optionalEfficiency to 0, so
the real values are multiplier 1.0 / time 0.5. Flagged by worker-N2289, verified by
the coordinator 03:07 16/11.

## Implementation

Fix in `godot-mindustry/tools/runtime_proofs/C07BeamDrillUpdateTileProof.gd`:
- Live tick (:92): multiplier 1.75 → **1.0**, time 0.875 → **0.5** (no hydrogen).
  Comments :69-71 rewritten to state the N2256 fold.
- **Added a hydrogen-seeded case** (new key
  `live_tick_with_hydrogen_pins_boost_values`): a second plasma-bore (cell 22,20),
  store hydrogen 10.0 (full → booster row 1.0, capped by power min 0.5 →
  optionalEfficiency 0.5), pinning multiplier 1.75 / time 0.875 (+ optional_efficiency
  0.5, efficiency 0.5, warmup 1/60). Seeding mirrors the N2256 proof
  (`source_liquid_catalog_state` → `source_set_state` on sprite liquids meta).
- **Stamped `facing_amount = 1` for both drills — required, not in the brief:** a
  newly bound frame defaults `facing_amount = 0` → the N2202 gate (`facingAmount > 0`,
  BeamDrill.java:271) closes → `update_consumption_efficiency_state` zeroes efficiency
  and optionalEfficiency. Without the stamp the live tick reads efficiency 0 / warmup
  0 / time 0 — all four assertions wrong, even the fixed 1.0/0.5 values. Precedent:
  N2256 proof comment ("seed one facing wall or the gate closes").

**The brief was WRONG about :55/:60 (worker-verified, N2290 precedent):** those two
keys call the pure advance directly with EXPLICIT optional_efficiency (0.5/1.0), and
1.75/2.5 + 0.875/1.75 are correct pure math (`lerp(1, 2.5, 0.5) = 1.75`); the N2256
handoff confirms "The N2195 advance is untouched". Changing them would make the proof
assert WRONG values on Godot. The N2289 flag only ever said the LIVE proof was stale.
Keeping the two pure keys preserves the booster-math coverage.

The register (`register_c07_beam_drill_update_tile.py`) does NOT quote the stale
values, so it was not touched by the worker — but its docstring line 18 still claimed
"with no optional rows modeled yet". The coordinator fixed that one line at
integration (commit `c36b0563`, docstring-only, 0 SSOT impact): the hydrogen row is
live since N2256, so the no-hydrogen fold is 0.

**No new pure, no new ledger entry, no new proof test, no new test module — SSOT
+0/+0/+0/+0** (totals stayed 11888/1743/1677/3146). The test file needed no change.

## Commits

- Slice: `0ae8a739` (pushed, server [new branch]; ls-remote verified by the
  coordinator 03:35 after proxy resets blocked the worker's 4 attempts 03:30–03:34).
- Integration cherry-pick: `2a3b8a59`. Integration fix: `c36b0563` (register docstring).

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 26/26, row-state) +
proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Full gate (wave advances-9 integration, PID 13482, 03:38–03:59): Ran 6286 tests in 1229.839s, FAILED (failures=248, skipped=5), 0 errors — 248/248 Godot-absent `AssertionError: unexpectedly None` (242 inherited + 6 new proof tests N2295/N2296/N2297/N2298/N2299/N2301; N2300 adds no test).

## SSOT / DEFERRED

SSOT +0/+0/+0/+0 confirmed (before = after = 11888/1743/1677/3146). DEFERRED
unchanged (proof fix, not a feature; no entry resolved, no entry added).

## Godot debt

Debt is a RE-RUN of `C07BeamDrillUpdateTileProof` (N2195, now 7 keys: the 6 original
+ `live_tick_with_hydrogen_pins_boost_values`) — the Godot agent must run the UPDATED
scene (live tick 1.0/0.5 + hydrogen-seeded case 1.75/0.875). Third re-run alongside
N2196 and N2280. See GOAL.md §5.
