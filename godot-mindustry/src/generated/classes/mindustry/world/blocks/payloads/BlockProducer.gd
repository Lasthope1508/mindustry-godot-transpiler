# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/payloads/BlockProducer.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.payloads"
const JAVA_KIND := "class"
const JAVA_NAME := "BlockProducer"
const JAVA_EXTENDS := "PayloadBlock"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "buildSpeed", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BlockProducer", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_icons_0(_args: Array = []) -> Variant:
	var region: Variant = _args[0] if _args.size() > 0 else null
	var out_region: Variant = _args[1] if _args.size() > 1 else null
	var top_region: Variant = _args[2] if _args.size() > 2 else null
	var icons: Array = [region, out_region, top_region]
	return {"source_owner": "PortGame.source_block_producer_icons_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "class_expr": "public abstract class BlockProducer extends PayloadBlock{", "override_expr": "@Override", "method": "public TextureRegion[] icons(){", "return_expr": "return new TextureRegion[]{region, outRegion, topRegion};", "region": region, "out_region": out_region, "top_region": top_region, "icons": icons}

func java_method_drawPlanRegion_1(_args: Array = []) -> Variant:
	var region: Variant = _args[0] if _args.size() > 0 else null
	var out_region: Variant = _args[1] if _args.size() > 1 else null
	var top_region: Variant = _args[2] if _args.size() > 2 else null
	var plan_drawx: float = float(_args[3] if _args.size() > 3 else 0.0)
	var plan_drawy: float = float(_args[4] if _args.size() > 4 else 0.0)
	var plan_rotation: float = float(_args[5] if _args.size() > 5 else 0.0)
	var out_region_rotation: float = plan_rotation * 90.0
	var draw_calls: Array = [{"call": "Draw.rect(region, plan.drawx(), plan.drawy());", "region": region, "x": plan_drawx, "y": plan_drawy}, {"call": "Draw.rect(outRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);", "region": out_region, "x": plan_drawx, "y": plan_drawy, "rotation": out_region_rotation}, {"call": "Draw.rect(topRegion, plan.drawx(), plan.drawy());", "region": top_region, "x": plan_drawx, "y": plan_drawy}]
	return {"source_owner": "PortGame.source_block_producer_draw_plan_region_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "class_expr": "public abstract class BlockProducer extends PayloadBlock{", "override_expr": "@Override", "method": "public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){", "draw_region_expr": "Draw.rect(region, plan.drawx(), plan.drawy());", "draw_out_region_expr": "Draw.rect(outRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);", "draw_top_region_expr": "Draw.rect(topRegion, plan.drawx(), plan.drawy());", "region": region, "out_region": out_region, "top_region": top_region, "plan_drawx": plan_drawx, "plan_drawy": plan_drawy, "plan_rotation": plan_rotation, "out_region_rotation": out_region_rotation, "draw_calls": draw_calls}

func java_method_setBars_2(_args: Array = []) -> Variant:
	var recipe_null: bool = bool(_args[0] if _args.size() > 0 else true)
	var entity_progress: float = float(_args[1] if _args.size() > 1 else 0.0)
	var recipe_build_time: float = float(_args[2] if _args.size() > 2 else 1.0)
	var progress_bar_fraction: float = 0.0 if recipe_null else entity_progress / recipe_build_time
	var progress_bar_call: Dictionary = {"call": "addBar(\"progress\", (BlockProducerBuild entity) -> new Bar(\"bar.progress\", Pal.ammo, () -> entity.recipe() == null ? 0f : (entity.progress / entity.recipe().buildTime)));", "name": "progress", "bar_text": "bar.progress", "color": "Pal.ammo", "fraction": progress_bar_fraction}
	return {"source_owner": "PortGame.source_block_producer_set_bars_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "class_expr": "public abstract class BlockProducer extends PayloadBlock{", "override_expr": "@Override", "method": "public void setBars(){", "super_set_bars_expr": "super.setBars();", "add_bar_expr": "addBar(\"progress\", (BlockProducerBuild entity) -> new Bar(\"bar.progress\", Pal.ammo, () -> entity.recipe() == null ? 0f : (entity.progress / entity.recipe().buildTime)));", "bar_text": "bar.progress", "bar_color": "Pal.ammo", "bar_progress_expr": "entity.recipe() == null ? 0f : (entity.progress / entity.recipe().buildTime)", "recipe_null": recipe_null, "entity_progress": entity_progress, "recipe_build_time": recipe_build_time, "super_set_bars_called": true, "progress_bar_added": true, "progress_bar_fraction": progress_bar_fraction, "progress_bar_call": progress_bar_call}
