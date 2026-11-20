"""Register the Turret logic-processor sense dispatch hook (N2507).

SenseI.run() is `public void run(LExecutor exec){ Object target =
from.obj(); Object sense = type.obj(); if(target == null && sense
== LAccess.dead){ to.setnum(1); return; } if(target instanceof
Senseable se){ if(sense instanceof Content co){
to.setnum(se.sense(co)); }else if(sense instanceof LAccess la){
Object objOut = se.senseObject(la); if(objOut ==
Senseable.noSensed){ to.setnum(se.sense(la)); }else{
to.setobj(objOut); } } } else{ if(sense == LAccess.size ||
sense == LAccess.bufferSize){ ... } to.setobj(null); } }`
(LExecutor.java:681-718). This slice ports the dispatch for a duo
Senseable target + an LAccess sensor: the null-target dead leg writes
num 1 (checked first, before senseObject); the senseObject-handled
leg writes the object with to.setobj -- including a null object for
the config / payloadType legs, which is NOT the sentinel and so never
falls back to numeric sense; the noSensed leg writes the numeric
sense(la) value from the N2283/N2284 chain, passed in as the
sense_value param. The Content leg and the non-Senseable
size/bufferSize legs are deferred (see the scope file
docs/superpowers/handoffs/hidden_files/n2507-scope.md).

GREEN decisions (pinned by this slice): (1) One pure function on
SourceTurretBuildState.gd,
source_logic_sense_dispatch_state(sensor, target_is_null,
sense_object_handled, sense_object, sense_value), returning
`handled` + `output_kind` ("num" / "obj") + `output_value` +
`is_no_sensed`, so the caller sees exactly which write the logic
variable receives. It sits immediately AFTER
source_turret_sense_object_state (the hook consumes its output) and
BEFORE source_turret_progress_state. (2) There is NO driver tick
line: the dispatch is a logic read, not a tick write (the
N2206/N2208/N2223/N2283/N2284/N2506 precedent); the proof calls the
pure function directly with synthetic inputs, and wiring the hook
into a live logic-executor driver is its own later slice (the logic
executor is not in the driver yet). (3) No legacy
`source_logic_sense_dispatch_result` schema exists, so the contract
validator falls through to the new
source_logic_sense_dispatch_state_result schema and no alias is
needed. (4) Shard routing: this is the FIRST slice whose java_source
is under core/src/mindustry/logic/ -- no /logic/ shard exists, so it
lives in the canonical SSOT only and NO shard count changes (comp
stays 559/463, defense stays 210/209). Registering it with a
BuildingComp.java java_source just to land in the comp shard would be
dishonest; creating a /logic/ shard is separate infra work, NOT this
slice. SSOT expected after GREEN: symbols +4, Done +1, contracts +1,
schema +2, 11668/1735/1669/3129 -> 11672/1736/1670/3131.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_sense_object import DEFERRED as N2506_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LEXECUTOR = 'core/src/mindustry/logic/LExecutor.java'
SENSEABLE = 'core/src/mindustry/logic/Senseable.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
PROOF = '/root/C07TurretLogicSenseDispatchProof'
DISPATCH_OWNER = 'SourceTurretBuildState.source_logic_sense_dispatch_state'
TESTS = ['test_c07_turret_logic_sense_dispatch_registration', 'test_all_c07_turret_logic_sense_dispatch_input_evidence_is_exact', 'test_turret_logic_sense_dispatch_state', 'test_reference_graph_and_actual_c07_turret_logic_sense_dispatch']
# The slice sources the N2507 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/logic/LExecutor.java',
    'core/src/mindustry/logic/Senseable.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/logic/LAccess.java',
]
EXACT_EXPRS = [
    'public static class SenseI implements LInstruction{',
    'if(target == null && sense == LAccess.dead){',
    'to.setnum(1);',
    'if(target instanceof Senseable se){',
    'if(sense instanceof Content co){',
    'to.setnum(se.sense(co));',
    '}else if(sense instanceof LAccess la){',
    'Object objOut = se.senseObject(la);',
    'if(objOut == Senseable.noSensed){',
    'to.setnum(se.sense(la));',
    'to.setobj(objOut);',
    'if(sense == LAccess.size || sense == LAccess.bufferSize){',
    'to.setobj(null);',
    'Object noSensed = new Object();',
    'default Object senseObject(LAccess sensor){',
    'return noSensed;',
    'public Object senseObject(LAccess sensor){',
    'public double sense(LAccess sensor){',
    'case ammo -> totalAmmo;',
    '    dead,',
]

# DEFERRED is carried from the N2506 register script via import --
# never retyped. The dispatch-hook entry ("Turret sense() logic-
# processor dispatch hook (LExecutor sense -> turret sense) -- NOT
# this slice ...") is DROPPED here -- the hook is done at N2507 --
# and replaced by the new entries below. Every other entry is
# carried verbatim (the N2211/N2228 lesson -- never retype the pool).
DEFERRED = [e for e in N2506_DEFERRED if 'logic-processor dispatch hook' not in e] + [
    'Turret sense() logic-processor dispatch hook (LExecutor SenseI.run -> turret sense -> super.sense -> senseObject fallback) -- DONE by this slice (N2507); the pure function ports the null-target dead leg (num 1, checked first), the senseObject-handled leg (obj output, including null objects for config / payloadType, which never fall back to numeric sense), and the noSensed fallback leg (num sense(la) from the N2283/N2284 chain, passed in as sense_value). The Content leg and the non-Senseable size/bufferSize legs are still deferred (see below).',
    'Turret logic-sense dispatch Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506: the N2507 proof runs headless on Linux here and waits for a Windows Godot run.',
    'SenseI.run() Content leg (`if(sense instanceof Content co){ to.setnum(se.sense(co)); }`, LExecutor.java:692-693) -- NOT this slice; it needs `BuildingComp.sense(Content)` (BuildingComp.java:2139-2147: items.get / liquids.get / payloads.get / NaN), i.e. live items/liquids/payloads counts, which are not in the frame (same reason N2284 deferred totalItems).',
    'SenseI.run() non-Senseable legs (`if(sense == LAccess.size || sense == LAccess.bufferSize){ ... } to.setobj(null);`, LExecutor.java:704-717) -- NOT this slice; the target is not a building at all (a string / sequence logic var), not a turret concern.',
]


def definitions():
    def a(typ, expr, rule, source=LEXECUTOR, **extra):
        return backed(typ, source, expr, rule, **extra)

    dispatch_inputs = {
        'sensor': a('String', '}else if(sense instanceof LAccess la){', 'The logic sensor to read, spelled by its LAccess enum name (`}else if(sense instanceof LAccess la){`, LExecutor.java:694; `    dead,` LAccess.java:47, `firstItem,` :8, `type,` :63, `payloadType,` :69, `config(true, "to"),` :83): the dispatch only models LAccess sensors -- the Content leg is its own later slice.'),
        'target_is_null': a('bool', 'if(target == null && sense == LAccess.dead){', 'Whether the sensed target is null (`Object target = from.obj();`, LExecutor.java:682; `if(target == null && sense == LAccess.dead){`, :685): only a null target takes the dead leg, and it is checked before senseObject.'),
        'sense_object_handled': a('bool', 'if(objOut == Senseable.noSensed){', 'Whether senseObject() returned a real object instead of the sentinel (`Object objOut = se.senseObject(la);` / `if(objOut == Senseable.noSensed){`, LExecutor.java:695-697; `Object noSensed = new Object();`, Senseable.java:6): the N2506 pure function reports this as handled, and a null object still counts as handled.'),
        'sense_object': a('Variant', 'Object objOut = se.senseObject(la);', 'The senseObject() output (`Object objOut = se.senseObject(la);`, LExecutor.java:695) from the N2506 pure function -- the block id for "type", the observed first item id or null for "firstItem", null for "config" / "payloadType"; passed explicitly because the hook does not recompute sensor legs (the N2212/N2220 per-def-param precedent).'),
        'sense_value': a('float', 'to.setnum(se.sense(la));', 'The numeric sense(la) fallback value (`to.setnum(se.sense(la));`, LExecutor.java:699) from the N2283/N2284 chain (`public double sense(LAccess sensor){`, Turret.java:405 / BuildingComp.java:2093); passed explicitly because the hook does not recompute sensor legs (the N2212/N2220 per-def-param precedent).'),
    }
    dispatch_outputs = {
        'handled': a('bool', 'public static class SenseI implements LInstruction{', 'Whether the dispatch resolved to a logic-variable write (`public static class SenseI implements LInstruction{`, LExecutor.java:668; every modeled leg writes with to.setnum or to.setobj, so handled is true throughout this slice).'),
        'output_kind': a('String', 'to.setobj(objOut);', 'Which write the dispatch performs: "num" when it calls to.setnum (`to.setnum(1);` / `to.setnum(se.sense(la));`, LExecutor.java:686/699) and "obj" when it calls to.setobj (`to.setobj(objOut);`, :702); the logic variable holds either a number or an object, never both.'),
        'output_value': a('Variant', 'Object objOut = se.senseObject(la);', 'The value written to the logic variable: 1.0 for the null-target dead leg (`to.setnum(1);`, LExecutor.java:686), the senseObject output for the object leg (`to.setobj(objOut);`, :702 -- possibly null for config / payloadType), the numeric sense value for the fallback leg (`to.setnum(se.sense(la));`, :699).'),
        'is_no_sensed': a('bool', 'if(objOut == Senseable.noSensed){', 'Whether senseObject() fell through to the noSensed sentinel (`if(objOut == Senseable.noSensed){`, LExecutor.java:697 -- `Object noSensed = new Object();`, Senseable.java:6); true only on the numeric fallback leg, the N2506 `is_no_sensed` precedent.'),
    }
    return dispatch_inputs, dispatch_outputs


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
    dispatch_inputs, dispatch_outputs = definitions()

    entries = [
        ('N2507', DISPATCH_OWNER, 'source_logic_sense_dispatch_state', LEXECUTOR, 'mindustry.logic.LExecutor.SenseI', 'SenseI.run(LExecutor)', dispatch_inputs, dispatch_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret logic-processor sense dispatch hook from LExecutor.java:681-718 + Senseable.java + BuildingComp.java + Turret.java + LAccess.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret logic-processor sense dispatch hook from LExecutor.java:681-718 + Senseable.java + BuildingComp.java + Turret.java + LAccess.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: handled, output_kind, output_value, is_no_sensed.
    by_slice['N2507'] = [
        'source_logic_sense_dispatch_state_result.handled',
        'source_logic_sense_dispatch_state_result.output_kind',
        'source_logic_sense_dispatch_state_result.output_value',
        'source_logic_sense_dispatch_state_result.is_no_sensed',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2507', dict(status='done', java_source=LEXECUTOR, java_class='mindustry.logic.LExecutor.SenseI', java_method='SenseI.run(LExecutor)', godot_owner=DISPATCH_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2507'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
