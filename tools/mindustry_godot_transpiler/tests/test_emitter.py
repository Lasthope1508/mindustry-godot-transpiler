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

if __name__ == "__main__":
    unittest.main()
