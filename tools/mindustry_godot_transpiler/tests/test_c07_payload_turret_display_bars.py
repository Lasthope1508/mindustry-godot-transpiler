import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_AMMO_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourcePayloadAmmoTurretBuildPortBridge.gd'
PAYLOAD_AMMO_TURRET_DISPLAY_BARS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadTurretDisplayBarsProof.gd'


class C07PayloadTurretDisplayBarsTests(unittest.TestCase):
    def test_c07_payload_turret_display_bars_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2381']['godot_owner'], 'PortGame.source_payload_ammo_turret_build_display_bars_state')
        # PayloadTurretBuild.displayBars()+updateTile()+getPayloads()
        # (PayloadAmmoTurret.java:143-145/:165-168/:171-177):
        # `public PayloadSeq getPayloads(){`
        # `return payloads;`
        # `}`
        # `public void updateTile(){`
        # `totalAmmo = payloads.total();`
        # `super.updateTile();`
        # `}`
        # `public void displayBars(Table bars){`
        # `super.displayBars(bars);`
        # `bars.add(new Bar("stat.ammo", Pal.ammo, () -> (float)totalAmmo / maxAmmo)).growX();`
        # `bars.row();`
        # `}`
        # on `public class PayloadTurretBuild extends TurretBuild{`
        # (PayloadAmmoTurret.java:94) inside
        # `public class PayloadAmmoTurret extends Turret{`
        # (PayloadAmmoTurret.java:21). This is the
        # PayloadAmmoTurret grouped override: getPayloads
        # returns the payloads seq itself; updateTile syncs
        # totalAmmo from `payloads.total()` then calls the
        # TurretBuild super tick; displayBars adds the
        # "stat.ammo" bar (fraction (float)totalAmmo /
        # maxAmmo) to the table then opens a new row.
        # `super.updateTile();` is callee/context (already
        # owned by N1222/N1417/N2103/N2108/N2110/N2153/
        # N2362) -- NOT a distinguishing expr.
        # `super.displayBars(bars);` is callee/context
        # (Block/Building displayBars) -- NOT a
        # distinguishing expr. The distinguishing lines are
        # `return payloads;`, `totalAmmo = payloads.total();`
        # and the bars.add / bars.row pair (all 0-hit in
        # both ledgers at HEAD 4f53d70e). `payloads`
        # arrives as the explicit payload_contents param
        # (the N2330 param precedent); `bars` arrives as
        # the explicit bars param (rows of bar specs);
        # `totalAmmo`/`maxAmmo` arrive as explicit int
        # params; Pal.ammo / Table / Bar are NOT ported.
        # Four new result symbols: bars, ammo_fraction,
        # total_ammo, payloads.
        self.assertEqual(
            ledger['N2381']['source_symbols'],
            [
                'source_payload_ammo_turret_build_display_bars_state_result.bars',
                'source_payload_ammo_turret_build_display_bars_state_result.ammo_fraction',
                'source_payload_ammo_turret_build_update_tile_state_result.total_ammo',
                'source_payload_ammo_turret_build_get_payloads_state_result.payloads',
            ],
        )
        for name in ledger['N2381']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2381']['runtime_proof'], '/root/C07PayloadTurretDisplayBarsProof')
        self.assertEqual(
            ledger['N2381']['tests'],
            [
                'test_c07_payload_turret_display_bars_registration',
                'test_all_c07_payload_turret_display_bars_input_evidence_is_exact',
                'test_payload_turret_display_bars_update_tile_get_payloads_state',
                'test_reference_graph_and_actual_c07_payload_turret_display_bars',
            ],
        )
        self.assertTrue(ledger['N2381']['deferred_exprs'])

    def test_all_c07_payload_turret_display_bars_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2381']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2381']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_turret_display_bars_update_tile_get_payloads_state(self):
        bridge = PAYLOAD_AMMO_TURRET_BRIDGE.read_text(encoding='utf-8')
        # PayloadTurretBuild.displayBars()+updateTile()+getPayloads()
        # (PayloadAmmoTurret.java:143-145/:165-168/:171-177)
        # groups three one-to-three-line overrides: getPayloads
        # returns the payloads seq; updateTile syncs totalAmmo
        # from payloads.total() then calls the super tick;
        # displayBars adds the "stat.ammo" bar then opens a
        # new row. `super.updateTile();` /
        # `super.displayBars(bars);` are callee/context.
        # NO driver tick line of its own: updateTile only
        # syncs the frame field (the caller wiring waits
        # for its own slice); displayBars is a UI spec, not
        # a per-tick write; getPayloads is a pure accessor.
        self.assertIn('static func source_payload_ammo_turret_build_display_bars_state(bars: Array, total_ammo: int, max_ammo: int) -> Dictionary:', bridge)
        self.assertIn('static func source_payload_ammo_turret_build_update_tile_state(payload_contents: Array) -> Dictionary:', bridge)
        self.assertIn('static func source_payload_ammo_turret_build_get_payloads_state(payload_contents: Array) -> Dictionary:', bridge)
        self.assertIn('return {"bars": rows, "ammo_fraction": ammo_fraction}', bridge)
        self.assertIn('return {"total_ammo": total_ammo}', bridge)
        self.assertIn('return {"payloads": payload_contents.duplicate()}', bridge)
        for expr in [
            'public class PayloadAmmoTurret extends Turret{',
            'public class PayloadTurretBuild extends TurretBuild{',
            'public PayloadSeq payloads = new PayloadSeq();',
            '@Override',
            'public PayloadSeq getPayloads(){',
            'return payloads;',
            'public void updateTile(){',
            'totalAmmo = payloads.total();',
            'super.updateTile();',
            'public void displayBars(Table bars){',
            'super.displayBars(bars);',
            'bars.add(new Bar("stat.ammo", Pal.ammo, () -> (float)totalAmmo / maxAmmo)).growX();',
            'bars.row();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the three pure functions
        # with synthetic inputs (no live tick): displayBars
        # adds the ammo bar to the current row and opens a
        # new row / full fraction / zero-max guard /
        # appends to an existing row / inputs unmutated /
        # exactly two result keys; updateTile counts the
        # payloads / empty stays zero / exactly one result
        # key; getPayloads returns the contents / empty
        # stays empty / returns a copy / exactly one
        # result key.
        proof = PAYLOAD_AMMO_TURRET_DISPLAY_BARS_PROOF.read_text(encoding='utf-8')
        for key in [
            'display_bars_adds_ammo_bar',
            'display_bars_fraction_full',
            'display_bars_fraction_zero_max',
            'display_bars_appends_to_existing_row',
            'display_bars_inputs_unmutated',
            'display_bars_returns_only_two_keys',
            'update_tile_total_ammo_counts_payloads',
            'update_tile_empty_payloads_zero',
            'update_tile_returns_only_one_key',
            'get_payloads_returns_contents',
            'get_payloads_empty_returns_empty',
            'get_payloads_returns_copy',
            'get_payloads_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_payload_turret_display_bars(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadTurretDisplayBarsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_TURRET_DISPLAY_BARS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'display_bars_adds_ammo_bar',
            'display_bars_fraction_full',
            'display_bars_fraction_zero_max',
            'display_bars_appends_to_existing_row',
            'display_bars_inputs_unmutated',
            'display_bars_returns_only_two_keys',
            'update_tile_total_ammo_counts_payloads',
            'update_tile_empty_payloads_zero',
            'update_tile_returns_only_one_key',
            'get_payloads_returns_contents',
            'get_payloads_empty_returns_empty',
            'get_payloads_returns_copy',
            'get_payloads_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
