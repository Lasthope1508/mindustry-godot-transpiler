extends RefCounted
class_name SourcePowerGraphBatteryDistributionState

const source_math_defaults_script := preload("res://src/game/SourceMathDefaults.gd")
const source_power_graph_source_text_state := preload("res://src/game/SourcePowerGraphSourceTextState.gd")
const SOURCE_FLOAT_ROUNDING_ERROR := source_math_defaults_script.FLOAT_ROUNDING_ERROR
const SOURCE_POWER_GRAPH_BATTERY_STORED_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_BATTERY_STORED_METHOD
const SOURCE_POWER_GRAPH_BATTERY_STORED_INITIAL := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_BATTERY_STORED_INITIAL
const SOURCE_POWER_GRAPH_BATTERY_CAPACITY_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_BATTERY_CAPACITY_METHOD
const SOURCE_POWER_GRAPH_BATTERY_CAPACITY_INITIAL := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_BATTERY_CAPACITY_INITIAL
const SOURCE_POWER_GRAPH_BATTERY_TOTAL_CAPACITY_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_BATTERY_TOTAL_CAPACITY_METHOD
const SOURCE_POWER_GRAPH_BATTERY_ITEMS_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_BATTERY_ITEMS_EXPR
const SOURCE_POWER_GRAPH_BATTERY_LOOP_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_BATTERY_LOOP_EXPR
const SOURCE_POWER_GRAPH_BATTERY_ITEM_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_BATTERY_ITEM_EXPR
const SOURCE_POWER_GRAPH_BATTERY_ENABLED_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_BATTERY_ENABLED_GUARD
const SOURCE_POWER_GRAPH_BATTERY_STORED_ADD_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_BATTERY_STORED_ADD_EXPR
const SOURCE_POWER_GRAPH_BATTERY_CAPACITY_ADD_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_BATTERY_CAPACITY_ADD_EXPR
const SOURCE_POWER_GRAPH_BATTERY_TOTAL_CAPACITY_ADD_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_BATTERY_TOTAL_CAPACITY_ADD_EXPR
const SOURCE_POWER_GRAPH_BATTERY_STORED_RETURN_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_BATTERY_STORED_RETURN_EXPR
const SOURCE_POWER_GRAPH_BATTERY_CAPACITY_RETURN_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_BATTERY_CAPACITY_RETURN_EXPR
const SOURCE_POWER_GRAPH_USE_BATTERIES_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_USE_BATTERIES_METHOD
const SOURCE_POWER_GRAPH_USE_BATTERIES_STORED_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_USE_BATTERIES_STORED_EXPR
const SOURCE_POWER_GRAPH_USE_BATTERIES_ZERO_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_USE_BATTERIES_ZERO_GUARD
const SOURCE_POWER_GRAPH_USE_BATTERIES_USED_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_USE_BATTERIES_USED_EXPR
const SOURCE_POWER_GRAPH_USE_BATTERIES_CONSUMED_PERCENT_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_USE_BATTERIES_CONSUMED_PERCENT_EXPR
const SOURCE_POWER_GRAPH_USE_BATTERIES_STATUS_MUL_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_USE_BATTERIES_STATUS_MUL_EXPR
const SOURCE_POWER_GRAPH_USE_BATTERIES_RETURN_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_USE_BATTERIES_RETURN_EXPR
const SOURCE_POWER_GRAPH_MATHF_EQUAL_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_MATHF_EQUAL_EXPR
const SOURCE_POWER_GRAPH_CHARGE_BATTERIES_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CHARGE_BATTERIES_METHOD
const SOURCE_POWER_GRAPH_CHARGE_BATTERIES_CAPACITY_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CHARGE_BATTERIES_CAPACITY_EXPR
const SOURCE_POWER_GRAPH_CHARGE_BATTERIES_COMMENT := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CHARGE_BATTERIES_COMMENT
const SOURCE_POWER_GRAPH_CHARGE_BATTERIES_CHARGED_PERCENT_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CHARGE_BATTERIES_CHARGED_PERCENT_EXPR
const SOURCE_POWER_GRAPH_CHARGE_BATTERIES_ZERO_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CHARGE_BATTERIES_ZERO_GUARD
const SOURCE_POWER_GRAPH_CHARGE_BATTERIES_TODO := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CHARGE_BATTERIES_TODO
const SOURCE_POWER_GRAPH_CHARGE_BATTERIES_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CHARGE_BATTERIES_GUARD
const SOURCE_POWER_GRAPH_CHARGE_BATTERIES_STATUS_ADD_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CHARGE_BATTERIES_STATUS_ADD_EXPR
const SOURCE_POWER_GRAPH_CHARGE_BATTERIES_RETURN_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CHARGE_BATTERIES_RETURN_EXPR
const SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_METHOD
const SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_COVERAGE_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_COVERAGE_EXPR
const SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_ITEMS_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_ITEMS_EXPR
const SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_LOOP_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_LOOP_EXPR
const SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_CONSUMER_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_CONSUMER_EXPR
const SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_CONS_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_CONS_EXPR
const SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_BUFFERED_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_BUFFERED_GUARD
const SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_CAPACITY_ZERO_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_CAPACITY_ZERO_GUARD
const SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_MAXIMUM_RATE_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_MAXIMUM_RATE_EXPR
const SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_BUFFERED_STATUS_CLAMP_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_BUFFERED_STATUS_CLAMP_EXPR
const SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_UNBUFFERED_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_UNBUFFERED_GUARD
const SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_UNBUFFERED_COVERAGE_STATUS_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_UNBUFFERED_COVERAGE_STATUS_EXPR
const SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_UNBUFFERED_ESTIMATE_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_UNBUFFERED_ESTIMATE_EXPR
const SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_NAN_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_NAN_GUARD
const SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_NAN_STATUS_ZERO_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_NAN_STATUS_ZERO_EXPR
const SOURCE_POWER_GRAPH_MATHF_ZERO_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_MATHF_ZERO_EXPR
const SOURCE_POWER_GRAPH_MATHF_CLAMP_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_MATHF_CLAMP_EXPR
const SOURCE_POWER_GRAPH_UPDATE_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_METHOD
const SOURCE_POWER_GRAPH_UPDATE_NONEMPTY_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_NONEMPTY_GUARD
const SOURCE_POWER_GRAPH_UPDATE_CHARGED_INIT := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_CHARGED_INIT
const SOURCE_POWER_GRAPH_UPDATE_UNEQUAL_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_UNEQUAL_GUARD
const SOURCE_POWER_GRAPH_UPDATE_DEFICIT_GATE := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_DEFICIT_GATE
const SOURCE_POWER_GRAPH_UPDATE_POWER_BATTERY_USED_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_POWER_BATTERY_USED_EXPR
const SOURCE_POWER_GRAPH_UPDATE_POWER_PRODUCED_BATTERY_ADD_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_POWER_PRODUCED_BATTERY_ADD_EXPR
const SOURCE_POWER_GRAPH_UPDATE_LAST_POWER_PRODUCED_BATTERY_ADD_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_LAST_POWER_PRODUCED_BATTERY_ADD_EXPR
const SOURCE_POWER_GRAPH_UPDATE_SURPLUS_GATE := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_SURPLUS_GATE
const SOURCE_POWER_GRAPH_UPDATE_CHARGED_TRUE_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_CHARGED_TRUE_EXPR
const SOURCE_POWER_GRAPH_UPDATE_POWER_PRODUCED_CHARGE_SUB_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_POWER_PRODUCED_CHARGE_SUB_EXPR
const SOURCE_POWER_GRAPH_UPDATE_DISTRIBUTE_POWER_EXPR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_DISTRIBUTE_POWER_EXPR

