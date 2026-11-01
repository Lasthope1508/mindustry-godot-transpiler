# Single-liquid consumer descriptors and shared Block hydration — N2002–N2003

Date: 2026-11-01. Parent: `05fd5d87`. This checkpoint exports direct `consumeLiquid` constructor/selector definitions from Java content and resolves them into one shared typed descriptor view per Block during actual placement. Consumer apply/filter effects, full mixed consumer initialization, multiplier callbacks and automatic Drill consumption remain open.

## Checkpoints

| Gate | Acceptance requirement | Status/evidence |
| --- | --- | --- |
| LC-A | Exact source/SSOT review and expected RED | Four new test methods: six expected failures including two contract subtests |
| LC-B | Source descriptor extraction without gameplay literals | 53 direct calls / 49 blocks exported; one thorium-reactor call explicitly unresolved |
| LC-C | Typed Block-owned hydration and independent runtime checks | Accepted: focused 16 tests / 13 subtests; native MCP matches=true, all eight boolean checks true |
| LC-D | Full suite, final native/editor, replay, exact commit | Accepted: full 5358 tests / 22607 subtests; native/editor, 13-file replay and final catalog pass; exact staged scope verified in index-final.log |

This closes the descriptor/read/binding portion of the previous handoff's CP-PO2. It does not close all production consumer hydration or CP-PO3 automatic ticks. Block descriptors and building LiquidModule storage have different owners and lifetimes.

## Source evidence and module ownership

### N2002 — direct source definitions

The existing `mindustry_port/content_registry.py` extractor emits `properties.consumeLiquid` only when all direct single-liquid calls in that block's initializer can be resolved. `SourceConsumeLiquidState.source_liquid_consumer_definitions_state(block)` exposes that ordered constructor-input view as `consume_builder`. The property must exist; no empty-list fallback is used for unresolved metadata.

Source anchors:

- `content/Blocks.java:2865–2875`: mechanical drill's `consumeLiquid(Liquids.water, 0.05f).boost()`.
- `content/Blocks.java:2877–2884`: pneumatic drill's distinct `3.5f / 60f` expression.
- `world/Block.java:1127–1128`: factory calls `consume(new ConsumeLiquid(liquid, amount))`.
- `world/consumers/ConsumeLiquid.java:17–20`: constructor delegates amount to its base and assigns its Liquid field.
- `world/consumers/Consume.java:27–39`: ordered optional/booster/update assignments; `.boost()` returns `optional(true, true)`.

The parser uses the existing Java tokenizer/parser, so comments are excluded before calls are considered. It accepts standalone calls in the initializer's root scope, a `Liquids` static field reference, numeric literal/division expressions, and literal `.boost()`, `.optional(a,b)` and `.update(a)` selectors in source order. Zero amounts remain zero. Integer division retains truncation for integer operands; existing numeric-literal conversion is reused. This metadata checkpoint does not claim exhaustive Java float32 bit parity for arbitrary expressions.

It rejects variable/function amounts, assigned calls, nested conditional calls, unknown selectors, nonliteral/negated boolean flags and consumer mutation through `consumeBuilder`, `findConsumer`, `removeConsumer` or `removeConsumers`. If any direct call is unresolved, no partial `consumeLiquid` array is emitted for that block. Absence means unresolved or outside this source view, not proof that the Block has no consumers.

Java field names are preserved exactly. The parser does not turn an identifier into a guessed slug and does not maintain a block-name/liquid-name allowlist. Source rates and selector values are stored in generated content rather than gameplay callbacks. Omitted optional/booster/update flags stay omitted; the existing canonical Consume classifier interprets its already registered defaults.

Coverage against actual declared block initializers:

- **54 direct calls in 50 blocks** after comments are excluded.
- **53 calls in 49 blocks** have complete supported direct-call metadata.
- **Thorium-reactor** remains unresolved at `Blocks.java:2618–2629`: `heating / coolantPower` requires variable resolution. No guessed rate or partial descriptor is emitted.
- Constructor-inherited consumers and other factory types, including ConsumeLiquids, filters and power consumers, are not included in this single-liquid view.

Semantic comparison with the pre-turn snapshot confirms that only `consumeLiquid` is added to those 49 canonical block properties. No existing property, other content collection or content count changes. Counts remain 22 items, 11 liquids, 417 blocks and 56 units. All five registered mirrors involved in replay are rebuilt through manifest-defined canonical selection; source selection, rather than the helper class name, determines which domain mirror gains entries.

### N2003 — shared typed Block descriptor view

`SourceConsumeLiquidState.source_bind_liquid_consumers_state(block, content_catalog)` resolves each source field through `content_catalog.get_many("liquid")`, then obtains its numeric ordinal through the existing `SourceContentRegistryRuntimeState.source_liquid_catalog_state` provider. The mapping explicitly supports a Java field name that differs from its content slug. It does not use the mixed-type global `get_by_id` lookup.

