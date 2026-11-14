# Report — N2183: Accelerator power.status live read (interplanetary-accelerator) (C07)

Date: 2026-11-15. Batch: N2183 (single slice). Status: **DONE (2026-11-15 ~06:0x +07 — targeted 4/4 OK, neighbours 192/192 OK, Godot proof GREEN 9 keys matches:true, full gate attempt 1 Ran 5829 in 1181.043s, failures=134, skipped=5, 0 errors — all 134 verified Godot-absent asserts). Slice commit `<hash>`.**

## What changed

The next `power.status` consumer family after the N2182 impact-reactor slice: the Accelerator implementation family — a SINGLE def, **interplanetary-accelerator** (`consumePower(10f)`, Blocks.java:6829; `powerBufferRequirement = 1_000_000f;` Blocks.java:6826, `size = 7;` Blocks.java:6827, `scaledHealth = 80;` Blocks.java:6831, `researchCostMultiplier = 0.1f;` Blocks.java:6825, `buildCostMultiplier = 0.5f;` Blocks.java:6830, requirements copper 16000 / silicon 11000 / thorium 13000 / titanium 12000 / surge-alloy 6000 / phase-fabric 5000, Blocks.java:6824, Category.effect, BuildVisibility.campaignOnly, Blocks.java:6823-6824). `Accelerator extends Block` (Accelerator.java:35), `AcceleratorBuild extends Building implements LaunchAnimator` (Accelerator.java:119). Catalog confirms implementation Accelerator + hasPower true + consumesPower true + consumePower 10.0 + outputsPower false + powerUsage 10.0 + health 3920 (content_registry_blocks.json, `content_registry.blocks.interplanetary-accelerator`). Blocks.java defs are the source of truth, see Exact exprs in the handoff.

The accelerator had NO driver at all — no `SourceAccelerator*` file exists in godot-mindustry/src/game, no `"Accelerator"` entry in any `SOURCE_*_IMPLEMENTATIONS` list (grep for `"Accelerator"` in `godot-mindustry/src/game/` returns nothing), and no frame key existed, so the N2142 stamp never reached an accelerator frame. The Incinerator lesson was applied: the candidate was checked for an existing driver before scoping.

**Naming note:** "Accelerator" is a campaign/effect block (`world/blocks/campaign/Accelerator.java`), NOT related to any factory/turret/defense/bridge/conveyor/router/power-generator family. Single def **interplanetary-accelerator** (Blocks.java:6823), Category.effect.

**Battery care (the scoping question):** the accelerator is a LAUNCH block — its canLaunch needs BOTH efficiency AND a full battery: `return isValid() && !net.client() && state.isCampaign() && efficiency > 0f && power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f && progress >= 1f && !launching;` (Accelerator.java:240, `public boolean canLaunch(){` :239). The row this slice folds is the CONSUMER-side read (`return build.power.status;`, ConsumePower.java:39), exactly like every pure-consumer slice; the BATTERY side (`getBatteryStored` / `useBatteries`, Accelerator.java:240, 270, and the powerBufferRequirement bar, Accelerator.java:105-109, `() -> b.power.graph.getBatteryStored() / powerBufferRequirement`) waits for its own slice. The power-only fold is EXACT for the efficiency side: without it the port would behave as if power.status were 1.0 and the accelerator would charge progress at full speed with no power.

**Power is STATIC here** — unlike RepairTurret's conditional draw: `consumePower(10f)` registers a plain ConsumePower, so the catalog `consumePower: 10.0` is present and the plain radar gate `block.properties.has("consumePower")` works — no RepairTurret-style `or consumesPower` adaptation needed. The pure row is the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39).

**shouldConsume — NO override, so NO gate to defer:** AcceleratorBuild has no shouldConsume override (grep finds none in Accelerator.java), so the BuildingComp default applies (`public boolean shouldConsume(){`, BuildingComp.java:755, with `return enabled;`, :756). When the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994). There is NO gate to defer here: the power-only fold is EXACT for this family, because the only gate is `enabled`, which the driver already checks.

