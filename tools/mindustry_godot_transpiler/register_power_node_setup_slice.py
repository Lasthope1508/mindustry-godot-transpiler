from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/power/PowerNode.java"
TEST = "test_power_node_setup_matches_upstream_source"

SLICES = (
    {
        "id": "N1929",
        "name": "set_stats",
        "method": "setStats()",
        "owner": "PortGame.source_power_node_set_stats_state",
        "expressions": {
            "method": "public void setStats(){",
            "super_set_stats_expr": "super.setStats();",
            "power_range_stat_expr": "stats.add(Stat.powerRange, laserRange, StatUnit.blocks);",
            "power_connections_stat_expr": "stats.add(Stat.powerConnections, maxNodes, StatUnit.none);",
        },
        "inputs": {
            "laser_range": ("float", "laserRange"),
            "max_nodes": ("int", "maxNodes"),
            "super_set_stats_state": ("Dictionary", "super.setStats();"),
        },
        "derived": {
            "range_stat_unit": ("String", "StatUnit.blocks"),
            "connections_stat_unit": ("String", "StatUnit.none"),
            "stats": ("Array", "stats.add(Stat.powerRange, laserRange, StatUnit.blocks);"),
        },
    },
    {
        "id": "N1930",
        "name": "init",
        "method": "init()",
        "owner": "PortGame.source_power_node_init_state",
        "expressions": {
            "method": "public void init(){",
            "super_init_expr": "super.init();",
            "clip_size_expr": "clipSize = Math.max(clipSize, laserRange * tilesize);",
        },
        "inputs": {
            "clip_size": ("float", "clipSize"),
            "laser_range": ("float", "laserRange"),
            "tilesize": ("float", "tilesize"),
            "super_init_state": ("Dictionary", "super.init();"),
        },
        "derived": {
            "clip_size_after": ("float", "Math.max(clipSize, laserRange * tilesize)"),
            "super_init_called": ("bool", "super.init();"),
        },
    },
    {
        "id": "N1931",
        "name": "plan_config_clip_size",
        "method": "planConfigClipSize()",
        "owner": "PortGame.source_power_node_plan_config_clip_size_state",
        "expressions": {
            "method": "public float planConfigClipSize(){",
            "return_expr": "return laserRange * tilesize * 2f + size * tilesize;",
        },
        "inputs": {
            "laser_range": ("float", "laserRange"),
            "tilesize": ("float", "tilesize"),
            "size": ("float", "size"),
        },
        "derived": {
            "clip_size": ("float", "laserRange * tilesize * 2f + size * tilesize"),
        },
    },
)


def source_key(owner: str, method: str, expression: str, type_name: str, status: str) -> dict:
    return {
        "type": type_name,
        "status": status,
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expression,
        "rule": "Exact upstream PowerNode setup expression or explicit derived result.",
        "used_by": [owner.lower()],
    }


def register(entry: dict) -> None:
    owner = entry["owner"]
    method = entry["method"]
    slice_id = entry["id"]
    proof = "/root/Main." + owner.split(".", 1)[1]
    stem = "source_power_node_" + entry["name"]
    symbols = {}
    for key, expression in entry["expressions"].items():
        symbol_name = "power_node_" + entry["name"] + "." + key
        symbols[symbol_name] = {
            "godot_owner": owner,
            "godot_symbol": stem + "_result." + key,
            "java_expr": expression,
            "java_method": method,
            "java_source": SOURCE,
            "rule": "PowerNode " + method + " source expression.",
            "runtime_proof": proof,
            "source_slice": slice_id,
            "status": "source-backed",
            "tests": [TEST],
        }
    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.upsert_source_slice(GODOT, slice_id, {
        "exact_exprs": list(entry["expressions"].values()),
        "deferred_exprs": ["Godot scene/UI side effects remain separate from this canonical state."],
        "godot_owner": owner,
        "java_class": "mindustry.world.blocks.power.PowerNode",
        "java_method": method,
        "java_source": SOURCE,
        "rule": "Registers PowerNode " + method + " setup state.",
        "runtime_proof": proof,
        "source_symbols": list(symbols),
        "status": "done",
        "tests": [TEST],
    })
    input_schema = stem + "_input"
    input_keys = {
        name: source_key(owner, method, expression, type_name, "explicit-input")
        for name, (type_name, expression) in entry["inputs"].items()
    }
    result_keys = {
        name: source_key(owner, method, expression, "String", "source-backed")
        for name, expression in entry["expressions"].items()
    }
    result_keys.update({
        name: {"type": type_name, "status": "generated", "alias_of": input_schema + "." + name, "used_by": [owner.lower()]}
        for name, (type_name, _) in entry["inputs"].items()
    })
    result_keys.update({
        name: source_key(owner, method, expression, type_name, "derived")
        for name, (type_name, expression) in entry["derived"].items()
    })
    source_symbols.upsert_source_api_contract(GODOT, owner, {
        "java_source": SOURCE,
        "params": [{"name": name, "schema": input_schema + "." + name, "type": type_name} for name, (type_name, _) in entry["inputs"].items()],
        "return_keys": list(result_keys),
        "rule": "Public runtime contract for PowerNode " + method + " state.",
        "runtime_proof": proof,
        "source_method": method,
        "source_slice": slice_id,
        "status": "source-backed",
        "tests": [TEST],
    })
    source_symbols.upsert_source_state_schema(GODOT, input_schema, {
        "keys": input_keys,
        "owner": owner,
        "rule": "Inputs for PowerNode " + method + " state.",
        "runtime_proof": proof,
        "source_slice": slice_id,
        "status": "source-backed",
    })
    source_symbols.upsert_source_state_schema(GODOT, stem + "_result", {
        "keys": result_keys,
        "owner": owner,
        "rule": "Result for PowerNode " + method + " state.",
        "runtime_proof": proof,
        "source_slice": slice_id,
        "status": "source-backed",
    })


def main() -> None:
    for entry in SLICES:
        register(entry)
    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
