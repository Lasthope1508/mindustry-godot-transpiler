from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
OWNER = "PortGame.source_building_health_recent_state"
PROOF = "/root/Main.BuildingLifecycleStateModuleProof"
TESTS = ["test_building_health_recent_slice.py", "test_source_symbols.py"]


def entry(type_name: str, status: str, method: str, expr: str, rule: str, *, alias_of: str | None = None) -> dict:
    value = {"type": type_name, "status": status, "java_source": SOURCE, "java_method": method, "java_expr": expr, "rule": rule}
    if alias_of:
        value["alias_of"] = alias_of
    return value


def main() -> None:
    method = "recentlyHealed(), wasRecentlyHealed(float), wasRecentlyDamaged()"
    input_name = "source_building_health_recent_input"
    result_name = "source_building_health_recent_result"
    symbols = {
        "building_health_recent.recently_healed": {"status": "source-backed", "godot_owner": OWNER, "godot_symbol": f"{result_name}.recentlyHealed", "rule": "Source timestamp mutation.", "tests": TESTS, "runtime_proof": PROOF, "java_source": SOURCE, "java_method": "recentlyHealed()", "java_expr": "lastHealTime = Time.time;"},
        "building_health_recent.was_recently_healed": {"status": "source-backed", "godot_owner": OWNER, "godot_symbol": f"{result_name}.wasRecentlyHealed", "rule": "Source heal recency predicate.", "tests": TESTS, "runtime_proof": PROOF, "java_source": SOURCE, "java_method": "wasRecentlyHealed(float)", "java_expr": "return lastHealTime + duration >= Time.time;"},
        "building_health_recent.was_recently_damaged": {"status": "source-backed", "godot_owner": OWNER, "godot_symbol": f"{result_name}.wasRecentlyDamaged", "rule": "Source damage recency predicate.", "tests": TESTS, "runtime_proof": PROOF, "java_source": SOURCE, "java_method": "wasRecentlyDamaged()", "java_expr": "return lastDamageTime + recentDamageTime >= Time.time;"},
        "building_health_recent.source_time": {"status": "explicit-input", "godot_owner": OWNER, "godot_symbol": f"{input_name}.source_time", "rule": "Explicit source clock input.", "tests": TESTS, "runtime_proof": PROOF, "java_source": SOURCE, "java_method": method, "java_expr": "Time.time"},
        "building_health_recent.last_heal_time": {"status": "explicit-input", "godot_owner": OWNER, "godot_symbol": f"{input_name}.last_heal_time", "rule": "Explicit last-heal timestamp input.", "tests": TESTS, "runtime_proof": PROOF, "java_source": SOURCE, "java_method": method, "java_expr": "lastHealTime"},
        "building_health_recent.heal_duration": {"status": "explicit-input", "godot_owner": OWNER, "godot_symbol": f"{input_name}.heal_duration", "rule": "Explicit duration input.", "tests": TESTS, "runtime_proof": PROOF, "java_source": SOURCE, "java_method": "wasRecentlyHealed(float)", "java_expr": "duration"},
        "building_health_recent.last_damage_time": {"status": "explicit-input", "godot_owner": OWNER, "godot_symbol": f"{input_name}.last_damage_time", "rule": "Explicit last-damage timestamp input.", "tests": TESTS, "runtime_proof": PROOF, "java_source": SOURCE, "java_method": "wasRecentlyDamaged()", "java_expr": "lastDamageTime"},
        "building_health_recent.recent_damage_time": {"status": "explicit-input", "godot_owner": OWNER, "godot_symbol": f"{input_name}.recent_damage_time", "rule": "Explicit recent-damage window input.", "tests": TESTS, "runtime_proof": PROOF, "java_source": SOURCE, "java_method": "wasRecentlyDamaged()", "java_expr": "recentDamageTime"},
    }
    source_symbols.upsert_source_slice(GODOT, "N1949", {"status": "done", "java_source": SOURCE, "java_class": "mindustry.entities.comp.BuildingComp", "java_method": method, "godot_owner": OWNER, "exact_exprs": ["lastHealTime = Time.time;", "return lastHealTime + duration >= Time.time;", "return lastDamageTime + recentDamageTime >= Time.time;"], "source_symbols": list(symbols), "tests": TESTS, "runtime_proof": PROOF, "rule": "Canonical temporal health cluster shares the lifecycle state module."})
    source_symbols.upsert_source_api_contract(GODOT, OWNER, {"status": "active", "source_slice": "N1949", "java_source": SOURCE, "source_method": method, "params": [{"name": "source_time", "type": "float", "schema": f"{input_name}.source_time"}, {"name": "last_heal_time", "type": "float", "schema": f"{input_name}.last_heal_time"}, {"name": "heal_duration", "type": "float", "schema": f"{input_name}.heal_duration"}, {"name": "last_damage_time", "type": "float", "schema": f"{input_name}.last_damage_time"}, {"name": "recent_damage_time", "type": "float", "schema": f"{input_name}.recent_damage_time"}], "return_keys": ["recently_healed", "was_recently_healed", "was_recently_damaged"], "tests": TESTS, "runtime_proof": PROOF, "rule": "Public temporal health contract with explicit source clock and timestamps."})
    source_symbols.upsert_source_state_schema(GODOT, input_name, {"status": "active", "owner": OWNER, "runtime_proof": PROOF, "keys": {"source_time": entry("float", "explicit-input", method, "Time.time", "Source clock."), "last_heal_time": entry("float", "explicit-input", method, "lastHealTime", "Last heal timestamp."), "heal_duration": entry("float", "explicit-input", "wasRecentlyHealed(float)", "duration", "Heal recency duration."), "last_damage_time": entry("float", "explicit-input", "wasRecentlyDamaged()", "lastDamageTime", "Last damage timestamp."), "recent_damage_time": entry("float", "explicit-input", "wasRecentlyDamaged()", "recentDamageTime", "Damage recency window.")}})
    source_symbols.upsert_source_state_schema(GODOT, result_name, {"status": "active", "owner": OWNER, "runtime_proof": PROOF, "keys": {"recently_healed": entry("Dictionary", "source-backed", "recentlyHealed()", "lastHealTime = Time.time;", "Updated heal timestamp."), "was_recently_healed": entry("Dictionary", "source-backed", "wasRecentlyHealed(float)", "return lastHealTime + duration >= Time.time;", "Heal recency result."), "was_recently_damaged": entry("Dictionary", "source-backed", "wasRecentlyDamaged()", "return lastDamageTime + recentDamageTime >= Time.time;", "Damage recency result.")}})
    registry = source_symbols.load_source_symbol_registry(GODOT)
    aliases = registry.setdefault("policy", {}).setdefault("canonicalOwnerAliases", {})
    for function_owner in ("recently_healed", "was_recently_healed", "was_recently_damaged"):
        aliases[f"port_game.source_building_{function_owner}_state"] = "port_game.source_building_health_recent_state"
    source_ssot.write_json(GODOT, "registry", registry)
    source_symbols.upsert_source_symbols(GODOT, symbols)
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)
    policy_names = ("registry", "audit_report", "slice_ledger", "state_schema", "module_manifest")
    source_ssot.write_registered_json(
        GODOT,
        "source_root_policies",
        {"version": 1, "policies": {name: source_ssot.load_registered_json(GODOT, name).get("policy", {}) for name in policy_names}},
    )


if __name__ == "__main__":
    main()
