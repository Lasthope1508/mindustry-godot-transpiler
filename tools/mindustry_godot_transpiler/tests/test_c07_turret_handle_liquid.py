import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_HANDLE_LIQUID_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretHandleLiquidProof.gd'


class C07TurretHandleLiquidTests(unittest.TestCase):
    def test_c07_turret_handle_liquid_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2356']['godot_owner'], 'SourceTurretBuildState.source_turret_handle_liquid_state')
        # TurretBuild.handleLiquid() (Turret.java:615-621):
        # `@Override`
        # `public void handleLiquid(Building source, Liquid liquid, float amount){`
        # `if(coolant != null && liquids.currentAmount() <= 0.001f){`
        # `Events.fire(Trigger.turretCool);`
        # `}`
        # `super.handleLiquid(source, liquid, amount);`
        # `}`
        # on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
        # (Turret.java:277). When the turret block has a coolant
        # consumer (`public @Nullable ConsumeLiquidBase coolant;`,
        # BaseTurret.java:34) and the liquid store is (near-)empty
        # (`public float currentAmount(){`,
        # LiquidModule.java:98, `<= 0.001f`), the turret-cool
        # event fires (`Events.fire(Trigger.turretCool);`) -- the
        # port records it as the bool flag turret_cool_fired, it
        # does NOT port Events/Trigger. The base
        # BuildingComp.handleLiquid (BuildingComp.java:872-874,
        # `public void handleLiquid(Building source, Liquid liquid,
        # float amount){` / `liquids.add(liquid, amount);`) is
        # ALWAYS called via super -- the port records it as the
        # flag super_called, it does NOT port
        # Building.handleLiquid (the N585 base slice owns the
        # `liquids.add(liquid, amount);` line). The signature line
        # is shared text with N585 (BuildingComp.handleLiquid
        # base, a different class and method) and N2118
        # (GenericCrafterBuild evidence) -- callee/context
        # evidence, not ownership of TurretBuild.handleLiquid();
        # this slice registers the correct java_class =
        # ...Turret.TurretBuild and java_method =
        # TurretBuild.handleLiquid(...) (the batch-10 scope
        # section 1.2 flag, resolved here, not stalled on). NO
        # driver tick line: the engine calls handleLiquid()
        # when liquid enters the building; no call site is ported
        # here. Two new result symbols: turret_cool_fired,
        # super_called.
        self.assertEqual(
            ledger['N2356']['source_symbols'],
            [
                'source_turret_handle_liquid_state_result.turret_cool_fired',
                'source_turret_handle_liquid_state_result.super_called',
            ],
        )
        for name in ledger['N2356']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_handle_liquid_state')
        self.assertEqual(ledger['N2356']['runtime_proof'], '/root/C07TurretHandleLiquidProof')
        self.assertEqual(
            ledger['N2356']['tests'],
            [
                'test_c07_turret_handle_liquid_registration',
                'test_all_c07_turret_handle_liquid_input_evidence_is_exact',
                'test_turret_handle_liquid_state',
                'test_reference_graph_and_actual_c07_turret_handle_liquid',
            ],
        )
        self.assertTrue(ledger['N2356']['deferred_exprs'])

    def test_all_c07_turret_handle_liquid_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2356']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_handle_liquid_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2356']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_handle_liquid_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.handleLiquid() (Turret.java:615-621) fires
        # the turret-cool event only when the block has a coolant
        # consumer and the liquid store is (near-)empty, then
        # ALWAYS delegates to the Building base:
        # `if(coolant != null && liquids.currentAmount() <= 0.001f){`
        # / `Events.fire(Trigger.turretCool);`
        # / `super.handleLiquid(source, liquid, amount);`. The
        # event is a bool flag in the returned dict (no
        # Events/Trigger port); the super call is the
        # super_called flag (Building.handleLiquid itself is NOT
        # ported -- N585 owns `liquids.add(liquid, amount);`).
        # The coolant field lives on the block
        # (`public @Nullable ConsumeLiquidBase coolant;`,
        # BaseTurret.java:34) and is read as the explicit bool
        # param has_coolant; the liquid amount is
        # `public float currentAmount(){`
        # (LiquidModule.java:98), read as the explicit float param
        # liquid_amount. There is NO driver tick line: the engine
        # calls handleLiquid() when liquid enters the building.
        self.assertIn('static func source_turret_handle_liquid_state(frame: Dictionary, has_coolant: bool, liquid_amount: float) -> Dictionary:', turret)
        self.assertIn('var turret_cool_fired: bool = has_coolant and liquid_amount <= 0.001', turret)
        self.assertIn('return {"turret_cool_fired": turret_cool_fired, "super_called": true}', turret)
        for expr in [
            'public void handleLiquid(Building source, Liquid liquid, float amount){',
            'if(coolant != null && liquids.currentAmount() <= 0.001f){',
            'Events.fire(Trigger.turretCool);',
            'super.handleLiquid(source, liquid, amount);',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            'public @Nullable ConsumeLiquidBase coolant;',
            'liquids.add(liquid, amount);',
            'public float currentAmount(){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function with synthetic
        # frames and explicit coolant/amount params (no live tick,
        # no liquid flow: the amount arrives already measured as
        # liquid_amount): coolant + empty store fires the event
        # and always calls super / no coolant never fires /
        # coolant + liquid present never fires / the 0.001
        # boundary still fires (`<= 0.001f`) / the frame is not
        # mutated by the call.
        proof = TURRET_HANDLE_LIQUID_PROOF.read_text(encoding='utf-8')
        for key in [
            'turret_cool_fired',
            'no_coolant_noop',
            'liquid_present_noop',
            'boundary_fires',
            'input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_handle_liquid(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretHandleLiquidProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_HANDLE_LIQUID_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'turret_cool_fired',
            'no_coolant_noop',
            'liquid_present_noop',
            'boundary_fires',
            'input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
