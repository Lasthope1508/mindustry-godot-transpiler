import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_TURRET_BUILD = ROOT / 'godot-mindustry/src/game/SourceItemTurretBuildPortBridge.gd'
AMMO_FILTER_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemTurretInitAmmoFilterProof.gd'


class C07ItemTurretInitAmmoFilterTests(unittest.TestCase):
    def test_c07_item_turret_init_ammo_filter_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2431']['godot_owner'], 'PortGame.source_item_turret_init_ammo_filter_state')
        # Anonymous ConsumeItemFilter.build(Building
        # build, Table table) inside ItemTurret.init()
        # (ItemTurret.java:70-80): the ammo-filter UI
        # statement :76-78, one statement in joined
        # form, registered as its 3 verbatim lines
        # (joined single-line form is NOT verbatim in
        # the Java file -- N2428 opener precedent). The
        # 3 lines are 0-hit in both ledgers (re-probed
        # at base d73ffef3, remote origin/main 308b9f00).
        # N1463 owns the BASE ConsumeItemFilter.build()
        # each() call (`content.items().each(i ->
        # filter.get(i) && i.unlockedNow() &&
        # !i.hidden, item -> image.add(new ReqImage(
        # StatValues.stack(item, 1), ...` + `() ->
        # build.items.has(item))));`) -- a different
        # statement (hidden filter + StatValues.stack +
        # items.has), NOT this ItemTurret override
        # (uiIcon image + ItemTurretBuild peek check).
        # N2396 owns the PayloadAmmoTurret PAT twin
        # (`image.add(new ReqImage(new Image(
        # content.uiIcon), () -> build instanceof
        # PayloadTurretBuild it && ...`)) -- a different
        # expr. N1463 + N1504 own the neighbouring
        # `:74 MultiReqImage` + `:79 table.add` lines --
        # neither is re-registered here. One GD function
        # on SourceItemTurretBuildPortBridge.gd (the
        # ItemTurret file, NOT a new file -- N2416 ctor
        # precedent). The owner is PortGame.* (this file
        # is a PortBridge -- N2358/N2384/N2396/N2419
        # precedent), NOT the file class name. The
        # result is frame data only (one req_images
        # Array); no Draw is ported.
        self.assertEqual(
            ledger['N2431']['java_method'],
            'ItemTurret.init() ConsumeItemFilter.build(Building build, Table table)',
        )
        self.assertEqual(
            ledger['N2431']['source_symbols'],
            [
                'source_item_turret_init_ammo_filter_state_result.req_images',
            ],
        )
        for name in ledger['N2431']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('PortGame.source_item_turret_init_ammo_filter_state'))
        self.assertEqual(ledger['N2431']['runtime_proof'], '/root/C07ItemTurretInitAmmoFilterProof')
        self.assertEqual(
            ledger['N2431']['tests'],
            [
                'test_c07_item_turret_init_ammo_filter_registration',
                'test_all_c07_item_turret_init_ammo_filter_input_evidence_is_exact',
                'test_item_turret_init_ammo_filter_state',
                'test_reference_graph_and_actual_c07_item_turret_init_ammo_filter',
            ],
        )
        self.assertTrue(ledger['N2431']['deferred_exprs'])

    def test_all_c07_item_turret_init_ammo_filter_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2431']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('PortGame.source_item_turret_init_ammo_filter_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2431']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_turret_init_ammo_filter_state(self):
        defaults = ITEM_TURRET_BUILD.read_text(encoding='utf-8')
        # Anonymous ConsumeItemFilter.build(Building
        # build, Table table) inside ItemTurret.init()
        # (ItemTurret.java:70-80): content.items().each
        # keeps only items passing the filter and
        # unlockedNow, adding one ReqImage per kept item
        # whose Boolp is true exactly when the build is
        # an ItemTurretBuild with non-empty ammo and the
        # peeked ItemEntry item is this item.
        self.assertIn('static func source_item_turret_init_ammo_filter_state(items: Array, is_item_turret_build: bool, ammo_empty: bool, peek_item: Variant) -> Dictionary:', defaults)
        for expr in [
            'content.items().each(i -> filter.get(i) && i.unlockedNow(),',
            'item -> image.add(new ReqImage(new Image(item.uiIcon),',
            '() -> build instanceof ItemTurretBuild it && !it.ammo.isEmpty() && ((ItemEntry)it.ammo.peek()).item == item)));',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, defaults)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick, no render):
        # keeps an unlocked filtered item with a true
        # Boolp, drops a locked item, drops an
        # unfiltered item, Boolp false when not an
        # ItemTurretBuild / when ammo is empty / when
        # the peeked item differs, and the result
        # carries only the req_images key.
        proof = AMMO_FILTER_PROOF.read_text(encoding='utf-8')
        for key in [
            'ammo_filter_includes_unlocked_filtered_item',
            'ammo_filter_excludes_locked_item',
            'ammo_filter_excludes_unfiltered_item',
            'ammo_filter_invalid_when_not_item_turret_build',
            'ammo_filter_invalid_when_ammo_empty',
            'ammo_filter_invalid_when_peek_differs',
            'ammo_filter_returns_only_req_images_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_item_turret_init_ammo_filter(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemTurretInitAmmoFilterProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_TURRET_INIT_AMMO_FILTER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ammo_filter_includes_unlocked_filtered_item',
            'ammo_filter_excludes_locked_item',
            'ammo_filter_excludes_unfiltered_item',
            'ammo_filter_invalid_when_not_item_turret_build',
            'ammo_filter_invalid_when_ammo_empty',
            'ammo_filter_invalid_when_peek_differs',
            'ammo_filter_returns_only_req_images_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
