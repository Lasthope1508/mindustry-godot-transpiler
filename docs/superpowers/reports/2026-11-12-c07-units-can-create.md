# Report — N2140: Units.canCreate live evaluation (C07 entry slice)

Date: 2026-11-12. Batch: N2140 (single slice). Status: **DONE + PUSHED 2026-11-12 ~23:05 +07 (23:00 cron run). Targeted tests 4/4 OK, neighbours 28/28, Godot proof GREEN, full gate verified clean except Godot (Ran 5657, failures=91, skipped=5, 0 errors — all 91 Godot-absent asserts). Commit + push to origin main (fork Lasthope1508) this run — see handoff for the commit hashes.**

## What changed

The C07 entry slice and the first item on the N2139 "Next" list (C07–C12 per the completion backlog). The N2139 handoff deferred `Units.canCreate` live evaluation to C07 ("needs C07: live per-type unit counts + the unit cap"); the assembler `should_consume` branch (`SourceUnitFactoryBuildState.gd:593`) and the production tick driver (`SourceUnitFactoryBuildState.gd:778`) still read `frame["can_create"]`, default true. N2140 is that slice: a pure `source_units_can_create_state(use_unit_cap, count_type, unit_cap, is_banned)` in `SourceUnitRuntimeState` that evaluates `!type.useUnitCap || (team.data().countType(type) < getCap(team) && !type.isBanned())` exactly as Units.java:116, plus a factory helper `source_unit_factory_can_create_state` (cap bridge + frame `team_unit_counts` + Rules.isBanned) wiring both assembler call sites to call it instead of the permissive frame default. Composition, not re-implementation: `getCap` and `countType` already have port-bridge pure functions (`PortGame.source_unit_cap_state`, `PortGame.source_unit_count_state`); `isBanned` logic already exists in the factory file (`unitWhitelist != bannedUnits.contains(unit)`); N2140 composes those three already-ported pieces with `type.useUnitCap` into the one predicate. The stale deferred comment (lines 529-531) is gone.

Neighbour fix in this slice (proof/test-harness only, no gameplay change — live call sites always pass game non-null): with game null the direct proof calls read rules `{}` → cap 0 (Rules.unitCap default) → can_create false for every assembler case. (a) `should_consume` now falls back to `frame.get("rules_state", {})` when game is null — the frame-rules convention already exists (tick driver stamps `frame["rules_state"]`, cons-item efficiency reads it); (b) proof scene: full-blocks frame carries `"rules_state": {"unitCap": 10}` (count 0 < 10 → can_create true); no-create frame carries `"rules_state": {"unitCap": 0}` instead of the now-dead `"can_create": false` key, so the false comes from the live evaluation.

Gap flagged (not a slice bug): the frame does not record live per-type unit counts yet (`team.data().typeCounts`, Teams.java:430-444) — the pure function takes `count_type` as an input and the frame helper defaults absent counts to 0 (permissive until a unit-group slice lands); the catalog does not capture `useUnitCap` per unit type (UnitType.java:205 defaults true — the helper defaults true, the Java default).

## Proof keys (new scene, 6 keys)

New scene `C07UnitsCanCreateProof` (plan unit mace, cap 10 unless noted), prefix `C_07_UNITS_CAN_CREATE_PROOF `:

- `can_create_under_cap`: useUnitCap true, count 9, cap 10, not banned → true.
- `can_create_at_cap`: useUnitCap true, count 10, cap 10, not banned → false.
- `can_create_no_cap_type`: useUnitCap false, count 99, cap 10 → true.
- `can_create_banned_unit`: useUnitCap true, count 0, cap 10, banned true → false.
- `can_create_uncapped_wave_team`: cap 2147483647 (`Integer.MAX_VALUE`), count 100 → true.
- `can_create_variable_cap`: cap 15 (rules.unitCap 10 + teamData.unitCap 5), count 14 → true, result `unit_cap` == 15.

## Verified numbers (measured in this VM)