static func battery_state(batteries: Array) -> Dictionary:
	var stored := 0.0
	var capacity := 0.0
	var total_capacity := 0.0
	var battery_count := 0
	var enabled_count := 0
	for battery in batteries:
		if typeof(battery) != TYPE_DICTIONARY:
			continue
		battery_count += 1
		if bool(battery.get("enabled", false)):
			var power_status := float(battery.get("power_status", 0.0))
			var source_capacity := float(battery.get("capacity", 0.0))
			stored += power_status * source_capacity
			capacity += (1.0 - power_status) * source_capacity
			total_capacity += source_capacity
			enabled_count += 1
	return {
		"stored_method": SOURCE_POWER_GRAPH_BATTERY_STORED_METHOD,
		"stored_initial": SOURCE_POWER_GRAPH_BATTERY_STORED_INITIAL,
		"capacity_method": SOURCE_POWER_GRAPH_BATTERY_CAPACITY_METHOD,
		"capacity_initial": SOURCE_POWER_GRAPH_BATTERY_CAPACITY_INITIAL,
		"total_capacity_method": SOURCE_POWER_GRAPH_BATTERY_TOTAL_CAPACITY_METHOD,
		"items": SOURCE_POWER_GRAPH_BATTERY_ITEMS_EXPR,
		"loop": SOURCE_POWER_GRAPH_BATTERY_LOOP_EXPR,
		"battery": SOURCE_POWER_GRAPH_BATTERY_ITEM_EXPR,
		"guard": SOURCE_POWER_GRAPH_BATTERY_ENABLED_GUARD,
		"stored_add": SOURCE_POWER_GRAPH_BATTERY_STORED_ADD_EXPR,
		"capacity_add": SOURCE_POWER_GRAPH_BATTERY_CAPACITY_ADD_EXPR,
		"total_capacity_add": SOURCE_POWER_GRAPH_BATTERY_TOTAL_CAPACITY_ADD_EXPR,
		"stored_return": SOURCE_POWER_GRAPH_BATTERY_STORED_RETURN_EXPR,
		"capacity_return": SOURCE_POWER_GRAPH_BATTERY_CAPACITY_RETURN_EXPR,
		"stored": stored,
		"capacity": capacity,
		"total_capacity": total_capacity,
		"battery_count": battery_count,
		"enabled_count": enabled_count,
	}

