# Report — N2136: unit-factory shouldConsume wiring to the power stamp

Date: 2026-11-12. Batch: N2136 (single slice). Status: **DONE + PUSHED 2026-11-12 ~16:45 +07 (16:45 cron run). Targeted tests 4/4 OK, neighbours 12/12, Godot proof GREEN, full gate verified clean except Godot (Ran 5641, failures=87, skipped=5, 0 errors — all 87 Godot-absent asserts). Commit + push to origin main (fork Lasthope1508) this run — see handoff for the commit hash.**

## What changed

N2124 modeled the unit-factory family's per-class `shouldConsume()` bodies, but the power stamp (`SourcePlacedPowerGraphState.source_consumer_should_consume_for_cell_state`, N2125) kept reading the unit-factory frame's `enabled` flag only — the stamp's own comment named the gap: "The other families keep the enabled-only read: their per-class shouldConsume bodies (UnitFactory plans, N2124) are not wired to the stamp yet." A plan-less ground factory, a payload-less reconstructor, or a blocks-less assembler therefore kept charging power in the graph, while `ConsumePower.requestedPower` (ConsumePower.java:56-60) charges `usage * (entity.shouldConsume() ? 1f : 0f)`.

N2136 is that wiring: the stamp calls `source_unit_factory_should_consume_state` (N2124) for the unit-factory frame — the same pattern as the factory and adjacent-factory branches already in the stamp — so the graph reads the per-class body instead of the frame's `enabled` flag. No new symbol, contract, or schema: the wiring makes the already-registered `source_unit_factory_should_consume_state_result.should_consume` (N2124) live. The registry symbol's rule now records that the power stamp reads it live (N2136), and its tests grow 4 → 8. The remaining families (drill, turret, continuous-liquid-turret) keep the enabled-only read because their shouldConsume IS the Building default (`return enabled;`, BuildingComp.java:755-757).

## Proof keys (same scene, 5 new keys)

Placed live after the re-enabled section, on cells Vector2i(30, 7), (35, 7), (40, 7) — the same cells the should-consume proof uses on this Main scene. The helper calls alone run no power step, so the factories' power usage cannot leak into the earlier keys.

- `stamp_unit_factory_no_plan_false`: ground-factory frame `current_plan = -1`, enabled → helper `should_consume == false`, `found == true`.
- `stamp_unit_factory_plan_true`: same frame with `current_plan = 0` → `should_consume == true`.
- `stamp_unit_factory_disabled_false`: plan 0 + `enabled = false` → `should_consume == false`.
- `stamp_unit_reconstructor_no_payload_false`: reconstructor frame, no payload → `should_consume == false`.
- `stamp_unit_assembler_default_false`: assembler frame, no `blocks` → `should_consume == false` (payload_efficiency 0.0 via the N2129 module, N2132 wiring).

## Verified numbers (measured in this VM)

- Test module `test_c06_unit_factory_should_consume_power_stamp.py`: **4/4 OK in 58.1s** (Godot on PATH) — registration (ledger N2136, 1 reused symbol, runtime proof, test names, deferred_exprs), exact-evidence (1 reused symbol + 12 exprs over UnitFactory.java + Reconstructor.java + UnitAssembler.java + ConsumePower.java + BuildingComp.java, all found verbatim), source-text (stamp preloads the unit-factory state + the branch calls `source_unit_factory_should_consume_state(frame, block, game)`; no "are not wired to the stamp yet" comment; proof has the 5 new keys), and the Godot proof test (5 new keys, all true, `matches: true`).
- RED run (16:00 cron run): 4 tests in 57.3s, FAILED (failures=1, errors=7), all expected — registration `KeyError: 'N2136'`, evidence errors on the missing ledger entry, source-text `AssertionError` (stamp did not preload/call the unit-factory state yet), proof 5 subTest `KeyError`s (new keys not emitted yet; the old scene still ran green on its old keys).
- Neighbours (sequential, Godot on PATH): **8/8 OK in 70.4s** — `test_c06_power_should_consume` (N2125) + `test_unit_factory_should_consume` (N2124). Total with targeted: **12/12**. No port-7777 collision (sequential run, per the known lesson).
- `git diff --check` clean.
- SSOT +0/+1/+0/+0 → **11265 / 1587 / 1506 / 2803**; audit stays 1335.

## Gate / suite

- Test modules standalone: N2136 4/4 (proof green, see above).
- Godot proof: **GREEN 2026-11-12 ~16:20 +07** — 5 new keys all true, `matches: true`, on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- Full Python suite, inclusive gate with the N2136 module (log `tools/mindustry_godot_transpiler/full-suite-n2136-gate.log`, 213 modules): **FINISHED ~16:40 +07, VERIFIED clean except Godot in the 16:45 cron run — Ran 5641 tests in 916.943s, FAILED (failures=87, skipped=5), 0 errors. All 87 failures verified Godot-absent: 86 plain `assertIsNotNone(godot)` + 1 hydration test (`Godot required for hydration proof`); every `AssertionError` in the log is `unexpectedly None`, no other failure type, 0 ERROR lines.** Attempt 1 (setsid, PID 9937, ~16:2x) died at session-end with the log frozen at 3487 bytes (preserved as `full-suite-n2136-gate-attempt1.log`); attempt 2 (setsid, PID 10185, ~16:25) finished clean. The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule).

## Deferred

- **Live production wiring:** the tick driver advances no progress and calls no `spawned()` yet — UnitFactory progress (UnitFactory.java:401-403), Reconstructor progress (Reconstructor.java:330-348) and UnitAssembler `spawned()` (UnitAssembler.java:544-571) are the production slice; the intake call site (`moveInPayload() && !wasOccupied`, UnitAssembler.java:500-503) is the wiring that calls the intake slice when a payload arrives.
- `Units.canCreate` live evaluation (needs C07: live per-type unit counts + the unit cap); the assembler branch keeps reading `frame["can_create"]`, default true, until then.
- `lastTier` tracking + progress reset on tier change (UnitAssembler.java:441-447) — belongs to the live production/tick wiring.
- The live-loop module link/unlink call sites: `updateModules`/`removeModule` are called from `UnitAssemblerModuleBuild` link/unlink (UnitAssemblerModule.java:80-83) — the port has no live module-linking frame event yet.
- Live-loop belt enabled gate (sprite-`enabled` seam) — the pure advance function takes efficiency since N2135; the caller is the missing half.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

See `handoffs/2026-11-12-c06-unit-factory-should-consume-power-stamp-handoff.md` for the full detail.
