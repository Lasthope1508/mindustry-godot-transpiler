# Handoff — N2193 ShockwaveTower shouldConsume gate

Date: 2026-11-15. Batch: N2193 (single slice). Status: **DONE + PUSHED (slice `2e75942`, main `864c4e8`) — targeted 4/4 OK, neighbours 44/44 OK, proof 9 keys matches:true, full gate Ran 5865, failures=143, skipped=5, 0 errors (all Godot-absent).**

## RED (this run, 18:00 +07 tick)

- **Test module** `tools/mindustry_godot_transpiler/tests/test_c07_shockwave_tower_should_consume.py` (new) + **register script** `tools/mindustry_godot_transpiler/register_c07_shockwave_tower_should_consume.py` (new) + **proof scene** `godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerShouldConsumeProof.gd` (+ `.tscn`, new) written, following the N2191 proof shape with the N2192 placement (shockwave-tower, cell (28, 21), driver called directly).
- **Targeted RED run:** `python3 -m unittest tests.test_c07_shockwave_tower_should_consume` (Godot 4.6.2 on PATH, port 7777 FREE at run start): **Ran 4 in 9.969s, FAILED (failures=2, errors=2)** — log `tools/mindustry_godot_transpiler/n2193-red.log`. All four failures are the missing implementation, exactly the RED expectation:
  1. Registration — ERROR `KeyError: 'N2193'` (no ledger entry yet).
  2. Input-evidence — ERROR `KeyError: 'N2193'` (same cause).
  3. State — FAIL `static func source_shockwave_tower_should_consume_state` not found in SourceShockwaveTowerBuildState.gd.
  4. Proof — FAIL Godot parse error: `Static function "source_shockwave_tower_should_consume_state()" not found in base "SourceShockwaveTowerBuildState"` (3 call sites, proof .tscn fails to load), `ERROR:` in output.
  No proof .json written (scene never parsed); port 7777 free again after the run. `git diff --check` clean.
- **Slice files for the later commit (NOT staged yet):**
  `test_c07_shockwave_tower_should_consume.py` + `register_c07_shockwave_tower_should_consume.py` (new),
  `C07ShockwaveTowerShouldConsumeProof.gd` + `.tscn` (new),
  this handoff (new). GREEN will add: `SourceShockwaveTowerBuildState.gd` (M),
  `source_api_contracts.json` + `source_slice_ledger.json` +
  `source_state_schema.json` + `source_symbol_registry.json` (M),
  and is expected to mirror N2193 into the defense shards (see below).
  Never stage: `*.gd.uid`, proof `.json`, run logs, old gate logs.

## Scope (verified against upstream Java + the port this run)

- **N2193 is the ShockwaveTower shouldConsume gate, and nothing else.** One
  family (ShockwaveTower: shockwave-tower only), one pure function
  (`source_shockwave_tower_should_consume_state(frame)`) + one driver
  line in the EXISTING `godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd`, one proof scene. It closes the exact observable gap N2177 left open with a documented limit: with a fully charged tower power.status reads 1.0 while Java efficiency is 0.
- **Why this item, why now:** it is the first remaining C07 deferred item in the N2192 handoff "Next" order whose prerequisite just landed: N2192 stamps `reload_counter` on the frame each tick (the charge advance is the ONLY writer), so the gate slice can now read a live counter. The shouldConsume gate is the prerequisite for the fire gate (`reloadCounter < reload` is what the fire branch reads at ShockwaveTower.java:73 via the charge condition).
- **Why not the other deferred items** (all verified in the N2192 handoff table, still true this run — main 6b5f6f4, N2192 DONE + PUSHED):
  | Candidate | Why not N2193 |
  |---|---|
  | BuildTurret shouldConsume | Needs a plans count plus suppression state — two subsystem inputs, and the port tracks no live build-plan state. Bigger. |
  | ShieldWall broken() coupling | No shouldConsume override to wire (default `return enabled;`); the deferred item is the broken()/damage coupling — a different, bigger slice. |
  | RepairTurret coolant (repair-turret only) | Optional consumer, needs liquids state on the turret frame — the second pass, own slice. |
  | MassDriver / LaunchPad rows | Whole updateTile advances — much bigger, own slices. |
  | Units.nearby live query (`nearby_damaged_units` stamping) | Own slice; unrelated to the shockwave tower. |
