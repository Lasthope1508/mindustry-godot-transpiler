"""Register the Turret isShooting() accessor (N2343).

TurretBuild.isShooting() (Turret.java:429-432) is the
one-line shooting-state accessor:
`public boolean isShooting(){`
`return isShooting;`
`}`
on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
(Turret.java:277). The field is the TurretBuild field
(`public boolean wasShooting, isShooting;`,
Turret.java:292).

RED decisions (resolved at RED): (1) One pure function --
the field arrives as the explicit bool is_shooting (the
shouldConsume :364 / sense :413 / warmup :502 precedent --
the field name collides with the method name, so the GD
param is is_shooting, never isShooting). The frame carries
no tracked key for this accessor (the minRange :593
precedent -- the tick frame tracks no shooting state yet).
(2) The field is written by updateTile :492
(`isShooting = alwaysShooting || (unit.controller()
instanceof Player ? unit.isShooting() :
logicControlled() ? logicShooting : target != null);`) --
NOT ported here: this slice only reads the field. (3) NO
driver tick line: isShooting() is a read accessor its
callers read, not a per-tick write (the N2249 precedent) --
no `.isShooting()` call site exists in core/src; the FIELD
is read directly at shouldConsume :365 (`return isShooting
|| reloadCounter < reload;`), sense :413 (`case shooting ->
isShooting ? 1 : 0;`) and the warmup leg :502 (`float
warmupTarget = (isShooting && canConsume()) || charging()
? 1f : 0f;`). (4) estimateDps() (Turret.java:329-332,
N2301) does NOT call isShooting() -- it reads hasAmmo()
and peekAmmo() -- and status() (Turret.java:369-374,
N2285) reads hasAmmo(), not isShooting(); neither caller
is ported here. One new result symbol: is_shooting. One
slice source: Turret.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_should_turn import DEFERRED as N2337_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretIsShootingProof'
OWNER = 'SourceTurretBuildState.source_turret_is_shooting_state'
TESTS = ['test_c07_turret_is_shooting_registration', 'test_all_c07_turret_is_shooting_input_evidence_is_exact', 'test_turret_is_shooting_state', 'test_reference_graph_and_actual_c07_turret_is_shooting']
# The 1 slice source the N2343 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    'public class Turret extends ReloadTurret{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public boolean isShooting(){',
    'return isShooting;',
    'public boolean wasShooting, isShooting;',
]

# DEFERRED is carried from the N2337 register script via import --
# never retyped. Nothing in it closes here: isShooting() was never
# a deferred entry of the Turret chain. One entry is added: the
# N2343 Windows Godot proof debt (GOAL.md section 5).
DEFERRED = N2337_DEFERRED + [
    'Turret isShooting() Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2343 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    inputs = {
        'frame': a('Dictionary', 'public boolean isShooting(){', 'The turret frame (TurretBuild.isShooting, Turret.java:429): the family-convention first arg every Turret pure function takes; it carries no tracked key for this accessor -- the tick frame tracks no shooting state yet, so the live value arrives as an explicit param (the N2188 precedent).'),
        'is_shooting': a('bool', 'public boolean wasShooting, isShooting;', 'Whether the turret is shooting (`isShooting`, Turret.java:429-432): the TurretBuild field (`public boolean wasShooting, isShooting;`, Turret.java:292); the GD param is is_shooting because the field name collides with the method name (the shouldConsume / sense / warmup precedent). Written by updateTile :492, not ported here.'),
    }
    outputs = {
        'is_shooting': a('bool', 'return isShooting;', 'Whether the turret is shooting (Turret.java:430, `return isShooting;`): the field echoed unchanged.'),
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
        ('N2343', OWNER, 'source_turret_is_shooting_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.isShooting()', inputs, outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.isShooting() state from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.isShooting() state from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: is_shooting.
    by_slice['N2343'] = [
        'source_turret_is_shooting_state_result.is_shooting',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2343', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.isShooting()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2343'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
