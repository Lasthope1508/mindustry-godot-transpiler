# Report — N2143: reconstructor constructTime catalog capture (C07)

Date: 2026-11-13. Batch: N2143 (single slice). Status: **DONE + PUSHED 2026-11-13 ~01:57 +07 (01:45 cron run). Targeted tests 4/4 OK, neighbours 35/35 OK, Godot proof GREEN, full gate verified clean except Godot (Ran 5669, failures=94, skipped=5, 0 errors — all 94 Godot-absent asserts). Commit + push to origin main (fork Lasthope1508) this run — see handoff for the commit hashes.**

## What changed

The deferred catalog follow-up named in the N2138, N2139 and N2142 handoffs ("catalog has no constructTime for reconstructor blocks, so the driver uses default 120.0 instead of the real 600 for additive-reconstructor — waits for a later catalog slice"). N2138 wired the reconstructor production tick and its pure function takes `construct_time` as an input (backed by the class default, Reconstructor.java:36), but the content catalog never captured the per-block override, so the tick driver read `block.properties.get("constructTime", 120.0)` and an additive-reconstructor upgraded on the 120.0 default instead of its real 600.0 (Blocks.java:6310), and a multiplicative-reconstructor on 120.0 instead of 1800.0 (Blocks.java:6330).

Composition, not re-implementation: the tick function (`source_reconstructor_production_tick_state`, N2138) already completes exactly when `progress >= constructTime` (Reconstructor.java:334); N2143 does not touch it. N2143 supplies the missing catalog capture (the craftTime pattern, N2117: the initializer's own assignment, else the class default) plus one pure read on the block so the driver stops inlining the fold.

Implemented in `tools/mindustry_godot_transpiler/mindustry_port/content_registry.py` (`_block_properties`, Reconstructor branch, next to the `upgrades` branch): capture `constructTime` — the block initializer's own assignment via `constructTime\s*=\s*([^;]+);` + `_numeric_expression_value`, else the class default from `class_sources["Reconstructor"]` (`public float constructTime = 60 * 2;`, Reconstructor.java:36). Both sides are multiplication expressions (`60f * 10f`, `60f * 30f`, `60 * 2`), so plain `_numeric_assignment` does not match. Regen via `transpile.py content` touches all **8** Reconstructor blocks in upstream — a correction to the RED expectation, which counted only additive/multiplicative: additive 600.0, multiplicative 1800.0, exponential 5400.0 (`60f * 60f * 1.5f`), tetrative 14400.0 (`60f * 60f * 4`), tank-refabricator 1800.0, ship-refabricator 3000.0, mech-refabricator 2700.0, prime-refabricator 3600.0 — all 8 verified verbatim against Blocks.java:6309/6329/6351/6372/6457/6474/6492/6512. `content_registry_blocks` shard rebuilt (+8 lines); `MindustryContentRegistry.gd` regen is a 1-line blob change.

Pure `SourceUnitFactoryBuildState.source_reconstructor_construct_time_state(block)` — follows the has_upgrade / plan-requirements pattern (block: Object, null-safe, `block.properties.get(...)`): returns `{"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_RECONSTRUCTOR_CONSTRUCT_TIME_STATE, "construct_time": float(block.properties.get("constructTime", 120.0))}`; null block → 120.0 (the Reconstructor.java:36 class default `60 * 2`). Owner constant `PORT_GAME_SOURCE_RECONSTRUCTOR_CONSTRUCT_TIME_STATE := "port_game.source_reconstructor_construct_time_state"` in `SourceRuntimeOwnerUnitBuildingRegistry.gd` (next to `PORT_GAME_SOURCE_RECONSTRUCTOR_PRODUCTION_TICK_STATE`). Driver rewire in `SourceUnitFactoryBuildState.gd` (~line 772): `var construct_time: float = float(block.properties.get("constructTime", 120.0))` becomes `var construct_time: float = float(source_reconstructor_construct_time_state(block).get("construct_time", 120.0))` — behavior-preserving; the fold lives in the pure function now.

`test_content_registry.py`: the reconstructor fixture in `test_block_registry_captures_reconstructor_upgrades_and_assembler_plans` extended — additive `constructTime = 60f * 10f;` → assert 600.0; **test_content_registry 11/11 OK**.

## Proof keys (new scene, 6 keys)

New scene `C07ReconstructorConstructTimeProof` (modeled on `C06ReconstructorProductionProof` — Main scene, campaign playable slice, `catalog.get_many("block")`, `RuntimeProofState`), prefix `C_07_RECONSTRUCTOR_CONSTRUCT_TIME_PROOF `:

- `additive_construct_time_600`: catalog additive-reconstructor `properties.get("constructTime")` == 600.0.
- `multiplicative_construct_time_1800`: catalog multiplicative-reconstructor == 1800.0.
- `read_default_120`: the pure read on `MindustryBlock.new({})` (empty properties) → construct_time 120.0.
- `read_additive_600`: the pure read on the catalog additive block → 600.0.
- `tick_completes_at_600`: `source_reconstructor_production_tick_state` with construct_time 600.0 (from the read), frame `{efficiency 1.0, payload {unit: "dagger"}, progress 599.0, time 0.0, speed_scl 1.0}`, has_upgrade true, upgrade "mace", in position, edelta 1.0, build speed 1.0, source_delta 1.0 → completed true, payload.unit "mace" (progress 599 + 1 = 600 >= 600).
- `tick_incomplete_below_600`: same call with progress 100.0 → progress 101.0, completed false.

## Verified numbers (measured in this VM)

- Test module `test_c07_reconstructor_construct_time.py`: **4/4 OK in 14.5s** (Godot on PATH, 01:30 cron run) — registration (ledger N2143, 1 new symbol, runtime proof, test names, deferred_exprs), exact-evidence (1 new symbol + 10 exprs over Reconstructor.java + Blocks.java, all found verbatim), source-text (pure function exists + the two quoted Java lines in its comment + driver calls it + owner constant + `"constructTime"` in the extractor + registry JSON 600.0/1800.0; proof has the 6 new keys), and the Godot proof test (6 new keys, all true, `matches: true`).
- RED run (01:15 cron run): 4 tests in 2.408s, FAILED (failures=2, errors=2), all expected — registration `KeyError: 'N2143'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure function did not exist yet), proof returncode 1 (proof scene did not exist yet).
- Neighbours (Godot on PATH, sequential, 01:30 cron run): **35/35 OK** — `test_c06_reconstructor_production_tick` (N2138) + `test_c06_unit_factory_production_tick` (N2137) + `test_c06_unit_assembler_production_tick` (N2139) + `test_c07_units_can_create` (N2140) + `test_c07_unit_group_counts` (N2141) + `test_c07_power_status_live` (N2142), each 4/4, plus `test_content_registry` 11/11.
- `git diff --check` clean.
- SSOT +1/+1/+1/+2 → **11297 / 1594 / 1515 / 2821**; audit stays 1335. No `unit_building_*` shard change: `unit_building_slices` selects only `java_source == UnitFactory.java`, so Reconstructor.java slices don't flow into it — same as N2138/N2139/N2140 precedent (root SSOT JSONs only).

## Gate / suite

- Test modules standalone: N2143 4/4 (proof green, see above); neighbours 35/35.
- Godot proof: **GREEN 2026-11-13 ~01:30 +07** (01:30 cron run) — 6 new keys all true, `matches: true`, on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- Full Python suite, inclusive gate with the N2143 module (log `tools/mindustry_godot_transpiler/full-suite-n2143-gate.log`, 211 modules): **FINISHED ~01:55 +07, VERIFIED clean except Godot in the 01:45 cron run — Ran 5669 tests in 876.574s, FAILED (failures=94, skipped=5), 0 errors. All 94 failures verified Godot-absent: 94 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None` (93 inherited + new N2143 proof test), 0 `ERROR:` blocks; the N2143 module shows no failure other than its Godot-proof test.** Gate attempt 1 (worker, setsid, PID 5081, ~01:37) died session-end (log frozen at 3465 bytes, preserved as `full-suite-n2143-gate-attempt1.log`); attempt 2 (setsid, PID 5288, ~01:40, main-thread launch) finished clean. The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule). VM restarted since the 01:00 run; javalang 0.13.0 reinstalled at the 01:15 run before RED, per the standing rule.