- **SSOT baseline re-verified from the generated JSONs this run** (main
  6b5f6f4, N2192 DONE + PUSHED): symbols **11396** + slices **1642** +
  contracts **1563** + schemas **2917**; audit `totalSourceFunctions` 1335.
  Matches the N2192 handoff exactly. Expected after N2193 by the N2188
  rule (one symbol per result-dict key): **11397/1643/1564/2919** — the
  pure function returns a 1-key dict (`should_consume`); **verify at
  the GREEN register run, do not trust the estimate**.
- **Shard check (done this run):** YES, a shard selects ShockwaveTower.java — like N2192. The `defense_slices` shard selects `java_source` containing `/world/blocks/defense/` (source_ssot_modules.json), and `defense_api_contracts` mirrors owners from it. Verified from disk: N2192 IS in both shards today (defense_slices 155 slices, defense_api_contracts 154 contracts, per the N2192 handoff GREEN section). **So the GREEN register run is expected to mirror N2193 into both defense shards** (the N2177/N2192 precedent) — the register script's shard-rebuild loop writes all registered JSONs including shards. Verify the shard diffs at GREEN.
- **Environment (checked this run):** port 7777 FREE at RED run start (no Godot running); javalang 0.13.0 importable (no reinstall needed); Godot binary at `~/workspace/godot-bin/godot` (4.6.2-stable, build 71f334935) but NOT on PATH in the worker shell — the RED proof run exported `PATH="$HOME/workspace/godot-bin:$PATH"` first (the N2177 lesson). Worktree clean except pre-existing untracked `*.gd.uid` noise + old gate/run logs (never stage).

## Java source evidence (all verified verbatim this run — grep 2026-11-15 ~18:0x)

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
- Port mirror verified: the driver currently computes `var should_consume: bool = bool(frame.get("enabled", true))` BEFORE the consumption setup (SourceShockwaveTowerBuildState.gd, tick driver) and the N2192 charge runs AFTER `apply_update_consumption_state` and stamps `frame["reload_counter"]` — so at GREEN the pure gate call replaces that one line and reads the counter the PREVIOUS tick's charge stamped (the Java order: updateConsumption :2274 reads shouldConsume() at :1960 BEFORE updateTile :2277 charges the counter). No invented keys.
- Register script's EXACT_EXPRS verified verbatim against upstream at RED (40/40 present, 0 missing, checked by script this run); `slice_sources` includes Blocks.java (the N2191 lesson — the `consumePower(100f / 60f);` / `range = 170f;` / `reload = 80f;` exprs come from it).
- All 32 Java exprs the state test asserts in the .gd file are ALREADY present in SourceShockwaveTowerBuildState.gd (verified by grep this run — the N2177/N2192 comments carry them); GREEN only has to add the function itself plus its four new strings (`frame.get("reload_counter", null)`, `float(observed) < 80.0 and enabled`, `return {"should_consume": enabled}`, `source_shockwave_tower_should_consume_state(frame)`).

## Design (decided in scoping, to confirm at GREEN)

- New pure function `source_shockwave_tower_should_consume_state(frame)` in
  the EXISTING `godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd`
  (dict-return style), returning `{"should_consume": bool}`:
  `var enabled: bool = bool(frame.get("enabled", true))`,
  `var observed: Variant = frame.get("reload_counter", null)`,
  `if observed == null: return {"should_consume": enabled}`,
  `return {"should_consume": float(observed) < 80.0 and enabled}`.
- **Frame key: `reload_counter` (float).** Stamped by the N2192 charge every
  tick after apply_update_consumption_state; the gate is the only reader.
- **Driver change — one line** in
  `source_shockwave_tower_tick_buildings_state`, BEFORE the consumption
  setup: the pure-function call replaces
  `var should_consume: bool = bool(frame.get("enabled", true))`
  (the N2191 driver pattern), reading the `reload_counter` the previous
  tick's charge stamped. The setup / power row /
  `update_consumption_state` / `apply_update_consumption_state` / charge
  calls are unchanged.
