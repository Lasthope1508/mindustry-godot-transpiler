extends RefCounted
class_name SourceBuilderRuntimeSourceTextState

const SOURCE_BUILDER_RUNTIME_SOURCE := "core/src/mindustry/entities/comp/BuilderComp.java"

const SOURCE_BUILDER_CAN_BUILD_METHOD := "public boolean canBuild(){"
const SOURCE_BUILDER_CAN_BUILD_RETURN_EXPR := "return type.buildSpeed > 0 && buildSpeedMultiplier > 0;"
const SOURCE_BUILDER_CAN_BUILD_GENERATED_METHOD := "java_method_canBuild_0"
const SOURCE_BUILDER_CAN_BUILD_GENERATED_OWNER := "builder_comp.java_method_canBuild_0"

const SOURCE_BUILDER_UPDATE_METHOD := "public void update(){"
const SOURCE_BUILDER_UPDATE_BUILD_LOGIC_CALL_EXPR := "updateBuildLogic();"
const SOURCE_BUILDER_UPDATE_GENERATED_METHOD := "java_method_update_1"
const SOURCE_BUILDER_UPDATE_GENERATED_OWNER := "builder_comp.java_method_update_1"

const SOURCE_BUILDER_AFTER_READ_METHOD := "public void afterRead(){"
const SOURCE_BUILDER_AFTER_READ_COMMENT := "//why would this happen?"
const SOURCE_BUILDER_AFTER_READ_GUARD_EXPR := "if(plans == null){"
const SOURCE_BUILDER_AFTER_READ_QUEUE_CONSTRUCTOR := "new Queue<>(1)"
const SOURCE_BUILDER_AFTER_READ_GENERATED_METHOD := "java_method_afterRead_2"
const SOURCE_BUILDER_AFTER_READ_GENERATED_OWNER := "builder_comp.java_method_afterRead_2"

const SOURCE_BUILDER_IS_BUILDING_METHOD := "boolean isBuilding(){"
const SOURCE_BUILDER_IS_BUILDING_RETURN_EXPR := "return plans.size != 0;"
const SOURCE_BUILDER_IS_BUILDING_GENERATED_METHOD := "java_method_isBuilding_9"
const SOURCE_BUILDER_IS_BUILDING_GENERATED_OWNER := "builder_comp.java_method_isBuilding_9"

const SOURCE_BUILDER_CLEAR_BUILDING_METHOD := "void clearBuilding(){"
const SOURCE_BUILDER_CLEAR_BUILDING_PLANS_CLEAR_CALL_EXPR := "plans.clear();"
const SOURCE_BUILDER_CLEAR_BUILDING_GENERATED_METHOD := "java_method_clearBuilding_10"
const SOURCE_BUILDER_CLEAR_BUILDING_GENERATED_OWNER := "builder_comp.java_method_clearBuilding_10"

const SOURCE_BUILDER_ADD_BUILD_TAIL_METHOD := "void addBuild(BuildPlan place){"
const SOURCE_BUILDER_ADD_BUILD_TAIL_CALL_EXPR := "addBuild(place, true);"
const SOURCE_BUILDER_ADD_BUILD_TAIL_GENERATED_METHOD := "java_method_addBuild_11"
const SOURCE_BUILDER_ADD_BUILD_TAIL_GENERATED_OWNER := "builder_comp.java_method_addBuild_11"

const SOURCE_BUILDER_SHOULD_SKIP_METHOD := "boolean shouldSkip(BuildPlan plan, @Nullable Building core){"
const SOURCE_BUILDER_SHOULD_SKIP_GUARD_EXPR := "if(state.rules.infiniteResources || team.rules().infiniteResources || plan.breaking || core == null || plan.isRotation(team) || plan.isDerelictRepair()) return false;"
const SOURCE_BUILDER_SHOULD_SKIP_RETURN_EXPR := "return (plan.stuck && !core.items.has(plan.block.requirements)) || (Structs.contains(plan.block.requirements, i -> !core.items.has(i.item, Math.min(i.amount, 15)) && Mathf.round(i.amount * state.rules.buildCostMultiplier) > 0));"
const SOURCE_BUILDER_SHOULD_SKIP_GENERATED_METHOD := "java_method_shouldSkip_7"
const SOURCE_BUILDER_SHOULD_SKIP_GENERATED_OWNER := "builder_comp.java_method_shouldSkip_7"

