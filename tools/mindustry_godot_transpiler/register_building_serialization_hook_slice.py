from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
OWNER = "PortGame.source_building_serialization_hook_state"
PROOF = "/root/Main.BuildingLifecycleStateModuleProof"
TESTS = ["test_building_lifecycle_serialization_slice.py", "test_emitter.py", "test_source_parity.py"]


def main() -> None:
    definitions = [
        ("N1911", "write(Writes)", "public void write(Writes write){", "building_write_hook", "Empty base serialization write hook reserved for subclasses."),
        ("N1912", "read(Reads,byte)", "public void read(Reads read, byte revision){", "building_read_hook", "Empty base serialization read hook reserved for subclasses."),
    ]
    symbols = {}
    for slice_id, method, expression, prefix, rule in definitions:
        symbol_name = f"{prefix}.method"
        symbols[symbol_name] = {
            "status": "source-backed", "godot_owner": OWNER, "godot_symbol": f"source_building_serialization_hook_result.{prefix}", "rule": rule,
            "tests": TESTS, "runtime_proof": PROOF, "java_source": SOURCE, "java_method": method, "java_expr": expression,
        }
        source_symbols.upsert_source_slice(GODOT, slice_id, {
            "status": "done", "java_source": SOURCE, "java_class": "mindustry.entities.comp.BuildingComp", "java_method": method,
            "godot_owner": OWNER, "exact_exprs": [expression], "source_symbols": [symbol_name], "tests": TESTS,
            "runtime_proof": PROOF, "rule": rule,
        })
    source_symbols.upsert_source_api_contract(GODOT, OWNER, {
        "status": "active", "source_slice": "N1911", "java_source": SOURCE, "source_method": "write(Writes)/read(Reads,byte)",
        "params": [{"name": "write_or_read", "type": "Variant", "schema": "source_building_serialization_hook_input.write_or_read"}],
        "return_keys": ["source_owner", "method", "no_op"], "tests": TESTS, "runtime_proof": PROOF,
        "rule": "Canonical explicit no-op preserves the superclass extension-hook contract without inventing serialization work.",
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_serialization_hook_input", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {"write_or_read": {"type": "Variant", "status": "explicit-input", "java_source": SOURCE, "java_expr": "Writes write / Reads read", "rule": "Opaque serialization callback dependency."}},
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_serialization_hook_result", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            "method": {"type": "String", "status": "source-backed", "java_source": SOURCE, "java_expr": "public void write(Writes write){", "rule": "Hook method boundary."},
            "no_op": {"type": "bool", "status": "source-backed", "java_source": SOURCE, "java_expr": "public void read(Reads read, byte revision){", "rule": "Base hook body is intentionally empty."},
        },
    })
    source_symbols.upsert_source_symbols(GODOT, symbols)
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
