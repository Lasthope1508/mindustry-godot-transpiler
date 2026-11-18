"""Register the BurstDrill updateTile advance (N2256).

BurstDrillBuild.updateTile advances the burst drill's
drilling state every tick (BurstDrill.java:76, `public void
updateTile(){`): it returns early with no dominant item
(BurstDrill.java:77, `if(dominantItem == null){`); decays
invertTime (BurstDrill.java:81, `if(invertTime > 0f)
invertTime -= delta() / invertedTime;`); dumps on the dump
timer (BurstDrill.java:83, `if(timer(timerDump, dumpTime /
timeScale)){` with `dump(items.has(dominantItem) ?
dominantItem : null);`, BurstDrill.java:84); reads the
effective drill time (BurstDrill.java:87, `float drillTime =
getDrillTime(dominantItem);` with `getDrillTime` dividing by
the per-item multiplier, BurstDrill.java:53-54, `public float
getDrillTime(Item item){` / `return drillTime /
drillMultipliers.get(item, 1f);`); lerps the smooth progress
(BurstDrill.java:89, `smoothProgress = Mathf.lerpDelta(
smoothProgress, progress / (drillTime - 20f), 0.1f);`); when
producing (BurstDrill.java:91, `if(items.total() <=
itemCapacity - dominantItems && dominantItems > 0 &&
efficiency > 0){`) approaches warmup toward progress /
drillTime (BurstDrill.java:92, `warmup =
Mathf.approachDelta(warmup, progress / drillTime, 0.01f);`),
folds the speed from the liquid boost and the folded
efficiency (BurstDrill.java:94, `float speed = Mathf.lerp(1f,
liquidBoostIntensity, optionalEfficiency) * efficiency;`),
advances timeDrilled through the pow2In speed curve
(BurstDrill.java:96, `timeDrilled += speedCurve.apply(progress
/ drillTime) * speed;` with `public Interp speedCurve =
Interp.pow2In;`, BurstDrill.java:19), records the drill speed
(BurstDrill.java:98, `lastDrillSpeed = 1f / drillTime * speed
* dominantItems;`) and advances progress (BurstDrill.java:99,
`progress += delta() * speed;`); when not producing it decays
warmup (BurstDrill.java:101, `warmup =
Mathf.approachDelta(warmup, 0f, 0.01f);`) and zeroes the drill
speed (BurstDrill.java:102, `lastDrillSpeed = 0f;`) and
returns; and when the progress crosses the drill time
(BurstDrill.java:106, `if(dominantItems > 0 && progress >=
drillTime && items.total() < itemCapacity){`) it offloads one
item per dominant item (BurstDrill.java:107-108, `for(int i =
0; i < dominantItems; i++){` / `offload(dominantItem);`),
inverts (BurstDrill.java:111, `invertTime = 1f;`) and wraps
progress (BurstDrill.java:112, `progress %= drillTime;`). The
completion effects (BurstDrill.java:114-117, `if(wasVisible){`
with `Effect.shake(shake, shake, this);`,
`drillSound.at(...);` and `drillEffect.at(...);`) wait for
their own slice; the `invert_fired` flag is the observable
signal that slice will consume. The actual dump call (`public
boolean dump(Item todump){`, BuildingComp.java:1072) waits for
the driver slice; the `dump_due` flag is the observable
signal. The offload application (`offload(dominantItem);`)
waits for the driver slice that owns the items module; the
`offloaded_count` result is the observable.

RED decisions (resolved at RED): (1) One pure function on the
same family file N2149 built, following the N2248 Radar
updateTile precedent: (frame, delta, drill_time_base,
drill_multiplier, inverted_time, liquid_boost_intensity,
item_capacity, dump_interval) and NO driver tick line -- the
burst-drill frame carries no dominant_item / dominant_items /
items_total / dump_timer (the ore/dominant binding and
items-module slices own those frame keys), so the advance is
pure-function-only, the N2251 / N2252 precedent, and no field
is invented. (2) The frame carries `dominant_item` (Variant,
absent -> null, `public Item dominantItem;`, Drill.java:244),
`dominant_items` (int, absent -> 0, `public int
dominantItems;`, Drill.java:243), `invert_time` (float, absent
-> 0.0, `public float invertTime = 0f;`, BurstDrill.java:73),
`smooth_progress` (float, absent -> 0.0, `public float
smoothProgress = 0f;`, BurstDrill.java:72), `progress` /
`warmup` / `time_drilled` / `last_drill_speed` (floats, absent
-> 0.0, `public float progress;` / `public float warmup;` /
`public float timeDrilled;` / `public float lastDrillSpeed;`,
Drill.java:238-241), `efficiency` / `optional_efficiency`
(floats, absent -> 0.0, the transient field defaults
`transient float efficiency;` / `transient float
optionalEfficiency;`, BuildingComp.java:85/87), `items_total`
(float, absent -> 0.0 -- a fresh ItemModule totals 0, the
N2207 LaunchPad precedent) and `dump_timer` (float, absent ->
0.0 -- the Interval accumulator for `protected final int
timerDump = timers++;`, Block.java:436, with `public int
dumpTime = 5;`, Block.java:438). delta() is Time.delta *
timeScale (BuildingComp.java:1922-1923, `public float delta(){`
with `return Time.delta * timeScale;` -- timeScale is 1 by
default and the port passes the raw tick seconds, the N2190
driver convention). (3) The effective drill time is derived
from the params before the early return, so every return
carries the same eleven keys; the frame values themselves are
untouched when there is no dominant item. (4) The dump timer
follows the port's dump_timer_state model
(SourceDrillDumpRuntimeState.dump_timer_state). (5) The speed
curve is Interp.pow2In (`PowIn pow2In = new PowIn(2);`,
Interp.java:29, with `return (float)Math.pow(a, power);`,
Interp.java:116 -- pow2In(a) is a squared), so the curve
factor is (progress / drillTime) squared. (6) The per-def
values are explicit params (the N2212 / N2248 per-def-param
precedent): impact-drill drillTime 720f (Blocks.java:3072,
`drillTime = 60f * 12f;`), itemCapacity 40 (Blocks.java:3078),
liquidBoostIntensity 1.75f (Blocks.java:3084);
eruption-drill drillTime 281.25f (Blocks.java:3095),
itemCapacity 60 (Blocks.java:3107), liquidBoostIntensity 2f
(Blocks.java:3115); both defs multiply beryllium by 2f
(Blocks.java:3083/3114, `drillMultipliers.put(Items.beryllium,
2f);`). Eleven new result symbols: drill_time, invert_time,
smooth_progress, warmup, time_drilled, last_drill_speed,
progress, dump_timer, dump_due, offloaded_count, invert_fired.
Slice sources: BurstDrill.java + Drill.java + BuildingComp.java
+ Block.java + Blocks.java + Interp.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_icons import DEFERRED as N2227_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BURST_DRILL = 'core/src/mindustry/world/blocks/production/BurstDrill.java'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
INTERP = 'arc-core/src/arc/math/Interp.java'
PROOF = '/root/C07BurstDrillUpdateTileProof'
UPDATE_TILE_OWNER = 'SourceBurstDrillBuildState.source_burst_drill_update_tile_state'
TESTS = ['test_c07_burst_drill_update_tile_registration', 'test_all_c07_burst_drill_update_tile_input_evidence_is_exact', 'test_burst_drill_update_tile_state', 'test_reference_graph_and_actual_c07_burst_drill_update_tile']
# The 6 slice sources the N2256 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BurstDrill.java',
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/content/Blocks.java',
    'arc-core/src/arc/math/Interp.java',
]
EXACT_EXPRS = ['public void updateTile(){', 'if(dominantItem == null){', 'if(invertTime > 0f) invertTime -= delta() / invertedTime;', 'if(timer(timerDump, dumpTime / timeScale)){', 'dump(items.has(dominantItem) ? dominantItem : null);', 'float drillTime = getDrillTime(dominantItem);', 'smoothProgress = Mathf.lerpDelta(smoothProgress, progress / (drillTime - 20f), 0.1f);', 'if(items.total() <= itemCapacity - dominantItems && dominantItems > 0 && efficiency > 0){', 'warmup = Mathf.approachDelta(warmup, progress / drillTime, 0.01f);', 'float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;', 'timeDrilled += speedCurve.apply(progress / drillTime) * speed;', 'lastDrillSpeed = 1f / drillTime * speed * dominantItems;', 'progress += delta() * speed;', 'warmup = Mathf.approachDelta(warmup, 0f, 0.01f);', 'lastDrillSpeed = 0f;', 'if(dominantItems > 0 && progress >= drillTime && items.total() < itemCapacity){', 'for(int i = 0; i < dominantItems; i++){', 'offload(dominantItem);', 'invertTime = 1f;', 'progress %= drillTime;', 'if(wasVisible){', 'Effect.shake(shake, shake, this);', 'drillSound.at(x, y, 1f + Mathf.range(drillSoundPitchRand), drillSoundVolume);', 'drillEffect.at(x + Mathf.range(drillEffectRnd), y + Mathf.range(drillEffectRnd), dominantItem.color);', 'public float smoothProgress = 0f;', 'public float invertTime = 0f;', 'public float invertedTime = 200f;', 'public Interp speedCurve = Interp.pow2In;', 'public float getDrillTime(Item item){', 'return drillTime / drillMultipliers.get(item, 1f);', 'public class BurstDrill extends Drill{', 'public class BurstDrillBuild extends DrillBuild{', 'public float progress;', 'public float warmup;', 'public float timeDrilled;', 'public float lastDrillSpeed;', 'public int dominantItems;', 'public Item dominantItem;', 'public class DrillBuild extends Building{', 'transient float efficiency;', 'transient float optionalEfficiency;', 'public float delta(){', 'return Time.delta * timeScale;', 'public boolean dump(Item todump){', 'protected final int timerDump = timers++;', 'public int dumpTime = 5;', 'drillTime = 60f * 12f;', 'drillTime = 281.25f;', 'liquidBoostIntensity = 1.75f;', 'liquidBoostIntensity = 2f;', 'itemCapacity = 40;', 'itemCapacity = 60;', 'drillMultipliers.put(Items.beryllium, 2f);', 'PowIn pow2In = new PowIn(2);', 'return (float)Math.pow(a, power);']

# DEFERRED is carried from the N2227 register script via import --
# (round 3: the N2247 (ex-N2229) senseObject(config) register is DROPPED -- remote N2252 covers that leg -- so the chain skips it and imports N2227 directly).
# never retyped. One carried entry is DROPPED here, not carried:
# the BurstDrill updateTile advance entry -- N2256 IS the
# updateTile advance slice, so carrying it would leave a stale
# "waits for its own slice" row for done work. The shouldConsume
# gate (N2257), the liquid rows (N2258) and the ore / dominant-item
# binding entries stay deferred -- those slices own them.
DEFERRED = [e for e in N2227_DEFERRED if 'BurstDrill updateTile advance' not in e] + [
    'BurstDrill updateTile advance Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2227: the N2256 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BurstDrill completion effects (shake / drillSound / drillEffect, BurstDrill.java:114-117) -- the N2256 proof carries no shake/sound/effect keys; the invert_fired flag is the observable signal that slice will consume; the effects wait for their own slice.',
    'BurstDrill dump call (BuildingComp.java:1072, `public boolean dump(Item todump){`) -- the N2256 proof carries no dump-call key; the dump_due flag is the observable signal; the actual dump call waits for the driver slice.',
    'BurstDrill offload application (offload(dominantItem), BurstDrill.java:108) -- the N2256 proof carries no offload-application key; the offloaded_count result is the observable; the application waits for the driver slice that owns the items module.',
]


def definitions():
    def a(typ, expr, rule, source=BURST_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    update_tile_inputs = {
        'frame': a('Dictionary', 'public void updateTile(){', 'The burst-drill frame (BurstDrillBuild.updateTile, BurstDrill.java:76): carries dominant_item (Variant, absent -> null), dominant_items (int, absent -> 0), invert_time / smooth_progress / progress / warmup / time_drilled / last_drill_speed (floats, absent -> 0.0), efficiency / optional_efficiency (floats, absent -> 0.0), items_total (float, absent -> 0.0) and dump_timer (float, absent -> 0.0).', source=BURST_DRILL),
        'delta': a('float', 'return Time.delta * timeScale;', 'The tick seconds: delta() is Time.delta * timeScale (BuildingComp.java:1922-1923); timeScale is 1 by default and the port passes the raw tick seconds (the N2190 driver convention).', source=BUILDING_COMP),
        'drill_time_base': a('float', 'drillTime = 60f * 12f;', 'The per-def base drill time, 720f for the impact-drill def (Blocks.java:3072) and 281.25f for the eruption-drill def (Blocks.java:3095); passed explicitly because the catalog carries no drillTime (the N2212 per-def-param precedent).', source=BLOCKS),
        'drill_multiplier': a('float', 'drillMultipliers.put(Items.beryllium, 2f);', 'The per-item drill multiplier, 2f for beryllium on both defs (Blocks.java:3083/3114), 1f otherwise (getDrillTime divides by drillMultipliers.get(item, 1f), BurstDrill.java:54); passed explicitly because the catalog carries no drillMultipliers.', source=BLOCKS),
        'inverted_time': a('float', 'public float invertedTime = 200f;', 'The invert decay divisor, 200f (BurstDrill.java:26); invertTime decays by delta / invertedTime (BurstDrill.java:81).', source=BURST_DRILL),
        'liquid_boost_intensity': a('float', 'liquidBoostIntensity = 1.75f;', 'The per-def liquid boost intensity, 1.75f for the impact-drill def (Blocks.java:3084) and 2f for the eruption-drill def (Blocks.java:3115); passed explicitly because the catalog carries no liquidBoostIntensity (the N2212 per-def-param precedent).', source=BLOCKS),
        'item_capacity': a('float', 'itemCapacity = 40;', 'The per-def item capacity, 40 for the impact-drill def (Blocks.java:3078) and 60 for the eruption-drill def (Blocks.java:3107); passed explicitly because the catalog carries no itemCapacity (the N2212 per-def-param precedent).', source=BLOCKS),
        'dump_interval': a('float', 'public int dumpTime = 5;', 'The dump timer interval: dumpTime 5 (Block.java:438) over timeScale 1, so the timer fires every 5s (BurstDrill.java:83, `if(timer(timerDump, dumpTime / timeScale)){`).', source=BLOCK),
    }
    update_tile_outputs = {
        'drill_time': a('float', 'return drillTime / drillMultipliers.get(item, 1f);', 'The effective drill time this tick: the base divided by the per-item multiplier (getDrillTime, BurstDrill.java:53-54); derived from the params before the early return, so every return carries it.', source=BURST_DRILL),
        'invert_time': a('float', 'if(invertTime > 0f) invertTime -= delta() / invertedTime;', 'The invert time after the tick: decayed by delta / invertedTime while positive (BurstDrill.java:81), set to 1f when the progress crosses the drill time (BurstDrill.java:111).', source=BURST_DRILL),
        'smooth_progress': a('float', 'smoothProgress = Mathf.lerpDelta(smoothProgress, progress / (drillTime - 20f), 0.1f);', 'The smoothed progress after the tick: lerpDelta toward progress / (drillTime - 20f) at 0.1f (BurstDrill.java:89), via the port SourceMathState.source_lerp_delta helper.', source=BURST_DRILL),
        'warmup': a('float', 'warmup = Mathf.approachDelta(warmup, progress / drillTime, 0.01f);', 'The warmup after the tick: approachDelta toward progress / drillTime at 0.01f when producing (BurstDrill.java:92), toward 0f at 0.01f when not producing (BurstDrill.java:101), via the port SourceMathState.source_approach_delta helper.', source=BURST_DRILL),
        'time_drilled': a('float', 'timeDrilled += speedCurve.apply(progress / drillTime) * speed;', 'The drilled time after the tick: advanced through the pow2In speed curve applied to progress / drillTime, times the speed (BurstDrill.java:96); pow2In(a) is a squared (Interp.java:29/116).', source=BURST_DRILL),
        'last_drill_speed': a('float', 'lastDrillSpeed = 1f / drillTime * speed * dominantItems;', 'The drill speed after the tick: 1f / drillTime * speed * dominantItems when producing (BurstDrill.java:98), 0f when not producing (BurstDrill.java:102).', source=BURST_DRILL),
        'progress': a('float', 'progress += delta() * speed;', 'The drill progress after the tick: advanced by delta() * speed when producing (BurstDrill.java:99), wrapped by drillTime when it crosses it (BurstDrill.java:112, `progress %= drillTime;`).', source=BURST_DRILL),
        'dump_timer': a('float', 'if(timer(timerDump, dumpTime / timeScale)){', 'The dump timer after the tick: advanced by delta following the port dump_timer_state model, wrapping at the dump interval (BurstDrill.java:83).', source=BURST_DRILL),
        'dump_due': a('bool', 'dump(items.has(dominantItem) ? dominantItem : null);', 'Whether the dump fires this tick: true when the dump timer reaches the interval (BurstDrill.java:83-84); the observable flag -- the actual dump call (BuildingComp.java:1072) waits for the driver slice.', source=BURST_DRILL),
        'offloaded_count': a('int', 'offload(dominantItem);', 'How many items offload this tick: dominantItems when the progress crosses the drill time (BurstDrill.java:106-108), 0 otherwise; the observable -- the offload application waits for the driver slice that owns the items module.', source=BURST_DRILL),
        'invert_fired': a('bool', 'invertTime = 1f;', 'Whether the invert fired this tick: true when the progress crosses the drill time (BurstDrill.java:106-112); the observable flag -- the completion effects (BurstDrill.java:114-117) wait for their own slice.', source=BURST_DRILL),
    }
    return update_tile_inputs, update_tile_outputs


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
    update_tile_inputs, update_tile_outputs = definitions()

    entries = [
        ('N2256', UPDATE_TILE_OWNER, 'source_burst_drill_update_tile_state', BURST_DRILL, 'mindustry.world.blocks.production.BurstDrill.BurstDrillBuild', 'BurstDrillBuild.updateTile()', update_tile_inputs, update_tile_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BurstDrill updateTile advance from BurstDrill.java + Drill.java + BuildingComp.java + Block.java + Blocks.java + Interp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BurstDrill updateTile advance from BurstDrill.java + Drill.java + BuildingComp.java + Block.java + Blocks.java + Interp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: drill_time, invert_time,
    # smooth_progress, warmup, time_drilled, last_drill_speed,
    # progress, dump_timer, dump_due, offloaded_count,
    # invert_fired.
    by_slice['N2256'] = [
        'source_burst_drill_update_tile_state_result.drill_time',
        'source_burst_drill_update_tile_state_result.invert_time',
        'source_burst_drill_update_tile_state_result.smooth_progress',
        'source_burst_drill_update_tile_state_result.warmup',
        'source_burst_drill_update_tile_state_result.time_drilled',
        'source_burst_drill_update_tile_state_result.last_drill_speed',
        'source_burst_drill_update_tile_state_result.progress',
        'source_burst_drill_update_tile_state_result.dump_timer',
        'source_burst_drill_update_tile_state_result.dump_due',
        'source_burst_drill_update_tile_state_result.offloaded_count',
        'source_burst_drill_update_tile_state_result.invert_fired',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2256', dict(status='done', java_source=BURST_DRILL, java_class='mindustry.world.blocks.production.BurstDrill.BurstDrillBuild', java_method='BurstDrillBuild.updateTile()', godot_owner=UPDATE_TILE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2256'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
