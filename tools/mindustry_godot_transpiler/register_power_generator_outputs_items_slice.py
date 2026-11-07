from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/power/PowerGenerator.java"
OWNER = "PortGame.source_power_generator_outputs_items_state"
PROOF = "/root/Main.source_power_generator_outputs_items_state"
METHOD = "outputsItems()"
SLICE = "N1923"


def source_key(type_name: str, expression: str, rule: str) -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": SOURCE,
        "java_method": METHOD,
        "java_expr": expression,
        "rule": rule,
        "used_by": [OWNER.lower()],
    }


def main() -> None:
    symbols = {
        "power_generator_outputs_items.method": {
            "godot_owner": OWNER,
            "godot_symbol": "source_power_generator_outputs_items_result.method",
            "java_expr": "public boolean outputsItems(){",
            "java_method": METHOD,
            "java_source": SOURCE,
            "rule": "PowerGenerator.outputsItems method boundary.",
            "runtime_proof": PROOF,
            "source_slice": SLICE,
            "status": "source-backed",
            "tests": ["test_power_generator_outputs_items_matches_upstream_source"],
        },
        "power_generator_outputs_items.return_false": {
            "godot_owner": OWNER,
            "godot_symbol": "source_power_generator_outputs_items_result.outputs_items",
            "java_expr": "return false;",
            "java_method": METHOD,
            "java_source": SOURCE,
            "rule": "PowerGenerator does not output items.",
            "runtime_proof": PROOF,
            "source_slice": SLICE,
            "status": "source-backed",
            "tests": ["test_power_generator_outputs_items_matches_upstream_source"],
        },
    }
    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.upsert_source_slice(GODOT, SLICE, {
        "exact_exprs": ["public boolean outputsItems(){", "return false;"],
        "deferred_exprs": ["PowerGenerator item-output routing remains false by upstream contract."],
        "godot_owner": OWNER,
        "java_class": "mindustry.world.blocks.power.PowerGenerator",
        "java_method": METHOD,
        "java_source": SOURCE,
        "rule": "Registers the source-backed PowerGenerator.outputsItems constant state.",
        "runtime_proof": PROOF,
        "source_symbols": list(symbols),
        "status": "done",
        "tests": ["test_power_generator_outputs_items_matches_upstream_source"],
    })
    source_symbols.upsert_source_api_contract(GODOT, OWNER, {
        "java_source": SOURCE,
        "params": [],
        "return_keys": ["method", "return_expr", "outputs_items"],
        "rule": "Public runtime contract for PowerGenerator.outputsItems constant false state.",
        "runtime_proof": PROOF,
        "source_method": METHOD,
        "source_slice": SLICE,
        "status": "source-backed",
        "tests": ["test_power_generator_outputs_items_matches_upstream_source"],
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_power_generator_outputs_items_result", {
        "keys": {
            "method": source_key("String", "public boolean outputsItems(){", "Result preserves the PowerGenerator method boundary."),
            "return_expr": source_key("String", "return false;", "Result preserves the exact false return expression."),
            "outputs_items": source_key("bool", "return false;", "Canonical PowerGenerator item-output result."),
        },
        "owner": OWNER,
        "rule": "Result schema for PowerGenerator.outputsItems constant false state.",
        "runtime_proof": PROOF,
        "source_slice": SLICE,
        "status": "source-backed",
    })
    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
