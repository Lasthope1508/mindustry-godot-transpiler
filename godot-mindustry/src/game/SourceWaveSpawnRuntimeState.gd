extends RefCounted
class_name SourceWaveSpawnRuntimeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const SOURCE_SPAWN_GROUP_GET_SPAWNED_BEGIN_END_EXPR := "if(wave < begin || wave > end || (wave - begin) % spacing != 0){"
const SOURCE_SPAWN_GROUP_GET_SPAWNED_AMOUNT_EXPR := "return Math.min(unitAmount + (int)(((wave - begin) / spacing) / unitScaling), max);"
const SOURCE_WAVE_SPAWNER_WAVE_ZERO_EXPR := "int spawned = group.getSpawned(state.wave - 1);"

const SPAWN_GROUP_BEGIN_DEFAULT := 0
const SPAWN_GROUP_END_DEFAULT := 999999999
const SPAWN_GROUP_SPACING_DEFAULT := 1
const SPAWN_GROUP_UNIT_AMOUNT_DEFAULT := 1
const SPAWN_GROUP_UNIT_SCALING_DEFAULT := 1.0
const SPAWN_GROUP_MAX_DEFAULT := 60

static func spawned_for_wave_state(group: Dictionary, wave_zero: int) -> Dictionary:
	var begin := int(group.get("begin", SPAWN_GROUP_BEGIN_DEFAULT))
	var end := int(group.get("end", SPAWN_GROUP_END_DEFAULT))
	var spacing: int = max(1, int(group.get("spacing", SPAWN_GROUP_SPACING_DEFAULT)))
	var unit_amount := int(group.get("unitAmount", SPAWN_GROUP_UNIT_AMOUNT_DEFAULT))
	var unit_scaling: float = max(float(group.get("unitScaling", SPAWN_GROUP_UNIT_SCALING_DEFAULT)), 0.0001)
	var max_amount := int(group.get("max", SPAWN_GROUP_MAX_DEFAULT))
	var eligible: bool = wave_zero >= begin and wave_zero <= end and (wave_zero - begin) % spacing == 0
	var spawned: int = 0
	if eligible:
		spawned = min(unit_amount + int((float(wave_zero - begin) / float(spacing)) / unit_scaling), max_amount)
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_WAVE_SPAWNED_FOR_WAVE_STATE,
		"begin_end_expr": SOURCE_SPAWN_GROUP_GET_SPAWNED_BEGIN_END_EXPR,
		"amount_expr": SOURCE_SPAWN_GROUP_GET_SPAWNED_AMOUNT_EXPR,
		"wave": wave_zero,
		"begin": begin,
		"end": end,
		"spacing": spacing,
		"unitAmount": unit_amount,
		"unitScaling": unit_scaling,
		"max": max_amount,
		"eligible": eligible,
		"spawned": spawned,
	}

# SSOT-registered entry point for SpawnGroup.getSpawned(int) (N2449).
# The validator only discovers functions named source_*/generated_/tile_,
# and the bare spawned_for_wave_state above predates that rule (PortGame-era
# file creation; its exact name is pinned by test_playable.py), so the
# slice registers this thin source_-prefixed forward instead of renaming
# the original. Behavior is identical -- it delegates 1:1.
static func source_spawn_group_get_spawned_state(group: Dictionary, wave_zero: int) -> Dictionary:
	return spawned_for_wave_state(group, wave_zero)

# SpawnGroup.getShield(int) (N2452).
# SpawnGroup.getShield(int wave) (SpawnGroup.java:76-78): `return
# Math.max(shields + shieldScaling*(wave - begin), 0);` (:77).
# Unlike getSpawned (N2449, registration-only), this formula was
# NOT live in GD (grep `-i shield` in this file: 0-hit; grep
# `get_shield|getShield` in all of src/game/: 0-hit), so this slice
# writes the GD func new. Java `Math.max(float, int 0)` becomes GD
# `maxf(..., 0.0)` (maxf, not maxi, because the left side is a
# float; wave - begin may be negative -- the clamp to 0 is correct
# in that case too). Pure formula, no side effect; precedent
# N2123/N2297 micro-accessors.
static func source_spawn_group_get_shield_state(shields: float, shield_scaling: float, wave: int, begin: int) -> Dictionary:
	return {"shield": maxf(shields + shield_scaling * float(wave - begin), 0.0)}

