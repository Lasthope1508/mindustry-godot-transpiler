import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BuildingLifecycleSerializationSliceTests(unittest.TestCase):
    def test_generated_serialization_methods_delegate_to_module(self):
        source = (PROJECT / "src/generated/classes/mindustry/entities/comp/BuildingComp.gd").read_text(encoding="utf-8")
        expected = {
            "write_12": "write_hook_noop_state",
            "read_13": "read_hook_noop_state",
            "writeAll_8": "write_all_state",
            "readAll_9": "read_all_state",
            "writeSync_10": "write_sync_state",
            "readSync_11": "read_sync_state",
            "version_58": "version_state",
        }
        for suffix, delegate in expected.items():
            match = re.search(rf"func java_method_{suffix}\(_args: Array = \[\]\) -> Variant:\n(?P<body>.*?)(?=\nfunc |\Z)", source, re.S)
            self.assertIsNotNone(match, suffix)
            self.assertIn(f"source_building_serialization_state.{delegate}", match.group("body"))
            self.assertNotIn("return null", match.group("body"))

    def test_serialization_module_keeps_exact_source_delegations(self):
        source_text = (PROJECT / "src/game/SourceBuildingSerializationSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceBuildingSerializationState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBuildingSerializationPortBridge.gd").read_text(encoding="utf-8")
        for literal in (
            'const WRITE_ALL_BASE_CALL := "writeBase(write);"',
            'const WRITE_ALL_BODY_CALL := "write(write);"',
            'const READ_ALL_BASE_CALL := "readBase(read);"',
            'const READ_ALL_BODY_CALL := "read(read, revision);"',
            'const WRITE_SYNC_CALL := "writeAll(write);"',
            'const READ_SYNC_CALL := "readAll(read, revision);"',
        ):
            self.assertIn(literal, source_text)
        for method in ("write_all_state", "read_all_state", "write_sync_state", "read_sync_state"):
            self.assertIn(f"static func {method}()", state)
            self.assertIn(f"func source_building_{method}()", bridge)
        for method in ("write_hook_noop_state", "read_hook_noop_state"):
            self.assertIn(f"static func {method}", state)

    def test_serialization_base_hooks_are_explicit_canonical_noops(self):
        source_text = (PROJECT / "src/game/SourceBuildingSerializationSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceBuildingSerializationState.gd").read_text(encoding="utf-8")
        for literal in ('const WRITE_HOOK_METHOD := "public void write(Writes write){"', 'const READ_HOOK_METHOD := "public void read(Reads read, byte revision){"'):
            self.assertIn(literal, source_text)
        self.assertIn('"no_op": true', state)

    def test_serialization_bridge_is_in_root_chain(self):
        power_graph = (PROJECT / "src/game/SourcePowerGraphPortBridge.gd").read_text(encoding="utf-8")
        self.assertIn('extends "res://src/game/SourceBuildingSerializationPortBridge.gd"', power_graph)


if __name__ == "__main__":
    unittest.main()
