# Report — N2138: Reconstructor live production tick (progress advance + upgrade call)

Date: 2026-11-12. Batch: N2138 (single slice). Status: **DONE + PUSHED 2026-11-12 ~20:25 +07 (20:15 cron run). Targeted tests 4/4 OK, neighbours 16/16, Godot proof GREEN, full gate verified clean except Godot (Ran 5649, failures=89, skipped=5, 0 errors — all 89 Godot-absent asserts). Commit + push to origin main (fork Lasthope1508) this run — see handoff for the commit hashes.**

## What changed

The live tick driver (`SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state`, wired from `SourceFactoryRuntimeState.gd:192`) ran the consumption half of `updateTile` every tick and, since N2137, advanced production for `UnitFactory` frames only — its comment said "Reconstructor and UnitAssembler keep the consumption-only tick until their own production slices (N2138, N2139)". N2138 is that slice for the reconstructor: a pure `source_reconstructor_production_tick_state(frame, construct_time, has_upgrade, upgrade_unit, payload_in_position, edelta, unit_build_speed, source_delta)` — one tick of `ReconstructorBuild.updateTile()` (Reconstructor.java:317-356) — wired into the tick driver for `Reconstructor` implementations only. It advances `progress`/`time`/`speed_scl` per `progress += edelta() * state.rules.unitBuildSpeed(team)` and `time += edelta() * speedScl * state.rules.unitBuildSpeed(team)`, and at `progress >= constructTime` fires the upgrade call (`payload.unit = upgrade(payload.unit.type).create(payload.unit.team())` + `consume()` + `UnitCreateEvent`, recorded as state — no live event bus). UnitAssembler keeps the consumption-only tick until N2139. `moveOutPayload()` is NOT modeled here — a no-upgrade payload is recorded as `moved_out` state but stays in the frame until the move-out slice lands.

Two nesting facts from reading the Java in GREEN (not the RED sketch): the `if(progress >= constructTime)` completion check sits inside `moveInPayload()` but **outside** the `efficiency > 0` block (Reconstructor.java:324-348) — a frame whose progress already reached constructTime completes even on an efficiency-0 tick; and unlike UnitFactory, `time` advances even with no payload, as long as `speedScl > 0` (Reconstructor.java:355-356). The implementation follows the Java nesting.

Catalog gap flagged (not a slice bug): the block catalog does **not** capture `constructTime` in block properties for reconstructor blocks (additive-reconstructor properties list no `constructTime`, only the `upgrades` map), so the tick driver default **120.0** applies for all reconstructor blocks until a catalog slice captures it — the live tick advances an additive-reconstructor at constructTime 120.0, not its real 600. The pure function takes `construct_time` as an input and the proof drives 600 directly. The factory frame records no `pay_vector` key — the driver default `{"x": 0.0, "y": 0.0}` matches the Java default `payVector = new Vec2()` (0,0), so a frame with no recorded pay_vector reads in-position, as designed.

## Gate finding fixed (test-only, game code untouched)

Gate attempt 5 exposed 1 real failure: N2128 `test_consume_trigger_removes_only_item_rows` — its blanket `assertNotIn(consume_state)`-style count on the tick driver broke because N2138 legitimately adds a second completion-guarded consume call site in the tick driver (`SourceUnitFactoryBuildState.gd:738`, under its own `if bool(reconstructor_production.get("completed", false)):` guard, line 737), alongside the N2137 UnitFactory one (line 714, under its own guard line 713). Same class as the N2137 gate's real failure, also fixed test-only. Fix, test-only (14 lines in the N2128 test module): the assertion now expects **2** completion-guarded call sites (UnitFactory N2137 + Reconstructor N2138; UnitAssembler keeps the consumption-only tick until N2139) and asserts the second call sits under its own `get("completed", false)):` guard. Targeted re-runs after the fix: N2128 4/4 OK, N2138 4/4 OK (8/8 in 55.5s; main thread re-verified 8/8 in 50.1s).

## Proof keys (new scene, 6 keys)

New scene `C06ReconstructorProductionProof` (additive-reconstructor frame, dagger -> mace, constructTime 600 — deterministic, no tick-driver timing), prefix `C_06_RECONSTRUCTOR_PRODUCTION_PROOF `:

- `reconstructor_progress_advances`: efficiency 1.0, has_upgrade true, payload_in_position true, edelta 1.0 → progress 0 → 1.0, constructing true.
- `reconstructor_time_advances`: speed_scl 1.0, edelta 1.0 → time 0 → 1.0 (speedScl stays 1.0, time uses the new speedScl).
- `reconstructor_no_payload_no_progress`: payload null → constructing false, progress 0, speed_scl lerps toward 0 (1.0 → 0.95 at source_delta 1.0); time advances with the lerped speedScl (0 → 0.95).
- `reconstructor_not_in_position_no_progress`: payload present, has_upgrade true, payload_in_position false → progress 0, valid false, speed_scl 1.0 → 0.95, completed false.
- `reconstructor_completes_upgrade`: progress 599.5 + edelta 1.0 = 600.5 ≥ 600 → completed true, payload unit mace, progress fmod → 0.5, consumed true, unit_created_event true.
- `reconstructor_no_upgrade_moves_out`: has_upgrade false → moved_out true, progress unchanged, constructing false, completed false.

