# Handoff — N2130: UnitAssembler payload trigger at completion + spawned() blocks.clear()

Date: 2026-11-12. Batch: N2130 (single slice). Status: **GREEN done in this VM; test module 4/4 OK; Godot proof GREEN 2026-11-12 ~08:52 +07 (12 content keys + 2 registry keys, all true, `matches: true`, Godot 4.6.2-stable Linux); inclusive full gate landed 08:22 +07 (Ran 5617, FAILED failures=81, skipped=5, 0 errors — all 81 Godot-proof failures).** Committed on proof branch `c06-proof` (ab02c0a, joint with N2128+N2129, pushed to origin) — NOT on main yet; merge after the proof-results docs commit.

## What this batch is

The first slice on the N2129 "Next" list: the payload trigger at completion + `spawned()` `blocks.clear()`. One function, 7 symbols, SSOT +7/+1/+1/+2 (expected: 11249 / 1581 / 1503 / 2797; audit 1335 — verify in GREEN).

## Exact upstream evidence (all 17 exprs verified verbatim in this VM)

- `ConsumePayloadDynamic.trigger` (ConsumePayloadDynamic.java:34-39): `public void trigger(Building build){ float mult = multiplier.get(build); for(PayloadStack stack : payloads.get(build)){ build.getPayloads().remove(stack.item, Math.round(stack.amount * mult)); } }` — the rows are `plan().requirements` (UnitAssembler.java:158, `consume(consPayload = new ConsumePayloadDynamic((UnitAssemblerBuild build) -> build.plan().requirements));`).
- `PayloadSeq.remove(block, amount)` (PayloadSeq.java:40-42) is `add(block, -amount)` — **no clamp**: a short stack goes negative before the clear (unlike ItemModule.remove in N2128, which clamps). The port records the requested removal per stack.
- `UnitAssemblerBuild.spawned()` (UnitAssembler.java:543-571): `var plan = plan(); ... consume();` first (line 546), then the unit is created, then `progress = 0f; ... blocks.clear();` (line 571) at the end. `PayloadSeq.clear()` (PayloadSeq.java:61-64): `payloads.clear(); total = 0;`.
- `BuildingComp.consume()` (BuildingComp.java:1911-1915): `public void consume(){ for(Consume cons : block.consumers){ cons.trigger(self()); } }` — the trigger is the payload row of that consume() call; the item/liquid rows are already covered by N2128's `source_unit_factory_consume_state`.
- Multiplier is the family's `Rules.unitCost` callback (UnitAssembler.java:175, `consumeBuilder.each(c -> c.multiplier = b -> state.rules.unitCost(b.team))`, the N2097 callback); the Consume default is `b -> 1f` (Consume.java:18).

## Design (decided in RED, implement in GREEN)

- New `SourceUnitFactoryBuildState.source_unit_factory_assembler_payload_trigger_state(frame: Dictionary, plan: Dictionary) -> Dictionary`, placed next to `source_unit_factory_assembler_payload_state` (N2129).
- Reads the multiplier through `source_consume_state.source_cost_multiplier_for_block_state(frame)` like N2129 does; per requirement stack removes `int(round(float(stack.get("amount", 0)) * multiplier))` from the frame's `blocks` dict (no clamp — mirror `PayloadSeq.remove`), records it in `removed` (accumulate per item); then `blocks.clear()` unconditionally (spawned() always clears, including extra blocks beyond the plan and short/empty modules).
- Returns `{"source_owner": PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_PAYLOAD_TRIGGER_STATE, "triggered": <stacks>, "removed": {item: amount}, "cleared": true, "blocks": {}, "total": 0}`. Return keys `['triggered', 'removed', 'cleared', 'blocks', 'total']`; params `['frame', 'plan']`; 7 symbols (2 inputs + 5 outputs).
- Pure function, NOT wired into the tick driver or the shouldConsume gate — the tick never calls it; the live production wiring (progress advance + the call at completion) is a later slice.
- New registry const `PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_PAYLOAD_TRIGGER_STATE` in `SourceRuntimeOwnerUnitBuildingRegistry.gd`.

## Files changed (RED only)

- `tools/mindustry_godot_transpiler/tests/test_c06_unit_assembler_payload_trigger.py` (new, 4 tests): registration (ledger N2130, 7 symbols, deferred_exprs), exact-evidence (5 slice sources), source-text (signature, `round(float(stack.get("amount", 0)) * multiplier)`, `Math.round(stack.amount * mult)`, `build.getPayloads().remove(stack.item, Math.round(stack.amount * mult));`, `blocks.clear()`, registry const; tick + gate must not call it), Godot proof (`C06UnitAssemblerPayloadTriggerProof.tscn`, prefix `C_06_UNIT_ASSEMBLER_PAYLOAD_TRIGGER_PROOF `).

## Verified numbers (do not re-derive, these are measured in this VM)

