# Handoff — N2136: unit-factory shouldConsume wiring to the power stamp

Date: 2026-11-12. Batch: N2136 (single slice). Status: **DONE + PUSHED 2026-11-12 ~16:45 +07 (16:45 cron run). Targeted 4/4 OK, neighbours 12/12, Godot proof GREEN. Full gate attempt 2 FINISHED ~16:40 +07 and VERIFIED clean except Godot: Ran 5641 in 916.943s, FAILED (failures=87, skipped=5), 0 errors — all 87 Godot-absent asserts (86 `assertIsNotNone(godot)` + 1 hydration). Slice commit 21142e5 + docs commit on origin main.**

## GREEN progress (16:15 cron run, 2026-11-12 ~16:15-16:30 +07)

- Register script written + run: `tools/mindustry_godot_transpiler/register_c06_unit_factory_should_consume_power_stamp.py` (modeled on the N2132 one). Ledger N2136 entry + registry symbol rule/tests update (4 N2124 → 8). SSOT **11265 / 1587 / 1506 / 2803**, audit 1335 — exactly the expected numbers (symbols unchanged, slices +1, contracts/schemas unchanged).
- Stamp implemented in `godot-mindustry/src/game/SourcePlacedPowerGraphState.gd`: preload `source_unit_factory_build_state` (preload-cycle check done: `SourceUnitFactoryBuildState.gd` preloads 13 files, none is `SourcePlacedPowerGraphState.gd` — no cycle); new branch after the adjacent-factory branch, same shape, calls `source_unit_factory_should_consume_state(frame, block, game)` and returns `should_consume` from it with `shouldConsumePower` from `frame["should_consume_power"]` (fallback `enabled`); the "are not wired to the stamp yet" comment is gone, replaced by a note that the unit-factory family is live (N2136) and the remaining families keep the enabled-only read because their shouldConsume IS the Building default (`return enabled;`, BuildingComp.java:755-757).
- Proof updated in `godot-mindustry/tools/runtime_proofs/C06PowerShouldConsumeProof.gd`: preload `unit_factory_build_state`; 5 new keys placed live after the re-enabled section (helper calls alone run no power step, so no leak into earlier keys), on cells Vector2i(30, 7), (35, 7), (40, 7) — the same cells the should-consume proof uses on this Main scene. Factory frame `current_plan` -1 → false, 0 → true, `enabled` false → false; reconstructor no payload → false; assembler no `blocks` → false.
- Targeted tests **4/4 OK in 58.1s** (Godot on PATH) — registration, exact-evidence (1 reused symbol + 12 exprs), source-text, Godot proof test (5 new keys, all true, `matches: true`, returncode 0, no `ERROR:`).
- Neighbours (sequential, Godot on PATH): **8/8 OK in 70.4s** — `test_c06_power_should_consume` (N2125) + `test_unit_factory_should_consume` (N2124). Total with targeted: **12/12**.
- `git diff --check` clean.
- Full gate LAUNCHED ~16:2x +07: `setsid nohup python3 -m unittest discover -s tests > full-suite-n2136-gate.log 2>&1` from `tools/mindustry_godot_transpiler` (no Godot on PATH — the established gate pattern). Verified detached: PID 9937, SID 9937 (own session), log growing (3426 bytes of dots at +36s). Expected Ran ~5641, FAILED (failures=87, skipped=5), 0 errors — all 87 `assertIsNotNone(godot)` (86 inherited + the new N2136 proof test).
- **Full gate attempt 1 DIED ~16:24 +07** (same session-end signature as N2133 attempts 1/2/4 and N2134 attempt 1): PID 9937 gone, no python/unittest process left, log frozen at 3487 bytes (last write 16:24:32 +07). Frozen log preserved as `full-suite-n2136-gate-attempt1.log`. Note: it died even though the worker reported it "detached" (PID 9937, SID 9937, own session, log growing at +36s) — the cron worker's launch does NOT survive the worker's session ending.
- **Full gate attempt 2 FINISHED ~16:40 +07 and VERIFIED in the 16:45 cron run (PID 10185 gone, log complete at 60614 bytes): Ran 5641 tests in 916.943s, FAILED (failures=87, skipped=5), 0 errors — all 87 verified Godot-absent (86 plain `assertIsNotNone(godot)` + 1 hydration `Godot required for hydration proof`; every `AssertionError` in the log is `unexpectedly None`, 0 ERROR lines). Gate clean except Godot — commit/push condition met.** Do NOT run proof scenes while a gate runs (port-7777 bind ERROR fails proof tests).

