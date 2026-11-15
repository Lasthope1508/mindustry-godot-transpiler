# Handoff — N2191 RepairTower shouldConsume gate

Date: 2026-11-15. Batch: N2191 (single slice). Status: **DONE + PUSHED (16:5x +07 tick) — targeted 4/4, proof 5/5 keys matches:true, neighbours 44/44, full gate attempt 2 Ran 5857, failures=141, skipped=5, 0 errors (all Godot-absent). Slice commit `23f5a99`, docs `2a5bca1`, GOAL `126a359`, origin/main == HEAD == `126a359`.**

## GREEN (this run, 16:2x +07 tick — BLOCKED, see below)

- **Implementation:** pure function `source_repair_tower_should_consume_state(frame)` added to `godot-mindustry/src/game/SourceRepairTowerBuildState.gd` (dict-return, `targets_count` null → `{"should_consume": enabled}`, present → `{"should_consume": int(observed) > 0 and enabled}`) + exactly 1 driver line replaced in `source_repair_tower_tick_buildings_state` before `update_consumption_setup_state` (+ comment). `git diff --check` clean; diff 10 insertions + 1 deletion in that one file. No other gameplay touched.
- **Register script FIX (RED-script bug, not a test fix):** the RED-written register script crashed on launch — `ast.literal_eval` on the N2190 script's DEFERRED raised `ValueError: malformed node (ast.Call)`, because N2190's DEFERRED is a computed `list(_N2176_DEFERRED) + [...]` expression, NOT a plain list literal as the N2191 script's comment claimed. Fixed in `register_c07_repair_tower_should_consume.py` only: DEFERRED is now carried by `from register_c07_repair_tower_target_refresh import DEFERRED as _N2190_DEFERRED` (runtime value verbatim, never retyped) + a NOTE for the next slice (N2191's DEFERRED is likewise computed — carry by import, not ast.literal_eval). Register then ran clean, exit 0.
- **SSOT verified from disk after register: 11395/1641/1562/2915, audit 1335** — exactly the handoff expectation (+1/+1/+1/+2). Only the 4 canonical SSOT JSONs modified (276 insertions, 0 deletions); no shard change. Ledger N2191 row present, godot_owner correct, deferred_exprs 158 entries.
- **Targeted (Godot 4.6.2 on PATH, port 7777 FREE): Ran 4 in 15.757s, FAILED (failures=1)** — log `tools/mindustry_godot_transpiler/n2191-green.log`. Passing: registration, state, proof. Failing: `test_all_c07_repair_tower_should_consume_input_evidence_is_exact`, single subtest expr `consumePower(1f);`.
- **Root cause of the 1 failure (verified, NOT an implementation bug):** the expr IS verbatim in upstream — `consumePower(1f);` at Blocks.java:6582 (unit-repair-tower block, re-read this run) — but the RED test's `slice_sources` set lists only RepairTower.java / ConsumePower.java / BuildingComp.java / UnitAssembler.java / Block.java and OMITS `core/src/mindustry/content/Blocks.java`, so the exact-expr check can never find it. The N2190 test's `slice_sources` DOES include Blocks.java (test_c07_repair_tower_target_refresh.py:100) — the N2191 test dropped it when the source set was copied. The obvious fix is adding `'core/src/mindustry/content/Blocks.java'` to that set (test-harness only, no game code, no SSOT change); per the GREEN task instruction ("không tự sửa test để cho xanh") the worker STOPPED here and did not apply it.
- **Godot proof GREEN (inside the targeted run):** `C07RepairTowerShouldConsumeProof.json` — 5/5 slice keys true (`gate_blocks_without_targets`, `gate_passes_with_targets`, `gate_blocks_when_disabled`, `gate_absent_preserves_power_fold`, `gate_passes_with_targets_no_power`), `matches: true`, 0 ERROR. Proof .json untracked, never staged.
- **Main-thread resolution (16:3x +07):** the fix was applied by the main thread after independent verification from disk/log (Blocks.java:6582 re-read verbatim; N2190 test line 100 confirms Blocks.java belongs in the source set; SSOT 11395/1641/1562/2915 + audit 1335 re-read from disk; proof .json re-read: matches:true, 5/5 keys). One line added to `tests/test_c07_repair_tower_should_consume.py` — `'core/src/mindustry/content/Blocks.java'` in `slice_sources` (test-harness only, no game code, no SSOT change). Targeted re-run: **Ran 4 in 15.701s, OK** (port 7777 FREE), log `n2191-green.log` (overwritten with the passing run).
- **Neighbours (main thread, 16:3x +07):** family N2190 + N2176 modules **Ran 8 in 27.700s, OK**; wiring 9 modules **Ran 32 in 121.644s, OK** (log `n2191-wiring.log`, port 7777 FREE at start). GREEN total: targeted 4 + family 8 + wiring 32 = **44/44 OK**. No port-7777 flakes this run.
- **Full gate (main thread, launched ~16:22 +07):** `setsid nohup python3 -m unittest discover -s tests > full-suite-n2191-gate.log`, PID 11054, SID 11054 (own session), no Godot on PATH, javalang 0.13.0 checked first. Expect Ran ~5857, failures ~141, skipped 5, 0 errors (all Godot-absent asserts). Do NOT run any Godot proof scene while the gate runs (port-7777 rule).
- **NOT done:** gate verification (main thread, after the gate finishes ~16:38–16:40) → report/spec/GOAL → commit + push. Windows Godot proof stays debt in GOAL.md §5.

