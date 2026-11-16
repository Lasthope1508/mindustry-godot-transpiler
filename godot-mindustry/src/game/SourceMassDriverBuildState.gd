extends RefCounted
class_name SourceMassDriverBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")

# The MassDriver implementation (MassDriver.java:27, `public class MassDriver extends Block{`): mass-driver (consumePower 1.75f, Blocks.java:2173, `consumePower(1.75f);`; size 3, itemCapacity 120, reload 200f, range 440f, Blocks.java:2167-2174). MassDriver extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_mass_driver_building", the wall-crafter precedent), and this slice adds the mass-driver key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceMassDriver* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile no-power skip (MassDriver.java:169, `if(efficiency <= 0f){`) gates on efficiency, so a mass driver with no power would keep rotating and firing as if power.status were 1.0.
const SOURCE_MASS_DRIVER_BUILD_IMPLEMENTATIONS := ["MassDriver"]
const SOURCE_MASS_DRIVER_BUILDING_META_KEY := "source_mass_driver_building"
# The mass-driver def/class constants (single def, Blocks.java:2167-2174):
# `size = 3;` / `itemCapacity = 120;` (against the Block default `public int itemCapacity = 10;`, Block.java:75) /
# `reload = 200f;` (the DEF reload beats the class `public float reload = 100f;`, MassDriver.java:33) /
# `range = 440f;` / `consumePower(1.75f);`; class: `public float rotateSpeed = 5f;` (MassDriver.java:29),
# `public int minDistribute = 10;` (MassDriver.java:31), `public float bulletSpeed = 5.5f;` (MassDriver.java:35),
# `public float bulletLifetime = 200f;` (MassDriver.java:36).
const SOURCE_MASS_DRIVER_ITEM_CAPACITY := 120
const SOURCE_MASS_DRIVER_RELOAD := 200.0
const SOURCE_MASS_DRIVER_RANGE := 440.0
const SOURCE_MASS_DRIVER_ROTATE_SPEED := 5.0
const SOURCE_MASS_DRIVER_MIN_DISTRIBUTE := 10
const SOURCE_MASS_DRIVER_BULLET_SPEED := 5.5
const SOURCE_MASS_DRIVER_BULLET_LIFETIME := 200.0

