# Report — N2181: StackRouter power.status live read (surge-router) (C07)

Date: 2026-11-15. Batch: N2181 (single slice). Status: **DONE (2026-11-15 ~03:1x +07 — targeted 4/4 OK, neighbours 184/184 OK, Godot proof GREEN 9 keys matches:true, full gate attempt 1 Ran 5821 in 981.835s, failures=132, skipped=5, 0 errors — all 132 verified Godot-absent asserts). Slice commit `<hash>`.**

## What changed

The next `power.status` consumer family after the N2180 stack-conveyor slice: the StackRouter implementation family — a SINGLE def, **surge-router** (`consumePower(3f / 60f)`, Blocks.java:2266; size 1, speed 6f, itemCapacity 10, health 130, requirements surge-alloy 5 / tungsten 1, Blocks.java:2255-2266). StackRouter extends DuctRouter (StackRouter.java:11, `public class StackRouter extends DuctRouter{`); its build extends DuctRouterBuild (StackRouter.java:24, `public class StackRouterBuild extends DuctRouterBuild{`). Catalog confirms implementation StackRouter + hasPower true + consumesPower true + consumePower 0.05 + conductivePower true + outputsPower false (content_registry_blocks.json, `content_registry.blocks.surge-router`). Blocks.java defs are the source of truth, see Exact exprs in the handoff.

The stack router had NO driver at all — no `SourceStackRouter*` file exists in godot-mindustry/src/game, no `"StackRouter"` entry in any `SOURCE_*_IMPLEMENTATIONS` list (grep for `"StackRouter"` in `godot-mindustry/src/game/` returns nothing), and no frame key existed, so the N2142 stamp never reached a stack-router frame. The Incinerator lesson was applied: the candidate was checked for an existing driver before scoping.

**Naming note:** "StackRouter" is a distribution block (`world/blocks/distribution/StackRouter.java`), NOT related to any factory/turret/defense/bridge/conveyor family. Single def **surge-router** (Blocks.java:2255), Category.distribution.

**Family split — surge-router only:** the StackRouter family splits into defs with DIFFERENT implementations — surge-router carries `consumePower(3f / 60f)` (Blocks.java:2266, catalog `consumePower: 0.05`) + `hasPower = true;` (:2260), `consumesPower = true;` (:2261), `conductivePower = true;` (:2262), `baseEfficiency = 1f;` (:2265), `speed = 6f;` (:2259), health 130 (:2257), `underBullets = true;` (:2264), `solid = false;` (:2263), requirements surge-alloy 5 / tungsten 1; duct-router carries NO consumePower def and NO hasPower line (Blocks.java:2193-2201, health 90, speed 4f, itemCapacity 1 class default), implementation `DuctRouter`; plain router / distributor carry NO consumePower def and NO hasPower line (Blocks.java:2139-2148), implementations `Router` / `Distributor`. This slice covers **surge-router only**. The driver's implementation list holds `StackRouter` only — the duct-router / router defs are DIFFERENT implementations, so the split is enforced by the list itself as well as by the driver gate (`block.properties.has("consumePower")`). Catalog quirk respected: duct-router and router list `hasPower: true` in the catalog despite NO consumePower def and NO hasPower line in Blocks.java — the same pattern as plastanium-conveyor in N2180 and bridge-conveyor in N2178 and bridge-conduit in N2179. The plain radar gate `block.properties.has("consumePower")` correctly includes surge-router and excludes duct-router and router. Do NOT adapt the gate to `or consumesPower`.

The efficiency coupling that makes this slice matter: updateTile computes `float eff = enabled ? (efficiency + baseEfficiency) : 0f;` (StackRouter.java:29) and advances `progress += eff;` (:35) toward `cap = speed` (:30) — so a surge-router with no power unloads slower and draws no glow, while the port without this slice would behave as if power.status were 1.0. The glow is the only HARD power gate: `if(glowRegion.found() && power != null && power.status > 0){` (:79) with `Draw.color(glowColor, glowAlpha * power.status);` (:81).

**baseEfficiency = 1f changes the meaning of "zero at no power":** the surge def sets `baseEfficiency = 1f;` (Blocks.java:2265), so at efficiency 0 the router STILL unloads at eff 1f — power raises eff toward 2f. The proof's `efficiency_zero_at_no_power` key proves the folded efficiency is 0; it must NOT claim the router stops. The unload continues at the base rate.

