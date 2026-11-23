"""Register the BurstDrill getDrillTime() override (N2344).

BurstDrill.getDrillTime() (BurstDrill.java:52-55, `@Override
public float getDrillTime(Item item){`) returns the drill
time divided by the per-item multiplier (`return drillTime /
drillMultipliers.get(item, 1f);` -- BurstDrill.java:54), with
NO hardness term: the base Drill formula (`return (drillTime
+ hardnessDrillMultiplier * item.hardness) /
drillMultipliers.get(item, 1f);`, Drill.java:171) is NOT this
slice -- the BurstDrill override drops the
`hardnessDrillMultiplier * item.hardness` leg entirely (and
the constructor zeroes the field, `hardnessDrillMultiplier =
0f;`, BurstDrill.java:39, "does not drill in the traditional
sense, so this is not even used"), so item.hardness is NOT
an input here. drillTime is the block field (`public float
drillTime = 300;`, Drill.java:36); drillMultipliers is
(`public ObjectFloatMap<Item> drillMultipliers = new
ObjectFloatMap<>();`, Drill.java:66) and defaults a missing
item to 1f. One new result symbol: drill_time. Two defs share
the function (impact-drill, Blocks.java:3070, drillTime 720f;
eruption-drill, Blocks.java:3093, drillTime 281.25f); both put
beryllium at 2f (Blocks.java:3083/3114). This slice is
distinct from Drill.getDrillTime (N1367/N690, owner
PortGame.source_drill_delay): different class, different
formula, different GD name -- the shared signature string
`public float getDrillTime(Item item){` in N1367's
exact_exprs is evidence-only (same signature string,
different class + body), not ownership. There is NO driver
tick line: the BurstDrill tick (N2149/N2294/N2296) already
reads `getDrillTime(dominantItem)` (BurstDrill.java:87)
through its precomputed drill_time_base / drill_multiplier
params; this slice ports only the pure function, not the
caller.

RED decisions (resolved at RED, recorded in the test): (1)
One pure function on the same family file N2149 built:
source_burst_drill_get_drill_time_state(frame, drill_time,
drill_multipliers, item_id) returning drill_time
(drill_time / drill_multipliers.get(item_id, 1.0)). frame is
the canonical first param of this family file and carries no
live keys for this block-level read (the N2212 / N2224
per-def-param precedent, same as setStats). drill_time and
drill_multipliers are explicit per-def params; item_id rides
as a string id (the source_drill_delay bridge precedent:
item_id: String). (2) There is NO driver tick line (see
above). One new result symbol: drill_time.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_drill_should_ambient_sound import DEFERRED as N2305_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BURST_DRILL = 'core/src/mindustry/world/blocks/production/BurstDrill.java'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07BurstDrillGetDrillTimeProof'
GET_DRILL_TIME_OWNER = 'SourceBurstDrillBuildState.source_burst_drill_get_drill_time_state'
TESTS = ['test_c07_burst_drill_get_drill_time_registration', 'test_all_c07_burst_drill_get_drill_time_input_evidence_is_exact', 'test_burst_drill_get_drill_time_state', 'test_reference_graph_and_actual_c07_burst_drill_get_drill_time']
# The 3 slice sources the N2344 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BurstDrill.java',
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['@Override', 'public float getDrillTime(Item item){', 'return drillTime / drillMultipliers.get(item, 1f);', 'public float drillTime = 300;', 'public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();', 'public float hardnessDrillMultiplier = 50f;', 'hardnessDrillMultiplier = 0f;', 'return (drillTime + hardnessDrillMultiplier * item.hardness) / drillMultipliers.get(item, 1f);', 'public class BurstDrill extends Drill{', 'public class Drill extends Block{', 'drillTime = 60f * 12f;', 'drillTime = 281.25f;', 'drillMultipliers.put(Items.beryllium, 2f);', 'float drillTime = getDrillTime(dominantItem);']

# DEFERRED is carried from the N2305 register script via import --
# never retyped. The N2305 script's DEFERRED is a computed
# expression (N2323_DEFERRED + [...]), NOT a plain list literal,
# so the N2218-style ast.literal_eval carry cannot recover it
# (ValueError: malformed node); the import recovers the runtime
# value verbatim. N2305 carries the longest live BurstDrill debt
# list (295 entries, via N2323); the N2338/N2341 literal 3-entry
# lists are side branches, not the chain head. No carried entry
# is dropped here: there is no BurstDrill getDrillTime entry in
# the carried list.
DEFERRED = list(N2305_DEFERRED) + [
    'BurstDrill getDrillTime() Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2227: the N2344 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BURST_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    get_drill_time_inputs = {
        'frame': a('Dictionary', 'public float getDrillTime(Item item){', 'The BurstDrillBuild frame (BurstDrill.getDrillTime, BurstDrill.java:52-55); the family-convention first arg (every BurstDrill pure function takes it). No live keys are read from the frame -- drill_time and drill_multipliers are explicit per-def params (the N2212 / N2224 per-def-param precedent, same as setStats).', source=BURST_DRILL),
        'drill_time': a('float', 'public float drillTime = 300;', 'The base time to drill one ore, in frames (`public float drillTime = 300;`, Drill.java:36); passed explicitly because it is per-def static state, not a live frame key (the N2212 per-def-param precedent). Impact-drill overrides it to `drillTime = 60f * 12f;` (720f, Blocks.java:3072); eruption-drill to `drillTime = 281.25f;` (Blocks.java:3095).', source=DRILL),
        'drill_multipliers': a('Dictionary', 'public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();', 'The per-item drill-speed multipliers (`public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();`, Drill.java:66); a missing item defaults to 1f via `drillMultipliers.get(item, 1f)` (BurstDrill.java:54). Passed explicitly because it is per-def static state (the N2212 per-def-param precedent): both defs put beryllium at 2f (`drillMultipliers.put(Items.beryllium, 2f);`, Blocks.java:3083/3114).', source=DRILL),
        'item_id': a('Variant', 'public float getDrillTime(Item item){', 'The item to drill (`public float getDrillTime(Item item){`, BurstDrill.java:53); rides as a string id (the source_drill_delay bridge precedent: item_id: String). The caller passes the dominant item (the tick reads `float drillTime = getDrillTime(dominantItem);`, BurstDrill.java:87).', source=BURST_DRILL),
    }
    get_drill_time_outputs = {
        'drill_time': a('float', 'return drillTime / drillMultipliers.get(item, 1f);', 'The drill time for the item: drillTime divided by the per-item multiplier (`return drillTime / drillMultipliers.get(item, 1f);`, BurstDrill.java:54), with NO hardness term -- the base Drill formula (`return (drillTime + hardnessDrillMultiplier * item.hardness) / drillMultipliers.get(item, 1f);`, Drill.java:171) is NOT this slice; the BurstDrill constructor zeroes the field (`hardnessDrillMultiplier = 0f;`, BurstDrill.java:39), so item.hardness is not an input. Impact-drill + beryllium gives 720/2 = 360 (NOT the base formula (720 + 50*3)/2 = 435).'),
    }
    return get_drill_time_inputs, get_drill_time_outputs


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
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
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
    get_drill_time_inputs, get_drill_time_outputs = definitions()

    entries = [
        ('N2344', GET_DRILL_TIME_OWNER, 'source_burst_drill_get_drill_time_state', BURST_DRILL, 'mindustry.world.blocks.production.BurstDrill', 'BurstDrill.getDrillTime()', get_drill_time_inputs, get_drill_time_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BurstDrill getDrillTime() state from BurstDrill.java + Drill.java + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BurstDrill getDrillTime() state from BurstDrill.java + Drill.java + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: drill_time.
    by_slice['N2344'] = [
        'source_burst_drill_get_drill_time_state_result.drill_time',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2344', dict(status='done', java_source=BURST_DRILL, java_class='mindustry.world.blocks.production.BurstDrill', java_method='BurstDrill.getDrillTime()', godot_owner=GET_DRILL_TIME_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2344'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
