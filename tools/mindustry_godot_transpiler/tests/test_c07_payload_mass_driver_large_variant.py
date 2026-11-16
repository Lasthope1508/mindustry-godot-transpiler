import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadMassDriverBuildState.gd'
PAYLOAD_MASS_DRIVER_LARGE_VARIANT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverLargeVariantProof.gd'
PAYLOAD_MASS_DRIVER_LARGE_VARIANT_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverLargeVariantProof.tscn'


class C07PayloadMassDriverLargeVariantTests(unittest.TestCase):
    def test_c07_payload_mass_driver_large_variant_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        # N2357 is a VERIFICATION slice, not a port slice: no new
        # pure, no new symbol, no new ledger entry (the +0
        # precedent -- N2307, N2337, N2300, N2302, N2309 have no
        # ledger entry either). The large def is covered by
        # three existing entries: the N2245 advance, the N2246
        # branches, and the N2304 per-def gate. The registration
        # test pins those owners, and pins that this slice adds
        # no entry of its own.
        self.assertNotIn('N2357', ledger)
        self.assertEqual(ledger['N2245']['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_update_tile_advance_state')
        self.assertEqual(ledger['N2246']['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_state_branches_state')
        self.assertEqual(ledger['N2304']['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_accept_payload_state_for_def')
        self.assertEqual(
            ledger['N2304']['source_symbols'],
            [
                'source_payload_mass_driver_accept_payload_state_for_def_result.accepts',
                'source_payload_mass_driver_accept_payload_state_for_def_result.size_fits',
                'source_payload_mass_driver_accept_payload_state_for_def_result.threshold',
            ],
        )
        for name in ledger['N2304']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java')
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_accept_payload_state_for_def')
        # The catalog carries the per-def rows the driver reads
        # live: size / reload / range / consumePower for BOTH
        # defs (chargeTime / maxPayloadSize are NOT catalog
        # properties -- the driver resolves them by block id,
        # pinned in the row-state test below).
        blocks = json.loads((generated / 'source_modules/content_registry_blocks.json').read_text(encoding='utf-8'))['blocks']
        small = blocks['payload-mass-driver']
        large = blocks['large-payload-mass-driver']
        self.assertEqual(small['implementation'], 'PayloadMassDriver')
        self.assertEqual(large['implementation'], 'PayloadMassDriver')
        self.assertEqual(small['properties']['size'], 3)
        self.assertEqual(large['properties']['size'], 5)
        self.assertEqual(small['properties']['reload'], 130.0)
        self.assertEqual(large['properties']['reload'], 130.0)
        self.assertEqual(small['properties']['range'], 700.0)
        self.assertEqual(large['properties']['range'], 2100.0)
        self.assertEqual(small['properties']['consumePower'], 0.5)
        self.assertEqual(large['properties']['consumePower'], 3.0)
        self.assertEqual(small['properties']['powerUsage'], 0.5)
        self.assertEqual(large['properties']['powerUsage'], 3.0)
        self.assertNotIn('chargeTime', small['properties'])
        self.assertNotIn('chargeTime', large['properties'])
        self.assertNotIn('maxPayloadSize', small['properties'])
        self.assertNotIn('maxPayloadSize', large['properties'])

    def test_all_c07_payload_mass_driver_large_variant_input_evidence_is_exact(self):
        # No N2357 ledger entry (see the registration test), so
        # the exact evidence is verified straight from upstream
        # instead of through ledger exact_exprs: both defs'
        # lines in Blocks.java plus the class defaults in
        # PayloadMassDriver.java, verbatim AND on the right
        # lines (the N2307 lesson: a right string on a wrong
        # line is a stale cite).
        blocks = (ROOT / 'mindustry-upstream/core/src/mindustry/content/Blocks.java').read_text(encoding='utf-8')
        blocks_lines = blocks.splitlines()
        payload_mass_driver = (ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java').read_text(encoding='utf-8')
        payload_mass_driver_lines = payload_mass_driver.splitlines()
        for expr in [
            'payloadMassDriver = new PayloadMassDriver("payload-mass-driver"){{',
            'largePayloadMassDriver = new PayloadMassDriver("large-payload-mass-driver"){{',
            'size = 3;',
            'size = 5;',
            'reload = 130f;',
            'chargeTime = 90f;',
            'chargeTime = 100f;',
            'range = 700f;',
            'range = 2100f;',
            'maxPayloadSize = 2.5f;',
            'maxPayloadSize = 4f;',
            'consumePower(0.5f);',
            'consumePower(3f);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, blocks)
        for expr in [
            'public float range = 100f;',
            'public float reload = 30f;',
            'public float chargeTime = 100f;',
            'public float maxPayloadSize = 3;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, payload_mass_driver)
        # Small def (Blocks.java:6617-6627).
        self.assertIn('payload-mass-driver', blocks_lines[6616])
        self.assertEqual(blocks_lines[6619].strip(), 'size = 3;')
        self.assertEqual(blocks_lines[6620].strip(), 'reload = 130f;')
        self.assertEqual(blocks_lines[6621].strip(), 'chargeTime = 90f;')
        self.assertEqual(blocks_lines[6622].strip(), 'range = 700f;')
        self.assertEqual(blocks_lines[6623].strip(), 'maxPayloadSize = 2.5f;')
        self.assertEqual(blocks_lines[6625].strip(), 'consumePower(0.5f);')
        # Large def (Blocks.java:6629-6639).
        self.assertIn('large-payload-mass-driver', blocks_lines[6628])
        self.assertEqual(blocks_lines[6631].strip(), 'size = 5;')
        self.assertEqual(blocks_lines[6632].strip(), 'reload = 130f;')
        self.assertEqual(blocks_lines[6633].strip(), 'chargeTime = 100f;')
        self.assertEqual(blocks_lines[6634].strip(), 'range = 2100f;')
        self.assertEqual(blocks_lines[6635].strip(), 'maxPayloadSize = 4f;')
        self.assertEqual(blocks_lines[6636].strip(), 'consumePower(3f);')
        # Class defaults (PayloadMassDriver.java:24-30): the
        # DEFs win on every field except chargeTime for the
        # large def, where the def (100f) happens to equal the
        # class default (100f) -- the large chargeTime is still
        # a per-def value, resolved by block id, not the class
        # fallback.
        self.assertEqual(payload_mass_driver_lines[23].strip(), 'public float range = 100f;')
        self.assertEqual(payload_mass_driver_lines[27].strip(), 'public float reload = 30f;')
        self.assertEqual(payload_mass_driver_lines[28].strip(), 'public float chargeTime = 100f;')
        self.assertEqual(payload_mass_driver_lines[29].strip(), 'public float maxPayloadSize = 3;')

    def test_payload_mass_driver_large_variant_state(self):
        payload_mass_driver = PAYLOAD_MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The driver documents BOTH defs in its header
        # (Blocks.java:6617-6639): the small def (size 3,
        # reload 130f, chargeTime 90f, range 700f,
        # maxPayloadSize 2.5f, consumePower 0.5f) and the large
        # def (size 5, reload 130f, chargeTime 100f, range
        # 2100f, maxPayloadSize 4f, consumePower 3f), beating
        # the class defaults (range 100f, reload 30f,
        # chargeTime 100f, maxPayloadSize 3,
        # PayloadMassDriver.java:24-30).
        self.assertIn('large-payload-mass-driver: `size = 5;` / `reload = 130f;` / `chargeTime = 100f;` /', payload_mass_driver)
        self.assertIn('`range = 2100f;` / `maxPayloadSize = 4f;` / `consumePower(3f);` (Blocks.java:6629-6639).', payload_mass_driver)
        self.assertIn('payload-mass-driver: `size = 3;` / `reload = 130f;` / `chargeTime = 90f;` /', payload_mass_driver)
        self.assertIn('`range = 700f;` / `maxPayloadSize = 2.5f;` / `consumePower(0.5f);` (Blocks.java:6617-6628);', payload_mass_driver)
        # The per-def consts: the small-def values are the
        # base consts (chargeTime 90, range 700) and the large
        # values are the _LARGE consts (100 / 2100); the
        # maxPayloadSize base const is the CLASS default (3.0)
        # with explicit _SMALL (2.5) and _LARGE (4.0) consts
        # (the N2304 comment pins this asymmetry).
        self.assertIn('const SOURCE_PAYLOAD_MASS_DRIVER_RANGE := 700.0', payload_mass_driver)
        self.assertIn('const SOURCE_PAYLOAD_MASS_DRIVER_RANGE_LARGE := 2100.0', payload_mass_driver)
        self.assertIn('const SOURCE_PAYLOAD_MASS_DRIVER_CHARGE_TIME := 90.0', payload_mass_driver)
        self.assertIn('const SOURCE_PAYLOAD_MASS_DRIVER_CHARGE_TIME_LARGE := 100.0', payload_mass_driver)
        self.assertIn('const SOURCE_PAYLOAD_MASS_DRIVER_MAX_PAYLOAD_SIZE := 3.0', payload_mass_driver)
        self.assertIn('const SOURCE_PAYLOAD_MASS_DRIVER_MAX_PAYLOAD_SIZE_SMALL := 2.5', payload_mass_driver)
        self.assertIn('const SOURCE_PAYLOAD_MASS_DRIVER_MAX_PAYLOAD_SIZE_LARGE := 4.0', payload_mass_driver)
        self.assertIn('const SOURCE_PAYLOAD_MASS_DRIVER_RELOAD := 130.0', payload_mass_driver)
        # The three per-def helpers resolve by block id -- no
        # small-def value is hardcoded in a logic path: the
        # chargeTime / range helpers return the large value
        # for the large def and the small value otherwise, and
        # the maxPayloadSize helper checks BOTH defs
        # explicitly and keeps the class default for an unknown
        # block id.
        self.assertIn('static func _payload_mass_driver_charge_time_for_block(block_id: String) -> float:', payload_mass_driver)
        self.assertIn('static func _payload_mass_driver_range_for_block(block_id: String) -> float:', payload_mass_driver)
        self.assertIn('static func _payload_mass_driver_max_payload_size_for_block(block_id: String) -> float:', payload_mass_driver)
        self.assertIn('if block_id == "large-payload-mass-driver":', payload_mass_driver)
        self.assertIn('if block_id == "payload-mass-driver":', payload_mass_driver)
        self.assertIn('return SOURCE_PAYLOAD_MASS_DRIVER_CHARGE_TIME_LARGE', payload_mass_driver)
        self.assertIn('return SOURCE_PAYLOAD_MASS_DRIVER_RANGE_LARGE', payload_mass_driver)
        self.assertIn('return SOURCE_PAYLOAD_MASS_DRIVER_MAX_PAYLOAD_SIZE_LARGE', payload_mass_driver)
        # The live tick reads the per-def values through the
        # helpers (range for the link check, chargeTime for
        # the fire gate, maxPayloadSize for the accept gate)
        # and reload / size from the catalog properties --
        # the small-def defaults there (130 / 3) only apply
        # when the catalog row is missing, and the catalog
        # carries 130 / 5 for the large def (pinned in the
        # registration test). The power row reads
        # consumePower through the catalog (has_power_consumer
        # checks block.properties.has("consumePower")).
        self.assertIn('var link_range: float = _payload_mass_driver_range_for_block(block_id)', payload_mass_driver)
        self.assertIn('var charge_time: float = _payload_mass_driver_charge_time_for_block(block_id)', payload_mass_driver)
        self.assertIn('var reload_value: float = float(block.properties.get("reload", SOURCE_PAYLOAD_MASS_DRIVER_RELOAD))', payload_mass_driver)
        self.assertIn('var size_value: int = int(block.properties.get("size", 3))', payload_mass_driver)
        self.assertIn('var max_payload_size: float = _payload_mass_driver_max_payload_size_for_block(block_id)', payload_mass_driver)
        self.assertIn('var has_power_consumer: bool = bool(block.properties.has("consumePower"))', payload_mass_driver)
        self.assertIn('source_payload_mass_driver_accept_payload_state_for_def(float(offered_payload_size), frame.get("payload", null) != null, max_payload_size)', payload_mass_driver)
        # The pures the large def runs through are intact:
        # the N2245 advance, the N2246 branches, the N2298
        # class-default gate, the N2304 per-def gate, the
        # power row, the tick, and the frame bind.
        self.assertIn('static func source_payload_mass_driver_update_tile_advance_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_state_branches_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_accept_payload_state(payload_size: float, has_payload: bool) -> Dictionary:', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_accept_payload_state_for_def(payload_size: float, has_payload: bool, max_payload_size: float) -> Dictionary:', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_power_status_row_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_tick_buildings_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_bind_frame_state', payload_mass_driver)
        # The proof's keys drive the large def end to end:
        # the catalog rows, the 100f chargeTime discriminator
        # (a charge that fires the small def does not fire
        # the large def), the 2100f range live link (the
        # large pair 40 cells apart -- 320 Java world units
        # -- links, the small pair 100 cells apart -- 800
        # Java world units, re-seeded N2365 after the N2364
        # tile-size fix -- does not), the size-5 move-out
        # dest, and the live per-def accept verdict. Static
        # checks:
        # the proof preloads the family state file that
        # exists, and the scene file references the proof
        # script that exists.
        proof = PAYLOAD_MASS_DRIVER_LARGE_VARIANT_PROOF.read_text(encoding='utf-8')
        for key in [
            'large_def_catalog_rows',
            'large_def_charge_time_100',
            'large_def_range_2100_live_link',
            'large_def_size_5_move_out_dest',
            'large_def_accepts_size_32_live',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadMassDriverBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_MASS_DRIVER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_MASS_DRIVER_LARGE_VARIANT_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadMassDriverLargeVariantProof.gd', scene)
        self.assertIn('C07PayloadMassDriverLargeVariantProof', scene)

    def test_reference_graph_and_actual_c07_payload_mass_driver_large_variant(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadMassDriverLargeVariantProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_MASS_DRIVER_LARGE_VARIANT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'large_def_catalog_rows',
            'large_def_charge_time_100',
            'large_def_range_2100_live_link',
            'large_def_size_5_move_out_dest',
            'large_def_accepts_size_32_live',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