static func _is_mass_driver_build_implementation(implementation: String) -> bool:
	return SOURCE_MASS_DRIVER_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_mass_driver_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The mass-driver tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (MassDriver.java:27, `public class MassDriver extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# mass driver skips consumption like Java's updateConsumption
	# (BuildingComp.java:1944-1945, "everything is valid when
	# cheating"). A team with no rule keeps the false default
	# (Rules.java:328 TeamRule.cheat, default false).
	frame["block_implementation"] = block_implementation
	frame["team_id"] = team_id
	frame["rules_state"] = rules_state
	frame["cheating"] = bool(source_rules_state.source_team_cheating_state(rules_state, team_id).get("cheating", false))
	# Building.enabled (BuildingComp.java:77, `transient boolean
	# enabled = true;`) is what shouldConsume() returns
	# (BuildingComp.java:755-757), so the power graph reads it live
	# for this mass driver (N2125); the tick preserves a disabled
	# mass driver instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# A new MassDriverBuild starts unlinked and idle: `public int link = -1;` (MassDriver.java:116),
	# `public float rotation = 90;` (MassDriver.java:117), `public float reloadCounter = 0f;` (MassDriver.java:118),
	# `public DriverState state = DriverState.idle;` (MassDriver.java:119),
	# `public OrderedSet<Building> waitingShooters = new OrderedSet<>();` (MassDriver.java:121, empty),
	# and the Building.items ItemModule (frame["items"], Dictionary keyed by item name, the factory precedent).
	return {"link": -1, "rotation": 90.0, "reload_counter": 0.0, "state": "idle", "waiting_shooters": [], "items": {}, "accepts_item": false}

static func source_mass_driver_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the mass-driver frame meta key
	# ("source_mass_driver_building"). A MassDriver sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_mass_driver_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_MASS_DRIVER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_MASS_DRIVER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_MASS_DRIVER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func _to_short(value: int) -> int:
	# The Java (short) cast: truncate to the low 16 bits, then sign-extend (Point2.pack/unpack cast through short, arc Point2.java:35-42); GDScript ints are 64-bit, so the wrap is explicit.
	var truncated: int = value & 0xFFFF
	if truncated >= 0x8000:
		return truncated - 0x10000
	return truncated

static func _point2_pack(x: int, y: int) -> int:
	# Point2.pack (arc Point2.java:40-42, `return (((short)x) << 16) | (((short)y) & 0xFFFF);`).
	return (_to_short(x) << 16) | (_to_short(y) & 0xFFFF)

static func _point2_unpack(pos: int) -> Vector2i:
	# Point2.unpack (arc Point2.java:35-37, `return new Point2((short)(pos >>> 16), (short)(pos & 0xFFFF));`).
	return Vector2i(_to_short(pos >> 16), _to_short(pos & 0xFFFF))

static func _mass_driver_angles_near(a: float, b: float, margin: float) -> bool:
	# Angles.near (Angles.java:29-31, `return angleDist(a, b) < range;`) -- STRICT <, unlike
	# Angles.within (Angles.java:19-21, `return angleDist(a, b) <= margin;`). No source_angles_near
	# exists in SourceMathState (only source_angles_within), so this slice ports near locally over
	# the shared angleDist (the N2191 slerpDelta local precedent -- no separate symbol).
	return source_math_state.source_angles_angle_dist(a, b) < margin

static func _mass_driver_shooter_valid(record: Dictionary) -> bool:
	# shooterValid (MassDriver.java:342-344, `protected boolean shooterValid(Building other){` with
	# `return other instanceof MassDriverBuild entity && other.isValid() && other.efficiency > 0 && entity.block == block && entity.link == pos() && within(other, range);`).
	# NOTE: unlike linkValid, shooterValid does NOT check the team. The record is the driver-gathered
	# per-shooter snapshot (is_mass_driver / is_valid / efficiency / same_block / link_equals_self / within_range).
	return bool(record.get("is_mass_driver", false)) and bool(record.get("is_valid", false)) and float(record.get("efficiency", 0.0)) > 0.0 and bool(record.get("same_block", false)) and bool(record.get("link_equals_self", false)) and bool(record.get("within_range", false))

static func _mass_driver_link_valid(link: int, linked: Dictionary) -> bool:
	# linkValid (MassDriver.java:346-349, `protected boolean linkValid(){` with `if(link == -1) return false;`
	# and `return world.build(this.link) instanceof MassDriverBuild other && other.block == block && other.team == team && within(other, range);`):
	# the link is the config link (`public int link = -1;`, MassDriver.java:116, default -1), and the
	# linked dict carries the precomputed components (exists / is_mass_driver / same_block / same_team /
	# within_range), the N2225 partner precedent -- the SAME dict the N2237 advance reads for its has_link
	# conjunction, so this helper mirrors that conjunction exactly (the advance itself is untouched).
	# within is STRICT dst2 < range*range (Position.java:44-46, the N2229 verification):
	# `default boolean within(Position other, float dst){` delegates to
	# `default boolean within(float x, float y, float dst){` with
	# `return Mathf.dst2(getX(), getY(), x, y) < dst*dst;`; the tick computes within_range that way
	# (source_dst < link_range, range the single def 440f, `range = 440f;`, Blocks.java:2172).
	return link != -1 and bool(linked.get("exists", false)) and bool(linked.get("is_mass_driver", false)) and bool(linked.get("same_block", false)) and bool(linked.get("same_team", false)) and bool(linked.get("within_range", false))

static func source_mass_driver_accept_item_state(frame: Dictionary, item_capacity: int, linked: Dictionary) -> Dictionary:
	# The intake gate (MassDriver.java:285-288, `public boolean acceptItem(Building source, Item item){` with
	# `//mass drivers that output only cannot accept items` and
	# `return items.total() < itemCapacity && linkValid();`): two terms -- the store total under the def
	# itemCapacity (`itemCapacity = 120;`, Blocks.java:2170, against the Block default `public int itemCapacity = 10;`,
	# Block.java:75) AND linkValid() (MassDriver.java:346-349, the private helper above). The source/item
	# args are ignored by Java -- the gate is capacity + link only -- so the pure takes no source/item
	# inputs. The store total reads through the shared drill inventory helper (never a hand-rolled total).
	# The driver has no intake path of its own -- the only acceptItem mentions are the neighbour arrays
	# the N2294 dump reads as frame inputs -- so there is no call site to wire the gate INTO; the tick
	# stamps the verdict on the frame as accepts_item every tick after the dump write-back (the N2295
	# Loader acceptPayload precedent), reading the post-tick store and the same linked dict the advance
	# reads, so neighbour intake queries (dump paths consult acceptItem, BuildingComp.java:1088,
	# `if(other.acceptItem(self(), item) && canDump(other, item)){`) can consult it. No live neighbour
	# reads it yet (see DEFERRED -- the MassDriver frame items intake entry).
	var link: int = int(frame.get("link", -1))
	var items_total: int = inventory.items_total(frame.get("items", {}))
	var accepts: bool = items_total < item_capacity and _mass_driver_link_valid(link, linked)
	return {"accepts": accepts}

static func source_mass_driver_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, item_capacity: int, reload: float, rotate_speed: float, min_distribute: int, bullet_speed: float, bullet_lifetime: float, tile_pos: int, self_x: float, self_y: float, linked: Dictionary, shooters: Dictionary, item_order: Array) -> Dictionary:
	# The updateTile advance (MassDriverBuild.updateTile(), MassDriver.java:133-221,
	# `public void updateTile(){`, + fire(), MassDriver.java:290-317), on
	# `public class MassDriver extends Block{` (MassDriver.java:27) /
	# `public class MassDriverBuild extends Building implements RotBlock{` (MassDriver.java:115).
	# Build fields: `public int link = -1;` (MassDriver.java:116),
	# `public float rotation = 90;` (MassDriver.java:117),
	# `public float reloadCounter = 0f;` (MassDriver.java:118),
	# `public DriverState state = DriverState.idle;` (MassDriver.java:119),
	# `public OrderedSet<Building> waitingShooters = new OrderedSet<>();` (MassDriver.java:121).
	# Class fields: `public float range;` (MassDriver.java:28, def `range = 440f;`, Blocks.java:2172),
	# `public float rotateSpeed = 5f;` (MassDriver.java:29),
	# `public int minDistribute = 10;` (MassDriver.java:31),
	# `public float reload = 100f;` (MassDriver.java:33, the DEF `reload = 200f;`, Blocks.java:2171, wins),
	# `public float bulletSpeed = 5.5f;` (MassDriver.java:35),
	# `public float bulletLifetime = 200f;` (MassDriver.java:36),
	# `itemCapacity = 120;` (Blocks.java:2170), `consumePower(1.75f);` (Blocks.java:2173).
	# Java order, step by step. `Building link = world.build(this.link);` / `boolean hasLink = linkValid();`
	# (MassDriver.java:134-135); `if(hasLink){` / `this.link = link.pos();` (MassDriver.java:137-139).
	# linkValid (MassDriver.java:346-349, `protected boolean linkValid(){` with `if(link == -1) return false;`
	# and `return world.build(this.link) instanceof MassDriverBuild other && other.block == block && other.team == team && within(other, range);`):
	# the linked dict carries the precomputed components (exists / is_mass_driver / same_block / same_team /
	# within_range), the N2225 partner precedent; within is STRICT dst2 < range*range (Position.java:44-46,
	# the N2229 verification). The link is a CONFIG link (player set through the config handlers,
	# `config(Point2.class, (MassDriverBuild tile, Point2 point) -> tile.link = Point2.pack(point.x + tile.tileX(), point.y + tile.tileY()));` (MassDriver.java:58)
	# and `config(Integer.class, (MassDriverBuild tile, Integer point) -> tile.link = point);` (MassDriver.java:59)) --
	# the port has no config UI, so link is a frame key (default -1) and live config fill defers.
	# Reload, regardless of state (MassDriver.java:142-144): `reloadCounter = Mathf.clamp(reloadCounter - edelta() / reload);`
	# -- the one-arg Mathf.clamp clamps to [0, 1] (arc Mathf.java:402-404, `return Math.max(Math.min(value, 1f), 0f);`).
	# `var current = currentShooter();` (MassDriver.java:146, first of waitingShooters, null when empty);
	# `if(current != null && !shooterValid(current)){` / `waitingShooters.remove(current);` (MassDriver.java:149-150) --
	# only the FIRST entry is cleaned, once per tick. waitingShooters is an OrderedSet: the port uses a list
	# keeping insertion order. shooterValid is the private helper above (MassDriver.java:342-344).
	# State switch (MassDriver.java:154-161): `if(state == DriverState.idle){` /
	# `if(!waitingShooters.isEmpty() && (itemCapacity - items.total() >= minDistribute)){` / `state = DriverState.accepting;`
	# (MassDriver.java:156-157) else if hasLink `state = DriverState.shooting;` (MassDriver.java:159).
	# `dumpAccumulate();` (MassDriver.java:164-166, idle or accepting) is live since N2294 through the
	# pure source_mass_driver_dump_state function, driven from the tick AFTER the advance with the
	# post-switch state (state_after_switch, returned here): Java dumps between the switch and the
	# no-power skip, so the dump gate reads the state the switch just produced -- NOT the final state,
	# which the accepting/shooting branches below may flip back to idle (a shooting driver that fires
	# ends idle but must NOT dump). The dump runs even when efficiency is 0 (the gate sits before the
	# no-power skip, MassDriver.java:168-171), and the only branch below that mutates items is fire(),
	# which runs only while shooting -- so running the dump after the advance sees the same store Java
	# dumps from in every dump-eligible state. The neighbour acceptItem / canDump arrays are frame
	# inputs (default []), and the dumped item is not written into the neighbour frame yet.
	# No-power skip (MassDriver.java:169-171): `if(efficiency <= 0f){` / `return;` -- the reload decay and the
	# state switch above already ran; the rotation / fire below never run.
	# Accepting (MassDriver.java:173-182): `if(currentShooter() == null || (itemCapacity - items.total() < minDistribute)){`
	# / `state = DriverState.idle;` / `return;` (MassDriver.java:175-177, the current shooter is re-queried AFTER
	# the cleanup) else `rotation = Angles.moveToward(rotation, angleTo(currentShooter()), rotateSpeed * efficiency);`
	# (MassDriver.java:181). A missing shooter record means the shooter sprite is gone: Java would rotate toward
	# its stale position for one tick, the port keeps the rotation (the entry is cleaned next tick when first).
	# Shooting (MassDriver.java:182-220): `}else if(state == DriverState.shooting){` /
	# `if(!hasLink || (!waitingShooters.isEmpty() && (itemCapacity - items.total() >= minDistribute))){`
	# / `state = DriverState.idle;` / `return;` (MassDriver.java:184-186); `float targetRotation = angleTo(link);`
	# (MassDriver.java:187); `items.total() >= minDistribute` and `link.block.itemCapacity - link.items.total() >= minDistribute`
	# (MassDriver.java:189-190, self stock and LINK space, the linked block itemCapacity) then
	# `MassDriverBuild other = (MassDriverBuild)link;` / `other.waitingShooters.add(this);` (MassDriver.java:195-196,
	# the cross-building write-back -- the OrderedSet add is a no-op on duplicates, and the driver writes the
	# returned partner_waiting_shooters back onto the linked frame, the N2225 precedent).
	# `if(reloadCounter <= 0.0001f){` (MassDriver.java:198):
	# `rotation = Angles.moveToward(rotation, targetRotation, rotateSpeed * efficiency);` (MassDriver.java:201),
	# then the fire gate (MassDriver.java:204-206): `if(other.currentShooter() == this &&` /
	# `other.state == DriverState.accepting &&` / `Angles.near(rotation, targetRotation, 2f) && Angles.near(other.rotation, targetRotation + 180f, 2f)){` --
	# other.currentShooter() is the first of the UPDATED partner list (after the add above), the rotation check
	# uses the rotation AFTER this tick's moveToward, and Angles.near is STRICT < (the local helper above).
	# `fire(other);` (MassDriver.java:207) then `state = DriverState.idle;` (MassDriver.java:216).
	# `float timeToArrive = Math.min(bulletLifetime / timeScale, dst(other) / (bulletSpeed * timeScale));` /
	# `Time.run(timeToArrive, () -> {` (MassDriver.java:209-210) with `other.waitingShooters.remove(this);` /
	# `other.state = DriverState.idle;` (MassDriver.java:212-213) DEFERS -- no Time.run in the port.
	# fire() (MassDriver.java:290-317, `protected void fire(MassDriverBuild target){`): `reloadCounter = 1f;`
	# (MassDriver.java:292); `for(int i = 0; i < content.items().size; i++){` (MassDriver.java:298, content-id
	# order -- the catalog item_names_by_id, the N2225 take precedent) with
	# `int maxTransfer = Math.min(items.get(content.item(i)), tile.block().itemCapacity - totalUsed);`
	# (MassDriver.java:299, capped by the SELF block itemCapacity minus totalUsed) /
	# `totalUsed += maxTransfer;` (MassDriver.java:301) / `items.remove(content.item(i), maxTransfer);`
	# (MassDriver.java:302, the items LEAVE the self frame the moment they fire -- the bullet carries them;
	# ItemModule.remove clamps, `amount = Math.min(amount, items[item.id]);`, ItemModule.java:258-259, and the
	# shared remove_item_state clamps the same way); the bullet params are
	# `totalUsed/2f, bulletSpeed * timeScale, bulletLifetime / timeScale` (MassDriver.java:309, damage is
	# totalUsed/2f FLOAT division). The bullet entity creation (MassDriverBolt) defers -- no live bullet in the
	# port -- so the pure advance returns fired_items + fired_total + bullet_damage + bullet_speed +
	# bullet_lifetime as pure results. handlePayload (MassDriver.java:319-340,
	# `public void handlePayload(Bullet bullet, DriverBulletData data){`) is NOT updateTile and defers.
	# delta() is `return Time.delta * timeScale;` (BuildingComp.java:1922-1924) and edelta() is
	# `return efficiency * delta();` (BuildingComp.java:1927-1929); source_delta is Time.delta in ticks
	# (seconds * 60 through game_source_delta, arc Time.java:26), never raw seconds; timeScale reads
	# `private transient float timeScale = 1f, timeScaleDuration;` (BuildingComp.java:98); efficiency is
	# `transient float efficiency;` (BuildingComp.java:85), default 0.0. The advance runs after consumption,
	# like Java's Building.update() (BuildingComp.java:2274-2277, `updateConsumption();` then
	# `if(enabled || !block.noUpdateDisabled){` / `updateTile();`), and MassDriver has
	# `public boolean noUpdateDisabled = false;` (Block.java:170, the default), so Java runs updateTile()
	# even when disabled (the N2231 precedent). Returns the advanced self values plus the partner
	# waiting list (partner_waiting_shooters) plus the fire report (fired / fired_items / fired_total /
	# bullet_damage / bullet_speed / bullet_lifetime); the driver writes both frames back. When nothing
	# fires the bullet fields are 0 and fired_items is empty.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var link: int = int(frame.get("link", -1))
	var rotation: float = float(frame.get("rotation", 90.0))
	var reload_counter: float = float(frame.get("reload_counter", 0.0))
	var state: String = str(frame.get("state", "idle"))
	var waiting_shooters: Array = (frame.get("waiting_shooters", []) as Array).duplicate(true)
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var partner_waiting_shooters: Array = (linked.get("waiting_shooters", []) as Array).duplicate(true)
	var delta: float = source_delta * time_scale
	var edelta: float = efficiency * delta
	var has_link: bool = link != -1 and bool(linked.get("exists", false)) and bool(linked.get("is_mass_driver", false)) and bool(linked.get("same_block", false)) and bool(linked.get("same_team", false)) and bool(linked.get("within_range", false))
	if has_link:
		link = int(linked.get("pos", link))
	if reload_counter > 0.0:
		reload_counter = clampf(reload_counter - edelta / reload, 0.0, 1.0)
	var current: Variant = waiting_shooters[0] if not waiting_shooters.is_empty() else null
	if current != null:
		var current_record: Variant = shooters.get(int(current), null)
		if current_record == null or not _mass_driver_shooter_valid(current_record):
			waiting_shooters.remove_at(0)
	var items_total: int = inventory.items_total(items)
	if state == "idle":
		if not waiting_shooters.is_empty() and item_capacity - items_total >= min_distribute:
			state = "accepting"
		elif has_link:
			state = "shooting"
	# The post-switch state (N2294): the dump gate (MassDriver.java:164-166) reads the state the
	# switch just produced, before the accepting/shooting branches below -- the advance returns it
	# as state_after_switch so the tick can drive source_mass_driver_dump_state with it.
	var state_after_switch: String = state
	var fired: bool = false
	var fired_items: Dictionary = {}
	var fired_total: int = 0
	var bullet_damage: float = 0.0
	var fired_bullet_speed: float = 0.0
	var fired_bullet_lifetime: float = 0.0
	if efficiency > 0.0:
		if state == "accepting":
			var shooter: Variant = waiting_shooters[0] if not waiting_shooters.is_empty() else null
			if shooter == null or item_capacity - items_total < min_distribute:
				state = "idle"
			else:
				var shooter_record: Variant = shooters.get(int(shooter), null)
				if shooter_record != null:
					var shooter_angle: float = source_math_state.source_angles_angle(self_x, self_y, float(shooter_record.get("x", 0.0)), float(shooter_record.get("y", 0.0)))
					rotation = source_math_state.source_angles_move_toward(rotation, shooter_angle, rotate_speed * efficiency)
		elif state == "shooting":
			if not has_link or (not waiting_shooters.is_empty() and item_capacity - items_total >= min_distribute):
				state = "idle"
			else:
				var target_rotation: float = source_math_state.source_angles_angle(self_x, self_y, float(linked.get("x", 0.0)), float(linked.get("y", 0.0)))
				if items_total >= min_distribute and int(linked.get("item_capacity", 0)) - int(linked.get("items_total", 0)) >= min_distribute:
					if not partner_waiting_shooters.has(tile_pos):
						partner_waiting_shooters.append(tile_pos)
					if reload_counter <= 0.0001:
						rotation = source_math_state.source_angles_move_toward(rotation, target_rotation, rotate_speed * efficiency)
						var partner_current: Variant = partner_waiting_shooters[0] if not partner_waiting_shooters.is_empty() else null
						if partner_current != null and int(partner_current) == tile_pos and str(linked.get("state", "idle")) == "accepting" and _mass_driver_angles_near(rotation, target_rotation, 2.0) and _mass_driver_angles_near(float(linked.get("rotation", 90.0)), target_rotation + 180.0, 2.0):
							reload_counter = 1.0
							var total_used: int = 0
							for item_name in item_order:
								var held: int = inventory.item_count(items, str(item_name))
								var max_transfer: int = mini(held, item_capacity - total_used)
								if max_transfer > 0:
									fired_items[str(item_name)] = max_transfer
									var removed: Dictionary = inventory.remove_item_state(items, str(item_name), max_transfer)
									items = removed.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, items)
									total_used += max_transfer
							fired = true
							fired_total = total_used
							bullet_damage = total_used / 2.0
							fired_bullet_speed = bullet_speed * time_scale
							fired_bullet_lifetime = bullet_lifetime / time_scale
							state = "idle"
	return {"link": link, "rotation": rotation, "reload_counter": reload_counter, "state": state, "state_after_switch": state_after_switch, "waiting_shooters": waiting_shooters, "items": items, "partner_waiting_shooters": partner_waiting_shooters, "fired": fired, "fired_items": fired_items, "fired_total": fired_total, "bullet_damage": bullet_damage, "bullet_speed": fired_bullet_speed, "bullet_lifetime": fired_bullet_lifetime}

