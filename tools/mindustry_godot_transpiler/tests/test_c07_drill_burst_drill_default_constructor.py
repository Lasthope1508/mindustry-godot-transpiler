import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
DRILL_BURST_DRILL_DEFAULT_CONSTRUCTOR_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillBurstDrillDefaultConstructorProof.gd'


class C07DrillBurstDrillDefaultConstructorTests(unittest.TestCase):
    def test_c07_drill_burst_drill_default_constructor_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2403']['godot_owner'], 'SourceBurstDrillBuildState.source_drill_default_constructor_state')
        # Drill(String name) (Drill.java:76-88) +
        # BurstDrill(String name) (BurstDrill.java:35-45)
        # is one grouped slice: two ctors of one Drill
        # family, same concern "Drill family ctor
        # defaults" -- main-thread decision 2026-11-22,
        # batch 26 slot 1 (APPROVED gộp; the N2395/N2397/
        # N2399 group precedent). Two GD functions, one
        # ledger entry, one owner per function (the N2380
        # multi-function precedent; the N2378 lesson: a
        # contract owner must be an actual GD function, so
        # the group label
        # `source_drill_burst_drill_default_constructor_group_state`
        # is NOT an owner -- the ledger godot_owner is the
        # first function owner,
        # `source_drill_default_constructor_state`). Seven
        # exact exprs, 0-hit both ledgers at HEAD 5ffcadd1:
        # Drill `group = BlockGroup.drills;`,
        # `ambientSound = Sounds.loopDrill;`,
        # `ambientSoundVolume = 0.019f;`; BurstDrill
        # `drillEffectRnd = 0f;`, `drillEffect =
        # Fx.shockwave;`, `ambientSoundVolume = 0.18f;`,
        # `ambientSound = Sounds.drillCharge;`. NOT this
        # slice: `flags = EnumSet.of(BlockFlag.drill);`
        # (owned N2401, batch 25), `hardnessDrillMultiplier
        # = 0f;` (owned N2344), `hasLiquids = true;`
        # (owned N927/N2000/N2179/N2182/N2209),
        # `super(name);` (N2185), `update = true;` /
        # `solid = true;` / `hasItems = true;`
        # (N2180-N2183 and friends), `envEnabled |=
        # Env.space;` (N2185). Nine new result symbols:
        # Drill name, group, ambient_sound,
        # ambient_sound_volume; BurstDrill name,
        # drill_effect_rnd, drill_effect,
        # ambient_sound_volume, ambient_sound.
        self.assertEqual(
            ledger['N2403']['java_method'],
            'Drill.Drill(String name)/BurstDrill.BurstDrill(String name)',
        )
        self.assertEqual(
            ledger['N2403']['source_symbols'],
            [
                'source_drill_default_constructor_state_result.name',
                'source_drill_default_constructor_state_result.group',
                'source_drill_default_constructor_state_result.ambient_sound',
                'source_drill_default_constructor_state_result.ambient_sound_volume',
                'source_burst_drill_default_constructor_state_result.name',
                'source_burst_drill_default_constructor_state_result.drill_effect_rnd',
                'source_burst_drill_default_constructor_state_result.drill_effect',
                'source_burst_drill_default_constructor_state_result.ambient_sound_volume',
                'source_burst_drill_default_constructor_state_result.ambient_sound',
            ],
        )
        for name in ledger['N2403']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/world/blocks/production/BurstDrill.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2403']['runtime_proof'], '/root/C07DrillBurstDrillDefaultConstructorProof')
        self.assertEqual(
            ledger['N2403']['tests'],
            [
                'test_c07_drill_burst_drill_default_constructor_registration',
                'test_all_c07_drill_burst_drill_default_constructor_input_evidence_is_exact',
                'test_drill_burst_drill_default_constructor_state',
                'test_reference_graph_and_actual_c07_drill_burst_drill_default_constructor',
            ],
        )
        self.assertTrue(ledger['N2403']['deferred_exprs'])

    def test_all_c07_drill_burst_drill_default_constructor_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2403']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2403']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_drill_burst_drill_default_constructor_state(self):
        state = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # Drill(String name) (Drill.java:76-88) +
        # BurstDrill(String name) (BurstDrill.java:35-45)
        # is load-time block definition setup, not a
        # per-tick driver: it only fixes the seven
        # Drill-family-only defaults. The Block base
        # defaults they override are `public BlockGroup
        # group = BlockGroup.none;` (Block.java:249),
        # `public Sound ambientSound = Sounds.none;`
        # (Block.java:351), `public float
        # ambientSoundVolume = 0.05f;` (Block.java:353)
        # and the Drill base defaults `public Effect
        # drillEffect = Fx.mine;` (Drill.java:53),
        # `public float drillEffectRnd = -1f;`
        # (Drill.java:55). `Sounds.loopDrill` /
        # `Sounds.drillCharge` are the drill loop sound
        # asset refs -- they arrive as explicit Variant
        # params, NOT re-ported. `BlockGroup.drills` is
        # the block-group enum value -- it arrives as an
        # explicit Variant param, NOT re-ported.
        # `Fx.shockwave` is the burst effect ref -- it
        # arrives as an explicit Variant param, NOT
        # re-ported. This is field defaults only: NOT
        # ambient C (N2304 HELD -- the SoundControl
        # updateLoops mixer), NO driver tick line. frame
        # carries no live keys for this load-time setup
        # -- it is the canonical first param of this
        # family file.
        self.assertIn('static func source_drill_default_constructor_state(frame: Dictionary, block_name: String, ambient_sound: Variant, group: Variant) -> Dictionary:', state)
        self.assertIn('static func source_burst_drill_default_constructor_state(frame: Dictionary, block_name: String, ambient_sound: Variant, drill_effect: Variant) -> Dictionary:', state)
        self.assertIn('return {"name": block_name, "group": group, "ambient_sound": ambient_sound, "ambient_sound_volume": ambient_sound_volume}', state)
        self.assertIn('return {"name": block_name, "drill_effect_rnd": drill_effect_rnd, "drill_effect": drill_effect, "ambient_sound_volume": ambient_sound_volume, "ambient_sound": ambient_sound}', state)
        for expr in [
            'group = BlockGroup.drills;',
            'ambientSound = Sounds.loopDrill;',
            'ambientSoundVolume = 0.019f;',
            'drillEffectRnd = 0f;',
            'drillEffect = Fx.shockwave;',
            'ambientSoundVolume = 0.18f;',
            'ambientSound = Sounds.drillCharge;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure functions with
        # synthetic frames (no live tick): the Drill
        # defaults (mechanical-drill, Blocks.java:2865)
        # and the BurstDrill defaults (impact-drill,
        # Blocks.java:3070) read through / the ambient
        # sound, group and drill-effect params pass
        # through in both shapes / a second call with
        # another block name passes its name through /
        # the result-key shapes.
        proof = DRILL_BURST_DRILL_DEFAULT_CONSTRUCTOR_PROOF.read_text(encoding='utf-8')
        for key in [
            'defaults_drill_name_passthrough',
            'defaults_drill_group_passthrough',
            'defaults_drill_ambient_sound_passthrough',
            'defaults_drill_ambient_sound_volume',
            'returns_only_drill_keys',
            'defaults_burst_name_passthrough',
            'defaults_burst_drill_effect_rnd',
            'defaults_burst_drill_effect_passthrough',
            'defaults_burst_ambient_sound_volume',
            'defaults_burst_ambient_sound_passthrough',
            'returns_only_burst_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_drill_burst_drill_default_constructor(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DrillBurstDrillDefaultConstructorProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DRILL_BURST_DRILL_DEFAULT_CONSTRUCTOR_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'defaults_drill_name_passthrough',
            'defaults_drill_group_passthrough',
            'defaults_drill_ambient_sound_passthrough',
            'defaults_drill_ambient_sound_volume',
            'returns_only_drill_keys',
            'defaults_burst_name_passthrough',
            'defaults_burst_drill_effect_rnd',
            'defaults_burst_drill_effect_passthrough',
            'defaults_burst_ambient_sound_volume',
            'defaults_burst_ambient_sound_passthrough',
            'returns_only_burst_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
