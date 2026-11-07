extends RefCounted
class_name SourceCampaignSectorPresetSourceTextState

const SOURCE_SECTOR_PRESETS_JAVA := "core/src/mindustry/content/SectorPresets.java"
const SOURCE_SERPULO_ALWAYS_UNLOCKED_PRESET_SOURCE := """
groundZero = new SectorPreset("groundZero", serpulo, 15){{
    alwaysUnlocked = true;
    addStartingItems = true;
    captureWave = 10;
    difficulty = 1;
    overrideLaunchDefaults = true;
    noLighting = true;
    startWaveTimeMultiplier = 3f;
}};
"""
