# Executable Building proximity and Tile pre-change — N2026–N2028

Date: 2026-11-02. Parent: `fb25c7d9`. Sequential C01–C12 goal. This batch accepts executable mutation primitives on real object/Tile references in supplied contexts, including a bounded application to the actual Main Tile store. It does not accept automatic complete Main removal/overlap, C01 as a domain, or clean-checkout reproducibility.

## Checkpoints and evidence

| Gate | Evidence | Status |
| --- | --- | --- |
| PR-A | Checklist/five roots/manifest/all shards/upstream read; RED | 5 expected failures / 1 pass in 12.08s; extra order regression failed on stale Tile snapshot |
| PR-B | Focused tests and catalog | 21 tests / 5659 subtests in 64.63s; 0 catalog errors / 113 modules / 0 JSON errors; 33 exact source anchors |
| PR-C | Full suite with frozen inputs; native MCP, inspect and stop | 5397 tests / 22981 subtests in 1212.78s; 23 native checks true; 0 actual errors / 68 warnings |
| PR-D | Editor, deterministic replay, exact index | Editor exit 0; 114 raw hashes unchanged; exact staged allowlist and whitespace audit follows staging of its own log |

## Ownership and actual API boundary

SourceBuildingLifecycleProximityState gains source_apply_remove_from_proximity and source_apply_update_proximity. They mutate the original persistent proximity arrays and retain original Building/Team object identities. Callers provide actual world.build lookup, proximity access, Team access and lifecycle hooks. The primitive does not manufacture an empty proximity, a team, noSleep state, power graph or no-op fallback. Existing SourceBlockPlanGeometryState.edge_points_state remains the one edge geometry owner.

SourceBlockGeometry.source_apply_tile_pre_changed executes the existing tile_pre_changed_state reset/event plan, tile_fire_change_state generation guard and linked footprint traversal. No new runtime module, registry, persistent cache, block-name allowlist or alternative geometry formula is introduced. Canonical Blocks.air is supplied as a resolved object, never assigned as the descriptive string marker.

These are real source void operations. All 33 input symbols, three input schemas and three explicit void contracts register in the same slices. The catalog now supports return_type=void with empty return_keys, while preserving the existing nonempty-key requirement for Dictionary contracts. Cross-catalog validation requires an actual explicit -> void implementation and still checks owner, slice, params/schema, proof and tests. Nested/multiline/default-string signatures are tested; a Dictionary or untyped implementation cannot use the void exemption.

The first full attempt exposed missing comp API contracts; its failed pytest child was deliberately stopped after a targeted reproduction proved the failure. Frozen inputs remained unchanged. That attempt is not an accepted full gate. New void-validator RED cases failed before the implementation; the final successful full gate above supersedes it. No test expectation was weakened to exclude void slices.

Mirror semantics preserve the explicit type through a generic optional_mirror_fields manifest capability. Only comp_api_contracts enables optional return_type in this batch. Canonical absence stays absent for legacy contracts; missing, changed and invented optional fields are rejected. Invalid optional-field declarations are rejected. The comp mirror is regenerated rather than edited, and all existing contract records remain unchanged.

## N2026 — removeFromProximity

Call onProximityRemoved once before collecting edge entities. Resolve edges from the Building origin and old Block size through the existing geometry owner. Deduplicate original Building references. Removal includes neighbors from other teams. For each unique neighbor, remove this exact Building reference from its actual proximity array, then call its onProximityUpdate. Clear the removed Building's own proximity only after those neighbor hooks finish.

The proof distinguishes hook timing from final state: onProximityRemoved sees links still present; each neighbor hook sees its link removed while the removed Building's own list remains intact. Duplicate edge references produce one notification. No ordering between different unique neighbors is claimed: upstream uses ObjectSet.

## N2027 — updateProximity

Clear the original own array, scan actual edge lookups, exclude null and different Team identities, and add this Building uniquely into each neighbor's persistent proximity. Deduplicate neighboring Building references, populate the own list, then call self onProximityAdded, self onProximityUpdate, and each unique neighbor's onProximityUpdate. Finally execute recache only when explicit actual headless/drawCached context permits it.

