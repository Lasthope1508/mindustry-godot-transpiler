# Handoff — N2141: Live per-type unit counts — TeamData.updateCount + updateTeamStats rebuild (unit-group system)

Date: 2026-11-12. Batch: N2141 (single slice). Status: **DONE + PUSHED 2026-11-13 ~00:05 +07 (00:00 cron run). Gate certified clean except Godot (Ran 5661, failures=92, skipped=5, 0 errors — all 92 Godot-absent asserts). Slice commit 3f580e7 + docs commit 1d5b38d on origin main; see "Gate certification" below.**

## Gate certification (00:00 cron run)

- Gate **FINISHED ~00:00 +07** (single attempt, setsid PID 5263, launched ~23:41, main-thread launch, no Godot on PATH): **Ran 5661 tests in 905.646s, FAILED (failures=92, skipped=5), 0 errors.** Verified in this run: 92 `FAIL:` blocks, 0 `ERROR:` blocks, every FAIL block contains `assertIsNotNone(godot)` / `unexpectedly None` (91 inherited + new N2141 proof test), 0 `ERROR:` lines in the log, 0 non-Godot failures; the N2141 module shows no failure other than its Godot-proof test (`test_reference_graph_and_actual_c07_unit_group_counts`). Log: `tools/mindustry_godot_transpiler/full-suite-n2141-gate.log` (63,871 bytes).
- Report written (`docs/superpowers/reports/2026-11-12-c07-unit-group-counts.md`); design spec updated (Status Summary 1591→1592 + N2141 checklist row + migration-log row); this handoff updated. Slice committed + docs committed + pushed to origin main this run (hashes below).

## GREEN progress (23:30 cron run)

- State at GREEN time: main at 2cf3ea5 (N2140 merged + pushed); RED done 23:15 (test module + this handoff untracked). javalang 0.13.0 + Godot 4.6.2 verified present at run start (no VM restart since RED — no reinstall needed).
- Register script `tools/mindustry_godot_transpiler/register_c07_unit_group_counts.py` (new, modeled on the N2140 one): 5 new symbols, all `java_source` `core/src/mindustry/game/Teams.java`. SSOT **11286/1591/1510/2811 → 11291/1592/1512/2815** (+5 symbols / +1 slice / +2 contracts / +4 schemas); audit stays 1335 (`totalSourceFunctions`).
- GREEN checks resolved: (a) catalog unit ids are name strings only (`content_registry_units.json`, 56 units, `"id": "dagger"` etc.) — no integer `type.id`, no content-unit-size exposed — so the driver reads `content_unit_size` from the frame (`frame.get("content_unit_size", 0)`) and the proof passes it directly; no catalog value invented. (b) No frame carries a `units` list (frame starts `{}` in `_initial_frame()`; grep confirms no `"units"` key in the factory file) — the driver reads `frame.get("units", [])`, so the counts stay 0 until a unit-list slice lands; flagged as a gap, not silently defaulted. (c) Registry consts added in `SourceRuntimeOwnerGameplayRegistry.gd:120-121`, following the `PORT_GAME_SOURCE_UNITS_CAN_CREATE_STATE` pattern: `PORT_GAME_SOURCE_TEAM_DATA_UPDATE_COUNT_STATE`, `PORT_GAME_SOURCE_TEAM_DATA_UPDATE_TEAM_STATS_STATE`.
- Implemented in `godot-mindustry/src/game/SourceTeamsRuntimeState.gd` (+ registry preload): pure `source_team_data_update_count_state(type_counts, type_id, amount, unit_count, content_unit_size)` (Teams.java:429-436 + countType read-back 442-444; `type_id < 0` maps to `type == null`, skip; grow via `Arrays.copyOf` semantics to `content_unit_size`, pad 0; both counts `Math.max(..., 0)`); pure `source_team_data_update_team_stats_state(units, team_id, content_unit_size)` (Teams.java:182-245 single-team: reset `data.unitCount = 0` + fill 0, then recount every live unit of the team via the updateCount primitive, recursing into `payload_units` exactly as `count(unit)` Teams.java:168-179, via private helper `_team_data_count_unit`; returns name-keyed `team_unit_counts` the N2140 helper reads); wired in the tick driver (`SourceUnitFactoryBuildState.gd`, assembler branch ~line 830): stamp `frame["team_unit_counts"]` from the stats rebuild before the `source_unit_factory_can_create_state` call; stale comment ("the frame still records no per-type unit counts...") removed — source-text test asserts it is gone.
- CORRECTION to the RED design (implementation is faithful to Java; the RED expectation was wrong): `update_count_grows_array` expects `[1,0,0,1,0]`, not `[1,0,0,1]` — `Arrays.copyOf(typeCounts, Vars.content.units().size)` grows to the FULL content size (5), not to `type_id+1`. Proof expectation + comment fixed; verified by a direct Godot run printing the dict.
- Proof scene new: `godot-mindustry/tools/runtime_proofs/C07UnitGroupCountsProof.gd` + `.tscn` (modeled on `C07UnitsCanCreateProof`), prefix `C_07_UNIT_GROUP_COUNTS_PROOF `, 7 keys. Type ids in the proof: dagger 2, mace 1, crawler 4; content size 5.
- Targeted **4/4 OK in 13.1s** (Godot on PATH). Neighbours **20/20 OK** (5 modules × 4, sequential, Godot on PATH): N2140 `test_c07_units_can_create`, N2132 `test_c06_unit_assembler_payload_should_consume`, N2124 `test_unit_factory_should_consume`, N2139 `test_c06_unit_assembler_production_tick`, N2136 `test_c06_unit_factory_should_consume_power_stamp`.
- `git diff --check` clean.
- Full gate launched ~23:41 +07 from this run: `setsid python3 -m unittest discover -s tests > full-suite-n2141-gate.log 2>&1` (no Godot on PATH, established pattern), PID 5263, SID 5263, PPID 1 (verified detached), ~95% CPU, log growing. Expected: Ran ~5661, FAILED (failures=92, skipped=5), 0 errors — all Godot-absent asserts (91 inherited + new N2141 proof test). NO proof scene run while the gate runs (port-7777 rule). **Do NOT commit/push until the gate is certified clean except Godot.**

