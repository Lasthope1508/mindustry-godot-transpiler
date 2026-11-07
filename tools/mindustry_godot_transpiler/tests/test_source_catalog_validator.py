import tempfile
import unittest
from pathlib import Path

import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port import source_ssot, source_symbols


def _write_minimal_catalog(root: Path, *, registry, slices, contracts, schemas, aliases=None):
    payloads = {
        "registry": {"version": 1, "policy": {"newSourceOwnerRequiresRegistry": True, "canonicalOwnerAliases": aliases or {}}, "symbols": registry},
        "slice_ledger": {"version": 1, "policy": {"newSliceRequiresLedger": True}, "slices": slices},
        "api_contracts": {"version": 1, "policy": {"newSourceOwnerRequiresApiContract": True}, "contracts": contracts},
        "state_schema": {"version": 1, "policy": {"newDictionaryKeyRequiresSchema": True}, "schemas": schemas},
    }
    for module_name in source_ssot.module_names():
        payload = payloads.get(module_name, {"version": 1})
        root_key = source_ssot.root_key(module_name)
        if root_key and root_key not in payload:
            payload[root_key] = {}
        source_ssot.write_json(root, module_name, payload)
    manifest_path = root / source_ssot.extension_manifest_relative_path()
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text('{"version": 1, "modules": {}}\n', encoding="utf-8")


