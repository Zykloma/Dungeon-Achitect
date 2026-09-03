extends Node

signal run_reset

const SAVE_VERSION := 1

var lifetime_stats: Dictionary = {
    "gold_earned": 0.0,
    "souls_earned": 0.0,
    "mana_earned": 0.0,
    "heroes_killed": 0,
    "heroes_escaped": 0,
    "boss_kills": 0,
    "max_fame": 0.0,
    "deepest_floor": 1,
}

var dark_essence: int = 0
var meta_upgrades: Dictionary = {}

func reset_run_stats() -> void:
    run_reset.emit()
