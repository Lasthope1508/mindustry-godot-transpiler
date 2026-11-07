from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/power/PowerGenerator.java"


def k(owner: str, method: str, expression: str, type_name: str = "String", status: str = "source-backed") -> dict:
    return {"type": type_name, "status": status, "java_source": SOURCE, "java_method": method, "java_expr": expression, "rule": "Exact upstream PowerGenerator lifecycle expression.", "used_by": [owner.lower()]}


def register_load() -> None:
    owner = "PortGame.source_power_generator_load_state"
    proof = "/root/Main.source_power_generator_load_state"
    method = "load()"
    slice_id = "N1925"
    symbols = {
        "power_generator_load.method": {"godot_owner": owner, "godot_symbol": "source_power_generator_load_result.method", "java_expr": "public void load(){", "java_method": method, "java_source": SOURCE, "rule": "PowerGenerator.load method boundary.", "runtime_proof": proof, "source_slice": slice_id, "status": "source-backed", "tests": ["test_power_generator_load_and_draw_plan_region_match_upstream_source"]},
        "power_generator_load.super_load": {"godot_owner": owner, "godot_symbol": "source_power_generator_load_result.super_load_expr", "java_expr": "super.load();", "java_method": method, "java_source": SOURCE, "rule": "PowerGenerator delegates superclass loading first.", "runtime_proof": proof, "source_slice": slice_id, "status": "source-backed", "tests": ["test_power_generator_load_and_draw_plan_region_match_upstream_source"]},
        "power_generator_load.drawer_load": {"godot_owner": owner, "godot_symbol": "source_power_generator_load_result.drawer_load_expr", "java_expr": "drawer.load(this);", "java_method": method, "java_source": SOURCE, "rule": "PowerGenerator loads its drawer after superclass load.", "runtime_proof": proof, "source_slice": slice_id, "status": "source-backed", "tests": ["test_power_generator_load_and_draw_plan_region_match_upstream_source"]},
    }
    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.upsert_source_slice(GODOT, slice_id, {"exact_exprs": ["public void load(){", "super.load();", "drawer.load(this);"], "deferred_exprs": ["Texture icon production remains in the separate icons slice."], "godot_owner": owner, "java_class": "mindustry.world.blocks.power.PowerGenerator", "java_method": method, "java_source": SOURCE, "rule": "Registers PowerGenerator.load lifecycle state.", "runtime_proof": proof, "source_symbols": list(symbols), "status": "done", "tests": ["test_power_generator_load_and_draw_plan_region_match_upstream_source"]})
    source_symbols.upsert_source_api_contract(GODOT, owner, {"java_source": SOURCE, "params": [{"name": "super_load_state", "schema": "source_power_generator_load_input.super_load_state", "type": "Dictionary"}, {"name": "drawer_load_state", "schema": "source_power_generator_load_input.drawer_load_state", "type": "Dictionary"}], "return_keys": ["method", "super_load_expr", "drawer_load_expr", "super_load_state", "drawer_load_state", "super_load_called", "drawer_load_called"], "rule": "Public runtime contract for PowerGenerator.load state.", "runtime_proof": proof, "source_method": method, "source_slice": slice_id, "status": "source-backed", "tests": ["test_power_generator_load_and_draw_plan_region_match_upstream_source"]})
    source_symbols.upsert_source_state_schema(GODOT, "source_power_generator_load_input", {"keys": {"super_load_state": {"type": "Dictionary", "status": "explicit-input", "java_source": SOURCE, "java_method": method, "java_expr": "super.load();", "rule": "Injected superclass load state.", "used_by": [owner.lower()]}, "drawer_load_state": {"type": "Dictionary", "status": "explicit-input", "java_source": SOURCE, "java_method": method, "java_expr": "drawer.load(this);", "rule": "Injected drawer load state.", "used_by": [owner.lower()]}}, "owner": owner, "rule": "Inputs for PowerGenerator.load state.", "runtime_proof": proof, "source_slice": slice_id, "status": "source-backed"})
    source_symbols.upsert_source_state_schema(GODOT, "source_power_generator_load_result", {"keys": {"method": k(owner, method, "public void load(){"), "super_load_expr": k(owner, method, "super.load();"), "drawer_load_expr": k(owner, method, "drawer.load(this);"), "super_load_state": {"type": "Dictionary", "status": "generated", "alias_of": "source_power_generator_load_input.super_load_state", "used_by": [owner.lower()]}, "drawer_load_state": {"type": "Dictionary", "status": "generated", "alias_of": "source_power_generator_load_input.drawer_load_state", "used_by": [owner.lower()]}, "super_load_called": k(owner, method, "super.load();", "bool"), "drawer_load_called": k(owner, method, "drawer.load(this);", "bool")}, "owner": owner, "rule": "Result schema for PowerGenerator.load state.", "runtime_proof": proof, "source_slice": slice_id, "status": "source-backed"})


