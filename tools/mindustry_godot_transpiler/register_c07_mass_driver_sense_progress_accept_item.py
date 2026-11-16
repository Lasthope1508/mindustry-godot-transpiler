"""Register the MassDriver sense(progress) override + acceptItem predicate (N2208).

The MassDriver's sense(progress) override, following the N2206
launch-pad sense precedent and the N2203 damage() precedent (a
pure function with NO driver tick line -- sense is a logic read,
not a tick write). MassDriverBuild overrides sense: `if(sensor ==
LAccess.progress) return Mathf.clamp(1f - reloadCounter);`
(MassDriver.java:225), and non-progress sensors fall through to
super.sense (MassDriver.java:226, `return super.sense(sensor);`)
-- but the BuildingComp super switch has NO progress case
(BuildingComp.java:2093, `public double sense(LAccess sensor){`
+ 2123, `default -> Float.NaN; //gets converted to null in
logic`), so a logic processor reading `progress` on a mass
driver currently gets NaN/null while Java returns the clamped
reload fraction. N2208 closes that gap with one pure function
(source_mass_driver_sense_state) over one frame key
(`reload_counter`, float) plus the sensor string: the function
takes (frame, sensor) -- the sensor parameter because sense is a
logic read over an enum, not a tick write -- and returns the
generic laccess wire shape (`sense_value` +
`sense_value_is_nan`, SourceBlockSenseState.laccess_state) plus
an explicit `handled` flag, so a caller can tell "handled, value
is a clamped fraction" from "not handled -- fall through to
super.sense". The same slice adds the intake predicate:
MassDriverBuild.acceptItem (`public boolean acceptItem(Building
source, Item item){` with `return items.total() <
itemCapacity && linkValid();`, MassDriver.java:285-287) -- a
second pure function (source_mass_driver_accept_item_state)
over one frame key (`items_total`, float) plus the per-def
itemCapacity and the caller-computed link_valid flag,
returning `accept_item`. RED decisions (pinned by this slice):
(1) sensor spelling is "progress" -- LAccess.java:28 lists
`progress,`, and the generic sense layer matches sensor strings
by enum name. (2) An absent `reload_counter` key reads 0.0, NOT
NaN: `public float reloadCounter = 0f;` is the Java init value,
so a freshly built driver senses clamp(1 - 0) = 1.0 -- fully
reloaded, the only observable Java behavior at init -- and
returning 1.0 regresses nothing, because no consumer reads this
value yet (the sense-dispatch hook does not exist); absent ->
NaN would preserve the port's current UNFAITHFUL output
instead. (3) The clamp edge: reloadCounter 1.0 (just fired)
senses 0.0, 0.5 senses 0.5, a negative counter (impossible in
Java -- the counter only drains toward 0 and fire resets it to
1) floors to 1.0 anyway through the clamp. (4) An absent
`items_total` key reads 0.0 -- a fresh ItemModule totals 0
(`protected int total;`, ItemModule.java:25, with `public int
total(){` / `return total;`, ItemModule.java:174-175) -- so a
fresh driver with a valid link accepts items, which IS the Java
init behavior. (5) linkValid() is a world query (`protected
boolean linkValid(){` with `if(link == -1) return false;` and
`return world.build(this.link) instanceof MassDriverBuild other
&& other.block == block && other.team == team && within(other,
range);`, MassDriver.java:346-349), so the pure accept function
takes `link_valid` as a caller-computed bool; computing it from
link state is its own later slice. (6) itemCapacity is per-def:
mass-driver 120 (Blocks.java:2170, `itemCapacity = 120;`),
class default 10 (Block.java:75, `public int itemCapacity =
10;`); the caller passes it in, the N2207 launch-pad
precedent. No new frame key, no SOURCE_CONSUMER_FRAME_META_KEYS
change, no simulate_factory wiring change, no driver tick line
for either function. Shard note: MassDriver.java lives under
/world/blocks/distribution/ and no shard selection matches it
(the N2171 precedent), so the GREEN register run must record
that no source_modules shard changes.

Composition, not re-implementation: the generic laccess wire
(SourceBlockSenseState.laccess_state) already defines the
`sense_value` + `sense_value_is_nan` shape for Block-level sense
(Block.java:1651-1664). N2208 does not touch it -- it is the
Block-level sense, takes no frame/reload-counter input, and
adding family state there would break its generic shape; the
BuildingComp sense bridges are likewise the wrong layer (they
port the BuildingComp switch, which has no progress case by
design). N2208 supplies the missing per-family pure functions;
the logic-processor integration -- how a logic `sense progress`
read on a placed mass driver reaches this family function -- is
its own later slice with a documented limit, as is the
intake/dump integration that calls acceptItem. No updateTile
advance: the link/state-machine advance / reload drain /
waitingShooters / rotation align / fire / dumpAccumulate
(MassDriver.java:133-221) waits for its own slice; the proof
carries no link/state/reload/fire keys. Single def -- no
large-mass-driver def in this upstream version, so the same
functions cover the whole family. Do NOT confuse sense with
progress(): `public float progress(){` + `return 0f;`
(BuildingComp.java:617-619) is a DIFFERENT method the sense
switch never calls.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_launch_pad_update_tile import DEFERRED as _N2207_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
MASS_DRIVER = 'core/src/mindustry/world/blocks/distribution/MassDriver.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
ITEM_MODULE = 'core/src/mindustry/world/modules/ItemModule.java'
PROOF = '/root/C07MassDriverSenseProgressAcceptItemProof'
SENSE_OWNER = 'SourceMassDriverBuildState.source_mass_driver_sense_state'
ACCEPT_OWNER = 'SourceMassDriverBuildState.source_mass_driver_accept_item_state'
TESTS = ['test_c07_mass_driver_sense_progress_accept_item_registration', 'test_all_c07_mass_driver_sense_progress_accept_item_input_evidence_is_exact', 'test_mass_driver_sense_progress_accept_item_state', 'test_reference_graph_and_actual_c07_mass_driver_sense_progress_accept_item']
# The 6 slice sources the N2208 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files, and no expr may name a file outside them.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/distribution/MassDriver.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/logic/LAccess.java',
    'core/src/mindustry/world/modules/ItemModule.java',
]
EXACT_EXPRS = ['public double sense(LAccess sensor){', 'if(sensor == LAccess.progress) return Mathf.clamp(1f - reloadCounter);', 'return super.sense(sensor);', 'public float reloadCounter = 0f;', 'public boolean acceptItem(Building source, Item item){', 'return items.total() < itemCapacity && linkValid();', 'protected boolean linkValid(){', 'if(link == -1) return false;', 'return world.build(this.link) instanceof MassDriverBuild other && other.block == block && other.team == team && within(other, range);', 'public class MassDriver extends Block{', 'public class MassDriverBuild extends Building implements RotBlock{', 'reloadCounter = Mathf.clamp(reloadCounter - edelta() / reload);', 'reloadCounter = 1f;', 'default -> Float.NaN; //gets converted to null in logic', 'public float progress(){', 'return 0f;', 'progress,', 'itemCapacity = 120;', 'reload = 200f;', 'range = 440f;', 'public int itemCapacity = 10;', 'protected int total;', 'public int total(){', 'return total;']

# DEFERRED is carried from the N2207 register script via import --
# never retyped. The N2207 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2206 import), NOT a plain
# list literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2208's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval. The
# sense(progress) override and the acceptItem predicate
# themselves are NOT carried as deferred: they are THIS slice
# (N2208) -- the inherited N2171 entries still name them as
# waiting, which is stale history, superseded by this slice.
DEFERRED = list(_N2207_DEFERRED) + [
    'MassDriver sense(progress) / acceptItem Windows Godot proof -- debt in GOAL.md section 5, same as N2175-N2207: the N2208 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def f(typ, expr, rule, source=MASS_DRIVER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2208_sense_inputs = {
        'frame': f('Dictionary', 'public float reloadCounter = 0f;', 'The building frame carrying the reload_counter observation (MassDriver.java:117, `public float reloadCounter = 0f;`, drained by the updateTile advance every tick after the no-power skip and reset by fire()); a missing reload_counter key reads 0.0 -- the Java init default, not "no observation yet" -- because `public float reloadCounter = 0f;` is the init value, so a freshly built driver senses clamp(1 - 0) = 1.0, fully reloaded.'),
        'sensor': f('String', 'progress,', 'The LAccess sensor enum name as a string (LAccess.java:28 lists `progress,`); the generic sense layer matches sensor strings by enum name ("health", "maxHealth", "color", ...). Only "progress" is handled by this override; any other sensor falls through to super.sense (MassDriver.java:226, `return super.sense(sensor);`).', source=LACCESS),
    }
    n2208_sense_outputs = {
        'sense_value': f('float', 'if(sensor == LAccess.progress) return Mathf.clamp(1f - reloadCounter);', 'The sensed progress value (MassDriver.java:224-227): the clamped reload fraction `Mathf.clamp(1f - reloadCounter)` when the sensor is "progress" (handled true, sense_value_is_nan false), null when the sensor is not handled (fall through to super.sense, handled false, sense_value_is_nan true).'),
    }
    n2208_accept_inputs = {
        'frame': f('Dictionary', 'public boolean acceptItem(Building source, Item item){', 'The building frame carrying the items_total observation (MassDriver.java:285, `public boolean acceptItem(Building source, Item item){` reads `items.total()`); a missing items_total key reads 0.0 -- a fresh ItemModule totals 0 (`protected int total;`, ItemModule.java:25, with `public int total(){` / `return total;`, ItemModule.java:174-175) -- so a fresh driver with a valid link accepts items, which IS the Java init behavior.'),
        'item_capacity': f('float', 'itemCapacity = 120;', 'The per-def itemCapacity the accept predicate runs the items total against (Blocks.java:2170, `itemCapacity = 120;` for mass-driver; class default 10, Block.java:75, `public int itemCapacity = 10;`); the caller passes it in, the N2207 launch-pad precedent.', source=BLOCKS),
        'link_valid': f('bool', 'protected boolean linkValid(){', 'The caller-computed link validity (MassDriver.java:346, `protected boolean linkValid(){` with `if(link == -1) return false;` and the world.build(instanceof) check, MassDriver.java:347-348): linkValid() is a world query, so the pure accept function takes it as a bool; computing it from link state is its own later slice.'),
    }
    n2208_accept_outputs = {
        'accept_item': f('bool', 'return items.total() < itemCapacity && linkValid();', 'The accept predicate (MassDriver.java:285-288): true when the held items total is below itemCapacity AND the link is valid -- "mass drivers that output only cannot accept items" (MassDriver.java:286) -- false otherwise.'),
    }
    return n2208_sense_inputs, n2208_sense_outputs, n2208_accept_inputs, n2208_accept_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
        upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    inputs, outputs = [], []
    sense_inputs, sense_outputs, accept_inputs, accept_outputs = definitions()
    inputs = [sense_inputs, accept_inputs]
    outputs = [sense_outputs, accept_outputs]
    for keys in inputs + outputs:
        for field, meta in keys.items():
            source = meta['java_source']
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
            if meta['java_expr'] not in text:
                missing.append('%s: %s' % (field, meta['java_expr']))
    total = len(EXACT_EXPRS) + sum(len(keys) for keys in inputs + outputs)
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    n2208_sense_inputs, n2208_sense_outputs, n2208_accept_inputs, n2208_accept_outputs = definitions()

    entries = [
        ('N2208', SENSE_OWNER, 'source_mass_driver_sense_state', MASS_DRIVER, 'mindustry.world.blocks.distribution.MassDriver.MassDriverBuild', 'MassDriverBuild.sense()', n2208_sense_inputs, n2208_sense_outputs, True, 'Dictionary'),
        ('N2208', ACCEPT_OWNER, 'source_mass_driver_accept_item_state', MASS_DRIVER, 'mindustry.world.blocks.distribution.MassDriver.MassDriverBuild', 'MassDriverBuild.acceptItem()', n2208_accept_inputs, n2208_accept_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed MassDriver sense(progress) override + acceptItem predicate from MassDriver.java / BuildingComp.java / LAccess.java / ItemModule.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed MassDriver sense(progress) override + acceptItem predicate from MassDriver.java / BuildingComp.java / LAccess.java / ItemModule.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the sensed value, then the accept predicate.
    by_slice['N2208'] = [
        'source_mass_driver_sense_state_result.sense_value',
        'source_mass_driver_accept_item_state_result.accept_item',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2208', dict(status='done', java_source=MASS_DRIVER, java_class='mindustry.world.blocks.distribution.MassDriver.MassDriverBuild', java_method='MassDriverBuild.sense()', godot_owner=SENSE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2208'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
