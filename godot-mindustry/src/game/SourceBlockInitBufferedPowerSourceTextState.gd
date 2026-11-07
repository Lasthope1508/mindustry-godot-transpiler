extends RefCounted
class_name SourceBlockInitBufferedPowerSourceTextState

const SOURCE_BLOCK_INIT_BUFFERED_POWER_SOURCE := "core/src/mindustry/world/Block.java"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_CONSUME_POWER_SOURCE := "core/src/mindustry/world/consumers/ConsumePower.java"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_METHOD := "public void init(){"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_SUPER_INIT_EXPR := "super.init();"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_OUTPUTS_POWER_FIELD_EXPR := "public boolean outputsPower = false;"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_CONS_POWER_FIELD_EXPR := "public @Nullable ConsumePower consPower;"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_CONSUME_POWER_BUFFERED_FIELD_EXPR := "public boolean buffered;"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_GUARD_EXPR := "if(!outputsPower && consPower != null && consPower.buffered){"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_WARN_EXPR := "Log.warn(\"Consumer using buffered power: @. Disabling buffered power.\", name);"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_DISABLE_EXPR := "consPower.buffered = false;"

const SOURCE_BLOCK_INIT_BUFFERED_POWER_JAVA_METHOD_INIT_123 := "java_method_init_123"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_BRIDGE_MODE_KEY := "mindustry_init_bridge_mode"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_BUFFERED_POWER_MODE := "buffered_power"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_GENERATED_OWNER := "block.java_method_init_123"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_SOURCE_OWNER_KEY := "source_owner"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_GENERATED_OWNER_KEY := "generated_owner"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_RESULT_KEY := "result"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_CANONICAL_KEY := "canonical"
const SOURCE_BLOCK_INIT_BUFFERED_POWER_MATCHES_KEY := "matches"
