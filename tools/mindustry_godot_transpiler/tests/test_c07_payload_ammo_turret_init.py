import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BRIDGE = ROOT / 'godot-mindustry/src/game/SourcePayloadAmmoTurretBuildPortBridge.gd'
PAYLOAD_AMMO_TURRET_INIT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadAmmoTurretInitProof.gd'


class C07PayloadAmmoTurretInitTests(unittest.TestCase):
    def test_c07_payload_ammo_turret_init_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2396']['godot_owner'], 'PortGame.source_payload_ammo_turret_init_state')
        # PayloadAmmoTurret.init() (PayloadAmmoTurret.java:59-93)
        # registers one ConsumePayloadFilter whose build()
        # lists every ammo content (blocks then units) that
        # passes the filter and is unlocked, whose
        # displayContent() gates each entry on
        # `filter.get(content) && content.unlockedNow()`,
        # and whose efficiency() is 1f exactly when the
        # build is a PayloadTurretBuild with any payload.
        # One pure function on the PortBridge file (the
        # N2358/N2387 PortGame-owner precedent): content
        # blocks/units arrive as explicit Array params,
        # filter/unlockedNow/uiIcon as explicit Callables --
        # Table/MultiReqImage/ReqImage/Stats are NOT ported.
        # display() is a no-op comment (`//don't display`)
        # and owns no expr. Two new result symbols:
        # display_contents, efficiency.
        self.assertEqual(
            ledger['N2396']['source_symbols'],
            [
                'source_payload_ammo_turret_init_state_result.display_contents',
                'source_payload_ammo_turret_init_state_result.efficiency',
            ],
        )
        for name in ledger['N2396']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2396']['runtime_proof'], '/root/C07PayloadAmmoTurretInitProof')
        self.assertEqual(
            ledger['N2396']['tests'],
            [
                'test_c07_payload_ammo_turret_init_registration',
                'test_all_c07_payload_ammo_turret_init_input_evidence_is_exact',
                'test_payload_ammo_turret_init_state',
                'test_reference_graph_and_actual_c07_payload_ammo_turret_init',
            ],
        )
        self.assertTrue(ledger['N2396']['deferred_exprs'])

    def test_all_c07_payload_ammo_turret_init_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2396']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2396']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_ammo_turret_init_state(self):
        bridge = BRIDGE.read_text(encoding='utf-8')
        # The pure init() row lives on the PortBridge file
        # next to the N2358 currentAmmo row:
        # PayloadAmmoTurret.init()
        # (PayloadAmmoTurret.java:59-93) registers
        # `consume(new ConsumePayloadFilter(i ->
        # ammoTypes.containsKey(i)){...})`
        # (PayloadAmmoTurret.java:60). Its build() walks
        # content.blocks() then content.units(), calling
        # displayContent() for each; displayContent() adds
        # a ReqImage only when `filter.get(content) &&
        # content.unlockedNow()`, with the per-entry
        # visibility `build instanceof PayloadTurretBuild
        # it && !it.payloads.isEmpty() &&
        # it.currentAmmo() == content`; efficiency() is
        # `build instanceof PayloadTurretBuild it &&
        # it.payloads.any() ? 1f : 0f`. content.blocks/units
        # arrive as explicit Array params,
        # filter/unlockedNow/uiIcon as explicit Callables
        # (the N2330 param precedent); Table /
        # MultiReqImage / ReqImage / Stats are NOT ported.
        # payloads.any() and !payloads.isEmpty() are the
        # same fact (PayloadSeq.java:14-20, any() is
        # total > 0, isEmpty() is total == 0), so one
        # payloads_any bool param stands for both.
        # currentAmmo() (N2358) arrives as the explicit
        # current_ammo param, NOT re-ported. display()
        # is a no-op comment (`//don't display`) and owns
        # no expr. NO driver line: init() registers the
        # consumer once, it is not a per-tick write.
        self.assertIn('static func source_payload_ammo_turret_init_state(content_blocks: Array, content_units: Array, filter: Callable, unlocked_now: Callable, ui_icon: Callable, is_payload_turret_build: bool, payloads_any: bool, current_ammo: Variant) -> Dictionary:', bridge)
        # Efficiency is 1.0 exactly for a PayloadTurretBuild
        # with any payload, else 0.0.
        self.assertIn('var efficiency: float = 1.0 if is_payload_turret_build and payloads_any else 0.0', bridge)
        self.assertIn('return {"display_contents": display_contents, "efficiency": efficiency}', bridge)
        for expr in [
            'consume(new ConsumePayloadFilter(i -> ammoTypes.containsKey(i)){',
            'for(var block : content.blocks()) displayContent(build, image, block);',
            'for(var unit : content.units()) displayContent(build, image, unit);',
            'if(filter.get(content) && content.unlockedNow()){',
            'return build instanceof PayloadTurretBuild it && it.payloads.any() ? 1f : 0f;',
            'image.add(new ReqImage(new Image(content.uiIcon), () -> build instanceof PayloadTurretBuild it && !it.payloads.isEmpty() && it.currentAmmo() == content));',
            'void displayContent(Building build, MultiReqImage image, UnlockableContent content){',
            'public class PayloadAmmoTurret extends Turret{',
            'public class PayloadTurretBuild extends TurretBuild{',
            'public PayloadSeq payloads = new PayloadSeq();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure init function
        # (displayed list in blocks-then-units order,
        # filter/unlocked gates, per-entry visibility,
        # efficiency 1f/0f). There are no driver-tick keys:
        # init() registers the consumer once.
        proof = PAYLOAD_AMMO_TURRET_INIT_PROOF.read_text(encoding='utf-8')
        for key in [
            'init_display_blocks_shown',
            'init_display_units_shown',
            'init_display_blocks_before_units',
            'init_display_filter_rejects',
            'init_display_locked_excluded',
            'init_display_empty',
            'init_display_visible_current_ammo',
            'init_display_hidden_other_ammo',
            'init_display_hidden_no_payloads',
            'init_efficiency_one_with_ammo',
            'init_efficiency_zero_empty_payloads',
            'init_efficiency_zero_not_payload_build',
            'init_display_input_unmutated',
            'init_returns_only_two_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_payload_ammo_turret_init(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadAmmoTurretInitProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_AMMO_TURRET_INIT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'init_display_blocks_shown',
            'init_display_units_shown',
            'init_display_blocks_before_units',
            'init_display_filter_rejects',
            'init_display_locked_excluded',
            'init_display_empty',
            'init_display_visible_current_ammo',
            'init_display_hidden_other_ammo',
            'init_display_hidden_no_payloads',
            'init_efficiency_one_with_ammo',
            'init_efficiency_zero_empty_payloads',
            'init_efficiency_zero_not_payload_build',
            'init_display_input_unmutated',
            'init_returns_only_two_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
