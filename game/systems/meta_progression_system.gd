class_name MetaProgressionSystem
extends Node

signal meta_upgrade_bought(id: StringName, rank: int)

func rank(id: StringName) -> int:
    return int(AppState.meta_upgrades.get(id, 0))

func max_rank(id: StringName) -> int:
    var def := ContentDB.meta_upgrade(id)
    return def.max_rank if def else 0

func next_cost(id: StringName) -> int:
    var r := rank(id)
    if r >= max_rank(id):
        return 0
    match id:
        &"meta.ancient_treasury", &"meta.black_pact":
            return 2 + int(floor(pow(float(r + 1), 1.35)))
        &"meta.architect_memory":
            return 3 + 2 * r
        &"meta.blood_book", &"meta.stone_memory":
            return 2 + int(floor(pow(float(r + 1), 1.40)))
        &"meta.fast_invitations":
            return 4 + 3 * r
        &"meta.starting_capital":
            return 1 + int(floor(pow(float(r + 1), 1.25)))
        &"meta.longer_night":
            return 5 + 4 * r
        &"meta.depth_right":
            return 25
        &"meta.relic_chamber":
            return 40
    return 0

func buy(id: StringName) -> bool:
    var def := ContentDB.meta_upgrade(id)
    if def == null or rank(id) >= def.max_rank:
        return false
    var cost := next_cost(id)
    if cost <= 0 or AppState.dark_essence < cost:
        return false
    AppState.dark_essence -= cost
    var new_rank := rank(id) + 1
    AppState.meta_upgrades[id] = new_rank
    meta_upgrade_bought.emit(id, new_rank)
    return true

func gold_multiplier() -> float:
    return 1.0 + 0.04 * rank(&"meta.ancient_treasury")

func soul_multiplier() -> float:
    return 1.0 + 0.03 * rank(&"meta.black_pact")

func room_cost_discount() -> float:
    return 0.02 * rank(&"meta.architect_memory")

func monster_damage_multiplier() -> float:
    return 1.0 + 0.02 * rank(&"meta.blood_book")

func monster_hp_multiplier() -> float:
    return 1.0 + 0.02 * rank(&"meta.stone_memory")

func spawn_interval_multiplier() -> float:
    return max(0.25, 1.0 - 0.015 * rank(&"meta.fast_invitations"))

func starting_gold() -> float:
    return 250.0 + 50.0 * rank(&"meta.starting_capital")

func offline_cap_seconds() -> float:
    return (12.0 + rank(&"meta.longer_night")) * 3600.0

func second_floor_unlocked() -> bool:
    return rank(&"meta.depth_right") > 0

func relics_unlocked() -> bool:
    return rank(&"meta.relic_chamber") > 0
