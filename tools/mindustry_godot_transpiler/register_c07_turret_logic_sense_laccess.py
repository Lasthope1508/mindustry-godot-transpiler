"""Register the SenseI LAccess numeric dispatch `se.sense(la)` (N2510).

SenseI.run() is `public void run(LExecutor exec){ Object target =
from.obj(); Object sense = type.obj(); if(target == null && sense
== LAccess.dead){ to.setnum(1); return; } if(target instanceof
Senseable se){ if(sense instanceof Content co){
to.setnum(se.sense(co)); }else if(sense instanceof LAccess la){
Object objOut = se.senseObject(la); if(objOut ==
Senseable.noSensed){ to.setnum(se.sense(la)); }else{
to.setobj(objOut); } } }else{ if(sense == LAccess.size || sense ==
LAccess.bufferSize){ ... } to.setobj(null); } }`
(LExecutor.java:681-718). N2507 ported the LAccess branch's
dispatch outcome but took the numeric value as a param
(`sense_value`); this slice ports the resolution of `se.sense(la)`
itself for a duo turret building. `se.sense(la)` calls
Turret.sense (`public double sense(LAccess sensor){`,
Turret.java:405-419: ammo / ammoCapacity / rotation / shootX /
shootY / shooting / progress), whose `default` falls through to
super.sense (`default -> super.sense(sensor);`, :415;
BuildingComp.sense, BuildingComp.java:2093-2126, 23 handled legs),
whose default is NaN (`default -> Float.NaN; //gets converted to
null in logic`, :2123). The only overlap is `rotation`, handled
by both switches over the same live frame value; Java order is
Turret.sense first, so the turret value wins.

GREEN decisions (pinned by this slice): (1) One pure function on
SourceTurretBuildState.gd,
source_logic_sense_laccess_state(sensor, turret_handled,
turret_sense_value, comp_handled, comp_sense_value), returning
`handled` + `sense_value` + `sense_value_is_nan` (the N2283/N2284
sense wire shape), so the caller sees exactly which numeric value
the logic variable receives and whether either sense switch
handled the sensor. It sits immediately AFTER
source_logic_sense_content_state and BEFORE
source_logic_sense_size_state, mirroring exact Java order inside
SenseI.run(): Content (:692-693) -> LAccess (:694) -> else-branch
(:705-717). The two sense outcomes are passed in as params (the
N2212/N2220 per-def-param precedent, same as N2507 passing in
`sense_value`): the function does NOT re-implement the 30 sensor
legs of N2283/N2284. (2) There is NO driver tick line: the leg
is a logic read, not a tick write (the
N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509 precedent);
the proof calls the pure function directly with synthetic inputs,
and wiring the dispatch into a live logic-executor driver is its
own later slice (the logic executor is not in the driver yet).
(3) No legacy `source_logic_sense_laccess_result` schema exists,
so the contract validator falls through to the new
source_logic_sense_laccess_state_result schema and no alias is
needed. (4) Shard routing: the ported method is SenseI.run()
itself, so the java_source is LExecutor.java (NOT Turret.java /
BuildingComp.java -- those are the dispatched methods, already
ported by N2283/N2284), and the slice lives in the canonical
SSOT only (the N2507/N2509 precedent:
`core/src/mindustry/logic/` selects into no shard); comp stays
560/464, defense stays 210/209. SSOT expected after GREEN:
symbols +3, Done +1, contracts +1, schema +2, 11680/1738/1672/3135
-> 11683/1739/1673/3137.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_logic_sense_size import DEFERRED as N2509_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LEXECUTOR = 'core/src/mindustry/logic/LExecutor.java'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07TurretLogicSenseLAccessProof'
LACCESS_OWNER = 'SourceTurretBuildState.source_logic_sense_laccess_state'
TESTS = ['test_c07_turret_logic_sense_laccess_registration', 'test_all_c07_turret_logic_sense_laccess_input_evidence_is_exact', 'test_turret_logic_sense_laccess_state', 'test_reference_graph_and_actual_c07_turret_logic_sense_laccess']
# The slice sources the N2510 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/logic/LExecutor.java',
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
]
EXACT_EXPRS = [
    '}else if(sense instanceof LAccess la){',
    'Object objOut = se.senseObject(la);',
    'if(objOut == Senseable.noSensed){',
    'to.setnum(se.sense(la));',
    'to.setobj(objOut);',
    'public double sense(LAccess sensor){',
    'case ammo -> totalAmmo;',
    'case rotation -> rotation;',
    'case progress -> progress();',
    'default -> super.sense(sensor);',
    'public static class SenseI implements LInstruction{',
    'if(target instanceof Senseable se){',
    'default -> Float.NaN; //gets converted to null in logic',
]

# DEFERRED is carried from the N2509 register script via import --
# never retyped. No entry is dropped: no pool entry states the
# SenseI LAccess numeric dispatch as still-deferred (N2507's DONE
# entry already records the dispatch hook with sense_value passed
# in; this slice provides the function that resolves that value,
# and the hook itself is unchanged). The new entries below are
# appended. Every other entry is carried verbatim (the
# N2211/N2228 lesson -- never retype the pool).
DEFERRED = N2509_DEFERRED + [
    'SenseI.run() LAccess numeric dispatch (`}else if(sense instanceof LAccess la){ Object objOut = se.senseObject(la); if(objOut == Senseable.noSensed){ to.setnum(se.sense(la)); }else{ to.setobj(objOut); }`, LExecutor.java:694-703) -- DONE by this slice (N2510); the pure function resolves `se.sense(la)` for a duo turret from the two already-ported sense outcomes: Turret.sense (Turret.java:405-419: ammo / ammoCapacity / rotation / shootX / shootY / shooting / progress) answers first, its `default` falls through to super.sense (BuildingComp.java:2093-2126, 23 handled legs), and a sensor neither handles reports handled false + NaN (BuildingComp default :2123). The deferred sensor legs inside sense() (dead/health/totalItems/camera*/powerNet*-with-power) still report handled false + NaN through this slice.',
    'Turret logic-sense LAccess Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509: the N2510 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=LEXECUTOR, **extra):
        return backed(typ, source, expr, rule, **extra)

    laccess_inputs = {
        'sensor': a('String', '}else if(sense instanceof LAccess la){', 'The logic sensor to read, spelled by its LAccess enum name (`}else if(sense instanceof LAccess la){`, LExecutor.java:694): it identifies the query whose `se.sense(la)` value is being resolved; the dispatch itself runs on the two handled flags, because the two switches already ran in their own slices (N2283/N2284).'),
        'turret_handled': a('bool', 'public double sense(LAccess sensor){', 'Whether Turret.sense handled the sensor (`public double sense(LAccess sensor){`, Turret.java:406; its switch covers ammo / ammoCapacity / rotation / shootX / shootY / shooting / progress, :408-416): Turret.sense is called first, so a handled sensor never reaches super.sense.', source=TURRET),
        'turret_sense_value': a('Variant', 'case ammo -> totalAmmo;', 'The Turret.sense return value (`case ammo -> totalAmmo;`, Turret.java:408, representative of the seven handled legs), passed explicitly because the pure function does not recompute sensor legs (the N2212/N2220 per-def-param precedent); ignored when turret_handled is false.', source=TURRET),
        'comp_handled': a('bool', 'public double sense(LAccess sensor){', 'Whether BuildingComp.sense handled the sensor (`public double sense(LAccess sensor){`, BuildingComp.java:2093; 23 handled legs, :2094-2122): it is consulted only when Turret.sense missed, via `default -> super.sense(sensor);` (Turret.java:415).', source=BUILDING_COMP),
        'comp_sense_value': a('Variant', 'case size -> block.size;', 'The BuildingComp.sense return value (`case size -> block.size;`, BuildingComp.java:2121, representative of the 23 handled legs), passed explicitly because the pure function does not recompute sensor legs (the N2212/N2220 per-def-param precedent); ignored when comp_handled is false.', source=BUILDING_COMP),
    }
    laccess_outputs = {
        'handled': a('bool', 'to.setnum(se.sense(la));', 'Whether the numeric dispatch resolved to a logic-variable write (`to.setnum(se.sense(la));`, LExecutor.java:699): true when either sense switch handled the sensor, false when neither did (the deferred sensor legs and unknown sensors).'),
        'sense_value': a('Variant', 'to.setnum(se.sense(la));', 'The numeric value written to the logic variable (`to.setnum(se.sense(la));`, LExecutor.java:699): the Turret.sense value when it handled the sensor, else the BuildingComp.sense value, else null.'),
        'sense_value_is_nan': a('bool', 'default -> Float.NaN; //gets converted to null in logic', 'Whether Java returns Float.NaN for this sensor (`default -> Float.NaN; //gets converted to null in logic`, BuildingComp.java:2123); true only when neither sense switch handled the sensor, the N2283/N2284 `sense_value_is_nan` precedent.', source=BUILDING_COMP),
    }
    return laccess_inputs, laccess_outputs


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
    laccess_inputs, laccess_outputs = definitions()

    entries = [
        ('N2510', LACCESS_OWNER, 'source_logic_sense_laccess_state', LEXECUTOR, 'mindustry.logic.LExecutor.SenseI', 'SenseI.run(LExecutor)', laccess_inputs, laccess_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SenseI LAccess numeric dispatch se.sense(la) from LExecutor.java:694-703.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SenseI LAccess numeric dispatch se.sense(la) from LExecutor.java:694-703.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: handled, sense_value, sense_value_is_nan.
    by_slice['N2510'] = [
        'source_logic_sense_laccess_state_result.handled',
        'source_logic_sense_laccess_state_result.sense_value',
        'source_logic_sense_laccess_state_result.sense_value_is_nan',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2510', dict(status='done', java_source=LEXECUTOR, java_class='mindustry.logic.LExecutor.SenseI', java_method='SenseI.run(LExecutor)', godot_owner=LACCESS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2510'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
