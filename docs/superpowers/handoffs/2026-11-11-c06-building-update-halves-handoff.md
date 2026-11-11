# Handoff — N2126: BuildingComp.update() live-loop halves (per-building timeScale in the belt advance + the disabled-building updateTile gate in the conduit tick)

Date: 2026-11-11. Batch: N2126 (single slice). Status: built, registered, proof 21/21 verified, test module 4/4 standalone. **Targeted gate re-run 5601 OK** (1931.790s); **full Python suite 5601 OK** (1915.753s).

## What this batch is

`BuildingComp.update()` (BuildingComp.java:2262-2277) does two things per tick before `updateTile()`: it decays `timeScaleDuration` and resets `timeScale` to 1f on expiry, and it runs `updateTile()` only when `enabled || !block.noUpdateDisabled`. The decay already ran live (`simulate_block_time_scales` decays every placed sprite each tick), but neither half was wired into the tick drivers that consume the values — so this slice wires each half where it bites:

- **Belt timeScale (the expiry half):** the belt advance moved items by `speed * delta` with a hardcoded time scale of 1.0, while `ConveyorBuild.updateTile` moves them by `speed * edelta()` (Conveyor.java:266) and `edelta()` carries the building's own timeScale (BuildingComp.java:1922-1929). A boosted belt never moved faster and the expiry was unobservable in the belt path. The wrapper now reads each belt sprite's live timeScale and the advance scales `moved` by it.
- **Conduit gate (the updateTile half):** the conduit tick ran `updateTile` unconditionally, while the conduit sets `noUpdateDisabled = true` (Conduit.java:53), so a disabled conduit kept moving liquid. The tick now reads the conduit frame's `enabled` flag (the factory/turret frame pattern) and applies the gate via the existing `update_tile_gate_state` pure function: a disabled conduit returns `update_tile_called: false` with its liquid, smoothLiquid and flow timer untouched. A disabled GenericCrafter still runs `updateTile` — `noUpdateDisabled` defaults false (Block.java:170), so the gate is vacuous there and only its zero efficiency stops it (the N2123 register note).

2 symbols, 0 new contracts, 0 new schemas, SSOT +2/+1/+0/+0 → 11232 / 1577 / 1500 / 2791; audit 1335.

## Files changed