## RED progress (23:15 cron run)

- State at RED time: main at 2cf3ea5 (N2140 merged + pushed to the fork 2026-11-12 ~23:05; C07 entry slice done). Working tree clean except untracked `*.gd.uid` files (never stage) and untracked gate logs (pre-existing env noise, not this slice).
- javalang was MISSING at run start (VM restarted since the 23:00 run — system-wide pip wiped again); reinstalled 0.13.0 (`pip install --break-system-packages javalang==0.13.0`, verified import OK) before the RED run, per the post-restart rule. Godot 4.6.2 present (`~/workspace/godot-bin/godot`; `godot` is NOT on the default PATH — targeted runs must `export PATH="$HOME/workspace/godot-bin:$PATH"`).
- Test module written: `tools/mindustry_godot_transpiler/tests/test_c07_unit_group_counts.py` (4 tests). RED run (Godot on PATH): **Ran 4 tests in 2.538s, FAILED (failures=2, errors=2)** — all expected:
  - registration `KeyError: 'N2141'` (ledger entry not written yet);
  - evidence errors on the missing ledger entry (same KeyError);
  - source-text `AssertionError`: `source_team_data_update_count_state` not found in `SourceTeamsRuntimeState.gd` (the pure functions do not exist yet);
  - proof: Godot returncode 1, `Cannot open file 'res://tools/runtime_proofs/C07UnitGroupCountsProof.tscn'` — the proof scene does not exist yet.
- `git diff --check` clean (no tracked changes yet — only the new untracked test module + this handoff).

## What this batch is

