# Handoff — N2142: power.status live read — PowerGraph.distributePower consumer write-back (C07)

Date: 2026-11-13. Batch: N2142 (single slice). Status: **DONE + PUSHED 2026-11-13 ~01:15 +07 (01:00 cron run). Targeted 4/4 OK + neighbours 26/26 OK (independently re-verified this run), Godot proof GREEN, full gate verified clean except Godot (Ran 5665, failures=93, skipped=5, 0 errors — all 93 Godot-absent asserts). Slice commit bec3f30 + docs commit <TBD> on origin main; see "Gate certification" below.**

## RED progress (00:15 cron run)

- State at RED time: main at e9aadd7 (N2141 merged + pushed to the fork 2026-11-13 ~00:05; C07 unit-group counts done). Working tree clean except untracked `*.gd.uid` files (never stage) and untracked gate logs (pre-existing env noise, not this slice).
- javalang 0.13.0 present at run start (no VM restart since the 00:00 run — no reinstall needed). Godot 4.6.2 present (`~/workspace/godot-bin/godot`; `godot` is NOT on the default PATH — targeted runs must `export PATH="$HOME/workspace/godot-bin:$PATH"`).
- Test module written: `tools/mindustry_godot_transpiler/tests/test_c07_power_status_live.py` (4 tests). RED run (Godot on PATH): **Ran 4 tests in 0.745s, FAILED (failures=2, errors=2)** — all expected:
  - registration `KeyError: 'N2142'` (ledger entry not written yet);
  - evidence errors on the missing ledger entry (same KeyError);
  - source-text `AssertionError`: `source_consumer_power_status_for_cell_state` not found in `SourcePlacedPowerGraphState.gd` (the read/write pair does not exist yet);
  - proof: Godot returncode 1, `Cannot open file 'res://tools/runtime_proofs/C07PowerStatusLiveProof.tscn'` — the proof scene does not exist yet.
- `git diff --check` clean (no tracked changes yet — only the new untracked test module + this handoff).

## What this batch is

The next deferred follow-up from N2139/N2141 and the next C07 item per the completion backlog (unit lifecycle/teams). N2139's assembler driver folds `frame.get("power_status", null)` — null to 1.0, `!enabled` to 0.0 — with the comment "the frame records no power_status yet, so null folds to 1.0 and !enabled folds to 0.0 until a power-status slice lands." N2142 is that slice: the graph update already runs every tick before the factory tick (`SourceFactoryRuntimeState.gd:163` vs `:192`) and already computes every consumer's `power.status` through the pure `distributePower` — but the live loop only writes **battery** statuses back to sprite meta and drops every consumer's computed status. The unit-factory driver therefore never sees a live value, so an assembler with no power still runs at full `powerStatus`.

Composition, not re-implementation: `distributePower` already has a pure function (`SourcePowerGraphBatteryDistributionState.distribute_power_state`, via `SourcePowerGraphState.distribute_power_state`, port bridge + `PowerGraphBatteryDistributionModuleProof` driving it) — N2142 does not touch it. N2142 supplies the missing read/write pair on the placed building's frame (the battery pattern, N2082/N2083) plus the live-loop write-back of the already-computed statuses.

## Exact upstream evidence (all 16 exprs verified verbatim in this VM)

- `PowerGraph.distributePower` coverage + per-consumer assignment (PowerGraph.java:184-215): `public void distributePower(float needed, float produced, boolean charged){` / `float coverage = Mathf.zero(needed) && Mathf.zero(produced) && !charged && Mathf.zero(lastPowerStored) ? 0f : Mathf.zero(needed) ? 1f : Math.min(1, produced / needed);` / `consumer.power.status = Mathf.clamp(consumer.power.status + maximumRate / cons.capacity);` / `consumer.power.status = coverage;` / `consumer.power.status = Math.min(1, produced / (needed + cons.usage * consumer.delta()));` / `if(Float.isNaN(consumer.power.status)){` / `consumer.power.status = 0f;`
- Cheat branch (PowerGraph.java:217-224): `tile.power.status = 1f;` / `lastPowerNeeded = lastPowerProduced = 1f;`
- Call site (PowerGraph.java:240): `distributePower(powerNeeded, powerProduced, charged);`
- Field default (PowerModule.java:13): `public float status = 0.0f;`
- Driver fold (UnitAssembler.java:469): `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`
- Canonical read (ConsumePower.java:38-40): `return build.power.status;` (+ requestedPower buffered branch `(1f - entity.power.status) * capacity :`)
- Graph membership gates (PowerGraph.java:277, 215): `public void add(Building build){` / `public void update(){`

