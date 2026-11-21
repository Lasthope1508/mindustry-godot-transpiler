import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_AMMO_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourcePayloadAmmoTurretBuildPortBridge.gd'
PAYLOAD_AMMO_TURRET_LIMIT_RANGE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadTurretLimitRangeProof.gd'


class C07PayloadTurretLimitRangeTests(unittest.TestCase):
    def test_c07_payload_turret_limit_range_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2384']['godot_owner'], 'PortGame.source_payload_ammo_turret_limit_range_state')
        # PayloadTurret limitRange()+limitRange(float)+setStats()
        # (PayloadAmmoTurret.java:40-42/:45-49/:51-56):
        # `public void limitRange(){`
        # `limitRange(1f);`
        # `}`
        # `public void limitRange(float margin){`
        # `for(var entry : ammoTypes.copy().entries()){`
        # `entry.value.lifetime = (range + margin) / entry.value.speed;`
        # `}`
        # `}`
        # `@Override`
        # `public void setStats(){`
        # `super.setStats();`
        # `stats.remove(Stat.itemCapacity);`
        # `stats.add(Stat.ammo, StatValues.ammo(ammoTypes, true));`
        # `}`
        # on `public class PayloadAmmoTurret extends Turret{`
        # (PayloadAmmoTurret.java:21). These are class methods
        # (not Build methods): limitRange copies every ammo
        # bullet and clamps its lifetime to (range + margin) /
        # speed; the no-arg form delegates with margin 1f;
        # setStats drops the itemCapacity stat row and adds
        # the ammo row. `super.setStats();` is callee/context
        # (Block/Turret super stats) -- NOT a distinguishing
        # expr. `stats.remove(Stat.itemCapacity);` hits N1175
        # in both ledgers -- evidence only, NOT a
        # distinguishing expr. The distinguishing lines are
        # `limitRange(1f);`,
        # `for(var entry : ammoTypes.copy().entries()){`,
        # `entry.value.lifetime = (range + margin) / entry.value.speed;`
        # and `stats.add(Stat.ammo, StatValues.ammo(ammoTypes, true));`
        # (all 0-hit in both ledgers at HEAD 0ac2993f).
        # `ammoTypes` arrives as the explicit ammo_entries
        # param (one dict per ammo entry: content/lifetime/
        # speed -- the N2330 param precedent); `range` is the
        # BaseTurret field (`public float range = 80f;`,
        # BaseTurret.java:21) and arrives as the explicit
        # range_value param; `margin` arrives as an explicit
        # float param (1.0 for the no-arg form); `stats`
        # (Stats UI API) arrives as the explicit stats param
        # (rows of stat dicts -- the N2330 param precedent);
        # `StatValues.ammo(ammoTypes, true)` is NOT ported --
        # the ammo row spec carries the ammo types list and
        # the showUnit flag (`show_unit: true`,
        # StatValues.java:606-607 `ammo(map, boolean
        # showUnit)`).
        # Three new result symbols: ammo_entries (x2),
        # stats.
        self.assertEqual(
            ledger['N2384']['source_symbols'],
            [
                'source_payload_ammo_turret_limit_range_state_result.ammo_entries',
                'source_payload_ammo_turret_limit_range_default_state_result.ammo_entries',
                'source_payload_ammo_turret_set_stats_state_result.stats',
            ],
        )
        for name in ledger['N2384']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2384']['runtime_proof'], '/root/C07PayloadTurretLimitRangeProof')
        self.assertEqual(
            ledger['N2384']['tests'],
            [
                'test_c07_payload_turret_limit_range_registration',
                'test_all_c07_payload_turret_limit_range_input_evidence_is_exact',
                'test_payload_turret_limit_range_set_stats_state',
                'test_reference_graph_and_actual_c07_payload_turret_limit_range',
            ],
        )
        self.assertTrue(ledger['N2384']['deferred_exprs'])

    def test_all_c07_payload_turret_limit_range_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2384']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2384']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_turret_limit_range_set_stats_state(self):
        bridge = PAYLOAD_AMMO_TURRET_BRIDGE.read_text(encoding='utf-8')
        # PayloadTurret limitRange()+limitRange(float)+setStats()
        # (PayloadAmmoTurret.java:40-42/:45-49/:51-56) groups
        # three class methods: limitRange(float) rewrites every
        # ammo bullet lifetime to (range + margin) / speed over
        # a copy of the ammo map; limitRange() delegates with
        # margin 1f; setStats removes the itemCapacity row and
        # adds the ammo row. `super.setStats();` is
        # callee/context. NO driver tick line: limitRange is a
        # def-time setup call, setStats is a UI spec -- the
        # caller wiring waits for its own slice.
        self.assertIn('static func source_payload_ammo_turret_limit_range_state(ammo_entries: Array, range_value: float, margin: float) -> Dictionary:', bridge)
        self.assertIn('static func source_payload_ammo_turret_limit_range_default_state(ammo_entries: Array, range_value: float) -> Dictionary:', bridge)
        self.assertIn('static func source_payload_ammo_turret_set_stats_state(stats: Array, ammo_types: Array) -> Dictionary:', bridge)
        self.assertIn('return source_payload_ammo_turret_limit_range_state(ammo_entries, range_value, 1.0)', bridge)
        self.assertIn('return {"ammo_entries": updated}', bridge)
        self.assertIn('return {"stats": rows}', bridge)
        for expr in [
            'public class PayloadAmmoTurret extends Turret{',
            'public class PayloadTurretBuild extends TurretBuild{',
            'public void limitRange(){',
            'limitRange(1f);',
            'public void limitRange(float margin){',
            'for(var entry : ammoTypes.copy().entries()){',
            'entry.value.lifetime = (range + margin) / entry.value.speed;',
            '@Override',
            'public void setStats(){',
            'super.setStats();',
            'stats.remove(Stat.itemCapacity);',
            'stats.add(Stat.ammo, StatValues.ammo(ammoTypes, true));',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the three pure functions
        # with synthetic inputs (no live tick): limitRange
        # rewrites lifetimes / default margin is 1.0 / other
        # fields kept / inputs unmutated / exactly one
        # result key / empty stays empty; setStats removes
        # the itemCapacity row / adds the ammo row /
        # inputs unmutated / exactly one result key /
        # empty stats still gets the ammo row.
        proof = PAYLOAD_AMMO_TURRET_LIMIT_RANGE_PROOF.read_text(encoding='utf-8')
        for key in [
            'limit_range_sets_lifetime',
            'limit_range_default_margin_one',
            'limit_range_keeps_other_fields',
            'limit_range_inputs_unmutated',
            'limit_range_returns_only_one_key',
            'limit_range_empty_returns_empty',
            'set_stats_removes_item_capacity',
            'set_stats_adds_ammo_row',
            'set_stats_inputs_unmutated',
            'set_stats_returns_only_one_key',
            'set_stats_empty_stats_adds_ammo',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_payload_turret_limit_range(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadTurretLimitRangeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_TURRET_LIMIT_RANGE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'limit_range_sets_lifetime',
            'limit_range_default_margin_one',
            'limit_range_keeps_other_fields',
            'limit_range_inputs_unmutated',
            'limit_range_returns_only_one_key',
            'limit_range_empty_returns_empty',
            'set_stats_removes_item_capacity',
            'set_stats_adds_ammo_row',
            'set_stats_inputs_unmutated',
            'set_stats_returns_only_one_key',
            'set_stats_empty_stats_adds_ammo',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
