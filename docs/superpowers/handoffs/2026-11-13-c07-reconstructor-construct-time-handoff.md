# Handoff — N2143: reconstructor constructTime catalog capture (C07)

Date: 2026-11-13. Batch: N2143 (single slice). Status: **DONE + PUSHED 2026-11-13 ~01:57 +07 (01:45 cron run). Targeted 4/4 OK + neighbours 35/35 OK, Godot proof GREEN. Full gate attempt 2 CERTIFIED clean except Godot (Ran 5669 in 876.574s, failures=94, skipped=5, 0 errors — all 94 verified Godot-absent asserts). Slice commit + docs commit pushed to origin main — see "Commits" below.**

## GREEN progress (01:30 cron run)

- Pure function `SourceUnitFactoryBuildState.source_reconstructor_construct_time_state(block)` + owner constant `PORT_GAME_SOURCE_RECONSTRUCTOR_CONSTRUCT_TIME_STATE` + driver rewire at `SourceUnitFactoryBuildState.gd:772` (now calls the pure read instead of inlining the fold; behavior-preserving).
- Extractor: `_block_properties` Reconstructor branch captures `constructTime` — initializer's own assignment via `constructTime\s*=\s*([^;]+);` + `_numeric_expression_value`, else the class default from `class_sources["Reconstructor"]`. `test_content_registry.py` fixture extended (additive `constructTime = 60f * 10f;` → assert 600.0); **test_content_registry 11/11 OK**.
- Regen via `transpile.py content`: **correction to the RED expectation** — the diff touches all **8** Reconstructor blocks in upstream, not just 2 (the handoff author counted only additive/multiplicative): additive 600.0, multiplicative 1800.0, exponential 5400.0 (`60f * 60f * 1.5f`), tetrative 14400.0 (`60f * 60f * 4`), tank-refabricator 1800.0, ship-refabricator 3000.0, mech-refabricator 2700.0, prime-refabricator 3600.0 — all 8 verified verbatim against Blocks.java:6309/6329/6351/6372/6457/6474/6492/6512. `content_registry_blocks` shard rebuilt (+8 lines). `MindustryContentRegistry.gd` regen is a 1-line blob change.
- Register script `register_c07_reconstructor_construct_time.py` run: SSOT actuals **11297 / 1594 / 1515 / 2821**, audit 1335 — matching the RED expectation exactly. No `unit_building_*` shard change: `unit_building_slices` selects only `java_source == UnitFactory.java`, so Reconstructor.java slices don't flow into it — same as N2138/N2139/N2140 precedent (root SSOT JSONs only).
- Proof scene `C07ReconstructorConstructTimeProof` (.gd + .tscn, uid `uid://c07reccttime1`, 6 keys) written; **targeted 4/4 OK in 14.5s** (proof test runs the scene headless, matches:true, no ERROR). **Neighbours 35/35 OK sequential, Godot on PATH**: N2138 4/4, N2137 4/4, N2139 4/4, N2140 4/4, N2141 4/4, N2142 4/4, test_content_registry 11/11.
- `git diff --check` clean.
- Full gate **attempt 1 (worker, PID 5081, setsid, ~01:37) DIED session-end ~01:38** (log frozen 3465 bytes, preserved as `full-suite-n2143-gate-attempt1.log`). **Attempt 2 (main thread, PID 5288, setsid, SID 5288, ~01:40, javalang verified OK) RUNNING** — verified alive at 95.8% CPU, log growing. Expected: Ran ~5669, FAILED (failures=94, skipped=5), 0 errors — all Godot-absent asserts (93 inherited + new N2143 proof test). NO proof scene run while the gate runs (port-7777 rule). **Do NOT commit/push until the gate is certified clean except Godot.**

## Gate certification + push (01:45 cron run)