## RED progress (16:00 cron run, 2026-11-12 ~16:00-16:15 +07)

- State at RED time: main at e582770 (N2135 merged + pushed to the fork 2026-11-12 ~15:49); working tree clean except untracked `*.gd.uid` files (never stage) and untracked gate logs (pre-existing env noise, not this slice).
- javalang 0.13.0 present (no VM restart since the 15:15 run); Godot 4.6.2 present (`~/workspace/godot-bin/godot`; `godot` is NOT on the default PATH — targeted runs must `export PATH="$HOME/workspace/godot-bin:$PATH"`).
- Test module written: `tools/mindustry_godot_transpiler/tests/test_c06_unit_factory_should_consume_power_stamp.py` (4 tests). RED run (Godot on PATH): **Ran 4 tests in 57.3s, FAILED (failures=1, errors=7)** — all expected:
  - registration `KeyError: 'N2136'` (ledger entry not written yet);
  - evidence errors on the missing ledger entry (same KeyError);
  - source-text `AssertionError`: `source_unit_factory_build_state` not found in `SourcePlacedPowerGraphState.gd` (the preload + branch do not exist yet);
  - proof: 5 subTest `KeyError`s, one per new key (`stamp_unit_factory_no_plan_false`, `stamp_unit_factory_plan_true`, `stamp_unit_factory_disabled_false`, `stamp_unit_reconstructor_no_payload_false`, `stamp_unit_assembler_default_false`) — the old proof scene itself still runs green (returncode 0, no `ERROR:`, its old keys match), the new keys are simply not emitted yet.
- `git diff --check` clean (no tracked changes yet — only the new untracked test module).

## What this batch is

The wiring half of the unit-factory shouldConsume work, the next item on the N2135 "Next" list: the power stamp `source_consumer_should_consume_for_cell_state` (`SourcePlacedPowerGraphState.gd`) stops reading the unit-factory frame's `enabled` flag only and calls the family's per-class shouldConsume (`source_unit_factory_should_consume_state`, N2124) for the unit-factory frame — the same pattern as the factory and adjacent-factory branches already in the stamp. A plan-less ground factory, a payload-less reconstructor, or a blocks-less assembler then reads `should_consume == false` from the graph, which is the `entity.shouldConsume()` factor `ConsumePower.requestedPower` charges (`usage * (entity.shouldConsume() ? 1f : 0f)`). The stamp's own comment names this exact gap: "The other families keep the enabled-only read: their per-class shouldConsume bodies (UnitFactory plans, N2124) are not wired to the stamp yet."

## Exact upstream evidence (all 12 exprs verified verbatim in this VM)

- `UnitFactoryBuild.shouldConsume()` (UnitFactory.java:445-448): `public boolean shouldConsume(){` / `if(currentPlan == -1) return false;` / `return enabled && payload == null && team.activateUnitFactories();`
- `ReconstructorBuild.shouldConsume()` (Reconstructor.java:367-369): `public boolean shouldConsume(){` / `return constructing && enabled && team.activateUnitFactories();`
- `UnitAssemblerBuild.shouldConsume()` (UnitAssembler.java:389-391): `public boolean shouldConsume(){` / `return enabled && !wasOccupied && Units.canCreate(team, plan().unit) && consPayload.efficiency(this) > 0 && consItem.efficiency(this) > 0 && team.activateUnitFactories();`
- `ConsumePower.requestedPower` (ConsumePower.java:56-60): `public float requestedPower(Building entity){` / `usage * (entity.shouldConsume() ? 1f : 0f)`
- `BuildingComp.shouldConsume()` (BuildingComp.java:755-757): `public boolean shouldConsume(){` / `return enabled;`
- The disabled branch (BuildingComp.java:1952-1956): `if(!enabled){` / `potentialEfficiency = efficiency = optionalEfficiency = 0f;` / `shouldConsumePower = false;`
- The first-pass flag (BuildingComp.java:1971-1974): `if(cons != block.consPower && result <= 0.0000001f){` — a non-power consumer at ~0 efficiency clears `shouldConsumePower`, the stamp's second key.

## Design (decided in RED, implement in GREEN)

