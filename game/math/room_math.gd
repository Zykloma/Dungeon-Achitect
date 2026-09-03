class_name RoomMath
extends RefCounted

static func upgrade_cost(base_cost: float, level: int) -> float:
    return ceil(base_cost * 1.10 * pow(1.65, max(0, level - 1)))

static func room_stat_multiplier(level: int) -> float:
    return 1.0 + 0.18 * float(max(0, level - 1))
