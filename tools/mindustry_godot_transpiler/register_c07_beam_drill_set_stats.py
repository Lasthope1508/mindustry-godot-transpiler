"""Register the BeamDrill setStats() slice (N2388).

BeamDrill.setStats() (BeamDrill.java:119-137, `public void
setStats(){`) calls the Drill super (`super.setStats();`
-- :120, owned by N2332 at SourceBurstDrillBuildState, NOT
this slice), adds the drillTier row (`stats.add(
Stat.drillTier, StatValues.drillables(drillTime, 0f, size,
drillMultipliers, b ->` -- :122 -- the Floor leg :123 and
the StaticWall leg :124), adds the drillSpeed row
(`stats.add(Stat.drillSpeed, 60f / drillTime * size,
StatUnit.itemsSecond);` -- :127), and, only when
`optionalBoostIntensity != 1` and a booster consumer is
found (:129), REPLACES the booster row (`stats.replace(
Stat.booster,` -- :130 -- `consBase.amount,
optionalBoostIntensity, false, consBase::consumes)` --
:133) the super added. TWO traps vs Drill.setStats
(Drill.java:175-191): (1) BeamDrill passes the PLAIN
`size` to drillables (:122) and multiplies the drillSpeed
row by the PLAIN `size` (:127) -- Drill passes `size *
size` in both places (Drill.java:178, :181); (2) the
BeamDrill booster row uses the PLAIN
optionalBoostIntensity (:133) and REPLACES the super row
(`stats.replace(Stat.booster,`, :130) instead of
remove-then-add -- the BurstDrill override (N2309) removes
then re-adds with the plain intensity, the Drill super row
uses the SQUARED liquidBoostIntensity (Drill.java:188).
The drillables call passes `0f` as the drillMultiplier
(StatValues.java:413, `public static StatValue
drillables(float drillTime, float drillMultiplier, float
size, ObjectFloatMap<Item> multipliers, Boolf<Block>
filter){`): with a 0f multiplier the per-ore rate `60f /
(Math.max(drillTime + drillMultiplier *
block.itemDrop.hardness, drillTime) /
multipliers.get(block.itemDrop, 1f)) * size`
(StatValues.java:428) reduces to `60f / (drillTime /
multipliers.get(item, 1f)) * size`. The speedBoosters unit
is "{0} x speed": StatUnit.timesSpeed is `timesSpeed =
new StatUnit("timesSpeed", false),` (StatUnit.java:34)
and localized() reads bundle key "unit.timesspeed"
(StatUnit.java:61-62), English value "x speed"
(bundle.properties:1364). `consBase.amount` is the
per-frame liquid amount (`public float amount;`,
ConsumeLiquidBase.java:8); `consBase::consumes` is the
liquid filter (`public abstract boolean consumes(Liquid
liquid);`, ConsumeLiquidBase.java:21); the `false`
strength arg (:133) means the displayed speed is the
plain intensity, not heatCapacity-scaled
(StatValues.java:522). The booster filter flag is
`public boolean booster;` (Consume.java:14).
findConsumer (`public <T extends Consume> T findConsumer(
Boolf<Consume> filter){`, Block.java:1104) returns the
first consumer matching the filter.

RED decisions (resolved at RED): (1) One pure function on
the existing family file N2378 / N2379 / N2382 / N2385
built, after source_beam_drill_draw_place_state:
source_beam_drill_set_stats_state(frame, drill_time, size,
tier, drill_multipliers, blocked_items,
optional_boost_intensity, booster_consumer_found,
booster_amount, booster_consumes, drillables_filter)
returning drill_tier_row (the drillables call args:
drill_time, drill_multiplier 0f, size PLAIN,
drill_multipliers, tier, blocked_items, the filter
Callable), drill_speed_row ({value 60/drillTime*size,
unit "items/second"}), booster_row_replaced (whether
stats.replace(Stat.booster) ran -- true exactly when the
if-branch runs) and booster_row (the speedBoosters row
dict {format, amount, intensity PLAIN, strength,
consumes}, or null when the branch does not run). frame
carries no live keys for this block-level stat read --
drillTime, tier, size, drillMultipliers, blockedItems,
optionalBoostIntensity and the booster consumer are
per-def static state, not live frame keys (the N2212 /
N2224 per-def-param precedent); frame is the canonical
first param of this family file. (2) findConsumer is NOT
ported in this slice: the caller passes the already-found
result (booster_consumer_found / booster_amount /
booster_consumes) -- the N1688/N1753 findConsumer
precedent; the search order is deferred. (3) The two
drillables filter legs arrive as the explicit
drillables_filter Callable (the N2379 world_tile
precedent): the caller passes a predicate over block
Dictionaries {"kind", "wall_ore", "item_drop",
"hardness"}; Stats / StatValues / Floor / StaticWall /
ConsumeLiquidBase are NOT ported here. (4) There is NO
driver tick line: setStats is a stat-display read, not a
tick write (the N2224 / N2246 setStats lifecycle
precedent); the proof calls the pure function directly
with per-def params. (5) The `super.setStats();` leg
(BeamDrill.java:120) is Drill.setStats, owned by N2332
-- NOT this slice; the `StatValues.speedBoosters("{0}" +
StatUnit.timesSpeed.localized(),` line (BeamDrill.java:131)
is owned by N2309/N2332 -- evidence only, NOT a
distinguishing expr here. Four new result symbols:
drill_tier_row, drill_speed_row, booster_row_replaced,
booster_row. Two defs share the function (plasma-bore,
Blocks.java:3038, drillTime 160f, size 2, tier 3,
optionalBoostIntensity 2.5f class default, hydrogen
booster 0.25f/60f; large-plasma-bore, Blocks.java:3052,
drillTime 100f, size 3, tier 5, nitrogen booster
3f/60f); they differ only in the per-def params the
caller passes. Slice sources: BeamDrill.java +
Blocks.java + StatValues.java + StatUnit.java + Stat.java
+ ConsumeLiquidBase.java + Block.java + Consume.java +
bundle.properties.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_beam_drill_draw_place import DEFERRED as N2385_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BEAM_DRILL = 'core/src/mindustry/world/blocks/production/BeamDrill.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
STAT_VALUES = 'core/src/mindustry/world/meta/StatValues.java'
STAT_UNIT = 'core/src/mindustry/world/meta/StatUnit.java'
STAT = 'core/src/mindustry/world/meta/Stat.java'
CONSUME_LIQUID_BASE = 'core/src/mindustry/world/consumers/ConsumeLiquidBase.java'
BLOCK = 'core/src/mindustry/world/Block.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
BUNDLE = 'core/assets/bundles/bundle.properties'
PROOF = '/root/C07BeamDrillSetStatsProof'
SET_STATS_OWNER = 'SourceBeamDrillBuildState.source_beam_drill_set_stats_state'
TESTS = ['test_c07_beam_drill_set_stats_registration', 'test_all_c07_beam_drill_set_stats_input_evidence_is_exact', 'test_beam_drill_set_stats_state', 'test_reference_graph_and_actual_c07_beam_drill_set_stats']
# The 9 slice sources the N2388 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BeamDrill.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/meta/StatValues.java',
    'core/src/mindustry/world/meta/StatUnit.java',
    'core/src/mindustry/world/meta/Stat.java',
    'core/src/mindustry/world/consumers/ConsumeLiquidBase.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/world/consumers/Consume.java',
    'core/assets/bundles/bundle.properties',
]
EXACT_EXPRS = [
    'stats.add(Stat.drillTier, StatValues.drillables(drillTime, 0f, size, drillMultipliers, b ->',
    '(b instanceof Floor f && f.wallOre && f.itemDrop != null && f.itemDrop.hardness <= tier && (blockedItems == null || !blockedItems.contains(f.itemDrop))) ||',
    '(b instanceof StaticWall w && w.itemDrop != null && w.itemDrop.hardness <= tier && (blockedItems == null || !blockedItems.contains(w.itemDrop)))',
    'stats.add(Stat.drillSpeed, 60f / drillTime * size, StatUnit.itemsSecond);',
    'if(optionalBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){',
    'stats.replace(Stat.booster,',
    'consBase.amount, optionalBoostIntensity, false, consBase::consumes)',
]

# DEFERRED is carried from the N2385 register script via import --
# never retyped. This slice resolves NONE of the carried entries
# (setStats touches no draw tick, updateTile advance,
# shouldConsume gate, liquid row, drillMultipliers row, or
# facing binding), so all are carried verbatim. Four entries
# are added: N2388's Windows proof debt, the drillables
# table-rendering boundary, the localized-unit note, and the
# findConsumer search-order note.
DEFERRED = list(N2385_DEFERRED) + [
    'BeamDrill setStats() Windows Godot proof -- debt in GOAL.md section 5, same as N2155: the N2388 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BeamDrill setStats() drillables table rendering (StatValues.drillables, StatValues.java:413-437: content.blocks() iteration + per-block filter evaluation + per-ore rate 60f / (Math.max(drillTime + drillMultiplier * block.itemDrop.hardness, drillTime) / multipliers.get(block.itemDrop, 1f)) * size, StatValues.java:428) -- the N2388 pure function pins the drillables call args; the displayed per-ore table is rendered at display time, not by setStats.',
    'BeamDrill setStats() localized unit rendering (StatUnit.itemsSecond.localized() reads bundle "unit.itemssecond", English "items/second", bundle.properties:1354; StatUnit.timesSpeed.localized() reads bundle "unit.timesspeed", English "x speed", bundle.properties:1364) -- the N2388 proof pins the English bundle values; other locales wait for their own slice.',
    'BeamDrill setStats() findConsumer search order (Block.java:1104, first consumer matching f instanceof ConsumeLiquidBase && f.booster) -- the N2388 pure function takes the already-found consumer; which consumer wins when several boosters exist waits for its own slice.',
]


def definitions():
    def a(typ, expr, rule, source=BEAM_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    set_stats_inputs = {
        'frame': a('Dictionary', 'public void setStats(){', 'The beam drill frame (BeamDrill.setStats, BeamDrill.java:119): carries no live keys for this block-level stat read -- drillTime, tier, size, drillMultipliers, blockedItems, optionalBoostIntensity and the booster consumer are per-def static state, not live frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file.'),
        'drill_time': a('float', 'public float drillTime = 200f;', 'The base time to drill one ore, in frames (`public float drillTime = 200f;`, BeamDrill.java:39, the class default); plasma-bore 160f (Blocks.java:3042), large-plasma-bore 100f (Blocks.java:3055); passed explicitly because it is per-def static state (the N2212 / N2224 per-def-param precedent).'),
        'size': a('int', 'public int size = 1;', 'The block size in tiles (`public int size = 1;`, Block.java:215); BeamDrill passes the PLAIN size to drillables and to the drillSpeed row (BeamDrill.java:122, :127) -- NOT size * size like Drill (Drill.java:178, :181); plasma-bore size 2 (Blocks.java:3044), large-plasma-bore size 3 (Blocks.java:3058); passed explicitly (the N2212 per-def-param precedent).', source=BLOCK),
        'tier': a('int', 'public int tier = 1;', 'The maximum tier of blocks this drill can mine (`public int tier = 1;`, BeamDrill.java:41, the class default); the drillables filter legs gate on `f.itemDrop.hardness <= tier` (BeamDrill.java:123-124); plasma-bore tier 3 (Blocks.java:3043), large-plasma-bore tier 5 (Blocks.java:3057); passed explicitly.'),
        'drill_multipliers': a('Dictionary', 'public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();', 'The per-item drill-time multipliers (`public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();`, BeamDrill.java:47); both BeamDrill defs leave it empty; passed explicitly as a Dictionary because it is per-def static state.'),
        'blocked_items': a('Variant', 'public @Nullable Seq<Item> blockedItems;', 'The items this drill cannot mine (`public @Nullable Seq<Item> blockedItems;`, BeamDrill.java:51); the drillables filter legs gate on `blockedItems == null || !blockedItems.contains(f.itemDrop)` / `!blockedItems.contains(w.itemDrop)` (BeamDrill.java:123-124); both BeamDrill defs leave it null; passed explicitly as null or an Array.'),
        'optional_boost_intensity': a('float', 'public float optionalBoostIntensity = 2.5f;', 'The per-def optional boost intensity (`public float optionalBoostIntensity = 2.5f;`, BeamDrill.java:44, the class default -- NOT 1f; neither def overrides it); the setStats guard reads `optionalBoostIntensity != 1` (BeamDrill.java:129); passed explicitly because it is per-def static state, not a live frame key (the N2212 / N2224 per-def-param precedent).'),
        'booster_consumer_found': a('bool', 'if(optionalBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){', 'Whether findConsumer found a booster consumer: the first consumer matching `f instanceof ConsumeLiquidBase && f.booster` (BeamDrill.java:129, via Block.java:1104 `public <T extends Consume> T findConsumer(Boolf<Consume> filter){`); passed explicitly because findConsumer is not ported in this slice (the N1688/N1753 precedent).'),
        'booster_amount': a('float', 'public float amount;', 'The found booster consumer amount per frame (ConsumeLiquidBase.java:8, `public float amount;`, the amount used per frame); the speedBoosters amount param (`consBase.amount, optionalBoostIntensity, false, consBase::consumes)`, BeamDrill.java:133): 0.25f/60f hydrogen for the plasma-bore def (Blocks.java:3049) and 3f/60f nitrogen for the large-plasma-bore def (Blocks.java:3065); passed explicitly with the found consumer.', source=CONSUME_LIQUID_BASE),
        'booster_consumes': a('bool', 'public abstract boolean consumes(Liquid liquid);', 'The found booster consumer liquid filter result (ConsumeLiquidBase.java:21, `public abstract boolean consumes(Liquid liquid);`, the `consBase::consumes` method reference, BeamDrill.java:133); the speedBoosters filter param; passed explicitly with the found consumer.', source=CONSUME_LIQUID_BASE),
        'drillables_filter': a('Callable', '(b instanceof Floor f && f.wallOre && f.itemDrop != null && f.itemDrop.hardness <= tier && (blockedItems == null || !blockedItems.contains(f.itemDrop))) ||', 'The StatValues.drillables filter predicate (BeamDrill.java:123-124, the two lambda legs: a wall-ore Floor, or a StaticWall, whose drop is hard enough for the tier and not blocked); the caller passes a Callable over block Dictionaries {"kind", "wall_ore", "item_drop", "hardness"} (the N2379 world_tile Callable precedent) -- Floor / StaticWall are NOT ported here.'),
    }
    set_stats_outputs = {
        'drill_tier_row': a('Dictionary', 'stats.add(Stat.drillTier, StatValues.drillables(drillTime, 0f, size, drillMultipliers, b ->', 'The Stat.drillTier row added by BeamDrill.setStats, pinning the StatValues.drillables call args (BeamDrill.java:122-125): {drill_time, drill_multiplier 0f, size PLAIN (NOT size * size, the Drill.java:178 trap), drill_multipliers, tier, blocked_items, filter}; the per-block filter evaluation and the displayed per-ore table render at display time (StatValues.java:413-437).'),
        'drill_speed_row': a('Dictionary', 'stats.add(Stat.drillSpeed, 60f / drillTime * size, StatUnit.itemsSecond);', 'The Stat.drillSpeed row added by BeamDrill.setStats: {value 60f / drillTime * size, unit "items/second"} (BeamDrill.java:127, `stats.add(Stat.drillSpeed, 60f / drillTime * size, StatUnit.itemsSecond);`; StatUnit.itemsSecond localized "items/second", bundle.properties:1354); the size is PLAIN, NOT squared (the Drill.java:181 trap); plasma-bore 0.75, large-plasma-bore 1.8.'),
        'booster_row_replaced': a('bool', 'stats.replace(Stat.booster,', 'Whether stats.replace(Stat.booster) ran: true exactly when the if-branch runs (BeamDrill.java:130, `stats.replace(Stat.booster,`, inside the `optionalBoostIntensity != 1` + booster-found guard at :129) -- the replace swaps the super row (Drill.setStats, N2332, squared intensity) for the BeamDrill row with the plain intensity.'),
        'booster_row': a('Variant', 'consBase.amount, optionalBoostIntensity, false, consBase::consumes)', 'The Stat.booster row added by BeamDrill.setStats, or null when the branch does not run: {format "{0} x speed", amount consBase.amount, intensity optionalBoostIntensity PLAIN (BeamDrill.java:133 -- the trap vs the N2332 Drill super row, which uses the SQUARED liquidBoostIntensity, Drill.java:188), strength false, consumes consBase::consumes} (BeamDrill.java:130-134, `stats.replace(Stat.booster,` + `StatValues.speedBoosters("{0}" + StatUnit.timesSpeed.localized(),` + `consBase.amount, optionalBoostIntensity, false, consBase::consumes)`; the format is "{0} x speed" because StatUnit.timesSpeed.localized() reads bundle key "unit.timesspeed", English value "x speed").'),
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
        ('N2388', SET_STATS_OWNER, 'source_beam_drill_set_stats_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', 'BeamDrillBuild.setStats', set_stats_inputs, set_stats_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BeamDrill setStats() state from BeamDrill.java + Blocks.java + StatValues.java + StatUnit.java + Stat.java + ConsumeLiquidBase.java + Block.java + Consume.java + bundle.properties.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BeamDrill setStats() state from BeamDrill.java + Blocks.java + StatValues.java + StatUnit.java + Stat.java + ConsumeLiquidBase.java + Block.java + Consume.java + bundle.properties.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: drill_tier_row,
    # drill_speed_row, booster_row_replaced, booster_row.
    by_slice['N2388'] = [
        'source_beam_drill_set_stats_state_result.drill_tier_row',
        'source_beam_drill_set_stats_state_result.drill_speed_row',
        'source_beam_drill_set_stats_state_result.booster_row_replaced',
        'source_beam_drill_set_stats_state_result.booster_row',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2388', dict(status='done', java_source=BEAM_DRILL, java_class='mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', java_method='BeamDrillBuild.setStats', godot_owner=SET_STATS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2388'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