static func wave_spawn_state(groups: Array, wave_index: int, fallback_unit_id: String) -> Dictionary:
	var wave_zero: int = wave_index - 1
	var spawned_groups: Array = []
	var spawn_requests: Array = []
	var request_index: int = 0
	for group_value in groups:
		var group: Dictionary = group_value if group_value is Dictionary else {}
		var spawn_state: Dictionary = spawned_for_wave_state(group, wave_zero)
		var spawned := int(spawn_state.get("spawned", 0))
		if spawned <= 0:
			continue
		var unit_id := str(group.get("unit", fallback_unit_id))
		var group_result := group.duplicate(true)
		group_result["spawned"] = spawned
		group_result["wave"] = wave_zero
		spawned_groups.append(group_result)
		for i in spawned:
			spawn_requests.append({"unit": unit_id, "index": request_index, "group": group_result.duplicate(true)})
			request_index += 1
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_WAVE_SPAWN_STATE,
		"wave_zero_expr": SOURCE_WAVE_SPAWNER_WAVE_ZERO_EXPR,
		"wave_index": wave_index,
		"wave": wave_zero,
		"groups": spawned_groups,
		"spawn_requests": spawn_requests,
	}


static func source_wave_spawn_can_spawn_state(spawn: int, position: int) -> Dictionary:
	# SpawnGroup.canSpawn(int) (SpawnGroup.java:62-64): the 1 body expr
	# only -- `return spawn == -1 || spawn == position;` (:63). `spawn`
	# is the SpawnGroup field `public int spawn = -1;`
	# (SpawnGroup.java:44, "If not -1, the unit will only spawn in
	# spawnpoints with these packed coordinates."): -1 means every
	# position. GD takes spawn + position as int inputs, never
	# packs/unpacks coords here. No call-site of canSpawn exists
	# outside SpawnGroup.java (grep: 0 hits) -- this slice ports
	# only the predicate. Precedent N2123/N2297 micro-accessors +
	# N2444 isSpawning, same pure-predicate shape.
	return {"can_spawn": spawn == -1 or spawn == position}

# SpawnGroup.toString() (N2492).
# SpawnGroup.toString() (SpawnGroup.java:159-170): a mechanical
# concatenation of exactly the 9 fields type, end, begin, spacing,
# max, unitScaling, unitAmount, effect, items, in Java order.
# TRAP: shields (:38) and shieldScaling (:40) are NOT printed --
# they appear in equals (N2457) and hashCode only. Java string
# concatenation prints a null reference as "null", an object via
# its toString(), and a float via Float.toString:
# - type is a UnitType: MappableContent.toString()
#   (MappableContent.java:16-18) is `return name;` and UnitType
#   has no override, so the type_name input is the content name
#   string itself (the N2457 name model), or null.
# - effect is a StatusEffect: StatusEffect.toString()
#   (StatusEffect.java:244-246) returns localizedName, so the
#   effect_name input is the print string itself (the N2457
#   name model), or null ("Null to disable", :47).
# - items is a single @Nullable ItemStack (:50), NOT an array:
#   ItemStack.toString() (ItemStack.java:82-84) is
#   `return item + ": " + amount;`, rendered from the N2457
#   Dictionary model {"item": <name>, "amount": <int>}, or
#   "null" when items is null.
# - unitScaling is a float: _java_float_string below applies
#   Float.toString semantics (GD str() prints the un-narrowed
#   double instead).
# The SSOT contract return_type only accepts Dictionary or
# void, so the string is returned in the one-key envelope
# (the N2365 envelope precedent, also used by the BlockPlan /
# TeamData toString slices in SourceTeamsRuntimeState).
static func source_spawn_group_to_string_state(type_name: Variant, end: int, begin: int, spacing: int, max: int, unit_scaling: float, unit_amount: int, effect_name: Variant, items: Variant) -> Dictionary:
	var type_text: String = "null" if type_name == null else str(type_name)
	var effect_text: String = "null" if effect_name == null else str(effect_name)
	var items_text: String = "null"
	if items != null:
		var stack: Dictionary = items
		items_text = str(stack.get("item", "")) + ": " + str(int(stack.get("amount", 0)))
	return {"to_string": "SpawnGroup{" + "type=" + type_text + ", end=" + str(end) + ", begin=" + str(begin) + ", spacing=" + str(spacing) + ", max=" + str(max) + ", unitScaling=" + _java_float_string(unit_scaling) + ", unitAmount=" + str(unit_amount) + ", effect=" + effect_text + ", items=" + items_text + "}"}

