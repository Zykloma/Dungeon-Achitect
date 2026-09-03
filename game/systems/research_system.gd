class_name ResearchSystem
extends Node

signal research_bought(id: StringName, rank: int)
signal research_reset

var economy: EconomySystem
var ranks: Dictionary = {}

func setup(eco: EconomySystem) -> void:
    economy = eco

func rank(id: StringName) -> int:
    return int(ranks.get(id, 0))

func is_maxed(id: StringName) -> bool:
    var def := ContentDB.research(id)
    return def == null or rank(id) >= def.max_rank

func next_cost(id: StringName) -> Dictionary:
    var def := ContentDB.research(id)
    if def == null or is_maxed(id):
        return {"gold": 0.0, "souls": 0.0}
    var r := rank(id)
    var growth := pow(def.cost_growth, r)
    return {
        "gold": ceil(def.base_gold_cost * growth),
        "souls": ceil(def.base_soul_cost * growth),
    }

func can_buy(id: StringName) -> bool:
    if economy == null or is_maxed(id):
        return false
    if id == &"research.ritual_efficiency" and not mana_unlocked():
        return false
    var cost := next_cost(id)
    return economy.can_afford(float(cost["gold"]), float(cost["souls"]))

func buy(id: StringName) -> bool:
    if not can_buy(id):
        return false
    var cost := next_cost(id)
    if not economy.spend(float(cost["gold"]), float(cost["souls"])):
        return false
    var new_rank := rank(id) + 1
    ranks[id] = new_rank
    research_bought.emit(id, new_rank)
    return true

func reset_run_research() -> void:
    ranks.clear()
    research_reset.emit()

func monster_damage_multiplier() -> float:
    return 1.0 + 0.08 * rank(&"research.sharpened_weapons")

func monster_hp_multiplier() -> float:
    return 1.0 + 0.08 * rank(&"research.thicker_hides")

func trap_reset_multiplier() -> float:
    return max(0.20, 1.0 - 0.04 * rank(&"research.fast_repairs"))

func trap_damage_multiplier() -> float:
    return 1.0 + 0.10 * rank(&"research.cruel_spikes")

func treasure_fame_multiplier() -> float:
    return 1.0 + 0.12 * rank(&"research.better_lures")

func gold_production_multiplier() -> float:
    return 1.0 + 0.12 * rank(&"research.efficient_mines")

func soul_loot_multiplier() -> float:
    return 1.0 + 0.08 * rank(&"research.soul_extraction")

func mana_unlocked() -> bool:
    return rank(&"research.arcane_well") > 0

func mana_production_multiplier() -> float:
    return 1.0 + 0.10 * rank(&"research.ritual_efficiency")

func spawn_interval_multiplier() -> float:
    return max(0.25, 1.0 - 0.03 * rank(&"research.faster_rumors"))

func room_cost_discount() -> float:
    return 0.03 * rank(&"research.room_planning")

func automation_slots() -> int:
    return rank(&"research.dungeon_logistics")

func serialize() -> Dictionary:
    return {"ranks": ranks.duplicate(true)}

func restore(data: Dictionary) -> void:
    ranks.clear()
    var saved: Dictionary = data.get("ranks", {})
    for key in saved:
        var id := StringName(str(key))
        var def := ContentDB.research(id)
        if def:
            ranks[id] = clampi(int(saved[key]), 0, def.max_rank)
