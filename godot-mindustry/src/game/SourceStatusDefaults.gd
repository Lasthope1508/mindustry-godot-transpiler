extends RefCounted
class_name SourceStatusDefaults

const STATUS_EFFECT_NONE := "StatusEffects.none"
const STATUS_FIELD_EXPR := "public StatusEffect status = StatusEffects.none;"
const STATUS_DURATION_FIELD_EXPR := "public float statusDuration = 300;"
const STATUS_APPLY_METHOD := "public void apply(StatusEffect effect, float duration){\n        if(effect == StatusEffects.none || effect == null || isImmune(effect)) return; //don't apply empty or immune effects\n    }"