static func use_batteries_state(batteries: Array, needed: float) -> Dictionary:
	var source_batteries: Array = []
	for battery in batteries:
		if typeof(battery) != TYPE_DICTIONARY:
			continue
		source_batteries.append(battery.duplicate(true))
	var stored_state := battery_state(source_batteries)
	var stored := float(stored_state.get("stored", 0.0))
	var used := 0.0
	var consumed_power_percentage := 0.0
	var zero_guard_returned: bool = abs(stored - 0.0) <= SOURCE_FLOAT_ROUNDING_ERROR
	if not zero_guard_returned:
		used = min(stored, needed)
		consumed_power_percentage = min(1.0, needed / stored)
		for source_battery_state in source_batteries:
			if bool(source_battery_state.get("enabled", false)):
				var power_status := float(source_battery_state.get("power_status", 0.0))
				source_battery_state["power_status"] = power_status * (1.0 - consumed_power_percentage)
	return {
		"method": SOURCE_POWER_GRAPH_USE_BATTERIES_METHOD,
		"stored_expr": SOURCE_POWER_GRAPH_USE_BATTERIES_STORED_EXPR,
		"zero_guard": SOURCE_POWER_GRAPH_USE_BATTERIES_ZERO_GUARD,
		"used_expr": SOURCE_POWER_GRAPH_USE_BATTERIES_USED_EXPR,
		"consumed_percent_expr": SOURCE_POWER_GRAPH_USE_BATTERIES_CONSUMED_PERCENT_EXPR,
		"items": SOURCE_POWER_GRAPH_BATTERY_ITEMS_EXPR,
		"loop": SOURCE_POWER_GRAPH_BATTERY_LOOP_EXPR,
		"battery": SOURCE_POWER_GRAPH_BATTERY_ITEM_EXPR,
		"status_mul": SOURCE_POWER_GRAPH_USE_BATTERIES_STATUS_MUL_EXPR,
		"return_expr": SOURCE_POWER_GRAPH_USE_BATTERIES_RETURN_EXPR,
		"mathf_equal": SOURCE_POWER_GRAPH_MATHF_EQUAL_EXPR,
		"needed": needed,
		"stored": stored,
		"used": used,
		"consumed_power_percentage": consumed_power_percentage,
		"zero_guard_returned": zero_guard_returned,
		"batteries": source_batteries,
	}

