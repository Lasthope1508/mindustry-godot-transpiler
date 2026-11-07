# Handoff — noSleep wake-on-activity binding (N2044–N2046)

Date: 2026-11-07. Parent: `295ebae`. Sequential C01–C12 goal. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-no-sleep-wake-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Wired the `noSleep` binding (pure state, N1890) into its Building call sites, so Buildings wake when stacks are handled or proximity updates:

- **N2044 `SourceBuildingItemState.source_handle_stack_wake_state(current_count, amount, sleep_time, sleeping, sleeping_entities) -> Dictionary`** — `handleStack`: `noSleep()` runs first, then the stack is added. Delegates to `handle_stack_count` for the count and to `no_sleep_state` for the wake transition. Result keys: `count_before, count_after, sleep_time_before, sleep_time_after, sleeping_before, sleeping_after, sleeping_entities_before, sleeping_entities_after, woke, add_called`.
- **N2045 `SourceBuildingItemState.source_remove_stack_wake_state(has_items_module, item_count, amount, sleep_time, sleeping, sleeping_entities) -> Dictionary`** — `removeStack`: delegates to `remove_stack_state` for the clamped removal. Without an items module the Java null guard returns 0 before `noSleep`, so sleepTime, sleeping and sleepingEntities are untouched (`woke` false, `add_called` false). With an items module, `noSleep` runs, then the clamped stack is removed. Result keys: `removed, remaining, return_value` plus the eight wake keys.
- **N2046 `SourceBuildingAccessState.source_on_proximity_update_wake_state(sleep_time, sleeping, sleeping_entities) -> Dictionary`** — `onProximityUpdate` is just `noSleep()`; delegates to `no_sleep_state` and re-keys the result. This is the superclass wake, distinct from the power-domain `onProximityUpdate` state at N968 (power graph side). Result keys: the eight wake keys.

The group `add()` is recorded (`add_called`), not executed, because the runtime has no entity groups yet.

SSOT delta: **43 symbols / 6 schemas / 3 contracts / 3 slices**. Totals now: **10346 symbols / 1501 slices / 1389 contracts / 2569 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1334 — no PortGame/PortBridge owner in this batch. Unlike the N2028 precedent, the new owner contracts ARE mirrored in the `comp` module shards (`source_modules/comp_api_contracts.json` gains the N2046 contract, `source_modules/comp_slices.json` gains N2044–N2046).

## How it was verified

- RED first: registration test failed with `KeyError: 'N2044'` / `'N2045'` / `'N2046'` and the proof scene was missing before the registration script ran.
- Targeted: registration test OK, exact-evidence test OK (all binding symbol exprs + ledger exprs exact against pinned `BuildingComp.java`), `test_tile_slice` 41 OK, binding + liquid + catalog suites 72 OK.
- Catalog: 0 errors, JSON modules 0 errors / 113 modules. `git diff --check` clean.
- Godot proof: `NoSleepWakeProof` — all 10 checks true, `matches=true`, Godot `4.6.2.stable.official.71f334935` headless. Proof JSON at `godot-mindustry/tools/runtime_proofs/NoSleepWakeProof.json`. One test fix worth remembering: the proof writer emits the prefix `NO_SLEEP_WAKE_PROOF ` (name uppercased with underscores), not `NOSLEEP_WAKE_PROOF `.
- Full Python suite PASS: 5402 tests OK in 992.821s. Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files in this slice (stage/commit exactly these)

- `godot-mindustry/src/game/SourceBuildingItemState.gd` (N2044 + N2045, plus the AccessState preload)
- `godot-mindustry/src/game/SourceBuildingAccessState.gd` (N2046)
- `godot-mindustry/src/generated/source_api_contracts.json`, `source_slice_ledger.json`, `source_state_schema.json`, `source_symbol_registry.json`, `source_modules/comp_api_contracts.json`, `source_modules/comp_slices.json` (comp shards mirror the new BuildingComp owners; the audit report was regenerated but is byte-identical — `totalSourceFunctions` stays 1334, no new PortGame/PortBridge owner)
- `godot-mindustry/tools/runtime_proofs/NoSleepWakeProof.gd`, `NoSleepWakeProof.tscn`
- `tools/mindustry_godot_transpiler/register_no_sleep_wake_binding.py`, `tools/mindustry_godot_transpiler/tests/test_no_sleep_wake_binding.py`
- `docs/superpowers/reports/2026-11-07-no-sleep-wake-binding.md`, `docs/superpowers/handoffs/2026-11-07-no-sleep-wake-binding-handoff.md`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1498 → 1501, N2044–N2046 checklist/table/log rows)

Do NOT stage `mindustry-upstream/`, `arc-upstream/`, `.godot/`, `godot-mindustry/project.godot`, or `*.gd.uid` (gitignored / known workspace noise). `TileChangeBuildSetBlockProof.gd.uid`, `PlacedTileSetBlockProof.gd.uid`, `SchematicPlaceProof.gd.uid`, `LoadoutPlaceProof.gd.uid`, `ValidPlaceProof.gd.uid` and `SourceSchematicPlacementState.gd.uid` are untracked noise from earlier proof runs; leave them alone.

## What is still open (next batch)

1. C01 tail: entity group membership (Java `add()`/`remove()` group moves), controller pickup and world transition invalidation (need the unit system and campaign state machine), `Conveyor.unitOn`'s unit-pushing body, remaining Tile/Floor side effects.
2. Then C02 output/dump/transport: reuse the drill inventory/dump and building item states, drop the local fallback for source offload/dump composition, keep one inventory owner, gate on two Drills with multiple conveyors/receivers/cores and correct in/out accounting. Then C03 power, C04 liquid, C05 consumer init, C06 full gameplay loop, C07 units/waves, C08 null-body classification, C09 facade debt, C10 save/load/network, C11 UI/audio/perf, C12 clean-checkout release candidate.

No whole-domain acceptance or parity percentage is inferred from ledger counts.
