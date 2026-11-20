"""Register the SenseI Content leg (N2508).

SenseI.run() is `public void run(LExecutor exec){ Object target =
from.obj(); Object sense = type.obj(); if(target == null && sense
== LAccess.dead){ to.setnum(1); return; } if(target instanceof
Senseable se){ if(sense instanceof Content co){
to.setnum(se.sense(co)); }else if(sense instanceof LAccess la){
... } } else{ ... } }` (LExecutor.java:681-718). The Content branch
calls BuildingComp.sense(Content), which is `public double
sense(Content content){ if(content instanceof Item i && items !=
null) return items.get(i); if(content instanceof Liquid l &&
liquids != null) return liquids.get(l); if(getPayloads() != null){
if(content instanceof UnitType u) return getPayloads().get(u);
if(content instanceof Block b) return getPayloads().get(b); }
return Float.NaN; //invalid sense }` (BuildingComp.java:2139-2147).
This slice ports that branch for a duo Senseable target: Item /
Liquid / UnitType / Block counts from the live inventories, passed
in as params (the N2212/N2220 per-def-param precedent), and
Float.NaN for anything else. The leg always writes with to.setnum,
so output_kind is always "num" and handled is true throughout.

GREEN decisions (pinned by this slice): (1) One pure function on
SourceTurretBuildState.gd,
source_logic_sense_content_state(content_kind, has_items,
item_count, has_liquids, liquid_amount, has_payloads,
payload_unit_count, payload_block_count), returning `handled` +
`output_kind` (always "num") + `output_value` + `is_invalid`, so
the caller sees exactly which count the logic variable receives and
whether the sense was invalid. It sits immediately AFTER
source_logic_sense_dispatch_state (the Content leg is the other
branch of the same SenseI.run() dispatch) and BEFORE
source_turret_progress_state. (2) There is NO driver tick line: the
leg is a logic read, not a tick write (the
N2206/N2208/N2223/N2283/N2284/N2506/N2507 precedent); the proof
calls the pure function directly with synthetic inputs, and wiring
the leg into a live logic-executor driver is its own later slice
(the logic executor is not in the driver yet). (3) No legacy
`source_logic_sense_content_result` schema exists, so the contract
validator falls through to the new
source_logic_sense_content_state_result schema and no alias is
needed. (4) Shard routing: the ported method is
BuildingComp.sense(Content), so the java_source is
BuildingComp.java (NOT LExecutor.java -- the N2507 precedent is the
reverse: there the dispatched method WAS SenseI.run itself), and
the slice mirrors into the comp shard: comp 559/463 -> 560/464;
defense stays 210/209. SSOT expected after GREEN: symbols +4, Done
+1, contracts +1, schema +2, 11672/1736/1670/3131 ->
11676/1737/1671/3133.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_logic_sense_dispatch import DEFERRED as N2507_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LEXECUTOR = 'core/src/mindustry/logic/LExecutor.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07TurretLogicSenseContentProof'
CONTENT_OWNER = 'SourceTurretBuildState.source_logic_sense_content_state'
TESTS = ['test_c07_turret_logic_sense_content_registration', 'test_all_c07_turret_logic_sense_content_input_evidence_is_exact', 'test_turret_logic_sense_content_state', 'test_reference_graph_and_actual_c07_turret_logic_sense_content']
# The slice sources the N2508 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/logic/LExecutor.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
]
EXACT_EXPRS = [
    'if(sense instanceof Content co){',
    'to.setnum(se.sense(co));',
    'public double sense(Content content){',
    'if(content instanceof Item i && items != null) return items.get(i);',
    'if(content instanceof Liquid l && liquids != null) return liquids.get(l);',
    'if(getPayloads() != null){',
    'if(content instanceof UnitType u) return getPayloads().get(u);',
    'if(content instanceof Block b) return getPayloads().get(b);',
    'return Float.NaN; //invalid sense',
    'public static class SenseI implements LInstruction{',
    'if(target instanceof Senseable se){',
]

# DEFERRED is carried from the N2507 register script via import --
# never retyped. The Content-leg entry ("SenseI.run() Content leg
# ... -- NOT this slice ...") is DROPPED here -- the Content leg is
# done at N2508 -- and replaced by the new entries below. Every
# other entry is carried verbatim (the N2211/N2228 lesson -- never
# retype the pool).
DEFERRED = [e for e in N2507_DEFERRED if 'Content leg' not in e] + [
    'SenseI.run() Content leg (`if(sense instanceof Content co){ to.setnum(se.sense(co)); }`, LExecutor.java:692-693) -- DONE by this slice (N2508); the pure function ports BuildingComp.sense(Content) (BuildingComp.java:2139-2147): Item reads items.get(i), Liquid reads liquids.get(l), UnitType / Block read getPayloads().get(...), anything else returns Float.NaN (invalid sense). The leg always writes with to.setnum, so output_kind is always "num". The non-Senseable size/bufferSize legs are still deferred (see below).',
    'Turret logic-sense content Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507: the N2508 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=LEXECUTOR, **extra):
        return backed(typ, source, expr, rule, **extra)

    content_inputs = {
        'content_kind': a('String', 'if(sense instanceof Content co){', 'The sensed Content type, spelled "item" / "liquid" / "unit" / "block" (Item / Liquid / UnitType / Block, `if(sense instanceof Content co){`, LExecutor.java:692; `public double sense(Content content){`, BuildingComp.java:2139): any other spelling is an invalid sense.'),
        'has_items': a('bool', 'if(content instanceof Item i && items != null) return items.get(i);', 'Whether the building has an items inventory (`if(content instanceof Item i && items != null) return items.get(i);`, BuildingComp.java:2140): an Item sensor with no items falls through to Float.NaN, it does NOT fall into the payload legs.', source=BUILDING_COMP),
        'item_count': a('float', 'if(content instanceof Item i && items != null) return items.get(i);', 'The sensed Item count (`items.get(i)`, BuildingComp.java:2140), passed explicitly because the pure function does not read the frame (the N2212/N2220 per-def-param precedent).', source=BUILDING_COMP),
        'has_liquids': a('bool', 'if(content instanceof Liquid l && liquids != null) return liquids.get(l);', 'Whether the building has a liquids inventory (`if(content instanceof Liquid l && liquids != null) return liquids.get(l);`, BuildingComp.java:2141).', source=BUILDING_COMP),
        'liquid_amount': a('float', 'if(content instanceof Liquid l && liquids != null) return liquids.get(l);', 'The sensed Liquid amount (`liquids.get(l)`, BuildingComp.java:2141), passed explicitly because the pure function does not read the frame (the N2212/N2220 per-def-param precedent).', source=BUILDING_COMP),
        'has_payloads': a('bool', 'if(getPayloads() != null){', 'Whether the building has a payloads inventory (`if(getPayloads() != null){`, BuildingComp.java:2142): only UnitType / Block sensors read payloads, and only when payloads exist.', source=BUILDING_COMP),
        'payload_unit_count': a('float', 'if(content instanceof UnitType u) return getPayloads().get(u);', 'The sensed UnitType payload count (`getPayloads().get(u)`, BuildingComp.java:2143), passed explicitly because the pure function does not read the frame (the N2212/N2220 per-def-param precedent).', source=BUILDING_COMP),
        'payload_block_count': a('float', 'if(content instanceof Block b) return getPayloads().get(b);', 'The sensed Block payload count (`getPayloads().get(b)`, BuildingComp.java:2144), passed explicitly because the pure function does not read the frame (the N2212/N2220 per-def-param precedent).', source=BUILDING_COMP),
    }
    content_outputs = {
        'handled': a('bool', 'public double sense(Content content){', 'Whether the leg resolved to a logic-variable write (`public double sense(Content content){`, BuildingComp.java:2139; every modeled leg writes with to.setnum (`to.setnum(se.sense(co));`, LExecutor.java:693), so handled is true throughout this slice).', source=BUILDING_COMP),
        'output_kind': a('String', 'public double sense(Content content){', 'Which write the leg performs: always "num", because the Content branch writes with to.setnum (`to.setnum(se.sense(co));`, LExecutor.java:693) and never to.setobj; the sensed value is a double (`public double sense(Content content){`, BuildingComp.java:2139).', source=BUILDING_COMP),
        'output_value': a('float', 'public double sense(Content content){', 'The value written to the logic variable: the Item / Liquid / UnitType / Block count (`public double sense(Content content){`, BuildingComp.java:2139), or Float.NaN when the sense is invalid (`return Float.NaN; //invalid sense`, :2146).', source=BUILDING_COMP),
        'is_invalid': a('bool', 'return Float.NaN; //invalid sense', 'Whether Java returns Float.NaN for this sense (`return Float.NaN; //invalid sense`, BuildingComp.java:2146); true only on the invalid leg, the N2284 `sense_value_is_nan` precedent.', source=BUILDING_COMP),
    }
    return content_inputs, content_outputs


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
    content_inputs, content_outputs = definitions()

    entries = [
        ('N2508', CONTENT_OWNER, 'source_logic_sense_content_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp.BuildingComp', 'BuildingComp.sense(Content)', content_inputs, content_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SenseI Content leg from BuildingComp.java:2139-2147 + LExecutor.java:692-693.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SenseI Content leg from BuildingComp.java:2139-2147 + LExecutor.java:692-693.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: handled, output_kind, output_value, is_invalid.
    by_slice['N2508'] = [
        'source_logic_sense_content_state_result.handled',
        'source_logic_sense_content_state_result.output_kind',
        'source_logic_sense_content_state_result.output_value',
        'source_logic_sense_content_state_result.is_invalid',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2508', dict(status='done', java_source=BUILDING_COMP, java_class='mindustry.entities.comp.BuildingComp.BuildingComp', java_method='BuildingComp.sense(Content)', godot_owner=CONTENT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2508'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
