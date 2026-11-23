"""Register the Radar(String name) ctor field defaults (N2404).

Radar(String name) (Radar.java:27-34, `public Radar(String
name){`) assigns 3 literal field defaults on the Radar def:
`update = solid = true;` / `flags =
EnumSet.of(BlockFlag.hasFogRadius);` / `outlineIcon =
true;`. The 2 other ctor lines are NOT in this slice and
are never re-registered: `super(name);` is already the
exact_expr of N2185, `fogRadius = 10;` of N2320/N2321/N2342
(all 0-hit re-probed at HEAD 5ffcadd1, local + remote
ledgers). One GD function on SourceRadarBuildState.gd (the
Radar family file) -- the N2400 Turret ctor precedent
(owner `source_turret_default_constructor_state`) and
the N2401 BeamDrill ctor precedent for the flags Variant
passthrough. The defaults are frame data only (bool
literals + one flags value); no Draw is ported, and the
proof asserts frame defaults, never a real render. Five
new result symbols: one per default plus the updated def
frame. Radar was declared 40/40 done at renumber #52 --
that was drawSelect completion; this ctor is the last
unported Radar block-level item, reopened by main-thread
approval for batch 26. One slice source: Radar.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_radar_draw_place import DEFERRED as N2342_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RADAR = 'core/src/mindustry/world/blocks/defense/Radar.java'
PROOF = '/root/C07RadarDefaultConstructorProof'
CTOR_OWNER = 'SourceRadarBuildState.source_radar_default_constructor_state'
TESTS = ['test_c07_radar_default_constructor_registration', 'test_all_c07_radar_default_constructor_input_evidence_is_exact', 'test_radar_default_constructor_state', 'test_reference_graph_and_actual_c07_radar_default_constructor']
# The 1 slice source the N2404 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/Radar.java',
]
EXACT_EXPRS = [
    'update = solid = true;',
    'flags = EnumSet.of(BlockFlag.hasFogRadius);',
    'outlineIcon = true;',
]

# DEFERRED is carried from the N2342 register script via import --
# never retyped. Nothing in it closes here: N2404 ports the
# Radar() ctor field defaults, which no N2342 entry lists.
# One entry is added: the N2404 Windows Godot proof debt
# (GOAL.md section 5).
DEFERRED = N2342_DEFERRED + [
    'Radar() ctor field defaults N2404 Windows Godot proof -- debt in GOAL.md section 5, same as N2342: the N2404 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RADAR, **extra):
        return backed(typ, source, expr, rule, **extra)

    ctor_inputs = {
        'radar_defaults': a('Dictionary', 'public Radar(String name){', 'The Radar def frame (Radar.java:27, `public Radar(String name){`): the family-convention first arg; the ctor writes its 3 literal field defaults into it, so radar_defaults is an in/out param -- keys already present keep their unrelated values, the 4 ctor keys are overwritten with the ctor values.'),
        'block_flags': a('Variant', 'flags = EnumSet.of(BlockFlag.hasFogRadius);', 'The block flags (Radar.java:31, `flags = EnumSet.of(BlockFlag.hasFogRadius);`): the block-flag enum value (`hasFogRadius`, BlockFlag.java, core/src/mindustry/world/meta/BlockFlag.java) -- EnumSet is NOT ported here: it arrives as an explicit Variant param and passes through to the result flags key; the Block base default it overrides is `public EnumSet<BlockFlag> flags = EnumSet.of();` (Block.java:251).'),
    }
    ctor_outputs = {
        'update': a('bool', 'update = solid = true;', 'Whether the block updates every tick (Radar.java:30, `update = solid = true;`): Block.update; the ctor enables it for radar. The Block base default is `public boolean update;` (Block.java:102, default false).'),
        'solid': a('bool', 'update = solid = true;', 'Whether the block is solid (Radar.java:30, `update = solid = true;`): Block.solid; the ctor enables it for radar. The Block base default is `public boolean solid;` (Block.java:112, default false).'),
        'flags': a('Variant', 'flags = EnumSet.of(BlockFlag.hasFogRadius);', 'The block flags, read through (Radar.java:31, `flags = EnumSet.of(BlockFlag.hasFogRadius);`): the block-flag enum value passed in as block_flags; the Block base default it overrides is `public EnumSet<BlockFlag> flags = EnumSet.of();` (Block.java:251).'),
        'outline_icon': a('bool', 'outlineIcon = true;', 'Whether the block draws an outline icon (Radar.java:32, `outlineIcon = true;`): Block.outlineIcon; the ctor enables it for radar. The Block base default is `public boolean outlineIcon = false;` (Block.java:313).'),
        'radar_defaults': a('Dictionary', 'public Radar(String name){', 'The updated Radar def frame (Radar.java:27, `public Radar(String name){`): the same in/out Dictionary -- unrelated keys preserved, the 4 ctor keys written with the ctor values.'),
    }
    return ctor_inputs, ctor_outputs


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
    ctor_inputs, ctor_outputs = definitions()

    entries = [
        ('N2404', CTOR_OWNER, 'source_radar_default_constructor_state', RADAR, 'mindustry.world.blocks.defense.Radar', 'Radar(String name)', ctor_inputs, ctor_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Radar() ctor field defaults state from Radar.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Radar() ctor field defaults state from Radar.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the 4 ctor values in ctor
    # order, then the updated def frame.
    by_slice['N2404'] = [
        'source_radar_default_constructor_state_result.update',
        'source_radar_default_constructor_state_result.solid',
        'source_radar_default_constructor_state_result.flags',
        'source_radar_default_constructor_state_result.outline_icon',
        'source_radar_default_constructor_state_result.radar_defaults',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2404', dict(status='done', java_source=RADAR, java_class='mindustry.world.blocks.defense.Radar', java_method='Radar(String name)', godot_owner=CTOR_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2404'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
