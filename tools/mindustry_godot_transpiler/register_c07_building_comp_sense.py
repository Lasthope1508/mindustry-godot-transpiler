"""Register the BuildingComp super.sense() LAccess delegation (N2284).

super.sense() is `public double sense(LAccess sensor){ return
switch(sensor){ case x -> World.conv(x); case y ->
World.conv(y); case color -> Color.toDoubleBits(team.color.r,
team.color.g, team.color.b, 1f); case dead -> !isValid() ? 1
: 0; case solid -> block.solid || checkSolid() ? 1 : 0; case
team -> team.id; case health -> health; case maxHealth ->
maxHealth; case efficiency -> efficiency; case timescale ->
timeScale; case range -> this instanceof Ranged r ? r.range()
/ tilesize : 0; case rotation -> rotation; case totalItems ->
items == null ? 0 : items.total(); case totalLiquids ->
liquids == null ? 0 : liquids.currentAmount(); case
totalPower -> power == null || block.consPower == null ? 0 :
power.status * (block.consPower.buffered ?
block.consPower.capacity : 1f); case itemCapacity ->
block.hasItems ? block.itemCapacity : 0; case
liquidCapacity -> block.hasLiquids ? block.liquidCapacity :
0; case powerCapacity -> block.consPower != null ?
block.consPower.capacity : 0f; case powerNetIn -> power ==
null ? 0 : power.graph.getLastScaledPowerIn() * 60; case
powerNetOut -> power == null ? 0 :
power.graph.getLastScaledPowerOut() * 60; case
powerNetStored -> power == null ? 0 :
power.graph.getLastPowerStored(); case powerNetCapacity ->
power == null ? 0 : power.graph.getLastCapacity(); case
enabled -> enabled ? 1 : 0; case controlled -> this
instanceof ControlBlock c && c.isControlled() ?
GlobalVars.ctrlPlayer : 0; case payloadCount ->
(getPayloads() != null ? getPayloads().total() : 0) +
(getPayload() != null ? 1 : 0); case size -> block.size;
case cameraX, cameraY, cameraWidth, cameraHeight -> this
instanceof ControlBlock c ? c.unit().sense(sensor) : 0;
default -> Float.NaN; }; }` (BuildingComp.java:2093-2126).
23 of the 30 sensors are implemented here: x/y read the
explicit world_x/world_y params through World.conv (the
frame carries no building position key); color reads the
explicit team_color_* params through arc toDoubleBits
(`public static double toDoubleBits(float r, float g, float
b, float a){` / `return Double.longBitsToDouble(
Color.rgba8888(r, g, b, a) & 0x00000000_ffffffffL);`,
arc-core/src/arc/graphics/Color.java:166-167, with
`rgba8888(r,g,b,a) = ((int)(r*255)<<24)|((int)(g*255)<<16)|
((int)(b*255)<<8)|(int)(a*255)`, :211-212); solid reads
block_solid (duo true, `solid = true;`,
BaseTurret.java:40, and `checkSolid()` returns false,
BuildingComp.java:1734-1736); team reads the live frame
team_id (absent folds to 0, derelict); maxHealth reads
max_health (`maxHealth(block.health);`,
BuildingComp.java:142; duo `health = 250;`,
Blocks.java:3321); efficiency reads the live frame
efficiency (absent folds to 0.0, `transient float
efficiency;`, BuildingComp.java:85); timescale reads the
explicit time_scale param (`private transient float
timeScale = 1f, timeScaleDuration;`,
BuildingComp.java:98); range reads range_value / tilesize
(duo is Ranged, `public class BaseTurretBuild extends
Building implements Ranged, RotBlock{`,
BaseTurret.java:113; `range()` is `range +
peekAmmo().rangeChange`, Turret.java:342-347; duo `range =
160;`, graphite `rangeChange = 16f;`); rotation reads the
live frame rotation (absent folds to 90.0, `public float
rotation = 90;`, BaseTurret.java:114); totalLiquids reads
total_liquids when has_liquids (duo false -> 0);
totalPower folds to 0 when power or consPower is absent
(duo has no consumePower, only `coolant =
consumeCoolant(0.1f);`) and otherwise reads the live frame
power_status; itemCapacity reads item_capacity when
has_items (`hasItems = true;`, ItemTurret.java:28;
`public int itemCapacity = 10;`, Block.java:75);
liquidCapacity reads liquid_capacity when has_liquids
(`public float liquidCapacity = -1f;`, Block.java:77);
powerCapacity reads power_capacity when has_cons_power;
powerNetIn/Out/Stored/Capacity fold to 0 when power is
absent (duo) and report handled=false when it is present
(the graph is not live in the frame); enabled reads the
live frame enabled (absent folds to true, `transient
boolean enabled = true;`, BuildingComp.java:77);
controlled reads is_player (`isControlled()` is
`unit().isPlayer()`, ControlBlock.java:10-12, over the
non-null proxy unit `public BlockUnitc unit =
(BlockUnitc)UnitTypes.block.create(team);`,
Turret.java:291; `GlobalVars.ctrlPlayer = 2`,
GlobalVars.java:24); payloadCount reads payload_count
(base `getPayload()` / `getPayloads()` return null,
BuildingComp.java:984/993); size reads block_size
(`public int size = 1;`, Block.java:215). dead / health /
totalItems / cameraX / cameraY / cameraWidth /
cameraHeight stay deferred and report handled=false + NaN
(dead needs tile validity, `return tile.build == self()
&& !dead();`, BuildingComp.java:2031; health and
totalItems are not live in the frame; camera* needs
UnitComp.sense delegation for the proxy unit).

GREEN decisions (pinned by this slice): (1) One pure
function on SourceTurretBuildState.gd,
source_building_comp_sense_state(frame, sensor, tilesize,
world_x, world_y, team_color_r, team_color_g,
team_color_b, block_solid, block_size, max_health,
range_value, has_items, item_capacity, has_liquids,
liquid_capacity, total_liquids, has_cons_power,
power_capacity, power_buffered, has_power, time_scale,
is_player, payload_count), returning the
N2206/N2208/N2223/N2283 sense wire shape (`handled` +
`sense_value` + `sense_value_is_nan`), so the
logic-dispatch caller can try the Turret sense first and
this function second. It sits immediately AFTER
source_turret_sense_state (Java order: Turret.sense
default -> super.sense) and BEFORE
source_turret_progress_state. (2) There is NO driver tick
line: sense is a logic read, not a tick write (the
N2206/N2208/N2223/N2283 precedent); the proof calls the
pure function directly with synthetic frames, and the
logic-processor dispatch hook is its own later slice. (3)
No legacy `source_building_comp_sense_result` schema
exists, so the contract validator falls through to the
new source_building_comp_sense_state_result schema and no
alias is needed. SSOT expected after GREEN: symbols +3,
Done +1, contracts +1, schema +2, 11662/1733/1667/3125 ->
11665/1734/1668/3127; defense shard slices 210 -> 211,
contracts 209 -> 210.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_sense import DEFERRED as N2283_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
ITEM_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
BLOCK = 'core/src/mindustry/world/Block.java'
WORLD = 'core/src/mindustry/core/World.java'
VARS = 'core/src/mindustry/Vars.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
TEAM = 'core/src/mindustry/game/Team.java'
GLOBAL_VARS = 'core/src/mindustry/logic/GlobalVars.java'
PAL = 'core/src/mindustry/graphics/Pal.java'
ARC_COLOR = 'arc-core/src/arc/graphics/Color.java'
CONTROL_BLOCK = 'core/src/mindustry/world/blocks/ControlBlock.java'
PROOF = '/root/C07BuildingCompSenseProof'
SENSE_OWNER = 'SourceTurretBuildState.source_building_comp_sense_state'
TESTS = ['test_c07_building_comp_sense_registration', 'test_all_c07_building_comp_sense_input_evidence_is_exact', 'test_building_comp_sense_state', 'test_reference_graph_and_actual_c07_building_comp_sense']
# The slice sources the N2284 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files. The arc-core entry is read from
# arc-upstream/, all others from mindustry-upstream/.
SLICE_SOURCES = [
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/core/World.java',
    'core/src/mindustry/Vars.java',
    'core/src/mindustry/logic/LAccess.java',
    'core/src/mindustry/game/Team.java',
    'core/src/mindustry/logic/GlobalVars.java',
    'core/src/mindustry/graphics/Pal.java',
    'core/src/mindustry/world/blocks/ControlBlock.java',
    'arc-core/src/arc/graphics/Color.java',
]
EXACT_EXPRS = [
    'public double sense(LAccess sensor){',
    'case x -> World.conv(x);',
    'case y -> World.conv(y);',
    'case color -> Color.toDoubleBits(team.color.r, team.color.g, team.color.b, 1f);',
    'case dead -> !isValid() ? 1 : 0;',
    'case solid -> block.solid || checkSolid() ? 1 : 0;',
    'case team -> team.id;',
    'case health -> health;',
    'case maxHealth -> maxHealth;',
    'case efficiency -> efficiency;',
    'case timescale -> timeScale;',
    'case range -> this instanceof Ranged r ? r.range() / tilesize : 0;',
    'case rotation -> rotation;',
    'case totalItems -> items == null ? 0 : items.total();',
    'case totalLiquids -> liquids == null ? 0 : liquids.currentAmount();',
    'case totalPower -> power == null || block.consPower == null ? 0 : power.status * (block.consPower.buffered ? block.consPower.capacity : 1f);',
    'case itemCapacity -> block.hasItems ? block.itemCapacity : 0;',
    'case liquidCapacity -> block.hasLiquids ? block.liquidCapacity : 0;',
    'case powerCapacity -> block.consPower != null ? block.consPower.capacity : 0f;',
    'case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;',
    'case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;',
    'case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();',
    'case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();',
    'case enabled -> enabled ? 1 : 0;',
    'case controlled -> this instanceof ControlBlock c && c.isControlled() ? GlobalVars.ctrlPlayer : 0;',
    'case payloadCount -> (getPayloads() != null ? getPayloads().total() : 0) + (getPayload() != null ? 1 : 0);',
    'case size -> block.size;',
    'case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;',
    'default -> Float.NaN; //gets converted to null in logic',
    'return tile.build == self() && !dead();',
    'public boolean checkSolid(){',
    'public float rotation = 90;',
    'public static float conv(float coord){',
    'return coord / tilesize;',
    'public static final int tilesize = 8;',
    'transient boolean enabled = true;',
    'transient float efficiency;',
    'private transient float timeScale = 1f, timeScaleDuration;',
    'maxHealth(block.health);',
    'health = 250;',
    'range = 160;',
    'rangeChange = 16f;',
    'public int itemCapacity = 10;',
    'public int size = 1;',
    'public float liquidCapacity = -1f;',
    'solid = true;',
    'public class BaseTurretBuild extends Building implements Ranged, RotBlock{',
    'public float range(){',
    'return range + peekAmmo().rangeChange;',
    'hasItems = true;',
    'public static final int ctrlProcessor = 1, ctrlPlayer = 2, ctrlCommand = 3;',
    'public Unit unit(){',
    'public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);',
    'return unit().isPlayer();',
    'public @Nullable Payload getPayload(){',
    'public @Nullable PayloadSeq getPayloads(){',
    'accent = Color.valueOf("ffd37f"),',
    'derelict = new Team(0, "derelict", Color.valueOf("4d4e58")),',
    'sharded = new Team(1, "sharded", Pal.accent.cpy(), Color.valueOf("ffd37f"), Color.valueOf("eab678"), Color.valueOf("d4816b")),',
    'coolant = consumeCoolant(0.1f);',
    'public static double toDoubleBits(float r, float g, float b, float a){',
    'return Double.longBitsToDouble(Color.rgba8888(r, g, b, a) & 0x00000000_ffffffffL);',
    'public static int rgba8888(float r, float g, float b, float a){',
    'return ((int)(r * 255) << 24) | ((int)(g * 255) << 16) | ((int)(b * 255) << 8) | (int)(a * 255);',
    'x,',
    'y,',
    'color("to");',
    'dead,',
    'solid,',
    'team,',
    'health,',
    'maxHealth,',
    'efficiency,',
    'timescale,',
    'range,',
    'rotation,',
    'totalItems,',
    'totalLiquids,',
    'totalPower,',
    'itemCapacity,',
    'liquidCapacity,',
    'powerCapacity,',
    'powerNetStored,',
    'powerNetCapacity,',
    'powerNetIn,',
    'powerNetOut,',
    'enabled("to"),',
    'controlled,',
    'payloadCount,',
    'size,',
    'cameraX,',
    'cameraY,',
    'cameraWidth,',
    'cameraHeight,',
]

# DEFERRED is carried from the N2283 register script via import --
# never retyped. super.sense() is done by this slice except the
# deferred legs; the logic-processor dispatch hook, senseObject,
# findTarget / shootp / calculateHeat / the other ItemTurret
# defs / controlled() live wiring still wait.
DEFERRED = list(N2283_DEFERRED) + [
    'BuildingComp super.sense() delegation (`public double sense(LAccess sensor){`, BuildingComp.java:2093-2126) -- DONE by this slice (N2284) except the deferred legs below; the pure function ports 23 of the 30 sensors over live frame keys + explicit live / catalog params, and reports handled=false + NaN for the rest so the caller knows to fall through.',
    'BuildingComp sense() dead leg (`case dead -> !isValid() ? 1 : 0;`, BuildingComp.java:2097) -- NOT this slice; `isValid()` is `tile.build == self() && !dead();` (BuildingComp.java:2031) and needs tile state that is not in the frame.',
    'BuildingComp sense() health leg (`case health -> health;`, BuildingComp.java:2100) -- NOT this slice; building health is not live in the frame (only unit_health for the controlled unit); the maxHealth/health re-sync is its own later slice.',
    'BuildingComp sense() totalItems leg (`case totalItems -> items == null ? 0 : items.total();`, BuildingComp.java:2107) -- NOT this slice; duo hasItems=true so the total is live inventory, not in the frame (must not be confused with totalAmmo).',
    'BuildingComp sense() cameraX/cameraY/cameraWidth/cameraHeight legs (`case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;`, BuildingComp.java:2121) -- NOT this slice; they need UnitComp.sense delegation for the proxy unit, its own later slice.',
    'BuildingComp sense() powerNetIn/powerNetOut/powerNetStored/powerNetCapacity legs when power is present (BuildingComp.java:2114-2117) -- NOT this slice; the power graph values are not live in the frame, so the pure function reports handled=false there; the power-null fold (duo) is done here.',
]


def definitions():
    def a(typ, expr, rule, source=BUILDING_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    sense_inputs = {
        'frame': a('Dictionary', 'case rotation -> rotation;', 'The turret frame carrying the live `team_id` (stamped every tick, absent folds to 0, derelict), `efficiency` (stamped every tick, absent folds to 0.0, `transient float efficiency;`, BuildingComp.java:85), `rotation` (stamped every tick by the aim call, absent folds to 90.0, `public float rotation = 90;`, BaseTurret.java:114), `enabled` (stamped every tick, absent folds to true, `transient boolean enabled = true;`, BuildingComp.java:77) and `power_status` (stamped by the graph update, N2142, absent folds to 1.0).'),
        'sensor': a('String', 'public double sense(LAccess sensor){', 'The logic sensor to read, spelled by its LAccess enum name (`x,` LAccess.java:31, `y,` :32, `color("to");` :84, `dead,` :47, `solid,` :46, `team,` :62, `health,` :22, `maxHealth,` :23, `efficiency,` :27, `timescale,` :29, `range,` :48, `rotation,` :30, `totalItems,` :7, `totalLiquids,` :9, `totalPower,` :10, `itemCapacity,` :11, `liquidCapacity,` :12, `powerCapacity,` :13, `powerNetStored,` :14, `powerNetCapacity,` :15, `powerNetIn,` :16, `powerNetOut,` :17, `enabled("to"),` :80, `controlled,` :65, `payloadCount,` :68, `size,` :45, `cameraX,` :37, `cameraY,` :38, `cameraWidth,` :39, `cameraHeight,` :40): the 23 implemented sensors are handled here, the 7 deferred legs report handled=false.'),
        'tilesize': a('float', 'public static final int tilesize = 8;', 'The world tilesize in pixels (Vars.java:135, `public static final int tilesize = 8;`); passed explicitly (the N2220 draw-place precedent) so the x/y/range legs divide by the caller-supplied world constant (`public static float conv(float coord){` / `return coord / tilesize;`, World.java:165-166).', source=VARS),
        'world_x': a('float', 'case x -> World.conv(x);', 'The building world x in pixels (`case x -> World.conv(x);`, BuildingComp.java:2094); passed explicitly because the frame carries no building position key (the N2212/N2220 per-def-param precedent).'),
        'world_y': a('float', 'case y -> World.conv(y);', 'The building world y in pixels (`case y -> World.conv(y);`, BuildingComp.java:2095); passed explicitly because the frame carries no building position key (the N2212/N2220 per-def-param precedent).'),
        'team_color_r': a('float', 'case color -> Color.toDoubleBits(team.color.r, team.color.g, team.color.b, 1f);', 'The team color red component 0-1 (`team.color.r`, BuildingComp.java:2096; sharded is Pal.accent, `accent = Color.valueOf("ffd37f"),`, Pal.java:79); passed explicitly because the frame carries no team color, and read through arc toDoubleBits (verified float32-safe by Python struct for the proof bytes).'),
        'team_color_g': a('float', 'case color -> Color.toDoubleBits(team.color.r, team.color.g, team.color.b, 1f);', 'The team color green component 0-1 (`team.color.g`, BuildingComp.java:2096; sharded g is 211/255).'),
        'team_color_b': a('float', 'case color -> Color.toDoubleBits(team.color.r, team.color.g, team.color.b, 1f);', 'The team color blue component 0-1 (`team.color.b`, BuildingComp.java:2096; sharded b is 127/255).'),
        'block_solid': a('bool', 'case solid -> block.solid || checkSolid() ? 1 : 0;', 'Whether the block is solid (`block.solid`, BuildingComp.java:2098; duo true, `solid = true;`, BaseTurret.java:40; `checkSolid()` returns false, BuildingComp.java:1734-1736, so the leg is exactly block.solid).'),
        'block_size': a('int', 'case size -> block.size;', 'The block size in tiles (`block.size`, BuildingComp.java:2120; `public int size = 1;`, Block.java:215, duo never overrides it).'),
        'max_health': a('float', 'case maxHealth -> maxHealth;', 'The building max health (`maxHealth`, BuildingComp.java:2101; `maxHealth(block.health);` at creation, BuildingComp.java:142; duo `health = 250;`, Blocks.java:3321).'),
        'range_value': a('float', 'case range -> this instanceof Ranged r ? r.range() / tilesize : 0;', 'The live range() in pixels (`r.range()`, BuildingComp.java:2104; duo is Ranged, `public class BaseTurretBuild extends Building implements Ranged, RotBlock{`, BaseTurret.java:113; `range()` is `range + peekAmmo().rangeChange`, Turret.java:342-347; duo `range = 160;`, graphite `rangeChange = 16f;`); passed explicitly because it depends on the live ammo type.'),
        'has_items': a('bool', 'case itemCapacity -> block.hasItems ? block.itemCapacity : 0;', 'Whether the block has an item inventory (`block.hasItems`, BuildingComp.java:2110; duo true, `hasItems = true;`, ItemTurret.java:28).'),
        'item_capacity': a('int', 'case itemCapacity -> block.hasItems ? block.itemCapacity : 0;', 'The item capacity (`block.itemCapacity`, BuildingComp.java:2110; `public int itemCapacity = 10;`, Block.java:75, ItemTurret never overrides it).'),
        'has_liquids': a('bool', 'case liquidCapacity -> block.hasLiquids ? block.liquidCapacity : 0;', 'Whether the block has a liquid inventory (`block.hasLiquids`, BuildingComp.java:2111; duo false, it only consumes coolant through a ConsumeLiquidBase, `coolant = consumeCoolant(0.1f);`, Blocks.java:3324).'),
        'liquid_capacity': a('float', 'case liquidCapacity -> block.hasLiquids ? block.liquidCapacity : 0;', 'The liquid capacity (`block.liquidCapacity`, BuildingComp.java:2111; `public float liquidCapacity = -1f;`, Block.java:77, the unset default).'),
        'total_liquids': a('float', 'case totalLiquids -> liquids == null ? 0 : liquids.currentAmount();', 'The live total liquids (`liquids.currentAmount()`, BuildingComp.java:2108); only read when has_liquids is true, duo folds to 0.'),
        'has_cons_power': a('bool', 'case powerCapacity -> block.consPower != null ? block.consPower.capacity : 0f;', 'Whether the block has a ConsumePower (`block.consPower != null`, BuildingComp.java:2112; duo false, it has no consumePower property, only coolant).'),
        'power_capacity': a('float', 'case powerCapacity -> block.consPower != null ? block.consPower.capacity : 0f;', 'The power capacity (`block.consPower.capacity`, BuildingComp.java:2112; only read when has_cons_power is true).'),
        'power_buffered': a('bool', 'case totalPower -> power == null || block.consPower == null ? 0 : power.status * (block.consPower.buffered ? block.consPower.capacity : 1f);', 'Whether the power consumer is buffered (`block.consPower.buffered`, BuildingComp.java:2109; buffered multiplies power.status by the capacity, unbuffered by 1).'),
        'has_power': a('bool', 'case totalPower -> power == null || block.consPower == null ? 0 : power.status * (block.consPower.buffered ? block.consPower.capacity : 1f);', 'Whether the building has a power module (`power != null`, BuildingComp.java:2109; duo false, no consumePower and no power output; the powerNet* legs also fold to 0 on this flag).'),
        'time_scale': a('float', 'case timescale -> timeScale;', 'The live timeScale (`timeScale`, BuildingComp.java:2103; `private transient float timeScale = 1f, timeScaleDuration;`, BuildingComp.java:98); passed explicitly because it is not in the frame.'),
        'is_player': a('bool', 'case controlled -> this instanceof ControlBlock c && c.isControlled() ? GlobalVars.ctrlPlayer : 0;', 'Whether a player unit controls the block (`c.isControlled()` is `unit().isPlayer()`, ControlBlock.java:10-12, over the non-null proxy unit `public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`, Turret.java:291; `public static final int ctrlProcessor = 1, ctrlPlayer = 2, ctrlCommand = 3;`, GlobalVars.java:24); passed explicitly because player-control state is not tracked by the driver yet.'),
        'payload_count': a('int', 'case payloadCount -> (getPayloads() != null ? getPayloads().total() : 0) + (getPayload() != null ? 1 : 0);', 'The live payload count (`(getPayloads() != null ? getPayloads().total() : 0) + (getPayload() != null ? 1 : 0)`, BuildingComp.java:2120; base `getPayload()` / `getPayloads()` return null, BuildingComp.java:984/993, so duo is 0).'),
    }
    sense_outputs = {
        'handled': a('bool', 'default -> Float.NaN; //gets converted to null in logic', 'Whether this slice handled the sensor (one of the 23 implemented sensors); false means "not handled -- deferred leg or unknown sensor" (the N2208 mass-driver / N2223 repair-turret / N2283 turret sense precedent).'),
        'sense_value': a('float', 'case x -> World.conv(x);', 'The sensed value: World.conv(world_x/y) in tiles for "x"/"y" (:2094-2095), arc toDoubleBits(team color) for "color" (:2096), 1 or 0 for "solid" (:2098), the live team id for "team" (:2099), maxHealth for "maxHealth" (:2101), the live efficiency for "efficiency" (:2102), timeScale for "timescale" (:2103), range()/tilesize for "range" (:2104), the live rotation for "rotation" (:2105), the live total liquids (or 0) for "totalLiquids" (:2108), power.status x capacity-or-1 (or 0) for "totalPower" (:2109), item/liquid/power capacity for "itemCapacity"/"liquidCapacity"/"powerCapacity" (:2110-2112), 0 for the powerNet* legs when power is absent (:2113-2116), 1 or 0 for "enabled" (:2118), 2 or 0 for "controlled" (:2119), the payload count for "payloadCount" (:2120), block.size for "size" (:2121); null when the sensor is not handled.'),
        'sense_value_is_nan': a('bool', 'default -> Float.NaN; //gets converted to null in logic', 'Whether the sensed value is NaN: true only when the sensor is not handled (the super switch default, BuildingComp.java:2123, `default -> Float.NaN; //gets converted to null in logic`, converts to null in logic); false for all 23 handled sensors.'),
    }
    return sense_inputs, sense_outputs


def _read_source(source):
    base = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
    return (base / source).read_text(encoding='utf-8')


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = _read_source(source)
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
        total += len(keys)
        for field, meta in keys.items():
            text = _read_source(meta['java_source'])
            if meta['java_expr'] not in text:
                missing.append('%s: %s' % (field, meta['java_expr']))
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    sense_inputs, sense_outputs = definitions()

    entries = [
        ('N2284', SENSE_OWNER, 'source_building_comp_sense_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp.BuildingComp', 'BuildingComp.sense(LAccess)', sense_inputs, sense_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BuildingComp super.sense() LAccess delegation from BuildingComp.java:2093-2126 + Turret.java + BaseTurret.java + ItemTurret.java + Blocks.java + Block.java + World.java + Vars.java + LAccess.java + Team.java + GlobalVars.java + Pal.java + arc Color.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BuildingComp super.sense() LAccess delegation from BuildingComp.java:2093-2126 + Turret.java + BaseTurret.java + ItemTurret.java + Blocks.java + Block.java + World.java + Vars.java + LAccess.java + Team.java + GlobalVars.java + Pal.java + arc Color.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: handled, sense_value,
    # sense_value_is_nan.
    by_slice['N2284'] = [
        'source_building_comp_sense_state_result.handled',
        'source_building_comp_sense_state_result.sense_value',
        'source_building_comp_sense_state_result.sense_value_is_nan',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2284', dict(status='done', java_source=BUILDING_COMP, java_class='mindustry.entities.comp.BuildingComp.BuildingComp', java_method='BuildingComp.sense(LAccess)', godot_owner=SENSE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2284'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)

    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {definition[1] for definition in entries}
    for name, module in modules.items():
        if module.get('canonical_module') == 'api_contracts':
            selected = source_ssot.build_extension_shard(GODOT, name)[module['root_key']]
            if new_owners.intersection(selected):
                optional = module.setdefault('optional_mirror_fields', [])
                if 'return_type' not in optional:
                    optional.append('return_type')
    source_ssot.write_registered_json(GODOT, 'module_manifest', manifest)
    for canonical in ['slice_ledger', 'api_contracts', 'state_schema', 'registry', 'audit_report', 'module_manifest']:
        for name, module in modules.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    if '--verify' in sys.argv:
        sys.exit(verify())
    main()
