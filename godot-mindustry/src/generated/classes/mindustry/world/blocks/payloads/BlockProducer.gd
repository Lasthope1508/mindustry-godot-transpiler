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
	return null

func java_method_setBars_2(_args: Array = []) -> Variant:
	return null
