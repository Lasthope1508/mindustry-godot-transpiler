# Report — N2180: StackConveyor power.status live read (surge-conveyor) (C07)

Date: 2026-11-15. Batch: N2180 (single slice). Status: **DONE (2026-11-15 ~02:0x +07 — targeted 4/4 OK, neighbours 180/180 OK, Godot proof GREEN 9 keys matches:true, full gate attempt 4 Ran 5817 in 972.474s, failures=131, skipped=5, 0 errors — all 131 verified Godot-absent asserts). Slice commit `<hash>`.**

## What changed

The next `power.status` consumer family after the N2179 liquid-bridge slice: the StackConveyor implementation family — a SINGLE def, **surge-conveyor** (`consumePower(1f / 60f)`, Blocks.java:2251; size 1, speed 5f/60f, itemCapacity 10, health 130, requirements surge-alloy 1 / tungsten 1, Blocks.java:2237-2253). StackConveyor extends Block implements Autotiler (StackConveyor.java:24, `public class StackConveyor extends Block implements Autotiler{`); its build extends Building (StackConveyor.java:114, `public class StackConveyorBuild extends Building{`). Catalog confirms implementation StackConveyor + hasPower true + consumesPower true + consumePower 0.016666666666666666 + conductivePower true + outputsPower false (content_registry_blocks.json, `content_registry.blocks.surge-conveyor`). Blocks.java defs are the source of truth, see Exact exprs in the handoff.

The stack conveyor had NO driver at all — no `SourceStackConveyor*` file exists in godot-mindustry/src/game, no `"StackConveyor"` entry in any `SOURCE_*_IMPLEMENTATIONS` list (grep for `"StackConveyor"` in `godot-mindustry/src/game/` returns nothing), and no frame key existed, so the N2142 stamp never reached a stack-conveyor frame. The Incinerator lesson was applied: the candidate was checked for an existing driver before scoping. (The N2056–N2058 conveyor-stack-binding handoff bound the ConveyorBuild stack API — a different class, `ConveyorBuild`, not `StackConveyorBuild`.)

**Naming note:** "StackConveyor" is a distribution block (`world/blocks/distribution/StackConveyor.java`), NOT related to any factory/turret/defense/bridge family. Single def **surge-conveyor** (Blocks.java:2237), Category.distribution.

**Family split — surge-conveyor only:** the StackConveyor family splits into TWO defs with ONE implementation — surge-conveyor carries `consumePower(1f / 60f)` (Blocks.java:2251, catalog `consumePower: 0.016666666666666666`) + `hasPower = true;` (:2245), `consumesPower = true;` (:2246), `conductivePower = true;` (:2247), `baseEfficiency = 1f;` (:2250), `outputRouter = false;` (:2244), `speed = 5f / 60f;` (:2241), health 130 (:2239), itemCapacity 10 (:2242); plastanium-conveyor carries NO consumePower def and NO hasPower line (Blocks.java:2084-2089, health 90, speed 4f/60f, itemCapacity 10, requirements plastanium 1 / silicon 1 / graphite 1), NO `consumePower` property in the catalog (implementation `StackConveyor`). This slice covers **surge-conveyor only**. The driver's implementation list holds `StackConveyor` only — the plastanium-conveyor def is the SAME implementation but has no power consumer, so the split is enforced by the driver gate (`block.properties.has("consumePower")`), not by the list. Catalog quirk respected: plastanium-conveyor lists `hasPower: true` in the catalog despite NO consumePower def and NO hasPower line in Blocks.java — the same pattern as bridge-conveyor in N2178 and bridge-conduit in N2179. The plain radar gate `block.properties.has("consumePower")` correctly includes surge-conveyor and excludes plastanium-conveyor. Do NOT adapt the gate to `or consumesPower`.

The efficiency coupling that makes this slice matter: updateTile computes `float eff = enabled ? (efficiency + baseEfficiency) : 1f;` (StackConveyor.java:270) and reels the cooldown with `if(cooldown > 0f) cooldown = Mathf.clamp(cooldown - speed * eff * delta(), 0f, recharge);` (:273) — so a surge-conveyor with no power reels slower and draws no glow, while the port without this slice would behave as if power.status were 1.0. The glow is the only HARD power gate: `if(glowRegion.found() && power != null && power.status > 0f){` (:156) with `Draw.color(glowColor, glowAlpha * power.status);` (:158).

