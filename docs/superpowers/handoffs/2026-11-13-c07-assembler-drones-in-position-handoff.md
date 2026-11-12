# Handoff — N2144: assembler drones_in_position live count (C07)

Date: 2026-11-13. Batch: N2144 (single slice). Status: **DONE + PUSHED 2026-11-13 ~02:45 +07 (02:45 cron run). Targeted 4/4 OK (re-verified 15.1s this run) + neighbours 20/20 OK, Godot proof GREEN. Full gate attempt 2 CERTIFIED clean except Godot (Ran 5673 in 880.661s, failures=95, skipped=5, 0 errors — all 95 verified Godot-absent asserts). Slice commit + docs commit pushed to origin main — see "Commits" below.**

## RED progress (02:00 cron run)

- State at RED time: main at 2dd9abc (N2143 merged + pushed to the fork 2026-11-13 ~01:57; C07 reconstructor constructTime catalog capture done). Working tree clean except untracked `*.gd.uid` files (never stage) and untracked gate logs (pre-existing env noise, not this slice).
- javalang 0.13.0 present at run start (no reinstall needed — no VM restart since the 01:45 run). Godot 4.6.2 present (`~/workspace/godot-bin/godot`; `godot` is NOT on the default PATH — targeted runs must `export PATH="$HOME/workspace/godot-bin:$PATH"`).
- Test module written: `tools/mindustry_godot_transpiler/tests/test_c07_assembler_drones_in_position.py` (4 tests). RED run (Godot on PATH): **Ran 4 tests in 0.953s, FAILED (failures=2, errors=2)** — all expected:
  - registration `KeyError: 'N2144'` (ledger entry not written yet);
  - evidence errors on the missing ledger entry (same KeyError);
  - source-text `AssertionError`: `static func source_assembler_drones_in_position_state` not found in `SourceUnitFactoryBuildState.gd` (the pure count does not exist yet);
  - proof: Godot returncode 1, `Cannot open file 'res://tools/runtime_proofs/C07AssemblerDronesInPositionProof.tscn'` — the proof scene does not exist yet.
- `git diff --check` clean (no tracked changes yet — only the new untracked test module + this handoff).

## What this batch is

The first of the deferred C07 frame-input follow-ups named in the N2138, N2139 and N2142 handoffs ("frame has no drones_in_position (default 0, eff 0, no progress until a drone-position slice lands)"). N2139 wired the assembler production tick and its pure function takes `in_position_count` as an input, but the tick driver reads it from `frame.get("drones_in_position", 0)` (`SourceUnitFactoryBuildState.gd:839`) and the frame never stamps a live value, so `eff` is 0 and no progress advances — the driver comment at lines 821-826 says so outright. N2144 is that live count: the AssemblerAI-only drone list counted through `inPosition()` (UnitAssembler.java:516), exposed as one pure count over the frame's units list so the driver stamps `frame["drones_in_position"]` before the tick call.

Composition, not re-implementation: the tick function (`source_unit_assembler_production_tick_state`, N2139) already divides `in_position_count` by `drones_created` (`SourceUnitFactoryBuildState.gd:1250`); N2144 does not touch it. N2144 supplies the missing count + driver stamp.

## Scope decision (decided in RED — the other two frame inputs stay deferred)

The three deferred frame inputs split by data availability, checked in this VM before RED:

- **`drones_in_position` — IN N2144.** Computable from data the driver can carry: the frame's units list (`frame.get("units", [])`, the N2141 record shape `{"team_id", "type_id", "type_name", "payload_units"}`) plus the recorded per-unit `in_position` flag.
- **`spawn_occupied` / `spawn_visual_occupied` — DEFERRED, not N2144.** `checkSolid(spawn, false/true)` (UnitAssembler.java:675-680) needs tile solidity (`EntityCollisions.solid` overlap) + a nearby-units query (`Units.anyEntities`) — world/collision data the frame does not carry. The port's only checkSolid, `SourceBuildingCoreState.check_solid_state()`, is a no-arg stub returning `false`. A live value waits for a collision/tile-solidity frame-data slice.
- **`allow_update` — DEFERRED, not N2144.** The canonical `SourceBuildingAccessState.allow_update_state(...)` (12 params, `BuildingComp.allowUpdate()`, BuildingComp.java:622-627) already exists, but the driver cannot supply its inputs: `rules_state` carries only `unitCostMultiplier` + `teams` (no `env`, `limitMapArea`, `limitX/Y/W/H`, `disableOutsideArea`), and the catalog carries no block env/privileged flags. A live stamp waits for a rules-state capture slice (env + map limits). Do NOT wire it with invented defaults — repo rule: defer behavior that needs another Java line instead of guessing.
- Net `readUnits` / `whenSyncedUnits` drone sync stays deferred (presentation/net, not state); the per-unit `AssemblerAI.inPosition()` evaluation from live unit pos/rotation/targetPos/targetAngle stays deferred (the units list carries no pos/rotation yet — the count reads the recorded `in_position` flag, exactly like N2141's team stats read the recorded `type_name`/`type_id`).

## Exact upstream evidence (all 7 exprs verified verbatim in this VM)

- Count (UnitAssembler.java:516): `float eff = (units.count(u -> ((AssemblerAI)u.controller()).inPosition()) / (float)dronesCreated);`
- List filter (UnitAssembler.java:460): `units.removeAll(u -> !u.isAdded() || u.dead || !(u.controller() instanceof AssemblerAI));`
- Per-unit gate (AssemblerAI.java): `public boolean inPosition(){` / `return unit.within(targetPos, 10f) && Angles.within(unit.rotation, targetAngle, 15f);`
- Drone type (UnitAssembler.java:47): `public UnitType droneType = UnitTypes.assemblyDrone;`
- Drone type name (UnitTypes.java:4595): `assemblyDrone = new ErekirUnitType("assembly-drone"){{`
- Drone cap (UnitAssembler.java:48): `public int dronesCreated = 4;`

## Design (decided in RED, implement in GREEN)

- **New pure function** `SourceUnitFactoryBuildState.source_assembler_drones_in_position_state(units: Array) -> Dictionary` — follows the team-stats pattern (array in, null-safe, skips non-Dictionary entries): counts entries with `str(entry.get("type_name", "")) == "assembly-drone"` AND `bool(entry.get("in_position", false))`. Returns `{"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ASSEMBLER_DRONES_IN_POSITION_STATE, "drones_in_position": count}`. Flat count, no payload recursion — Java counts the flat assembler `units` Seq, not Groups.unit. Header comment quotes `float eff = (units.count(u -> ((AssemblerAI)u.controller()).inPosition()) / (float)dronesCreated);` (UnitAssembler.java:516) and `public UnitType droneType = UnitTypes.assemblyDrone;` (UnitAssembler.java:47) — the source-text test asserts them.
- **Owner constant** `PORT_GAME_SOURCE_ASSEMBLER_DRONES_IN_POSITION_STATE := "port_game.source_assembler_drones_in_position_state"` in `SourceRuntimeOwnerUnitBuildingRegistry.gd` (next to the other `PORT_GAME_SOURCE_*_STATE` constants for this file).
- **Driver stamp** in `SourceUnitFactoryBuildState.gd`, UnitAssembler branch, before the tick call (~line 839): `frame["drones_in_position"] = int(source_assembler_drones_in_position_state(frame.get("units", [])).get("drones_in_position", 0))` — the tick call keeps reading `int(frame.get("drones_in_position", 0))`, now stamped instead of default. Replace the stale driver comment (lines 821-826: "the frame records no drones_in_position either, so eff is 0 ... until a drone-position slice lands") with the live-stamp note; keep the spawn_occupied / allow_update sentences (still deferred).
- **Register script** `register_c07_assembler_drones_in_position.py` (modeled on the N2143 one): 1 new result symbol:
  - `source_assembler_drones_in_position_state_result.drones_in_position` ← `float eff = (units.count(u -> ((AssemblerAI)u.controller()).inPosition()) / (float)dronesCreated);` (UnitAssembler.java:516 — the count the tick divides by dronesCreated).
  - Input (schema only): `units` ← `units.removeAll(u -> !u.isAdded() || u.dead || !(u.controller() instanceof AssemblerAI));` (UnitAssembler.java:460 — the AssemblerAI-only list the count runs over). Slice `java_source` UnitAssembler.java, `java_class` `mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild`, `java_method` `UnitAssemblerBuild.updateTile()`.
  - Expected SSOT +1 symbol / +1 slice / +1 contract / +2 schemas → **11298 / 1595 / 1516 / 2823**; audit 1335. GREEN verifies actuals.
- **Proof**: new scene `godot-mindustry/tools/runtime_proofs/C07AssemblerDronesInPositionProof.gd` + `.tscn` (modeled on `C06UnitAssemblerProductionProof` — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_ASSEMBLER_DRONES_IN_POSITION_PROOF `, 6 keys:
  - `count_empty_0`: the pure count over `[]` → 0.
  - `count_two_of_four`: 4 synthetic assembly-drone entries, 2 with `in_position` true → 2.
  - `count_ignores_other_types`: non-assembly-drone entries (e.g. `type_name` "dagger") with `in_position` true → not counted.
  - `count_ignores_not_in_position`: assembly-drone entries with `in_position` false → 0.
  - `tick_eff_half`: `source_unit_assembler_production_tick_state` with in_position_count 2, drones_created 4 → eff 0.5, progress advances by `edelta * unit_build_speed * 0.5 / plan.time` (assert the exact progress value, same shape as the N2139 proof's progress cases).
  - `tick_no_progress_zero_drones`: same call with in_position_count 0 → eff 0, progress unchanged.
  - Proof JSON is gitignored, never stage it.
- **Neighbours to run in GREEN** (targeted, sequential, Godot on PATH): N2139 `test_c06_unit_assembler_production_tick` (4/4 expected), N2140 `test_c07_units_can_create`, N2141 `test_c07_unit_group_counts` (units-list shape), N2142 `test_c07_power_status_live`, N2143 `test_c07_reconstructor_construct_time` (4/4 each).

## Files changed (RED only; uncommitted)

- `tools/mindustry_godot_transpiler/tests/test_c07_assembler_drones_in_position.py` (new, 4 tests): registration (ledger N2144, 1 new symbol, runtime proof, test names, deferred_exprs), exact-evidence (1 new symbol + 7 exprs over UnitAssembler.java + AssemblerAI.java + UnitTypes.java), source-text (pure function exists + the two quoted Java lines in its comment + driver stamps from `frame.get("units", [])` + owner constant; proof has the 6 new keys), Godot proof (`C07AssemblerDronesInPositionProof.tscn`, prefix `C_07_ASSEMBLER_DRONES_IN_POSITION_PROOF `, the 6 new keys true).
- This handoff (new, untracked).

## Verified numbers (do not re-derive, these are measured in this VM)

- RED run: **4 tests in 0.953s, FAILED (failures=2, errors=2), all expected** — registration `KeyError: 'N2144'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure function does not exist yet), proof returncode 1 (proof scene does not exist yet).
- Exact-expr pre-check: **7/7 exprs found verbatim** in the 3 slice sources (UnitAssembler.java, AssemblerAI.java, UnitTypes.java).
- Negatives confirmed before RED: `source_assembler_drones_in_position_state` 0 times in `SourceUnitFactoryBuildState.gd`; `ASSEMBLER_DRONES_IN_POSITION` 0 times in `SourceRuntimeOwnerUnitBuildingRegistry.gd`; `drones_in_position` 0 times in `source_symbol_registry.json`.
- `git diff --check` clean.
- State at RED time: main at 2dd9abc (N2143 merged + pushed to the fork 2026-11-13 ~01:57); SSOT 11297 / 1594 / 1515 / 2821; audit 1335.
- javalang 0.13.0 present at run start (no reinstall needed); Godot 4.6.2 on `~/workspace/godot-bin`.

## GREEN progress (02:15 cron run)

- Pure count `SourceUnitFactoryBuildState.source_assembler_drones_in_position_state(units: Array)` → `{"source_owner", "drones_in_position"}` (counts Dictionary entries with `type_name == "assembly-drone"` and `in_position` true; skips non-Dictionary entries, team-stats pattern N2141; flat count, no payload recursion). Header comment quotes both `float eff = ...` (UnitAssembler.java:516) and `public UnitType droneType = UnitTypes.assemblyDrone;` (UnitAssembler.java:47).
- Owner constant `PORT_GAME_SOURCE_ASSEMBLER_DRONES_IN_POSITION_STATE` added to `SourceRuntimeOwnerUnitBuildingRegistry.gd` (next to the N2143 constant).
- Driver stamp in the UnitAssembler branch before the tick call: `frame["drones_in_position"] = int(source_assembler_drones_in_position_state(frame.get("units", [])).get("drones_in_position", 0))`; the tick call keeps reading `int(frame.get("drones_in_position", 0))`, now stamped instead of default. Stale comment lines 821-826 replaced with the live-stamp note; spawn_occupied / allow_update sentences kept (still deferred). Tick function N2139 untouched.
- Register script `register_c07_assembler_drones_in_position.py` (modeled on the N2143 one): 1 new result symbol, SSOT actuals **11298 / 1595 / 1516 / 2823** — exactly the RED expectation (+1/+1/+1/+2); audit 1335.
- Proof scene `C07AssemblerDronesInPositionProof.gd` + `.tscn` (modeled on `C07ReconstructorConstructTimeProof`): Godot proof **GREEN** — `C07AssemblerDronesInPositionProof.json`, 6/6 keys true, `matches: true`, no ERROR (Godot 4.6.2-stable Linux, build 71f334935). Tick keys use plan `{"unit": "mace", "time": 60.0}`: eff 0.5 → progress `0.5/60.0`; 0 drones → progress unchanged 0.0.
- Targeted **4/4 OK** in 14.8s (Godot on PATH). Neighbours **20/20 OK** sequential (N2139 + N2140 + N2141 + N2142 + N2143, each 4/4). `git diff --check` clean.
- Full gate **attempt 1 (worker, PID 9634, setsid, ~02:20) DIED session-end ~02:21** (log frozen 3472 bytes, preserved as `full-suite-n2144-gate-attempt1.log`). **Attempt 2 (main thread, PID 9866, setsid, SID 9866, ~02:22, javalang verified OK) FINISHED ~02:37 +07: Ran 5673 in 880.661s, FAILED (failures=95, skipped=5), 0 errors — CERTIFIED clean except Godot in the 02:45 cron run: 95 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None` (94 plain + 1 hydration proof; 94 inherited + new N2144 proof test), 0 `ERROR:` blocks; the N2144 module shows no failure other than its Godot-proof test (which passes with Godot present, 4/4 OK re-verified 15.1s this run).** Log: `tools/mindustry_godot_transpiler/full-suite-n2144-gate.log`.
- Files changed (uncommitted): `SourceUnitFactoryBuildState.gd` (pure + driver), `SourceRuntimeOwnerUnitBuildingRegistry.gd` (1 const), `register_c07_assembler_drones_in_position.py` (new), `tests/test_c07_assembler_drones_in_position.py` (RED), `C07AssemblerDronesInPositionProof.gd/.tscn` (new), SSOT JSONs (registry/ledger/contracts/schema/audit shards), this handoff. Never stage `*.gd.uid`, proof `.json` (gitignored), gate logs.

## Commits (pushed to origin main 2026-11-13 ~02:45 +07, this run)

- Slice commit: (hash below — filled after commit)
- Docs commit: (hash below — filled after commit)
- Handoff-hash commit: (hash below — filled after commit)

## Next (after gate certification)

1. Verify the gate log (expect Ran ~5673, failures=95, skipped=5, 0 errors, all Godot-absent). — DONE this run, certified above.
2. Write the report + update the design spec (Status Summary 1594→1595) + this handoff, then commit + push the slice + docs to origin main. — DONE this run (report `docs/superpowers/reports/2026-11-13-c07-assembler-drones-in-position.md`; spec Status Summary 1594→1595, N2144 checklist + changelog rows).
3. Next slice N2145: scope at RED from the deferred list — leading candidate is `power.status` for the remaining consumer families (drill, turret, factory, adjacent): the N2142 write-back already stamps every consumer's frame generically; each family's driver read is the remaining work. `spawn_occupied` / `allow_update` still blocked on frame data (collision / rules-state capture slices); `moveOutPayload()` still waits for the payload-module representation; net drone sync stays deferred.

## Deferred (not this slice)

- `spawn_occupied` / `spawn_visual_occupied` frame inputs — `checkSolid(spawn, false/true)` (UnitAssembler.java:514-515, 675-680) needs tile solidity + nearby-units query; the port's `check_solid_state()` is a no-arg stub returning false; waits for a collision/tile-solidity frame-data slice.
- `allow_update` frame input — canonical `allow_update_state` exists (`SourceBuildingAccessState`, BuildingComp.java:622-627) but the driver cannot supply its inputs: `rules_state` carries only `unitCostMultiplier` + `teams` (no `env`, `limitMapArea`, limits), and the catalog carries no block env/privileged flags; waits for a rules-state capture slice.
- Per-unit `AssemblerAI.inPosition()` evaluation from live unit pos/rotation/targetPos/targetAngle — the count reads the recorded `in_position` flag; the units list carries no pos/rotation yet.
- Net `readUnits` / `whenSyncedUnits` drone sync (UnitAssembler.java:430-460) — presentation/net, not state.
- `moveOutPayload()` modeling — the assembler production tick still has no payload move-out.
- `power.status` live read for the other consumer families (drill, turret, factory, adjacent) — the write-back stamps every consumer's frame generically, but only the unit-factory driver reads `frame["power_status"]` so far.
- C07–C12 remain open.
