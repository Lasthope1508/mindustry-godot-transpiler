# LiquidModule indexed storage — N1993–N1995

Date: 2026-10-31. Parent: `674e08b9` (canonical ConsumeLiquid delegates). This checkpoint implements the missing get/add/remove resource boundary and proves real mutation of a supplied storage frame. Live world/Drill ownership is a later integration checkpoint.

## Checkpoints

| Gate | Scope | Result |
| --- | --- | --- |
| LS-A | Exact source, registered boundary and RED | RED produced six architecture/registration subtest failures and one runtime failure |
| LS-B | Cohesive canonical storage implementation | Three generated methods delegate to one new domain module; remove composes add |
| LS-C | Independent runtime and cross-catalog validation | 15 golden storage cases and BuildingComp consumption mutation match; validator 0 errors / 113 modules |
| LS-D | Full Python, editor, native final proof, exact diff and commit | Accepted: 5347 tests / 22552 subtests pass; final native proof and validator pass |

## Ownership and module boundaries

`SourceLiquidModuleState.gd` is the single runtime domain owner for this checkpoint. It contains three static entrypoints, with no PortGame facade and no additional source-text/default/helper files:

- `source_get_state(self_state, liquid_id)` reads the indexed amount and returns the registered `amount` envelope without mutation.
- `source_add_state(self_state, liquid_id, amount, cache_sums)` changes the existing array in place, assigns current identity, and conditionally increments the shared flow cache by the positive part of the added amount.
- `source_remove_state(...)` calculates Java's exact capped delta and calls canonical add. It contains no second implementation of add/current/flow behavior.

The emitter generates only required argument extraction/type conversion and delegation in `LiquidModule.java_method_get_8`, `java_method_add_10`, and `java_method_remove_12`. All four mutation arguments are required. No fabricated liquid ID, amount, storage capacity, flow-enabled flag or private cache default is added. Regeneration emitted 801 classes with 0 failures.

The explicit mutable instance frame contains `liquids` (indexed Array), `current` (Liquid.id representation), and `flow` (the upstream null/non-null guard). Existing concrete Liquid identity resolution is represented at this boundary by a valid in-range ID supplied by the caller. The caller also supplies `cache_sums` separately because Java declares `cacheSums` static. Two instances can therefore share one cache Array while retaining separate liquid amounts and current identities. A null flow does not require indexing the cache; a non-null flow requires an appropriately sized shared cache. Empty-array flow is non-null and is exercised in the proof.

The mutable frame is a registered Godot representation, not a claim that the generated Java constructor now allocates content storage. Array initialization, current identity and actual flow/cache ownership are explicitly supplied, not inferred. All other generated LiquidModule methods remain outside the selected three-method scope.

## Source evidence

Upstream `core/src/mindustry/world/modules/LiquidModule.java` supplies:

- Lines 19–26: static `cacheSums`, content-sized `liquids`, `current = content.liquid(0)` and nullable flow.
- Lines 102–104: `get` returns `liquids[liquid.id]`.
- Lines 110–117: `add` increments the selected amount, assigns `current = liquid`, and adds `Math.max(amount, 0)` to cacheSums only when flow is non-null.
- Lines 125–128: `remove` delegates to `add(liquid, Math.max(-amount, -liquids[liquid.id]))`.

Negative add amounts remain allowed, including values that make storage negative; add has no clamp in Java. Negative remove requests increase stored amount through the source expression, and their positive contribution reaches the flow cache when enabled. The source comment alone does not justify adding a new guard.

## SSOT and reproducibility

`register_liquid_module_storage.py` registers three direct module owners, three API contracts, five schemas, ten symbols and three slice records. N1993=get, N1994=add, N1995=remove. Each slice retains exact source expressions, tests, native proof reference and explicit deferred work. The result schema for each method is linked to its contract; mutation result fields alias the one canonical storage-frame schema.

No alias, JSON shard or manifest module is added. The existing 113-module catalog remains in place. The world/modules source path is not selected by existing consumer/component shards, so no unrelated mirror is regenerated. Canonical ledger count becomes 1450 records; this is registered slice count, not full-method/game coverage. Static direct module owners are checked by the cross-catalog implementation resolver; the legacy non-static PortGame source-function audit scope is unchanged.

Before/after semantic comparison confirms only the ten symbols, three contracts, five schemas and three slices were added; existing root entries and root policy metadata were unchanged. The working tree already contains substantial unrelated schema/manifest/runtime changes. Stage only the new schema entries onto the HEAD schema document in the index; preserve pre-existing working-tree schema data and never stage the whole dirty schema file. Other edited root catalogs, generated LiquidModule and emitter were clean at this checkpoint's start.

