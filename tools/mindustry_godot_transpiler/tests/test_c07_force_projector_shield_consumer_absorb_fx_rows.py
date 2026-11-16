import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FORCE_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceForceProjectorBuildState.gd'
FORCE_PROJECTOR_SHIELD_CONSUMER_ABSORB_FX_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ForceProjectorShieldConsumerAbsorbFxProof.gd'
FORCE_PROJECTOR_SHIELD_CONSUMER_ABSORB_FX_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ForceProjectorShieldConsumerAbsorbFxProof.tscn'


class C07ForceProjectorShieldConsumerAbsorbFxRowsTests(unittest.TestCase):
    def test_c07_force_projector_shield_consumer_absorb_fx_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2487']['godot_owner'], 'SourceForceProjectorBuildState.source_force_projector_shield_consumer_absorb_fx_state')
        # The shieldConsumer bullet path (ForceProjector.
        # java:58-70) fires per absorbed BULLET in
        # deflectBullets: `paramBlock.hitSound.at(
        # bullet.x, bullet.y, 1f + Mathf.range(0.1f),
        # paramBlock.hitSoundVolume);` +
        # `paramBlock.absorbEffect.at(bullet);`
        # (:64-65), with hitSound = Sounds.shieldHit
        # (:47), hitSoundVolume 0.12f (:48), and
        # absorbEffect = Fx.absorb (:49). The absorb
        # gate / hit / buildup are live since N2235
        # (the advance's deflect branch reports
        # absorbed_bullets as a pure result), so
        # N2487 ports ONLY the sound + effect as ONE
        # pure-only pure (the N2469 precedent, NO
        # tick wiring): source_force_projector_shield_
        # consumer_absorb_fx_state(absorbed, bullet_x,
        # bullet_y, pitch_roll) returns hit_sound_call
        # {token "shieldHit", x, y, pitch 1f +
        # pitch_roll, volume 0.12} + absorb_effect_call
        # {effect "Fx.absorb", x, y} when the caller-
        # supplied absorbed verdict is true, both null
        # otherwise (the N2397 null-when-absent
        # precedent). The pitch roll is caller-
        # supplied (NO RNG in the pure, the N2421
        # precedent). This is a DIFFERENT call site
        # from the absorbExplosion :272 call (live
        # since N2482 as the pure source_force_
        # projector_absorb_effect_state) -- the N2423
        # and N2482 pures are unchanged by this
        # slice. Two new result symbols:
        # hit_sound_call, absorb_effect_call.
        self.assertEqual(
            ledger['N2487']['source_symbols'],
            [
                'source_force_projector_shield_consumer_absorb_fx_state_result.hit_sound_call',
                'source_force_projector_shield_consumer_absorb_fx_state_result.absorb_effect_call',
            ],
        )
        for name in ledger['N2487']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/ForceProjector.java')
                self.assertEqual(symbol['godot_owner'], 'SourceForceProjectorBuildState.source_force_projector_shield_consumer_absorb_fx_state')
        self.assertEqual(ledger['N2487']['runtime_proof'], '/root/C07ForceProjectorShieldConsumerAbsorbFxProof')
        self.assertEqual(
            ledger['N2487']['tests'],
            [
                'test_c07_force_projector_shield_consumer_absorb_fx_rows_registration',
                'test_all_c07_force_projector_shield_consumer_absorb_fx_rows_input_evidence_is_exact',
                'test_force_projector_shield_consumer_absorb_fx_rows_state',
                'test_reference_graph_and_actual_c07_force_projector_shield_consumer_absorb_fx_rows',
            ],
        )
        self.assertTrue(ledger['N2487']['deferred_exprs'])
        # This slice resolves DEFERRED #231 (1-based in
        # DEFERRED-after-advances-33.py, the merged 231
        # file): the shieldConsumer absorb FX rows
        # entry is gone -- while the updateTile live-
        # fill entry stays. No new entry: the sound /
        # effect call sites wait for audio/effect
        # slices, not a ForceProjector deferral. Net
        # 231 - 1 = 230.
        self.assertFalse(any(entry.startswith('ForceProjector shieldConsumer absorb FX rows (') for entry in ledger['N2487']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ForceProjector updateTile live fill (') for entry in ledger['N2487']['deferred_exprs']))
        self.assertEqual(len(ledger['N2487']['deferred_exprs']), 230)

    def test_all_c07_force_projector_shield_consumer_absorb_fx_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2487']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceForceProjectorBuildState.source_force_projector_shield_consumer_absorb_fx_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ForceProjector.java',
            'core/src/mindustry/content/Fx.java',
            'core/src/mindustry/entities/Effect.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2487']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_force_projector_shield_consumer_absorb_fx_rows_state(self):
        force_projector = FORCE_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The shieldConsumer absorb FX rows (the
        # static shieldConsumer lambda, ForceProjector.
        # java:58-70): the gate / hit / buildup are
        # live since N2235 (the advance's deflect
        # branch), so this pure consumes the caller-
        # supplied absorbed verdict (one entry of
        # the N2235 advance's absorbed_bullets
        # result, per absorbed BULLET) and reports
        # the sound + effect as pure call records
        # (the N2469 precedent -- no sound played,
        # no effect spawned): `protected static
        # final Cons<Bullet> shieldConsumer = bullet
        # -> {` + `if(bullet.team != paramEntity.team
        # && bullet.type.absorbable && !bullet.
        # absorbed &&` + `Intersector.
        # isInRegularPolygon(paramBlock.sides,
        # paramEntity.x, paramEntity.y, paramEntity.
        # realRadius(), paramBlock.shieldRotation,
        # bullet.x, bullet.y)){` + `bullet.absorb();`
        # + `paramBlock.hitSound.at(bullet.x, bullet.
        # y, 1f + Mathf.range(0.1f), paramBlock.
        # hitSoundVolume);` + `paramBlock.absorbEffect.
        # at(bullet);`. The sound is Sounds.shieldHit
        # (`public Sound hitSound = Sounds.shieldHit;`,
        # ForceProjector.java:47; asset core/assets/
        # sounds/shieldHit.ogg), the volume is
        # hitSoundVolume 0.12f (`public float
        # hitSoundVolume = 0.12f;`, :48), the pitch
        # is 1f + Mathf.range(0.1f) with the roll
        # caller-supplied (NO RNG in the pure, the
        # N2421 precedent), and the effect is
        # Fx.absorb (`public Effect absorbEffect =
        # Fx.absorb;`, :49; `absorb = new Effect(12,
        # e -> {`, Fx.java:1356) fired AT the bullet
        # (`public void at(Position pos){`, Effect.
        # java:105 -- create at pos.x/pos.y, rotation
        # 0, no extra args). The single force-
        # projector def does NOT override hitSound,
        # hitSoundVolume, or absorbEffect (Blocks.
        # java:1964-1976). This is a DIFFERENT call
        # site from the absorbExplosion :272 call
        # (live since N2482) -- the N2423 and N2482
        # pures are unchanged by this slice. Keep
        # each Java expr on ONE comment line (the
        # N2148 lesson: a split line fails this
        # test).
        self.assertIn('static func source_force_projector_shield_consumer_absorb_fx_state', force_projector)
        self.assertIn('protected static final Cons<Bullet> shieldConsumer = bullet -> {', force_projector)
        self.assertIn('if(bullet.team != paramEntity.team && bullet.type.absorbable && !bullet.absorbed &&', force_projector)
        self.assertIn('Intersector.isInRegularPolygon(paramBlock.sides, paramEntity.x, paramEntity.y, paramEntity.realRadius(), paramBlock.shieldRotation, bullet.x, bullet.y)){', force_projector)
        self.assertIn('bullet.absorb();', force_projector)
        self.assertIn('paramBlock.hitSound.at(bullet.x, bullet.y, 1f + Mathf.range(0.1f), paramBlock.hitSoundVolume);', force_projector)
        self.assertIn('paramBlock.absorbEffect.at(bullet);', force_projector)
        self.assertIn('public Sound hitSound = Sounds.shieldHit;', force_projector)
        self.assertIn('public float hitSoundVolume = 0.12f;', force_projector)
        self.assertIn('public Effect absorbEffect = Fx.absorb;', force_projector)
        self.assertIn('absorb = new Effect(12, e -> {', force_projector)
        self.assertIn('public void at(Position pos){', force_projector)
        # The documented limits record the
        # shieldConsumer absorb FX rows as live, and
        # the N2423 / N2482 pures are untouched (this
        # slice amends neither them nor their
        # proofs).
        self.assertIn('shieldConsumer absorb FX is live since N2487', force_projector)
        self.assertIn('static func source_force_projector_absorb_explosion_state', force_projector)
        self.assertIn('static func source_force_projector_absorb_effect_state', force_projector)
        # Pure-only: the driver NEVER calls any of
        # the three pures from the tick -- the only
        # call-shaped occurrence of each is its
        # definition itself (docstring mentions carry
        # no parens).
        self.assertEqual(force_projector.count('source_force_projector_shield_consumer_absorb_fx_state('), 1)
        self.assertEqual(force_projector.count('source_force_projector_absorb_explosion_state('), 1)
        self.assertEqual(force_projector.count('source_force_projector_absorb_effect_state('), 1)
        # The proof's keys drive the FX pure (the
        # fire + the null gate + the exact shieldHit
        # token + the pitch roll + the bullet
        # position pass-through + the live N2235
        # deflect verdict as the input).
        proof = FORCE_PROJECTOR_SHIELD_CONSUMER_ABSORB_FX_PROOF.read_text(encoding='utf-8')
        for key in [
            'fx_on_absorb',
            'fx_null_when_not_absorbed',
            'fx_sound_token',
            'fx_pitch_roll',
            'fx_position',
            'fx_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist). Pure-only: the proof
        # never touches the live tick; the live-input key
        # composes the N2235 advance (its absorbed_bullets
        # result feeds this pure's absorbed input, per
        # bullet).
        self.assertIn('preload("res://src/game/SourceForceProjectorBuildState.gd")', proof)
        self.assertIn('force_projector_build_state.source_force_projector_shield_consumer_absorb_fx_state(', proof)
        self.assertIn('force_projector_build_state.source_force_projector_update_tile_advance_state(', proof)
        self.assertNotIn('source_force_projector_tick_buildings_state', proof)
        self.assertTrue(FORCE_PROJECTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = FORCE_PROJECTOR_SHIELD_CONSUMER_ABSORB_FX_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ForceProjectorShieldConsumerAbsorbFxProof.gd', scene)
        self.assertIn('C07ForceProjectorShieldConsumerAbsorbFxProof', scene)

    def test_reference_graph_and_actual_c07_force_projector_shield_consumer_absorb_fx_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ForceProjectorShieldConsumerAbsorbFxProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FORCE_PROJECTOR_SHIELD_CONSUMER_ABSORB_FX_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fx_on_absorb',
            'fx_null_when_not_absorbed',
            'fx_sound_token',
            'fx_pitch_roll',
            'fx_position',
            'fx_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
