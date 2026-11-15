# Handoff — N2190 RepairTower target refresh

Date: 2026-11-15. Batch: N2190 (single slice). Status: **DONE + PUSHED (slice `f10c459`, main `1779511`) — full gate attempt 2 finished 15:33 +07 (Ran 5853, failures=140, skipped=5, 0 errors, all 140 verified Godot-absent asserts). GREEN evidence: pure function `source_repair_tower_refresh_targets_state` + driver call + proof scene `C07RepairTowerTargetRefreshProof.gd` (+ `.tscn`) written; register run clean, SSOT 11394/1640/1561/2913 (audit 1335) — exactly the RED estimate, no shard change; targeted Ran 4 OK in 16.3s (Godot proof 7/7 keys true, `matches: true`, 0 ERROR, returncode 0); neighbours N2176 4/4 OK; wiring 9 modules / 32 tests OK. Windows proof: debt in GOAL.md §5, not run on Windows Godot.**

## GREEN (this run, 14:45 +07 tick)

- **Pure function** `source_repair_tower_refresh_targets_state(frame, delta)` in
  the EXISTING `godot-mindustry/src/game/SourceRepairTowerBuildState.gd`,
  with `SOURCE_REPAIR_TOWER_REFRESH_INTERVAL := 6.0` and the full Java
  verbatim block in its comment. Semantics exactly per the RED decisions:
  PE ≤ 0 → timer untouched, refreshed false; PE > 0 → `refresh += delta`,
  below 6.0 accumulates without refresh; at/above 6.0 resets to 0.0,
  refreshed true, stamps `nearby_damaged_units` as `targets_count` when an
  observation exists (`has_targets_count` true), otherwise refreshes the
  timer with no stamp.
- **Driver call** one call + comment in
  `source_repair_tower_tick_buildings_state`, INSIDE the existing
  `if has_power_consumer and enabled and not cheating:` block, AFTER
  `apply_update_consumption_state` (the Java order, updateConsumption :2274
  before updateTile :2277, as the RED test comment pins). Writes
  `frame["refresh"]` every call, `frame["targets_count"]` only when
  `has_targets_count` is true. `git diff --check` clean.
- **Proof scene** `C07RepairTowerTargetRefreshProof.gd` (+ `.tscn`, `.json`
  untracked per .gitignore:6), N2176 shape: 4 pure keys + 3 live keys.
  Run headless on Linux here: all 7 keys true, `matches: true`, 0 ERROR.
  Proof JSON at
  `godot-mindustry/tools/runtime_proofs/C07RepairTowerTargetRefreshProof.json`.
- **Correction to the RED handoff's live-key parenthetical** (verified this
  run, not assumed): the RED text said "first tick does not advance (no
  potential_efficiency stamp yet — absent folds to 0.0)". With the driver
  call AFTER `apply_update_consumption_state` — the placement the RED test
  comment pins and the Java order demands — the first live tick DOES
  advance the timer by one delta, because the same-tick consumption stamp
  already exists when the refresh reads it. The proof therefore pins the
  true property instead: `live_first_tick_no_advance` asserts a freshly
  bound tower frame carries no accumulated refresh (absent → 0.0) and no
  stamped count before its first driver tick — the deterministic 0.0 start
  (Java inits `refresh` randomly) — and the absent-PE no-advance stays
  covered by the pure key `refresh_gate_closed_at_zero_efficiency`. No
  gameplay change: the driver placement is unchanged from the RED design.
- **Register run:** `register_c07_repair_tower_target_refresh.py` exit 0.
  SSOT 11394/1640/1561/2913, audit `totalSourceFunctions` 1335 — exactly
  the RED estimate (one symbol per result-dict key). No shard change (no
  `source_modules/` file touched), as predicted.
- **Targeted:** `tests.test_c07_repair_tower_target_refresh` Ran 4 OK in
  16.298s (port 7777 FREE at run start; Godot 4.6.2 via
  `PATH="$HOME/workspace/godot-bin:$PATH"`). Log `n2190-green.log`.
- **Neighbours:** N2176 module Ran 4 OK in 14.810s. **Wiring:** 9 modules /
  32 tests OK in ~125s, no failures (no port-7777 flakes this run). Log
  `n2190-wiring.log`.
