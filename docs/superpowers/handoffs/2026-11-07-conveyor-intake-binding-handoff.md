# Handoff — ConveyorBuild intake binding (N2050–N2052)

Date: 2026-11-07. Parent: `078ae76`. Sequential C01–C12 goal, C02 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-conveyor-intake-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Bound the conveyor side of the dump composition — the intake a drill dumps into:

- **N2050 `SourceConveyorRuntimeState.source_conveyor_accept_item_state(len, capacity, facing_direction, rotation, minitem, item_space, source_block_rotate, next_is_source) -> Dictionary`** — acceptItem: capacity guard, facing null guard (facing_direction −1), `direction = |facing_direction − rotation|`, arms `(direction == 0 && minitem >= itemSpace) || (direction % 2 == 1 && minitem > 0.7)`, and the rotating-source-feeding-its-own-next refusal. Result keys: `accepted, direction, reason` (accepted, at_capacity, no_facing, wrong_direction, rotate_loop). The facing direction is computed by the caller with the existing `tile_relative_cardinal_state` (byte-identical to Java `Tile.relativeTo`); the multiblock facing-edge clamp is a later slice.
- **N2051 `SourceConveyorRuntimeState.source_conveyor_handle_item_state(len, capacity, facing_direction, rotation, mid, item_id, item_count_before) -> Dictionary`** — handleItem: capacity guard (no noSleep, no intake); otherwise `ang = facing_direction − rotation` (not absolute, matching Java), `x` from the ang arms, straight (`|ang| == 0`) inserts at index 0 with y 0, side inserts at mid with y 0.5, `noSleep()` runs on intake. Result keys: `accepted, index, x, y, len_after, item_count_after, no_sleep_called, reason` (accepted, at_capacity). The caller applies the array shift at the returned index.
- **N2052 `SourceConveyorRuntimeState.source_conveyor_pass_state(item_id, next_present, next_same_team, next_accepts_hook, next_handle_hook) -> Dictionary`** — pass: guards (null item, no next, wrong team, next rejects via hook); a missing handle hook fails closed with reason `no_handle`. On success the handle hook runs. Result keys: `passed, item_id, handle_called, reason` (passed, null_item, no_next, wrong_team, next_rejects, no_handle).

SSOT delta: **35 symbols / 6 schemas / 3 contracts / 3 slices**. Totals now: **10433 symbols / 1507 slices / 1395 contracts / 2581 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — no PortGame/PortBridge owner in this batch. Unlike the N2028 precedent, the new owner contracts ARE mirrored in the `conveyor` module shards (`source_modules/conveyor_api_contracts.json`, `conveyor_slices.json`, `conveyor_state_schema.json`, `conveyor_symbols.json`).

## How it was verified

- RED first: registration test failed (failures=1, errors=4) with the proof scene missing before the registration script ran.
- Targeted: registration test OK, exact-evidence test OK (all binding symbol exprs + ledger exprs exact against pinned `Conveyor.java`), `test_tile_slice` 41 OK, binding + liquid + catalog suites 78 OK.
- Catalog: 0 errors, JSON modules 0 errors / 113 modules. `git diff --check` clean.
- Godot proof: `ConveyorIntakeProof` — all 23 checks true, `matches=true`, Godot `4.6.2.stable.official.71f334935` headless. Proof JSON at `godot-mindustry/tools/runtime_proofs/ConveyorIntakeProof.json`. One fix worth remembering: GDScript `abs()` returns a Variant, so `var direction := abs(...)` fails to infer under warnings-as-errors — type it explicitly (`var direction: int`).
- Full Python suite PASS: 5408 tests OK in 1006.173s. The first full-suite run was killed mid-way by a service restart; the re-run completed cleanly. Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files in this slice (stage/commit exactly these)

- `godot-mindustry/src/game/SourceConveyorRuntimeState.gd` (N2050 + N2051 + N2052)
- `godot-mindustry/src/generated/source_api_contracts.json`, `source_slice_ledger.json`, `source_state_schema.json`, `source_symbol_registry.json`, `source_ssot_modules.json` (manifest gains `return_type` in the conveyor module's `optional_mirror_fields`), `source_modules/conveyor_api_contracts.json`, `conveyor_slices.json`, `conveyor_state_schema.json`, `conveyor_symbols.json` (conveyor shards mirror the new ConveyorBuild owners; the audit report was regenerated but is byte-identical — `totalSourceFunctions` stays 1335, no new PortGame/PortBridge owner)
- `godot-mindustry/tools/runtime_proofs/ConveyorIntakeProof.gd`, `ConveyorIntakeProof.tscn`
- `tools/mindustry_godot_transpiler/register_conveyor_intake_binding.py`, `tools/mindustry_godot_transpiler/tests/test_conveyor_intake_binding.py`
- `docs/superpowers/reports/2026-11-07-conveyor-intake-binding.md`, `docs/superpowers/handoffs/2026-11-07-conveyor-intake-binding-handoff.md`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1504 → 1507, N2050–N2052 checklist/table/log rows)

Do NOT stage `mindustry-upstream/`, `arc-upstream/`, `.godot/`, `godot-mindustry/project.godot`, or `*.gd.uid` (gitignored / known workspace noise). `ConveyorIntakeProof.gd.uid` and the earlier proof `.uid` files are untracked noise from proof runs; leave them alone.

## What is still open (next batch)

1. C02: wire the dump composition's hooks to these intake functions for a live drill→conveyor→core chain, the drill runtime bridge's game-global `drill_output_item_id` (make it use the actual dominant item), the one-inventory-owner cleanup, and the backlog's two-Drill gate (multiple conveyors/receivers/cores, capacity and blocked-output cases, exact in/out accounting, no double production in one frame).
2. C01 tail: entity group membership, controller pickup and world transition invalidation (need the unit system and campaign state machine), `Conveyor.unitOn`'s unit-pushing body, remaining Tile/Floor side effects.
3. Then C03 power, C04 liquid, C05 consumer init, C06 full gameplay loop, C07 units/waves, C08 null-body classification, C09 facade debt, C10 save/load/network, C11 UI/audio/perf, C12 clean-checkout release candidate.

No whole-domain acceptance or parity percentage is inferred from ledger counts.