The efficiency coupling that makes this slice matter: updateTile advances progress ONLY by efficiency — `if(efficiency >= 0f){` (:142) / `progress += Time.delta * efficiency / buildDuration;` (:143), `progress = Math.min(progress, 1f);` (:144) — with `heat = Mathf.lerpDelta(heat, launching ? 1f : efficiency, 0.05f);` (:131) and `statusLerp = Mathf.lerpDelta(statusLerp, power.status, 0.05f);` (:132) tracking the same two values, and `time += Time.delta * efficiency;` (:135) when not launching. At efficiency 0 the progress never reaches 1f, `isCoreBuilt()` (`return progress >= 1f;`, :154) never becomes true, and canLaunch never passes — while the port without this slice would charge at full speed. The item consumption (`consumeItems launchBlock.requirements`, :91; `getMaximumAccepted` / `acceptItem`, :293-299) rides on the launch, not the tick — the tick models the power row only; the item rows wait for their own slices, so the folded efficiency is the min over the modeled consumers (power only).

New file `godot-mindustry/src/game/SourceAcceleratorBuildState.gd`, class_name SourceAcceleratorBuildState, with `SOURCE_ACCELERATOR_BUILD_IMPLEMENTATIONS := ["Accelerator"]` and frame meta key `"source_accelerator_building"`:

- Pure `source_accelerator_power_status_row_state(frame, has_power_consumer)` (mirrors `source_impact_reactor_power_status_row_state`): without a consumer → `{"has_power_row": false, "row": {}}`; else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469).
- `source_accelerator_tick_frame_state` (mirrors the impact-reactor tick-frame: block_implementation / team_id / rules_state / cheating via TeamComp.cheating(), preserve disabled frame).
- `source_accelerator_bind_frame_state` (mirrors the impact-reactor bind: empty frame under the accelerator meta key, no-op for other blocks / already-bound sprites).
- Driver `source_accelerator_tick_buildings_state(game, seconds)` (mirrors the impact-reactor driver: iterate placed buildings, match implementation, bind frame, tick frame, when the block has the static power consumer (`block.properties.has("consumePower")`) and enabled and not cheating fold the pure row via `source_building_efficiency_state.update_consumption_state(true, ...)` with has_consumers=true — the power consumer counts toward hasConsumers, Block.java:1449 — and apply it; no consumer actors, no launch/battery tick, no updateTile progress/launch advance).

Header quotes all 73 exact exprs, each on ONE comment line. All 6 documented limits recorded in the pure function's comment.

New frame key `"source_accelerator_building"` added to `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS` so the N2142 graph stamp/write-back finds the accelerator frame. Wiring in `SourceFactoryRuntimeState.simulate_factory`: preload + call `source_accelerator_tick_buildings_state(game, delta)` immediately after the impact-reactor call.

