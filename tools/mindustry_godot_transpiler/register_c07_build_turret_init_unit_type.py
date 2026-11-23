"""Register the BuildTurret init() UnitType fields slice (N2426).

BuildTurret.init() (BuildTurret.java:50-69, `public void
init(){`) -- this slice is ONLY the 6 UnitType field lines
inside the anonymous `unitType = new
UnitType("turret-unit-" + name){{` (:56):

- `hidden = true;` (:57)
- `internal = true;` (:58)
- `speed = 0f;` (:59)
- `hitSize = 0f;` (:60)
- `health = 1;` (:61)
- `rotateSpeed = BuildTurret.this.rotateSpeed;` (:63)

NOT this slice: `if(elevation < 0) elevation = size /
2f;` (:53, already owned), `itemCapacity = 0;` (:62,
already owned), `buildBeamOffset =
BuildTurret.this.buildBeamOffset;` / `buildRange =
BuildTurret.this.range;` / `buildSpeed =
BuildTurret.this.buildSpeed;` / `constructor =
BlockUnitUnit::create;` (:64-67, already owned at
N2184), the opener :56 and the `}};` closer :68
(generic). The 6 exprs are 0-hit in BOTH ledgers at RED
(exact + strip + normalize), and `java_method`
BuildTurret.init() is 0-hit in both. One pure function
on SourceBuildTurretBuildState.gd (the BuildTurret file,
static func -- the N2184/N2201/N2423 convention for
this file, NOT PortGame.*). One owner + one GD func +
one contract. The block's rotateSpeed is the only
input: the constructor default is `rotateSpeed = 10f;`
(BuildTurret.java:45), but the init line reads the live
block field, so the caller passes it explicitly; the 5
other fields are constants taken from the Java lines.
Slice source: BuildTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_build_turret_update_tile_plan import DEFERRED as N2423_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILD_TURRET = 'core/src/mindustry/world/blocks/defense/BuildTurret.java'
PROOF = '/root/C07BuildTurretInitUnitTypeProof'
INIT_OWNER = 'SourceBuildTurretBuildState.source_build_turret_init_unit_type_state'
TESTS = ['test_c07_build_turret_init_unit_type_registration', 'test_all_c07_build_turret_init_unit_type_input_evidence_is_exact', 'test_build_turret_init_unit_type_state', 'test_reference_graph_and_actual_c07_build_turret_init_unit_type']
# The 1 slice source the N2426 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/BuildTurret.java',
]
EXACT_EXPRS = [
    'hidden = true;',
    'internal = true;',
    'speed = 0f;',
    'hitSize = 0f;',
    'health = 1;',
    'rotateSpeed = BuildTurret.this.rotateSpeed;',
]

# DEFERRED is carried from the N2423 register script via import --
# never retyped. This slice resolves NONE of the carried entries
# (the init UnitType fields are not the updateTile plan legs,
# the Units.nearby mimic query, the driver call site, or the
# timer evaluation), so all are carried verbatim. One entry is
# added: N2426's Windows proof debt.
DEFERRED = list(N2423_DEFERRED) + [
    'BuildTurret init() UnitType fields Windows Godot proof -- debt in GOAL.md section 5, same as N2184-N2201/N2423: the N2426 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BUILD_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    init_inputs = {
        'rotate_speed': a('float', 'rotateSpeed = BuildTurret.this.rotateSpeed;', 'The block rotate speed (BuildTurret.java:63, `rotateSpeed = BuildTurret.this.rotateSpeed;`): the BuildTurret field -- constructor default `rotateSpeed = 10f;` (BuildTurret.java:45) -- passed explicitly because the init line reads the live block field.'),
    }
    init_outputs = {
        'hidden': a('bool', 'hidden = true;', 'Whether the builder unit type is hidden (BuildTurret.java:57, `hidden = true;`): the turret-unit never shows in the unit list.'),
        'internal': a('bool', 'internal = true;', 'Whether the builder unit type is internal (BuildTurret.java:58, `internal = true;`): the turret-unit is an internal helper unit.'),
        'speed': a('float', 'speed = 0f;', 'The builder unit speed (BuildTurret.java:59, `speed = 0f;`): the turret-unit never moves.'),
        'hit_size': a('float', 'hitSize = 0f;', 'The builder unit hit size (BuildTurret.java:60, `hitSize = 0f;`): the turret-unit never takes hits.'),
        'health': a('int', 'health = 1;', 'The builder unit health (BuildTurret.java:61, `health = 1;`): the turret-unit exists only to carry the build plan.'),
        'rotate_speed': a('float', 'rotateSpeed = BuildTurret.this.rotateSpeed;', 'The builder unit rotate speed (BuildTurret.java:63, `rotateSpeed = BuildTurret.this.rotateSpeed;`): copied from the block field.'),
    }
    return init_inputs, init_outputs


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
    (init_inputs, init_outputs) = definitions()

    entries = [
        ('N2426', INIT_OWNER, 'source_build_turret_init_unit_type_state', BUILD_TURRET, 'mindustry.world.blocks.defense.BuildTurret', 'BuildTurret.init()', init_inputs, init_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BuildTurret init() UnitType fields from BuildTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BuildTurret init() UnitType fields from BuildTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: hidden, internal, speed,
    # hit_size, health, rotate_speed.
    by_slice['N2426'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2426', dict(status='done', java_source=BUILD_TURRET, java_class='mindustry.world.blocks.defense.BuildTurret', java_method='BuildTurret.init()', godot_owner=INIT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2426'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
