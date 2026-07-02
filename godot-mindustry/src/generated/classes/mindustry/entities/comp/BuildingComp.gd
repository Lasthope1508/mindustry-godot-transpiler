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

const SOURCE_INT64_MIN := -9223372036854775807 - 1
const SOURCE_UINT16_MASK := 65535
const SOURCE_RAND_MURMUR_CONST1_WORDS := [0x8ccd, 0xed55, 0xafd7, 0xff51]
const SOURCE_RAND_MURMUR_CONST2_WORDS := [0xec53, 0x1a85, 0xb9fe, 0xc4ce]
const SOURCE_LONG_MIN_WORDS := [0, 0, 0, 0x8000]

func _source_arc_is_power_of_two(value: int) -> bool:
	return value != 0 and (value & (value - 1)) == 0

func _source_words_from_nonnegative(value: int) -> Array:
	var remaining: int = value
	var words: Array = []
	for _index in 4:
		words.append(remaining & SOURCE_UINT16_MASK)
		remaining = remaining >> 16
	return words

func _source_words_clone(words: Array) -> Array:
	return [int(words[0]), int(words[1]), int(words[2]), int(words[3])]

func _source_words_xor(left: Array, right: Array) -> Array:
	return [int(left[0]) ^ int(right[0]), int(left[1]) ^ int(right[1]), int(left[2]) ^ int(right[2]), int(left[3]) ^ int(right[3])]

func _source_words_add(left: Array, right: Array) -> Array:
	var result: Array = [0, 0, 0, 0]
	var carry := 0
	for index in 4:
		var sum_value: int = int(left[index]) + int(right[index]) + carry
		result[index] = sum_value & SOURCE_UINT16_MASK
		carry = sum_value >> 16
	return result

func _source_words_shift_left(words: Array, bits: int) -> Array:
	var result: Array = [0, 0, 0, 0]
	var word_shift: int = bits >> 4
	var bit_shift: int = bits % 16
	for index in 4:
		var source_index: int = index - word_shift
		var value := 0
		if source_index >= 0:
			value = int(words[source_index]) << bit_shift
			if bit_shift > 0 and source_index > 0:
				value |= int(words[source_index - 1]) >> (16 - bit_shift)
		result[index] = value & SOURCE_UINT16_MASK
	return result

func _source_words_unsigned_shift_right(words: Array, bits: int) -> Array:
	var result: Array = [0, 0, 0, 0]
	var word_shift: int = bits >> 4
	var bit_shift: int = bits % 16
	for index in 4:
		var source_index: int = index + word_shift
		var value := 0
		if source_index < 4:
			value = int(words[source_index]) >> bit_shift
			if bit_shift > 0 and source_index < 3:
				value |= int(words[source_index + 1]) << (16 - bit_shift)
		result[index] = value & SOURCE_UINT16_MASK
	return result

func _source_words_mul(left: Array, right: Array) -> Array:
	var accum: Array = [0, 0, 0, 0]
	for left_index in 4:
		for right_index in 4:
			var target_index: int = left_index + right_index
			if target_index < 4:
				accum[target_index] = int(accum[target_index]) + int(left[left_index]) * int(right[right_index])
	var result: Array = [0, 0, 0, 0]
	var carry := 0
	for index in 4:
		var total: int = int(accum[index]) + carry
		result[index] = total & SOURCE_UINT16_MASK
		carry = total >> 16
	return result

func _source_words_to_nonnegative(words: Array) -> int:
	return int(words[0]) + (int(words[1]) << 16) + (int(words[2]) << 32) + (int(words[3]) << 48)

func _source_words_to_signed(words: Array) -> int:
	if (int(words[3]) & 0x8000) == 0:
		return _source_words_to_nonnegative(words)
	var inverted: Array = [int(words[0]) ^ SOURCE_UINT16_MASK, int(words[1]) ^ SOURCE_UINT16_MASK, int(words[2]) ^ SOURCE_UINT16_MASK, int(words[3]) ^ SOURCE_UINT16_MASK]
	var magnitude_words: Array = _source_words_add(inverted, [1, 0, 0, 0])
	if int(magnitude_words[3]) == 0x8000 and int(magnitude_words[2]) == 0 and int(magnitude_words[1]) == 0 and int(magnitude_words[0]) == 0:
		return SOURCE_INT64_MIN
	return -_source_words_to_nonnegative(magnitude_words)

func _source_arc_rand_murmur_hash3_words(words: Array) -> Array:
	var x: Array = _source_words_clone(words)
	x = _source_words_xor(x, _source_words_unsigned_shift_right(x, 33))
	x = _source_words_mul(x, SOURCE_RAND_MURMUR_CONST1_WORDS)
	x = _source_words_xor(x, _source_words_unsigned_shift_right(x, 33))
	x = _source_words_mul(x, SOURCE_RAND_MURMUR_CONST2_WORDS)
	x = _source_words_xor(x, _source_words_unsigned_shift_right(x, 33))
	return x

func _source_arc_rand_set_seed(source_seed: int) -> Dictionary:
	var seed_words: Array = SOURCE_LONG_MIN_WORDS.duplicate() if source_seed == 0 else _source_words_from_nonnegative(source_seed)
	var seed0: Array = _source_arc_rand_murmur_hash3_words(seed_words)
	return {"seed0": seed0, "seed1": _source_arc_rand_murmur_hash3_words(seed0)}

func _source_arc_rand_next_long_words(rand_state: Dictionary) -> Array:
	var s1: Array = (rand_state["seed0"] as Array).duplicate()
	var s0: Array = (rand_state["seed1"] as Array).duplicate()
	rand_state["seed0"] = s0
	s1 = _source_words_xor(s1, _source_words_shift_left(s1, 23))
	var seed1: Array = _source_words_xor(_source_words_xor(_source_words_xor(s1, s0), _source_words_unsigned_shift_right(s1, 17)), _source_words_unsigned_shift_right(s0, 26))
	rand_state["seed1"] = seed1
	return _source_words_add(seed1, s0)

func _source_arc_rand_next_int_unbounded(rand_state: Dictionary) -> int:
	return _source_words_to_signed(_source_arc_rand_next_long_words(rand_state))

func _source_arc_rand_next_long_bound(rand_state: Dictionary, bound: int) -> int:
	if bound <= 0:
		push_error("Rand.nextLong bound must be positive")
		return 0
	while true:
		var bits: int = _source_words_to_nonnegative(_source_words_unsigned_shift_right(_source_arc_rand_next_long_words(rand_state), 1))
		var value: int = bits % bound
		if bits - value + (bound - 1) >= 0:
			return value
	return 0

func _source_arc_rand_next_int_bound(rand_state: Dictionary, bound: int) -> int:
	return _source_arc_rand_next_long_bound(rand_state, bound)

