"""Register the RepairTurret senseObject() rows (N2234).

BuildingComp.senseObject() (BuildingComp.java:2128-2136, `public
Object senseObject(LAccess sensor){`) switches on the LAccess
sensor: `case type -> block;` (:2130), `case firstItem -> items ==
null ? null : items.first();` (:2131), `case config -> block.
configSenseable() ? config() : null;` (:2132), `case payloadType
-> getPayload() instanceof UnitPayload p1 ? p1.unit.type :
getPayload() instanceof BuildPayload p2 ? p2.block() : null;`
(:2133), `default -> noSensed;` (:2134). For a repair turret
the three middle legs are all null, pinned not guessed:
firstItem is null because `hasItems` is false by default
(Block.java:45, `public @NoPatch boolean hasItems;`) and
RepairTurret never sets it, so BuildingComp.java:145 (`if(block.
hasItems) items = new ItemModule();`) never creates the items
module; config is null because RepairTurret registers no
`config()` call, so `configurations` (Block.java:402, `public
ObjectMap<Class<?>, Cons2> configurations = new ObjectMap<>();`)
stays empty and configSenseable() (Block.java:809-813) is false;
payloadType is null because the base `getPayload()` returns null
(BuildingComp.java:984-986, `public @Nullable Payload
getPayload(){` / `return null;`) and RepairTurret does not
override it. The `type` leg returns the block itself; the port
identity of a block is its id string (the same key every
`_..._for_block_id` helper resolves). An unhandled sensor returns
the `noSensed` sentinel (Senseable.java:6, `Object noSensed = new
Object();`), which the logic converts to a numeric `sense()`
fallback (LExecutor.java:697-701, `if(objOut == Senseable.
noSensed){` / `to.setnum(se.sense(la));`) -- the port reports it
as `handled: false` + `is_no_sensed: true`, the sense() N2223
`sense_value_is_nan` precedent. The sensor spellings are the
LAccess enum names (LAccess.java:8, `firstItem,`; :63, `type,`;
:69, `payloadType,`; :83, `config(true, "to"),`).

RED decisions (resolved at RED): (1) One pure function on the
same family file, taking the sensor spelling and the block id
explicitly (per-def static state, not a live frame key -- the
N2212 / N2220 precedent). (2) There is NO driver tick line:
senseObject is a logic read, not a tick write (the N2223 sense /
N2230 setStats / N2232 RepairTower range+warmup precedent). (3)
The lumped deferred entry "RepairTurret display() /
senseObject(config) rows" is dropped -- senseObject is done here
-- and replaced by a display()-only entry plus the per-def
ambientSoundVolume correction entry plus the N2234 Windows-proof
debt entry; the pool already carried that lumped entry twice
(identical strings), so the filter drops both copies. (4)
Suppression live + targets live list stay BLOCKED: no
`frame["units"] =` stamp exists anywhere in src/game, and no
frame stamps `heal_suppressed` / `heal_suppression_time`.
Three new result symbols: handled, sense_object, is_no_sensed.
SSOT expected after GREEN: symbols +3, Done +1, contracts +1,
schema +2, 11524/1683/1614/3019 -> 11527/1684/1615/3021. Slice
sources: RepairTurret.java + Blocks.java + BuildingComp.java +
Block.java + Senseable.java + LAccess.java. No shard change:
RepairTurret.java matches no shard (the N2213-N2233 precedent).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_range_build_rotation import DEFERRED as N2233_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
SENSEABLE = 'core/src/mindustry/logic/Senseable.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
PROOF = '/root/C07RepairTurretSenseObjectProof'
SENSE_OBJECT_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_sense_object_state'
TESTS = ['test_c07_repair_turret_sense_object_registration', 'test_all_c07_repair_turret_sense_object_input_evidence_is_exact', 'test_repair_turret_sense_object_state', 'test_reference_graph_and_actual_c07_repair_turret_sense_object']
# The 6 slice sources the N2234 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/logic/Senseable.java',
    'core/src/mindustry/logic/LAccess.java',
]
EXACT_EXPRS = ['public Object senseObject(LAccess sensor){', 'case type -> block;', 'case firstItem -> items == null ? null : items.first();', 'case config -> block.configSenseable() ? config() : null;', 'case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null;', 'default -> noSensed;', 'public boolean configSenseable(){', 'return configurations.containsKey(Item.class) || configurations.containsKey(Liquid.class) || configurations.containsKey(UnlockableContent.class) ||', 'public ObjectMap<Class<?>, Cons2> configurations = new ObjectMap<>();', 'public @NoPatch boolean hasItems;', 'if(block.hasItems) items = new ItemModule();', 'public @Nullable Payload getPayload(){', 'Object noSensed = new Object();', 'public class RepairTurret extends Block{', 'public class RepairPointBuild extends Building implements Ranged, RotBlock{', 'repairPoint = new RepairTurret("repair-point"){{', 'repairTurret = new RepairTurret("repair-turret"){{', '    type,', '    firstItem,', '    config(true, "to"),', '    payloadType,']

# DEFERRED is carried from the N2233 register script via import --
# never retyped. The lumped entry "RepairTurret display() /
# senseObject(config) rows" is DROPPED here -- senseObject is done
# at N2234 -- and replaced by the new entries below; the pool
# carried that lumped entry twice (identical strings), so the
# filter drops both copies. Every other entry is carried verbatim
# (the N2211/N2228 lesson -- never retype the pool).
DEFERRED = [e for e in N2233_DEFERRED if 'RepairTurret display() / senseObject(config) rows' not in e] + [
    'RepairTurret display() rows -- BuildingComp.display (BuildingComp.java:1556) builds the UI Table (bars + consumption + flow); RepairTurret category is units so no flow table, and display() is UI Table work, not a pure state read -- it waits for its own slice (senseObject done at N2234).',
    'RepairTurret per-def ambientSoundVolume correction -- N2222 pinned the 1.0 class default (RepairTurret.java:67, `ambientSoundVolume = 1f;`) but Blocks.java overrides it per def (repair-point 0.9f, :6394; repair-turret 1.25f, :6408); the ambient-sound loop still uses 1.0 for both defs -- a correction slice should resolve the volume per def and wire it into the loop.',
    'RepairTurret senseObject() Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2233: the N2234 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BUILDING_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    sense_object_inputs = {
        'sensor': a('String', 'public Object senseObject(LAccess sensor){', 'The logic sensor spelling (BuildingComp.java:2128, `public Object senseObject(LAccess sensor){` -- the LAccess enum names, LAccess.java:8 `firstItem,`, :63 `type,`, :69 `payloadType,`, :83 `config(true, "to"),`).'),
        'block_id': a('String', 'repairPoint = new RepairTurret("repair-point"){{', 'The block id (Blocks.java:6386, `repairPoint = new RepairTurret("repair-point"){{` -- repair-turret, Blocks.java:6397, `repairTurret = new RepairTurret("repair-turret"){{`): the port identity of the `block` the `type` leg returns, passed explicitly because it is per-def static state, not a live frame key (the N2212 / N2220 per-def-param precedent).', source=BLOCKS),
    }
    sense_object_outputs = {
        'handled': a('bool', 'public Object senseObject(LAccess sensor){', 'Whether the sensor is one of the four senseObject legs (BuildingComp.java:2128-2134, `public Object senseObject(LAccess sensor){` / `case type -> block;` / `case firstItem -> ...` / `case config -> ...` / `case payloadType -> ...`); any other sensor falls through to `default -> noSensed;` and is unhandled.'),
        'sense_object': a('Variant', 'case type -> block;', 'The sensed object (BuildingComp.java:2130, `case type -> block;` -- the block id; firstItem / config / payloadType are all null for a repair turret, BuildingComp.java:2131-2133, `case firstItem -> items == null ? null : items.first();` / `case config -> block.configSenseable() ? config() : null;` / `case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null;`).'),
        'is_no_sensed': a('bool', 'default -> noSensed;', 'Whether the sensor fell through to the noSensed sentinel (BuildingComp.java:2134, `default -> noSensed;` -- `Object noSensed = new Object();`, Senseable.java:6; the logic converts it to a numeric sense() fallback, LExecutor.java:697-701).'),
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
        ('N2234', SENSE_OBJECT_OWNER, 'source_repair_turret_sense_object_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.senseObject(LAccess)', sense_object_inputs, sense_object_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret senseObject() state from BuildingComp.java + Block.java + Senseable.java + LAccess.java + Blocks.java + RepairTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret senseObject() state from BuildingComp.java + Block.java + Senseable.java + LAccess.java + Blocks.java + RepairTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: handled, sense_object, is_no_sensed.
    by_slice['N2234'] = [
        'source_repair_turret_sense_object_state_result.handled',
        'source_repair_turret_sense_object_state_result.sense_object',
        'source_repair_turret_sense_object_state_result.is_no_sensed',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2234', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='RepairPointBuild.senseObject(LAccess)', godot_owner=SENSE_OBJECT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2234'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
