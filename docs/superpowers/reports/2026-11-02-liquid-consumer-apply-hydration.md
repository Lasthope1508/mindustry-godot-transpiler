# Liquid consumer apply capability and filter hydration — N2004–N2006

Date: 2026-11-02. Parent: `28dbf074`. This batch connects the supported direct single-liquid descriptor view to source-backed apply effects before building LiquidModule allocation. It preserves original content properties and keeps one applied view on each Block. Full consumer initialization, production callbacks and automatic resource ticks remain open.

## Checkpoints

| Gate | Requirement | Status |
| --- | --- | --- |
| LA-A | Read source, SSOT and handoff; confirm RED | Expected RED: 5 failures / 1 passed in 11.84s, including 3 missing-contract subtests, missing placement ordering and missing runtime APIs |
| LA-B | Canonical projections and actual placement integration | Focused: 11 tests / 16 subtests in 60.31s; legacy: 5 tests / 3 subtests in 0.63s; pre-full catalog: 0 errors / 113 modules / 0 JSON errors |
| LA-C | Complete suite and final native/editor proof | Accepted: 5361 tests / 22630 subtests in 1043.57s; native matches=true, editor exit 0 |
| LA-D | Replay, exact index scope and checkpoint commit | Accepted: 12 file hashes unchanged; scope and final index audit retained in evidence |

## Source and canonical ownership

`ConsumeLiquidBase.java:16–19` unconditionally assigns `block.hasLiquids = true`. That statement does not read the previous value. `ConsumeLiquid.java:25–29` invokes the base apply, then assigns `block.liquidFilter[liquid.id] = true`. Both effects occur for optional/booster consumers and consumers with `update=false` as well as required update consumers.

`Block.java:1444–1455` builds its consumer arrays, allocates filters using typed content counts, then applies every consumer. `Block.java:1481–1494` repeats the relevant initialization during reinitialization. This batch implements a lazy, immutable-load projection of the supported direct single-liquid subset. It does not implement live reinitialization, or claim that unrelated inherited/mixed consumer effects have run. `BuildingComp.create` conditionally allocates LiquidModule from the Block's effective `hasLiquids`; the existing N2001 allocation owner remains responsible for that frame.

### N2004 — unconditional capability projection

`SourceConsumeLiquidBaseState.source_apply_capability_state()` returns only `block_has_liquids_after`. The existing `apply_state(bool)` keeps its signature, before-value evidence and owner metadata, and delegates the assignment result to this new canonical projection. There is one assignment implementation in this owner.

The new projection deliberately has no before-value input. Missing constructor metadata never becomes a fabricated `false` just to call an older bool boundary. Known false, known true and absent constructor capability all receive the same unconditional source-backed after-value when a supported consumer is applied.

### N2005 — filter assignment projection

`SourceConsumeLiquidState.source_apply_filter_state(liquid_filter_before, liquid_id)` owns the existing duplicate-and-set filter projection. The legacy `apply_state(bool, Array, int, Callable)` delegates that part to the same method, retaining its existing base callback and public result shape. Existing set bits are preserved; the supplied before array remains unchanged. Production code uses the resolved typed ordinal from N2003, without a content-name allowlist or guessed ID.

These two projections keep capability assignment and filter assignment within their existing source domain owners. No new production file or manifest module is introduced. Consumer mirror `generated_owner` fields refer to the existing generated `java_method_apply_0` owners; those generated methods retain their established legacy delegates. The new APIs are partial-input projections rather than new generated Java methods.

### N2006 — shared applied Block state and placement ordering

`SourceConsumeLiquidState.source_apply_liquid_consumers_state(block, content_catalog)` requires at least one resolved direct ConsumeLiquid descriptor. It reuses N2003 binding, obtains typed content sizes, and initializes the filter through `SourceBlockInitItemLiquidFiltersState.item_liquid_filters_state`. Every supported descriptor contributes capability and its filter bit, including zero-rate, optional and update-disabled descriptors. The result `{has_liquids, liquid_filter}` is cached on the Block under registered `SOURCE_BLOCK_LIQUID_APPLY_META_KEY`.