func _source_arc_random_seed_int(source_seed: int, min_value: int, max_value: int) -> int:
	var rand_state := _source_arc_rand_set_seed(source_seed)
	if _source_arc_is_power_of_two(max_value):
		_source_arc_rand_next_int_unbounded(rand_state)
	return _source_arc_rand_next_int_bound(rand_state, max_value - min_value + 1) + min_value

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
	var draw_cracks := bool(_args[0] if _args.size() > 0 else false)
	var damaged_state := bool(_args[1] if _args.size() > 1 else false)
	var block_size_value := int(_args[2] if _args.size() > 2 else 1)
	var max_crack_size := int(_args[3] if _args.size() > 3 else 0)
	var health_fraction := float(_args[4] if _args.size() > 4 else 1.0)
	var crack_regions := int(_args[5] if _args.size() > 5 else 1)
	var position_id := int(_args[6] if _args.size() > 6 else 0)
	if not draw_cracks or not damaged_state or block_size_value > max_crack_size:
		return {"visible": false}
	var crack_index := clampi(int((1.0 - health_fraction) * float(crack_regions)), 0, crack_regions - 1)
	var lightness := 0.1 + (1.0 - health_fraction) * 0.6
	var crack_rotation_degrees := (position_id % 4) * 90
	return {"visible": true, "region_size_index": block_size_value - 1, "crack_index": crack_index, "lightness": lightness, "rotation_degrees": crack_rotation_degrees}

func java_method_drawSelect_125(_args: Array = []) -> Variant:
	var block_status := str(_args[0] if _args.size() > 0 else "")
	var source_x := float(_args[1] if _args.size() > 1 else 0.0)
	var source_y := float(_args[2] if _args.size() > 2 else 0.0)
	var source_rotation := float(_args[3] if _args.size() > 3 else 0.0)
	var tile_x := int(_args[4] if _args.size() > 4 else 0)
	var tile_y := int(_args[5] if _args.size() > 5 else 0)
	var unit_activation_delay := float(_args[6] if _args.size() > 6 else 0.0)
	var state_tick := float(_args[7] if _args.size() > 7 else 0.0)
	var inactive_unit_factory := block_status == "inactiveUnitFactory"
	var remaining_activation_delay := maxf(0.0, unit_activation_delay - state_tick)
	return {"overlay_visible": true, "overlay_x": source_x, "overlay_y": source_y, "overlay_rotation": source_rotation, "place_text_visible": inactive_unit_factory, "place_text_bundle_key": "rules.unitfactoryactivation.objective", "place_text_time": remaining_activation_delay, "place_text_tile_x": tile_x, "place_text_tile_y": tile_y}

func java_method_drawItemSelection_126(_args: Array = []) -> Variant:
	var has_selection := bool(_args[0] if _args.size() > 0 else false)
	var source_x := float(_args[1] if _args.size() > 1 else 0.0)
	var source_y := float(_args[2] if _args.size() > 2 else 0.0)
	var block_size_value := int(_args[3] if _args.size() > 3 else 1)
	var source_tilesize := float(_args[4] if _args.size() > 4 else 8.0)
	var icon_small := float(_args[5] if _args.size() > 5 else 0.0)
	var selection_icon_ratio := float(_args[6] if _args.size() > 6 else 1.0)
	if not has_selection:
		return {"visible": false}
	var dx := source_x - float(block_size_value) * source_tilesize / 2.0
	var dy := source_y + float(block_size_value) * source_tilesize / 2.0
	var selection_width := icon_small / 4.0 * selection_icon_ratio
	var selection_height := icon_small / 4.0
	return {"visible": true, "dx": dx, "dy": dy, "shadow_color": "darkGray", "shadow_alpha": 1.0, "shadow_y": dy - 1.0, "foreground_y": dy, "selection_width": selection_width, "selection_height": selection_height}

func java_method_drawDisabled_127(_args: Array = []) -> Variant:
	var source_x := float(_args[0] if _args.size() > 0 else 0.0)
	var source_y := float(_args[1] if _args.size() > 1 else 0.0)
	var disabled_icon_size := 6.0
	return {"visible": true, "icon": "cancel", "color": "scarlet", "alpha": 0.8, "x": source_x, "y": source_y, "width": disabled_icon_size, "height": disabled_icon_size}

func java_method_draw_128(_args: Array = []) -> Variant:
	var variants := int(_args[0] if _args.size() > 0 else 0)
	var has_variant_regions := bool(_args[1] if _args.size() > 1 else false)
	var variant_region_count := int(_args[2] if _args.size() > 2 else 0)
	var tile_pos := int(_args[3] if _args.size() > 3 else 0)
	var source_x := float(_args[4] if _args.size() > 4 else 0.0)
	var source_y := float(_args[5] if _args.size() > 5 else 0.0)
	var block_rotate := bool(_args[6] if _args.size() > 6 else false)
	var block_rotate_draw := bool(_args[7] if _args.size() > 7 else false)
	var rotation_quadrants := int(_args[8] if _args.size() > 8 else 0)
	var draw_rotation := float(rotation_quadrants * 90) if block_rotate and block_rotate_draw else 0.0
	if variants == 0 or not has_variant_regions:
		return {"visible": true, "region_kind": "region", "variant_index": -1, "x": source_x, "y": source_y, "rotation_degrees": draw_rotation, "draw_team_top": true}
	var max_variant_index: int = max(0, variant_region_count - 1)
	var variant_index: int = _source_arc_random_seed_int(tile_pos, 0, max_variant_index)
	return {"visible": true, "region_kind": "variant_region", "variant_index": variant_index, "x": source_x, "y": source_y, "rotation_degrees": draw_rotation, "draw_team_top": true}

func java_method_drawCached_129(_args: Array = []) -> Variant:
	return java_method_draw_128(_args)

func java_method_recache_130(_args: Array = []) -> Variant:
	var headless := bool(_args[0] if _args.size() > 0 else false)
	var building_cache_layer: Variant = _args[1] if _args.size() > 1 else null
	var tile_state: Variant = _args[2] if _args.size() > 2 else null
	if headless:
		return {"method": "public void recache(){", "headless_gate": "if(!headless) renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);", "recache_call": "", "recache": false, "building_cache_layer": building_cache_layer, "tile": tile_state}
	return {"method": "public void recache(){", "headless_gate": "if(!headless) renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);", "recache_call": "renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);", "recache": true, "building_cache_layer": building_cache_layer, "tile": tile_state}

