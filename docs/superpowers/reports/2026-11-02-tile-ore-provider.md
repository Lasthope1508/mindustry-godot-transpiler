# Source terrain definitions and canonical Tile ore providers — N2014–N2016

Date: 2026-11-02. Parent: `1b74e8c3`. C01-A prerequisite batch in the sequential C01–C12 goal. This batch repairs missing source content and binds actual typed Block objects to existing canonical Tile/static/linked geometry. It does not close C01-A or connect the game world's terrain/proximity/output lifecycle.

## Checkpoints

| Gate | Evidence | Status |
| --- | --- | --- |
| TO-A | Source/ownership inventory and expected RED | 6 failures / 1 pass in 2.67s, including two contract subtests |
| TO-B | Focused regression, complete catalog and exact semantic scope | 22 tests / 19 subtests in 38.30s; catalog 0 errors / 113 modules; scope accepted |
| TO-C | Full suite and native MCP/inspect/stop | Accepted: 5379 / 22748 in 1071.39s; native 17 checks true; explicit stop |
| TO-D | Editor parse, deterministic replay, exact index/commit | Editor exit 0; 10 hashes unchanged; exact staged audit in index-final.log |

## Cohesive ownership

No new production GDScript module, facade, manifest entry, geometry formula, registry owner or alternate ore-selection algorithm is introduced. Existing owners are reused:

- `SourceBlockGeometry.tile_drop_state` remains the sole Tile.drop conditional.
- `SourceBlockQueryBasicState.is_static_state` remains the sole walls-cache comparison.
- `SourceBlockGeometry.tile_get_linked_tiles_as_array_state` remains the sole linked-footprint traversal.
- `SourceDrillRuntimeState.source_count_ore_state` remains the sole priority/count/numeric-Item-ID selection algorithm.
- The existing `SourceWorldTerrainRuntimeState` owns the new object/projection binding functions.
- The new Python `terrain_content.py` is one bounded source extraction capability used by the existing content-registry generator. Generated JSON/GD content is regenerated, never manually patched.

## N2014 — source constructor terrain definitions

`Block.java:182` explicitly initializes nullable `itemDrop = null`; `Block.java:233` initializes `cacheLayer = CacheLayer.normal`. `StaticWall.java:31` and `Cliff.java:17` assign walls. Source content initializers set floor drops and liquid/cache-layer overrides. `OreBlock.java:17–27` accepts either a name plus Item or an Item-only constructor delegating to `this("ore-" + ore.name, ore)`. Names come from the actual Item definition, not a conversion of the Java Block field.

The extractor follows selected constructor signatures, superclass/this delegation, field initializers and direct anonymous initializers through actual class ancestry. It uses javalang ASTs for constructor bodies, selected assignments and initializer bodies. Source tokens delimit constructors/creators. It evaluates only the bounded String/int/Item arguments, literal/null values, Items fields, CacheLayer fields and String concatenation used by these definitions. Conditional, nested, dynamic and unsupported writes stay unresolved and propagate through inheritance. A supplied direct source override can resolve its own field; missing metadata is never converted into false/null by the runtime binder.

Post-construction writers conservatively invalidate metadata. The extractor validates the reference-preserving init→setup(itemDrop) assignment pattern from ASTs, including the absence of Item-parameter reassignment, before retaining OreBlock's constructor Item. ShallowLiquid's later `set()` cache assignment stays unresolved. This is not a complete arbitrary-Java interpreter, whole-program mutation analysis, mod loader or reload lifecycle.

The Java-8 lexer miscounts source positions inside Java text blocks. The creator scan masks their contents while preserving every offset and newline; terrain expressions themselves do not accept text-block values. A fixture places a real creator after a multiline text block and a commented fake creator. Scope auditing caught the initial position regression before full acceptance; final extraction preserves every preexisting content property.

Eight previously omitted builtin definitions are added in source registration order: ore-copper, ore-lead, ore-scrap, ore-coal, ore-titanium, ore-thorium, ore-beryllium and ore-tungsten. Existing entries gain only `itemDrop`/`cacheLayer`; block count becomes **417 → 425**. Items/liquids/units/waves/assets and existing Block properties stay unchanged. Two stale tests asserting 417 now verify canonical collection/count consistency; independent fixtures and source goldens cover the actual new entries and Item/name mapping.

Unsupported definitions and their source locations are recorded in `terrain-inventory.json` in the evidence directory. Missing fields are observable boundaries, not accepted default values.

## N2015 — actual typed Tile input → canonical ore facts

`Tile.java:46–49` retains actual block/floor/overlay references. `Tile.java:571–573` chooses the floor drop when overlay is the canonical air reference or has null itemDrop; otherwise it chooses the overlay drop. `Block.java:1100–1102` defines static through the walls cache layer, independently of solidity or occupancy.

`source_tile_ore_state` receives a Tile projection containing those actual typed objects, the existing N2011 typed Item view and the actual canonical air object. It requires resolved explicit itemDrop definitions for floor/overlay and cacheLayer for the occupying block. Item field references resolve through the typed map to shared canonical numeric Item facts. The binder delegates drop/static behavior and returns the existing canMine/countOre-compatible `{is_static, drop}` shape. Air equality uses object identity; a different object with the same `air` slug does not become canonical air. Source objects are not mutated or cached.