- **Proof scene (written at RED):** new
  `C07ShockwaveTowerShouldConsumeProof.gd` (+ `.tscn`, no `.json` tracked),
  following the N2191 proof shape with the N2192 placement
  (shockwave-tower, cell (28, 21), driver called directly, not
  simulate_factory). 6 keys:
  1. `gate_passes_below_reload` — pure: counter 10.0, enabled → true.
  2. `gate_blocks_at_reload` — pure: counter 80.0 (at reload, not < reload), enabled → false.
  3. `gate_blocks_when_disabled` — pure gate + machinery (the N2191 pattern): counter 10.0, enabled=false → gate false, machinery efficiency 0.0 (the driver skips the whole consumption block when disabled, so a live tick cannot stamp a fresh efficiency).
  4. `gate_absent_preserves_power_fold` — live tick: NO `reload_counter` key, power 0.5, enabled → efficiency 0.5 (pins the absent-default decision).
  5. `gate_blocks_when_fully_charged` — live tick: counter 80.0, power 1.0 → efficiency 0.0 (the gate overrides the power fold).
  6. `gate_passes_below_reload_live` — live tick: counter 10.0, power 0.5 → efficiency 0.5.

## RED decisions (frame keys, proof keys, exact vs deferred)

- **Absent `reload_counter` → `should_consume = enabled`.** Rationale (the
  N2191 `targets_count` / N2188 `has_target` precedent): null means "no
  observation yet", not "fully charged" — the N2192 charge stamps
  `reload_counter` only after the first consumption stamp each tick, and
  defaulting absent to false would zero efficiency for every live
  shockwave tower before its first charge tick, a live regression
  against N2177 GREEN. It also matches the Java default shouldConsume
  (`return enabled;`, BuildingComp.java:755-756) and the Java init:
  `reloadCounter = Mathf.random(reload);` (ShockwaveTower.java:67) is
  always < reload, so at Java init the gate is true when enabled.
- **The present case is `float(observed) < 80.0 and enabled`.** The
  `and enabled` follows the N2191 precedent (`targets_count > 0 and
  enabled`): the Java override alone has no enabled check, but the
  driver only runs the consumption block when enabled, and the Java
  default `return enabled;` makes enabled part of shouldConsume
  semantics. The 80.0 threshold is the per-def reload (Blocks.java:2044),
  NOT the class default 90.0 (`60f * 1.5f`, ShockwaveTower.java:26) — the
  per-def value overrides it, and the N2192 charge already runs against 80f.
- **The gate reads the counter the previous tick stamped, not a recomputed
  value.** The N2192 charge is the only writer of `reload_counter`; the
  driver calls the gate BEFORE the consumption setup (the Java order,
  updateConsumption :2274 reads shouldConsume() at :1960) and the charge
  runs AFTER apply_update_consumption_state — so the gate never sees a
  counter this tick's charge just advanced.
- **Exact exprs (this slice, all verified verbatim above):** the shouldConsume
  gate (:121-122), the counter init (:67), the charge line (:73), the fire
  reset + heat set (:82-83), the wave damage (:87), the heat decay (:104),
  sense (:110), warmup (:117), the class fields (:23-34, :46-47), edelta
  (:1927-1928), canConsume (:1917-1918), potentialEfficiency assignment
  (:1989), the update gate (:1960, :1992-1993), the shouldConsume default
  (:755-756), the row read (ConsumePower.java:39), the null fold
  (UnitAssembler.java:469), hasConsumers (Block.java:1449), the per-def
  block (Blocks.java :2040-2044: size 3, cyanogen, consumePower 100f/60f,
  range 170f, reload 80f). The register script's EXACT_EXPRS were verified
  verbatim against upstream at RED (40/40 present).
- **Deferred (NOT N2193):** the fire gate — bullet scan, wave damage,
  heat=1, reloadCounter=0 reset (ShockwaveTower.java:74-103); heat decay
  (:104 `heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);`); sense(LAccess.progress) = reloadCounter/reload (:110); warmup() returns heat (:117); cyanogen liquid consumer; draw modeling (:126-139). Windows Godot proof — debt in GOAL.md §5.