func java_method_payloadDraw_131(_args: Array = []) -> Variant:
	var draw_cached := bool(_args[0] if _args.size() > 0 else false)
	var draw_dynamic := bool(_args[1] if _args.size() > 1 else false)
	var current_z := float(_args[2] if _args.size() > 2 else 0.0)
	var building_cache_layer_z := float(_args[3] if _args.size() > 3 else 0.0)
	var variants := int(_args[4] if _args.size() > 4 else 0)
	var has_variant_regions := bool(_args[5] if _args.size() > 5 else false)
	var variant_region_count := int(_args[6] if _args.size() > 6 else 0)
	var tile_pos := int(_args[7] if _args.size() > 7 else 0)
	var source_x := float(_args[8] if _args.size() > 8 else 0.0)
	var source_y := float(_args[9] if _args.size() > 9 else 0.0)
	var block_rotate := bool(_args[10] if _args.size() > 10 else false)
	var block_rotate_draw := bool(_args[11] if _args.size() > 11 else false)
	var rotation_quadrants := int(_args[12] if _args.size() > 12 else 0)
	var draw_args := [variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants]
	var cached_draw: Dictionary = {}
	var dynamic_draw: Dictionary = {}
	if draw_cached:
		cached_draw = java_method_drawCached_129(draw_args)
	if draw_dynamic:
		dynamic_draw = java_method_draw_128(draw_args)
	return {"method": "public void payloadDraw(){", "saved_z_call": "float z = Draw.z();", "cached_gate": "if(block.drawCached){" if draw_cached else "", "cached_z_call": "Draw.z(block.buildingCacheLayer.layer);" if draw_cached else "", "cached_draw_call": "drawCached();" if draw_cached else "", "dynamic_gate": "if(block.drawDynamic){" if draw_dynamic else "", "restore_z_call": "Draw.z(z);" if draw_dynamic else "", "dynamic_draw_call": "draw();" if draw_dynamic else "", "saved_z": current_z, "cached_visible": draw_cached, "cached_z": building_cache_layer_z, "cached_draw": cached_draw, "dynamic_visible": draw_dynamic, "dynamic_z": current_z, "dynamic_draw": dynamic_draw}

func java_method_drawTeamTop_132(_args: Array = []) -> Variant:
	var team_region_found := bool(_args[0] if _args.size() > 0 else false)
	var team_region_matches_team := bool(_args[1] if _args.size() > 1 else false)
	var team_color := String(_args[2] if _args.size() > 2 else "")
	var source_x := float(_args[3] if _args.size() > 3 else 0.0)
	var source_y := float(_args[4] if _args.size() > 4 else 0.0)
	if not team_region_found:
		return {"visible": false}
	return {"visible": true, "tint_color": team_color if team_region_matches_team else "", "x": source_x, "y": source_y, "color_reset": true}

func java_method_drawLight_133(_args: Array = []) -> Variant:
	var has_liquids := bool(_args[0] if _args.size() > 0 else false)
	var draw_liquid_light := bool(_args[1] if _args.size() > 1 else false)
	var light_liquid_is_null := bool(_args[2] if _args.size() > 2 else false)
	var current_liquid_color := String(_args[3] if _args.size() > 3 else "")
	var current_liquid_alpha := float(_args[4] if _args.size() > 4 else 0.0)
	var light_liquid_color := String(_args[5] if _args.size() > 5 else "")
	var light_liquid_alpha := float(_args[6] if _args.size() > 6 else 0.0)
	var selected_liquid_amount := float(_args[7] if _args.size() > 7 else 0.0)
	var visual_liquid := float(_args[8] if _args.size() > 8 else 0.0)
	var source_delta := float(_args[9] if _args.size() > 9 else 0.0)
	var source_x := float(_args[10] if _args.size() > 10 else 0.0)
	var source_y := float(_args[11] if _args.size() > 11 else 0.0)
	var block_size_value := int(_args[12] if _args.size() > 12 else 0)
	var selected_color: String = current_liquid_color if light_liquid_is_null else light_liquid_color
	var selected_alpha: float = current_liquid_alpha if light_liquid_is_null else light_liquid_alpha
	if not has_liquids or not draw_liquid_light or selected_alpha <= 0.001:
		return {"visible": false, "visual_liquid": visual_liquid}
	var target: float = 1.0 if selected_liquid_amount >= 0.01 else 0.0
	var next_visual_liquid: float = lerp(visual_liquid, target, clamp(0.06 * source_delta, 0.0, 1.0))
	var light_state: Dictionary = {"visible": false, "drawLiquidLightCall": "drawLiquidLight(liq, visualLiquid);"}
	if next_visual_liquid > 0.01:
		var fract: float = 1.0
		var opacity: float = selected_alpha * fract
		if opacity > 0.001:
			light_state = {"visible": true, "x": source_x, "y": source_y, "radius": block_size_value * 30.0 * fract, "color": selected_color, "opacity": opacity, "alpha": opacity * next_visual_liquid, "fract": fract}
	light_state["visual_liquid"] = next_visual_liquid
	light_state["drawLiquidLightCall"] = "drawLiquidLight(liq, visualLiquid);"
	return light_state

func java_method_drawLiquidLight_134(_args: Array = []) -> Variant:
	var source_x := float(_args[0] if _args.size() > 0 else 0.0)
	var source_y := float(_args[1] if _args.size() > 1 else 0.0)
	var block_size_value := int(_args[2] if _args.size() > 2 else 0)
	var light_color := String(_args[3] if _args.size() > 3 else "")
	var light_alpha := float(_args[4] if _args.size() > 4 else 0.0)
	var amount := float(_args[5] if _args.size() > 5 else 0.0)
	if amount <= 0.01:
		return {"visible": false}
	var fract: float = 1.0
	var opacity: float = light_alpha * fract
	if opacity <= 0.001:
		return {"visible": false}
	return {"visible": true, "x": source_x, "y": source_y, "radius": block_size_value * 30.0 * fract, "color": light_color, "opacity": opacity, "alpha": opacity * amount, "fract": fract}

func java_method_drawTeam_135(_args: Array = []) -> Variant:
	var team_color := String(_args[0] if _args.size() > 0 else "")
	var source_x := float(_args[1] if _args.size() > 1 else 0.0)
	var source_y := float(_args[2] if _args.size() > 2 else 0.0)
	var block_size_value := int(_args[3] if _args.size() > 3 else 0)
	var source_tilesize := float(_args[4] if _args.size() > 4 else 8.0)
	return {"visible": true, "region": "block-border", "color": team_color, "x": source_x - block_size_value * source_tilesize / 2.0 + 4.0, "y": source_y - block_size_value * source_tilesize / 2.0 + 4.0, "color_reset": true}

