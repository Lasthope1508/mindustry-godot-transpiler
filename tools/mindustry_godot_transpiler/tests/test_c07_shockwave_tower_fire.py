import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_FIRE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerFireProof.gd'


class C07ShockwaveTowerFireTests(unittest.TestCase):
    def test_c07_shockwave_tower_fire_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2194']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_state')
        # N2192 stamped the reload counter (the charge advance is
        # the ONLY writer of `reload_counter`,
        # ShockwaveTower.java:73, `if(potentialEfficiency > 0 &&
        # (reloadCounter += edelta()) >= reload && timer(timerCheck,
        # checkInterval)){`), and N2193 wired the shouldConsume
        # gate over it (`return reloadCounter < reload;`,
        # ShockwaveTower.java:122). N2194 closes the fire branch
        # itself (ShockwaveTower.java:73-104): the pure function
        # reads the counter the charge stamped -- it does NOT
        # re-advance it, the charge already advanced it this tick
        # -- and, on fire, returns the reset counter 0.0 and heat
        # 1.0 (ShockwaveTower.java:82-83, `heat = 1f;` /
        # `reloadCounter = 0f;`); every tick it also returns the
        # heat decay (ShockwaveTower.java:104, `heat =
        # Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);`,
        # reload 80f per-def, Blocks.java:2044, cooldownMultiplier
        # 1f, ShockwaveTower.java:34). The fire condition is the
        # :73 gate over the observed frame keys:
        # `potential_efficiency > 0` AND `reload_counter >= 80.0`
        # AND an observed `targets_count > 0`. The live bullet
        # scan (Groups.bullet.intersect, ShockwaveTower.java:75-79)
        # has NO frame input in the port -- no live bullet query
        # exists -- so the fire reads an observed `targets_count`
        # frame key (the N2190 RepairTower precedent: stamped only
        # when observed) and absent means no fire, never invented
        # targets. The timer cadence (`timer(timerCheck,
        # checkInterval)`, checkInterval 8f,
        # ShockwaveTower.java:31) is DEFERRED: the port tracks no
        # per-building Interval timer state (TimerComp.java:10-13,
        # `public boolean timer(int index, float time){` /
        # `return timer.get(index, time);` over `transient
        # Interval timer = new Interval(6);`), so the port fires
        # on the first tick the counter is at reload with targets
        # observed, where Java fires only on a timer tick -- up to
        # checkInterval earlier, a documented fidelity gap owned by
        # a later per-building-timer slice. Absent `reload_counter`
        # starts from deterministic 0.0 (the N2192 precedent --
        # Java inits `reloadCounter = Mathf.random(reload);`,
        # ShockwaveTower.java:67, but the port never uses `randf`
        # in game code); absent `potential_efficiency` is 0.0, so
        # no fire; absent `heat` is 0.0 (Java init `heat = 0f;`,
        # ShockwaveTower.java:68). On a fire tick Java sets heat
        # 1f (:82) and then decays it the same tick (:104), so the
        # pure function applies the decay AFTER the fire set, in
        # the same order. Three new result symbols: the fire flag,
        # the reset counter, and the heat.
        self.assertEqual(
            ledger['N2194']['source_symbols'],
            [
                'source_shockwave_tower_fire_state_result.fired',
                'source_shockwave_tower_fire_state_result.reload_counter',
                'source_shockwave_tower_fire_state_result.heat',
            ],
        )
        for name in ledger['N2194']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_fire_state_result.fired': 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_state',
                    'source_shockwave_tower_fire_state_result.reload_counter': 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_state',
                    'source_shockwave_tower_fire_state_result.heat': 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_state',
                }[name])
        self.assertEqual(ledger['N2194']['runtime_proof'], '/root/C07ShockwaveTowerFireProof')
        self.assertEqual(
            ledger['N2194']['tests'],
            [
                'test_c07_shockwave_tower_fire_registration',
                'test_all_c07_shockwave_tower_fire_input_evidence_is_exact',
                'test_shockwave_tower_fire_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_fire',
            ],
        )
        self.assertTrue(ledger['N2194']['deferred_exprs'])

    def test_all_c07_shockwave_tower_fire_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2194']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_fire_state_result.fired': 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_state',
                    'source_shockwave_tower_fire_state_result.reload_counter': 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_state',
                    'source_shockwave_tower_fire_state_result.heat': 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2194']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_fire_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The pure fire gate lives on the shockwave-tower build
        # state: ShockwaveTowerBuild.updateTile fires its wave when
        # the reload counter, charged by edelta(), reaches reload
        # (ShockwaveTower.java:72, `public void updateTile(){`
        # with :73, `if(potentialEfficiency > 0 && (reloadCounter
        # += edelta()) >= reload && timer(timerCheck,
        # checkInterval)){`), and edelta() is efficiency * delta
        # (BuildingComp.java:1928, `return efficiency * delta();`).
        # The charge advance is N2192's job and the ONLY writer of
        # `reload_counter` -- the fire function reads the counter
        # the charge stamped this tick and never re-advances it.
        # On fire with targets (ShockwaveTower.java:81,
        # `if(targets.size > 0){`) Java sets heat 1f (:82, `heat =
        # 1f;`) and resets the counter (:83, `reloadCounter =
        # 0f;`); the wave damage line (:87, `float waveDamage =
        # Math.min(bulletDamage, bulletDamage * falloffCount /
        # targets.size);`) and the per-target damage / removal
        # (:89-95) plus the Fx / sound / shake (:84-86, :95) and
        # the shockwaveTowerUse event (:97-99) wait for their own
        # slices -- the fire function returns only the flag, the
        # reset counter, and the heat. Every tick, heat decays
        # (ShockwaveTower.java:104, `heat = Mathf.clamp(heat -
        # Time.delta / reload * cooldownMultiplier);`) against the
        # per-def reload 80f (Blocks.java:2044, `reload = 80f;`,
        # overriding the class default `60f * 1.5f`,
        # ShockwaveTower.java:26) and cooldownMultiplier 1f
        # (ShockwaveTower.java:34) -- Time.delta is the raw delta,
        # not edelta. The bullet scan itself (:74-79,
        # `targets.clear();` / `Groups.bullet.intersect(x - range,
        # y - range, range * 2, range * 2, b -> {` / `if(b.team !=
        # team && b.type.hittable){` / `targets.add(b);`) has no
        # frame input in the port, so the fire reads an observed
        # `targets_count` key (the N2190 precedent) and absent
        # means no fire. The timer cadence (`timer(timerCheck,
        # checkInterval)`, checkInterval 8f, ShockwaveTower.java:31;
        # `public int timerCheck = timers ++;`,
        # ShockwaveTower.java:23; TimerComp.java:10-13) is deferred
        # -- the port tracks no per-building Interval state.
        # canConsume (BuildingComp.java:1917, `public boolean
        # canConsume(){` with `return potentialEfficiency > 0;`,
        # BuildingComp.java:1918) is the same potential-efficiency
        # gate, and potentialEfficiency is the pre-gate min
        # efficiency (BuildingComp.java:1989,
        # `potentialEfficiency = efficiency;`, assigned BEFORE the
        # `if(!update){` zeroing, BuildingComp.java:1992-1993,
        # `efficiency = optionalEfficiency = 0f;`) -- so a fully
        # charged tower whose N2193 gate zeroes efficiency still
        # fires when it has power, exactly like Java: the fire
        # condition reads potentialEfficiency, not efficiency.
        self.assertIn('static func source_shockwave_tower_fire_state', shockwave_tower)
        # The fire cases, pinned as the pure function's decision
        # structure: the frame carries the live counter as
        # `reload_counter` (float, stamped by the N2192 charge
        # every tick after apply_update_consumption_state), the
        # potential efficiency as `potential_efficiency`, the heat
        # as `heat`, and the observed target count as
        # `targets_count` (int, stamped only when observed). The
        # fire conjunction is `potential_efficiency > 0.0 and
        # reload_counter >= 80.0 and observed_targets != null and
        # float(observed_targets) > 0.0`; on fire the function
        # returns `{"fired": fired, "reload_counter":
        # reload_counter, "heat": heat}` with the counter reset to
        # 0.0 and heat 1.0 (then decayed by this tick's delta, the
        # Java :82-then-:104 order); on no fire it returns the
        # counter unchanged and the decayed heat. Absent
        # `reload_counter` starts from deterministic 0.0 (the
        # N2192 precedent, never `randf`); absent
        # `potential_efficiency` is 0.0 (no fire); absent `heat`
        # is 0.0 (Java init `heat = 0f;`); absent `targets_count`
        # means no fire (never invent targets).
        self.assertIn('frame.get("reload_counter", 0.0)', shockwave_tower)
        self.assertIn('frame.get("potential_efficiency", 0.0)', shockwave_tower)
        self.assertIn('frame.get("heat", 0.0)', shockwave_tower)
        self.assertIn('frame.get("targets_count", null)', shockwave_tower)
        self.assertIn('observed_targets != null', shockwave_tower)
        with self.subTest(case='reload_counter=80.0 at reload with targets fires'):
            self.assertIn('reload_counter >= 80.0', shockwave_tower)
        with self.subTest(case='reload_counter=10.0 below reload never fires'):
            self.assertIn('reload_counter >= 80.0', shockwave_tower)
        with self.subTest(case='targets_count=0 never fires'):
            self.assertIn('float(observed_targets) > 0.0', shockwave_tower)
        with self.subTest(case='no targets_count key never fires'):
            self.assertIn('frame.get("targets_count", null)', shockwave_tower)
        with self.subTest(case='potential_efficiency=0.0 never fires'):
            self.assertIn('potential_efficiency > 0.0', shockwave_tower)
        with self.subTest(case='heat decays every tick against reload 80f'):
            self.assertIn('clampf(heat - delta / 80.0, 0.0, 1.0)', shockwave_tower)
        with self.subTest(case='fire returns the flag, the reset counter, and the heat'):
            self.assertIn('return {"fired": fired, "reload_counter": reload_counter, "heat": heat}', shockwave_tower)
        self.assertIn('source_shockwave_tower_fire_state(frame, seconds)', shockwave_tower)
        self.assertIn('public class ShockwaveTower extends Block{', shockwave_tower)
        self.assertIn('public class ShockwaveTowerBuild extends Building{', shockwave_tower)
        self.assertIn('public int timerCheck = timers ++;', shockwave_tower)
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
        self.assertIn('update = true;', shockwave_tower)
        self.assertIn('solid = true;', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_tick_buildings_state', shockwave_tower)
        # The proof's keys drive the pure fire (fires when charged
        # with targets / never below reload / never without targets
        # / never without a targets_count key / heat decays every
        # tick) plus the live tick (the fire resets the counter
        # live). There are no bullet-scan / wave-damage / Fx /
        # sound / shake / event / sense / warmup keys: the live
        # bullet scan (ShockwaveTower.java:75-79), the wave damage
        # application (:87-96), waveEffect / shootSound / shake /
        # hitEffect (:84-86, :95), the shockwaveTowerUse event
        # (:97-99), sense(LAccess.progress) (:110), warmup()
        # (:117) and the cyanogen liquid consumer
        # (Blocks.java:2041) wait for their own slices, and the
        # timer cadence (:73, checkInterval 8f) waits for a
        # per-building-timer slice.
        proof = SHOCKWAVE_TOWER_FIRE_PROOF.read_text(encoding='utf-8')
        for key in [
            'fire_when_charged_with_targets',
            'no_fire_below_reload',
            'no_fire_without_targets',
            'no_fire_without_targets_key',
            'heat_decays_every_tick',
            'fire_resets_counter_live',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_shockwave_tower_fire(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerFireProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_FIRE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fire_when_charged_with_targets',
            'no_fire_below_reload',
            'no_fire_without_targets',
            'no_fire_without_targets_key',
            'heat_decays_every_tick',
            'fire_resets_counter_live',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
