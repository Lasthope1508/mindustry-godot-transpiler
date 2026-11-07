from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
OWNER = "PortGame.source_building_navigation_state"
PROOF = "/root/Main.BuildingNavigationStateModuleProof"
TESTS = ["test_building_navigation_slice.py", "test_emitter.py", "test_source_parity.py"]


def symbol(name: str, expression: str, method: str, rule: str) -> tuple[str, dict]:
    return name, {
        "status": "source-backed",
        "godot_owner": OWNER,
        "godot_symbol": f"source_building_navigation_result.{name.rsplit('.', 1)[-1]}",
        "rule": rule,
        "tests": TESTS,
        "runtime_proof": PROOF,
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expression,
    }


def main() -> None:
    ledger = source_symbols.load_source_slice_ledger(GODOT)
    for stale_slice_id in ("N1917", "N1923"):
        stale_each_edge = ledger.get("slices", {}).get(stale_slice_id, {})
        if stale_each_edge.get("godot_owner") == OWNER and stale_each_edge.get("java_method") == "eachEdge(Cons<Tile>)":
            ledger["slices"].pop(stale_slice_id)
        source_ssot.write_json(GODOT, "slice_ledger", ledger)
    definitions = [
        ("N1903", "nearby(int,int)", ["public Building nearby(int dx, int dy){", "return world.build(tile.x + dx, tile.y + dy);"], "building_nearby_delta", "Nearby delta delegates through world.build, never world.tile."),
        ("N1904", "nearby(int)", ["public Building nearby(int rotation){", "case 0 -> world.build(tile.x + 1, tile.y);", "case 3 -> world.build(tile.x, tile.y - 1);"], "building_nearby_rotation", "Nearby rotation preserves the source cardinal switch and null default."),
        ("N1905", "relativeTo(Tile)", ["public byte relativeTo(Tile tile){", "return relativeTo(tile.x, tile.y);"], "building_relative_to_tile", "Tile overload delegates to absolute tile-relative semantics."),
        ("N1906", "relativeTo(Building)", ["public byte relativeTo(Building build){", "if(Math.abs(x - build.x) > Math.abs(y - build.y)){", "return -1;"], "building_relative_to_building", "Building overload uses source world-position dominant-axis logic."),
        ("N1907", "relativeToEdge(Tile)", ["public byte relativeToEdge(Tile other){", "return relativeTo(Edges.getFacingEdge(other, tile));"], "building_relative_to_edge", "Facing edge is calculated from the other tile before this building resolves direction."),
        ("N1908", "relativeTo(int,int)", ["public byte relativeTo(int cx, int cy){", "return tile.absoluteRelativeTo(cx, cy);"], "building_relative_to_coordinates", "Coordinate overload reuses Tile.absoluteRelativeTo."),
        ("N1909", "front()/back()", ["public @Nullable Building front(){", "public @Nullable Building back(){", "int trns = block.size/2 + 1;"], "building_navigation_front_back", "Front and back share the exact multiblock distance rule."),
        ("N1910", "left()/right()", ["public @Nullable Building left(){", "public @Nullable Building right(){", "int trns = block.size/2 + 1;"], "building_navigation_left_right", "Left and right share the exact multiblock distance rule."),
        ("N1916", "findClosestEdge(Position,Boolf<Tile>)", ["public @Nullable Tile findClosestEdge(Position to, Boolf<Tile> solid){", "if(to == null) return null;", "for(var point : Edges.getEdges(block.size)){", "Tile other = Vars.world.tile(tile.x + point.x, tile.y + point.y);", "if(other != null && !solid.get(other) && (best == null || to.dst2(other) < mindst)){", "mindst = other.dst2(to);"], "building_find_closest_edge", "Closest-edge selection reuses canonical Edges offsets, uses World.tile rather than World.build, and preserves first-valid selection order."),
        ("N1950", "eachEdge(Cons<Tile>)", ["public void eachEdge(Cons<Tile> cons){", "for(var edge : block.getEdges()){", "Tile other = world.tile(tile.x + edge.x, tile.y + edge.y);", "if(other != null){", "cons.get(other);"], "building_each_edge", "eachEdge preserves block.getEdges ordering, world.tile lookup, null filtering, and Cons callback dispatch."),
    ]
    all_symbols: dict[str, dict] = {}
    for slice_id, method, expressions, prefix, rule in definitions:
        entries = [symbol(f"{prefix}.method", expressions[0], method, rule)]
        for index, expression in enumerate(expressions[1:], start=1):
            entries.append(symbol(f"{prefix}.expr_{index}", expression, method, rule))
        source_symbols.upsert_source_slice(GODOT, slice_id, {
            "status": "done",
            "java_source": SOURCE,
            "java_class": "mindustry.entities.comp.BuildingComp",
            "java_method": method,
            "godot_owner": OWNER,
            "exact_exprs": expressions,
            "source_symbols": [name for name, _entry in entries],
            "tests": TESTS,
            "runtime_proof": PROOF,
            "rule": rule,
        })
        all_symbols.update(dict(entries))
    source_symbols.upsert_source_api_contract(GODOT, OWNER, {
        "status": "active",
        "source_slice": "N1903",
        "java_source": SOURCE,
        "source_method": "BuildingComp navigation overload group",
        "params": [{"name": "world_build_lookup", "type": "Callable", "schema": "source_building_navigation_input.world_build_lookup"}, {"name": "world_tile_lookup", "type": "Callable", "schema": "source_building_navigation_input.world_tile_lookup"}, {"name": "solid_lookup", "type": "Callable", "schema": "source_building_navigation_input.solid_lookup"}, {"name": "block_edges_lookup", "type": "Callable", "schema": "source_building_navigation_input.block_edges_lookup"}, {"name": "cons_callback", "type": "Callable", "schema": "source_building_navigation_input.cons_callback"}],
        "return_keys": ["nearby", "relative_to", "facing_edge", "multiblock_neighbor", "closest_edge", "each_edge", "visited_tiles", "callback_count", "callback_called"],
        "tests": TESTS,
        "runtime_proof": PROOF,
        "rule": "One canonical navigation owner preserves BuildingComp world.build lookup and source geometry delegates across the overload group.",
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_navigation_input", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            "world_build_lookup": {"type": "Callable", "status": "explicit-input", "java_source": SOURCE, "java_expr": "world.build(...)", "rule": "Explicit World.build lookup dependency."},
            "world_tile_lookup": {"type": "Callable", "status": "explicit-input", "java_source": SOURCE, "java_expr": "Vars.world.tile(...)", "rule": "Explicit World.tile lookup dependency for closest-edge tiles."},
            "solid_lookup": {"type": "Callable", "status": "explicit-input", "java_source": SOURCE, "java_expr": "solid.get(other)", "rule": "Explicit Boolf<Tile> solidity predicate."},
            "block_edges_lookup": {"type": "Callable", "status": "explicit-input", "java_source": SOURCE, "java_expr": "block.getEdges()", "rule": "Explicit Block edge-offset lookup preserving source ordering."},
            "cons_callback": {"type": "Callable", "status": "explicit-input", "java_source": SOURCE, "java_expr": "cons.get(other)", "rule": "Explicit Cons<Tile> callback dependency."},
        },
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_navigation_result", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            "nearby": {"type": "Variant", "status": "source-backed", "java_source": SOURCE, "java_expr": "return world.build(tile.x + dx, tile.y + dy);", "rule": "Returned nearby Building or null."},
            "relative_to": {"type": "int", "status": "source-backed", "java_source": SOURCE, "java_expr": "return tile.absoluteRelativeTo(cx, cy);", "rule": "Canonical tile-relative direction."},
            "facing_edge": {"type": "int", "status": "source-backed", "java_source": SOURCE, "java_expr": "return relativeTo(Edges.getFacingEdge(other, tile));", "rule": "Direction via source facing-edge selection."},
            "multiblock_neighbor": {"type": "Variant", "status": "source-backed", "java_source": SOURCE, "java_expr": "int trns = block.size/2 + 1;", "rule": "Returned neighbor at multiblock edge distance."},
            "closest_edge": {"type": "Variant", "status": "source-backed", "java_source": SOURCE, "java_expr": "if(other != null && !solid.get(other) && (best == null || to.dst2(other) < mindst)){", "rule": "Nearest non-solid edge Tile or null."},
            "each_edge": {"type": "Dictionary", "status": "source-backed", "java_source": SOURCE, "java_expr": "for(var edge : block.getEdges()){", "rule": "Canonical edge traversal result."},
            "visited_tiles": {"type": "Array", "status": "source-backed", "java_source": SOURCE, "java_expr": "if(other != null){", "rule": "Non-null World.tile results in source edge order."},
            "callback_count": {"type": "int", "status": "source-backed", "java_source": SOURCE, "java_expr": "cons.get(other);", "rule": "Count of callback dispatches."},
            "callback_called": {"type": "bool", "status": "source-backed", "java_source": SOURCE, "java_expr": "cons.get(other);", "rule": "Whether the Cons callback received at least one tile."},
        },
    })
    source_symbols.upsert_source_symbols(GODOT, all_symbols)
    registry = source_symbols.load_source_symbol_registry(GODOT)
    aliases = registry.setdefault("policy", {}).setdefault("canonicalOwnerAliases", {})
    aliases["port_game.source_building_each_edge_state"] = "port_game.source_building_navigation_state"
    source_ssot.write_json(GODOT, "registry", registry)
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
