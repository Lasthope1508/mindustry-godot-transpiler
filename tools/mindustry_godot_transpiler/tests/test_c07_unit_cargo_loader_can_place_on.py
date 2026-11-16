import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_CARGO_LOADER_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitCargoLoaderBuildState.gd'
UNIT_CARGO_LOADER_CAN_PLACE_ON_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderCanPlaceOnProof.gd'
UNIT_CARGO_LOADER_CAN_PLACE_ON_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderCanPlaceOnProof.tscn'


class C07UnitCargoLoaderCanPlaceOnTests(unittest.TestCase):
    def test_c07_unit_cargo_loader_can_place_on_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2330']['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_can_place_on_state')
        # UnitCargoLoader overrides canPlaceOn (UnitCargoLoader.java:65-68,
        # `return super.canPlaceOn(tile, team, rotation) &&
        # Units.canCreate(team, unitType);`) and the Block default
        # returns TRUE (Block.java:606-608, `return true;`), so
        # the UCL placement gate IS the N2322 canCreate verdict.
        # N2330 is a thin slice: a new pure,
        # source_unit_cargo_loader_can_place_on_state, composing
        # source_unit_cargo_loader_can_create_state (N2322, via
        # the N2140 bridge) and returning {can_place_on} -- no
        # duplicated cap math. canPlaceOn is a placement gate,
        # NOT tick wiring: the driver never calls it each tick
        # (grep-verified: only the Documented limits mention
        # it), so this slice adds no tick call. One new result
        # symbol.
        self.assertEqual(
            ledger['N2330']['source_symbols'],
            [
                'source_unit_cargo_loader_can_place_on_state_result.can_place_on',
            ],
        )
        for name in ledger['N2330']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/UnitCargoLoader.java')
                self.assertEqual(symbol['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_can_place_on_state')
        self.assertEqual(ledger['N2330']['runtime_proof'], '/root/C07UnitCargoLoaderCanPlaceOnProof')
        self.assertEqual(
            ledger['N2330']['tests'],
            [
                'test_c07_unit_cargo_loader_can_place_on_registration',
                'test_all_c07_unit_cargo_loader_can_place_on_input_evidence_is_exact',
                'test_unit_cargo_loader_can_place_on_state',
                'test_reference_graph_and_actual_c07_unit_cargo_loader_can_place_on',
            ],
        )
        self.assertTrue(ledger['N2330']['deferred_exprs'])
        # This slice resolves the canPlaceOn placement-gate
        # entry, so it is gone from DEFERRED -- and two new
        # entries take its place: the drawPlace cap-warning
        # preview (UnitCargoLoader.java:70-75, presentation,
        # never covered by the resolved entry) and the live
        # placement call site (no placement path calls the
        # pure yet; the valid-place hook defaults to the Block
        # default true without one). The N2322 live
        # unit-count source, the bar / draw / read-write rows
        # and the live unit fill stay deferred.
        self.assertFalse(any(entry.startswith('UnitCargoLoader canPlaceOn / Units.canCreate rows (') for entry in ledger['N2330']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader drawPlace rows (') for entry in ledger['N2330']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader canPlaceOn live placement call site (') for entry in ledger['N2330']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader canCreate live unit-count source (') for entry in ledger['N2330']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader bar rows (') for entry in ledger['N2330']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader draw rows (') for entry in ledger['N2330']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader read/write rows (') for entry in ledger['N2330']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader updateTile live unit fill (') for entry in ledger['N2330']['deferred_exprs']))

    def test_all_c07_unit_cargo_loader_can_place_on_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2330']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_can_place_on_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/UnitCargoLoader.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/entities/Units.java',
            'core/src/mindustry/type/UnitType.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2330']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_cargo_loader_can_place_on_state(self):
        unit_cargo_loader = UNIT_CARGO_LOADER_STATE.read_text(encoding='utf-8')
        # The canPlaceOn pure (N2330) composes the N2322
        # canCreate verdict: Java's override is
        # `return super.canPlaceOn(tile, team, rotation) &&
        # Units.canCreate(team, unitType);`
        # (UnitCargoLoader.java:65-68, the return is :66) and
        # the Block default is `return true;`
        # (Block.java:606-608), so can_place_on == can_create.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test). Cite notes
        # (all verified by grep at this pin): the method body
        # is :65-67 with :68 blank, so the repo's :65-68 cite
        # (kept from the DEFERRED entry and the N2322 worker's
        # verified note) covers the method plus its trailing
        # blank line; Block.canPlaceOn is :606-608 exactly as
        # briefed; drawPlace is :70-75 with the canCreate call
        # at :73. The pure takes the frame only: Java receives
        # tile / team / rotation, but super ignores them
        # (constant true) and canCreate needs only team +
        # unitType, which arrive through the frame
        # can_create_inputs dict (the 11 N2322 keys), so no
        # tile geometry is needed. No input stamped means
        # permissive (the N2322 default, inherited).
        self.assertIn('static func source_unit_cargo_loader_can_place_on_state', unit_cargo_loader)
        self.assertIn('public boolean canPlaceOn(Tile tile, Team team, int rotation){', unit_cargo_loader)
        self.assertIn('return super.canPlaceOn(tile, team, rotation) && Units.canCreate(team, unitType);', unit_cargo_loader)
        self.assertIn('return true;', unit_cargo_loader)
        self.assertIn('return !type.useUnitCap || (team.data().countType(type) < getCap(team) && !type.isBanned());', unit_cargo_loader)
        self.assertIn('public UnitType unitType = UnitTypes.manifold;', unit_cargo_loader)
        self.assertIn('public class UnitCargoLoader extends Block{', unit_cargo_loader)
        # The pure composes the N2322 canCreate pure -- it
        # does not duplicate the cap math -- and models the
        # super call as the Block default true.
        self.assertIn('var super_can_place_on: bool = true', unit_cargo_loader)
        self.assertIn('source_unit_cargo_loader_can_create_state(frame)', unit_cargo_loader)
        self.assertIn('{"can_place_on": super_can_place_on and bool(can_create_state.get("can_create", true))}', unit_cargo_loader)
        # canPlaceOn is a placement gate, NOT tick wiring: the
        # only call-shaped occurrence of the pure in the
        # driver is its own definition -- no tick call site,
        # no placement hook wiring (the live call site waits
        # for its own slice).
        self.assertEqual(unit_cargo_loader.count('source_unit_cargo_loader_can_place_on_state('), 1)
        # The documented limits now record canPlaceOn as live
        # (N2330); the bar / draw / read-write rows still
        # defer, and the N2322 canCreate evaluation, the N2234
        # updateTile advance and the N2211 shouldConsume gate
        # stay live.
        self.assertIn('canPlaceOn live (N2330)', unit_cargo_loader)
        self.assertIn('canCreate live evaluation (N2322)', unit_cargo_loader)
        self.assertIn('updateTile advance live (N2234)', unit_cargo_loader)
        self.assertIn('shouldConsume gate live (N2211)', unit_cargo_loader)
        self.assertIn('static func source_unit_cargo_loader_can_create_state', unit_cargo_loader)
        self.assertIn('static func source_unit_cargo_loader_update_tile_advance_state', unit_cargo_loader)
        self.assertIn('static func source_unit_cargo_loader_should_consume_state', unit_cargo_loader)
        # The proof's keys drive the pure (can create, capped,
        # banned, no cap when the cap is unused, uncapped
        # branches, the permissive default without inputs).
        # There is NO live-tick key: canPlaceOn is a placement
        # gate, not tick wiring, so no tick reports a verdict.
        proof = UNIT_CARGO_LOADER_CAN_PLACE_ON_PROOF.read_text(encoding='utf-8')
        for key in [
            'can_place_on_when_can_create',
            'cannot_place_on_when_capped',
            'permissive_default_without_inputs',
            'banned_type_cannot_place',
            'no_cap_when_unit_cap_unused',
            'uncapped_when_unit_cap_disabled',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceUnitCargoLoaderBuildState.gd")', proof)
        self.assertTrue(UNIT_CARGO_LOADER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = UNIT_CARGO_LOADER_CAN_PLACE_ON_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07UnitCargoLoaderCanPlaceOnProof.gd', scene)
        self.assertIn('C07UnitCargoLoaderCanPlaceOnProof', scene)

    def test_reference_graph_and_actual_c07_unit_cargo_loader_can_place_on(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitCargoLoaderCanPlaceOnProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_CARGO_LOADER_CAN_PLACE_ON_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'can_place_on_when_can_create',
            'cannot_place_on_when_capped',
            'permissive_default_without_inputs',
            'banned_type_cannot_place',
            'no_cap_when_unit_cap_unused',
            'uncapped_when_unit_cap_disabled',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
