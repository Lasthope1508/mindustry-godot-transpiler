from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/power/PowerNode.java"
TEST = "test_power_node_placement_matches_upstream_source"


def source_key(owner: str, method: str, expression: str, type_name: str, status: str = "source-backed") -> dict:
    return {
        "type": type_name,
        "status": status,
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expression,
        "rule": "Exact upstream PowerNode placement expression or explicit runtime dependency.",
        "used_by": [owner.lower()],
    }


def register_slice(owner: str, slice_id: str, method: str, expressions: dict, inputs: dict, result_keys: dict, schema_input: str, schema_result: str) -> None:
    proof = "/root/Main." + owner.split(".", 1)[1]
    source_symbols.upsert_source_symbols(GODOT, {
        f"power_node_{slice_id}.method": {
            "godot_owner": owner,
            "godot_symbol": f"{schema_result}.method",
            "java_expr": expressions["method"],
            "java_method": method,
            "java_source": SOURCE,
            "rule": "PowerNode placement source method.",
            "runtime_proof": proof,
            "source_slice": slice_id,
            "status": "source-backed",
            "tests": [TEST],
        },
        **{
            f"power_node_{slice_id}.{key}": {
                "godot_owner": owner,
                "godot_symbol": f"{schema_result}.{key}",
                "java_expr": expression,
                "java_method": method,
                "java_source": SOURCE,
                "rule": "PowerNode placement source expression.",
                "runtime_proof": proof,
                "source_slice": slice_id,
                "status": "source-backed",
                "tests": [TEST],
            }
            for key, expression in expressions.items()
            if key != "method"
        },
    })
    source_symbols.upsert_source_slice(GODOT, slice_id, {
        "exact_exprs": list(expressions.values()),
        "deferred_exprs": ["World, placement, player, and renderer objects remain explicit runtime inputs."],
        "godot_owner": owner,
        "java_class": "mindustry.world.blocks.power.PowerNode",
        "java_method": method,
        "java_source": SOURCE,
        "rule": "Registers PowerNode placement behavior.",
        "runtime_proof": proof,
        "source_symbols": [f"power_node_{slice_id}.{key}" for key in expressions],
        "status": "done",
        "tests": [TEST],
    })
    source_symbols.upsert_source_api_contract(GODOT, owner, {
        "java_source": SOURCE,
        "params": [
            {"name": name, "schema": f"{schema_input}.{name}", "type": type_name}
            for name, (type_name, _) in inputs.items()
        ],
        "return_keys": list(result_keys),
        "rule": "Public runtime contract for PowerNode placement state.",
        "runtime_proof": proof,
        "source_method": method,
        "source_slice": slice_id,
        "status": "source-backed",
        "tests": [TEST],
    })
    source_symbols.upsert_source_state_schema(GODOT, schema_input, {
        "keys": {
            name: source_key(owner, method, expression, type_name, "explicit-input")
            for name, (type_name, expression) in inputs.items()
        },
        "owner": owner,
        "rule": "Explicit runtime dependencies for PowerNode placement.",
        "runtime_proof": proof,
        "source_slice": slice_id,
        "status": "source-backed",
    })
    source_symbols.upsert_source_state_schema(GODOT, schema_result, {
        "keys": result_keys,
        "owner": owner,
        "rule": "Canonical PowerNode placement result.",
        "runtime_proof": proof,
        "source_slice": slice_id,
        "status": "source-backed",
    })