func java_method_checkSuppression_136(_args: Array = []) -> Variant:
	var block_suppressable := bool(_args[0] if _args.size() > 0 else false)
	var source_time := float(_args[1] if _args.size() > 1 else 0.0)
	var heal_suppression_time := float(_args[2] if _args.size() > 2 else 0.0)
	var source_delta := float(_args[3] if _args.size() > 3 else 0.0)
	var source_x := float(_args[4] if _args.size() > 4 else 0.0)
	var source_y := float(_args[5] if _args.size() > 5 else 0.0)
	var block_size_value := int(_args[6] if _args.size() > 6 else 0)
	var source_tilesize := float(_args[7] if _args.size() > 7 else 8.0)
	var suppress_color := String(_args[8] if _args.size() > 8 else "")
	var suppressed: bool = block_suppressable and source_time <= heal_suppression_time
	if not suppressed:
		return {"suppressed": false, "particle_visible": false}
	var particle_range: float = block_size_value * source_tilesize / 2.0 - 1.0
	var chance_threshold: float = 0.03 * source_delta
	return {"suppressed": true, "particle_visible": "chanceDelta", "chance_threshold": chance_threshold, "effect": "regenSuppressParticle", "color": suppress_color, "particle_range": particle_range, "x_min": source_x - particle_range, "x_max": source_x + particle_range, "y_min": source_y - particle_range, "y_max": source_y + particle_range}

func java_method_playerPlaced_137(_args: Array = []) -> Variant:
	var config_state: Variant = _args[0] if _args.size() > 0 else null
	return {"method": "public void playerPlaced(Object config){", "comment": "Called after the block is placed by this client.", "call_super": "@CallSuper", "no_op": true, "config_state": config_state}

func java_method_placed_138(_args: Array = []) -> Variant:
	var net_client := bool(_args[0] if _args.size() > 0 else false)
	var consumes_power := bool(_args[1] if _args.size() > 1 else false)
	var outputs_power := bool(_args[2] if _args.size() > 2 else false)
	var has_power := bool(_args[3] if _args.size() > 3 else false)
	var connected_power := bool(_args[4] if _args.size() > 4 else false)
	var linked_to_self := bool(_args[5] if _args.size() > 5 else false)
	var source_pos := int(_args[6] if _args.size() > 6 else -1)
	var should_link_power := (consumes_power or outputs_power) and has_power and connected_power
	if net_client:
		return {"method": "public void placed(){", "comment": "Called after the block is placed by anyone.", "call_super": "@CallSuper", "client_guard": "if(net.client()) return;" if net_client else "", "power_gate": "", "power_node_scan": "", "link_guard": "", "configure_call": "", "returned": true, "power_link_scan": false, "configure": false, "configure_pos": -1}
	if not should_link_power:
		return {"method": "public void placed(){", "comment": "Called after the block is placed by anyone.", "call_super": "@CallSuper", "client_guard": "if(net.client()) return;" if net_client else "", "power_gate": "if((block.consumesPower || block.outputsPower) && block.hasPower && block.connectedPower){" if should_link_power else "", "power_node_scan": "PowerNode.getNodeLinks(tile, block, team, other -> {" if should_link_power else "", "link_guard": "if(!other.power.links.contains(pos())){" if should_link_power else "", "configure_call": "", "returned": false, "power_link_scan": false, "configure": false, "configure_pos": -1}
	var configure := not linked_to_self
	return {"method": "public void placed(){", "comment": "Called after the block is placed by anyone.", "call_super": "@CallSuper", "client_guard": "if(net.client()) return;" if net_client else "", "power_gate": "if((block.consumesPower || block.outputsPower) && block.hasPower && block.connectedPower){" if should_link_power else "", "power_node_scan": "PowerNode.getNodeLinks(tile, block, team, other -> {" if should_link_power else "", "link_guard": "if(!other.power.links.contains(pos())){" if should_link_power else "", "configure_call": "other.configureAny(pos());" if configure else "", "returned": false, "power_link_scan": true, "configure": configure, "configure_pos": source_pos if configure else -1}

func java_method_onRepaired_139(_args: Array = []) -> Variant:
	var has_fog_radius := bool(_args[0] if _args.size() > 0 else false)
	return {"method": "public void onRepaired(){", "call_super": "@CallSuper", "placed_call": "placed();", "fog_gate": "if(block.flags.contains(BlockFlag.hasFogRadius)){" if has_fog_radius else "", "fog_call": "fogControl.forceUpdate(team, self());" if has_fog_radius else "", "has_fog_radius": has_fog_radius, "placed": true, "fog_force_update": has_fog_radius}

func java_method_isCommandable_140(_args: Array = []) -> Variant:
	var block_commandable := bool(_args[0] if _args.size() > 0 else false)
	return {"method": "public boolean isCommandable(){", "return_expr": "return block.commandable;", "block_commandable": block_commandable, "commandable": block_commandable}

func java_method_isPayload_141(_args: Array = []) -> Variant:
	var tile_is_empty_tile := bool(_args[0] if _args.size() > 0 else false)
	return {"method": "public boolean isPayload(){", "return_expr": "return tile == emptyTile;", "tile_is_empty_tile": tile_is_empty_tile, "is_payload": tile_is_empty_tile}

func java_method_overwrote_142(_args: Array = []) -> Variant:
	var previous_state: Variant = _args[0] if _args.size() > 0 else null
	return {"method": "public void overwrote(Seq<Building> previous){", "comment": "Called when a block is placed over some other blocks. This seq will always have at least one item.", "no_op": true, "previous_state": previous_state}

func java_method_onRemoved_143(_args: Array = []) -> Variant:
	var current_state: Variant = _args[0] if _args.size() > 0 else null
	return {"method": "public void onRemoved(){", "no_op": true, "current_state": current_state}

func java_method_unitOn_144(_args: Array = []) -> Variant:
	var unit_state: Variant = _args[0] if _args.size() > 0 else null
	return {"comment": "Called every frame a unit is on this. Hovering/flying/steppy units do not apply.  ", "method": "public void unitOn(Unit unit){", "empty_body": "public void unitOn(Unit unit){\n    }", "unit_state": unit_state}

func java_method_unitOnAny_145(_args: Array = []) -> Variant:
	var unit_state: Variant = _args[0] if _args.size() > 0 else null
	return {"comment": "Called every frame a unit is on this. Applies to any unit.  ", "method": "public void unitOnAny(Unit unit){", "empty_body": "public void unitOnAny(Unit unit){\n    }", "unit_state": unit_state}

func java_method_unitRemoved_146(_args: Array = []) -> Variant:
	var unit_state: Variant = _args[0] if _args.size() > 0 else null
	return {"comment": "Called when a unit that spawned at this tile is removed.", "method": "public void unitRemoved(Unit unit){", "empty_body": "public void unitRemoved(Unit unit){\n    }", "unit_state": unit_state}