- **No new symbols, no new contracts, no new schemas.** The wiring adds no new function, registry const, or return key: `source_consumer_should_consume_for_cell_state` (N2125) and `source_unit_factory_should_consume_state` (N2124) already exist, and `should_consume` is already a stamp return key. The ledger entry N2136 therefore lists the ONE symbol this slice makes live — `source_unit_factory_should_consume_state_result.should_consume` — which already exists in the registry (N2124). This is allowed: `validate_source_slice_ledger` requires `source_symbols` non-empty, and precedent exists for symbols shared across slices (N1084/N1085 share 5 symbols; N2132 reused `payload_efficiency` the same way). Expected SSOT after GREEN: **11265 / 1587 / 1506 / 2803** (symbols unchanged, slices +1, contracts/schemas unchanged); audit stays 1335.
- Ledger N2136 entry: `status: done`, `java_source: core/src/mindustry/world/blocks/units/UnitFactory.java`, `java_class: mindustry.world.blocks.units.UnitFactory.UnitFactoryBuild`, `java_method: UnitFactoryBuild.shouldConsume()`, `godot_owner: SourcePlacedPowerGraphState.source_consumer_should_consume_for_cell_state`, `exact_exprs`: the 12 exprs above, `source_symbols`: the 1 reused symbol, `tests`: the 4 test names of the new module, `runtime_proof: /root/C06PowerShouldConsumeProof`, `deferred_exprs`: live production wiring, Units.canCreate live evaluation, lastTier/progress reset, module link/unlink call sites, live-loop belt enabled gate, C06–C12 open.
- Register script `register_c06_unit_factory_should_consume_power_stamp.py` (GREEN, modeled on the N2132 one): writes the ledger N2136 entry and updates the registry symbol `source_unit_factory_should_consume_state_result.should_consume` — its `rule` currently says only "The per-class body for this frame and block: ..." → extend it to record that the power stamp reads it live (N2136); append the 4 N2136 test names to its `tests` (4 N2124 → 8). Verify SSOT totals 11265 / 1587 / 1506 / 2803, audit 1335.
- Gate wiring in `SourcePlacedPowerGraphState.gd`, inside `source_consumer_should_consume_for_cell_state`:
  - Add the preload next to the other family preloads: `const source_unit_factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")`. **GREEN check: verify no preload cycle** — `SourceUnitFactoryBuildState.gd` must not preload `SourcePlacedPowerGraphState.gd` (it preloads `SourcePlacedBlockState` and others; confirm before adding).
  - New branch after the adjacent-factory branch, before the enabled-only fallthrough (same shape as the two branches above it):
    ```gdscript
    if meta_key == source_unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY:
        var block: Variant = default_callbacks_state(game).get("block_from_sprite", Callable()).call(sprite)
        var should: Dictionary = source_unit_factory_build_state.source_unit_factory_should_consume_state(frame, block, game)
        return {"should_consume": bool(should.get("should_consume", enabled)), "shouldConsumePower": bool(frame.get("should_consume_power", enabled)), "found": true, "reason": "live_frame"}
    ```
  - Update the deferred comment in the stamp ("The other families keep the enabled-only read: their per-class shouldConsume bodies (UnitFactory plans, N2124) are not wired to the stamp yet."): the unit-factory family is now live (N2136); the remaining families (drill, turret, continuous-liquid-turret) keep the enabled-only read because their shouldConsume IS the Building default (`return enabled;`, BuildingComp.java:755-757).
