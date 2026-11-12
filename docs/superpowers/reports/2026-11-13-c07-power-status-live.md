# Report — N2142: power.status live read — PowerGraph.distributePower consumer write-back (C07)

Date: 2026-11-13. Batch: N2142 (single slice). Status: **DONE + PUSHED 2026-11-13 ~01:15 +07 (01:00 cron run). Targeted tests 4/4 OK, neighbours 26/26 OK, Godot proof GREEN, full gate verified clean except Godot (Ran 5665, failures=93, skipped=5, 0 errors — all 93 Godot-absent asserts). Commit + push to origin main (fork Lasthope1508) this run — see handoff for the commit hashes.**

## What changed

The next deferred follow-up from N2139/N2141 and the next C07 item per the completion backlog (unit lifecycle/teams). N2139's assembler driver folded `frame.get("power_status", null)` — null to 1.0, `!enabled` to 0.0 — with the comment "the frame records no power_status yet, so null folds to 1.0 and !enabled folds to 0.0 until a power-status slice lands." N2142 is that slice: the graph update already runs every tick before the factory tick (`SourceFactoryRuntimeState.gd:163` vs `:192`) and already computes every consumer's `power.status` through the pure `distributePower` — but the live loop only wrote **battery** statuses back to sprite meta and dropped every consumer's computed status. The unit-factory driver therefore never saw a live value, so an assembler with no power still ran at full `powerStatus`.

Composition, not re-implementation: `distributePower` already has a pure function (`SourcePowerGraphBatteryDistributionState.distribute_power_state`, via `SourcePowerGraphState.distribute_power_state`, port bridge + `PowerGraphBatteryDistributionModuleProof` driving it) — N2142 does not touch it. N2142 supplies the missing read/write pair on the placed building's frame (the battery pattern, N2082/N2083) plus the live-loop write-back of the already-computed statuses.

Implemented in `SourcePlacedPowerGraphState.gd` (+ registry preload): pure `source_consumer_power_status_for_cell_state(game, cell)` — reads the placed building frame's stored `power_status`, following the battery read: no sprite → `{"status": 0.0, "found": false, "reason": "no_sprite"}`; sprite with no family frame → `{"status": 0.0, "found": false, "reason": "no_frame"}`; frame present → `{"status": float(frame.get("power_status", 0.0)), "found": true, "reason": "live_frame"}`. Default 0.0 is the Java field default (`PowerModule.java:13`, `public float status = 0.0f;`), not invented. Pure `source_consumer_set_power_status_for_cell_state(game, cell, status)` — writes `frame["power_status"] = status` into the sprite's family frame (first of `SOURCE_CONSUMER_FRAME_META_KEYS` present; `set_meta` back after mutating, the battery-write pattern): no sprite → `{"stored": false, "reason": "no_sprite"}`; no family frame → `{"stored": false, "reason": "no_frame"}`; stored → `{"stored": true, "reason": "live_frame"}`. Wired in `SourceFactoryRuntimeState.source_factory_update_power_graph_state` (after the battery write-back loop, same pattern): iterate the updated consumers and write each one's computed `power_status` back to its building frame via the set function — source `update.get("battery_distribute_state", {}).get("consumers", [])` when non-empty, else top-level `update.get("consumers", [])` (the cheat branch, PowerGraph.java:217-224: `distributePower` never runs so `battery_distribute_state` is `{}`, but `update_state` writes `power_status = 1.0` onto the real consumer dicts it returns top-level, so the fallback stamps the cheat value). Only consumers with a `Vector2i` `origin_cell` are stamped (the battery loop's guard). Driver change in `SourceUnitFactoryBuildState.gd` (assembler branch, ~line 810): the stale comment is gone, replaced with a live-stamp comment — the fold itself stays, it is the verbatim `!enabled ? 0f : power == null ? 1f : power.status` (UnitAssembler.java:469), and null only fires before the first graph update.

## Proof keys (new scene, 7 keys)

New scene `C07PowerStatusLiveProof` (modeled on `C07UnitGroupCountsProof` + `BatteryPowerStatusProof`, same Main scene), prefix `C_07_POWER_STATUS_LIVE_PROOF `; set/read keys use a proof-local fake game (inner `RefCounted` class with `block_sprite_at_cell` returning a proof-created `Sprite2D` carrying the `source_unit_factory_building` frame meta), deterministic and independent of campaign-slice layout:

- `consumer_set_read_roundtrip`: set 0.5 on a consumer frame → read returns 0.5.
- `consumer_read_missing_sprite`: no sprite at the cell → found false, status 0.0.
- `consumer_read_no_frame`: sprite without a family frame → found false.
- `consumer_set_no_frame`: set on a sprite without a family frame → stored false.
- `distribute_coverage_half`: one unbuffered consumer (`shouldConsumePower` true, `power_status` 0.0, `delta` 1.0), needed 10.0, produced 5.0, charged false, last stored 0.0 → coverage 0.5, consumer `power_status` 0.5 (consumer-dict shape copied from `PowerGraphBatteryDistributionModuleProof.gd:10-20`).
- `distribute_coverage_full`: same consumer, needed 0.0, produced 5.0 → coverage 1.0, status 1.0.
- `distribute_buffered_accumulates`: buffered consumer (`capacity` 100.0, `power_status` 0.2, `requested_power` 10.0, `delta` 1.0), needed 10.0, produced 5.0 → coverage 0.5, status `clamp(0.2 + 10*0.5*1/100)` = 0.25.

