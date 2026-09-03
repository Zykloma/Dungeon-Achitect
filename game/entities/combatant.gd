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

func apply_damage(raw: float, magic := false) -> float:
    if dead: return 0.0
    var dealt := CombatMath.magic_damage(raw, armor) if magic else CombatMath.physical_damage(raw, armor)
    hp -= dealt
    if hp <= 0.0:
        hp = 0.0; dead = true; died.emit(self); queue_free()
    queue_redraw()
    return dealt

func _draw_health(radius := 12.0) -> void:
    var pct := clampf(hp / max(1.0, max_hp), 0.0, 1.0)
    draw_rect(Rect2(Vector2(-radius, -radius - 8), Vector2(radius * 2, 4)), Color(0.12, 0.12, 0.12), true)
    draw_rect(Rect2(Vector2(-radius, -radius - 8), Vector2(radius * 2 * pct, 4)), Color(0.25, 0.8, 0.28), true)
