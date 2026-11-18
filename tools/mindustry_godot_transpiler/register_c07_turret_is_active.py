"""Register the Turret isActive() predicate (N2279).

TurretBuild.isActive() (Turret.java:449-451) is the one-line
activity gate:
`public boolean isActive(){`
`return (target != null || wasShooting) && enabled && activationTimer <= 0;`
on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
(Turret.java:277). The three inputs are TurretBuild /
BaseTurretBuild / BuildingComp fields: target (`public
@Nullable Posc target;`, Turret.java:289), wasShooting
(`public boolean wasShooting, isShooting;`,
Turret.java:292, set in updateTile :517/:600/:608 from the
previous tick's shooting state), enabled (`transient
boolean enabled = true;`, BuildingComp.java:77), and
activationTimer (`public float activationTimer = 0;`,
BaseTurret.java:115, set to activationTime on placed(),
BaseTurret.java:120 `activationTimer = activationTime;`,
against `public float activationTime = 0f;`,
BaseTurret.java:27 -- the placement delay before a
turret starts shooting).

RED decisions (resolved at RED): (1) One pure function --
target arrives as the explicit bool target_is_null (the
invalidateTarget :488 precedent), wasShooting arrives as
the explicit bool is_shooting (the should_consume :164 /
sense :267 / update_tile_warmup :384 precedent -- the
param is named is_shooting per the family convention, but
for isActive() it carries wasShooting, the previous
tick's shooting flag), activationTimer arrives as the
explicit float activation_timer (the frame tracks no
activation timer key -- _initial_frame() returns {} and
the file has no activation_timer key), and enabled is
read from the frame (the tick frame stamps
frame["enabled"], default true, matching the Java field
default). (2) The comparison is `<= 0`: a timer of
exactly 0 is active, matching Java exactly. (3) NO
driver tick line: isActive() is a predicate the tick
driver reads, not a tick write of its own -- wiring it
into the driver waits for its own slice. (4) isActive()
has no caller inside Turret.java; its live callers
(sound/status paths) are their own slices. One new
result symbol: is_active. Three slice sources:
Turret.java + BaseTurret.java + BuildingComp.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_write_read import DEFERRED as N2276_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07TurretIsActiveProof'
OWNER = 'SourceTurretBuildState.source_turret_is_active_state'
TESTS = ['test_c07_turret_is_active_registration', 'test_all_c07_turret_is_active_input_evidence_is_exact', 'test_turret_is_active_state', 'test_reference_graph_and_actual_c07_turret_is_active']
# The 3 slice sources the N2279 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
]
EXACT_EXPRS = [
    'public class Turret extends ReloadTurret{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public class BaseTurret extends Block{',
    'public class BaseTurretBuild extends Building implements Ranged, RotBlock{',
    'public boolean isActive(){',
    'return (target != null || wasShooting) && enabled && activationTimer <= 0;',
    'public @Nullable Posc target;',
    'public boolean wasShooting, isShooting;',
    'transient boolean enabled = true;',
    'public float activationTimer = 0;',
    'public float activationTime = 0f;',
    'activationTimer = activationTime;',
]

# DEFERRED is carried from the N2276 register script via import --
# never retyped. Nothing in it closes here: isActive() was never
# a deferred entry of the Turret chain. One entry is added: the
# N2279 Windows Godot proof debt (GOAL.md section 5).
DEFERRED = N2276_DEFERRED + [
    'Turret isActive() Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2279 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    inputs = {
        'frame': a('Dictionary', 'public boolean isActive(){', 'The turret frame (TurretBuild.isActive, Turret.java:449): the family-convention first arg every Turret pure function takes; it is read for the tracked enabled key only -- the tick frame stamps frame["enabled"], default true (BuildingComp.java:77, `transient boolean enabled = true;`).'),
        'target_is_null': a('bool', 'public @Nullable Posc target;', 'Whether the turret has no target (`target != null`, Turret.java:450): the TurretBuild field (`public @Nullable Posc target;`, Turret.java:289); the driver computes the null check (the invalidateTarget :488 precedent) -- a null target makes this true.'),
        'is_shooting': a('bool', 'public boolean wasShooting, isShooting;', 'Whether the turret shot on the previous tick (`wasShooting`, Turret.java:450): named is_shooting per the family convention (should_consume :164, sense :267, update_tile_warmup :384 take is_shooting), but for isActive() it carries wasShooting (`public boolean wasShooting, isShooting;`, Turret.java:292), set in updateTile :517/:600/:608.'),
        'activation_timer': a('float', 'public float activationTimer = 0;', 'The placement activation timer (`activationTimer <= 0`, Turret.java:450): the BaseTurretBuild field (`public float activationTimer = 0;`, BaseTurret.java:115), set to activationTime on placed() (BaseTurret.java:120, `activationTimer = activationTime;`, against `public float activationTime = 0f;`, BaseTurret.java:27); an explicit param because the frame tracks no activation timer key.', source=BASE_TURRET),
    }
    outputs = {
        'is_active': a('bool', 'return (target != null || wasShooting) && enabled && activationTimer <= 0;', 'Whether the turret counts as active (Turret.java:450, `return (target != null || wasShooting) && enabled && activationTimer <= 0;`): a target or a previous-tick shot, and enabled, and the activation timer elapsed (exactly 0 counts as elapsed).'),
    }
    return inputs, outputs


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
    inputs, outputs = definitions()

    entries = [
        ('N2279', OWNER, 'source_turret_is_active_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.isActive()', inputs, outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.isActive() state from Turret.java + BaseTurret.java + BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.isActive() state from Turret.java + BaseTurret.java + BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: is_active.
    by_slice['N2279'] = [
        'source_turret_is_active_state_result.is_active',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2279', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.isActive()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2279'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