## RED (this run, 16:00 +07 tick)

- **Test module** `tools/mindustry_godot_transpiler/tests/test_c07_repair_tower_should_consume.py` (new) + **register script** `tools/mindustry_godot_transpiler/register_c07_repair_tower_should_consume.py` (new) + **proof scene** `godot-mindustry/tools/runtime_proofs/C07RepairTowerShouldConsumeProof.gd` (+ `.tscn`, new) written, following the N2188 should-consume pattern with the N2190 repair-tower placement.
- **Targeted RED run:** `python3 -m unittest tests.test_c07_repair_tower_should_consume` (Godot 4.6.2 on PATH, port 7777 FREE at run start): **Ran 4 in 10.933s, FAILED (failures=2, errors=2)** — registration `KeyError: 'N2191'` (no ledger entry yet), input-evidence error (same cause), state test FAIL (`static func source_repair_tower_should_consume_state` not found in SourceRepairTowerBuildState.gd), proof test FAIL (Godot parse error: `Static function "source_repair_tower_should_consume_state()" not found in base "SourceRepairTowerBuildState"`, proof .tscn fails to load). All four failures are the missing implementation, exactly the RED expectation. No proof .json written (scene never parsed); port 7777 free again after the run.
- **Slice files for the later commit (NOT staged yet):**
  `test_c07_repair_tower_should_consume.py` + `register_c07_repair_tower_should_consume.py` (new),
  `C07RepairTowerShouldConsumeProof.gd` + `.tscn` (new),
  this handoff (new). GREEN will add: `SourceRepairTowerBuildState.gd` (M),
  `source_api_contracts.json` + `source_slice_ledger.json` +
  `source_state_schema.json` + `source_symbol_registry.json` (M).
  Never stage: `*.gd.uid`, proof `.json`, run logs, old gate logs.

## Scope (verified against upstream Java + the port this run)

- **N2191 is the RepairTower shouldConsume gate, and nothing else.** One family
  (RepairTower: unit-repair-tower only), one pure function
  (`source_repair_tower_should_consume_state`) + one driver line in the
  EXISTING `godot-mindustry/src/game/SourceRepairTowerBuildState.gd`, one
  proof scene. It closes the exact observable gap N2176 left open with a
  documented limit: with no targets Java forces efficiency to 0 through the
  gate, while the port folds power-only and reports efficiency 1.0.
- **Why this item, why now:** it is the first remaining C07 deferred item in
  the N2188 table order whose prerequisite just landed: N2190 stamps
  `targets_count` on refresh expiry (the refresh block is the ONLY writer of
  `targets`, RepairTower.java:59-66), so the gate slice can now read a live
  count. The N2190 handoff "Next" lists it first. The gate is a single
  boolean expression over one frame key (`targets_count`) plus `enabled`;
  it needs no per-def values, no second subsystem input, and its driver
  file is dedicated.
- **Why not the other deferred items** (all verified in the N2188 handoff
  table, still true this run — main 6cfda2e, N2190 DONE + PUSHED):
  | Candidate | Why not N2191 |
  |---|---|
  | ShockwaveTower shouldConsume (`reloadCounter < reload`) | Needs the updateTile charge advance first (ShockwaveTower.java:73) plus per-def reload. Bigger: the charge advance first. |
  | BuildTurret shouldConsume | Needs a plans count plus suppression state — two subsystem inputs, and the port tracks no live build-plan state. Bigger. |
  | ShieldWall broken() coupling | No shouldConsume override to wire (default `return enabled;`); the deferred item is the broken()/damage coupling — a different, bigger slice. |
  | RepairTurret coolant (repair-turret only) | Optional consumer, needs liquids state on the turret frame — the second pass, own slice. |
  | MassDriver / LaunchPad rows | Whole updateTile advances — much bigger, own slices. |
  | Units.nearby live query (`nearby_damaged_units` stamping) | Own slice; N2191 reads the count the refresh stamps, it does not produce the query. The gate activates only after a refresh expiry stamps a count; until then the absent-key default preserves N2176 behavior. |