func java_method_puddleOn_147(_args: Array = []) -> Variant:
	var puddle_state: Variant = _args[0] if _args.size() > 0 else null
	return {"comment": "Called when a puddle is on this building. Only called at an interval (40 ticks).", "method": "public void puddleOn(Puddle puddle){", "no_op": true, "puddle_state": puddle_state}

func java_method_configured_148(_args: Array = []) -> Variant:
	var value_state: Dictionary = _args[1] if _args.size() > 1 and _args[1] is Dictionary else {}
	var type_name := "void" if bool(value_state.get("is_null", false)) else str(value_state.get("superclass", "")) if bool(value_state.get("is_anonymous_class", false)) else str(value_state.get("class", ""))
	var value_kind := str(value_state.get("kind", ""))
	if value_kind == "Item":
		type_name = "Item"
	if value_kind == "Block":
		type_name = "Block"
	if value_kind == "Liquid":
		type_name = "Liquid"
	if value_kind == "UnitType":
		type_name = "UnitType"
	return {"source_owner": "PortGame.source_building_configured_type_state", "comment": "//null is of type void.class; anonymous classes use their superclass.", "assignment": "Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();", "item_override": "if(value instanceof Item) type = Item.class;", "block_override": "if(value instanceof Block) type = Block.class;", "liquid_override": "if(value instanceof Liquid) type = Liquid.class;", "unit_type_override": "if(value instanceof UnitType) type = UnitType.class;", "type_name": type_name, "value_state": value_state}

func java_method_updateLastAccess_149(_args: Array = []) -> Variant:
	var builder_state: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	var current_last_accessed := str(_args[1] if _args.size() > 1 else "")
	var last_accessed := str(builder_state.get("colored_name", ""))
	return {"source_owner": "PortGame.source_building_configured_last_access_state", "method": "public void updateLastAccess(Player player){", "assignment": "lastAccessed = player.coloredName();", "last_accessed": last_accessed, "updated": true, "builder_state": builder_state, "current_last_accessed": current_last_accessed}

