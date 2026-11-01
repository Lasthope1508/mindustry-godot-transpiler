# Placed building liquid ownership — N1999–N2001

Date: 2026-11-01. Parent: `5e174b27`. This checkpoint connects the existing canonical LiquidModule frame to actual world placement. It adds typed liquid ordinal resolution, exports source-explicit block liquid flags and initializes one frame per eligible placed building. Production Drill consumer hydration and automatic tick dispatch remain deferred.

## Checkpoints

| Gate | Acceptance requirement | Evidence/status |
| --- | --- | --- |
| PO-A | Exact source/SSOT review and expected RED | Four new tests initially fail; source anchors and registration recorded below |
| PO-B | Canonical content and persistent instance ownership | Typed catalog provider, 56 source-explicit block flags, placement initialization; no numeric liquid IDs in production |
| PO-C | Actual world proof and guard coverage | Focused GREEN: 18 tests / 21 subtests; native MCP: all proof flags true, actual errors zero, project stopped |
| PO-D | Complete suite, final native proof, reproducible mirrors and exact commit | Accepted: 5354 tests / 22588 subtests; editor exit 0; catalog/JSON zero errors; 15 replay hashes unchanged; exact slice index verified |

## Canonical module boundaries

### Typed content identity — N1999

`SourceContentRegistryRuntimeState.source_liquid_catalog_state(content_catalog)` derives `content_liquid_ids` and `liquid_id_by_name` from the existing content catalog's `get_many("liquid")` sequence. Ordinals follow registration order. Production does not embed a liquid count, water ID, slug table or fallback identity. Existing UI string IDs retain their representation.

Source evidence:

- `ctype/Content.java:20–22`: assign `id` from the size of the sequence for this content type, then register the content.
- `core/ContentLoader.java:308–318`: `liquids()`, `liquid(int)` and `liquid(String)` all operate within `ContentType.liquid`.

The existing mixed-type `ContentCatalog.by_id` has a name collision: `water` can resolve to the floor block because blocks are registered after liquids. This checkpoint avoids that map for numeric liquid identity and uses the typed sequence. It does not redesign every UI/global content lookup. The proof's independent literal map checks all eleven current upstream liquids, including water, against the new provider.

### Source-explicit block capability — N2000

The existing content extractor's constructor/inheritance resolver now carries `hasLiquids` alongside its existing capability flags. Initializer assignments override inherited constructor assignments. `SourcePlacedBlockState.source_block_has_liquids_state(block)` reads the hydrated property at a required-input boundary.

Source evidence:

- `world/Block.java:47`: the `hasLiquids` field declaration.
- `world/blocks/production/Drill.java:81`: constructor sets `hasLiquids = true`.
- Concrete inherited constructor and content initializer assignments are read by the extractor; the synthetic fixture proves inherited true, explicit false, child inheritance and initializer override.

No false fallback is introduced when the property is absent. The extractor does not yet run `ConsumeLiquidBase.apply`, `ConsumeLiquids.apply` or `ConsumeLiquidFilter.apply`; those can enable liquids during later initialization. A missing exported flag therefore means unresolved hydration at this checkpoint. The placement boundary participates only when the property exists.

These exported values cover constructor/inherited/initializer assignments before consumer apply, not complete post-`Block.init` capability parity. An explicit false can subsequently become true in `cons.apply`. The selected real Drill already sets true in its constructor and is the accepted live ownership target; adding flags to 56 blocks does not mean all 56 blocks have completed their final consumer initialization semantics.

Semantic comparison against the pre-turn snapshot confirms exactly 56 block property additions, each adding only `hasLiquids`. The content counts remain 22 items, 11 liquids, 417 blocks and 56 units. No existing property or other content collection changes.

The registered `content_registry_blocks` mirror is regenerated through `source_ssot.build_extension_shard` and `write_registered_json`, using its manifest-defined fields and canonical references. Registration replay includes this mirror. The first validator run caught 56 stale property mirrors after content regeneration; synchronizing them closes those errors without changing validator rules.

### Building instance allocation — N2001

`SourcePlacedBlockState.source_initialize_building_liquids_state(sprite, has_liquids, content_catalog)` reuses the existing `SourceLiquidModuleState.source_initial_state` allocation owner. The persistent frame lives under the registered `SOURCE_BUILDING_LIQUIDS_META_KEY`, representing `BuildingComp.liquids` on that placed instance.

Source evidence: `BuildingComp.java:137–146`, especially `if(block.hasLiquids) liquids = new LiquidModule();`, and the nullable LiquidModule field declaration.

