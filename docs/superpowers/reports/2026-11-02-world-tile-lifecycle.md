# Canonical world Tile storage and bootstrap/placement projection — N2017–N2019

Date: 2026-11-02. Parent: `a9fcb807`. Sequential C01–C12 goal, C01-A provider integration batch. This checkpoint binds actual source geometry and a dense Tile container to the real default game bootstrap and placement recording. It does not close C01, complete Tile.setBlock lifecycle, or enable live mixed-ore production.

## Checkpoints

| Gate | Evidence | Status |
| --- | --- | --- |
| WT-A | Read root SSOT/manifest/shards/checklist/Java; expected missing APIs/contracts RED | 6 failures / 1 pass, 31.17s; retained compressed log |
| WT-B | Focused and catalog | 19 tests / 18 subtests, 73.68s; 0 errors / 113 modules / 0 JSON errors |
| WT-C | Complete full suite, native MCP, debug inspection and explicit stop | 5383 tests / 22772 subtests in 1170.21s; 20 native checks true; 0 actual errors / 68 warnings |
| WT-D | Editor parse, deterministic replay and exact semantic index | Editor exit 0; 114 raw hashes unchanged; exact index audit in evidence/index-final.log |

## Cohesive owners

- `SourceWorldTerrainRuntimeState` owns geometry composition, dense Tile storage, decoded-map materialization and game bootstrap projection. No new production runtime module or alternate ore registry.
- `SourceBlockMetadataState.block_size`, `SourceBlockInitPlacementState.offset_state` and `SourceBlockQueryBasicState.is_multiblock_state` remain the sole metadata/default/init/query owners. There is no second sizeOffset formula or persistent geometry cache.
- Existing `SourceBlockGeometry` owns linked traversal and drop; existing query owner owns isStatic; existing `SourceDrillRuntimeState.source_count_ore_state` owns ore selection.
- Actual game state has one `source_world_tiles` container. `placed_blocks` remains the Building sprite index. Static batched walls enter Tile storage from decoded map records, independently of sprites.
- Source field identities air/stone/oreCopper are pinned in the existing terrain owner and SSOT. They express Tile.fill, SaveVersion's air-floor replacement and the existing explicit copper scenario. Arbitrary map content uses actual decoded IDs and typed definitions, without a name allowlist or underscore/slug conversion. Existing rendering texture keys such as stone_floor are not content IDs.

## N2017 — canonical geometry binding

Actual typed Block metadata feeds existing source size/default, Block.init offset and isMultiblock owners. Results contain size, size_offset and is_multiblock. Independent runtime cases cover sizes 1/2/3/4 and expected offsets 0/0/-1/-1. Definitions are not mutated and no init result is guessed from sprite bounds.

## N2018 — dense Tile and decoded-map materialization

Tiles.java constructor/fill/get defines width*height storage, logical coordinates, source-air references and null outside each boundary. Dictionaries preserve Tile and Block identity; each cell is independent. The provider supports positive loaded-world dimensions, not all World resize/intermediate empty states.

SaveVersion.java readMap creates floors before blocks and replaces an actual air floor with source stone. Complete ordered floor runs may cross rows. Gaps, overlaps, incomplete coverage and unresolved/wrong-type content are rejected. Existing decoded block records contain center Buildings and individual static cells. Center footprints reuse canonical linked geometry and skip null border lookups.

This is a field/proxy projection of decoded map data. It does not deserialize Building entity payloads, teams, rotations or data bytes and does not reproduce all Tile.setBlock side effects. Unknown metadata is not replaced by guessed air/static/drop values.

## N2019 — actual game bootstrap and placement wiring

`SourceWorldInitialBuildRuntimeState.build_world` stores the Tile container before static/dynamic Building placement. It uses a consumed campaign map when supplied; otherwise it uses explicit scenario logical dimensions, stone floor and copper overlay cells. Viewport background dimensions remain a rendering concern.

