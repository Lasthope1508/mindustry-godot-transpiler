from pathlib import Path

from mindustry_port import source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/power/PowerGraph.java"
ARC_SOURCE = "arc-core/src/arc/math/Mathf.java"


def key(type_name: str, expression: str, method: str, rule: str, owner: str, java_source: str = SOURCE) -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": java_source,
        "java_method": method,
        "java_expr": expression,
        "rule": rule,
        "used_by": [owner.lower()],
    }


def alias(type_name: str, target: str, owner: str) -> dict:
    return {"type": type_name, "status": "generated", "alias_of": target, "used_by": [owner.lower()]}


def extend(schema_name: str, owner: str, additions: dict) -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    entry = catalog["schemas"][schema_name]
    entry["keys"].update(additions)
    source_symbols.upsert_source_state_schema(GODOT, schema_name, entry)


def main() -> None:
    update_balance = "PortGame.source_power_graph_update_balance_state"
    method = "update()"
    extend("source_power_graph_update_balance_result", update_balance, {
        "method": key("String", "public void update(){", method, "Method boundary.", update_balance),
        "power_needed_expr": key("String", "float powerNeeded = getPowerNeeded();", method, "Power needed aggregate.", update_balance),
        "power_produced_expr": key("String", "float powerProduced = getPowerProduced();", method, "Power produced aggregate.", update_balance),
        "last_power_needed_expr": key("String", "lastPowerNeeded = powerNeeded;", method, "Last needed assignment.", update_balance),
        "last_power_produced_expr": key("String", "lastPowerProduced = powerProduced;", method, "Last produced assignment.", update_balance),
        "last_scaled_power_in_expr": key("String", "lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta;", method, "Scaled input assignment.", update_balance),
        "last_scaled_power_out_expr": key("String", "lastScaledPowerOut = powerNeeded / Time.delta;", method, "Scaled output assignment.", update_balance),
        "last_capacity_expr": key("String", "lastCapacity = getTotalBatteryCapacity();", method, "Battery capacity assignment.", update_balance),
        "last_power_stored_expr": key("String", "lastPowerStored = getBatteryStored();", method, "Stored power assignment.", update_balance),
        "power_balance_expr": key("String", "powerBalance.add((lastPowerProduced - lastPowerNeeded + energyDelta) / Time.delta);", method, "Power balance sample append.", update_balance),
        "energy_delta_zero_expr": key("String", "energyDelta = 0f;", method, "Energy delta reset.", update_balance),
        "source_delta": alias("float", "source_power_graph_update_balance_input.source_delta", update_balance),
    })

    use_owner = "PortGame.source_power_graph_use_batteries_state"
    use_method = "useBatteries(float needed)"
    extend("source_power_graph_use_batteries_result", use_owner, {
        "method": key("String", "public float useBatteries(float needed){", use_method, "Method boundary.", use_owner),
        "stored_expr": key("String", "float stored = getBatteryStored();", use_method, "Stored power read.", use_owner),
        "zero_guard": key("String", "if(Mathf.equal(stored, 0f)) return 0f;", use_method, "Zero stored power guard.", use_owner),
        "used_expr": key("String", "float used = Math.min(stored, needed);", use_method, "Discharge amount.", use_owner),
        "consumed_percent_expr": key("String", "float consumedPowerPercentage = Math.min(1.0f, needed / stored);", use_method, "Battery status scale.", use_owner),
        "items": key("String", "var items = batteries.items;", use_method, "Battery sequence extraction.", use_owner),
        "loop": key("String", "for(int i = 0; i < batteries.size; i++){", use_method, "Battery iteration.", use_owner),
        "battery": key("String", "var battery = items[i];", use_method, "Current battery selection.", use_owner),
        "guard": key("String", "if(battery.enabled){", use_method, "Enabled battery guard.", use_owner),
        "status_mul": key("String", "battery.power.status *= (1f-consumedPowerPercentage);", use_method, "Battery status discharge mutation.", use_owner),
        "return_expr": key("String", "return used;", use_method, "Discharge return.", use_owner),
        "mathf_equal": key("String", "return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;", "Mathf.equal(float, float)", "Arc equality dependency.", use_owner, ARC_SOURCE),
        "needed": alias("float", "source_power_graph_use_batteries_input.needed", use_owner),
        "zero_guard_returned": key("bool", "if(Mathf.equal(stored, 0f)) return 0f;", use_method, "Proof-visible zero guard result.", use_owner),
    })

    charge_owner = "PortGame.source_power_graph_charge_batteries_state"
    charge_method = "chargeBatteries(float excess)"
    extend("source_power_graph_charge_batteries_result", charge_owner, {
        "method": key("String", "public float chargeBatteries(float excess){", charge_method, "Method boundary.", charge_owner),
        "capacity_expr": key("String", "float capacity = getBatteryCapacity();", charge_method, "Battery capacity read.", charge_owner),
        "charged_percent_comment": key("String", "//how much of the missing in each battery % is charged", charge_method, "Source comment boundary.", charge_owner),
        "charged_percent_expr": key("String", "float chargedPercent = Math.min(excess/capacity, 1f);", charge_method, "Charge percentage.", charge_owner),
        "zero_guard": key("String", "if(Mathf.equal(capacity, 0f)) return 0f;", charge_method, "Zero capacity guard.", charge_owner),
        "items": key("String", "var items = batteries.items;", charge_method, "Battery sequence extraction.", charge_owner),
        "loop": key("String", "for(int i = 0; i < batteries.size; i++){", charge_method, "Battery iteration.", charge_owner),
        "battery": key("String", "var battery = items[i];", charge_method, "Current battery selection.", charge_owner),
        "todo": key("String", "//TODO why would it be 0", charge_method, "Source TODO boundary.", charge_owner),
        "guard": key("String", "if(battery.enabled && battery.block.consPower.capacity > 0f){", charge_method, "Enabled-capacity guard.", charge_owner),
        "status_add": key("String", "battery.power.status += (1f - battery.power.status) * chargedPercent;", charge_method, "Battery status charge mutation.", charge_owner),
        "return_expr": key("String", "return Math.min(excess, capacity);", charge_method, "Charge return.", charge_owner),
        "mathf_equal": key("String", "return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;", "Mathf.equal(float, float)", "Arc equality dependency.", charge_owner, ARC_SOURCE),
        "excess": alias("float", "source_power_graph_charge_batteries_input.excess", charge_owner),
        "zero_guard_returned": key("bool", "if(Mathf.equal(capacity, 0f)) return 0f;", charge_method, "Proof-visible zero guard result.", charge_owner),
    })

    update_owner = "PortGame.source_power_graph_update_battery_distribute_state"
    update_method = "update()"
    extend("source_power_graph_update_battery_distribute_result", update_owner, {
        "method": key("String", "public void update(){", update_method, "Method boundary.", update_owner),
        "nonempty_guard": key("String", "if(!(consumers.size == 0 && producers.size == 0 && batteries.size == 0)){", update_method, "Nonempty graph guard.", update_owner),
        "charged_init": key("String", "boolean charged = false;", update_method, "Charge state initialization.", update_owner),
        "unequal_guard_expr": key("String", "if(!Mathf.equal(powerNeeded, powerProduced)){", update_method, "Balance comparison gate.", update_owner),
        "deficit_gate": key("String", "if(powerNeeded > powerProduced){", update_method, "Deficit gate.", update_owner),
        "power_battery_used_expr": key("String", "float powerBatteryUsed = useBatteries(powerNeeded - powerProduced);", update_method, "Battery discharge call.", update_owner),
        "power_produced_battery_add_expr": key("String", "powerProduced += powerBatteryUsed;", update_method, "Production increase after discharge.", update_owner),
        "last_power_produced_battery_add_expr": key("String", "lastPowerProduced += powerBatteryUsed;", update_method, "Last production increase after discharge.", update_owner),
        "surplus_gate": key("String", "}else if(powerProduced > powerNeeded){", update_method, "Surplus gate.", update_owner),
        "charged_true_expr": key("String", "charged = true;", update_method, "Charged branch assignment.", update_owner),
        "power_produced_charge_sub_expr": key("String", "powerProduced -= chargeBatteries(powerProduced - powerNeeded);", update_method, "Production reduction after charge.", update_owner),
        "distribute_power_expr": key("String", "distributePower(powerNeeded, powerProduced, charged);", update_method, "Distribution call.", update_owner),
        "mathf_equal": key("String", "return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;", "Mathf.equal(float, float)", "Arc equality dependency.", update_owner, ARC_SOURCE),
        "last_power_stored": alias("float", "source_power_graph_update_battery_distribute_input.last_power_stored", update_owner),
        "producers": alias("Array", "source_power_graph_update_battery_distribute_input.producers", update_owner),
    })


if __name__ == "__main__":
    main()
