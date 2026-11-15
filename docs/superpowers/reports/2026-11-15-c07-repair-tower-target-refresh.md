# Report — N2190: RepairTower target refresh (C07)

Date: 2026-11-15. Batch: N2190 (single slice). Status: **DONE (2026-11-15 ~15:4x +07 — Godot proof GREEN 7 keys matches:true, neighbours N2176 4/4 OK, wiring 32/32 OK, full gate Ran 5853, failures=140, skipped=5, 0 errors — all 140 verified Godot-absent asserts, baseline +1 failure from the new proof test). Slice commit `f10c459`.**

## What changed

The first remaining C07 deferred item in the N2188 table order, and the prerequisite the N2188 handoff named for the RepairTower shouldConsume gate (`targets.size > 0`): the refresh is the only writer of `targets`, so the gate slice cannot read a live count until this slice stamps one. One family (RepairTower: unit-repair-tower only), one pure function, one driver call, one proof scene — no gameplay change.

What N2190 adds (9 files, +921 lines):

- **Pure function** `source_repair_tower_refresh_targets_state(frame, delta)` in the EXISTING `godot-mindustry/src/game/SourceRepairTowerBuildState.gd`, with `SOURCE_REPAIR_TOWER_REFRESH_INTERVAL := 6.0` (RepairTower.java:19, `static final float refreshInterval = 6f;`) and the full Java verbatim block in its comment. Returns `{"refreshed": bool, "refresh": float, "targets_count": int-or-null, "has_targets_count": bool}`. Semantics exactly per the RED decisions: PE ≤ 0 → timer untouched, refreshed false; PE > 0 → `refresh += delta`, below 6.0 accumulates without refresh; at/above 6.0 resets to 0.0, refreshed true, stamps `nearby_damaged_units` as `targets_count` when an observation exists, otherwise refreshes the timer with no stamp.
- **Driver call** — one call + comment in `source_repair_tower_tick_buildings_state`, INSIDE the existing `if has_power_consumer and enabled and not cheating:` block, AFTER `apply_update_consumption_state` (the Java order, updateConsumption :2274 before updateTile :2277). Writes `frame["refresh"]` every call, `frame["targets_count"]` only when `has_targets_count` is true. `git diff --check` clean.
- **Proof scene** `C07RepairTowerTargetRefreshProof.gd` (+ `.tscn`, `.json` untracked per .gitignore:6), N2176 shape: 4 pure keys + 3 live keys.
- **Test module + register script** `test_c07_repair_tower_target_refresh.py` + `register_c07_repair_tower_target_refresh.py` (N2176 pattern). SSOT 11390/1639/1560/2911 → **11394/1640/1561/2913**, audit `totalSourceFunctions` 1335 — exactly the RED estimate (one symbol per result-dict key, 4-key dict). No shard change (no `source_modules/` file touched), as predicted.
- **Documented deviation (pinned in the proof):** Java inits `refresh = Mathf.random(refreshInterval)` — random in [0,6); the port takes the deterministic 0.0 start. No `randf` in the pure function (determinism; the C06DefenseProof lesson).
- **Correction to the RED handoff's live-key parenthetical** (verified at GREEN, not assumed): the RED text said "first tick does not advance (no potential_efficiency stamp yet — absent folds to 0.0)". With the driver call AFTER `apply_update_consumption_state` — the placement the RED test comment pins and the Java order demands — the first live tick DOES advance the timer by one delta, because the same-tick consumption stamp already exists when the refresh reads it. The proof therefore pins the true property instead: `live_first_tick_no_advance` asserts a freshly bound tower frame carries no accumulated refresh (absent → 0.0) and no stamped count before its first driver tick. No gameplay change: the driver placement is unchanged from the RED design.

## RED

Tests written first per the slice process; the handoff's RED decisions section records the frame keys (`refresh`, `targets_count`, `nearby_damaged_units`, `potential_efficiency`), proof keys, and exact-vs-deferred calls confirmed at RED in the 14:45 tick. No RED log file survives on disk (no `n2190-red.log`), so no RED failure counts are cited here — the GREEN evidence below is the verified record.

