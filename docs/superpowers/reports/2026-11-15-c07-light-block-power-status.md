# Report — N2185: LightBlock power.status live read (illuminator) (C07)

Date: 2026-11-15. Batch: N2185 (single slice). Status: **DONE (2026-11-15 ~08:4x +07 — targeted 4/4 OK, neighbours 200/200 OK, Godot proof GREEN 9 keys matches:true, full gate attempt 1 Ran 5837 in 985.588s, failures=136, skipped=5, 0 errors — all 136 verified Godot-absent asserts). Slice commit `ffe1153`.**

## What changed

The LAST `power.status` consumer family still lacking a C07 driver: the LightBlock implementation family — a SINGLE def, **illuminator** (`consumePower(0.05f)`, Blocks.java:6767). `LightBlock extends Block` (LightBlock.java), build `LightBuild extends Building`. Class defaults: brightness 0.9f, radius 200f; `hasPower = true`, `update = true`, `configurable = true`, `envEnabled |= Env.space`. Catalog confirms implementation LightBlock + hasPower true + consumesPower true + consumePower 0.05. Blocks.java defs are the source of truth, see Exact exprs in the handoff.

The illuminator had NO driver at all — no `SourceLightBlock*` file exists in godot-mindustry/src/game, no `"LightBlock"` entry in any `SOURCE_*_IMPLEMENTATIONS` list, and no frame key existed, so the N2142 stamp never reached an illuminator frame. The driver question was checked before scoping (the N2178/N2179/N2180/N2181/N2182/N2183/N2184 precedent).

**Correction of the N2184 handoff's "Next: N2185 Drill":** Drill was already done as **N2147** (spec line 225: "N2147: drill power.status live read, laser-drill (consumePower 1.10f) + blast-drill (consumePower 3f) base Drill family (C07)"). The 07:45 worker verified this against the spec. **N2185 is LightBlock** — the only remaining consumePower slice lacking a C07 power driver (catalog scan in the N2184 handoff: 100 defs with a real numeric consumePower, 48 distinct implementations; only Drill and LightBlock still lacked a driver — Drill is N2147, so LightBlock is the last one).

**shouldConsume — NO override, so NO gate to defer:** LightBuild has NO shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) applies; the power-only fold is EXACT, no deferral needed.

**Power is STATIC here** — `consumePower(0.05f)` registers a plain ConsumePower, so the catalog `consumePower: 0.05` is present and the plain radar gate `block.properties.has("consumePower")` works — no RepairTurret-style `or consumesPower` adaptation needed. The pure row is the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39).

The efficiency coupling that makes this slice matter: drawLight folds `brightness * efficiency` (LightBlock.java:128); updateTile lerps smoothTime toward timeScale (:104-107). At efficiency 0 the light draws nothing, while the port without this slice would behave as if power.status were 1.0.

New file `godot-mindustry/src/game/SourceLightBlockBuildState.gd`, class_name SourceLightBlockBuildState, with `SOURCE_LIGHT_BLOCK_BUILD_IMPLEMENTATIONS := ["LightBlock"]` and frame meta key `"source_light_block_building"`:

- Pure `source_light_block_power_status_row_state(frame, has_power_consumer)` (mirrors `source_build_turret_power_status_row_state`): without a consumer → `{"has_power_row": false, "row": {}}`; else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469).
- `source_light_block_tick_frame_state` (mirrors the build-turret tick-frame: block_implementation / team_id / rules_state / cheating via TeamComp.cheating(), preserve disabled frame).
- `source_light_block_bind_frame_state` (mirrors the build-turret bind: empty frame under the light-block meta key, no-op for other blocks / already-bound sprites).
- Driver `source_light_block_tick_buildings_state(game, seconds)` (mirrors the build-turret driver: iterate placed buildings, match implementation, bind frame, tick frame, when the block has the static power consumer (`block.properties.has("consumePower")`) and enabled and not cheating fold the pure row via `source_building_efficiency_state.update_consumption_state(true, ...)` with has_consumers=true — the power consumer counts toward hasConsumers, Block.java:1449 — and apply it; no consumer actors, no updateTile advance).

Header quotes all 82 exact exprs, each on ONE comment line. All documented limits recorded in the pure function's comment.

New frame key `"source_light_block_building"` added to `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS` so the N2142 graph stamp/write-back finds the light-block frame. Wiring in `SourceFactoryRuntimeState.simulate_factory`: preload (`:47`) + call `source_light_block_tick_buildings_state(game, delta)` (`:530`) immediately after the build-turret call (`:520`).