- **DEFERRED chain gap, recorded at RED:** the register script carries
  DEFERRED by import from `register_c07_shockwave_tower_charge`
  (runtime value verbatim, never retyped — the N2191/N2192 lesson, with
  the same NOTE left for the next slice). The inherited 160-entry list
  contains NO ShockwaveTower entries (the N2192 RED note, still true).
  The N2193 register script adds 2 new entries (Windows Godot proof debt
  + a re-pin of the still-deferred fire gate / heat / sense / warmup /
  liquid / draw from N2193's own standpoint). **The shouldConsume gate
  itself is NOT carried as deferred: it is THIS slice** — the inherited
  N2192 entry still names it as waiting, which is stale history,
  superseded by this slice; the register script's comment says so.
- **Test module:** `test_c07_shockwave_tower_should_consume.py` +
  `register_c07_shockwave_tower_should_consume.py`, following the N2191
  registration pattern (test file asserts the ledger `godot_owner` +
  `source_symbols` for the new pure function; register script rebuilds
  SSOT). Neighbours to run at GREEN: the N2177 shockwave-tower module
  (`tests.test_c07_shockwave_tower_power_status`, 4 tests) + the N2192
  module (`tests.test_c07_shockwave_tower_charge`, 4 tests) + the wiring
  9 modules / 32 tests.

## GREEN (this run, 18:15 +07 tick)

- **Pure function + 1 driver line** added to the EXISTING
  `godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd`:
  `source_shockwave_tower_should_consume_state(frame)` (dict-return
  style, `frame.get("reload_counter", null)` / absent →
  `{"should_consume": enabled}` / present →
  `float(observed) < 80.0 and enabled`) + driver line
  `var should_consume: bool = bool(source_shockwave_tower_should_consume_state(frame).get("should_consume", true))`
  replacing `bool(frame.get("enabled", true))` (the N2191 pattern).
  Stale "(2) shouldConsume gate deferred" comments left untouched
  (the N2191 precedent — minimal GREEN).
- **RED-worker claim corrected:** `size = 3;` was NOT already in the
  .gd file (grep count 0 at GREEN start); it is now carried in the
  new function's comment (`size = 3;` + `range = 170f;` +
  `reload = 80f;`). All other 31 asserted exprs verified present.
- **Register run:** SSOT **11397/1643/1564/2919**, audit 1335 —
  exactly the RED estimate. Defense shards mirrored: defense_slices
  155 → **156**, defense_api_contracts 154 → **155**. `git diff
  --check` clean.
- **Targeted:** `python3 -m unittest
  tests.test_c07_shockwave_tower_should_consume` (Godot 4.6.2 on
  PATH, port 7777 FREE): **Ran 4 in 15.047s, OK**. Proof scene
  `C07ShockwaveTowerShouldConsumeProof.json`: **6 keys, all true,
  `matches: true`**, no ERROR.
- **Neighbours:** family N2177 4 + N2192 4 = **8/8 OK** (28.047s);
  wiring 9 modules / **32/32 OK** (119.091s, log `n2193-wiring.log`).
  **GREEN total 44/44 OK** (targeted 4 + family 8 + wiring 32).
- **Full gate LAUNCHED this run** (setsid nohup, no Godot on PATH,
  no proof scene while it runs): `python3 -m unittest discover -s
  tests > full-suite-n2193-gate.log 2>&1`, PID 10614 (parent shell
  PID 10611), started ~18:2x, log accumulating (Godot-absent F's
  as expected). Expected: Ran ~5865, failures ~143, skipped 5,
  0 errors (all Godot-absent; +4 tests / +1 failure vs N2192).
  **Gate attempt 2 DONE (see "Gate FINISHED" below):** Ran 5865,
  failures=143, skipped=5, 0 errors — all Godot-absent. Slice is DONE
  per the repo process; remaining: report/spec/GOAL → commit + push
  (this tick).
- **Next after N2193:** ShockwaveTower fire gate (now unblocked),
  then BuildTurret shouldConsume, ShieldWall broken(), MassDriver
  / LaunchPad rows, RepairTurret coolant, the Units.nearby live
  query — each its own slice; or C08 inventory when asked.

## NOT done (report/spec/GOAL + push — gate DONE)

