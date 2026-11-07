from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
OWNER = "PortGame.source_power_graph_distribute_power_state"
PROOF = "/root/Main.source_power_graph_distribute_power_state"
SOURCE = "core/src/mindustry/world/blocks/power/PowerGraph.java"
ARC_SOURCE = "arc-core/src/arc/math/Mathf.java"


def source_key(type_name: str, expression: str, rule: str, java_source: str = SOURCE, method: str = "distributePower(float needed, float produced, boolean charged)") -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": java_source,
        "java_method": method,
        "java_expr": expression,
        "rule": rule,
        "used_by": [OWNER.lower()],
    }


def alias(type_name: str, target: str) -> dict:
    return {"type": type_name, "status": "generated", "alias_of": target, "used_by": [OWNER.lower()]}


def main() -> None:
    expressions = {
        "method": ("String", "public void distributePower(float needed, float produced, boolean charged){", "Method boundary."),
        "coverage_expr": ("String", "float coverage = Mathf.zero(needed) && Mathf.zero(produced) && !charged && Mathf.zero(lastPowerStored) ? 0f : Mathf.zero(needed) ? 1f : Math.min(1, produced / needed);", "Global coverage formula."),
        "items": ("String", "var items = consumers.items;", "Consumer sequence extraction."),
        "loop": ("String", "for(int i = 0; i < consumers.size; i++){", "Consumer iteration."),
        "consumer": ("String", "var consumer = items[i];", "Current consumer selection."),
        "cons": ("String", "var cons = consumer.block.consPower;", "Consumer power configuration selection."),
        "buffered_gate": ("String", "if(cons.buffered){", "Buffered consumer branch."),
        "capacity_zero_guard": ("String", "if(!Mathf.zero(cons.capacity)){", "Buffered capacity guard."),
        "maximum_rate_expr": ("String", "float maximumRate = cons.requestedPower(consumer) * coverage * consumer.delta();", "Buffered maximum rate."),
        "buffered_status_clamp": ("String", "consumer.power.status = Mathf.clamp(consumer.power.status + maximumRate / cons.capacity);", "Buffered status mutation."),
        "unbuffered_gate": ("String", "}else{", "Unbuffered consumer branch."),
        "unbuffered_coverage_status": ("String", "consumer.power.status = coverage;", "Active unbuffered status."),
        "unbuffered_estimate_status": ("String", "consumer.power.status = Math.min(1, produced / (needed + cons.usage * consumer.delta()));", "Inactive consumer estimate."),
        "nan_guard": ("String", "if(Float.isNaN(consumer.power.status)){", "NaN correction guard."),
        "nan_status_zero": ("String", "consumer.power.status = 0f;", "NaN correction assignment."),
        "mathf_zero": ("String", "Mathf.zero(float)", "Arc zero comparison dependency.", ARC_SOURCE, "zero(float)"),
        "mathf_clamp": ("String", "Mathf.clamp(float)", "Arc clamp dependency.", ARC_SOURCE, "clamp(float)"),
    }
    keys = {name: source_key(*value) for name, value in expressions.items()}
    keys.update({
        "needed": alias("float", "source_power_graph_distribute_power_input.needed"),
        "produced": alias("float", "source_power_graph_distribute_power_input.produced"),
        "charged": alias("bool", "source_power_graph_distribute_power_input.charged"),
        "last_power_stored": alias("float", "source_power_graph_distribute_power_input.last_power_stored"),
        "coverage": source_key("float", expressions["coverage_expr"][1], "Computed global power coverage."),
        "consumers": source_key("Array", "PowerGraph.distributePower consumer.power.status mutations", "Consumer status mutations are the canonical aggregate result of distribution."),
        "buffered_count": source_key("int", "if(cons.buffered){", "Proof-visible count of buffered consumers."),
        "unbuffered_count": source_key("int", "}else{", "Proof-visible count of unbuffered consumers."),
        "nan_guard_count": source_key("int", "if(Float.isNaN(consumer.power.status)){", "Proof-visible count of NaN corrections."),
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_power_graph_distribute_power_result", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF, "keys": keys,
    })
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
