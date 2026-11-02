# Typed Item facts and Drill blocked-item initialization — N2011–N2013

Date: 2026-11-02. Parent: `295188b6`. This is the next prerequisite batch for C01-A, within the sequential C01–C12 completion goal. It connects the actual typed Item catalog and source Drill blocked-item metadata to the canonical N2010 ore-selection state. It does not close C01 or enable live mixed-ore gameplay.

## Checkpoints

| Gate | Requirement | Status |
| --- | --- | --- |
| OB-A | Exact source, existing ownership and expected RED | 6 failed / 2 passed in 0.95s, including three contract subtests |
| OB-B | Parser, inheritance, actual catalog/binding and prior Drill regression | 16 tests / 15 subtests pass in 28.06s; catalog 0 errors / 113 modules |
| OB-C | Full suite, native MCP/stop, editor | Accepted: 5372 / 22734 in 1091.66s; native matches=true; editor exit 0 |
| OB-D | Replay, exact scope/index audit and commit | Accepted: 13 hashes unchanged; exact staged audit retained |

## Source-backed module boundaries

### N2011 — actual Item numeric identity/effective fields

`Content.java:20–22` assigns `this.id = (short)Vars.content.getBy(getContentType()).size` before registering. `ContentLoader.java:175–177` appends to the matching type sequence. `Items.java.load()` construction order differs from its static field declaration order: copper is 0, lead 1, sand 4, thorium 7. The existing typed `MindustryContentCatalog.get_many("item")` retains that construction order.

`SourceContentRegistryRuntimeState.source_item_catalog_state` derives a transient view from that existing item sequence. It returns numeric facts shared between Java-field and slug maps, plus the inverse numeric-to-slug array. It does not call the global cross-type `get_by_id`, alphabetically sort IDs, cache a second registry or change existing slug identity. Each fact has the registered `source_drill_ore_item` shape: numeric `id`, effective `hardness`, `low_priority`.

`MindustryItem.low_priority` owns the Java implicit boolean false from `Item.java:39`, then source-explicit generated `lowPriority` overrides it. Effective hardness remains owned by the existing typed Item field and its source initialization. The catalog reads these typed fields; it does not introduce another hardness/priority fallback. This view covers the current builtin content registration sequence; arbitrary mod registration/overflow/reload lifecycle is not claimed.

### N2012 — generated blocked definitions and canonical init

`Drill.java:42–44` declares nullable `blockedItem`/`blockedItems`, initially null. `Drill.java:93–95` converts the legacy item only if the sequence is null. An explicit empty or nonempty sequence remains authoritative.

`content_registry._drill_blocked_defaults` follows actual Java class ancestry to Drill, retaining constructor overrides in parent-to-child order. It verifies the base nullable declarations before exporting defaults; incomplete fixtures or an unresolved constructor do not acquire guessed values. Unknown constructor definitions propagate unresolved status to descendants. BeamDrill has similar fields but is a separate class hierarchy and receives no Drill metadata from this resolver.

`_drill_blocked_definitions` tokenizes source, ignores comments and resolves only standalone unconditional null, `Items.<field>`, and direct `Seq.with(Items..., ...)` assignments. It preserves field identity and sequence order. Conditional/nested writes, dynamic expressions, mutations or unsupported constructors leave the whole blocked definition unresolved. No partial null fallback is emitted after an unresolved write. This is a bounded extraction capability, not a complete arbitrary-Java interpreter or dynamic mutation analysis.

Generation adds exactly `blockedItem` and `blockedItems` to six existing Drill/BurstDrill definitions: mechanical, pneumatic, laser, blast, impact and eruption. All items/liquids/units/waves/counts and other block properties stay unchanged. `Blocks.java:3080` explicitly sets impact-drill's `blockedItem = Items.thorium`; it is preserved as the Java field name `thorium`, not converted through a guessed slug. BeamDrill and unrelated blocks remain outside this extraction scope.

`SourceDrillRuntimeState.source_init_blocked_items_state` owns the runtime conditional and returns the same supplied sequence/null, or a new singleton only for the exact legacy conversion branch. No new production module is introduced.

### N2013 — actual Block → canonical numeric blocked sequence

`SourceDrillRuntimeState.source_bind_ore_items_state` requires both generated definition keys on the actual Block. Missing/unresolved metadata asserts rather than becoming null. Java field references resolve through the typed Item view to numeric IDs, then the binder delegates initialization to the N2012 canonical function. Source Block properties and Item definitions are not mutated; no second persistent blocked-item cache is added.

The result composes directly with N2010 `source_count_ore_state`. Proofs use actual content, actual impact-drill/BurstDrill properties and the canonical selection algorithm. This establishes typed facts and blocked initialization, not a world tile/proximity provider.

## Independent proof and regressions

