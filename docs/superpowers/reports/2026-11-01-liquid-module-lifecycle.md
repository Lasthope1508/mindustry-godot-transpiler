# LiquidModule instance initialization and lifecycle — N1996–N1998

Date: 2026-11-01. Parent commit: `58b9c60c`. Scope: explicit instance-field initialization, current/currentAmount, reset/clear and set in the existing LiquidModule domain. World/Drill storage ownership and runtime content lookup are outside this checkpoint.

## Checkpoints

| Gate | Requirement | Evidence/status |
| --- | --- | --- |
| LL-A | Read source/SSOT, define representation, prove RED | 13 expected failures: 12 architecture/registration subtest failures plus runtime failure |
| LL-B | Reuse canonical storage owner and frame | Six canonical entrypoints added to existing SourceLiquidModuleState; generated adapters delegate |
| LL-C | Independent lifecycle and composition proof | Native MCP: 19/19 cases match; initialized consumption, registry and one-headquarter checks true |
| LL-D | Complete acceptance and exact commit scope | Accepted: 5350 tests / 22570 subtests pass; final native and catalog gates pass |

## Module ownership and behavior

The production implementation remains in `godot-mindustry/src/game/SourceLiquidModuleState.gd`. No runtime module, facade, default container or source-text helper is added.

1. **Initial instance frame:** `source_initial_state(content_liquid_ids)` allocates a fresh amount Array sized from the supplied canonical content list, fills it with zero, takes current identity from the first catalog ID, and starts nullable instance flow at null. The input is the resolved nonempty `content.liquids()` ID list in canonical order, representing both `content.liquids().size` and `content.liquid(0)`. No fixed capacity or fallback liquid ID is introduced. Static flow caches are not initialized or owned by this instance adapter.
2. **Read current identity:** `source_current_state(self_state)` returns the existing canonical `current` ID representation without mutation. It does not resolve or fabricate a concrete Liquid object.
3. **Read current amount:** `source_current_amount_state(self_state)` calls the existing canonical indexed getter with current ID. It reuses the getter amount envelope and does not add another indexed-read implementation.
4. **Clear:** `source_clear_state(self_state)` fills the existing amount Array with zero, preserving the Array reference, current identity and flow reference.
5. **Reset:** `source_reset_state(...)` composes canonical clear, assigns the selected amount and then assigns current identity. It preserves flow and accepts source-supported zero/negative amounts.
6. **Set:** `source_set_state(...)` compares the requested amount with the old current-liquid amount before writing the selected amount. A greater or equal amount switches current identity, including ties. A lower amount can leave current pointing to another liquid. No clamp, automatic maximum search or flow update is introduced.

Existing get/add/remove implementation and contracts are unchanged. Reset/clear/set do not touch Java's static cacheSums. Their frame remains the same registered `liquids/current/flow` representation from N1993–N1995.

## Generated adapter boundary

`emitter.py` regenerates current, currentAmount, clear, reset and set as required input extraction/type conversion followed by a canonical call. Existing generated get/add/remove signatures are preserved. The same emitter branch handles the cohesive LiquidModule storage methods; there is no new runtime dispatcher.

The additional generated `java_initialize_state([content_liquid_ids])` explicitly exposes upstream **instance-field initialization**. Upstream LiquidModule declares no explicit constructor; the adapter does not invent a parsed Java constructor or change `JAVA_CONSTRUCTORS`. It is registered as `<instance field initialization>` and delegates to the domain initializer. Godot `.new()` still constructs the generated adapter object without fetching content or installing a storage frame automatically. Callers must provide the canonical list and retain the returned frame.

This checkpoint therefore closes deterministic allocation/initial-field semantics at the explicit registered boundary. It does not close runtime content discovery, concrete Liquid references, or automatic BuildingComp/world instance wiring. Initial null flow follows Java's default for the nullable instance reference; subsequent flow lifecycle is still deferred.

## Source and SSOT

Exact source: `mindustry-upstream/core/src/mindustry/world/modules/LiquidModule.java`.

- Instance fields: `private float[] liquids = new float[content.liquids().size];`, `private Liquid current = content.liquid(0);`, `private @Nullable WindowedMean[] flow;`.
- `current()` returns `current`; `currentAmount()` returns `liquids[current.id]`.
- `reset`: `Arrays.fill(liquids, 0f);`, `liquids[liquid.id] = amount;`, `current = liquid;`.
- `clear`: `Arrays.fill(liquids, 0);` with no current/flow assignment.
- `set`: `if(amount >= liquids[current.id]){ current = liquid; }`, then `liquids[liquid.id] = amount;`.

`register_liquid_module_lifecycle.py` adds three coherent slice records:

- N1996: initial instance frame and current/currentAmount reads.
- N1997: clear/reset transitions and preservation of unrelated instance state.
- N1998: set's pre-write comparison and conditional current transition.

It adds six direct module API contracts, seven schemas and ten symbols. Six result schemas alias the existing canonical frame/getter fields; the only new input shape is the resolved content-ID list. Existing storage input schemas are reused for the lifecycle methods. Slice records explicitly retain the remaining deferred bindings.

Before/after semantic comparison verifies no previous catalog entry or root policy metadata changed. No new alias, JSON shard or manifest module is introduced. The `/world/modules/` path is not selected by existing consumer/component shards. The catalog remains 113 modules; the canonical ledger becomes 1453 records. These counts describe registered records, not gameplay or full-source parity.

