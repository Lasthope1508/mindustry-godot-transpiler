import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
POINT_DEFENSE_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceTurretRuntimePortBridge.gd'
POINT_DEFENSE_REGISTRY = ROOT / 'godot-mindustry/src/game/SourceRuntimeOwnerTurretRegistry.gd'
POINT_DEFENSE_PERSISTENCE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretPersistenceIntegrationProof.gd'


class C07PointDefenseTurretPersistenceIntegrationTests(unittest.TestCase):
    def test_c07_point_defense_turret_persistence_integration_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2249']['godot_owner'], 'PortGame.source_point_defense_turret_build_write_state')
        # N2245 built the write/read pure functions on
        # SourcePointDefenseTurretBuildState, but nothing in the
        # port could call them from the PortGame surface: the
        # port has no save/load stream, and no bridge exposed
        # them (PointDefenseTurret.java:117-128, `write` persists
        # exactly one float, `rotation`, and `read` restores it
        # unconditionally -- no revision guard, unlike
        # RepairTurret.read(), N2217). N2249 wires the two pure
        # functions onto the PortGame-callable surface, the
        # N2217/N2245 deferred persistence-integration step: two
        # thin bridge functions on
        # SourceTurretRuntimePortBridge (the TractorBeam
        # precedent, :221/:227, and the ItemTurret precedent,
        # SourceItemTurretBuildPortBridge.gd:68) that delegate to
        # the N2245 pure functions, plus two registry consts in
        # SourceRuntimeOwnerTurretRegistry (the N2246 precedent:
        # a registry const gets no symbol of its own, only the
        # callable surface is registered). The bridge write wraps
        # the rotation float into the frame the pure function
        # reads (`{"rotation": rotation_value}`, default 90.0
        # when absent, `public float rotation = 90;`,
        # BaseTurret.java:114); the bridge read passes the saved
        # float straight through -- NO revision parameter,
        # because the Java body never reads `revision`, and NO
        # frame parameter either. NO driver tick line:
        # persistence is not a per-tick call (the N2245
        # precedent). NO `generated_*_bridge_state` variant:
        # that pattern needs a
        # `java_inner_class_PointDefenseBuild_method_write_*` /
        # `read_*` stub, and grep of `godot-mindustry/src/`
        # finds NO `java_inner_class_PointDefense*` stub at all.
        # NO save/load stream is created here: PortGame.gd calls
        # no `*_build_write_state` / `*_build_read_state`
        # bridge yet, and no file outside the bridge/registry
        # calls these two either -- the stream caller is a later
        # slice. Two new result symbols: the bridge write/read
        # rotation, each backed by the same Java line as its
        # N2245 pure function.
        self.assertEqual(
            ledger['N2249']['source_symbols'],
            [
                'source_point_defense_turret_build_write_state_result.rotation',
                'source_point_defense_turret_build_read_state_result.rotation',
            ],
        )
        for name in ledger['N2249']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2249']['runtime_proof'], '/root/C07PointDefenseTurretPersistenceIntegrationProof')
        self.assertEqual(
            ledger['N2249']['tests'],
            [
                'test_c07_point_defense_turret_persistence_integration_registration',
                'test_all_c07_point_defense_turret_persistence_integration_input_evidence_is_exact',
                'test_point_defense_turret_persistence_integration_state',
                'test_reference_graph_and_actual_c07_point_defense_turret_persistence_integration',
            ],
        )
        self.assertTrue(ledger['N2249']['deferred_exprs'])

    def test_all_c07_point_defense_turret_persistence_integration_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2249']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2249']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_point_defense_turret_persistence_integration_state(self):
        bridge = POINT_DEFENSE_BRIDGE.read_text(encoding='utf-8')
        # (1) The bridge preloads the family state file (the
        # ItemTurret bridge precedent,
        # SourceItemTurretBuildPortBridge.gd:3, `const
        # source_item_turret_build_state :=
        # preload("res://src/game/SourceItemTurretBuildState.gd")`)
        # and exposes two thin delegating functions: write wraps
        # the rotation float into the frame the N2245 pure
        # function reads, read passes the saved float straight
        # through. The bridge functions carry their Java
        # evidence as comments, the repo convention.
        self.assertIn('const source_point_defense_turret_build_state := preload("res://src/game/SourcePointDefenseTurretBuildState.gd")', bridge)
        self.assertIn('func source_point_defense_turret_build_write_state(rotation_value: float) -> Dictionary:', bridge)
        self.assertIn('return source_point_defense_turret_build_state.source_point_defense_turret_write_state({"rotation": rotation_value})', bridge)
        self.assertIn('func source_point_defense_turret_build_read_state(saved_rotation: float) -> Dictionary:', bridge)
        self.assertIn('return source_point_defense_turret_build_state.source_point_defense_turret_read_state(saved_rotation)', bridge)
        for expr in [
            'public void write(Writes write){',
            'super.write(write);',
            'write.f(rotation);',
            'public void read(Reads read, byte revision){',
            'super.read(read, revision);',
            'rotation = read.f();',
            'public byte version(){',
            'return 0;',
            'public float rotation = 90;',
            'public class PointDefenseTurret extends ReloadTurret{',
            'public class PointDefenseBuild extends ReloadTurretBuild{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # NO generated_*_bridge_state variant: that pattern
        # needs a java_inner_class_PointDefenseBuild stub and
        # none exists anywhere under godot-mindustry/src/.
        self.assertNotIn('generated_point_defense_turret_build_write_bridge_state', bridge)
        self.assertNotIn('generated_point_defense_turret_build_read_bridge_state', bridge)
        # (2) The two registry consts (the N2246 precedent:
        # PORT_GAME_SOURCE_POINT_DEFENSE_TURRET_SET_STATS_STATE,
        # SourceRuntimeOwnerTurretRegistry.gd:104).
        registry = POINT_DEFENSE_REGISTRY.read_text(encoding='utf-8')
        self.assertIn('const PORT_GAME_SOURCE_POINT_DEFENSE_TURRET_BUILD_WRITE_STATE := "port_game.source_point_defense_turret_build_write_state"', registry)
        self.assertIn('const PORT_GAME_SOURCE_POINT_DEFENSE_TURRET_BUILD_READ_STATE := "port_game.source_point_defense_turret_build_read_state"', registry)
        # The proof's keys drive the bridge through the game
        # node (PortGame inherits SourceTurretRuntimePortBridge
        # via the SourceSsotAccessorPortBridge link in its
        # extends chain, the ItemTurret proof precedent):
        # bridge write returns the rotation / bridge write
        # returns only rotation / bridge read restores the
        # saved rotation / bridge read returns only rotation /
        # bridge write-then-read round-trips the value / the
        # registry consts name the bridge functions.
        proof = POINT_DEFENSE_PERSISTENCE_PROOF.read_text(encoding='utf-8')
        for key in [
            'bridge_write_returns_rotation',
            'bridge_write_returns_only_rotation',
            'bridge_read_restores_rotation',
            'bridge_read_returns_only_rotation',
            'bridge_write_read_round_trip',
            'registry_consts_match_bridge_names',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_point_defense_turret_persistence_integration(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PointDefenseTurretPersistenceIntegrationProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_POINT_DEFENSE_TURRET_PERSISTENCE_INTEGRATION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'bridge_write_returns_rotation',
            'bridge_write_returns_only_rotation',
            'bridge_read_restores_rotation',
            'bridge_read_returns_only_rotation',
            'bridge_write_read_round_trip',
            'registry_consts_match_bridge_names',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
