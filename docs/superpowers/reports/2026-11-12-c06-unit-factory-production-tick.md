# Report — N2137: UnitFactory live production tick (progress advance + completion call)

Date: 2026-11-12. Batch: N2137 (single slice). Status: **DONE + PUSHED 2026-11-12 ~18:15 +07 (18:15 cron run). Targeted tests 4/4 OK, neighbours 8/8, Godot proof GREEN, full gate verified clean except Godot (Ran 5645, failures=88, skipped=5, 0 errors — all 88 Godot-absent asserts). Commit + push to origin main (fork Lasthope1508) this run — see handoff for the commit hashes.**

## What changed

The live tick driver (`SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state`, wired from `SourceFactoryRuntimeState.gd:192`) ran the consumption half of `updateTile` every tick but advanced no progress and called no completion — its own comment said "a later slice that ticks production reads it". N2137 is that slice for the ground factory: a pure `source_unit_factory_production_tick_state(frame, plan, plans_count, edelta, unit_build_speed, source_delta)` — one tick of `UnitFactoryBuild.updateTile()` (UnitFactory.java:392-442) — wired into the tick driver for `UnitFactory` implementations only. It advances `progress`/`time`/`speed_scl` per `progress += edelta() * Vars.state.rules.unitBuildSpeed(team)` and `time += edelta() * speedScl * Vars.state.rules.unitBuildSpeed(team)`, and at `progress >= plan.time` fires the completion call (`payload = new UnitPayload(unit)` + `consume()` + `UnitCreateEvent`, recorded as state — no live event bus). Reconstructor and UnitAssembler keep the consumption-only tick until their own production slices (N2138, N2139). `moveOutPayload()` is NOT modeled here — a payload created last tick stays in the frame, so the next tick's `payload != null` branch resets `progress = 0` until the move-out slice lands.

## Gate finding fixed (test-only, game code untouched)

Gate attempt 2 exposed 1 real failure: N2128 `test_consume_trigger_removes_only_item_rows` — its blanket `assertNotIn(consume_state)` on the tick driver broke because N2137 legitimately calls the consume trigger from the tick driver, but only under the `completed` guard, faithful to `UnitFactory.java:392-442` (`consume()` after `payload = new UnitPayload(unit)`). Fix, test-only (10 lines in the N2128 test module): the assertion now requires the call to appear exactly once and only after the `if bool(production.get("completed", false)):` guard — a stronger assertion than the old blanket one. Targeted re-runs after the fix: N2128 4/4 OK, N2137 4/4 OK.

## Proof keys (new scene, 5 keys)

New scene `C06UnitFactoryProductionProof` (dagger plan, 900 ticks — deterministic, no tick-driver timing), prefix `C_06_UNIT_FACTORY_PRODUCTION_PROOF `:

- `production_progress_advances`: efficiency 1.0, plan 0, edelta 1.0 → progress 0 → 1.0.
- `production_time_advances`: speed_scl 1.0, edelta 1.0 → time 0 → 1.0.
- `production_no_plan_no_progress`: current_plan -1 → progress unchanged, speed_scl lerps toward 0 (1.0 → 0.95 at source_delta 1.0).
- `production_completes_payload`: progress 899.5 + edelta 1.0 = 900.5 ≥ 900 → completed true, payload unit dagger, progress fmod → 0.5 then clamp → 0.5, consumed true.
- `production_payload_present_resets_progress`: payload present → progress 0.

## Verified numbers (measured in this VM)

- Test module `test_c06_unit_factory_production_tick.py`: **4/4 OK in 14.2s** (Godot on PATH) — registration (ledger N2137, 5 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (5 new symbols + 25 exprs over UnitFactory.java + Rules.java + BuildingComp.java + UnitType.java, all found verbatim), source-text (pure function exists + tick driver calls it + the two quoted Java lines in the function comment + no "a later slice that ticks production reads it" comment; proof has the 5 new keys), and the Godot proof test (5 new keys, all true, `matches: true`).
- RED run (16:45 cron run): 4 tests in 1.018s, FAILED (failures=2, errors=2), all expected — registration `KeyError: 'N2137'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure function did not exist yet), proof returncode 1 (proof scene did not exist yet).
- Neighbours (Godot on PATH): **8/8 OK** — `test_c06_power_should_consume` (N2136) + `test_unit_factory_live_loop` (N2109). Total with targeted: **12/12**. (One main-thread re-run showed the proof content all true with the single failure being ONLY a port-7777 bind ERROR from a concurrently-running neighbour proof scene — environmental, not a slice regression; no proof scene was run while the gate ran.)
- `git diff --check` clean.
- SSOT +5/+1/+1/+2 → **11270 / 1588 / 1507 / 2805**; audit stays 1335.

## Gate / suite

- Test modules standalone: N2137 4/4 (proof green, see above); N2128 4/4 after the test-only gate fix.
- Godot proof: **GREEN 2026-11-12 ~17:00 +07** — 5 new keys all true, `matches: true`, on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- Full Python suite, inclusive gate with the N2137 module (log `tools/mindustry_godot_transpiler/full-suite-n2137-gate.log`, 213 modules): **FINISHED ~18:08 +07, VERIFIED clean except Godot in the 18:15 cron run — Ran 5645 tests in 1082.282s, FAILED (failures=88, skipped=5), 0 errors. All 88 failures verified Godot-absent: every `AssertionError` in the log is `unexpectedly None` (87 plain `assertIsNotNone(godot)` + 1 hydration), 0 ERROR lines; the N2128 module shows no failure other than its Godot-proof test.** Attempt 1 died ~17:15 at session-end (log frozen 2793 bytes, preserved as `full-suite-n2137-gate-attempt1.log`); attempt 2 finished ~17:45 (Ran 5645, failures=89 — 88 Godot-absent + the 1 real N2128 failure, fixed test-only; log preserved as `full-suite-n2137-gate-attempt2.log`); attempt 3 died ~17:49 at session-end (log frozen 3433 bytes, preserved as `full-suite-n2137-gate-attempt3.log`); attempt 4 (setsid, PID 6018, ~17:50) finished clean. The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule).

## Deferred

- **N2138 Reconstructor production tick** (Reconstructor.java:317-356 — constructing cache, progress advance, upgrade on completion, `progress %= 1f`, `consume()`, `UnitCreateEvent`).
- **N2139 UnitAssembler production tick** (UnitAssembler.java:429-571 — progress advance, `spawned()` call at completion, drone progress, tier/lastTier reset; intake call site `moveInPayload() && !wasOccupied`, UnitAssembler.java:500-503).
- `moveOutPayload()` transport — the production tick does not move a completed payload out yet; a completed factory's next tick resets progress to 0 until the move-out slice lands.
- `Units.canCreate` live evaluation (needs C07: live per-type unit counts + the unit cap); the assembler branch keeps reading `frame["can_create"]`, default true, until then.
- `lastTier` tracking + progress reset on tier change (UnitAssembler.java:441-447) — belongs to the UnitAssembler production/tick wiring.
- The live-loop module link/unlink call sites: `updateModules`/`removeModule` are called from `UnitAssemblerModuleBuild` link/unlink (UnitAssemblerModule.java:80-83) — the port has no live module-linking frame event yet.
- Live-loop belt enabled gate (sprite-`enabled` seam) — the pure advance function takes efficiency since N2135; the caller is the missing half.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

See `handoffs/2026-11-12-c06-unit-factory-production-tick-handoff.md` for the full detail.
