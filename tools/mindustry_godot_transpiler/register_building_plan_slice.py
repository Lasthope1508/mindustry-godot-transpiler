from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
OWNER = "PortGame.source_building_add_plan_state"
PROOF = "/root/Main.BuildingPlanStateModuleProof"
TESTS = ["test_building_plan_slice.py", "test_emitter.py", "test_source_parity.py"]


def source_symbol(name: str, expression: str, method: str, rule: str) -> tuple[str, dict]:
    return name, {
        "status": "source-backed", "godot_owner": OWNER, "godot_symbol": f"source_building_add_plan_result.{name.rsplit('.', 1)[-1]}",
        "rule": rule, "tests": TESTS, "runtime_proof": PROOF, "java_source": SOURCE, "java_method": method, "java_expr": expression,
    }


def main() -> None:
    definitions = [
        ("N1914", "addPlan(boolean)", ["public void addPlan(boolean checkPrevious){", "addPlan(checkPrevious, false);"], "building_add_plan_default", "One-argument overload preserves the source false ignoreConditions delegate."),
        ("N1915", "addPlan(boolean,boolean)", ["public void addPlan(boolean checkPrevious, boolean ignoreConditions){", "if(!ignoreConditions && (!block.rebuildable || (team == state.rules.defaultTeam && state.isCampaign() && !block.isVisible()))) return;", "if(self() instanceof ConstructBuild entity){", "data.plans.removeIndex(i);", "data.plans.addFirst(new BlockPlan(tile.x, tile.y, (short)rotation, toAdd, overrideConfig == null ? config() : overrideConfig));"], "building_add_plan", "Building plan lifecycle preserves eligibility, construction resume, replacement, and prepend order."),
    ]
    all_symbols: dict[str, dict] = {}
    for slice_id, method, expressions, prefix, rule in definitions:
        entries = [source_symbol(f"{prefix}.method", expressions[0], method, rule)]
        for index, expression in enumerate(expressions[1:], start=1):
            entries.append(source_symbol(f"{prefix}.expr_{index}", expression, method, rule))
        source_symbols.upsert_source_slice(GODOT, slice_id, {
            "status": "done", "java_source": SOURCE, "java_class": "mindustry.entities.comp.BuildingComp", "java_method": method,
            "godot_owner": OWNER, "exact_exprs": expressions, "source_symbols": [name for name, _ in entries], "tests": TESTS,
            "runtime_proof": PROOF, "rule": rule,
        })
        all_symbols.update(dict(entries))
    source_symbols.upsert_source_api_contract(GODOT, OWNER, {
        "status": "active", "source_slice": "N1914", "java_source": SOURCE, "source_method": "BuildingComp.addPlan(boolean[, boolean])",
        "params": [
            {"name": "check_previous", "type": "bool", "schema": "source_building_add_plan_input.check_previous"},
            {"name": "plans", "type": "Array", "schema": "source_building_add_plan_input.plans"},
            {"name": "construct_current", "type": "Variant", "schema": "source_building_add_plan_input.construct_current"},
        ],
        "return_keys": ["source_owner", "plans", "added", "removed_previous", "path", "plan"], "tests": TESTS, "runtime_proof": PROOF,
        "rule": "One canonical owner controls Building plan reinsertion and never owns Block plan geometry/config APIs.",
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_add_plan_input", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            "check_previous": {"type": "bool", "status": "explicit-input", "java_source": SOURCE, "java_expr": "checkPrevious", "rule": "Remove matching prior plan before prepend."},
            "plans": {"type": "Array", "status": "explicit-input", "java_source": SOURCE, "java_expr": "data.plans", "rule": "TeamData plan sequence."},
            "construct_current": {"type": "Variant", "status": "explicit-input", "java_source": SOURCE, "java_expr": "entity.current", "rule": "Synthetic ConstructBuild target block."},
        },
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_add_plan_result", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            "plans": {"type": "Array", "status": "source-backed", "java_source": SOURCE, "java_expr": "data.plans.addFirst(new BlockPlan(tile.x, tile.y, (short)rotation, toAdd, overrideConfig == null ? config() : overrideConfig));", "rule": "Updated team plan sequence."},
            "added": {"type": "bool", "status": "source-backed", "java_source": SOURCE, "java_expr": "data.plans.addFirst(new BlockPlan(tile.x, tile.y, (short)rotation, toAdd, overrideConfig == null ? config() : overrideConfig));", "rule": "Whether source reached plan prepend."},
            "removed_previous": {"type": "bool", "status": "source-backed", "java_source": SOURCE, "java_expr": "data.plans.removeIndex(i);", "rule": "Whether source removed the first coordinate match."},
            "path": {"type": "String", "status": "source-backed", "java_source": SOURCE, "java_expr": "if(!ignoreConditions && (!block.rebuildable || (team == state.rules.defaultTeam && state.isCampaign() && !block.isVisible()))) return;", "rule": "Source branch path."},
            "plan": {"type": "Variant", "status": "source-backed", "java_source": SOURCE, "java_expr": "new BlockPlan(tile.x, tile.y, (short)rotation, toAdd, overrideConfig == null ? config() : overrideConfig)", "rule": "Prepended plan payload."},
        },
    })
    source_symbols.upsert_source_symbols(GODOT, all_symbols)
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
