import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BuildingLifecycleInitCreateAddSliceTests(unittest.TestCase):
    def test_source_backed_lifecycle_contract_is_present(self):
        source_text = (PROJECT / "src/game/SourceBuildingLifecycleSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceBuildingLifecycleState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBuildingLifecyclePortBridge.gd").read_text(encoding="utf-8")
        registry = (PROJECT / "src/game/SourceRuntimeOwnerBuildingRegistry.gd").read_text(encoding="utf-8")

        for literal in (
            'const SOURCE_BUILDING_INIT_METHOD := "public Building init(Tile tile, Team team, boolean shouldAdd, int rotation){"',
            'const SOURCE_BUILDING_CREATE_METHOD := "public Building create(Block block, Team team){"',
            'const SOURCE_BUILDING_ADD_METHOD := "public void add(){"',
            'const SOURCE_BUILDING_INIT_CREATE_JAVA_METHOD := "java_method_init_0"',
            'const SOURCE_BUILDING_CREATE_JAVA_METHOD := "java_method_create_1"',
            'const SOURCE_BUILDING_ADD_JAVA_METHOD := "java_method_add_2"',
        ):
            self.assertIn(literal, source_text)

        self.assertIn("static func init_state(", state)
        self.assertIn("static func create_state(", state)
        self.assertIn("static func add_state(", state)
        self.assertIn("static func generated_init_bridge_state(", state)
        self.assertIn("static func generated_create_bridge_state(", state)
        self.assertIn("static func generated_add_bridge_state(", state)
        self.assertIn("func generated_building_comp_init_bridge_state(", bridge)
        self.assertIn("func generated_building_comp_create_bridge_state(", bridge)
        self.assertIn("func generated_building_comp_add_bridge_state(", bridge)
        for name in ("INIT", "CREATE", "ADD"):
            self.assertIn(f"PORT_GAME_SOURCE_BUILDING_{name}_STATE", registry)

    def test_generated_methods_delegate_and_are_not_null_stubs(self):
        generated = (PROJECT / "src/generated/classes/mindustry/entities/comp/BuildingComp.gd").read_text(encoding="utf-8")
        expectations = {
            "init_0": "source_building_lifecycle_state.init_state",
            "create_1": "source_building_lifecycle_state.create_state",
            "add_2": "source_building_lifecycle_state.add_state",
        }
        for suffix, delegate in expectations.items():
            match = re.search(rf"func java_method_{suffix}\(_args: Array = \[\]\) -> Variant:\n(?P<body>.*?)(?=\nfunc |\Z)", generated, re.S)
            self.assertIsNotNone(match, suffix)
            self.assertIn(delegate, match.group("body"))
            self.assertNotIn("return null", match.group("body"))

    def test_canonical_catalogs_register_all_three_owners(self):
        generated = PROJECT / "src/generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        contracts = json.loads((generated / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        schemas = json.loads((generated / "source_state_schema.json").read_text(encoding="utf-8"))["schemas"]
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        owners = {
            "init": "PortGame.source_building_init_state",
            "create": "PortGame.source_building_create_state",
            "add": "PortGame.source_building_add_state",
        }
        for name, owner in owners.items():
            self.assertTrue(any(entry.get("godot_owner") == owner for entry in registry.values()), name)
            self.assertIn(owner, contracts)
            self.assertIn(f"source_building_{name}_input", schemas)
            self.assertIn(f"source_building_{name}_result", schemas)
            self.assertTrue(any(entry.get("godot_owner") == owner for entry in ledger.values()), name)

    def test_runtime_proof_checks_lifecycle_bridges(self):
        proof = (PROJECT / "tools/runtime_proofs/BuildingLifecycleStateModuleProof.gd").read_text(encoding="utf-8")
        for key in ("init_bridge_matches", "create_bridge_matches", "add_bridge_matches"):
            self.assertIn(f'"{key}"', proof)
        self.assertIn("runtime_proof_state.exit_code(proof)", proof)


if __name__ == "__main__":
    unittest.main()
