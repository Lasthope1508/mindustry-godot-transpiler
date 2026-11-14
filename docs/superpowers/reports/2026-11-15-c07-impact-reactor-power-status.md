# Report — N2182: ImpactReactor power.status live read (impact-reactor) (C07)

Date: 2026-11-15. Batch: N2182 (single slice). Status: **DONE (2026-11-15 ~04:4x +07 — targeted 4/4 OK, neighbours 188/188 OK, Godot proof GREEN 9 keys matches:true, full gate attempt 1 Ran 5825 in 988.761s, failures=133, skipped=5, 0 errors — all 133 verified Godot-absent asserts). Slice commit `<hash>`.**

## What changed

The next `power.status` consumer family after the N2181 stack-router slice: the ImpactReactor implementation family — a SINGLE def, **impact-reactor** (`consumePower(25f)`, Blocks.java:2642; size 4, health 900, powerProduction 130f, itemDuration 140f, liquidCapacity 80f, requirements lead 500 / silicon 300 / graphite 400 / thorium 100 / surge-alloy 250 / metaglass 250, Blocks.java:2632-2644). ImpactReactor extends PowerGenerator (ImpactReactor.java:17, `public class ImpactReactor extends PowerGenerator{`); its build extends GeneratorBuild (ImpactReactor.java:74, `public class ImpactReactorBuild extends GeneratorBuild{`). Catalog confirms implementation ImpactReactor + hasPower true + consumesPower true + consumePower 25.0 + outputsPower true + powerProduction 130.0 + powerUsage 25.0 + powerBuffered false (content_registry_blocks.json, `content_registry.blocks.impact-reactor`). Blocks.java defs are the source of truth, see Exact exprs in the handoff.

The impact reactor had NO driver at all — no `SourceImpactReactor*` file exists in godot-mindustry/src/game, no `"ImpactReactor"` entry in any `SOURCE_*_IMPLEMENTATIONS` list (grep for `"ImpactReactor"` in `godot-mindustry/src/game/` returns nothing), and no frame key existed, so the N2142 stamp never reached an impact-reactor frame. The Incinerator lesson was applied: the candidate was checked for an existing driver before scoping.

**Naming note:** "ImpactReactor" is a power block (`world/blocks/power/ImpactReactor.java`), NOT related to any factory/turret/defense/bridge/conveyor/router family. Single def **impact-reactor** (Blocks.java:2632), Category.power.

**Consume-vs-produce care (the scoping question):** the reactor is a GENERATOR — it both consumes 25f and produces `powerProduction * productionEfficiency` (130f at full warmup). The row this slice folds is the CONSUMER-side read (`return build.power.status;`, ConsumePower.java:39), exactly like every pure-consumer slice: the shared machinery folds it into the min efficiency, and the folded efficiency feeds the warmup gate. The PRODUCER side waits for its own slice: `getPowerProduction()` returns `enabled ? powerProduction * productionEfficiency : 0f;` (PowerGenerator.java:156-158), `productionEfficiency = Mathf.pow(warmup, 5f);` (ImpactReactor.java:100). The power bar shows NET output: `Strings.fixed(Math.max(entity.getPowerProduction() - (consPower == null ? 0f : consPower.usage), 0) * 60 * entity.timeScale(), 1)),` (ImpactReactor.java:50).

**Power is STATIC here** — unlike RepairTurret's conditional draw: `consumePower(25f)` registers a plain ConsumePower, so the catalog `consumePower: 25.0` is present and the plain radar gate `block.properties.has("consumePower")` works — no RepairTurret-style `or consumesPower` adaptation needed. The pure row is the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39).

**shouldConsume — NO override, so NO gate to defer:** ImpactReactorBuild has no shouldConsume override (nor do GeneratorBuild / PowerGenerator), so the BuildingComp default applies (`public boolean shouldConsume(){`, BuildingComp.java:755, with `return enabled;`, :756). When the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994). There is NO gate to defer here: the power-only fold is EXACT for this family, because the only gate is `enabled`, which the driver already checks.

The efficiency coupling that makes this slice matter: updateTile warms up ONLY while `efficiency >= 0.9999f && power.status >= 0.99f` (ImpactReactor.java:79) — `warmup = Mathf.lerpDelta(warmup, 1f, warmupSpeed * timeScale);` (:82), else `warmup = Mathf.lerpDelta(warmup, 0f, 0.01f);` (:95); `productionEfficiency = Mathf.pow(warmup, 5f);` (:100). So a reactor that cannot draw its 25f never warms up and never produces, while the port without this slice would behave as if power.status were 1.0. The item/liquid consumption (`consumeItem blast-compound`, `consumeLiquid cryofluid 0.25f`) rides on the same `consume()` call — the tick models the power row only; the item/liquid rows wait for their own slices, so the folded efficiency is the min over the modeled consumers (power only).

