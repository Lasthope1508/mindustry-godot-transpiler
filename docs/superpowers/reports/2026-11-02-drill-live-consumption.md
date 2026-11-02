# Concrete liquid consumers and automatic Drill gameplay — N2007–N2009

Date: 2026-11-02. Parent: `e97eb17c`. This batch implements both the concrete liquid consumer adapter and game-loop-driven Drill consumption/production for the current single-ore, power-free base-Drill gameplay. It also fixes the canonical building traversal used for time-scale decay. This is a bounded gameplay checkpoint, not complete Drill/Mindustry parity.

## Checkpoints

| Gate | Requirement | Status |
| --- | --- | --- |
| DL-A | Read source/SSOT and prove missing behavior | Expected RED: 6 failures / 1 passed in 11.90s, including 4 contract subtests |
| DL-B | Canonical adapter, traversal and actual game-process proof | Focused 14 tests / 20 subtests in 74.95s; final proof 3 tests / 4 subtests in 19.31s; two corrected boundary regressions pass |
| DL-C | Full suite, final native MCP, editor parse | Accepted: 5364 tests / 22683 subtests in 1030.23s; native matches=true; editor exit 0 |
| DL-D | Replay, final catalog, exact checkpoint staging/commit | Accepted: 14 hashes unchanged; exact index audit retained in evidence |

## Module boundaries and source evidence

### N2007 — concrete liquid consumer adapter

`SourceConsumeState.source_cost_multiplier_state(build)` owns the default **cost** callback from `Consume.java:18`, `multiplier = b -> 1f`. This remains separate from `efficiencyMultiplier(Building)` and its existing canonical method. The new callback is an explicit adapter boundary with a registered dictionary result; production bindings supply the source default, and the proof supplies a non-default callback returning two.

`SourceConsumeLiquidState.RuntimeConsumer` is a concrete RefCounted adapter with `efficiency(build)` and `update(build)` methods. `source_runtime_consumer_state` binds the shared typed Block descriptor, actual Building LiquidModule frame, explicit shared-flow-cache input and cost callback. It does not copy the Block amount/flags or create another liquid array.

- `BuildingComp.java:1922–1928` supplies delta/edelta; the adapter calls `SourceBuildingTimeState.edelta` in both passes.
- `ConsumeLiquid.java:39–48` supplies update and efficiency. The adapter delegates to the existing `SourceConsumeLiquidState.efficiency_state/update_state` owners.
- Actual storage access/mutation delegates to `SourceLiquidModuleState.source_get_state/source_remove_state`; source removal clamping and current-liquid behavior stay there.
- Source tick delta and actual Building timeScale are refreshed before both passes. `efficiency_scale` is read from the Building frame, after canonical setup has established the first-pass efficiency.
- Adapter instances are cached per Building and reused across ticks. Their `definition` references remain Block-owned, while `liquids` references remain Building-owned.

The consumer slice's `generated_owner` is explicitly empty: this is a production adapter around existing canonical methods, not a fabricated generated Java method. The consumer mirror requires the field but no generated method is claimed.

### N2008 — one visit per real Building

Upstream `Logic.java:476`, `Groups.build.update()`, updates buildings once each. The existing placement owner records every occupied cell in `placed_blocks`; several keys can reference one Sprite2D. `placed_block_origins` holds origin coordinates, not Sprite2D instances.

`SourcePlacedBlockState.source_unique_buildings_state(game)` derives a transient unique list from the existing `placed_blocks` values, filters invalid/freed instances and deduplicates by instance identity. It creates no second persistent building registry. Existing `simulate_time_scales` now uses this list instead of passing Vector2i origin values to sprite decay. The new Drill tick consumes the same traversal owner.

The proof places two real 2×2 buildings. Four occupied-cell references produce one visit to each instance. A time-scale duration of 100 becomes 99 after one source tick, rather than decaying four times or failing to decay because the loop read coordinates as sprites. Source time-scale decay still occurs before consumption in the existing game-loop order.

### N2009 — automatic consumption and production composition

`SourceDrillConsumptionRuntimeState.gd` is the only new production module. It binds the preceding owners to the existing factory game loop. It does not implement another rate, removal, clamp, warmup or production formula.