- Proof updates in `godot-mindustry/tools/runtime_proofs/C06PowerShouldConsumeProof.gd` (same scene, no new `.tscn`; proof JSON is gitignored, never stage it). Proof keys grow by 5 — place the three factories live **after the re-enabled section** (after the last `_power_step` call, so the baseline/disabled/re-enabled keys are untouched; the helper calls alone run no power step, so the factories' power usage cannot leak into earlier keys), using the same `record_placed_block` pattern as `C06UnitFactoryShouldConsumeProof.gd` (cells Vector2i(30, 7), (35, 7), (40, 7) are free in the scenario — verify in GREEN; the should-consume proof uses them on the same Main scene):
  - `stamp_unit_factory_no_plan_false`: ground-factory frame `current_plan = -1`, enabled → helper `should_consume == false`, `found == true`.
  - `stamp_unit_factory_plan_true`: same frame with `current_plan = 0` → `should_consume == true`.
  - `stamp_unit_factory_disabled_false`: plan 0 + `enabled = false` → `should_consume == false`.
  - `stamp_unit_reconstructor_no_payload_false`: reconstructor frame, no payload → `should_consume == false`.
  - `stamp_unit_assembler_default_false`: assembler frame, no `blocks` → `should_consume == false` (payload_efficiency 0.0 via the N2129 module, N2132 wiring).
  - GREEN check: the gate resolves the implementation from `block` (`block_from_sprite` on the live sprite) or the frame's `block_implementation` — confirm the placed frames carry what the gate needs (the should-consume proof sets only `current_plan`/`items`/`payload` and the gate works there because `record_placed_block` binds the frame; the stamp passes the resolved `block`, so the same path applies).
- The N2125 test module needs NO change (its assertions — meta keys present, `enabled` read, factory-branch call — all still hold; the new branch adds nothing it asserts on). Verify in GREEN by running it.
- The gate's `should_consume` formula itself is unchanged — only the unit-factory input changes source, from the frame `enabled` flag to the N2124 per-class bodies.

## Files changed (RED only)

- `tools/mindustry_godot_transpiler/tests/test_c06_unit_factory_should_consume_power_stamp.py` (new, 4 tests): registration (ledger N2136, 1 reused symbol, runtime proof, test names, deferred_exprs), exact-evidence (1 reused symbol + 12 exprs over UnitFactory.java + Reconstructor.java + UnitAssembler.java + ConsumePower.java + BuildingComp.java), source-text (stamp preloads the unit-factory state + the branch calls `source_unit_factory_should_consume_state(frame, block, game)`; no "are not wired to the stamp yet" comment; proof has the 5 new keys), Godot proof (`C06PowerShouldConsumeProof.tscn`, prefix `C_06_POWER_SHOULD_CONSUME_PROOF `, the 5 new keys true).

## Verified numbers (do not re-derive, these are measured in this VM)

- RED run: **4 tests in 57.3s, FAILED (failures=1, errors=7), all expected** — registration `KeyError: 'N2136'`, evidence errors on the missing ledger entry, source-text `AssertionError` (stamp does not preload/call the unit-factory state yet), proof 5 subTest `KeyError`s (new keys not emitted yet; the old scene still runs green on its old keys).
- Exact-expr pre-check: **12/12 exprs found verbatim** in the 5 slice sources (UnitFactory.java, Reconstructor.java, UnitAssembler.java, ConsumePower.java, BuildingComp.java).
- `git diff --check` clean.
- State at RED time: main at e582770 (N2135 merged + pushed to the fork 2026-11-12 ~15:49); SSOT 11265 / 1586 / 1506 / 2803; audit 1335.

## GREEN work remaining (next run)

1. ~~Write + run the register script~~ DONE (SSOT 11265 / **1587** / 1506 / 2803, audit 1335).
2. ~~Implement the stamp branch + preload + comment update~~ DONE (preload-cycle check passed).
3. ~~Update the proof keys~~ DONE (5 new keys).
4. ~~Targeted tests GREEN 4/4 + neighbours N2125 + N2124 (12/12 total)~~ DONE.
5. Full Python gate (213 modules) — **attempt 1 DIED ~16:24 +07 (session-end, log frozen 3487 bytes, preserved as `full-suite-n2136-gate-attempt1.log`); attempt 2 (setsid, PID 10185, ~16:25) FINISHED ~16:40 +07 and VERIFIED in the 16:45 cron run: Ran 5641 in 916.943s, FAILED (failures=87, skipped=5), 0 errors — all 87 Godot-absent asserts (86 `assertIsNotNone(godot)` + 1 hydration). Gate clean except Godot.**
6. ~~Godot proof GREEN (5 keys, all true, `matches: true`)~~ DONE — via the targeted proof test.
7. Report + design-spec N2136 row + Status Summary 1586→1587 + changelog row + this handoff, then commit + push to the fork (origin main) — **DONE this run (16:45 cron run), see "Commit" below.**

## Next (after N2136 lands)

- Live production wiring (progress + call at completion). Then C07–C12 per the completion backlog.

## Deferred (not this slice)

- Live production wiring: progress advance + the call at completion (UnitFactory.java:401-403, Reconstructor.java:330-348, UnitAssembler.spawned()), plus the intake call site (`moveInPayload() && !wasOccupied`, UnitAssembler.java:500-503).
- `Units.canCreate` live evaluation (needs C07: live per-type unit counts + the unit cap); the assembler branch keeps reading `frame["can_create"]`, default true, until then.
- `lastTier` tracking + progress reset on tier change (UnitAssembler.java:441-447) — belongs to the live production/tick wiring.
- The live-loop module link/unlink call sites: `updateModules`/`removeModule` are called from `UnitAssemblerModuleBuild` link/unlink (UnitAssemblerModule.java:80-83) — the port has no live module-linking frame event yet.
- Live-loop belt enabled gate (sprite-`enabled` seam) — the pure advance function takes efficiency since N2135; the caller is the missing half.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

## Commit

DONE + PUSHED 2026-11-12 ~16:45 +07 (16:45 cron run): slice commit 21142e5 (10 files) + docs commit (below) on origin main.
