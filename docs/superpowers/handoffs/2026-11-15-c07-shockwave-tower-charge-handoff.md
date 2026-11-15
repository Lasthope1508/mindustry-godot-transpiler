# Handoff — N2192 ShockwaveTower charge advance

Date: 2026-11-15. Batch: N2192 (single slice). Status: **DONE, gate
finished 17:45 +07 tick** — targeted 4/4 OK, neighbours 40/40 OK,
proof 9 keys matches:true, full gate Ran 5861, failures=142, skipped=5,
0 errors (all Godot-absent). Slice commit `b028951`, docs `8b609ad`,
GOAL `9193eb4`. Push follows in this tick.

## RED (this run, 17:00 +07 tick)

- **Test module** `tools/mindustry_godot_transpiler/tests/test_c07_shockwave_tower_charge.py` (new) + **register script** `tools/mindustry_godot_transpiler/register_c07_shockwave_tower_charge.py` (new) + **proof scene** `godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerChargeProof.gd` (+ `.tscn`, new) written, following the N2177 proof shape with the N2191 placement (shockwave-tower, cell (28, 21), driver called directly).
- **Targeted RED run:** `python3 -m unittest tests.test_c07_shockwave_tower_charge` (Godot 4.6.2 on PATH, port 7777 FREE at run start): **Ran 4 in 9.876s, FAILED (failures=2, errors=2)** — log `tools/mindustry_godot_transpiler/n2192-red.log`. All four failures are the missing implementation, exactly the RED expectation:
  1. Registration — ERROR `KeyError: 'N2192'` (no ledger entry yet).
  2. Input-evidence — ERROR `KeyError: 'N2192'` (same cause).
  3. State — FAIL `static func source_shockwave_tower_charge_state` not found in SourceShockwaveTowerBuildState.gd.
  4. Proof — FAIL Godot parse error: `Static function "source_shockwave_tower_charge_state()" not found in base "SourceShockwaveTowerBuildState"` (5 call sites, proof .tscn fails to load), `ERROR:` in output.
  No proof .json written (scene never parsed); port 7777 free again after the run. `git diff --check` clean.
- **Slice files for the later commit (NOT staged yet):**
  `test_c07_shockwave_tower_charge.py` + `register_c07_shockwave_tower_charge.py` (new),
  `C07ShockwaveTowerChargeProof.gd` + `.tscn` (new),
  this handoff (new). GREEN will add: `SourceShockwaveTowerBuildState.gd` (M),
  `source_api_contracts.json` + `source_slice_ledger.json` +
  `source_state_schema.json` + `source_symbol_registry.json` (M),
  and is expected to mirror N2192 into the defense shards (see below).
  Never stage: `*.gd.uid`, proof `.json`, run logs, old gate logs.

## Scope (verified against upstream Java + the port this run)

- **N2192 is the ShockwaveTower charge advance, and nothing else.** One
  family (ShockwaveTower: shockwave-tower only), one pure function
  (`source_shockwave_tower_charge_state(frame, delta)`) + one driver
  call in the EXISTING `godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd`, one proof scene. It closes the exact observable gap N2177 left open with a documented limit: with no live reload counter the tower could never charge and never fire.
- **Why this item, why now:** it is the first remaining C07 deferred item in the N2191 handoff "Next" order whose prerequisite just landed: N2177 stamps `potential_efficiency` / `efficiency` on the frame each tick (via `apply_update_consumption_state`), so the charge slice can now read a live gate and a live increment. The charge is the prerequisite for the shouldConsume gate (`return reloadCounter < reload;`, ShockwaveTower.java:121-122), which needs a live counter to read.
- **Why not the other deferred items** (all verified in the N2191 handoff table, still true this run — main 9e26791, N2191 DONE + PUSHED):
  | Candidate | Why not N2192 |
  |---|---|
  | ShockwaveTower shouldConsume (`reloadCounter < reload`) | Needs the charge advance first — this slice. Next after N2192. |
  | BuildTurret shouldConsume | Needs a plans count plus suppression state — two subsystem inputs, and the port tracks no live build-plan state. Bigger. |
  | ShieldWall broken() coupling | No shouldConsume override to wire (default `return enabled;`); the deferred item is the broken()/damage coupling — a different, bigger slice. |
  | RepairTurret coolant (repair-turret only) | Optional consumer, needs liquids state on the turret frame — the second pass, own slice. |
  | MassDriver / LaunchPad rows | Whole updateTile advances — much bigger, own slices. |
  | Units.nearby live query (`nearby_damaged_units` stamping) | Own slice; unrelated to the shockwave tower. |
