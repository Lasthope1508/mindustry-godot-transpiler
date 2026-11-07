from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
PROOF = "/root/Main.BuildingLifecycleStateModuleProof"
TESTS = ["test_building_unit_payload_slice.py", "test_emitter.py", "test_source_parity.py"]


def schema_key(type_name: str, expression: str, rule: str, status: str = "source-backed") -> dict:
    return {
        "type": type_name,
        "status": status,
        "java_source": SOURCE,
        "java_expr": expression,
        "rule": rule,
    }


def register_contract(slice_id: str, owner: str, method: str, expressions: list[str], symbols: list[tuple[str, str, str]]) -> None:
    entries = {
        name: {
            "status": "source-backed",
            "godot_owner": owner,
            "godot_symbol": symbol,
            "rule": rule,
            "tests": TESTS,
            "runtime_proof": PROOF,
            "java_source": SOURCE,
            "java_method": method,
            "java_expr": expression,
        }
        for name, symbol, expression, rule in symbols
    }
    source_symbols.upsert_source_slice(GODOT, slice_id, {
        "status": "done",
        "java_source": SOURCE,
        "java_class": "mindustry.entities.comp.BuildingComp",
        "java_method": method,
        "godot_owner": owner,
        "exact_exprs": expressions,
        "source_symbols": list(entries),
        "tests": TESTS,
        "runtime_proof": PROOF,
        "rule": "Canonical lifecycle contract mirrors the exact BuildingComp method body without adding behavior.",
    })
    source_symbols.upsert_source_symbols(GODOT, entries)


def main() -> None:
    update_payload_owner = "PortGame.source_building_update_payload_state"
    update_payload_method = "updatePayload(Unit unitHolder, Building buildingHolder)"
    update_payload_expressions = [
        "public void updatePayload(@Nullable Unit unitHolder, @Nullable Building buildingHolder){",
        "update();",
    ]
    register_contract("N1901", update_payload_owner, update_payload_method, update_payload_expressions, [
        ("building_update_payload.method", "source_building_update_payload_result.method", update_payload_expressions[0], "updatePayload method boundary."),
        ("building_update_payload.delegate", "source_building_update_payload_result.update_called", update_payload_expressions[1], "updatePayload delegates exactly once to update()."),
    ])
    source_symbols.upsert_source_api_contract(GODOT, update_payload_owner, {
        "status": "active",
        "source_slice": "N1901",
        "java_source": SOURCE,
        "source_method": update_payload_method,
        "params": [
            {"name": "update_state", "type": "Variant", "schema": "source_building_update_payload_input.update_state"},
            {"name": "unit_holder", "type": "Variant", "schema": "source_building_update_payload_input.unit_holder"},
            {"name": "building_holder", "type": "Variant", "schema": "source_building_update_payload_input.building_holder"},
        ],
        "return_keys": ["source_owner", "method", "update_call", "unit_holder", "building_holder", "update_called", "update_state"],
        "tests": TESTS,
        "runtime_proof": PROOF,
        "rule": "Canonical updatePayload delegate preserves both payload holders and the update() delegation result.",
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_update_payload_input", {
        "status": "active", "owner": update_payload_owner, "runtime_proof": PROOF,
        "keys": {
            "update_state": schema_key("Variant", "update();", "Generated update() delegate result.", "explicit-input"),
            "unit_holder": schema_key("Variant", "unitHolder", "Nullable Unit holder.", "explicit-input"),
            "building_holder": schema_key("Variant", "buildingHolder", "Nullable Building holder.", "explicit-input"),
        },
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_update_payload_result", {
        "status": "active", "owner": update_payload_owner, "runtime_proof": PROOF,
        "keys": {
            "method": schema_key("String", update_payload_expressions[0], "Method boundary."),
            "update_call": schema_key("String", update_payload_expressions[1], "Exact delegate expression."),
            "unit_holder": {"type": "Variant", "status": "generated", "alias_of": "source_building_update_payload_input.unit_holder"},
            "building_holder": {"type": "Variant", "status": "generated", "alias_of": "source_building_update_payload_input.building_holder"},
            "update_called": schema_key("bool", update_payload_expressions[1], "Delegate always runs once."),
            "update_state": {"type": "Variant", "status": "generated", "alias_of": "source_building_update_payload_input.update_state"},
        },
    })

    update_tile_owner = "PortGame.source_building_update_tile_noop_state"
    update_tile_method = "updateTile()"
    update_tile_expressions = ["public void updateTile(){"]
    register_contract("N1902", update_tile_owner, update_tile_method, update_tile_expressions, [
        ("building_update_tile_noop.method", "source_building_update_tile_noop_result.method", update_tile_expressions[0], "Empty updateTile method boundary."),
    ])
    source_symbols.upsert_source_api_contract(GODOT, update_tile_owner, {
        "status": "active",
        "source_slice": "N1902",
        "java_source": SOURCE,
        "source_method": update_tile_method,
        "params": [],
        "return_keys": ["source_owner", "method", "no_op"],
        "tests": TESTS,
        "runtime_proof": PROOF,
        "rule": "Canonical explicit no-op for the empty BuildingComp.updateTile base hook.",
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_update_tile_noop_result", {
        "status": "active", "owner": update_tile_owner, "runtime_proof": PROOF,
        "keys": {
            "method": schema_key("String", update_tile_expressions[0], "Method boundary."),
            "no_op": schema_key("bool", update_tile_expressions[0], "Source body is intentionally empty."),
        },
    })
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