**baseEfficiency = 1f changes the meaning of "zero at no power":** the surge def sets `baseEfficiency = 1f;` (Blocks.java:2250), so at efficiency 0 the belt STILL reels at eff 1f — power raises eff toward 2f. The proof's `efficiency_zero_at_no_power` key proves the folded efficiency is 0; it must NOT claim the belt stops. The transfer branch returns early without a link (`if(link == -1) return;`, :276) or when disabled (`if(!enabled) return;`, :287), and the handoff sets `cooldown = recharge;` (:311) with `e.cooldown = 1;` (:312). plastanium-conveyor transport does NOT depend on power.status: with no power consumer its efficiency stays 1.0 when enabled, so the cooldown still reels at baseEfficiency 0f and items still move — excluding it from the power driver is correct, not a gap. N2180 is the stack conveyor's live read — the same proven N2145–N2179 pure-row pattern, on the N2173 radar precedent (new family file + own driver + own frame key + simulate_factory wiring): one new pure function on a new state file + a driver fold + a new frame key + the wiring.

**Power is STATIC here** — unlike RepairTurret's conditional draw: `consumePower(1f / 60f)` registers a plain ConsumePower, so the catalog `consumePower: 0.0167` is present and the plain radar gate `block.properties.has("consumePower")` works — no RepairTurret-style `or consumesPower` adaptation needed. The pure row is the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39).

**shouldConsume — NO override, so NO gate to defer:** StackConveyorBuild has no shouldConsume override, so the BuildingComp default applies (`public boolean shouldConsume(){`, BuildingComp.java:755, with `return enabled;`, :756). When the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994). Unlike the ItemBridge / LiquidBridge link gates (N2178/N2179), there is NO gate to defer here: the power-only fold is EXACT for this family, because the only gate is `enabled`, which the driver already checks.

New file `godot-mindustry/src/game/SourceStackConveyorBuildState.gd`, class_name SourceStackConveyorBuildState, with `SOURCE_STACK_CONVEYOR_BUILD_IMPLEMENTATIONS := ["StackConveyor"]` and frame meta key `"source_stack_conveyor_building"`:

- Pure `source_stack_conveyor_power_status_row_state(frame, has_power_consumer)` (mirrors `source_liquid_bridge_power_status_row_state`): without a consumer → `{"has_power_row": false, "row": {}}`; else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469).
- `source_stack_conveyor_tick_frame_state` (mirrors the liquid-bridge tick-frame: block_implementation / team_id / rules_state / cheating via TeamComp.cheating(), preserve disabled frame).
- `source_stack_conveyor_bind_frame_state` (mirrors the liquid-bridge bind: empty frame under the stack-conveyor meta key, no-op for other blocks / already-bound sprites).
- Driver `source_stack_conveyor_tick_buildings_state(game, seconds)` (mirrors the liquid-bridge driver: iterate placed buildings, match implementation, bind frame, tick frame, when the block has the static power consumer (`block.properties.has("consumePower")`) and enabled and not cheating fold the pure row via `source_building_efficiency_state.update_consumption_state(true, ...)` with has_consumers=true — the power consumer counts toward hasConsumers, Block.java:1449 — and apply it; no consumer actors, no production tick, no updateTile reel/transfer advance).

Header quotes all 56 exact exprs, each on ONE comment line. All 6 documented limits recorded in the pure function's comment.

New frame key `"source_stack_conveyor_building"` added to `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS` so the N2142 graph stamp/write-back finds the stack-conveyor frame. Wiring in `SourceFactoryRuntimeState.simulate_factory`: preload `source_stack_conveyor_build_state` (:42) + call `source_stack_conveyor_tick_buildings_state(game, delta)` (:473, immediately after the liquid-bridge call :462).