- Test module `test_c07_units_can_create.py`: **4/4 OK in 13.2s** (Godot on PATH, 22:15 cron run) — registration (ledger N2140, 4 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (4 new symbols + 22 exprs over Units.java + Teams.java + UnitType.java + Rules.java + Team.java + GameState.java + UnitAssembler.java, all found verbatim), source-text (pure function exists + the two quoted Java lines in the function comment + factory calls it + the deferred comment is gone; proof has the 6 new keys), and the Godot proof test (6 new keys, all true, `matches: true`). Re-verified 22:30 run **4/4 OK in 12.9s**.
- RED run (22:00 cron run): 4 tests in 0.636s, FAILED (failures=2, errors=2), all expected — registration `KeyError: 'N2140'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure function did not exist yet), proof returncode 1 (proof scene did not exist yet).
- Neighbours (Godot on PATH, sequential): **28/28 OK** — `test_unit_factory_should_consume` (N2124) + `test_c06_unit_assembler_payload_should_consume` (N2132) + `test_c06_unit_factory_production_tick` (N2137) + `test_c06_reconstructor_production_tick` (N2138) + `test_c06_unit_assembler_production_tick` (N2139) + `test_c06_unit_factory_consume_trigger` (N2128) + `test_c07_units_can_create` (N2140), each 4/4, after the proof-harness fix above. (A combined parallel run showed port-7777 collision failures — env-only; sequential re-runs pass.)
- `git diff --check` clean.
- SSOT +4/+1/+1/+2 → **11286 / 1591 / 1510 / 2811**; audit stays 1335.

## Gate / suite

- Test modules standalone: N2140 4/4 (proof green, see above); neighbours 28/28 after the proof-harness fix.
- Godot proof: **GREEN 2026-11-12 ~22:15 +07** — 6 new keys all true, `matches: true`, on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- Full Python suite, inclusive gate with the N2140 module (log `tools/mindustry_godot_transpiler/full-suite-n2140-gate.log`, 210 modules): **FINISHED ~23:00 +07, VERIFIED clean except Godot in the 23:00 cron run — Ran 5657 tests in 886.721s, FAILED (failures=91, skipped=5), 0 errors. All 91 failures verified Godot-absent: 91 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None` (90 plain + 1 hydration proof), 0 `ERROR:` blocks, 0 non-Godot failures; the N2140 module shows no failure other than its Godot-proof test, and the N2124/N2132 modules likewise.** Gate attempt 1 (setsid, PID 12440, ~22:41) died ~22:44 at session-end (log frozen at 4878 bytes, preserved as `full-suite-n2140-gate-attempt1.log`); attempt 2 (setsid, PID 13033, ~22:45, main-thread launch) finished clean. The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule). No VM restart during this slice; javalang 0.13.0 verified present before the gate.

## Deferred

- **C07 continues** per the completion backlog: unit lifecycle/controller/pathfinding/command/weapon/death, wave/spawn/teams, map/world transition, campaign persistence. Concrete follow-ups already deferred in the tree: live per-type unit counts in the frame (the unit-group system — the pure function takes `count_type` as an input; the frame helper defaults absent counts to 0), `power.status` live read, `drones_in_position` / `spawn_occupied` / `allow_update` frame inputs, `moveOutPayload()` modeling, reconstructor `constructTime` catalog capture.
- Net readUnits/whenSyncedUnits drone sync (UnitAssembler.java:430-460) — client sync, needs the net slice.
- `units.removeAll(u -> !u.isAdded() || u.dead || !(u.controller() instanceof AssemblerAI))` (UnitAssembler.java:461) — live unit list, no port frame for it yet.
- AI perimeter arrangement (`ai.targetPos.trns(...)`, `ai.targetAngle`, UnitAssembler.java:506-513) — AssemblerAI presentation, not state.
- Live-world spawn path in `spawned()` (`unit.set`, `unit.add`, `unit.buildOn`, `acceptPayload`/`handlePayload`, `Units.notifyUnitSpawn`, UnitAssembler.java:548-563) — the pure tick records `spawned`/`consumed`/`unit_created_event` as state.
- Commandable `commandPos` branch + `createSound` + `Fx.unitAssemble` (UnitAssembler.java:549-551, 564-566) — presentation, not state.
- `Call.assemblerDroneSpawned` net call (UnitAssembler.java:488) — the pure tick records `drone_spawned` as state.
- Drone controller-not-AssemblerAI bug guard (UnitAssembler.java:479-490) — data-patch guard, deferred to a validation slice.
- `checkSolid` live collision queries + `getUnitSpawn` geometry (UnitAssembler.java:332-336, 675-681) — the pure tick takes occupancy as inputs.
- C07–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

See `handoffs/2026-11-12-c07-units-can-create-handoff.md` for the full detail.
