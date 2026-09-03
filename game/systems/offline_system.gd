class_name OfflineSystem
extends Node

const BASE_CAP_SECONDS := 12.0 * 3600.0
const EFFICIENCY := 0.70

var ema_gold_per_second := 0.0
var ema_souls_per_second := 0.0
var ema_mana_per_second := 0.0
var ema_kills_per_second := 0.0

func reward_for(save_data: Dictionary) -> Dictionary:
    var last := float(save_data.get("last_save_unix", Time.get_unix_time_from_system()))
    var seconds := min(Time.get_unix_time_from_system() - last, BASE_CAP_SECONDS)
    var rates: Dictionary = save_data.get("offline_ema", {})
    return {
        "seconds": seconds,
        "gold": float(rates.get("gold", 0.0)) * seconds * EFFICIENCY,
        "souls": float(rates.get("souls", 0.0)) * seconds * EFFICIENCY,
        "mana": float(rates.get("mana", 0.0)) * seconds * EFFICIENCY,
        "expected_kills": float(rates.get("kills", 0.0)) * seconds * EFFICIENCY,
    }

func serialize() -> Dictionary:
    return {"gold": ema_gold_per_second, "souls": ema_souls_per_second, "mana": ema_mana_per_second, "kills": ema_kills_per_second}
