import tempfile
import unittest
from pathlib import Path

import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.emitter import emit_gdscript_classes


class EmitterTests(unittest.TestCase):
    def test_emit_gdscript_class_skeleton_from_java_ast(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "content" / "Sample.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.content;
import mindustry.type.Item;
public class Sample extends BaseSample implements Named{
    public int health;
    private String displayName;
    public Sample(int health){}
    public boolean enabled(Item item){ return true; }
    private void enabled(){ }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            manifest = emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "content" / "Sample.gd"
            registry = output_root.parent / "GeneratedClassRegistry.gd"
            self.assertEqual(manifest["emitted_file_count"], 1)
            self.assertEqual(manifest["skipped_failure_count"], 0)
            self.assertEqual(manifest["files"], ["mindustry/content/Sample.gd"])
            self.assertEqual(manifest["registry"], "GeneratedClassRegistry.gd")
            self.assertEqual(emitted.read_text(encoding="utf-8"), """# Generated from Mindustry upstream.
# Source: mindustry/content/Sample.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.content"
const JAVA_KIND := "class"
const JAVA_NAME := "Sample"
const JAVA_EXTENDS := "BaseSample"
const JAVA_IMPLEMENTS := ["Named"]
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "health", "type": "int"}, {"modifiers": ["private"], "name": "displayName", "type": "String"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Sample", "parameters": [{"name": "health", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "enabled", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private"], "name": "enabled", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_enabled_0(_args: Array = []) -> Variant:
	return null

func java_method_enabled_1(_args: Array = []) -> Variant:
	return null
""")
            self.assertEqual(registry.read_text(encoding="utf-8"), """# Generated from Mindustry upstream.
# Source: emitted_classes.json
# Do not edit by hand.
extends RefCounted
class_name MindustryGeneratedClassRegistry

const CLASS_COUNT := 1
const CLASSES := [{"gdscript_path": "res://src/generated/classes/mindustry/content/Sample.gd", "java_kind": "class", "java_name": "Sample", "java_package": "mindustry.content", "java_path": "mindustry/content/Sample.java"}]

static func count() -> int:
	return CLASS_COUNT

static func all_classes() -> Array:
	return CLASSES

static func find_by_java_name(java_name: String) -> Dictionary:
	for class_entry in CLASSES:
		if class_entry.get("java_name", "") == java_name:
			return class_entry
	return {}
""")


    def test_emit_bridges_building_comp_get_progress_increase_to_source_formula(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public float getProgressIncrease(float baseTime){
        return 1f / baseTime * edelta();
    }

    public float getDisplayEfficiency(){
        return getProgressIncrease(1f) / edelta();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_getProgressIncrease_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var base_time := float(_args[0] if _args.size() > 0 else 1.0)", source_text)
            self.assertIn("var edelta_value := float(_args[1] if _args.size() > 1 else 1.0)", source_text)
            self.assertIn("return 1.0 / base_time * edelta_value", source_text)
            self.assertIn("func java_method_getDisplayEfficiency_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var edelta_value := float(_args[0] if _args.size() > 0 else 1.0)", source_text)
            self.assertIn("return (1.0 / 1.0 * edelta_value) / edelta_value", source_text)

    def test_emit_bridges_building_comp_should_ambient_sound_to_source_delegate(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public boolean shouldAmbientSound(){
        return shouldConsume();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_shouldAmbientSound_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var should_consume_state := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("return should_consume_state", source_text)

    def test_emit_bridges_building_comp_draw_status_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void drawStatus(){
        if(block.enableDrawStatus && block.consumers.length > 0){
            float multiplier = block.size > 1 ? 1 : 0.64f;
            float brcx = x + (block.size * tilesize / 2f) - (tilesize * multiplier / 2f);
            float brcy = y - (block.size * tilesize / 2f) + (tilesize * multiplier / 2f);
            Fill.square(brcx, brcy, 2.5f * multiplier, 45);
            Fill.square(brcx, brcy, 1.5f * multiplier, 45);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawStatus_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var enable_draw_status := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var consumers_length := int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("var block_size_value := int(_args[2] if _args.size() > 2 else 1)", source_text)
            self.assertIn("var multiplier := 1.0 if block_size_value > 1 else 0.64", source_text)
            self.assertIn('"gray_square_size": 2.5 * multiplier', source_text)
            self.assertIn('"status_square_size": 1.5 * multiplier', source_text)

    def test_emit_bridges_building_comp_draw_cracks_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void drawCracks(){
        if(!block.drawCracks || !damaged() || block.size > BlockRenderer.maxCrackSize) return;
        int id = pos();
        TextureRegion region = renderer.blocks.cracks[block.size - 1][Mathf.clamp((int)((1f - healthf()) * BlockRenderer.crackRegions), 0, BlockRenderer.crackRegions-1)];
        Draw.colorl(0.2f, 0.1f + (1f - healthf())* 0.6f);
        Draw.rect(region, x, y, (id%4)*90);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawCracks_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var draw_cracks := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var damaged_state := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var crack_index := clampi(int((1.0 - health_fraction) * float(crack_regions)), 0, crack_regions - 1)", source_text)
            self.assertIn("var lightness := 0.1 + (1.0 - health_fraction) * 0.6", source_text)
            self.assertIn("var crack_rotation_degrees := (position_id % 4) * 90", source_text)
            self.assertIn('"region_size_index": block_size_value - 1', source_text)

    def test_emit_bridges_building_comp_draw_select_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void drawSelect(){
        block.drawOverlay(x, y, rotation);
        if(status() == BlockStatus.inactiveUnitFactory){
            block.drawPlaceText(Core.bundle.format("rules.unitfactoryactivation.objective", UI.formatTime((float)Math.max(0f, state.rules.unitActivationDelay(team) - state.tick))), tile.x, tile.y, false);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawSelect_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var block_status := str(_args[0] if _args.size() > 0 else "")', source_text)
            self.assertIn("var source_x := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var source_rotation := float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn('var inactive_unit_factory := block_status == "inactiveUnitFactory"', source_text)
            self.assertIn("var remaining_activation_delay := maxf(0.0, unit_activation_delay - state_tick)", source_text)
            self.assertIn('"overlay_visible": true', source_text)
            self.assertIn('"place_text_bundle_key": "rules.unitfactoryactivation.objective"', source_text)

    def test_emit_bridges_building_comp_draw_item_selection_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void drawItemSelection(@Nullable UnlockableContent selection){
        if(selection != null){
            float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;
            Draw.mixcol(Color.darkGray, 1f);
            Draw.rect(selection.fullIcon, dx, dy - 1, s, h);
            Draw.reset();
            Draw.rect(selection.fullIcon, dx, dy, s, h);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawItemSelection_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var has_selection := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("if not has_selection:", source_text)
            self.assertIn("var dx := source_x - float(block_size_value) * source_tilesize / 2.0", source_text)
            self.assertIn("var selection_width := icon_small / 4.0 * selection_icon_ratio", source_text)
            self.assertIn('"shadow_color": "darkGray"', source_text)
            self.assertIn('"foreground_y": dy', source_text)

    def test_emit_bridges_building_comp_draw_disabled_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void drawDisabled(){
        Draw.color(Color.scarlet);
        Draw.alpha(0.8f);
        float size = 6f;
        Draw.rect(Icon.cancel.getRegion(), x, y, size, size);
        Draw.reset();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawDisabled_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var source_x := float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var source_y := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var disabled_icon_size := 6.0", source_text)
            self.assertIn('"icon": "cancel"', source_text)
            self.assertIn('"color": "scarlet"', source_text)
            self.assertIn('"alpha": 0.8', source_text)
            self.assertIn('"width": disabled_icon_size', source_text)

    def test_emit_bridges_building_comp_draw_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void draw(){
        if(block.variants == 0 || block.variantRegions == null){
            Draw.rect(block.region, x, y, drawrot());
        }else{
            Draw.rect(block.variantRegions[Mathf.randomSeed(tile.pos(), 0, Math.max(0, block.variantRegions.length - 1))], x, y, drawrot());
        }
        drawTeamTop();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_draw_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var variants := int(_args[0] if _args.size() > 0 else 0)", source_text)
            self.assertIn("var has_variant_regions := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var variant_region_count := int(_args[2] if _args.size() > 2 else 0)", source_text)
            self.assertIn("var tile_pos := int(_args[3] if _args.size() > 3 else 0)", source_text)
            self.assertIn("var source_x := float(_args[4] if _args.size() > 4 else 0.0)", source_text)
            self.assertIn("var source_y := float(_args[5] if _args.size() > 5 else 0.0)", source_text)
            self.assertIn("var block_rotate := bool(_args[6] if _args.size() > 6 else false)", source_text)
            self.assertIn("var block_rotate_draw := bool(_args[7] if _args.size() > 7 else false)", source_text)
            self.assertIn("var rotation_quadrants := int(_args[8] if _args.size() > 8 else 0)", source_text)
            self.assertIn("var draw_rotation := float(rotation_quadrants * 90) if block_rotate and block_rotate_draw else 0.0", source_text)
            self.assertIn("if variants == 0 or not has_variant_regions:", source_text)
            self.assertIn("var max_variant_index: int = max(0, variant_region_count - 1)", source_text)
            self.assertIn("var variant_index: int = _source_arc_random_seed_int(tile_pos, 0, max_variant_index)", source_text)
            self.assertIn('"region_kind": "variant_region"', source_text)
            self.assertIn('"draw_team_top": true', source_text)

    def test_emit_bridges_building_comp_draw_cached_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void drawCached(){
        draw();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawCached_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("return java_method_draw_128(_args)", source_text)

    def test_emit_bridges_building_comp_recache_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void recache(){
        if(!headless) renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_recache_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var headless := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn('var building_cache_layer: Variant = _args[1] if _args.size() > 1 else null', source_text)
            self.assertIn('var tile_state: Variant = _args[2] if _args.size() > 2 else null', source_text)
            self.assertIn("if headless:", source_text)
            self.assertIn('"recache_call": ""', source_text)
            self.assertIn('"recache": false', source_text)
            self.assertIn('"recache_call": "renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);"', source_text)
            self.assertIn('"recache": true', source_text)

    def test_emit_bridges_building_comp_payload_draw_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void payloadDraw(){
        float z = Draw.z();
        if(block.drawCached){
            Draw.z(block.buildingCacheLayer.layer);
            drawCached();
        }
        if(block.drawDynamic){
            Draw.z(z);
            draw();
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_payloadDraw_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var draw_cached := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var draw_dynamic := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var current_z := float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var building_cache_layer_z := float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var variants := int(_args[4] if _args.size() > 4 else 0)", source_text)
            self.assertIn("var draw_args := [variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants]", source_text)
            self.assertIn("var cached_draw: Dictionary = {}", source_text)
            self.assertIn("cached_draw = java_method_drawCached_129(draw_args)", source_text)
            self.assertIn("dynamic_draw = java_method_draw_128(draw_args)", source_text)
            self.assertIn('"cached_gate": "if(block.drawCached){" if draw_cached else ""', source_text)
            self.assertIn('"dynamic_draw_call": "draw();" if draw_dynamic else ""', source_text)

    def test_emit_bridges_building_comp_draw_team_top_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void drawTeamTop(){
        if(block.teamRegion.found()){
            if(block.teamRegions[team.id] == block.teamRegion) Draw.color(team.color);
            Draw.rect(block.teamRegions[team.id], x, y);
            Draw.color();
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawTeamTop_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var team_region_found := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var team_region_matches_team := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn('var team_color := String(_args[2] if _args.size() > 2 else "")', source_text)
            self.assertIn("var source_x := float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var source_y := float(_args[4] if _args.size() > 4 else 0.0)", source_text)
            self.assertIn("if not team_region_found:", source_text)
            self.assertIn('return {"visible": false}', source_text)
            self.assertIn('"tint_color": team_color if team_region_matches_team else ""', source_text)
            self.assertIn('"color_reset": true', source_text)

    def test_emit_bridges_building_comp_draw_light_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void drawLight(){
        Liquid liq = block.hasLiquids && block.lightLiquid == null ? liquids.current() : block.lightLiquid;
        if(block.hasLiquids && block.drawLiquidLight && liq.lightColor.a > 0.001f){
            visualLiquid = Mathf.lerpDelta(visualLiquid, liquids.get(liq)>= 0.01f ? 1f : 0f, 0.06f);
            drawLiquidLight(liq, visualLiquid);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawLight_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var has_liquids := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var draw_liquid_light := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var light_liquid_is_null := bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn('var current_liquid_color := String(_args[3] if _args.size() > 3 else "")', source_text)
            self.assertIn("var selected_color: String = current_liquid_color if light_liquid_is_null else light_liquid_color", source_text)
            self.assertIn("var selected_alpha: float = current_liquid_alpha if light_liquid_is_null else light_liquid_alpha", source_text)
            self.assertIn("if not has_liquids or not draw_liquid_light or selected_alpha <= 0.001:", source_text)
            self.assertIn('return {"visible": false, "visual_liquid": visual_liquid}', source_text)
            self.assertIn("var target: float = 1.0 if selected_liquid_amount >= 0.01 else 0.0", source_text)
            self.assertIn("var next_visual_liquid: float = lerp(visual_liquid, target, clamp(0.06 * source_delta, 0.0, 1.0))", source_text)
            self.assertIn('var light_state: Dictionary = {"visible": false, "drawLiquidLightCall": "drawLiquidLight(liq, visualLiquid);"}', source_text)
            self.assertIn("var fract: float = 1.0", source_text)
            self.assertIn("var opacity: float = selected_alpha * fract", source_text)
            self.assertIn('"drawLiquidLightCall": "drawLiquidLight(liq, visualLiquid);"', source_text)

    def test_emit_bridges_building_comp_draw_liquid_light_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void drawLiquidLight(Liquid liquid, float amount){
        if(amount > 0.01f){
            Color color = liquid.lightColor;
            float fract = 1f;
            float opacity = color.a * fract;
            if(opacity > 0.001f){
                Drawf.light(x, y, block.size * 30f * fract, color, opacity * amount);
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawLiquidLight_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var source_x := float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var source_y := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var block_size_value := int(_args[2] if _args.size() > 2 else 0)", source_text)
            self.assertIn('var light_color := String(_args[3] if _args.size() > 3 else "")', source_text)
            self.assertIn("var light_alpha := float(_args[4] if _args.size() > 4 else 0.0)", source_text)
            self.assertIn("var amount := float(_args[5] if _args.size() > 5 else 0.0)", source_text)
            self.assertIn("if amount <= 0.01:", source_text)
            self.assertIn('return {"visible": false}', source_text)
            self.assertIn("var fract: float = 1.0", source_text)
            self.assertIn("var opacity: float = light_alpha * fract", source_text)
            self.assertIn("if opacity <= 0.001:", source_text)
            self.assertIn('return {"visible": true, "x": source_x, "y": source_y, "radius": block_size_value * 30.0 * fract, "color": light_color, "opacity": opacity, "alpha": opacity * amount, "fract": fract}', source_text)

    def test_emit_bridges_building_comp_draw_team_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void drawTeam(){
        Draw.color(team.color);
        Draw.rect("block-border", x - block.size * tilesize / 2f + 4, y - block.size * tilesize / 2f + 4);
        Draw.color();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawTeam_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var team_color := String(_args[0] if _args.size() > 0 else "")', source_text)
            self.assertIn("var source_x := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var source_y := float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var block_size_value := int(_args[3] if _args.size() > 3 else 0)", source_text)
            self.assertIn("var source_tilesize := float(_args[4] if _args.size() > 4 else 8.0)", source_text)
            self.assertIn('return {"visible": true, "region": "block-border", "color": team_color, "x": source_x - block_size_value * source_tilesize / 2.0 + 4.0, "y": source_y - block_size_value * source_tilesize / 2.0 + 4.0, "color_reset": true}', source_text)

    def test_emit_bridges_building_comp_check_suppression_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public boolean checkSuppression(){
        if(isHealSuppressed()){
            if(Mathf.chanceDelta(0.03)){
                Fx.regenSuppressParticle.at(x + Mathf.range(block.size * tilesize/2f - 1f), y + Mathf.range(block.size * tilesize/2f - 1f), suppressColor);
            }
            return true;
        }
        return false;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_checkSuppression_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var block_suppressable := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var source_time := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var heal_suppression_time := float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var source_delta := float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var source_x := float(_args[4] if _args.size() > 4 else 0.0)", source_text)
            self.assertIn("var source_y := float(_args[5] if _args.size() > 5 else 0.0)", source_text)
            self.assertIn("var block_size_value := int(_args[6] if _args.size() > 6 else 0)", source_text)
            self.assertIn("var source_tilesize := float(_args[7] if _args.size() > 7 else 8.0)", source_text)
            self.assertIn('var suppress_color := String(_args[8] if _args.size() > 8 else "")', source_text)
            self.assertIn("var suppressed: bool = block_suppressable and source_time <= heal_suppression_time", source_text)
            self.assertIn('return {"suppressed": false, "particle_visible": false}', source_text)
            self.assertIn("var particle_range: float = block_size_value * source_tilesize / 2.0 - 1.0", source_text)
            self.assertIn("var chance_threshold: float = 0.03 * source_delta", source_text)
            self.assertIn('"particle_visible": "chanceDelta"', source_text)
            self.assertIn('"effect": "regenSuppressParticle"', source_text)
            self.assertIn('"x_min": source_x - particle_range', source_text)

    def test_emit_bridges_building_comp_player_placed_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    @CallSuper
    public void playerPlaced(Object config){

    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_playerPlaced_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var config_state: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"method": "public void playerPlaced(Object config){"', source_text)
            self.assertIn('"comment": "Called after the block is placed by this client."', source_text)
            self.assertIn('"call_super": "@CallSuper"', source_text)
            self.assertIn('"no_op": true', source_text)
            self.assertIn('"config_state": config_state', source_text)

    def test_emit_bridges_building_comp_placed_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    @CallSuper
    public void placed(){
        if(net.client()) return;

        if((block.consumesPower || block.outputsPower) && block.hasPower && block.connectedPower){
            PowerNode.getNodeLinks(tile, block, team, other -> {
                if(!other.power.links.contains(pos())){
                    other.configureAny(pos());
                }
            });
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_placed_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var net_client := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var consumes_power := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var outputs_power := bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("var has_power := bool(_args[3] if _args.size() > 3 else false)", source_text)
            self.assertIn("var connected_power := bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("var linked_to_self := bool(_args[5] if _args.size() > 5 else false)", source_text)
            self.assertIn("var source_pos := int(_args[6] if _args.size() > 6 else -1)", source_text)
            self.assertIn("var should_link_power := (consumes_power or outputs_power) and has_power and connected_power", source_text)
            self.assertIn('"client_guard": "if(net.client()) return;" if net_client else ""', source_text)
            self.assertIn('"power_node_scan": "PowerNode.getNodeLinks(tile, block, team, other -> {" if should_link_power else ""', source_text)
            self.assertIn('"configure_call": "other.configureAny(pos());" if configure else ""', source_text)
            self.assertIn('"configure_pos": source_pos if configure else -1', source_text)

    def test_emit_bridges_building_comp_on_repaired_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    @CallSuper
    public void onRepaired(){
        placed();
        if(block.flags.contains(BlockFlag.hasFogRadius)){
            fogControl.forceUpdate(team, self());
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_onRepaired_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var has_fog_radius := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn('"method": "public void onRepaired(){"', source_text)
            self.assertIn('"call_super": "@CallSuper"', source_text)
            self.assertIn('"placed_call": "placed();"', source_text)
            self.assertIn('"fog_gate": "if(block.flags.contains(BlockFlag.hasFogRadius)){" if has_fog_radius else ""', source_text)
            self.assertIn('"fog_call": "fogControl.forceUpdate(team, self());" if has_fog_radius else ""', source_text)
            self.assertIn('"has_fog_radius": has_fog_radius', source_text)
            self.assertIn('"placed": true', source_text)
            self.assertIn('"fog_force_update": has_fog_radius', source_text)

    def test_emit_bridges_building_comp_is_commandable_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public boolean isCommandable(){
        return block.commandable;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_isCommandable_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var block_commandable := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn('"method": "public boolean isCommandable(){"', source_text)
            self.assertIn('"return_expr": "return block.commandable;"', source_text)
            self.assertIn('"block_commandable": block_commandable', source_text)
            self.assertIn('"commandable": block_commandable', source_text)

    def test_emit_bridges_building_comp_is_payload_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public boolean isPayload(){
        return tile == emptyTile;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_isPayload_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var tile_is_empty_tile := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn('"method": "public boolean isPayload(){"', source_text)
            self.assertIn('"return_expr": "return tile == emptyTile;"', source_text)
            self.assertIn('"tile_is_empty_tile": tile_is_empty_tile', source_text)
            self.assertIn('"is_payload": tile_is_empty_tile', source_text)

    def test_emit_bridges_building_comp_overwrote_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /**
     * Called when a block is placed over some other blocks. This seq will always have at least one item.
     * Should load some previous state, if necessary. */
    public void overwrote(Seq<Building> previous){

    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_overwrote_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var previous_state: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"method": "public void overwrote(Seq<Building> previous){"', source_text)
            self.assertIn('"comment": "Called when a block is placed over some other blocks. This seq will always have at least one item."', source_text)
            self.assertIn('"no_op": true', source_text)
            self.assertIn('"previous_state": previous_state', source_text)

    def test_emit_bridges_building_comp_on_removed_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void onRemoved(){
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_onRemoved_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var current_state: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"method": "public void onRemoved(){"', source_text)
            self.assertIn('"no_op": true', source_text)
            self.assertIn('"current_state": current_state', source_text)

    def test_emit_bridges_building_comp_unit_on_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Called every frame a unit is on this. Hovering/flying/steppy units do not apply.  */
    public void unitOn(Unit unit){
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_unitOn_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var unit_state: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"comment": "Called every frame a unit is on this. Hovering/flying/steppy units do not apply.  "', source_text)
            self.assertIn('"method": "public void unitOn(Unit unit){"', source_text)
            self.assertIn('"empty_body": "public void unitOn(Unit unit){\\n    }"', source_text)
            self.assertIn('"unit_state": unit_state', source_text)

    def test_emit_bridges_building_comp_unit_on_any_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Called every frame a unit is on this. Applies to any unit.  */
    public void unitOnAny(Unit unit){
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_unitOnAny_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var unit_state: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"comment": "Called every frame a unit is on this. Applies to any unit.  "', source_text)
            self.assertIn('"method": "public void unitOnAny(Unit unit){"', source_text)
            self.assertIn('"empty_body": "public void unitOnAny(Unit unit){\\n    }"', source_text)
            self.assertIn('"unit_state": unit_state', source_text)

    def test_emit_bridges_building_comp_unit_removed_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Called when a unit that spawned at this tile is removed. */
    public void unitRemoved(Unit unit){
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_unitRemoved_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var unit_state: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"comment": "Called when a unit that spawned at this tile is removed."', source_text)
            self.assertIn('"method": "public void unitRemoved(Unit unit){"', source_text)
            self.assertIn('"empty_body": "public void unitRemoved(Unit unit){\\n    }"', source_text)
            self.assertIn('"unit_state": unit_state', source_text)

    def test_emit_bridges_building_comp_puddle_on_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Called when a puddle is on this building. Only called at an interval (40 ticks). */
    public void puddleOn(Puddle puddle){

    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_puddleOn_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var puddle_state: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"comment": "Called when a puddle is on this building. Only called at an interval (40 ticks)."', source_text)
            self.assertIn('"method": "public void puddleOn(Puddle puddle){"', source_text)
            self.assertIn('"no_op": true', source_text)
            self.assertIn('"puddle_state": puddle_state', source_text)

    def test_emit_bridges_building_comp_configured_type_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void configured(@Nullable Unit builder, @Nullable Object value){
        //null is of type void.class; anonymous classes use their superclass.
        Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();

        if(value instanceof Item) type = Item.class;
        if(value instanceof Block) type = Block.class;
        if(value instanceof Liquid) type = Liquid.class;
        if(value instanceof UnitType) type = UnitType.class;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_configured_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var value_state: Dictionary = _args[1] if _args.size() > 1 and _args[1] is Dictionary else {}", source_text)
            self.assertIn("var type_name := \"void\" if bool(value_state.get(\"is_null\", false)) else str(value_state.get(\"superclass\", \"\")) if bool(value_state.get(\"is_anonymous_class\", false)) else str(value_state.get(\"class\", \"\"))", source_text)
            self.assertIn("var value_kind := str(value_state.get(\"kind\", \"\"))", source_text)
            self.assertIn("if value_kind == \"Item\":", source_text)
            self.assertIn("if value_kind == \"Block\":", source_text)
            self.assertIn("if value_kind == \"Liquid\":", source_text)
            self.assertIn("if value_kind == \"UnitType\":", source_text)
            self.assertIn('"assignment": "Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();"', source_text)
            self.assertIn('"item_override": "if(value instanceof Item) type = Item.class;"', source_text)
            self.assertIn('"block_override": "if(value instanceof Block) type = Block.class;"', source_text)
            self.assertIn('"liquid_override": "if(value instanceof Liquid) type = Liquid.class;"', source_text)
            self.assertIn('"unit_type_override": "if(value instanceof UnitType) type = UnitType.class;"', source_text)
            self.assertIn('"type_name": type_name', source_text)
            self.assertIn('"value_state": value_state', source_text)

    def test_emit_bridges_building_comp_update_last_access_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void updateLastAccess(Player player){
        lastAccessed = player.coloredName();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_updateLastAccess_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var builder_state: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}", source_text)
            self.assertIn("var current_last_accessed := str(_args[1] if _args.size() > 1 else \"\")", source_text)
            self.assertIn("var last_accessed := str(builder_state.get(\"colored_name\", \"\"))", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_configured_last_access_state"', source_text)
            self.assertIn('"method": "public void updateLastAccess(Player player){"', source_text)
            self.assertIn('"assignment": "lastAccessed = player.coloredName();"', source_text)
            self.assertIn('"last_accessed": last_accessed', source_text)
            self.assertIn('"updated": true', source_text)
            self.assertIn('"builder_state": builder_state', source_text)
            self.assertIn('"current_last_accessed": current_last_accessed', source_text)
            self.assertNotIn("if(builder != null && builder.isPlayer()){", source_text)
            self.assertNotIn("updateLastAccess(builder.getPlayer());", source_text)

    def test_emit_bridges_building_comp_tapped_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Called when the block is tapped by the local player. */
    public void tapped(){

    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_tapped_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var current_state: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_tapped_state"', source_text)
            self.assertIn('"comment": "Called when the block is tapped by the local player."', source_text)
            self.assertIn('"method": "public void tapped(){"', source_text)
            self.assertIn('"empty_body": "public void tapped(){\\n\\n    }"', source_text)
            self.assertIn('"current_state": current_state', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_building_comp_after_destroyed_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Called *after* the tile has been removed. */
    public void afterDestroyed(){
        if(block.destroyBullet != null){
            block.destroyBullet.create(this, block.destroyBulletSameTeam ? team : Team.derelict, x, y, Mathf.randomSeed(id(), 360f));
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_afterDestroyed_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var has_destroy_bullet := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var destroy_bullet_same_team := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn('var team_id := str(_args[2] if _args.size() > 2 else "")', source_text)
            self.assertIn("var source_x := float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var source_y := float(_args[4] if _args.size() > 4 else 0.0)", source_text)
            self.assertIn("var building_id := int(_args[5] if _args.size() > 5 else 0)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_after_destroyed_state"', source_text)
            self.assertIn('"comment": "Called *after* the tile has been removed."', source_text)
            self.assertIn('"method": "public void afterDestroyed(){"', source_text)
            self.assertIn('"guard": "if(block.destroyBullet != null){"', source_text)
            self.assertIn('"create_call": "block.destroyBullet.create(this, block.destroyBulletSameTeam ? team : Team.derelict, x, y, Mathf.randomSeed(id(), 360f));"', source_text)
            self.assertIn('"team_choice": "block.destroyBulletSameTeam ? team : Team.derelict"', source_text)
            self.assertIn('"rotation_expr": "Mathf.randomSeed(id(), 360f)"', source_text)
            self.assertIn('"has_destroy_bullet": has_destroy_bullet', source_text)
            self.assertIn('"destroy_bullet_same_team": destroy_bullet_same_team', source_text)
            self.assertIn('"team_id": team_id', source_text)
            self.assertIn('"source_x": source_x', source_text)
            self.assertIn('"source_y": source_y', source_text)
            self.assertIn('"building_id": building_id', source_text)

    def test_emit_bridges_building_comp_explosion_item_cap_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** @return the cap for item amount calculations, used when this block explodes. */
    public int explosionItemCap(){
        return block.itemCapacity;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_explosionItemCap_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var item_capacity := int(_args[0] if _args.size() > 0 else 0)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_explosion_item_cap_state"', source_text)
            self.assertIn('"comment": "@return the cap for item amount calculations, used when this block explodes."', source_text)
            self.assertIn('"method": "public int explosionItemCap(){"', source_text)
            self.assertIn('"return_expr": "return block.itemCapacity;"', source_text)
            self.assertIn('"item_capacity": item_capacity', source_text)
            self.assertIn('"explosion_item_cap": item_capacity', source_text)

    def test_emit_bridges_building_comp_splash_liquid_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void splashLiquid(Liquid liquid, float amount){
        float splash = Mathf.clamp(amount / 4f, 0f, 10f);

        for(int i = 0; i < Mathf.clamp(amount / 5, 0, 30); i++){
            Time.run(i / 2f, () -> {
                Tile other = world.tileWorld(x + Mathf.range(block.size * tilesize / 2), y + Mathf.range(block.size * tilesize / 2));
                if(other != null){
                    Puddles.deposit(other, liquid, splash);
                }
            });
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_splashLiquid_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var liquid: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var amount := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var source_block_size := int(_args[2] if _args.size() > 2 else 0)", source_text)
            self.assertIn("var source_tilesize := float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var splash := clampf(amount / 4.0, 0.0, 10.0)", source_text)
            self.assertIn("var deposit_count := int(ceil(clampf(amount / 5.0, 0.0, 30.0)))", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_splash_liquid_state"', source_text)
            self.assertIn('"method": "public void splashLiquid(Liquid liquid, float amount){"', source_text)
            self.assertIn('"splash_expr": "float splash = Mathf.clamp(amount / 4f, 0f, 10f);"', source_text)
            self.assertIn('"loop": "for(int i = 0; i < Mathf.clamp(amount / 5, 0, 30); i++){"', source_text)
            self.assertIn('"delay_expr": "Time.run(i / 2f, () -> {"', source_text)
            self.assertIn('"tile_world": "Tile other = world.tileWorld(x + Mathf.range(block.size * tilesize / 2), y + Mathf.range(block.size * tilesize / 2));"', source_text)
            self.assertIn('"deposit_guard": "if(other != null){"', source_text)
            self.assertIn('"deposit": "Puddles.deposit(other, liquid, splash);"', source_text)
            self.assertIn('"liquid": liquid', source_text)
            self.assertIn('"amount": amount', source_text)
            self.assertIn('"source_block_size": source_block_size', source_text)
            self.assertIn('"source_tilesize": source_tilesize', source_text)
            self.assertIn('"splash": splash', source_text)
            self.assertIn('"deposit_count": deposit_count', source_text)
            self.assertIn('"delays": delays', source_text)
            self.assertIn('"random_range": float(source_block_size) * source_tilesize / 2.0', source_text)
            self.assertIn('"deposit_if_tile_exists": true', source_text)

    def test_emit_bridges_building_comp_on_deconstructed_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Called when a block begins (not finishes!) deconstruction. The building is still present at this point. */
    public void onDeconstructed(@Nullable Unit builder){
        //deposit non-incinerable liquid on ground
        if(liquids != null && liquids.currentAmount() > 0 && (!liquids.current().incinerable || block.deconstructDropAllLiquid)){
            float perCell = liquids.currentAmount() / (block.size * block.size) * 2f;
            tile.getLinkedTiles(other -> Puddles.deposit(other, liquids.current(), perCell));
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_onDeconstructed_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var has_liquids_module := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var current_amount := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var current_incinerable := bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("var deconstruct_drop_all_liquid := bool(_args[3] if _args.size() > 3 else false)", source_text)
            self.assertIn("var source_block_size := int(_args[4] if _args.size() > 4 else 0)", source_text)
            self.assertIn("var can_drop_liquid := not current_incinerable or deconstruct_drop_all_liquid", source_text)
            self.assertIn("var deposit_linked_tiles := has_liquids_module and current_amount > 0.0 and can_drop_liquid", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_on_deconstructed_liquid_state"', source_text)
            self.assertIn('"comment": "Called when a block begins (not finishes!) deconstruction. The building is still present at this point."', source_text)
            self.assertIn('"method": "public void onDeconstructed(@Nullable Unit builder){"', source_text)
            self.assertIn('"deposit_comment": "//deposit non-incinerable liquid on ground"', source_text)
            self.assertIn('"gate": "if(liquids != null && liquids.currentAmount() > 0 && (!liquids.current().incinerable || block.deconstructDropAllLiquid)){"', source_text)
            self.assertIn('"per_cell_expr": "float perCell = liquids.currentAmount() / (block.size * block.size) * 2f;"', source_text)
            self.assertIn('"deposit_call_expr": "tile.getLinkedTiles(other -> Puddles.deposit(other, liquids.current(), perCell));"', source_text)
            self.assertIn('"has_liquids_module": has_liquids_module', source_text)
            self.assertIn('"current_amount": current_amount', source_text)
            self.assertIn('"current_incinerable": current_incinerable', source_text)
            self.assertIn('"deconstruct_drop_all_liquid": deconstruct_drop_all_liquid', source_text)
            self.assertIn('"source_block_size": source_block_size', source_text)
            self.assertIn('"can_drop_liquid": can_drop_liquid', source_text)
            self.assertIn('"deposit_linked_tiles": deposit_linked_tiles', source_text)
            self.assertIn('"per_cell": per_cell', source_text)
            self.assertIn('"deposit_call": deposit_linked_tiles', source_text)

    def test_emit_bridges_building_comp_on_destroyed_item_explosion_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Called when the block is destroyed. The tile is still intact at this stage. */
    public void onDestroyed(){
        float explosiveness = block.baseExplosiveness;
        float flammability = 0f;
        float power = 0f;

        if(block.hasItems){
            for(Item item : content.items()){
                int amount = Math.min(items.get(item), explosionItemCap());
                explosiveness += item.explosiveness * amount;
                flammability += item.flammability * amount;
                power += item.charge * Mathf.pow(amount, 1.1f) * 150f;
            }
        }

        if(block.hasLiquids){
            flammability += liquids.sum((liquid, amount) -> liquid.flammability * amount / 2f);
            explosiveness += liquids.sum((liquid, amount) -> liquid.explosiveness * amount / 2f);
        }

        if(block.consPower != null && block.consPower.buffered){
            power += this.power.status * block.consPower.capacity;
        }

        if(block.hasLiquids && state.rules.damageExplosions){
            liquids.each(this::splashLiquid);
        }

        //cap explosiveness so fluid tanks/vaults don't instakill units
        Damage.dynamicExplosion(x, y, flammability * block.flammabilityScale, explosiveness * 3.5f * block.explosivenessScale, power, tilesize * block.size / 2f, state.rules.damageExplosions, block.destroyEffect, block.baseShake);

        if(block.createRubble && !floor().solid && !floor().isLiquid){
            Effect.rubble(x, y, block.size);
        }

            if(!headless){
                playDestroySound();

                if(explosiveness > 40f){
                    (Mathf.chance(0.5) ? Sounds.blockExplodeExplosive : Sounds.blockExplodeExplosiveAlt).at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);
                }else if(flammability > 5f){
                    Sounds.blockExplodeFlammable.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);
                }

                if(power > 30000f){
                    Sounds.blockExplodeElectricBig.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);
                }else if(power > 2000f){
                    Sounds.blockExplodeElectric.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);
                }
            }
        }

    public void playDestroySound(){
        block.destroySound.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_onDestroyed_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var base_explosiveness := float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var has_items := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var item_states: Array = _args[2] if _args.size() > 2 and _args[2] is Array else []", source_text)
            self.assertIn("var item_cap := int(_args[3] if _args.size() > 3 else 0)", source_text)
            self.assertIn("var explosiveness := base_explosiveness", source_text)
            self.assertIn("var flammability := 0.0", source_text)
            self.assertIn("var power := 0.0", source_text)
            self.assertIn("var item_amount: int = min(int(item_state.get(\"amount\", 0)), item_cap)", source_text)
            self.assertIn("var has_liquids := bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("var liquid_states: Array = _args[5] if _args.size() > 5 and _args[5] is Array else []", source_text)
            self.assertIn("if has_liquids:", source_text)
            self.assertIn("flammability += float(liquid_state.get(\"flammability\", 0.0)) * float(liquid_state.get(\"amount\", 0.0)) / 2.0", source_text)
            self.assertIn("explosiveness += float(liquid_state.get(\"explosiveness\", 0.0)) * float(liquid_state.get(\"amount\", 0.0)) / 2.0", source_text)
            self.assertIn("var current_power := power", source_text)
            self.assertIn("var has_cons_power := bool(_args[6] if _args.size() > 6 else false)", source_text)
            self.assertIn("var cons_power_buffered := bool(_args[7] if _args.size() > 7 else false)", source_text)
            self.assertIn("var power_status := float(_args[8] if _args.size() > 8 else 0.0)", source_text)
            self.assertIn("var cons_power_capacity := float(_args[9] if _args.size() > 9 else 0.0)", source_text)
            self.assertIn("var apply_buffered_power := has_cons_power and cons_power_buffered", source_text)
            self.assertIn("var buffered_power_contribution := power_status * cons_power_capacity if apply_buffered_power else 0.0", source_text)
            self.assertIn("power = current_power + buffered_power_contribution", source_text)
            self.assertIn("var damage_explosions := bool(_args[10] if _args.size() > 10 else false)", source_text)
            self.assertIn("var splash_liquids := has_liquids and damage_explosions", source_text)
            self.assertIn('var splash_call := "liquids.each(this::splashLiquid);" if splash_liquids else ""', source_text)
            self.assertIn("var liquid_count := liquid_states.size() if splash_liquids else 0", source_text)
            self.assertIn("var liquids: Array = liquid_states.duplicate() if splash_liquids else []", source_text)
            self.assertIn("var source_x := float(_args[11] if _args.size() > 11 else 0.0)", source_text)
            self.assertIn("var source_y := float(_args[12] if _args.size() > 12 else 0.0)", source_text)
            self.assertIn("var flammability_scale := float(_args[13] if _args.size() > 13 else 1.0)", source_text)
            self.assertIn("var explosiveness_scale := float(_args[14] if _args.size() > 14 else 1.0)", source_text)
            self.assertIn("var source_tilesize := float(_args[15] if _args.size() > 15 else 0.0)", source_text)
            self.assertIn("var source_block_size := int(_args[16] if _args.size() > 16 else 0)", source_text)
            self.assertIn('var destroy_effect := str(_args[17] if _args.size() > 17 else "")', source_text)
            self.assertIn("var base_shake := float(_args[18] if _args.size() > 18 else 0.0)", source_text)
            self.assertIn("var dynamic_explosion_flammability := flammability * flammability_scale", source_text)
            self.assertIn("var dynamic_explosion_explosiveness := explosiveness * 3.5 * explosiveness_scale", source_text)
            self.assertIn("var dynamic_explosion_radius := source_tilesize * float(source_block_size) / 2.0", source_text)
            self.assertIn("var create_rubble := bool(_args[19] if _args.size() > 19 else false)", source_text)
            self.assertIn("var floor_solid := bool(_args[20] if _args.size() > 20 else false)", source_text)
            self.assertIn("var floor_is_liquid := bool(_args[21] if _args.size() > 21 else false)", source_text)
            self.assertIn("var should_create_rubble := create_rubble and not floor_solid and not floor_is_liquid", source_text)
            self.assertIn('var rubble_call := "Effect.rubble(x, y, block.size);" if should_create_rubble else ""', source_text)
            self.assertIn("var headless := bool(_args[22] if _args.size() > 22 else false)", source_text)
            self.assertIn('var destroy_sound := str(_args[23] if _args.size() > 23 else "")', source_text)
            self.assertIn("var destroy_pitch_min := float(_args[24] if _args.size() > 24 else 0.0)", source_text)
            self.assertIn("var destroy_pitch_max := float(_args[25] if _args.size() > 25 else 0.0)", source_text)
            self.assertIn("var destroy_sound_volume := float(_args[26] if _args.size() > 26 else 0.0)", source_text)
            self.assertIn("var play_destroy_sound := not headless", source_text)
            self.assertIn('var base_destroy_sound := destroy_sound if play_destroy_sound else ""', source_text)
            self.assertIn("var play_reactive_sound := not headless and (explosiveness > 40.0 or flammability > 5.0)", source_text)
            self.assertIn('var reactive_sound_kind := "explosive" if not headless and explosiveness > 40.0 else "flammable" if not headless and flammability > 5.0 else ""', source_text)
            self.assertIn('var reactive_sound := "blockExplodeFlammable" if reactive_sound_kind == "flammable" else ""', source_text)
            self.assertIn('var reactive_sound_choices := ["blockExplodeExplosive", "blockExplodeExplosiveAlt"] if reactive_sound_kind == "explosive" else []', source_text)
            self.assertIn('var reactive_chance := 0.5 if reactive_sound_kind == "explosive" else 0.0', source_text)
            self.assertIn("var play_power_sound := not headless and power > 2000.0", source_text)
            self.assertIn('var power_sound_kind := "big" if not headless and power > 30000.0 else "normal" if not headless and power > 2000.0 else ""', source_text)
            self.assertIn('var power_sound := "blockExplodeElectricBig" if power_sound_kind == "big" else "blockExplodeElectric" if power_sound_kind == "normal" else ""', source_text)
            self.assertIn('"source_owner": "PortGame.source_building_on_destroyed_item_explosion_state"', source_text)
            self.assertIn('"liquid_source_owner": "PortGame.source_building_on_destroyed_liquid_explosion_state"', source_text)
            self.assertIn('"buffered_power_source_owner": "PortGame.source_building_on_destroyed_buffered_power_state"', source_text)
            self.assertIn('"splash_liquid_source_owner": "PortGame.source_building_on_destroyed_splash_liquid_state"', source_text)
            self.assertIn('"dynamic_explosion_source_owner": "PortGame.source_building_on_destroyed_dynamic_explosion_call_state"', source_text)
            self.assertIn('"rubble_source_owner": "PortGame.source_building_on_destroyed_rubble_state"', source_text)
            self.assertIn('"base_sound_source_owner": "PortGame.source_building_on_destroyed_base_sound_state"', source_text)
            self.assertIn('"reactive_sound_source_owner": "PortGame.source_building_on_destroyed_reactive_sound_state"', source_text)
            self.assertIn('"power_sound_source_owner": "PortGame.source_building_on_destroyed_power_sound_state"', source_text)
            self.assertIn('"comment": "Called when the block is destroyed. The tile is still intact at this stage."', source_text)
            self.assertIn('"method": "public void onDestroyed(){"', source_text)
            self.assertIn('"dynamic_explosion_comment": "//cap explosiveness so fluid tanks/vaults don', source_text)
            self.assertIn('"dynamic_explosion_call": "Damage.dynamicExplosion(x, y, flammability * block.flammabilityScale, explosiveness * 3.5f * block.explosivenessScale, power, tilesize * block.size / 2f, state.rules.damageExplosions, block.destroyEffect, block.baseShake);"', source_text)
            self.assertIn('"rubble_gate": "if(block.createRubble && !floor().solid && !floor().isLiquid){"', source_text)
            self.assertIn('"rubble_effect_call": "Effect.rubble(x, y, block.size);"', source_text)
            self.assertIn('"base_sound_gate": "if(!headless){"', source_text)
            self.assertIn('"base_sound_call": "playDestroySound();"', source_text)
            self.assertIn('"play_destroy_sound_call": "block.destroySound.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);"', source_text)
            self.assertIn('"reactive_explosive_gate": "if(explosiveness > 40f){"', source_text)
            self.assertIn('"reactive_explosive_sound_call": "(Mathf.chance(0.5) ? Sounds.blockExplodeExplosive : Sounds.blockExplodeExplosiveAlt).at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);"', source_text)
            self.assertIn('"reactive_flammable_gate": "}else if(flammability > 5f){"', source_text)
            self.assertIn('"reactive_flammable_sound_call": "Sounds.blockExplodeFlammable.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);"', source_text)
            self.assertIn('"power_sound_big_gate": "if(power > 30000f){"', source_text)
            self.assertIn('"power_sound_big_call": "Sounds.blockExplodeElectricBig.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);"', source_text)
            self.assertIn('"power_sound_normal_gate": "}else if(power > 2000f){"', source_text)
            self.assertIn('"power_sound_normal_call": "Sounds.blockExplodeElectric.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);"', source_text)
            self.assertIn('"base_explosiveness_expr": "float explosiveness = block.baseExplosiveness;"', source_text)
            self.assertIn('"flammability_expr": "float flammability = 0f;"', source_text)
            self.assertIn('"power_expr": "float power = 0f;"', source_text)
            self.assertIn('"has_items_gate": "if(block.hasItems){"', source_text)
            self.assertIn('"items_loop": "for(Item item : content.items()){"', source_text)
            self.assertIn('"amount_expr": "int amount = Math.min(items.get(item), explosionItemCap());"', source_text)
            self.assertIn('"explosiveness_add": "explosiveness += item.explosiveness * amount;"', source_text)
            self.assertIn('"flammability_add": "flammability += item.flammability * amount;"', source_text)
            self.assertIn('"power_add": "power += item.charge * Mathf.pow(amount, 1.1f) * 150f;"', source_text)
            self.assertIn('"has_liquids_gate": "if(block.hasLiquids){"', source_text)
            self.assertIn('"liquid_flammability_add": "flammability += liquids.sum((liquid, amount) -> liquid.flammability * amount / 2f);"', source_text)
            self.assertIn('"liquid_explosiveness_add": "explosiveness += liquids.sum((liquid, amount) -> liquid.explosiveness * amount / 2f);"', source_text)
            self.assertIn('"buffered_power_guard": "if(block.consPower != null && block.consPower.buffered){"', source_text)
            self.assertIn('"buffered_power_add": "power += this.power.status * block.consPower.capacity;"', source_text)
            self.assertIn('"splash_liquid_gate": "if(block.hasLiquids && state.rules.damageExplosions){"', source_text)
            self.assertIn('"splash_liquid_call": "liquids.each(this::splashLiquid);"', source_text)
            self.assertIn('"base_explosiveness": base_explosiveness', source_text)
            self.assertIn('"has_items": has_items', source_text)
            self.assertIn('"item_cap": item_cap', source_text)
            self.assertIn('"has_liquids": has_liquids', source_text)
            self.assertIn('"damage_explosions": damage_explosions', source_text)
            self.assertIn('"splash_liquids": splash_liquids', source_text)
            self.assertIn('"call": splash_call', source_text)
            self.assertIn('"liquid_count": liquid_count', source_text)
            self.assertIn('"liquids": liquids', source_text)
            self.assertIn('"headless": headless', source_text)
            self.assertIn('"destroy_sound": destroy_sound', source_text)
            self.assertIn('"destroy_pitch_min": destroy_pitch_min', source_text)
            self.assertIn('"destroy_pitch_max": destroy_pitch_max', source_text)
            self.assertIn('"destroy_sound_volume": destroy_sound_volume', source_text)
            self.assertIn('"play_destroy_sound": play_destroy_sound', source_text)
            self.assertIn('"sound": base_destroy_sound', source_text)
            self.assertIn('"pitch_min": destroy_pitch_min', source_text)
            self.assertIn('"pitch_max": destroy_pitch_max', source_text)
            self.assertIn('"volume": destroy_sound_volume', source_text)
            self.assertIn('"play_reactive_sound": play_reactive_sound', source_text)
            self.assertIn('"reactive_sound_kind": reactive_sound_kind', source_text)
            self.assertIn('"reactive_sound": reactive_sound', source_text)
            self.assertIn('"reactive_sound_choices": reactive_sound_choices', source_text)
            self.assertIn('"reactive_chance": reactive_chance', source_text)
            self.assertIn('"play_power_sound": play_power_sound', source_text)
            self.assertIn('"power_sound_kind": power_sound_kind', source_text)
            self.assertIn('"power_sound": power_sound', source_text)
            self.assertIn('"dynamic_explosion_x": source_x', source_text)
            self.assertIn('"dynamic_explosion_y": source_y', source_text)
            self.assertIn('"dynamic_explosion_flammability": dynamic_explosion_flammability', source_text)
            self.assertIn('"dynamic_explosion_explosiveness": dynamic_explosion_explosiveness', source_text)
            self.assertIn('"dynamic_explosion_power": power', source_text)
            self.assertIn('"dynamic_explosion_radius": dynamic_explosion_radius', source_text)
            self.assertIn('"dynamic_explosion_damage_explosions": damage_explosions', source_text)
            self.assertIn('"dynamic_explosion_effect": destroy_effect', source_text)
            self.assertIn('"dynamic_explosion_shake": base_shake', source_text)
            self.assertIn('"rubble_create_rubble": should_create_rubble', source_text)
            self.assertIn('"rubble_call": rubble_call', source_text)
            self.assertIn('"rubble_x": source_x', source_text)
            self.assertIn('"rubble_y": source_y', source_text)
            self.assertIn('"rubble_size": source_block_size if should_create_rubble else 0', source_text)
            self.assertIn('"current_power": current_power', source_text)
            self.assertIn('"has_cons_power": has_cons_power', source_text)
            self.assertIn('"cons_power_buffered": cons_power_buffered', source_text)
            self.assertIn('"power_status": power_status', source_text)
            self.assertIn('"cons_power_capacity": cons_power_capacity', source_text)
            self.assertIn('"apply_buffered_power": apply_buffered_power', source_text)
            self.assertIn('"buffered_power_contribution": buffered_power_contribution', source_text)
            self.assertIn('"explosiveness": explosiveness', source_text)
            self.assertIn('"flammability": flammability', source_text)
            self.assertIn('"power": power', source_text)

    def test_emit_bridges_building_comp_play_destroy_sound_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void playDestroySound(){
        block.destroySound.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_playDestroySound_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var destroy_sound := str(_args[0] if _args.size() > 0 else "")', source_text)
            self.assertIn("var destroy_pitch_min := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var destroy_pitch_max := float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var destroy_sound_volume := float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_on_destroyed_base_sound_state"', source_text)
            self.assertIn('"method": "public void playDestroySound(){"', source_text)
            self.assertIn('"play_destroy_sound_call": "block.destroySound.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);"', source_text)
            self.assertIn('"destroy_sound": destroy_sound', source_text)
            self.assertIn('"sound": destroy_sound', source_text)
            self.assertIn('"pitch_min": destroy_pitch_min', source_text)
            self.assertIn('"pitch_max": destroy_pitch_max', source_text)
            self.assertIn('"volume": destroy_sound_volume', source_text)

    def test_emit_bridges_building_comp_get_display_name_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public String getDisplayName(){
        //derelict team icon currently doesn't display
        return team == Team.derelict ?
            block.localizedName + "\\n" + Core.bundle.get("block.derelict") :
            block.localizedName + (team == player.team() || team.emoji.isEmpty() ? "" : " " + team.emoji);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_getDisplayName_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var localized_name := str(_args[0] if _args.size() > 0 else "")', source_text)
            self.assertIn("var team_is_derelict := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var team_is_player := bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn('var team_emoji := str(_args[3] if _args.size() > 3 else "")', source_text)
            self.assertIn('var derelict_label := str(_args[4] if _args.size() > 4 else "")', source_text)
            self.assertIn('"source_owner": "PortGame.source_building_display_name_state"', source_text)
            self.assertIn('"method": "public String getDisplayName(){"', source_text)
            self.assertIn("\"derelict_comment\": \"//derelict team icon currently doesn't display\"", source_text)
            self.assertIn('"derelict_return": "block.localizedName + \\"\\\\n\\" + Core.bundle.get(\\"block.derelict\\")"', source_text)
            self.assertIn('"regular_return": "block.localizedName + (team == player.team() || team.emoji.isEmpty() ? \\"\\" : \\" \\" + team.emoji)"', source_text)
            self.assertIn('"display_name": display_name', source_text)

    def test_emit_bridges_building_comp_flow_items_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** @return the item module to use for flow rate calculations */
    public ItemModule flowItems(){
        return items;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_flowItems_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var items_module: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_flow_items_state"', source_text)
            self.assertIn('"comment": "/** @return the item module to use for flow rate calculations */"', source_text)
            self.assertIn('"method": "public ItemModule flowItems(){"', source_text)
            self.assertIn('"return_expr": "return items;"', source_text)
            self.assertIn('"items_module": items_module', source_text)
            self.assertIn('"flow_items": items_module', source_text)

    def test_emit_bridges_building_comp_display_to_source_ui_gates_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void display(Table table){
        //display the block stuff
        //TODO duplicated code?
        table.table(t -> {
            t.left();
            t.add(new Image(block.getDisplayIcon(tile))).scaling(Scaling.fit).size(8 * 4);
            t.labelWrap(block.getDisplayName(tile)).left().width(190f).padLeft(5);
        }).growX().left();
        table.row();
        //only display everything else if the team is the same
        if(team == player.team()){
            table.table(bars -> {
                bars.defaults().growX().height(18f).pad(4);
                displayBars(bars);
            }).growX();
            table.row();
            table.table(this::displayConsumption).growX();
            boolean displayFlow = (block.category == Category.distribution || block.category == Category.liquid) && block.displayFlow;
            if(displayFlow){
            }
            if(net.active() && lastAccessed != null){
                table.row();
                table.add(Core.bundle.format("lastaccessed", lastAccessed)).growX().wrap().left();
            }
            table.marginBottom(-5);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_display_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var block_ui_icon: Variant = _args[0] if _args.size() > 0 else null', source_text)
            self.assertIn('var localized_name := str(_args[1] if _args.size() > 1 else "")', source_text)
            self.assertIn("var team_is_player := bool(_args[3] if _args.size() > 3 else false)", source_text)
            self.assertIn('var block_category := str(_args[6] if _args.size() > 6 else "")', source_text)
            self.assertIn("var icon_state := {", source_text)
            self.assertIn('"icon_source_owner": "PortGame.source_building_display_icon_state"', source_text)
            self.assertIn('"name_source_owner": "PortGame.source_building_display_name_state"', source_text)
            self.assertIn('"source_owner": "PortGame.source_building_display_ui_gates_state"', source_text)
            self.assertIn('"method": "public void display(Table table){"', source_text)
            self.assertIn('"header_icon_call": "t.add(new Image(block.getDisplayIcon(tile))).scaling(Scaling.fit).size(8 * 4);"', source_text)
            self.assertIn('"header_name_call": "t.labelWrap(block.getDisplayName(tile)).left().width(190f).padLeft(5);"', source_text)
            self.assertIn('"same_team_gate": "if(team == player.team()){"', source_text)
            self.assertIn('"display_flow_formula": "boolean displayFlow = (block.category == Category.distribution || block.category == Category.liquid) && block.displayFlow;"', source_text)
            self.assertIn('"last_accessed_gate": "if(net.active() && lastAccessed != null){"', source_text)
            self.assertIn('"icon": icon_state', source_text)
            self.assertIn('"display_name": display_name', source_text)
            self.assertIn('"ui_gates": ui_gates', source_text)

    def test_emit_bridges_building_comp_display_consumption_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void displayConsumption(Table table){
        table.left();
        for(Consume cons : block.consumers){
            if(cons.optional && cons.booster) continue;
            cons.build(self(), table);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_displayConsumption_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var consumers: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []", source_text)
            self.assertIn("var self_state: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var built_consumers: Array = []", source_text)
            self.assertIn("var skipped_consumers: Array = []", source_text)
            self.assertIn("var optional_value := bool(cons.get(\"optional\", false))", source_text)
            self.assertIn("var booster_value := bool(cons.get(\"booster\", false))", source_text)
            self.assertIn("if optional_value and booster_value:", source_text)
            self.assertIn("skipped_consumers.append(cons)", source_text)
            self.assertIn("built_consumers.append({\"consumer\": cons, \"self_state\": self_state})", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_display_consumption_state"', source_text)
            self.assertIn('"method": "public void displayConsumption(Table table){"', source_text)
            self.assertIn('"table_left_call": "table.left();"', source_text)
            self.assertIn('"consumers_loop": "for(Consume cons : block.consumers){"', source_text)
            self.assertIn('"optional_booster_skip": "if(cons.optional && cons.booster) continue;"', source_text)
            self.assertIn('"build_call": "cons.build(self(), table);"', source_text)

    def test_emit_bridges_building_comp_display_bars_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void displayBars(Table table){
        for(Func<Building, Bar> bar : block.listBars()){
            var result = bar.get(self());
            if(result == null) continue;
            table.add(result).growX();
            table.row();
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_displayBars_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var bar_results: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []", source_text)
            self.assertIn("var added_bars: Array = []", source_text)
            self.assertIn("var skipped_bars: Array = []", source_text)
            self.assertIn("for result in bar_results:", source_text)
            self.assertIn("if result == null:", source_text)
            self.assertIn("skipped_bars.append(result)", source_text)
            self.assertIn("added_bars.append(result)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_display_bars_state"', source_text)
            self.assertIn('"method": "public void displayBars(Table table){"', source_text)
            self.assertIn('"bars_loop": "for(Func<Building, Bar> bar : block.listBars()){"', source_text)
            self.assertIn('"get_result": "var result = bar.get(self());"', source_text)
            self.assertIn('"null_skip": "if(result == null) continue;"', source_text)
            self.assertIn('"add_call": "table.add(result).growX();"', source_text)
            self.assertIn('"row_call": "table.row();"', source_text)

    def test_emit_bridges_building_comp_get_cursor_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Returns whether a hand cursor should be shown over this block. */
    public Cursor getCursor(){
        return block.configurable && interactable(player.team()) ? SystemCursor.hand : SystemCursor.arrow;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_getCursor_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var block_configurable := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var interactable_player_team := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn('var cursor := "hand" if block_configurable and interactable_player_team else "arrow"', source_text)
            self.assertIn('"source_owner": "PortGame.source_building_cursor_state"', source_text)
            self.assertIn('"comment": "/** Returns whether a hand cursor should be shown over this block. */"', source_text)
            self.assertIn('"method": "public Cursor getCursor(){"', source_text)
            self.assertIn('"return_expr": "return block.configurable && interactable(player.team()) ? SystemCursor.hand : SystemCursor.arrow;"', source_text)
            self.assertIn('"block_configurable": block_configurable', source_text)
            self.assertIn('"interactable_player_team": interactable_player_team', source_text)
            self.assertIn('"cursor": cursor', source_text)

    def test_emit_bridges_building_comp_on_configure_tapped_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public boolean onConfigureTapped(float x, float y){
        return false;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_onConfigureTapped_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var x := float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var y := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_on_configure_tapped_state"', source_text)
            self.assertIn('"method": "public boolean onConfigureTapped(float x, float y){"', source_text)
            self.assertIn('"return_false": "return false;"', source_text)
            self.assertIn('"x": x', source_text)
            self.assertIn('"y": y', source_text)
            self.assertIn('"consumed": false', source_text)

    def test_emit_bridges_building_comp_on_configure_closed_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /**
     * Called when this block's config menu is closed.
     */
    public void onConfigureClosed(){}
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_onConfigureClosed_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_on_configure_closed_state"', source_text)
            self.assertIn('"method": "public void onConfigureClosed(){}"', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_building_comp_should_show_configure_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Returns whether this config menu should show when the specified player taps it. */
    public boolean shouldShowConfigure(Player player){
        return true;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_shouldShowConfigure_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var player: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_should_show_configure_state"', source_text)
            self.assertIn('"comment": "/** Returns whether this config menu should show when the specified player taps it. */"', source_text)
            self.assertIn('"method": "public boolean shouldShowConfigure(Player player){"', source_text)
            self.assertIn('"return_true": "return true;"', source_text)
            self.assertIn('"player": player', source_text)
            self.assertIn('"should_show": true', source_text)

    def test_emit_bridges_building_comp_should_hide_configure_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Whether this configuration should be hidden now. Called every frame the config is open. */
    public boolean shouldHideConfigure(Player player){
        return false;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_shouldHideConfigure_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var player: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_should_hide_configure_state"', source_text)
            self.assertIn('"comment": "/** Whether this configuration should be hidden now. Called every frame the config is open. */"', source_text)
            self.assertIn('"method": "public boolean shouldHideConfigure(Player player){"', source_text)
            self.assertIn('"return_false": "return false;"', source_text)
            self.assertIn('"player": player', source_text)
            self.assertIn('"should_hide": false', source_text)

    def test_emit_bridges_building_comp_draw_configure_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void drawConfigure(){
        Draw.color(Pal.accent);
        Lines.stroke(1f);
        Lines.square(x, y, block.size * tilesize / 2f + 1f);
        Draw.reset();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawConfigure_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var source_x := float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var source_y := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var block_size_value := int(_args[2] if _args.size() > 2 else 0)", source_text)
            self.assertIn("var source_tilesize := float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var half_extent := float(block_size_value) * source_tilesize / 2.0", source_text)
            self.assertIn("var radius_offset := 1.0", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_draw_configure_state"', source_text)
            self.assertIn('"method": "public void drawConfigure(){"', source_text)
            self.assertIn('"color": "Pal.accent"', source_text)
            self.assertIn('"stroke": 1.0', source_text)
            self.assertIn('"shape": "square"', source_text)
            self.assertIn('"square": "Lines.square(x, y, block.size * tilesize / 2f + 1f);"', source_text)
            self.assertIn('"x": source_x', source_text)
            self.assertIn('"y": source_y', source_text)
            self.assertIn('"halfExtent": half_extent', source_text)
            self.assertIn('"radiusOffset": radius_offset', source_text)
            self.assertIn('"radius": half_extent + radius_offset', source_text)
            self.assertIn('"reset": true', source_text)

    def test_emit_bridges_building_comp_check_solid_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public boolean checkSolid(){
        return false;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_checkSolid_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_check_solid_state"', source_text)
            self.assertIn('"method": "public boolean checkSolid(){"', source_text)
            self.assertIn('"checkSolid": false', source_text)

    def test_emit_bridges_building_comp_handle_damage_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public float handleDamage(float amount){
        return amount;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_handleDamage_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var amount := float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_handle_damage_state"', source_text)
            self.assertIn('"method": "public float handleDamage(float amount){"', source_text)
            self.assertIn('"amount": amount', source_text)
            self.assertIn('"handled_damage": amount', source_text)

    def test_emit_bridges_building_comp_absorb_lasers_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public boolean absorbLasers(){
        return block.absorbLasers;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_absorbLasers_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var block_absorb_lasers := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_absorb_lasers_state"', source_text)
            self.assertIn('"blockAbsorbLasers": block_absorb_lasers', source_text)
            self.assertIn('"defaultAbsorbLasers": false', source_text)
            self.assertIn('"absorbLasers": block_absorb_lasers', source_text)

    def test_emit_bridges_building_comp_is_insulated_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public boolean isInsulated(){
        return block.insulated;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_isInsulated_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var block_insulated := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_is_insulated_state"', source_text)
            self.assertIn('"method": "public boolean isInsulated(){"', source_text)
            self.assertIn('"block_insulated": block_insulated', source_text)
            self.assertIn('"insulated": block_insulated', source_text)

    def test_emit_bridges_building_comp_collide_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public boolean collide(Bullet other){
        return true;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_collide_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var other: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_collide_state"', source_text)
            self.assertIn('"method": "public boolean collide(Bullet other){"', source_text)
            self.assertIn('"other": other', source_text)
            self.assertIn('"collide": true', source_text)

    def test_emit_bridges_building_comp_collision_to_source_damage_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public boolean collision(Bullet other){
        boolean wasDead = health <= 0;
        BulletType t = other.type;
        float damage = other.type.buildingDamage(other);
        if(!t.pierceArmor){
            damage = Damage.applyArmor(damage, block.armor * t.armorMultiplier * t.blockArmorMultiplier);
        }
        damage(other, other.team, damage);
        return true;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_collision_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var current_health := float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var bullet_building_damage := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var block_armor := float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var bullet_pierce_armor := bool(_args[3] if _args.size() > 3 else false)", source_text)
            self.assertIn("var bullet_armor_multiplier := float(_args[4] if _args.size() > 4 else 0.0)", source_text)
            self.assertIn("var bullet_block_armor_multiplier := float(_args[5] if _args.size() > 5 else 0.0)", source_text)
            self.assertIn("var armor := block_armor * bullet_armor_multiplier * bullet_block_armor_multiplier", source_text)
            self.assertIn("if not bullet_pierce_armor:", source_text)
            self.assertIn("damage = max(damage - armor, 0.1 * damage)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_collision_damage_state"', source_text)
            self.assertIn('"method": "public boolean collision(Bullet other){"', source_text)
            self.assertIn('"was_dead": current_health <= 0.0', source_text)
            self.assertIn('"raw_damage": bullet_building_damage', source_text)
            self.assertIn('"removed": true', source_text)

    def test_emit_bridges_building_comp_damage_delegate_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Used to handle damage from splash damage for certain types of blocks. */
    public void damage(@Nullable Team source, float damage){
        damage(damage);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_damage_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var source_team: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var damage_amount := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_damage_delegate_state"', source_text)
            self.assertIn('"comment": "/** Used to handle damage from splash damage for certain types of blocks. */"', source_text)
            self.assertIn('"method": "public void damage(@Nullable Team source, float damage){"', source_text)
            self.assertIn('"source_team": source_team', source_text)
            self.assertIn('"damage": damage_amount', source_text)
            self.assertIn('"delegates_to_damage": true', source_text)

    def test_emit_bridges_building_comp_bullet_damage_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Handles splash damage with a bullet source. */
    public void damage(Bullet bullet, Team source, float damage){
        damage(source, damage);
        Events.fire(bulletDamageEvent.set(self(), bullet));
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_damage_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var bullet: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var source_team: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var damage_amount := float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_bullet_damage_state"', source_text)
            self.assertIn('"comment": "/** Handles splash damage with a bullet source. */"', source_text)
            self.assertIn('"method": "public void damage(Bullet bullet, Team source, float damage){"', source_text)
            self.assertIn('"bullet": bullet', source_text)
            self.assertIn('"source_team": source_team', source_text)
            self.assertIn('"damage": damage_amount', source_text)
            self.assertIn('"delegates_to_source_damage": true', source_text)
            self.assertIn('"fires_bullet_damage_event": true', source_text)

    def test_emit_bridges_building_comp_change_team_delegate_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Changes this building's team in a safe manner. */
    public void changeTeam(Team next){
        changeTeam(next, true);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_changeTeam_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var next_team: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_change_team_delegate_state"', source_text)
            self.assertIn('"comment": "/** Changes this building\'s team in a safe manner. */"', source_text)
            self.assertIn('"method": "public void changeTeam(Team next){"', source_text)
            self.assertIn('"next_team": next_team', source_text)
            self.assertIn('"delegates_to_change_team": true', source_text)
            self.assertIn('"update_power": true', source_text)

    def test_emit_bridges_building_comp_change_team_initial_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Changes this building's team in a safe manner. */
    public void changeTeam(Team next, boolean updatePower){
        if(this.team == next) return;
        if(block.forceTeam != null) team = block.forceTeam;
        Team last = this.team;
        if(last == next) return;
        boolean was = isValid();
        if(was) indexer.removeIndex(tile);
        this.team = next;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_changeTeam_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var current_team: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var next_team: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var force_team: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("var was_valid := bool(_args[3] if _args.size() > 3 else false)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_change_team_initial_state"', source_text)
            self.assertIn('"comment": "/** Changes this building\'s team in a safe manner. */"', source_text)
            self.assertIn('"method": "public void changeTeam(Team next, boolean updatePower){"', source_text)
            self.assertIn('"team": next_team', source_text)
            self.assertIn('"remove_index": was_valid', source_text)
            self.assertIn('"assign_next": true', source_text)

    def test_emit_bridges_building_comp_change_team_power_proximity_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void changeTeam(Team next, boolean updatePower){
        if(this.team == next) return;
        Team last = this.team;
        boolean was = isValid();
        this.team = next;
        if(power != null && updatePower){
            var oldGraph = power.graph;
            for(var other : proximity){
                if(other != null && other.team != team && other.power != null && other.power.graph == oldGraph){
                    new PowerGraph().reflow(other);
                }
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_changeTeam_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var power_present := bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("var update_power := bool(_args[5] if _args.size() > 5 else false)", source_text)
            self.assertIn("var old_graph: Variant = _args[6] if _args.size() > 6 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_change_team_power_proximity_state"', source_text)
            self.assertIn('"gate": "if(power != null && updatePower){"', source_text)
            self.assertIn('"old_graph": old_graph', source_text)
            self.assertIn('"team": next_team', source_text)
            self.assertIn('"proximity_reflow": power_present and update_power', source_text)
            self.assertIn('result["power_proximity"] = power_proximity', source_text)

    def test_emit_bridges_building_comp_change_team_power_links_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void changeTeam(Team next, boolean updatePower){
        if(this.team == next) return;
        Team last = this.team;
        boolean was = isValid();
        this.team = next;
        if(power != null && updatePower){
            var oldGraph = power.graph;
            for(int i = 0; i < power.links.size; i++){
                var other = world.build(power.links.items[i]);
                if(other != null && other.team != team && other.power != null && other.power.graph == oldGraph){
                    power.links.removeIndex(i);
                    other.power.links.removeValue(pos());
                    new PowerGraph().reflow(other);
                    i --;
                }
            }
            new PowerGraph().reflow(self());
            updatePowerGraph();
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_changeTeam_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var link_count := int(_args[7] if _args.size() > 7 else 0)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_change_team_power_links_state"', source_text)
            self.assertIn('"loop": "for(int i = 0; i < power.links.size; i++){"', source_text)
            self.assertIn('"old_graph": old_graph', source_text)
            self.assertIn('"team": next_team', source_text)
            self.assertIn('"link_count": link_count if power_present and update_power else 0', source_text)
            self.assertIn('"remove_index": power_present and update_power and link_count > 0', source_text)
            self.assertIn('"reflow_self": power_present and update_power and link_count > 0', source_text)
            self.assertIn('"update_power_graph": power_present and update_power and link_count > 0', source_text)
            self.assertIn('result["power_links"] = power_links', source_text)

    def test_emit_bridges_building_comp_change_team_final_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void changeTeam(Team next, boolean updatePower){
        if(this.team == next) return;
        if(block.forceTeam != null) team = block.forceTeam;
        Team last = this.team;
        if(last == next) return;
        boolean was = isValid();
        this.team = next;
        if(was){
            indexer.addIndex(tile);
            Events.fire(teamChangeEvent.set(last, self()));
        }
        checkAllowUpdate();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_changeTeam_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_change_team_final_state"', source_text)
            self.assertIn('"was": was_valid', source_text)
            self.assertIn('"add_index": was_valid', source_text)
            self.assertIn('"team_change_event": was_valid', source_text)
            self.assertIn('"event_last": last_team', source_text)
            self.assertIn('"check_allow_update": true', source_text)
            self.assertIn('result["final"] = final_state', source_text)

    def test_emit_bridges_building_comp_can_pickup_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public boolean canPickup(){
        return block.canPickup;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_canPickup_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var block_can_pickup := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_can_pickup_state"', source_text)
            self.assertIn('"method": "public boolean canPickup(){"', source_text)
            self.assertIn('"blockCanPickup": block_can_pickup', source_text)
            self.assertIn('"canPickup": block_can_pickup', source_text)

    def test_emit_bridges_building_comp_picked_up_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Called right before this building is picked up. */
    public void pickedUp(){

    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_pickedUp_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var previous_state: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_picked_up_state"', source_text)
            self.assertIn('"method": "public void pickedUp(){"', source_text)
            self.assertIn('"comment": "Called right before this building is picked up."', source_text)
            self.assertIn('"no_op": true', source_text)
            self.assertIn('"previous_state": previous_state', source_text)

    def test_emit_bridges_building_comp_after_picked_up_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Called right after this building is picked up. */
    public void afterPickedUp(){
        if(power != null){
            power.graph = new PowerGraph();
            power.links.clear();
            if(block.consPower != null && !block.consPower.buffered){
                power.status = 0f;
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_afterPickedUp_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var power_present := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var has_cons_power := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var cons_power_buffered := bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("var current_status := float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var status := 0.0 if power_present and has_cons_power and not cons_power_buffered else current_status", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_after_picked_up_state"', source_text)
            self.assertIn('"power_present": power_present', source_text)
            self.assertIn('"new_power_graph": power_present', source_text)
            self.assertIn('"clear_links": power_present', source_text)
            self.assertIn('"status": status', source_text)

    def test_emit_bridges_building_comp_remove_from_proximity_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void removeFromProximity(){
        onProximityRemoved();
        tmpTiles.clear();

        Point2[] nearby = Edges.getEdges(block.size);
        for(Point2 point : nearby){
            Building other = world.build(tile.x + point.x, tile.y + point.y);
            if(other != null){
                tmpTiles.add(other);
            }
        }

        for(Building other : tmpTiles){
            other.proximity.remove(self(), true);
            other.onProximityUpdate();
        }
        proximity.clear();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_removeFromProximity_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var nearby_count := int(_args[0] if _args.size() > 0 else 0)", source_text)
            self.assertIn("var removable_count := int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("var queued_removals := clampi(removable_count, 0, nearby_count)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_remove_from_proximity_state"', source_text)
            self.assertIn('"method": "public void removeFromProximity(){"', source_text)
            self.assertIn('"on_proximity_removed": true', source_text)
            self.assertIn('"tmp_tiles_cleared": true', source_text)
            self.assertIn('"nearby_count": nearby_count', source_text)
            self.assertIn('"queued_removals": queued_removals', source_text)
            self.assertIn('"proximity_updates": queued_removals', source_text)
            self.assertIn('"proximity_cleared": true', source_text)

    def test_emit_bridges_building_comp_update_proximity_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void updateProximity(){
        tmpTiles.clear();
        proximity.clear();

        Point2[] nearby = Edges.getEdges(block.size);
        for(Point2 point : nearby){
            Building other = world.build(tile.x + point.x, tile.y + point.y);

            if(other == null || other.team != team) continue;

            other.proximity.addUnique(self());

            tmpTiles.add(other);
        }

        for(Building tile : tmpTiles){
            proximity.add(tile);
        }

        onProximityAdded();
        onProximityUpdate();

        for(Building other : tmpTiles){
            other.onProximityUpdate();
        }

        if(!headless && block.drawCached) recache();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_updateProximity_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var nearby_count := int(_args[0] if _args.size() > 0 else 0)", source_text)
            self.assertIn("var same_team_count := int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("var headless := bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("var draw_cached := bool(_args[3] if _args.size() > 3 else false)", source_text)
            self.assertIn("var same_team_clamped := clampi(same_team_count, 0, nearby_count)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_update_proximity_state"', source_text)
            self.assertIn('"tmp_tiles_cleared": true', source_text)
            self.assertIn('"proximity_cleared": true', source_text)
            self.assertIn('"nearby_count": nearby_count', source_text)
            self.assertIn('"same_team_count": same_team_clamped', source_text)
            self.assertIn('"add_unique_calls": same_team_clamped', source_text)
            self.assertIn('"on_proximity_added": true', source_text)
            self.assertIn('"self_proximity_update": true', source_text)
            self.assertIn('"other_proximity_updates": same_team_clamped', source_text)
            self.assertIn('"recache": (not headless) and draw_cached', source_text)

    def test_emit_bridges_building_comp_on_nearby_build_added_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void onNearbyBuildAdded(Building other){}
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_onNearbyBuildAdded_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var other_state: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_on_nearby_build_added_state"', source_text)
            self.assertIn('"method": "public void onNearbyBuildAdded(Building other){}"', source_text)
            self.assertIn('"no_op": true', source_text)
            self.assertIn('"other_state": other_state', source_text)

    def test_emit_bridges_building_comp_consume_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void consume(){
        for(Consume cons : block.consumers){
            cons.trigger(self());
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_consume_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var consumers: Array = _args[0] if _args.size() > 0 else []", source_text)
            self.assertIn("var self_state: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var triggered: Array = []", source_text)
            self.assertIn("for consumer in consumers:", source_text)
            self.assertIn('triggered.append({"consumer": consumer, "self": self_state})', source_text)
            self.assertIn('"source_owner": "PortGame.source_building_consume_state"', source_text)
            self.assertIn('"triggered": triggered', source_text)

    def test_emit_bridges_building_comp_can_consume_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public boolean canConsume(){
        return potentialEfficiency > 0;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_canConsume_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var potential_efficiency := float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var can_consume := potential_efficiency > 0.0", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_can_consume_state"', source_text)
            self.assertIn('"method": "public boolean canConsume(){"', source_text)
            self.assertIn('"potentialEfficiency": potential_efficiency', source_text)
            self.assertIn('"canConsume": can_consume', source_text)

    def test_emit_bridges_building_comp_delta_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Scaled delta. */
    public float delta(){
        return Time.delta * timeScale;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_delta_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var source_delta := float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var time_scale := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var delta := source_delta * time_scale", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_delta"', source_text)
            self.assertIn('"comment": "/** Scaled delta. */"', source_text)
            self.assertIn('"method": "public float delta(){"', source_text)
            self.assertIn('"source_delta": source_delta', source_text)
            self.assertIn('"time_scale": time_scale', source_text)
            self.assertIn('"delta": delta', source_text)

    def test_emit_bridges_building_comp_edelta_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public float delta(){
        return Time.delta * timeScale;
    }
    public float edelta(){
        return efficiency * delta();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_edelta_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var source_delta := float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var time_scale := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var efficiency := float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var delta_result = java_method_delta_0([source_delta, time_scale])", source_text)
            self.assertIn('var delta_call := float(delta_result.get("delta", 0.0))', source_text)
            self.assertIn("var edelta := efficiency * delta_call", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_edelta"', source_text)
            self.assertIn('"method": "public float edelta(){"', source_text)
            self.assertIn('"delta_call": delta_call', source_text)
            self.assertIn('"efficiency": efficiency', source_text)
            self.assertIn('"source_delta": source_delta', source_text)
            self.assertIn('"time_scale": time_scale', source_text)
            self.assertIn('"edelta": edelta', source_text)

    def test_emit_bridges_building_comp_update_efficiency_multiplier_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Called after efficiency is updated but before consumers are updated. Use to apply your own multiplier. */
    public void updateEfficiencyMultiplier(){
        float scale = efficiencyScale();
        efficiency *= scale;
        optionalEfficiency *= scale;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_updateEfficiencyMultiplier_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var efficiency := float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var optional_efficiency := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var efficiency_scale := float(_args[2] if _args.size() > 2 else 1.0)", source_text)
            self.assertIn("var scale := efficiency_scale", source_text)
            self.assertIn("efficiency *= scale", source_text)
            self.assertIn("optional_efficiency *= scale", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_update_efficiency_multiplier_state"', source_text)
            self.assertIn('"comment": "/** Called after efficiency is updated but before consumers are updated. Use to apply your own multiplier. */"', source_text)
            self.assertIn('"method": "public void updateEfficiencyMultiplier(){"', source_text)
            self.assertIn('"scale": scale', source_text)
            self.assertIn('"efficiency": efficiency', source_text)
            self.assertIn('"optional_efficiency": optional_efficiency', source_text)
            self.assertIn('"efficiency_scale": efficiency_scale', source_text)

    def test_emit_bridges_building_comp_efficiency_scale_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    /** Calculate your own efficiency multiplier. By default, this is applied in updateEfficiencyMultiplier. */
    public float efficiencyScale(){
        return 1f;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_efficiencyScale_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_efficiency_scale_state"', source_text)
            self.assertIn('"comment": "/** Calculate your own efficiency multiplier. By default, this is applied in updateEfficiencyMultiplier. */"', source_text)
            self.assertIn('"method": "public float efficiencyScale(){"', source_text)
            self.assertIn('"efficiency_scale": 1.0', source_text)

    def test_emit_bridges_building_comp_update_consumption_initial_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void updateEfficiencyMultiplier(){
        float scale = efficiencyScale();
        efficiency *= scale;
        optionalEfficiency *= scale;
    }
    public void updateConsumption(){
        //everything is valid when cheating
        if(!block.hasConsumers || cheating()){
            potentialEfficiency = enabled && productionValid() ? 1f : 0f;
            efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;
            shouldConsumePower = true;
            updateEfficiencyMultiplier();
            return;
        }

        //disabled -> nothing works
        if(!enabled){
            potentialEfficiency = efficiency = optionalEfficiency = 0f;
            shouldConsumePower = false;
            return;
        }

        boolean update = shouldConsume() && productionValid();

        float minEfficiency = 1f;

        //assume efficiency is 1 for the calculations below
        efficiency = optionalEfficiency = 1f;
        shouldConsumePower = true;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_updateConsumption_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var has_consumers := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var cheating := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var enabled_state := bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("var production_valid := bool(_args[3] if _args.size() > 3 else false)", source_text)
            self.assertIn("var should_consume_state := bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("var efficiency_scale := float(_args[5] if _args.size() > 5 else 1.0)", source_text)
            self.assertIn("if has_consumers and not cheating:", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_building_update_consumption_setup_state"', source_text)
            self.assertIn("potential_efficiency = 1.0 if enabled_state and production_valid else 0.0", source_text)
            self.assertIn("efficiency = potential_efficiency if should_consume_state else 0.0", source_text)
            self.assertIn("var multiplied = java_method_updateEfficiencyMultiplier_0([efficiency, efficiency, efficiency_scale])", source_text)
            self.assertIn('var final_efficiency := float(multiplied.get("efficiency", efficiency))', source_text)
            self.assertIn('var final_optional_efficiency := float(multiplied.get("optional_efficiency", efficiency))', source_text)
            self.assertIn('"source_owner": "PortGame.source_building_update_consumption_initial_state"', source_text)
            self.assertIn('"method": "public void updateConsumption(){"', source_text)
            self.assertIn('"comment": "//everything is valid when cheating"', source_text)
            self.assertIn('"guard": "if(!block.hasConsumers || cheating()){"', source_text)
            self.assertIn('"potential_efficiency": potential_efficiency', source_text)
            self.assertIn('"efficiency": final_efficiency', source_text)
            self.assertIn('"optional_efficiency": final_optional_efficiency', source_text)
            self.assertIn('"should_consume_power": true', source_text)
            self.assertIn('"returned": true', source_text)

    def test_emit_bridges_building_comp_update_consumption_disabled_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void updateEfficiencyMultiplier(){
        float scale = efficiencyScale();
        efficiency *= scale;
        optionalEfficiency *= scale;
    }
    public void updateConsumption(){
        //everything is valid when cheating
        if(!block.hasConsumers || cheating()){
            potentialEfficiency = enabled && productionValid() ? 1f : 0f;
            efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;
            shouldConsumePower = true;
            updateEfficiencyMultiplier();
            return;
        }

        //disabled -> nothing works
        if(!enabled){
            potentialEfficiency = efficiency = optionalEfficiency = 0f;
            shouldConsumePower = false;
            return;
        }

        boolean update = shouldConsume() && productionValid();

        float minEfficiency = 1f;

        //assume efficiency is 1 for the calculations below
        efficiency = optionalEfficiency = 1f;
        shouldConsumePower = true;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_updateConsumption_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("if not enabled_state:", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_update_consumption_disabled_state"', source_text)
            self.assertIn('"comment": "//disabled -> nothing works"', source_text)
            self.assertIn('"guard": "if(!enabled){"', source_text)
            self.assertIn('"efficiencies": "potentialEfficiency = efficiency = optionalEfficiency = 0f;"', source_text)
            self.assertIn('"power": "shouldConsumePower = false;"', source_text)
            self.assertIn('"potential_efficiency": 0.0', source_text)
            self.assertIn('"efficiency": 0.0', source_text)
            self.assertIn('"optional_efficiency": 0.0', source_text)
            self.assertIn('"should_consume_power": false', source_text)
            self.assertIn('"returned": true', source_text)

    def test_emit_bridges_building_comp_update_consumption_setup_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void updateEfficiencyMultiplier(){
        float scale = efficiencyScale();
        efficiency *= scale;
        optionalEfficiency *= scale;
    }
    public void updateConsumption(){
        //everything is valid when cheating
        if(!block.hasConsumers || cheating()){
            potentialEfficiency = enabled && productionValid() ? 1f : 0f;
            efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;
            shouldConsumePower = true;
            updateEfficiencyMultiplier();
            return;
        }

        //disabled -> nothing works
        if(!enabled){
            potentialEfficiency = efficiency = optionalEfficiency = 0f;
            shouldConsumePower = false;
            return;
        }

        boolean update = shouldConsume() && productionValid();

        float minEfficiency = 1f;

        //assume efficiency is 1 for the calculations below
        efficiency = optionalEfficiency = 1f;
        shouldConsumePower = true;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_updateConsumption_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var update := should_consume_state and production_valid", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_update_consumption_setup_state"', source_text)
            self.assertIn('"update_expr": "boolean update = shouldConsume() && productionValid();"', source_text)
            self.assertIn('"min": "float minEfficiency = 1f;"', source_text)
            self.assertIn('"comment": "//assume efficiency is 1 for the calculations below"', source_text)
            self.assertIn('"efficiencies": "efficiency = optionalEfficiency = 1f;"', source_text)
            self.assertIn('"power": "shouldConsumePower = true;"', source_text)
            self.assertIn('"update": update', source_text)
            self.assertIn('"min_efficiency": 1.0', source_text)
            self.assertIn('"efficiency": 1.0', source_text)
            self.assertIn('"optional_efficiency": 1.0', source_text)
            self.assertIn('"should_consume_power": true', source_text)

    def test_emit_bridges_building_comp_update_consumption_non_optional_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void updateEfficiencyMultiplier(){
        float scale = efficiencyScale();
        efficiency *= scale;
        optionalEfficiency *= scale;
    }
    public void updateConsumption(){
        //everything is valid when cheating
        if(!block.hasConsumers || cheating()){
            potentialEfficiency = enabled && productionValid() ? 1f : 0f;
            efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;
            shouldConsumePower = true;
            updateEfficiencyMultiplier();
            return;
        }

        //disabled -> nothing works
        if(!enabled){
            potentialEfficiency = efficiency = optionalEfficiency = 0f;
            shouldConsumePower = false;
            return;
        }

        boolean update = shouldConsume() && productionValid();

        float minEfficiency = 1f;

        //assume efficiency is 1 for the calculations below
        efficiency = optionalEfficiency = 1f;
        shouldConsumePower = true;

        //first pass: get the minimum efficiency of any consumer
        for(var cons : block.nonOptionalConsumers){
            float result = cons.efficiency(self());

            if(cons != block.consPower && result <= 0.0000001f){
                shouldConsumePower = false;
            }

            minEfficiency = Math.min(minEfficiency, result);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_updateConsumption_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var non_optional_consumer_results: Array = _args[6] if _args.size() > 6 else []", source_text)
            self.assertIn("for consumer in non_optional_consumer_results:", source_text)
            self.assertIn('var result := float(consumer.get("result", 0.0))', source_text)
            self.assertIn('if not bool(consumer.get("is_power", false)) and result <= 0.0000001:', source_text)
            self.assertIn("should_consume_power = false", source_text)
            self.assertIn("min_efficiency = min(min_efficiency, result)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_update_consumption_non_optional_pass_state"', source_text)
            self.assertIn('"method": "public void updateConsumption(){"', source_text)
            self.assertIn('"comment": "//first pass: get the minimum efficiency of any consumer"', source_text)
            self.assertIn('"loop": "for(var cons : block.nonOptionalConsumers){"', source_text)
            self.assertIn('"result": "float result = cons.efficiency(self());"', source_text)
            self.assertIn('"power_gate": "if(cons != block.consPower && result <= 0.0000001f){"', source_text)
            self.assertIn('"power_state": "shouldConsumePower = false;"', source_text)
            self.assertIn('"min": "minEfficiency = Math.min(minEfficiency, result);"', source_text)
            self.assertIn('"non_optional_consumer_results": non_optional_consumer_results', source_text)
            self.assertIn('"min_efficiency": min_efficiency', source_text)
            self.assertIn('"should_consume_power": should_consume_power', source_text)

    def test_emit_bridges_building_comp_update_consumption_optional_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void updateEfficiencyMultiplier(){
        float scale = efficiencyScale();
        efficiency *= scale;
        optionalEfficiency *= scale;
    }
    public void updateConsumption(){
        //everything is valid when cheating
        if(!block.hasConsumers || cheating()){
            potentialEfficiency = enabled && productionValid() ? 1f : 0f;
            efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;
            shouldConsumePower = true;
            updateEfficiencyMultiplier();
            return;
        }

        //disabled -> nothing works
        if(!enabled){
            potentialEfficiency = efficiency = optionalEfficiency = 0f;
            shouldConsumePower = false;
            return;
        }

        boolean update = shouldConsume() && productionValid();

        float minEfficiency = 1f;

        //assume efficiency is 1 for the calculations below
        efficiency = optionalEfficiency = 1f;
        shouldConsumePower = true;

        //first pass: get the minimum efficiency of any consumer
        for(var cons : block.nonOptionalConsumers){
            float result = cons.efficiency(self());

            if(cons != block.consPower && result <= 0.0000001f){
                shouldConsumePower = false;
            }

            minEfficiency = Math.min(minEfficiency, result);
        }

        //same for optionals
        for(var cons : block.optionalConsumers){
            optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));
        }

        //efficiency is now this minimum value
        efficiency = minEfficiency;
        optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);

        //assign "potential"
        potentialEfficiency = efficiency;

        //no updating means zero efficiency
        if(!update){
            efficiency = optionalEfficiency = 0f;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_updateConsumption_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var optional_consumer_results: Array = _args[7] if _args.size() > 7 else []", source_text)
            self.assertIn("if _args.size() <= 7:", source_text)
            self.assertIn("var optional_efficiency := 1.0", source_text)
            self.assertIn("for result in optional_consumer_results:", source_text)
            self.assertIn("optional_efficiency = min(optional_efficiency, float(result))", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_update_consumption_optional_pass_state"', source_text)
            self.assertIn('"method": "public void updateConsumption(){"', source_text)
            self.assertIn('"comment": "//same for optionals"', source_text)
            self.assertIn('"loop": "for(var cons : block.optionalConsumers){"', source_text)
            self.assertIn('"optional_min": "optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));"', source_text)
            self.assertIn('"optional_consumer_results": optional_consumer_results', source_text)
            self.assertIn('"optional_efficiency": optional_efficiency', source_text)

    def test_emit_bridges_building_comp_update_consumption_efficiency_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    public void updateConsumption(){
        boolean update = shouldConsume() && productionValid();
        float minEfficiency = 1f;

        //assume efficiency is 1 for the calculations below
        efficiency = optionalEfficiency = 1f;
        shouldConsumePower = true;

        //first pass: get the minimum efficiency of any consumer
        for(var cons : block.nonOptionalConsumers){
            float result = cons.efficiency(self());

            if(cons != block.consPower && result <= 0.0000001f){
                shouldConsumePower = false;
            }

            minEfficiency = Math.min(minEfficiency, result);
        }

        //same for optionals
        for(var cons : block.optionalConsumers){
            optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));
        }

        //efficiency is now this minimum value
        efficiency = minEfficiency;
        optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);

        //assign "potential"
        potentialEfficiency = efficiency;

        //no updating means zero efficiency
        if(!update){
            efficiency = optionalEfficiency = 0f;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_updateConsumption_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("if _args.size() <= 8:", source_text)
            self.assertIn("efficiency = min_efficiency", source_text)
            self.assertIn("var optional_efficiency_input := optional_efficiency", source_text)
            self.assertIn("optional_efficiency = min(optional_efficiency, min_efficiency)", source_text)
            self.assertIn("potential_efficiency = efficiency", source_text)
            self.assertIn("if not update:", source_text)
            self.assertIn("efficiency = 0.0", source_text)
            self.assertIn("optional_efficiency = 0.0", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_update_consumption_efficiency_state"', source_text)
            self.assertIn('"comment": "//efficiency is now this minimum value"', source_text)
            self.assertIn('"assign": "efficiency = minEfficiency;"', source_text)
            self.assertIn('"optional_min": "optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);"', source_text)
            self.assertIn('"potential_assign": "potentialEfficiency = efficiency;"', source_text)
            self.assertIn('"no_update_guard": "if(!update){"', source_text)
            self.assertIn('"no_update_zero": "efficiency = optionalEfficiency = 0f;"', source_text)
            self.assertIn('"min_efficiency": min_efficiency', source_text)
            self.assertIn('"optional_efficiency_input": optional_efficiency_input', source_text)
            self.assertIn('"potential_efficiency": potential_efficiency', source_text)

    def test_emit_bridges_building_comp_update_consumption_second_pass_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    public void updateEfficiencyMultiplier(){
        float scale = efficiencyScale();
        efficiency *= scale;
        optionalEfficiency *= scale;
    }

    public void updateConsumption(){
        boolean update = shouldConsume() && productionValid();
        float minEfficiency = 1f;

        //assume efficiency is 1 for the calculations below
        efficiency = optionalEfficiency = 1f;
        shouldConsumePower = true;

        //first pass: get the minimum efficiency of any consumer
        for(var cons : block.nonOptionalConsumers){
            float result = cons.efficiency(self());

            if(cons != block.consPower && result <= 0.0000001f){
                shouldConsumePower = false;
            }

            minEfficiency = Math.min(minEfficiency, result);
        }

        //same for optionals
        for(var cons : block.optionalConsumers){
            optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));
        }

        //efficiency is now this minimum value
        efficiency = minEfficiency;
        optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);

        //assign "potential"
        potentialEfficiency = efficiency;

        //no updating means zero efficiency
        if(!update){
            efficiency = optionalEfficiency = 0f;
        }

        updateEfficiencyMultiplier();

        //second pass: update every consumer based on efficiency
        if(update && efficiency > 0){
            for(var cons : block.updateConsumers){
                cons.update(self());
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_updateConsumption_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("if _args.size() <= 9:", source_text)
            self.assertIn("var update_consumers: Array = _args[9] if _args.size() > 9 else []", source_text)
            self.assertIn("var self_state: Dictionary = _args[10] if _args.size() > 10 else {}", source_text)
            self.assertIn("var multiplied = java_method_updateEfficiencyMultiplier_0([efficiency, optional_efficiency, efficiency_scale])", source_text)
            self.assertIn('efficiency = float(multiplied.get("efficiency", efficiency))', source_text)
            self.assertIn("var updated_consumers := []", source_text)
            self.assertIn("if update and efficiency > 0.0:", source_text)
            self.assertIn("for consumer in update_consumers:", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_update_consumption_second_pass_state"', source_text)
            self.assertIn('"multiplier": "updateEfficiencyMultiplier();"', source_text)
            self.assertIn('"comment": "//second pass: update every consumer based on efficiency"', source_text)
            self.assertIn('"guard": "if(update && efficiency > 0){"', source_text)
            self.assertIn('"loop": "for(var cons : block.updateConsumers){"', source_text)
            self.assertIn('"update_call": "cons.update(self());"', source_text)
            self.assertIn('"updated_consumers": updated_consumers', source_text)
            self.assertIn('"update_count": updated_consumers.size()', source_text)

    def test_emit_bridges_building_comp_ambient_volume_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    /** @return ambient sound volume scale. */
    public float ambientVolume(){
        return efficiency;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_ambientVolume_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var efficiency := float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_ambient_volume"', source_text)
            self.assertIn('"method": "public float ambientVolume(){"', source_text)
            self.assertIn('"efficiency": efficiency', source_text)
            self.assertIn('"ambientVolume": efficiency', source_text)

    def test_emit_bridges_building_comp_config_default_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    /** Tile configuration. Defaults to null. Used for block rebuilding. */
    @Nullable
    public Object config(){
        return null;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_config_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_config_default"', source_text)
            self.assertIn('"comment": "/** Tile configuration. Defaults to null. Used for block rebuilding. */"', source_text)
            self.assertIn('"nullable": "@Nullable"', source_text)
            self.assertIn('"method": "public Object config(){"', source_text)
            self.assertIn('"config": null', source_text)

    def test_emit_bridges_building_comp_is_valid_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Replace
    @Override
    public boolean isValid(){
        return tile.build == self() && !dead();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_isValid_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var tile_build_matches_self := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var dead_state := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var valid := tile_build_matches_self and not dead_state", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_is_valid"', source_text)
            self.assertIn('"replace": "@Replace"', source_text)
            self.assertIn('"override": "@Override"', source_text)
            self.assertIn('"method": "public boolean isValid(){"', source_text)
            self.assertIn('"tile_build_matches_self": tile_build_matches_self', source_text)
            self.assertIn('"dead_state": dead_state', source_text)
            self.assertIn('"valid": valid', source_text)

    def test_emit_bridges_building_comp_heal_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @MethodPriority(100)
    @Override
    public void heal(){
        healthChanged();
    }

    @MethodPriority(100)
    @Override
    public void heal(float amount){
        healthChanged();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_heal_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("func java_method_heal_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var amount: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_heal_state"', source_text)
            self.assertIn('"priority": "@MethodPriority(100)"', source_text)
            self.assertIn('"override": "@Override"', source_text)
            self.assertIn('"method": "public void heal(){"', source_text)
            self.assertIn('"method": "public void heal(float amount){"', source_text)
            self.assertIn('"health_changed_call": "healthChanged();"', source_text)
            self.assertIn('"health_changed": true', source_text)
            self.assertIn('"amount": null', source_text)
            self.assertIn('"amount": amount', source_text)

    def test_emit_bridges_building_comp_health_changed_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    public void healthChanged(){
        //server-side, health updates are batched.
        if(net.server()){
            netServer.buildHealthUpdate(self());
        }

        indexer.notifyHealthChanged(self());
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_healthChanged_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var net_server := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var self_state: Variant = _args[1] if _args.size() > 1 else {}", source_text)
            self.assertIn("var build_health_update: Variant = self_state", source_text)
            self.assertIn("if not net_server:", source_text)
            self.assertIn("build_health_update = null", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_health_changed_state"', source_text)
            self.assertIn('"method": "public void healthChanged(){"', source_text)
            self.assertIn('"server_comment": "//server-side, health updates are batched."', source_text)
            self.assertIn('"server_guard": "if(net.server()){"', source_text)
            self.assertIn('"build_health_update_call": "netServer.buildHealthUpdate(self());"', source_text)
            self.assertIn('"notify_call": "indexer.notifyHealthChanged(self());"', source_text)
            self.assertIn('"build_health_update_called": net_server', source_text)
            self.assertIn('"build_health_update": build_health_update', source_text)
            self.assertIn('"notify_health_changed": self_state', source_text)

    def test_emit_bridges_building_comp_sense_position_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public double sense(LAccess sensor){
        return switch(sensor){
            case x -> World.conv(x);
            case y -> World.conv(y);
            default -> Float.NaN;
        };
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_sense_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var world_x := float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var world_y := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var source_tilesize := float(_args[2] if _args.size() > 2 else 8.0)", source_text)
            self.assertIn("var source_x := world_x / source_tilesize", source_text)
            self.assertIn("var source_y := world_y / source_tilesize", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_sense_position_state"', source_text)
            self.assertIn('"method": "public double sense(LAccess sensor){"', source_text)
            self.assertIn('"switch_case": "return switch(sensor){"', source_text)
            self.assertIn('"x_case": "case x -> World.conv(x);"', source_text)
            self.assertIn('"y_case": "case y -> World.conv(y);"', source_text)
            self.assertIn('"world_conv_method": "public static float conv(float coord){"', source_text)
            self.assertIn('"world_conv_return": "return coord / tilesize;"', source_text)
            self.assertIn('"world_x": world_x', source_text)
            self.assertIn('"world_y": world_y', source_text)
            self.assertIn('"source_tilesize": source_tilesize', source_text)
            self.assertIn('"x": source_x', source_text)
            self.assertIn('"y": source_y', source_text)

    def test_emit_bridges_building_comp_sense_health_process_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public double sense(LAccess sensor){
        return switch(sensor){
            case health -> health;
            case maxHealth -> maxHealth;
            case efficiency -> efficiency;
            case timescale -> timeScale;
            case range -> this instanceof Ranged r ? r.range() / tilesize : 0;
            case rotation -> rotation;
            default -> Float.NaN;
        };
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_sense_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var health := float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var max_health := float(_args[4] if _args.size() > 4 else 0.0)", source_text)
            self.assertIn("var efficiency := float(_args[5] if _args.size() > 5 else 0.0)", source_text)
            self.assertIn("var time_scale := float(_args[6] if _args.size() > 6 else 0.0)", source_text)
            self.assertIn("var ranged_range := float(_args[7] if _args.size() > 7 else 0.0)", source_text)
            self.assertIn("var has_range := bool(_args[8] if _args.size() > 8 else false)", source_text)
            self.assertIn("var rotation_value := float(_args[9] if _args.size() > 9 else 0.0)", source_text)
            self.assertIn("var sense_range := ranged_range / source_tilesize if has_range else 0.0", source_text)
            self.assertIn('"health_process_source_owner": "PortGame.source_building_sense_health_process_state"', source_text)
            self.assertIn('"health_case": "case health -> health;"', source_text)
            self.assertIn('"max_health_case": "case maxHealth -> maxHealth;"', source_text)
            self.assertIn('"efficiency_case": "case efficiency -> efficiency;"', source_text)
            self.assertIn('"timescale_case": "case timescale -> timeScale;"', source_text)
            self.assertIn('"range_case": "case range -> this instanceof Ranged r ? r.range() / tilesize : 0;"', source_text)
            self.assertIn('"rotation_case": "case rotation -> rotation;"', source_text)
            self.assertIn('"range": sense_range', source_text)
            self.assertIn('"rotation": rotation_value', source_text)
            self.assertIn('"sense_health_process": sense_health_process', source_text)

    def test_emit_bridges_building_comp_sense_totals_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public double sense(LAccess sensor){
        return switch(sensor){
            case totalItems -> items == null ? 0 : items.total();
            //totalLiquids is inherently bad design, but unfortunately it is useful for conduits/tanks
            case totalLiquids -> liquids == null ? 0 : liquids.currentAmount();
            case totalPower -> power == null || block.consPower == null ? 0 : power.status * (block.consPower.buffered ? block.consPower.capacity : 1f);
            default -> Float.NaN;
        };
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_sense_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var total_items := float(_args[10] if _args.size() > 10 else 0.0)", source_text)
            self.assertIn("var total_liquids := float(_args[11] if _args.size() > 11 else 0.0)", source_text)
            self.assertIn("var total_power := float(_args[12] if _args.size() > 12 else 0.0)", source_text)
            self.assertIn('"totals_source_owner": "PortGame.source_building_sense_totals_state"', source_text)
            self.assertIn('"total_items_case": "case totalItems -> items == null ? 0 : items.total();"', source_text)
            self.assertIn('"total_liquids_comment": "//totalLiquids is inherently bad design, but unfortunately it is useful for conduits/tanks"', source_text)
            self.assertIn('"total_liquids_case": "case totalLiquids -> liquids == null ? 0 : liquids.currentAmount();"', source_text)
            self.assertIn('"total_power_case": "case totalPower -> power == null || block.consPower == null ? 0 : power.status * (block.consPower.buffered ? block.consPower.capacity : 1f);"', source_text)
            self.assertIn('"total_items": total_items', source_text)
            self.assertIn('"total_liquids": total_liquids', source_text)
            self.assertIn('"total_power": total_power', source_text)
            self.assertIn('"sense_totals": sense_totals', source_text)

    def test_emit_bridges_building_comp_sense_capacity_power_net_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public double sense(LAccess sensor){
        return switch(sensor){
            case itemCapacity -> block.hasItems ? block.itemCapacity : 0;
            case liquidCapacity -> block.hasLiquids ? block.liquidCapacity : 0;
            case powerCapacity -> block.consPower != null ? block.consPower.capacity : 0f;
            case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;
            case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;
            case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();
            case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();
            default -> Float.NaN;
        };
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_sense_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var block_has_items := bool(_args[13] if _args.size() > 13 else false)", source_text)
            self.assertIn("var block_item_capacity := float(_args[14] if _args.size() > 14 else 0.0)", source_text)
            self.assertIn("var block_has_liquids := bool(_args[15] if _args.size() > 15 else false)", source_text)
            self.assertIn("var block_liquid_capacity := float(_args[16] if _args.size() > 16 else 0.0)", source_text)
            self.assertIn("var has_cons_power := bool(_args[17] if _args.size() > 17 else false)", source_text)
            self.assertIn("var cons_power_capacity := float(_args[18] if _args.size() > 18 else 0.0)", source_text)
            self.assertIn("var has_power_module := bool(_args[19] if _args.size() > 19 else false)", source_text)
            self.assertIn("var last_scaled_power_in := float(_args[20] if _args.size() > 20 else 0.0)", source_text)
            self.assertIn("var last_scaled_power_out := float(_args[21] if _args.size() > 21 else 0.0)", source_text)
            self.assertIn("var last_power_stored := float(_args[22] if _args.size() > 22 else 0.0)", source_text)
            self.assertIn("var last_power_capacity := float(_args[23] if _args.size() > 23 else 0.0)", source_text)
            self.assertIn("var power_net_in := last_scaled_power_in * 60.0 if has_power_module else 0.0", source_text)
            self.assertIn('"capacity_power_net_source_owner": "PortGame.source_building_sense_capacity_power_net_state"', source_text)
            self.assertIn('"item_capacity_case": "case itemCapacity -> block.hasItems ? block.itemCapacity : 0;"', source_text)
            self.assertIn('"power_net_capacity_case": "case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();"', source_text)
            self.assertIn('"item_capacity": block_item_capacity if block_has_items else 0.0', source_text)
            self.assertIn('"power_net_in": power_net_in', source_text)
            self.assertIn('"sense_capacity_power_net": sense_capacity_power_net', source_text)

    def test_emit_bridges_building_comp_sense_enabled_controlled_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public double sense(LAccess sensor){
        return switch(sensor){
            case enabled -> enabled ? 1 : 0;
            case controlled -> this instanceof ControlBlock c && c.isControlled() ? GlobalVars.ctrlPlayer : 0;
            default -> Float.NaN;
        };
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_sense_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var enabled_state := bool(_args[24] if _args.size() > 24 else false)", source_text)
            self.assertIn("var is_control_block := bool(_args[25] if _args.size() > 25 else false)", source_text)
            self.assertIn("var is_controlled := bool(_args[26] if _args.size() > 26 else false)", source_text)
            self.assertIn("var ctrl_player_value := float(_args[27] if _args.size() > 27 else 0.0)", source_text)
            self.assertIn('"enabled_controlled_source_owner": "PortGame.source_building_sense_enabled_controlled_state"', source_text)
            self.assertIn('"enabled_case": "case enabled -> enabled ? 1 : 0;"', source_text)
            self.assertIn('"controlled_case": "case controlled -> this instanceof ControlBlock c && c.isControlled() ? GlobalVars.ctrlPlayer : 0;"', source_text)
            self.assertIn('"enabled": 1.0 if enabled_state else 0.0', source_text)
            self.assertIn('"controlled": ctrl_player_value if is_control_block and is_controlled else 0.0', source_text)
            self.assertIn('"sense_enabled_controlled": sense_enabled_controlled', source_text)

    def test_emit_bridges_building_comp_sense_payload_size_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public double sense(LAccess sensor){
        return switch(sensor){
            case payloadCount -> (getPayloads() != null ? getPayloads().total() : 0) + (getPayload() != null ? 1 : 0);
            case size -> block.size;
            default -> Float.NaN;
        };
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_sense_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var has_payload_seq := bool(_args[28] if _args.size() > 28 else false)", source_text)
            self.assertIn("var payload_seq_total := float(_args[29] if _args.size() > 29 else 0.0)", source_text)
            self.assertIn("var has_single_payload := bool(_args[30] if _args.size() > 30 else false)", source_text)
            self.assertIn("var block_size_value := float(_args[31] if _args.size() > 31 else 0.0)", source_text)
            self.assertIn("var payload_count := 0.0", source_text)
            self.assertIn("if has_payload_seq:", source_text)
            self.assertIn("payload_count += payload_seq_total", source_text)
            self.assertIn("if has_single_payload:", source_text)
            self.assertIn("payload_count += 1.0", source_text)
            self.assertIn('"payload_size_source_owner": "PortGame.source_building_sense_payload_size_state"', source_text)
            self.assertIn('"payload_count_case": "case payloadCount -> (getPayloads() != null ? getPayloads().total() : 0) + (getPayload() != null ? 1 : 0);"', source_text)
            self.assertIn('"size_case": "case size -> block.size;"', source_text)
            self.assertIn('"payload_count": payload_count', source_text)
            self.assertIn('"size": block_size_value', source_text)
            self.assertIn('"sense_payload_size": sense_payload_size', source_text)

    def test_emit_bridges_building_comp_sense_camera_default_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public double sense(LAccess sensor){
        return switch(sensor){
            case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;
            default -> Float.NaN; //gets converted to null in logic
        };
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_sense_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var camera_is_control_block := bool(_args[32] if _args.size() > 32 else false)", source_text)
            self.assertIn("var unit_camera_x := float(_args[33] if _args.size() > 33 else 0.0)", source_text)
            self.assertIn("var unit_camera_y := float(_args[34] if _args.size() > 34 else 0.0)", source_text)
            self.assertIn("var unit_camera_width := float(_args[35] if _args.size() > 35 else 0.0)", source_text)
            self.assertIn("var unit_camera_height := float(_args[36] if _args.size() > 36 else 0.0)", source_text)
            self.assertIn("var camera_x := unit_camera_x if camera_is_control_block else 0.0", source_text)
            self.assertIn("var camera_y := unit_camera_y if camera_is_control_block else 0.0", source_text)
            self.assertIn("var camera_width := unit_camera_width if camera_is_control_block else 0.0", source_text)
            self.assertIn("var camera_height := unit_camera_height if camera_is_control_block else 0.0", source_text)
            self.assertIn('"camera_default_source_owner": "PortGame.source_building_sense_camera_default_state"', source_text)
            self.assertIn('"camera_case": "case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;"', source_text)
            self.assertIn('"default_case": "default -> Float.NaN; //gets converted to null in logic"', source_text)
            self.assertIn('"is_control_block": camera_is_control_block', source_text)
            self.assertIn('"camera_x": camera_x', source_text)
            self.assertIn('"camera_height": camera_height', source_text)
            self.assertIn('"invalid_sensor": null', source_text)
            self.assertIn('"sense_camera_default": sense_camera_default', source_text)

    def test_emit_bridges_building_comp_sense_object_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public Object senseObject(LAccess sensor){
        return switch(sensor){
            case type -> block;
            case firstItem -> items == null ? null : items.first();
            case config -> block.configSenseable() ? config() : null;
            case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null;
            default -> noSensed;
        };
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_senseObject_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var sensor := str(_args[0] if _args.size() > 0 else "")', source_text)
            self.assertIn("var block_value: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var has_items_module := bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("var first_item_value: Variant = _args[3] if _args.size() > 3 else null", source_text)
            self.assertIn("var config_senseable := bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("var config_value: Variant = _args[5] if _args.size() > 5 else null", source_text)
            self.assertIn('var single_payload_kind := str(_args[6] if _args.size() > 6 else "")', source_text)
            self.assertIn("var single_payload_content: Variant = _args[7] if _args.size() > 7 else null", source_text)
            self.assertIn('"object_source_owner": "PortGame.source_building_sense_object_state"', source_text)
            self.assertIn('"method": "public Object senseObject(LAccess sensor){"', source_text)
            self.assertIn('"type_case": "case type -> block;"', source_text)
            self.assertIn('"first_item_case": "case firstItem -> items == null ? null : items.first();"', source_text)
            self.assertIn('"config_case": "case config -> block.configSenseable() ? config() : null;"', source_text)
            self.assertIn('"payload_type_case": "case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null;"', source_text)
            self.assertIn('"default_case": "default -> noSensed;"', source_text)
            self.assertIn('"no_sensed": no_sensed', source_text)
            self.assertIn('"value": value', source_text)
            self.assertIn('"sense_object": sense_object', source_text)

    def test_emit_bridges_building_comp_sense_content_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public double sense(Content content){
        if(content instanceof Item i && items != null) return items.get(i);
        if(content instanceof Liquid l && liquids != null) return liquids.get(l);
        if(getPayloads() != null){
            if(content instanceof UnitType u) return getPayloads().get(u);
            if(content instanceof Block b) return getPayloads().get(b);
        }
        return Float.NaN; //invalid sense
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_sense_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var content_type := str(_args[0] if _args.size() > 0 else "")', source_text)
            self.assertIn("var has_items_module := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var item_amount := float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var has_liquids_module := bool(_args[3] if _args.size() > 3 else false)", source_text)
            self.assertIn("var liquid_amount := float(_args[4] if _args.size() > 4 else 0.0)", source_text)
            self.assertIn("var has_payloads := bool(_args[5] if _args.size() > 5 else false)", source_text)
            self.assertIn("var payload_amount := float(_args[6] if _args.size() > 6 else 0.0)", source_text)
            self.assertIn('"content_source_owner": "PortGame.source_building_sense_content_state"', source_text)
            self.assertIn('"method": "public double sense(Content content){"', source_text)
            self.assertIn('"item_case": "if(content instanceof Item i && items != null) return items.get(i);"', source_text)
            self.assertIn('"liquid_case": "if(content instanceof Liquid l && liquids != null) return liquids.get(l);"', source_text)
            self.assertIn('"payloads_guard": "if(getPayloads() != null){"', source_text)
            self.assertIn('"unit_payload_case": "if(content instanceof UnitType u) return getPayloads().get(u);"', source_text)
            self.assertIn('"block_payload_case": "if(content instanceof Block b) return getPayloads().get(b);"', source_text)
            self.assertIn('"invalid_return": "return Float.NaN; //invalid sense"', source_text)
            self.assertIn('"sensed": sensed', source_text)
            self.assertIn('"value": value', source_text)
            self.assertIn('"sense_content": sense_content', source_text)

    def test_emit_bridges_building_comp_control_enabled_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public void control(LAccess type, double p1, double p2, double p3, double p4){
        if(type == LAccess.enabled){
            enabled = !Mathf.zero((float)p1);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_control_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var current_enabled := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn('var control_type := str(_args[1] if _args.size() > 1 else "")', source_text)
            self.assertIn("var p1 := float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var next_enabled := current_enabled", source_text)
            self.assertIn('if control_type == "enabled":', source_text)
            self.assertIn("next_enabled = not absf(p1) <= SOURCE_FLOAT_ROUNDING_ERROR", source_text)
            self.assertIn('"enabled_source_owner": "PortGame.source_building_control_enabled_state"', source_text)
            self.assertIn('"method": "public void control(LAccess type, double p1, double p2, double p3, double p4){"', source_text)
            self.assertIn('"guard": "if(type == LAccess.enabled){"', source_text)
            self.assertIn('"assignment": "enabled = !Mathf.zero((float)p1);"', source_text)
            self.assertIn('"current_enabled": current_enabled', source_text)
            self.assertIn('"control_type": control_type', source_text)
            self.assertIn('"p1": p1', source_text)
            self.assertIn('"enabled": next_enabled', source_text)
            self.assertIn('"control_enabled": control_enabled', source_text)

    def test_emit_bridges_building_comp_control_config_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public void control(LAccess type, Object p1, double p2, double p3, double p4){
        //don't execute configure instructions that copy logic building configures; this can cause extreme lag
        if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){
            //change config only if it's new
            configured(null, p1);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_control_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var control_type := str(_args[0] if _args.size() > 0 else "")', source_text)
            self.assertIn("var block_logic_configurable := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var p1_is_logic_build := bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("var p1_value: Variant = _args[3] if _args.size() > 3 else null", source_text)
            self.assertIn("var configured_called := false", source_text)
            self.assertIn("var value: Variant = null", source_text)
            self.assertIn('if control_type == "config" and block_logic_configurable and not p1_is_logic_build:', source_text)
            self.assertIn("configured_called = true", source_text)
            self.assertIn("value = p1_value", source_text)
            self.assertIn('"config_source_owner": "PortGame.source_building_control_config_state"', source_text)
            self.assertIn('"method": "public void control(LAccess type, Object p1, double p2, double p3, double p4){"', source_text)
            self.assertIn('"lag_comment": "//don\'t execute configure instructions that copy logic building configures; this can cause extreme lag"', source_text)
            self.assertIn('"guard": "if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){"', source_text)
            self.assertIn('"new_comment": "//change config only if it\'s new"', source_text)
            self.assertIn('"configured_call": "configured(null, p1);"', source_text)
            self.assertIn('"configured_called": configured_called', source_text)
            self.assertIn('"builder": null', source_text)
            self.assertIn('"value": value', source_text)
            self.assertIn('"control_config": control_config', source_text)

    def test_emit_bridges_building_comp_set_prop_health_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public void setProp(LAccess prop, double value){
        switch(prop){
            case health -> {
                health = (float)Mathf.clamp(value, 0, maxHealth);
                if(health <= 0f && !dead()){
                    Call.buildDestroyed(self());
                }else{
                    healthChanged();
                }
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setProp_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var prop := str(_args[0] if _args.size() > 0 else "")', source_text)
            self.assertIn("var current_health := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var max_health_value := float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var value := float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var dead_state := bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("var self_state: Variant = _args[5] if _args.size() > 5 else null", source_text)
            self.assertIn("var health := current_health", source_text)
            self.assertIn("var build_destroyed_called := false", source_text)
            self.assertIn("var build_destroyed: Variant = null", source_text)
            self.assertIn("var health_changed := false", source_text)
            self.assertIn('if prop == "health":', source_text)
            self.assertIn("health = clampf(value, 0.0, max_health_value)", source_text)
            self.assertIn("if health <= 0.0 and not dead_state:", source_text)
            self.assertIn("build_destroyed_called = true", source_text)
            self.assertIn("build_destroyed = self_state", source_text)
            self.assertIn("health_changed = true", source_text)
            self.assertIn('"health_source_owner": "PortGame.source_building_set_prop_health_state"', source_text)
            self.assertIn('"method": "public void setProp(LAccess prop, double value){"', source_text)
            self.assertIn('"switch_prop": "switch(prop){"', source_text)
            self.assertIn('"health_case": "case health -> {"', source_text)
            self.assertIn('"clamp_assign": "health = (float)Mathf.clamp(value, 0, maxHealth);"', source_text)
            self.assertIn('"destroy_gate": "if(health <= 0f && !dead()){"', source_text)
            self.assertIn('"build_destroyed_call": "Call.buildDestroyed(self());"', source_text)
            self.assertIn('"else_branch": "}else{"', source_text)
            self.assertIn('"health_changed_call": "healthChanged();"', source_text)
            self.assertIn('"set_prop_health": set_prop_health', source_text)

    def test_emit_bridges_building_comp_set_prop_team_double_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public void setProp(LAccess prop, double value){
        switch(prop){
            case team -> {
                Team team = Team.get((int)value);
                if(this.team != team){
                    changeTeam(team);
                }
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setProp_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var current_team_id := int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("var team_value := float(_args[2] if _args.size() > 2 else value)", source_text)
            self.assertIn("var team_id := current_team_id", source_text)
            self.assertIn("var change_team_called := false", source_text)
            self.assertIn("var change_team: Variant = null", source_text)
            self.assertIn('if prop == "team":', source_text)
            self.assertIn("var next_team_id := int(team_value)", source_text)
            self.assertIn("if current_team_id != next_team_id:", source_text)
            self.assertIn("team_id = next_team_id", source_text)
            self.assertIn("change_team_called = true", source_text)
            self.assertIn("change_team = next_team_id", source_text)
            self.assertIn('"team_source_owner": "PortGame.source_building_set_prop_team_double_state"', source_text)
            self.assertIn('"team_case": "case team -> {"', source_text)
            self.assertIn('"team_lookup": "Team team = Team.get((int)value);"', source_text)
            self.assertIn('"change_gate": "if(this.team != team){"', source_text)
            self.assertIn('"change_team_call": "changeTeam(team);"', source_text)
            self.assertIn('"current_team_id": current_team_id', source_text)
            self.assertIn('"team_id": team_id', source_text)
            self.assertIn('"change_team_called": change_team_called', source_text)
            self.assertIn('"change_team": change_team', source_text)
            self.assertIn('"set_prop_team_double": set_prop_team_double', source_text)

    def test_emit_bridges_building_comp_set_prop_total_power_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public void setProp(LAccess prop, double value){
        switch(prop){
            case totalPower -> {
                if(power != null && block.consPower != null && block.consPower.buffered){
                    power.status = Mathf.clamp((float)(value / block.consPower.capacity));
                }
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setProp_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var current_power_status := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var has_power := bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("var has_cons_power := bool(_args[3] if _args.size() > 3 else false)", source_text)
            self.assertIn("var cons_power_buffered := bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("var cons_power_capacity := float(_args[5] if _args.size() > 5 else 0.0)", source_text)
            self.assertIn("var total_power_value := float(_args[6] if _args.size() > 6 else value)", source_text)
            self.assertIn("var power_status := current_power_status", source_text)
            self.assertIn("var updated := false", source_text)
            self.assertIn('if prop == "totalPower" and has_power and has_cons_power and cons_power_buffered:', source_text)
            self.assertIn("power_status = clampf(total_power_value / cons_power_capacity, 0.0, 1.0)", source_text)
            self.assertIn("updated = true", source_text)
            self.assertIn('"total_power_source_owner": "PortGame.source_building_set_prop_total_power_state"', source_text)
            self.assertIn('"total_power_case": "case totalPower -> {"', source_text)
            self.assertIn('"total_power_guard": "if(power != null && block.consPower != null && block.consPower.buffered){"', source_text)
            self.assertIn('"status_assign": "power.status = Mathf.clamp((float)(value / block.consPower.capacity));"', source_text)
            self.assertIn('"current_power_status": current_power_status', source_text)
            self.assertIn('"has_power": has_power', source_text)
            self.assertIn('"has_cons_power": has_cons_power', source_text)
            self.assertIn('"cons_power_buffered": cons_power_buffered', source_text)
            self.assertIn('"cons_power_capacity": cons_power_capacity', source_text)
            self.assertIn('"value": total_power_value', source_text)
            self.assertIn('"power_status": power_status', source_text)
            self.assertIn('"updated": updated', source_text)
            self.assertIn('"set_prop_total_power": set_prop_total_power', source_text)

    def test_emit_bridges_building_comp_set_prop_team_object_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public void setProp(LAccess prop, Object value){
        switch(prop){
            case team -> {
                if(value instanceof Team team && this.team != team){
                    changeTeam(team);
                }
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setProp_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var prop := str(_args[0] if _args.size() > 0 else "")', source_text)
            self.assertIn("var current_team_value: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var value_is_team := bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("var team_value: Variant = _args[3] if _args.size() > 3 else null", source_text)
            self.assertIn("var team: Variant = current_team_value", source_text)
            self.assertIn("var change_team_called := false", source_text)
            self.assertIn("var change_team: Variant = null", source_text)
            self.assertIn('if prop == "team" and value_is_team and current_team_value != team_value:', source_text)
            self.assertIn("team = team_value", source_text)
            self.assertIn("change_team_called = true", source_text)
            self.assertIn("change_team = team_value", source_text)
            self.assertIn('"team_object_source_owner": "PortGame.source_building_set_prop_team_object_state"', source_text)
            self.assertIn('"method": "public void setProp(LAccess prop, Object value){"', source_text)
            self.assertIn('"switch_prop": "switch(prop){"', source_text)
            self.assertIn('"team_case": "case team -> {"', source_text)
            self.assertIn('"team_gate": "if(value instanceof Team team && this.team != team){"', source_text)
            self.assertIn('"change_team_call": "changeTeam(team);"', source_text)
            self.assertIn('"current_team_value": current_team_value', source_text)
            self.assertIn('"value_is_team": value_is_team', source_text)
            self.assertIn('"team_value": team_value', source_text)
            self.assertIn('"team": team', source_text)
            self.assertIn('"change_team_called": change_team_called', source_text)
            self.assertIn('"change_team": change_team', source_text)
            self.assertIn('"set_prop_team_object": set_prop_team_object', source_text)

    def test_emit_bridges_building_comp_set_prop_item_content_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public void setProp(UnlockableContent content, double value){
        if(content instanceof Item item && items != null){
            int amount = (int)value;
            if(items.get(item) != amount){
                if(items.get(item) < amount){
                    handleStack(item, acceptStack(item, amount - items.get(item), null), null);
                }else if(amount >= 0){
                    removeStack(item, items.get(item) - amount);
                }
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setProp_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var content_type := str(_args[0] if _args.size() > 0 else "")', source_text)
            self.assertIn("var has_items_module := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var item_value: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("var current_amount := int(_args[3] if _args.size() > 3 else 0)", source_text)
            self.assertIn("var value := float(_args[4] if _args.size() > 4 else 0.0)", source_text)
            self.assertIn("var accepted_stack := int(_args[5] if _args.size() > 5 else 0)", source_text)
            self.assertIn("var amount := int(value)", source_text)
            self.assertIn('"item_content_source_owner": "PortGame.source_building_set_prop_item_content_state"', source_text)
            self.assertIn('"method": "public void setProp(UnlockableContent content, double value){"', source_text)
            self.assertIn('"item_gate": "if(content instanceof Item item && items != null){"', source_text)
            self.assertIn('"amount_assign": "int amount = (int)value;"', source_text)
            self.assertIn('"amount_diff_gate": "if(items.get(item) != amount){"', source_text)
            self.assertIn('"increase_gate": "if(items.get(item) < amount){"', source_text)
            self.assertIn('"handle_stack_call": "handleStack(item, acceptStack(item, amount - items.get(item), null), null);"', source_text)
            self.assertIn('"remove_gate": "}else if(amount >= 0){"', source_text)
            self.assertIn('"remove_stack_call": "removeStack(item, items.get(item) - amount);"', source_text)
            self.assertIn('"content_type": content_type', source_text)
            self.assertIn('"has_items_module": has_items_module', source_text)
            self.assertIn('"item": item_value', source_text)
            self.assertIn('"amount": amount', source_text)
            self.assertIn('"accepted": accepted_stack', source_text)
            self.assertIn('"set_prop_item_content": set_prop_item_content', source_text)

    def test_emit_bridges_building_comp_set_prop_liquid_content_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public void setProp(UnlockableContent content, double value){
        if(content instanceof Item item && items != null){
            int amount = (int)value;
            if(items.get(item) != amount){
                if(items.get(item) < amount){
                    handleStack(item, acceptStack(item, amount - items.get(item), null), null);
                }else if(amount >= 0){
                    removeStack(item, items.get(item) - amount);
                }
            }
        }else if(content instanceof Liquid liquid && liquids != null){
            float amount = Mathf.clamp((float)value, 0f, block.liquidCapacity);
            //decreasing amount is always allowed
            if(amount < liquids.get(liquid) || (acceptLiquid(self(), liquid) && (liquids.current() == liquid || liquids.currentAmount() <= 0.1f || block.consumesLiquid(liquid)))){
                liquids.set(liquid, amount);
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setProp_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var has_liquids_module := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var liquid_value: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("var block_liquid_capacity := float(_args[5] if _args.size() > 5 else 0.0)", source_text)
            self.assertIn("var accept_liquid_result := bool(_args[6] if _args.size() > 6 else false)", source_text)
            self.assertIn("var current_liquid_matches := bool(_args[7] if _args.size() > 7 else false)", source_text)
            self.assertIn("var current_liquid_amount := float(_args[8] if _args.size() > 8 else 0.0)", source_text)
            self.assertIn("var block_consumes_liquid := bool(_args[9] if _args.size() > 9 else false)", source_text)
            self.assertIn("var liquid_amount := clampf(value, 0.0, block_liquid_capacity)", source_text)
            self.assertIn('"liquid_content_source_owner": "PortGame.source_building_set_prop_liquid_content_state"', source_text)
            self.assertIn('"liquid_gate": "}else if(content instanceof Liquid liquid && liquids != null){"', source_text)
            self.assertIn('"clamp_assign": "float amount = Mathf.clamp((float)value, 0f, block.liquidCapacity);"', source_text)
            self.assertIn('"decreasing_comment": "//decreasing amount is always allowed"', source_text)
            self.assertIn('"set_gate": "if(amount < liquids.get(liquid) || (acceptLiquid(self(), liquid) && (liquids.current() == liquid || liquids.currentAmount() <= 0.1f || block.consumesLiquid(liquid)))){"', source_text)
            self.assertIn('"liquids_set_call": "liquids.set(liquid, amount);"', source_text)
            self.assertIn('"liquid": liquid_value', source_text)
            self.assertIn('"amount": liquid_amount', source_text)
            self.assertIn('"set_prop_liquid_content": set_prop_liquid_content', source_text)

    def test_emit_bridges_building_comp_in_fog_initial_gate_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Replace
    @Override
    public boolean inFogTo(Team viewer){
        if(team == viewer || !state.rules.fog) return false;

        return true;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_inFogTo_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var same_team := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var rules_fog := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var in_fog_initial_gate := {\"method\": \"public boolean inFogTo(Team viewer){\", \"initial_return\": \"if(team == viewer || !state.rules.fog) return false;\", \"same_team\": same_team, \"rules_fog\": rules_fog}", source_text)
            self.assertIn("if same_team or not rules_fog:", source_text)
            self.assertIn('in_fog_initial_gate.merge({"returned": true, "value": false})', source_text)
            self.assertIn('in_fog_initial_gate.merge({"returned": false, "value": null})', source_text)
            self.assertIn('"source_owner": "PortGame.source_building_in_fog_initial_gate_state"', source_text)
            self.assertIn('"in_fog_initial_gate_source_owner": "PortGame.source_building_in_fog_initial_gate_state"', source_text)
            self.assertIn('"in_fog_initial_gate": in_fog_initial_gate', source_text)

    def test_emit_bridges_building_comp_in_fog_discovery_gate_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Replace
    @Override
    public boolean inFogTo(Team viewer){
        if(team == viewer || !state.rules.fog) return false;

        int size = block.size, of = block.sizeOffset, tx = tile.x, ty = tile.y;

        if(!isDiscovered(viewer)) return true;

        return true;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_inFogTo_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var block_size_value := int(_args[2] if _args.size() > 2 else 0)", source_text)
            self.assertIn("var block_size_offset := int(_args[3] if _args.size() > 3 else 0)", source_text)
            self.assertIn("var tile_x := int(_args[4] if _args.size() > 4 else 0)", source_text)
            self.assertIn("var tile_y := int(_args[5] if _args.size() > 5 else 0)", source_text)
            self.assertIn("var is_discovered := bool(_args[6] if _args.size() > 6 else false)", source_text)
            self.assertIn('var in_fog_discovery_gate := {"method": "public boolean inFogTo(Team viewer){", "grid_declaration": "int size = block.size, of = block.sizeOffset, tx = tile.x, ty = tile.y;", "undiscovered_return": "if(!isDiscovered(viewer)) return true;", "block_size_value": block_size_value, "block_size_offset": block_size_offset, "tile_x": tile_x, "tile_y": tile_y, "is_discovered": is_discovered}', source_text)
            self.assertIn("if not is_discovered:", source_text)
            self.assertIn('in_fog_discovery_gate.merge({"returned": true, "value": true, "grid": {"size": block_size_value, "offset": block_size_offset, "tile_x": tile_x, "tile_y": tile_y}})', source_text)
            self.assertIn('in_fog_discovery_gate.merge({"returned": false, "value": null, "grid": {"size": block_size_value, "offset": block_size_offset, "tile_x": tile_x, "tile_y": tile_y}})', source_text)
            self.assertIn('"in_fog_discovery_gate_source_owner": "PortGame.source_building_in_fog_discovery_gate_state"', source_text)
            self.assertIn('"in_fog_discovery_gate": in_fog_discovery_gate', source_text)

    def test_emit_bridges_building_comp_in_fog_visibility_loop_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Replace
    @Override
    public boolean inFogTo(Team viewer){
        if(team == viewer || !state.rules.fog) return false;

        int size = block.size, of = block.sizeOffset, tx = tile.x, ty = tile.y;

        if(!isDiscovered(viewer)) return true;

        for(int x = 0; x < size; x++){
            for(int y = 0; y < size; y++){
                if(fogControl.isVisibleTile(viewer, tx + x + of, ty + y + of)){
                    return false;
                }
            }
        }

        return true;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var visible_tiles: Array = _args[7] if _args.size() > 7 and _args[7] is Array else []", source_text)
            self.assertIn('var in_fog_visibility_loop := {"method": "public boolean inFogTo(Team viewer){", "outer_loop": "for(int x = 0; x < size; x++){", "inner_loop": "for(int y = 0; y < size; y++){", "visible_tile_check": "if(fogControl.isVisibleTile(viewer, tx + x + of, ty + y + of)){", "visible_return": "return false;", "final_return": "return true;", "block_size_value": block_size_value, "block_size_offset": block_size_offset, "tile_x": tile_x, "tile_y": tile_y, "visible_tiles": visible_tiles}', source_text)
            self.assertIn("var checked_tiles: Array = []", source_text)
            self.assertIn("for x in range(block_size_value):", source_text)
            self.assertIn("for y in range(block_size_value):", source_text)
            self.assertIn("var check_x := tile_x + x + block_size_offset", source_text)
            self.assertIn("var check_y := tile_y + y + block_size_offset", source_text)
            self.assertIn('checked_tiles.append({"x": check_x, "y": check_y})', source_text)
            self.assertIn('in_fog_visibility_loop.merge({"in_fog": false, "checked_tiles": checked_tiles, "visible_tile": {"x": check_x, "y": check_y}})', source_text)
            self.assertIn('in_fog_visibility_loop.merge({"in_fog": true, "checked_tiles": checked_tiles, "visible_tile": null})', source_text)
            self.assertIn('"in_fog_visibility_loop_source_owner": "PortGame.source_building_in_fog_visibility_loop_state"', source_text)
            self.assertIn('"in_fog_visibility_loop": in_fog_visibility_loop', source_text)

    def test_emit_bridges_building_comp_killed_initial_side_effects_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    public void killed(){
        dead = true;
        Events.fire(new BlockDestroyEvent(tile));
        onDestroyed();
        if(tile != emptyTile){
            tile.remove();
        }
        remove();
        afterDestroyed();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_killed_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var tile_value: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('var killed_initial_side_effects := {"method": "public void killed(){", "tile_value": tile_value, "dead": true, "event": {"type": "BlockDestroyEvent", "tile": tile_value}, "on_destroyed_called": true, "next_step": "tile_remove_gate"}', source_text)
            self.assertIn("var tile_not_empty_tile := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn('var killed_removal_side_effects := {"method": "public void killed(){", "tile_not_empty_tile": tile_not_empty_tile, "tile_remove_gate": tile_not_empty_tile, "tile_remove_called": tile_not_empty_tile, "remove_called": true, "after_destroyed_called": true}', source_text)
            self.assertIn('"source_owner": "PortGame.source_building_killed_initial_side_effects_state"', source_text)
            self.assertIn('"killed_initial_side_effects_source_owner": "PortGame.source_building_killed_initial_side_effects_state"', source_text)
            self.assertIn('"killed_initial_side_effects": killed_initial_side_effects', source_text)
            self.assertIn('"killed_removal_side_effects_source_owner": "PortGame.source_building_killed_removal_side_effects_state"', source_text)
            self.assertIn('"killed_removal_side_effects": killed_removal_side_effects', source_text)

    def test_emit_bridges_building_comp_check_allow_update_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    public void checkAllowUpdate(){
        if(!allowUpdate()){
            enabled = false;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_checkAllowUpdate_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var current_enabled := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var allow_update_result := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_check_allow_update_state"', source_text)
            self.assertIn('"method": "public void checkAllowUpdate(){"', source_text)
            self.assertIn('"guard": "if(!allowUpdate()){"', source_text)
            self.assertIn('"disable": "enabled = false;"', source_text)
            self.assertIn('"check_allow_update_source_owner": "PortGame.source_building_check_allow_update_state"', source_text)
            self.assertIn('"check_allow_update": check_allow_update', source_text)

    def test_emit_bridges_building_comp_update_timescale_decay_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    public void update(){
        if((timeScaleDuration -= Time.delta) <= 0f){
            timeScale = 1f;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_update_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var current_time_scale := float(_args[0] if _args.size() > 0 else 1.0)", source_text)
            self.assertIn("var current_time_scale_duration := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var time_delta := float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var next_duration := current_time_scale_duration - time_delta", source_text)
            self.assertIn("if next_duration <= 0.0:", source_text)
            self.assertIn('update_timescale_decay.merge({"time_scale": 1.0, "time_scale_duration": next_duration})', source_text)
            self.assertIn('update_timescale_decay.merge({"time_scale": current_time_scale, "time_scale_duration": next_duration})', source_text)
            self.assertIn('"source_owner": "PortGame.source_building_update_timescale_decay_state"', source_text)
            self.assertIn('"field": "private transient float timeScale = 1f, timeScaleDuration;"', source_text)
            self.assertIn('"method": "public void update(){"', source_text)
            self.assertIn('"decay_gate": "if((timeScaleDuration -= Time.delta) <= 0f){"', source_text)
            self.assertIn('"reset": "timeScale = 1f;"', source_text)
            self.assertIn('"update_timescale_decay_source_owner": "PortGame.source_building_update_timescale_decay_state"', source_text)
            self.assertIn('"update_timescale_decay": update_timescale_decay', source_text)

    def test_emit_bridges_building_comp_update_ambient_sound_gate_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    public void update(){
        if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){
            control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_update_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var headless_mode := bool(_args[3] if _args.size() > 3 else false)", source_text)
            self.assertIn("var ambient_sound_value: Variant = _args[4] if _args.size() > 4 else null", source_text)
            self.assertIn("var sounds_none_value: Variant = _args[5] if _args.size() > 5 else null", source_text)
            self.assertIn("var should_ambient_sound_result := bool(_args[6] if _args.size() > 6 else false)", source_text)
            self.assertIn("var block_ambient_sound_volume := float(_args[7] if _args.size() > 7 else 0.0)", source_text)
            self.assertIn("var ambient_volume_value := float(_args[8] if _args.size() > 8 else 0.0)", source_text)
            self.assertIn("var should_loop: bool = not headless_mode and ambient_sound_value != sounds_none_value and should_ambient_sound_result", source_text)
            self.assertIn('update_ambient_sound_gate.merge({"loop_called": false, "sound": ambient_sound_value, "volume": 0.0})', source_text)
            self.assertIn('update_ambient_sound_gate.merge({"loop_called": true, "sound": ambient_sound_value, "volume": block_ambient_sound_volume * ambient_volume_value})', source_text)
            self.assertIn('"gate": "if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){"', source_text)
            self.assertIn('"loop_call": "control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());"', source_text)
            self.assertIn('"volume_expr": "block.ambientSoundVolume * ambientVolume()"', source_text)
            self.assertIn('"update_ambient_sound_gate_source_owner": "PortGame.source_building_update_ambient_sound_gate_state"', source_text)
            self.assertIn('"update_ambient_sound_gate": update_ambient_sound_gate', source_text)

    def test_emit_bridges_building_comp_update_consumption_call_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    public void update(){
        updateConsumption();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_update_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var update_consumption_call := {"method": "public void update(){", "call": "updateConsumption();", "update_consumption_called": true}', source_text)
            self.assertIn('"update_consumption_call_source_owner": "PortGame.source_building_update_consumption_call_state"', source_text)
            self.assertIn('"update_consumption_call": update_consumption_call', source_text)

    def test_emit_bridges_building_comp_update_tile_gate_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    public void update(){
        if(enabled || !block.noUpdateDisabled){
            updateTile();
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_update_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var enabled_state := bool(_args[9] if _args.size() > 9 else false)", source_text)
            self.assertIn("var block_no_update_disabled := bool(_args[10] if _args.size() > 10 else false)", source_text)
            self.assertIn("var update_tile_called := enabled_state or not block_no_update_disabled", source_text)
            self.assertIn('var update_tile_gate := {"method": "public void update(){", "gate": "if(enabled || !block.noUpdateDisabled){", "update_tile_call": "updateTile();", "enabled_state": enabled_state, "block_no_update_disabled": block_no_update_disabled, "update_tile_called": update_tile_called}', source_text)
            self.assertIn('"update_tile_gate_source_owner": "PortGame.source_building_update_tile_gate_state"', source_text)
            self.assertIn('"update_tile_gate": update_tile_gate', source_text)

    def test_emit_bridges_building_comp_update_fog_visibility_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    public void updateFogVisibility(){
        if(!wasVisible && !inFogTo(player.team())){
            visibleFlags |= (1L << player.team().id);
            wasVisible = true;
            renderer.blocks.updateShadow(self());
            renderer.minimap.update(tile);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_updateFogVisibility_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var was_visible := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var in_fog_to_player_team := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var visible_flags := int(_args[2] if _args.size() > 2 else 0)", source_text)
            self.assertIn("var player_team_id := int(_args[3] if _args.size() > 3 else 0)", source_text)
            self.assertIn("var self_state: Variant = _args[4] if _args.size() > 4 else null", source_text)
            self.assertIn("var tile_state: Variant = _args[5] if _args.size() > 5 else null", source_text)
            self.assertIn("var should_update := not was_visible and not in_fog_to_player_team", source_text)
            self.assertIn("var updated_flags := visible_flags | (1 << player_team_id)", source_text)
            self.assertIn('"comment": "/** When a block is newly revealed outside of camera view range, it is updated on the minimap. */"', source_text)
            self.assertIn('"gate": "if(!wasVisible && !inFogTo(player.team())){"', source_text)
            self.assertIn('"visible_flags": updated_flags', source_text)
            self.assertIn('"update_shadow": self_state', source_text)
            self.assertIn('"minimap_update": tile_state', source_text)
            self.assertIn('"source_owner": "PortGame.source_building_update_fog_visibility_state"', source_text)
            self.assertIn('"update_fog_visibility_source_owner": "PortGame.source_building_update_fog_visibility_state"', source_text)
            self.assertIn('"update_fog_visibility": update_fog_visibility', source_text)

    def test_emit_bridges_building_comp_hitbox_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    public void hitbox(Rect out){
        out.setCentered(x, y, block.size * tilesize, block.size * tilesize);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_hitbox_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var world_x := float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var world_y := float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var block_size_value := int(_args[2] if _args.size() > 2 else 0)", source_text)
            self.assertIn("var source_tilesize := float(_args[3] if _args.size() > 3 else 8.0)", source_text)
            self.assertIn("var hitbox_size := float(block_size_value) * source_tilesize", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_hitbox_state"', source_text)
            self.assertIn('"method": "public void hitbox(Rect out){"', source_text)
            self.assertIn('"set_centered_expr": "out.setCentered(x, y, block.size * tilesize, block.size * tilesize);"', source_text)
            self.assertIn('"hitbox_size_expr": "block.size * tilesize"', source_text)
            self.assertIn('"set_centered": {"x": world_x, "y": world_y, "width": hitbox_size, "height": hitbox_size}', source_text)

    def test_emit_bridges_building_comp_to_string_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    @Replace
    public String toString(){
        return "Building#" + id() + "[" + tileX() + "," + tileY() + "]:" + block;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_toString_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var id_value := int(_args[0] if _args.size() > 0 else 0)", source_text)
            self.assertIn("var tile_x_value := int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("var tile_y_value := int(_args[2] if _args.size() > 2 else 0)", source_text)
            self.assertIn("var block_value: Variant = _args[3] if _args.size() > 3 else null", source_text)
            self.assertIn('var to_string_result := "Building#" + str(id_value) + "[" + str(tile_x_value) + "," + str(tile_y_value) + "]:" + str(block_value)', source_text)
            self.assertIn('"source_owner": "PortGame.source_building_to_string_state"', source_text)
            self.assertIn('"override_annotation": "@Override"', source_text)
            self.assertIn('"replace_annotation": "@Replace"', source_text)
            self.assertIn('"method": "public String toString(){"', source_text)
            self.assertIn('"return_expr": "return \\"Building#\\" + id() + \\"[\\" + tileX() + \\",\\" + tileY() + \\"]:\\" + block;"', source_text)
            self.assertIn('"id_value": id_value', source_text)
            self.assertIn('"tile_x_value": tile_x_value', source_text)
            self.assertIn('"tile_y_value": tile_y_value', source_text)
            self.assertIn('"block_value": block_value', source_text)
            self.assertIn('"to_string": to_string_result', source_text)

    def test_emit_bridges_building_tether_comp_update_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingTetherComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingTetherComp{
    public void update(){
        if(building == null || !building.isValid() || building.team != team){
            Call.unitDespawn(self());
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingTetherComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_update_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var building_exists := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var building_is_valid := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var building_team_value: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("var team_value: Variant = _args[3] if _args.size() > 3 else null", source_text)
            self.assertIn("var unit_id := int(_args[4] if _args.size() > 4 else 0)", source_text)
            self.assertIn("var guard: bool = (not building_exists) or (not building_is_valid) or building_team_value != team_value", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_tether_update_state"', source_text)
            self.assertIn('"method": "public void update(){"', source_text)
            self.assertIn('"guard_expr": "if(building == null || !building.isValid() || building.team != team){"', source_text)
            self.assertIn('"call": "Call.unitDespawn(self())"', source_text)
            self.assertIn('"unit": unit_id', source_text)
            self.assertIn('"despawn": despawn_call', source_text)

    def test_emit_bridges_unit_tether_comp_after_read_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "UnitTetherComp.java").write_text(
                """
package mindustry.entities.comp;

class UnitTetherComp{
    public void afterRead(){
        if(spawnerUnitId != -1) spawner = Groups.unit.getByID(spawnerUnitId);
        spawnerUnitId = -1;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "UnitTetherComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_afterRead_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var spawner_unit_id := int(_args[0] if _args.size() > 0 else -1)", source_text)
            self.assertIn("var groups_unit_get_by_id_result: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var guard: bool = spawner_unit_id != -1", source_text)
            self.assertIn("var spawner_value: Variant = null", source_text)
            self.assertIn("var groups_unit_get_by_id_call: Variant = null", source_text)
            self.assertIn("if guard:", source_text)
            self.assertIn('groups_unit_get_by_id_call = {"call": "Groups.unit.getByID(spawnerUnitId)", "id": spawner_unit_id}', source_text)
            self.assertIn("spawner_value = groups_unit_get_by_id_result", source_text)
            self.assertIn('"source_owner": "PortGame.source_unit_tether_after_read_state"', source_text)
            self.assertIn('"method": "public void afterRead(){"', source_text)
            self.assertIn('"guard_expr": "if(spawnerUnitId != -1) spawner = Groups.unit.getByID(spawnerUnitId);"', source_text)
            self.assertIn('"reset_expr": "spawnerUnitId = -1;"', source_text)
            self.assertIn('"spawnerUnitId": -1', source_text)

    def test_emit_bridges_unit_tether_comp_after_sync_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "UnitTetherComp.java").write_text(
                """
package mindustry.entities.comp;

class UnitTetherComp{
    public void afterSync(){
        if(spawnerUnitId != -1) spawner = Groups.unit.getByID(spawnerUnitId);
        spawnerUnitId = -1;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "UnitTetherComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_afterSync_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var spawner_unit_id := int(_args[0] if _args.size() > 0 else -1)", source_text)
            self.assertIn("var groups_unit_get_by_id_result: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var guard: bool = spawner_unit_id != -1", source_text)
            self.assertIn("var spawner_value: Variant = null", source_text)
            self.assertIn("var groups_unit_get_by_id_call: Variant = null", source_text)
            self.assertIn("if guard:", source_text)
            self.assertIn('groups_unit_get_by_id_call = {"call": "Groups.unit.getByID(spawnerUnitId)", "id": spawner_unit_id}', source_text)
            self.assertIn("spawner_value = groups_unit_get_by_id_result", source_text)
            self.assertIn('"source_owner": "PortGame.source_unit_tether_after_sync_state"', source_text)
            self.assertIn('"method": "public void afterSync(){"', source_text)
            self.assertIn('"guard_expr": "if(spawnerUnitId != -1) spawner = Groups.unit.getByID(spawnerUnitId);"', source_text)
            self.assertIn('"reset_expr": "spawnerUnitId = -1;"', source_text)
            self.assertIn('"spawnerUnitId": -1', source_text)

    def test_emit_bridges_unit_tether_comp_update_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "UnitTetherComp.java").write_text(
                """
package mindustry.entities.comp;

class UnitTetherComp{
    public void update(){
        if(spawner == null || !spawner.isValid() || spawner.team != team){
            Call.unitDespawn(self());
        }else{
            spawnerUnitId = spawner.id;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "UnitTetherComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_update_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var spawner_exists := bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var spawner_is_valid := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var spawner_team_value: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("var team_value: Variant = _args[3] if _args.size() > 3 else null", source_text)
            self.assertIn("var unit_id := int(_args[4] if _args.size() > 4 else 0)", source_text)
            self.assertIn("var spawner_id := int(_args[5] if _args.size() > 5 else -1)", source_text)
            self.assertIn("var guard: bool = (not spawner_exists) or (not spawner_is_valid) or spawner_team_value != team_value", source_text)
            self.assertIn("var next_spawner_unit_id := -1", source_text)
            self.assertIn("if not guard:", source_text)
            self.assertIn("next_spawner_unit_id = spawner_id", source_text)
            self.assertIn('"source_owner": "PortGame.source_unit_tether_update_state"', source_text)
            self.assertIn('"method": "public void update(){"', source_text)
            self.assertIn('"guard_expr": "if(spawner == null || !spawner.isValid() || spawner.team != team){"', source_text)
            self.assertIn('"else_expr": "}else{"', source_text)
            self.assertIn('"assign_expr": "spawnerUnitId = spawner.id;"', source_text)
            self.assertIn('"call": "Call.unitDespawn(self())"', source_text)
            self.assertIn('"unit": unit_id', source_text)
            self.assertIn('"spawnerUnitId": next_spawner_unit_id', source_text)

    def test_emit_bridges_building_comp_hit_size_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Override
    public float hitSize(){
        return tile.block().size * tilesize;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_hitSize_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var block_size_value := int(_args[0] if _args.size() > 0 else 0)", source_text)
            self.assertIn("var source_tilesize := float(_args[1] if _args.size() > 1 else 8.0)", source_text)
            self.assertIn("var hit_size := float(block_size_value) * source_tilesize", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_hit_size"', source_text)
            self.assertIn('"override": "@Override"', source_text)
            self.assertIn('"method": "public float hitSize(){"', source_text)
            self.assertIn('"return_expr": "return tile.block().size * tilesize;"', source_text)
            self.assertIn('"block_size_value": block_size_value', source_text)
            self.assertIn('"source_tilesize": source_tilesize', source_text)
            self.assertIn('"hit_size": hit_size', source_text)

    def test_emit_bridges_building_comp_kill_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Replace
    @Override
    public void kill(){
        Call.buildDestroyed(self());
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_kill_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var self_state: Variant = _args[0] if _args.size() > 0 else {}", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_kill_state"', source_text)
            self.assertIn('"replace": "@Replace"', source_text)
            self.assertIn('"override": "@Override"', source_text)
            self.assertIn('"method": "public void kill(){"', source_text)
            self.assertIn('"build_destroyed_call": "Call.buildDestroyed(self());"', source_text)
            self.assertIn('"self_state": self_state', source_text)

    def test_emit_bridges_building_comp_damage_dead_guard_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Replace
    @Override
    public void damage(float damage){
        if(dead()) return;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_damage_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var damage_amount := float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var dead_state := bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn('"source_owner": "PortGame.source_building_damage_dead_guard_state"', source_text)
            self.assertIn('"replace": "@Replace"', source_text)
            self.assertIn('"override": "@Override"', source_text)
            self.assertIn('"method": "public void damage(float damage){"', source_text)
            self.assertIn('"dead_guard": "if(dead()) return;"', source_text)
            self.assertIn('"damage_amount": damage_amount', source_text)
            self.assertIn('"dead_state": dead_state', source_text)
            self.assertIn('"returned": dead_state', source_text)
            self.assertIn('"continues": not dead_state', source_text)

    def test_emit_bridges_building_comp_damage_block_health_scale_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Replace
    @Override
    public void damage(float damage){
        if(dead()) return;

        float dm = state.rules.blockHealth(team);
        lastDamageTime = Time.time;

        if(Mathf.zero(dm)){
            damage = health + 1;
        }else{
            damage /= dm;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var health := float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var block_health_multiplier := float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var source_time := float(_args[4] if _args.size() > 4 else 0.0)", source_text)
            self.assertIn("var block_health_scale := {}", source_text)
            self.assertIn("if not dead_state:", source_text)
            self.assertIn("if is_zero_approx(block_health_multiplier):", source_text)
            self.assertIn('"damage": health + 1.0', source_text)
            self.assertIn('"damage": damage_amount / block_health_multiplier', source_text)
            self.assertIn('"last_damage_time": source_time', source_text)
            self.assertIn('"block_health_source_owner": "PortGame.source_building_damage_block_health_scale_state"', source_text)
            self.assertIn('"block_health": "float dm = state.rules.blockHealth(team);"', source_text)
            self.assertIn('"last_damage_time_expr": "lastDamageTime = Time.time;"', source_text)
            self.assertIn('"zero_guard": "if(Mathf.zero(dm)){"', source_text)
            self.assertIn('"zero_assignment": "damage = health + 1;"', source_text)
            self.assertIn('"scale_assignment": "damage /= dm;"', source_text)
            self.assertIn('"block_health_scale": block_health_scale', source_text)

    def test_emit_bridges_building_comp_damage_handle_damage_gate_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Replace
    @Override
    public void damage(float damage){
        if(dead()) return;

        float dm = state.rules.blockHealth(team);
        lastDamageTime = Time.time;

        if(Mathf.zero(dm)){
            damage = health + 1;
        }else{
            damage /= dm;
        }

        //TODO handle this better on the client.
        if(!net.client()){
            health -= handleDamage(damage);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var net_client := bool(_args[5] if _args.size() > 5 else false)", source_text)
            self.assertIn("var handled_damage := float(_args[6] if _args.size() > 6 else 0.0)", source_text)
            self.assertIn("var handle_damage_gate := {}", source_text)
            self.assertIn('var scaled_damage := float(block_health_scale.get("damage", damage_amount))', source_text)
            self.assertIn("if not net_client:", source_text)
            self.assertIn('"health": health - handled_damage', source_text)
            self.assertIn('"handle_damage_called": true', source_text)
            self.assertIn('"handled_damage": null', source_text)
            self.assertIn('"handle_damage_source_owner": "PortGame.source_building_damage_handle_damage_gate_state"', source_text)
            self.assertIn('"client_comment": "//TODO handle this better on the client."', source_text)
            self.assertIn('"client_guard": "if(!net.client()){"', source_text)
            self.assertIn('"health_assignment": "health -= handleDamage(damage);"', source_text)
            self.assertIn('"handle_damage_gate": handle_damage_gate', source_text)

    def test_emit_bridges_building_comp_damage_health_changed_call_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Replace
    @Override
    public void damage(float damage){
        if(dead()) return;

        float dm = state.rules.blockHealth(team);
        lastDamageTime = Time.time;

        if(Mathf.zero(dm)){
            damage = health + 1;
        }else{
            damage /= dm;
        }

        //TODO handle this better on the client.
        if(!net.client()){
            health -= handleDamage(damage);
        }

        healthChanged();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn('"health_changed_source_owner": "PortGame.source_building_damage_health_changed_call_state"', source_text)
            self.assertIn('"health_changed_call": "healthChanged();"', source_text)
            self.assertIn("var health_changed_call_state := {}", source_text)
            self.assertIn('health_changed_call_state = {"health_changed": true}', source_text)
            self.assertIn('"health_changed_call_state": health_changed_call_state', source_text)

    def test_emit_bridges_building_comp_damage_destroy_gate_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuildingComp.java").write_text(
                """
package mindustry.entities.comp;

class BuildingComp{
    @Replace
    @Override
    public void damage(float damage){
        if(dead()) return;

        float dm = state.rules.blockHealth(team);
        lastDamageTime = Time.time;

        if(Mathf.zero(dm)){
            damage = health + 1;
        }else{
            damage /= dm;
        }

        //TODO handle this better on the client.
        if(!net.client()){
            health -= handleDamage(damage);
        }

        healthChanged();

        if(health <= 0){
            Call.buildDestroyed(self());
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var self_state: Variant = _args[7] if _args.size() > 7 else {}", source_text)
            self.assertIn("var destroy_gate_state := {}", source_text)
            self.assertIn('destroy_gate_state = {"destroy_gate": "if(health <= 0){", "build_destroyed_call": "Call.buildDestroyed(self());", "build_destroyed_called": true, "build_destroyed": self_state}', source_text)
            self.assertIn('"destroy_gate_source_owner": "PortGame.source_building_damage_destroy_gate_state"', source_text)
            self.assertIn('"destroy_gate": destroy_gate_state', source_text)

    def test_emit_bridges_child_comp_add_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "ChildComp.java").write_text(
                """
package mindustry.entities.comp;

class ChildComp{
    public void add(){
        if(parent != null){
            offsetX = x - parent.getX();
            offsetY = y - parent.getY();
            if(rotWithParent){
                if(parent instanceof Rotc r){
                    offsetPos = -r.rotation();
                    offsetRot = rotation - r.rotation();
                }else if(parent instanceof RotBlock rot){
                    offsetPos = -rot.buildRotation();
                    offsetRot = rotation - rot.buildRotation();
                }
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "ChildComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_add_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var child_state: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}", source_text)
            self.assertIn("var parent_guard: bool = bool(child_state.get(\"parent_exists\", false))", source_text)
            self.assertIn("var next_offset_x: float = offset_x", source_text)
            self.assertIn("next_offset_x = x - parent_get_x", source_text)
            self.assertIn("next_offset_y = y - parent_get_y", source_text)
            self.assertIn("next_offset_pos = -parent_rotc_rotation", source_text)
            self.assertIn("next_offset_rot = rotation - parent_rotc_rotation", source_text)
            self.assertIn("next_offset_pos = -parent_rotblock_build_rotation", source_text)
            self.assertIn("next_offset_rot = rotation - parent_rotblock_build_rotation", source_text)
            self.assertIn('"source_owner": "PortGame.source_child_add_state"', source_text)
            self.assertIn('"method": "public void add(){"', source_text)
            self.assertIn('"parent_guard_expr": "if(parent != null){"', source_text)
            self.assertIn('"offsetX_expr": "offsetX = x - parent.getX();"', source_text)
            self.assertIn('"parent_rotc_guard_expr": "if(parent instanceof Rotc r){"', source_text)
            self.assertIn('"parent_rotblock_guard_expr": "}else if(parent instanceof RotBlock rot){"', source_text)

    def test_emit_bridges_child_comp_update_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "ChildComp.java").write_text(
                """
package mindustry.entities.comp;

class ChildComp{
    public void add(){
    }

    public void update(){
        if(parent != null){
            if(rotWithParent){
                if(parent instanceof Rotc r){
                    x = parent.getX() + Angles.trnsx(r.rotation() + offsetPos, offsetX, offsetY);
                    y = parent.getY() + Angles.trnsy(r.rotation() + offsetPos, offsetX, offsetY);
                    rotation = r.rotation() + offsetRot;
                }else if(parent instanceof RotBlock rot){
                    x = parent.getX() + Angles.trnsx(rot.buildRotation() + offsetPos, offsetX, offsetY);
                    y = parent.getY() + Angles.trnsy(rot.buildRotation() + offsetPos, offsetX, offsetY);
                    rotation = rot.buildRotation() + offsetRot;
                }
            }else{
                x = parent.getX() + offsetX;
                y = parent.getY() + offsetY;
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "ChildComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_update_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var child_state: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}", source_text)
            self.assertIn("var parent_guard: bool = bool(child_state.get(\"parent_exists\", false))", source_text)
            self.assertIn("var next_x: float = x", source_text)
            self.assertIn("var next_y: float = y", source_text)
            self.assertIn("var next_rotation: float = rotation", source_text)
            self.assertIn("var _source_arc_angles_trns_vec := func(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:", source_text)
            self.assertIn("var trns_vec_rotc: Dictionary = _source_arc_angles_trns_vec.call(parent_rotc_rotation + offset_pos, offset_x, offset_y)", source_text)
            self.assertIn("next_x = parent_get_x + float(trns_vec_rotc.get(\"x\", 0.0))", source_text)
            self.assertIn("next_y = parent_get_y + float(trns_vec_rotc.get(\"y\", 0.0))", source_text)
            self.assertIn("next_rotation = parent_rotc_rotation + offset_rot", source_text)
            self.assertIn("var trns_vec_rotblock: Dictionary = _source_arc_angles_trns_vec.call(parent_rotblock_build_rotation + offset_pos, offset_x, offset_y)", source_text)
            self.assertIn("next_rotation = parent_rotblock_build_rotation + offset_rot", source_text)
            self.assertIn("next_x = parent_get_x + offset_x", source_text)
            self.assertIn("next_y = parent_get_y + offset_y", source_text)
            self.assertIn('"source_owner": "PortGame.source_child_update_state"', source_text)
            self.assertIn('"method": "public void update(){"', source_text)
            self.assertIn('"trnsx_rotc_expr": "x = parent.getX() + Angles.trnsx(r.rotation() + offsetPos, offsetX, offsetY);"', source_text)
            self.assertIn('"trnsy_rotblock_expr": "y = parent.getY() + Angles.trnsy(rot.buildRotation() + offsetPos, offsetX, offsetY);"', source_text)

    def test_emit_bridges_pos_comp_set_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "PosComp.java").write_text(
                """
package mindustry.entities.comp;

class PosComp{
    void set(float x, float y){
        this.x = x;
        this.y = y;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "PosComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_set_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var x_value: float = float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var y_value: float = float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn('"source_owner": "PortGame.source_pos_set_state"', source_text)
            self.assertIn('"method": "void set(float x, float y){"', source_text)
            self.assertIn('"x_assign_expr": "this.x = x;"', source_text)
            self.assertIn('"y_assign_expr": "this.y = y;"', source_text)
            self.assertIn('"x": x_value', source_text)
            self.assertIn('"y": y_value', source_text)

    def test_emit_bridges_shielder_comp_absorb_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "ShielderComp.java").write_text(
                """
package mindustry.entities.comp;

class ShielderComp{
    void absorb(){

    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "ShielderComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_absorb_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_shielder_absorb_state"', source_text)
            self.assertIn('"method": "void absorb(){"', source_text)
            self.assertIn('"empty_body": "void absorb(){\\n\\n    }"', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_sync_comp_snap_sync_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "SyncComp.java").write_text(
                """
package mindustry.entities.comp;

class SyncComp{
    void snapSync(){}
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "SyncComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_snapSync_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_sync_snap_sync_state"', source_text)
            self.assertIn('"method": "void snapSync(){}"', source_text)
            self.assertIn('"empty_body": "void snapSync(){}"', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_sync_comp_snap_interpolation_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "SyncComp.java").write_text(
                """
package mindustry.entities.comp;

class SyncComp{
    void snapInterpolation(){}
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "SyncComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_snapInterpolation_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_sync_snap_interpolation_state"', source_text)
            self.assertIn('"method": "void snapInterpolation(){}"', source_text)
            self.assertIn('"empty_body": "void snapInterpolation(){}"', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_sync_comp_read_sync_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "SyncComp.java").write_text(
                """
package mindustry.entities.comp;

class SyncComp{
    void readSync(Reads read){}
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "SyncComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_readSync_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_sync_read_sync_state"', source_text)
            self.assertIn('"method": "void readSync(Reads read){}"', source_text)
            self.assertIn('"empty_body": "void readSync(Reads read){}"', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_sync_comp_write_sync_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "SyncComp.java").write_text(
                """
package mindustry.entities.comp;

class SyncComp{
    void writeSync(Writes write){}
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "SyncComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_writeSync_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_sync_write_sync_state"', source_text)
            self.assertIn('"method": "void writeSync(Writes write){}"', source_text)
            self.assertIn('"empty_body": "void writeSync(Writes write){}"', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_sync_comp_read_sync_manual_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "SyncComp.java").write_text(
                """
package mindustry.entities.comp;

class SyncComp{
    void readSyncManual(FloatBuffer buffer){}
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "SyncComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_readSyncManual_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_sync_read_sync_manual_state"', source_text)
            self.assertIn('"method": "void readSyncManual(FloatBuffer buffer){}"', source_text)
            self.assertIn('"empty_body": "void readSyncManual(FloatBuffer buffer){}"', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_sync_comp_write_sync_manual_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "SyncComp.java").write_text(
                """
package mindustry.entities.comp;

class SyncComp{
    void writeSyncManual(FloatBuffer buffer){}
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "SyncComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_writeSyncManual_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_sync_write_sync_manual_state"', source_text)
            self.assertIn('"method": "void writeSyncManual(FloatBuffer buffer){}"', source_text)
            self.assertIn('"empty_body": "void writeSyncManual(FloatBuffer buffer){}"', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_sync_comp_after_sync_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "SyncComp.java").write_text(
                """
package mindustry.entities.comp;

class SyncComp{
    void afterSync(){}
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "SyncComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_afterSync_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_sync_after_sync_state"', source_text)
            self.assertIn('"method": "void afterSync(){}"', source_text)
            self.assertIn('"empty_body": "void afterSync(){}"', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_sync_comp_interpolate_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "SyncComp.java").write_text(
                """
package mindustry.entities.comp;

class SyncComp{
    void interpolate(){}
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "SyncComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_interpolate_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_sync_interpolate_state"', source_text)
            self.assertIn('"method": "void interpolate(){}"', source_text)
            self.assertIn('"empty_body": "void interpolate(){}"', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_sync_comp_is_sync_hidden_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "SyncComp.java").write_text(
                """
package mindustry.entities.comp;

class SyncComp{
    boolean isSyncHidden(Player player){
        return false;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "SyncComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_isSyncHidden_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var player: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_sync_is_sync_hidden_state"', source_text)
            self.assertIn('"method": "boolean isSyncHidden(Player player){"', source_text)
            self.assertIn('"player": player', source_text)
            self.assertIn('"return_expr": "return false;"', source_text)
            self.assertIn('"is_sync_hidden": false', source_text)

    def test_emit_bridges_sync_comp_handle_sync_hidden_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "SyncComp.java").write_text(
                """
package mindustry.entities.comp;

class SyncComp{
    void handleSyncHidden(){

    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "SyncComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_handleSyncHidden_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_sync_handle_sync_hidden_state"', source_text)
            self.assertIn('"method": "void handleSyncHidden(){"', source_text)
            self.assertIn('"empty_body": "void handleSyncHidden(){\\n\\n}"', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_sync_comp_update_interpolate_gate_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "SyncComp.java").write_text(
                """
package mindustry.entities.comp;

class SyncComp{
    public void update(){
        //interpolate the player if:
        //- this is a client and the entity is everything except the local player
        //- this is a server and the entity is a remote player
        if((Vars.net.client() && !isLocal()) || isRemote()){
            interpolate();
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "SyncComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_update_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var net_client: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var is_local: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var is_remote: bool = bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("var interpolate_called: bool = (net_client and not is_local) or is_remote", source_text)
            self.assertIn("var interpolate_result: Variant = null", source_text)
            self.assertIn("if interpolate_called:", source_text)
            self.assertIn("\t\tinterpolate_result = java_method_interpolate_7([])", source_text)
            self.assertNotIn("java_method_interpolate_7([]) if interpolate_called else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_sync_update_interpolate_state"', source_text)
            self.assertIn('"method": "public void update(){"', source_text)
            self.assertIn('"condition": "if((Vars.net.client() && !isLocal()) || isRemote()){"', source_text)
            self.assertIn('"interpolate_call": "interpolate();"', source_text)
            self.assertIn('"interpolate_called": interpolate_called', source_text)

    def test_emit_bridges_sync_comp_remove_client_removed_entity_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "SyncComp.java").write_text(
                """
package mindustry.entities.comp;

class SyncComp{
    public void remove(){
        //notify client of removal
        if(Vars.net.client()){
            Vars.netClient.addRemovedEntity(id());
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "SyncComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_remove_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var net_client: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var entity_id: int = int(_args[1] if _args.size() > 1 else -1)", source_text)
            self.assertIn("var add_removed_entity_call: Variant = null", source_text)
            self.assertIn("if net_client:", source_text)
            self.assertIn('"source_owner": "PortGame.source_sync_remove_client_removed_entity_state"', source_text)
            self.assertIn('"method": "public void remove(){"', source_text)
            self.assertIn('"condition": "if(Vars.net.client()){"', source_text)
            self.assertIn('"add_removed_entity_call": add_removed_entity_call', source_text)
            self.assertIn('"id_call": "id()"', source_text)

    def test_emit_bridges_block_unit_comp_ammof_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BlockUnitComp.java").write_text(
                """
package mindustry.entities.comp;

class BlockUnitComp{
    transient float ammo;

    public float ammof(){
        return ammo;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BlockUnitComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_ammof_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var ammo: float = float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn('"source_owner": "PortGame.source_block_unit_ammof_state"', source_text)
            self.assertIn('"method": "public float ammof(){"', source_text)
            self.assertIn('"return_expr": "return ammo;"', source_text)
            self.assertIn('"ammo": ammo', source_text)

    def test_emit_bridges_block_unit_comp_icon_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BlockUnitComp.java").write_text(
                """
package mindustry.entities.comp;

class BlockUnitComp{
    public TextureRegion icon(){
        return tile.block.uiIcon;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BlockUnitComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_icon_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var tile_block_ui_icon: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_block_unit_icon_state"', source_text)
            self.assertIn('"method": "public TextureRegion icon(){"', source_text)
            self.assertIn('"return_expr": "return tile.block.uiIcon;"', source_text)
            self.assertIn('"tile_block_ui_icon": tile_block_ui_icon', source_text)

    def test_emit_bridges_block_unit_comp_killed_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BlockUnitComp.java").write_text(
                """
package mindustry.entities.comp;

class BlockUnitComp{
    public void killed(){
        tile.kill();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BlockUnitComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_killed_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var tile_kill_call: String = \"tile.kill();\"", source_text)
            self.assertIn("var tile_kill_called: bool = true", source_text)
            self.assertIn('"source_owner": "PortGame.source_block_unit_killed_state"', source_text)
            self.assertIn('"method": "public void killed(){"', source_text)
            self.assertIn('"tile_kill_call": tile_kill_call', source_text)
            self.assertIn('"tile_kill_called": tile_kill_called', source_text)

    def test_emit_bridges_block_unit_comp_damage_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BlockUnitComp.java").write_text(
                """
package mindustry.entities.comp;

class BlockUnitComp{
    public void damage(float v, boolean b){
        tile.damage(v, b);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BlockUnitComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_damage_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var v: float = float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var b: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var tile_damage_call: String = \"tile.damage(v, b);\"", source_text)
            self.assertIn("var tile_damage_called: bool = true", source_text)
            self.assertIn('"source_owner": "PortGame.source_block_unit_damage_state"', source_text)
            self.assertIn('"method": "public void damage(float v, boolean b){"', source_text)
            self.assertIn('"tile_damage_call": tile_damage_call', source_text)
            self.assertIn('"tile_damage_called": tile_damage_called', source_text)
            self.assertIn('"v": v', source_text)
            self.assertIn('"b": b', source_text)

    def test_emit_bridges_block_unit_comp_dead_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BlockUnitComp.java").write_text(
                """
package mindustry.entities.comp;

class BlockUnitComp{
    public boolean dead(){
        return tile == null || tile.dead();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BlockUnitComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_dead_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var tile_null: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var tile_dead: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var dead: bool = tile_null or tile_dead", source_text)
            self.assertIn('"source_owner": "PortGame.source_block_unit_dead_state"', source_text)
            self.assertIn('"method": "public boolean dead(){"', source_text)
            self.assertIn('"return_expr": "return tile == null || tile.dead();"', source_text)
            self.assertIn('"tile_null": tile_null', source_text)
            self.assertIn('"tile_dead": tile_dead', source_text)
            self.assertIn('"dead": dead', source_text)

    def test_emit_bridges_block_unit_comp_is_valid_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BlockUnitComp.java").write_text(
                """
package mindustry.entities.comp;

class BlockUnitComp{
    public boolean isValid(){
        return tile != null && tile.isValid();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BlockUnitComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_isValid_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var tile_exists: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var tile_is_valid: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var is_valid: bool = tile_exists and tile_is_valid", source_text)
            self.assertIn('"source_owner": "PortGame.source_block_unit_is_valid_state"', source_text)
            self.assertIn('"method": "public boolean isValid(){"', source_text)
            self.assertIn('"return_expr": "return tile != null && tile.isValid();"', source_text)
            self.assertIn('"tile_exists": tile_exists', source_text)
            self.assertIn('"tile_is_valid": tile_is_valid', source_text)
            self.assertIn('"is_valid": is_valid', source_text)

    def test_emit_bridges_block_unit_comp_is_added_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BlockUnitComp.java").write_text(
                """
package mindustry.entities.comp;

class BlockUnitComp{
    public boolean isAdded(){
        return tile != null && tile.isValid();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BlockUnitComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_isAdded_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var tile_exists: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var tile_is_valid: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var is_added: bool = tile_exists and tile_is_valid", source_text)
            self.assertIn('"source_owner": "PortGame.source_block_unit_is_added_state"', source_text)
            self.assertIn('"method": "public boolean isAdded(){"', source_text)
            self.assertIn('"return_expr": "return tile != null && tile.isValid();"', source_text)
            self.assertIn('"tile_exists": tile_exists', source_text)
            self.assertIn('"tile_is_valid": tile_is_valid', source_text)
            self.assertIn('"is_added": is_added', source_text)

    def test_emit_bridges_block_unit_comp_team_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BlockUnitComp.java").write_text(
                """
package mindustry.entities.comp;

class BlockUnitComp{
    public void team(Team team){
        if(tile != null && this.team != team){
            this.team = team;
            if(tile.team != team){
                tile.changeTeam(team);
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BlockUnitComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_team_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var tile_exists: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var this_team: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var team: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("var tile_team: Variant = _args[3] if _args.size() > 3 else null", source_text)
            self.assertIn("var outer_guard: bool = tile_exists and this_team != team", source_text)
            self.assertIn("var this_team_after: Variant = this_team", source_text)
            self.assertIn("var inner_guard: bool = false", source_text)
            self.assertIn("var tile_change_team_call: Variant = null", source_text)
            self.assertIn("var tile_change_team_called: bool = false", source_text)
            self.assertIn("if outer_guard:", source_text)
            self.assertIn("this_team_after = team", source_text)
            self.assertIn("inner_guard = tile_team != team", source_text)
            self.assertIn("if inner_guard:", source_text)
            self.assertIn('tile_change_team_call = {"call": "tile.changeTeam(team);", "team": team}', source_text)
            self.assertIn("tile_change_team_called = true", source_text)
            self.assertIn('"source_owner": "PortGame.source_block_unit_team_state"', source_text)
            self.assertIn('"method": "public void team(Team team){"', source_text)
            self.assertIn('"outer_guard_expr": "if(tile != null && this.team != team){"', source_text)
            self.assertIn('"this_team_assignment_expr": "this.team = team;"', source_text)
            self.assertIn('"inner_guard_expr": "if(tile.team != team){"', source_text)
            self.assertIn('"tile_change_team_call_expr": "tile.changeTeam(team);"', source_text)
            self.assertIn('"this_team_after": this_team_after', source_text)
            self.assertIn('"tile_change_team_called": tile_change_team_called', source_text)

    def test_emit_bridges_block_unit_comp_update_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BlockUnitComp.java").write_text(
                """
package mindustry.entities.comp;

class BlockUnitComp{
    public void update(){
        if(tile != null){
            team = tile.team;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BlockUnitComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_update_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var tile_exists: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var team: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var tile_team: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("var tile_guard: bool = tile_exists", source_text)
            self.assertIn("var team_after: Variant = team", source_text)
            self.assertIn("if tile_guard:", source_text)
            self.assertIn("team_after = tile_team", source_text)
            self.assertIn('"source_owner": "PortGame.source_block_unit_update_state"', source_text)
            self.assertIn('"method": "public void update(){"', source_text)
            self.assertIn('"guard_expr": "if(tile != null){"', source_text)
            self.assertIn('"team_assignment_expr": "team = tile.team;"', source_text)
            self.assertIn('"tile_guard": tile_guard', source_text)
            self.assertIn('"team_after": team_after', source_text)

    def test_emit_bridges_block_unit_comp_tile_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BlockUnitComp.java").write_text(
                """
package mindustry.entities.comp;

class BlockUnitComp{
    public void tile(Building tile){
        this.tile = tile;

        //sets up block stats
        maxHealth(tile.block.health);
        health(tile.health);
        hitSize(tile.block.size * tilesize * 0.7f);
        set(tile);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BlockUnitComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_tile_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var tile: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var tile_block_health: float = float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var tile_health: float = float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var tile_block_size: float = float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var tilesize: float = float(_args[4] if _args.size() > 4 else 0.0)", source_text)
            self.assertIn("var hit_size: float = tile_block_size * tilesize * 0.7", source_text)
            self.assertIn('var max_health_call: Dictionary = {"call": "maxHealth(tile.block.health);", "value": tile_block_health}', source_text)
            self.assertIn('var health_call: Dictionary = {"call": "health(tile.health);", "value": tile_health}', source_text)
            self.assertIn('var hit_size_call: Dictionary = {"call": "hitSize(tile.block.size * tilesize * 0.7f);", "value": hit_size}', source_text)
            self.assertIn('var set_call: Dictionary = {"call": "set(tile);", "tile": tile}', source_text)
            self.assertIn('"source_owner": "PortGame.source_block_unit_tile_state"', source_text)
            self.assertIn('"method": "public void tile(Building tile){"', source_text)
            self.assertIn('"tile_assignment_expr": "this.tile = tile;"', source_text)
            self.assertIn('"comment": "//sets up block stats"', source_text)
            self.assertIn('"hit_size": hit_size', source_text)
            self.assertIn('"set_call": set_call', source_text)

    def test_emit_bridges_block_unit_comp_add_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BlockUnitComp.java").write_text(
                """
package mindustry.entities.comp;

class BlockUnitComp{
    public void add(){
        if(tile == null){
            throw new RuntimeException("Do not add BlockUnit entities to the game, they will simply crash. Internal use only.");
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BlockUnitComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_add_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var tile_null: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var runtime_exception_thrown: bool = tile_null", source_text)
            self.assertIn('var runtime_exception_message: String = "Do not add BlockUnit entities to the game, they will simply crash. Internal use only." if runtime_exception_thrown else ""', source_text)
            self.assertIn('"source_owner": "PortGame.source_block_unit_add_state"', source_text)
            self.assertIn('"method": "public void add(){"', source_text)
            self.assertIn('"guard_expr": "if(tile == null){"', source_text)
            self.assertIn('"throw_expr": "throw new RuntimeException', source_text)
            self.assertIn('"tile_null": tile_null', source_text)
            self.assertIn('"runtime_exception_thrown": runtime_exception_thrown', source_text)
            self.assertIn('"runtime_exception_message": runtime_exception_message', source_text)

    def test_emit_bridges_builder_comp_can_build_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuilderComp.java").write_text(
                """
package mindustry.entities.comp;

class BuilderComp{
    public boolean canBuild(){
        return type.buildSpeed > 0 && buildSpeedMultiplier > 0;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuilderComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_canBuild_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var type_build_speed: float = float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var build_speed_multiplier: float = float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var type_build_speed_positive: bool = type_build_speed > 0", source_text)
            self.assertIn("var build_speed_multiplier_positive: bool = build_speed_multiplier > 0", source_text)
            self.assertIn("var can_build: bool = type_build_speed_positive and build_speed_multiplier_positive", source_text)
            self.assertIn('"source_owner": "PortGame.source_builder_can_build_state"', source_text)
            self.assertIn('"method": "public boolean canBuild(){"', source_text)
            self.assertIn('"return_expr": "return type.buildSpeed > 0 && buildSpeedMultiplier > 0;"', source_text)
            self.assertIn('"type_build_speed_positive": type_build_speed_positive', source_text)
            self.assertIn('"build_speed_multiplier_positive": build_speed_multiplier_positive', source_text)
            self.assertIn('"can_build": can_build', source_text)

    def test_emit_bridges_builder_comp_update_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuilderComp.java").write_text(
                """
package mindustry.entities.comp;

class BuilderComp{
    public void update(){
        updateBuildLogic();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuilderComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_update_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var update_build_logic_call: String = "updateBuildLogic();"', source_text)
            self.assertIn("var update_build_logic_called: bool = true", source_text)
            self.assertIn('"source_owner": "PortGame.source_builder_update_state"', source_text)
            self.assertIn('"method": "public void update(){"', source_text)
            self.assertIn('"update_build_logic_call": update_build_logic_call', source_text)
            self.assertIn('"update_build_logic_called": update_build_logic_called', source_text)

    def test_emit_bridges_builder_comp_is_building_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuilderComp.java").write_text(
                """
package mindustry.entities.comp;

class BuilderComp{
    boolean isBuilding(){
        return plans.size != 0;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuilderComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_isBuilding_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var plans_size: int = int(_args[0] if _args.size() > 0 else 0)", source_text)
            self.assertIn("var is_building: bool = plans_size != 0", source_text)
            self.assertIn('"source_owner": "PortGame.source_builder_is_building_state"', source_text)
            self.assertIn('"method": "boolean isBuilding(){"', source_text)
            self.assertIn('"return_expr": "return plans.size != 0;"', source_text)
            self.assertIn('"plans_size": plans_size', source_text)
            self.assertIn('"is_building": is_building', source_text)

    def test_emit_bridges_builder_comp_clear_building_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuilderComp.java").write_text(
                """
package mindustry.entities.comp;

class BuilderComp{
    void clearBuilding(){
        plans.clear();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuilderComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_clearBuilding_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var plans_clear_call: String = "plans.clear();"', source_text)
            self.assertIn("var plans_clear_called: bool = true", source_text)
            self.assertIn('"source_owner": "PortGame.source_builder_clear_building_state"', source_text)
            self.assertIn('"method": "void clearBuilding(){"', source_text)
            self.assertIn('"plans_clear_call": plans_clear_call', source_text)
            self.assertIn('"plans_clear_called": plans_clear_called', source_text)

    def test_emit_bridges_builder_comp_add_build_tail_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuilderComp.java").write_text(
                """
package mindustry.entities.comp;

class BuilderComp{
    void addBuild(BuildPlan place){
        addBuild(place, true);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuilderComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_addBuild_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var place: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var tail: bool = true", source_text)
            self.assertIn('var add_build_call: Dictionary = {"call": "addBuild(place, true);", "place": place, "tail": tail}', source_text)
            self.assertIn('"source_owner": "PortGame.source_builder_add_build_tail_state"', source_text)
            self.assertIn('"method": "void addBuild(BuildPlan place){"', source_text)
            self.assertIn('"add_build_call": add_build_call', source_text)
            self.assertIn('"add_build_called": true', source_text)

    def test_emit_bridges_builder_comp_add_build_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuilderComp.java").write_text(
                """
package mindustry.entities.comp;

class BuilderComp{
    /** Add another build plans to the queue, if it doesn't exist there yet. */
    void addBuild(BuildPlan place, boolean tail){
        if(!canBuild()) return;

        BuildPlan replace = null;
        for(BuildPlan plan : plans){
            if(plan.x == place.x && plan.y == place.y){
                replace = plan;
                break;
            }
        }
        if(replace != null){
            plans.remove(replace);
        }
        Tile tile = world.tile(place.x, place.y);
        if(tile != null && tile.build instanceof ConstructBuild cons){
            place.progress = cons.progress;
        }
        if(tail){
            plans.addLast(place);
        }else{
            plans.addFirst(place);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuilderComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_addBuild_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var plans: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []", source_text)
            self.assertIn("var place: Dictionary = (_args[1] if _args.size() > 1 and _args[1] is Dictionary else {}).duplicate(true)", source_text)
            self.assertIn("var tail: bool = bool(_args[2] if _args.size() > 2 else true)", source_text)
            self.assertIn("var can_build: bool = bool(_args[3] if _args.size() > 3 else true)", source_text)
            self.assertIn("var replace_index: int = -1", source_text)
            self.assertIn('if int(plan.get("x", 0)) == int(place.get("x", 0)) and int(plan.get("y", 0)) == int(place.get("y", 0)):', source_text)
            self.assertIn("plans_after.remove_at(replace_index)", source_text)
            self.assertIn("place_after[\"progress\"] = construct_progress", source_text)
            self.assertIn("plans_after.append(place_after)", source_text)
            self.assertIn("plans_after.insert(0, place_after)", source_text)
            self.assertIn('"source_owner": "PortGame.source_builder_add_build_state"', source_text)
            self.assertIn('"method": "void addBuild(BuildPlan place, boolean tail){"', source_text)
            self.assertIn('"guard_expr": "if(!canBuild()) return;"', source_text)
            self.assertIn('"replace_match_expr": "plan.x == place.x && plan.y == place.y"', source_text)
            self.assertIn('"progress_expr": "place.progress = cons.progress;"', source_text)
            self.assertIn('"plans_after": plans_after', source_text)

    def test_emit_bridges_builder_comp_build_plan_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuilderComp.java").write_text(
                """
package mindustry.entities.comp;

class BuilderComp{
    @Nullable BuildPlan buildPlan(){
        return plans.size == 0 ? null : plans.first();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuilderComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_buildPlan_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var plans_size: int = int(_args[0]) if _args.size() > 0 else 0", source_text)
            self.assertIn("var plans_first: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var build_plan: Variant = null if plans_size == 0 else plans_first", source_text)
            self.assertIn('"source_owner": "PortGame.source_builder_build_plan_state"', source_text)
            self.assertIn('"method": "BuildPlan buildPlan(){"', source_text)
            self.assertIn('"return_expr": "return plans.size == 0 ? null : plans.first();"', source_text)
            self.assertIn('"build_plan": build_plan', source_text)

    def test_emit_bridges_builder_comp_after_read_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuilderComp.java").write_text(
                """
package mindustry.entities.comp;

class BuilderComp{
    @Override
    public void afterRead(){
        //why would this happen?
        if(plans == null){
            plans = new Queue<>(1);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuilderComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_afterRead_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var plans_null: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var queue_reset: bool = plans_null", source_text)
            self.assertIn("var plans_capacity: int = 1 if queue_reset else 0", source_text)
            self.assertIn('"source_owner": "PortGame.source_builder_after_read_state"', source_text)
            self.assertIn('"method": "public void afterRead(){"', source_text)
            self.assertIn('"guard_expr": "if(plans == null){"', source_text)
            self.assertIn('"queue_constructor": "new Queue<>(1)"', source_text)
            self.assertIn('"queue_reset": queue_reset', source_text)

    def test_emit_bridges_builder_comp_actively_building_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuilderComp.java").write_text(
                """
package mindustry.entities.comp;

class BuilderComp{
    boolean activelyBuilding(){
        //not actively building when not near the build plan
        if(isBuilding()){
            var plan = buildPlan();
            if(!state.isEditor() && plan != null && !within(plan, state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange)){
                return false;
            }
        }
        return isBuilding() && updateBuilding;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuilderComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_activelyBuilding_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var plans_size: int = int(_args[0] if _args.size() > 0 else 0)", source_text)
            self.assertIn("var plans_first: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var state_is_editor: bool = bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("var state_rules_infinite_resources: bool = bool(_args[3] if _args.size() > 3 else false)", source_text)
            self.assertIn("var type_build_range: float = float(_args[4] if _args.size() > 4 else 0.0)", source_text)
            self.assertIn("var within_plan: bool = bool(_args[5] if _args.size() > 5 else false)", source_text)
            self.assertIn("var update_building: bool = bool(_args[6] if _args.size() > 6 else false)", source_text)
            self.assertIn("var build_plan: Variant = null if plans_size == 0 else plans_first", source_text)
            self.assertIn("var final_place_dst: float = 3.4028234663852886e38 if state_rules_infinite_resources else type_build_range", source_text)
            self.assertIn("var outside_range_blocked: bool = is_building and not state_is_editor and build_plan != null and not within_plan", source_text)
            self.assertIn("var actively_building: bool = false if outside_range_blocked else is_building and update_building", source_text)
            self.assertIn('"source_owner": "PortGame.source_builder_actively_building_state"', source_text)
            self.assertIn('"method": "boolean activelyBuilding(){"', source_text)
            self.assertIn('"range_expr": "state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange"', source_text)
            self.assertIn('"actively_building": actively_building', source_text)

    def test_emit_bridges_builder_comp_remove_build_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuilderComp.java").write_text(
                """
package mindustry.entities.comp;

class BuilderComp{
    void removeBuild(int x, int y, boolean breaking){
        //remove matching plan
        int idx = plans.indexOf(req -> req.breaking == breaking && req.x == x && req.y == y);
        if(idx != -1){
            plans.removeIndex(idx);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuilderComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_removeBuild_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var plans: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []", source_text)
            self.assertIn("var x: int = int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("var y: int = int(_args[2] if _args.size() > 2 else 0)", source_text)
            self.assertIn("var breaking: bool = bool(_args[3] if _args.size() > 3 else false)", source_text)
            self.assertIn("var idx: int = -1", source_text)
            self.assertIn("if bool(plan.get(\"breaking\", false)) == breaking and int(plan.get(\"x\", 0)) == x and int(plan.get(\"y\", 0)) == y:", source_text)
            self.assertIn("var plans_after: Array = plans.duplicate(true)", source_text)
            self.assertIn("plans_after.remove_at(idx)", source_text)
            self.assertIn("var remove_index_call: Variant = null", source_text)
            self.assertIn('remove_index_call = {"call": "plans.removeIndex(idx);", "idx": idx}', source_text)
            self.assertIn('"source_owner": "PortGame.source_builder_remove_build_state"', source_text)
            self.assertIn('"method": "void removeBuild(int x, int y, boolean breaking){"', source_text)
            self.assertIn('"index_expr": "int idx = plans.indexOf(req -> req.breaking == breaking && req.x == x && req.y == y);"', source_text)
            self.assertIn('"removed": idx != -1', source_text)

    def test_emit_bridges_builder_comp_should_skip_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuilderComp.java").write_text(
                """
package mindustry.entities.comp;

class BuilderComp{
    /** @return whether this plan should be skipped, in favor of the next one. */
    boolean shouldSkip(BuildPlan plan, @Nullable Building core){
        if(state.rules.infiniteResources || team.rules().infiniteResources || plan.breaking || core == null || plan.isRotation(team) || plan.isDerelictRepair()) return false;

        return (plan.stuck && !core.items.has(plan.block.requirements)) ||
            (Structs.contains(plan.block.requirements, i -> !core.items.has(i.item, Math.min(i.amount, 15)) && Mathf.round(i.amount * state.rules.buildCostMultiplier) > 0));
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuilderComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_shouldSkip_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var state_rules_infinite_resources: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var team_rules_infinite_resources: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var plan_breaking: bool = bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("var core_null: bool = bool(_args[3] if _args.size() > 3 else false)", source_text)
            self.assertIn("var plan_is_rotation: bool = bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("var plan_is_derelict_repair: bool = bool(_args[5] if _args.size() > 5 else false)", source_text)
            self.assertIn("var plan_stuck: bool = bool(_args[6] if _args.size() > 6 else false)", source_text)
            self.assertIn("var core_items_has_plan_block_requirements: bool = bool(_args[7] if _args.size() > 7 else true)", source_text)
            self.assertIn("var structs_contains_missing_requirement: bool = bool(_args[8] if _args.size() > 8 else false)", source_text)
            self.assertIn("var guard_returns_false: bool = state_rules_infinite_resources or team_rules_infinite_resources or plan_breaking or core_null or plan_is_rotation or plan_is_derelict_repair", source_text)
            self.assertIn("var stuck_missing_requirements: bool = plan_stuck and not core_items_has_plan_block_requirements", source_text)
            self.assertIn("var should_skip: bool = false if guard_returns_false else (stuck_missing_requirements or structs_contains_missing_requirement)", source_text)
            self.assertIn('"source_owner": "PortGame.source_builder_should_skip_state"', source_text)
            self.assertIn('"method": "boolean shouldSkip(BuildPlan plan, @Nullable Building core){"', source_text)
            self.assertIn('"comment": "/** @return whether this plan should be skipped, in favor of the next one. */"', source_text)
            self.assertIn('"guard_expr": "if(state.rules.infiniteResources || team.rules().infiniteResources || plan.breaking || core == null || plan.isRotation(team) || plan.isDerelictRepair()) return false;"', source_text)
            self.assertIn('"return_expr": "return (plan.stuck && !core.items.has(plan.block.requirements)) || (Structs.contains(plan.block.requirements, i -> !core.items.has(i.item, Math.min(i.amount, 15)) && Mathf.round(i.amount * state.rules.buildCostMultiplier) > 0));"', source_text)
            self.assertIn('"should_skip": should_skip', source_text)

    def test_emit_bridges_builder_comp_draw_plan_top_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuilderComp.java").write_text(
                """
package mindustry.entities.comp;

class BuilderComp{
    void drawPlanTop(BuildPlan plan, float alpha){
        if(!plan.breaking){
            Draw.reset();
            Draw.mixcol(Color.white, 0.24f + Mathf.absin(Time.globalTime, 6f, 0.28f));
            Draw.alpha(alpha);
            plan.block.drawPlanConfigTop(plan, plans);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuilderComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawPlanTop_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var plan: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var plans: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []", source_text)
            self.assertIn("var plan_breaking: bool = bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("var alpha: float = float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var mathf_absin_time_global_6_0_28: float = float(_args[4] if _args.size() > 4 else 0.0)", source_text)
            self.assertIn("var draw_top: bool = not plan_breaking", source_text)
            self.assertIn("var mixcol_alpha: float = 0.24 + mathf_absin_time_global_6_0_28", source_text)
            self.assertIn("var draw_reset_called: bool = draw_top", source_text)
            self.assertIn("var draw_plan_config_top_call: Variant = null", source_text)
            self.assertIn('draw_plan_config_top_call = {"call": "plan.block.drawPlanConfigTop(plan, plans);", "plan": plan, "plans": plans}', source_text)
            self.assertIn('"source_owner": "PortGame.source_builder_draw_plan_top_state"', source_text)
            self.assertIn('"method": "void drawPlanTop(BuildPlan plan, float alpha){"', source_text)
            self.assertIn('"guard_expr": "if(!plan.breaking){"', source_text)
            self.assertIn('"mixcol_expr": "Draw.mixcol(Color.white, 0.24f + Mathf.absin(Time.globalTime, 6f, 0.28f));"', source_text)
            self.assertIn('"draw_plan_config_top_expr": "plan.block.drawPlanConfigTop(plan, plans);"', source_text)
            self.assertIn('"draw_top": draw_top', source_text)

    def test_emit_bridges_builder_comp_draw_plan_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuilderComp.java").write_text(
                """
package mindustry.entities.comp;

class BuilderComp{
    void drawPlan(BuildPlan plan, float alpha){
        plan.animScale = 1f;
        if(plan.breaking){
            control.input.drawBreaking(plan);
        }else{
            plan.block.drawPlan(plan, control.input.allPlans(),
            Build.validPlace(plan.block, team, plan.x, plan.y, plan.rotation) || control.input.planMatches(plan),
            alpha);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuilderComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawPlan_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var plan: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var all_plans: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []", source_text)
            self.assertIn("var plan_breaking: bool = bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("var alpha: float = float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var build_valid_place: bool = bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("var control_input_plan_matches: bool = bool(_args[5] if _args.size() > 5 else false)", source_text)
            self.assertIn("var plan_anim_scale: float = 1.0", source_text)
            self.assertIn("var draw_plan_valid: bool = build_valid_place or control_input_plan_matches", source_text)
            self.assertIn("var draw_breaking_call: Variant = null", source_text)
            self.assertIn("var draw_plan_call: Variant = null", source_text)
            self.assertIn('draw_breaking_call = {"call": "control.input.drawBreaking(plan);", "plan": plan}', source_text)
            self.assertIn('draw_plan_call = {"call": "plan.block.drawPlan(plan, control.input.allPlans(), Build.validPlace(...) || control.input.planMatches(plan), alpha);", "plan": plan, "all_plans": all_plans, "valid": draw_plan_valid, "alpha": alpha}', source_text)
            self.assertIn('"source_owner": "PortGame.source_builder_draw_plan_state"', source_text)
            self.assertIn('"method": "void drawPlan(BuildPlan plan, float alpha){"', source_text)
            self.assertIn('"anim_scale_expr": "plan.animScale = 1f;"', source_text)
            self.assertIn('"breaking_guard_expr": "if(plan.breaking){"', source_text)
            self.assertIn('"draw_breaking_expr": "control.input.drawBreaking(plan);"', source_text)
            self.assertIn('"draw_plan_valid_expr": "Build.validPlace(plan.block, team, plan.x, plan.y, plan.rotation) || control.input.planMatches(plan)"', source_text)
            self.assertIn('"draw_plan_call": draw_plan_call', source_text)

    def test_emit_bridges_builder_comp_draw_building_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuilderComp.java").write_text(
                """
package mindustry.entities.comp;

class BuilderComp{
    public void drawBuilding(){
        //TODO make this more generic so it works with builder "weapons"
        boolean active = activelyBuilding();
        if(!active && lastActive == null) return;

        Draw.z(Layer.flyingUnit);

        BuildPlan plan = active ? buildPlan() : lastActive;
        Tile tile = plan.tile();
        var core = team.core();

        if(tile == null || !within(plan, state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange)){
            return;
        }

        //draw remote plans.
        if(core != null && active && !isLocal() && !(tile.block() instanceof ConstructBlock) && !state.isPaused()){
            Draw.z(Layer.plans - 1f);
            drawPlan(plan, 0.5f);
            drawPlanTop(plan, 0.5f);
            Draw.z(Layer.flyingUnit);
        }

        if(type.drawBuildBeam){
            float focusLen = type.buildBeamOffset + Mathf.absin(Time.time, 3f, 0.6f);
            float px = x + Angles.trnsx(rotation, focusLen);
            float py = y + Angles.trnsy(rotation, focusLen);

            drawBuildingBeam(px, py);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuilderComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawBuilding_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var active: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var last_active: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var build_plan: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("var plan: Variant = build_plan if active else last_active", source_text)
            self.assertIn("var inactive_without_last_active: bool = not active and last_active == null", source_text)
            self.assertIn("var outside_range_blocked: bool = not tile_exists or not within_plan", source_text)
            self.assertIn("var remote_plan_draw: bool = false", source_text)
            self.assertIn("remote_plan_draw = core_exists and active and not is_local and not tile_block_is_construct_block and not state_is_paused", source_text)
            self.assertIn("var focus_len: float = type_build_beam_offset + mathf_absin_time_3_0_6", source_text)
            self.assertIn("var px: float = x + angles_trnsx_rotation_focus_len", source_text)
            self.assertIn("var py: float = y + angles_trnsy_rotation_focus_len", source_text)
            self.assertIn('"source_owner": "PortGame.source_builder_draw_building_state"', source_text)
            self.assertIn('"method": "public void drawBuilding(){"', source_text)
            self.assertIn('"active_expr": "boolean active = activelyBuilding();"', source_text)
            self.assertIn('"plan_expr": "BuildPlan plan = active ? buildPlan() : lastActive;"', source_text)
            self.assertIn('"range_guard_expr": "if(tile == null || !within(plan, state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange)){"', source_text)
            self.assertIn('"remote_guard_expr": "if(core != null && active && !isLocal() && !(tile.block() instanceof ConstructBlock) && !state.isPaused()){"', source_text)
            self.assertIn('"draw_building_beam_call": draw_building_beam_call', source_text)

    def test_emit_bridges_builder_comp_draw_building_beam_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "src"
            comp_dir = source_root / "mindustry" / "entities" / "comp"
            comp_dir.mkdir(parents=True)
            (comp_dir / "BuilderComp.java").write_text(
                """
package mindustry.entities.comp;

class BuilderComp{
    public void drawBuildingBeam(float px, float py){
        boolean active = activelyBuilding();
        if(!active && lastActive == null) return;

        Draw.z(Layer.flyingUnit);

        BuildPlan plan = active ? buildPlan() : lastActive;
        Tile tile = world.tile(plan.x, plan.y);

        if(tile == null || !within(plan, state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange)){
            return;
        }

        int size = plan.breaking ? active ? tile.block().size : lastSize : plan.block.size;
        float tx = plan.drawx(), ty = plan.drawy();

        Lines.stroke(1f, plan.breaking ? Pal.remove : Pal.accent);
        Draw.z(Layer.buildBeam);

        Draw.alpha(buildAlpha);

        if(!active && !(tile.build instanceof ConstructBuild)){
            Fill.square(plan.drawx(), plan.drawy(), size * tilesize/2f);
        }

        Drawf.buildBeam(px, py, tx, ty, Vars.tilesize * size / 2f);

        Fill.square(px, py, 1.8f + Mathf.absin(Time.time, 2.2f, 1.1f), rotation + 45);

        Draw.reset();
        Draw.z(Layer.flyingUnit);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuilderComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawBuildingBeam_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var px: float = float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var py: float = float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var inactive_without_last_active: bool = not active and last_active == null", source_text)
            self.assertIn("var plan: Variant = build_plan if active else last_active", source_text)
            self.assertIn("var outside_range_blocked: bool = not tile_exists or not within_plan", source_text)
            self.assertIn("var size: int = tile_block_size if plan_breaking and active else last_size if plan_breaking else plan_block_size", source_text)
            self.assertIn("var tx: float = plan_drawx", source_text)
            self.assertIn("var ty: float = plan_drawy", source_text)
            self.assertIn("var stroke_color: String = \"Pal.remove\" if plan_breaking else \"Pal.accent\"", source_text)
            self.assertIn("fill_last_active_square_call = {\"call\": \"Fill.square(plan.drawx(), plan.drawy(), size * tilesize/2f);\"", source_text)
            self.assertIn("build_beam_call = {\"call\": \"Drawf.buildBeam(px, py, tx, ty, Vars.tilesize * size / 2f);\"", source_text)
            self.assertIn("focus_square_radius: float = 1.8 + mathf_absin_time_2_2_1_1", source_text)
            self.assertIn("focus_square_rotation: float = rotation_value + 45.0", source_text)
            self.assertIn('"source_owner": "PortGame.source_builder_draw_building_beam_state"', source_text)
            self.assertIn('"method": "public void drawBuildingBeam(float px, float py){"', source_text)
            self.assertIn('"size_expr": "int size = plan.breaking ? active ? tile.block().size : lastSize : plan.block.size;"', source_text)

    def test_emit_bridges_turret_outputs_items_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class Turret extends ReloadTurret{
    @Override
    public boolean outputsItems(){
        return false;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_outputsItems_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_turret_outputs_items_state"', source_text)
            self.assertIn('"method": "public boolean outputsItems(){"', source_text)
            self.assertIn('"return_expr": "return false;"', source_text)
            self.assertIn('"outputs_items": false', source_text)

    def test_emit_bridges_block_outputs_items_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            block_path = source_root / "mindustry" / "world" / "Block.java"
            block_path.parent.mkdir(parents=True, exist_ok=True)
            block_path.write_text(
                """
package mindustry.world;

public class Block{
    /** If true, buildings have an ItemModule. */
    public @NoPatch boolean hasItems;
    public boolean outputsItems(){
        return hasItems;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "Block.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_outputsItems_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar has_items: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_block_outputs_items_state"', source_text)
            self.assertIn('"source": "core/src/mindustry/world/Block.java"', source_text)
            self.assertIn('"field_expr": "public @NoPatch boolean hasItems;"', source_text)
            self.assertIn('"method": "public boolean outputsItems(){"', source_text)
            self.assertIn('"return_expr": "return hasItems;"', source_text)
            self.assertIn('"outputs_items": has_items', source_text)

    def test_emit_bridges_block_can_place_on_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            block_path = source_root / "mindustry" / "world" / "Block.java"
            block_path.parent.mkdir(parents=True, exist_ok=True)
            block_path.write_text(
                """
package mindustry.world;

public class Block{
    /** @return whether this block can be placed on the specified tile. */
    public boolean canPlaceOn(Tile tile, Team team, int rotation){
        return true;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "Block.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_canPlaceOn_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar tile: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("\tvar team: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("\tvar rotation: int = int(_args[2] if _args.size() > 2 else 0)", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_block_can_place_on_state"', source_text)
            self.assertIn('"source": "core/src/mindustry/world/Block.java"', source_text)
            self.assertIn('"comment": "/** @return whether this block can be placed on the specified tile. */"', source_text)
            self.assertIn('"method": "public boolean canPlaceOn(Tile tile, Team team, int rotation){"', source_text)
            self.assertIn('"return_expr": "return true;"', source_text)
            self.assertIn('"can_place": true', source_text)

    def test_emit_bridges_block_can_break_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            block_path = source_root / "mindustry" / "world" / "Block.java"
            block_path.parent.mkdir(parents=True, exist_ok=True)
            block_path.write_text(
                """
package mindustry.world;

public class Block{
    /** @return whether this block can be broken on the specified tile. */
    public boolean canBreak(Tile tile){
        return true;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "Block.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_canBreak_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar tile: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_block_can_break_state"', source_text)
            self.assertIn('"source": "core/src/mindustry/world/Block.java"', source_text)
            self.assertIn('"comment": "/** @return whether this block can be broken on the specified tile. */"', source_text)
            self.assertIn('"method": "public boolean canBreak(Tile tile){"', source_text)
            self.assertIn('"return_expr": "return true;"', source_text)
            self.assertIn('"can_break": true', source_text)

    def test_emit_bridges_block_rotated_output_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            block_path = source_root / "mindustry" / "world" / "Block.java"
            block_path.parent.mkdir(parents=True, exist_ok=True)
            block_path.write_text(
                """
package mindustry.world;

public class Block{
    /** whether this is rotatable */
    public boolean rotate;

    public boolean rotatedOutput(int x, int y){
        return rotate;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "Block.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_rotatedOutput_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar rotate_value: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("\tvar x_value: int = int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("\tvar y_value: int = int(_args[2] if _args.size() > 2 else 0)", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_block_rotated_output_state"', source_text)
            self.assertIn('"field_comment": "/** whether this is rotatable */"', source_text)
            self.assertIn('"field_expr": "public boolean rotate;"', source_text)
            self.assertIn('"method": "public boolean rotatedOutput(int x, int y){"', source_text)
            self.assertIn('"return_expr": "return rotate;"', source_text)
            self.assertIn('"rotated_output": rotate_value', source_text)

    def test_emit_bridges_block_rotated_output_tile_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            block_path = source_root / "mindustry" / "world" / "Block.java"
            block_path.parent.mkdir(parents=True, exist_ok=True)
            block_path.write_text(
                """
package mindustry.world;

public class Block{
    public boolean rotatedOutput(int x, int y){
        return rotate;
    }

    public boolean rotatedOutput(int fromX, int fromY, Tile destination){
        return rotatedOutput(fromX, fromY);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "Block.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_rotatedOutput_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar rotate_value: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("\tvar from_x: int = int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("\tvar from_y: int = int(_args[2] if _args.size() > 2 else 0)", source_text)
            self.assertIn("\tvar destination: Variant = _args[3] if _args.size() > 3 else null", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_block_rotated_output_tile_state"', source_text)
            self.assertIn('"method": "public boolean rotatedOutput(int fromX, int fromY, Tile destination){"', source_text)
            self.assertIn('"delegate_call": "rotatedOutput(fromX, fromY)"', source_text)
            self.assertIn('"return_expr": "return rotatedOutput(fromX, fromY);"', source_text)
            self.assertIn('"base_state": base_state', source_text)
            self.assertIn('"rotated_output": base_state["rotated_output"]', source_text)

    def test_emit_bridges_block_synthetic_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            block_path = source_root / "mindustry" / "world" / "Block.java"
            block_path.parent.mkdir(parents=True, exist_ok=True)
            block_path.write_text(
                """
package mindustry.world;

public class Block{
    public boolean synthetic(){
        return update || destructible;
    }
}
""",
                encoding="utf-8",
            )

            output_root = root / "godot" / "src" / "generated" / "classes"
            emit_gdscript_classes(source_root, output_root)
            block_script = output_root / "mindustry" / "world" / "Block.gd"
            source_text = block_script.read_text(encoding="utf-8")

            self.assertIn("func java_method_synthetic_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar update_value: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("\tvar destructible_value: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("\tvar synthetic_value: bool = update_value or destructible_value", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_block_synthetic_state"', source_text)
            self.assertIn('"method": "public boolean synthetic(){"', source_text)
            self.assertIn('"return_expr": "return update || destructible;"', source_text)
            self.assertIn('"synthetic": synthetic_value', source_text)

    def test_emit_bridges_block_check_force_dark_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            block_path = source_root / "mindustry" / "world" / "Block.java"
            block_path.parent.mkdir(parents=True, exist_ok=True)
            block_path.write_text(
                """
package mindustry.world;

public class Block{
    public boolean checkForceDark(Tile tile){
        return forceDark;
    }
}
""",
                encoding="utf-8",
            )

            output_root = root / "godot" / "src" / "generated" / "classes"
            emit_gdscript_classes(source_root, output_root)
            block_script = output_root / "mindustry" / "world" / "Block.gd"
            source_text = block_script.read_text(encoding="utf-8")

            self.assertIn("func java_method_checkForceDark_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar force_dark_value: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("\tvar tile: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_block_check_force_dark_state"', source_text)
            self.assertIn('"method": "public boolean checkForceDark(Tile tile){"', source_text)
            self.assertIn('"return_expr": "return forceDark;"', source_text)
            self.assertIn('"force_dark": force_dark_value', source_text)
            self.assertIn('"tile": tile', source_text)

    def test_emit_bridges_block_is_darkened_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            block_path = source_root / "mindustry" / "world" / "Block.java"
            block_path.parent.mkdir(parents=True, exist_ok=True)
            block_path.write_text(
                """
package mindustry.world;

public class Block{
    /** If true, the 'map edge' darkness will be applied to this block. */
    public boolean isDarkened(Tile tile){
        return solid && ((!synthetic() && fillsTile) || checkForceDark(tile));
    }
}
""",
                encoding="utf-8",
            )

            output_root = root / "godot" / "src" / "generated" / "classes"
            emit_gdscript_classes(source_root, output_root)
            block_script = output_root / "mindustry" / "world" / "Block.gd"
            source_text = block_script.read_text(encoding="utf-8")

            self.assertIn("func java_method_isDarkened_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar solid_value: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("\tvar update_value: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("\tvar destructible_value: bool = bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("\tvar fills_tile_value: bool = bool(_args[3] if _args.size() > 3 else false)", source_text)
            self.assertIn("\tvar force_dark_value: bool = bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("\tvar tile: Variant = _args[5] if _args.size() > 5 else null", source_text)
            self.assertIn("\tvar synthetic_state := {", source_text)
            self.assertIn("\tvar check_force_dark_state := {", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_block_is_darkened_state"', source_text)
            self.assertIn('"comment": "/** If true, the \'map edge\' darkness will be applied to this block. */"', source_text)
            self.assertIn('"method": "public boolean isDarkened(Tile tile){"', source_text)
            self.assertIn('"return_expr": "return solid && ((!synthetic() && fillsTile) || checkForceDark(tile));"', source_text)
            self.assertIn('"is_darkened": is_darkened_value', source_text)

    def test_emit_bridges_block_consumes_item_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            block_path = source_root / "mindustry" / "world" / "Block.java"
            block_path.parent.mkdir(parents=True, exist_ok=True)
            block_path.write_text(
                """
package mindustry.world;

public class Block{
    public boolean consumesItem(Item item){
        return itemFilter[item.id];
    }
}
""",
                encoding="utf-8",
            )

            output_root = root / "godot" / "src" / "generated" / "classes"
            emit_gdscript_classes(source_root, output_root)
            block_script = output_root / "mindustry" / "world" / "Block.gd"
            source_text = block_script.read_text(encoding="utf-8")

            self.assertIn("func java_method_consumesItem_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar item_filter: Array = _args[0] if _args.size() > 0 else []", source_text)
            self.assertIn("\tvar item_id: int = int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("\tvar item: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("\tvar consumes_item_value: bool = bool(item_filter[item_id])", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_block_consumes_item_state"', source_text)
            self.assertIn('"method": "public boolean consumesItem(Item item){"', source_text)
            self.assertIn('"return_expr": "return itemFilter[item.id];"', source_text)
            self.assertIn('"itemFilter": item_filter', source_text)
            self.assertIn('"item_id": item_id', source_text)
            self.assertIn('"item": item', source_text)
            self.assertIn('"consumes_item": consumes_item_value', source_text)

    def test_emit_bridges_block_consumes_liquid_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            block_path = source_root / "mindustry" / "world" / "Block.java"
            block_path.parent.mkdir(parents=True, exist_ok=True)
            block_path.write_text(
                """
package mindustry.world;

public class Block{
    public boolean consumesLiquid(Liquid liq){
        return liquidFilter[liq.id];
    }
}
""",
                encoding="utf-8",
            )

            output_root = root / "godot" / "src" / "generated" / "classes"
            emit_gdscript_classes(source_root, output_root)
            block_script = output_root / "mindustry" / "world" / "Block.gd"
            source_text = block_script.read_text(encoding="utf-8")

            self.assertIn("func java_method_consumesLiquid_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar liquid_filter: Array = _args[0] if _args.size() > 0 else []", source_text)
            self.assertIn("\tvar liquid_id: int = int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("\tvar liq: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("\tvar consumes_liquid_value: bool = bool(liquid_filter[liquid_id])", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_block_consumes_liquid_state"', source_text)
            self.assertIn('"method": "public boolean consumesLiquid(Liquid liq){"', source_text)
            self.assertIn('"return_expr": "return liquidFilter[liq.id];"', source_text)
            self.assertIn('"liquidFilter": liquid_filter', source_text)
            self.assertIn('"liq_id": liquid_id', source_text)
            self.assertIn('"liq": liq', source_text)
            self.assertIn('"consumes_liquid": consumes_liquid_value', source_text)

    def test_emit_bridges_block_has_building_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            block_path = source_root / "mindustry" / "world" / "Block.java"
            block_path.parent.mkdir(parents=True, exist_ok=True)
            block_path.write_text(
                """
package mindustry.world;

public class Block{
    public boolean hasBuilding(){
        return destructible || update;
    }
}
""",
                encoding="utf-8",
            )

            output_root = root / "godot" / "src" / "generated" / "classes"
            emit_gdscript_classes(source_root, output_root)
            block_script = output_root / "mindustry" / "world" / "Block.gd"
            source_text = block_script.read_text(encoding="utf-8")

            self.assertIn("func java_method_hasBuilding_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar destructible_value: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("\tvar update_value: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("\tvar has_building_value: bool = destructible_value or update_value", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_block_has_building_state"', source_text)
            self.assertIn('"method": "public boolean hasBuilding(){"', source_text)
            self.assertIn('"return_expr": "return destructible || update;"', source_text)
            self.assertIn('"destructible": destructible_value', source_text)
            self.assertIn('"update": update_value', source_text)
            self.assertIn('"has_building": has_building_value', source_text)

    def test_emit_bridges_turret_init_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class Turret extends ReloadTurret{
    @Override
    public void init(){
        if(shootY == Float.NEGATIVE_INFINITY) shootY = size * tilesize / 2f;
        if(elevation < 0) elevation = size / 2f;
        if(recoilTime < 0f) recoilTime = reload;
        if(cooldownTime < 0f) cooldownTime = reload;
        if(newTargetInterval <= 0f) newTargetInterval = targetInterval;

        if(!targetGround){
            disableOverlapCheck = true;
        }

        super.init();
        trackingRange = Math.max(range, trackingRange);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_init_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var shoot_y_after: float = size * source_tilesize / 2.0 if shoot_y_is_negative_infinity else shoot_y", source_text)
            self.assertIn("var elevation_after: float = size / 2.0 if elevation < 0.0 else elevation", source_text)
            self.assertIn("var recoil_time_after: float = reload if recoil_time < 0.0 else recoil_time", source_text)
            self.assertIn("var cooldown_time_after: float = reload if cooldown_time < 0.0 else cooldown_time", source_text)
            self.assertIn("var new_target_interval_after: float = target_interval if new_target_interval <= 0.0 else new_target_interval", source_text)
            self.assertIn("var disable_overlap_check_after: bool = true if not target_ground else disable_overlap_check", source_text)
            self.assertIn("var tracking_range_after: float = max(range_value, tracking_range)", source_text)
            self.assertIn('"source_owner": "PortGame.source_turret_init_state"', source_text)
            self.assertIn('"method": "public void init(){"', source_text)
            self.assertIn('"tracking_range_expr": "trackingRange = Math.max(range, trackingRange);"', source_text)

    def test_emit_bridges_base_turret_init_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            base_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "BaseTurret.java"
            base_turret_path.parent.mkdir(parents=True, exist_ok=True)
            base_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class BaseTurret extends Block{
    @Override
    public void init(){
        if(coolant == null){
            coolant = findConsumer(c -> c instanceof ConsumeCoolant);
        }

        checkInitCoolant();

        if(!disableOverlapCheck){
            placeOverlapRange = Math.max(placeOverlapRange, range + placeOverlapMargin);
        }
        fogRadius = Math.max(Mathf.round(range / tilesize * fogRadiusMultiplier), fogRadius);
        super.init();
    }

    @Override
    public void reinitializeConsumers(){
    }

    void checkInitCoolant(){
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "BaseTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_init_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_base_turret_init_state"', source_text)
            self.assertIn('"method": "public void init(){"', source_text)
            self.assertIn('"coolant_null_guard_expr": "if(coolant == null){"', source_text)
            self.assertIn('"find_consumer_expr": "coolant = findConsumer(c -> c instanceof ConsumeCoolant);"', source_text)
            self.assertIn('"check_init_coolant_expr": "checkInitCoolant();"', source_text)
            self.assertIn('"overlap_guard_expr": "if(!disableOverlapCheck){"', source_text)
            self.assertIn('"place_overlap_range_expr": "placeOverlapRange = Math.max(placeOverlapRange, range + placeOverlapMargin);"', source_text)
            self.assertIn('"fog_radius_expr": "fogRadius = Math.max(Mathf.round(range / tilesize * fogRadiusMultiplier), fogRadius);"', source_text)
            self.assertIn('"super_init_expr": "super.init();"', source_text)

    def test_emit_bridges_base_turret_reinitialize_consumers_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            base_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "BaseTurret.java"
            base_turret_path.parent.mkdir(parents=True, exist_ok=True)
            base_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class BaseTurret extends Block{
    @Override
    public void init(){
        super.init();
    }

    @Override
    public void reinitializeConsumers(){
        checkInitCoolant();

        super.reinitializeConsumers();
    }

    void checkInitCoolant(){
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "BaseTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_reinitializeConsumers_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_base_turret_reinitialize_consumers_state"', source_text)
            self.assertIn('"method": "public void reinitializeConsumers(){"', source_text)
            self.assertIn('"override_expr": "@Override"', source_text)
            self.assertIn('"check_init_coolant_expr": "checkInitCoolant();"', source_text)
            self.assertIn('"super_reinitialize_consumers_expr": "super.reinitializeConsumers();"', source_text)
            self.assertIn('"check_init_coolant_called": true', source_text)
            self.assertIn('"super_reinitialize_consumers_called": true', source_text)

    def test_emit_bridges_base_turret_check_init_coolant_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            base_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "BaseTurret.java"
            base_turret_path.parent.mkdir(parents=True, exist_ok=True)
            base_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class BaseTurret extends Block{
    @Override
    public void init(){
        super.init();
    }

    @Override
    public void reinitializeConsumers(){
    }

    void checkInitCoolant(){
        if(coolant != null){
            coolant.update = false;
            coolant.booster = true;
            coolant.optional = true;

            //json parsing does not add to consumes
            if(!hasConsumer(coolant)) consume(coolant);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "BaseTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_checkInitCoolant_2(_args: Array = []) -> Variant:", source_text)
            self.assertIn('"source_owner": "PortGame.source_base_turret_check_init_coolant_state"', source_text)
            self.assertIn('"method": "void checkInitCoolant(){"', source_text)
            self.assertIn('"coolant_guard_expr": "if(coolant != null){"', source_text)
            self.assertIn('"update_assign_expr": "coolant.update = false;"', source_text)
            self.assertIn('"booster_assign_expr": "coolant.booster = true;"', source_text)
            self.assertIn('"optional_assign_expr": "coolant.optional = true;"', source_text)
            self.assertIn('"json_comment": "//json parsing does not add to consumes"', source_text)
            self.assertIn('"consume_guard_expr": "if(!hasConsumer(coolant)) consume(coolant);"', source_text)

    def test_emit_bridges_base_turret_draw_place_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            base_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "BaseTurret.java"
            base_turret_path.parent.mkdir(parents=True, exist_ok=True)
            base_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class BaseTurret extends Block{
    @Override
    public void init(){
    }

    @Override
    public void reinitializeConsumers(){
    }

    void checkInitCoolant(){
    }

    @Override
    public void drawPlace(int x, int y, int rotation, boolean valid){
        super.drawPlace(x, y, rotation, valid);

        Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);

        if(fogRadiusMultiplier < 0.99f && state.rules.fog){
            Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range * fogRadiusMultiplier, Pal.lightishGray);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "BaseTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawPlace_3(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var tile_x: int = int(_args[0] if _args.size() > 0 else 0)", source_text)
            self.assertIn("var dash_circle_x: float = float(tile_x) * source_tilesize + block_offset", source_text)
            self.assertIn("var fog_dash_circle_called: bool = fog_radius_multiplier < 0.99 and rules_fog", source_text)
            self.assertIn('"source_owner": "PortGame.source_base_turret_draw_place_state"', source_text)
            self.assertIn('"method": "public void drawPlace(int x, int y, int rotation, boolean valid){"', source_text)
            self.assertIn('"super_draw_place_expr": "super.drawPlace(x, y, rotation, valid);"', source_text)
            self.assertIn('"dash_circle_expr": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);"', source_text)
            self.assertIn('"fog_guard_expr": "if(fogRadiusMultiplier < 0.99f && state.rules.fog){"', source_text)
            self.assertIn('"fog_dash_circle_expr": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range * fogRadiusMultiplier, Pal.lightishGray);"', source_text)

    def test_emit_bridges_base_turret_set_stats_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            base_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "BaseTurret.java"
            base_turret_path.parent.mkdir(parents=True, exist_ok=True)
            base_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class BaseTurret extends Block{
    @Override
    public void init(){
    }

    @Override
    public void reinitializeConsumers(){
    }

    void checkInitCoolant(){
    }

    @Override
    public void drawPlace(int x, int y, int rotation, boolean valid){
    }

    @Override
    public void setStats(){
        super.setStats();

        stats.add(Stat.shootRange, range / tilesize, StatUnit.blocks);
        if(activationTime > 0) stats.add(Stat.activationTime, activationTime / 60f, StatUnit.seconds);
    }

    @Override
    public void setBars(){
        super.setBars();

        if(activationTime > 0){
            addBar("activationtimer", (BaseTurretBuild entity) ->
            new Bar(() ->
            (entity.activationTimer > 0)? Core.bundle.format("bar.activationtimer", Mathf.ceil(entity.activationTimer / 60f)) : Core.bundle.get("bar.activated"),
            () -> (entity.activationTimer > 0)?  Pal.lightOrange : Pal.techBlue,
            () -> 1 - entity.activationTimer / activationTime));
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "BaseTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setStats_4(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var shoot_range_blocks: float = range_value / source_tilesize", source_text)
            self.assertIn("var activation_time_stat_called: bool = activation_time > 0.0", source_text)
            self.assertIn('"source_owner": "PortGame.source_base_turret_set_stats_state"', source_text)
            self.assertIn('"method": "public void setStats(){"', source_text)
            self.assertIn('"super_set_stats_expr": "super.setStats();"', source_text)
            self.assertIn('"shoot_range_stat_expr": "stats.add(Stat.shootRange, range / tilesize, StatUnit.blocks);"', source_text)
            self.assertIn('"activation_time_guard_expr": "if(activationTime > 0)"', source_text)
            self.assertIn('"activation_time_stat_expr": "stats.add(Stat.activationTime, activationTime / 60f, StatUnit.seconds);"', source_text)

    def test_emit_bridges_base_turret_set_bars_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            base_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "BaseTurret.java"
            base_turret_path.parent.mkdir(parents=True, exist_ok=True)
            base_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class BaseTurret extends Block{
    @Override
    public void init(){
    }

    @Override
    public void reinitializeConsumers(){
    }

    void checkInitCoolant(){
    }

    @Override
    public void drawPlace(int x, int y, int rotation, boolean valid){
    }

    @Override
    public void setStats(){
    }

    @Override
    public void setBars(){
        super.setBars();

        if(activationTime > 0){
            addBar("activationtimer", (BaseTurretBuild entity) ->
            new Bar(() ->
            (entity.activationTimer > 0)? Core.bundle.format("bar.activationtimer", Mathf.ceil(entity.activationTimer / 60f)) : Core.bundle.get("bar.activated"),
            () -> (entity.activationTimer > 0)?  Pal.lightOrange : Pal.techBlue,
            () -> 1 - entity.activationTimer / activationTime));
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "BaseTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setBars_5(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var activation_bar_added: bool = activation_time > 0.0", source_text)
            self.assertIn("var activation_timer_positive: bool = entity_activation_timer > 0.0", source_text)
            self.assertIn("var activation_bar_fraction: float = 0.0", source_text)
            self.assertIn("activation_bar_fraction = 1.0 - entity_activation_timer / activation_time", source_text)
            self.assertIn('"source_owner": "PortGame.source_base_turret_set_bars_state"', source_text)
            self.assertIn('"method": "public void setBars(){"', source_text)
            self.assertIn('"super_set_bars_expr": "super.setBars();"', source_text)
            self.assertIn('"activation_time_guard_expr": "if(activationTime > 0){"', source_text)
            self.assertIn('"add_bar_expr": "addBar(\\"activationtimer\\", (BaseTurretBuild entity) ->"', source_text)
            self.assertIn('"bar_progress_expr": "() -> 1 - entity.activationTimer / activationTime"', source_text)

    def test_emit_bridges_turret_load_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class Turret extends ReloadTurret{
    @Override
    public void load(){
        super.load();

        drawer.load(this);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_load_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_turret_load_state"', source_text)
            self.assertIn('"method": "public void load(){"', source_text)
            self.assertIn('"super_load_expr": "super.load();"', source_text)
            self.assertIn('"drawer_load_expr": "drawer.load(this);"', source_text)
            self.assertIn('"drawer_load_called": true', source_text)

    def test_emit_bridges_turret_draw_plan_region_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class Turret extends ReloadTurret{
    @Override
    public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){
        drawer.drawPlan(this, plan, list);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawPlanRegion_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var plan: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var list: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_turret_draw_plan_region_state"', source_text)
            self.assertIn('"method": "public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){"', source_text)
            self.assertIn('"drawer_draw_plan_expr": "drawer.drawPlan(this, plan, list);"', source_text)
            self.assertIn('"drawer_draw_plan_called": true', source_text)

    def test_emit_bridges_turret_icons_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class Turret extends ReloadTurret{
    @Override
    public TextureRegion[] icons(){
        return drawer.finalIcons(this);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_icons_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_turret_icons_state"', source_text)
            self.assertIn('"method": "public TextureRegion[] icons(){"', source_text)
            self.assertIn('"drawer_final_icons_expr": "return drawer.finalIcons(this);"', source_text)
            self.assertIn('"drawer_final_icons_called": true', source_text)

    def test_emit_bridges_tractor_beam_turret_icons_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public @Load(value = "@-base", fallback = "block-@size") TextureRegion baseRegion;

    @Override
    public TextureRegion[] icons(){
        return new TextureRegion[]{baseRegion, region};
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_icons_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var base_region: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var region: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var icons: Array = [base_region, region]", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_tractor_beam_turret_icons_state"', source_text)
            self.assertIn('"method": "public TextureRegion[] icons(){"', source_text)
            self.assertIn('"return_expr": "return new TextureRegion[]{baseRegion, region};"', source_text)
            self.assertIn('"base_region": base_region', source_text)
            self.assertIn('"region": region', source_text)
            self.assertIn('"icons": icons', source_text)

    def test_emit_bridges_tractor_beam_turret_set_stats_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public float damage = 0f;
    public boolean targetAir = true, targetGround = false;

    @Override
    public void setStats(){
        super.setStats();

        stats.add(Stat.targetsAir, targetAir);
        stats.add(Stat.targetsGround, targetGround);
        if(damage > 0) stats.add(Stat.damage, damage * 60f, StatUnit.perSecond);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setStats_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var target_air: bool = bool(_args[0] if _args.size() > 0 else true)", source_text)
            self.assertIn("var target_ground: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var damage: float = float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var damage_per_second: float = damage * 60.0", source_text)
            self.assertIn("var damage_stat_added: bool = damage > 0.0", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_tractor_beam_turret_set_stats_state"', source_text)
            self.assertIn('"method": "public void setStats(){"', source_text)
            self.assertIn('"super_set_stats_expr": "super.setStats();"', source_text)
            self.assertIn('"targets_air_stat_expr": "stats.add(Stat.targetsAir, targetAir);"', source_text)
            self.assertIn('"targets_ground_stat_expr": "stats.add(Stat.targetsGround, targetGround);"', source_text)
            self.assertIn('"damage_stat_expr": "if(damage > 0) stats.add(Stat.damage, damage * 60f, StatUnit.perSecond);"', source_text)
            self.assertIn('"damage_stat_added": damage_stat_added', source_text)
            self.assertIn('"damage_per_second": damage_per_second', source_text)

    def test_emit_bridges_tractor_beam_turret_init_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    @Override
    public void init(){
        super.init();

        updateClipRadius(range + tilesize);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_init_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var range_value: float = float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var source_tilesize: float = float(_args[1] if _args.size() > 1 else 8.0)", source_text)
            self.assertIn("var clip_radius: float = range_value + source_tilesize", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_tractor_beam_turret_init_state"', source_text)
            self.assertIn('"method": "public void init(){"', source_text)
            self.assertIn('"super_init_expr": "super.init();"', source_text)
            self.assertIn('"update_clip_radius_expr": "updateClipRadius(range + tilesize);"', source_text)
            self.assertIn('"clip_radius": clip_radius', source_text)
            self.assertIn('"update_clip_radius_call": update_clip_radius_call', source_text)

    def test_emit_bridges_tractor_beam_turret_build_should_consume_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        public @Nullable Unit target;

        @Override
        public boolean shouldConsume(){
            return super.shouldConsume() && target != null;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_TractorBeamBuild_method_shouldConsume_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var super_should_consume: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var target: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var target_present: bool = target != null", source_text)
            self.assertIn("var should_consume: bool = super_should_consume and target_present", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_tractor_beam_turret_build_should_consume_state"', source_text)
            self.assertIn('"inner_class": "public class TractorBeamBuild extends BaseTurretBuild{"', source_text)
            self.assertIn('"field": "public @Nullable Unit target;"', source_text)
            self.assertIn('"method": "public boolean shouldConsume(){"', source_text)
            self.assertIn('"return_expr": "return super.shouldConsume() && target != null;"', source_text)

    def test_emit_bridges_tractor_beam_turret_build_estimate_dps_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public float damage = 0f;
    public class TractorBeamBuild extends BaseTurretBuild{
        public boolean any;
        public float coolantMultiplier = 1f;

        @Override
        public float estimateDps(){
            if(!any || damage <= 0) return 0f;
            return damage * 60f * efficiency * coolantMultiplier;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_TractorBeamBuild_method_estimateDps_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var any_state: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var damage: float = float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var efficiency: float = float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var coolant_multiplier: float = float(_args[3] if _args.size() > 3 else 1.0)", source_text)
            self.assertIn("var zero_guard: bool = (not any_state) or damage <= 0.0", source_text)
            self.assertIn("var estimate_dps: float = 0.0 if zero_guard else damage * 60.0 * efficiency * coolant_multiplier", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_tractor_beam_turret_build_estimate_dps_state"', source_text)
            self.assertIn('"inner_class": "public class TractorBeamBuild extends BaseTurretBuild{"', source_text)
            self.assertIn('"method": "public float estimateDps(){"', source_text)
            self.assertIn('"zero_guard_expr": "if(!any || damage <= 0) return 0f;"', source_text)
            self.assertIn('"return_expr": "return damage * 60f * efficiency * coolantMultiplier;"', source_text)

    def test_emit_bridges_tractor_beam_turret_build_write_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void write(Writes write){
            super.write(write);

            write.f(rotation);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_TractorBeamBuild_method_write_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var rotation: float = float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn('var write_f_call: Dictionary = {"call": "write.f(rotation);", "value": rotation}', source_text)
            self.assertIn('return {"source_owner": "PortGame.source_tractor_beam_turret_build_write_state"', source_text)
            self.assertIn('"inner_class": "public class TractorBeamBuild extends BaseTurretBuild{"', source_text)
            self.assertIn('"method": "public void write(Writes write){"', source_text)
            self.assertIn('"super_write_expr": "super.write(write);"', source_text)
            self.assertIn('"write_rotation_expr": "write.f(rotation);"', source_text)
            self.assertIn('"super_write_called": true', source_text)
            self.assertIn('"write_f_call": write_f_call', source_text)

    def test_emit_bridges_tractor_beam_turret_build_read_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void read(Reads read, byte revision){
            super.read(read, revision);

            rotation = read.f();
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_TractorBeamBuild_method_read_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var read_f_value: float = float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var revision_value: int = int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn('var super_read_call: Dictionary = {"call": "super.read(read, revision);", "revision": revision_value}', source_text)
            self.assertIn('var read_f_call: Dictionary = {"call": "read.f();", "value": read_f_value}', source_text)
            self.assertIn("var rotation_after: float = read_f_value", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_tractor_beam_turret_build_read_state"', source_text)
            self.assertIn('"inner_class": "public class TractorBeamBuild extends BaseTurretBuild{"', source_text)
            self.assertIn('"method": "public void read(Reads read, byte revision){"', source_text)
            self.assertIn('"super_read_expr": "super.read(read, revision);"', source_text)
            self.assertIn('"read_rotation_expr": "rotation = read.f();"', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_activation_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_TractorBeamBuild_method_updateTile_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var activation_timer: float = float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var time_delta: float = float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var activation_guard: bool = activation_timer > 0.0", source_text)
            self.assertIn("var activation_timer_after: float = activation_timer - time_delta if activation_guard else activation_timer", source_text)
            self.assertIn("var returned_early: bool = activation_guard", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_tractor_beam_turret_build_update_tile_activation_state"', source_text)
            self.assertIn('"method": "public void updateTile(){"', source_text)
            self.assertIn('"activation_guard_expr": "if(activationTimer > 0){"', source_text)
            self.assertIn('"activation_decrement_expr": "activationTimer -= Time.delta;"', source_text)
            self.assertIn('"return_expr": "return;"', source_text)
            self.assertIn('"next_expr": "float eff = efficiency * coolantMultiplier, edelta = eff * delta();"', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_eff_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            //retarget
            if(timer(timerTarget, retargetTime)){
                target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_TractorBeamBuild_method_updateTile_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var activation_returned_early: bool = activation_guard", source_text)
            self.assertIn("var efficiency: float = float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var coolant_multiplier: float = float(_args[3] if _args.size() > 3 else 1.0)", source_text)
            self.assertIn("var delta_value: float = float(_args[4] if _args.size() > 4 else 0.0)", source_text)
            self.assertIn("var eff_calculated: bool = not activation_returned_early", source_text)
            self.assertIn("var eff: float = efficiency * coolant_multiplier if eff_calculated else 0.0", source_text)
            self.assertIn("var edelta: float = eff * delta_value if eff_calculated else 0.0", source_text)
            self.assertIn('"eff_expr": "float eff = efficiency * coolantMultiplier, edelta = eff * delta();"', source_text)
            self.assertIn('"retarget_comment_expr": "//retarget"', source_text)
            self.assertIn('"retarget_guard_expr": "if(timer(timerTarget, retargetTime)){"', source_text)
            self.assertIn('"eff": eff', source_text)
            self.assertIn('"edelta": edelta', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_retarget_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            //retarget
            if(timer(timerTarget, retargetTime)){
                target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_TractorBeamBuild_method_updateTile_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var timer_target_ready: bool = bool(_args[5] if _args.size() > 5 else false)", source_text)
            self.assertIn("var existing_target: Variant = _args[6] if _args.size() > 6 else null", source_text)
            self.assertIn("var closest_enemy_result: Variant = _args[7] if _args.size() > 7 else null", source_text)
            self.assertIn("var team: Variant = _args[8] if _args.size() > 8 else null", source_text)
            self.assertIn("var x: float = float(_args[9] if _args.size() > 9 else 0.0)", source_text)
            self.assertIn("var y: float = float(_args[10] if _args.size() > 10 else 0.0)", source_text)
            self.assertIn("var range_value: float = float(_args[11] if _args.size() > 11 else 0.0)", source_text)
            self.assertIn("var target_air: bool = bool(_args[12] if _args.size() > 12 else false)", source_text)
            self.assertIn("var target_ground: bool = bool(_args[13] if _args.size() > 13 else false)", source_text)
            self.assertIn("var retarget_evaluated: bool = not activation_returned_early", source_text)
            self.assertIn("var retarget_called: bool = retarget_evaluated and timer_target_ready", source_text)
            self.assertIn("var target_after: Variant = closest_enemy_result if retarget_called else existing_target", source_text)
            self.assertIn('"retarget_assign_expr": "target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));"', source_text)
            self.assertIn('"target_check_filter_expr": "u -> u.checkTarget(targetAir, targetGround)"', source_text)
            self.assertIn('"timer_target_ready": timer_target_ready', source_text)
            self.assertIn('"closest_enemy_result": closest_enemy_result', source_text)
            self.assertIn('"target_after": target_after', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_coolant_guard_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            //retarget
            if(timer(timerTarget, retargetTime)){
                target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));
            }

            //consume coolant
            if(target != null && coolant != null){
                float maxUsed = coolant.amount;

                Liquid liquid = liquids.current();

                float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_TractorBeamBuild_method_updateTile_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var coolant_present: bool = bool(_args[14] if _args.size() > 14 else false)", source_text)
            self.assertIn("var coolant_amount: float = float(_args[15] if _args.size() > 15 else 0.0)", source_text)
            self.assertIn("var current_liquid: Variant = _args[16] if _args.size() > 16 else null", source_text)
            self.assertIn("var coolant_evaluated: bool = not activation_returned_early", source_text)
            self.assertIn("var coolant_guard: bool = coolant_evaluated and target_after != null and coolant_present", source_text)
            self.assertIn("var max_used: float = coolant_amount if coolant_guard else 0.0", source_text)
            self.assertIn("var liquid: Variant = current_liquid if coolant_guard else null", source_text)
            self.assertIn('"coolant_comment_expr": "//consume coolant"', source_text)
            self.assertIn('"coolant_guard_expr": "if(target != null && coolant != null){"', source_text)
            self.assertIn('"max_used_expr": "float maxUsed = coolant.amount;"', source_text)
            self.assertIn('"current_liquid_expr": "Liquid liquid = liquids.current();"', source_text)
            self.assertIn('"used_next_expr": "float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));"', source_text)
            self.assertIn('"coolant_guard": coolant_guard', source_text)
            self.assertIn('"max_used": max_used', source_text)
            self.assertIn('"liquid": liquid', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_coolant_used_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            //retarget
            if(timer(timerTarget, retargetTime)){
                target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));
            }

            //consume coolant
            if(target != null && coolant != null){
                float maxUsed = coolant.amount;

                Liquid liquid = liquids.current();

                float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));

                liquids.remove(liquid, used);
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_TractorBeamBuild_method_updateTile_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var liquid_amount: float = float(_args[17] if _args.size() > 17 else 0.0)", source_text)
            self.assertIn("var liquid_heat_capacity: float = float(_args[18] if _args.size() > 18 else 1.0)", source_text)
            self.assertIn("var max_used_time_delta: float = max_used * time_delta if coolant_guard else 0.0", source_text)
            self.assertIn("var heat_capacity_limit: float = (1.0 / coolant_multiplier) / liquid_heat_capacity if coolant_guard else 0.0", source_text)
            self.assertIn("var nonnegative_heat_capacity_limit: float = max(0.0, heat_capacity_limit) if coolant_guard else 0.0", source_text)
            self.assertIn("var used: float = min(min(liquid_amount, max_used_time_delta), nonnegative_heat_capacity_limit) if coolant_guard else 0.0", source_text)
            self.assertIn('"liquids_get_expr": "liquids.get(liquid)"', source_text)
            self.assertIn('"max_used_time_delta_expr": "maxUsed * Time.delta"', source_text)
            self.assertIn('"heat_capacity_limit_expr": "(1f / coolantMultiplier) / liquid.heatCapacity"', source_text)
            self.assertIn('"used_expr": "float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));"', source_text)
            self.assertIn('"remove_next_expr": "liquids.remove(liquid, used);"', source_text)
            self.assertIn('"liquid_amount": liquid_amount', source_text)
            self.assertIn('"liquid_heat_capacity": liquid_heat_capacity', source_text)
            self.assertIn('"used": used', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_coolant_remove_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            //retarget
            if(timer(timerTarget, retargetTime)){
                target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));
            }

            //consume coolant
            if(target != null && coolant != null){
                float maxUsed = coolant.amount;

                Liquid liquid = liquids.current();

                float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));

                liquids.remove(liquid, used);
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_TractorBeamBuild_method_updateTile_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var remove_called: bool = coolant_guard", source_text)
            self.assertIn("var remove_call: Dictionary = {}", source_text)
            self.assertIn("if remove_called:", source_text)
            self.assertIn('remove_call = {"call": "liquids.remove(liquid, used);", "liquid": liquid, "amount": used}', source_text)
            self.assertIn('"remove_expr": "liquids.remove(liquid, used);"', source_text)
            self.assertIn('"remove_called": remove_called', source_text)
            self.assertIn('"remove_call": remove_call', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_coolant_effect_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            //retarget
            if(timer(timerTarget, retargetTime)){
                target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));
            }

            //consume coolant
            if(target != null && coolant != null){
                float maxUsed = coolant.amount;

                Liquid liquid = liquids.current();

                float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));

                liquids.remove(liquid, used);

                if(Mathf.chance(0.06 * used)){
                    coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));
                }
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var chance_result: bool = bool(_args[19] if _args.size() > 19 else false)", source_text)
            self.assertIn("var size: float = float(_args[20] if _args.size() > 20 else 0.0)", source_text)
            self.assertIn("var source_tilesize: float = float(_args[21] if _args.size() > 21 else 8.0)", source_text)
            self.assertIn("var range_x: float = float(_args[22] if _args.size() > 22 else 0.0)", source_text)
            self.assertIn("var range_y: float = float(_args[23] if _args.size() > 23 else 0.0)", source_text)
            self.assertIn("var chance_threshold: float = 0.06 * used if coolant_guard else 0.0", source_text)
            self.assertIn("var particle_range: float = size * source_tilesize / 2.0 if coolant_guard else 0.0", source_text)
            self.assertIn("var cool_effect_called: bool = coolant_guard and chance_result", source_text)
            self.assertIn('cool_effect_call = {"call": "coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));", "x": x + range_x, "y": y + range_y, "range": particle_range}', source_text)
            self.assertIn('"chance_expr": "Mathf.chance(0.06 * used)"', source_text)
            self.assertIn('"cool_effect_expr": "coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));"', source_text)
            self.assertIn('"cool_effect_call": cool_effect_call', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_coolant_multiplier_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            //retarget
            if(timer(timerTarget, retargetTime)){
                target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));
            }

            //consume coolant
            if(target != null && coolant != null){
                float maxUsed = coolant.amount;

                Liquid liquid = liquids.current();

                float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));

                liquids.remove(liquid, used);

                if(Mathf.chance(0.06 * used)){
                    coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));
                }

                coolantMultiplier = 1f + (used * liquid.heatCapacity * coolantMultiplier);
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var coolant_multiplier_assign_called: bool = coolant_guard", source_text)
            self.assertIn("var coolant_multiplier_after: float = 1.0 + (used * liquid_heat_capacity * coolant_multiplier) if coolant_guard else coolant_multiplier", source_text)
            self.assertIn("var coolant_multiplier_assign_call: Dictionary = {}", source_text)
            self.assertIn("if coolant_multiplier_assign_called:", source_text)
            self.assertIn('coolant_multiplier_assign_call = {"call": "coolantMultiplier = 1f + (used * liquid.heatCapacity * coolantMultiplier);", "value": coolant_multiplier_after}', source_text)
            self.assertIn('"coolant_multiplier_assign_expr": "coolantMultiplier = 1f + (used * liquid.heatCapacity * coolantMultiplier);"', source_text)
            self.assertIn('"coolant_multiplier_after": coolant_multiplier_after', source_text)
            self.assertIn('"coolant_multiplier_assign_call": coolant_multiplier_assign_call', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_any_reset_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            //retarget
            if(timer(timerTarget, retargetTime)){
                target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));
            }

            //consume coolant
            if(target != null && coolant != null){
                float maxUsed = coolant.amount;

                Liquid liquid = liquids.current();

                float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));

                liquids.remove(liquid, used);

                if(Mathf.chance(0.06 * used)){
                    coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));
                }

                coolantMultiplier = 1f + (used * liquid.heatCapacity * coolantMultiplier);
            }

            any = false;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var any_before: bool = bool(_args[24] if _args.size() > 24 else false)", source_text)
            self.assertIn("var any_reset_evaluated: bool = not activation_returned_early", source_text)
            self.assertIn("var any_reset_called: bool = any_reset_evaluated", source_text)
            self.assertIn("var any_after: bool = false if any_reset_evaluated else any_before", source_text)
            self.assertIn("var any_reset_call: Dictionary = {}", source_text)
            self.assertIn("if any_reset_called:", source_text)
            self.assertIn('any_reset_call = {"call": "any = false;", "value": any_after}', source_text)
            self.assertIn('"any_reset_expr": "any = false;"', source_text)
            self.assertIn('"any_after": any_after', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_look_target_guard_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            //retarget
            if(timer(timerTarget, retargetTime)){
                target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));
            }

            //consume coolant
            if(target != null && coolant != null){
                float maxUsed = coolant.amount;

                Liquid liquid = liquids.current();

                float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));

                liquids.remove(liquid, used);

                if(Mathf.chance(0.06 * used)){
                    coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));
                }

                coolantMultiplier = 1f + (used * liquid.heatCapacity * coolantMultiplier);
            }

            any = false;

            //look at target
            if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var target_within_result: bool = bool(_args[25] if _args.size() > 25 else false)", source_text)
            self.assertIn("var target_team: Variant = _args[26] if _args.size() > 26 else null", source_text)
            self.assertIn("var target_check_result: bool = bool(_args[27] if _args.size() > 27 else false)", source_text)
            self.assertIn("var target_hit_size: float = float(_args[28] if _args.size() > 28 else 0.0)", source_text)
            self.assertIn("var look_target_evaluated: bool = not activation_returned_early", source_text)
            self.assertIn("var target_exists_for_look: bool = look_target_evaluated and target_after != null", source_text)
            self.assertIn("var target_within_radius: float = range_value + target_hit_size / 2.0 if target_exists_for_look else 0.0", source_text)
            self.assertIn("var target_within_evaluated: bool = target_exists_for_look", source_text)
            self.assertIn("var target_enemy: bool = target_team != team if target_team_evaluated else false", source_text)
            self.assertIn("var target_check_evaluated: bool = target_team_evaluated and target_enemy", source_text)
            self.assertIn("var efficiency_gate_evaluated: bool = target_check_evaluated and target_check_result", source_text)
            self.assertIn("var look_target_guard: bool = efficiency_gate_evaluated and efficiency > 0.02", source_text)
            self.assertIn('"look_target_comment_expr": "//look at target"', source_text)
            self.assertIn('"look_target_guard_expr": "if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){"', source_text)
            self.assertIn('"look_target_guard": look_target_guard', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_sound_loop_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            any = false;

            //look at target
            if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){
                if(!headless){
                    control.sound.loop(shootSound, this, shootSoundVolume);
                }
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var headless: bool = bool(_args[29] if _args.size() > 29 else false)", source_text)
            self.assertIn("var shoot_sound: Variant = _args[30] if _args.size() > 30 else null", source_text)
            self.assertIn("var shoot_sound_volume: float = float(_args[31] if _args.size() > 31 else 1.0)", source_text)
            self.assertIn("var sound_loop_evaluated: bool = look_target_guard", source_text)
            self.assertIn("var sound_loop_called: bool = sound_loop_evaluated and not headless", source_text)
            self.assertIn("var shoot_sound_loop_call: Dictionary = {}", source_text)
            self.assertIn("if sound_loop_called:", source_text)
            self.assertIn('shoot_sound_loop_call = {"call": "control.sound.loop(shootSound, this, shootSoundVolume);", "sound": shoot_sound, "target": "this", "volume": shoot_sound_volume}', source_text)
            self.assertIn('"sound_loop_guard_expr": "if(!headless){"', source_text)
            self.assertIn('"shoot_sound_loop_expr": "control.sound.loop(shootSound, this, shootSoundVolume);"', source_text)
            self.assertIn('"shoot_sound_loop_call": shoot_sound_loop_call', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_angle_to_target_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            any = false;

            //look at target
            if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){
                if(!headless){
                    control.sound.loop(shootSound, this, shootSoundVolume);
                }

                float dest = angleTo(target);
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var angle_to_target_evaluated: bool = look_target_guard", source_text)
            self.assertIn("var dest: float = 0.0", source_text)
            self.assertIn("if angle_to_target_evaluated and target_after is Dictionary:", source_text)
            self.assertIn('dest = rad_to_deg(atan2(float(target_after.get("y", 0.0)) - y, float(target_after.get("x", 0.0)) - x))', source_text)
            self.assertIn("if dest < 0.0:", source_text)
            self.assertIn("dest += 360.0", source_text)
            self.assertIn("var angle_to_target_call: Dictionary = {}", source_text)
            self.assertIn('angle_to_target_call = {"call": "angleTo(target)", "origin": {"x": x, "y": y}, "target": target_after, "result": dest}', source_text)
            self.assertIn('"dest_expr": "float dest = angleTo(target);"', source_text)
            self.assertIn('"angle_to_target_call": angle_to_target_call', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_rotation_move_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            any = false;

            //look at target
            if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){
                if(!headless){
                    control.sound.loop(shootSound, this, shootSoundVolume);
                }

                float dest = angleTo(target);
                rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var rotation_before: float = float(_args[32] if _args.size() > 32 else 0.0)", source_text)
            self.assertIn("var rotate_speed: float = float(_args[33] if _args.size() > 33 else 0.0)", source_text)
            self.assertIn("var rotation_move_evaluated: bool = angle_to_target_evaluated", source_text)
            self.assertIn("var rotation_max_delta: float = rotate_speed * edelta if rotation_move_evaluated else 0.0", source_text)
            self.assertIn("var rotation_after: float = rotation_before", source_text)
            self.assertIn("var rotation_angle_dist: float = min(rotation_forward_delta, rotation_backward_delta)", source_text)
            self.assertIn("if abs(rotation_angle_dist) < rotation_max_delta:", source_text)
            self.assertIn("rotation_after = dest", source_text)
            self.assertIn("rotation_after = rotation_angle_mod - rotation_max_delta", source_text)
            self.assertIn("rotation_after = rotation_angle_mod + rotation_max_delta", source_text)
            self.assertIn('rotation_move_call = {"call": "Angles.moveToward(rotation, dest, rotateSpeed * edelta)", "rotation": rotation_before, "dest": dest, "speed": rotation_max_delta, "result": rotation_after}', source_text)
            self.assertIn('"rotation_move_expr": "rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);"', source_text)
            self.assertIn('"rotation_after": rotation_after', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_last_target_position_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            any = false;

            //look at target
            if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){
                float dest = angleTo(target);
                rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);
                lastX = target.x;
                lastY = target.y;
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var last_x_before: float = float(_args[34] if _args.size() > 34 else 0.0)", source_text)
            self.assertIn("var last_y_before: float = float(_args[35] if _args.size() > 35 else 0.0)", source_text)
            self.assertIn("var last_target_position_evaluated: bool = rotation_move_evaluated", source_text)
            self.assertIn("var last_x_after: float = last_x_before", source_text)
            self.assertIn("var last_y_after: float = last_y_before", source_text)
            self.assertIn('last_target_position_call = {"call": "lastX = target.x; lastY = target.y;", "target": target_after, "last_x": last_x_after, "last_y": last_y_after}', source_text)
            self.assertIn('"last_x_expr": "lastX = target.x;"', source_text)
            self.assertIn('"last_y_expr": "lastY = target.y;"', source_text)
            self.assertIn('"last_x_after": last_x_after', source_text)
            self.assertIn('"last_y_after": last_y_after', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_active_strength_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            any = false;

            //look at target
            if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){
                float dest = angleTo(target);
                rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);
                lastX = target.x;
                lastY = target.y;
                strength = Mathf.lerpDelta(strength, 1f, 0.1f);
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var strength_before: float = float(_args[36] if _args.size() > 36 else 0.0)", source_text)
            self.assertIn("var strength_lerp_evaluated: bool = last_target_position_evaluated", source_text)
            self.assertIn("var strength_lerp_progress: float = 0.1", source_text)
            self.assertIn("var strength_lerp_scaled_progress: float = strength_lerp_progress * time_delta if strength_lerp_evaluated else 0.0", source_text)
            self.assertIn("var strength_lerp_clamped_progress: float = clampf(strength_lerp_scaled_progress, 0.0, 1.0)", source_text)
            self.assertIn("var strength_after: float = strength_before + (1.0 - strength_before) * strength_lerp_clamped_progress if strength_lerp_evaluated else strength_before", source_text)
            self.assertIn('strength_lerp_call = {"call": "strength = Mathf.lerpDelta(strength, 1f, 0.1f);", "from": strength_before, "to": 1.0, "progress": strength_lerp_progress, "time_delta": time_delta, "result": strength_after}', source_text)
            self.assertIn('"strength_lerp_expr": "strength = Mathf.lerpDelta(strength, 1f, 0.1f);"', source_text)
            self.assertIn('"strength_after": strength_after', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_inactive_strength_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){
                strength = Mathf.lerpDelta(strength, 1f, 0.1f);
            }else{
                strength = Mathf.lerpDelta(strength, 0, 0.1f);
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var inactive_strength_evaluated: bool = not activation_returned_early and not look_target_guard", source_text)
            self.assertIn("var inactive_strength_lerp_progress: float = 0.1", source_text)
            self.assertIn("var inactive_strength_lerp_scaled_progress: float = inactive_strength_lerp_progress * time_delta if inactive_strength_evaluated else 0.0", source_text)
            self.assertIn("var inactive_strength_after: float = strength_before + (0.0 - strength_before) * inactive_strength_lerp_clamped_progress if inactive_strength_evaluated else strength_after", source_text)
            self.assertIn("if inactive_strength_evaluated:", source_text)
            self.assertIn("\t\tstrength_after = inactive_strength_after", source_text)
            self.assertIn('inactive_strength_lerp_call = {"call": "strength = Mathf.lerpDelta(strength, 0, 0.1f);", "from": strength_before, "to": 0.0, "progress": inactive_strength_lerp_progress, "time_delta": time_delta, "result": inactive_strength_after}', source_text)
            self.assertIn('"inactive_strength_lerp_expr": "strength = Mathf.lerpDelta(strength, 0, 0.1f);"', source_text)
            self.assertIn('"inactive_strength_after": inactive_strength_after', source_text)
            self.assertIn('"inactive_strength_lerp_call": inactive_strength_lerp_call', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            any = false;

            //look at target
            if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){
                float dest = angleTo(target);
                rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);
                lastX = target.x;
                lastY = target.y;
                strength = Mathf.lerpDelta(strength, 1f, 0.1f);

                //shoot when possible
                if(Angles.within(rotation, dest, shootCone)){
                }
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var shoot_cone: float = float(_args[37] if _args.size() > 37 else 0.0)", source_text)
            self.assertIn("var shoot_when_possible_evaluated: bool = strength_lerp_evaluated", source_text)
            self.assertIn("var shoot_within_angle_dist: float = 0.0", source_text)
            self.assertIn("var shoot_within_guard: bool = shoot_when_possible_evaluated and shoot_within_angle_dist <= shoot_cone", source_text)
            self.assertIn('shoot_within_call = {"call": "Angles.within(rotation, dest, shootCone)", "rotation": rotation_after, "dest": dest, "shoot_cone": shoot_cone, "angle_dist": shoot_within_angle_dist, "result": shoot_within_guard}', source_text)
            self.assertIn('"shoot_when_possible_guard_expr": "if(Angles.within(rotation, dest, shootCone)){"', source_text)
            self.assertIn('"angles_within_method": "public static boolean within(float a, float b, float margin){\\n        return angleDist(a, b) <= margin;\\n    }"', source_text)
            self.assertIn('"shoot_within_guard": shoot_within_guard', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_damage_pierce_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            any = false;

            //look at target
            if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){
                float dest = angleTo(target);
                rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);
                lastX = target.x;
                lastY = target.y;
                strength = Mathf.lerpDelta(strength, 1f, 0.1f);

                //shoot when possible
                if(Angles.within(rotation, dest, shootCone)){
                    if(damage > 0){
                        target.damageContinuousPierce(damage * eff * timeScale * state.rules.blockDamage(team));
                    }
                }
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var damage: float = float(_args[38] if _args.size() > 38 else 0.0)", source_text)
            self.assertIn("var time_scale: float = float(_args[39] if _args.size() > 39 else 1.0)", source_text)
            self.assertIn("var rules_block_damage: float = float(_args[40] if _args.size() > 40 else 1.0)", source_text)
            self.assertIn("var damage_gate_evaluated: bool = shoot_within_guard", source_text)
            self.assertIn("var damage_gate: bool = damage_gate_evaluated and damage > 0.0", source_text)
            self.assertIn("var damage_amount: float = damage * eff * time_scale * rules_block_damage if damage_gate else 0.0", source_text)
            self.assertIn('block_damage_call = {"call": "state.rules.blockDamage(team)", "team": team, "result": rules_block_damage}', source_text)
            self.assertIn('damage_continuous_pierce_call = {"call": "target.damageContinuousPierce(damage * eff * timeScale * state.rules.blockDamage(team));", "target": target_after, "amount": damage_amount}', source_text)
            self.assertIn('"damage_gate_expr": "if(damage > 0){"', source_text)
            self.assertIn('"damage_continuous_pierce_expr": "target.damageContinuousPierce(damage * eff * timeScale * state.rules.blockDamage(team));"', source_text)
            self.assertIn('"status_next_expr": "if(status != StatusEffects.none){"', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_status_apply_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            any = false;

            //look at target
            if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){
                float dest = angleTo(target);
                rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);
                lastX = target.x;
                lastY = target.y;
                strength = Mathf.lerpDelta(strength, 1f, 0.1f);

                //shoot when possible
                if(Angles.within(rotation, dest, shootCone)){
                    if(damage > 0){
                        target.damageContinuousPierce(damage * eff * timeScale * state.rules.blockDamage(team));
                    }

                    if(status != StatusEffects.none){
                        target.apply(status, statusDuration);
                    }
                }
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var status: Variant = _args[41] if _args.size() > 41 else \"StatusEffects.none\"", source_text)
            self.assertIn("var status_duration: float = float(_args[42] if _args.size() > 42 else 300.0)", source_text)
            self.assertIn("var status_gate_evaluated: bool = shoot_within_guard", source_text)
            self.assertIn("var status_is_none: bool = status is String and status == \"StatusEffects.none\"", source_text)
            self.assertIn("var status_gate: bool = status_gate_evaluated and not status_is_none", source_text)
            self.assertIn('status_apply_call = {"call": "target.apply(status, statusDuration);", "target": target_after, "status": status, "duration": status_duration}', source_text)
            self.assertIn('"status_gate_expr": "if(status != StatusEffects.none){"', source_text)
            self.assertIn('"status_apply_expr": "target.apply(status, statusDuration);"', source_text)
            self.assertIn('"any_next_expr": "any = true;"', source_text)
            self.assertIn('"status": status', source_text)
            self.assertIn('"status_apply_call": status_apply_call', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_any_true_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            any = false;

            //look at target
            if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){
                float dest = angleTo(target);
                rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);
                lastX = target.x;
                lastY = target.y;
                strength = Mathf.lerpDelta(strength, 1f, 0.1f);

                //shoot when possible
                if(Angles.within(rotation, dest, shootCone)){
                    if(status != StatusEffects.none){
                        target.apply(status, statusDuration);
                    }

                    any = true;
                    target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));
                }
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var any_before_shoot: bool = any_after", source_text)
            self.assertIn("var any_true_evaluated: bool = shoot_within_guard", source_text)
            self.assertIn("var any_true_called: bool = any_true_evaluated", source_text)
            self.assertIn("if any_true_called:", source_text)
            self.assertIn("\t\tany_after = true", source_text)
            self.assertIn('any_true_call = {"call": "any = true;", "value": any_after}', source_text)
            self.assertIn('"any_true_expr": "any = true;"', source_text)
            self.assertIn('"impulse_next_expr": "target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));"', source_text)
            self.assertIn('"any_before_shoot": any_before_shoot', source_text)
            self.assertIn('"any_true_call": any_true_call', source_text)

    def test_emit_bridges_tractor_beam_turret_build_update_tile_impulse_net_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public float force = 0.3f;
    public float scaledForce = 0f;

    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void updateTile(){
            if(activationTimer > 0){
                activationTimer -= Time.delta;
                return;
            }

            float eff = efficiency * coolantMultiplier, edelta = eff * delta();

            any = false;

            if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){
                float dest = angleTo(target);
                rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);
                lastX = target.x;
                lastY = target.y;
                strength = Mathf.lerpDelta(strength, 1f, 0.1f);

                if(Angles.within(rotation, dest, shootCone)){
                    any = true;
                    target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));
                }
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("var force_value: float = float(_args[43]) if _args.size() > 43 else 0.3", source_text)
            self.assertIn("var scaled_force: float = float(_args[44]) if _args.size() > 44 else 0.0", source_text)
            self.assertIn("var target_dst_to_building: float = sqrt(pow(target_x_for_impulse - x, 2) + pow(target_y_for_impulse - y, 2))", source_text)
            self.assertIn("var impulse_limit: float = (force_value + (1.0 - target_dst_to_building / range_value) * scaled_force) * edelta", source_text)
            self.assertIn("var impulse_net_called: bool = any_true_called", source_text)
            self.assertIn("var impulse_net_call: Dictionary = {}", source_text)
            self.assertIn('impulse_net_call = {"call": "target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));"', source_text)
            self.assertIn('"force_expr": "public float force = 0.3f;"', source_text)
            self.assertIn('"scaled_force_expr": "public float scaledForce = 0f;"', source_text)
            self.assertIn('"impulse_net_expr": "target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));"', source_text)
            self.assertIn('"impulse_net_call": impulse_net_call', source_text)

    def test_emit_bridges_tractor_beam_turret_build_draw_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class TractorBeamTurret extends BaseTurret{
    public class TractorBeamBuild extends BaseTurretBuild{
        @Override
        public void draw(){
            Draw.rect(baseRegion, x, y);
            Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);
            Draw.rect(region, x, y, rotation - 90);

            //draw laser if applicable
            if(any && !isPayload()){
                Draw.z(Layer.bullet);
                float ang = angleTo(lastX, lastY);

                Draw.mixcol(laserColor, Mathf.absin(4f, 0.6f));

                Drawf.laser(laser, laserStart, laserEnd,
                x + Angles.trnsx(ang, shootLength), y + Angles.trnsy(ang, shootLength),
                lastX, lastY, strength * efficiency * laserWidth);

                Draw.mixcol();
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_TractorBeamBuild_method_draw_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var rotation_value: float = float(_args[4] if _args.size() > 4 else 0.0)", source_text)
            self.assertIn("var laser_guard: bool = any_state and not is_payload", source_text)
            self.assertIn("var draw_rotation: float = rotation_value - 90.0", source_text)
            self.assertIn("var laser_width_value: float = strength * efficiency * laser_width", source_text)
            self.assertIn('var base_rect_call: Dictionary = {"call": "Draw.rect(baseRegion, x, y);"', source_text)
            self.assertIn('var shadow_call: Dictionary = {"call": "Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);"', source_text)
            self.assertIn('var region_rect_call: Dictionary = {"call": "Draw.rect(region, x, y, rotation - 90);"', source_text)
            self.assertIn('var laser_call: Dictionary = {}', source_text)
            self.assertIn('laser_call = {"call": "Drawf.laser(laser, laserStart, laserEnd, x + Angles.trnsx(ang, shootLength), y + Angles.trnsy(ang, shootLength), lastX, lastY, strength * efficiency * laserWidth);"', source_text)
            self.assertIn('return {"source_owner": "PortGame.source_tractor_beam_turret_build_draw_state"', source_text)
            self.assertIn('"laser_guard_expr": "if(any && !isPayload()){"', source_text)
            self.assertIn('"angle_expr": "float ang = angleTo(lastX, lastY);"', source_text)
            self.assertIn('"laser_expr": "Drawf.laser(laser, laserStart, laserEnd, x + Angles.trnsx(ang, shootLength), y + Angles.trnsy(ang, shootLength), lastX, lastY, strength * efficiency * laserWidth);"', source_text)

    def test_emit_bridges_ability_update_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            ability_path = source_root / "mindustry" / "entities" / "abilities" / "Ability.java"
            ability_path.parent.mkdir(parents=True, exist_ok=True)
            ability_path.write_text(
                """
package mindustry.entities.abilities;

public abstract class Ability implements Cloneable{
    public void update(Unit unit){}
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "abilities" / "Ability.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_update_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar unit: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_ability_update_state"', source_text)
            self.assertIn('"method": "public void update(Unit unit){}"', source_text)
            self.assertIn('"unit": unit', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_ability_draw_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            ability_path = source_root / "mindustry" / "entities" / "abilities" / "Ability.java"
            ability_path.parent.mkdir(parents=True, exist_ok=True)
            ability_path.write_text(
                """
package mindustry.entities.abilities;

public abstract class Ability implements Cloneable{
    public void draw(Unit unit){}
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "abilities" / "Ability.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_draw_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar unit: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_ability_draw_state"', source_text)
            self.assertIn('"method": "public void draw(Unit unit){}"', source_text)
            self.assertIn('"unit": unit', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_ability_death_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            ability_path = source_root / "mindustry" / "entities" / "abilities" / "Ability.java"
            ability_path.parent.mkdir(parents=True, exist_ok=True)
            ability_path.write_text(
                """
package mindustry.entities.abilities;

public abstract class Ability implements Cloneable{
    public void death(Unit unit){}
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "abilities" / "Ability.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_death_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar unit: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_ability_death_state"', source_text)
            self.assertIn('"method": "public void death(Unit unit){}"', source_text)
            self.assertIn('"unit": unit', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_ability_created_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            ability_path = source_root / "mindustry" / "entities" / "abilities" / "Ability.java"
            ability_path.parent.mkdir(parents=True, exist_ok=True)
            ability_path.write_text(
                """
package mindustry.entities.abilities;

public abstract class Ability implements Cloneable{
    public void created(Unit unit){}
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "abilities" / "Ability.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_created_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar unit: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_ability_created_state"', source_text)
            self.assertIn('"method": "public void created(Unit unit){}"', source_text)
            self.assertIn('"unit": unit', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_ability_init_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            ability_path = source_root / "mindustry" / "entities" / "abilities" / "Ability.java"
            ability_path.parent.mkdir(parents=True, exist_ok=True)
            ability_path.write_text(
                """
package mindustry.entities.abilities;

public abstract class Ability implements Cloneable{
    public void init(UnitType type){}
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "abilities" / "Ability.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_init_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar type_value: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_ability_init_state"', source_text)
            self.assertIn('"method": "public void init(UnitType type){}"', source_text)
            self.assertIn('"type": type_value', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_ability_display_bars_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            ability_path = source_root / "mindustry" / "entities" / "abilities" / "Ability.java"
            ability_path.parent.mkdir(parents=True, exist_ok=True)
            ability_path.write_text(
                """
package mindustry.entities.abilities;

public abstract class Ability implements Cloneable{
    public void displayBars(Unit unit, Table bars){}
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "abilities" / "Ability.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_displayBars_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar unit: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("\tvar bars: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_ability_display_bars_state"', source_text)
            self.assertIn('"method": "public void displayBars(Unit unit, Table bars){}"', source_text)
            self.assertIn('"unit": unit', source_text)
            self.assertIn('"bars": bars', source_text)
            self.assertIn('"no_op": true', source_text)

    def test_emit_bridges_ability_display_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            ability_path = source_root / "mindustry" / "entities" / "abilities" / "Ability.java"
            ability_path.parent.mkdir(parents=True, exist_ok=True)
            ability_path.write_text(
                """
package mindustry.entities.abilities;

public abstract class Ability implements Cloneable{
    public void display(Table t){
        t.table(Styles.grayPanel, a -> {
            a.add("[accent]" + localized()).padBottom(4).center().top().expandX();
            a.row();
            a.left().top().defaults().left();
            addStats(a);
        }).pad(5).margin(10).growX().top().uniformX();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "abilities" / "Ability.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_display_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar table_state: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("\tvar localized_value: String = str(_args[1] if _args.size() > 1 else \"\")", source_text)
            self.assertIn('"source_owner": "PortGame.source_ability_display_state"', source_text)
            self.assertIn('"method": "public void display(Table t){"', source_text)
            self.assertIn('"table": table_state', source_text)
            self.assertIn('"style_expr": "Styles.grayPanel"', source_text)
            self.assertIn('"localized_call": "localized()"', source_text)
            self.assertIn('"title_text": "[accent]" + localized_value', source_text)
            self.assertIn('"add_stats_call": "addStats(a);"', source_text)
            self.assertIn('"table_mutation": true', source_text)

    def test_emit_bridges_ability_add_stats_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            ability_path = source_root / "mindustry" / "entities" / "abilities" / "Ability.java"
            ability_path.parent.mkdir(parents=True, exist_ok=True)
            ability_path.write_text(
                """
package mindustry.entities.abilities;

public abstract class Ability implements Cloneable{
    protected static final float descriptionWidth = 350f;
    public void addStats(Table t){
        if(Core.bundle.has(getBundle() + ".description")){
            t.add(Core.bundle.get(getBundle() + ".description")).wrap().width(descriptionWidth);
            t.row();
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "abilities" / "Ability.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_addStats_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar table_state: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("\tvar get_bundle_value: String = str(_args[1] if _args.size() > 1 else \"\")", source_text)
            self.assertIn("\tvar bundle_has_description: bool = bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("\tvar bundle_description: String = str(_args[3] if _args.size() > 3 else \"\")", source_text)
            self.assertIn('"source_owner": "PortGame.source_ability_add_stats_state"', source_text)
            self.assertIn('"method": "public void addStats(Table t){"', source_text)
            self.assertIn('"field_expr": "protected static final float descriptionWidth = 350f;"', source_text)
            self.assertIn('"description_width": 350.0', source_text)
            self.assertIn('"guard_passed": bundle_has_description', source_text)
            self.assertIn('"add_description_call": add_description_call', source_text)
            self.assertIn('"row_call": row_call', source_text)

    def test_emit_bridges_ability_ability_stat_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            ability_path = source_root / "mindustry" / "entities" / "abilities" / "Ability.java"
            ability_path.parent.mkdir(parents=True, exist_ok=True)
            ability_path.write_text(
                """
package mindustry.entities.abilities;

public abstract class Ability implements Cloneable{
    public String abilityStat(String stat, Object... values){
        return Core.bundle.format("ability.stat." + stat, values);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "abilities" / "Ability.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_abilityStat_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar stat_value: String = str(_args[0] if _args.size() > 0 else \"\")", source_text)
            self.assertIn("\tvar values: Array = []", source_text)
            self.assertIn("\tvar formatted_value: String = str(_args[2] if _args.size() > 2 else \"\")", source_text)
            self.assertIn("\tvar bundle_key: String = \"ability.stat.\" + stat_value", source_text)
            self.assertIn('"source_owner": "PortGame.source_ability_ability_stat_state"', source_text)
            self.assertIn('"method": "public String abilityStat(String stat, Object... values){"', source_text)
            self.assertIn('"bundle_key_expr": "\\"ability.stat.\\" + stat"', source_text)
            self.assertIn('"format_call": "Core.bundle.format(\\"ability.stat.\\" + stat, values)"', source_text)
            self.assertIn('"formatted_value": formatted_value', source_text)
            self.assertIn('"return_value": formatted_value', source_text)

    def test_emit_bridges_ability_copy_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            ability_path = source_root / "mindustry" / "entities" / "abilities" / "Ability.java"
            ability_path.parent.mkdir(parents=True, exist_ok=True)
            ability_path.write_text(
                """
package mindustry.entities.abilities;

public abstract class Ability implements Cloneable{
    public Ability copy(){
        try{
            return (Ability)clone();
        }catch(CloneNotSupportedException e){
            //I am disgusted
            throw new RuntimeException("java sucks", e);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "abilities" / "Ability.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_copy_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar clone_supported: bool = bool(_args[0] if _args.size() > 0 else true)", source_text)
            self.assertIn("\tvar clone_value: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("\tvar exception_value: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_ability_copy_state"', source_text)
            self.assertIn('"method": "public Ability copy(){"', source_text)
            self.assertIn('"clone_return_expr": "return (Ability)clone();"', source_text)
            self.assertIn('"catch_expr": "}catch(CloneNotSupportedException e){"', source_text)
            self.assertIn('"runtime_exception_expr": "throw new RuntimeException(\\"java sucks\\", e);"', source_text)
            self.assertIn('"return_value": return_value', source_text)
            self.assertIn('"thrown_exception": thrown_exception', source_text)

    def test_emit_bridges_ability_localized_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            ability_path = source_root / "mindustry" / "entities" / "abilities" / "Ability.java"
            ability_path.parent.mkdir(parents=True, exist_ok=True)
            ability_path.write_text(
                """
package mindustry.entities.abilities;

public abstract class Ability implements Cloneable{
    /** @return localized ability name; mods should override this. */
    public String localized(){
        return Core.bundle.get(getBundle());
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "abilities" / "Ability.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_localized_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar get_bundle_value: String = str(_args[0] if _args.size() > 0 else \"\")", source_text)
            self.assertIn("\tvar bundle_value: String = str(_args[1] if _args.size() > 1 else \"\")", source_text)
            self.assertIn('"source_owner": "PortGame.source_ability_localized_state"', source_text)
            self.assertIn('"comment": "/** @return localized ability name; mods should override this. */"', source_text)
            self.assertIn('"method": "public String localized(){"', source_text)
            self.assertIn('"get_bundle_call": "getBundle()"', source_text)
            self.assertIn('"get_bundle_value": get_bundle_value', source_text)
            self.assertIn('"bundle_get_call": "Core.bundle.get(getBundle())"', source_text)
            self.assertIn('"return_expr": "return Core.bundle.get(getBundle());"', source_text)
            self.assertIn('"return_value": bundle_value', source_text)

    def test_emit_bridges_ability_get_bundle_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            ability_path = source_root / "mindustry" / "entities" / "abilities" / "Ability.java"
            ability_path.parent.mkdir(parents=True, exist_ok=True)
            ability_path.write_text(
                """
package mindustry.entities.abilities;

public abstract class Ability implements Cloneable{
    public String getBundle(){
        var type = getClass();
        return "ability." + (type.isAnonymousClass() ? type.getSuperclass() : type).getSimpleName().replace("Ability", "").toLowerCase();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "abilities" / "Ability.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_getBundle_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("\tvar class_simple_name: String = str(_args[0] if _args.size() > 0 else \"\")", source_text)
            self.assertIn("\tvar is_anonymous_class: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("\tvar superclass_simple_name: String = str(_args[2] if _args.size() > 2 else \"\")", source_text)
            self.assertIn("\tvar selected_simple_name: String = superclass_simple_name if is_anonymous_class else class_simple_name", source_text)
            self.assertIn("\tvar stripped_name: String = selected_simple_name.replace(\"Ability\", \"\")", source_text)
            self.assertIn("\tvar return_value: String = \"ability.\" + stripped_name.to_lower()", source_text)
            self.assertIn('"source_owner": "PortGame.source_ability_get_bundle_state"', source_text)
            self.assertIn('"method": "public String getBundle(){"', source_text)
            self.assertIn('"type_assignment": "var type = getClass();"', source_text)
            self.assertIn('"return_expr": "return \\"ability.\\" + (type.isAnonymousClass() ? type.getSuperclass() : type).getSimpleName().replace(\\"Ability\\", \\"\\").toLowerCase();"', source_text)
            self.assertIn('"return_value": return_value', source_text)

    def test_emit_bridges_turret_get_regions_to_outline_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class Turret extends ReloadTurret{
    @Override
    public void getRegionsToOutline(Seq<TextureRegion> out){
        drawer.getRegionsToOutline(this, out);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_getRegionsToOutline_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var out: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_turret_get_regions_to_outline_state"', source_text)
            self.assertIn('"method": "public void getRegionsToOutline(Seq<TextureRegion> out){"', source_text)
            self.assertIn('"drawer_get_regions_to_outline_expr": "drawer.getRegionsToOutline(this, out);"', source_text)
            self.assertIn('"drawer_get_regions_to_outline_called": true', source_text)

    def test_emit_bridges_turret_limit_range_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class Turret extends ReloadTurret{
    public void limitRange(BulletType bullet, float margin){
        float realRange = bullet.rangeChange + range;
        //doesn't handle drag
        bullet.lifetime = (realRange + margin + bullet.extraRangeMargin + 10f) / bullet.speed;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_limitRange_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var bullet: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}", source_text)
            self.assertIn("var margin: float = float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var turret_range: float = float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var real_range: float = bullet_range_change + turret_range", source_text)
            self.assertIn("var bullet_lifetime: float = (real_range + margin + bullet_extra_range_margin + 10.0) / bullet_speed", source_text)
            self.assertIn('bullet["lifetime"] = bullet_lifetime', source_text)
            self.assertIn('return {"source_owner": "PortGame.source_turret_limit_range_state"', source_text)
            self.assertIn('"method": "public void limitRange(BulletType bullet, float margin){"', source_text)
            self.assertIn('"real_range_expr": "float realRange = bullet.rangeChange + range;"', source_text)
            self.assertIn('"lifetime_expr": "bullet.lifetime = (realRange + margin + bullet.extraRangeMargin + 10f) / bullet.speed;"', source_text)

    def test_emit_bridges_turret_draw_place_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class Turret extends ReloadTurret{
    @Override
    public void drawPlace(int x, int y, int rotation, boolean valid){
        super.drawPlace(x, y, rotation, valid);

        if(drawMinRange){
            Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, minRange, Pal.placing);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_drawPlace_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var tile_x: int = int(_args[0] if _args.size() > 0 else 0)", source_text)
            self.assertIn("var tile_y: int = int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("var draw_min_range: bool = bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("var dash_circle_x: float = float(tile_x) * source_tilesize + block_offset", source_text)
            self.assertIn("var dash_circle_called: bool = draw_min_range", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_turret_draw_place_state"', source_text)
            self.assertIn('"method": "public void drawPlace(int x, int y, int rotation, boolean valid){"', source_text)
            self.assertIn('"super_draw_place_expr": "super.drawPlace(x, y, rotation, valid);"', source_text)
            self.assertIn('"draw_min_range_gate": "if(drawMinRange){"', source_text)
            self.assertIn('"dash_circle_expr": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, minRange, Pal.placing);"', source_text)

    def test_emit_bridges_turret_set_stats_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class Turret extends ReloadTurret{
    @Override
    public void setStats(){
        super.setStats();

        stats.add(Stat.inaccuracy, (int)inaccuracy, StatUnit.degrees);
        stats.add(Stat.reload, 60f / (reload + (!reloadWhileCharging ? shoot.firstShotDelay : 0f)) * shoot.shots, StatUnit.perSecond);
        stats.add(Stat.targetsAir, targetAir);
        stats.add(Stat.targetsGround, targetGround);
        if(ammoPerShot != 1) stats.add(Stat.ammoUse, ammoPerShot, StatUnit.perShot);
        if(heatRequirement > 0) stats.add(Stat.input, heatRequirement, StatUnit.heatUnits);
        if(heatRequirement > 0 && maxHeatEfficiency > 0) stats.add(Stat.maxEfficiency, (int)(maxHeatEfficiency * 100f), StatUnit.percent);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setStats_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var reload_stat_denominator: float = reload_value + (shoot_first_shot_delay if not reload_while_charging else 0.0)", source_text)
            self.assertIn("var reload_stat_rate: float = 60.0 / reload_stat_denominator * shoot_shots", source_text)
            self.assertIn("var ammo_use_stat_called: bool = ammo_per_shot != 1", source_text)
            self.assertIn("var input_heat_stat_called: bool = heat_requirement > 0.0", source_text)
            self.assertIn("var max_efficiency_stat_called: bool = heat_requirement > 0.0 and max_heat_efficiency > 0.0", source_text)
            self.assertIn('"source_owner": "PortGame.source_turret_set_stats_state"', source_text)
            self.assertIn('"method": "public void setStats(){"', source_text)
            self.assertIn('"super_set_stats_expr": "super.setStats();"', source_text)
            self.assertIn('"inaccuracy_stat_expr": "stats.add(Stat.inaccuracy, (int)inaccuracy, StatUnit.degrees);"', source_text)
            self.assertIn('"reload_stat_expr": "stats.add(Stat.reload, 60f / (reload + (!reloadWhileCharging ? shoot.firstShotDelay : 0f)) * shoot.shots, StatUnit.perSecond);"', source_text)
            self.assertIn('"max_efficiency_stat_expr": "stats.add(Stat.maxEfficiency, (int)(maxHeatEfficiency * 100f), StatUnit.percent);"', source_text)

    def test_emit_bridges_turret_set_bars_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class Turret extends ReloadTurret{
    @Override
    public void setBars(){
        super.setBars();

        if(heatRequirement > 0){
            addBar("heat", (TurretBuild entity) ->
            new Bar(() ->
            Core.bundle.format("bar.heatpercent", (int)entity.heatReq, (int)(Math.min(entity.heatReq / heatRequirement, maxHeatEfficiency) * 100)),
            () -> Pal.lightOrange,
            () -> entity.heatReq / heatRequirement));
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setBars_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var heat_bar_added: bool = heat_requirement > 0.0", source_text)
            self.assertIn("var heat_bar_percent: int = 0", source_text)
            self.assertIn("heat_bar_percent = int(min(entity_heat_req / heat_requirement, max_heat_efficiency) * 100.0)", source_text)
            self.assertIn("heat_bar_fraction = entity_heat_req / heat_requirement", source_text)
            self.assertIn('"source_owner": "PortGame.source_turret_set_bars_state"', source_text)
            self.assertIn('"method": "public void setBars(){"', source_text)
            self.assertIn('"super_set_bars_expr": "super.setBars();"', source_text)
            self.assertIn('"heat_requirement_guard_expr": "if(heatRequirement > 0){"', source_text)
            self.assertIn('"add_bar_expr": "addBar(\\\"heat\\\", (TurretBuild entity) ->"', source_text)
            self.assertIn('"bar_text_format_expr": "Core.bundle.format(\\\"bar.heatpercent\\\", (int)entity.heatReq, (int)(Math.min(entity.heatReq / heatRequirement, maxHeatEfficiency) * 100))"', source_text)
            self.assertIn('"bar_progress_expr": "() -> entity.heatReq / heatRequirement"', source_text)

    def test_emit_bridges_continuous_turret_set_stats_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ContinuousTurret extends Turret{
    public BulletType shootType = Bullets.placeholder;

    @Override
    public void setStats(){
        super.setStats();

        stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));
        stats.remove(Stat.reload);
        stats.remove(Stat.inaccuracy);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setStats_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var shoot_type: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('var object_map_call: Dictionary = {"call": "ObjectMap.of(this, shootType)", "this": "ContinuousTurret", "shoot_type": shoot_type}', source_text)
            self.assertIn('"source_owner": "PortGame.source_continuous_turret_set_stats_state"', source_text)
            self.assertIn('"method": "public void setStats(){"', source_text)
            self.assertIn('"super_set_stats_expr": "super.setStats();"', source_text)
            self.assertIn('"stats_add_expr": "stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));"', source_text)
            self.assertIn('"remove_reload_expr": "stats.remove(Stat.reload);"', source_text)
            self.assertIn('"remove_inaccuracy_expr": "stats.remove(Stat.inaccuracy);"', source_text)

    def test_emit_bridges_turret_rotated_output_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class Turret extends ReloadTurret{
    @Override
    public boolean rotatedOutput(int x, int y){
        return false;
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_rotatedOutput_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var tile_x: int = int(_args[0] if _args.size() > 0 else 0)", source_text)
            self.assertIn("var tile_y: int = int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_turret_rotated_output_state"', source_text)
            self.assertIn('"method": "public boolean rotatedOutput(int x, int y){"', source_text)
            self.assertIn('"return_expr": "return false;"', source_text)
            self.assertIn('"rotated_output": false', source_text)

    def test_emit_bridges_turret_place_ended_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class Turret extends ReloadTurret{
    @Override
    public void placeEnded(Tile tile, @Nullable Unit builder, int rotation, @Nullable Object config){
        super.placeEnded(tile, builder, rotation, config);
        if(rotate && tile.build instanceof TurretBuild turret){
            turret.rotation = tile.build.rotdeg();
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "Turret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_placeEnded_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var tile: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var rotate: bool = bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("var tile_build_is_turret_build: bool = bool(_args[5] if _args.size() > 5 else false)", source_text)
            self.assertIn("var rotation_assigned: bool = rotate and tile_build_is_turret_build", source_text)
            self.assertIn("var turret_rotation_after: float = tile_build_rotdeg if rotation_assigned else turret_rotation", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_turret_place_ended_state"', source_text)
            self.assertIn('"method": "public void placeEnded(Tile tile, @Nullable Unit builder, int rotation, @Nullable Object config){"', source_text)
            self.assertIn('"super_place_ended_expr": "super.placeEnded(tile, builder, rotation, config);"', source_text)
            self.assertIn('"rotation_assign_expr": "turret.rotation = tile.build.rotdeg();"', source_text)

    def test_emit_bridges_reload_turret_set_stats_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            reload_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ReloadTurret.java"
            reload_turret_path.parent.mkdir(parents=True, exist_ok=True)
            reload_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ReloadTurret extends BaseTurret{
    @Override
    public void setStats(){
        super.setStats();

        if(coolant != null){
            stats.replace(Stat.booster, StatValues.boosters(reload, coolant.amount, coolantMultiplier, true, coolant::consumes));
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ReloadTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setStats_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var coolant_present: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var booster_replace_called: bool = coolant_present", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_reload_turret_set_stats_state"', source_text)
            self.assertIn('"method": "public void setStats(){"', source_text)
            self.assertIn('"super_set_stats_expr": "super.setStats();"', source_text)
            self.assertIn('"coolant_gate": "if(coolant != null){"', source_text)
            self.assertIn('"booster_replace_expr": "stats.replace(Stat.booster, StatValues.boosters(reload, coolant.amount, coolantMultiplier, true, coolant::consumes));"', source_text)

    def test_emit_bridges_power_turret_set_stats_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            power_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "PowerTurret.java"
            power_turret_path.parent.mkdir(parents=True, exist_ok=True)
            power_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class PowerTurret extends Turret{
    public BulletType shootType;

    @Override
    public void setStats(){
        super.setStats();
        stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "PowerTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setStats_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var shoot_type: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var object_map_call: Dictionary = {\"call\": \"ObjectMap.of(this, shootType)\", \"owner\": \"this\", \"shoot_type\": shoot_type}", source_text)
            self.assertIn("var stats_add_call: Dictionary = {\"call\": \"stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));\", \"stat\": \"Stat.ammo\", \"ammo_values_call\": ammo_values_call}", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_power_turret_set_stats_state"', source_text)
            self.assertIn('"method": "public void setStats(){"', source_text)
            self.assertIn('"super_set_stats_expr": "super.setStats();"', source_text)
            self.assertIn('"stats_add_expr": "stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));"', source_text)

    def test_emit_bridges_power_turret_limit_range_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            power_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "PowerTurret.java"
            power_turret_path.parent.mkdir(parents=True, exist_ok=True)
            power_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class PowerTurret extends Turret{
    public BulletType shootType;

    @Override
    public void setStats(){
        super.setStats();
        stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));
    }

    public void limitRange(float margin){
        limitRange(shootType, margin);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "PowerTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_limitRange_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var shoot_type: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var margin: float = float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var limit_range_call: Dictionary = {\"call\": \"limitRange(shootType, margin);\", \"shoot_type\": shoot_type, \"margin\": margin}", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_power_turret_limit_range_state"', source_text)
            self.assertIn('"method": "public void limitRange(float margin){"', source_text)
            self.assertIn('"dispatch_expr": "limitRange(shootType, margin);"', source_text)

    def test_emit_bridges_power_turret_build_get_ammo_fraction_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            power_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "PowerTurret.java"
            power_turret_path.parent.mkdir(parents=True, exist_ok=True)
            power_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class PowerTurret extends Turret{
    public class PowerTurretBuild extends TurretBuild{
        @Override
        public float getAmmoFraction(){
            return power == null ? 0f : power.status;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "PowerTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_PowerTurretBuild_method_getAmmoFraction_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var power_null: bool = bool(_args[0] if _args.size() > 0 else true)", source_text)
            self.assertIn("var power_status: float = float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var ammo_fraction: float = 0.0 if power_null else power_status", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_power_turret_build_get_ammo_fraction_state"', source_text)
            self.assertIn('"inner_class": "public class PowerTurretBuild extends TurretBuild{"', source_text)
            self.assertIn('"method": "public float getAmmoFraction(){"', source_text)
            self.assertIn('"return_expr": "return power == null ? 0f : power.status;"', source_text)

    def test_emit_bridges_power_turret_build_sense_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            power_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "PowerTurret.java"
            power_turret_path.parent.mkdir(parents=True, exist_ok=True)
            power_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class PowerTurret extends Turret{
    public class PowerTurretBuild extends TurretBuild{
        @Override
        public float getAmmoFraction(){
            return power == null ? 0f : power.status;
        }

        @Override
        public double sense(LAccess sensor){
            return switch(sensor){
                case ammo -> power == null ? 0f : power.status;
                case ammoCapacity -> 1;
                default -> super.sense(sensor);
            };
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "PowerTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_PowerTurretBuild_method_sense_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var sensor: String = str(_args[0] if _args.size() > 0 else \"\")", source_text)
            self.assertIn("var power_null: bool = bool(_args[1] if _args.size() > 1 else true)", source_text)
            self.assertIn("var power_status: float = float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var super_sense_value: float = float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn('if sensor == "ammo":', source_text)
            self.assertIn('elif sensor == "ammoCapacity":', source_text)
            self.assertIn("sense_value = super_sense_value", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_power_turret_build_sense_state"', source_text)
            self.assertIn('"method": "public double sense(LAccess sensor){"', source_text)
            self.assertIn('"ammo_case": "case ammo -> power == null ? 0f : power.status;"', source_text)
            self.assertIn('"default_case": "default -> super.sense(sensor);"', source_text)

    def test_emit_bridges_power_turret_build_use_ammo_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            power_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "PowerTurret.java"
            power_turret_path.parent.mkdir(parents=True, exist_ok=True)
            power_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class PowerTurret extends Turret{
    public BulletType shootType;
    public class PowerTurretBuild extends TurretBuild{
        @Override
        public float getAmmoFraction(){
            return power == null ? 0f : power.status;
        }

        @Override
        public double sense(LAccess sensor){
            return switch(sensor){
                case ammo -> power == null ? 0f : power.status;
                case ammoCapacity -> 1;
                default -> super.sense(sensor);
            };
        }

        @Override
        public BulletType useAmmo(){
            //nothing used directly
            return shootType;
        }

        @Override
        public boolean hasAmmo(){
            //you can always rotate, but never shoot if there's no power
            return true;
        }

        @Override
        public BulletType peekAmmo(){
            return shootType;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "PowerTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_PowerTurretBuild_method_useAmmo_2(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var shoot_type: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_power_turret_build_use_ammo_state"', source_text)
            self.assertIn('"method": "public BulletType useAmmo(){"', source_text)
            self.assertIn('"comment": "//nothing used directly"', source_text)
            self.assertIn('"return_expr": "return shootType;"', source_text)
            self.assertIn('"shoot_type": shoot_type', source_text)

    def test_emit_bridges_power_turret_build_has_ammo_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            power_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "PowerTurret.java"
            power_turret_path.parent.mkdir(parents=True, exist_ok=True)
            power_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class PowerTurret extends Turret{
    public class PowerTurretBuild extends TurretBuild{
        @Override
        public float getAmmoFraction(){
            return power == null ? 0f : power.status;
        }

        @Override
        public double sense(LAccess sensor){
            return switch(sensor){
                case ammo -> power == null ? 0f : power.status;
                case ammoCapacity -> 1;
                default -> super.sense(sensor);
            };
        }

        @Override
        public BulletType useAmmo(){
            //nothing used directly
            return shootType;
        }

        @Override
        public boolean hasAmmo(){
            //you can always rotate, but never shoot if there's no power
            return true;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "PowerTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_PowerTurretBuild_method_hasAmmo_3(_args: Array = []) -> Variant:", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_power_turret_build_has_ammo_state"', source_text)
            self.assertIn('"method": "public boolean hasAmmo(){"', source_text)
            self.assertIn('"comment": "//you can always rotate, but never shoot if there\'s no power"', source_text)
            self.assertIn('"return_expr": "return true;"', source_text)
            self.assertIn('"has_ammo": true', source_text)

    def test_emit_bridges_power_turret_build_peek_ammo_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            power_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "PowerTurret.java"
            power_turret_path.parent.mkdir(parents=True, exist_ok=True)
            power_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class PowerTurret extends Turret{
    public BulletType shootType;
    public class PowerTurretBuild extends TurretBuild{
        @Override
        public float getAmmoFraction(){
            return power == null ? 0f : power.status;
        }

        @Override
        public double sense(LAccess sensor){
            return switch(sensor){
                case ammo -> power == null ? 0f : power.status;
                case ammoCapacity -> 1;
                default -> super.sense(sensor);
            };
        }

        @Override
        public BulletType useAmmo(){
            //nothing used directly
            return shootType;
        }

        @Override
        public boolean hasAmmo(){
            //you can always rotate, but never shoot if there's no power
            return true;
        }

        @Override
        public BulletType peekAmmo(){
            return shootType;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "PowerTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_PowerTurretBuild_method_peekAmmo_4(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var shoot_type: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_power_turret_build_peek_ammo_state"', source_text)
            self.assertIn('"method": "public BulletType peekAmmo(){"', source_text)
            self.assertIn('"return_expr": "return shootType;"', source_text)
            self.assertIn('"shoot_type": shoot_type', source_text)

    def test_emit_bridges_item_turret_build_on_proximity_added_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public ObjectMap<Item, BulletType> ammoTypes = new OrderedMap<>();

    public class ItemTurretBuild extends TurretBuild{
        @Override
        public void onProximityAdded(){
            super.onProximityAdded();

            //add first ammo item to cheaty blocks so they can shoot properly
            if(!hasAmmo() && cheating() && ammoTypes.size > 0){
                handleItem(this, ammoTypes.keys().next());
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ItemTurretBuild_method_onProximityAdded_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var has_ammo: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var cheating: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var ammo_types_size: int = int(_args[2] if _args.size() > 2 else 0)", source_text)
            self.assertIn("var first_ammo_item: Variant = _args[3] if _args.size() > 3 else null", source_text)
            self.assertIn("var should_handle_first_ammo: bool = (not has_ammo) and cheating and ammo_types_size > 0", source_text)
            self.assertIn('if should_handle_first_ammo:', source_text)
            self.assertIn('var handle_item_call: Dictionary = {}', source_text)
            self.assertIn('handle_item_call = {"call": "handleItem(this, ammoTypes.keys().next());", "source": "this", "item": first_ammo_item}', source_text)
            self.assertIn('return {"source_owner": "PortGame.source_item_turret_build_on_proximity_added_state"', source_text)
            self.assertIn('"inner_class": "public class ItemTurretBuild extends TurretBuild{"', source_text)
            self.assertIn('"method": "public void onProximityAdded(){"', source_text)
            self.assertIn('"super_on_proximity_added_expr": "super.onProximityAdded();"', source_text)
            self.assertIn('"guard_expr": "if(!hasAmmo() && cheating() && ammoTypes.size > 0){"', source_text)
            self.assertIn('"handle_item_expr": "handleItem(this, ammoTypes.keys().next());"', source_text)

    def test_emit_bridges_item_turret_build_sense_object_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public class ItemTurretBuild extends TurretBuild{
        @Override
        public void onProximityAdded(){
            super.onProximityAdded();
        }

        @Override
        public Object senseObject(LAccess sensor){
            return switch(sensor){
                case currentAmmoType -> ammo.size > 0 ? ((ItemEntry)ammo.peek()).item : null;
                default -> super.senseObject(sensor);
            };
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ItemTurretBuild_method_senseObject_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var sensor: String = str(_args[0] if _args.size() > 0 else "")', source_text)
            self.assertIn("var ammo_size: int = int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("var peek_item: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("var super_sense_object_value: Variant = _args[3] if _args.size() > 3 else null", source_text)
            self.assertIn('if sensor == "currentAmmoType":', source_text)
            self.assertIn("sense_object_value = peek_item if ammo_size > 0 else null", source_text)
            self.assertIn("sense_object_value = super_sense_object_value", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_item_turret_build_sense_object_state"', source_text)
            self.assertIn('"method": "public Object senseObject(LAccess sensor){"', source_text)
            self.assertIn('"current_ammo_type_case": "case currentAmmoType -> ammo.size > 0 ? ((ItemEntry)ammo.peek()).item : null;"', source_text)
            self.assertIn('"default_case": "default -> super.senseObject(sensor);"', source_text)
            self.assertIn('"sense_object_value": sense_object_value', source_text)

    def test_emit_bridges_item_turret_build_get_ammo_content_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public class ItemTurretBuild extends TurretBuild{
        @Override
        public void onProximityAdded(){
            super.onProximityAdded();
        }

        @Override
        public Object senseObject(LAccess sensor){
            return null;
        }

        @Override
        public UnlockableContent getAmmoContent(){
            return ammo.size > 0 ? ((ItemEntry)ammo.peek()).item : null;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ItemTurretBuild_method_getAmmoContent_2(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var ammo_size: int = int(_args[0] if _args.size() > 0 else 0)", source_text)
            self.assertIn("var peek_item: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var ammo_content: Variant = peek_item if ammo_size > 0 else null", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_item_turret_build_get_ammo_content_state"', source_text)
            self.assertIn('"method": "public UnlockableContent getAmmoContent(){"', source_text)
            self.assertIn('"return_expr": "return ammo.size > 0 ? ((ItemEntry)ammo.peek()).item : null;"', source_text)
            self.assertIn('"ammo_content": ammo_content', source_text)

    def test_emit_bridges_item_turret_build_get_ammo_fraction_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public class ItemTurretBuild extends TurretBuild{
        @Override
        public void onProximityAdded(){
            super.onProximityAdded();
        }

        @Override
        public Object senseObject(LAccess sensor){
            return null;
        }

        @Override
        public UnlockableContent getAmmoContent(){
            return null;
        }

        @Override
        public float getAmmoFraction(){
            return (float)totalAmmo / maxAmmo;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ItemTurretBuild_method_getAmmoFraction_3(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var total_ammo: float = float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var max_ammo: float = float(_args[1] if _args.size() > 1 else 1.0)", source_text)
            self.assertIn("var ammo_fraction: float = total_ammo / max_ammo", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_item_turret_build_get_ammo_fraction_state"', source_text)
            self.assertIn('"method": "public float getAmmoFraction(){"', source_text)
            self.assertIn('"return_expr": "return (float)totalAmmo / maxAmmo;"', source_text)
            self.assertIn('"ammo_fraction": ammo_fraction', source_text)

    def test_emit_bridges_item_turret_build_accept_stack_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public class ItemTurretBuild extends TurretBuild{
        @Override
        public void onProximityAdded(){
            super.onProximityAdded();
        }

        @Override
        public Object senseObject(LAccess sensor){
            return null;
        }

        @Override
        public UnlockableContent getAmmoContent(){
            return null;
        }

        @Override
        public float getAmmoFraction(){
            return (float)totalAmmo / maxAmmo;
        }

        @Override
        public int acceptStack(Item item, int amount, Teamc source){
            BulletType type = ammoTypes.get(item);

            if(type == null) return 0;

            return Math.min((int)((maxAmmo - totalAmmo) / ammoTypes.get(item).ammoMultiplier), amount);
        }

        @Override
        public void handleStack(Item item, int amount, Teamc source){
            for(int i = 0; i < amount; i++){
                handleItem(null, item);
            }
        }

        //currently can't remove items from turrets.
        @Override
        public int removeStack(Item item, int amount){
            return 0;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ItemTurretBuild_method_acceptStack_4(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var item: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var amount: int = int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("var max_ammo: float = float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var total_ammo: float = float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var ammo_multiplier: float = float(_args[4] if _args.size() > 4 else 1.0)", source_text)
            self.assertIn("var ammo_type_null: bool = bool(_args[5] if _args.size() > 5 else false)", source_text)
            self.assertIn("var accept_stack: int = 0 if ammo_type_null else min(int((max_ammo - total_ammo) / ammo_multiplier), amount)", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_item_turret_build_accept_stack_state"', source_text)
            self.assertIn('"method": "public int acceptStack(Item item, int amount, Teamc source){"', source_text)
            self.assertIn('"return_expr": "return Math.min((int)((maxAmmo - totalAmmo) / ammoTypes.get(item).ammoMultiplier), amount);"', source_text)
            self.assertIn('"accept_stack": accept_stack', source_text)

    def test_emit_bridges_item_turret_build_handle_stack_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public class ItemTurretBuild extends TurretBuild{
        @Override
        public void onProximityAdded(){
            super.onProximityAdded();
        }

        @Override
        public Object senseObject(LAccess sensor){
            return null;
        }

        @Override
        public UnlockableContent getAmmoContent(){
            return null;
        }

        @Override
        public float getAmmoFraction(){
            return (float)totalAmmo / maxAmmo;
        }

        @Override
        public int acceptStack(Item item, int amount, Teamc source){
            return 0;
        }

        @Override
        public void handleStack(Item item, int amount, Teamc source){
            for(int i = 0; i < amount; i++){
                handleItem(null, item);
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ItemTurretBuild_method_handleStack_5(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var item: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var amount: int = int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("var handle_item_calls: Array = []", source_text)
            self.assertIn("for _i in range(amount):", source_text)
            self.assertIn('handle_item_calls.append({"call": "handleItem(null, item);", "source": null, "item": item})', source_text)
            self.assertIn('return {"source_owner": "PortGame.source_item_turret_build_handle_stack_state"', source_text)
            self.assertIn('"method": "public void handleStack(Item item, int amount, Teamc source){"', source_text)
            self.assertIn('"loop_expr": "for(int i = 0; i < amount; i++){"', source_text)
            self.assertIn('"handle_item_expr": "handleItem(null, item);"', source_text)
            self.assertIn('"handle_item_call_count": handle_item_calls.size()', source_text)

    def test_emit_bridges_item_turret_build_remove_stack_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public class ItemTurretBuild extends TurretBuild{
        @Override
        public void onProximityAdded(){
            super.onProximityAdded();
        }

        @Override
        public Object senseObject(LAccess sensor){
            return null;
        }

        @Override
        public UnlockableContent getAmmoContent(){
            return null;
        }

        @Override
        public float getAmmoFraction(){
            return (float)totalAmmo / maxAmmo;
        }

        @Override
        public int acceptStack(Item item, int amount, Teamc source){
            return 0;
        }

        @Override
        public void handleStack(Item item, int amount, Teamc source){
        }

        //currently can't remove items from turrets.
        @Override
        public int removeStack(Item item, int amount){
            return 0;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ItemTurretBuild_method_removeStack_6(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var item: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var amount: int = int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("var removed_stack: int = 0", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_item_turret_build_remove_stack_state"', source_text)
            self.assertIn('"comment": "//currently can\'t remove items from turrets."', source_text)
            self.assertIn('"method": "public int removeStack(Item item, int amount){"', source_text)
            self.assertIn('"return_expr": "return 0;"', source_text)
            self.assertIn('"removed_stack": removed_stack', source_text)

    def test_emit_bridges_item_turret_build_handle_item_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public class ItemTurretBuild extends TurretBuild{
        @Override
        public void onProximityAdded(){ }
        @Override
        public Object senseObject(LAccess sensor){ return null; }
        @Override
        public UnlockableContent getAmmoContent(){ return null; }
        @Override
        public float getAmmoFraction(){ return 0f; }
        @Override
        public int acceptStack(Item item, int amount, Teamc source){ return 0; }
        @Override
        public void handleStack(Item item, int amount, Teamc source){ }
        @Override
        public int removeStack(Item item, int amount){ return 0; }

        @Override
        public void handleItem(Building source, Item item){
            //TODO instead of all this "entry" crap, turrets could just accept only one type of ammo at a time - simpler for both users and the code

            if(item == Items.pyratite){
                Events.fire(Trigger.flameAmmo);
            }

            if(totalAmmo == 0){
                Events.fire(Trigger.resupplyTurret);
            }

            BulletType type = ammoTypes.get(item);
            if(type == null) return;
            totalAmmo += type.ammoMultiplier;

            //find ammo entry by type
            for(int i = 0; i < ammo.size; i++){
                ItemEntry entry = (ItemEntry)ammo.get(i);

                //if found, put it to the right
                if(entry.item == item){
                    entry.amount += type.ammoMultiplier;
                    ammo.swap(i, ammo.size - 1);
                    return;
                }
            }

            //must not be found
            ammo.add(new ItemEntry(item, (int)type.ammoMultiplier));
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ItemTurretBuild_method_handleItem_7(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var item: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var item_is_pyratite: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var total_ammo: int = int(_args[2] if _args.size() > 2 else 0)", source_text)
            self.assertIn("var ammo_multiplier: float = float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var ammo_type_null: bool = bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("var ammo_entries_after: Array = ammo_entries.duplicate(true)", source_text)
            self.assertIn("var flame_ammo_event_fired: bool = item_is_pyratite", source_text)
            self.assertIn("var resupply_turret_event_fired: bool = total_ammo == 0", source_text)
            self.assertIn("total_ammo_after = int(total_ammo + ammo_multiplier)", source_text)
            self.assertIn("entry_copy[\"amount\"] = int(entry_copy.get(\"amount\", 0)) + int(ammo_multiplier)", source_text)
            self.assertIn("ammo_entries_after.append({\"item\": item, \"amount\": int(ammo_multiplier)})", source_text)
            self.assertIn('"method": "public void handleItem(Building source, Item item){"', source_text)
            self.assertIn('"type_null_guard": "if(type == null) return;"', source_text)
            self.assertIn('"add_expr": "ammo.add(new ItemEntry(item, (int)type.ammoMultiplier));"', source_text)

    def test_emit_bridges_item_turret_build_accept_item_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public class ItemTurretBuild extends TurretBuild{
        @Override
        public void onProximityAdded(){ }
        @Override
        public Object senseObject(LAccess sensor){ return null; }
        @Override
        public UnlockableContent getAmmoContent(){ return null; }
        @Override
        public float getAmmoFraction(){ return 0f; }
        @Override
        public int acceptStack(Item item, int amount, Teamc source){ return 0; }
        @Override
        public void handleStack(Item item, int amount, Teamc source){ }
        @Override
        public int removeStack(Item item, int amount){ return 0; }
        @Override
        public void handleItem(Building source, Item item){ }

        @Override
        public boolean acceptItem(Building source, Item item){
            return ammoTypes.get(item) != null && totalAmmo + ammoTypes.get(item).ammoMultiplier <= maxAmmo;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ItemTurretBuild_method_acceptItem_8(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var item: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var total_ammo: int = int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("var max_ammo: float = float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var ammo_multiplier: float = float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var ammo_type_null: bool = bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("var accept_item: bool = not ammo_type_null and total_ammo + ammo_multiplier <= max_ammo", source_text)
            self.assertIn('"method": "public boolean acceptItem(Building source, Item item){"', source_text)
            self.assertIn('"return_expr": "return ammoTypes.get(item) != null && totalAmmo + ammoTypes.get(item).ammoMultiplier <= maxAmmo;"', source_text)
            self.assertIn('"accept_item": accept_item', source_text)

    def test_emit_bridges_item_turret_build_version_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public class ItemTurretBuild extends TurretBuild{
        @Override
        public void onProximityAdded(){ }
        @Override
        public Object senseObject(LAccess sensor){ return null; }
        @Override
        public UnlockableContent getAmmoContent(){ return null; }
        @Override
        public float getAmmoFraction(){ return 0f; }
        @Override
        public int acceptStack(Item item, int amount, Teamc source){ return 0; }
        @Override
        public void handleStack(Item item, int amount, Teamc source){ }
        @Override
        public int removeStack(Item item, int amount){ return 0; }
        @Override
        public void handleItem(Building source, Item item){ }
        @Override
        public boolean acceptItem(Building source, Item item){ return false; }

        @Override
        public byte version(){
            return 2;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ItemTurretBuild_method_version_9(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var version_value: int = 2", source_text)
            self.assertIn('"method": "public byte version(){"', source_text)
            self.assertIn('"return_expr": "return 2;"', source_text)
            self.assertIn('"version": version_value', source_text)

    def test_emit_bridges_item_turret_build_write_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public class ItemTurretBuild extends TurretBuild{
        @Override
        public void onProximityAdded(){ }
        @Override
        public Object senseObject(LAccess sensor){ return null; }
        @Override
        public UnlockableContent getAmmoContent(){ return null; }
        @Override
        public float getAmmoFraction(){ return 0f; }
        @Override
        public int acceptStack(Item item, int amount, Teamc source){ return 0; }
        @Override
        public void handleStack(Item item, int amount, Teamc source){ }
        @Override
        public int removeStack(Item item, int amount){ return 0; }
        @Override
        public void handleItem(Building source, Item item){ }
        @Override
        public boolean acceptItem(Building source, Item item){ return false; }
        @Override
        public byte version(){ return 2; }

        @Override
        public void write(Writes write){
            super.write(write);
            write.b(ammo.size);
            for(AmmoEntry entry : ammo){
                ItemEntry i = (ItemEntry)entry;
                write.s(i.item.id);
                write.s(i.amount);
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ItemTurretBuild_method_write_10(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var ammo_entries: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []", source_text)
            self.assertIn('write_calls.append({"call": "super.write(write);"})', source_text)
            self.assertIn('write_calls.append({"call": "write.b(ammo.size);", "value": ammo_entries.size()})', source_text)
            self.assertIn('entry_writes.append({"item_id": int(entry_copy.get("item_id", 0)), "amount": int(entry_copy.get("amount", 0))})', source_text)
            self.assertIn('"method": "public void write(Writes write){"', source_text)
            self.assertIn('"write_item_id_expr": "write.s(i.item.id);"', source_text)
            self.assertIn('"write_amount_expr": "write.s(i.amount);"', source_text)

    def test_emit_bridges_item_turret_build_read_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public class ItemTurretBuild extends TurretBuild{
        @Override
        public void onProximityAdded(){ }
        @Override
        public Object senseObject(LAccess sensor){ return null; }
        @Override
        public UnlockableContent getAmmoContent(){ return null; }
        @Override
        public float getAmmoFraction(){ return 0f; }
        @Override
        public int acceptStack(Item item, int amount, Teamc source){ return 0; }
        @Override
        public void handleStack(Item item, int amount, Teamc source){ }
        @Override
        public int removeStack(Item item, int amount){ return 0; }
        @Override
        public void handleItem(Building source, Item item){ }
        @Override
        public boolean acceptItem(Building source, Item item){ return false; }
        @Override
        public byte version(){ return 2; }
        @Override
        public void write(Writes write){ }

        @Override
        public void read(Reads read, byte revision){
            super.read(read, revision);
            ammo.clear();
            totalAmmo = 0;
            int amount = read.ub();
            for(int i = 0; i < amount; i++){
                Item item = Vars.content.item(revision < 2 ? read.ub() : read.s());
                int itemAmount = Math.min(read.s(), maxAmmo);

                //only add ammo if this is a valid ammo type
                if(item != null && ammoTypes.containsKey(item)){
                    totalAmmo += itemAmount;
                    ammo.add(new ItemEntry(item, itemAmount));
                }
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ItemTurretBuild_method_read_11(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var revision: int = int(_args[0] if _args.size() > 0 else 0)", source_text)
            self.assertIn("var max_ammo: int = int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn("var read_entries: Array = _args[2] if _args.size() > 2 and _args[2] is Array else []", source_text)
            self.assertIn('read_calls.append({"call": "super.read(read, revision);", "revision": revision})', source_text)
            self.assertIn('read_calls.append({"call": "ammo.clear();"})', source_text)
            self.assertIn('read_calls.append({"call": "totalAmmo = 0;", "value": 0})', source_text)
            self.assertIn('read_calls.append({"call": "read.ub();", "target": "amount", "value": read_entries.size()})', source_text)
            self.assertIn('var item_read_call: String = "read.ub();" if revision < 2 else "read.s();"', source_text)
            self.assertIn('var item_amount: int = min(int(entry_copy.get("amount", 0)), max_ammo)', source_text)
            self.assertIn('ammo_entries_after.append({"item": item, "amount": item_amount})', source_text)
            self.assertIn('"method": "public void read(Reads read, byte revision){"', source_text)
            self.assertIn('"item_lookup_expr": "Item item = Vars.content.item(revision < 2 ? read.ub() : read.s());"', source_text)
            self.assertIn('"valid_ammo_guard": "if(item != null && ammoTypes.containsKey(item)){"', source_text)

    def test_emit_bridges_item_entry_constructor_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public class ItemTurretBuild extends TurretBuild{
        @Override
        public void onProximityAdded(){ }
    }

    public class ItemEntry extends AmmoEntry{
        public Item item;

        ItemEntry(Item item, int amount){
            this.item = item;
            this.amount = amount;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ItemEntry_constructor_ItemEntry_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var item: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var amount: int = int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn('"inner_class": "public class ItemEntry extends AmmoEntry{"', source_text)
            self.assertIn('"field": "public Item item;"', source_text)
            self.assertIn('"constructor": "ItemEntry(Item item, int amount){"', source_text)
            self.assertIn('"item_assign_expr": "this.item = item;"', source_text)
            self.assertIn('"amount_assign_expr": "this.amount = amount;"', source_text)
            self.assertIn('"item_after": item', source_text)
            self.assertIn('"amount_after": amount', source_text)

    def test_emit_bridges_item_entry_type_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public class ItemEntry extends AmmoEntry{
        public Item item;

        @Override
        public BulletType type(){
            return ammoTypes.get(item);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ItemEntry_method_type_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var item: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var ammo_type: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_item_entry_type_state"', source_text)
            self.assertIn('"inner_class": "public class ItemEntry extends AmmoEntry{"', source_text)
            self.assertIn('"override_expr": "@Override"', source_text)
            self.assertIn('"method": "public BulletType type(){"', source_text)
            self.assertIn('"return_expr": "return ammoTypes.get(item);"', source_text)
            self.assertIn('"type": ammo_type', source_text)

    def test_emit_bridges_item_entry_to_string_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public class ItemEntry extends AmmoEntry{
        public Item item;

        @Override
        public BulletType type(){
            return ammoTypes.get(item);
        }

        @Override
        public String toString(){
            return "ItemEntry{" +
            "item=" + item +
            ", amount=" + amount +
            '}';
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ItemEntry_method_toString_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var item_string: String = str(_args[0] if _args.size() > 0 else "null")', source_text)
            self.assertIn("var amount: int = int(_args[1] if _args.size() > 1 else 0)", source_text)
            self.assertIn('var to_string_value: String = "ItemEntry{item=" + item_string + ", amount=" + str(amount) + "}"', source_text)
            self.assertNotIn("var to_string: String", source_text)
            self.assertIn('"source_owner": "PortGame.source_item_entry_to_string_state"', source_text)
            self.assertIn('"method": "public String toString(){"', source_text)
            self.assertIn('"return_start_expr": "return \\"ItemEntry{\\" +"', source_text)
            self.assertIn('"item_concat_expr": "\\"item=\\" + item +"', source_text)
            self.assertIn('"amount_concat_expr": "\\", amount=\\" + amount +"', source_text)
            self.assertIn('"return_end_expr": "\'}\';"', source_text)
            self.assertIn('"to_string": to_string_value', source_text)

    def test_emit_bridges_liquid_turret_ammo_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            liquid_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.java"
            liquid_turret_path.parent.mkdir(parents=True, exist_ok=True)
            liquid_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class LiquidTurret extends Turret{
    public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();

    /** Initializes accepted ammo map. Format: [liquid1, bullet1, liquid2, bullet2...] */
    public void ammo(Object... objects){
        ammoTypes = ObjectMap.of(objects);
    }

    @Override
    public void setStats(){
        super.setStats();

        stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_ammo_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var objects: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []", source_text)
            self.assertIn('"source_owner": "PortGame.source_liquid_turret_ammo_state"', source_text)
            self.assertIn('"field": "public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();"', source_text)
            self.assertIn('"comment": "/** Initializes accepted ammo map. Format: [liquid1, bullet1, liquid2, bullet2...] */"', source_text)
            self.assertIn('"method": "public void ammo(Object... objects){"', source_text)
            self.assertIn('"assignment_expr": "ammoTypes = ObjectMap.of(objects);"', source_text)
            self.assertIn('"objects": objects', source_text)
            self.assertIn('"ammo_types_after": objects', source_text)

    def test_emit_bridges_item_turret_ammo_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public ObjectMap<Item, BulletType> ammoTypes = new OrderedMap<>();

    /** Initializes accepted ammo map. Format: [item1, bullet1, item2, bullet2...] */
    public void ammo(Object... objects){
        ammoTypes = OrderedMap.of(objects);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_ammo_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var objects: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []", source_text)
            self.assertIn('"source_owner": "PortGame.source_item_turret_ammo_state"', source_text)
            self.assertIn('"field": "public ObjectMap<Item, BulletType> ammoTypes = new OrderedMap<>();"', source_text)
            self.assertIn('"comment": "/** Initializes accepted ammo map. Format: [item1, bullet1, item2, bullet2...] */"', source_text)
            self.assertIn('"method": "public void ammo(Object... objects){"', source_text)
            self.assertIn('"assignment_expr": "ammoTypes = OrderedMap.of(objects);"', source_text)
            self.assertIn('"objects": objects', source_text)
            self.assertIn('"ammo_types_after": objects', source_text)

    def test_emit_bridges_continuous_liquid_turret_ammo_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

import mindustry.entities.bullet.*;

public class ContinuousLiquidTurret extends ContinuousTurret{
    public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();

    /** Initializes accepted ammo map. Format: [liquid1, bullet1, liquid2, bullet2...] */
    public void ammo(Object... objects){
        ammoTypes = ObjectMap.of(objects);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_ammo_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var objects: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []", source_text)
            self.assertIn('"source_owner": "PortGame.source_continuous_liquid_turret_ammo_state"', source_text)
            self.assertIn('"field": "public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();"', source_text)
            self.assertIn('"comment": "/** Initializes accepted ammo map. Format: [liquid1, bullet1, liquid2, bullet2...] */"', source_text)
            self.assertIn('"method": "public void ammo(Object... objects){"', source_text)
            self.assertIn('"assignment_expr": "ammoTypes = ObjectMap.of(objects);"', source_text)
            self.assertIn('"objects": objects', source_text)
            self.assertIn('"ammo_types_after": objects', source_text)

    def test_emit_bridges_continuous_liquid_turret_set_stats_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

import mindustry.entities.bullet.*;

public class ContinuousLiquidTurret extends ContinuousTurret{
    public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();
    public float liquidConsumed = 1f / 60f;

    public void ammo(Object... objects){
        ammoTypes = ObjectMap.of(objects);
    }

    @Override
    public void setStats(){
        super.setStats();
        //mirror stats onto each bullet (purely visual)
        ammoTypes.each((l, b) -> b.statLiquidConsumed = liquidConsumed);

        stats.replace(Stat.ammo, StatValues.ammo(ammoTypes));
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setStats_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var ammo_types: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []", source_text)
            self.assertIn("var liquid_consumed: float = float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn('"source_owner": "PortGame.source_continuous_liquid_turret_set_stats_state"', source_text)
            self.assertIn('"method": "public void setStats(){"', source_text)
            self.assertIn('"override_expr": "@Override"', source_text)
            self.assertIn('"super_set_stats_expr": "super.setStats();"', source_text)
            self.assertIn('"mirror_comment": "//mirror stats onto each bullet (purely visual)"', source_text)
            self.assertIn('"stat_liquid_consumed_expr": "ammoTypes.each((l, b) -> b.statLiquidConsumed = liquidConsumed);"', source_text)
            self.assertIn('"stats_replace_expr": "stats.replace(Stat.ammo, StatValues.ammo(ammoTypes));"', source_text)
            self.assertIn('"stat_liquid_consumed_updates": stat_liquid_consumed_updates', source_text)
            self.assertIn('"stats_replace_call": stats_replace_call', source_text)

    def test_emit_bridges_liquid_turret_set_stats_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            liquid_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.java"
            liquid_turret_path.parent.mkdir(parents=True, exist_ok=True)
            liquid_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class LiquidTurret extends Turret{
    public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();

    /** Initializes accepted ammo map. Format: [liquid1, bullet1, liquid2, bullet2...] */
    public void ammo(Object... objects){
        ammoTypes = ObjectMap.of(objects);
    }

    @Override
    public void setStats(){
        super.setStats();

        stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setStats_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var ammo_types: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('var name_value: String = str(_args[1] if _args.size() > 1 else "")', source_text)
            self.assertIn('"source_owner": "PortGame.source_liquid_turret_set_stats_state"', source_text)
            self.assertIn('"method": "public void setStats(){"', source_text)
            self.assertIn('"override_expr": "@Override"', source_text)
            self.assertIn('"super_set_stats_expr": "super.setStats();"', source_text)
            self.assertIn('"stats_add_expr": "stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));"', source_text)
            self.assertIn('"ammo_types": ammo_types', source_text)
            self.assertIn('"name_value": name_value', source_text)
            self.assertIn('"stats_added": true', source_text)

    def test_emit_bridges_liquid_turret_init_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            liquid_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.java"
            liquid_turret_path.parent.mkdir(parents=True, exist_ok=True)
            liquid_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class LiquidTurret extends Turret{
    public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();

    /** Initializes accepted ammo map. Format: [liquid1, bullet1, liquid2, bullet2...] */
    public void ammo(Object... objects){
        ammoTypes = ObjectMap.of(objects);
    }

    @Override
    public void setStats(){
        super.setStats();

        stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));
    }

    @Override
    public void init(){
        consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), 1f){

            @Override
            public void update(Building build){

            }

            @Override
            public void display(Stats stats){

            }
        });

        if(targetGround){
            ammoTypes.each((item, type) -> placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin));
        }

        super.init();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_init_2(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var ammo_entries: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []", source_text)
            self.assertIn("var target_ground: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn('"source_owner": "PortGame.source_liquid_turret_init_state"', source_text)
            self.assertIn('"method": "public void init(){"', source_text)
            self.assertIn('"consume_expr": "consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), 1f){"', source_text)
            self.assertIn('"filter_expr": "i -> ammoTypes.containsKey(i)"', source_text)
            self.assertIn('"target_ground_expr": "if(targetGround){"', source_text)
            self.assertIn('"overlap_expr": "ammoTypes.each((item, type) -> placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin));"', source_text)
            self.assertIn('"super_init_expr": "super.init();"', source_text)
            self.assertIn('"super_init_called": true', source_text)

    def test_emit_bridges_continuous_liquid_turret_init_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ContinuousLiquidTurret extends ContinuousTurret{
    public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();
    public float liquidConsumed = 1f / 60f;

    @Override
    public void init(){
        consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), liquidConsumed){

            {
                multiplier = b -> {
                    var ammo = ammoTypes.get(b.liquids.current());
                    return ammo == null ? 1f : 1f / ammo.ammoMultiplier;
                };
            }

            @Override
            public void display(Stats stats){

            }
        });

        if(targetGround){
            ammoTypes.each((item, type) -> placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin));
        }

        super.init();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_init_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var ammo_entries: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []", source_text)
            self.assertIn("var liquid_consumed: float = float(_args[5] if _args.size() > 5 else 0.0)", source_text)
            self.assertIn('"source_owner": "PortGame.source_continuous_liquid_turret_init_state"', source_text)
            self.assertIn('"consume_expr": "consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), liquidConsumed){"', source_text)
            self.assertIn('"multiplier_expr": "multiplier = b -> {"', source_text)
            self.assertIn('"ammo_lookup_expr": "var ammo = ammoTypes.get(b.liquids.current());"', source_text)
            self.assertIn('"multiplier_return_expr": "return ammo == null ? 1f : 1f / ammo.ammoMultiplier;"', source_text)
            self.assertIn('"display_override_noop": true', source_text)
            self.assertIn('"overlap_expr": "ammoTypes.each((item, type) -> placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin));"', source_text)
            self.assertIn('"super_init_called": true', source_text)

    def test_emit_bridges_liquid_turret_build_should_active_sound_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            liquid_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.java"
            liquid_turret_path.parent.mkdir(parents=True, exist_ok=True)
            liquid_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class LiquidTurret extends Turret{
    public class LiquidTurretBuild extends TurretBuild{

        @Override
        public boolean shouldActiveSound(){
            return wasShooting && enabled;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_LiquidTurretBuild_method_shouldActiveSound_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var was_shooting: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var enabled: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn('"source_owner": "PortGame.source_liquid_turret_build_should_active_sound_state"', source_text)
            self.assertIn('"inner_class": "public class LiquidTurretBuild extends TurretBuild{"', source_text)
            self.assertIn('"method": "public boolean shouldActiveSound(){"', source_text)
            self.assertIn('"return_expr": "return wasShooting && enabled;"', source_text)
            self.assertIn('"should_active_sound": was_shooting and enabled', source_text)

    def test_emit_bridges_continuous_liquid_turret_build_should_active_sound_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ContinuousLiquidTurret extends ContinuousTurret{
    public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{
        boolean activated;

        @Override
        public boolean shouldActiveSound(){
            return wasShooting && enabled;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ContinuousLiquidTurretBuild_method_shouldActiveSound_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var was_shooting: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var enabled: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn('"source_owner": "PortGame.source_continuous_liquid_turret_build_should_active_sound_state"', source_text)
            self.assertIn('"inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{"', source_text)
            self.assertIn('"method": "public boolean shouldActiveSound(){"', source_text)
            self.assertIn('"return_expr": "return wasShooting && enabled;"', source_text)
            self.assertIn('"should_active_sound": was_shooting and enabled', source_text)

    def test_emit_bridges_continuous_liquid_turret_build_get_ammo_content_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ContinuousLiquidTurret extends ContinuousTurret{
    public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{
        boolean activated;

        @Override
        public boolean shouldActiveSound(){
            return wasShooting && enabled;
        }

        @Override
        public UnlockableContent getAmmoContent(){
            return liquids != null && liquids.currentAmount() > 0f ? liquids.current() : null;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ContinuousLiquidTurretBuild_method_getAmmoContent_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var liquids_null: bool = bool(_args[0] if _args.size() > 0 else true)", source_text)
            self.assertIn("var current_amount: float = float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var current_liquid: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("var ammo_content: Variant = current_liquid if not liquids_null and current_amount > 0.0 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_continuous_liquid_turret_build_get_ammo_content_state"', source_text)
            self.assertIn('"inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{"', source_text)
            self.assertIn('"method": "public UnlockableContent getAmmoContent(){"', source_text)
            self.assertIn('"return_expr": "return liquids != null && liquids.currentAmount() > 0f ? liquids.current() : null;"', source_text)
            self.assertIn('"ammo_content": ammo_content', source_text)

    def test_emit_bridges_continuous_liquid_turret_build_get_ammo_fraction_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ContinuousLiquidTurret extends ContinuousTurret{
    public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{
        boolean activated;

        @Override
        public boolean shouldActiveSound(){
            return wasShooting && enabled;
        }

        @Override
        public UnlockableContent getAmmoContent(){
            return liquids != null && liquids.currentAmount() > 0f ? liquids.current() : null;
        }

        @Override
        public float getAmmoFraction(){
            return liquids.currentAmount() / liquidCapacity;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ContinuousLiquidTurretBuild_method_getAmmoFraction_2(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var current_amount: float = float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var liquid_capacity: float = float(_args[1] if _args.size() > 1 else 1.0)", source_text)
            self.assertIn("var ammo_fraction: float = current_amount / liquid_capacity", source_text)
            self.assertIn('"source_owner": "PortGame.source_continuous_liquid_turret_build_get_ammo_fraction_state"', source_text)
            self.assertIn('"inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{"', source_text)
            self.assertIn('"method": "public float getAmmoFraction(){"', source_text)
            self.assertIn('"return_expr": "return liquids.currentAmount() / liquidCapacity;"', source_text)
            self.assertIn('"ammo_fraction": ammo_fraction', source_text)

    def test_emit_bridges_continuous_liquid_turret_build_update_tile_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ContinuousLiquidTurret extends ContinuousTurret{
    public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{
        boolean activated;

        @Override
        public void updateTile(){
            super.updateTile();

            //only allow the turret to begin firing when it can fire for 4 continuous updates
            if(liquids.currentAmount() >= liquidConsumed * 4f){
                activated = true;
            }else if(liquids.currentAmount() < liquidConsumed){
                activated = false;
            }
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ContinuousLiquidTurretBuild_method_updateTile_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var current_amount: float = float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var liquid_consumed: float = float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var activated_before: bool = bool(_args[2] if _args.size() > 2 else false)", source_text)
            self.assertIn("var activate_threshold: float = liquid_consumed * 4.0", source_text)
            self.assertIn("if current_amount >= activate_threshold:", source_text)
            self.assertIn("elif current_amount < liquid_consumed:", source_text)
            self.assertIn('"source_owner": "PortGame.source_continuous_liquid_turret_build_update_tile_state"', source_text)
            self.assertIn('"method": "public void updateTile(){"', source_text)
            self.assertIn('"comment": "//only allow the turret to begin firing when it can fire for 4 continuous updates"', source_text)
            self.assertIn('"activated_after": activated_after', source_text)

    def test_emit_bridges_continuous_liquid_turret_build_sense_object_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ContinuousLiquidTurret extends ContinuousTurret{
    public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{
        boolean activated;

        @Override
        public Object senseObject(LAccess sensor){
            return switch(sensor){
                case currentAmmoType -> liquids.current();
                default -> super.senseObject(sensor);
            };
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ContinuousLiquidTurretBuild_method_senseObject_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var sensor: String = str(_args[0] if _args.size() > 0 else "")', source_text)
            self.assertIn("var current_liquid: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var super_sense_object_value: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn('if sensor == "currentAmmoType":', source_text)
            self.assertIn("sense_object_value = current_liquid", source_text)
            self.assertIn("sense_object_value = super_sense_object_value", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_continuous_liquid_turret_build_sense_object_state"', source_text)
            self.assertIn('"inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{"', source_text)
            self.assertIn('"field": "boolean activated;"', source_text)
            self.assertIn('"method": "public Object senseObject(LAccess sensor){"', source_text)
            self.assertIn('"current_ammo_type_case": "case currentAmmoType -> liquids.current();"', source_text)
            self.assertIn('"default_case": "default -> super.senseObject(sensor);"', source_text)
            self.assertIn('"sense_object_value": sense_object_value', source_text)

    def test_emit_bridges_continuous_liquid_turret_build_can_consume_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ContinuousLiquidTurret extends ContinuousTurret{
    public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{
        boolean activated;

        @Override
        public boolean canConsume(){
            return hasCorrectAmmo() && super.canConsume();
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ContinuousLiquidTurretBuild_method_canConsume_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var has_correct_ammo: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var super_can_consume: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var can_consume: bool = has_correct_ammo and super_can_consume", source_text)
            self.assertIn('"source_owner": "PortGame.source_continuous_liquid_turret_build_can_consume_state"', source_text)
            self.assertIn('"inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{"', source_text)
            self.assertIn('"field": "boolean activated;"', source_text)
            self.assertIn('"method": "public boolean canConsume(){"', source_text)
            self.assertIn('"return_expr": "return hasCorrectAmmo() && super.canConsume();"', source_text)
            self.assertIn('"can_consume": can_consume', source_text)

    def test_emit_bridges_continuous_liquid_turret_build_should_consume_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ContinuousLiquidTurret extends ContinuousTurret{
    public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{
        boolean activated;

        @Override
        public boolean shouldConsume(){
            return super.shouldConsume() && activated;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ContinuousLiquidTurretBuild_method_shouldConsume_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var super_should_consume: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var activated: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var should_consume: bool = super_should_consume and activated", source_text)
            self.assertIn('"source_owner": "PortGame.source_continuous_liquid_turret_build_should_consume_state"', source_text)
            self.assertIn('"inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{"', source_text)
            self.assertIn('"field": "boolean activated;"', source_text)
            self.assertIn('"method": "public boolean shouldConsume(){"', source_text)
            self.assertIn('"return_expr": "return super.shouldConsume() && activated;"', source_text)
            self.assertIn('"should_consume": should_consume', source_text)

    def test_emit_bridges_continuous_liquid_turret_build_use_ammo_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

import mindustry.entities.bullet.*;

public class ContinuousLiquidTurret extends ContinuousTurret{
    public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{
        boolean activated;

        @Override
        public BulletType useAmmo(){
            //does not consume ammo upon firing
            return peekAmmo();
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ContinuousLiquidTurretBuild_method_useAmmo_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var peek_ammo: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var returned_ammo: Variant = peek_ammo", source_text)
            self.assertIn('"source_owner": "PortGame.source_continuous_liquid_turret_build_use_ammo_state"', source_text)
            self.assertIn('"inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{"', source_text)
            self.assertIn('"field": "boolean activated;"', source_text)
            self.assertIn('"method": "public BulletType useAmmo(){"', source_text)
            self.assertIn('"comment": "//does not consume ammo upon firing"', source_text)
            self.assertIn('"return_expr": "return peekAmmo();"', source_text)
            self.assertIn('"peek_ammo": peek_ammo', source_text)
            self.assertIn('"returned_ammo": returned_ammo', source_text)

    def test_emit_bridges_continuous_liquid_turret_build_peek_ammo_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

import mindustry.entities.bullet.*;

public class ContinuousLiquidTurret extends ContinuousTurret{
    public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{
        boolean activated;

        @Override
        public BulletType peekAmmo(){
            return ammoTypes.get(liquids.current());
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ContinuousLiquidTurretBuild_method_peekAmmo_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var current_liquid: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var ammo_type: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_continuous_liquid_turret_build_peek_ammo_state"', source_text)
            self.assertIn('"inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{"', source_text)
            self.assertIn('"field": "boolean activated;"', source_text)
            self.assertIn('"method": "public BulletType peekAmmo(){"', source_text)
            self.assertIn('"return_expr": "return ammoTypes.get(liquids.current());"', source_text)
            self.assertIn('"current_liquid": current_liquid', source_text)
            self.assertIn('"peek_ammo": ammo_type', source_text)

    def test_emit_bridges_continuous_liquid_turret_build_has_ammo_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ContinuousLiquidTurret extends ContinuousTurret{
    public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{
        boolean activated;

        @Override
        public boolean hasAmmo(){
            return hasCorrectAmmo() && ammoTypes.get(liquids.current()) != null && liquids.currentAmount() > 0f && activated;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ContinuousLiquidTurretBuild_method_hasAmmo_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var has_correct_ammo: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var current_liquid: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var ammo_type: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("var current_amount: float = float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var activated: bool = bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("var ammo_type_present: bool = ammo_type != null", source_text)
            self.assertIn("var has_ammo: bool = has_correct_ammo and ammo_type_present and current_amount > 0.0 and activated", source_text)
            self.assertIn('"source_owner": "PortGame.source_continuous_liquid_turret_build_has_ammo_state"', source_text)
            self.assertIn('"inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{"', source_text)
            self.assertIn('"field": "boolean activated;"', source_text)
            self.assertIn('"method": "public boolean hasAmmo(){"', source_text)
            self.assertIn('"return_expr": "return hasCorrectAmmo() && ammoTypes.get(liquids.current()) != null && liquids.currentAmount() > 0f && activated;"', source_text)
            self.assertIn('"has_ammo": has_ammo', source_text)

    def test_emit_bridges_continuous_liquid_turret_build_has_correct_ammo_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ContinuousLiquidTurret extends ContinuousTurret{
    public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{
        boolean activated;

        public boolean hasCorrectAmmo(){
            return !bullets.any() || bullets.first().bullet.type == peekAmmo();
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ContinuousLiquidTurretBuild_method_hasCorrectAmmo_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var bullets_any: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var first_bullet_type: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var peek_ammo: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("var has_correct_ammo: bool = (not bullets_any) or first_bullet_type == peek_ammo", source_text)
            self.assertIn('"source_owner": "PortGame.source_continuous_liquid_turret_build_has_correct_ammo_state"', source_text)
            self.assertIn('"inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{"', source_text)
            self.assertIn('"field": "boolean activated;"', source_text)
            self.assertIn('"method": "public boolean hasCorrectAmmo(){"', source_text)
            self.assertIn('"return_expr": "return !bullets.any() || bullets.first().bullet.type == peekAmmo();"', source_text)
            self.assertIn('"has_correct_ammo": has_correct_ammo', source_text)

    def test_emit_bridges_continuous_liquid_turret_build_accept_item_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ContinuousLiquidTurret extends ContinuousTurret{
    public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{
        boolean activated;

        @Override
        public boolean acceptItem(Building source, Item item){
            return false;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ContinuousLiquidTurretBuild_method_acceptItem_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var source_building: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var item: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var accept_item: bool = false", source_text)
            self.assertIn('"source_owner": "PortGame.source_continuous_liquid_turret_build_accept_item_state"', source_text)
            self.assertIn('"inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{"', source_text)
            self.assertIn('"field": "boolean activated;"', source_text)
            self.assertIn('"method": "public boolean acceptItem(Building source, Item item){"', source_text)
            self.assertIn('"override_expr": "@Override"', source_text)
            self.assertIn('"return_expr": "return false;"', source_text)
            self.assertIn('"source_building": source_building', source_text)
            self.assertIn('"item": item', source_text)
            self.assertIn('"accept_item": accept_item', source_text)

    def test_emit_bridges_continuous_liquid_turret_build_accept_liquid_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ContinuousLiquidTurret extends ContinuousTurret{
    public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{
        boolean activated;

        @Override
        public boolean acceptLiquid(Building source, Liquid liquid){
            return ammoTypes.get(liquid) != null &&
                (liquids.current() == liquid ||
                ((!ammoTypes.containsKey(liquids.current()) || liquids.get(liquids.current()) <= 1f / ammoTypes.get(liquids.current()).ammoMultiplier + 0.001f)));
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ContinuousLiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_ContinuousLiquidTurretBuild_method_acceptLiquid_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var source_building: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var liquid: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var ammo_type: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("var current_liquid: Variant = _args[3] if _args.size() > 3 else null", source_text)
            self.assertIn("var current_liquid_ammo_type_present: bool = bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("var current_liquid_amount: float = float(_args[5] if _args.size() > 5 else 0.0)", source_text)
            self.assertIn("var current_ammo_multiplier: float = float(_args[6] if _args.size() > 6 else 1.0)", source_text)
            self.assertIn("var liquid_has_ammo_type: bool = ammo_type != null", source_text)
            self.assertIn("var same_liquid: bool = current_liquid == liquid", source_text)
            self.assertIn("var current_liquid_missing_ammo_type: bool = not current_liquid_ammo_type_present", source_text)
            self.assertIn("var current_required_with_epsilon: Variant = null", source_text)
            self.assertIn("if liquid_has_ammo_type and not same_liquid and current_liquid_ammo_type_present:", source_text)
            self.assertIn("current_required_with_epsilon = 1.0 / current_ammo_multiplier + 0.001", source_text)
            self.assertIn("current_liquid_drained = current_liquid_amount <= current_required_with_epsilon", source_text)
            self.assertIn("var accept_liquid: bool = liquid_has_ammo_type and (same_liquid or replacement_allowed)", source_text)
            self.assertIn('"source_owner": "PortGame.source_continuous_liquid_turret_build_accept_liquid_state"', source_text)
            self.assertIn('"inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{"', source_text)
            self.assertIn('"field": "boolean activated;"', source_text)
            self.assertIn('"method": "public boolean acceptLiquid(Building source, Liquid liquid){"', source_text)
            self.assertIn('"override_expr": "@Override"', source_text)
            self.assertIn('"return_expr": "return ammoTypes.get(liquid) != null && (liquids.current() == liquid || ((!ammoTypes.containsKey(liquids.current()) || liquids.get(liquids.current()) <= 1f / ammoTypes.get(liquids.current()).ammoMultiplier + 0.001f)));"', source_text)
            self.assertIn('"accept_liquid": accept_liquid', source_text)

    def test_emit_bridges_liquid_turret_build_get_ammo_content_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            liquid_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.java"
            liquid_turret_path.parent.mkdir(parents=True, exist_ok=True)
            liquid_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class LiquidTurret extends Turret{
    public class LiquidTurretBuild extends TurretBuild{

        @Override
        public boolean shouldActiveSound(){
            return wasShooting && enabled;
        }

        @Override
        public UnlockableContent getAmmoContent(){
            return liquids != null && liquids.currentAmount() > 0f ? liquids.current() : null;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_LiquidTurretBuild_method_getAmmoContent_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var liquids_null: bool = bool(_args[0] if _args.size() > 0 else true)", source_text)
            self.assertIn("var current_amount: float = float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var current_liquid: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_liquid_turret_build_get_ammo_content_state"', source_text)
            self.assertIn('"inner_class": "public class LiquidTurretBuild extends TurretBuild{"', source_text)
            self.assertIn('"method": "public UnlockableContent getAmmoContent(){"', source_text)
            self.assertIn('"return_expr": "return liquids != null && liquids.currentAmount() > 0f ? liquids.current() : null;"', source_text)
            self.assertIn('"ammo_content": ammo_content', source_text)

    def test_emit_bridges_liquid_turret_build_get_ammo_fraction_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            liquid_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.java"
            liquid_turret_path.parent.mkdir(parents=True, exist_ok=True)
            liquid_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class LiquidTurret extends Turret{
    public class LiquidTurretBuild extends TurretBuild{

        @Override
        public boolean shouldActiveSound(){
            return wasShooting && enabled;
        }

        @Override
        public UnlockableContent getAmmoContent(){
            return liquids != null && liquids.currentAmount() > 0f ? liquids.current() : null;
        }

        @Override
        public float getAmmoFraction(){
            return liquids.currentAmount() / liquidCapacity;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_LiquidTurretBuild_method_getAmmoFraction_2(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var current_amount: float = float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var liquid_capacity: float = float(_args[1] if _args.size() > 1 else 1.0)", source_text)
            self.assertIn('"source_owner": "PortGame.source_liquid_turret_build_get_ammo_fraction_state"', source_text)
            self.assertIn('"inner_class": "public class LiquidTurretBuild extends TurretBuild{"', source_text)
            self.assertIn('"method": "public float getAmmoFraction(){"', source_text)
            self.assertIn('"return_expr": "return liquids.currentAmount() / liquidCapacity;"', source_text)
            self.assertIn('"ammo_fraction": ammo_fraction', source_text)

    def test_emit_bridges_liquid_turret_build_sense_object_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            liquid_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.java"
            liquid_turret_path.parent.mkdir(parents=True, exist_ok=True)
            liquid_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class LiquidTurret extends Turret{
    public class LiquidTurretBuild extends TurretBuild{
        @Override
        public boolean shouldActiveSound(){
            return wasShooting && enabled;
        }

        @Override
        public UnlockableContent getAmmoContent(){
            return liquids != null && liquids.currentAmount() > 0f ? liquids.current() : null;
        }

        @Override
        public float getAmmoFraction(){
            return liquids.currentAmount() / liquidCapacity;
        }

        @Override
        public Object senseObject(LAccess sensor){
            return switch(sensor){
                case currentAmmoType -> liquids.current();
                default -> super.senseObject(sensor);
            };
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_LiquidTurretBuild_method_senseObject_3(_args: Array = []) -> Variant:", source_text)
            self.assertIn('var sensor: String = str(_args[0] if _args.size() > 0 else "")', source_text)
            self.assertIn("var current_liquid: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var super_sense_object_value: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn('if sensor == "currentAmmoType":', source_text)
            self.assertIn("sense_object_value = current_liquid", source_text)
            self.assertIn("sense_object_value = super_sense_object_value", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_liquid_turret_build_sense_object_state"', source_text)
            self.assertIn('"method": "public Object senseObject(LAccess sensor){"', source_text)
            self.assertIn('"current_ammo_type_case": "case currentAmmoType -> liquids.current();"', source_text)
            self.assertIn('"default_case": "default -> super.senseObject(sensor);"', source_text)
            self.assertIn('"sense_object_value": sense_object_value', source_text)

    def test_emit_bridges_liquid_turret_build_find_target_extinguish_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            liquid_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.java"
            liquid_turret_path.parent.mkdir(parents=True, exist_ok=True)
            liquid_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class LiquidTurret extends Turret{
    public class LiquidTurretBuild extends TurretBuild{
        @Override
        public boolean shouldActiveSound(){ return wasShooting && enabled; }
        @Override
        public UnlockableContent getAmmoContent(){ return liquids.current(); }
        @Override
        public float getAmmoFraction(){ return liquids.currentAmount() / liquidCapacity; }
        @Override
        public Object senseObject(LAccess sensor){ return liquids.current(); }

        @Override
        protected void findTarget(){
            if(extinguish && liquids.current().canExtinguish()){
                Fire result = null;
                if(result != null){
                    target = result;
                    return;
                }
            }

            super.findTarget();
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_LiquidTurretBuild_method_findTarget_4(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var extinguish: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var current_liquid_can_extinguish: bool = bool(_args[1] if _args.size() > 1 else false)", source_text)
            self.assertIn("var fire_result: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("var should_scan_fires: bool = extinguish and current_liquid_can_extinguish", source_text)
            self.assertIn("if should_scan_fires and fire_result != null:", source_text)
            self.assertIn("target_after = fire_result", source_text)
            self.assertIn('"source_owner": "PortGame.source_liquid_turret_build_find_target_extinguish_state"', source_text)
            self.assertIn('"method": "protected void findTarget(){"', source_text)
            self.assertIn('"guard_expr": "if(extinguish && liquids.current().canExtinguish()){"', source_text)
            self.assertIn('"assign_expr": "target = result;"', source_text)
            self.assertIn('"super_find_target_expr": "super.findTarget();"', source_text)

    def test_emit_bridges_liquid_turret_build_use_ammo_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            liquid_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.java"
            liquid_turret_path.parent.mkdir(parents=True, exist_ok=True)
            liquid_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class LiquidTurret extends Turret{
    public class LiquidTurretBuild extends TurretBuild{
        @Override
        public boolean shouldActiveSound(){ return wasShooting && enabled; }
        @Override
        public UnlockableContent getAmmoContent(){ return liquids.current(); }
        @Override
        public float getAmmoFraction(){ return liquids.currentAmount() / liquidCapacity; }
        @Override
        public Object senseObject(LAccess sensor){ return liquids.current(); }
        @Override
        protected void findTarget(){ super.findTarget(); }

        @Override
        public BulletType useAmmo(){
            if(cheating()) return ammoTypes.get(liquids.current());
            BulletType type = ammoTypes.get(liquids.current());
            liquids.remove(liquids.current(), 1f / type.ammoMultiplier);
            return type;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_LiquidTurretBuild_method_useAmmo_5(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var cheating: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var current_liquid: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var ammo_type: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("var ammo_multiplier: float = float(_args[3] if _args.size() > 3 else 1.0)", source_text)
            self.assertIn("if not cheating:", source_text)
            self.assertIn("liquid_remove_amount = 1.0 / ammo_multiplier", source_text)
            self.assertIn('"source_owner": "PortGame.source_liquid_turret_build_use_ammo_state"', source_text)
            self.assertIn('"method": "public BulletType useAmmo(){"', source_text)
            self.assertIn('"cheating_return_expr": "if(cheating()) return ammoTypes.get(liquids.current());"', source_text)
            self.assertIn('"type_lookup_expr": "BulletType type = ammoTypes.get(liquids.current());"', source_text)
            self.assertIn('"remove_expr": "liquids.remove(liquids.current(), 1f / type.ammoMultiplier);"', source_text)
            self.assertIn('"return_expr": "return type;"', source_text)

    def test_emit_bridges_liquid_turret_build_peek_ammo_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            liquid_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.java"
            liquid_turret_path.parent.mkdir(parents=True, exist_ok=True)
            liquid_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class LiquidTurret extends Turret{
    public class LiquidTurretBuild extends TurretBuild{
        @Override
        public boolean shouldActiveSound(){ return wasShooting && enabled; }
        @Override
        public UnlockableContent getAmmoContent(){ return liquids.current(); }
        @Override
        public float getAmmoFraction(){ return liquids.currentAmount() / liquidCapacity; }
        @Override
        public Object senseObject(LAccess sensor){ return liquids.current(); }
        @Override
        protected void findTarget(){ super.findTarget(); }
        @Override
        public BulletType useAmmo(){ return ammoTypes.get(liquids.current()); }

        @Override
        public BulletType peekAmmo(){
            return ammoTypes.get(liquids.current());
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_LiquidTurretBuild_method_peekAmmo_6(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var current_liquid: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var ammo_type: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn('"source_owner": "PortGame.source_liquid_turret_build_peek_ammo_state"', source_text)
            self.assertIn('"inner_class": "public class LiquidTurretBuild extends TurretBuild{"', source_text)
            self.assertIn('"method": "public BulletType peekAmmo(){"', source_text)
            self.assertIn('"return_expr": "return ammoTypes.get(liquids.current());"', source_text)
            self.assertIn('"current_liquid": current_liquid', source_text)
            self.assertIn('"peek_ammo": ammo_type', source_text)

    def test_emit_bridges_liquid_turret_build_has_ammo_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            liquid_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.java"
            liquid_turret_path.parent.mkdir(parents=True, exist_ok=True)
            liquid_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class LiquidTurret extends Turret{
    public class LiquidTurretBuild extends TurretBuild{
        @Override
        public boolean shouldActiveSound(){ return wasShooting && enabled; }
        @Override
        public UnlockableContent getAmmoContent(){ return liquids.current(); }
        @Override
        public float getAmmoFraction(){ return liquids.currentAmount() / liquidCapacity; }
        @Override
        public Object senseObject(LAccess sensor){ return liquids.current(); }
        @Override
        protected void findTarget(){ super.findTarget(); }
        @Override
        public BulletType useAmmo(){ return ammoTypes.get(liquids.current()); }
        @Override
        public BulletType peekAmmo(){ return ammoTypes.get(liquids.current()); }

        @Override
        public boolean hasAmmo(){
            return ammoTypes.get(liquids.current()) != null && liquids.currentAmount() >= 1f / ammoTypes.get(liquids.current()).ammoMultiplier;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_LiquidTurretBuild_method_hasAmmo_7(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var current_liquid: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var ammo_type: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var current_amount: float = float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var ammo_multiplier: float = float(_args[3] if _args.size() > 3 else 1.0)", source_text)
            self.assertIn("var ammo_type_present: bool = ammo_type != null", source_text)
            self.assertIn("var required_amount: float = 1.0 / ammo_multiplier", source_text)
            self.assertIn("var has_ammo: bool = ammo_type_present and current_amount >= required_amount", source_text)
            self.assertIn('"source_owner": "PortGame.source_liquid_turret_build_has_ammo_state"', source_text)
            self.assertIn('"method": "public boolean hasAmmo(){"', source_text)
            self.assertIn('"return_expr": "return ammoTypes.get(liquids.current()) != null && liquids.currentAmount() >= 1f / ammoTypes.get(liquids.current()).ammoMultiplier;"', source_text)
            self.assertIn('"has_ammo": has_ammo', source_text)

    def test_emit_bridges_liquid_turret_build_accept_item_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            liquid_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.java"
            liquid_turret_path.parent.mkdir(parents=True, exist_ok=True)
            liquid_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class LiquidTurret extends Turret{
    public class LiquidTurretBuild extends TurretBuild{
        @Override
        public boolean shouldActiveSound(){ return wasShooting && enabled; }
        @Override
        public UnlockableContent getAmmoContent(){ return liquids.current(); }
        @Override
        public float getAmmoFraction(){ return liquids.currentAmount() / liquidCapacity; }
        @Override
        public Object senseObject(LAccess sensor){ return liquids.current(); }
        @Override
        protected void findTarget(){ super.findTarget(); }
        @Override
        public BulletType useAmmo(){ return ammoTypes.get(liquids.current()); }
        @Override
        public BulletType peekAmmo(){ return ammoTypes.get(liquids.current()); }
        @Override
        public boolean hasAmmo(){ return true; }

        @Override
        public boolean acceptItem(Building source, Item item){
            return false;
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_LiquidTurretBuild_method_acceptItem_8(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var source_building: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var item: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var accept_item: bool = false", source_text)
            self.assertIn('"source_owner": "PortGame.source_liquid_turret_build_accept_item_state"', source_text)
            self.assertIn('"inner_class": "public class LiquidTurretBuild extends TurretBuild{"', source_text)
            self.assertIn('"method": "public boolean acceptItem(Building source, Item item){"', source_text)
            self.assertIn('"return_expr": "return false;"', source_text)
            self.assertIn('"source_building": source_building', source_text)
            self.assertIn('"item": item', source_text)
            self.assertIn('"accept_item": accept_item', source_text)

    def test_emit_bridges_liquid_turret_build_accept_liquid_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            liquid_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.java"
            liquid_turret_path.parent.mkdir(parents=True, exist_ok=True)
            liquid_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class LiquidTurret extends Turret{
    public class LiquidTurretBuild extends TurretBuild{
        @Override
        public boolean shouldActiveSound(){ return wasShooting && enabled; }
        @Override
        public UnlockableContent getAmmoContent(){ return liquids.current(); }
        @Override
        public float getAmmoFraction(){ return liquids.currentAmount() / liquidCapacity; }
        @Override
        public Object senseObject(LAccess sensor){ return liquids.current(); }
        @Override
        protected void findTarget(){ super.findTarget(); }
        @Override
        public BulletType useAmmo(){ return ammoTypes.get(liquids.current()); }
        @Override
        public BulletType peekAmmo(){ return ammoTypes.get(liquids.current()); }
        @Override
        public boolean hasAmmo(){ return true; }
        @Override
        public boolean acceptItem(Building source, Item item){ return false; }

        @Override
        public boolean acceptLiquid(Building source, Liquid liquid){
            return ammoTypes.get(liquid) != null &&
                (liquids.current() == liquid ||
                ((!ammoTypes.containsKey(liquids.current()) || liquids.get(liquids.current()) <= 1f / ammoTypes.get(liquids.current()).ammoMultiplier + 0.001f)));
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "LiquidTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_inner_class_LiquidTurretBuild_method_acceptLiquid_9(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var source_building: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn("var liquid: Variant = _args[1] if _args.size() > 1 else null", source_text)
            self.assertIn("var ammo_type: Variant = _args[2] if _args.size() > 2 else null", source_text)
            self.assertIn("var current_liquid: Variant = _args[3] if _args.size() > 3 else null", source_text)
            self.assertIn("var current_liquid_ammo_type_present: bool = bool(_args[4] if _args.size() > 4 else false)", source_text)
            self.assertIn("var current_liquid_amount: float = float(_args[5] if _args.size() > 5 else 0.0)", source_text)
            self.assertIn("var current_ammo_multiplier: float = float(_args[6] if _args.size() > 6 else 1.0)", source_text)
            self.assertIn("var liquid_has_ammo_type: bool = ammo_type != null", source_text)
            self.assertIn("var same_liquid: bool = current_liquid == liquid", source_text)
            self.assertIn("var current_liquid_missing_ammo_type: bool = not current_liquid_ammo_type_present", source_text)
            self.assertIn("var current_required_with_epsilon: Variant = null", source_text)
            self.assertIn("if liquid_has_ammo_type and not same_liquid and current_liquid_ammo_type_present:", source_text)
            self.assertIn("current_required_with_epsilon = 1.0 / current_ammo_multiplier + 0.001", source_text)
            self.assertIn("current_liquid_drained = current_liquid_amount <= current_required_with_epsilon", source_text)
            self.assertIn("var accept_liquid: bool = liquid_has_ammo_type and (same_liquid or replacement_allowed)", source_text)
            self.assertIn('"source_owner": "PortGame.source_liquid_turret_build_accept_liquid_state"', source_text)
            self.assertIn('"method": "public boolean acceptLiquid(Building source, Liquid liquid){"', source_text)
            self.assertIn('"return_expr": "return ammoTypes.get(liquid) != null && (liquids.current() == liquid || ((!ammoTypes.containsKey(liquids.current()) || liquids.get(liquids.current()) <= 1f / ammoTypes.get(liquids.current()).ammoMultiplier + 0.001f)));"', source_text)
            self.assertIn('"accept_liquid": accept_liquid', source_text)

    def test_emit_bridges_item_turret_limit_range_default_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    /** Limits bullet range to this turret's range value. */
    public void limitRange(){
        limitRange(9f);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_limitRange_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_item_turret_limit_range_default_state"', source_text)
            self.assertIn('"method": "public void limitRange(){"', source_text)
            self.assertIn('"comment": "/** Limits bullet range to this turret\'s range value. */"', source_text)
            self.assertIn('"dispatch_expr": "limitRange(9f);"', source_text)
            self.assertIn("var margin: float = 9.0", source_text)
            self.assertIn('"margin": margin', source_text)
            self.assertIn('"limit_range_called": true', source_text)

    def test_emit_bridges_item_turret_limit_range_entries_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public ObjectMap<Item, BulletType> ammoTypes = new OrderedMap<>();

    /** Initializes accepted ammo map. Format: [item1, bullet1, item2, bullet2...] */
    public void ammo(Object... objects){
        ammoTypes = OrderedMap.of(objects);
    }

    /** Limits bullet range to this turret's range value. */
    public void limitRange(){
        limitRange(9f);
    }

    /** Limits bullet range to this turret's range value. */
    public void limitRange(float margin){
        for(var entry : ammoTypes.entries()){
            limitRange(entry.value, margin);
        }
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_limitRange_1(_args: Array = []) -> Variant:", source_text)
            self.assertIn("func java_method_limitRange_2(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var margin: float = float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var ammo_entries: Array = _args[1] if _args.size() > 1 else []", source_text)
            self.assertIn("for entry in ammo_entries:", source_text)
            self.assertIn('var entry_value: Variant = entry.get("value", null) if entry is Dictionary else entry', source_text)
            self.assertIn("limit_range_calls.append({\"call\": \"limitRange(entry.value, margin);\", \"entry_value\": entry_value, \"margin\": margin})", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_item_turret_limit_range_entries_state"', source_text)
            self.assertIn('"method": "public void limitRange(float margin){"', source_text)
            self.assertIn('"loop_expr": "for(var entry : ammoTypes.entries()){"', source_text)
            self.assertIn('"dispatch_expr": "limitRange(entry.value, margin);"', source_text)

    def test_emit_bridges_item_turret_set_stats_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public ObjectMap<Item, BulletType> ammoTypes = new OrderedMap<>();

    /** Initializes accepted ammo map. Format: [item1, bullet1, item2, bullet2...] */
    public void ammo(Object... objects){
        ammoTypes = OrderedMap.of(objects);
    }

    /** Limits bullet range to this turret's range value. */
    public void limitRange(){
        limitRange(9f);
    }

    /** Limits bullet range to this turret's range value. */
    public void limitRange(float margin){
        for(var entry : ammoTypes.entries()){
            limitRange(entry.value, margin);
        }
    }

    @Override
    public void setStats(){
        super.setStats();

        stats.remove(Stat.itemCapacity);
        stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));
        stats.add(Stat.ammoCapacity, maxAmmo / Math.max(ammoPerShot, 1), StatUnit.shots);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setStats_3(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var ammo_types: Variant = _args[0] if _args.size() > 0 else null", source_text)
            self.assertIn('var name_value: String = str(_args[1] if _args.size() > 1 else "")', source_text)
            self.assertIn("var max_ammo: float = float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var ammo_per_shot: float = float(_args[3] if _args.size() > 3 else 1.0)", source_text)
            self.assertIn("var ammo_capacity_divisor: float = maxf(ammo_per_shot, 1.0)", source_text)
            self.assertIn("var ammo_capacity: float = max_ammo / ammo_capacity_divisor", source_text)
            self.assertIn("var ammo_values_call: Dictionary = {\"call\": \"StatValues.ammo(ammoTypes, name)\", \"ammo_types\": ammo_types, \"name\": name_value}", source_text)
            self.assertIn("var stats_ammo_capacity_add_call: Dictionary = {\"call\": \"stats.add(Stat.ammoCapacity, maxAmmo / Math.max(ammoPerShot, 1), StatUnit.shots);\", \"stat\": \"Stat.ammoCapacity\", \"value\": ammo_capacity, \"unit\": \"StatUnit.shots\"}", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_item_turret_set_stats_state"', source_text)
            self.assertIn('"method": "public void setStats(){"', source_text)
            self.assertIn('"stats_remove_expr": "stats.remove(Stat.itemCapacity);"', source_text)
            self.assertIn('"stats_ammo_add_expr": "stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));"', source_text)
            self.assertIn('"stats_ammo_capacity_add_expr": "stats.add(Stat.ammoCapacity, maxAmmo / Math.max(ammoPerShot, 1), StatUnit.shots);"', source_text)

    def test_emit_bridges_item_turret_set_bars_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public ObjectMap<Item, BulletType> ammoTypes = new OrderedMap<>();

    /** Initializes accepted ammo map. Format: [item1, bullet1, item2, bullet2...] */
    public void ammo(Object... objects){
        ammoTypes = OrderedMap.of(objects);
    }

    /** Limits bullet range to this turret's range value. */
    public void limitRange(){
        limitRange(9f);
    }

    /** Limits bullet range to this turret's range value. */
    public void limitRange(float margin){
        for(var entry : ammoTypes.entries()){
            limitRange(entry.value, margin);
        }
    }

    @Override
    public void setStats(){
        super.setStats();

        stats.remove(Stat.itemCapacity);
        stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));
        stats.add(Stat.ammoCapacity, maxAmmo / Math.max(ammoPerShot, 1), StatUnit.shots);
    }

    @Override
    public void setBars(){
        super.setBars();

        addBar("ammo", (ItemTurretBuild entity) ->
            new Bar(
                "stat.ammo",
                Pal.ammo,
                () -> (float)entity.totalAmmo / maxAmmo
            )
        );
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setBars_4(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var total_ammo: float = float(_args[0] if _args.size() > 0 else 0.0)", source_text)
            self.assertIn("var max_ammo: float = float(_args[1] if _args.size() > 1 else 1.0)", source_text)
            self.assertIn("var ammo_bar_fraction: float = total_ammo / max_ammo", source_text)
            self.assertIn("var bar_call: Dictionary = {\"call\": \"addBar(\\\"ammo\\\", (ItemTurretBuild entity) -> new Bar(...));\", \"name\": \"ammo\", \"bar_text\": \"stat.ammo\", \"color\": \"Pal.ammo\", \"fraction\": ammo_bar_fraction}", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_item_turret_set_bars_state"', source_text)
            self.assertIn('"method": "public void setBars(){"', source_text)
            self.assertIn('"super_set_bars_expr": "super.setBars();"', source_text)
            self.assertIn('"add_bar_expr": "addBar(\\"ammo\\", (ItemTurretBuild entity) -> new Bar(\\"', source_text)
            self.assertIn('"bar_fraction_expr": "() -> (float)entity.totalAmmo / maxAmmo"', source_text)

    def test_emit_bridges_item_turret_init_ground_overlap_to_source_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            item_turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.java"
            item_turret_path.parent.mkdir(parents=True, exist_ok=True)
            item_turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

public class ItemTurret extends Turret{
    public ObjectMap<Item, BulletType> ammoTypes = new OrderedMap<>();

    @Override
    public void init(){
        consume(new ConsumeItemFilter(i -> ammoTypes.containsKey(i)){
            @Override
            public void build(Building build, Table table){
                MultiReqImage image = new MultiReqImage();
            }
        });

        if(targetGround){
            ammoTypes.each((item, type) -> placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin));
        }

        super.init();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "ItemTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_init_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var target_ground: bool = bool(_args[0] if _args.size() > 0 else false)", source_text)
            self.assertIn("var place_overlap_range: float = float(_args[1] if _args.size() > 1 else 0.0)", source_text)
            self.assertIn("var range_value: float = float(_args[2] if _args.size() > 2 else 0.0)", source_text)
            self.assertIn("var place_overlap_margin: float = float(_args[3] if _args.size() > 3 else 0.0)", source_text)
            self.assertIn("var ammo_entries: Array = _args[4] if _args.size() > 4 else []", source_text)
            self.assertIn("var place_overlap_range_after: float = place_overlap_range", source_text)
            self.assertIn("if target_ground:", source_text)
            self.assertIn("var range_change: float = float(entry_value.get(\"range_change\", entry_value.get(\"rangeChange\", 0.0)) if entry_value is Dictionary else 0.0)", source_text)
            self.assertIn("var candidate_range: float = range_value + range_change + place_overlap_margin", source_text)
            self.assertIn("place_overlap_range_after = maxf(place_overlap_range_after, candidate_range)", source_text)
            self.assertIn('return {"source_owner": "PortGame.source_item_turret_init_ground_overlap_state"', source_text)
            self.assertIn('"method": "public void init(){"', source_text)
            self.assertIn('"consume_expr": "consume(new ConsumeItemFilter(i -> ammoTypes.containsKey(i)))"', source_text)
            self.assertIn('"target_ground_guard_expr": "if(targetGround){"', source_text)
            self.assertIn('"overlap_expr": "placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin)"', source_text)
            self.assertIn('"super_init_expr": "super.init();"', source_text)

if __name__ == "__main__":
    unittest.main()
