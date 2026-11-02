# Drill proximity, typed dominant Item and production — N2020–N2022

Date: 2026-11-02. Parent: `9bfecb91`. Sequential C01–C12 goal, C01 assignment/proximity/output batch. This accepts the stated partial lifecycle, not the whole of C01 or full Mindustry parity. C01 and C02–C12 remain open.

## Checkpoints

| Gate | Evidence | Status |
| --- | --- | --- |
| DP-A | Read checklist/root SSOT/manifest/shards/exact Java; RED before implementation | 4 expected failures / 1 pass, 12.17s |
| DP-B | Focused/facade/audit and catalog | 17 tests / 44 subtests, 111.65s; 0 errors / 113 modules / 0 JSON errors |
| DP-C | Complete full suite with inputs frozen; native MCP, inspect and explicit stop | 5386 tests / 22848 subtests, 1156.75s; 22 native checks true; 0 actual errors / 68 warnings |
| DP-D | Editor, deterministic replay and exact semantic index | Editor exit 0; 114 raw hashes unchanged; exact allowlist audited in evidence/index-final.log |

## Problem and resulting behavior

The old live tick scanned ore_items_by_cell every frame, rejected mixed footprints, stored an Item slug and overwrote dominant fields. That defeated canonical countOre/proximity behavior. Primary factory output also used the global copper display slug regardless of the Building's dominant Item.

A placement now initializes and assigns the existing Building frame from real Tile facts. Supported overlay mutations recompute that same frame through the canonical Tile mutation guard and Drill countOre owner. Ticks consume the stored dominant Item/count without scanning the world or legacy rendering map. Actual primary offload and secondary local inventory use the canonical Item name resolved by numeric id. No new production runtime module, block-name allowlist, selection registry or arithmetic formula was introduced.

## Module responsibilities and source anchors

| Owner | Responsibility | Source |
| --- | --- | --- |
| SourceDrillRuntimeState | getDrop delegates supplied canonical Tile.drop; canMine/countOre use that adapter; proximity assignment composes countOre; pickup clears only Item | Drill.java getDrop, countOre, DrillBuild.onProximityUpdate/pickedUp |
| SourceContentRegistryRuntimeState | Existing typed Item view, numeric registration order, hardness and lowPriority | ContentLoader/Content/Item, accepted N2011 |
| SourceWorldInitialBuildRuntimeState | Create one world-scoped typed Item view before recording placements | Existing world/bootstrap and content providers |
| SourceDrillConsumptionRuntimeState | Bind actual placed Drill frame; retain Item identity; use actual name for getDrillTime/output; no per-tick selection | DrillBuild.onProximityUpdate, updateConsumption/updateTile |
| SourceWorldTerrainRuntimeState | Apply actual overlay mutation and supported Drill notification through existing Tile owner | Tile.setOverlay; existing SourceBlockGeometry.tile_overlay_mutation_state |
| SourceFactoryRuntimeState | Feed primary offload/dump the selected Item name; guard nullable Item and zero amount | Drill.updateTile offload(dominantItem); existing inventory/dump composition |

The world-scoped source_item_catalog is a typed view of existing canonical content, treated as readonly. It is rebuilt by build_world before placements and reused for Item references, blocked binding and name lookup. It is not a second content or ore-selection owner. Existing source_world_tiles stores terrain; placed_blocks remains the Building identity index.

Eligibility for proximity assignment uses blockedItems metadata exported through source Drill ancestry. Separate BeamDrill behavior is not dispatched as base Drill. The live tick retains its previous explicit base-Drill/direct-liquid/no-power subset; BurstDrill production and electric Drill are not claimed.

## Source-exact scope and boundaries

N2020 implements return tile.drop(), dominantItem = returnItem, dominantItems = returnCount and pickup's dominantItem = null. Pickup preserves count, progress and other fields. The pure assignment function deliberately does not pretend to implement superclass BuildingComp.noSleep or group membership. No sleep state is fabricated from false/zero placeholders.

N2021 binds those assignments into real default-world placement and overlay changes. Identity-equal overlay sets are no-ops. Tile.setOverlay defers build notification while generating; explicit end-of-generation proximity recomputes. Proxy cell lookup reaches the same Building. This batch does not implement recache/render updates, Events.fire, other Building overrides, floor changes, complete overlap/removal or automatic map-end/controller pickup dispatch. Helpers expose those narrow supported boundaries honestly.

