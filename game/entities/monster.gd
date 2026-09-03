class_name Monster
extends Combatant

var definition: MonsterDefinition
var home_position: Vector2
var aggro_range := 150.0
var source_room_id := -1
var stat_hp_multiplier := 1.0
var stat_damage_multiplier := 1.0
var regen_timer := 0.0
var revived_once := false

func setup(def: MonsterDefinition, _level: int, at: Vector2, hp_mult: float = 1.0, dmg_mult: float = 1.0, room_id: int = -1) -> void:
    definition = def
    team = &"monster"
    home_position = at
    position = at
    source_room_id = room_id
    stat_hp_multiplier = hp_mult
    stat_damage_multiplier = dmg_mult
    max_hp = def.base_hp * stat_hp_multiplier
    hp = max_hp
    damage = def.base_damage * stat_damage_multiplier
    armor = def.armor
    attack_interval = def.attack_interval
    move_speed = def.move_speed
    queue_redraw()

func apply_stat_multipliers(hp_mult: float, dmg_mult: float) -> void:
    var pct := hp / max(1.0, max_hp)
    stat_hp_multiplier = hp_mult
    stat_damage_multiplier = dmg_mult
    max_hp = definition.base_hp * stat_hp_multiplier
    hp = max(1.0, max_hp * pct)
    damage = definition.base_damage * stat_damage_multiplier
    queue_redraw()

func _physics_process(delta: float) -> void:
    if dead:
        return
    attack_cooldown = max(0.0, attack_cooldown - delta)
    _process_statuses(delta)
    if definition and definition.ability_id == &"regeneration":
        regen_timer += delta
        if regen_timer >= 5.0:
            regen_timer = 0.0
            heal(max_hp * 0.02)

func has_tag(tag: StringName) -> bool:
    return definition != null and tag in definition.tags

func _draw() -> void:
    draw_circle(Vector2.ZERO, 11.0, Color(0.86, 0.32, 0.25))
    draw_circle(Vector2.ZERO, 11.0, Color.WHITE, false, 2.0)
    _draw_health(11.0)
