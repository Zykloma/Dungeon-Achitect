class_name Monster
extends Combatant

var definition: MonsterDefinition
var home_position: Vector2
var aggro_range := 150.0

func setup(def: MonsterDefinition, level: int, at: Vector2) -> void:
    definition = def; team = &"monster"; home_position = at; position = at
    var mult := RoomMath.room_stat_multiplier(level)
    max_hp = def.base_hp * mult; hp = max_hp; damage = def.base_damage * mult; armor = def.armor
    attack_interval = def.attack_interval; move_speed = def.move_speed
    queue_redraw()

func _physics_process(delta: float) -> void:
    if dead: return
    attack_cooldown = max(0.0, attack_cooldown - delta)

func _draw() -> void:
    draw_circle(Vector2.ZERO, 11.0, Color(0.86, 0.32, 0.25))
    draw_circle(Vector2.ZERO, 11.0, Color.WHITE, false, 2.0)
    _draw_health(11.0)