**Disabled branch differs from the conveyor:** StackRouter computes `... : 0f;` (StackRouter.java:29) where StackConveyor computes `... : 1f;` (StackConveyor.java:270) — a disabled surge-router unloads nothing, while a disabled surge-conveyor still reels at eff 1f. The driver already checks `enabled`, so this difference needs no extra handling.

**Parent updateTile is overridden:** DuctRouterBuild.updateTile advances `progress += edelta() / speed * 2f;` (DuctRouter.java:102) — but StackRouterBuild OVERRIDES updateTile (StackRouter.java:28), so the parent's edelta-based advance never runs for a surge-router. The port must not model the parent advance for this family. duct-router / router transport does NOT depend on power.status: with no power consumer their efficiency stays 1.0 when enabled, so excluding them from the power driver is correct, not a gap. N2181 is the stack router's live read — the same proven N2145–N2180 pure-row pattern, on the N2173 radar precedent (new family file + own driver + own frame key + simulate_factory wiring): one new pure function on a new state file + a driver fold + a new frame key + the wiring.

**Power is STATIC here** — unlike RepairTurret's conditional draw: `consumePower(3f / 60f)` registers a plain ConsumePower, so the catalog `consumePower: 0.05` is present and the plain radar gate `block.properties.has("consumePower")` works — no RepairTurret-style `or consumesPower` adaptation needed. The pure row is the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39).

**shouldConsume — NO override, so NO gate to defer:** StackRouterBuild has no shouldConsume override (nor do DuctRouterBuild / RouterBuild), so the BuildingComp default applies (`public boolean shouldConsume(){`, BuildingComp.java:755, with `return enabled;`, :756). When the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994). Unlike the ItemBridge / LiquidBridge link gates (N2178/N2179), there is NO gate to defer here: the power-only fold is EXACT for this family, because the only gate is `enabled`, which the driver already checks.

New file `godot-mindustry/src/game/SourceStackRouterBuildState.gd`, class_name SourceStackRouterBuildState, with `SOURCE_STACK_ROUTER_BUILD_IMPLEMENTATIONS := ["StackRouter"]` and frame meta key `"source_stack_router_building"`:

- Pure `source_stack_router_power_status_row_state(frame, has_power_consumer)` (mirrors `source_stack_conveyor_power_status_row_state`): without a consumer → `{"has_power_row": false, "row": {}}`; else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469).
- `source_stack_router_tick_frame_state` (mirrors the stack-conveyor tick-frame: block_implementation / team_id / rules_state / cheating via TeamComp.cheating(), preserve disabled frame).
- `source_stack_router_bind_frame_state` (mirrors the stack-conveyor bind: empty frame under the stack-router meta key, no-op for other blocks / already-bound sprites).
- Driver `source_stack_router_tick_buildings_state(game, seconds)` (mirrors the stack-conveyor driver: iterate placed buildings, match implementation, bind frame, tick frame, when the block has the static power consumer (`block.properties.has("consumePower")`) and enabled and not cheating fold the pure row via `source_building_efficiency_state.update_consumption_state(true, ...)` with has_consumers=true — the power consumer counts toward hasConsumers, Block.java:1449 — and apply it; no consumer actors, no production tick, no updateTile progress/unload advance).

Header quotes all 86 exact exprs, each on ONE comment line. All 6 documented limits recorded in the pure function's comment.

New frame key `"source_stack_router_building"` added to `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS` so the N2142 graph stamp/write-back finds the stack-router frame. Wiring in `SourceFactoryRuntimeState.simulate_factory`: preload `source_stack_router_build_state` (:43) + call `source_stack_router_tick_buildings_state(game, delta)` (:485, immediately after the stack-conveyor call :474).

