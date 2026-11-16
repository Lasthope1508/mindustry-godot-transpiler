import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MEND_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceMendProjectorBuildState.gd'
MEND_PROJECTOR_MEND_SOUND_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorMendSoundRowsProof.gd'
MEND_PROJECTOR_MEND_SOUND_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorMendSoundRowsProof.tscn'


class C07MendProjectorMendSoundRowsTests(unittest.TestCase):
    def test_c07_mend_projector_mend_sound_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2504']['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_mend_sound_state')
        # The heal scan is live since N2242
        # (source_mend_projector_heal_scan_state): it
        # returns the heal amounts (one per healed
        # candidate) and the any flag, but the
        # mendSound.at call at MendProjector.
        # java:119-121 deferred under its own narrow
        # entry (DEFERRED #114). N2504 ports ONLY
        # that sound as ONE pure-only pure (the
        # N2487 precedent, NO tick wiring):
        # source_mend_projector_mend_sound_state
        # (any_healed, x, y, pitch_roll) returns
        # mend_sound_call {token "healWave", x, y,
        # pitch 1.0 + pitch_roll, volume 0.5} when
        # the caller-supplied any_healed verdict is
        # true, null otherwise (the N2397
        # null-when-absent precedent). The
        # any_healed verdict is a caller-supplied
        # input (the N2242 scan's "any" result key
        # -- true iff at least one candidate was
        # healed) -- this pure does NOT recompute
        # the heal gate and does NOT amend the
        # N2242 pure or its proof. NO sound is
        # played -- the sound call site waits for
        # its own slice. The sound fires ONCE PER
        # TICK (after the eachBlock lambda,
        # MendProjector.java:112-117, gated on `any`
        # :119-121) -- not once per healed building,
        # unlike the Fx.healBlockFull effect (:115,
        # live since N2484). mendSound is
        # Sounds.healWave (`public Sound mendSound
        # = Sounds.healWave;`, MendProjector.
        # java:32; asset core/assets/sounds/block/
        # healWave.ogg, the N2444 precedent) and
        # the volume is the literal mendSoundVolume
        # 0.5f (`public float mendSoundVolume =
        # 0.5f;`, MendProjector.java:33); neither
        # def overrides either (Blocks.java:
        # 1919-1942). The record uses the "token"
        # key form (the N2487 precedent -- the
        # N2469/N2444 "sound" key form is NOT used
        # here). The pitch roll is caller-supplied
        # in [-0.1, 0.1] (NO RNG in the pure, the
        # N2421 precedent). One new result symbol:
        # mend_sound_call.
        self.assertEqual(
            ledger['N2504']['source_symbols'],
            [
                'source_mend_projector_mend_sound_state_result.mend_sound_call',
            ],
        )
        for name in ledger['N2504']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/MendProjector.java')
                self.assertEqual(symbol['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_mend_sound_state')
        self.assertEqual(ledger['N2504']['runtime_proof'], '/root/C07MendProjectorMendSoundRowsProof')
        self.assertEqual(
            ledger['N2504']['tests'],
            [
                'test_c07_mend_projector_mend_sound_rows_registration',
                'test_all_c07_mend_projector_mend_sound_rows_input_evidence_is_exact',
                'test_mend_projector_mend_sound_rows_state',
                'test_reference_graph_and_actual_c07_mend_projector_mend_sound_rows',
            ],
        )
        self.assertTrue(ledger['N2504']['deferred_exprs'])
        # This slice resolves DEFERRED #114 (1-based in
        # DEFERRED-after-advances-35.py, the merged 218
        # file): the mendSound rows entry is gone --
        # while the recentlyHealed entry stays
        # (a different Java line, its own slice).
        # No new entry: the sound call site that
        # would play Sounds.healWave is an
        # audio slice, not a MendProjector
        # deferral (the N2482 precedent -- no entry
        # added). Net 218 - 1 = 217.
        self.assertFalse(any(entry.startswith('MendProjector mendSound rows (') for entry in ledger['N2504']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector recentlyHealed rows (') for entry in ledger['N2504']['deferred_exprs']))
        self.assertEqual(len(ledger['N2504']['deferred_exprs']), 217)

    def test_all_c07_mend_projector_mend_sound_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2504']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_mend_sound_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/MendProjector.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2504']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mend_projector_mend_sound_rows_state(self):
        mend_projector = MEND_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The mendSound row (MendBuild.updateTile()
        # heal branch, MendProjector.java:106-122):
        # the heal scan is live since N2242, so this
        # pure consumes the caller-supplied
        # any_healed verdict (the N2242 scan's "any"
        # result key) and reports the sound as a
        # pure call record (the N2487 precedent --
        # no sound played): `if(any){` +
        # `mendSound.at(this, 1f + Mathf.range(0.1f),
        # mendSoundVolume);` + `private boolean any
        # = false;`. The sound is Sounds.healWave
        # (`public Sound mendSound =
        # Sounds.healWave;`, MendProjector.java:32;
        # asset core/assets/sounds/block/healWave.
        # ogg, the N2444 precedent) and the volume
        # is the literal mendSoundVolume 0.5f
        # (`public float mendSoundVolume = 0.5f;`,
        # MendProjector.java:33); neither def
        # overrides either (Blocks.java:1919-1942).
        # The call passes `this` (the building, a
        # Position), so the Position overload
        # (`public int at(Position pos, float pitch,
        # float volume){`, arc Sound.java:180-182)
        # fires at the building x/y. The pitch is
        # 1f + Mathf.range(0.1f) with the roll
        # caller-supplied in [-0.1, 0.1] (Mathf.
        # range(r) is the arc uniform roll in [-r,
        # r], arc Mathf.java:220-222) -- NO RNG in
        # the pure (the N2421 precedent). The defs
        # are `mender = new MendProjector("mender")
        # {{` (reload 200f) and `mendProjector =
        # new MendProjector("mend-projector"){{`
        # (reload 250f). Keep each Java expr on ONE
        # comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_mend_projector_mend_sound_state', mend_projector)
        self.assertIn('if(any){', mend_projector)
        self.assertIn('mendSound.at(this, 1f + Mathf.range(0.1f), mendSoundVolume);', mend_projector)
        self.assertIn('private boolean any = false;', mend_projector)
        self.assertIn('public Sound mendSound = Sounds.healWave;', mend_projector)
        self.assertIn('public float mendSoundVolume = 0.5f;', mend_projector)
        self.assertIn('public int at(Position pos, float pitch, float volume){', mend_projector)
        self.assertIn('public static float range(float range){', mend_projector)
        self.assertIn('mender = new MendProjector("mender"){{', mend_projector)
        self.assertIn('mendProjector = new MendProjector("mend-projector"){{', mend_projector)
        # The documented limits record the mendSound
        # row as live, and the N2242 / N2484 pures
        # are untouched (this slice amends neither
        # them nor their proofs).
        self.assertIn('mendSound', mend_projector)
        self.assertIn('is live since N2504 as this pure-only call record', mend_projector)
        self.assertIn('static func source_mend_projector_heal_scan_state', mend_projector)
        self.assertIn('static func source_mend_projector_heal_effect_state', mend_projector)
        # Pure-only: the driver NEVER calls the sound
        # pure from the tick -- the only call-shaped
        # occurrence is its definition itself
        # (docstring mentions carry no parens). The
        # N2242 scan pure keeps its 2 call-shaped
        # occurrences (definition + the live tick
        # call) and the N2484 effect pure keeps its
        # 1 (definition only) -- this slice adds no
        # more.
        self.assertEqual(mend_projector.count('source_mend_projector_mend_sound_state('), 1)
        self.assertEqual(mend_projector.count('source_mend_projector_heal_scan_state('), 2)
        self.assertEqual(mend_projector.count('source_mend_projector_heal_effect_state('), 1)
        # The proof's keys drive the sound pure (the
        # fire + the null gate + the exact healWave
        # token + the pitch roll + the position
        # pass-through + the live N2242 heal verdict
        # as the input).
        proof = MEND_PROJECTOR_MEND_SOUND_PROOF.read_text(encoding='utf-8')
        for key in [
            'sound_on_heal',
            'sound_null_when_not_healed',
            'sound_token',
            'sound_pitch_roll',
            'sound_position',
            'sound_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist). Pure-only: the proof
        # never touches the live tick; the live-input key
        # composes the N2242 pure (its any result key feeds
        # this pure's any_healed input).
        self.assertIn('preload("res://src/game/SourceMendProjectorBuildState.gd")', proof)
        self.assertIn('mend_projector_build_state.source_mend_projector_mend_sound_state(', proof)
        self.assertIn('mend_projector_build_state.source_mend_projector_heal_scan_state(', proof)
        self.assertNotIn('source_mend_projector_tick_buildings_state', proof)
        self.assertTrue(MEND_PROJECTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = MEND_PROJECTOR_MEND_SOUND_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07MendProjectorMendSoundRowsProof.gd', scene)
        self.assertIn('C07MendProjectorMendSoundRowsProof', scene)

    def test_reference_graph_and_actual_c07_mend_projector_mend_sound_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MendProjectorMendSoundRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MEND_PROJECTOR_MEND_SOUND_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sound_on_heal',
            'sound_null_when_not_healed',
            'sound_token',
            'sound_pitch_roll',
            'sound_position',
            'sound_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