The provider requires complete metadata even for an unselected drop branch; that is its declared input precondition, not an invented runtime fallback. A separate negative headless test deliberately supplies unresolved metadata, requires the specific assertion and verifies that no successful proof is emitted. That expected negative-test diagnostic is distinct from native acceptance, which requires zero actual errors.

## N2016 — canonical linked traversal and Tile binding

`Tile.java:502–524` clears its temporary list, iterates source dx→dy order with actual initialized sizeOffset, excludes null world lookups and uses this directly for non-multiblocks.

`source_linked_ore_tiles_state` passes the supplied source geometry and world callback to the existing canonical geometry owner. It projects the resulting actual typed Tile inputs through N2015. It does not calculate an alternate footprint, scan the whole map, default missing world tiles to ore or establish another simulation-state store.

The proof's world is an explicit sparse callback of actual source-backed Block objects. Actual game-world loading/storage, canonical initialized Block geometry binding, mutation/proximity events and production-output application are **not** established by this supplied-world proof. Those are the next C01 checkpoints.

## Independent semantic proof

`TileOreProviderProof.tscn` checks 15 semantic cases plus registry validity/one-headquarter:

1. Actual sand floor drop maps to the shared sand fact.
2. Non-air overlay with null drop falls back to the floor.
3. Actual Item-only ore constructor supplies copper.
4. ore-crystal-thorium returns thorium despite its different slug.
5. Actual stone with air has explicit null drop.
6. Static stone wall blocks canMine while preserving underlying drop.
7. Cliff is static through its own source constructor.
8. A placed mechanical Drill is not a static wall.
9. Air identity is independent of matching slug.
10. A 2×2 footprint preserves exact source callback order.
11. Actual sand/lead/copper/static-wall facts compose with canonical priority/count/ID selection.
12. Odd size/negative offset and world bounds retain only real tiles.
13. Single tile uses this without any world lookup.
14. Empty world gives an empty footprint and null selected ore.
15. Input definitions and world object references stay unchanged.

Python fixtures also cover generic constructor names/Item names, this/super delegation, inherited static defaults, unsupported conditional and late writes, anonymous method writes, explicit nulls and text-block positions. Legacy Item/blocked/ore-selection and content-registry tests remain in the focused gate.

## Gates and evidence

- SSOT delta: **3 slices / 2 contracts / 6 schemas / 20 symbols**. Canonical ledger **1468 → 1471**. Prior entries and policy metadata preserved.
- Catalog: **0 errors / 113 modules / 0 JSON errors**; all nine cross-catalog counters zero. Direct extension manifest remains 100 entries; 113 includes canonical modules.
- Full suite: **5379 passed / 22748 subtests passed in 1071.39s**, complete log retained. The earlier safety-review interruption is retained separately and is not counted as a successful gate.
- Native MCP: **17/17 checks true, matches=true**; **0 actual errors / 23 compiler warnings**. Debug and explicit stop inspected. Editor parse: **exit 0**, no actual errors.
- Complete content+SSOT replay: **10 raw SHA256 hashes unchanged**. Final catalog accepted. Exact root/content/runtime staged audit and whitespace gate are retained in `index-final.log`.
- Gates apply to the current working tree. Clean-checkout regeneration and release acceptance remain C12. Preexisting dirty refactors/settings/UID/arc files are excluded from this batch's commit.

## Next sequential checkpoint

C01-A still requires a real world terrain/Tile provider and initialized geometry binding in the actual game lifecycle. Replace ore-name projection with canonical source facts when that wiring is ready; do not relabel the supplied callback proof as live gameplay. Then finish C01-B proximity assignment/invalidation and C01-C production/offload from each Building's actual dominant item. C02–C12 remain open in the completion backlog.

## Reproduction

```powershell
python -c "import sys;from pathlib import Path;sys.path.insert(0,'tools/mindustry_godot_transpiler');from mindustry_port.content_registry import write_content_registry;write_content_registry(Path('mindustry-upstream'),Path('godot-mindustry'))"
python tools/mindustry_godot_transpiler/register_tile_ore_provider.py
python -m pytest -q -p no:cacheprovider tools/mindustry_godot_transpiler/tests/test_tile_ore_provider.py tools/mindustry_godot_transpiler/tests/test_drill_ore_binding.py tools/mindustry_godot_transpiler/tests/test_drill_ore_selection.py tools/mindustry_godot_transpiler/tests/test_content_registry.py --tb=short
python -m pytest -q -p no:cacheprovider tools/mindustry_godot_transpiler/tests --tb=short
```

After full success run the proof scene through native Godot MCP against this checkout. Inspect all debug output and explicitly stop. Run editor parse, complete content+SSOT replay and final catalog gate; retain compiler warnings separately from actual errors. Exact semantic staging must regenerate GD content from the staged canonical JSON so unrelated dirty content cannot enter the commit.