- **Slice files for the later commit (NOT staged yet):**
  `SourceRepairTowerBuildState.gd` (M),
  `C07RepairTowerTargetRefreshProof.gd` + `.tscn` (new),
  `test_c07_repair_tower_target_refresh.py` + `register_c07_repair_tower_target_refresh.py` (new),
  `source_api_contracts.json` + `source_slice_ledger.json` +
  `source_state_schema.json` + `source_symbol_registry.json` (M),
  this handoff (new). Never stage: `*.gd.uid`, proof `.json`, run logs.

## Scope (verified against upstream Java + the port this run)

- **N2190 is the RepairTower target-refresh slice, and nothing else.** One family
  (RepairTower: unit-repair-tower only), one pure function
  (`source_repair_tower_refresh_targets_state`) in the EXISTING
  `godot-mindustry/src/game/SourceRepairTowerBuildState.gd`, one driver call
  in the existing `source_repair_tower_tick_buildings_state`. It is the
  prerequisite the N2188 handoff table named for RepairTower shouldConsume
  (`targets.size > 0`): the refresh is the only writer of `targets`, so the
  gate slice cannot read a live count until this slice stamps one.
- **Why this item, why now:** it is the first remaining C07 deferred item in
  the N2188 table order (RepairTower shouldConsume needs the target-refresh
  slice first) and the N2189 handoff "Next" lists it first. The timer advance
  is a single boolean gate over one frame key (`potential_efficiency`) plus
  `delta`; it needs no per-def values (range/healAmount are irrelevant to the
  timer), no second subsystem input, and its driver file is dedicated.
- **Why not the other deferred items** (all verified in the N2188 handoff table,
  still true this run — no new commits since N2189, main 4ada17c):
  | Candidate | Why not N2190 |
  |---|---|
  | RepairTower shouldConsume (`targets.size > 0`) | Needs the targets count this slice stamps. It is the follow-up slice (N2191 or later), not this one. |
  | ShockwaveTower shouldConsume (`reloadCounter < reload`) | Needs the updateTile charge advance first (ShockwaveTower.java:73) plus per-def reload. Bigger: the charge advance first. |
  | BuildTurret shouldConsume | Needs a plans count plus suppression state — two subsystem inputs, and the port tracks no live build-plan state. Bigger. |
  | ShieldWall broken() coupling | No shouldConsume override to wire (default `return enabled;`); the deferred item is the broken()/damage coupling — a different, bigger slice. |
  | RepairTurret coolant (repair-turret only) | Optional consumer, needs liquids state on the turret frame — the second pass, own slice. |
  | MassDriver / LaunchPad rows | Whole updateTile advances — much bigger, own slices. |
- **SSOT baseline re-verified from the generated JSONs this run** (main 4ada17c,
  N2189 DONE + PUSHED): symbols **11390** + slices **1639** + contracts
  **1560** + schemas **2911**; audit `totalSourceFunctions` 1335. Matches the
  N2189 handoff exactly (N2189 was proof-harness-only, no SSOT change). The
  N2188 estimate correction holds: the N2188 report records 11390, not the
  11391 estimated in its handoff (pure function returns a 1-key dict).
  Expected after N2190 by the N2188 rule (one symbol per result-dict key):
  **11394/1640/1561/2913** — the pure function returns a 4-key dict
  (`refreshed`, `refresh`, `targets_count`, `has_targets_count`); **verify at
  the GREEN register run, do not trust the estimate**. **No shard change
  expected:** no shard selects `/world/blocks/units/` (unit_building_slices
  selects UnitFactory.java exactly) — the N2183 campaign precedent; verify at
  the GREEN register run.
- **Environment (checked this run):** port 7777 FREE (no Godot running — the
  one `pgrep` hit was a `gh pr list` shell whose cwd contains "godot", not a
  Godot process); javalang 0.13.0 importable (no reinstall needed — no VM
  restart since the N2189 tick); Godot binary exists at
  `~/workspace/godot-bin/godot` (4.6.2-stable) but is NOT on PATH in the worker
  shell — the GREEN proof run must export
  `PATH="$HOME/workspace/godot-bin:$PATH"` first (the N2177 lesson). Worktree
  clean except pre-existing untracked `*.gd.uid` noise (never stage). This
  handoff is the only new file, untracked, NOT staged, NOT committed.

## Java source evidence (all verified verbatim this run — read 2026-11-15 ~14:1x)

