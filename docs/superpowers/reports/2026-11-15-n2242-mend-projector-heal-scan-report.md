# N2242 MendProjector Heal Scan — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 5 — wave advances-5, integration branch `integration/wave-advances-5-n2242-n2248`, base `00f5feb3`).

## Source

- MendBuild.updateTile() heal branch (MendProjector.java:106-122): realRange = range + phaseHeat * phaseRangeBoost (:107); charge reset (:108); indexer scan (:112); heal formula `other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency)` (:113); mendSound (:119-121).
- **Scope corrections (all verified by grep): the brief's 12f/12f/50f are CLASS defaults only — the defs override them**: mender range 40f / healPercent 4f / phaseBoost 4f / phaseRangeBoost 20f (Blocks.java:1923-1927), mend-projector range 85f / healPercent 11f / phaseBoost 15f (Blocks.java:1936-1939); phaseRangeBoost is NOT overridden on mend-projector, so the class 50f applies there. **`any` is a FIELD** (`private boolean any = false;`, MendProjector.java:35), not a local. Predicate halves: damaged() (HealthComp.java:47-49) + isHealSuppressed() (BuildingComp.java:487-489).
- Defs mender (reload 200f) + mend-projector (reload 250f, class 250f :26; useTime 400f :31; mendSoundVolume 0.5f :33).

## Implementation

- `SourceMendProjectorBuildState.gd`:
  - Pure `source_mend_projector_heal_scan_state(frame, ...)` → 4 result symbols: real_range, heal_amounts, any, scanned. Takes all five per-def values (reload / range / healPercent / phaseBoost / phaseRangeBoost) as explicit params.
  - The N2193 advance **mutates and returns the frame itself** (not an advance dict) and resets charge to 0 inside the branch — the driver captures `charge_before` before the N2193 advance and the pure scan recomputes the crossing (`charge_before + heat_after * time_delta * time_scale >= reload && can_heal`); the N2193 function is untouched. Frame key `last_heal_scan`.
  - The port has no indexer, so the scan takes its candidate list explicit (each candidate: max_health, damaged, heal_suppressed). Fx/sound/recentlyHealed defer.

## Commits

- Slice `b0bc1971` (worker-N2242, branch `slice/N2242-mend-projector-heal-scan`, 5 files +1306/−1; đã push 19:48, remote tip b0bc1971).
- Integration cherry-pick `ac09e99f` (clean); SSOT gộp `9296c64f` (wave advances-5): 11706/1698/1620/3031 (slice riêng +4/+1/+1/+2 → 11646/1692/1614/3019).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 33/33, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Siblings N2193/N2156: 3/4 PASS, proof Godot-absent — không regression.
- Targeted wave (7 module): Ran 28, 21 PASS + 7 proof Godot-absent. Neighbours 8 module: Ran 32, 24 PASS + 8 proof Godot-absent, 0 error.
- Full gate wave advances-5: Ran 6082 in 1118.145s, failures=197, skipped=5, 0 errors — 197/197 Godot-absent (190 inherited + 7 new proof tests N2242–N2248).

## SSOT / DEFERRED

- SSOT slice riêng +4/+1/+1/+2 → 11646/1692/1614/3019; audit 1336, legacy 0. **Defense shard CHANGED** (`defense_slices` + `defense_api_contracts`).
- DEFERRED 286 (283 − 1 resolved: heal scan + sound entry + 4 new: heal effect rows, mendSound rows, recentlyHealed rows, heal scan range query).
- DEFERRED gộp sau wave advances-5: 294 entries (283 − 11 resolved + 22 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07MendProjectorHealScanProof` — 6 keys: `real_range_folds_phase_heat`, `heal_amount_formula`, `damaged_only_predicate`, `heal_suppressed_excluded`, `no_scan_below_reload`, `live_tick_scans_when_charged`.
