import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_PEEK_AMMO_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretPeekAmmoProof.gd'


class C07TurretPeekAmmoTests(unittest.TestCase):
    def test_c07_turret_peek_ammo_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2329']['godot_owner'], 'SourceTurretBuildState.source_turret_peek_ammo_state')
        # One pure accessor on TurretBuild (Turret.java:277):
        # `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
        # peekAmmo() (Turret.java:693-695):
        # `/** @return the ammo type that will be returned if useAmmo is called. */`
        # `public @Nullable BulletType peekAmmo(){`
        # `return ammo.size == 0 ? null : ammo.peek().type();`
        # `}`
        # -- ammo is the TurretBuild field (`public Seq<AmmoEntry>
        # ammo = new Seq<>();`, Turret.java:282) and arrives as an
        # explicit param (the N2313 hasAmmo precedent): the ammo list
        # as an Array of {amount, item, type} dicts (the
        # peek_ammo_stack_state convention -- Seq.peek() is the last
        # entry). AmmoEntry is the abstract entry type (`public static
        # abstract class AmmoEntry{`, Turret.java:257) with `public int
        # amount;` and `public abstract BulletType type();`
        # (Turret.java:258-260). `type()` is NOT re-ported here: for
        # ItemEntry it resolves through the block ammoTypes map
        # (`return ammoTypes.get(item);`, ItemTurret.java:236-238) and
        # the map itself is NOT ported -- the BulletType NAME arrives
        # as the explicit "type" value on each entry dict. peekAmmo()
        # does NOT check amounts and does NOT swap (unlike hasAmmo()
        # N2313): it only reads the peek. NO driver tick line:
        # peekAmmo() is a pure accessor its callers read, not a
        # per-tick write (the N2249/N2221 precedent) -- targetPosition()
        # (Turret.java:454, remote N2266) and useAmmo() (N2108) read
        # the result; neither caller is ported here. One new result
        # symbol: peek_ammo.
        self.assertEqual(
            ledger['N2329']['source_symbols'],
            [
                'source_turret_peek_ammo_state_result.peek_ammo',
            ],
        )
        for name in ledger['N2329']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2329']['runtime_proof'], '/root/C07TurretPeekAmmoProof')
        self.assertEqual(
            ledger['N2329']['tests'],
            [
                'test_c07_turret_peek_ammo_registration',
                'test_all_c07_turret_peek_ammo_input_evidence_is_exact',
                'test_turret_peek_ammo_state',
                'test_reference_graph_and_actual_c07_turret_peek_ammo',
            ],
        )
        self.assertTrue(ledger['N2329']['deferred_exprs'])

    def test_all_c07_turret_peek_ammo_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2329']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2329']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_peek_ammo_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.peekAmmo() (Turret.java:693-695):
        # `/** @return the ammo type that will be returned if useAmmo is called. */`
        # `public @Nullable BulletType peekAmmo(){`
        # `return ammo.size == 0 ? null : ammo.peek().type();`
        # `}`
        # -- ammo is the TurretBuild field (`public Seq<AmmoEntry>
        # ammo = new Seq<>();`, Turret.java:282), explicit param as an
        # Array of {amount, item, type} dicts (the N2313 convention --
        # Seq.peek() is the last entry). The "type" value on each dict
        # carries the `AmmoEntry.type()` result (the BulletType name):
        # `type()` itself is NOT re-ported (ItemEntry resolves it via
        # the unported ammoTypes map, ItemTurret.java:236-238).
        # peekAmmo() reads only the peek: no amount check, no swap,
        # no mutation -- unlike hasAmmo() (N2313). NO driver tick
        # line: a pure accessor its callers read (targetPosition
        # Turret.java:454, useAmmo N2108), not a per-tick write.
        self.assertIn('static func source_turret_peek_ammo_state(frame: Dictionary, ammo_stacks: Array) -> Dictionary:', turret)
        self.assertIn('return {"peek_ammo": peeked_type}', turret)
        for expr in [
            'public @Nullable BulletType peekAmmo(){',
            'return ammo.size == 0 ? null : ammo.peek().type();',
            'public Seq<AmmoEntry> ammo = new Seq<>();',
            'public abstract BulletType type();',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function with synthetic
        # frames (no live tick: peekAmmo() is a pure accessor over an
        # explicit param): empty ammo is null / a single stack returns
        # its type name / the peek is the LAST entry, not the first /
        # an entry without a "type" value is null / the amount is
        # ignored (peekAmmo never checks amounts) / the input ammo
        # list is NOT mutated / the result carries only its one key.
        proof = TURRET_PEEK_AMMO_PROOF.read_text(encoding='utf-8')
        for key in [
            'peek_ammo_empty_null',
            'peek_ammo_single_returns_type',
            'peek_ammo_peek_is_last',
            'peek_ammo_missing_type_null',
            'peek_ammo_amount_ignored',
            'peek_ammo_input_unmutated',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_peek_ammo(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretPeekAmmoProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_PEEK_AMMO_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'peek_ammo_empty_null',
            'peek_ammo_single_returns_type',
            'peek_ammo_peek_is_last',
            'peek_ammo_missing_type_null',
            'peek_ammo_amount_ignored',
            'peek_ammo_input_unmutated',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
