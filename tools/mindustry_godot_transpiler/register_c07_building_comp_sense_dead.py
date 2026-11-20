"""Register the BuildingComp.sense() `dead` leg (N2511).

BuildingComp.sense() is `public double sense(LAccess sensor){`
(BuildingComp.java:2093-2126). Its `dead` leg is `case dead ->
!isValid() ? 1 : 0;` (:2098), with `isValid()` `public boolean
isValid(){` / `return tile.build == self() && !dead();`
(:2030-2032). N2284 ported 23 handled legs of sense() and left
dead/health/totalItems/camera*/powerNet* deferred -- dead deferred
because `isValid()` needs tile state not in the frame (note inside
`source_building_comp_sense_state`,
SourceTurretBuildState.gd:313). This slice ports exactly the `dead`
leg, first in Java switch order among the deferred legs.
health / totalItems / camera* / powerNet* stay deferred (separate
later slices, in Java switch order).

GREEN decisions (pinned by this slice): (1) One pure function on
SourceTurretBuildState.gd,
source_building_comp_sense_dead_state(tile_build_is_self, is_dead),
returning `handled` + `sense_value` + `sense_value_is_nan` (the
N2283/N2284 sense wire shape). The two `isValid()` conjuncts are
passed in as params (the N2212/N2220 per-def-param precedent):
`tile_build_is_self` is `tile.build == self()` (:2031, first
conjunct) and `is_dead` is `dead()` (:2031, second conjunct,
negated in `isValid()`). `is_valid = tile_build_is_self and not
is_dead` is the exact `isValid()` body, no guessing;
`sense_value` is 0.0 when valid, 1.0 when not valid
(`!isValid() ? 1 : 0`, :2098). `handled` is true always (this
function IS the dead leg; the sensor is fixed `dead`, so no
`sensor` param) and `sense_value_is_nan` is false always (the leg
never yields NaN; the key stays in the wire shape for consistency
with N2283/N2284). It sits immediately AFTER
source_building_comp_sense_state and BEFORE
source_turret_sense_object_state, mirroring the sense() /
senseObject() order in BuildingComp.java (:2093 / :2128). It does
NOT modify `source_building_comp_sense_state`: dead stays
handled:false in the big dispatch until a later wiring slice
connects this leg (same as N2508's Content leg living beside
N2284). (2) There is NO driver tick line: the leg is a logic
read, not a tick write (the
N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510
precedent); the proof calls the pure function directly with
synthetic inputs, and wiring the leg into a live logic-executor
driver is its own later slice (the logic executor is not in the
driver yet). (3) No legacy
`source_building_comp_sense_dead_result` schema exists, so the
contract validator falls through to the new
source_building_comp_sense_dead_state_result schema and no alias
is needed. (4) Shard routing: the ported method is
BuildingComp.sense, so the java_source is BuildingComp.java
(NOT LExecutor.java -- the N2510 precedent is the reverse: there
the dispatched method WAS SenseI.run itself), and the slice
mirrors into the comp shard: comp 560/464 -> 561/465; defense
stays 210/209. SSOT expected after GREEN: symbols +3, Done +1,
contracts +1, schema +2, 11683/1739/1673/3137 ->
11686/1740/1674/3139.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_logic_sense_laccess import DEFERRED as N2510_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
PROOF = '/root/C07BuildingCompSenseDeadProof'
DEAD_OWNER = 'SourceTurretBuildState.source_building_comp_sense_dead_state'
TESTS = ['test_c07_building_comp_sense_dead_registration', 'test_all_c07_building_comp_sense_dead_input_evidence_is_exact', 'test_building_comp_sense_dead_state', 'test_reference_graph_and_actual_c07_building_comp_sense_dead']
# The slice sources the N2511 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/logic/LAccess.java',
]
EXACT_EXPRS = [
    'case dead -> !isValid() ? 1 : 0;',
    'return tile.build == self() && !dead();',
    'public boolean isValid(){',
    'public double sense(LAccess sensor){',
    'default -> Float.NaN; //gets converted to null in logic',
    'dead,',
]

# DEFERRED is carried from the N2510 register script via import --
# never retyped. The dead-leg entry ("BuildingComp sense() dead leg
# ... -- NOT this slice ...") is DROPPED here -- the dead leg is
# done at N2511 -- and replaced by the new entries below. Every
# other entry is carried verbatim (the N2211/N2228 lesson -- never
# retype the pool).
DEFERRED = [e for e in N2510_DEFERRED if 'sense() dead leg' not in e] + [
    'BuildingComp sense() dead leg (`case dead -> !isValid() ? 1 : 0;`, BuildingComp.java:2098) -- DONE by this slice (N2511); the pure function ports `isValid()` exactly (`return tile.build == self() && !dead();`, :2031) from the two passed-in conjuncts and returns 1.0 when not valid, 0.0 when valid, with handled true and sense_value_is_nan false always. dead stays handled:false in `source_building_comp_sense_state` until a later wiring slice connects this leg. health / totalItems / camera* / powerNet* stay deferred (separate later slices, in Java switch order).',
    'BuildingComp sense() dead Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510: the N2511 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BUILDING_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    dead_inputs = {
        'tile_build_is_self': a('bool', 'return tile.build == self() && !dead();', 'Whether `tile.build == self()` (`return tile.build == self() && !dead();`, BuildingComp.java:2031, first conjunct of `isValid()`): the tile still holds this building; passed explicitly because the tile state is not stamped in the frame yet (the N2212/N2220 per-def-param precedent).'),
        'is_dead': a('bool', 'return tile.build == self() && !dead();', 'Whether `dead()` (`return tile.build == self() && !dead();`, BuildingComp.java:2031, second conjunct, negated in `isValid()`): the building is destroyed; passed explicitly because the tile state is not stamped in the frame yet (the N2212/N2220 per-def-param precedent).'),
    }
    dead_outputs = {
        'handled': a('bool', 'case dead -> !isValid() ? 1 : 0;', 'Whether the leg resolved to a logic-variable write (`case dead -> !isValid() ? 1 : 0;`, BuildingComp.java:2098): true always, because this function IS the dead leg and the sensor is fixed `dead`.'),
        'sense_value': a('Variant', 'case dead -> !isValid() ? 1 : 0;', 'The numeric value written to the logic variable (`case dead -> !isValid() ? 1 : 0;`, BuildingComp.java:2098): 0.0 when `isValid()` holds, 1.0 when it does not.'),
        'sense_value_is_nan': a('bool', 'default -> Float.NaN; //gets converted to null in logic', 'Whether Java returns Float.NaN for this sensor (`default -> Float.NaN; //gets converted to null in logic`, BuildingComp.java:2123); false always for the dead leg, which never yields NaN -- the key stays in the wire shape for consistency with N2283/N2284.'),
    }
    return dead_inputs, dead_outputs


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
    dead_inputs, dead_outputs = definitions()

    entries = [
        ('N2511', DEAD_OWNER, 'source_building_comp_sense_dead_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp.BuildingComp', 'BuildingComp.sense(LAccess)', dead_inputs, dead_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BuildingComp.sense() dead leg from BuildingComp.java:2098 + isValid() :2030-2032.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BuildingComp.sense() dead leg from BuildingComp.java:2098 + isValid() :2030-2032.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: handled, sense_value, sense_value_is_nan.
    by_slice['N2511'] = [
        'source_building_comp_sense_dead_state_result.handled',
        'source_building_comp_sense_dead_state_result.sense_value',
        'source_building_comp_sense_dead_state_result.sense_value_is_nan',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2511', dict(status='done', java_source=BUILDING_COMP, java_class='mindustry.entities.comp.BuildingComp.BuildingComp', java_method='BuildingComp.sense(LAccess)', godot_owner=DEAD_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2511'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
