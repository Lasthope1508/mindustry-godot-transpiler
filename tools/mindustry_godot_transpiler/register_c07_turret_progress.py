"""Register the TurretBuild.progress() pure function (N2292).

TurretBuild overrides progress (Turret.java:425-427,
`public float progress(){` / `return Mathf.clamp(
reloadCounter / reload);`). The base default it overrides
is BuildingComp.progress (BuildingComp.java:617-619,
`public float progress(){` / `return 0f;`). The two inputs
are the same reload pair N2291 wires for shouldConsume:
reloadCounter (ReloadTurret.java:26, `public float
reloadCounter;`, advanced in updateReload, Turret.java:720-723
and capped at reload, Turret.java:723, `reloadCounter =
Math.min(reloadCounter, reload);`), against the per-def
reload time (ReloadTurret.java:10, `public float reload =
10f;`). arc Mathf.clamp with one argument clamps to [0, 1]
(the MendProjector precedent, SourceMendProjectorState.gd:41,
`clamp(charge / reload_value, 0.0, 1.0)`). The only live
consumer is sense() case progress (Turret.java:414, `case
progress -> progress();`) -- the assigned N2293 slice;
setBars (Turret.java:192-202) never reads progress(). This
closes the deferred item recorded in N2291
('TurretBuild.progress() (Turret.java:425-427) -- N2292,
assigned centrally; depends on the reloadCounter/reload
pair this slice wires.').

RED decisions (resolved at RED): (1) One pure function on
SourceTurretBuildState.gd next to the N2291 shouldConsume
row, following the N2188 explicit-param precedent:
(frame, reload_counter, reload). frame is accepted for the
family call shape and reads no live frame key --
reloadCounter / reload arrive as explicit params, because
the tick frame tracks only cheating / enabled /
power_status / efficiency today. (2) NO driver line: the
tick frame tracks neither reloadCounter nor reload yet,
and wiring frame defaults would stamp a constant 0.0
progress -- pure function only, the N2251 / N2252
precedent; sense() (N2293) calls it with explicit params.
(3) sense() (Turret.java:406-419) stays DEFERRED -- it is
the assigned N2293 slice. The warmup advance
(Turret.java:501-515) stays deferred per N2148. One new
result symbol: progress. Slice sources: Turret.java +
ReloadTurret.java + BuildingComp.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_should_consume import DEFERRED as N2235_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07TurretProgressProof'
PROGRESS_OWNER = 'SourceTurretBuildState.source_turret_progress_state'
TESTS = ['test_c07_turret_progress_registration', 'test_all_c07_turret_progress_input_evidence_is_exact', 'test_turret_progress_state', 'test_reference_graph_and_actual_c07_turret_progress']
# The 3 slice sources the N2292 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
]
EXACT_EXPRS = [
    'public float progress(){',
    'return Mathf.clamp(reloadCounter / reload);',
    'public float reloadCounter;',
    'public float reload = 10f;',
    'reloadCounter = Math.min(reloadCounter, reload);',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'return 0f;',
    'case progress -> progress();',
]

# DEFERRED is carried from the N2291 register script via import --
# never retyped. The N2291 entry deferring TurretBuild.progress()
# to N2292 is DROPPED here: N2292 IS that slice. Everything
# else is carried verbatim.
DEFERRED = [e for e in N2235_DEFERRED if 'TurretBuild.progress() (Turret.java:425-427)' not in e] + [
    'Turret progress Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2292 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret frame tracking for reloadCounter / reload -- TurretBuild.updateTile advances reloadCounter in updateReload (Turret.java:720-723, capped at reload :723); the tick frame tracks only cheating/enabled/power_status/efficiency today, so progress() takes explicit params until a frame-tracking slice stamps them; sense() (N2293) calls this pure function with explicit params.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    progress_inputs = {
        'frame': a('Dictionary', 'return Mathf.clamp(reloadCounter / reload);', 'The turret frame (accepted for the family call shape; this leg reads no live frame key -- reloadCounter / reload arrive as explicit params, the N2188 per-def-param precedent, because the tick frame tracks only cheating/enabled/power_status/efficiency).'),
        'reload_counter': a('float', 'public float reloadCounter;', 'The reload progress: the ReloadTurretBuild.reloadCounter field (ReloadTurret.java:26), advanced in updateReload (Turret.java:720-723) and capped at reload (:723); passed explicitly because no frame key stamps it yet.', source=RELOAD_TURRET),
        'reload': a('float', 'public float reload = 10f;', 'The per-def reload time: ReloadTurret.reload (ReloadTurret.java:10); passed explicitly because the frame carries no reload def value yet.', source=RELOAD_TURRET),
    }
    progress_outputs = {
        'progress': a('float', 'return Mathf.clamp(reloadCounter / reload);', 'The reload progress clamped to [0, 1]: 0 while unreloaded, 1 once the reload counter reaches reload (Turret.java:426); read by sense() case progress (Turret.java:414).'),
    }
    return progress_inputs, progress_outputs


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
    progress_inputs, progress_outputs = definitions()

    entries = [
        ('N2292', PROGRESS_OWNER, 'source_turret_progress_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.progress()', progress_inputs, progress_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.progress() state from Turret.java + ReloadTurret.java + BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.progress() state from Turret.java + ReloadTurret.java + BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the single result symbol.
    by_slice['N2292'] = [
        'source_turret_progress_state_result.progress',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2292', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.progress()', godot_owner=PROGRESS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2292'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
