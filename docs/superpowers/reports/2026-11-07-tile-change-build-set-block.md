# Executable Tile changeBuild / changed / full two-pass setBlock — N2029–N2031

Date: 2026-11-07. Parent: `3890f39`. Sequential C01–C12 goal, C01 next batch after N2026–N2028. This batch composes the registered proximity/pre-change primitives into executable `Tile.changeBuild`, `Tile.changed` and the full two-pass `Tile.setBlock` on actual Tile dictionaries. It does not bind them at production placement or world reload, and it does not accept C01 as a domain or clean-checkout reproducibility.

## Checkpoints and evidence

| Gate | Evidence | Status |
| --- | --- | --- |
| PR-A | Checklist/SSOT/manifest/shards/upstream Java read; RED | Registration test failed first with `KeyError: 'N2029'` / `'N2030'` / `'N2031'` (3 errors) before the registration script ran |
| PR-B | Focused and catalog | Registration test OK; `test_tile_slice` 41 tests OK; proximity void-catalog tests 6 OK; catalog validation 0 errors, JSON modules 0 errors / 113 modules; `git diff --check` clean |
| PR-C | Full suite with frozen inputs; native MCP, inspect and stop | **Partially done.** Godot proof passes headless on this machine: `TileChangeBuildSetBlockProof` 15/15 checks true, `matches=true`, Godot `4.6.2.stable.official.71f334935`, 0 errors after a one-time project import (see below). Full Python suite started in the background at commit time; check `/tmp/full-suite-n2029.log`. Native MCP runtime proof on Richard's Windows machine (port 7777) is still the remaining step for this gate |
| PR-D | Editor, deterministic replay, exact index | **Pending.** Editor parse and replay run with the full suite; exact staged allowlist below |

Exact-source evidence: all 61 new symbol `java_expr` values and all ledger `exact_exprs` for N2029–N2031 were verified as exact substrings of `Tile.java` at pinned upstream revision `2bdedfed25932ebf11330d3584092c50e2e26d96`, first via raw content at that revision and then by the exact-evidence test against the local `mindustry-upstream/` tree populated from the pinned-commit tarball (the full `git clone` was too slow on this network, ~200 KB/s; the tree contents are identical for test purposes and the directory is gitignored). `Geometry.d4` order `(1,0), (0,1), (-1,0), (0,-1)` was verified against Arc `Geometry.java` at pinned revision `f30acd23ece4b626b755660d56c1b0d4aaf46aed`.

Two environment fixes on a fresh Linux checkout, not part of the slice: the Godot proof first failed with `ERROR: Unrecognized UID: "uid://csajjlruh8jey"` (MCPRuntime autoload) because the gitignored `.godot/` cache did not exist; a one-time `godot --headless --path godot-mindustry --import` fixed it. The proof also first failed one check (`change_build_removes_old_and_updates_unique_edges`) because the test fixture placed edge Buildings at non-edge offsets; the fixture was corrected to real `edge_points_state(2)` offsets (`(12,10)` and `(11,9)` for the deduplicated neighbour, `(12,11)` for the second neighbour) and then passed.

## Ownership and actual API boundary

`SourceBlockGeometry` gains `source_apply_tile_change_build`, `source_apply_tile_changed` and `source_apply_tile_set_block`. All three are `-> void` and mutate the supplied Tile dictionary in place; they manufacture no empty proximity, team, Block or Building, and no guessed default.

- **N2029 changeBuild.** Old Building is removed first (`remove_build`), the Tile build is cleared, edge Buildings are collected through the canonical edge owner `SourceBlockPlanGeometryState.edge_points_state(old_block_size)` in source order and deduplicated by identity (upstream `tileSet` is an `ObjectSet`, so no order between distinct neighbours is claimed), each unique edge Building updates proximity once, and a new Building is created only when the new Block has one, with `init_update = block.update && !state.isEditor()`.
- **N2030 changed.** While generating, no proximity work happens and the change event is suppressed through the canonical `tile_fire_change_state` gate; a static Block still recaches. With a build present, the build updates proximity; without one, each `Geometry.d4` neighbour is looked up fresh and only non-changing neighbours receive `onProximityUpdate`.
- **N2031 setBlock.** Composes the three primitives in source order: `changing = true`; static guard `recache`/`recacheWall`; `forceTeam` replacement; `preChanged` (N2028, old Building retained on the mutation Tile); `this.block = type`; `changeBuild` (N2029, rotation normalized with `posmod 4`); `build.team(team)` when a build exists; multiblock two-pass with fresh lookups per pass in source dx/dy order (pass 0 clears each proxy through the caller-bound `setBlock(Blocks.air)` hook, pass 1 assigns the new entity and Block, then the mutation Tile is re-assigned); `changed` (N2030); `changing = false`; `block.blockChanged(this)`.

## SSOT and preservation

Delta: **61 symbols / 3 input schemas / 3 void contracts / 3 slices**. Working totals: **10141 symbols / 1486 ledger records / 1375 contracts / 2540 schemas**. Content remains 425 blocks. Extension manifest remains 100 direct modules; expanded validation remains 113. The audit report was regenerated by the registration script; totals are unchanged (`totalSourceFunctions=1331`, `functionRecordAccountingGap=17` preserved, C09 item) and the diff is a reordering of `sourceFunctions` records only. `SourceBlockGeometry` contracts are not mirrored in any `source_modules` shard, matching the N2028 precedent for this owner; the registration script's optional-`return_type` mirror loop therefore changed no shard.

## Remaining C01 work and next batch

Bind the three primitives at production placement and world reload: actual Building/proximity/Team state, `Tile.changeBuild`/`setBlock` call sites, entity group removal/init through the real provider, and the actual event/renderer/pathfinder context. The multiblock pass-0 `setBlock(Blocks.air)` hook must be bound to the real recursive `setBlock` there; the proof probe only records the call and clears the proxy.

Superclass `noSleep` must use actual `sleepTime`/`sleeping`/group membership/`sleepingEntities`. Power `onProximityRemoved`/`Added` and turret unregister require actual domain hooks; callback probes are not their acceptance. Controller pickup/world transitions and remaining Tile/Floor side effects stay open. C02–C12 remain open. No whole-domain acceptance or parity percentage is inferred from ledger counts.

Evidence: `tools/runtime_proofs/TileChangeBuildSetBlockProof.gd` / `.tscn`, `tools/mindustry_godot_transpiler/tests/test_tile_change_build_set_block.py`, `tools/mindustry_godot_transpiler/register_tile_change_build_set_block.py`.
