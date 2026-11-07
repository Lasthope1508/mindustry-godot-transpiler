# Generated from Mindustry upstream.
# Source: mindustry/world/Block.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world"
const JAVA_KIND := "class"
const JAVA_NAME := "Block"
const JAVA_EXTENDS := "UnlockableContent"
const JAVA_IMPLEMENTS := ["Senseable"]
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "hasItems", "type": "boolean"}, {"modifiers": ["public"], "name": "hasLiquids", "type": "boolean"}, {"modifiers": ["public"], "name": "hasPower", "type": "boolean"}, {"modifiers": ["public"], "name": "outputsLiquid", "type": "boolean"}, {"modifiers": ["public"], "name": "consumesPower", "type": "boolean"}, {"modifiers": ["public"], "name": "outputsPower", "type": "boolean"}, {"modifiers": ["public"], "name": "connectedPower", "type": "boolean"}, {"modifiers": ["public"], "name": "conductivePower", "type": "boolean"}, {"modifiers": ["public"], "name": "outputsPayload", "type": "boolean"}, {"modifiers": ["public"], "name": "acceptsUnitPayloads", "type": "boolean"}, {"modifiers": ["public"], "name": "acceptsPayload", "type": "boolean"}, {"modifiers": ["public"], "name": "acceptsItems", "type": "boolean"}, {"modifiers": ["public"], "name": "alwaysAllowDeposit", "type": "boolean"}, {"modifiers": ["public"], "name": "depositCooldown", "type": "float"}, {"modifiers": ["public"], "name": "separateItemCapacity", "type": "boolean"}, {"modifiers": ["public"], "name": "itemCapacity", "type": "int"}, {"modifiers": ["public"], "name": "liquidCapacity", "type": "float"}, {"modifiers": ["public"], "name": "liquidPressure", "type": "float"}, {"modifiers": ["public"], "name": "outputFacing", "type": "boolean"}, {"modifiers": ["public"], "name": "noSideBlend", "type": "boolean"}, {"modifiers": ["public"], "name": "displayFlow", "type": "boolean"}, {"modifiers": ["public"], "name": "inEditor", "type": "boolean"}, {"modifiers": ["public"], "name": "editorConfigurable", "type": "boolean"}, {"modifiers": ["public"], "name": "lastConfig", "type": "Object"}, {"modifiers": ["public"], "name": "saveConfig", "type": "boolean"}, {"modifiers": ["public"], "name": "copyConfig", "type": "boolean"}, {"modifiers": ["public"], "name": "clearOnDoubleTap", "type": "boolean"}, {"modifiers": ["public"], "name": "update", "type": "boolean"}, {"modifiers": ["public"], "name": "destructible", "type": "boolean"}, {"modifiers": ["public"], "name": "unloadable", "type": "boolean"}, {"modifiers": ["public"], "name": "isDuct", "type": "boolean"}, {"modifiers": ["public"], "name": "allowResupply", "type": "boolean"}, {"modifiers": ["public"], "name": "solid", "type": "boolean"}, {"modifiers": ["public"], "name": "solidifes", "type": "boolean"}, {"modifiers": ["public"], "name": "teamPassable", "type": "boolean"}, {"modifiers": ["public"], "name": "underBullets", "type": "boolean"}, {"modifiers": ["public"], "name": "rotate", "type": "boolean"}, {"modifiers": ["public"], "name": "rotateDraw", "type": "boolean"}, {"modifiers": ["public"], "name": "rotateDrawEditor", "type": "boolean"}, {"modifiers": ["public"], "name": "visualRotationOffset", "type": "float"}, {"modifiers": ["public"], "name": "lockRotation", "type": "boolean"}, {"modifiers": ["public"], "name": "ignoreLineRotation", "type": "boolean"}, {"modifiers": ["public"], "name": "invertFlip", "type": "boolean"}, {"modifiers": ["public"], "name": "variants", "type": "int"}, {"modifiers": ["public"], "name": "drawArrow", "type": "boolean"}, {"modifiers": ["public"], "name": "drawTeamOverlay", "type": "boolean"}, {"modifiers": ["public"], "name": "saveData", "type": "boolean"}, {"modifiers": ["public"], "name": "breakable", "type": "boolean"}, {"modifiers": ["public"], "name": "unitMoveBreakable", "type": "boolean"}, {"modifiers": ["public"], "name": "rebuildable", "type": "boolean"}, {"modifiers": ["public"], "name": "privileged", "type": "boolean"}, {"modifiers": ["public"], "name": "requiresWater", "type": "boolean"}, {"modifiers": ["public"], "name": "placeableLiquid", "type": "boolean"}, {"modifiers": ["public"], "name": "placeablePlayer", "type": "boolean"}, {"modifiers": ["public"], "name": "placeableOn", "type": "boolean"}, {"modifiers": ["public"], "name": "insulated", "type": "boolean"}, {"modifiers": ["public"], "name": "squareSprite", "type": "boolean"}, {"modifiers": ["public"], "name": "absorbLasers", "type": "boolean"}, {"modifiers": ["public"], "name": "enableDrawStatus", "type": "boolean"}, {"modifiers": ["public"], "name": "drawDisabled", "type": "boolean"}, {"modifiers": ["public"], "name": "autoResetEnabled", "type": "boolean"}, {"modifiers": ["public"], "name": "noUpdateDisabled", "type": "boolean"}, {"modifiers": ["public"], "name": "updateInUnits", "type": "boolean"}, {"modifiers": ["public"], "name": "alwaysUpdateInUnits", "type": "boolean"}, {"modifiers": ["public"], "name": "canPickup", "type": "boolean"}, {"modifiers": ["public"], "name": "deconstructDropAllLiquid", "type": "boolean"}, {"modifiers": ["public"], "name": "useColor", "type": "boolean"}, {"modifiers": ["public"], "name": "itemDrop", "type": "Item"}, {"modifiers": ["public"], "name": "playerUnmineable", "type": "boolean"}, {"modifiers": ["public"], "name": "attributes", "type": "Attributes"}, {"modifiers": ["public"], "name": "scaledHealth", "type": "float"}, {"modifiers": ["public"], "name": "health", "type": "int"}, {"modifiers": ["public"], "name": "armor", "type": "float"}, {"modifiers": ["public"], "name": "baseExplosiveness", "type": "float"}, {"modifiers": ["public"], "name": "explosivenessScale", "type": "float"}, {"modifiers": ["public"], "name": "flammabilityScale", "type": "float"}, {"modifiers": ["public"], "name": "baseShake", "type": "float"}, {"modifiers": ["public"], "name": "destroyBullet", "type": "BulletType"}, {"modifiers": ["public"], "name": "destroyBulletSameTeam", "type": "boolean"}, {"modifiers": ["public"], "name": "lightLiquid", "type": "Liquid"}, {"modifiers": ["public"], "name": "drawCracks", "type": "boolean"}, {"modifiers": ["public"], "name": "createRubble", "type": "boolean"}, {"modifiers": ["public"], "name": "floating", "type": "boolean"}, {"modifiers": ["public"], "name": "size", "type": "int"}, {"modifiers": ["public"], "name": "offset", "type": "float"}, {"modifiers": ["public"], "name": "sizeOffset", "type": "int"}, {"modifiers": ["public"], "name": "clipSize", "type": "float"}, {"modifiers": ["public"], "name": "lightClipSize", "type": "float"}, {"modifiers": ["public"], "name": "placeOverlapRange", "type": "float"}, {"modifiers": ["public"], "name": "crushDamageMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "crushFragile", "type": "boolean"}, {"modifiers": ["public"], "name": "timers", "type": "int"}, {"modifiers": ["public"], "name": "cacheLayer", "type": "CacheLayer"}, {"modifiers": ["public"], "name": "drawDynamic", "type": "boolean"}, {"modifiers": ["public"], "name": "drawCached", "type": "boolean"}, {"modifiers": ["public"], "name": "buildingCacheLayer", "type": "BuildingCacheLayer"}, {"modifiers": ["public"], "name": "fillsTile", "type": "boolean"}, {"modifiers": ["public"], "name": "forceDark", "type": "boolean"}, {"modifiers": ["public"], "name": "alwaysReplace", "type": "boolean"}, {"modifiers": ["public"], "name": "replaceable", "type": "boolean"}, {"modifiers": ["public"], "name": "group", "type": "BlockGroup"}, {"modifiers": ["public"], "name": "flags", "type": "EnumSet"}, {"modifiers": ["public"], "name": "priority", "type": "float"}, {"modifiers": ["public"], "name": "unitCapModifier", "type": "int"}, {"modifiers": ["public"], "name": "configurable", "type": "boolean"}, {"modifiers": ["public"], "name": "configureSound", "type": "Sound"}, {"modifiers": ["public"], "name": "ignoreResizeConfig", "type": "boolean"}, {"modifiers": ["public"], "name": "commandable", "type": "boolean"}, {"modifiers": ["public"], "name": "allowConfigInventory", "type": "boolean"}, {"modifiers": ["public"], "name": "selectionRows", "type": "int"}, {"modifiers": ["public"], "name": "selectionColumns", "type": "int"}, {"modifiers": ["public"], "name": "logicConfigurable", "type": "boolean"}, {"modifiers": ["public"], "name": "delayLandingConfig", "type": "boolean"}, {"modifiers": ["public"], "name": "consumesTap", "type": "boolean"}, {"modifiers": ["public"], "name": "drawLiquidLight", "type": "boolean"}, {"modifiers": ["public"], "name": "envRequired", "type": "int"}, {"modifiers": ["public"], "name": "envEnabled", "type": "int"}, {"modifiers": ["public"], "name": "envDisabled", "type": "int"}, {"modifiers": ["public"], "name": "sync", "type": "boolean"}, {"modifiers": ["public"], "name": "conveyorPlacement", "type": "boolean"}, {"modifiers": ["public"], "name": "allowDiagonal", "type": "boolean"}, {"modifiers": ["public"], "name": "swapDiagonalPlacement", "type": "boolean"}, {"modifiers": ["public"], "name": "allowRectanglePlacement", "type": "boolean"}, {"modifiers": ["public"], "name": "schematicPriority", "type": "int"}, {"modifiers": ["public"], "name": "mapColor", "type": "Color"}, {"modifiers": ["public"], "name": "hasColor", "type": "boolean"}, {"modifiers": ["public"], "name": "targetable", "type": "boolean"}, {"modifiers": ["public"], "name": "attacks", "type": "boolean"}, {"modifiers": ["public"], "name": "suppressable", "type": "boolean"}, {"modifiers": ["public"], "name": "canOverdrive", "type": "boolean"}, {"modifiers": ["public"], "name": "outlineColor", "type": "Color"}, {"modifiers": ["public"], "name": "outlineIcon", "type": "boolean"}, {"modifiers": ["public"], "name": "outlineRadius", "type": "int"}, {"modifiers": ["public"], "name": "outlinedIcon", "type": "int"}, {"modifiers": ["public"], "name": "hasShadow", "type": "boolean"}, {"modifiers": ["public"], "name": "customShadow", "type": "boolean"}, {"modifiers": ["public"], "name": "placePitchChange", "type": "boolean"}, {"modifiers": ["public"], "name": "breakPitchChange", "type": "boolean"}, {"modifiers": ["public"], "name": "placeSound", "type": "Sound"}, {"modifiers": ["public"], "name": "breakSound", "type": "Sound"}, {"modifiers": ["public"], "name": "destroySound", "type": "Sound"}, {"modifiers": ["public"], "name": "destroySoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "destroyPitchMin", "type": "float"}, {"modifiers": ["public"], "name": "destroyPitchMax", "type": "float"}, {"modifiers": ["public"], "name": "albedo", "type": "float"}, {"modifiers": ["public"], "name": "lightColor", "type": "Color"}, {"modifiers": ["public"], "name": "emitLight", "type": "boolean"}, {"modifiers": ["public"], "name": "obstructsLight", "type": "boolean"}, {"modifiers": ["public"], "name": "lightRadius", "type": "float"}, {"modifiers": ["public"], "name": "fogRadius", "type": "int"}, {"modifiers": ["public"], "name": "ambientSound", "type": "Sound"}, {"modifiers": ["public"], "name": "ambientSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "requirements", "type": "ItemStack"}, {"modifiers": ["public"], "name": "category", "type": "Category"}, {"modifiers": ["public"], "name": "buildTime", "type": "float"}, {"modifiers": ["public"], "name": "buildVisibility", "type": "BuildVisibility"}, {"modifiers": ["public"], "name": "buildCostMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "deconstructThreshold", "type": "float"}, {"modifiers": ["public"], "name": "instantDeconstruct", "type": "boolean"}, {"modifiers": ["public"], "name": "instantBuild", "type": "boolean"}, {"modifiers": ["public"], "name": "ignoreBuildDarkness", "type": "boolean"}, {"modifiers": ["public"], "name": "placeEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "breakEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "destroyEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "researchCostMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "researchCostMultipliers", "type": "ObjectFloatMap"}, {"modifiers": ["public"], "name": "researchCost", "type": "ItemStack"}, {"modifiers": ["public"], "name": "forceTeam", "type": "Team"}, {"modifiers": ["public"], "name": "instantTransfer", "type": "boolean"}, {"modifiers": ["public"], "name": "quickRotate", "type": "boolean"}, {"modifiers": ["public"], "name": "allowDerelictRepair", "type": "boolean"}, {"modifiers": ["public"], "name": "subclass", "type": "Class"}, {"modifiers": ["public"], "name": "selectScroll", "type": "float"}, {"modifiers": ["public"], "name": "buildType", "type": "Prov"}, {"modifiers": ["public"], "name": "configurations", "type": "ObjectMap"}, {"modifiers": ["public"], "name": "itemFilter", "type": "boolean"}, {"modifiers": ["public"], "name": "liquidFilter", "type": "boolean"}, {"modifiers": ["public"], "name": "consumers", "type": "Consume"}, {"modifiers": ["public"], "name": "optionalConsumers", "type": "Consume"}, {"modifiers": ["public"], "name": "nonOptionalConsumers", "type": "Consume"}, {"modifiers": ["public"], "name": "updateConsumers", "type": "Consume"}, {"modifiers": ["public"], "name": "hasConsumers", "type": "boolean"}, {"modifiers": ["public"], "name": "consPower", "type": "ConsumePower"}, {"modifiers": ["protected"], "name": "barMap", "type": "OrderedMap"}, {"modifiers": ["protected"], "name": "consumeBuilder", "type": "Seq"}, {"modifiers": ["protected"], "name": "generatedIcons", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "regionRotated1", "type": "int"}, {"modifiers": ["public"], "name": "regionRotated2", "type": "int"}, {"modifiers": ["public"], "name": "region", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "customShadowRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "teamRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "teamRegions", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "variantRegions", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "variantShadowRegions", "type": "TextureRegion"}, {"modifiers": ["final", "protected", "static"], "name": "tempTiles", "type": "Seq"}, {"modifiers": ["final", "protected", "static"], "name": "tempBuilds", "type": "Seq"}, {"modifiers": ["final", "protected"], "name": "timerDump", "type": "int"}, {"modifiers": ["public"], "name": "dumpTime", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Block", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "drawBase", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawBaseCached", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawShadow", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "percentSolid", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "drawEnvironmentLight", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawSideRegion", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPotentialLinks", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlaceText", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "drawPlaceText", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "drawLine", "type": "boolean", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "drawOverlay", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "displayShadow", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "sumAttribute", "parameters": [{"name": "attr", "type": "Attribute", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "getDisplayIcon", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "getDisplayName", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "String"}, {"modifiers": ["public"], "name": "minimapColor", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "getColor", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "Color"}, {"modifiers": ["public"], "name": "outputsItems", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canPlaceOn", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canBreak", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "rotatedOutput", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "rotatedOutput", "parameters": [{"name": "fromX", "type": "int", "varargs": false}, {"name": "fromY", "type": "int", "varargs": false}, {"name": "destination", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "synthetic", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "checkForceDark", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isDarkened", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "addBar", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "sup", "type": "Func", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "removeBar", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "listBars", "parameters": [], "return_type": "Iterable"}, {"modifiers": ["public"], "name": "addLiquidBar", "parameters": [{"name": "liq", "type": "Liquid", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addLiquidBar", "parameters": [{"name": "current", "type": "Func", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterPatch", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "consumesItem", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "consumesLiquid", "parameters": [{"name": "liq", "type": "Liquid", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canReplace", "parameters": [{"name": "other", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getReplacement", "parameters": [{"name": "req", "type": "BuildPlan", "varargs": false}, {"name": "plans", "type": "Seq", "varargs": false}], "return_type": "Block"}, {"modifiers": ["public"], "name": "changePlacementPath", "parameters": [{"name": "points", "type": "Seq", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "diagonalOn", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "changePlacementPath", "parameters": [{"name": "points", "type": "Seq", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "handlePlacementLine", "parameters": [{"name": "plans", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "configSenseable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "nextConfig", "parameters": [], "return_type": "Object"}, {"modifiers": ["public"], "name": "onNewPlan", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlan", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlan", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawOtherPlayerPlan", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawDefaultPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "findPlan", "parameters": [{"name": "list", "type": "Eachable", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "predicate", "type": "Boolf", "varargs": false}], "return_type": "BuildPlan"}, {"modifiers": ["public", "static"], "name": "findPlan", "parameters": [{"name": "list", "type": "Eachable", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "size", "type": "int", "varargs": false}, {"name": "predicate", "type": "Boolf", "varargs": false}], "return_type": "BuildPlan"}, {"modifiers": ["public"], "name": "getPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "drawPlanConfig", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanConfigCenter", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "content", "type": "Object", "varargs": false}, {"name": "region", "type": "String", "varargs": false}, {"name": "cross", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanConfigCenter", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "content", "type": "Object", "varargs": false}, {"name": "region", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanConfigTop", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "planConfigClipSize", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "pointConfig", "parameters": [{"name": "config", "type": "Object", "varargs": false}, {"name": "transformer", "type": "Cons", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public"], "name": "configClear", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "config", "parameters": [{"name": "type", "type": "Class", "varargs": false}, {"name": "config", "type": "Cons2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isAccessible", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "nearbySide", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "index", "type": "int", "varargs": false}, {"name": "out", "type": "Point2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getEdges", "parameters": [], "return_type": "Point2"}, {"modifiers": ["public"], "name": "getInsideEdges", "parameters": [], "return_type": "Point2"}, {"modifiers": ["public"], "name": "iterateTaken", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "placer", "type": "Intc2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "makeIconRegions", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["protected"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "getRegionsToOutline", "parameters": [{"name": "out", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getGeneratedIcons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "resetGeneratedIcons", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "variantRegions", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "hasBuilding", "parameters": [], "return_type": "boolean"}, {"modifiers": ["final", "public"], "name": "newBuilding", "parameters": [], "return_type": "Building"}, {"modifiers": ["public"], "name": "updateClipRadius", "parameters": [{"name": "radiusInWorldUnits", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "bounds", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rect", "type": "Rect", "varargs": false}], "return_type": "Rect"}, {"modifiers": ["public"], "name": "isMultiblock", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isVisible", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isPlaceable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isBanned", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "supportsEnv", "parameters": [{"name": "env", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "buildEditorConfig", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onPicked", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getConfig", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public"], "name": "blockChanged", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "placeBegan", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "previous", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "placeBegan", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "previous", "type": "Block", "varargs": false}, {"name": "builder", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "placeEnded", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "builder", "type": "Unit", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "config", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "beforePlaceBegan", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "previous", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "editorPicked", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isFloor", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isOverlay", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "asFloor", "parameters": [], "return_type": "Floor"}, {"modifiers": ["public"], "name": "isAir", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canBeBuilt", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "environmentBuildable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isStatic", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "findConsumer", "parameters": [{"name": "filter", "type": "Boolf", "varargs": false}], "return_type": "T"}, {"modifiers": ["public"], "name": "hasConsumer", "parameters": [{"name": "cons", "type": "Consume", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "removeConsumer", "parameters": [{"name": "cons", "type": "Consume", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "removeConsumers", "parameters": [{"name": "b", "type": "Boolf", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "consumeLiquid", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}], "return_type": "ConsumeLiquid"}, {"modifiers": ["public"], "name": "consumeLiquids", "parameters": [{"name": "stacks", "type": "LiquidStack", "varargs": true}], "return_type": "ConsumeLiquids"}, {"modifiers": ["public"], "name": "consumePower", "parameters": [{"name": "powerPerTick", "type": "float", "varargs": false}], "return_type": "ConsumePower"}, {"modifiers": ["public"], "name": "consumePowerCond", "parameters": [{"name": "usage", "type": "float", "varargs": false}, {"name": "cons", "type": "Boolf", "varargs": false}], "return_type": "ConsumePower"}, {"modifiers": ["public"], "name": "consumePowerDynamic", "parameters": [{"name": "usage", "type": "Floatf", "varargs": false}], "return_type": "ConsumePower"}, {"modifiers": ["public"], "name": "consumePowerDynamic", "parameters": [{"name": "displayed", "type": "float", "varargs": false}, {"name": "usage", "type": "Floatf", "varargs": false}], "return_type": "ConsumePower"}, {"modifiers": ["public"], "name": "consumePowerBuffered", "parameters": [{"name": "powerCapacity", "type": "float", "varargs": false}], "return_type": "ConsumePower"}, {"modifiers": ["public"], "name": "consumeItem", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "ConsumeItems"}, {"modifiers": ["public"], "name": "consumeItem", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": "ConsumeItems"}, {"modifiers": ["public"], "name": "consumeItems", "parameters": [{"name": "items", "type": "ItemStack", "varargs": true}], "return_type": "ConsumeItems"}, {"modifiers": ["public"], "name": "consumeCoolant", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": "ConsumeCoolant"}, {"modifiers": ["public"], "name": "consumeCoolant", "parameters": [{"name": "amount", "type": "float", "varargs": false}, {"name": "allowLiquid", "type": "boolean", "varargs": false}, {"name": "allowGas", "type": "boolean", "varargs": false}], "return_type": "ConsumeCoolant"}, {"modifiers": ["public"], "name": "consume", "parameters": [{"name": "consume", "type": "T", "varargs": false}], "return_type": "T"}, {"modifiers": ["public"], "name": "setupRequirements", "parameters": [{"name": "cat", "type": "Category", "varargs": false}, {"name": "stacks", "type": "ItemStack", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setupRequirements", "parameters": [{"name": "cat", "type": "Category", "varargs": false}, {"name": "visible", "type": "BuildVisibility", "varargs": false}, {"name": "stacks", "type": "ItemStack", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "requirements", "parameters": [{"name": "cat", "type": "Category", "varargs": false}, {"name": "stacks", "type": "ItemStack", "varargs": false}, {"name": "unlocked", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "requirements", "parameters": [{"name": "cat", "type": "Category", "varargs": false}, {"name": "stacks", "type": "ItemStack", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "requirements", "parameters": [{"name": "cat", "type": "Category", "varargs": false}, {"name": "visible", "type": "BuildVisibility", "varargs": false}, {"name": "stacks", "type": "ItemStack", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "initBuilding", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "researchRequirements", "parameters": [], "return_type": "ItemStack"}, {"modifiers": ["public"], "name": "getDependencies", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getContentType", "parameters": [], "return_type": "ContentType"}, {"modifiers": ["public"], "name": "logicVisible", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "postInit", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "reinitializeConsumers", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "checkContentArrayCapacity", "parameters": [{"name": "items", "type": "int", "varargs": false}, {"name": "liquids", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isHidden", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "createIcons", "parameters": [{"name": "packer", "type": "MultiPacker", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "planRotation", "parameters": [{"name": "rot", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "flipRotation", "parameters": [{"name": "req", "type": "BuildPlan", "varargs": false}, {"name": "x", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getPlanConfigs", "parameters": [{"name": "options", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "sense", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "double"}, {"modifiers": ["public"], "name": "sense", "parameters": [{"name": "content", "type": "Content", "varargs": false}], "return_type": "double"}, {"modifiers": ["public"], "name": "senseObject", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "Object"}]
const JAVA_ENUM_CONSTANTS := []
const source_building_core_state := preload("res://src/game/SourceBuildingCoreState.gd")
const source_block_init_flags_state := preload("res://src/game/SourceBlockInitFlagsState.gd")
const source_block_init_health_state := preload("res://src/game/SourceBlockInitHealthState.gd")
const source_block_init_clip_state := preload("res://src/game/SourceBlockInitClipState.gd")
const source_block_query_state := preload("res://src/game/SourceBlockQueryState.gd")
const source_block_query_basic_state := preload("res://src/game/SourceBlockQueryBasicState.gd")
const source_block_query_placement_state := preload("res://src/game/SourceBlockQueryPlacementState.gd")
const source_block_query_filter_state := preload("res://src/game/SourceBlockQueryFilterState.gd")
const source_block_query_darkness_state := preload("res://src/game/SourceBlockQueryDarknessState.gd")
const source_block_plan_visibility_state := preload("res://src/game/SourceBlockPlanVisibilityState.gd")
const source_block_plan_placement_state := preload("res://src/game/SourceBlockPlanPlacementState.gd")
const source_block_plan_config_state := preload("res://src/game/SourceBlockPlanConfigState.gd")
const source_block_plan_draw_state := preload("res://src/game/SourceBlockPlanDrawState.gd")
const source_block_runtime_geometry_state := preload("res://src/game/SourceBlockRuntimeGeometryState.gd")
const source_block_sense_state := preload("res://src/game/SourceBlockSenseState.gd")
const source_block_draw_state := preload("res://src/game/SourceBlockDrawState.gd")
const source_block_stats_bars_state := preload("res://src/game/SourceBlockStatsBarsState.gd")
const source_block_init_build_time_state := preload("res://src/game/SourceBlockInitBuildTimeState.gd")
const source_block_init_placement_state := preload("res://src/game/SourceBlockInitPlacementState.gd")
const source_block_init_building_default_state := preload("res://src/game/SourceBlockInitBuildingDefaultState.gd")
const source_block_requirements_state := preload("res://src/game/SourceBlockRequirementsState.gd")
const source_block_consume_state := preload("res://src/game/SourceBlockConsumeState.gd")
const source_block_check_content_array_capacity_state := preload("res://src/game/SourceBlockCheckContentArrayCapacityState.gd")
const source_block_load_state := preload("res://src/game/SourceBlockLoadState.gd")
const source_block_icon_state := preload("res://src/game/SourceBlockIconState.gd")
const source_block_init_consumer_state := preload("res://src/game/SourceBlockInitConsumerState.gd")
const source_block_init_item_liquid_filters_state := preload("res://src/game/SourceBlockInitItemLiquidFiltersState.gd")
const source_block_init_set_bars_call_state := preload("res://src/game/SourceBlockInitSetBarsCallState.gd")
const source_block_init_stats_categories_state := preload("res://src/game/SourceBlockInitStatsCategoriesState.gd")
const source_block_init_logic_configurable_state := preload("res://src/game/SourceBlockInitLogicConfigurableState.gd")
const source_block_init_buffered_power_state := preload("res://src/game/SourceBlockInitBufferedPowerState.gd")
const source_block_init_sandbox_visibility_state := preload("res://src/game/SourceBlockInitSandboxVisibilityState.gd")
const source_block_init_sound_state := preload("res://src/game/SourceBlockInitSoundState.gd")
const source_block_reinitialize_consumers_state := preload("res://src/game/SourceBlockReinitializeConsumersState.gd")
const source_block_display_query_state := preload("res://src/game/SourceBlockDisplayQueryState.gd")
const source_block_attribute_state := preload("res://src/game/SourceBlockAttributeState.gd")
const source_block_lifecycle_hook_state := preload("res://src/game/SourceBlockLifecycleHookState.gd")
const source_block_query_consumer_state := preload("res://src/game/SourceBlockQueryConsumerState.gd")
const source_block_get_dependencies_state := preload("res://src/game/SourceBlockGetDependenciesState.gd")
const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_block_research_requirements_state := preload("res://src/game/SourceBlockResearchRequirementsState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_block_plan_geometry_state := preload("res://src/game/SourceBlockPlanGeometryState.gd")
const SOURCE_TILESIZE := source_world_defaults.TILESIZE
const source_builder_runtime_state := preload("res://src/game/SourceBuilderRuntimeState.gd")

func java_method_drawBase_0(_args: Array = []) -> Variant:
	var tile_build_present: bool = bool(_args[0] if _args.size() > 0 else false)
	var variants: int = int(_args[1] if _args.size() > 1 else 0)
	var region_value: Variant = _args[2] if _args.size() > 2 else "region"
	var variant_region: Variant = _args[3] if _args.size() > 3 else "variantRegion"
	var tile_drawx: float = float(_args[4] if _args.size() > 4 else 0.0)
	var tile_drawy: float = float(_args[5] if _args.size() > 5 else 0.0)
	return source_block_draw_state.generated_draw_base_result_state(tile_build_present, variants, region_value, variant_region, tile_drawx, tile_drawy)

func java_method_drawBaseCached_1(_args: Array = []) -> Variant:
	var tile_build_present: bool = bool(_args[0] if _args.size() > 0 else false)
	var variants: int = int(_args[1] if _args.size() > 1 else 0)
	var region_value: Variant = _args[2] if _args.size() > 2 else "region"
	var variant_region: Variant = _args[3] if _args.size() > 3 else "variantRegion"
	var tile_drawx: float = float(_args[4] if _args.size() > 4 else 0.0)
	var tile_drawy: float = float(_args[5] if _args.size() > 5 else 0.0)
	return source_block_draw_state.generated_draw_base_cached_result_state(tile_build_present, variants, region_value, variant_region, tile_drawx, tile_drawy)

func java_method_drawShadow_2(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	var variants: int = int(_args[1] if _args.size() > 1 else 0)
	var custom_shadow_region: Variant = _args[2] if _args.size() > 2 else "customShadowRegion"
	var variant_shadow_region: Variant = _args[3] if _args.size() > 3 else "variantShadowRegion"
	var tile_drawx: float = float(_args[4] if _args.size() > 4 else 0.0)
	var tile_drawy: float = float(_args[5] if _args.size() > 5 else 0.0)
	var shadow_alpha: float = float(_args[6] if _args.size() > 6 else 1.0)
	return source_block_draw_state.generated_draw_shadow_result_state(tile, variants, custom_shadow_region, variant_shadow_region, tile_drawx, tile_drawy, shadow_alpha)

func java_method_percentSolid_3(_args: Array = []) -> Variant:
	var tile_exists: bool = bool(_args[0] if _args.size() > 0 else false)
	var x_value: int = int(_args[1] if _args.size() > 1 else 0)
	var y_value: int = int(_args[2] if _args.size() > 2 else 0)
	var linked_non_liquid_count: float = float(_args[3] if _args.size() > 3 else 0.0)
	var size_value: float = float(_args[4] if _args.size() > 4 else 1.0)
	return source_block_display_query_state.generated_block_percent_solid_result_state(tile_exists, x_value, y_value, linked_non_liquid_count, size_value)

func java_method_drawEnvironmentLight_4(_args: Array = []) -> Variant:
	var tile_worldx: float = float(_args[0] if _args.size() > 0 else 0.0)
	var tile_worldy: float = float(_args[1] if _args.size() > 1 else 0.0)
	var light_radius: float = float(_args[2] if _args.size() > 2 else 0.0)
	var light_color: Variant = _args[3] if _args.size() > 3 else "lightColor"
	var light_alpha: float = float(_args[4] if _args.size() > 4 else 1.0)
	return source_block_draw_state.generated_draw_environment_light_result_state(tile_worldx, tile_worldy, light_radius, light_color, light_alpha)

func java_method_drawPlace_5(_args: Array = []) -> Variant:
	var x_value: int = int(_args[0] if _args.size() > 0 else 0)
	var y_value: int = int(_args[1] if _args.size() > 1 else 0)
	var rotation: int = int(_args[2] if _args.size() > 2 else 0)
	var valid: bool = bool(_args[3] if _args.size() > 3 else false)
	var source_tilesize: float = float(_args[4] if _args.size() > 4 else SOURCE_TILESIZE)
	var offset_value: float = float(_args[5] if _args.size() > 5 else 0.0)
	return source_block_draw_state.generated_draw_place_result_state(x_value, y_value, rotation, valid, source_tilesize, offset_value)

func java_method_drawSideRegion_6(_args: Array = []) -> Variant:
	var region_width := float(_args[0] if _args.size() > 0 else 0.0)
	var region_scale := float(_args[1] if _args.size() > 1 else 1.0)
	var x_value := float(_args[2] if _args.size() > 2 else 0.0)
	var y_value := float(_args[3] if _args.size() > 3 else 0.0)
	var block_size := float(_args[4] if _args.size() > 4 else 1.0)
	var source_tilesize := float(_args[5] if _args.size() > 5 else 8.0)
	var rotation := int(_args[6] if _args.size() > 6 else 0)
	return source_block_draw_state.generated_draw_side_region_result_state(region_width, region_scale, x_value, y_value, block_size, source_tilesize, rotation)

func java_method_drawPotentialLinks_7(_args: Array = []) -> Variant:
	var consumes_power := bool(_args[0] if _args.size() > 0 else false)
	var outputs_power := bool(_args[1] if _args.size() > 1 else false)
	var has_power := bool(_args[2] if _args.size() > 2 else false)
	var connected_power := bool(_args[3] if _args.size() > 3 else false)
	var tile_present := bool(_args[4] if _args.size() > 4 else false)
	var x_value := int(_args[5] if _args.size() > 5 else 0)
	var y_value := int(_args[6] if _args.size() > 6 else 0)
	var source_tilesize := float(_args[7] if _args.size() > 7 else 8.0)
	var offset_value := float(_args[8] if _args.size() > 8 else 0.0)
	var block_size := float(_args[9] if _args.size() > 9 else 1.0)
	var power_links: Array = _args[10] if _args.size() > 10 and _args[10] is Array else []
	var beam_links: Array = _args[11] if _args.size() > 11 and _args[11] is Array else []
	return source_block_draw_state.generated_draw_potential_links_result_state(consumes_power, outputs_power, has_power, connected_power, tile_present, x_value, y_value, source_tilesize, offset_value, block_size, power_links, beam_links)

func java_method_drawPlaceText_8(_args: Array = []) -> Variant:
	var pixelate := bool(_args[0] if _args.size() > 0 else false)
	var text_value := str(_args[1] if _args.size() > 1 else "")
	var x_value := int(_args[2] if _args.size() > 2 else 0)
	var y_value := int(_args[3] if _args.size() > 3 else 0)
	var valid := bool(_args[4] if _args.size() > 4 else false)
	var source_tilesize := float(_args[5] if _args.size() > 5 else 8.0)
	var offset_value := float(_args[6] if _args.size() > 6 else 0.0)
	var block_size := float(_args[7] if _args.size() > 7 else 1.0)
	var layout_width := float(_args[8] if _args.size() > 8 else 0.0)
	var layout_height := float(_args[9] if _args.size() > 9 else 0.0)
	return source_block_draw_state.generated_draw_place_text_simple_result_state(pixelate, text_value, x_value, y_value, valid, source_tilesize, offset_value, block_size, layout_width, layout_height)

func java_method_drawPlaceText_9(_args: Array = []) -> Variant:
	var pixelate := bool(_args[0] if _args.size() > 0 else false)
	var text_value := str(_args[1] if _args.size() > 1 else "")
	var x_value := int(_args[2] if _args.size() > 2 else 0)
	var y_value := int(_args[3] if _args.size() > 3 else 0)
	var color_value: Variant = _args[4] if _args.size() > 4 else "Pal.accent"
	var draw_line := bool(_args[5] if _args.size() > 5 else true)
	var source_tilesize := float(_args[6] if _args.size() > 6 else 8.0)
	var offset_value := float(_args[7] if _args.size() > 7 else 0.0)
	var block_size := float(_args[8] if _args.size() > 8 else 1.0)
	var layout_width := float(_args[9] if _args.size() > 9 else 0.0)
	var layout_height := float(_args[10] if _args.size() > 10 else 0.0)
	return source_block_draw_state.generated_draw_place_text_result_state(pixelate, text_value, x_value, y_value, color_value, draw_line, source_tilesize, offset_value, block_size, layout_width, layout_height)

func java_method_drawOverlay_10(_args: Array = []) -> Variant:
	var x_value: float = float(_args[0] if _args.size() > 0 else 0.0)
	var y_value: float = float(_args[1] if _args.size() > 1 else 0.0)
	var rotation: int = int(_args[2] if _args.size() > 2 else 0)
	return source_block_draw_state.generated_draw_overlay_result_state(x_value, y_value, rotation)

func java_method_displayShadow_11(_args: Array = []) -> Variant:
	var has_shadow: bool = bool(_args[0] if _args.size() > 0 else false)
	var tile: Variant = _args[1] if _args.size() > 1 else null
	return source_block_draw_state.generated_display_shadow_result_state(has_shadow, tile)

func java_method_sumAttribute_12(_args: Array = []) -> Variant:
	var attr_present := bool(_args[0] if _args.size() > 0 else false)
	var tile_present := bool(_args[1] if _args.size() > 1 else false)
	var floating := bool(_args[2] if _args.size() > 2 else false)
	var placeable_liquid := bool(_args[3] if _args.size() > 3 else false)
	var linked_tile_deep_by_index: Array = _args[4] if _args.size() > 4 and _args[4] is Array else []
	var linked_attribute_value_by_index: Array = _args[5] if _args.size() > 5 and _args[5] is Array else []
	return source_block_attribute_state.generated_block_sum_attribute_result_state(attr_present, tile_present, floating, placeable_liquid, linked_tile_deep_by_index, linked_attribute_value_by_index)

func java_method_getDisplayIcon_13(_args: Array = []) -> Variant:
	var tile_build_present: bool = bool(_args[0] if _args.size() > 0 else false)
	var ui_icon: Variant = _args[1] if _args.size() > 1 else "uiIcon"
	var build_display_icon: Variant = _args[2] if _args.size() > 2 else "buildDisplayIcon"
	return source_block_display_query_state.generated_block_get_display_icon_result_state(tile_build_present, ui_icon, build_display_icon)

func java_method_getDisplayName_14(_args: Array = []) -> Variant:
	var tile_build_present: bool = bool(_args[0] if _args.size() > 0 else false)
	var localized_name: String = str(_args[1] if _args.size() > 1 else "")
	var build_display_name: String = str(_args[2] if _args.size() > 2 else "")
	return source_block_display_query_state.generated_block_get_display_name_result_state(tile_build_present, localized_name, build_display_name)

func java_method_minimapColor_15(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	return source_block_display_query_state.generated_block_minimap_color_result_state(tile)

func java_method_getColor_16(_args: Array = []) -> Variant:
	var minimap_color: int = int(_args[0] if _args.size() > 0 else 0)
	var map_color: Variant = _args[1] if _args.size() > 1 else "mapColor"
	var tmp_c3_set_color: Variant = _args[2] if _args.size() > 2 else "Tmp.c3.set(mc)"
	return source_block_display_query_state.generated_block_get_color_result_state(minimap_color, map_color, tmp_c3_set_color)

func java_method_outputsItems_17(_args: Array = []) -> Variant:
	var has_items: bool = bool(_args[0] if _args.size() > 0 else false)
	return source_block_query_state.generated_outputs_items_result_state(has_items)

func java_method_canPlaceOn_18(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	var team: Variant = _args[1] if _args.size() > 1 else null
	var rotation: int = int(_args[2] if _args.size() > 2 else 0)
	return source_block_query_placement_state.generated_can_place_on_result_state(tile, team, rotation)

func java_method_canBreak_19(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	return source_block_query_placement_state.generated_can_break_result_state(tile)

func java_method_rotatedOutput_20(_args: Array = []) -> Variant:
	var rotate_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var x_value: int = int(_args[1] if _args.size() > 1 else 0)
	var y_value: int = int(_args[2] if _args.size() > 2 else 0)
	return source_block_query_placement_state.generated_rotated_output_result_state(rotate_value, x_value, y_value)

func java_method_rotatedOutput_21(_args: Array = []) -> Variant:
	var rotate_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var from_x: int = int(_args[1] if _args.size() > 1 else 0)
	var from_y: int = int(_args[2] if _args.size() > 2 else 0)
	var destination: Variant = _args[3] if _args.size() > 3 else null
	return source_block_query_placement_state.generated_rotated_output_tile_result_state(rotate_value, from_x, from_y, destination)

func java_method_synthetic_22(_args: Array = []) -> Variant:
	var update_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var destructible_value: bool = bool(_args[1] if _args.size() > 1 else false)
	return source_block_query_darkness_state.generated_synthetic_result_state(update_value, destructible_value)

func java_method_checkForceDark_23(_args: Array = []) -> Variant:
	var force_dark_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var tile: Variant = _args[1] if _args.size() > 1 else null
	return source_block_query_darkness_state.generated_check_force_dark_result_state(force_dark_value, tile)

func java_method_isDarkened_24(_args: Array = []) -> Variant:
	var solid_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var update_value: bool = bool(_args[1] if _args.size() > 1 else false)
	var destructible_value: bool = bool(_args[2] if _args.size() > 2 else false)
	var fills_tile_value: bool = bool(_args[3] if _args.size() > 3 else false)
	var force_dark_value: bool = bool(_args[4] if _args.size() > 4 else false)
	var tile: Variant = _args[5] if _args.size() > 5 else null
	return source_block_query_darkness_state.generated_is_darkened_result_state(solid_value, update_value, destructible_value, fills_tile_value, force_dark_value, tile)

func java_method_setStats_25(_args: Array = []) -> Variant:
	var size_value: int = int(_args[0] if _args.size() > 0 else 1)
	var synthetic_value: bool = bool(_args[1] if _args.size() > 1 else false)
	var health: float = float(_args[2] if _args.size() > 2 else 0.0)
	var armor: float = float(_args[3] if _args.size() > 3 else 0.0)
	var buildable_value: bool = bool(_args[4] if _args.size() > 4 else false)
	var requirements_length: int = int(_args[5] if _args.size() > 5 else 0)
	var build_time: float = float(_args[6] if _args.size() > 6 else 0.0)
	var instant_transfer: bool = bool(_args[7] if _args.size() > 7 else false)
	var consumers: Array = (_args[8] as Array).duplicate() if _args.size() > 8 and _args[8] is Array else []
	var has_liquids: bool = bool(_args[9] if _args.size() > 9 else false)
	var liquid_capacity: float = float(_args[10] if _args.size() > 10 else 0.0)
	var has_items: bool = bool(_args[11] if _args.size() > 11 else false)
	var item_capacity: int = int(_args[12] if _args.size() > 12 else 0)
	return source_block_stats_bars_state.generated_set_stats_result_state(size_value, synthetic_value, health, armor, buildable_value, requirements_length, build_time, instant_transfer, consumers, has_liquids, liquid_capacity, has_items, item_capacity)

func java_method_addBar_26(_args: Array = []) -> Variant:
	var bar_name: String = str(_args[0] if _args.size() > 0 else "")
	var bar_supplier: Variant = _args[1] if _args.size() > 1 else null
	var bar_map_before: Dictionary = (_args[2] as Dictionary).duplicate() if _args.size() > 2 and _args[2] is Dictionary else {}
	return source_block_stats_bars_state.generated_add_bar_result_state(bar_name, bar_supplier, bar_map_before)

func java_method_removeBar_27(_args: Array = []) -> Variant:
	var bar_name: String = str(_args[0] if _args.size() > 0 else "")
	var bar_map_before: Dictionary = (_args[1] as Dictionary).duplicate() if _args.size() > 1 and _args[1] is Dictionary else {}
	return source_block_stats_bars_state.generated_remove_bar_result_state(bar_name, bar_map_before)

func java_method_listBars_28(_args: Array = []) -> Variant:
	var bar_map: Dictionary = (_args[0] as Dictionary).duplicate() if _args.size() > 0 and _args[0] is Dictionary else {}
	return source_block_stats_bars_state.generated_list_bars_result_state(bar_map)

func java_method_addLiquidBar_29(_args: Array = []) -> Variant:
	var liquid_name: String = str(_args[0] if _args.size() > 0 else "")
	var liquid_unlocked: bool = bool(_args[1] if _args.size() > 1 else false)
	var liquid_amount: float = float(_args[2] if _args.size() > 2 else 0.0)
	var liquid_capacity: float = float(_args[3] if _args.size() > 3 else 1.0)
	var localized_name: String = str(_args[4] if _args.size() > 4 else liquid_name)
	var bar_color: Variant = _args[5] if _args.size() > 5 else "liq.barColor"
	return source_block_stats_bars_state.generated_add_liquid_bar_static_result_state(liquid_name, liquid_unlocked, liquid_amount, liquid_capacity, localized_name, bar_color)

func java_method_addLiquidBar_30(_args: Array = []) -> Variant:
	var current_liquid: Variant = _args[0] if _args.size() > 0 else null
	var current_amount: float = float(_args[1] if _args.size() > 1 else 0.0)
	var liquid_capacity: float = float(_args[2] if _args.size() > 2 else 1.0)
	var localized_name: String = str(_args[3] if _args.size() > 3 else "")
	var bar_color: Variant = _args[4] if _args.size() > 4 else "Color.clear"
	var empty_threshold: float = float(_args[5] if _args.size() > 5 else 0.001)
	return source_block_stats_bars_state.generated_add_liquid_bar_dynamic_result_state(current_liquid, current_amount, liquid_capacity, localized_name, bar_color, empty_threshold)

func java_method_setBars_31(_args: Array = []) -> Variant:
	var cons_power_present: bool = bool(_args[0] if _args.size() > 0 else false)
	var has_items: bool = bool(_args[1] if _args.size() > 1 else false)
	var configurable: bool = bool(_args[2] if _args.size() > 2 else false)
	var item_total: int = int(_args[3] if _args.size() > 3 else 0)
	var item_capacity: int = int(_args[4] if _args.size() > 4 else 1)
	var unit_cap_modifier: int = int(_args[5] if _args.size() > 5 else 0)
	var has_liquids: bool = bool(_args[6] if _args.size() > 6 else false)
	var static_liquid_bar_added: bool = bool(_args[7] if _args.size() > 7 else false)
	return source_block_stats_bars_state.generated_set_bars_result_state(cons_power_present, has_items, configurable, item_total, item_capacity, unit_cap_modifier, has_liquids, static_liquid_bar_added)

func java_method_afterPatch_32(_args: Array = []) -> Variant:
	var size_value: int = int(_args[0] if _args.size() > 0 else 1)
	var source_tilesize: float = float(_args[1] if _args.size() > 1 else SOURCE_TILESIZE)
	var content_items_size: int = int(_args[2] if _args.size() > 2 else 0)
	var content_liquids_size: int = int(_args[3] if _args.size() > 3 else 0)
	var consume_builder: Array = (_args[4] as Array).duplicate() if _args.size() > 4 and _args[4] is Array else []
	return source_block_stats_bars_state.generated_after_patch_result_state(size_value, source_tilesize, content_items_size, content_liquids_size, consume_builder)

func java_method_consumesItem_33(_args: Array = []) -> Variant:
	var item_filter: Array = _args[0] if _args.size() > 0 else []
	var item_id: int = int(_args[1] if _args.size() > 1 else 0)
	var item: Variant = _args[2] if _args.size() > 2 else null
	return source_block_query_filter_state.consumes_item_state(item_filter, item_id, item)

func java_method_consumesLiquid_34(_args: Array = []) -> Variant:
	var liquid_filter: Array = _args[0] if _args.size() > 0 else []
	var liquid_id: int = int(_args[1] if _args.size() > 1 else 0)
	var liq: Variant = _args[2] if _args.size() > 2 else null
	return source_block_query_filter_state.consumes_liquid_state(liquid_filter, liquid_id, liq)

func java_method_canReplace_35(_args: Array = []) -> Variant:
	var existing_always_replace: bool = bool(_args[0] if _args.size() > 0 else false)
	var existing_privileged: bool = bool(_args[1] if _args.size() > 1 else false)
	var existing_replaceable: bool = bool(_args[2] if _args.size() > 2 else false)
	var same_block: bool = bool(_args[3] if _args.size() > 3 else false)
	var new_rotate: bool = bool(_args[4] if _args.size() > 4 else false)
	var new_quick_rotate: bool = bool(_args[5] if _args.size() > 5 else false)
	var new_group_is_none: bool = bool(_args[6] if _args.size() > 6 else true)
	var same_group: bool = bool(_args[7] if _args.size() > 7 else false)
	var new_size: int = int(_args[8] if _args.size() > 8 else 1)
	var existing_size: int = int(_args[9] if _args.size() > 9 else 1)
	var same_subclass: bool = bool(_args[10] if _args.size() > 10 else false)
	var group_any_replace: bool = bool(_args[11] if _args.size() > 11 else false)
	return source_building_core_state.block_can_replace_result_state(existing_always_replace, existing_privileged, existing_replaceable, same_block, new_rotate, new_quick_rotate, new_group_is_none, same_group, new_size, existing_size, same_subclass, group_any_replace)

func java_method_getReplacement_36(_args: Array = []) -> Variant:
	var req: Variant = _args[0] if _args.size() > 0 else null
	var plans: Variant = _args[1] if _args.size() > 1 else []
	var self_block: Variant = _args[2] if _args.size() > 2 else "this"
	return source_block_plan_placement_state.get_replacement_state(req, plans, self_block)

func java_method_changePlacementPath_37(_args: Array = []) -> Variant:
	var points: Variant = _args[0] if _args.size() > 0 else []
	var rotation: int = int(_args[1] if _args.size() > 1 else 0)
	var diagonal_on: bool = bool(_args[2] if _args.size() > 2 else false)
	return source_block_plan_placement_state.change_placement_path_diagonal_state(points, rotation, diagonal_on)

func java_method_changePlacementPath_38(_args: Array = []) -> Variant:
	var points: Variant = _args[0] if _args.size() > 0 else []
	var rotation: int = int(_args[1] if _args.size() > 1 else 0)
	return source_block_plan_placement_state.change_placement_path_state(points, rotation)

func java_method_handlePlacementLine_39(_args: Array = []) -> Variant:
	var plans: Variant = _args[0] if _args.size() > 0 else []
	return source_block_plan_placement_state.handle_placement_line_state(plans)

func java_method_configSenseable_40(_args: Array = []) -> Variant:
	var item_configured: bool = bool(_args[0] if _args.size() > 0 else false)
	var liquid_configured: bool = bool(_args[1] if _args.size() > 1 else false)
	var unlockable_content_configured: bool = bool(_args[2] if _args.size() > 2 else false)
	var block_configured: bool = bool(_args[3] if _args.size() > 3 else false)
	var unit_type_configured: bool = bool(_args[4] if _args.size() > 4 else false)
	return source_block_plan_config_state.config_senseable_state(item_configured, liquid_configured, unlockable_content_configured, block_configured, unit_type_configured)

func java_method_nextConfig_41(_args: Array = []) -> Variant:
	var save_config: bool = bool(_args[0] if _args.size() > 0 else false)
	var last_config: Variant = _args[1] if _args.size() > 1 else null
	return source_block_plan_config_state.next_config_state(save_config, last_config)

func java_method_onNewPlan_42(_args: Array = []) -> Variant:
	var plan: Variant = _args[0] if _args.size() > 0 else null
	return source_block_plan_placement_state.on_new_plan_state(plan)

func java_method_drawPlan_43(_args: Array = []) -> Variant:
	var plan: Variant = _args[0] if _args.size() > 0 else null
	var list: Variant = _args[1] if _args.size() > 1 else []
	var valid: bool = bool(_args[2] if _args.size() > 2 else false)
	return source_block_plan_draw_state.draw_plan_default_alpha_state(plan, list, valid)

func java_method_drawPlan_44(_args: Array = []) -> Variant:
	var plan: Variant = _args[0] if _args.size() > 0 else null
	var list: Variant = _args[1] if _args.size() > 1 else []
	var valid: bool = bool(_args[2] if _args.size() > 2 else false)
	var alpha: float = float(_args[3] if _args.size() > 3 else 1.0)
	var time_absin: float = float(_args[4] if _args.size() > 4 else 0.0)
	return source_block_plan_draw_state.draw_plan_state(plan, list, valid, alpha, time_absin)

func java_method_drawOtherPlayerPlan_45(_args: Array = []) -> Variant:
	var plan: Variant = _args[0] if _args.size() > 0 else null
	var list: Variant = _args[1] if _args.size() > 1 else []
	var alpha: float = float(_args[2] if _args.size() > 2 else 1.0)
	return source_block_plan_draw_state.draw_other_player_plan_state(plan, list, alpha)

func java_method_drawPlanRegion_46(_args: Array = []) -> Variant:
	var plan: Variant = _args[0] if _args.size() > 0 else null
	var list: Variant = _args[1] if _args.size() > 1 else []
	return source_block_plan_draw_state.draw_plan_region_state(plan, list)

func java_method_drawDefaultPlanRegion_47(_args: Array = []) -> Variant:
	var plan: Variant = _args[0] if _args.size() > 0 else null
	var list: Variant = _args[1] if _args.size() > 1 else []
	var rotate_value: bool = bool(_args[2] if _args.size() > 2 else false)
	var rotate_draw: bool = bool(_args[3] if _args.size() > 3 else false)
	var plan_rotation: float = float(_args[4] if _args.size() > 4 else 0.0)
	return source_block_plan_draw_state.draw_default_plan_region_state(plan, list, rotate_value, rotate_draw, plan_rotation)

func java_method_findPlan_48(_args: Array = []) -> Variant:
	var list: Variant = _args[0] if _args.size() > 0 else []
	var x_value: int = int(_args[1] if _args.size() > 1 else 0)
	var y_value: int = int(_args[2] if _args.size() > 2 else 0)
	var predicate: Variant = _args[3] if _args.size() > 3 else null
	return source_block_plan_draw_state.find_plan_default_size_state(list, x_value, y_value, predicate)

func java_method_findPlan_49(_args: Array = []) -> Variant:
	var list: Variant = _args[0] if _args.size() > 0 else []
	var x_value: int = int(_args[1] if _args.size() > 1 else 0)
	var y_value: int = int(_args[2] if _args.size() > 2 else 0)
	var size_value: int = int(_args[3] if _args.size() > 3 else 1)
	var predicate: Variant = _args[4] if _args.size() > 4 else null
	var list_is_query_eachable: bool = bool(_args[5] if _args.size() > 5 else false)
	var query_find_result: Variant = _args[6] if _args.size() > 6 else null
	return source_block_plan_draw_state.find_plan_state(list, x_value, y_value, size_value, predicate, list_is_query_eachable, query_find_result)

func java_method_getPlanRegion_50(_args: Array = []) -> Variant:
	var plan: Variant = _args[0] if _args.size() > 0 else null
	var list: Variant = _args[1] if _args.size() > 1 else []
	var full_icon: Variant = _args[2] if _args.size() > 2 else "fullIcon"
	return source_block_plan_draw_state.get_plan_region_state(plan, list, full_icon)

func java_method_drawPlanConfig_51(_args: Array = []) -> Variant:
	var plan: Variant = _args[0] if _args.size() > 0 else null
	var list: Variant = _args[1] if _args.size() > 1 else []
	return source_block_plan_draw_state.draw_plan_config_state(plan, list)

func java_method_drawPlanConfigCenter_52(_args: Array = []) -> Variant:
	var plan: Variant = _args[0] if _args.size() > 0 else null
	var content: Variant = _args[1] if _args.size() > 1 else null
	var region: String = str(_args[2] if _args.size() > 2 else "")
	var cross: bool = bool(_args[3] if _args.size() > 3 else false)
	var content_color: Variant = _args[4] if _args.size() > 4 else null
	return source_block_plan_draw_state.draw_plan_config_center_state(plan, content, region, cross, content_color)

func java_method_drawPlanConfigCenter_53(_args: Array = []) -> Variant:
	var plan: Variant = _args[0] if _args.size() > 0 else null
	var content: Variant = _args[1] if _args.size() > 1 else null
	var region: String = str(_args[2] if _args.size() > 2 else "")
	return source_block_plan_draw_state.draw_plan_config_center_default_cross_state(plan, content, region)

func java_method_drawPlanConfigTop_54(_args: Array = []) -> Variant:
	var plan: Variant = _args[0] if _args.size() > 0 else null
	var list: Variant = _args[1] if _args.size() > 1 else []
	return source_block_plan_draw_state.draw_plan_config_top_state(plan, list)

func java_method_planConfigClipSize_55(_args: Array = []) -> Variant:
	var clip_size: float = float(_args[0] if _args.size() > 0 else 0.0)
	return source_block_plan_draw_state.plan_config_clip_size_state(clip_size)

func java_method_pointConfig_56(_args: Array = []) -> Variant:
	var config: Variant = _args[0] if _args.size() > 0 else null
	var transformer: Variant = _args[1] if _args.size() > 1 else null
	return source_block_plan_config_state.point_config_state(config, transformer)

func java_method_configClear_57(_args: Array = []) -> Variant:
	var cons: Variant = _args[0] if _args.size() > 0 else null
	return source_block_plan_config_state.config_clear_state(cons)

func java_method_config_58(_args: Array = []) -> Variant:
	var type_value: Variant = _args[0] if _args.size() > 0 else null
	var config_handler: Variant = _args[1] if _args.size() > 1 else null
	return source_block_plan_config_state.config_handler_state(type_value, config_handler)

func java_method_isAccessible_59(_args: Array = []) -> Variant:
	var has_items: bool = bool(_args[0] if _args.size() > 0 else false)
	var item_capacity: int = int(_args[1] if _args.size() > 1 else 0)
	return source_block_plan_config_state.is_accessible_state(has_items, item_capacity)

func java_method_nearbySide_60(_args: Array = []) -> Variant:
	var x_value: int = int(_args[0] if _args.size() > 0 else 0)
	var y_value: int = int(_args[1] if _args.size() > 1 else 0)
	var rotation: int = int(_args[2] if _args.size() > 2 else 0)
	var index_value: int = int(_args[3] if _args.size() > 3 else 0)
	var size_value: int = int(_args[4] if _args.size() > 4 else 1)
	var out_value: Variant = _args[5] if _args.size() > 5 else null
	return source_block_plan_geometry_state.nearby_side_state(x_value, y_value, rotation, index_value, size_value, out_value)

func java_method_getEdges_61(_args: Array = []) -> Variant:
	var size_value: int = int(_args[0] if _args.size() > 0 else 1)
	return source_block_plan_geometry_state.get_edges_state(size_value)

func java_method_getInsideEdges_62(_args: Array = []) -> Variant:
	var size_value: int = int(_args[0] if _args.size() > 0 else 1)
	return source_block_plan_geometry_state.get_inside_edges_state(size_value)

func java_method_iterateTaken_63(_args: Array = []) -> Variant:
	var x_value: int = int(_args[0] if _args.size() > 0 else 0)
	var y_value: int = int(_args[1] if _args.size() > 1 else 0)
	var size_value: int = int(_args[2] if _args.size() > 2 else 1)
	var placer: Variant = _args[3] if _args.size() > 3 else null
	return source_block_plan_geometry_state.iterate_taken_state(x_value, y_value, size_value, placer)

func java_method_makeIconRegions_64(_args: Array = []) -> Variant:
	return source_block_icon_state.generated_make_icon_regions_result_state()

func java_method_icons_65(_args: Array = []) -> Variant:
	var name_value: String = str(_args[0] if _args.size() > 0 else "")
	var variants: int = int(_args[1] if _args.size() > 1 else 0)
	var region_value: Variant = _args[2] if _args.size() > 2 else null
	var team_region_found: bool = bool(_args[3] if _args.size() > 3 else false)
	var minfo_mod: Variant = _args[4] if _args.size() > 4 else null
	var team_regions: Array = (_args[5] as Array).duplicate() if _args.size() > 5 and _args[5] is Array else []
	var team_sharded_id: int = int(_args[6] if _args.size() > 6 else 0)
	return source_block_icon_state.generated_icons_result_state(name_value, variants, region_value, team_region_found, minfo_mod, team_regions, team_sharded_id)

func java_method_getRegionsToOutline_66(_args: Array = []) -> Variant:
	var out_before: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
	return source_block_icon_state.generated_get_regions_to_outline_result_state(out_before)

func java_method_getGeneratedIcons_67(_args: Array = []) -> Variant:
	var generated_icons_before: Variant = _args[0] if _args.size() > 0 else null
	var icons_value: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	return source_block_icon_state.generated_get_generated_icons_result_state(generated_icons_before, icons_value)

func java_method_resetGeneratedIcons_68(_args: Array = []) -> Variant:
	var generated_icons_before: Variant = _args[0] if _args.size() > 0 else null
	return source_block_icon_state.generated_reset_generated_icons_result_state(generated_icons_before)

func java_method_variantRegions_69(_args: Array = []) -> Variant:
	var variant_regions_before: Variant = _args[0] if _args.size() > 0 else null
	var full_icon: Variant = _args[1] if _args.size() > 1 else null
	return source_block_icon_state.generated_variant_regions_result_state(variant_regions_before, full_icon)

func java_method_hasBuilding_70(_args: Array = []) -> Variant:
	var destructible_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var update_value: bool = bool(_args[1] if _args.size() > 1 else false)
	return source_block_query_basic_state.generated_has_building_result_state(destructible_value, update_value)

func java_method_newBuilding_71(_args: Array = []) -> Variant:
	var build_type_value: Variant = _args[0] if _args.size() > 0 else null
	return source_block_runtime_geometry_state.new_building_state(build_type_value)

func java_method_updateClipRadius_72(_args: Array = []) -> Variant:
	var clip_size_before: float = float(_args[0] if _args.size() > 0 else 0.0)
	var size_value: int = int(_args[1] if _args.size() > 1 else 1)
	var tilesize_value: float = float(_args[2] if _args.size() > 2 else 8.0)
	var radius_in_world_units: float = float(_args[3] if _args.size() > 3 else 0.0)
	return source_block_runtime_geometry_state.update_clip_radius_state(clip_size_before, size_value, tilesize_value, radius_in_world_units)

func java_method_bounds_73(_args: Array = []) -> Variant:
	var x_value: int = int(_args[0] if _args.size() > 0 else 0)
	var y_value: int = int(_args[1] if _args.size() > 1 else 0)
	var size_value: int = int(_args[2] if _args.size() > 2 else 1)
	var tilesize_value: float = float(_args[3] if _args.size() > 3 else 8.0)
	var offset_value: float = float(_args[4] if _args.size() > 4 else 0.0)
	var rect_value: Variant = _args[5] if _args.size() > 5 else null
	return source_block_runtime_geometry_state.bounds_state(x_value, y_value, size_value, tilesize_value, offset_value, rect_value)

func java_method_isMultiblock_74(_args: Array = []) -> Variant:
	var size_value: int = int(_args[0] if _args.size() > 0 else 0)
	return source_block_query_basic_state.generated_is_multiblock_result_state(size_value)

func java_method_isVisible_75(_args: Array = []) -> Variant:
	var is_hidden_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var state_rules_editor: bool = bool(_args[1] if _args.size() > 1 else false)
	var state_rules_hide_banned_blocks: bool = bool(_args[2] if _args.size() > 2 else false)
	var is_banned_value: bool = bool(_args[3] if _args.size() > 3 else false)
	return source_block_plan_visibility_state.generated_is_visible_result_state(is_hidden_value, state_rules_editor, state_rules_hide_banned_blocks, is_banned_value)

func java_method_isPlaceable_76(_args: Array = []) -> Variant:
	var placeable_is_visible_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var placeable_is_banned_value: bool = bool(_args[1] if _args.size() > 1 else false)
	var placeable_state_rules_editor: bool = bool(_args[2] if _args.size() > 2 else false)
	var supports_env_value: bool = bool(_args[3] if _args.size() > 3 else false)
	return source_block_plan_visibility_state.generated_is_placeable_result_state(placeable_is_visible_value, placeable_is_banned_value, placeable_state_rules_editor, supports_env_value)

func java_method_isBanned_77(_args: Array = []) -> Variant:
	var rules_is_banned_value: bool = bool(_args[0] if _args.size() > 0 else false)
	return source_block_query_basic_state.generated_is_banned_result_state(rules_is_banned_value)

func java_method_supportsEnv_78(_args: Array = []) -> Variant:
	var env_enabled: int = int(_args[0] if _args.size() > 0 else 0)
	var env_disabled: int = int(_args[1] if _args.size() > 1 else 0)
	var env_required: int = int(_args[2] if _args.size() > 2 else 0)
	var env_value: int = int(_args[3] if _args.size() > 3 else 0)
	return source_block_query_basic_state.generated_supports_env_result_state(env_enabled, env_disabled, env_required, env_value)

func java_method_buildEditorConfig_79(_args: Array = []) -> Variant:
	var table: Variant = _args[0] if _args.size() > 0 else null
	return source_block_lifecycle_hook_state.build_editor_config_state(table)

func java_method_onPicked_80(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	return source_block_lifecycle_hook_state.on_picked_state(tile)

func java_method_getConfig_81(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	return source_block_lifecycle_hook_state.get_config_state(tile)

func java_method_blockChanged_82(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	return source_block_lifecycle_hook_state.block_changed_state(tile)

func java_method_placeBegan_83(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	var previous: Variant = _args[1] if _args.size() > 1 else null
	return source_block_lifecycle_hook_state.place_began_state(tile, previous)

func java_method_placeBegan_84(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	var previous: Variant = _args[1] if _args.size() > 1 else null
	var builder: Variant = _args[2] if _args.size() > 2 else null
	return source_block_lifecycle_hook_state.place_began_builder_state(tile, previous, builder)

func java_method_placeEnded_85(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	var builder: Variant = _args[1] if _args.size() > 1 else null
	var rotation_value: int = int(_args[2] if _args.size() > 2 else 0)
	var config: Variant = _args[3] if _args.size() > 3 else null
	return source_block_lifecycle_hook_state.place_ended_state(tile, builder, rotation_value, config)

func java_method_beforePlaceBegan_86(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	var previous: Variant = _args[1] if _args.size() > 1 else null
	return source_block_lifecycle_hook_state.before_place_began_state(tile, previous)

func java_method_editorPicked_87(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	return source_block_lifecycle_hook_state.editor_picked_state(tile)

func java_method_isFloor_88(_args: Array = []) -> Variant:
	var is_floor_instance: bool = bool(_args[0] if _args.size() > 0 else false)
	return source_block_query_basic_state.generated_is_floor_result_state(is_floor_instance)

func java_method_isOverlay_89(_args: Array = []) -> Variant:
	var is_overlay_floor_instance: bool = bool(_args[0] if _args.size() > 0 else false)
	return source_block_query_basic_state.generated_is_overlay_result_state(is_overlay_floor_instance)

func java_method_asFloor_90(_args: Array = []) -> Variant:
	var self_block: Variant = _args[0] if _args.size() > 0 else null
	return source_block_query_basic_state.generated_as_floor_result_state(self_block)

func java_method_isAir_91(_args: Array = []) -> Variant:
	var id_value: int = int(_args[0] if _args.size() > 0 else 0)
	return source_block_query_basic_state.generated_is_air_result_state(id_value)

func java_method_canBeBuilt_92(_args: Array = []) -> Variant:
	var build_visibility_value: String = str(_args[0] if _args.size() > 0 else "shown")
	return source_block_query_basic_state.generated_can_be_built_result_state(build_visibility_value)

func java_method_environmentBuildable_93(_args: Array = []) -> Variant:
	var is_on_planet_value: bool = bool(_args[0] if _args.size() > 0 else false)
	return source_block_query_basic_state.generated_environment_buildable_result_state(is_on_planet_value)

func java_method_isStatic_94(_args: Array = []) -> Variant:
	var cache_layer_value: String = str(_args[0] if _args.size() > 0 else "normal")
	return source_block_query_basic_state.generated_is_static_result_state(cache_layer_value)

func java_method_findConsumer_95(_args: Array = []) -> Variant:
	var consumers_length: int = int(_args[0] if _args.size() > 0 else 0)
	var consume_builder_match: Variant = _args[1] if _args.size() > 1 else null
	var consumers_match: Variant = _args[2] if _args.size() > 2 else null
	var filter: Variant = _args[3] if _args.size() > 3 else null
	return source_block_query_consumer_state.find_consumer_state(consumers_length, consume_builder_match, consumers_match, filter)

func java_method_hasConsumer_96(_args: Array = []) -> Variant:
	var consume_builder_contains: bool = bool(_args[0] if _args.size() > 0 else false)
	var cons: Variant = _args[1] if _args.size() > 1 else null
	return source_block_query_consumer_state.has_consumer_state(consume_builder_contains, cons)

func java_method_removeConsumer_97(_args: Array = []) -> Variant:
	var consumers_length: int = int(_args[0] if _args.size() > 0 else 0)
	var cons: Variant = _args[1] if _args.size() > 1 else null
	return source_block_query_consumer_state.remove_consumer_state(consumers_length, cons)

func java_method_removeConsumers_98(_args: Array = []) -> Variant:
	var consume_builder_contains_power_after_remove: bool = bool(_args[0] if _args.size() > 0 else false)
	var b: Variant = _args[1] if _args.size() > 1 else null
	return source_block_query_consumer_state.remove_consumers_state(consume_builder_contains_power_after_remove, b)

func java_method_consumeLiquid_99(_args: Array = []) -> Variant:
	var liquid: Variant = _args[0] if _args.size() > 0 else null
	var amount: float = float(_args[1] if _args.size() > 1 else 0.0)
	return source_block_consume_state.generated_consume_liquid_result_state(liquid, amount)

func java_method_consumeLiquids_100(_args: Array = []) -> Variant:
	var stacks: Variant = _args[0] if _args.size() > 0 else []
	return source_block_consume_state.generated_consume_liquids_result_state(stacks)

func java_method_consumePower_101(_args: Array = []) -> Variant:
	var power_per_tick: float = float(_args[0] if _args.size() > 0 else 0.0)
	return source_block_consume_state.generated_consume_power_result_state(power_per_tick)

func java_method_consumePowerCond_102(_args: Array = []) -> Variant:
	var usage: float = float(_args[0] if _args.size() > 0 else 0.0)
	var cons: Variant = _args[1] if _args.size() > 1 else null
	return source_block_consume_state.generated_consume_power_cond_result_state(usage, cons)

func java_method_consumePowerDynamic_103(_args: Array = []) -> Variant:
	var usage: Variant = _args[0] if _args.size() > 0 else null
	return source_block_consume_state.generated_consume_power_dynamic_result_state(usage)

func java_method_consumePowerDynamic_104(_args: Array = []) -> Variant:
	var displayed: float = float(_args[0] if _args.size() > 0 else 0.0)
	var usage: Variant = _args[1] if _args.size() > 1 else null
	return source_block_consume_state.generated_consume_power_dynamic_displayed_result_state(displayed, usage)

func java_method_consumePowerBuffered_105(_args: Array = []) -> Variant:
	var power_capacity: float = float(_args[0] if _args.size() > 0 else 0.0)
	return source_block_consume_state.generated_consume_power_buffered_result_state(power_capacity)

func java_method_consumeItem_106(_args: Array = []) -> Variant:
	var item: Variant = _args[0] if _args.size() > 0 else null
	return source_block_consume_state.generated_consume_item_single_result_state(item)

func java_method_consumeItem_107(_args: Array = []) -> Variant:
	var item: Variant = _args[0] if _args.size() > 0 else null
	var amount: int = int(_args[1] if _args.size() > 1 else 0)
	return source_block_consume_state.generated_consume_item_amount_result_state(item, amount)

func java_method_consumeItems_108(_args: Array = []) -> Variant:
	var items: Array = _args
	return source_block_consume_state.generated_consume_items_varargs_result_state(items)

func java_method_consumeCoolant_109(_args: Array = []) -> Variant:
	var amount: float = float(_args[0] if _args.size() > 0 else 0.0)
	return source_block_consume_state.generated_consume_coolant_single_result_state(amount)

func java_method_consumeCoolant_110(_args: Array = []) -> Variant:
	var amount: float = float(_args[0] if _args.size() > 0 else 0.0)
	var allow_liquid: bool = bool(_args[1] if _args.size() > 1 else false)
	var allow_gas: bool = bool(_args[2] if _args.size() > 2 else false)
	return source_block_consume_state.generated_consume_coolant_filtered_result_state(amount, allow_liquid, allow_gas)

func java_method_consume_111(_args: Array = []) -> Variant:
	var consume: Variant = _args[0] if _args.size() > 0 else null
	var consume_is_power: bool = bool(_args[1] if _args.size() > 1 else false)
	var consume_builder_before: Array = (_args[2] if _args.size() > 2 else []) as Array
	var consume_builder_without_power: Array = (_args[3] if _args.size() > 3 else []) as Array
	var cons_power_before: Variant = _args[4] if _args.size() > 4 else null
	return source_block_consume_state.generated_consume_generic_result_state(consume, consume_is_power, consume_builder_before, consume_builder_without_power, cons_power_before)

func java_method_setupRequirements_112(_args: Array = []) -> Variant:
	var cat: Variant = _args[0] if _args.size() > 0 else null
	var stacks: Variant = _args[1] if _args.size() > 1 else null
	return source_block_requirements_state.generated_setup_requirements_simple_result_state(cat, stacks)

func java_method_setupRequirements_113(_args: Array = []) -> Variant:
	var cat: Variant = _args[0] if _args.size() > 0 else null
	var build_visibility: Variant = _args[1] if _args.size() > 1 else null
	var stacks: Variant = _args[2] if _args.size() > 2 else null
	return source_block_requirements_state.generated_setup_requirements_visible_result_state(cat, build_visibility, stacks)

func java_method_requirements_114(_args: Array = []) -> Variant:
	var cat: Variant = _args[0] if _args.size() > 0 else null
	var stacks: Variant = _args[1] if _args.size() > 1 else null
	var unlocked: bool = bool(_args[2] if _args.size() > 2 else false)
	return source_block_requirements_state.generated_requirements_unlocked_result_state(cat, stacks, unlocked)

func java_method_requirements_115(_args: Array = []) -> Variant:
	var cat: Variant = _args[0] if _args.size() > 0 else null
	var stacks: Variant = _args[1] if _args.size() > 1 else null
	return source_block_requirements_state.generated_requirements_simple_result_state(cat, stacks)

func java_method_requirements_116(_args: Array = []) -> Variant:
	var cat: Variant = _args[0] if _args.size() > 0 else null
	var build_visibility: Variant = _args[1] if _args.size() > 1 else null
	var stacks: Variant = _args[2] if _args.size() > 2 else null
	return source_block_requirements_state.generated_requirements_visible_result_state(cat, build_visibility, stacks)

func java_method_initBuilding_117(_args: Array = []) -> Variant:
	var build_type_before: Variant = _args[0] if _args.size() > 0 else null
	return source_block_init_building_default_state.generated_building_default_result_state(build_type_before)

func java_method_researchRequirements_118(_args: Array = []) -> Variant:
	var research_cost: Variant = _args[0] if _args.size() > 0 else null
	var research_cost_multiplier: float = float(_args[1] if _args.size() > 1 else 1.0)
	var requirements: Array = _args[2] if _args.size() > 2 else []
	var research_cost_multipliers: Dictionary = _args[3] if _args.size() > 3 else {}
	if _args.size() <= 1:
		return source_block_research_requirements_state.research_cost_state(research_cost)
	if _args.size() <= 2:
		return source_block_research_requirements_state.empty_state(research_cost, research_cost_multiplier)
	if _args.size() <= 3:
		return source_block_research_requirements_state.loop_shape_state(research_cost, research_cost_multiplier, requirements)
	if _args.size() <= 4:
		return source_block_research_requirements_state.quantity_formula_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)
	if _args.size() <= 5:
		return source_block_research_requirements_state.round_amount_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)
	return source_block_research_requirements_state.output_fill_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)

func java_method_getDependencies_119(_args: Array = []) -> Variant:
	var requirements: Array = _args[0] if _args.size() > 0 else []
	if _args.size() <= 1:
		return source_block_get_dependencies_state.requirements_state(requirements)
	var consume_builder: Array = _args[1] if _args.size() > 1 else []
	if _args.size() <= 2:
		return source_block_get_dependencies_state.consume_builder_optional_state(requirements, consume_builder)
	return source_block_get_dependencies_state.consume_items_state(requirements, consume_builder)

func java_method_getContentType_120(_args: Array = []) -> Variant:
	return source_block_metadata_state.content_type_state()

func java_method_logicVisible_121(_args: Array = []) -> Variant:
	var build_visibility_value: String = str(_args[0] if _args.size() > 0 else "")
	return source_block_metadata_state.logic_visible_state(build_visibility_value)

func java_method_postInit_122(_args: Array = []) -> Variant:
	if _args.size() <= 2:
		pass
	else:
		var requirements: Array = _args[0] if _args.size() > 0 else []
		var shown_planets_before: Array = _args[1] if _args.size() > 1 else []
		var content_planets: Array = _args[2] if _args.size() > 2 else []
		var shown_planets_after: Array = shown_planets_before.duplicate()
		var auto_assign_guard_passed: bool = requirements.size() > 0 and shown_planets_before.is_empty()
		var evaluated_planets: Array = []
		var landable_planets: Array = []
		var added_planets: Array = []
		var blocked_planets: Array = []
		if auto_assign_guard_passed:
			for planet in content_planets:
				var planet_name: String = str(planet.get("name", ""))
				evaluated_planets.append(planet_name)
				if not bool(planet.get("is_landable", false)):
					continue
				landable_planets.append(planet_name)
				var blocking_requirement_indices: Array = []
				for i in range(requirements.size()):
					var stack: Dictionary = requirements[i]
					var is_on_planets: Array = stack.get("is_on_planets", [])
					if not is_on_planets.has(planet_name):
						blocking_requirement_indices.append(i)
				if blocking_requirement_indices.is_empty():
					shown_planets_after.append(planet_name)
					added_planets.append(planet_name)
				else:
					blocked_planets.append({"planet": planet_name, "blocking_requirement_indices": blocking_requirement_indices})
		return {"source_owner": "port_game.source_block_post_init_shown_planets_state", "source": "core/src/mindustry/world/Block.java", "method": "public void postInit(){", "shown_planets_comment": "//usually, an empty set of planets is a configuration error. auto-assign based on requirements", "auto_assign_guard_expr": "if(requirements.length > 0 && shownPlanets.isEmpty()){", "content_planets_loop_expr": "for(Planet planet : content.planets()){", "planet_landable_guard_expr": "if(planet.isLandable()){", "structs_contains_guard_expr": "if(!Structs.contains(requirements, s -> !s.item.isOnPlanet(planet))){", "shown_planets_add_expr": "shownPlanets.add(planet);", "requirements": requirements, "shown_planets_before": shown_planets_before, "content_planets": content_planets, "shown_planets_after": shown_planets_after, "auto_assign_guard_passed": auto_assign_guard_passed, "evaluated_planets": evaluated_planets, "landable_planets": landable_planets, "added_planets": added_planets, "blocked_planets": blocked_planets}
	var database_tag_before: Variant = _args[0] if _args.size() > 0 else null
	var category_name: String = str(_args[1] if _args.size() > 1 else "")
	var database_tag_after: Variant = database_tag_before
	var database_tag_assigned: bool = database_tag_before == null or str(database_tag_before).is_empty()
	if database_tag_assigned:
		database_tag_after = category_name
	return {"source_owner": "port_game.source_block_post_init_database_tag_state", "source": "core/src/mindustry/world/Block.java", "method": "public void postInit(){", "database_tag_guard_expr": "if(databaseTag == null || databaseTag.isEmpty()){", "database_tag_assign_expr": "databaseTag = category.name();", "super_post_init_expr": "super.postInit();", "database_tag_before": database_tag_before, "category_name": category_name, "database_tag_after": database_tag_after, "database_tag_assigned": database_tag_assigned}

func java_method_init_123(_args: Array = []) -> Variant:
	var init_bridge_mode: String = str(get_meta("mindustry_init_bridge_mode", "destroy_sound"))
	if init_bridge_mode == "custom_shadow":
		var custom_shadow: bool = bool(_args[0] if _args.size() > 0 else false)
		var has_shadow_before: bool = bool(_args[1] if _args.size() > 1 else true)
		return source_block_init_flags_state.generated_custom_shadow_result_state(custom_shadow, has_shadow_before)
	if init_bridge_mode == "under_bullets":
		var under_bullets: bool = bool(_args[0] if _args.size() > 0 else false)
		var priority_before: Variant = _args[1] if _args.size() > 1 else null
		return source_block_init_flags_state.generated_under_bullets_result_state(under_bullets, priority_before)
	if init_bridge_mode == "fog_radius_flag":
		var fog_radius: int = int(_args[0] if _args.size() > 0 else -1)
		var flags_before: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
		return source_block_init_flags_state.generated_fog_radius_flag_result_state(fog_radius, flags_before)
	if init_bridge_mode == "sync_flag":
		var sync_value: bool = bool(_args[0] if _args.size() > 0 else false)
		var flags_before: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
		return source_block_init_flags_state.generated_sync_flag_result_state(sync_value, flags_before)
	if init_bridge_mode == "health_scaled":
		var health_before: int = int(_args[0] if _args.size() > 0 else -1)
		var health_size_value: int = int(_args[1] if _args.size() > 1 else 1)
		var scaled_health: float = float(_args[2] if _args.size() > 2 else 0.0)
		return source_block_init_health_state.generated_health_scaled_result_state(health_before, health_size_value, scaled_health)
	if init_bridge_mode == "health_requirements_scaling":
		var health_before: int = int(_args[0] if _args.size() > 0 else -1)
		var requirements_health_size_value: int = int(_args[1] if _args.size() > 1 else 1)
		var scaled_health_before: float = float(_args[2] if _args.size() > 2 else -1.0)
		var requirement_health_scalings: Array = (_args[3] as Array).duplicate() if _args.size() > 3 and _args[3] is Array else []
		return source_block_init_health_state.generated_health_requirements_scaling_result_state(health_before, requirements_health_size_value, scaled_health_before, requirement_health_scalings)
	if init_bridge_mode == "clip_size":
		var clip_size_before: float = float(_args[0] if _args.size() > 0 else 0.0)
		var clip_size_size_value: int = int(_args[1] if _args.size() > 1 else 1)
		var source_tilesize: float = float(_args[2] if _args.size() > 2 else SOURCE_TILESIZE)
		return source_block_init_clip_state.generated_clip_size_result_state(clip_size_before, clip_size_size_value, source_tilesize)
	if init_bridge_mode == "light_clip_size":
		var light_clip_size_before: float = float(_args[0] if _args.size() > 0 else 0.0)
		var clip_size: float = float(_args[1] if _args.size() > 1 else 0.0)
		return source_block_init_clip_state.generated_light_clip_size_result_state(light_clip_size_before, clip_size)
	if init_bridge_mode == "liquid_light":
		var has_liquids: bool = bool(_args[0] if _args.size() > 0 else false)
		var draw_liquid_light: bool = bool(_args[1] if _args.size() > 1 else false)
		var emit_light_before: bool = bool(_args[2] if _args.size() > 2 else false)
		var light_clip_size_before: float = float(_args[3] if _args.size() > 3 else 0.0)
		var liquid_light_size_value: int = int(_args[4] if _args.size() > 4 else 1)
		return source_block_init_clip_state.generated_liquid_light_result_state(has_liquids, draw_liquid_light, emit_light_before, light_clip_size_before, liquid_light_size_value)
	if init_bridge_mode == "liquid_capacity_default":
		var liquid_capacity_before: float = float(_args[0] if _args.size() > 0 else -1.0)
		return source_block_init_clip_state.generated_liquid_capacity_default_result_state(liquid_capacity_before)
	if init_bridge_mode == "emit_light_radius":
		var emit_light: bool = bool(_args[0] if _args.size() > 0 else false)
		var light_clip_size_before: float = float(_args[1] if _args.size() > 1 else 0.0)
		var light_radius: float = float(_args[2] if _args.size() > 2 else 0.0)
		return source_block_init_clip_state.generated_emit_light_radius_result_state(emit_light, light_clip_size_before, light_radius)
	if init_bridge_mode == "accepts_items":
		var block_group: Variant = _args[0] if _args.size() > 0 else ""
		var category_value: Variant = _args[1] if _args.size() > 1 else ""
		var accepts_items_before: bool = bool(_args[2] if _args.size() > 2 else false)
		return source_block_init_placement_state.generated_accepts_items_result_state(block_group, category_value, accepts_items_before)
	if init_bridge_mode == "offset":
		var offset_size_value: int = int(_args[0] if _args.size() > 0 else 1)
		var source_tilesize: float = float(_args[1] if _args.size() > 1 else SOURCE_TILESIZE)
		return source_block_init_placement_state.generated_offset_result_state(offset_size_value, source_tilesize)
	if init_bridge_mode == "build_time_requirements":
		var build_time_before: float = float(_args[0] if _args.size() > 0 else -1.0)
		var requirement_stacks: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
		return source_block_init_build_time_state.generated_requirements_result_state(build_time_before, requirement_stacks)
	if init_bridge_mode == "build_time_default":
		var default_build_time_before: float = float(_args[0] if _args.size() > 0 else -1.0)
		return source_block_init_build_time_state.generated_default_result_state(default_build_time_before)
	if init_bridge_mode == "build_time_multiplier":
		var multiplier_build_time_before: float = float(_args[0] if _args.size() > 0 else 20.0)
		var build_cost_multiplier: float = float(_args[1] if _args.size() > 1 else 1.0)
		return source_block_init_build_time_state.generated_multiplier_result_state(multiplier_build_time_before, build_cost_multiplier)
	if init_bridge_mode == "consumer_arrays":
		var consumer_builder_entries: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
		return source_block_init_consumer_state.generated_consumer_arrays_result_state(consumer_builder_entries)
	if init_bridge_mode == "item_liquid_filters":
		var content_items_size: int = int(_args[0] if _args.size() > 0 else 0)
		var content_liquids_size: int = int(_args[1] if _args.size() > 1 else 0)
		return source_block_init_item_liquid_filters_state.generated_item_liquid_filters_result_state(content_items_size, content_liquids_size)
	if init_bridge_mode == "consumer_apply_loop":
		var consumer_entries: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
		return source_block_init_consumer_state.generated_consumer_apply_loop_result_state(consumer_entries)
	if init_bridge_mode == "set_bars_call":
		return source_block_init_set_bars_call_state.generated_set_bars_call_result_state()
	if init_bridge_mode == "stats_categories":
		var stats_use_categories_before: bool = bool(_args[0] if _args.size() > 0 else false)
		return source_block_init_stats_categories_state.generated_stats_categories_result_state(stats_use_categories_before)
	if init_bridge_mode == "logic_configurable":
		var logic_configurable_before: bool = bool(_args[0] if _args.size() > 0 else false)
		var config_key_assignable_to_unlockable_content: bool = bool(_args[1] if _args.size() > 1 else false)
		return source_block_init_logic_configurable_state.generated_logic_configurable_result_state(logic_configurable_before, config_key_assignable_to_unlockable_content)
	if init_bridge_mode == "buffered_power":
		var outputs_power: bool = bool(_args[0] if _args.size() > 0 else false)
		var has_cons_power: bool = bool(_args[1] if _args.size() > 1 else false)
		var cons_power_buffered_before: bool = bool(_args[2] if _args.size() > 2 else false)
		return source_block_init_buffered_power_state.generated_buffered_power_result_state(outputs_power, has_cons_power, cons_power_buffered_before)
	if init_bridge_mode == "sandbox_visibility":
		var build_visibility: String = str(_args[0] if _args.size() > 0 else "BuildVisibility.hidden")
		var hide_details_before: bool = bool(_args[1] if _args.size() > 1 else true)
		return source_block_init_sandbox_visibility_state.generated_sandbox_visibility_result_state(build_visibility, hide_details_before)
	if init_bridge_mode == "place_sound":
		var place_sound_before: Variant = _args[0] if _args.size() > 0 else "Sounds.unset"
		var place_size_value: int = int(_args[1] if _args.size() > 1 else 1)
		return source_block_init_sound_state.generated_place_sound_result_state(place_sound_before, place_size_value)
	if init_bridge_mode == "break_sound":
		var break_sound_before: Variant = _args[0] if _args.size() > 0 else "Sounds.unset"
		var break_size_value: int = int(_args[1] if _args.size() > 1 else 1)
		return source_block_init_sound_state.generated_break_sound_result_state(break_sound_before, break_size_value)
	var destroy_sound_before: Variant = _args[0] if _args.size() > 0 else "Sounds.unset"
	var size_value: int = int(_args[1] if _args.size() > 1 else 1)
	return source_block_init_sound_state.generated_destroy_sound_result_state(destroy_sound_before, size_value)

func java_method_reinitializeConsumers_124(_args: Array = []) -> Variant:
	var reinitialize_bridge_mode: String = str(get_meta("mindustry_reinitialize_consumers_bridge_mode", "consumer_arrays"))
	if reinitialize_bridge_mode == "consumer_apply_loop":
		var consumer_entries: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
		return source_block_reinitialize_consumers_state.generated_apply_loop_result_state(consumer_entries)
	if reinitialize_bridge_mode == "outputs_power":
		var outputs_power: bool = bool(_args[0] if _args.size() > 0 else false)
		var has_power_before: bool = bool(_args[1] if _args.size() > 1 else false)
		return source_block_reinitialize_consumers_state.generated_outputs_power_result_state(outputs_power, has_power_before)
	if reinitialize_bridge_mode == "item_liquid_filters":
		var content_items_size: int = int(_args[0] if _args.size() > 0 else 0)
		var content_liquids_size: int = int(_args[1] if _args.size() > 1 else 0)
		return source_block_reinitialize_consumers_state.generated_item_liquid_filters_result_state(content_items_size, content_liquids_size)
	var consumer_builder_entries: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
	return source_block_reinitialize_consumers_state.generated_arrays_result_state(consumer_builder_entries)

func java_method_checkContentArrayCapacity_125(_args: Array = []) -> Variant:
	var item_filter: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
	var liquid_filter: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var items: int = int(_args[2] if _args.size() > 2 else item_filter.size())
	var liquids: int = int(_args[3] if _args.size() > 3 else liquid_filter.size())
	return source_block_check_content_array_capacity_state.generated_check_content_array_capacity_result_state(item_filter, liquid_filter, items, liquids)

func java_method_load_126(_args: Array = []) -> Variant:
	if str(get_meta("mindustry_load_bridge_mode", "")) == "variant_shadow_regions":
		var shadow_load_name_value: String = str(_args[0] if _args.size() > 0 else "")
		var shadow_variants: int = int(_args[1] if _args.size() > 1 else 0)
		var shadow_custom_shadow: bool = bool(_args[2] if _args.size() > 2 else false)
		return source_block_load_state.generated_variant_shadow_regions_result_state(shadow_load_name_value, shadow_variants, shadow_custom_shadow)
	if str(get_meta("mindustry_load_bridge_mode", "")) == "variant_regions":
		var variant_load_name_value: String = str(_args[0] if _args.size() > 0 else "")
		var variants: int = int(_args[1] if _args.size() > 1 else 0)
		return source_block_load_state.generated_variant_regions_result_state(variant_load_name_value, variants)
	if str(get_meta("mindustry_load_bridge_mode", "")) == "team_regions":
		var team_load_name_value: String = str(_args[0] if _args.size() > 0 else "")
		var team_region_found: bool = bool(_args[1] if _args.size() > 1 else false)
		var team_region: Variant = _args[2] if _args.size() > 2 else "teamRegion"
		var teams: Array = (_args[3] as Array).duplicate() if _args.size() > 3 and _args[3] is Array else []
		return source_block_load_state.generated_team_regions_result_state(team_load_name_value, team_region_found, team_region, teams)
	var name_value: String = str(_args[0] if _args.size() > 0 else "")
	return source_block_load_state.generated_base_regions_result_state(name_value)

func java_method_isHidden_127(_args: Array = []) -> Variant:
	var build_visibility_visible: bool = bool(_args[0] if _args.size() > 0 else false)
	var revealed_blocks_contains_self: bool = bool(_args[1] if _args.size() > 1 else false)
	return source_block_plan_visibility_state.generated_is_hidden_result_state(build_visibility_visible, revealed_blocks_contains_self)

func java_method_createIcons_128(_args: Array = []) -> Variant:
	var super_state: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	var synthetic := bool(_args[1] if _args.size() > 1 else false)
	var full_icon_width := int(_args[2] if _args.size() > 2 else 0)
	var full_icon_height := int(_args[3] if _args.size() > 3 else 0)
	var full_icon_center_color: Variant = _args[4] if _args.size() > 4 else null
	var map_color_before: Variant = _args[5] if _args.size() > 5 else null
	var name_value := str(_args[6] if _args.size() > 6 else "")
	var team_region_found := bool(_args[7] if _args.size() > 7 else false)
	var teams: Array = _args[8] if _args.size() > 8 and _args[8] is Array else []
	var team_region: Variant = _args[9] if _args.size() > 9 else null
	var team_regions_before: Array = _args[10] if _args.size() > 10 and _args[10] is Array else []
	var atlas_team_overrides: Array = _args[11] if _args.size() > 11 and _args[11] is Array else []
	var outline_icon := bool(_args[12] if _args.size() > 12 else false)
	var outlined_icon := int(_args[13] if _args.size() > 13 else -1)
	var outline_radius := int(_args[14] if _args.size() > 14 else 0)
	var generated_icons: Array = _args[15] if _args.size() > 15 and _args[15] is Array else []
	var custom_regions_to_outline: Array = _args[16] if _args.size() > 16 and _args[16] is Array else []
	return source_block_icon_state.generated_create_icons_result_state(super_state, synthetic, full_icon_width, full_icon_height, full_icon_center_color, map_color_before, name_value, team_region_found, teams, team_region, team_regions_before, atlas_team_overrides, outline_icon, outlined_icon, outline_radius, generated_icons, custom_regions_to_outline)

func java_method_planRotation_129(_args: Array = []) -> Variant:
	var rotate_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var lock_rotation: bool = bool(_args[1] if _args.size() > 1 else false)
	var rot: int = int(_args[2] if _args.size() > 2 else 0)
	return source_block_plan_placement_state.generated_plan_rotation_result_state(rotate_value, lock_rotation, rot)

func java_method_flipRotation_130(_args: Array = []) -> Variant:
	var rotation_before: int = int(_args[0] if _args.size() > 0 else 0)
	var x_value: bool = bool(_args[1] if _args.size() > 1 else false)
	var invert_flip: bool = bool(_args[2] if _args.size() > 2 else false)
	var rotate_value: bool = bool(_args[3] if _args.size() > 3 else false)
	var lock_rotation: bool = bool(_args[4] if _args.size() > 4 else false)
	return source_block_plan_placement_state.generated_flip_rotation_result_state(rotation_before, x_value, invert_flip, rotate_value, lock_rotation)

func java_method_getPlanConfigs_131(_args: Array = []) -> Variant:
	var options_before: Array = _args[0] if _args.size() > 0 else []
	var item_configured: bool = bool(_args[1] if _args.size() > 1 else false)
	var liquid_configured: bool = bool(_args[2] if _args.size() > 2 else false)
	var content_items: Array = _args[3] if _args.size() > 3 else []
	var content_liquids: Array = _args[4] if _args.size() > 4 else []
	return source_block_plan_config_state.generated_get_plan_configs_result_state(options_before, item_configured, liquid_configured, content_items, content_liquids)

func java_method_sense_132(_args: Array = []) -> Variant:
	var sensor: String = str(_args[0] if _args.size() > 0 else "")
	var map_color_double_bits: float = float(_args[1] if _args.size() > 1 else 0.0)
	var health_value: float = float(_args[2] if _args.size() > 2 else 0.0)
	var solid_value: bool = bool(_args[3] if _args.size() > 3 else false)
	var size_value: int = int(_args[4] if _args.size() > 4 else 0)
	var item_capacity: int = int(_args[5] if _args.size() > 5 else 0)
	var liquid_capacity: float = float(_args[6] if _args.size() > 6 else 0.0)
	var has_cons_power: bool = bool(_args[7] if _args.size() > 7 else false)
	var cons_power_buffered: bool = bool(_args[8] if _args.size() > 8 else false)
	var cons_power_capacity: float = float(_args[9] if _args.size() > 9 else 0.0)
	var logic_id: int = int(_args[10] if _args.size() > 10 else 0)
	return source_block_sense_state.generated_laccess_result_state(sensor, map_color_double_bits, health_value, solid_value, size_value, item_capacity, liquid_capacity, has_cons_power, cons_power_buffered, cons_power_capacity, logic_id)

func java_method_sense_133(_args: Array = []) -> Variant:
	var content_type: String = str(_args[0] if _args.size() > 0 else "")
	var content_item: Variant = _args[1] if _args.size() > 1 else null
	var state_rules_infinite_resources: bool = bool(_args[2] if _args.size() > 2 else false)
	var requirements: Array = _args[3] if _args.size() > 3 else []
	var build_cost_multiplier: float = float(_args[4] if _args.size() > 4 else 1.0)
	return source_block_sense_state.generated_content_result_state(content_type, content_item, state_rules_infinite_resources, requirements, build_cost_multiplier)

func java_method_senseObject_134(_args: Array = []) -> Variant:
	var sensor: String = str(_args[0] if _args.size() > 0 else "")
	var block_name: Variant = _args[1] if _args.size() > 1 else null
	var no_sensed: Variant = _args[2] if _args.size() > 2 else null
	return source_block_sense_state.generated_object_result_state(sensor, block_name, no_sensed)
