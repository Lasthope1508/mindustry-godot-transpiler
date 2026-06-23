extends RefCounted
class_name ColorCompat

static func from_hex(hex: String) -> Color:
	return Color.html(hex)