N2022 removes live per-tick legacy scanning and resolves actual dominant Item through the shared canonical id-to-name array. Primary offload still uses the existing legacy inventory bridge, while secondary output remains the explicitly deferred C02 local-inventory path. Dump-any/null semantics are not added: the existing String-only dump call is skipped for a null dominant Item. That remains a documented source parity gap, not a fabricated replacement for upstream dump(null).

## Independent runtime cases

The actual Main scene bootstrap selects copper from the 2 ore cells under its default size-2 Drill. A second real placement selects lead from four real Tiles, with a distinct frame and shared Item facts. Overlay changes exercise 3:1 count, 2:2 numeric-ID tie, proxy identity, generating deferral, explicit recomputation and identity no-op.

The primary is then changed to lead while the legacy global output slug stays copper. With no offload neighbors, forced progress makes both actual Buildings produce two lead and no copper. Clearing ore_items_by_cell does not change selection. Direct raw Tile mutation without notification also does not trigger a tick re-scan. Clearing actual overlays resets null/zero and stops production. Pickup retains count while null remains across ticks. Registry and one-headquarter invariants stay true.

DrillLiveConsumptionProof was migrated from out-of-world (100,100) legacy-map fixtures to an actual in-bounds second Drill and Tile overlay mutation. All existing liquid accounting, optional/partial/dry behavior, disabled/full/no-ore guards, timescale, autonomous processing and adapter/storage identity assertions remain. The proof was not weakened to keep the old scanner passing.

## Registration, verification and staging

Same-slice additions: **25 symbols / 6 Dictionary-result contracts / 13 schemas / 3 slices**. New void pickup helper has an input schema/source symbols without a fabricated result. Root totals: **10010 symbols / 1477 slices / 1364 contracts / 2523 schemas**. Content remains 425 blocks; manifest remains 100 direct extension entries, 113 expanded validated modules. Existing root records and canonical audit are unchanged. Every added symbol's exact source expression matches its upstream file; nested schema references for the new records resolve to existing schemas.

Focused final: 17/44 in 111.65s. Complete full: 5386/22848 in 1156.75s, exit 0; all 1836 preexisting source/test/catalog inputs have unchanged hashes across the full run. Native MCP: 22/22 checks true, matches=true, 68 warnings and zero actual errors; debug and explicit stop inspected. Editor exit 0. Replay: 114 registered JSON/content raw hashes unchanged. Catalog zero errors.

An earlier facade gate finished with 6 failures / 2334 passes / 2376 subtests in 322.88s: assertions still required the former inline amount extraction. Repair gate then caught one additional stale dump guard expectation. Those expectations now assert the actual selected-Item/guarded call shape. The accepted focused and full gates ran after the repairs. Both failed focused logs are retained compressed, never counted as accepted results. No failed full gate occurred in this batch.

The working tree contains a substantial preexisting facade/source-text extraction. Exact semantic staging maps this batch's source_item_catalog field and placement hook from existing working bridge files into their same existing functions/state in HEAD PortGame. Shared modules and the six affected facade assertions are staged as contextual changes only. Prior records, unrelated facade work, project.godot, UID files, arc-upstream and content/manifest changes are excluded. No push/amend. Working-tree gate evidence is not a clean-checkout acceptance claim; C12 remains open.

## Next checkpoint

Continue C01 with canonical floor mutation notification and actual Building removal/overlap/proximity invalidation. Reuse SourceBlockGeometry.tile_set_floor_state, tile_pre_changed_state/tile_change_build_state/tile_changed_state and existing placement/removal owners before adding code. Floor notification differs from overlay: it runs even while generating. Source noSleep belongs to SourceBuildingAccessState; bind actual state/group lifecycle before claiming full superclass behavior.

Then complete C02 per-Building offload/dump/transport and nullable dump-any semantics, removing secondary local fallback and global primary inventory ownership only through a source-backed composition. Keep C03–C12 in dependency order. Do not label all 12 groups complete from this batch or infer parity percentage from slice/test counts.

Evidence: `evidence/2026-11-02-drill-proximity-lifecycle/`.
