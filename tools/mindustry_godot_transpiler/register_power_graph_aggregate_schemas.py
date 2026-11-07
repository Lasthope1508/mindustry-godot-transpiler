from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/power/PowerGraph.java"
UPDATE_OWNER = "PortGame.source_power_graph_update_state"
REMOVE_OWNER = "PortGame.source_power_graph_remove_state"
UPDATE_PROOF = "/root/Main.generated_power_graph_update_bridge_state"
REMOVE_PROOF = "/root/Main.generated_power_graph_remove_bridge_state"


def source_key(type_name: str, expression: str, method: str, rule: str, used_by: str, java_source: str = SOURCE) -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": java_source,
        "java_method": method,
        "java_expr": expression,
        "rule": rule,
        "used_by": [used_by.lower()],
    }


def generated_alias(type_name: str, target: str, used_by: str) -> dict:
    return {
        "type": type_name,
        "status": "generated",
        "alias_of": target,
        "used_by": [used_by.lower()],
    }


def main() -> None:
    update_keys = {
        "method": source_key("String", "public void update(){", "update()", "PowerGraph.update method boundary.", UPDATE_OWNER),
        "nonempty_guard": source_key("String", "if(!(consumers.size == 0 && producers.size == 0 && batteries.size == 0)){", "update()", "Empty graph guard before distribution.", UPDATE_OWNER),
        "charged_init": source_key("String", "boolean charged = false;", "update()", "Charge state starts false.", UPDATE_OWNER),
        "unequal_guard_expr": source_key("String", "if(!Mathf.equal(powerNeeded, powerProduced)){", "update()", "Power balance comparison gate.", UPDATE_OWNER),
        "deficit_gate": source_key("String", "if(powerNeeded > powerProduced){", "update()", "Deficit branch uses batteries.", UPDATE_OWNER),
        "power_battery_used_expr": source_key("String", "float powerBatteryUsed = useBatteries(powerNeeded - powerProduced);", "update()", "Battery discharge call.", UPDATE_OWNER),
        "power_produced_battery_add_expr": source_key("String", "powerProduced += powerBatteryUsed;", "update()", "Discharged power enters production total.", UPDATE_OWNER),
        "last_power_produced_battery_add_expr": source_key("String", "lastPowerProduced += powerBatteryUsed;", "update()", "Discharged power enters last production total.", UPDATE_OWNER),
        "surplus_gate": source_key("String", "}else if(powerProduced > powerNeeded){", "update()", "Surplus branch charges batteries.", UPDATE_OWNER),
        "charged_true_expr": source_key("String", "charged = true;", "update()", "Surplus marks graph charged.", UPDATE_OWNER),
        "power_produced_charge_sub_expr": source_key("String", "powerProduced -= chargeBatteries(powerProduced - powerNeeded);", "update()", "Battery charge is removed from production total.", UPDATE_OWNER),
        "distribute_power_expr": source_key("String", "distributePower(powerNeeded, powerProduced, charged);", "update()", "Final consumer distribution call.", UPDATE_OWNER),
        "mathf_equal": source_key("String", "return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;", "Mathf.equal(float, float)", "Arc Mathf.equal tolerance used by update.", UPDATE_OWNER, "arc-core/src/arc/math/Mathf.java"),
        "cheat_state": generated_alias("Dictionary", "source_power_graph_update_cheat_result", UPDATE_OWNER),
        "balance_state": generated_alias("Dictionary", "source_power_graph_update_balance_result", UPDATE_OWNER),
        "battery_distribute_state": generated_alias("Dictionary", "source_power_graph_update_battery_distribute_result", UPDATE_OWNER),
        "power_needed": generated_alias("float", "source_power_graph_update_balance_result.power_needed", UPDATE_OWNER),
        "power_produced": generated_alias("float", "source_power_graph_update_balance_result.power_produced", UPDATE_OWNER),
        "last_power_needed": generated_alias("float", "source_power_graph_update_balance_result.last_power_needed", UPDATE_OWNER),
        "last_power_produced": generated_alias("float", "source_power_graph_update_balance_result.last_power_produced", UPDATE_OWNER),
        "last_power_stored": generated_alias("float", "source_power_graph_update_balance_result.last_power_stored", UPDATE_OWNER),
        "consumers": generated_alias("Array", "source_power_graph_update_balance_input.consumers", UPDATE_OWNER),
        "producers": generated_alias("Array", "source_power_graph_update_balance_input.producers", UPDATE_OWNER),
        "batteries": generated_alias("Array", "source_power_graph_update_balance_input.batteries", UPDATE_OWNER),
        "energy_delta": generated_alias("float", "source_power_graph_update_balance_input.energy_delta", UPDATE_OWNER),
        "source_delta": generated_alias("float", "source_power_graph_update_balance_input.source_delta", UPDATE_OWNER),
        "power_balance_samples": generated_alias("Array", "source_power_graph_update_balance_input.power_balance_samples", UPDATE_OWNER),
    }
    remove_keys = {
        "method": source_key("String", "public void remove(Building tile){", "remove(Building tile)", "PowerGraph.remove method boundary.", REMOVE_OWNER),
        "remove_comment": source_key("String", "//go through all the connections of this tile", "remove(Building tile)", "Branch traversal begins with tile connections.", REMOVE_OWNER),
        "seed_state": generated_alias("Dictionary", "source_power_graph_remove_branch_seed_result", REMOVE_OWNER),
        "bfs_state": generated_alias("Dictionary", "source_power_graph_remove_branch_bfs_result", REMOVE_OWNER),
        "update_state": generated_alias("Dictionary", "source_power_graph_remove_branch_update_result", REMOVE_OWNER),
        "empty_entity_state": generated_alias("Dictionary", "source_power_graph_remove_empty_entity_result", REMOVE_OWNER),
        "tile": generated_alias("Dictionary", "source_power_graph_remove_empty_entity_input.tile", REMOVE_OWNER),
        "entity_present": generated_alias("bool", "source_power_graph_remove_empty_entity_input.entity_present", REMOVE_OWNER),
    }
    source_symbols.upsert_source_state_schema(GODOT, "source_power_graph_update_result", {
        "status": "active", "owner": UPDATE_OWNER, "runtime_proof": UPDATE_PROOF, "keys": update_keys,
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_power_graph_remove_result", {
        "status": "active", "owner": REMOVE_OWNER, "runtime_proof": REMOVE_PROOF, "keys": remove_keys,
    })
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