The first deferred follow-up from N2140 and the next C07 item per the completion backlog (unit lifecycle/teams). N2140's canCreate helper reads `frame["team_unit_counts"]` (default 0 for a missing unit, exactly `TeamData.countType`, Teams.java:442-444) but no frame records it yet — the tick driver comment says "the frame still records no per-type unit counts, so the count reads 0 until the unit-group slice lands." N2141 is that slice: the pure `TeamData.updateCount` primitive plus a pure `updateTeamStats` rebuild for one team, and the driver stamps the rebuilt `frame["team_unit_counts"]` before the assembler can_create call.

Composition, not re-implementation: `countType` already has a port-bridge pure function (`PortGame.source_unit_count_state`, `SourceUnitUpdatePortBridge.gd:105-111`, registered symbols `unit_count.*`); the N2140 helper already reads the name-keyed frame map. N2141 supplies the missing live counts behind that map — it does not duplicate the cap formula, the count lookup, or the canCreate predicate.

## Exact upstream evidence (all 22 exprs verified verbatim in this VM)

- `TeamData.typeCounts` / `updateCount` / `countType` (Teams.java:302, 429-436, 442-444): `public @Nullable int[] typeCounts;` / `public void updateCount(UnitType type, int amount){` / `if(type == null) return;` / `unitCount = Math.max(amount + unitCount, 0);` / `if(typeCounts == null || typeCounts.length <= type.id){` / `typeCounts = typeCounts == null ? new int[Vars.content.units().size] : Arrays.copyOf(typeCounts, Vars.content.units().size);` / `typeCounts[type.id] = Math.max(amount + typeCounts[type.id], 0);` / `public int countType(UnitType type){` / `return typeCounts == null || typeCounts.length <= type.id ? 0 : typeCounts[type.id];`
- `Teams.updateTeamStats` reset + rebuild (Teams.java:182, 187, 199-200, 213, 218): `public void updateTeamStats(){` / `data.unitCount = 0;` / `if(data.typeCounts != null){` / `Arrays.fill(data.typeCounts, 0);` / `for(Unit unit : Groups.unit){` / `data.units.add(unit);`
- `Teams.count(unit)` payload recursion (Teams.java:168-169, 175): `private void count(Unit unit){` / `unit.team.data().updateCount(unit.type, 1);` / `count(payload.unit);`
- `updateCount` lifecycle call sites (UnitComp.java:592, 597; PayloadComp.java:101, 200): `team.data().updateCount(type, 1);` / `team.data().updateCount(type, -1);` / `if(unit.isAdded()) unit.team.data().updateCount(unit.type, 1);` / `if(!u.isAdded()) u.team.data().updateCount(u.type, -1);`

## Design (decided in RED, implement in GREEN)