**The warmup gate is a HARD gate, unlike the router's base-efficiency soft coupling:** at efficiency 0 the warmup decays to 0 and production is 0 — there is no baseEfficiency-style floor. The proof's `efficiency_zero_at_no_power` key proves the folded efficiency is 0; unlike N2181 it MAY claim the reactor stops producing (productionEfficiency is pow(warmup, 5f), and warmup decays when the gate fails) — but the warmup advance itself still waits for its own slice, so the proof carries no warmup/production keys.

New file `godot-mindustry/src/game/SourceImpactReactorBuildState.gd`, class_name SourceImpactReactorBuildState, with `SOURCE_IMPACT_REACTOR_BUILD_IMPLEMENTATIONS := ["ImpactReactor"]` and frame meta key `"source_impact_reactor_building"`:

- Pure `source_impact_reactor_power_status_row_state(frame, has_power_consumer)` (mirrors `source_stack_router_power_status_row_state`): without a consumer → `{"has_power_row": false, "row": {}}`; else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469).
- `source_impact_reactor_tick_frame_state` (mirrors the stack-router tick-frame: block_implementation / team_id / rules_state / cheating via TeamComp.cheating(), preserve disabled frame).
- `source_impact_reactor_bind_frame_state` (mirrors the stack-router bind: empty frame under the impact-reactor meta key, no-op for other blocks / already-bound sprites).
- Driver `source_impact_reactor_tick_buildings_state(game, seconds)` (mirrors the stack-router driver: iterate placed buildings, match implementation, bind frame, tick frame, when the block has the static power consumer (`block.properties.has("consumePower")`) and enabled and not cheating fold the pure row via `source_building_efficiency_state.update_consumption_state(true, ...)` with has_consumers=true — the power consumer counts toward hasConsumers, Block.java:1449 — and apply it; no consumer actors, no production tick, no updateTile warmup/production advance).

Header quotes all 78 exact exprs, each on ONE comment line. All 6 documented limits recorded in the pure function's comment.

New frame key `"source_impact_reactor_building"` added to `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS` so the N2142 graph stamp/write-back finds the impact-reactor frame. Wiring in `SourceFactoryRuntimeState.simulate_factory`: preload + call `source_impact_reactor_tick_buildings_state(game, delta)` immediately after the stack-router call.

