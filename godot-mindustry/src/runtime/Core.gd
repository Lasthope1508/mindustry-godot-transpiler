extends RefCounted
class_name Core

static var assets: Dictionary = {}
static var settings: Dictionary = {}

static func asset(path: String) -> Variant:
	return assets.get(path)