- **SSOT baseline re-verified from the generated JSONs this run** (main
  6cfda2e, N2190 DONE + PUSHED): symbols **11394** + slices **1640** +
  contracts **1561** + schemas **2913**; audit `totalSourceFunctions` 1335.
  Matches the N2190 handoff exactly. Expected after N2191 by the N2188
  rule (one symbol per result-dict key): **11395/1641/1562/2915** — the
  pure function returns a 1-key dict (`should_consume`); **verify at
  the GREEN register run, do not trust the estimate**. **No shard change
  expected:** no shard selects `/world/blocks/units/` (unit_building_slices
  selects UnitFactory.java exactly) — the N2183 campaign precedent; verify
  at the GREEN register run.
- **Environment (checked this run):** port 7777 FREE at RED run start (no
  Godot running); javalang 0.13.0 importable (no reinstall needed — VM
  restart #12 was ~15:11, uptime 48 min at the 16:00 check, javalang
  survived it); Godot binary at `~/workspace/godot-bin/godot`
  (4.6.2-stable) but NOT on PATH in the worker shell — the GREEN proof
  run must export `PATH="$HOME/workspace/godot-bin:$PATH"` first (the
  N2177 lesson). Worktree clean except pre-existing untracked `*.gd.uid`
  noise + old gate/run logs (never stage).

## Java source evidence (all verified verbatim this run — grep 2026-11-15 ~16:0x)

- `public class RepairTower extends Block{` (RepairTower.java:18)
- `public class RepairTowerBuild extends Building implements Ranged{` (RepairTower.java:46)
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
- `public boolean shouldConsume(){` (BuildingComp.java:755, the default)
- `return enabled;` (BuildingComp.java:756)
- `boolean update = shouldConsume() && productionValid();` (BuildingComp.java:1960)
- `if(!update){` (BuildingComp.java:1992)
- `efficiency = optionalEfficiency = 0f;` (BuildingComp.java:1993)
- `potentialEfficiency = efficiency;` (BuildingComp.java:1989, assigned BEFORE the `if(!update){` zeroing — so potentialEfficiency is the pre-gate min efficiency (power.status fold) and stays 1.0 with full power even when shouldConsume is false (no targets); the tower therefore keeps refreshing with no targets — the N2190 finding, still true)
- `public void updateConsumption(){` (BuildingComp.java:1943)
- `return efficiency * delta();` (BuildingComp.java:1928, edelta)
- `return build.power.status;` (ConsumePower.java:39)
- `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;` (UnitAssembler.java:469, the null fold)
- `hasConsumers = consumers.length > 0;` (Block.java:1449)
- `consumePower(1f);` (Blocks.java:6582 — STATIC draw, a plain ConsumePower, NOT the RepairTurret-style conditional `consumePowerCond`; no ConsumePowerCondition line enters this slice)
- Port mirror verified: `SourceBuildingEfficiencyState.update_consumption_state` zeroes efficiency when should_consume is false (the N2188 verification, `update_consumption_initial_state` — `efficiency := potential_efficiency if should_consume_state else 0.0`); the N2176 driver still runs `var should_consume: bool = bool(frame.get("enabled", true))` (SourceRepairTowerBuildState.gd, the line N2191 GREEN replaces).

## Design (decided in scoping, to confirm at GREEN)

- New pure function `source_repair_tower_should_consume_state(frame)` in
  the EXISTING `godot-mindustry/src/game/SourceRepairTowerBuildState.gd`
  (dict-return style, mirroring
  `source_repair_turret_should_consume_state`), returning
  `{"should_consume": bool}`:
  `var enabled: bool = bool(frame.get("enabled", true))`,
  `var observed: Variant = frame.get("targets_count", null)`,
  absent → `return {"should_consume": enabled}`,
  present → `return {"should_consume": int(observed) > 0 and enabled}`.
- **Frame key: `targets_count` (int).** Stamped by the N2190 refresh on
  expiry when a `nearby_damaged_units` observation exists; the live-units
  query slice owns stamping `nearby_damaged_units`. No new frame meta key,
  no SOURCE_CONSUMER_FRAME_META_KEYS change.
