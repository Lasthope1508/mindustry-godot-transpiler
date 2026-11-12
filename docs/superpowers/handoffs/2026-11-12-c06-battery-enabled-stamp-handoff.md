# Handoff — N2134: battery live `enabled` stamp

Date: 2026-11-12. Batch: N2134 (single slice). Status: **DONE + PUSHED 2026-11-12 ~15:15 +07 (15:00 cron run): register + function + wiring + proof scene, targeted 4/4 OK, Godot proof GREEN (6 keys, matches:true). Full gate attempt 2 FINISHED ~15:06 +07: Ran 5633 in 1660.539s, FAILED (failures=85, skipped=5), 0 errors — all 85 verified Godot-proof asserts (84 plain assertIsNotNone + 1 hydration), zero real failures. Report + design spec (Status Summary 1584→1585) + this handoff updated; committed + pushed to origin main.**

## RED progress (14:15 cron run, 2026-11-12 ~14:15-14:30 +07)

- State at RED time: main at 26cd38f (N2133 merged + pushed); working tree clean except untracked `*.gd.uid` files (never stage) and untracked gate logs.
- javalang 0.13.0 present (check before GREEN gate runs — a VM restart wipes it; reinstall first per the known rule). Godot 4.6.2 present (`~/workspace/godot-bin/godot` symlink; `godot` is NOT on the default PATH — targeted runs must `export PATH="$HOME/workspace/godot-bin:$PATH"`).
- Test module written: `tools/mindustry_godot_transpiler/tests/test_c06_battery_enabled_stamp.py` (4 tests). RED run: **Ran 4 tests in 0.365s, FAILED (failures=2, errors=2)** — all expected:
  - registration `KeyError: 'N2134'` (ledger entry not written yet);
  - evidence errors on the missing ledger entry (same KeyError);
  - source-text `AssertionError`: `source_building_power_battery_enabled_stamp_state` does not exist yet;
  - proof: `assertIsNotNone(godot)` — no Godot binary on PATH in the cron shell (the gate-expected Godot-absent shape; with Godot on PATH it would be returncode 1, scene file does not exist yet — the new proof scene is GREEN work).
- `git diff --check` clean (no tracked changes yet — only the new untracked test module).

## GREEN progress (14:30 cron run, 2026-11-12 ~14:30-14:45 +07)