# Java Float.toString(float): NaN prints "NaN", infinities print
# "Infinity"/"-Infinity", zero keeps its sign ("0.0"/"-0.0"),
# and any other value prints with the shortest digit string
# that round-trips the FLOAT32 value, in plain notation on
# [1e-3, 1e7) and scientific notation (d.dddE<exp>) outside it.
# GD str() prints the un-narrowed double (the field default
# `never`, (float)Integer.MAX_VALUE, would print as
# "2147483648.0" instead of "2.1474836E9"), so the value is
# narrowed through the float32 bit pattern first and the
# digits are searched by reconstruction. The sign of zero is
# read off the float32 sign bit: String.num is NOT reliable
# for it in this build (a script's zero constants all take
# the sign of the first zero constant in the file, verified
# on Godot 4.6.2), while the bit pattern is exact.
static func _java_float_string(value: float) -> String:
	if is_nan(value):
		return "NaN"
	if is_inf(value):
		return "-Infinity" if value < 0.0 else "Infinity"
	var f: float = _float32(value)
	if f == 0.0:
		return "-0.0" if _float32_negative(value) else "0.0"
	var sign := ""
	if f < 0.0:
		sign = "-"
		f = -f
	var exp10 := int(floor(log(f) / log(10.0)))
	var mantissa: float = f / pow(10.0, float(exp10))
	while mantissa >= 10.0:
		mantissa /= 10.0
		exp10 += 1
	while mantissa < 1.0:
		mantissa *= 10.0
		exp10 -= 1
	var digits := ""
	for n in range(1, 10):
		var scaled: float = f / pow(10.0, float(exp10 - n + 1))
		var rounded: float = round(scaled)
		if rounded >= pow(10.0, float(n)):
			# Rounding carried into a new digit count
			# (9.99.. -> 10.0): only a power of ten can
			# be the shortest form then.
			if _float32(pow(10.0, float(exp10 + 1))) == f:
				digits = "1"
				exp10 += 1
				break
			continue
		if _float32(rounded * pow(10.0, float(exp10 - n + 1))) == f:
			digits = str(int(rounded))
			break
	if digits == "":
		# Unreachable for a float32 (9 significant digits
		# always round-trip); kept so the function still
		# returns a string if the search ever misses.
		digits = "0"
	if exp10 >= -3 and exp10 <= 6:
		var int_digits := exp10 + 1
		var body := ""
		if int_digits >= digits.length():
			body = digits + "0".repeat(int_digits - digits.length()) + ".0"
		elif int_digits > 0:
			body = digits.substr(0, int_digits) + "." + digits.substr(int_digits)
		else:
			body = "0." + "0".repeat(-int_digits) + digits
		return sign + body
	var mantissa_text := digits.substr(0, 1) + "." + (digits.substr(1) if digits.length() > 1 else "0")
	return sign + mantissa_text + "E" + str(exp10)

# Narrow a GDScript double to the Java float32 value it
# models, through the IEEE754 single-precision bit pattern.
static func _float32(value: float) -> float:
	var bytes := PackedByteArray()
	bytes.resize(4)
	bytes.encode_float(0, value)
	return bytes.decode_float(0)

# The sign bit of the float32 pattern (byte 3, little-endian):
# the only reliable -0.0 test in this build (see above).
static func _float32_negative(value: float) -> bool:
	var bytes := PackedByteArray()
	bytes.resize(4)
	bytes.encode_float(0, value)
	return (bytes[3] & 0x80) != 0

# SpawnGroup.equals(Object) (N2457).
# SpawnGroup.equals(Object) (SpawnGroup.java:181-190): `if(this == o)
# return true;` (:183), `if(o == null || getClass() != o.getClass())
# return false;` (:184), then the field comparison (:186-189). The
# comparison covers end, begin, spacing, max, unitScaling, shields,
# shieldScaling, unitAmount, type, effect and items ONLY -- spawn
# (:44), payloads (:46) and team (:52) are deliberately NOT
# compared. The three floats use Java Float.compare semantics
# (NaN == NaN, -0.0f < 0.0f); GD `==` gets both wrong
# (NaN != NaN, 0.0 == -0.0), so floats go through _float_compare.
# The `this == o` identity shortcut (:183) is deliberately NOT
# modelled: GDScript has no reference-identity operator for
# Dictionary, and Dictionary `==` is deep value equality -- which
# is wrong here twice over (verified on Godot 4.6.2): `==` between
# a Dictionary and a String/int is an invalid operation, and
# `{"x": 0.0} == {"x": -0.0}` is true, so the shortcut would
# short-circuit the -0.0 trap before _float_compare ever runs.
# The shortcut is unobservable anyway: the field comparison below
# returns true for a group compared with itself (Float.compare
# makes NaN == NaN, Structs.eq makes items equal to itself).
# The type guard (:184, `o == null || getClass() != o.getClass()`)
# MUST come first -- `==` against a non-Dictionary other is an
# invalid operation, so nothing may compare `other` with `group`
# before the `is Dictionary` check.
# Structs.eq(items, group.items) (arc Structs.java:12-14) delegates
# to ItemStack.equals (ItemStack.java:77-79): same item identity +
# same amount; GD models ItemStack as Dictionary {"item": <name>,
# "amount": <int>} or null. type/effect are compared by content
# name (data-driven equivalent of Java reference identity). Pure
# predicate, no side effect; precedent N2123/N2297 micro-accessors.
static func source_spawn_group_equals_state(group: Dictionary, other: Variant) -> Dictionary:
	if not (other is Dictionary):
		return {"equals": false}
	var other_group: Dictionary = other
	return {"equals": _spawn_group_fields_equal(group, other_group)}