## Verified numbers (measured in this VM)

- Test module `test_c06_reconstructor_production_tick.py`: **4/4 OK in 15.8s** (Godot on PATH) — registration (ledger N2138, 6 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (6 new symbols + 34 exprs over Reconstructor.java + PayloadBlock.java + BuildingComp.java + Rules.java, all found verbatim), source-text (pure function exists + tick driver calls it + the two quoted Java lines in the function comment + no "Reconstructor and UnitAssembler keep the consumption-only" comment; proof has the 6 new keys), and the Godot proof test (6 new keys, all true, `matches: true`).
- RED run (18:30 cron run): 4 tests in 1.259s, FAILED (failures=2, errors=2), all expected — registration `KeyError: 'N2138'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure function did not exist yet), proof returncode 1 (proof scene did not exist yet).
- Neighbours (Godot on PATH): **16/16 OK in 98.8s** — `test_unit_factory_should_consume` (N2124) + `test_c06_power_should_consume` (N2136) + `test_c06_unit_factory_production_tick` (N2137) + `test_unit_factory_live_loop` (N2109). No change needed, as designed.
- `git diff --check` clean.
- SSOT +6/+1/+1/+2 → **11276 / 1589 / 1508 / 2807**; audit stays 1335.

## Gate / suite

- Test modules standalone: N2138 4/4 (proof green, see above); N2128 4/4 after the test-only gate fix.
- Godot proof: **GREEN 2026-11-12 ~18:55 +07** — 6 new keys all true, `matches: true` (9 keys total incl. registry_valid + one_headquarter_per_ssot), on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- Full Python suite, inclusive gate with the N2138 module (log `tools/mindustry_godot_transpiler/full-suite-n2138-gate.log`, 209 modules): **FINISHED ~20:19 +07, VERIFIED clean except Godot in the 20:15 cron run — Ran 5649 tests in 1678.341s, FAILED (failures=89, skipped=5), 0 errors. All 89 failures verified Godot-absent: 89 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None`, 0 `ERROR:` blocks, 0 non-Godot failures; the N2138 module shows no failure other than its Godot-proof test, and the N2128 module likewise.** Attempt 1 died ~18:52 at session-end (log frozen 3437 bytes, preserved as `full-suite-n2138-gate-attempt1-dead.log`); attempt 2 died ~19:03 at session-end (log frozen 3449 bytes, preserved as `full-suite-n2138-gate-attempt2.log`); attempt 3 died ~19:08 in a VM restart (log frozen 5008 bytes, preserved as `full-suite-n2138-gate-attempt3-dead.log`; the restart wiped javalang — reinstalled 0.13.0 before attempt 4); attempt 4 died ~19:18 at session-end (log frozen 3437 bytes, preserved as `full-suite-n2138-gate-attempt4.log`); attempt 5 finished ~19:46 (Ran 5649, failures=90 — 89 Godot-absent + the 1 real N2128 failure, fixed test-only; log preserved as `full-suite-n2138-gate-attempt5.log`); attempt 6 (setsid, PID 5386, ~19:51, main-thread launch) finished clean. The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule).

## Deferred

- **N2139 UnitAssembler production tick** (UnitAssembler.java:429-571 — progress advance, `spawned()` call at completion, drone progress, tier/lastTier reset; intake call site `moveInPayload() && !wasOccupied`, UnitAssembler.java:500-503).
- `moveOutPayload()` transport — the production tick records `moved_out` as state but does not move a payload out; a no-upgrade payload stays in the frame until the move-out slice lands.
- `moveInPayload()` approach animation (`payVector.approach(Vec2.ZERO, payloadSpeed * delta())`, `payRotation` moveToward, PayloadBlock.java:186-196) — the pure tick takes `payload_in_position` as an input; the approach itself belongs to the payload transport slice.
- The commandable-unit command branch (`commandPos`/`command`, Reconstructor.java:337-343) and `createSound` (Reconstructor.java:345) — presentation, not state.
- `Units.canCreate` live evaluation (needs C07: live per-type unit counts + the unit cap); the assembler branch keeps reading `frame["can_create"]`, default true, until then.
- `lastTier` tracking + progress reset on tier change (UnitAssembler.java:441-447) — belongs to the UnitAssembler production/tick wiring.
- The live-loop module link/unlink call sites: `updateModules`/`removeModule` are called from `UnitAssemblerModuleBuild` link/unlink (UnitAssemblerModule.java:80-83) — the port has no live module-linking frame event yet.
- Live-loop belt enabled gate (sprite-`enabled` seam) — the pure advance function takes efficiency since N2135; the caller is the missing half.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

See `handoffs/2026-11-12-c06-reconstructor-production-tick-handoff.md` for the full detail.