## Verified numbers (measured in this VM)

- Test module `test_c07_power_status_live.py`: **4/4 OK in 4.857s** (Godot on PATH, 01:00 cron run, independently re-verified this run) — registration (ledger N2142, 5 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (5 new symbols + 16 exprs over PowerGraph.java + PowerModule.java + UnitAssembler.java + ConsumePower.java, all found verbatim), source-text (both pure functions exist + the three quoted Java lines in the function comments + live-loop write-back calls the set function + the stale driver comment is gone; proof has the 7 new keys), and the Godot proof test (7 new keys, all true, `matches: true`).
- RED run (00:15 cron run): 4 tests in 0.745s, FAILED (failures=2, errors=2), all expected — registration `KeyError: 'N2142'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure functions did not exist yet), proof returncode 1 (proof scene did not exist yet).
- Neighbours (Godot on PATH, sequential, 01:00 cron run, independently re-verified this run): **26/26 OK in 133.077s** — `test_c07_unit_group_counts` (N2141) + `test_c07_units_can_create` (N2140) + `test_c06_unit_assembler_production_tick` (N2139) + `test_c06_unit_factory_should_consume_power_stamp` (N2136) + `test_c06_unit_assembler_payload_should_consume` (N2132) + `test_battery_power_status_binding` + `test_power_graph_live_update_binding`.
- `git diff --check` clean.
- SSOT +5/+1/+2/+4 → **11296 / 1593 / 1514 / 2819**; audit stays 1335.

## Gate / suite

- Test modules standalone: N2142 4/4 (proof green, see above); neighbours 26/26.
- Godot proof: **GREEN 2026-11-13 ~00:30 +07** (worker run; re-verified green by the targeted proof test this run) — 7 new keys all true, `matches: true`, on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- Full Python suite, inclusive gate with the N2142 module (log `tools/mindustry_godot_transpiler/full-suite-n2142-gate.log`, 211 modules): **FINISHED ~01:01 +07, VERIFIED clean except Godot in the 01:00 cron run — Ran 5665 tests in 904.240s, FAILED (failures=93, skipped=5), 0 errors. All 93 failures verified Godot-absent: 93 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None` (92 inherited + new N2142 proof test), 0 `ERROR:` blocks, 0 non-Godot failures; the N2142 module shows no failure other than its Godot-proof test.** Gate attempt 1 (worker, setsid, PID 12393, ~00:45) died session-end (log frozen at 3453 bytes, preserved as `full-suite-n2142-gate-attempt1.log`); attempt 2 (setsid, PID 12741, ~00:46, main-thread launch) finished clean. The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule). No VM restart during this slice; javalang 0.13.0 verified present at the 00:15 run (no reinstall needed).

## Deferred

- `drones_in_position` / `spawn_occupied` / `spawn_visual_occupied` / `allow_update` frame inputs — the assembler driver still reads defaults (0 / false / false / true) until a drone-position / collision / allow-update slice lands.
- `moveOutPayload()` modeling — the assembler production tick still has no payload move-out.
- Reconstructor `constructTime` catalog capture — the driver still uses default 120.0 instead of the real 600 for additive-reconstructor.
- Net `readUnits` / `whenSyncedUnits` drone sync — presentation/net, not state.
- Live `UnitComp.add()` / `remove()` lifecycle hooks (UnitComp.java:591-598, 603-604, 752) — no live unit lifecycle in the port yet.
- `PayloadComp` add/remove count hooks (PayloadComp.java:101, 200) — same, payload lifecycle not ported yet.
- `Teams.updateTeamStats` full multi-team rebuild (`present`/`bosses`/`players`/`unitsByType`/`unitTree`, Teams.java:182-245) — N2141 rebuilds one team's counts only.
- `Units.notifyUnitSpawn` / spawn path, `Call.unitCapDeath` / `Call.unitEnvDeath` net calls — presentation/net, not state.
- `power.status` live read for the other consumer families (drill, turret, factory, adjacent) — the write-back stamps every consumer's frame generically, but only the unit-factory driver reads `frame["power_status"]` so far; the other families' consumption paths still fold their own defaults until their slices land.
- C07–C12 remain open. Concrete follow-ups already deferred in the tree: `drones_in_position` / `spawn_occupied` / `allow_update` frame inputs, `moveOutPayload()` modeling, reconstructor `constructTime` catalog capture, net readUnits/whenSyncedUnits drone sync.

See `handoffs/2026-11-12-c07-power-status-live-handoff.md` for the full detail.
