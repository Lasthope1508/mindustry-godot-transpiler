# Handoff — N2140: Units.canCreate live evaluation (C07 entry slice)

Date: 2026-11-12. Batch: N2140 (single slice). Status: **DONE + PUSHED 2026-11-12 ~23:05 +07 (23:00 cron run). Targeted 4/4 OK, neighbours 28/28, Godot proof GREEN, full gate attempt 2 verified clean except Godot (Ran 5657, failures=91, skipped=5, 0 errors — all 91 Godot-absent asserts). Committed + pushed to the fork — see "Commit" below.**

## GREEN progress (22:15 cron run, TIMED OUT before logging neighbours/gate)

- Register script run: SSOT 11282/1590/1509/2809 → **11286/1591/1510/2811**, audit 1335 (totalSourceFunctions). 4 new symbols, registry const `PORT_GAME_SOURCE_UNITS_CAN_CREATE_STATE`.
- Pure function `SourceUnitRuntimeState.source_units_can_create_state` + factory helper `source_unit_factory_can_create_state` (cap bridge + frame `team_unit_counts` + Rules.isBanned); wiring in should_consume assembler branch + production tick driver; stale deferred comment removed; proof `C07UnitsCanCreateProof` (6 keys) GREEN. Targeted **4/4 OK** (13.2s, Godot proof GREEN), re-verified 22:30 run 4/4 OK in 12.9s.
- Neighbours at 22:15: 2 failures (N2124 + N2132 proof tests) — single key `should_consume_assembler_full_blocks_true` False in both; all other keys true.

## Neighbour fix + gate (22:30 cron run)