- **SSOT baseline re-verified from the generated JSONs this run** (main
  9e26791, N2191 DONE + PUSHED): symbols **11395** + slices **1641** +
  contracts **1562** + schemas **2915**; audit `totalSourceFunctions` 1335.
  Matches the N2191 handoff exactly. Expected after N2192 by the N2188
  rule (one symbol per result-dict key): **11396/1642/1563/2917** — the
  pure function returns a 1-key dict (`reload_counter`); **verify at
  the GREEN register run, do not trust the estimate**.
- **Shard check (done this run):** YES, a shard selects ShockwaveTower.java — unlike N2191 (units path, no shard selects it). The `defense_slices` shard selects `java_source` containing `/world/blocks/defense/` (source_ssot_modules.json), and `defense_api_contracts` mirrors owners from it. Verified from disk: N2177 IS in both shards today (defense_slices 154 slices, defense_api_contracts 153 contracts), N2191 is in neither. **So the GREEN register run is expected to mirror N2192 into both defense shards** (the N2177 precedent) — the register script's shard-rebuild loop writes all registered JSONs including shards. Verify the shard diffs at GREEN.
- **Environment (checked this run):** port 7777 FREE at RED run start (no Godot running); javalang 0.13.0 importable (no reinstall needed); Godot binary at `~/workspace/godot-bin/godot` (4.6.2-stable, build 71f334935) but NOT on PATH in the worker shell — the RED proof run exported `PATH="$HOME/workspace/godot-bin:$PATH"` first (the N2177 lesson). Worktree clean except pre-existing untracked `*.gd.uid` noise + old gate/run logs (never stage).

## Java source evidence (all verified verbatim this run — grep 2026-11-15 ~17:0x)