- Register script written + run: `tools/mindustry_godot_transpiler/register_c06_battery_enabled_stamp.py` (modeled on the N2133 one: ledger N2134 entry + 4 new symbols, mixed java_source — input → BuildingComp.java, results → PowerGraph.java — + 1 contract + 2 schemas). **SSOT verified: 11264 / 1585 / 1506 / 2803** — symbols +4, slices +1, contracts +1, schemas +2, exactly as expected; audit stays 1335. Exact exprs re-verified 13/13 verbatim (the 13th is `float totalCapacity = 0f;`, in getBatteryCapacity/getTotalBatteryCapacity).
- Owner const added: `PORT_GAME_SOURCE_BUILDING_POWER_BATTERY_ENABLED_STAMP_STATE` in `SourceRuntimeOwnerBuildingRegistry.gd` (next to the block-battery const, line 37); resolves through the `SourceRuntimeOwnerRegistry` → `SourceRuntimeOwnerGameplayRegistry` → … → `SourceRuntimeOwnerTurretRegistry` → BuildingRegistry chain (verified by reading the chain).
- Implemented `SourceBuildingPowerState.source_building_power_battery_enabled_stamp_state(frame)` (after `block_battery_state`): duplicates each battery dict, overwrites `enabled` with the live `Building.enabled` via `block_properties(block)`, keeps the static value when the block carries none; returns `source_owner` + `batteries` + `enabled_count` + `disabled_count`.
- Wired `SourcePlacedPowerGraphState.runtime_state`: stamps the grouped batteries before `battery_state` reads them. Standalone `battery_state()` query helper NOT wired (per design).
- Proof scene written: `C06BatteryEnabledStampProof` (.tscn uid `uid://c6batteryestp` + .gd, modeled on `C06UnitAssemblerCheckTierProof`, prefix `C_06_BATTERY_ENABLED_STAMP_PROOF `; proof JSON is gitignored, never stage it). 6 keys, all true, `matches: true`.
- **Targeted tests GREEN 4/4 in 29.6s** (Godot on PATH). Two fixes during GREEN, both test/proof-side, not game code: (1) the RED test's expected `source_symbols` order listed `enabled_count` before `disabled_count` — the register script stores `sorted()` like N2133, so the test now expects alphabetical `batteries, disabled_count, enabled_count`; (2) the proof's `enabled_stamp_disabled_excluded_from_stored` key first reused the mixed frame, whose missing battery also counts as enabled (stored would be 1000, not 500) — it now stamps a dedicated `[enabled, disabled]` frame, so stored is exactly 500.0 as the handoff designed.
- Neighbours (battery/power-graph modules, Godot on PATH): **Ran 10, FAILED (failures=2)** — both failures are Godot proof tests failing on `ERROR: [MCP Runtime] Failed to start server on port 7777: 22`, because a parallel run was executing the same proof scenes at the same time (two `C06PowerShouldConsumeProof` Godot processes seen alive concurrently). The proof keys in the failing output are ALL true including `matches: true` — environmental port collision, not a slice regression (the known lesson: never run proof scenes concurrently / while a gate runs). The 8 non-proof neighbour tests passed. Do NOT re-run proof scenes while the full gate runs. (Independent verification by the second parallel worker: the same 7 neighbour modules re-run sequentially — **Ran 21, OK in 282.6s** — confirming the 2 failures were the port collision only.)
- **Full gate STARTED ~14:36 +07: launched via `setsid nohup python3 -m unittest discover -s tests` by the second parallel worker (PID 11188, own session SID 11188, PPID 11186 dead shell — detached, cwd tools/mindustry_godot_transpiler, log `full-suite-n2134-gate.log` growing, dots + F in the expected Godot-absent shape).** Expected: Ran ~5633, FAILED (failures=85, skipped=5), 0 errors — all 85 `assertIsNotNone(godot)` (84 inherited + the new N2134 proof test).
- **Full gate attempt 1 DIED ~14:38 +07** (same session-end signature as N2133 attempts 1/2/4): PID 11188 gone, no python/unittest process left, log frozen at 3419 bytes (last write 14:38:01 +07). Frozen log preserved as `full-suite-n2134-gate-attempt1.log`. Note: it died even though the worker reported it "detached" (PPID was a dead shell) — the cron worker's `setsid nohup` launch does NOT survive the worker's session ending.
- **Full gate attempt 2 STARTED ~14:39 +07** (main-thread restart after the 14:30 report; same launch method as N2133 attempts 3 and 5, which survived: backgrounded `&&` chain, subshell stays alive as the gate's parent): `setsid nohup python3 -m unittest discover -s tests`, PID 11455 (own session SID 11455, verified; log growing 1233 → 2258 bytes in 10 s, dots only so far), no Godot on PATH. javalang 0.13.0 verified present before restart. Expected done ~15:10-15:20 +07; expected **Ran ~5633, FAILED (failures=85, skipped=5), 0 errors** — all 85 `assertIsNotNone(godot)`. **Do NOT start another gate while PID 11455 is running; verify its result in the next run(s) before commit/push. Do NOT run proof scenes while it runs** (port-7777 bind ERROR fails proof tests).
- `git diff --check` clean. Slice files changed (uncommitted): register script + test module (new), `SourceBuildingPowerState.gd`, `SourcePlacedPowerGraphState.gd`, `SourceRuntimeOwnerBuildingRegistry.gd`, 6 SSOT JSON files, proof .gd + .tscn (new). Never stage `*.gd.uid`, `project.godot`, `arc-upstream/`, `mindustry-upstream/`, proof `.json`, gate logs, or the Windows queue doc.

## What this batch is

The battery live `enabled` stamp, the next item on the N2133 "Next" list (and the N2133 deferred line: "PowerGraph.getBatteryStored gates on battery.enabled (PowerGraph.java:118-126), but the battery has no tick frame in the port, so its live enabled flag cannot be read yet; the battery dict keeps its static enabled value"). `PowerGraph` reads the live `Building.enabled` on every battery pass — `if(battery.enabled){` in `getBatteryStored` / `getBatteryCapacity` / `getTotalBatteryCapacity` / `useBatteries` (PowerGraph.java:123, 135, 147, 163) and `if(battery.enabled && battery.block.consPower.capacity > 0f){` in `chargeBatteries` (PowerGraph.java:180). The flag itself is `BuildingComp`'s `transient boolean enabled = true;` (BuildingComp.java:77). The port's `SourcePowerGraphBatteryDistributionState` already reads `battery.enabled` from the frame dicts, and `SourceBuildingPowerState.block_battery_state(block)` stamps an `enabled` key — but derived statically as `has_power or outputs_power or consumes_power or power_buffered`, never from the live building — so a disabled battery building still counts as enabled in the graph.

## Exact upstream evidence (all 13 exprs verified verbatim in this VM)

- The flag (BuildingComp.java:77): `transient boolean enabled = true;`
- The guards (PowerGraph.java:123, 135, 147, 163): `if(battery.enabled){` — and (PowerGraph.java:180): `if(battery.enabled && battery.block.consPower.capacity > 0f){`
- The iteration (PowerGraph.java:120-122 and siblings): `var items = batteries.items;` / `for(int i = 0; i < batteries.size; i++){` / `var battery = items[i];`
- The accumulations: `totalAccumulator += battery.power.status * battery.block.consPower.capacity;` / `totalCapacity += (1f - battery.power.status) * battery.block.consPower.capacity;` / `totalCapacity += battery.block.consPower.capacity;` / `float totalAccumulator = 0f;`
- The mutations: `battery.power.status *= (1f-consumedPowerPercentage);` / `battery.power.status += (1f - battery.power.status) * chargedPercent;`

## Design (decided in RED, implement in GREEN)

- **New function, no new contracts beyond the function itself.** `SourceBuildingPowerState.source_building_power_battery_enabled_stamp_state(frame)` — the frame's `batteries` list is the battery dicts built by `block_battery_state` (each carries its live building under the existing `block` key plus the statically derived `enabled`). The stamp overwrites each dict's `enabled` with the live `Building.enabled` read through the existing `block_properties(block)` seam (`block_properties` returns a Dictionary block's own dict / `properties` sub-dict, or an Object block's `properties` dict — so a live building dict carrying an `enabled` key is read, and an Object node is read the same way). A battery whose block carries no live `enabled` keeps its statically derived value (Java defaults `enabled` to true, and the static derivation is the port's standing default for a battery block — the guard keeps existing proof frames unaffected, same pattern as N2133's `frame.has("modules")` guard). Returns `source_owner` (new const `PORT_GAME_SOURCE_BUILDING_POWER_BATTERY_ENABLED_STAMP_STATE` in `SourceRuntimeOwnerBuildingRegistry.gd`, next to `PORT_GAME_SOURCE_BUILDING_POWER_BLOCK_BATTERY_STATE` at line 36 — visible to `SourceBuildingPowerState` through the `SourceRuntimeOwnerRegistry` → `SourceRuntimeOwnerGameplayRegistry` chain; verify the chain resolves in GREEN), `batteries` (the stamped list), `enabled_count`, `disabled_count`.
- **Gate wiring (same pattern as N2133):** `SourcePlacedPowerGraphState.runtime_state` (the live tick path, last function in the file) stamps the grouped batteries before `battery_state` reads them — `var stamped := source_building_power_state.source_building_power_battery_enabled_stamp_state({"batteries": grouped.get("batteries", [])})` then pass `stamped.get("batteries", [])` to `battery_state`. The standalone `battery_state()` query helper is NOT wired (minimal scope; a frame without a live building keeps its static value anyway) — note it as a follow-up in the deferred list if a later slice needs it.
- **4 new symbols** (N2129 pattern — input + results, no bare function symbol):
  - `source_building_power_battery_enabled_stamp_state_input.frame` — java_expr `transient boolean enabled = true;`, java_source `core/src/mindustry/entities/comp/BuildingComp.java`
  - `source_building_power_battery_enabled_stamp_state_result.batteries` — java_expr `if(battery.enabled){`, java_source `core/src/mindustry/world/blocks/power/PowerGraph.java`
  - `source_building_power_battery_enabled_stamp_state_result.enabled_count` — java_expr `var battery = items[i];`, java_source PowerGraph.java
  - `source_building_power_battery_enabled_stamp_state_result.disabled_count` — java_expr `if(battery.enabled && battery.block.consPower.capacity > 0f){`, java_source PowerGraph.java
  - All `godot_owner` `SourceBuildingPowerState.source_building_power_battery_enabled_stamp_state`. Note the mixed java_source: the register script must pass the source per symbol (the N2133 script's `f()` takes a `source=` kwarg; the input symbol uses BuildingComp.java, the results use PowerGraph.java). The ledger entry's own `java_source` is PowerGraph.java, `java_class` `mindustry.world.blocks.power.PowerGraph`, `java_method` `PowerGraph.getBatteryStored()` (the first guard site, PowerGraph.java:118-126, cited by the N2133 deferred line; the other four guard sites are in the exact_exprs).
- Ledger N2134 entry: `status: done`, `java_source: core/src/mindustry/world/blocks/power/PowerGraph.java`, `java_class: mindustry.world.blocks.power.PowerGraph`, `java_method: PowerGraph.getBatteryStored()`, `godot_owner: SourceBuildingPowerState.source_building_power_battery_enabled_stamp_state`, `exact_exprs`: the 13 exprs above, `source_symbols`: the 4 new symbols, `tests`: the 4 test names of the new module, `runtime_proof: /root/C06BatteryEnabledStampProof`, `deferred_exprs`: disabled-belt efficiency half, unit-factory shouldConsume wiring to the power stamp, live production wiring, Units.canCreate live evaluation, lastTier/progress reset, module link/unlink call sites, C06–C12 open (plus the standalone `battery_state()` query helper not stamped — see gate wiring above).
- Register script `register_c06_battery_enabled_stamp.py` (GREEN, modeled on the N2133 one): writes the ledger N2134 entry + the 4 symbols; rebuilds the SSOT shards. Expected SSOT after GREEN: **11264 / 1585 / 1506 / 2803** — symbols +4 and slices +1 are certain; contracts/schemas deltas TBD at GREEN (N2129 precedent for a new function was +1 contract / +2 schema; verify from the rebuilt shards, do not assume). Audit stays 1335.
- Proof updates: NEW scene `C06BatteryEnabledStampProof` (.tscn + .gd, prefix `C_06_BATTERY_ENABLED_STAMP_PROOF `; proof JSON is gitignored, never stage it). 6 keys:
  - `enabled_stamp_enabled_true`: battery with block enabled=true → enabled true.
  - `enabled_stamp_disabled_false`: battery with block enabled=false → enabled false.
  - `enabled_stamp_missing_keeps_static`: battery block with no `enabled` key → keeps the statically derived enabled (true for a battery block).
  - `enabled_stamp_mixed_enabled_count`: mixed [true, false, missing] → enabled_count 2.
  - `enabled_stamp_mixed_disabled_count`: same frame → disabled_count 1.
  - `enabled_stamp_disabled_excluded_from_stored`: `SourcePowerGraphBatteryDistributionState.battery_state` over the stamped batteries counts stored only from the enabled one (enabled battery power_status 0.5 × capacity 1000 = 500; disabled battery status 1.0 × 1000 excluded).
  - Model the scene on `C06UnitAssemblerCheckTierProof.gd` (same Main.tscn boot, `enter_campaign_playable_slice`, call the function directly on frames — the stamp is pure, no block needed). Battery dicts in the proof are plain dicts with `block` = a dict carrying `enabled` (or no `enabled` key for the missing case), `power_status`, `capacity`.
- The `test_playable.py` battery assertions (`block_battery_state` exists, `_group_state` calls it) need NO change: `block_battery_state` itself is untouched; only the new stamp function and the `runtime_state` wiring are added. Check in GREEN whether any existing test module asserts on `runtime_state` output shape (the stamped `batteries` list keeps the same dicts, only `enabled` may change — and only when a block carries a live `enabled`, which no existing fixture does).

## Files changed (RED only)

- `tools/mindustry_godot_transpiler/tests/test_c06_battery_enabled_stamp.py` (new, 4 tests): registration (ledger N2134, 4 new symbols with mixed java_source, runtime proof, test names, deferred_exprs), exact-evidence (4 symbols + 13 exprs over PowerGraph.java + BuildingComp.java), source-text (stamp function exists; `runtime_state` in SourcePlacedPowerGraphState calls `source_building_power_battery_enabled_stamp_state`; proof has the 6 new keys), Godot proof (`C06BatteryEnabledStampProof.tscn`, prefix `C_06_BATTERY_ENABLED_STAMP_PROOF `, the 6 keys true).

## Verified numbers (do not re-derive, these are measured in this VM)

- RED run: **4 tests, 2 failures + 2 errors, all expected** — registration `KeyError: 'N2134'`, evidence errors on the missing ledger entry, source-text `AssertionError` (function not implemented), proof `assertIsNotNone(godot)` (no Godot on PATH in the cron shell).
- Exact-expr pre-check: **13/13 exprs found verbatim** in the 2 slice sources (PowerGraph.java, BuildingComp.java).
- `git diff --check` clean.
- State at RED time: main at 26cd38f (N2133 merged + pushed to the fork 2026-11-12 ~14:05); SSOT 11260 / 1584 / 1505 / 2801; audit 1335.

## GREEN work remaining (next run)

1. ✅ Write + run the register script — DONE 14:30 run: SSOT 11264 / 1585 / 1506 / 2803, audit 1335.
2. ✅ Owner const — DONE (line 37, resolves through the registry chain).
3. ✅ Implement `source_building_power_battery_enabled_stamp_state(frame)` — DONE.
4. ✅ Wire `SourcePlacedPowerGraphState.runtime_state` — DONE.
5. ✅ Write the new proof scene `C06BatteryEnabledStampProof` (6 keys) — DONE.
6. ✅ Targeted tests GREEN 4/4 (Godot on PATH) + neighbours (8/10 non-proof OK; 2 proof-test failures are the concurrent port-7777 collision, proof keys all true — environmental, not a regression).
7. Full Python gate (211 modules) — **attempt 1 DIED ~14:38 +07 (session-end, log frozen 3419 bytes, preserved as `full-suite-n2134-gate-attempt1.log`); attempt 2 (setsid, PID 11455, own session SID 11455, started ~14:39) FINISHED ~15:06 +07 (15:00 cron run): Ran 5633 in 1660.539s, FAILED (failures=85, skipped=5), 0 errors — all 85 verified individually as Godot-proof failures (84 plain `assertIsNotNone(godot)` + 1 hydration `assertIsNotNone(godot, 'Godot required for hydration proof')`, 0 non-Godot failure shapes, 0 errors); the N2134 module contributes only its proof test, its 3 non-proof tests pass. Gate clean except Godot.**
8. ✅ Godot proof GREEN (6 keys, all true, `matches: true`) — DONE 14:30 run (headless in this VM; run standalone, NOT while the gate runs).
9. ✅ Report + design-spec N2134 row + Status Summary 1584→1585 + changelog row + this handoff — DONE 15:00 cron run. Committed + pushed to the fork (origin main) in the same run (see Commit section below).

## Next (after N2134 lands)

- Disabled-belt efficiency half, unit-factory shouldConsume wiring to the power stamp, live production wiring (progress + call at completion). Then C07–C12 per the completion backlog.

## Deferred (not this slice)

- The standalone `SourcePlacedPowerGraphState.battery_state()` query helper is not stamped — only the live tick path (`runtime_state`) stamps. A query frame without a live building keeps its static `enabled` either way.
- `lastTier` tracking + progress reset on tier change (UnitAssembler.java:441-447) — belongs to the live production/tick wiring, not the battery stamp.
- The live-loop module link/unlink call sites: `updateModules`/`removeModule` are called from `UnitAssemblerModuleBuild` link/unlink (UnitAssemblerModule.java:80-83) — the port has no live module-linking frame event yet.
- Live production wiring: progress advance + the call at completion (UnitFactory.java:401-403, Reconstructor.java:330-348, UnitAssembler.spawned()), plus the intake call site (`moveInPayload() && !wasOccupied`, UnitAssembler.java:500-503).
- Unit-factory frames' per-class shouldConsume wiring to the power stamp; disabled-belt efficiency half (BuildingComp.java:1943-1948 — a disabled conveyor reads efficiency 0 in Java, the port carries no per-belt efficiency yet).
- `Units.canCreate` live evaluation (needs C07: live per-type unit counts + the unit cap); the assembler branch keeps reading `frame["can_create"]`, default true, until then.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

## Commit

Not yet — GREEN done (targeted 4/4, Godot proof 6 keys GREEN, SSOT 11264 / 1585 / 1506 / 2803); full gate verified clean except Godot (attempt 2 finished ~15:06 +07: Ran 5633, failures=85, skipped=5, 0 errors, all Godot-proof). Commit + push to origin main in the 15:00 cron run.
