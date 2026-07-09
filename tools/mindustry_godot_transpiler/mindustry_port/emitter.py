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
        java_file.get("path") == "mindustry/entities/abilities/Ability.java"
        and type_entry.get("name") == "Ability"
        and method.get("name") == "update"
    ):
        return [
            "\tvar unit: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"source_owner\": \"PortGame.source_ability_update_state\", \"source\": \"core/src/mindustry/entities/abilities/Ability.java\", \"method\": \"public void update(Unit unit){}\", \"unit\": unit, \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/abilities/Ability.java"
        and type_entry.get("name") == "Ability"
        and method.get("name") == "draw"
    ):
        return [
            "\tvar unit: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"source_owner\": \"PortGame.source_ability_draw_state\", \"source\": \"core/src/mindustry/entities/abilities/Ability.java\", \"method\": \"public void draw(Unit unit){}\", \"unit\": unit, \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/abilities/Ability.java"
        and type_entry.get("name") == "Ability"
        and method.get("name") == "death"
    ):
        return [
            "\tvar unit: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"source_owner\": \"PortGame.source_ability_death_state\", \"source\": \"core/src/mindustry/entities/abilities/Ability.java\", \"method\": \"public void death(Unit unit){}\", \"unit\": unit, \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/abilities/Ability.java"
        and type_entry.get("name") == "Ability"
        and method.get("name") == "created"
    ):
        return [
            "\tvar unit: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"source_owner\": \"PortGame.source_ability_created_state\", \"source\": \"core/src/mindustry/entities/abilities/Ability.java\", \"method\": \"public void created(Unit unit){}\", \"unit\": unit, \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/abilities/Ability.java"
        and type_entry.get("name") == "Ability"
        and method.get("name") == "init"
    ):
        return [
            "\tvar type_value: Variant = _args[0] if _args.size() > 0 else null",
            "\treturn {\"source_owner\": \"PortGame.source_ability_init_state\", \"source\": \"core/src/mindustry/entities/abilities/Ability.java\", \"method\": \"public void init(UnitType type){}\", \"type\": type_value, \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/abilities/Ability.java"
        and type_entry.get("name") == "Ability"
        and method.get("name") == "displayBars"
    ):
        return [
            "\tvar unit: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar bars: Variant = _args[1] if _args.size() > 1 else null",
            "\treturn {\"source_owner\": \"PortGame.source_ability_display_bars_state\", \"source\": \"core/src/mindustry/entities/abilities/Ability.java\", \"method\": \"public void displayBars(Unit unit, Table bars){}\", \"unit\": unit, \"bars\": bars, \"no_op\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/entities/abilities/Ability.java"
        and type_entry.get("name") == "Ability"
        and method.get("name") == "display"
    ):
        return [
            "\tvar table_state: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar localized_value: String = str(_args[1] if _args.size() > 1 else \"\")",
            '\treturn {"source_owner": "PortGame.source_ability_display_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "method": "public void display(Table t){", "table": table_state, "style_expr": "Styles.grayPanel", "table_call": "t.table(Styles.grayPanel, a -> {", "localized_call": "localized()", "title_expr": "\\"[accent]\\" + localized()", "localized_value": localized_value, "title_text": "[accent]" + localized_value, "add_call": "a.add(\\"[accent]\\" + localized()).padBottom(4).center().top().expandX();", "row_call": "a.row();", "defaults_call": "a.left().top().defaults().left();", "add_stats_call": "addStats(a);", "outer_chain": "}).pad(5).margin(10).growX().top().uniformX();", "table_mutation": true}',
        ]
    if (
        java_file.get("path") == "mindustry/entities/abilities/Ability.java"
        and type_entry.get("name") == "Ability"
        and method.get("name") == "addStats"
    ):
        return [
            "\tvar table_state: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar get_bundle_value: String = str(_args[1] if _args.size() > 1 else \"\")",
            "\tvar bundle_has_description: bool = bool(_args[2] if _args.size() > 2 else false)",
            "\tvar bundle_description: String = str(_args[3] if _args.size() > 3 else \"\")",
            "\tvar description_key: String = get_bundle_value + \".description\"",
            "\tvar add_description_call: Variant = null",
            "\tvar row_call: Variant = null",
            "\tif bundle_has_description:",
            '\t\tadd_description_call = {"call": "t.add(Core.bundle.get(getBundle() + \\".description\\")).wrap().width(descriptionWidth);", "description": bundle_description, "width": 350.0}',
            '\t\trow_call = "t.row();"',
            '\treturn {"source_owner": "PortGame.source_ability_add_stats_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "method": "public void addStats(Table t){", "table": table_state, "field_expr": "protected static final float descriptionWidth = 350f;", "description_width": 350.0, "get_bundle_call": "getBundle()", "get_bundle_value": get_bundle_value, "description_key_expr": "getBundle() + \\".description\\"", "description_key": description_key, "guard_expr": "if(Core.bundle.has(getBundle() + \\".description\\")){", "guard_passed": bundle_has_description, "bundle_description": bundle_description, "add_description_call": add_description_call, "row_call": row_call}',
        ]
    if (
        java_file.get("path") == "mindustry/entities/abilities/Ability.java"
        and type_entry.get("name") == "Ability"
        and method.get("name") == "abilityStat"
    ):
        return [
            "\tvar stat_value: String = str(_args[0] if _args.size() > 0 else \"\")",
            "\tvar values: Array = []",
            "\tif _args.size() > 1 and _args[1] is Array:",
            "\t\tvalues = _args[1]",
            "\tvar formatted_value: String = str(_args[2] if _args.size() > 2 else \"\")",
            '\tvar bundle_key: String = "ability.stat." + stat_value',
            '\treturn {"source_owner": "PortGame.source_ability_ability_stat_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "method": "public String abilityStat(String stat, Object... values){", "stat": stat_value, "values": values, "bundle_key_expr": "\\"ability.stat.\\" + stat", "bundle_key": bundle_key, "format_call": "Core.bundle.format(\\"ability.stat.\\" + stat, values)", "formatted_value": formatted_value, "return_expr": "return Core.bundle.format(\\"ability.stat.\\" + stat, values);", "return_value": formatted_value}',
        ]
    if (
        java_file.get("path") == "mindustry/entities/abilities/Ability.java"
        and type_entry.get("name") == "Ability"
        and method.get("name") == "copy"
    ):
        return [
            "\tvar clone_supported: bool = bool(_args[0] if _args.size() > 0 else true)",
            "\tvar clone_value: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar exception_value: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar return_value: Variant = clone_value if clone_supported else null",
            "\tvar thrown_exception: Variant = null",
            "\tif not clone_supported:",
            '\t\tthrown_exception = {"type": "RuntimeException", "message": "java sucks", "cause": exception_value}',
            '\treturn {"source_owner": "PortGame.source_ability_copy_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "method": "public Ability copy(){", "try_expr": "try{", "clone_return_expr": "return (Ability)clone();", "clone_supported": clone_supported, "clone_value": clone_value, "catch_expr": "}catch(CloneNotSupportedException e){", "comment_expr": "//I am disgusted", "runtime_exception_expr": "throw new RuntimeException(\\"java sucks\\", e);", "exception_value": exception_value, "return_value": return_value, "thrown_exception": thrown_exception}',
        ]
    if (
        java_file.get("path") == "mindustry/entities/abilities/Ability.java"
        and type_entry.get("name") == "Ability"
        and method.get("name") == "localized"
    ):
        return [
            "\tvar get_bundle_value: String = str(_args[0] if _args.size() > 0 else \"\")",
            "\tvar bundle_value: String = str(_args[1] if _args.size() > 1 else \"\")",
            '\treturn {"source_owner": "PortGame.source_ability_localized_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "comment": "/** @return localized ability name; mods should override this. */", "method": "public String localized(){", "get_bundle_call": "getBundle()", "get_bundle_value": get_bundle_value, "bundle_get_call": "Core.bundle.get(getBundle())", "return_expr": "return Core.bundle.get(getBundle());", "return_value": bundle_value}',
        ]
    if (
        java_file.get("path") == "mindustry/entities/abilities/Ability.java"
        and type_entry.get("name") == "Ability"
        and method.get("name") == "getBundle"
    ):
        return [
            "\tvar class_simple_name: String = str(_args[0] if _args.size() > 0 else \"\")",
            "\tvar is_anonymous_class: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar superclass_simple_name: String = str(_args[2] if _args.size() > 2 else \"\")",
            "\tvar selected_simple_name: String = superclass_simple_name if is_anonymous_class else class_simple_name",
            "\tvar stripped_name: String = selected_simple_name.replace(\"Ability\", \"\")",
            "\tvar return_value: String = \"ability.\" + stripped_name.to_lower()",
            '\treturn {"source_owner": "PortGame.source_ability_get_bundle_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "method": "public String getBundle(){", "type_assignment": "var type = getClass();", "class_simple_name": class_simple_name, "is_anonymous_class": is_anonymous_class, "superclass_simple_name": superclass_simple_name, "selected_expr": "(type.isAnonymousClass() ? type.getSuperclass() : type)", "selected_simple_name": selected_simple_name, "replace_expr": "getSimpleName().replace(\\"Ability\\", \\"\\")", "stripped_name": stripped_name, "lower_expr": "toLowerCase()", "return_expr": "return \\"ability.\\" + (type.isAnonymousClass() ? type.getSuperclass() : type).getSimpleName().replace(\\"Ability\\", \\"\\").toLowerCase();", "return_value": return_value}',
        ]
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
        java_file.get("path") == "mindustry/world/consumers/ConsumePower.java"
        and type_entry.get("name") == "ConsumePower"
        and method.get("name") == "ignore"
    ):
        return [
            "\tvar buffered: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar ignore_consume: bool = buffered",
            '\treturn {"source_owner": "PortGame.source_consume_power_ignore_state", "source": "core/src/mindustry/world/consumers/ConsumePower.java", "method": "public boolean ignore(){", "buffered": buffered, "ignore": ignore_consume, "return_expr": "return buffered;"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumePower.java"
        and type_entry.get("name") == "ConsumePower"
        and method.get("name") == "efficiency"
    ):
        return [
            "\tvar power_status: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar efficiency: float = power_status",
            '\treturn {"source_owner": "PortGame.source_consume_power_efficiency_state", "source": "core/src/mindustry/world/consumers/ConsumePower.java", "method": "public float efficiency(Building build){", "power_status": power_status, "efficiency": efficiency, "return_expr": "return build.power.status;"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumePower.java"
        and type_entry.get("name") == "ConsumePower"
        and method.get("name") == "display"
    ):
        return [
            "\tvar buffered: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar usage: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar capacity: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar buffered_guard: bool = buffered",
            "\tvar usage_guard: bool = usage > 0.0",
            "\tvar power_use_value: float = usage * 60.0",
            "\tvar stats_add_call: Dictionary = {}",
            "\tif buffered_guard:",
            '\t\tstats_add_call = {"call": "stats.add(Stat.powerCapacity, capacity, StatUnit.none);", "stat": "Stat.powerCapacity", "value": capacity, "unit": "StatUnit.none"}',
            "\telif usage_guard:",
            '\t\tstats_add_call = {"call": "stats.add(Stat.powerUse, usage * 60f, StatUnit.powerSecond);", "stat": "Stat.powerUse", "value": power_use_value, "unit": "StatUnit.powerSecond"}',
            '\treturn {"source_owner": "PortGame.source_consume_power_display_state", "source": "core/src/mindustry/world/consumers/ConsumePower.java", "method": "public void display(Stats stats){", "buffered": buffered, "usage": usage, "capacity": capacity, "buffered_guard": buffered_guard, "usage_guard": usage_guard, "stats_add_called": not stats_add_call.is_empty(), "power_use_value": power_use_value, "stats_add_call": stats_add_call, "buffered_guard_expr": "if(buffered){", "usage_guard_expr": "}else if(usage > 0f){", "capacity_stats_add_expr": "stats.add(Stat.powerCapacity, capacity, StatUnit.none);", "usage_stats_add_expr": "stats.add(Stat.powerUse, usage * 60f, StatUnit.powerSecond);"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumePower.java"
        and type_entry.get("name") == "ConsumePower"
        and method.get("name") == "requestedPower"
    ):
        return [
            "\tvar buffered: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar usage: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar capacity: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar power_status: float = float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar should_consume: bool = bool(_args[4] if _args.size() > 4 else false)",
            "\tvar requested_power: float = (1.0 - power_status) * capacity if buffered else usage * (1.0 if should_consume else 0.0)",
            '\treturn {"source_owner": "PortGame.source_consume_power_requested_power_state", "source": "core/src/mindustry/world/consumers/ConsumePower.java", "method": "public float requestedPower(Building entity){", "buffered": buffered, "usage": usage, "capacity": capacity, "power_status": power_status, "should_consume": should_consume, "requested_power": requested_power, "buffered_expr": "(1f - entity.power.status) * capacity", "unbuffered_expr": "usage * (entity.shouldConsume() ? 1f : 0f)"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumePowerCondition.java"
        and type_entry.get("name") == "ConsumePowerCondition"
        and method.get("name") == "requestedPower"
    ):
        return [
            "\tvar usage: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar consume_get: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar requested_power: float = usage if consume_get else 0.0",
            '\treturn {"source_owner": "PortGame.source_consume_power_condition_requested_power_state", "source": "core/src/mindustry/world/consumers/ConsumePowerCondition.java", "method": "public float requestedPower(Building entity){", "usage": usage, "consume_get": consume_get, "requested_power": requested_power, "return_expr": "return consume.get(entity) ? usage : 0f;"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumePowerDynamic.java"
        and type_entry.get("name") == "ConsumePowerDynamic"
        and method.get("name") == "requestedPower"
    ):
        return [
            "\tvar usage_get: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar requested_power: float = usage_get",
            '\treturn {"source_owner": "PortGame.source_consume_power_dynamic_requested_power_state", "source": "core/src/mindustry/world/consumers/ConsumePowerDynamic.java", "method": "public float requestedPower(Building entity){", "usage_get": usage_get, "requested_power": requested_power, "return_expr": "return usage.get(entity);"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumePowerDynamic.java"
        and type_entry.get("name") == "ConsumePowerDynamic"
        and method.get("name") == "display"
    ):
        return [
            "\tvar displayed_power_usage: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar display_guard: bool = displayed_power_usage != 0.0",
            "\tvar power_use_value: float = displayed_power_usage * 60.0",
            "\tvar stats_add_call: Dictionary = {}",
            "\tif display_guard:",
            '\t\tstats_add_call = {"call": "stats.add(Stat.powerUse, displayedPowerUsage * 60f, StatUnit.powerSecond);", "stat": "Stat.powerUse", "value": power_use_value, "unit": "StatUnit.powerSecond"}',
            '\treturn {"source_owner": "PortGame.source_consume_power_dynamic_display_state", "source": "core/src/mindustry/world/consumers/ConsumePowerDynamic.java", "method": "public void display(Stats stats){", "displayed_power_usage": displayed_power_usage, "display_guard": display_guard, "stats_add_called": display_guard, "power_use_value": power_use_value, "stats_add_call": stats_add_call, "guard_expr": "if(displayedPowerUsage != 0f){", "stats_add_expr": "stats.add(Stat.powerUse, displayedPowerUsage * 60f, StatUnit.powerSecond);"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemFlammable.java"
        and type_entry.get("name") == "ConsumeItemFlammable"
        and method.get("name") == "itemEfficiencyMultiplier"
    ):
        return [
            "\tvar item_flammability: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar efficiency_multiplier: float = item_flammability",
            '\treturn {"source_owner": "PortGame.source_consume_item_flammable_item_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFlammable.java", "method": "public float itemEfficiencyMultiplier(Item item){", "item_flammability": item_flammability, "efficiency_multiplier": efficiency_multiplier, "return_expr": "return item.flammability;"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemExplosive.java"
        and type_entry.get("name") == "ConsumeItemExplosive"
        and method.get("name") == "itemEfficiencyMultiplier"
    ):
        return [
            "\tvar item_explosiveness: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar efficiency_multiplier: float = item_explosiveness",
            '\treturn {"source_owner": "PortGame.source_consume_item_explosive_item_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeItemExplosive.java", "method": "public float itemEfficiencyMultiplier(Item item){", "item_explosiveness": item_explosiveness, "efficiency_multiplier": efficiency_multiplier, "return_expr": "return item.explosiveness;"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemRadioactive.java"
        and type_entry.get("name") == "ConsumeItemRadioactive"
        and method.get("name") == "itemEfficiencyMultiplier"
    ):
        return [
            "\tvar item_radioactivity: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar efficiency_multiplier: float = item_radioactivity",
            '\treturn {"source_owner": "PortGame.source_consume_item_radioactive_item_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeItemRadioactive.java", "method": "public float itemEfficiencyMultiplier(Item item){", "item_radioactivity": item_radioactivity, "efficiency_multiplier": efficiency_multiplier, "return_expr": "return item.radioactivity;"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemCharged.java"
        and type_entry.get("name") == "ConsumeItemCharged"
        and method.get("name") == "itemEfficiencyMultiplier"
    ):
        return [
            "\tvar item_charge: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar efficiency_multiplier: float = item_charge",
            '\treturn {"source_owner": "PortGame.source_consume_item_charged_item_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeItemCharged.java", "method": "public float itemEfficiencyMultiplier(Item item){", "item_charge": item_charge, "efficiency_multiplier": efficiency_multiplier, "return_expr": "return item.charge;"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemFilter.java"
        and type_entry.get("name") == "ConsumeItemFilter"
        and method.get("name") == "apply"
    ):
        return [
            "\tvar block_has_items_before: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar block_accepts_items_before: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar item_filter_before: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []",
            "\tvar filtered_item_ids: Array = (_args[3] as Array).duplicate() if _args.size() > 3 and _args[3] is Array else []",
            "\tvar item_filter_after: Array = item_filter_before.duplicate()",
            "\tfor item_id in filtered_item_ids:",
            "\t\titem_filter_after[int(item_id)] = true",
            "\tvar block_has_items_after: bool = true",
            "\tvar block_accepts_items_after: bool = true",
            '\treturn {"source_owner": "PortGame.source_consume_item_filter_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public void apply(Block block){", "has_items_assignment_expr": "block.hasItems = true;", "accepts_items_assignment_expr": "block.acceptsItems = true;", "each_expr": "content.items().each(filter, item -> block.itemFilter[item.id] = true);", "item_filter_assignment_expr": "block.itemFilter[item.id] = true;", "block_has_items_before": block_has_items_before, "block_accepts_items_before": block_accepts_items_before, "item_filter_before": item_filter_before, "filtered_item_ids": filtered_item_ids, "block_has_items_after": block_has_items_after, "block_accepts_items_after": block_accepts_items_after, "item_filter_after": item_filter_after}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItems.java"
        and type_entry.get("name") == "ConsumeItems"
        and method.get("name") == "apply"
    ):
        return [
            "\tvar block_has_items_before: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar block_accepts_items_before: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar item_filter_before: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []",
            "\tvar item_stacks: Array = (_args[3] as Array).duplicate(true) if _args.size() > 3 and _args[3] is Array else []",
            "\tvar item_filter_after: Array = item_filter_before.duplicate()",
            "\tfor stack in item_stacks:",
            "\t\tif not stack is Dictionary:",
            "\t\t\tcontinue",
            '\t\tvar item_id := int(stack.get("item_id", -1))',
            "\t\titem_filter_after[item_id] = true",
            "\tvar block_has_items_after: bool = true",
            "\tvar block_accepts_items_after: bool = true",
            '\treturn {"source_owner": "PortGame.source_consume_items_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeItems.java", "method": "public void apply(Block block){", "items_field": "public final ItemStack[] items;", "has_items_assignment_expr": "block.hasItems = true;", "accepts_items_assignment_expr": "block.acceptsItems = true;", "items_loop_expr": "for(var stack : items){", "item_filter_assignment_expr": "block.itemFilter[stack.item.id] = true;", "block_has_items_field": "public @NoPatch boolean hasItems;", "block_accepts_items_field": "public boolean acceptsItems = false;", "block_item_filter_field": "public boolean[] itemFilter = {}, liquidFilter = {};", "block_has_items_before": block_has_items_before, "block_accepts_items_before": block_accepts_items_before, "item_filter_before": item_filter_before, "item_stacks": item_stacks, "block_has_items_after": block_has_items_after, "block_accepts_items_after": block_accepts_items_after, "item_filter_after": item_filter_after}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItems.java"
        and type_entry.get("name") == "ConsumeItems"
        and method.get("name") == "build"
    ):
        return [
            "\tvar item_stacks: Array = (_args[0] as Array).duplicate(true) if _args.size() > 0 and _args[0] is Array else []",
            "\tvar item_amounts: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []",
            "\tvar multiplier_get_build: float = float(_args[2] if _args.size() > 2 else 1.0)",
            "\tvar req_images: Array = []",
            "\tvar row_calls: Array = []",
            "\tfor index in item_stacks.size():",
            "\t\tvar stack: Variant = item_stacks[index]",
            "\t\tif not stack is Dictionary:",
            "\t\t\tcontinue",
            '\t\tvar item_id: int = int(stack.get("item_id", -1))',
            '\t\tvar stack_amount: float = float(stack.get("amount", 0.0))',
            "\t\tvar required_amount: int = int(floor(stack_amount * multiplier_get_build + 0.5))",
            "\t\tvar item_amount: float = 0.0",
            "\t\tif item_id < item_amounts.size():",
            "\t\t\titem_amount = float(item_amounts[item_id])",
            "\t\tvar valid: bool = item_id < item_amounts.size() and item_amount >= required_amount",
            '\t\treq_images.append({"item_id": item_id, "stack_amount": stack_amount, "required_amount": required_amount, "item_amount": item_amount, "valid": valid, "stat_values_stack_expr": "StatValues.stack(stack.item, Math.round(stack.amount * multiplier.get(build)))", "pad_right": 8.0})',
            "\t\tif (index + 1) % 4 == 0:",
            '\t\t\trow_calls.append({"call": "c.row();", "after_count": index + 1})',
            "\tvar table_cell_left: bool = true",
            '\treturn {"source_owner": "PortGame.source_consume_items_build_state", "source": "core/src/mindustry/world/consumers/ConsumeItems.java", "method": "public void build(Building build, Table table){", "items_field": "public final ItemStack[] items;", "table_expr": "table.table(c -> {", "i_initial_expr": "int i = 0;", "loop_expr": "for(var stack : items){", "add_expr": "c.add(new ReqImage(StatValues.stack(stack.item, Math.round(stack.amount * multiplier.get(build))),", "stat_values_stack_expr": "StatValues.stack(stack.item, Math.round(stack.amount * multiplier.get(build)))", "valid_expr": "() -> build.items.has(stack.item, Math.round(stack.amount * multiplier.get(build))))).padRight(8);", "row_expr": "if(++i % 4 == 0) c.row();", "table_left_expr": "}).left();", "multiplier_field": "public Floatf<Building> multiplier = b -> 1f;", "item_stack_item_field": "public Item item;", "item_stack_amount_field": "public int amount = 0;", "building_items_field": "@Nullable ItemModule items;", "item_module_has_expr": "public boolean has(Item item, int amount){", "item_module_has_return_expr": "return get(item) >= amount;", "req_image_constructor": "public ReqImage(Element image, Boolp valid){", "req_image_valid_expr": "public boolean valid(){", "stat_values_stack_method": "public static Stack stack(UnlockableContent item, int amount){", "cell_pad_right_expr": "public Cell<T> padRight(float padRight){", "cell_left_expr": "public Cell<T> left(){", "item_stacks": item_stacks, "item_amounts": item_amounts, "multiplier_get_build": multiplier_get_build, "req_images": req_images, "row_calls": row_calls, "table_cell_left": table_cell_left}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItems.java"
        and type_entry.get("name") == "ConsumeItems"
        and method.get("name") == "trigger"
    ):
        return [
            "\tvar item_stacks: Array = (_args[0] as Array).duplicate(true) if _args.size() > 0 and _args[0] is Array else []",
            "\tvar multiplier_get_build: float = float(_args[1] if _args.size() > 1 else 1.0)",
            "\tvar remove_calls: Array = []",
            "\tfor stack in item_stacks:",
            "\t\tif not stack is Dictionary:",
            "\t\t\tcontinue",
            '\t\tvar item_id: int = int(stack.get("item_id", -1))',
            '\t\tvar stack_amount: float = float(stack.get("amount", 0.0))',
            "\t\tvar remove_amount: int = int(floor(stack_amount * multiplier_get_build + 0.5))",
            '\t\tremove_calls.append({"call": "build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));", "item_id": item_id, "stack_amount": stack_amount, "amount": remove_amount})',
            '\treturn {"source_owner": "PortGame.source_consume_items_trigger_state", "source": "core/src/mindustry/world/consumers/ConsumeItems.java", "method": "public void trigger(Building build){", "items_field": "public final ItemStack[] items;", "items_loop_expr": "for(var stack : items){", "remove_expr": "build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));", "round_expr": "Math.round(stack.amount * multiplier.get(build))", "multiplier_field": "public Floatf<Building> multiplier = b -> 1f;", "item_stack_item_field": "public Item item;", "item_stack_amount_field": "public int amount = 0;", "building_items_field": "@Nullable ItemModule items;", "item_module_remove_method": "public void remove(Item item, int amount){", "item_module_remove_clamp": "amount = Math.min(amount, items[item.id]);", "item_stacks": item_stacks, "multiplier_get_build": multiplier_get_build, "remove_calls": remove_calls}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItems.java"
        and type_entry.get("name") == "ConsumeItems"
        and method.get("name") == "efficiency"
    ):
        return [
            "\tvar consume_trigger_valid: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar item_stacks: Array = (_args[1] as Array).duplicate(true) if _args.size() > 1 and _args[1] is Array else []",
            "\tvar item_amounts: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []",
            "\tvar multiplier_get_build: float = float(_args[3] if _args.size() > 3 else 1.0)",
            "\tvar item_module_has_stacks: bool = true",
            "\tvar stack_checks: Array = []",
            "\tfor stack in item_stacks:",
            "\t\tif not stack is Dictionary:",
            "\t\t\tcontinue",
            '\t\tvar item_id: int = int(stack.get("item_id", -1))',
            '\t\tvar stack_amount: float = float(stack.get("amount", 0.0))',
            "\t\tvar required_amount: int = int(floor(stack_amount * multiplier_get_build + 0.5))",
            "\t\tvar item_amount: float = 0.0",
            "\t\tif item_id < item_amounts.size():",
            "\t\t\titem_amount = float(item_amounts[item_id])",
            "\t\tvar has_stack: bool = item_id < item_amounts.size() and item_amount >= required_amount",
            '\t\tstack_checks.append({"item_id": item_id, "stack_amount": stack_amount, "required_amount": required_amount, "item_amount": item_amount, "has_stack": has_stack})',
            "\t\tif item_id >= item_amounts.size() or float(item_amounts[item_id]) < required_amount:",
            "\t\t\titem_module_has_stacks = false",
            "\t\t\tbreak",
            "\tvar efficiency_value: float = 1.0 if consume_trigger_valid or item_module_has_stacks else 0.0",
            '\treturn {"source_owner": "PortGame.source_consume_items_efficiency_state", "source": "core/src/mindustry/world/consumers/ConsumeItems.java", "method": "public float efficiency(Building build){", "items_field": "public final ItemStack[] items;", "return_expr": "return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;", "consume_trigger_valid_expr": "build.consumeTriggerValid()", "item_module_has_stacks_expr": "public boolean has(ItemStack[] stacks, float multiplier){", "item_module_has_stack_guard_expr": "if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;", "item_module_has_stacks_return_expr": "return true;", "item_module_has_item_amount_expr": "public boolean has(Item item, int amount){", "item_module_has_item_amount_return_expr": "return get(item) >= amount;", "multiplier_field": "public Floatf<Building> multiplier = b -> 1f;", "item_stack_item_field": "public Item item;", "item_stack_amount_field": "public int amount = 0;", "consume_trigger_valid": consume_trigger_valid, "item_stacks": item_stacks, "item_amounts": item_amounts, "multiplier_get_build": multiplier_get_build, "item_module_has_stacks": item_module_has_stacks, "stack_checks": stack_checks, "efficiency": efficiency_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItems.java"
        and type_entry.get("name") == "ConsumeItems"
        and method.get("name") == "display"
    ):
        return [
            "\tvar booster: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar stats_time_period: float = float(_args[1] if _args.size() > 1 else -1.0)",
            "\tvar item_stacks: Array = (_args[2] as Array).duplicate(true) if _args.size() > 2 and _args[2] is Array else []",
            '\tvar selected_stat: String = "booster" if booster else "input"',
            '\tvar stat_values_items_expr: String = "StatValues.items(items)" if stats_time_period < 0.0 else "StatValues.items(stats.timePeriod, items)"',
            "\tvar display_items: Array = []",
            "\tfor stack in item_stacks:",
            "\t\tif not stack is Dictionary:",
            "\t\t\tcontinue",
            '\t\tvar item_id: int = int(stack.get("item_id", -1))',
            '\t\tvar amount: int = int(stack.get("amount", 0))',
            '\t\tvar display_expr: String = "displayItem(stack.item, stack.amount, displayName)" if stats_time_period < 0.0 else "displayItem(stack.item, stack.amount, timePeriod, true)"',
            '\t\tdisplay_items.append({"item_id": item_id, "amount": amount, "time_period": stats_time_period, "display_expr": display_expr})',
            '\tvar stats_add_call: Dictionary = {"call": "stats.add", "stat": selected_stat, "stat_value_expr": stat_values_items_expr, "time_period": stats_time_period, "item_stacks": item_stacks}',
            '\treturn {"source_owner": "PortGame.source_consume_items_display_state", "source": "core/src/mindustry/world/consumers/ConsumeItems.java", "method": "public void display(Stats stats){", "items_field": "public final ItemStack[] items;", "stats_add_expr": "stats.add(booster ? Stat.booster : Stat.input, stats.timePeriod < 0 ? StatValues.items(items) : StatValues.items(stats.timePeriod, items));", "stats_add_call_expr": "stats.add", "selected_stat_expr": "booster ? Stat.booster : Stat.input", "time_period_branch_expr": "stats.timePeriod < 0 ? StatValues.items(items) : StatValues.items(stats.timePeriod, items)", "stat_values_items_expr": stat_values_items_expr, "stat_values_items_method": "public static StatValue items(ItemStack... stacks){", "stat_values_timed_items_method": "public static StatValue items(float timePeriod, ItemStack... stacks){", "display_item_untimed_expr": "displayItem(stack.item, stack.amount, displayName)", "display_item_timed_expr": "displayItem(stack.item, stack.amount, timePeriod, true)", "stats_add_method": "public void add(Stat stat, StatValue value){", "stats_time_period_field": "public float timePeriod = -1;", "booster_field": "public boolean booster;", "stat_input_expr": "input = new Stat(\\"input\\", StatCat.crafting),", "stat_booster_expr": "booster = new Stat(\\"booster\\", StatCat.optional),", "item_stack_item_field": "public Item item;", "item_stack_amount_field": "public int amount = 0;", "booster": booster, "selected_stat": selected_stat, "stats_time_period": stats_time_period, "item_stacks": item_stacks, "display_items": display_items, "stats_add_call": stats_add_call}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemFilter.java"
        and type_entry.get("name") == "ConsumeItemFilter"
        and method.get("name") == "build"
    ):
        return [
            "\tvar filtered_item_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []",
            "\tvar build_items_has_item_flags: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []",
            "\tvar req_images: Array = []",
            "\tfor index in filtered_item_ids.size():",
            "\t\tvar valid: bool = bool(build_items_has_item_flags[index]) if index < build_items_has_item_flags.size() else false",
            '\t\treq_images.append({"item_id": int(filtered_item_ids[index]), "stack_amount": 1, "valid": valid, "stat_values_stack_expr": "StatValues.stack(item, 1)", "valid_expr": "build.items.has(item)"})',
            "\tvar table_image_size: float = 8.0 * 4.0",
            '\treturn {"source_owner": "PortGame.source_consume_item_filter_build_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public void build(Building build, Table table){", "filter_field": "public Boolf<Item> filter = i -> false;", "image_expr": "MultiReqImage image = new MultiReqImage();", "each_expr": "content.items().each(i -> filter.get(i) && i.unlockedNow() && !i.hidden, item -> image.add(new ReqImage(StatValues.stack(item, 1), () -> build.items.has(item))));", "table_add_expr": "table.add(image).size(8 * 4);", "multi_req_image_class": "public class MultiReqImage extends Stack{", "multi_req_image_add_expr": "public void add(ReqImage display){", "req_image_constructor": "public ReqImage(Element image, Boolp valid){", "req_image_valid_expr": "public boolean valid(){", "stat_values_stack_expr": "public static Stack stack(UnlockableContent item, int amount){", "building_items_field": "@Nullable ItemModule items;", "item_module_has_expr": "public boolean has(Item item){", "cell_size_expr": "public Cell<T> size(float size){", "filtered_item_ids": filtered_item_ids, "build_items_has_item_flags": build_items_has_item_flags, "multi_req_image_created": true, "req_images": req_images, "req_image_count": req_images.size(), "table_add_image": true, "table_image_size": table_image_size}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemFilter.java"
        and type_entry.get("name") == "ConsumeItemFilter"
        and method.get("name") == "update"
    ):
        return [
            "\tvar build_state: Variant = _args[0] if _args.size() > 0 else null",
            '\treturn {"source_owner": "PortGame.source_consume_item_filter_update_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public void update(Building build){", "empty_body": "public void update(Building build){\\n    }", "build_state": build_state, "no_op": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemFilter.java"
        and type_entry.get("name") == "ConsumeItemFilter"
        and method.get("name") == "trigger"
    ):
        return [
            "\tvar build_state: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar consumed_item: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar item_removed: bool = consumed_item != null",
            "\tvar remove_amount: int = 1 if item_removed else 0",
            "\tvar remove_call: Variant = null",
            "\tif item_removed:",
            '\t\tremove_call = {"call": "build.items.remove(item, 1)", "item": consumed_item, "amount": 1}',
            '\treturn {"source_owner": "PortGame.source_consume_item_filter_trigger_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public void trigger(Building build){", "get_consumed_expr": "Item item = getConsumed(build);", "null_guard_expr": "if(item != null){", "remove_expr": "build.items.remove(item, 1);", "build_state": build_state, "consumed_item": consumed_item, "item_removed": item_removed, "remove_amount": remove_amount, "remove_call": remove_call}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemFilter.java"
        and type_entry.get("name") == "ConsumeItemFilter"
        and method.get("name") == "itemEfficiencyMultiplier"
    ):
        return [
            "\tvar efficiency_multiplier: float = 1.0",
            '\treturn {"source_owner": "PortGame.source_consume_item_filter_item_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public float itemEfficiencyMultiplier(Item item){", "efficiency_multiplier": efficiency_multiplier, "return_expr": "return 1f;"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemFilter.java"
        and type_entry.get("name") == "ConsumeItemFilter"
        and method.get("name") == "efficiency"
    ):
        return [
            "\tvar consume_trigger_valid: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar consumed_item: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar has_consumed_item: bool = consumed_item != null",
            "\tvar efficiency: float = 1.0 if consume_trigger_valid or has_consumed_item else 0.0",
            '\treturn {"source_owner": "PortGame.source_consume_item_filter_efficiency_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public float efficiency(Building build){", "return_expr": "return build.consumeTriggerValid() || getConsumed(build) != null ? 1f : 0f;", "consume_trigger_valid_expr": "build.consumeTriggerValid()", "get_consumed_expr": "getConsumed(build) != null", "consume_trigger_valid": consume_trigger_valid, "consumed_item": consumed_item, "has_consumed_item": has_consumed_item, "efficiency": efficiency}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemFilter.java"
        and type_entry.get("name") == "ConsumeItemFilter"
        and method.get("name") == "getConsumed"
    ):
        return [
            "\tvar content_items: Array = _args[0] if _args.size() > 0 else []",
            "\tvar build_items_has_item_flags: Array = _args[1] if _args.size() > 1 else []",
            "\tvar filter_get_item_flags: Array = _args[2] if _args.size() > 2 else []",
            "\tvar consumed_item: Variant = null",
            "\tvar consumed_index: int = -1",
            "\tvar checked_items: Array = []",
            "\tfor i in range(content_items.size()):",
            "\t\tvar item: Variant = content_items[i]",
            "\t\tvar build_items_has_item: bool = bool(build_items_has_item_flags[i]) if i < build_items_has_item_flags.size() else false",
            "\t\tvar filter_get_item: bool = bool(filter_get_item_flags[i]) if i < filter_get_item_flags.size() else false",
            "\t\tvar item_matches: bool = build_items_has_item and filter_get_item",
            '\t\tchecked_items.append({"index": i, "item": item, "build_items_has_item": build_items_has_item, "filter_get_item": filter_get_item, "item_matches": item_matches})',
            "\t\tif item_matches:",
            "\t\t\tconsumed_item = item",
            "\t\t\tconsumed_index = i",
            "\t\t\tbreak",
            '\treturn {"source_owner": "PortGame.source_consume_item_filter_get_consumed_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public @Nullable Item getConsumed(Building build){", "loop_expr": "for(int i = 0; i < content.items().size; i++){", "content_item_expr": "Item item = content.item(i);", "guard_expr": "if(build.items.has(item) && this.filter.get(item)){", "return_item_expr": "return item;", "return_null_expr": "return null;", "content_items": content_items, "build_items_has_item_flags": build_items_has_item_flags, "filter_get_item_flags": filter_get_item_flags, "checked_items": checked_items, "consumed_item": consumed_item, "consumed_index": consumed_index}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemFilter.java"
        and type_entry.get("name") == "ConsumeItemFilter"
        and method.get("name") == "display"
    ):
        return [
            "\tvar booster: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar stats_time_period: float = float(_args[1] if _args.size() > 1 else -1.0)",
            "\tvar filtered_item_ids: Array = _args[2] if _args.size() > 2 else []",
            '\tvar selected_stat: String = "booster" if booster else "input"',
            "\tvar display_items: Array = []",
            "\tfor item_id in filtered_item_ids:",
            '\t\tvar display_expr: String = "displayItem(item)" if stats_time_period <= 0.0 else "displayItem(item, 1, timePeriod, true)"',
            '\t\tdisplay_items.append({"item_id": int(item_id), "time_period": stats_time_period, "display_expr": display_expr})',
            '\tvar stats_add_call: Dictionary = {"call": "stats.add", "stat": selected_stat, "stat_value_expr": "StatValues.items(stats.timePeriod, filter)", "time_period": stats_time_period, "filtered_item_ids": filtered_item_ids}',
            '\treturn {"source_owner": "PortGame.source_consume_item_filter_display_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public void display(Stats stats){", "stats_add_expr": "stats.add(booster ? Stat.booster : Stat.input, StatValues.items(stats.timePeriod, filter));", "stats_add_call_expr": "stats.add", "selected_stat_expr": "booster ? Stat.booster : Stat.input", "stat_values_items_expr": "StatValues.items(stats.timePeriod, filter)", "stat_values_items_method": "public static StatValue items(float timePeriod, Boolf<Item> filter){", "content_filter_expr": "Seq<Item> list = content.items().select(i -> filter.get(i) && i.unlockedNow() && !i.isHidden());", "display_item_expr": "table.add(timePeriod <= 0 ? displayItem(item) : displayItem(item, 1, timePeriod, true)).padRight(5);", "booster": booster, "selected_stat": selected_stat, "stats_time_period": stats_time_period, "filtered_item_ids": filtered_item_ids, "stats_add_call": stats_add_call, "display_items": display_items}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemFilter.java"
        and type_entry.get("name") == "ConsumeItemFilter"
        and method.get("name") == "efficiencyMultiplier"
    ):
        return [
            "\tvar consumed_item: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar item_efficiency_multiplier: float = float(_args[1] if _args.size() > 1 else 1.0)",
            "\tvar has_consumed_item: bool = consumed_item != null",
            "\tvar efficiency_multiplier: float = item_efficiency_multiplier if has_consumed_item else 0.0",
            '\treturn {"source_owner": "PortGame.source_consume_item_filter_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public float efficiencyMultiplier(Building build){", "get_consumed_expr": "var item = getConsumed(build);", "return_expr": "return item == null ? 0f : itemEfficiencyMultiplier(item);", "item_efficiency_multiplier_expr": "itemEfficiencyMultiplier(item)", "consumed_item": consumed_item, "item_efficiency_multiplier": item_efficiency_multiplier, "has_consumed_item": has_consumed_item, "efficiency_multiplier": efficiency_multiplier}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeLiquidFlammable.java"
        and type_entry.get("name") == "ConsumeLiquidFlammable"
        and method.get("name") == "liquidEfficiencyMultiplier"
    ):
        return [
            "\tvar liquid_flammability: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar efficiency_multiplier: float = liquid_flammability",
            '\treturn {"source_owner": "PortGame.source_consume_liquid_flammable_liquid_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidFlammable.java", "method": "public float liquidEfficiencyMultiplier(Liquid liquid){", "liquid_flammability": liquid_flammability, "efficiency_multiplier": efficiency_multiplier, "return_expr": "return liquid.flammability;"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeLiquidFilter.java"
        and type_entry.get("name") == "ConsumeLiquidFilter"
        and method.get("name") == "liquidEfficiencyMultiplier"
    ):
        return [
            "\tvar efficiency_multiplier: float = 1.0",
            '\treturn {"source_owner": "PortGame.source_consume_liquid_filter_liquid_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java", "method": "public float liquidEfficiencyMultiplier(Liquid liquid){", "efficiency_multiplier": efficiency_multiplier, "return_expr": "return 1f;"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeLiquidFilter.java"
        and type_entry.get("name") == "ConsumeLiquidFilter"
        and method.get("name") == "consumes"
    ):
        return [
            "\tvar filter_get_liquid: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar consumes_liquid: bool = filter_get_liquid",
            '\treturn {"source_owner": "PortGame.source_consume_liquid_filter_consumes_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java", "method": "public boolean consumes(Liquid liquid){", "filter_get_liquid": filter_get_liquid, "consumes_liquid": consumes_liquid, "return_expr": "return filter.get(liquid);"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeLiquidBase.java"
        and type_entry.get("name") == "ConsumeLiquidBase"
        and method.get("name") == "apply"
    ):
        return [
            "\tvar block_has_liquids_before: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar block_has_liquids_after: bool = true",
            '\treturn {"source_owner": "PortGame.source_consume_liquid_base_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidBase.java", "method": "public void apply(Block block){", "block_has_liquids_before": block_has_liquids_before, "block_has_liquids_after": block_has_liquids_after, "assignment_expr": "block.hasLiquids = true;"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeLiquid.java"
        and type_entry.get("name") == "ConsumeLiquid"
        and method.get("name") == "apply"
    ):
        return [
            "\tvar block_has_liquids_before: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar liquid_filter_before: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []",
            "\tvar liquid_id: int = int(_args[2] if _args.size() > 2 else 0)",
            '\tvar base_apply_state: Dictionary = {"assignment_expr": "block.hasLiquids = true;", "block_has_liquids_before": block_has_liquids_before, "block_has_liquids_after": true, "method": "public void apply(Block block){", "source_owner": "PortGame.source_consume_liquid_base_apply_state"}',
            "\tvar liquid_filter_after: Array = liquid_filter_before.duplicate()",
            "\tliquid_filter_after[liquid_id] = true",
            '\treturn {"source_owner": "PortGame.source_consume_liquid_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquid.java", "method": "public void apply(Block block){", "super_apply_expr": "super.apply(block);", "liquid_filter_assignment_expr": "block.liquidFilter[liquid.id] = true;", "block_has_liquids_before": block_has_liquids_before, "block_has_liquids_after": base_apply_state["block_has_liquids_after"], "base_apply_state": base_apply_state, "liquid_filter_before": liquid_filter_before, "liquid_id": liquid_id, "liquid_filter_after": liquid_filter_after}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeLiquid.java"
        and type_entry.get("name") == "ConsumeLiquid"
        and method.get("name") == "update"
    ):
        return [
            "\tvar liquid_id: int = int(_args[0] if _args.size() > 0 else 0)",
            "\tvar amount: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar build_edelta: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar multiplier_get_build: float = float(_args[3] if _args.size() > 3 else 1.0)",
            "\tvar remove_amount: float = amount * build_edelta * multiplier_get_build",
            '\treturn {"source_owner": "PortGame.source_consume_liquid_update_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquid.java", "method": "public void update(Building build){", "remove_expr": "build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));", "liquid_id": liquid_id, "amount": amount, "build_edelta": build_edelta, "multiplier_get_build": multiplier_get_build, "remove_amount": remove_amount}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeLiquids.java"
        and type_entry.get("name") == "ConsumeLiquids"
        and method.get("name") == "apply"
    ):
        return [
            "\tvar block_has_liquids_before: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar liquid_filter_before: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []",
            "\tvar liquid_ids: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []",
            "\tvar liquid_filter_after: Array = liquid_filter_before.duplicate()",
            "\tfor liquid_id in liquid_ids:",
            "\t\tliquid_filter_after[int(liquid_id)] = true",
            '\treturn {"source_owner": "PortGame.source_consume_liquids_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquids.java", "method": "public void apply(Block block){", "has_liquids_assignment_expr": "block.hasLiquids = true;", "loop_expr": "for(var stack : liquids){", "liquid_filter_assignment_expr": "block.liquidFilter[stack.liquid.id] = true;", "block_has_liquids_before": block_has_liquids_before, "block_has_liquids_after": true, "liquid_filter_before": liquid_filter_before, "liquid_ids": liquid_ids, "liquid_filter_after": liquid_filter_after}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeLiquidsDynamic.java"
        and type_entry.get("name") == "ConsumeLiquidsDynamic"
        and method.get("name") == "apply"
    ):
        return [
            "\tvar block_has_liquids_before: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar block_has_liquids_after: bool = true",
            '\treturn {"source_owner": "PortGame.source_consume_liquids_dynamic_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidsDynamic.java", "method": "public void apply(Block block){", "block_has_liquids_before": block_has_liquids_before, "block_has_liquids_after": block_has_liquids_after, "assignment_expr": "block.hasLiquids = true;"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemDynamic.java"
        and type_entry.get("name") == "ConsumeItemDynamic"
        and method.get("name") == "apply"
    ):
        return [
            "\tvar block_has_items_before: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar block_accepts_items_before: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar block_has_items_after: bool = true",
            "\tvar block_accepts_items_after: bool = true",
            '\treturn {"source_owner": "PortGame.source_consume_item_dynamic_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeItemDynamic.java", "method": "public void apply(Block block){", "has_items_assignment_expr": "block.hasItems = true;", "accepts_items_assignment_expr": "block.acceptsItems = true;", "block_has_items_before": block_has_items_before, "block_accepts_items_before": block_accepts_items_before, "block_has_items_after": block_has_items_after, "block_accepts_items_after": block_accepts_items_after}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeLiquidsDynamic.java"
        and type_entry.get("name") == "ConsumeLiquidsDynamic"
        and method.get("name") == "build"
    ):
        return [
            "\tvar current_liquid_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []",
            "\tvar next_liquid_ids: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []",
            "\tvar liquid_ids_changed: bool = current_liquid_ids != next_liquid_ids",
            "\tvar rebuild_calls: Array = []",
            '\trebuild_calls.append({"call": "rebuild(build, cont);", "phase": "initial", "liquid_ids": current_liquid_ids})',
            "\tvar current_liquid_ids_after_update: Array = current_liquid_ids.duplicate()",
            "\tif liquid_ids_changed:",
            '\t\trebuild_calls.append({"call": "rebuild(build, cont);", "phase": "update", "liquid_ids": next_liquid_ids})',
            "\t\tcurrent_liquid_ids_after_update = next_liquid_ids.duplicate()",
            '\treturn {"source_owner": "PortGame.source_consume_liquids_dynamic_build_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidsDynamic.java", "method": "public void build(Building build, Table table){", "current_expr": "LiquidStack[][] current = {liquids.get(build)};", "table_expr": "table.table(cont -> {", "update_expr": "table.update(() -> {", "changed_expr": "if(current[0] != liquids.get(build)){", "rebuild_expr": "rebuild(build, cont);", "assignment_expr": "current[0] = liquids.get(build);", "current_liquid_ids": current_liquid_ids, "next_liquid_ids": next_liquid_ids, "liquid_ids_changed": liquid_ids_changed, "rebuild_calls": rebuild_calls, "current_liquid_ids_after_update": current_liquid_ids_after_update, "table_cell_created": true, "update_registered": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemDynamic.java"
        and type_entry.get("name") == "ConsumeItemDynamic"
        and method.get("name") == "build"
    ):
        return [
            "\tvar current_item_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []",
            "\tvar next_item_ids: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []",
            "\tvar item_ids_changed: bool = current_item_ids != next_item_ids",
            "\tvar rebuild_calls: Array = []",
            '\trebuild_calls.append({"call": "rebuild(build, cont);", "phase": "initial", "item_ids": current_item_ids})',
            "\tvar current_item_ids_after_update: Array = current_item_ids.duplicate()",
            "\tif item_ids_changed:",
            '\t\trebuild_calls.append({"call": "rebuild(build, cont);", "phase": "update", "item_ids": next_item_ids})',
            "\t\tcurrent_item_ids_after_update = next_item_ids.duplicate()",
            '\treturn {"source_owner": "PortGame.source_consume_item_dynamic_build_state", "source": "core/src/mindustry/world/consumers/ConsumeItemDynamic.java", "method": "public void build(Building build, Table table){", "current_expr": "ItemStack[][] current = {items.get(build)};", "table_expr": "table.table(cont -> {", "update_expr": "table.update(() -> {", "changed_expr": "if(current[0] != items.get(build)){", "rebuild_expr": "rebuild(build, cont);", "assignment_expr": "current[0] = items.get(build);", "current_item_ids": current_item_ids, "next_item_ids": next_item_ids, "item_ids_changed": item_ids_changed, "rebuild_calls": rebuild_calls, "current_item_ids_after_update": current_item_ids_after_update, "table_cell_created": true, "update_registered": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemDynamic.java"
        and type_entry.get("name") == "ConsumeItemDynamic"
        and method.get("name") == "rebuild"
    ):
        return [
            "\tvar item_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []",
            "\tvar item_stack_amounts: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []",
            "\tvar item_amounts: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []",
            "\tvar building_has_items: bool = bool(_args[3] if _args.size() > 3 else true)",
            "\tvar multiplier_get_build: float = float(_args[4] if _args.size() > 4 else 1.0)",
            "\tvar req_images: Array = []",
            "\tvar row_calls: Array = []",
            "\tfor index in item_ids.size():",
            "\t\tvar stack_amount: float = float(item_stack_amounts[index] if index < item_stack_amounts.size() else 0.0)",
            "\t\tvar item_amount: float = float(item_amounts[index] if index < item_amounts.size() else 0.0)",
            "\t\tvar required_amount: int = int(floor(stack_amount * multiplier_get_build + 0.5))",
            "\t\tvar valid: bool = building_has_items and item_amount >= required_amount",
            '\t\treq_images.append({"item_id": int(item_ids[index]), "stack_amount": stack_amount, "required_amount": required_amount, "item_amount": item_amount, "valid": valid, "stat_values_stack_expr": "StatValues.stack(stack.item, Math.round(stack.amount * multiplier.get(build)))", "pad_right": 8.0, "left": true})',
            "\t\tif (index + 1) % 4 == 0:",
            '\t\t\trow_calls.append({"call": "table.row();", "after_count": index + 1})',
            '\treturn {"source_owner": "PortGame.source_consume_item_dynamic_rebuild_state", "source": "core/src/mindustry/world/consumers/ConsumeItemDynamic.java", "method": "private void rebuild(Building build, Table table){", "items_field": "public final Func<Building, ItemStack[]> items;", "clear_expr": "table.clear();", "i_initial_expr": "int i = 0;", "loop_expr": "for(ItemStack stack : items.get(build)){", "add_expr": "table.add(new ReqImage(StatValues.stack(stack.item, Math.round(stack.amount * multiplier.get(build))), () -> build.items != null && build.items.has(stack.item, Math.round(stack.amount * multiplier.get(build))))).padRight(8).left();", "row_expr": "if(++i % 4 == 0) table.row();", "multiplier_field": "public Floatf<Building> multiplier = b -> 1f;", "item_stack_item_field": "public Item item;", "item_stack_amount_field": "public int amount = 0;", "building_items_field": "@Nullable ItemModule items;", "item_module_has_expr": "public boolean has(Item item, int amount){", "stat_values_stack_expr": "public static Stack stack(UnlockableContent item, int amount){", "req_image_constructor": "public ReqImage(Element image, Boolp valid){", "req_image_valid_expr": "public boolean valid(){", "cell_pad_right_expr": "public Cell<T> padRight(float padRight){", "cell_left_expr": "public Cell<T> left(){", "item_ids": item_ids, "item_stack_amounts": item_stack_amounts, "item_amounts": item_amounts, "building_has_items": building_has_items, "multiplier_get_build": multiplier_get_build, "req_images": req_images, "row_calls": row_calls, "cleared": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemDynamic.java"
        and type_entry.get("name") == "ConsumeItemDynamic"
        and method.get("name") == "trigger"
    ):
        return [
            "\tvar item_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []",
            "\tvar item_stack_amounts: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []",
            "\tvar multiplier_get_build: float = float(_args[2] if _args.size() > 2 else 1.0)",
            "\tvar remove_calls: Array = []",
            "\tfor index in item_ids.size():",
            "\t\tvar stack_amount: float = float(item_stack_amounts[index] if index < item_stack_amounts.size() else 0.0)",
            "\t\tvar remove_amount: int = int(floor(stack_amount * multiplier_get_build + 0.5))",
            '\t\tremove_calls.append({"call": "build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));", "item_id": int(item_ids[index]), "stack_amount": stack_amount, "amount": remove_amount})',
            '\treturn {"source_owner": "PortGame.source_consume_item_dynamic_trigger_state", "source": "core/src/mindustry/world/consumers/ConsumeItemDynamic.java", "method": "public void trigger(Building build){", "items_field": "public final Func<Building, ItemStack[]> items;", "loop_expr": "for(ItemStack stack : items.get(build)){", "remove_expr": "build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));", "round_expr": "Math.round(stack.amount * multiplier.get(build))", "multiplier_field": "public Floatf<Building> multiplier = b -> 1f;", "item_stack_item_field": "public Item item;", "item_stack_amount_field": "public int amount = 0;", "building_items_field": "@Nullable ItemModule items;", "item_module_remove_method": "public void remove(Item item, int amount){", "item_module_remove_clamp": "amount = Math.min(amount, items[item.id]);", "item_ids": item_ids, "item_stack_amounts": item_stack_amounts, "multiplier_get_build": multiplier_get_build, "remove_calls": remove_calls}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemDynamic.java"
        and type_entry.get("name") == "ConsumeItemDynamic"
        and method.get("name") == "efficiency"
    ):
        return [
            "\tvar consume_trigger_valid: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar item_ids: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []",
            "\tvar item_stack_amounts: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []",
            "\tvar item_amounts: Array = (_args[3] as Array).duplicate() if _args.size() > 3 and _args[3] is Array else []",
            "\tvar multiplier_get_build: float = float(_args[4] if _args.size() > 4 else 1.0)",
            "\tvar item_module_has_stacks: bool = true",
            "\tvar stack_checks: Array = []",
            "\tfor index in item_ids.size():",
            "\t\tvar item_id: int = int(item_ids[index])",
            "\t\tvar stack_amount: float = float(item_stack_amounts[index] if index < item_stack_amounts.size() else 0.0)",
            "\t\tvar required_amount: int = int(floor(stack_amount * multiplier_get_build + 0.5))",
            "\t\tvar item_amount: float = 0.0",
            "\t\tif item_id < item_amounts.size():",
            "\t\t\titem_amount = float(item_amounts[item_id])",
            "\t\tvar has_stack: bool = item_id < item_amounts.size() and item_amount >= required_amount",
            '\t\tstack_checks.append({"item_id": item_id, "stack_amount": stack_amount, "required_amount": required_amount, "item_amount": item_amount, "has_stack": has_stack})',
            "\t\tif item_id >= item_amounts.size() or float(item_amounts[item_id]) < required_amount:",
            "\t\t\titem_module_has_stacks = false",
            "\t\t\tbreak",
            "\tvar efficiency_value: float = 1.0 if consume_trigger_valid or item_module_has_stacks else 0.0",
            '\treturn {"source_owner": "PortGame.source_consume_item_dynamic_efficiency_state", "source": "core/src/mindustry/world/consumers/ConsumeItemDynamic.java", "method": "public float efficiency(Building build){", "items_field": "public final Func<Building, ItemStack[]> items;", "return_expr": "return build.consumeTriggerValid() || build.items.has(items.get(build), multiplier.get(build)) ? 1f : 0f;", "consume_trigger_valid_expr": "build.consumeTriggerValid()", "item_module_has_stacks_expr": "public boolean has(ItemStack[] stacks, float multiplier){", "item_module_has_stack_guard_expr": "if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;", "item_module_has_stacks_return_expr": "return true;", "item_module_has_item_amount_expr": "public boolean has(Item item, int amount){", "item_module_has_item_amount_return_expr": "return get(item) >= amount;", "multiplier_field": "public Floatf<Building> multiplier = b -> 1f;", "item_stack_item_field": "public Item item;", "item_stack_amount_field": "public int amount = 0;", "consume_trigger_valid": consume_trigger_valid, "item_ids": item_ids, "item_stack_amounts": item_stack_amounts, "item_amounts": item_amounts, "multiplier_get_build": multiplier_get_build, "item_module_has_stacks": item_module_has_stacks, "stack_checks": stack_checks, "efficiency": efficiency_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemEfficiency.java"
        and type_entry.get("name") == "ConsumeItemEfficiency"
        and method.get("name") == "display"
    ):
        return [
            "\tvar booster: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar stats_time_period: float = float(_args[1] if _args.size() > 1 else -1.0)",
            "\tvar filtered_item_ids: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []",
            "\tvar item_efficiency_multipliers: Array = (_args[3] as Array).duplicate() if _args.size() > 3 and _args[3] is Array else []",
            "\tvar item_duration_multipliers: Array = (_args[4] as Array).duplicate() if _args.size() > 4 and _args[4] is Array else []",
            "\tvar table_has_cells: bool = bool(_args[5] if _args.size() > 5 else false)",
            '\tvar selected_stat: String = "booster" if booster else "input"',
            "\tvar display_rows: Array = []",
            "\tfor index in filtered_item_ids.size():",
            "\t\tvar item_id: int = int(filtered_item_ids[index])",
            "\t\tvar efficiency_multiplier: float = float(item_efficiency_multipliers[index] if index < item_efficiency_multipliers.size() else 1.0)",
            "\t\tvar time_multiplier: float = float(item_duration_multipliers[index] if index < item_duration_multipliers.size() else 1.0)",
            "\t\tvar time_value: float = 1.0 / (stats_time_period * time_multiplier / 60.0)",
            "\t\tvar efficiency_percent: float = efficiency_multiplier * 100.0",
            '\t\tdisplay_rows.append({"item_id": item_id, "efficiency_multiplier": efficiency_multiplier, "efficiency_percent": efficiency_percent, "time_multiplier": time_multiplier, "time": time_value, "time_period": stats_time_period})',
            '\treturn {"source_owner": "PortGame.source_consume_item_efficiency_display_state", "source": "core/src/mindustry/world/consumers/ConsumeItemEfficiency.java", "method": "public void display(Stats stats){", "item_duration_multipliers_field": "public @Nullable ObjectFloatMap<Item> itemDurationMultipliers;", "stats_add_expr": "stats.add(booster ? Stat.booster : Stat.input, StatValues.itemEffMultiplier(this::itemEfficiencyMultiplier, stats.timePeriod, filter, itemDurationMultipliers));", "stats_add_call": "stats.add", "selected_stat_expr": "booster ? Stat.booster : Stat.input", "selected_stat": selected_stat, "item_eff_multiplier_expr": "StatValues.itemEffMultiplier(this::itemEfficiencyMultiplier, stats.timePeriod, filter, itemDurationMultipliers)", "item_eff_multiplier_method": "public static StatValue itemEffMultiplier(Floatf<Item> efficiency, float timePeriod, Boolf<Item> filter, @Nullable ObjectFloatMap<Item> itemDurationMultipliers){", "table_cells_grow_expr": "if(table.getCells().size > 0) table.getCells().peek().growX();", "table_grow_previous_cell": table_has_cells, "content_filter_expr": "for(Item item : content.items().select(i -> filter.get(i) && i.unlockedNow() && !i.isHidden())){", "time_multiplier_expr": "float timeMultiplier = itemDurationMultipliers == null ? 1f : itemDurationMultipliers.get(item, 1f);", "time_expr": "float time = 1f / (timePeriod * timeMultiplier / 60f);", "efficiency_expr": "b.add(Core.bundle.format(\\"stat.efficiency\\", fixValue(efficiency.get(item) * 100f))).right().pad(10f).padRight(15f);", "booster": booster, "stats_time_period": stats_time_period, "filtered_item_ids": filtered_item_ids, "item_efficiency_multipliers": item_efficiency_multipliers, "item_duration_multipliers": item_duration_multipliers, "table_has_cells": table_has_cells, "display_rows": display_rows}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeLiquidsDynamic.java"
        and type_entry.get("name") == "ConsumeLiquidsDynamic"
        and method.get("name") == "rebuild"
    ):
        return [
            "\tvar liquid_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []",
            "\tvar liquid_amounts: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []",
            "\tvar building_has_liquids: bool = bool(_args[2] if _args.size() > 2 else true)",
            "\tvar req_images: Array = []",
            "\tvar row_calls: Array = []",
            "\tfor index in liquid_ids.size():",
            "\t\tvar liquid_amount: float = float(liquid_amounts[index] if index < liquid_amounts.size() else 0.0)",
            "\t\tvar valid: bool = building_has_liquids and liquid_amount > 0.0",
            '\t\treq_images.append({"liquid_id": int(liquid_ids[index]), "liquid_amount": liquid_amount, "valid": valid, "ui_icon_expr": "stack.liquid.uiIcon", "size": 32.0, "pad_right": 8.0})',
            "\t\tif (index + 1) % 4 == 0:",
            '\t\t\trow_calls.append({"call": "table.row();", "after_count": index + 1})',
            '\treturn {"source_owner": "PortGame.source_consume_liquids_dynamic_rebuild_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidsDynamic.java", "method": "private void rebuild(Building build, Table table){", "clear_expr": "table.clear();", "i_initial_expr": "int i = 0;", "loop_expr": "for(LiquidStack stack : liquids.get(build)){", "add_expr": "table.add(new ReqImage(stack.liquid.uiIcon, () -> build.liquids != null && build.liquids.get(stack.liquid) > 0)).size(Vars.iconMed).padRight(8);", "row_expr": "if(++i % 4 == 0) table.row();", "liquid_ids": liquid_ids, "liquid_amounts": liquid_amounts, "building_has_liquids": building_has_liquids, "req_images": req_images, "row_calls": row_calls, "cleared": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeLiquidsDynamic.java"
        and type_entry.get("name") == "ConsumeLiquidsDynamic"
        and method.get("name") == "update"
    ):
        return [
            "\tvar liquid_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []",
            "\tvar liquid_stack_amounts: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []",
            "\tvar build_edelta: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar multiplier_get_build: float = float(_args[3] if _args.size() > 3 else 1.0)",
            "\tvar remove_calls: Array = []",
            "\tfor index in liquid_ids.size():",
            "\t\tvar stack_amount: float = float(liquid_stack_amounts[index] if index < liquid_stack_amounts.size() else 0.0)",
            "\t\tvar remove_amount: float = stack_amount * build_edelta * multiplier_get_build",
            '\t\tremove_calls.append({"call": "build.liquids.remove(stack.liquid, stack.amount * build.edelta() * mult);", "liquid_id": int(liquid_ids[index]), "stack_amount": stack_amount, "amount": remove_amount})',
            '\treturn {"source_owner": "PortGame.source_consume_liquids_dynamic_update_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidsDynamic.java", "method": "public void update(Building build){", "multiplier_expr": "float mult = multiplier.get(build);", "loop_expr": "for(LiquidStack stack : liquids.get(build)){", "remove_expr": "build.liquids.remove(stack.liquid, stack.amount * build.edelta() * mult);", "liquid_ids": liquid_ids, "liquid_stack_amounts": liquid_stack_amounts, "build_edelta": build_edelta, "multiplier_get_build": multiplier_get_build, "remove_calls": remove_calls}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeLiquidsDynamic.java"
        and type_entry.get("name") == "ConsumeLiquidsDynamic"
        and method.get("name") == "efficiency"
    ):
        return [
            "\tvar liquid_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []",
            "\tvar liquid_stack_amounts: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []",
            "\tvar liquid_amounts: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []",
            "\tvar build_edelta: float = float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar multiplier_get_build: float = float(_args[4] if _args.size() > 4 else 1.0)",
            "\tvar ed: float = build_edelta",
            "\tif ed <= 0.00000001:",
            '\t\treturn {"source_owner": "PortGame.source_consume_liquids_dynamic_efficiency_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidsDynamic.java", "method": "public float efficiency(Building build){", "ed_expr": "float ed = build.edelta();", "ed_guard_expr": "if(ed <= 0.00000001f) return 0f;", "liquid_ids": liquid_ids, "liquid_stack_amounts": liquid_stack_amounts, "liquid_amounts": liquid_amounts, "build_edelta": build_edelta, "multiplier_get_build": multiplier_get_build, "ed": ed, "min_initial_expr": "float min = 1f;", "loop_expr": "for(LiquidStack stack : liquids.get(build)){", "efficiency_expr": "Math.min(build.liquids.get(stack.liquid) / (stack.amount * ed * multiplier.get(build)), min)", "return_expr": "return min;", "per_stack_efficiencies": [], "efficiency": 0.0}',
            "\tvar min_efficiency: float = 1.0",
            "\tvar per_stack_efficiencies: Array = []",
            "\tfor index in liquid_ids.size():",
            "\t\tvar stack_amount: float = float(liquid_stack_amounts[index] if index < liquid_stack_amounts.size() else 0.0)",
            "\t\tvar liquid_amount: float = float(liquid_amounts[index] if index < liquid_amounts.size() else 0.0)",
            "\t\tvar denominator: float = stack_amount * ed * multiplier_get_build",
            "\t\tvar stack_efficiency: float = liquid_amount / denominator",
            "\t\tmin_efficiency = min(stack_efficiency, min_efficiency)",
            '\t\tper_stack_efficiencies.append({"liquid_id": int(liquid_ids[index]), "liquid_amount": liquid_amount, "stack_amount": stack_amount, "denominator": denominator, "efficiency": stack_efficiency})',
            '\treturn {"source_owner": "PortGame.source_consume_liquids_dynamic_efficiency_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidsDynamic.java", "method": "public float efficiency(Building build){", "ed_expr": "float ed = build.edelta();", "ed_guard_expr": "if(ed <= 0.00000001f) return 0f;", "liquid_ids": liquid_ids, "liquid_stack_amounts": liquid_stack_amounts, "liquid_amounts": liquid_amounts, "build_edelta": build_edelta, "multiplier_get_build": multiplier_get_build, "ed": ed, "min_initial_expr": "float min = 1f;", "loop_expr": "for(LiquidStack stack : liquids.get(build)){", "efficiency_expr": "Math.min(build.liquids.get(stack.liquid) / (stack.amount * ed * multiplier.get(build)), min)", "return_expr": "return min;", "per_stack_efficiencies": per_stack_efficiencies, "efficiency": min_efficiency}',
        ]
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeLiquid.java"
        and type_entry.get("name") == "ConsumeLiquid"
        and method.get("name") == "consumes"
    ):
        return [
            "\tvar liquid_matches_self_liquid: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar consumes_liquid: bool = liquid_matches_self_liquid",
            '\treturn {"source_owner": "PortGame.source_consume_liquid_consumes_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquid.java", "method": "public boolean consumes(Liquid liquid){", "liquid_matches_self_liquid": liquid_matches_self_liquid, "consumes_liquid": consumes_liquid, "return_expr": "return liquid == this.liquid;"}',
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
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "outputsItems"
    ):
        return [
            "\tvar has_items: bool = bool(_args[0] if _args.size() > 0 else false)",
            '\treturn {"source_owner": "PortGame.source_block_outputs_items_state", "source": "core/src/mindustry/world/Block.java", "field_comment": "/** If true, buildings have an ItemModule. */", "field_expr": "public @NoPatch boolean hasItems;", "method": "public boolean outputsItems(){", "return_expr": "return hasItems;", "has_items": has_items, "outputs_items": has_items}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "canPlaceOn"
    ):
        return [
            "\tvar tile: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar team: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar rotation: int = int(_args[2] if _args.size() > 2 else 0)",
            '\treturn {"source_owner": "PortGame.source_block_can_place_on_state", "source": "core/src/mindustry/world/Block.java", "comment": "/** @return whether this block can be placed on the specified tile. */", "method": "public boolean canPlaceOn(Tile tile, Team team, int rotation){", "return_expr": "return true;", "tile": tile, "team": team, "rotation": rotation, "can_place": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "canBreak"
    ):
        return [
            "\tvar tile: Variant = _args[0] if _args.size() > 0 else null",
            '\treturn {"source_owner": "PortGame.source_block_can_break_state", "source": "core/src/mindustry/world/Block.java", "comment": "/** @return whether this block can be broken on the specified tile. */", "method": "public boolean canBreak(Tile tile){", "return_expr": "return true;", "tile": tile, "can_break": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "rotatedOutput"
        and [param.get("type") for param in method.get("parameters", [])] == ["int", "int"]
    ):
        return [
            "\tvar rotate_value: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar x_value: int = int(_args[1] if _args.size() > 1 else 0)",
            "\tvar y_value: int = int(_args[2] if _args.size() > 2 else 0)",
            '\treturn {"source_owner": "PortGame.source_block_rotated_output_state", "source": "core/src/mindustry/world/Block.java", "field_comment": "/** whether this is rotatable */", "field_expr": "public boolean rotate;", "method": "public boolean rotatedOutput(int x, int y){", "return_expr": "return rotate;", "rotate": rotate_value, "x": x_value, "y": y_value, "rotated_output": rotate_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "rotatedOutput"
        and [param.get("type") for param in method.get("parameters", [])] == ["int", "int", "Tile"]
    ):
        return [
            "\tvar rotate_value: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar from_x: int = int(_args[1] if _args.size() > 1 else 0)",
            "\tvar from_y: int = int(_args[2] if _args.size() > 2 else 0)",
            "\tvar destination: Variant = _args[3] if _args.size() > 3 else null",
            '\tvar base_state := {"source_owner": "PortGame.source_block_rotated_output_state", "source": "core/src/mindustry/world/Block.java", "field_comment": "/** whether this is rotatable */", "field_expr": "public boolean rotate;", "method": "public boolean rotatedOutput(int x, int y){", "return_expr": "return rotate;", "rotate": rotate_value, "x": from_x, "y": from_y, "rotated_output": rotate_value}',
            '\treturn {"source_owner": "PortGame.source_block_rotated_output_tile_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean rotatedOutput(int fromX, int fromY, Tile destination){", "delegate_call": "rotatedOutput(fromX, fromY)", "return_expr": "return rotatedOutput(fromX, fromY);", "rotate": rotate_value, "fromX": from_x, "fromY": from_y, "destination": destination, "base_state": base_state, "rotated_output": base_state["rotated_output"]}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "synthetic"
    ):
        return [
            "\tvar update_value: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar destructible_value: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar synthetic_value: bool = update_value or destructible_value",
            '\treturn {"source_owner": "PortGame.source_block_synthetic_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean synthetic(){", "return_expr": "return update || destructible;", "update": update_value, "destructible": destructible_value, "synthetic": synthetic_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "checkForceDark"
    ):
        return [
            "\tvar force_dark_value: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar tile: Variant = _args[1] if _args.size() > 1 else null",
            '\treturn {"source_owner": "PortGame.source_block_check_force_dark_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean checkForceDark(Tile tile){", "return_expr": "return forceDark;", "force_dark": force_dark_value, "tile": tile, "check_force_dark": force_dark_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "isDarkened"
    ):
        return [
            "\tvar solid_value: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar update_value: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar destructible_value: bool = bool(_args[2] if _args.size() > 2 else false)",
            "\tvar fills_tile_value: bool = bool(_args[3] if _args.size() > 3 else false)",
            "\tvar force_dark_value: bool = bool(_args[4] if _args.size() > 4 else false)",
            "\tvar tile: Variant = _args[5] if _args.size() > 5 else null",
            '\tvar synthetic_state := {"source_owner": "PortGame.source_block_synthetic_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean synthetic(){", "return_expr": "return update || destructible;", "update": update_value, "destructible": destructible_value, "synthetic": update_value or destructible_value}',
            '\tvar check_force_dark_state := {"source_owner": "PortGame.source_block_check_force_dark_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean checkForceDark(Tile tile){", "return_expr": "return forceDark;", "force_dark": force_dark_value, "tile": tile, "check_force_dark": force_dark_value}',
            '\tvar is_darkened_value: bool = solid_value and ((not bool(synthetic_state["synthetic"]) and fills_tile_value) or bool(check_force_dark_state["check_force_dark"]))',
            '\treturn {"source_owner": "PortGame.source_block_is_darkened_state", "source": "core/src/mindustry/world/Block.java", "comment": "/** If true, the \'map edge\' darkness will be applied to this block. */", "method": "public boolean isDarkened(Tile tile){", "return_expr": "return solid && ((!synthetic() && fillsTile) || checkForceDark(tile));", "solid": solid_value, "fillsTile": fills_tile_value, "synthetic_state": synthetic_state, "check_force_dark_state": check_force_dark_state, "tile": tile, "is_darkened": is_darkened_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "isHidden"
    ):
        return [
            "\tvar build_visibility_visible: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar revealed_blocks_contains_self: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar is_hidden_value: bool = (not build_visibility_visible) and (not revealed_blocks_contains_self)",
            '\treturn {"source_owner": "PortGame.source_block_is_hidden_state", "source": "core/src/mindustry/world/Block.java", "override_expr": "@Override", "method": "public boolean isHidden(){", "return_expr": "return !buildVisibility.visible() && !state.rules.revealedBlocks.contains(this);", "build_visibility_visible": build_visibility_visible, "revealed_blocks_contains_self": revealed_blocks_contains_self, "is_hidden": is_hidden_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "planRotation"
    ):
        return [
            "\tvar rotate_value: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar lock_rotation: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar rot: int = int(_args[2] if _args.size() > 2 else 0)",
            "\tvar plan_rotation_value: int = 0 if ((not rotate_value) and lock_rotation) else rot",
            '\treturn {"source_owner": "PortGame.source_block_plan_rotation_state", "source": "core/src/mindustry/world/Block.java", "method": "public int planRotation(int rot){", "return_expr": "return !rotate && lockRotation ? 0 : rot;", "rotate": rotate_value, "lockRotation": lock_rotation, "rot": rot, "plan_rotation": plan_rotation_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "flipRotation"
    ):
        return [
            "\tvar rotation_before: int = int(_args[0] if _args.size() > 0 else 0)",
            "\tvar x_value: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar invert_flip: bool = bool(_args[2] if _args.size() > 2 else false)",
            "\tvar rotate_value: bool = bool(_args[3] if _args.size() > 3 else false)",
            "\tvar lock_rotation: bool = bool(_args[4] if _args.size() > 4 else false)",
            "\tvar rotation_even: bool = rotation_before % 2 == 0",
            "\tvar flip_guard: bool = (x_value == rotation_even) != invert_flip",
            "\tvar mod_value: int = int(fmod(fmod(float(rotation_before + 2), 4.0) + 4.0, 4.0))",
            '\tvar plan_rotation_state := {"source_owner": "PortGame.source_block_plan_rotation_state", "source": "core/src/mindustry/world/Block.java", "method": "public int planRotation(int rot){", "return_expr": "return !rotate && lockRotation ? 0 : rot;", "rotate": rotate_value, "lockRotation": lock_rotation, "rot": mod_value, "plan_rotation": 0 if ((not rotate_value) and lock_rotation) else mod_value}',
            '\tvar rotation_after: int = int(plan_rotation_state["plan_rotation"]) if flip_guard else rotation_before',
            '\treturn {"source_owner": "PortGame.source_block_flip_rotation_state", "source": "core/src/mindustry/world/Block.java", "method": "public void flipRotation(BuildPlan req, boolean x){", "guard_expr": "if((x == (req.rotation % 2 == 0)) != invertFlip){", "assignment_expr": "req.rotation = planRotation(Mathf.mod(req.rotation + 2, 4));", "rotation_before": rotation_before, "x": x_value, "invertFlip": invert_flip, "rotate": rotate_value, "lockRotation": lock_rotation, "rotation_even": rotation_even, "flip_guard": flip_guard, "mod_input": rotation_before + 2, "mod_value": mod_value, "plan_rotation_state": plan_rotation_state, "rotation_after": rotation_after}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "getPlanConfigs"
    ):
        return [
            "\tvar options_before: Array = _args[0] if _args.size() > 0 else []",
            "\tvar item_configured: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar liquid_configured: bool = bool(_args[2] if _args.size() > 2 else false)",
            "\tvar content_items: Array = _args[3] if _args.size() > 3 else []",
            "\tvar content_liquids: Array = _args[4] if _args.size() > 4 else []",
            "\tvar options_after: Array = options_before.duplicate()",
            "\tif item_configured:",
            "\t\toptions_after.append_array(content_items)",
            "\tif liquid_configured:",
            "\t\toptions_after.append_array(content_liquids)",
            "\tvar item_options_added: int = content_items.size() if item_configured else 0",
            "\tvar liquid_options_added: int = content_liquids.size() if liquid_configured else 0",
            '\treturn {"source_owner": "PortGame.source_block_get_plan_configs_state", "source": "core/src/mindustry/world/Block.java", "comment": "/** Fills the specified array with the list of configuration options this block has. Only used for plans. */", "method": "public void getPlanConfigs(Seq<UnlockableContent> options){", "item_guard_expr": "if(configurations.containsKey(Item.class)){", "item_add_expr": "options.add(content.items());", "liquid_guard_expr": "if(configurations.containsKey(Liquid.class)){", "liquid_add_expr": "options.add(content.liquids());", "options_before": options_before, "item_configured": item_configured, "liquid_configured": liquid_configured, "content_items": content_items, "content_liquids": content_liquids, "item_options_added": item_options_added, "liquid_options_added": liquid_options_added, "options_after": options_after}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "sense"
        and method.get("parameters")
        and method["parameters"][0].get("type") == "LAccess"
    ):
        return [
            '\tvar sensor: String = str(_args[0] if _args.size() > 0 else "")',
            "\tvar map_color_double_bits: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar health_value: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar solid_value: bool = bool(_args[3] if _args.size() > 3 else false)",
            "\tvar size_value: int = int(_args[4] if _args.size() > 4 else 0)",
            "\tvar item_capacity: int = int(_args[5] if _args.size() > 5 else 0)",
            "\tvar liquid_capacity: float = float(_args[6] if _args.size() > 6 else 0.0)",
            "\tvar has_cons_power: bool = bool(_args[7] if _args.size() > 7 else false)",
            "\tvar cons_power_buffered: bool = bool(_args[8] if _args.size() > 8 else false)",
            "\tvar cons_power_capacity: float = float(_args[9] if _args.size() > 9 else 0.0)",
            "\tvar logic_id: int = int(_args[10] if _args.size() > 10 else 0)",
            "\tvar sense_value: float = NAN",
            "\tmatch sensor:",
            '\t\t"color":',
            "\t\t\tsense_value = map_color_double_bits",
            '\t\t"health", "maxHealth":',
            "\t\t\tsense_value = health_value",
            '\t\t"solid":',
            "\t\t\tsense_value = 1.0 if solid_value else 0.0",
            '\t\t"size":',
            "\t\t\tsense_value = float(size_value)",
            '\t\t"itemCapacity":',
            "\t\t\tsense_value = float(item_capacity)",
            '\t\t"liquidCapacity":',
            "\t\t\tsense_value = liquid_capacity",
            '\t\t"powerCapacity":',
            "\t\t\tsense_value = cons_power_capacity if has_cons_power and cons_power_buffered else 0.0",
            '\t\t"id":',
            "\t\t\tsense_value = float(logic_id)",
            '\t\t_:',
            "\t\t\tsense_value = NAN",
            "\tvar sense_value_wire: Variant = sense_value",
            "\tif is_nan(sense_value):",
            "\t\tsense_value_wire = null",
            '\treturn {"source_owner": "PortGame.source_block_sense_laccess_state", "source": "core/src/mindustry/world/Block.java", "override_expr": "@Override", "method": "public double sense(LAccess sensor){", "switch_expr": "return switch(sensor){", "color_case": "case color -> mapColor.toDoubleBits();", "health_case": "case health, maxHealth -> health;", "solid_case": "case solid -> solid ? 1 : 0;", "size_case": "case size -> size;", "item_capacity_case": "case itemCapacity -> itemCapacity;", "liquid_capacity_case": "case liquidCapacity -> liquidCapacity;", "power_capacity_case": "case powerCapacity -> consPower != null && consPower.buffered ? consPower.capacity : 0f;", "id_case": "case id -> getLogicId();", "default_expr": "default -> Double.NaN;", "sensor": sensor, "map_color_double_bits": map_color_double_bits, "health": health_value, "solid": solid_value, "size": size_value, "itemCapacity": item_capacity, "liquidCapacity": liquid_capacity, "has_cons_power": has_cons_power, "cons_power_buffered": cons_power_buffered, "cons_power_capacity": cons_power_capacity, "logic_id": logic_id, "sense_value": sense_value_wire, "sense_value_is_nan": is_nan(sense_value)}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "sense"
        and method.get("parameters")
        and method["parameters"][0].get("type") == "Content"
    ):
        return [
            '\tvar content_type: String = str(_args[0] if _args.size() > 0 else "")',
            "\tvar content_item: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar state_rules_infinite_resources: bool = bool(_args[2] if _args.size() > 2 else false)",
            "\tvar requirements: Array = _args[3] if _args.size() > 3 else []",
            "\tvar build_cost_multiplier: float = float(_args[4] if _args.size() > 4 else 1.0)",
            "\tvar sense_value: float = NAN",
            "\tvar matched_requirement_index: int = -1",
            "\tvar matched_requirement: Variant = null",
            "\tvar matched_amount: int = 0",
            '\tif content_type == "Item":',
            "\t\tsense_value = 0.0",
            "\t\tif state_rules_infinite_resources:",
            "\t\t\tsense_value = 0.0",
            "\t\telse:",
            "\t\t\tfor index in range(requirements.size()):",
            "\t\t\t\tvar requirement: Dictionary = {}",
            "\t\t\t\tif requirements[index] is Dictionary:",
            "\t\t\t\t\trequirement = requirements[index]",
            '\t\t\t\tif requirement.get("item") == content_item:',
            "\t\t\t\t\tmatched_requirement_index = index",
            "\t\t\t\t\tmatched_requirement = requirement",
            '\t\t\t\t\tmatched_amount = int(floor(float(requirement.get("amount", 0.0)) * build_cost_multiplier + 0.5))',
            "\t\t\t\t\tsense_value = float(matched_amount)",
            "\t\t\t\t\tbreak",
            "\tvar sense_value_wire: Variant = sense_value",
            "\tif is_nan(sense_value):",
            "\t\tsense_value_wire = null",
            '\treturn {"source_owner": "PortGame.source_block_sense_content_state", "source": "core/src/mindustry/world/Block.java", "override_expr": "@Override", "method": "public double sense(Content content){", "item_instanceof_expr": "if(content instanceof Item item){", "infinite_resources_return_expr": "if(state.rules.infiniteResources) return 0;", "requirements_loop_expr": "for(ItemStack r : requirements){", "item_match_guard_expr": "if(r.item == item){", "amount_return_expr": "return Math.round(r.amount * state.rules.buildCostMultiplier);", "missing_item_return_expr": "return 0f;", "invalid_return_expr": "return Double.NaN;", "content_type": content_type, "content_item": content_item, "state_rules_infinite_resources": state_rules_infinite_resources, "requirements": requirements, "build_cost_multiplier": build_cost_multiplier, "matched_requirement_index": matched_requirement_index, "matched_requirement": matched_requirement, "matched_amount": matched_amount, "sense_value": sense_value_wire, "sense_value_is_nan": is_nan(sense_value)}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "senseObject"
        and method.get("parameters")
        and method["parameters"][0].get("type") == "LAccess"
    ):
        return [
            '\tvar sensor: String = str(_args[0] if _args.size() > 0 else "")',
            "\tvar block_name: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar no_sensed: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar sense_object_value: Variant = no_sensed",
            '\tif sensor == "name":',
            "\t\tsense_object_value = block_name",
            '\treturn {"source_owner": "PortGame.source_block_sense_object_state", "source": "core/src/mindustry/world/Block.java", "override_expr": "@Override", "method": "public Object senseObject(LAccess sensor){", "name_guard_expr": "if(sensor == LAccess.name) return name;", "default_return_expr": "return noSensed;", "sensor": sensor, "block_name": block_name, "no_sensed": no_sensed, "sense_object_value": sense_object_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "block"
    ):
        return [
            "\tvar build_block: Variant = _args[0] if _args.size() > 0 else null",
            '\treturn {"source_owner": "PortGame.source_build_payload_block_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "method": "public Block block(){", "return_expr": "return build.block;", "build_block": build_block}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "showOverlay"
        and len(method.get("parameters", [])) == 1
        and method["parameters"][0].get("type") == "TextureRegion"
    ):
        return [
            "\tvar icon: Variant = _args[0] if _args.size() > 0 else null",
            '\treturn {"source_owner": "PortGame.source_unit_payload_show_overlay_texture_region_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "overlay_time_field_expr": "public float overlayTime = 0f;", "overlay_region_field_expr": "public @Nullable TextureRegion overlayRegion;", "method": "public void showOverlay(TextureRegion icon){", "overlay_region_assign_expr": "overlayRegion = icon;", "overlay_time_assign_expr": "overlayTime = 1f;", "icon": icon, "overlayRegion_after": icon, "overlayTime_after": 1.0}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "showOverlay"
        and len(method.get("parameters", [])) == 1
        and method["parameters"][0].get("type") == "TextureRegionDrawable"
    ):
        return [
            "\tvar icon_null: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar headless: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar region: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar returned: bool = icon_null or headless",
            "\tvar overlay_region_after: Variant = null",
            "\tvar overlay_time_after: Variant = null",
            "\tvar delegate_call: Variant = null",
            "\tif not returned:",
            "\t\toverlay_region_after = region",
            "\t\toverlay_time_after = 1.0",
            '\t\tdelegate_call = {"call": "showOverlay(icon.getRegion());", "region": region}',
            '\treturn {"source_owner": "PortGame.source_unit_payload_show_overlay_drawable_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "import_expr": "import static mindustry.Vars.*;", "method": "public void showOverlay(TextureRegionDrawable icon){", "guard_expr": "if(icon == null || headless) return;", "delegate_expr": "showOverlay(icon.getRegion());", "icon_null": icon_null, "headless": headless, "region": region, "returned": returned, "get_region_called": not returned, "show_overlay_called": not returned, "delegate_call": delegate_call, "overlayRegion_after": overlay_region_after, "overlayTime_after": overlay_time_after}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "contentEquals"
    ):
        return [
            "\tvar other_is_unit_payload: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar other_unit_type: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar unit_type: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar content_equals: bool = other_is_unit_payload and other_unit_type == unit_type",
            '\treturn {"source_owner": "PortGame.source_unit_payload_content_equals_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public boolean contentEquals(Payload other){", "return_expr": "return other instanceof UnitPayload up && up.unit.type == unit.type;", "other_is_unit_payload": other_is_unit_payload, "other_unit_type": other_unit_type, "unit_type": unit_type, "content_equals": content_equals}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "update"
    ):
        return [
            "\tvar unit_type: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar unit: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar unit_holder: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar building_holder: Variant = _args[3] if _args.size() > 3 else null",
            "\tvar update_payload_called: bool = true",
            '\tvar update_payload_call: Dictionary = {"call": "unit.type.updatePayload(unit, unitHolder, buildingHolder);", "unit_type": unit_type, "unit": unit, "unitHolder": unit_holder, "buildingHolder": building_holder}',
            '\treturn {"source_owner": "PortGame.source_unit_payload_update_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public void update(@Nullable Unit unitHolder, @Nullable Building buildingHolder){", "update_payload_expr": "unit.type.updatePayload(unit, unitHolder, buildingHolder);", "unit_type": unit_type, "unit": unit, "unitHolder": unit_holder, "buildingHolder": building_holder, "update_payload_called": update_payload_called, "update_payload_call": update_payload_call}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "content"
    ):
        return [
            "\tvar unit_type: Variant = _args[0] if _args.size() > 0 else null",
            '\treturn {"source_owner": "PortGame.source_unit_payload_content_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public UnlockableContent content(){", "return_expr": "return unit.type;", "unit_type": unit_type, "content": unit_type}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "requirements"
    ):
        return [
            "\tvar unit_type: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar total_requirements: Variant = _args[1] if _args.size() > 1 else []",
            '\tvar get_total_requirements_call: Dictionary = {"call": "unit.type.getTotalRequirements();", "unit_type": unit_type, "requirements": total_requirements}',
            '\treturn {"source_owner": "PortGame.source_unit_payload_requirements_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public ItemStack[] requirements(){", "return_expr": "return unit.type.getTotalRequirements();", "unit_type": unit_type, "requirements": total_requirements, "get_total_requirements_call": get_total_requirements_call}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "buildTime"
    ):
        return [
            "\tvar unit_type: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar build_time: float = float(_args[1] if _args.size() > 1 else 0.0)",
            '\tvar get_build_time_call: Dictionary = {"call": "unit.type.getBuildTime();", "unit_type": unit_type, "buildTime": build_time}',
            '\treturn {"source_owner": "PortGame.source_unit_payload_build_time_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public float buildTime(){", "return_expr": "return unit.type.getBuildTime();", "unit_type": unit_type, "buildTime": build_time, "get_build_time_call": get_build_time_call}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "write"
    ):
        return [
            "\tvar payload_unit: int = int(_args[0] if _args.size() > 0 else 0)",
            "\tvar unit_class_id: int = int(_args[1] if _args.size() > 1 else 0)",
            '\tvar write_calls: Array = [{"call": "write.b(payloadUnit);", "method": "write.b", "value": payload_unit}, {"call": "write.b(unit.classId());", "method": "write.b", "value": unit_class_id}, {"call": "unit.write(write);", "method": "unit.write", "called": true}]',
            '\treturn {"source_owner": "PortGame.source_unit_payload_write_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public void write(Writes write){", "payload_unit_write_expr": "write.b(payloadUnit);", "unit_class_id_write_expr": "write.b(unit.classId());", "unit_write_expr": "unit.write(write);", "payload_unit": payload_unit, "unit_class_id": unit_class_id, "unit_write_called": true, "write_calls": write_calls}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "set"
    ):
        return [
            "\tvar x: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar y: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar rotation_value: float = float(_args[2] if _args.size() > 2 else 0.0)",
            '\tvar set_call: Dictionary = {"call": "unit.set(x, y);", "x": x, "y": y}',
            '\treturn {"source_owner": "PortGame.source_unit_payload_set_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public void set(float x, float y, float rotation){", "set_expr": "unit.set(x, y);", "rotation_assign_expr": "unit.rotation = rotation;", "x": x, "y": y, "rotation": rotation_value, "set_called": true, "set_call": set_call}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "x"
    ):
        return [
            "\tvar unit_x: float = float(_args[0] if _args.size() > 0 else 0.0)",
            '\treturn {"source_owner": "PortGame.source_unit_payload_x_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public float x(){", "return_expr": "return unit.x;", "unit_x": unit_x, "x": unit_x}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "y"
    ):
        return [
            "\tvar unit_y: float = float(_args[0] if _args.size() > 0 else 0.0)",
            '\treturn {"source_owner": "PortGame.source_unit_payload_y_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public float y(){", "return_expr": "return unit.y;", "unit_y": unit_y, "y": unit_y}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "rotation"
    ):
        return [
            "\tvar unit_rotation: float = float(_args[0] if _args.size() > 0 else 0.0)",
            '\treturn {"source_owner": "PortGame.source_unit_payload_rotation_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public float rotation(){", "return_expr": "return unit.rotation;", "unit_rotation": unit_rotation, "rotation": unit_rotation}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "size"
    ):
        return [
            "\tvar unit_hit_size: float = float(_args[0] if _args.size() > 0 else 0.0)",
            '\treturn {"source_owner": "PortGame.source_unit_payload_size_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public float size(){", "return_expr": "return unit.hitSize;", "unit_hit_size": unit_hit_size, "size": unit_hit_size}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "dump"
    ):
        field_names = {field.get("name") for field in type_entry.get("fields", [])}
        if {"overlayTime", "overlayRegion"}.issubset(field_names):
            source_text = str(java_file.get("_source_text", ""))
            if "if(Vars.net.client()) return true;" not in source_text:
                return [
                    "\tvar unit_type_null: bool = bool(_args[0] if _args.size() > 0 else false)",
                    "\tvar units_can_create: bool = bool(_args[1] if _args.size() > 1 else true)",
                    "\tvar solid_present: bool = bool(_args[2] if _args.size() > 2 else false)",
                    "\tvar unit_rotation: float = float(_args[3] if _args.size() > 3 else 0.0)",
                    "\tvar unit_x: float = float(_args[4] if _args.size() > 4 else 0.0)",
                    "\tvar unit_y: float = float(_args[5] if _args.size() > 5 else 0.0)",
                    "\tvar solid_solid: bool = bool(_args[6] if _args.size() > 6 else false)",
                    "\tvar unit_type_flying: bool = bool(_args[7] if _args.size() > 7 else false)",
                    "\tvar unit_physic_size: float = float(_args[8] if _args.size() > 8 else 0.0)",
                    "\tvar units_count: int = int(_args[9] if _args.size() > 9 else 0)",
                    "\tvar can_create_evaluated: bool = not unit_type_null",
                    "\tvar can_create_guard: bool = can_create_evaluated and not units_can_create",
                    "\tvar before_solid_returned: bool = unit_type_null or can_create_guard",
                    "\tvar solid_evaluated: bool = not before_solid_returned",
                    "\tvar solid_present_guard: bool = solid_evaluated and solid_present",
                    "\tvar _source_arc_angles_trns_vec := func(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:",
                    "\t\tvar radians := deg_to_rad(angle_degrees)",
                    "\t\tvar cos_value := cos(radians)",
                    "\t\tvar sin_value := sin(radians)",
                    '\t\treturn {"x": x_value * cos_value - y_value * sin_value, "y": x_value * sin_value + y_value * cos_value, "angle": angle_degrees, "source": "rv.set(x, y).rotate(angle)", "vec2RotateSource": "newX = this.x * cos - this.y * sin; newY = this.x * sin + this.y * cos"}',
                    "\tvar source_tilesize: float = 8.0",
                    '\tvar trns_vec: Dictionary = _source_arc_angles_trns_vec.call(unit_rotation, 1.0, 0.0) if solid_present_guard else {"x": 0.0, "y": 0.0}',
                    '\tvar tx: int = int(round((unit_x + float(trns_vec.get("x", 0.0))) / source_tilesize)) if solid_present_guard else 0',
                    '\tvar ty: int = int(round((unit_y + float(trns_vec.get("y", 0.0))) / source_tilesize)) if solid_present_guard else 0',
                    "\tvar solid_solid_evaluated: bool = solid_present_guard",
                    "\tvar solid_guard: bool = solid_solid_evaluated and solid_solid",
                    "\tvar before_overlap_returned: bool = before_solid_returned or solid_guard",
                    "\tvar overlap_evaluated: bool = not before_overlap_returned",
                    "\tvar units_count_evaluated: bool = overlap_evaluated and not unit_type_flying",
                    "\tvar overlap_radius: float = unit_physic_size * 1.05 if units_count_evaluated else 0.0",
                    "\tvar overlap_guard: bool = units_count_evaluated and units_count > 0",
                    "\tvar returned: bool = before_overlap_returned or overlap_guard",
                    "\tvar dump_result: Variant = null",
                    "\tif unit_type_null:",
                    "\t\tdump_result = true",
                    "\telif can_create_guard:",
                    "\t\tdump_result = false",
                    "\telif solid_guard:",
                    "\t\tdump_result = false",
                    "\telif overlap_guard:",
                    "\t\tdump_result = false",
                    "\tvar overlayTime_after: float = 1.0 if can_create_guard else 0.0",
                    "\tvar overlayRegion_after: Variant = null",
                    "\tvar solid_call: Dictionary = {}",
                    "\tif solid_solid_evaluated:",
                    '\t\tsolid_call = {"call": "solid.solid(tx, ty)", "tx": tx, "ty": ty, "result": solid_solid}',
                    "\tvar units_count_call: Dictionary = {}",
                    "\tif units_count_evaluated:",
                    '\t\tunits_count_call = {"call": "Units.count(unit.x, unit.y, unit.physicSize() * 1.05f, o -> o.isGrounded() && (o.type.allowLegStep == unit.type.allowLegStep))", "x": unit_x, "y": unit_y, "radius": overlap_radius, "result": units_count}',
                    "\tvar deferred_remaining_dump: bool = not returned",
                    '\treturn {"source_owner": "PortGame.source_unit_payload_dump_overlap_guard_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "arc_vec2_source": "arc-core/src/arc/math/geom/Vec2.java", "world_source": "core/src/mindustry/core/World.java", "vars_source": "core/src/mindustry/Vars.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "field_overlay_time_expr": "public float overlayTime = 0f;", "field_overlay_region_expr": "public @Nullable TextureRegion overlayRegion;", "override_expr": "@Override", "method": "public boolean dump(){", "todo_comment_expr": "//TODO should not happen", "type_null_guard_expr": "if(unit.type == null) return true;", "can_create_guard_expr": "if(!Units.canCreate(unit.team, unit.type)){", "overlay_time_assign_expr": "overlayTime = 1f;", "overlay_region_assign_expr": "overlayRegion = null;", "solidity_comment_expr": "//check if unit can be dumped here", "solid_assign_expr": "SolidPred solid = unit.solidity();", "solid_guard_expr": "if(solid != null){", "trns_expr": "Tmp.v1.trns(unit.rotation, 1f);", "vec2_trns_amount_expr": "public Vec2 trns(float angle, float amount){", "vec2_trns_amount_return_expr": "return set(amount, 0).rotate(angle);", "tile_assign_expr": "int tx = World.toTile(unit.x + Tmp.v1.x), ty = World.toTile(unit.y + Tmp.v1.y);", "world_to_tile_method": "public static int toTile(float coord){", "world_to_tile_return": "return Math.round(coord / tilesize);", "vars_tilesize_field": "public static final int tilesize = 8;", "solid_block_comment_expr": "//cannot dump on solid blocks", "solid_solid_guard_expr": "if(solid.solid(tx, ty)) return false;", "overlap_comment_expr": "//cannot dump when there\'s a lot of overlap going on", "overlap_guard_expr": "if(!unit.type.flying && Units.count(unit.x, unit.y, unit.physicSize() * 1.05f, o -> o.isGrounded() && (o.type.allowLegStep == unit.type.allowLegStep)) > 0){", "unit_type_flying_expr": "unit.type.flying", "units_count_expr": "Units.count(unit.x, unit.y, unit.physicSize() * 1.05f, o -> o.isGrounded() && (o.type.allowLegStep == unit.type.allowLegStep))", "physic_size_expr": "unit.physicSize()", "radius_multiplier_expr": "1.05f", "predicate_is_grounded_expr": "o.isGrounded()", "predicate_allow_leg_step_expr": "o.type.allowLegStep == unit.type.allowLegStep", "return_false_expr": "return false;", "client_dumping_comment_expr": "//no client dumping", "unit_type_null": unit_type_null, "units_can_create": units_can_create, "solid_present": solid_present, "unit_rotation": unit_rotation, "unit_x": unit_x, "unit_y": unit_y, "solid_solid": solid_solid, "unit_type_flying": unit_type_flying, "unit_physic_size": unit_physic_size, "units_count": units_count, "can_create_evaluated": can_create_evaluated, "can_create_guard": can_create_guard, "before_solid_returned": before_solid_returned, "solid_evaluated": solid_evaluated, "solid_present_guard": solid_present_guard, "trns_vec": trns_vec, "tx": tx, "ty": ty, "solid_solid_evaluated": solid_solid_evaluated, "solid_call": solid_call, "solid_guard": solid_guard, "before_overlap_returned": before_overlap_returned, "overlap_evaluated": overlap_evaluated, "units_count_evaluated": units_count_evaluated, "units_count_call": units_count_call, "overlap_radius": overlap_radius, "overlap_guard": overlap_guard, "returned": returned, "dump": dump_result, "overlayTime_after": overlayTime_after, "overlayRegion_after": overlayRegion_after, "deferred_remaining_dump": deferred_remaining_dump}',
                ]
            if "Units.notifyUnitSpawn(unit);" in source_text:
                return [
                    "\tvar unit_type_null: bool = bool(_args[0] if _args.size() > 0 else false)",
                    "\tvar units_can_create: bool = bool(_args[1] if _args.size() > 1 else true)",
                    "\tvar solid_present: bool = bool(_args[2] if _args.size() > 2 else false)",
                    "\tvar unit_rotation: float = float(_args[3] if _args.size() > 3 else 0.0)",
                    "\tvar unit_x: float = float(_args[4] if _args.size() > 4 else 0.0)",
                    "\tvar unit_y: float = float(_args[5] if _args.size() > 5 else 0.0)",
                    "\tvar solid_solid: bool = bool(_args[6] if _args.size() > 6 else false)",
                    "\tvar unit_type_flying: bool = bool(_args[7] if _args.size() > 7 else false)",
                    "\tvar unit_physic_size: float = float(_args[8] if _args.size() > 8 else 0.0)",
                    "\tvar units_count: int = int(_args[9] if _args.size() > 9 else 0)",
                    "\tvar net_client: bool = bool(_args[10] if _args.size() > 10 else false)",
                    "\tvar range_x: float = float(_args[11] if _args.size() > 11 else 0.0)",
                    "\tvar range_y: float = float(_args[12] if _args.size() > 12 else 0.0)",
                    "\tvar unit_id: Variant = _args[13] if _args.size() > 13 else null",
                    "\tvar can_create_evaluated: bool = not unit_type_null",
                    "\tvar can_create_guard: bool = can_create_evaluated and not units_can_create",
                    "\tvar before_solid_returned: bool = unit_type_null or can_create_guard",
                    "\tvar solid_evaluated: bool = not before_solid_returned",
                    "\tvar solid_present_guard: bool = solid_evaluated and solid_present",
                    "\tvar _source_arc_angles_trns_vec := func(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:",
                    "\t\tvar radians := deg_to_rad(angle_degrees)",
                    "\t\tvar cos_value := cos(radians)",
                    "\t\tvar sin_value := sin(radians)",
                    '\t\treturn {"x": x_value * cos_value - y_value * sin_value, "y": x_value * sin_value + y_value * cos_value, "angle": angle_degrees, "source": "rv.set(x, y).rotate(angle)", "vec2RotateSource": "newX = this.x * cos - this.y * sin; newY = this.x * sin + this.y * cos"}',
                    "\tvar source_tilesize: float = 8.0",
                    '\tvar trns_vec: Dictionary = _source_arc_angles_trns_vec.call(unit_rotation, 1.0, 0.0) if solid_present_guard else {"x": 0.0, "y": 0.0}',
                    '\tvar tx: int = int(round((unit_x + float(trns_vec.get("x", 0.0))) / source_tilesize)) if solid_present_guard else 0',
                    '\tvar ty: int = int(round((unit_y + float(trns_vec.get("y", 0.0))) / source_tilesize)) if solid_present_guard else 0',
                    "\tvar solid_solid_evaluated: bool = solid_present_guard",
                    "\tvar solid_guard: bool = solid_solid_evaluated and solid_solid",
                    "\tvar before_overlap_returned: bool = before_solid_returned or solid_guard",
                    "\tvar overlap_evaluated: bool = not before_overlap_returned",
                    "\tvar units_count_evaluated: bool = overlap_evaluated and not unit_type_flying",
                    "\tvar overlap_radius: float = unit_physic_size * 1.05 if units_count_evaluated else 0.0",
                    "\tvar overlap_guard: bool = units_count_evaluated and units_count > 0",
                    "\tvar before_client_returned: bool = before_overlap_returned or overlap_guard",
                    "\tvar net_client_evaluated: bool = not before_client_returned",
                    "\tvar client_guard: bool = net_client_evaluated and net_client",
                    "\tvar before_spawn_returned: bool = before_client_returned or client_guard",
                    "\tvar spawn_evaluated: bool = not before_spawn_returned",
                    "\tvar returned: bool = before_spawn_returned or spawn_evaluated",
                    "\tvar dump_result: Variant = null",
                    "\tif unit_type_null:",
                    "\t\tdump_result = true",
                    "\telif can_create_guard:",
                    "\t\tdump_result = false",
                    "\telif solid_guard:",
                    "\t\tdump_result = false",
                    "\telif overlap_guard:",
                    "\t\tdump_result = false",
                    "\telif client_guard:",
                    "\t\tdump_result = true",
                    "\tif spawn_evaluated:",
                    "\t\tdump_result = true",
                    "\tvar overlayTime_after: float = 1.0 if can_create_guard else 0.0",
                    "\tvar overlayRegion_after: Variant = null",
                    "\tvar solid_call: Dictionary = {}",
                    "\tif solid_solid_evaluated:",
                    '\t\tsolid_call = {"call": "solid.solid(tx, ty)", "tx": tx, "ty": ty, "result": solid_solid}',
                    "\tvar units_count_call: Dictionary = {}",
                    "\tif units_count_evaluated:",
                    '\t\tunits_count_call = {"call": "Units.count(unit.x, unit.y, unit.physicSize() * 1.05f, o -> o.isGrounded() && (o.type.allowLegStep == unit.type.allowLegStep))", "x": unit_x, "y": unit_y, "radius": overlap_radius, "result": units_count}',
                    "\tvar velocity_add_call: Dictionary = {}",
                    "\tvar unit_add_called: bool = false",
                    "\tvar unit_unloaded_called: bool = false",
                    "\tvar event_fire_call: Dictionary = {}",
                    "\tvar notify_unit_spawn_call: Dictionary = {}",
                    "\tif spawn_evaluated:",
                    '\t\tvelocity_add_call = {"call": "unit.vel.add(Mathf.range(0.5f), Mathf.range(0.5f));", "x": range_x, "y": range_y, "unit": unit_id}',
                    "\t\tunit_add_called = true",
                    "\t\tunit_unloaded_called = true",
                    '\t\tevent_fire_call = {"call": "Events.fire(new UnitUnloadEvent(unit));", "event": "new UnitUnloadEvent(unit)", "unit": unit_id}',
                    '\t\tnotify_unit_spawn_call = {"call": "Units.notifyUnitSpawn(unit);", "unit": unit_id}',
                    "\tvar deferred_remaining_dump: bool = false",
                    '\tvar state: Dictionary = {"source_owner": "PortGame.source_unit_payload_dump_spawn_side_effects_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "arc_vec2_source": "arc-core/src/arc/math/geom/Vec2.java", "arc_mathf_source": "arc-core/src/arc/math/Mathf.java", "world_source": "core/src/mindustry/core/World.java", "vars_source": "core/src/mindustry/Vars.java", "units_source": "core/src/mindustry/entities/Units.java", "event_type_source": "core/src/mindustry/game/EventType.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "field_overlay_time_expr": "public float overlayTime = 0f;", "field_overlay_region_expr": "public @Nullable TextureRegion overlayRegion;", "override_expr": "@Override", "method": "public boolean dump(){", "todo_comment_expr": "//TODO should not happen", "type_null_guard_expr": "if(unit.type == null) return true;", "can_create_guard_expr": "if(!Units.canCreate(unit.team, unit.type)){", "overlay_time_assign_expr": "overlayTime = 1f;", "overlay_region_assign_expr": "overlayRegion = null;", "solidity_comment_expr": "//check if unit can be dumped here", "solid_assign_expr": "SolidPred solid = unit.solidity();", "solid_guard_expr": "if(solid != null){", "trns_expr": "Tmp.v1.trns(unit.rotation, 1f);", "vec2_trns_amount_expr": "public Vec2 trns(float angle, float amount){", "vec2_trns_amount_return_expr": "return set(amount, 0).rotate(angle);", "tile_assign_expr": "int tx = World.toTile(unit.x + Tmp.v1.x), ty = World.toTile(unit.y + Tmp.v1.y);", "world_to_tile_method": "public static int toTile(float coord){", "world_to_tile_return": "return Math.round(coord / tilesize);", "vars_tilesize_field": "public static final int tilesize = 8;", "solid_block_comment_expr": "//cannot dump on solid blocks", "solid_solid_guard_expr": "if(solid.solid(tx, ty)) return false;", "overlap_comment_expr": "//cannot dump when there\'s a lot of overlap going on", "overlap_guard_expr": "if(!unit.type.flying && Units.count(unit.x, unit.y, unit.physicSize() * 1.05f, o -> o.isGrounded() && (o.type.allowLegStep == unit.type.allowLegStep)) > 0){", "unit_type_flying_expr": "unit.type.flying", "units_count_expr": "Units.count(unit.x, unit.y, unit.physicSize() * 1.05f, o -> o.isGrounded() && (o.type.allowLegStep == unit.type.allowLegStep))", "physic_size_expr": "unit.physicSize()", "radius_multiplier_expr": "1.05f", "predicate_is_grounded_expr": "o.isGrounded()", "predicate_allow_leg_step_expr": "o.type.allowLegStep == unit.type.allowLegStep", "return_false_expr": "return false;", "client_dumping_comment_expr": "//no client dumping", "net_client_guard_expr": "if(Vars.net.client()) return true;", "vars_net_field": "public static Net net;", "return_true_expr": "return true;", "prevents_stacking_comment_expr": "//prevents stacking", "unit_type_null": unit_type_null, "units_can_create": units_can_create, "solid_present": solid_present, "unit_rotation": unit_rotation, "unit_x": unit_x, "unit_y": unit_y, "solid_solid": solid_solid, "unit_type_flying": unit_type_flying, "unit_physic_size": unit_physic_size, "units_count": units_count, "net_client": net_client, "range_x": range_x, "range_y": range_y, "unit_id": unit_id, "can_create_evaluated": can_create_evaluated, "can_create_guard": can_create_guard, "before_solid_returned": before_solid_returned, "solid_evaluated": solid_evaluated, "solid_present_guard": solid_present_guard, "trns_vec": trns_vec, "tx": tx, "ty": ty, "solid_solid_evaluated": solid_solid_evaluated, "solid_call": solid_call, "solid_guard": solid_guard, "before_overlap_returned": before_overlap_returned, "overlap_evaluated": overlap_evaluated, "units_count_evaluated": units_count_evaluated, "units_count_call": units_count_call, "overlap_radius": overlap_radius, "overlap_guard": overlap_guard, "before_client_returned": before_client_returned, "net_client_evaluated": net_client_evaluated, "client_guard": client_guard, "before_spawn_returned": before_spawn_returned, "spawn_evaluated": spawn_evaluated, "velocity_add_call": velocity_add_call, "unit_add_called": unit_add_called, "unit_unloaded_called": unit_unloaded_called, "event_fire_call": event_fire_call, "notify_unit_spawn_call": notify_unit_spawn_call, "returned": returned, "dump": dump_result, "overlayTime_after": overlayTime_after, "overlayRegion_after": overlayRegion_after, "deferred_remaining_dump": deferred_remaining_dump}',
                    '\tstate["velocity_add_expr"] = "unit.vel.add(Mathf.range(0.5f), Mathf.range(0.5f));"',
                    '\tstate["mathf_range_float_method"] = "public static float range(float range){"',
                    '\tstate["mathf_range_float_return"] = "return random(-range, range);"',
                    '\tstate["unit_add_expr"] = "unit.add();"',
                    '\tstate["unit_unloaded_expr"] = "unit.unloaded();"',
                    '\tstate["event_fire_expr"] = "Events.fire(new UnitUnloadEvent(unit));"',
                    '\tstate["unit_unload_event_comment"] = "/** Called when a unit is dumped from any payload block. */"',
                    '\tstate["unit_unload_event_class"] = "public static class UnitUnloadEvent{"',
                    '\tstate["unit_unload_event_constructor"] = "public UnitUnloadEvent(Unit unit){"',
                    '\tstate["notify_unit_spawn_expr"] = "Units.notifyUnitSpawn(unit);"',
                    '\tstate["notify_unit_spawn_method"] = "public static void notifyUnitSpawn(Unit unit){"',
                    '\tstate["notify_unit_spawn_guard"] = "if(net.server()){"',
                    '\tstate["final_return_true_expr"] = "return true;"',
                    "\treturn state",
                ]
            return [
                "\tvar unit_type_null: bool = bool(_args[0] if _args.size() > 0 else false)",
                "\tvar units_can_create: bool = bool(_args[1] if _args.size() > 1 else true)",
                "\tvar solid_present: bool = bool(_args[2] if _args.size() > 2 else false)",
                "\tvar unit_rotation: float = float(_args[3] if _args.size() > 3 else 0.0)",
                "\tvar unit_x: float = float(_args[4] if _args.size() > 4 else 0.0)",
                "\tvar unit_y: float = float(_args[5] if _args.size() > 5 else 0.0)",
                "\tvar solid_solid: bool = bool(_args[6] if _args.size() > 6 else false)",
                "\tvar unit_type_flying: bool = bool(_args[7] if _args.size() > 7 else false)",
                "\tvar unit_physic_size: float = float(_args[8] if _args.size() > 8 else 0.0)",
                "\tvar units_count: int = int(_args[9] if _args.size() > 9 else 0)",
                "\tvar net_client: bool = bool(_args[10] if _args.size() > 10 else false)",
                "\tvar can_create_evaluated: bool = not unit_type_null",
                "\tvar can_create_guard: bool = can_create_evaluated and not units_can_create",
                "\tvar before_solid_returned: bool = unit_type_null or can_create_guard",
                "\tvar solid_evaluated: bool = not before_solid_returned",
                "\tvar solid_present_guard: bool = solid_evaluated and solid_present",
                "\tvar _source_arc_angles_trns_vec := func(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:",
                "\t\tvar radians := deg_to_rad(angle_degrees)",
                "\t\tvar cos_value := cos(radians)",
                "\t\tvar sin_value := sin(radians)",
                '\t\treturn {"x": x_value * cos_value - y_value * sin_value, "y": x_value * sin_value + y_value * cos_value, "angle": angle_degrees, "source": "rv.set(x, y).rotate(angle)", "vec2RotateSource": "newX = this.x * cos - this.y * sin; newY = this.x * sin + this.y * cos"}',
                "\tvar source_tilesize: float = 8.0",
                '\tvar trns_vec: Dictionary = _source_arc_angles_trns_vec.call(unit_rotation, 1.0, 0.0) if solid_present_guard else {"x": 0.0, "y": 0.0}',
                '\tvar tx: int = int(round((unit_x + float(trns_vec.get("x", 0.0))) / source_tilesize)) if solid_present_guard else 0',
                '\tvar ty: int = int(round((unit_y + float(trns_vec.get("y", 0.0))) / source_tilesize)) if solid_present_guard else 0',
                "\tvar solid_solid_evaluated: bool = solid_present_guard",
                "\tvar solid_guard: bool = solid_solid_evaluated and solid_solid",
                "\tvar before_overlap_returned: bool = before_solid_returned or solid_guard",
                "\tvar overlap_evaluated: bool = not before_overlap_returned",
                "\tvar units_count_evaluated: bool = overlap_evaluated and not unit_type_flying",
                "\tvar overlap_radius: float = unit_physic_size * 1.05 if units_count_evaluated else 0.0",
                "\tvar overlap_guard: bool = units_count_evaluated and units_count > 0",
                "\tvar before_client_returned: bool = before_overlap_returned or overlap_guard",
                "\tvar net_client_evaluated: bool = not before_client_returned",
                "\tvar client_guard: bool = net_client_evaluated and net_client",
                "\tvar returned: bool = before_client_returned or client_guard",
                "\tvar dump_result: Variant = null",
                "\tif unit_type_null:",
                "\t\tdump_result = true",
                "\telif can_create_guard:",
                "\t\tdump_result = false",
                "\telif solid_guard:",
                "\t\tdump_result = false",
                "\telif overlap_guard:",
                "\t\tdump_result = false",
                "\telif client_guard:",
                "\t\tdump_result = true",
                "\tvar overlayTime_after: float = 1.0 if can_create_guard else 0.0",
                "\tvar overlayRegion_after: Variant = null",
                "\tvar solid_call: Dictionary = {}",
                "\tif solid_solid_evaluated:",
                '\t\tsolid_call = {"call": "solid.solid(tx, ty)", "tx": tx, "ty": ty, "result": solid_solid}',
                "\tvar units_count_call: Dictionary = {}",
                "\tif units_count_evaluated:",
                '\t\tunits_count_call = {"call": "Units.count(unit.x, unit.y, unit.physicSize() * 1.05f, o -> o.isGrounded() && (o.type.allowLegStep == unit.type.allowLegStep))", "x": unit_x, "y": unit_y, "radius": overlap_radius, "result": units_count}',
                "\tvar deferred_remaining_dump: bool = not returned",
                '\treturn {"source_owner": "PortGame.source_unit_payload_dump_no_client_guard_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "arc_vec2_source": "arc-core/src/arc/math/geom/Vec2.java", "world_source": "core/src/mindustry/core/World.java", "vars_source": "core/src/mindustry/Vars.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "field_overlay_time_expr": "public float overlayTime = 0f;", "field_overlay_region_expr": "public @Nullable TextureRegion overlayRegion;", "override_expr": "@Override", "method": "public boolean dump(){", "todo_comment_expr": "//TODO should not happen", "type_null_guard_expr": "if(unit.type == null) return true;", "can_create_guard_expr": "if(!Units.canCreate(unit.team, unit.type)){", "overlay_time_assign_expr": "overlayTime = 1f;", "overlay_region_assign_expr": "overlayRegion = null;", "solidity_comment_expr": "//check if unit can be dumped here", "solid_assign_expr": "SolidPred solid = unit.solidity();", "solid_guard_expr": "if(solid != null){", "trns_expr": "Tmp.v1.trns(unit.rotation, 1f);", "vec2_trns_amount_expr": "public Vec2 trns(float angle, float amount){", "vec2_trns_amount_return_expr": "return set(amount, 0).rotate(angle);", "tile_assign_expr": "int tx = World.toTile(unit.x + Tmp.v1.x), ty = World.toTile(unit.y + Tmp.v1.y);", "world_to_tile_method": "public static int toTile(float coord){", "world_to_tile_return": "return Math.round(coord / tilesize);", "vars_tilesize_field": "public static final int tilesize = 8;", "solid_block_comment_expr": "//cannot dump on solid blocks", "solid_solid_guard_expr": "if(solid.solid(tx, ty)) return false;", "overlap_comment_expr": "//cannot dump when there\'s a lot of overlap going on", "overlap_guard_expr": "if(!unit.type.flying && Units.count(unit.x, unit.y, unit.physicSize() * 1.05f, o -> o.isGrounded() && (o.type.allowLegStep == unit.type.allowLegStep)) > 0){", "unit_type_flying_expr": "unit.type.flying", "units_count_expr": "Units.count(unit.x, unit.y, unit.physicSize() * 1.05f, o -> o.isGrounded() && (o.type.allowLegStep == unit.type.allowLegStep))", "physic_size_expr": "unit.physicSize()", "radius_multiplier_expr": "1.05f", "predicate_is_grounded_expr": "o.isGrounded()", "predicate_allow_leg_step_expr": "o.type.allowLegStep == unit.type.allowLegStep", "return_false_expr": "return false;", "client_dumping_comment_expr": "//no client dumping", "net_client_guard_expr": "if(Vars.net.client()) return true;", "vars_net_field": "public static Net net;", "return_true_expr": "return true;", "prevents_stacking_comment_expr": "//prevents stacking", "unit_type_null": unit_type_null, "units_can_create": units_can_create, "solid_present": solid_present, "unit_rotation": unit_rotation, "unit_x": unit_x, "unit_y": unit_y, "solid_solid": solid_solid, "unit_type_flying": unit_type_flying, "unit_physic_size": unit_physic_size, "units_count": units_count, "net_client": net_client, "can_create_evaluated": can_create_evaluated, "can_create_guard": can_create_guard, "before_solid_returned": before_solid_returned, "solid_evaluated": solid_evaluated, "solid_present_guard": solid_present_guard, "trns_vec": trns_vec, "tx": tx, "ty": ty, "solid_solid_evaluated": solid_solid_evaluated, "solid_call": solid_call, "solid_guard": solid_guard, "before_overlap_returned": before_overlap_returned, "overlap_evaluated": overlap_evaluated, "units_count_evaluated": units_count_evaluated, "units_count_call": units_count_call, "overlap_radius": overlap_radius, "overlap_guard": overlap_guard, "before_client_returned": before_client_returned, "net_client_evaluated": net_client_evaluated, "client_guard": client_guard, "returned": returned, "dump": dump_result, "overlayTime_after": overlayTime_after, "overlayRegion_after": overlayRegion_after, "deferred_remaining_dump": deferred_remaining_dump}',
            ]
        return [
            "\tvar unit_type_null: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar returned: bool = unit_type_null",
            "\tvar dump_result: Variant = null",
            "\tif returned:",
            "\t\tdump_result = true",
            "\tvar deferred_remaining_dump: bool = not returned",
            '\treturn {"source_owner": "PortGame.source_unit_payload_dump_type_null_guard_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public boolean dump(){", "todo_comment_expr": "//TODO should not happen", "guard_expr": "if(unit.type == null) return true;", "return_expr": "return true", "unit_type_null": unit_type_null, "returned": returned, "dump": dump_result, "deferred_remaining_dump": deferred_remaining_dump}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "drawShadow"
    ):
        return [
            "\tvar unit_type_null: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar alpha: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar unit_id: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar returned_early: bool = unit_type_null",
            "\tvar draw_soft_shadow_called: bool = not returned_early",
            "\tvar draw_soft_shadow_call: Dictionary = {}",
            "\tif draw_soft_shadow_called:",
            '\t\tdraw_soft_shadow_call = {"call": "unit.type.drawSoftShadow(unit, alpha);", "unit": unit_id, "alpha": alpha}',
            '\treturn {"source_owner": "PortGame.source_unit_payload_draw_shadow_type_null_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public void drawShadow(float alpha){", "todo_comment_expr": "//TODO should not happen", "type_null_guard_expr": "if(unit.type == null) return;", "draw_soft_shadow_expr": "unit.type.drawSoftShadow(unit, alpha);", "unit_type_null": unit_type_null, "alpha": alpha, "unit_id": unit_id, "returned_early": returned_early, "draw_soft_shadow_called": draw_soft_shadow_called, "draw_soft_shadow_call": draw_soft_shadow_call}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "draw"
    ):
        return [
            "\tvar unit_type_null: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar unit_elevation: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar unit_id: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar overlay_time: float = float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar overlay_region: Variant = _args[4] if _args.size() > 4 else null",
            "\tvar unit_x: float = float(_args[5] if _args.size() > 5 else 0.0)",
            "\tvar unit_y: float = float(_args[6] if _args.size() > 6 else 0.0)",
            "\tvar time_delta: float = float(_args[7] if _args.size() > 7 else 0.0)",
            "\tvar draw_z_before: float = float(_args[8] if _args.size() > 8 else 0.0)",
            "\tvar interp_exp5_out_overlay_time: float = float(_args[9] if _args.size() > 9 else 0.0)",
            "\tvar returned_early: bool = unit_type_null",
            "\tvar elevation_snapshot: float = unit_elevation",
            "\tvar elevation_after_zero: float = 0.0 if not returned_early else unit_elevation",
            '\tvar draw_scl_call: Dictionary = {"sx": 1.0, "sy": 1.0}',
            '\tvar unit_type_draw_call: Dictionary = {"unit": unit_id}',
            "\tvar draw_scl_called: bool = not returned_early",
            "\tvar unit_type_draw_called: bool = not returned_early",
            "\tif returned_early:",
            "\t\tdraw_scl_call = {}",
            "\t\tunit_type_draw_call = {}",
            "\tvar elevation_after_restore: float = elevation_snapshot if not returned_early else unit_elevation",
            "\tvar deferred_remaining_draw: bool = not returned_early",
            "\tif _args.size() <= 1:",
            '\t\treturn {"source_owner": "PortGame.source_unit_payload_draw_type_null_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public void draw(){", "todo_comment_expr": "//TODO should not happen", "type_null_guard_expr": "if(unit.type == null) return;", "next_expr": "float e = unit.elevation;", "unit_type_null": unit_type_null, "returned_early": returned_early, "deferred_remaining_draw": deferred_remaining_draw}',
            "\tif _args.size() <= 3:",
            '\t\treturn {"source_owner": "PortGame.source_unit_payload_draw_elevation_setup_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public void draw(){", "todo_comment_expr": "//TODO should not happen", "type_null_guard_expr": "if(unit.type == null) return;", "elevation_snapshot_expr": "float e = unit.elevation;", "elevation_zero_expr": "unit.elevation = 0f;", "draw_scl_expr": "Draw.scl(1f, 1f);", "unit_type_draw_expr": "unit.type.draw(unit);", "elevation_restore_expr": "unit.elevation = e;", "next_expr": "//draw warning", "unit_type_null": unit_type_null, "unit_elevation": unit_elevation, "unit_id": unit_id, "returned_early": returned_early, "elevation_snapshot": elevation_snapshot, "elevation_after_zero": elevation_after_zero, "draw_scl_called": draw_scl_called, "draw_scl_call": draw_scl_call, "unit_type_draw_called": unit_type_draw_called, "unit_type_draw_call": unit_type_draw_call, "elevation_after_restore": elevation_after_restore, "deferred_remaining_draw": deferred_remaining_draw}',
            "\tvar overlay_duration: float = 40.0",
            "\tvar overlay_guard: bool = (not returned_early) and overlay_time > 0.0",
            "\tvar draw_z_snapshot: float = draw_z_before",
            '\tvar draw_z_warning_call: Dictionary = {"z": "Layer.groundUnit + 1f"} if overlay_guard else {}',
            '\tvar overlay_region_resolved: Variant = overlay_region if overlay_region != null else "Icon.warning.getRegion()"',
            '\tvar draw_color_call: Dictionary = {"color": "Color.scarlet"} if overlay_guard else {}',
            "\tvar draw_alpha_value: float = 0.8 * interp_exp5_out_overlay_time if overlay_guard else 0.0",
            '\tvar draw_alpha_call: Dictionary = {"alpha": draw_alpha_value} if overlay_guard else {}',
            "\tvar warning_size: float = 8.0",
            '\tvar draw_rect_call: Dictionary = {"region": overlay_region_resolved, "x": unit_x, "y": unit_y, "width": warning_size, "height": warning_size} if overlay_guard else {}',
            "\tvar draw_reset_called: bool = overlay_guard",
            "\tvar overlay_time_after: float = maxf(overlay_time - time_delta / overlay_duration, 0.0) if overlay_guard else overlay_time",
            '\tvar draw_z_restore_call: Dictionary = {"z": draw_z_snapshot} if overlay_guard else {}',
            '\treturn {"source_owner": "PortGame.source_unit_payload_draw_overlay_warning_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "overlay_duration_field_expr": "public static final float overlayDuration = 40f;", "overlay_time_field_expr": "public float overlayTime = 0f;", "overlay_region_field_expr": "public @Nullable TextureRegion overlayRegion;", "method": "public void draw(){", "draw_warning_comment_expr": "//draw warning", "overlay_guard_expr": "if(overlayTime > 0){", "draw_z_snapshot_expr": "float z = Draw.z();", "draw_z_warning_expr": "Draw.z(Layer.groundUnit + 1f);", "region_expr": "var region = overlayRegion == null ? Icon.warning.getRegion() : overlayRegion;", "draw_color_expr": "Draw.color(Color.scarlet);", "draw_alpha_expr": "Draw.alpha(0.8f * Interp.exp5Out.apply(overlayTime));", "size_expr": "float size = 8f;", "draw_rect_expr": "Draw.rect(region, unit.x, unit.y, size, size);", "draw_reset_expr": "Draw.reset();", "overlay_time_update_expr": "overlayTime = Math.max(overlayTime - Time.delta/overlayDuration, 0f);", "draw_z_restore_expr": "Draw.z(z);", "unit_type_null": unit_type_null, "unit_elevation": unit_elevation, "unit_id": unit_id, "overlay_time": overlay_time, "overlay_region": overlay_region, "unit_x": unit_x, "unit_y": unit_y, "time_delta": time_delta, "draw_z_before": draw_z_before, "interp_exp5_out_overlay_time": interp_exp5_out_overlay_time, "returned_early": returned_early, "overlay_duration": overlay_duration, "overlay_guard": overlay_guard, "draw_z_snapshot": draw_z_snapshot, "draw_z_warning_call": draw_z_warning_call, "overlay_region_resolved": overlay_region_resolved, "draw_color_call": draw_color_call, "draw_alpha_value": draw_alpha_value, "draw_alpha_call": draw_alpha_call, "warning_size": warning_size, "draw_rect_call": draw_rect_call, "draw_reset_called": draw_reset_called, "overlay_time_after": overlay_time_after, "draw_z_restore_call": draw_z_restore_call, "deferred_remaining_draw": false}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
        and method.get("name") == "icon"
    ):
        return [
            "\tvar unit_type_full_icon: Variant = _args[0] if _args.size() > 0 else null",
            '\treturn {"source_owner": "PortGame.source_unit_payload_icon_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public TextureRegion icon(){", "return_expr": "return unit.type.fullIcon;", "unit_type_full_icon": unit_type_full_icon, "icon": unit_type_full_icon}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BlockProducer.java"
        and type_entry.get("name") == "BlockProducer"
        and method.get("name") == "icons"
    ):
        return [
            "\tvar region: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar out_region: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar top_region: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar icons: Array = [region, out_region, top_region]",
            '\treturn {"source_owner": "PortGame.source_block_producer_icons_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "class_expr": "public abstract class BlockProducer extends PayloadBlock{", "override_expr": "@Override", "method": "public TextureRegion[] icons(){", "return_expr": "return new TextureRegion[]{region, outRegion, topRegion};", "region": region, "out_region": out_region, "top_region": top_region, "icons": icons}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BlockProducer.java"
        and type_entry.get("name") == "BlockProducer"
        and method.get("name") == "drawPlanRegion"
    ):
        return [
            "\tvar region: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar out_region: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar top_region: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar plan_drawx: float = float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar plan_drawy: float = float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar plan_rotation: float = float(_args[5] if _args.size() > 5 else 0.0)",
            "\tvar out_region_rotation: float = plan_rotation * 90.0",
            '\tvar draw_calls: Array = [{"call": "Draw.rect(region, plan.drawx(), plan.drawy());", "region": region, "x": plan_drawx, "y": plan_drawy}, {"call": "Draw.rect(outRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);", "region": out_region, "x": plan_drawx, "y": plan_drawy, "rotation": out_region_rotation}, {"call": "Draw.rect(topRegion, plan.drawx(), plan.drawy());", "region": top_region, "x": plan_drawx, "y": plan_drawy}]',
            '\treturn {"source_owner": "PortGame.source_block_producer_draw_plan_region_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "class_expr": "public abstract class BlockProducer extends PayloadBlock{", "override_expr": "@Override", "method": "public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){", "draw_region_expr": "Draw.rect(region, plan.drawx(), plan.drawy());", "draw_out_region_expr": "Draw.rect(outRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);", "draw_top_region_expr": "Draw.rect(topRegion, plan.drawx(), plan.drawy());", "region": region, "out_region": out_region, "top_region": top_region, "plan_drawx": plan_drawx, "plan_drawy": plan_drawy, "plan_rotation": plan_rotation, "out_region_rotation": out_region_rotation, "draw_calls": draw_calls}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BlockProducer.java"
        and type_entry.get("name") == "BlockProducer"
        and method.get("name") == "setBars"
    ):
        return [
            "\tvar recipe_null: bool = bool(_args[0] if _args.size() > 0 else true)",
            "\tvar entity_progress: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar recipe_build_time: float = float(_args[2] if _args.size() > 2 else 1.0)",
            "\tvar progress_bar_fraction: float = 0.0 if recipe_null else entity_progress / recipe_build_time",
            '\tvar progress_bar_call: Dictionary = {"call": "addBar(\\"progress\\", (BlockProducerBuild entity) -> new Bar(\\"bar.progress\\", Pal.ammo, () -> entity.recipe() == null ? 0f : (entity.progress / entity.recipe().buildTime)));", "name": "progress", "bar_text": "bar.progress", "color": "Pal.ammo", "fraction": progress_bar_fraction}',
            '\treturn {"source_owner": "PortGame.source_block_producer_set_bars_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "class_expr": "public abstract class BlockProducer extends PayloadBlock{", "override_expr": "@Override", "method": "public void setBars(){", "super_set_bars_expr": "super.setBars();", "add_bar_expr": "addBar(\\"progress\\", (BlockProducerBuild entity) -> new Bar(\\"bar.progress\\", Pal.ammo, () -> entity.recipe() == null ? 0f : (entity.progress / entity.recipe().buildTime)));", "bar_text": "bar.progress", "bar_color": "Pal.ammo", "bar_progress_expr": "entity.recipe() == null ? 0f : (entity.progress / entity.recipe().buildTime)", "recipe_null": recipe_null, "entity_progress": entity_progress, "recipe_build_time": recipe_build_time, "super_set_bars_called": true, "progress_bar_added": true, "progress_bar_fraction": progress_bar_fraction, "progress_bar_call": progress_bar_call}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "place"
        and len(method.get("parameters", [])) == 1
    ):
        return [
            "\tvar tile: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar build_block: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar build_team: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar rotation_value: int = 0",
            '\treturn {"source_owner": "PortGame.source_build_payload_place_default_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "method": "public void place(Tile tile){", "delegate_expr": "place(tile, 0);", "tile": tile, "build_block": build_block, "build_team": build_team, "delegated_rotation": rotation_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "place"
        and len(method.get("parameters", [])) == 2
    ):
        return [
            "\tvar tile: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar build_block: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar build_team: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar rotation_value: int = int(_args[3] if _args.size() > 3 else 0)",
            '\tvar set_block_call: Dictionary = {"call": "tile.setBlock(build.block, build.team, rotation, () -> build);", "tile": tile, "block": build_block, "team": build_team, "rotation": rotation_value, "build_supplier": "() -> build"}',
            '\treturn {"source_owner": "PortGame.source_build_payload_place_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "method": "public void place(Tile tile, int rotation){", "set_block_expr": "tile.setBlock(build.block, build.team, rotation, () -> build);", "dropped_expr": "build.dropped();", "tile": tile, "build_block": build_block, "build_team": build_team, "rotation": rotation_value, "set_block_call": set_block_call, "dropped_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "contentEquals"
    ):
        return [
            "\tvar other_is_build_payload: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar other_block: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar build_block: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar content_equals: bool = other_is_build_payload and other_block == build_block",
            '\treturn {"source_owner": "PortGame.source_build_payload_content_equals_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public boolean contentEquals(Payload other){", "return_expr": "return other instanceof BuildPayload bp && bp.block() == build.block;", "other_is_build_payload": other_is_build_payload, "other_block": other_block, "build_block": build_block, "content_equals": content_equals}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "update"
    ):
        return [
            "\tvar unit_holder_present: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar build_block_update_in_units: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar unit_payload_update: bool = bool(_args[2] if _args.size() > 2 else false)",
            "\tvar build_block_always_update_in_units: bool = bool(_args[3] if _args.size() > 3 else false)",
            "\tvar unit_holder: Variant = _args[4] if _args.size() > 4 else null",
            "\tvar building_holder: Variant = _args[5] if _args.size() > 5 else null",
            "\tvar returned: bool = unit_holder_present and ((not build_block_update_in_units) or ((not unit_payload_update) and (not build_block_always_update_in_units)))",
            "\tvar tile_after: Variant = null",
            "\tvar update_payload_called: bool = false",
            "\tvar update_payload_call: Variant = null",
            "\tif not returned:",
            '\t\ttile_after = "emptyTile"',
            "\t\tupdate_payload_called = true",
            '\t\tupdate_payload_call = {"call": "build.updatePayload(unitHolder, buildingHolder);", "unitHolder": unit_holder, "buildingHolder": building_holder}',
            '\treturn {"source_owner": "PortGame.source_build_payload_update_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "import_expr": "import static mindustry.Vars.*;", "override_expr": "@Override", "method": "public void update(@Nullable Unit unitHolder, @Nullable Building buildingHolder){", "guard_expr": "if(unitHolder != null && (!build.block.updateInUnits || (!state.rules.unitPayloadUpdate && !build.block.alwaysUpdateInUnits))) return;", "tile_assign_expr": "build.tile = emptyTile;", "update_payload_expr": "build.updatePayload(unitHolder, buildingHolder);", "unit_holder_present": unit_holder_present, "build_block_update_in_units": build_block_update_in_units, "unit_payload_update": unit_payload_update, "build_block_always_update_in_units": build_block_always_update_in_units, "unitHolder": unit_holder, "buildingHolder": building_holder, "returned": returned, "tile_after": tile_after, "update_payload_called": update_payload_called, "update_payload_call": update_payload_call}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "destroyed"
    ):
        return [
            "\tvar dead_after: bool = true",
            "\tvar on_destroyed_called: bool = true",
            '\treturn {"source_owner": "PortGame.source_build_payload_destroyed_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public void destroyed(){", "dead_assign_expr": "build.dead = true;", "on_destroyed_expr": "build.onDestroyed();", "dead_after": dead_after, "on_destroyed_called": on_destroyed_called}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "content"
    ):
        return [
            "\tvar build_block: Variant = _args[0] if _args.size() > 0 else null",
            '\treturn {"source_owner": "PortGame.source_build_payload_content_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public UnlockableContent content(){", "return_expr": "return build.block;", "content": build_block}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "buildTime"
    ):
        return [
            "\tvar build_time: float = float(_args[0] if _args.size() > 0 else 0.0)",
            '\treturn {"source_owner": "PortGame.source_build_payload_build_time_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public float buildTime(){", "return_expr": "return build.block.buildTime;", "buildTime": build_time}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "requirements"
    ):
        return [
            "\tvar requirements: Variant = _args[0] if _args.size() > 0 else []",
            '\treturn {"source_owner": "PortGame.source_build_payload_requirements_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public ItemStack[] requirements(){", "return_expr": "return build.block.requirements;", "requirements": requirements}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "x"
    ):
        return [
            "\tvar build_x: float = float(_args[0] if _args.size() > 0 else 0.0)",
            '\treturn {"source_owner": "PortGame.source_build_payload_x_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public float x(){", "return_expr": "return build.x;", "x": build_x}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "y"
    ):
        return [
            "\tvar build_y: float = float(_args[0] if _args.size() > 0 else 0.0)",
            '\treturn {"source_owner": "PortGame.source_build_payload_y_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public float y(){", "return_expr": "return build.y;", "y": build_y}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "size"
    ):
        return [
            "\tvar build_block_size: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar source_tilesize: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar size: float = build_block_size * source_tilesize",
            '\treturn {"source_owner": "PortGame.source_build_payload_size_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "import_expr": "import static mindustry.Vars.*;", "override_expr": "@Override", "method": "public float size(){", "return_expr": "return build.block.size * tilesize;", "build_block_size": build_block_size, "source_tilesize": source_tilesize, "size": size}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "remove"
    ):
        return [
            '\treturn {"source_owner": "PortGame.source_build_payload_remove_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public void remove(){", "remove_expr": "build.remove();", "remove_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "write"
    ):
        return [
            "\tvar payload_block: int = int(_args[0] if _args.size() > 0 else 0)",
            "\tvar build_block_id: int = int(_args[1] if _args.size() > 1 else 0)",
            "\tvar build_version: int = int(_args[2] if _args.size() > 2 else 0)",
            '\tvar write_calls: Array = [{"call": "write.b(payloadBlock);", "method": "write.b", "value": payload_block}, {"call": "write.s(build.block.id);", "method": "write.s", "value": build_block_id}, {"call": "write.b(build.version());", "method": "write.b", "value": build_version}, {"call": "build.writeAll(write);", "method": "build.writeAll", "called": true}]',
            '\treturn {"source_owner": "PortGame.source_build_payload_write_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public void write(Writes write){", "payload_block_write_expr": "write.b(payloadBlock);", "block_id_write_expr": "write.s(build.block.id);", "version_write_expr": "write.b(build.version());", "write_all_expr": "build.writeAll(write);", "payload_block": payload_block, "build_block_id": build_block_id, "build_version": build_version, "write_all_called": true, "write_calls": write_calls}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "set"
    ):
        return [
            "\tvar x: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar y: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar rotation: float = float(_args[2] if _args.size() > 2 else 0.0)",
            '\tvar set_call: Dictionary = {"call": "build.set(x, y);", "x": x, "y": y}',
            '\treturn {"source_owner": "PortGame.source_build_payload_set_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public void set(float x, float y, float rotation){", "set_expr": "build.set(x, y);", "x": x, "y": y, "rotation": rotation, "set_called": true, "set_call": set_call}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "drawShadow"
    ):
        return [
            "\tvar build_x: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar build_y: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar build_block_size: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar source_tilesize: float = float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar alpha: float = float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar shadow_size: float = build_block_size * source_tilesize * 1.85",
            '\tvar shadow_call: Dictionary = {"call": "Drawf.squareShadow(build.x, build.y, build.block.size * tilesize * 1.85f, alpha);", "x": build_x, "y": build_y, "size": shadow_size, "alpha": alpha}',
            '\treturn {"source_owner": "PortGame.source_build_payload_draw_shadow_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "import_expr": "import static mindustry.Vars.*;", "override_expr": "@Override", "method": "public void drawShadow(float alpha){", "shadow_expr": "Drawf.squareShadow(build.x, build.y, build.block.size * tilesize * 1.85f, alpha);", "build_x": build_x, "build_y": build_y, "build_block_size": build_block_size, "source_tilesize": source_tilesize, "alpha": alpha, "shadow_size": shadow_size, "shadow_call": shadow_call}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "draw"
    ):
        return [
            "\tvar prev_z: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar layer_flying_unit_low: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar transform_z: float = float(_args[2] if _args.size() > 2 else prev_z)",
            "\tvar shadow_z: float = prev_z - 0.001",
            "\tvar transform_threshold: float = layer_flying_unit_low + 1.0",
            "\tvar transform_min_limit: float = layer_flying_unit_low - 1.0",
            "\tvar transformed_z: float = transform_z",
            "\tif transform_z < transform_threshold:",
            "\t\tvar transform_clamped: float = clampf((transform_z - prev_z) / 100.0, -0.0009, 0.9)",
            "\t\ttransformed_z = 0.0011 + min(transform_clamped + prev_z, transform_min_limit)",
            '\tvar draw_calls: Array = [{"call": "float prevZ = Draw.z();", "value": prev_z}, {"call": "Draw.z(prevZ - 0.001f);", "z": shadow_z}, {"call": "drawShadow(1f);", "alpha": 1.0}, {"call": "Draw.z(prevZ);", "z": prev_z}, {"call": "Draw.zTransform(z ->", "input_z": transform_z, "result": transformed_z}, {"call": "build.tile = emptyTile;", "tile": "emptyTile"}, {"call": "build.payloadDraw();", "called": true}, {"call": "Draw.zTransform();", "called": true}, {"call": "Draw.z(prevZ);", "z": prev_z}]',
            '\treturn {"source_owner": "PortGame.source_build_payload_draw_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "import_expr": "import static mindustry.Vars.*;", "override_expr": "@Override", "method": "public void draw(){", "prev_z_expr": "float prevZ = Draw.z();", "shadow_z_expr": "Draw.z(prevZ - 0.001f);", "draw_shadow_expr": "drawShadow(1f);", "z_restore_expr": "Draw.z(prevZ);", "z_transform_expr": "Draw.zTransform(z ->", "z_transform_return_expr": "z >= Layer.flyingUnitLow + 1f ? z : 0.0011f + Math.min(Mathf.clamp((z - prevZ)/100f, -0.0009f, 0.9f) + prevZ, Layer.flyingUnitLow - 1f)", "tile_assign_expr": "build.tile = emptyTile;", "payload_draw_expr": "build.payloadDraw();", "z_transform_reset_expr": "Draw.zTransform();", "final_z_restore_expr": "Draw.z(prevZ);", "prev_z": prev_z, "layer_flying_unit_low": layer_flying_unit_low, "transform_z": transform_z, "shadow_z": shadow_z, "transformed_z": transformed_z, "tile_after": "emptyTile", "payload_draw_called": true, "draw_calls": draw_calls}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
        and method.get("name") == "icon"
    ):
        return [
            "\tvar full_icon: Variant = _args[0] if _args.size() > 0 else null",
            '\treturn {"source_owner": "PortGame.source_build_payload_icon_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public TextureRegion icon(){", "return_expr": "return block().fullIcon;", "full_icon": full_icon, "icon": full_icon}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/production/Drill.java"
        and type_entry.get("name") == "Drill"
        and method.get("name") == "getDrillTime"
    ):
        return [
            "\tvar drill_time: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar hardness_drill_multiplier: float = float(_args[1] if _args.size() > 1 else 50.0)",
            "\tvar item_hardness: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar drill_multiplier: float = float(_args[3] if _args.size() > 3 else 1.0)",
            "\tvar drill_time_result: float = (drill_time + hardness_drill_multiplier * item_hardness) / drill_multiplier",
            '\treturn {"source_owner": "PortGame.source_drill_delay", "source": "core/src/mindustry/world/blocks/production/Drill.java", "method": "public float getDrillTime(Item item){", "result_expr": "return (drillTime + hardnessDrillMultiplier * item.hardness) / drillMultipliers.get(item, 1f);", "drillTime": drill_time_result, "hardnessDrillMultiplier": hardness_drill_multiplier, "itemHardness": item_hardness, "drillMultiplier": drill_multiplier}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "consumesItem"
    ):
        return [
            "\tvar item_filter: Array = _args[0] if _args.size() > 0 else []",
            "\tvar item_id: int = int(_args[1] if _args.size() > 1 else 0)",
            "\tvar item: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar consumes_item_value: bool = bool(item_filter[item_id])",
            '\treturn {"source_owner": "PortGame.source_block_consumes_item_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean consumesItem(Item item){", "return_expr": "return itemFilter[item.id];", "itemFilter": item_filter, "item_id": item_id, "item": item, "consumes_item": consumes_item_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "consumesLiquid"
    ):
        return [
            "\tvar liquid_filter: Array = _args[0] if _args.size() > 0 else []",
            "\tvar liquid_id: int = int(_args[1] if _args.size() > 1 else 0)",
            "\tvar liq: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar consumes_liquid_value: bool = bool(liquid_filter[liquid_id])",
            '\treturn {"source_owner": "PortGame.source_block_consumes_liquid_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean consumesLiquid(Liquid liq){", "return_expr": "return liquidFilter[liq.id];", "liquidFilter": liquid_filter, "liq_id": liquid_id, "liq": liq, "consumes_liquid": consumes_liquid_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "hasBuilding"
    ):
        return [
            "\tvar destructible_value: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar update_value: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar has_building_value: bool = destructible_value or update_value",
            '\treturn {"source_owner": "PortGame.source_block_has_building_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean hasBuilding(){", "return_expr": "return destructible || update;", "destructible": destructible_value, "update": update_value, "has_building": has_building_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "isMultiblock"
    ):
        return [
            "\tvar size_value: int = int(_args[0] if _args.size() > 0 else 0)",
            "\tvar is_multiblock_value: bool = size_value > 1",
            '\treturn {"source_owner": "PortGame.source_block_is_multiblock_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean isMultiblock(){", "return_expr": "return size > 1;", "size": size_value, "is_multiblock": is_multiblock_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "isAir"
    ):
        return [
            "\tvar id_value: int = int(_args[0] if _args.size() > 0 else 0)",
            "\tvar is_air_value: bool = id_value == 0",
            '\treturn {"source_owner": "PortGame.source_block_is_air_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean isAir(){", "return_expr": "return id == 0;", "id": id_value, "is_air": is_air_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "canBeBuilt"
    ):
        return [
            '\tvar build_visibility_value: String = str(_args[0] if _args.size() > 0 else "shown")',
            '\tvar can_be_built_value: bool = build_visibility_value != "hidden" and build_visibility_value != "debugOnly"',
            '\treturn {"source_owner": "PortGame.source_block_can_be_built_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean canBeBuilt(){", "return_expr": "return buildVisibility != BuildVisibility.hidden && buildVisibility != BuildVisibility.debugOnly;", "buildVisibility": build_visibility_value, "hidden_constant": "BuildVisibility.hidden", "debug_only_constant": "BuildVisibility.debugOnly", "can_be_built": can_be_built_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "isStatic"
    ):
        return [
            '\tvar cache_layer_value: String = str(_args[0] if _args.size() > 0 else "normal")',
            '\tvar is_static_value: bool = cache_layer_value == "walls"',
            '\treturn {"source_owner": "PortGame.source_block_is_static_state", "source": "core/src/mindustry/world/Block.java", "cache_layer_source": "core/src/mindustry/graphics/CacheLayer.java", "method": "public boolean isStatic(){", "return_expr": "return cacheLayer == CacheLayer.walls;", "cacheLayer": cache_layer_value, "walls_constant": "CacheLayer.walls", "is_static": is_static_value}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "hasConsumer"
    ):
        return [
            "\tvar consume_builder_contains: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar cons: Variant = _args[1] if _args.size() > 1 else null",
            '\treturn {"source_owner": "PortGame.source_block_has_consumer_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean hasConsumer(Consume cons){", "return_expr": "return consumeBuilder.contains(cons);", "consumeBuilder_contains": consume_builder_contains, "cons": cons, "has_consumer": consume_builder_contains}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "removeConsumer"
    ):
        return [
            "\tvar consumers_length: int = int(_args[0] if _args.size() > 0 else 0)",
            "\tvar cons: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar illegal_state_exception_thrown: bool = consumers_length > 0",
            "\tvar consume_builder_remove_called: bool = not illegal_state_exception_thrown",
            '\treturn {"source_owner": "PortGame.source_block_remove_consumer_state", "source": "core/src/mindustry/world/Block.java", "method": "public void removeConsumer(Consume cons){", "guard_expr": "if(consumers.length > 0){", "exception_expr": "throw new IllegalStateException(\\"You can only remove consumers before init(). After init(), all consumers have already been initialized.\\");", "exception_message": "You can only remove consumers before init(). After init(), all consumers have already been initialized.", "remove_expr": "consumeBuilder.remove(cons);", "consumers_length": consumers_length, "cons": cons, "illegal_state_exception_thrown": illegal_state_exception_thrown, "consume_builder_remove_called": consume_builder_remove_called}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "removeConsumers"
    ):
        return [
            "\tvar consume_builder_contains_power_after_remove: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar b: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar cons_power_cleared: bool = not consume_builder_contains_power_after_remove",
            '\treturn {"source_owner": "PortGame.source_block_remove_consumers_state", "source": "core/src/mindustry/world/Block.java", "method": "public void removeConsumers(Boolf<Consume> b){", "remove_all_expr": "consumeBuilder.removeAll(b);", "comment": "//the power was removed, unassign it", "power_guard_expr": "if(!consumeBuilder.contains(c -> c instanceof ConsumePower)){", "cons_power_expr": "consPower = null;", "consumeBuilder_contains_power_after_remove": consume_builder_contains_power_after_remove, "b": b, "consume_builder_remove_all_called": true, "cons_power_cleared": cons_power_cleared}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "reinitializeConsumers"
    ):
        return [
            '\tvar reinitialize_bridge_mode: String = str(get_meta("mindustry_reinitialize_consumers_bridge_mode", "consumer_arrays"))',
            '\tif reinitialize_bridge_mode == "consumer_apply_loop":',
            "\t\tvar consumer_entries: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []",
            "\t\tvar apply_calls: Array = []",
            "\t\tfor consumer in consumer_entries:",
            '\t\t\tapply_calls.append({"call": "cons.apply(this);", "consumer": consumer, "block_arg": "this"})',
            '\t\treturn {"source_owner": "PortGame.source_block_reinitialize_consumers_apply_loop_state", "source": "core/src/mindustry/world/Block.java", "consume_source": "core/src/mindustry/world/consumers/Consume.java", "method": "public void reinitializeConsumers(){", "consumers_loop_expr": "for(Consume cons : consumers){", "consume_apply_expr": "cons.apply(this);", "consume_apply_method_expr": "public void apply(Block block){", "consumers": consumer_entries, "apply_calls": apply_calls, "apply_call_count": apply_calls.size()}',
            '\tif reinitialize_bridge_mode == "outputs_power":',
            "\t\tvar outputs_power: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\t\tvar has_power_before: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\t\tvar has_power_after: bool = true if outputs_power else has_power_before",
            '\t\treturn {"source_owner": "PortGame.source_block_reinitialize_consumers_outputs_power_state", "source": "core/src/mindustry/world/Block.java", "method": "public void reinitializeConsumers(){", "outputs_power_expr": "if(outputsPower) hasPower = true;", "outputs_power": outputs_power, "has_power_before": has_power_before, "has_power_after": has_power_after}',
            '\tif reinitialize_bridge_mode == "item_liquid_filters":',
            "\t\tvar content_items_size: int = int(_args[0] if _args.size() > 0 else 0)",
            "\t\tvar content_liquids_size: int = int(_args[1] if _args.size() > 1 else 0)",
            "\t\tvar item_filter: Array = []",
            "\t\tfor _i in range(max(content_items_size, 0)):",
            "\t\t\titem_filter.append(false)",
            "\t\tvar liquid_filter: Array = []",
            "\t\tfor _i in range(max(content_liquids_size, 0)):",
            "\t\t\tliquid_filter.append(false)",
            '\t\treturn {"source_owner": "PortGame.source_block_reinitialize_consumers_item_liquid_filters_state", "source": "core/src/mindustry/world/Block.java", "method": "public void reinitializeConsumers(){", "item_filter_expr": "itemFilter = new boolean[content.items().size];", "liquid_filter_expr": "liquidFilter = new boolean[content.liquids().size];", "content_items_size": content_items_size, "content_liquids_size": content_liquids_size, "item_filter": item_filter, "liquid_filter": liquid_filter, "item_filter_size": item_filter.size(), "liquid_filter_size": liquid_filter.size()}',
            "\tvar consumer_builder_entries: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []",
            "\tvar consumers: Array = consumer_builder_entries.duplicate()",
            "\tvar cons_power: Variant = null",
            "\tvar optional_consumers: Array = []",
            "\tvar non_optional_consumers: Array = []",
            "\tvar update_consumers: Array = []",
            "\tfor consumer in consumer_builder_entries:",
            "\t\tif not consumer is Dictionary:",
            "\t\t\tcontinue",
            '\t\tvar ignored: bool = bool(consumer.get("ignored", false))',
            '\t\tif cons_power == null and bool(consumer.get("is_consume_power", false)):',
            "\t\t\tcons_power = consumer",
            '\t\tif bool(consumer.get("optional", false)) and not ignored:',
            "\t\t\toptional_consumers.append(consumer)",
            '\t\tif not bool(consumer.get("optional", false)) and not ignored:',
            "\t\t\tnon_optional_consumers.append(consumer)",
            '\t\tif bool(consumer.get("update", true)) and not ignored:',
            "\t\t\tupdate_consumers.append(consumer)",
            "\tvar has_consumers: bool = consumers.size() > 0",
            '\treturn {"source_owner": "PortGame.source_block_reinitialize_consumers_arrays_state", "source": "core/src/mindustry/world/Block.java", "consume_source": "core/src/mindustry/world/consumers/Consume.java", "method": "public void reinitializeConsumers(){", "consumers_expr": "consumers = consumeBuilder.toArray(Consume.class);", "cons_power_expr": "consPower = (ConsumePower)Structs.find(consumers, c -> c instanceof ConsumePower);", "optional_consumers_expr": "optionalConsumers = consumeBuilder.select(consume -> consume.optional && !consume.ignore()).toArray(Consume.class);", "non_optional_consumers_expr": "nonOptionalConsumers = consumeBuilder.select(consume -> !consume.optional && !consume.ignore()).toArray(Consume.class);", "update_consumers_expr": "updateConsumers = consumeBuilder.select(consume -> consume.update && !consume.ignore()).toArray(Consume.class);", "has_consumers_expr": "hasConsumers = consumers.length > 0;", "consume_optional_field_expr": "public boolean optional;", "consume_update_field_expr": "public boolean update = true;", "consume_ignore_method_expr": "public boolean ignore(){", "consume_is_power_expr": "c instanceof ConsumePower", "consume_builder": consumer_builder_entries, "consumers": consumers, "cons_power": cons_power, "optional_consumers": optional_consumers, "non_optional_consumers": non_optional_consumers, "update_consumers": update_consumers, "has_consumers": has_consumers}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "checkContentArrayCapacity"
    ):
        return [
            "\tvar item_filter: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []",
            "\tvar liquid_filter: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []",
            "\tvar items: int = int(_args[2] if _args.size() > 2 else item_filter.size())",
            "\tvar liquids: int = int(_args[3] if _args.size() > 3 else liquid_filter.size())",
            "\tvar item_filter_after: Array = []",
            "\tfor i in range(max(items, 0)):",
            "\t\titem_filter_after.append(bool(item_filter[i]) if i < item_filter.size() else false)",
            "\tvar liquid_filter_after: Array = []",
            "\tfor i in range(max(liquids, 0)):",
            "\t\tliquid_filter_after.append(bool(liquid_filter[i]) if i < liquid_filter.size() else false)",
            '\treturn {"source_owner": "PortGame.source_block_check_content_array_capacity_state", "source": "core/src/mindustry/world/Block.java", "method": "public void checkContentArrayCapacity(int items, int liquids){", "liquid_resize_expr": "if(liquidFilter.length != liquids) liquidFilter = Arrays.copyOf(liquidFilter, liquids);", "item_resize_expr": "if(itemFilter.length != items) itemFilter = Arrays.copyOf(itemFilter, items);", "item_filter_before": item_filter, "liquid_filter_before": liquid_filter, "items": items, "liquids": liquids, "item_filter_after": item_filter_after, "liquid_filter_after": liquid_filter_after}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "load"
    ):
        return [
            '\tif str(get_meta("mindustry_load_bridge_mode", "")) == "variant_shadow_regions":',
            '\t\tvar shadow_load_name_value: String = str(_args[0] if _args.size() > 0 else "")',
            "\t\tvar shadow_variants: int = int(_args[1] if _args.size() > 1 else 0)",
            "\t\tvar shadow_custom_shadow: bool = bool(_args[2] if _args.size() > 2 else false)",
            "\t\tvar shadow_variants_guard: bool = shadow_variants != 0",
            "\t\tvar shadow_custom_shadow_guard: bool = shadow_variants_guard and shadow_custom_shadow",
            "\t\tvar variant_shadow_regions: Array = []",
            "\t\tif shadow_custom_shadow_guard:",
            "\t\t\tfor i in range(shadow_variants):",
            '\t\t\t\tvariant_shadow_regions.append("Core.atlas.find(%s-shadow%d)" % [shadow_load_name_value, i + 1])',
            '\t\treturn {"source_owner": "PortGame.source_block_load_variant_shadow_regions_state", "source": "core/src/mindustry/world/Block.java", "method": "public void load(){", "variants_guard_expr": "if(variants != 0){", "custom_shadow_guard_expr": "if(customShadow){", "variant_shadow_regions_expr": "variantShadowRegions = new TextureRegion[variants];", "variant_shadow_loop_expr": "for(int i = 0; i < variants; i++){", "variant_shadow_assignment_expr": "variantShadowRegions[i] = Core.atlas.find(name + \\"-shadow\\" + (i + 1));", "name": shadow_load_name_value, "variants": shadow_variants, "custom_shadow": shadow_custom_shadow, "variants_guard": shadow_variants_guard, "custom_shadow_guard": shadow_custom_shadow_guard, "variant_shadow_regions": variant_shadow_regions}',
            '\tif str(get_meta("mindustry_load_bridge_mode", "")) == "variant_regions":',
            '\t\tvar variant_load_name_value: String = str(_args[0] if _args.size() > 0 else "")',
            "\t\tvar variants: int = int(_args[1] if _args.size() > 1 else 0)",
            "\t\tvar variants_guard: bool = variants != 0",
            "\t\tvar variant_regions: Array = []",
            "\t\tvar variant_region_value: Variant = null",
            "\t\tif variants_guard:",
            "\t\t\tfor i in range(variants):",
            '\t\t\t\tvariant_regions.append("Core.atlas.find(%s%d)" % [variant_load_name_value, i + 1])',
            "\t\t\tif variant_regions.size() > 0:",
            "\t\t\t\tvariant_region_value = variant_regions[0]",
            '\t\treturn {"source_owner": "PortGame.source_block_load_variant_regions_state", "source": "core/src/mindustry/world/Block.java", "method": "public void load(){", "variants_guard_expr": "if(variants != 0){", "variant_regions_expr": "variantRegions = new TextureRegion[variants];", "variant_loop_expr": "for(int i = 0; i < variants; i++){", "variant_assignment_expr": "variantRegions[i] = Core.atlas.find(name + (i + 1));", "region_assignment_expr": "region = variantRegions[0];", "name": variant_load_name_value, "variants": variants, "variants_guard": variants_guard, "variant_regions": variant_regions, "region": variant_region_value}',
            '\tif str(get_meta("mindustry_load_bridge_mode", "")) == "team_regions":',
            '\t\tvar team_load_name_value: String = str(_args[0] if _args.size() > 0 else "")',
            "\t\tvar team_region_found: bool = bool(_args[1] if _args.size() > 1 else false)",
            '\t\tvar team_region: Variant = _args[2] if _args.size() > 2 else "teamRegion"',
            "\t\tvar teams: Array = (_args[3] as Array).duplicate() if _args.size() > 3 and _args[3] is Array else []",
            "\t\tvar team_regions: Array = []",
            "\t\tfor _i in range(teams.size()):",
            "\t\t\tteam_regions.append(team_region)",
            "\t\tvar assignments: Array = []",
            "\t\tfor team in teams:",
            "\t\t\tif not team is Dictionary:",
            "\t\t\t\tcontinue",
            '\t\t\tvar team_id: int = int(team.get("id", 0))',
            '\t\t\tvar team_name: String = str(team.get("name", ""))',
            '\t\t\tvar team_has_palette: bool = bool(team.get("hasPalette", false))',
            "\t\t\tvar assigned_region: Variant = team_region",
            "\t\t\tif team_region_found and team_has_palette:",
            '\t\t\t\tassigned_region = "Core.atlas.find(%s-team-%s, %s)" % [team_load_name_value, team_name, str(team_region)]',
            "\t\t\tif team_id >= 0 and team_id < team_regions.size():",
            "\t\t\t\tteam_regions[team_id] = assigned_region",
            '\t\t\tassignments.append({"team_id": team_id, "team_name": team_name, "team_has_palette": team_has_palette, "assigned_region": assigned_region})',
            '\t\treturn {"source_owner": "PortGame.source_block_load_team_regions_state", "source": "core/src/mindustry/world/Block.java", "method": "public void load(){", "comment": "//load specific team regions", "team_regions_expr": "teamRegions = new TextureRegion[Team.all.length];", "team_loop_expr": "for(Team team : Team.all){", "team_assignment_expr": "teamRegions[team.id] = teamRegion.found() && team.hasPalette ? Core.atlas.find(name + \\"-team-\\" + team.name, teamRegion) : teamRegion;", "name": team_load_name_value, "team_region_found": team_region_found, "team_region": team_region, "teams": teams, "team_all_length": teams.size(), "team_regions": team_regions, "assignments": assignments}',
            '\tvar name_value: String = str(_args[0] if _args.size() > 0 else "")',
            '\tvar region_value: String = "Core.atlas.find(%s)" % name_value',
            '\treturn {"source_owner": "PortGame.source_block_load_base_regions_state", "source": "core/src/mindustry/world/Block.java", "method": "public void load(){", "super_load_expr": "super.load();", "region_expr": "region = Core.atlas.find(name);", "content_regions_expr": "ContentRegions.loadRegions(this);", "name": name_value, "region": region_value, "super_load_called": true, "content_regions_loaded": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "consumeLiquid"
        and len(method.get("parameters", [])) == 2
    ):
        return [
            "\tvar liquid: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar amount: float = float(_args[1] if _args.size() > 1 else 0.0)",
            '\tvar constructed_consume: Dictionary = {"type": "ConsumeLiquid", "liquid": liquid, "amount": amount}',
            '\treturn {"source_owner": "PortGame.source_block_consume_liquid_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeLiquid consumeLiquid(Liquid liquid, float amount){", "return_expr": "return consume(new ConsumeLiquid(liquid, amount));", "constructor_expr": "new ConsumeLiquid(liquid, amount)", "consume_call_expr": "consume(new ConsumeLiquid(liquid, amount))", "liquid": liquid, "amount": amount, "constructed_consume": constructed_consume, "consume_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "consumeLiquids"
    ):
        return [
            "\tvar stacks: Variant = _args[0] if _args.size() > 0 else []",
            '\tvar constructed_consume: Dictionary = {"type": "ConsumeLiquids", "stacks": stacks}',
            '\treturn {"source_owner": "PortGame.source_block_consume_liquids_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeLiquids consumeLiquids(LiquidStack... stacks){", "return_expr": "return consume(new ConsumeLiquids(stacks));", "constructor_expr": "new ConsumeLiquids(stacks)", "consume_call_expr": "consume(new ConsumeLiquids(stacks))", "stacks": stacks, "constructed_consume": constructed_consume, "consume_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "consumePower"
        and len(method.get("parameters", [])) == 1
    ):
        return [
            "\tvar power_per_tick: float = float(_args[0] if _args.size() > 0 else 0.0)",
            '\tvar constructed_consume: Dictionary = {"type": "ConsumePower", "powerPerTick": power_per_tick, "capacity": 0.0, "buffered": false}',
            '\treturn {"source_owner": "PortGame.source_block_consume_power_state", "source": "core/src/mindustry/world/Block.java", "comment": "Creates a consumer which directly uses power without buffering it.", "param": "@param powerPerTick The amount of power which is required each tick for 100% efficiency.", "method": "public ConsumePower consumePower(float powerPerTick){", "return_expr": "return consume(new ConsumePower(powerPerTick, 0.0f, false));", "constructor_expr": "new ConsumePower(powerPerTick, 0.0f, false)", "consume_call_expr": "consume(new ConsumePower(powerPerTick, 0.0f, false))", "powerPerTick": power_per_tick, "capacity": 0.0, "buffered": false, "constructed_consume": constructed_consume, "consume_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "consumePowerCond"
    ):
        return [
            "\tvar usage: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar cons: Variant = _args[1] if _args.size() > 1 else null",
            '\tvar constructed_consume: Dictionary = {"type": "ConsumePowerCondition", "usage": usage, "condition": cons}',
            '\treturn {"source_owner": "PortGame.source_block_consume_power_cond_state", "source": "core/src/mindustry/world/Block.java", "comment": "Creates a consumer which only consumes power when the condition is met.", "method": "public <T extends Building> ConsumePower consumePowerCond(float usage, Boolf<T> cons){", "return_expr": "return consume(new ConsumePowerCondition(usage, (Boolf<Building>)cons));", "constructor_expr": "new ConsumePowerCondition(usage, (Boolf<Building>)cons)", "condition_cast_expr": "(Boolf<Building>)cons", "consume_call_expr": "consume(new ConsumePowerCondition(usage, (Boolf<Building>)cons))", "usage": usage, "condition": cons, "constructed_consume": constructed_consume, "consume_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "consumePowerDynamic"
        and len(method.get("parameters", [])) == 2
    ):
        return [
            "\tvar displayed: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar usage: Variant = _args[1] if _args.size() > 1 else null",
            '\tvar constructed_consume: Dictionary = {"type": "ConsumePowerDynamic", "displayed": displayed, "usage": usage}',
            '\treturn {"source_owner": "PortGame.source_block_consume_power_dynamic_displayed_state", "source": "core/src/mindustry/world/Block.java", "comment": "Creates a consumer that consumes a dynamic amount of power.", "method": "public <T extends Building> ConsumePower consumePowerDynamic(float displayed, Floatf<T> usage){", "return_expr": "return consume(new ConsumePowerDynamic(displayed, (Floatf<Building>)usage));", "constructor_expr": "new ConsumePowerDynamic(displayed, (Floatf<Building>)usage)", "usage_cast_expr": "(Floatf<Building>)usage", "consume_call_expr": "consume(new ConsumePowerDynamic(displayed, (Floatf<Building>)usage))", "displayed": displayed, "usage": usage, "constructed_consume": constructed_consume, "consume_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "consumePowerBuffered"
    ):
        return [
            "\tvar power_capacity: float = float(_args[0] if _args.size() > 0 else 0.0)",
            '\tvar constructed_consume: Dictionary = {"type": "ConsumePower", "powerPerTick": 0.0, "capacity": power_capacity, "buffered": true}',
            '\treturn {"source_owner": "PortGame.source_block_consume_power_buffered_state", "source": "core/src/mindustry/world/Block.java", "comment": "Creates a consumer which stores power.", "param": "@param powerCapacity The maximum capacity in power units.", "method": "public ConsumePower consumePowerBuffered(float powerCapacity){", "return_expr": "return consume(new ConsumePower(0f, powerCapacity, true));", "constructor_expr": "new ConsumePower(0f, powerCapacity, true)", "consume_call_expr": "consume(new ConsumePower(0f, powerCapacity, true))", "powerCapacity": power_capacity, "powerPerTick": 0.0, "buffered": true, "constructed_consume": constructed_consume, "consume_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "consumeItem"
        and len(method.get("parameters", [])) == 1
    ):
        return [
            "\tvar item: Variant = _args[0] if _args.size() > 0 else null",
            '\treturn {"source_owner": "PortGame.source_block_consume_item_single_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeItems consumeItem(Item item){", "return_expr": "return consumeItem(item, 1);", "delegate_call_expr": "consumeItem(item, 1)", "item": item, "amount": 1, "delegate_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "consumeItem"
        and len(method.get("parameters", [])) == 2
    ):
        return [
            "\tvar item: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar amount: int = int(_args[1] if _args.size() > 1 else 0)",
            '\tvar item_stack: Dictionary = {"type": "ItemStack", "item": item, "amount": amount}',
            '\tvar constructed_consume: Dictionary = {"type": "ConsumeItems", "items": [item_stack]}',
            '\treturn {"source_owner": "PortGame.source_block_consume_item_amount_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeItems consumeItem(Item item, int amount){", "return_expr": "return consume(new ConsumeItems(new ItemStack[]{new ItemStack(item, amount)}));", "item_stack_expr": "new ItemStack(item, amount)", "item_stack_array_expr": "new ItemStack[]{new ItemStack(item, amount)}", "constructor_expr": "new ConsumeItems(new ItemStack[]{new ItemStack(item, amount)})", "consume_call_expr": "consume(new ConsumeItems(new ItemStack[]{new ItemStack(item, amount)}))", "item": item, "amount": amount, "item_stack": item_stack, "constructed_consume": constructed_consume, "consume_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "consumeItems"
    ):
        return [
            "\tvar items: Array = _args",
            '\tvar constructed_consume: Dictionary = {"type": "ConsumeItems", "items": items}',
            '\treturn {"source_owner": "PortGame.source_block_consume_items_varargs_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeItems consumeItems(ItemStack... items){", "return_expr": "return consume(new ConsumeItems(items));", "constructor_expr": "new ConsumeItems(items)", "consume_call_expr": "consume(new ConsumeItems(items))", "items": items, "constructed_consume": constructed_consume, "consume_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "consumeCoolant"
        and len(method.get("parameters", [])) == 3
    ):
        return [
            "\tvar amount: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar allow_liquid: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar allow_gas: bool = bool(_args[2] if _args.size() > 2 else false)",
            '\tvar constructed_consume: Dictionary = {"type": "ConsumeCoolant", "amount": amount, "allowLiquid": allow_liquid, "allowGas": allow_gas}',
            '\treturn {"source_owner": "PortGame.source_block_consume_coolant_filtered_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeCoolant consumeCoolant(float amount, boolean allowLiquid, boolean allowGas){", "return_expr": "return consume(new ConsumeCoolant(amount, allowLiquid, allowGas));", "constructor_expr": "new ConsumeCoolant(amount, allowLiquid, allowGas)", "consume_call_expr": "consume(new ConsumeCoolant(amount, allowLiquid, allowGas))", "amount": amount, "allowLiquid": allow_liquid, "allowGas": allow_gas, "constructed_consume": constructed_consume, "consume_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "consumeCoolant"
        and len(method.get("parameters", [])) == 1
    ):
        return [
            "\tvar amount: float = float(_args[0] if _args.size() > 0 else 0.0)",
            '\tvar constructed_consume: Dictionary = {"type": "ConsumeCoolant", "amount": amount}',
            '\treturn {"source_owner": "PortGame.source_block_consume_coolant_single_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeCoolant consumeCoolant(float amount){", "return_expr": "return consume(new ConsumeCoolant(amount));", "constructor_expr": "new ConsumeCoolant(amount)", "consume_call_expr": "consume(new ConsumeCoolant(amount))", "amount": amount, "constructed_consume": constructed_consume, "consume_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "consume"
        and len(method.get("parameters", [])) == 1
    ):
        return [
            "\tvar consume: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar consume_is_power: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar consume_builder_before: Array = (_args[2] if _args.size() > 2 else []) as Array",
            "\tvar consume_builder_without_power: Array = (_args[3] if _args.size() > 3 else []) as Array",
            "\tvar cons_power_before: Variant = _args[4] if _args.size() > 4 else null",
            "\tvar consume_builder_after: Array = consume_builder_without_power.duplicate() if consume_is_power else consume_builder_before.duplicate()",
            "\tconsume_builder_after.append(consume)",
            "\tvar remove_power_called: bool = consume_is_power",
            "\tvar cons_power_after: Variant = consume if consume_is_power else cons_power_before",
            '\treturn {"source_owner": "PortGame.source_block_consume_generic_state", "source": "core/src/mindustry/world/Block.java", "method": "public <T extends Consume> T consume(T consume){", "power_guard_expr": "if(consume instanceof ConsumePower){", "comment": "//there can only be one power consumer", "remove_power_expr": "consumeBuilder.removeAll(b -> b instanceof ConsumePower);", "cons_power_expr": "consPower = (ConsumePower)consume;", "add_expr": "consumeBuilder.add(consume);", "return_expr": "return consume;", "consume": consume, "consume_is_power": consume_is_power, "consume_builder_before": consume_builder_before, "consume_builder_without_power": consume_builder_without_power, "consume_builder_after": consume_builder_after, "cons_power_before": cons_power_before, "cons_power_after": cons_power_after, "remove_power_called": remove_power_called, "add_called": true, "returned_consume": consume}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "setupRequirements"
        and len(method.get("parameters", [])) == 2
    ):
        return [
            "\tvar cat: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar stacks: Variant = _args[1] if _args.size() > 1 else null",
            '\treturn {"source_owner": "PortGame.source_block_setup_requirements_simple_state", "source": "core/src/mindustry/world/Block.java", "method": "public void setupRequirements(Category cat, ItemStack[] stacks){", "delegate_call_expr": "requirements(cat, stacks)", "cat": cat, "stacks": stacks, "delegate_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "setupRequirements"
        and len(method.get("parameters", [])) == 3
    ):
        return [
            "\tvar cat: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar build_visibility: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar stacks: Variant = _args[2] if _args.size() > 2 else null",
            '\treturn {"source_owner": "PortGame.source_block_setup_requirements_visible_state", "source": "core/src/mindustry/world/Block.java", "method": "public void setupRequirements(Category cat, BuildVisibility visible, ItemStack[] stacks){", "delegate_call_expr": "requirements(cat, visible, stacks)", "cat": cat, "visible": build_visibility, "stacks": stacks, "delegate_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "requirements"
        and [param.get("type") for param in method.get("parameters", [])] == ["Category", "ItemStack", "boolean"]
    ):
        return [
            "\tvar cat: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar stacks: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar unlocked: bool = bool(_args[2] if _args.size() > 2 else false)",
            '\treturn {"source_owner": "PortGame.source_block_requirements_unlocked_state", "source": "core/src/mindustry/world/Block.java", "method": "public void requirements(Category cat, ItemStack[] stacks, boolean unlocked){", "delegate_call_expr": "requirements(cat, BuildVisibility.shown, stacks)", "always_unlocked_assignment_expr": "this.alwaysUnlocked = unlocked;", "cat": cat, "build_visibility": "BuildVisibility.shown", "stacks": stacks, "unlocked": unlocked, "delegate_called": true, "always_unlocked_assigned": true, "always_unlocked_after": unlocked}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "requirements"
        and [param.get("type") for param in method.get("parameters", [])] == ["Category", "ItemStack"]
    ):
        return [
            "\tvar cat: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar stacks: Variant = _args[1] if _args.size() > 1 else null",
            '\treturn {"source_owner": "PortGame.source_block_requirements_simple_state", "source": "core/src/mindustry/world/Block.java", "method": "public void requirements(Category cat, ItemStack[] stacks){", "delegate_call_expr": "requirements(cat, BuildVisibility.shown, stacks)", "cat": cat, "build_visibility": "BuildVisibility.shown", "stacks": stacks, "delegate_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "requirements"
        and [param.get("type") for param in method.get("parameters", [])] == ["Category", "BuildVisibility", "ItemStack"]
    ):
        return [
            "\tvar cat: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar build_visibility: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar stacks: Variant = _args[2] if _args.size() > 2 else null",
            "\tvar requirements_after: Variant = stacks",
            "\trequirements_after.sort_custom(func(left, right):",
            "\t\treturn int(left[\"item\"][\"id\"]) < int(right[\"item\"][\"id\"])",
            "\t)",
            '\treturn {"source_owner": "PortGame.source_block_requirements_visible_state", "source": "core/src/mindustry/world/Block.java", "method": "public void requirements(Category cat, BuildVisibility visible, ItemStack[] stacks){", "comment": "/** Sets up requirements. Use only this method to set up requirements. */", "category_assignment_expr": "this.category = cat;", "requirements_assignment_expr": "this.requirements = stacks;", "build_visibility_assignment_expr": "this.buildVisibility = visible;", "sort_expr": "Arrays.sort(requirements, Structs.comparingInt(i -> i.item.id));", "cat": cat, "visible": build_visibility, "stacks": stacks, "category_after": cat, "requirements_after": requirements_after, "build_visibility_after": build_visibility, "sort_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "initBuilding"
        and len(method.get("parameters", [])) == 0
    ):
        return [
            "\tvar build_type_before: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar default_assigned: bool = build_type_before == null",
            '\tvar build_type_after: Variant = "Building::create" if default_assigned else build_type_before',
            '\treturn {"source_owner": "PortGame.source_block_init_building_default_state", "source": "core/src/mindustry/world/Block.java", "method": "protected void initBuilding(){", "default_guard_expr": "if(buildType == null){", "default_comment": "//assign default value", "default_assignment_expr": "buildType = Building::create;", "build_type_before": build_type_before, "build_type_after": build_type_after, "default_assigned": default_assigned}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "researchRequirements"
        and len(method.get("parameters", [])) == 0
    ):
        return [
            "\tvar research_cost: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar research_cost_multiplier: float = float(_args[1] if _args.size() > 1 else 1.0)",
            "\tvar returned_early: bool = research_cost != null",
            "\tvar returned_requirements: Variant = research_cost if returned_early else null",
            "\tif _args.size() <= 1:",
            '\t\treturn {"source_owner": "PortGame.source_block_research_requirements_research_cost_state", "source": "core/src/mindustry/world/Block.java", "method": "public ItemStack[] researchRequirements(){", "override_expr": "@Override", "research_cost_guard_expr": "if(researchCost != null) return researchCost;", "return_expr": "return researchCost;", "research_cost": research_cost, "returned_requirements": returned_requirements, "returned_early": returned_early}',
            "\tvar returned_empty: bool = research_cost == null and research_cost_multiplier <= 0.0",
            '\tvar returned_requirements_after_multiplier: Variant = "ItemStack.empty" if returned_empty else returned_requirements',
            "\tif _args.size() <= 2:",
            '\t\treturn {"source_owner": "PortGame.source_block_research_requirements_empty_state", "source": "core/src/mindustry/world/Block.java", "method": "public ItemStack[] researchRequirements(){", "override_expr": "@Override", "research_cost_guard_expr": "if(researchCost != null) return researchCost;", "empty_guard_expr": "if(researchCostMultiplier <= 0f) return ItemStack.empty;", "empty_return_expr": "return ItemStack.empty;", "research_cost": research_cost, "research_cost_multiplier": research_cost_multiplier, "returned_requirements": returned_requirements_after_multiplier, "returned_empty": returned_empty}',
            "\tvar requirements: Array = _args[2] if _args.size() > 2 else []",
            "\tvar allocation_reached: bool = research_cost == null and research_cost_multiplier > 0.0",
            "\tvar allocated_out_length: int = requirements.size() if allocation_reached else 0",
            "\tvar loop_indices: Array = []",
            "\tfor i in range(allocated_out_length):",
            "\t\tloop_indices.append(i)",
            "\tif _args.size() <= 3:",
            '\t\treturn {"source_owner": "PortGame.source_block_research_requirements_loop_shape_state", "source": "core/src/mindustry/world/Block.java", "method": "public ItemStack[] researchRequirements(){", "override_expr": "@Override", "research_cost_guard_expr": "if(researchCost != null) return researchCost;", "empty_guard_expr": "if(researchCostMultiplier <= 0f) return ItemStack.empty;", "out_alloc_expr": "ItemStack[] out = new ItemStack[requirements.length];", "loop_expr": "for(int i = 0; i < out.length; i++){", "return_out_expr": "return out;", "research_cost": research_cost, "research_cost_multiplier": research_cost_multiplier, "requirements": requirements, "allocation_reached": allocation_reached, "allocated_out_length": allocated_out_length, "loop_indices": loop_indices}',
            "\tvar research_cost_multipliers: Dictionary = _args[3] if _args.size() > 3 else {}",
            "\tvar quantity_values: Array = []",
            "\tvar multiplier_values: Array = []",
            "\tvar amount_power_values: Array = []",
            "\tfor requirement in requirements:",
            "\t\tif not allocation_reached:",
            "\t\t\tcontinue",
            '\t\tvar item_key: String = str(requirement.get("item", ""))',
            '\t\tvar cost_multiplier: float = float(research_cost_multipliers.get(item_key, 1.0))',
            '\t\tvar amount_power: float = pow(float(requirement.get("amount", 0.0)), 1.11)',
            "\t\tvar quantity_float: float = 60.0 * research_cost_multiplier + amount_power * 20.0 * research_cost_multiplier * cost_multiplier",
            "\t\tvar quantity: int = int(quantity_float / 10.0) * 10",
            "\t\tmultiplier_values.append(cost_multiplier)",
            "\t\tamount_power_values.append(amount_power)",
            "\t\tquantity_values.append(quantity)",
            "\tif _args.size() <= 4:",
            '\t\treturn {"source_owner": "PortGame.source_block_research_requirements_quantity_formula_state", "source": "core/src/mindustry/world/Block.java", "method": "public ItemStack[] researchRequirements(){", "quantity_expr": "int quantity = Mathf.round(60 * researchCostMultiplier + Mathf.pow(requirements[i].amount, 1.11f) * 20 * researchCostMultiplier * researchCostMultipliers.get(requirements[i].item, 1f), 10);", "mathf_round_expr": "Mathf.round(value, 10)", "mathf_round_step_expr": "return (int)(value / step) * step;", "research_cost": research_cost, "research_cost_multiplier": research_cost_multiplier, "requirements": requirements, "research_cost_multipliers": research_cost_multipliers, "quantity_values": quantity_values, "multiplier_values": multiplier_values, "amount_power_values": amount_power_values}',
            "\tvar rounded_amount_values: Array = []",
            "\tfor quantity in quantity_values:",
            "\t\tvar rounded_amount: int = int(quantity)",
            "\t\tif rounded_amount >= 1000000000:",
            "\t\t\trounded_amount = int(float(rounded_amount) / 100000000.0) * 100000000",
            "\t\telif rounded_amount >= 1000000:",
            "\t\t\trounded_amount = int(float(rounded_amount) / 100000.0) * 100000",
            "\t\telif rounded_amount >= 10000:",
            "\t\t\trounded_amount = int(float(rounded_amount) / 1000.0) * 1000",
            "\t\telif rounded_amount >= 1000:",
            "\t\t\trounded_amount = int(float(rounded_amount) / 100.0) * 100",
            "\t\telif rounded_amount >= 100:",
            "\t\t\trounded_amount = int(float(rounded_amount) / 100.0) * 100",
            "\t\telif rounded_amount >= 10:",
            "\t\t\trounded_amount = int(float(rounded_amount) / 10.0) * 10",
            "\t\trounded_amount_values.append(rounded_amount)",
            "\tif _args.size() <= 5:",
            '\t\treturn {"source_owner": "PortGame.source_block_research_requirements_round_amount_state", "source": "core/src/mindustry/world/Block.java", "ui_source": "core/src/mindustry/core/UI.java", "method": "public ItemStack[] researchRequirements(){", "round_amount_expr": "UI.roundAmount(quantity)", "ui_round_amount_method": "public static int roundAmount(int number){", "mathf_round_int_step_expr": "return (value / step) * step;", "quantity_values": quantity_values, "rounded_amount_values": rounded_amount_values}',
            "\tvar output_requirements: Array = []",
            "\tfor i in range(rounded_amount_values.size()):",
            "\t\tvar requirement: Dictionary = requirements[i] if i < requirements.size() else {}",
            '\t\toutput_requirements.append({"item": requirement.get("item"), "amount": rounded_amount_values[i]})',
            '\treturn {"source_owner": "PortGame.source_block_research_requirements_output_fill_state", "source": "core/src/mindustry/world/Block.java", "method": "public ItemStack[] researchRequirements(){", "itemstack_fill_expr": "out[i] = new ItemStack(requirements[i].item, UI.roundAmount(quantity));", "return_out_expr": "return out;", "quantity_values": quantity_values, "rounded_amount_values": rounded_amount_values, "output_requirements": output_requirements, "returned_requirements": output_requirements}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "getDependencies"
        and len(method.get("parameters", [])) == 1
    ):
        return [
            "\tvar requirements: Array = _args[0] if _args.size() > 0 else []",
            "\tvar dependency_items: Array = []",
            "\tfor requirement in requirements:",
            '\t\tdependency_items.append(requirement.get("item"))',
            "\tif _args.size() <= 1:",
            '\t\treturn {"source_owner": "PortGame.source_block_get_dependencies_requirements_state", "source": "core/src/mindustry/world/Block.java", "method": "public void getDependencies(Cons<UnlockableContent> cons){", "requirements_comment": "//just requires items", "requirements_loop_expr": "for(ItemStack stack : requirements){", "cons_get_item_expr": "cons.get(stack.item);", "requirements": requirements, "dependency_items": dependency_items}',
            "\tvar consume_builder: Array = _args[1] if _args.size() > 1 else []",
            "\tvar consume_loop_indices: Array = []",
            "\tvar skipped_optional_indices: Array = []",
            "\tvar non_optional_indices: Array = []",
            "\tfor i in range(consume_builder.size()):",
            "\t\tconsume_loop_indices.append(i)",
            "\t\tvar consume: Dictionary = consume_builder[i]",
            '\t\tif bool(consume.get("optional", false)):',
            "\t\t\tskipped_optional_indices.append(i)",
            "\t\t\tcontinue",
            "\t\tnon_optional_indices.append(i)",
            "\tif _args.size() <= 2:",
            '\t\treturn {"source_owner": "PortGame.source_block_get_dependencies_consume_builder_optional_state", "source": "core/src/mindustry/world/Block.java", "method": "public void getDependencies(Cons<UnlockableContent> cons){", "inputs_comment": "//also requires inputs", "consume_builder_loop_expr": "for(var c : consumeBuilder){", "optional_guard_expr": "if(c.optional) continue;", "requirements": requirements, "dependency_items": dependency_items, "consume_builder": consume_builder, "consume_loop_indices": consume_loop_indices, "skipped_optional_indices": skipped_optional_indices, "non_optional_indices": non_optional_indices}',
            "\tvar consume_items_indices: Array = []",
            "\tvar consume_item_dependency_items: Array = []",
            "\tfor i in range(consume_builder.size()):",
            "\t\tvar consume: Dictionary = consume_builder[i]",
            '\t\tif bool(consume.get("optional", false)):',
            "\t\t\tcontinue",
            '\t\tif str(consume.get("type", "")) != "ConsumeItems":',
            "\t\t\tcontinue",
            "\t\tconsume_items_indices.append(i)",
            '\t\tfor stack in consume.get("items", []):',
            '\t\t\tconsume_item_dependency_items.append(stack.get("item"))',
            '\t\t\tdependency_items.append(stack.get("item"))',
            '\treturn {"source_owner": "PortGame.source_block_get_dependencies_consume_items_state", "source": "core/src/mindustry/world/Block.java", "method": "public void getDependencies(Cons<UnlockableContent> cons){", "consume_items_guard_expr": "if(c instanceof ConsumeItems i){", "consume_items_loop_expr": "for(ItemStack stack : i.items){", "consume_items_cons_get_item_expr": "cons.get(stack.item);", "requirements": requirements, "dependency_items": dependency_items, "consume_builder": consume_builder, "consume_loop_indices": consume_loop_indices, "skipped_optional_indices": skipped_optional_indices, "non_optional_indices": non_optional_indices, "consume_items_indices": consume_items_indices, "consume_item_dependency_items": consume_item_dependency_items}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "getContentType"
        and len(method.get("parameters", [])) == 0
    ):
        return [
            '\treturn {"source_owner": "PortGame.source_block_get_content_type_state", "source": "core/src/mindustry/world/Block.java", "method": "public ContentType getContentType(){", "content_type_return_expr": "return ContentType.block;", "content_type": "ContentType.block"}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "logicVisible"
        and len(method.get("parameters", [])) == 0
    ):
        return [
            '\tvar build_visibility_value: String = str(_args[0] if _args.size() > 0 else "")',
            '\tvar logic_visible: bool = build_visibility_value != "BuildVisibility.hidden"',
            '\treturn {"source_owner": "PortGame.source_block_logic_visible_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean logicVisible(){", "logic_visible_return_expr": "return buildVisibility != BuildVisibility.hidden;", "build_visibility": build_visibility_value, "logic_visible": logic_visible}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "postInit"
        and len(method.get("parameters", [])) == 0
    ):
        return [
            "\tif _args.size() <= 2:",
            "\t\tpass",
            "\telse:",
            "\t\tvar requirements: Array = _args[0] if _args.size() > 0 else []",
            "\t\tvar shown_planets_before: Array = _args[1] if _args.size() > 1 else []",
            "\t\tvar content_planets: Array = _args[2] if _args.size() > 2 else []",
            "\t\tvar shown_planets_after: Array = shown_planets_before.duplicate()",
            "\t\tvar auto_assign_guard_passed: bool = requirements.size() > 0 and shown_planets_before.is_empty()",
            "\t\tvar evaluated_planets: Array = []",
            "\t\tvar landable_planets: Array = []",
            "\t\tvar added_planets: Array = []",
            "\t\tvar blocked_planets: Array = []",
            "\t\tif auto_assign_guard_passed:",
            "\t\t\tfor planet in content_planets:",
            '\t\t\t\tvar planet_name: String = str(planet.get("name", ""))',
            "\t\t\t\tevaluated_planets.append(planet_name)",
            '\t\t\t\tif not bool(planet.get("is_landable", false)):',
            "\t\t\t\t\tcontinue",
            "\t\t\t\tlandable_planets.append(planet_name)",
            "\t\t\t\tvar blocking_requirement_indices: Array = []",
            "\t\t\t\tfor i in range(requirements.size()):",
            "\t\t\t\t\tvar stack: Dictionary = requirements[i]",
            '\t\t\t\t\tvar is_on_planets: Array = stack.get("is_on_planets", [])',
            "\t\t\t\t\tif not is_on_planets.has(planet_name):",
            "\t\t\t\t\t\tblocking_requirement_indices.append(i)",
            "\t\t\t\tif blocking_requirement_indices.is_empty():",
            "\t\t\t\t\tshown_planets_after.append(planet_name)",
            "\t\t\t\t\tadded_planets.append(planet_name)",
            "\t\t\t\telse:",
            '\t\t\t\t\tblocked_planets.append({"planet": planet_name, "blocking_requirement_indices": blocking_requirement_indices})',
            '\t\treturn {"source_owner": "PortGame.source_block_post_init_shown_planets_state", "source": "core/src/mindustry/world/Block.java", "method": "public void postInit(){", "shown_planets_comment": "//usually, an empty set of planets is a configuration error. auto-assign based on requirements", "auto_assign_guard_expr": "if(requirements.length > 0 && shownPlanets.isEmpty()){", "content_planets_loop_expr": "for(Planet planet : content.planets()){", "planet_landable_guard_expr": "if(planet.isLandable()){", "structs_contains_guard_expr": "if(!Structs.contains(requirements, s -> !s.item.isOnPlanet(planet))){", "shown_planets_add_expr": "shownPlanets.add(planet);", "requirements": requirements, "shown_planets_before": shown_planets_before, "content_planets": content_planets, "shown_planets_after": shown_planets_after, "auto_assign_guard_passed": auto_assign_guard_passed, "evaluated_planets": evaluated_planets, "landable_planets": landable_planets, "added_planets": added_planets, "blocked_planets": blocked_planets}',
            "\tvar database_tag_before: Variant = _args[0] if _args.size() > 0 else null",
            '\tvar category_name: String = str(_args[1] if _args.size() > 1 else "")',
            "\tvar database_tag_after: Variant = database_tag_before",
            "\tvar database_tag_assigned: bool = database_tag_before == null or str(database_tag_before).is_empty()",
            "\tif database_tag_assigned:",
            "\t\tdatabase_tag_after = category_name",
            '\treturn {"source_owner": "PortGame.source_block_post_init_database_tag_state", "source": "core/src/mindustry/world/Block.java", "method": "public void postInit(){", "database_tag_guard_expr": "if(databaseTag == null || databaseTag.isEmpty()){", "database_tag_assign_expr": "databaseTag = category.name();", "super_post_init_expr": "super.postInit();", "database_tag_before": database_tag_before, "category_name": category_name, "database_tag_after": database_tag_after, "database_tag_assigned": database_tag_assigned}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "init"
        and len(method.get("parameters", [])) == 0
    ):
        return [
            '\tvar init_bridge_mode: String = str(get_meta("mindustry_init_bridge_mode", "destroy_sound"))',
            '\tif init_bridge_mode == "custom_shadow":',
            "\t\tvar custom_shadow: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\t\tvar has_shadow_before: bool = bool(_args[1] if _args.size() > 1 else true)",
            "\t\tvar has_shadow_after: bool = has_shadow_before",
            "\t\tvar has_shadow_assigned: bool = custom_shadow",
            "\t\tif has_shadow_assigned:",
            "\t\t\thas_shadow_after = false",
            '\t\treturn {"source_owner": "PortGame.source_block_init_custom_shadow_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "custom_shadow_comment": "//disable standard shadow", "custom_shadow_guard_expr": "if(customShadow){", "has_shadow_assign_expr": "hasShadow = false;", "custom_shadow": custom_shadow, "has_shadow_before": has_shadow_before, "has_shadow_after": has_shadow_after, "has_shadow_assigned": has_shadow_assigned}',
            '\tif init_bridge_mode == "under_bullets":',
            "\t\tvar under_bullets: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\t\tvar priority_before: Variant = _args[1] if _args.size() > 1 else null",
            "\t\tvar priority_after: Variant = priority_before",
            "\t\tvar priority_assigned: bool = under_bullets",
            "\t\tif priority_assigned:",
            '\t\t\tpriority_after = "TargetPriority.under"',
            '\t\treturn {"source_owner": "PortGame.source_block_init_under_bullets_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "under_bullets_guard_expr": "if(underBullets){", "priority_assign_expr": "priority = TargetPriority.under;", "target_priority_under_expr": "TargetPriority.under", "under_bullets": under_bullets, "priority_before": priority_before, "priority_after": priority_after, "priority_assigned": priority_assigned}',
            '\tif init_bridge_mode == "fog_radius_flag":',
            "\t\tvar fog_radius: int = int(_args[0] if _args.size() > 0 else -1)",
            "\t\tvar flags_before: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []",
            "\t\tvar flags_after: Array = flags_before.duplicate()",
            "\t\tvar has_fog_radius_flag_added: bool = fog_radius > 0",
            '\t\tif has_fog_radius_flag_added and not flags_after.has("BlockFlag.hasFogRadius"):',
            '\t\t\tflags_after.append("BlockFlag.hasFogRadius")',
            '\t\treturn {"source_owner": "PortGame.source_block_init_fog_radius_flag_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "fog_radius_guard_expr": "if(fogRadius > 0){", "flags_assign_expr": "flags = flags.with(BlockFlag.hasFogRadius);", "block_flag_has_fog_radius_expr": "BlockFlag.hasFogRadius", "fog_radius": fog_radius, "flags_before": flags_before, "flags_after": flags_after, "has_fog_radius_flag_added": has_fog_radius_flag_added}',
            '\tif init_bridge_mode == "sync_flag":',
            "\t\tvar sync_value: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\t\tvar flags_before: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []",
            "\t\tvar flags_after: Array = flags_before.duplicate()",
            "\t\tvar synced_flag_added: bool = sync_value",
            '\t\tif synced_flag_added and not flags_after.has("BlockFlag.synced"):',
            '\t\t\tflags_after.append("BlockFlag.synced")',
            '\t\treturn {"source_owner": "PortGame.source_block_init_sync_flag_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "sync_guard_expr": "if(sync){", "flags_assign_expr": "flags = flags.with(BlockFlag.synced);", "block_flag_synced_expr": "BlockFlag.synced", "sync": sync_value, "flags_before": flags_before, "flags_after": flags_after, "synced_flag_added": synced_flag_added}',
            '\tif init_bridge_mode == "health_scaled":',
            "\t\tvar health_before: int = int(_args[0] if _args.size() > 0 else -1)",
            "\t\tvar health_size_value: int = int(_args[1] if _args.size() > 1 else 1)",
            "\t\tvar scaled_health: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\t\tvar health_after: int = health_before",
            "\t\tvar health_assigned: bool = health_before == -1 and scaled_health >= 0.0",
            "\t\tif health_assigned:",
            "\t\t\thealth_after = int(health_size_value * health_size_value * scaled_health)",
            '\t\treturn {"source_owner": "PortGame.source_block_init_health_scaled_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "health_comment": "//initialize default health based on size", "health_guard_expr": "if(health == -1){", "round_init_expr": "boolean round = false;", "scaled_health_negative_guard_expr": "if(scaledHealth < 0){", "health_assign_expr": "health = round ? Mathf.round(size * size * scaledHealth, 5) : (int)(size * size * scaledHealth);", "int_cast_expr": "(int)(size * size * scaledHealth)", "health_before": health_before, "size": health_size_value, "scaled_health": scaled_health, "round": false, "health_after": health_after, "health_assigned": health_assigned}',
            '\tif init_bridge_mode == "health_requirements_scaling":',
            "\t\tvar health_before: int = int(_args[0] if _args.size() > 0 else -1)",
            "\t\tvar requirements_health_size_value: int = int(_args[1] if _args.size() > 1 else 1)",
            "\t\tvar scaled_health_before: float = float(_args[2] if _args.size() > 2 else -1.0)",
            "\t\tvar requirement_health_scalings: Array = (_args[3] as Array).duplicate() if _args.size() > 3 and _args[3] is Array else []",
            "\t\tvar health_assigned: bool = health_before == -1 and scaled_health_before < 0.0",
            "\t\tvar scaling: float = 1.0",
            "\t\tfor health_scaling in requirement_health_scalings:",
            "\t\t\tscaling += float(health_scaling)",
            "\t\tvar scaled_health_after: float = 40.0 * scaling if health_assigned else scaled_health_before",
            "\t\tvar health_after: int = health_before",
            "\t\tif health_assigned:",
            "\t\t\thealth_after = int(float(requirements_health_size_value * requirements_health_size_value) * scaled_health_after / 5.0) * 5",
            '\t\treturn {"source_owner": "PortGame.source_block_init_health_requirements_scaling_state", "source": "core/src/mindustry/world/Block.java", "item_source": "core/src/mindustry/type/Item.java", "arc_mathf_source": "arc-core/src/arc/math/Mathf.java", "method": "public void init(){", "super_init_expr": "super.init();", "health_comment": "//initialize default health based on size", "health_guard_expr": "if(health == -1){", "scaled_health_negative_guard_expr": "if(scaledHealth < 0){", "scaled_health_default_expr": "scaledHealth = 40;", "scaling_init_expr": "float scaling = 1f;", "requirements_loop_expr": "for(var stack : requirements){", "health_scaling_add_expr": "scaling += stack.item.healthScaling;", "item_health_scaling_field_expr": "public float healthScaling = 0f;", "scaled_health_multiply_expr": "scaledHealth *= scaling;", "round_true_expr": "round = true;", "mathf_round_expr": "Mathf.round(size * size * scaledHealth, 5)", "mathf_round_step_expr": "return (int)(value / step) * step;", "health_before": health_before, "size": requirements_health_size_value, "scaled_health_before": scaled_health_before, "requirement_health_scalings": requirement_health_scalings, "scaling": scaling, "scaled_health_after": scaled_health_after, "round": health_assigned, "health_after": health_after, "health_assigned": health_assigned}',
            '\tif init_bridge_mode == "clip_size":',
            "\t\tvar clip_size_before: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\t\tvar clip_size_size_value: int = int(_args[1] if _args.size() > 1 else 1)",
            "\t\tvar source_tilesize: float = float(_args[2] if _args.size() > 2 else 8.0)",
            "\t\tvar size_tilesize: float = float(clip_size_size_value) * source_tilesize",
            "\t\tvar clip_size_after: float = max(clip_size_before, size_tilesize)",
            '\t\treturn {"source_owner": "PortGame.source_block_init_clip_size_state", "source": "core/src/mindustry/world/Block.java", "vars_source": "core/src/mindustry/Vars.java", "method": "public void init(){", "super_init_expr": "super.init();", "clip_size_expr": "clipSize = Math.max(clipSize, size * tilesize);", "tilesize_comment": "/** size of tiles in units */", "tilesize_field_expr": "public static final int tilesize = 8;", "clip_size_before": clip_size_before, "size": clip_size_size_value, "source_tilesize": source_tilesize, "size_tilesize": size_tilesize, "clip_size_after": clip_size_after}',
            '\tif init_bridge_mode == "light_clip_size":',
            "\t\tvar light_clip_size_before: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\t\tvar clip_size: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\t\tvar light_clip_size_after: float = max(light_clip_size_before, clip_size)",
            '\t\treturn {"source_owner": "PortGame.source_block_init_light_clip_size_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "clip_size_expr": "clipSize = Math.max(clipSize, size * tilesize);", "light_clip_size_expr": "lightClipSize = Math.max(lightClipSize, clipSize);", "light_clip_size_before": light_clip_size_before, "clip_size": clip_size, "light_clip_size_after": light_clip_size_after}',
            '\tif init_bridge_mode == "liquid_light":',
            "\t\tvar has_liquids: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\t\tvar draw_liquid_light: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\t\tvar emit_light_before: bool = bool(_args[2] if _args.size() > 2 else false)",
            "\t\tvar light_clip_size_before: float = float(_args[3] if _args.size() > 3 else 0.0)",
            "\t\tvar liquid_light_size_value: int = int(_args[4] if _args.size() > 4 else 1)",
            "\t\tvar liquid_light_gate: bool = has_liquids and draw_liquid_light",
            "\t\tvar liquid_light_clip_size: float = float(liquid_light_size_value) * 30.0 * 2.0",
            "\t\tvar emit_light_after: bool = true if liquid_light_gate else emit_light_before",
            "\t\tvar light_clip_size_after: float = max(light_clip_size_before, liquid_light_clip_size) if liquid_light_gate else light_clip_size_before",
            '\t\treturn {"source_owner": "PortGame.source_block_init_liquid_light_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "liquid_light_guard_expr": "if(hasLiquids && drawLiquidLight){", "emit_light_assign_expr": "emitLight = true;", "light_clip_size_expr": "lightClipSize = Math.max(lightClipSize, size * 30f * 2f);", "has_liquids": has_liquids, "draw_liquid_light": draw_liquid_light, "emit_light_before": emit_light_before, "light_clip_size_before": light_clip_size_before, "size": liquid_light_size_value, "liquid_light_gate": liquid_light_gate, "liquid_light_clip_size": liquid_light_clip_size, "emit_light_after": emit_light_after, "light_clip_size_after": light_clip_size_after}',
            '\tif init_bridge_mode == "liquid_capacity_default":',
            "\t\tvar liquid_capacity_before: float = float(_args[0] if _args.size() > 0 else -1.0)",
            "\t\tvar liquid_capacity_assigned: bool = liquid_capacity_before < 0.0",
            "\t\tvar consume_amount: float = 1.0",
            "\t\tvar liquid_capacity_after: int = int(10.0 * consume_amount + 16384.5) - 16384 if liquid_capacity_assigned else int(liquid_capacity_before)",
            '\t\treturn {"source_owner": "PortGame.source_block_init_liquid_capacity_default_state", "source": "core/src/mindustry/world/Block.java", "arc_mathf_source": "arc-core/src/arc/math/Mathf.java", "method": "public void init(){", "super_init_expr": "super.init();", "liquid_capacity_comment": "//some blocks don\'t have hasLiquids, but have liquid consumers/liquid capacity", "liquid_capacity_guard_expr": "if(liquidCapacity < 0){", "consume_amount_default_expr": "float consumeAmount = 1f;", "consume_builder_loop_expr": "for(var cons : consumeBuilder){", "liquid_capacity_assign_expr": "liquidCapacity = Mathf.round(10f * consumeAmount);", "mathf_round_expr": "return (int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;", "liquid_capacity_before": liquid_capacity_before, "consume_amount": consume_amount, "liquid_capacity_assigned": liquid_capacity_assigned, "liquid_capacity_after": liquid_capacity_after}',
            '\tif init_bridge_mode == "emit_light_radius":',
            "\t\tvar emit_light: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\t\tvar light_clip_size_before: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\t\tvar light_radius: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\t\tvar light_radius_clip_size: float = light_radius * 2.0",
            "\t\tvar light_clip_size_after: float = max(light_clip_size_before, light_radius_clip_size) if emit_light else light_clip_size_before",
            '\t\treturn {"source_owner": "PortGame.source_block_init_emit_light_radius_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "emit_light_guard_expr": "if(emitLight){", "light_clip_size_expr": "lightClipSize = Math.max(lightClipSize, lightRadius * 2f);", "emit_light": emit_light, "light_clip_size_before": light_clip_size_before, "light_radius": light_radius, "light_radius_clip_size": light_radius_clip_size, "light_clip_size_after": light_clip_size_after}',
            '\tif init_bridge_mode == "accepts_items":',
            '\t\tvar block_group: Variant = _args[0] if _args.size() > 0 else ""',
            '\t\tvar category_value: Variant = _args[1] if _args.size() > 1 else ""',
            "\t\tvar accepts_items_before: bool = bool(_args[2] if _args.size() > 2 else false)",
            '\t\tvar accepts_items_gate: bool = block_group == "BlockGroup.transportation" or category_value == "Category.distribution"',
            "\t\tvar accepts_items_after: bool = true if accepts_items_gate else accepts_items_before",
            '\t\treturn {"source_owner": "PortGame.source_block_init_accepts_items_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "accepts_items_guard_expr": "if(group == BlockGroup.transportation || category == Category.distribution){", "accepts_items_assign_expr": "acceptsItems = true;", "block_group": block_group, "category": category_value, "accepts_items_before": accepts_items_before, "accepts_items_gate": accepts_items_gate, "accepts_items_after": accepts_items_after}',
            '\tif init_bridge_mode == "offset":',
            "\t\tvar offset_size_value: int = int(_args[0] if _args.size() > 0 else 1)",
            "\t\tvar source_tilesize: float = float(_args[1] if _args.size() > 1 else 8.0)",
            "\t\tvar offset_after: float = float((offset_size_value + 1) % 2) * source_tilesize / 2.0",
            "\t\tvar size_offset_after: int = -int(float(offset_size_value - 1) / 2.0)",
            '\t\treturn {"source_owner": "PortGame.source_block_init_offset_state", "source": "core/src/mindustry/world/Block.java", "vars_source": "core/src/mindustry/Vars.java", "method": "public void init(){", "super_init_expr": "super.init();", "offset_expr": "offset = ((size + 1) % 2) * tilesize / 2f;", "size_offset_expr": "sizeOffset = -((size - 1) / 2);", "tilesize_field_expr": "public static final int tilesize = 8;", "size": offset_size_value, "source_tilesize": source_tilesize, "offset_after": offset_after, "size_offset_after": size_offset_after}',
            '\tif init_bridge_mode == "build_time_requirements":',
            "\t\tvar build_time_before: float = float(_args[0] if _args.size() > 0 else -1.0)",
            "\t\tvar requirement_stacks: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []",
            "\t\tvar requirements_length: int = requirement_stacks.size()",
            "\t\tvar build_time_assigned: bool = requirement_stacks.size() > 0 and build_time_before < 0.0",
            "\t\tvar build_time_after: float = 0.0 if build_time_assigned else build_time_before",
            "\t\tif build_time_assigned:",
            "\t\t\tfor stack in requirement_stacks:",
            "\t\t\t\tif stack is Dictionary:",
            "\t\t\t\t\tbuild_time_after += float(stack.get(\"amount\", 0)) * float(stack.get(\"cost\", 1.0))",
            '\t\treturn {"source_owner": "PortGame.source_block_init_build_time_requirements_state", "source": "core/src/mindustry/world/Block.java", "item_source": "core/src/mindustry/type/Item.java", "item_stack_source": "core/src/mindustry/type/ItemStack.java", "method": "public void init(){", "super_init_expr": "super.init();", "build_time_guard_expr": "if(requirements.length > 0 && buildTime < 0){", "build_time_zero_expr": "buildTime = 0f;", "requirements_loop_expr": "for(ItemStack stack : requirements){", "build_time_add_expr": "buildTime += stack.amount * stack.item.cost;", "item_cost_field_expr": "public float cost = 1f;", "itemstack_amount_field_expr": "public int amount = 0;", "build_time_before": build_time_before, "requirement_stacks": requirement_stacks, "requirements_length": requirements_length, "build_time_assigned": build_time_assigned, "build_time_after": build_time_after}',
            '\tif init_bridge_mode == "build_time_default":',
            "\t\tvar default_build_time_before: float = float(_args[0] if _args.size() > 0 else -1.0)",
            "\t\tvar build_time_assigned: bool = default_build_time_before < 0.0",
            "\t\tvar build_time_after: float = 20.0 if build_time_assigned else default_build_time_before",
            '\t\treturn {"source_owner": "PortGame.source_block_init_build_time_default_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "build_time_guard_expr": "if(buildTime < 0){", "build_time_default_expr": "buildTime = 20f;", "build_time_before": default_build_time_before, "build_time_assigned": build_time_assigned, "build_time_after": build_time_after}',
            '\tif init_bridge_mode == "build_time_multiplier":',
            "\t\tvar multiplier_build_time_before: float = float(_args[0] if _args.size() > 0 else 20.0)",
            "\t\tvar build_cost_multiplier: float = float(_args[1] if _args.size() > 1 else 1.0)",
            "\t\tvar build_time_after: float = multiplier_build_time_before * build_cost_multiplier",
            '\t\treturn {"source_owner": "PortGame.source_block_init_build_time_multiplier_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "build_cost_multiplier_field_expr": "public float buildCostMultiplier = 1f;", "build_time_multiplier_expr": "buildTime *= buildCostMultiplier;", "build_time_before": multiplier_build_time_before, "build_cost_multiplier": build_cost_multiplier, "build_time_after": build_time_after}',
            '\tif init_bridge_mode == "consumer_arrays":',
            "\t\tvar consumer_builder_entries: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []",
            "\t\tvar consumers: Array = consumer_builder_entries.duplicate()",
            "\t\tvar optional_consumers: Array = []",
            "\t\tvar non_optional_consumers: Array = []",
            "\t\tvar update_consumers: Array = []",
            "\t\tfor consumer in consumer_builder_entries:",
            "\t\t\tif not consumer is Dictionary:",
            "\t\t\t\tcontinue",
            '\t\t\tvar ignored: bool = bool(consumer.get("ignored", false))',
            '\t\t\tif bool(consumer.get("optional", false)) and not ignored:',
            "\t\t\t\toptional_consumers.append(consumer)",
            '\t\t\tif not bool(consumer.get("optional", false)) and not ignored:',
            "\t\t\t\tnon_optional_consumers.append(consumer)",
            '\t\t\tif bool(consumer.get("update", true)) and not ignored:',
            "\t\t\t\tupdate_consumers.append(consumer)",
            "\t\tvar has_consumers: bool = consumers.size() > 0",
            '\t\treturn {"source_owner": "PortGame.source_block_init_consumer_arrays_state", "source": "core/src/mindustry/world/Block.java", "consume_source": "core/src/mindustry/world/consumers/Consume.java", "method": "public void init(){", "super_init_expr": "super.init();", "consumers_expr": "consumers = consumeBuilder.toArray(Consume.class);", "optional_consumers_expr": "optionalConsumers = consumeBuilder.select(consume -> consume.optional && !consume.ignore()).toArray(Consume.class);", "non_optional_consumers_expr": "nonOptionalConsumers = consumeBuilder.select(consume -> !consume.optional && !consume.ignore()).toArray(Consume.class);", "update_consumers_expr": "updateConsumers = consumeBuilder.select(consume -> consume.update && !consume.ignore()).toArray(Consume.class);", "has_consumers_expr": "hasConsumers = consumers.length > 0;", "consume_optional_field_expr": "public boolean optional;", "consume_update_field_expr": "public boolean update = true;", "consume_ignore_method_expr": "public boolean ignore(){", "consume_builder": consumer_builder_entries, "consumers": consumers, "optional_consumers": optional_consumers, "non_optional_consumers": non_optional_consumers, "update_consumers": update_consumers, "has_consumers": has_consumers}',
            '\tif init_bridge_mode == "item_liquid_filters":',
            "\t\tvar content_items_size: int = int(_args[0] if _args.size() > 0 else 0)",
            "\t\tvar content_liquids_size: int = int(_args[1] if _args.size() > 1 else 0)",
            "\t\tvar item_filter: Array = []",
            "\t\tfor _i in range(max(content_items_size, 0)):",
            "\t\t\titem_filter.append(false)",
            "\t\tvar liquid_filter: Array = []",
            "\t\tfor _i in range(max(content_liquids_size, 0)):",
            "\t\t\tliquid_filter.append(false)",
            '\t\treturn {"source_owner": "PortGame.source_block_init_item_liquid_filters_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "item_filter_expr": "itemFilter = new boolean[content.items().size];", "liquid_filter_expr": "liquidFilter = new boolean[content.liquids().size];", "content_items_size": content_items_size, "content_liquids_size": content_liquids_size, "item_filter": item_filter, "liquid_filter": liquid_filter, "item_filter_size": item_filter.size(), "liquid_filter_size": liquid_filter.size()}',
            '\tif init_bridge_mode == "consumer_apply_loop":',
            "\t\tvar consumer_entries: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []",
            "\t\tvar apply_calls: Array = []",
            "\t\tfor consumer in consumer_entries:",
            '\t\t\tapply_calls.append({"call": "cons.apply(this);", "consumer": consumer, "block_arg": "this"})',
            '\t\treturn {"source_owner": "PortGame.source_block_init_consumer_apply_loop_state", "source": "core/src/mindustry/world/Block.java", "consume_source": "core/src/mindustry/world/consumers/Consume.java", "method": "public void init(){", "super_init_expr": "super.init();", "consumers_loop_expr": "for(Consume cons : consumers){", "consume_apply_expr": "cons.apply(this);", "consume_apply_method_expr": "public void apply(Block block){", "consumers": consumer_entries, "apply_calls": apply_calls, "apply_call_count": apply_calls.size()}',
            '\tif init_bridge_mode == "set_bars_call":',
            '\t\tvar set_bars_call: Dictionary = {"call": "setBars();", "method": "public void setBars(){"}',
            '\t\treturn {"source_owner": "PortGame.source_block_init_set_bars_call_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "set_bars_expr": "setBars();", "set_bars_method_expr": "public void setBars(){", "health_bar_expr": "addBar(\\"health\\", entity -> new Bar(\\"stat.health\\", Pal.health, entity::healthf).blink(Color.white));", "set_bars_call": set_bars_call, "set_bars_called": true}',
            '\tif init_bridge_mode == "stats_categories":',
            "\t\tvar stats_use_categories_before: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\t\tvar stats_use_categories_after: bool = true",
            '\t\treturn {"source_owner": "PortGame.source_block_init_stats_categories_state", "source": "core/src/mindustry/world/Block.java", "stats_source": "core/src/mindustry/world/meta/Stats.java", "method": "public void init(){", "super_init_expr": "super.init();", "stats_use_categories_expr": "stats.useCategories = true;", "stats_use_categories_field_expr": "public boolean useCategories = false;", "stats_use_categories_before": stats_use_categories_before, "stats_use_categories_after": stats_use_categories_after}',
            '\tif init_bridge_mode == "logic_configurable":',
            "\t\tvar logic_configurable_before: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\t\tvar config_key_assignable_to_unlockable_content: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\t\tvar logic_configurable_after: bool = logic_configurable_before or config_key_assignable_to_unlockable_content",
            '\t\treturn {"source_owner": "PortGame.source_block_init_logic_configurable_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "logic_configurable_field_expr": "public boolean logicConfigurable = false;", "logic_configurable_guard_expr": "if(!logicConfigurable){", "configurations_each_expr": "configurations.each((key, val) -> {", "unlockable_assignable_expr": "if(UnlockableContent.class.isAssignableFrom(key)){", "logic_configurable_assignment_expr": "logicConfigurable = true;", "logic_configurable_before": logic_configurable_before, "config_key_assignable_to_unlockable_content": config_key_assignable_to_unlockable_content, "logic_configurable_after": logic_configurable_after}',
            '\tif init_bridge_mode == "buffered_power":',
            "\t\tvar outputs_power: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\t\tvar has_cons_power: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\t\tvar cons_power_buffered_before: bool = bool(_args[2] if _args.size() > 2 else false)",
            "\t\tvar buffered_power_disabled: bool = (not outputs_power) and has_cons_power and cons_power_buffered_before",
            "\t\tvar cons_power_buffered_after: bool = false if buffered_power_disabled else cons_power_buffered_before",
            '\t\treturn {"source_owner": "PortGame.source_block_init_buffered_power_state", "source": "core/src/mindustry/world/Block.java", "consume_power_source": "core/src/mindustry/world/consumers/ConsumePower.java", "method": "public void init(){", "super_init_expr": "super.init();", "outputs_power_field_expr": "public boolean outputsPower = false;", "cons_power_field_expr": "public @Nullable ConsumePower consPower;", "consume_power_buffered_field_expr": "public boolean buffered;", "buffered_power_guard_expr": "if(!outputsPower && consPower != null && consPower.buffered){", "buffered_power_warn_expr": "Log.warn(\\"Consumer using buffered power: @. Disabling buffered power.\\", name);", "buffered_power_disable_expr": "consPower.buffered = false;", "outputs_power": outputs_power, "has_cons_power": has_cons_power, "cons_power_buffered_before": cons_power_buffered_before, "buffered_power_disabled": buffered_power_disabled, "cons_power_buffered_after": cons_power_buffered_after}',
            '\tif init_bridge_mode == "sandbox_visibility":',
            '\t\tvar build_visibility: String = str(_args[0] if _args.size() > 0 else "BuildVisibility.hidden")',
            "\t\tvar hide_details_before: bool = bool(_args[1] if _args.size() > 1 else true)",
            '\t\tvar sandbox_visibility_applied: bool = build_visibility == "BuildVisibility.sandboxOnly"',
            "\t\tvar hide_details_after: bool = false if sandbox_visibility_applied else hide_details_before",
            '\t\treturn {"source_owner": "PortGame.source_block_init_sandbox_visibility_state", "source": "core/src/mindustry/world/Block.java", "build_visibility_source": "core/src/mindustry/world/meta/BuildVisibility.java", "unlockable_content_source": "core/src/mindustry/ctype/UnlockableContent.java", "method": "public void init(){", "super_init_expr": "super.init();", "build_visibility_field_expr": "public BuildVisibility buildVisibility = BuildVisibility.hidden;", "hide_details_field_expr": "public boolean hideDetails = true;", "sandbox_visibility_guard_expr": "if(buildVisibility == BuildVisibility.sandboxOnly){", "sandbox_only_expr": "sandboxOnly = new BuildVisibility(() -> Vars.state == null || Vars.state.rules.infiniteResources),", "hide_details_assign_expr": "hideDetails = false;", "build_visibility": build_visibility, "hide_details_before": hide_details_before, "sandbox_visibility_applied": sandbox_visibility_applied, "hide_details_after": hide_details_after}',
            '\tif init_bridge_mode == "place_sound":',
            '\t\tvar place_sound_before: Variant = _args[0] if _args.size() > 0 else "Sounds.unset"',
            "\t\tvar place_size_value: int = int(_args[1] if _args.size() > 1 else 1)",
            "\t\tvar place_sound_after: Variant = place_sound_before",
            '\t\tvar place_sound_assigned: bool = place_sound_before == "Sounds.unset"',
            "\t\tif place_sound_assigned:",
            "\t\t\tif place_size_value >= 3:",
            '\t\t\t\tplace_sound_after = "Sounds.blockPlace3"',
            "\t\t\telif place_size_value >= 2:",
            '\t\t\t\tplace_sound_after = "Sounds.blockPlace2"',
            "\t\t\telse:",
            '\t\t\t\tplace_sound_after = "Sounds.blockPlace1"',
            '\t\treturn {"source_owner": "PortGame.source_block_init_place_sound_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "place_sound_guard_expr": "if(placeSound == Sounds.unset){", "place_sound_assign_expr": "placeSound =", "place_sound_size_3_expr": "size >= 3 ? Sounds.blockPlace3 :", "place_sound_size_2_expr": "size >= 2 ? Sounds.blockPlace2 :", "place_sound_size_1_expr": "Sounds.blockPlace1;", "place_sound_before": place_sound_before, "size": place_size_value, "place_sound_after": place_sound_after, "place_sound_assigned": place_sound_assigned}',
            '\tif init_bridge_mode == "break_sound":',
            '\t\tvar break_sound_before: Variant = _args[0] if _args.size() > 0 else "Sounds.unset"',
            "\t\tvar break_size_value: int = int(_args[1] if _args.size() > 1 else 1)",
            "\t\tvar break_sound_after: Variant = break_sound_before",
            '\t\tvar break_sound_assigned: bool = break_sound_before == "Sounds.unset"',
            "\t\tif break_sound_assigned:",
            "\t\t\tif break_size_value >= 3:",
            '\t\t\t\tbreak_sound_after = "Sounds.blockBreak3"',
            "\t\t\telif break_size_value >= 2:",
            '\t\t\t\tbreak_sound_after = "Sounds.blockBreak2"',
            "\t\t\telse:",
            '\t\t\t\tbreak_sound_after = "Sounds.blockBreak1"',
            '\t\treturn {"source_owner": "PortGame.source_block_init_break_sound_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "break_sound_guard_expr": "if(breakSound == Sounds.unset){", "break_sound_assign_expr": "breakSound =", "break_sound_size_3_expr": "size >= 3 ? Sounds.blockBreak3 :", "break_sound_size_2_expr": "size >= 2 ? Sounds.blockBreak2 :", "break_sound_size_1_expr": "Sounds.blockBreak1;", "break_sound_before": break_sound_before, "size": break_size_value, "break_sound_after": break_sound_after, "break_sound_assigned": break_sound_assigned}',
            '\tvar destroy_sound_before: Variant = _args[0] if _args.size() > 0 else "Sounds.unset"',
            "\tvar size_value: int = int(_args[1] if _args.size() > 1 else 1)",
            "\tvar destroy_sound_after: Variant = destroy_sound_before",
            '\tvar destroy_sound_assigned: bool = destroy_sound_before == "Sounds.unset"',
            "\tif destroy_sound_assigned:",
            "\t\tif size_value >= 3:",
            '\t\t\tdestroy_sound_after = "Sounds.blockExplode3"',
            "\t\telif size_value >= 2:",
            '\t\t\tdestroy_sound_after = {"type": "RandomSound", "sounds": ["Sounds.blockExplode2", "Sounds.blockExplode2Alt"]}',
            "\t\telse:",
            '\t\t\tdestroy_sound_after = {"type": "RandomSound", "sounds": ["Sounds.blockExplode1", "Sounds.blockExplode1Alt"]}',
            '\treturn {"source_owner": "PortGame.source_block_init_destroy_sound_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "destroy_sound_guard_expr": "if(destroySound == Sounds.unset){", "destroy_sound_assign_expr": "destroySound =", "destroy_sound_size_3_expr": "size >= 3 ? Sounds.blockExplode3 :", "destroy_sound_size_2_expr": "size >= 2 ? new RandomSound(Sounds.blockExplode2, Sounds.blockExplode2Alt) :", "destroy_sound_size_1_expr": "new RandomSound(Sounds.blockExplode1, Sounds.blockExplode1Alt);", "destroy_sound_before": destroy_sound_before, "size": size_value, "destroy_sound_after": destroy_sound_after, "destroy_sound_assigned": destroy_sound_assigned}',
        ]
    if (
        java_file.get("path") == "mindustry/world/Block.java"
        and type_entry.get("name") == "Block"
        and method.get("name") == "consumePowerDynamic"
        and len(method.get("parameters", [])) == 1
    ):
        return [
            "\tvar usage: Variant = _args[0] if _args.size() > 0 else null",
            '\tvar constructed_consume: Dictionary = {"type": "ConsumePowerDynamic", "usage": usage}',
            '\treturn {"source_owner": "PortGame.source_block_consume_power_dynamic_state", "source": "core/src/mindustry/world/Block.java", "comment": "Creates a consumer that consumes a dynamic amount of power.", "method": "public <T extends Building> ConsumePower consumePowerDynamic(Floatf<T> usage){", "return_expr": "return consume(new ConsumePowerDynamic((Floatf<Building>)usage));", "constructor_expr": "new ConsumePowerDynamic((Floatf<Building>)usage)", "usage_cast_expr": "(Floatf<Building>)usage", "consume_call_expr": "consume(new ConsumePowerDynamic((Floatf<Building>)usage))", "usage": usage, "constructed_consume": constructed_consume, "consume_called": true}',
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/ContinuousTurret.java"
        and type_entry.get("name") == "ContinuousTurret"
        and method.get("name") == "setStats"
    ):
        return [
            "\tvar shoot_type: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar object_map_call: Dictionary = {\"call\": \"ObjectMap.of(this, shootType)\", \"this\": \"ContinuousTurret\", \"shoot_type\": shoot_type}",
            "\tvar ammo_values_call: Dictionary = {\"call\": \"StatValues.ammo(ObjectMap.of(this, shootType))\", \"object_map_call\": object_map_call}",
            "\tvar stats_add_call: Dictionary = {\"call\": \"stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));\", \"stat\": \"Stat.ammo\", \"ammo_values_call\": ammo_values_call}",
            "\treturn {\"source_owner\": \"PortGame.source_continuous_turret_set_stats_state\", \"method\": \"public void setStats(){\", \"override_expr\": \"@Override\", \"super_set_stats_expr\": \"super.setStats();\", \"stats_add_expr\": \"stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));\", \"remove_reload_expr\": \"stats.remove(Stat.reload);\", \"remove_inaccuracy_expr\": \"stats.remove(Stat.inaccuracy);\", \"shoot_type\": shoot_type, \"super_set_stats_called\": true, \"stats_add_called\": true, \"remove_reload_called\": true, \"remove_inaccuracy_called\": true, \"object_map_call\": object_map_call, \"ammo_values_call\": ammo_values_call, \"stats_add_call\": stats_add_call}",
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
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/TractorBeamTurret.java"
        and type_entry.get("name") == "TractorBeamTurret"
        and method.get("name") == "icons"
    ):
        return [
            "\tvar base_region: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar region: Variant = _args[1] if _args.size() > 1 else null",
            "\tvar icons: Array = [base_region, region]",
            "\treturn {\"source_owner\": \"PortGame.source_tractor_beam_turret_icons_state\", \"method\": \"public TextureRegion[] icons(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return new TextureRegion[]{baseRegion, region};\", \"base_region\": base_region, \"region\": region, \"icons\": icons}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/TractorBeamTurret.java"
        and type_entry.get("name") == "TractorBeamTurret"
        and method.get("name") == "setStats"
    ):
        return [
            "\tvar target_air: bool = bool(_args[0] if _args.size() > 0 else true)",
            "\tvar target_ground: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar damage: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar targets_air_stat_call: Dictionary = {\"call\": \"stats.add(Stat.targetsAir, targetAir);\", \"stat\": \"Stat.targetsAir\", \"value\": target_air}",
            "\tvar targets_ground_stat_call: Dictionary = {\"call\": \"stats.add(Stat.targetsGround, targetGround);\", \"stat\": \"Stat.targetsGround\", \"value\": target_ground}",
            "\tvar damage_per_second: float = damage * 60.0",
            "\tvar damage_stat_added: bool = damage > 0.0",
            "\tvar damage_stat_call: Dictionary = {}",
            "\tif damage_stat_added:",
            "\t\tdamage_stat_call = {\"call\": \"stats.add(Stat.damage, damage * 60f, StatUnit.perSecond);\", \"stat\": \"Stat.damage\", \"value\": damage_per_second, \"unit\": \"StatUnit.perSecond\"}",
            "\treturn {\"source_owner\": \"PortGame.source_tractor_beam_turret_set_stats_state\", \"method\": \"public void setStats(){\", \"override_expr\": \"@Override\", \"super_set_stats_expr\": \"super.setStats();\", \"targets_air_stat_expr\": \"stats.add(Stat.targetsAir, targetAir);\", \"targets_ground_stat_expr\": \"stats.add(Stat.targetsGround, targetGround);\", \"damage_stat_expr\": \"if(damage > 0) stats.add(Stat.damage, damage * 60f, StatUnit.perSecond);\", \"target_air\": target_air, \"target_ground\": target_ground, \"damage\": damage, \"super_set_stats_called\": true, \"targets_air_stat_call\": targets_air_stat_call, \"targets_ground_stat_call\": targets_ground_stat_call, \"damage_per_second\": damage_per_second, \"damage_stat_added\": damage_stat_added, \"damage_stat_call\": damage_stat_call}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/TractorBeamTurret.java"
        and type_entry.get("name") == "TractorBeamTurret"
        and method.get("name") == "init"
    ):
        return [
            "\tvar range_value: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar source_tilesize: float = float(_args[1] if _args.size() > 1 else 8.0)",
            "\tvar clip_radius: float = range_value + source_tilesize",
            "\tvar update_clip_radius_call: Dictionary = {\"call\": \"updateClipRadius(range + tilesize);\", \"radius\": clip_radius}",
            "\treturn {\"source_owner\": \"PortGame.source_tractor_beam_turret_init_state\", \"method\": \"public void init(){\", \"override_expr\": \"@Override\", \"super_init_expr\": \"super.init();\", \"update_clip_radius_expr\": \"updateClipRadius(range + tilesize);\", \"range\": range_value, \"tilesize\": source_tilesize, \"clip_radius\": clip_radius, \"super_init_called\": true, \"update_clip_radius_called\": true, \"update_clip_radius_call\": update_clip_radius_call}",
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
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/BaseTurret.java"
        and type_entry.get("name") == "BaseTurret"
        and method.get("name") == "drawPlace"
    ):
        return [
            "\tvar tile_x: int = int(_args[0] if _args.size() > 0 else 0)",
            "\tvar tile_y: int = int(_args[1] if _args.size() > 1 else 0)",
            "\tvar rotation: int = int(_args[2] if _args.size() > 2 else 0)",
            "\tvar valid: bool = bool(_args[3] if _args.size() > 3 else false)",
            "\tvar source_tilesize: float = float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar block_offset: float = float(_args[5] if _args.size() > 5 else 0.0)",
            "\tvar range_value: float = float(_args[6] if _args.size() > 6 else 0.0)",
            "\tvar fog_radius_multiplier: float = float(_args[7] if _args.size() > 7 else 1.0)",
            "\tvar rules_fog: bool = bool(_args[8] if _args.size() > 8 else false)",
            "\tvar dash_circle_x: float = float(tile_x) * source_tilesize + block_offset",
            "\tvar dash_circle_y: float = float(tile_y) * source_tilesize + block_offset",
            "\tvar dash_circle_call: Dictionary = {\"call\": \"Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);\", \"x\": dash_circle_x, \"y\": dash_circle_y, \"radius\": range_value, \"color\": \"Pal.placing\"}",
            "\tvar fog_dash_circle_called: bool = fog_radius_multiplier < 0.99 and rules_fog",
            "\tvar fog_dash_circle_call: Dictionary = {}",
            "\tif fog_dash_circle_called:",
            "\t\tfog_dash_circle_call = {\"call\": \"Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range * fogRadiusMultiplier, Pal.lightishGray);\", \"x\": dash_circle_x, \"y\": dash_circle_y, \"radius\": range_value * fog_radius_multiplier, \"color\": \"Pal.lightishGray\"}",
            "\treturn {\"source_owner\": \"PortGame.source_base_turret_draw_place_state\", \"method\": \"public void drawPlace(int x, int y, int rotation, boolean valid){\", \"override_expr\": \"@Override\", \"super_draw_place_expr\": \"super.drawPlace(x, y, rotation, valid);\", \"dash_circle_expr\": \"Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);\", \"fog_guard_expr\": \"if(fogRadiusMultiplier < 0.99f && state.rules.fog){\", \"fog_dash_circle_expr\": \"Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range * fogRadiusMultiplier, Pal.lightishGray);\", \"tile_x\": tile_x, \"tile_y\": tile_y, \"rotation\": rotation, \"valid\": valid, \"source_tilesize\": source_tilesize, \"block_offset\": block_offset, \"range\": range_value, \"fog_radius_multiplier\": fog_radius_multiplier, \"rules_fog\": rules_fog, \"dash_circle_x\": dash_circle_x, \"dash_circle_y\": dash_circle_y, \"super_draw_place_called\": true, \"dash_circle_call\": dash_circle_call, \"fog_dash_circle_called\": fog_dash_circle_called, \"fog_dash_circle_call\": fog_dash_circle_call}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/BaseTurret.java"
        and type_entry.get("name") == "BaseTurret"
        and method.get("name") == "setStats"
    ):
        return [
            "\tvar range_value: float = float(_args[0] if _args.size() > 0 else 80.0)",
            "\tvar source_tilesize: float = float(_args[1] if _args.size() > 1 else 8.0)",
            "\tvar activation_time: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar shoot_range_blocks: float = range_value / source_tilesize",
            "\tvar shoot_range_stat_call: Dictionary = {\"call\": \"stats.add(Stat.shootRange, range / tilesize, StatUnit.blocks);\", \"stat\": \"Stat.shootRange\", \"value\": shoot_range_blocks, \"unit\": \"StatUnit.blocks\"}",
            "\tvar activation_time_stat_called: bool = activation_time > 0.0",
            "\tvar activation_time_stat_call: Dictionary = {}",
            "\tif activation_time_stat_called:",
            "\t\tactivation_time_stat_call = {\"call\": \"stats.add(Stat.activationTime, activationTime / 60f, StatUnit.seconds);\", \"stat\": \"Stat.activationTime\", \"value\": activation_time / 60.0, \"unit\": \"StatUnit.seconds\"}",
            "\treturn {\"source_owner\": \"PortGame.source_base_turret_set_stats_state\", \"method\": \"public void setStats(){\", \"override_expr\": \"@Override\", \"super_set_stats_expr\": \"super.setStats();\", \"shoot_range_stat_expr\": \"stats.add(Stat.shootRange, range / tilesize, StatUnit.blocks);\", \"activation_time_guard_expr\": \"if(activationTime > 0)\", \"activation_time_stat_expr\": \"stats.add(Stat.activationTime, activationTime / 60f, StatUnit.seconds);\", \"range\": range_value, \"tilesize\": source_tilesize, \"activation_time\": activation_time, \"shoot_range_blocks\": shoot_range_blocks, \"super_set_stats_called\": true, \"shoot_range_stat_call\": shoot_range_stat_call, \"activation_time_stat_called\": activation_time_stat_called, \"activation_time_stat_call\": activation_time_stat_call}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/BaseTurret.java"
        and type_entry.get("name") == "BaseTurret"
        and method.get("name") == "setBars"
    ):
        return [
            "\tvar activation_time: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar entity_activation_timer: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar activation_bar_added: bool = activation_time > 0.0",
            "\tvar activation_timer_positive: bool = entity_activation_timer > 0.0",
            "\tvar activation_bar_fraction: float = 0.0",
            "\tvar activation_bar_text_call: Dictionary = {}",
            "\tvar activation_bar_color: String = \"\"",
            "\tvar activation_bar_call: Dictionary = {}",
            "\tif activation_bar_added:",
            "\t\tactivation_bar_fraction = 1.0 - entity_activation_timer / activation_time",
            "\t\tif activation_timer_positive:",
            "\t\t\tactivation_bar_text_call = {\"call\": \"Core.bundle.format(\\\"bar.activationtimer\\\", Mathf.ceil(entity.activationTimer / 60f))\", \"key\": \"bar.activationtimer\", \"seconds\": ceil(entity_activation_timer / 60.0)}",
            "\t\t\tactivation_bar_color = \"Pal.lightOrange\"",
            "\t\telse:",
            "\t\t\tactivation_bar_text_call = {\"call\": \"Core.bundle.get(\\\"bar.activated\\\")\", \"key\": \"bar.activated\"}",
            "\t\t\tactivation_bar_color = \"Pal.techBlue\"",
            "\t\tactivation_bar_call = {\"call\": \"addBar(\\\"activationtimer\\\", (BaseTurretBuild entity) -> new Bar(...));\", \"name\": \"activationtimer\", \"text_call\": activation_bar_text_call, \"color\": activation_bar_color, \"fraction\": activation_bar_fraction}",
            "\treturn {\"source_owner\": \"PortGame.source_base_turret_set_bars_state\", \"method\": \"public void setBars(){\", \"override_expr\": \"@Override\", \"super_set_bars_expr\": \"super.setBars();\", \"activation_time_guard_expr\": \"if(activationTime > 0){\", \"add_bar_expr\": \"addBar(\\\"activationtimer\\\", (BaseTurretBuild entity) ->\", \"bar_new_expr\": \"new Bar(() ->\", \"bar_text_format_expr\": \"Core.bundle.format(\\\"bar.activationtimer\\\", Mathf.ceil(entity.activationTimer / 60f))\", \"bar_text_get_expr\": \"Core.bundle.get(\\\"bar.activated\\\")\", \"bar_color_expr\": \"() -> (entity.activationTimer > 0)?  Pal.lightOrange : Pal.techBlue\", \"bar_progress_expr\": \"() -> 1 - entity.activationTimer / activationTime\", \"activation_time\": activation_time, \"entity_activation_timer\": entity_activation_timer, \"super_set_bars_called\": true, \"activation_bar_added\": activation_bar_added, \"activation_timer_positive\": activation_timer_positive, \"activation_bar_fraction\": activation_bar_fraction, \"activation_bar_text_call\": activation_bar_text_call, \"activation_bar_color\": activation_bar_color, \"activation_bar_call\": activation_bar_call}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/BaseTurret.java"
        and type_entry.get("name") == "BaseTurret"
        and method.get("name") == "init"
    ):
        return [
            "\tvar coolant_present: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar found_consume_coolant: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar disable_overlap_check: bool = bool(_args[2] if _args.size() > 2 else false)",
            "\tvar place_overlap_range: float = float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar range_value: float = float(_args[4] if _args.size() > 4 else 80.0)",
            "\tvar place_overlap_margin: float = float(_args[5] if _args.size() > 5 else 56.0)",
            "\tvar source_tilesize: float = float(_args[6] if _args.size() > 6 else 8.0)",
            "\tvar fog_radius_multiplier: float = float(_args[7] if _args.size() > 7 else 1.0)",
            "\tvar fog_radius: int = int(_args[8] if _args.size() > 8 else 0)",
            "\tvar find_consumer_called: bool = not coolant_present",
            "\tvar coolant_present_after: bool = coolant_present or found_consume_coolant",
            "\tvar place_overlap_range_after: float = place_overlap_range",
            "\tif not disable_overlap_check:",
            "\t\tplace_overlap_range_after = max(place_overlap_range, range_value + place_overlap_margin)",
            "\tvar computed_fog_radius: int = int(round(range_value / source_tilesize * fog_radius_multiplier))",
            "\tvar fog_radius_after: int = max(computed_fog_radius, fog_radius)",
            "\treturn {\"source_owner\": \"PortGame.source_base_turret_init_state\", \"method\": \"public void init(){\", \"override_expr\": \"@Override\", \"coolant_null_guard_expr\": \"if(coolant == null){\", \"find_consumer_expr\": \"coolant = findConsumer(c -> c instanceof ConsumeCoolant);\", \"check_init_coolant_expr\": \"checkInitCoolant();\", \"overlap_guard_expr\": \"if(!disableOverlapCheck){\", \"place_overlap_range_expr\": \"placeOverlapRange = Math.max(placeOverlapRange, range + placeOverlapMargin);\", \"fog_radius_expr\": \"fogRadius = Math.max(Mathf.round(range / tilesize * fogRadiusMultiplier), fogRadius);\", \"super_init_expr\": \"super.init();\", \"coolant_present\": coolant_present, \"found_consume_coolant\": found_consume_coolant, \"find_consumer_called\": find_consumer_called, \"coolant_present_after\": coolant_present_after, \"check_init_coolant_called\": true, \"disable_overlap_check\": disable_overlap_check, \"place_overlap_range\": place_overlap_range, \"range\": range_value, \"place_overlap_margin\": place_overlap_margin, \"place_overlap_range_after\": place_overlap_range_after, \"tilesize\": source_tilesize, \"fog_radius_multiplier\": fog_radius_multiplier, \"fog_radius\": fog_radius, \"computed_fog_radius\": computed_fog_radius, \"fog_radius_after\": fog_radius_after, \"super_init_called\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/BaseTurret.java"
        and type_entry.get("name") == "BaseTurret"
        and method.get("name") == "reinitializeConsumers"
    ):
        return [
            "\treturn {\"source_owner\": \"PortGame.source_base_turret_reinitialize_consumers_state\", \"method\": \"public void reinitializeConsumers(){\", \"override_expr\": \"@Override\", \"check_init_coolant_expr\": \"checkInitCoolant();\", \"super_reinitialize_consumers_expr\": \"super.reinitializeConsumers();\", \"check_init_coolant_called\": true, \"super_reinitialize_consumers_called\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/BaseTurret.java"
        and type_entry.get("name") == "BaseTurret"
        and method.get("name") == "checkInitCoolant"
    ):
        return [
            "\tvar coolant_present: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar has_consumer: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar update_after: Variant = null",
            "\tvar booster_after: Variant = null",
            "\tvar optional_after: Variant = null",
            "\tif coolant_present:",
            "\t\tupdate_after = false",
            "\t\tbooster_after = true",
            "\t\toptional_after = true",
            "\tvar consume_called: bool = coolant_present and not has_consumer",
            "\treturn {\"source_owner\": \"PortGame.source_base_turret_check_init_coolant_state\", \"method\": \"void checkInitCoolant(){\", \"coolant_guard_expr\": \"if(coolant != null){\", \"update_assign_expr\": \"coolant.update = false;\", \"booster_assign_expr\": \"coolant.booster = true;\", \"optional_assign_expr\": \"coolant.optional = true;\", \"json_comment\": \"//json parsing does not add to consumes\", \"consume_guard_expr\": \"if(!hasConsumer(coolant)) consume(coolant);\", \"coolant_present\": coolant_present, \"has_consumer\": has_consumer, \"update_after\": update_after, \"booster_after\": booster_after, \"optional_after\": optional_after, \"consume_called\": consume_called}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/Turret.java"
        and type_entry.get("name") == "Turret"
        and method.get("name") == "setStats"
    ):
        return [
            "\tvar inaccuracy_value: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar reload_value: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar reload_while_charging: bool = bool(_args[2] if _args.size() > 2 else true)",
            "\tvar shoot_first_shot_delay: float = float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar shoot_shots: float = float(_args[4] if _args.size() > 4 else 1.0)",
            "\tvar target_air: bool = bool(_args[5] if _args.size() > 5 else true)",
            "\tvar target_ground: bool = bool(_args[6] if _args.size() > 6 else true)",
            "\tvar ammo_per_shot: int = int(_args[7] if _args.size() > 7 else 1)",
            "\tvar heat_requirement: float = float(_args[8] if _args.size() > 8 else -1.0)",
            "\tvar max_heat_efficiency: float = float(_args[9] if _args.size() > 9 else 3.0)",
            "\tvar reload_stat_denominator: float = reload_value + (shoot_first_shot_delay if not reload_while_charging else 0.0)",
            "\tvar reload_stat_rate: float = 60.0 / reload_stat_denominator * shoot_shots",
            "\tvar inaccuracy_stat_call: Dictionary = {\"call\": \"stats.add(Stat.inaccuracy, (int)inaccuracy, StatUnit.degrees);\", \"stat\": \"Stat.inaccuracy\", \"value\": int(inaccuracy_value), \"unit\": \"StatUnit.degrees\"}",
            "\tvar reload_stat_call: Dictionary = {\"call\": \"stats.add(Stat.reload, 60f / (reload + (!reloadWhileCharging ? shoot.firstShotDelay : 0f)) * shoot.shots, StatUnit.perSecond);\", \"stat\": \"Stat.reload\", \"value\": reload_stat_rate, \"unit\": \"StatUnit.perSecond\", \"denominator\": reload_stat_denominator}",
            "\tvar targets_air_stat_call: Dictionary = {\"call\": \"stats.add(Stat.targetsAir, targetAir);\", \"stat\": \"Stat.targetsAir\", \"value\": target_air}",
            "\tvar targets_ground_stat_call: Dictionary = {\"call\": \"stats.add(Stat.targetsGround, targetGround);\", \"stat\": \"Stat.targetsGround\", \"value\": target_ground}",
            "\tvar ammo_use_stat_called: bool = ammo_per_shot != 1",
            "\tvar ammo_use_stat_call: Dictionary = {}",
            "\tif ammo_use_stat_called:",
            "\t\tammo_use_stat_call = {\"call\": \"stats.add(Stat.ammoUse, ammoPerShot, StatUnit.perShot);\", \"stat\": \"Stat.ammoUse\", \"value\": ammo_per_shot, \"unit\": \"StatUnit.perShot\"}",
            "\tvar input_heat_stat_called: bool = heat_requirement > 0.0",
            "\tvar input_heat_stat_call: Dictionary = {}",
            "\tif input_heat_stat_called:",
            "\t\tinput_heat_stat_call = {\"call\": \"stats.add(Stat.input, heatRequirement, StatUnit.heatUnits);\", \"stat\": \"Stat.input\", \"value\": heat_requirement, \"unit\": \"StatUnit.heatUnits\"}",
            "\tvar max_efficiency_stat_called: bool = heat_requirement > 0.0 and max_heat_efficiency > 0.0",
            "\tvar max_efficiency_stat_call: Dictionary = {}",
            "\tif max_efficiency_stat_called:",
            "\t\tmax_efficiency_stat_call = {\"call\": \"stats.add(Stat.maxEfficiency, (int)(maxHeatEfficiency * 100f), StatUnit.percent);\", \"stat\": \"Stat.maxEfficiency\", \"value\": int(max_heat_efficiency * 100.0), \"unit\": \"StatUnit.percent\"}",
            "\treturn {\"source_owner\": \"PortGame.source_turret_set_stats_state\", \"method\": \"public void setStats(){\", \"override_expr\": \"@Override\", \"super_set_stats_expr\": \"super.setStats();\", \"inaccuracy_stat_expr\": \"stats.add(Stat.inaccuracy, (int)inaccuracy, StatUnit.degrees);\", \"reload_stat_expr\": \"stats.add(Stat.reload, 60f / (reload + (!reloadWhileCharging ? shoot.firstShotDelay : 0f)) * shoot.shots, StatUnit.perSecond);\", \"targets_air_stat_expr\": \"stats.add(Stat.targetsAir, targetAir);\", \"targets_ground_stat_expr\": \"stats.add(Stat.targetsGround, targetGround);\", \"ammo_use_guard_expr\": \"if(ammoPerShot != 1)\", \"ammo_use_stat_expr\": \"stats.add(Stat.ammoUse, ammoPerShot, StatUnit.perShot);\", \"input_heat_guard_expr\": \"if(heatRequirement > 0)\", \"input_heat_stat_expr\": \"stats.add(Stat.input, heatRequirement, StatUnit.heatUnits);\", \"max_efficiency_guard_expr\": \"if(heatRequirement > 0 && maxHeatEfficiency > 0)\", \"max_efficiency_stat_expr\": \"stats.add(Stat.maxEfficiency, (int)(maxHeatEfficiency * 100f), StatUnit.percent);\", \"inaccuracy_value\": inaccuracy_value, \"reload_value\": reload_value, \"reload_while_charging\": reload_while_charging, \"shoot_first_shot_delay\": shoot_first_shot_delay, \"shoot_shots\": shoot_shots, \"target_air\": target_air, \"target_ground\": target_ground, \"ammo_per_shot\": ammo_per_shot, \"heat_requirement\": heat_requirement, \"max_heat_efficiency\": max_heat_efficiency, \"reload_stat_denominator\": reload_stat_denominator, \"reload_stat_rate\": reload_stat_rate, \"super_set_stats_called\": true, \"inaccuracy_stat_call\": inaccuracy_stat_call, \"reload_stat_call\": reload_stat_call, \"targets_air_stat_call\": targets_air_stat_call, \"targets_ground_stat_call\": targets_ground_stat_call, \"ammo_use_stat_called\": ammo_use_stat_called, \"ammo_use_stat_call\": ammo_use_stat_call, \"input_heat_stat_called\": input_heat_stat_called, \"input_heat_stat_call\": input_heat_stat_call, \"max_efficiency_stat_called\": max_efficiency_stat_called, \"max_efficiency_stat_call\": max_efficiency_stat_call}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/Turret.java"
        and type_entry.get("name") == "Turret"
        and method.get("name") == "setBars"
    ):
        return [
            "\tvar heat_requirement: float = float(_args[0] if _args.size() > 0 else -1.0)",
            "\tvar entity_heat_req: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar max_heat_efficiency: float = float(_args[2] if _args.size() > 2 else 3.0)",
            "\tvar heat_bar_added: bool = heat_requirement > 0.0",
            "\tvar heat_bar_percent: int = 0",
            "\tvar heat_bar_fraction: float = 0.0",
            "\tvar heat_bar_text_call: Dictionary = {}",
            "\tvar heat_bar_color: String = \"\"",
            "\tvar heat_bar_call: Dictionary = {}",
            "\tif heat_bar_added:",
            "\t\theat_bar_percent = int(min(entity_heat_req / heat_requirement, max_heat_efficiency) * 100.0)",
            "\t\theat_bar_fraction = entity_heat_req / heat_requirement",
            "\t\theat_bar_text_call = {\"call\": \"Core.bundle.format(\\\"bar.heatpercent\\\", (int)entity.heatReq, (int)(Math.min(entity.heatReq / heatRequirement, maxHeatEfficiency) * 100))\", \"key\": \"bar.heatpercent\", \"heat_req\": int(entity_heat_req), \"percent\": heat_bar_percent}",
            "\t\theat_bar_color = \"Pal.lightOrange\"",
            "\t\theat_bar_call = {\"call\": \"addBar(\\\"heat\\\", (TurretBuild entity) -> new Bar(...));\", \"name\": \"heat\", \"text_call\": heat_bar_text_call, \"color\": heat_bar_color, \"fraction\": heat_bar_fraction}",
            "\treturn {\"source_owner\": \"PortGame.source_turret_set_bars_state\", \"method\": \"public void setBars(){\", \"override_expr\": \"@Override\", \"super_set_bars_expr\": \"super.setBars();\", \"heat_requirement_guard_expr\": \"if(heatRequirement > 0){\", \"add_bar_expr\": \"addBar(\\\"heat\\\", (TurretBuild entity) ->\", \"bar_new_expr\": \"new Bar(() ->\", \"bar_text_format_expr\": \"Core.bundle.format(\\\"bar.heatpercent\\\", (int)entity.heatReq, (int)(Math.min(entity.heatReq / heatRequirement, maxHeatEfficiency) * 100))\", \"bar_color_expr\": \"() -> Pal.lightOrange\", \"bar_progress_expr\": \"() -> entity.heatReq / heatRequirement\", \"heat_requirement\": heat_requirement, \"entity_heat_req\": entity_heat_req, \"max_heat_efficiency\": max_heat_efficiency, \"super_set_bars_called\": true, \"heat_bar_added\": heat_bar_added, \"heat_bar_percent\": heat_bar_percent, \"heat_bar_fraction\": heat_bar_fraction, \"heat_bar_text_call\": heat_bar_text_call, \"heat_bar_color\": heat_bar_color, \"heat_bar_call\": heat_bar_call}",
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
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/ReloadTurret.java"
        and type_entry.get("name") == "ReloadTurret"
        and method.get("name") == "setStats"
    ):
        return [
            "\tvar coolant_present: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar reload_value: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar coolant_amount: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar coolant_multiplier: float = float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar booster_replace_called: bool = coolant_present",
            "\tvar booster_replace_call: Dictionary = {}",
            "\tif booster_replace_called:",
            "\t\tbooster_replace_call = {\"call\": \"stats.replace(Stat.booster, StatValues.boosters(reload, coolant.amount, coolantMultiplier, true, coolant::consumes));\", \"stat\": \"Stat.booster\", \"reload\": reload_value, \"coolant_amount\": coolant_amount, \"coolant_multiplier\": coolant_multiplier, \"base\": true, \"consumes\": \"coolant::consumes\"}",
            "\treturn {\"source_owner\": \"PortGame.source_reload_turret_set_stats_state\", \"method\": \"public void setStats(){\", \"override_expr\": \"@Override\", \"super_set_stats_expr\": \"super.setStats();\", \"coolant_gate\": \"if(coolant != null){\", \"booster_replace_expr\": \"stats.replace(Stat.booster, StatValues.boosters(reload, coolant.amount, coolantMultiplier, true, coolant::consumes));\", \"coolant_present\": coolant_present, \"reload_value\": reload_value, \"coolant_amount\": coolant_amount, \"coolant_multiplier\": coolant_multiplier, \"super_set_stats_called\": true, \"booster_replace_called\": booster_replace_called, \"booster_replace_call\": booster_replace_call}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/PowerTurret.java"
        and type_entry.get("name") == "PowerTurret"
        and method.get("name") == "setStats"
    ):
        return [
            "\tvar shoot_type: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar object_map_call: Dictionary = {\"call\": \"ObjectMap.of(this, shootType)\", \"owner\": \"this\", \"shoot_type\": shoot_type}",
            "\tvar ammo_values_call: Dictionary = {\"call\": \"StatValues.ammo(ObjectMap.of(this, shootType))\", \"object_map_call\": object_map_call}",
            "\tvar stats_add_call: Dictionary = {\"call\": \"stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));\", \"stat\": \"Stat.ammo\", \"ammo_values_call\": ammo_values_call}",
            "\treturn {\"source_owner\": \"PortGame.source_power_turret_set_stats_state\", \"method\": \"public void setStats(){\", \"override_expr\": \"@Override\", \"super_set_stats_expr\": \"super.setStats();\", \"stats_add_expr\": \"stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));\", \"shoot_type\": shoot_type, \"super_set_stats_called\": true, \"stats_add_called\": true, \"object_map_call\": object_map_call, \"ammo_values_call\": ammo_values_call, \"stats_add_call\": stats_add_call}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/PowerTurret.java"
        and type_entry.get("name") == "PowerTurret"
        and method.get("name") == "limitRange"
    ):
        return [
            "\tvar shoot_type: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar margin: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar limit_range_call: Dictionary = {\"call\": \"limitRange(shootType, margin);\", \"shoot_type\": shoot_type, \"margin\": margin}",
            "\treturn {\"source_owner\": \"PortGame.source_power_turret_limit_range_state\", \"method\": \"public void limitRange(float margin){\", \"dispatch_expr\": \"limitRange(shootType, margin);\", \"shoot_type\": shoot_type, \"margin\": margin, \"limit_range_called\": true, \"limit_range_call\": limit_range_call}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/LiquidTurret.java"
        and type_entry.get("name") == "LiquidTurret"
        and method.get("name") == "ammo"
    ):
        return [
            "\tvar objects: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []",
            "\treturn {\"source_owner\": \"PortGame.source_liquid_turret_ammo_state\", \"field\": \"public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();\", \"comment\": \"/** Initializes accepted ammo map. Format: [liquid1, bullet1, liquid2, bullet2...] */\", \"method\": \"public void ammo(Object... objects){\", \"assignment_expr\": \"ammoTypes = ObjectMap.of(objects);\", \"objects\": objects, \"ammo_types_after\": objects}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java"
        and type_entry.get("name") == "ContinuousLiquidTurret"
        and method.get("name") == "ammo"
    ):
        return [
            "\tvar objects: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []",
            "\treturn {\"source_owner\": \"PortGame.source_continuous_liquid_turret_ammo_state\", \"field\": \"public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();\", \"comment\": \"/** Initializes accepted ammo map. Format: [liquid1, bullet1, liquid2, bullet2...] */\", \"method\": \"public void ammo(Object... objects){\", \"assignment_expr\": \"ammoTypes = ObjectMap.of(objects);\", \"objects\": objects, \"ammo_types_after\": objects}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java"
        and type_entry.get("name") == "ContinuousLiquidTurret"
        and method.get("name") == "setStats"
    ):
        return [
            "\tvar ammo_types: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []",
            "\tvar liquid_consumed: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar stat_liquid_consumed_updates: Array = []",
            "\tfor entry in ammo_types:",
            "\t\tvar entry_dict: Dictionary = entry if entry is Dictionary else {}",
            "\t\tstat_liquid_consumed_updates.append({\"call\": \"b.statLiquidConsumed = liquidConsumed\", \"liquid\": entry_dict.get(\"liquid\", null), \"bullet\": entry_dict.get(\"bullet\", null), \"stat_liquid_consumed\": liquid_consumed})",
            "\tvar ammo_values_call: Dictionary = {\"call\": \"StatValues.ammo(ammoTypes)\", \"ammo_types\": ammo_types}",
            "\tvar stats_replace_call: Dictionary = {\"call\": \"stats.replace(Stat.ammo, StatValues.ammo(ammoTypes));\", \"stat\": \"Stat.ammo\", \"ammo_values_call\": ammo_values_call}",
            "\treturn {\"source_owner\": \"PortGame.source_continuous_liquid_turret_set_stats_state\", \"method\": \"public void setStats(){\", \"override_expr\": \"@Override\", \"super_set_stats_expr\": \"super.setStats();\", \"mirror_comment\": \"//mirror stats onto each bullet (purely visual)\", \"stat_liquid_consumed_expr\": \"ammoTypes.each((l, b) -> b.statLiquidConsumed = liquidConsumed);\", \"stats_replace_expr\": \"stats.replace(Stat.ammo, StatValues.ammo(ammoTypes));\", \"ammo_types\": ammo_types, \"liquid_consumed\": liquid_consumed, \"super_set_stats_called\": true, \"stat_liquid_consumed_updates\": stat_liquid_consumed_updates, \"stats_replace_called\": true, \"ammo_values_call\": ammo_values_call, \"stats_replace_call\": stats_replace_call}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java"
        and type_entry.get("name") == "ContinuousLiquidTurret"
        and method.get("name") == "init"
    ):
        return [
            "\tvar ammo_entries: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []",
            "\tvar target_ground: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar current_place_overlap_range: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar range_value: float = float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar place_overlap_margin: float = float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar liquid_consumed: float = float(_args[5] if _args.size() > 5 else 0.0)",
            "\tvar current_liquid: Variant = _args[6] if _args.size() > 6 else null",
            "\tvar current_ammo_multiplier: Variant = _args[7] if _args.size() > 7 else null",
            "\tvar multiplier_result: float = 1.0 if current_ammo_multiplier == null else 1.0 / float(current_ammo_multiplier)",
            "\tvar consume_call: Dictionary = {\"call\": \"consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), liquidConsumed){...});\", \"filter_expr\": \"i -> ammoTypes.containsKey(i)\", \"amount\": liquid_consumed, \"multiplier_expr\": \"multiplier = b -> {\", \"ammo_lookup_expr\": \"var ammo = ammoTypes.get(b.liquids.current());\", \"current_liquid\": current_liquid, \"current_ammo_multiplier\": current_ammo_multiplier, \"multiplier_return_expr\": \"return ammo == null ? 1f : 1f / ammo.ammoMultiplier;\", \"multiplier_result\": multiplier_result, \"display_override_noop\": true}",
            "\tvar overlap_updates: Array = []",
            "\tif target_ground:",
            "\t\tfor entry in ammo_entries:",
            "\t\t\tvar entry_dict: Dictionary = entry if entry is Dictionary else {}",
            "\t\t\tvar type_state: Variant = entry_dict.get(\"type\", entry_dict.get(\"bullet\", {}))",
            "\t\t\tvar range_change: float = 0.0",
            "\t\t\tif type_state is Dictionary:",
            "\t\t\t\trange_change = float(type_state.get(\"rangeChange\", 0.0))",
            "\t\t\tvar before_range: float = current_place_overlap_range",
            "\t\t\tvar candidate_range: float = range_value + range_change + place_overlap_margin",
            "\t\t\tcurrent_place_overlap_range = max(current_place_overlap_range, candidate_range)",
            "\t\t\toverlap_updates.append({\"liquid\": entry_dict.get(\"liquid\", entry_dict.get(\"item\", null)), \"type\": type_state, \"range_change\": range_change, \"candidate_range\": candidate_range, \"before\": before_range, \"after\": current_place_overlap_range})",
            "\treturn {\"source_owner\": \"PortGame.source_continuous_liquid_turret_init_state\", \"method\": \"public void init(){\", \"override_expr\": \"@Override\", \"consume_expr\": \"consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), liquidConsumed){\", \"filter_expr\": \"i -> ammoTypes.containsKey(i)\", \"consume_call\": consume_call, \"multiplier_expr\": \"multiplier = b -> {\", \"ammo_lookup_expr\": \"var ammo = ammoTypes.get(b.liquids.current());\", \"multiplier_return_expr\": \"return ammo == null ? 1f : 1f / ammo.ammoMultiplier;\", \"multiplier_result\": multiplier_result, \"display_override_noop\": true, \"target_ground_expr\": \"if(targetGround){\", \"overlap_expr\": \"ammoTypes.each((item, type) -> placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin));\", \"super_init_expr\": \"super.init();\", \"ammo_entries\": ammo_entries, \"target_ground\": target_ground, \"place_overlap_range_before\": float(_args[2] if _args.size() > 2 else 0.0), \"range_value\": range_value, \"place_overlap_margin\": place_overlap_margin, \"liquid_consumed\": liquid_consumed, \"current_liquid\": current_liquid, \"current_ammo_multiplier\": current_ammo_multiplier, \"overlap_updates\": overlap_updates, \"place_overlap_range_after\": current_place_overlap_range, \"super_init_called\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/LiquidTurret.java"
        and type_entry.get("name") == "LiquidTurret"
        and method.get("name") == "setStats"
    ):
        return [
            "\tvar ammo_types: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar name_value: String = str(_args[1] if _args.size() > 1 else \"\")",
            "\tvar ammo_values_call: Dictionary = {\"call\": \"StatValues.ammo(ammoTypes, name)\", \"ammo_types\": ammo_types, \"name\": name_value}",
            "\tvar stats_add_call: Dictionary = {\"call\": \"stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));\", \"stat\": \"Stat.ammo\", \"ammo_values_call\": ammo_values_call}",
            "\treturn {\"source_owner\": \"PortGame.source_liquid_turret_set_stats_state\", \"method\": \"public void setStats(){\", \"override_expr\": \"@Override\", \"super_set_stats_expr\": \"super.setStats();\", \"stats_add_expr\": \"stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));\", \"ammo_types\": ammo_types, \"name_value\": name_value, \"super_set_stats_called\": true, \"stats_added\": true, \"ammo_values_call\": ammo_values_call, \"stats_add_call\": stats_add_call}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/LiquidTurret.java"
        and type_entry.get("name") == "LiquidTurret"
        and method.get("name") == "init"
    ):
        return [
            "\tvar ammo_entries: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []",
            "\tvar target_ground: bool = bool(_args[1] if _args.size() > 1 else false)",
            "\tvar current_place_overlap_range: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar range_value: float = float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar place_overlap_margin: float = float(_args[4] if _args.size() > 4 else 0.0)",
            "\tvar consume_call: Dictionary = {\"call\": \"consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), 1f){...});\", \"filter_expr\": \"i -> ammoTypes.containsKey(i)\", \"amount\": 1.0, \"update_override_noop\": true, \"display_override_noop\": true}",
            "\tvar overlap_updates: Array = []",
            "\tif target_ground:",
            "\t\tfor entry in ammo_entries:",
            "\t\t\tvar entry_dict: Dictionary = entry if entry is Dictionary else {}",
            "\t\t\tvar type_state: Variant = entry_dict.get(\"type\", {})",
            "\t\t\tvar range_change: float = 0.0",
            "\t\t\tif type_state is Dictionary:",
            "\t\t\t\trange_change = float(type_state.get(\"rangeChange\", 0.0))",
            "\t\t\tvar before_range: float = current_place_overlap_range",
            "\t\t\tvar candidate_range: float = range_value + range_change + place_overlap_margin",
            "\t\t\tcurrent_place_overlap_range = max(current_place_overlap_range, candidate_range)",
            "\t\t\toverlap_updates.append({\"item\": entry_dict.get(\"item\", null), \"type\": type_state, \"range_change\": range_change, \"candidate_range\": candidate_range, \"before\": before_range, \"after\": current_place_overlap_range})",
            "\treturn {\"source_owner\": \"PortGame.source_liquid_turret_init_state\", \"method\": \"public void init(){\", \"override_expr\": \"@Override\", \"consume_expr\": \"consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), 1f){\", \"filter_expr\": \"i -> ammoTypes.containsKey(i)\", \"consume_call\": consume_call, \"target_ground_expr\": \"if(targetGround){\", \"overlap_expr\": \"ammoTypes.each((item, type) -> placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin));\", \"super_init_expr\": \"super.init();\", \"ammo_entries\": ammo_entries, \"target_ground\": target_ground, \"place_overlap_range_before\": float(_args[2] if _args.size() > 2 else 0.0), \"range_value\": range_value, \"place_overlap_margin\": place_overlap_margin, \"overlap_updates\": overlap_updates, \"place_overlap_range_after\": current_place_overlap_range, \"super_init_called\": true}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/ItemTurret.java"
        and type_entry.get("name") == "ItemTurret"
        and method.get("name") == "ammo"
    ):
        return [
            "\tvar objects: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []",
            "\treturn {\"source_owner\": \"PortGame.source_item_turret_ammo_state\", \"field\": \"public ObjectMap<Item, BulletType> ammoTypes = new OrderedMap<>();\", \"comment\": \"/** Initializes accepted ammo map. Format: [item1, bullet1, item2, bullet2...] */\", \"method\": \"public void ammo(Object... objects){\", \"assignment_expr\": \"ammoTypes = OrderedMap.of(objects);\", \"objects\": objects, \"ammo_types_after\": objects}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/ItemTurret.java"
        and type_entry.get("name") == "ItemTurret"
        and method.get("name") == "limitRange"
        and len(method.get("parameters", [])) == 0
    ):
        return [
            "\tvar margin: float = 9.0",
            "\tvar limit_range_call: Dictionary = {\"call\": \"limitRange(9f);\", \"margin\": margin}",
            "\treturn {\"source_owner\": \"PortGame.source_item_turret_limit_range_default_state\", \"method\": \"public void limitRange(){\", \"comment\": \"/** Limits bullet range to this turret's range value. */\", \"dispatch_expr\": \"limitRange(9f);\", \"margin\": margin, \"limit_range_called\": true, \"limit_range_call\": limit_range_call}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/ItemTurret.java"
        and type_entry.get("name") == "ItemTurret"
        and method.get("name") == "limitRange"
        and len(method.get("parameters", [])) == 1
    ):
        return [
            "\tvar margin: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar ammo_entries: Array = _args[1] if _args.size() > 1 else []",
            "\tvar limit_range_calls: Array = []",
            "\tfor entry in ammo_entries:",
            "\t\tvar entry_value: Variant = entry.get(\"value\", null) if entry is Dictionary else entry",
            "\t\tlimit_range_calls.append({\"call\": \"limitRange(entry.value, margin);\", \"entry_value\": entry_value, \"margin\": margin})",
            "\treturn {\"source_owner\": \"PortGame.source_item_turret_limit_range_entries_state\", \"method\": \"public void limitRange(float margin){\", \"comment\": \"/** Limits bullet range to this turret's range value. */\", \"loop_expr\": \"for(var entry : ammoTypes.entries()){\", \"dispatch_expr\": \"limitRange(entry.value, margin);\", \"margin\": margin, \"ammo_entries\": ammo_entries, \"limit_range_calls\": limit_range_calls, \"limit_range_call_count\": limit_range_calls.size()}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/ItemTurret.java"
        and type_entry.get("name") == "ItemTurret"
        and method.get("name") == "setStats"
    ):
        return [
            "\tvar ammo_types: Variant = _args[0] if _args.size() > 0 else null",
            "\tvar name_value: String = str(_args[1] if _args.size() > 1 else \"\")",
            "\tvar max_ammo: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar ammo_per_shot: float = float(_args[3] if _args.size() > 3 else 1.0)",
            "\tvar ammo_capacity_divisor: float = maxf(ammo_per_shot, 1.0)",
            "\tvar ammo_capacity: float = max_ammo / ammo_capacity_divisor",
            "\tvar stats_item_capacity_remove_call: Dictionary = {\"call\": \"stats.remove(Stat.itemCapacity);\", \"stat\": \"Stat.itemCapacity\"}",
            "\tvar ammo_values_call: Dictionary = {\"call\": \"StatValues.ammo(ammoTypes, name)\", \"ammo_types\": ammo_types, \"name\": name_value}",
            "\tvar stats_ammo_add_call: Dictionary = {\"call\": \"stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));\", \"stat\": \"Stat.ammo\", \"ammo_values_call\": ammo_values_call}",
            "\tvar stats_ammo_capacity_add_call: Dictionary = {\"call\": \"stats.add(Stat.ammoCapacity, maxAmmo / Math.max(ammoPerShot, 1), StatUnit.shots);\", \"stat\": \"Stat.ammoCapacity\", \"value\": ammo_capacity, \"unit\": \"StatUnit.shots\"}",
            "\treturn {\"source_owner\": \"PortGame.source_item_turret_set_stats_state\", \"method\": \"public void setStats(){\", \"override_expr\": \"@Override\", \"super_set_stats_expr\": \"super.setStats();\", \"stats_remove_expr\": \"stats.remove(Stat.itemCapacity);\", \"stats_ammo_add_expr\": \"stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));\", \"stats_ammo_capacity_add_expr\": \"stats.add(Stat.ammoCapacity, maxAmmo / Math.max(ammoPerShot, 1), StatUnit.shots);\", \"ammo_types\": ammo_types, \"name_value\": name_value, \"max_ammo\": max_ammo, \"ammo_per_shot\": ammo_per_shot, \"ammo_capacity_divisor\": ammo_capacity_divisor, \"ammo_capacity\": ammo_capacity, \"super_set_stats_called\": true, \"stats_item_capacity_removed\": true, \"stats_ammo_added\": true, \"stats_ammo_capacity_added\": true, \"stats_item_capacity_remove_call\": stats_item_capacity_remove_call, \"ammo_values_call\": ammo_values_call, \"stats_ammo_add_call\": stats_ammo_add_call, \"stats_ammo_capacity_add_call\": stats_ammo_capacity_add_call}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/ItemTurret.java"
        and type_entry.get("name") == "ItemTurret"
        and method.get("name") == "setBars"
    ):
        return [
            "\tvar total_ammo: float = float(_args[0] if _args.size() > 0 else 0.0)",
            "\tvar max_ammo: float = float(_args[1] if _args.size() > 1 else 1.0)",
            "\tvar ammo_bar_fraction: float = total_ammo / max_ammo",
            "\tvar bar_call: Dictionary = {\"call\": \"addBar(\\\"ammo\\\", (ItemTurretBuild entity) -> new Bar(...));\", \"name\": \"ammo\", \"bar_text\": \"stat.ammo\", \"color\": \"Pal.ammo\", \"fraction\": ammo_bar_fraction}",
            "\treturn {\"source_owner\": \"PortGame.source_item_turret_set_bars_state\", \"method\": \"public void setBars(){\", \"override_expr\": \"@Override\", \"super_set_bars_expr\": \"super.setBars();\", \"add_bar_expr\": \"addBar(\\\"ammo\\\", (ItemTurretBuild entity) -> new Bar(\\\"stat.ammo\\\", Pal.ammo, () -> (float)entity.totalAmmo / maxAmmo));\", \"bar_fraction_expr\": \"() -> (float)entity.totalAmmo / maxAmmo\", \"total_ammo\": total_ammo, \"max_ammo\": max_ammo, \"ammo_bar_fraction\": ammo_bar_fraction, \"super_set_bars_called\": true, \"bar_added\": true, \"bar_call\": bar_call}",
        ]
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/ItemTurret.java"
        and type_entry.get("name") == "ItemTurret"
        and method.get("name") == "init"
    ):
        return [
            "\tvar target_ground: bool = bool(_args[0] if _args.size() > 0 else false)",
            "\tvar place_overlap_range: float = float(_args[1] if _args.size() > 1 else 0.0)",
            "\tvar range_value: float = float(_args[2] if _args.size() > 2 else 0.0)",
            "\tvar place_overlap_margin: float = float(_args[3] if _args.size() > 3 else 0.0)",
            "\tvar ammo_entries: Array = _args[4] if _args.size() > 4 else []",
            "\tvar place_overlap_range_after: float = place_overlap_range",
            "\tvar place_overlap_updates: Array = []",
            "\tif target_ground:",
            "\t\tfor entry in ammo_entries:",
            "\t\t\tvar entry_value: Variant = entry.get(\"value\", entry) if entry is Dictionary else entry",
            "\t\t\tvar range_change: float = float(entry_value.get(\"range_change\", entry_value.get(\"rangeChange\", 0.0)) if entry_value is Dictionary else 0.0)",
            "\t\t\tvar candidate_range: float = range_value + range_change + place_overlap_margin",
            "\t\t\tplace_overlap_range_after = maxf(place_overlap_range_after, candidate_range)",
            "\t\t\tplace_overlap_updates.append({\"call\": \"placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin)\", \"range_change\": range_change, \"candidate_range\": candidate_range, \"place_overlap_range_after\": place_overlap_range_after})",
            "\treturn {\"source_owner\": \"PortGame.source_item_turret_init_ground_overlap_state\", \"method\": \"public void init(){\", \"override_expr\": \"@Override\", \"consume_expr\": \"consume(new ConsumeItemFilter(i -> ammoTypes.containsKey(i)))\", \"consume_filter_deferred\": true, \"target_ground_guard_expr\": \"if(targetGround){\", \"overlap_expr\": \"placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin)\", \"super_init_expr\": \"super.init();\", \"target_ground\": target_ground, \"place_overlap_range\": place_overlap_range, \"range_value\": range_value, \"place_overlap_margin\": place_overlap_margin, \"ammo_entries\": ammo_entries, \"place_overlap_range_after\": place_overlap_range_after, \"place_overlap_updates\": place_overlap_updates, \"place_overlap_update_count\": place_overlap_updates.size(), \"super_init_called\": true}",
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


def _extra_method_stub_lines(java_file: dict, type_entry: dict) -> list[str]:
    lines: list[str] = []
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BuildPayload.java"
        and type_entry.get("name") == "BuildPayload"
    ):
        for index, constructor in enumerate(type_entry.get("constructors", [])):
            params = constructor.get("parameters", [])
            if len(params) == 2:
                lines.extend([
                    "",
                    f"func java_constructor_BuildPayload_{index}(_args: Array = []) -> Variant:",
                    "\tvar block: Variant = _args[0] if _args.size() > 0 else null",
                    "\tvar team: Variant = _args[1] if _args.size() > 1 else null",
                    '\tvar create_call: Dictionary = {"call": "block.newBuilding().create(block, team)", "block": block, "team": team}',
                    '\treturn {"source_owner": "PortGame.source_build_payload_constructor_block_team_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "import_expr": "import static mindustry.Vars.*;", "constructor": "public BuildPayload(Block block, Team team){", "build_assign_expr": "this.build = block.newBuilding().create(block, team);", "tile_assign_expr": "this.build.tile = emptyTile;", "block": block, "team": team, "create_call": create_call, "tile_after": "emptyTile"}',
                ])
            elif len(params) == 1:
                lines.extend([
                    "",
                    f"func java_constructor_BuildPayload_{index}(_args: Array = []) -> Variant:",
                    "\tvar build: Variant = _args[0] if _args.size() > 0 else null",
                    '\treturn {"source_owner": "PortGame.source_build_payload_constructor_build_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "constructor": "public BuildPayload(Building build){", "build_assign_expr": "this.build = build;", "build": build, "build_after": build}',
                ])
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/UnitPayload.java"
        and type_entry.get("name") == "UnitPayload"
    ):
        for index, constructor in enumerate(type_entry.get("constructors", [])):
            params = constructor.get("parameters", [])
            if len(params) == 1:
                lines.extend([
                    "",
                    f"func java_constructor_UnitPayload_{index}(_args: Array = []) -> Variant:",
                    "\tvar unit: Variant = _args[0] if _args.size() > 0 else null",
                    '\treturn {"source_owner": "PortGame.source_unit_payload_constructor_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "constructor": "public UnitPayload(Unit unit){", "unit_assign_expr": "this.unit = unit;", "unit": unit, "unit_after": unit}',
                ])
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeLiquidsDynamic.java"
        and type_entry.get("name") == "ConsumeLiquidsDynamic"
    ):
        for index, constructor in enumerate(type_entry.get("constructors", [])):
            params = constructor.get("parameters", [])
            if len(params) == 1:
                lines.extend([
                    "",
                    f"func java_constructor_ConsumeLiquidsDynamic_{index}(_args: Array = []) -> Variant:",
                    "\tvar liquids: Variant = _args[0] if _args.size() > 0 else null",
                    "\tvar liquids_after: Variant = liquids",
                    '\treturn {"source_owner": "PortGame.source_consume_liquids_dynamic_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidsDynamic.java", "constructor": "public <T extends Building> ConsumeLiquidsDynamic(Func<T, LiquidStack[]> liquids){", "suppress_warnings_expr": "@SuppressWarnings(\\"unchecked\\")", "assignment_expr": "this.liquids = (Func<Building, LiquidStack[]>)liquids;", "cast_expr": "(Func<Building, LiquidStack[]>)liquids", "liquids": liquids, "liquids_after": liquids_after}',
                ])
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemDynamic.java"
        and type_entry.get("name") == "ConsumeItemDynamic"
    ):
        for index, constructor in enumerate(type_entry.get("constructors", [])):
            params = constructor.get("parameters", [])
            if len(params) == 1:
                lines.extend([
                    "",
                    f"func java_constructor_ConsumeItemDynamic_{index}(_args: Array = []) -> Variant:",
                    "\tvar items: Variant = _args[0] if _args.size() > 0 else null",
                    "\tvar items_after: Variant = items",
                    '\treturn {"source_owner": "PortGame.source_consume_item_dynamic_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItemDynamic.java", "constructor": "public <T extends Building> ConsumeItemDynamic(Func<T, ItemStack[]> items){", "suppress_warnings_expr": "@SuppressWarnings(\\"unchecked\\")", "assignment_expr": "this.items = (Func<Building, ItemStack[]>)items;", "cast_expr": "(Func<Building, ItemStack[]>)items", "items": items, "items_after": items_after}',
                ])
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemFilter.java"
        and type_entry.get("name") == "ConsumeItemFilter"
    ):
        for index, constructor in enumerate(type_entry.get("constructors", [])):
            params = constructor.get("parameters", [])
            if len(params) == 1:
                lines.extend([
                    "",
                    f"func java_constructor_ConsumeItemFilter_{index}(_args: Array = []) -> Variant:",
                    "\tvar item: Variant = _args[0] if _args.size() > 0 else null",
                    "\tvar filter_after: Variant = item",
                    '\treturn {"source_owner": "PortGame.source_consume_item_filter_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "constructor": "public ConsumeItemFilter(Boolf<Item> item){", "filter_assignment_expr": "this.filter = item;", "filter_field": "public Boolf<Item> filter = i -> false;", "item": item, "filter_after": filter_after}',
                ])
            elif len(params) == 0:
                lines.extend([
                    "",
                    f"func java_constructor_ConsumeItemFilter_{index}(_args: Array = []) -> Variant:",
                    '\tvar filter_after: String = "i -> false"',
                    '\treturn {"source_owner": "PortGame.source_consume_item_filter_default_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "constructor": "public ConsumeItemFilter(){", "filter_field": "public Boolf<Item> filter = i -> false;", "filter_after": filter_after}',
                ])
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemFlammable.java"
        and type_entry.get("name") == "ConsumeItemFlammable"
    ):
        for index, constructor in enumerate(type_entry.get("constructors", [])):
            params = constructor.get("parameters", [])
            if len(params) == 1:
                lines.extend([
                    "",
                    f"func java_constructor_ConsumeItemFlammable_{index}(_args: Array = []) -> Variant:",
                    "\tvar min_flammability: float = float(_args[0] if _args.size() > 0 else 0.0)",
                    "\tvar min_flammability_after: float = min_flammability",
                    '\tvar filter_expr: String = "item -> item.flammability >= this.minFlammability"',
                    '\treturn {"source_owner": "PortGame.source_consume_item_flammable_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFlammable.java", "constructor": "public ConsumeItemFlammable(float minFlammability){", "min_flammability_field": "public float minFlammability;", "assignment_expr": "this.minFlammability = minFlammability;", "filter_assignment_expr": "filter = item -> item.flammability >= this.minFlammability;", "filter_expr": filter_expr, "item_flammability_field": "public float flammability = 0f;", "min_flammability": min_flammability, "min_flammability_after": min_flammability_after}',
                ])
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItems.java"
        and type_entry.get("name") == "ConsumeItems"
    ):
        for index, constructor in enumerate(type_entry.get("constructors", [])):
            params = constructor.get("parameters", [])
            if len(params) == 1:
                lines.extend([
                    "",
                    f"func java_constructor_ConsumeItems_{index}(_args: Array = []) -> Variant:",
                    "\tvar item_stacks: Array = (_args[0] as Array).duplicate(true) if _args.size() > 0 and _args[0] is Array else []",
                    "\tvar items_after: Array = item_stacks.duplicate(true)",
                    '\treturn {"source_owner": "PortGame.source_consume_items_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItems.java", "constructor": "public ConsumeItems(ItemStack[] items){", "assignment_expr": "this.items = items;", "items_field": "public final ItemStack[] items;", "item_stacks": item_stacks, "items_after": items_after}',
                ])
            elif len(params) == 0:
                lines.extend([
                    "",
                    f"func java_constructor_ConsumeItems_{index}(_args: Array = []) -> Variant:",
                    "\tvar item_stacks: Array = []",
                    "\tvar items_after: Array = item_stacks.duplicate(true)",
                    '\treturn {"source_owner": "PortGame.source_consume_items_default_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItems.java", "constructor": "protected ConsumeItems(){", "default_call_expr": "this(ItemStack.empty);", "item_stack_empty_expr": "public static final ItemStack[] empty = {};", "items_field": "public final ItemStack[] items;", "item_stacks": item_stacks, "items_after": items_after}',
                ])
    if (
        java_file.get("path") == "mindustry/world/consumers/ConsumeItemEfficiency.java"
        and type_entry.get("name") == "ConsumeItemEfficiency"
    ):
        for index, constructor in enumerate(type_entry.get("constructors", [])):
            params = constructor.get("parameters", [])
            if len(params) == 1:
                lines.extend([
                    "",
                    f"func java_constructor_ConsumeItemEfficiency_{index}(_args: Array = []) -> Variant:",
                    "\tvar item: Variant = _args[0] if _args.size() > 0 else null",
                    "\tvar filter_after: Variant = item",
                    '\treturn {"source_owner": "PortGame.source_consume_item_efficiency_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItemEfficiency.java", "constructor": "public ConsumeItemEfficiency(Boolf<Item> item){", "super_call_expr": "super(item);", "parent_constructor_expr": "public ConsumeItemFilter(Boolf<Item> item){", "filter_assignment_expr": "this.filter = item;", "filter_field": "public Boolf<Item> filter = i -> false;", "item": item, "filter_after": filter_after}',
                ])
            elif len(params) == 0:
                lines.extend([
                    "",
                    f"func java_constructor_ConsumeItemEfficiency_{index}(_args: Array = []) -> Variant:",
                    '\tvar filter_after: String = "i -> false"',
                    '\treturn {"source_owner": "PortGame.source_consume_item_efficiency_default_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItemEfficiency.java", "constructor": "public ConsumeItemEfficiency(){", "parent_constructor_expr": "public ConsumeItemFilter(){", "filter_field": "public Boolf<Item> filter = i -> false;", "filter_after": filter_after}',
                ])
    if (
        java_file.get("path") == "mindustry/world/blocks/payloads/BlockProducer.java"
        and type_entry.get("name") == "BlockProducer"
    ):
        for inner_class in type_entry.get("inner_classes", []):
            if inner_class.get("name") != "BlockProducerBuild":
                continue
            for index, method in enumerate(inner_class.get("methods", [])):
                if method.get("name") == "acceptItem":
                    lines.extend([
                        "",
                        f"func java_inner_class_BlockProducerBuild_method_acceptItem_{index}(_args: Array = []) -> Variant:",
                        "\tvar source_building: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar item: Variant = _args[1] if _args.size() > 1 else null",
                        "\tvar item_count: int = int(_args[2] if _args.size() > 2 else 0)",
                        "\tvar maximum_accepted: int = int(_args[3] if _args.size() > 3 else 0)",
                        "\tvar accept_item: bool = item_count < maximum_accepted",
                        '\treturn {"source_owner": "PortGame.source_block_producer_build_accept_item_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public boolean acceptItem(Building source, Item item){", "return_expr": "return items.get(item) < getMaximumAccepted(item);", "source_building": source_building, "item": item, "item_count": item_count, "maximum_accepted": maximum_accepted, "accept_item": accept_item}',
                    ])
                elif method.get("name") == "getMaximumAccepted":
                    lines.extend([
                        "",
                        f"func java_inner_class_BlockProducerBuild_method_getMaximumAccepted_{index}(_args: Array = []) -> Variant:",
                        "\tvar item: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar recipe_null: bool = bool(_args[1] if _args.size() > 1 else true)",
                        "\tvar requirements: Array = []",
                        "\tif _args.size() > 2 and _args[2] is Array:",
                        "\t\trequirements = _args[2]",
                        "\tvar maximum_accepted: int = 0",
                        "\tvar matched_requirement: Variant = null",
                        "\tif not recipe_null:",
                        "\t\tfor stack in requirements:",
                        "\t\t\tif stack is Dictionary:",
                        "\t\t\t\tvar stack_item: Variant = stack.get(\"item\", null)",
                        "\t\t\t\tif stack_item == item:",
                        "\t\t\t\t\tvar stack_amount: int = int(stack.get(\"amount\", 0))",
                        "\t\t\t\t\tmaximum_accepted = stack_amount * 2",
                        "\t\t\t\t\tmatched_requirement = stack",
                        "\t\t\t\t\tbreak",
                        '\treturn {"source_owner": "PortGame.source_block_producer_build_get_maximum_accepted_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public int getMaximumAccepted(Item item){", "null_guard": "if(recipe() == null) return 0;", "requirement_loop": "for(ItemStack stack : recipe().requirements){", "match_expr": "if(stack.item == item) return stack.amount * 2;", "final_return": "return 0;", "item": item, "recipe_null": recipe_null, "requirements": requirements, "matched_requirement": matched_requirement, "maximum_accepted": maximum_accepted}',
                    ])
                elif method.get("name") == "acceptPayload":
                    lines.extend([
                        "",
                        f"func java_inner_class_BlockProducerBuild_method_acceptPayload_{index}(_args: Array = []) -> Variant:",
                        "\tvar source_building: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar payload: Variant = _args[1] if _args.size() > 1 else null",
                        "\tvar accept_payload: bool = false",
                        '\treturn {"source_owner": "PortGame.source_block_producer_build_accept_payload_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public boolean acceptPayload(Building source, Payload payload){", "return_expr": "return false;", "source_building": source_building, "payload": payload, "accept_payload": accept_payload}',
                    ])
                elif method.get("name") == "shouldConsume":
                    lines.extend([
                        "",
                        f"func java_inner_class_BlockProducerBuild_method_shouldConsume_{index}(_args: Array = []) -> Variant:",
                        "\tvar super_should_consume: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar recipe_null: bool = bool(_args[1] if _args.size() > 1 else true)",
                        "\tvar should_consume: bool = super_should_consume and not recipe_null",
                        '\treturn {"source_owner": "PortGame.source_block_producer_build_should_consume_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public boolean shouldConsume(){", "return_expr": "return super.shouldConsume() && recipe() != null;", "super_should_consume": super_should_consume, "recipe_null": recipe_null, "should_consume": should_consume}',
                    ])
                elif method.get("name") == "updateTile":
                    lines.extend([
                        "",
                        f"func java_inner_class_BlockProducerBuild_method_updateTile_{index}(_args: Array = []) -> Variant:",
                        "\tvar recipe_null: bool = bool(_args[0] if _args.size() > 0 else true)",
                        "\tvar efficiency: float = float(_args[1] if _args.size() > 1 else 0.0)",
                        "\tvar payload_null: bool = bool(_args[2] if _args.size() > 2 else true)",
                        "\tvar produce: bool = not recipe_null and efficiency > 0.0 and payload_null",
                        '\treturn {"source_owner": "PortGame.source_block_producer_build_update_tile_produce_gate_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public void updateTile(){", "super_call": "super.updateTile();", "recipe_assignment": "var recipe = recipe();", "produce_expr": "boolean produce = recipe != null && efficiency > 0 && payload == null;", "recipe_null": recipe_null, "efficiency": efficiency, "payload_null": payload_null, "produce": produce}',
                        "",
                        f"func java_inner_class_BlockProducerBuild_method_updateTile_progress_accumulation_{index}(_args: Array = []) -> Variant:",
                        "\tvar produce: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar progress_before: float = float(_args[1] if _args.size() > 1 else 0.0)",
                        "\tvar build_speed: float = float(_args[2] if _args.size() > 2 else 0.0)",
                        "\tvar edelta: float = float(_args[3] if _args.size() > 3 else 0.0)",
                        "\tvar progress_delta: float = build_speed * edelta if produce else 0.0",
                        "\tvar progress_after: float = progress_before + progress_delta",
                        '\treturn {"source_owner": "PortGame.source_block_producer_build_update_tile_progress_accumulation_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public void updateTile(){", "if_produce_expr": "if(produce){", "progress_expr": "progress += buildSpeed * edelta();", "produce": produce, "progress_before": progress_before, "build_speed": build_speed, "edelta": edelta, "progress_delta": progress_delta, "progress_after": progress_after}',
                        "",
                        f"func java_inner_class_BlockProducerBuild_method_updateTile_completion_guard_{index}(_args: Array = []) -> Variant:",
                        "\tvar progress: float = float(_args[0] if _args.size() > 0 else 0.0)",
                        "\tvar recipe_build_time: float = float(_args[1] if _args.size() > 1 else 0.0)",
                        "\tvar completion_guard: bool = progress >= recipe_build_time",
                        "\tvar consume_called: bool = completion_guard",
                        '\treturn {"source_owner": "PortGame.source_block_producer_build_update_tile_completion_guard_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public void updateTile(){", "completion_guard_expr": "if(progress >= recipe.buildTime){", "consume_expr": "consume();", "progress": progress, "recipe_build_time": recipe_build_time, "completion_guard": completion_guard, "consume_called": consume_called}',
                        "",
                        f"func java_inner_class_BlockProducerBuild_method_updateTile_payload_creation_{index}(_args: Array = []) -> Variant:",
                        "\tvar completion_guard: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar recipe: Variant = _args[1] if _args.size() > 1 else null",
                        "\tvar team: Variant = _args[2] if _args.size() > 2 else null",
                        "\tvar x: float = float(_args[3] if _args.size() > 3 else 0.0)",
                        "\tvar y: float = float(_args[4] if _args.size() > 4 else 0.0)",
                        "\tvar payload_size: float = float(_args[5] if _args.size() > 5 else 0.0)",
                        "\tvar tilesize: float = float(_args[6] if _args.size() > 6 else 1.0)",
                        "\tvar payload_after: Variant = null",
                        "\tif completion_guard:",
                        '\t\tpayload_after = {"recipe": recipe, "team": team}',
                        "\tvar place_effect_called: bool = completion_guard",
                        "\tvar effect_radius: Variant = null",
                        "\tif completion_guard:",
                        "\t\teffect_radius = payload_size / tilesize",
                        '\treturn {"source_owner": "PortGame.source_block_producer_build_update_tile_payload_creation_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public void updateTile(){", "payload_expr": "payload = new BuildPayload(recipe, team);", "place_effect_expr": "payload.block().placeEffect.at(x, y, payload.size() / tilesize);", "completion_guard": completion_guard, "recipe": recipe, "team": team, "x": x, "y": y, "payload_size": payload_size, "tilesize": tilesize, "payload_after": payload_after, "place_effect_called": place_effect_called, "effect_radius": effect_radius}',
                        "",
                        f"func java_inner_class_BlockProducerBuild_method_updateTile_pay_vector_progress_reset_{index}(_args: Array = []) -> Variant:",
                        "\tvar completion_guard: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar pay_vector_x: float = float(_args[1] if _args.size() > 1 else 0.0)",
                        "\tvar pay_vector_y: float = float(_args[2] if _args.size() > 2 else 0.0)",
                        "\tvar progress_before: float = float(_args[3] if _args.size() > 3 else 0.0)",
                        '\tvar pay_vector_after: Dictionary = {"x": pay_vector_x, "y": pay_vector_y}',
                        "\tvar progress_after: float = progress_before",
                        "\tif completion_guard:",
                        '\t\tpay_vector_after = {"x": 0.0, "y": 0.0}',
                        "\t\tprogress_after = fmod(progress_before, 1.0)",
                        '\treturn {"source_owner": "PortGame.source_block_producer_build_update_tile_pay_vector_progress_reset_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "parent_source": "core/src/mindustry/world/blocks/payloads/PayloadBlock.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public void updateTile(){", "completion_guard_expr": "if(progress >= recipe.buildTime){", "pay_vector_field": "public Vec2 payVector = new Vec2();", "progress_field": "public float progress, time, heat;", "pay_vector_set_zero_expr": "payVector.setZero();", "progress_modulo_expr": "progress %= 1f;", "completion_guard": completion_guard, "pay_vector_x": pay_vector_x, "pay_vector_y": pay_vector_y, "progress_before": progress_before, "pay_vector_after": pay_vector_after, "progress_after": progress_after}',
                        "",
                        f"func java_inner_class_BlockProducerBuild_method_updateTile_heat_time_{index}(_args: Array = []) -> Variant:",
                        "\tvar produce: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar heat_before: float = float(_args[1] if _args.size() > 1 else 0.0)",
                        "\tvar time_before: float = float(_args[2] if _args.size() > 2 else 0.0)",
                        "\tvar time_delta: float = float(_args[3] if _args.size() > 3 else 0.0)",
                        "\tvar produce_num: float = 1.0 if produce else 0.0",
                        "\tvar heat_after: float = heat_before + (produce_num - heat_before) * clampf(0.15 * time_delta, 0.0, 1.0)",
                        "\tvar time_after: float = time_before + heat_after * time_delta",
                        '\treturn {"source_owner": "PortGame.source_block_producer_build_update_tile_heat_time_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "arc_source": "arc-core/src/arc/math/Mathf.java", "building_source": "core/src/mindustry/entities/comp/BuildingComp.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public void updateTile(){", "field_expr": "public float progress, time, heat;", "heat_expr": "heat = Mathf.lerpDelta(heat, Mathf.num(produce), 0.15f);", "time_expr": "time += heat * delta();", "mathf_num_method": "public static int num(boolean b){", "mathf_lerp_delta_method": "public static float lerpDelta(float fromValue, float toValue, float progress){\\n        return lerp(fromValue, toValue, clamp(progress * Time.delta));\\n    }", "building_delta_method": "public float delta(){", "produce": produce, "produce_num": produce_num, "heat_before": heat_before, "time_before": time_before, "time_delta": time_delta, "heat_after": heat_after, "time_after": time_after}',
                        "",
                        f"func java_inner_class_BlockProducerBuild_method_updateTile_move_out_payload_{index}(_args: Array = []) -> Variant:",
                        "\tvar payload_present: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar pay_vector_x: float = float(_args[1] if _args.size() > 1 else 0.0)",
                        "\tvar pay_vector_y: float = float(_args[2] if _args.size() > 2 else 0.0)",
                        "\tvar pay_rotation_before: float = float(_args[3] if _args.size() > 3 else 0.0)",
                        "\tvar rotdeg_value: float = float(_args[4] if _args.size() > 4 else 0.0)",
                        "\tvar size_value: float = float(_args[5] if _args.size() > 5 else 0.0)",
                        "\tvar tilesize: float = float(_args[6] if _args.size() > 6 else 8.0)",
                        "\tvar payload_rotate_speed: float = float(_args[7] if _args.size() > 7 else 0.0)",
                        "\tvar payload_speed: float = float(_args[8] if _args.size() > 8 else 0.0)",
                        "\tvar time_delta: float = float(_args[9] if _args.size() > 9 else 0.0)",
                        "\tvar front_present: bool = bool(_args[10] if _args.size() > 10 else false)",
                        "\tvar front_solid: bool = bool(_args[11] if _args.size() > 11 else false)",
                        "\tvar front_outputs_payload: bool = bool(_args[12] if _args.size() > 12 else false)",
                        "\tvar front_accepts_payload: bool = bool(_args[13] if _args.size() > 13 else false)",
                        "\tvar move_payload_result: bool = bool(_args[14] if _args.size() > 14 else false)",
                        "\tvar half_extent: float = size_value * tilesize / 2.0",
                        "\tvar dest: Variant = null",
                        '\tvar pay_vector_after: Dictionary = {"x": pay_vector_x, "y": pay_vector_y}',
                        "\tvar pay_rotation_after: float = pay_rotation_before",
                        "\tvar update_payload_called: bool = false",
                        "\tvar can_dump: bool = false",
                        "\tvar can_move: bool = false",
                        "\tvar distance_to_dest: float = 0.0",
                        "\tvar distance_to_dest2: float = 0.0",
                        "\tvar pushed_output_fraction: Variant = null",
                        "\tvar arrived: bool = false",
                        "\tvar move_payload_called: bool = false",
                        "\tvar dump_payload_called: bool = false",
                        "\tvar payload_after_present: bool = payload_present",
                        "\tif payload_present:",
                        "\t\tupdate_payload_called = true",
                        "\t\tvar radians: float = deg_to_rad(rotdeg_value)",
                        '\t\tdest = {"x": half_extent * cos(radians), "y": half_extent * sin(radians)}',
                        "\t\tvar rotation_speed: float = payload_rotate_speed * time_delta",
                        "\t\tvar angle_a: float = fmod(fmod(pay_rotation_before, 360.0) + 360.0, 360.0)",
                        "\t\tvar angle_b: float = fmod(fmod(rotdeg_value, 360.0) + 360.0, 360.0)",
                        "\t\tvar forward_angle_dist: float = angle_a - angle_b + 360.0 if (angle_a - angle_b) < 0.0 else angle_a - angle_b",
                        "\t\tvar backward_angle_dist: float = angle_b - angle_a + 360.0 if (angle_b - angle_a) < 0.0 else angle_b - angle_a",
                        "\t\tvar angle_distance: float = min(forward_angle_dist, backward_angle_dist)",
                        "\t\tif abs(angle_distance) < rotation_speed:",
                        "\t\t\tpay_rotation_after = rotdeg_value",
                        "\t\telse:",
                        "\t\t\tvar angle_mod: float = fmod(fmod(pay_rotation_before, 360.0) + 360.0, 360.0)",
                        "\t\t\tvar to_mod: float = fmod(fmod(rotdeg_value, 360.0) + 360.0, 360.0)",
                        "\t\t\tif (angle_mod > to_mod) == ((360.0 - abs(angle_mod - to_mod)) > abs(angle_mod - to_mod)):",
                        "\t\t\t\tpay_rotation_after = angle_mod - rotation_speed",
                        "\t\t\telse:",
                        "\t\t\t\tpay_rotation_after = angle_mod + rotation_speed",
                        "\t\tvar target_x: float = float(dest.get(\"x\", 0.0))",
                        "\t\tvar target_y: float = float(dest.get(\"y\", 0.0))",
                        "\t\tvar dx_approach: float = pay_vector_x - target_x",
                        "\t\tvar dy_approach: float = pay_vector_y - target_y",
                        "\t\tvar approach_alpha: float = payload_speed * time_delta",
                        "\t\tvar approach_alpha2: float = approach_alpha * approach_alpha",
                        "\t\tvar approach_len2: float = dx_approach * dx_approach + dy_approach * dy_approach",
                        "\t\tif approach_len2 > approach_alpha2:",
                        "\t\t\tvar scl: float = sqrt(approach_alpha2 / approach_len2)",
                        '\t\t\tpay_vector_after = {"x": pay_vector_x - dx_approach * scl, "y": pay_vector_y - dy_approach * scl}',
                        "\t\telse:",
                        '\t\t\tpay_vector_after = {"x": target_x, "y": target_y}',
                        "\t\tcan_dump = (not front_present) or (not front_solid)",
                        "\t\tcan_move = front_present and (front_outputs_payload or front_accepts_payload)",
                        "\t\tvar dx: float = target_x - float(pay_vector_after.get(\"x\", 0.0))",
                        "\t\tvar dy: float = target_y - float(pay_vector_after.get(\"y\", 0.0))",
                        "\t\tdistance_to_dest2 = dx * dx + dy * dy",
                        "\t\tdistance_to_dest = sqrt(distance_to_dest2)",
                        "\t\tif can_dump and not can_move:",
                        "\t\t\tpushed_output_fraction = 1.0 - (distance_to_dest / half_extent)",
                        "\t\tarrived = distance_to_dest2 < 0.001 * 0.001",
                        "\t\tif arrived:",
                        '\t\t\tpay_vector_after = {"x": clampf(float(pay_vector_after.get("x", 0.0)), -half_extent, half_extent), "y": clampf(float(pay_vector_after.get("y", 0.0)), -half_extent, half_extent)}',
                        "\t\t\tif can_move:",
                        "\t\t\t\tmove_payload_called = true",
                        "\t\t\t\tpayload_after_present = not move_payload_result",
                        "\t\t\telif can_dump:",
                        "\t\t\t\tdump_payload_called = true",
                        '\treturn {"source_owner": "PortGame.source_block_producer_build_update_tile_move_out_payload_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "parent_source": "core/src/mindustry/world/blocks/payloads/PayloadBlock.java", "arc_source": "arc-core/src/arc/math/Angles.java; arc-core/src/arc/math/geom/Vec2.java; arc-core/src/arc/math/geom/Position.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "update_tile_method": "public void updateTile(){", "move_out_payload_expr": "moveOutPayload();", "method": "public void moveOutPayload(){", "payload_null_guard": "if(payload == null) return;", "update_payload_expr": "updatePayload();", "dest_expr": "Vec2 dest = Tmp.v1.trns(rotdeg(), size * tilesize/2f);", "pay_rotation_expr": "payRotation = Angles.moveToward(payRotation, rotdeg(), payloadRotateSpeed * delta());", "pay_vector_expr": "payVector.approach(dest, payloadSpeed * delta());", "front_expr": "Building front = front();", "can_dump_expr": "boolean canDump = front == null || !front.tile.solid();", "can_move_expr": "boolean canMove = front != null && (front.block.outputsPayload || front.block.acceptsPayload);", "push_output_expr": "pushOutput(payload, 1f - (payVector.dst(dest) / (size * tilesize / 2f)));", "arrived_guard": "if(payVector.within(dest, 0.001f)){", "clamp_expr": "payVector.clamp(-size * tilesize / 2f, -size * tilesize / 2f, size * tilesize / 2f, size * tilesize / 2f);", "move_payload_expr": "if(movePayload(payload)){", "payload_clear_expr": "payload = null;", "dump_payload_expr": "dumpPayload();", "payload_present": payload_present, "pay_vector_x": pay_vector_x, "pay_vector_y": pay_vector_y, "pay_rotation_before": pay_rotation_before, "rotdeg_value": rotdeg_value, "size_value": size_value, "tilesize": tilesize, "payload_rotate_speed": payload_rotate_speed, "payload_speed": payload_speed, "time_delta": time_delta, "front_present": front_present, "front_solid": front_solid, "front_outputs_payload": front_outputs_payload, "front_accepts_payload": front_accepts_payload, "move_payload_result": move_payload_result, "half_extent": half_extent, "dest": dest, "update_payload_called": update_payload_called, "pay_rotation_after": pay_rotation_after, "pay_vector_after": pay_vector_after, "can_dump": can_dump, "can_move": can_move, "distance_to_dest": distance_to_dest, "distance_to_dest2": distance_to_dest2, "pushed_output_fraction": pushed_output_fraction, "arrived": arrived, "move_payload_called": move_payload_called, "dump_payload_called": dump_payload_called, "payload_after_present": payload_after_present}',
                    ])
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/LiquidTurret.java"
        and type_entry.get("name") == "LiquidTurret"
    ):
        for inner_class in type_entry.get("inner_classes", []):
            if inner_class.get("name") != "LiquidTurretBuild":
                continue
            for index, method in enumerate(inner_class.get("methods", [])):
                if method.get("name") == "shouldActiveSound":
                    lines.extend([
                        "",
                        f"func java_inner_class_LiquidTurretBuild_method_shouldActiveSound_{index}(_args: Array = []) -> Variant:",
                        "\tvar was_shooting: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar enabled: bool = bool(_args[1] if _args.size() > 1 else false)",
                        "\treturn {\"source_owner\": \"PortGame.source_liquid_turret_build_should_active_sound_state\", \"inner_class\": \"public class LiquidTurretBuild extends TurretBuild{\", \"method\": \"public boolean shouldActiveSound(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return wasShooting && enabled;\", \"was_shooting\": was_shooting, \"enabled\": enabled, \"should_active_sound\": was_shooting and enabled}",
                    ])
                elif method.get("name") == "getAmmoContent":
                    lines.extend([
                        "",
                        f"func java_inner_class_LiquidTurretBuild_method_getAmmoContent_{index}(_args: Array = []) -> Variant:",
                        "\tvar liquids_null: bool = bool(_args[0] if _args.size() > 0 else true)",
                        "\tvar current_amount: float = float(_args[1] if _args.size() > 1 else 0.0)",
                        "\tvar current_liquid: Variant = _args[2] if _args.size() > 2 else null",
                        "\tvar ammo_content: Variant = current_liquid if not liquids_null and current_amount > 0.0 else null",
                        "\treturn {\"source_owner\": \"PortGame.source_liquid_turret_build_get_ammo_content_state\", \"inner_class\": \"public class LiquidTurretBuild extends TurretBuild{\", \"method\": \"public UnlockableContent getAmmoContent(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return liquids != null && liquids.currentAmount() > 0f ? liquids.current() : null;\", \"liquids_null\": liquids_null, \"current_amount\": current_amount, \"current_liquid\": current_liquid, \"ammo_content\": ammo_content}",
                    ])
                elif method.get("name") == "getAmmoFraction":
                    lines.extend([
                        "",
                        f"func java_inner_class_LiquidTurretBuild_method_getAmmoFraction_{index}(_args: Array = []) -> Variant:",
                        "\tvar current_amount: float = float(_args[0] if _args.size() > 0 else 0.0)",
                        "\tvar liquid_capacity: float = float(_args[1] if _args.size() > 1 else 1.0)",
                        "\tvar ammo_fraction: float = current_amount / liquid_capacity",
                        "\treturn {\"source_owner\": \"PortGame.source_liquid_turret_build_get_ammo_fraction_state\", \"inner_class\": \"public class LiquidTurretBuild extends TurretBuild{\", \"method\": \"public float getAmmoFraction(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return liquids.currentAmount() / liquidCapacity;\", \"current_amount\": current_amount, \"liquid_capacity\": liquid_capacity, \"ammo_fraction\": ammo_fraction}",
                    ])
                elif method.get("name") == "senseObject":
                    lines.extend([
                        "",
                        f"func java_inner_class_LiquidTurretBuild_method_senseObject_{index}(_args: Array = []) -> Variant:",
                        "\tvar sensor: String = str(_args[0] if _args.size() > 0 else \"\")",
                        "\tvar current_liquid: Variant = _args[1] if _args.size() > 1 else null",
                        "\tvar super_sense_object_value: Variant = _args[2] if _args.size() > 2 else null",
                        "\tvar sense_object_value: Variant = null",
                        "\tif sensor == \"currentAmmoType\":",
                        "\t\tsense_object_value = current_liquid",
                        "\telse:",
                        "\t\tsense_object_value = super_sense_object_value",
                        "\treturn {\"source_owner\": \"PortGame.source_liquid_turret_build_sense_object_state\", \"inner_class\": \"public class LiquidTurretBuild extends TurretBuild{\", \"method\": \"public Object senseObject(LAccess sensor){\", \"override_expr\": \"@Override\", \"switch_return_expr\": \"return switch(sensor){\", \"current_ammo_type_case\": \"case currentAmmoType -> liquids.current();\", \"default_case\": \"default -> super.senseObject(sensor);\", \"sensor\": sensor, \"current_liquid\": current_liquid, \"super_sense_object_value\": super_sense_object_value, \"sense_object_value\": sense_object_value}",
                    ])
                elif method.get("name") == "findTarget":
                    lines.extend([
                        "",
                        f"func java_inner_class_LiquidTurretBuild_method_findTarget_{index}(_args: Array = []) -> Variant:",
                        "\tvar extinguish: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar current_liquid_can_extinguish: bool = bool(_args[1] if _args.size() > 1 else false)",
                        "\tvar fire_result: Variant = _args[2] if _args.size() > 2 else null",
                        "\tvar should_scan_fires: bool = extinguish and current_liquid_can_extinguish",
                        "\tvar target_after: Variant = null",
                        "\tvar target_assigned: bool = false",
                        "\tvar super_find_target_called: bool = true",
                        "\tif should_scan_fires and fire_result != null:",
                        "\t\ttarget_after = fire_result",
                        "\t\ttarget_assigned = true",
                        "\t\tsuper_find_target_called = false",
                        "\treturn {\"source_owner\": \"PortGame.source_liquid_turret_build_find_target_extinguish_state\", \"inner_class\": \"public class LiquidTurretBuild extends TurretBuild{\", \"method\": \"protected void findTarget(){\", \"override_expr\": \"@Override\", \"guard_expr\": \"if(extinguish && liquids.current().canExtinguish()){\", \"result_init_expr\": \"Fire result = null;\", \"assign_expr\": \"target = result;\", \"return_expr\": \"return;\", \"super_find_target_expr\": \"super.findTarget();\", \"extinguish\": extinguish, \"current_liquid_can_extinguish\": current_liquid_can_extinguish, \"fire_result\": fire_result, \"should_scan_fires\": should_scan_fires, \"target_after\": target_after, \"target_assigned\": target_assigned, \"super_find_target_called\": super_find_target_called}",
                    ])
                elif method.get("name") == "useAmmo":
                    lines.extend([
                        "",
                        f"func java_inner_class_LiquidTurretBuild_method_useAmmo_{index}(_args: Array = []) -> Variant:",
                        "\tvar cheating: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar current_liquid: Variant = _args[1] if _args.size() > 1 else null",
                        "\tvar ammo_type: Variant = _args[2] if _args.size() > 2 else null",
                        "\tvar ammo_multiplier: float = float(_args[3] if _args.size() > 3 else 1.0)",
                        "\tvar returned_ammo: Variant = ammo_type",
                        "\tvar liquid_remove_amount: float = 0.0",
                        "\tvar remove_liquid_call: Dictionary = {}",
                        "\tif not cheating:",
                        "\t\tliquid_remove_amount = 1.0 / ammo_multiplier",
                        "\t\tremove_liquid_call = {\"call\": \"liquids.remove(liquids.current(), 1f / type.ammoMultiplier);\", \"liquid\": current_liquid, \"amount\": liquid_remove_amount}",
                        "\treturn {\"source_owner\": \"PortGame.source_liquid_turret_build_use_ammo_state\", \"inner_class\": \"public class LiquidTurretBuild extends TurretBuild{\", \"method\": \"public BulletType useAmmo(){\", \"override_expr\": \"@Override\", \"cheating_return_expr\": \"if(cheating()) return ammoTypes.get(liquids.current());\", \"type_lookup_expr\": \"BulletType type = ammoTypes.get(liquids.current());\", \"remove_expr\": \"liquids.remove(liquids.current(), 1f / type.ammoMultiplier);\", \"return_expr\": \"return type;\", \"cheating\": cheating, \"current_liquid\": current_liquid, \"ammo_type\": ammo_type, \"ammo_multiplier\": ammo_multiplier, \"liquid_remove_amount\": liquid_remove_amount, \"remove_liquid_call\": remove_liquid_call, \"returned_ammo\": returned_ammo}",
                    ])
                elif method.get("name") == "peekAmmo":
                    lines.extend([
                        "",
                        f"func java_inner_class_LiquidTurretBuild_method_peekAmmo_{index}(_args: Array = []) -> Variant:",
                        "\tvar current_liquid: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar ammo_type: Variant = _args[1] if _args.size() > 1 else null",
                        "\treturn {\"source_owner\": \"PortGame.source_liquid_turret_build_peek_ammo_state\", \"inner_class\": \"public class LiquidTurretBuild extends TurretBuild{\", \"method\": \"public BulletType peekAmmo(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return ammoTypes.get(liquids.current());\", \"current_liquid\": current_liquid, \"peek_ammo\": ammo_type}",
                    ])
                elif method.get("name") == "hasAmmo":
                    lines.extend([
                        "",
                        f"func java_inner_class_LiquidTurretBuild_method_hasAmmo_{index}(_args: Array = []) -> Variant:",
                        "\tvar current_liquid: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar ammo_type: Variant = _args[1] if _args.size() > 1 else null",
                        "\tvar current_amount: float = float(_args[2] if _args.size() > 2 else 0.0)",
                        "\tvar ammo_multiplier: float = float(_args[3] if _args.size() > 3 else 1.0)",
                        "\tvar ammo_type_present: bool = ammo_type != null",
                        "\tvar required_amount: float = 1.0 / ammo_multiplier",
                        "\tvar has_ammo: bool = ammo_type_present and current_amount >= required_amount",
                        "\treturn {\"source_owner\": \"PortGame.source_liquid_turret_build_has_ammo_state\", \"inner_class\": \"public class LiquidTurretBuild extends TurretBuild{\", \"method\": \"public boolean hasAmmo(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return ammoTypes.get(liquids.current()) != null && liquids.currentAmount() >= 1f / ammoTypes.get(liquids.current()).ammoMultiplier;\", \"current_liquid\": current_liquid, \"ammo_type\": ammo_type, \"current_amount\": current_amount, \"ammo_multiplier\": ammo_multiplier, \"ammo_type_present\": ammo_type_present, \"required_amount\": required_amount, \"has_ammo\": has_ammo}",
                    ])
                elif method.get("name") == "acceptItem":
                    lines.extend([
                        "",
                        f"func java_inner_class_LiquidTurretBuild_method_acceptItem_{index}(_args: Array = []) -> Variant:",
                        "\tvar source_building: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar item: Variant = _args[1] if _args.size() > 1 else null",
                        "\tvar accept_item: bool = false",
                        "\treturn {\"source_owner\": \"PortGame.source_liquid_turret_build_accept_item_state\", \"inner_class\": \"public class LiquidTurretBuild extends TurretBuild{\", \"method\": \"public boolean acceptItem(Building source, Item item){\", \"override_expr\": \"@Override\", \"return_expr\": \"return false;\", \"source_building\": source_building, \"item\": item, \"accept_item\": accept_item}",
                    ])
                elif method.get("name") == "acceptLiquid":
                    lines.extend([
                        "",
                        f"func java_inner_class_LiquidTurretBuild_method_acceptLiquid_{index}(_args: Array = []) -> Variant:",
                        "\tvar source_building: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar liquid: Variant = _args[1] if _args.size() > 1 else null",
                        "\tvar ammo_type: Variant = _args[2] if _args.size() > 2 else null",
                        "\tvar current_liquid: Variant = _args[3] if _args.size() > 3 else null",
                        "\tvar current_liquid_ammo_type_present: bool = bool(_args[4] if _args.size() > 4 else false)",
                        "\tvar current_liquid_amount: float = float(_args[5] if _args.size() > 5 else 0.0)",
                        "\tvar current_ammo_multiplier: float = float(_args[6] if _args.size() > 6 else 1.0)",
                        "\tvar liquid_has_ammo_type: bool = ammo_type != null",
                        "\tvar same_liquid: bool = current_liquid == liquid",
                        "\tvar current_liquid_missing_ammo_type: bool = not current_liquid_ammo_type_present",
                        "\tvar current_required_with_epsilon: Variant = null",
                        "\tvar current_liquid_drained: bool = false",
                        "\tif liquid_has_ammo_type and not same_liquid and current_liquid_ammo_type_present:",
                        "\t\tcurrent_required_with_epsilon = 1.0 / current_ammo_multiplier + 0.001",
                        "\t\tcurrent_liquid_drained = current_liquid_amount <= current_required_with_epsilon",
                        "\tvar replacement_allowed: bool = false",
                        "\tif liquid_has_ammo_type and not same_liquid:",
                        "\t\treplacement_allowed = current_liquid_missing_ammo_type or current_liquid_drained",
                        "\tvar accept_liquid: bool = liquid_has_ammo_type and (same_liquid or replacement_allowed)",
                        "\treturn {\"source_owner\": \"PortGame.source_liquid_turret_build_accept_liquid_state\", \"inner_class\": \"public class LiquidTurretBuild extends TurretBuild{\", \"method\": \"public boolean acceptLiquid(Building source, Liquid liquid){\", \"override_expr\": \"@Override\", \"return_expr\": \"return ammoTypes.get(liquid) != null && (liquids.current() == liquid || ((!ammoTypes.containsKey(liquids.current()) || liquids.get(liquids.current()) <= 1f / ammoTypes.get(liquids.current()).ammoMultiplier + 0.001f)));\", \"source_building\": source_building, \"liquid\": liquid, \"ammo_type\": ammo_type, \"current_liquid\": current_liquid, \"current_liquid_ammo_type_present\": current_liquid_ammo_type_present, \"current_liquid_amount\": current_liquid_amount, \"current_ammo_multiplier\": current_ammo_multiplier, \"liquid_has_ammo_type\": liquid_has_ammo_type, \"same_liquid\": same_liquid, \"current_liquid_missing_ammo_type\": current_liquid_missing_ammo_type, \"current_required_with_epsilon\": current_required_with_epsilon, \"current_liquid_drained\": current_liquid_drained, \"replacement_allowed\": replacement_allowed, \"accept_liquid\": accept_liquid}",
                    ])
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java"
        and type_entry.get("name") == "ContinuousLiquidTurret"
    ):
        for inner_class in type_entry.get("inner_classes", []):
            if inner_class.get("name") != "ContinuousLiquidTurretBuild":
                continue
            for index, method in enumerate(inner_class.get("methods", [])):
                if method.get("name") == "shouldActiveSound":
                    lines.extend([
                        "",
                        f"func java_inner_class_ContinuousLiquidTurretBuild_method_shouldActiveSound_{index}(_args: Array = []) -> Variant:",
                        "\tvar was_shooting: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar enabled: bool = bool(_args[1] if _args.size() > 1 else false)",
                        "\treturn {\"source_owner\": \"PortGame.source_continuous_liquid_turret_build_should_active_sound_state\", \"inner_class\": \"public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{\", \"field\": \"boolean activated;\", \"method\": \"public boolean shouldActiveSound(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return wasShooting && enabled;\", \"was_shooting\": was_shooting, \"enabled\": enabled, \"should_active_sound\": was_shooting and enabled}",
                    ])
                elif method.get("name") == "getAmmoContent":
                    lines.extend([
                        "",
                        f"func java_inner_class_ContinuousLiquidTurretBuild_method_getAmmoContent_{index}(_args: Array = []) -> Variant:",
                        "\tvar liquids_null: bool = bool(_args[0] if _args.size() > 0 else true)",
                        "\tvar current_amount: float = float(_args[1] if _args.size() > 1 else 0.0)",
                        "\tvar current_liquid: Variant = _args[2] if _args.size() > 2 else null",
                        "\tvar ammo_content: Variant = current_liquid if not liquids_null and current_amount > 0.0 else null",
                        "\treturn {\"source_owner\": \"PortGame.source_continuous_liquid_turret_build_get_ammo_content_state\", \"inner_class\": \"public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{\", \"field\": \"boolean activated;\", \"method\": \"public UnlockableContent getAmmoContent(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return liquids != null && liquids.currentAmount() > 0f ? liquids.current() : null;\", \"liquids_null\": liquids_null, \"current_amount\": current_amount, \"current_liquid\": current_liquid, \"ammo_content\": ammo_content}",
                    ])
                elif method.get("name") == "getAmmoFraction":
                    lines.extend([
                        "",
                        f"func java_inner_class_ContinuousLiquidTurretBuild_method_getAmmoFraction_{index}(_args: Array = []) -> Variant:",
                        "\tvar current_amount: float = float(_args[0] if _args.size() > 0 else 0.0)",
                        "\tvar liquid_capacity: float = float(_args[1] if _args.size() > 1 else 1.0)",
                        "\tvar ammo_fraction: float = current_amount / liquid_capacity",
                        "\treturn {\"source_owner\": \"PortGame.source_continuous_liquid_turret_build_get_ammo_fraction_state\", \"inner_class\": \"public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{\", \"field\": \"boolean activated;\", \"method\": \"public float getAmmoFraction(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return liquids.currentAmount() / liquidCapacity;\", \"current_amount\": current_amount, \"liquid_capacity\": liquid_capacity, \"ammo_fraction\": ammo_fraction}",
                    ])
                elif method.get("name") == "updateTile":
                    lines.extend([
                        "",
                        f"func java_inner_class_ContinuousLiquidTurretBuild_method_updateTile_{index}(_args: Array = []) -> Variant:",
                        "\tvar current_amount: float = float(_args[0] if _args.size() > 0 else 0.0)",
                        "\tvar liquid_consumed: float = float(_args[1] if _args.size() > 1 else 0.0)",
                        "\tvar activated_before: bool = bool(_args[2] if _args.size() > 2 else false)",
                        "\tvar activate_threshold: float = liquid_consumed * 4.0",
                        "\tvar activated_after: bool = activated_before",
                        "\tif current_amount >= activate_threshold:",
                        "\t\tactivated_after = true",
                        "\telif current_amount < liquid_consumed:",
                        "\t\tactivated_after = false",
                        "\treturn {\"source_owner\": \"PortGame.source_continuous_liquid_turret_build_update_tile_state\", \"inner_class\": \"public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{\", \"field\": \"boolean activated;\", \"method\": \"public void updateTile(){\", \"override_expr\": \"@Override\", \"super_update_tile_expr\": \"super.updateTile();\", \"super_update_tile_called\": true, \"comment\": \"//only allow the turret to begin firing when it can fire for 4 continuous updates\", \"activate_guard_expr\": \"if(liquids.currentAmount() >= liquidConsumed * 4f){\", \"activated_true_expr\": \"activated = true;\", \"deactivate_guard_expr\": \"}else if(liquids.currentAmount() < liquidConsumed){\", \"activated_false_expr\": \"activated = false;\", \"current_amount\": current_amount, \"liquid_consumed\": liquid_consumed, \"activated_before\": activated_before, \"activate_threshold\": activate_threshold, \"activated_after\": activated_after}",
                    ])
                elif method.get("name") == "senseObject":
                    lines.extend([
                        "",
                        f"func java_inner_class_ContinuousLiquidTurretBuild_method_senseObject_{index}(_args: Array = []) -> Variant:",
                        "\tvar sensor: String = str(_args[0] if _args.size() > 0 else \"\")",
                        "\tvar current_liquid: Variant = _args[1] if _args.size() > 1 else null",
                        "\tvar super_sense_object_value: Variant = _args[2] if _args.size() > 2 else null",
                        "\tvar sense_object_value: Variant = null",
                        "\tif sensor == \"currentAmmoType\":",
                        "\t\tsense_object_value = current_liquid",
                        "\telse:",
                        "\t\tsense_object_value = super_sense_object_value",
                        "\treturn {\"source_owner\": \"PortGame.source_continuous_liquid_turret_build_sense_object_state\", \"inner_class\": \"public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{\", \"field\": \"boolean activated;\", \"method\": \"public Object senseObject(LAccess sensor){\", \"override_expr\": \"@Override\", \"switch_return_expr\": \"return switch(sensor){\", \"current_ammo_type_case\": \"case currentAmmoType -> liquids.current();\", \"default_case\": \"default -> super.senseObject(sensor);\", \"sensor\": sensor, \"current_liquid\": current_liquid, \"super_sense_object_value\": super_sense_object_value, \"sense_object_value\": sense_object_value}",
                    ])
                elif method.get("name") == "canConsume":
                    lines.extend([
                        "",
                        f"func java_inner_class_ContinuousLiquidTurretBuild_method_canConsume_{index}(_args: Array = []) -> Variant:",
                        "\tvar has_correct_ammo: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar super_can_consume: bool = bool(_args[1] if _args.size() > 1 else false)",
                        "\tvar can_consume: bool = has_correct_ammo and super_can_consume",
                        "\treturn {\"source_owner\": \"PortGame.source_continuous_liquid_turret_build_can_consume_state\", \"inner_class\": \"public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{\", \"field\": \"boolean activated;\", \"method\": \"public boolean canConsume(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return hasCorrectAmmo() && super.canConsume();\", \"has_correct_ammo\": has_correct_ammo, \"super_can_consume\": super_can_consume, \"can_consume\": can_consume}",
                    ])
                elif method.get("name") == "shouldConsume":
                    lines.extend([
                        "",
                        f"func java_inner_class_ContinuousLiquidTurretBuild_method_shouldConsume_{index}(_args: Array = []) -> Variant:",
                        "\tvar super_should_consume: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar activated: bool = bool(_args[1] if _args.size() > 1 else false)",
                        "\tvar should_consume: bool = super_should_consume and activated",
                        "\treturn {\"source_owner\": \"PortGame.source_continuous_liquid_turret_build_should_consume_state\", \"inner_class\": \"public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{\", \"field\": \"boolean activated;\", \"method\": \"public boolean shouldConsume(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return super.shouldConsume() && activated;\", \"super_should_consume\": super_should_consume, \"activated\": activated, \"should_consume\": should_consume}",
                    ])
                elif method.get("name") == "useAmmo":
                    lines.extend([
                        "",
                        f"func java_inner_class_ContinuousLiquidTurretBuild_method_useAmmo_{index}(_args: Array = []) -> Variant:",
                        "\tvar peek_ammo: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar returned_ammo: Variant = peek_ammo",
                        "\treturn {\"source_owner\": \"PortGame.source_continuous_liquid_turret_build_use_ammo_state\", \"inner_class\": \"public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{\", \"field\": \"boolean activated;\", \"method\": \"public BulletType useAmmo(){\", \"override_expr\": \"@Override\", \"comment\": \"//does not consume ammo upon firing\", \"return_expr\": \"return peekAmmo();\", \"peek_ammo\": peek_ammo, \"returned_ammo\": returned_ammo}",
                    ])
                elif method.get("name") == "peekAmmo":
                    lines.extend([
                        "",
                        f"func java_inner_class_ContinuousLiquidTurretBuild_method_peekAmmo_{index}(_args: Array = []) -> Variant:",
                        "\tvar current_liquid: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar ammo_type: Variant = _args[1] if _args.size() > 1 else null",
                        "\treturn {\"source_owner\": \"PortGame.source_continuous_liquid_turret_build_peek_ammo_state\", \"inner_class\": \"public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{\", \"field\": \"boolean activated;\", \"method\": \"public BulletType peekAmmo(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return ammoTypes.get(liquids.current());\", \"current_liquid\": current_liquid, \"peek_ammo\": ammo_type}",
                    ])
                elif method.get("name") == "hasAmmo":
                    lines.extend([
                        "",
                        f"func java_inner_class_ContinuousLiquidTurretBuild_method_hasAmmo_{index}(_args: Array = []) -> Variant:",
                        "\tvar has_correct_ammo: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar current_liquid: Variant = _args[1] if _args.size() > 1 else null",
                        "\tvar ammo_type: Variant = _args[2] if _args.size() > 2 else null",
                        "\tvar current_amount: float = float(_args[3] if _args.size() > 3 else 0.0)",
                        "\tvar activated: bool = bool(_args[4] if _args.size() > 4 else false)",
                        "\tvar ammo_type_present: bool = ammo_type != null",
                        "\tvar has_ammo: bool = has_correct_ammo and ammo_type_present and current_amount > 0.0 and activated",
                        "\treturn {\"source_owner\": \"PortGame.source_continuous_liquid_turret_build_has_ammo_state\", \"inner_class\": \"public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{\", \"field\": \"boolean activated;\", \"method\": \"public boolean hasAmmo(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return hasCorrectAmmo() && ammoTypes.get(liquids.current()) != null && liquids.currentAmount() > 0f && activated;\", \"has_correct_ammo\": has_correct_ammo, \"current_liquid\": current_liquid, \"ammo_type\": ammo_type, \"current_amount\": current_amount, \"activated\": activated, \"ammo_type_present\": ammo_type_present, \"has_ammo\": has_ammo}",
                    ])
                elif method.get("name") == "hasCorrectAmmo":
                    lines.extend([
                        "",
                        f"func java_inner_class_ContinuousLiquidTurretBuild_method_hasCorrectAmmo_{index}(_args: Array = []) -> Variant:",
                        "\tvar bullets_any: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar first_bullet_type: Variant = _args[1] if _args.size() > 1 else null",
                        "\tvar peek_ammo: Variant = _args[2] if _args.size() > 2 else null",
                        "\tvar has_correct_ammo: bool = (not bullets_any) or first_bullet_type == peek_ammo",
                        "\treturn {\"source_owner\": \"PortGame.source_continuous_liquid_turret_build_has_correct_ammo_state\", \"inner_class\": \"public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{\", \"field\": \"boolean activated;\", \"method\": \"public boolean hasCorrectAmmo(){\", \"return_expr\": \"return !bullets.any() || bullets.first().bullet.type == peekAmmo();\", \"bullets_any\": bullets_any, \"first_bullet_type\": first_bullet_type, \"peek_ammo\": peek_ammo, \"has_correct_ammo\": has_correct_ammo}",
                    ])
                elif method.get("name") == "acceptItem":
                    lines.extend([
                        "",
                        f"func java_inner_class_ContinuousLiquidTurretBuild_method_acceptItem_{index}(_args: Array = []) -> Variant:",
                        "\tvar source_building: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar item: Variant = _args[1] if _args.size() > 1 else null",
                        "\tvar accept_item: bool = false",
                        "\treturn {\"source_owner\": \"PortGame.source_continuous_liquid_turret_build_accept_item_state\", \"inner_class\": \"public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{\", \"field\": \"boolean activated;\", \"method\": \"public boolean acceptItem(Building source, Item item){\", \"override_expr\": \"@Override\", \"return_expr\": \"return false;\", \"source_building\": source_building, \"item\": item, \"accept_item\": accept_item}",
                    ])
                elif method.get("name") == "acceptLiquid":
                    lines.extend([
                        "",
                        f"func java_inner_class_ContinuousLiquidTurretBuild_method_acceptLiquid_{index}(_args: Array = []) -> Variant:",
                        "\tvar source_building: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar liquid: Variant = _args[1] if _args.size() > 1 else null",
                        "\tvar ammo_type: Variant = _args[2] if _args.size() > 2 else null",
                        "\tvar current_liquid: Variant = _args[3] if _args.size() > 3 else null",
                        "\tvar current_liquid_ammo_type_present: bool = bool(_args[4] if _args.size() > 4 else false)",
                        "\tvar current_liquid_amount: float = float(_args[5] if _args.size() > 5 else 0.0)",
                        "\tvar current_ammo_multiplier: float = float(_args[6] if _args.size() > 6 else 1.0)",
                        "\tvar liquid_has_ammo_type: bool = ammo_type != null",
                        "\tvar same_liquid: bool = current_liquid == liquid",
                        "\tvar current_liquid_missing_ammo_type: bool = not current_liquid_ammo_type_present",
                        "\tvar current_required_with_epsilon: Variant = null",
                        "\tvar current_liquid_drained: bool = false",
                        "\tif liquid_has_ammo_type and not same_liquid and current_liquid_ammo_type_present:",
                        "\t\tcurrent_required_with_epsilon = 1.0 / current_ammo_multiplier + 0.001",
                        "\t\tcurrent_liquid_drained = current_liquid_amount <= current_required_with_epsilon",
                        "\tvar replacement_allowed: bool = false",
                        "\tif liquid_has_ammo_type and not same_liquid:",
                        "\t\treplacement_allowed = current_liquid_missing_ammo_type or current_liquid_drained",
                        "\tvar accept_liquid: bool = liquid_has_ammo_type and (same_liquid or replacement_allowed)",
                        "\treturn {\"source_owner\": \"PortGame.source_continuous_liquid_turret_build_accept_liquid_state\", \"inner_class\": \"public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{\", \"field\": \"boolean activated;\", \"method\": \"public boolean acceptLiquid(Building source, Liquid liquid){\", \"override_expr\": \"@Override\", \"return_expr\": \"return ammoTypes.get(liquid) != null && (liquids.current() == liquid || ((!ammoTypes.containsKey(liquids.current()) || liquids.get(liquids.current()) <= 1f / ammoTypes.get(liquids.current()).ammoMultiplier + 0.001f)));\", \"source_building\": source_building, \"liquid\": liquid, \"ammo_type\": ammo_type, \"current_liquid\": current_liquid, \"current_liquid_ammo_type_present\": current_liquid_ammo_type_present, \"current_liquid_amount\": current_liquid_amount, \"current_ammo_multiplier\": current_ammo_multiplier, \"liquid_has_ammo_type\": liquid_has_ammo_type, \"same_liquid\": same_liquid, \"current_liquid_missing_ammo_type\": current_liquid_missing_ammo_type, \"current_required_with_epsilon\": current_required_with_epsilon, \"current_liquid_drained\": current_liquid_drained, \"replacement_allowed\": replacement_allowed, \"accept_liquid\": accept_liquid}",
                    ])
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/TractorBeamTurret.java"
        and type_entry.get("name") == "TractorBeamTurret"
    ):
        for inner_class in type_entry.get("inner_classes", []):
            if inner_class.get("name") != "TractorBeamBuild":
                continue
            for index, method in enumerate(inner_class.get("methods", [])):
                if method.get("name") == "updateTile":
                    lines.extend([
                        "",
                        f"func java_inner_class_TractorBeamBuild_method_updateTile_{index}(_args: Array = []) -> Variant:",
                        "\tvar activation_timer: float = float(_args[0] if _args.size() > 0 else 0.0)",
                        "\tvar time_delta: float = float(_args[1] if _args.size() > 1 else 0.0)",
                        "\tvar activation_guard: bool = activation_timer > 0.0",
                        "\tvar activation_timer_after: float = activation_timer - time_delta if activation_guard else activation_timer",
                        "\tvar returned_early: bool = activation_guard",
                        "\tvar activation_returned_early: bool = activation_guard",
                        "\tvar efficiency: float = float(_args[2] if _args.size() > 2 else 0.0)",
                        "\tvar coolant_multiplier: float = float(_args[3] if _args.size() > 3 else 1.0)",
                        "\tvar delta_value: float = float(_args[4] if _args.size() > 4 else 0.0)",
                        "\tvar eff_calculated: bool = not activation_returned_early",
                        "\tvar eff: float = efficiency * coolant_multiplier if eff_calculated else 0.0",
                        "\tvar edelta: float = eff * delta_value if eff_calculated else 0.0",
                        "\tvar timer_target_ready: bool = bool(_args[5] if _args.size() > 5 else false)",
                        "\tvar existing_target: Variant = _args[6] if _args.size() > 6 else null",
                        "\tvar closest_enemy_result: Variant = _args[7] if _args.size() > 7 else null",
                        "\tvar team: Variant = _args[8] if _args.size() > 8 else null",
                        "\tvar x: float = float(_args[9] if _args.size() > 9 else 0.0)",
                        "\tvar y: float = float(_args[10] if _args.size() > 10 else 0.0)",
                        "\tvar range_value: float = float(_args[11] if _args.size() > 11 else 0.0)",
                        "\tvar target_air: bool = bool(_args[12] if _args.size() > 12 else false)",
                        "\tvar target_ground: bool = bool(_args[13] if _args.size() > 13 else false)",
                        "\tvar retarget_evaluated: bool = not activation_returned_early",
                        "\tvar retarget_called: bool = retarget_evaluated and timer_target_ready",
                        "\tvar target_after: Variant = closest_enemy_result if retarget_called else existing_target",
                        "\tvar closest_enemy_call: Dictionary = {}",
                        "\tif retarget_called:",
                        "\t\tclosest_enemy_call = {\"call\": \"Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));\", \"team\": team, \"x\": x, \"y\": y, \"range\": range_value, \"target_air\": target_air, \"target_ground\": target_ground, \"result\": closest_enemy_result}",
                        "\tvar coolant_present: bool = bool(_args[14] if _args.size() > 14 else false)",
                        "\tvar coolant_amount: float = float(_args[15] if _args.size() > 15 else 0.0)",
                        "\tvar current_liquid: Variant = _args[16] if _args.size() > 16 else null",
                        "\tvar coolant_evaluated: bool = not activation_returned_early",
                        "\tvar coolant_guard: bool = coolant_evaluated and target_after != null and coolant_present",
                        "\tvar max_used: float = coolant_amount if coolant_guard else 0.0",
                        "\tvar liquid: Variant = current_liquid if coolant_guard else null",
                        "\tvar liquid_amount: float = float(_args[17] if _args.size() > 17 else 0.0)",
                        "\tvar liquid_heat_capacity: float = float(_args[18] if _args.size() > 18 else 1.0)",
                        "\tvar max_used_time_delta: float = max_used * time_delta if coolant_guard else 0.0",
                        "\tvar heat_capacity_limit: float = (1.0 / coolant_multiplier) / liquid_heat_capacity if coolant_guard else 0.0",
                        "\tvar nonnegative_heat_capacity_limit: float = max(0.0, heat_capacity_limit) if coolant_guard else 0.0",
                        "\tvar used: float = min(min(liquid_amount, max_used_time_delta), nonnegative_heat_capacity_limit) if coolant_guard else 0.0",
                        "\tvar remove_called: bool = coolant_guard",
                        "\tvar remove_call: Dictionary = {}",
                        "\tif remove_called:",
                        "\t\tremove_call = {\"call\": \"liquids.remove(liquid, used);\", \"liquid\": liquid, \"amount\": used}",
                        "\tvar chance_result: bool = bool(_args[19] if _args.size() > 19 else false)",
                        "\tvar size: float = float(_args[20] if _args.size() > 20 else 0.0)",
                        "\tvar source_tilesize: float = float(_args[21] if _args.size() > 21 else 8.0)",
                        "\tvar range_x: float = float(_args[22] if _args.size() > 22 else 0.0)",
                        "\tvar range_y: float = float(_args[23] if _args.size() > 23 else 0.0)",
                        "\tvar chance_threshold: float = 0.06 * used if coolant_guard else 0.0",
                        "\tvar particle_range: float = size * source_tilesize / 2.0 if coolant_guard else 0.0",
                        "\tvar chance_called: bool = coolant_guard",
                        "\tvar cool_effect_called: bool = coolant_guard and chance_result",
                        "\tvar cool_effect_call: Dictionary = {}",
                        "\tif cool_effect_called:",
                        "\t\tcool_effect_call = {\"call\": \"coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));\", \"x\": x + range_x, \"y\": y + range_y, \"range\": particle_range}",
                        "\tvar coolant_multiplier_assign_called: bool = coolant_guard",
                        "\tvar coolant_multiplier_after: float = 1.0 + (used * liquid_heat_capacity * coolant_multiplier) if coolant_guard else coolant_multiplier",
                        "\tvar coolant_multiplier_assign_call: Dictionary = {}",
                        "\tif coolant_multiplier_assign_called:",
                        "\t\tcoolant_multiplier_assign_call = {\"call\": \"coolantMultiplier = 1f + (used * liquid.heatCapacity * coolantMultiplier);\", \"value\": coolant_multiplier_after}",
                        "\tvar any_before: bool = bool(_args[24] if _args.size() > 24 else false)",
                        "\tvar any_reset_evaluated: bool = not activation_returned_early",
                        "\tvar any_reset_called: bool = any_reset_evaluated",
                        "\tvar any_after: bool = false if any_reset_evaluated else any_before",
                        "\tvar any_reset_call: Dictionary = {}",
                        "\tif any_reset_called:",
                        "\t\tany_reset_call = {\"call\": \"any = false;\", \"value\": any_after}",
                        "\tvar target_within_result: bool = bool(_args[25] if _args.size() > 25 else false)",
                        "\tvar target_team: Variant = _args[26] if _args.size() > 26 else null",
                        "\tvar target_check_result: bool = bool(_args[27] if _args.size() > 27 else false)",
                        "\tvar target_hit_size: float = float(_args[28] if _args.size() > 28 else 0.0)",
                        "\tvar look_target_evaluated: bool = not activation_returned_early",
                        "\tvar target_exists_for_look: bool = look_target_evaluated and target_after != null",
                        "\tvar target_within_radius: float = range_value + target_hit_size / 2.0 if target_exists_for_look else 0.0",
                        "\tvar target_within_evaluated: bool = target_exists_for_look",
                        "\tvar target_within_call: Dictionary = {}",
                        "\tif target_within_evaluated:",
                        "\t\ttarget_within_call = {\"call\": \"target.within(this, range + target.hitSize/2f)\", \"target\": target_after, \"radius\": target_within_radius, \"result\": target_within_result}",
                        "\tvar target_team_evaluated: bool = target_within_evaluated and target_within_result",
                        "\tvar target_enemy: bool = target_team != team if target_team_evaluated else false",
                        "\tvar target_check_evaluated: bool = target_team_evaluated and target_enemy",
                        "\tvar target_check_call: Dictionary = {}",
                        "\tif target_check_evaluated:",
                        "\t\ttarget_check_call = {\"call\": \"target.checkTarget(targetAir, targetGround)\", \"target_air\": target_air, \"target_ground\": target_ground, \"result\": target_check_result}",
                        "\tvar efficiency_gate_evaluated: bool = target_check_evaluated and target_check_result",
                        "\tvar look_target_guard: bool = efficiency_gate_evaluated and efficiency > 0.02",
                        "\tvar headless: bool = bool(_args[29] if _args.size() > 29 else false)",
                        "\tvar shoot_sound: Variant = _args[30] if _args.size() > 30 else null",
                        "\tvar shoot_sound_volume: float = float(_args[31] if _args.size() > 31 else 1.0)",
                        "\tvar sound_loop_evaluated: bool = look_target_guard",
                        "\tvar sound_loop_called: bool = sound_loop_evaluated and not headless",
                        "\tvar shoot_sound_loop_call: Dictionary = {}",
                        "\tif sound_loop_called:",
                        "\t\tshoot_sound_loop_call = {\"call\": \"control.sound.loop(shootSound, this, shootSoundVolume);\", \"sound\": shoot_sound, \"target\": \"this\", \"volume\": shoot_sound_volume}",
                        "\tvar angle_to_target_evaluated: bool = look_target_guard",
                        "\tvar dest: float = 0.0",
                        "\tif angle_to_target_evaluated and target_after is Dictionary:",
                        "\t\tdest = rad_to_deg(atan2(float(target_after.get(\"y\", 0.0)) - y, float(target_after.get(\"x\", 0.0)) - x))",
                        "\t\tif dest < 0.0:",
                        "\t\t\tdest += 360.0",
                        "\tvar angle_to_target_call: Dictionary = {}",
                        "\tif angle_to_target_evaluated:",
                        "\t\tangle_to_target_call = {\"call\": \"angleTo(target)\", \"origin\": {\"x\": x, \"y\": y}, \"target\": target_after, \"result\": dest}",
                        "\tvar rotation_before: float = float(_args[32] if _args.size() > 32 else 0.0)",
                        "\tvar rotate_speed: float = float(_args[33] if _args.size() > 33 else 0.0)",
                        "\tvar rotation_move_evaluated: bool = angle_to_target_evaluated",
                        "\tvar rotation_max_delta: float = rotate_speed * edelta if rotation_move_evaluated else 0.0",
                        "\tvar rotation_after: float = rotation_before",
                        "\tvar rotation_move_call: Dictionary = {}",
                        "\tif rotation_move_evaluated:",
                        "\t\tvar rotation_angle_mod: float = fmod(fmod(rotation_before, 360.0) + 360.0, 360.0)",
                        "\t\tvar rotation_to_mod: float = fmod(fmod(dest, 360.0) + 360.0, 360.0)",
                        "\t\tvar rotation_forward_delta: float = rotation_angle_mod - rotation_to_mod + 360.0 if (rotation_angle_mod - rotation_to_mod) < 0.0 else rotation_angle_mod - rotation_to_mod",
                        "\t\tvar rotation_backward_delta: float = rotation_to_mod - rotation_angle_mod + 360.0 if (rotation_to_mod - rotation_angle_mod) < 0.0 else rotation_to_mod - rotation_angle_mod",
                        "\t\tvar rotation_angle_dist: float = min(rotation_forward_delta, rotation_backward_delta)",
                        "\t\tif abs(rotation_angle_dist) < rotation_max_delta:",
                        "\t\t\trotation_after = dest",
                        "\t\telif (rotation_angle_mod > rotation_to_mod) == ((360.0 - abs(rotation_angle_mod - rotation_to_mod)) > abs(rotation_angle_mod - rotation_to_mod)):",
                        "\t\t\trotation_after = rotation_angle_mod - rotation_max_delta",
                        "\t\telse:",
                        "\t\t\trotation_after = rotation_angle_mod + rotation_max_delta",
                        "\t\trotation_move_call = {\"call\": \"Angles.moveToward(rotation, dest, rotateSpeed * edelta)\", \"rotation\": rotation_before, \"dest\": dest, \"speed\": rotation_max_delta, \"result\": rotation_after}",
                        "\tvar last_x_before: float = float(_args[34] if _args.size() > 34 else 0.0)",
                        "\tvar last_y_before: float = float(_args[35] if _args.size() > 35 else 0.0)",
                        "\tvar last_target_position_evaluated: bool = rotation_move_evaluated",
                        "\tvar last_x_after: float = last_x_before",
                        "\tvar last_y_after: float = last_y_before",
                        "\tvar last_target_position_call: Dictionary = {}",
                        "\tif last_target_position_evaluated and target_after is Dictionary:",
                        "\t\tlast_x_after = float(target_after.get(\"x\", last_x_before))",
                        "\t\tlast_y_after = float(target_after.get(\"y\", last_y_before))",
                        "\t\tlast_target_position_call = {\"call\": \"lastX = target.x; lastY = target.y;\", \"target\": target_after, \"last_x\": last_x_after, \"last_y\": last_y_after}",
                        "\tvar strength_before: float = float(_args[36] if _args.size() > 36 else 0.0)",
                        "\tvar strength_lerp_evaluated: bool = last_target_position_evaluated",
                        "\tvar strength_lerp_progress: float = 0.1",
                        "\tvar strength_lerp_scaled_progress: float = strength_lerp_progress * time_delta if strength_lerp_evaluated else 0.0",
                        "\tvar strength_lerp_clamped_progress: float = clampf(strength_lerp_scaled_progress, 0.0, 1.0)",
                        "\tvar strength_after: float = strength_before + (1.0 - strength_before) * strength_lerp_clamped_progress if strength_lerp_evaluated else strength_before",
                        "\tvar strength_lerp_call: Dictionary = {}",
                        "\tif strength_lerp_evaluated:",
                        "\t\tstrength_lerp_call = {\"call\": \"strength = Mathf.lerpDelta(strength, 1f, 0.1f);\", \"from\": strength_before, \"to\": 1.0, \"progress\": strength_lerp_progress, \"time_delta\": time_delta, \"result\": strength_after}",
                        "\tvar inactive_strength_evaluated: bool = not activation_returned_early and not look_target_guard",
                        "\tvar inactive_strength_lerp_progress: float = 0.1",
                        "\tvar inactive_strength_lerp_scaled_progress: float = inactive_strength_lerp_progress * time_delta if inactive_strength_evaluated else 0.0",
                        "\tvar inactive_strength_lerp_clamped_progress: float = clampf(inactive_strength_lerp_scaled_progress, 0.0, 1.0)",
                        "\tvar inactive_strength_after: float = strength_before + (0.0 - strength_before) * inactive_strength_lerp_clamped_progress if inactive_strength_evaluated else strength_after",
                        "\tvar inactive_strength_lerp_call: Dictionary = {}",
                        "\tif inactive_strength_evaluated:",
                        "\t\tstrength_after = inactive_strength_after",
                        "\t\tinactive_strength_lerp_call = {\"call\": \"strength = Mathf.lerpDelta(strength, 0, 0.1f);\", \"from\": strength_before, \"to\": 0.0, \"progress\": inactive_strength_lerp_progress, \"time_delta\": time_delta, \"result\": inactive_strength_after}",
                        "\tvar shoot_cone: float = float(_args[37] if _args.size() > 37 else 0.0)",
                        "\tvar shoot_when_possible_evaluated: bool = strength_lerp_evaluated",
                        "\tvar shoot_within_angle_dist: float = 0.0",
                        "\tif shoot_when_possible_evaluated:",
                        "\t\tvar shoot_rotation_mod: float = fmod(fmod(rotation_after, 360.0) + 360.0, 360.0)",
                        "\t\tvar shoot_dest_mod: float = fmod(fmod(dest, 360.0) + 360.0, 360.0)",
                        "\t\tvar shoot_forward_delta: float = shoot_rotation_mod - shoot_dest_mod + 360.0 if (shoot_rotation_mod - shoot_dest_mod) < 0.0 else shoot_rotation_mod - shoot_dest_mod",
                        "\t\tvar shoot_backward_delta: float = shoot_dest_mod - shoot_rotation_mod + 360.0 if (shoot_dest_mod - shoot_rotation_mod) < 0.0 else shoot_dest_mod - shoot_rotation_mod",
                        "\t\tshoot_within_angle_dist = min(shoot_forward_delta, shoot_backward_delta)",
                        "\tvar shoot_within_guard: bool = shoot_when_possible_evaluated and shoot_within_angle_dist <= shoot_cone",
                        "\tvar shoot_within_call: Dictionary = {}",
                        "\tif shoot_when_possible_evaluated:",
                        "\t\tshoot_within_call = {\"call\": \"Angles.within(rotation, dest, shootCone)\", \"rotation\": rotation_after, \"dest\": dest, \"shoot_cone\": shoot_cone, \"angle_dist\": shoot_within_angle_dist, \"result\": shoot_within_guard}",
                        "\tvar damage: float = float(_args[38] if _args.size() > 38 else 0.0)",
                        "\tvar time_scale: float = float(_args[39] if _args.size() > 39 else 1.0)",
                        "\tvar rules_block_damage: float = float(_args[40] if _args.size() > 40 else 1.0)",
                        "\tvar damage_gate_evaluated: bool = shoot_within_guard",
                        "\tvar damage_gate: bool = damage_gate_evaluated and damage > 0.0",
                        "\tvar damage_amount: float = damage * eff * time_scale * rules_block_damage if damage_gate else 0.0",
                        "\tvar block_damage_call: Dictionary = {}",
                        "\tif damage_gate:",
                        "\t\tblock_damage_call = {\"call\": \"state.rules.blockDamage(team)\", \"team\": team, \"result\": rules_block_damage}",
                        "\tvar damage_continuous_pierce_call: Dictionary = {}",
                        "\tif damage_gate:",
                        "\t\tdamage_continuous_pierce_call = {\"call\": \"target.damageContinuousPierce(damage * eff * timeScale * state.rules.blockDamage(team));\", \"target\": target_after, \"amount\": damage_amount}",
                        "\tvar status: Variant = _args[41] if _args.size() > 41 else \"StatusEffects.none\"",
                        "\tvar status_duration: float = float(_args[42] if _args.size() > 42 else 300.0)",
                        "\tvar status_gate_evaluated: bool = shoot_within_guard",
                        "\tvar status_is_none: bool = status is String and status == \"StatusEffects.none\"",
                        "\tvar status_gate: bool = status_gate_evaluated and not status_is_none",
                        "\tvar status_apply_call: Dictionary = {}",
                        "\tif status_gate:",
                        "\t\tstatus_apply_call = {\"call\": \"target.apply(status, statusDuration);\", \"target\": target_after, \"status\": status, \"duration\": status_duration}",
                        "\tvar any_before_shoot: bool = any_after",
                        "\tvar any_true_evaluated: bool = shoot_within_guard",
                        "\tvar any_true_called: bool = any_true_evaluated",
                        "\tvar any_true_call: Dictionary = {}",
                        "\tif any_true_called:",
                        "\t\tany_after = true",
                        "\t\tany_true_call = {\"call\": \"any = true;\", \"value\": any_after}",
                        "\tvar force_value: float = float(_args[43]) if _args.size() > 43 else 0.3",
                        "\tvar scaled_force: float = float(_args[44]) if _args.size() > 44 else 0.0",
                        "\tvar target_x_for_impulse: float = x",
                        "\tvar target_y_for_impulse: float = y",
                        "\tif target_after is Dictionary:",
                        "\t\ttarget_x_for_impulse = float(target_after.get(\"x\", x))",
                        "\t\ttarget_y_for_impulse = float(target_after.get(\"y\", y))",
                        "\tvar impulse_vector_x: float = x - target_x_for_impulse",
                        "\tvar impulse_vector_y: float = y - target_y_for_impulse",
                        "\tvar target_dst_to_building: float = sqrt(pow(target_x_for_impulse - x, 2) + pow(target_y_for_impulse - y, 2))",
                        "\tvar impulse_limit: float = (force_value + (1.0 - target_dst_to_building / range_value) * scaled_force) * edelta",
                        "\tvar impulse_net_called: bool = any_true_called",
                        "\tif impulse_net_called:",
                        "\t\tvar impulse_len2: float = impulse_vector_x * impulse_vector_x + impulse_vector_y * impulse_vector_y",
                        "\t\tvar impulse_limit2: float = impulse_limit * impulse_limit",
                        "\t\tif impulse_len2 > impulse_limit2:",
                        "\t\t\tvar impulse_scale: float = sqrt(impulse_limit2 / impulse_len2)",
                        "\t\t\timpulse_vector_x *= impulse_scale",
                        "\t\t\timpulse_vector_y *= impulse_scale",
                        "\tvar impulse_net_call: Dictionary = {}",
                        "\tif impulse_net_called:",
                        "\t\timpulse_net_call = {\"call\": \"target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));\", \"target\": target_after, \"x\": impulse_vector_x, \"y\": impulse_vector_y, \"limit\": impulse_limit, \"target_dst_to_building\": target_dst_to_building, \"force\": force_value, \"scaled_force\": scaled_force}",
                        "\treturn {\"source_owner\": \"PortGame.source_tractor_beam_turret_build_update_tile_activation_state\", \"inner_class\": \"public class TractorBeamBuild extends BaseTurretBuild{\", \"method\": \"public void updateTile(){\", \"override_expr\": \"@Override\", \"activation_guard_expr\": \"if(activationTimer > 0){\", \"activation_decrement_expr\": \"activationTimer -= Time.delta;\", \"return_expr\": \"return;\", \"next_expr\": \"float eff = efficiency * coolantMultiplier, edelta = eff * delta();\", \"eff_expr\": \"float eff = efficiency * coolantMultiplier, edelta = eff * delta();\", \"retarget_comment_expr\": \"//retarget\", \"retarget_guard_expr\": \"if(timer(timerTarget, retargetTime)){\", \"retarget_assign_expr\": \"target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));\", \"target_check_filter_expr\": \"u -> u.checkTarget(targetAir, targetGround)\", \"coolant_comment_expr\": \"//consume coolant\", \"coolant_guard_expr\": \"if(target != null && coolant != null){\", \"max_used_expr\": \"float maxUsed = coolant.amount;\", \"current_liquid_expr\": \"Liquid liquid = liquids.current();\", \"liquids_get_expr\": \"liquids.get(liquid)\", \"max_used_time_delta_expr\": \"maxUsed * Time.delta\", \"heat_capacity_limit_expr\": \"(1f / coolantMultiplier) / liquid.heatCapacity\", \"used_expr\": \"float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));\", \"remove_next_expr\": \"liquids.remove(liquid, used);\", \"remove_expr\": \"liquids.remove(liquid, used);\", \"chance_expr\": \"Mathf.chance(0.06 * used)\", \"cool_effect_expr\": \"coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));\", \"coolant_multiplier_assign_expr\": \"coolantMultiplier = 1f + (used * liquid.heatCapacity * coolantMultiplier);\", \"any_reset_expr\": \"any = false;\", \"look_target_comment_expr\": \"//look at target\", \"look_target_guard_expr\": \"if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){\", \"sound_loop_guard_expr\": \"if(!headless){\", \"shoot_sound_loop_expr\": \"control.sound.loop(shootSound, this, shootSoundVolume);\", \"dest_expr\": \"float dest = angleTo(target);\", \"rotation_move_expr\": \"rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);\", \"last_x_expr\": \"lastX = target.x;\", \"last_y_expr\": \"lastY = target.y;\", \"strength_next_expr\": \"strength = Mathf.lerpDelta(strength, 1f, 0.1f);\", \"strength_lerp_expr\": \"strength = Mathf.lerpDelta(strength, 1f, 0.1f);\", \"inactive_strength_lerp_expr\": \"strength = Mathf.lerpDelta(strength, 0, 0.1f);\", \"shoot_when_possible_next_expr\": \"if(Angles.within(rotation, dest, shootCone)){\", \"shoot_when_possible_comment_expr\": \"//shoot when possible\", \"shoot_when_possible_guard_expr\": \"if(Angles.within(rotation, dest, shootCone)){\", \"angles_within_method\": \"public static boolean within(float a, float b, float margin){\\n        return angleDist(a, b) <= margin;\\n    }\", \"damage_next_expr\": \"if(damage > 0){\", \"damage_gate_expr\": \"if(damage > 0){\", \"damage_continuous_pierce_expr\": \"target.damageContinuousPierce(damage * eff * timeScale * state.rules.blockDamage(team));\", \"rules_block_damage_method\": \"public float blockDamage(Team team){\\n        return blockDamageMultiplier * teams.get(team).blockDamageMultiplier;\\n    }\", \"damage_continuous_pierce_method\": \"void damageContinuousPierce(float amount){\\n        damagePierce(amount * Time.delta, hitTime <= -20 + hitDuration);\\n    }\", \"status_next_expr\": \"if(status != StatusEffects.none){\", \"status_gate_expr\": \"if(status != StatusEffects.none){\", \"status_apply_expr\": \"target.apply(status, statusDuration);\", \"status_field_expr\": \"public StatusEffect status = StatusEffects.none;\", \"status_duration_field_expr\": \"public float statusDuration = 300;\", \"status_apply_method\": \"public void apply(StatusEffect effect, float duration){\\n        if(effect == StatusEffects.none || effect == null || isImmune(effect)) return; //don't apply empty or immune effects\\n    }\", \"any_next_expr\": \"any = true;\", \"any_true_expr\": \"any = true;\", \"force_expr\": \"public float force = 0.3f;\", \"scaled_force_expr\": \"public float scaledForce = 0f;\", \"impulse_next_expr\": \"target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));\", \"impulse_net_expr\": \"target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));\", \"used_next_expr\": \"float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));\", \"activation_timer\": activation_timer, \"time_delta\": time_delta, \"activation_guard\": activation_guard, \"activation_timer_after\": activation_timer_after, \"returned_early\": returned_early, \"activation_returned_early\": activation_returned_early, \"efficiency\": efficiency, \"coolant_multiplier\": coolant_multiplier, \"delta_value\": delta_value, \"eff_calculated\": eff_calculated, \"eff\": eff, \"edelta\": edelta, \"timer_target_ready\": timer_target_ready, \"existing_target\": existing_target, \"closest_enemy_result\": closest_enemy_result, \"team\": team, \"x\": x, \"y\": y, \"range_value\": range_value, \"target_air\": target_air, \"target_ground\": target_ground, \"retarget_evaluated\": retarget_evaluated, \"retarget_called\": retarget_called, \"target_after\": target_after, \"closest_enemy_call\": closest_enemy_call, \"coolant_present\": coolant_present, \"coolant_amount\": coolant_amount, \"current_liquid\": current_liquid, \"coolant_evaluated\": coolant_evaluated, \"coolant_guard\": coolant_guard, \"max_used\": max_used, \"liquid\": liquid, \"liquid_amount\": liquid_amount, \"liquid_heat_capacity\": liquid_heat_capacity, \"max_used_time_delta\": max_used_time_delta, \"heat_capacity_limit\": heat_capacity_limit, \"nonnegative_heat_capacity_limit\": nonnegative_heat_capacity_limit, \"used\": used, \"remove_called\": remove_called, \"remove_call\": remove_call, \"chance_result\": chance_result, \"size\": size, \"source_tilesize\": source_tilesize, \"range_x\": range_x, \"range_y\": range_y, \"chance_threshold\": chance_threshold, \"particle_range\": particle_range, \"chance_called\": chance_called, \"cool_effect_called\": cool_effect_called, \"cool_effect_call\": cool_effect_call, \"coolant_multiplier_assign_called\": coolant_multiplier_assign_called, \"coolant_multiplier_after\": coolant_multiplier_after, \"coolant_multiplier_assign_call\": coolant_multiplier_assign_call, \"any_before\": any_before, \"any_reset_evaluated\": any_reset_evaluated, \"any_reset_called\": any_reset_called, \"any_after\": any_after, \"any_reset_call\": any_reset_call, \"target_within_result\": target_within_result, \"target_team\": target_team, \"target_check_result\": target_check_result, \"target_hit_size\": target_hit_size, \"look_target_evaluated\": look_target_evaluated, \"target_exists_for_look\": target_exists_for_look, \"target_within_radius\": target_within_radius, \"target_within_evaluated\": target_within_evaluated, \"target_within_call\": target_within_call, \"target_team_evaluated\": target_team_evaluated, \"target_enemy\": target_enemy, \"target_check_evaluated\": target_check_evaluated, \"target_check_call\": target_check_call, \"efficiency_gate_evaluated\": efficiency_gate_evaluated, \"look_target_guard\": look_target_guard, \"headless\": headless, \"shoot_sound\": shoot_sound, \"shoot_sound_volume\": shoot_sound_volume, \"sound_loop_evaluated\": sound_loop_evaluated, \"sound_loop_called\": sound_loop_called, \"shoot_sound_loop_call\": shoot_sound_loop_call, \"angle_to_target_evaluated\": angle_to_target_evaluated, \"dest\": dest, \"angle_to_target_call\": angle_to_target_call, \"rotation_before\": rotation_before, \"rotate_speed\": rotate_speed, \"rotation_move_evaluated\": rotation_move_evaluated, \"rotation_max_delta\": rotation_max_delta, \"rotation_after\": rotation_after, \"rotation_move_call\": rotation_move_call, \"last_x_before\": last_x_before, \"last_y_before\": last_y_before, \"last_target_position_evaluated\": last_target_position_evaluated, \"last_x_after\": last_x_after, \"last_y_after\": last_y_after, \"last_target_position_call\": last_target_position_call, \"strength_before\": strength_before, \"strength_lerp_evaluated\": strength_lerp_evaluated, \"strength_lerp_progress\": strength_lerp_progress, \"strength_lerp_scaled_progress\": strength_lerp_scaled_progress, \"strength_lerp_clamped_progress\": strength_lerp_clamped_progress, \"strength_after\": strength_after, \"strength_lerp_call\": strength_lerp_call, \"inactive_strength_evaluated\": inactive_strength_evaluated, \"inactive_strength_lerp_progress\": inactive_strength_lerp_progress, \"inactive_strength_lerp_scaled_progress\": inactive_strength_lerp_scaled_progress, \"inactive_strength_lerp_clamped_progress\": inactive_strength_lerp_clamped_progress, \"inactive_strength_after\": inactive_strength_after, \"inactive_strength_lerp_call\": inactive_strength_lerp_call, \"shoot_cone\": shoot_cone, \"shoot_when_possible_evaluated\": shoot_when_possible_evaluated, \"shoot_within_angle_dist\": shoot_within_angle_dist, \"shoot_within_guard\": shoot_within_guard, \"shoot_within_call\": shoot_within_call, \"damage\": damage, \"time_scale\": time_scale, \"rules_block_damage\": rules_block_damage, \"damage_gate_evaluated\": damage_gate_evaluated, \"damage_gate\": damage_gate, \"damage_amount\": damage_amount, \"block_damage_call\": block_damage_call, \"damage_continuous_pierce_call\": damage_continuous_pierce_call, \"status\": status, \"status_duration\": status_duration, \"status_gate_evaluated\": status_gate_evaluated, \"status_gate\": status_gate, \"status_apply_call\": status_apply_call, \"any_before_shoot\": any_before_shoot, \"any_true_evaluated\": any_true_evaluated, \"any_true_called\": any_true_called, \"any_true_call\": any_true_call, \"force_value\": force_value, \"scaled_force\": scaled_force, \"target_x_for_impulse\": target_x_for_impulse, \"target_y_for_impulse\": target_y_for_impulse, \"target_dst_to_building\": target_dst_to_building, \"impulse_limit\": impulse_limit, \"impulse_vector_x\": impulse_vector_x, \"impulse_vector_y\": impulse_vector_y, \"impulse_net_called\": impulse_net_called, \"impulse_net_call\": impulse_net_call}",
                    ])
                elif method.get("name") == "shouldConsume":
                    lines.extend([
                        "",
                        f"func java_inner_class_TractorBeamBuild_method_shouldConsume_{index}(_args: Array = []) -> Variant:",
                        "\tvar super_should_consume: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar target: Variant = _args[1] if _args.size() > 1 else null",
                        "\tvar target_present: bool = target != null",
                        "\tvar should_consume: bool = super_should_consume and target_present",
                        "\treturn {\"source_owner\": \"PortGame.source_tractor_beam_turret_build_should_consume_state\", \"inner_class\": \"public class TractorBeamBuild extends BaseTurretBuild{\", \"field\": \"public @Nullable Unit target;\", \"method\": \"public boolean shouldConsume(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return super.shouldConsume() && target != null;\", \"super_should_consume\": super_should_consume, \"target\": target, \"target_present\": target_present, \"should_consume\": should_consume}",
                    ])
                elif method.get("name") == "estimateDps":
                    lines.extend([
                        "",
                        f"func java_inner_class_TractorBeamBuild_method_estimateDps_{index}(_args: Array = []) -> Variant:",
                        "\tvar any_state: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar damage: float = float(_args[1] if _args.size() > 1 else 0.0)",
                        "\tvar efficiency: float = float(_args[2] if _args.size() > 2 else 0.0)",
                        "\tvar coolant_multiplier: float = float(_args[3] if _args.size() > 3 else 1.0)",
                        "\tvar zero_guard: bool = (not any_state) or damage <= 0.0",
                        "\tvar estimate_dps: float = 0.0 if zero_guard else damage * 60.0 * efficiency * coolant_multiplier",
                        "\treturn {\"source_owner\": \"PortGame.source_tractor_beam_turret_build_estimate_dps_state\", \"inner_class\": \"public class TractorBeamBuild extends BaseTurretBuild{\", \"method\": \"public float estimateDps(){\", \"override_expr\": \"@Override\", \"zero_guard_expr\": \"if(!any || damage <= 0) return 0f;\", \"return_expr\": \"return damage * 60f * efficiency * coolantMultiplier;\", \"any_state\": any_state, \"damage\": damage, \"efficiency\": efficiency, \"coolant_multiplier\": coolant_multiplier, \"zero_guard\": zero_guard, \"estimate_dps\": estimate_dps}",
                    ])
                elif method.get("name") == "draw":
                    lines.extend([
                        "",
                        f"func java_inner_class_TractorBeamBuild_method_draw_{index}(_args: Array = []) -> Variant:",
                        "\tvar base_region: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar region: Variant = _args[1] if _args.size() > 1 else null",
                        "\tvar x: float = float(_args[2] if _args.size() > 2 else 0.0)",
                        "\tvar y: float = float(_args[3] if _args.size() > 3 else 0.0)",
                        "\tvar rotation_value: float = float(_args[4] if _args.size() > 4 else 0.0)",
                        "\tvar size: float = float(_args[5] if _args.size() > 5 else 0.0)",
                        "\tvar any_state: bool = bool(_args[6] if _args.size() > 6 else false)",
                        "\tvar is_payload: bool = bool(_args[7] if _args.size() > 7 else false)",
                        "\tvar last_x: float = float(_args[8] if _args.size() > 8 else 0.0)",
                        "\tvar last_y: float = float(_args[9] if _args.size() > 9 else 0.0)",
                        "\tvar laser_color: Variant = _args[10] if _args.size() > 10 else null",
                        "\tvar mathf_absin_4_0_6: float = float(_args[11] if _args.size() > 11 else 0.0)",
                        "\tvar laser: Variant = _args[12] if _args.size() > 12 else null",
                        "\tvar laser_start: Variant = _args[13] if _args.size() > 13 else null",
                        "\tvar laser_end: Variant = _args[14] if _args.size() > 14 else null",
                        "\tvar shoot_length: float = float(_args[15] if _args.size() > 15 else 0.0)",
                        "\tvar strength: float = float(_args[16] if _args.size() > 16 else 0.0)",
                        "\tvar efficiency: float = float(_args[17] if _args.size() > 17 else 0.0)",
                        "\tvar laser_width: float = float(_args[18] if _args.size() > 18 else 0.0)",
                        "\tvar draw_rotation: float = rotation_value - 90.0",
                        "\tvar base_rect_call: Dictionary = {\"call\": \"Draw.rect(baseRegion, x, y);\", \"region\": base_region, \"x\": x, \"y\": y}",
                        "\tvar shadow_call: Dictionary = {\"call\": \"Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);\", \"region\": region, \"x\": x - size / 2.0, \"y\": y - size / 2.0, \"rotation\": draw_rotation}",
                        "\tvar region_rect_call: Dictionary = {\"call\": \"Draw.rect(region, x, y, rotation - 90);\", \"region\": region, \"x\": x, \"y\": y, \"rotation\": draw_rotation}",
                        "\tvar laser_guard: bool = any_state and not is_payload",
                        "\tvar angle_to_last: float = rad_to_deg(atan2(last_y - y, last_x - x))",
                        "\tvar laser_start_x: float = x + cos(deg_to_rad(angle_to_last)) * shoot_length",
                        "\tvar laser_start_y: float = y + sin(deg_to_rad(angle_to_last)) * shoot_length",
                        "\tvar laser_width_value: float = strength * efficiency * laser_width",
                        "\tvar draw_z_call: Dictionary = {}",
                        "\tvar mixcol_call: Dictionary = {}",
                        "\tvar laser_call: Dictionary = {}",
                        "\tvar mixcol_reset_called: bool = false",
                        "\tif laser_guard:",
                        "\t\tdraw_z_call = {\"call\": \"Draw.z(Layer.bullet);\", \"layer\": \"Layer.bullet\"}",
                        "\t\tmixcol_call = {\"call\": \"Draw.mixcol(laserColor, Mathf.absin(4f, 0.6f));\", \"color\": laser_color, \"alpha\": mathf_absin_4_0_6}",
                        "\t\tlaser_call = {\"call\": \"Drawf.laser(laser, laserStart, laserEnd, x + Angles.trnsx(ang, shootLength), y + Angles.trnsy(ang, shootLength), lastX, lastY, strength * efficiency * laserWidth);\", \"laser\": laser, \"laser_start\": laser_start, \"laser_end\": laser_end, \"start_x\": laser_start_x, \"start_y\": laser_start_y, \"end_x\": last_x, \"end_y\": last_y, \"width\": laser_width_value}",
                        "\t\tmixcol_reset_called = true",
                        "\treturn {\"source_owner\": \"PortGame.source_tractor_beam_turret_build_draw_state\", \"inner_class\": \"public class TractorBeamBuild extends BaseTurretBuild{\", \"method\": \"public void draw(){\", \"override_expr\": \"@Override\", \"base_rect_expr\": \"Draw.rect(baseRegion, x, y);\", \"shadow_expr\": \"Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);\", \"region_rect_expr\": \"Draw.rect(region, x, y, rotation - 90);\", \"laser_guard_expr\": \"if(any && !isPayload()){\", \"draw_z_expr\": \"Draw.z(Layer.bullet);\", \"angle_expr\": \"float ang = angleTo(lastX, lastY);\", \"mixcol_expr\": \"Draw.mixcol(laserColor, Mathf.absin(4f, 0.6f));\", \"laser_expr\": \"Drawf.laser(laser, laserStart, laserEnd, x + Angles.trnsx(ang, shootLength), y + Angles.trnsy(ang, shootLength), lastX, lastY, strength * efficiency * laserWidth);\", \"mixcol_reset_expr\": \"Draw.mixcol();\", \"base_region\": base_region, \"region\": region, \"x\": x, \"y\": y, \"rotation\": rotation_value, \"size\": size, \"any_state\": any_state, \"is_payload\": is_payload, \"last_x\": last_x, \"last_y\": last_y, \"laser_color\": laser_color, \"mathf_absin_4_0_6\": mathf_absin_4_0_6, \"laser\": laser, \"laser_start\": laser_start, \"laser_end\": laser_end, \"shoot_length\": shoot_length, \"strength\": strength, \"efficiency\": efficiency, \"laser_width\": laser_width, \"draw_rotation\": draw_rotation, \"base_rect_call\": base_rect_call, \"shadow_call\": shadow_call, \"region_rect_call\": region_rect_call, \"laser_guard\": laser_guard, \"angle_to_last\": angle_to_last, \"laser_start_x\": laser_start_x, \"laser_start_y\": laser_start_y, \"laser_width_value\": laser_width_value, \"draw_z_call\": draw_z_call, \"mixcol_call\": mixcol_call, \"laser_call\": laser_call, \"mixcol_reset_called\": mixcol_reset_called}",
                    ])
                elif method.get("name") == "write":
                    lines.extend([
                        "",
                        f"func java_inner_class_TractorBeamBuild_method_write_{index}(_args: Array = []) -> Variant:",
                        "\tvar rotation: float = float(_args[0] if _args.size() > 0 else 0.0)",
                        "\tvar write_f_call: Dictionary = {\"call\": \"write.f(rotation);\", \"value\": rotation}",
                        "\treturn {\"source_owner\": \"PortGame.source_tractor_beam_turret_build_write_state\", \"inner_class\": \"public class TractorBeamBuild extends BaseTurretBuild{\", \"method\": \"public void write(Writes write){\", \"override_expr\": \"@Override\", \"super_write_expr\": \"super.write(write);\", \"write_rotation_expr\": \"write.f(rotation);\", \"rotation\": rotation, \"super_write_called\": true, \"write_f_call\": write_f_call}",
                    ])
                elif method.get("name") == "read":
                    lines.extend([
                        "",
                        f"func java_inner_class_TractorBeamBuild_method_read_{index}(_args: Array = []) -> Variant:",
                        "\tvar read_f_value: float = float(_args[0] if _args.size() > 0 else 0.0)",
                        "\tvar revision_value: int = int(_args[1] if _args.size() > 1 else 0)",
                        "\tvar super_read_call: Dictionary = {\"call\": \"super.read(read, revision);\", \"revision\": revision_value}",
                        "\tvar read_f_call: Dictionary = {\"call\": \"read.f();\", \"value\": read_f_value}",
                        "\tvar rotation_after: float = read_f_value",
                        "\treturn {\"source_owner\": \"PortGame.source_tractor_beam_turret_build_read_state\", \"inner_class\": \"public class TractorBeamBuild extends BaseTurretBuild{\", \"method\": \"public void read(Reads read, byte revision){\", \"override_expr\": \"@Override\", \"super_read_expr\": \"super.read(read, revision);\", \"read_rotation_expr\": \"rotation = read.f();\", \"read_f_value\": read_f_value, \"revision_value\": revision_value, \"super_read_call\": super_read_call, \"read_f_call\": read_f_call, \"rotation_after\": rotation_after}",
                    ])
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/PowerTurret.java"
        and type_entry.get("name") == "PowerTurret"
    ):
        for inner_class in type_entry.get("inner_classes", []):
            if inner_class.get("name") != "PowerTurretBuild":
                continue
            for index, method in enumerate(inner_class.get("methods", [])):
                if method.get("name") == "getAmmoFraction":
                    lines.extend([
                        "",
                        f"func java_inner_class_PowerTurretBuild_method_getAmmoFraction_{index}(_args: Array = []) -> Variant:",
                        "\tvar power_null: bool = bool(_args[0] if _args.size() > 0 else true)",
                        "\tvar power_status: float = float(_args[1] if _args.size() > 1 else 0.0)",
                        "\tvar ammo_fraction: float = 0.0 if power_null else power_status",
                        "\treturn {\"source_owner\": \"PortGame.source_power_turret_build_get_ammo_fraction_state\", \"inner_class\": \"public class PowerTurretBuild extends TurretBuild{\", \"method\": \"public float getAmmoFraction(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return power == null ? 0f : power.status;\", \"power_null\": power_null, \"power_status\": power_status, \"ammo_fraction\": ammo_fraction}",
                    ])
                elif method.get("name") == "sense":
                    lines.extend([
                        "",
                        f"func java_inner_class_PowerTurretBuild_method_sense_{index}(_args: Array = []) -> Variant:",
                        "\tvar sensor: String = str(_args[0] if _args.size() > 0 else \"\")",
                        "\tvar power_null: bool = bool(_args[1] if _args.size() > 1 else true)",
                        "\tvar power_status: float = float(_args[2] if _args.size() > 2 else 0.0)",
                        "\tvar super_sense_value: float = float(_args[3] if _args.size() > 3 else 0.0)",
                        "\tvar sense_value: float = 0.0",
                        "\tif sensor == \"ammo\":",
                        "\t\tsense_value = 0.0 if power_null else power_status",
                        "\telif sensor == \"ammoCapacity\":",
                        "\t\tsense_value = 1.0",
                        "\telse:",
                        "\t\tsense_value = super_sense_value",
                        "\treturn {\"source_owner\": \"PortGame.source_power_turret_build_sense_state\", \"inner_class\": \"public class PowerTurretBuild extends TurretBuild{\", \"method\": \"public double sense(LAccess sensor){\", \"override_expr\": \"@Override\", \"switch_return\": \"return switch(sensor){\", \"ammo_case\": \"case ammo -> power == null ? 0f : power.status;\", \"ammo_capacity_case\": \"case ammoCapacity -> 1;\", \"default_case\": \"default -> super.sense(sensor);\", \"sensor\": sensor, \"power_null\": power_null, \"power_status\": power_status, \"super_sense_value\": super_sense_value, \"sense_value\": sense_value}",
                    ])
                elif method.get("name") == "useAmmo":
                    lines.extend([
                        "",
                        f"func java_inner_class_PowerTurretBuild_method_useAmmo_{index}(_args: Array = []) -> Variant:",
                        "\tvar shoot_type: Variant = _args[0] if _args.size() > 0 else null",
                        "\treturn {\"source_owner\": \"PortGame.source_power_turret_build_use_ammo_state\", \"inner_class\": \"public class PowerTurretBuild extends TurretBuild{\", \"method\": \"public BulletType useAmmo(){\", \"override_expr\": \"@Override\", \"comment\": \"//nothing used directly\", \"return_expr\": \"return shootType;\", \"shoot_type\": shoot_type}",
                    ])
                elif method.get("name") == "hasAmmo":
                    lines.extend([
                        "",
                        f"func java_inner_class_PowerTurretBuild_method_hasAmmo_{index}(_args: Array = []) -> Variant:",
                        "\treturn {\"source_owner\": \"PortGame.source_power_turret_build_has_ammo_state\", \"inner_class\": \"public class PowerTurretBuild extends TurretBuild{\", \"method\": \"public boolean hasAmmo(){\", \"override_expr\": \"@Override\", \"comment\": \"//you can always rotate, but never shoot if there's no power\", \"return_expr\": \"return true;\", \"has_ammo\": true}",
                    ])
                elif method.get("name") == "peekAmmo":
                    lines.extend([
                        "",
                        f"func java_inner_class_PowerTurretBuild_method_peekAmmo_{index}(_args: Array = []) -> Variant:",
                        "\tvar shoot_type: Variant = _args[0] if _args.size() > 0 else null",
                        "\treturn {\"source_owner\": \"PortGame.source_power_turret_build_peek_ammo_state\", \"inner_class\": \"public class PowerTurretBuild extends TurretBuild{\", \"method\": \"public BulletType peekAmmo(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return shootType;\", \"shoot_type\": shoot_type}",
                    ])
    if (
        java_file.get("path") == "mindustry/world/blocks/defense/turrets/ItemTurret.java"
        and type_entry.get("name") == "ItemTurret"
    ):
        for inner_class in type_entry.get("inner_classes", []):
            if inner_class.get("name") != "ItemTurretBuild":
                continue
            for index, method in enumerate(inner_class.get("methods", [])):
                if method.get("name") == "onProximityAdded":
                    lines.extend([
                        "",
                        f"func java_inner_class_ItemTurretBuild_method_onProximityAdded_{index}(_args: Array = []) -> Variant:",
                        "\tvar has_ammo: bool = bool(_args[0] if _args.size() > 0 else false)",
                        "\tvar cheating: bool = bool(_args[1] if _args.size() > 1 else false)",
                        "\tvar ammo_types_size: int = int(_args[2] if _args.size() > 2 else 0)",
                        "\tvar first_ammo_item: Variant = _args[3] if _args.size() > 3 else null",
                        "\tvar should_handle_first_ammo: bool = (not has_ammo) and cheating and ammo_types_size > 0",
                        "\tvar handle_item_call: Dictionary = {}",
                        "\tif should_handle_first_ammo:",
                        "\t\thandle_item_call = {\"call\": \"handleItem(this, ammoTypes.keys().next());\", \"source\": \"this\", \"item\": first_ammo_item}",
                        "\treturn {\"source_owner\": \"PortGame.source_item_turret_build_on_proximity_added_state\", \"inner_class\": \"public class ItemTurretBuild extends TurretBuild{\", \"method\": \"public void onProximityAdded(){\", \"override_expr\": \"@Override\", \"super_on_proximity_added_expr\": \"super.onProximityAdded();\", \"comment\": \"//add first ammo item to cheaty blocks so they can shoot properly\", \"guard_expr\": \"if(!hasAmmo() && cheating() && ammoTypes.size > 0){\", \"handle_item_expr\": \"handleItem(this, ammoTypes.keys().next());\", \"has_ammo\": has_ammo, \"cheating\": cheating, \"ammo_types_size\": ammo_types_size, \"first_ammo_item\": first_ammo_item, \"should_handle_first_ammo\": should_handle_first_ammo, \"handle_item_call\": handle_item_call, \"super_on_proximity_added_called\": true}",
                    ])
                elif method.get("name") == "senseObject":
                    lines.extend([
                        "",
                        f"func java_inner_class_ItemTurretBuild_method_senseObject_{index}(_args: Array = []) -> Variant:",
                        "\tvar sensor: String = str(_args[0] if _args.size() > 0 else \"\")",
                        "\tvar ammo_size: int = int(_args[1] if _args.size() > 1 else 0)",
                        "\tvar peek_item: Variant = _args[2] if _args.size() > 2 else null",
                        "\tvar super_sense_object_value: Variant = _args[3] if _args.size() > 3 else null",
                        "\tvar sense_object_value: Variant = null",
                        "\tif sensor == \"currentAmmoType\":",
                        "\t\tsense_object_value = peek_item if ammo_size > 0 else null",
                        "\telse:",
                        "\t\tsense_object_value = super_sense_object_value",
                        "\treturn {\"source_owner\": \"PortGame.source_item_turret_build_sense_object_state\", \"inner_class\": \"public class ItemTurretBuild extends TurretBuild{\", \"method\": \"public Object senseObject(LAccess sensor){\", \"override_expr\": \"@Override\", \"switch_return_expr\": \"return switch(sensor){\", \"current_ammo_type_case\": \"case currentAmmoType -> ammo.size > 0 ? ((ItemEntry)ammo.peek()).item : null;\", \"default_case\": \"default -> super.senseObject(sensor);\", \"sensor\": sensor, \"ammo_size\": ammo_size, \"peek_item\": peek_item, \"super_sense_object_value\": super_sense_object_value, \"sense_object_value\": sense_object_value}",
                    ])
                elif method.get("name") == "getAmmoContent":
                    lines.extend([
                        "",
                        f"func java_inner_class_ItemTurretBuild_method_getAmmoContent_{index}(_args: Array = []) -> Variant:",
                        "\tvar ammo_size: int = int(_args[0] if _args.size() > 0 else 0)",
                        "\tvar peek_item: Variant = _args[1] if _args.size() > 1 else null",
                        "\tvar ammo_content: Variant = peek_item if ammo_size > 0 else null",
                        "\treturn {\"source_owner\": \"PortGame.source_item_turret_build_get_ammo_content_state\", \"inner_class\": \"public class ItemTurretBuild extends TurretBuild{\", \"method\": \"public UnlockableContent getAmmoContent(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return ammo.size > 0 ? ((ItemEntry)ammo.peek()).item : null;\", \"ammo_size\": ammo_size, \"peek_item\": peek_item, \"ammo_content\": ammo_content}",
                    ])
                elif method.get("name") == "getAmmoFraction":
                    lines.extend([
                        "",
                        f"func java_inner_class_ItemTurretBuild_method_getAmmoFraction_{index}(_args: Array = []) -> Variant:",
                        "\tvar total_ammo: float = float(_args[0] if _args.size() > 0 else 0.0)",
                        "\tvar max_ammo: float = float(_args[1] if _args.size() > 1 else 1.0)",
                        "\tvar ammo_fraction: float = total_ammo / max_ammo",
                        "\treturn {\"source_owner\": \"PortGame.source_item_turret_build_get_ammo_fraction_state\", \"inner_class\": \"public class ItemTurretBuild extends TurretBuild{\", \"method\": \"public float getAmmoFraction(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return (float)totalAmmo / maxAmmo;\", \"total_ammo\": total_ammo, \"max_ammo\": max_ammo, \"ammo_fraction\": ammo_fraction}",
                    ])
                elif method.get("name") == "acceptStack":
                    lines.extend([
                        "",
                        f"func java_inner_class_ItemTurretBuild_method_acceptStack_{index}(_args: Array = []) -> Variant:",
                        "\tvar item: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar amount: int = int(_args[1] if _args.size() > 1 else 0)",
                        "\tvar max_ammo: float = float(_args[2] if _args.size() > 2 else 0.0)",
                        "\tvar total_ammo: float = float(_args[3] if _args.size() > 3 else 0.0)",
                        "\tvar ammo_multiplier: float = float(_args[4] if _args.size() > 4 else 1.0)",
                        "\tvar ammo_type_null: bool = bool(_args[5] if _args.size() > 5 else false)",
                        "\tvar accept_stack: int = 0 if ammo_type_null else min(int((max_ammo - total_ammo) / ammo_multiplier), amount)",
                        "\treturn {\"source_owner\": \"PortGame.source_item_turret_build_accept_stack_state\", \"inner_class\": \"public class ItemTurretBuild extends TurretBuild{\", \"method\": \"public int acceptStack(Item item, int amount, Teamc source){\", \"override_expr\": \"@Override\", \"type_lookup\": \"BulletType type = ammoTypes.get(item);\", \"null_guard\": \"if(type == null) return 0;\", \"return_expr\": \"return Math.min((int)((maxAmmo - totalAmmo) / ammoTypes.get(item).ammoMultiplier), amount);\", \"item\": item, \"amount\": amount, \"max_ammo\": max_ammo, \"total_ammo\": total_ammo, \"ammo_multiplier\": ammo_multiplier, \"ammo_type_null\": ammo_type_null, \"accept_stack\": accept_stack}",
                    ])
                elif method.get("name") == "handleStack":
                    lines.extend([
                        "",
                        f"func java_inner_class_ItemTurretBuild_method_handleStack_{index}(_args: Array = []) -> Variant:",
                        "\tvar item: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar amount: int = int(_args[1] if _args.size() > 1 else 0)",
                        "\tvar handle_item_calls: Array = []",
                        "\tfor _i in range(amount):",
                        "\t\thandle_item_calls.append({\"call\": \"handleItem(null, item);\", \"source\": null, \"item\": item})",
                        "\treturn {\"source_owner\": \"PortGame.source_item_turret_build_handle_stack_state\", \"inner_class\": \"public class ItemTurretBuild extends TurretBuild{\", \"method\": \"public void handleStack(Item item, int amount, Teamc source){\", \"override_expr\": \"@Override\", \"loop_expr\": \"for(int i = 0; i < amount; i++){\", \"handle_item_expr\": \"handleItem(null, item);\", \"item\": item, \"amount\": amount, \"handle_item_calls\": handle_item_calls, \"handle_item_call_count\": handle_item_calls.size()}",
                    ])
                elif method.get("name") == "removeStack":
                    lines.extend([
                        "",
                        f"func java_inner_class_ItemTurretBuild_method_removeStack_{index}(_args: Array = []) -> Variant:",
                        "\tvar item: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar amount: int = int(_args[1] if _args.size() > 1 else 0)",
                        "\tvar removed_stack: int = 0",
                        "\treturn {\"source_owner\": \"PortGame.source_item_turret_build_remove_stack_state\", \"inner_class\": \"public class ItemTurretBuild extends TurretBuild{\", \"comment\": \"//currently can't remove items from turrets.\", \"method\": \"public int removeStack(Item item, int amount){\", \"override_expr\": \"@Override\", \"return_expr\": \"return 0;\", \"item\": item, \"amount\": amount, \"removed_stack\": removed_stack}",
                    ])
                elif method.get("name") == "handleItem":
                    lines.extend([
                        "",
                        f"func java_inner_class_ItemTurretBuild_method_handleItem_{index}(_args: Array = []) -> Variant:",
                        "\tvar item: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar item_is_pyratite: bool = bool(_args[1] if _args.size() > 1 else false)",
                        "\tvar total_ammo: int = int(_args[2] if _args.size() > 2 else 0)",
                        "\tvar ammo_multiplier: float = float(_args[3] if _args.size() > 3 else 0.0)",
                        "\tvar ammo_type_null: bool = bool(_args[4] if _args.size() > 4 else false)",
                        "\tvar ammo_entries: Array = _args[5] if _args.size() > 5 and _args[5] is Array else []",
                        "\tvar ammo_entries_after: Array = ammo_entries.duplicate(true)",
                        "\tvar flame_ammo_event_fired: bool = item_is_pyratite",
                        "\tvar resupply_turret_event_fired: bool = total_ammo == 0",
                        "\tvar total_ammo_after: int = total_ammo",
                        "\tvar type_null_returned: bool = ammo_type_null",
                        "\tvar entry_found: bool = false",
                        "\tvar entry_added: bool = false",
                        "\tvar swapped: bool = false",
                        "\tif not ammo_type_null:",
                        "\t\ttotal_ammo_after = int(total_ammo + ammo_multiplier)",
                        "\t\tfor i in range(ammo_entries_after.size()):",
                        "\t\t\tvar entry_copy: Dictionary = ammo_entries_after[i] if ammo_entries_after[i] is Dictionary else {}",
                        "\t\t\tif entry_copy.get(\"item\", null) == item:",
                        "\t\t\t\tentry_copy[\"amount\"] = int(entry_copy.get(\"amount\", 0)) + int(ammo_multiplier)",
                        "\t\t\t\tammo_entries_after[i] = entry_copy",
                        "\t\t\t\tvar last_index: int = ammo_entries_after.size() - 1",
                        "\t\t\t\tvar last_entry: Variant = ammo_entries_after[last_index]",
                        "\t\t\t\tammo_entries_after[last_index] = ammo_entries_after[i]",
                        "\t\t\t\tammo_entries_after[i] = last_entry",
                        "\t\t\t\tentry_found = true",
                        "\t\t\t\tswapped = true",
                        "\t\t\t\tbreak",
                        "\t\tif not entry_found:",
                        "\t\t\tammo_entries_after.append({\"item\": item, \"amount\": int(ammo_multiplier)})",
                        "\t\t\tentry_added = true",
                        "\treturn {\"source_owner\": \"PortGame.source_item_turret_build_handle_item_state\", \"inner_class\": \"public class ItemTurretBuild extends TurretBuild{\", \"method\": \"public void handleItem(Building source, Item item){\", \"override_expr\": \"@Override\", \"todo_comment\": \"//TODO instead of all this \\\"entry\\\" crap, turrets could just accept only one type of ammo at a time - simpler for both users and the code\", \"pyratite_guard\": \"if(item == Items.pyratite){\", \"flame_event_expr\": \"Events.fire(Trigger.flameAmmo);\", \"resupply_guard\": \"if(totalAmmo == 0){\", \"resupply_event_expr\": \"Events.fire(Trigger.resupplyTurret);\", \"type_lookup\": \"BulletType type = ammoTypes.get(item);\", \"type_null_guard\": \"if(type == null) return;\", \"total_ammo_update_expr\": \"totalAmmo += type.ammoMultiplier;\", \"loop_expr\": \"for(int i = 0; i < ammo.size; i++){\", \"entry_cast\": \"ItemEntry entry = (ItemEntry)ammo.get(i);\", \"found_guard\": \"if(entry.item == item){\", \"entry_update_expr\": \"entry.amount += type.ammoMultiplier;\", \"swap_expr\": \"ammo.swap(i, ammo.size - 1);\", \"add_expr\": \"ammo.add(new ItemEntry(item, (int)type.ammoMultiplier));\", \"item\": item, \"item_is_pyratite\": item_is_pyratite, \"total_ammo\": total_ammo, \"ammo_multiplier\": ammo_multiplier, \"ammo_type_null\": ammo_type_null, \"flame_ammo_event_fired\": flame_ammo_event_fired, \"resupply_turret_event_fired\": resupply_turret_event_fired, \"type_null_returned\": type_null_returned, \"total_ammo_after\": total_ammo_after, \"ammo_entries_after\": ammo_entries_after, \"entry_found\": entry_found, \"entry_added\": entry_added, \"swapped\": swapped}",
                    ])
                elif method.get("name") == "acceptItem":
                    lines.extend([
                        "",
                        f"func java_inner_class_ItemTurretBuild_method_acceptItem_{index}(_args: Array = []) -> Variant:",
                        "\tvar item: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar total_ammo: int = int(_args[1] if _args.size() > 1 else 0)",
                        "\tvar max_ammo: float = float(_args[2] if _args.size() > 2 else 0.0)",
                        "\tvar ammo_multiplier: float = float(_args[3] if _args.size() > 3 else 0.0)",
                        "\tvar ammo_type_null: bool = bool(_args[4] if _args.size() > 4 else false)",
                        "\tvar accept_item: bool = not ammo_type_null and total_ammo + ammo_multiplier <= max_ammo",
                        "\treturn {\"source_owner\": \"PortGame.source_item_turret_build_accept_item_state\", \"inner_class\": \"public class ItemTurretBuild extends TurretBuild{\", \"method\": \"public boolean acceptItem(Building source, Item item){\", \"override_expr\": \"@Override\", \"return_expr\": \"return ammoTypes.get(item) != null && totalAmmo + ammoTypes.get(item).ammoMultiplier <= maxAmmo;\", \"item\": item, \"total_ammo\": total_ammo, \"max_ammo\": max_ammo, \"ammo_multiplier\": ammo_multiplier, \"ammo_type_null\": ammo_type_null, \"accept_item\": accept_item}",
                    ])
                elif method.get("name") == "version":
                    lines.extend([
                        "",
                        f"func java_inner_class_ItemTurretBuild_method_version_{index}(_args: Array = []) -> Variant:",
                        "\tvar version_value: int = 2",
                        "\treturn {\"source_owner\": \"PortGame.source_item_turret_build_version_state\", \"inner_class\": \"public class ItemTurretBuild extends TurretBuild{\", \"method\": \"public byte version(){\", \"override_expr\": \"@Override\", \"return_expr\": \"return 2;\", \"version\": version_value}",
                    ])
                elif method.get("name") == "write":
                    lines.extend([
                        "",
                        f"func java_inner_class_ItemTurretBuild_method_write_{index}(_args: Array = []) -> Variant:",
                        "\tvar ammo_entries: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []",
                        "\tvar write_calls: Array = []",
                        "\tvar entry_writes: Array = []",
                        "\twrite_calls.append({\"call\": \"super.write(write);\"})",
                        "\twrite_calls.append({\"call\": \"write.b(ammo.size);\", \"value\": ammo_entries.size()})",
                        "\tfor entry in ammo_entries:",
                        "\t\tvar entry_copy: Dictionary = entry.duplicate(true) if entry is Dictionary else {}",
                        "\t\tentry_writes.append({\"item_id\": int(entry_copy.get(\"item_id\", 0)), \"amount\": int(entry_copy.get(\"amount\", 0))})",
                        "\t\twrite_calls.append({\"call\": \"write.s(i.item.id);\", \"value\": int(entry_copy.get(\"item_id\", 0))})",
                        "\t\twrite_calls.append({\"call\": \"write.s(i.amount);\", \"value\": int(entry_copy.get(\"amount\", 0))})",
                        "\treturn {\"source_owner\": \"PortGame.source_item_turret_build_write_state\", \"inner_class\": \"public class ItemTurretBuild extends TurretBuild{\", \"method\": \"public void write(Writes write){\", \"override_expr\": \"@Override\", \"super_write_expr\": \"super.write(write);\", \"write_size_expr\": \"write.b(ammo.size);\", \"loop_expr\": \"for(AmmoEntry entry : ammo){\", \"entry_cast\": \"ItemEntry i = (ItemEntry)entry;\", \"write_item_id_expr\": \"write.s(i.item.id);\", \"write_amount_expr\": \"write.s(i.amount);\", \"ammo_size\": ammo_entries.size(), \"entry_writes\": entry_writes, \"write_calls\": write_calls}",
                    ])
                elif method.get("name") == "read":
                    lines.extend([
                        "",
                        f"func java_inner_class_ItemTurretBuild_method_read_{index}(_args: Array = []) -> Variant:",
                        "\tvar revision: int = int(_args[0] if _args.size() > 0 else 0)",
                        "\tvar max_ammo: int = int(_args[1] if _args.size() > 1 else 0)",
                        "\tvar read_entries: Array = _args[2] if _args.size() > 2 and _args[2] is Array else []",
                        "\tvar read_calls: Array = []",
                        "\tvar ammo_entries_after: Array = []",
                        "\tvar total_ammo_after: int = 0",
                        "\tread_calls.append({\"call\": \"super.read(read, revision);\", \"revision\": revision})",
                        "\tread_calls.append({\"call\": \"ammo.clear();\"})",
                        "\tread_calls.append({\"call\": \"totalAmmo = 0;\", \"value\": 0})",
                        "\tread_calls.append({\"call\": \"read.ub();\", \"target\": \"amount\", \"value\": read_entries.size()})",
                        "\tfor entry in read_entries:",
                        "\t\tvar entry_copy: Dictionary = entry.duplicate(true) if entry is Dictionary else {}",
                        "\t\tvar item: Variant = entry_copy.get(\"item\", null)",
                        "\t\tvar ammo_type_valid: bool = bool(entry_copy.get(\"ammo_type_valid\", false))",
                        "\t\tvar item_read_call: String = \"read.ub();\" if revision < 2 else \"read.s();\"",
                        "\t\tread_calls.append({\"call\": item_read_call, \"target\": \"item\", \"item\": item})",
                        "\t\tvar item_amount: int = min(int(entry_copy.get(\"amount\", 0)), max_ammo)",
                        "\t\tread_calls.append({\"call\": \"read.s();\", \"target\": \"itemAmount\", \"value\": item_amount})",
                        "\t\tif item != null and ammo_type_valid:",
                        "\t\t\ttotal_ammo_after += item_amount",
                        "\t\t\tammo_entries_after.append({\"item\": item, \"amount\": item_amount})",
                        "\t\t\tread_calls.append({\"call\": \"totalAmmo += itemAmount;\", \"value\": total_ammo_after})",
                        "\t\t\tread_calls.append({\"call\": \"ammo.add(new ItemEntry(item, itemAmount));\", \"item\": item, \"amount\": item_amount})",
                        "\treturn {\"source_owner\": \"PortGame.source_item_turret_build_read_state\", \"inner_class\": \"public class ItemTurretBuild extends TurretBuild{\", \"method\": \"public void read(Reads read, byte revision){\", \"override_expr\": \"@Override\", \"super_read_expr\": \"super.read(read, revision);\", \"clear_expr\": \"ammo.clear();\", \"total_reset_expr\": \"totalAmmo = 0;\", \"amount_expr\": \"int amount = read.ub();\", \"loop_expr\": \"for(int i = 0; i < amount; i++){\", \"item_lookup_expr\": \"Item item = Vars.content.item(revision < 2 ? read.ub() : read.s());\", \"item_amount_expr\": \"int itemAmount = Math.min(read.s(), maxAmmo);\", \"valid_comment\": \"//only add ammo if this is a valid ammo type\", \"valid_ammo_guard\": \"if(item != null && ammoTypes.containsKey(item)){\", \"total_add_expr\": \"totalAmmo += itemAmount;\", \"ammo_add_expr\": \"ammo.add(new ItemEntry(item, itemAmount));\", \"read_count\": read_entries.size(), \"total_ammo_after\": total_ammo_after, \"ammo_entries_after\": ammo_entries_after, \"read_calls\": read_calls}",
                    ])
        for inner_class in type_entry.get("inner_classes", []):
            if inner_class.get("name") != "ItemEntry":
                continue
            for index, constructor in enumerate(inner_class.get("constructors", [])):
                if constructor.get("name") == "ItemEntry":
                    lines.extend([
                        "",
                        f"func java_inner_class_ItemEntry_constructor_ItemEntry_{index}(_args: Array = []) -> Variant:",
                        "\tvar item: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar amount: int = int(_args[1] if _args.size() > 1 else 0)",
                        "\treturn {\"source_owner\": \"PortGame.source_item_entry_constructor_state\", \"inner_class\": \"public class ItemEntry extends AmmoEntry{\", \"field\": \"public Item item;\", \"constructor\": \"ItemEntry(Item item, int amount){\", \"item_assign_expr\": \"this.item = item;\", \"amount_assign_expr\": \"this.amount = amount;\", \"item\": item, \"amount\": amount, \"item_after\": item, \"amount_after\": amount}",
                    ])
            for index, method in enumerate(inner_class.get("methods", [])):
                if method.get("name") == "type":
                    lines.extend([
                        "",
                        f"func java_inner_class_ItemEntry_method_type_{index}(_args: Array = []) -> Variant:",
                        "\tvar item: Variant = _args[0] if _args.size() > 0 else null",
                        "\tvar ammo_type: Variant = _args[1] if _args.size() > 1 else null",
                        "\treturn {\"source_owner\": \"PortGame.source_item_entry_type_state\", \"inner_class\": \"public class ItemEntry extends AmmoEntry{\", \"override_expr\": \"@Override\", \"method\": \"public BulletType type(){\", \"return_expr\": \"return ammoTypes.get(item);\", \"item\": item, \"ammo_type\": ammo_type, \"type\": ammo_type}",
                    ])
                if method.get("name") == "toString":
                    lines.extend([
                        "",
                        f"func java_inner_class_ItemEntry_method_toString_{index}(_args: Array = []) -> Variant:",
                        "\tvar item_string: String = str(_args[0] if _args.size() > 0 else \"null\")",
                        "\tvar amount: int = int(_args[1] if _args.size() > 1 else 0)",
                        "\tvar to_string_value: String = \"ItemEntry{item=\" + item_string + \", amount=\" + str(amount) + \"}\"",
                        "\treturn {\"source_owner\": \"PortGame.source_item_entry_to_string_state\", \"inner_class\": \"public class ItemEntry extends AmmoEntry{\", \"override_expr\": \"@Override\", \"method\": \"public String toString(){\", \"return_start_expr\": \"return \\\"ItemEntry{\\\" +\", \"item_concat_expr\": \"\\\"item=\\\" + item +\", \"amount_concat_expr\": \"\\\", amount=\\\" + amount +\", \"return_end_expr\": \"'}';\", \"item_string\": item_string, \"amount\": amount, \"to_string\": to_string_value}",
                    ])
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
    lines.extend(_extra_method_stub_lines(java_file, type_entry))
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
        source_path = Path(source_root) / java_file.get("path", "")
        if source_path.exists():
            java_file["_source_text"] = source_path.read_text(encoding="utf-8", errors="replace")
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