Documented limits in the pure function's comment, same discipline as N2148–N2181: (1) power-only first pass — the impact-reactor's static power consumer (consumePower 25f, Blocks.java:2642) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); item (blast-compound) and liquid (cryofluid 0.25f) rows wait for their own slices. (2) NO shouldConsume gate to defer — ImpactReactorBuild has no shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) applies; the power-only fold is EXACT. (3) No updateTile warmup/production advance — warmup lerp / totalProgress / productionEfficiency (ImpactReactor.java:79-100) wait for their own slices; the proof carries no warmup / production keys, the eff fold is what the efficiency keys prove. (4) No sense modeling — sense waits for its own slice. (5) Single def — impact-reactor only (size 4, health 900, powerProduction 130f, itemDuration 140f, liquidCapacity 80f); per-def stat values wait for their own verification slice. (6) No draw/config modeling — draw / drawSelect / config wait for their own slices.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_impact_reactor_power_status.py` (402 lines) + register script `tools/mindustry_godot_transpiler/register_c07_impact_reactor_power_status.py` (166 lines) written, modeled on the N2181 pair (test written fresh with ImpactReactor prose; register script via transform `/tmp/n2182_transform.py` — targeted identifier swaps on head/tail only, inherited DEFERRED kept verbatim, docstring + EXACT_EXPRS replaced wholesale). Register script: EXACT_EXPRS = the 78 verified exprs (all 78 unique, all present verbatim in upstream — script check, 0 missing), DEFERRED 209 entries (198 inherited + 11 new ImpactReactor-family entries).

RED run: Ran 4 tests, FAILED (failures=1, errors=3) — exactly as expected for a new-file slice: registration KeyError 'N2182' (no ledger entry yet), exact-evidence KeyError 'N2182', row-state FileNotFoundError on the not-yet-existing `SourceImpactReactorBuildState.gd`, proof test `assertIsNotNone(godot)` (no Godot on PATH in the worker shell + missing `C07ImpactReactorPowerStatusProof.tscn`) — all four fail for the expected missing-artifact reasons, none passes spuriously. Port 7777 was FREE before the run. 78/78 exact exprs verified verbatim at scoping (script check, 0 missing). SSOT baseline 11372/1632/1553/2897, audit 1335. `git diff --check` OK.

**Shard question resolved at RED — then CORRECTED at GREEN:** at RED the expectation was NO shard change (the N2171/N2178/N2179/N2180/N2181 precedent). At the GREEN register run the power shard DID change — purely additive N2182 mirrors — because the power shard selects by java_source under `world/blocks/power/` and ImpactReactor.java matches it. `source_modules/power_api_contracts.json` +32 lines, `source_modules/power_slices.json` +18 lines. No NEW shard file was created; the RED "no shard changed" expectation was wrong for a power-family slice (the N2178–N2181 precedent families matched no shard selection).

**VM restarted during this run** (uptime 1 min at run start, ~03:30 +07; 6th restart since the project began) — javalang wiped and reinstalled 0.13.0 (`pip install --break-system-packages -r tools/mindustry_godot_transpiler/requirements.txt` from the repo root) before any test work, per the MEMORY rule. Port 7777 FREE at run start. Godot binary exists at `~/workspace/godot-bin/godot` (4.6.2-stable, build 71f334935) but is NOT on PATH in the worker shell — the GREEN proof run must export `PATH="$HOME/workspace/godot-bin:$PATH"` first (the N2177 main-thread re-run had it on PATH).

## GREEN

- New `godot-mindustry/src/game/SourceImpactReactorBuildState.gd` (radar N2173 / stack-router N2181 precedent): pure row + tick-frame + bind + driver, plain `block.properties.has("consumePower")` gate — static power, no RepairTurret-style adaptation; folds via `update_consumption_state` with has_consumers=true. Header quotes all 78 exact exprs, each on ONE comment line. All 6 documented limits recorded in the pure function's comment. NO shouldConsume gate to defer — ImpactReactorBuild has no override, BuildingComp default `return enabled;` applies, power-only fold is EXACT.
- Frame key `"source_impact_reactor_building"` appended to `SOURCE_CONSUMER_FRAME_META_KEYS` (SourcePlacedPowerGraphState.gd:140, end of list after the stack-router key). Wiring in `SourceFactoryRuntimeState.simulate_factory`: preload + call immediately after the stack-router call.
- Proof scene `godot-mindustry/tools/runtime_proofs/C07ImpactReactorPowerStatusProof.gd` + `.tscn` (N2181 model, 6 keys + registry_valid / one_headquarter_per_ssot / matches). Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register-script fix at GREEN (RED transform artifact): the script's TESTS list carried 3 stale stack-router names and `java_method='StackRouterBuild.updateTile()'` — both fixed to the ImpactReactor names / `ImpactReactorBuild.updateTile()` before the register run; the root ledger now records the correct 4 test names. The DEFERRED list's inherited StackRouter/StackConveyor/ItemBridge/LiquidBridge entries are intentional (the N2178–N2181 precedent: inherited verbatim).
- Register script run: SSOT **11374/1633/1554/2899** — exactly the expected values (+2/+1/+1/+2); audit 1335 unchanged; ledger N2182 status done. Power shard changed (see RED correction above): `power_api_contracts.json` +32 lines, `power_slices.json` +18 lines, purely additive.
- Targeted: **Ran 4 tests in 14.673s, OK** (Godot 4.6.2 on PATH). Port 7777 FREE before the run. `git diff --check` OK.
- Godot proof (inside the targeted run, Linux headless 4.6.2): **9 keys all true, matches:true** — `impact_reactor_has_power_consumer`, `power_row_half`, `power_row_absent_without_consumer`, `power_row_null_folds_one`, `efficiency_folds_power_min`, `efficiency_zero_at_no_power`, `registry_valid`, `one_headquarter_per_ssot`, `matches`. No ERROR in output.

## Neighbours

Family run ~03:5x +07 (38 modules, 152 tests — 37 at N2181 + the new impact-reactor module), Godot 4.6.2 on PATH, port 7777 FREE at launch. **The worker's family run died with its session** (log had only 146 dots, no footer, no process when main thread checked ~04:00). Main thread re-ran the family from its own session: **Ran 152 tests in 631.090s, FAILED (failures=12)** — all 12 are `test_reference_graph_and_actual_c07_*_power_status` proof tests (separator, shield-wall, shockwave-tower, solid-pump, stack-conveyor, stack-router, tractor-beam-turret, turret, unit-assembler-module, unit-cargo-loader, unit-factory, wall-crafter). **Root cause — known port-7777 flake, NOT a slice regression:** every failure is `assertNotIn('ERROR:', output)` tripped by `ERROR: [MCP Runtime] Failed to start server on port 7777: 22`, while the proof JSON in the same output shows `matches:true` with all keys true (12 × `matches:true`, 12 × `7777` in the log). The N2182 impact-reactor module itself is NOT among the failures.

- **Re-run loop 1 (12 modules, ~04:0x):** 6 OK, 6 FAILED (solid-pump, turret, unit-assembler-module, unit-cargo-loader, unit-factory, wall-crafter — the failed ones took 16–18s vs ~13s, contention mid-loop as the other agent's Godot re-grabbed the port).
- **Re-run loop 2 (the 6 remaining, ~04:1x):** ALL 6 OK (each 4/4, ~13s, port 7777 FREE at launch).
- Family final: **152/152 OK** (140 in-run + 12 on isolated re-runs).

Wiring-standard set (9 modules / 32 tests, the N2177 lesson) run by the main thread ~04:19: **ALL OK** (4+3+3+3+4+4+4+3+4).

Neighbours final: targeted **4/4 OK**; family **152/152 OK**; wiring **32/32 OK**. Total **188/188 OK**. No regression from N2182.

**Worker-lesson correction (04:15 run):** the 04:00 worker claimed "22 failures, 130 pass" — WRONG; verified from the log footer + FAIL headers: 12 failures, 140 pass (140+12=152). Count failures from the footer and FAIL headers, not from a grep of the port-error string (each failing proof prints the bind error once per Godot retry, so the string count overcounts).

## Gate

Full gate attempt 1 **launched from the MAIN THREAD ~04:20 +07**: `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2182-gate.log 2>&1 < /dev/null &` — **PID 7426, SID 7426 (own session), PPID 7423 (background subshell), CPU ~92%, log growing**. Single gate only. No Godot on PATH. No proof scene ran while the gate ran (port-7777 rule).

Finished ~04:36 +07 (log mtime 04:36 +07): **Ran 5825 tests in 988.761s, FAILED (failures=133, skipped=5)** — no errors field, 0 `ERROR:` lines. All 133 verified Godot-absent (grep on the log): **133 × `AssertionError: unexpectedly None`** (the N2175 lesson — count by the error message, not the exact-no-message-arg awk), including the new N2182 proof test (`test_reference_graph_and_actual_c07_impact_reactor_power_status`, log line 467), 0 port-7777 bind errors. The gate is clean except Godot — exactly as expected (132 inherited + 1 new). No VM restart during the gate (boot ~03:30, uptime 1h17m at 04:46, javalang 0.13.0 still present). Gate back to normal speed (988.8s vs N2181's 981.8s, N2180's 972.5s).

## Commits

- Slice: `<hash>` — C07: N2182 ImpactReactor power.status live read (impact-reactor; pure power row + driver wiring; proof 6 keys), 13 files.
- Docs: `<hash>` — Docs: N2182 report + design spec + handoff (gate clean except Godot).
- GOAL: `<hash>` — Docs: GOAL.md names the N2182 slice commit that carries its proof to Windows (§5 debt line).
- Pushed 2026-11-15 ~04:5x +07 to the fork (Lasthope1508). See the handoff Commits section for the hashes.

## Deferred (NOT this slice)

- Producer side: `getPowerProduction()` / `productionEfficiency` / warmup advance (ImpactReactor.java:79-100, PowerGenerator.java:96, 105, 156-158) — its own slice.
- Item/liquid consumption rows (consumeItem blast-compound, consumeLiquid cryofluid 0.25f, ImpactReactor.java:2643-2644) — their own slices.
- updateTile warmup/production advance (ImpactReactor.java:79-100) — its own slice.
- sense modeling — its own slice.
- Draw / config modeling (draw / drawSelect / config) — their own slices.
- Per-def stat values (size 4, health 900, powerProduction 130f, itemDuration 140f, liquidCapacity 80f) — their own verification slice.
- Next candidates (verified in the N2178–N2181 reports, not yet scoped): Accelerator (interplanetary-accelerator, 10f), BuildTurret (build-tower, 3f, Blocks.java:2005).
