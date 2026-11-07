# Handoff — Build.validPlace binding (N2041–N2043)

Date: 2026-11-07. Parent: `7b6c237`. Sequential C01–C12 goal. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-valid-place-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Bound `Build.validPlace` (7-arg form) into the runtime, so placement legality is evaluated from the world Tile store instead of a caller-supplied hook:

- **N2041 `SourceBlockGeometry.source_valid_place_footprint_cell_state(game, block, block_flags, floor_flags, check_cell, origin_cell, team_id, rotation, check_visible, check_core_radius, rules_state, darkness_hook, fog_discovered_hook) -> Dictionary`** — one footprint cell in Java order: null cell, size-2 darkness, staticFog/fog discovery, deep floor, derelict repair, same-block-same-rotation (except a non-derelict team replacing a derelict same block), `Tile.interactable` from `Teams.canInteract` (team metas), solid floor, payload replacement, canReplace/canBeReplaced/derelict-same-type plus bounds containment, requires-water. `canBeReplaced` collapses into `canReplace` (`Building.canBeReplaced(other)` is `other.canReplace(block)`); ConstructBuild replacement is false (no build under construction). Result keys: `cell, valid, reason`.
- **N2042 `SourceBlockGeometry.source_valid_place_ignore_units_state(game, block, block_flags, floor_flags, team_id, x, y, rotation, check_visible, check_core_radius, rules_state, cores_state, can_place_on_hook, darkness_hook, fog_discovered_hook, enemy_overlap_hook) -> Dictionary`** — null type, visibility gate (rules dict + block flags), core protection from a caller-supplied cores registry (polygon closest-core mode and enemy-radius mode, cell-center distances in pixels), null tile, canPlaceOn hook (Block default true), floor already-placed return, darkness, shallows (footprint plus ring floors), footprint loop through N2041 returning the first failing cell and reason, place-range check via the enemy-overlap hook. Result keys: `valid, reason, cell`.
- **N2043 `PortGame.source_valid_place_state(block, block_flags, floor_flags, team_id, x, y, rotation, check_visible, check_core_radius, rules_state, cores_state, can_place_on_hook, darkness_hook, fog_discovered_hook, enemy_overlap_hook, unit_overlap_hook) -> Dictionary`** — runs N2042, then `checkNoUnitOverlap`: a solid/solidifes block with a hook reporting an overlap fails (`unit_overlap`); a null hook means no overlap (no unit system yet).
- **Rotation meta (N2041 data dependency).** The N2033 setBlock binding's entity init now stores the placement rotation on the Building sprite meta (`SourceBlockGeometry.SOURCE_BUILD_ROTATION_META_KEY`, default 0 for older sprites), so the same-block check reads real state. One line in `SourceWorldTerrainRuntimeState.gd`, plus the const in `SourceBlockGeometry.gd`.

Caller-supplied, each with a Java default when absent: `block_flags` / `floor_flags` lookup dictionaries keyed by block id (the Block/Floor fields the catalog does not export); `rules_state` (Rules.java defaults); `cores_state` (cores with cell/team/protectCores, buildRadius 400, tilesize 8). Hooks defaulting honestly: `can_place_on_hook` (Block default true), `darkness_hook` (0), `fog_discovered_hook` (undiscovered), `enemy_overlap_hook` (no overlap), `unit_overlap_hook` (no overlap).

SSOT delta: **54 symbols / 6 schemas / 3 contracts / 3 slices**. Totals now: **10303 symbols / 1498 slices / 1386 contracts / 2563 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` is 1334, `+1` for `port_game.source_valid_place_state`.

## How it was verified

- RED first: registration test failed with `KeyError: 'N2041'` / `'N2042'` / `'N2043'` and the proof scene was missing before the registration script ran.
- Targeted: registration test OK, exact-evidence test OK (all binding symbol exprs + ledger exprs exact against pinned `Build.java` / `Block.java` / `Tile.java` / `Teams.java` / `Rules.java` / `Floor.java` / `Drill.java` / `Vars.java`), `test_tile_slice` 41 OK, binding + liquid + catalog suites 68 OK. The exact-evidence test caught three `block_flags` symbols using the `canReplace` expr with the wrong source (`Build.java` instead of `Block.java`); the register script now passes `source=BLOCK` for them.
- Catalog: 0 errors, JSON modules 0 errors / 113 modules. `git diff --check` clean.
- Godot proof: `ValidPlaceProof` — all 21 checks true, `matches=true`, Godot `4.6.2.stable.official.71f334935` headless. Proof JSON at `godot-mindustry/tools/runtime_proofs/ValidPlaceProof.json`. Two fixes worth remembering: (1) the first `_valid_place_can_replace` draft mis-evaluated the rotation and group arms — the function now takes an explicit `other_is_self` flag; (2) the unit-overlap case must run before the drill is placed at (33,20), or the footprint cell fails with `cannot_replace` first.
- Full Python suite PASS: 5399 tests OK in 980.136s. Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files in this slice (stage/commit exactly these)

- `godot-mindustry/src/game/SourceBlockGeometry.gd` (N2041 + N2042, rotation meta const)
- `godot-mindustry/src/game/SourceWorldTerrainRuntimeState.gd` (rotation meta set in the N2033 entity init — N2041 data dependency)
- `godot-mindustry/src/game/PortGame.gd` (N2043 entry)
- `godot-mindustry/src/generated/source_api_contracts.json`, `source_slice_ledger.json`, `source_state_schema.json`, `source_symbol_registry.json`, `source_symbol_audit_report.json` (audit report regenerated, `totalSourceFunctions` 1333 → 1334)
- `godot-mindustry/tools/runtime_proofs/ValidPlaceProof.gd`, `ValidPlaceProof.tscn`
- `tools/mindustry_godot_transpiler/register_valid_place_binding.py`, `tools/mindustry_godot_transpiler/tests/test_valid_place_binding.py`
- `docs/superpowers/reports/2026-11-07-valid-place-binding.md`, `docs/superpowers/handoffs/2026-11-07-valid-place-binding-handoff.md`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1495 → 1498, N2041–N2043 checklist/table/log rows)

Do NOT stage `mindustry-upstream/`, `arc-upstream/`, `.godot/`, `godot-mindustry/project.godot`, or `*.gd.uid` (gitignored / known workspace noise). `TileChangeBuildSetBlockProof.gd.uid`, `PlacedTileSetBlockProof.gd.uid`, `SchematicPlaceProof.gd.uid`, `LoadoutPlaceProof.gd.uid` and `SourceSchematicPlacementState.gd.uid` are untracked noise from earlier proof runs; leave them alone.

## What is still open (next batch)

1. Superclass `noSleep` group membership (entity group add/remove — the pure `no_sleep_state` is already bound at N1890); power/turret live hooks (pure proximity and PowerGraph states already bound at N966/N967/N1590+); controller pickup/world transitions; remaining Tile/Floor side effects. The pure-state slices for those areas exist; what is missing is live wiring into systems the runtime does not own yet (entity groups, event bus, unit system, renderer recache).
2. Then C02 output/dump/transport, C03 power, C04 liquid, C05 consumer init, C06 full gameplay loop, C07 units/waves, C08 null-body classification, C09 facade debt, C10 save/load/network, C11 UI/audio/perf, C12 clean-checkout release candidate.

No whole-domain acceptance or parity percentage is inferred from ledger counts.
