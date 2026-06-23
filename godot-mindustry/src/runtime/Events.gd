extends RefCounted
class_name Events

static var listeners: Dictionary = {}

static func on(event_name: String, callback: Callable) -> void:
	if not listeners.has(event_name):
		listeners[event_name] = []
	listeners[event_name].append(callback)

static func fire(event_name: String, payload: Variant = null) -> void:
	for callback in listeners.get(event_name, []):
		callback.call(payload)
