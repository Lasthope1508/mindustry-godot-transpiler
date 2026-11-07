import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"
GENERATED = PROJECT / "src" / "generated"
UPSTREAM = ROOT / "mindustry-upstream"


class BuildingUnitPayloadSliceTests(unittest.TestCase):
    def test_building_update_payload_delegates_to_update_and_update_tile_is_source_noop(self):
        source = (UPSTREAM / "core" / "src" / "mindustry" / "entities" / "comp" / "BuildingComp.java").read_text(encoding="utf-8")
        generated = (GENERATED / "classes" / "mindustry" / "entities" / "comp" / "BuildingComp.gd").read_text(encoding="utf-8")
        lifecycle_state = (PROJECT / "src" / "game" / "SourceBuildingLifecycleState.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceBuildingLifecycleSourceTextState.gd").read_text(encoding="utf-8")

        for expression in (
            "public void updatePayload(@Nullable Unit unitHolder, @Nullable Building buildingHolder){",
            "update();",
            "public void updateTile(){",
        ):
            with self.subTest(expression=expression):
                self.assertIn(expression, source)
                self.assertIn(expression, source_text)

        update_payload_start = generated.index("func java_method_updatePayload_195")
        update_payload_end = generated.index("\nfunc ", update_payload_start + 1)
        update_payload_body = generated[update_payload_start:update_payload_end]
        self.assertIn("var update_state = java_method_update_217([])", update_payload_body)
        self.assertIn("return source_building_lifecycle_state.update_payload_state(update_state, unit_holder, building_holder)", update_payload_body)
        self.assertNotIn("return null", update_payload_body)

        update_tile_start = generated.index("func java_method_updateTile_196")
        update_tile_end = generated.index("\nfunc ", update_tile_start + 1)
        update_tile_body = generated[update_tile_start:update_tile_end]
        self.assertIn("return source_building_lifecycle_state.update_tile_noop_state()", update_tile_body)
        self.assertNotIn("return null", update_tile_body)
        self.assertIn("static func update_payload_state(", lifecycle_state)
        self.assertIn("static func update_tile_noop_state()", lifecycle_state)

    def test_building_update_payload_and_noop_tile_are_registered_and_proven(self):
        registry = json.loads((GENERATED / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        schemas = json.loads((GENERATED / "source_state_schema.json").read_text(encoding="utf-8"))["schemas"]
        proof = (PROJECT / "tools" / "runtime_proofs" / "BuildingLifecycleStateModuleProof.gd").read_text(encoding="utf-8")

        self.assertEqual(ledger["N1901"]["godot_owner"], "PortGame.source_building_update_payload_state")
        self.assertEqual(ledger["N1902"]["godot_owner"], "PortGame.source_building_update_tile_noop_state")
        self.assertEqual(contracts["PortGame.source_building_update_payload_state"]["source_slice"], "N1901")
        self.assertEqual(contracts["PortGame.source_building_update_tile_noop_state"]["source_slice"], "N1902")
        self.assertEqual(schemas["source_building_update_payload_result"]["owner"], "PortGame.source_building_update_payload_state")
        self.assertEqual(schemas["source_building_update_tile_noop_result"]["owner"], "PortGame.source_building_update_tile_noop_state")
        self.assertEqual(registry["building_update_payload.delegate"]["godot_owner"], "PortGame.source_building_update_payload_state")
        self.assertEqual(registry["building_update_tile_noop.method"]["godot_owner"], "PortGame.source_building_update_tile_noop_state")
        self.assertIn("generated_building_comp_update_payload_bridge_state", proof)
        self.assertIn("generated_building_comp_update_tile_noop_bridge_state", proof)

    def test_handle_unit_payload_preserves_the_upstream_side_effect_order(self):
        source = (UPSTREAM / "core" / "src" / "mindustry" / "entities" / "comp" / "BuildingComp.java").read_text(encoding="utf-8")
        state = (PROJECT / "src" / "game" / "SourceBuildingPayloadState.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceBuildingPayloadSourceTextState.gd").read_text(encoding="utf-8")

        expected = [
            "public void handleUnitPayload(Unit unit, Cons<Payload> grabber){",
            "Fx.spawn.at(unit);",
            "if(unit.isPlayer()){",
            "unit.getPlayer().clearUnit();",
            "unit.remove();",
            "if(net.client()){",
            "unit.id = EntityGroup.nextId();",
            "Core.app.post(() -> unit.id = EntityGroup.nextId());",
            "grabber.get(new UnitPayload(unit));",
            "Fx.unitDrop.at(unit);",
        ]
        for expression in expected:
            with self.subTest(expression=expression):
                self.assertIn(expression, source)
                self.assertIn(expression, source_text)

        self.assertIn("static func handle_unit_payload_state(", state)
        self.assertIn("SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CALL_ORDER", state)
        self.assertIn("source_unit_payload_basic_state.constructor_state(unit)", state)
        for name in (
            "SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_SPAWN_EXPR",
            "SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLEAR_UNIT_EXPR",
            "SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_REMOVE_EXPR",
            "SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_SERVER_ID_EXPR",
            "SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_GRABBER_EXPR",
            "SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_UNIT_DROP_EXPR",
        ):
            self.assertIn(f"const {name} := source_building_payload_source_text_state.{name}", state)

    def test_generated_building_comp_delegates_to_the_canonical_payload_owner(self):
        generated = (GENERATED / "classes" / "mindustry" / "entities" / "comp" / "BuildingComp.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src" / "game" / "SourceBuildingPayloadState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src" / "game" / "SourceBuildingItemPayloadPortBridge.gd").read_text(encoding="utf-8")

        start = generated.index("func java_method_handleUnitPayload_63")
        end = generated.index("\nfunc ", start + 1)
        body = generated[start:end]
        self.assertIn('const source_building_payload_state := preload("res://src/game/SourceBuildingPayloadState.gd")', generated)
        self.assertIn("return source_building_payload_state.handle_unit_payload_state(unit, grabber, dependencies)", body)
        self.assertNotIn("return null", body)
        self.assertIn("static func generated_handle_unit_payload_bridge_state(", state)
        self.assertIn("func source_building_handle_unit_payload_state(", bridge)
        self.assertIn("func generated_building_comp_handle_unit_payload_bridge_state(", bridge)

    def test_generated_building_comp_dispatches_existing_payload_contracts(self):
        generated = (GENERATED / "classes" / "mindustry" / "entities" / "comp" / "BuildingComp.gd").read_text(encoding="utf-8")

        expected_dispatches = {
            "java_method_acceptPayload_82": "source_building_payload_state.accept_payload_state()",
            "java_method_handlePayload_83": "source_building_payload_state.handle_payload_state(payload_state)",
            "java_method_movePayload_84": "source_building_payload_state.move_payload_state(has_next_tile, has_next_build, same_team, accepts_payload)",
            "java_method_dumpPayload_85": 'source_building_payload_state.dump_payload_state(proximity_size, dump_cursor, accepts_payload_by_index, Callable(SourceBuildingItemDumpState, "increment_dump_cursor_state"))',
            "java_method_getPayload_99": "source_building_payload_state.get_payload_default_state()",
            "java_method_takePayload_100": "source_building_payload_state.take_payload_default_state()",
            "java_method_getPayloads_101": "source_building_payload_state.get_payloads_default_state()",
        }
        for method, dispatch in expected_dispatches.items():
            start = generated.index("func %s" % method)
            end = generated.find("\nfunc ", start + 1)
            body = generated[start:end if end != -1 else None]
            self.assertIn(dispatch, body)
            self.assertNotIn("return null", body)

    def test_generated_building_comp_dispatches_existing_item_contracts(self):
        generated = (GENERATED / "classes" / "mindustry" / "entities" / "comp" / "BuildingComp.gd").read_text(encoding="utf-8")
        item_state = (PROJECT / "src" / "game" / "SourceBuildingItemState.gd").read_text(encoding="utf-8")

        self.assertIn("static func handle_item_count(current_count: int) -> int:", item_state)

        expected_dispatches = {
            "java_method_acceptStack_77": "source_building_item_state.accept_stack_state(accepts_item, has_items, same_team_or_null_source, maximum_accepted, item_count, amount)",
            "java_method_getMaximumAccepted_78": "source_building_item_state.maximum_accepted(block_item_capacity)",
            "java_method_removeStack_79": "source_building_item_state.remove_stack_state(has_items_module, item_count, amount)",
            "java_method_handleStack_80": "source_building_item_state.handle_stack_count(current_count, amount)",
            "java_method_handleItem_87": "source_building_item_state.handle_item_count(current_count)",
            "java_method_acceptItem_88": "source_building_item_state.accept_item_state(consumes_item, item_count, maximum_accepted)",
        }
        for method, dispatch in expected_dispatches.items():
            start = generated.index("func %s" % method)
            end = generated.find("\nfunc ", start + 1)
            body = generated[start:end if end != -1 else None]
            self.assertIn(dispatch, body)
            self.assertNotIn("return null", body)

    def test_generated_building_comp_dispatches_can_be_replaced_contract(self):
        generated = (GENERATED / "classes" / "mindustry" / "entities" / "comp" / "BuildingComp.gd").read_text(encoding="utf-8")
        start = generated.index("func java_method_canBeReplaced_86")
        end = generated.find("\nfunc ", start + 1)
        body = generated[start:end if end != -1 else None]

        self.assertIn("source_building_core_state.building_can_be_replaced_state(other_can_replace_block)", body)
        self.assertNotIn("return null", body)

    def test_generated_building_comp_dispatches_existing_liquid_contracts(self):
        generated = (GENERATED / "classes" / "mindustry" / "entities" / "comp" / "BuildingComp.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "BuildingLiquidStateModuleProof.gd").read_text(encoding="utf-8")

        self.assertIn(
            'const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")',
            generated,
        )
        expected_dispatches = {
            "java_method_acceptLiquid_89": "source_building_liquid_state.accept_liquid_state(has_liquids, consumes_liquid)",
            "java_method_handleLiquid_90": "source_building_liquid_state.handle_liquid_amount(current_liquid_amount, amount)",
            "java_method_canDumpLiquid_94": "source_building_liquid_state.can_dump_liquid_default_state(to_state, liquid)",
            "java_method_transferLiquid_95": "source_building_liquid_state.transfer_liquid_state(liquid, amount, next_block_liquid_capacity, next_liquid_amount, next_accepts_liquid, current_liquid_amount)",
            "java_method_moveLiquidForward_96": "source_building_liquid_state.move_liquid_forward_state(leaks, liquid, next_tile_present, next_build_present, next_block_solid, next_block_has_liquids, current_liquid_amount, move_liquid_return)",
            "java_method_moveLiquid_97": "source_building_liquid_state.move_liquid_state(liquid, next_present, destination_team_matches, destination_block_has_liquids, current_liquid_amount, destination_liquid_amount, source_block_liquid_capacity, source_block_liquid_pressure, destination_block_liquid_capacity, destination_accepts_liquid)",
            "java_method_getLiquidDestination_98": "source_building_liquid_state.get_liquid_destination_default_state(from_state, liquid, self_state)",
        }
        for method, dispatch in expected_dispatches.items():
            start = generated.index("func %s" % method)
            end = generated.find("\nfunc ", start + 1)
            body = generated[start:end if end != -1 else None]
            self.assertIn(dispatch, body)
            self.assertNotIn("return null", body)

        self.assertIn("generated_building_comp.java_method_acceptLiquid_89", proof)
        self.assertIn("generated_building_comp.java_method_moveLiquid_97", proof)
        self.assertIn('"generated_liquid_contracts_match"', proof)

    def test_generated_building_comp_dispatches_all_dump_liquid_overloads_to_one_canonical_contract(self):
        generated = (GENERATED / "classes" / "mindustry" / "entities" / "comp" / "BuildingComp.gd").read_text(encoding="utf-8")
        liquid_state = (PROJECT / "src" / "game" / "SourceBuildingLiquidState.gd").read_text(encoding="utf-8")
        dump_state = (PROJECT / "src" / "game" / "SourceBuildingLiquidDumpState.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "BuildingLiquidStateModuleProof.gd").read_text(encoding="utf-8")

        self.assertIn("static func dump_liquid_state(", liquid_state)
        self.assertIn("static func dump_liquid_state(", dump_state)
        for method in (
            "java_method_dumpLiquid_91",
            "java_method_dumpLiquid_92",
            "java_method_dumpLiquid_93",
        ):
            start = generated.index("func %s" % method)
            end = generated.find("\nfunc ", start + 1)
            body = generated[start:end if end != -1 else None]
            with self.subTest(method=method):
                self.assertIn("source_building_liquid_state.dump_liquid_state(", body)
                self.assertNotIn("return null", body)

        self.assertIn("generated_building_comp.java_method_dumpLiquid_91", proof)
        self.assertIn("generated_building_comp.java_method_dumpLiquid_92", proof)
        self.assertIn("generated_building_comp.java_method_dumpLiquid_93", proof)

    def test_dump_liquid_composite_contract_is_registered_through_canonical_ssot(self):
        registry = json.loads((GENERATED / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        schemas = json.loads((GENERATED / "source_state_schema.json").read_text(encoding="utf-8"))["schemas"]

        owner = "PortGame.source_building_dump_liquid_state"
        self.assertEqual(ledger["N1900"]["godot_owner"], owner)
        self.assertEqual(ledger["N1900"]["status"], "done")
        self.assertEqual(contracts[owner]["source_slice"], "N1900")
        self.assertEqual(schemas["source_building_dump_liquid_input"]["owner"], owner)
        self.assertEqual(schemas["source_building_dump_liquid_result"]["owner"], owner)
        self.assertEqual(registry["building_dump_liquid.transfer"]["godot_owner"], owner)
        self.assertEqual(registry["building_dump_liquid.transfer"]["status"], "source-backed")

    def test_handle_unit_payload_symbols_contract_schema_and_slice_are_registered(self):
        registry = json.loads((GENERATED / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        schemas = json.loads((GENERATED / "source_state_schema.json").read_text(encoding="utf-8"))["schemas"]

        owner = "PortGame.source_building_handle_unit_payload_state"
        for symbol in (
            "building_handle_unit_payload.method",
            "building_handle_unit_payload.spawn",
            "building_handle_unit_payload.player_clear_unit",
            "building_handle_unit_payload.remove",
            "building_handle_unit_payload.client_id",
            "building_handle_unit_payload.server_id",
            "building_handle_unit_payload.grabber",
            "building_handle_unit_payload.unit_drop",
        ):
            with self.subTest(symbol=symbol):
                self.assertEqual(registry[symbol]["godot_owner"], owner)
                self.assertEqual(registry[symbol]["status"], "source-backed")

        self.assertEqual(ledger["N1899"]["godot_owner"], owner)
        self.assertEqual(ledger["N1899"]["status"], "done")
        self.assertEqual(contracts[owner]["source_slice"], "N1899")
        self.assertEqual(schemas["source_building_handle_unit_payload_result"]["owner"], owner)

    def test_runtime_proof_exercises_client_and_deferred_server_id_paths(self):
        proof = (PROJECT / "tools" / "runtime_proofs" / "BuildingUnitPayloadModuleProof.gd").read_text(encoding="utf-8")

        self.assertIn("generated_building_comp_handle_unit_payload_bridge_state", proof)
        self.assertIn('"client"', proof)
        self.assertIn('"server"', proof)
        self.assertIn('"matches"', proof)
        self.assertIn('runtime_proof_state.write_proof("BuildingUnitPayloadModuleProof", proof)', proof)


if __name__ == "__main__":
    unittest.main()
