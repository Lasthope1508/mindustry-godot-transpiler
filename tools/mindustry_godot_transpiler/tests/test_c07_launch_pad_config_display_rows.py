import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LAUNCH_PAD_STATE = ROOT / 'godot-mindustry/src/game/SourceLaunchPadBuildState.gd'
LAUNCH_PAD_CONFIG_DISPLAY_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadConfigDisplayRowsProof.gd'
LAUNCH_PAD_CONFIG_DISPLAY_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadConfigDisplayRowsProof.tscn'
DISPLAY_OWNER = 'SourceLaunchPadBuildState.source_launch_pad_display_state'
CONFIG_OWNER = 'SourceLaunchPadBuildState.source_launch_pad_config_state'
LAUNCH_PAD_JAVA = 'core/src/mindustry/world/blocks/campaign/LaunchPad.java'


class C07LaunchPadConfigDisplayRowsTests(unittest.TestCase):
    def test_c07_launch_pad_config_display_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2466']['godot_owner'], DISPLAY_OWNER)
        # display() (LaunchPad.java:164-177) renders the
        # destination label only in campaign, not a net
        # client, and the pad's team is the player's
        # team (:167); shouldShowConfigure (:180-182)
        # is campaign only; buildConfiguration
        # (:185-203) deselects on the gate fail (:187)
        # and otherwise offers the upOpen / cleari
        # button (size 40f) that opens the planet
        # sector picker. N2466 ports all three as TWO
        # pure-only pures (no tick wiring): the display
        # pure returns destination_label {key
        # "launch.destination", value the
        # "sectors.nonelaunch" bundle token or
        # "[accent]" + name} (null unless the gate
        # passes), and the config pure folds
        # shouldShowConfigure into show_configure plus
        # the button CALL record, the gate-fail
        # deselect flag, the post-select destination
        # and the refreshImportRates flag. Six new
        # result symbols, in Java order: the display
        # label, then show_configure, button_call,
        # deselect_called, destination_after and
        # refresh_import_rates_called. The
        # super.display call is recorded, not a symbol
        # (the N2374/N2396 precedent); the UI itself
        # is NOT ported (the N2443 picker precedent);
        # the pad(4)/wrap/width(200f)/left() layout is
        # UI chrome, not modeled.
        self.assertEqual(
            ledger['N2466']['source_symbols'],
            [
                'source_launch_pad_display_state_result.destination_label',
                'source_launch_pad_config_state_result.show_configure',
                'source_launch_pad_config_state_result.button_call',
                'source_launch_pad_config_state_result.deselect_called',
                'source_launch_pad_config_state_result.destination_after',
                'source_launch_pad_config_state_result.refresh_import_rates_called',
            ],
        )
        owners = {
            'source_launch_pad_display_state_result.destination_label': DISPLAY_OWNER,
            'source_launch_pad_config_state_result.show_configure': CONFIG_OWNER,
            'source_launch_pad_config_state_result.button_call': CONFIG_OWNER,
            'source_launch_pad_config_state_result.deselect_called': CONFIG_OWNER,
            'source_launch_pad_config_state_result.destination_after': CONFIG_OWNER,
            'source_launch_pad_config_state_result.refresh_import_rates_called': CONFIG_OWNER,
        }
        for name in ledger['N2466']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], LAUNCH_PAD_JAVA)
                self.assertEqual(symbol['godot_owner'], owners[name])
        self.assertEqual(ledger['N2466']['runtime_proof'], '/root/C07LaunchPadConfigDisplayRowsProof')
        self.assertEqual(
            ledger['N2466']['tests'],
            [
                'test_c07_launch_pad_config_display_rows_registration',
                'test_all_c07_launch_pad_config_display_rows_input_evidence_is_exact',
                'test_launch_pad_config_display_rows_state',
                'test_reference_graph_and_actual_c07_launch_pad_config_display_rows',
            ],
        )
        self.assertTrue(ledger['N2466']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #34 (1-based in
        # DEFERRED-after-advances-30.py): the LaunchPad
        # config / display / shouldShowConfigure entry
        # is REMOVED -- display(), shouldShowConfigure()
        # and buildConfiguration() are live now as pure
        # rows, so nothing of the entry remains. Net
        # 246 - 1 = 245. No new entry is added: the
        # pures are pure-only (the UI call sites wait
        # for UI slices, not a LaunchPad deferral).
        self.assertFalse(any(entry.startswith('LaunchPad config / display / shouldShowConfigure rows (') for entry in ledger['N2466']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LaunchPad acceptItem driver wiring (') for entry in ledger['N2466']['deferred_exprs']))
        self.assertEqual(len(ledger['N2466']['deferred_exprs']), 245)

    def test_all_c07_launch_pad_config_display_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        owners = {
            'source_launch_pad_display_state_result.destination_label': DISPLAY_OWNER,
            'source_launch_pad_config_state_result.show_configure': CONFIG_OWNER,
            'source_launch_pad_config_state_result.button_call': CONFIG_OWNER,
            'source_launch_pad_config_state_result.deselect_called': CONFIG_OWNER,
            'source_launch_pad_config_state_result.destination_after': CONFIG_OWNER,
            'source_launch_pad_config_state_result.refresh_import_rates_called': CONFIG_OWNER,
        }
        for name in ledger['N2466']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], owners[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
            'core/assets/bundles/bundle.properties',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2466']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_launch_pad_config_display_rows_state(self):
        launch_pad = LAUNCH_PAD_STATE.read_text(encoding='utf-8')
        # The config / display rows (LaunchPadBuild.
        # display(), LaunchPad.java:164-177;
        # shouldShowConfigure(), :180-182;
        # buildConfiguration(), :185-203), two
        # pure-only pures, no tick wiring. display()
        # is `super.display(table);` then the gate
        # `if(!state.isCampaign() || net.client() ||
        # team != player.team()) return;` -- the label
        # row renders only in campaign, not a net
        # client, and the pad's team is the player's
        # team. The destination is `Sector dest =
        # state.rules.sector == null ? null :
        # state.rules.sector.info.destination;` and
        # the label is `return Core.bundle.format(
        # "launch.destination",` with `dest == null ||
        # !dest.hasBase() ? Core.bundle.get(
        # "sectors.nonelaunch") :` else `"[accent]" +
        # dest.name());`. The label is a Dict {key,
        # value} because Java calls Core.bundle.format
        # with an argument (the N2450 precedent -- the
        # UI composes the rendered string); the
        # "sectors.nonelaunch" value is the BUNDLE
        # TOKEN (`sectors.nonelaunch = [lightgray]none
        # (sun)`, bundle.properties:921), not the
        # localized text, and the key is
        # "launch.destination" (`launch.destination =
        # Destination: {0}`, bundle.properties:875).
        # The destination is caller-supplied (the
        # sector state is not in the driver, the N2435
        # precedent): null or a Dict {name, has_base}
        # (the destination field is `public @Nullable
        # Sector destination;`, SectorInfo.java:51-52;
        # hasBase() is Sector.java:135). The
        # super.display call is recorded, not a symbol
        # (the N2374/N2396 precedent); the pad(4)/
        # wrap/width(200f)/left() layout is UI chrome
        # -- not modeled. shouldShowConfigure is
        # `return state.isCampaign();` (campaign only,
        # folded into the config pure as
        # show_configure). buildConfiguration is
        # `if(!state.isCampaign() || net.client()){`
        # with the early-return `deselect();`, else
        # `table.button(Icon.upOpen, Styles.cleari,
        # () -> {` (Icon.upOpen is LaunchPad.java:191,
        # used across the UI; Styles.cleari is
        # Styles.java:89/337) opening `ui.planet.
        # showSelect(state.rules.sector, other -> {`
        # (PlanetDialog.java:376); the callback is
        # `if(state.isCampaign() && other.planet ==
        # state.rules.sector.planet){` then `var prev =
        # state.rules.sector.info.destination;` +
        # `state.rules.sector.info.destination =
        # other;` + `if(prev != null){` +
        # `prev.info.refreshImportRates(state.
        # getPlanet());`, and the button is
        # `}).size(40f);`. The button is a CALL record
        # (the N2443 picker precedent -- the UI is NOT
        # ported); the click-time deselect (:201) is
        # part of the button_call record, not a
        # separate key. The callback re-check reuses
        # the one is_campaign input (one evaluation
        # moment; a click-time campaign change is a
        # UI-timing concern). The refresh fires when
        # prev != null AND the callback applied --
        # Java's only condition inside the callback is
        # `if(prev != null){`, so a same-sector
        # re-selection still refreshes (the assignment
        # runs, prev != null). Keep each Java expr on
        # ONE comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_launch_pad_display_state', launch_pad)
        self.assertIn('static func source_launch_pad_config_state', launch_pad)
        self.assertIn('super.display(table);', launch_pad)
        self.assertIn('if(!state.isCampaign() || net.client() || team != player.team()) return;', launch_pad)
        self.assertIn('Sector dest = state.rules.sector == null ? null : state.rules.sector.info.destination;', launch_pad)
        self.assertIn('return Core.bundle.format("launch.destination",', launch_pad)
        self.assertIn('dest == null || !dest.hasBase() ? Core.bundle.get("sectors.nonelaunch") :', launch_pad)
        self.assertIn('"[accent]" + dest.name());', launch_pad)
        self.assertIn('return state.isCampaign();', launch_pad)
        self.assertIn('if(!state.isCampaign() || net.client()){', launch_pad)
        self.assertIn('deselect();', launch_pad)
        self.assertIn('table.button(Icon.upOpen, Styles.cleari, () -> {', launch_pad)
        self.assertIn('ui.planet.showSelect(state.rules.sector, other -> {', launch_pad)
        self.assertIn('if(state.isCampaign() && other.planet == state.rules.sector.planet){', launch_pad)
        self.assertIn('var prev = state.rules.sector.info.destination;', launch_pad)
        self.assertIn('state.rules.sector.info.destination = other;', launch_pad)
        self.assertIn('if(prev != null){', launch_pad)
        self.assertIn('prev.info.refreshImportRates(state.getPlanet());', launch_pad)
        self.assertIn('}).size(40f);', launch_pad)
        self.assertIn('public @Nullable Sector destination;', launch_pad)
        self.assertIn('launch.destination = Destination: {0}', launch_pad)
        self.assertIn('sectors.nonelaunch = [lightgray]none (sun)', launch_pad)
        # The documented limits record the config /
        # display rows as live.
        self.assertIn('Config/display rows live (N2466)', launch_pad)
        # The proof's keys drive the two pures (the
        # display label with a destination, the label
        # with no destination / no base, the display
        # gate, the config button record, the select
        # callback incl. the same-sector refresh, and
        # the gate-fail deselect).
        proof = LAUNCH_PAD_CONFIG_DISPLAY_PROOF.read_text(encoding='utf-8')
        for key in [
            'display_label_dest',
            'display_label_none',
            'display_gate',
            'config_button',
            'config_select',
            'config_deselect',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceLaunchPadBuildState.gd")', proof)
        self.assertTrue(LAUNCH_PAD_STATE.exists())
        self.assertTrue(LAUNCH_PAD_CONFIG_DISPLAY_PROOF_SCENE.exists())
        self.assertIn('C07LaunchPadConfigDisplayRowsProof.gd', LAUNCH_PAD_CONFIG_DISPLAY_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_launch_pad_config_display_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaunchPadConfigDisplayRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LAUNCH_PAD_CONFIG_DISPLAY_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'display_label_dest',
            'display_label_none',
            'display_gate',
            'config_button',
            'config_select',
            'config_deselect',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
