from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
PROOF = "/root/Main.BuildingUnitPayloadModuleProof"
OWNER = "PortGame.source_building_handle_unit_payload_state"
SLICE = "N1899"
METHOD = "handleUnitPayload(Unit, Cons<Payload>)"
TESTS = ["test_building_unit_payload_slice.py"]


def schema_key(type_name: str, status: str, expression: str, rule: str) -> dict:
    return {
        "type": type_name,
        "status": status,
        "java_source": SOURCE,
        "java_method": METHOD,
        "java_expr": expression,
        "rule": rule,
    }


def symbol(name: str, godot_symbol: str, expression: str, rule: str, status: str = "source-backed") -> tuple[str, dict]:
    return name, {
        "status": status,
        "godot_owner": OWNER,
        "godot_symbol": godot_symbol,
        "rule": rule,
        "tests": TESTS,
        "runtime_proof": PROOF,
        "java_source": SOURCE,
        "java_method": METHOD,
        "java_expr": expression,
    }


def main() -> None:
    expressions = [
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
    symbols = [
        symbol("building_handle_unit_payload.method", "source_building_handle_unit_payload_result.method", expressions[0], "BuildingComp unit payload method boundary."),
        symbol("building_handle_unit_payload.spawn", "source_building_handle_unit_payload_result.spawn_called", expressions[1], "Spawn effect runs before unit conversion."),
        symbol("building_handle_unit_payload.player_clear_unit", "source_building_handle_unit_payload_result.clear_unit_called", expressions[3], "Player unit is cleared before removal."),
        symbol("building_handle_unit_payload.remove", "source_building_handle_unit_payload_result.remove_called", expressions[4], "Unit removal occurs before payload construction."),
        symbol("building_handle_unit_payload.client_id", "source_building_handle_unit_payload_result.unit_id_assigned_immediately", expressions[6], "Client assigns the payload unit ID immediately."),
        symbol("building_handle_unit_payload.server_id", "source_building_handle_unit_payload_result.unit_id_assignment_deferred", expressions[7], "Server defers the payload unit ID assignment to the next frame."),
        symbol("building_handle_unit_payload.grabber", "source_building_handle_unit_payload_result.payload", expressions[8], "Payload grabber receives the constructed UnitPayload."),
        symbol("building_handle_unit_payload.unit_drop", "source_building_handle_unit_payload_result.unit_drop_called", expressions[9], "Unit-drop effect runs after the payload grabber."),
    ]
    source_symbols.upsert_source_slice(GODOT, SLICE, {
        "status": "done",
        "java_source": SOURCE,
        "java_class": "mindustry.entities.comp.BuildingComp",
        "java_method": METHOD,
        "godot_owner": OWNER,
        "exact_exprs": expressions,
        "source_symbols": [name for name, _entry in symbols],
        "tests": TESTS,
        "runtime_proof": PROOF,
        "rule": "Canonical source-backed Unit to UnitPayload conversion preserves source effect ordering and client/server ID timing.",
    })
    source_symbols.upsert_source_api_contract(GODOT, OWNER, {
        "status": "active",
        "source_slice": SLICE,
        "java_source": SOURCE,
        "source_method": METHOD,
        "params": [
            {"name": "unit", "type": "Variant", "schema": "source_building_handle_unit_payload_input.unit"},
            {"name": "grabber", "type": "Callable", "schema": "source_building_handle_unit_payload_input.grabber"},
            {"name": "dependencies", "type": "Dictionary", "schema": "source_building_handle_unit_payload_input.dependencies"},
        ],
        "return_keys": ["source_owner", "source", "method", "payload", "call_order", "spawn_called", "clear_unit_called", "remove_called", "unit_id_assigned_immediately", "unit_id_assignment_deferred", "grabber_called", "unit_drop_called", "missing_dependencies"],
        "tests": TESTS,
        "runtime_proof": PROOF,
        "rule": "Canonical BuildingComp unit payload conversion contract; runtime effects are explicit callback dependencies.",
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_handle_unit_payload_input", {
        "status": "active",
        "owner": OWNER,
        "runtime_proof": PROOF,
        "keys": {
            "unit": schema_key("Variant", "explicit-input", "unit", "Unit converted to a payload."),
            "grabber": schema_key("Callable", "explicit-input", "grabber", "Cons<Payload>.get callback."),
            "dependencies": schema_key("Dictionary", "explicit-input", "Fx, net, EntityGroup, Core.app, and unit lifecycle dependencies.", "Explicit runtime callback dependencies."),
        },
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_handle_unit_payload_result", {
        "status": "active",
        "owner": OWNER,
        "runtime_proof": PROOF,
        "keys": {
            "method": schema_key("String", "source-backed", expressions[0], "Method boundary."),
            "payload": schema_key("Dictionary", "source-backed", expressions[8], "Constructed UnitPayload state."),
            "call_order": schema_key("Array", "source-backed", expressions[0], "Observed source side-effect ordering."),
            "spawn_called": schema_key("bool", "source-backed", expressions[1], "Spawn effect invocation."),
            "clear_unit_called": schema_key("bool", "source-backed", expressions[3], "Conditional player clear invocation."),
            "remove_called": schema_key("bool", "source-backed", expressions[4], "Unit removal invocation."),
            "unit_id_assigned_immediately": schema_key("bool", "source-backed", expressions[6], "Client ID assignment invocation."),
            "unit_id_assignment_deferred": schema_key("bool", "source-backed", expressions[7], "Server deferred ID assignment scheduling."),
            "grabber_called": schema_key("bool", "source-backed", expressions[8], "Payload grabber invocation."),
            "unit_drop_called": schema_key("bool", "source-backed", expressions[9], "Unit-drop effect invocation."),
            "missing_dependencies": schema_key("Array", "source-backed", expressions[0], "Missing explicit callback dependencies."),
        },
    })
    source_symbols.upsert_source_symbols(GODOT, dict(symbols))
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