static func charge_batteries_state(batteries: Array, excess: float) -> Dictionary:
	var source_batteries: Array = []
	for battery in batteries:
		if typeof(battery) != TYPE_DICTIONARY:
			continue
		source_batteries.append(battery.duplicate(true))
	var capacity_state := battery_state(source_batteries)
	var capacity := float(capacity_state.get("capacity", 0.0))
	var charged_percent := 0.0
	var charged := 0.0
	var zero_guard_returned: bool = abs(capacity - 0.0) <= SOURCE_FLOAT_ROUNDING_ERROR
	if not zero_guard_returned:
		charged_percent = min(excess / capacity, 1.0)
		charged = min(excess, capacity)
		for source_battery_state in source_batteries:
			var source_capacity := float(source_battery_state.get("capacity", 0.0))
			if bool(source_battery_state.get("enabled", false)) and source_capacity > 0.0:
				var power_status := float(source_battery_state.get("power_status", 0.0))
				source_battery_state["power_status"] = power_status + (1.0 - power_status) * charged_percent
	return {
		"method": SOURCE_POWER_GRAPH_CHARGE_BATTERIES_METHOD,
		"capacity_expr": SOURCE_POWER_GRAPH_CHARGE_BATTERIES_CAPACITY_EXPR,
		"charged_percent_comment": SOURCE_POWER_GRAPH_CHARGE_BATTERIES_COMMENT,
		"charged_percent_expr": SOURCE_POWER_GRAPH_CHARGE_BATTERIES_CHARGED_PERCENT_EXPR,
		"zero_guard": SOURCE_POWER_GRAPH_CHARGE_BATTERIES_ZERO_GUARD,
		"items": SOURCE_POWER_GRAPH_BATTERY_ITEMS_EXPR,
		"loop": SOURCE_POWER_GRAPH_BATTERY_LOOP_EXPR,
		"battery": SOURCE_POWER_GRAPH_BATTERY_ITEM_EXPR,
		"todo": SOURCE_POWER_GRAPH_CHARGE_BATTERIES_TODO,
		"guard": SOURCE_POWER_GRAPH_CHARGE_BATTERIES_GUARD,
		"status_add": SOURCE_POWER_GRAPH_CHARGE_BATTERIES_STATUS_ADD_EXPR,
		"return_expr": SOURCE_POWER_GRAPH_CHARGE_BATTERIES_RETURN_EXPR,
		"mathf_equal": SOURCE_POWER_GRAPH_MATHF_EQUAL_EXPR,
		"excess": excess,
		"capacity": capacity,
		"charged_percent": charged_percent,
		"charged": charged,
		"zero_guard_returned": zero_guard_returned,
		"batteries": source_batteries,
	}

