# Handoff — Schematics.place binding (N2035–N2037)

Date: 2026-11-07. Parent: `e1d5ea3`. Sequential C01–C12 goal. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-schematic-place-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Bound `Schematics.place` (5-arg form) into the production setBlock funnel, so a schematic dictionary is placed on the real world Tile store one stile at a time through the N2033 binding:

- **N2035 `source_apply_schematic_tile_state(game, stile, origin_cell, team_id, overwrite, valid_place_hook, tile_config_callback) -> Dictionary`** in new `godot-mindustry/src/game/SourceSchematicPlacementState.gd` — resolves the world Tile at the stile offset; null Tile skipped (`tile_missing`); `overwrite` false is fail-closed without a valid `valid_place_hook` (`valid_place_unchecked`) and skips on hook rejection (`valid_place_rejected`); the Building is created by the placement funnel exactly like player placement (new Sprite2D, `configure_block_sprite`, `World/BlockLayer`, `record_placed_block` with the threaded team); when the Tile keeps a Building and the stile carries a config, `configure_any_state` runs with the caller-supplied `tile_config_callback`. Result keys: `cell, tile, build, placed, skipped, valid_place_checked, configured`.
- **N2036 `source_apply_schematic_place_state(game, schematic, x, y, team_id, overwrite, valid_place_hook, tile_config_callback) -> Dictionary`** in the same file — origin is the center minus half the width/height, stiles run in source order through N2035. Result keys: `origin, placed, skipped, configured, results`.
- **N2037 `PortGame.source_place_schematic_state(schematic, x, y, team_id, overwrite, valid_place_hook, tile_config_callback) -> Dictionary`** in `godot-mindustry/src/game/PortGame.gd` — delegates to N2036. The `source_` prefix is required for implementation discovery (see the N2034 void-contract failure). The placement funnel gains a defaulted `team_id: int = 1` (sharded) parameter, forwarded through the `PortGame` override, so schematic placement threads its team instead of hardcoding the player team; existing callers keep the default.
- **Funnel registration note.** The `record_placed_block_input.team_id` symbol belongs to the funnel slice N2034 (owner matches); only the schema key is added by this batch's register script. `test_playable.py`'s `record_placed_block` signature assertion is updated to the new funnel signature.

SSOT delta: **40 symbols / 6 schemas / 3 contracts / 3 slices**. Totals now: **10202 symbols / 1492 slices / 1380 contracts / 2551 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules.

## How it was verified

- RED first: registration test failed with `KeyError: 'N2035'` / `'N2036'` / `'N2037'` and the funnel `team_id` key missing before the registration script ran; the proof scene was also missing.
- Targeted: registration test OK, exact-evidence test OK (all binding symbol exprs + ledger exprs exact against pinned `Schematics.java` / `Schematic.java` / `BuildingComp.java` / `Block.java`), `test_tile_slice` 41 OK, binding + liquid + catalog suites 64 OK.
- Catalog: 0 errors, JSON modules 0 errors / 113 modules. `git diff --check` clean.
- Godot proof: `SchematicPlaceProof` — all 10 checks true, `matches=true`, Godot `4.6.2.stable.official.71f334935` headless. Proof JSON at `godot-mindustry/tools/runtime_proofs/SchematicPlaceProof.json`. One proof fix is worth remembering: the overwrite-replacement check first failed because `queue_free()` is deferred — await one process frame before asserting the old sprite is freed, mirroring the PlacedTileSetBlockProof pattern.
- Full Python suite PASS after the fix: 5393 tests OK in 928.702s. Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files in this slice (stage/commit exactly these)

- `godot-mindustry/src/game/SourceSchematicPlacementState.gd` (new; N2035 + N2036)
- `godot-mindustry/src/game/PortGame.gd` (N2037 entry + funnel `team_id` forwarding)
- `godot-mindustry/src/game/SourcePlacedBlockPortBridge.gd` (funnel defaulted `team_id`)
- `godot-mindustry/src/generated/source_symbol_registry.json`, `source_slice_ledger.json`, `source_api_contracts.json`, `source_state_schema.json` (audit report regenerated, totals unchanged)
- `godot-mindustry/tools/runtime_proofs/SchematicPlaceProof.gd`, `SchematicPlaceProof.tscn`
- `tools/mindustry_godot_transpiler/register_schematic_place_binding.py`, `tools/mindustry_godot_transpiler/tests/test_schematic_place_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_playable.py` (funnel signature assertion only)
- `docs/superpowers/reports/2026-11-07-schematic-place-binding.md`, `docs/superpowers/handoffs/2026-11-07-schematic-place-binding-handoff.md`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1489 → 1492, N2035–N2037 checklist/table/log rows)

Do NOT stage `mindustry-upstream/`, `arc-upstream/`, `.godot/`, `godot-mindustry/project.godot`, or `*.gd.uid` (gitignored / known workspace noise). `TileChangeBuildSetBlockProof.gd.uid` is untracked noise from an earlier proof run; leave it alone.

## What is still open (next batch)

1. `Schematics.placeLoadout` — core-tile anchoring, `schematicPriority` sort, blocking-build removal pass, `registerCore`.
2. `Build.validPlace` — needs rules/fog/darkness/unit/`canPlaceOn`/`canReplace` state before the fail-closed hook can be replaced by a real check.
3. Superclass `noSleep` with actual `sleepTime`/`sleeping`/group/`sleepingEntities`; power `onProximityRemoved`/`Added` and turret unregister with actual domain hooks.
4. Controller pickup/world transitions, remaining Tile/Floor side effects. Then C02 output/dump/transport, C03 power, C04 liquid, C05 consumer init, C06 full gameplay loop, C07 units/waves, C08 null-body classification, C09 facade debt, C10 save/load/network, C11 UI/audio/perf, C12 clean-checkout release candidate.

No whole-domain acceptance or parity percentage is inferred from ledger counts.
