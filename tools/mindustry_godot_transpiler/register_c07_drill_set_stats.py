"""Register the Drill setStats() super leg (N2280).

Drill.setStats() (Drill.java:175-191, `public void
setStats(){`) calls the Block super (`super.setStats();`
-- :176, Block.setStats owned by N1696 at PortGame, NOT
this slice), adds the drillTier row (`stats.add(
Stat.drillTier, StatValues.drillables(drillTime,
hardnessDrillMultiplier, size * size, drillMultipliers,
b -> b instanceof Floor f && !f.wallOre && f.itemDrop !=
null && f.itemDrop.hardness <= tier && (blockedItems ==
null || !blockedItems.contains(f.itemDrop)) &&
(indexer.isBlockPresent(f) || state.isMenu())));` --
:178-179), adds the drillSpeed row (`stats.add(
Stat.drillSpeed, 60f / drillTime * size * size,
StatUnit.itemsSecond);` -- :181), and, only when
`liquidBoostIntensity != 1` and a booster consumer is
found (:183), removes the booster row (`stats.remove(
Stat.booster);` -- :184) and re-adds it with the SQUARED
intensity (`liquidBoostIntensity * liquidBoostIntensity,
false, consBase::consumes)` -- :188). The squared
intensity is the TRAP vs N2309, whose BurstDrill override
row uses the PLAIN intensity (BurstDrill.java:65); the
override removes this row first (BurstDrill.java:62) and
re-adds it plain, so the displayed speed is the plain
intensity, not the square. The drillables per-ore rate the
displayed table renders is `60f / (Math.max(drillTime +
drillMultiplier * block.itemDrop.hardness, drillTime) /
multipliers.get(block.itemDrop, 1f)) * size`
(StatValues.java:428); the filter's per-floor evaluation
(`indexer.isBlockPresent(f) || state.isMenu()`,
Drill.java:179) and the table iteration
(`content.blocks()`, StatValues.java:413-437) are
display-time, NOT this slice -- this function pins the
args setStats captures. The classes are `public class
Drill extends Block{` (Drill.java:27). Per-def values: the
class defaults are `public float
hardnessDrillMultiplier = 50f;` (Drill.java:28), `public
int tier;` (Drill.java:34, no default -- Java int default
0), `public float drillTime = 300;` (Drill.java:36),
`public float liquidBoostIntensity = 1.6f;`
(Drill.java:38); impact-drill `drillTime = 60f * 12f;`
(Blocks.java:3072, 720f), size 4, tier 6, beryllium
multiplier 2f, `liquidBoostIntensity = 1.75f;`, ozone
booster 3f/60f; eruption-drill `drillTime = 281.25f;`,
size 5, tier 7, beryllium multiplier 2f,
`liquidBoostIntensity = 2f;`, cyanogen booster 0.75f/60f.

RED decisions (resolved at RED): (1) One pure function on
the same family file N2149 / N2256 / N2258 / N2312 / N2262 /
N2309 / N2317 / N2277 built, after
source_burst_drill_set_stats_state:
source_drill_set_stats_state(frame, drill_time,
hardness_drill_multiplier, size, tier, drill_multipliers,
blocked_items, liquid_boost_intensity,
booster_consumer_found, booster_amount, booster_consumes)
returning drill_tier_row (the drillables call args:
drill_time, hardness_drill_multiplier, size_squared,
drill_multipliers, tier, blocked_items), drill_speed_row
({value 60/drillTime*size^2, unit "items/second"}),
booster_row_removed (whether stats.remove(Stat.booster)
ran -- true exactly when the if-branch runs) and
booster_row (the speedBoosters row dict {format, amount,
intensity SQUARED, strength, consumes}, or null when the
branch does not run). frame carries no live keys for this
block-level stat read -- the drill params and the booster
consumer are per-def static state, not live frame keys
(the N2212 / N2224 per-def-param precedent); frame is the
canonical first param of this family file. (2)
findConsumer is NOT ported in this slice: the caller
passes the already-found result (booster_consumer_found /
booster_amount / booster_consumes) -- the N1688/N1753
findConsumer precedent; the search order is deferred.
(3) There is NO driver tick line: setStats is a
stat-display read, not a tick write (the N2224 / N2246
setStats lifecycle precedent); the proof calls the pure
function directly with per-def params. (4) The
`super.setStats();` leg (Drill.java:176) is Block.setStats,
owned by N1696 at PortGame -- NOT this slice. This slice
CLOSES the super-leg deferred entry N2309 carried. Four
new result symbols: drill_tier_row, drill_speed_row,
booster_row_removed, booster_row. Two defs share the
function (impact-drill, Blocks.java:3070, drillTime 720f,
size 4, tier 6, intensity 1.75f, ozone booster 3f/60f;
eruption-drill, Blocks.java:3093, drillTime 281.25f, size
5, tier 7, intensity 2f, cyanogen booster 0.75f/60f); they
differ only in the per-def params the caller passes.
Slice sources: Drill.java + Blocks.java + StatValues.java +
StatUnit.java + ConsumeLiquidBase.java + Block.java +
Consume.java + Stat.java + bundle.properties.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_burst_drill_set_stats import DEFERRED as N2309_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
STAT_VALUES = 'core/src/mindustry/world/meta/StatValues.java'
STAT_UNIT = 'core/src/mindustry/world/meta/StatUnit.java'
CONSUME_LIQUID_BASE = 'core/src/mindustry/world/consumers/ConsumeLiquidBase.java'
BLOCK = 'core/src/mindustry/world/Block.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
STAT = 'core/src/mindustry/world/meta/Stat.java'
BUNDLE = 'core/assets/bundles/bundle.properties'
PROOF = '/root/C07DrillSetStatsProof'
SET_STATS_OWNER = 'SourceBurstDrillBuildState.source_drill_set_stats_state'
TESTS = ['test_c07_drill_set_stats_registration', 'test_all_c07_drill_set_stats_input_evidence_is_exact', 'test_drill_set_stats_state', 'test_reference_graph_and_actual_c07_drill_set_stats']
# The 9 slice sources the N2280 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/meta/StatValues.java',
    'core/src/mindustry/world/meta/StatUnit.java',
    'core/src/mindustry/world/consumers/ConsumeLiquidBase.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/world/consumers/Consume.java',
    'core/src/mindustry/world/meta/Stat.java',
    'core/assets/bundles/bundle.properties',
]
EXACT_EXPRS = ['public void setStats(){', 'super.setStats();', 'stats.add(Stat.drillTier, StatValues.drillables(drillTime, hardnessDrillMultiplier, size * size, drillMultipliers, b -> b instanceof Floor f && !f.wallOre && f.itemDrop != null &&', 'f.itemDrop.hardness <= tier && (blockedItems == null || !blockedItems.contains(f.itemDrop)) && (indexer.isBlockPresent(f) || state.isMenu())));', 'stats.add(Stat.drillSpeed, 60f / drillTime * size * size, StatUnit.itemsSecond);', 'if(liquidBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){', 'stats.remove(Stat.booster);', 'StatValues.speedBoosters("{0}" + StatUnit.timesSpeed.localized(),', 'liquidBoostIntensity * liquidBoostIntensity, false, consBase::consumes)', 'public class Drill extends Block{', 'public float hardnessDrillMultiplier = 50f;', 'public int tier;', 'public float drillTime = 300;', 'public float liquidBoostIntensity = 1.6f;', 'public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();', 'public @Nullable Seq<Item> blockedItems;', 'public static StatValue drillables(float drillTime, float drillMultiplier, float size, ObjectFloatMap<Item> multipliers, Boolf<Block> filter){', 'b.add(Strings.autoFixed(60f / (Math.max(drillTime + drillMultiplier * block.itemDrop.hardness, drillTime) / multipliers.get(block.itemDrop, 1f)) * size, 2) + StatUnit.perSecond.localized())', 'itemsSecond = new StatUnit("itemsSecond"),', 'unit.itemssecond = items/second', 'timesSpeed = new StatUnit("timesSpeed", false),', 'drillTier = new Stat("drillTier", StatCat.crafting),', 'drillSpeed = new Stat("drillSpeed", StatCat.crafting),', 'public int size = 1;', 'size = 4;', 'size = 5;', 'drillTime = 60f * 12f;', 'drillTime = 281.25f;', 'tier = 6;', 'tier = 7;', 'drillMultipliers.put(Items.beryllium, 2f);', 'liquidBoostIntensity = 1.75f;', 'liquidBoostIntensity = 2f;', 'consumeLiquid(Liquids.ozone, 3f / 60f).boost();', 'consumeLiquid(Liquids.cyanogen, 0.75f / 60f).boost();', 'public abstract boolean consumes(Liquid liquid);', 'public <T extends Consume> T findConsumer(Boolf<Consume> filter){', 'public boolean booster;', 'public float amount;']

# DEFERRED is carried from the N2309 register script via import --
# never retyped. The N2309 script's DEFERRED is a computed
# expression (list(...) + [...]), NOT a plain list literal, so
# the N2218-style ast.literal_eval carry cannot recover it
# (ValueError: malformed node); the import recovers the runtime
# value verbatim. One carried entry is DROPPED here, not carried:
# the BurstDrill setStats() super leg entry -- N2280 IS the
# super-leg slice, so carrying it would leave a stale "waits for
# its own slice" row for done work. The findConsumer search-order
# entry, the localized-unit entry and the N2309 Windows-proof debt
# stay deferred -- those slices own them.
DEFERRED = [e for e in N2309_DEFERRED if 'BurstDrill setStats() super leg' not in e] + [
    'Drill setStats() Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2227: the N2280 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Drill setStats() drillables table rendering (StatValues.drillables, StatValues.java:413-437: content.blocks() iteration + per-floor filter evaluation incl. indexer.isBlockPresent(f) / state.isMenu(), Drill.java:179) -- the N2280 pure function pins the drillables call args; the displayed per-ore table is rendered at display time, not by setStats.',
    'Drill setStats() localized unit rendering (StatUnit.itemsSecond.localized() reads bundle "unit.itemssecond", English "items/second", bundle.properties:1354) -- the N2280 proof pins the English bundle value; other locales wait for their own slice.',
]


def definitions():
    def a(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    set_stats_inputs = {
        'frame': a('Dictionary', 'public void setStats(){', 'The drill frame (Drill.setStats, Drill.java:175): carries no live keys for this block-level stat read -- drillTime, tier, size, drillMultipliers, blockedItems, liquidBoostIntensity and the booster consumer are per-def static state, not live frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file.'),
        'drill_time': a('float', 'public float drillTime = 300;', 'The base time to drill one ore, in frames (`public float drillTime = 300;`, Drill.java:36, the class default); impact-drill 60f*12f = 720f (Blocks.java:3072), eruption-drill 281.25f (Blocks.java:3095); passed explicitly because it is per-def static state (the N2212 / N2224 per-def-param precedent).'),
        'hardness_drill_multiplier': a('float', 'public float hardnessDrillMultiplier = 50f;', 'The hardness multiplier added per ore hardness in getDrillTime/drillables (`public float hardnessDrillMultiplier = 50f;`, Drill.java:28); the same class value for both defs; passed explicitly because it is per-def static state.'),
        'size': a('int', 'public int size = 1;', 'The block size in tiles (`public int size = 1;`, Block.java:215); the drillables call passes size * size and the drillSpeed row passes size * size (Drill.java:178, :181); impact-drill size 4 (Blocks.java:3073), eruption-drill size 5 (Blocks.java:3096); passed explicitly (the N2212 per-def-param precedent).', source=BLOCK),
        'tier': a('int', 'public int tier;', 'The maximum tier of blocks this drill can mine (`public int tier;`, Drill.java:34, no default -- Java int default 0); the drillables filter gates on `f.itemDrop.hardness <= tier` (Drill.java:179); impact-drill tier 6 (Blocks.java:3075), eruption-drill tier 7 (Blocks.java:3098); passed explicitly.'),
        'drill_multipliers': a('Dictionary', 'public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();', 'The per-item drill-time multipliers (`public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();`, Drill.java:66); both defs put beryllium 2f (`drillMultipliers.put(Items.beryllium, 2f);`, Blocks.java:3083/3113); passed explicitly as a Dictionary because it is per-def static state.'),
        'blocked_items': a('Variant', 'public @Nullable Seq<Item> blockedItems;', 'The items this drill cannot mine (`public @Nullable Seq<Item> blockedItems;`, Drill.java:44, set from blockedItem at :93-94); the drillables filter gates on `blockedItems == null || !blockedItems.contains(f.itemDrop)` (Drill.java:179); impact-drill blocks thorium (`blockedItem = Items.thorium;`, Blocks.java:3080), eruption-drill blocks nothing (null); passed explicitly as null or an Array.'),
        'liquid_boost_intensity': a('float', 'public float liquidBoostIntensity = 1.6f;', 'The per-def liquid boost intensity (Drill.java:38, `public float liquidBoostIntensity = 1.6f;`, the class default; impact-drill 1.75f, Blocks.java:3084; eruption-drill 2f, Blocks.java:3115); the setStats guard reads `liquidBoostIntensity != 1` (Drill.java:183); passed explicitly because it is per-def static state, not a live frame key (the N2212 / N2224 per-def-param precedent).'),
        'booster_consumer_found': a('bool', 'if(liquidBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){', 'Whether findConsumer found a booster consumer: the first consumer matching `f instanceof ConsumeLiquidBase && f.booster` (Drill.java:183, via Block.java:1104 `public <T extends Consume> T findConsumer(Boolf<Consume> filter){`); passed explicitly because findConsumer is not ported in this slice (the N1688/N1753 precedent).'),
        'booster_amount': a('float', 'public float amount;', 'The found booster consumer amount per frame (ConsumeLiquidBase.java:8, `public float amount;`, the amount used per frame); the speedBoosters amount param (`consBase.amount, liquidBoostIntensity * liquidBoostIntensity, false, consBase::consumes)`, Drill.java:188): 3f/60f ozone for the impact-drill def (Blocks.java:3090) and 0.75f/60f cyanogen for the eruption-drill def (Blocks.java:3120); passed explicitly with the found consumer.', source=CONSUME_LIQUID_BASE),
        'booster_consumes': a('bool', 'public abstract boolean consumes(Liquid liquid);', 'The found booster consumer liquid filter result (ConsumeLiquidBase.java:21, `public abstract boolean consumes(Liquid liquid);`, the `consBase::consumes` method reference, Drill.java:188); the speedBoosters filter param; passed explicitly with the found consumer.', source=CONSUME_LIQUID_BASE),
    }
    set_stats_outputs = {
        'drill_tier_row': a('Dictionary', 'stats.add(Stat.drillTier, StatValues.drillables(drillTime, hardnessDrillMultiplier, size * size, drillMultipliers, b -> b instanceof Floor f && !f.wallOre && f.itemDrop != null &&', 'The Stat.drillTier row added by Drill.setStats, pinning the StatValues.drillables call args (Drill.java:178-179): {drill_time, hardness_drill_multiplier, size_squared (the drillables size param is size * size), drill_multipliers, tier, blocked_items}; the per-floor filter evaluation and the displayed per-ore table render at display time (StatValues.java:413-437).'),
        'drill_speed_row': a('Dictionary', 'stats.add(Stat.drillSpeed, 60f / drillTime * size * size, StatUnit.itemsSecond);', 'The Stat.drillSpeed row added by Drill.setStats: {value 60f / drillTime * size * size, unit "items/second"} (Drill.java:181, `stats.add(Stat.drillSpeed, 60f / drillTime * size * size, StatUnit.itemsSecond);`; StatUnit.itemsSecond localized "items/second", bundle.properties:1354); class default 0.2, impact-drill 1.333..., eruption-drill 5.333....'),
        'booster_row_removed': a('bool', 'stats.remove(Stat.booster);', 'Whether stats.remove(Stat.booster) ran: true exactly when the if-branch runs (Drill.java:184, `stats.remove(Stat.booster);`, inside the `liquidBoostIntensity != 1` + booster-found guard at :183) -- the remove runs before the add, so the displayed booster row is the Drill super row until the BurstDrill override replaces it.'),
        'booster_row': a('Variant', 'liquidBoostIntensity * liquidBoostIntensity, false, consBase::consumes)', 'The Stat.booster row added by Drill.setStats, or null when the branch does not run: {format "{0} x speed", amount consBase.amount, intensity liquidBoostIntensity SQUARED (Drill.java:188 -- the trap vs the N2309 BurstDrill override row, which uses the PLAIN intensity, BurstDrill.java:65), strength false, consumes consBase::consumes} (Drill.java:185-189, `stats.add(Stat.booster,` + `StatValues.speedBoosters("{0}" + StatUnit.timesSpeed.localized(),` + `liquidBoostIntensity * liquidBoostIntensity, false, consBase::consumes)`; the format is "{0} x speed" because StatUnit.timesSpeed.localized() reads bundle key "unit.timesspeed", English value "x speed").'),
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
        ('N2280', SET_STATS_OWNER, 'source_drill_set_stats_state', DRILL, 'mindustry.world.blocks.production.Drill', 'Drill.setStats()', set_stats_inputs, set_stats_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Drill setStats() state from Drill.java + Blocks.java + StatValues.java + StatUnit.java + ConsumeLiquidBase.java + Block.java + Consume.java + Stat.java + bundle.properties.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Drill setStats() state from Drill.java + Blocks.java + StatValues.java + StatUnit.java + ConsumeLiquidBase.java + Block.java + Consume.java + Stat.java + bundle.properties.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: drill_tier_row, drill_speed_row, booster_row_removed, booster_row.
    by_slice['N2280'] = [
        'source_drill_set_stats_state_result.drill_tier_row',
        'source_drill_set_stats_state_result.drill_speed_row',
        'source_drill_set_stats_state_result.booster_row_removed',
        'source_drill_set_stats_state_result.booster_row',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2280', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill', java_method='Drill.setStats()', godot_owner=SET_STATS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2280'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