`record_placed_block` updates the same container using actual Block identity and canonical footprint geometry. The game exposes source_world_tile and source_world_linked_ore_tiles_state; the latter composes initialized geometry, world lookup and the accepted Tile ore provider. Native proof instantiates the actual Main scene, checks default bootstrap, initial Drill, a second real placement and canonical countOre composition over the live world's Tiles.

The decoded campaign branch is tested through the game-owned materializer with an explicit map fixture, including static walls and center/proxies. This is not acceptance of campaign map-file launch/reload or Building deserialization. A fresh materialization allocates independent storage; this does not prove old scene/Building teardown on world transition.

Existing record_placed_block callers can record sprites outside logical world bounds. The new Tile projection skips a null center while preserving that legacy sprite API; it does not create out-of-bounds Tiles or claim source placement validation parity.

## Registration and staging

Same-slice additions: **48 symbols / 5 Dictionary-result contracts / 15 schemas / 3 slices**. Scalar/void helpers have source-backed symbols/input schemas, without fabricated Dictionary results. Ledger 1474; symbols 9985; contracts 1358; schemas 2510. Direct extension manifest remains 100; expanded validation remains 113 modules. Only block_slices/block_api_contracts mirrors change, regenerated in dependency order.

The canonical source audit is regenerated for exactly two new game query owners/functions. Function count 1329→1331; discovered owners 1327→1329; canonical owners 1312→1314; registered owners 1304→1306. Legacy-unregistered and coverage gap remain 0. Existing function-record accounting gap 17 remains a C09 inventory item. Audit source paths for the two additions are mapped to PortGame in the staged monolithic layout and to their actual bridge in the working layout; prior audit records/policy are preserved.

The working tree contains a large preexisting uncommitted facade extraction. New runtime hooks physically live in SourcePlayableWorldRuntimePortBridge and SourcePlacedBlockPortBridge there. HEAD still owns the same functions and state directly in PortGame. Exact semantic staging maps only this batch's new field/query methods/placement hook into HEAD's PortGame, stages the shared build_world call in its existing canonical module and includes the terrain scenario preload required by those new functions. Unrelated bridge extraction and source-text refactors remain unstaged and unchanged. The scope/index helpers record this correspondence; no whole-directory staging is used.

The already-existing world_size getter (a direct view of canonical WORLD_SIZE) is also included as the new materializer/proof's necessary dependency, without its other unrelated scenario changes. Working-tree full/native gates do not establish clean-checkout acceptance. C12 remains open, including existing dependency/facade debt. No push or amend.

## Verification and remaining work

Focused: 19 tests / 18 subtests in 73.68s. Full: 5383 tests / 22772 subtests in 1170.21s. Native MCP: 20/20 true, matches=true, 68 warnings and 0 actual errors; explicit stop inspected. Editor parse exit 0. All registered JSON plus generated content GD replay: 114 hashes unchanged. Catalog and exact scoped index accepted.

The first full run completed with 2 failures / 5381 passes / 22768 subtests in 1245.64s. It caught a facade-test extraction that ran past the next method into canonical module code, plus a stale audit after adding two game queries. The test now uses its existing method-boundary helper; registration regenerates the canonical audit. Repair gate: 6 tests / 3 subtests in 73.39s. The complete full suite above was rerun after these repairs. The failed log is retained compressed, not counted as an accepted gate.

Next: C01-A Drill.getDrop composition and source lifecycle boundaries; C01-B onProximityUpdate dominantItem/dominantItems assignment/invalidation, pickup/reset and removal/footprint changes; then C01-C actual dominant-item output/offload. Do not add a per-tick map scan as a substitute for proximity lifecycle. Keep live mixed-ore gameplay locked until those gates.

Full Tile.setBlock overlap cleanup/changeBuild/events/recache/team handling, setFloor/setOverlay notifications, removal, campaign reload, save/network persistence, legacy ore_items_by_cell migration and C02–C12 remain open. Registry/test counts are not whole-game parity percentages.

Evidence: `evidence/2026-11-02-world-tile-lifecycle/`. Source-evidence JSON contains exact anchors for all 48 added symbols; scope-helper.txt and index-audit-helper.txt reconstruct the exact commit boundary.
