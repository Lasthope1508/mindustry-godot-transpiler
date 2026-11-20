"""Register the ContinuousTurret getAmmoFraction() (N2355).

ContinuousTurretBuild.getAmmoFraction()
(ContinuousTurret.java:75-84, `@Override` /
`public float getAmmoFraction(){` /
`//TODO unclean way of calculating ammo fraction to display` /
`float ammoFract = efficiency;` /
`if(findConsumer(f -> f instanceof ConsumeLiquidBase) instanceof ConsumeLiquid cons){` /
`ammoFract = Math.min(ammoFract, liquids.get(cons.liquid) / liquidCapacity);` /
`return ammoFract;`) is one pure function on the NEW
SourceContinuousTurretBuildPortBridge.gd, following the
ItemTurret PortBridge precedent
(SourceItemTurretBuildPortBridge.gd:23,
source_item_turret_build_get_ammo_fraction_state). It
starts from the block efficiency and caps it by the
liquid fraction when a ConsumeLiquid consumer exists.

RED decisions (resolved at RED): (1) The function lives
directly in the new PortBridge file: there is no
SourceContinuousTurretBuildState.gd to delegate to.
The SSOT owner is PortGame (not the bridge filename):
PortBridge files are discovered by the catalog validator
as port_game.* (source_symbols._discover_godot_owner_functions
forces class_name "port_game" for *PortBridge.gd), the same
as every other PortBridge contract (e.g. N1181
PortGame.source_item_turret_build_get_ammo_fraction_state).
Registering the bridge filename as owner breaks
implementation_linkage validation (gate batch 9: 9 failures)
-- fixed here, owner PortGame.
(2) The findConsumer lookup is NOT ported: its result
arrives as the explicit has_liquid_consumer +
liquid_amount params (the N2330 param precedent).
liquidCapacity is a live block field, taken as an
explicit param; it is never zero for a block with a
liquid consumer, so no guard is invented. (3) All
inputs are scalars -- there is no dict frame input, so
there is no input-unmutated proof key for this slice
(unlike the frame-taking Turret accessors). (4) NO
driver line: a pure accessor the HUD caller reads, not
a per-tick write. (5) Evidence, not ownership: the
other getAmmoFraction overrides own their own bodies --
TurretBuild base (N2348, constant 1f), ItemTurretBuild
(N1181), LiquidTurretBuild (N1198),
ContinuousLiquidTurretBuild (N1221), PowerTurretBuild
(N1168) -- and are NOT touched here. One new result
symbol: ammo_fraction. Slice source: ContinuousTurret.java
only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_read_sync import DEFERRED as N2353_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
CONTINUOUS_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java'
PROOF = '/root/C07ContinuousTurretGetAmmoFractionProof'
FRACTION_OWNER = 'PortGame.source_continuous_turret_build_get_ammo_fraction_state'
TESTS = ['test_c07_continuous_turret_get_ammo_fraction_registration', 'test_all_c07_continuous_turret_get_ammo_fraction_input_evidence_is_exact', 'test_continuous_turret_get_ammo_fraction_state', 'test_reference_graph_and_actual_c07_continuous_turret_get_ammo_fraction']
# The 1 slice source the N2355 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
]
EXACT_EXPRS = [
    'public class ContinuousTurret extends Turret{',
    'public class ContinuousTurretBuild extends TurretBuild{',
    '@Override',
    'public float getAmmoFraction(){',
    '//TODO unclean way of calculating ammo fraction to display',
    'float ammoFract = efficiency;',
    'if(findConsumer(f -> f instanceof ConsumeLiquidBase) instanceof ConsumeLiquid cons){',
    'ammoFract = Math.min(ammoFract, liquids.get(cons.liquid) / liquidCapacity);',
    'return ammoFract;',
]

# DEFERRED is carried from the N2353 register script via import --
# never retyped. All N2353 entries are carried verbatim (the
# Turret chain, the B/C notes, and N2353's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2355's Windows proof debt.
DEFERRED = list(N2353_DEFERRED) + [
    'ContinuousTurret getAmmoFraction Windows Godot proof -- debt in GOAL.md section 5, same as N2353: the N2355 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=CONTINUOUS_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    fraction_inputs = {
        'efficiency': a('float', 'float ammoFract = efficiency;', 'The block efficiency (ContinuousTurret.java:78, `float ammoFract = efficiency;`): the starting fraction before the liquid cap -- a BuildingComp transient field, taken as an explicit param.'),
        'has_liquid_consumer': a('bool', 'if(findConsumer(f -> f instanceof ConsumeLiquidBase) instanceof ConsumeLiquid cons){', 'Whether the findConsumer lookup found a ConsumeLiquid consumer (ContinuousTurret.java:79): the lookup itself is NOT ported -- its boolean result arrives as an explicit param (the N2330 param precedent).'),
        'liquid_amount': a('float', 'ammoFract = Math.min(ammoFract, liquids.get(cons.liquid) / liquidCapacity);', 'The amount of the consumer liquid currently held, liquids.get(cons.liquid) (ContinuousTurret.java:80): the numerator of the liquid fraction, taken as an explicit param.'),
        'liquid_capacity': a('float', 'ammoFract = Math.min(ammoFract, liquids.get(cons.liquid) / liquidCapacity);', 'The block liquidCapacity field (ContinuousTurret.java:80): the divisor of the liquid fraction, taken as an explicit param -- never zero for a block with a liquid consumer, so no guard is invented.'),
    }
    fraction_outputs = {
        'ammo_fraction': a('float', 'return ammoFract;', 'The ammo fraction (ContinuousTurret.java:83, `return ammoFract;`): efficiency, capped by the liquid fraction when a ConsumeLiquid consumer exists -- ammo as a fraction of capacity, used for direct turret control HUD.'),
    }
    return (fraction_inputs, fraction_outputs)


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
    (fraction_inputs, fraction_outputs) = definitions()

    entries = [
        ('N2355', FRACTION_OWNER, 'source_continuous_turret_build_get_ammo_fraction_state', CONTINUOUS_TURRET, 'mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', 'ContinuousTurretBuild.getAmmoFraction()', fraction_inputs, fraction_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ContinuousTurretBuild.getAmmoFraction() state from ContinuousTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ContinuousTurretBuild.getAmmoFraction() state from ContinuousTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: ammo_fraction.
    by_slice['N2355'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2355', dict(status='done', java_source=CONTINUOUS_TURRET, java_class='mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', java_method='ContinuousTurretBuild.getAmmoFraction()', godot_owner=FRACTION_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2355'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
