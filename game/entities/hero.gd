class_name Hero
extends Combatant

signal escaped(hero: Hero)
signal treasure_reached(hero: Hero)

var definition: HeroDefinition
var level: int = 1
var gold_reward: float
var soul_reward: float
var path_service: PathService
var grid: GridService
var cell_path: Array[Vector2i] = []
var path_index := 0
var state: StringName = &"to_treasure"
var entrance_cell: Vector2i
var treasure_cell: Vector2i
var attack_counter := 0
var support_timer := 0.0

func setup(def: HeroDefinition, hero_level: int, path: PathService, grid_service: GridService, entrance: Vector2i, treasure: Vector2i) -> void:
    definition = def
    level = hero_level
    path_service = path
    grid = grid_service
    entrance_cell = entrance
    treasure_cell = treasure
    team = &"hero"
    max_hp = CombatMath.hero_hp(def.base_hp, level)
    hp = max_hp
    damage = CombatMath.hero_damage(def.base_damage, level)
    armor = CombatMath.hero_armor(def.armor, level)
    attack_interval = def.attack_interval
    move_speed = def.move_speed
    gold_reward = CombatMath.hero_gold(def.base_gold_reward, level)
    soul_reward = CombatMath.hero_souls(def.base_soul_reward, level)
    if def.id == &"hero.paladin":
        magic_resistance = 0.20
    position = grid.cell_to_world(entrance_cell)
    _set_destination(treasure_cell)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if dead:
        return
    attack_cooldown = max(0.0, attack_cooldown - delta)
    support_timer += delta
    _process_statuses(delta)
    if definition.id == &"hero.raider" and hp / max_hp < 0.25 and state != &"to_exit":
        state = &"to_exit"
        _set_destination(entrance_cell)
    _move_path(delta)

func _move_path(delta: float) -> void:
    if path_index >= cell_path.size():
        if state == &"to_treasure":
            treasure_reached.emit(self)
            state = &"to_exit"
            _set_destination(entrance_cell)
        elif state == &"to_exit":
            escaped.emit(self)
            queue_free()
        return
    var target := grid.cell_to_world(cell_path[path_index])
    position = position.move_toward(target, effective_speed() * delta)
    if position.distance_to(target) < 2.0:
        path_index += 1

func _set_destination(cell: Vector2i) -> void:
    cell_path = path_service.get_cell_path(grid.world_to_cell(position), cell)
    path_index = 1 if cell_path.size() > 1 else 0

func attack_range() -> float:
    if definition.id == &"hero.ranger" or definition.id == &"hero.mage":
        return 4.0 * GridService.CELL_SIZE
    return 58.0

func _draw() -> void:
    draw_circle(Vector2.ZERO, 12.0, Color(0.25, 0.55, 0.95))
    draw_circle(Vector2.ZERO, 12.0, Color.WHITE, false, 2.0)
    _draw_health(12.0)
