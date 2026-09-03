class_name EconomySystem
extends Node

signal changed(currency: StringName, value: float)

var gold: float = 250.0
var souls: float = 0.0
var mana: float = 0.0
var fame: float = 0.0
var run_gold_earned: float = 0.0
var run_souls_earned: float = 0.0
var run_mana_earned: float = 0.0
var max_fame: float = 0.0

func add(currency: StringName, amount: float) -> void:
    if amount == 0.0:
        return
    match currency:
        &"gold":
            gold += amount
            run_gold_earned += max(0.0, amount)
            AppState.lifetime_stats.gold_earned += max(0.0, amount)
        &"souls":
            souls += amount
            run_souls_earned += max(0.0, amount)
            AppState.lifetime_stats.souls_earned += max(0.0, amount)
        &"mana":
            mana += amount
            run_mana_earned += max(0.0, amount)
            AppState.lifetime_stats.mana_earned += max(0.0, amount)
        &"fame":
            fame = max(0.0, fame + amount)
            max_fame = max(max_fame, fame)
            AppState.lifetime_stats.max_fame = max(AppState.lifetime_stats.max_fame, fame)
    changed.emit(currency, get_value(currency))

func can_afford(gold_cost: float, soul_cost: float = 0.0, mana_cost: float = 0.0) -> bool:
    return gold >= gold_cost and souls >= soul_cost and mana >= mana_cost

func spend(gold_cost: float, soul_cost: float = 0.0, mana_cost: float = 0.0) -> bool:
    if not can_afford(gold_cost, soul_cost, mana_cost):
        return false
    gold -= gold_cost
    souls -= soul_cost
    mana -= mana_cost
    changed.emit(&"gold", gold)
    changed.emit(&"souls", souls)
    changed.emit(&"mana", mana)
    return true

func get_value(currency: StringName) -> float:
    match currency:
        &"gold": return gold
        &"souls": return souls
        &"mana": return mana
        &"fame": return fame
    return 0.0

func reset_run(starting_gold: float = 250.0) -> void:
    gold = starting_gold
    souls = 0.0
    mana = 0.0
    fame = 0.0
    run_gold_earned = 0.0
    run_souls_earned = 0.0
    run_mana_earned = 0.0
    max_fame = 0.0
    for currency in [&"gold", &"souls", &"mana", &"fame"]:
        changed.emit(currency, get_value(currency))

func serialize() -> Dictionary:
    return {
        "gold": gold,
        "souls": souls,
        "mana": mana,
        "fame": fame,
        "run_gold_earned": run_gold_earned,
        "run_souls_earned": run_souls_earned,
        "run_mana_earned": run_mana_earned,
        "max_fame": max_fame,
    }

func restore(data: Dictionary) -> void:
    gold = float(data.get("gold", 250.0))
    souls = float(data.get("souls", 0.0))
    mana = float(data.get("mana", 0.0))
    fame = float(data.get("fame", 0.0))
    run_gold_earned = float(data.get("run_gold_earned", 0.0))
    run_souls_earned = float(data.get("run_souls_earned", 0.0))
    run_mana_earned = float(data.get("run_mana_earned", 0.0))
    max_fame = float(data.get("max_fame", fame))