- `public class RepairTower extends Block{` (RepairTower.java:18)
- `static final float refreshInterval = 6f;` (RepairTower.java:19)
- `public float range = 80f;` (RepairTower.java:21)
- `public float healAmount = 1f;` (RepairTower.java:24)
- `public class RepairTowerBuild extends Building implements Ranged{` (RepairTower.java:46)
- `public float refresh = Mathf.random(refreshInterval);` (RepairTower.java:47)
- `public Seq<Unit> targets = new Seq<>();` (RepairTower.java:49)
- `public void updateTile(){` (RepairTower.java:57)
- `if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){` (RepairTower.java:59)
- `targets.clear();` (RepairTower.java:60)
- `refresh = 0f;` (RepairTower.java:61)
- `Units.nearby(team, x, y, range, u -> {` (RepairTower.java:62)
- `if(u.damaged()){` (RepairTower.java:63)
- `targets.add(u);` (RepairTower.java:64)
- `public boolean shouldConsume(){` (RepairTower.java:89)
- `return targets.size > 0;` (RepairTower.java:90)
- `unit-repair-tower`: `size = 2;` (Blocks.java:6578), `range = 100f;` (Blocks.java:6579), `healAmount = 1.5f;` (Blocks.java:6580), `consumePower(1f);` (Blocks.java:6582), `consumeLiquid(Liquids.ozone, 3f / 60f);` (Blocks.java:6583)
- `public void update(){` (BuildingComp.java:2263) — `updateConsumption();` (BuildingComp.java:2274) runs BEFORE `updateTile();` (BuildingComp.java:2277), so the refresh block reads the potentialEfficiency stamped by THIS tick's updateConsumption.
- `public void updateConsumption(){` (BuildingComp.java:1943): no-consumers-or-cheating branch `potentialEfficiency = enabled && productionValid() ? 1f : 0f;` (BuildingComp.java:1946); disabled branch all 0 (BuildingComp.java:1955); `boolean update = shouldConsume() && productionValid();` (BuildingComp.java:1960); first pass min over non-optional consumers (BuildingComp.java:1969-1976); `potentialEfficiency = efficiency;` (BuildingComp.java:1989) is assigned BEFORE the `if(!update){` zeroing (BuildingComp.java:1992-1993) — so potentialEfficiency is the pre-gate min efficiency (power.status fold) and stays 1.0 with full power even when shouldConsume is false (no targets). The tower therefore keeps refreshing with no targets; it only stops when power is gone or it is disabled.
- `public boolean canConsume(){` (BuildingComp.java:1917) with `return potentialEfficiency > 0;` (BuildingComp.java:1918).
- `Units.nearby(team, x, y, radius, cons)` (Units.java:445): rectangle intersect then `unit.within(x, y, radius + unit.hitSize/2f)` (Units.java:449-451) — the effective radius is range + hitSize/2 per unit. The query itself is NOT N2190 (see RED decisions).
- Port mirror verified: `SourceBuildingEfficiencyState.update_consumption_efficiency_state` sets `potential_efficiency := efficiency` (the min) before the `if not update` zeroing (SourceBuildingEfficiencyState.gd:129-137), and `apply_update_consumption_state` stamps `potential_efficiency` onto the frame (SourceBuildingEfficiencyState.gd:178). The N2176 driver therefore stamps a fresh `potential_efficiency` every tick its consumption block runs.
- Port unit stores checked this run: there is NO live friendly-unit enumeration wired into any driver — `PortGame.gd` exposes no unit-listing accessor; `SourceTeamsRuntimeState` teams carry `"units": []` arrays but nothing appends friendly units to them; `SourceEnemyUnitRuntimeState` holds spawned enemy units as `{"sprite", "type", "health"}` dicts (wrong team for a repair tower, which heals its OWN team). The `Units.nearby` query is therefore its own later slice, not N2190.

## Design (decided in scoping, to confirm at RED)

- New pure function `source_repair_tower_refresh_targets_state(frame, delta)` in
  the EXISTING `godot-mindustry/src/game/SourceRepairTowerBuildState.gd`
  (dict-return style, mirroring
  `source_repair_tower_power_status_row_state`), returning
  `{"refreshed": bool, "refresh": float, "targets_count": int-or-null,
  "has_targets_count": bool}`.
- **Frame keys:** `refresh` (float, seconds accumulated); `targets_count`
  (int, stamped on refresh expiry when an observation exists);
  `nearby_damaged_units` (int, the observation channel — stamped by the
  future live-units query slice, NOT this one); `potential_efficiency`
  (already stamped by the N2176 driver via `apply_update_consumption_state`).
  No `refresh` / `targets_count` / `nearby_damaged_units` key exists anywhere
  in `godot-mindustry/src/game/*.gd` today (verified by grep this run) — no
  collision. `potential_efficiency` is the existing shared key.
