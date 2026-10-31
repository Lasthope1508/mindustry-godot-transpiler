# ConsumeLiquid canonical delegates — N1991–N1992

Date: 2026-10-31. Parent checkpoint: `8e815a95` (BuildingComp consumption remediation). Scope: canonicalize the two existing generated liquid-consumption methods before resource-storage integration. Full gameplay/resource parity is outside this acceptance.

## Checkpoints

| Checkpoint | Requirement | Result |
| --- | --- | --- |
| CL-A: source and RED | Preserve exact Java behavior and expose duplicate generated ownership | Two architecture tests failed before implementation; source evidence retained from N1449/N1543 |
| CL-B: canonical implementation | Generated methods delegate to the existing domain owner | Update and efficiency delegate to `SourceConsumeLiquidState`; emitter regenerated 801 classes / 0 failures |
| CL-C: independent runtime | Golden expected values and BuildingComp dispatch match through native Godot MCP | 17/17 cases match; composition, registry and one-headquarter checks true; actual runtime errors 0 |
| CL-D: acceptance | Focused/full Python, JSON/catalog, editor parse and exact diff/staging | Accepted: 5344 tests / 22542 subtests pass; validator and editor parse pass |

## Changes by module

1. **Existing domain owner:** `godot-mindustry/src/game/SourceConsumeLiquidState.gd` retains `update_state(...)` and `efficiency_state(...)`. Its implementation is unchanged. No new runtime helper/module or production formula was introduced.
2. **Emitter and generated adapter:** `tools/mindustry_godot_transpiler/mindustry_port/emitter.py` emits a preload of that existing owner in `ConsumeLiquid.gd`. `java_method_update_2` and `java_method_efficiency_3` normalize their historical positional inputs and immediately delegate. The duplicate multiplication, epsilon guard, division, cap and source-result dictionaries were removed from these generated method bodies. Historical input defaults are unchanged.
3. **Contracts and result shape:** existing canonical contracts and result schemas remain authoritative. Generated return values now use those existing canonical envelopes, including their source metadata. No new API contract, schema, symbol owner, alias or manifest module is added.
4. **Ledger and mirror:** N1991 follows N1449 (update); N1992 follows N1543 (efficiency). Both entries retain original source symbols, owners, contracts and every deferred expression. `register_consume_liquid_generated_delegate.py` derives the entries from their originals and regenerates the registered `consumer_slices` mirror. Replay is idempotent. The ledger has 1447 records after these two additions; this count is not a method-coverage or gameplay-completion percentage.
5. **Regression tests:** existing emitter tests now require delegation while retaining input-normalization assertions. `test_consume_liquid_generated_delegate.py` rejects reintroduced inline formulas and executes the independent proof scene headlessly when Godot is available. Native MCP verification remains a separate acceptance step.
6. **Proof artifact:** `ConsumeLiquidCanonicalProof.gd/.tscn` contains independent Java-derived expected results. It adds no production defaults or alternative runtime owner. Native runs remain alive for debug inspection and explicit stop; headless test runs exit with the proof status.

## Exact source boundary

`mindustry-upstream/core/src/mindustry/world/consumers/ConsumeLiquid.java:41–52` owns the behavior:

- Update requests `amount * build.edelta() * multiplier.get(build)` from `build.liquids.remove(...)`.
- Efficiency calculates `ed = build.edelta() * build.efficiencyScale()`.
- `ed <= 0.00000001f` returns zero.
- Otherwise efficiency is `min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f)`.

The adapter still receives evaluated liquid ID/availability, amount, delta, scale and multiplier at its registered boundary. It does not invent a concrete `Building`, `Liquid`, or functional multiplier instance.

## Runtime evidence and limits

The golden matrix contains 11 efficiency cases and 6 update cases. It covers absent/partial/full/excess available liquid; zero/negative delta; zero efficiency scale; epsilon and the value above it; non-unit scale/multiplier; zero update amount/delta/multiplier; and liquid-ID preservation. Expected numeric values are literal independent golden results, not a second call to the helper under test.

The composition check feeds available liquid `0.25`, amount `0.5`, delta `2`, scale `1`, multiplier `1` into generated efficiency. Its result `0.25` enters a complete BuildingComp consumption frame. A concrete proof consumer receives the applied frame, evaluates canonical `edelta`, then calls generated liquid update. All three efficiency fields equal `0.25`, power consumption remains enabled, and the dispatched removal request is exactly `0.25`.

