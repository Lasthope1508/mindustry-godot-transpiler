# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/BuildingComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "BuildingComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Posc", "Teamc", "Healthc", "Buildingc", "Timerc", "QuadTreeObject", "Displayable", "Sized", "Senseable", "Controllable", "Settable"]
const JAVA_FIELDS := [{"modifiers": ["final", "static"], "name": "timeToSleep", "type": "float"}, {"modifiers": ["final", "static"], "name": "recentDamageTime", "type": "float"}, {"modifiers": ["final", "static"], "name": "tmpTiles", "type": "ObjectSet"}, {"modifiers": ["final", "static"], "name": "tempBuilds", "type": "Seq"}, {"modifiers": ["final", "static"], "name": "teamChangeEvent", "type": "BuildTeamChangeEvent"}, {"modifiers": ["final", "static"], "name": "bulletDamageEvent", "type": "BuildDamageEvent"}, {"modifiers": ["static"], "name": "sleepingEntities", "type": "int"}, {"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "health", "type": "float"}, {"modifiers": [], "name": "maxHealth", "type": "float"}, {"modifiers": [], "name": "team", "type": "Team"}, {"modifiers": [], "name": "dead", "type": "boolean"}, {"modifiers": ["transient"], "name": "tile", "type": "Tile"}, {"modifiers": ["transient"], "name": "block", "type": "Block"}, {"modifiers": ["transient"], "name": "proximity", "type": "Seq"}, {"modifiers": ["transient"], "name": "cdump", "type": "int"}, {"modifiers": ["transient"], "name": "rotation", "type": "int"}, {"modifiers": ["transient"], "name": "lastAccessed", "type": "String"}, {"modifiers": ["transient"], "name": "visualLiquid", "type": "float"}, {"modifiers": ["transient"], "name": "visibleFlags", "type": "long"}, {"modifiers": ["transient"], "name": "wasVisible", "type": "boolean"}, {"modifiers": ["transient"], "name": "enabled", "type": "boolean"}, {"modifiers": ["transient"], "name": "lastDisabler", "type": "Building"}, {"modifiers": [], "name": "power", "type": "PowerModule"}, {"modifiers": [], "name": "items", "type": "ItemModule"}, {"modifiers": [], "name": "liquids", "type": "LiquidModule"}, {"modifiers": ["transient"], "name": "efficiency", "type": "float"}, {"modifiers": ["transient"], "name": "optionalEfficiency", "type": "float"}, {"modifiers": ["transient"], "name": "potentialEfficiency", "type": "float"}, {"modifiers": ["transient"], "name": "shouldConsumePower", "type": "boolean"}, {"modifiers": ["transient"], "name": "healSuppressionTime", "type": "float"}, {"modifiers": ["transient"], "name": "lastHealTime", "type": "float"}, {"modifiers": ["transient"], "name": "suppressColor", "type": "Color"}, {"modifiers": ["private", "transient"], "name": "lastDamageTime", "type": "float"}, {"modifiers": ["private", "transient"], "name": "timeScale", "type": "float"}, {"modifiers": ["private", "transient"], "name": "timeScaleDuration", "type": "float"}, {"modifiers": ["private", "transient"], "name": "dumpAccum", "type": "float"}, {"modifiers": ["private", "transient"], "name": "sleeping", "type": "boolean"}, {"modifiers": ["private", "transient"], "name": "sleepTime", "type": "float"}, {"modifiers": ["private", "transient"], "name": "initialized", "type": "boolean"}, {"modifiers": ["transient"], "name": "wasDamaged", "type": "boolean"}, {"modifiers": ["transient"], "name": "indexerBuildIndex", "type": "short"}, {"modifiers": ["transient"], "name": "indexerBuildTypeIndex", "type": "short"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "shouldAdd", "type": "boolean", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public"], "name": "create", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public"], "name": "add", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "tileX", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "tileY", "parameters": [], "return_type": "int"}, {"modifiers": ["final", "public"], "name": "writeBase", "parameters": [{"name": "write", "type": "Writes", "varargs": false}], "return_type": ""}, {"modifiers": ["final", "public"], "name": "readBase", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "moduleBitmask", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "writeAll", "parameters": [{"name": "write", "type": "Writes", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "readAll", "parameters": [{"name": "read", "type": "Reads", "varargs": false}, {"name": "revision", "type": "byte", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "writeSync", "parameters": [{"name": "write", "type": "Writes", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "readSync", "parameters": [{"name": "read", "type": "Reads", "varargs": false}, {"name": "revision", "type": "byte", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "write", "type": "Writes", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "read", "type": "Reads", "varargs": false}, {"name": "revision", "type": "byte", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isDiscovered", "parameters": [{"name": "viewer", "type": "Team", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "addPlan", "parameters": [{"name": "checkPrevious", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addPlan", "parameters": [{"name": "checkPrevious", "type": "boolean", "varargs": false}, {"name": "ignoreConditions", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "findClosestEdge", "parameters": [{"name": "to", "type": "Position", "varargs": false}, {"name": "solid", "type": "Boolf", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public"], "name": "configure", "parameters": [{"name": "value", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "configureAny", "parameters": [{"name": "value", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "deselect", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "configTapped", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "calculateHeat", "parameters": [{"name": "sideHeat", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "calculateHeat", "parameters": [{"name": "sideHeat", "type": "float", "varargs": false}, {"name": "cameFrom", "type": "IntSet", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "applyBoost", "parameters": [{"name": "intensity", "type": "float", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "applySlowdown", "parameters": [{"name": "intensity", "type": "float", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "applyHealSuppression", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "applyHealSuppression", "parameters": [{"name": "amount", "type": "float", "varargs": false}, {"name": "suppressColor", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isHealSuppressed", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "recentlyHealed", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "wasRecentlyHealed", "parameters": [{"name": "duration", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "wasRecentlyDamaged", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "eachEdge", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "nearby", "parameters": [{"name": "dx", "type": "int", "varargs": false}, {"name": "dy", "type": "int", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public"], "name": "nearby", "parameters": [{"name": "rotation", "type": "int", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public"], "name": "relativeTo", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "byte"}, {"modifiers": ["public"], "name": "relativeTo", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "byte"}, {"modifiers": ["public"], "name": "relativeToEdge", "parameters": [{"name": "other", "type": "Tile", "varargs": false}], "return_type": "byte"}, {"modifiers": ["public"], "name": "relativeTo", "parameters": [{"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}], "return_type": "byte"}, {"modifiers": ["public"], "name": "front", "parameters": [], "return_type": "Building"}, {"modifiers": ["public"], "name": "back", "parameters": [], "return_type": "Building"}, {"modifiers": ["public"], "name": "left", "parameters": [], "return_type": "Building"}, {"modifiers": ["public"], "name": "right", "parameters": [], "return_type": "Building"}, {"modifiers": ["public"], "name": "fogRadius", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "pos", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "rotdeg", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "drawrot", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "floor", "parameters": [], "return_type": "Floor"}, {"modifiers": ["public"], "name": "interactable", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "timeScale", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "warmup", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "totalProgress", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "progress", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "allowUpdate", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "inMapArea", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "status", "parameters": [], "return_type": "BlockStatus"}, {"modifiers": ["public"], "name": "sleep", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "noSleep", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "version", "parameters": [], "return_type": "byte"}, {"modifiers": ["public"], "name": "canControlSelect", "parameters": [{"name": "player", "type": "Unit", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "onControlSelect", "parameters": [{"name": "player", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onCommand", "parameters": [{"name": "target", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getCommandPosition", "parameters": [], "return_type": "Vec2"}, {"modifiers": ["public"], "name": "handleUnitPayload", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "grabber", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "canWithdraw", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canUnload", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canResupply", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "payloadCheck", "parameters": [{"name": "conveyorRotation", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "itemTaken", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "allowDeposit", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "dropped", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "handleString", "parameters": [{"name": "value", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "created", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "shouldConsume", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "productionValid", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "consumeTriggerValid", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getPowerProduction", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "acceptStack", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}, {"name": "source", "type": "Teamc", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "getMaximumAccepted", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "removeStack", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "handleStack", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}, {"name": "source", "type": "Teamc", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getStackOffset", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "trns", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "acceptPayload", "parameters": [{"name": "source", "type": "Building", "varargs": false}, {"name": "payload", "type": "Payload", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "handlePayload", "parameters": [{"name": "source", "type": "Building", "varargs": false}, {"name": "payload", "type": "Payload", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "movePayload", "parameters": [{"name": "todump", "type": "Payload", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "dumpPayload", "parameters": [{"name": "todump", "type": "Payload", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canBeReplaced", "parameters": [{"name": "other", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "handleItem", "parameters": [{"name": "source", "type": "Building", "varargs": false}, {"name": "item", "type": "Item", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "acceptItem", "parameters": [{"name": "source", "type": "Building", "varargs": false}, {"name": "item", "type": "Item", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "acceptLiquid", "parameters": [{"name": "source", "type": "Building", "varargs": false}, {"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "handleLiquid", "parameters": [{"name": "source", "type": "Building", "varargs": false}, {"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "dumpLiquid", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "dumpLiquid", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "scaling", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "dumpLiquid", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "scaling", "type": "float", "varargs": false}, {"name": "outputDir", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "canDumpLiquid", "parameters": [{"name": "to", "type": "Building", "varargs": false}, {"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "transferLiquid", "parameters": [{"name": "next", "type": "Building", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}, {"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "moveLiquidForward", "parameters": [{"name": "leaks", "type": "boolean", "varargs": false}, {"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "moveLiquid", "parameters": [{"name": "next", "type": "Building", "varargs": false}, {"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "getLiquidDestination", "parameters": [{"name": "from", "type": "Building", "varargs": false}, {"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public"], "name": "getPayload", "parameters": [], "return_type": "Payload"}, {"modifiers": ["public"], "name": "takePayload", "parameters": [], "return_type": "Payload"}, {"modifiers": ["public"], "name": "getPayloads", "parameters": [], "return_type": "PayloadSeq"}, {"modifiers": ["public"], "name": "offload", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "put", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "produced", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "produced", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "dumpAccumulate", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "dumpAccumulate", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "dump", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "dump", "parameters": [{"name": "todump", "type": "Item", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "incrementDump", "parameters": [{"name": "prox", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "canDump", "parameters": [{"name": "to", "type": "Building", "varargs": false}, {"name": "item", "type": "Item", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "moveForward", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "onProximityRemoved", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "onProximityAdded", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "onProximityUpdate", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updatePowerGraph", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "powerGraphRemoved", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "conductsTo", "parameters": [{"name": "other", "type": "Building", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getPowerConnections", "parameters": [{"name": "out", "type": "Seq", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "getProgressIncrease", "parameters": [{"name": "baseTime", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "getDisplayEfficiency", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "shouldAmbientSound", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "drawStatus", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawCracks", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawSelect", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawItemSelection", "parameters": [{"name": "selection", "type": "UnlockableContent", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawDisabled", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawCached", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "recache", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "payloadDraw", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawTeamTop", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawLight", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawLiquidLight", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawTeam", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "checkSuppression", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "playerPlaced", "parameters": [{"name": "config", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "placed", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "onRepaired", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isCommandable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isPayload", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "overwrote", "parameters": [{"name": "previous", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onRemoved", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "unitOn", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "unitOnAny", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "unitRemoved", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "puddleOn", "parameters": [{"name": "puddle", "type": "Puddle", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "configured", "parameters": [{"name": "builder", "type": "Unit", "varargs": false}, {"name": "value", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateLastAccess", "parameters": [{"name": "player", "type": "Player", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "tapped", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterDestroyed", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "explosionItemCap", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "splashLiquid", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onDeconstructed", "parameters": [{"name": "builder", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onDestroyed", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "playDestroySound", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getDisplayName", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "getDisplayIcon", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "flowItems", "parameters": [], "return_type": "ItemModule"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "displayConsumption", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "displayBars", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "buildConfiguration", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateTableAlign", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getCursor", "parameters": [], "return_type": "Cursor"}, {"modifiers": ["public"], "name": "onConfigureBuildTapped", "parameters": [{"name": "other", "type": "Building", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "onConfigureTapped", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "onConfigureClosed", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "shouldShowConfigure", "parameters": [{"name": "player", "type": "Player", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "shouldHideConfigure", "parameters": [{"name": "player", "type": "Player", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "drawConfigure", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "checkSolid", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "handleDamage", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "absorbLasers", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isInsulated", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "collide", "parameters": [{"name": "other", "type": "Bullet", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "collision", "parameters": [{"name": "other", "type": "Bullet", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "damage", "parameters": [{"name": "source", "type": "Team", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "damage", "parameters": [{"name": "bullet", "type": "Bullet", "varargs": false}, {"name": "source", "type": "Team", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "changeTeam", "parameters": [{"name": "next", "type": "Team", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "changeTeam", "parameters": [{"name": "next", "type": "Team", "varargs": false}, {"name": "updatePower", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "canPickup", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "pickedUp", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterPickedUp", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "removeFromProximity", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateProximity", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "onNearbyBuildAdded", "parameters": [{"name": "other", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "consume", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "canConsume", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "delta", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "edelta", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "updateEfficiencyMultiplier", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "efficiencyScale", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "updateConsumption", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updatePayload", "parameters": [{"name": "unitHolder", "type": "Unit", "varargs": false}, {"name": "buildingHolder", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateTile", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "ambientVolume", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "config", "parameters": [], "return_type": "Object"}, {"modifiers": ["public"], "name": "isValid", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "heal", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "heal", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "hitSize", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "kill", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "damage", "parameters": [{"name": "damage", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "healthChanged", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "sense", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "double"}, {"modifiers": ["public"], "name": "senseObject", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public"], "name": "sense", "parameters": [{"name": "content", "type": "Content", "varargs": false}], "return_type": "double"}, {"modifiers": ["public"], "name": "control", "parameters": [{"name": "type", "type": "LAccess", "varargs": false}, {"name": "p1", "type": "double", "varargs": false}, {"name": "p2", "type": "double", "varargs": false}, {"name": "p3", "type": "double", "varargs": false}, {"name": "p4", "type": "double", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "control", "parameters": [{"name": "type", "type": "LAccess", "varargs": false}, {"name": "p1", "type": "Object", "varargs": false}, {"name": "p2", "type": "double", "varargs": false}, {"name": "p3", "type": "double", "varargs": false}, {"name": "p4", "type": "double", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setProp", "parameters": [{"name": "prop", "type": "LAccess", "varargs": false}, {"name": "value", "type": "double", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setProp", "parameters": [{"name": "prop", "type": "LAccess", "varargs": false}, {"name": "value", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setProp", "parameters": [{"name": "content", "type": "UnlockableContent", "varargs": false}, {"name": "value", "type": "double", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "inFogTo", "parameters": [{"name": "viewer", "type": "Team", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "killed", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "checkAllowUpdate", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateFogVisibility", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "hitbox", "parameters": [{"name": "out", "type": "Rect", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_init_0(_args: Array = []) -> Variant:
	return null

func java_method_create_1(_args: Array = []) -> Variant:
	return null

func java_method_add_2(_args: Array = []) -> Variant:
	return null

func java_method_tileX_3(_args: Array = []) -> Variant:
	return null

func java_method_tileY_4(_args: Array = []) -> Variant:
	return null

func java_method_writeBase_5(_args: Array = []) -> Variant:
	return null

func java_method_readBase_6(_args: Array = []) -> Variant:
	return null

func java_method_moduleBitmask_7(_args: Array = []) -> Variant:
	return null

func java_method_writeAll_8(_args: Array = []) -> Variant:
	return null

func java_method_readAll_9(_args: Array = []) -> Variant:
	return null

func java_method_writeSync_10(_args: Array = []) -> Variant:
	return null

func java_method_readSync_11(_args: Array = []) -> Variant:
	return null

func java_method_write_12(_args: Array = []) -> Variant:
	return null

func java_method_read_13(_args: Array = []) -> Variant:
	return null

func java_method_isDiscovered_14(_args: Array = []) -> Variant:
	return null

func java_method_addPlan_15(_args: Array = []) -> Variant:
	return null

func java_method_addPlan_16(_args: Array = []) -> Variant:
	return null

func java_method_findClosestEdge_17(_args: Array = []) -> Variant:
	return null

func java_method_configure_18(_args: Array = []) -> Variant:
	return null

func java_method_configureAny_19(_args: Array = []) -> Variant:
	return null

func java_method_deselect_20(_args: Array = []) -> Variant:
	return null

func java_method_configTapped_21(_args: Array = []) -> Variant:
	return null

func java_method_calculateHeat_22(_args: Array = []) -> Variant:
	return null

func java_method_calculateHeat_23(_args: Array = []) -> Variant:
	return null

func java_method_applyBoost_24(_args: Array = []) -> Variant:
	return null

func java_method_applySlowdown_25(_args: Array = []) -> Variant:
	return null

func java_method_applyHealSuppression_26(_args: Array = []) -> Variant:
	return null

func java_method_applyHealSuppression_27(_args: Array = []) -> Variant:
	return null

func java_method_isHealSuppressed_28(_args: Array = []) -> Variant:
	return null

func java_method_recentlyHealed_29(_args: Array = []) -> Variant:
	return null

func java_method_wasRecentlyHealed_30(_args: Array = []) -> Variant:
	return null

func java_method_wasRecentlyDamaged_31(_args: Array = []) -> Variant:
	return null

func java_method_eachEdge_32(_args: Array = []) -> Variant:
	return null

func java_method_nearby_33(_args: Array = []) -> Variant:
	return null

func java_method_nearby_34(_args: Array = []) -> Variant:
	return null

func java_method_relativeTo_35(_args: Array = []) -> Variant:
	return null

func java_method_relativeTo_36(_args: Array = []) -> Variant:
	return null

func java_method_relativeToEdge_37(_args: Array = []) -> Variant:
	return null

func java_method_relativeTo_38(_args: Array = []) -> Variant:
	return null

func java_method_front_39(_args: Array = []) -> Variant:
	return null

func java_method_back_40(_args: Array = []) -> Variant:
	return null

func java_method_left_41(_args: Array = []) -> Variant:
	return null

func java_method_right_42(_args: Array = []) -> Variant:
	return null

func java_method_fogRadius_43(_args: Array = []) -> Variant:
	return null

func java_method_pos_44(_args: Array = []) -> Variant:
	return null

func java_method_rotdeg_45(_args: Array = []) -> Variant:
	return null

func java_method_drawrot_46(_args: Array = []) -> Variant:
	return null

func java_method_floor_47(_args: Array = []) -> Variant:
	return null

func java_method_interactable_48(_args: Array = []) -> Variant:
	return null

func java_method_timeScale_49(_args: Array = []) -> Variant:
	return null

func java_method_warmup_50(_args: Array = []) -> Variant:
	return null

func java_method_totalProgress_51(_args: Array = []) -> Variant:
	return null

func java_method_progress_52(_args: Array = []) -> Variant:
	return null

func java_method_allowUpdate_53(_args: Array = []) -> Variant:
	return null

func java_method_inMapArea_54(_args: Array = []) -> Variant:
	return null

func java_method_status_55(_args: Array = []) -> Variant:
	return null

func java_method_sleep_56(_args: Array = []) -> Variant:
	return null

func java_method_noSleep_57(_args: Array = []) -> Variant:
	return null

func java_method_version_58(_args: Array = []) -> Variant:
	return null

func java_method_canControlSelect_59(_args: Array = []) -> Variant:
	return null

func java_method_onControlSelect_60(_args: Array = []) -> Variant:
	return null

func java_method_onCommand_61(_args: Array = []) -> Variant:
	return null

func java_method_getCommandPosition_62(_args: Array = []) -> Variant:
	return null

func java_method_handleUnitPayload_63(_args: Array = []) -> Variant:
	return null

func java_method_canWithdraw_64(_args: Array = []) -> Variant:
	return null

func java_method_canUnload_65(_args: Array = []) -> Variant:
	return null

func java_method_canResupply_66(_args: Array = []) -> Variant:
	return null

func java_method_payloadCheck_67(_args: Array = []) -> Variant:
	return null

func java_method_itemTaken_68(_args: Array = []) -> Variant:
	return null

func java_method_allowDeposit_69(_args: Array = []) -> Variant:
	return null

func java_method_dropped_70(_args: Array = []) -> Variant:
	return null

func java_method_handleString_71(_args: Array = []) -> Variant:
	return null

func java_method_created_72(_args: Array = []) -> Variant:
	return null

func java_method_shouldConsume_73(_args: Array = []) -> Variant:
	return null

func java_method_productionValid_74(_args: Array = []) -> Variant:
	return null

func java_method_consumeTriggerValid_75(_args: Array = []) -> Variant:
	return null

func java_method_getPowerProduction_76(_args: Array = []) -> Variant:
	return null

func java_method_acceptStack_77(_args: Array = []) -> Variant:
	return null

func java_method_getMaximumAccepted_78(_args: Array = []) -> Variant:
	return null

func java_method_removeStack_79(_args: Array = []) -> Variant:
	return null

func java_method_handleStack_80(_args: Array = []) -> Variant:
	return null

func java_method_getStackOffset_81(_args: Array = []) -> Variant:
	return null

func java_method_acceptPayload_82(_args: Array = []) -> Variant:
	return null

func java_method_handlePayload_83(_args: Array = []) -> Variant:
	return null

func java_method_movePayload_84(_args: Array = []) -> Variant:
	return null

func java_method_dumpPayload_85(_args: Array = []) -> Variant:
	return null

func java_method_canBeReplaced_86(_args: Array = []) -> Variant:
	return null

func java_method_handleItem_87(_args: Array = []) -> Variant:
	return null

func java_method_acceptItem_88(_args: Array = []) -> Variant:
	return null

func java_method_acceptLiquid_89(_args: Array = []) -> Variant:
	return null

func java_method_handleLiquid_90(_args: Array = []) -> Variant:
	return null

func java_method_dumpLiquid_91(_args: Array = []) -> Variant:
	return null

func java_method_dumpLiquid_92(_args: Array = []) -> Variant:
	return null

func java_method_dumpLiquid_93(_args: Array = []) -> Variant:
	return null

func java_method_canDumpLiquid_94(_args: Array = []) -> Variant:
	return null

func java_method_transferLiquid_95(_args: Array = []) -> Variant:
	return null

func java_method_moveLiquidForward_96(_args: Array = []) -> Variant:
	return null

func java_method_moveLiquid_97(_args: Array = []) -> Variant:
	return null

func java_method_getLiquidDestination_98(_args: Array = []) -> Variant:
	return null

func java_method_getPayload_99(_args: Array = []) -> Variant:
	return null

func java_method_takePayload_100(_args: Array = []) -> Variant:
	return null

func java_method_getPayloads_101(_args: Array = []) -> Variant:
	return null

func java_method_offload_102(_args: Array = []) -> Variant:
	return null

func java_method_put_103(_args: Array = []) -> Variant:
	return null

func java_method_produced_104(_args: Array = []) -> Variant:
	return null

func java_method_produced_105(_args: Array = []) -> Variant:
	return null

func java_method_dumpAccumulate_106(_args: Array = []) -> Variant:
	return null

func java_method_dumpAccumulate_107(_args: Array = []) -> Variant:
	return null

func java_method_dump_108(_args: Array = []) -> Variant:
	return null

func java_method_dump_109(_args: Array = []) -> Variant:
	return null

func java_method_incrementDump_110(_args: Array = []) -> Variant:
	return null

func java_method_canDump_111(_args: Array = []) -> Variant:
	return null

func java_method_moveForward_112(_args: Array = []) -> Variant:
	return null

func java_method_onProximityRemoved_113(_args: Array = []) -> Variant:
	return null

func java_method_onProximityAdded_114(_args: Array = []) -> Variant:
	return null

func java_method_onProximityUpdate_115(_args: Array = []) -> Variant:
	return null

func java_method_updatePowerGraph_116(_args: Array = []) -> Variant:
	return null

func java_method_powerGraphRemoved_117(_args: Array = []) -> Variant:
	return null

func java_method_conductsTo_118(_args: Array = []) -> Variant:
	return null

func java_method_getPowerConnections_119(_args: Array = []) -> Variant:
	return null

func java_method_getProgressIncrease_120(_args: Array = []) -> Variant:
	var base_time := float(_args[0] if _args.size() > 0 else 1.0)
	var edelta_value := float(_args[1] if _args.size() > 1 else 1.0)
	return 1.0 / base_time * edelta_value

func java_method_getDisplayEfficiency_121(_args: Array = []) -> Variant:
	var edelta_value := float(_args[0] if _args.size() > 0 else 1.0)
	return (1.0 / 1.0 * edelta_value) / edelta_value

func java_method_shouldAmbientSound_122(_args: Array = []) -> Variant:
	var should_consume_state := bool(_args[0] if _args.size() > 0 else false)
	return should_consume_state

func java_method_drawStatus_123(_args: Array = []) -> Variant:
	var enable_draw_status := bool(_args[0] if _args.size() > 0 else false)
	var consumers_length := int(_args[1] if _args.size() > 1 else 0)
	var block_size_value := int(_args[2] if _args.size() > 2 else 1)
	var source_x := float(_args[3] if _args.size() > 3 else 0.0)
	var source_y := float(_args[4] if _args.size() > 4 else 0.0)
	var source_tilesize := float(_args[5] if _args.size() > 5 else 8.0)
	if not (enable_draw_status and consumers_length > 0):
		return {"visible": false}
	var multiplier := 1.0 if block_size_value > 1 else 0.64
	var brcx := source_x + (float(block_size_value) * source_tilesize / 2.0) - (source_tilesize * multiplier / 2.0)
	var brcy := source_y - (float(block_size_value) * source_tilesize / 2.0) + (source_tilesize * multiplier / 2.0)
	return {"visible": true, "multiplier": multiplier, "brcx": brcx, "brcy": brcy, "gray_square_size": 2.5 * multiplier, "status_square_size": 1.5 * multiplier}

func java_method_drawCracks_124(_args: Array = []) -> Variant:
	return null

func java_method_drawSelect_125(_args: Array = []) -> Variant:
	return null

func java_method_drawItemSelection_126(_args: Array = []) -> Variant:
	return null

func java_method_drawDisabled_127(_args: Array = []) -> Variant:
	return null

func java_method_draw_128(_args: Array = []) -> Variant:
	return null

func java_method_drawCached_129(_args: Array = []) -> Variant:
	return null

func java_method_recache_130(_args: Array = []) -> Variant:
	return null

func java_method_payloadDraw_131(_args: Array = []) -> Variant:
	return null

func java_method_drawTeamTop_132(_args: Array = []) -> Variant:
	return null

func java_method_drawLight_133(_args: Array = []) -> Variant:
	return null

func java_method_drawLiquidLight_134(_args: Array = []) -> Variant:
	return null

func java_method_drawTeam_135(_args: Array = []) -> Variant:
	return null

func java_method_checkSuppression_136(_args: Array = []) -> Variant:
	return null

func java_method_playerPlaced_137(_args: Array = []) -> Variant:
	return null

func java_method_placed_138(_args: Array = []) -> Variant:
	return null

func java_method_onRepaired_139(_args: Array = []) -> Variant:
	return null

func java_method_isCommandable_140(_args: Array = []) -> Variant:
	return null

func java_method_isPayload_141(_args: Array = []) -> Variant:
	return null

func java_method_overwrote_142(_args: Array = []) -> Variant:
	return null

func java_method_onRemoved_143(_args: Array = []) -> Variant:
	return null

func java_method_unitOn_144(_args: Array = []) -> Variant:
	return null

func java_method_unitOnAny_145(_args: Array = []) -> Variant:
	return null

func java_method_unitRemoved_146(_args: Array = []) -> Variant:
	return null

func java_method_puddleOn_147(_args: Array = []) -> Variant:
	return null

func java_method_configured_148(_args: Array = []) -> Variant:
	return null

func java_method_updateLastAccess_149(_args: Array = []) -> Variant:
	return null

func java_method_tapped_150(_args: Array = []) -> Variant:
	return null

func java_method_afterDestroyed_151(_args: Array = []) -> Variant:
	return null

func java_method_explosionItemCap_152(_args: Array = []) -> Variant:
	return null

func java_method_splashLiquid_153(_args: Array = []) -> Variant:
	return null

func java_method_onDeconstructed_154(_args: Array = []) -> Variant:
	return null

func java_method_onDestroyed_155(_args: Array = []) -> Variant:
	return null

func java_method_playDestroySound_156(_args: Array = []) -> Variant:
	return null

func java_method_getDisplayName_157(_args: Array = []) -> Variant:
	return null

func java_method_getDisplayIcon_158(_args: Array = []) -> Variant:
	return null

func java_method_flowItems_159(_args: Array = []) -> Variant:
	return null

func java_method_display_160(_args: Array = []) -> Variant:
	return null

func java_method_displayConsumption_161(_args: Array = []) -> Variant:
	return null

func java_method_displayBars_162(_args: Array = []) -> Variant:
	return null

func java_method_buildConfiguration_163(_args: Array = []) -> Variant:
	return null

func java_method_updateTableAlign_164(_args: Array = []) -> Variant:
	return null

func java_method_getCursor_165(_args: Array = []) -> Variant:
	return null

func java_method_onConfigureBuildTapped_166(_args: Array = []) -> Variant:
	return null

func java_method_onConfigureTapped_167(_args: Array = []) -> Variant:
	return null

func java_method_onConfigureClosed_168(_args: Array = []) -> Variant:
	return null

func java_method_shouldShowConfigure_169(_args: Array = []) -> Variant:
	return null

func java_method_shouldHideConfigure_170(_args: Array = []) -> Variant:
	return null

func java_method_drawConfigure_171(_args: Array = []) -> Variant:
	return null

func java_method_checkSolid_172(_args: Array = []) -> Variant:
	return null

func java_method_handleDamage_173(_args: Array = []) -> Variant:
	return null

func java_method_absorbLasers_174(_args: Array = []) -> Variant:
	return null

func java_method_isInsulated_175(_args: Array = []) -> Variant:
	return null

func java_method_collide_176(_args: Array = []) -> Variant:
	return null

func java_method_collision_177(_args: Array = []) -> Variant:
	return null

func java_method_damage_178(_args: Array = []) -> Variant:
	return null

func java_method_damage_179(_args: Array = []) -> Variant:
	return null

func java_method_changeTeam_180(_args: Array = []) -> Variant:
	return null

func java_method_changeTeam_181(_args: Array = []) -> Variant:
	return null

func java_method_canPickup_182(_args: Array = []) -> Variant:
	return null

func java_method_pickedUp_183(_args: Array = []) -> Variant:
	return null

func java_method_afterPickedUp_184(_args: Array = []) -> Variant:
	return null

func java_method_removeFromProximity_185(_args: Array = []) -> Variant:
	return null

func java_method_updateProximity_186(_args: Array = []) -> Variant:
	return null

func java_method_onNearbyBuildAdded_187(_args: Array = []) -> Variant:
	return null

func java_method_consume_188(_args: Array = []) -> Variant:
	return null

func java_method_canConsume_189(_args: Array = []) -> Variant:
	return null

func java_method_delta_190(_args: Array = []) -> Variant:
	return null

func java_method_edelta_191(_args: Array = []) -> Variant:
	return null

func java_method_updateEfficiencyMultiplier_192(_args: Array = []) -> Variant:
	return null

func java_method_efficiencyScale_193(_args: Array = []) -> Variant:
	return null

func java_method_updateConsumption_194(_args: Array = []) -> Variant:
	return null

func java_method_updatePayload_195(_args: Array = []) -> Variant:
	return null

func java_method_updateTile_196(_args: Array = []) -> Variant:
	return null

func java_method_ambientVolume_197(_args: Array = []) -> Variant:
	return null

func java_method_config_198(_args: Array = []) -> Variant:
	return null

func java_method_isValid_199(_args: Array = []) -> Variant:
	return null

func java_method_heal_200(_args: Array = []) -> Variant:
	return null

func java_method_heal_201(_args: Array = []) -> Variant:
	return null

func java_method_hitSize_202(_args: Array = []) -> Variant:
	return null

func java_method_kill_203(_args: Array = []) -> Variant:
	return null

func java_method_damage_204(_args: Array = []) -> Variant:
	return null

func java_method_healthChanged_205(_args: Array = []) -> Variant:
	return null

func java_method_sense_206(_args: Array = []) -> Variant:
	return null

func java_method_senseObject_207(_args: Array = []) -> Variant:
	return null

func java_method_sense_208(_args: Array = []) -> Variant:
	return null

func java_method_control_209(_args: Array = []) -> Variant:
	return null

func java_method_control_210(_args: Array = []) -> Variant:
	return null

func java_method_setProp_211(_args: Array = []) -> Variant:
	return null

func java_method_setProp_212(_args: Array = []) -> Variant:
	return null

func java_method_setProp_213(_args: Array = []) -> Variant:
	return null

func java_method_inFogTo_214(_args: Array = []) -> Variant:
	return null

func java_method_killed_215(_args: Array = []) -> Variant:
	return null

func java_method_checkAllowUpdate_216(_args: Array = []) -> Variant:
	return null

func java_method_update_217(_args: Array = []) -> Variant:
	return null

func java_method_updateFogVisibility_218(_args: Array = []) -> Variant:
	return null

func java_method_hitbox_219(_args: Array = []) -> Variant:
	return null

func java_method_toString_220(_args: Array = []) -> Variant:
	return null
