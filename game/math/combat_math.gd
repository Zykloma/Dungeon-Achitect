class_name CombatMath
extends RefCounted

static func physical_damage(raw: float, armor: float) -> float:
    return max(1.0, raw * 25.0 / (25.0 + max(0.0, armor)))

static func magic_damage(raw: float, armor: float) -> float:
    return physical_damage(raw, armor * 0.30)

static func hero_hp(base_hp: float, level: int) -> float:
    return base_hp * pow(1.18, max(0, level - 1))

static func hero_damage(base_damage: float, level: int) -> float:
    return base_damage * pow(1.13, max(0, level - 1))

static func hero_armor(base_armor: float, level: int) -> float:
    return base_armor + floor(float(max(0, level - 1)) / 3.0)

static func hero_gold(base_gold: float, level: int) -> float:
    return round(base_gold * pow(1.15, max(0, level - 1)))

static func hero_souls(base_souls: float, level: int) -> float:
    if base_souls <= 0.0:
        return 0.0
    return max(base_souls, round(base_souls * pow(1.08, max(0, level - 1))))