- RED run: **4 tests, 2 failures + 2 errors, all expected** — registration `KeyError: 'N2130'`, evidence errors on the missing ledger entry, source-text `AssertionError` (function not found), proof `assertIsNotNone(godot)` (no binary).
- Exact-expr pre-check: **17/17 exprs found verbatim** in the 5 slice sources (BuildingComp.java, Consume.java, ConsumePayloadDynamic.java, UnitAssembler.java, PayloadSeq.java).
- `git diff --check` clean.

## GREEN results (this run, 2026-11-12 ~07:45–08:00 +07)

1. `tools/mindustry_godot_transpiler/register_c06_unit_assembler_payload_trigger.py` written (mirrors the N2129 register script) and run: 7 symbols, 17 exact exprs, TESTS list, PROOF `/root/C06UnitAssemblerPayloadTriggerProof`. SSOT totals verified after the run: **11249 / 1581 / 1503 / 2797**; audit `totalSourceFunctions` 1335 — exactly the RED-phase expectation.
2. `SourceUnitFactoryBuildState.source_unit_factory_assembler_payload_trigger_state(frame, plan)` implemented next to `source_unit_factory_assembler_payload_state`, plus registry const `PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_PAYLOAD_TRIGGER_STATE` in `SourceRuntimeOwnerUnitBuildingRegistry.gd`. Per requirement stack it removes `int(round(float(stack.get("amount", 0)) * multiplier))` from the frame's `blocks` dict (no clamp — mirror `PayloadSeq.remove`), accumulates per item in `removed`, counts the stack in `triggered`; zero-amount rows are skipped (they remove nothing, like the N2129 efficiency where they cannot change the result); then `blocks.clear()` unconditionally. Returns `{"source_owner": ..., "triggered", "removed", "cleared": true, "blocks": {}, "total": 0}`. One fix during GREEN: the `build.getPayloads().remove(...)` Java line in the comment was wrapped across two lines, so the source-text test did not match — rejoined onto one line.
3. Proof `godot-mindustry/tools/runtime_proofs/C06UnitAssemblerPayloadTriggerProof.gd` + `.tscn` written (mirrors the N2129 proof pattern): **12 content keys** — vanquish met (removed stell 4 + tungsten-wall-large 10, triggered 2, blocks {}, total 0, frame module emptied), vanquish stell short 3 → removed still 4, empty blocks → removed 4/10, conquer met (locus 6 + carbide-wall-large 20), conquer short 19 → removed 20, unitCost 2.0 met → removed 8/20, unitCost 2.0 short → removed 8, extra blocks beyond plan → cleared, total 0, empty requirements → removed {}, triggered 0, cleared true, plan-less → same, rounding at unitCost 1.5 → removed stell 6 + tungsten-wall-large 15, duplicate/zero-amount stack → duplicates accumulate (stell 8), zero-amount row skipped. Proof JSON is gitignored, never stage it. NOT run — no Godot binary in this VM.
4. Targeted tests GREEN: `test_c06_unit_assembler_payload_trigger` **3/4 standalone** (registration, exact-evidence, source-text green; proof red on `shutil.which('godot')` → None, expected). Neighbour non-proof tests green: `test_c06_unit_assembler_payload` + `test_c06_unit_factory_consume_trigger` + `test_c06_source_exhaustion_output_full` — 9/9 non-proof OK (their 3 proof tests fail the same way here). `git diff --check` clean.
5. Report `docs/superpowers/reports/2026-11-12-c06-unit-assembler-payload-trigger.md`, design-spec N2130 row + totals (1581) + changelog row + C06 paragraph leg, this handoff — all done, proof results filled 2026-11-12 ~08:52 +07. Committed on proof branch `c06-proof` (ab02c0a, joint with N2128+N2129, pushed to origin); the proof-results docs go in as a second commit on `c06-proof`, then merge `c06-proof` to main (fast-forward) and push origin main.

## GREEN work remaining (next run)