When the create guard is true, initialization installs a fresh canonical frame with catalog-sized amounts, first current liquid and null flow. A false guard performs no assignment: a previously existing frame is preserved; an absent field remains null. The implementation explicitly checks `has_meta` before reading. Godot logs an error for an absent key even when `get_meta(key, null)` is passed; the focused runtime test caught that issue and the final implementation removes it.

`PortGame.record_placed_block` calls this initializer after its existing cell/sprite initialization, for blocks whose explicit hydrated capability is present. There is no block-name special case, new simulation formula, copied liquid array or secondary instance owner. Re-recording with a true guard represents the source create boundary and allocates again; regular reads and consumption must reuse the stored frame.

## Registration and scope audit

- Three ledger records: N1999 typed liquid catalog, N2000 explicit liquid capability, N2001 placed allocation.
- Three API contracts, six schemas and ten source symbols, including the metadata binding.
- Canonical schemas: `source_liquid_catalog_input/result`, `source_block_has_liquids_input/result`, `source_initialize_building_liquids_input/result`.
- Ordered content IDs alias the previously registered LiquidModule initialization input. The stored `liquids` result references the existing `source_liquid_module_storage_state` frame.
- Existing root entries and policy metadata are unchanged. No new owner alias, shard or manifest module is introduced. Canonical ledger total becomes 1456; module count remains 113. These are registered-record counts, not a full-source parity percentage.
- Relevant existing production/component mirrors and the content block mirror are regenerated from canonical catalogs.
- Audit report scope is unchanged: the new static domain owners are checked by the cross-catalog validator, not represented as new legacy non-static PortGame methods.

The workspace contains a pre-existing, uncommitted facade/bridge refactor. This slice preserves it. The working PortGame override calls `super.record_placed_block` to retain its existing canonical placement delegate, then adds only the new capability guard and initialization call. The index patch applies that same guard/call to HEAD's existing `record_placed_block`, without staging the unrelated facade inheritance or untracked bridge chain. The two dirty runtime modules and schema/mirror JSON files are staged by adding only this checkpoint's delta to HEAD. No `project.godot`, `.gd.uid`, `arc-upstream` or unrelated refactor data is included.

The existing shared test-only `RuntimeProofState.gd` output helper was untracked despite earlier proofs already referring to it. It is included unchanged as an explicit dependency of this proof. No new production state/formula owner is created by that helper. Semantic JSON scope is audited separately from generated formatting/order; staging does not import old mirror record reordering merely because regeneration sorts the full collection.

## Independent proof matrix

`PlacedLiquidOwnershipProof.gd/.tscn` instantiates the actual `scenes/Main.tscn`, enters the campaign playable slice, waits for placement/bootstrap, freezes automatic processing and finds the real mechanical drill among the world's placed blocks.

The proof checks:

1. Exact typed name-to-ordinal mapping for all current upstream liquids. Numeric expected values are test goldens only.
2. The real drill already owns an initialized frame from placement, with eleven slots, current ID zero and null flow.
3. A supplied test consumer uses generated ConsumeLiquid efficiency/update and the canonical BuildingComp consumption frame/dispatch to mutate that exact world-owned frame through the existing liquid removal owner.
4. Starting with water 1.25, two consuming ticks leave 0.25 then zero; requests are 1 and 0.25. A third starved tick dispatches no additional removal.
5. Disabled and `shouldConsume=false` cases preserve 0.25 and dispatch no removals.
6. A second placed-instance allocation is independent. False allocation guards preserve an existing frame and leave an absent frame null.
7. Registry validity and one-headquarter-per-SSOT are true.

The production removal, efficiency, complete consumption frame and dispatch owners are reused. The proof supplies its own consumer descriptor and explicit tick inputs; it does not prove that a production Drill consumer descriptor, liquid boost policy or automatic game-loop consumption is already hydrated. It does prove actual world storage ownership and consumption composition using that stored frame.

## Validation and evidence

