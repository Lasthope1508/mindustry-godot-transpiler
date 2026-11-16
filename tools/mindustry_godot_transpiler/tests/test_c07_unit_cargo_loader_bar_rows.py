import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_CARGO_LOADER_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitCargoLoaderBuildState.gd'
UNIT_CARGO_LOADER_BAR_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderBarRowsProof.gd'
UNIT_CARGO_LOADER_BAR_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderBarRowsProof.tscn'


class C07UnitCargoLoaderBarRowsTests(unittest.TestCase):
    def test_c07_unit_cargo_loader_bar_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2417']['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_bar_rows_state')
        # The UnitCargoLoader tick is live (N2234 advance +
        # N2249 liquid row + N2322 canCreate + N2330
        # canPlaceOn + N2415 draw rows) but NOTHING modeled
        # setBars(): the "units" bar (UnitCargoLoader.java:
        # 48-63) -- the bar.unitcap label (the unicode icon
        # of unitType.name + the live countType + the cap
        # string or "∞"), the Pal.power color, and the
        # count/cap fraction (1f when the type ignores the
        # unit cap). N2417 ports setBars() as ONE pure-only
        # bar pure, the N2415 draw pattern: the bar is
        # presentation, never called by the tick, so the
        # pure takes caller-supplied inputs (unit type name
        # / the Fonts unicode icon / countType / useUnitCap
        # / cap) and returns the bar as data. Three new
        # result symbols: the label parts, the color, the
        # fraction.
        self.assertEqual(
            ledger['N2417']['source_symbols'],
            [
                'source_unit_cargo_loader_bar_rows_state_result.bar_label',
                'source_unit_cargo_loader_bar_rows_state_result.bar_color',
                'source_unit_cargo_loader_bar_rows_state_result.bar_fraction',
            ],
        )
        for name in ledger['N2417']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/UnitCargoLoader.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_'))
        self.assertEqual(ledger['N2417']['runtime_proof'], '/root/C07UnitCargoLoaderBarRowsProof')
        self.assertEqual(
            ledger['N2417']['tests'],
            [
                'test_c07_unit_cargo_loader_bar_rows_registration',
                'test_all_c07_unit_cargo_loader_bar_rows_input_evidence_is_exact',
                'test_unit_cargo_loader_bar_rows_state',
                'test_reference_graph_and_actual_c07_unit_cargo_loader_bar_rows',
            ],
        )
        self.assertTrue(ledger['N2417']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #2 (1-based in
        # DEFERRED-after-advances-24.py): the
        # UnitCargoLoader bar rows entry is REMOVED --
        # setBars() is live now, so nothing of the entry
        # remains. Net 286 - 1 = 285.
        self.assertFalse(any(entry.startswith('UnitCargoLoader bar rows (setBars units bar, UnitCargoLoader.java:48-63)') for entry in ledger['N2417']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader read/write rows (readUnitId, write unit id, UnitCargoLoader.java:174-188)') for entry in ledger['N2417']['deferred_exprs']))
        self.assertEqual(len(ledger['N2417']['deferred_exprs']), 285)

    def test_all_c07_unit_cargo_loader_bar_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2417']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/units/UnitCargoLoader.java',
            'core/src/mindustry/entities/Units.java',
            'core/src/mindustry/ui/Fonts.java',
            'core/assets/bundles/bundle.properties',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2417']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_cargo_loader_bar_rows_state(self):
        unit_cargo_loader = UNIT_CARGO_LOADER_STATE.read_text(encoding='utf-8')
        # The bar rows (UnitCargoLoader.setBars(),
        # UnitCargoLoader.java:48-63): `super.setBars();`
        # first, then `addBar("units", ...)` with the
        # bar.unitcap label (`Core.bundle.format(
        # "bar.unitcap", Fonts.getUnicodeStr(unitType.name),
        # e.team.data().countType(unitType),
        # unitType.useUnitCap ? Units.getStringCap(e.team)
        # : "∞")`, formatted by `bar.unitcap = {0} {1}/{2}`
        # in bundle.properties), the Pal.power color
        # (`() -> Pal.power,`), and the fraction
        # (`() -> unitType.useUnitCap ? (float)e.team.data()
        # .countType(unitType) / Units.getCap(e.team) : 1f`).
        # getStringCap (Units.java:128-132) substitutes "∞"
        # when the cap is Integer.MAX_VALUE - 1 or more
        # (`return cap >= Integer.MAX_VALUE - 1 ? "∞" :
        # cap + "";`), and getCap (Units.java:119-126) clamps
        # at 0 (`return Math.max(0, ...);`) -- so cap 0 is
        # reachable in Java (unitCap 0) and Java divides
        # anyway: the float division is UNGUARDED (count 0 /
        # cap 0 is NaN, count > 0 / cap 0 is Infinity), and
        # the pure matches it with no guard. The unicode
        # icon is the Fonts lookup (`return stringIcons.get(
        # content, "");`, Fonts.java:43-45) over the runtime
        # font atlas, so it arrives caller-supplied like the
        # live countType / cap. Pure-only: the tick never
        # calls setBars (the bar is presentation, read by
        # the UI).
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_unit_cargo_loader_bar_rows_state', unit_cargo_loader)
        self.assertIn('public void setBars(){', unit_cargo_loader)
        self.assertIn('super.setBars();', unit_cargo_loader)
        self.assertIn('addBar("units", (UnitTransportSourceBuild e) ->', unit_cargo_loader)
        self.assertIn('Core.bundle.format("bar.unitcap",', unit_cargo_loader)
        self.assertIn('Fonts.getUnicodeStr(unitType.name),', unit_cargo_loader)
        self.assertIn('e.team.data().countType(unitType),', unit_cargo_loader)
        self.assertIn('unitType.useUnitCap ? Units.getStringCap(e.team) : "∞"', unit_cargo_loader)
        self.assertIn('() -> Pal.power,', unit_cargo_loader)
        self.assertIn('() -> unitType.useUnitCap ? (float)e.team.data().countType(unitType) / Units.getCap(e.team) : 1f', unit_cargo_loader)
        self.assertIn('public UnitType unitType = UnitTypes.manifold;', unit_cargo_loader)
        self.assertIn('public static int getCap(Team team){', unit_cargo_loader)
        self.assertIn('return Math.max(0, state.rules.unitCapVariable ? state.rules.unitCap + team.data().unitCap : state.rules.unitCap);', unit_cargo_loader)
        self.assertIn('public static String getStringCap(Team team){', unit_cargo_loader)
        self.assertIn('int cap = getCap(team);', unit_cargo_loader)
        self.assertIn('return cap >= Integer.MAX_VALUE - 1 ? "∞" : cap + "";', unit_cargo_loader)
        self.assertIn('public static String getUnicodeStr(String content){', unit_cargo_loader)
        self.assertIn('return stringIcons.get(content, "");', unit_cargo_loader)
        self.assertIn('bar.unitcap = {0} {1}/{2}', unit_cargo_loader)
        self.assertIn('power = Color.valueOf("fbad67"),', unit_cargo_loader)
        self.assertIn('return typeCounts == null || typeCounts.length <= type.id ? 0 : typeCounts[type.id];', unit_cargo_loader)
        # The documented limits record the bar rows as
        # live (the old "Bar / read-write rows still defer"
        # text is gone -- read/write still defer, bar does
        # not).
        self.assertIn('Bar rows live (N2417)', unit_cargo_loader)
        self.assertNotIn('Bar / read-write rows still defer', unit_cargo_loader)
        # The proof's keys drive the bar pure (the label
        # parts, the capped-cap "∞" branch, the no-cap
        # branch with fraction 1f, the Pal.power color, the
        # fraction math, and the unguarded cap-0 edge).
        proof = UNIT_CARGO_LOADER_BAR_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'bar_label_parts',
            'bar_cap_branch',
            'bar_no_cap_branch',
            'bar_color',
            'bar_fraction_math',
            'bar_zero_cap_edge',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceUnitCargoLoaderBuildState.gd")', proof)
        self.assertTrue(UNIT_CARGO_LOADER_STATE.exists())
        self.assertTrue(UNIT_CARGO_LOADER_BAR_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07UnitCargoLoaderBarRowsProof.gd', UNIT_CARGO_LOADER_BAR_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_unit_cargo_loader_bar_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitCargoLoaderBarRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_CARGO_LOADER_BAR_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'bar_label_parts',
            'bar_cap_branch',
            'bar_no_cap_branch',
            'bar_color',
            'bar_fraction_math',
            'bar_zero_cap_edge',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
