"""Register the BurstDrill liquid rows (N2296).

Each BurstDrill def carries two ConsumeLiquid rows
(Blocks.java:3089-3090 impact, :3119-3120 eruption): one
required liquid and one booster liquid (.boost() makes it
optional, Consume.java:33-35, `public Consume boost(){` with
`return optional(true, true);`). BuildingComp.updateConsumption
(BuildingComp.java:1943-2004) folds the required row into the
first pass (BuildingComp.java:1969-1977, `for(var cons : block.
nonOptionalConsumers){` / `minEfficiency = Math.min(
minEfficiency, result);`) and the booster row into the optional
pass (BuildingComp.java:1980-1982, `for(var cons : block.
optionalConsumers){` / `optionalEfficiency = Math.min(
optionalEfficiency, cons.efficiency(self()));`), then assigns
`efficiency = minEfficiency;` / `optionalEfficiency = Math.min(
optionalEfficiency, minEfficiency);`
(BuildingComp.java:1985-1986) and runs the second pass
(`if(update && efficiency > 0){` / `for(var cons : block.
updateConsumers){`, BuildingComp.java:1999-2000). Each row's
efficiency is ConsumeLiquid.efficiency (ConsumeLiquid.java:42-46,
`float ed = build.edelta() * build.efficiencyScale();` /
`if(ed <= 0.00000001f) return 0f;` /
`return Math.min(build.liquids.get(liquid) / (amount * ed *
multiplier.get(build)), 1f);`) with edelta()
(BuildingComp.java:1928, `return efficiency * delta();`) and
the default cost multiplier (Consume.java:18, `public
Floatf<Building> multiplier = b -> 1f;` -- nothing overrides it
for burst drills), and each row's removal is ConsumeLiquid.update
(ConsumeLiquid.java:37-38, `build.liquids.remove(liquid, amount
* build.edelta() * multiplier.get(build));`). The booster row is
what feeds the speed fold (BurstDrill.java:94, `float speed =
Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) *
efficiency;`): without the booster liquid the drill runs at base
speed. The per-def rows are impact-drill water 10f/60f required
(Blocks.java:3089, `consumeLiquid(Liquids.water, 10f/60f);`) +
ozone 3f/60f booster (Blocks.java:3090,
`consumeLiquid(Liquids.ozone, 3f / 60f).boost();`) and
eruption-drill hydrogen 4f/60f required (Blocks.java:3119,
`consumeLiquid(Liquids.hydrogen, 4f / 60f);`) + cyanogen
0.75f/60f booster (Blocks.java:3120,
`consumeLiquid(Liquids.cyanogen, 0.75f / 60f).boost();`).

RED decisions (resolved at RED): (1) One pure function on the
same family file N2149/N2256 built, following the N2256
per-def-param precedent: (frame, delta, required_amount,
booster_amount) plus one driver line that folds the rows into
the consumption call when the frame carries liquid observations
(the BuildTurret precedent: a frame with no stored-amount keys
keeps the power-only fold instead of zeroing efficiency for
every live burst drill). (2) The frame carries `efficiency`
(float, absent -> 0.0, `transient float efficiency;`,
BuildingComp.java:85), `efficiency_scale` (float, absent ->
1.0, `public float efficiencyScale(){` with `return 1f;`,
BuildingComp.java:1939-1941), `required_liquid_stored` and
`booster_liquid_stored` (floats, absent -> 0.0 -- a fresh
LiquidModule holds 0 of every liquid). delta() is Time.delta *
timeScale (BuildingComp.java:1922-1923, `public float delta(){`
with `return Time.delta * timeScale;` -- timeScale is 1 by
default and the port passes the raw tick seconds, the N2190
driver convention). (3) Both efficiencies go through the port's
existing ConsumeLiquid efficiency_state helper (exact formula,
ed guard at 0.00000001f, cap at 1); both removals are amount *
edelta * the unit cost multiplier. (4) The driver resolves the
per-def amounts from the block's bound liquid consumers through
the generic N2003 binding, splitting the required row from the
booster row on the booster flag. (5) The removal application
(`build.liquids.remove(...)`) waits for the driver slice that
owns the liquids module; the remove_amount results are the
observable signal. The setStats booster display row
(Drill.java:183-189) is stats display, not tick state, and waits
for its own slice. Nine new result symbols: edelta, ed,
required_efficiency, booster_efficiency,
required_remove_amount, booster_remove_amount, required_row,
optional_row, has_liquids. Slice sources: BurstDrill.java +
Drill.java + BuildingComp.java + Block.java + Blocks.java +
ConsumeLiquid.java + ConsumeLiquidBase.java + Consume.java.
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
CONSUME_LIQUID = 'core/src/mindustry/world/consumers/ConsumeLiquid.java'
CONSUME_LIQUID_BASE = 'core/src/mindustry/world/consumers/ConsumeLiquidBase.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
PROOF = '/root/C07BurstDrillLiquidRowsProof'
LIQUID_ROWS_OWNER = 'SourceBurstDrillBuildState.source_burst_drill_liquid_rows_state'
TESTS = ['test_c07_burst_drill_liquid_rows_registration', 'test_all_c07_burst_drill_liquid_rows_input_evidence_is_exact', 'test_burst_drill_liquid_rows_state', 'test_reference_graph_and_actual_c07_burst_drill_liquid_rows']
# The 8 slice sources the N2296 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BurstDrill.java',
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/consumers/ConsumeLiquid.java',
    'core/src/mindustry/world/consumers/ConsumeLiquidBase.java',
    'core/src/mindustry/world/consumers/Consume.java',
]
EXACT_EXPRS = ['float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;', 'public float liquidBoostIntensity = 1.6f;', 'liquidBoostIntensity = 1.75f;', 'liquidBoostIntensity = 2f;', 'consumeLiquid(Liquids.water, 10f/60f);', 'consumeLiquid(Liquids.ozone, 3f / 60f).boost();', 'consumeLiquid(Liquids.hydrogen, 4f / 60f);', 'consumeLiquid(Liquids.cyanogen, 0.75f / 60f).boost();', 'public float amount;', 'block.hasLiquids = true;', 'public boolean optional;', 'public boolean booster;', 'public Floatf<Building> multiplier = b -> 1f;', 'public Consume boost(){', 'return optional(true, true);', 'block.liquidFilter[liquid.id] = true;', 'build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', 'float ed = build.edelta() * build.efficiencyScale();', 'if(ed <= 0.00000001f) return 0f;', 'return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);', 'stats.add(booster ? Stat.booster : Stat.input, liquid, amount * 60f, true);', 'return liquid == this.liquid;', 'public float delta(){', 'return Time.delta * timeScale;', 'public float edelta(){', 'return efficiency * delta();', 'public float efficiencyScale(){', 'transient float efficiency;', 'transient float optionalEfficiency;', 'for(var cons : block.nonOptionalConsumers){', 'minEfficiency = Math.min(minEfficiency, result);', 'for(var cons : block.optionalConsumers){', 'optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));', 'efficiency = minEfficiency;', 'optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);', 'potentialEfficiency = efficiency;', 'if(update && efficiency > 0){', 'for(var cons : block.updateConsumers){', 'public @NoPatch boolean hasLiquids;', 'hasConsumers = consumers.length > 0;', 'if(liquidBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){', 'public void updateTile(){', 'public class BurstDrill extends Drill{', 'public class BurstDrillBuild extends DrillBuild{', 'public class DrillBuild extends Building{']

# DEFERRED is carried from the N2294 register script via import --
# never retyped. One carried entry is DROPPED here, not carried:
# the BurstDrill liquid rows entry -- N2296 IS the liquid rows
# slice, so carrying it would leave a stale "waits for its own
# slice" row for done work. The shouldConsume gate (N2257) and
# the ore / dominant-item binding entries stay deferred -- those
# slices own them.
DEFERRED = [e for e in N2294_DEFERRED if 'BurstDrill liquid rows' not in e] + [
    'BurstDrill liquid rows Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2227: the N2296 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BurstDrill liquid removal application (liquids.remove, ConsumeLiquid.java:37-38) -- the N2296 proof carries remove_amount keys; the actual removal from the building liquid module waits for the driver slice that owns the liquids module.',
    'BurstDrill setStats booster display row (Drill.java:183-189, stats.add(Stat.booster, StatValues.speedBoosters(...))) -- stats display, not tick state; waits for its own slice.',
    'BurstDrill liquid rows without a power consumer -- the fold runs through the existing consumption call site, which today runs only when the def has a power consumer; both burst defs have power.',
]


def definitions():
    def a(typ, expr, rule, source=BURST_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    liquid_rows_inputs = {
        'frame': a('Dictionary', 'public void updateTile(){', 'The burst-drill frame (BurstDrillBuild.updateTile, BurstDrill.java:76): carries efficiency (float, absent -> 0.0), efficiency_scale (float, absent -> 1.0), required_liquid_stored and booster_liquid_stored (floats, absent -> 0.0).', source=BURST_DRILL),
        'delta': a('float', 'return Time.delta * timeScale;', 'The tick seconds: delta() is Time.delta * timeScale (BuildingComp.java:1922-1923); timeScale is 1 by default and the port passes the raw tick seconds (the N2190 driver convention).', source=BUILDING_COMP),
        'required_amount': a('float', 'consumeLiquid(Liquids.water, 10f/60f);', 'The per-def required liquid amount per frame, 10f/60f water for the impact-drill def (Blocks.java:3089) and 4f/60f hydrogen for the eruption-drill def (Blocks.java:3119); passed explicitly because the catalog carries no per-row amount on the frame (the N2212 per-def-param precedent).', source=BLOCKS),
        'booster_amount': a('float', 'consumeLiquid(Liquids.ozone, 3f / 60f).boost();', 'The per-def booster liquid amount per frame, 3f/60f ozone for the impact-drill def (Blocks.java:3090) and 0.75f/60f cyanogen for the eruption-drill def (Blocks.java:3120); passed explicitly because the catalog carries no per-row amount on the frame (the N2212 per-def-param precedent).', source=BLOCKS),
    }
    liquid_rows_outputs = {
        'edelta': a('float', 'return efficiency * delta();', 'The scaled delta this tick: efficiency * delta() (edelta, BuildingComp.java:1928).', source=BUILDING_COMP),
        'ed': a('float', 'float ed = build.edelta() * build.efficiencyScale();', 'The guarded ed this tick: edelta * efficiencyScale (ConsumeLiquid.java:43); at or below 0.00000001f both row efficiencies are 0.', source=CONSUME_LIQUID),
        'required_efficiency': a('float', 'return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);', 'The required liquid row efficiency: the stored required liquid over the required amount, capped at 1 (ConsumeLiquid.efficiency, ConsumeLiquid.java:42-46); folds into the first pass (BuildingComp.java:1969-1977).', source=CONSUME_LIQUID),
        'booster_efficiency': a('float', 'return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);', 'The booster liquid row efficiency: the stored booster liquid over the required amount, capped at 1 (ConsumeLiquid.efficiency, ConsumeLiquid.java:42-46); folds into the optional pass (BuildingComp.java:1980-1982) and feeds the speed fold (BurstDrill.java:94).', source=CONSUME_LIQUID),
        'required_remove_amount': a('float', 'build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', 'The required liquid removed this tick: amount * edelta * the unit cost multiplier (ConsumeLiquid.update, ConsumeLiquid.java:37-38); the observable -- the actual liquids.remove application waits for the driver slice that owns the liquids module.', source=CONSUME_LIQUID),
        'booster_remove_amount': a('float', 'build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', 'The booster liquid removed this tick: amount * edelta * the unit cost multiplier (ConsumeLiquid.update, ConsumeLiquid.java:37-38); the observable -- the actual liquids.remove application waits for the driver slice that owns the liquids module.', source=CONSUME_LIQUID),
        'required_row': a('Dictionary', 'for(var cons : block.nonOptionalConsumers){', 'The driver row for the required liquid: {result: required_efficiency, is_power: false}, folded into the non-optional results of updateConsumption (BuildingComp.java:1969-1977).', source=BUILDING_COMP),
        'optional_row': a('Dictionary', 'for(var cons : block.optionalConsumers){', 'The driver row for the booster liquid: {result: booster_efficiency}, folded into the optional results of updateConsumption (BuildingComp.java:1980-1982).', source=BUILDING_COMP),
        'has_liquids': a('bool', 'block.hasLiquids = true;', 'Whether the block carries liquids: true, ConsumeLiquidBase.apply sets block.hasLiquids (ConsumeLiquidBase.java:17-19).', source=CONSUME_LIQUID_BASE),
    }
    return liquid_rows_inputs, liquid_rows_outputs


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
    liquid_rows_inputs, liquid_rows_outputs = definitions()

    entries = [
        ('N2296', LIQUID_ROWS_OWNER, 'source_burst_drill_liquid_rows_state', BURST_DRILL, 'mindustry.world.blocks.production.BurstDrill.BurstDrillBuild', 'BurstDrillBuild.updateTile()', liquid_rows_inputs, liquid_rows_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BurstDrill liquid rows from BurstDrill.java + Drill.java + BuildingComp.java + Block.java + Blocks.java + ConsumeLiquid.java + ConsumeLiquidBase.java + Consume.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BurstDrill liquid rows from BurstDrill.java + Drill.java + BuildingComp.java + Block.java + Blocks.java + ConsumeLiquid.java + ConsumeLiquidBase.java + Consume.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: edelta, ed,
    # required_efficiency, booster_efficiency,
    # required_remove_amount, booster_remove_amount,
    # required_row, optional_row, has_liquids.
    by_slice['N2296'] = [
        'source_burst_drill_liquid_rows_state_result.edelta',
        'source_burst_drill_liquid_rows_state_result.ed',
        'source_burst_drill_liquid_rows_state_result.required_efficiency',
        'source_burst_drill_liquid_rows_state_result.booster_efficiency',
        'source_burst_drill_liquid_rows_state_result.required_remove_amount',
        'source_burst_drill_liquid_rows_state_result.booster_remove_amount',
        'source_burst_drill_liquid_rows_state_result.required_row',
        'source_burst_drill_liquid_rows_state_result.optional_row',
        'source_burst_drill_liquid_rows_state_result.has_liquids',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2296', dict(status='done', java_source=BURST_DRILL, java_class='mindustry.world.blocks.production.BurstDrill.BurstDrillBuild', java_method='BurstDrillBuild.updateTile()', godot_owner=LIQUID_ROWS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2296'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
