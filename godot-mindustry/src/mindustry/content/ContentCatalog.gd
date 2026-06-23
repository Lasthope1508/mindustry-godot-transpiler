extends RefCounted
class_name MindustryContentCatalog

const GeneratedRegistry := preload("res://src/generated/MindustryContentRegistry.gd")
const ItemScript := preload("res://src/mindustry/content/Item.gd")
const LiquidScript := preload("res://src/mindustry/content/Liquid.gd")
const BlockScript := preload("res://src/mindustry/content/Block.gd")

var items: Array = []
var liquids: Array = []
var blocks: Array = []
var by_id: Dictionary = {}
var by_type: Dictionary = {"item": [], "liquid": [], "block": []}

func _init() -> void:
	load_generated_registry()

func load_generated_registry() -> void:
	items.clear()
	liquids.clear()
	blocks.clear()
	by_id.clear()
	by_type = {"item": [], "liquid": [], "block": []}
	for data in GeneratedRegistry.ITEMS:
		_register(ItemScript.new(data))
	for data in GeneratedRegistry.LIQUIDS:
		_register(LiquidScript.new(data))
	for data in GeneratedRegistry.BLOCKS:
		_register(BlockScript.new(data))

func _register(content: RefCounted) -> void:
	by_id[content.id] = content
	by_type[content.content_type].append(content)
	if content.content_type == "item":
		items.append(content)
	elif content.content_type == "liquid":
		liquids.append(content)
	elif content.content_type == "block":
		blocks.append(content)

func counts() -> Dictionary:
	return {"items": items.size(), "liquids": liquids.size(), "blocks": blocks.size()}

func get_by_id(id: String):
	return by_id.get(id)

func get_many(type_name: String) -> Array:
	return by_type.get(type_name, [])

func has_content(id: String) -> bool:
	return by_id.has(id)
