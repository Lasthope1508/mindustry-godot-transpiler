# Report — N2147: drill power.status live read (laser-drill + blast-drill, base Drill family) (C07)

Date: 2026-11-13. Batch: N2147 (single slice). Status: **DONE + PUSHED 2026-11-13 ~09:0x +07 (09:00 cron run). Targeted tests 4/4 OK, neighbours 14/14 OK, Godot proof GREEN, full gate verified clean except Godot (Ran 5685, failures=98, skipped=5, 0 errors — all 98 Godot-absent asserts). Commit + push to origin main (fork Lasthope1508) this run — see handoff for the commit hashes.**

## What changed

The third of the remaining `power.status` consumer families named in the N2142/N2144/N2145 handoffs. N2142's live loop stamps `frame["power_status"]` each tick before the drill tick runs, and the write-back is generic, so drill frames already receive the live status. But the drill tick driver never read it: `SourceDrillConsumptionRuntimeState.source_tick_state` skipped any block with `block.properties.has("consumePower")` (line 102), so laser-drill and blast-drill never ticked at all — they ran as if `power.status` were 1.0 and their drill speed never folded power. N2147 is the drill family's live read — the same proven N2145/N2146 pure-row pattern, one file over.

Composition, not re-implementation: the shared efficiency machinery (`SourceBuildingEfficiencyState.update_consumption_state`, via `update_consumption_non_optional_pass_state`) already folds `{"result": ..., "is_power": true}` rows into the min efficiency — the power consumer's `ConsumePower.efficiency` is `build.power.status` (ConsumePower.java:39). N2147 does not touch it. N2147 supplies the missing pure power row + lifts the driver exclusion + appends the row.

Pure `SourceDrillConsumptionRuntimeState.source_drill_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary` — `has_power_consumer` false → `{"has_power_row": false, "row": {}}`; true → `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live = 1.0 if `frame.get("power_status", null)` is null else `float(frame.get("power_status"))`. The null→1.0 fold is the assembler convention (UnitAssembler.java:469, before the first graph update). Header comment quotes `return build.power.status;` (ConsumePower.java:39), the null-fold line, `hasConsumers = consumers.length > 0;` (Block.java:1449), and the drill speed fold `float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;` (Drill.java:301).

Driver wiring in `source_tick_state`: the `or block.properties.has("consumePower")` exclusion is lifted, so power drills tick; after the rows loop, gated on `has_power_consumer and enabled and not cheating`, the pure row is appended to `required_results`. No `has_consumers` fix: both power drills have liquid rows, so `groups["has_consumers"]` is already true (Block.java:1449).

Scope decision (decided in RED): **base Drill family only — laser-drill (consumePower 1.10f, water booster 0.08f) and blast-drill (consumePower 3f, water booster 0.1f)**. mechanical-drill / pneumatic-drill have no power (already ticked). eruption-drill / impact-drill are BurstDrill (own driver, out of scope). water-extractor is SolidPump (out of scope). No progress keys in the proof — the drill speed fold (Drill.java:301) is what the efficiency keys prove.

## Proof keys (new scene, 6 keys)

New scene `C07DrillPowerStatusProof` (modeled on the N2146 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_DRILL_POWER_STATUS_PROOF `:

- `laser_has_power_consumer`: catalog `laser-drill` properties has `consumePower` (grounds the driver gate).
- `power_row_half`: pure row over frame `{"power_status": 0.5}`, has_power_consumer true → row result 0.5, `is_power` true.
- `power_row_absent_without_consumer`: has_power_consumer false → `has_power_row` false.
- `power_row_null_folds_one`: frame without `power_status` → row result 1.0.
- `efficiency_folds_power_min`: live tick — place laser-drill with a dominant item (ore) so `should_consume` is true, stamp `frame["power_status"] = 0.5`, tick → frame efficiency 0.5.
- `efficiency_zero_at_no_power`: same, `power_status` 0.0 → efficiency 0.0.

## Verified numbers (measured in this VM)

