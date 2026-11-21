"""Register the BeamDrill updateTile() facing-harvest + dump slice (N2398).

BeamDrillBuild.updateTile() (BeamDrill.java:237-265, `public
void updateTile(){`) -- this slice is the facing-harvest +
dump half: `float drillTime = getDrillTime(lastItem);`
(:247), `boostWarmup = Mathf.lerpDelta(boostWarmup,
optionalEfficiency, 0.1f);` (:248), the harvest gate
`if(time >= drillTime){` (:253) with the facing loop
`for(Tile tile : facing){` (:254), `Item drop = tile ==
null ? null : tile.wallDrop();` (:255), the capacity gate
`if(items.total() < itemCapacity && drop != null){`
(:256), `items.add(drop, 1);` (:257), `produced(drop);`
(:258), `time %= drillTime;` (:261), and the dump
`dump();` (:264) behind the timer gate.

NOT this slice: `super.updateTile();` (generic, 8 hits
local), `if(lasers[0] == null) updateLasers();` /
`updateFacing();` (N2379), the warmup gate (`warmup =
Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f
/ 60f);`, :242), `float multiplier = Mathf.lerp(1f,
optionalBoostIntensity, optionalEfficiency);` (:246),
`lastDrillSpeed = (facingAmount * multiplier * timeScale)
/ drillTime * efficiency;` (:249), `time += edelta() *
multiplier;` (:251) -- all N2155 -- and the timer gate
(`if(timer(timerDump, dumpTime / timeScale)){`, :263 --
N691/N2068/N2072/N2073/N2294, generic; it arrives as the
dump_ready bool, the timer result computed by the
caller, the TractorBeam timer_target_ready precedent).

getDrillTime is BeamDrill's own method
(BeamDrill.java:216-218, `public float getDrillTime(Item
item){` / `return drillTime / drillMultipliers.get(item,
1f);`, class default `public float drillTime = 200f;`,
BeamDrill.java:39; plasma-bore 160f, large-plasma-bore
100f, Blocks.java:3038-3065) -- NOT N2344's BurstDrill
.getDrillTime (different class, same formula shape): it
arrives as the explicit get_drill_time Callable (the
drawPlace precedent). `Mathf.lerpDelta` is arc
(Mathf.java:430-432) -- the ported
SourceMathState.source_lerp_delta helper folds it, so
Time.delta arrives as the explicit time_delta param.
`wallDrop()` is Tile.java:575 (the block itemDrop when
solid, else the wall-ore overlay drop, else null) -- the
facing tiles arrive as tile Dictionaries {"wall_drop":
...} or null (the N2379 updateFacing precedent).
`items.total()` / `items.add(drop, 1)` are the ItemModule
engine API (the current total arrives as items_total,
the capacity as item_capacity, the add as the items_add
Callable); the capacity gate is checked against a
running total because Java re-reads items.total() after
each add inside the loop. `produced(drop)` is
BuildingComp.java:1035-1037 and `dump()` is
BuildingComp.java:1064-1066 -- both arrive as explicit
Callables (the N2377 drawer precedent). `time` is the
BeamDrillBuild field (`public float time;`,
BeamDrill.java:225) shared with N2155 -- taken in/out,
NOT re-registered. Eight new result symbols:
drill_time, boost_warmup, time, harvested,
get_drill_time_called, items_add_called,
produced_called, dump_called. Slice sources:
BeamDrill.java + BuildingComp.java + Mathf.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_beam_drill_draw_select_draw_plan_region_init import DEFERRED as N2394_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BEAM_DRILL = 'core/src/mindustry/world/blocks/production/BeamDrill.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
MATHF = 'arc-core/src/arc/math/Mathf.java'
PROOF = '/root/C07BeamDrillUpdateTileProof'
UPDATE_TILE_OWNER = 'SourceBeamDrillBuildState.source_beam_drill_update_tile_state'
TESTS = ['test_c07_beam_drill_update_tile_registration', 'test_all_c07_beam_drill_update_tile_input_evidence_is_exact', 'test_beam_drill_update_tile_state', 'test_reference_graph_and_actual_c07_beam_drill_update_tile']
# The 3 slice sources the N2398 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BeamDrill.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'arc-core/src/arc/math/Mathf.java',
]
EXACT_EXPRS = [
    'float drillTime = getDrillTime(lastItem);',
    'boostWarmup = Mathf.lerpDelta(boostWarmup, optionalEfficiency, 0.1f);',
    'if(time >= drillTime){',
    'for(Tile tile : facing){',
    'Item drop = tile == null ? null : tile.wallDrop();',
    'if(items.total() < itemCapacity && drop != null){',
    'items.add(drop, 1);',
    'produced(drop);',
    'time %= drillTime;',
    'dump();',
]

# DEFERRED is carried from the N2394 register script via import --
# never retyped. This slice resolves NONE of the carried entries
# (updateTile is the facing-harvest + dump half, not the
# drawSelect / drawPlanRegion / init UI, the warmup gate /
# multiplier / lastDrillSpeed / time advance (N2155), or the
# updateLasers / updateFacing call sites (N2379)), so all are
# carried verbatim. One entry is added: N2398's Windows
# proof debt.
DEFERRED = list(N2394_DEFERRED) + [
    'BeamDrill updateTile() facing-harvest + dump Windows Godot proof -- debt in GOAL.md section 5, same as N2394: the N2398 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BEAM_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    update_tile_inputs = {
        'frame': a('Dictionary', 'public void updateTile(){', 'The beam-drill frame (BeamDrillBuild.updateTile, BeamDrill.java:237): carries no live keys for this tick half -- lastItem / boostWarmup / time / facing / items state arrive as explicit params, not frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file.'),
        'last_item': a('Variant', 'public @Nullable Item lastItem;', 'The last mined item: the BeamDrillBuild field (`public @Nullable Item lastItem;`, BeamDrill.java:223), set by updateFacing (`lastItem = drop;`, BeamDrill.java:396) and cleared when the facing changes (`lastItem = null;`, BeamDrill.java:376, :409); passed explicitly because it is live build state, not a frame key.'),
        'boost_warmup': a('float', 'public float warmup, boostWarmup;', 'The boost warmup before this tick (BeamDrill.java:226, `public float warmup, boostWarmup;`): lerped toward optionalEfficiency at 0.1f per delta (BeamDrill.java:248).'),
        'optional_efficiency': a('float', 'transient float optionalEfficiency;', 'The optional-consumer efficiency (BuildingComp.java:87, `transient float optionalEfficiency;`): the lerp target for boostWarmup (BeamDrill.java:248, `Mathf.lerpDelta(boostWarmup, optionalEfficiency, 0.1f);`) and the boost multiplier input (BeamDrill.java:246, N2155).', source=BUILDING_COMP),
        'time': a('float', 'public float time;', 'The drill progress time before this tick: the BeamDrillBuild field (`public float time;`, BeamDrill.java:225) shared with N2155 (`time += edelta() * multiplier;`, BeamDrill.java:251) -- taken in/out, NOT re-registered; this slice only applies the `time %= drillTime;` wrap (BeamDrill.java:261) when the harvest gate fires.'),
        'time_delta': a('float', 'Time.delta', 'Time.delta (Mathf.java:431, `clamp(progress * Time.delta)` inside `Mathf.lerpDelta`): the frame delta the lerpDelta fold scales by (the ported SourceMathState.source_lerp_delta helper).', source=MATHF),
        'facing': a('Array', 'public Tile[] facing = new Tile[size];', 'The facing tiles: the BeamDrillBuild field (`public Tile[] facing = new Tile[size];`, BeamDrill.java:221), built by updateFacing (N2379) -- an Array of tile Dictionaries {"wall_drop": ...} or null (the N2379 precedent), so `tile.wallDrop()` (Tile.java:575) reads "wall_drop".'),
        'items_total': a('int', 'if(items.total() < itemCapacity && drop != null){', 'The current item count (BeamDrill.java:256, `items.total()` inside the capacity gate): the ItemModule total before this tick; the gate is re-checked against a running total inside the loop because Java re-reads items.total() after each add.'),
        'item_capacity': a('int', 'if(items.total() < itemCapacity && drop != null){', 'The block item capacity (BeamDrill.java:256, `itemCapacity` inside the capacity gate): the ItemModule cap the running total is checked against (Block default 10).'),
        'dump_ready': a('bool', 'if(timer(timerDump, dumpTime / timeScale)){', 'The dump timer result (BeamDrill.java:263, `if(timer(timerDump, dumpTime / timeScale)){`): the generic timer gate (N691/N2068/N2072/N2073/N2294) computed by the caller -- the TractorBeam timer_target_ready precedent; dump() fires only when it is true.'),
        'get_drill_time': a('Callable', 'float drillTime = getDrillTime(lastItem);', 'The getDrillTime delegate (BeamDrill.java:247, `float drillTime = getDrillTime(lastItem);`): BeamDrill\'s own method (BeamDrill.java:216-218, `return drillTime / drillMultipliers.get(item, 1f);`, class default 200f) -- NOT re-ported here: it arrives as an explicit Callable param (the drawPlace precedent: guarded with is_valid(), invoked with .call(last_item)); an invalid callable reports drill_time 0.0 and the harvest gate does not fire.'),
        'items_add': a('Callable', 'items.add(drop, 1);', 'The items.add delegate (BeamDrill.java:257, `items.add(drop, 1);`): the ItemModule engine API -- NOT re-ported here: it arrives as an explicit Callable param (the N2377 drawer precedent: guarded with is_valid(), invoked with .call(drop, 1)); an invalid callable is reported via items_add_called false and the harvested drops still read through.'),
        'produced': a('Callable', 'produced(drop);', 'The produced delegate (BeamDrill.java:258, `produced(drop);`): the BuildingComp callee (`public void produced(Item item){`, BuildingComp.java:1035, `produced(item, 1);`) -- NOT re-ported here: it arrives as an explicit Callable param (the N2377 drawer precedent: guarded with is_valid(), invoked with .call(drop)); an invalid callable is reported via produced_called false.'),
        'dump': a('Callable', 'dump();', 'The dump delegate (BeamDrill.java:264, `dump();`): the BuildingComp callee (`public boolean dump(){`, BuildingComp.java:1064, `return dump(null);`) -- NOT re-ported here: it arrives as an explicit Callable param (the N2377 drawer precedent: guarded with is_valid(), invoked with .call()); an invalid callable is reported via dump_called false.'),
    }
    update_tile_outputs = {
        'drill_time': a('float', 'float drillTime = getDrillTime(lastItem);', 'The drill time for the last item (BeamDrill.java:247, `float drillTime = getDrillTime(lastItem);`): drillTime / drillMultipliers.get(item, 1f) (BeamDrill.java:217) -- 200.0 for the class default with no multiplier.'),
        'boost_warmup': a('float', 'boostWarmup = Mathf.lerpDelta(boostWarmup, optionalEfficiency, 0.1f);', 'The boost warmup after this tick (BeamDrill.java:248, `boostWarmup = Mathf.lerpDelta(boostWarmup, optionalEfficiency, 0.1f);`): lerped toward optionalEfficiency at 0.1f per delta (arc Mathf.java:430-432, folded by SourceMathState.source_lerp_delta).'),
        'time': a('float', 'time %= drillTime;', 'The drill progress time after this tick (BeamDrill.java:261, `time %= drillTime;`): wrapped by modulo when the harvest gate fires, unchanged otherwise (the `time += edelta() * multiplier;` advance is N2155).'),
        'harvested': a('Array', 'for(Tile tile : facing){', 'The drops harvested this tick, in facing order (BeamDrill.java:254-259, `for(Tile tile : facing){` / `Item drop = tile == null ? null : tile.wallDrop();` / the capacity gate / `items.add(drop, 1);` / `produced(drop);`): null tiles and null drops are skipped, a full item store blocks adds (checked against the running total).'),
        'get_drill_time_called': a('bool', 'float drillTime = getDrillTime(lastItem);', 'Whether the getDrillTime delegate was invoked (BeamDrill.java:247, `float drillTime = getDrillTime(lastItem);`): true when the get_drill_time Callable is valid, false otherwise (the N2377 drawer_called precedent).'),
        'items_add_called': a('bool', 'items.add(drop, 1);', 'Whether the items.add delegate was invoked (BeamDrill.java:257, `items.add(drop, 1);`): true when the items_add Callable is valid and at least one drop passed the capacity gate, false otherwise (the N2377 drawer_called precedent).'),
        'produced_called': a('bool', 'produced(drop);', 'Whether the produced delegate was invoked (BeamDrill.java:258, `produced(drop);`): true when the produced Callable is valid and at least one drop passed the capacity gate, false otherwise (the N2377 drawer_called precedent).'),
        'dump_called': a('bool', 'dump();', 'Whether the dump delegate was invoked (BeamDrill.java:264, `dump();`): true when the dump_ready gate is true and the dump Callable is valid, false otherwise (the N2377 drawer_called precedent).'),
    }
    return update_tile_inputs, update_tile_outputs


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
    inputs_outputs = [definitions()]
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
        for pair in keys:
            total += len(pair)
            for field, meta in pair.items():
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
    update_tile_inputs, update_tile_outputs = definitions()

    entries = [
        ('N2398', UPDATE_TILE_OWNER, 'source_beam_drill_update_tile_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', 'BeamDrillBuild.updateTile()', update_tile_inputs, update_tile_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BeamDrill updateTile() facing-harvest + dump state from BeamDrill.java + BuildingComp.java + Mathf.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BeamDrill updateTile() facing-harvest + dump state from BeamDrill.java + BuildingComp.java + Mathf.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: drill_time, boost_warmup,
    # time, harvested, get_drill_time_called,
    # items_add_called, produced_called, dump_called.
    by_slice['N2398'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2398', dict(status='done', java_source=BEAM_DRILL, java_class='mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', java_method='BeamDrillBuild.updateTile()', godot_owner=UPDATE_TILE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2398'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
