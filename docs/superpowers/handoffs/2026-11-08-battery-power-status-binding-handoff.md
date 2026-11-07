# Handoff — Battery power-status persistence binding (N2082–N2083)

Date: 2026-11-08. Parent: `a1fc6e2`. Sequential C01–C12 goal, C03 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-08-battery-power-status-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What these slices did

Made a battery's power_status persist across frames, so a charged battery can discharge on a later frame — the C03 gate's battery discharge path, proven live.

- **N2082 `SourcePlacedPowerGraphState.source_battery_power_status_for_cell_state(game, cell) -> Dictionary`** — reads a battery's stored power_status from its sprite's meta (key `source_battery_power_status`), returning `{status, found, reason}` (status 0.0 when the sprite has none).
- **N2083 `SourcePlacedPowerGraphState.source_battery_set_power_status_for_cell_state(game, cell, status) -> Dictionary`** — writes the status to the sprite's meta, returning `{stored, reason}`. The live-loop step `source_factory_update_power_graph_state` now loads the stored status into each battery dict before the update and writes the result back after; `_group_state` adds the origin cell to each battery dict so the step can resolve the sprite.

SSOT delta: **10 symbols / 4 schemas / 2 contracts / 2 slices**. Totals now: **10760 symbols / 1538 slices / 1426 contracts / 2643 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — the audit's discovery only scans PortGame/PortBridge facade functions, so State `source_` functions are not counted there (validated by the catalog validator instead). The power module shards mirror the new owners (`power_api_contracts.json`, `power_slices.json`), as they did for N2077/N2081.

## Why it exists

`block_battery_state` rebuilt the battery's power_status as 0.0 every frame from the block's static properties, so the charge never persisted and the discharge path could never trigger live. In Java, `battery.power.status` is a field on the Building that persists (PowerGraph.java:124, :164, :181). The port now stores it on the battery sprite's meta — the per-building persistent state, as the conveyor queue is stored on the conveyor sprite.

## What the Godot proof shows

`BatteryPowerStatusProof` — 5/5 checks true on the real Main scene: the battery starts with no stored status (0.0); the write stores 0.5 and the read returns it; with the battery pre-charged to 0.5, the deficit step discharges it (`power_battery_used` 0.098, the full deficit) and the stored status drops; a second step reads the persisted status and discharges it further.

## Verification

- Full Python suite: **5462 tests OK in 1272.006s** (log `~/workspace/logs/full-suite-n2082.log`). Editor parse, deterministic replay and native MCP proof are still open for these slices.

## Files changed

- `godot-mindustry/src/game/SourcePlacedPowerGraphState.gd` (N2082, N2083, the origin cell on battery dicts)
- `godot-mindustry/src/game/SourceFactoryRuntimeState.gd` (the step loads/writes the stored battery status)
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/src/generated/source_modules/power_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/power_slices.json`
- `godot-mindustry/tools/runtime_proofs/BatteryPowerStatusProof.gd`
- `godot-mindustry/tools/runtime_proofs/BatteryPowerStatusProof.tscn`
- `tools/mindustry_godot_transpiler/register_battery_power_status_binding.py`
- `tools/mindustry_godot_transpiler/register_battery_power_status_write_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_battery_power_status_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_playable.py` (the battery append pin in `_group_state`)
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1536 → 1538, N2082/N2083 checklist/table/log rows)
- `docs/superpowers/reports/2026-11-08-battery-power-status-binding.md` (this report)
- `docs/superpowers/handoffs/2026-11-08-battery-power-status-binding-handoff.md` (this handoff)

## Open items

- The full-power case (coverage 1.0 with produced >= needed); connection removal/split and building disabled/full-output cases. C04–C12 remain open. Editor parse, deterministic replay and native MCP proof are still open for these slices.