func java_method_tapped_150(_args: Array = []) -> Variant:
	var current_state: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_building_tapped_state", "comment": "Called when the block is tapped by the local player.", "method": "public void tapped(){", "empty_body": "public void tapped(){\n\n    }", "current_state": current_state, "no_op": true}

func java_method_afterDestroyed_151(_args: Array = []) -> Variant:
	var has_destroy_bullet := bool(_args[0] if _args.size() > 0 else false)
	var destroy_bullet_same_team := bool(_args[1] if _args.size() > 1 else false)
	var team_id := str(_args[2] if _args.size() > 2 else "")
	var source_x := float(_args[3] if _args.size() > 3 else 0.0)
	var source_y := float(_args[4] if _args.size() > 4 else 0.0)
	var building_id := int(_args[5] if _args.size() > 5 else 0)
	return {"source_owner": "PortGame.source_building_after_destroyed_state", "comment": "Called *after* the tile has been removed.", "method": "public void afterDestroyed(){", "guard": "if(block.destroyBullet != null){", "create_call": "block.destroyBullet.create(this, block.destroyBulletSameTeam ? team : Team.derelict, x, y, Mathf.randomSeed(id(), 360f));", "team_choice": "block.destroyBulletSameTeam ? team : Team.derelict", "rotation_expr": "Mathf.randomSeed(id(), 360f)", "has_destroy_bullet": has_destroy_bullet, "destroy_bullet_same_team": destroy_bullet_same_team, "team_id": team_id, "source_x": source_x, "source_y": source_y, "building_id": building_id}

func java_method_explosionItemCap_152(_args: Array = []) -> Variant:
	var item_capacity := int(_args[0] if _args.size() > 0 else 0)
	return {"source_owner": "PortGame.source_building_explosion_item_cap_state", "comment": "@return the cap for item amount calculations, used when this block explodes.", "method": "public int explosionItemCap(){", "return_expr": "return block.itemCapacity;", "item_capacity": item_capacity, "explosion_item_cap": item_capacity}

func java_method_splashLiquid_153(_args: Array = []) -> Variant:
	var liquid: Variant = _args[0] if _args.size() > 0 else null
	var amount := float(_args[1] if _args.size() > 1 else 0.0)
	var source_block_size := int(_args[2] if _args.size() > 2 else 0)
	var source_tilesize := float(_args[3] if _args.size() > 3 else 0.0)
	var splash := clampf(amount / 4.0, 0.0, 10.0)
	var deposit_count := int(ceil(clampf(amount / 5.0, 0.0, 30.0)))
	var delays: Array[float] = []
	for i in deposit_count:
		delays.append(float(i) / 2.0)
	return {"source_owner": "PortGame.source_building_splash_liquid_state", "method": "public void splashLiquid(Liquid liquid, float amount){", "splash_expr": "float splash = Mathf.clamp(amount / 4f, 0f, 10f);", "loop": "for(int i = 0; i < Mathf.clamp(amount / 5, 0, 30); i++){", "delay_expr": "Time.run(i / 2f, () -> {", "tile_world": "Tile other = world.tileWorld(x + Mathf.range(block.size * tilesize / 2), y + Mathf.range(block.size * tilesize / 2));", "deposit_guard": "if(other != null){", "deposit": "Puddles.deposit(other, liquid, splash);", "liquid": liquid, "amount": amount, "source_block_size": source_block_size, "source_tilesize": source_tilesize, "splash": splash, "deposit_count": deposit_count, "delays": delays, "random_range": float(source_block_size) * source_tilesize / 2.0, "deposit_if_tile_exists": true}

func java_method_onDeconstructed_154(_args: Array = []) -> Variant:
	var has_liquids_module := bool(_args[0] if _args.size() > 0 else false)
	var current_amount := float(_args[1] if _args.size() > 1 else 0.0)
	var current_incinerable := bool(_args[2] if _args.size() > 2 else false)
	var deconstruct_drop_all_liquid := bool(_args[3] if _args.size() > 3 else false)
	var source_block_size := int(_args[4] if _args.size() > 4 else 0)
	var can_drop_liquid := not current_incinerable or deconstruct_drop_all_liquid
	var deposit_linked_tiles := has_liquids_module and current_amount > 0.0 and can_drop_liquid
	var per_cell := 0.0
	if deposit_linked_tiles:
		per_cell = current_amount / float(source_block_size * source_block_size) * 2.0
	return {"source_owner": "PortGame.source_building_on_deconstructed_liquid_state", "comment": "Called when a block begins (not finishes!) deconstruction. The building is still present at this point.", "method": "public void onDeconstructed(@Nullable Unit builder){", "deposit_comment": "//deposit non-incinerable liquid on ground", "gate": "if(liquids != null && liquids.currentAmount() > 0 && (!liquids.current().incinerable || block.deconstructDropAllLiquid)){", "per_cell_expr": "float perCell = liquids.currentAmount() / (block.size * block.size) * 2f;", "deposit_call_expr": "tile.getLinkedTiles(other -> Puddles.deposit(other, liquids.current(), perCell));", "has_liquids_module": has_liquids_module, "current_amount": current_amount, "current_incinerable": current_incinerable, "deconstruct_drop_all_liquid": deconstruct_drop_all_liquid, "source_block_size": source_block_size, "can_drop_liquid": can_drop_liquid, "deposit_linked_tiles": deposit_linked_tiles, "per_cell": per_cell, "deposit_call": deposit_linked_tiles}

func java_method_onDestroyed_155(_args: Array = []) -> Variant:
	var base_explosiveness := float(_args[0] if _args.size() > 0 else 0.0)
	var has_items := bool(_args[1] if _args.size() > 1 else false)
	var item_states: Array = _args[2] if _args.size() > 2 and _args[2] is Array else []
	var item_cap := int(_args[3] if _args.size() > 3 else 0)
	var explosiveness := base_explosiveness
	var flammability := 0.0
	var power := 0.0
	if has_items:
		for item_state in item_states:
			var item_amount: int = min(int(item_state.get("amount", 0)), item_cap)
			explosiveness += float(item_state.get("explosiveness", 0.0)) * float(item_amount)
			flammability += float(item_state.get("flammability", 0.0)) * float(item_amount)
			power += float(item_state.get("charge", 0.0)) * pow(float(item_amount), 1.1) * 150.0
	var has_liquids := bool(_args[4] if _args.size() > 4 else false)
	var liquid_states: Array = _args[5] if _args.size() > 5 and _args[5] is Array else []
	if has_liquids:
		for liquid_state in liquid_states:
			flammability += float(liquid_state.get("flammability", 0.0)) * float(liquid_state.get("amount", 0.0)) / 2.0
			explosiveness += float(liquid_state.get("explosiveness", 0.0)) * float(liquid_state.get("amount", 0.0)) / 2.0
	var current_power := power
	var has_cons_power := bool(_args[6] if _args.size() > 6 else false)
	var cons_power_buffered := bool(_args[7] if _args.size() > 7 else false)
	var power_status := float(_args[8] if _args.size() > 8 else 0.0)
	var cons_power_capacity := float(_args[9] if _args.size() > 9 else 0.0)
	var apply_buffered_power := has_cons_power and cons_power_buffered
	var buffered_power_contribution := power_status * cons_power_capacity if apply_buffered_power else 0.0
	power = current_power + buffered_power_contribution
	var damage_explosions := bool(_args[10] if _args.size() > 10 else false)
	var splash_liquids := has_liquids and damage_explosions
	var splash_call := "liquids.each(this::splashLiquid);" if splash_liquids else ""
	var liquid_count := liquid_states.size() if splash_liquids else 0
	var liquids: Array = liquid_states.duplicate() if splash_liquids else []
	var source_x := float(_args[11] if _args.size() > 11 else 0.0)
	var source_y := float(_args[12] if _args.size() > 12 else 0.0)
	var flammability_scale := float(_args[13] if _args.size() > 13 else 1.0)
	var explosiveness_scale := float(_args[14] if _args.size() > 14 else 1.0)
	var source_tilesize := float(_args[15] if _args.size() > 15 else 0.0)
	var source_block_size := int(_args[16] if _args.size() > 16 else 0)
	var destroy_effect := str(_args[17] if _args.size() > 17 else "")
	var base_shake := float(_args[18] if _args.size() > 18 else 0.0)
	var dynamic_explosion_flammability := flammability * flammability_scale
	var dynamic_explosion_explosiveness := explosiveness * 3.5 * explosiveness_scale
	var dynamic_explosion_radius := source_tilesize * float(source_block_size) / 2.0
	var create_rubble := bool(_args[19] if _args.size() > 19 else false)
	var floor_solid := bool(_args[20] if _args.size() > 20 else false)
	var floor_is_liquid := bool(_args[21] if _args.size() > 21 else false)
	var should_create_rubble := create_rubble and not floor_solid and not floor_is_liquid
	var rubble_call := "Effect.rubble(x, y, block.size);" if should_create_rubble else ""
	var headless := bool(_args[22] if _args.size() > 22 else false)
	var destroy_sound := str(_args[23] if _args.size() > 23 else "")
	var destroy_pitch_min := float(_args[24] if _args.size() > 24 else 0.0)
	var destroy_pitch_max := float(_args[25] if _args.size() > 25 else 0.0)
	var destroy_sound_volume := float(_args[26] if _args.size() > 26 else 0.0)
	var play_destroy_sound := not headless
	var base_destroy_sound := destroy_sound if play_destroy_sound else ""
	var play_reactive_sound := not headless and (explosiveness > 40.0 or flammability > 5.0)
	var reactive_sound_kind := "explosive" if not headless and explosiveness > 40.0 else "flammable" if not headless and flammability > 5.0 else ""
	var reactive_sound := "blockExplodeFlammable" if reactive_sound_kind == "flammable" else ""
	var reactive_sound_choices := ["blockExplodeExplosive", "blockExplodeExplosiveAlt"] if reactive_sound_kind == "explosive" else []
	var reactive_chance := 0.5 if reactive_sound_kind == "explosive" else 0.0
	var play_power_sound := not headless and power > 2000.0
	var power_sound_kind := "big" if not headless and power > 30000.0 else "normal" if not headless and power > 2000.0 else ""
	var power_sound := "blockExplodeElectricBig" if power_sound_kind == "big" else "blockExplodeElectric" if power_sound_kind == "normal" else ""
	return {"source_owner": "PortGame.source_building_on_destroyed_item_explosion_state", "liquid_source_owner": "PortGame.source_building_on_destroyed_liquid_explosion_state", "buffered_power_source_owner": "PortGame.source_building_on_destroyed_buffered_power_state", "splash_liquid_source_owner": "PortGame.source_building_on_destroyed_splash_liquid_state", "dynamic_explosion_source_owner": "PortGame.source_building_on_destroyed_dynamic_explosion_call_state", "rubble_source_owner": "PortGame.source_building_on_destroyed_rubble_state", "base_sound_source_owner": "PortGame.source_building_on_destroyed_base_sound_state", "reactive_sound_source_owner": "PortGame.source_building_on_destroyed_reactive_sound_state", "power_sound_source_owner": "PortGame.source_building_on_destroyed_power_sound_state", "comment": "Called when the block is destroyed. The tile is still intact at this stage.", "method": "public void onDestroyed(){", "dynamic_explosion_comment": "//cap explosiveness so fluid tanks/vaults don't instakill units", "dynamic_explosion_call": "Damage.dynamicExplosion(x, y, flammability * block.flammabilityScale, explosiveness * 3.5f * block.explosivenessScale, power, tilesize * block.size / 2f, state.rules.damageExplosions, block.destroyEffect, block.baseShake);", "rubble_gate": "if(block.createRubble && !floor().solid && !floor().isLiquid){", "rubble_effect_call": "Effect.rubble(x, y, block.size);", "base_sound_gate": "if(!headless){", "base_sound_call": "playDestroySound();", "play_destroy_sound_call": "block.destroySound.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);", "reactive_explosive_gate": "if(explosiveness > 40f){", "reactive_explosive_sound_call": "(Mathf.chance(0.5) ? Sounds.blockExplodeExplosive : Sounds.blockExplodeExplosiveAlt).at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);", "reactive_flammable_gate": "}else if(flammability > 5f){", "reactive_flammable_sound_call": "Sounds.blockExplodeFlammable.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);", "power_sound_big_gate": "if(power > 30000f){", "power_sound_big_call": "Sounds.blockExplodeElectricBig.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);", "power_sound_normal_gate": "}else if(power > 2000f){", "power_sound_normal_call": "Sounds.blockExplodeElectric.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);", "base_explosiveness_expr": "float explosiveness = block.baseExplosiveness;", "flammability_expr": "float flammability = 0f;", "power_expr": "float power = 0f;", "has_items_gate": "if(block.hasItems){", "items_loop": "for(Item item : content.items()){", "amount_expr": "int amount = Math.min(items.get(item), explosionItemCap());", "explosiveness_add": "explosiveness += item.explosiveness * amount;", "flammability_add": "flammability += item.flammability * amount;", "power_add": "power += item.charge * Mathf.pow(amount, 1.1f) * 150f;", "has_liquids_gate": "if(block.hasLiquids){", "liquid_flammability_add": "flammability += liquids.sum((liquid, amount) -> liquid.flammability * amount / 2f);", "liquid_explosiveness_add": "explosiveness += liquids.sum((liquid, amount) -> liquid.explosiveness * amount / 2f);", "buffered_power_guard": "if(block.consPower != null && block.consPower.buffered){", "buffered_power_add": "power += this.power.status * block.consPower.capacity;", "splash_liquid_gate": "if(block.hasLiquids && state.rules.damageExplosions){", "splash_liquid_call": "liquids.each(this::splashLiquid);", "base_explosiveness": base_explosiveness, "has_items": has_items, "item_cap": item_cap, "has_liquids": has_liquids, "damage_explosions": damage_explosions, "splash_liquids": splash_liquids, "call": splash_call, "liquid_count": liquid_count, "liquids": liquids, "headless": headless, "destroy_sound": destroy_sound, "destroy_pitch_min": destroy_pitch_min, "destroy_pitch_max": destroy_pitch_max, "destroy_sound_volume": destroy_sound_volume, "play_destroy_sound": play_destroy_sound, "sound": base_destroy_sound, "pitch_min": destroy_pitch_min, "pitch_max": destroy_pitch_max, "volume": destroy_sound_volume, "play_reactive_sound": play_reactive_sound, "reactive_sound_kind": reactive_sound_kind, "reactive_sound": reactive_sound, "reactive_sound_choices": reactive_sound_choices, "reactive_chance": reactive_chance, "play_power_sound": play_power_sound, "power_sound_kind": power_sound_kind, "power_sound": power_sound, "dynamic_explosion_x": source_x, "dynamic_explosion_y": source_y, "dynamic_explosion_flammability": dynamic_explosion_flammability, "dynamic_explosion_explosiveness": dynamic_explosion_explosiveness, "dynamic_explosion_power": power, "dynamic_explosion_radius": dynamic_explosion_radius, "dynamic_explosion_damage_explosions": damage_explosions, "dynamic_explosion_effect": destroy_effect, "dynamic_explosion_shake": base_shake, "rubble_create_rubble": should_create_rubble, "rubble_call": rubble_call, "rubble_x": source_x, "rubble_y": source_y, "rubble_size": source_block_size if should_create_rubble else 0, "current_power": current_power, "has_cons_power": has_cons_power, "cons_power_buffered": cons_power_buffered, "power_status": power_status, "cons_power_capacity": cons_power_capacity, "apply_buffered_power": apply_buffered_power, "buffered_power_contribution": buffered_power_contribution, "explosiveness": explosiveness, "flammability": flammability, "power": power}

func java_method_playDestroySound_156(_args: Array = []) -> Variant:
	var destroy_sound := str(_args[0] if _args.size() > 0 else "")
	var destroy_pitch_min := float(_args[1] if _args.size() > 1 else 0.0)
	var destroy_pitch_max := float(_args[2] if _args.size() > 2 else 0.0)
	var destroy_sound_volume := float(_args[3] if _args.size() > 3 else 0.0)
	return {"source_owner": "PortGame.source_building_on_destroyed_base_sound_state", "method": "public void playDestroySound(){", "play_destroy_sound_call": "block.destroySound.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);", "destroy_sound": destroy_sound, "destroy_pitch_min": destroy_pitch_min, "destroy_pitch_max": destroy_pitch_max, "destroy_sound_volume": destroy_sound_volume, "sound": destroy_sound, "pitch_min": destroy_pitch_min, "pitch_max": destroy_pitch_max, "volume": destroy_sound_volume}

func java_method_getDisplayName_157(_args: Array = []) -> Variant:
	var localized_name := str(_args[0] if _args.size() > 0 else "")
	var team_is_derelict := bool(_args[1] if _args.size() > 1 else false)
	var team_is_player := bool(_args[2] if _args.size() > 2 else false)
	var team_emoji := str(_args[3] if _args.size() > 3 else "")
	var derelict_label := str(_args[4] if _args.size() > 4 else "")
	var display_name := localized_name
	if team_is_derelict:
		display_name = localized_name + "\n" + derelict_label
	elif not team_is_player and not team_emoji.is_empty():
		display_name = localized_name + " " + team_emoji
	return {"source_owner": "PortGame.source_building_display_name_state", "method": "public String getDisplayName(){", "derelict_comment": "//derelict team icon currently doesn't display", "derelict_return": "block.localizedName + \"\\n\" + Core.bundle.get(\"block.derelict\")", "regular_return": "block.localizedName + (team == player.team() || team.emoji.isEmpty() ? \"\" : \" \" + team.emoji)", "localized_name": localized_name, "team_is_derelict": team_is_derelict, "team_is_player": team_is_player, "team_emoji": team_emoji, "derelict_label": derelict_label, "display_name": display_name}

func java_method_getDisplayIcon_158(_args: Array = []) -> Variant:
	return null

func java_method_flowItems_159(_args: Array = []) -> Variant:
	var items_module: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_building_flow_items_state", "comment": "/** @return the item module to use for flow rate calculations */", "method": "public ItemModule flowItems(){", "return_expr": "return items;", "items_module": items_module, "flow_items": items_module}

func java_method_display_160(_args: Array = []) -> Variant:
	var block_ui_icon: Variant = _args[0] if _args.size() > 0 else null
	var localized_name := str(_args[1] if _args.size() > 1 else "")
	var team_is_derelict := bool(_args[2] if _args.size() > 2 else false)
	var team_is_player := bool(_args[3] if _args.size() > 3 else false)
	var team_emoji := str(_args[4] if _args.size() > 4 else "")
	var derelict_label := str(_args[5] if _args.size() > 5 else "")
	var block_category := str(_args[6] if _args.size() > 6 else "")
	var block_display_flow := bool(_args[7] if _args.size() > 7 else false)
	var net_active := bool(_args[8] if _args.size() > 8 else false)
	var has_last_accessed := bool(_args[9] if _args.size() > 9 else false)
	var icon_state := {"source_owner": "PortGame.source_building_display_icon_state", "block_ui_icon": block_ui_icon, "icon": block_ui_icon}
	var display_name := localized_name
	if team_is_derelict:
		display_name = localized_name + "\n" + derelict_label
	elif not team_is_player and not team_emoji.is_empty():
		display_name = localized_name + " " + team_emoji
	var display_flow := (block_category == "distribution" or block_category == "liquid") and block_display_flow
	var ui_gates := {"display_header": true, "display_same_team_details": team_is_player, "display_bars": team_is_player, "display_consumption": team_is_player, "display_flow": team_is_player and display_flow, "display_last_accessed": team_is_player and net_active and has_last_accessed}
	return {"source_owner": "PortGame.source_building_display_ui_gates_state", "icon_source_owner": "PortGame.source_building_display_icon_state", "name_source_owner": "PortGame.source_building_display_name_state", "method": "public void display(Table table){", "display_block_comment": "//display the block stuff", "todo_comment": "//TODO duplicated code?", "header_icon_call": "t.add(new Image(block.getDisplayIcon(tile))).scaling(Scaling.fit).size(8 * 4);", "header_name_call": "t.labelWrap(block.getDisplayName(tile)).left().width(190f).padLeft(5);", "same_team_comment": "//only display everything else if the team is the same", "same_team_gate": "if(team == player.team()){", "display_bars_call": "displayBars(bars);", "display_consumption_call": "table.table(this::displayConsumption).growX();", "display_flow_formula": "boolean displayFlow = (block.category == Category.distribution || block.category == Category.liquid) && block.displayFlow;", "display_flow_gate": "if(displayFlow){", "last_accessed_gate": "if(net.active() && lastAccessed != null){", "last_accessed_call": "table.add(Core.bundle.format(\"lastaccessed\", lastAccessed)).growX().wrap().left();", "icon": icon_state, "display_name": display_name, "ui_gates": ui_gates, "block_ui_icon": block_ui_icon, "localized_name": localized_name, "team_is_derelict": team_is_derelict, "team_is_player": team_is_player, "team_emoji": team_emoji, "derelict_label": derelict_label, "block_category": block_category, "block_display_flow": block_display_flow, "net_active": net_active, "has_last_accessed": has_last_accessed}

func java_method_displayConsumption_161(_args: Array = []) -> Variant:
	var consumers: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var self_state: Variant = _args[1] if _args.size() > 1 else null
	var built_consumers: Array = []
	var skipped_consumers: Array = []
	for cons in consumers:
		var optional_value := bool(cons.get("optional", false))
		var booster_value := bool(cons.get("booster", false))
		if optional_value and booster_value:
			skipped_consumers.append(cons)
			continue
		built_consumers.append({"consumer": cons, "self_state": self_state})
	return {"source_owner": "PortGame.source_building_display_consumption_state", "method": "public void displayConsumption(Table table){", "table_left_call": "table.left();", "consumers_loop": "for(Consume cons : block.consumers){", "optional_booster_skip": "if(cons.optional && cons.booster) continue;", "build_call": "cons.build(self(), table);", "consumers": consumers, "self_state": self_state, "built_consumers": built_consumers, "skipped_consumers": skipped_consumers}

func java_method_displayBars_162(_args: Array = []) -> Variant:
	var bar_results: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var added_bars: Array = []
	var skipped_bars: Array = []
	for result in bar_results:
		if result == null:
			skipped_bars.append(result)
			continue
		added_bars.append(result)
	return {"source_owner": "PortGame.source_building_display_bars_state", "method": "public void displayBars(Table table){", "bars_loop": "for(Func<Building, Bar> bar : block.listBars()){", "get_result": "var result = bar.get(self());", "null_skip": "if(result == null) continue;", "add_call": "table.add(result).growX();", "row_call": "table.row();", "bar_results": bar_results, "added_bars": added_bars, "skipped_bars": skipped_bars, "row_calls": added_bars.size()}

func java_method_buildConfiguration_163(_args: Array = []) -> Variant:
	return null

func java_method_updateTableAlign_164(_args: Array = []) -> Variant:
	return null

func java_method_getCursor_165(_args: Array = []) -> Variant:
	var block_configurable := bool(_args[0] if _args.size() > 0 else false)
	var interactable_player_team := bool(_args[1] if _args.size() > 1 else false)
	var cursor := "hand" if block_configurable and interactable_player_team else "arrow"
	return {"source_owner": "PortGame.source_building_cursor_state", "comment": "/** Returns whether a hand cursor should be shown over this block. */", "method": "public Cursor getCursor(){", "return_expr": "return block.configurable && interactable(player.team()) ? SystemCursor.hand : SystemCursor.arrow;", "block_configurable": block_configurable, "interactable_player_team": interactable_player_team, "cursor": cursor}

func java_method_onConfigureBuildTapped_166(_args: Array = []) -> Variant:
	return null

func java_method_onConfigureTapped_167(_args: Array = []) -> Variant:
	var x := float(_args[0] if _args.size() > 0 else 0.0)
	var y := float(_args[1] if _args.size() > 1 else 0.0)
	return {"source_owner": "PortGame.source_building_on_configure_tapped_state", "method": "public boolean onConfigureTapped(float x, float y){", "return_false": "return false;", "x": x, "y": y, "consumed": false}

func java_method_onConfigureClosed_168(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_building_on_configure_closed_state", "method": "public void onConfigureClosed(){}", "no_op": true}

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
