import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_WAVE_EFFECTS_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerWaveEffectsRowsProof.gd'
SHOCKWAVE_TOWER_WAVE_EFFECTS_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerWaveEffectsRowsProof.tscn'


class C07ShockwaveTowerWaveEffectsRowsTests(unittest.TestCase):
    def test_c07_shockwave_tower_wave_effects_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2470']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_wave_effects_state')
        # The ShockwaveTower updateTile STATE is live
        # (N2247 advance): the fire gate + bullet scan
        # + wave damage + fire reset + heat decay run
        # every tick -- but the advance fires SILENTLY
        # (pure result only): the wave effect / sound /
        # shake rows (:84-86) and the per-target hit
        # effect (:95) were never modeled. N2470 ports
        # them as ONE pure-only pure (the N2468
        # precedent, NO tick wiring):
        # source_shockwave_tower_wave_effects_state(
        # fired, x, y, range_value, pitch_roll,
        # targets) returns wave_effect_call {token
        # "Fx.pointShockwave", x, y, range, color
        # "Pal.accent"} + shoot_sound_call {token
        # "shockwaveTower", pitch 1f + pitch_roll,
        # volume 1.0} + shake_call {intensity 2.0,
        # duration 2.0} + hit_effect_calls (an Array
        # of {token "Fx.hitSquaresColor", x, y, color
        # "Pal.accent"} -- ONE per target, empty when
        # targets is empty), all calls null (hit list
        # empty) when the gate fails. NO sound is
        # played, NO effect spawned, NO camera shaken
        # -- the audio/effect call sites wait for
        # their own slices. The pitch roll is an
        # ALREADY-ROLLED caller-supplied input
        # (Mathf.range(0.15f) in [-0.15, 0.15]) -- NO
        # RNG in the pure (the N2421 precedent). Four
        # new result symbols, in Java updateTile
        # order: the wave call records (:84-86), then
        # the hit call records (:95).
        self.assertEqual(
            ledger['N2470']['source_symbols'],
            [
                'source_shockwave_tower_wave_effects_state_result.wave_effect_call',
                'source_shockwave_tower_wave_effects_state_result.shoot_sound_call',
                'source_shockwave_tower_wave_effects_state_result.shake_call',
                'source_shockwave_tower_wave_effects_state_result.hit_effect_calls',
            ],
        )
        expected_owners = {
            'source_shockwave_tower_wave_effects_state_result.wave_effect_call': 'SourceShockwaveTowerBuildState.source_shockwave_tower_wave_effects_state',
            'source_shockwave_tower_wave_effects_state_result.shoot_sound_call': 'SourceShockwaveTowerBuildState.source_shockwave_tower_wave_effects_state',
            'source_shockwave_tower_wave_effects_state_result.shake_call': 'SourceShockwaveTowerBuildState.source_shockwave_tower_wave_effects_state',
            'source_shockwave_tower_wave_effects_state_result.hit_effect_calls': 'SourceShockwaveTowerBuildState.source_shockwave_tower_wave_effects_state',
        }
        for name in ledger['N2470']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/ShockwaveTower.java')
                self.assertEqual(symbol['godot_owner'], expected_owners[name])
        self.assertEqual(ledger['N2470']['runtime_proof'], '/root/C07ShockwaveTowerWaveEffectsRowsProof')
        self.assertEqual(
            ledger['N2470']['tests'],
            [
                'test_c07_shockwave_tower_wave_effects_rows_registration',
                'test_all_c07_shockwave_tower_wave_effects_rows_input_evidence_is_exact',
                'test_shockwave_tower_wave_effects_rows_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_wave_effects_rows',
            ],
        )
        self.assertTrue(ledger['N2470']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #141 (1-based in
        # DEFERRED-after-advances-31.py): the
        # ShockwaveTower wave effects / sound / shake
        # entry is REMOVED -- waveEffect.at +
        # shootSound.at + Effect.shake + hitEffect.at
        # are live now as pure call records, so
        # nothing of the entry remains. Net 238 - 1 =
        # 237. (The #142 wave-damage-application entry
        # and the #40 trigger entry still stand: the
        # damage application on live bullets and the
        # Events.fire(Trigger.shockwaveTowerUse) are
        # NOT in this slice's scope.)
        self.assertFalse(any(entry.startswith('ShockwaveTower wave effects / sound / shake (') for entry in ledger['N2470']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower wave damage application on live bullets (') for entry in ledger['N2470']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower trigger row (') for entry in ledger['N2470']['deferred_exprs']))
        self.assertEqual(len(ledger['N2470']['deferred_exprs']), 237)

    def test_all_c07_shockwave_tower_wave_effects_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2470']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceShockwaveTowerBuildState.source_shockwave_tower_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
            'core/src/mindustry/content/Fx.java',
            'core/src/mindustry/entities/Effect.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2470']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_wave_effects_rows_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The wave effects / sound / shake rows
        # (ShockwaveTowerBuild.updateTile(), Shockwave-
        # Tower.java:81-95): the STATE is live since
        # N2247 (the fire gate + bullet scan + wave
        # damage + fire reset + heat decay), so this
        # pure consumes the caller-evaluated fired
        # gate (the N2247 fire verdict) and reports
        # the wave effect + sound + shake + per-target
        # hit effects as pure call records (the N2468
        # precedent -- no sound played, no effect
        # spawned, no camera shaken): `if(targets.size
        # > 0){` + `waveEffect.at(x, y, range,
        # waveColor);` + `shootSound.at(x, y, 1f +
        # Mathf.range(0.15f), 1f);` + `Effect.shake(
        # shake, shake, this);` + `for(var target :
        # targets){` + `hitEffect.at(target.x,
        # target.y, waveColor);`. The fields are the
        # block fields (`public float range = 110f;` /
        # `public float shake = 2f;` / `public Sound
        # shootSound = Sounds.shockwaveTower;` /
        # `public Color waveColor = Pal.accent,
        # heatColor = Pal.turretHeat, shapeColor =
        # Color.valueOf("f29c83");` / `public Effect
        # hitEffect = Fx.hitSquaresColor;` / `public
        # Effect waveEffect = Fx.pointShockwave;`,
        # ShockwaveTower.java:25/29/32-33/35-36). The
        # Fx tokens are exact (`pointShockwave = new
        # Effect(20, e -> {`, Fx.java:223;
        # `hitSquaresColor = new Effect(14, e -> {`,
        # Fx.java:890) and the Sounds token is exact
        # via the .ogg asset (shockwaveTower.ogg --
        # Sounds is build-generated, no Sounds.java in
        # upstream, the N2444 padLaunch precedent)
        # and the color token is exact (`accent =
        # Color.valueOf("ffd37f"),`, Pal.java:79). The
        # shake is Effect.shake(shake, shake, this) --
        # the Position overload (`public static void
        # shake(float intensity, float duration,
        # Position loc){`, Effect.java:210-212)
        # delegates to (`public static void shake(
        # float intensity, float duration, float x,
        # float y){`, Effect.java:201), so the first
        # arg is the intensity and the second the
        # duration, both 2f; the camera-distance
        # falloff inside (Effect.java:204-207) is the
        # callee's own behavior -- the pure records
        # the CALL params, not the falloff result. The
        # pitch roll is an ALREADY-ROLLED caller-
        # supplied input (Mathf.range(r) is the arc
        # uniform roll in [-r, r], `public static
        # float range(float range){` with `return
        # random(-range, range);`, arc Mathf.java:220-
        # 222) -- NO RNG in the pure (the N2421
        # precedent). DEF BEATS CLASS: the shockwave-
        # tower def (Blocks.java:2038-2044) sets
        # `range = 170f;` over the class `public float
        # range = 110f;`; the pure takes range as a
        # param, so the caller passes the def value.
        # Keep each Java expr on ONE comment line
        # (the N2148 lesson: a split line fails this
        # test).
        self.assertIn('static func source_shockwave_tower_wave_effects_state', shockwave_tower)
        self.assertIn('if(targets.size > 0){', shockwave_tower)
        self.assertIn('waveEffect.at(x, y, range, waveColor);', shockwave_tower)
        self.assertIn('shootSound.at(x, y, 1f + Mathf.range(0.15f), 1f);', shockwave_tower)
        self.assertIn('Effect.shake(shake, shake, this);', shockwave_tower)
        self.assertIn('for(var target : targets){', shockwave_tower)
        self.assertIn('hitEffect.at(target.x, target.y, waveColor);', shockwave_tower)
        self.assertIn('public float range = 110f;', shockwave_tower)
        self.assertIn('public float shake = 2f;', shockwave_tower)
        self.assertIn('public Sound shootSound = Sounds.shockwaveTower;', shockwave_tower)
        self.assertIn('public Color waveColor = Pal.accent, heatColor = Pal.turretHeat, shapeColor = Color.valueOf("f29c83");', shockwave_tower)
        self.assertIn('public Effect hitEffect = Fx.hitSquaresColor;', shockwave_tower)
        self.assertIn('public Effect waveEffect = Fx.pointShockwave;', shockwave_tower)
        self.assertIn('pointShockwave = new Effect(20, e -> {', shockwave_tower)
        self.assertIn('hitSquaresColor = new Effect(14, e -> {', shockwave_tower)
        self.assertIn('accent = Color.valueOf("ffd37f"),', shockwave_tower)
        self.assertIn('public static void shake(float intensity, float duration, Position loc){', shockwave_tower)
        self.assertIn('public static void shake(float intensity, float duration, float x, float y){', shockwave_tower)
        self.assertIn('public static float range(float range){', shockwave_tower)
        self.assertIn('return random(-range, range);', shockwave_tower)
        self.assertIn('range = 170f;', shockwave_tower)
        # The documented limits record the wave effects
        # rows as live.
        self.assertIn('Wave effects / sound / shake rows live (N2470)', shockwave_tower)
        # The proof's keys drive the wave pure (the
        # fire + gate + pitch math + range/color
        # pass-through, the per-target hits + the
        # empty-targets case).
        proof = SHOCKWAVE_TOWER_WAVE_EFFECTS_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'wave_fires',
            'wave_gate',
            'wave_pitch',
            'wave_range_color',
            'hit_per_target',
            'hit_empty',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceShockwaveTowerBuildState.gd")', proof)
        self.assertTrue(SHOCKWAVE_TOWER_STATE.exists())
        self.assertTrue(SHOCKWAVE_TOWER_WAVE_EFFECTS_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07ShockwaveTowerWaveEffectsRowsProof.gd', SHOCKWAVE_TOWER_WAVE_EFFECTS_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_shockwave_tower_wave_effects_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerWaveEffectsRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_WAVE_EFFECTS_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'wave_fires',
            'wave_gate',
            'wave_pitch',
            'wave_range_color',
            'hit_per_target',
            'hit_empty',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
