import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FRACKER_STATE = ROOT / 'godot-mindustry/src/game/SourceFrackerBuildState.gd'
ATTRIBUTE_STATE = ROOT / 'godot-mindustry/src/game/SourceAttributeState.gd'
FRACKER_ATTRIBUTE_ENV_LIVE_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerAttributeEnvLiveFillProof.gd'
FRACKER_ATTRIBUTE_ENV_LIVE_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerAttributeEnvLiveFillProof.tscn'
FRACKER_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/production/Fracker.java'
SOLID_PUMP_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/production/SolidPump.java'
ATTRIBUTE_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/meta/Attribute.java'
ATTRIBUTES_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/Attributes.java'
GAME_STATE_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/core/GameState.java'
BLOCKS_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/content/Blocks.java'


class C07FrackerAttributeEnvLiveFillTests(unittest.TestCase):
    def test_c07_fracker_attribute_env_live_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2453']['godot_owner'], 'SourceFrackerBuildState.source_fracker_attribute_env_live_fill_state')
        # N2305 ported the fraction fill (onProximityUpdate,
        # SolidPump.java:150-159, recomputed each enabled tick
        # from frame["proximity_linked_tiles"] + the
        # attribute_env frame input, default 0f) -- but the
        # env stayed a frame input, so a live oil-extractor
        # with no fill read env 0 and pumped at boost alone.
        # N2453 is the live fill: the tick reads the env
        # attribute map (frame["env_attrs"], the caller-
        # supplied envAttrs keyed by attribute NAME) and the
        # state presence (frame["state_present"], default
        # true) BEFORE the N2305 recompute and fills
        # frame["attribute_env"] with the OIL env value
        # (Attribute.env(), Attribute.java:31-34). One new
        # symbol: the filled env value.
        self.assertEqual(
            ledger['N2453']['source_symbols'],
            [
                'source_fracker_attribute_env_live_fill_state_result.attribute_env',
            ],
        )
        for name in ledger['N2453']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Fracker.java',
                    'core/src/mindustry/world/blocks/production/SolidPump.java',
                    'core/src/mindustry/world/meta/Attribute.java',
                    'core/src/mindustry/world/blocks/Attributes.java',
                    'core/src/mindustry/core/GameState.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_attribute_env_live_fill_state')
        self.assertEqual(ledger['N2453']['runtime_proof'], '/root/C07FrackerAttributeEnvLiveFillProof')
        self.assertEqual(
            ledger['N2453']['tests'],
            [
                'test_c07_fracker_attribute_env_live_fill_registration',
                'test_all_c07_fracker_attribute_env_live_fill_input_evidence_is_exact',
                'test_fracker_attribute_env_live_fill_state',
                'test_reference_graph_and_actual_c07_fracker_attribute_env_live_fill',
            ],
        )
        self.assertTrue(ledger['N2453']['deferred_exprs'])
        # This slice RESOLVES the Fracker attribute env live
        # fill entry (DEFERRED #216 in the coordinator's
        # merged numbering, base DEFERRED-after-advances-28,
        # 265 entries): the fill is live now, so the entry
        # is REMOVED and the list drops to 264. No new
        # entry: the live envAttrs-producer gap (no producer
        # stamps frame["env_attrs"] / frame["state_present"]
        # yet) is a follow-through note, not a deferral --
        # the pure + frame inputs work with seeded maps. The
        # SolidPump attribute-env, Fracker onProximityUpdate
        # trigger, and Fracker item-intake entries stay
        # verbatim.
        self.assertEqual(len(ledger['N2453']['deferred_exprs']), 264)
        self.assertFalse(any(entry.startswith('Fracker attribute env live fill (') for entry in ledger['N2453']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump attribute env live fill (') for entry in ledger['N2453']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker onProximityUpdate trigger (') for entry in ledger['N2453']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker item intake (') for entry in ledger['N2453']['deferred_exprs']))

    def test_all_c07_fracker_attribute_env_live_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2453']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_attribute_env_live_fill_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Fracker.java',
            'core/src/mindustry/world/blocks/production/SolidPump.java',
            'core/src/mindustry/world/meta/Attribute.java',
            'core/src/mindustry/world/blocks/Attributes.java',
            'core/src/mindustry/core/GameState.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2453']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_fracker_attribute_env_live_fill_state(self):
        fracker = FRACKER_STATE.read_text(encoding='utf-8')
        # The live fill (N2453, DEFERRED #216): the tick fills
        # frame["attribute_env"] from the live env attribute
        # map BEFORE the N2305 fraction recompute reads it.
        # Java: the fraction adds the attribute env
        # (`float fraction = Math.max(validTiles + boost +
        # (attribute == null ? 0 : attribute.env()), 0);`,
        # SolidPump.java:124), and Attribute.env() returns 0
        # when Vars.state is null and otherwise reads the
        # state's envAttrs (`if(Vars.state == null) return 0;`
        # / `return Vars.state.envAttrs.get(this);`,
        # Attribute.java:32-33). envAttrs is an Attributes
        # (`public Attributes envAttrs = new Attributes();`,
        # GameState.java:43) -- a float array indexed by
        # attribute id, NOT a map (`return arr[attr.id];`,
        # Attributes.java:18), so a missing / unset key reads
        # the array default 0.0, never null. The fracker
        # attribute is oil (`attribute = Attribute.oil;`,
        # Blocks.java:2972 -- the oil-extractor DEF sets it;
        # the Fracker CLASS sets none). Keep each Java expr
        # on ONE comment line (the N2148 lesson: a split line
        # fails this test).
        self.assertIn('static func source_fracker_attribute_env_live_fill_state(env_attrs: Dictionary, state_present: bool) -> Dictionary:', fracker)
        self.assertIn('float fraction = Math.max(validTiles + boost + (attribute == null ? 0 : attribute.env()), 0);', fracker)
        self.assertIn('public float env(){', fracker)
        self.assertIn('if(Vars.state == null) return 0;', fracker)
        self.assertIn('return Vars.state.envAttrs.get(this);', fracker)
        self.assertIn('public Attributes envAttrs = new Attributes();', fracker)
        self.assertIn('public float get(Attribute attr){', fracker)
        self.assertIn('return arr[attr.id];', fracker)
        self.assertIn('attribute = Attribute.oil;', fracker)
        # DESIGN DECISION (verified, not guessed): the port
        # has no envAttrs model -- no producer stamps a state
        # env map anywhere, and the only env() port is the
        # SourceAttributeState.env_state helper, which takes
        # the env VALUE as an explicit param (it never reads
        # a map). So this slice defines the MINIMAL extension
        # in the pure's input contract (env_attrs: a Dict
        # keyed by attribute NAME, e.g. {"oil": 0.5}, read
        # through the "oil" key; state_present: the
        # Vars.state-null guard) and documents the producer
        # gap (the live envAttrs producer that stamps those
        # frame inputs waits for its own slice) -- it does
        # NOT invent an envAttrs producer.
        attribute_state = ATTRIBUTE_STATE.read_text(encoding='utf-8')
        self.assertIn('static func env_state(state_present: bool, env_value: float) -> Dictionary:', attribute_state)
        self.assertIn('var value := env_value if state_present else 0.0', attribute_state)
        self.assertIn('env_attrs', fracker)
        self.assertIn('state_present', fracker)
        self.assertIn('envAttrs producer', fracker)
        # The pure: no state -> 0.0 exact (the Vars.state ==
        # null branch); otherwise the oil value, 0.0 when the
        # key is missing (the float-array default, never null).
        self.assertIn('0.0 if not state_present else float(env_attrs.get("oil", 0.0))', fracker)
        self.assertIn('"attribute_env": attribute_env', fracker)
        # The fill is called exactly once (its definition plus
        # the one tick call site), with the frame env map
        # (default {} -- an empty map fills 0.0, preserving
        # the no-fill behavior) and the frame state presence
        # (default true -- a live game has a state; the false
        # branch is exercised by the proof seed).
        self.assertEqual(fracker.count('source_fracker_attribute_env_live_fill_state('), 2)
        self.assertIn('source_fracker_attribute_env_live_fill_state(frame.get("env_attrs", {}), bool(frame.get("state_present", true)))', fracker)
        # The tick wires the fill BEFORE the N2305 recompute
        # reads the frame env: a supplied value WINS (the
        # N2381 precedent -- the N2224/N2305 proofs seed
        # attribute_env by hand, so a fill there would
        # overwrite the seed), and a previously live-filled
        # frame (attribute_env_live -- port bookkeeping, not
        # Java state, the N2394 precedent) refreshes every
        # tick.
        self.assertIn('has_supplied_attribute_env', fracker)
        self.assertIn('frame.get("env_attrs", {})', fracker)
        self.assertIn('frame.get("state_present", true)', fracker)
        self.assertIn('frame["attribute_env_live"] = true', fracker)
        self.assertIn('bool(frame.get("attribute_env_live", false))', fracker)
        self.assertLess(
            fracker.index('source_fracker_attribute_env_live_fill_state(frame.get("env_attrs", {}), bool(frame.get("state_present", true)))'),
            fracker.index('source_fracker_proximity_fraction_state(proximity_tiles, float(frame.get("attribute_env", 0.0)))'),
        )
        self.assertLess(
            fracker.index('frame["attribute_env"] = env_filled.get("attribute_env", 0.0)'),
            fracker.index('source_fracker_proximity_fraction_state(proximity_tiles, float(frame.get("attribute_env", 0.0)))'),
        )
        # The N2305 fraction pins still hold: the recompute
        # call, the frame-input read, the valid_tiles / boost
        # stamps, and the doc strings.
        self.assertIn('source_fracker_proximity_fraction_state(proximity_tiles, float(frame.get("attribute_env", 0.0)))', fracker)
        self.assertIn('frame["valid_tiles"] = fraction_filled["valid_tiles"]', fracker)
        self.assertIn('frame["boost"] = fraction_filled["boost"]', fracker)
        self.assertIn('Fraction fill live (N2305)', fracker)
        self.assertIn('linked-tile scan live since N2414', fracker)
        self.assertIn('dumpLiquid live (N2284)', fracker)
        self.assertIn('shouldConsume gate live (N2207)', fracker)
        self.assertIn('updateTile advance live (N2224)', fracker)
        # The documented limits now record the attribute env
        # live fill as live (N2453).
        self.assertIn('Attribute env live fill live (N2453)', fracker)
        self.assertIn('static func source_fracker_proximity_fraction_state', fracker)
        self.assertIn('static func source_fracker_linked_tiles_live_fill_state', fracker)
        self.assertIn('static func source_fracker_update_tile_advance_state', fracker)
        self.assertIn('static func source_fracker_should_consume_state', fracker)
        self.assertIn('static func source_fracker_tick_buildings_state', fracker)
        # The :633 frame-sync pin still holds (the
        # cite-sweep test pins it too; the doc edit above
        # it is line-neutral and the pure lives after the
        # tick function).
        self.assertEqual(
            fracker.splitlines()[632].strip(),
            'frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})',
        )
        # Scope pins, by Java line number: the fraction env
        # term (SolidPump.java:124), Attribute.env()
        # (Attribute.java:31-33), the envAttrs field
        # (GameState.java:43), the Attributes array read
        # (Attributes.java:16-18), and the def attribute
        # (Blocks.java:2972).
        solid_pump_lines = SOLID_PUMP_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(solid_pump_lines[123].strip(), 'float fraction = Math.max(validTiles + boost + (attribute == null ? 0 : attribute.env()), 0);')
        attribute_lines = ATTRIBUTE_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(attribute_lines[30].strip(), 'public float env(){')
        self.assertEqual(attribute_lines[31].strip(), 'if(Vars.state == null) return 0;')
        self.assertEqual(attribute_lines[32].strip(), 'return Vars.state.envAttrs.get(this);')
        game_state_lines = GAME_STATE_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(game_state_lines[42].strip(), 'public Attributes envAttrs = new Attributes();')
        attributes_lines = ATTRIBUTES_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(attributes_lines[15].strip(), 'public float get(Attribute attr){')
        self.assertEqual(attributes_lines[17].strip(), 'return arr[attr.id];')
        blocks_lines = BLOCKS_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(blocks_lines[2971].strip(), 'attribute = Attribute.oil;')
        # The proof's keys drive the fill (env present, a
        # missing key reading 0.0, no state reading 0.0, a
        # supplied value winning over the fill, the live tick
        # filling the frame, and the filled env entering the
        # fraction).
        proof = FRACKER_ATTRIBUTE_ENV_LIVE_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'env_present',
            'env_missing_key',
            'env_no_state',
            'env_supplied_wins',
            'env_live_tick',
            'env_fraction_effect',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        for line in proof.splitlines():
            if 'preload("res://' in line:
                res_path = line.split('preload("res://', 1)[1].split('"', 1)[0]
                with self.subTest(preload=res_path):
                    self.assertTrue((ROOT / 'godot-mindustry' / res_path).is_file(), res_path)
        self.assertIn('preload("res://src/game/SourceFrackerBuildState.gd")', proof)
        self.assertTrue(FRACKER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('fracker_build_state.source_fracker_attribute_env_live_fill_state(', proof)
        self.assertIn('fracker_build_state.source_fracker_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = FRACKER_ATTRIBUTE_ENV_LIVE_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07FrackerAttributeEnvLiveFillProof.gd', scene)
        self.assertIn('C07FrackerAttributeEnvLiveFillProof', scene)

    def test_reference_graph_and_actual_c07_fracker_attribute_env_live_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07FrackerAttributeEnvLiveFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FRACKER_ATTRIBUTE_ENV_LIVE_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'env_present',
            'env_missing_key',
            'env_no_state',
            'env_supplied_wins',
            'env_live_tick',
            'env_fraction_effect',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
