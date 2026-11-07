# Handoff — Schematics.placeLoadout binding (N2038–N2040)

Date: 2026-11-07. Parent: `099e9c2`. Sequential C01–C12 goal. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-loadout-place-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Bound `Schematics.placeLoadout` (5-arg form) into the production setBlock funnel, so a loadout schematic dictionary is placed with its core stile as the anchor, stiles in descending schematicPriority order, each non-core stile first clearing blocking Buildings from its footprint, and a placed CoreBuild firing the register-core hook:

- **N2038 `source_apply_loadout_tile_state(game, stile, origin_cell, team_id, check, tile_config_callback, register_core_hook) -> Dictionary`** in `godot-mindustry/src/game/SourceSchematicPlacementState.gd` — resolves the world Tile at the stile offset; null Tile skipped (`tile_missing`) before any removal pass. With `check` true and a non-core block, the removal pass walks `occupied_cells(cell, block)` and sends every non-air linked tile through the N2033 binding with air (`Tile.remove()` == `setBlock(air)`), re-reading the tile block per cell so a multiblock cleared by its origin is not counted twice. Core stiles skip the pass. The Building is then placed through N2035 with overwrite=true and no valid-place hook (placeLoadout never checks `Build.validPlace`). When the placed Building's block is a CoreBlock (`implementation == "CoreBlock"` from the content registry) and a valid hook is supplied, `register_core_hook` is called with (build, team_id) after configureAny. Result keys: `cell, tile, build, placed, skipped, removed, configured, core_placed, core_registered`.
- **N2039 `source_apply_loadout_place_state(game, schematic, x, y, team_id, check, priority_hook, tile_config_callback, register_core_hook) -> Dictionary`** in the same file — finds the first core stile and asserts when the schematic carries none (the runtime form of Java's throw); origin is the placed core position minus the core stile offsets; stiles run in descending priority order on a copy (the schematic's own tile order is untouched) through N2038. The priority hook is caller-supplied because `schematicPriority` is not exported by the content catalog (default 0; only seven upstream overrides); without one every stile has priority 0. Result keys: `origin, placed, skipped, removed, configured, cores_registered, results`.
- **N2040 `PortGame.source_place_loadout_state(schematic, x, y, team_id, check, priority_hook, tile_config_callback, register_core_hook) -> Dictionary`** in `godot-mindustry/src/game/PortGame.gd` — delegates to N2039. The `source_` prefix is required for implementation discovery (see the N2034 void-contract failure). The 4-arg `placeLoadout` delegation defaults `check` to true.

SSOT delta: **47 symbols / 6 schemas / 3 contracts / 3 slices**. Totals now: **10249 symbols / 1495 slices / 1383 contracts / 2557 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` is 1333, `+1` for `port_game.source_place_loadout_state`.

## How it was verified

- RED first: registration test failed with `KeyError: 'N2038'` / `'N2039'` / `'N2040'` and the proof scene was missing before the registration script ran.
- Targeted: registration test OK, exact-evidence test OK (all binding symbol exprs + ledger exprs exact against pinned `Schematics.java` / `Schematic.java` / `Teams.java` / `Tile.java` / `Block.java`), `test_tile_slice` 41 OK, binding + liquid + catalog suites 65 OK.
- Catalog: 0 errors, JSON modules 0 errors / 113 modules. `git diff --check` clean.
- Godot proof: `LoadoutPlaceProof` — all 10 checks true, `matches=true`, Godot `4.6.2.stable.official.71f334935` headless. Proof JSON at `godot-mindustry/tools/runtime_proofs/LoadoutPlaceProof.json`. Two proof/implementation fixes worth remembering: (1) the size-3 core footprint is centered on its cell (`sizeOffset` -1), covering (29..31, 19..21), not origin-anchored — the first (32,22) assertion was wrong, not the binding; (2) the first edit to `SourceSchematicPlacementState.gd` replaced the N2036 function instead of appending after it — PortGame failed to parse until N2036 was restored.
- Full Python suite PASS: 5396 tests OK in 958.013s. Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files in this slice (stage/commit exactly these)

- `godot-mindustry/src/game/SourceSchematicPlacementState.gd` (N2038 + N2039; N2036 restored in place)
- `godot-mindustry/src/game/PortGame.gd` (N2040 entry)
- `godot-mindustry/src/generated/source_api_contracts.json`, `source_slice_ledger.json`, `source_state_schema.json`, `source_symbol_registry.json`, `source_symbol_audit_report.json` (audit report regenerated, `totalSourceFunctions` 1332 → 1333)
- `godot-mindustry/tools/runtime_proofs/LoadoutPlaceProof.gd`, `LoadoutPlaceProof.tscn`
- `tools/mindustry_godot_transpiler/register_loadout_place_binding.py`, `tools/mindustry_godot_transpiler/tests/test_loadout_place_binding.py`
- `docs/superpowers/reports/2026-11-07-loadout-place-binding.md`, `docs/superpowers/handoffs/2026-11-07-loadout-place-binding-handoff.md`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1492 → 1495, N2038–N2040 checklist/table/log rows)

Do NOT stage `mindustry-upstream/`, `arc-upstream/`, `.godot/`, `godot-mindustry/project.godot`, or `*.gd.uid` (gitignored / known workspace noise). `TileChangeBuildSetBlockProof.gd.uid`, `PlacedTileSetBlockProof.gd.uid` and `SourceSchematicPlacementState.gd.uid` are untracked noise from earlier proof runs; leave them alone.

## What is still open (next batch)

1. `Build.validPlace` — needs rules/fog/darkness/unit/`canPlaceOn`/`canReplace` state before any placement path can check it for real.
2. Superclass `noSleep` with actual `sleepTime`/`sleeping`/group/`sleepingEntities`; power `onProximityRemoved`/`Added` and turret unregister with actual domain hooks.
3. Controller pickup/world transitions, remaining Tile/Floor side effects. Then C02 output/dump/transport, C03 power, C04 liquid, C05 consumer init, C06 full gameplay loop, C07 units/waves, C08 null-body classification, C09 facade debt, C10 save/load/network, C11 UI/audio/perf, C12 clean-checkout release candidate.

No whole-domain acceptance or parity percentage is inferred from ledger counts.
