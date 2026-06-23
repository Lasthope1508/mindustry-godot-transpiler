extends Node
class_name PortBootstrap

@onready var generated_content: Node = get_node_or_null("../GeneratedContent")
@onready var skin_layer: Node = get_node_or_null("../SkinLayer")

func _ready() -> void:
	print("Mindustry Godot Port bootstrap ready")
