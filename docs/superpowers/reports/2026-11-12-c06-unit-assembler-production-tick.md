# Report — N2139: UnitAssembler live production tick (progress/warmup/drone advance + spawned() call)

Date: 2026-11-12. Batch: N2139 (single slice). Status: **DONE + PUSHED 2026-11-12 ~21:45 +07 (21:45 cron run). Targeted tests 4/4 OK, neighbours 20/20, Godot proof GREEN, full gate verified clean except Godot (Ran 5653, failures=90, skipped=5, 0 errors — all 90 Godot-absent asserts). Commit + push to origin main (fork Lasthope1508) this run — see handoff for the commit hashes.**

## What changed

The live tick driver (`SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state`, wired from `SourceFactoryRuntimeState.gd:192`) ran the consumption half of `updateTile` every tick and, since N2137/N2138, advanced production for `UnitFactory` and `Reconstructor` frames — its comment said "UnitAssembler keeps the consumption-only tick until its own production slice (N2139)". N2139 is that slice and closes the three factory-family production ticks: a pure `source_unit_assembler_production_tick_state(frame, plan, drones_created, drone_construct_time, payload_in_position, spawn_occupied, spawn_visual_occupied, in_position_count, allow_update, can_create, power_status, edelta, unit_build_speed, source_delta)` — one tick of `UnitAssemblerBuild.updateTile()` (UnitAssembler.java:429-571) — wired into the tick driver for `UnitAssembler` implementations only (call site `SourceUnitFactoryBuildState.gd:778`). It runs the tier reset (`lastTier -2 → -1` on the first tick, progress reset only when `lastTier >= 0`), the power/drone warmups, the drone spawn gate (`droneProgress += delta() * unitBuildSpeed * powerStatus / droneConstructTime >= 1f`), the `moveInPayload() && !wasOccupied` intake call site (calls the N2131 intake state), the spawn-occupancy warmups, and the production advance `progress += edelta() * state.rules.unitBuildSpeed(team) * eff / plan.time` — at `progress >= 1f` the `spawned()` call fires (`consume()` + `blocks.clear()` + `UnitCreateEvent`, recorded as state — no live event bus). Both stale comments are updated: production is live for all three factory-family implementations. `moveOutPayload()` is NOT modeled here — a completed payload stays in the frame until the move-out slice lands.

The N2128 blanket-assert test needed its test-only update in GREEN (same class as the N2137/N2138 gate findings, but caught before the gate this time): the assertion now expects **3** completion-guarded consume call sites (UnitFactory N2137 + Reconstructor N2138 + UnitAssembler N2139), each under its own `get("completed", false)):` guard; game code untouched. The gate finished with zero real failures, so no gate-time fix was needed.

Catalog gaps flagged (not slice bugs): the block catalog does **not** capture `dronesCreated` / `droneConstructTime` in block properties for assembler blocks, so the driver defaults **4 / 240.0** apply until a catalog slice captures them. The frame records no `drones_in_position` — the driver defaults **0**, so `eff` is 0 and no progress accrues until a drone-position slice lands (flagged, not silently defaulted to "all in position"). The frame records no `spawn_occupied` / `spawn_visual_occupied` (live `checkSolid` has no port yet) — the driver defaults false ("spawn free"). The frame records no `allow_update` (default true) and no `power_status` (null → 1.0).

## Proof keys (new scene, 6 keys)

New scene `C06UnitAssemblerProductionProof` (assembler frame, plan `{unit: "mace", time: 60.0}`, drones_created 4, drone_construct_time 240.0 — deterministic, no tick-driver timing), prefix `C_06_UNIT_ASSEMBLER_PRODUCTION_PROOF `:

- `assembler_progress_advances`: efficiency 1.0, can_create true, not occupied, 4/4 drones in position, edelta 1.0 → progress 0 → 1/60, warmup lerps toward 1.0.
- `assembler_tier_change_resets_progress`: last_tier 0, current_tier 1, progress 5.0 → progress 0, last_tier 1.
- `assembler_drone_spawns`: units_count 3, drone_progress 239.0, source_delta 240.0 → drone_progress 239.0 + 240*1*1/240 = 240.0 ≥ 1 → drone_spawned true, drone_progress 0, units_count 4.
- `assembler_intake_yeets_payload`: payload present, payload_in_position true, was_occupied false → payload null, blocks gained the payload content.
- `assembler_completes_spawn`: progress 0.99, plan.time 1.0, edelta 1.0, eff 1.0 → progress 1.99 ≥ 1 → completed true, spawned true, progress 0, blocks cleared, consumed true, unit_created_event true.
- `assembler_occupied_no_progress`: spawn_occupied true → progress unchanged, warmup lerps toward 0, completed false.

## Verified numbers (measured in this VM)