static func distribute_power_state(consumers: Array, needed: float, produced: float, charged: bool, last_power_stored: float) -> Dictionary:
	var source_consumers: Array = []
	for consumer in consumers:
		if typeof(consumer) != TYPE_DICTIONARY:
			continue
		source_consumers.append(consumer.duplicate(true))
	var needed_zero: bool = abs(needed) <= SOURCE_FLOAT_ROUNDING_ERROR
	var produced_zero: bool = abs(produced) <= SOURCE_FLOAT_ROUNDING_ERROR
	var last_power_stored_zero: bool = abs(last_power_stored) <= SOURCE_FLOAT_ROUNDING_ERROR
	var coverage := 0.0
	if needed_zero and produced_zero and not charged and last_power_stored_zero:
		coverage = 0.0
	elif needed_zero:
		coverage = 1.0
	else:
		coverage = min(1.0, produced / needed)
	var buffered_count := 0
	var unbuffered_count := 0
	var nan_guard_count := 0
	for consumer_state in source_consumers:
		var buffered := bool(consumer_state.get("buffered", false))
		var capacity := float(consumer_state.get("capacity", 0.0))
		var delta := float(consumer_state.get("delta", 0.0))
		var power_status := float(consumer_state.get("power_status", 0.0))
		if buffered:
			buffered_count += 1
			if abs(capacity) > SOURCE_FLOAT_ROUNDING_ERROR:
				var requested_power := float(consumer_state.get("requested_power", 0.0))
				var maximum_rate := requested_power * coverage * delta
				consumer_state["maximum_rate"] = maximum_rate
				consumer_state["power_status"] = clamp(power_status + maximum_rate / capacity, 0.0, 1.0)
			continue
		unbuffered_count += 1
		if bool(consumer_state.get("shouldConsumePower", false)):
			consumer_state["power_status"] = coverage
		else:
			var usage := float(consumer_state.get("usage", 0.0))
			var denominator := needed + usage * delta
			var estimated_status := 0.0
			var estimate_nan := false
			if abs(denominator) <= SOURCE_FLOAT_ROUNDING_ERROR:
				if abs(produced) <= SOURCE_FLOAT_ROUNDING_ERROR:
					estimate_nan = true
				elif produced > 0.0:
					estimated_status = 1.0
				else:
					estimated_status = -INF
			else:
				estimated_status = min(1.0, produced / denominator)
			if estimate_nan or is_nan(estimated_status):
				estimated_status = 0.0
				nan_guard_count += 1
			consumer_state["power_status"] = estimated_status
	return {
		"method": SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_METHOD,
		"coverage_expr": SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_COVERAGE_EXPR,
		"items": SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_ITEMS_EXPR,
		"loop": SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_LOOP_EXPR,
		"consumer": SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_CONSUMER_EXPR,
		"cons": SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_CONS_EXPR,
		"buffered_gate": SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_BUFFERED_GUARD,
		"capacity_zero_guard": SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_CAPACITY_ZERO_GUARD,
		"maximum_rate_expr": SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_MAXIMUM_RATE_EXPR,
		"buffered_status_clamp": SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_BUFFERED_STATUS_CLAMP_EXPR,
		"unbuffered_gate": SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_UNBUFFERED_GUARD,
		"unbuffered_coverage_status": SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_UNBUFFERED_COVERAGE_STATUS_EXPR,
		"unbuffered_estimate_status": SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_UNBUFFERED_ESTIMATE_EXPR,
		"nan_guard": SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_NAN_GUARD,
		"nan_status_zero": SOURCE_POWER_GRAPH_DISTRIBUTE_POWER_NAN_STATUS_ZERO_EXPR,
		"mathf_zero": SOURCE_POWER_GRAPH_MATHF_ZERO_EXPR,
		"mathf_clamp": SOURCE_POWER_GRAPH_MATHF_CLAMP_EXPR,
		"needed": needed,
		"produced": produced,
		"charged": charged,
		"last_power_stored": last_power_stored,
		"coverage": coverage,
		"consumers": source_consumers,
		"buffered_count": buffered_count,
		"unbuffered_count": unbuffered_count,
		"nan_guard_count": nan_guard_count,
	}

