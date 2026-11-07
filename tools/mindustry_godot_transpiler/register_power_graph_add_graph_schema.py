from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/power/PowerGraph.java"
OWNER = "PortGame.source_power_graph_add_graph_state"
METHOD = "addGraph(PowerGraph graph)"


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


def alias(type_name: str, target: str) -> dict:
    return {
        "type": type_name,
        "status": "generated",
        "alias_of": target,
        "used_by": [OWNER.lower()],
    }


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    entry = catalog["schemas"]["source_power_graph_add_graph_result"]
    entry["keys"].update({
        "self_guard": source_key("String", "if(graph == this) return;", "Self-graph early return."),
        "merge_comment": source_key("String", "//merge into other graph instead.", "Delegation branch comment."),
        "delegate_return_expr": source_key("String", "return;", "Delegation branch returns after merging into the larger graph."),
        "remove_comment": source_key("String", "//other entity should be removed as the graph was merged", "Merged graph entity cleanup comment."),
        "graph_is_self": alias("bool", "source_power_graph_add_graph_input.graph_is_self"),
        "graph_all_size": alias("int", "source_power_graph_add_graph_input.graph_all_size"),
        "all_size": alias("int", "source_power_graph_add_graph_input.all_size"),
        "graph_has_entity": alias("bool", "source_power_graph_add_graph_input.graph_has_entity"),
        "graph_tiles": alias("Array", "source_power_graph_add_graph_input.graph_tiles"),
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_power_graph_add_graph_result", entry)
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