Documented limits in the pure function's comment, same discipline as N2148–N2180: (1) power-only first pass — the surge-router's static power consumer (consumePower 3f/60f, Blocks.java:2266) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); surge-router has no second consumer. (2) NO shouldConsume gate to defer — StackRouterBuild has no shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) applies; the power-only fold is EXACT for this family. (3) No updateTile advance — eff fold / progress advance / unload branch / target handoff / current-pick branch (StackRouter.java:28-70) wait for their own slices; the proof carries no progress / unloading / target / acceptItem keys, the eff fold (StackRouter.java:29) is what the efficiency keys prove. (4) No sense modeling — sense waits for its own slice. (5) Single def — surge-router only (size 1, speed 6f, itemCapacity 10, health 130, surge-alloy 5 / tungsten 1); duct-router (DuctRouter, no power def) and router (Router, no power def) are explicitly OUT of scope; per-def stat values wait for their own verification slice. (6) No draw/config modeling — draw / drawSelect / config wait for their own slices.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_stack_router_power_status.py` + register script `tools/mindustry_godot_transpiler/register_c07_stack_router_power_status.py` written, modeled on the N2180 pair (test written fresh with StackRouter prose; register script via transform `/tmp/n2181_transform_register.py` — identifier swaps on head/tail only, inherited DEFERRED kept verbatim, docstring + EXACT_EXPRS replaced wholesale). Register script: EXACT_EXPRS = the 86 verified exprs (all 86 unique, all present verbatim in upstream — script check, 0 missing), DEFERRED 198 entries (187 inherited + 11 new StackRouter-family entries).

RED run: Ran 4 tests, FAILED (failures=1, errors=3) — exactly as expected for a new-file slice: registration KeyError 'N2181' (no ledger entry yet), exact-evidence KeyError 'N2181', row-state FileNotFoundError on the not-yet-existing `SourceStackRouterBuildState.gd`, proof test `assertIsNotNone(godot)` (no Godot on PATH in the worker shell + missing `C07StackRouterPowerStatusProof.tscn`) — all four fail for the expected missing-artifact reasons, none passes spuriously. Port 7777 was FREE before the run. 86/86 exact exprs verified verbatim at scoping (script check, 0 missing). SSOT baseline 11370/1631/1552/2895, audit 1335. `git diff --check` OK.

**Shard question resolved at RED:** NO new shard expected. No `stack_router` / `distribution` shard selection matches StackRouter.java (the N2171 MassDriver / N2178 ItemBridge / N2179 LiquidBridge / N2180 StackConveyor precedent — java_source under `world/blocks/distribution/`, in the root ledger only) — verified at the GREEN register run: no `source_modules` shard changed.

**No VM restart since ~01:30 +07** (the 5th restart of the night; uptime 1h48m at the 03:18 check, javalang 0.13.0 still present). Godot binary intact (`~/workspace/godot-bin/godot` → 4.6.2-stable).

## GREEN

- New `godot-mindustry/src/game/SourceStackRouterBuildState.gd` (radar N2173 / stack-conveyor N2180 precedent): pure row + tick-frame + bind + driver, plain `block.properties.has("consumePower")` gate — static power, no RepairTurret-style adaptation; folds via `update_consumption_state` with has_consumers=true. Header quotes all 86 exact exprs, each on ONE comment line. All 6 documented limits recorded in the pure function's comment. NO shouldConsume gate to defer — StackRouterBuild has no override, BuildingComp default `return enabled;` applies, power-only fold is EXACT.
- Frame key `"source_stack_router_building"` appended to `SOURCE_CONSUMER_FRAME_META_KEYS` (SourcePlacedPowerGraphState.gd:140, end of list after the stack-conveyor key). Wiring in `SourceFactoryRuntimeState.simulate_factory`: preload (:43) + call immediately after the stack-conveyor call (:485).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07StackRouterPowerStatusProof.gd` + `.tscn` (N2180 model, 6 keys + registry_valid / one_headquarter_per_ssot / matches). Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run: SSOT **11372/1632/1553/2897** — exactly the expected values (+2/+1/+1/+2); audit 1335 unchanged; ledger N2181 status done. No source_modules shard changed — no shard selection matches StackRouter.java (the N2171/N2178/N2179/N2180 precedent, decided at RED).
- Targeted: **Ran 4 tests in 15.518s, OK** (Godot 4.6.2 on PATH). Port 7777 FREE before the run. `git diff --check` OK.
- Godot proof (inside the targeted run, Linux headless 4.6.2): **9 keys all true, matches:true** — `stack_router_has_power_consumer`, `power_row_half`, `power_row_absent_without_consumer`, `power_row_null_folds_one`, `efficiency_folds_power_min`, `efficiency_zero_at_no_power`, `registry_valid`, `one_headquarter_per_ssot`, `matches`. No ERROR in output.

