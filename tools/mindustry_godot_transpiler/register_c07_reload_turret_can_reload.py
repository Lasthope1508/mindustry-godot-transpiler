"""Register ReloadTurretBuild.canReload() (N2473).

ReloadTurretBuild.canReload() (ReloadTurret.java:49-51) is one
slice (batch 50 slot 1):
    protected boolean canReload(){
        return reloadCounter < reload;
    }
It is the gate its own class's updateCooling() (N2525,
ReloadTurret.java:28-38) calls first (`if(canReload() &&
coolant != null && ...){`, :29) and the gate
TurretBuild.shouldConsume() (N2291, Turret.java:364-366,
`return isShooting || reloadCounter < reload;`) embeds as
half of an OR -- but NEITHER slice registers canReload():
N2525 registers updateCooling, N2291 registers
shouldConsume, and N2280 isActive embeds the same
expression without registering this method. The trap is
that the comparison is STRICT `<`: counter == reload is
false, 0 < 0 is false, and a negative counter is NOT
clamped (Java has no Math.max here; capping lives in
updateReload, not in canReload). A port that uses `<=`
or clamps the counter at 0 is wrong. One GD function on
the existing file SourceTurretBuildState.gd (home of
N2525 source_turret_cooling_state), placed between
source_turret_cooling_state (Java updateCooling :28-38)
and source_turret_range_state (Java TurretBuild.range
:334-350) because canReload() (:49-51) comes after
updateCooling() and before range() in Java order; the
spare ammoReloadMultiplier (:41-43) and baseReloadSpeed
(:45-47) would slot between cooling and canReload if
ported later. The reload field defaults to 10f
(ReloadTurret.java:10) and reloadCounter defaults to
0f (ReloadTurretBuild field :26, Java float default).
One slice source: ReloadTurret.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
PROOF = '/root/C07ReloadTurretCanReloadProof'
CAN_RELOAD_OWNER = 'SourceTurretBuildState.source_reload_turret_can_reload_state'
TESTS = ['test_c07_reload_turret_can_reload_registration', 'test_all_c07_reload_turret_can_reload_input_evidence_is_exact', 'test_reload_turret_can_reload_state', 'test_reference_graph_and_actual_c07_reload_turret_can_reload']
# The 1 slice source the N2473 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
]
FORMULA = '            return reloadCounter < reload;'
EXACT_EXPRS = [
    '        protected boolean canReload(){',
    FORMULA,
    '    public float reload = 10f;',
    '        public float reloadCounter;',
]
JAVA_METHOD = 'ReloadTurretBuild.canReload()'

DEFERRED = [
    'ReloadTurretBuild.canReload() Windows Godot proof -- debt in GOAL.md section 5: the N2473 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RELOAD_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    can_reload_inputs = {
        'reload_counter': a('float', FORMULA, 'The reload counter (ReloadTurret.java:49-51): the ReloadTurretBuild field `reloadCounter` (:26, Java float default 0f), the left half of the strict `<` comparison.'),
        'reload': a('float', FORMULA, 'The per-def reload time in ticks (ReloadTurret.java:49-51): the ReloadTurret field `reload` (:10, default 10f), the right half of the strict `<` comparison.'),
    }
    can_reload_outputs = {
        'can_reload': a('bool', FORMULA, 'Whether the turret can reload (ReloadTurret.java:49-51): `reloadCounter < reload`, STRICT `<` -- counter == reload is false, 0 < 0 is false, and a negative counter is NOT clamped (no Math.max here; capping lives in updateReload, not in canReload).'),
    }
    return can_reload_inputs, can_reload_outputs


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
    can_reload_inputs, can_reload_outputs = definitions()

    entries = [
        ('N2473', CAN_RELOAD_OWNER, 'source_reload_turret_can_reload_state', RELOAD_TURRET, 'mindustry.world.blocks.defense.turrets.ReloadTurret.ReloadTurretBuild', JAVA_METHOD, can_reload_inputs, can_reload_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ReloadTurretBuild.canReload() state from ReloadTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ReloadTurretBuild.canReload() state from ReloadTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2473'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2473', dict(status='done', java_source=RELOAD_TURRET, java_class='mindustry.world.blocks.defense.turrets.ReloadTurret.ReloadTurretBuild', java_method=JAVA_METHOD, godot_owner=CAN_RELOAD_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2473'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