- `public class ShockwaveTower extends Block{` (ShockwaveTower.java:22)
- `public int timerCheck = timers ++;` (ShockwaveTower.java:23)
- `public float range = 110f;` (ShockwaveTower.java:25)
- `public float reload = 60f * 1.5f;` (ShockwaveTower.java:26)
- `public float bulletDamage = 160;` (ShockwaveTower.java:27)
- `public float falloffCount = 20f;` (ShockwaveTower.java:28)
- `public float shake = 2f;` (ShockwaveTower.java:29)
- `public float checkInterval = 8f;` (ShockwaveTower.java:31)
- `public float cooldownMultiplier = 1f;` (ShockwaveTower.java:34)
- `update = true;` (ShockwaveTower.java:46)
- `solid = true;` (ShockwaveTower.java:47)
- `public class ShockwaveTowerBuild extends Building{` (ShockwaveTower.java:66)
- `public float reloadCounter = Mathf.random(reload);` (ShockwaveTower.java:67)
- `public float heat = 0f;` (ShockwaveTower.java:68)
- `public void updateTile(){` (ShockwaveTower.java:72)
- `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){` (ShockwaveTower.java:73)
- `heat = 1f;` (ShockwaveTower.java:82)
- `reloadCounter = 0f;` (ShockwaveTower.java:83)
- `float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);` (ShockwaveTower.java:87)
- `heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);` (ShockwaveTower.java:104)
- `if(sensor == LAccess.progress) return reloadCounter / reload;` (ShockwaveTower.java:110)
- `return heat;` (ShockwaveTower.java:117)
- `public boolean shouldConsume(){` (ShockwaveTower.java:121)
- `return reloadCounter < reload;` (ShockwaveTower.java:122)
- `public boolean canConsume(){` (BuildingComp.java:1917)
- `return potentialEfficiency > 0;` (BuildingComp.java:1918)
- `public float edelta(){` (BuildingComp.java:1927)
- `return efficiency * delta();` (BuildingComp.java:1928)
- `boolean update = shouldConsume() && productionValid();` (BuildingComp.java:1960)
- `potentialEfficiency = efficiency;` (BuildingComp.java:1989, assigned BEFORE the `if(!update){` zeroing — so potentialEfficiency is the pre-gate min efficiency (power.status fold))
- `if(!update){` (BuildingComp.java:1992)
- `efficiency = optionalEfficiency = 0f;` (BuildingComp.java:1993)
- `public boolean shouldConsume(){` (BuildingComp.java:755, the default)
- `return enabled;` (BuildingComp.java:756)
- `return build.power.status;` (ConsumePower.java:39)
- `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;` (UnitAssembler.java:469, the null fold)
- `hasConsumers = consumers.length > 0;` (Block.java:1449)
- `consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));` (Blocks.java:2041)
- `consumePower(100f / 60f);` (Blocks.java:2042)
- `range = 170f;` (Blocks.java:2043)
- `reload = 80f;` (Blocks.java:2044)
- `size = 3;` (Blocks.java:2040)
- Port mirror verified: `SourceBuildingEfficiencyState.apply_update_consumption_state` stamps `potential_efficiency` / `efficiency` / `optional_efficiency` / `should_consume_power` on the frame, so the charge gate reads `potential_efficiency` and the increment reads `efficiency * delta` from keys the N2177 machinery already stamps — no invented keys. The N2190 driver convention passes the tick's `seconds` as the pure function's `delta` (`source_repair_tower_refresh_targets_state(frame, seconds)`).
- Register script's EXACT_EXPRS verified verbatim against upstream at RED (40/40 present, 0 missing, checked by script this run); `slice_sources` includes Blocks.java (the N2191 lesson — the `consumePower(100f / 60f);` / `range = 170f;` / `reload = 80f;` exprs come from it).

## Design (decided in scoping, to confirm at GREEN)

- New pure function `source_shockwave_tower_charge_state(frame, delta)` in
  the EXISTING `godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd`
  (dict-return style), returning `{"reload_counter": float}`:
  `var reload_counter: float = float(frame.get("reload_counter", 0.0))`,
  `var potential_efficiency: float = float(frame.get("potential_efficiency", 0.0))`,
  `if potential_efficiency > 0.0: reload_counter += float(frame.get("efficiency", 0.0)) * delta`,
  `return {"reload_counter": reload_counter}`.
- **Frame key: `reload_counter` (float).** Stamped by the driver call on
  the frame each tick; the live charge is the only writer.
- **Driver change — one call + comment** in
  `source_shockwave_tower_tick_buildings_state`, AFTER
  `apply_update_consumption_state` (the Java order: updateConsumption
  runs BEFORE updateTile, so the charge reads THIS tick's freshly
  stamped `potential_efficiency` / `efficiency`): pass the tick's
  `seconds` as the delta (the N2190 driver convention) and stamp the
  frame key. The setup / power row / `update_consumption_state` /
  `apply_update_consumption_state` calls are unchanged.