Static domain entrypoints are checked by the cross-catalog implementation resolver. The legacy non-static PortGame audit report scope is unchanged. The new direct owners are not presented as new PortGame functions.

## Independent proof matrix

`LiquidModuleLifecycleProof.gd/.tscn` compares production adapters against independent literal expectations derived from Java:

- Two content-list sizes verify allocation, zero amounts, first current identity and null instance flow.
- Two initialized module objects verify fresh independent amount Arrays and unchanged input IDs.
- Three current/currentAmount cases verify read-only behavior for both IDs and zero amounts.
- Three reset cases cover normal, zero and negative amounts, clearing other liquids and selecting current.
- Two clear cases cover nonempty and already-empty storage while preserving current identity.
- Eight set cases cover lower/equal/greater amounts, same current liquid, zero ties, negative values and switching to the other index.

All mutation cases verify the original frame and amount Array identities, unchanged flow reference/content and returned frame identity. This catches implementations that silently replace the Array or reset current/flow during clear/reset.

The composition check reuses the previous storage proof's consumer fixture, without executing that fixture scene's `_ready()`. It obtains the frame through the new generated initializer, resets liquid 1 to 1.25, then executes three BuildingComp consumption ticks. Independent expected amounts are `[0, 0.25]`, `[0, 0]`, then still empty; removal requests are `[1, 0.25]`. A set to 0.5 followed by another tick consumes exactly 0.5. Final clear leaves current ID 1 and current amount zero. Production calculation, state application, dispatch and storage mutation are exercised; expected values never come from a duplicate helper call.

This remains composition at an explicit input boundary with a test consumer. It is not a live Drill/world integration proof, a full flow timer proof or exhaustive Java float32 parity for arbitrary numeric inputs.

## Validation record

- RED: 13 expected failures and 2 passing outer subtest containers.
- Emit: 801 classes / 0 failures.
- Focused GREEN including existing storage and ConsumeLiquid regression: **9 passed / 22 subtests passed in 7.26s**.
- Cross-catalog: **0 errors / 113 modules / 0 JSON errors**, all nine counters zero.
- Native Godot MCP: **19/19 cases pass**, initialized_consumption_matches=true, registry_valid=true, one_headquarter_per_ssot=true; actual ERROR/SCRIPT ERROR entries 0. Raw stderr contains 25 existing compiler warnings from SourceBlockGeometry/SourceBuildingVisibilityState and context lines; it is not an empty errors container. The native project was explicitly stopped before the full suite.
- Godot 4.6.2 editor parse: exit 0, no ERROR/SCRIPT ERROR output.
- Full Python suite: **5350 passed / 22570 subtests passed in 1010.72s** (16m50s), exit 0.
- Final native MCP after the full suite: 19/19 cases and initialized consumption match; registry/headquarter checks true; actual ERROR/SCRIPT ERROR entries 0, 25 existing compiler warnings retained separately in raw logs; project stopped.
- Registration replay: all four root catalog hashes unchanged (PASS).
- Final validator: **0 errors / 113 modules / 0 JSON errors**, all nine counters zero.
- Slice diff/index checks pass; canonical ledger/checklist count 1453. Only seven newly added schema entries are staged from the dirty schema document; unrelated workspace data is preserved.

Evidence directory: `docs/superpowers/reports/evidence/2026-11-01-liquid-module-lifecycle/`. RED, focused GREEN, full suite, editor, native debug/stop and catalog scope/replay records are kept separately.

## Handoff and next checkpoints

1. **Runtime content and instance ownership:** locate the authoritative runtime content provider for ordered Liquid IDs. Trace upstream `content.liquids()`/`content.liquid(0)` and BuildingComp's `liquids = new LiquidModule()` allocation boundary before adding wiring. Bind one initialized frame to the selected real building owner and share it across reads, efficiency evaluation and consumer updates. Do not create a second storage dictionary or hardcode IDs/capacity in a gameplay callback. If the runtime catalog lacks canonical liquid IDs, port/register that provider first.
2. **Remaining lifecycle:** inspect source-backed checkArrayCapacity, handleFlow and stopFlow before choosing the next cohesive one-to-three slices. Capacity changes must preserve/truncate values exactly as Arrays.copyOf specifies; stopFlow must preserve static caches and storage; handleFlow must share the existing cache owner rather than duplicate add/removal formulas. Leave unselected behavior explicit.
3. **Full flow domain:** updateFlow needs the real timer/window/reset/cache/display/bitset semantics. Null initial flow is not a permanent disabled-flow policy. Do not claim full flow parity from the present null/non-null guard and preservation tests.
4. **Production acceptance:** the selected real block must prove initialization, at least two resource-consuming ticks, starvation, disabled/no-consume guards and persisted instance ownership. Keep pure calculation and resource application in their canonical owners. Serialization and each/sum callbacks remain source-backed work with their own dependencies.
5. **Gate discipline:** reread all five roots and the manifest/relevant shards; RED before GREEN; register every new boundary in the same slice; run focused/JSON/catalog/full/native/editor checks; inspect actual errors and stop MCP; update ledger/checklist/report; stage exact owned changes and commit. The workspace has pre-existing dirty schema/manifest/runtime files; stage only newly added schema entries onto HEAD and preserve the prior working-tree edits.
