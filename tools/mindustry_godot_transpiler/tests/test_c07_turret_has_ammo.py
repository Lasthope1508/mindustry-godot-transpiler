import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_HAS_AMMO_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretHasAmmoProof.gd'


class C07TurretHasAmmoTests(unittest.TestCase):
    def test_c07_turret_has_ammo_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2313']['godot_owner'], 'SourceTurretBuildState.source_turret_has_ammo_state')
        # One predicate on TurretBuild (Turret.java:277):
        # `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
        # hasAmmo() (Turret.java:698-713):
        # `public boolean hasAmmo(){`
        # `//skip first entry if it has less than the required amount of ammo`
        # `if(ammo.size >= 2 && ammo.peek().amount < ammoPerShot){`
        # `for(int i = 0; i < ammo.size; i ++){`
        # `if(ammo.get(i).amount >= ammoPerShot){`
        # `ammo.swap(ammo.size - 1, i);`
        # `break;`
        # `}`
        # `}`
        # `//used for "side-ammo" like gas in some turrets`
        # `if(!canConsume()) return false;`
        # `return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());`
        # `}`
        # -- ammo is the TurretBuild field (`public Seq<AmmoEntry>
        # ammo = new Seq<>();`, Turret.java:282), ammoPerShot the
        # block field (`public int ammoPerShot = 1;`, Turret.java:49).
        # Both arrive as explicit params (the N2311/N2261 precedent):
        # the ammo list as an Array of {amount, item} dicts (the
        # peek_ammo_stack_state convention -- Seq.peek() is the last
        # entry), ammo_per_shot as an int. canConsume() (Turret.java:624)
        # and cheating() are NOT ported here: their results arrive as
        # explicit bool params (the brief). The swap is the side-effect:
        # the function returns BOTH the bool and the new ammo order
        # (`ammo_stacks_after`) -- the caller keeps its own list
        # (pure function: the swap lands on a deep copy). NO driver
        # tick line: hasAmmo() is a predicate its callers read, not a
        # per-tick write (the N2249/N2221 precedent) -- estimateDps()
        # (N2301) and targetPosition() (Turret.java:454) read the
        # result; targetPosition() still waits for peekAmmo() (T6).
        # Two new result symbols: has_ammo + ammo_stacks_after.
        self.assertEqual(
            ledger['N2313']['source_symbols'],
            [
                'source_turret_has_ammo_state_result.has_ammo',
                'source_turret_has_ammo_state_result.ammo_stacks_after',
            ],
        )
        for name in ledger['N2313']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2313']['runtime_proof'], '/root/C07TurretHasAmmoProof')
        self.assertEqual(
            ledger['N2313']['tests'],
            [
                'test_c07_turret_has_ammo_registration',
                'test_all_c07_turret_has_ammo_input_evidence_is_exact',
                'test_turret_has_ammo_state',
                'test_reference_graph_and_actual_c07_turret_has_ammo',
            ],
        )
        self.assertTrue(ledger['N2313']['deferred_exprs'])

    def test_all_c07_turret_has_ammo_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2313']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2313']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_has_ammo_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.hasAmmo() (Turret.java:698-713):
        # `public boolean hasAmmo(){`
        # `//skip first entry if it has less than the required amount of ammo`
        # `if(ammo.size >= 2 && ammo.peek().amount < ammoPerShot){`
        # `for(int i = 0; i < ammo.size; i ++){`
        # `if(ammo.get(i).amount >= ammoPerShot){`
        # `ammo.swap(ammo.size - 1, i);`
        # `break;`
        # `}`
        # `}`
        # `//used for "side-ammo" like gas in some turrets`
        # `if(!canConsume()) return false;`
        # `return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());`
        # `}`
        # -- the swap runs BEFORE the canConsume() gate (Java order:
        # the scan/swap is the first block, the gate the second), so
        # the returned ammo_stacks_after carries the swap even when
        # has_ammo is false for can_consume. Seq.peek() is the LAST
        # entry (arc Seq.peek() returns items[size - 1]), matching the
        # peek_ammo_stack_state convention. canConsume() and cheating()
        # are explicit bool params, NOT re-ported here.
        self.assertIn('static func source_turret_has_ammo_state(frame: Dictionary, ammo_stacks: Array, ammo_per_shot: int, can_consume: bool, cheating: bool) -> Dictionary:', turret)
        self.assertIn('stacks_after[stacks_after.size() - 1] = candidate', turret)
        self.assertIn('stacks_after[index] = last_entry', turret)
        self.assertIn('return {"has_ammo": has_ammo, "ammo_stacks_after": stacks_after}', turret)
        for expr in [
            'public boolean hasAmmo(){',
            'if(ammo.size >= 2 && ammo.peek().amount < ammoPerShot){',
            'for(int i = 0; i < ammo.size; i ++){',
            'if(ammo.get(i).amount >= ammoPerShot){',
            'ammo.swap(ammo.size - 1, i);',
            'if(!canConsume()) return false;',
            'return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());',
            'public Seq<AmmoEntry> ammo = new Seq<>();',
            'public int ammoPerShot = 1;',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function with synthetic
        # frames (no live tick: hasAmmo() is a pure predicate over
        # explicit params): empty ammo is false / a single sufficient
        # stack is true / a single short stack is false without
        # cheating and true with cheating / a short peek with a
        # sufficient entry swaps it to the peek position / no
        # sufficient entry means no swap / can_consume false is false
        # even with sufficient ammo (and the swap still applies) /
        # the input ammo list is NOT mutated (pure function: the swap
        # lands on a deep copy) / the result carries only its two keys.
        proof = TURRET_HAS_AMMO_PROOF.read_text(encoding='utf-8')
        for key in [
            'has_ammo_empty_false',
            'has_ammo_single_enough_true',
            'has_ammo_single_short_false',
            'has_ammo_single_short_cheating_true',
            'has_ammo_swap_to_sufficient',
            'has_ammo_no_sufficient_no_swap',
            'has_ammo_cannot_consume_false',
            'has_ammo_input_unmutated',
            'returns_only_two_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_has_ammo(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretHasAmmoProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_HAS_AMMO_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'has_ammo_empty_false',
            'has_ammo_single_enough_true',
            'has_ammo_single_short_false',
            'has_ammo_single_short_cheating_true',
            'has_ammo_swap_to_sufficient',
            'has_ammo_no_sufficient_no_swap',
            'has_ammo_cannot_consume_false',
            'has_ammo_input_unmutated',
            'returns_only_two_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
