extends RefCounted
class_name SourceGeometryDefaults

# Arc Geometry.d8 order shared by source-backed geometry consumers.
const D8_OFFSETS := [
	Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 1),
	Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
]
