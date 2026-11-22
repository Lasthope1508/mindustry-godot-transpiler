"""Register the Drill init() defaulting slice (N2424).

Drill.init() (Drill.java:91-97, `public void init(){`) --
this slice is ONLY the 1 line:
`if(drillEffectRnd < 0) drillEffectRnd = size;`
(:96).

NOT this slice: `super.init();` (:92) and the
blockedItems guard `if(blockedItems == null &&
blockedItem != null){ blockedItems =
Seq.with(blockedItem); }` (:93-95) -- both already
owned. The 1 distinguishing expr is 0-hit in both the
local and the remote ledger (re-probed at base
f8c57422, remote origin/main e45de296). One pure
function on SourceDrillRuntimePortBridge.gd (the Drill
file, non-static func -- the PortGame-era style of this
file). The owner is PortGame.* (the N691/N692/N693/
N696/N697/N701/N703/N2420 precedent for the other
Drill legs in this file).

The Drill field default is `public float
drillEffectRnd = -1f;` (Drill.java:55, "Block size by
default") -- a negative value means "use the block
size", so the resolved radius is size when the field is
negative, the field itself otherwise. One new result
symbol: drill_effect_rnd. Slice sources: Drill.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_drill_update_tile_effects import DEFERRED as N2420_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
PROOF = '/root/C07DrillInitProof'
INIT_OWNER = 'PortGame.source_drill_init_state'
TESTS = ['test_c07_drill_init_registration', 'test_all_c07_drill_init_input_evidence_is_exact', 'test_drill_init_state', 'test_reference_graph_and_actual_c07_drill_init']
# The 1 slice source the N2424 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/Drill.java',
]
EXACT_EXPRS = [
    'if(drillEffectRnd < 0) drillEffectRnd = size;',
]
INIT_EXPR = 'if(drillEffectRnd < 0) drillEffectRnd = size;'

# DEFERRED is carried from the N2420 register script via import --
# never retyped. This slice resolves NONE of the carried entries
# (the init defaulting line is not the updateTile effect legs,
# the items/efficiency gate (N693), `progress %= delay`
# (N696), `offload(dominantItem)` (N2022), or the warmup
# approach (N692/N703)), so all are carried verbatim. One
# entry is added: N2424's Windows proof debt.
DEFERRED = list(N2420_DEFERRED) + [
    'Drill init() defaulting Windows Godot proof -- debt in GOAL.md section 5, same as N2420: the N2424 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    init_inputs = {
        'drill_effect_rnd': a('float', INIT_EXPR, 'The drill effect random radius before init (Drill.java:96, `if(drillEffectRnd < 0) drillEffectRnd = size;`): the Drill field (`public float drillEffectRnd = -1f;`, Drill.java:55, "Block size by default") -- a negative value means "use the block size", passed explicitly.'),
        'size': a('float', INIT_EXPR, 'The block size (Drill.java:96, `if(drillEffectRnd < 0) drillEffectRnd = size;`): the Block.size in tiles -- the value a negative drillEffectRnd resolves to, passed explicitly.'),
    }
    init_outputs = {
        'drill_effect_rnd': a('float', INIT_EXPR, 'The resolved drill effect random radius (Drill.java:96, `if(drillEffectRnd < 0) drillEffectRnd = size;`): size when drill_effect_rnd is negative, drill_effect_rnd itself otherwise.'),
    }
    return init_inputs, init_outputs


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
    init_inputs, init_outputs = definitions()

    entries = [
        ('N2424', INIT_OWNER, 'source_drill_init_state', DRILL, 'mindustry.world.blocks.production.Drill', 'Drill.init()', init_inputs, init_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Drill init() defaulting state from Drill.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Drill init() defaulting state from Drill.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: drill_effect_rnd.
    by_slice['N2424'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2424', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill', java_method='Drill.init()', godot_owner=INIT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2424'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
