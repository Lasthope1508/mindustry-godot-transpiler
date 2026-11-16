import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadMassDriverBuildState.gd'
PAYLOAD_MASS_DRIVER_LINK_CONFIG_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverLinkConfigRowsProof.gd'
PAYLOAD_MASS_DRIVER_LINK_CONFIG_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverLinkConfigRowsProof.tscn'


class C07PayloadMassDriverLinkConfigRowsTests(unittest.TestCase):
    def test_c07_payload_mass_driver_link_config_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2460']['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_link_valid_state')
        # The PayloadMassDriver tick is live (N2245
        # updateTile advance + N2246 state branches +
        # N2298/N2304 acceptPayload gate) but NOTHING
        # modeled the link / config rows: config
        # Point2 (PayloadMassDriver.java:70, relative
        # point + tile, packed) + config Integer (:71,
        # absolute packed int), onConfigureBuildTapped
        # (:443-460, self-tap / unlink / link / fall
        # through), linkValid (:466-468, link != -1 +
        # looked-up PayloadDriverBuild + block == block
        # + team == team + within(range)) and config()
        # (:471-474, null tile -> null, else unpack
        # minus tile). The DEFERRED entry cited
        # :64-65 and :321-350 -- BOTH WRONG: :64-65
        # are the constructor flags (the handlers are
        # :70-71) and :321-350 are sense() /
        # updatePayload() / draw(). N2460 ports them
        # as THREE pure-only pures (the N2449
        # discriminated-action precedent): the link
        # verdict, the config apply + config() value,
        # and the tap handler. Six new result symbols.
        self.assertEqual(
            ledger['N2460']['source_symbols'],
            [
                'source_payload_mass_driver_link_valid_state_result.link_valid',
                'source_payload_mass_driver_config_state_result.link',
                'source_payload_mass_driver_config_state_result.config_value',
                'source_payload_mass_driver_configure_tapped_state_result.link_after',
                'source_payload_mass_driver_configure_tapped_state_result.deselect_called',
                'source_payload_mass_driver_configure_tapped_state_result.handled',
            ],
        )
        expected_sources = {
            'source_payload_mass_driver_link_valid_state_result.link_valid': 'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java',
            'source_payload_mass_driver_config_state_result.link': 'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java',
            'source_payload_mass_driver_config_state_result.config_value': 'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java',
            'source_payload_mass_driver_configure_tapped_state_result.link_after': 'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java',
            'source_payload_mass_driver_configure_tapped_state_result.deselect_called': 'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java',
            'source_payload_mass_driver_configure_tapped_state_result.handled': 'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        for name in ledger['N2460']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourcePayloadMassDriverBuildState.source_payload_mass_driver_'))
        self.assertEqual(ledger['N2460']['runtime_proof'], '/root/C07PayloadMassDriverLinkConfigRowsProof')
        self.assertEqual(
            ledger['N2460']['tests'],
            [
                'test_c07_payload_mass_driver_link_config_rows_registration',
                'test_all_c07_payload_mass_driver_link_config_rows_input_evidence_is_exact',
                'test_payload_mass_driver_link_config_rows_state',
                'test_reference_graph_and_actual_c07_payload_mass_driver_link_config_rows',
            ],
        )
        self.assertTrue(ledger['N2460']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #3 (1-based in
        # the merged advances-29 DEFERRED base): the
        # PayloadMassDriver link/config rows entry is
        # REMOVED -- config Point2/Integer,
        # onConfigureBuildTapped, linkValid and
        # config() are all live now. Net 253 - 1 =
        # 252. The MassDriver link/config entry
        # STAYS (a different family, its own slice).
        self.assertFalse(any(entry.startswith('PayloadMassDriver link/config rows (') for entry in ledger['N2460']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver link/config rows (') for entry in ledger['N2460']['deferred_exprs']))
        self.assertEqual(len(ledger['N2460']['deferred_exprs']), 252)

    def test_all_c07_payload_mass_driver_link_config_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2460']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourcePayloadMassDriverBuildState.source_payload_mass_driver_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java',
            'core/src/mindustry/world/blocks/distribution/MassDriver.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/input/InputHandler.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2460']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_mass_driver_link_config_rows_state(self):
        payload_mass_driver = PAYLOAD_MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The link / config rows (PayloadMassDriver.
        # java:70-71 config handlers; :443-460
        # onConfigureBuildTapped; :466-468 linkValid;
        # :471-474 config()): the link is a PACKED
        # INT (`public int link = -1;`, :133), the
        # Point2 config is RELATIVE (point + tile,
        # packed) while the Integer config is the
        # absolute packed int, linkValid folds the
        # -1 check into one conjunction (MassDriver
        # writes it as an early return, MassDriver.
        # java:347), and the tap gate is `other.block
        # instanceof PayloadMassDriver` -- NOT
        # `other.block == block` (MassDriver.java:
        # 274), so a small driver links to a large
        # one. The tap return means "should
        # deselect" (BuildingComp.java:1690), so
        # handled INVERTS it: true exactly when a
        # configure ran. config() returns null for
        # a null tile, else unpack(link) minus tile
        # -- with NO -1 special case, so unpack(-1)
        # = (-1, -1) (arc Point2.java:35-37). PMD
        # registers NO configClear: "clear" is
        # configure(-1) through the Integer handler.
        # Pure-only: the tick never calls config /
        # onConfigureBuildTapped / linkValid. Keep
        # each Java expr on ONE comment line (the
        # N2148 lesson: a split line fails this
        # test).
        self.assertIn('static func source_payload_mass_driver_link_valid_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_config_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_configure_tapped_state', payload_mass_driver)
        self.assertIn('config(Point2.class, (PayloadDriverBuild tile, Point2 point) -> tile.link = Point2.pack(point.x + tile.tileX(), point.y + tile.tileY()));', payload_mass_driver)
        self.assertIn('config(Integer.class, (PayloadDriverBuild tile, Integer point) -> tile.link = point);', payload_mass_driver)
        self.assertIn('public int link = -1;', payload_mass_driver)
        self.assertIn('public boolean onConfigureBuildTapped(Building other){', payload_mass_driver)
        self.assertIn('if(this == other){', payload_mass_driver)
        self.assertIn('if(link == -1) deselect();', payload_mass_driver)
        self.assertIn('configure(-1);', payload_mass_driver)
        self.assertIn('if(link == other.pos()){', payload_mass_driver)
        self.assertIn('}else if(other.block instanceof PayloadMassDriver && other.dst(tile) <= range && other.team == team){', payload_mass_driver)
        self.assertIn('configure(other.pos());', payload_mass_driver)
        self.assertIn('protected boolean linkValid(){', payload_mass_driver)
        self.assertIn('return link != -1 && world.build(this.link) instanceof PayloadDriverBuild other && other.block == block && other.team == team && within(other, range);', payload_mass_driver)
        self.assertIn('public Point2 config(){', payload_mass_driver)
        self.assertIn('if(tile == null) return null;', payload_mass_driver)
        self.assertIn('return Point2.unpack(link).sub(tile.x, tile.y);', payload_mass_driver)
        self.assertIn('configurable = true;', payload_mass_driver)
        self.assertIn('public class PayloadDriverBuild extends PayloadBlockBuild<Payload> implements RotBlock{', payload_mass_driver)
        self.assertIn('public class PayloadMassDriver extends PayloadBlock{', payload_mass_driver)
        self.assertIn('}else if(other.block == block && other.dst(tile) <= range && other.team == team){', payload_mass_driver)
        self.assertIn('if(link == -1) return false;', payload_mass_driver)
        self.assertIn('@return whether this block should be deselected.', payload_mass_driver)
        self.assertIn('Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();', payload_mass_driver)
        self.assertIn('block.configurations.get(type).get(this, value);', payload_mass_driver)
        self.assertIn('if(config.isShown() && config.getSelected().onConfigureBuildTapped(build)){', payload_mass_driver)
        # The documented limits record the link /
        # config rows as live.
        self.assertIn('Link/config rows live (N2460)', payload_mass_driver)
        # The proof's keys drive the pures (the link
        # verdict incl. -1 and range, the relative
        # Point2 config, the clear, and the tap
        # link).
        proof = PAYLOAD_MASS_DRIVER_LINK_CONFIG_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'link_valid_true',
            'link_valid_minus_one',
            'link_valid_range',
            'config_point2_relative',
            'config_clear',
            'tapped_link',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourcePayloadMassDriverBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_MASS_DRIVER_STATE.exists())
        self.assertTrue(PAYLOAD_MASS_DRIVER_LINK_CONFIG_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07PayloadMassDriverLinkConfigRowsProof.gd', PAYLOAD_MASS_DRIVER_LINK_CONFIG_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_payload_mass_driver_link_config_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadMassDriverLinkConfigRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_MASS_DRIVER_LINK_CONFIG_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'link_valid_true',
            'link_valid_minus_one',
            'link_valid_range',
            'config_point2_relative',
            'config_clear',
            'tapped_link',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
