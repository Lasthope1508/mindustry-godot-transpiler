# Report — N2144: assembler drones_in_position live count (C07)

Date: 2026-11-13. Batch: N2144 (single slice). Status: **DONE + PUSHED 2026-11-13 ~02:45 +07 (02:45 cron run). Targeted tests 4/4 OK, neighbours 20/20 OK, Godot proof GREEN, full gate verified clean except Godot (Ran 5673, failures=95, skipped=5, 0 errors — all 95 Godot-absent asserts). Commit + push to origin main (fork Lasthope1508) this run — see handoff for the commit hashes.**

## What changed

The first of the deferred C07 frame-input follow-ups named in the N2138, N2139 and N2142 handoffs ("frame has no drones_in_position (default 0, eff 0, no progress until a drone-position slice lands)"). N2139 wired the assembler production tick and its pure function takes `in_position_count` as an input, but the tick driver read it from `frame.get("drones_in_position", 0)` (`SourceUnitFactoryBuildState.gd:839`) and the frame never stamped a live value, so `eff` was 0 and no progress advanced — the driver comment at lines 821-826 said so outright. N2144 is that live count: the AssemblerAI-only drone list counted through `inPosition()` (UnitAssembler.java:516), exposed as one pure count over the frame's units list so the driver stamps `frame["drones_in_position"]` before the tick call.

Composition, not re-implementation: the tick function (`source_unit_assembler_production_tick_state`, N2139) already divides `in_position_count` by `drones_created` (`SourceUnitFactoryBuildState.gd:1250`); N2144 does not touch it. N2144 supplies the missing count + driver stamp.

Pure `SourceUnitFactoryBuildState.source_assembler_drones_in_position_state(units: Array)` — follows the team-stats pattern (array in, null-safe, skips non-Dictionary entries): counts entries with `str(entry.get("type_name", "")) == "assembly-drone"` AND `bool(entry.get("in_position", false))`. Returns `{"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ASSEMBLER_DRONES_IN_POSITION_STATE, "drones_in_position": count}`. Flat count, no payload recursion — Java counts the flat assembler `units` Seq, not Groups.unit. Header comment quotes `float eff = (units.count(u -> ((AssemblerAI)u.controller()).inPosition()) / (float)dronesCreated);` (UnitAssembler.java:516) and `public UnitType droneType = UnitTypes.assemblyDrone;` (UnitAssembler.java:47). Owner constant `PORT_GAME_SOURCE_ASSEMBLER_DRONES_IN_POSITION_STATE := "port_game.source_assembler_drones_in_position_state"` in `SourceRuntimeOwnerUnitBuildingRegistry.gd` (next to the N2143 constant).

Driver stamp in `SourceUnitFactoryBuildState.gd`, UnitAssembler branch, before the tick call: `frame["drones_in_position"] = int(source_assembler_drones_in_position_state(frame.get("units", [])).get("drones_in_position", 0))` — the tick call keeps reading `int(frame.get("drones_in_position", 0))`, now stamped instead of default. The stale driver comment (lines 821-826: "the frame records no drones_in_position either, so eff is 0 ... until a drone-position slice lands") is replaced with the live-stamp note; the spawn_occupied / allow_update sentences are kept (still deferred).

Scope decision (decided in RED, data-checked in this VM): `spawn_occupied` / `spawn_visual_occupied` stay deferred — `checkSolid(spawn, false/true)` (UnitAssembler.java:675-680) needs tile solidity + a nearby-units query, world/collision data the frame does not carry; `allow_update` stays deferred — the canonical `allow_update_state` exists but the driver cannot supply its inputs (`rules_state` carries only `unitCostMultiplier` + `teams`, no `env` / map limits; the catalog carries no block env/privileged flags). The per-unit `AssemblerAI.inPosition()` evaluation from live unit pos/rotation stays deferred — the count reads the recorded `in_position` flag, exactly like N2141's team stats read the recorded `type_name`/`type_id`.

## Proof keys (new scene, 6 keys)

