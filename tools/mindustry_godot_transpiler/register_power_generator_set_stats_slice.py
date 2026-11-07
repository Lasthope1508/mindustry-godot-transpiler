from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/power/PowerGenerator.java"
OWNER = "PortGame.source_power_generator_set_stats_state"
PROOF = "/root/Main.source_power_generator_set_stats_state"
METHOD = "setStats()"
SLICE = "N1924"


def key(type_name: str, expr: str, rule: str, status: str = "source-backed") -> dict:
    return {"type": type_name, "status": status, "java_source": SOURCE, "java_method": METHOD, "java_expr": expr, "rule": rule, "used_by": [OWNER.lower()]}


def alias(type_name: str, name: str) -> dict:
    return {"type": type_name, "status": "generated", "alias_of": f"source_power_generator_set_stats_input.{name}", "used_by": [OWNER.lower()]}


def main() -> None:
    symbols = {
        "power_generator_set_stats.method": {"godot_owner": OWNER, "godot_symbol": "source_power_generator_set_stats_result.method", "java_expr": "public void setStats(){", "java_method": METHOD, "java_source": SOURCE, "rule": "PowerGenerator.setStats method boundary.", "runtime_proof": PROOF, "source_slice": SLICE, "status": "source-backed", "tests": ["test_power_generator_set_stats_matches_upstream_source"]},
        "power_generator_set_stats.super_set_stats": {"godot_owner": OWNER, "godot_symbol": "source_power_generator_set_stats_result.super_set_stats_expr", "java_expr": "super.setStats();", "java_method": METHOD, "java_source": SOURCE, "rule": "Superclass stats setup executes first.", "runtime_proof": PROOF, "source_slice": SLICE, "status": "source-backed", "tests": ["test_power_generator_set_stats_matches_upstream_source"]},
        "power_generator_set_stats.generation_stat": {"godot_owner": OWNER, "godot_symbol": "source_power_generator_set_stats_result.stats_add_expr", "java_expr": "stats.add(generationType, powerProduction * 60.0f, StatUnit.powerSecond);", "java_method": METHOD, "java_source": SOURCE, "rule": "Power generation statistic is registered per second.", "runtime_proof": PROOF, "source_slice": SLICE, "status": "source-backed", "tests": ["test_power_generator_set_stats_matches_upstream_source"]},
    }
    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.upsert_source_slice(GODOT, SLICE, {"exact_exprs": ["public void setStats(){", "super.setStats();", "stats.add(generationType, powerProduction * 60.0f, StatUnit.powerSecond);"], "deferred_exprs": ["PowerGenerator setBars and drawer/UI behavior remain separate slices."], "godot_owner": OWNER, "java_class": "mindustry.world.blocks.power.PowerGenerator", "java_method": METHOD, "java_source": SOURCE, "rule": "Registers source-backed PowerGenerator.setStats state.", "runtime_proof": PROOF, "source_symbols": list(symbols), "status": "done", "tests": ["test_power_generator_set_stats_matches_upstream_source"]})
    source_symbols.upsert_source_api_contract(GODOT, OWNER, {"java_source": SOURCE, "params": [{"name": "power_production", "schema": "source_power_generator_set_stats_input.power_production", "type": "float"}, {"name": "super_set_stats_state", "schema": "source_power_generator_set_stats_input.super_set_stats_state", "type": "Dictionary"}], "return_keys": ["method", "generation_type_field", "super_set_stats_expr", "super_set_stats_state", "stats_add_expr", "power_production", "generation_stat_value", "stat_unit"], "rule": "Public runtime contract for PowerGenerator.setStats state.", "runtime_proof": PROOF, "source_method": METHOD, "source_slice": SLICE, "status": "source-backed", "tests": ["test_power_generator_set_stats_matches_upstream_source"]})
    source_symbols.upsert_source_state_schema(GODOT, "source_power_generator_set_stats_input", {"keys": {"power_production": key("float", "powerProduction", "PowerGenerator powerProduction field input.", "explicit-input"), "super_set_stats_state": {"type": "Dictionary", "status": "explicit-input", "java_source": SOURCE, "java_method": METHOD, "java_expr": "super.setStats();", "rule": "Injected superclass stats state.", "used_by": [OWNER.lower()]}}, "owner": OWNER, "rule": "Inputs for PowerGenerator.setStats state.", "runtime_proof": PROOF, "source_slice": SLICE, "status": "source-backed"})
    source_symbols.upsert_source_state_schema(GODOT, "source_power_generator_set_stats_result", {"keys": {"method": key("String", "public void setStats(){", "Result method boundary."), "generation_type_field": key("String", "public Stat generationType = Stat.basePowerGeneration;", "Generation stat field."), "super_set_stats_expr": key("String", "super.setStats();", "Superclass stats call."), "super_set_stats_state": alias("Dictionary", "super_set_stats_state"), "stats_add_expr": key("String", "stats.add(generationType, powerProduction * 60.0f, StatUnit.powerSecond);", "Generation stat registration."), "power_production": alias("float", "power_production"), "generation_stat_value": {"type": "float", "status": "derived", "java_source": SOURCE, "java_method": METHOD, "java_expr": "powerProduction * 60.0f", "rule": "Derived generation stat value.", "used_by": [OWNER.lower()]}, "stat_unit": key("String", "StatUnit.powerSecond", "Power-per-second stat unit.")}, "owner": OWNER, "rule": "Result schema for PowerGenerator.setStats state.", "runtime_proof": PROOF, "source_slice": SLICE, "status": "source-backed"})
    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
