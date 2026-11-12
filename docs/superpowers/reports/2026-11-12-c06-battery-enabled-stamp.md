# Report — N2134: battery live `enabled` stamp

Date: 2026-11-12. Batch: N2134 (single slice). Status: GREEN done in this VM, targeted tests **4/4 OK**. **Godot proof GREEN 2026-11-12 ~14:30 +07: Godot 4.6.2-stable Linux (build 71f334935, identical to the Windows 4.6.2 build) ran `C06BatteryEnabledStampProof.tscn` headless in this VM — 6 keys, all true, `matches: true`. Inclusive full gate finished ~15:06 +07 (Ran 5633 in 1660.539s, failures=85, skipped=5, 0 errors — all 85 Godot-proof failures, no Godot binary on PATH). Committed + pushed to origin main (fork Lasthope1508) in the 15:00 cron run.**

## What changed

`PowerGraph` reads the live `Building.enabled` on every battery pass — `if(battery.enabled){` in `getBatteryStored` / `getBatteryCapacity` / `getTotalBatteryCapacity` / `useBatteries` (PowerGraph.java:123, 135, 147, 163) and `if(battery.enabled && battery.block.consPower.capacity > 0f){` in `chargeBatteries` (PowerGraph.java:180). The flag itself is `BuildingComp`'s `transient boolean enabled = true;` (BuildingComp.java:77). The port's `SourcePowerGraphBatteryDistributionState` already reads `battery.enabled` from the frame dicts, and `SourceBuildingPowerState.block_battery_state(block)` stamps an `enabled` key — but derived statically as `has_power or outputs_power or consumes_power or power_buffered`, never from the live building — so a disabled battery building still counted as enabled in the graph.

N2134 adds `SourceBuildingPowerState.source_building_power_battery_enabled_stamp_state(frame)`: it duplicates each battery dict, overwrites `enabled` with the live `Building.enabled` read through the existing `block_properties(block)` seam, keeps the static value when the block carries no live `enabled` (Java defaults `enabled` to true), and returns `batteries` + `enabled_count` + `disabled_count` under the new owner const `PORT_GAME_SOURCE_BUILDING_POWER_BATTERY_ENABLED_STAMP_STATE`. `SourcePlacedPowerGraphState.runtime_state` (the live tick path) stamps the grouped batteries before `battery_state` reads them. The standalone `battery_state()` query helper is NOT wired — a frame without a live building keeps its static value anyway (noted as a follow-up in the deferred list).

## Proof keys (new scene, 6 keys)

- `enabled_stamp_enabled_true`: battery with block enabled=true → enabled true.
- `enabled_stamp_disabled_false`: battery with block enabled=false → enabled false.
- `enabled_stamp_missing_keeps_static`: battery block with no `enabled` key → keeps the statically derived enabled (true for a battery block).
- `enabled_stamp_mixed_enabled_count`: mixed [true, false, missing] → enabled_count 2.
- `enabled_stamp_mixed_disabled_count`: same frame → disabled_count 1.
- `enabled_stamp_disabled_excluded_from_stored`: `SourcePowerGraphBatteryDistributionState.battery_state` over the stamped batteries counts stored only from the enabled one (enabled battery power_status 0.5 × capacity 1000 = 500; disabled battery status 1.0 × 1000 excluded).

## Verified numbers (measured in this VM)

