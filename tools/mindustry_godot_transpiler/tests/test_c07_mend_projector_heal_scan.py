import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MEND_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceMendProjectorBuildState.gd'
MEND_PROJECTOR_HEAL_SCAN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorHealScanProof.gd'
MEND_PROJECTOR_HEAL_SCAN_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorHealScanProof.tscn'


class C07MendProjectorHealScanTests(unittest.TestCase):
    def test_c07_mend_projector_heal_scan_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2242']['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_heal_scan_state')
        # N2193 advanced smoothEfficiency / heat / charge /
        # phaseHeat and reset the charge inside the
        # `charge >= reload` branch, which sits BEFORE the
        # indexer scan -- but the scan itself (the realRange
        # fold, the damaged + not-heal-suppressed predicate,
        # the heal formula, the `any` flag, the mendSound)
        # waited for its own slice: the port has no indexer
        # and no live building query, so the scan takes its
        # candidate list explicit. N2242 is that scan: a pure
        # function over the post-advance frame (phase_heat,
        # efficiency, heat) + the charge captured BEFORE the
        # advance (the N2193 advance already reset the frame
        # charge to 0 on crossing, so the scan recomputes the
        # crossing from charge_before + heat_after * delta *
        # timeScale) + per-def params (range / healPercent /
        # phaseBoost / phaseRangeBoost -- the defs override
        # the class defaults: mender 40f / 4f / 4f / 20f,
        # mend-projector 85f / 11f / 15f / class 50f). Fx /
        # sound / recentlyHealed and the live indexer range
        # query stay deferred. Four new result symbols: the
        # scan result the driver records on the frame as
        # last_heal_scan.
        self.assertEqual(
            ledger['N2242']['source_symbols'],
            [
                'source_mend_projector_heal_scan_result.real_range',
                'source_mend_projector_heal_scan_result.heal_amounts',
                'source_mend_projector_heal_scan_result.any',
                'source_mend_projector_heal_scan_result.scanned',
            ],
        )
        for name in ledger['N2242']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/MendProjector.java')
                self.assertEqual(symbol['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_heal_scan_state')
        self.assertEqual(ledger['N2242']['runtime_proof'], '/root/C07MendProjectorHealScanProof')
        self.assertEqual(
            ledger['N2242']['tests'],
            [
                'test_c07_mend_projector_heal_scan_registration',
                'test_all_c07_mend_projector_heal_scan_input_evidence_is_exact',
                'test_mend_projector_heal_scan_state',
                'test_reference_graph_and_actual_c07_mend_projector_heal_scan',
            ],
        )
        self.assertTrue(ledger['N2242']['deferred_exprs'])

    def test_all_c07_mend_projector_heal_scan_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2242']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_heal_scan_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/MendProjector.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/comp/HealthComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2242']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mend_projector_heal_scan_state(self):
        mend_projector = MEND_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure heal scan lives on the mend-projector build
        # state: the realRange fold, the damaged + not
        # heal-suppressed predicate, the heal formula, the
        # `any` flag and the branch-taken flag, over the exact
        # Java lines (MendProjector.java:106-122) -- keep each
        # exact expr on ONE comment line, the N2148 lesson: a
        # split line fails this test.
        self.assertIn('static func source_mend_projector_heal_scan_state', mend_projector)
        self.assertIn('if(charge >= reload && canHeal){', mend_projector)
        self.assertIn('float realRange = range + phaseHeat * phaseRangeBoost;', mend_projector)
        self.assertIn('indexer.eachBlock(this, realRange, b -> b.damaged() && !b.isHealSuppressed(), other -> {', mend_projector)
        self.assertIn('other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);', mend_projector)
        self.assertIn('private boolean any = false;', mend_projector)
        # The predicate's two halves come from the component
        # sources, not from a guess: damaged() is health below
        # maxHealth (HealthComp.java:47-49) and
        # isHealSuppressed() is the suppressable + suppression
        # window check (BuildingComp.java:487-489); the port
        # takes both as explicit per-candidate booleans.
        self.assertIn('return health < maxHealth - 0.001f;', mend_projector)
        self.assertIn('return block.suppressable && Time.time <= healSuppressionTime;', mend_projector)
        # The deferred lines stay visible as deferrals, not
        # implementations: recentlyHealed() writes a timestamp
        # on the healed building object, Fx.healBlockFull is
        # presentation, and mendSound plays only when `any`
        # holds -- the pure scan returns the amounts and the
        # flag and lets the caller apply them.
        self.assertIn('other.recentlyHealed();', mend_projector)
        self.assertIn('Fx.healBlockFull.at(other.x, other.y, other.block.size, baseColor, other.block);', mend_projector)
        self.assertIn('mendSound.at(this, 1f + Mathf.range(0.1f), mendSoundVolume);', mend_projector)
        # The crossing recompute cites the charge advance: the
        # N2193 advance already reset the frame charge, so the
        # scan recomputes charge_before + heat_after * delta *
        # timeScale against the per-def reload.
        self.assertIn('charge += heat * delta();', mend_projector)
        # The tick driver wires the scan after the N2193
        # advance for every ticked mend projector: it captures
        # charge_before BEFORE the advance, then runs the pure
        # scan with the per-def params from the block
        # properties (class defaults where a def does not
        # override: range 60f, healPercent 12f, phaseBoost 12f,
        # phaseRangeBoost 50f, MendProjector.java:27-30) and
        # records the result on the frame as last_heal_scan.
        # The live tick passes no candidates: the port has no
        # indexer, so the range query stays deferred.
        self.assertIn('source_mend_projector_heal_scan_state(frame', mend_projector)
        self.assertIn('charge_before', mend_projector)
        self.assertIn('last_heal_scan', mend_projector)
        self.assertIn('block.properties.get("range"', mend_projector)
        self.assertIn('block.properties.get("healPercent"', mend_projector)
        # The proof's keys drive the pure scan (realRange
        # fold, heal formula, damaged-only predicate,
        # heal-suppressed exclusion, no scan below reload)
        # plus the live tick (a charged mender runs the scan
        # branch -- the key is named for the scan, not a heal:
        # the live tick has no indexer candidates, so no
        # building heals live; the pure keys prove the heals).
        proof = MEND_PROJECTOR_HEAL_SCAN_PROOF.read_text(encoding='utf-8')
        for key in [
            'real_range_folds_phase_heat',
            'heal_amount_formula',
            'damaged_only_predicate',
            'heal_suppressed_excluded',
            'no_scan_below_reload',
            'live_tick_scans_when_charged',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Every preload in the proof points at a file that
        # exists (the N2185 lesson: a proof scene that cannot
        # load fails for the wrong reason on Windows).
        for preload in re.findall(r'preload\("res://([^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload).is_file(), preload)
        scene = MEND_PROJECTOR_HEAL_SCAN_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07MendProjectorHealScanProof.gd', scene)
        self.assertIn('[node name="C07MendProjectorHealScanProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_mend_projector_heal_scan(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MendProjectorHealScanProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MEND_PROJECTOR_HEAL_SCAN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'real_range_folds_phase_heat',
            'heal_amount_formula',
            'damaged_only_predicate',
            'heal_suppressed_excluded',
            'no_scan_below_reload',
            'live_tick_scans_when_charged',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