def register_draw_plan_region() -> None:
    owner = "PortGame.source_power_generator_draw_plan_region_state"
    proof = "/root/Main.source_power_generator_draw_plan_region_state"
    method = "drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list)"
    slice_id = "N1926"
    symbols = {
        "power_generator_draw_plan_region.method": {"godot_owner": owner, "godot_symbol": "source_power_generator_draw_plan_region_result.method", "java_expr": "public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){", "java_method": method, "java_source": SOURCE, "rule": "PowerGenerator.drawPlanRegion method boundary.", "runtime_proof": proof, "source_slice": slice_id, "status": "source-backed", "tests": ["test_power_generator_load_and_draw_plan_region_match_upstream_source"]},
        "power_generator_draw_plan_region.drawer_draw_plan": {"godot_owner": owner, "godot_symbol": "source_power_generator_draw_plan_region_result.drawer_draw_plan_expr", "java_expr": "drawer.drawPlan(this, plan, list);", "java_method": method, "java_source": SOURCE, "rule": "PowerGenerator delegates plan drawing to drawer.", "runtime_proof": proof, "source_slice": slice_id, "status": "source-backed", "tests": ["test_power_generator_load_and_draw_plan_region_match_upstream_source"]},
    }
    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.upsert_source_slice(GODOT, slice_id, {"exact_exprs": ["public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){", "drawer.drawPlan(this, plan, list);"], "deferred_exprs": ["Drawer implementation remains an injected dependency.",], "godot_owner": owner, "java_class": "mindustry.world.blocks.power.PowerGenerator", "java_method": method, "java_source": SOURCE, "rule": "Registers PowerGenerator.drawPlanRegion delegation state.", "runtime_proof": proof, "source_symbols": list(symbols), "status": "done", "tests": ["test_power_generator_load_and_draw_plan_region_match_upstream_source"]})
    source_symbols.upsert_source_api_contract(GODOT, owner, {"java_source": SOURCE, "params": [{"name": "plan", "schema": "source_power_generator_draw_plan_region_input.plan", "type": "Variant"}, {"name": "list", "schema": "source_power_generator_draw_plan_region_input.list", "type": "Variant"}, {"name": "drawer_draw_plan_state", "schema": "source_power_generator_draw_plan_region_input.drawer_draw_plan_state", "type": "Dictionary"}], "return_keys": ["method", "drawer_draw_plan_expr", "plan", "list", "drawer_draw_plan_state", "drawer_draw_plan_called"], "rule": "Public runtime contract for PowerGenerator.drawPlanRegion state.", "runtime_proof": proof, "source_method": method, "source_slice": slice_id, "status": "source-backed", "tests": ["test_power_generator_load_and_draw_plan_region_match_upstream_source"]})
    source_symbols.upsert_source_state_schema(GODOT, "source_power_generator_draw_plan_region_input", {"keys": {"plan": {"type": "Variant", "status": "explicit-input", "java_source": SOURCE, "java_method": method, "java_expr": "BuildPlan plan", "rule": "Injected build plan.", "used_by": [owner.lower()]}, "list": {"type": "Variant", "status": "explicit-input", "java_source": SOURCE, "java_method": method, "java_expr": "Eachable<BuildPlan> list", "rule": "Injected plan list.", "used_by": [owner.lower()]}, "drawer_draw_plan_state": {"type": "Dictionary", "status": "explicit-input", "java_source": SOURCE, "java_method": method, "java_expr": "drawer.drawPlan(this, plan, list);", "rule": "Injected drawer plan state.", "used_by": [owner.lower()]}}, "owner": owner, "rule": "Inputs for PowerGenerator.drawPlanRegion state.", "runtime_proof": proof, "source_slice": slice_id, "status": "source-backed"})
    source_symbols.upsert_source_state_schema(GODOT, "source_power_generator_draw_plan_region_result", {"keys": {"method": k(owner, method, "public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){"), "drawer_draw_plan_expr": k(owner, method, "drawer.drawPlan(this, plan, list);"), "plan": {"type": "Variant", "status": "generated", "alias_of": "source_power_generator_draw_plan_region_input.plan", "used_by": [owner.lower()]}, "list": {"type": "Variant", "status": "generated", "alias_of": "source_power_generator_draw_plan_region_input.list", "used_by": [owner.lower()]}, "drawer_draw_plan_state": {"type": "Dictionary", "status": "generated", "alias_of": "source_power_generator_draw_plan_region_input.drawer_draw_plan_state", "used_by": [owner.lower()]}, "drawer_draw_plan_called": k(owner, method, "drawer.drawPlan(this, plan, list);", "bool")}, "owner": owner, "rule": "Result schema for PowerGenerator.drawPlanRegion state.", "runtime_proof": proof, "source_slice": slice_id, "status": "source-backed"})


def main() -> None:
    register_load()
    register_draw_plan_region()
    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
