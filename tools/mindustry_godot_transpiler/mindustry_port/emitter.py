import json
import re
from pathlib import Path
from typing import Any

from mindustry_port.java_ast import parse_source_tree


def gdscript_literal(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True)


def _script_path(java_file: dict, type_entry: dict) -> Path:
    package_path = java_file.get("package", "").replace(".", "/")
    return Path(package_path) / f"{type_entry['name']}.gd"


def _gd_identifier(value: str) -> str:
    identifier = re.sub(r"[^A-Za-z0-9_]", "_", value)
    identifier = re.sub(r"_+", "_", identifier).strip("_")
    if not identifier:
        return "unnamed"
    if identifier[0].isdigit():
        return f"_{identifier}"
    return identifier


def _method_body_lines(java_file: dict, type_entry: dict, method: dict) -> list[str]:
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "getProgressIncrease"
        and method.get("return_type") == "float"
    ):
        return [
            "\tvar base_time := float(_args[0] if _args.size() > 0 else 1.0)",
            "\tvar edelta_value := float(_args[1] if _args.size() > 1 else 1.0)",
            "\treturn 1.0 / base_time * edelta_value",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "getDisplayEfficiency"
        and method.get("return_type") == "float"
    ):
        return [
            "\tvar edelta_value := float(_args[0] if _args.size() > 0 else 1.0)",
            "\treturn (1.0 / 1.0 * edelta_value) / edelta_value",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "shouldAmbientSound"
        and method.get("return_type") == "boolean"
    ):
        return [
            "\tvar should_consume_state := bool(_args[0] if _args.size() > 0 else false)",
            "\treturn should_consume_state",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "drawStatus"
    ):
        return [
            "\tvar enable_draw_status := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar consumers_length := int(_args[1] if _args.size() > 1 else 0)",
            "\tvar block_size_value := int(_args[2] if _args.size() > 2 else 1)",
            "\tvar source_x := float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar source_y := float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar source_tilesize := float(_args[5] if _args.size() > 5 else 8.0)",
            "\tif not (enable_draw_status and consumers_length > 0):",
            "\t\treturn {\"visible\": false}",
            "\tvar multiplier := 1.0 if block_size_value > 1 else 0.64",
            "\tvar brcx := source_x + (float(block_size_value) * source_tilesize / 2.0) - (source_tilesize * multiplier / 2.0)",
            "\tvar brcy := source_y - (float(block_size_value) * source_tilesize / 2.0) + (source_tilesize * multiplier / 2.0)",
            "\treturn {\"visible\": true, \"multiplier\": multiplier, \"brcx\": brcx, \"brcy\": brcy, \"gray_square_size\": 2.5 * multiplier, \"status_square_size\": 1.5 * multiplier}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "drawCracks"
    ):
        return [
            "\tvar draw_cracks := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar damaged_state := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar block_size_value := int(_args[2] if _args.size() > 2 else 1)",
            "\tvar max_crack_size := int(_args[3] if _args.size() > 3 else 0)",
            "\tvar health_fraction := float(_args[4] if _args.size() > 4 else 1.0)",
            "\tvar crack_regions := int(_args[5] if _args.size() > 5 else 1)",
            "\tvar position_id := int(_args[6] if _args.size() > 6 else 0)",
            "\tif not draw_cracks or not damaged_state or block_size_value > max_crack_size:",
            "\t\treturn {\"visible\": false}",
            "\tvar crack_index := clampi(int((1.0 - health_fraction) * float(crack_regions)), 0, crack_regions - 1)",
            "\tvar lightness := 0.1 + (1.0 - health_fraction) * 0.6",
            "\tvar crack_rotation_degrees := (position_id % 4) * 90",
            "\treturn {\"visible\": true, \"region_size_index\": block_size_value - 1, \"crack_index\": crack_index, \"lightness\": lightness, \"rotation_degrees\": crack_rotation_degrees}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "drawSelect"
    ):
        return [
            "\tvar block_status := str(_args[0] if _args.size() > 0 else \"\")",
            "\tvar source_x := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar source_y := float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar source_rotation := float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar tile_x := int(_args[4] if _args.size() > 4 else 0)",
            "\tvar tile_y := int(_args[5] if _args.size() > 5 else 0)",
            "\tvar unit_activation_delay := float(_args[6] if _args.size() > 6 else 0.0)",
            "\tvar state_tick := float(_args[7] if _args.size() > 7 else 0.0)",
            "\tvar inactive_unit_factory := block_status == \"inactiveUnitFactory\"",
            "\tvar remaining_activation_delay := maxf(0.0, unit_activation_delay - state_tick)",
            "\treturn {\"overlay_visible\": true, \"overlay_x\": source_x, \"overlay_y\": source_y, \"overlay_rotation\": source_rotation, \"place_text_visible\": inactive_unit_factory, \"place_text_bundle_key\": \"rules.unitfactoryactivation.objective\", \"place_text_time\": remaining_activation_delay, \"place_text_tile_x\": tile_x, \"place_text_tile_y\": tile_y}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "drawItemSelection"
    ):
        return [
            "\tvar has_selection := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar source_x := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar source_y := float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar block_size_value := int(_args[3] if _args.size() > 3 else 1)",
            "\tvar source_tilesize := float(_args[4] if _args.size() > 4 else 8.0)",
            "\tvar icon_small := float(_args[5] if _args.size() > 5 else 0.0)",
            "\tvar selection_icon_ratio := float(_args[6] if _args.size() > 6 else 1.0)",
            "\tif not has_selection:",
            "\t\treturn {\"visible\": false}",
            "\tvar dx := source_x - float(block_size_value) * source_tilesize / 2.0",
            "\tvar dy := source_y + float(block_size_value) * source_tilesize / 2.0",
            "\tvar selection_width := icon_small / 4.0 * selection_icon_ratio",
            "\tvar selection_height := icon_small / 4.0",
            "\treturn {\"visible\": true, \"dx\": dx, \"dy\": dy, \"shadow_color\": \"darkGray\", \"shadow_alpha\": 1.0, \"shadow_y\": dy - 1.0, \"foreground_y\": dy, \"selection_width\": selection_width, \"selection_height\": selection_height}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "drawDisabled"
    ):
        return [
            "\tvar source_x := float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar source_y := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar disabled_icon_size := 6.0",
            "\treturn {\"visible\": true, \"icon\": \"cancel\", \"color\": \"scarlet\", \"alpha\": 0.8, \"x\": source_x, \"y\": source_y, \"width\": disabled_icon_size, \"height\": disabled_icon_size}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "draw"
    ):
        return [
            "\tvar variants := int(_args[0] if _args.size() > 0 else 0)",
            "\tvar has_variant_regions := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar variant_region_count := int(_args[2] if _args.size() > 2 else 0)",
            "\tvar tile_pos := int(_args[3] if _args.size() > 3 else 0)",
            "\tvar source_x := float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar source_y := float(_args[5] if _args.size() > 5 else 0.0)",
            "\tvar block_rotate := bool(_args[6] if _args.size() > 6 else false)",
            "\tvar block_rotate_draw := bool(_args[7] if _args.size() > 7 else false)",
            "\tvar rotation_quadrants := int(_args[8] if _args.size() > 8 else 0)",
            "\tvar draw_rotation := float(rotation_quadrants * 90) if block_rotate and block_rotate_draw else 0.0",
            "\tif variants == 0 or not has_variant_regions:",
            "\t\treturn {\"visible\": true, \"region_kind\": \"region\", \"variant_index\": -1, \"x\": source_x, \"y\": source_y, \"rotation_degrees\": draw_rotation, \"draw_team_top\": true}",
            "\tvar max_variant_index: int = max(0, variant_region_count - 1)",
            "\tvar variant_index: int = _source_arc_random_seed_int(tile_pos, 0, max_variant_index)",
            "\treturn {\"visible\": true, \"region_kind\": \"variant_region\", \"variant_index\": variant_index, \"x\": source_x, \"y\": source_y, \"rotation_degrees\": draw_rotation, \"draw_team_top\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "drawCached"
    ):
        return [
            "\treturn java_method_draw_128(_args)",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "recache"
    ):
        return [
            "\tvar headless := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar building_cache_layer: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar tile_state: Variant = _args[2] if _args.size() > 2 else null",
            "\tif headless:",
            "\t\treturn {\"method\": \"public void recache(){\", \"headless_gate\": \"if(!headless) renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);\", \"recache_call\": \"\", \"recache\": false, \"building_cache_layer\": building_cache_layer, \"tile\": tile_state}",
            "\treturn {\"method\": \"public void recache(){\", \"headless_gate\": \"if(!headless) renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);\", \"recache_call\": \"renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);\", \"recache\": true, \"building_cache_layer\": building_cache_layer, \"tile\": tile_state}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "payloadDraw"
    ):
        return [
            "\tvar draw_cached := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar draw_dynamic := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar current_z := float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar building_cache_layer_z := float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar variants := int(_args[4] if _args.size() > 4 else 0)",
            "\tvar has_variant_regions := bool(_args[5] if _args.size() > 5 else false)",
            "\tvar variant_region_count := int(_args[6] if _args.size() > 6 else 0)",
            "\tvar tile_pos := int(_args[7] if _args.size() > 7 else 0)",
            "\tvar source_x := float(_args[8] if _args.size() > 8 else 0.0)",
            "\tvar source_y := float(_args[9] if _args.size() > 9 else 0.0)",
            "\tvar block_rotate := bool(_args[10] if _args.size() > 10 else false)",
            "\tvar block_rotate_draw := bool(_args[11] if _args.size() > 11 else false)",
            "\tvar rotation_quadrants := int(_args[12] if _args.size() > 12 else 0)",
            "\tvar draw_args := [variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants]",
            "\tvar cached_draw: Dictionary = {}",
            "\tvar dynamic_draw: Dictionary = {}",
            "\tif draw_cached:",
            "\t\tcached_draw = java_method_drawCached_129(draw_args)",
            "\tif draw_dynamic:",
            "\t\tdynamic_draw = java_method_draw_128(draw_args)",
            "\treturn {\"method\": \"public void payloadDraw(){\", \"saved_z_call\": \"float z = Draw.z();\", \"cached_gate\": \"if(block.drawCached){\" if draw_cached else \"\", \"cached_z_call\": \"Draw.z(block.buildingCacheLayer.layer);\" if draw_cached else \"\", \"cached_draw_call\": \"drawCached();\" if draw_cached else \"\", \"dynamic_gate\": \"if(block.drawDynamic){\" if draw_dynamic else \"\", \"restore_z_call\": \"Draw.z(z);\" if draw_dynamic else \"\", \"dynamic_draw_call\": \"draw();\" if draw_dynamic else \"\", \"saved_z\": current_z, \"cached_visible\": draw_cached, \"cached_z\": building_cache_layer_z, \"cached_draw\": cached_draw, \"dynamic_visible\": draw_dynamic, \"dynamic_z\": current_z, \"dynamic_draw\": dynamic_draw}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "drawTeamTop"
    ):
        return [
            "\tvar team_region_found := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar team_region_matches_team := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar team_color := String(_args[2] if _args.size() > 2 else \"\")",
            "\tvar source_x := float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar source_y := float(_args[4] if _args.size() > 4 else 0.0)",
            "\tif not team_region_found:",
            "\t\treturn {\"visible\": false}",
            "\treturn {\"visible\": true, \"tint_color\": team_color if team_region_matches_team else \"\", \"x\": source_x, \"y\": source_y, \"color_reset\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "drawLight"
    ):
        return [
            "\tvar has_liquids := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar draw_liquid_light := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar light_liquid_is_null := bool(_args[2] if _args.size() > 2 else false)",
            "\tvar current_liquid_color := String(_args[3] if _args.size() > 3 else \"\")",
            "\tvar current_liquid_alpha := float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar light_liquid_color := String(_args[5] if _args.size() > 5 else \"\")",
            "\tvar light_liquid_alpha := float(_args[6] if _args.size() > 6 else 0.0)",
            "\tvar selected_liquid_amount := float(_args[7] if _args.size() > 7 else 0.0)",
            "\tvar visual_liquid := float(_args[8] if _args.size() > 8 else 0.0)",
            "\tvar source_delta := float(_args[9] if _args.size() > 9 else 0.0)",
            "\tvar source_x := float(_args[10] if _args.size() > 10 else 0.0)",
            "\tvar source_y := float(_args[11] if _args.size() > 11 else 0.0)",
            "\tvar block_size_value := int(_args[12] if _args.size() > 12 else 0)",
            "\tvar selected_color: String = current_liquid_color if light_liquid_is_null else light_liquid_color",
            "\tvar selected_alpha: float = current_liquid_alpha if light_liquid_is_null else light_liquid_alpha",
            "\tif not has_liquids or not draw_liquid_light or selected_alpha <= 0.001:",
            "\t\treturn {\"visible\": false, \"visual_liquid\": visual_liquid}",
            "\tvar target: float = 1.0 if selected_liquid_amount >= 0.01 else 0.0",
            "\tvar next_visual_liquid: float = lerp(visual_liquid, target, clamp(0.06 * source_delta, 0.0, 1.0))",
            "\tvar light_state: Dictionary = {\"visible\": false, \"drawLiquidLightCall\": \"drawLiquidLight(liq, visualLiquid);\"}",
            "\tif next_visual_liquid > 0.01:",
            "\t\tvar fract: float = 1.0",
            "\t\tvar opacity: float = selected_alpha * fract",
            "\t\tif opacity > 0.001:",
            "\t\t\tlight_state = {\"visible\": true, \"x\": source_x, \"y\": source_y, \"radius\": block_size_value * 30.0 * fract, \"color\": selected_color, \"opacity\": opacity, \"alpha\": opacity * next_visual_liquid, \"fract\": fract}",
            "\tlight_state[\"visual_liquid\"] = next_visual_liquid",
            "\tlight_state[\"drawLiquidLightCall\"] = \"drawLiquidLight(liq, visualLiquid);\"",
            "\treturn light_state",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "drawLiquidLight"
    ):
        return [
            "\tvar source_x := float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar source_y := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar block_size_value := int(_args[2] if _args.size() > 2 else 0)",
            "\tvar light_color := String(_args[3] if _args.size() > 3 else \"\")",
            "\tvar light_alpha := float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar amount := float(_args[5] if _args.size() > 5 else 0.0)",
            "\tif amount <= 0.01:",
            "\t\treturn {\"visible\": false}",
            "\tvar fract: float = 1.0",
            "\tvar opacity: float = light_alpha * fract",
            "\tif opacity <= 0.001:",
            "\t\treturn {\"visible\": false}",
            "\treturn {\"visible\": true, \"x\": source_x, \"y\": source_y, \"radius\": block_size_value * 30.0 * fract, \"color\": light_color, \"opacity\": opacity, \"alpha\": opacity * amount, \"fract\": fract}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "drawTeam"
    ):
        return [
            "\tvar team_color := String(_args[0] if _args.size() > 0 else \"\")",
            "\tvar source_x := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar source_y := float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar block_size_value := int(_args[3] if _args.size() > 3 else 0)",
            "\tvar source_tilesize := float(_args[4] if _args.size() > 4 else 8.0)",
            "\treturn {\"visible\": true, \"region\": \"block-border\", \"color\": team_color, \"x\": source_x - block_size_value * source_tilesize / 2.0 + 4.0, \"y\": source_y - block_size_value * source_tilesize / 2.0 + 4.0, \"color_reset\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "checkSuppression"
    ):
        return [
            "\tvar block_suppressable := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar source_time := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar heal_suppression_time := float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar source_delta := float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar source_x := float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar source_y := float(_args[5] if _args.size() > 5 else 0.0)",
            "\tvar block_size_value := int(_args[6] if _args.size() > 6 else 0)",
            "\tvar source_tilesize := float(_args[7] if _args.size() > 7 else 8.0)",
            "\tvar suppress_color := String(_args[8] if _args.size() > 8 else \"\")",
            "\tvar suppressed: bool = block_suppressable and source_time <= heal_suppression_time",
            "\tif not suppressed:",
            "\t\treturn {\"suppressed\": false, \"particle_visible\": false}",
            "\tvar particle_range: float = block_size_value * source_tilesize / 2.0 - 1.0",
            "\tvar chance_threshold: float = 0.03 * source_delta",
            "\treturn {\"suppressed\": true, \"particle_visible\": \"chanceDelta\", \"chance_threshold\": chance_threshold, \"effect\": \"regenSuppressParticle\", \"color\": suppress_color, \"particle_range\": particle_range, \"x_min\": source_x - particle_range, \"x_max\": source_x + particle_range, \"y_min\": source_y - particle_range, \"y_max\": source_y + particle_range}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "playerPlaced"
    ):
        return [
            "\tvar config_state: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"method\": \"public void playerPlaced(Object config){\", \"comment\": \"Called after the block is placed by this client.\", \"call_super\": \"@CallSuper\", \"no_op\": true, \"config_state\": config_state}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "placed"
    ):
        return [
            "\tvar net_client := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar consumes_power := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar outputs_power := bool(_args[2] if _args.size() > 2 else false)",
            "\tvar has_power := bool(_args[3] if _args.size() > 3 else false)",
            "\tvar connected_power := bool(_args[4] if _args.size() > 4 else false)",
            "\tvar linked_to_self := bool(_args[5] if _args.size() > 5 else false)",
            "\tvar source_pos := int(_args[6] if _args.size() > 6 else -1)",
            "\tvar should_link_power := (consumes_power or outputs_power) and has_power and connected_power",
            "\tif net_client:",
            "\t\treturn {\"method\": \"public void placed(){\", \"comment\": \"Called after the block is placed by anyone.\", \"call_super\": \"@CallSuper\", \"client_guard\": \"if(net.client()) return;\" if net_client else \"\", \"power_gate\": \"\", \"power_node_scan\": \"\", \"link_guard\": \"\", \"configure_call\": \"\", \"returned\": true, \"power_link_scan\": false, \"configure\": false, \"configure_pos\": -1}",
            "\tif not should_link_power:",
            "\t\treturn {\"method\": \"public void placed(){\", \"comment\": \"Called after the block is placed by anyone.\", \"call_super\": \"@CallSuper\", \"client_guard\": \"if(net.client()) return;\" if net_client else \"\", \"power_gate\": \"if((block.consumesPower || block.outputsPower) && block.hasPower && block.connectedPower){\" if should_link_power else \"\", \"power_node_scan\": \"PowerNode.getNodeLinks(tile, block, team, other -> {\" if should_link_power else \"\", \"link_guard\": \"if(!other.power.links.contains(pos())){\" if should_link_power else \"\", \"configure_call\": \"\", \"returned\": false, \"power_link_scan\": false, \"configure\": false, \"configure_pos\": -1}",
            "\tvar configure := not linked_to_self",
            "\treturn {\"method\": \"public void placed(){\", \"comment\": \"Called after the block is placed by anyone.\", \"call_super\": \"@CallSuper\", \"client_guard\": \"if(net.client()) return;\" if net_client else \"\", \"power_gate\": \"if((block.consumesPower || block.outputsPower) && block.hasPower && block.connectedPower){\" if should_link_power else \"\", \"power_node_scan\": \"PowerNode.getNodeLinks(tile, block, team, other -> {\" if should_link_power else \"\", \"link_guard\": \"if(!other.power.links.contains(pos())){\" if should_link_power else \"\", \"configure_call\": \"other.configureAny(pos());\" if configure else \"\", \"returned\": false, \"power_link_scan\": true, \"configure\": configure, \"configure_pos\": source_pos if configure else -1}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "onRepaired"
    ):
        return [
            "\tvar has_fog_radius := bool(_args[0] if _args.size() > 0 else false)",
            "\treturn {\"method\": \"public void onRepaired(){\", \"call_super\": \"@CallSuper\", \"placed_call\": \"placed();\", \"fog_gate\": \"if(block.flags.contains(BlockFlag.hasFogRadius)){\" if has_fog_radius else \"\", \"fog_call\": \"fogControl.forceUpdate(team, self());\" if has_fog_radius else \"\", \"has_fog_radius\": has_fog_radius, \"placed\": true, \"fog_force_update\": has_fog_radius}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "isCommandable"
    ):
        return [
            "\tvar block_commandable := bool(_args[0] if _args.size() > 0 else false)",
            "\treturn {\"method\": \"public boolean isCommandable(){\", \"return_expr\": \"return block.commandable;\", \"block_commandable\": block_commandable, \"commandable\": block_commandable}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "isPayload"
    ):
        return [
            "\tvar tile_is_empty_tile := bool(_args[0] if _args.size() > 0 else false)",
            "\treturn {\"method\": \"public boolean isPayload(){\", \"return_expr\": \"return tile == emptyTile;\", \"tile_is_empty_tile\": tile_is_empty_tile, \"is_payload\": tile_is_empty_tile}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "overwrote"
    ):
        return [
            "\tvar previous_state: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"method\": \"public void overwrote(Seq<Building> previous){\", \"comment\": \"Called when a block is placed over some other blocks. This seq will always have at least one item.\", \"no_op\": true, \"previous_state\": previous_state}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "onRemoved"
    ):
        return [
            "\tvar current_state: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"method\": \"public void onRemoved(){\", \"no_op\": true, \"current_state\": current_state}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "unitOn"
    ):
        return [
            "\tvar unit_state: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"comment\": \"Called every frame a unit is on this. Hovering/flying/steppy units do not apply.  \", \"method\": \"public void unitOn(Unit unit){\", \"empty_body\": \"public void unitOn(Unit unit){\\n    }\", \"unit_state\": unit_state}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "unitOnAny"
    ):
        return [
            "\tvar unit_state: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"comment\": \"Called every frame a unit is on this. Applies to any unit.  \", \"method\": \"public void unitOnAny(Unit unit){\", \"empty_body\": \"public void unitOnAny(Unit unit){\\n    }\", \"unit_state\": unit_state}",
        ]
    return ["\treturn null"]

