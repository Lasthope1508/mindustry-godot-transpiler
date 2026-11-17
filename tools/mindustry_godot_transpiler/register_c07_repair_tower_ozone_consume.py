"""Register the RepairTower ozone consumer (N2229).

The ozone liquid consumer of RepairTower
(`consumeLiquid(Liquids.ozone, 3f / 60f);`,
Blocks.java:6583, amount 0.05f/tick): the ConsumeLiquid.efficiency
fold (ConsumeLiquid.java:42-48) into the first pass plus the
ConsumeLiquid.update drain (ConsumeLiquid.java:37-38) in the
second pass (BuildingComp.java:1969-1976 / 1997-2000). The power
row is N2153, the shouldConsume gate N2191, the refresh N2190,
the driver stamp of the live nearby-damaged count N2211 and the
heal advance N2228.

RED decisions (resolved at RED): (1) Two pure functions on
SourceRepairTowerBuildState.gd, because Java calls them at two
different times (first pass vs second pass): the row function
source_repair_tower_ozone_row_state(frame, delta) returning
`{"has_ozone_row": ..., "row": {"result": ..., "is_power":
false}}`, and the consume function
source_repair_tower_ozone_consume_state(frame, delta) returning
`{"ozone_drained": ..., "liquids": ...}`. The row goes through
the generic helper SourceConsumeLiquidState.efficiency_state
(the N2007 drill precedent -- it mirrors
ConsumeLiquid.efficiency exactly, including the epsilon guard
and the cap at 1): ed = delta * efficiency_scale, because the
first pass assumes efficiency 1 (`efficiency =
optionalEfficiency = 1f;`, BuildingComp.java:1966,
`//assume efficiency is 1 for the calculations below`, :1967)
and efficiencyScale() defaults 1f (BuildingComp.java:1940-1942).
The drain does NOT use the generic update_state, because that
helper takes a numeric liquid_id the frame never carries (the
frame keys liquids by slug, "ozone"), so the drain inlines the
3 lines like the N2187 cryofluid precedent: drain = 0.05 *
folded efficiency * delta, clamped at the stock
(LiquidModule.java:125-127, `//cap to prevent negative
removal`). (2) Absent key "ozone" in frame["liquids"] means NO
observation, NOT an empty tank (the N2191 precedent, settled):
has_ozone_row false, the power-only fold is kept (folding
absent to 0 would zero efficiency for every live tower), drain
0 and the dict unchanged; a present {"ozone": 0.0} (observed
empty tank) folds to result 0.0. (3) delta is the driver
seconds (the N2228 precedent -- no separate time_scale, unlike
N2187; timeScale != 1 stays deferred). (4) The driver calls
the row before update_consumption_state (appending the row to
required_results beside the power row) and the consume after
apply_update_consumption_state, before the refresh / heal (Java
runs updateConsumption() :2274 before updateTile() :2277,
BuildingComp.java), ensuring frame["liquids"] is a Dictionary
first (the N2187 precedent) and stamping frame["ozone_drained"]
and frame["liquids"] live. A non-power row <= 1e-7 clears
should_consume_power (`if(cons != block.consPower && result <=
0.0000001f){`, BuildingComp.java:1972-1974, mirrored by
update_consumption_non_optional_pass_state). Four new result
symbols: has_ozone_row + row + ozone_drained + liquids. Slice
sources: RepairTower.java + ConsumeLiquid.java + Consume.java +
BuildingComp.java + LiquidModule.java + Blocks.java. Shard note:
unlike N2219-N2228 (whose java_source is RepairTower.java),
N2229's java_source IS ConsumeLiquid.java, so the
`consumer_slices` shard selects it (selection: java_source
contains `/world/consumers/`) and mirrors `generated_owner` --
a hand-written slice has no codegen owner, so the entry carries
`generated_owner: ''`, the N2007 precedent (the only other
hand-written consumer slice; its shard entry mirrors '').
Without the key the shard rebuild fails with KeyError:
'generated_owner'.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_tower_heal_advance import DEFERRED as N2228_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TOWER = 'core/src/mindustry/world/blocks/units/RepairTower.java'
CONSUME_LIQUID = 'core/src/mindustry/world/consumers/ConsumeLiquid.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
LIQUID_MODULE = 'core/src/mindustry/world/modules/LiquidModule.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07RepairTowerOzoneConsumeProof'
ROW_OWNER = 'SourceRepairTowerBuildState.source_repair_tower_ozone_row_state'
CONSUME_OWNER = 'SourceRepairTowerBuildState.source_repair_tower_ozone_consume_state'
TESTS = ['test_c07_repair_tower_ozone_consume_registration', 'test_all_c07_repair_tower_ozone_consume_input_evidence_is_exact', 'test_repair_tower_ozone_consume_state', 'test_reference_graph_and_actual_c07_repair_tower_ozone_consume']
# The 6 slice sources the N2229 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTower.java',
    'core/src/mindustry/world/consumers/ConsumeLiquid.java',
    'core/src/mindustry/world/consumers/Consume.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/modules/LiquidModule.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public class RepairTower extends Block{', 'consumeLiquid(Liquids.ozone, 3f / 60f);', 'range = 100f;', 'healAmount = 1.5f;', 'public void update(Building build){', 'build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', 'public float efficiency(Building build){', 'float ed = build.edelta() * build.efficiencyScale();', 'if(ed <= 0.00000001f) return 0f;', '//there can be more liquid than necessary, so cap at 1', 'return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);', 'public boolean update = true;', 'public Floatf<Building> multiplier = b -> 1f;', 'efficiency = optionalEfficiency = 1f;', '//assume efficiency is 1 for the calculations below', 'minEfficiency = Math.min(minEfficiency, result);', 'if(cons != block.consPower && result <= 0.0000001f){', 'shouldConsumePower = false;', 'if(update && efficiency > 0){', 'for(var cons : block.updateConsumers){', 'cons.update(self());', 'public float delta(){', 'return Time.delta * timeScale;', 'public float edelta(){', 'return efficiency * delta();', 'public float efficiencyScale(){', 'return 1f;', 'updateConsumption();', 'updateTile();', '//cap to prevent negative removal', 'add(liquid, Math.max(-amount, -liquids[liquid.id]));', 'public float get(Liquid liquid){', 'return liquids[liquid.id];']

# DEFERRED is carried from the N2228 register script via import --
# never retyped. The N2228 script's DEFERRED is a computed
# expression (list(...) + [...]), NOT a plain list literal, so the
# N2218-style ast.literal_eval carry cannot recover it; the import
# recovers the runtime value verbatim. The carried RepairTower
# ozone entry is DROPPED here (this slice closes it) and replaced
# by the new entries below; every other entry is carried verbatim
# (the N2211/N2228 lesson -- never retype the pool).
DEFERRED = [e for e in N2228_DEFERRED if 'RepairTower liquid consumer row' not in e] + [
    'RepairTower ozone consumer Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2228: the N2229 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Live liquid-stock observation -- no tick stamps a real LiquidModule stock into frame["liquids"] of a placed building; when that slice lands, the N2229 absent-guard automatically activates the real fold on live towers.',
    'RepairTower timeScale != 1 (BuildingComp.java:98, default 1f) -- N2229 uses the driver seconds like N2228, deferred from N2228.',
    'RepairTower draw() body / drawSelect() / setStats() / drawPlace() / accessors range()/warmup() -- deferred from N2228, still wait for their own slices.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    row_inputs = {
        'frame': a('Dictionary', 'public float efficiency(Building build){', 'The tower frame (ConsumeLiquid.java:42, `public float efficiency(Building build){` -- the frame carries the liquids dict keyed by liquid-name slug ("ozone") and the efficiency_scale stamped by the driver; absent key "ozone" means no observation, not an empty tank).', source=CONSUME_LIQUID),
        'delta': a('float', 'return efficiency * delta();', 'The tick delta in seconds (BuildingComp.java:1928, `return efficiency * delta();` -- the driver passes its per-tick seconds; the first pass assumes efficiency 1, BuildingComp.java:1966, so edelta is 1.0 * delta here).', source=BUILDING_COMP),
    }
    row_outputs = {
        'has_ozone_row': a('bool', 'public float get(Liquid liquid){', 'Whether an ozone observation exists: true only when frame["liquids"] is a Dictionary with key "ozone" (LiquidModule.java:102, `public float get(Liquid liquid){` -- the stock read; absent means no observation, so the row is skipped and the power-only fold is kept).', source=LIQUID_MODULE),
        'row': a('Dictionary', 'return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);', 'The ozone consumer row for the first-pass fold: {"result": fold, "is_power": false} (ConsumeLiquid.java:47 -- the fold is min(stock / (0.05 * ed * 1.0), 1.0), 0.0 when ed <= 1e-8; empty when no observation).', source=CONSUME_LIQUID),
    }
    consume_inputs = {
        'frame': a('Dictionary', 'public void update(Building build){', 'The tower frame (ConsumeLiquid.java:37, `public void update(Building build){` -- the frame carries the folded efficiency (stamped by apply_update_consumption_state) and the liquids dict; the drain reads both).', source=CONSUME_LIQUID),
        'delta': a('float', 'return efficiency * delta();', 'The tick delta in seconds (BuildingComp.java:1928, `return efficiency * delta();` -- the driver passes its per-tick seconds; the drain is 0.05 * folded efficiency * delta).', source=BUILDING_COMP),
    }
    consume_outputs = {
        'ozone_drained': a('float', 'build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', 'The ozone drained this tick: 0.05 * folded efficiency * delta, clamped at the stock (ConsumeLiquid.java:38 -- 0 when efficiency is 0, the tower is disabled, or no ozone observation exists).', source=CONSUME_LIQUID),
        'liquids': a('Dictionary', '//cap to prevent negative removal', 'The liquids dict after the drain: a duplicate with ["ozone"] reduced by the drained amount, never negative (LiquidModule.java:125-127, `//cap to prevent negative removal` -- unchanged when no ozone observation exists).', source=LIQUID_MODULE),
    }
    return row_inputs, row_outputs, consume_inputs, consume_outputs


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
    row_inputs, row_outputs, consume_inputs, consume_outputs = definitions()

    entries = [
        ('N2229', ROW_OWNER, 'source_repair_tower_ozone_row_state', CONSUME_LIQUID, 'mindustry.world.consumers.ConsumeLiquid', 'ConsumeLiquid.efficiency(Building)', row_inputs, row_outputs, True, 'Dictionary'),
        ('N2229', CONSUME_OWNER, 'source_repair_tower_ozone_consume_state', CONSUME_LIQUID, 'mindustry.world.consumers.ConsumeLiquid', 'ConsumeLiquid.update(Building)', consume_inputs, consume_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTower ozone consumer from ConsumeLiquid.java / Consume.java / BuildingComp.java / LiquidModule.java / Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTower ozone consumer from ConsumeLiquid.java / Consume.java / BuildingComp.java / LiquidModule.java / Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: has_ozone_row + row
    # (row function) + ozone_drained + liquids (consume
    # function).
    by_slice['N2229'] = [
        'source_repair_tower_ozone_row_state_result.has_ozone_row',
        'source_repair_tower_ozone_row_state_result.row',
        'source_repair_tower_ozone_consume_state_result.ozone_drained',
        'source_repair_tower_ozone_consume_state_result.liquids',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2229', dict(status='done', java_source=CONSUME_LIQUID, java_class='mindustry.world.consumers.ConsumeLiquid', java_method='ConsumeLiquid.efficiency(Building)', godot_owner=ROW_OWNER, generated_owner='', exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2229'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
