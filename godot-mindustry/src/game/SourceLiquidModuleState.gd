extends RefCounted
class_name SourceLiquidModuleState

# Explicit storage frame: liquids is the indexed amount array; current is Liquid.id;
# flow preserves Java's null/non-null guard. cache_sums is the shared static array,
# supplied separately so two module frames can update the same upstream cache.
static func source_initial_state(content_liquid_ids: Array) -> Dictionary:
	var liquids: Array = []
	liquids.resize(content_liquid_ids.size())
	liquids.fill(0.0)
	return {"liquids": liquids, "current": int(content_liquid_ids[0]), "flow": null}

static func source_current_state(self_state: Dictionary) -> Dictionary:
	return {"current": self_state["current"]}

static func source_current_amount_state(self_state: Dictionary) -> Dictionary:
	return source_get_state(self_state, int(self_state["current"]))

static func source_clear_state(self_state: Dictionary) -> Dictionary:
	self_state["liquids"].fill(0.0)
	return self_state

static func source_reset_state(self_state: Dictionary, liquid_id: int, amount: float) -> Dictionary:
	source_clear_state(self_state)
	self_state["liquids"][liquid_id] = amount
	self_state["current"] = liquid_id
	return self_state

static func source_set_state(self_state: Dictionary, liquid_id: int, amount: float) -> Dictionary:
	if amount >= self_state["liquids"][self_state["current"]]:
		self_state["current"] = liquid_id
	self_state["liquids"][liquid_id] = amount
	return self_state

static func source_get_state(self_state: Dictionary, liquid_id: int) -> Dictionary:
	return {"amount": self_state["liquids"][liquid_id]}

static func source_add_state(self_state: Dictionary, liquid_id: int, amount: float, cache_sums: Array) -> Dictionary:
	self_state["liquids"][liquid_id] += amount
	self_state["current"] = liquid_id
	if self_state["flow"] != null:
		cache_sums[liquid_id] += max(amount, 0.0)
	return self_state

static func source_remove_state(self_state: Dictionary, liquid_id: int, amount: float, cache_sums: Array) -> Dictionary:
	return source_add_state(self_state, liquid_id, max(-amount, -float(self_state["liquids"][liquid_id])), cache_sums)