- Full gate attempt 2 (setsid, PID 5288, ~01:40, main-thread launch) **FINISHED ~01:55 +07: Ran 5669 tests in 876.574s, FAILED (failures=94, skipped=5), 0 errors** — certified clean except Godot in this run: 94 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None` (93 inherited + new N2143 proof test), 0 `ERROR:` blocks; the N2143 module shows no failure other than its Godot-proof test (`test_reference_graph_and_actual_c07_reconstructor_construct_time`, line 125, `assertIsNotNone(godot)` — passes with Godot on PATH, targeted 4/4 OK). Log `tools/mindustry_godot_transpiler/full-suite-n2143-gate.log` (untracked, kept in the worktree, never staged).
- Report written: `docs/superpowers/reports/2026-11-13-c07-reconstructor-construct-time.md`. Design spec updated: Status Summary 1593→1594, N2143 checklist row + changelog line added.
- Commits: (filled after push — see below).

## Commits

- Slice commit: d7a4ec8.
- Docs commit: de00c8f.
- Handoff-hash commit: TBD if needed (prior pattern).

## Next (next slice)

C07 continues per the completion backlog — deferred follow-ups, in backlog order: `drones_in_position` / `spawn_occupied` / `allow_update` frame inputs, `moveOutPayload()` modeling, net readUnits/whenSyncedUnits drone sync, `power.status` live read for the other consumer families (drill, turret, factory, adjacent). Next run starts the next slice's RED.

## RED progress (01:15 cron run)

- State at RED time: main at c53e3b9 (N2142 merged + pushed to the fork 2026-11-13 ~01:09; C07 power.status live read done). Working tree clean except untracked `*.gd.uid` files (never stage), untracked gate logs and an untracked `tools/mindustry_godot_transpiler/targeted-env-fix.log` (pre-existing env noise, not this slice).
- VM restarted since the 01:00 run — javalang was missing at run start; reinstalled 0.13.0 (`pip install --break-system-packages -r tools/mindustry_godot_transpiler/requirements.txt` from the repo root) before the RED run, per the standing rule. Godot 4.6.2 present (`~/workspace/godot-bin/godot`; `godot` is NOT on the default PATH — targeted runs must `export PATH="$HOME/workspace/godot-bin:$PATH"`).
- Test module written: `tools/mindustry_godot_transpiler/tests/test_c07_reconstructor_construct_time.py` (4 tests). RED run (Godot on PATH): **Ran 4 tests in 2.408s, FAILED (failures=2, errors=2)** — all expected:
  - registration `KeyError: 'N2143'` (ledger entry not written yet);
  - evidence errors on the missing ledger entry (same KeyError);
  - source-text `AssertionError`: `static func source_reconstructor_construct_time_state` not found in `SourceUnitFactoryBuildState.gd` (the pure read does not exist yet);
  - proof: Godot returncode 1, `Cannot open file 'res://tools/runtime_proofs/C07ReconstructorConstructTimeProof.tscn'` — the proof scene does not exist yet.
- `git diff --check` clean (no tracked changes yet — only the new untracked test module + this handoff).

## What this batch is

The deferred catalog follow-up named in the N2138, N2139 and N2142 handoffs ("catalog has no constructTime for reconstructor blocks, so the driver uses default 120.0 instead of the real 600 for additive-reconstructor — waits for a later catalog slice"). N2138 wired the reconstructor production tick and its pure function takes `construct_time` as an input (backed by the class default, Reconstructor.java:36), but the content catalog never captured the per-block override, so the tick driver reads `block.properties.get("constructTime", 120.0)` and an additive-reconstructor upgrades on the 120.0 default instead of its real 600.0 (Blocks.java:6310), and a multiplicative-reconstructor on 120.0 instead of 1800.0 (Blocks.java:6330).

Composition, not re-implementation: the tick function (`source_reconstructor_production_tick_state`, N2138) already completes exactly when `progress >= constructTime` (Reconstructor.java:334); N2143 does not touch it. N2143 supplies the missing catalog capture (the craftTime pattern, N2117: the initializer's own assignment, else the class default) plus one pure read on the block so the driver stops inlining the fold.

## Exact upstream evidence (all 10 exprs verified verbatim in this VM)

- Class default (Reconstructor.java:36): `public float constructTime = 60 * 2;`
- Completion gate (Reconstructor.java:334): `if(progress >= constructTime){`
- Additive override (Blocks.java:6310): `constructTime = 60f * 10f;`
- Multiplicative override (Blocks.java:6330): `constructTime = 60f * 30f;`
- Stats (Reconstructor.java:87, 90): `stats.timePeriod = constructTime;` / `stats.add(Stat.productionTime, constructTime / 60f, StatUnit.seconds);`
- Progress fraction (Reconstructor.java:169): `return progress / constructTime;`
- Block creators (Blocks.java:6302, 6322): `additiveReconstructor = new Reconstructor("additive-reconstructor"){{` / `multiplicativeReconstructor = new Reconstructor("multiplicative-reconstructor"){{`
- Constructor (Reconstructor.java): `public Reconstructor(String name){`

## Design (decided in RED, implement in GREEN)

- **New pure function** `SourceUnitFactoryBuildState.source_reconstructor_construct_time_state(block: Object) -> Dictionary` — follows the has_upgrade / plan-requirements pattern (block: Object, null-safe, `block.properties.get(...)`): returns `{"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_RECONSTRUCTOR_CONSTRUCT_TIME_STATE, "construct_time": float(block.properties.get("constructTime", 120.0))}`; null block → 120.0 (the Reconstructor.java:36 class default `60 * 2`). Header comment quotes `public float constructTime = 60 * 2;` (Reconstructor.java:36) and `constructTime = 60f * 10f;` (Blocks.java:6310) — the source-text test asserts them.
- **Owner constant** `PORT_GAME_SOURCE_RECONSTRUCTOR_CONSTRUCT_TIME_STATE := "port_game.source_reconstructor_construct_time_state"` in `SourceRuntimeOwnerUnitBuildingRegistry.gd` (next to `PORT_GAME_SOURCE_RECONSTRUCTOR_PRODUCTION_TICK_STATE`, line 23).
- **Driver rewire** in `SourceUnitFactoryBuildState.gd` (~line 772): `var construct_time: float = float(block.properties.get("constructTime", 120.0))` becomes `var construct_time: float = float(source_reconstructor_construct_time_state(block).get("construct_time", 120.0))` — behavior-preserving; the fold lives in the pure function now. The source-text test asserts the `source_reconstructor_construct_time_state(block)` call is present.
- **Catalog extractor** in `tools/mindustry_godot_transpiler/mindustry_port/content_registry.py`, `_block_properties`, next to the Reconstructor `upgrades` branch: capture `constructTime` — the block initializer's own assignment, else the class default from `class_sources["Reconstructor"]`. Both sides are multiplication expressions (`60f * 10f`, `60f * 30f`, `60 * 2`), so plain `_numeric_assignment` does NOT match; use a `constructTime\s*=\s*([^;]+);` match + `_numeric_expression_value` (already handles `*`/`/` via javalang — proven by the UnitPlan times, e.g. dagger 900.0), wrapped with `float(...)`. Follow the craftTime shape (N2117): `properties["constructTime"] = float(...)`. `extract_blocks` already passes `class_sources` into `_block_properties` (content_registry.py:255).
- **Regenerate** `content_registry.json` + `MindustryContentRegistry.gd` via `write_content_registry` (transpile.py:81 entry), then rebuild the `content_registry_blocks` SSOT shard mirror (`source_ssot.write_registered_json(GODOT, 'content_registry_blocks', ...)` — the N2114 lesson). Check the regen diff touches only the two reconstructor entries.
- **test_content_registry.py**: extend the reconstructor fixture in `test_block_registry_captures_reconstructor_upgrades_and_assembler_plans` — add `constructTime = 60f * 10f;` to the additive-reconstructor initializer and assert `by_id["additive-reconstructor"]["properties"].get("constructTime") == 600.0`. (The multiplicative 1800.0 is asserted on the real registry by the N2143 source-text test.)
- **Register script** `register_c07_reconstructor_construct_time.py` (modeled on the N2142 one): 1 new result symbol:
  - `source_reconstructor_construct_time_state_result.construct_time` ← `public float constructTime = 60 * 2;` (Reconstructor.java:36 — the class default the read returns when the catalog carries no override; the per-block overrides are exact exprs).
  - Input (schema only): `block` ← `additiveReconstructor = new Reconstructor("additive-reconstructor"){{` (Blocks.java:6302 — the block definition the read resolves). Slice `java_source` Reconstructor.java, `java_class` `mindustry.world.blocks.units.Reconstructor.ReconstructorBuild`, `java_method` `ReconstructorBuild.updateTile()`.
  - Expected SSOT +1 symbol / +1 slice / +1 contract / +2 schemas → **11297 / 1594 / 1515 / 2821**; audit 1335. GREEN verifies actuals.
- **Proof**: new scene `godot-mindustry/tools/runtime_proofs/C07ReconstructorConstructTimeProof.gd` + `.tscn` (modeled on `C06ReconstructorProductionProof` — Main scene, campaign playable slice, `catalog.get_many("block")`, `RuntimeProofState`), prefix `C_07_RECONSTRUCTOR_CONSTRUCT_TIME_PROOF `, 6 keys:
  - `additive_construct_time_600`: catalog additive-reconstructor `properties.get("constructTime")` == 600.0.
  - `multiplicative_construct_time_1800`: catalog multiplicative-reconstructor == 1800.0.
  - `read_default_120`: the pure read on `MindustryBlock.new({})` (empty properties) → construct_time 120.0.
  - `read_additive_600`: the pure read on the catalog additive block → 600.0.
  - `tick_completes_at_600`: `source_reconstructor_production_tick_state` with construct_time 600.0 (from the read), frame `{efficiency 1.0, payload {unit: "dagger"}, progress 599.0, time 0.0, speed_scl 1.0}`, has_upgrade true, upgrade "mace", in position, edelta 1.0, build speed 1.0, source_delta 1.0 → completed true, payload.unit "mace" (progress 599 + 1 = 600 >= 600; the N2138 proof's completing case used 599.5 → same shape).
  - `tick_incomplete_below_600`: same call with progress 100.0 → progress 101.0, completed false.
  - Proof JSON is gitignored, never stage it.
- **Neighbours to run in GREEN** (targeted, sequential, Godot on PATH): N2138 `test_c06_reconstructor_production_tick` (4/4 expected), N2137 `test_c06_unit_factory_production_tick`, N2139 `test_c06_unit_assembler_production_tick`, N2140 `test_c07_units_can_create`, N2141 `test_c07_unit_group_counts`, N2142 `test_c07_power_status_live`, plus `test_content_registry` (11 tests) since the extractor changes.

## Files changed (RED only; uncommitted)

- `tools/mindustry_godot_transpiler/tests/test_c07_reconstructor_construct_time.py` (new, 4 tests): registration (ledger N2143, 1 new symbol, runtime proof, test names, deferred_exprs), exact-evidence (1 new symbol + 10 exprs over Reconstructor.java + Blocks.java), source-text (pure function exists + the two quoted Java lines in its comment + driver calls it + owner constant + `"constructTime"` in the extractor + registry JSON 600.0/1800.0; proof has the 6 new keys), Godot proof (`C07ReconstructorConstructTimeProof.tscn`, prefix `C_07_RECONSTRUCTOR_CONSTRUCT_TIME_PROOF `, the 6 new keys true).
- This handoff (new, untracked).

## Verified numbers (do not re-derive, these are measured in this VM)

- RED run: **4 tests in 2.408s, FAILED (failures=2, errors=2), all expected** — registration `KeyError: 'N2143'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure function does not exist yet), proof returncode 1 (proof scene does not exist yet).
- Exact-expr pre-check: **10/10 exprs found verbatim** in the 2 slice sources (Reconstructor.java, Blocks.java).
- Negatives confirmed before RED: `constructTime` appears 0 times in `content_registry.py`; `source_reconstructor_construct_time_state` 0 times in `SourceUnitFactoryBuildState.gd`; `RECONSTRUCTOR_CONSTRUCT_TIME` 0 times in `SourceRuntimeOwnerUnitBuildingRegistry.gd`; registry JSON has no `constructTime` for either reconstructor block.
- `git diff --check` clean.
- State at RED time: main at c53e3b9 (N2142 merged + pushed to the fork 2026-11-13 ~01:09); SSOT 11296 / 1593 / 1514 / 2819; audit 1335.
- javalang 0.13.0 reinstalled at run start (VM restarted since the 01:00 run); Godot 4.6.2 on `~/workspace/godot-bin`.

## Next (GREEN — DONE this run, see "GREEN progress" above; kept for the record)

1. ~~Implement the pure function + owner constant + driver rewire~~ DONE.
2. ~~Extend the extractor + fixture; run `test_content_registry` green~~ DONE (11/11).
3. ~~Regenerate content_registry.json + MindustryContentRegistry.gd; rebuild the shard; verify the regen diff~~ DONE (8 Reconstructor blocks, all verified — see correction above).
4. ~~Write the register script, run it, verify SSOT actuals 11297 / 1594 / 1515 / 2821, audit 1335~~ DONE (exact match).
5. ~~Write the proof scene (6 keys), run targeted 4/4 OK + neighbours, then the full gate~~ — proof + targeted + neighbours DONE; full gate LAUNCHED, awaiting certification (see "Next (gate certification + push)" above).

## Deferred (not this slice)

- `drones_in_position` / `spawn_occupied` / `spawn_visual_occupied` / `allow_update` frame inputs — the assembler driver still reads defaults (0 / false / false / true) until a drone-position / collision / allow-update slice lands.
- `moveOutPayload()` modeling — the assembler production tick still has no payload move-out.
- Net `readUnits` / `whenSyncedUnits` drone sync — presentation/net, not state.
- Live `UnitComp.add()` / `remove()` lifecycle hooks (UnitComp.java:591-598, 603-604, 752) — no live unit lifecycle in the port yet.
- `PayloadComp` add/remove count hooks (PayloadComp.java:101, 200) — same, payload lifecycle not ported yet.
- `Teams.updateTeamStats` full multi-team rebuild (`present`/`bosses`/`players`/`unitsByType`/`unitTree`, Teams.java:182-245) — N2141 rebuilds one team's counts only.
- `Units.notifyUnitSpawn` / spawn path, `Call.unitCapDeath` / `Call.unitEnvDeath` net calls — presentation/net, not state.
- `power.status` live read for the other consumer families (drill, turret, factory, adjacent) — the write-back stamps every consumer's frame generically, but only the unit-factory driver reads `frame["power_status"]` so far; the other families' consumption paths still fold their own defaults until their slices land.
- C07–C12 remain open.