- RED: four expected failures before implementation.
- First runtime GREEN attempt: proof values matched but the test rejected actual absent-metadata errors; fixed with `has_meta`.
- First focused GREEN after metadata correction: **15 passed / 21 subtests passed in 23.62s**.
- Full integration attempt caught a scope-adjustment regression: **3 failed / 5351 passed / 22588 subtests in 1127.53s**. Copying HEAD's placement body into the working facade override reintroduced inline cell/sprite orchestration prohibited by three existing placement tests. Fixed by delegating through `super.record_placed_block`; none of those assertions were weakened or edited.
- Final focused GREEN including all three architecture regressions: **18 passed / 21 subtests passed in 23.71s**.
- Content generation: 22 items / 11 liquids / 417 blocks / 56 units.
- Cross-catalog + JSON validator after mirror regeneration: **0 errors / 113 modules / 0 JSON errors**, all nine category counters zero.
- Final Godot 4.6.2 editor parse after native stop: **exit 0, actual ERROR/SCRIPT ERROR count zero**.
- Final full suite: **5354 passed / 22588 subtests passed in 975.01s (16m15s), exit 0**. Two interrupted attempts are retained separately and do not count as acceptance: the first was stopped after a stale mirror was found, the second after exact commit scope review moved the hook out of the pre-existing untracked bridge. The completed failed inline-orchestration run is retained as compressed raw evidence.
- Final native MCP after the full suite: **matches=true**; typed catalog, live Drill ownership, owned consumption, independent frames, false guard, registry and one-headquarter flags all true. Water amounts after consuming ticks are **[0.25, 0]**. Actual ERROR/SCRIPT ERROR count **0** in debug and final stop output; **66 compiler warnings** from existing modules are retained in the raw log. The tool's `errors` container includes those warning lines and is not empty. The project was explicitly stopped.
- Content + registration replay: **all 15 working canonical file hashes unchanged**, including four roots, seven mirrors, content JSON/GDScript, manifest and audit.
- Final validator after replay: **0 errors / 113 modules / 0 JSON errors**, all nine counters zero.
- Exact index verification: only the three new slices, three contracts, six schemas, ten symbols, required content/mirror changes, canonical runtime additions, placement hook and proof/dependency/report files are included. Existing root entries and policy values remain unchanged; diff checks pass. Ledger/checklist total **1456**.

Evidence directory: `docs/superpowers/reports/evidence/2026-11-01-placed-liquid-ownership/`. It contains RED, the caught metadata error, failed integration evidence, focused/final full logs, final native debug/stop/proof, editor parse, scope/index and replay records.

To reproduce content and catalog generation, run from the repository root in this order:

```powershell
python tools/mindustry_godot_transpiler/transpile.py content
python tools/mindustry_godot_transpiler/register_placed_liquid_ownership.py
python -m pytest -q -p no:cacheprovider tools/mindustry_godot_transpiler/tests/test_placed_liquid_ownership.py tools/mindustry_godot_transpiler/tests/test_content_registry.py tools/mindustry_godot_transpiler/tests/test_liquid_module_storage.py tools/mindustry_godot_transpiler/tests/test_liquid_module_lifecycle.py --tb=short
python -m pytest -q -p no:cacheprovider tools/mindustry_godot_transpiler/tests --tb=short
```

Then launch `tools/runtime_proofs/PlacedLiquidOwnershipProof.tscn` through Godot MCP against this checkout's actual `godot-mindustry` directory, inspect debug output, verify proof flags and stop. The absolute worktree path printed in the older AGENTS is not this checkout. Headless proof success alone does not satisfy the native gate. Do not run generation concurrently with a full suite that is reading the same catalogs.

`scope.json` records before/after semantic additions and unchanged root policies; `exact_scope_and_index.txt` preserves the workstation audit/staging procedure. That procedure uses pre-turn snapshots under `C:/tmp/liquid-owner-before` and is evidence, not a portable production generator or a replacement for fresh snapshots in the next turn. Registration replay hashes describe the current canonical working files. They do not assert that the unrelated dirty facade/schema refactor is included in this slice's commit.

## Handoff: next cohesive checkpoints

### CP-PO1 — accepted

Keep the catalog provider, flag hydration and allocation boundaries together. Preserve the current capability guard and its unresolved-metadata meaning. Use `SOURCE_BUILDING_LIQUIDS_META_KEY` for readers rather than inventing another dictionary or key. Do not use global `get_by_id("water")` for liquid identity.

### CP-PO2 — production consumer hydration

Read the exact upstream content initializer, Drill constructor/init and consumer apply path before selecting at most three slices. Trace the actual liquid consumer's liquid identity, amount, multiplier, optional/booster status, consumption predicate and update participation. Reuse current canonical schema names and typed ID resolution.

Register the concrete consumer descriptor and its source evidence. If `Consumer.apply` sets `hasLiquids`, hydrate that effect through one source-backed initialization owner and update the canonical content representation/mirror. Do not infer true from a generic block category or treat absent metadata as false. Do not hardcode water, capacities, rate, boost multiplier or the mechanical-drill slug into a generic runtime handler.