This `liquid_filter` is the union for the supported direct single-liquid subset. Other consumer factories, inherited consumers and unresolved expressions may contribute additional bits later. It must not yet be used as the complete mixed-consumer rejection/acceptance policy. Initializing an array here does not establish complete Block.init or item-filter behavior.

Coverage audit of the current source-derived registry: 53 descriptors across 49 Block definitions; 19 already have source-explicit `hasLiquids=true`, 30 have no constructor capability metadata, and none have explicit false. Those 30 definitions can now obtain an evidence-backed effective capability when placed. The live proof checks electrolyzer; this count does not claim that all 30 Block types have been exercised in gameplay. Explicit false behavior is independently covered by a typed fixture.

`PortGame.record_placed_block` binds and applies the supported descriptor view before invoking existing conditional building allocation. `SourcePlacedBlockState.source_block_has_liquids_state` reads the applied Block capability first, and otherwise retains its required source-explicit constructor-property path. Missing both sources remains unresolved. Source content properties are not overwritten. There is no second per-building liquid amount frame and no resource consumption formula in placement.

The apply cache has Block lifetime and is shared across buildings. The LiquidModule frame keeps Building lifetime and is independent for every building. This batch does not make repeated calls to N2001 allocation idempotent for the same already initialized sprite; placement still owns one create event. Runtime content reload, consumer mutation and reinitializeConsumers require explicit source-backed invalidation before reusing the cache.

## Independent proof

`LiquidConsumerApplyHydrationProof.gd/.tscn` verifies:

1. Unconditional capability after-value, while the legacy API preserves both false and true before-values.
2. A filter with an already-set unrelated bit retains that bit, adds the requested bit and leaves the input array unchanged; the legacy apply API agrees.
3. Absent/false/true source capability fixtures each become liquid-capable without changing their source dictionaries. Two distinct Java fields resolve through different content slugs to ordinals 0 and 2, producing `[true, false, true]`. One descriptor is optional, zero-rate and `update=false`, so apply cannot be incorrectly gated by those flags.
4. Repeated apply shares both dictionary and filter-array identity on the Block.
5. The actual Main scene enters campaign, then two actual placement calls use the real catalog `electrolyzer` Block whose constructor metadata lacks `hasLiquids`. Its water filter is sized from the real catalog, and only its supported water bit is set. Both placed sprites receive LiquidModule frames. Writing water=3 into the first leaves the second at zero; frame identities differ. The original Block properties remain unchanged.
6. Registry validity and one-headquarter-per-SSOT remain true.

The fixture coordinates and liquid quantities are explicit proof inputs. They are not production defaults. This proof calls actual placement and validates allocation; it does not claim automatic drilling, production consumer update dispatch, complete mixed-consumer filters or full Mindustry parity.

## SSOT, scope and validation

- Three slices N2004–N2006; ledger becomes **1461**.
- Three contracts, five schemas and nine symbols. The no-input capability projection requires no empty input schema; its result schema is registered.
- Schemas alias established apply/input/catalog definitions rather than repeating source defaults.
- Consumer mirrors gain N2004/N2005 and their contracts; Block mirrors gain N2006 and its contract, regenerated in dependency order through existing manifest selection.
- No content registry, manifest, audit policy, alias graph or module count change. Existing root entries remain unchanged.
- Initial RED is archived in compressed form because unittest printed the entire contract dictionary. Its failure summary and SHA256 accompany the raw log archive. The assertion was made concise without weakening the check.
- An empty input-schema registration attempt and a missing required consumer-mirror `generated_owner` were caught before focused acceptance. The final script omits the empty schema and supplies actual existing generated owners; manifest selection was not changed.
- Full suite: **5361 passed / 22630 subtests passed in 1043.57s**; complete output retained in `full.log`.
- Final native MCP: **matches=true**, all proof checks true; explicit stop verified. Debug and stop inspected for actual errors: **0**, with **66 compiler warnings** retained. Raw MCP errors arrays therefore contain warnings. Editor parse: **exit 0**, no actual errors. Native logs, proof summary and editor output are retained.
- Registration replay: **12 raw SHA256 hashes unchanged**, including manifest/audit/content. Final catalog: **0 errors / 113 modules / 0 JSON errors**, all nine category counters zero.
- Exact index scope: only this batch's root additions and runtime deltas, new registration/test/proof files, checklist/report and evidence; prior entries/policies and unrelated refactors preserved. Final staged whitespace and index audit pass; see `index-final.log`.