Documented limits in the pure function's comment, same discipline as N2148–N2184: (1) power-only first pass — the illuminator's static power consumer (consumePower 0.05f, Blocks.java:6767) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only). (2) No updateTile advance — smoothTime lerp (LightBlock.java:104-107) waits for its own slice; the proof carries no smoothTime key, the brightness fold (LightBlock.java:128) is what the efficiency keys prove. (3) No drawLight modeling beyond the efficiency fold — draw / write / read wait for their own slices. (4) No sense modeling — sense waits for its own slice. (5) Single def — illuminator only (brightness 0.9f, radius 200f); per-def stat values wait for their own verification slice. (6) No config modeling — config waits for its own slice.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_light_block_power_status.py` (336 lines) + register script `tools/mindustry_godot_transpiler/register_c07_light_block_power_status.py` (158 lines) written by the 07:45 worker. Register script: EXACT_EXPRS = the 82 verified exprs (all 82 unique, all present verbatim in upstream — script check, 0 missing), DEFERRED 241 entries.

RED run: Ran 4 tests, FAILED (failures=1, errors=1) — NOT the usual (failures=1, errors=3): because the register already ran, the registration + exact-evidence tests already pass. Remaining failures are the expected RED reasons: ERROR `test_light_block_power_status_row_state` — FileNotFoundError on the not-yet-existing `SourceLightBlockBuildState.gd`; FAIL `test_reference_graph_and_actual_c07_light_block_power_status` — Godot ran but `Cannot open file 'res://tools/runtime_proofs/C07LightBlockPowerStatusProof.tscn'` (proof scene not yet written). No other failures. Port 7777 was FREE before the run. 82/82 exact exprs verified verbatim at scoping (script check, 0 missing). SSOT baseline 11378/1635/1556/2903, audit 1335. `git diff --check` OK.

**Shard question resolved at RED:** the power shard WILL change (LightBlock.java lives at `core/src/mindustry/world/blocks/power/LightBlock.java`, matching the power shard selection `java_source contains /world/blocks/power/` — the N2182 precedent): power_slices 110→111, power_api_contracts 89→90 (verified at the RED register run).

**Transform-script bugs found and fixed in this run:** two bugs, both caught by the targeted run (3/4 before the fix): the `BuildTurretBuild` → `LightBuild` swap corrupted the proof preload `SourceBuildTurretBuildState` → `SourceLightBuildState` (parse error: preload file does not exist) — fix: swap the full class name `SourceBuildTurretBuildState` → `SourceLightBlockBuildState` FIRST, then `BuildTurretBuild` → `LightBuild` (lesson: a class-name swap must precede any substring swap that overlaps it); the proof's `SOURCE_BUILD_TURRET_BUILDING_META_KEY` (uppercase const) survived all swaps — none of them matched the uppercase token — fix: explicit const-name swap + direct fix in the proof file (3 occurrences) (lesson: check uppercase const tokens separately after a transform).

**VM restart #8 ~07:31 +07** (uptime 40 min at the 08:00 check): javalang wiped, reinstalled 0.13.0 by the 08:00 worker before GREEN. No work lost (GREEN files + SSOT survived in ~/workspace). Port 7777 FREE at run start.

## GREEN

- New `godot-mindustry/src/game/SourceLightBlockBuildState.gd` (224 lines; build-turret N2184 precedent): pure row + tick-frame + bind + driver, plain `block.properties.has("consumePower")` gate — static power, no RepairTurret-style adaptation; folds via `update_consumption_state` with has_consumers=true. Header quotes all 82 exact exprs, each on ONE comment line. All documented limits recorded in the pure function's comment. shouldConsume — NO override, so NO gate to defer (BuildingComp default `return enabled;`).
- Frame key `"source_light_block_building"` appended to `SOURCE_CONSUMER_FRAME_META_KEYS` (SourcePlacedPowerGraphState.gd:140, end of list after the build-turret key). Wiring in `SourceFactoryRuntimeState.simulate_factory`: preload `:47` + driver call `:530` immediately after the build-turret call `:520`.
- Proof scene `godot-mindustry/tools/runtime_proofs/C07LightBlockPowerStatusProof.gd` + `.tscn` (N2184 model, 6 keys + registry_valid / one_headquarter_per_ssot / matches). Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run (by the 07:45 RED worker, after writing the handoff — so the handoff RED section's "no tracked files changed yet" is stale): SSOT **11380/1636/1557/2905** — exactly the expected values (+2/+1/+1/+2); audit 1335 unchanged; ledger N2185 status done. Power shard DID change (see RED above): power_slices 110→111 (+18 lines), power_api_contracts 89→90 (+32 lines), purely additive N2185 mirrors.
- Targeted: **Ran 4 tests in 15.935s, OK** (Godot 4.6.2 on PATH). Port 7777 FREE before the run. `git diff --check` OK.
- Godot proof (inside the targeted run, Linux headless 4.6.2): **9 keys all true, matches:true** — `light_block_has_power_consumer`, `power_row_half`, `power_row_absent_without_consumer`, `power_row_null_folds_one`, `efficiency_folds_power_min`, `efficiency_zero_at_no_power`, `registry_valid`, `one_headquarter_per_ssot`, `matches`. No ERROR in output.

## Neighbours

Family run ~08:2x +07 (41 modules, 164 tests — 40 at N2184 + the new light-block module), Godot 4.6.2 on PATH, port 7777 FREE at launch — log `tools/mindustry_godot_transpiler/n2185-neighbours.log`. **Ran 164 tests in 557.192s, OK** — FAMILY EXIT 0, ZERO flakes. 41 modules / 164 tests. VM back to normal speed after restart #8 (family 557s vs N2184's 595s).

Wiring-standard set (9 modules / 32 tests, the N2177 lesson) — main thread ~08:23, sequentially after the family run (one script, no parallel Godot runs, no port-7777 contention): **ALL OK (4+3+3+3+4+4+4+3+4)**, each module ~13–14s (normal speed restored).

Neighbours final: targeted **4/4 OK**; family **164/164 OK**; wiring **32/32 OK**. Total **200/200 OK**. No regression from N2185.

## Gate

Full gate attempt 1 **launched from the MAIN THREAD ~08:23 +07**: `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2185-gate.log 2>&1 < /dev/null &` — **PID 7659, SID 7659 (own session), PPID 7656 (background subshell), CPU ~91%, log growing**. Single gate only. No Godot on PATH. No proof scene ran while the gate ran (port-7777 rule).

Finished ~08:39 +07 (log mtime 01:39 UTC): **Ran 5837 tests in 985.588s, FAILED (failures=136, skipped=5)** — no errors field, 0 `ERROR:` lines. All 136 verified Godot-absent (grep on the log): **136 × `AssertionError: unexpectedly None`** (the N2175 lesson — count by the error message, not the exact-no-message-arg awk), including the new N2185 proof test (`test_reference_graph_and_actual_c07_light_block_power_status`, log line 323, `assertIsNotNone(godot)` — expected, no Godot on PATH in the gate), 0 port-7777 bind errors. The gate is clean except Godot — exactly as expected (135 inherited + 1 new). No VM restart during the gate (restart #8 was ~07:31, before launch; uptime 1:14 at 08:45, javalang 0.13.0 intact). Gate back to normal speed (985.6s vs N2184's 1198.2s).

## Commits

- Slice: `ffe1153` — C07: N2185 LightBlock power.status live read (illuminator; pure power row + driver wiring; proof 6 keys), 13 files.
- Docs: `<hash>` — Docs: N2185 report + design spec + handoff (gate clean except Godot).
- GOAL: `<hash>` — Docs: GOAL.md names the N2185 slice commit that carries its proof to Windows (§5 debt line).
- Pushed 2026-11-15 ~08:5x +07 to the fork (Lasthope1508). See the handoff Commits section for the hashes.

## Deferred (NOT this slice)

- shouldConsume gate: NONE — LightBuild has no shouldConsume override; the BuildingComp default (`return enabled;`) applies and the power-only fold is EXACT.
- updateTile advance: smoothTime lerp (LightBlock.java:104-107) — its own slice.
- drawLight modeling beyond the efficiency fold (LightBlock.java:128) — its own slice.
- sense modeling — its own slice.
- Draw / config modeling (draw / write / read) — their own slices.
- Per-def stat values (brightness 0.9f, radius 200f) — their own verification slice.
- Proof N2185 not yet run on Windows Godot (debt in GOAL.md §5, same as N2184).
- Next: C07 power.status is now COMPLETE for all catalog consumePower defs with a driver (per the 07:45 worker's scan — verify at scoping of the next slice); the remaining C07 work is the deferred shouldConsume gates / updateTile advances / second consumers, per the backlog.
