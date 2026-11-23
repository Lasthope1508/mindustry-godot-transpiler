"""Register the Turret handleLiquid() (N2356).

TurretBuild.handleLiquid() (Turret.java:615-621,
`@Override` / `public void handleLiquid(Building source,
Liquid liquid, float amount){` / `if(coolant != null &&
liquids.currentAmount() <= 0.001f){` /
`Events.fire(Trigger.turretCool);` / `}` /
`super.handleLiquid(source, liquid, amount);` / `}`) is
one pure function on SourceTurretBuildState.gd next to
the N2353 readSync function. When the turret block has
a coolant consumer (`public @Nullable ConsumeLiquidBase
coolant;`, BaseTurret.java:34) and the liquid store is
(near-)empty (`public float currentAmount(){`,
LiquidModule.java:98, `<= 0.001f`), the turret-cool
event fires (`Events.fire(Trigger.turretCool);`) -- the
port records it as the bool flag turret_cool_fired, it
does NOT port Events/Trigger. The base
BuildingComp.handleLiquid (BuildingComp.java:872-874,
`public void handleLiquid(Building source, Liquid
liquid, float amount){` / `liquids.add(liquid,
amount);`) is ALWAYS called via super -- the port
records it as the flag super_called, it does NOT port
Building.handleLiquid (the N585 base slice owns the
`liquids.add(liquid, amount);` line).

RED decisions (resolved at RED): (1) One slice entry
for the one method, following the N2343/N2348/N2353
precedent (one ledger entry per method group, one
function per method). (2) The frame is the
family-convention first arg and is read for nothing:
handleLiquid writes no frame state; the coolant
presence arrives as the explicit bool param
has_coolant and the liquid amount as the explicit
float param liquid_amount (the N2330 param precedent
-- the port has no liquid flow to measure here). (3)
The function returns two keys: turret_cool_fired,
true exactly when has_coolant and liquid_amount <=
0.001, plus super_called, always true -- the Turret
override delegates to the Building base
unconditionally. (4) The signature line
`public void handleLiquid(Building source, Liquid
liquid, float amount){` is shared text with N585
(BuildingComp.handleLiquid base, a different class
and method) and N2118 (GenericCrafterBuild evidence)
-- callee/context evidence, not ownership of
TurretBuild.handleLiquid(); this slice registers the
correct java_method = TurretBuild.handleLiquid() (the
batch-10 scope section 1.2 flag, resolved here, not
stalled on). (5) NO driver tick line: the engine calls
handleLiquid() when liquid enters the building; no
call site is ported here. (6) This slice closes no
deferred entry -- no deferred entry mentions
handleLiquid. Two new result symbols. Four slice
sources: Turret.java + BaseTurret.java +
BuildingComp.java + LiquidModule.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_read_sync import DEFERRED as N2353_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
LIQUID_MODULE = 'core/src/mindustry/world/modules/LiquidModule.java'
PROOF = '/root/C07TurretHandleLiquidProof'
HANDLE_LIQUID_OWNER = 'SourceTurretBuildState.source_turret_handle_liquid_state'
TESTS = ['test_c07_turret_handle_liquid_registration', 'test_all_c07_turret_handle_liquid_input_evidence_is_exact', 'test_turret_handle_liquid_state', 'test_reference_graph_and_actual_c07_turret_handle_liquid']
# The 4 slice sources the N2356 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/modules/LiquidModule.java',
]
EXACT_EXPRS = [
    'public class Turret extends ReloadTurret{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public @Nullable ConsumeLiquidBase coolant;',
    '@Override',
    'public void handleLiquid(Building source, Liquid liquid, float amount){',
    'if(coolant != null && liquids.currentAmount() <= 0.001f){',
    'Events.fire(Trigger.turretCool);',
    'super.handleLiquid(source, liquid, amount);',
    'liquids.add(liquid, amount);',
    'public float currentAmount(){',
]

# DEFERRED is carried from the N2353 register script via import --
# never retyped. No deferred entry mentions handleLiquid, so this
# slice closes none; it only adds its own Windows-proof debt entry.
DEFERRED = list(N2353_DEFERRED) + [
    'Turret handleLiquid Windows Godot proof -- debt in GOAL.md section 5, same as N2353: the N2356 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    handle_liquid_inputs = {
        'frame': a('Dictionary', 'public void handleLiquid(Building source, Liquid liquid, float amount){', 'The turret frame (TurretBuild.handleLiquid, Turret.java:615): the family-convention first arg every Turret pure function takes; it is read for nothing here -- handleLiquid writes no frame state.'),
        'has_coolant': a('bool', 'public @Nullable ConsumeLiquidBase coolant;', 'Whether the turret block has a coolant consumer (Turret.java:616, `if(coolant != null && liquids.currentAmount() <= 0.001f){`): the block field (`public @Nullable ConsumeLiquidBase coolant;`, BaseTurret.java:34) arrives as an explicit bool param (the N2330 param precedent).', source=BASE_TURRET),
        'liquid_amount': a('float', 'if(coolant != null && liquids.currentAmount() <= 0.001f){', 'The current liquid amount (Turret.java:616, `if(coolant != null && liquids.currentAmount() <= 0.001f){`): `public float currentAmount(){` (LiquidModule.java:98) arrives as an explicit float param -- the port has no liquid flow to measure here (the N2330 param precedent).'),
    }
    handle_liquid_outputs = {
        'turret_cool_fired': a('bool', 'Events.fire(Trigger.turretCool);', 'Whether the turret-cool event fired (Turret.java:617, `Events.fire(Trigger.turretCool);`): true exactly when the block has a coolant consumer and the liquid store is (near-)empty (`<= 0.001f`); the port records the event as a bool flag, it does NOT port Events/Trigger.'),
        'super_called': a('bool', 'super.handleLiquid(source, liquid, amount);', 'Whether the Building base handleLiquid was called (Turret.java:620, `super.handleLiquid(source, liquid, amount);`): always true -- the Turret override delegates to the base (BuildingComp.java:872-874, `public void handleLiquid(Building source, Liquid liquid, float amount){` / `liquids.add(liquid, amount);`) unconditionally; Building.handleLiquid itself is NOT ported here (the N585 base slice owns the `liquids.add(liquid, amount);` line).'),
    }
    return (handle_liquid_inputs, handle_liquid_outputs)


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
    (handle_liquid_inputs, handle_liquid_outputs) = definitions()

    entries = [
        ('N2356', HANDLE_LIQUID_OWNER, 'source_turret_handle_liquid_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.handleLiquid()', handle_liquid_inputs, handle_liquid_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.handleLiquid() state from Turret.java + BaseTurret.java + BuildingComp.java + LiquidModule.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.handleLiquid() state from Turret.java + BaseTurret.java + BuildingComp.java + LiquidModule.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: turret_cool_fired, super_called.
    by_slice['N2356'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2356', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.handleLiquid()', godot_owner=HANDLE_LIQUID_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2356'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
