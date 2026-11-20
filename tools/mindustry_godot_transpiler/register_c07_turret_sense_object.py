"""Register the Turret BuildingComp senseObject() LAccess delegation (N2506).

senseObject() is `public Object senseObject(LAccess sensor){
return switch(sensor){ case type -> block; case firstItem ->
items == null ? null : items.first(); case config ->
block.configSenseable() ? config() : null; case payloadType
-> getPayload() instanceof UnitPayload p1 ? p1.unit.type :
getPayload() instanceof BuildPayload p2 ? p2.block() : null;
default -> noSensed; }; }` (BuildingComp.java:2128-2136).
All 4 legs + default are implemented here: type returns the
block id; firstItem returns the observed first item ("" encodes
null -- `items == null ? null : items.first()`,
ItemModule.first() scans items[] in content order and returns
the first item with count > 0, else null,
ItemModule.java:182-189; duo hasItems=true, ItemTurret.java:28,
so `if(block.hasItems) items = new ItemModule();`,
BuildingComp.java:145, runs and items is non-null); config is
constant null for duo (no `config(...)` registration in any
turret file, so `configurations` stays without an Item / Liquid
/ UnlockableContent / Block / UnitType handler and
`configSenseable()` is false, Block.java:809-812; base
`config()` returns null anyway, BuildingComp.java:2024, no
turret override); payloadType is constant null (base
`getPayload()` returns null, BuildingComp.java:984-985, no
turret override, so neither instanceof arm can fire); an
unknown sensor falls through to the noSensed sentinel
(`Object noSensed = new Object();`, Senseable.java:6), which
the logic converts to a numeric sense() fallback
(`if(objOut == Senseable.noSensed){` /
`to.setnum(se.sense(la));`, LExecutor.java:697-699).

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_sense_object_state(sensor, block_id, first_item),
returning the N2234 senseObject wire shape (`handled` +
`sense_object` + `is_no_sensed`), so the logic-dispatch caller
can try senseObject() first and fall back to numeric sense()
on the sentinel. It sits immediately AFTER
source_building_comp_sense_state (Java order: sense() then
senseObject() in BuildingComp) and BEFORE
source_turret_progress_state. (2) There is NO driver tick
line: senseObject is a logic read, not a tick write (the
N2206/N2208/N2223/N2283/N2284/N2234 precedent); the proof
calls the pure function directly with synthetic inputs, and
the logic-processor dispatch hook is its own later slice. (3)
No legacy `source_turret_sense_object_result` schema exists,
so the contract validator falls through to the new
source_turret_sense_object_state_result schema and no alias
is needed. SSOT expected after GREEN: symbols +3, Done +1,
contracts +1, schema +2, 11665/1734/1668/3127 ->
11668/1735/1669/3129; comp shard slices 558 -> 559,
contracts 462 -> 463 (java_source BuildingComp.java routes
to comp, the N2284 precedent); defense stays 210/209.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_building_comp_sense import DEFERRED as N2284_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
ITEM_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
BLOCK = 'core/src/mindustry/world/Block.java'
SENSEABLE = 'core/src/mindustry/logic/Senseable.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
LEXECUTOR = 'core/src/mindustry/logic/LExecutor.java'
ITEM_MODULE = 'core/src/mindustry/world/modules/ItemModule.java'
PROOF = '/root/C07TurretSenseObjectProof'
SENSE_OBJECT_OWNER = 'SourceTurretBuildState.source_turret_sense_object_state'
TESTS = ['test_c07_turret_sense_object_registration', 'test_all_c07_turret_sense_object_input_evidence_is_exact', 'test_turret_sense_object_state', 'test_reference_graph_and_actual_c07_turret_sense_object']
# The slice sources the N2506 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/logic/Senseable.java',
    'core/src/mindustry/logic/LAccess.java',
    'core/src/mindustry/logic/LExecutor.java',
    'core/src/mindustry/world/modules/ItemModule.java',
]
EXACT_EXPRS = [
    'public Object senseObject(LAccess sensor){',
    'case type -> block;',
    'case firstItem -> items == null ? null : items.first();',
    'case config -> block.configSenseable() ? config() : null;',
    'case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null;',
    'default -> noSensed;',
    'public boolean configSenseable(){',
    'return configurations.containsKey(Item.class) || configurations.containsKey(Liquid.class) || configurations.containsKey(UnlockableContent.class) ||',
    'configurations.containsKey(Block.class) || configurations.containsKey(UnitType.class);',
    'public ObjectMap<Class<?>, Cons2> configurations = new ObjectMap<>();',
    'public @NoPatch boolean hasItems;',
    'if(block.hasItems) items = new ItemModule();',
    'public @Nullable Payload getPayload(){',
    'public Object config(){',
    'Object noSensed = new Object();',
    'if(objOut == Senseable.noSensed){',
    'to.setnum(se.sense(la));',
    'public @Nullable Item first(){',
    'return content.item(i);',
    'hasItems = true;',
    'duo = new ItemTurret("duo"){{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    '    type,',
    '    firstItem,',
    '    config(true, "to"),',
    '    payloadType,',
]

# DEFERRED is carried from the N2284 register script via import --
# never retyped. The senseObject entry ("Turret senseObject()
# (BuildingComp.java:2128-2136) -- NOT this slice ...") is DROPPED
# here -- senseObject is done at N2506 -- and replaced by the new
# entries below. Every other entry is carried verbatim (the
# N2211/N2228 lesson -- never retype the pool).
DEFERRED = [e for e in N2284_DEFERRED if 'Turret senseObject() (BuildingComp.java:2128-2136)' not in e] + [
    'Turret senseObject() (BuildingComp.java:2128-2136) -- DONE by this slice (N2506); the pure function ports all 4 legs + default over the block id + observed first item, and reports handled=false + is_no_sensed=true for unknown sensors so the caller falls back to numeric sense().',
    'Turret senseObject() Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284: the N2506 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BUILDING_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    sense_object_inputs = {
        'sensor': a('String', 'public Object senseObject(LAccess sensor){', 'The logic sensor to read, spelled by its LAccess enum name (`public Object senseObject(LAccess sensor){`, BuildingComp.java:2128; `firstItem,` LAccess.java:8, `type,` :63, `payloadType,` :69, `config(true, "to"),` :83): the 4 senseObject legs are handled here, any other sensor falls through to noSensed.'),
        'block_id': a('String', 'duo = new ItemTurret("duo"){{', 'The block id (`duo = new ItemTurret("duo"){{`, Blocks.java:3257; `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`, Turret.java:277): the port identity of the `block` the `type` leg returns, passed explicitly because it is per-def static state, not a live frame key (the N2212/N2220 per-def-param precedent).', source=BLOCKS),
        'first_item': a('String', 'case firstItem -> items == null ? null : items.first();', 'The observed first item id (`items.first()`, BuildingComp.java:2131; `public @Nullable Item first(){`, ItemModule.java:182-189, scans items[] in content order and returns the first item with count > 0, `return content.item(i);`, else null; duo hasItems=true, `hasItems = true;`, ItemTurret.java:28, so `if(block.hasItems) items = new ItemModule();`, BuildingComp.java:145, runs); "" encodes null (items null or empty); passed explicitly because the frame carries no items key (the N2212/N2220 per-def-param precedent, same reason N2284 deferred totalItems).'),
    }
    sense_object_outputs = {
        'handled': a('bool', 'public Object senseObject(LAccess sensor){', 'Whether the sensor is one of the four senseObject legs (BuildingComp.java:2128-2133, `public Object senseObject(LAccess sensor){` / `case type -> block;` / `case firstItem -> ...` / `case config -> ...` / `case payloadType -> ...`); any other sensor falls through to `default -> noSensed;` and is unhandled.'),
        'sense_object': a('Variant', 'case type -> block;', 'The sensed object: the block id for "type" (BuildingComp.java:2130, `case type -> block;`), the observed first item id or null for "firstItem" (BuildingComp.java:2131, `case firstItem -> items == null ? null : items.first();`), null for "config" (BuildingComp.java:2132, `case config -> block.configSenseable() ? config() : null;` -- duo configSenseable() is false, Block.java:809-812) and for "payloadType" (BuildingComp.java:2133, `case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null;` -- base getPayload() returns null, BuildingComp.java:984); null when the sensor is not handled.'),
        'is_no_sensed': a('bool', 'default -> noSensed;', 'Whether the sensor fell through to the noSensed sentinel (BuildingComp.java:2134, `default -> noSensed;` -- `Object noSensed = new Object();`, Senseable.java:6; the logic converts it to a numeric sense() fallback, `if(objOut == Senseable.noSensed){` / `to.setnum(se.sense(la));`, LExecutor.java:697-699); true only when the sensor is not handled.'),
    }
    return sense_object_inputs, sense_object_outputs


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
    sense_object_inputs, sense_object_outputs = definitions()

    entries = [
        ('N2506', SENSE_OBJECT_OWNER, 'source_turret_sense_object_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp.BuildingComp', 'BuildingComp.senseObject(LAccess)', sense_object_inputs, sense_object_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret BuildingComp senseObject() LAccess delegation from BuildingComp.java:2128-2136 + Turret.java + ItemTurret.java + Blocks.java + Block.java + Senseable.java + LAccess.java + LExecutor.java + ItemModule.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret BuildingComp senseObject() LAccess delegation from BuildingComp.java:2128-2136 + Turret.java + ItemTurret.java + Blocks.java + Block.java + Senseable.java + LAccess.java + LExecutor.java + ItemModule.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: handled, sense_object, is_no_sensed.
    by_slice['N2506'] = [
        'source_turret_sense_object_state_result.handled',
        'source_turret_sense_object_state_result.sense_object',
        'source_turret_sense_object_state_result.is_no_sensed',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2506', dict(status='done', java_source=BUILDING_COMP, java_class='mindustry.entities.comp.BuildingComp.BuildingComp', java_method='BuildingComp.senseObject(LAccess)', godot_owner=SENSE_OBJECT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2506'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