## Deferred

- `drones_in_position` / `spawn_occupied` / `spawn_visual_occupied` / `allow_update` frame inputs — the assembler driver still reads defaults (0 / false / false / true) until a drone-position / collision / allow-update slice lands.
- `moveOutPayload()` modeling — the assembler production tick still has no payload move-out.
- Net `readUnits` / `whenSyncedUnits` drone sync — presentation/net, not state.
- Live `UnitComp.add()` / `remove()` lifecycle hooks (UnitComp.java:591-598, 603-604, 752) — no live unit lifecycle in the port yet.
- `PayloadComp` add/remove count hooks (PayloadComp.java:101, 200) — same, payload lifecycle not ported yet.
- `Teams.updateTeamStats` full multi-team rebuild (`present`/`bosses`/`players`/`unitsByType`/`unitTree`, Teams.java:182-245) — N2141 rebuilds one team's counts only.
- `Units.notifyUnitSpawn` / spawn path, `Call.unitCapDeath` / `Call.unitEnvDeath` net calls — presentation/net, not state.
- `power.status` live read for the other consumer families (drill, turret, factory, adjacent) — the write-back stamps every consumer's frame generically, but only the unit-factory driver reads `frame["power_status"]` so far; the other families' consumption paths still fold their own defaults until their slices land.
- C07–C12 remain open. Concrete follow-ups already deferred in the tree: `drones_in_position` / `spawn_occupied` / `allow_update` frame inputs, `moveOutPayload()` modeling, net readUnits/whenSyncedUnits drone sync.

See `handoffs/2026-11-13-c07-reconstructor-construct-time-handoff.md` for the full detail.
