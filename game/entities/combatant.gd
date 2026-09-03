class_name Combatant
extends Node2D

signal died(unit: Combatant)

var max_hp: float = 1.0
var hp: float = 1.0
var damage: float = 1.0
var armor: float = 0.0
var attack_interval: float = 1.0
var attack_cooldown: float = 0.0
var move_speed: float = 60.0
var team: StringName
var dead := false
var slow_multiplier := 1.0
var slow_time := 0.0
var armor_multiplier := 1.0
var armor_debuff_time := 0.0
var magic_resistance := 0.0

func _process_statuses(delta: float) -> void:
    if slow_time > 0.0:
        slow_time = max(0.0, slow_time - delta)
        if slow_time <= 0.0:
            slow_multiplier = 1.0
    if armor_debuff_time > 0.0:
        armor_debuff_time = max(0.0, armor_debuff_time - delta)
        if armor_debuff_time <= 0.0:
            armor_multiplier = 1.0

func effective_speed() -> float:
    return move_speed * slow_multiplier

func effective_armor() -> float:
    return max(0.0, armor * armor_multiplier)

func apply_damage(raw: float, magic := false) -> float:
    if dead:
        return 0.0
    var dealt := CombatMath.magic_damage(raw, effective_armor()) if magic else CombatMath.physical_damage(raw, effective_armor())
    if magic and magic_resistance > 0.0:
        dealt *= max(0.0, 1.0 - magic_resistance)
    hp -= dealt
    if hp <= 0.0:
        hp = 0.0
        dead = true
        died.emit(self)
        queue_free()
    queue_redraw()
    return dealt

func heal(amount: float) -> float:
    if dead or amount <= 0.0:
        return 0.0
    var before := hp
    hp = min(max_hp, hp + amount)
    queue_redraw()
    return hp - before

func apply_slow(multiplier: float, duration: float) -> void:
    slow_multiplier = min(slow_multiplier, clampf(multiplier, 0.20, 1.0))
    slow_time = max(slow_time, duration)

func apply_armor_debuff(multiplier: float, duration: float) -> void:
    armor_multiplier = min(armor_multiplier, clampf(multiplier, 0.10, 1.0))
    armor_debuff_time = max(armor_debuff_time, duration)

func _draw_health(radius := 12.0) -> void:
    var pct := clampf(hp / max(1.0, max_hp), 0.0, 1.0)
    draw_rect(Rect2(Vector2(-radius, -radius - 8), Vector2(radius * 2, 4)), Color(0.12, 0.12, 0.12), true)
    draw_rect(Rect2(Vector2(-radius, -radius - 8), Vector2(radius * 2 * pct, 4)), Color(0.25, 0.8, 0.28), true)