## Independent behavior proof

`LiquidModuleStorageProof` uses literal expected arrays/amounts from Java, without calling the canonical helper to calculate expected values. Fifteen cases cover two read-only getters, positive/negative/zero add, partial/exact/excess/zero/empty removal, negative removal, both liquid indices, other-liquid preservation, current selection on zero/removal operations, flow cache enabled/disabled behavior, and two-instance shared-cache behavior.

The composition proof uses actual generated get results as the availability input to generated ConsumeLiquid efficiency. The result enters the registered complete BuildingComp frame. A concrete proof consumer receives the applied efficiency, computes canonical edelta, requests consumption through generated ConsumeLiquid update, and applies that request through generated LiquidModule remove to the original storage frame.

Independent expected states: `[4, 1.25] → [4, 0.25] → [4, 0]`; efficiencies `1 → 0.25 → 0`; removal requests `[1, 0.25]`. The third tick dispatches no resource update. Separate disabled and shouldConsume=false cases preserve the second liquid amount `0.25` and dispatch no consumer. The first liquid remains `4` throughout. This extends the preceding amount-only proof with real mutation of the registered storage adapter.

This proof composes production domain/adapter code with a supplied test actor and frame. It is not a production world binding or a whole-Drill gameplay proof. Java float32 versus Godot floating-point precision for arbitrary values is not exhaustively established by the binary-fraction golden cases.

## Validation record

- RED: 7 expected failures (six subtest failures plus runtime), 2 test methods passed their outer subtest containers.
- Emit: 801 classes / 0 failures.
- Initial focused GREEN: 3 passed / 6 subtests passed in 2.57s.
- Initial native MCP: all 15 golden cases and consumption mutation match; registry valid; one headquarter per SSOT; actual ERROR/SCRIPT ERROR entries 0. The initial capture includes 25 existing compiler warnings and one proof-only ternary-type warning; the latter was corrected without changing production storage behavior.
- Cross-catalog: 0 errors / 113 modules / 0 JSON errors, all nine counters zero.
- Editor parse: exit 0, no ERROR/SCRIPT ERROR output.
- Full Python suite: **5347 passed / 22552 subtests passed in 1006.98s**, exit 0.
- Final focused regression after proof-only warning cleanup: **6 passed / 10 subtests passed in 4.72s**, including previous canonical ConsumeLiquid tests. Production implementation was unchanged by that cleanup.
- Final native MCP: **15/15 golden cases pass**, consumption_mutation_matches=true, registry_valid=true, one_headquarter_per_ssot=true; actual ERROR/SCRIPT ERROR entries 0. The raw stderr container contains 25 existing compiler warnings in SourceBlockGeometry/SourceBuildingVisibilityState, plus context lines; it is not described as empty. Native project explicitly stopped.
- Final validator: **0 errors / 113 modules / 0 JSON errors**, all nine counters zero.
- Registration replay: all four root catalog hashes unchanged (PASS).
- Exact slice diff/staging checks pass; pre-existing schema/manifest/runtime changes remain outside the commit.

Raw logs, before/after scope verification, registration replay and native output are retained under `docs/superpowers/reports/evidence/2026-10-31-liquid-module-storage/`. Historical RED output is preserved separately.

## Handoff after acceptance

The next coherent checkpoint is source-backed LiquidModule initialization and lifecycle, followed by production storage ownership in BuildingComp/block callers. Reuse this storage owner; do not add local liquid dictionaries or repeat arithmetic in Drill/consumer callbacks.

1. Re-read all five root catalogs, manifest/relevant shards and exact Java. Inspect constructor field initialization and content-size/content.liquid(0) identity mapping before choosing the next one to three slices. `current/currentAmount`, reset/set/clear, capacity changes and flow lifecycle have distinct source semantics; select a cohesive accepted scope and leave the rest explicit.
2. Write independent RED tests for construction/current identity and selected lifecycle transitions. Preserve the difference between clear (keeps current), reset (changes current), set (conditional current change), and add/remove (always select current). Register all new boundary fields/contracts/symbols in that same scope.
3. Keep `cacheSums` shared when connecting real flow owners. Do not replace Java's nullable flow lifecycle with an always-disabled default. Port timer/window/reset/display behavior before claiming full flow support.
4. For production integration, derive availability from the actual instance store, derive all BuildingComp predicates from their canonical owners, and bind consumer updates to that same store. Prove at least two ticks plus starvation/disabled/no-consume behavior in the real selected block. Do not label the present proof actor as live world integration.
5. Accept only after focused/source fidelity, validator/JSON, full suite, native MCP inspection/stop, editor parse, checklist/report, exact staging and commit. Preserve unrelated pre-existing working-tree changes.
