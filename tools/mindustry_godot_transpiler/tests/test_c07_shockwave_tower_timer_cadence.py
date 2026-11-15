import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_TIMER_CADENCE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerTimerCadenceProof.gd'


class C07ShockwaveTowerTimerCadenceTests(unittest.TestCase):
    def test_c07_shockwave_tower_timer_cadence_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2200']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_timer_state')
        # The fire gate (ShockwaveTower.java:73,
        # `if(potentialEfficiency > 0 && (reloadCounter +=
        # edelta()) >= reload && timer(timerCheck,
        # checkInterval)){`) has three conjuncts, and the port
        # models the first two -- N2192's charge advances the
        # counter by edelta() (BuildingComp.java:1927-1929,
        # `return efficiency * delta();`) and N2194's fire reads
        # the charged counter against reload 80f
        # (Blocks.java:2044, `reload = 80f;`) -- but the third
        # conjunct, the per-building Interval timer
        # (`timer(timerCheck, checkInterval)`, checkInterval 8f,
        # ShockwaveTower.java:31; `public int timerCheck = timers
        # ++;`, ShockwaveTower.java:23, over `public int timers
        # = 0;`, Block.java:231; `public boolean timer(int index,
        # float time){` / `if(Float.isInfinite(time)) return
        # false;` / `return timer.get(index, time);`,
        # TimerComp.java:10-13, over `transient Interval timer =
        # new Interval(6);`, TimerComp.java:9, and
        # Interval.get: `boolean got = check(id, time);` /
        # `if(got) times[id] = Time.time;`,
        # Interval.java:23-24, over `return Time.time -
        # times[id] >= time || Time.time < times[id];`,
        # Interval.java:29), has NO pure function in the port --
        # so the port fires on the first tick the counter is at
        # reload with targets observed, where Java fires only on
        # a timer tick, up to checkInterval (8 ticks, Time.delta
        # is ticks: `Math.min(Core.graphics.getDeltaTime() *
        # 60f, 3f)`, Time.java:26, with `timeRaw += delta;` /
        # `time = (float)timeRaw;`, Time.java:70-75) earlier, and
        # the port scans every tick where Java scans only on a
        # timer tick (the N2195 scan comment defers exactly this
        # cadence to the per-building-timer slice). N2200 owns
        # the timer. The pure function
        # (source_shockwave_tower_timer_state) reads the frame's
        # `potential_efficiency` / `reload_counter` gate inputs
        # (the N2192 charge stamps the counter, the consumption
        # machinery stamps potential_efficiency) and its
        # `timer_elapsed` key (seconds since the last due check
        # on the port's seconds clock -- the N2190 refresh /
        # N2192 charge precedent: the port's driver clock is
        # seconds, so checkInterval 8f runs as 8.0 port-seconds,
        # keeping the Java ratio of 10 checks per 80-reload
        # charge; Java wall time is 8 ticks ~= 0.13s) and
        # returns `{"check_due": bool, "timer_elapsed": float}`:
        # due when the gate is open (potential_efficiency > 0
        # AND reload_counter >= 80.0) AND the interval elapsed
        # (timer_elapsed >= 8.0, the Interval.check `>=`); a
        # fresh frame (no `timer_elapsed` key -- a fresh
        # Interval, whose slots start at 0 over `times = new
        # float[capacity];`, Interval.java:7, while global
        # Time.time is long past 8 at any real placement) is due
        # on its first gated consult; a due check restarts the
        # elapsed clock at 0.0 (the `if(got) times[id] =
        # Time.time;` stamp); a closed gate never consumes the
        # due-ness -- the elapsed clock keeps running, so the
        # check stays due until the gate opens (the Interval
        # property: the timer is only consulted when the first
        # two conjuncts hold, and Time.time keeps advancing
        # while they do not). The backward-time clause
        # (`Time.time < times[id]`) is not modeled: the port's
        # relative clock never rewinds. The driver calls the
        # timer AFTER the N2192 charge (the Java order: the
        # charge runs inside the gate condition before the timer
        # consult) and BEFORE the N2195 scan, stamps
        # `timer_elapsed` and `timer_check_due` on the frame,
        # and runs the scan ONLY when the check is due (Java
        # :74-79 live inside the :73 if); the N2194 fire still
        # runs every tick for its heat decay (ShockwaveTower.java:104,
        # outside the gate) but fires only when
        # `timer_check_due` is true (absent means due, the
        # backward-compatible default for N2194's direct calls).
        # No RNG. Two new result symbols: the check-due flag
        # and the elapsed clock.
        self.assertEqual(
            ledger['N2200']['source_symbols'],
            [
                'source_shockwave_tower_timer_state_result.check_due',
                'source_shockwave_tower_timer_state_result.timer_elapsed',
            ],
        )
        for name in ledger['N2200']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
                    'arc-core/src/arc/util/Interval.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_timer_state_result.check_due': 'SourceShockwaveTowerBuildState.source_shockwave_tower_timer_state',
                    'source_shockwave_tower_timer_state_result.timer_elapsed': 'SourceShockwaveTowerBuildState.source_shockwave_tower_timer_state',
                }[name])
        self.assertEqual(ledger['N2200']['runtime_proof'], '/root/C07ShockwaveTowerTimerCadenceProof')
        self.assertEqual(
            ledger['N2200']['tests'],
            [
                'test_c07_shockwave_tower_timer_cadence_registration',
                'test_all_c07_shockwave_tower_timer_cadence_input_evidence_is_exact',
                'test_shockwave_tower_timer_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_timer_cadence',
            ],
        )
        self.assertTrue(ledger['N2200']['deferred_exprs'])

    def test_all_c07_shockwave_tower_timer_cadence_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2200']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_timer_state_result.check_due': 'SourceShockwaveTowerBuildState.source_shockwave_tower_timer_state',
                    'source_shockwave_tower_timer_state_result.timer_elapsed': 'SourceShockwaveTowerBuildState.source_shockwave_tower_timer_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'arc-core/src/arc/util/Interval.java',
            'arc-core/src/arc/util/Time.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/world/Tile.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2200']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_timer_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The timer cadence lives on the shockwave-tower build
        # state: ShockwaveTowerBuild.updateTile fires its wave
        # only when the reload counter reaches reload AND the
        # per-building timer elapses (ShockwaveTower.java:73,
        # `if(potentialEfficiency > 0 && (reloadCounter +=
        # edelta()) >= reload && timer(timerCheck,
        # checkInterval)){` with :31, `public float
        # checkInterval = 8f;`, and :23, `public int timerCheck
        # = timers ++;`, over `public int timers = 0;`,
        # Block.java:231). The timer consult is
        # TimerComp.timer (`public boolean timer(int index,
        # float time){` / `if(Float.isInfinite(time)) return
        # false;` / `return timer.get(index, time);`,
        # TimerComp.java:10-13, over `transient Interval timer
        # = new Interval(6);`, TimerComp.java:9), and
        # Interval.get stamps the slot on a due check
        # (`boolean got = check(id, time);` / `if(got)
        # times[id] = Time.time;`, Interval.java:23-24) when the
        # global tick clock has advanced past the interval
        # (`return Time.time - times[id] >= time || Time.time <
        # times[id];`, Interval.java:29, over `times = new
        # float[capacity];`, Interval.java:7 -- fresh slots
        # start at 0) -- and Time.time is a tick clock
        # (`Math.min(Core.graphics.getDeltaTime() * 60f, 3f)`,
        # Time.java:26, with `timeRaw += delta;` / `time =
        # (float)timeRaw;`, Time.java:70-75), so checkInterval
        # 8f is 8 ticks ~= 0.13s in Java, and 8.0 on the port's
        # seconds driver clock (the N2190 refresh / N2192
        # charge precedent). The pure function
        # (source_shockwave_tower_timer_state) takes the frame
        # and the tick delta and returns `{"check_due": bool,
        # "timer_elapsed": float}`: due when the gate is open
        # (potential_efficiency > 0 AND reload_counter >=
        # 80.0, the per-def reload, Blocks.java:2044, `reload =
        # 80f;`) AND the interval elapsed (timer_elapsed >=
        # 8.0); a fresh frame (no `timer_elapsed` key) is due
        # on its first gated consult (a fresh Interval while
        # global Time.time is long past 8); a due check restarts
        # the elapsed clock at 0.0; a closed gate never consumes
        # the due-ness -- the elapsed clock keeps running, so a
        # check that was due while unpowered stays due when
        # power returns. The driver calls the timer AFTER the
        # N2192 charge and BEFORE the N2195 scan, stamps
        # `timer_elapsed` and `timer_check_due`, runs the scan
        # ONLY when the check is due, and the N2194 fire reads
        # `timer_check_due` (absent means due) so it still runs
        # every tick for its heat decay (ShockwaveTower.java:104,
        # `heat = Mathf.clamp(heat - Time.delta / reload *
        # cooldownMultiplier);`) but fires only on a due tick.
        # No RNG.
        self.assertIn('static func source_shockwave_tower_timer_state', shockwave_tower)
        # The timer cases, pinned as the pure function's
        # decision structure: the frame carries the gate inputs
        # (`potential_efficiency`, `reload_counter`) and the
        # elapsed clock (`timer_elapsed`, absent on a fresh
        # frame). Due is gate-open AND (fresh OR elapsed >=
        # 8.0); a due check returns elapsed 0.0; otherwise the
        # elapsed clock advances by the tick delta. The driver
        # calls the timer after the charge and before the scan,
        # stamps `timer_elapsed` and `timer_check_due`, and
        # gates the scan on the due flag; the fire reads the
        # due flag (absent means due).
        self.assertIn('frame.get("timer_elapsed", null)', shockwave_tower)
        self.assertIn('frame.get("potential_efficiency", 0.0)', shockwave_tower)
        self.assertIn('frame.get("reload_counter", 0.0)', shockwave_tower)
        self.assertIn('elapsed_value >= 8.0', shockwave_tower)
        self.assertIn('return {"check_due": true, "timer_elapsed": 0.0}', shockwave_tower)
        self.assertIn('return {"check_due": false, "timer_elapsed": elapsed_value}', shockwave_tower)
        self.assertIn('source_shockwave_tower_timer_state(frame, seconds)', shockwave_tower)
        self.assertIn('frame["timer_elapsed"]', shockwave_tower)
        self.assertIn('frame["timer_check_due"]', shockwave_tower)
        self.assertIn('frame.get("timer_check_due", null)', shockwave_tower)
        with self.subTest(case='timer due on a fresh frame'):
            self.assertIn('return {"check_due": true, "timer_elapsed": 0.0}', shockwave_tower)
        with self.subTest(case='timer not due below the interval'):
            self.assertIn('return {"check_due": false, "timer_elapsed": elapsed_value}', shockwave_tower)
        with self.subTest(case='timer due at the interval'):
            self.assertIn('return {"check_due": true, "timer_elapsed": 0.0}', shockwave_tower)
        with self.subTest(case='timer gate closed without power'):
            self.assertIn('return {"check_due": false, "timer_elapsed": elapsed_value}', shockwave_tower)
        with self.subTest(case='timer gate closed below reload'):
            self.assertIn('return {"check_due": false, "timer_elapsed": elapsed_value}', shockwave_tower)
        with self.subTest(case='timer due-ness persists across unpowered ticks'):
            self.assertIn('return {"check_due": true, "timer_elapsed": 0.0}', shockwave_tower)
        with self.subTest(case='live driver fire gated on the timer'):
            self.assertIn('source_shockwave_tower_timer_state(frame, seconds)', shockwave_tower)
        with self.subTest(case='live driver scan gated on the timer'):
            self.assertIn('frame["timer_check_due"]', shockwave_tower)
        self.assertIn('public class ShockwaveTower extends Block{', shockwave_tower)
        self.assertIn('public class ShockwaveTowerBuild extends Building{', shockwave_tower)
        self.assertIn('public int timerCheck = timers ++;', shockwave_tower)
        self.assertIn('public int timers = 0;', shockwave_tower)
        self.assertIn('public float range = 110f;', shockwave_tower)
        self.assertIn('public float reload = 60f * 1.5f;', shockwave_tower)
        self.assertIn('public float bulletDamage = 160;', shockwave_tower)
        self.assertIn('public float falloffCount = 20f;', shockwave_tower)
        self.assertIn('public float shake = 2f;', shockwave_tower)
        self.assertIn('public float checkInterval = 8f;', shockwave_tower)
        self.assertIn('public float cooldownMultiplier = 1f;', shockwave_tower)
        self.assertIn('public Sound shootSound = Sounds.shockwaveTower;', shockwave_tower)
        self.assertIn('public Effect hitEffect = Fx.hitSquaresColor;', shockwave_tower)
        self.assertIn('public Effect waveEffect = Fx.pointShockwave;', shockwave_tower)
        self.assertIn('public float reloadCounter = Mathf.random(reload);', shockwave_tower)
        self.assertIn('public float heat = 0f;', shockwave_tower)
        self.assertIn('public Seq<Bullet> targets = new Seq<>();', shockwave_tower)
        self.assertIn('public void updateTile(){', shockwave_tower)
        self.assertIn('if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', shockwave_tower)
        self.assertIn('targets.clear();', shockwave_tower)
        self.assertIn('Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {', shockwave_tower)
        self.assertIn('if(b.team != team && b.type.hittable){', shockwave_tower)
        self.assertIn('targets.add(b);', shockwave_tower)
        self.assertIn('if(targets.size > 0){', shockwave_tower)
        self.assertIn('heat = 1f;', shockwave_tower)
        self.assertIn('reloadCounter = 0f;', shockwave_tower)
        self.assertIn('waveEffect.at(x, y, range, waveColor);', shockwave_tower)
        self.assertIn('shootSound.at(x, y, 1f + Mathf.range(0.15f), 1f);', shockwave_tower)
        self.assertIn('Effect.shake(shake, shake, this);', shockwave_tower)
        self.assertIn('float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);', shockwave_tower)
        self.assertIn('for(var target : targets){', shockwave_tower)
        self.assertIn('if(target.damage > waveDamage){', shockwave_tower)
        self.assertIn('target.damage -= waveDamage;', shockwave_tower)
        self.assertIn('target.remove();', shockwave_tower)
        self.assertIn('hitEffect.at(target.x, target.y, waveColor);', shockwave_tower)
        self.assertIn('if(team == state.rules.defaultTeam){', shockwave_tower)
        self.assertIn('Events.fire(Trigger.shockwaveTowerUse);', shockwave_tower)
        self.assertIn('shockwaveTowerUse,', shockwave_tower)
        self.assertIn('public Team defaultTeam = Team.sharded;', shockwave_tower)
        self.assertIn('sharded = new Team(1, "sharded", Pal.accent.cpy(), Color.valueOf("ffd37f"), Color.valueOf("eab678"), Color.valueOf("d4816b")),', shockwave_tower)
        self.assertIn('heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);', shockwave_tower)
        self.assertIn('if(sensor == LAccess.progress) return reloadCounter / reload;', shockwave_tower)
        self.assertIn('return heat;', shockwave_tower)
        self.assertIn('return reloadCounter < reload;', shockwave_tower)
        self.assertIn('public boolean shouldConsume(){', shockwave_tower)
        self.assertIn('public boolean canConsume(){', shockwave_tower)
        self.assertIn('return potentialEfficiency > 0;', shockwave_tower)
        self.assertIn('return efficiency * delta();', shockwave_tower)
        self.assertIn('potentialEfficiency = efficiency;', shockwave_tower)
        self.assertIn('boolean update = shouldConsume() && productionValid();', shockwave_tower)
        self.assertIn('if(!update){', shockwave_tower)
        self.assertIn('efficiency = optionalEfficiency = 0f;', shockwave_tower)
        self.assertIn('return enabled;', shockwave_tower)
        self.assertIn('consumePower(100f / 60f);', shockwave_tower)
        self.assertIn('consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));', shockwave_tower)
        self.assertIn('range = 170f;', shockwave_tower)
        self.assertIn('reload = 80f;', shockwave_tower)
        self.assertIn('size = 3;', shockwave_tower)
        self.assertIn('return build.power.status;', shockwave_tower)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', shockwave_tower)
        self.assertIn('hasConsumers = consumers.length > 0;', shockwave_tower)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', shockwave_tower)
        self.assertIn('update = true;', shockwave_tower)
        self.assertIn('solid = true;', shockwave_tower)
        self.assertIn('public static final int tilesize = 8;', shockwave_tower)
        self.assertIn('return x * tilesize;', shockwave_tower)
        self.assertIn('return block().offset + worldx();', shockwave_tower)
        self.assertIn('public boolean timer(int index, float time){', shockwave_tower)
        self.assertIn('if(Float.isInfinite(time)) return false;', shockwave_tower)
        self.assertIn('return timer.get(index, time);', shockwave_tower)
        self.assertIn('transient Interval timer = new Interval(6);', shockwave_tower)
        self.assertIn('boolean got = check(id, time);', shockwave_tower)
        self.assertIn('if(got) times[id] = Time.time;', shockwave_tower)
        self.assertIn('return Time.time - times[id] >= time || Time.time < times[id];', shockwave_tower)
        self.assertIn('times = new float[capacity];', shockwave_tower)
        self.assertIn('Math.min(Core.graphics.getDeltaTime() * 60f, 3f)', shockwave_tower)
        self.assertIn('timeRaw += delta;', shockwave_tower)
        self.assertIn('time = (float)timeRaw;', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_tick_buildings_state', shockwave_tower)
        # The proof's keys drive the pure timer (due on a fresh
        # frame / not due below the interval / due at the
        # interval / gate closed without power / gate closed
        # below reload / due-ness persists across unpowered
        # ticks) plus the live tick (the driver gates the fire
        # and the scan on the timer). There are no sense /
        # warmup keys: sense(LAccess.progress) (:110), warmup()
        # (:117) and the cyanogen liquid consumer
        # (Blocks.java:2041) wait for their own slices.
        proof = SHOCKWAVE_TOWER_TIMER_CADENCE_PROOF.read_text(encoding='utf-8')
        for key in [
            'timer_due_on_fresh_frame',
            'timer_not_due_below_interval',
            'timer_due_at_interval',
            'timer_gate_closed_without_power',
            'timer_gate_closed_below_reload',
            'timer_due_persists_across_unpowered_ticks',
            'live_driver_fire_gated_on_timer',
            'live_driver_scan_gated_on_timer',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_shockwave_tower_timer_cadence(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerTimerCadenceProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_TIMER_CADENCE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'timer_due_on_fresh_frame',
            'timer_not_due_below_interval',
            'timer_due_at_interval',
            'timer_gate_closed_without_power',
            'timer_gate_closed_below_reload',
            'timer_due_persists_across_unpowered_ticks',
            'live_driver_fire_gated_on_timer',
            'live_driver_scan_gated_on_timer',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
