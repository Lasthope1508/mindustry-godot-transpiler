import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_DEFAULT_CONSTRUCTOR_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillDefaultConstructorProof.gd'


class C07BeamDrillDefaultConstructorTests(unittest.TestCase):
    def test_c07_beam_drill_default_constructor_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2401']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_default_constructor_state')
        # BeamDrill(String name) (BeamDrill.java:63-80,
        # `public BeamDrill(String name){`) sets the six
        # BeamDrill-only field defaults: the render flags
        # (`drawArrow = false;`, `regionRotated1 = 1;`,
        # `ignoreLineRotation = true;`) and the ambient
        # sound (`ambientSoundVolume = 0.05f;`,
        # `ambientSound = Sounds.loopMineBeam;`) plus the
        # block flag (`flags = EnumSet.of(BlockFlag.drill);`).
        # The other ctor lines are NOT this slice:
        # `super(name);` (N2185), `hasItems = true;` /
        # `rotate = true;` / `update = true;` / `solid =
        # true;` (N2180-N2183 and friends) and `envEnabled
        # |= Env.space;` (N2185) all hit the ledgers already.
        # The three render-flag strings also appear in the
        # Turret ctor (N2400, same strings, different class)
        # -- both slices register them, but this register
        # pins java_method to the BeamDrill ctor. Seven new
        # result symbols: name, draw_arrow,
        # region_rotated_1, ignore_line_rotation,
        # ambient_sound_volume, ambient_sound, flags.
        self.assertEqual(
            ledger['N2401']['source_symbols'],
            [
                'source_beam_drill_default_constructor_state_result.name',
                'source_beam_drill_default_constructor_state_result.draw_arrow',
                'source_beam_drill_default_constructor_state_result.region_rotated_1',
                'source_beam_drill_default_constructor_state_result.ignore_line_rotation',
                'source_beam_drill_default_constructor_state_result.ambient_sound_volume',
                'source_beam_drill_default_constructor_state_result.ambient_sound',
                'source_beam_drill_default_constructor_state_result.flags',
            ],
        )
        for name in ledger['N2401']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BeamDrill.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/world/meta/BlockFlag.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2401']['runtime_proof'], '/root/C07BeamDrillDefaultConstructorProof')
        self.assertEqual(
            ledger['N2401']['tests'],
            [
                'test_c07_beam_drill_default_constructor_registration',
                'test_all_c07_beam_drill_default_constructor_input_evidence_is_exact',
                'test_beam_drill_default_constructor_state',
                'test_reference_graph_and_actual_c07_beam_drill_default_constructor',
            ],
        )
        self.assertTrue(ledger['N2401']['deferred_exprs'])

    def test_all_c07_beam_drill_default_constructor_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2401']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BeamDrill.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/meta/BlockFlag.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2401']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_default_constructor_state(self):
        state = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # BeamDrill(String name) (BeamDrill.java:63-80) is a
        # load-time block definition setup, not a per-tick
        # driver: it only fixes the six BeamDrill-only
        # defaults. The Block base defaults they override
        # are `public boolean drawArrow = true;`
        # (Block.java:136), `public int regionRotated1 =
        # -1, regionRotated2 = -1;` (Block.java:426),
        # `public boolean ignoreLineRotation = false;`
        # (Block.java:130), `public Sound ambientSound =
        # Sounds.none;` (Block.java:351), `public
        # EnumSet<BlockFlag> flags = EnumSet.of();`
        # (Block.java:251) -- while `public float
        # ambientSoundVolume = 0.05f;` (Block.java:353)
        # already equals the ctor value, so the ctor line
        # only re-asserts it. `Sounds.loopMineBeam` is the
        # beam-mining loop sound asset ref (core/assets
        # /sounds/beams) -- it arrives as an explicit
        # Variant param, NOT re-ported. `EnumSet.of
        # (BlockFlag.drill)` is the block-flag enum value
        # (`drill` -- "Is a drill.",
        # BlockFlag.java) -- it arrives as an explicit
        # Variant param, NOT re-ported. This is field
        # defaults only: NOT ambient C (N2304 HELD -- the
        # SoundControl updateLoops mixer), NO driver tick
        # line. frame carries no live keys for this
        # load-time setup -- it is the canonical first
        # param of this family file.
        self.assertIn('static func source_beam_drill_default_constructor_state(frame: Dictionary, block_name: String, ambient_sound: Variant, block_flags: Variant) -> Dictionary:', state)
        self.assertIn('return {"name": block_name, "draw_arrow": draw_arrow, "region_rotated_1": region_rotated_1, "ignore_line_rotation": ignore_line_rotation, "ambient_sound_volume": ambient_sound_volume, "ambient_sound": ambient_sound, "flags": block_flags}', state)
        for expr in [
            'drawArrow = false;',
            'regionRotated1 = 1;',
            'ignoreLineRotation = true;',
            'ambientSoundVolume = 0.05f;',
            'ambientSound = Sounds.loopMineBeam;',
            'flags = EnumSet.of(BlockFlag.drill);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure function with
        # synthetic frames (no live tick): the plasma-bore
        # defaults (Blocks.java:3038-3051) read through /
        # the ambient sound and flags params pass through
        # in both shapes / a second call with another block
        # name passes its name through / the result-key
        # shape.
        proof = BEAM_DRILL_DEFAULT_CONSTRUCTOR_PROOF.read_text(encoding='utf-8')
        for key in [
            'defaults_name_passthrough',
            'defaults_draw_arrow_false',
            'defaults_region_rotated_1',
            'defaults_ignore_line_rotation_true',
            'defaults_ambient_sound_volume',
            'defaults_ambient_sound_passthrough',
            'defaults_flags_passthrough',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_beam_drill_default_constructor(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillDefaultConstructorProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_DEFAULT_CONSTRUCTOR_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'defaults_name_passthrough',
            'defaults_draw_arrow_false',
            'defaults_region_rotated_1',
            'defaults_ignore_line_rotation_true',
            'defaults_ambient_sound_volume',
            'defaults_ambient_sound_passthrough',
            'defaults_flags_passthrough',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