- **Constant:** `SOURCE_REPAIR_TOWER_REFRESH_INTERVAL := 6.0`
  (RepairTower.java:19, `static final float refreshInterval = 6f;`).
- **Driver change — one call + comment** in
  `source_repair_tower_tick_buildings_state`, INSIDE the existing
  `if has_power_consumer and enabled and not cheating:` block, AFTER
  `apply_update_consumption_state` — the Java order (updateConsumption :2274
  before updateTile :2277). The driver writes `frame["refresh"]` from the
  result every call, and `frame["targets_count"]` only when
  `has_targets_count` is true. `delta` is the tick's `seconds` (Time.delta).
- **Proof scene (default, to confirm at RED):** new
  `C07RepairTowerTargetRefreshProof.gd` (+ `.tscn`, no `.json` tracked),
  following the N2176 proof shape: pure-function keys called directly on the
  state file + a live placed unit-repair-tower ticked through the driver.
  Pure keys: gate-closed (potential_efficiency 0) leaves refresh untouched;
  advance below the interval accumulates without refresh; cumulative delta
  crossing 6.0 refreshes (refresh 0.0, refreshed true) and stamps the supplied
  count; expiry with no `nearby_damaged_units` observation refreshes the timer
  but leaves targets_count unstamped. Live keys: refresh accumulates across
  1/60s ticks at power 1.0; refresh does NOT advance at power_status 0.0
  (potential_efficiency 0); first tick does not advance (no
  potential_efficiency stamp yet — absent folds to 0.0).

## RED decisions (frame keys, proof keys, exact vs deferred)

- **Absent `refresh` → 0.0 (timer starts at 0; first refresh after exactly 6s
  of powered operation).** Java inits `refresh = Mathf.random(refreshInterval)`
  (:47) — random in [0,6); the port takes the deterministic 0.0 start, a
  documented deviation pinned in the proof. No `randf` in the pure function
  (determinism; the C06DefenseProof lesson: seeded RNG only in proof scenes,
  never in game code).
- **Absent `potential_efficiency` → 0.0 (Java field default, BuildingComp.java:89
  `transient float potentialEfficiency;`).** No advance before the first
  consumption stamp. This also makes the first live tick a no-advance tick —
  pin it in the proof.
- **Absent `nearby_damaged_units` at expiry → refresh resets, targets_count is
  NOT stamped (no observation yet — the N2188 `has_target` precedent).** The
  live-units query slice (Units.nearby, team + range 100f + damaged filter,
  RepairTower.java:61-65, effective radius range + hitSize/2 per unit,
  Units.java:449-451) stamps `nearby_damaged_units` later; until then the
  follow-up shouldConsume gate must treat absent `targets_count` as "no
  observation" and preserve the N2176 power-only behavior — the gate slice
  decides, not this one. The pure function takes NO unit query and NO range:
  it consumes the count, it does not produce it.