1. Derive the typed Block lookup once per tick, using the canonical loaded Block catalog. This temporary lookup is not another content registry. Dispatch class identity through the existing canonical generated Drill path. No block-name allowlist or hand-copied liquid rate is used.
2. Select supported base-Drill definitions with resolved direct liquid descriptors and no explicit `consumePower`. In the immutable current upstream catalog these are mechanical and pneumatic drills. Laser/blast drills require their power consumer domain. Generic `hasPower/consumesPower` metadata is not used to infer an absent power consumer.
3. Resolve a single ore identity from the canonical ore-cell map, check source tier/hardness, and use the existing ore-count owner. A footprint with multiple ore identities remains unresolved; full `countOre` priority sorting is not invented. A footprint with no mineable ore yields null dominantItem and zero dominantItems.
4. Retain one registered Building frame on the sprite. `enabled=true` and ordinary field initialization come from BuildingComp/DrillBuild; the initial non-cheating value models the current loaded campaign's default TeamRule. A live TeamRules provider/reload is not introduced here.
5. Compute `shouldConsume` exactly from `Drill.java:247–249`: item total below capacity, enabled, and non-null dominant item. Reuse canonical base productionValid, efficiencyScale, consumer classification and the full `SourceBuildingEfficiencyState.update_consumption_state/apply_update_consumption_state` pair. The apply adapter assigns efficiencies before dispatching actual consumer updates. Required/optional/update/ignored semantics stay in those owners.
6. Compute Drill speed from the exact source lerp expression at `Drill.java:301`; unboosted speed and liquidBoostIntensity are registered in the existing `SourceFactoryDefaults` owner. Existing canonical runtime shell, warmup, last-speed, delta and production owners produce the event. Null-ore return preserves warmup/timeDrilled/progress; the inactive/full branch still advances timeDrilled before its source branch, using the canonical timeDrilled delta helper.
7. Feed the primary event into existing factory composition so production executes once. Existing primary offload/dump/transport application remains in `SourceFactoryRuntimeState`. Primary inventory/progress are synchronized with their existing demo owners; the frame does not replace them with a second amount store. Secondary drills retain independent local inventory/progress and publish per-cell warmup/timeDrilled/last-speed through existing cell owners. Complete secondary neighbor routing and dump timers are deferred.

`SourceFactoryRuntimeState.simulate_factory` now calls this live composition at its existing simulation boundary. Existing standalone preview/state APIs remain available and pure; a stale cached event is not substituted into those APIs. Native real process callbacks and deterministic `_process(delta)` calls therefore drive actual consumption and Drill production without manually invoking a proof consumer.

This supported gameplay has `flow=null`, matching the existing LiquidModule initialization. The live binder asserts that condition before supplying an unused empty cache input. The concrete adapter itself can receive an explicit canonical cache array, but automatic active-flow cache ownership/lifecycle is still outside this checkpoint. There is no invented static flow-cache default.

## Independent proof matrix

`DrillLiveConsumptionProof.gd/.tscn` runs the actual Main scene and campaign placement:

| Case | Independent expected behavior |
| --- | --- |
| Adapter with amount .05, source delta 1, timeScale 2, multiplier callback 2, water .15 | Efficiency .75; canonical removal clamps storage to zero; shared descriptor identity retained |
| Default cost callback | Returns one through its own source-backed owner, without calling efficiencyMultiplier |
| Two 2×2 buildings | Each sprite occurs once in traversal despite four cell entries; liquid frames remain independent |
| Primary water .125, scale 1 | Controlled game ticks leave .075, .025, then zero |
| Secondary water .2, scale 2 | Controlled game ticks leave .1, then zero; duration 100→99 on the first tick |
| Partial optional water | Primary optionalEfficiency .5 while base efficiency remains one |
| Dry optional booster | Base efficiency stays one, optionalEfficiency zero, speed one, real primary progress continues |
| Disabled secondary | No water removal, efficiency zero, progress unchanged |
| Full primary inventory | No water removal and efficiency zero for that tick |
| No ore | Null dominantItem, efficiency zero and no water removal |
| Repeated ticks | Same concrete adapter and Building liquid frame identities reused |
| Autonomous scheduling | Re-enable real `_process`, await actual process frames, then verify water decreases |
| Registry | Valid canonical registry and one headquarter per SSOT |

Proof numbers and positions are explicit test inputs, not production defaults. This proof demonstrates both supplied-resource automatic consumption and live production progression. It does not claim that pumps/fluid transport already fill the drill automatically, or that every upstream Drill subclass/ore/output network has parity.

## SSOT and acceptance evidence

