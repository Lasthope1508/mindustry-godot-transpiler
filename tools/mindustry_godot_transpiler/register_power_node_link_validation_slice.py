from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/power/PowerNode.java"
TEST = "test_power_node_link_validation_matches_upstream_source"


def source_key(owner: str, method: str, expression: str, type_name: str, status: str = "source-backed") -> dict:
    return {
        "type": type_name,
        "status": status,
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expression,
        "rule": "Exact upstream PowerNode link validation expression or explicit runtime input.",
        "used_by": [owner.lower()],
    }


def alias(type_name: str, target: str, owner: str) -> dict:
    return {
        "type": type_name,
        "status": "generated",
        "alias_of": target,
        "used_by": [owner.lower()],
    }


def main() -> None:
    link_owner = "PortGame.source_power_node_link_valid_state"
    link_method = "linkValid(Building tile, Building link, boolean checkMaxNodes)"
    link_input = "source_power_node_link_valid_input"
    link_result = "source_power_node_link_valid_result"
    link_expressions = {
        "method": "public boolean linkValid(Building tile, Building link){",
        "overload_method": link_method,
        "guard_expr": "if(tile == link || link == null || !link.block.hasPower || !link.block.connectedPower || tile.team != link.team || (sameBlockConnection && tile.block != link.block)) return false;",
        "overlap_expr": "if(overlaps(tile, link, laserRange * tilesize) || (link.block instanceof PowerNode node && overlaps(link, tile, node.laserRange * tilesize))){",
        "max_nodes_expr": "if(checkMaxNodes && link.block instanceof PowerNode node){",
        "return_expr": "return link.power.links.size < node.maxNodes || link.power.links.contains(tile.pos());",
        "true_expr": "return true;",
        "false_expr": "return false;",
    }
    link_input_keys = {
        "link_state": source_key(link_owner, link_method, "tile, link", "Dictionary", "explicit-input"),
        "check_max_nodes": source_key(link_owner, link_method, "checkMaxNodes", "bool", "explicit-input"),
    }
    link_result_keys = {key: source_key(link_owner, link_method, expression, "String") for key, expression in link_expressions.items()}
    link_result_keys.update({
        "link_state": alias("Dictionary", link_input + ".link_state", link_owner),
        "check_max_nodes": alias("bool", link_input + ".check_max_nodes", link_owner),
        "guard_failed": source_key(link_owner, link_method, link_expressions["guard_expr"], "bool", "derived"),
        "overlaps_match": source_key(link_owner, link_method, link_expressions["overlap_expr"], "bool", "derived"),
        "max_nodes_match": source_key(link_owner, link_method, link_expressions["max_nodes_expr"], "bool", "derived"),
        "link_valid": source_key(link_owner, link_method, link_expressions["true_expr"] + " / " + link_expressions["false_expr"], "bool", "derived"),
    })
    source_symbols.upsert_source_symbols(GODOT, {
        "power_node_link_valid.method": {
            "godot_owner": link_owner,
            "godot_symbol": link_result + ".method",
            "java_expr": link_expressions["method"],
            "java_method": link_method,
            "java_source": SOURCE,
            "rule": "PowerNode linkValid overload source method.",
            "runtime_proof": "/root/Main.source_power_node_link_valid_state",
            "source_slice": "N1932",
            "status": "source-backed",
            "tests": [TEST],
        },
        **{
            "power_node_link_valid." + key: {
                "godot_owner": link_owner,
                "godot_symbol": link_result + "." + key,
                "java_expr": expression,
                "java_method": link_method,
                "java_source": SOURCE,
                "rule": "PowerNode linkValid source expression.",
                "runtime_proof": "/root/Main.source_power_node_link_valid_state",
                "source_slice": "N1932",
                "status": "source-backed",
                "tests": [TEST],
            }
            for key, expression in link_expressions.items()
        },
        "power_node_link_valid.link_state": {
            "godot_owner": link_owner,
            "godot_symbol": link_input + ".link_state",
            "java_expr": "tile, link",
            "java_method": link_method,
            "java_source": SOURCE,
            "rule": "Explicit runtime state for the Java Building inputs.",
            "runtime_proof": "/root/Main.source_power_node_link_valid_state",
            "source_slice": "N1932",
            "status": "explicit-input",
            "tests": [TEST],
        },
        "power_node_link_valid.check_max_nodes": {
            "godot_owner": link_owner,
            "godot_symbol": link_input + ".check_max_nodes",
            "java_expr": "checkMaxNodes",
            "java_method": link_method,
            "java_source": SOURCE,
            "rule": "Explicit linkValid max-node input.",
            "runtime_proof": "/root/Main.source_power_node_link_valid_state",
            "source_slice": "N1932",
            "status": "explicit-input",
            "tests": [TEST],
        },
    })
    source_symbols.upsert_source_slice(GODOT, "N1932", {
        "exact_exprs": list(link_expressions.values()),
        "deferred_exprs": ["World/building object construction remains an explicit runtime input."],
        "godot_owner": link_owner,
        "java_class": "mindustry.world.blocks.power.PowerNode",
        "java_method": "linkValid()",
        "java_source": SOURCE,
        "rule": "Registers PowerNode linkValid overload behavior.",
        "runtime_proof": "/root/Main.source_power_node_link_valid_state",
        "source_symbols": ["power_node_link_valid." + key for key in link_expressions],
        "status": "done",
        "tests": [TEST],
    })
    source_symbols.upsert_source_api_contract(GODOT, link_owner, {
        "java_source": SOURCE,
        "params": [
            {"name": "link_state", "schema": link_input + ".link_state", "type": "Dictionary"},
            {"name": "check_max_nodes", "schema": link_input + ".check_max_nodes", "type": "bool"},
        ],
        "return_keys": list(link_result_keys),
        "rule": "Public runtime contract for PowerNode linkValid() state.",
        "runtime_proof": "/root/Main.source_power_node_link_valid_state",
        "source_method": link_method,
        "source_slice": "N1932",
        "status": "source-backed",
        "tests": [TEST],
    })
    source_symbols.upsert_source_state_schema(GODOT, link_input, {
        "keys": link_input_keys,
        "owner": link_owner,
        "rule": "Explicit Building and branch inputs for PowerNode linkValid().",
        "runtime_proof": "/root/Main.source_power_node_link_valid_state",
        "source_slice": "N1932",
        "status": "source-backed",
    })
    source_symbols.upsert_source_state_schema(GODOT, link_result, {
        "keys": link_result_keys,
        "owner": link_owner,
        "rule": "Canonical PowerNode linkValid() result.",
        "runtime_proof": "/root/Main.source_power_node_link_valid_state",
        "source_slice": "N1932",
        "status": "source-backed",
    })

    insulated_owner = "PortGame.source_power_node_insulated_state"
    insulated_method = "insulated(Tile tile, Tile other) / insulated(Building tile, Building other) / insulated(int x, int y, int x2, int y2)"
    insulated_input = "source_power_node_insulated_input"
    insulated_result = "source_power_node_insulated_result"
    insulated_expressions = {
        "tile_method": "public static boolean insulated(Tile tile, Tile other){",
        "building_method": "public static boolean insulated(Building tile, Building other){",
        "coordinate_method": "public static boolean insulated(int x, int y, int x2, int y2){",
        "raycast_expr": "return World.raycast(x, y, x2, y2, (wx, wy) -> {",
        "build_expr": "return tile != null && tile.isInsulated();",
    }
    insulated_input_keys = {
        "raycast_insulated": source_key(insulated_owner, insulated_method, "return tile != null && tile.isInsulated();", "bool", "explicit-input"),
    }
    insulated_result_keys = {key: source_key(insulated_owner, insulated_method, expression, "String") for key, expression in insulated_expressions.items()}
    insulated_result_keys.update({
        "raycast_insulated": alias("bool", insulated_input + ".raycast_insulated", insulated_owner),
        "insulated": source_key(insulated_owner, insulated_method, "return World.raycast(x, y, x2, y2, (wx, wy) -> {", "bool", "derived"),
    })
    source_symbols.upsert_source_symbols(GODOT, {
        "power_node_insulated.method": {
            "godot_owner": insulated_owner,
            "godot_symbol": insulated_result + ".insulated",
            "java_expr": insulated_expressions["coordinate_method"],
            "java_method": insulated_method,
            "java_source": SOURCE,
            "rule": "PowerNode insulated overload source methods.",
            "runtime_proof": "/root/Main.source_power_node_insulated_state",
            "source_slice": "N1933",
            "status": "source-backed",
            "tests": [TEST],
        },
        **{
            "power_node_insulated." + key: {
                "godot_owner": insulated_owner,
                "godot_symbol": insulated_result + "." + key,
                "java_expr": expression,
                "java_method": insulated_method,
                "java_source": SOURCE,
                "rule": "PowerNode insulated source expression.",
                "runtime_proof": "/root/Main.source_power_node_insulated_state",
                "source_slice": "N1933",
                "status": "source-backed",
                "tests": [TEST],
            }
            for key, expression in insulated_expressions.items()
        },
        "power_node_insulated.raycast_insulated": {
            "godot_owner": insulated_owner,
            "godot_symbol": insulated_input + ".raycast_insulated",
            "java_expr": "return tile != null && tile.isInsulated();",
            "java_method": insulated_method,
            "java_source": SOURCE,
            "rule": "Explicit runtime result of the world raycast callback.",
            "runtime_proof": "/root/Main.source_power_node_insulated_state",
            "source_slice": "N1933",
            "status": "explicit-input",
            "tests": [TEST],
        },
    })
    source_symbols.upsert_source_slice(GODOT, "N1933", {
        "exact_exprs": list(insulated_expressions.values()),
        "deferred_exprs": ["World.raycast traversal remains owned by the world runtime; this slice consumes its explicit callback result."],
        "godot_owner": insulated_owner,
        "java_class": "mindustry.world.blocks.power.PowerNode",
        "java_method": "insulated()",
        "java_source": SOURCE,
        "rule": "Registers PowerNode insulated overload behavior.",
        "runtime_proof": "/root/Main.source_power_node_insulated_state",
        "source_symbols": ["power_node_insulated." + key for key in insulated_expressions],
        "status": "done",
        "tests": [TEST],
    })
    source_symbols.upsert_source_api_contract(GODOT, insulated_owner, {
        "java_source": SOURCE,
        "params": [{"name": "raycast_insulated", "schema": insulated_input + ".raycast_insulated", "type": "bool"}],
        "return_keys": list(insulated_result_keys),
        "rule": "Public runtime contract for PowerNode insulated() state.",
        "runtime_proof": "/root/Main.source_power_node_insulated_state",
        "source_method": insulated_method,
        "source_slice": "N1933",
        "status": "source-backed",
        "tests": [TEST],
    })
    source_symbols.upsert_source_state_schema(GODOT, insulated_input, {
        "keys": insulated_input_keys,
        "owner": insulated_owner,
        "rule": "Explicit world raycast result for PowerNode insulated().",
        "runtime_proof": "/root/Main.source_power_node_insulated_state",
        "source_slice": "N1933",
        "status": "source-backed",
    })
    source_symbols.upsert_source_state_schema(GODOT, insulated_result, {
        "keys": insulated_result_keys,
        "owner": insulated_owner,
        "rule": "Canonical PowerNode insulated() result.",
        "runtime_proof": "/root/Main.source_power_node_insulated_state",
        "source_slice": "N1933",
        "status": "source-backed",
    })
    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
