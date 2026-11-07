from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java"
OWNER = "PortGame.source_liquid_turret_init_state"
PROOF = "/root/Main.source_liquid_turret_init_state"
METHOD = "LiquidTurret.init()"


def source_key(type_name: str, expression: str, rule: str) -> dict:
    return {"type": type_name, "status": "source-backed", "java_source": SOURCE, "java_method": METHOD, "java_expr": expression, "rule": rule, "used_by": [OWNER.lower()]}


def input_alias(type_name: str, name: str) -> dict:
    return {"type": type_name, "status": "explicit-input", "alias_of": f"source_liquid_turret_init_input.{name}", "used_by": [OWNER.lower()]}


def main() -> None:
    keys = {
        "source_owner": {"type": "String", "status": "generated", "alias_of": OWNER.lower(), "used_by": [OWNER.lower()]},
        "override_expr": source_key("String", "@Override", "Override annotation."),
        "consume_expr": source_key("String", "consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), 1f){", "Liquid consumer registration."),
        "filter_expr": source_key("String", "i -> ammoTypes.containsKey(i)", "Accepted-liquid filter predicate."),
        "target_ground_expr": source_key("String", "if(targetGround){", "Ground-target overlap branch."),
        "overlap_expr": source_key("String", "ammoTypes.each((item, type) -> placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin));", "Ammo range overlap aggregation."),
        "super_init_expr": source_key("String", "super.init();", "Inherited init dispatch."),
        "ammo_entries": input_alias("Array", "ammo_entries"),
        "target_ground": input_alias("bool", "target_ground"),
        "place_overlap_range_before": input_alias("float", "place_overlap_range"),
        "range_value": input_alias("float", "range_value"),
        "place_overlap_margin": input_alias("float", "place_overlap_margin"),
        "overlap_updates": source_key("Array", "range + type.rangeChange + placeOverlapMargin", "Evaluated overlap aggregation updates."),
        "place_overlap_range_after": source_key("float", "placeOverlapRange", "Final overlap range after ammo aggregation."),
        "super_init_called": source_key("bool", "super.init();", "Evaluated inherited init dispatch."),
    }
    source_symbols.upsert_source_state_schema(GODOT, "source_liquid_turret_init_result", {"status": "active", "owner": OWNER, "runtime_proof": PROOF, "source_slice": "N1195", "rule": "Dictionary returned by the source-backed LiquidTurret.init state.", "keys": {**source_symbols.load_source_state_schema(GODOT)["schemas"]["source_liquid_turret_init_result"]["keys"], **keys}})
    for name in ("defense_slices", "defense_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
