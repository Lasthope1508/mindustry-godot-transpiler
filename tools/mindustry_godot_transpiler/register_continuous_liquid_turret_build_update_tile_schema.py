from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java"
OWNER = "PortGame.source_continuous_liquid_turret_build_update_tile_state"
PROOF = "/root/Main.source_continuous_liquid_turret_build_update_tile_state"
METHOD = "ContinuousLiquidTurretBuild.updateTile()"


def source_key(type_name: str, expression: str, rule: str) -> dict:
    return {"type": type_name, "status": "source-backed", "java_source": SOURCE, "java_method": METHOD, "java_expr": expression, "rule": rule, "used_by": [OWNER.lower()]}


def input_alias(type_name: str, name: str) -> dict:
    return {"type": type_name, "status": "explicit-input", "alias_of": f"source_continuous_liquid_turret_build_update_tile_input.{name}", "used_by": [OWNER.lower()]}


def main() -> None:
    keys = {
        "source_owner": {"type": "String", "status": "generated", "alias_of": OWNER.lower(), "used_by": [OWNER.lower()]},
        "inner_class": source_key("String", "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{", "Inner build class boundary."),
        "field": source_key("String", "boolean activated;", "Activation state field."),
        "override_expr": source_key("String", "@Override", "Override annotation."),
        "super_update_tile_expr": source_key("String", "super.updateTile();", "Inherited update dispatch."),
        "super_update_tile_called": source_key("bool", "super.updateTile();", "Evaluated inherited update dispatch."),
        "comment": source_key("String", "//only allow the turret to begin firing when it can fire for 4 continuous updates", "Source activation policy comment."),
        "activate_guard_expr": source_key("String", "if(liquids.currentAmount() >= liquidConsumed * 4f){", "Activation threshold guard."),
        "activated_true_expr": source_key("String", "activated = true;", "Activation assignment."),
        "deactivate_guard_expr": source_key("String", "}else if(liquids.currentAmount() < liquidConsumed){", "Deactivation threshold guard."),
        "activated_false_expr": source_key("String", "activated = false;", "Deactivation assignment."),
        "current_amount": input_alias("float", "current_amount"),
        "liquid_consumed": input_alias("float", "liquid_consumed"),
        "activated_before": input_alias("bool", "activated_before"),
    }
    source_symbols.upsert_source_state_schema(GODOT, "source_continuous_liquid_turret_build_update_tile_result", {"status": "active", "owner": OWNER, "runtime_proof": PROOF, "source_slice": "N1222", "rule": "Dictionary returned by the source-backed ContinuousLiquidTurretBuild.updateTile state.", "keys": {**source_symbols.load_source_state_schema(GODOT)["schemas"]["source_continuous_liquid_turret_build_update_tile_result"]["keys"], **keys}})
    for name in ("defense_slices", "defense_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