`DrillOreBindingProof.tscn` checks 14 semantic cases plus registry validity and one-headquarter:

1. Independently expected builtin numeric IDs 0/1/4/7.
2. Copper source hardness/priority, sand true priority with default hardness zero, graphite default hardness zero.
3. Java `phaseFabric` → `phase-fabric` slug and numeric 11 share fact identity; item count matches the typed catalog.
4. A supplied typed catalog in nonalphabetical order retains IDs even when its global lookup returns a different content type.
5. Null legacy/sequence stays null.
6. Nonnull legacy with null sequence allocates the exact singleton.
7. Explicit empty sequence overrides legacy and preserves identity.
8. Existing nonempty sequence preserves identity/order.
9. Actual inherited impact-drill binds thorium ID 7 without source mutation.
10. Actual mechanical-drill remains unblocked.
11. Supplied explicit empty definition overrides legacy during hydration.
12. Java field sequence preserves order and leaves source strings unchanged.
13. Real sand/lead facts compose with N2010 priority selection; selected fact reference is retained.
14. Actual impact blocked sequence excludes thorium from countOre and selects mineable beryllium.

Python fixtures additionally prove comments, null/empty handling, dynamic/conditional rejection and multilevel constructor inheritance with unresolved descendants. The focused gate includes N2010 state, N2007–N2009 actual game-process liquid consumption and existing content-registry fixtures. This batch introduces no new pump, power, neighbor routing or mixed-ore game tick.

## SSOT and verification evidence

- **3 slices, 3 contracts, 7 schemas, 13 symbols** added. Ledger **1465 → 1468**.
- No existing root entry/policy edits, manifest entry or audit rewrite. Existing production and content mirrors regenerate through their registered selectors; catalog stays **113 modules**.
- Generated content delta is restricted to the two blocked-definition keys on six existing blocks. The generated GD registry is emitted from canonical content; it is not patched by hand.
- Final focused gate: **16 passed / 15 subtests in 28.06s**. Pre-full validator: **0 errors / 113 modules / 0 JSON errors**, all nine counters zero.
- Full suite: **5372 passed / 22734 subtests passed in 1091.66s**; complete log retained.
- Native MCP: **16/16 checks true, matches=true**, explicit stop, **0 actual errors / 23 compiler warnings**. Editor parse: **exit 0**, no actual errors. Raw debug and stop retained.
- Content+SSOT replay: **13 raw SHA256 hashes unchanged**. Final catalog **0 errors / 113 modules / 0 JSON errors**. Exact root/content/runtime scope and staged whitespace audit pass; see `index-final.log`.

Evidence directory: `evidence/2026-11-02-drill-item-blocked-binding/`. It retains RED/focused/full output, parser and actual runtime proof, diagnostics, replay hashes, semantic staging scope and index audit.

The working tree contains extensive earlier facade/source-text refactors. Semantic JSON and contextual runtime deltas reconstruct this batch's index from parent HEAD, preserving that prior work. The GD content artifact is regenerated from the staged canonical content payload. Acceptance describes the tested canonical working tree; it does not establish clean-checkout release readiness. Project settings, UID noise and arc-upstream stay outside the commit.

## Next sequential checkpoint

C01-A still requires actual world `Tile.drop`/`Block.isStatic`/linked-footprint facts. Current terrain projection derives ores from overlay names and does not export effective floor/overlay drops or cache-layer semantics; do not turn its missing fields into false/null defaults.

Continue with source-backed terrain/block metadata and Tile providers, then C01-B proximity invalidation and C01-C actual dominant output binding. Only after those gates open live mixed-ore gameplay, move to C02 per-Building output/dump/transport. C03–C12 remain tracked in `../handoffs/2026-11-02-mindustry-completion-backlog.md`; none is marked complete by this batch.

## Reproduction

```powershell
python -c "import sys;from pathlib import Path;sys.path.insert(0,'tools/mindustry_godot_transpiler');from mindustry_port.content_registry import write_content_registry;write_content_registry(Path('mindustry-upstream'),Path('godot-mindustry'))"
python tools/mindustry_godot_transpiler/register_drill_ore_binding.py
python -m pytest -q -p no:cacheprovider tools/mindustry_godot_transpiler/tests/test_drill_ore_binding.py tools/mindustry_godot_transpiler/tests/test_drill_ore_selection.py tools/mindustry_godot_transpiler/tests/test_drill_live_consumption.py tools/mindustry_godot_transpiler/tests/test_content_registry.py --tb=short
python -m pytest -q -p no:cacheprovider tools/mindustry_godot_transpiler/tests --tb=short
```

After full success run `DrillOreBindingProof.tscn` through native Godot MCP against this checkout, inspect all output and explicitly stop. Then editor parse, complete content+SSOT regeneration replay and final catalog gate. Retain compiler warnings separately from actual errors.
