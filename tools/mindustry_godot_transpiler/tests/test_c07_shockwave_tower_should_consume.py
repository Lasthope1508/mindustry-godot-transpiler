import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerShouldConsumeProof.gd'
SHOCKWAVE_TOWER_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerShouldConsumeProof.tscn'


class C07ShockwaveTowerShouldConsumeTests(unittest.TestCase):
    def test_c07_shockwave_tower_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2187']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_should_consume_state')
        # N2177 gave the shockwave tower its live power.status
        # read (a pure power row over the stamped frame value,
        # folded by the shared machinery into the min efficiency),
        # but RED-deferred the shouldConsume gate: the port
        # tracked no live reload counter on any placed-building
        # frame, so the machinery ran with should_consume=true
        # when enabled (the MendProjector suppression precedent)
        # -- when fully reloaded power.status reads 1.0 while
        # Java efficiency is 0. N2187 resolves that deferral:
        # ShockwaveTowerBuild overrides shouldConsume
        # (ShockwaveTower.java:121-122, `return reloadCounter <
        # reload;`), and updateConsumption forces efficiency to
        # zero when the gate is false (BuildingComp.java:1960,
        # `boolean update = shouldConsume() &&
        # productionValid();` + 1992-1994, `if(!update){` /
        # efficiency = optionalEfficiency = 0f). The driver now
        # tracks reloadCounter as frame state, advances it each
        # tick by the updateTile charge (ShockwaveTower.java:73,
        # `(reloadCounter += edelta())`, edelta() = efficiency *
        # delta(), BuildingComp.java:1927-1929), and feeds
        # should_consume = enabled && reload_counter < reload to
        # the machinery. Two new result symbols: the gate and
        # the counter it reads.
        self.assertEqual(
            ledger['N2187']['source_symbols'],
            [
                'source_shockwave_tower_should_consume_state_result.should_consume',
                'source_shockwave_tower_should_consume_state_result.reload_counter',
            ],
        )
        for name in ledger['N2187']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/ShockwaveTower.java')
                self.assertEqual(symbol['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_should_consume_state')
        self.assertEqual(ledger['N2187']['runtime_proof'], '/root/C07ShockwaveTowerShouldConsumeProof')
        self.assertEqual(
            ledger['N2187']['tests'],
            [
                'test_c07_shockwave_tower_should_consume_registration',
                'test_all_c07_shockwave_tower_should_consume_input_evidence_is_exact',
                'test_shockwave_tower_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_should_consume',
            ],
        )
        self.assertTrue(ledger['N2187']['deferred_exprs'])
        # This slice resolves the N2177 gate deferral, so the
        # entry is gone from the carried-forward list -- and the
        # new random-init deferral (the fresh-frame 0.0 stand-in
        # for Mathf.random(reload)) is present.
        self.assertFalse(any(entry.startswith('ShockwaveTower shouldConsume gate (') for entry in ledger['N2187']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower random reloadCounter init (') for entry in ledger['N2187']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower fire reset (') for entry in ledger['N2187']['deferred_exprs']))

    def test_all_c07_shockwave_tower_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2187']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_should_consume_state')
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/PowerModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2187']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_should_consume_gate_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the shockwave-tower build state:
        # ShockwaveTowerBuild.shouldConsume() (ShockwaveTower.java:121,
        # `public boolean shouldConsume(){` with `return
        # reloadCounter < reload;`, ShockwaveTower.java:122). The
        # counter is frame state (`public float reloadCounter =
        # Mathf.random(reload);`, ShockwaveTower.java:67); reload
        # is the def value from the catalog block (`reload =
        # 80f;`, Blocks.java:2043), falling back to the class
        # default (`public float reload = 60f * 1.5f;`,
        # ShockwaveTower.java:26). The BuildingComp default
        # (`return enabled;`, BuildingComp.java:755-756) does NOT
        # apply here -- this override replaces it; enabled is
        # enforced separately by the driver guard and the
        # machinery's disabled early return. When the gate is
        # false updateConsumption forces efficiency to zero
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). The driver advances the counter each
        # tick by the updateTile charge (ShockwaveTower.java:73,
        # `if(potentialEfficiency > 0 && (reloadCounter +=
        # edelta()) >= reload && timer(timerCheck,
        # checkInterval)){`, keep on ONE comment line, the N2148
        # shootWarmup lesson: a split line fails this test),
        # edelta() is efficiency * delta
        # (BuildingComp.java:1927-1929, `return efficiency *
        # delta();`), and the charge runs after the consumption
        # fold because Java calls updateConsumption()
        # (BuildingComp.java:2274) before updateTile()
        # (BuildingComp.java:2277). The fire reset
        # (`reloadCounter = 0f;`, ShockwaveTower.java:84) waits
        # for the fire slice, so a fully charged tower stays
        # charged (gate false, efficiency 0) until then; the
        # bullet scan / wave damage / heat
        # (`heat = Mathf.clamp(heat - Time.delta / reload *
        # cooldownMultiplier);`, ShockwaveTower.java:104) /
        # cooldown wait for their own slices too. The N2177 RED
        # decision is resolved: the machinery no longer runs
        # with should_consume=true when enabled.
        self.assertIn('static func source_shockwave_tower_should_consume_state', shockwave_tower)
        self.assertIn('reload_counter < reload', shockwave_tower)
        self.assertIn('public boolean shouldConsume(){', shockwave_tower)
        self.assertIn('return reloadCounter < reload;', shockwave_tower)
        self.assertIn('public float reloadCounter = Mathf.random(reload);', shockwave_tower)
        self.assertIn('public float reload = 60f * 1.5f;', shockwave_tower)
        self.assertIn('reload = 80f;', shockwave_tower)
        self.assertIn('if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', shockwave_tower)
        self.assertIn('return efficiency * delta();', shockwave_tower)
        self.assertIn('boolean update = shouldConsume() && productionValid();', shockwave_tower)
        self.assertIn('if(!update){', shockwave_tower)
        self.assertIn('return enabled;', shockwave_tower)
        self.assertIn('reloadCounter = 0f;', shockwave_tower)
        self.assertIn('heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);', shockwave_tower)
        self.assertIn('updateConsumption();', shockwave_tower)
        self.assertIn('updateTile();', shockwave_tower)
        # The driver feeds the live gate to the machinery and
        # advances the counter after the fold: the gate call,
        # the enabled-and-gate fold, the potentialEfficiency > 0
        # charge guard, and the edelta advance itself.
        self.assertIn('source_shockwave_tower_should_consume_state(frame, block)', shockwave_tower)
        self.assertIn('bool(gate.get("should_consume", true))', shockwave_tower)
        self.assertIn('float(frame.get("potential_efficiency", 0.0)) > 0.0', shockwave_tower)
        self.assertIn('frame["reload_counter"] = float(frame.get("reload_counter", 0.0)) + float(frame.get("efficiency", 0.0)) * source_placed_block_state.game_source_delta(game, seconds)', shockwave_tower)
        # The documented limits record the gate as live and the
        # charge as modeled; the old N2177 deferral text is gone.
        self.assertIn('shouldConsume gate live (N2187)', shockwave_tower)
        self.assertNotIn('runs with should_consume=true when enabled', shockwave_tower)
        # The proof's keys drive the pure gate (true below
        # reload, false at and above reload) plus the live tick
        # (efficiency 0 when the gate is false, the N2177 power
        # fold preserved when the gate is true, and the counter
        # advancing by edelta). There are no wave / heat /
        # target / sense / warmup keys: the bullet scan / wave
        # damage / heat / cooldown (ShockwaveTower.java:73-104)
        # wait for their own slice, so the reload charge
        # (ShockwaveTower.java:73) is what the efficiency keys
        # prove.
        proof = SHOCKWAVE_TOWER_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_below_reload',
            'gate_false_at_reload',
            'gate_false_above_reload',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'reload_counter_advances_by_edelta',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the N2185
        # lesson: check the preload target exists, and the
        # scene file exists and points at the proof script).
        self.assertIn('preload("res://src/game/SourceShockwaveTowerBuildState.gd")', proof)
        self.assertTrue(SHOCKWAVE_TOWER_STATE.exists())
        self.assertTrue(SHOCKWAVE_TOWER_SHOULD_CONSUME_PROOF_SCENE.exists())
        self.assertIn('C07ShockwaveTowerShouldConsumeProof.gd', SHOCKWAVE_TOWER_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_shockwave_tower_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_true_below_reload',
            'gate_false_at_reload',
            'gate_false_above_reload',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'reload_counter_advances_by_edelta',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