- **Proof scene (written at RED):** new
  `C07ShockwaveTowerChargeProof.gd` (+ `.tscn`, no `.json` tracked),
  following the N2177 proof shape with the N2191 placement
  (shockwave-tower, cell (28, 21), driver called directly, not
  simulate_factory). 6 keys:
  1. `charge_advances_at_full_efficiency` — pure: counter 10.0, potential 1.0, efficiency 1.0, delta 1/60 → 10.0 + 1/60.
  2. `charge_frozen_without_power` — pure: counter 10.0, potential 0.0, efficiency 0.0 → stays 10.0.
  3. `charge_scales_with_partial_efficiency` — pure: counter 10.0, potential 0.5, efficiency 0.5, delta 1/60 → 10.0 + 0.5/60.
  4. `charge_accumulates_past_reload_without_fire` — pure: counter 79.0, potential 1.0, efficiency 1.0, delta 2.0 → 81.0, past the per-def reload 80f (no clamp, no reset).
  5. `charge_absent_counter_starts_zero` — pure: NO `reload_counter` key, potential 1.0, efficiency 1.0, delta 1/60 → 1/60 (pins the deterministic 0.0 init).
  6. `charge_driver_stamps_counter` — live tick: power_status 1.0, reload_counter 10.0, tick(game, 1/60) → frame reload_counter ≈ 10.0 + 1/60.

## RED decisions (frame keys, proof keys, exact vs deferred)

- **Absent `reload_counter` → start at deterministic 0.0.** Rationale (the
  N2190 RepairTower refresh precedent): Java inits `reloadCounter =
  Mathf.random(reload);` (ShockwaveTower.java:67), but the port takes
  the deterministic 0.0 start — no `randf` in game code (the
  C06DefenseProof lesson: seeded RNG only in proof scenes, never in
  game code). A random init would make the proof non-deterministic.
- **NO clamp at reload, NO reset without fire.** Java keeps accumulating
  past reload until a successful fire resets the counter to 0
  (ShockwaveTower.java:83, `reloadCounter = 0f;`, inside the
  `targets.size > 0` branch at :81); the charge function itself never
  clamps or resets. Pinned by proof key 4 (81.0 past the 80f reload).
- **The charge reads the stamped `potential_efficiency` / `efficiency`,
  not a recomputed edelta.** The N2177 machinery already stamps both
  keys on the frame via `apply_update_consumption_state`; the pure
  function reads them with 0.0 defaults (no advance before the first
  consumption stamp — the N2190 `potential_efficiency` precedent).
- **Exact exprs (this slice, all verified verbatim above):** the fire
  gate line (:73), the counter/heat inits (:67-68), the class fields
  (:23-34, :46-47), the fire reset + heat set (:82-83), the wave damage
  (:87), the heat decay (:104), sense (:110), warmup (:117), the
  shouldConsume gate (:121-122), edelta (:1927-1928), canConsume
  (:1917-1918), potentialEfficiency assignment (:1989), the update gate
  (:1960, :1992-1993), the shouldConsume default (:755-756), the row
  read (ConsumePower.java:39), the null fold (UnitAssembler.java:469),
  hasConsumers (Block.java:1449), the per-def block (Blocks.java
  :2040-2044: size 3, cyanogen, consumePower 100f/60f, range 170f,
  reload 80f). The register script's EXACT_EXPRS were verified
  verbatim against upstream at RED (40/40 present).
- **Deferred (NOT N2192):** the fire gate — bullet scan, wave damage,
  heat=1, reloadCounter=0 reset (ShockwaveTower.java:74-103); heat decay
  (:104 `heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);`); sense(LAccess.progress) = reloadCounter/reload (:110); warmup() returns heat (:117); the shouldConsume gate itself (:121-122); cyanogen liquid consumer; draw modeling (:126-139). Windows Godot proof — debt in GOAL.md §5.
