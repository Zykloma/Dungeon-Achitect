class_name PrestigeMath
extends RefCounted

static func run_score(gold: float, souls: float, mana: float, boss_kills: int, max_fame: float, deepest_floor: int) -> float:
    return gold + 40.0 * souls + 5.0 * mana + 2500.0 * boss_kills + 500.0 * max_fame + 8000.0 * max(0, deepest_floor - 1)

static func dark_essence(score: float) -> int:
    if score < 25000.0:
        return 0
    return max(4, int(floor(4.0 * pow(score / 25000.0, 0.62))))