- **Driver change — one line + comment** in
  `source_repair_tower_tick_buildings_state`: replace
  `var should_consume: bool = bool(frame.get("enabled", true))` with
  `var should_consume: bool = bool(source_repair_tower_should_consume_state(frame).get("should_consume", true))`,
  BEFORE `update_consumption_setup_state` — the Java order
  (updateConsumption :2274 reads shouldConsume() at :1960), reading the
  `targets_count` the PREVIOUS tick's refresh stamped (Java: the targets
  list persists between refreshes; the gate reads the current list). The
  setup / power row / `update_consumption_state` /
  `apply_update_consumption_state` / refresh calls are unchanged. The
  refresh runs AFTER the consumption (N2190 placement) and cannot stamp
  a count on a 1/60s tick (6.0s interval), so a proof-stamped count
  survives the driver call.
- **Proof scene (written at RED):** new
  `C07RepairTowerShouldConsumeProof.gd` (+ `.tscn`, no `.json` tracked),
  following the N2188 proof shape with the N2190 placement
  (unit-repair-tower, cell (28, 21), driver called directly, not
  simulate_factory). 5 keys:
  1. `gate_blocks_without_targets` — targets_count=0, power_status=0.5 → efficiency 0 (the gate overrides the power fold).
  2. `gate_passes_with_targets` — targets_count=2, power_status=0.5 → efficiency 0.5 (the power fold applies).
  3. `gate_blocks_when_disabled` — pure gate {targets_count: 2, enabled: false} → false + machinery efficiency 0 (driver skips the consumption block when disabled, so this key runs the pure gate + machinery directly, the N2188 pattern).
  4. `gate_absent_preserves_power_fold` — NO targets_count key, power_status=0.5 → efficiency 0.5 (pins the RED absent-default decision).
  5. `gate_passes_with_targets_no_power` — targets_count=1, power_status absent → efficiency 1.0 (null fold, the assembler convention).

## RED decisions (frame keys, proof keys, exact vs deferred)

- **Absent `targets_count` → `should_consume = enabled` (preserve the
  N2176 power-only behavior).** Rationale (the N2188 `has_target`
  precedent): null means "no observation yet", not "no targets" — no
  placed-building frame carries a live targets count until the
  live-units query slice stamps `nearby_damaged_units` and a refresh
  expiry stamps `targets_count`; defaulting absent to false would zero
  efficiency for every live repair tower, a live regression against
  N2176 GREEN, forbidden by the user boundary (the game must stay
  exactly as it is; only the proof/test harness may change). The gate
  activates when a refresh expiry stamps `targets_count` from the
  observed count.
- **The gate reads `targets_count`, not `nearby_damaged_units`.** Java
  reads `targets.size` — the list the refresh writes; the port's
  equivalent of the list size is the stamped `targets_count`, not the
  raw observation channel. The refresh is the only writer of
  `targets_count`, so the gate can never read a fresher count than the
  last refresh — same as Java.
- **Exact exprs (this slice, all verified verbatim above):** the
  shouldConsume override (:89-90), the target list (:49), the refresh
  writes (:60-61, :64), the gate lines (BuildingComp.java:1960,
  1992-1993), potentialEfficiency assignment (:1989), the row read
  (ConsumePower.java:39), the null fold (UnitAssembler.java:469),
  hasConsumers (Block.java:1449), edelta (BuildingComp.java:1928),
  the static draw (Blocks.java:6582 `consumePower(1f);`). The register
  script's EXACT_EXPRS were verified verbatim against upstream at RED
  (18/18 present), DEFERRED carried from the N2190 script via AST
  (never retyped) plus the new N2191 Windows-debt entry.
- **Deferred (NOT N2191):** the `Units.nearby` live query +
  `nearby_damaged_units` stamping (own slice — the gate activates only
  after a refresh expiry stamps a count; until then the absent-key
  default preserves N2176 behavior); the heal loop + warmup lerp +
  totalProgress advance (RepairTower.java:67-86); the ozone liquid
  consumer (consumeLiquid ozone 3f/60f, Blocks.java:6583 — the N2174
  coolant precedent); suppression (`suppressable = true`,
  RepairTower.java:31, `checkSuppression()` zeroes warmup, :69-72);
  ShockwaveTower / BuildTurret gates, ShieldWall broken(), MassDriver /
  LaunchPad rows — each its own slice; Windows Godot proof — debt in
  GOAL.md §5.
- **Test module:** `test_c07_repair_tower_should_consume.py` +
  `register_c07_repair_tower_should_consume.py`, following the N2188
  registration pattern (test file asserts the ledger `godot_owner` +
  `source_symbols` for the new pure function; register script rebuilds
  SSOT). Neighbours to run at GREEN: the N2190 repair-tower module +
  the N2176 repair-tower module + the wiring 9 modules / 32 tests.

