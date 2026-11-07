extends RefCounted
class_name SourceBlockPostInitSourceTextState

const SOURCE_BLOCK_POST_INIT_SOURCE := "core/src/mindustry/world/Block.java"
const SOURCE_BLOCK_POST_INIT_METHOD := "public void postInit(){"
const SOURCE_BLOCK_POST_INIT_JAVA_METHOD_POST_INIT_122 := "java_method_postInit_122"
const SOURCE_BLOCK_POST_INIT_GENERATED_OWNER := "block.java_method_postInit_122"
const SOURCE_BLOCK_POST_INIT_SUPER_EXPR := "super.postInit();"

const SOURCE_BLOCK_POST_INIT_DATABASE_TAG_GUARD_EXPR := "if(databaseTag == null || databaseTag.isEmpty()){"
const SOURCE_BLOCK_POST_INIT_DATABASE_TAG_ASSIGN_EXPR := "databaseTag = category.name();"

const SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_COMMENT := "//usually, an empty set of planets is a configuration error. auto-assign based on requirements"
const SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_AUTO_ASSIGN_GUARD_EXPR := "if(requirements.length > 0 && shownPlanets.isEmpty()){"
const SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_CONTENT_PLANETS_LOOP_EXPR := "for(Planet planet : content.planets()){"
const SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_PLANET_LANDABLE_GUARD_EXPR := "if(planet.isLandable()){"
const SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_STRUCTS_CONTAINS_GUARD_EXPR := "if(!Structs.contains(requirements, s -> !s.item.isOnPlanet(planet))){"
const SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_ADD_EXPR := "shownPlanets.add(planet);"