# Java Float.compare(float, float): NaN is equal to NaN and greater
# than any other value; -0.0f is less than 0.0f; otherwise numeric.
# GD `==` cannot express either trap, so the sign of zero is read
# off String.num (verified on Godot 4.6.2: String.num(-0.0) is
# "-0.0" and String.num(0.0) is "0.0", while str() prints "0.0"
# for both and signf() returns 0.0 for both, so neither of those
# distinguishes the two zeros).
static func _float_compare(a: float, b: float) -> int:
	if is_nan(a) and is_nan(b):
		return 0
	if is_nan(a):
		return 1
	if is_nan(b):
		return -1
	if a == b:
		if _is_negative_zero(a) and not _is_negative_zero(b):
			return -1
		if _is_negative_zero(b) and not _is_negative_zero(a):
			return 1
		return 0
	return -1 if a < b else 1

static func _is_negative_zero(value: float) -> bool:
	return value == 0.0 and String.num(value).begins_with("-")

static func _spawn_group_fields_equal(group: Dictionary, other_group: Dictionary) -> bool:
	if int(group.get("end", SPAWN_GROUP_END_DEFAULT)) != int(other_group.get("end", SPAWN_GROUP_END_DEFAULT)):
		return false
	if int(group.get("begin", SPAWN_GROUP_BEGIN_DEFAULT)) != int(other_group.get("begin", SPAWN_GROUP_BEGIN_DEFAULT)):
		return false
	if int(group.get("spacing", SPAWN_GROUP_SPACING_DEFAULT)) != int(other_group.get("spacing", SPAWN_GROUP_SPACING_DEFAULT)):
		return false
	if int(group.get("max", SPAWN_GROUP_MAX_DEFAULT)) != int(other_group.get("max", SPAWN_GROUP_MAX_DEFAULT)):
		return false
	if _float_compare(float(group.get("unitScaling", SPAWN_GROUP_UNIT_SCALING_DEFAULT)), float(other_group.get("unitScaling", SPAWN_GROUP_UNIT_SCALING_DEFAULT))) != 0:
		return false
	if _float_compare(float(group.get("shields", 0.0)), float(other_group.get("shields", 0.0))) != 0:
		return false
	if _float_compare(float(group.get("shieldScaling", 0.0)), float(other_group.get("shieldScaling", 0.0))) != 0:
		return false
	if int(group.get("unitAmount", SPAWN_GROUP_UNIT_AMOUNT_DEFAULT)) != int(other_group.get("unitAmount", SPAWN_GROUP_UNIT_AMOUNT_DEFAULT)):
		return false
	if group.get("type", null) != other_group.get("type", null):
		return false
	if group.get("effect", null) != other_group.get("effect", null):
		return false
	return _item_stacks_equal(group.get("items", null), other_group.get("items", null))

# Structs.eq(items, group.items) (arc Structs.java:12-14): (a == b)
# || (a != null && a.equals(b)); ItemStack.equals(Object)
# (ItemStack.java:77-79): same object, or same item identity +
# same amount. GD models ItemStack as Dictionary {"item": <name>,
# "amount": <int>} or null; both null is equal, one null is not.
static func _item_stacks_equal(a: Variant, b: Variant) -> bool:
	if a == null and b == null:
		return true
	if a == null or b == null:
		return false
	if not (a is Dictionary) or not (b is Dictionary):
		return false
	return str(a.get("item", "")) == str(b.get("item", "")) and int(a.get("amount", 0)) == int(b.get("amount", 0))