The resolver requires a unique typed field match. It calls the existing canonical `constructor_state` and uses its `liquid_after`/`amount_after` representation. The canonical `SourceConsumeState.ignore_state` supplies the inherited ignore result. The source definition remains unchanged; the normalized row retains explicit flags and carries the typed numeric Liquid representation already used by storage/consumer APIs.

The result is cached under the registered `SOURCE_BLOCK_LIQUID_CONSUMERS_META_KEY` on the Block object. Repeated placement of the same type receives the same Array and row identity. This matches Block ownership of consumer configuration: Java stores `consumeBuilder` and `consumers` on Block, not on each Building. Actual liquid amounts remain in the existing per-building LiquidModule frame. No second building amount array or rate formula is introduced.

`PortGame.record_placed_block` adds a guarded call to this binder after its existing placement/storage path. It does not reintroduce cell/sprite orchestration or perform resource consumption. The inherited working-tree facade remains delegated; the index patch adds the same two-line hook to HEAD's existing placement method. Bind only when source metadata exists.

The cached view assumes an immutable loaded catalog and constructor definitions. Catalog reload/reordering, mod content replacement and descriptor mutation require source-backed invalidation before this cache can be reused across those transitions. This checkpoint does not invent a reload policy.

## SSOT and exact scope

- Ledger records N2002 and N2003; total becomes **1458**.
- Two contracts, six schemas and seventeen symbols, including the Block metadata binding.
- Schemas: `source_liquid_consumer_definition`, `source_liquid_consumer_state`, `source_liquid_consumer_definitions_input/result`, `source_bind_liquid_consumers_input/result`.
- Runtime row fields alias existing constructor, optional, update-flag and ignore schemas. The source field-name input is separately registered as source metadata.
- No new production module, manifest module or canonical owner alias. Catalog remains **113 modules**.
- Existing root entries and policy values are unchanged. Audit and manifest files remain unchanged.
- Relevant consumer mirrors are replayed without forcing a new source selection. N2003 belongs to existing Block slice/contract mirrors because its source is Block.java. The content block mirror carries the 49 property additions.

The workspace has pre-existing dirty runtime, schema, Block mirror and facade files. Before/after snapshots isolate only this checkpoint's additions. Dirty JSON is staged by applying the semantic delta to HEAD, preserving previous entries/policies; the existing runtime file receives only the new constant/method block, and PortGame receives only the new hook. Pre-existing facade chains, `project.godot`, `.gd.uid`, `arc-upstream` and unrelated work remain outside the commit. Scope/replay data describes the canonical working tree used by the gates; it does not claim that the unrelated refactor was committed.

## Independent proof

`LiquidConsumerHydrationProof.gd/.tscn` instantiates actual `scenes/Main.tscn`, enters the campaign slice, waits for placement/bootstrap and freezes automatic processing. It inspects the actual mechanical-drill Block:

1. Its descriptor metadata must already exist from placement; the proof cannot create it first and then claim placement integration.
2. A repeat bind returns the identical Array/row; source definitions still contain Java field `water` and amount 0.05.
3. Resolved fields independently match water ordinal 0, amount 0.05, optional=true, booster=true and ignored=false.
4. Existing canonical classification yields one optional, zero required and one automatically updated descriptor from that subset.
5. With the actual descriptor amount and explicit test inputs delta=2, scale=1, multiplier=1, water 0.1 / 0.05 / 0 gives independent expected `[efficiency, optionalEfficiency]` pairs **[1,1], [1,0.5], [1,0]** through existing Liquid/Building calculation owners.
6. A separate fixture maps Java field `coolantJavaName` to content slug `different-content-slug` at ordinal 1. It is required and explicitly `update=false`; the existing classifier must produce one required and zero update entries. This catches field/slug conflation and ignored update flags without a production allowlist.
7. Registry validity and one-headquarter-per-SSOT must be true.

The proof deliberately does not dispatch update consumers, resolve a production multiplier callback or simulate Drill's ore/capacity predicate. Source `BuildingComp.updateConsumption:1998–2002` dispatches update consumers when the building can update and base efficiency is positive, even if the consumer is optional. Do not reuse required-consumer starvation expectations for the optional water booster. Automatic game-loop behavior needs the remaining dependencies below.

## Validation record

