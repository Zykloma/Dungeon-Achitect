class_name PrestigeSystem
extends Node

signal boss_kill_registered(total: int)

var economy: EconomySystem
var boss_kills := 0
var deepest_floor := 1

func setup(eco: EconomySystem) -> void:
    economy = eco

func register_boss_kill() -> void:
    boss_kills += 1
    AppState.lifetime_stats.boss_kills += 1
    boss_kill_registered.emit(boss_kills)

func current_run_score() -> float:
    return PrestigeMath.run_score(economy.run_gold_earned, economy.run_souls_earned, economy.run_mana_earned, boss_kills, economy.max_fame, deepest_floor)

func can_prestige() -> bool:
    return boss_kills >= 1 and current_run_score() >= 25000.0

func available_dark_essence() -> int:
    if not can_prestige():
        return 0
    return PrestigeMath.dark_essence(current_run_score())

func reset_run_counters() -> void:
    boss_kills = 0
    deepest_floor = 1

func serialize() -> Dictionary:
    return {"boss_kills": boss_kills, "deepest_floor": deepest_floor}

func restore(data: Dictionary) -> void:
    boss_kills = int(data.get("boss_kills", 0))
    deepest_floor = maxi(1, int(data.get("deepest_floor", 1)))