New scene `C07AssemblerDronesInPositionProof` (modeled on `C07ReconstructorConstructTimeProof` — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_ASSEMBLER_DRONES_IN_POSITION_PROOF `:

- `count_empty_0`: the pure count over `[]` → 0.
- `count_two_of_four`: 4 synthetic assembly-drone entries, 2 with `in_position` true → 2.
- `count_ignores_other_types`: non-assembly-drone entries (e.g. `type_name` "dagger") with `in_position` true → not counted.
- `count_ignores_not_in_position`: assembly-drone entries with `in_position` false → 0.
- `tick_eff_half`: `source_unit_assembler_production_tick_state` with in_position_count 2, drones_created 4 → eff 0.5, progress advances by `edelta * unit_build_speed * 0.5 / plan.time` (plan `{"unit": "mace", "time": 60.0}` → progress `0.5/60.0`).
- `tick_no_progress_zero_drones`: same call with in_position_count 0 → eff 0, progress unchanged 0.0.

## Verified numbers (measured in this VM)

- Test module `test_c07_assembler_drones_in_position.py`: **4/4 OK in 15.1s** (Godot on PATH, re-verified this run; 14.8s at GREEN time 02:15) — registration (ledger N2144, 1 new symbol, runtime proof, test names, deferred_exprs), exact-evidence (1 new symbol + 7 exprs over UnitAssembler.java + AssemblerAI.java + UnitTypes.java, all found verbatim), source-text (pure function exists + the two quoted Java lines in its comment + driver stamps from `frame.get("units", [])` + owner constant; proof has the 6 new keys), and the Godot proof test (6 new keys, all true, `matches: true`).
- RED run (02:00 cron run): 4 tests in 0.953s, FAILED (failures=2, errors=2), all expected — registration `KeyError: 'N2144'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure function did not exist yet), proof returncode 1 (proof scene did not exist yet).
- Neighbours (Godot on PATH, sequential, 02:15 cron run): **20/20 OK** — `test_c06_unit_assembler_production_tick` (N2139) + `test_c07_units_can_create` (N2140) + `test_c07_unit_group_counts` (N2141) + `test_c07_power_status_live` (N2142) + `test_c07_reconstructor_construct_time` (N2143), each 4/4.
- `git diff --check` clean.
- SSOT +1/+1/+1/+2 → **11298 / 1595 / 1516 / 2823**; audit stays 1335.

## Gate / suite

- Test modules standalone: N2144 4/4 (proof green, see above); neighbours 20/20.
- Godot proof: **GREEN 2026-11-13 ~02:15 +07** (02:15 cron run) — 6 new keys all true, `matches: true`, on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- Full Python suite, inclusive gate with the N2144 module (log `tools/mindustry_godot_transpiler/full-suite-n2144-gate.log`, 211 modules): **FINISHED ~02:37 +07, VERIFIED clean except Godot in this run — Ran 5673 tests in 880.661s, FAILED (failures=95, skipped=5), 0 errors. All 95 failures verified Godot-absent: 95 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None` (94 plain + 1 hydration proof, 94 inherited + new N2144 proof test), 0 `ERROR:` blocks; the N2144 module shows no failure other than its Godot-proof test.** Gate attempt 1 (worker, setsid, PID 9634, ~02:20) died session-end ~02:21 (log frozen at 3472 bytes, preserved as `full-suite-n2144-gate-attempt1.log`); attempt 2 (setsid, PID 9866, ~02:22, main-thread launch) finished clean. The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule). No VM restart since the 01:45 run; javalang 0.13.0 present, no reinstall needed.

## Deferred

- `spawn_occupied` / `spawn_visual_occupied` frame inputs — `checkSolid(spawn, false/true)` (UnitAssembler.java:675-680) needs tile solidity + nearby-units query; the port's `check_solid_state()` is a no-arg stub returning false; waits for a collision/tile-solidity frame-data slice.
- `allow_update` frame input — canonical `allow_update_state` exists (`SourceBuildingAccessState`, BuildingComp.java:622-627) but the driver cannot supply its inputs: `rules_state` carries only `unitCostMultiplier` + `teams` (no `env`, `limitMapArea`, limits), and the catalog carries no block env/privileged flags; waits for a rules-state capture slice.
- Per-unit `AssemblerAI.inPosition()` evaluation from live unit pos/rotation/targetPos/targetAngle — the count reads the recorded `in_position` flag; the units list carries no pos/rotation yet.
- Net `readUnits` / `whenSyncedUnits` drone sync — presentation/net, not state.
- `moveOutPayload()` modeling — the assembler production tick still has no payload move-out.
- `power.status` live read for the other consumer families (drill, turret, factory, adjacent) — the write-back stamps every consumer's frame generically, but only the unit-factory driver reads `frame["power_status"]` so far; the other families' consumption paths still fold their own defaults until their slices land.
- C07–C12 remain open. Next candidate: N2145 scopes from the deferred list at RED — leading candidate is `power.status` for the remaining consumer families (the N2142 write-back already stamps every consumer's frame generically; each family's driver read is the remaining work).

See `handoffs/2026-11-13-c07-assembler-drones-in-position-handoff.md` for the full detail.