This proves availability evaluation at an explicit input boundary, BuildingComp state application, consumer callback dispatch, and the requested removal amount. The callback records the amount. It does **not** call or mutate real `LiquidModule` storage. Generated `LiquidModule.get/add/remove` are still stubs, and live Drill/resource binding remains deferred. This checkpoint must not be described as completed real liquid consumption.

Native MCP captured `matches=true`, `case_count=17`, `building_composition_matches=true`, `registry_valid=true`, and `one_headquarter_per_ssot=true`. Actual `ERROR:`/`SCRIPT ERROR` entries are zero. The raw stderr/errors container contains 25 pre-existing compiler warnings from `SourceBlockGeometry.gd` and `SourceBuildingVisibilityState.gd`, plus their context lines; it is not an empty array. Stop output is retained separately.

The MCP project path was this checkout's actual `godot-mindustry` directory. The historical absolute worktree path in AGENTS.md is not this checkout. Native proof was stopped before the full Python run to release port 7777.

## Validation record

- RED: 2 expected architecture failures, 1 runtime test deselected.
- Emit: 801 classes, 0 failures.
- Focused GREEN: 55 passed, 91 subtests passed, 2877 deselected in 3.82s.
- Cross-catalog/JSON: 0 errors, 113 modules, 0 JSON errors; all nine validator counters zero.
- Native Godot MCP: 17/17 golden cases and BuildingComp composition pass; actual runtime errors 0; project stopped.
- Godot 4.6.2 headless editor parse: exit 0, no `ERROR:` or `SCRIPT ERROR` output.
- Full Python suite: **5344 passed / 22542 subtests passed in 948.46s** (15m48s), exit 0.
- Legacy generated liquid proof: exit 0, matches=true; compatibility helpers remain valid after canonical return-envelope delegation.
- Registration replay: unchanged ledger/mirror hashes (PASS).
- Slice diff checks pass. Exact slice staging preserves unrelated working-tree edits, including the pre-existing consumer-mirror header change.

Raw evidence is stored in `docs/superpowers/reports/evidence/2026-10-31-consume-liquid-generated-delegate/`. RED evidence remains RED; it is not overwritten by GREEN logs.

## Handoff: next coherent resource-storage checkpoint

Do not add a local dictionary of guessed liquids to Drill or duplicate consumer formulas in a gameplay caller. Keep the next unit of work focused on the missing upstream resource domain, then integrate it at the registered BuildingComp boundary.

1. **Inventory before edits:** reread all five root SSOT catalogs, the extension manifest/relevant shards, the ledger and existing liquid-related owners. Inspect `LiquidModule.java` fields, initialization, `get`, `add`, `remove`, `current`, `currentAmount` and flow-state dependencies. Reuse any existing canonical resource owner after checking semantics; create one cohesive resource-domain module only if none exists. The current generated `LiquidModule.get/add/remove` bodies return null.
2. **Specify a source-backed state contract:** preserve indexed liquid amounts, current-liquid identity and the `flow != null`/`cacheSums` effects wherever included in the selected slice. Every new boundary field, source owner and result shape must have exact Java evidence and be registered together. Do not silently assume flow is disabled or replace identity with a fabricated default.
3. **RED before implementation:** demonstrate missing storage behavior. Source `remove` delegates to `add(liquid, Math.max(-amount, -liquids[liquid.id]))`; source `add` changes the selected amount/current liquid and conditionally accumulates only positive flow. The test matrix must include partial/exact/overdraw removals, untouched second-liquid storage, repeated updates, and current/flow effects in the accepted scope. Preserve negative-request behavior if exposed; do not add a new nonnegative clamp based on the Java comment alone.
4. **Canonical GREEN:** make generated resource methods delegate to the domain owner, register all new symbols/contracts/schemas in the same slice, regenerate mirrors and prove replay idempotence. Storage mutation must use that owner; consumer formulas continue using `SourceConsumeLiquidState`.
5. **Integration checkpoint:** supply actual storage availability to generated efficiency, pass the result through the complete BuildingComp frame, and apply the requested removal through the resource owner. Independently prove before/after amounts across two ticks, starvation and no-consume conditions. Only then claim executable liquid resource consumption at that boundary.
6. **Acceptance:** focused tests, all catalog/JSON gates, full Python suite, native MCP with actual error check and stop, editor parse, updated ledger/checklist/report, exact staging and commit. One to three source-backed slices per turn; split storage and world integration at their real boundaries when needed.

Drill world integration follows only after its source-derived `shouldConsume`, item-capacity/enabled/dominant-item predicates, time/efficiency scaling, resource state and consumer instances can be supplied from actual runtime owners. Unimplemented dependencies stay explicit in the handoff rather than being converted into defaults or declared done.
