"""Register the BurstDrill shouldConsume gate (N2295).

BurstDrillBuild overrides shouldConsume
(BurstDrill.java:128, `public boolean shouldConsume(){`
with `return items.total() <= itemCapacity -
dominantItems && enabled;`, BurstDrill.java:129) over the
items total (ItemModule.java:174, `public int total(){`
with `return total;`, ItemModule.java:175 -- the cached
total a fresh ItemModule starts at 0), the per-def item
capacity (`public int itemCapacity = 10;`, Block.java:75,
with `itemCapacity = 40;`, Blocks.java:3078, for
impact-drill and `itemCapacity = 60;`, Blocks.java:3107,
for eruption-drill), the dominant count (`public int
dominantItems;`, Drill.java:243, with `public Item
dominantItem;`, Drill.java:244) and the enabled flag
(`transient boolean enabled = true;`,
BuildingComp.java:77), and updateConsumption forces
efficiency to zero when the gate is false
(BuildingComp.java:1960, `boolean update = shouldConsume()
&& productionValid();` + 1992, `if(!update){` + 1993,
`efficiency = optionalEfficiency = 0f;`). The BuildingComp
default (`public boolean shouldConsume(){` with `return
enabled;`, BuildingComp.java:755-756) is what the
override replaces. The gate matters because with a full
item store Java efficiency is 0 while the port folds
power-only and reports 1.0 -- the N2149 gap this slice
closes once the frame carries the stamped totals. A
missing power stamp folds to 1.0 before the first graph
update, the assembler fold (UnitAssembler.java:469,
`float powerStatus = !enabled ? 0f : power == null ? 1f :
power.status;`), and the power consumer counts toward
hasConsumers (Block.java:1449, `hasConsumers =
consumers.length > 0;`); edelta() is efficiency * delta
(BuildingComp.java:1928, `return efficiency * delta();`).
The burst drill's power draw is STATIC: impact-drill
consumePower 160f/60f and eruption-drill consumePower 6f,
so the row read is the plain one (ConsumePower.java:39,
`return build.power.status;`) -- no RepairTurret-style
ConsumePowerCondition adaptation.

RED decisions (resolved at RED): (1) One pure function on
the same family file N2149/N2256 built, following the
N2191 RepairTower shouldConsume precedent:
source_burst_drill_should_consume_state(frame,
item_capacity) and the driver line replaces `var
should_consume: bool = bool(frame.get("enabled", true))`
BEFORE the consumption setup (the Java order,
updateConsumption :2274 reads shouldConsume() at :1960).
(2) The frame carries `items_total` (float, absent -> 0.0
-- a fresh ItemModule totals 0, the N2207 LaunchPad
precedent), `dominant_items` (int, absent -> 0,
`public int dominantItems;`, Drill.java:243) and `enabled`
(bool, absent -> true, `transient boolean enabled =
true;`, BuildingComp.java:77); the per-def item_capacity
is an explicit param (the N2212 / N2248 per-def-param
precedent). Absent keys mean "no observation yet", not
"full": the defaults make the bound read `0 <=
itemCapacity - 0`, so should_consume = enabled, the N2149
behavior preserved (the N2188 / N2191 absent-preserves
precedent) -- no placed-building frame carries live
items/dominant state until the ore/dominant binding slice
stamps it, and defaulting absent to false would zero
efficiency for every live burst drill. (3) The driver
reads the per-def itemCapacity from the catalog block
properties (`block.properties.get("itemCapacity",
source_block_defaults.ITEM_CAPACITY_DEFAULT)`, the
AdjacentFactory precedent, with the Block default 10,
Block.java:75) -- the catalog carries itemCapacity 40 for
impact-drill and 60 for eruption-drill, matching
Blocks.java:3078/3107. (4) The proof stamps
items_total / dominant_items on the live frame (the
binding slice will stamp them live later); the proof
carries no liquid / updateTile / ore-binding keys. One
new result symbol: the gate itself. Slice sources:
BurstDrill.java + Drill.java + BuildingComp.java +
Block.java + Blocks.java + ItemModule.java +
ConsumePower.java + UnitAssembler.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_burst_drill_update_tile import DEFERRED as N2294_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BURST_DRILL = 'core/src/mindustry/world/blocks/production/BurstDrill.java'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
ITEM_MODULE = 'core/src/mindustry/world/modules/ItemModule.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
PROOF = '/root/C07BurstDrillShouldConsumeProof'
SHOULD_CONSUME_OWNER = 'SourceBurstDrillBuildState.source_burst_drill_should_consume_state'
TESTS = ['test_c07_burst_drill_should_consume_registration', 'test_all_c07_burst_drill_should_consume_input_evidence_is_exact', 'test_burst_drill_should_consume_state', 'test_reference_graph_and_actual_c07_burst_drill_should_consume']
# The 8 slice sources the N2295 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BurstDrill.java',
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/modules/ItemModule.java',
    'core/src/mindustry/world/consumers/ConsumePower.java',
    'core/src/mindustry/world/blocks/units/UnitAssembler.java',
]
EXACT_EXPRS = ['public boolean shouldConsume(){', 'return items.total() <= itemCapacity - dominantItems && enabled;', 'public int dominantItems;', 'public Item dominantItem;', 'public int total(){', 'return total;', 'public int itemCapacity = 10;', 'itemCapacity = 40;', 'itemCapacity = 60;', 'transient boolean enabled = true;', 'boolean update = shouldConsume() && productionValid();', 'if(!update){', 'efficiency = optionalEfficiency = 0f;', 'return enabled;', 'hasConsumers = consumers.length > 0;', 'return build.power.status;', 'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', 'public class BurstDrill extends Drill{', 'public class BurstDrillBuild extends DrillBuild{', 'public class DrillBuild extends Building{', 'return efficiency * delta();']

# DEFERRED is carried from the N2294 register script via import --
# never retyped. One carried entry is DROPPED here, not carried:
# the BurstDrill shouldConsume gate entry -- N2295 IS the
# shouldConsume gate slice, so carrying it would leave a stale
# "waits for its own slice" row for done work. The liquid rows
# (N2258) and the ore / dominant-item binding entries stay
# deferred -- those slices own them.
DEFERRED = [e for e in N2294_DEFERRED if 'BurstDrill shouldConsume gate' not in e] + [
    'BurstDrill shouldConsume Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2294: the N2295 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BURST_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    should_consume_inputs = {
        'frame': a('Dictionary', 'return items.total() <= itemCapacity - dominantItems && enabled;', 'The burst-drill frame (BurstDrillBuild.shouldConsume, BurstDrill.java:128-129): carries items_total (float, absent -> 0.0 -- a fresh ItemModule totals 0, the N2207 LaunchPad precedent), dominant_items (int, absent -> 0, `public int dominantItems;`, Drill.java:243) and enabled (bool, absent -> true, `transient boolean enabled = true;`, BuildingComp.java:77); absent keys mean no observation yet, not full, so the gate preserves the N2149 behavior (should_consume = enabled).', source=BURST_DRILL),
        'item_capacity': a('float', 'itemCapacity = 40;', 'The per-def item capacity, 40 for the impact-drill def (Blocks.java:3078) and 60 for the eruption-drill def (Blocks.java:3107); passed explicitly because the pure function cannot reach the catalog (the N2212 per-def-param precedent); the driver reads it from the catalog block properties (the AdjacentFactory precedent).', source=BLOCKS),
    }
    should_consume_outputs = {
        'should_consume': a('bool', 'return items.total() <= itemCapacity - dominantItems && enabled;', 'The shouldConsume gate (BurstDrill.java:128-129): items_total <= item_capacity - dominant_items && enabled; false gates efficiency to 0 via updateConsumption (BuildingComp.java:1960 + 1992-1993).', source=BURST_DRILL),
    }
    return should_consume_inputs, should_consume_outputs


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
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
        total += len(keys)
        for field, meta in keys.items():
            source = meta['java_source']
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
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
        ('N2295', SHOULD_CONSUME_OWNER, 'source_burst_drill_should_consume_state', BURST_DRILL, 'mindustry.world.blocks.production.BurstDrill.BurstDrillBuild', 'BurstDrillBuild.shouldConsume()', should_consume_inputs, should_consume_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BurstDrill shouldConsume gate from BurstDrill.java + Drill.java + BuildingComp.java + Block.java + Blocks.java + ItemModule.java + ConsumePower.java + UnitAssembler.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BurstDrill shouldConsume gate from BurstDrill.java + Drill.java + BuildingComp.java + Block.java + Blocks.java + ItemModule.java + ConsumePower.java + UnitAssembler.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the gate, its only result key.
    by_slice['N2295'] = [
        'source_burst_drill_should_consume_state_result.should_consume',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2295', dict(status='done', java_source=BURST_DRILL, java_class='mindustry.world.blocks.production.BurstDrill.BurstDrillBuild', java_method='BurstDrillBuild.shouldConsume()', godot_owner=SHOULD_CONSUME_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2295'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