static func source_mass_driver_dump_state(frame: Dictionary, state_after_switch: String, source_delta: float, time_scale: float, content_item_ids: Array, neighbour_accepts_item: Array, neighbour_can_dump: Array) -> Dictionary:
	# The dumpAccumulate dump (MassDriverBuild.updateTile(), MassDriver.java:163-166):
	# `//dump when idle or accepting`
	# `if(state == DriverState.idle || state == DriverState.accepting){`
	# `dumpAccumulate();`
	# -- between the state switch (MassDriver.java:154-161, `if(state == DriverState.idle){` /
	# `state = DriverState.accepting;` / `state = DriverState.shooting;`) and the no-power skip
	# (MassDriver.java:168-171):
	# `if(efficiency <= 0f){`
	# so the dump runs even when efficiency is 0 -- the pure takes no efficiency input at all, and
	# the tick calls it unconditionally after the advance. And dumpAccumulate() is only CALLED while
	# idle or accepting, so the accumulator does NOT grow while shooting: the pure gates the whole
	# accumulation on the post-switch state (state_after_switch, returned by the N2237 advance --
	# NOT the final state, which the accepting/shooting branches may flip back to idle: a shooting
	# driver that fires ends idle but must NOT dump, and the accepting branch may flip accepting
	# back to idle while the dump still fires). The accumulator is the Building field at its Java
	# default (`private transient float dumpAccum;`, BuildingComp.java:99, 0.0), carried as the
	# frame key dump_accum. dumpAccumulate() delegates to dumpAccumulate(null)
	# (BuildingComp.java:1048-1050):
	# `public boolean dumpAccumulate(){`
	# `return dumpAccumulate(null);`
	# and dumpAccumulate(Item) (BuildingComp.java:1053-1061) accumulates and dumps in a while loop
	# -- possibly MULTIPLE times per tick:
	# `public boolean dumpAccumulate(Item item){`
	# `boolean res = false;`
	# `dumpAccum += delta();`
	# `while(dumpAccum >= 1f){`
	# `res |= dump(item);`
	# `dumpAccum -=1f;`
	# The attempt count + remainder come from the shared helper (SourceBuildingItemDumpState.
	# dump_accumulate_state, which the bridge source_dump_accumulate_attempt_state delegates to;
	# the bridge method is an instance method, so the static pure calls the underlying static
	# directly -- the same function, no duplication, no helper modified), then each attempt routes
	# through the shared dump(null) port. delta() is `Time.delta * timeScale`
	# (BuildingComp.java:1922-1924):
	# `public float delta(){`
	# `return Time.delta * timeScale;`
	# so the accumulator grows by source_delta * time_scale (the N2237 advance precedent);
	# source_delta is Time.delta in ticks (seconds * 60 through game_source_delta, arc
	# Time.java:26), never raw seconds; timeScale reads `private transient float timeScale = 1f,
	# timeScaleDuration;` (BuildingComp.java:98). dump() (BuildingComp.java:1064-1066):
	# `public boolean dump(){`
	# `return dump(null);`
	# delegates to dump(null) (BuildingComp.java:1072-1114):
	# `public boolean dump(Item todump){`
	# `if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;`
	# `int dump = this.cdump;`
	# `var allItems = content.items();`
	# `int itemSize = allItems.size;`
	# `if(todump == null){`
	# `Building other = proximity.get((i + dump) % proximity.size);`
	# `if(!items.has(ii)) continue;`
	# `Item item = (Item)itemArray[ii];`
	# `if(other.acceptItem(self(), item) && canDump(other, item)){`
	# `other.handleItem(self(), item);`
	# `items.remove(item, 1);`
	# `incrementDump(proximity.size);`
	# -- neighbours outer, content items inner: for each neighbour from the cdump cursor, the first
	# held item in content order an accepting neighbour takes is handed over, 1 leaves the store,
	# and the cursor advances once per neighbour checked (incrementDump, BuildingComp.java:1116-1120):
	# `public void incrementDump(int prox){`
	# `if(prox != 0){`
	# `cdump = ((cdump + 1) % prox);`
	# The cursor is a Building field at its Java default: `transient int cdump;`
	# (BuildingComp.java:68, 0). The mass driver has items (`hasItems = true;`, MassDriver.java:51),
	# so the hasItems guard always passes. canDump defaults to true
	# (`public boolean canDump(Building to, Item item){`, BuildingComp.java:1124-1126); the
	# neighbour arrays carry the live per-neighbour answers as frame inputs. The dump itself runs
	# through the shared dump(null) port (SourceBuildingItemDumpState.dump_item_state) -- NOT the
	# putItem gate game_put_item_state, which dumps one SPECIFIC item and needs a game object for
	# its increment callbacks, while dumpAccumulate calls dump(). The shared port reports the
	# handled neighbour but does not write the item into the neighbour frame -- the write-back
	# waits for its own slice. A failed attempt still consumes its 1f of accumulator (Java calls
	# dump() inside the while loop whether or not it succeeds), and an attempt with an empty store
	# or no neighbours guards inside dump_item_state and dumps nothing.
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var dump_accum: float = float(frame.get("dump_accum", 0.0))
	var cursor: int = int(frame.get("cdump", 0))
	var dumped := false
	if state_after_switch == "idle" or state_after_switch == "accepting":
		var delta: float = source_delta * time_scale
		var attempt: Dictionary = source_building_item_dump_state.dump_accumulate_state(dump_accum, delta)
		dump_accum = float(attempt.get("dump_accum", dump_accum))
		var attempts: int = int(attempt.get("dump_attempts", 0))
		for _attempt in range(attempts):
			var amounts: Array = []
			for item_id in content_item_ids:
				amounts.append(int(items.get(str(item_id), 0)))
			var result: Dictionary = source_building_item_dump_state.dump_item_state(true, inventory.items_total(items), neighbour_accepts_item.size(), null, false, content_item_ids, amounts, neighbour_accepts_item, neighbour_can_dump, cursor)
			cursor = int(result.get("cdump", cursor))
			if bool(result.get("dumped", false)):
				dumped = true
				var amounts_after: Array = result.get("item_amounts_by_index", amounts)
				for j in range(content_item_ids.size()):
					if j < amounts_after.size():
						items[str(content_item_ids[j])] = int(amounts_after[j])
	return {"dump_accum_after": dump_accum, "dumped": dumped, "items_after": items, "cursor_after": cursor}

