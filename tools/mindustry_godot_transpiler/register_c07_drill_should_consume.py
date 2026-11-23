"""Register the DrillBuild shouldConsume() gate (N2338).

DrillBuild.shouldConsume() (Drill.java:247-249, `public
boolean shouldConsume(){` with `return items.total() <
itemCapacity && enabled && dominantItem != null;`, :248)
is the BASE gate updateConsumption reads
(BuildingComp.java:1960, `boolean update = shouldConsume()
&& productionValid();` + 1992, `if(!update){` + 1993,
`efficiency = optionalEfficiency = 0f;`): items total
below the per-def item capacity AND enabled AND a dominant
item bound. It is NOT the BurstDrill override (N2295,
BurstDrill.java:128-129, `return items.total() <=
itemCapacity - dominantItems && enabled;` -- `<=` with the
dominant COUNT subtracted, no dominantItem null check) and
NOT the Turret override (N2291, Turret.java:364-366) --
each class owns its own shouldConsume(). The strict `<` is
the observable difference from N2295's `<=`: at
items_total == itemCapacity the base gate blocks while the
override (with dominant_items 0) would pass. The
dominantItem null check is the second difference: a drill
with room and enabled but no dominant item bound does NOT
consume. The BuildingComp default (`public boolean
shouldConsume(){` with `return enabled;`,
BuildingComp.java:755-756) is what the override replaces.
The items total is the cached ItemModule total
(ItemModule.java:174, `public int total(){` with `return
total;`, ItemModule.java:175 -- a fresh ItemModule starts
at 0); the per-def item capacity is `public int
itemCapacity = 10;` (Block.java:75, with `itemCapacity =
40;`, Blocks.java:3078, for impact-drill and `itemCapacity
= 60;`, Blocks.java:3107, for eruption-drill); the
dominant item is `public Item dominantItem;`
(Drill.java:244, with `public int dominantItems;`,
Drill.java:243); the enabled flag is `transient boolean
enabled = true;` (BuildingComp.java:77). The classes are
`public class Drill extends Block{` (Drill.java:27) and
`public class DrillBuild extends Building{`
(Drill.java:237); BurstDrillBuild inherits DrillBuild
(`public class BurstDrill extends Drill{`,
BurstDrill.java:17, with `public class BurstDrillBuild
extends DrillBuild{`, BurstDrill.java:70) and overrides
shouldConsume (N2295) -- the override runs for burst
drills, the base gate here is the DrillBuild predicate.

RED decisions (resolved at RED): (1) One pure function on
the same family file N2149/N2256 built, following the
N2295 BurstDrill shouldConsume precedent:
source_drill_should_consume_state(frame, item_capacity,
has_dominant_item). (2) The frame carries `items_total`
(float, absent -> 0.0 -- a fresh ItemModule totals 0, the
N2207 LaunchPad precedent) and `enabled` (bool, absent ->
true, `transient boolean enabled = true;`,
BuildingComp.java:77); the per-def item_capacity is an
explicit param (the N2212 / N2248 per-def-param
precedent); has_dominant_item is an explicit bool param
(the N2341 drawSelect precedent -- dominantItem is
`public Item dominantItem;`, Drill.java:244, set by the
N2262 ore/dominant binding, which the frame does not carry
yet). Absent keys mean "no observation yet", not "full":
the defaults make the bound read `0 < itemCapacity`, so
should_consume = enabled and has_dominant_item, the N2149
behavior preserved (the N2188 / N2191 absent-preserves
precedent) -- no placed-building frame carries live
items/dominant state until the ore/dominant binding slice
stamps it, and defaulting absent to false would zero
efficiency for every live drill. (3) There is NO driver
tick line: the BurstDrill tick driver calls the N2295
override (polymorphism -- a BurstDrill build runs the
override, not the base), and this slice ports only the
base predicate, not a caller. One new result symbol: the
gate itself. Slice sources: Drill.java + BurstDrill.java +
BuildingComp.java + Block.java + Blocks.java +
ItemModule.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BURST_DRILL = 'core/src/mindustry/world/blocks/production/BurstDrill.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
ITEM_MODULE = 'core/src/mindustry/world/modules/ItemModule.java'
PROOF = '/root/C07DrillShouldConsumeProof'
SHOULD_CONSUME_OWNER = 'SourceBurstDrillBuildState.source_drill_should_consume_state'
TESTS = ['test_c07_drill_should_consume_registration', 'test_all_c07_drill_should_consume_input_evidence_is_exact', 'test_drill_should_consume_state', 'test_reference_graph_and_actual_c07_drill_should_consume']
# The 6 slice sources the N2338 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/world/blocks/production/BurstDrill.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/modules/ItemModule.java',
]
EXACT_EXPRS = ['public boolean shouldConsume(){', 'return items.total() < itemCapacity && enabled && dominantItem != null;', 'public Item dominantItem;', 'public int dominantItems;', 'public int total(){', 'return total;', 'public int itemCapacity = 10;', 'itemCapacity = 40;', 'itemCapacity = 60;', 'transient boolean enabled = true;', 'boolean update = shouldConsume() && productionValid();', 'if(!update){', 'efficiency = optionalEfficiency = 0f;', 'return enabled;', 'public class DrillBuild extends Building{', 'public class Drill extends Block{', 'public class BurstDrillBuild extends DrillBuild{', 'public class BurstDrill extends Drill{']

DEFERRED = [
    'DrillBuild shouldConsume() Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2294: the N2338 proof runs headless on Linux here and waits for a Windows Godot run.',
    'DrillBuild shouldConsume() live driver wiring -- the BurstDrill tick driver calls the N2295 override (polymorphism); this slice ports only the base predicate, no caller. A plain-Drill tick driver wiring the base gate waits for its own slice.',
    'DrillBuild shouldConsume() dominantItem live binding -- the caller passes has_dominant_item explicitly; the N2262 ore/dominant binding stamps dominantItem live later.',
]


def definitions():
    def a(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    should_consume_inputs = {
        'frame': a('Dictionary', 'return items.total() < itemCapacity && enabled && dominantItem != null;', 'The drill frame (DrillBuild.shouldConsume, Drill.java:247-249): carries items_total (float, absent -> 0.0 -- a fresh ItemModule totals 0, the N2207 LaunchPad precedent) and enabled (bool, absent -> true, `transient boolean enabled = true;`, BuildingComp.java:77); absent keys mean no observation yet, not full, so the gate preserves the N2149 behavior (should_consume = enabled and has_dominant_item).', source=DRILL),
        'item_capacity': a('float', 'itemCapacity = 40;', 'The per-def item capacity, 40 for the impact-drill def (Blocks.java:3078) and 60 for the eruption-drill def (Blocks.java:3107); passed explicitly because the pure function cannot reach the catalog (the N2212 per-def-param precedent); the Block default is 10 (Block.java:75).', source=BLOCKS),
        'has_dominant_item': a('bool', 'public Item dominantItem;', 'Whether the drill has a dominant item bound: dominantItem is `public Item dominantItem;` (Drill.java:244), set by the N2262 ore/dominant binding; shouldConsume requires `dominantItem != null` (Drill.java:248); passed explicitly because the frame carries no dominant-item id yet (the N2341 drawSelect precedent).'),
    }
    should_consume_outputs = {
        'should_consume': a('bool', 'return items.total() < itemCapacity && enabled && dominantItem != null;', 'The shouldConsume gate (Drill.java:247-249): items_total < item_capacity && enabled && has_dominant_item; false gates efficiency to 0 via updateConsumption (BuildingComp.java:1960 + 1992-1993).', source=DRILL),
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
        ('N2338', SHOULD_CONSUME_OWNER, 'source_drill_should_consume_state', DRILL, 'mindustry.world.blocks.production.Drill$DrillBuild', 'DrillBuild.shouldConsume()', should_consume_inputs, should_consume_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed DrillBuild shouldConsume() gate from Drill.java + BurstDrill.java + BuildingComp.java + Block.java + Blocks.java + ItemModule.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed DrillBuild shouldConsume() gate from Drill.java + BurstDrill.java + BuildingComp.java + Block.java + Blocks.java + ItemModule.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the gate, its only result key.
    by_slice['N2338'] = [
        'source_drill_should_consume_state_result.should_consume',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2338', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill$DrillBuild', java_method='DrillBuild.shouldConsume()', godot_owner=SHOULD_CONSUME_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2338'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