- Gate DONE (see "Gate FINISHED" below). Remaining: report
  (`docs/superpowers/reports/2026-11-15-c07-shockwave-tower-should-consume.md`)
  → spec (Done/ledger 1642 → 1643 + N2193 row, in the docs commit — the
  N2190 miss is NOT repeated) → GOAL.md §5 (Windows proof stays debt)
  → push. Windows Godot proof stays debt in GOAL.md §5.
- **Next after N2193:** ShockwaveTower fire gate (now unblocked),
  then BuildTurret shouldConsume, ShieldWall broken(), MassDriver /
  LaunchPad rows, RepairTurret coolant, the Units.nearby live query —
  each its own slice; or C08 inventory when asked.

## DONE this run (18:5x +07 tick)

- Full gate attempt 2 finished ~18:37 (see "Gate FINISHED" above) →
  report
  (`docs/superpowers/reports/2026-11-15-c07-shockwave-tower-should-consume.md`)
  → spec (Done/ledger 1642 → 1643 + N2193 row, in the docs commit — the
  N2190 miss is NOT repeated) → GOAL.md §5 (Windows proof stays debt) →
  slice commit `2e75942` (11 files, +958) → docs `927e6fd` + GOAL
  `2bd471f` commits → this hash-naming commit → push to origin main in
  this tick (origin/main re-checked before push: still 6b5f6f4).
- **Next after N2193:** ShockwaveTower fire gate (now unblocked — the
  shouldConsume gate is the prerequisite the fire branch reads), then
  BuildTurret shouldConsume, ShieldWall broken(), MassDriver / LaunchPad
  rows, RepairTurret coolant, the Units.nearby live query — each its own
  slice; or C08 inventory when asked.

## Gate FINISHED (verified 18:45 +07 tick)

- Gate attempt 2 (main thread, PID 10841, SID 10841, ~18:21): **Ran
  5865 tests in 977.751s, FAILED (failures=143, skipped=5)** — log
  `tools/mindustry_godot_transpiler/full-suite-n2193-gate.log` (97,656
  bytes, footer present). All 143 verified Godot-absent: **143 ×
  `AssertionError: unexpectedly None`**, 0 other AssertionError types,
  0 `ERROR:` lines, 143 `FAIL:` lines. The N2193 proof test is failure
  #143 (the expected +1: it needs Godot on PATH, and it passed 4/4 in
  the targeted run where Godot was on PATH). Attempt 1 (PID 10614,
  worker-launched) died at 3651/5865 tests with no footer when the
  worker session ended — no VM restart. No VM restart during attempt 2
  (uptime 1:33 at the 18:45 check; restart #13 ~17:13 happened BEFORE
  the gate launched). javalang 0.13.0 still importable, port 7777 FREE,
  godot NOT on PATH (correct baseline). Gate is clean except Godot —
  exactly the N2192 baseline (Ran 5861, failures 142, skipped 5) + 4
  new tests / +1 failure from the new proof test. Slice is DONE per
  the repo process.

## Gate attempt 2 (launched main thread ~18:21 +07)

- Gate attempt 1 (PID 10614, worker-launched) is DEAD — verified by main thread: no python/unittest process, log `full-suite-n2193-gate.log` stopped at 3651 bytes (3527 dots + 119 F + 0 E + 5 s, no footer) at ~3651/5865 tests. NO VM restart (uptime ~1:30 at the check). The gate died when the tick's worker session ended — the same worker-session death pattern as N2191 attempt 1. The worker's "gate running" status was stale.
- GREEN verified by main thread (the worker left NO `n2193-green.log` on disk): targeted re-run Ran 4 OK in 13.818s; family N2177 Ran 4 OK (13.389s) + N2192 Ran 4 OK (12.990s); wiring 32/32 OK (`n2193-wiring.log`: Ran 32, OK). GREEN total 44/44.
- Gate attempt 2 (main thread, PID 10841, SID 10841, ~18:21): `which godot` → NOT on PATH (correct baseline); javalang OK; log truncated fresh, growing with dots + F's (314 bytes at launch check). Parent subshell PID 10838 stays alive. Expected: Ran ~5865, failures ~143, skipped 5, 0 errors.
- Proof JSON: 9 keys total (6 semantic + registry_valid + one_headquarter_per_ssot + matches), matches:true, 0 false.