- Test module `test_c06_unit_assembler_production_tick.py`: **4/4 OK in 17.6s** (Godot on PATH, 21:15 cron run) — registration (ledger N2139, 6 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (6 new symbols + 45 exprs over UnitAssembler.java + PayloadBlock.java + BuildingComp.java + Rules.java, all found verbatim), source-text (pure function exists + tick driver calls it + the two quoted Java lines in the function comment + no "UnitAssembler keeps the consumption-only" comment; proof has the 6 new keys), and the Godot proof test (6 new keys, all true, `matches: true`). Main thread re-verified **8/8 OK in 25.1s** (N2139 4/4 + N2128 4/4).
- RED run (20:30 cron run): 4 tests in 1.460s, FAILED (failures=2, errors=2), all expected — registration `KeyError: 'N2139'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure function did not exist yet), proof returncode 1 (proof scene did not exist yet).
- Neighbours (Godot on PATH): **20/20 OK in 84.7s** — `test_unit_factory_should_consume` (N2124) + `test_c06_unit_assembler_payload_should_consume` (N2132) + `test_c06_unit_factory_production_tick` (N2137) + `test_c06_reconstructor_production_tick` (N2138) + `test_c06_unit_factory_consume_trigger` (N2128). No change needed except the N2128 test-only call-site count, as designed.
- `git diff --check` clean.
- SSOT +6/+1/+1/+2 → **11282 / 1590 / 1509 / 2809**; audit stays 1335.

## Gate / suite

- Test modules standalone: N2139 4/4 (proof green, see above); N2128 4/4 after the test-only call-site update.
- Godot proof: **GREEN 2026-11-12 ~21:15 +07** — 6 new keys all true, `matches: true` (9 keys total incl. registry_valid + one_headquarter_per_ssot), on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- Full Python suite, inclusive gate with the N2139 module (log `tools/mindustry_godot_transpiler/full-suite-n2139-gate.log`, 210 modules): **FINISHED ~21:35 +07, VERIFIED clean except Godot in the 21:45 cron run — Ran 5653 tests in 907.076s, FAILED (failures=90, skipped=5), 0 errors. All 90 failures verified Godot-absent: 90 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None` (89 plain + 1 hydration proof), 0 `ERROR:` blocks, 0 non-Godot failures; the N2139 module shows no failure other than its Godot-proof test, and the N2128 module likewise.** Single attempt (setsid, PID 2810, ~21:20, main-thread launch) finished clean — no session-end death, no real failure. The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule). A VM restart ~21:08 wiped javalang — reinstalled 0.13.0 before the gate launch.

## Deferred

- **C07–C12** per the completion backlog. C06's factory → core → defense vertical closes with the three production ticks live (N2137 + N2138 + N2139).
- `moveOutPayload()` transport — the production tick records completion as state but does not move a payload out; a completed payload stays in the frame until the move-out slice lands.
- `moveInPayload()` approach animation (`payVector.approach(Vec2.ZERO, payloadSpeed * delta())`, `payRotation` moveToward, PayloadBlock.java:186-196) — the pure tick takes `payload_in_position` as an input; the approach itself belongs to the payload transport slice.
- Net readUnits/whenSyncedUnits drone sync (UnitAssembler.java:430-460) — client sync, needs the net slice.
- `units.removeAll(u -> !u.isAdded() || u.dead || !(u.controller() instanceof AssemblerAI))` (UnitAssembler.java:461) — live unit list, no port frame for it yet.
- AI perimeter arrangement (`ai.targetPos.trns(...)`, `ai.targetAngle`, UnitAssembler.java:506-513) — AssemblerAI presentation, not state.
- Live-world spawn path in `spawned()` (`unit.set`, `unit.add`, `unit.buildOn`, `acceptPayload`/`handlePayload`, `Units.notifyUnitSpawn`, UnitAssembler.java:548-563) — the pure tick records `spawned`/`consumed`/`unit_created_event` as state.
- Commandable `commandPos` branch + `createSound` + `Fx.unitAssemble` (UnitAssembler.java:549-551, 564-566) — presentation, not state.
- `Call.assemblerDroneSpawned(tile)` net call (UnitAssembler.java:488) — the pure tick records `drone_spawned` as state.
- Drone controller-not-AssemblerAI bug guard (UnitAssembler.java:479-490) — data-patch guard, deferred to a validation slice.
- `checkSolid` live collision queries + `getUnitSpawn` geometry (UnitAssembler.java:332-336, 675-681) — the pure tick takes occupancy as inputs.
- `Units.canCreate` live evaluation (needs C07: live per-type unit counts + the unit cap); the assembler branch keeps reading `frame["can_create"]`, default true, until then.
- `power.status` live read — the driver folds `frame["power_status"]` (null → 1.0) until a power-status slice lands.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

See `handoffs/2026-11-12-c06-unit-assembler-production-tick-handoff.md` for the full detail.