Documented limits in the pure function's comment, same discipline as N2148–N2179: (1) power-only first pass — the surge-conveyor's static power consumer (consumePower 1f/60f, Blocks.java:2251) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); surge-conveyor has no second consumer. (2) NO shouldConsume gate to defer — StackConveyorBuild has no shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) applies; the power-only fold is EXACT for this family. (3) No updateTile advance — eff fold / cooldown reel / link gate / transfer branch (StackConveyor.java:268-315) wait for their own slices; the proof carries no reel / cooldown / transfer / link keys, the eff fold (StackConveyor.java:270) is what the efficiency keys prove. (4) No sense modeling — sense waits for its own slice. (5) Single def — surge-conveyor only (size 1, speed 5f/60f, itemCapacity 10, health 130, surge-alloy 1 / tungsten 1); plastanium-conveyor (StackConveyor, no power def) is explicitly OUT of scope; per-def stat values wait for their own verification slice. (6) No draw/config modeling — draw / drawSelect / config wait for their own slices.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_stack_conveyor_power_status.py` + register script `tools/mindustry_godot_transpiler/register_c07_stack_conveyor_power_status.py` written, modeled on the N2179 pair. Register script: EXACT_EXPRS = the 56 verified exprs (all 56 unique, all present verbatim in upstream — script check, 0 missing), DEFERRED 187 entries (177 inherited + 10 new StackConveyor entries, prefix byte-identical to N2179's list).

RED run: Ran 4 tests, FAILED (failures=1, errors=3) — exactly as expected for a new-file slice: registration KeyError 'N2180' (no ledger entry yet), exact-evidence KeyError 'N2180', row-state FileNotFoundError on the not-yet-existing `SourceStackConveyorBuildState.gd`, proof test `assertIsNotNone(godot)` (no Godot on PATH in the worker shell + missing `C07StackConveyorPowerStatusProof.tscn`) — all four fail for the expected missing-artifact reasons, none passes spuriously. Port 7777 was FREE before the run. 56/56 exact exprs verified verbatim at scoping (script check, 0 missing). SSOT baseline 11368/1630/1551/2893, audit 1335. `git diff --check` OK.

**Shard question resolved at RED:** NO new shard expected. No `stack_conveyor` / `distribution` shard selection matches StackConveyor.java (the N2171 MassDriver / N2178 ItemBridge / N2179 LiquidBridge precedent — java_source under `world/blocks/distribution/`, in the root ledger only) — verified at the GREEN register run: no `source_modules` shard changed.

**VM restart between ~01:29 and ~01:30 +07** (the 5th restart of the night; uptime 0 min at the 01:30 check). javalang wiped by the restart and **reinstalled 0.13.0 by the 01:30 cron run** (`pip install --break-system-packages -r tools/mindustry_godot_transpiler/requirements.txt`, verified `import javalang` OK). Godot binary intact (`~/workspace/godot-bin/godot` → 4.6.2-stable).

## GREEN

- New `godot-mindustry/src/game/SourceStackConveyorBuildState.gd` (radar N2173 / liquid-bridge N2179 precedent): pure row + tick-frame + bind + driver, plain `block.properties.has("consumePower")` gate — static power, no RepairTurret-style adaptation; folds via `update_consumption_state` with has_consumers=true. Header quotes all 56 exact exprs, each on ONE comment line. All 6 documented limits recorded in the pure function's comment. NO shouldConsume gate to defer — StackConveyorBuild has no override, BuildingComp default `return enabled;` applies, power-only fold is EXACT.
- Frame key `"source_stack_conveyor_building"` appended to `SOURCE_CONSUMER_FRAME_META_KEYS` (SourcePlacedPowerGraphState.gd, after the liquid-bridge key). Wiring in `SourceFactoryRuntimeState.simulate_factory`: preload (:42) + call immediately after the liquid-bridge call (:473).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07StackConveyorPowerStatusProof.gd` + `.tscn` (N2179 model, 6 keys + registry_valid / one_headquarter_per_ssot / matches). Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run: SSOT **11370/1631/1552/2895** — exactly the expected values (+2/+1/+1/+2); audit 1335 unchanged; ledger N2180 status done. No source_modules shard changed — no shard selection matches StackConveyor.java (the N2171/N2178/N2179 precedent, decided at RED).
- Targeted: **Ran 4 tests in 15.710s, OK** (Godot 4.6.2 on PATH). Port 7777 FREE before the run. `git diff --check` OK.
- Godot proof (inside the targeted run, Linux headless 4.6.2): **9 keys all true, matches:true** — `stack_conveyor_has_power_consumer`, `power_row_half`, `power_row_absent_without_consumer`, `power_row_null_folds_one`, `efficiency_folds_power_min`, `efficiency_zero_at_no_power`, `registry_valid`, `one_headquarter_per_ssot`, `matches`. No ERROR in output.

## Neighbours

Family run ~01:13 +07: **Ran 144 tests in 468.684s, OK** — 36 modules (35 at N2179 + the new stack-conveyor module), Godot 4.6.2 on PATH, port 7777 FREE at launch. Clean run, ZERO port-7777 flakes this time (no isolated re-run needed). No regression from N2180.

Wiring-standard set (9 modules / 32 tests, the N2177 lesson) run by the main thread ~01:19 +07: test_factory_live_loop 4/4, test_power_graph_live_update_binding 3/3, test_battery_power_status_binding 3/3, test_battery_placement_binding 3/3, test_adjacent_factory_live_loop 4/4, test_unit_factory_live_loop 4/4, test_turret_live_loop 4/4, test_continuous_liquid_turret_live_loop 3/3, test_power_graph_consumer_cheating 4/4 — **32/32 OK**.