## Neighbours

Family run ~02:43 +07: **Ran 148 tests in 484.520s, OK** — 37 modules (36 at N2180 + the new stack-router module), Godot 4.6.2 on PATH, port 7777 FREE at launch. Clean run, ZERO port-7777 flakes this time (no isolated re-run needed). No regression from N2181.

Wiring-standard set (9 modules / 32 tests, the N2177 lesson) run by the main thread ~02:47 +07: test_factory_live_loop 4/4, test_power_graph_live_update_binding 3/3, test_battery_power_status_binding 3/3, test_battery_placement_binding 3/3, test_adjacent_factory_live_loop 4/4, test_unit_factory_live_loop 4/4, test_turret_live_loop 4/4, test_continuous_liquid_turret_live_loop 3/3, test_power_graph_consumer_cheating 4/4 — **32/32 OK**.

Neighbours final: targeted **4/4 OK**; family **148/148 OK**; wiring **32/32 OK**. Total **184/184 OK**. No regression from N2181.

**Worker-lesson correction (02:47 run):** the 02:15 worker claimed the wiring module list "is not recorded in the N2177/N2179 handoffs" — wrong, the list IS recorded (MEMORY.md + the N2177 main-thread chain) — and the family run does NOT cover these modules. The main thread's wiring re-run above is the correction. Same error as N2180's 01:15 worker; do not repeat it.

## Gate

Full gate attempt 1 **launched from the MAIN THREAD ~02:48 +07**: `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2181-gate.log 2>&1 < /dev/null &` — **PID 10226, SID 10226 (own session), PPID 10223 (background subshell), CPU ~92%, log growing**. Single gate only. No Godot on PATH. No proof scene ran while the gate ran (port-7777 rule).

Finished ~03:04 +07 (log mtime 03:04:16 +07): **Ran 5821 tests in 981.835s, FAILED (failures=132, skipped=5)** — no errors field, 0 `ERROR:` lines. All 132 verified Godot-absent (grep on the log): **132 × `AssertionError: unexpectedly None`** (the N2175 lesson — count by the error message, not the exact-no-message-arg awk), including the new N2181 proof test (`test_reference_graph_and_actual_c07_stack_router_power_status`, log line 467), 0 port-7777 bind errors. The gate is clean except Godot — exactly as expected (131 inherited + 1 new). No VM restart during the gate (boot 01:30, uptime 1h48m at 03:18, javalang 0.13.0 still present). Gate back to normal speed (981.8s vs N2180's 972.5s, N2179's 949.5s).

## Commits

- Slice: `<hash>` — C07: N2181 StackRouter power.status live read (surge-router; pure power row + driver wiring; proof 6 keys), 11 files.
- Docs: `<hash>` — Docs: N2181 report + design spec + handoff (gate clean except Godot).
- GOAL: `<hash>` — Docs: GOAL.md names the N2181 slice commit that carries its proof to Windows (§5 debt line).
- Pushed 2026-11-15 ~03:2x +07 to the fork (Lasthope1508). See the handoff Commits section for the hashes.

## Deferred (NOT this slice)

- StackRouter updateTile advance (eff fold / progress advance / unload branch / target handoff / current-pick branch, StackRouter.java:28-70) — its own slice.
- sense modeling — its own slice.
- Draw / config modeling (draw / drawSelect / config) — their own slices.
- Per-def stat values (size 1, speed 6f, itemCapacity 10, health 130, surge-alloy 5 / tungsten 1) — their own verification slice.
- duct-router (DuctRouter, no power def) and router / distributor (no power def) — explicitly OUT of scope; their transport does not depend on power.status.
- Next candidates (verified in the N2178/N2179/N2180 reports, not yet scoped): ImpactReactor (impact-reactor, consumePower 25f BUT outputsPower true — generator, consume-vs-produce needs care at scoping), Accelerator (interplanetary-accelerator, 10f), BuildTurret (build-tower, 3f, Blocks.java:2005).
