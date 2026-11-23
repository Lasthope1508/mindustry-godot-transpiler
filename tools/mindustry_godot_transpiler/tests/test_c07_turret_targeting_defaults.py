import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TARGETING_DEFAULTS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretTargetingDefaultsProof.gd'

EXACT_EXPRS = [
    'public float targetInterval = 20;',
    'public float newTargetInterval = -1f;',
    'public boolean reloadWhileCharging = true;',
    'public boolean targetAir = true;',
    'public boolean targetGround = true;',
    'public boolean targetBlocks = true;',
    'public boolean displayAmmoMultiplier = true;',
    'public boolean targetUnderBlocks = true;',
    'public Boolf<Unit> unitFilter = u -> true;',
    'public Boolf<Building> buildingFilter = b -> targetUnderBlocks || !b.block.underBullets;',
]

RESULT_KEYS = [
    'target_interval',
    'new_target_interval',
    'reload_while_charging',
    'target_air',
    'target_ground',
    'target_blocks',
    'display_ammo_multiplier',
    'target_under_blocks',
    'unit_filter',
    'building_filter',
]

PROOF_KEYS = [
    'targeting_defaults_target_interval',
    'targeting_defaults_new_target_interval',
    'targeting_defaults_reload_while_charging',
    'targeting_defaults_target_air',
    'targeting_defaults_target_ground',
    'targeting_defaults_target_blocks',
    'targeting_defaults_display_ammo_multiplier',
    'targeting_defaults_target_under_blocks',
    'targeting_defaults_unit_filter_always_true',
    'targeting_defaults_building_filter_open_under_blocks',
    'targeting_defaults_building_filter_closed_blocked',
    'targeting_defaults_building_filter_open_not_under_bullets',
]


class C07TurretTargetingDefaultsTests(unittest.TestCase):
    def test_c07_turret_targeting_defaults_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2445']['godot_owner'], 'SourceTurretBuildState.source_turret_targeting_defaults_state')
        # Turret field decls (Turret.java:42, :44, :82, :89, :91,
        # :93, :99, :101, :109, :111) -- the targeting/shoot
        # defaults group. Field-decl-only slice, main-thread
        # decision with N2440 (BeamDrill): decls belong to no
        # method, so no method slice can absorb them. All 10
        # exprs were 0-hit in BOTH ledgers (re-probed at base
        # 8a0c6e4d). The other Turret field decls (:46-:108
        # except these 10 -- maxAmmo, ammoPerShot, inaccuracy,
        # shootCone, moveWhileCharging, targetHealing,
        # playerControllable, alwaysShooting, predictTarget,
        # unitSort, heatColor, ...) are NOT registered here --
        # later slices. The :111 buildingFilter references
        # :101 targetUnderBlocks, so the group stays together
        # in one slot instead of splitting the filters off.
        self.assertEqual(
            ledger['N2445']['java_method'],
            'Turret field declarations',
        )
        self.assertEqual(
            ledger['N2445']['exact_exprs'],
            EXACT_EXPRS,
        )
        self.assertEqual(
            ledger['N2445']['source_symbols'],
            ['source_turret_targeting_defaults_state_result.' + key for key in RESULT_KEYS],
        )
        for name in ledger['N2445']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_turret_targeting_defaults_state'))
        self.assertEqual(ledger['N2445']['runtime_proof'], '/root/C07TurretTargetingDefaultsProof')
        self.assertEqual(
            ledger['N2445']['tests'],
            [
                'test_c07_turret_targeting_defaults_registration',
                'test_all_c07_turret_targeting_defaults_input_evidence_is_exact',
                'test_turret_targeting_defaults_state',
                'test_reference_graph_and_actual_c07_turret_targeting_defaults',
            ],
        )
        self.assertTrue(ledger['N2445']['deferred_exprs'])

    def test_all_c07_turret_targeting_defaults_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2445']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_turret_targeting_defaults_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2445']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_targeting_defaults_state(self):
        state = TURRET_STATE.read_text(encoding='utf-8')
        # The GD function is new (N2445): one Dictionary with
        # the 10 defaults. The two Boolf lambdas are NOT
        # ported as lambdas -- GDScript has no Java Boolf;
        # unitFilter (`u -> true`) is data (always true) and
        # buildingFilter is computed from the two inputs
        # (`target_under_blocks || !under_bullets`). Each exact
        # Java expr is quoted verbatim on its own comment line
        # (the N2378 precedent: never split an exact expr
        # across lines).
        self.assertIn('static func source_turret_targeting_defaults_state(target_under_blocks: bool = true, under_bullets: bool = false) -> Dictionary:', state)
        for expr in EXACT_EXPRS:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        for key in RESULT_KEYS:
            with self.subTest(key=key):
                self.assertIn('"%s":' % key, state)
        self.assertIn('PORT_GAME_SOURCE_TURRET_TARGETING_DEFAULTS_STATE', state)
        # The proof's keys pin every default: the two
        # intervals, the five targeting flags, the ammo
        # multiplier display flag, the under-blocks flag,
        # the always-true unit filter, and the three
        # building-filter cases (open under blocks, closed
        # when blocked, open when not under bullets).
        proof = TARGETING_DEFAULTS_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_targeting_defaults(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretTargetingDefaultsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_TARGETING_DEFAULTS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