- **DEFERRED chain gap, recorded at RED:** the register script carries
  DEFERRED by import from `register_c07_repair_tower_should_consume`
  (runtime value verbatim, never retyped — the N2191 lesson, with the
  same NOTE left for the next slice). The inherited 158-entry list
  contains NO ShockwaveTower entries: N2177's register script added
  them as a literal, but the chain forked between N2185 and N2190 and
  the later slices carried the pre-N2177 list forward, so the N2177
  ShockwaveTower deferred items live only in the N2177 ledger row, not
  in this carried list. The N2192 register script adds 2 new entries
  (Windows Godot proof debt + a re-pin of the still-deferred fire
  gate / shouldConsume gate / heat / sense / warmup / liquid / draw
  from N2192's own standpoint) instead of retyping the old list.
- **Test module:** `test_c07_shockwave_tower_charge.py` +
  `register_c07_shockwave_tower_charge.py`, following the N2191
  registration pattern (test file asserts the ledger `godot_owner` +
  `source_symbols` for the new pure function; register script rebuilds
  SSOT). Neighbours to run at GREEN: the N2177 shockwave-tower module
  + the wiring 9 modules / 32 tests.

## GREEN (this run, 17:15 +07 tick)

- **Pure function** `source_shockwave_tower_charge_state(frame, delta)` added to
  the EXISTING `SourceShockwaveTowerBuildState.gd` (dict-return style,
  `{"reload_counter": float}`): absent key → deterministic 0.0, gate
  `potential_efficiency > 0.0`, increment `efficiency * delta`, no clamp,
  no reset. **Driver:** one call after `apply_update_consumption_state`
  in `source_shockwave_tower_tick_buildings_state`, passing `seconds`,
  stamping `frame["reload_counter"]`.
- **RED-test fix (test-harness only, no gameplay change):** the RED test
  asserted 4 Java exprs in the .gd file that the N2177 file only carried
  as prose — `efficiency = optionalEfficiency = 0f;` (BuildingComp
  :1993), `range = 170f;` / `reload = 80f;` (Blocks.java:2043-2044),
  `public void updateTile(){` (ShockwaveTower.java:72) — added as
  citations in the new function's comment. All 4 verified verbatim
  against upstream (the handoff's RED evidence list). First GREEN run
  failed on the first of these only (`efficiency = optionalEfficiency
  = 0f;`); the other 3 were found by grep before the re-run.
- **Register run clean:** SSOT **11396/1642/1563/2917**, audit 1335 —
  exactly the RED estimate. Defense shards mirrored as expected:
  defense_slices 154 → 155, defense_api_contracts 153 → 154, N2192 in
  both.
- **Targeted: Ran 4, OK in 13.141s** (log `n2192-green.log`, Godot
  4.6.2 on PATH, port 7777 FREE at start; proof 6 keys `matches:
  true`, 0 ERROR, returncode 0). **Neighbours: family N2177 4/4 OK**
  (13.241s); **wiring-standard set 32/32 OK in 122.808s** (log
  `n2192-wiring.log`: factory_live_loop, power_graph_live_update_binding,
  battery_power_status_binding, battery_placement_binding,
  adjacent_factory_live_loop, unit_factory_live_loop, turret_live_loop,
  continuous_liquid_turret_live_loop, power_graph_consumer_cheating).
  **GREEN total 40/40 OK.** `git diff --check` clean. Port 7777 free
  after all runs. Nothing staged, committed or pushed.
- **NOT done:** full gate (MAIN THREAD ONLY — launch from the main
  thread: `cd tools/mindustry_godot_transpiler && python3 -c "import
  javalang" && setsid nohup python3 -m unittest discover -s tests >
  full-suite-n2192-gate.log 2>&1 < /dev/null &`, no Godot on PATH,
  no proof scene while the gate runs) → report/spec/GOAL → commit +
  push. Expect Ran ~5861, failures ~142, skipped 5, 0 errors (all
  Godot-absent asserts). Windows Godot proof stays debt in GOAL.md §5.
- **Next after N2192:** ShockwaveTower shouldConsume gate (`return
  reloadCounter < reload;` — now unblocked, the charge stamps the live
  counter), then BuildTurret shouldConsume, ShieldWall broken(),
  MassDriver / LaunchPad rows, RepairTurret coolant, the Units.nearby
  live query — each its own slice; or C08 inventory when asked.

## NOT done (report/spec/GOAL + push — gate DONE)

- Gate DONE (see "Gate FINISHED" below). Remaining: report
  (`docs/superpowers/reports/2026-11-15-c07-shockwave-tower-charge.md`)
  → spec (Done/ledger 1641 → 1642 + N2192 row, in the docs commit — the
  N2190 miss is NOT repeated) → GOAL.md §5 (Windows proof stays debt)
  → push. Windows Godot proof stays debt in GOAL.md §5.
- **Next after N2192:** ShockwaveTower shouldConsume gate (now unblocked
  — the charge stamps the live counter), then BuildTurret shouldConsume,
  ShieldWall broken(), MassDriver / LaunchPad rows, RepairTurret
  coolant, the Units.nearby live query — each its own slice; or C08
  inventory (classify the 5,390 null-body functions) when asked.

## DONE this run (17:4x +07 tick)

- Full gate finished ~17:37 (see "Gate FINISHED" above) → report
  (`docs/superpowers/reports/2026-11-15-c07-shockwave-tower-charge.md`)
  → spec (Done/ledger 1641 → 1642 + N2192 row, in the docs commit — the
  N2190 miss is NOT repeated) → GOAL.md §5 (Windows proof stays debt) →
  slice commit `b028951` (11 files, +935) → docs `8b609ad` + GOAL
  `9193eb4` commits → this hash-naming commit → push to origin main in
  this tick (origin/main re-checked before push: still 9e26791 — new
  slice branches N2232–N2234 exist on the fork but main is untouched).
- **Next after N2192:** ShockwaveTower shouldConsume gate (now unblocked
  — the charge stamps the live counter), then BuildTurret shouldConsume,
  ShieldWall broken(), MassDriver / LaunchPad rows, RepairTurret
  coolant, the Units.nearby live query — each its own slice; or C08
  inventory (classify the 5,390 null-body functions) when asked.

## Gate FINISHED (verified 17:45 +07 tick)

- Gate (main thread, PID 2712, SID 2712, ~17:21): **Ran 5861 tests in
  966.039s, FAILED (failures=142, skipped=5)** — log
  `tools/mindustry_godot_transpiler/full-suite-n2192-gate.log` (96,969
  bytes, footer present). All 142 verified Godot-absent: **142 ×
  `AssertionError: unexpectedly None`**, 0 other AssertionError types,
  0 `ERROR:` lines, 142 `FAIL:` lines. The N2192 proof test is failure
  #142 (the expected +1: it needs Godot on PATH, and it passed 4/4 in
  the targeted run where Godot was on PATH). No VM restart during the
  gate (uptime 33 min at the 17:45 check; restart #13 ~17:13 happened
  BEFORE the gate launched). javalang 0.13.0 still importable, port
  7777 FREE, godot NOT on PATH (correct baseline). Gate is clean
  except Godot — exactly the N2191 baseline (Ran 5857, failures 141,
  skipped 5) + 4 new tests / +1 failure from the new proof test. Slice
  is DONE per the repo process.

## Gate (launched main thread ~17:21 +07)

- Full gate (main thread, PID 2712, SID 2712): `which godot` → NOT on PATH (correct baseline); javalang OK; log `full-suite-n2192-gate.log`, growing with dots + F's (308 bytes at launch check). Parent subshell PID 2709 stays alive. Expected: Ran ~5861, failures ~142, skipped 5, 0 errors.
- Neighbours verified by main thread: family N2177 module Ran 4 OK (13.073s, re-run ~17:21, port FREE) + new module 4/4 (targeted) + wiring 32/32 (Ran 32, OK from `n2192-wiring.log`). Neighbours final: targeted 4 + family 4 + wiring 32 = 40/40.
- Proof JSON: 9 keys total (6 semantic + registry_valid + one_headquarter_per_ssot + matches), matches:true, 0 false.