Neighbours final: targeted **4/4 OK**; family **144/144 OK**; wiring **32/32 OK**. Total **180/180 OK**. No regression from N2180.

**Worker-lesson correction (01:15 run):** the 01:15 worker claimed the wiring module list "is not recorded in the N2177/N2179 handoffs" — wrong, the list IS recorded (MEMORY.md + the N2177 main-thread chain) — and the family run does NOT cover these modules. The main thread's wiring re-run above is the correction.

## Gate

Full gate attempt 1 (worker-launched ~01:09, mislabeled "main thread" in the handoff): log frozen at 3,602 bytes — 3,490 dots + 107 F + 5 s = 3,597 tests, NO footer, no process. Died ~01:15 +07 when the worker session timed out.

Full gate attempt 2 (launched by the 01:15 cron run ~01:17 +07, PID 14203): log frozen at 3,605 bytes — 3,493 dots + 107 F + 5 s = 3,598 tests, NO footer, PID not running. Died ~01:18:29 +07 when that worker session ended.

**Lesson (proven twice in a row): worker-launched gates die with the worker session even with setsid nohup — only main-thread launches survive.** Workers must NOT launch gates. The 01:15 worker's cause theory ("Godot of the other agent stopped, suspected VM issue") is wrong — no VM restart (uptime 1h46m), javalang OK; the sessions ending killed the gates.

Full gate attempt 3 (launched by the MAIN THREAD ~01:21 +07, PID 14713, SID 14713): log frozen at 5,479 bytes — 5,359 dots + 115 F + 5 s = 5,479 tests (~94% of ~5,817), NO footer. Died on the **VM restart ~01:29:57 +07** (uptime 2 min at the 01:32 check) — the 5th restart of the night. The 115 F at 94% is on pace for the expected ~131 Godot-absent failures. Environmental death, unlike attempts 1–2 (worker-session deaths).

Full gate attempt 4 **launched from the MAIN THREAD ~01:33 +07**: `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2180-gate.log 2>&1 < /dev/null &` — **PID 1944, SID 1944 (own session), PPID 1941 (background subshell), CPU ~86%, log growing**. Single gate only. No Godot on PATH. No proof scene ran while the gate ran (port-7777 rule).

Finished ~01:49 +07 (log mtime 01:49 +07): **Ran 5817 tests in 972.474s, FAILED (failures=131, skipped=5)** — no errors field, 0 `ERROR:` lines. All 131 verified Godot-absent (grep on the log): **131 × `AssertionError: unexpectedly None`** (the N2175 lesson — count by the error message, not the exact-no-message-arg awk), including the new N2180 proof test (`test_reference_graph_and_actual_c07_stack_conveyor_power_status`, log line 459), 0 port-7777 bind errors. The gate is clean except Godot — exactly as expected (130 inherited + 1 new). No VM restart during the gate (boot 01:30, uptime 30 min at 02:00, javalang 0.13.0 still present). Gate back to normal speed (972.5s vs N2179's 949.5s, N2178's 1041.9s).

## Commits

- Slice: `<hash>` — C07: N2180 StackConveyor power.status live read (surge-conveyor; pure power row + driver wiring; proof 6 keys), 11 files.
- Docs: `<hash>` — Docs: N2180 report + design spec + handoff (gate clean except Godot).
- GOAL: `<hash>` — Docs: GOAL.md names the N2180 slice commit that carries its proof to Windows (§5 debt line).
- Pushed 2026-11-15 ~02:1x +07 to the fork (Lasthope1508). See the handoff Commits section for the hashes.

## Deferred (NOT this slice)

- StackConveyor updateTile advance (eff fold / cooldown reel / link gate / transfer branch, StackConveyor.java:268-315) — its own slice.
- sense modeling — its own slice.
- Draw / config modeling (draw / drawSelect / config) — their own slices.
- Per-def stat values (size 1, speed 5f/60f, itemCapacity 10, health 130, surge-alloy 1 / tungsten 1) — their own verification slice.
- plastanium-conveyor (StackConveyor, no power def) — explicitly OUT of scope; its transport does not depend on power.status.
- Next candidates (verified in the N2178/N2179 reports, not yet scoped): StackRouter (surge-router, 3f/60f = 0.05), ImpactReactor (impact-reactor, consumePower 25f BUT outputsPower true — generator, consume-vs-produce needs care at scoping), Accelerator (interplanetary-accelerator, 10f), BuildTurret (build-tower, 3f, Blocks.java:2005).