static func update_battery_distribute_state(consumers: Array, producers: Array, batteries: Array, power_needed: float, power_produced: float, last_power_produced: float, last_power_stored: float) -> Dictionary:
	var source_consumers: Array = []
	for consumer in consumers:
		if typeof(consumer) != TYPE_DICTIONARY:
			continue
		source_consumers.append(consumer.duplicate(true))
	var source_producers: Array = []
	for producer in producers:
		if typeof(producer) != TYPE_DICTIONARY:
			continue
		source_producers.append(producer.duplicate(true))
	var source_batteries: Array = []
	for battery in batteries:
		if typeof(battery) != TYPE_DICTIONARY:
			continue
		source_batteries.append(battery.duplicate(true))
	var branch_entered: bool = not (source_consumers.is_empty() and source_producers.is_empty() and source_batteries.is_empty())
	var charged := false
	var power_battery_used := 0.0
	var power_battery_charged := 0.0
	var next_power_produced := power_produced
	var next_last_power_produced := last_power_produced
	var coverage := 0.0
	if branch_entered:
		if abs(power_needed - next_power_produced) > SOURCE_FLOAT_ROUNDING_ERROR:
			if power_needed > next_power_produced:
				var use_state := use_batteries_state(source_batteries, power_needed - next_power_produced)
				power_battery_used = float(use_state.get("used", 0.0))
				source_batteries = use_state.get("batteries", source_batteries)
				next_power_produced += power_battery_used
				next_last_power_produced += power_battery_used
			elif next_power_produced > power_needed:
				charged = true
				var charge_state := charge_batteries_state(source_batteries, next_power_produced - power_needed)
				power_battery_charged = float(charge_state.get("charged", 0.0))
				source_batteries = charge_state.get("batteries", source_batteries)
				next_power_produced -= power_battery_charged
		var distribute_state := distribute_power_state(source_consumers, power_needed, next_power_produced, charged, last_power_stored)
		source_consumers = distribute_state.get("consumers", source_consumers)
		coverage = float(distribute_state.get("coverage", 0.0))
	return {
		"method": SOURCE_POWER_GRAPH_UPDATE_METHOD,
		"nonempty_guard": SOURCE_POWER_GRAPH_UPDATE_NONEMPTY_GUARD,
		"charged_init": SOURCE_POWER_GRAPH_UPDATE_CHARGED_INIT,
		"unequal_guard_expr": SOURCE_POWER_GRAPH_UPDATE_UNEQUAL_GUARD,
		"deficit_gate": SOURCE_POWER_GRAPH_UPDATE_DEFICIT_GATE,
		"power_battery_used_expr": SOURCE_POWER_GRAPH_UPDATE_POWER_BATTERY_USED_EXPR,
		"power_produced_battery_add_expr": SOURCE_POWER_GRAPH_UPDATE_POWER_PRODUCED_BATTERY_ADD_EXPR,
		"last_power_produced_battery_add_expr": SOURCE_POWER_GRAPH_UPDATE_LAST_POWER_PRODUCED_BATTERY_ADD_EXPR,
		"surplus_gate": SOURCE_POWER_GRAPH_UPDATE_SURPLUS_GATE,
		"charged_true_expr": SOURCE_POWER_GRAPH_UPDATE_CHARGED_TRUE_EXPR,
		"power_produced_charge_sub_expr": SOURCE_POWER_GRAPH_UPDATE_POWER_PRODUCED_CHARGE_SUB_EXPR,
		"distribute_power_expr": SOURCE_POWER_GRAPH_UPDATE_DISTRIBUTE_POWER_EXPR,
		"mathf_equal": SOURCE_POWER_GRAPH_MATHF_EQUAL_EXPR,
		"branch_entered": branch_entered,
		"charged": charged,
		"power_battery_used": power_battery_used,
		"power_battery_charged": power_battery_charged,
		"power_needed": power_needed,
		"power_produced": next_power_produced,
		"last_power_produced": next_last_power_produced,
		"last_power_stored": last_power_stored,
		"coverage": coverage,
		"consumers": source_consumers,
		"producers": source_producers,
		"batteries": source_batteries,
	}