Cases prove stale-list replacement without replacing the array, bidirectional links, distinct Building objects with equal fields, other-Team exclusion, duplicate-edge deduplication, repeated update idempotence, all recache guard combinations and empty/bounded-world self hooks. Callback probes verify graph visibility and ordering; they do not prove real power/noSleep integrations.

## N2028 — Tile.preChanged

Fire the mutation Tile's canonical pre-event unless generating. For a previous Building, call onRemoved then removeFromProximity. Traverse the old Building footprint from its actual center and initialized size/offset, excluding only the mutation Tile. Each proxy fires its pre-event, clears build and assigns actual air, then fires its changed event. During generation, hooks/assignments still occur and events are suppressed. The mutation Tile retains its old Building for the later changeBuild phase.

The implementation streams lookup and reset in source dx/dy order. A regression test replaces one Tile in onRemoved and a later Tile in an earlier changed-event callback. Both newly looked-up Tiles must be reset while the stale replaced objects remain untouched. A footprint snapshot before callbacks failed this test and was replaced; this is retained in order-red.log.gz.

Cases cover proxy rather than center mutation, size-three odd footprint, clipped bounds, unoccupied mutation, exact event bracketing and generation. The actual Main scene case explicitly binds the existing Drill Sprite reference into its existing canonical Tile dictionaries and invokes the primitive; all old footprint cells except the clicked proxy reset, and the old Sprite remains available for changeBuild. This explicit supplied binding is a proof fixture, not production automatic placement wiring or complete entity removal. The game stops before any inconsistent partially removed state is ticked.

## SSOT and preservation

Delta: **33 symbols / 3 input schemas / 3 void contracts / 3 slices**. Working totals: **10080 symbols / 1483 ledger records / 1372 contracts / 2537 schemas**. Content remains 425 blocks. Extension manifest remains 100 direct modules; expanded validation remains 113. All previous root records, policy/configuration, canonical audit and content are preserved. Manifest changes only by enabling optional return_type for the affected comp contract mirror; its entry mirror is regenerated too.

All 2331 frozen source/test/catalog/scene/proof-script inputs were unchanged across full verification. This snapshot includes Main scenes and proof .gd/.tscn inputs as well as project.godot; generated proof JSON outputs are not inputs. Replay is deterministic. Existing dirty workspace files remain intact.

## Exact staging and C12 dependency limits

The proximity owner already exists in the preexisting uncommitted extraction, while HEAD has the old descriptive helpers in SourceBuildingLifecycleState. Stage only the cohesive new executable methods in that same owner path, without adopting the unrelated descriptive/source-text extraction. Geometry stages only this batch's executable method appended to the existing HEAD module. The verified working file retains all existing descriptive helpers and dependencies.

Parent HEAD still lacks the existing SourceBlockPlanGeometryState.edge_points_state owner and several Tile geometry helpers used here. dependency-inventory.json records this exact debt. C12 must adopt the real existing canonical owner graph and reconcile the facade delegation as a coherent cluster; do not write competing formulas to make isolated HEAD fragments runnable. These gates establish working-tree acceptance only.

The parent HEAD also lacks the working cross-catalog validator. This batch deliberately adopts the complete existing canonical Python owners source_symbols.py and source_ssot.py, including their prerequisite alias/linkage/selection logic, together with typed void and optional mirror support. A validator fragment depending on unstaged validator internals would not be a coherent commit. This two-module infrastructure adoption is explicit, exact and covered by focused/full gates; other preexisting dirty files remain preserved.

## Remaining C01 work and next batch

Bind actual Building/proximity/Team state at production placement and world reload. Compose these registered primitives into Tile.changeBuild and full two-pass Tile.setBlock: preChanged on the old footprint, old entity/group removal, null mutation Tile build, unique edge updateProximity, optional new entity initialization, then overlap clear pass before proxy assignment pass. Keep actual event/renderer/pathfinder context and lifecycle ordering.

Superclass noSleep must use actual sleepTime/sleeping/group membership/sleepingEntities. Power onProximityRemoved/Added and turret unregister require actual domain hooks; these callback probes are not their acceptance. Controller pickup/world transitions and remaining Tile/Floor side effects stay open. C02–C12 remain open. No whole-domain acceptance or parity percentage is inferred from ledger counts.

Evidence: `evidence/2026-11-02-building-proximity-mutation/`.