def _helper_lines(java_file: dict, type_entry: dict) -> list[str]:
    if not (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
    ):
        return []
    return [
        "",
        "const SOURCE_INT64_MIN := -9223372036854775807 - 1",
        "const SOURCE_UINT16_MASK := 65535",
        "const SOURCE_RAND_MURMUR_CONST1_WORDS := [0x8ccd, 0xed55, 0xafd7, 0xff51]",
        "const SOURCE_RAND_MURMUR_CONST2_WORDS := [0xec53, 0x1a85, 0xb9fe, 0xc4ce]",
        "const SOURCE_LONG_MIN_WORDS := [0, 0, 0, 0x8000]",
        "",
        "func _source_arc_is_power_of_two(value: int) -> bool:",
        "\treturn value != 0 and (value & (value - 1)) == 0",
        "",
        "func _source_words_from_nonnegative(value: int) -> Array:",
        "\tvar remaining: int = value",
        "\tvar words: Array = []",
        "\tfor _index in 4:",
        "\t\twords.append(remaining & SOURCE_UINT16_MASK)",
        "\t\tremaining = remaining >> 16",
        "\treturn words",
        "",
        "func _source_words_clone(words: Array) -> Array:",
        "\treturn [int(words[0]), int(words[1]), int(words[2]), int(words[3])]",
        "",
        "func _source_words_xor(left: Array, right: Array) -> Array:",
        "\treturn [int(left[0]) ^ int(right[0]), int(left[1]) ^ int(right[1]), int(left[2]) ^ int(right[2]), int(left[3]) ^ int(right[3])]",
        "",
        "func _source_words_add(left: Array, right: Array) -> Array:",
        "\tvar result: Array = [0, 0, 0, 0]",
        "\tvar carry := 0",
        "\tfor index in 4:",
        "\t\tvar sum_value: int = int(left[index]) + int(right[index]) + carry",
        "\t\tresult[index] = sum_value & SOURCE_UINT16_MASK",
        "\t\tcarry = sum_value >> 16",
        "\treturn result",
        "",
        "func _source_words_shift_left(words: Array, bits: int) -> Array:",
        "\tvar result: Array = [0, 0, 0, 0]",
        "\tvar word_shift: int = bits >> 4",
        "\tvar bit_shift: int = bits % 16",
        "\tfor index in 4:",
        "\t\tvar source_index: int = index - word_shift",
        "\t\tvar value := 0",
        "\t\tif source_index >= 0:",
        "\t\t\tvalue = int(words[source_index]) << bit_shift",
        "\t\t\tif bit_shift > 0 and source_index > 0:",
        "\t\t\t\tvalue |= int(words[source_index - 1]) >> (16 - bit_shift)",
        "\t\tresult[index] = value & SOURCE_UINT16_MASK",
        "\treturn result",
        "",
        "func _source_words_unsigned_shift_right(words: Array, bits: int) -> Array:",
        "\tvar result: Array = [0, 0, 0, 0]",
        "\tvar word_shift: int = bits >> 4",
        "\tvar bit_shift: int = bits % 16",
        "\tfor index in 4:",
        "\t\tvar source_index: int = index + word_shift",
        "\t\tvar value := 0",
        "\t\tif source_index < 4:",
        "\t\t\tvalue = int(words[source_index]) >> bit_shift",
        "\t\t\tif bit_shift > 0 and source_index < 3:",
        "\t\t\t\tvalue |= int(words[source_index + 1]) << (16 - bit_shift)",
        "\t\tresult[index] = value & SOURCE_UINT16_MASK",
        "\treturn result",
        "",
        "func _source_words_mul(left: Array, right: Array) -> Array:",
        "\tvar accum: Array = [0, 0, 0, 0]",
        "\tfor left_index in 4:",
        "\t\tfor right_index in 4:",
        "\t\t\tvar target_index: int = left_index + right_index",
        "\t\t\tif target_index < 4:",
        "\t\t\t\taccum[target_index] = int(accum[target_index]) + int(left[left_index]) * int(right[right_index])",
        "\tvar result: Array = [0, 0, 0, 0]",
        "\tvar carry := 0",
        "\tfor index in 4:",
        "\t\tvar total: int = int(accum[index]) + carry",
        "\t\tresult[index] = total & SOURCE_UINT16_MASK",
        "\t\tcarry = total >> 16",
        "\treturn result",
        "",
        "func _source_words_to_nonnegative(words: Array) -> int:",
        "\treturn int(words[0]) + (int(words[1]) << 16) + (int(words[2]) << 32) + (int(words[3]) << 48)",
        "",
        "func _source_words_to_signed(words: Array) -> int:",
        "\tif (int(words[3]) & 0x8000) == 0:",
        "\t\treturn _source_words_to_nonnegative(words)",
        "\tvar inverted: Array = [int(words[0]) ^ SOURCE_UINT16_MASK, int(words[1]) ^ SOURCE_UINT16_MASK, int(words[2]) ^ SOURCE_UINT16_MASK, int(words[3]) ^ SOURCE_UINT16_MASK]",
        "\tvar magnitude_words: Array = _source_words_add(inverted, [1, 0, 0, 0])",
        "\tif int(magnitude_words[3]) == 0x8000 and int(magnitude_words[2]) == 0 and int(magnitude_words[1]) == 0 and int(magnitude_words[0]) == 0:",
        "\t\treturn SOURCE_INT64_MIN",
        "\treturn -_source_words_to_nonnegative(magnitude_words)",
        "",
        "func _source_arc_rand_murmur_hash3_words(words: Array) -> Array:",
        "\tvar x: Array = _source_words_clone(words)",
        "\tx = _source_words_xor(x, _source_words_unsigned_shift_right(x, 33))",
        "\tx = _source_words_mul(x, SOURCE_RAND_MURMUR_CONST1_WORDS)",
        "\tx = _source_words_xor(x, _source_words_unsigned_shift_right(x, 33))",
        "\tx = _source_words_mul(x, SOURCE_RAND_MURMUR_CONST2_WORDS)",
        "\tx = _source_words_xor(x, _source_words_unsigned_shift_right(x, 33))",
        "\treturn x",
        "",
        "func _source_arc_rand_set_seed(source_seed: int) -> Dictionary:",
        "\tvar seed_words: Array = SOURCE_LONG_MIN_WORDS.duplicate() if source_seed == 0 else _source_words_from_nonnegative(source_seed)",
        "\tvar seed0: Array = _source_arc_rand_murmur_hash3_words(seed_words)",
        "\treturn {\"seed0\": seed0, \"seed1\": _source_arc_rand_murmur_hash3_words(seed0)}",
        "",
        "func _source_arc_rand_next_long_words(rand_state: Dictionary) -> Array:",
        "\tvar s1: Array = (rand_state[\"seed0\"] as Array).duplicate()",
        "\tvar s0: Array = (rand_state[\"seed1\"] as Array).duplicate()",
        "\trand_state[\"seed0\"] = s0",
        "\ts1 = _source_words_xor(s1, _source_words_shift_left(s1, 23))",
        "\tvar seed1: Array = _source_words_xor(_source_words_xor(_source_words_xor(s1, s0), _source_words_unsigned_shift_right(s1, 17)), _source_words_unsigned_shift_right(s0, 26))",
        "\trand_state[\"seed1\"] = seed1",
        "\treturn _source_words_add(seed1, s0)",
        "",
        "func _source_arc_rand_next_int_unbounded(rand_state: Dictionary) -> int:",
        "\treturn _source_words_to_signed(_source_arc_rand_next_long_words(rand_state))",
        "",
        "func _source_arc_rand_next_long_bound(rand_state: Dictionary, bound: int) -> int:",
        "\tif bound <= 0:",
        "\t\tpush_error(\"Rand.nextLong bound must be positive\")",
        "\t\treturn 0",
        "\twhile true:",
        "\t\tvar bits: int = _source_words_to_nonnegative(_source_words_unsigned_shift_right(_source_arc_rand_next_long_words(rand_state), 1))",
        "\t\tvar value: int = bits % bound",
        "\t\tif bits - value + (bound - 1) >= 0:",
        "\t\t\treturn value",
        "\treturn 0",
        "",
        "func _source_arc_rand_next_int_bound(rand_state: Dictionary, bound: int) -> int:",
        "\treturn _source_arc_rand_next_long_bound(rand_state, bound)",
        "",
        "func _source_arc_random_seed_int(source_seed: int, min_value: int, max_value: int) -> int:",
        "\tvar rand_state := _source_arc_rand_set_seed(source_seed)",
        "\tif _source_arc_is_power_of_two(max_value):",
        "\t\t_source_arc_rand_next_int_unbounded(rand_state)",
        "\treturn _source_arc_rand_next_int_bound(rand_state, max_value - min_value + 1) + min_value",
    ]