- Test module `test_c06_battery_enabled_stamp.py`: **4/4 OK in 29.6s** (Godot on PATH) — registration (ledger N2134, 4 new symbols with mixed java_source, runtime proof, test names, deferred_exprs), exact-evidence (4 symbols + 13 exprs over PowerGraph.java + BuildingComp.java, all found verbatim), source-text (stamp function exists; `runtime_state` in SourcePlacedPowerGraphState calls `source_building_power_battery_enabled_stamp_state`; proof has the 6 new keys), and the Godot proof test (6 keys, all true, `matches: true`).
- RED run (14:15 cron run): 4 tests, 2 failures + 2 errors, all expected — registration `KeyError: 'N2134'`, evidence errors on the missing ledger entry, source-text `AssertionError` (function not implemented), proof `assertIsNotNone(godot)` (no Godot on PATH in the cron shell).
- Two fixes during GREEN, both test/proof-side, not game code: (1) the RED test's expected `source_symbols` order listed `enabled_count` before `disabled_count` — the register script stores `sorted()` like N2133, so the test now expects alphabetical `batteries, disabled_count, enabled_count`; (2) the proof's `enabled_stamp_disabled_excluded_from_stored` key first reused the mixed frame, whose missing battery also counts as enabled (stored would be 1000, not 500) — it now stamps a dedicated `[enabled, disabled]` frame, so stored is exactly 500.0 as designed.
- Neighbours (battery/power-graph modules, Godot on PATH): Ran 10, FAILED (failures=2) — both failures are Godot proof tests failing on `ERROR: [MCP Runtime] Failed to start server on port 7777: 22`, because a parallel run was executing the same proof scenes at the same time (two `C06PowerShouldConsumeProof` Godot processes seen alive concurrently). The proof keys in the failing output are ALL true including `matches: true` — environmental port collision, not a slice regression (the known lesson: never run proof scenes concurrently / while a gate runs). The 8 non-proof neighbour tests passed. Independent verification by the second parallel worker: the same 7 neighbour modules re-run sequentially — Ran 21, OK in 282.6s — confirming the 2 failures were the port collision only.
- `git diff --check` clean.
- SSOT +4/+1/+1/+2 → **11264 / 1585 / 1506 / 2803**; audit stays 1335.

## Gate / suite

- Test modules standalone: N2134 4/4 (proof green, see above).
- Godot proof: **GREEN 2026-11-12 ~14:30 +07** — 6 keys all true, `matches: true`, on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- Full Python suite, inclusive gate with the N2134 module (log `tools/mindustry_godot_transpiler/full-suite-n2134-gate.log`, 211 modules): attempt 1 died ~14:38 +07 when its spawning cron session ended (log frozen at 3419 bytes, no summary; preserved as `full-suite-n2134-gate-attempt1.log`); attempt 2 started detached with `setsid` ~14:39 +07 (PID 11455, own session SID 11455) and **finished ~15:06 +07: Ran 5633 in 1660.539s, FAILED (failures=85, skipped=5), 0 errors** — all 85 verified individually as Godot-proof failures (84 plain `assertIsNotNone(godot)` + 1 hydration `assertIsNotNone(godot, 'Godot required for hydration proof')`, 0 other failure shapes, 0 errors); the N2134 module contributes only its proof test, its 3 non-proof tests pass. Zero errors, zero non-Godot failures: the gate is clean except Godot.
- The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule).

## Deferred

- The standalone `SourcePlacedPowerGraphState.battery_state()` query helper is not stamped — only the live tick path (`runtime_state`) stamps. A query frame without a live building keeps its static `enabled` either way.
- `lastTier` tracking + progress reset on tier change (UnitAssembler.java:441-447) — belongs to the live production/tick wiring, not the battery stamp.
- The live-loop module link/unlink call sites (`updateModules`/`removeModule` from `UnitAssemblerModuleBuild` link/unlink, UnitAssemblerModule.java:80-83) — the port has no live module-linking frame event yet.
- Live production wiring: progress advance + the call at completion (UnitFactory.java:401-403, Reconstructor.java:330-348, UnitAssembler.spawned()), plus the intake call site (`moveInPayload() && !wasOccupied`, UnitAssembler.java:500-503).
- Unit-factory frames' per-class shouldConsume wiring to the power stamp; disabled-belt efficiency half (BuildingComp.java:1943-1948 — a disabled conveyor reads efficiency 0 in Java, the port carries no per-belt efficiency yet).
- `Units.canCreate` live evaluation (needs C07: live per-type unit counts + the unit cap); the assembler branch keeps reading `frame["can_create"]`, default true, until then.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

See `handoffs/2026-11-12-c06-battery-enabled-stamp-handoff.md` for the full detail.
