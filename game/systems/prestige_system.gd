class_name PrestigeSystem
extends Node

var economy: EconomySystem
var boss_kills := 0
var deepest_floor := 1

func setup(eco: EconomySystem) -> void:
    economy = eco

func current_run_score() -> float:
    return PrestigeMath.run_score(economy.run_gold_earned, economy.run_souls_earned, economy.run_mana_earned, boss_kills, economy.max_fame, deepest_floor)

func available_dark_essence() -> int:
    if boss_kills < 1: return 0
    return PrestigeMath.dark_essence(current_run_score())