- **New pure function 1** `SourceTeamsRuntimeState.source_team_data_update_count_state(type_counts: Array, type_id: int, amount: int, unit_count: int, content_unit_size: int) -> Dictionary` — evaluates `TeamData.updateCount` (Teams.java:429-436) exactly: `type == null` maps to `type_id < 0` (skip, counts unchanged); grow the array to `content_unit_size` when null/short (`Arrays.copyOf` semantics — pad with 0); `unitCount = Math.max(amount + unitCount, 0)`; `typeCounts[type.id] = Math.max(amount + typeCounts[type.id], 0)`; read the updated per-type count back through the `countType` formula (Teams.java:442-444). Returns `{"source_owner": <new registry const>, "type_counts", "unit_count", "count_type"}`. The function's header comment quotes the updateCount lines and the countType line verbatim — the source-text test asserts them.
- **New pure function 2** `SourceTeamsRuntimeState.source_team_data_update_team_stats_state(units: Array, team_id: int, content_unit_size: int) -> Dictionary` — evaluates the `updateTeamStats` reset + rebuild for ONE team (Teams.java:182-245, single-team restriction is the frame's view): reset (`data.unitCount = 0;`, `Arrays.fill(data.typeCounts, 0);`), then for each unit record of that team in `units` (records `{"team_id": int, "type_id": int, "type_name": String, "payload_units": [...]}` — the `Groups.unit` iteration, Teams.java:213) count it via the updateCount primitive, recursing into `payload_units` exactly as `count(unit)` (Teams.java:168-179). Returns `{"source_owner": <new registry const>, "unit_count", "team_unit_counts"}` where `team_unit_counts` is the name-keyed map the N2140 helper reads (`frame["team_unit_counts"].get(plan_unit, 0)`). The function's header comment quotes the `data.unitCount = 0;` and `count(unit);` lines verbatim — the source-text test asserts them.
  - GREEN checks: (a) whether the unit catalog exposes a per-type id / content unit count (`Vars.content.units().size`) for `content_unit_size` — check with evidence; absent → the driver reads the size from the frame (`frame.get("content_unit_size", ...)`) or the proof passes it directly; do not invent a catalog value; (b) whether any frame already carries a `units` list (expect absent — the driver reads `frame.get("units", [])`, empty → counts stay 0; flag it as a gap, do not silently default to "all in position"); (c) the two registry consts' exact names (`PORT_GAME_SOURCE_TEAM_DATA_UPDATE_COUNT_STATE`, `PORT_GAME_SOURCE_TEAM_DATA_UPDATE_TEAM_STATS_STATE`) — follow the existing `PORT_GAME_SOURCE_UNITS_CAN_CREATE_STATE` pattern in `SourceRuntimeOwnerGameplayRegistry.gd:119`.
- **Wiring** in `SourceUnitFactoryBuildState` tick driver (line ~825, assembler branch): before the `source_unit_factory_can_create_state` call, stamp `frame["team_unit_counts"]` from `source_team_data_update_team_stats_state(frame.get("units", []), team_id, content_unit_size)`; remove the stale comment ("the frame still records no per-type unit counts, so the count reads 0 until the unit-group slice lands") — the source-text test asserts the substring `the frame still records no` is gone. The can_create call itself is unchanged (it already reads the frame map).
- **Proof**: new scene `godot-mindustry/tools/runtime_proofs/C07UnitGroupCountsProof.gd` + `.tscn` (modeled on `C07UnitsCanCreateProof`, same Main scene), prefix `C_07_UNIT_GROUP_COUNTS_PROOF `, 7 keys driving the pure functions directly:
  - `update_count_add_grows`: counts null/empty, type_id 2, amount +1, content size 5 → type_counts [0,0,1,0,0], unit_count 1, count_type 1.
  - `update_count_add_existing`: counts [0,3,0], type_id 1, amount +1, unit_count 3 → [0,4,0], unit_count 4, count_type 4.
  - `update_count_remove_clamps_zero`: counts [0,1], type_id 1, amount -1 → [0,0], unit_count 0; and -1 on [0,0] stays [0,0], unit_count 0.
  - `update_count_grows_array`: counts [1], type_id 3, amount +1, content size 5 → [1,0,0,1,0], unit_count 1. (GREEN correction: the RED draft said [1,0,0,1] — `Arrays.copyOf` grows to the full content size 5, not to type_id+1; the implementation is faithful, the expectation was fixed.)
  - `count_type_null_counts`: counts empty/null, type_id 0, amount 0 → type_counts zeroed to content size, count_type 0.
  - `update_team_stats_counts_units`: units dagger x2 + mace x1 for team 1, dagger x1 for team 2 → team 1 unit_count 3, team_unit_counts {dagger: 2, mace: 1} (team-2 unit excluded).
  - `update_team_stats_payload_recursion`: unit dagger carrying payload crawler → unit_count 2, team_unit_counts {dagger: 1, crawler: 1}.
  - GREEN check: cells free on the Main scene; proof JSON is gitignored, never stage it.
- **Register script** `register_c07_unit_group_counts.py` (GREEN, modeled on the N2140 one): 5 new symbols, each with its Java line as `java_expr`, all `java_source` `core/src/mindustry/game/Teams.java`:
  - `source_team_data_update_count_state_result.type_counts` ← `typeCounts[type.id] = Math.max(amount + typeCounts[type.id], 0);`
  - `source_team_data_update_count_state_result.unit_count` ← `unitCount = Math.max(amount + unitCount, 0);`
  - `source_team_data_update_count_state_result.count_type` ← `return typeCounts == null || typeCounts.length <= type.id ? 0 : typeCounts[type.id];`
  - `source_team_data_update_team_stats_state_result.team_unit_counts` ← `count(unit);`
  - `source_team_data_update_team_stats_state_result.unit_count` ← `data.unitCount = 0;`
  - Expected SSOT +5 symbols / +1 slice → **11291 / 1592 / … / …**; contracts/schema deltas VERIFY in GREEN (the register script prints the actuals); audit 1335.

## Files changed (RED only; uncommitted)

- `tools/mindustry_godot_transpiler/tests/test_c07_unit_group_counts.py` (new, 4 tests): registration (ledger N2141, 5 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (5 new symbols + 22 exprs over Teams.java + UnitComp.java + PayloadComp.java), source-text (both pure functions exist + the five quoted Java lines in the function comments + driver calls the stats function + the stale comment is gone; proof has the 7 new keys), Godot proof (`C07UnitGroupCountsProof.tscn`, prefix `C_07_UNIT_GROUP_COUNTS_PROOF `, the 7 new keys true).
- This handoff (new, untracked).

## Verified numbers (do not re-derive, these are measured in this VM)

- RED run: **4 tests in 2.538s, FAILED (failures=2, errors=2), all expected** — registration `KeyError: 'N2141'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure functions do not exist yet), proof returncode 1 (proof scene does not exist yet).
- Exact-expr pre-check: **22/22 exprs found verbatim** in the 3 slice sources (Teams.java, UnitComp.java, PayloadComp.java).
- `git diff --check` clean.
- State at RED time: main at 2cf3ea5 (N2140 merged + pushed to the fork 2026-11-12 ~23:05); SSOT 11286 / 1591 / 1510 / 2811; audit 1335.
- javalang 0.13.0 reinstalled at this run (VM restart wiped it); Godot 4.6.2 on `~/workspace/godot-bin`.

## Gate certification — DONE (00:00 cron run, see "Gate certification" above)

- ~~Check the gate log~~ — certified: Ran 5661, failures=92, skipped=5, 0 errors, all 92 Godot-absent asserts. Report + spec + handoff updated; slice + docs committed + pushed to the fork (stage exact slice files only; never stage `*.gd.uid`, `project.godot`, `arc-upstream/`, `mindustry-upstream/`, proof `.json`, gate logs).
- GREEN checks from the design above: (a) catalog `content.units().size` / per-type id source for `content_unit_size`; (b) whether any frame carries a `units` list; (c) registry const naming.

## Next (after N2141 lands)

- C07 continues per the completion backlog: unit lifecycle/controller/pathfinding/command/weapon/death, wave/spawn/teams, map/world transition, campaign persistence. Concrete follow-ups already deferred in the tree: `power.status` live read, `drones_in_position` / `spawn_occupied` / `allow_update` frame inputs, `moveOutPayload()` modeling, reconstructor `constructTime` catalog capture, net readUnits/whenSyncedUnits drone sync.

## Deferred (not this slice)

- Live `UnitComp.add()` / `remove()` lifecycle hooks (UnitComp.java:591-598, 603-604, 752: cap-death and env-death `updateCount(type, -1)` calls) — no live unit lifecycle in the port yet; the pure updateCount primitive is the state they will call, lifecycle wiring waits for a unit-lifecycle slice.
- `PayloadComp` add/remove count hooks (PayloadComp.java:101, 200) — same, payload lifecycle not ported yet.
- `Teams.updateTeamStats` full multi-team rebuild (`present`/`bosses`/`players`/`unitsByType`/`unitTree`, Teams.java:182-245) — N2141 rebuilds one team's counts only; presence/boss/player/tree state stays deferred.
- `Units.notifyUnitSpawn` / spawn path, `Call.unitCapDeath` / `Call.unitEnvDeath` net calls — presentation/net, not state.
- `power.status` live read — the driver folds `frame["power_status"]` (null → 1.0) until a power-status slice lands.
- C07–C12 remain open.
