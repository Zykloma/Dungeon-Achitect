class_name SpawnDirector
extends Node

signal hero_killed(tier: int)
signal hero_escaped(tier: int)

var economy: EconomySystem
var build_service: BuildService
var path_service: PathService
var grid: GridService
var heroes_root: Node2D
var research: ResearchSystem
var meta: MetaProgressionSystem
var spawn_timer := 2.0
var rng := RandomNumberGenerator.new()

func setup(eco: EconomySystem, build: BuildService, path: PathService, grid_service: GridService, root: Node2D, research_system: ResearchSystem, meta_system: MetaProgressionSystem) -> void:
    economy = eco
    build_service = build
    path_service = path
    grid = grid_service
    heroes_root = root
    research = research_system
    meta = meta_system
    rng.randomize()

func _process(delta: float) -> void:
    if economy == null:
        return
    spawn_timer -= delta
    if spawn_timer <= 0.0:
        _spawn_wave()
        spawn_timer = _spawn_interval(economy.fame)

func _spawn_wave() -> void:
    var entrance := build_service.find_first(&"entrance")
    var treasure := build_service.find_first(&"treasure")
    if entrance == null or treasure == null:
        return
    var entrance_cell := grid.world_to_cell(entrance.center_world())
    var treasure_cell := grid.world_to_cell(treasure.center_world())
    if path_service.get_cell_path(entrance_cell, treasure_cell).is_empty():
        return
    var count := _group_size(economy.fame)
    for i in range(count):
        var def := _pick_hero(economy.fame)
        var hero := Hero.new()
        hero.name = "Hero_%s_%d" % [Time.get_ticks_usec(), i]
        heroes_root.add_child(hero)
        hero.setup(def, _pick_level(economy.fame), path_service, grid, entrance_cell, treasure_cell)
        hero.position += Vector2(i * 8.0, i * 5.0)
        hero.died.connect(_on_hero_died.bind(hero))
        hero.escaped.connect(_on_hero_escaped)

func clear_all() -> void:
    if heroes_root:
        for child in heroes_root.get_children():
            child.queue_free()
    spawn_timer = 2.0

func _on_hero_died(_unit: Combatant, hero: Hero) -> void:
    var gold := hero.gold_reward * meta.gold_multiplier()
    var souls := hero.soul_reward * research.soul_loot_multiplier() * meta.soul_multiplier()
    economy.add(&"gold", gold)
    economy.add(&"souls", souls)
    economy.add(&"fame", 0.25 * hero.definition.tier)
    AppState.lifetime_stats.heroes_killed += 1
    hero_killed.emit(hero.definition.tier)

func _on_hero_escaped(hero: Hero) -> void:
    economy.add(&"fame", 3.0 * hero.definition.tier)
    AppState.lifetime_stats.heroes_escaped += 1
    hero_escaped.emit(hero.definition.tier)

func _spawn_interval(fame: float) -> float:
    var base := 14.0
    if fame < 10:
        base = 14.0
    elif fame < 25:
        base = 12.0
    elif fame < 50:
        base = 10.0
    elif fame < 90:
        base = 8.0
    elif fame < 150:
        base = 6.5
    else:
        base = 5.0
    return max(2.0, base * research.spawn_interval_multiplier() * meta.spawn_interval_multiplier())

func _group_size(fame: float) -> int:
    if fame < 10:
        return 1
    if fame < 25:
        return 2 if rng.randf() < 0.05 else 1
    if fame < 50:
        return 2 if rng.randf() < 0.15 else 1
    if fame < 90:
        return rng.randi_range(2, 3)
    if fame < 150:
        return rng.randi_range(3, 4)
    return rng.randi_range(3, 5)

func _pick_hero(fame: float) -> HeroDefinition:
    var pool: Array[StringName] = [&"hero.raider", &"hero.militia"]
    if fame >= 10:
        pool.append(&"hero.warrior")
    if fame >= 25:
        pool.append_array([&"hero.thief", &"hero.ranger"])
    if fame >= 50:
        pool.append_array([&"hero.mage", &"hero.cleric"])
    if fame >= 90:
        pool.append_array([&"hero.barbarian", &"hero.paladin"])
    if fame >= 150:
        pool.append(&"hero.champion")
    return ContentDB.hero(pool[rng.randi_range(0, pool.size() - 1)])

func _pick_level(fame: float) -> int:
    if fame < 25:
        return rng.randi_range(1, 3)
    if fame < 50:
        return rng.randi_range(2, 6)
    if fame < 90:
        return rng.randi_range(4, 10)
    if fame < 150:
        return rng.randi_range(7, 15)
    return rng.randi_range(10, 20 + int(fame / 100.0))
