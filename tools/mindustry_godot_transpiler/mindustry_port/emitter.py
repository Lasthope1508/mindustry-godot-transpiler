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
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "unitRemoved"
    ):
        return [
            "\tvar unit_state: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"comment\": \"Called when a unit that spawned at this tile is removed.\", \"method\": \"public void unitRemoved(Unit unit){\", \"empty_body\": \"public void unitRemoved(Unit unit){\\n    }\", \"unit_state\": unit_state}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "puddleOn"
    ):
        return [
            "\tvar puddle_state: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"comment\": \"Called when a puddle is on this building. Only called at an interval (40 ticks).\", \"method\": \"public void puddleOn(Puddle puddle){\", \"no_op\": true, \"puddle_state\": puddle_state}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "configured"
    ):
        return [
            "\tvar value_state: Dictionary = _args[1] if _args.size() > 1 and _args[1] is Dictionary else {}",
            "\tvar type_name := \"void\" if bool(value_state.get(\"is_null\", false)) else str(value_state.get(\"superclass\", \"\")) if bool(value_state.get(\"is_anonymous_class\", false)) else str(value_state.get(\"class\", \"\"))",
            "\tvar value_kind := str(value_state.get(\"kind\", \"\"))",
            "\tif value_kind == \"Item\":",
            "\t\ttype_name = \"Item\"",
            "\tif value_kind == \"Block\":",
            "\t\ttype_name = \"Block\"",
            "\tif value_kind == \"Liquid\":",
            "\t\ttype_name = \"Liquid\"",
            "\tif value_kind == \"UnitType\":",
            "\t\ttype_name = \"UnitType\"",
            "\treturn {\"source_owner\": \"PortGame.source_building_configured_type_state\", \"comment\": \"//null is of type void.class; anonymous classes use their superclass.\", \"assignment\": \"Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();\", \"item_override\": \"if(value instanceof Item) type = Item.class;\", \"block_override\": \"if(value instanceof Block) type = Block.class;\", \"liquid_override\": \"if(value instanceof Liquid) type = Liquid.class;\", \"unit_type_override\": \"if(value instanceof UnitType) type = UnitType.class;\", \"type_name\": type_name, \"value_state\": value_state}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "updateLastAccess"
    ):
        return [
            "\tvar builder_state: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}",
            "\tvar current_last_accessed := str(_args[1] if _args.size() > 1 else \"\")",
            "\tvar last_accessed := str(builder_state.get(\"colored_name\", \"\"))",
            "\treturn {\"source_owner\": \"PortGame.source_building_configured_last_access_state\", \"method\": \"public void updateLastAccess(Player player){\", \"assignment\": \"lastAccessed = player.coloredName();\", \"last_accessed\": last_accessed, \"updated\": true, \"builder_state\": builder_state, \"current_last_accessed\": current_last_accessed}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "tapped"
    ):
        return [
            "\tvar current_state: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"source_owner\": \"PortGame.source_building_tapped_state\", \"comment\": \"Called when the block is tapped by the local player.\", \"method\": \"public void tapped(){\", \"empty_body\": \"public void tapped(){\\n\\n    }\", \"current_state\": current_state, \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "afterDestroyed"
    ):
        return [
            "\tvar has_destroy_bullet := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar destroy_bullet_same_team := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar team_id := str(_args[2] if _args.size() > 2 else \"\")",
            "\tvar source_x := float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar source_y := float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar building_id := int(_args[5] if _args.size() > 5 else 0)",
            "\treturn {\"source_owner\": \"PortGame.source_building_after_destroyed_state\", \"comment\": \"Called *after* the tile has been removed.\", \"method\": \"public void afterDestroyed(){\", \"guard\": \"if(block.destroyBullet != null){\", \"create_call\": \"block.destroyBullet.create(this, block.destroyBulletSameTeam ? team : Team.derelict, x, y, Mathf.randomSeed(id(), 360f));\", \"team_choice\": \"block.destroyBulletSameTeam ? team : Team.derelict\", \"rotation_expr\": \"Mathf.randomSeed(id(), 360f)\", \"has_destroy_bullet\": has_destroy_bullet, \"destroy_bullet_same_team\": destroy_bullet_same_team, \"team_id\": team_id, \"source_x\": source_x, \"source_y\": source_y, \"building_id\": building_id}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "explosionItemCap"
    ):
        return [
            "\tvar item_capacity := int(_args[0] if _args.size() > 0 else 0)",
            "\treturn {\"source_owner\": \"PortGame.source_building_explosion_item_cap_state\", \"comment\": \"@return the cap for item amount calculations, used when this block explodes.\", \"method\": \"public int explosionItemCap(){\", \"return_expr\": \"return block.itemCapacity;\", \"item_capacity\": item_capacity, \"explosion_item_cap\": item_capacity}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "playDestroySound"
    ):
        return [
            "\tvar destroy_sound := str(_args[0] if _args.size() > 0 else \"\")",
            "\tvar destroy_pitch_min := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar destroy_pitch_max := float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar destroy_sound_volume := float(_args[3] if _args.size() > 3 else 0.0)",
            "\treturn {\"source_owner\": \"PortGame.source_building_on_destroyed_base_sound_state\", \"method\": \"public void playDestroySound(){\", \"play_destroy_sound_call\": \"block.destroySound.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);\", \"destroy_sound\": destroy_sound, \"destroy_pitch_min\": destroy_pitch_min, \"destroy_pitch_max\": destroy_pitch_max, \"destroy_sound_volume\": destroy_sound_volume, \"sound\": destroy_sound, \"pitch_min\": destroy_pitch_min, \"pitch_max\": destroy_pitch_max, \"volume\": destroy_sound_volume}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "getDisplayName"
    ):
        return [
            "\tvar localized_name := str(_args[0] if _args.size() > 0 else \"\")",
            "\tvar team_is_derelict := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar team_is_player := bool(_args[2] if _args.size() > 2 else false)",
            "\tvar team_emoji := str(_args[3] if _args.size() > 3 else \"\")",
            "\tvar derelict_label := str(_args[4] if _args.size() > 4 else \"\")",
            "\tvar display_name := localized_name",
            "\tif team_is_derelict:",
            "\t\tdisplay_name = localized_name + \"\\n\" + derelict_label",
            "\telif not team_is_player and not team_emoji.is_empty():",
            "\t\tdisplay_name = localized_name + \" \" + team_emoji",
            "\treturn {\"source_owner\": \"PortGame.source_building_display_name_state\", \"method\": \"public String getDisplayName(){\", \"derelict_comment\": \"//derelict team icon currently doesn't display\", \"derelict_return\": \"block.localizedName + \\\"\\\\n\\\" + Core.bundle.get(\\\"block.derelict\\\")\", \"regular_return\": \"block.localizedName + (team == player.team() || team.emoji.isEmpty() ? \\\"\\\" : \\\" \\\" + team.emoji)\", \"localized_name\": localized_name, \"team_is_derelict\": team_is_derelict, \"team_is_player\": team_is_player, \"team_emoji\": team_emoji, \"derelict_label\": derelict_label, \"display_name\": display_name}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "flowItems"
    ):
        return [
            "\tvar items_module: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"source_owner\": \"PortGame.source_building_flow_items_state\", \"comment\": \"/** @return the item module to use for flow rate calculations */\", \"method\": \"public ItemModule flowItems(){\", \"return_expr\": \"return items;\", \"items_module\": items_module, \"flow_items\": items_module}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "display"
    ):
        return [
            "\tvar block_ui_icon: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar localized_name := str(_args[1] if _args.size() > 1 else \"\")",
            "\tvar team_is_derelict := bool(_args[2] if _args.size() > 2 else false)",
            "\tvar team_is_player := bool(_args[3] if _args.size() > 3 else false)",
            "\tvar team_emoji := str(_args[4] if _args.size() > 4 else \"\")",
            "\tvar derelict_label := str(_args[5] if _args.size() > 5 else \"\")",
            "\tvar block_category := str(_args[6] if _args.size() > 6 else \"\")",
            "\tvar block_display_flow := bool(_args[7] if _args.size() > 7 else false)",
            "\tvar net_active := bool(_args[8] if _args.size() > 8 else false)",
            "\tvar has_last_accessed := bool(_args[9] if _args.size() > 9 else false)",
            "\tvar icon_state := {\"source_owner\": \"PortGame.source_building_display_icon_state\", \"block_ui_icon\": block_ui_icon, \"icon\": block_ui_icon}",
            "\tvar display_name := localized_name",
            "\tif team_is_derelict:",
            "\t\tdisplay_name = localized_name + \"\\n\" + derelict_label",
            "\telif not team_is_player and not team_emoji.is_empty():",
            "\t\tdisplay_name = localized_name + \" \" + team_emoji",
            "\tvar display_flow := (block_category == \"distribution\" or block_category == \"liquid\") and block_display_flow",
            "\tvar ui_gates := {\"display_header\": true, \"display_same_team_details\": team_is_player, \"display_bars\": team_is_player, \"display_consumption\": team_is_player, \"display_flow\": team_is_player and display_flow, \"display_last_accessed\": team_is_player and net_active and has_last_accessed}",
            "\treturn {\"source_owner\": \"PortGame.source_building_display_ui_gates_state\", \"icon_source_owner\": \"PortGame.source_building_display_icon_state\", \"name_source_owner\": \"PortGame.source_building_display_name_state\", \"method\": \"public void display(Table table){\", \"display_block_comment\": \"//display the block stuff\", \"todo_comment\": \"//TODO duplicated code?\", \"header_icon_call\": \"t.add(new Image(block.getDisplayIcon(tile))).scaling(Scaling.fit).size(8 * 4);\", \"header_name_call\": \"t.labelWrap(block.getDisplayName(tile)).left().width(190f).padLeft(5);\", \"same_team_comment\": \"//only display everything else if the team is the same\", \"same_team_gate\": \"if(team == player.team()){\", \"display_bars_call\": \"displayBars(bars);\", \"display_consumption_call\": \"table.table(this::displayConsumption).growX();\", \"display_flow_formula\": \"boolean displayFlow = (block.category == Category.distribution || block.category == Category.liquid) && block.displayFlow;\", \"display_flow_gate\": \"if(displayFlow){\", \"last_accessed_gate\": \"if(net.active() && lastAccessed != null){\", \"last_accessed_call\": \"table.add(Core.bundle.format(\\\"lastaccessed\\\", lastAccessed)).growX().wrap().left();\", \"icon\": icon_state, \"display_name\": display_name, \"ui_gates\": ui_gates, \"block_ui_icon\": block_ui_icon, \"localized_name\": localized_name, \"team_is_derelict\": team_is_derelict, \"team_is_player\": team_is_player, \"team_emoji\": team_emoji, \"derelict_label\": derelict_label, \"block_category\": block_category, \"block_display_flow\": block_display_flow, \"net_active\": net_active, \"has_last_accessed\": has_last_accessed}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "displayConsumption"
    ):
        return [
            "\tvar consumers: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []",
            "\tvar self_state: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar built_consumers: Array = []",
            "\tvar skipped_consumers: Array = []",
            "\tfor cons in consumers:",
            "\t\tvar optional_value := bool(cons.get(\"optional\", false))",
            "\t\tvar booster_value := bool(cons.get(\"booster\", false))",
            "\t\tif optional_value and booster_value:",
            "\t\t\tskipped_consumers.append(cons)",
            "\t\t\tcontinue",
            "\t\tbuilt_consumers.append({\"consumer\": cons, \"self_state\": self_state})",
            "\treturn {\"source_owner\": \"PortGame.source_building_display_consumption_state\", \"method\": \"public void displayConsumption(Table table){\", \"table_left_call\": \"table.left();\", \"consumers_loop\": \"for(Consume cons : block.consumers){\", \"optional_booster_skip\": \"if(cons.optional && cons.booster) continue;\", \"build_call\": \"cons.build(self(), table);\", \"consumers\": consumers, \"self_state\": self_state, \"built_consumers\": built_consumers, \"skipped_consumers\": skipped_consumers}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "displayBars"
    ):
        return [
            "\tvar bar_results: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []",
            "\tvar added_bars: Array = []",
            "\tvar skipped_bars: Array = []",
            "\tfor result in bar_results:",
            "\t\tif result == null:",
            "\t\t\tskipped_bars.append(result)",
            "\t\t\tcontinue",
            "\t\tadded_bars.append(result)",
            "\treturn {\"source_owner\": \"PortGame.source_building_display_bars_state\", \"method\": \"public void displayBars(Table table){\", \"bars_loop\": \"for(Func<Building, Bar> bar : block.listBars()){\", \"get_result\": \"var result = bar.get(self());\", \"null_skip\": \"if(result == null) continue;\", \"add_call\": \"table.add(result).growX();\", \"row_call\": \"table.row();\", \"bar_results\": bar_results, \"added_bars\": added_bars, \"skipped_bars\": skipped_bars, \"row_calls\": added_bars.size()}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "getCursor"
    ):
        return [
            "\tvar block_configurable := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar interactable_player_team := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar cursor := \"hand\" if block_configurable and interactable_player_team else \"arrow\"",
            "\treturn {\"source_owner\": \"PortGame.source_building_cursor_state\", \"comment\": \"/** Returns whether a hand cursor should be shown over this block. */\", \"method\": \"public Cursor getCursor(){\", \"return_expr\": \"return block.configurable && interactable(player.team()) ? SystemCursor.hand : SystemCursor.arrow;\", \"block_configurable\": block_configurable, \"interactable_player_team\": interactable_player_team, \"cursor\": cursor}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "onConfigureTapped"
    ):
        return [
            "\tvar x := float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar y := float(_args[1] if _args.size() > 1 else 0.0)",
            "\treturn {\"source_owner\": \"PortGame.source_building_on_configure_tapped_state\", \"method\": \"public boolean onConfigureTapped(float x, float y){\", \"return_false\": \"return false;\", \"x\": x, \"y\": y, \"consumed\": false}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "onConfigureClosed"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_building_on_configure_closed_state\", \"method\": \"public void onConfigureClosed(){}\", \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "shouldShowConfigure"
    ):
        return [
            "\tvar player: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"source_owner\": \"PortGame.source_building_should_show_configure_state\", \"comment\": \"/** Returns whether this config menu should show when the specified player taps it. */\", \"method\": \"public boolean shouldShowConfigure(Player player){\", \"return_true\": \"return true;\", \"player\": player, \"should_show\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "shouldHideConfigure"
    ):
        return [
            "\tvar player: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"source_owner\": \"PortGame.source_building_should_hide_configure_state\", \"comment\": \"/** Whether this configuration should be hidden now. Called every frame the config is open. */\", \"method\": \"public boolean shouldHideConfigure(Player player){\", \"return_false\": \"return false;\", \"player\": player, \"should_hide\": false}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "drawConfigure"
    ):
        return [
            "\tvar source_x := float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar source_y := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar block_size_value := int(_args[2] if _args.size() > 2 else 0)",
            "\tvar source_tilesize := float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar half_extent := float(block_size_value) * source_tilesize / 2.0",
            "\tvar radius_offset := 1.0",
            "\treturn {\"source_owner\": \"PortGame.source_building_draw_configure_state\", \"method\": \"public void drawConfigure(){\", \"color\": \"Pal.accent\", \"stroke\": 1.0, \"shape\": \"square\", \"square\": \"Lines.square(x, y, block.size * tilesize / 2f + 1f);\", \"x\": source_x, \"y\": source_y, \"halfExtent\": half_extent, \"radiusOffset\": radius_offset, \"radius\": half_extent + radius_offset, \"reset\": true, \"source_x\": source_x, \"source_y\": source_y, \"block_size_value\": block_size_value, \"source_tilesize\": source_tilesize}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "checkSolid"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_building_check_solid_state\", \"method\": \"public boolean checkSolid(){\", \"checkSolid\": false}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "handleDamage"
    ):
        return [
            "\tvar amount := float(_args[0] if _args.size() > 0 else 0.0)",
            "\treturn {\"source_owner\": \"PortGame.source_building_handle_damage_state\", \"method\": \"public float handleDamage(float amount){\", \"amount\": amount, \"handled_damage\": amount}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "absorbLasers"
    ):
        return [
            "\tvar block_absorb_lasers := bool(_args[0] if _args.size() > 0 else false)",
            "\treturn {\"source_owner\": \"PortGame.source_building_absorb_lasers_state\", \"blockAbsorbLasers\": block_absorb_lasers, \"defaultAbsorbLasers\": false, \"absorbLasers\": block_absorb_lasers}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "isInsulated"
    ):
        return [
            "\tvar block_insulated := bool(_args[0] if _args.size() > 0 else false)",
            "\treturn {\"source_owner\": \"PortGame.source_building_is_insulated_state\", \"method\": \"public boolean isInsulated(){\", \"block_insulated\": block_insulated, \"insulated\": block_insulated}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "collide"
    ):
        return [
            "\tvar other: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"source_owner\": \"PortGame.source_building_collide_state\", \"method\": \"public boolean collide(Bullet other){\", \"other\": other, \"collide\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "collision"
    ):
        return [
            "\tvar current_health := float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar bullet_building_damage := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar block_armor := float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar bullet_pierce_armor := bool(_args[3] if _args.size() > 3 else false)",
            "\tvar bullet_armor_multiplier := float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar bullet_block_armor_multiplier := float(_args[5] if _args.size() > 5 else 0.0)",
            "\tvar damage := bullet_building_damage",
            "\tvar armor := block_armor * bullet_armor_multiplier * bullet_block_armor_multiplier",
            "\tif not bullet_pierce_armor:",
            "\t\tdamage = max(damage - armor, 0.1 * damage)",
            "\treturn {\"source_owner\": \"PortGame.source_building_collision_damage_state\", \"method\": \"public boolean collision(Bullet other){\", \"was_dead\": current_health <= 0.0, \"raw_damage\": bullet_building_damage, \"armor\": armor, \"damage\": damage, \"removed\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "damage"
        and [param.get("type") for param in method.get("parameters", [])] == ["Team", "float"]
    ):
        return [
            "\tvar source_team: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar damage_amount := float(_args[1] if _args.size() > 1 else 0.0)",
            "\treturn {\"source_owner\": \"PortGame.source_building_damage_delegate_state\", \"comment\": \"/** Used to handle damage from splash damage for certain types of blocks. */\", \"method\": \"public void damage(@Nullable Team source, float damage){\", \"source_team\": source_team, \"damage\": damage_amount, \"delegates_to_damage\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "damage"
        and [param.get("type") for param in method.get("parameters", [])] == ["Bullet", "Team", "float"]
    ):
        return [
            "\tvar bullet: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar source_team: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar damage_amount := float(_args[2] if _args.size() > 2 else 0.0)",
            "\treturn {\"source_owner\": \"PortGame.source_building_bullet_damage_state\", \"comment\": \"/** Handles splash damage with a bullet source. */\", \"method\": \"public void damage(Bullet bullet, Team source, float damage){\", \"bullet\": bullet, \"source_team\": source_team, \"damage\": damage_amount, \"delegates_to_source_damage\": true, \"fires_bullet_damage_event\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "changeTeam"
        and [param.get("type") for param in method.get("parameters", [])] == ["Team"]
    ):
        return [
            "\tvar next_team: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"source_owner\": \"PortGame.source_building_change_team_delegate_state\", \"comment\": \"/** Changes this building's team in a safe manner. */\", \"method\": \"public void changeTeam(Team next){\", \"next_team\": next_team, \"delegates_to_change_team\": true, \"update_power\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "changeTeam"
        and [param.get("type") for param in method.get("parameters", [])] == ["Team", "boolean"]
    ):
        return [
            "\tvar current_team: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar next_team: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar force_team: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar was_valid := bool(_args[3] if _args.size() > 3 else false)",
            "\tvar power_present := bool(_args[4] if _args.size() > 4 else false)",
            "\tvar update_power := bool(_args[5] if _args.size() > 5 else false)",
            "\tvar old_graph: Variant = _args[6] if _args.size() > 6 else null",
            "\tvar link_count := int(_args[7] if _args.size() > 7 else 0)",
            "\tif current_team == next_team:",
            "\t\treturn {\"source_owner\": \"PortGame.source_building_change_team_initial_state\", \"comment\": \"/** Changes this building's team in a safe manner. */\", \"method\": \"public void changeTeam(Team next, boolean updatePower){\", \"team\": current_team, \"last_team\": current_team, \"returned\": true, \"remove_index\": false, \"assign_next\": false}",
            "\tvar team_after_force = force_team if force_team != null else current_team",
            "\tvar last_team = team_after_force",
            "\tif last_team == next_team:",
            "\t\treturn {\"source_owner\": \"PortGame.source_building_change_team_initial_state\", \"comment\": \"/** Changes this building's team in a safe manner. */\", \"method\": \"public void changeTeam(Team next, boolean updatePower){\", \"team\": team_after_force, \"last_team\": last_team, \"returned\": true, \"remove_index\": false, \"assign_next\": false}",
            "\tvar result = {\"source_owner\": \"PortGame.source_building_change_team_initial_state\", \"comment\": \"/** Changes this building's team in a safe manner. */\", \"method\": \"public void changeTeam(Team next, boolean updatePower){\", \"team\": next_team, \"last_team\": last_team, \"returned\": false, \"remove_index\": was_valid, \"assign_next\": true}",
            "\tvar power_proximity = {\"source_owner\": \"PortGame.source_building_change_team_power_proximity_state\", \"method\": \"public void changeTeam(Team next, boolean updatePower){\", \"gate\": \"if(power != null && updatePower){\", \"old_graph\": old_graph, \"team\": next_team, \"proximity_reflow\": power_present and update_power}",
            "\tresult[\"power_proximity\"] = power_proximity",
            "\tvar power_links = {\"source_owner\": \"PortGame.source_building_change_team_power_links_state\", \"method\": \"public void changeTeam(Team next, boolean updatePower){\", \"loop\": \"for(int i = 0; i < power.links.size; i++){\", \"old_graph\": old_graph, \"team\": next_team, \"link_count\": link_count if power_present and update_power else 0, \"remove_index\": power_present and update_power and link_count > 0, \"reflow_self\": power_present and update_power and link_count > 0, \"update_power_graph\": power_present and update_power and link_count > 0}",
            "\tresult[\"power_links\"] = power_links",
            "\tvar final_state = {\"source_owner\": \"PortGame.source_building_change_team_final_state\", \"method\": \"public void changeTeam(Team next, boolean updatePower){\", \"was\": was_valid, \"add_index\": was_valid, \"team_change_event\": was_valid, \"event_last\": last_team, \"check_allow_update\": true}",
            "\tresult[\"final\"] = final_state",
            "\treturn result",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "canPickup"
    ):
        return [
            "\tvar block_can_pickup := bool(_args[0] if _args.size() > 0 else false)",
            "\treturn {\"source_owner\": \"PortGame.source_building_can_pickup_state\", \"method\": \"public boolean canPickup(){\", \"blockCanPickup\": block_can_pickup, \"canPickup\": block_can_pickup}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "pickedUp"
    ):
        return [
            "\tvar previous_state: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"source_owner\": \"PortGame.source_building_picked_up_state\", \"method\": \"public void pickedUp(){\", \"comment\": \"Called right before this building is picked up.\", \"no_op\": true, \"previous_state\": previous_state}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "afterPickedUp"
    ):
        return [
            "\tvar power_present := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar has_cons_power := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar cons_power_buffered := bool(_args[2] if _args.size() > 2 else false)",
            "\tvar current_status := float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar status := 0.0 if power_present and has_cons_power and not cons_power_buffered else current_status",
            "\treturn {\"source_owner\": \"PortGame.source_building_after_picked_up_state\", \"power_present\": power_present, \"new_power_graph\": power_present, \"clear_links\": power_present, \"status\": status}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "removeFromProximity"
    ):
        return [
            "\tvar nearby_count := int(_args[0] if _args.size() > 0 else 0)",
            "\tvar removable_count := int(_args[1] if _args.size() > 1 else 0)",
            "\tvar queued_removals := clampi(removable_count, 0, nearby_count)",
            "\treturn {\"source_owner\": \"PortGame.source_building_remove_from_proximity_state\", \"method\": \"public void removeFromProximity(){\", \"on_proximity_removed_call\": \"onProximityRemoved();\", \"tmp_tiles_clear_call\": \"tmpTiles.clear();\", \"edges_get_call\": \"Point2[] nearby = Edges.getEdges(block.size);\", \"world_build_call\": \"Building other = world.build(tile.x + point.x, tile.y + point.y);\", \"tmp_tiles_add_call\": \"tmpTiles.add(other);\", \"remove_self_call\": \"other.proximity.remove(self(), true);\", \"other_update_call\": \"other.onProximityUpdate();\", \"proximity_clear_call\": \"proximity.clear();\", \"on_proximity_removed\": true, \"tmp_tiles_cleared\": true, \"nearby_count\": nearby_count, \"queued_removals\": queued_removals, \"proximity_updates\": queued_removals, \"proximity_cleared\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "updateProximity"
    ):
        return [
            "\tvar nearby_count := int(_args[0] if _args.size() > 0 else 0)",
            "\tvar same_team_count := int(_args[1] if _args.size() > 1 else 0)",
            "\tvar headless := bool(_args[2] if _args.size() > 2 else false)",
            "\tvar draw_cached := bool(_args[3] if _args.size() > 3 else false)",
            "\tvar same_team_clamped := clampi(same_team_count, 0, nearby_count)",
            "\treturn {\"source_owner\": \"PortGame.source_building_update_proximity_state\", \"tmp_tiles_cleared\": true, \"proximity_cleared\": true, \"nearby_count\": nearby_count, \"same_team_count\": same_team_clamped, \"add_unique_calls\": same_team_clamped, \"on_proximity_added\": true, \"self_proximity_update\": true, \"other_proximity_updates\": same_team_clamped, \"recache\": (not headless) and draw_cached}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "onNearbyBuildAdded"
    ):
        return [
            "\tvar other_state: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"source_owner\": \"PortGame.source_building_on_nearby_build_added_state\", \"method\": \"public void onNearbyBuildAdded(Building other){}\", \"no_op\": true, \"other_state\": other_state}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "consume"
    ):
        return [
            "\tvar consumers: Array = _args[0] if _args.size() > 0 else []",
            "\tvar self_state: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar triggered: Array = []",
            "\tfor consumer in consumers:",
            "\t\ttriggered.append({\"consumer\": consumer, \"self\": self_state})",
            "\treturn {\"source_owner\": \"PortGame.source_building_consume_state\", \"triggered\": triggered}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "canConsume"
    ):
        return [
            "\tvar potential_efficiency := float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar can_consume := potential_efficiency > 0.0",
            "\treturn {\"source_owner\": \"PortGame.source_building_can_consume_state\", \"method\": \"public boolean canConsume(){\", \"potentialEfficiency\": potential_efficiency, \"canConsume\": can_consume}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "delta"
    ):
        return [
            "\tvar source_delta := float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar time_scale := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar delta := source_delta * time_scale",
            "\treturn {\"source_owner\": \"PortGame.source_building_delta\", \"comment\": \"/** Scaled delta. */\", \"method\": \"public float delta(){\", \"source_delta\": source_delta, \"time_scale\": time_scale, \"delta\": delta}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "edelta"
    ):
        delta_method_index = next(
            (
                index
                for index, candidate in enumerate(type_entry.get("methods", []))
                if candidate.get("name") == "delta"
            ),
            0,
        )
        return [
            "\tvar source_delta := float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar time_scale := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar efficiency := float(_args[2] if _args.size() > 2 else 0.0)",
            f"\tvar delta_result = java_method_delta_{delta_method_index}([source_delta, time_scale])",
            "\tvar delta_call := float(delta_result.get(\"delta\", 0.0))",
            "\tvar edelta := efficiency * delta_call",
            "\treturn {\"source_owner\": \"PortGame.source_building_edelta\", \"method\": \"public float edelta(){\", \"delta_call\": delta_call, \"efficiency\": efficiency, \"source_delta\": source_delta, \"time_scale\": time_scale, \"edelta\": edelta}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "updateEfficiencyMultiplier"
    ):
        return [
            "\tvar efficiency := float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar optional_efficiency := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar efficiency_scale := float(_args[2] if _args.size() > 2 else 1.0)",
            "\tvar scale := efficiency_scale",
            "\tefficiency *= scale",
            "\toptional_efficiency *= scale",
            "\treturn {\"source_owner\": \"PortGame.source_building_update_efficiency_multiplier_state\", \"comment\": \"/** Called after efficiency is updated but before consumers are updated. Use to apply your own multiplier. */\", \"method\": \"public void updateEfficiencyMultiplier(){\", \"scale\": scale, \"efficiency\": efficiency, \"optional_efficiency\": optional_efficiency, \"efficiency_scale\": efficiency_scale}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "efficiencyScale"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_building_efficiency_scale_state\", \"comment\": \"/** Calculate your own efficiency multiplier. By default, this is applied in updateEfficiencyMultiplier. */\", \"method\": \"public float efficiencyScale(){\", \"efficiency_scale\": 1.0}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "updateConsumption"
    ):
        update_efficiency_multiplier_index = next(
            (
                index
                for index, candidate in enumerate(type_entry.get("methods", []))
                if candidate.get("name") == "updateEfficiencyMultiplier"
            ),
            0,
        )
        return [
            "\tvar has_consumers := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar cheating := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar enabled_state := bool(_args[2] if _args.size() > 2 else false)",
            "\tvar production_valid := bool(_args[3] if _args.size() > 3 else false)",
            "\tvar should_consume_state := bool(_args[4] if _args.size() > 4 else false)",
            "\tvar efficiency_scale := float(_args[5] if _args.size() > 5 else 1.0)",
            "\tvar non_optional_consumer_results: Array = _args[6] if _args.size() > 6 else []",
            "\tvar optional_consumer_results: Array = _args[7] if _args.size() > 7 else []",
            "\tvar update_consumers: Array = _args[9] if _args.size() > 9 else []",
            "\tvar self_state: Dictionary = _args[10] if _args.size() > 10 else {}",
            "\tvar efficiency := 0.0",
            "\tvar potential_efficiency := 0.0",
            "\tif has_consumers and not cheating:",
            "\t\tif not enabled_state:",
            "\t\t\treturn {\"source_owner\": \"PortGame.source_building_update_consumption_disabled_state\", \"method\": \"public void updateConsumption(){\", \"comment\": \"//disabled -> nothing works\", \"guard\": \"if(!enabled){\", \"efficiencies\": \"potentialEfficiency = efficiency = optionalEfficiency = 0f;\", \"power\": \"shouldConsumePower = false;\", \"return\": \"return;\", \"enabled_state\": enabled_state, \"potential_efficiency\": 0.0, \"efficiency\": 0.0, \"optional_efficiency\": 0.0, \"should_consume_power\": false, \"returned\": true}",
            "\t\tvar update := should_consume_state and production_valid",
            "\t\tif _args.size() <= 6:",
            "\t\t\treturn {\"source_owner\": \"PortGame.source_building_update_consumption_setup_state\", \"method\": \"public void updateConsumption(){\", \"update_expr\": \"boolean update = shouldConsume() && productionValid();\", \"min\": \"float minEfficiency = 1f;\", \"comment\": \"//assume efficiency is 1 for the calculations below\", \"efficiencies\": \"efficiency = optionalEfficiency = 1f;\", \"power\": \"shouldConsumePower = true;\", \"should_consume_state\": should_consume_state, \"production_valid\": production_valid, \"update\": update, \"min_efficiency\": 1.0, \"efficiency\": 1.0, \"optional_efficiency\": 1.0, \"should_consume_power\": true}",
            "\t\tvar min_efficiency := 1.0",
            "\t\tvar should_consume_power := true",
            "\t\tfor consumer in non_optional_consumer_results:",
            "\t\t\tvar result := float(consumer.get(\"result\", 0.0))",
            "\t\t\tif not bool(consumer.get(\"is_power\", false)) and result <= 0.0000001:",
            "\t\t\t\tshould_consume_power = false",
            "\t\t\tmin_efficiency = min(min_efficiency, result)",
            "\t\tif _args.size() <= 7:",
            "\t\t\treturn {\"source_owner\": \"PortGame.source_building_update_consumption_non_optional_pass_state\", \"method\": \"public void updateConsumption(){\", \"comment\": \"//first pass: get the minimum efficiency of any consumer\", \"loop\": \"for(var cons : block.nonOptionalConsumers){\", \"result\": \"float result = cons.efficiency(self());\", \"power_gate\": \"if(cons != block.consPower && result <= 0.0000001f){\", \"power_state\": \"shouldConsumePower = false;\", \"min\": \"minEfficiency = Math.min(minEfficiency, result);\", \"non_optional_consumer_results\": non_optional_consumer_results, \"min_efficiency\": min_efficiency, \"should_consume_power\": should_consume_power}",
            "\t\tvar optional_efficiency := 1.0",
            "\t\tfor result in optional_consumer_results:",
            "\t\t\toptional_efficiency = min(optional_efficiency, float(result))",
            "\t\tif _args.size() <= 8:",
            "\t\t\treturn {\"source_owner\": \"PortGame.source_building_update_consumption_optional_pass_state\", \"method\": \"public void updateConsumption(){\", \"comment\": \"//same for optionals\", \"loop\": \"for(var cons : block.optionalConsumers){\", \"optional_min\": \"optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));\", \"optional_consumer_results\": optional_consumer_results, \"optional_efficiency\": optional_efficiency}",
            "\t\tefficiency = min_efficiency",
            "\t\tvar optional_efficiency_input := optional_efficiency",
            "\t\toptional_efficiency = min(optional_efficiency, min_efficiency)",
            "\t\tpotential_efficiency = efficiency",
            "\t\tif not update:",
            "\t\t\tefficiency = 0.0",
            "\t\t\toptional_efficiency = 0.0",
            "\t\tif _args.size() <= 9:",
            "\t\t\treturn {\"source_owner\": \"PortGame.source_building_update_consumption_efficiency_state\", \"method\": \"public void updateConsumption(){\", \"comment\": \"//efficiency is now this minimum value\", \"assign\": \"efficiency = minEfficiency;\", \"optional_min\": \"optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);\", \"potential_comment\": \"//assign \\\"potential\\\"\", \"potential_assign\": \"potentialEfficiency = efficiency;\", \"no_update_comment\": \"//no updating means zero efficiency\", \"no_update_guard\": \"if(!update){\", \"no_update_zero\": \"efficiency = optionalEfficiency = 0f;\", \"min_efficiency\": min_efficiency, \"optional_efficiency_input\": optional_efficiency_input, \"update\": update, \"efficiency\": efficiency, \"optional_efficiency\": optional_efficiency, \"potential_efficiency\": potential_efficiency}",
            f"\t\tvar multiplied = java_method_updateEfficiencyMultiplier_{update_efficiency_multiplier_index}([efficiency, optional_efficiency, efficiency_scale])",
            "\t\tefficiency = float(multiplied.get(\"efficiency\", efficiency))",
            "\t\toptional_efficiency = float(multiplied.get(\"optional_efficiency\", optional_efficiency))",
            "\t\tvar updated_consumers := []",
            "\t\tif update and efficiency > 0.0:",
            "\t\t\tfor consumer in update_consumers:",
            "\t\t\t\tupdated_consumers.append({\"consumer\": consumer, \"self\": self_state})",
            "\t\treturn {\"source_owner\": \"PortGame.source_building_update_consumption_second_pass_state\", \"method\": \"public void updateConsumption(){\", \"multiplier\": \"updateEfficiencyMultiplier();\", \"comment\": \"//second pass: update every consumer based on efficiency\", \"guard\": \"if(update && efficiency > 0){\", \"loop\": \"for(var cons : block.updateConsumers){\", \"update_call\": \"cons.update(self());\", \"update\": update, \"efficiency\": efficiency, \"update_consumers\": update_consumers, \"self_state\": self_state, \"updated_consumers\": updated_consumers, \"update_count\": updated_consumers.size()}",
            "\telse:",
            "\t\tpotential_efficiency = 1.0 if enabled_state and production_valid else 0.0",
            "\t\tefficiency = potential_efficiency if should_consume_state else 0.0",
            f"\t\tvar multiplied = java_method_updateEfficiencyMultiplier_{update_efficiency_multiplier_index}([efficiency, efficiency, efficiency_scale])",
            "\t\tvar final_efficiency := float(multiplied.get(\"efficiency\", efficiency))",
            "\t\tvar final_optional_efficiency := float(multiplied.get(\"optional_efficiency\", efficiency))",
            "\t\treturn {\"source_owner\": \"PortGame.source_building_update_consumption_initial_state\", \"method\": \"public void updateConsumption(){\", \"comment\": \"//everything is valid when cheating\", \"guard\": \"if(!block.hasConsumers || cheating()){\", \"potential\": \"potentialEfficiency = enabled && productionValid() ? 1f : 0f;\", \"efficiency_assign\": \"efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;\", \"power\": \"shouldConsumePower = true;\", \"multiplier\": \"updateEfficiencyMultiplier();\", \"return\": \"return;\", \"has_consumers\": has_consumers, \"cheating\": cheating, \"enabled_state\": enabled_state, \"production_valid\": production_valid, \"should_consume_state\": should_consume_state, \"efficiency_scale\": efficiency_scale, \"potential_efficiency\": potential_efficiency, \"efficiency\": final_efficiency, \"optional_efficiency\": final_optional_efficiency, \"should_consume_power\": true, \"returned\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "ambientVolume"
    ):
        return [
            "\tvar efficiency := float(_args[0] if _args.size() > 0 else 0.0)",
            "\treturn {\"source_owner\": \"PortGame.source_building_ambient_volume\", \"method\": \"public float ambientVolume(){\", \"efficiency\": efficiency, \"ambientVolume\": efficiency}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "config"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_building_config_default\", \"comment\": \"/** Tile configuration. Defaults to null. Used for block rebuilding. */\", \"nullable\": \"@Nullable\", \"method\": \"public Object config(){\", \"config\": null}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "isValid"
    ):
        return [
            "\tvar tile_build_matches_self := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar dead_state := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar valid := tile_build_matches_self and not dead_state",
            "\treturn {\"source_owner\": \"PortGame.source_building_is_valid\", \"replace\": \"@Replace\", \"override\": \"@Override\", \"method\": \"public boolean isValid(){\", \"tile_build_matches_self\": tile_build_matches_self, \"dead_state\": dead_state, \"valid\": valid}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "heal"
        and not method.get("parameters")
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_building_heal_state\", \"priority\": \"@MethodPriority(100)\", \"override\": \"@Override\", \"method\": \"public void heal(){\", \"health_changed_call\": \"healthChanged();\", \"amount\": null, \"health_changed\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "heal"
        and [parameter.get("name") for parameter in method.get("parameters", [])] == ["amount"]
    ):
        return [
            "\tvar amount: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"source_owner\": \"PortGame.source_building_heal_state\", \"priority\": \"@MethodPriority(100)\", \"override\": \"@Override\", \"method\": \"public void heal(float amount){\", \"health_changed_call\": \"healthChanged();\", \"amount\": amount, \"health_changed\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "hitSize"
    ):
        return [
            "\tvar block_size_value := int(_args[0] if _args.size() > 0 else 0)",
            "\tvar source_tilesize := float(_args[1] if _args.size() > 1 else 8.0)",
            "\tvar hit_size := float(block_size_value) * source_tilesize",
            "\treturn {\"source_owner\": \"PortGame.source_building_hit_size\", \"override\": \"@Override\", \"method\": \"public float hitSize(){\", \"return_expr\": \"return tile.block().size * tilesize;\", \"block_size_value\": block_size_value, \"source_tilesize\": source_tilesize, \"hit_size\": hit_size}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "hitbox"
    ):
        return [
            "\tvar world_x := float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar world_y := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar block_size_value := int(_args[2] if _args.size() > 2 else 0)",
            "\tvar source_tilesize := float(_args[3] if _args.size() > 3 else 8.0)",
            "\tvar hitbox_size := float(block_size_value) * source_tilesize",
            "\treturn {\"source_owner\": \"PortGame.source_building_hitbox_state\", \"method\": \"public void hitbox(Rect out){\", \"set_centered_expr\": \"out.setCentered(x, y, block.size * tilesize, block.size * tilesize);\", \"hitbox_size_expr\": \"block.size * tilesize\", \"world_x\": world_x, \"world_y\": world_y, \"block_size_value\": block_size_value, \"source_tilesize\": source_tilesize, \"hitbox_size\": hitbox_size, \"set_centered\": {\"x\": world_x, \"y\": world_y, \"width\": hitbox_size, \"height\": hitbox_size}}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "toString"
    ):
        return [
            "\tvar id_value := int(_args[0] if _args.size() > 0 else 0)",
            "\tvar tile_x_value := int(_args[1] if _args.size() > 1 else 0)",
            "\tvar tile_y_value := int(_args[2] if _args.size() > 2 else 0)",
            "\tvar block_value: Variant = _args[3] if _args.size() > 3 else null",
            "\tvar to_string_result := \"Building#\" + str(id_value) + \"[\" + str(tile_x_value) + \",\" + str(tile_y_value) + \"]:\" + str(block_value)",
            "\treturn {\"source_owner\": \"PortGame.source_building_to_string_state\", \"override_annotation\": \"@Override\", \"replace_annotation\": \"@Replace\", \"method\": \"public String toString(){\", \"return_expr\": \"return \\\"Building#\\\" + id() + \\\"[\\\" + tileX() + \\\",\\\" + tileY() + \\\"]:\\\" + block;\", \"id_value\": id_value, \"tile_x_value\": tile_x_value, \"tile_y_value\": tile_y_value, \"block_value\": block_value, \"to_string\": to_string_result}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingTetherComp.java"
        and type_entry.get("name") == "BuildingTetherComp"
        and method.get("name") == "update"
    ):
        return [
            "\tvar building_exists := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar building_is_valid := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar building_team_value: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar team_value: Variant = _args[3] if _args.size() > 3 else null",
            "\tvar unit_id := int(_args[4] if _args.size() > 4 else 0)",
            "\tvar guard: bool = (not building_exists) or (not building_is_valid) or building_team_value != team_value",
            "\tvar despawn_call: Variant = null",
            "\tif guard:",
            "\t\tdespawn_call = {\"call\": \"Call.unitDespawn(self())\", \"unit\": unit_id}",
            "\treturn {\"source_owner\": \"PortGame.source_building_tether_update_state\", \"method\": \"public void update(){\", \"guard_expr\": \"if(building == null || !building.isValid() || building.team != team){\", \"building_exists\": building_exists, \"building_is_valid\": building_is_valid, \"building_team_value\": building_team_value, \"team_value\": team_value, \"guard\": guard, \"despawn\": despawn_call}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/ChildComp.java"
        and type_entry.get("name") == "ChildComp"
        and method.get("name") == "add"
    ):
        return [
            "\tvar child_state: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}",
            "\tvar x: float = float(child_state.get(\"x\", 0.0))",
            "\tvar y: float = float(child_state.get(\"y\", 0.0))",
            "\tvar rotation: float = float(child_state.get(\"rotation\", 0.0))",
            "\tvar offset_x: float = float(child_state.get(\"offsetX\", 0.0))",
            "\tvar offset_y: float = float(child_state.get(\"offsetY\", 0.0))",
            "\tvar offset_pos: float = float(child_state.get(\"offsetPos\", 0.0))",
            "\tvar offset_rot: float = float(child_state.get(\"offsetRot\", 0.0))",
            "\tvar parent_guard: bool = bool(child_state.get(\"parent_exists\", false))",
            "\tvar parent_get_x: float = float(child_state.get(\"parent_get_x\", 0.0))",
            "\tvar parent_get_y: float = float(child_state.get(\"parent_get_y\", 0.0))",
            "\tvar rot_with_parent: bool = bool(child_state.get(\"rot_with_parent\", false))",
            "\tvar parent_is_rotc: bool = bool(child_state.get(\"parent_is_rotc\", false))",
            "\tvar parent_rotc_rotation: float = float(child_state.get(\"parent_rotc_rotation\", 0.0))",
            "\tvar parent_is_rotblock: bool = bool(child_state.get(\"parent_is_rotblock\", false))",
            "\tvar parent_rotblock_build_rotation: float = float(child_state.get(\"parent_rotblock_build_rotation\", 0.0))",
            "\tvar next_offset_x: float = offset_x",
            "\tvar next_offset_y: float = offset_y",
            "\tvar next_offset_pos: float = offset_pos",
            "\tvar next_offset_rot: float = offset_rot",
            "\tvar rot_with_parent_guard := false",
            "\tvar parent_rotc_guard := false",
            "\tvar parent_rotblock_guard := false",
            "\tif parent_guard:",
            "\t\tnext_offset_x = x - parent_get_x",
            "\t\tnext_offset_y = y - parent_get_y",
            "\t\tif rot_with_parent:",
            "\t\t\trot_with_parent_guard = true",
            "\t\t\tif parent_is_rotc:",
            "\t\t\t\tparent_rotc_guard = true",
            "\t\t\t\tnext_offset_pos = -parent_rotc_rotation",
            "\t\t\t\tnext_offset_rot = rotation - parent_rotc_rotation",
            "\t\t\telif parent_is_rotblock:",
            "\t\t\t\tparent_rotblock_guard = true",
            "\t\t\t\tnext_offset_pos = -parent_rotblock_build_rotation",
            "\t\t\t\tnext_offset_rot = rotation - parent_rotblock_build_rotation",
            "\treturn {\"source_owner\": \"PortGame.source_child_add_state\", \"method\": \"public void add(){\", \"parent_guard_expr\": \"if(parent != null){\", \"offsetX_expr\": \"offsetX = x - parent.getX();\", \"offsetY_expr\": \"offsetY = y - parent.getY();\", \"rot_with_parent_guard_expr\": \"if(rotWithParent){\", \"parent_rotc_guard_expr\": \"if(parent instanceof Rotc r){\", \"parent_rotblock_guard_expr\": \"}else if(parent instanceof RotBlock rot){\", \"offsetPos_rotc_expr\": \"offsetPos = -r.rotation();\", \"offsetRot_rotc_expr\": \"offsetRot = rotation - r.rotation();\", \"offsetPos_rotblock_expr\": \"offsetPos = -rot.buildRotation();\", \"offsetRot_rotblock_expr\": \"offsetRot = rotation - rot.buildRotation();\", \"parentGuard\": parent_guard, \"offsetX\": next_offset_x, \"offsetY\": next_offset_y, \"rotWithParentGuard\": rot_with_parent_guard, \"parentRotcGuard\": parent_rotc_guard, \"parentRotBlockGuard\": parent_rotblock_guard, \"offsetPos\": next_offset_pos, \"offsetRot\": next_offset_rot}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/ChildComp.java"
        and type_entry.get("name") == "ChildComp"
        and method.get("name") == "update"
    ):
        return [
            "\tvar child_state: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}",
            "\tvar x: float = float(child_state.get(\"x\", 0.0))",
            "\tvar y: float = float(child_state.get(\"y\", 0.0))",
            "\tvar rotation: float = float(child_state.get(\"rotation\", 0.0))",
            "\tvar offset_x: float = float(child_state.get(\"offsetX\", 0.0))",
            "\tvar offset_y: float = float(child_state.get(\"offsetY\", 0.0))",
            "\tvar offset_pos: float = float(child_state.get(\"offsetPos\", 0.0))",
            "\tvar offset_rot: float = float(child_state.get(\"offsetRot\", 0.0))",
            "\tvar parent_guard: bool = bool(child_state.get(\"parent_exists\", false))",
            "\tvar parent_get_x: float = float(child_state.get(\"parent_get_x\", 0.0))",
            "\tvar parent_get_y: float = float(child_state.get(\"parent_get_y\", 0.0))",
            "\tvar rot_with_parent: bool = bool(child_state.get(\"rot_with_parent\", false))",
            "\tvar parent_is_rotc: bool = bool(child_state.get(\"parent_is_rotc\", false))",
            "\tvar parent_rotc_rotation: float = float(child_state.get(\"parent_rotc_rotation\", 0.0))",
            "\tvar parent_is_rotblock: bool = bool(child_state.get(\"parent_is_rotblock\", false))",
            "\tvar parent_rotblock_build_rotation: float = float(child_state.get(\"parent_rotblock_build_rotation\", 0.0))",
            "\tvar _source_arc_angles_trns_vec := func(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:",
            "\t\tvar radians := deg_to_rad(angle_degrees)",
            "\t\tvar cos_value := cos(radians)",
            "\t\tvar sin_value := sin(radians)",
            "\t\treturn {\"x\": x_value * cos_value - y_value * sin_value, \"y\": x_value * sin_value + y_value * cos_value}",
            "\tvar next_x: float = x",
            "\tvar next_y: float = y",
            "\tvar next_rotation: float = rotation",
            "\tvar rot_with_parent_guard := false",
            "\tvar parent_rotc_guard := false",
            "\tvar parent_rotblock_guard := false",
            "\tif parent_guard:",
            "\t\tif rot_with_parent:",
            "\t\t\trot_with_parent_guard = true",
            "\t\t\tif parent_is_rotc:",
            "\t\t\t\tparent_rotc_guard = true",
            "\t\t\t\tvar trns_vec_rotc: Dictionary = _source_arc_angles_trns_vec.call(parent_rotc_rotation + offset_pos, offset_x, offset_y)",
            "\t\t\t\tnext_x = parent_get_x + float(trns_vec_rotc.get(\"x\", 0.0))",
            "\t\t\t\tnext_y = parent_get_y + float(trns_vec_rotc.get(\"y\", 0.0))",
            "\t\t\t\tnext_rotation = parent_rotc_rotation + offset_rot",
            "\t\t\telif parent_is_rotblock:",
            "\t\t\t\tparent_rotblock_guard = true",
            "\t\t\t\tvar trns_vec_rotblock: Dictionary = _source_arc_angles_trns_vec.call(parent_rotblock_build_rotation + offset_pos, offset_x, offset_y)",
            "\t\t\t\tnext_x = parent_get_x + float(trns_vec_rotblock.get(\"x\", 0.0))",
            "\t\t\t\tnext_y = parent_get_y + float(trns_vec_rotblock.get(\"y\", 0.0))",
            "\t\t\t\tnext_rotation = parent_rotblock_build_rotation + offset_rot",
            "\t\telse:",
            "\t\t\tnext_x = parent_get_x + offset_x",
            "\t\t\tnext_y = parent_get_y + offset_y",
            "\treturn {\"source_owner\": \"PortGame.source_child_update_state\", \"method\": \"public void update(){\", \"parent_guard_expr\": \"if(parent != null){\", \"rot_with_parent_guard_expr\": \"if(rotWithParent){\", \"parent_rotc_guard_expr\": \"if(parent instanceof Rotc r){\", \"parent_rotblock_guard_expr\": \"}else if(parent instanceof RotBlock rot){\", \"trnsx_rotc_expr\": \"x = parent.getX() + Angles.trnsx(r.rotation() + offsetPos, offsetX, offsetY);\", \"trnsy_rotc_expr\": \"y = parent.getY() + Angles.trnsy(r.rotation() + offsetPos, offsetX, offsetY);\", \"rotation_rotc_expr\": \"rotation = r.rotation() + offsetRot;\", \"trnsx_rotblock_expr\": \"x = parent.getX() + Angles.trnsx(rot.buildRotation() + offsetPos, offsetX, offsetY);\", \"trnsy_rotblock_expr\": \"y = parent.getY() + Angles.trnsy(rot.buildRotation() + offsetPos, offsetX, offsetY);\", \"rotation_rotblock_expr\": \"rotation = rot.buildRotation() + offsetRot;\", \"no_rot_x_expr\": \"x = parent.getX() + offsetX;\", \"no_rot_y_expr\": \"y = parent.getY() + offsetY;\", \"parentGuard\": parent_guard, \"rotWithParentGuard\": rot_with_parent_guard, \"parentRotcGuard\": parent_rotc_guard, \"parentRotBlockGuard\": parent_rotblock_guard, \"x\": next_x, \"y\": next_y, \"rotation\": next_rotation}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BlockUnitComp.java"
        and type_entry.get("name") == "BlockUnitComp"
        and method.get("name") == "tile"
        and len(method.get("parameters", [])) == 1
        and method.get("parameters", [])[0].get("name") == "tile"
    ):
        return [
            "\tvar tile: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar tile_block_health: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar tile_health: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar tile_block_size: float = float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar tilesize: float = float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar this_tile_after: Variant = tile",
            "\tvar hit_size: float = tile_block_size * tilesize * 0.7",
            "\tvar max_health_call: Dictionary = {\"call\": \"maxHealth(tile.block.health);\", \"value\": tile_block_health}",
            "\tvar health_call: Dictionary = {\"call\": \"health(tile.health);\", \"value\": tile_health}",
            "\tvar hit_size_call: Dictionary = {\"call\": \"hitSize(tile.block.size * tilesize * 0.7f);\", \"value\": hit_size}",
            "\tvar set_call: Dictionary = {\"call\": \"set(tile);\", \"tile\": tile}",
            "\treturn {\"source_owner\": \"PortGame.source_block_unit_tile_state\", \"method\": \"public void tile(Building tile){\", \"tile_assignment_expr\": \"this.tile = tile;\", \"comment\": \"//sets up block stats\", \"max_health_call\": max_health_call, \"health_call\": health_call, \"hit_size_call\": hit_size_call, \"set_call\": set_call, \"tile\": tile, \"tile_block_health\": tile_block_health, \"tile_health\": tile_health, \"tile_block_size\": tile_block_size, \"tilesize\": tilesize, \"this_tile_after\": this_tile_after, \"hit_size\": hit_size}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/Turret.java"
        and type_entry.get("name") == "Turret"
        and method.get("name") == "outputsItems"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_turret_outputs_items_state\", \"method\": \"public boolean outputsItems(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return false;\", \"outputs_items\": false}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/Turret.java"
        and type_entry.get("name") == "Turret"
        and method.get("name") == "init"
    ):
        return [
            "\tvar shoot_y: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar shoot_y_is_negative_infinity: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar size: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar source_tilesize: float = float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar elevation: float = float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar recoil_time: float = float(_args[5] if _args.size() > 5 else 0.0)",
            "\tvar reload: float = float(_args[6] if _args.size() > 6 else 0.0)",
            "\tvar cooldown_time: float = float(_args[7] if _args.size() > 7 else 0.0)",
            "\tvar new_target_interval: float = float(_args[8] if _args.size() > 8 else 0.0)",
            "\tvar target_interval: float = float(_args[9] if _args.size() > 9 else 0.0)",
            "\tvar target_ground: bool = bool(_args[10] if _args.size() > 10 else true)",
            "\tvar disable_overlap_check: bool = bool(_args[11] if _args.size() > 11 else false)",
            "\tvar range_value: float = float(_args[12] if _args.size() > 12 else 0.0)",
            "\tvar tracking_range: float = float(_args[13] if _args.size() > 13 else 0.0)",
            "\tvar shoot_y_after: float = size * source_tilesize / 2.0 if shoot_y_is_negative_infinity else shoot_y",
            "\tvar elevation_after: float = size / 2.0 if elevation < 0.0 else elevation",
            "\tvar recoil_time_after: float = reload if recoil_time < 0.0 else recoil_time",
            "\tvar cooldown_time_after: float = reload if cooldown_time < 0.0 else cooldown_time",
            "\tvar new_target_interval_after: float = target_interval if new_target_interval <= 0.0 else new_target_interval",
            "\tvar disable_overlap_check_after: bool = true if not target_ground else disable_overlap_check",
            "\tvar tracking_range_after: float = max(range_value, tracking_range)",
            "\treturn {\"source_owner\": \"PortGame.source_turret_init_state\", \"method\": \"public void init(){\", \"override_expr\": \"@Override\", \"shoot_y_guard_expr\": \"if(shootY == Float.NEGATIVE_INFINITY) shootY = size * tilesize / 2f;\", \"shoot_y_expr\": \"shootY = size * tilesize / 2f\", \"elevation_guard_expr\": \"if(elevation < 0) elevation = size / 2f;\", \"elevation_expr\": \"elevation = size / 2f\", \"recoil_time_guard_expr\": \"if(recoilTime < 0f) recoilTime = reload;\", \"recoil_time_expr\": \"recoilTime = reload\", \"cooldown_time_guard_expr\": \"if(cooldownTime < 0f) cooldownTime = reload;\", \"cooldown_time_expr\": \"cooldownTime = reload\", \"new_target_interval_guard_expr\": \"if(newTargetInterval <= 0f) newTargetInterval = targetInterval;\", \"new_target_interval_expr\": \"newTargetInterval = targetInterval\", \"target_ground_guard_expr\": \"if(!targetGround){\", \"disable_overlap_check_expr\": \"disableOverlapCheck = true;\", \"super_init_expr\": \"super.init();\", \"tracking_range_expr\": \"trackingRange = Math.max(range, trackingRange);\", \"shoot_y\": shoot_y, \"shoot_y_is_negative_infinity\": shoot_y_is_negative_infinity, \"size\": size, \"source_tilesize\": source_tilesize, \"elevation\": elevation, \"recoil_time\": recoil_time, \"reload\": reload, \"cooldown_time\": cooldown_time, \"new_target_interval\": new_target_interval, \"target_interval\": target_interval, \"target_ground\": target_ground, \"disable_overlap_check\": disable_overlap_check, \"range\": range_value, \"tracking_range\": tracking_range, \"shoot_y_after\": shoot_y_after, \"elevation_after\": elevation_after, \"recoil_time_after\": recoil_time_after, \"cooldown_time_after\": cooldown_time_after, \"new_target_interval_after\": new_target_interval_after, \"disable_overlap_check_after\": disable_overlap_check_after, \"tracking_range_after\": tracking_range_after}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/Turret.java"
        and type_entry.get("name") == "Turret"
        and method.get("name") == "load"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_turret_load_state\", \"method\": \"public void load(){\", \"override_expr\": \"@Override\", \"super_load_expr\": \"super.load();\", \"drawer_load_expr\": \"drawer.load(this);\", \"super_load_called\": true, \"drawer_load_called\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/Turret.java"
        and type_entry.get("name") == "Turret"
        and method.get("name") == "drawPlanRegion"
    ):
        return [
            "\tvar plan: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar list: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar drawer_draw_plan_call: Dictionary = {\"call\": \"drawer.drawPlan(this, plan, list);\", \"plan\": plan, \"list\": list}",
            "\treturn {\"source_owner\": \"PortGame.source_turret_draw_plan_region_state\", \"method\": \"public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){\", \"override_expr\": \"@Override\", \"drawer_draw_plan_expr\": \"drawer.drawPlan(this, plan, list);\", \"plan\": plan, \"list\": list, \"drawer_draw_plan_call\": drawer_draw_plan_call, \"drawer_draw_plan_called\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/Turret.java"
        and type_entry.get("name") == "Turret"
        and method.get("name") == "icons"
    ):
        return [
            "\tvar drawer_final_icons_return: Array = [\"drawer.finalIcons(this)\"]",
            "\treturn {\"source_owner\": \"PortGame.source_turret_icons_state\", \"method\": \"public TextureRegion[] icons(){\", \"override_expr\": \"@Override\", \"drawer_final_icons_expr\": \"return drawer.finalIcons(this);\", \"drawer_final_icons_called\": true, \"icons\": drawer_final_icons_return}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/Turret.java"
        and type_entry.get("name") == "Turret"
        and method.get("name") == "getRegionsToOutline"
    ):
        return [
            "\tvar out: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar drawer_get_regions_to_outline_call: Dictionary = {\"call\": \"drawer.getRegionsToOutline(this, out);\", \"out\": out}",
            "\treturn {\"source_owner\": \"PortGame.source_turret_get_regions_to_outline_state\", \"method\": \"public void getRegionsToOutline(Seq<TextureRegion> out){\", \"override_expr\": \"@Override\", \"drawer_get_regions_to_outline_expr\": \"drawer.getRegionsToOutline(this, out);\", \"out\": out, \"drawer_get_regions_to_outline_call\": drawer_get_regions_to_outline_call, \"drawer_get_regions_to_outline_called\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/Turret.java"
        and type_entry.get("name") == "Turret"
        and method.get("name") == "limitRange"
    ):
        return [
            "\tvar bullet: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}",
            "\tvar margin: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar turret_range: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar bullet_range_change: float = float(bullet.get(\"rangeChange\", 0.0))",
            "\tvar real_range: float = bullet_range_change + turret_range",
            "\tvar bullet_extra_range_margin: float = float(bullet.get(\"extraRangeMargin\", 0.0))",
            "\tvar bullet_speed: float = float(bullet.get(\"speed\", 1.0))",
            "\tvar bullet_lifetime: float = (real_range + margin + bullet_extra_range_margin + 10.0) / bullet_speed",
            "\tbullet[\"lifetime\"] = bullet_lifetime",
            "\treturn {\"source_owner\": \"PortGame.source_turret_limit_range_state\", \"method\": \"public void limitRange(BulletType bullet, float margin){\", \"real_range_expr\": \"float realRange = bullet.rangeChange + range;\", \"drag_comment\": \"//doesn't handle drag\", \"lifetime_expr\": \"bullet.lifetime = (realRange + margin + bullet.extraRangeMargin + 10f) / bullet.speed;\", \"bullet\": bullet, \"margin\": margin, \"turret_range\": turret_range, \"bullet_range_change\": bullet_range_change, \"real_range\": real_range, \"bullet_extra_range_margin\": bullet_extra_range_margin, \"bullet_speed\": bullet_speed, \"bullet_lifetime\": bullet_lifetime, \"updated_bullet\": bullet}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/Turret.java"
        and type_entry.get("name") == "Turret"
        and method.get("name") == "drawPlace"
    ):
        return [
            "\tvar tile_x: int = int(_args[0] if _args.size() > 0 else 0)",
            "\tvar tile_y: int = int(_args[1] if _args.size() > 1 else 0)",
            "\tvar rotation: int = int(_args[2] if _args.size() > 2 else 0)",
            "\tvar valid: bool = bool(_args[3] if _args.size() > 3 else false)",
            "\tvar draw_min_range: bool = bool(_args[4] if _args.size() > 4 else false)",
            "\tvar source_tilesize: float = float(_args[5] if _args.size() > 5 else 0.0)",
            "\tvar block_offset: float = float(_args[6] if _args.size() > 6 else 0.0)",
            "\tvar min_range: float = float(_args[7] if _args.size() > 7 else 0.0)",
            "\tvar dash_circle_x: float = float(tile_x) * source_tilesize + block_offset",
            "\tvar dash_circle_y: float = float(tile_y) * source_tilesize + block_offset",
            "\tvar dash_circle_called: bool = draw_min_range",
            "\tvar dash_circle_call: Dictionary = {}",
            "\tif dash_circle_called:",
            "\t\tdash_circle_call = {\"call\": \"Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, minRange, Pal.placing);\", \"x\": dash_circle_x, \"y\": dash_circle_y, \"radius\": min_range, \"color\": \"Pal.placing\"}",
            "\treturn {\"source_owner\": \"PortGame.source_turret_draw_place_state\", \"method\": \"public void drawPlace(int x, int y, int rotation, boolean valid){\", \"override_expr\": \"@Override\", \"super_draw_place_expr\": \"super.drawPlace(x, y, rotation, valid);\", \"draw_min_range_gate\": \"if(drawMinRange){\", \"dash_circle_expr\": \"Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, minRange, Pal.placing);\", \"tile_x\": tile_x, \"tile_y\": tile_y, \"rotation\": rotation, \"valid\": valid, \"draw_min_range\": draw_min_range, \"source_tilesize\": source_tilesize, \"block_offset\": block_offset, \"min_range\": min_range, \"dash_circle_x\": dash_circle_x, \"dash_circle_y\": dash_circle_y, \"dash_circle_called\": dash_circle_called, \"dash_circle_call\": dash_circle_call}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/Turret.java"
        and type_entry.get("name") == "Turret"
        and method.get("name") == "rotatedOutput"
    ):
        return [
            "\tvar tile_x: int = int(_args[0] if _args.size() > 0 else 0)",
            "\tvar tile_y: int = int(_args[1] if _args.size() > 1 else 0)",
            "\treturn {\"source_owner\": \"PortGame.source_turret_rotated_output_state\", \"method\": \"public boolean rotatedOutput(int x, int y){\", \"override_expr\": \"@Override\", \"return_expr\": \"return false;\", \"tile_x\": tile_x, \"tile_y\": tile_y, \"rotated_output\": false}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/Turret.java"
        and type_entry.get("name") == "Turret"
        and method.get("name") == "placeEnded"
    ):
        return [
            "\tvar tile: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar builder: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar rotation: int = int(_args[2] if _args.size() > 2 else 0)",
            "\tvar config: Variant = _args[3] if _args.size() > 3 else null",
            "\tvar rotate: bool = bool(_args[4] if _args.size() > 4 else false)",
            "\tvar tile_build_is_turret_build: bool = bool(_args[5] if _args.size() > 5 else false)",
            "\tvar turret_rotation: float = float(_args[6] if _args.size() > 6 else 0.0)",
            "\tvar tile_build_rotdeg: float = float(_args[7] if _args.size() > 7 else 0.0)",
            "\tvar rotation_assigned: bool = rotate and tile_build_is_turret_build",
            "\tvar turret_rotation_after: float = tile_build_rotdeg if rotation_assigned else turret_rotation",
            "\treturn {\"source_owner\": \"PortGame.source_turret_place_ended_state\", \"method\": \"public void placeEnded(Tile tile, @Nullable Unit builder, int rotation, @Nullable Object config){\", \"override_expr\": \"@Override\", \"super_place_ended_expr\": \"super.placeEnded(tile, builder, rotation, config);\", \"place_ended_gate\": \"if(rotate && tile.build instanceof TurretBuild turret){\", \"rotation_assign_expr\": \"turret.rotation = tile.build.rotdeg();\", \"tile\": tile, \"builder\": builder, \"rotation\": rotation, \"config\": config, \"rotate\": rotate, \"tile_build_is_turret_build\": tile_build_is_turret_build, \"turret_rotation\": turret_rotation, \"tile_build_rotdeg\": tile_build_rotdeg, \"super_place_ended_called\": true, \"rotation_assigned\": rotation_assigned, \"turret_rotation_after\": turret_rotation_after}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuilderComp.java"
        and type_entry.get("name") == "BuilderComp"
        and method.get("name") == "canBuild"
    ):
        return [
            "\tvar type_build_speed: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar build_speed_multiplier: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar type_build_speed_positive: bool = type_build_speed > 0",
            "\tvar build_speed_multiplier_positive: bool = build_speed_multiplier > 0",
            "\tvar can_build: bool = type_build_speed_positive and build_speed_multiplier_positive",
            "\treturn {\"source_owner\": \"PortGame.source_builder_can_build_state\", \"method\": \"public boolean canBuild(){\", \"return_expr\": \"return type.buildSpeed > 0 && buildSpeedMultiplier > 0;\", \"type_build_speed\": type_build_speed, \"build_speed_multiplier\": build_speed_multiplier, \"type_build_speed_positive\": type_build_speed_positive, \"build_speed_multiplier_positive\": build_speed_multiplier_positive, \"can_build\": can_build}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuilderComp.java"
        and type_entry.get("name") == "BuilderComp"
        and method.get("name") == "update"
    ):
        return [
            "\tvar update_build_logic_call: String = \"updateBuildLogic();\"",
            "\tvar update_build_logic_called: bool = true",
            "\treturn {\"source_owner\": \"PortGame.source_builder_update_state\", \"method\": \"public void update(){\", \"update_build_logic_call\": update_build_logic_call, \"update_build_logic_called\": update_build_logic_called}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuilderComp.java"
        and type_entry.get("name") == "BuilderComp"
        and method.get("name") == "afterRead"
    ):
        return [
            "\tvar plans_null: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar queue_reset: bool = plans_null",
            "\tvar plans_capacity: int = 1 if queue_reset else 0",
            "\treturn {\"source_owner\": \"PortGame.source_builder_after_read_state\", \"method\": \"public void afterRead(){\", \"comment\": \"//why would this happen?\", \"guard_expr\": \"if(plans == null){\", \"queue_constructor\": \"new Queue<>(1)\", \"plans_null\": plans_null, \"queue_reset\": queue_reset, \"plans_capacity\": plans_capacity}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuilderComp.java"
        and type_entry.get("name") == "BuilderComp"
        and method.get("name") == "isBuilding"
    ):
        return [
            "\tvar plans_size: int = int(_args[0] if _args.size() > 0 else 0)",
            "\tvar is_building: bool = plans_size != 0",
            "\treturn {\"source_owner\": \"PortGame.source_builder_is_building_state\", \"method\": \"boolean isBuilding(){\", \"return_expr\": \"return plans.size != 0;\", \"plans_size\": plans_size, \"is_building\": is_building}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuilderComp.java"
        and type_entry.get("name") == "BuilderComp"
        and method.get("name") == "drawPlan"
    ):
        return [
            "\tvar plan: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar all_plans: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []",
            "\tvar plan_breaking: bool = bool(_args[2] if _args.size() > 2 else false)",
            "\tvar alpha: float = float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar build_valid_place: bool = bool(_args[4] if _args.size() > 4 else false)",
            "\tvar control_input_plan_matches: bool = bool(_args[5] if _args.size() > 5 else false)",
            "\tvar plan_anim_scale: float = 1.0",
            "\tvar draw_plan_valid: bool = build_valid_place or control_input_plan_matches",
            "\tvar draw_breaking_call: Variant = null",
            "\tvar draw_plan_call: Variant = null",
            "\tif plan_breaking:",
            "\t\tdraw_breaking_call = {\"call\": \"control.input.drawBreaking(plan);\", \"plan\": plan}",
            "\telse:",
            "\t\tdraw_plan_call = {\"call\": \"plan.block.drawPlan(plan, control.input.allPlans(), Build.validPlace(...) || control.input.planMatches(plan), alpha);\", \"plan\": plan, \"all_plans\": all_plans, \"valid\": draw_plan_valid, \"alpha\": alpha}",
            "\treturn {\"source_owner\": \"PortGame.source_builder_draw_plan_state\", \"method\": \"void drawPlan(BuildPlan plan, float alpha){\", \"anim_scale_expr\": \"plan.animScale = 1f;\", \"breaking_guard_expr\": \"if(plan.breaking){\", \"draw_breaking_expr\": \"control.input.drawBreaking(plan);\", \"draw_plan_expr\": \"plan.block.drawPlan(plan, control.input.allPlans(), Build.validPlace(plan.block, team, plan.x, plan.y, plan.rotation) || control.input.planMatches(plan), alpha);\", \"draw_plan_valid_expr\": \"Build.validPlace(plan.block, team, plan.x, plan.y, plan.rotation) || control.input.planMatches(plan)\", \"plan\": plan, \"all_plans\": all_plans, \"plan_breaking\": plan_breaking, \"alpha\": alpha, \"build_valid_place\": build_valid_place, \"control_input_plan_matches\": control_input_plan_matches, \"plan_anim_scale\": plan_anim_scale, \"draw_plan_valid\": draw_plan_valid, \"draw_breaking_call\": draw_breaking_call, \"draw_plan_call\": draw_plan_call}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuilderComp.java"
        and type_entry.get("name") == "BuilderComp"
        and method.get("name") == "drawPlanTop"
    ):
        return [
            "\tvar plan: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar plans: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []",
            "\tvar plan_breaking: bool = bool(_args[2] if _args.size() > 2 else false)",
            "\tvar alpha: float = float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar mathf_absin_time_global_6_0_28: float = float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar draw_top: bool = not plan_breaking",
            "\tvar mixcol_alpha: float = 0.24 + mathf_absin_time_global_6_0_28",
            "\tvar draw_reset_called: bool = draw_top",
            "\tvar draw_alpha_call: Variant = null",
            "\tvar draw_plan_config_top_call: Variant = null",
            "\tif draw_top:",
            "\t\tdraw_alpha_call = {\"call\": \"Draw.alpha(alpha);\", \"alpha\": alpha}",
            "\t\tdraw_plan_config_top_call = {\"call\": \"plan.block.drawPlanConfigTop(plan, plans);\", \"plan\": plan, \"plans\": plans}",
            "\treturn {\"source_owner\": \"PortGame.source_builder_draw_plan_top_state\", \"method\": \"void drawPlanTop(BuildPlan plan, float alpha){\", \"guard_expr\": \"if(!plan.breaking){\", \"draw_reset_expr\": \"Draw.reset();\", \"mixcol_expr\": \"Draw.mixcol(Color.white, 0.24f + Mathf.absin(Time.globalTime, 6f, 0.28f));\", \"draw_alpha_expr\": \"Draw.alpha(alpha);\", \"draw_plan_config_top_expr\": \"plan.block.drawPlanConfigTop(plan, plans);\", \"plan\": plan, \"plans\": plans, \"plan_breaking\": plan_breaking, \"alpha\": alpha, \"mathf_absin_time_global_6_0_28\": mathf_absin_time_global_6_0_28, \"draw_top\": draw_top, \"mixcol_alpha\": mixcol_alpha, \"draw_reset_called\": draw_reset_called, \"draw_alpha_call\": draw_alpha_call, \"draw_plan_config_top_call\": draw_plan_config_top_call}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuilderComp.java"
        and type_entry.get("name") == "BuilderComp"
        and method.get("name") == "shouldSkip"
    ):
        return [
            "\tvar state_rules_infinite_resources: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar team_rules_infinite_resources: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar plan_breaking: bool = bool(_args[2] if _args.size() > 2 else false)",
            "\tvar core_null: bool = bool(_args[3] if _args.size() > 3 else false)",
            "\tvar plan_is_rotation: bool = bool(_args[4] if _args.size() > 4 else false)",
            "\tvar plan_is_derelict_repair: bool = bool(_args[5] if _args.size() > 5 else false)",
            "\tvar plan_stuck: bool = bool(_args[6] if _args.size() > 6 else false)",
            "\tvar core_items_has_plan_block_requirements: bool = bool(_args[7] if _args.size() > 7 else true)",
            "\tvar structs_contains_missing_requirement: bool = bool(_args[8] if _args.size() > 8 else false)",
            "\tvar guard_returns_false: bool = state_rules_infinite_resources or team_rules_infinite_resources or plan_breaking or core_null or plan_is_rotation or plan_is_derelict_repair",
            "\tvar stuck_missing_requirements: bool = plan_stuck and not core_items_has_plan_block_requirements",
            "\tvar should_skip: bool = false if guard_returns_false else (stuck_missing_requirements or structs_contains_missing_requirement)",
            "\treturn {\"source_owner\": \"PortGame.source_builder_should_skip_state\", \"method\": \"boolean shouldSkip(BuildPlan plan, @Nullable Building core){\", \"comment\": \"/** @return whether this plan should be skipped, in favor of the next one. */\", \"guard_expr\": \"if(state.rules.infiniteResources || team.rules().infiniteResources || plan.breaking || core == null || plan.isRotation(team) || plan.isDerelictRepair()) return false;\", \"return_expr\": \"return (plan.stuck && !core.items.has(plan.block.requirements)) || (Structs.contains(plan.block.requirements, i -> !core.items.has(i.item, Math.min(i.amount, 15)) && Mathf.round(i.amount * state.rules.buildCostMultiplier) > 0));\", \"state_rules_infinite_resources\": state_rules_infinite_resources, \"team_rules_infinite_resources\": team_rules_infinite_resources, \"plan_breaking\": plan_breaking, \"core_null\": core_null, \"plan_is_rotation\": plan_is_rotation, \"plan_is_derelict_repair\": plan_is_derelict_repair, \"plan_stuck\": plan_stuck, \"core_items_has_plan_block_requirements\": core_items_has_plan_block_requirements, \"structs_contains_missing_requirement\": structs_contains_missing_requirement, \"guard_returns_false\": guard_returns_false, \"stuck_missing_requirements\": stuck_missing_requirements, \"should_skip\": should_skip}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuilderComp.java"
        and type_entry.get("name") == "BuilderComp"
        and method.get("name") == "removeBuild"
    ):
        return [
            "\tvar plans: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []",
            "\tvar x: int = int(_args[1] if _args.size() > 1 else 0)",
            "\tvar y: int = int(_args[2] if _args.size() > 2 else 0)",
            "\tvar breaking: bool = bool(_args[3] if _args.size() > 3 else false)",
            "\tvar idx: int = -1",
            "\tfor i in range(plans.size()):",
            "\t\tvar plan: Dictionary = plans[i] if plans[i] is Dictionary else {}",
            "\t\tif bool(plan.get(\"breaking\", false)) == breaking and int(plan.get(\"x\", 0)) == x and int(plan.get(\"y\", 0)) == y:",
            "\t\t\tidx = i",
            "\t\t\tbreak",
            "\tvar plans_after: Array = plans.duplicate(true)",
            "\tvar remove_index_call: Variant = null",
            "\tif idx != -1:",
            "\t\tplans_after.remove_at(idx)",
            "\t\tremove_index_call = {\"call\": \"plans.removeIndex(idx);\", \"idx\": idx}",
            "\treturn {\"source_owner\": \"PortGame.source_builder_remove_build_state\", \"method\": \"void removeBuild(int x, int y, boolean breaking){\", \"comment\": \"//remove matching plan\", \"index_expr\": \"int idx = plans.indexOf(req -> req.breaking == breaking && req.x == x && req.y == y);\", \"guard_expr\": \"if(idx != -1){\", \"remove_index_expr\": \"plans.removeIndex(idx);\", \"plans\": plans, \"x\": x, \"y\": y, \"breaking\": breaking, \"idx\": idx, \"removed\": idx != -1, \"remove_index_call\": remove_index_call, \"plans_after\": plans_after}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuilderComp.java"
        and type_entry.get("name") == "BuilderComp"
        and method.get("name") == "clearBuilding"
    ):
        return [
            "\tvar plans_clear_call: String = \"plans.clear();\"",
            "\tvar plans_clear_called: bool = true",
            "\treturn {\"source_owner\": \"PortGame.source_builder_clear_building_state\", \"method\": \"void clearBuilding(){\", \"plans_clear_call\": plans_clear_call, \"plans_clear_called\": plans_clear_called}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuilderComp.java"
        and type_entry.get("name") == "BuilderComp"
        and method.get("name") == "addBuild"
        and len(method.get("parameters", [])) == 1
    ):
        return [
            "\tvar place: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar tail: bool = true",
            "\tvar add_build_call: Dictionary = {\"call\": \"addBuild(place, true);\", \"place\": place, \"tail\": tail}",
            "\treturn {\"source_owner\": \"PortGame.source_builder_add_build_tail_state\", \"method\": \"void addBuild(BuildPlan place){\", \"place\": place, \"tail\": tail, \"add_build_call\": add_build_call, \"add_build_called\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuilderComp.java"
        and type_entry.get("name") == "BuilderComp"
        and method.get("name") == "addBuild"
        and len(method.get("parameters", [])) == 2
    ):
        return [
            "\tvar plans: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []",
            "\tvar place: Dictionary = (_args[1] if _args.size() > 1 and _args[1] is Dictionary else {}).duplicate(true)",
            "\tvar tail: bool = bool(_args[2] if _args.size() > 2 else true)",
            "\tvar can_build: bool = bool(_args[3] if _args.size() > 3 else true)",
            "\tvar world_tile_exists: bool = bool(_args[4] if _args.size() > 4 else false)",
            "\tvar tile_build_is_construct_build: bool = bool(_args[5] if _args.size() > 5 else false)",
            "\tvar construct_progress: float = float(_args[6] if _args.size() > 6 else 0.0)",
            "\tvar place_after: Dictionary = place.duplicate(true)",
            "\tvar plans_after: Array = plans.duplicate(true)",
            "\tvar replace_index: int = -1",
            "\tvar removed_replace: bool = false",
            "\tvar world_tile_call: Variant = null",
            "\tvar progress_copied: bool = false",
            "\tvar add_last_call: Variant = null",
            "\tvar add_first_call: Variant = null",
            "\tif can_build:",
            "\t\tfor i in range(plans_after.size()):",
            "\t\t\tvar plan: Dictionary = plans_after[i] if plans_after[i] is Dictionary else {}",
            "\t\t\tif int(plan.get(\"x\", 0)) == int(place.get(\"x\", 0)) and int(plan.get(\"y\", 0)) == int(place.get(\"y\", 0)):",
            "\t\t\t\treplace_index = i",
            "\t\t\t\tbreak",
            "\t\tif replace_index != -1:",
            "\t\t\tplans_after.remove_at(replace_index)",
            "\t\t\tremoved_replace = true",
            "\t\tworld_tile_call = {\"call\": \"world.tile(place.x, place.y);\", \"x\": int(place.get(\"x\", 0)), \"y\": int(place.get(\"y\", 0))}",
            "\t\tif world_tile_exists and tile_build_is_construct_build:",
            "\t\t\tplace_after[\"progress\"] = construct_progress",
            "\t\t\tprogress_copied = true",
            "\t\tif tail:",
            "\t\t\tplans_after.append(place_after)",
            "\t\t\tadd_last_call = {\"call\": \"plans.addLast(place);\", \"place\": place_after}",
            "\t\telse:",
            "\t\t\tplans_after.insert(0, place_after)",
            "\t\t\tadd_first_call = {\"call\": \"plans.addFirst(place);\", \"place\": place_after}",
            "\treturn {\"source_owner\": \"PortGame.source_builder_add_build_state\", \"method\": \"void addBuild(BuildPlan place, boolean tail){\", \"comment\": \"/** Add another build plans to the queue, if it doesn't exist there yet. */\", \"guard_expr\": \"if(!canBuild()) return;\", \"replace_init_expr\": \"BuildPlan replace = null;\", \"replace_match_expr\": \"plan.x == place.x && plan.y == place.y\", \"remove_replace_expr\": \"plans.remove(replace);\", \"tile_lookup_expr\": \"Tile tile = world.tile(place.x, place.y);\", \"construct_guard_expr\": \"if(tile != null && tile.build instanceof ConstructBuild cons){\", \"progress_expr\": \"place.progress = cons.progress;\", \"tail_guard_expr\": \"if(tail){\", \"add_last_expr\": \"plans.addLast(place);\", \"add_first_expr\": \"plans.addFirst(place);\", \"plans\": plans, \"place\": place, \"tail\": tail, \"can_build\": can_build, \"world_tile_exists\": world_tile_exists, \"tile_build_is_construct_build\": tile_build_is_construct_build, \"construct_progress\": construct_progress, \"returned_early\": not can_build, \"replace_index\": replace_index, \"removed_replace\": removed_replace, \"world_tile_call\": world_tile_call, \"progress_copied\": progress_copied, \"add_last_call\": add_last_call, \"add_first_call\": add_first_call, \"plans_after\": plans_after, \"place_after\": place_after}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuilderComp.java"
        and type_entry.get("name") == "BuilderComp"
        and method.get("name") == "buildPlan"
    ):
        return [
            "\tvar plans_size: int = int(_args[0]) if _args.size() > 0 else 0",
            "\tvar plans_first: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar build_plan: Variant = null if plans_size == 0 else plans_first",
            "\treturn {\"source_owner\": \"PortGame.source_builder_build_plan_state\", \"method\": \"BuildPlan buildPlan(){\", \"return_expr\": \"return plans.size == 0 ? null : plans.first();\", \"plans_size\": plans_size, \"plans_first\": plans_first, \"build_plan\": build_plan}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuilderComp.java"
        and type_entry.get("name") == "BuilderComp"
        and method.get("name") == "activelyBuilding"
    ):
        return [
            "\tvar plans_size: int = int(_args[0] if _args.size() > 0 else 0)",
            "\tvar plans_first: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar state_is_editor: bool = bool(_args[2] if _args.size() > 2 else false)",
            "\tvar state_rules_infinite_resources: bool = bool(_args[3] if _args.size() > 3 else false)",
            "\tvar type_build_range: float = float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar within_plan: bool = bool(_args[5] if _args.size() > 5 else false)",
            "\tvar update_building: bool = bool(_args[6] if _args.size() > 6 else false)",
            "\tvar is_building: bool = plans_size != 0",
            "\tvar build_plan: Variant = null if plans_size == 0 else plans_first",
            "\tvar final_place_dst: float = 3.4028234663852886e38 if state_rules_infinite_resources else type_build_range",
            "\tvar outside_range_blocked: bool = is_building and not state_is_editor and build_plan != null and not within_plan",
            "\tvar actively_building: bool = false if outside_range_blocked else is_building and update_building",
            "\treturn {\"source_owner\": \"PortGame.source_builder_actively_building_state\", \"method\": \"boolean activelyBuilding(){\", \"comment\": \"//not actively building when not near the build plan\", \"guard_expr\": \"if(isBuilding()){\", \"plan_assignment\": \"var plan = buildPlan();\", \"range_expr\": \"state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange\", \"return_false_expr\": \"return false;\", \"return_expr\": \"return isBuilding() && updateBuilding;\", \"plans_size\": plans_size, \"plans_first\": plans_first, \"is_building\": is_building, \"build_plan\": build_plan, \"state_is_editor\": state_is_editor, \"state_rules_infinite_resources\": state_rules_infinite_resources, \"type_build_range\": type_build_range, \"final_place_dst\": final_place_dst, \"within_plan\": within_plan, \"update_building\": update_building, \"outside_range_blocked\": outside_range_blocked, \"actively_building\": actively_building}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuilderComp.java"
        and type_entry.get("name") == "BuilderComp"
        and method.get("name") == "drawBuilding"
    ):
        return [
            "\tvar active: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar last_active: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar build_plan: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar tile_exists: bool = bool(_args[3] if _args.size() > 3 else false)",
            "\tvar core_exists: bool = bool(_args[4] if _args.size() > 4 else false)",
            "\tvar within_plan: bool = bool(_args[5] if _args.size() > 5 else false)",
            "\tvar state_rules_infinite_resources: bool = bool(_args[6] if _args.size() > 6 else false)",
            "\tvar type_build_range: float = float(_args[7] if _args.size() > 7 else 0.0)",
            "\tvar is_local: bool = bool(_args[8] if _args.size() > 8 else false)",
            "\tvar tile_block_is_construct_block: bool = bool(_args[9] if _args.size() > 9 else false)",
            "\tvar state_is_paused: bool = bool(_args[10] if _args.size() > 10 else false)",
            "\tvar type_draw_build_beam: bool = bool(_args[11] if _args.size() > 11 else false)",
            "\tvar type_build_beam_offset: float = float(_args[12] if _args.size() > 12 else 0.0)",
            "\tvar mathf_absin_time_3_0_6: float = float(_args[13] if _args.size() > 13 else 0.0)",
            "\tvar x: float = float(_args[14] if _args.size() > 14 else 0.0)",
            "\tvar y: float = float(_args[15] if _args.size() > 15 else 0.0)",
            "\tvar rotation: float = float(_args[16] if _args.size() > 16 else 0.0)",
            "\tvar angles_trnsx_rotation_focus_len: float = float(_args[17] if _args.size() > 17 else 0.0)",
            "\tvar angles_trnsy_rotation_focus_len: float = float(_args[18] if _args.size() > 18 else 0.0)",
            "\tvar inactive_without_last_active: bool = not active and last_active == null",
            "\tvar plan: Variant = build_plan if active else last_active",
            "\tvar z_flying_unit_call: Variant = null",
            "\tvar outside_range_blocked: bool = not tile_exists or not within_plan",
            "\tvar remote_plan_draw: bool = false",
            "\tvar z_plans_call: Variant = null",
            "\tvar draw_plan_call: Variant = null",
            "\tvar draw_plan_top_call: Variant = null",
            "\tvar z_restore_call: Variant = null",
            "\tvar focus_len: float = type_build_beam_offset + mathf_absin_time_3_0_6",
            "\tvar px: float = x + angles_trnsx_rotation_focus_len",
            "\tvar py: float = y + angles_trnsy_rotation_focus_len",
            "\tvar draw_building_beam_call: Variant = null",
            "\tif not inactive_without_last_active:",
            "\t\tz_flying_unit_call = {\"call\": \"Draw.z(Layer.flyingUnit);\", \"layer\": \"Layer.flyingUnit\"}",
            "\t\tif not outside_range_blocked:",
            "\t\t\tremote_plan_draw = core_exists and active and not is_local and not tile_block_is_construct_block and not state_is_paused",
            "\t\t\tif remote_plan_draw:",
            "\t\t\t\tz_plans_call = {\"call\": \"Draw.z(Layer.plans - 1f);\", \"layer\": \"Layer.plans - 1f\"}",
            "\t\t\t\tdraw_plan_call = {\"call\": \"drawPlan(plan, 0.5f);\", \"plan\": plan, \"alpha\": 0.5}",
            "\t\t\t\tdraw_plan_top_call = {\"call\": \"drawPlanTop(plan, 0.5f);\", \"plan\": plan, \"alpha\": 0.5}",
            "\t\t\t\tz_restore_call = {\"call\": \"Draw.z(Layer.flyingUnit);\", \"layer\": \"Layer.flyingUnit\"}",
            "\t\t\tif type_draw_build_beam:",
            "\t\t\t\tdraw_building_beam_call = {\"call\": \"drawBuildingBeam(px, py);\", \"px\": px, \"py\": py}",
            "\treturn {\"source_owner\": \"PortGame.source_builder_draw_building_state\", \"method\": \"public void drawBuilding(){\", \"todo_comment\": \"//TODO make this more generic so it works with builder \\\"weapons\\\"\", \"active_expr\": \"boolean active = activelyBuilding();\", \"inactive_guard_expr\": \"if(!active && lastActive == null) return;\", \"z_flying_expr\": \"Draw.z(Layer.flyingUnit);\", \"plan_expr\": \"BuildPlan plan = active ? buildPlan() : lastActive;\", \"tile_expr\": \"Tile tile = plan.tile();\", \"core_expr\": \"var core = team.core();\", \"range_guard_expr\": \"if(tile == null || !within(plan, state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange)){\", \"remote_comment\": \"//draw remote plans.\", \"remote_guard_expr\": \"if(core != null && active && !isLocal() && !(tile.block() instanceof ConstructBlock) && !state.isPaused()){\", \"z_plans_expr\": \"Draw.z(Layer.plans - 1f);\", \"draw_plan_expr\": \"drawPlan(plan, 0.5f);\", \"draw_plan_top_expr\": \"drawPlanTop(plan, 0.5f);\", \"beam_guard_expr\": \"if(type.drawBuildBeam){\", \"focus_len_expr\": \"float focusLen = type.buildBeamOffset + Mathf.absin(Time.time, 3f, 0.6f);\", \"px_expr\": \"float px = x + Angles.trnsx(rotation, focusLen);\", \"py_expr\": \"float py = y + Angles.trnsy(rotation, focusLen);\", \"draw_beam_expr\": \"drawBuildingBeam(px, py);\", \"active\": active, \"last_active\": last_active, \"build_plan\": build_plan, \"plan\": plan, \"tile_exists\": tile_exists, \"core_exists\": core_exists, \"within_plan\": within_plan, \"state_rules_infinite_resources\": state_rules_infinite_resources, \"type_build_range\": type_build_range, \"is_local\": is_local, \"tile_block_is_construct_block\": tile_block_is_construct_block, \"state_is_paused\": state_is_paused, \"type_draw_build_beam\": type_draw_build_beam, \"type_build_beam_offset\": type_build_beam_offset, \"mathf_absin_time_3_0_6\": mathf_absin_time_3_0_6, \"x\": x, \"y\": y, \"rotation\": rotation, \"angles_trnsx_rotation_focus_len\": angles_trnsx_rotation_focus_len, \"angles_trnsy_rotation_focus_len\": angles_trnsy_rotation_focus_len, \"inactive_without_last_active\": inactive_without_last_active, \"z_flying_unit_call\": z_flying_unit_call, \"outside_range_blocked\": outside_range_blocked, \"remote_plan_draw\": remote_plan_draw, \"z_plans_call\": z_plans_call, \"draw_plan_call\": draw_plan_call, \"draw_plan_top_call\": draw_plan_top_call, \"z_restore_call\": z_restore_call, \"focus_len\": focus_len, \"px\": px, \"py\": py, \"draw_building_beam_call\": draw_building_beam_call}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuilderComp.java"
        and type_entry.get("name") == "BuilderComp"
        and method.get("name") == "drawBuildingBeam"
    ):
        return [
            "\tvar px: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar py: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar active: bool = bool(_args[2] if _args.size() > 2 else false)",
            "\tvar last_active: Variant = _args[3] if _args.size() > 3 else null",
            "\tvar build_plan: Variant = _args[4] if _args.size() > 4 else null",
            "\tvar tile_exists: bool = bool(_args[5] if _args.size() > 5 else false)",
            "\tvar within_plan: bool = bool(_args[6] if _args.size() > 6 else false)",
            "\tvar state_rules_infinite_resources: bool = bool(_args[7] if _args.size() > 7 else false)",
            "\tvar type_build_range: float = float(_args[8] if _args.size() > 8 else 0.0)",
            "\tvar plan_breaking: bool = bool(_args[9] if _args.size() > 9 else false)",
            "\tvar tile_block_size: int = int(_args[10] if _args.size() > 10 else 0)",
            "\tvar last_size: int = int(_args[11] if _args.size() > 11 else 0)",
            "\tvar plan_block_size: int = int(_args[12] if _args.size() > 12 else 0)",
            "\tvar plan_drawx: float = float(_args[13] if _args.size() > 13 else 0.0)",
            "\tvar plan_drawy: float = float(_args[14] if _args.size() > 14 else 0.0)",
            "\tvar build_alpha: float = float(_args[15] if _args.size() > 15 else 0.0)",
            "\tvar tile_build_is_construct_build: bool = bool(_args[16] if _args.size() > 16 else false)",
            "\tvar source_tilesize: float = float(_args[17] if _args.size() > 17 else 0.0)",
            "\tvar mathf_absin_time_2_2_1_1: float = float(_args[18] if _args.size() > 18 else 0.0)",
            "\tvar rotation_value: float = float(_args[19] if _args.size() > 19 else 0.0)",
            "\tvar inactive_without_last_active: bool = not active and last_active == null",
            "\tvar plan: Variant = build_plan if active else last_active",
            "\tvar outside_range_blocked: bool = not tile_exists or not within_plan",
            "\tvar size: int = tile_block_size if plan_breaking and active else last_size if plan_breaking else plan_block_size",
            "\tvar tx: float = plan_drawx",
            "\tvar ty: float = plan_drawy",
            "\tvar stroke_color: String = \"Pal.remove\" if plan_breaking else \"Pal.accent\"",
            "\tvar z_flying_unit_call: Variant = null",
            "\tvar stroke_call: Variant = null",
            "\tvar z_build_beam_call: Variant = null",
            "\tvar draw_alpha_call: Variant = null",
            "\tvar fill_last_active_square_call: Variant = null",
            "\tvar build_beam_call: Variant = null",
            "\tvar focus_square_radius: float = 1.8 + mathf_absin_time_2_2_1_1",
            "\tvar focus_square_rotation: float = rotation_value + 45.0",
            "\tvar focus_square_call: Variant = null",
            "\tvar draw_reset_call: Variant = null",
            "\tvar z_restore_call: Variant = null",
            "\tif not inactive_without_last_active:",
            "\t\tz_flying_unit_call = {\"call\": \"Draw.z(Layer.flyingUnit);\", \"layer\": \"Layer.flyingUnit\"}",
            "\t\tif not outside_range_blocked:",
            "\t\t\tstroke_call = {\"call\": \"Lines.stroke(1f, plan.breaking ? Pal.remove : Pal.accent);\", \"width\": 1.0, \"color\": stroke_color}",
            "\t\t\tz_build_beam_call = {\"call\": \"Draw.z(Layer.buildBeam);\", \"layer\": \"Layer.buildBeam\"}",
            "\t\t\tdraw_alpha_call = {\"call\": \"Draw.alpha(buildAlpha);\", \"alpha\": build_alpha}",
            "\t\t\tif not active and not tile_build_is_construct_build:",
            "\t\t\t\tfill_last_active_square_call = {\"call\": \"Fill.square(plan.drawx(), plan.drawy(), size * tilesize/2f);\", \"x\": plan_drawx, \"y\": plan_drawy, \"radius\": float(size) * source_tilesize / 2.0}",
            "\t\t\tbuild_beam_call = {\"call\": \"Drawf.buildBeam(px, py, tx, ty, Vars.tilesize * size / 2f);\", \"px\": px, \"py\": py, \"tx\": tx, \"ty\": ty, \"radius\": source_tilesize * float(size) / 2.0}",
            "\t\t\tfocus_square_call = {\"call\": \"Fill.square(px, py, 1.8f + Mathf.absin(Time.time, 2.2f, 1.1f), rotation + 45);\", \"x\": px, \"y\": py, \"radius\": focus_square_radius, \"rotation\": focus_square_rotation}",
            "\t\t\tdraw_reset_call = {\"call\": \"Draw.reset();\"}",
            "\t\t\tz_restore_call = {\"call\": \"Draw.z(Layer.flyingUnit);\", \"layer\": \"Layer.flyingUnit\"}",
            "\treturn {\"source_owner\": \"PortGame.source_builder_draw_building_beam_state\", \"method\": \"public void drawBuildingBeam(float px, float py){\", \"active_expr\": \"boolean active = activelyBuilding();\", \"inactive_guard_expr\": \"if(!active && lastActive == null) return;\", \"z_flying_expr\": \"Draw.z(Layer.flyingUnit);\", \"plan_expr\": \"BuildPlan plan = active ? buildPlan() : lastActive;\", \"tile_expr\": \"Tile tile = world.tile(plan.x, plan.y);\", \"range_guard_expr\": \"if(tile == null || !within(plan, state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange)){\", \"size_expr\": \"int size = plan.breaking ? active ? tile.block().size : lastSize : plan.block.size;\", \"draw_xy_expr\": \"float tx = plan.drawx(), ty = plan.drawy();\", \"stroke_expr\": \"Lines.stroke(1f, plan.breaking ? Pal.remove : Pal.accent);\", \"z_build_beam_expr\": \"Draw.z(Layer.buildBeam);\", \"alpha_expr\": \"Draw.alpha(buildAlpha);\", \"fill_last_active_guard_expr\": \"if(!active && !(tile.build instanceof ConstructBuild)){\", \"fill_last_active_square_expr\": \"Fill.square(plan.drawx(), plan.drawy(), size * tilesize/2f);\", \"build_beam_expr\": \"Drawf.buildBeam(px, py, tx, ty, Vars.tilesize * size / 2f);\", \"focus_square_expr\": \"Fill.square(px, py, 1.8f + Mathf.absin(Time.time, 2.2f, 1.1f), rotation + 45);\", \"draw_reset_expr\": \"Draw.reset();\", \"z_restore_expr\": \"Draw.z(Layer.flyingUnit);\", \"px\": px, \"py\": py, \"active\": active, \"last_active\": last_active, \"build_plan\": build_plan, \"plan\": plan, \"tile_exists\": tile_exists, \"within_plan\": within_plan, \"state_rules_infinite_resources\": state_rules_infinite_resources, \"type_build_range\": type_build_range, \"plan_breaking\": plan_breaking, \"tile_block_size\": tile_block_size, \"last_size\": last_size, \"plan_block_size\": plan_block_size, \"plan_drawx\": plan_drawx, \"plan_drawy\": plan_drawy, \"build_alpha\": build_alpha, \"tile_build_is_construct_build\": tile_build_is_construct_build, \"source_tilesize\": source_tilesize, \"mathf_absin_time_2_2_1_1\": mathf_absin_time_2_2_1_1, \"rotation\": rotation_value, \"inactive_without_last_active\": inactive_without_last_active, \"outside_range_blocked\": outside_range_blocked, \"size\": size, \"tx\": tx, \"ty\": ty, \"stroke_color\": stroke_color, \"z_flying_unit_call\": z_flying_unit_call, \"stroke_call\": stroke_call, \"z_build_beam_call\": z_build_beam_call, \"draw_alpha_call\": draw_alpha_call, \"fill_last_active_square_call\": fill_last_active_square_call, \"build_beam_call\": build_beam_call, \"focus_square_radius\": focus_square_radius, \"focus_square_rotation\": focus_square_rotation, \"focus_square_call\": focus_square_call, \"draw_reset_call\": draw_reset_call, \"z_restore_call\": z_restore_call}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BlockUnitComp.java"
        and type_entry.get("name") == "BlockUnitComp"
        and method.get("name") == "add"
    ):
        return [
            "\tvar tile_null: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar runtime_exception_thrown: bool = tile_null",
            "\tvar runtime_exception_message: String = \"Do not add BlockUnit entities to the game, they will simply crash. Internal use only.\" if runtime_exception_thrown else \"\"",
            "\treturn {\"source_owner\": \"PortGame.source_block_unit_add_state\", \"method\": \"public void add(){\", \"guard_expr\": \"if(tile == null){\", \"throw_expr\": \"throw new RuntimeException(\\\"Do not add BlockUnit entities to the game, they will simply crash. Internal use only.\\\");\", \"tile_null\": tile_null, \"runtime_exception_thrown\": runtime_exception_thrown, \"runtime_exception_message\": runtime_exception_message}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BlockUnitComp.java"
        and type_entry.get("name") == "BlockUnitComp"
        and method.get("name") == "update"
    ):
        return [
            "\tvar tile_exists: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar team: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar tile_team: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar tile_guard: bool = tile_exists",
            "\tvar team_after: Variant = team",
            "\tif tile_guard:",
            "\t\tteam_after = tile_team",
            "\treturn {\"source_owner\": \"PortGame.source_block_unit_update_state\", \"method\": \"public void update(){\", \"guard_expr\": \"if(tile != null){\", \"team_assignment_expr\": \"team = tile.team;\", \"tile_exists\": tile_exists, \"team\": team, \"tile_team\": tile_team, \"tile_guard\": tile_guard, \"team_after\": team_after}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BlockUnitComp.java"
        and type_entry.get("name") == "BlockUnitComp"
        and method.get("name") == "icon"
    ):
        return [
            "\tvar tile_block_ui_icon: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"source_owner\": \"PortGame.source_block_unit_icon_state\", \"method\": \"public TextureRegion icon(){\", \"return_expr\": \"return tile.block.uiIcon;\", \"tile_block_ui_icon\": tile_block_ui_icon}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BlockUnitComp.java"
        and type_entry.get("name") == "BlockUnitComp"
        and method.get("name") == "ammof"
    ):
        return [
            "\tvar ammo: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\treturn {\"source_owner\": \"PortGame.source_block_unit_ammof_state\", \"method\": \"public float ammof(){\", \"return_expr\": \"return ammo;\", \"ammo\": ammo}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BlockUnitComp.java"
        and type_entry.get("name") == "BlockUnitComp"
        and method.get("name") == "killed"
    ):
        return [
            "\tvar tile_kill_call: String = \"tile.kill();\"",
            "\tvar tile_kill_called: bool = true",
            "\treturn {\"source_owner\": \"PortGame.source_block_unit_killed_state\", \"method\": \"public void killed(){\", \"tile_kill_call\": tile_kill_call, \"tile_kill_called\": tile_kill_called}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BlockUnitComp.java"
        and type_entry.get("name") == "BlockUnitComp"
        and method.get("name") == "damage"
        and len(method.get("parameters", [])) == 2
        and method.get("parameters", [])[0].get("name") == "v"
        and method.get("parameters", [])[1].get("name") == "b"
    ):
        return [
            "\tvar v: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar b: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar tile_damage_call: String = \"tile.damage(v, b);\"",
            "\tvar tile_damage_called: bool = true",
            "\treturn {\"source_owner\": \"PortGame.source_block_unit_damage_state\", \"method\": \"public void damage(float v, boolean b){\", \"tile_damage_call\": tile_damage_call, \"tile_damage_called\": tile_damage_called, \"v\": v, \"b\": b}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BlockUnitComp.java"
        and type_entry.get("name") == "BlockUnitComp"
        and method.get("name") == "team"
        and len(method.get("parameters", [])) == 1
        and method.get("parameters", [])[0].get("name") == "team"
    ):
        return [
            "\tvar tile_exists: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar this_team: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar team: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar tile_team: Variant = _args[3] if _args.size() > 3 else null",
            "\tvar outer_guard: bool = tile_exists and this_team != team",
            "\tvar this_team_after: Variant = this_team",
            "\tvar inner_guard: bool = false",
            "\tvar tile_change_team_call: Variant = null",
            "\tvar tile_change_team_called: bool = false",
            "\tif outer_guard:",
            "\t\tthis_team_after = team",
            "\t\tinner_guard = tile_team != team",
            "\t\tif inner_guard:",
            "\t\t\ttile_change_team_call = {\"call\": \"tile.changeTeam(team);\", \"team\": team}",
            "\t\t\ttile_change_team_called = true",
            "\treturn {\"source_owner\": \"PortGame.source_block_unit_team_state\", \"method\": \"public void team(Team team){\", \"outer_guard_expr\": \"if(tile != null && this.team != team){\", \"this_team_assignment_expr\": \"this.team = team;\", \"inner_guard_expr\": \"if(tile.team != team){\", \"tile_change_team_call_expr\": \"tile.changeTeam(team);\", \"tile_exists\": tile_exists, \"this_team\": this_team, \"team\": team, \"tile_team\": tile_team, \"outer_guard\": outer_guard, \"inner_guard\": inner_guard, \"this_team_after\": this_team_after, \"tile_change_team_call\": tile_change_team_call, \"tile_change_team_called\": tile_change_team_called}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BlockUnitComp.java"
        and type_entry.get("name") == "BlockUnitComp"
        and method.get("name") == "dead"
    ):
        return [
            "\tvar tile_null: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar tile_dead: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar dead: bool = tile_null or tile_dead",
            "\treturn {\"source_owner\": \"PortGame.source_block_unit_dead_state\", \"method\": \"public boolean dead(){\", \"return_expr\": \"return tile == null || tile.dead();\", \"tile_null\": tile_null, \"tile_dead\": tile_dead, \"dead\": dead}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BlockUnitComp.java"
        and type_entry.get("name") == "BlockUnitComp"
        and method.get("name") == "isValid"
    ):
        return [
            "\tvar tile_exists: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar tile_is_valid: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar is_valid: bool = tile_exists and tile_is_valid",
            "\treturn {\"source_owner\": \"PortGame.source_block_unit_is_valid_state\", \"method\": \"public boolean isValid(){\", \"return_expr\": \"return tile != null && tile.isValid();\", \"tile_exists\": tile_exists, \"tile_is_valid\": tile_is_valid, \"is_valid\": is_valid}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BlockUnitComp.java"
        and type_entry.get("name") == "BlockUnitComp"
        and method.get("name") == "isAdded"
    ):
        return [
            "\tvar tile_exists: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar tile_is_valid: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar is_added: bool = tile_exists and tile_is_valid",
            "\treturn {\"source_owner\": \"PortGame.source_block_unit_is_added_state\", \"method\": \"public boolean isAdded(){\", \"return_expr\": \"return tile != null && tile.isValid();\", \"tile_exists\": tile_exists, \"tile_is_valid\": tile_is_valid, \"is_added\": is_added}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/PosComp.java"
        and type_entry.get("name") == "PosComp"
        and method.get("name") == "set"
        and len(method.get("parameters", [])) == 2
        and method.get("parameters", [])[0].get("type") == "float"
        and method.get("parameters", [])[1].get("type") == "float"
    ):
        return [
            "\tvar x_value: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar y_value: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\treturn {\"source_owner\": \"PortGame.source_pos_set_state\", \"method\": \"void set(float x, float y){\", \"x_assign_expr\": \"this.x = x;\", \"y_assign_expr\": \"this.y = y;\", \"x\": x_value, \"y\": y_value}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/ShielderComp.java"
        and type_entry.get("name") == "ShielderComp"
        and method.get("name") == "absorb"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_shielder_absorb_state\", \"method\": \"void absorb(){\", \"empty_body\": \"void absorb(){\\n\\n    }\", \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/SyncComp.java"
        and type_entry.get("name") == "SyncComp"
        and method.get("name") == "snapSync"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_sync_snap_sync_state\", \"method\": \"void snapSync(){}\", \"empty_body\": \"void snapSync(){}\", \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/SyncComp.java"
        and type_entry.get("name") == "SyncComp"
        and method.get("name") == "snapInterpolation"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_sync_snap_interpolation_state\", \"method\": \"void snapInterpolation(){}\", \"empty_body\": \"void snapInterpolation(){}\", \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/SyncComp.java"
        and type_entry.get("name") == "SyncComp"
        and method.get("name") == "readSync"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_sync_read_sync_state\", \"method\": \"void readSync(Reads read){}\", \"empty_body\": \"void readSync(Reads read){}\", \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/SyncComp.java"
        and type_entry.get("name") == "SyncComp"
        and method.get("name") == "writeSync"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_sync_write_sync_state\", \"method\": \"void writeSync(Writes write){}\", \"empty_body\": \"void writeSync(Writes write){}\", \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/SyncComp.java"
        and type_entry.get("name") == "SyncComp"
        and method.get("name") == "readSyncManual"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_sync_read_sync_manual_state\", \"method\": \"void readSyncManual(FloatBuffer buffer){}\", \"empty_body\": \"void readSyncManual(FloatBuffer buffer){}\", \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/SyncComp.java"
        and type_entry.get("name") == "SyncComp"
        and method.get("name") == "writeSyncManual"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_sync_write_sync_manual_state\", \"method\": \"void writeSyncManual(FloatBuffer buffer){}\", \"empty_body\": \"void writeSyncManual(FloatBuffer buffer){}\", \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/SyncComp.java"
        and type_entry.get("name") == "SyncComp"
        and method.get("name") == "afterSync"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_sync_after_sync_state\", \"method\": \"void afterSync(){}\", \"empty_body\": \"void afterSync(){}\", \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/SyncComp.java"
        and type_entry.get("name") == "SyncComp"
        and method.get("name") == "interpolate"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_sync_interpolate_state\", \"method\": \"void interpolate(){}\", \"empty_body\": \"void interpolate(){}\", \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/SyncComp.java"
        and type_entry.get("name") == "SyncComp"
        and method.get("name") == "isSyncHidden"
    ):
        return [
            "\tvar player: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"source_owner\": \"PortGame.source_sync_is_sync_hidden_state\", \"method\": \"boolean isSyncHidden(Player player){\", \"player\": player, \"return_expr\": \"return false;\", \"is_sync_hidden\": false}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/SyncComp.java"
        and type_entry.get("name") == "SyncComp"
        and method.get("name") == "handleSyncHidden"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_sync_handle_sync_hidden_state\", \"method\": \"void handleSyncHidden(){\", \"empty_body\": \"void handleSyncHidden(){\\n\\n}\", \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/SyncComp.java"
        and type_entry.get("name") == "SyncComp"
        and method.get("name") == "update"
    ):
        return [
            "\tvar net_client: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar is_local: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar is_remote: bool = bool(_args[2] if _args.size() > 2 else false)",
            "\tvar interpolate_called: bool = (net_client and not is_local) or is_remote",
            "\tvar interpolate_result: Variant = null",
            "\tif interpolate_called:",
            "\t\tinterpolate_result = java_method_interpolate_7([])",
            "\treturn {\"source_owner\": \"PortGame.source_sync_update_interpolate_state\", \"method\": \"public void update(){\", \"condition\": \"if((Vars.net.client() && !isLocal()) || isRemote()){\", \"interpolate_call\": \"interpolate();\", \"net_client\": net_client, \"is_local\": is_local, \"is_remote\": is_remote, \"interpolate_called\": interpolate_called, \"interpolate\": interpolate_result}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/SyncComp.java"
        and type_entry.get("name") == "SyncComp"
        and method.get("name") == "remove"
    ):
        return [
            "\tvar net_client: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar entity_id: int = int(_args[1] if _args.size() > 1 else -1)",
            "\tvar add_removed_entity_call: Variant = null",
            "\tif net_client:",
            "\t\tadd_removed_entity_call = {\"call\": \"Vars.netClient.addRemovedEntity(id());\", \"entity_id\": entity_id}",
            "\treturn {\"source_owner\": \"PortGame.source_sync_remove_client_removed_entity_state\", \"method\": \"public void remove(){\", \"condition\": \"if(Vars.net.client()){\", \"add_removed_entity_call\": add_removed_entity_call, \"id_call\": \"id()\", \"net_client\": net_client, \"entity_id\": entity_id}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/UnitTetherComp.java"
        and type_entry.get("name") == "UnitTetherComp"
        and method.get("name") == "afterRead"
    ):
        return [
            "\tvar spawner_unit_id := int(_args[0] if _args.size() > 0 else -1)",
            "\tvar groups_unit_get_by_id_result: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar guard: bool = spawner_unit_id != -1",
            "\tvar spawner_value: Variant = null",
            "\tvar groups_unit_get_by_id_call: Variant = null",
            "\tif guard:",
            "\t\tgroups_unit_get_by_id_call = {\"call\": \"Groups.unit.getByID(spawnerUnitId)\", \"id\": spawner_unit_id}",
            "\t\tspawner_value = groups_unit_get_by_id_result",
            "\treturn {\"source_owner\": \"PortGame.source_unit_tether_after_read_state\", \"method\": \"public void afterRead(){\", \"guard_expr\": \"if(spawnerUnitId != -1) spawner = Groups.unit.getByID(spawnerUnitId);\", \"reset_expr\": \"spawnerUnitId = -1;\", \"spawnerUnitIdBefore\": spawner_unit_id, \"guard\": guard, \"groupsUnitGetById\": groups_unit_get_by_id_call, \"spawner\": spawner_value, \"spawnerUnitId\": -1}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/UnitTetherComp.java"
        and type_entry.get("name") == "UnitTetherComp"
        and method.get("name") == "afterSync"
    ):
        return [
            "\tvar spawner_unit_id := int(_args[0] if _args.size() > 0 else -1)",
            "\tvar groups_unit_get_by_id_result: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar guard: bool = spawner_unit_id != -1",
            "\tvar spawner_value: Variant = null",
            "\tvar groups_unit_get_by_id_call: Variant = null",
            "\tif guard:",
            "\t\tgroups_unit_get_by_id_call = {\"call\": \"Groups.unit.getByID(spawnerUnitId)\", \"id\": spawner_unit_id}",
            "\t\tspawner_value = groups_unit_get_by_id_result",
            "\treturn {\"source_owner\": \"PortGame.source_unit_tether_after_sync_state\", \"method\": \"public void afterSync(){\", \"guard_expr\": \"if(spawnerUnitId != -1) spawner = Groups.unit.getByID(spawnerUnitId);\", \"reset_expr\": \"spawnerUnitId = -1;\", \"spawnerUnitIdBefore\": spawner_unit_id, \"guard\": guard, \"groupsUnitGetById\": groups_unit_get_by_id_call, \"spawner\": spawner_value, \"spawnerUnitId\": -1}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/UnitTetherComp.java"
        and type_entry.get("name") == "UnitTetherComp"
        and method.get("name") == "update"
    ):
        return [
            "\tvar spawner_exists := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar spawner_is_valid := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar spawner_team_value: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar team_value: Variant = _args[3] if _args.size() > 3 else null",
            "\tvar unit_id := int(_args[4] if _args.size() > 4 else 0)",
            "\tvar spawner_id := int(_args[5] if _args.size() > 5 else -1)",
            "\tvar guard: bool = (not spawner_exists) or (not spawner_is_valid) or spawner_team_value != team_value",
            "\tvar despawn_call: Variant = null",
            "\tvar next_spawner_unit_id := -1",
            "\tif guard:",
            "\t\tdespawn_call = {\"call\": \"Call.unitDespawn(self())\", \"unit\": unit_id}",
            "\tif not guard:",
            "\t\tnext_spawner_unit_id = spawner_id",
            "\treturn {\"source_owner\": \"PortGame.source_unit_tether_update_state\", \"method\": \"public void update(){\", \"guard_expr\": \"if(spawner == null || !spawner.isValid() || spawner.team != team){\", \"else_expr\": \"}else{\", \"assign_expr\": \"spawnerUnitId = spawner.id;\", \"spawner_exists\": spawner_exists, \"spawner_is_valid\": spawner_is_valid, \"spawner_team_value\": spawner_team_value, \"team_value\": team_value, \"guard\": guard, \"despawn\": despawn_call, \"spawnerUnitId\": next_spawner_unit_id}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "kill"
    ):
        return [
            "\tvar self_state: Variant = _args[0] if _args.size() > 0 else {}",
            "\treturn {\"source_owner\": \"PortGame.source_building_kill_state\", \"replace\": \"@Replace\", \"override\": \"@Override\", \"method\": \"public void kill(){\", \"build_destroyed_call\": \"Call.buildDestroyed(self());\", \"self_state\": self_state}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "damage"
    ):
        return [
            "\tvar damage_amount := float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar dead_state := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar health := float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar block_health_multiplier := float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar source_time := float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar net_client := bool(_args[5] if _args.size() > 5 else false)",
            "\tvar handled_damage := float(_args[6] if _args.size() > 6 else 0.0)",
            "\tvar self_state: Variant = _args[7] if _args.size() > 7 else {}",
            "\tvar block_health_scale := {}",
            "\tvar handle_damage_gate := {}",
            "\tvar health_changed_call_state := {}",
            "\tvar destroy_gate_state := {}",
            "\tif not dead_state:",
            "\t\tif is_zero_approx(block_health_multiplier):",
            "\t\t\tblock_health_scale = {\"damage\": health + 1.0, \"last_damage_time\": source_time}",
            "\t\telse:",
            "\t\t\tblock_health_scale = {\"damage\": damage_amount / block_health_multiplier, \"last_damage_time\": source_time}",
            "\t\tvar scaled_damage := float(block_health_scale.get(\"damage\", damage_amount))",
            "\t\tif not net_client:",
            "\t\t\thandle_damage_gate = {\"health\": health - handled_damage, \"damage\": scaled_damage, \"handled_damage\": handled_damage, \"handle_damage_called\": true}",
            "\t\telse:",
            "\t\t\thandle_damage_gate = {\"health\": health, \"damage\": scaled_damage, \"handled_damage\": null, \"handle_damage_called\": false}",
            "\t\thealth_changed_call_state = {\"health_changed\": true}",
            "\t\tvar destroy_health := float(handle_damage_gate.get(\"health\", health))",
            "\t\tif destroy_health <= 0.0:",
            "\t\t\tdestroy_gate_state = {\"destroy_gate\": \"if(health <= 0){\", \"build_destroyed_call\": \"Call.buildDestroyed(self());\", \"build_destroyed_called\": true, \"build_destroyed\": self_state}",
            "\t\telse:",
            "\t\t\tdestroy_gate_state = {\"destroy_gate\": \"if(health <= 0){\", \"build_destroyed_call\": \"Call.buildDestroyed(self());\", \"build_destroyed_called\": false, \"build_destroyed\": null}",
            "\treturn {\"source_owner\": \"PortGame.source_building_damage_dead_guard_state\", \"block_health_source_owner\": \"PortGame.source_building_damage_block_health_scale_state\", \"handle_damage_source_owner\": \"PortGame.source_building_damage_handle_damage_gate_state\", \"health_changed_source_owner\": \"PortGame.source_building_damage_health_changed_call_state\", \"destroy_gate_source_owner\": \"PortGame.source_building_damage_destroy_gate_state\", \"replace\": \"@Replace\", \"override\": \"@Override\", \"method\": \"public void damage(float damage){\", \"dead_guard\": \"if(dead()) return;\", \"block_health\": \"float dm = state.rules.blockHealth(team);\", \"last_damage_time_expr\": \"lastDamageTime = Time.time;\", \"zero_guard\": \"if(Mathf.zero(dm)){\", \"zero_assignment\": \"damage = health + 1;\", \"scale_assignment\": \"damage /= dm;\", \"client_comment\": \"//TODO handle this better on the client.\", \"client_guard\": \"if(!net.client()){\", \"health_assignment\": \"health -= handleDamage(damage);\", \"health_changed_call\": \"healthChanged();\", \"damage_amount\": damage_amount, \"dead_state\": dead_state, \"returned\": dead_state, \"continues\": not dead_state, \"block_health_multiplier\": block_health_multiplier, \"health\": health, \"source_time\": source_time, \"net_client\": net_client, \"handled_damage\": handled_damage, \"self_state\": self_state, \"block_health_scale\": block_health_scale, \"handle_damage_gate\": handle_damage_gate, \"health_changed_call_state\": health_changed_call_state, \"destroy_gate\": destroy_gate_state}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "healthChanged"
    ):
        return [
            "\tvar net_server := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar self_state: Variant = _args[1] if _args.size() > 1 else {}",
            "\tvar build_health_update: Variant = self_state",
            "\tif not net_server:",
            "\t\tbuild_health_update = null",
            "\treturn {\"source_owner\": \"PortGame.source_building_health_changed_state\", \"method\": \"public void healthChanged(){\", \"server_comment\": \"//server-side, health updates are batched.\", \"server_guard\": \"if(net.server()){\", \"build_health_update_call\": \"netServer.buildHealthUpdate(self());\", \"notify_call\": \"indexer.notifyHealthChanged(self());\", \"net_server\": net_server, \"self_state\": self_state, \"build_health_update_called\": net_server, \"build_health_update\": build_health_update, \"notify_health_changed\": self_state}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "sense"
        and [parameter.get("name") for parameter in method.get("parameters", [])] == ["sensor"]
    ):
        return [
            "\tvar world_x := float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar world_y := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar source_tilesize := float(_args[2] if _args.size() > 2 else 8.0)",
            "\tvar source_x := world_x / source_tilesize",
            "\tvar source_y := world_y / source_tilesize",
            "\tvar health := float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar max_health := float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar efficiency := float(_args[5] if _args.size() > 5 else 0.0)",
            "\tvar time_scale := float(_args[6] if _args.size() > 6 else 0.0)",
            "\tvar ranged_range := float(_args[7] if _args.size() > 7 else 0.0)",
            "\tvar has_range := bool(_args[8] if _args.size() > 8 else false)",
            "\tvar rotation_value := float(_args[9] if _args.size() > 9 else 0.0)",
            "\tvar sense_range := ranged_range / source_tilesize if has_range else 0.0",
            "\tvar sense_health_process := {\"method\": \"public double sense(LAccess sensor){\", \"health_case\": \"case health -> health;\", \"max_health_case\": \"case maxHealth -> maxHealth;\", \"efficiency_case\": \"case efficiency -> efficiency;\", \"timescale_case\": \"case timescale -> timeScale;\", \"range_case\": \"case range -> this instanceof Ranged r ? r.range() / tilesize : 0;\", \"rotation_case\": \"case rotation -> rotation;\", \"health_input\": health, \"max_health_input\": max_health, \"efficiency_input\": efficiency, \"time_scale\": time_scale, \"ranged_range\": ranged_range, \"source_tilesize\": source_tilesize, \"has_range\": has_range, \"rotation_value\": rotation_value, \"health\": health, \"max_health\": max_health, \"efficiency\": efficiency, \"timescale\": time_scale, \"range\": sense_range, \"rotation\": rotation_value}",
            "\tvar total_items := float(_args[10] if _args.size() > 10 else 0.0)",
            "\tvar total_liquids := float(_args[11] if _args.size() > 11 else 0.0)",
            "\tvar total_power := float(_args[12] if _args.size() > 12 else 0.0)",
            "\tvar sense_totals := {\"method\": \"public double sense(LAccess sensor){\", \"total_items_case\": \"case totalItems -> items == null ? 0 : items.total();\", \"total_liquids_comment\": \"//totalLiquids is inherently bad design, but unfortunately it is useful for conduits/tanks\", \"total_liquids_case\": \"case totalLiquids -> liquids == null ? 0 : liquids.currentAmount();\", \"total_power_case\": \"case totalPower -> power == null || block.consPower == null ? 0 : power.status * (block.consPower.buffered ? block.consPower.capacity : 1f);\", \"total_items\": total_items, \"total_liquids\": total_liquids, \"total_power\": total_power}",
            "\tvar block_has_items := bool(_args[13] if _args.size() > 13 else false)",
            "\tvar block_item_capacity := float(_args[14] if _args.size() > 14 else 0.0)",
            "\tvar block_has_liquids := bool(_args[15] if _args.size() > 15 else false)",
            "\tvar block_liquid_capacity := float(_args[16] if _args.size() > 16 else 0.0)",
            "\tvar has_cons_power := bool(_args[17] if _args.size() > 17 else false)",
            "\tvar cons_power_capacity := float(_args[18] if _args.size() > 18 else 0.0)",
            "\tvar has_power_module := bool(_args[19] if _args.size() > 19 else false)",
            "\tvar last_scaled_power_in := float(_args[20] if _args.size() > 20 else 0.0)",
            "\tvar last_scaled_power_out := float(_args[21] if _args.size() > 21 else 0.0)",
            "\tvar last_power_stored := float(_args[22] if _args.size() > 22 else 0.0)",
            "\tvar last_power_capacity := float(_args[23] if _args.size() > 23 else 0.0)",
            "\tvar power_net_in := last_scaled_power_in * 60.0 if has_power_module else 0.0",
            "\tvar power_net_out := last_scaled_power_out * 60.0 if has_power_module else 0.0",
            "\tvar power_net_stored := last_power_stored if has_power_module else 0.0",
            "\tvar power_net_capacity := last_power_capacity if has_power_module else 0.0",
            "\tvar sense_capacity_power_net := {\"method\": \"public double sense(LAccess sensor){\", \"item_capacity_case\": \"case itemCapacity -> block.hasItems ? block.itemCapacity : 0;\", \"liquid_capacity_case\": \"case liquidCapacity -> block.hasLiquids ? block.liquidCapacity : 0;\", \"power_capacity_case\": \"case powerCapacity -> block.consPower != null ? block.consPower.capacity : 0f;\", \"power_net_in_case\": \"case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;\", \"power_net_out_case\": \"case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;\", \"power_net_stored_case\": \"case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();\", \"power_net_capacity_case\": \"case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();\", \"block_has_items\": block_has_items, \"block_item_capacity\": block_item_capacity, \"block_has_liquids\": block_has_liquids, \"block_liquid_capacity\": block_liquid_capacity, \"has_cons_power\": has_cons_power, \"cons_power_capacity\": cons_power_capacity, \"has_power_module\": has_power_module, \"last_scaled_power_in\": last_scaled_power_in, \"last_scaled_power_out\": last_scaled_power_out, \"last_power_stored\": last_power_stored, \"last_power_capacity\": last_power_capacity, \"item_capacity\": block_item_capacity if block_has_items else 0.0, \"liquid_capacity\": block_liquid_capacity if block_has_liquids else 0.0, \"power_capacity\": cons_power_capacity if has_cons_power else 0.0, \"power_net_in\": power_net_in, \"power_net_out\": power_net_out, \"power_net_stored\": power_net_stored, \"power_net_capacity\": power_net_capacity}",
            "\tvar enabled_state := bool(_args[24] if _args.size() > 24 else false)",
            "\tvar is_control_block := bool(_args[25] if _args.size() > 25 else false)",
            "\tvar is_controlled := bool(_args[26] if _args.size() > 26 else false)",
            "\tvar ctrl_player_value := float(_args[27] if _args.size() > 27 else 0.0)",
            "\tvar sense_enabled_controlled := {\"method\": \"public double sense(LAccess sensor){\", \"enabled_case\": \"case enabled -> enabled ? 1 : 0;\", \"controlled_case\": \"case controlled -> this instanceof ControlBlock c && c.isControlled() ? GlobalVars.ctrlPlayer : 0;\", \"enabled_state\": enabled_state, \"is_control_block\": is_control_block, \"is_controlled\": is_controlled, \"ctrl_player_value\": ctrl_player_value, \"enabled\": 1.0 if enabled_state else 0.0, \"controlled\": ctrl_player_value if is_control_block and is_controlled else 0.0}",
            "\tvar has_payload_seq := bool(_args[28] if _args.size() > 28 else false)",
            "\tvar payload_seq_total := float(_args[29] if _args.size() > 29 else 0.0)",
            "\tvar has_single_payload := bool(_args[30] if _args.size() > 30 else false)",
            "\tvar block_size_value := float(_args[31] if _args.size() > 31 else 0.0)",
            "\tvar payload_count := 0.0",
            "\tif has_payload_seq:",
            "\t\tpayload_count += payload_seq_total",
            "\tif has_single_payload:",
            "\t\tpayload_count += 1.0",
            "\tvar sense_payload_size := {\"method\": \"public double sense(LAccess sensor){\", \"payload_count_case\": \"case payloadCount -> (getPayloads() != null ? getPayloads().total() : 0) + (getPayload() != null ? 1 : 0);\", \"size_case\": \"case size -> block.size;\", \"has_payload_seq\": has_payload_seq, \"payload_seq_total\": payload_seq_total, \"has_single_payload\": has_single_payload, \"block_size_value\": block_size_value, \"payload_count\": payload_count, \"size\": block_size_value}",
            "\tvar camera_is_control_block := bool(_args[32] if _args.size() > 32 else false)",
            "\tvar unit_camera_x := float(_args[33] if _args.size() > 33 else 0.0)",
            "\tvar unit_camera_y := float(_args[34] if _args.size() > 34 else 0.0)",
            "\tvar unit_camera_width := float(_args[35] if _args.size() > 35 else 0.0)",
            "\tvar unit_camera_height := float(_args[36] if _args.size() > 36 else 0.0)",
            "\tvar camera_x := unit_camera_x if camera_is_control_block else 0.0",
            "\tvar camera_y := unit_camera_y if camera_is_control_block else 0.0",
            "\tvar camera_width := unit_camera_width if camera_is_control_block else 0.0",
            "\tvar camera_height := unit_camera_height if camera_is_control_block else 0.0",
            "\tvar sense_camera_default := {\"method\": \"public double sense(LAccess sensor){\", \"camera_case\": \"case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;\", \"default_case\": \"default -> Float.NaN; //gets converted to null in logic\", \"is_control_block\": camera_is_control_block, \"unit_camera_x\": unit_camera_x, \"unit_camera_y\": unit_camera_y, \"unit_camera_width\": unit_camera_width, \"unit_camera_height\": unit_camera_height, \"camera_x\": camera_x, \"camera_y\": camera_y, \"camera_width\": camera_width, \"camera_height\": camera_height, \"invalid_sensor\": null}",
            "\treturn {\"source_owner\": \"PortGame.source_building_sense_position_state\", \"health_process_source_owner\": \"PortGame.source_building_sense_health_process_state\", \"totals_source_owner\": \"PortGame.source_building_sense_totals_state\", \"capacity_power_net_source_owner\": \"PortGame.source_building_sense_capacity_power_net_state\", \"enabled_controlled_source_owner\": \"PortGame.source_building_sense_enabled_controlled_state\", \"payload_size_source_owner\": \"PortGame.source_building_sense_payload_size_state\", \"camera_default_source_owner\": \"PortGame.source_building_sense_camera_default_state\", \"method\": \"public double sense(LAccess sensor){\", \"switch_case\": \"return switch(sensor){\", \"x_case\": \"case x -> World.conv(x);\", \"y_case\": \"case y -> World.conv(y);\", \"world_conv_method\": \"public static float conv(float coord){\", \"world_conv_return\": \"return coord / tilesize;\", \"world_x\": world_x, \"world_y\": world_y, \"source_tilesize\": source_tilesize, \"x\": source_x, \"y\": source_y, \"health_process\": sense_health_process, \"sense_health_process\": sense_health_process, \"totals\": sense_totals, \"sense_totals\": sense_totals, \"capacity_power_net\": sense_capacity_power_net, \"sense_capacity_power_net\": sense_capacity_power_net, \"enabled_controlled\": sense_enabled_controlled, \"sense_enabled_controlled\": sense_enabled_controlled, \"payload_size\": sense_payload_size, \"sense_payload_size\": sense_payload_size, \"camera_default\": sense_camera_default, \"sense_camera_default\": sense_camera_default}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "senseObject"
    ):
        return [
            "\tvar sensor := str(_args[0] if _args.size() > 0 else \"\")",
            "\tvar block_value: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar has_items_module := bool(_args[2] if _args.size() > 2 else false)",
            "\tvar first_item_value: Variant = _args[3] if _args.size() > 3 else null",
            "\tvar config_senseable := bool(_args[4] if _args.size() > 4 else false)",
            "\tvar config_value: Variant = _args[5] if _args.size() > 5 else null",
            "\tvar single_payload_kind := str(_args[6] if _args.size() > 6 else \"\")",
            "\tvar single_payload_content: Variant = _args[7] if _args.size() > 7 else null",
            "\tvar no_sensed := false",
            "\tvar value: Variant = null",
            "\tmatch sensor:",
            "\t\t\"type\":",
            "\t\t\tvalue = block_value",
            "\t\t\"firstItem\":",
            "\t\t\tvalue = first_item_value if has_items_module else null",
            "\t\t\"config\":",
            "\t\t\tvalue = config_value if config_senseable else null",
            "\t\t\"payloadType\":",
            "\t\t\tif single_payload_kind == \"unit\" or single_payload_kind == \"block\":",
            "\t\t\t\tvalue = single_payload_content",
            "\t\t_:",
            "\t\t\tno_sensed = true",
            "\tvar sense_object := {\"method\": \"public Object senseObject(LAccess sensor){\", \"type_case\": \"case type -> block;\", \"first_item_case\": \"case firstItem -> items == null ? null : items.first();\", \"config_case\": \"case config -> block.configSenseable() ? config() : null;\", \"payload_type_case\": \"case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null;\", \"default_case\": \"default -> noSensed;\", \"sensor\": sensor, \"block_value\": block_value, \"has_items_module\": has_items_module, \"first_item_value\": first_item_value, \"config_senseable\": config_senseable, \"config_value\": config_value, \"single_payload_kind\": single_payload_kind, \"single_payload_content\": single_payload_content, \"no_sensed\": no_sensed, \"value\": value}",
            "\treturn {\"source_owner\": \"PortGame.source_building_sense_object_state\", \"object_source_owner\": \"PortGame.source_building_sense_object_state\", \"sense_object\": sense_object}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "sense"
        and [parameter.get("name") for parameter in method.get("parameters", [])] == ["content"]
    ):
        return [
            "\tvar content_type := str(_args[0] if _args.size() > 0 else \"\")",
            "\tvar has_items_module := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar item_amount := float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar has_liquids_module := bool(_args[3] if _args.size() > 3 else false)",
            "\tvar liquid_amount := float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar has_payloads := bool(_args[5] if _args.size() > 5 else false)",
            "\tvar payload_amount := float(_args[6] if _args.size() > 6 else 0.0)",
            "\tvar sensed := false",
            "\tvar value: Variant = null",
            "\tif content_type == \"item\" and has_items_module:",
            "\t\tsensed = true",
            "\t\tvalue = item_amount",
            "\telif content_type == \"liquid\" and has_liquids_module:",
            "\t\tsensed = true",
            "\t\tvalue = liquid_amount",
            "\telif (content_type == \"unit\" or content_type == \"block\") and has_payloads:",
            "\t\tsensed = true",
            "\t\tvalue = payload_amount",
            "\tvar sense_content := {\"method\": \"public double sense(Content content){\", \"item_case\": \"if(content instanceof Item i && items != null) return items.get(i);\", \"liquid_case\": \"if(content instanceof Liquid l && liquids != null) return liquids.get(l);\", \"payloads_guard\": \"if(getPayloads() != null){\", \"unit_payload_case\": \"if(content instanceof UnitType u) return getPayloads().get(u);\", \"block_payload_case\": \"if(content instanceof Block b) return getPayloads().get(b);\", \"invalid_return\": \"return Float.NaN; //invalid sense\", \"content_type\": content_type, \"has_items_module\": has_items_module, \"item_amount\": item_amount, \"has_liquids_module\": has_liquids_module, \"liquid_amount\": liquid_amount, \"has_payloads\": has_payloads, \"payload_amount\": payload_amount, \"sensed\": sensed, \"value\": value}",
            "\treturn {\"source_owner\": \"PortGame.source_building_sense_content_state\", \"content_source_owner\": \"PortGame.source_building_sense_content_state\", \"sense_content\": sense_content}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "control"
        and [parameter.get("type") for parameter in method.get("parameters", [])] == ["LAccess", "double", "double", "double", "double"]
    ):
        return [
            "\tvar current_enabled := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar control_type := str(_args[1] if _args.size() > 1 else \"\")",
            "\tvar p1 := float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar next_enabled := current_enabled",
            "\tif control_type == \"enabled\":",
            "\t\tnext_enabled = not absf(p1) <= SOURCE_FLOAT_ROUNDING_ERROR",
            "\tvar control_enabled := {\"method\": \"public void control(LAccess type, double p1, double p2, double p3, double p4){\", \"guard\": \"if(type == LAccess.enabled){\", \"assignment\": \"enabled = !Mathf.zero((float)p1);\", \"mathf_float_rounding_error\": \"public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits\", \"mathf_zero_float_method\": \"public static boolean zero(float value){\", \"mathf_zero_float_return\": \"return Math.abs(value) <= FLOAT_ROUNDING_ERROR;\", \"current_enabled\": current_enabled, \"control_type\": control_type, \"p1\": p1, \"enabled\": next_enabled}",
            "\treturn {\"source_owner\": \"PortGame.source_building_control_enabled_state\", \"enabled_source_owner\": \"PortGame.source_building_control_enabled_state\", \"control_enabled\": control_enabled}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "control"
        and [parameter.get("type") for parameter in method.get("parameters", [])] == ["LAccess", "Object", "double", "double", "double"]
    ):
        return [
            "\tvar control_type := str(_args[0] if _args.size() > 0 else \"\")",
            "\tvar block_logic_configurable := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar p1_is_logic_build := bool(_args[2] if _args.size() > 2 else false)",
            "\tvar p1_value: Variant = _args[3] if _args.size() > 3 else null",
            "\tvar configured_called := false",
            "\tvar value: Variant = null",
            "\tif control_type == \"config\" and block_logic_configurable and not p1_is_logic_build:",
            "\t\tconfigured_called = true",
            "\t\tvalue = p1_value",
            "\tvar control_config := {\"method\": \"public void control(LAccess type, Object p1, double p2, double p3, double p4){\", \"lag_comment\": \"//don't execute configure instructions that copy logic building configures; this can cause extreme lag\", \"guard\": \"if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){\", \"new_comment\": \"//change config only if it's new\", \"configured_call\": \"configured(null, p1);\", \"control_type\": control_type, \"block_logic_configurable\": block_logic_configurable, \"p1_is_logic_build\": p1_is_logic_build, \"p1_value\": p1_value, \"configured_called\": configured_called, \"builder\": null, \"value\": value}",
            "\treturn {\"source_owner\": \"PortGame.source_building_control_config_state\", \"config_source_owner\": \"PortGame.source_building_control_config_state\", \"control_config\": control_config}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "setProp"
        and [parameter.get("type") for parameter in method.get("parameters", [])] == ["LAccess", "double"]
    ):
        return [
            "\tvar prop := str(_args[0] if _args.size() > 0 else \"\")",
            "\tvar current_health := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar max_health_value := float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar value := float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar dead_state := bool(_args[4] if _args.size() > 4 else false)",
            "\tvar self_state: Variant = _args[5] if _args.size() > 5 else null",
            "\tvar health := current_health",
            "\tvar build_destroyed_called := false",
            "\tvar build_destroyed: Variant = null",
            "\tvar health_changed := false",
            "\tif prop == \"health\":",
            "\t\thealth = clampf(value, 0.0, max_health_value)",
            "\t\tif health <= 0.0 and not dead_state:",
            "\t\t\tbuild_destroyed_called = true",
            "\t\t\tbuild_destroyed = self_state",
            "\t\telse:",
            "\t\t\thealth_changed = true",
            "\tvar current_team_id := int(_args[1] if _args.size() > 1 else 0)",
            "\tvar team_value := float(_args[2] if _args.size() > 2 else value)",
            "\tvar team_id := current_team_id",
            "\tvar change_team_called := false",
            "\tvar change_team: Variant = null",
            "\tif prop == \"team\":",
            "\t\tvar next_team_id := int(team_value)",
            "\t\tif current_team_id != next_team_id:",
            "\t\t\tteam_id = next_team_id",
            "\t\t\tchange_team_called = true",
            "\t\t\tchange_team = next_team_id",
            "\tvar current_power_status := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar has_power := bool(_args[2] if _args.size() > 2 else false)",
            "\tvar has_cons_power := bool(_args[3] if _args.size() > 3 else false)",
            "\tvar cons_power_buffered := bool(_args[4] if _args.size() > 4 else false)",
            "\tvar cons_power_capacity := float(_args[5] if _args.size() > 5 else 0.0)",
            "\tvar total_power_value := float(_args[6] if _args.size() > 6 else value)",
            "\tvar power_status := current_power_status",
            "\tvar updated := false",
            "\tif prop == \"totalPower\" and has_power and has_cons_power and cons_power_buffered:",
            "\t\tpower_status = clampf(total_power_value / cons_power_capacity, 0.0, 1.0)",
            "\t\tupdated = true",
            "\tvar set_prop_health := {\"method\": \"public void setProp(LAccess prop, double value){\", \"switch_prop\": \"switch(prop){\", \"health_case\": \"case health -> {\", \"clamp_assign\": \"health = (float)Mathf.clamp(value, 0, maxHealth);\", \"destroy_gate\": \"if(health <= 0f && !dead()){\", \"build_destroyed_call\": \"Call.buildDestroyed(self());\", \"else_branch\": \"}else{\", \"health_changed_call\": \"healthChanged();\", \"prop\": prop, \"current_health\": current_health, \"max_health_value\": max_health_value, \"value\": value, \"dead_state\": dead_state, \"self_state\": self_state, \"health\": health, \"build_destroyed_called\": build_destroyed_called, \"build_destroyed\": build_destroyed, \"health_changed\": health_changed}",
            "\tvar set_prop_team_double := {\"method\": \"public void setProp(LAccess prop, double value){\", \"team_case\": \"case team -> {\", \"team_lookup\": \"Team team = Team.get((int)value);\", \"change_gate\": \"if(this.team != team){\", \"change_team_call\": \"changeTeam(team);\", \"prop\": prop, \"current_team_id\": current_team_id, \"value\": team_value, \"team_id\": team_id, \"change_team_called\": change_team_called, \"change_team\": change_team}",
            "\tvar set_prop_total_power := {\"method\": \"public void setProp(LAccess prop, double value){\", \"total_power_case\": \"case totalPower -> {\", \"total_power_guard\": \"if(power != null && block.consPower != null && block.consPower.buffered){\", \"status_assign\": \"power.status = Mathf.clamp((float)(value / block.consPower.capacity));\", \"prop\": prop, \"current_power_status\": current_power_status, \"has_power\": has_power, \"has_cons_power\": has_cons_power, \"cons_power_buffered\": cons_power_buffered, \"cons_power_capacity\": cons_power_capacity, \"value\": total_power_value, \"power_status\": power_status, \"updated\": updated}",
            "\treturn {\"source_owner\": \"PortGame.source_building_set_prop_health_state\", \"health_source_owner\": \"PortGame.source_building_set_prop_health_state\", \"team_source_owner\": \"PortGame.source_building_set_prop_team_double_state\", \"total_power_source_owner\": \"PortGame.source_building_set_prop_total_power_state\", \"set_prop_health\": set_prop_health, \"set_prop_team_double\": set_prop_team_double, \"set_prop_total_power\": set_prop_total_power}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "setProp"
        and [parameter.get("type") for parameter in method.get("parameters", [])] == ["LAccess", "Object"]
    ):
        return [
            "\tvar prop := str(_args[0] if _args.size() > 0 else \"\")",
            "\tvar current_team_value: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar value_is_team := bool(_args[2] if _args.size() > 2 else false)",
            "\tvar team_value: Variant = _args[3] if _args.size() > 3 else null",
            "\tvar team: Variant = current_team_value",
            "\tvar change_team_called := false",
            "\tvar change_team: Variant = null",
            "\tif prop == \"team\" and value_is_team and current_team_value != team_value:",
            "\t\tteam = team_value",
            "\t\tchange_team_called = true",
            "\t\tchange_team = team_value",
            "\tvar set_prop_team_object := {\"method\": \"public void setProp(LAccess prop, Object value){\", \"switch_prop\": \"switch(prop){\", \"team_case\": \"case team -> {\", \"team_gate\": \"if(value instanceof Team team && this.team != team){\", \"change_team_call\": \"changeTeam(team);\", \"prop\": prop, \"current_team_value\": current_team_value, \"value_is_team\": value_is_team, \"team_value\": team_value, \"team\": team, \"change_team_called\": change_team_called, \"change_team\": change_team}",
            "\treturn {\"source_owner\": \"PortGame.source_building_set_prop_team_object_state\", \"team_object_source_owner\": \"PortGame.source_building_set_prop_team_object_state\", \"set_prop_team_object\": set_prop_team_object}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "setProp"
        and [parameter.get("type") for parameter in method.get("parameters", [])] == ["UnlockableContent", "double"]
    ):
        return [
            "\tvar content_type := str(_args[0] if _args.size() > 0 else \"\")",
            "\tvar has_items_module := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar item_value: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar current_amount := int(_args[3] if _args.size() > 3 else 0)",
            "\tvar value := float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar accepted_stack := int(_args[5] if _args.size() > 5 else 0)",
            "\tvar has_liquids_module := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar liquid_value: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar current_liquid_amount_value := float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar block_liquid_capacity := float(_args[5] if _args.size() > 5 else 0.0)",
            "\tvar accept_liquid_result := bool(_args[6] if _args.size() > 6 else false)",
            "\tvar current_liquid_matches := bool(_args[7] if _args.size() > 7 else false)",
            "\tvar current_liquid_amount := float(_args[8] if _args.size() > 8 else 0.0)",
            "\tvar block_consumes_liquid := bool(_args[9] if _args.size() > 9 else false)",
            "\tvar amount := int(value)",
            "\tvar source_exprs := {\"method\": \"public void setProp(UnlockableContent content, double value){\", \"item_gate\": \"if(content instanceof Item item && items != null){\", \"amount_assign\": \"int amount = (int)value;\", \"amount_diff_gate\": \"if(items.get(item) != amount){\", \"increase_gate\": \"if(items.get(item) < amount){\", \"handle_stack_call\": \"handleStack(item, acceptStack(item, amount - items.get(item), null), null);\", \"remove_gate\": \"}else if(amount >= 0){\", \"remove_stack_call\": \"removeStack(item, items.get(item) - amount);\"}",
            "\tvar set_prop_item_content: Dictionary",
            "\tif content_type != \"item\" or not has_items_module:",
            "\t\tset_prop_item_content = {\"action\": \"none\", \"item\": item_value, \"amount\": current_amount, \"delta\": 0, \"accepted\": 0}",
            "\telif current_amount == amount:",
            "\t\tset_prop_item_content = {\"action\": \"none\", \"item\": item_value, \"amount\": amount, \"delta\": 0, \"accepted\": 0}",
            "\telif current_amount < amount:",
            "\t\tset_prop_item_content = {\"action\": \"handle_stack\", \"item\": item_value, \"amount\": amount, \"delta\": amount - current_amount, \"accepted\": accepted_stack}",
            "\telif amount >= 0:",
            "\t\tset_prop_item_content = {\"action\": \"remove_stack\", \"item\": item_value, \"amount\": amount, \"delta\": current_amount - amount, \"accepted\": 0}",
            "\telse:",
            "\t\tset_prop_item_content = {\"action\": \"none\", \"item\": item_value, \"amount\": amount, \"delta\": 0, \"accepted\": 0}",
            "\tset_prop_item_content.merge(source_exprs)",
            "\tset_prop_item_content.merge({\"content_type\": content_type, \"has_items_module\": has_items_module, \"value\": value})",
            "\tvar liquid_source_exprs := {\"method\": \"public void setProp(UnlockableContent content, double value){\", \"liquid_gate\": \"}else if(content instanceof Liquid liquid && liquids != null){\", \"clamp_assign\": \"float amount = Mathf.clamp((float)value, 0f, block.liquidCapacity);\", \"decreasing_comment\": \"//decreasing amount is always allowed\", \"set_gate\": \"if(amount < liquids.get(liquid) || (acceptLiquid(self(), liquid) && (liquids.current() == liquid || liquids.currentAmount() <= 0.1f || block.consumesLiquid(liquid)))){\", \"liquids_set_call\": \"liquids.set(liquid, amount);\"}",
            "\tvar liquid_amount := clampf(value, 0.0, block_liquid_capacity)",
            "\tvar can_set_liquid := liquid_amount < current_liquid_amount_value",
            "\tif not can_set_liquid:",
            "\t\tcan_set_liquid = accept_liquid_result and (current_liquid_matches or current_liquid_amount <= 0.1 or block_consumes_liquid)",
            "\tvar set_prop_liquid_content: Dictionary",
            "\tif content_type != \"liquid\" or not has_liquids_module:",
            "\t\tset_prop_liquid_content = {\"action\": \"none\", \"liquid\": liquid_value, \"amount\": current_liquid_amount_value}",
            "\telif can_set_liquid:",
            "\t\tset_prop_liquid_content = {\"action\": \"set_liquid\", \"liquid\": liquid_value, \"amount\": liquid_amount}",
            "\telse:",
            "\t\tset_prop_liquid_content = {\"action\": \"none\", \"liquid\": liquid_value, \"amount\": current_liquid_amount_value}",
            "\tset_prop_liquid_content.merge(liquid_source_exprs)",
            "\tset_prop_liquid_content.merge({\"content_type\": content_type, \"has_liquids_module\": has_liquids_module, \"value\": value})",
            "\treturn {\"source_owner\": \"PortGame.source_building_set_prop_item_content_state\", \"item_content_source_owner\": \"PortGame.source_building_set_prop_item_content_state\", \"liquid_content_source_owner\": \"PortGame.source_building_set_prop_liquid_content_state\", \"set_prop_item_content\": set_prop_item_content, \"set_prop_liquid_content\": set_prop_liquid_content}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "inFogTo"
    ):
        return [
            "\tvar same_team := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar rules_fog := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar block_size_value := int(_args[2] if _args.size() > 2 else 0)",
            "\tvar block_size_offset := int(_args[3] if _args.size() > 3 else 0)",
            "\tvar tile_x := int(_args[4] if _args.size() > 4 else 0)",
            "\tvar tile_y := int(_args[5] if _args.size() > 5 else 0)",
            "\tvar is_discovered := bool(_args[6] if _args.size() > 6 else false)",
            "\tvar visible_tiles: Array = _args[7] if _args.size() > 7 and _args[7] is Array else []",
            "\tvar in_fog_initial_gate := {\"method\": \"public boolean inFogTo(Team viewer){\", \"initial_return\": \"if(team == viewer || !state.rules.fog) return false;\", \"same_team\": same_team, \"rules_fog\": rules_fog}",
            "\tvar in_fog_discovery_gate := {\"method\": \"public boolean inFogTo(Team viewer){\", \"grid_declaration\": \"int size = block.size, of = block.sizeOffset, tx = tile.x, ty = tile.y;\", \"undiscovered_return\": \"if(!isDiscovered(viewer)) return true;\", \"block_size_value\": block_size_value, \"block_size_offset\": block_size_offset, \"tile_x\": tile_x, \"tile_y\": tile_y, \"is_discovered\": is_discovered}",
            "\tvar in_fog_visibility_loop := {\"method\": \"public boolean inFogTo(Team viewer){\", \"outer_loop\": \"for(int x = 0; x < size; x++){\", \"inner_loop\": \"for(int y = 0; y < size; y++){\", \"visible_tile_check\": \"if(fogControl.isVisibleTile(viewer, tx + x + of, ty + y + of)){\", \"visible_return\": \"return false;\", \"final_return\": \"return true;\", \"block_size_value\": block_size_value, \"block_size_offset\": block_size_offset, \"tile_x\": tile_x, \"tile_y\": tile_y, \"visible_tiles\": visible_tiles}",
            "\tif same_team or not rules_fog:",
            "\t\tin_fog_initial_gate.merge({\"returned\": true, \"value\": false})",
            "\telse:",
            "\t\tin_fog_initial_gate.merge({\"returned\": false, \"value\": null})",
            "\tif not is_discovered:",
            "\t\tin_fog_discovery_gate.merge({\"returned\": true, \"value\": true, \"grid\": {\"size\": block_size_value, \"offset\": block_size_offset, \"tile_x\": tile_x, \"tile_y\": tile_y}})",
            "\telse:",
            "\t\tin_fog_discovery_gate.merge({\"returned\": false, \"value\": null, \"grid\": {\"size\": block_size_value, \"offset\": block_size_offset, \"tile_x\": tile_x, \"tile_y\": tile_y}})",
            "\tvar checked_tiles: Array = []",
            "\tvar visible_match := false",
            "\tfor x in range(block_size_value):",
            "\t\tif visible_match:",
            "\t\t\tbreak",
            "\t\tfor y in range(block_size_value):",
            "\t\t\tvar check_x := tile_x + x + block_size_offset",
            "\t\t\tvar check_y := tile_y + y + block_size_offset",
            "\t\t\tchecked_tiles.append({\"x\": check_x, \"y\": check_y})",
            "\t\t\tfor visible_tile in visible_tiles:",
            "\t\t\t\tif int(visible_tile.get(\"x\", -2147483648)) == check_x and int(visible_tile.get(\"y\", -2147483648)) == check_y:",
            "\t\t\t\t\tvisible_match = true",
            "\t\t\t\t\tin_fog_visibility_loop.merge({\"in_fog\": false, \"checked_tiles\": checked_tiles, \"visible_tile\": {\"x\": check_x, \"y\": check_y}})",
            "\t\t\t\t\tbreak",
            "\t\t\tif visible_match:",
            "\t\t\t\tbreak",
            "\tif not visible_match:",
            "\t\tin_fog_visibility_loop.merge({\"in_fog\": true, \"checked_tiles\": checked_tiles, \"visible_tile\": null})",
            "\treturn {\"source_owner\": \"PortGame.source_building_in_fog_initial_gate_state\", \"in_fog_initial_gate_source_owner\": \"PortGame.source_building_in_fog_initial_gate_state\", \"in_fog_initial_gate\": in_fog_initial_gate, \"in_fog_discovery_gate_source_owner\": \"PortGame.source_building_in_fog_discovery_gate_state\", \"in_fog_discovery_gate\": in_fog_discovery_gate, \"in_fog_visibility_loop_source_owner\": \"PortGame.source_building_in_fog_visibility_loop_state\", \"in_fog_visibility_loop\": in_fog_visibility_loop}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "killed"
    ):
        return [
            "\tvar tile_value: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar killed_initial_side_effects := {\"method\": \"public void killed(){\", \"tile_value\": tile_value, \"dead\": true, \"event\": {\"type\": \"BlockDestroyEvent\", \"tile\": tile_value}, \"on_destroyed_called\": true, \"next_step\": \"tile_remove_gate\"}",
            "\tvar tile_not_empty_tile := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar killed_removal_side_effects := {\"method\": \"public void killed(){\", \"tile_not_empty_tile\": tile_not_empty_tile, \"tile_remove_gate\": tile_not_empty_tile, \"tile_remove_called\": tile_not_empty_tile, \"remove_called\": true, \"after_destroyed_called\": true}",
            "\treturn {\"source_owner\": \"PortGame.source_building_killed_initial_side_effects_state\", \"killed_initial_side_effects_source_owner\": \"PortGame.source_building_killed_initial_side_effects_state\", \"killed_initial_side_effects\": killed_initial_side_effects, \"killed_removal_side_effects_source_owner\": \"PortGame.source_building_killed_removal_side_effects_state\", \"killed_removal_side_effects\": killed_removal_side_effects}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "checkAllowUpdate"
    ):
        return [
            "\tvar current_enabled := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar allow_update_result := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar check_allow_update := {\"method\": \"public void checkAllowUpdate(){\", \"guard\": \"if(!allowUpdate()){\", \"disable\": \"enabled = false;\", \"current_enabled\": current_enabled, \"allow_update_result\": allow_update_result}",
            "\tif not allow_update_result:",
            "\t\tcheck_allow_update.merge({\"enabled\": false, \"changed\": current_enabled})",
            "\telse:",
            "\t\tcheck_allow_update.merge({\"enabled\": current_enabled, \"changed\": false})",
            "\treturn {\"source_owner\": \"PortGame.source_building_check_allow_update_state\", \"check_allow_update_source_owner\": \"PortGame.source_building_check_allow_update_state\", \"check_allow_update\": check_allow_update}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "update"
    ):
        return [
            "\tvar current_time_scale := float(_args[0] if _args.size() > 0 else 1.0)",
            "\tvar current_time_scale_duration := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar time_delta := float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar next_duration := current_time_scale_duration - time_delta",
            "\tvar update_timescale_decay := {\"field\": \"private transient float timeScale = 1f, timeScaleDuration;\", \"method\": \"public void update(){\", \"decay_gate\": \"if((timeScaleDuration -= Time.delta) <= 0f){\", \"reset\": \"timeScale = 1f;\", \"current_time_scale\": current_time_scale, \"current_time_scale_duration\": current_time_scale_duration, \"time_delta\": time_delta}",
            "\tif next_duration <= 0.0:",
            "\t\tupdate_timescale_decay.merge({\"time_scale\": 1.0, \"time_scale_duration\": next_duration})",
            "\telse:",
            "\t\tupdate_timescale_decay.merge({\"time_scale\": current_time_scale, \"time_scale_duration\": next_duration})",
            "\tvar headless_mode := bool(_args[3] if _args.size() > 3 else false)",
            "\tvar ambient_sound_value: Variant = _args[4] if _args.size() > 4 else null",
            "\tvar sounds_none_value: Variant = _args[5] if _args.size() > 5 else null",
            "\tvar should_ambient_sound_result := bool(_args[6] if _args.size() > 6 else false)",
            "\tvar block_ambient_sound_volume := float(_args[7] if _args.size() > 7 else 0.0)",
            "\tvar ambient_volume_value := float(_args[8] if _args.size() > 8 else 0.0)",
            "\tvar should_loop: bool = not headless_mode and ambient_sound_value != sounds_none_value and should_ambient_sound_result",
            "\tvar update_ambient_sound_gate := {\"method\": \"public void update(){\", \"gate\": \"if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){\", \"loop_call\": \"control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());\", \"volume_expr\": \"block.ambientSoundVolume * ambientVolume()\", \"headless_mode\": headless_mode, \"ambient_sound_value\": ambient_sound_value, \"sounds_none_value\": sounds_none_value, \"should_ambient_sound_result\": should_ambient_sound_result, \"block_ambient_sound_volume\": block_ambient_sound_volume, \"ambient_volume_value\": ambient_volume_value}",
            "\tif not should_loop:",
            "\t\tupdate_ambient_sound_gate.merge({\"loop_called\": false, \"sound\": ambient_sound_value, \"volume\": 0.0})",
            "\telse:",
            "\t\tupdate_ambient_sound_gate.merge({\"loop_called\": true, \"sound\": ambient_sound_value, \"volume\": block_ambient_sound_volume * ambient_volume_value})",
            "\tvar update_consumption_call := {\"method\": \"public void update(){\", \"call\": \"updateConsumption();\", \"update_consumption_called\": true}",
            "\tvar enabled_state := bool(_args[9] if _args.size() > 9 else false)",
            "\tvar block_no_update_disabled := bool(_args[10] if _args.size() > 10 else false)",
            "\tvar update_tile_called := enabled_state or not block_no_update_disabled",
            "\tvar update_tile_gate := {\"method\": \"public void update(){\", \"gate\": \"if(enabled || !block.noUpdateDisabled){\", \"update_tile_call\": \"updateTile();\", \"enabled_state\": enabled_state, \"block_no_update_disabled\": block_no_update_disabled, \"update_tile_called\": update_tile_called}",
            "\treturn {\"source_owner\": \"PortGame.source_building_update_timescale_decay_state\", \"update_timescale_decay_source_owner\": \"PortGame.source_building_update_timescale_decay_state\", \"update_timescale_decay\": update_timescale_decay, \"update_ambient_sound_gate_source_owner\": \"PortGame.source_building_update_ambient_sound_gate_state\", \"update_ambient_sound_gate\": update_ambient_sound_gate, \"update_consumption_call_source_owner\": \"PortGame.source_building_update_consumption_call_state\", \"update_consumption_call\": update_consumption_call, \"update_tile_gate_source_owner\": \"PortGame.source_building_update_tile_gate_state\", \"update_tile_gate\": update_tile_gate}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "updateFogVisibility"
    ):
        return [
            "\tvar was_visible := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar in_fog_to_player_team := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar visible_flags := int(_args[2] if _args.size() > 2 else 0)",
            "\tvar player_team_id := int(_args[3] if _args.size() > 3 else 0)",
            "\tvar self_state: Variant = _args[4] if _args.size() > 4 else null",
            "\tvar tile_state: Variant = _args[5] if _args.size() > 5 else null",
            "\tvar should_update := not was_visible and not in_fog_to_player_team",
            "\tvar update_fog_visibility := {\"comment\": \"/** When a block is newly revealed outside of camera view range, it is updated on the minimap. */\", \"method\": \"public void updateFogVisibility(){\", \"gate\": \"if(!wasVisible && !inFogTo(player.team())){\", \"was_visible_input\": was_visible, \"in_fog_to_player_team\": in_fog_to_player_team, \"visible_flags_input\": visible_flags, \"player_team_id\": player_team_id}",
            "\tif not should_update:",
            "\t\tupdate_fog_visibility.merge({\"visible_flags\": visible_flags, \"was_visible\": was_visible, \"update_shadow\": null, \"minimap_update\": null})",
            "\telse:",
            "\t\tvar updated_flags := visible_flags | (1 << player_team_id)",
            "\t\tupdate_fog_visibility.merge({\"visible_flags\": updated_flags, \"was_visible\": true, \"update_shadow\": self_state, \"minimap_update\": tile_state})",
            "\treturn {\"source_owner\": \"PortGame.source_building_update_fog_visibility_state\", \"update_fog_visibility_source_owner\": \"PortGame.source_building_update_fog_visibility_state\", \"update_fog_visibility\": update_fog_visibility}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "splashLiquid"
    ):
        return [
            "\tvar liquid: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar amount := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar source_block_size := int(_args[2] if _args.size() > 2 else 0)",
            "\tvar source_tilesize := float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar splash := clampf(amount / 4.0, 0.0, 10.0)",
            "\tvar deposit_count := int(ceil(clampf(amount / 5.0, 0.0, 30.0)))",
            "\tvar delays: Array[float] = []",
            "\tfor i in deposit_count:",
            "\t\tdelays.append(float(i) / 2.0)",
            "\treturn {\"source_owner\": \"PortGame.source_building_splash_liquid_state\", \"method\": \"public void splashLiquid(Liquid liquid, float amount){\", \"splash_expr\": \"float splash = Mathf.clamp(amount / 4f, 0f, 10f);\", \"loop\": \"for(int i = 0; i < Mathf.clamp(amount / 5, 0, 30); i++){\", \"delay_expr\": \"Time.run(i / 2f, () -> {\", \"tile_world\": \"Tile other = world.tileWorld(x + Mathf.range(block.size * tilesize / 2), y + Mathf.range(block.size * tilesize / 2));\", \"deposit_guard\": \"if(other != null){\", \"deposit\": \"Puddles.deposit(other, liquid, splash);\", \"liquid\": liquid, \"amount\": amount, \"source_block_size\": source_block_size, \"source_tilesize\": source_tilesize, \"splash\": splash, \"deposit_count\": deposit_count, \"delays\": delays, \"random_range\": float(source_block_size) * source_tilesize / 2.0, \"deposit_if_tile_exists\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "onDeconstructed"
    ):
        return [
            "\tvar has_liquids_module := bool(_args[0] if _args.size() > 0 else false)",
            "\tvar current_amount := float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar current_incinerable := bool(_args[2] if _args.size() > 2 else false)",
            "\tvar deconstruct_drop_all_liquid := bool(_args[3] if _args.size() > 3 else false)",
            "\tvar source_block_size := int(_args[4] if _args.size() > 4 else 0)",
            "\tvar can_drop_liquid := not current_incinerable or deconstruct_drop_all_liquid",
            "\tvar deposit_linked_tiles := has_liquids_module and current_amount > 0.0 and can_drop_liquid",
            "\tvar per_cell := 0.0",
            "\tif deposit_linked_tiles:",
            "\t\tper_cell = current_amount / float(source_block_size * source_block_size) * 2.0",
            "\treturn {\"source_owner\": \"PortGame.source_building_on_deconstructed_liquid_state\", \"comment\": \"Called when a block begins (not finishes!) deconstruction. The building is still present at this point.\", \"method\": \"public void onDeconstructed(@Nullable Unit builder){\", \"deposit_comment\": \"//deposit non-incinerable liquid on ground\", \"gate\": \"if(liquids != null && liquids.currentAmount() > 0 && (!liquids.current().incinerable || block.deconstructDropAllLiquid)){\", \"per_cell_expr\": \"float perCell = liquids.currentAmount() / (block.size * block.size) * 2f;\", \"deposit_call_expr\": \"tile.getLinkedTiles(other -> Puddles.deposit(other, liquids.current(), perCell));\", \"has_liquids_module\": has_liquids_module, \"current_amount\": current_amount, \"current_incinerable\": current_incinerable, \"deconstruct_drop_all_liquid\": deconstruct_drop_all_liquid, \"source_block_size\": source_block_size, \"can_drop_liquid\": can_drop_liquid, \"deposit_linked_tiles\": deposit_linked_tiles, \"per_cell\": per_cell, \"deposit_call\": deposit_linked_tiles}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/comp/BuildingComp.java"
        and type_entry.get("name") == "BuildingComp"
        and method.get("name") == "onDestroyed"
    ):
        return [
            "\tvar base_explosiveness := float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar has_items := bool(_args[1] if _args.size() > 1 else false)",
            "\tvar item_states: Array = _args[2] if _args.size() > 2 and _args[2] is Array else []",
            "\tvar item_cap := int(_args[3] if _args.size() > 3 else 0)",
            "\tvar explosiveness := base_explosiveness",
            "\tvar flammability := 0.0",
            "\tvar power := 0.0",
            "\tif has_items:",
            "\t\tfor item_state in item_states:",
            "\t\t\tvar item_amount: int = min(int(item_state.get(\"amount\", 0)), item_cap)",
            "\t\t\texplosiveness += float(item_state.get(\"explosiveness\", 0.0)) * float(item_amount)",
            "\t\t\tflammability += float(item_state.get(\"flammability\", 0.0)) * float(item_amount)",
            "\t\t\tpower += float(item_state.get(\"charge\", 0.0)) * pow(float(item_amount), 1.1) * 150.0",
            "\tvar has_liquids := bool(_args[4] if _args.size() > 4 else false)",
            "\tvar liquid_states: Array = _args[5] if _args.size() > 5 and _args[5] is Array else []",
            "\tif has_liquids:",
            "\t\tfor liquid_state in liquid_states:",
            "\t\t\tflammability += float(liquid_state.get(\"flammability\", 0.0)) * float(liquid_state.get(\"amount\", 0.0)) / 2.0",
            "\t\t\texplosiveness += float(liquid_state.get(\"explosiveness\", 0.0)) * float(liquid_state.get(\"amount\", 0.0)) / 2.0",
            "\tvar current_power := power",
            "\tvar has_cons_power := bool(_args[6] if _args.size() > 6 else false)",
            "\tvar cons_power_buffered := bool(_args[7] if _args.size() > 7 else false)",
            "\tvar power_status := float(_args[8] if _args.size() > 8 else 0.0)",
            "\tvar cons_power_capacity := float(_args[9] if _args.size() > 9 else 0.0)",
            "\tvar apply_buffered_power := has_cons_power and cons_power_buffered",
            "\tvar buffered_power_contribution := power_status * cons_power_capacity if apply_buffered_power else 0.0",
            "\tpower = current_power + buffered_power_contribution",
            "\tvar damage_explosions := bool(_args[10] if _args.size() > 10 else false)",
            "\tvar splash_liquids := has_liquids and damage_explosions",
            "\tvar splash_call := \"liquids.each(this::splashLiquid);\" if splash_liquids else \"\"",
            "\tvar liquid_count := liquid_states.size() if splash_liquids else 0",
            "\tvar liquids: Array = liquid_states.duplicate() if splash_liquids else []",
            "\tvar source_x := float(_args[11] if _args.size() > 11 else 0.0)",
            "\tvar source_y := float(_args[12] if _args.size() > 12 else 0.0)",
            "\tvar flammability_scale := float(_args[13] if _args.size() > 13 else 1.0)",
            "\tvar explosiveness_scale := float(_args[14] if _args.size() > 14 else 1.0)",
            "\tvar source_tilesize := float(_args[15] if _args.size() > 15 else 0.0)",
            "\tvar source_block_size := int(_args[16] if _args.size() > 16 else 0)",
            "\tvar destroy_effect := str(_args[17] if _args.size() > 17 else \"\")",
            "\tvar base_shake := float(_args[18] if _args.size() > 18 else 0.0)",
            "\tvar dynamic_explosion_flammability := flammability * flammability_scale",
            "\tvar dynamic_explosion_explosiveness := explosiveness * 3.5 * explosiveness_scale",
            "\tvar dynamic_explosion_radius := source_tilesize * float(source_block_size) / 2.0",
            "\tvar create_rubble := bool(_args[19] if _args.size() > 19 else false)",
            "\tvar floor_solid := bool(_args[20] if _args.size() > 20 else false)",
            "\tvar floor_is_liquid := bool(_args[21] if _args.size() > 21 else false)",
            "\tvar should_create_rubble := create_rubble and not floor_solid and not floor_is_liquid",
            "\tvar rubble_call := \"Effect.rubble(x, y, block.size);\" if should_create_rubble else \"\"",
            "\tvar headless := bool(_args[22] if _args.size() > 22 else false)",
            "\tvar destroy_sound := str(_args[23] if _args.size() > 23 else \"\")",
            "\tvar destroy_pitch_min := float(_args[24] if _args.size() > 24 else 0.0)",
            "\tvar destroy_pitch_max := float(_args[25] if _args.size() > 25 else 0.0)",
            "\tvar destroy_sound_volume := float(_args[26] if _args.size() > 26 else 0.0)",
            "\tvar play_destroy_sound := not headless",
            "\tvar base_destroy_sound := destroy_sound if play_destroy_sound else \"\"",
            "\tvar play_reactive_sound := not headless and (explosiveness > 40.0 or flammability > 5.0)",
            "\tvar reactive_sound_kind := \"explosive\" if not headless and explosiveness > 40.0 else \"flammable\" if not headless and flammability > 5.0 else \"\"",
            "\tvar reactive_sound := \"blockExplodeFlammable\" if reactive_sound_kind == \"flammable\" else \"\"",
            "\tvar reactive_sound_choices := [\"blockExplodeExplosive\", \"blockExplodeExplosiveAlt\"] if reactive_sound_kind == \"explosive\" else []",
            "\tvar reactive_chance := 0.5 if reactive_sound_kind == \"explosive\" else 0.0",
            "\tvar play_power_sound := not headless and power > 2000.0",
            "\tvar power_sound_kind := \"big\" if not headless and power > 30000.0 else \"normal\" if not headless and power > 2000.0 else \"\"",
            "\tvar power_sound := \"blockExplodeElectricBig\" if power_sound_kind == \"big\" else \"blockExplodeElectric\" if power_sound_kind == \"normal\" else \"\"",
            "\treturn {\"source_owner\": \"PortGame.source_building_on_destroyed_item_explosion_state\", \"liquid_source_owner\": \"PortGame.source_building_on_destroyed_liquid_explosion_state\", \"buffered_power_source_owner\": \"PortGame.source_building_on_destroyed_buffered_power_state\", \"splash_liquid_source_owner\": \"PortGame.source_building_on_destroyed_splash_liquid_state\", \"dynamic_explosion_source_owner\": \"PortGame.source_building_on_destroyed_dynamic_explosion_call_state\", \"rubble_source_owner\": \"PortGame.source_building_on_destroyed_rubble_state\", \"base_sound_source_owner\": \"PortGame.source_building_on_destroyed_base_sound_state\", \"reactive_sound_source_owner\": \"PortGame.source_building_on_destroyed_reactive_sound_state\", \"power_sound_source_owner\": \"PortGame.source_building_on_destroyed_power_sound_state\", \"comment\": \"Called when the block is destroyed. The tile is still intact at this stage.\", \"method\": \"public void onDestroyed(){\", \"dynamic_explosion_comment\": \"//cap explosiveness so fluid tanks/vaults don't instakill units\", \"dynamic_explosion_call\": \"Damage.dynamicExplosion(x, y, flammability * block.flammabilityScale, explosiveness * 3.5f * block.explosivenessScale, power, tilesize * block.size / 2f, state.rules.damageExplosions, block.destroyEffect, block.baseShake);\", \"rubble_gate\": \"if(block.createRubble && !floor().solid && !floor().isLiquid){\", \"rubble_effect_call\": \"Effect.rubble(x, y, block.size);\", \"base_sound_gate\": \"if(!headless){\", \"base_sound_call\": \"playDestroySound();\", \"play_destroy_sound_call\": \"block.destroySound.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);\", \"reactive_explosive_gate\": \"if(explosiveness > 40f){\", \"reactive_explosive_sound_call\": \"(Mathf.chance(0.5) ? Sounds.blockExplodeExplosive : Sounds.blockExplodeExplosiveAlt).at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);\", \"reactive_flammable_gate\": \"}else if(flammability > 5f){\", \"reactive_flammable_sound_call\": \"Sounds.blockExplodeFlammable.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);\", \"power_sound_big_gate\": \"if(power > 30000f){\", \"power_sound_big_call\": \"Sounds.blockExplodeElectricBig.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);\", \"power_sound_normal_gate\": \"}else if(power > 2000f){\", \"power_sound_normal_call\": \"Sounds.blockExplodeElectric.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);\", \"base_explosiveness_expr\": \"float explosiveness = block.baseExplosiveness;\", \"flammability_expr\": \"float flammability = 0f;\", \"power_expr\": \"float power = 0f;\", \"has_items_gate\": \"if(block.hasItems){\", \"items_loop\": \"for(Item item : content.items()){\", \"amount_expr\": \"int amount = Math.min(items.get(item), explosionItemCap());\", \"explosiveness_add\": \"explosiveness += item.explosiveness * amount;\", \"flammability_add\": \"flammability += item.flammability * amount;\", \"power_add\": \"power += item.charge * Mathf.pow(amount, 1.1f) * 150f;\", \"has_liquids_gate\": \"if(block.hasLiquids){\", \"liquid_flammability_add\": \"flammability += liquids.sum((liquid, amount) -> liquid.flammability * amount / 2f);\", \"liquid_explosiveness_add\": \"explosiveness += liquids.sum((liquid, amount) -> liquid.explosiveness * amount / 2f);\", \"buffered_power_guard\": \"if(block.consPower != null && block.consPower.buffered){\", \"buffered_power_add\": \"power += this.power.status * block.consPower.capacity;\", \"splash_liquid_gate\": \"if(block.hasLiquids && state.rules.damageExplosions){\", \"splash_liquid_call\": \"liquids.each(this::splashLiquid);\", \"base_explosiveness\": base_explosiveness, \"has_items\": has_items, \"item_cap\": item_cap, \"has_liquids\": has_liquids, \"damage_explosions\": damage_explosions, \"splash_liquids\": splash_liquids, \"call\": splash_call, \"liquid_count\": liquid_count, \"liquids\": liquids, \"headless\": headless, \"destroy_sound\": destroy_sound, \"destroy_pitch_min\": destroy_pitch_min, \"destroy_pitch_max\": destroy_pitch_max, \"destroy_sound_volume\": destroy_sound_volume, \"play_destroy_sound\": play_destroy_sound, \"sound\": base_destroy_sound, \"pitch_min\": destroy_pitch_min, \"pitch_max\": destroy_pitch_max, \"volume\": destroy_sound_volume, \"play_reactive_sound\": play_reactive_sound, \"reactive_sound_kind\": reactive_sound_kind, \"reactive_sound\": reactive_sound, \"reactive_sound_choices\": reactive_sound_choices, \"reactive_chance\": reactive_chance, \"play_power_sound\": play_power_sound, \"power_sound_kind\": power_sound_kind, \"power_sound\": power_sound, \"dynamic_explosion_x\": source_x, \"dynamic_explosion_y\": source_y, \"dynamic_explosion_flammability\": dynamic_explosion_flammability, \"dynamic_explosion_explosiveness\": dynamic_explosion_explosiveness, \"dynamic_explosion_power\": power, \"dynamic_explosion_radius\": dynamic_explosion_radius, \"dynamic_explosion_damage_explosions\": damage_explosions, \"dynamic_explosion_effect\": destroy_effect, \"dynamic_explosion_shake\": base_shake, \"rubble_create_rubble\": should_create_rubble, \"rubble_call\": rubble_call, \"rubble_x\": source_x, \"rubble_y\": source_y, \"rubble_size\": source_block_size if should_create_rubble else 0, \"current_power\": current_power, \"has_cons_power\": has_cons_power, \"cons_power_buffered\": cons_power_buffered, \"power_status\": power_status, \"cons_power_capacity\": cons_power_capacity, \"apply_buffered_power\": apply_buffered_power, \"buffered_power_contribution\": buffered_power_contribution, \"explosiveness\": explosiveness, \"flammability\": flammability, \"power\": power}",
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
        "const SOURCE_FLOAT_ROUNDING_ERROR := 0.000001",
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