def main() -> None:
    change_owner = "PortGame.source_power_node_change_placement_path_state"
    change_method = "changePlacementPath(Seq<Point2> points, int rotation)"
    change_input = "source_power_node_change_placement_path_input"
    change_result = "source_power_node_change_placement_path_result"
    change_exprs = {
        "method": "public void changePlacementPath(Seq<Point2> points, int rotation){",
        "calculate_nodes_expr": "Placement.calculateNodes(points, this, rotation, (point, other) -> overlaps(world.tile(point.x, point.y), world.tile(other.x, other.y)));",
    }
    change_inputs = {
        "points": ("Variant", "points"),
        "rotation": ("int", "rotation"),
        "placement_result": ("Dictionary", "Placement.calculateNodes(...)"),
    }
    change_results = {
        key: source_key(change_owner, change_method, expression, "String")
        for key, expression in change_exprs.items()
    }
    change_results.update({
        "points": source_key(change_owner, change_method, "points", "Variant", "explicit-input"),
        "rotation": source_key(change_owner, change_method, "rotation", "int", "explicit-input"),
        "placement_result": source_key(change_owner, change_method, "Placement.calculateNodes(...)", "Dictionary", "explicit-input"),
        "calculated_points": source_key(change_owner, change_method, "Placement.calculateNodes(points, this, rotation, ...)", "Variant", "derived"),
        "world_overlap_dependency": source_key(change_owner, change_method, "overlaps(world.tile(point.x, point.y), world.tile(other.x, other.y))", "bool", "explicit-input"),
    })
    register_slice(change_owner, "N1934", change_method, change_exprs, change_inputs, change_results, change_input, change_result)

    draw_owner = "PortGame.source_power_node_draw_place_state"
    draw_method = "drawPlace(int x, int y, int rotation, boolean valid)"
    draw_input = "source_power_node_draw_place_input"
    draw_result = "source_power_node_draw_place_result"
    draw_exprs = {
        "method": "public void drawPlace(int x, int y, int rotation, boolean valid){",
        "tile_expr": "Tile tile = world.tile(x, y);",
        "guard_expr": "if(tile == null || !autolink) return;",
        "stroke_expr": "Lines.stroke(1f);",
        "color_expr": "Draw.color(Pal.placing);",
        "circle_expr": "Drawf.circles(x * tilesize + offset, y * tilesize + offset, laserRange * tilesize);",
        "link_expr": "getPotentialLinks(tile, player.team(), other -> {",
        "laser_color_expr": "Draw.color(laserColor1, Renderer.laserOpacity * 0.5f);",
        "laser_expr": "drawLaser(x * tilesize + offset, y * tilesize + offset, other.x, other.y, size, other.block.size);",
        "square_expr": "Drawf.square(other.x, other.y, other.block.size * tilesize / 2f + 2f, Pal.place);",
        "reset_expr": "Draw.reset();",
    }
    draw_inputs = {
        "x": ("int", "x"),
        "y": ("int", "y"),
        "rotation": ("int", "rotation"),
        "valid": ("bool", "valid"),
        "draw_input": ("Dictionary", "world.tile, autolink, player.team(), getPotentialLinks, renderer inputs"),
    }
    draw_results = {
        key: source_key(draw_owner, draw_method, expression, "String")
        for key, expression in draw_exprs.items()
    }
    draw_results.update({
        "x": source_key(draw_owner, draw_method, "x", "int", "explicit-input"),
        "y": source_key(draw_owner, draw_method, "y", "int", "explicit-input"),
        "rotation": source_key(draw_owner, draw_method, "rotation", "int", "explicit-input"),
        "valid": source_key(draw_owner, draw_method, "valid", "bool", "explicit-input"),
        "draw_input": source_key(draw_owner, draw_method, "world.tile, autolink, player.team(), getPotentialLinks, renderer inputs", "Dictionary", "explicit-input"),
        "skipped": source_key(draw_owner, draw_method, "tile == null || !autolink", "bool", "derived"),
        "commands": source_key(draw_owner, draw_method, "drawPlace orchestration", "Array", "derived"),
        "potential_links_dependency": source_key(draw_owner, draw_method, "getPotentialLinks(tile, player.team(), other -> {", "bool", "explicit-input"),
    })
    register_slice(draw_owner, "N1935", draw_method, draw_exprs, draw_inputs, draw_results, draw_input, draw_result)

    potential_owner = "PortGame.source_power_node_get_potential_links_state"
    potential_method = "getPotentialLinks(Tile tile, Team team, Cons<Building> others)"
    potential_input = "source_power_node_get_potential_links_input"
    potential_result = "source_power_node_get_potential_links_result"
    potential_exprs = {
        "method": "protected void getPotentialLinks(Tile tile, Team team, Cons<Building> others){",
        "guard_expr": "if(!autolink) return;",
        "valid_expr": "other != null && other.tile != tile && other.block.connectedPower && other.power != null",
        "range_expr": "overlaps(tile.x * tilesize + offset, tile.y * tilesize + offset, other.tile, laserRange * tilesize)",
        "sort_expr": "type = -Boolean.compare(a.block instanceof PowerNode, b.block instanceof PowerNode);",
        "distance_expr": "return Float.compare(a.dst2(tile), b.dst2(tile));",
    }
    potential_inputs = {"link_input": ("Dictionary", "world/team/building tree/graph candidate inputs")}
    potential_results = {
        key: source_key(potential_owner, potential_method, expression, "String")
        for key, expression in potential_exprs.items()
    }
    potential_results.update({
        "link_input": source_key(potential_owner, potential_method, "world/team/building tree/graph candidate inputs", "Dictionary", "explicit-input"),
        "autolink": source_key(potential_owner, potential_method, "autolink", "bool", "derived"),
        "graphs": source_key(potential_owner, potential_method, "graphs.add(t.power.graph);", "Array", "derived"),
        "valid_candidates": source_key(potential_owner, potential_method, "valid.get(build)", "Array", "derived"),
        "selected_links": source_key(potential_owner, potential_method, "others.get(t);", "Array", "derived"),
        "returned_count": source_key(potential_owner, potential_method, "returnInt ++ < maxNodes", "int", "derived"),
    })
    register_slice(potential_owner, "N1936", potential_method, potential_exprs, potential_inputs, potential_results, potential_input, potential_result)

    node_owner = "PortGame.source_power_node_get_node_links_state"
    node_method = "getNodeLinks(Tile tile, Block block, Team team, Cons<Building> others)"
    node_input = "source_power_node_get_node_links_input"
    node_result = "source_power_node_get_node_links_result"
    node_exprs = {
        "method": "public static void getNodeLinks(Tile tile, Block block, Team team, Cons<Building> others){",
        "valid_expr": "other != null && other.tile != tile && other.block instanceof PowerNode node",
        "range_expr": "node.overlaps(other.x, other.y, tile, block, node.laserRange * tilesize)",
    }
    node_inputs = {"link_input": ("Dictionary", "world/team/building tree/graph candidate inputs")}
    node_results = {
        key: source_key(node_owner, node_method, expression, "String")
        for key, expression in node_exprs.items()
    }
    node_results.update({
        "link_input": source_key(node_owner, node_method, "world/team/building tree/graph candidate inputs", "Dictionary", "explicit-input"),
        "graphs": source_key(node_owner, node_method, "graphs.add(t.power.graph);", "Array", "derived"),
        "valid_candidates": source_key(node_owner, node_method, "valid.get(build)", "Array", "derived"),
        "selected_links": source_key(node_owner, node_method, "others.get(t);", "Array", "derived"),
        "returned_count": source_key(node_owner, node_method, "tempBuilds.each(valid, t -> {", "int", "derived"),
    })
    register_slice(node_owner, "N1937", node_method, node_exprs, node_inputs, node_results, node_input, node_result)

    plan_owner = "PortGame.source_power_node_draw_plan_config_top_state"
    plan_method = "drawPlanConfigTop(BuildPlan plan, Eachable<BuildPlan> list)"
    plan_input = "source_power_node_draw_plan_config_top_input"
    plan_result = "source_power_node_draw_plan_config_top_result"
    plan_exprs = {
        "method": "public void drawPlanConfigTop(BuildPlan plan, Eachable<BuildPlan> list){",
        "guard_expr": "if(plan.config instanceof Point2[] ps){",
        "setup_expr": "setupColor(1f);",
        "find_expr": "var otherReq = findPlan(list, currentFindX, currentFindY, planFinder);",
        "null_expr": "if(otherReq == null || otherReq.block == null) continue;",
        "draw_expr": "drawLaser(plan.drawx(), plan.drawy(), otherReq.drawx(), otherReq.drawy(), size, otherReq.block.size, false);",
        "reset_expr": "Draw.color();",
    }
    plan_inputs = {"plan_input": ("Dictionary", "plan config and findPlan results")}
    plan_results = {
        key: source_key(plan_owner, plan_method, expression, "String")
        for key, expression in plan_exprs.items()
    }
    plan_results.update({
        "plan_input": source_key(plan_owner, plan_method, "plan config and findPlan results", "Dictionary", "explicit-input"),
        "config_present": source_key(plan_owner, plan_method, "plan.config instanceof Point2[] ps", "bool", "derived"),
        "commands": source_key(plan_owner, plan_method, "drawLaser(plan.drawx(), plan.drawy(), ...)", "Array", "derived"),
    })
    register_slice(plan_owner, "N1938", plan_method, plan_exprs, plan_inputs, plan_results, plan_input, plan_result)

    balance_slices = (
        {
            "id": "N1939",
            "name": "make_power_balance",
            "owner": "PortGame.source_power_node_make_power_balance_state",
            "method": "makePowerBalance()",
            "expressions": {
                "method": "public static Func<Building, Bar> makePowerBalance(){",
                "label_expr": 'Core.bundle.format("bar.powerbalance", ((entity.power.graph.getPowerBalance() >= 0 ? "+" : "") + UI.formatAmount((long)(entity.power.graph.getPowerBalance() * 60))))',
                "fill_expr": "Mathf.clamp(entity.power.graph.getLastPowerProduced() / entity.power.graph.getLastPowerNeeded())",
            },
        },
        {
            "id": "N1940",
            "name": "make_battery_balance",
            "owner": "PortGame.source_power_node_make_battery_balance_state",
            "method": "makeBatteryBalance()",
            "expressions": {
                "method": "public static Func<Building, Bar> makeBatteryBalance(){",
                "label_expr": 'Core.bundle.format("bar.powerstored", (UI.formatAmount((long)entity.power.graph.getLastPowerStored())), UI.formatAmount((long)entity.power.graph.getLastCapacity()))',
                "fill_expr": "Mathf.clamp(entity.power.graph.getLastPowerStored() / entity.power.graph.getLastCapacity())",
            },
        },
    )
    for entry in balance_slices:
        owner = entry["owner"]
        method = entry["method"]
        input_name = "source_power_node_" + entry["name"] + "_input"
        result_name = "source_power_node_" + entry["name"] + "_result"
        expressions = entry["expressions"]
        inputs = {"graph_input": ("Dictionary", "PowerGraph runtime values")}
        results = {key: source_key(owner, method, expression, "String") for key, expression in expressions.items()}
        results.update({
            "graph_input": source_key(owner, method, "PowerGraph runtime values", "Dictionary", "explicit-input"),
            "formatted_label": source_key(owner, method, "Core.bundle.format(...)", "String", "explicit-input"),
            "fill": source_key(owner, method, "Mathf.clamp(...)", "float", "derived"),
        })
        register_slice(owner, entry["id"], method, expressions, inputs, results, input_name, result_name)

    bars_owner = "PortGame.source_power_node_set_bars_state"
    bars_method = "setBars()"
    bars_input = "source_power_node_set_bars_input"
    bars_result = "source_power_node_set_bars_result"
    bars_exprs = {
        "method": "public void setBars(){",
        "super_expr": "super.setBars();",
        "power_expr": 'addBar("power", makePowerBalance());',
        "batteries_expr": 'addBar("batteries", makeBatteryBalance());',
        "connections_expr": 'Core.bundle.format("bar.powerlines", entity.power.links.size, maxNodes)',
    }
    bars_inputs = {"bars_input": ("Dictionary", "super bars, PowerGraph values, and link counts")}
    bars_results = {key: source_key(bars_owner, bars_method, expression, "String") for key, expression in bars_exprs.items()}
    bars_results.update({
        "bars_input": source_key(bars_owner, bars_method, "super bars, PowerGraph values, and link counts", "Dictionary", "explicit-input"),
        "super_set_bars_state": source_key(bars_owner, bars_method, "super.setBars();", "Dictionary", "explicit-input"),
        "power_balance": source_key(bars_owner, bars_method, "makePowerBalance()", "Dictionary", "derived"),
        "battery_balance": source_key(bars_owner, bars_method, "makeBatteryBalance()", "Dictionary", "derived"),
        "connections": source_key(bars_owner, bars_method, 'Core.bundle.format("bar.powerlines", entity.power.links.size, maxNodes)', "Dictionary", "derived"),
    })
    register_slice(bars_owner, "N1941", bars_method, bars_exprs, bars_inputs, bars_results, bars_input, bars_result)

    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
