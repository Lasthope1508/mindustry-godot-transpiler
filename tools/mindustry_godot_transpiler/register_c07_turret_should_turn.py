"""Register the Turret shouldTurn() predicate (N2337).

TurretBuild.shouldTurn() (Turret.java:669-671) is the one-line
turn gate:
`public boolean shouldTurn(){`
`return moveWhileCharging || !charging();`
on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
(Turret.java:277). Its caller is updateTile() :595
(`if(shouldTurn()){` / `turnToTarget(targetRot);`), which is
its own slice -- this slice is the pure predicate only.

RED decisions (resolved at RED): (1) One pure function,
source_turret_should_turn_state(frame, move_while_charging,
charging), returning should_turn. moveWhileCharging is the
Turret def field (`public boolean moveWhileCharging = true;`,
Turret.java:80) and arrives as an explicit bool param (the
N2311/N2261 precedent -- a def field, not build state).
charging() is NOT re-ported: it is the TurretBuild method
(Turret.java:715-717, `public boolean charging(){` /
`return queuedBullets > 0 && shoot.firstShotDelay > 0;`)
whose result the caller passes as the explicit bool
charging param (the N2311/N2340 precedent -- the caller
passes the live value); remote N2269 owns charging() (dedup
at merge). (2) The frame carries no tracked key for this
predicate (the minRange :593 precedent -- the tick frame
tracks no charging state yet), so all live values arrive as
explicit params. (3) NO driver tick line: shouldTurn() is a
predicate the updateTile() tick driver reads, not a tick
write of its own -- wiring it into the driver waits for the
updateTile() caller slice. One new result symbol:
should_turn. Slice source: Turret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_draw_select import DEFERRED as N2334_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretShouldTurnProof'
OWNER = 'SourceTurretBuildState.source_turret_should_turn_state'
TESTS = ['test_c07_turret_should_turn_registration', 'test_all_c07_turret_should_turn_input_evidence_is_exact', 'test_turret_should_turn_state', 'test_reference_graph_and_actual_c07_turret_should_turn']
# The 1 slice source the N2337 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    'public class Turret extends ReloadTurret{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public boolean shouldTurn(){',
    'return moveWhileCharging || !charging();',
    'public boolean moveWhileCharging = true;',
    'public boolean charging(){',
    'return queuedBullets > 0 && shoot.firstShotDelay > 0;',
    'if(shouldTurn()){',
]

# DEFERRED is carried from the N2334 register script via import --
# never retyped. The N2334 chain (54 entries) is a superset of the
# N2340 chain (41 entries, verified by set-union at RED: union
# len 54), so nothing is lost by chaining from N2334. One entry
# is added: the N2337 Windows Godot proof debt (GOAL.md
# section 5).
DEFERRED = N2334_DEFERRED + [
    'Turret shouldTurn() Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2337 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    inputs = {
        'frame': a('Dictionary', 'public boolean shouldTurn(){', 'The turret frame (TurretBuild.shouldTurn, Turret.java:669): the family-convention first arg every Turret pure function takes; it carries no tracked key for this predicate -- the tick frame tracks no charging state yet, so all live values arrive as explicit params (the minRange :593 precedent).'),
        'move_while_charging': a('bool', 'public boolean moveWhileCharging = true;', 'Whether the turret turns while charging (`moveWhileCharging`, Turret.java:670): the Turret def field (`public boolean moveWhileCharging = true;`, Turret.java:80); a def field, not build state, so it arrives as an explicit param (the N2311/N2261 precedent).'),
        'charging': a('bool', 'public boolean charging(){', 'Whether the turret is charging a shot (`charging()`, Turret.java:670): the TurretBuild method (`public boolean charging(){`, Turret.java:715, `return queuedBullets > 0 && shoot.firstShotDelay > 0;`, Turret.java:716) -- computed by the caller and passed in as an explicit bool, NOT re-ported here (the N2311/N2340 precedent); remote N2269 owns charging() (dedup at merge).'),
    }
    outputs = {
        'should_turn': a('bool', 'return moveWhileCharging || !charging();', 'Whether the turret turns toward its target (Turret.java:670, `return moveWhileCharging || !charging();`): true when the def allows turning while charging, or when not charging; false only while charging with moveWhileCharging false. Read by updateTile() :595 (`if(shouldTurn()){`) before turnToTarget(targetRot).'),
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
        ('N2337', OWNER, 'source_turret_should_turn_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.shouldTurn()', inputs, outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.shouldTurn() state from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.shouldTurn() state from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: should_turn.
    by_slice['N2337'] = [
        'source_turret_should_turn_state_result.should_turn',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2337', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.shouldTurn()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2337'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
