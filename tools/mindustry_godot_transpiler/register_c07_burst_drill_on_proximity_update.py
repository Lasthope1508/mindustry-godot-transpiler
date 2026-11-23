"""Register the BurstDrill ore / dominant-item binding (N2302).

DrillBuild.onProximityUpdate assigns the dominant ore from the
linked tiles (Drill.java:266-277, `public void
onProximityUpdate(){` with `super.onProximityUpdate();` /
`countOre(tile);` / `dominantItem = returnItem;` /
`dominantItems = returnCount;`) and BurstDrillBuild inherits
it whole (BurstDrill.java:17, `public class BurstDrill
extends Drill{`, with BurstDrillBuild, BurstDrill.java:70,
`public class BurstDrillBuild extends DrillBuild{`, and
DrillBuild, Drill.java:237, `public class DrillBuild extends
Building{`) -- BurstDrill does not override it. countOre
(Drill.java:198-229, `protected void countOre(Tile tile){`)
resets the return and the tallies (`returnItem = null;` /
`returnCount = 0;` / `oreCount.clear();` /
`itemArray.clear();`), counts the drop of every linked tile
canMine accepts (`for(Tile other : tile.getLinkedTilesAs(this,
tempTiles)){` / `if(canMine(other)){` /
`oreCount.increment(getDrop(other), 0, 1);`), collects the
counted items (`for(Item item : oreCount.keys()){` /
`itemArray.add(item);`), sorts them low-priority-last, then by
count, then by id (`int type = Boolean.compare(!item1.
lowPriority, !item2.lowPriority);` / `if(type != 0) return
type;` / `int amounts = Integer.compare(oreCount.get(item1, 0),
oreCount.get(item2, 0));` / `if(amounts != 0) return amounts;`
/ `return Integer.compare(item1.id, item2.id);`) and peeks the
last one (`if(itemArray.size == 0){` / `returnItem =
itemArray.peek();` / `returnCount = oreCount.get(itemArray.
peek(), 0);`). canMine (Drill.java:230-235, `public boolean
canMine(Tile tile){`) rejects a null or static tile (`if(tile ==
null || tile.block().isStatic()) return false;`) and requires
a drop whose hardness is at most the tier and which is not
blocked (`Item drops = tile.drop();` / `return drops != null &&
drops.hardness <= tier && (blockedItems == null ||
!blockedItems.contains(drops));`). The fields are `public int
tier;` / `public @Nullable Item blockedItem;` / `public
@Nullable Seq<Item> blockedItems;` / `protected @Nullable Item
returnItem;` / `protected int returnCount;` / `public int
dominantItems;` / `public Item dominantItem;`
(Drill.java:239-244). Drill.init (Drill.java:93-94) turns a
lone blockedItem into the list (`if(blockedItems == null &&
blockedItem != null){` / `blockedItems =
Seq.with(blockedItem);`).

RED decisions (resolved at RED): (1) One pure function on the
same family file N2256 built, delegating to the N2010/N2020
core (SourceDrillRuntimeState.
source_on_proximity_update_state) instead of porting countOre
again -- one pure function, one owner -- following the
N2256 precedent: (linked_tiles, tier, blocked_items) and NO
driver tick line, because proximity update runs at placement,
not per tick. (2) The live driver already stamps the frame:
the placement callback (SourceWorldTerrainRuntimeState.gd:116)
calls SourceDrillConsumptionRuntimeState.
source_on_proximity_update_state for every placed build, and
that driver stamps frame["dominant_item"] /
frame["dominant_items"] under the shared meta key
"source_drill_building" -- the same key as
SOURCE_BURST_DRILL_BUILDING_META_KEY
(SourceBurstDrillBuildState.gd:27) -- so the burst-drill
frame IS the drill frame. The driver gate is the catalog key,
not the value: it returns {"applied": false} only when
block.properties lacks "blockedItems", and the catalog carries
that key (null-valued) for BOTH defs -- impact-drill
blockedItem thorium / blockedItems null, eruption-drill
blockedItem null / blockedItems null -- so applied is true for
both, and the bind helper (SourceDrillRuntimeState.
source_bind_ore_items_state) resolves impact to blocked_items
[thorium] and eruption to blocked_items null. (3) The per-def
tier / blockedItem are explicit params (the N2212 / N2248
per-def-param precedent): impact-drill tier 6
(Blocks.java:3076, `tier = 6;`) with blockedItem thorium
(Blocks.java:3080, `blockedItem = Items.thorium;`);
eruption-drill tier 7 (Blocks.java:3097, `tier = 7;`) with no
blocked item. (4) The pickedUp reset (`public void
pickedUp(){` / `dominantItem = null;`, Drill.java:264-266)
is inherited too but waits for its own slice. Two new result
symbols: dominant_item, dominant_items. Slice sources:
BurstDrill.java + Drill.java + Blocks.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_burst_drill_icons import DEFERRED as N2312_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BURST_DRILL = 'core/src/mindustry/world/blocks/production/BurstDrill.java'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07BurstDrillOnProximityUpdateProof'
ON_PROXIMITY_UPDATE_OWNER = 'SourceBurstDrillBuildState.source_burst_drill_on_proximity_update_state'
TESTS = ['test_c07_burst_drill_on_proximity_update_registration', 'test_all_c07_burst_drill_on_proximity_update_input_evidence_is_exact', 'test_burst_drill_on_proximity_update_state', 'test_reference_graph_and_actual_c07_burst_drill_on_proximity_update']
# The 3 slice sources the N2302 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BurstDrill.java',
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['protected void countOre(Tile tile){', 'returnItem = null;', 'returnCount = 0;', 'oreCount.clear();', 'itemArray.clear();', 'for(Tile other : tile.getLinkedTilesAs(this, tempTiles)){', 'if(canMine(other)){', 'oreCount.increment(getDrop(other), 0, 1);', 'for(Item item : oreCount.keys()){', 'itemArray.add(item);', 'int type = Boolean.compare(!item1.lowPriority, !item2.lowPriority);', 'if(type != 0) return type;', 'int amounts = Integer.compare(oreCount.get(item1, 0), oreCount.get(item2, 0));', 'if(amounts != 0) return amounts;', 'return Integer.compare(item1.id, item2.id);', 'if(itemArray.size == 0){', 'returnItem = itemArray.peek();', 'returnCount = oreCount.get(itemArray.peek(), 0);', 'public boolean canMine(Tile tile){', 'if(tile == null || tile.block().isStatic()) return false;', 'Item drops = tile.drop();', 'return drops != null && drops.hardness <= tier && (blockedItems == null || !blockedItems.contains(drops));', 'public void onProximityUpdate(){', 'super.onProximityUpdate();', 'countOre(tile);', 'dominantItem = returnItem;', 'dominantItems = returnCount;', 'public int tier;', 'public @Nullable Item blockedItem;', 'public @Nullable Seq<Item> blockedItems;', 'protected @Nullable Item returnItem;', 'protected int returnCount;', 'public int dominantItems;', 'public Item dominantItem;', 'if(blockedItems == null && blockedItem != null){', 'blockedItems = Seq.with(blockedItem);', 'public void pickedUp(){', 'dominantItem = null;', 'public class DrillBuild extends Building{', 'public class BurstDrill extends Drill{', 'public class BurstDrillBuild extends DrillBuild{', 'tier = 6;', 'blockedItem = Items.thorium;', 'tier = 7;']

# DEFERRED is carried from the N2312 register script via import --
# never retyped. One carried entry is DROPPED here, not carried:
# the BurstDrill ore / dominant-item binding entry -- N2302 IS the
# ore / dominant-item binding slice, so carrying it would leave a
# stale "waits for its own slice" row for done work.
DEFERRED = [e for e in N2312_DEFERRED if 'BurstDrill ore / dominant-item binding' not in e] + [
    'BurstDrill ore / dominant-item binding Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2227: the N2302 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BurstDrill pickedUp reset (dominantItem = null, Drill.java:264-266, inherited by BurstDrillBuild) -- the N2302 proof carries no pickedUp key; the reset waits for its own slice.',
    'BurstDrill placed-sprite live proximity run (SourceWorldTerrainRuntimeState on_proximity_update callback stamping a placed burst-drill sprite) -- the N2302 proof verifies the catalog blockedItems key and the bind inputs the live driver reads, but runs no placed sprite; the placed-sprite run waits for its own slice.',
]


def definitions():
    def a(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    on_proximity_update_inputs = {
        'linked_tiles': a('Array', 'for(Tile other : tile.getLinkedTilesAs(this, tempTiles)){', 'The linked tiles countOre scans: Tile.getLinkedTilesAs over the drill footprint (Drill.java:206); each tile carries is_static and a drop (null when the tile drops nothing), the same tile shape the N2010 core reads.', source=DRILL),
        'tier': a('int', 'tier = 6;', 'The per-def drill tier, 6 for the impact-drill def (Blocks.java:3076) and 7 for the eruption-drill def (Blocks.java:3097); the canMine gate reads drops.hardness <= tier (Drill.java:233). The field is `public int tier;` (Drill.java:239); passed explicitly (the N2212 / N2248 per-def-param precedent).', source=BLOCKS),
        'blocked_items': a('Variant', 'if(blockedItems == null && blockedItem != null){', 'The blocked list: null when the def has no blocked item (eruption-drill), otherwise the blocked items (impact-drill thorium, Drill.init Drill.java:93-94 turns a lone blockedItem into Seq.with(blockedItem)); canMine treats null as "nothing blocked" (Drill.java:233). Passed explicitly because the bind resolution (SourceDrillRuntimeState.source_bind_ore_items_state) is what the live driver calls.', source=DRILL),
    }
    on_proximity_update_outputs = {
        'dominant_item': a('Variant', 'dominantItem = returnItem;', 'The dominant item after the count: returnItem, the peeked last item after the low-priority / count / id sort (Drill.java:227-228, `returnItem = itemArray.peek();`), null when no linked tile is mineable (Drill.java:224-225).', source=DRILL),
        'dominant_items': a('int', 'dominantItems = returnCount;', 'The dominant count after the count: returnCount, the ore count of the peeked item (Drill.java:229, `returnCount = oreCount.get(itemArray.peek(), 0);`), 0 when no linked tile is mineable.', source=DRILL),
    }
    return on_proximity_update_inputs, on_proximity_update_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
        upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
        total += len(keys)
        for field, meta in keys.items():
            source = meta['java_source']
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
            if meta['java_expr'] not in text:
                missing.append('%s: %s' % (field, meta['java_expr']))
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    on_proximity_update_inputs, on_proximity_update_outputs = definitions()

    entries = [
        ('N2302', ON_PROXIMITY_UPDATE_OWNER, 'source_burst_drill_on_proximity_update_state', BURST_DRILL, 'mindustry.world.blocks.production.BurstDrill.BurstDrillBuild', 'DrillBuild.onProximityUpdate()', on_proximity_update_inputs, on_proximity_update_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BurstDrill ore / dominant-item binding from Drill.java + BurstDrill.java + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BurstDrill ore / dominant-item binding from Drill.java + BurstDrill.java + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: dominant_item, dominant_items.
    by_slice['N2302'] = [
        'source_burst_drill_on_proximity_update_state_result.dominant_item',
        'source_burst_drill_on_proximity_update_state_result.dominant_items',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2302', dict(status='done', java_source=BURST_DRILL, java_class='mindustry.world.blocks.production.BurstDrill.BurstDrillBuild', java_method='DrillBuild.onProximityUpdate()', godot_owner=ON_PROXIMITY_UPDATE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2302'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {definition[1] for definition in entries}
    for name, module in modules.items():
        if module.get('canonical_module') == 'api_contracts':
            selected = source_ssot.build_extension_shard(GODOT, name)[module['root_key']]
            if new_owners.intersection(selected):
                optional = module.setdefault('optional_mirror_fields', [])
                if 'return_type' not in optional:
                    optional.append('return_type')
    source_ssot.write_registered_json(GODOT, 'module_manifest', manifest)
    for canonical in ['slice_ledger', 'api_contracts', 'state_schema', 'registry', 'audit_report', 'module_manifest']:
        for name, module in modules.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    if '--verify' in sys.argv:
        sys.exit(verify())
    main()
