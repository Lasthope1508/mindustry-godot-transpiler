"""Register the BurstDrill setStats() liquid booster rows (N2266).

BurstDrill.setStats() (BurstDrill.java:58-68, `public void
setStats(){`) calls the Drill super (`super.setStats();` --
:59, NOT this slice) and, only when `liquidBoostIntensity !=
1` and a booster consumer is found (`if(liquidBoostIntensity
!= 1 && findConsumer(f -> f instanceof ConsumeLiquidBase &&
f.booster) instanceof ConsumeLiquidBase consBase){` -- :61),
removes the booster row (`stats.remove(Stat.booster);` --
:62) and re-adds it with the PLAIN intensity (`stats.add(
Stat.booster,` -- :63 -- `StatValues.speedBoosters("{0}" +
StatUnit.timesSpeed.localized(),` -- :64 --
`consBase.amount, liquidBoostIntensity, false,
consBase::consumes)` -- :65). The super's own booster row
uses the SQUARED intensity (`liquidBoostIntensity *
liquidBoostIntensity, false, consBase::consumes)`,
Drill.java:188), so the override's remove-then-add is what
makes the displayed speed the plain intensity, not the
square. The booster value builder is StatValues.speedBoosters
(StatValues.java:506, `public static StatValue
speedBoosters(String unit, float amount, float speed, boolean
strength, Boolf<Liquid> filter){`). The unit format is "{0} x
speed": StatUnit.timesSpeed is `timesSpeed = new
StatUnit("timesSpeed", false),` (StatUnit.java:34) and
localized() reads bundle key "unit.timesspeed"
(StatUnit.java:61-62), English value "x speed"
(bundle.properties:1364). `consBase.amount` is the per-frame
liquid amount (`public float amount;`,
ConsumeLiquidBase.java:8); `consBase::consumes` is the liquid
filter (`public abstract boolean consumes(Liquid liquid);`,
ConsumeLiquidBase.java:21); the `false` strength arg (:65)
means the displayed speed is the plain intensity, not
heatCapacity-scaled (StatValues.java:522). The booster filter
flag is `public boolean booster;` (Consume.java:14).
findConsumer (`public <T extends Consume> T findConsumer(
Boolf<Consume> filter){`, Block.java:1104) returns the first
consumer matching the filter.

RED decisions (resolved at RED): (1) One pure function on
the same family file N2149 / N2256 / N2258 / N2269 / N2262
built, after source_burst_drill_icons_state:
source_burst_drill_set_stats_state(frame,
liquid_boost_intensity, booster_consumer_found,
booster_amount, booster_consumes) returning
booster_row_removed (whether stats.remove(Stat.booster) ran
-- true exactly when the if-branch runs, i.e. the same
condition as the add) and booster_row (the speedBoosters row
dict {format, amount, intensity, strength, consumes}, or
null when the branch does not run). frame carries no live
keys for this block-level stat read -- liquidBoostIntensity
and the booster consumer are per-def static state, not live
frame keys (the N2212 / N2224 per-def-param precedent);
frame is the canonical first param of this family file.
(2) findConsumer is NOT ported in this slice: the caller
passes the already-found result (booster_consumer_found /
booster_amount / booster_consumes) -- the N1688/N1753
findConsumer precedent; the search order is deferred.
(3) There is NO driver tick line: setStats is a
stat-display read, not a tick write (the N2224 / N2246
setStats lifecycle precedent); the proof calls the pure
function directly with per-def params. (4) The
`super.setStats();` leg (BurstDrill.java:59) is Drill.setStats
(Drill.java:177-191), NOT this slice: the Drill drillSpeed
row and the squared-intensity booster row wait for their own
slice. Two new result symbols: booster_row_removed,
booster_row. Two defs share the function (impact-drill,
Blocks.java:3070, liquidBoostIntensity 1.75f, ozone booster
3f/60f; eruption-drill, Blocks.java:3093,
liquidBoostIntensity 2f, cyanogen booster 0.75f/60f); they
differ only in the per-def intensity and booster amount the
caller passes. Slice sources: BurstDrill.java + Drill.java +
Blocks.java + StatValues.java + StatUnit.java +
ConsumeLiquidBase.java + Block.java + Consume.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_burst_drill_on_proximity_update import DEFERRED as N2262_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BURST_DRILL = 'core/src/mindustry/world/blocks/production/BurstDrill.java'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
STAT_VALUES = 'core/src/mindustry/world/meta/StatValues.java'
STAT_UNIT = 'core/src/mindustry/world/meta/StatUnit.java'
CONSUME_LIQUID_BASE = 'core/src/mindustry/world/consumers/ConsumeLiquidBase.java'
BLOCK = 'core/src/mindustry/world/Block.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
PROOF = '/root/C07BurstDrillSetStatsProof'
SET_STATS_OWNER = 'SourceBurstDrillBuildState.source_burst_drill_set_stats_state'
TESTS = ['test_c07_burst_drill_set_stats_registration', 'test_all_c07_burst_drill_set_stats_input_evidence_is_exact', 'test_burst_drill_set_stats_state', 'test_reference_graph_and_actual_c07_burst_drill_set_stats']
# The 8 slice sources the N2266 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BurstDrill.java',
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/meta/StatValues.java',
    'core/src/mindustry/world/meta/StatUnit.java',
    'core/src/mindustry/world/consumers/ConsumeLiquidBase.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/world/consumers/Consume.java',
]
EXACT_EXPRS = ['public void setStats(){', 'super.setStats();', 'if(liquidBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){', 'stats.remove(Stat.booster);', 'stats.add(Stat.booster,', 'StatValues.speedBoosters("{0}" + StatUnit.timesSpeed.localized(),', 'consBase.amount, liquidBoostIntensity, false, consBase::consumes)', 'public class BurstDrill extends Drill{', 'public static StatValue speedBoosters(String unit, float amount, float speed, boolean strength, Boolf<Liquid> filter){', 'timesSpeed = new StatUnit("timesSpeed", false),', 'public float liquidBoostIntensity = 1.6f;', 'liquidBoostIntensity = 1.75f;', 'liquidBoostIntensity = 2f;', 'consumeLiquid(Liquids.ozone, 3f / 60f).boost();', 'consumeLiquid(Liquids.cyanogen, 0.75f / 60f).boost();', 'liquidBoostIntensity * liquidBoostIntensity, false, consBase::consumes)', 'public abstract boolean consumes(Liquid liquid);', 'public <T extends Consume> T findConsumer(Boolf<Consume> filter){', 'public boolean booster;']

# DEFERRED is carried from the N2262 register script via import --
# never retyped. The N2262 script's DEFERRED is a computed
# expression (list comprehension over the N2269 import + [...]),
# NOT a plain list literal, so the N2218-style ast.literal_eval
# carry cannot recover it (ValueError: malformed node); the
# import recovers the runtime value verbatim. NOTE for the next
# slice: N2266's DEFERRED is likewise a computed list(...) + [...]
# expression, so carry it forward by import too, not by
# ast.literal_eval.
# No carried entry is dropped here: the carried 'BurstDrill
# setStats booster display row (Drill.java:183-189...)' entry is
# about the Drill SUPER's booster row, which N2266 does NOT close
# (the super leg stays deferred) -- only the BurstDrill override
# rows close here.
DEFERRED = list(N2262_DEFERRED) + [
    'BurstDrill setStats() Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2227: the N2266 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BurstDrill setStats() super leg (Drill.setStats, Drill.java:177-191: drillSpeed row `stats.add(Stat.drillSpeed, 60f / drillTime * size * size, StatUnit.itemsSecond);` plus the squared-intensity booster row) -- the N2266 pure function models only the BurstDrill override rows; the Drill super rows wait for their own slice.',
    'BurstDrill findConsumer search order (first ConsumeLiquidBase with booster, Block.java:1104 `public <T extends Consume> T findConsumer(Boolf<Consume> filter){`) -- the N2266 pure function takes the found consumer as explicit inputs; the search itself is not verified here.',
    'BurstDrill setStats() localized unit rendering (StatUnit.timesSpeed.localized() reads bundle "unit.timesspeed", English "x speed", bundle.properties:1364) -- the N2266 proof pins the English bundle value; other locales wait for their own slice.',
]


def definitions():
    def a(typ, expr, rule, source=BURST_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    set_stats_inputs = {
        'frame': a('Dictionary', 'public void setStats(){', 'The burst-drill frame (BurstDrill.setStats, BurstDrill.java:58): carries no live keys for this block-level stat read -- liquidBoostIntensity and the booster consumer are per-def static state, not live frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file.'),
        'liquid_boost_intensity': a('float', 'public float liquidBoostIntensity = 1.6f;', 'The per-def liquid boost intensity (Drill.java:38, `public float liquidBoostIntensity = 1.6f;`, the class default; impact-drill 1.75f, Blocks.java:3084; eruption-drill 2f, Blocks.java:3115); the setStats guard reads `liquidBoostIntensity != 1` (BurstDrill.java:61); passed explicitly because it is per-def static state, not a live frame key (the N2212 / N2224 per-def-param precedent).', source=DRILL),
        'booster_consumer_found': a('bool', 'if(liquidBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){', 'Whether findConsumer found a booster consumer: the first consumer matching `f instanceof ConsumeLiquidBase && f.booster` (BurstDrill.java:61, via Block.java:1104 `public <T extends Consume> T findConsumer(Boolf<Consume> filter){`); passed explicitly because findConsumer is not ported in this slice (the N1688/N1753 precedent).'),
        'booster_amount': a('float', 'public float amount;', 'The found booster consumer amount per frame (ConsumeLiquidBase.java:8, `public float amount;`, the amount used per frame); the speedBoosters amount param (`consBase.amount, liquidBoostIntensity, false, consBase::consumes)`, BurstDrill.java:65): 3f/60f ozone for the impact-drill def (Blocks.java:3090) and 0.75f/60f cyanogen for the eruption-drill def (Blocks.java:3120); passed explicitly with the found consumer.', source=CONSUME_LIQUID_BASE),
        'booster_consumes': a('bool', 'public abstract boolean consumes(Liquid liquid);', 'The found booster consumer liquid filter result (ConsumeLiquidBase.java:21, `public abstract boolean consumes(Liquid liquid);`, the `consBase::consumes` method reference, BurstDrill.java:65); the speedBoosters filter param; passed explicitly with the found consumer.', source=CONSUME_LIQUID_BASE),
    }
    set_stats_outputs = {
        'booster_row_removed': a('bool', 'stats.remove(Stat.booster);', 'Whether stats.remove(Stat.booster) ran: true exactly when the if-branch runs (BurstDrill.java:62, `stats.remove(Stat.booster);`, inside the `liquidBoostIntensity != 1` + booster-found guard at :61) -- the remove runs before the add, so the displayed booster row is the override row, not the super row.'),
        'booster_row': a('Variant', 'StatValues.speedBoosters("{0}" + StatUnit.timesSpeed.localized(),', 'The Stat.booster row added by the override, or null when the branch does not run: {format "{0} x speed", amount consBase.amount, intensity liquidBoostIntensity (PLAIN, not the super squared value, Drill.java:188), strength false, consumes consBase::consumes} (BurstDrill.java:63-65, `stats.add(Stat.booster,` + `StatValues.speedBoosters("{0}" + StatUnit.timesSpeed.localized(),` + `consBase.amount, liquidBoostIntensity, false, consBase::consumes)`; the format is "{0} x speed" because StatUnit.timesSpeed.localized() reads bundle key "unit.timesspeed", English value "x speed").'),
    }
    return set_stats_inputs, set_stats_outputs


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
    set_stats_inputs, set_stats_outputs = definitions()

    entries = [
        ('N2266', SET_STATS_OWNER, 'source_burst_drill_set_stats_state', BURST_DRILL, 'mindustry.world.blocks.production.BurstDrill', 'BurstDrill.setStats()', set_stats_inputs, set_stats_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BurstDrill setStats() state from BurstDrill.java + Drill.java + Blocks.java + StatValues.java + StatUnit.java + ConsumeLiquidBase.java + Block.java + Consume.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BurstDrill setStats() state from BurstDrill.java + Drill.java + Blocks.java + StatValues.java + StatUnit.java + ConsumeLiquidBase.java + Block.java + Consume.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: booster_row_removed, booster_row.
    by_slice['N2266'] = [
        'source_burst_drill_set_stats_state_result.booster_row_removed',
        'source_burst_drill_set_stats_state_result.booster_row',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2266', dict(status='done', java_source=BURST_DRILL, java_class='mindustry.world.blocks.production.BurstDrill', java_method='BurstDrill.setStats()', godot_owner=SET_STATS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2266'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
