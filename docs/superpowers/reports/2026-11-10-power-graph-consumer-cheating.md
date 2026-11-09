# C05 Power-graph consumer live cheating value — N2107

Date: 2026-11-10. Batch: N2107 (single slice, SSOT slice). SSOT +6/+1/+1/+2 → 10871 / 1558 / 1447 / 2685; audit `totalSourceFunctions` stays 1335.

## What changed

N2099 wired the drill tick to refresh its frame's `cheating` flag from the live rules (`TeamComp.cheating()`: `team.rules().cheat`) and N2106 did the same for the ContinuousLiquidTurret tick, but the power graph never saw that value: its consumer dicts are rebuilt from the catalog every frame (`SourcePlacedPowerGraphState._group_state`) and carry no `cheating` key, so `PowerGraph.update()`'s cheat gate (PowerGraph.java:217-224) could never fire live even for a cheating drill — and `SourcePowerGraphState.update_state` computed the cheat state without honouring it. N2107 closes that gap.

- `SourcePlacedPowerGraphState.source_consumer_cheating_for_cell_state(game, cell)` — reads a placed building's live TeamRule cheat flag from its team and the game rules: the sprite's `team_id` meta (derelict 0 when missing) through `source_game_rules_state` + `source_team_cheating_state` (the same live-rules read the drill/CLT ticks use, N2098/N2099). Returns `{"cheating", "team_id", "found", "reason"}`; a cell with no sprite returns `cheating=false, found=false, reason="no_sprite"`.
- `SourcePlacedPowerGraphState._group_state` — stamps `origin_cell` on each grouped consumer dict, mirroring batteries, so the live-loop step can find the building's sprite.
- `SourceFactoryRuntimeState.source_factory_update_power_graph_state(game, delta)` — after loading each battery's stored `power_status` (the N2082–N2083 pattern), stamps each consumer dict with its building's live cheating value from the helper. A consumer without a Vector2i origin keeps the false default.
- `SourcePowerGraphState.update_state(consumers, producers, batteries, energy_delta, source_delta, power_balance_samples)` — now takes the cheat branch when `cheat_state.returned` is true: sets every real consumer dict's `power_status` to 1.0 (the cheat state itself is computed on duplicated consumers) and returns the same shape with `power_needed`/`power_produced`/`last_power_needed`/`last_power_produced` all 1.0, `last_power_stored` from the batteries' stored power, and empty `balance_state`/`battery_distribute_state` — Java returns before computing those. The non-cheat path is unchanged.

## Verification

- New test `tools/mindustry_godot_transpiler/tests/test_power_graph_consumer_cheating.py` (4 tests): SSOT registration + exact-evidence checks for the 6 N2107 symbols, a source-text check for the helper, the `origin_cell` stamp, the live-loop stamping and the cheat branch, plus a proof run of `PowerGraphLiveUpdateProof`. Ran 4 tests OK in 12.711s.
- Godot proof `PowerGraphLiveUpdateProof` **13/13 true** on the real Main scene (extended with 7 checks): the helper returns `cheating=false, found=false` for an empty cell; the drill's team is known; cheating the drill's team makes the helper return `cheating=true` for the drill cell and the first consumer (the drill, placed first) carries `cheating=true`; the gate fires (`power_needed`/`power_produced`/`last_power_needed`/`last_power_produced` all 1.0, `cheat_state.returned` true) with every consumer's `power_status` 1.0; uncheating restores 6.0/60 needed and 0.12/60 produced with the gate closed.
- Targeted gate (log `~/workspace/logs/targeted-n2107c.log`): **5520 tests OK in 1524.583s, exit=0** (0 FAIL sections; exactly one summary line). The first gate run (`targeted-n2107.log`) failed on 1 stale pin — `test_playable.py:17111` pinned the old one-line consumer append; N2107 binds the consumer state to a local var first (to stamp `origin_cell`), so the pin now asserts the three new lines (test-only fix, no runtime change). The first rerun (`targeted-n2107b.log`) died at 5421 dots in the VM restart; the clean rerun is `targeted-n2107c.log`, 5520 tests OK.
- Full Python suite (log `~/workspace/logs/full-suite-n2107.log`): **5520 tests OK in 1510.748s, exit=0** (0 FAIL sections; exactly one summary line).

## SSOT delta

SSOT +6/+1/+1/+2 → 10871 symbols / 1558 slices / 1447 contracts / 2685 schemas; audit `totalSourceFunctions` stays 1335. N2107 registers 6 symbols (2 helper inputs, 4 helper outputs), 1 new contract (`source_consumer_cheating_for_cell_state`) and extends the N2077 live-loop driver contract in place (keeps its N2077 `source_slice`; params still `['game', 'delta']`, return keys unchanged; rule now mentions the cheating stamp). Owner mirrors into the `power_*` shards: the slice row lands in `power_slices.json` (java_source under `/world/blocks/power/`) and the extended driver contract mirrors into `power_api_contracts.json` (the shard mirrors one owner per slice — the primary driver — so the helper contract lives in the canonical `source_api_contracts.json` only).

## Still open

- C05 next: wiring the turret and factory families' own ticks to the live cheating value — their ticks do not exist in the live loop yet, so only the power-graph consumer path reads the value live here. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
