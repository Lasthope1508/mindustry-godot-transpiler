extends RefCounted
class_name SourceDirectionLiquidBridgeBuildState

# The DirectionLiquidBridge implementation (DirectionLiquidBridge.java:12, `public class DirectionLiquidBridge extends DirectionBridge{`): reinforced-bridge-conduit (Blocks.java:2432-2443, `reinforcedBridgeConduit = new DirectionLiquidBridge("reinforced-bridge-conduit"){{`; size 1, range 4, liquidCapacity 120f, health 250, speed 5f, graphite 8 / beryllium 20). DirectionLiquidBridge extends DirectionBridge (`public class DirectionBridge extends Block{`, DirectionBridge.java:22), NOT ItemBridge -- so no existing bridge driver matches it and no frame key exists for it; this driver is NEW, created by this slice (N2502) as a pure-only stats driver. The def sets hasPower = false (`hasPower = false;`, Blocks.java:2435) and NO consumePower -- this family has no power consumer at all, so there is no power.status fold to port. The port has NO SourceDirectionLiquidBridge* files at all yet -- no display/runtime state to lean on -- so this slice is the VERIFICATION slice (the N2304 / N2442 / N2489 / N2490 precedent): a source-backed pure returning the def's stat rows, with the CLASS defaults for an unknown def id (the N2304 fallback precedent). NO frame key, NO factory wiring, NO tick, NO advance -- those wait for later slices. Per-def stat rows live (N2502).

static func source_direction_liquid_bridge_per_def_stats_state(def_id: String) -> Dictionary:
	# The per-def stat rows (the VERIFICATION slice: the
	# values are already constants in this driver's header --
	# the N2304 / N2442 / N2489 / N2490 precedent): the def's
	# size / range / liquidCapacity / health / speed /
	# requirements for reinforced-bridge-conduit, the
	# DirectionLiquidBridge def this slice verifies
	# (Blocks.java:2432-2443), with the CLASS defaults for
	# an unknown def id (the N2304 fallback precedent).
	# The def block (each exact expr on ONE comment line,
	# the N2148 lesson):
	# `reinforcedBridgeConduit = new DirectionLiquidBridge("reinforced-bridge-conduit"){{`
	# `requirements(Category.liquid, with(Items.graphite, 8, Items.beryllium, 20));`
	# `range = 4;`
	# `liquidCapacity = 120f;`
	# `health = 250;`
	# The def sets NO size line -- size 1 is the Block class
	# default (`public int size = 1;`, Block.java:215). The
	# def sets NO speed line either -- speed 5f is the class
	# field (`public float speed = 5f;`,
	# DirectionLiquidBridge.java:15), and no method in
	# DirectionLiquidBridge.java / DirectionBridge.java
	# reads it -- the row still ports the declared field
	# value (the N2495 / N2496 speed-row precedent). The
	# class defaults live on the class + its parents:
	# DirectionLiquidBridge extends DirectionBridge
	# (`public class DirectionLiquidBridge extends DirectionBridge{`,
	# DirectionLiquidBridge.java:12) and DirectionBridge
	# extends Block (`public class DirectionBridge extends Block{`,
	# DirectionBridge.java:22):
	# `public int range = 4;`
	# `public float speed = 5f;`
	# `liquidCapacity = 20f;`
	# `public int size = 1;`
	# `public int health = -1;`
	# `public float scaledHealth = -1;`
	# `public ItemStack[] requirements = {};`
	# Range has an initializer on the PARENT
	# (DirectionBridge.java:31), so the class default is 4
	# -- the SAME as the def (the def restates the class
	# value). liquidCapacity is 20f at the CONSTRUCTOR
	# (DirectionLiquidBridge.java:26), not the Block -1f
	# sentinel (`public float liquidCapacity = -1f;`,
	# Block.java:77): Block.init() only replaces it under
	# `if(liquidCapacity < 0){` (Block.java:1407), so the
	# 20f survives init -- the effective class default is
	# 20f, NOT the 10f of a block with no liquidCapacity
	# line. Health is the -1 sentinel at the FIELD
	# (`public int health = -1;`, Block.java:190, "-1 to
	# use scaledHealth"); Block.init() resolves it --
	# `if(health == -1){` (Block.java:1378) with
	# `scaledHealth = 40;` (Block.java:1381, from
	# `public float scaledHealth = -1;`, Block.java:188)
	# and `Mathf.round(size * size * scaledHealth, 5)`
	# (Block.java:1393) -- to 40 for size 1 with no
	# requirements (the N2495 / N2496 / N2497 coordinator
	# decision: the health key carries the post-init 40).
	# An unknown def id therefore falls back to size 1,
	# range 4, liquidCapacity 20f, health 40, speed 5f,
	# and NO requirements (the Block default is the empty
	# array). reinforced-bridge-conduit is the ONLY
	# DirectionLiquidBridge def (Blocks.java:2432 is the
	# single `new DirectionLiquidBridge` call), so there
	# is no second def to fall back. The requirements dict
	# is the {item: amount} dict from the def (the N2490
	# precedent); the catalog carries the same rows as an
	# Array of {item, amount} dicts
	# (content_registry.json, reinforced-bridge-conduit)
	# plus health 250 / range 4, but NO size /
	# liquidCapacity / speed keys, so the driver reads
	# them from the def block. Key-set decision, from
	# Java: liquidPadding is NOT a row -- it is a
	# draw-only parameter (`public float liquidPadding = 1f;`,
	# DirectionLiquidBridge.java:16, read only by draw(),
	# DirectionLiquidBridge.java:46) that the def does
	# not override, so it waits for the draw slice with
	# the def's explosivenessScale / flammabilityScale
	# (`explosivenessScale = flammabilityScale = 20f/120f;`,
	# Blocks.java:2440). Pure-only: the caller reads it;
	# the tick / advance / shouldConsume pures do not
	# exist yet for this family and take these values as
	# caller-supplied inputs when they land. Per-def stat
	# rows live (N2502).
	if def_id == "reinforced-bridge-conduit":
		return {
			"size": 1,
			"range_value": 4,
			"liquid_capacity": 120.0,
			"health": 250,
			"speed": 5.0,
			"requirements": {"graphite": 8, "beryllium": 20},
		}
	return {
		"size": 1,
		"range_value": 4,
		"liquid_capacity": 20.0,
		"health": 40,
		"speed": 5.0,
		"requirements": {},
	}