- Root cause (verified): with game null the direct proof calls read rules `{}` → cap 0 (Rules.unitCap default) → can_create false for every assembler case. The 22:15 handoff's prescribed fix ("supply unitCap in the proof frame") alone was not enough — `source_unit_factory_should_consume_state` only read rules from `game`, never from the frame, so a frame rules_state would have been ignored.
- Fix (proof/test-harness only, no gameplay change — live call sites always pass game non-null): (a) should_consume now falls back to `frame.get("rules_state", {})` when game is null — the frame-rules convention already exists (tick driver stamps `frame["rules_state"]`, cons-item efficiency reads it); (b) proof scene: full-blocks frame carries `"rules_state": {"unitCap": 10}` (count 0 < 10 → can_create true); no-create frame carries `"rules_state": {"unitCap": 0}` instead of the now-dead `"can_create": false` key, so the false comes from the live evaluation.
- After the fix, neighbours all green (sequential, Godot on PATH): N2124 4/4, N2132 4/4, N2137 4/4, N2138 4/4, N2139 4/4, N2128 4/4, N2140 4/4 = **28/28 OK**. (Combined-run port-7777 collision failures earlier in this run were env-only; sequential re-runs pass.)
- Gate launched ~22:41 from the main thread: `setsid python3 -m unittest discover -s tests > full-suite-n2140-gate.log 2>&1` (no Godot on PATH), PID 12440, SID 12440, 95% CPU, log growing, dots only. Expected: Ran ~5657, FAILED (failures=91, skipped=5), 0 errors — all 91 Godot-absent asserts (90 inherited + new N2140 proof test). Verify every failure is `assertIsNotNone(godot)` / `unexpectedly None`, 0 ERROR lines, and N2140/N2124/N2132 have no failure outside the Godot-proof tests.
- **Attempt 1 (PID 12440) DIED ~22:44 +07** (same session-end signature): PID gone, log frozen at 4878 bytes (last write 22:44:04 +07). Frozen log preserved as `full-suite-n2140-gate-attempt1.log`. Note: it died even though the worker reported it launched "from the main thread" with setsid — the cron worker's launch does NOT survive the worker's session ending.
- **Attempt 2 STARTED ~22:45 +07** (main-thread restart; same surviving method: backgrounded `&&` chain, subshell stays alive as the gate's parent): `setsid nohup python3 -m unittest discover -s tests`, PID 13033 (own session SID 13033, verified; log growing 3443 → 3445 bytes, dots only so far), no Godot on PATH. javalang 0.13.0 verified present before restart. Expected done ~23:13-23:23 +07; expected **Ran ~5657, FAILED (failures=91, skipped=5), 0 errors** — all 91 `assertIsNotNone(godot)`. **Do NOT start another gate while PID 13033 is running; verify its result in the next run(s) before commit/push. Do NOT run proof scenes while it runs** (port-7777 bind ERROR fails proof tests).
- `git diff --check` clean. Working tree: 8 files changed, +357/-13 (7 tracked GREEN files + proof .gd; proof .tscn + register script + test module untracked, to be staged with the slice). javalang 0.13.0 present (no VM restart since 22:00); Godot 4.6.2 on `~/workspace/godot-bin`.

## RED progress (22:00 cron run, 2026-11-12 ~22:00 +07)

- State at RED time: main at cf3d958 (N2139 merged + pushed to the fork 2026-11-12 ~21:45; C06 factory production ticks closed with N2137 + N2138 + N2139). Working tree clean except untracked `*.gd.uid` files (never stage) and untracked gate logs (pre-existing env noise, not this slice).
- javalang 0.13.0 present; Godot 4.6.2 present (`~/workspace/godot-bin/godot`; `godot` is NOT on the default PATH — targeted runs must `export PATH="$HOME/workspace/godot-bin:$PATH"`).
- Test module written: `tools/mindustry_godot_transpiler/tests/test_c07_units_can_create.py` (4 tests). RED run (Godot on PATH): **Ran 4 tests in 0.636s, FAILED (failures=2, errors=2)** — all expected:
  - registration `KeyError: 'N2140'` (ledger entry not written yet);
  - evidence errors on the missing ledger entry (same KeyError);
  - source-text `AssertionError`: `source_units_can_create_state` not found in `SourceUnitRuntimeState.gd` (the pure function + factory wiring do not exist yet);
  - proof: Godot returncode 1, `Cannot open file 'res://tools/runtime_proofs/C07UnitsCanCreateProof.tscn'` — the proof scene does not exist yet.
- `git diff --check` clean (no tracked changes yet — only the new untracked test module + this handoff).

## What this batch is

The C07 entry slice and the first item on the N2139 "Next" list (C07–C12 per the completion backlog). The N2139 handoff deferred `Units.canCreate` live evaluation to C07 ("needs C07: live per-type unit counts + the unit cap"); the assembler `should_consume` branch (`SourceUnitFactoryBuildState.gd:593`) and the production tick driver (`SourceUnitFactoryBuildState.gd:778`) still read `frame["can_create"]`, default true. N2140 is that slice: a pure `source_units_can_create_state` that evaluates `Units.canCreate(team, type)` (Units.java:115-117) and wires both assembler call sites to call it instead of the permissive frame default.

Composition, not re-implementation: `getCap` and `countType` already have port-bridge pure functions (`PortGame.source_unit_cap_state`, `PortGame.source_unit_count_state`, `SourceUnitUpdatePortBridge.gd:105-111`, registered symbols `unit_cap.*` / `unit_count.*`); `isBanned` logic already exists in the factory file (`SourceUnitFactoryBuildState.gd:152-174`, `unitWhitelist != bannedUnits.contains(unit)`). N2140 composes those three already-ported pieces with `type.useUnitCap` into the one predicate — it does not duplicate the cap formula or the count lookup.

## Exact upstream evidence (all 22 exprs verified verbatim in this VM)

- `Units.canCreate` / `Units.getCap` (Units.java:115-125): `public static boolean canCreate(Team team, UnitType type){` / `return !type.useUnitCap || (team.data().countType(type) < getCap(team) && !type.isBanned());` / `public static int getCap(Team team){` / `if((team == state.rules.waveTeam && !state.rules.pvp) || (state.isCampaign() && team == state.rules.waveTeam) || state.rules.disableUnitCap || team.ignoreUnitCap){` / `return Integer.MAX_VALUE;` / `return Math.max(0, state.rules.unitCapVariable ? state.rules.unitCap + team.data().unitCap : state.rules.unitCap);`
- `TeamData.countType` (Teams.java:442-444): `public int countType(UnitType type){` / `return typeCounts == null || typeCounts.length <= type.id ? 0 : typeCounts[type.id];`
- `UnitType.isBanned` / `useUnitCap` (UnitType.java:205, 759-761): `useUnitCap = true,` / `public boolean isBanned(){` / `return state.rules.isBanned(this);`
- `Rules.isBanned` / cap fields (Rules.java:41, 75, 157, 159, 207, 311-313): `public boolean pvp;` / `public boolean unitCapVariable = true;` / `public int unitCap = 0;` / `public boolean disableUnitCap;` / `public Team waveTeam = Team.crux;` / `public boolean isBanned(UnitType unit){` / `return unitWhitelist != bannedUnits.contains(unit);`
- `Team.ignoreUnitCap` (Team.java:22): `public boolean ignoreUnitCap = false;`
- `GameState.isCampaign` (GameState.java:73-75): `public boolean isCampaign(){`
- Assembler call sites the wiring replaces (UnitAssembler.java:391, 524): `return enabled && !wasOccupied && Units.canCreate(team, plan().unit) && consPayload.efficiency(this) > 0 && consItem.efficiency(this) > 0 && team.activateUnitFactories();` / `if(!wasOccupied && efficiency > 0 && Units.canCreate(team, plan.unit)){`

## Design (decided in RED, implement in GREEN)

- **New pure function** `SourceUnitRuntimeState.source_units_can_create_state(use_unit_cap: bool, count_type: int, unit_cap: int, is_banned: bool) -> Dictionary` — evaluates `!use_unit_cap || (count_type < unit_cap && !is_banned)` exactly as Units.java:116. The caller computes `unit_cap` through the existing `source_unit_cap_state` bridge and `count_type` through the existing `source_unit_count_state` bridge; this function only composes them, so the cap formula and the count lookup are not duplicated. Returns `{"source_owner": <new registry const>, "can_create", "unit_cap", "count_type", "is_banned"}`. The function's header comment quotes the canCreate line and the getCap formula line verbatim — the source-text test asserts them.
  - GREEN check: whether the function should live in `SourceUnitRuntimeState` (direct static func, like its `drowning_state`/`captured_sector_death_state`) or be exposed through a `PortGame` wrapper like the cap/count bridges (`PortGame.source_unit_update_drowning_state` pattern). Decide with evidence: the factory file already calls `SourceUnitFactoryBuildState` static funcs directly from the driver; if the factory file can call `SourceUnitRuntimeState.source_units_can_create_state` directly, keep it direct — do not add a PortGame wrapper just for symmetry.
- **Wiring** in `SourceUnitFactoryBuildState`:
  - `should_consume` assembler branch (line ~593): replace `result["can_create"] = bool(frame.get("can_create", true))` with a call to the new pure function, fed by the plan unit (`plan.get("unit", "")`), the frame's per-type counts, the cap bridge over `rules_state` + team, and the banned check over `rules_state` (same `bannedUnits`/`unitWhitelist` read the has-upgrade state already does at lines 173-174).
  - Production tick driver (line ~778): pass the same computed `can_create` into `source_unit_assembler_production_tick_state` instead of `bool(frame.get("can_create", true))`.
  - Remove the stale deferred comment (lines 529-531: "Units.canCreate (Units.java:115-117) needs live per-type unit counts and the unit cap (the unit-group system, C07) — frame[\"can_create\"], default true") — the source-text test asserts it is gone.
  - GREEN checks: (a) whether the frame records per-type unit counts (`team_unit_counts` / `type_counts` — expect absent; decide the default with evidence: absent → count 0, permissive until a unit-group slice lands; flag it as a gap, do not silently default to "all in position"); (b) whether `rules_state` exposes `team.data().unitCap` (TeamData.unitCap) for the cap bridge — check the rules-state keys with evidence; (c) whether the catalog captures `useUnitCap` per unit type (UnitType.java:205 defaults true — check the unit-type metadata with evidence; absent → default true, the Java default); (d) whether `rules_state` already carries `bannedUnits`/`unitWhitelist` (the has-upgrade state reads them — expect present, verify).
- **Proof**: new scene `godot-mindustry/tools/runtime_proofs/C07UnitsCanCreateProof.gd` + `.tscn` (modeled on `C06UnitAssemblerProductionProof`, same Main scene), prefix `C_07_UNITS_CAN_CREATE_PROOF `, 6 keys driving the pure function directly (plan unit mace, cap 10 unless noted):
  - `can_create_under_cap`: useUnitCap true, count 9, cap 10, not banned → true.
  - `can_create_at_cap`: useUnitCap true, count 10, cap 10, not banned → false.
  - `can_create_no_cap_type`: useUnitCap false, count 99, cap 10 → true.
  - `can_create_banned_unit`: useUnitCap true, count 0, cap 10, banned true → false.
  - `can_create_uncapped_wave_team`: cap 2147483647 (`Integer.MAX_VALUE`), count 100 → true.
  - `can_create_variable_cap`: cap 15 (rules.unitCap 10 + teamData.unitCap 5), count 14 → true, result `unit_cap` == 15.
  - GREEN check: cells free on the Main scene; proof JSON is gitignored, never stage it.
- **Register script** `register_c07_units_can_create.py` (GREEN, modeled on the N2139 one): 4 new symbols, one per returned value, each with its Java line as `java_expr` (note the three different `java_source` files — the registration test asserts them per symbol):
  - `source_units_can_create_state_result.can_create` ← `return !type.useUnitCap || (team.data().countType(type) < getCap(team) && !type.isBanned());` (Units.java)
  - `source_units_can_create_state_result.unit_cap` ← `return Math.max(0, state.rules.unitCapVariable ? state.rules.unitCap + team.data().unitCap : state.rules.unitCap);` (Units.java)
  - `source_units_can_create_state_result.count_type` ← `return typeCounts == null || typeCounts.length <= type.id ? 0 : typeCounts[type.id];` (Teams.java)
  - `source_units_can_create_state_result.is_banned` ← `return unitWhitelist != bannedUnits.contains(unit);` (Rules.java)
  - Expected SSOT +4 symbols / +1 slice → **11286 / 1591 / … / …**; contracts/schema deltas VERIFY in GREEN (the register script prints the actuals); audit 1335.

## Files changed (RED + GREEN; uncommitted)

- `tools/mindustry_godot_transpiler/tests/test_c07_units_can_create.py` (new, 4 tests): registration (ledger N2140, 4 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (4 new symbols + 22 exprs over Units.java + Teams.java + UnitType.java + Rules.java + Team.java + GameState.java + UnitAssembler.java), source-text (pure function exists + the two quoted Java lines in the function comment + factory calls it + the deferred comment is gone; proof has the 6 new keys), Godot proof (`C07UnitsCanCreateProof.tscn`, prefix `C_07_UNITS_CAN_CREATE_PROOF `, the 6 new keys true).
- GREEN (22:15 run): `godot-mindustry/src/game/SourceUnitRuntimeState.gd` (pure function + registry preload), `godot-mindustry/src/game/SourceRuntimeOwnerGameplayRegistry.gd` (1 const), `godot-mindustry/src/game/SourceUnitFactoryBuildState.gd` (helper + 2 wiring call sites), `godot-mindustry/src/generated/` (registry + ledger + contracts + schema), `godot-mindustry/tools/runtime_proofs/C07UnitsCanCreateProof.gd` + `.tscn` (new), `tools/mindustry_godot_transpiler/register_c07_units_can_create.py` (new).
- Neighbour fix (22:30 run): `SourceUnitFactoryBuildState.gd` (frame-`rules_state` fallback when game is null) + `C06UnitFactoryShouldConsumeProof.gd` (full-blocks `rules_state: {unitCap: 10}`, no-create `rules_state: {unitCap: 0}`).

## Verified numbers (do not re-derive, these are measured in this VM)

- RED run: **4 tests in 0.636s, FAILED (failures=2, errors=2), all expected** — registration `KeyError: 'N2140'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure function does not exist yet), proof returncode 1 (proof scene does not exist yet).
- Exact-expr pre-check: **22/22 exprs found verbatim** in the 7 slice sources (Units.java, Teams.java, UnitType.java, Rules.java, Team.java, GameState.java, UnitAssembler.java).
- `git diff --check` clean.
- State at RED time: main at cf3d958 (N2139 merged + pushed to the fork 2026-11-12 ~21:45); SSOT 11282 / 1590 / 1509 / 2809; audit 1335.

## Gate verification (23:00 cron run)

- **Attempt 2 (PID 13033, ~22:45, main-thread setsid launch) FINISHED ~23:00 +07: Ran 5657 tests in 886.721s, FAILED (failures=91, skipped=5), 0 errors.** Verified: 91 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None` (90 plain + 1 hydration proof), 0 `ERROR:` blocks, 0 non-Godot failures; the N2140 module shows no failure other than its Godot-proof test, and the N2124/N2132 modules likewise. Gate clean except Godot — commit/push authorized.
- Attempt 1 (PID 12440) died ~22:44 session-end; frozen log preserved as `full-suite-n2140-gate-attempt1.log`.
- Report `docs/superpowers/reports/2026-11-12-c07-units-can-create.md` written; design spec updated (Status Summary 1590→1591, N2140 checklist row + changelog row).

## GREEN work remaining (next run)

~~All done this run (23:00): gate verified, report + design spec + handoff updated, slice committed + pushed (see "Commit" below).~~

## Next (after N2140 lands)

- C07 continues per the completion backlog (docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md): unit lifecycle/controller/pathfinding/command/weapon/death, wave/spawn/teams, map/world transition, campaign persistence. Concrete follow-ups already deferred in the tree: live per-type unit counts in the frame (GREEN check (a) above — the unit-group system), `power.status` live read, `drones_in_position` / `spawn_occupied` / `allow_update` frame inputs, `moveOutPayload()` modeling, reconstructor `constructTime` catalog capture.

## Deferred (not this slice)

- Live per-type unit counts in the frame (`team.data().typeCounts`, Teams.java:430-444) — the pure function takes `count_type` as an input; the frame does not record it yet (GREEN check (a)).
- Net readUnits/whenSyncedUnits drone sync (UnitAssembler.java:430-460) — client sync, needs the net slice.
- `units.removeAll(u -> !u.isAdded() || u.dead || !(u.controller() instanceof AssemblerAI))` (UnitAssembler.java:461) — live unit list, no port frame for it yet.
- AI perimeter arrangement (`ai.targetPos.trns(...)`, `ai.targetAngle`, UnitAssembler.java:506-513) — AssemblerAI presentation, not state.
- Live-world spawn path in `spawned()` (`unit.set`, `unit.add`, `unit.buildOn`, `acceptPayload`/`handlePayload`, `Units.notifyUnitSpawn`, UnitAssembler.java:548-563) — the pure tick records `spawned`/`consumed`/`unit_created_event` as state.
- Commandable `commandPos` branch + `createSound` + `Fx.unitAssemble` (UnitAssembler.java:549-551, 564-566) — presentation, not state.
- `Call.assemblerDroneSpawned` net call (UnitAssembler.java:488) — the pure tick records `drone_spawned` as state.
- Drone controller-not-AssemblerAI bug guard (UnitAssembler.java:479-490) — data-patch guard, deferred to a validation slice.
- `checkSolid` live collision queries + `getUnitSpawn` geometry (UnitAssembler.java:332-336, 675-681) — the pure tick takes occupancy as inputs.
- `power.status` live read — the driver folds `frame["power_status"]` (null → 1.0) until a power-status slice lands.
- C07–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

## Gate verified + commit (23:00 cron run, 2026-11-12 ~23:00-23:05 +07)

- **Gate attempt 2 FINISHED ~23:00 +07** (setsid PID 13033, started ~22:45, main-thread launch): **Ran 5657 tests in 886.721s, FAILED (failures=91, skipped=5), 0 errors** — verified in this run: 91 `FAIL:` blocks, 0 `ERROR:` blocks, all 91 `unexpectedly None` (90 plain `assertIsNotNone(godot)` + 1 hydration proof), 0 non-Godot failures; the N2140 module shows no failure other than its Godot-proof test, the N2124/N2132 modules likewise. Attempt 1 (setsid PID 12440, ~22:41) died ~22:44 at session-end (log frozen at 4878 bytes, preserved as `full-suite-n2140-gate-attempt1.log`); attempt 2 finished clean. Log `tools/mindustry_godot_transpiler/full-suite-n2140-gate.log`.
- Report `docs/superpowers/reports/2026-11-12-c07-units-can-create.md` written; design spec updated (N2140 checklist row + Status Summary 1590→1591 + changelog row).
- Slice commit: 54b10e1. Docs commit: d277094.

## Commit

DONE + PUSHED 2026-11-12 ~23:05 +07 — slice commit 54b10e1 + docs commit d277094 (+ this handoff-hash commit) pushed to origin main (fork Lasthope1508). Gate verified clean except Godot.