- Test module `test_c07_drill_power_status.py`: **4/4 OK in 26.299s** (Godot on PATH) — registration (ledger N2147, 2 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (2 new symbols + 8 exprs over ConsumePower.java + BuildingComp.java + Drill.java + Blocks.java + PowerModule.java + UnitAssembler.java + Block.java, all found verbatim), source-text (pure function exists + the quoted Java lines in its comment + driver no longer skips `consumePower` blocks + appends an `"is_power": true` row; proof has the 6 new keys), and the Godot proof test (6 new keys, all true, `matches: true`).
- RED run (08:15 cron run, ~08:07 +07): 4 tests in 1.053s, FAILED (failures=2, errors=2), all expected — registration `KeyError: 'N2147'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure function did not exist yet), proof returncode 1 (proof scene did not exist yet).
- Neighbours (Godot on PATH, sequential): **14/14 OK in 93.469s** — `test_drill_live_consumption` 3/3 + `test_drill_booster_binding` 3/3 + N2142 `test_c07_power_status_live` 4/4 + N2146 `test_c07_adjacent_factory_power_status` 4/4. Correction: the RED handoff said 16 — the two drill modules have 3 tests each, not 4.
- Godot proof: **GREEN 2026-11-13 ~08:25 +07** (08:15 cron run) — proof JSON 9 keys, all true, `matches: true` (6 semantic keys + `registry_valid` + `one_headquarter_per_ssot` + `matches`), on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Port 7777 was free; no proof scene ran while a gate ran. Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- `git diff --check` clean.
- SSOT +2/+1/+1/+2 → **11304 / 1598 / 1519 / 2829**; audit stays 1335.

## Gate / suite

- Test modules standalone: N2147 4/4 (proof green, see above); neighbours 14/14.
- Full Python suite, inclusive gate with the N2147 module (log `tools/mindustry_godot_transpiler/full-suite-n2147-gate.log`, 211 modules): **FINISHED ~09:02 +07, VERIFIED clean except Godot in this run — Ran 5685 tests in 1722.648s, FAILED (failures=98, skipped=5), 0 errors. All 98 failures verified Godot-absent: 98 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None`, 0 `ERROR:` blocks; the N2147 module shows no failure other than its Godot-proof test (`test_reference_graph_and_actual_c07_drill_power_status`).** Gate attempt 1 (worker-launched, setsid, PID 3427, ~08:30) died ~08:32 at session end (log stopped at 3,473 bytes, no footer — the known worker-launch pattern). Gate attempt 2 (main-thread launch, PID 4021, ~08:33) finished on the first attempt. The gate took 1722s vs N2146's 901s — roughly 2× slower; likely VM contention (another agent is using Godot on this VM, per the user at 08:05). The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule). Note: the log's progress output is block-buffered — it sat at ~5,379 bytes for the last ~15 minutes, then flushed to 67,758 bytes with the footer in the final minute; the process was CPU-busy (99%) throughout, not stuck.

## Deferred

- `power.status` live read for turret (four implementations, each its own wiring slice) — the last remaining consumer family from the N2142/N2144/N2145 list. Next candidate: N2148 scopes it.
- BurstDrill power (eruption-drill / impact-drill) and SolidPump power (water-extractor) — own drivers, own slices.
- Drill progress advance (Drill.java speed fold is proven; the tick driver's progress accounting is its own slice).
- `spawn_occupied` / `spawn_visual_occupied` frame inputs — need tile solidity + nearby-units query; waits for a collision/tile-solidity frame-data slice.
- `allow_update` frame input — waits for a rules-state capture slice (env + map limits).
- Per-unit `AssemblerAI.inPosition()` evaluation from live unit pos/rotation — units list carries no pos/rotation yet.
- Net `readUnits` / `whenSyncedUnits` drone sync — presentation/net, not state.
- `moveOutPayload()` modeling — the assembler production tick still has no payload move-out.
- C07–C12 remain open.

See `handoffs/2026-11-13-c07-drill-power-status-handoff.md` for the full detail.
