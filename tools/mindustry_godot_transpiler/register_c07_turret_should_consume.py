"""Register the TurretBuild.shouldConsume() pure function (N2291).

TurretBuild overrides shouldConsume (Turret.java:364-366,
`public boolean shouldConsume(){` / `return isShooting ||
reloadCounter < reload;`). The base default it overrides is
BuildingComp.shouldConsume (BuildingComp.java:755-757,
`public boolean shouldConsume(){` / `return enabled;`), and
updateConsumption forces efficiency to zero when the gate is
false (BuildingComp.java:1960, `boolean update =
shouldConsume() && productionValid();` + 1993,
`efficiency = optionalEfficiency = 0f;`). The two inputs
are TurretBuild fields: isShooting (Turret.java:292,
`public boolean wasShooting, isShooting;`, set in
updateTile :492) and reloadCounter (ReloadTurret.java:26,
`public float reloadCounter;`, advanced in updateReload,
Turret.java:720-723 and capped at reload, Turret.java:723,
`reloadCounter = Math.min(reloadCounter, reload);`),
against the per-def reload time (ReloadTurret.java:10,
`public float reload = 10f;`). The same comparison is the
canReload gate (ReloadTurret.java:50, `return
reloadCounter < reload;`). This closes the deferred item
recorded in N2148 ('Turret shouldConsume gate
(isShooting / reloadCounter, Turret.java:364-366) -- needs
targeting/reload state the tick does not track yet.').

RED decisions (resolved at RED): (1) One pure function on
SourceTurretBuildState.gd next to the N2148 power-status
row, following the N2188 explicit-param precedent:
(frame, is_shooting, reload_counter, reload). frame is
accepted for the family call shape and reads no live frame
key -- isShooting / reloadCounter / reload arrive as
explicit params, because the tick frame tracks only
cheating / enabled / power_status / efficiency today.
(2) The driver line replaces `should_consume = enabled`
in the power-consumer branch of
source_turret_tick_buildings_state (:221) and reads frame
defaults (is_shooting=false, reload_counter=0.0,
reload=10f -- the Java field defaults: boolean false,
float 0f, ReloadTurret.java:10) until a frame-tracking
slice stamps them; with those defaults 0.0 < 10f, so the
gate preserves the N2148 behaviour (should_consume=true
when enabled). (3) progress() (Turret.java:425-427) and
sense() (Turret.java:406-419) stay DEFERRED -- they are
the assigned N2254 / N2255 slices. The warmup advance
(Turret.java:501-515) stays deferred per N2148. One new
result symbol: should_consume. Slice sources:
Turret.java + ReloadTurret.java + BuildingComp.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_power_status import DEFERRED as N2148_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07TurretShouldConsumeProof'
SHOULD_CONSUME_OWNER = 'SourceTurretBuildState.source_turret_should_consume_state'
TESTS = ['test_c07_turret_should_consume_registration', 'test_all_c07_turret_should_consume_input_evidence_is_exact', 'test_turret_should_consume_state', 'test_reference_graph_and_actual_c07_turret_should_consume']
# The 3 slice sources the N2291 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
]
EXACT_EXPRS = [
    'public boolean shouldConsume(){',
    'return isShooting || reloadCounter < reload;',
    'public boolean wasShooting, isShooting;',
    'public float reloadCounter;',
    'public float reload = 10f;',
    'return reloadCounter < reload;',
    'boolean update = shouldConsume() && productionValid();',
    'efficiency = optionalEfficiency = 0f;',
    'reloadCounter = Math.min(reloadCounter, reload);',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'return enabled;',
]

# DEFERRED is carried from the N2148 register script via import --
# never retyped. The N2148 entry deferring the Turret
# shouldConsume gate to "its own slice" is DROPPED here: N2291
# IS that slice. Everything else is carried verbatim.
DEFERRED = [e for e in N2148_DEFERRED if 'Turret shouldConsume gate' not in e] + [
    'Turret shouldConsume Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2291 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret frame tracking for isShooting / reloadCounter / reload -- TurretBuild.updateTile sets isShooting (Turret.java:492) and updateReload advances reloadCounter (Turret.java:720-723, capped at reload :723); the tick frame tracks only cheating/enabled/power_status/efficiency today, so the driver reads frame defaults (is_shooting=false, reload_counter=0.0, reload=10f) until a frame-tracking slice stamps them.',
    'TurretBuild.progress() (Turret.java:425-427) -- N2254, assigned centrally; depends on the reloadCounter/reload pair this slice wires.',
    'TurretBuild.sense() (Turret.java:406-419) -- N2255, assigned centrally; its progress case depends on N2254.',
    'Turret shouldConsume gate for non-power turrets -- the N2291 driver line lives in the power-consumer branch of the tick driver (N2148); a turret with no power consumer runs no updateConsumption in this driver yet, so the gate does not reach it; waits for its own consumption-wiring slice.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    should_consume_inputs = {
        'frame': a('Dictionary', 'return isShooting || reloadCounter < reload;', 'The turret frame (accepted for the family call shape; this leg reads no live frame key -- isShooting / reloadCounter / reload arrive as explicit params, the N2188 per-def-param precedent, because the tick frame tracks only cheating/enabled/power_status/efficiency).'),
        'is_shooting': a('bool', 'public boolean wasShooting, isShooting;', 'Whether the turret is shooting: the TurretBuild.isShooting field (Turret.java:292), set in updateTile (Turret.java:492); passed explicitly because no frame key stamps it yet.'),
        'reload_counter': a('float', 'public float reloadCounter;', 'The reload progress: the ReloadTurretBuild.reloadCounter field (ReloadTurret.java:26), advanced in updateReload (Turret.java:720-723) and capped at reload (:723); passed explicitly because no frame key stamps it yet.', source=RELOAD_TURRET),
        'reload': a('float', 'public float reload = 10f;', 'The per-def reload time: ReloadTurret.reload (ReloadTurret.java:10); passed explicitly because the frame carries no reload def value yet.', source=RELOAD_TURRET),
    }
    should_consume_outputs = {
        'should_consume': a('bool', 'return isShooting || reloadCounter < reload;', 'Whether the turret should consume: true while shooting or still reloading (Turret.java:365); updateConsumption forces efficiency to zero when false (BuildingComp.java:1960 + 1993).'),
    }
    return should_consume_inputs, should_consume_outputs


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
    should_consume_inputs, should_consume_outputs = definitions()

    entries = [
        ('N2291', SHOULD_CONSUME_OWNER, 'source_turret_should_consume_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.shouldConsume()', should_consume_inputs, should_consume_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.shouldConsume() state from Turret.java + ReloadTurret.java + BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.shouldConsume() state from Turret.java + ReloadTurret.java + BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the single result symbol.
    by_slice['N2291'] = [
        'source_turret_should_consume_state_result.should_consume',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2291', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.shouldConsume()', godot_owner=SHOULD_CONSUME_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2291'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
