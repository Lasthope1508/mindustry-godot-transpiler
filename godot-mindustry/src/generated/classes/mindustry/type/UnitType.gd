# Generated from Mindustry upstream.
# Source: mindustry/type/UnitType.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.type"
const JAVA_KIND := "class"
const JAVA_NAME := "UnitType"
const JAVA_EXTENDS := "UnlockableContent"
const JAVA_IMPLEMENTS := ["Senseable"]
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "shadowTX", "type": "float"}, {"modifiers": ["final", "public", "static"], "name": "shadowTY", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "legOffset", "type": "Vec2"}, {"modifiers": ["final", "private", "static"], "name": "tmpStances", "type": "Seq"}, {"modifiers": ["public"], "name": "envRequired", "type": "int"}, {"modifiers": ["public"], "name": "envEnabled", "type": "int"}, {"modifiers": ["public"], "name": "envDisabled", "type": "int"}, {"modifiers": ["public"], "name": "speed", "type": "float"}, {"modifiers": ["public"], "name": "boostMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "floorMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "rotateSpeed", "type": "float"}, {"modifiers": ["public"], "name": "baseRotateSpeed", "type": "float"}, {"modifiers": ["public"], "name": "drag", "type": "float"}, {"modifiers": ["public"], "name": "accel", "type": "float"}, {"modifiers": ["public"], "name": "hitSize", "type": "float"}, {"modifiers": ["public"], "name": "deathShake", "type": "float"}, {"modifiers": ["public"], "name": "stepShake", "type": "float"}, {"modifiers": ["public"], "name": "rippleScale", "type": "float"}, {"modifiers": ["public"], "name": "riseSpeed", "type": "float"}, {"modifiers": ["public"], "name": "descentSpeed", "type": "float"}, {"modifiers": ["public"], "name": "fallSpeed", "type": "float"}, {"modifiers": ["public"], "name": "missileAccelTime", "type": "float"}, {"modifiers": ["public"], "name": "health", "type": "float"}, {"modifiers": ["public"], "name": "armor", "type": "float"}, {"modifiers": ["public"], "name": "range", "type": "float"}, {"modifiers": ["public"], "name": "maxRange", "type": "float"}, {"modifiers": ["public"], "name": "mineRange", "type": "float"}, {"modifiers": ["public"], "name": "buildRange", "type": "float"}, {"modifiers": ["public"], "name": "circleTargetRadius", "type": "float"}, {"modifiers": ["public"], "name": "crashDamageMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "wreckHealthMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "dpsEstimate", "type": "float"}, {"modifiers": ["public"], "name": "clipSize", "type": "float"}, {"modifiers": ["public"], "name": "drownTimeMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "strafePenalty", "type": "float"}, {"modifiers": ["public"], "name": "researchCostMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "groundLayer", "type": "float"}, {"modifiers": ["public"], "name": "flyingLayer", "type": "float"}, {"modifiers": ["public"], "name": "payloadCapacity", "type": "float"}, {"modifiers": ["public"], "name": "buildSpeed", "type": "float"}, {"modifiers": ["public"], "name": "aimDst", "type": "float"}, {"modifiers": ["public"], "name": "buildBeamOffset", "type": "float"}, {"modifiers": ["public"], "name": "mineBeamOffset", "type": "float"}, {"modifiers": ["public"], "name": "targetPriority", "type": "float"}, {"modifiers": ["public"], "name": "shadowElevation", "type": "float"}, {"modifiers": ["public"], "name": "shadowElevationScl", "type": "float"}, {"modifiers": ["public"], "name": "engineOffset", "type": "float"}, {"modifiers": ["public"], "name": "engineSize", "type": "float"}, {"modifiers": ["public"], "name": "engineLayer", "type": "float"}, {"modifiers": ["public"], "name": "itemOffsetY", "type": "float"}, {"modifiers": ["public"], "name": "lightRadius", "type": "float"}, {"modifiers": ["public"], "name": "lightOpacity", "type": "float"}, {"modifiers": ["public"], "name": "softShadowScl", "type": "float"}, {"modifiers": ["public"], "name": "fogRadius", "type": "float"}, {"modifiers": ["public"], "name": "waveTrailX", "type": "float"}, {"modifiers": ["public"], "name": "waveTrailY", "type": "float"}, {"modifiers": ["public"], "name": "trailScl", "type": "float"}, {"modifiers": ["public"], "name": "isEnemy", "type": "boolean"}, {"modifiers": ["public"], "name": "flying", "type": "boolean"}, {"modifiers": ["public"], "name": "wobble", "type": "boolean"}, {"modifiers": ["public"], "name": "targetAir", "type": "boolean"}, {"modifiers": ["public"], "name": "targetGround", "type": "boolean"}, {"modifiers": ["public"], "name": "faceTarget", "type": "boolean"}, {"modifiers": ["public"], "name": "circleTarget", "type": "boolean"}, {"modifiers": ["public"], "name": "autoDropBombs", "type": "boolean"}, {"modifiers": ["public"], "name": "targetBuildingsMobile", "type": "boolean"}, {"modifiers": ["public"], "name": "canBoost", "type": "boolean"}, {"modifiers": ["public"], "name": "boostWhenBuilding", "type": "boolean"}, {"modifiers": ["public"], "name": "boostWhenMining", "type": "boolean"}, {"modifiers": ["public"], "name": "logicControllable", "type": "boolean"}, {"modifiers": ["public"], "name": "playerControllable", "type": "boolean"}, {"modifiers": ["public"], "name": "controlSelectGlobal", "type": "boolean"}, {"modifiers": ["public"], "name": "allowedInPayloads", "type": "boolean"}, {"modifiers": ["public"], "name": "hittable", "type": "boolean"}, {"modifiers": ["public"], "name": "killable", "type": "boolean"}, {"modifiers": ["public"], "name": "targetable", "type": "boolean"}, {"modifiers": ["public"], "name": "vulnerableWithPayloads", "type": "boolean"}, {"modifiers": ["public"], "name": "pickupUnits", "type": "boolean"}, {"modifiers": ["public"], "name": "physics", "type": "boolean"}, {"modifiers": ["public"], "name": "canDrown", "type": "boolean"}, {"modifiers": ["public"], "name": "useUnitCap", "type": "boolean"}, {"modifiers": ["public"], "name": "coreUnitDock", "type": "boolean"}, {"modifiers": ["public"], "name": "createWreck", "type": "boolean"}, {"modifiers": ["public"], "name": "createScorch", "type": "boolean"}, {"modifiers": ["public"], "name": "lowAltitude", "type": "boolean"}, {"modifiers": ["public"], "name": "rotateToBuilding", "type": "boolean"}, {"modifiers": ["public"], "name": "allowLegStep", "type": "boolean"}, {"modifiers": ["public"], "name": "legPhysicsLayer", "type": "boolean"}, {"modifiers": ["public"], "name": "hovering", "type": "boolean"}, {"modifiers": ["public"], "name": "omniMovement", "type": "boolean"}, {"modifiers": ["public"], "name": "rotateMoveFirst", "type": "boolean"}, {"modifiers": ["public"], "name": "healFlash", "type": "boolean"}, {"modifiers": ["public"], "name": "canHeal", "type": "boolean"}, {"modifiers": ["public"], "name": "singleTarget", "type": "boolean"}, {"modifiers": ["public"], "name": "forceMultiTarget", "type": "boolean"}, {"modifiers": ["public"], "name": "canAttack", "type": "boolean"}, {"modifiers": ["public"], "name": "hidden", "type": "boolean"}, {"modifiers": ["public"], "name": "internal", "type": "boolean"}, {"modifiers": ["public"], "name": "internalGenerateSprites", "type": "boolean"}, {"modifiers": ["public"], "name": "bounded", "type": "boolean"}, {"modifiers": ["public"], "name": "naval", "type": "boolean"}, {"modifiers": ["public"], "name": "autoFindTarget", "type": "boolean"}, {"modifiers": ["public"], "name": "targetUnderBlocks", "type": "boolean"}, {"modifiers": ["public"], "name": "alwaysShootWhenMoving", "type": "boolean"}, {"modifiers": ["public"], "name": "hoverable", "type": "boolean"}, {"modifiers": ["public"], "name": "alwaysCreateOutline", "type": "boolean"}, {"modifiers": ["public"], "name": "generateFullIcon", "type": "boolean"}, {"modifiers": ["public"], "name": "squareShape", "type": "boolean"}, {"modifiers": ["public"], "name": "drawBuildBeam", "type": "boolean"}, {"modifiers": ["public"], "name": "drawMineBeam", "type": "boolean"}, {"modifiers": ["public"], "name": "drawCell", "type": "boolean"}, {"modifiers": ["public"], "name": "drawItems", "type": "boolean"}, {"modifiers": ["public"], "name": "drawShields", "type": "boolean"}, {"modifiers": ["public"], "name": "drawBody", "type": "boolean"}, {"modifiers": ["public"], "name": "drawSoftShadow", "type": "boolean"}, {"modifiers": ["public"], "name": "drawMinimap", "type": "boolean"}, {"modifiers": ["public"], "name": "aiController", "type": "Prov"}, {"modifiers": ["public"], "name": "controller", "type": "Func"}, {"modifiers": ["public"], "name": "constructor", "type": "Prov"}, {"modifiers": ["public"], "name": "abilities", "type": "Seq"}, {"modifiers": ["public"], "name": "weapons", "type": "Seq"}, {"modifiers": ["public"], "name": "immunities", "type": "ObjectSet"}, {"modifiers": ["public"], "name": "healColor", "type": "Color"}, {"modifiers": ["public"], "name": "lightColor", "type": "Color"}, {"modifiers": ["public"], "name": "shieldColor", "type": "Color"}, {"modifiers": ["public"], "name": "deathSound", "type": "Sound"}, {"modifiers": ["public"], "name": "deathSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "wreckSound", "type": "Sound"}, {"modifiers": ["public"], "name": "wreckSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "loopSound", "type": "Sound"}, {"modifiers": ["public"], "name": "loopSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "stepSound", "type": "Sound"}, {"modifiers": ["public"], "name": "stepSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "stepSoundPitch", "type": "float"}, {"modifiers": ["public"], "name": "stepSoundPitchRange", "type": "float"}, {"modifiers": ["public"], "name": "tankMoveSound", "type": "Sound"}, {"modifiers": ["public"], "name": "moveSound", "type": "Sound"}, {"modifiers": ["public"], "name": "moveSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "moveSoundPitchMin", "type": "float"}, {"modifiers": ["public"], "name": "moveSoundPitchMax", "type": "float"}, {"modifiers": ["public"], "name": "tankMoveVolume", "type": "float"}, {"modifiers": ["public"], "name": "fallEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "fallEngineEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "deathExplosionEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "treadEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "parts", "type": "Seq"}, {"modifiers": ["public"], "name": "engines", "type": "Seq"}, {"modifiers": ["public"], "name": "useEngineElevation", "type": "boolean"}, {"modifiers": ["public"], "name": "engineColor", "type": "Color"}, {"modifiers": ["public"], "name": "engineColorInner", "type": "Color"}, {"modifiers": ["public"], "name": "trailLength", "type": "int"}, {"modifiers": ["public"], "name": "trailColor", "type": "Color"}, {"modifiers": ["public"], "name": "flowfieldPathType", "type": "int"}, {"modifiers": ["public"], "name": "pathCost", "type": "PathCost"}, {"modifiers": ["public"], "name": "pathCostId", "type": "int"}, {"modifiers": ["public"], "name": "sample", "type": "Unit"}, {"modifiers": ["public"], "name": "targetFlags", "type": "BlockFlag"}, {"modifiers": ["public"], "name": "allowChangeCommands", "type": "boolean"}, {"modifiers": ["public"], "name": "commands", "type": "Seq"}, {"modifiers": ["public"], "name": "defaultCommand", "type": "UnitCommand"}, {"modifiers": ["public"], "name": "stances", "type": "Seq"}, {"modifiers": ["public"], "name": "outlineColor", "type": "Color"}, {"modifiers": ["public"], "name": "outlineRadius", "type": "int"}, {"modifiers": ["public"], "name": "outlines", "type": "boolean"}, {"modifiers": ["public"], "name": "itemCapacity", "type": "int"}, {"modifiers": ["public"], "name": "ammoCapacity", "type": "int"}, {"modifiers": ["public"], "name": "mineTier", "type": "int"}, {"modifiers": ["public"], "name": "mineSpeed", "type": "float"}, {"modifiers": ["public"], "name": "mineWalls", "type": "boolean"}, {"modifiers": ["public"], "name": "mineFloor", "type": "boolean"}, {"modifiers": ["public"], "name": "mineHardnessScaling", "type": "boolean"}, {"modifiers": ["public"], "name": "mineSound", "type": "Sound"}, {"modifiers": ["public"], "name": "mineSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "mineItems", "type": "Seq"}, {"modifiers": ["public"], "name": "legCount", "type": "int"}, {"modifiers": ["public"], "name": "legGroupSize", "type": "int"}, {"modifiers": ["public"], "name": "legLength", "type": "float"}, {"modifiers": ["public"], "name": "legSpeed", "type": "float"}, {"modifiers": ["public"], "name": "legForwardScl", "type": "float"}, {"modifiers": ["public"], "name": "legBaseOffset", "type": "float"}, {"modifiers": ["public"], "name": "legMoveSpace", "type": "float"}, {"modifiers": ["public"], "name": "legExtension", "type": "float"}, {"modifiers": ["public"], "name": "legPairOffset", "type": "float"}, {"modifiers": ["public"], "name": "legLengthScl", "type": "float"}, {"modifiers": ["public"], "name": "legStraightLength", "type": "float"}, {"modifiers": ["public"], "name": "legMaxLength", "type": "float"}, {"modifiers": ["public"], "name": "legMinLength", "type": "float"}, {"modifiers": ["public"], "name": "legSplashDamage", "type": "float"}, {"modifiers": ["public"], "name": "legSplashRange", "type": "float"}, {"modifiers": ["public"], "name": "baseLegStraightness", "type": "float"}, {"modifiers": ["public"], "name": "legStraightness", "type": "float"}, {"modifiers": ["public"], "name": "legBaseUnder", "type": "boolean"}, {"modifiers": ["public"], "name": "lockLegBase", "type": "boolean"}, {"modifiers": ["public"], "name": "legContinuousMove", "type": "boolean"}, {"modifiers": ["public"], "name": "flipBackLegs", "type": "boolean"}, {"modifiers": ["public"], "name": "flipLegSide", "type": "boolean"}, {"modifiers": ["public"], "name": "emitWalkSound", "type": "boolean"}, {"modifiers": ["public"], "name": "emitWalkEffect", "type": "boolean"}, {"modifiers": ["public"], "name": "mechLandShake", "type": "float"}, {"modifiers": ["public"], "name": "mechSideSway", "type": "float"}, {"modifiers": ["public"], "name": "mechFrontSway", "type": "float"}, {"modifiers": ["public"], "name": "mechStride", "type": "float"}, {"modifiers": ["public"], "name": "mechStepParticles", "type": "boolean"}, {"modifiers": ["public"], "name": "mechLegColor", "type": "Color"}, {"modifiers": ["public"], "name": "treadRects", "type": "Rect"}, {"modifiers": ["public"], "name": "treadFrames", "type": "int"}, {"modifiers": ["public"], "name": "treadPullOffset", "type": "int"}, {"modifiers": ["public"], "name": "crushFragile", "type": "boolean"}, {"modifiers": ["public"], "name": "segments", "type": "int"}, {"modifiers": ["public"], "name": "segmentUnits", "type": "int"}, {"modifiers": ["public"], "name": "segmentUnit", "type": "UnitType"}, {"modifiers": ["public"], "name": "segmentEndUnit", "type": "UnitType"}, {"modifiers": ["public"], "name": "segmentLayerOrder", "type": "boolean"}, {"modifiers": ["public"], "name": "segmentMag", "type": "float"}, {"modifiers": ["public"], "name": "segmentScl", "type": "float"}, {"modifiers": ["public"], "name": "segmentPhase", "type": "float"}, {"modifiers": ["public"], "name": "segmentRotSpeed", "type": "float"}, {"modifiers": ["public"], "name": "segmentMaxRot", "type": "float"}, {"modifiers": ["public"], "name": "segmentSpacing", "type": "float"}, {"modifiers": ["public"], "name": "segmentRotationRange", "type": "float"}, {"modifiers": ["public"], "name": "crawlSlowdown", "type": "float"}, {"modifiers": ["public"], "name": "crushDamage", "type": "float"}, {"modifiers": ["public"], "name": "crawlSlowdownFrac", "type": "float"}, {"modifiers": ["public"], "name": "lifetime", "type": "float"}, {"modifiers": ["public"], "name": "homingDelay", "type": "float"}, {"modifiers": ["public"], "name": "baseRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "legRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "region", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "previewRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "shadowRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "cellRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "itemCircleRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "softShadowRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "jointRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "footRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "legBaseRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "baseJointRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "outlineRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "treadRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "mineLaserRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "mineLaserEndRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "wreckRegions", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "segmentRegions", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "segmentCellRegions", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "segmentOutlineRegions", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "treadRegions", "type": "TextureRegion"}, {"modifiers": ["protected"], "name": "buildTime", "type": "float"}, {"modifiers": ["protected"], "name": "totalRequirements", "type": "ItemStack"}, {"modifiers": ["protected"], "name": "cachedRequirements", "type": "ItemStack"}, {"modifiers": ["protected"], "name": "firstRequirements", "type": "ItemStack"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "UnitType", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "postInit", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "createController", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": "UnitController"}, {"modifiers": ["public"], "name": "create", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public"], "name": "spawn", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public"], "name": "spawn", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public"], "name": "spawn", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public"], "name": "spawn", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public"], "name": "spawn", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "pos", "type": "Position", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public"], "name": "spawn", "parameters": [{"name": "pos", "type": "Position", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public"], "name": "spawn", "parameters": [{"name": "pos", "type": "Position", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public"], "name": "hasWeapons", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "targetable", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "targeter", "type": "Team", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "killable", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "hittable", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getUnitStances", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "out", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "allowStance", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "stance", "type": "UnitStance", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "allowCommand", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "command", "type": "UnitCommand", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updatePayload", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "unitHolder", "type": "Unit", "varargs": false}, {"name": "buildingHolder", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "killed", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "landed", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "supportsEnv", "parameters": [{"name": "env", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isBanned", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getDependencies", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isHidden", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "checkEntityMapping", "parameters": [{"name": "example", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "initPathType", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "estimateDps", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getRegionsToOutline", "parameters": [{"name": "out", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "needsBodyOutline", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "createIcons", "parameters": [{"name": "packer", "type": "MultiPacker", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "afterPatch", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "beforeParse", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getBuildTime", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getTotalRequirements", "parameters": [], "return_type": "ItemStack"}, {"modifiers": ["public"], "name": "getRequirements", "parameters": [{"name": "prevReturn", "type": "UnitType", "varargs": false}, {"name": "timeReturn", "type": "float", "varargs": false}], "return_type": "ItemStack"}, {"modifiers": ["public"], "name": "getFirstRequirements", "parameters": [], "return_type": "ItemStack"}, {"modifiers": ["public"], "name": "researchRequirements", "parameters": [], "return_type": "ItemStack"}, {"modifiers": ["public"], "name": "sense", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "double"}, {"modifiers": ["public"], "name": "senseObject", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public"], "name": "getContentType", "parameters": [], "return_type": "ContentType"}, {"modifiers": ["public"], "name": "setEnginesMirror", "parameters": [{"name": "array", "type": "UnitEngine", "varargs": true}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "shieldColor", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": "Color"}, {"modifiers": ["public"], "name": "drawMining", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawMiningBeam", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "px", "type": "float", "varargs": false}, {"name": "py", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPayload", "parameters": [{"name": "unit", "type": "T", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawShield", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawShadow", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawSoftShadow", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawSoftShadow", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawSoftShadow", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawItems", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawTrail", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawEngines", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawWeapons", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawWeaponOutlines", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawOutline", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawBody", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawCell", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "cellColor", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": "Color"}, {"modifiers": ["public"], "name": "drawLight", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawTank", "parameters": [{"name": "unit", "type": "T", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawLegs", "parameters": [{"name": "unit", "type": "T", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawCrawl", "parameters": [{"name": "crawl", "type": "Crawlc", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawMech", "parameters": [{"name": "mech", "type": "Mechc", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "applyOutlineColor", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "applyColor", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
const source_unit_type_state := preload("res://src/game/SourceUnitTypeState.gd")
const source_unit_type_source_text_state := preload("res://src/game/SourceUnitTypeSourceTextState.gd")

func java_method_postInit_0(_args: Array = []) -> Variant:
	return null

func java_method_createController_1(_args: Array = []) -> Variant:
	var controller_get: Callable = _args[0] if _args.size() > 0 and _args[0] is Callable else Callable()
	var unit: Variant = _args[1] if _args.size() > 1 else null
	var result := source_unit_type_state.create_controller_state(controller_get, unit)
	result["generated_owner"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_CREATE_CONTROLLER_GENERATED_OWNER
	result["generated_method"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_CREATE_CONTROLLER_GENERATED_METHOD
	return result

func java_method_create_2(_args: Array = []) -> Variant:
	return null

func java_method_spawn_3(_args: Array = []) -> Variant:
	return null

func java_method_spawn_4(_args: Array = []) -> Variant:
	return null

func java_method_spawn_5(_args: Array = []) -> Variant:
	return null

func java_method_spawn_6(_args: Array = []) -> Variant:
	return null

func java_method_spawn_7(_args: Array = []) -> Variant:
	return null

func java_method_spawn_8(_args: Array = []) -> Variant:
	return null

func java_method_spawn_9(_args: Array = []) -> Variant:
	return null

func java_method_hasWeapons_10(_args: Array = []) -> Variant:
	var weapons: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var result := source_unit_type_state.has_weapons_state(weapons)
	result["generated_owner"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_HAS_WEAPONS_GENERATED_OWNER
	result["generated_method"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_HAS_WEAPONS_GENERATED_METHOD
	return result

func java_method_targetable_11(_args: Array = []) -> Variant:
	var type_targetable: bool = bool(_args[0] if _args.size() > 0 else false)
	var vulnerable_with_payloads: bool = bool(_args[1] if _args.size() > 1 else false)
	var unit_is_payloadc: bool = bool(_args[2] if _args.size() > 2 else false)
	var unit_has_payload: bool = bool(_args[3] if _args.size() > 3 else false)
	var unit: Variant = _args[4] if _args.size() > 4 else null
	var targeter: Variant = _args[5] if _args.size() > 5 else null
	var result := source_unit_type_state.targetable_state(type_targetable, vulnerable_with_payloads, unit_is_payloadc, unit_has_payload, unit, targeter)
	result["generated_owner"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_TARGETABLE_GENERATED_OWNER
	result["generated_method"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_TARGETABLE_GENERATED_METHOD
	return result

func java_method_killable_12(_args: Array = []) -> Variant:
	var type_killable: bool = bool(_args[0] if _args.size() > 0 else false)
	var unit: Variant = _args[1] if _args.size() > 1 else null
	var result := source_unit_type_state.killable_state(type_killable, unit)
	result["generated_owner"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_KILLABLE_GENERATED_OWNER
	result["generated_method"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_KILLABLE_GENERATED_METHOD
	return result

func java_method_hittable_13(_args: Array = []) -> Variant:
	var type_hittable: bool = bool(_args[0] if _args.size() > 0 else false)
	var vulnerable_with_payloads: bool = bool(_args[1] if _args.size() > 1 else false)
	var unit_is_payloadc: bool = bool(_args[2] if _args.size() > 2 else false)
	var unit_has_payload: bool = bool(_args[3] if _args.size() > 3 else false)
	var unit: Variant = _args[4] if _args.size() > 4 else null
	var result := source_unit_type_state.hittable_state(type_hittable, vulnerable_with_payloads, unit_is_payloadc, unit_has_payload, unit)
	result["generated_owner"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_HITTABLE_GENERATED_OWNER
	result["generated_method"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_HITTABLE_GENERATED_METHOD
	return result

func java_method_getUnitStances_14(_args: Array = []) -> Variant:
	var controller_is_command_ai: bool = bool(_args[0] if _args.size() > 0 else false)
	var command_is_mine: bool = bool(_args[1] if _args.size() > 1 else false)
	var mine_floor: bool = bool(_args[2] if _args.size() > 2 else false)
	var mine_walls: bool = bool(_args[3] if _args.size() > 3 else false)
	var present_ores: Array = _args[4] if _args.size() > 4 and _args[4] is Array else []
	var stances: Array = _args[5] if _args.size() > 5 and _args[5] is Array else []
	var extra_stances: Array = _args[6] if _args.size() > 6 and _args[6] is Array else []
	var out: Array = _args[7] if _args.size() > 7 and _args[7] is Array else []
	var result := source_unit_type_state.get_unit_stances_state(controller_is_command_ai, command_is_mine, mine_floor, mine_walls, present_ores, stances, extra_stances, out)
	result["generated_owner"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_GET_UNIT_STANCES_GENERATED_OWNER
	result["generated_method"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_GET_UNIT_STANCES_GENERATED_METHOD
	return result

func java_method_allowStance_15(_args: Array = []) -> Variant:
	var stance: Variant = _args[0] if _args.size() > 0 else null
	var controller_is_command_ai: bool = bool(_args[1] if _args.size() > 1 else false)
	var command_is_mine: bool = bool(_args[2] if _args.size() > 2 else false)
	var mine_floor: bool = bool(_args[3] if _args.size() > 3 else false)
	var mine_walls: bool = bool(_args[4] if _args.size() > 4 else false)
	var present_ores: Array = _args[5] if _args.size() > 5 and _args[5] is Array else []
	var stances: Array = _args[6] if _args.size() > 6 and _args[6] is Array else []
	var extra_stances: Array = _args[7] if _args.size() > 7 and _args[7] is Array else []
	var out: Array = _args[8] if _args.size() > 8 and _args[8] is Array else []
	var result := source_unit_type_state.allow_stance_state(stance, controller_is_command_ai, command_is_mine, mine_floor, mine_walls, present_ores, stances, extra_stances, out)
	result["generated_owner"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_ALLOW_STANCE_GENERATED_OWNER
	result["generated_method"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_ALLOW_STANCE_GENERATED_METHOD
	return result

func java_method_allowCommand_16(_args: Array = []) -> Variant:
	var commands: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var command: Variant = _args[1] if _args.size() > 1 else null
	var result := source_unit_type_state.allow_command_state(commands, command)
	result["generated_owner"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_ALLOW_COMMAND_GENERATED_OWNER
	result["generated_method"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_ALLOW_COMMAND_GENERATED_METHOD
	return result

func java_method_update_17(_args: Array = []) -> Variant:
	var unit: Variant = _args[0] if _args.size() > 0 else null
	var result := source_unit_type_state.update_state(unit)
	result["generated_owner"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_UPDATE_GENERATED_OWNER
	result["generated_method"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_UPDATE_GENERATED_METHOD
	return result

func java_method_updatePayload_18(_args: Array = []) -> Variant:
	var unit: Variant = _args[0] if _args.size() > 0 else null
	var unit_holder: Variant = _args[1] if _args.size() > 1 else null
	var building_holder: Variant = _args[2] if _args.size() > 2 else null
	var result := source_unit_type_state.update_payload_state(unit, unit_holder, building_holder)
	result["generated_owner"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_UPDATE_PAYLOAD_GENERATED_OWNER
	result["generated_method"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_UPDATE_PAYLOAD_GENERATED_METHOD
	return result

func java_method_killed_19(_args: Array = []) -> Variant:
	var unit: Variant = _args[0] if _args.size() > 0 else null
	var result := source_unit_type_state.killed_state(unit)
	result["generated_owner"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_KILLED_GENERATED_OWNER
	result["generated_method"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_KILLED_GENERATED_METHOD
	return result

func java_method_landed_20(_args: Array = []) -> Variant:
	var unit: Variant = _args[0] if _args.size() > 0 else null
	var result := source_unit_type_state.landed_state(unit)
	result["generated_owner"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_LANDED_GENERATED_OWNER
	result["generated_method"] = source_unit_type_source_text_state.SOURCE_UNIT_TYPE_LANDED_GENERATED_METHOD
	return result

func java_method_display_21(_args: Array = []) -> Variant:
	return null

func java_method_supportsEnv_22(_args: Array = []) -> Variant:
	return null

func java_method_isBanned_23(_args: Array = []) -> Variant:
	return null

func java_method_getDependencies_24(_args: Array = []) -> Variant:
	return null

func java_method_isHidden_25(_args: Array = []) -> Variant:
	return null

func java_method_setStats_26(_args: Array = []) -> Variant:
	return null

func java_method_checkEntityMapping_27(_args: Array = []) -> Variant:
	return null

func java_method_initPathType_28(_args: Array = []) -> Variant:
	return null

func java_method_init_29(_args: Array = []) -> Variant:
	return null

func java_method_estimateDps_30(_args: Array = []) -> Variant:
	return null

func java_method_load_31(_args: Array = []) -> Variant:
	return null

func java_method_getRegionsToOutline_32(_args: Array = []) -> Variant:
	return null

func java_method_needsBodyOutline_33(_args: Array = []) -> Variant:
	return null

func java_method_createIcons_34(_args: Array = []) -> Variant:
	return null

func java_method_afterPatch_35(_args: Array = []) -> Variant:
	return null

func java_method_beforeParse_36(_args: Array = []) -> Variant:
	return null

func java_method_getBuildTime_37(_args: Array = []) -> Variant:
	return null

func java_method_getTotalRequirements_38(_args: Array = []) -> Variant:
	return null

func java_method_getRequirements_39(_args: Array = []) -> Variant:
	return null

func java_method_getFirstRequirements_40(_args: Array = []) -> Variant:
	return null

func java_method_researchRequirements_41(_args: Array = []) -> Variant:
	return null

func java_method_sense_42(_args: Array = []) -> Variant:
	return null

func java_method_senseObject_43(_args: Array = []) -> Variant:
	return null

func java_method_getContentType_44(_args: Array = []) -> Variant:
	return null

func java_method_setEnginesMirror_45(_args: Array = []) -> Variant:
	return null

func java_method_draw_46(_args: Array = []) -> Variant:
	return null

func java_method_shieldColor_47(_args: Array = []) -> Variant:
	return null

func java_method_drawMining_48(_args: Array = []) -> Variant:
	return null

func java_method_drawMiningBeam_49(_args: Array = []) -> Variant:
	return null

func java_method_drawPayload_50(_args: Array = []) -> Variant:
	return null

func java_method_drawShield_51(_args: Array = []) -> Variant:
	return null

func java_method_drawShadow_52(_args: Array = []) -> Variant:
	return null

func java_method_drawSoftShadow_53(_args: Array = []) -> Variant:
	return null

func java_method_drawSoftShadow_54(_args: Array = []) -> Variant:
	return null

func java_method_drawSoftShadow_55(_args: Array = []) -> Variant:
	return null

func java_method_drawItems_56(_args: Array = []) -> Variant:
	return null

func java_method_drawTrail_57(_args: Array = []) -> Variant:
	return null

func java_method_drawEngines_58(_args: Array = []) -> Variant:
	return null

func java_method_drawWeapons_59(_args: Array = []) -> Variant:
	return null

func java_method_drawWeaponOutlines_60(_args: Array = []) -> Variant:
	return null

func java_method_drawOutline_61(_args: Array = []) -> Variant:
	return null

func java_method_drawBody_62(_args: Array = []) -> Variant:
	return null

func java_method_drawCell_63(_args: Array = []) -> Variant:
	return null

func java_method_cellColor_64(_args: Array = []) -> Variant:
	return null

func java_method_drawLight_65(_args: Array = []) -> Variant:
	return null

func java_method_drawTank_66(_args: Array = []) -> Variant:
	return null

func java_method_drawLegs_67(_args: Array = []) -> Variant:
	return null

func java_method_drawCrawl_68(_args: Array = []) -> Variant:
	return null

func java_method_drawMech_69(_args: Array = []) -> Variant:
	return null

func java_method_applyOutlineColor_70(_args: Array = []) -> Variant:
	return null

func java_method_applyColor_71(_args: Array = []) -> Variant:
	return null
