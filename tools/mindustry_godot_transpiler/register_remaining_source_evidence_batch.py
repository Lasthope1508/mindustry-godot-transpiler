"""Register a small batch whose exact upstream symbols already exist."""

from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    schemas = catalog["schemas"]
    additions = {
        "source_block_post_init_shown_planets_result": {
            "auto_assign_guard_expr": ("core/src/mindustry/world/Block.java", "Block.postInit()", "if(requirements.length > 0 && shownPlanets.isEmpty(){"),
            "planet_landable_guard_expr": ("core/src/mindustry/world/Block.java", "Block.postInit()", "if(planet.isLandable()){"),
            "structs_contains_guard_expr": ("core/src/mindustry/world/Block.java", "Block.postInit()", "if(!Structs.contains(requirements, s -> !s.item.isOnPlanet(planet))){"),
            "shown_planets_add_expr": ("core/src/mindustry/world/Block.java", "Block.postInit()", "shownPlanets.add(planet);"),
        },
        "source_consume_liquid_filter_build_result": {
            "multi_req_image_class": ("core/src/mindustry/ui/MultiReqImage.java", "MultiReqImage", "public class MultiReqImage extends Stack{"),
            "multi_req_image_add_expr": ("core/src/mindustry/ui/MultiReqImage.java", "add(ReqImage display)", "public void add(ReqImage display){"),
            "req_image_constructor": ("core/src/mindustry/ui/ReqImage.java", "ReqImage(Element image, Boolp valid)", "public ReqImage(Element image, Boolp valid){"),
            "req_image_valid_expr": ("core/src/mindustry/ui/ReqImage.java", "valid()", "public boolean valid(){"),
            "cell_size_expr": ("arc-core/src/arc/scene/ui/layout/Cell.java", "size(float size)", "public Cell<T> size(float size){"),
        },
        "source_continuous_liquid_turret_set_stats_result": {
            "ammo_values_call": ("core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java", "LiquidTurret.setStats()", "StatValues.ammo(ammoTypes, name)"),
        },
    }
    for schema_name, keys in additions.items():
        for name, (java_source, java_method, java_expr) in keys.items():
            schemas[schema_name]["keys"][name] = {
                "type": "String",
                "status": "source-backed",
                "java_source": java_source,
                "java_method": java_method,
                "java_expr": java_expr,
                "rule": "Exact upstream expression already registered by the canonical source symbol registry.",
            }
    errors = source_symbols.validate_source_state_schema(catalog)
    if errors:
        raise ValueError("invalid source evidence batch: " + "; ".join(errors))
    source_ssot.write_json(GODOT, "state_schema", catalog)
    for module in source_ssot.registered_modules(GODOT):
        if module.canonical_module == "state_schema":
            source_ssot.write_registered_json(GODOT, module.name, source_ssot.build_extension_shard(GODOT, module.name))
    source_symbols.write_source_symbol_audit_report(GODOT)
    print("registered_remaining_source_evidence=10")


if __name__ == "__main__":
    main()