def _method_stub_lines(java_file: dict, type_entry: dict) -> list[str]:
    lines = []
    for index, method in enumerate(type_entry.get("methods", [])):
        name = _gd_identifier(method.get("name", "method"))
        lines.extend([
            "",
            f"func java_method_{name}_{index}(_args: Array = []) -> Variant:",
        ])
        lines.extend(_method_body_lines(java_file, type_entry, method))
    return lines


def _script_text(java_file: dict, type_entry: dict) -> str:
    lines = [
        "# Generated from Mindustry upstream.",
        f"# Source: {java_file['path']}",
        "# Do not edit by hand.",
        "extends RefCounted",
        "",
        f"const JAVA_PACKAGE := {gdscript_literal(java_file.get('package', ''))}",
        f"const JAVA_KIND := {gdscript_literal(type_entry.get('kind', ''))}",
        f"const JAVA_NAME := {gdscript_literal(type_entry.get('name', ''))}",
        f"const JAVA_EXTENDS := {gdscript_literal(type_entry.get('extends', ''))}",
        f"const JAVA_IMPLEMENTS := {gdscript_literal(type_entry.get('implements', []))}",
        f"const JAVA_FIELDS := {gdscript_literal(type_entry.get('fields', []))}",
        f"const JAVA_CONSTRUCTORS := {gdscript_literal(type_entry.get('constructors', []))}",
        f"const JAVA_METHODS := {gdscript_literal(type_entry.get('methods', []))}",
        f"const JAVA_ENUM_CONSTANTS := {gdscript_literal(type_entry.get('enum_constants', []))}",
    ]
    lines.extend(_helper_lines(java_file, type_entry))
    lines.extend(_method_stub_lines(java_file, type_entry))
    lines.append("")
    return "\n".join(lines)

