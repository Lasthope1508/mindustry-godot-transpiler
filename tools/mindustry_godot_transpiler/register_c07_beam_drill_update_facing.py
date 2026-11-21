"""Register the BeamDrill onProximityUpdate() + updateLasers() +
updateFacing() group (N2379).

MERGED slice (N2374 grouped / N2330 merged-slice precedent):
ONE record, ONE owner, covering ALL THREE java methods:
BeamDrillBuild.onProximityUpdate()
(BeamDrill.java:362-366, `public void onProximityUpdate(){` /
`//when rotated.` / `updateLasers();` / `updateFacing();`)
and
BeamDrillBuild.updateLasers()
(BeamDrill.java:368-373, `protected void updateLasers(){` /
`for(int i = 0; i < size; i++){` /
`if(lasers[i] == null) lasers[i] = new Point2();` /
`nearbySide(tileX(), tileY(), rotation, i, lasers[i]);`)
and
BeamDrillBuild.updateFacing()
(BeamDrill.java:375-412, `protected void updateFacing(){` /
`lastItem = null;` / `boolean multiple = false;` /
`int dx = Geometry.d4x(rotation), dy = Geometry.d4y(rotation);` /
`facingAmount = 0;` / the per-laser ray scan /
`facing[p] = dest;` / `if(multiple){` / `lastItem = null;`)
are one pure facing record on the existing
SourceBeamDrillBuildState.gd (created by N2155,
extended by N2378), following the grouped-slice
precedent (N2374 TeamData liveness, N2330 Drill
group): onProximityUpdate only calls the two
callees (2 exprs), so it stands alone too thin;
updateLasers + updateFacing are one pure
facing-tile logic pair over the same frame fields
`lasers` / `facing` / `lastItem` / `facingAmount`.
All THREE java_method names are in the ledger record
(`BeamDrillBuild.onProximityUpdate();
BeamDrillBuild.updateLasers();
BeamDrillBuild.updateFacing()`).
Main thread confirms at merge.

RED decisions (resolved at RED): (1) BeamDrill is
opened for C07 by main thread decision ~14:3x
(batch 17 scope, N2378 merged) -- no second
decision needed for this slot (same class, same
file). (2) The name `onProximityUpdate` shares text
with other classes' proximity updates
(N968/N2046/N2302, all `public void
onProximityUpdate(){` on a different class) --
registered under this java_method with the class
prefix + full java_class, 0-hit for
`BeamDrillBuild.onProximityUpdate` in both ledgers.
(3) `if(other != null){` EXACT-hits 5 slices,
`break;` EXACT-hits N1152/N2313, `public int tier
= 1;` EXACT-hits N2133/N2168, `public @Nullable
Seq<Item> blockedItems;` EXACT-hits N2013/N2302/
N2332, `public class BeamDrill extends Block{`
EXACT-hits N2155/N2378, `public class
BeamDrillBuild extends Building{` EXACT-hits N2378,
`@Override` EXACT-hits 100+ slices -- they are
callee/context only, NOT distinguishing exprs, and
are NOT in EXACT_EXPRS. The distinguishing exprs
are the 34 EXACT 0-hit lines, re-probed at HEAD
4f53d70e in both ledgers. (4) `if(lasers[0] ==
null) updateLasers();` is the updateTile call site
(BeamDrill.java:239-240) -- 0-hit in both ledgers;
updateTile N2155 does not own it; it IS in
EXACT_EXPRS as the call-site evidence. (5)
nearbySide is the N1762 callee
(PortGame.source_block_nearby_side_state,
Block.java:936) -- NOT re-ported; updateLasers
delegates to its static geometry form. (6) The
live world arrives as the explicit world_tile
Callable param (the N2294 param precedent):
world_tile.call(rx, ry) returns null or a tile
Dictionary {"solid", "wall_drop",
"wall_drop_hardness"}; facing[p] stores that tile
Dictionary (dest = other). Item identity is by
name (items are singletons per name in the
synthetic contract). (7) Geometry.d4x/d4y are the
arc Geometry arrays (Geometry.java:23-24, 47-51:
d4x {1,0,-1,0}, d4y {0,1,0,-1}, read with
Mathf.mod(i, 4)) -- the port reads them through
posmod(rotation, 4). (8) The per-def tier / range
/ size arrive as explicit params (the N2212 /
N2248 per-def-param precedent): plasma-bore tier 3
/ size 2 / range 5, large-plasma-bore tier 5 /
size 3 / range 6 (Blocks.java:3049-3065). (9) A
missing laser point (frame built without
updateLasers) leaves its facing null -- Java would
throw there; the guard is documented in the GD
comment, not a behavior change for any frame
updateLasers built. (10) NO driver tick line:
onProximityUpdate runs at placement / rotation,
not per tick (the N2302 precedent).
Four new result symbols: lasers, facing,
last_item, facing_amount.
Slice source: BeamDrill.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_beam_drill_power_status import DEFERRED as N2155_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BEAM_DRILL = 'core/src/mindustry/world/blocks/production/BeamDrill.java'
PROOF = '/root/C07BeamDrillUpdateFacingProof'
UPDATE_FACING_OWNER = 'SourceBeamDrillBuildState.source_beam_drill_update_facing_state'
TESTS = ['test_c07_beam_drill_update_facing_registration', 'test_all_c07_beam_drill_update_facing_input_evidence_is_exact', 'test_beam_drill_update_facing_state', 'test_reference_graph_and_actual_c07_beam_drill_update_facing']
# The 1 slice source the N2379 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BeamDrill.java',
]
EXACT_EXPRS = [
    'updateLasers();',
    'updateFacing();',
    'lasers[i] = new Point2();',
    'nearbySide(tileX(), tileY(), rotation, i, lasers[i]);',
    'lastItem = null;',
    'boolean multiple = false;',
    'int dx = Geometry.d4x(rotation), dy = Geometry.d4y(rotation);',
    'facingAmount = 0;',
    'facing[p] = dest;',
    'if(multiple){',
    'int rx = l.x + dx*i, ry = l.y + dy*i;',
    'if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){',
    'facingAmount ++;',
    'if(lastItem != drop && lastItem != null){',
    'multiple = true;',
    'lastItem = drop;',
    'dest = other;',
    'if(lasers[0] == null) updateLasers();',
    'protected void updateLasers(){',
    'protected void updateFacing(){',
    'public Tile[] facing = new Tile[size];',
    'public Point2[] lasers = new Point2[size];',
    'public @Nullable Item lastItem;',
    'public int facingAmount;',
    'for(int i = 0; i < size; i++){',
    'if(lasers[i] == null)',
    'Point2 l = lasers[p];',
    'Tile dest = null;',
    'for(int p = 0; p < size; p++){',
    'for(int i = 0; i < range; i++){',
    'Tile other = world.tile(rx, ry);',
    'if(other.solid()){',
    'Item drop = other.wallDrop();',
    'public int range = 5;',
]

# DEFERRED is carried from the N2155 register script via import --
# never retyped. This slice RESOLVES one N2155 entry -- the
# facing / laser binding (updateLasers / updateFacing,
# BeamDrill.java:368-411) -- so that entry is filtered out
# instead of carried: it is the work this slice does. All
# other N2155 entries are carried verbatim (the BeamDrill
# updateTile advance, shouldConsume gate, liquid rows,
# drillMultipliers rows, plus the Pump / Fracker / SolidPump
# / projector / payload-producer / BurstDrill chain notes --
# none of them is resolved by this slice). One entry is added:
# N2379's Windows proof debt.
DEFERRED = [e for e in N2155_DEFERRED if 'facing / laser binding' not in e] + [
    'BeamDrill facing / laser binding Windows Godot proof -- debt in GOAL.md section 5, same as N2155: the N2379 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BEAM_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    frame_expr = 'public Point2[] lasers = new Point2[size];'
    nearby_expr = 'nearbySide(tileX(), tileY(), rotation, i, lasers[i]);'
    d4_expr = 'int dx = Geometry.d4x(rotation), dy = Geometry.d4y(rotation);'
    size_expr = 'for(int i = 0; i < size; i++){'
    range_expr = 'for(int i = 0; i < range; i++){'
    gate_expr = 'if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){'
    tile_expr = 'Tile other = world.tile(rx, ry);'
    update_facing_inputs = {
        'frame': a('Dictionary', frame_expr, 'The build frame carrying the facing fields (BeamDrill.java:221-228, `public Tile[] facing = new Tile[size];` / `public Point2[] lasers = new Point2[size];` / `public @Nullable Item lastItem;` / `public int facingAmount;`): updateLasers writes frame["lasers"], updateFacing writes frame["facing"] / frame["last_item"] / frame["facing_amount"].'),
        'tile_x': a('int', nearby_expr, 'The build tile x, tileX() (BeamDrill.java:371, `nearbySide(tileX(), tileY(), rotation, i, lasers[i]);`): the footprint corner updateLasers measures from.'),
        'tile_y': a('int', nearby_expr, 'The build tile y, tileY() (BeamDrill.java:371, `nearbySide(tileX(), tileY(), rotation, i, lasers[i]);`): the footprint corner updateLasers measures from.'),
        'rotation': a('int', d4_expr, 'The build rotation 0-3 (BeamDrill.java:377, `int dx = Geometry.d4x(rotation), dy = Geometry.d4y(rotation);`): it picks the faced side for nearbySide and the ray direction for updateFacing.'),
        'size': a('int', size_expr, 'The block size (BeamDrill.java:369, `for(int i = 0; i < size; i++){`): the lasers / facing arrays are sized `size` (plasma-bore 2, large-plasma-bore 3, Blocks.java:3049-3065); passed explicitly (the N2212 / N2248 per-def-param precedent).'),
        'range_value': a('int', range_expr, 'The drill range (BeamDrill.java:381, `for(int i = 0; i < range; i++){`, with `public int range = 5;`, BeamDrill.java:40): how far each laser ray scans (plasma-bore 5, large-plasma-bore 6, Blocks.java:3049-3065); passed explicitly.'),
        'tier': a('int', gate_expr, 'The drill tier (BeamDrill.java:392, `if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){`): a drop counts only when its hardness is at most the tier (plasma-bore 3, large-plasma-bore 5, Blocks.java:3049-3065); passed explicitly.'),
        'blocked_items': a('Variant', gate_expr, 'The blocked list (BeamDrill.java:51, `public @Nullable Seq<Item> blockedItems;`, shared with N2013/N2302/N2332): null when the def blocks nothing, otherwise the blocked items; the gate treats null as "nothing blocked" (BeamDrill.java:392). Passed explicitly.'),
        'world_tile': a('Callable', tile_expr, 'The live world tile lookup (BeamDrill.java:383, `Tile other = world.tile(rx, ry);`): the port has no live World here, so it arrives as an explicit Callable param (the N2294 param precedent); world_tile.call(rx, ry) returns null or a tile Dictionary {"solid", "wall_drop", "wall_drop_hardness"}.'),
    }
    update_facing_outputs = {
        'lasers': a('Array', 'lasers[i] = new Point2();', 'The laser side points after updateLasers (BeamDrill.java:370, `lasers[i] = new Point2();`): one Vector2i per footprint side index, recomputed by the N1762 nearbySide callee.'),
        'facing': a('Array', 'facing[p] = dest;', 'The facing tile per laser ray (BeamDrill.java:406, `facing[p] = dest;`): the first solid tile with a mineable drop on that ray, or null when the ray finds none.'),
        'last_item': a('Variant', 'lastItem = drop;', 'The last counted drop (BeamDrill.java:400, `lastItem = drop;`): the drop of the last counted ray, or null when nothing counted -- or when two rays counted different drops, the multiple rule (BeamDrill.java:408-410, `if(multiple){ lastItem = null; }`).'),
        'facing_amount': a('int', 'facingAmount ++;', 'How many rays found a mineable drop (BeamDrill.java:394, `facingAmount ++;`, reset by `facingAmount = 0;`, BeamDrill.java:378): the count updateTile folds into lastDrillSpeed (BeamDrill.java:249).'),
    }
    return (update_facing_inputs, update_facing_outputs)


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    inputs_outputs = [definitions()]
    total = len(EXACT_EXPRS)
    for pair in inputs_outputs:
        for keys in pair:
            total += len(keys)
            for field, meta in keys.items():
                source = meta['java_source']
                text = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
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
    (update_facing_inputs, update_facing_outputs) = definitions()

    entries = [
        ('N2379', UPDATE_FACING_OWNER, 'source_beam_drill_update_facing_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', 'BeamDrillBuild.onProximityUpdate(); BeamDrillBuild.updateLasers(); BeamDrillBuild.updateFacing()', update_facing_inputs, update_facing_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BeamDrillBuild.onProximityUpdate()/updateLasers()/updateFacing() state from BeamDrill.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BeamDrillBuild.onProximityUpdate()/updateLasers()/updateFacing() state from BeamDrill.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: lasers, facing,
    # last_item, facing_amount.
    by_slice['N2379'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2379', dict(status='done', java_source=BEAM_DRILL, java_class='mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', java_method='BeamDrillBuild.onProximityUpdate(); BeamDrillBuild.updateLasers(); BeamDrillBuild.updateFacing()', godot_owner=UPDATE_FACING_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2379'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
