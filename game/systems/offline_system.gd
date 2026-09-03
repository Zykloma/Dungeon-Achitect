class_name OfflineSystem
extends Node

const EFFICIENCY := 0.70
const SAMPLE_SECONDS := 10.0
const EMA_WINDOW_SECONDS := 60.0

var economy: EconomySystem
var meta: MetaProgressionSystem
var ema_gold_per_second := 0.0
var ema_souls_per_second := 0.0
var ema_mana_per_second := 0.0
var ema_kills_per_second := 0.0
var average_kill_tier := 1.0
var sample_timer := 0.0
var last_gold_earned := 0.0
var last_souls_earned := 0.0
var last_mana_earned := 0.0
var kills_since_sample := 0
var tier_sum_since_sample := 0.0

func setup(eco: EconomySystem, meta_system: MetaProgressionSystem) -> void:
    economy = eco
    meta = meta_system
    _capture_totals()

func _process(delta: float) -> void:
    if economy == null:
        return
    sample_timer += delta
    if sample_timer >= SAMPLE_SECONDS:
        _sample(sample_timer)
        sample_timer = 0.0

func reset_run() -> void:
    ema_gold_per_second = 0.0
    ema_souls_per_second = 0.0
    ema_mana_per_second = 0.0
    ema_kills_per_second = 0.0
    average_kill_tier = 1.0
    kills_since_sample = 0
    tier_sum_since_sample = 0.0
    sample_timer = 0.0
    _capture_totals()

func record_kill(tier: int) -> void:
    kills_since_sample += 1
    tier_sum_since_sample += tier

func _sample(seconds: float) -> void:
    var alpha := 1.0 - exp(-seconds / EMA_WINDOW_SECONDS)
    var gold_rate := max(0.0, economy.run_gold_earned - last_gold_earned) / max(0.001, seconds)
    var soul_rate := max(0.0, economy.run_souls_earned - last_souls_earned) / max(0.001, seconds)
    var mana_rate := max(0.0, economy.run_mana_earned - last_mana_earned) / max(0.001, seconds)
    var kill_rate := float(kills_since_sample) / max(0.001, seconds)
    ema_gold_per_second = lerpf(ema_gold_per_second, gold_rate, alpha)
    ema_souls_per_second = lerpf(ema_souls_per_second, soul_rate, alpha)
    ema_mana_per_second = lerpf(ema_mana_per_second, mana_rate, alpha)
    ema_kills_per_second = lerpf(ema_kills_per_second, kill_rate, alpha)
    if kills_since_sample > 0:
        average_kill_tier = lerpf(average_kill_tier, tier_sum_since_sample / kills_since_sample, alpha)
    kills_since_sample = 0
    tier_sum_since_sample = 0.0
    _capture_totals()

func _capture_totals() -> void:
    if economy == null:
        return
    last_gold_earned = economy.run_gold_earned
    last_souls_earned = economy.run_souls_earned
    last_mana_earned = economy.run_mana_earned

func reward_for(save_data: Dictionary) -> Dictionary:
    var now := Time.get_unix_time_from_system()
    var last := float(save_data.get("last_save_unix", now))
    var elapsed := max(0.0, now - last)
    var cap := meta.offline_cap_seconds() if meta else 12.0 * 3600.0
    var seconds := min(elapsed, cap)
    var rates: Dictionary = save_data.get("offline_ema", {})
    var expected_kills := float(rates.get("kills", 0.0)) * seconds * EFFICIENCY
    var avg_tier := max(1.0, float(rates.get("average_tier", 1.0)))
    return {
        "seconds": seconds,
        "gold": float(rates.get("gold", 0.0)) * seconds * EFFICIENCY,
        "souls": float(rates.get("souls", 0.0)) * seconds * EFFICIENCY,
        "mana": float(rates.get("mana", 0.0)) * seconds * EFFICIENCY,
        "expected_kills": expected_kills,
        "fame": min(30.0, 0.25 * expected_kills * avg_tier),
    }

func serialize() -> Dictionary:
    return {
        "gold": ema_gold_per_second,
        "souls": ema_souls_per_second,
        "mana": ema_mana_per_second,
        "kills": ema_kills_per_second,
        "average_tier": average_kill_tier,
    }

func restore(data: Dictionary) -> void:
    ema_gold_per_second = float(data.get("gold", 0.0))
    ema_souls_per_second = float(data.get("souls", 0.0))
    ema_mana_per_second = float(data.get("mana", 0.0))
    ema_kills_per_second = float(data.get("kills", 0.0))
    average_kill_tier = float(data.get("average_tier", 1.0))
    _capture_totals()