The working tree contains extensive changes predating this batch, including facade delegation and source-text extraction. Before snapshots and semantic/text deltas isolate this batch. The index uses HEAD plus only these deltas; unrelated working-tree code is not silently included. Suite/runtime proof applies to the canonical working tree used for migration, not an asserted clean-checkout certification of unrelated uncommitted refactors. Project settings, `.gd.uid`, arc-upstream and the unrelated facade refactor stay outside this commit.

Evidence: `evidence/2026-11-02-liquid-consumer-apply-hydration/`.

## Reproduction

From this repository root, run registration, focused tests and the complete suite in order:

```powershell
python tools/mindustry_godot_transpiler/register_liquid_consumer_apply_hydration.py
python -m pytest -q -p no:cacheprovider tools/mindustry_godot_transpiler/tests/test_liquid_consumer_apply_hydration.py tools/mindustry_godot_transpiler/tests/test_liquid_consumer_hydration.py tools/mindustry_godot_transpiler/tests/test_placed_liquid_ownership.py --tb=short
python -m pytest -q -p no:cacheprovider tools/mindustry_godot_transpiler/tests --tb=short
```

After the full gate completes, launch `tools/runtime_proofs/LiquidConsumerApplyHydrationProof.tscn` through native Godot MCP using this checkout's `godot-mindustry` project. Inspect actual error lines separately from compiler warnings; explicitly stop and inspect final output. Run editor parse, deterministic registration replay and final cross-catalog validation. Do not regenerate catalogs while the full suite reads them.

## Handoff: next dependency checkpoints

1. **Concrete production adapter:** N2003's typed descriptors and N2006's applied capability are ready for the supported subset. Resolve source multiplier callback behavior before constructing callable consumers. `Consume.java:18` defines the cost callback `multiplier = b -> 1f`; `Consume.java:60–61` defines the separate `efficiencyMultiplier(Building)` method. The existing `SourceConsumeState.efficiency_multiplier_state()` owns the latter; do not treat it as the cost callback merely because both defaults equal one. Bind the Building's existing frame by reference. Reuse LiquidModule get/remove, ConsumeLiquid efficiency/update, Building edelta and consumption orchestration. Retain optional/booster/update/ignore classification. Dictionary descriptors still do not implement update callbacks.
2. **Automatic Drill behavior:** inspect exact Drill shouldConsume/item capacity/dominant item/enabled predicates, validity and efficiency/boost timing. Empty water removes the optional boost while valid base drilling continues. Prove real game-driven multiple ticks, disabled/full-output guards, clamp behavior and separate buildings; do not substitute manually invoked test callbacks.
3. **World traversal prerequisite:** the previous report's `placed_block_origins` mismatch remains open. Canonical placement maps occupied cells to origins and sprites; origins are not unique sprite instances. Add multi-cell/two-building RED evidence and fix dispatch through the canonical placement owner before automatic ticks. Do not add a second building registry.
4. **Complete initialization coverage:** inherited/mixed consumers, thorium-reactor's variable amount, capacity calculation and other Block.init effects remain open. Supported filter bits are partial evidence; no complete filter claim or missing-metadata empty list fallback. Runtime mutations/reload must invalidate both descriptor and apply caches through one source-backed lifecycle.
5. **LiquidModule continuation:** flow/static cache lifecycle, capacity/acceptance, serialization and callbacks remain separate source-backed slices. Preserve Block configuration versus Building quantities.
6. **Acceptance discipline:** 1–3 coherent slices; RED, focused, JSON/catalog, complete suite, final native proof/error inspection/stop, editor, replay, checklist/report and exact commit. Preserve all previous dirty files with before/after evidence.
