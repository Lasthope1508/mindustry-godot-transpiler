extends RefCounted
class_name SourceBuildingHeatSourceTextState

const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const SOURCE_BUILDING_COMP_SOURCE := "core/src/mindustry/entities/comp/BuildingComp.java"
const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_HEAT_DEFAULT_METHOD := "public float calculateHeat(float[] sideHeat){"
const SOURCE_BUILDING_HEAT_METHOD := "public float calculateHeat(float[] sideHeat, @Nullable IntSet cameFrom){"
const SOURCE_BUILDING_HEAT_ARRAYS_FILL := "Arrays.fill(sideHeat, 0f);"
const SOURCE_BUILDING_HEAT_CAME_FROM_CLEAR := "if(cameFrom != null) cameFrom.clear();"
const SOURCE_BUILDING_HEAT_PROXIMITY_LOOP := "for(var build : proximity){"
const SOURCE_BUILDING_HEAT_GATE := "if(build != null && build.team == team && build instanceof HeatBlock heater){"
const SOURCE_BUILDING_HEAT_SPLIT := "boolean split = build.block instanceof HeatConductor cond && cond.splitHeat;"
const SOURCE_BUILDING_HEAT_ROTATION_GATE := "if(!build.block.rotate || (!split && (relativeTo(build) + 2) % 4 == build.rotation) || (split && relativeTo(build) != build.rotation)){"
const SOURCE_BUILDING_HEAT_CYCLE_GATE := "if(!(build instanceof HeatConductorBuild hc && hc.cameFrom.contains(id()))){"
const SOURCE_BUILDING_HEAT_DIFF := "float diff = (Math.min(Math.abs(build.x - x), Math.abs(build.y - y)) / tilesize);"
const SOURCE_BUILDING_HEAT_CONTACT_POINTS := "int contactPoints = Math.min((int)(block.size/2f + build.block.size/2f - diff), Math.min(build.block.size, block.size));"
const SOURCE_BUILDING_HEAT_ADD := "float add = heater.heat() / build.block.size * contactPoints;"
const SOURCE_BUILDING_HEAT_SPLIT_DIVIDE := "add /= 3f;"
const SOURCE_BUILDING_HEAT_SIDE_ADD := "sideHeat[Mathf.mod(relativeTo(build), 4)] += add;"
const SOURCE_BUILDING_HEAT_TOTAL_ADD := "heat += add;"
const SOURCE_BUILDING_HEAT_CAME_FROM_ADD := "cameFrom.add(build.id);"
const SOURCE_BUILDING_HEAT_CAME_FROM_MERGE := "cameFrom.addAll(hc.cameFrom);"
const SOURCE_BUILDING_HEAT_UPDATE := "cond.updateHeat();"
const SOURCE_BUILDING_HEAT_RETURN := "return heat;"

const SOURCE_BUILDING_HEAT_DEFAULT_JAVA_METHOD := "java_method_calculateHeat_22"
const SOURCE_BUILDING_HEAT_JAVA_METHOD := "java_method_calculateHeat_23"
const SOURCE_BUILDING_HEAT_DEFAULT_GENERATED_OWNER := "building_comp.java_method_calculateHeat_22"
const SOURCE_BUILDING_HEAT_GENERATED_OWNER := "building_comp.java_method_calculateHeat_23"
