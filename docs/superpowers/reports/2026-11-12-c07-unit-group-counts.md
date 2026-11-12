# Report — N2141: Live per-type unit counts — TeamData.updateCount + updateTeamStats rebuild (C07 unit-group system)

Date: 2026-11-12. Batch: N2141 (single slice). Status: **DONE + PUSHED 2026-11-13 ~00:05 +07 (00:00 cron run). Targeted tests 4/4 OK, neighbours 20/20, Godot proof GREEN, full gate verified clean except Godot (Ran 5661, failures=92, skipped=5, 0 errors — all 92 Godot-absent asserts). Commit + push to origin main (fork Lasthope1508) this run — see handoff for the commit hashes.**

## What changed

The first deferred follow-up from N2140 and the next C07 item per the completion backlog (unit lifecycle/teams). N2140's canCreate helper reads `frame["team_unit_counts"]` (default 0 for a missing unit, exactly `TeamData.countType`, Teams.java:442-444) but no frame recorded it yet — the tick driver comment said "the frame still records no per-type unit counts, so the count reads 0 until the unit-group slice lands." N2141 is that slice: the pure `TeamData.updateCount` primitive plus a pure `updateTeamStats` rebuild for one team, and the driver stamps the rebuilt `frame["team_unit_counts"]` before the assembler can_create call.

Composition, not re-implementation: `countType` already has a port-bridge pure function (`PortGame.source_unit_count_state`, `SourceUnitUpdatePortBridge.gd:105-111`, registered symbols `unit_count.*`); the N2140 helper already reads the name-keyed frame map. N2141 supplies the missing live counts behind that map — it does not duplicate the cap formula, the count lookup, or the canCreate predicate.

Implemented in `SourceTeamsRuntimeState.gd` (+ registry preload): pure `source_team_data_update_count_state(type_counts, type_id, amount, unit_count, content_unit_size)` (Teams.java:429-436 + countType read-back 442-444; `type_id < 0` maps to `type == null`, skip; grow via `Arrays.copyOf` semantics to `content_unit_size`, pad 0; both counts `Math.max(..., 0)`); pure `source_team_data_update_team_stats_state(units, team_id, content_unit_size)` (Teams.java:182-245 single-team: reset `data.unitCount = 0` + fill 0, then recount every live unit of the team via the updateCount primitive, recursing into `payload_units` exactly as `count(unit)` Teams.java:168-179, via private helper `_team_data_count_unit`; returns name-keyed `team_unit_counts` the N2140 helper reads); wired in the tick driver (`SourceUnitFactoryBuildState.gd`, assembler branch ~line 830): stamp `frame["team_unit_counts"]` from the stats rebuild before the `source_unit_factory_can_create_state` call; stale comment ("the frame still records no per-type unit counts...") removed — source-text test asserts it is gone.

CORRECTION to the RED design (implementation is faithful to Java; the RED expectation was wrong): `update_count_grows_array` expects `[1,0,0,1,0]`, not `[1,0,0,1]` — `Arrays.copyOf(typeCounts, Vars.content.units().size)` grows to the FULL content size (5), not to `type_id+1`. Proof expectation + comment fixed; verified by a direct Godot run printing the dict.

Gaps flagged (not slice bugs): (a) catalog unit ids are name strings only (`content_registry_units.json`, 56 units, `"id": "dagger"` etc.) — no integer `type.id`, no content-unit-size exposed — so the driver reads `content_unit_size` from the frame (`frame.get("content_unit_size", 0)`) and the proof passes it directly; no catalog value invented. (b) No frame carries a `units` list (frame starts `{}` in `_initial_frame()`; grep confirms no `"units"` key in the factory file) — the driver reads `frame.get("units", [])`, so the counts stay 0 until a unit-list slice lands.

## Proof keys (new scene, 7 keys)

New scene `C07UnitGroupCountsProof` (modeled on `C07UnitsCanCreateProof`, same Main scene), prefix `C_07_UNIT_GROUP_COUNTS_PROOF `; type ids in the proof: dagger 2, mace 1, crawler 4; content size 5:

- `update_count_add_grows`: counts null/empty, type_id 2, amount +1, content size 5 → type_counts [0,0,1,0,0], unit_count 1, count_type 1.
- `update_count_add_existing`: counts [0,3,0], type_id 1, amount +1, unit_count 3 → [0,4,0], unit_count 4, count_type 4.
- `update_count_remove_clamps_zero`: counts [0,1], type_id 1, amount -1 → [0,0], unit_count 0; and -1 on [0,0] stays [0,0], unit_count 0.
- `update_count_grows_array`: counts [1], type_id 3, amount +1, content size 5 → [1,0,0,1,0], unit_count 1.
- `count_type_null_counts`: counts empty/null, type_id 0, amount 0 → type_counts zeroed to content size, count_type 0.
- `update_team_stats_counts_units`: units dagger x2 + mace x1 for team 1, dagger x1 for team 2 → team 1 unit_count 3, team_unit_counts {dagger: 2, mace: 1} (team-2 unit excluded).
- `update_team_stats_payload_recursion`: unit dagger carrying payload crawler → unit_count 2, team_unit_counts {dagger: 1, crawler: 1}.

## Verified numbers (measured in this VM)

- Test module `test_c07_unit_group_counts.py`: **4/4 OK in 13.1s** (Godot on PATH, 23:30 cron run) — registration (ledger N2141, 5 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (5 new symbols + 22 exprs over Teams.java + UnitComp.java + PayloadComp.java, all found verbatim), source-text (both pure functions exist + the five quoted Java lines in the function comments + driver calls the stats function + the stale comment is gone; proof has the 7 new keys), and the Godot proof test (7 new keys, all true, `matches: true`).
- RED run (23:15 cron run): 4 tests in 2.538s, FAILED (failures=2, errors=2), all expected — registration `KeyError: 'N2141'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure functions did not exist yet), proof returncode 1 (proof scene did not exist yet).
- Neighbours (Godot on PATH, sequential): **20/20 OK** — `test_c07_units_can_create` (N2140) + `test_c06_unit_assembler_payload_should_consume` (N2132) + `test_unit_factory_should_consume` (N2124) + `test_c06_unit_assembler_production_tick` (N2139) + `test_c06_unit_factory_should_consume_power_stamp` (N2136), each 4/4.
- `git diff --check` clean.
- SSOT +5/+1/+2/+4 → **11291 / 1592 / 1512 / 2815**; audit stays 1335.

## Gate / suite

- Test modules standalone: N2141 4/4 (proof green, see above); neighbours 20/20.
- Godot proof: **GREEN 2026-11-12 ~23:41 +07** — 7 new keys all true, `matches: true`, on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- Full Python suite, inclusive gate with the N2141 module (log `tools/mindustry_godot_transpiler/full-suite-n2141-gate.log`, 211 modules): **FINISHED ~00:00 +07, VERIFIED clean except Godot in the 00:00 cron run — Ran 5661 tests in 905.646s, FAILED (failures=92, skipped=5), 0 errors. All 92 failures verified Godot-absent: 92 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None` (91 inherited + new N2141 proof test), 0 `ERROR:` blocks, 0 non-Godot failures; the N2141 module shows no failure other than its Godot-proof test.** Single gate attempt (setsid, PID 5263, ~23:41, main-thread launch) finished clean. The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule). No VM restart during this slice; javalang 0.13.0 verified present at the 23:30 run (no reinstall needed).

## Deferred

- Live `UnitComp.add()` / `remove()` lifecycle hooks (UnitComp.java:591-598, 603-604, 752: cap-death and env-death `updateCount(type, -1)` calls) — no live unit lifecycle in the port yet; the pure updateCount primitive is the state they will call, lifecycle wiring waits for a unit-lifecycle slice.
- `PayloadComp` add/remove count hooks (PayloadComp.java:101, 200) — same, payload lifecycle not ported yet.
- `Teams.updateTeamStats` full multi-team rebuild (`present`/`bosses`/`players`/`unitsByType`/`unitTree`, Teams.java:182-245) — N2141 rebuilds one team's counts only; presence/boss/player/tree state stays deferred.
- `Units.notifyUnitSpawn` / spawn path, `Call.unitCapDeath` / `Call.unitEnvDeath` net calls — presentation/net, not state.
- `power.status` live read — the driver folds `frame["power_status"]` (null → 1.0) until a power-status slice lands.
- C07–C12 remain open. Concrete follow-ups already deferred in the tree: `drones_in_position` / `spawn_occupied` / `allow_update` frame inputs, `moveOutPayload()` modeling, reconstructor `constructTime` catalog capture, net readUnits/whenSyncedUnits drone sync.

See `handoffs/2026-11-12-c07-unit-group-counts-handoff.md` for the full detail.