## Design (decided in RED, implement in GREEN)

- **New pure function 1** `SourcePlacedPowerGraphState.source_consumer_power_status_for_cell_state(game: Object, cell: Vector2i) -> Dictionary` — reads the placed building frame's stored `power_status`, following the battery read (`source_battery_power_status_for_cell_state`, `SourcePlacedPowerGraphState.gd:47-57`): no sprite → `{"status": 0.0, "found": false, "reason": "no_sprite"}`; sprite with no family frame (none of `SOURCE_CONSUMER_FRAME_META_KEYS` present) → `{"status": 0.0, "found": false, "reason": "no_frame"}`; frame present → `{"status": float(frame.get("power_status", 0.0)), "found": true, "reason": "live_frame"}`. Default 0.0 is the Java field default (`PowerModule.java:13`, `public float status = 0.0f;`), not invented. Header comment quotes `return build.power.status;` (ConsumePower.java:39) and `public float status = 0.0f;` — the source-text test asserts them.
- **New pure function 2** `SourcePlacedPowerGraphState.source_consumer_set_power_status_for_cell_state(game: Object, cell: Vector2i, status: float) -> Dictionary` — writes `frame["power_status"] = status` into the sprite's family frame (first of `SOURCE_CONSUMER_FRAME_META_KEYS` present; `set_meta` back after mutating, the battery-write pattern), following the battery write (`source_battery_set_power_status_for_cell_state`): no sprite → `{"stored": false, "reason": "no_sprite"}`; no family frame → `{"stored": false, "reason": "no_frame"}`; stored → `{"stored": true, "reason": "live_frame"}`. Header comment quotes `consumer.power.status = coverage;` (PowerGraph.java:203) — the source-text test asserts it.
- **Wiring** in `SourceFactoryRuntimeState.source_factory_update_power_graph_state` (after the battery write-back loop, same pattern): iterate the updated consumers and write each one's computed `power_status` back to its building frame via the set function. Source: `update.get("battery_distribute_state", {}).get("consumers", [])` when non-empty; else top-level `update.get("consumers", [])` — the cheat branch (PowerGraph.java:217-224): `distributePower` never runs so `battery_distribute_state` is `{}`, but `update_state` writes `power_status = 1.0` onto the real consumer dicts it returns top-level, so the fallback stamps the cheat value. Only consumers with a `Vector2i` `origin_cell` are stamped (the battery loop's guard); `origin_cell` survives the `duplicate(true)` inside `update_battery_distribute_state`. The source-text test asserts the set-function call is present in `SourceFactoryRuntimeState.gd`.
- **Driver change** in `SourceUnitFactoryBuildState.gd` (assembler branch, ~line 810): remove the stale comment ("the frame records no power_status yet, so null folds to 1.0 and !enabled folds to 0.0 until a power-status slice lands") and replace it with a live-stamp comment (the graph update stamps `frame["power_status"]` each tick before this branch runs; the fold itself stays — it is the verbatim `!enabled ? 0f : power == null ? 1f : power.status` (UnitAssembler.java:469), and null only fires before the first graph update). The source-text test asserts the substring `the frame records no power_status yet` is gone.
- **Proof**: new scene `godot-mindustry/tools/runtime_proofs/C07PowerStatusLiveProof.gd` + `.tscn` (modeled on `C07UnitGroupCountsProof` + `BatteryPowerStatusProof`, same Main scene), prefix `C_07_POWER_STATUS_LIVE_PROOF `, 7 keys:
  - `consumer_set_read_roundtrip`: set 0.5 on a consumer frame → read returns 0.5.
  - `consumer_read_missing_sprite`: no sprite at the cell → found false, status 0.0.
  - `consumer_read_no_frame`: sprite without a family frame → found false.
  - `consumer_set_no_frame`: set on a sprite without a family frame → stored false.
  - `distribute_coverage_half`: one unbuffered consumer (`shouldConsumePower` true, `power_status` 0.0, `delta` 1.0), needed 10.0, produced 5.0, charged false, last stored 0.0 → coverage 0.5, consumer `power_status` 0.5 (consumer-dict shape copied from `PowerGraphBatteryDistributionModuleProof.gd:10-20`).
  - `distribute_coverage_full`: same consumer, needed 0.0, produced 5.0 → coverage 1.0, status 1.0.
  - `distribute_buffered_accumulates`: buffered consumer (`capacity` 100.0, `power_status` 0.2, `requested_power` 10.0, `delta` 1.0), needed 10.0, produced 5.0 → coverage 0.5, status `clamp(0.2 + 10*0.5*1/100)` = 0.25.
  - GREEN check: how the set/read keys get their game/sprite — preferred: a proof-local fake game (inner `RefCounted` class with `block_sprite_at_cell` returning a proof-created `Sprite2D` carrying the `source_unit_factory_building` frame meta), deterministic and independent of campaign-slice layout; fallback if the proof runner rejects it: the real-game + placed-cell pattern from `BatteryPowerStatusProof` (battery at `Vector2i(23, 7)`) — find the placed consumer cell in the campaign slice. Proof JSON is gitignored, never stage it.