Documented limits in the pure function's comment, same discipline as N2148–N2182: (1) power-only first pass — the accelerator's static power consumer (consumePower 10f, Blocks.java:6829) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); battery (`getBatteryStored` / `useBatteries`, powerBufferRequirement 1_000_000f) and item (launchBlock.requirements) rows wait for their own slices. (2) NO shouldConsume gate to defer — AcceleratorBuild has no shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) applies; the power-only fold is EXACT. (3) No updateTile progress/launch advance — heat / statusLerp / time / progress / launchHeat (Accelerator.java:131-154) and the launch itself (:239-270) wait for their own slices; the proof carries no progress / launch keys, the eff fold is what the efficiency keys prove. (4) No sense modeling — sense waits for its own slice. (5) Single def — interplanetary-accelerator only (size 7, health 3920, powerBufferRequirement 1_000_000f); per-def stat values wait for their own verification slice. (6) No draw/config modeling — draw / drawSelect / config wait for their own slices.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_accelerator_power_status.py` (385 lines) + register script `tools/mindustry_godot_transpiler/register_c07_accelerator_power_status.py` (165 lines) written, modeled on the N2182 pair (test written fresh with Accelerator prose; register script via transform `/tmp/n2183_transform.py` — targeted identifier swaps on head/tail only, inherited DEFERRED kept verbatim, docstring + EXACT_EXPRS replaced wholesale, 11 new Accelerator-family DEFERRED entries appended). Register script: EXACT_EXPRS = the 73 verified exprs (all 73 unique, all present verbatim in upstream — script check, 0 missing), DEFERRED 220 entries (209 inherited + 11 new Accelerator-family entries).

RED run: Ran 4 tests, FAILED (failures=1, errors=3) — exactly as expected for a new-file slice: registration KeyError 'N2183' (no ledger entry yet), exact-evidence KeyError 'N2183', row-state FileNotFoundError on the not-yet-existing `SourceAcceleratorBuildState.gd`, proof test `assertIsNotNone(godot)` (no Godot on PATH in the worker shell + missing `C07AcceleratorPowerStatusProof.tscn`) — all four fail for the expected missing-artifact reasons, none passes spuriously. Port 7777 was FREE before the run. 73/73 exact exprs verified verbatim at scoping (script check, 0 missing). SSOT baseline 11374/1633/1554/2899, audit 1335. `git diff --check` OK.

**Shard question resolved at RED:** NO shard expected to change — no manifest selection matches `world/blocks/campaign/` (selections cover `/world/blocks/power/`, `/world/blocks/production/`, `/world/blocks/defense/`, `/world/blocks/payloads/`, `/entities/comp/`, `/entities/bullet/`, `/type/`, `/world/consumers/`; grep for "campaign" in `source_ssot_modules.json` returns 0). The N2182 power-shard exception does not apply here; the N2178–N2181 precedent (no shard changed) holds — verified at the GREEN register run: no `source_modules/` entry in git status.

**Transform-script bug found and fixed in this run:** the first transform inserted the new DEFERRED entries with a leading `', '` after `deferred[:close]`, which already ends with the last entry's trailing comma — producing `',, '` and a SyntaxError at line 96. Fixed in `/tmp/n2183_transform.py` (join with a space only) and re-ran clean. Lesson for the next transform: `deferred[:close]` already carries the trailing comma.

**VM restarted during this run** (restart #7, ~05:32 +07; uptime 0 min at 22:32 UTC; boot ~03:30 +07 before it — that boot was restart #6) — javalang wiped and reinstalled 0.13.0 (`pip install --break-system-packages -r tools/mindustry_godot_transpiler/requirements.txt` from the repo root) before any test work, per the MEMORY rule. Port 7777 FREE at run start. Godot binary exists at `~/workspace/godot-bin/godot` (4.6.2-stable, build 71f334935) but is NOT on PATH in the worker shell — the GREEN proof run must export `PATH="$HOME/workspace/godot-bin:$PATH"` first (the N2177 main-thread re-run had it on PATH).

## GREEN

- New `godot-mindustry/src/game/SourceAcceleratorBuildState.gd` (impact-reactor N2182 precedent): pure row + tick-frame + bind + driver, plain `block.properties.has("consumePower")` gate — static power, no RepairTurret-style adaptation; folds via `update_consumption_state` with has_consumers=true. Header quotes all 73 exact exprs, each on ONE comment line. All 6 documented limits recorded in the pure function's comment. NO shouldConsume gate to defer — AcceleratorBuild has no override, BuildingComp default `return enabled;` applies, power-only fold is EXACT.
- Frame key `"source_accelerator_building"` appended to `SOURCE_CONSUMER_FRAME_META_KEYS` (SourcePlacedPowerGraphState.gd:140, end of list after the impact-reactor key). Wiring in `SourceFactoryRuntimeState.simulate_factory`: preload + call immediately after the impact-reactor call.
- Proof scene `godot-mindustry/tools/runtime_proofs/C07AcceleratorPowerStatusProof.gd` + `.tscn` (N2182 model, 6 keys + registry_valid / one_headquarter_per_ssot / matches). Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run: SSOT **11376/1634/1555/2901** — exactly the expected values (+2/+1/+1/+2); audit 1335 unchanged; ledger N2183 status done. NO shard changed (see RED above).
- Targeted: **Ran 4 tests in 16.072s, OK** (Godot 4.6.2 on PATH). Port 7777 FREE before the run. `git diff --check` OK.
- Godot proof (inside the targeted run, Linux headless 4.6.2): **9 keys all true, matches:true** — `accelerator_has_power_consumer`, `power_row_half`, `power_row_absent_without_consumer`, `power_row_null_folds_one`, `efficiency_folds_power_min`, `efficiency_zero_at_no_power`, `registry_valid`, `one_headquarter_per_ssot`, `matches`. No ERROR in output.

## Neighbours

Family run ~05:2x +07 (39 modules, 156 tests — 38 at N2182 + the new accelerator module), Godot 4.6.2 on PATH, port 7777 FREE at launch. **Ran 156 tests in 518.354s, OK** — footer verified by main thread. 39 modules / 156 tests, ZERO flakes this time.

Wiring-standard set (9 modules / 32 tests, the N2177 lesson) — **VM restart #7 (~05:32 +07) killed the main thread's wiring loop (PID 16074, on module 2/9) mid-run**, so the stale `n2183-wiring.log` (18 dots, 22:30) is that dead run. After javalang reinstall, the 05:30 worker re-ran the wiring set detached (`n2183-wiring-0532.log`): **9/9 modules OK, 32/32 tests** (4+3+3+3+4+4+4+3+4), 0 failures, 0 port-7777 flakes, ~19–20s per module.

**Correction — uncoordinated duplication + contention:** the 05:30 worker did NOT know the main thread had also reinstalled javalang and re-launched its own wiring loop (~05:34, backgrounded) — so TWO wiring loops ran Godot proofs in parallel ~05:34–05:37. The main thread's first loop failed 8/9 (port-7777 contention + restart); isolated re-runs (7 + 1) all OK, wiring final 32/32 — both loops agree on the final result, but the parallel runs were the likely cause of the contention. Same cause probably explains the targeted flakiness below — the "first runs after reboot" theory is WITHDRAWN.

Targeted re-run post-restart — TRANSIENT flake, then stable: first run FAILED (failures=1, test name not captured — tail -3 only), `-v` re-run 4/4 OK, next plain run FAILED (failures=1) again, then **5 consecutive OK runs** (1 plain + 4 loop runs). Total post-restart: 6 OK / 2 FAIL, both failures while the main thread's parallel wiring loop was running Godot proofs — most likely port-7777 contention, not a slice regression. No code fix was needed or made; the slice code is unchanged since the 05:15 worker's green.

Neighbours final: targeted **4/4 OK**; family **156/156 OK**; wiring **32/32 OK**. Total **192/192 OK**. No regression from N2183.

**Worker-lesson correction (05:45 run):** the 05:30 worker's first draft called the restart #6 — WRONG, it is #7 per the memory log (boot ~03:30 +07 was restart #6). Count restarts from the memory log, not from the current boot alone.

## Gate

Full gate attempt 1 **launched from the MAIN THREAD ~05:39 +07**: `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2183-gate.log 2>&1 < /dev/null &` — **PID 2560, SID 2560 (own session), PPID 2557 (background subshell), CPU ~76%, log growing**. Single gate only. No Godot on PATH. No proof scene ran while the gate ran (port-7777 rule).

Finished ~05:58 +07 (log mtime 05:58:30 +07): **Ran 5829 tests in 1181.043s, FAILED (failures=134, skipped=5)** — no errors field, 0 `ERROR:` lines. All 134 verified Godot-absent (grep on the log): **134 × `AssertionError: unexpectedly None`** (the N2175 lesson — count by the error message, not the exact-no-message-arg awk), including the new N2183 proof test (`test_reference_graph_and_actual_c07_accelerator_power_status`, log line 203), 0 port-7777 bind errors. The gate is clean except Godot — exactly as expected (133 inherited + 1 new). No VM restart during the gate (restart #7 was ~05:32, before launch; uptime 29 min at 06:01, javalang 0.13.0 still present). Gate slower than N2182 (1181.0s vs 988.8s) — slow mode after restart #7.

## Commits

- Slice: `<hash>` — C07: N2183 Accelerator power.status live read (interplanetary-accelerator; pure power row + driver wiring; proof 6 keys), 11 files.
- Docs: `<hash>` — Docs: N2183 report + design spec + handoff (gate clean except Godot).
- GOAL: `<hash>` — Docs: GOAL.md names the N2183 slice commit that carries its proof to Windows (§5 debt line).
- Pushed 2026-11-15 ~06:1x +07 to the fork (Lasthope1508). See the handoff Commits section for the hashes.

## Deferred (NOT this slice)

- Battery side: `getBatteryStored()` / `useBatteries(powerBufferRequirement)` / powerBufferRequirement bar (Accelerator.java:105-109, 240, 270) — its own slice.
- updateTile progress/launch advance: heat / statusLerp / time / progress / launchHeat lerps (Accelerator.java:131-154), launch sequence (Accelerator.java:239-270) — their own slices.
- Item consumption rows (`consumeItems launchBlock.requirements`, `getMaximumAccepted` / `acceptItem`, Accelerator.java:91, 293-299) — their own slices.
- sense modeling — its own slice.
- Draw / config modeling (draw / drawSelect / config) — their own slices.
- Per-def stat values (size 7, health 3920, powerBufferRequirement 1_000_000f, launchDuration 120f, chargeDuration 220f, buildDuration 120f) — their own verification slice.
- Next candidates (verified in the N2182 report, not yet scoped): BuildTurret (build-tower, 3f, Blocks.java:2005).
