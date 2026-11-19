"""Register the Turret status() accessor (N2285).

TurretBuild.status() (Turret.java:369-374) is the block-status
read:
`public BlockStatus status(){`
`if(enabled && !hasAmmo()) return BlockStatus.noInput;`
``
`return super.status();`
`}`
on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
(Turret.java:277). The super chain has two layers:
BaseTurretBuild.status() (BaseTurret.java:143-145,
`return (activationTimer <= 0)? super.status() : BlockStatus.inactive;`)
over BuildingComp.status() (BuildingComp.java:632-646), already
live as N1888 PortGame.source_building_status_state.

RED decisions (resolved at RED): (1) One pure function --
enabled arrives from the tick frame (stamped by
source_turret_tick_frame_state, absent reads true, the N2125
precedent); has_ammo arrives as an explicit bool carrying
hasAmmo() (Turret.java:698-712, `public boolean hasAmmo(){`,
with the ammo-swap side effect, the canConsume() gate and the
cheating() leg) -- NOT ported here (the N2268/N2261 precedent),
because no slice owns hasAmmo() yet; activation_timer arrives
as an explicit float carrying BaseTurretBuild.activationTimer
(BaseTurret.java:115, `public float activationTimer = 0;`, set
to activationTime on placed()); building_status arrives as an
explicit String carrying the live N1888 result. (2) The first
leg needs BOTH conditions: a disabled turret with no ammo falls
through to super.status(), which itself returns logicDisable
for !enabled -- so the function adds no enabled check of its
own in the super leg. (3) The inactive value
(BlockStatus.java:12, `inactive(Color.lightGray);`) has no
N1888 constant, so it carries the family-local const
SOURCE_TURRET_STATUS_INACTIVE in SourceTurretBuildState.gd.
(4) NO driver tick line: status() is a read accessor its
callers read, not a per-tick write (the N2249/N2221
precedent). One new result symbol: status. Four slice
sources: Turret.java + BaseTurret.java + BuildingComp.java +
BlockStatus.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_min_range import DEFERRED as N2282_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK_STATUS = 'core/src/mindustry/world/meta/BlockStatus.java'
PROOF = '/root/C07TurretStatusProof'
OWNER = 'SourceTurretBuildState.source_turret_status_state'
TESTS = ['test_c07_turret_status_registration', 'test_all_c07_turret_status_input_evidence_is_exact', 'test_turret_status_state', 'test_reference_graph_and_actual_c07_turret_status']
# The 4 slice sources the N2285 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/meta/BlockStatus.java',
]
EXACT_EXPRS = [
    'public class Turret extends ReloadTurret{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public BlockStatus status(){',
    'if(enabled && !hasAmmo()) return BlockStatus.noInput;',
    'return super.status();',
    'public boolean hasAmmo(){',
    'public class BaseTurret extends Block{',
    'public class BaseTurretBuild extends Building implements Ranged, RotBlock{',
    'public float activationTimer = 0;',
    'public BlockStatus status() {',
    'return (activationTimer <= 0)? super.status() : BlockStatus.inactive;',
    'if(!enabled){',
    'return BlockStatus.logicDisable;',
    'if(!shouldConsume()){',
    'return BlockStatus.noOutput;',
    'if(efficiency <= 0 || !productionValid()){',
    'return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;',
    'transient boolean enabled = true;',
    'inactive(Color.lightGray);',
    'noInput(Pal.remove),',
]

# DEFERRED is carried from the N2282 register script via import --
# never retyped. Nothing in it closes here: status() was never
# a deferred entry of the Turret chain. One entry is added: the
# N2285 Windows Godot proof debt (GOAL.md section 5).
DEFERRED = N2282_DEFERRED + [
    'Turret status() Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2285 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    inputs = {
        'frame': a('Dictionary', 'public BlockStatus status(){', 'The turret frame (TurretBuild.status, Turret.java:369): the family-convention first arg every Turret pure function takes; it carries `enabled` (stamped every tick by source_turret_tick_frame_state, absent reads true, the N2125 precedent -- BuildingComp.java:77, `transient boolean enabled = true;`).'),
        'has_ammo': a('bool', 'public boolean hasAmmo(){', 'Whether the turret has usable ammo (`hasAmmo()`, Turret.java:370): carries the hasAmmo() result (`public boolean hasAmmo(){`, Turret.java:698-712, with the ammo-swap side effect, the canConsume() gate and the cheating() leg) -- NOT ported here (the N2268/N2261 precedent), because no slice owns hasAmmo() yet.'),
        'activation_timer': a('float', 'public float activationTimer = 0;', 'The activation timer (`activationTimer`, BaseTurret.java:144): the BaseTurretBuild field (`public float activationTimer = 0;`, BaseTurret.java:115, set to activationTime on placed()); the BaseTurret leg returns super.status() while it is at most zero, BlockStatus.inactive while it is positive.', source=BASE_TURRET),
        'building_status': a('String', 'public BlockStatus status(){', 'The BuildingComp.status() result (BuildingComp.java:632-646): the live N1888 PortGame.source_building_status_state helper -- "logicDisable" / "noOutput" / "noInput" / "active"; returned as-is when the activation timer is at most zero. The N1888 helper already returns logicDisable for !enabled, so no enabled check of its own is needed in this leg.', source=BUILDING_COMP),
    }
    outputs = {
        'status': a('String', 'if(enabled && !hasAmmo()) return BlockStatus.noInput;', 'The block status (Turret.java:370-372, `if(enabled && !hasAmmo()) return BlockStatus.noInput;` / `return super.status();`): "noInput" when enabled with no ammo, else the BuildingComp.status() result when the activation timer is at most zero, else "inactive" (BlockStatus.java:12, `inactive(Color.lightGray);`).'),
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
        ('N2285', OWNER, 'source_turret_status_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.status()', inputs, outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.status() state from Turret.java + BaseTurret.java + BuildingComp.java + BlockStatus.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.status() state from Turret.java + BaseTurret.java + BuildingComp.java + BlockStatus.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: status.
    by_slice['N2285'] = [
        'source_turret_status_state_result.status',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2285', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.status()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2285'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
