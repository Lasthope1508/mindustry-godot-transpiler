from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
OWNER = "PortGame.source_building_heal_suppression_state"
PROOF = "/root/Main.BuildingLifecycleStateModuleProof"
TESTS = ["test_building_heal_suppression_slice.py", "test_source_symbols.py"]


def field(type_name: str, status: str, method: str, expr: str, rule: str, alias_of: str | None = None) -> dict:
    value = {"type": type_name, "status": status, "java_source": SOURCE, "java_method": method, "java_expr": expr, "rule": rule}
    if alias_of:
        value["alias_of"] = alias_of
    return value


def main() -> None:
    method = "applyHealSuppression(float), applyHealSuppression(float, Color)"
    input_name = "source_building_heal_suppression_input"
    result_name = "source_building_heal_suppression_result"
    symbols = {
        "building_heal_suppression.method": {"status": "source-backed", "godot_owner": OWNER, "godot_symbol": f"{result_name}.method", "java_source": SOURCE, "java_method": method, "java_expr": "public void applyHealSuppression(float amount, Color suppressColor){", "rule": "Overload boundary.", "tests": TESTS, "runtime_proof": PROOF},
        "building_heal_suppression.default_color": {"status": "source-backed", "godot_owner": OWNER, "godot_symbol": f"{result_name}.suppress_color", "java_source": SOURCE, "java_method": "applyHealSuppression(float)", "java_expr": "applyHealSuppression(amount, Pal.sapBullet);", "rule": "Default overload color.", "tests": TESTS, "runtime_proof": PROOF},
        "building_heal_suppression.time_assignment": {"status": "source-backed", "godot_owner": OWNER, "godot_symbol": f"{result_name}.heal_suppression_time_after", "java_source": SOURCE, "java_method": "applyHealSuppression(float, Color)", "java_expr": "healSuppressionTime = Math.max(healSuppressionTime, Time.time + amount);", "rule": "Maximum suppression expiry assignment.", "tests": TESTS, "runtime_proof": PROOF},
        "building_heal_suppression.color_assignment": {"status": "source-backed", "godot_owner": OWNER, "godot_symbol": f"{result_name}.suppress_color", "java_source": SOURCE, "java_method": "applyHealSuppression(float, Color)", "java_expr": "this.suppressColor = suppressColor;", "rule": "Suppression color assignment.", "tests": TESTS, "runtime_proof": PROOF},
    }
    source_symbols.upsert_source_slice(GODOT, "N1951", {"status": "done", "java_source": SOURCE, "java_class": "mindustry.entities.comp.BuildingComp", "java_method": method, "godot_owner": OWNER, "exact_exprs": ["public void applyHealSuppression(float amount){", "applyHealSuppression(amount, Pal.sapBullet);", "public void applyHealSuppression(float amount, Color suppressColor){", "healSuppressionTime = Math.max(healSuppressionTime, Time.time + amount);", "this.suppressColor = suppressColor;"], "source_symbols": list(symbols), "tests": TESTS, "runtime_proof": PROOF, "rule": "Canonical Building lifecycle health-suppression mutation preserves both overloads and source max assignment."})
    source_symbols.upsert_source_api_contract(GODOT, OWNER, {"status": "active", "source_slice": "N1951", "java_source": SOURCE, "source_method": method, "params": [{"name": "heal_suppression_time", "type": "float", "schema": f"{input_name}.heal_suppression_time"}, {"name": "source_time", "type": "float", "schema": f"{input_name}.source_time"}, {"name": "amount", "type": "float", "schema": f"{input_name}.amount"}, {"name": "suppress_color", "type": "Variant", "schema": f"{input_name}.suppress_color"}], "return_keys": ["source_owner", "method", "heal_suppression_time_before", "source_time", "amount", "heal_suppression_time_after", "suppress_color", "updated"], "tests": TESTS, "runtime_proof": PROOF, "rule": "Public health-suppression mutation contract with explicit clock, expiry, amount, and color inputs."})
    source_symbols.upsert_source_state_schema(GODOT, input_name, {"status": "active", "owner": OWNER, "runtime_proof": PROOF, "keys": {"heal_suppression_time": field("float", "explicit-input", method, "healSuppressionTime", "Existing suppression expiry."), "source_time": field("float", "explicit-input", method, "Time.time", "Explicit source clock."), "amount": field("float", "explicit-input", method, "amount", "Suppression duration amount."), "suppress_color": field("Variant", "explicit-input", method, "suppressColor", "Color overload input or Pal.sapBullet default.")}})
    source_symbols.upsert_source_state_schema(GODOT, result_name, {"status": "active", "owner": OWNER, "runtime_proof": PROOF, "keys": {"source_owner": field("String", "generated", method, "PortGame.source_building_heal_suppression_state", "Canonical owner marker."), "method": field("String", "source-backed", "applyHealSuppression(float, Color)", "public void applyHealSuppression(float amount, Color suppressColor){", "Source method marker."), "heal_suppression_time_before": field("float", "generated", method, "healSuppressionTime", "Previous expiry.", f"{input_name}.heal_suppression_time"), "source_time": field("float", "generated", method, "Time.time", "Clock input.", f"{input_name}.source_time"), "amount": field("float", "generated", method, "amount", "Amount input.", f"{input_name}.amount"), "heal_suppression_time_after": field("float", "source-backed", "applyHealSuppression(float, Color)", "healSuppressionTime = Math.max(healSuppressionTime, Time.time + amount);", "Updated expiry."), "suppress_color": field("Variant", "source-backed", "applyHealSuppression(float, Color)", "this.suppressColor = suppressColor;", "Applied color."), "updated": field("bool", "source-backed", method, "healSuppressionTime = Math.max(healSuppressionTime, Time.time + amount);", "Mutation completed.")}})
    source_symbols.upsert_source_symbols(GODOT, symbols)
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)
    policy_names = ("registry", "audit_report", "slice_ledger", "state_schema", "module_manifest")
    source_ssot.write_registered_json(GODOT, "source_root_policies", {"version": 1, "policies": {name: source_ssot.load_registered_json(GODOT, name).get("policy", {}) for name in policy_names}})


if __name__ == "__main__":
    main()
