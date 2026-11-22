"""Register the ContinuousTurret(String name) ctor field defaults (N2407).

ContinuousTurret(String name) (ContinuousTurret.java:20-25, `public
ContinuousTurret(String name){`) assigns 2 literal field defaults
on the ContinuousTurret def: `coolantMultiplier = 1f;` (:23) and
`displayAmmoMultiplier = false;` (:25). The other ctor lines are
NOT in this slice and are never re-registered: `super(name);`
and `envEnabled |= Env.space;` are already exact_exprs of N2185
(both 0-hit re-probed at HEAD 042ac898, local + remote ledgers).
One GD function on the NEW SourceContinuousTurretDefaults.gd (the
ContinuousTurret def-defaults file, NOT
SourceContinuousTurretBuildPortBridge.gd, which is the
ContinuousTurretBuild file) -- the Turret ctor batch 25 precedent
(owner `source_turret_default_constructor_state` on
SourceTurretDefaults.gd) and the BaseTurret ctor batch 26 precedent
(owner `source_base_turret_default_constructor_state` on
SourceBaseTurretDefaults.gd). `coolantMultiplier` is declared on
BaseTurret (BaseTurret.java:32, `public float coolantMultiplier =
5f;`), so the ctor overrides the 5f base default with 1f; the
same literal also appears in the LaserTurret() and
TractorBeamTurret() ctors -- this slice owns only the
ContinuousTurret() leg, recorded via java_method
`ContinuousTurret(String name)`. `displayAmmoMultiplier` is
declared on Turret (Turret.java:99, `public boolean
displayAmmoMultiplier = true;`), so the ctor overrides the true
base default with false. The defaults are frame data only (one
float literal + one bool literal); no Draw is ported, and the
proof asserts frame defaults, never a real render. Three new
result symbols: one per default plus the updated def frame. Three
slice sources: ContinuousTurret.java + BaseTurret.java + Turret.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_default_constructor import DEFERRED as N2400_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
CONTINUOUS_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07ContinuousTurretDefaultConstructorProof'
CTOR_OWNER = 'SourceContinuousTurretDefaults.source_continuous_turret_default_constructor_state'
TESTS = ['test_c07_continuous_turret_default_constructor_registration', 'test_all_c07_continuous_turret_default_constructor_input_evidence_is_exact', 'test_continuous_turret_default_constructor_state', 'test_reference_graph_and_actual_c07_continuous_turret_default_constructor']
# The 3 slice sources the N2407 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    'coolantMultiplier = 1f;',
    'displayAmmoMultiplier = false;',
]

# DEFERRED is carried from the N2400 register script via import --
# never retyped. Nothing in it closes here: N2407 ports the
# ContinuousTurret() ctor field defaults, which no N2400 entry lists.
# One entry is added: the N2407 Windows Godot proof debt
# (GOAL.md section 5).
DEFERRED = list(N2400_DEFERRED) + [
    'ContinuousTurret() ctor field defaults N2407 Windows Godot proof -- debt in GOAL.md section 5, same as N2400: the N2407 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=CONTINUOUS_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    ctor_inputs = {
        'continuous_turret_defaults': a('Dictionary', 'public ContinuousTurret(String name){', 'The ContinuousTurret def frame (ContinuousTurret.java:20, `public ContinuousTurret(String name){`): the family-convention first arg; the ctor writes its 2 literal field defaults into it, so continuous_turret_defaults is an in/out param -- keys already present keep their unrelated values, the 2 ctor keys are overwritten with the ctor literals.'),
    }
    ctor_outputs = {
        'coolant_multiplier': a('float', 'coolantMultiplier = 1f;', 'The coolant multiplier of this turret (ContinuousTurret.java:23, `coolantMultiplier = 1f;`): BaseTurret.coolantMultiplier; the ctor overrides the BaseTurret base default (`public float coolantMultiplier = 5f;`, BaseTurret.java:32) with 1f -- continuous turrets need no coolant boost. The same literal also appears in the LaserTurret() and TractorBeamTurret() ctors; this slice owns only the ContinuousTurret() leg (java_method `ContinuousTurret(String name)`).'),
        'display_ammo_multiplier': a('bool', 'displayAmmoMultiplier = false;', 'Whether this turret displays ammo multipliers in its stats (ContinuousTurret.java:25, `displayAmmoMultiplier = false;`): Turret.displayAmmoMultiplier; the ctor overrides the Turret base default (`public boolean displayAmmoMultiplier = true;`, Turret.java:99) with false -- continuous turrets show no ammo-multiplier stat.'),
        'continuous_turret_defaults': a('Dictionary', 'public ContinuousTurret(String name){', 'The updated ContinuousTurret def frame (ContinuousTurret.java:20, `public ContinuousTurret(String name){`): the same in/out Dictionary -- unrelated keys preserved, the 2 ctor keys written with the ctor literals.'),
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
        ('N2407', CTOR_OWNER, 'source_continuous_turret_default_constructor_state', CONTINUOUS_TURRET, 'mindustry.world.blocks.defense.turrets.ContinuousTurret', 'ContinuousTurret(String name)', ctor_inputs, ctor_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ContinuousTurret() ctor field defaults state from ContinuousTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ContinuousTurret() ctor field defaults state from ContinuousTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the 2 defaults in ctor
    # order, then the updated def frame.
    by_slice['N2407'] = [
        'source_continuous_turret_default_constructor_state_result.coolant_multiplier',
        'source_continuous_turret_default_constructor_state_result.display_ammo_multiplier',
        'source_continuous_turret_default_constructor_state_result.continuous_turret_defaults',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2407', dict(status='done', java_source=CONTINUOUS_TURRET, java_class='mindustry.world.blocks.defense.turrets.ContinuousTurret', java_method='ContinuousTurret(String name)', godot_owner=CTOR_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2407'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