- N2007–N2009 add **3 slices**; ledger becomes **1464**.
- **5 contracts, 12 schemas, 40 symbols**. Adapter bindings, persistent Building frame fields, metadata identity and source boost constants are registered in the same batch.
- No existing root entry or policy value changes. Manifest, audit report, generated content registry and content counts remain unchanged; validated catalog remains **113 modules**.
- Consumer slice/contract mirrors gain N2007. Production slice/contract mirrors gain N2009; production schema/symbol mirrors are rebuilt through their existing manifest selection. N2008 is rooted in Logic.java, so no forced Block-domain mirror is invented.
- The first validator caught missing production schema/symbol mirrors. Registration now regenerates slice, contract, schema and symbol mirrors in dependency order. No full suite was started while that validator was red.
- Focused runtime group: **14 passed / 20 subtests in 74.95s**. Final focused proof after the last code change: **3 passed / 4 subtests in 19.31s**.
- Broader regression selection initially had 52 passing tests and two failures that required the old factory dispatcher string. Only those two source-boundary assertions were updated to the new canonical live composition. Their rerun passes **2 tests / 2 subtests in 34.95s**. Existing production, callback and output assertions remain. The new runtime proof independently checks the resulting behavior.
- Pre-full validator: **0 errors / 113 modules / 0 JSON errors**, all nine category counters zero.
- Full suite: **5364 passed / 22683 subtests passed in 1030.23s**. Complete output retained in `full.log`.
- Native MCP: **matches=true**, all 13 proof checks true, explicit stop verified; **0 actual errors / 66 compiler warnings**. Raw debug and stop errors arrays contain these warnings and are retained. Editor parse: **exit 0**, no actual errors.
- Registration replay: **14 raw SHA256 hashes unchanged**, including manifest/audit/content. Final catalog: **0 errors / 113 modules / 0 JSON errors**, all nine category counters zero.
- Exact staged scope: only this batch additions/deltas, new registration/test/proof files, checklist/report and evidence. Prior root entries/policies and unrelated dirty refactors remain preserved. Staged whitespace and exact index audit pass; see `index-final.log`.

Evidence directory: `evidence/2026-11-02-drill-live-consumption/`.

The workspace includes extensive prior source-text and facade refactors. Before snapshots and semantic/text deltas preserve them outside this commit. The index is reconstructed from HEAD plus only this batch's runtime/SSOT/test changes. Full-suite and runtime acceptance refer to the canonical working tree used for migration; they do not certify an isolated clean checkout of unrelated uncommitted changes. `project.godot`, UID files, arc-upstream and unrelated facade work remain unstaged.

## Reproduction

```powershell
python tools/mindustry_godot_transpiler/register_drill_live_consumption.py
python -m pytest -q -p no:cacheprovider tools/mindustry_godot_transpiler/tests/test_drill_live_consumption.py tools/mindustry_godot_transpiler/tests/test_liquid_consumer_apply_hydration.py tools/mindustry_godot_transpiler/tests/test_liquid_consumer_hydration.py tools/mindustry_godot_transpiler/tests/test_placed_liquid_ownership.py --tb=short
python -m pytest -q -p no:cacheprovider tools/mindustry_godot_transpiler/tests --tb=short
```

After full success, run `tools/runtime_proofs/DrillLiveConsumptionProof.tscn` through native Godot MCP against this checkout's actual `godot-mindustry` directory. Inspect actual ERROR/SCRIPT ERROR entries separately from compiler warnings, explicitly stop and inspect final output, then run editor parse, deterministic registration replay and final catalog validation. Do not mutate catalogs during the full suite.

## Next checkpoints and limits

1. **Power and complete consumer coverage:** add source-backed power consumer adapters before allowing laser/blast drills into the new supported tick path. Do not use the absence of an amount schema, an optional booster, or broad capability flags to assume power is free. Other consumer factories/inherited consumers and dynamic source expressions remain separate.
2. **Mixed ore/proximity lifecycle:** port complete countOre sorting, lowPriority/count/numeric-id tiebreaks, blockedItems, canMine/static tile semantics and proximity invalidation. Current single-ore map projection must not be relabeled full ore-selection parity.
3. **Secondary output transport:** compose existing source offload/dump/timer owners with each secondary Building inventory. Keep one inventory owner, scope neighbor context to the actual origin, and prove output routing and capacity with multiple buildings. Current local fallback does not establish neighbor routing parity.
4. **Rules and runtime mutation:** connect live team cheating rules and Block consumer reinitialization/reload through their source lifecycle. Invalidate descriptor/apply/adapter caches together; do not append an alternate registry or silently retain old definitions.
5. **Liquid flow and supply:** bind the canonical shared flow cache lifecycle, flow timers/display, serialization and resource transport. Current automatic ticks consume supplied stored water; they do not introduce a pump network or another liquid array.
6. **Conformance expansion:** test pneumatic defaults, more ore tiers and additional real maps within the supported source class before expanding the acceptance claim. Keep rendering/effects outside numeric consumption proof unless their source behavior is ported explicitly.
7. **Gate discipline:** continue in 1–3 coherent slices with RED, focused, catalog/JSON, full suite, native proof/stop, editor, replay, checklist/report and exact commit. Preserve prior dirty work and keep production formulas inside their canonical domain owners.