- **Register script** `register_c07_power_status_live.py` (GREEN, modeled on the N2141 one): 5 new result symbols, all with verbatim `java_expr`:
  - `source_consumer_power_status_for_cell_state_result.status` ← `return build.power.status;` (ConsumePower.java, the canonical power.status read)
  - `source_consumer_power_status_for_cell_state_result.found` ← `public void add(Building build){` (PowerGraph.java, graph-membership gate — same convention as the cheating/should-consume reads)
  - `source_consumer_power_status_for_cell_state_result.reason` ← `public void update(){` (PowerGraph.java)
  - `source_consumer_set_power_status_for_cell_state_result.stored` ← `consumer.power.status = coverage;` (PowerGraph.java:203)
  - `source_consumer_set_power_status_for_cell_state_result.reason` ← `public void update(){` (PowerGraph.java)
  - Inputs (schema only): read `game` ← `public void update(){`, `cell` ← `public void add(Building build){`; set `game` ← `public void update(){`, `cell` ← `public void add(Building build){`, `status` ← `consumer.power.status = coverage;`. Slice `java_source` PowerGraph.java, `java_class` `mindustry.world.blocks.power.PowerGraph`, `java_method` `PowerGraph.distributePower(float, float, boolean)`.
  - Expected SSOT +5 symbols / +1 slice / +2 contracts / +4 schemas → **11296 / 1593 / 1514 / 2819**; audit 1335. GREEN verifies actuals.
- **Neighbours to run in GREEN** (targeted, sequential, Godot on PATH): N2141 `test_c07_unit_group_counts`, N2140 `test_c07_units_can_create`, N2139 `test_c06_unit_assembler_production_tick`, N2136 `test_c06_unit_factory_should_consume_power_stamp`, N2132 `test_c06_unit_assembler_payload_should_consume` (each 4/4 expected), plus the battery power-status binding test (`test_battery_power_status_binding`) and the power-graph live-update binding test (`test_power_graph_live_update_binding`) since the write-back touches the same live loop.

## Files changed (RED only; uncommitted)

