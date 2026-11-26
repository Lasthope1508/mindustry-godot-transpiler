"""Register ReloadTurretBuild.baseReloadSpeed() (N2476).

ReloadTurretBuild.baseReloadSpeed() (ReloadTurret.java:45-47) is one
slice (batch 51 slot 1):
    protected float baseReloadSpeed(){
        return efficiency;
    }
It is the base reload-speed factor TurretBuild.updateReload()
(Turret.java:719-721, N746) multiplies in
(`reloadCounter += delta() * ammoReloadMultiplier() *
baseReloadSpeed();`) -- but N746 registers updateReload, not
baseReloadSpeed, so this slice owns the factor itself. The trap
is that efficiency is returned WHOLE: no clamp, no floor --
efficiency 0 stays 0.0, efficiency > 1 passes through (a port
that clamps to [0, 1] is wrong), and a negative efficiency
passes through (Java has no Math.min/max here; the cap in
updateReload is on reloadCounter, not on this factor).
`efficiency` is the Building field (BuildingComp.java:84-85,
"Base efficiency. Takes the minimum value of all consumers",
transient float). Do NOT confuse with ammoReloadMultiplier()
(ReloadTurret.java:41-43, same class, returns the constant
1f -- NOT registered by this slice) or with
TurretBuild.ammoReloadMultiplier() (N746, Turret.java:724-726,
a ternary on peekAmmo -- a different method that DOES look at
ammo; baseReloadSpeed never looks at ammo). One GD function
on the existing file SourceTurretBuildState.gd (home of N2473
source_reload_turret_can_reload_state), placed between
source_turret_cooling_state (Java updateCooling :28-38) and
source_reload_turret_can_reload_state (Java canReload
:49-51) because baseReloadSpeed() (:45-47) comes after
updateCooling() and before canReload() in Java order; the
spare ammoReloadMultiplier (:41-43) would slot between
cooling and baseReloadSpeed if ported later. Slot is CLEAN,
no twin-register: java_method exact + substring
`baseReloadSpeed` are 0-hit in the ledger, the declaration
line is 0-hit in exact_exprs, and the body line
`return efficiency;` has 5 hits that all belong to other
methods (ambientVolume x2, BuildingComp.update x2,
TurretBuild.updateTile) -- a generic literal, not this
method. One slice source: ReloadTurret.java (plus
BuildingComp.java for the efficiency field definition).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07ReloadTurretBaseReloadSpeedProof'
BASE_RELOAD_SPEED_OWNER = 'SourceTurretBuildState.source_reload_turret_base_reload_speed_state'
TESTS = ['test_c07_reload_turret_base_reload_speed_registration', 'test_all_c07_reload_turret_base_reload_speed_input_evidence_is_exact', 'test_reload_turret_base_reload_speed_state', 'test_reference_graph_and_actual_c07_reload_turret_base_reload_speed']
# The 2 slice sources the N2476 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
]
FORMULA = '            return efficiency;'
EXACT_EXPRS = [
    '        protected float baseReloadSpeed(){',
    FORMULA,
    '    transient float efficiency;',
]
JAVA_METHOD = 'ReloadTurretBuild.baseReloadSpeed()'

DEFERRED = [
    'ReloadTurretBuild.baseReloadSpeed() Windows Godot proof -- debt in GOAL.md section 5: the N2476 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RELOAD_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    base_reload_speed_inputs = {
        'efficiency': a('float', FORMULA, 'The base efficiency (ReloadTurret.java:45-47): the Building field `efficiency` (BuildingComp.java:84-85, "Base efficiency. Takes the minimum value of all consumers", transient float), returned whole as the base reload-speed factor -- no clamp, no floor.'),
    }
    base_reload_speed_outputs = {
        'base_reload_speed': a('float', FORMULA, 'The base reload speed (ReloadTurret.java:45-47): `efficiency` returned whole -- 0 stays 0.0, > 1 passes through, a negative value passes through (no Math.min/max here; the cap in updateReload is on reloadCounter, not on this factor).'),
    }
    return base_reload_speed_inputs, base_reload_speed_outputs


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
    base_reload_speed_inputs, base_reload_speed_outputs = definitions()

    entries = [
        ('N2476', BASE_RELOAD_SPEED_OWNER, 'source_reload_turret_base_reload_speed_state', RELOAD_TURRET, 'mindustry.world.blocks.defense.turrets.ReloadTurret.ReloadTurretBuild', JAVA_METHOD, base_reload_speed_inputs, base_reload_speed_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ReloadTurretBuild.baseReloadSpeed() state from ReloadTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ReloadTurretBuild.baseReloadSpeed() state from ReloadTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2476'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2476', dict(status='done', java_source=RELOAD_TURRET, java_class='mindustry.world.blocks.defense.turrets.ReloadTurret.ReloadTurretBuild', java_method=JAVA_METHOD, godot_owner=BASE_RELOAD_SPEED_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2476'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