Acceptance requires independent source-derived descriptor expectations, enabled/disabled participation and required-versus-optional consumer behavior. Keep consumer selection and resource mutation in their existing canonical owners. Do not couple consumer hydration to full LiquidModule flow support unless the selected source lines require it.

The next source trace is already located: `Blocks.java:2865–2875` declares mechanical drill and `consumeLiquid(Liquids.water, 0.05f).boost()`; pneumatic drill uses a different arithmetic expression at lines 2877–2884. `Consume.java:27–35` defines `.boost()` as `optional(true, true)` and lines 15–18 define update participation and the multiplier function. `Block.java:1127–1128` creates/registers ConsumeLiquid; its init/reinit loops call `cons.apply(this)` at lines 1453–1454 and 1492–1493. `ConsumeLiquidBase.apply` enables storage and `ConsumeLiquid.apply` sets the typed liquid filter. These are source inputs for descriptor extraction, not values to copy into generic gameplay code. Prove expression handling without a block-name allowlist.

### CP-PO3 — automatic production ticks

Connect the hydrated production descriptor to the existing building tick/efficiency boundary. Read storage from the already placed instance, evaluate availability through the canonical getter, compute consumption through the existing generated/canonical delegates and dispatch exactly once through the current resource application owner. No second amount array, copied frame or duplicate `amount * delta * multiplier` formula is allowed in gameplay callbacks.

First reconcile the actual placement collection shape. `SourceBlockPlacement.record_cells:165–172` stores one entry per occupied cell: `placed_block_origins[key] = origin_cell` and `placed_blocks[key] = sprite`. Several keys therefore point to the same building sprite, and origin values are Vector2i rather than Sprite objects. Do not iterate `placed_blocks.values()` naively or assume `placed_block_origins.values()` is a unique sprite collection. Resolve the real instance through the existing placement owner and ensure one dispatch per building identity. Add a real multi-cell/two-building RED proof before selecting an automatic-tick implementation; do not create a parallel registry to hide the mismatch.

There is a pre-existing shape discrepancy worth auditing at that boundary: the current `SourcePlacedBlockState.simulate_time_scales` loop passes `placed_block_origins.get(key)` into its sprite-decay routine, whereas the actual registration path writes an origin coordinate there. This checkpoint does not change that loop or claim that its real-world iteration semantics are accepted by the liquid storage proof. Confirm the runtime impact with actual placement data before reusing it for liquid ticks; preserve the difference between source-backed arithmetic helpers and live collection wiring.

Acceptance must demonstrate actual game-driven ticks on the selected real building: initial ownership, at least two resource-consuming ticks, starvation, disabled and no-consume guards, frame persistence and independence of two building instances. The new proof must stop manually invoking `tick` with its test consumer to support an automatic-gameplay claim. Optional booster effects need separate source-derived expectations from required consumer starvation.

For this specific Drill, `Drill.java:247–249` defines `shouldConsume` using item total/capacity, enabled and a non-null dominant item. Lines 300–301 use `Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency` for speed. Empty water must remove the optional liquid boost while leaving otherwise valid unboosted drilling available. The current fixture supplies a required test consumer, so its starvation expectation must not be reused as the production mechanical drill's overall-validity expectation. Trace dominant-item selection and current item occupancy before connecting this predicate; keep any unresolved inputs explicit.

### CP-PO4 — remaining LiquidModule lifecycle and flow

Inspect `checkArrayCapacity`, `handleFlow`, `stopFlow`, `updateFlow`, serialization and each/sum callbacks before choosing the next scope. Capacity expansion/truncation must follow `Arrays.copyOf`; static cache ownership must remain shared with the existing add/remove owner. Null initial flow is not a permanent flow policy. Timer/window/reset/cache/display/bitset dependencies must be traced before claiming full flow parity. Dynamic content/mod reordering and loading old saves remain explicit dependencies.

### Required gate for every next checkpoint

Read AGENTS, design/checklist, all five roots, manifest and relevant shards; inspect exact Java. Write RED, implement one coherent one-to-three-slice batch, run focused checks and canonical/JSON validation, complete full suite, then native MCP proof plus actual error inspection/stop and final editor parse. Reconcile record counts and document remaining source lines. Replay generation to prove idempotence, check semantic scope against pre-turn snapshots, stage exact owned changes and commit. Preserve all unrelated dirty files and index only newly owned schema/runtime/mirror deltas.
