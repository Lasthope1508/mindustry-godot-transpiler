"""Register BeamDrill.getDrillTime(Item) (N2478).

BeamDrill.getDrillTime() (BeamDrill.java:216-218) is one
slice (batch 51 slot 3):
    public float getDrillTime(Item item){
        return drillTime / drillMultipliers.get(item, 1f);
    }
drillTime is the BeamDrill field (BeamDrill.java:39,
`public float drillTime = 200f;`) -- NOT Drill's
`public float drillTime = 300;` (Drill.java:36):
BeamDrill extends Block, not Drill, so Drill's field and
its hardness formula (`return (drillTime +
hardnessDrillMultiplier * item.hardness) /
drillMultipliers.get(item, 1f);`, Drill.java:171) are NOT
this slice. drillMultipliers is (`public
ObjectFloatMap<Item> drillMultipliers = new
ObjectFloatMap<>();`, BeamDrill.java:47) and a missing item
defaults to 1f. Per-def drillTime: plasma-bore 160f,
large-plasma-bore 100f (Blocks.java:3042/3055); neither def
puts any multiplier, so in practice every item drills at
the default 1f. The updateTile caller reads it as
`float drillTime = getDrillTime(lastItem);`
(BeamDrill.java:247); drawPlace reads it through the
get_drill_time Callable (BeamDrill.java:183), already
wired by its own slice -- this slice ports only the pure
function, not the callers.

The multiplier arrives PRE-RESOLVED: the caller applies
`drillMultipliers.get(item, 1f)` (default 1f) at the call
boundary and passes the resolved float here, so this pure
function never sees an item key and never guesses Arc
ObjectFloatMap null-key semantics -- a null item resolves
to 1.0 at the boundary (the precomputed-input precedent
of N2476/N2477). TRAPS: multiplier 0 gives Infinity
(Java float division, no exception -- GDScript float
division behaves the same); a negative multiplier passes
through (no clamp); drillTime is a per-def input (class
default 200f, plasma-bore 160f, large-plasma-bore 100f),
NOT hardcoded.

TWIN-REGISTER -- approved explicitly by the main thread
for N2478 (2026-11-26). The same body was already ported
per-class for BurstDrill (N2344, owner GD
SourceBurstDrillBuildState.source_burst_drill_get_drill_time_state)
and Drill (N690/N1367, owner
PortGame.source_drill_delay); the body literal
`return drillTime / drillMultipliers.get(item, 1f);` is
also an exact_expr of N2294 (evidence only). BeamDrill
had NO get_drill_time symbol of its own (registry
`beam_drill_get_drill_time` 0-hit; java_method
`BeamDrill.getDrillTime` exact/substring 0-hit), so this
slice adds a real new GD function -- NOT a duplicate like
TeamData.active(), which was permanently excluded because
its behaviour was already ported. Precedent for twin
registration with explicit main-thread approval: N2474,
N2477, N2421, N2389, N2418. Two slice sources:
BeamDrill.java + Blocks.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BEAM_DRILL = 'core/src/mindustry/world/blocks/production/BeamDrill.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07BeamDrillGetDrillTimeProof'
GET_DRILL_TIME_OWNER = 'SourceBeamDrillBuildState.source_beam_drill_get_drill_time_state'
TESTS = ['test_c07_beam_drill_get_drill_time_registration', 'test_all_c07_beam_drill_get_drill_time_input_evidence_is_exact', 'test_beam_drill_get_drill_time_state', 'test_reference_graph_and_actual_c07_beam_drill_get_drill_time']
# The 2 slice sources the N2478 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BeamDrill.java',
    'core/src/mindustry/content/Blocks.java',
]
FORMULA = 'return drillTime / drillMultipliers.get(item, 1f);'
EXACT_EXPRS = [
    'public class BeamDrill extends Block{',
    'public float drillTime = 200f;',
    'public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();',
    'public float getDrillTime(Item item){',
    FORMULA,
    'drillTime = 160f;',
    'drillTime = 100f;',
    'float drillTime = getDrillTime(lastItem);',
]
JAVA_METHOD = 'BeamDrill.getDrillTime(Item)'

DEFERRED = [
    'BeamDrill.getDrillTime(Item) Windows Godot proof -- debt in GOAL.md section 5: the N2478 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BeamDrill.getDrillTime(Item) is a TWIN-REGISTER with explicit main-thread approval (2026-11-26): the body literal `return drillTime / drillMultipliers.get(item, 1f);` was already ported per-class for BurstDrill (N2344, owner SourceBurstDrillBuildState.source_burst_drill_get_drill_time_state) and Drill (N690/N1367, owner PortGame.source_drill_delay), and is an exact_expr of N2294 (evidence only). N2344 is the nearest port owner; BeamDrill had no get_drill_time symbol of its own (registry 0-hit), so this slice adds a real new GD function. Precedent: N2474, N2477, N2421, N2389, N2418.',
    'Item null is modelled by a pre-resolved multiplier: the caller applies `drillMultipliers.get(item, 1f)` at the call boundary (a null item resolves to 1.0 there), so the pure function takes a float multiplier and never guesses Arc ObjectFloatMap null-key semantics.',
]


def definitions():
    def a(typ, expr, rule, source=BEAM_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    get_drill_time_inputs = {
        'drill_time': a('float', 'public float drillTime = 200f;', 'The base time to drill one ore, in frames (`public float drillTime = 200f;`, BeamDrill.java:39); passed explicitly because it is per-def static state, not a live frame key (the N2212 per-def-param precedent). Plasma-bore overrides it to 160f, large-plasma-bore to 100f (Blocks.java:3042/3055). NOT Drill\'s `public float drillTime = 300;` (Drill.java:36): BeamDrill extends Block, not Drill.'),
        'drill_multiplier': a('float', FORMULA, 'The pre-resolved per-item multiplier: the caller applies `drillMultipliers.get(item, 1f)` (BeamDrill.java:217) at the call boundary, so a missing item -- including a null item -- resolves to 1f before this function sees it. The map itself (`public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();`, BeamDrill.java:47) is NOT an input here; neither BeamDrill def puts any multiplier, so in practice every item drills at the default 1f.'),
    }
    get_drill_time_outputs = {
        'drill_time': a('float', FORMULA, 'The drill time for the item: drillTime divided by the pre-resolved per-item multiplier (`return drillTime / drillMultipliers.get(item, 1f);`, BeamDrill.java:217). Multiplier 0 gives Infinity (Java float division, no exception); a negative multiplier passes through unclamped.'),
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
        ('N2478', GET_DRILL_TIME_OWNER, 'source_beam_drill_get_drill_time_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill', JAVA_METHOD, get_drill_time_inputs, get_drill_time_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2096 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BeamDrill.getDrillTime(Item) state from BeamDrill.java + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BeamDrill.getDrillTime(Item) state from BeamDrill.java + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2478'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2478', dict(status='done', java_source=BEAM_DRILL, java_class='mindustry.world.blocks.production.BeamDrill', java_method=JAVA_METHOD, godot_owner=GET_DRILL_TIME_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2478'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