1. ~~Read the finished clean full-suite summary (log `full-suite-n2129-clean.log`, PID 9577, in flight since ~07:52 +07) and record the real N2128/N2129 gate result.~~ Done 08:07 +07: Ran 5613, FAILED (failures=80, skipped=5), 0 errors — all 80 Godot-proof failures; recorded in the N2129 report/handoff.
2. ~~Run a full Python gate that **includes** `test_c06_unit_assembler_payload_trigger` (208 modules on disk, 5618 collectable test methods).~~ Done: inclusive gate finished 08:22 +07 (log `full-suite-n2130-gate.log`, 917 s): **Ran 5617, FAILED (failures=81, skipped=5), 0 errors** — all 81 `assertIsNotNone(godot)` (the 5618 AST estimate was one high; the run collected 5617). Numbers filled into the N2129 + N2130 reports/handoffs.
3. ~~Windows Godot 4.6 proof run for `C06UnitAssemblerPayloadTriggerProof` (12 content keys) — plus the N2128/N2129 proofs if not yet run there.~~ Done 2026-11-12 ~08:52 +07: all three proofs green on Godot 4.6.2-stable Linux in this VM (12/12 tests OK in 38.007s; N2130 proof 12 content keys + 2 registry keys, all true, `matches: true`). The Windows live game was verified running via MCP at ~08:48, but the MCP channel cannot run proof scenes, so the proof ran headless here on the identical engine build (71f334935).
4. ~~Then commit + push N2128 + N2129 + N2130 to the fork (origin = Lasthope1508/mindustry-godot-transpiler) — stage the exact slice files only (never `*.gd.uid`, `project.godot`, `arc-upstream/`, `mindustry-upstream/`, proof `.json`, `full-suite-*.log`, `targeted-env-fix.log`).~~ Committed on proof branch `c06-proof` (ab02c0a, pushed to origin); proof-results docs go in as a second commit on `c06-proof`, then merge `c06-proof` to main (fast-forward) and push origin main. Stage the exact slice files only (never `*.gd.uid`, `project.godot`, `arc-upstream/`, `mindustry-upstream/`, proof `.json`, `full-suite-*.log`, `targeted-env-fix.log`).
5. Next slice after the commit: payload intake (`yeetPayload` blocks.add + acceptPayload/acceptUnitPayload gates) — the next item on the C06 order.

## N2129 suite status (finished 2026-11-12 07:46 +07; clean re-run in flight)

- Full suite first run (PID 6669, log `tools/mindustry_godot_transpiler/full-suite-n2129.log`, 961 s): **Ran 4930 tests, FAILED (failures=85, errors=138, skipped=4)**. All 223 problems are environmental, none by any C06 slice: 76 `assertIsNotNone(godot)` (no Godot binary, expected here); 21 `ModuleNotFoundError: javalang` (15 loader errors + 6 CLI failures — `javalang==0.13.0` is in `requirements.txt` but was not installed); ~120 `FileNotFoundError` on `arc-upstream/` files (the checkout was being expanded to full mid-run); 2 `bundle.properties` errors; 6 mid-expansion timing. The 5613 expectation was the 5609 + 4 estimate; the 207 modules hold 5630 collectable test methods, and the run collected fewer because 15 modules (699 methods, including `test_emitter`'s 600) failed to import. N2128's and N2129's own modules in that run: only their Godot proof tests failed.
- Environment fixed the same morning (~07:50 +07): `pip install -r requirements.txt` (`javalang==0.13.0`), `arc-upstream` fetched at `f30acd2`, `mindustry-upstream` +annotations/+bundles. Targeted re-run after the fixes (log `targeted-env-fix.log`, 3961 tests): only Godot-proof failures left (+1 bundle error, fixed by the checkout expansion and re-run OK as a single test).
- Clean full re-run finished 08:07 +07 (log `tools/mindustry_godot_transpiler/full-suite-n2129-clean.log`, 922 s, same 207 modules, explicitly excluding the N2130 test module because N2130 was still RED when it started): **Ran 5613, FAILED (failures=80, skipped=5), 0 errors** — all 80 Godot-proof failures. Inclusive full gate finished 08:22 +07 (log `full-suite-n2130-gate.log`, 208 modules, 917 s): **Ran 5617, FAILED (failures=81, skipped=5), 0 errors** — all 81 `assertIsNotNone(godot)`. Gate clean except Godot; only the Windows Godot proof run remains before the joint commit. Do NOT stage the logs (working logs, not slice files).

## Deferred (not this slice)

- Payload intake: `yeetPayload` (UnitAssembler.java:688-690, `blocks.add(payload.content(), 1)`) and `acceptPayload`/`acceptUnitPayload` (UnitAssembler.java:711-727).
- Wiring the payload efficiency into the `shouldConsume` gate (with the N2124 proof's assembler-default/live keys).
- `checkTier` from the module tiers (UnitAssembler.java:360-376).
- Live production wiring: progress advance + the call at completion (UnitFactory.java:401-403, Reconstructor.java:330-348, UnitAssembler.spawned()).
- Unit-factory frames' per-class shouldConsume wiring to the power stamp; battery live `enabled` stamp; disabled-belt efficiency half.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

## Commit (not done — GREEN + gates + proof pending)

Stage the exact slice files only (never `*.gd.uid`, `project.godot`, `arc-upstream/`, `mindustry-upstream/`, proof `.json`, `full-suite-n2129.log`): `SourceUnitFactoryBuildState.gd`, `SourceRuntimeOwnerUnitBuildingRegistry.gd`, the SSOT JSONs + `unit_building_*` shards, `test_c06_unit_assembler_payload_trigger.py`, `register_c06_unit_assembler_payload_trigger.py`, `C06UnitAssemblerPayloadTriggerProof.gd` + `.tscn`, the design spec, the report + this handoff. The worktree is a sparse checkout — commit from the user's full checkout, or expand the sparse checkout first and re-verify `git status` shows only these files.
