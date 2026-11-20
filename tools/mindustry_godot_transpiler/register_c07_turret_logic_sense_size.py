"""Register the SenseI non-Senseable size/bufferSize legs (N2509).

SenseI.run() is `public void run(LExecutor exec){ Object target =
from.obj(); Object sense = type.obj(); if(target == null && sense
== LAccess.dead){ to.setnum(1); return; } if(target instanceof
Senseable se){ if(sense instanceof Content co){
to.setnum(se.sense(co)); }else if(sense instanceof LAccess la){
... } }else{ if(sense == LAccess.size || sense ==
LAccess.bufferSize){ if(target instanceof CharSequence seq){
to.setnum(seq.length()); return; }else if(target instanceof Seq<?>
seq){ to.setnum(seq.size); return; } } to.setobj(null); } }`
(LExecutor.java:681-718). The else-branch (:705-717) runs when the
target is NOT a Senseable at all: a size / bufferSize sensor on a
CharSequence logic var writes seq.length() with to.setnum and
returns early (:707-709), on a Seq<?> logic var writes seq.size
with to.setnum and returns early (:710-712), and any other sensor
or target falls through to to.setobj(null) (:716). The null-target
dead leg (:685-688) is NOT this slice -- it was already done in
N2507, checked first, before the else-branch.

GREEN decisions (pinned by this slice): (1) One pure function on
SourceTurretBuildState.gd,
source_logic_sense_size_state(sensor, target_kind, string_length,
seq_size), returning `handled` + `output_kind` ("num" / "obj") +
`output_value` + `is_null`, so the caller sees exactly which value
the logic variable receives and whether the write was the null
fall-through. It sits immediately AFTER
source_logic_sense_content_state (the else-branch is the last leg
of the same SenseI.run() dispatch) and BEFORE
source_turret_progress_state. (2) There is NO driver tick line:
the legs are logic reads, not tick writes (the
N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508 precedent); the
proof calls the pure function directly with synthetic inputs, and
wiring the legs into a live logic-executor driver is its own later
slice (the logic executor is not in the driver yet). (3) No legacy
`source_logic_sense_size_result` schema exists, so the contract
validator falls through to the new
source_logic_sense_size_state_result schema and no alias is
needed. (4) Shard routing: the ported method is SenseI.run()
itself, so the java_source is LExecutor.java (NOT
BuildingComp.java -- the N2508 precedent is the reverse: there the
dispatched method WAS BuildingComp.sense(Content)), and the slice
lives in the canonical SSOT only (the N2507 precedent:
`core/src/mindustry/logic/` selects into no shard); comp stays
560/464, defense stays 210/209. SSOT expected after GREEN:
symbols +4, Done +1, contracts +1, schema +2, 11676/1737/1671/3133
-> 11680/1738/1672/3135.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_logic_sense_content import DEFERRED as N2508_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LEXECUTOR = 'core/src/mindustry/logic/LExecutor.java'
PROOF = '/root/C07TurretLogicSenseSizeProof'
SIZE_OWNER = 'SourceTurretBuildState.source_logic_sense_size_state'
TESTS = ['test_c07_turret_logic_sense_size_registration', 'test_all_c07_turret_logic_sense_size_input_evidence_is_exact', 'test_turret_logic_sense_size_state', 'test_reference_graph_and_actual_c07_turret_logic_sense_size']
# The slice sources the N2509 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/logic/LExecutor.java',
]
EXACT_EXPRS = [
    'if(sense == LAccess.size || sense == LAccess.bufferSize){',
    'if(target instanceof CharSequence seq){',
    'to.setnum(seq.length());',
    'return;',
    '}else if(target instanceof Seq<?> seq){',
    'to.setnum(seq.size);',
    'to.setobj(null);',
    'public static class SenseI implements LInstruction{',
    'if(target instanceof Senseable se){',
    '}else{',
]

# DEFERRED is carried from the N2508 register script via import --
# never retyped. The non-Senseable-legs entry ("SenseI.run()
# non-Senseable legs ... -- NOT this slice ...") is DROPPED here --
# the legs are done at N2509 -- and replaced by the new entries
# below. The filter also drops the N2507 dispatch-hook DONE entry,
# whose "The Content leg and the non-Senseable size/bufferSize legs
# are still deferred" clause is now stale for both legs (the same
# lossiness as N2508's 'Content leg' filter, which dropped that
# entry for the Content leg; the N2507 DONE entry is preserved in
# slice N2507's own ledger record). Every other entry is carried
# verbatim (the N2211/N2228 lesson -- never retype the pool).
DEFERRED = [e for e in N2508_DEFERRED if 'non-Senseable' not in e] + [
    'SenseI.run() non-Senseable legs (`if(sense == LAccess.size || sense == LAccess.bufferSize){ ... } to.setobj(null);`, LExecutor.java:705-717) -- DONE by this slice (N2509); the pure function ports the size/bufferSize guard on CharSequence (`to.setnum(seq.length());`, :708, early return :709) and Seq (`to.setnum(seq.size);`, :711, early return :712), with the `to.setobj(null)` fall-through (:716) for any other sensor or target. The null-target dead leg was already done in N2507 (checked first, :685-688).',
    'Turret logic-sense size Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508: the N2509 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=LEXECUTOR, **extra):
        return backed(typ, source, expr, rule, **extra)

    size_inputs = {
        'sensor': a('String', 'if(sense == LAccess.size || sense == LAccess.bufferSize){', 'The logic sensor to read, spelled by its LAccess enum name (`if(sense == LAccess.size || sense == LAccess.bufferSize){`, LExecutor.java:706; `    bufferSize,` LAccess.java:43, `    size,` :45): only "size" / "bufferSize" enter the size block -- any other sensor skips it and falls through to `to.setobj(null)`.'),
        'target_kind': a('String', 'if(target instanceof CharSequence seq){', 'The non-Senseable target type, spelled "string" (CharSequence, `if(target instanceof CharSequence seq){`, LExecutor.java:707) / "seq" (Seq<?>, `}else if(target instanceof Seq<?> seq){`, :710) / anything else: a null target is also "other" here, because the dead leg is checked first in N2507\'s hook and `instanceof` is false for null on both arms.'),
        'string_length': a('float', 'to.setnum(seq.length());', 'The CharSequence length (`seq.length()`, LExecutor.java:708), passed explicitly because the pure function does not read the frame (the N2212/N2220 per-def-param precedent).'),
        'seq_size': a('float', 'to.setnum(seq.size);', 'The Seq size (`seq.size`, LExecutor.java:711 -- arc Seq public field), passed explicitly because the pure function does not read the frame (the N2212/N2220 per-def-param precedent).'),
    }
    size_outputs = {
        'handled': a('bool', 'public static class SenseI implements LInstruction{', 'Whether the branch resolved to a logic-variable write (`public static class SenseI implements LInstruction{`, LExecutor.java:668; every modeled leg writes with to.setnum or to.setobj, so handled is true throughout this slice).'),
        'output_kind': a('String', 'to.setobj(null);', 'Which write the branch performs: "num" when it calls to.setnum (`to.setnum(seq.length());` / `to.setnum(seq.size);`, LExecutor.java:708/711) and "obj" when it calls to.setobj (`to.setobj(null);`, :716); the logic variable holds either a number or an object, never both.'),
        'output_value': a('Variant', 'to.setnum(seq.size);', 'The value written to the logic variable: the string length or sequence size on the num legs (`to.setnum(seq.length());` / `to.setnum(seq.size);`, LExecutor.java:708/711), or null on the fall-through leg (`to.setobj(null);`, :716).'),
        'is_null': a('bool', 'to.setobj(null);', 'Whether the branch fell through to the null object write (`to.setobj(null);`, LExecutor.java:716); true only on the fall-through leg, the N2507 `is_no_sensed` / N2508 `is_invalid` precedent for a 4th flag key.'),
    }
    return size_inputs, size_outputs


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
    size_inputs, size_outputs = definitions()

    entries = [
        ('N2509', SIZE_OWNER, 'source_logic_sense_size_state', LEXECUTOR, 'mindustry.logic.LExecutor.SenseI', 'SenseI.run(LExecutor)', size_inputs, size_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SenseI non-Senseable size/bufferSize legs from LExecutor.java:705-717.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SenseI non-Senseable size/bufferSize legs from LExecutor.java:705-717.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: handled, output_kind, output_value, is_null.
    by_slice['N2509'] = [
        'source_logic_sense_size_state_result.handled',
        'source_logic_sense_size_state_result.output_kind',
        'source_logic_sense_size_state_result.output_value',
        'source_logic_sense_size_state_result.is_null',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2509', dict(status='done', java_source=LEXECUTOR, java_class='mindustry.logic.LExecutor.SenseI', java_method='SenseI.run(LExecutor)', godot_owner=SIZE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2509'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