## NOT done (report/spec/GOAL + commit/push)

- Gate VERIFIED 16:45 +07 tick (from the log on disk): attempt 2 Ran 5857 in 975.562s, failures=141, skipped=5, 0 errors, 141 × `AssertionError: unexpectedly None`, 0 `ERROR:` lines, footer present, log 96,329 bytes. Gate is clean except Godot — exactly the N2190 baseline (Ran 5853, failures 140, skipped 5) + 4 new tests / +1 failure from the new proof test. Remaining: report (`docs/superpowers/reports/2026-11-15-c07-repair-tower-should-consume.md`, written this tick) + spec (Done/ledger 1640 → 1641 + N2191 row, done this tick) + GOAL.md §5 → slice commit → docs commit → GOAL commit → push. Windows Godot proof stays debt in GOAL.md §5.
- **Next after N2191:** ShockwaveTower charge advance (the prerequisite
  for its shouldConsume gate), then BuildTurret shouldConsume,
  ShieldWall broken(), MassDriver / LaunchPad rows, RepairTurret
  coolant, the Units.nearby live query — each its own slice; or C08
  inventory (classify the 5,390 null-body functions) when asked.

## Gate attempt 2 (launched main thread ~16:24 +07)

- Gate attempt 1 (PID 11054) is DEAD — verified by main thread: no python/unittest process, log `full-suite-n2191-gate.log` stopped at 3645 bytes (3523 dots + 117 F + 0 E + 5 s, no footer) at ~3645/5857 tests, last write 16:23:09 +07. NO VM restart (uptime 1:12). The gate died when the tick's worker session ended at ~16:23 — the same worker-session death pattern as N2189 attempt 1. The worker's "launched from main thread" claim was wrong: a main-thread gate survives as its own session (cf. N2190 attempt 2, PID 2330, PPID 1).
- Gate attempt 2 (main thread, PID 11314, SID 11314, ~16:24): `which godot` → NOT on PATH (correct baseline); javalang OK; log truncated fresh, growing with dots + F's (309 bytes at launch check). Parent subshell PID 11311 stays alive. Expected: Ran ~5857, failures ~141, skipped 5, 0 errors.
- Neighbours verified by main thread: family N2176 + N2190 modules re-run ~16:24, both OK (8/8); wiring 32/32 OK (single-pattern run, `n2191-wiring.log`: Ran 32, OK); targeted 4/4 (green log). GREEN total 44/44.

## DONE this run (16:5x +07 tick)

- Full gate attempt 2 finished ~16:40 (see above) → report
  (`docs/superpowers/reports/2026-11-15-c07-repair-tower-should-consume.md`)
  → spec (Done/ledger 1640 → 1641 + N2191 row, in the docs commit — the
  N2190 miss is NOT repeated) → GOAL.md §5 (Windows proof stays debt) →
  slice commit `23f5a99` (9 files, +806/−1) → docs `2a5bca1` + GOAL
  `126a359` commits → pushed to origin main ~16:5x (origin/main == HEAD
  == `126a359`, verified after push; no new commits from anyone else —
  re-checked origin/main before push: still 6cfda2e). Final handoff
  Status commit records DONE + PUSHED with the main hash.
- **Next after N2191:** ShockwaveTower charge advance (the prerequisite
  for its shouldConsume gate), then BuildTurret shouldConsume,
  ShieldWall broken(), MassDriver / LaunchPad rows, RepairTurret
  coolant, the Units.nearby live query — each its own slice; or C08
  inventory (classify the 5,390 null-body functions) when asked.

## Gate attempt 2 FINISHED (verified 16:45 +07 tick)

- Gate attempt 2 (PID 11314, SID 11314, main thread, ~16:24): **Ran 5857
  tests in 975.562s, FAILED (failures=141, skipped=5)** — log
  `tools/mindustry_godot_transpiler/full-suite-n2191-gate.log` (96,329
  bytes, footer present). All 141 verified Godot-absent: **141 ×
  `AssertionError: unexpectedly None`**, 0 other AssertionError types,
  0 `ERROR:` lines, 141 `FAIL:` lines. The N2191 proof test is failure
  #141 (the expected +1: it needs Godot on PATH, and it passed 4/4 in
  the targeted run where Godot was on PATH). No VM restart during
  attempt 2 (uptime 1:33 at the 16:45 check). Gate is clean except
  Godot — exactly the N2190 baseline (Ran 5853, failures 140, skipped
  5) + 4 new tests / +1 failure from the new proof test. Slice is DONE
  per the repo process.
