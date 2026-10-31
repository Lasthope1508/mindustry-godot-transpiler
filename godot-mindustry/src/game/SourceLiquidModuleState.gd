extends RefCounted
class_name SourceLiquidModuleState

# Explicit storage frame: liquids is the indexed amount array; current is Liquid.id;
# flow preserves Java's null/non-null guard. cache_sums is the shared static array,
# supplied separately so two module frames can update the same upstream cache.
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