- **Driver placement inside the consumption block (enabled + not cheating +
  has power consumer).** Consequence, documented limit: a disabled tower's
  refresh freezes (Java: potentialEfficiency 0 when disabled, BuildingComp.java:1955
  — same observable); a cheating team's tower does not advance refresh until
  the consumption-block cheating coverage lands (Java: cheating branch sets
  potentialEfficiency 1.0 when enabled, BuildingComp.java:1946). Do NOT call
  refresh outside the block: the frame's `potential_efficiency` would be
  stale (last powered tick's 1.0) and a disabled tower would keep refreshing.
- **Deferred (NOT N2190):** the `Units.nearby` live query + `nearby_damaged_units`
  stamping (own slice); the shouldConsume gate (`targets.size > 0` — the
  follow-up slice once `targets_count` is stamped live); the heal loop +
  warmup lerp + totalProgress advance (RepairTower.java:67-86); the ozone
  liquid consumer (consumeLiquid ozone 3f/60f, Blocks.java:6583 — the N2174
  coolant precedent); suppression (`suppressable = true`, RepairTower.java:31,
  `checkSuppression()` zeroes warmup, RepairTower.java:69-72).
- **Test module (to confirm at RED):** `test_c07_repair_tower_target_refresh.py`
  + `register_c07_repair_tower_target_refresh.py`, following the N2176
  registration pattern (test file asserts the ledger `godot_owner` +
  `source_symbols` for the new pure function; register script rebuilds SSOT).
  Neighbours to run at GREEN: the N2176 repair-tower module + the wiring
  9 modules / 32 tests.

## DONE this run (15:45 +07 tick)

- Full gate attempt 2 finished ~15:33 (see above) → report
  (`docs/superpowers/reports/2026-11-15-c07-repair-tower-target-refresh.md`)
  → GOAL.md §5 (Windows proof stays debt) → slice commit `f10c459` (9 files,
  +921) → docs `377984d` + GOAL `d4bdfc8` + hash-naming `1779511` commits →
  pushed to origin main ~15:5x (origin/main == HEAD == `1779511`, verified
  after push; no new commits from anyone else — re-checked origin/main
  before push: still 4ada17c). Final handoff Status commit records DONE +
  PUSHED with the main hash.
- **Next after N2190:** RepairTower shouldConsume gate (reads `targets_count`;
  needs the live-units query slice to stamp `nearby_damaged_units` first, or
  proceeds with the absent-key "no observation" default per the N2188
  precedent — the RED run decides); then ShockwaveTower charge advance,
  BuildTurret shouldConsume, ShieldWall broken(), MassDriver / LaunchPad rows,
  RepairTurret coolant — each its own slice; or C08 inventory (classify the
  5,390 null-body functions) when asked.

## Gate (launched main thread ~14:57 +07)

- Full gate attempt 1 (main thread, PID 15012, SID 15012): `which godot` → NOT on PATH (correct baseline); log `full-suite-n2190-gate.log`, growing with dots + F's (307 bytes at launch check). Parent subshell PID 15009 stays alive. Expected: Ran ~5853, failures ~140 (139 + 1 new proof test), skipped 5, 0 errors.
- Neighbours verified by main thread: family N2176 module Ran 4 OK (13.787s, re-run ~14:57, port FREE) + new module 4/4 (targeted) + wiring 32/32 (9× OK from `n2190-wiring.log`). Neighbours final: targeted 4 + family 4 + wiring 32 = 40/40.
- Proof JSON: 10 keys total (7 semantic + registry_valid + one_headquarter_per_ssot + matches), matches:true, 0 false.

## Gate attempt 2 (launched main thread ~15:17 +07)

- Gate attempt 1 (PID 15012, main thread) DIED ~15:11 on **VM restart #12** (uptime 5 min at the 15:16 check): log `full-suite-n2190-gate.log` stopped at 5536 bytes (dots + F, no footer) at ~5536/5853 tests. No work lost (GREEN files + SSOT survived in ~/workspace).
- javalang 0.13.0 still imports after this restart (unlike restarts #1–#10, which wiped it) — verified by main thread; no reinstall needed this time. Still check before every gate.
- Gate attempt 2 (main thread, PID 2330, SID 2330, ~15:17): `which godot` → NOT on PATH (correct baseline); log truncated fresh, growing with dots + F's (304 bytes at launch check). Parent subshell PID 2328 stays alive. Expected: Ran ~5853, failures ~140, skipped 5, 0 errors.
- **Gate attempt 2 FINISHED ~15:33 +07 (verified from the log on disk by the 15:45 tick): Ran 5853 tests in 991.372s, FAILED (failures=140, skipped=5)** — log `tools/mindustry_godot_transpiler/full-suite-n2190-gate.log` (95,660 bytes, footer present). All 140 verified Godot-absent: **140 × `AssertionError: unexpectedly None`**, 0 other AssertionError types, 0 `ERROR:` lines, 140 `FAIL:` lines. The N2190 proof test is failure #140 (the expected +1: it needs Godot on PATH, and it passed 4/4 in the targeted run where Godot was on PATH). No VM restart during attempt 2 (uptime 34 min at the 15:45 check = restart #12 at ~15:11). Gate is clean except Godot — exactly the N2189 baseline (Ran 5849, failures 139, skipped 5) + 4 new tests / +1 failure from the new proof test. Slice is DONE per the repo process.

## Spec fix-up (main thread, 15:5x +07)

- The docs commit `377984d` changed only the report + handoff — it did NOT update the design spec (AGENTS.md step 8). Verified by main thread: spec `| Done |` stayed 1639 and no N2190 row existed.
- Fix: spec `| Canonical slice ledger entries |` + `| Done |` 1639 → 1640, N2190 checklist row added after the N2188 row (pure function, driver placement, deterministic-0.0 deviation, GREEN + gate evidence, deferred items). `git diff --check` clean. Committed as the spec fix-up below.