- `tools/mindustry_godot_transpiler/tests/test_c07_power_status_live.py` (new, 4 tests): registration (ledger N2142, 5 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (5 new symbols + 16 exprs over PowerGraph.java + PowerModule.java + UnitAssembler.java + ConsumePower.java), source-text (both pure functions exist + the three quoted Java lines in the function comments + live-loop write-back calls the set function + the stale driver comment is gone; proof has the 7 new keys), Godot proof (`C07PowerStatusLiveProof.tscn`, prefix `C_07_POWER_STATUS_LIVE_PROOF `, the 7 new keys true).
- This handoff (new, untracked).

## Verified numbers (do not re-derive, these are measured in this VM)

- RED run: **4 tests in 0.745s, FAILED (failures=2, errors=2), all expected** — registration `KeyError: 'N2142'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure functions do not exist yet), proof returncode 1 (proof scene does not exist yet).
- Exact-expr pre-check: **16/16 exprs found verbatim** in the 4 slice sources (PowerGraph.java, PowerModule.java, UnitAssembler.java, ConsumePower.java).
- `git diff --check` clean.
- State at RED time: main at e9aadd7 (N2141 merged + pushed to the fork 2026-11-13 ~00:05); SSOT 11291 / 1592 / 1512 / 2815; audit 1335.
- javalang 0.13.0 present at run start (no VM restart since the 00:00 run); Godot 4.6.2 on `~/workspace/godot-bin`.

## Gate certification — attempt 2 FINISHED CLEAN except Godot (certified 01:00 cron run)

- GREEN done 2026-11-13 ~00:30 +07 (00:30 cron run, timed out before logging; completed by main thread ~00:46): register script executed (SSOT actuals **11296/1593/1514/2819**, matching the RED expectation exactly); 2 pure functions `source_consumer_power_status_for_cell_state` + `source_consumer_set_power_status_for_cell_state` in `SourcePlacedPowerGraphState.gd`; write-back wired in `SourceFactoryRuntimeState.gd` after the battery write-back; stale comment in `SourceUnitFactoryBuildState.gd` replaced with the live-stamp comment; proof scene `C07PowerStatusLiveProof` (.gd + .tscn + .json, FakeGame, 7 keys). Targeted 4/4 OK + neighbours 26/26 OK **independently re-verified this run** (targeted 4/4 in 4.857s; neighbours 26/26 in 133.077s, sequential, Godot on PATH). `git diff --check` clean.
- Full gate **attempt 1 (worker, PID 12393, detached) DIED session-end ~00:45** (log frozen 3453 bytes, preserved as `full-suite-n2142-gate-attempt1.log`).
- Full gate **attempt 2 (main thread, PID 12741, setsid, SID 12741, launched ~00:46, javalang verified OK) FINISHED ~01:01 +07: Ran 5665 tests in 904.240s, FAILED (failures=93, skipped=5), 0 errors — CERTIFIED clean except Godot this run: 93 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None` (92 inherited + new N2142 proof test `test_reference_graph_and_actual_c07_power_status_live`, which passes with Godot present), 0 `ERROR:` blocks, 0 non-Godot failures; the N2142 module shows no failure other than its Godot-proof test.** Log: `tools/mindustry_godot_transpiler/full-suite-n2142-gate.log`.
- Slice commits this run (01:00 cron run): slice commit bec3f30 + docs commit <TBD> on origin main. Report: `docs/superpowers/reports/2026-11-13-c07-power-status-live.md`. Design spec: Status Summary 1592→1593, N2142 checklist + changelog rows.

## Next (after N2142 lands)

- C07 continues per the completion backlog: unit lifecycle/controller/pathfinding/command/weapon/death, wave/spawn/teams, map/world transition, campaign persistence. Concrete follow-ups already deferred in the tree: `drones_in_position` / `spawn_occupied` / `allow_update` frame inputs, `moveOutPayload()` modeling, reconstructor `constructTime` catalog capture, net readUnits/whenSyncedUnits drone sync.

## Deferred (not this slice)

- `drones_in_position` / `spawn_occupied` / `spawn_visual_occupied` / `allow_update` frame inputs — the assembler driver still reads defaults (0 / false / false / true) until a drone-position / collision / allow-update slice lands.
- `moveOutPayload()` modeling — the assembler production tick still has no payload move-out.
- Reconstructor `constructTime` catalog capture — the driver still uses default 120.0 instead of the real 600 for additive-reconstructor.
- Net `readUnits` / `whenSyncedUnits` drone sync — presentation/net, not state.
- Live `UnitComp.add()` / `remove()` lifecycle hooks (UnitComp.java:591-598, 603-604, 752) — no live unit lifecycle in the port yet.
- `PayloadComp` add/remove count hooks (PayloadComp.java:101, 200) — same, payload lifecycle not ported yet.
- `Teams.updateTeamStats` full multi-team rebuild (`present`/`bosses`/`players`/`unitsByType`/`unitTree`, Teams.java:182-245) — N2141 rebuilds one team's counts only.
- `Units.notifyUnitSpawn` / spawn path, `Call.unitCapDeath` / `Call.unitEnvDeath` net calls — presentation/net, not state.
- `power.status` live read for the other consumer families (drill, turret, factory, adjacent) — the write-back stamps every consumer's frame generically, but only the unit-factory driver reads `frame["power_status"]` so far; the other families' consumption paths still fold their own defaults until their slices land.
- C07–C12 remain open.