def _registry_entry(java_file: dict, type_entry: dict, relative: Path) -> dict:
    return {
        "gdscript_path": f"res://src/generated/classes/{relative.as_posix()}",
        "java_kind": type_entry.get("kind", ""),
        "java_name": type_entry.get("name", ""),
        "java_package": java_file.get("package", ""),
        "java_path": java_file.get("path", ""),
    }

def _registry_text(entries: list[dict]) -> str:
    lines = [
        "# Generated from Mindustry upstream.",
        "# Source: emitted_classes.json",
        "# Do not edit by hand.",
        "extends RefCounted",
        "class_name MindustryGeneratedClassRegistry",
        "",
        f"const CLASS_COUNT := {len(entries)}",
        f"const CLASSES := {gdscript_literal(entries)}",
        "",
        "static func count() -> int:",
        "\treturn CLASS_COUNT",
        "",
        "static func all_classes() -> Array:",
        "\treturn CLASSES",
        "",
        "static func find_by_java_name(java_name: String) -> Dictionary:",
        "\tfor class_entry in CLASSES:",
        "\t\tif class_entry.get(\"java_name\", \"\") == java_name:",
        "\t\t\treturn class_entry",
        "\treturn {}",
        "",
    ]
    return "\n".join(lines)


def emit_gdscript_classes(source_root: Path, output_root: Path, limit: int | None = None) -> dict:
    output_root = Path(output_root)
    manifest = parse_source_tree(source_root, limit)
    files = []
    registry_entries = []
    for java_file in manifest["files"]:
        for type_entry in java_file.get("types", []):
            if not type_entry.get("name"):
                continue
            relative = _script_path(java_file, type_entry)
            output = output_root / relative
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_text(_script_text(java_file, type_entry), encoding="utf-8")
            files.append(relative.as_posix())
            registry_entries.append(_registry_entry(java_file, type_entry, relative))
    registry_path = output_root.parent / "GeneratedClassRegistry.gd"
    registry_path.parent.mkdir(parents=True, exist_ok=True)
    registry_path.write_text(_registry_text(registry_entries), encoding="utf-8")
    return {
        "source_root": Path(source_root).as_posix(),
        "output_root": output_root.as_posix(),
        "registry": registry_path.name,
        "emitted_file_count": len(files),
        "skipped_failure_count": manifest["failed_file_count"],
        "files": files,
        "failures": manifest["failures"],
    }
