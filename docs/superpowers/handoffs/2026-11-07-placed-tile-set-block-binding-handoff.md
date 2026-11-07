# Handoff — Production setBlock binding at placement and reload (N2032–N2034)

Date: 2026-11-07. Parent: `45eabcb`. Sequential C01–C12 goal. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-placed-tile-set-block-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Bound the N2029–N2031 `Tile.setBlock` primitive into the real production placement funnel, so player placement, the playable scenario and campaign bootstrap all execute the canonical setBlock with real Building identity, team and proximity:

- **N2032 `source_assign_build_team_state(sprite, team_id) -> Dictionary`** in `godot-mindustry/src/game/SourceBlockGeometry.gd` — assigns `Team.sharded` (id 1) to the placed sprite meta; `Team.derelict` (id 0) is the no-Building default. New consts `SOURCE_TEAM_SHARDED_ID := 1`, `SOURCE_TEAM_DERELICT_ID := 0`, `SOURCE_BUILD_TEAM_META_KEY := "team_id"`. This is the `build_team` hook target for the binding.
- **N2033 `source_apply_placed_tile_set_block_state(game, block, cell, sprite, team_id, rotation) -> Dictionary`** in `godot-mindustry/src/game/SourceWorldTerrainRuntimeState.gd` — builds all 38 setBlock hooks from the game context: world lookup via `source_world_tile`; previous build from `placed_blocks` (freed-instance guard); entity provider = the placed sprite; entity init = existing `game_initialize_sprite`; `remove_build` erases the old sprite from `placed_blocks` and every `placed_block_origins` entry whose value equals the old sprite's `origin_cell` meta, then `queue_free()`s it; proximity = the existing Drill recompute, team-filtered like `Building.updateProximity` (self first, then `onProximityUpdate` on each unique same-team edge neighbour); `build_team` = N2032; `neighbour_changing` via the neighbour Tile's `changing` flag; `set_block_air` = the recursive binding call with air + null sprite. Change events and renderer recache are explicit no-ops (no runtime bus/cache yet, per the N2021 precedent). Result keys: `tile, build, removed_old_build, proximity_updated, changed_event_fired, recache_called`.
- **N2034 wiring in `SourcePlacedBlockPortBridge.record_placed_block`** — the binding runs **before** `record_cells` overwrites the placement index, so the previous Building is still resolvable; the old separate proximity call is removed; the old field/proxy-assignment path is kept as a fallback when `source_world_tiles` is empty. **Out-of-world fallback:** the binding only runs when `source_world_tile` resolves the cell — the liquid-hydration proof places electrolyzers at `(200,200)` / `(210,200)`, outside the 48x32 world, and the first version asserted there. Otherwise the wiring falls back to the legacy init after `record_cells`, exactly like the pre-binding path. Uses the parent class's existing `source_block_geometry` const — do NOT redeclare it (a duplicate-const parse error was hit and fixed during this batch).
- **Scenario de-overlap (required by the binding).** The default scenario overlapped footprints — a conveyor cell inside the Drill footprint, a conveyor plus the Duo inside the Core footprint (core at `(17,8)`, size 3) — and faithful setBlock destroys the overlapped Building at bootstrap. `SourcePlayableScenarioDefaults.conveyor_cells()` now spans `range(DRILL_POS.x + 2, CORE_POS.x - 1)` (x 9..15, 7 cells); `DUO_POS` in `SourcePlayableWorldLayoutDefaults.gd` moved `(18,7)` → `(19,7)`. `path_points()` derives from `conveyor_cells()` so it updates automatically.

SSOT delta: **21 symbols / 5 schemas / 2 contracts / 3 slices** (N2034 has no contract — see below). Totals now: **10162 symbols / 1489 slices / 1377 contracts / 2545 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules.

## How it was verified

