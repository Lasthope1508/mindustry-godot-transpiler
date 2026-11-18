import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillUpdateTileProof.gd'


class C07BurstDrillUpdateTileTests(unittest.TestCase):
    def test_c07_burst_drill_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2256']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_update_tile_state')
        # BurstDrillBuild.updateTile advances the burst drill's
        # drilling state every tick (BurstDrill.java:76, `public
        # void updateTile(){`): it returns early with no
        # dominant item (BurstDrill.java:77,
        # `if(dominantItem == null){`); decays invertTime
        # (BurstDrill.java:81, `if(invertTime > 0f)
        # invertTime -= delta() / invertedTime;`); dumps on
        # the dump timer (BurstDrill.java:83,
        # `if(timer(timerDump, dumpTime / timeScale)){`
        # with `dump(items.has(dominantItem) ?
        # dominantItem : null);`, BurstDrill.java:84);
        # reads the effective drill time
        # (BurstDrill.java:87, `float drillTime =
        # getDrillTime(dominantItem);` with
        # `getDrillTime` dividing by the per-item
        # multiplier, BurstDrill.java:53-54, `public float
        # getDrillTime(Item item){` / `return drillTime /
        # drillMultipliers.get(item, 1f);`); lerps the
        # smooth progress (BurstDrill.java:89,
        # `smoothProgress = Mathf.lerpDelta(
        # smoothProgress, progress / (drillTime - 20f),
        # 0.1f);`); when producing
        # (BurstDrill.java:91, `if(items.total() <=
        # itemCapacity - dominantItems && dominantItems > 0
        # && efficiency > 0){`) approaches warmup toward
        # progress / drillTime (BurstDrill.java:92,
        # `warmup = Mathf.approachDelta(warmup, progress /
        # drillTime, 0.01f);`), folds the speed from the
        # liquid boost and the folded efficiency
        # (BurstDrill.java:94, `float speed = Mathf.lerp(1f,
        # liquidBoostIntensity, optionalEfficiency) *
        # efficiency;`), advances timeDrilled through the
        # pow2In speed curve (BurstDrill.java:96,
        # `timeDrilled += speedCurve.apply(progress /
        # drillTime) * speed;` with `public Interp
        # speedCurve = Interp.pow2In;`,
        # BurstDrill.java:19), records the drill speed
        # (BurstDrill.java:98, `lastDrillSpeed = 1f /
        # drillTime * speed * dominantItems;`) and advances
        # progress (BurstDrill.java:99, `progress += delta()
        # * speed;`); when not producing it decays warmup
        # (BurstDrill.java:101, `warmup =
        # Mathf.approachDelta(warmup, 0f, 0.01f);`) and
        # zeroes the drill speed (BurstDrill.java:102,
        # `lastDrillSpeed = 0f;`); and when the progress
        # crosses the drill time (BurstDrill.java:106,
        # `if(dominantItems > 0 && progress >= drillTime &&
        # items.total() < itemCapacity){`) it offloads one
        # item per dominant item (BurstDrill.java:107-108,
        # `for(int i = 0; i < dominantItems; i++){` /
        # `offload(dominantItem);`), inverts
        # (BurstDrill.java:111, `invertTime = 1f;`) and
        # wraps progress (BurstDrill.java:112, `progress %=
        # drillTime;`). The completion effects
        # (BurstDrill.java:114-117, `if(wasVisible){` with
        # `Effect.shake(shake, shake, this);`,
        # `drillSound.at(...);` and `drillEffect.at(...);`)
        # wait for their own slice; the `invert_fired`
        # flag is the observable signal that slice will
        # consume. The actual dump call (`public boolean
        # dump(Item todump){`, BuildingComp.java:1072)
        # waits for the driver slice; the `dump_due` flag
        # is the observable signal. The offload
        # application (`offload(dominantItem);`) waits for
        # the driver slice that owns the items module; the
        # `offloaded_count` result is the observable. N2256
        # closes the advance with one pure function over
        # the frame (`dominant_item`, `dominant_items`,
        # `invert_time`, `smooth_progress`, `progress`,
        # `warmup`, `time_drilled`, `last_drill_speed`,
        # `efficiency`, `optional_efficiency`,
        # `items_total`, `dump_timer`) plus the per-def
        # drill_time_base, drill_multiplier, inverted_time,
        # liquid_boost_intensity, item_capacity and
        # dump_interval parameters, following the N2248
        # Radar updateTile precedent: the pure function
        # takes (frame, delta, drill_time_base,
        # drill_multiplier, inverted_time,
        # liquid_boost_intensity, item_capacity,
        # dump_interval) and returns the new drill_time,
        # invert_time, smooth_progress, warmup,
        # time_drilled, last_drill_speed, progress,
        # dump_timer, dump_due flag, offloaded_count and
        # invert_fired flag. There is NO driver tick line
        # yet: the burst-drill frame carries no
        # dominant_item / dominant_items / items_total /
        # dump_timer (the ore/dominant binding and
        # items-module slices own those frame keys), so
        # the advance is pure-function-only, the N2251 /
        # N2252 precedent -- no field is invented. The
        # per-def values are explicit params (the N2212 /
        # N2248 per-def-param precedent): impact-drill
        # drillTime 720f (Blocks.java:3072, `drillTime =
        # 60f * 12f;`), itemCapacity 40
        # (Blocks.java:3078), liquidBoostIntensity 1.75f
        # (Blocks.java:3084); eruption-drill drillTime
        # 281.25f (Blocks.java:3095), itemCapacity 60
        # (Blocks.java:3107), liquidBoostIntensity 2f
        # (Blocks.java:3115); both defs multiply beryllium
        # by 2f (Blocks.java:3083/3114,
        # `drillMultipliers.put(Items.beryllium, 2f);`).
        # Eleven new result symbols: drill_time,
        # invert_time, smooth_progress, warmup,
        # time_drilled, last_drill_speed, progress,
        # dump_timer, dump_due, offloaded_count,
        # invert_fired.
        self.assertEqual(
            ledger['N2256']['source_symbols'],
            [
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
            ],
        )
        for name in ledger['N2256']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BurstDrill.java',
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/content/Blocks.java',
                    'arc-core/src/arc/math/Interp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2256']['runtime_proof'], '/root/C07BurstDrillUpdateTileProof')
        self.assertEqual(
            ledger['N2256']['tests'],
            [
                'test_c07_burst_drill_update_tile_registration',
                'test_all_c07_burst_drill_update_tile_input_evidence_is_exact',
                'test_burst_drill_update_tile_state',
                'test_reference_graph_and_actual_c07_burst_drill_update_tile',
            ],
        )
        self.assertTrue(ledger['N2256']['deferred_exprs'])

    def test_all_c07_burst_drill_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2256']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                source = symbol['java_source']
                upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / source).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'arc-core/src/arc/math/Interp.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2256']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_update_tile_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # The pure updateTile advance lives on the burst-drill
        # build state next to the N2149 power row:
        # BurstDrillBuild.updateTile (BurstDrill.java:76,
        # `public void updateTile(){`) returns early with no
        # dominant item (BurstDrill.java:77,
        # `if(dominantItem == null){`), decays invertTime
        # (BurstDrill.java:81, `if(invertTime > 0f)
        # invertTime -= delta() / invertedTime;`), dumps on
        # the dump timer (BurstDrill.java:83,
        # `if(timer(timerDump, dumpTime / timeScale)){`
        # with `dump(items.has(dominantItem) ?
        # dominantItem : null);`, BurstDrill.java:84),
        # reads the effective drill time
        # (BurstDrill.java:87, `float drillTime =
        # getDrillTime(dominantItem);`), lerps the smooth
        # progress (BurstDrill.java:89,
        # `smoothProgress = Mathf.lerpDelta(
        # smoothProgress, progress / (drillTime - 20f),
        # 0.1f);`), approaches warmup and advances
        # timeDrilled / lastDrillSpeed / progress when
        # producing (BurstDrill.java:91-99), decays warmup
        # and zeroes the drill speed when not producing
        # (BurstDrill.java:101-102, `warmup =
        # Mathf.approachDelta(warmup, 0f, 0.01f);` /
        # `lastDrillSpeed = 0f;`), and offloads, inverts
        # and wraps progress when the progress crosses the
        # drill time (BurstDrill.java:106-112). delta() is
        # Time.delta * timeScale (BuildingComp.java:1922-
        # 1923, `public float delta(){` with `return
        # Time.delta * timeScale;` -- timeScale is 1 by
        # default and the port passes the raw tick seconds,
        # the N2190 driver convention). The folded
        # efficiency and optional efficiency are the
        # transient fields (BuildingComp.java:85/87,
        # `transient float efficiency;` /
        # `transient float optionalEfficiency;`), default
        # 0.0 before the first machinery run. The frame
        # carries `dominant_item` (Variant, absent
        # defaults to null -- `public Item dominantItem;`,
        # Drill.java:244), `dominant_items` (int, absent
        # defaults to 0 -- `public int dominantItems;`,
        # Drill.java:243), `invert_time` (float, absent
        # defaults to 0.0 -- `public float invertTime =
        # 0f;`, BurstDrill.java:73), `smooth_progress`
        # (float, absent defaults to 0.0 -- `public float
        # smoothProgress = 0f;`, BurstDrill.java:72),
        # `progress` / `warmup` / `time_drilled` /
        # `last_drill_speed` (floats, absent default to
        # 0.0 -- `public float progress;` /
        # `public float warmup;` /
        # `public float timeDrilled;` /
        # `public float lastDrillSpeed;`,
        # Drill.java:238-241), `efficiency` /
        # `optional_efficiency` (floats, absent default
        # to 0.0 -- the transient field defaults),
        # `items_total` (float, absent defaults to 0.0 --
        # a fresh ItemModule totals 0, the N2207 LaunchPad
        # precedent) and `dump_timer` (float, absent
        # defaults to 0.0 -- the Interval accumulator for
        # `protected final int timerDump = timers++;`,
        # Block.java:436, with `public int dumpTime = 5;`,
        # Block.java:438). The speed curve is Interp.pow2In
        # (`public Interp speedCurve = Interp.pow2In;`,
        # BurstDrill.java:19, `PowIn pow2In = new
        # PowIn(2);`, Interp.java:29, with `return
        # (float)Math.pow(a, power);`, Interp.java:116 --
        # pow2In(a) is a squared), so the curve factor is
        # (progress / drillTime) squared. Two defs share
        # the implementation (BurstDrill.java:17, `public
        # class BurstDrill extends Drill{`;
        # BurstDrillBuild, BurstDrill.java:70, `public
        # class BurstDrillBuild extends DrillBuild{`,
        # with DrillBuild, Drill.java:237, `public class
        # DrillBuild extends Building{`). There is NO
        # driver tick line yet: the burst-drill frame
        # carries no dominant_item / dominant_items /
        # items_total / dump_timer, so the advance is
        # pure-function-only (the N2251 / N2252 precedent)
        # and no field is invented.
        self.assertIn('static func source_burst_drill_update_tile_state(frame: Dictionary, delta: float, drill_time_base: float, drill_multiplier: float, inverted_time: float, liquid_boost_intensity: float, item_capacity: float, dump_interval: float) -> Dictionary:', burst_drill)
        # The advance cases, pinned as the pure function's
        # decision structure: the effective drill time
        # divides the base by the multiplier; the early
        # return fires with no dominant item; invertTime
        # decays by delta / invertedTime; the dump timer
        # follows the port's dump_timer_state model; the
        # smooth progress lerps toward progress /
        # (drillTime - 20); warmup approaches progress /
        # drillTime when producing and 0 otherwise; the
        # speed folds the liquid boost and the efficiency;
        # timeDrilled advances through the squared curve;
        # the drill speed and progress advance; the final
        # gate offloads, inverts and wraps progress.
        self.assertIn('var dominant_item: Variant = frame.get("dominant_item", null)', burst_drill)
        self.assertIn('int(frame.get("dominant_items", 0))', burst_drill)
        self.assertIn('float(frame.get("invert_time", 0.0))', burst_drill)
        self.assertIn('float(frame.get("smooth_progress", 0.0))', burst_drill)
        self.assertIn('float(frame.get("progress", 0.0))', burst_drill)
        self.assertIn('float(frame.get("warmup", 0.0))', burst_drill)
        self.assertIn('float(frame.get("time_drilled", 0.0))', burst_drill)
        self.assertIn('float(frame.get("last_drill_speed", 0.0))', burst_drill)
        self.assertIn('float(frame.get("efficiency", 0.0))', burst_drill)
        self.assertIn('float(frame.get("optional_efficiency", 0.0))', burst_drill)
        self.assertIn('float(frame.get("items_total", 0.0))', burst_drill)
        self.assertIn('float(frame.get("dump_timer", 0.0))', burst_drill)
        with self.subTest(case='effective drill time divides the base by the multiplier'):
            self.assertIn('var drill_time: float = drill_time_base / drill_multiplier', burst_drill)
        with self.subTest(case='early return with no dominant item'):
            self.assertIn('if dominant_item == null:', burst_drill)
        with self.subTest(case='invertTime decays by delta over invertedTime'):
            self.assertIn('invert_time -= delta / inverted_time', burst_drill)
        with self.subTest(case='dump timer follows the port dump_timer_state model'):
            self.assertIn('source_drill_dump_runtime_state.dump_timer_state(dump_timer, delta, dump_interval)', burst_drill)
        with self.subTest(case='smooth progress lerps toward progress over drillTime minus 20'):
            self.assertIn('smooth_progress = source_math_state.source_lerp_delta(smooth_progress, progress / (drill_time - 20.0), 0.1, delta)', burst_drill)
        with self.subTest(case='producing gate reads items, dominant count and efficiency'):
            self.assertIn('if items_total <= item_capacity - float(dominant_items) and dominant_items > 0 and efficiency > 0.0:', burst_drill)
        with self.subTest(case='warmup approaches progress over drillTime when producing'):
            self.assertIn('warmup = source_math_state.source_approach_delta(warmup, progress / drill_time, 0.01, delta)', burst_drill)
        with self.subTest(case='speed folds the liquid boost and the efficiency'):
            self.assertIn('var speed: float = lerpf(1.0, liquid_boost_intensity, optional_efficiency) * efficiency', burst_drill)
        with self.subTest(case='timeDrilled advances through the squared speed curve'):
            self.assertIn('time_drilled += ratio * ratio * speed', burst_drill)
        with self.subTest(case='drill speed and progress advance'):
            self.assertIn('last_drill_speed = 1.0 / drill_time * speed * float(dominant_items)', burst_drill)
            self.assertIn('progress += delta * speed', burst_drill)
        with self.subTest(case='warmup decays and drill speed zeroes when not producing'):
            self.assertIn('warmup = source_math_state.source_approach_delta(warmup, 0.0, 0.01, delta)', burst_drill)
            self.assertIn('last_drill_speed = 0.0', burst_drill)
        with self.subTest(case='final gate offloads, inverts and wraps progress'):
            self.assertIn('if dominant_items > 0 and progress >= drill_time and items_total < item_capacity:', burst_drill)
            self.assertIn('offloaded_count = dominant_items', burst_drill)
            self.assertIn('invert_time = 1.0', burst_drill)
            self.assertIn('progress = fposmod(progress, drill_time)', burst_drill)
        with self.subTest(case='all eleven keys are returned'):
            self.assertIn('return {"drill_time": drill_time, "invert_time": invert_time, "smooth_progress": smooth_progress, "warmup": warmup, "time_drilled": time_drilled, "last_drill_speed": last_drill_speed, "progress": progress, "dump_timer": dump_timer, "dump_due": dump_due, "offloaded_count": offloaded_count, "invert_fired": invert_fired}', burst_drill)
        for expr in [
            'public void updateTile(){',
            'if(dominantItem == null){',
            'if(invertTime > 0f) invertTime -= delta() / invertedTime;',
            'if(timer(timerDump, dumpTime / timeScale)){',
            'dump(items.has(dominantItem) ? dominantItem : null);',
            'float drillTime = getDrillTime(dominantItem);',
            'smoothProgress = Mathf.lerpDelta(smoothProgress, progress / (drillTime - 20f), 0.1f);',
            'if(items.total() <= itemCapacity - dominantItems && dominantItems > 0 && efficiency > 0){',
            'warmup = Mathf.approachDelta(warmup, progress / drillTime, 0.01f);',
            'float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;',
            'timeDrilled += speedCurve.apply(progress / drillTime) * speed;',
            'lastDrillSpeed = 1f / drillTime * speed * dominantItems;',
            'progress += delta() * speed;',
            'warmup = Mathf.approachDelta(warmup, 0f, 0.01f);',
            'lastDrillSpeed = 0f;',
            'if(dominantItems > 0 && progress >= drillTime && items.total() < itemCapacity){',
            'for(int i = 0; i < dominantItems; i++){',
            'offload(dominantItem);',
            'invertTime = 1f;',
            'progress %= drillTime;',
            'if(wasVisible){',
            'Effect.shake(shake, shake, this);',
            'drillSound.at(x, y, 1f + Mathf.range(drillSoundPitchRand), drillSoundVolume);',
            'drillEffect.at(x + Mathf.range(drillEffectRnd), y + Mathf.range(drillEffectRnd), dominantItem.color);',
            'public float smoothProgress = 0f;',
            'public float invertTime = 0f;',
            'public float invertedTime = 200f;',
            'public Interp speedCurve = Interp.pow2In;',
            'public float getDrillTime(Item item){',
            'return drillTime / drillMultipliers.get(item, 1f);',
            'public class BurstDrill extends Drill{',
            'public class BurstDrillBuild extends DrillBuild{',
            'public float progress;',
            'public float warmup;',
            'public float timeDrilled;',
            'public float lastDrillSpeed;',
            'public int dominantItems;',
            'public Item dominantItem;',
            'public class DrillBuild extends Building{',
            'transient float efficiency;',
            'transient float optionalEfficiency;',
            'public float delta(){',
            'return Time.delta * timeScale;',
            'public boolean dump(Item todump){',
            'protected final int timerDump = timers++;',
            'public int dumpTime = 5;',
            'drillTime = 60f * 12f;',
            'drillTime = 281.25f;',
            'liquidBoostIntensity = 1.75f;',
            'liquidBoostIntensity = 2f;',
            'itemCapacity = 40;',
            'itemCapacity = 60;',
            'drillMultipliers.put(Items.beryllium, 2f);',
            'PowIn pow2In = new PowIn(2);',
            'return (float)Math.pow(a, power);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # No driver tick line lands here: the burst-drill
        # tick driver must not call the updateTile advance
        # -- the frame carries no dominant_item /
        # dominant_items / items_total / dump_timer yet.
        driver_start = burst_drill.index('static func source_burst_drill_tick_buildings_state')
        driver_text = burst_drill[driver_start:]
        self.assertNotIn('source_burst_drill_update_tile_state', driver_text)
        # The proof's keys drive the pure updateTile advance
        # (smooth-progress lerp / warmup approach / offload
        # invert and wrap / drill-time multiplier / no
        # advance without efficiency / dump timer fire / no
        # dominant item / no advance when full / eruption
        # def boost and capacity). There are no dump-call,
        # offload-application or completion-effect keys:
        # the dump call, the offload application and the
        # wasVisible-gated shake / sound / drillEffect wait
        # for their own slices, and the dump_due /
        # offloaded_count / invert_fired flags are the
        # observable signals those slices will consume.
        proof = BURST_DRILL_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'update_tile_smooth_progress_lerps_and_warmup_approaches',
            'update_tile_offload_inverts_and_wraps_progress',
            'update_tile_drill_time_divides_by_multiplier',
            'update_tile_no_advance_without_efficiency',
            'update_tile_dump_timer_fires_at_interval',
            'update_tile_no_dominant_item_returns_unchanged',
            'update_tile_no_advance_when_full',
            'update_tile_eruption_def_uses_boost_and_capacity',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_burst_drill_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'update_tile_smooth_progress_lerps_and_warmup_approaches',
            'update_tile_offload_inverts_and_wraps_progress',
            'update_tile_drill_time_divides_by_multiplier',
            'update_tile_no_advance_without_efficiency',
            'update_tile_dump_timer_fires_at_interval',
            'update_tile_no_dominant_item_returns_unchanged',
            'update_tile_no_advance_when_full',
            'update_tile_eruption_def_uses_boost_and_capacity',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
