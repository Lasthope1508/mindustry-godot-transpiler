import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_FIRE_EFFECTS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerFireEffectsProof.gd'


class C07ShockwaveTowerFireEffectsTests(unittest.TestCase):
    def test_c07_shockwave_tower_fire_effects_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2197']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_effects_state')
        # N2194's fire gate sets heat 1f and resets the counter
        # (ShockwaveTower.java:82-83, `heat = 1f;` /
        # `reloadCounter = 0f;`), N2195's scan stamps the observed
        # `targets_count`, and N2196's wave damage applies the
        # wave -- but the fire's Fx / sound / shake
        # (ShockwaveTower.java:84-86, `waveEffect.at(x, y, range,
        # waveColor);` / `shootSound.at(x, y, 1f +
        # Mathf.range(0.15f), 1f);` / `Effect.shake(shake, shake,
        # this);`) have NO pure function in the port -- a firing
        # tower resets its counter, heats up and damages bullets
        # while no wave effect, no sound and no shake is ever
        # recorded. N2197 owns the fire effects. The pure
        # function needs only the tower's world position (`x`/`y`
        # frame keys, derived by the driver from the placement
        # cell: Tile.java, `return x * tilesize;` / `return
        # block().offset + worldx();`, tilesize 8, offset 0 for
        # size 3) and returns one descriptor per Java call: the
        # wave effect (Fx.pointShockwave, ShockwaveTower.java:35,
        # `public Effect waveEffect = Fx.pointShockwave;`, at the
        # tower, rotation = range 170f per-def, Blocks.java:2043,
        # color waveColor Pal.accent, ShockwaveTower.java:29),
        # the shoot sound (Sounds.shockwaveTower,
        # ShockwaveTower.java:30, `public Sound shootSound =
        # Sounds.shockwaveTower;`, at the tower, pitch 1f +
        # Mathf.range(0.15f) -- a DETERMINISTIC pitch range
        # [0.85, 1.15], never a sampled pitch, since the pure
        # function takes no RNG -- volume 1f), and the shake
        # (Effect.shake(float intensity, float duration, Position
        # loc), Effect.java:210-211, called with (shake, shake,
        # this): intensity 2f, duration 2f, ShockwaveTower.java:27,
        # `public float shake = 2f;`, at the tower). Absent `x`/`y`
        # means "no effects": wave_effect / shoot_sound / shake
        # null, has_fire_effects false, and the driver stamps
        # nothing (the N2190 / N2195 / N2196 precedent) -- never a
        # fabricated descriptor. The driver calls the effects
        # AFTER the N2194 fire and ONLY when the fire fired, and
        # BEFORE the N2196 wave damage (the Java order :84-86
        # before :87): the effects live inside the fire gate in
        # Java (:81-96), so a charged-but-unfired tick spawns
        # nothing, and the fire gate already established
        # targets.size > 0, so no separate targets check is
        # needed. Four new result symbols: the wave-effect
        # descriptor, the shoot-sound descriptor, the shake
        # descriptor, and the effects flag.
        self.assertEqual(
            ledger['N2197']['source_symbols'],
            [
                'source_shockwave_tower_fire_effects_state_result.wave_effect',
                'source_shockwave_tower_fire_effects_state_result.shoot_sound',
                'source_shockwave_tower_fire_effects_state_result.shake',
                'source_shockwave_tower_fire_effects_state_result.has_fire_effects',
            ],
        )
        for name in ledger['N2197']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_fire_effects_state_result.wave_effect': 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_effects_state',
                    'source_shockwave_tower_fire_effects_state_result.shoot_sound': 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_effects_state',
                    'source_shockwave_tower_fire_effects_state_result.shake': 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_effects_state',
                    'source_shockwave_tower_fire_effects_state_result.has_fire_effects': 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_effects_state',
                }[name])
        self.assertEqual(ledger['N2197']['runtime_proof'], '/root/C07ShockwaveTowerFireEffectsProof')
        self.assertEqual(
            ledger['N2197']['tests'],
            [
                'test_c07_shockwave_tower_fire_effects_registration',
                'test_all_c07_shockwave_tower_fire_effects_input_evidence_is_exact',
                'test_shockwave_tower_fire_effects_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_fire_effects',
            ],
        )
        self.assertTrue(ledger['N2197']['deferred_exprs'])

    def test_all_c07_shockwave_tower_fire_effects_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2197']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_fire_effects_state_result.wave_effect': 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_effects_state',
                    'source_shockwave_tower_fire_effects_state_result.shoot_sound': 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_effects_state',
                    'source_shockwave_tower_fire_effects_state_result.shake': 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_effects_state',
                    'source_shockwave_tower_fire_effects_state_result.has_fire_effects': 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_effects_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/world/Tile.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2197']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_fire_effects_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The fire effects live on the shockwave-tower build
        # state: ShockwaveTowerBuild.updateTile fires its wave
        # when the reload counter reaches reload with targets
        # observed (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){` with :81, `if(targets.size > 0){`), then, after heat = 1f and reloadCounter = 0f (:82-83), spawns the wave effect (`waveEffect.at(x, y, range, waveColor);`, ShockwaveTower.java:84, over `public Effect waveEffect = Fx.pointShockwave;`, ShockwaveTower.java:35 -- Fx.pointShockwave draws `Lines.circle(e.x, e.y, e.finpow() * e.rotation)`, Fx.java:223-228, so the `range` argument is the effect rotation and the final circle radius is range 170f per-def, Blocks.java:2043, in waveColor Pal.accent, ShockwaveTower.java:29, `public Color waveColor = Pal.accent, heatColor = Pal.turretHeat, shapeColor = Color.valueOf("f29c83");`, Pal.accent = Color.valueOf("ffd37f"), Pal.java:79), plays the shoot sound (`shootSound.at(x, y, 1f + Mathf.range(0.15f), 1f);`, ShockwaveTower.java:85, over `public Sound shootSound = Sounds.shockwaveTower;`, ShockwaveTower.java:30 -- pitch 1f +/- 0.15f random, volume 1f), and shakes the screen (`Effect.shake(shake, shake, this);`, ShockwaveTower.java:86, over `public float shake = 2f;`, ShockwaveTower.java:27, and `public static void shake(float intensity, float duration, Position loc){`, Effect.java:210-211 -- intensity 2f, duration 2f, at the tower). The port spawns no real Fx / sound / shake (no Godot equivalents are wired), so the pure function stamps one descriptor per Java call instead of spawning it: `{"effect": "pointShockwave", "x": x, "y": y, "rotation": 170.0, "color": "Pal.accent"}` (the rotation IS the range argument, verbatim, not a renamed radius), `{"sound": "shockwaveTower", "x": x, "y": y, "pitch_min": 0.85, "pitch_max": 1.15, "volume": 1.0}` (the pitch is the DETERMINISTIC range of `1f + Mathf.range(0.15f)`, never a sampled value -- the pure function takes no RNG, so the scene seeds none), and `{"intensity": 2.0, "duration": 2.0, "x": x, "y": y}`. The function needs only the tower world position (`x`/`y` frame keys); absent `x`/`y` means "no effects": `{"wave_effect": null, "shoot_sound": null, "shake": null, "has_fire_effects": false}` and the driver stamps nothing (the N2190 / N2195 / N2196 precedent) -- never a fabricated descriptor. The driver calls the effects AFTER the N2194 fire, ONLY when the fire fired, and BEFORE the N2196 wave damage (the Java order :84-86 before :87), stamping `frame["wave_effect"]` / `frame["shoot_sound"]` / `frame["shake"]` only when has_fire_effects is true -- the effects live inside the fire gate in Java (:81-96), so a charged-but-unfired tick spawns nothing, and the stamped descriptors persist on the frame until the next fire (like heat / the N2196 outcomes).
        self.assertIn('static func source_shockwave_tower_fire_effects_state', shockwave_tower)
        # The fire-effects cases, pinned as the pure function's
        # decision structure: the frame carries the tower world
        # position as `x`/`y` (float). The wave effect is
        # Fx.pointShockwave at the tower with rotation = range
        # 170f per-def and color Pal.accent. The shoot sound is
        # Sounds.shockwaveTower at the tower with the
        # deterministic pitch range [0.85, 1.15] (1f +
        # Mathf.range(0.15f)) and volume 1.0. The shake is
        # intensity 2.0, duration 2.0 at the tower. The function
        # returns `{"wave_effect": {...}, "shoot_sound": {...},
        # "shake": {...}, "has_fire_effects": true}` when the
        # position is present and `{"wave_effect": null,
        # "shoot_sound": null, "shake": null, "has_fire_effects":
        # false}` when it is not. The driver calls it after the
        # N2194 fire, only when the fire fired, before the N2196
        # wave damage, and stamps frame["wave_effect"] /
        # frame["shoot_sound"] / frame["shake"] only when
        # has_fire_effects is true.
        self.assertIn('frame.get("x", null)', shockwave_tower)
        self.assertIn('frame.get("y", null)', shockwave_tower)
        self.assertIn('"effect": "pointShockwave"', shockwave_tower)
        self.assertIn('"rotation": 170.0', shockwave_tower)
        self.assertIn('"color": "Pal.accent"', shockwave_tower)
        self.assertIn('"sound": "shockwaveTower"', shockwave_tower)
        self.assertIn('"pitch_min": 0.85', shockwave_tower)
        self.assertIn('"pitch_max": 1.15', shockwave_tower)
        self.assertIn('"volume": 1.0', shockwave_tower)
        self.assertIn('"intensity": 2.0', shockwave_tower)
        self.assertIn('"duration": 2.0', shockwave_tower)
        self.assertIn('return {"wave_effect": null, "shoot_sound": null, "shake": null, "has_fire_effects": false}', shockwave_tower)
        self.assertIn('return {"wave_effect": wave_effect, "shoot_sound": shoot_sound, "shake": shake, "has_fire_effects": true}', shockwave_tower)
        with self.subTest(case='wave effect spawns at the tower with range rotation and accent color'):
            self.assertIn('"effect": "pointShockwave"', shockwave_tower)
        with self.subTest(case='shoot sound carries the deterministic pitch range'):
            self.assertIn('"pitch_min": 0.85', shockwave_tower)
        with self.subTest(case='shake carries intensity and duration 2.0'):
            self.assertIn('"intensity": 2.0', shockwave_tower)
        with self.subTest(case='absent position stamps nothing'):
            self.assertIn('return {"wave_effect": null, "shoot_sound": null, "shake": null, "has_fire_effects": false}', shockwave_tower)
        with self.subTest(case='live driver stamps fire effects only on fire'):
            self.assertIn('source_shockwave_tower_fire_effects_state(frame)', shockwave_tower)
        self.assertIn('source_shockwave_tower_fire_effects_state(frame)', shockwave_tower)
        self.assertIn('frame["wave_effect"]', shockwave_tower)
        self.assertIn('frame["shoot_sound"]', shockwave_tower)
        self.assertIn('frame["shake"]', shockwave_tower)
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
        self.assertIn('return timer.get(index, time);', shockwave_tower)
        self.assertIn('transient Interval timer = new Interval(6);', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_tick_buildings_state', shockwave_tower)
        # The proof's keys drive the pure fire effects (wave
        # effect at the tower / shoot sound pitch range / shake
        # intensity and duration / absent position stamps
        # nothing) plus the live tick (the driver stamps the
        # three descriptors only on a fire tick). There are no
        # hitEffect / event / sense / warmup keys: the hitEffect
        # spawning (:95), the shockwaveTowerUse event (:97-99),
        # sense(LAccess.progress) (:110), warmup() (:117) and
        # the cyanogen liquid consumer (Blocks.java:2041) wait
        # for their own slices, and the timer cadence (:73,
        # checkInterval 8f) waits for a per-building-timer slice.
        proof = SHOCKWAVE_TOWER_FIRE_EFFECTS_PROOF.read_text(encoding='utf-8')
        for key in [
            'wave_effect_spawns_at_tower',
            'shoot_sound_pitch_range',
            'shake_intensity_and_duration',
            'absent_position_stamps_nothing',
            'live_driver_stamps_fire_effects_on_fire',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_shockwave_tower_fire_effects(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerFireEffectsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_FIRE_EFFECTS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'wave_effect_spawns_at_tower',
            'shoot_sound_pitch_range',
            'shake_intensity_and_duration',
            'absent_position_stamps_nothing',
            'live_driver_stamps_fire_effects_on_fire',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
