import unittest
from pathlib import Path

import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port import source_symbols


class SourceSymbolRegistryTests(unittest.TestCase):
    def test_draw_parts_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])
        self.assertEqual(registry["version"], 1)

        fin_entry = source_symbols.source_symbol(registry, "bullet.fin")
        self.assertEqual(fin_entry["status"], "explicit-input")
        self.assertEqual(fin_entry["java_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(fin_entry["java_method"], "drawParts(Bullet b)")
        self.assertEqual(fin_entry["java_expr"], "b.fin()")
        self.assertEqual(fin_entry["godot_owner"], "PortGame.source_bullet_type_draw_parts_state")
        self.assertIn("test_bullet_type_draw_parts_state_matches_upstream_source", fin_entry["tests"])

        warmup_entry = source_symbols.source_symbol(registry, "draw_part.params.warmup")
        self.assertEqual(warmup_entry["status"], "source-backed")
        self.assertEqual(warmup_entry["java_expr"], "DrawPart.params.set(b.fin(), 0f, 0f, 0f, 0f, 0f, b.x, b.y, b.rotation()).warmup")
        self.assertEqual(warmup_entry["godot_symbol"], "partParams.warmup")
        self.assertEqual(warmup_entry["runtime_proof"], "/root/Main.source_bullet_type_draw_parts_state")

    def test_source_symbol_registry_rejects_unbacked_source_symbols(self):
        registry = {
            "version": 1,
            "symbols": {
                "bad.symbol": {
                    "status": "source-backed",
                    "godot_symbol": "bad",
                    "godot_owner": "PortGame.bad",
                    "rule": "bad",
                    "tests": [],
                    "runtime_proof": "/root/Main.bad",
                }
            },
        }

        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertIn("bad.symbol: source-backed requires java_source", errors)
        self.assertIn("bad.symbol: source-backed requires java_method", errors)
        self.assertIn("bad.symbol: source-backed requires java_expr", errors)

    def test_test_collision_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        bullet_team = source_symbols.source_symbol(registry, "test_collision.bullet.team")
        self.assertEqual(bullet_team["java_expr"], "bullet.team")
        self.assertEqual(bullet_team["godot_symbol"], "bullet_state.team")
        self.assertEqual(bullet_team["godot_owner"], "PortGame.source_bullet_type_test_collision_state")

        tile_health = source_symbols.source_symbol(registry, "test_collision.tile.healthf")
        self.assertEqual(tile_health["status"], "explicit-input")
        self.assertEqual(tile_health["java_expr"], "tile.healthf()")
        self.assertEqual(tile_health["runtime_proof"], "/root/Main.source_bullet_type_test_collision_state")

    def test_hit_tile_heal_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        heal_gate = source_symbols.source_symbol(registry, "hit_tile.heal_gate")
        self.assertEqual(heal_gate["java_expr"], "heals() && build.team == b.team && !(build.block instanceof ConstructBlock)")
        self.assertEqual(heal_gate["godot_owner"], "PortGame.source_bullet_type_hit_tile_heal_state")
        self.assertEqual(heal_gate["runtime_proof"], "/root/Main.source_bullet_type_hit_tile_heal_state")

        heal_amount = source_symbols.source_symbol(registry, "hit_tile.heal_amount_formula")
        self.assertEqual(heal_amount["java_expr"], "healPercent / 100f * build.maxHealth + healAmount")
        self.assertEqual(heal_amount["godot_symbol"], "hit_tile_heal_result.healAppliedAmount")

    def test_hit_tile_fire_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        fire_gate = source_symbols.source_symbol(registry, "hit_tile.fire_gate")
        self.assertEqual(fire_gate["java_expr"], "makeFire && build.team != b.team")
        self.assertEqual(fire_gate["godot_owner"], "PortGame.source_bullet_type_hit_tile_fire_state")
        self.assertEqual(fire_gate["runtime_proof"], "/root/Main.source_bullet_type_hit_tile_fire_state")

        build_tile = source_symbols.source_symbol(registry, "hit_tile.build.tile")
        self.assertEqual(build_tile["java_expr"], "build.tile")
        self.assertEqual(build_tile["godot_symbol"], "build_state.tile")

    def test_audit_reports_whole_godot_source_surface(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        audit = source_symbols.audit_godot_source_symbol_coverage(ROOT / "godot-mindustry", registry)

        self.assertGreater(audit["totalSourceFunctions"], 400)
        self.assertEqual(audit["registeredSourceOwnerCount"], 4)
        self.assertEqual(audit["exemptSourceOwnerCount"], 5)
        self.assertEqual(audit["legacyUnregisteredOwnerCount"], audit["totalSourceFunctions"] - 9)
        self.assertIn("PortGame.source_symbol_registry_state", audit["exemptSourceOwners"])
        self.assertIn("PortGame.source_symbol_audit_state", audit["exemptSourceOwners"])
        self.assertIn("PortGame.source_slice_ledger_state", audit["exemptSourceOwners"])
        self.assertIn("PortGame.source_api_contract_state", audit["exemptSourceOwners"])
        self.assertIn("PortGame.source_state_schema_state", audit["exemptSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_draw_parts_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_test_collision_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_tile_heal_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_tile_fire_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_overdrive_projector_range", audit["legacyUnregisteredOwners"])
        self.assertEqual(audit["policy"]["newSourceOwnerRequiresRegistry"], True)

    def test_audit_report_file_matches_current_godot_source(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        expected = source_symbols.audit_godot_source_symbol_coverage(ROOT / "godot-mindustry", registry)
        actual = source_symbols.load_source_symbol_audit_report(ROOT / "godot-mindustry")

        self.assertEqual(actual, expected)

    def test_source_slice_ledger_tracks_registered_source_owners(self):
        ledger = source_symbols.load_source_slice_ledger(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_slice_ledger(ledger)

        self.assertEqual(errors, [])
        self.assertTrue(ledger["policy"]["newSliceRequiresLedger"])

        draw_parts = source_symbols.source_slice(ledger, "N399")
        self.assertEqual(draw_parts["java_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(draw_parts["java_method"], "drawParts(Bullet b)")
        self.assertEqual(draw_parts["godot_owner"], "PortGame.source_bullet_type_draw_parts_state")
        self.assertIn("DrawPart.params.set(b.fin(), 0f, 0f, 0f, 0f, 0f, b.x, b.y, b.rotation())", draw_parts["exact_exprs"])

        test_collision = source_symbols.source_slice(ledger, "N401")
        self.assertEqual(test_collision["exact_exprs"], ["return !heals() || tile.team != bullet.team || tile.healthf() < 1f;"])

        hit_tile_heal = source_symbols.source_slice(ledger, "N405")
        self.assertEqual(hit_tile_heal["java_method"], "hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct)")
        self.assertEqual(hit_tile_heal["godot_owner"], "PortGame.source_bullet_type_hit_tile_heal_state")
        self.assertIn("build.heal(healPercent / 100f * build.maxHealth + healAmount)", hit_tile_heal["exact_exprs"])

        hit_tile_fire = source_symbols.source_slice(ledger, "N406")
        self.assertEqual(hit_tile_fire["java_method"], "hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct)")
        self.assertEqual(hit_tile_fire["godot_owner"], "PortGame.source_bullet_type_hit_tile_fire_state")
        self.assertIn("Fires.create(build.tile)", hit_tile_fire["exact_exprs"])

    def test_api_contracts_pin_runtime_params_and_return_keys(self):
        contracts = source_symbols.load_source_api_contracts(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_api_contracts(contracts)

        self.assertEqual(errors, [])
        self.assertTrue(contracts["policy"]["newSourceOwnerRequiresApiContract"])

        contract = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_test_collision_state")
        self.assertEqual([param["name"] for param in contract["params"]], ["bullet_type_state", "bullet_state", "tile_state"])
        self.assertEqual(contract["params"][2]["schema"], "tile_state")
        self.assertIn("collides", contract["return_keys"])
        self.assertIn("tileHealthf", contract["return_keys"])
        self.assertEqual(contract["source_method"], "testCollision(Bullet bullet, Building tile)")

        hit_tile_heal = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_tile_heal_state")
        self.assertEqual([param["name"] for param in hit_tile_heal["params"]], ["bullet_type_state", "bullet_state", "build_state"])
        self.assertEqual(hit_tile_heal["params"][2]["schema"], "build_state")
        self.assertIn("healGatePassed", hit_tile_heal["return_keys"])
        self.assertIn("healAppliedAmount", hit_tile_heal["return_keys"])
        self.assertEqual(hit_tile_heal["source_method"], "hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct)")

        hit_tile_fire = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_tile_fire_state")
        self.assertEqual([param["name"] for param in hit_tile_fire["params"]], ["bullet_type_state", "bullet_state", "build_state"])
        self.assertEqual(hit_tile_fire["params"][2]["schema"], "build_state")
        self.assertIn("fireGatePassed", hit_tile_fire["return_keys"])
        self.assertIn("firesCreateCall", hit_tile_fire["return_keys"])
        self.assertEqual(hit_tile_fire["source_method"], "hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct)")

    def test_state_schema_pins_dictionary_keys_and_aliases(self):
        schema = source_symbols.load_source_state_schema(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_state_schema(schema)

        self.assertEqual(errors, [])
        self.assertTrue(schema["policy"]["newDictionaryKeyRequiresSchema"])

        bullet_state = source_symbols.state_schema(schema, "bullet_state")
        self.assertEqual(bullet_state["keys"]["team"]["java_expr"], "bullet.team")
        self.assertEqual(bullet_state["keys"]["fin"]["java_expr"], "b.fin()")

        tile_state = source_symbols.state_schema(schema, "tile_state")
        self.assertEqual(tile_state["keys"]["healthf"]["java_expr"], "tile.healthf()")
        self.assertEqual(tile_state["keys"]["healthf"]["status"], "explicit-input")

        test_collision_output = source_symbols.state_schema(schema, "test_collision_result")
        self.assertEqual(test_collision_output["keys"]["tileHealthf"]["alias_of"], "tile_state.healthf")

        build_state = source_symbols.state_schema(schema, "build_state")
        self.assertEqual(build_state["keys"]["maxHealth"]["java_expr"], "build.maxHealth")
        self.assertEqual(build_state["keys"]["blockIsConstructBlock"]["java_expr"], "build.block instanceof ConstructBlock")
        self.assertEqual(build_state["keys"]["tile"]["java_expr"], "build.tile")

        hit_tile_output = source_symbols.state_schema(schema, "hit_tile_heal_result")
        self.assertEqual(hit_tile_output["keys"]["healGatePassed"]["java_expr"], "heals() && build.team == b.team && !(build.block instanceof ConstructBlock)")
        self.assertEqual(hit_tile_output["keys"]["healEffectCall"]["java_expr"], "healEffect.at(build.x, build.y, 0f, healColor, build.block)")

        hit_tile_fire_output = source_symbols.state_schema(schema, "hit_tile_fire_result")
        self.assertEqual(hit_tile_fire_output["keys"]["fireGatePassed"]["java_expr"], "makeFire && build.team != b.team")
        self.assertEqual(hit_tile_fire_output["keys"]["firesCreateCall"]["java_expr"], "Fires.create(build.tile)")

    def test_state_schema_rejects_keys_without_source_or_alias(self):
        schema = {
            "version": 1,
            "schemas": {
                "bad_state": {
                    "status": "active",
                    "keys": {
                        "madeUp": {"type": "float", "status": "source-backed"}
                    },
                }
            },
        }

        errors = source_symbols.validate_source_state_schema(schema)

        self.assertIn("bad_state.madeUp: source-backed requires java_source", errors)
        self.assertIn("bad_state.madeUp: source-backed requires java_expr", errors)


if __name__ == "__main__":
    unittest.main()