const SOURCE_BUILDER_REMOVE_BUILD_METHOD := "void removeBuild(int x, int y, boolean breaking){"
const SOURCE_BUILDER_REMOVE_BUILD_INDEX_EXPR := "int idx = plans.indexOf(req -> req.breaking == breaking && req.x == x && req.y == y);"
const SOURCE_BUILDER_REMOVE_BUILD_GUARD_EXPR := "if(idx != -1){"
const SOURCE_BUILDER_REMOVE_BUILD_REMOVE_INDEX_EXPR := "plans.removeIndex(idx);"
const SOURCE_BUILDER_REMOVE_BUILD_GENERATED_METHOD := "java_method_removeBuild_8"
const SOURCE_BUILDER_REMOVE_BUILD_GENERATED_OWNER := "builder_comp.java_method_removeBuild_8"

const SOURCE_BUILDER_ADD_BUILD_METHOD := "void addBuild(BuildPlan place, boolean tail){"
const SOURCE_BUILDER_ADD_BUILD_WORLD_TILE_CALL_EXPR := "world.tile(place.x, place.y);"
const SOURCE_BUILDER_ADD_BUILD_ADD_LAST_EXPR := "plans.addLast(place);"
const SOURCE_BUILDER_ADD_BUILD_ADD_FIRST_EXPR := "plans.addFirst(place);"
const SOURCE_BUILDER_ADD_BUILD_GENERATED_METHOD := "java_method_addBuild_12"
const SOURCE_BUILDER_ADD_BUILD_GENERATED_OWNER := "builder_comp.java_method_addBuild_12"

const SOURCE_BUILDER_BUILD_PLAN_METHOD := "BuildPlan buildPlan(){"
const SOURCE_BUILDER_BUILD_PLAN_RETURN_EXPR := "return plans.size == 0 ? null : plans.first();"
const SOURCE_BUILDER_BUILD_PLAN_GENERATED_METHOD := "java_method_buildPlan_14"
const SOURCE_BUILDER_BUILD_PLAN_GENERATED_OWNER := "builder_comp.java_method_buildPlan_14"

const SOURCE_BUILDER_ACTIVELY_BUILDING_METHOD := "boolean activelyBuilding(){"
const SOURCE_BUILDER_ACTIVELY_BUILDING_RANGE_EXPR := "state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange"
const SOURCE_BUILDER_ACTIVELY_BUILDING_GENERATED_METHOD := "java_method_activelyBuilding_13"
const SOURCE_BUILDER_ACTIVELY_BUILDING_GENERATED_OWNER := "builder_comp.java_method_activelyBuilding_13"

const SOURCE_BUILDER_BUILD_STEP_METHOD := "void updateBuildLogic(){"
const SOURCE_BUILDER_BUILD_STEP_SPEED_FORMULA_EXPR := "1f / entity.buildCost * type.buildSpeed * buildSpeedMultiplier * state.rules.buildSpeed(team)"
const SOURCE_BUILDER_BUILD_STEP_CONSTRUCT_CALL_EXPR := "entity.construct(self(), core, bs, current.config);"
const SOURCE_BUILDER_BUILD_STEP_DECONSTRUCT_CALL_EXPR := "entity.deconstruct(self(), core, bs);"
const SOURCE_BUILDER_BUILD_STEP_GENERATED_METHOD := "java_method_updateBuildLogic_4"
const SOURCE_BUILDER_BUILD_STEP_GENERATED_OWNER := "builder_comp.java_method_updateBuildLogic_4"