- `godot-mindustry/src/game/SourceConveyorRuntimeState.gd` (+10): `source_conveyor_advance_state` now computes `moved := speed * delta * time_scale` (was `speed * delta`), with a comment citing Conveyor.java:266 + BuildingComp.java:1922-1929 and noting efficiency is 1 here (a consumerless block reads efficiency 1 when enabled, BuildingComp.java:1943-1948; the disabled-belt efficiency-0 half is deferred — see below).
- `godot-mindustry/src/game/SourceFactoryRuntimeState.gd` (+14): `source_factory_advance_conveyors_state` reads each belt sprite's live timeScale into a `time_scales` dict (`source_placed_block_state.time_scale(sprite, game_default_time_scale(game))`) and passes `cell_time_scale` to the advance instead of the hardcoded `1.0`. The decay itself already runs in `simulate_block_time_scales` before `simulate_factory` in the game loop, so no new decay wiring was needed.
- `godot-mindustry/src/game/SourceConduitRuntimeState.gd` (+27): new `CONDUIT_NO_UPDATE_DISABLED := true` (Conduit.java:53) + `source_building_lifecycle_state` preload; `source_conduit_update_state` preserves `frame["enabled"]` (default true), applies `update_tile_gate_state(enabled, CONDUIT_NO_UPDATE_DISABLED)`, and on a gated-off tick writes the frame back and returns `{liquid, flowed: 0.0, smooth_liquid, flow_timer, update_tile_called: false, enabled}` with the pre-update values; the normal return gains `update_tile_called: true, enabled`. The no-sprite / no-liquids early returns are unchanged (no frame to gate on).
- `tools/mindustry_godot_transpiler/tests/test_c06_building_update_halves.py` (new, 4 tests) + `tools/mindustry_godot_transpiler/register_c06_building_update_halves.py` (new, mirrors `register_c06_power_should_consume.py`).
- `tools/mindustry_godot_transpiler/tests/test_conduit_update_binding.py` (1 line): the N2092 expected return keys gain `update_tile_called, enabled` — the contract extension changed them, so the old 4-key pin had to move with it.
- `godot-mindustry/src/generated/` (SSOT JSONs + `comp_*` / `conveyor_*` shards): N2126 row, 2 symbols; the N2092 conduit contract (return keys + rule + tests, source_slice kept), the N2069 advance contract and N2070 wrapper contract (rule + tests, source_slice kept), and the N2069 `time_scale` input symbol (rule + tests) extended in place.
- `godot-mindustry/tools/runtime_proofs/C06BuildingUpdateProof.gd` + `.tscn` (new, uid `uid://c6buildupd12`). Proof JSON is gitignored, never stage it.
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`: totals 1576 → 1577, N2126 checklist row, Current-cube sentence, Not Done C06 leg, migration-log row.
- `docs/superpowers/reports/2026-11-11-c06-building-update-halves.md` (this batch's report; gate re-run 5601 OK, full suite 5601 OK).

## Verified numbers (do not re-derive, these are measured)

- Proof `C06BuildingUpdateProof`: **21/21 keys true** (counted from `godot-mindustry/tools/runtime_proofs/C06BuildingUpdateProof.json`, `matches: true`, 0 false). Live numbers: belt at timeScale 2.0 advances 0.06/tick (xs 0.2 → 0.08); one decay tick with 1.0 duration left resets timeScale to 1.0 and the next advance is 0.03/tick (ys 0.06 → 0.09); disabled conduit flows 0.0 with flow timer and smoothLiquid frozen at their pre-call values, re-enabling swaps the water forward (flowed = first − second); over 120 live ticks a disabled conduit accumulates pump water while its downstream drains, and re-enabled it drains again. Pure checks: gate truth table (disabled conduit false; enabled conduit true; disabled crafter true — vacuous), decay expiry 2.0/1.0 → 1.0/0.0, decay keeps 2.0/599.0, applyBoost 1.0 → 2.0/600.0.
- Test modules standalone: **new module 4/4 OK in 26.636s**; **conveyor advance binding 3/3 + conduit update binding 3/3 OK** (10 tests total in 52.075s, run together after the fix below).
- First proof run was 20/21: `conduit_disabled_no_flow` was false because the test pinned smoothLiquid/flowTimer to 0.0, but the setup frames had already run the conduit tick, so the frame carried nonzero values — fixed in the proof (assert the gated call leaves them unchanged), not in the implementation. First module run was 3/4: the live-loop test pinned `frame["enabled"] = bool(frame.get("enabled", true))` as one line, but the implementation splits it across two lines (the factory-frame pattern) — fixed in the test.
- All 77 shards equal a fresh `build_extension_shard` (verified after the register run). `git diff --check` clean (run at the end; see report).
- Suite size: 5597 + 4 new tests = **5601** expected (204 modules).

## Deferred (not this slice)

- A disabled conveyor reads efficiency 0 in Java (BuildingComp.java:1943-1948, consumerless branch: efficiency is 1 only when enabled and productionValid); the port carries no per-belt efficiency yet, so a disabled belt still advances — the updateConsumption disabled branch needs a per-belt efficiency first. Found while verifying the `moved` comment, not guessed.
- The battery's live `enabled` stamp (`PowerGraph.getBatteryStored` gates on `battery.enabled`, but the battery has no tick frame).
- The shouldConsumePower half that clears when a non-power consumer fails (BuildingComp.java:1971-1974, first pass).
- `ConsumeItemDynamic.trigger` at unit completion (ConsumeItemDynamic.java:53-56).
- UnitAssembler plan dynamics (UnitAssembler.java:158-160).
- Source-exhaustion/output-full acts.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

## Next: N2127 (candidates)

The remaining C06 work, in the order the N2125/N2126 builders considered them: source-exhaustion/output-full acts, `ConsumeItemDynamic.trigger` at unit completion, UnitAssembler plan dynamics, the battery live `enabled` stamp, the disabled-belt efficiency half (needs a per-belt efficiency first).
