"""Register BaseTurretBuild.status() (N2475).

BaseTurretBuild.status() (BaseTurret.java:143-145) is one slice
(batch 50 slot 3):
    @Override
    public BlockStatus status() {
        return (activationTimer <= 0)? super.status() : BlockStatus.inactive;
    }
The boundary trap is `<= 0`: timer 0 returns super.status()
(the base), NOT inactive -- a port using `< 0` fails the
timer-zero key. super.status() is BuildingComp.status()
(BuildingComp.java:632-646, already live as N1888
PortGame.source_building_status_state) -- it arrives here as
the PRECOMPUTED base_status input (the N1256/N2374
precedent), NOT re-ported. `inactive`
(BlockStatus.inactive) is NOT `inactiveUnitFactory` --
the proof pins a base "inactiveUnitFactory" overridden to
"inactive" when the timer is positive. activationTimer is
the BaseTurretBuild field (`public float activationTimer = 0;`,
BaseTurret.java:115, default 0), set to activationTime by
placed() (BaseTurret.java:119-122).

TWIN NOTE -- the body literal `return (activationTimer <= 0)?
super.status() : BlockStatus.inactive;` is ALREADY an
exact_expr of N2285 (TurretBuild.status(), Turret.java:369-374),
which cites it as the super chain of TurretBuild.status()
and INLINES the leg in source_turret_status_state
(`if activation_timer <= 0.0: return building_status`,
SourceTurretBuildState.gd). This slice is NOT a duplicate
of N2285: TurretBuild.status() is a different java_method
with the hasAmmo leg, and its Java body never mentions
activationTimer. This slice adds the first GD function OWNED
as BaseTurretBuild.status(), for the inheritors that do NOT
override status() -- RadarBuild, BuildTurretBuild and
ReloadTurretBuild all read status() through this method
(their status() resolves to BaseTurretBuild.status(), with
super = BuildingComp.status()). The main thread assigned
N2475 with this N2285 distinction explicit (2026-11-26).
Precedent for twin registration with explicit main-thread
approval: N2474 (isCampaign, N2124), N2421, N2389, N2418.
One slice source: BaseTurret.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
PROOF = '/root/C07BaseTurretStatusProof'
STATUS_OWNER = 'SourceTurretBuildState.source_base_turret_build_status_state'
TESTS = ['test_c07_base_turret_status_registration', 'test_all_c07_base_turret_status_input_evidence_is_exact', 'test_base_turret_status_state', 'test_reference_graph_and_actual_c07_base_turret_status']
# The 1 slice source the N2475 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
]
FORMULA = '            return (activationTimer <= 0)? super.status() : BlockStatus.inactive;'
EXACT_EXPRS = [
    '        public BlockStatus status() {',
    FORMULA,
    '        public float activationTimer = 0;',
    '    public class BaseTurretBuild extends Building implements Ranged, RotBlock{',
]
JAVA_METHOD = 'BaseTurretBuild.status()'

DEFERRED = [
    'BaseTurretBuild.status() Windows Godot proof -- debt in GOAL.md section 5: the N2475 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BaseTurretBuild.status() is a TWIN-REGISTER with explicit main-thread assignment (2026-11-26): the literal `return (activationTimer <= 0)? super.status() : BlockStatus.inactive;` is also an exact_expr of N2285 (TurretBuild.status()), which cites it as the super chain and inlines the leg in source_turret_status_state; N2285 is a different java_method (hasAmmo leg, Java body never mentions activationTimer) and ports no function owned as BaseTurretBuild.status(). Precedent: N2474, N2421, N2389, N2418.',
    'BaseTurretBuild.estimateDps() (BaseTurret.java:137-139) is NOT in this slice: it sits between drawSelect() (:133-135) and status() (:143-145) in Java and is spared -- a later slice inserts its GD function between source_base_turret_build_draw_select_state and source_base_turret_build_status_state.',
]


def definitions():
    def a(typ, expr, rule, source=BASE_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    status_inputs = {
        'activation_timer': a('float', FORMULA, 'The activation countdown (BaseTurret.java:115, `public float activationTimer = 0;`, default 0): set to activationTime by placed() (BaseTurret.java:119-122, `activationTimer = activationTime;`). The boundary is `<= 0` -- timer 0 returns the base status, NOT inactive.'),
        'base_status': a('String', FORMULA, 'The precomputed super.status() result (BaseTurret.java:144, `super.status()`, i.e. BuildingComp.status(), BuildingComp.java:632-646, already live as N1888 PortGame.source_building_status_state): arrives as an explicit input (the N1256/N2374 precedent), NOT re-ported here. One of "active", "noOutput", "noInput", "logicDisable", "inactiveUnitFactory", "inactive".'),
    }
    status_outputs = {
        'status': a('String', FORMULA, 'The block status (BaseTurret.java:144, `return (activationTimer <= 0)? super.status() : BlockStatus.inactive;`): base_status when activation_timer <= 0, else "inactive" (BlockStatus.inactive -- NOT "inactiveUnitFactory", a different enum value).'),
    }
    return status_inputs, status_outputs


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
    status_inputs, status_outputs = definitions()

    entries = [
        ('N2475', STATUS_OWNER, 'source_base_turret_build_status_state', BASE_TURRET, 'mindustry.world.blocks.defense.turrets.BaseTurret.BaseTurretBuild', JAVA_METHOD, status_inputs, status_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BaseTurretBuild.status() state from BaseTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BaseTurretBuild.status() state from BaseTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2475'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2475', dict(status='done', java_source=BASE_TURRET, java_class='mindustry.world.blocks.defense.turrets.BaseTurret.BaseTurretBuild', java_method=JAVA_METHOD, godot_owner=STATUS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2475'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