static func source_mass_driver_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a mass driver does not take the early return. The updateTile advance follows the folded efficiency: the no-power skip (MassDriver.java:169, `if(efficiency <= 0f){`), the rotation align (MassDriver.java:181, `rotation = Angles.moveToward(rotation, angleTo(currentShooter()), rotateSpeed * efficiency);`) and the reload drain (MassDriver.java:143, `reloadCounter = Mathf.clamp(reloadCounter - edelta() / reload);`). MassDriverBuild has no shouldConsume override, so the BuildingComp default applies (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) -- the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). The mass driver (consumePower 1.75f, Blocks.java:2173, `consumePower(1.75f);`) is its own family (MassDriver.java:27, `public class MassDriver extends Block{`; MassDriverBuild, MassDriver.java:115, `public class MassDriverBuild extends Building implements RotBlock{`) -- power-only first pass, so the folded efficiency is the min over the *modeled* consumers (power only).
	# Documented limits: (1) power-only first pass -- the mass driver's power consumer is static (consumePower 1.75f, Blocks.java:2173), so the folded efficiency is the min over the *modeled* consumers (power only). (2) shouldConsume default applies -- MassDriverBuild has no shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-757) applies; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). (3) updateTile advance live (N2237) -- link refresh / reloadCounter decay / waitingShooters cleanup / idle-accepting-shooting switch / rotation align / register + fire (MassDriver.java:133-221 + fire() :290-317) run every tick after the consumption fold through the pure source_mass_driver_update_tile_advance_state function; dumpAccumulate (:164-166) is live since N2294 (source_mass_driver_dump_state, the idle/accepting gate + the dumpAccum while loop through the shared dumpAccumulate + dump_item_state helpers, running even without power -- the gate sits before the no-power skip); the Time.run arrival cleanup (:209-214), the bullet entity creation and handlePayload (:319-340) defer -- see DEFERRED. The power proof carries no link/state/reload/fire/dump keys; the N2237 proof carries the link/state/reload/fire keys and the N2294 proof carries the dump keys. (4) No link/config / handlePayload / sense / draw / read-write rows -- see DEFERRED. (5) Single def -- no large-mass-driver def in this upstream version, so the same driver covers the whole family. (6) acceptItem live (N2336) -- the intake gate (MassDriver.java:285-288, items.total() < itemCapacity && linkValid(), MassDriver.java:346-349) runs every tick through the pure source_mass_driver_accept_item_state function and exposes the verdict on the frame as accepts_item (the N2295 Loader acceptPayload precedent), reading the post-tick store and the same linked dict the N2237 advance reads; the N2336 proof carries the accept keys. No live neighbour reads the verdict yet -- the frame items intake waits for its own slice, see DEFERRED.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_mass_driver_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the mass-driver tick wiring every
	# tick (MassDriverBuild.updateTile(), MassDriver.java:133,
	# gates on the no-power skip (MassDriver.java:169, `if(efficiency <= 0f){`), so the link/state-machine advance follows the folded efficiency; no placed-buildings driver ticks MassDriver blocks, so this driver is the placed-mass-driver tick): each placed MassDriver build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
	var results_by_cell := {}
	var ticked_count := 0
	if game == null:
		return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
	var catalog = game.get("content_catalog")
	if catalog == null:
		return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if not _is_mass_driver_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_mass_driver_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_mass_driver_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a mass driver with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the no-power skip (MassDriver.java:169)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a mass driver does not take the early return. A mass driver with no power consumer is untouched: the tick models no other consumers yet (the updateTile advance is live since N2237 and runs below, after the consumption fold), and there is no shouldConsume override (MassDriverBuild has no shouldConsume override, so the BuildingComp default, BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756, applies), so the machinery runs with should_consume=true when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_mass_driver_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		# The updateTile advance (N2237, MassDriver.java:133-221 + fire(), :290-317): runs after the
		# consumption fold -- the Java order, `updateConsumption();` then
		# `if(enabled || !block.noUpdateDisabled){` / `updateTile();` (BuildingComp.java:2274-2277) --
		# and WITHOUT an enabled guard: MassDriver has
		# `public boolean noUpdateDisabled = false;` (Block.java:170, the default), so
		# Java runs updateTile() even when disabled (the N2231 precedent: updateConsumption
		# folds efficiency to 0, so the edelta rotation / fire stall while the reload decay
		# and the state switch still run). The driver gathers the linked building snapshot
		# (the partner sprite through placed_blocks by the unpacked link cell, Point2.unpack,
		# arc Point2.java:35-37; a missing sprite or a partner that is not a MassDriver fails
		# the block match, the N2225 precedent) and the per-shooter records for every
		# waiting entry (shooterValid, MassDriver.java:342-344). World coords are cell *
		# tile_size (Vars.tilesize 8, Vars.java:135; the game tile_size when set): both
		# endpoints are size-3 mass drivers, so the block offset (Block.java:761, 0 for
		# odd sizes) cancels in the angle and the distance. within is STRICT dst2 <
		# range*range (Position.java:44-46, the N2229 verification); range reads the
		# catalog property with the def 440f default (Blocks.java:2172). same_block is
		# the MassDriver implementation match -- single def, so a MassDriver IS the same
		# block. The fire loop runs over the catalog item order (item_names_by_id, the
		# content-id order fire() iterates). The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60 (arc Time.java:26), never raw
		# seconds; timeScale reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98). The pure advance returns the advanced self values plus
		# the partner waiting list, which the driver writes back to both frames (the
		# N2225 precedent).
		var tile_size_value: Variant = game.get("tile_size")
		var tile_size: float = 8.0 if tile_size_value == null else float(tile_size_value)
		var this_pos: int = _point2_pack(cell.x, cell.y)
		var self_x: float = float(cell.x) * tile_size
		var self_y: float = float(cell.y) * tile_size
		var link_range: float = float(block.properties.get("range", SOURCE_MASS_DRIVER_RANGE))
		var link_value: int = int(frame.get("link", -1))
		var other_cell: Vector2i = _point2_unpack(link_value)
		var placed_blocks_value: Variant = game.get("placed_blocks")
		var placed_blocks: Dictionary = placed_blocks_value if placed_blocks_value is Dictionary else {}
		var other_sprite: Variant = placed_blocks.get(game.call("cell_key", other_cell))
		var other_exists: bool = other_sprite != null and is_instance_valid(other_sprite) and other_sprite is Sprite2D
		var other_is_mass_driver: bool = false
		var other_teams_match: bool = false
		var other_block: Variant = null
		var partner_frame: Dictionary = {}
		if other_exists:
			var other_block_id: String = str(other_sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
			if blocks_by_id.has(other_block_id):
				other_block = blocks_by_id[other_block_id]
				other_is_mass_driver = _is_mass_driver_build_implementation(str(other_block.implementation))
			var other_team_id: int = int(other_sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
			other_teams_match = other_team_id == team_id
			if other_is_mass_driver:
				var partner_bound: Dictionary = source_mass_driver_bind_frame_state(other_sprite, other_block)
				partner_frame = partner_bound.get("frame", {})
		var other_x: float = float(other_cell.x) * tile_size
		var other_y: float = float(other_cell.y) * tile_size
		var other_within_range: bool = other_exists and source_math_state.source_dst(self_x, self_y, other_x, other_y) < link_range
		var linked: Dictionary = {"exists": other_exists, "pos": link_value, "is_mass_driver": other_is_mass_driver, "same_block": other_is_mass_driver, "same_team": other_teams_match, "within_range": other_within_range, "item_capacity": SOURCE_MASS_DRIVER_ITEM_CAPACITY, "items_total": 0, "state": "idle", "rotation": 90.0, "waiting_shooters": [], "x": other_x, "y": other_y}
		if other_exists and other_is_mass_driver:
			linked["items_total"] = inventory.items_total(partner_frame.get("items", {}))
			linked["state"] = str(partner_frame.get("state", "idle"))
			linked["rotation"] = float(partner_frame.get("rotation", 90.0))
			linked["waiting_shooters"] = (partner_frame.get("waiting_shooters", []) as Array).duplicate(true)
		var shooters: Dictionary = {}
		for shooter_pos in frame.get("waiting_shooters", []):
			var shooter_cell: Vector2i = _point2_unpack(int(shooter_pos))
			var shooter_sprite: Variant = placed_blocks.get(game.call("cell_key", shooter_cell))
			var shooter_exists: bool = shooter_sprite != null and is_instance_valid(shooter_sprite) and shooter_sprite is Sprite2D
			var shooter_is_mass_driver: bool = false
			var shooter_efficiency: float = 0.0
			var shooter_link: int = -1
			if shooter_exists:
				var shooter_block_id: String = str(shooter_sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
				if blocks_by_id.has(shooter_block_id):
					var shooter_block = blocks_by_id[shooter_block_id]
					shooter_is_mass_driver = _is_mass_driver_build_implementation(str(shooter_block.implementation))
					if shooter_is_mass_driver:
						var shooter_bound: Dictionary = source_mass_driver_bind_frame_state(shooter_sprite, shooter_block)
						var shooter_frame: Dictionary = shooter_bound.get("frame", {})
						shooter_efficiency = float(shooter_frame.get("efficiency", 0.0))
						shooter_link = int(shooter_frame.get("link", -1))
			var shooter_x: float = float(shooter_cell.x) * tile_size
			var shooter_y: float = float(shooter_cell.y) * tile_size
			shooters[int(shooter_pos)] = {"is_mass_driver": shooter_is_mass_driver, "is_valid": shooter_exists, "efficiency": shooter_efficiency, "same_block": shooter_is_mass_driver, "link_equals_self": shooter_link == this_pos, "within_range": shooter_exists and source_math_state.source_dst(self_x, self_y, shooter_x, shooter_y) < link_range, "x": shooter_x, "y": shooter_y}
		var item_order: Array = source_content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])
		var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		var advanced: Dictionary = source_mass_driver_update_tile_advance_state(frame, source_delta, time_scale, SOURCE_MASS_DRIVER_ITEM_CAPACITY, SOURCE_MASS_DRIVER_RELOAD, SOURCE_MASS_DRIVER_ROTATE_SPEED, SOURCE_MASS_DRIVER_MIN_DISTRIBUTE, SOURCE_MASS_DRIVER_BULLET_SPEED, SOURCE_MASS_DRIVER_BULLET_LIFETIME, this_pos, self_x, self_y, linked, shooters, item_order)
		frame["link"] = advanced["link"]
		frame["rotation"] = advanced["rotation"]
		frame["reload_counter"] = advanced["reload_counter"]
		frame["state"] = advanced["state"]
		frame["waiting_shooters"] = advanced["waiting_shooters"]
		frame["items"] = advanced["items"]
		if not partner_frame.is_empty():
			partner_frame["waiting_shooters"] = advanced["partner_waiting_shooters"]
		# N2294: the dumpAccumulate dump (MassDriver.java:164-166, `//dump when idle or accepting` /
		# `if(state == DriverState.idle || state == DriverState.accepting){ dumpAccumulate(); }`)
		# runs AFTER the advance in the same tick -- the Java order is dump between the state switch
		# (:154-161) and the no-power skip (:168-171), so the dump gate reads the post-switch state
		# (advanced["state_after_switch"]), NOT the final state: a shooting driver that fires ends
		# the tick idle but must NOT dump, and the accepting branch may flip accepting back to idle
		# while the dump still fires. The dump runs even when efficiency is 0 -- the gate sits
		# BEFORE the no-power skip, so an unpowered mass driver still dumps -- and the only advance
		# branch that mutates items is fire(), which runs only while shooting, so the post-advance
		# store is the store Java dumps from in every dump-eligible state. The neighbour acceptItem
		# / canDump arrays are frame inputs (default [] -- no neighbours, the Java proximity.size
		# == 0 outcome) until a live proximity fill lands, and the dumped item is not written into
		# the neighbour frame yet (no neighbour write-back). The frame dumpAccum (frame["dump_accum"],
		# default 0.0, `private transient float dumpAccum;`, BuildingComp.java:99) accumulates only
		# while the gate is open -- dumpAccumulate() is never called while shooting, so the
		# accumulator does not grow there -- and the shared cdump cursor (frame["cdump"], default 0,
		# BuildingComp.java:68) persists back like the advance keys.
		var post_switch_state: String = str(advanced.get("state_after_switch", advanced.get("state", "idle")))
		var dump_neighbour_accepts: Array = frame.get("dump_neighbour_accepts", [])
		var dump_neighbour_can_dump: Array = frame.get("dump_neighbour_can_dump", [])
		var dumped: Dictionary = source_mass_driver_dump_state(frame, post_switch_state, source_delta, time_scale, item_order, dump_neighbour_accepts, dump_neighbour_can_dump)
		frame["dump_accum"] = dumped.get("dump_accum_after", frame.get("dump_accum", 0.0))
		frame["items"] = dumped.get("items_after", frame.get("items", {}))
		frame["cdump"] = dumped.get("cursor_after", frame.get("cdump", 0))
		# N2336: the acceptItem intake verdict (MassDriver.java:285-288, `return items.total() <
		# itemCapacity && linkValid();`, MassDriver.java:346-349) is stamped on the frame every tick
		# (the N2295 Loader acceptPayload precedent) so neighbour intake queries -- dump paths
		# consult acceptItem (BuildingComp.java:1088) -- can read it; no live neighbour reads it
		# yet (see DEFERRED). The pure reads the post-tick store (fire() and the dump above are
		# the only item mutations this tick) and the same linked dict the advance reads -- no
		# second gather. The advance's link refresh cannot invalidate the snapshot: a valid link
		# refreshes to the same pos, and an unlinked driver keeps link -1 with exists false.
		var accept_verdict: Dictionary = source_mass_driver_accept_item_state(frame, SOURCE_MASS_DRIVER_ITEM_CAPACITY, linked)
		frame["accepts_item"] = bool(accept_verdict.get("accepts", false))
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