- RED first: registration test failed with `KeyError: 'N2032'` / `'N2033'` / `'N2034'` before the registration script ran; the proof scene was also missing.
- Targeted: registration test OK, exact-evidence test OK (all binding symbol exprs + ledger exprs exact against pinned `Tile.java` / `Team.java` / `Build.java` / `ConstructBlock.java`), `test_tile_slice` 41 OK.
- Catalog: 0 errors, JSON modules 0 errors / 113 modules. `git diff --check` clean. The first version of this batch registered a void contract for N2034 (`SourcePlacedBlockPortBridge.record_placed_block`); catalog validation failed with 2 errors because the implementation-discovery rule only sees `source_` / `generated_` functions in PortBridge files. The contract was removed (ledger + symbols + schema + runtime proof cover the slice; 99 symbol owners have no contract) and the register script now removes it on re-run instead of registering it. Renaming the funnel was rejected — the name is shared by `PortGame.gd`, `SourceBlockPlacement.gd` and three other slices' tests.
- Godot proof: `PlacedTileSetBlockProof` — all 13 checks true, `matches=true`, Godot `4.6.2.stable.official.71f334935` headless. Proof JSON at `godot-mindustry/tools/runtime_proofs/PlacedTileSetBlockProof.json`. Two proof findings are worth remembering: (1) the frame's `dominant_item` is the item **facts dictionary** (`{"id": 0, ...}` — copper is numeric id 0), not the string `"copper"`; the proof resolves the name through the catalog `item_names_by_id`. (2) A temporary `DebugBootstrapProof` was used to diagnose the bootstrap frame; it was deleted after use — do not recreate it unless the bootstrap frame regresses.
- Full Python suite PASS after the fix: 5390 tests OK in 904.200s. Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files in this slice (stage/commit exactly these)

- `godot-mindustry/src/game/SourceBlockGeometry.gd` (N2032 function + team consts)
- `godot-mindustry/src/game/SourceWorldTerrainRuntimeState.gd` (N2033 binding + 3 new preloads)
- `godot-mindustry/src/game/SourcePlacedBlockPortBridge.gd` (N2034 wiring)
- `godot-mindustry/src/game/SourcePlayableScenarioDefaults.gd`, `godot-mindustry/src/game/SourcePlayableWorldLayoutDefaults.gd` (scenario de-overlap)
- `godot-mindustry/src/generated/source_symbol_registry.json`, `source_slice_ledger.json`, `source_api_contracts.json`, `source_state_schema.json` (audit report regenerated, totals unchanged)
- `godot-mindustry/tools/runtime_proofs/PlacedTileSetBlockProof.gd`, `PlacedTileSetBlockProof.tscn`
- `tools/mindustry_godot_transpiler/register_placed_tile_set_block_binding.py`, `tools/mindustry_godot_transpiler/tests/test_placed_tile_set_block_binding.py`
- `docs/superpowers/reports/2026-11-07-placed-tile-set-block-binding.md`, `docs/superpowers/handoffs/2026-11-07-placed-tile-set-block-binding-handoff.md`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1486 → 1489, N2032–N2034 checklist/table/log rows)

Do NOT stage `mindustry-upstream/`, `arc-upstream/`, `.godot/`, `godot-mindustry/project.godot`, or `*.gd.uid` (gitignored / known workspace noise). `TileChangeBuildSetBlockProof.gd.uid` is untracked noise from the previous proof run; leave it alone.

## What is still open (next batch)

1. `Schematics.place` has no runtime path yet — its 3-arg setBlock call sites (`Schematics.java:491/514`, provider `type::newBuilding`) are the next binding target. Prep notes in `~/workspace/notes/next-batch-prep.md`.
2. Superclass `noSleep` with actual `sleepTime`/`sleeping`/group/`sleepingEntities`; power `onProximityRemoved`/`Added` and turret unregister with actual domain hooks.
3. Controller pickup/world transitions, remaining Tile/Floor side effects. Then C02 output/dump/transport, C03 power, C04 liquid, C05 consumer init, C06 full gameplay loop, C07 units/waves, C08 null-body classification, C09 facade debt, C10 save/load/network, C11 UI/audio/perf, C12 clean-checkout release candidate.

No whole-domain acceptance or parity percentage is inferred from ledger counts.
