"""Register the empty BuildingComp base callbacks as one lifecycle capability."""

from pathlib import Path

from mindustry_port import source_ssot, source_symbols

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
OWNER = "PortGame.source_building_empty_lifecycle_callbacks_state"
PROOF = "/root/Main.BuildingLifecycleStateModuleProof"
TESTS = ["test_building_empty_lifecycle_callbacks_slice.py", "test_source_catalog_validator.py"]
CALLBACKS = {
    "item_taken": ("itemTaken(Item)", "public void itemTaken(Item item){\n\n    }"),
    "dropped": ("dropped()", "public void dropped(){\n\n    }"),
    "handle_string": ("handleString(Object)", "public void handleString(Object value){\n\n    }"),
    "created": ("created()", "public void created(){}"),
    "get_stack_offset": ("getStackOffset(Item,Vec2)", "public void getStackOffset(Item item, Vec2 trns){\n\n    }"),
}


def field(type_name: str, status: str, expression: str, rule: str) -> dict:
    return {
        "type": type_name, "status": status, "java_source": SOURCE,
        "java_method": ", ".join(method for method, _ in CALLBACKS.values()),
        "java_expr": expression, "rule": rule, "used_by": [OWNER.lower()],
    }


def main() -> None:
    java = (ROOT / "mindustry-upstream" / SOURCE).read_text(encoding="utf-8")
    for _, expression in CALLBACKS.values():
        if expression not in java:
            raise ValueError(f"Empty callback source evidence drifted: {expression}")
    result_name = "source_building_empty_lifecycle_callbacks_result"
    input_name = "source_building_empty_lifecycle_callbacks_input"
    symbols = {
        f"building_empty_lifecycle_callbacks.{name}": {
            "status": "source-backed", "source_slice": "N1952", "godot_owner": OWNER,
            "godot_symbol": f"{result_name}.method", "java_source": SOURCE,
            "java_method": method, "java_expr": expression, "tests": TESTS, "runtime_proof": PROOF,
            "rule": "Empty superclass body; subclass overrides are outside this slice.",
        }
        for name, (method, expression) in CALLBACKS.items()
    }
    source_symbols.upsert_source_slice(GODOT, "N1952", {
        "status": "done", "coverage_kind": "empty-source-body", "java_source": SOURCE,
        "java_class": "mindustry.entities.comp.BuildingComp",
        "java_method": ", ".join(method for method, _ in CALLBACKS.values()), "godot_owner": OWNER,
        "exact_exprs": [expression for _, expression in CALLBACKS.values()],
        "source_symbols": list(symbols), "tests": TESTS, "runtime_proof": PROOF,
        "deferred_exprs": ["Concrete subclass overrides and integration into caller dispatch are outside this base callback slice."],
        "rule": "One lifecycle owner records five empty base callbacks without mutating arguments or inventing stack offsets, item transfer, payload or logic behavior.",
    })
    source_symbols.upsert_source_api_contract(GODOT, OWNER, {
        "status": "active", "source_slice": "N1952", "java_source": SOURCE,
        "source_method": ", ".join(method for method, _ in CALLBACKS.values()),
        "params": [{"name": "generated_method", "type": "String", "schema": f"{input_name}.generated_method"}],
        "return_keys": ["source_owner", "method", "no_op"], "tests": TESTS, "runtime_proof": PROOF,
        "rule": "Generated method selects one of five source-backed empty boundaries; Java arguments are unused by the empty body.",
    })
    expressions = " / ".join(expression for _, expression in CALLBACKS.values())
    source_symbols.upsert_source_state_schema(GODOT, input_name, {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {"generated_method": field("String", "generated", expressions, "Allowlisted generated callback identity; transport metadata, not a new Java parameter.")},
    })
    source_symbols.upsert_source_state_schema(GODOT, result_name, {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            "source_owner": field("String", "generated", OWNER, "Canonical lifecycle owner marker."),
            "method": field("String", "source-backed", expressions, "Exact selected Java empty body."),
            "no_op": field("bool", "source-backed", expressions, "No assignment, call, or returned value in any selected base body."),
        },
    })
    source_symbols.upsert_source_state_schema(GODOT, "generated_building_comp_empty_lifecycle_callbacks_bridge_result", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            "source_owner": field("String", "generated", OWNER, "Canonical owner marker."),
            "result": field("Dictionary", "generated", expressions, "Actual generated method result."),
            "canonical": field("Dictionary", "generated", expressions, "Canonical result for exact equality."),
            "matches": field("bool", "generated", expressions, "Strict full-dictionary equality, with null rejected."),
        },
    })
    source_symbols.upsert_source_symbols(GODOT, symbols)
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)
    policy_names = ("registry", "audit_report", "slice_ledger", "state_schema", "module_manifest")
    source_ssot.write_registered_json(GODOT, "source_root_policies", {
        "version": 1, "policies": {name: source_ssot.load_registered_json(GODOT, name).get("policy", {}) for name in policy_names},
    })


if __name__ == "__main__":
    main()