- Initial RED: **6 failures in 11.89s**, covering missing extraction, generated metadata, contracts and runtime binding.
- Additional parser RED: two failures for `update(!true)` and mutation via `findConsumer`; fixed by leaving those blocks unresolved. Existing assertions were retained.
- Focused GREEN including prior ownership and three placement architecture regressions: **16 passed / 13 subtests passed in 37.44s**.
- Validator initially caught the new Block slice, then its contract mirror dependency. Both are generated in dependency order. An accidentally started full run was stopped while this gate was still red; it does not count as acceptance.
- Final pre-full validator: **0 errors / 113 modules / 0 JSON errors**, all nine counters zero.
- Full suite: **5358 passed / 22607 subtests passed in 1022.80s**. Complete output is retained in `full.log`.
- Final native MCP proof: **matches=true**, all eight boolean checks true, efficiency pairs **[1,1], [1,0.5], [1,0]**. Both debug output and explicit stop output contain **0 actual ERROR/SCRIPT ERROR entries** and **66 compiler warning entries**; warnings remain recorded, so the raw MCP `errors` array is not empty. The project was explicitly stopped.
- Godot editor parse: **exit 0**, no actual parse/script/runtime error entries; complete output is retained in `editor-final.log`.
- Replay: content generation plus registration leaves all **13 SHA256 hashes unchanged**. Final live cross-catalog validator: **0 errors / 113 modules / 0 JSON errors**, all nine category counters zero.
- Exact index audit: original root entries and policy values unchanged; only 17 symbols, 2 slices, 2 contracts and 6 schemas added. No project settings, UID, arc, manifest or unrelated facade changes staged; staged diff check passes. Audit output is retained in `index-final.log`.

Evidence directory: `docs/superpowers/reports/evidence/2026-11-01-liquid-consumer-hydration/`.

Reproduction order from the repository root:

```powershell
python tools/mindustry_godot_transpiler/transpile.py content
python tools/mindustry_godot_transpiler/register_liquid_consumer_hydration.py
python -m pytest -q -p no:cacheprovider tools/mindustry_godot_transpiler/tests/test_liquid_consumer_hydration.py tools/mindustry_godot_transpiler/tests/test_placed_liquid_ownership.py tools/mindustry_godot_transpiler/tests/test_content_registry.py --tb=short
python -m pytest -q -p no:cacheprovider tools/mindustry_godot_transpiler/tests --tb=short
```

After full success, launch `tools/runtime_proofs/LiquidConsumerHydrationProof.tscn` through Godot MCP against this checkout's actual `godot-mindustry` directory. Inspect actual ERROR/SCRIPT ERROR entries separately from compiler warnings and explicitly stop. Run final editor parse and catalog replay/validation. Do not mutate catalogs concurrently with a full suite reading them.

## Handoff and next checkpoints

1. **Apply/init capability and filters:** inspect ConsumeLiquidBase.apply, ConsumeLiquid.apply and Block.init/reinit. Reuse existing canonical apply owners. Exported constructor `hasLiquids=false` or an absent flag is not final post-apply capability. Resolve that phase explicitly before claiming storage exists for every liquid-consuming Block. Do not inject false into an unknown pre-apply field to satisfy a bool input. Register any new partial-input boundary and canonical filter state in the same one-to-three-slice batch.
2. **Concrete production consumer adapter:** use these Block-owned typed rows and the already placed Building's frame. Resolve source multiplier behavior and retain optional/booster/update/ignore flags. Reuse canonical Liquid get/efficiency/update/remove and Building consumption/application owners; do not duplicate `amount * edelta * multiplier`, create per-building copies of Block amounts, or reparse Java inside gameplay. A dictionary descriptor is not yet a callable production consumer object.
3. **Automatic Drill ticks:** inspect actual shouldConsume predicate (item total/capacity, enabled, dominant item), production validity, delta, scale and boost speed before connecting dispatch. Source empty water removes optional boost while valid unboosted drilling continues. Update consumers can still be invoked at base efficiency 1 when optional efficiency is zero; removal must preserve source clamp behavior. Prove game-driven multi-tick behavior rather than manually invoking a test consumer.
4. **World iteration prerequisite:** `record_cells` writes an origin coordinate and sprite for every occupied cell. Several cells reference one building. `placed_block_origins` is not a unique sprite collection. Before automatic ticks, add a real multi-cell/two-building RED proof and audit the existing `simulate_time_scales` origin-value/sprite mismatch recorded in the prior report. Resolve instances through the canonical placement owner and dispatch once per building; do not hide the discrepancy with a parallel registry.
5. **Remaining descriptor coverage:** thorium-reactor needs source variable expression resolution. Inherited constructor consumers, other consumer factories, custom callbacks, runtime mutations and catalog reload require their own evidence. Keep missing metadata unresolved until supported; do not replace absence with an empty full consumer list.
6. **Remaining LiquidModule domain:** capacity, flow timers/caches/display, serialization and callbacks remain separate source-backed work. Preserve existing static cache and per-building storage owners.
7. **Gate/commit discipline:** read AGENTS, design, five roots, manifest and relevant shards before each coherent one-to-three-slice batch. RED first, focused/JSON/catalog gates, complete full suite, final native proof/error inspection/stop, editor parse, deterministic replay, checklist/report and exact commit. Preserve dirty workspace changes by snapshot and delta staging.