class SourceCatalogValidatorTests(unittest.TestCase):
    def test_catalog_validator_rejects_alias_target_without_registered_owner(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            _write_minimal_catalog(
                root,
                registry={"sample.method": {"godot_owner": "PortGame.sample_state"}},
                slices={},
                contracts={},
                schemas={},
                aliases={"port_game.sample_alias_state": "portgame.sample_state"},
            )

            report = source_symbols.validate_source_catalog(root)

            self.assertIn(
                "registry: canonical owner alias port_game.sample_alias_state targets unregistered owner portgame.sample_state",
                report["categories"]["alias_graph"],
            )

    def test_remediated_result_schemas_have_exact_upstream_evidence(self):
        godot = ROOT / "godot-mindustry"
        schemas = source_symbols.load_source_state_schema(godot)["schemas"]
        contracts = source_symbols.load_source_api_contracts(godot)["contracts"]
        owners_and_schemas = {
            "PortGame.source_tractor_beam_turret_build_draw_state": "source_tractor_beam_turret_build_draw_result",
            "PortGame.source_thermal_generator_set_stats_state": "source_thermal_generator_set_stats_result",
            "PortGame.source_turret_set_stats_state": "source_turret_set_stats_result",
            "PortGame.source_bullet_type_hit_entity_damage_cap_state": "hit_entity_damage_cap_result",
            "PortGame.source_bullet_type_hit_entity_armor_damage_state": "hit_entity_armor_damage_result",
        }
        source_cache = {}
        for owner, schema_name in owners_and_schemas.items():
            with self.subTest(owner=owner):
                keys = schemas[schema_name]["keys"]
                self.assertEqual(set(contracts[owner]["return_keys"]) - set(keys), set())
                for name, entry in keys.items():
                    alias = entry.get("alias_of")
                    if alias:
                        target, _, target_key = alias.partition(".")
                        self.assertIn(target, schemas, (schema_name, name))
                        if target_key:
                            self.assertIn(target_key, schemas[target]["keys"], (schema_name, name))
                    if entry.get("status") == "source-backed":
                        source_path = entry["java_source"]
                        if source_path not in source_cache:
                            source_cache[source_path] = (ROOT / "mindustry-upstream" / source_path).read_text(encoding="utf-8")
                        self.assertIn(entry["java_expr"], source_cache[source_path], (schema_name, name))

    def test_heat_power_and_bullet_result_schemas_match_contracts_and_source(self):
        godot = ROOT / "godot-mindustry"
        contracts = source_symbols.load_source_api_contracts(godot)["contracts"]
        schemas = source_symbols.load_source_state_schema(godot)["schemas"]
        owners = (
            "PortGame.source_building_calculate_heat_default_state",
            "PortGame.source_building_calculate_heat_state",
            "PortGame.source_power_graph_update_state",
            "PortGame.source_power_graph_remove_state",
            "PortGame.source_bullet_type_draw_parts_state",
        )
        for owner in owners:
            with self.subTest(owner=owner):
                schema_name = source_symbols._contract_result_schema_name(owner, schemas, contracts[owner]["return_keys"])
                self.assertIsNotNone(schema_name)
                self.assertEqual(set(contracts[owner]["return_keys"]) - set(schemas[schema_name]["keys"]), set())
                for key in schemas[schema_name]["keys"].values():
                    alias = key.get("alias_of")
                    if alias:
                        target, _, target_key = alias.partition(".")
                        self.assertIn(target, schemas)
                        if target_key:
                            self.assertIn(target_key, schemas[target]["keys"])

        bullet_source = (ROOT / "mindustry-upstream/core/src/mindustry/entities/bullet/BulletType.java").read_text(encoding="utf-8")
        bullet_runtime = (godot / "src/game/SourceBulletTypeDrawState.gd").read_text(encoding="utf-8")
        for expression in ("DrawPart.params.life = b.fin();", "parts.get(i).draw(DrawPart.params);"):
            self.assertIn(expression, bullet_source)
            self.assertIn(expression, bullet_runtime)

    def test_schema_reference_resolution_accepts_canonical_state_input_alias(self):
        schemas = {
            "direct": {"keys": {"value": {}}},
            "source_sample_state_input": {"keys": {"value": {}}},
        }
        self.assertEqual(
            source_symbols._resolve_contract_schema_reference(
                "port_game.source_sample_state", "direct.value", schemas
            ),
            ("direct", "value"),
        )
        self.assertEqual(
            source_symbols._resolve_contract_schema_reference(
                "port_game.source_sample_state", "source_sample_input.value", schemas, "value"
            ),
            ("source_sample_state_input", "value"),
        )
        self.assertEqual(
            source_symbols._resolve_contract_schema_reference(
                "port_game.source_sample_state", "missing.value", schemas
            ),
            None,
        )

    def test_schema_reference_resolution_uses_registered_parameter_key(self):
        schemas = {"source_bounds_state_input": {"keys": {"x_value": {}}}}
        self.assertEqual(
            source_symbols._resolve_contract_schema_reference(
                "port_game.generated_bounds_bridge_state",
                "source_bounds_input.x",
                schemas,
                "x_value",
            ),
            ("source_bounds_state_input", "x_value"),
        )

    def test_result_schema_resolution_uses_domain_name_and_owner_evidence(self):
        schemas = {
            "create_aim_result": {"keys": {"bullet": {}, "aim": {}}},
            "source_sample_result": {
                "keys": {
                    "value": {"used_by": ["port_game.source_sample_state"]},
                }
            },
        }
        self.assertEqual(
            source_symbols._contract_result_schema_name(
                "port_game.source_bullet_type_create_aim_state",
                schemas,
                ["bullet", "aim"],
            ),
            "create_aim_result",
        )
        self.assertEqual(
            source_symbols._contract_result_schema_name(
                "port_game.source_sample_state",
                schemas,
                ["value"],
            ),
            "source_sample_result",
        )

    def test_catalog_validator_reports_cross_catalog_links(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            registry = {
                "sample.method": {
                    "godot_owner": "port_game.sample_state",
                    "godot_symbol": "sample_result.value",
                    "java_source": "core/src/Sample.java",
                    "java_method": "Sample.run()",
                    "java_expr": "return value;",
                    "rule": "sample",
                    "runtime_proof": "/root/Main.sample_state",
                    "status": "source-backed",
                    "tests": ["test_sample"],
                }
            }
            slices = {
                "N1": {
                    "godot_owner": "port_game.sample_state",
                    "java_source": "core/src/Sample.java",
                    "java_class": "Sample",
                    "java_method": "Sample.run()",
                    "exact_exprs": ["return value;"],
                    "source_symbols": ["sample.method", "missing.symbol"],
                    "tests": ["test_sample"],
                    "runtime_proof": "/root/Main.sample_state",
                    "status": "done",
                }
            }
            contracts = {
                "PortGame.sample_state": {
                    "source_slice": "missing_slice",
                    "java_source": "core/src/Sample.java",
                    "source_method": "Sample.run()",
                    "params": [{"name": "value", "type": "int", "schema": "missing.value"}],
                    "return_keys": ["value"],
                    "tests": ["test_sample"],
                    "runtime_proof": "/root/Main.sample_state",
                    "rule": "sample",
                    "status": "active",
                }
            }
            schemas = {"sample_result": {"keys": {"other": {}}}}
            _write_minimal_catalog(root, registry=registry, slices=slices, contracts=contracts, schemas=schemas)

            report = source_symbols.validate_source_catalog(root)

            self.assertTrue(report["categories"]["slice_symbol_linkage"])
            self.assertTrue(report["categories"]["contract_slice_linkage"])
            self.assertTrue(report["categories"]["contract_schema_linkage"])
            self.assertTrue(report["categories"]["return_schema_linkage"])

    def test_real_catalog_report_preserves_open_p1_baseline(self):
        report = source_symbols.validate_source_catalog(ROOT / "godot-mindustry")

        self.assertEqual(report["counts"]["contract_slice_linkage"], 0)
        self.assertIn("json_errors", report)
        self.assertEqual(len(report["return_schema_diagnostics"]["missing_result_schema_contracts"]), 0)
        self.assertEqual(len(report["return_schema_diagnostics"]["unknown_return_keys"]), 0)
        self.assertEqual(len(report["errors"]), 0)


if __name__ == "__main__":
    unittest.main()