## GREEN

- **Targeted:** `tests.test_c07_repair_tower_target_refresh` **Ran 4 OK in 16.298s** (log `tools/mindustry_godot_transpiler/n2190-green.log`, port 7777 FREE, Godot 4.6.2 via `PATH="$HOME/workspace/godot-bin:$PATH"`).
- **Godot proof (headless, Linux, Godot 4.6.2): exit 0, 0 ERROR lines, JSON 10 assignments, `matches: true`, 0 false keys** — 7 semantic keys (4 pure + 3 live) + `registry_valid` + `one_headquarter_per_ssot` + `matches`, all true. Verified from the JSON on disk by the 15:45 tick.
- **Neighbours:** N2176 repair-tower module Ran 4 OK in 14.810s (main-thread re-run ~14:57: Ran 4 OK in 13.787s, port FREE). **Wiring 9 modules / 32 tests: 32/32 OK** in ~125s, no failures, no port-7777 flakes (log `tools/mindustry_godot_transpiler/n2190-wiring.log`).
- **Full gate attempt 1 (main thread, PID 15012, ~14:57): DIED ~15:11 on VM restart #12** — log stopped at 5,536 bytes (dots + F, no footer) at ~5536/5853 tests. No work lost (GREEN files + SSOT survived in ~/workspace). javalang 0.13.0 still imports after this restart (unlike restarts #1–#10, which wiped it) — no reinstall needed this time.
- **Full gate attempt 2 (main thread, PID 2330, ~15:17): FINISHED ~15:33** (log `tools/mindustry_godot_transpiler/full-suite-n2190-gate.log`, 95,660 bytes, footer present): **Ran 5853 tests in 991.372s, FAILED (failures=140, skipped=5)** — no errors field, 0 `ERROR:` lines. All 140 verified Godot-absent (grep on the log): **140 × `AssertionError: unexpectedly None`** (the N2175 lesson — count by the error message, not the exact-no-message-arg awk), 0 other AssertionError types, 140 `FAIL:` lines. The N2190 proof test is failure #140 (the expected +1: it needs Godot on PATH, and it passed 4/4 in the targeted run where Godot was on PATH). No VM restart during attempt 2 (uptime 34 min at the 15:45 check). The gate is clean except Godot — exactly the N2189 baseline (Ran 5849, failures 139, skipped 5) + 4 new tests / +1 failure from the new proof test.

## Commits

- Slice: `f10c459` — C07: N2190 RepairTower target refresh (pure function + driver call; proof 7 keys), 9 files, +921.
- Docs: (report + handoff — hash named in the follow-up commit, N2189 pattern).
- GOAL: (GOAL.md §5 — hash named in the follow-up commit, N2189 pattern).
- Pushed 2026-11-15 ~15:5x +07 to the fork (Lasthope1508). See the handoff Commits section for the hashes.

## Deferred (NOT this slice)

- RepairTower shouldConsume gate (`targets.size > 0` — the follow-up slice; needs the live-units query slice to stamp `nearby_damaged_units` first, or proceeds with the absent-key "no observation" default per the N2188 precedent — the RED run decides).
- The `Units.nearby` live query + `nearby_damaged_units` stamping (own slice); the heal loop + warmup lerp + totalProgress advance (RepairTower.java:67-86); the ozone liquid consumer (consumeLiquid ozone 3f/60f, Blocks.java:6583 — the N2174 coolant precedent); suppression (`suppressable = true`, RepairTower.java:31).
- The remaining C07 deferred items per the N2188 handoff table — ShockwaveTower shouldConsume (`reloadCounter < reload`, needs the updateTile charge advance), BuildTurret shouldConsume (plans count + suppression state), ShieldWall broken()/damage coupling, MassDriver / LaunchPad rows, RepairTurret coolant — each its own slice; or C08 inventory (classify the 5,390 null-body functions) when asked.
- Windows Godot proof — debt in GOAL.md §5, same as N2182–N2189.
