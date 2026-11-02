# Actual terrain mutation and Drill notification — N2023–N2025

Date: 2026-11-02. Parent: `f6f76298`. Sequential C01–C12 goal, C01 terrain lifecycle batch. This accepts canonical field mutation and supported Drill notifications. It does not close C01, all Tile side effects, RPC networking, clean-checkout reproducibility or full game parity.

## Checkpoints

| Gate | Evidence | Status |
| --- | --- | --- |
| TN-A | Read checklist/five roots/manifest/all shards/exact Tile.java; RED before implementation | 5 expected failures / 1 pass in 12.59s; additional shared-helper contract RED retained |
| TN-B | Focused plus source/audit/catalog | 14 tests / 93 subtests in 96.19s; metadata/source gate 2 tests / 51 subtests; 0 errors / 113 modules / 0 JSON errors |
| TN-C | Complete full suite with frozen inputs, native MCP, inspect and explicit stop | 5389 tests / 22905 subtests in 1182.91s; 18 native checks true; 0 actual errors / 68 warnings |
| TN-D | Editor, deterministic replay and exact staged scope | Editor exit 0; 114 raw hashes unchanged; index-final.log records final staged whitespace/allowlist audit |

## Behavior and cohesive module ownership

Existing SourceWorldTerrainRuntimeState applies changes to the one actual source_world_tiles container, looks up the existing Building identity through placed_blocks, and calls the canonical live Drill proximity owner. No new runtime module or persistent registry was created. SourceContentRegistryRuntimeState's world-scoped typed Item view and SourceDrillRuntimeState's canMine/countOre remain the sole Item/selection owners.

SourceBlockGeometry now has one small tile_floor_assignment_state used by the live floor adapter and by the existing descriptive tile_set_floor_state in the working tree. It owns identity guard, resulting Floor reference and changed-floor/Building notification predicate. The old descriptive function delegates those three outputs; there is no duplicated assignment formula. The live adapter does not pass invented headless, renderer, editor, event or pathfinder state merely to get a Building guard.

## N2023 — floor assignment and actual notification

Tile.java setFloor first returns when the same Floor reference is supplied. Otherwise it assigns this.floor and calls build.onProximityUpdate when a Building exists. That notification has no world.isGenerating guard. The live setter accepts only the inputs it consumes: actual game, x/y and typed Floor reference. A no-op preserves identity and does not recompute the frame.

Renderer floor indexes, recache, events, pathfinder and Floor.floorChanged callbacks are separate source behaviors. In particular TiledFloor and ColoredFloor override floorChanged to handle data bytes. This batch does not claim those effects, infer their inputs or execute a base no-op in place of an override. Non-Drill Building proximity overrides and superclass noSleep/group lifecycle remain separate.

## N2024 — quiet overlay and canonical clear

setOverlayQuiet composes the existing canonical overlay mutation owner and always assigns the supplied reference, without an identity guard, recache or proximity notification. It is a void mutation; no invented result wrapper is registered. A later normal tick does not silently reselect ore.

clearOverlay delegates canonical air, resolved by the existing source field identity, into normal setOverlay. It inherits normal identity and generating guards. There is no parallel clear formula, block-name allowlist or guessed air definition. Both use the same actual Tile dictionary and Building frame.

## N2025 — ordered floor/overlay receiver

The existing SourceBlockGeometry.tile_single_mutation_state recipe describes Tile.setFloor(Tile, Block, Block): floor.asFloor assignment first, setOverlay second. The live receiver executes that recipe's two calls in order through the same actual mutation adapters. A floor-default composition supplies canonical Blocks.air to that receiver, matching setFloorNet(floor, Blocks.air).

These are local application/composition boundaries, not RPC transport, authority or multiplayer acceptance. Inputs must already be resolved typed Floor/overlay definitions; this batch does not claim complete Block.asFloor validation or unsupported Floor subclass effects.

Generation makes order observable: the floor change notifies immediately while the old copper overlay remains, selecting four copper cells; the following overlay clear is applied without notification, so the stored count stays four until explicit proximity recomputation observes three. Reversing the calls would select three immediately and fails the independent native proof.

## Runtime cases and actual production

The actual Main scene's default Drill footprint is cleared through the normal clear API. A floor-only change introduces source sand and updates the same frame; identity-equal sets do nothing. A proxy cell floor change updates that one Building frame. Quiet copper overlay changes actual terrain while sand remains selected, including across an actual process tick; explicit proximity selects copper. Normal clear reselects sand and a second clear is an identity no-op.

The ordered generating receiver proves both assignments, immediate floor notification, deferred overlay notification and source call order. An explicit recompute then observes the resulting terrain. Floor-default composition clears the overlay after floor mutation. An unoccupied Tile changes floor without creating a Building.

Finally the actual footprint becomes sand-only. With the legacy ore map cleared and old global output slug still copper, forced progress through the real game process produces two sand and no copper. Registry and one-headquarter checks are true. This is live field/Drill behavior, not just a source-text state description.

## SSOT, staging and reproducibility limits

Same-slice additions: **37 symbols / 5 Dictionary-result contracts / 11 schemas / 3 slices**. Totals: **10047 symbols / 1480 slices / 1369 contracts / 2534 schemas** in the authoritative working catalogs. Expanded validation is 113 modules, direct extension manifest 100. Content and its generated GD remain unchanged at 425 blocks. All preexisting root records, manifest and canonical source audit are preserved. Exact anchors for all 37 added symbols match Tile.java; nested schema references resolve.

A discarded draft input, source_world_drill_floor_input.generating, was removed from the new uncommitted namespace before full acceptance because the scoped floor adapter deliberately has no generation gate or unrelated context input. No preexisting symbol was removed. The same-slice registrar is deterministic from the final canonical definitions.

Important C12 debt found during exact index audit: several descriptive Tile geometry functions and their source-text/owner-registry extraction currently exist only in the preexisting dirty working tree. HEAD lacks those complete functions. New live terrain APIs reuse that working canonical owner; earlier accepted live overlay code already had the same dependency. This batch does not bulk-stage the unrelated extraction or claim a runnable clean checkout.

Exact staging places the new shared floor helper in HEAD's existing SourceBlockGeometry module and adds the live terrain mutations to its existing world terrain owner. The working descriptive tile_set_floor_state delegation change is preserved in the preexisting extraction; it must be adopted with that whole existing owner in C12. Dependency inventory must include tile_set_floor_state, tile_overlay_mutation_state and tile_single_mutation_state, their SourceTileSetFloorSourceTextState/SourceTileOverlayMutationSourceTextState dependencies and corresponding owner constants. Do not independently reimplement those functions to make HEAD pass. This report explicitly limits acceptance to the verified working tree.

Focused: 14/93 in 96.19s. Full: 5389/22905 in 1182.91s, exit 0; hashes for all 1838 preexisting source/test/catalog inputs unchanged across the run. Native: 18/18, matches=true, 68 warnings, zero actual errors; inspect and explicit stop retained. Editor exit 0. Replay: 114 raw hashes unchanged. Catalog zero errors. Exact index/whitespace gate runs after staging its own log, avoiding the prior audit-log newline issue. No push/amend; unrelated dirty work remains preserved.

## Next C01 checkpoint

Actual terrain notification for the supported Drill subset now includes floor, overlay quiet/clear and ordered floor/overlay composition. Continue actual Building removal/overlap and proximity invalidation. Source Tile.preChanged resets the entire old multiblock from the old Building center, Tile.changeBuild removes the old entity and updates edge entities, and Tile.setBlock clears overlaps in a first pass before proxy assignment in a second pass. Reuse existing canonical geometry/edge/lifecycle owners, and bind domain cleanup rather than merely erasing one placement key or calling queue_free.

Source BuildingComp.removeFromProximity/updateProximity require real proximity and team context; superclass noSleep requires actual sleep/group state. Existing turret unregister and power graph removal owners must be wired when applicable. Actual controller pickup, world transitions and remaining Floor data/event/render/pathfinder behavior remain open. C02–C12 remain open; no group-wide acceptance or parity percentage follows from these counts.

Evidence: `evidence/2026-11-02-terrain-mutation-lifecycle/`.
