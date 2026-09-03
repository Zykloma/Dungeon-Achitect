class_name TrapSystem
extends Node

signal trap_triggered(room_id: int, hero: Hero, damage: float)
signal trap_disarmed(room_id: int, hero: Hero)

var build_service: BuildService
var heroes_root: Node2D
var research: ResearchSystem
var analytics: AnalyticsSystem
var cooldowns: Dictionary = {}
var disabled_for: Dictionary = {}
var occupants: Dictionary = {}
var rng := RandomNumberGenerator.new()

func setup(build: BuildService, hero_root: Node2D, research_system: ResearchSystem, analytics_system: AnalyticsSystem) -> void:
    build_service = build
    heroes_root = hero_root
    research = research_system
    analytics = analytics_system
    rng.randomize()

func _physics_process(delta: float) -> void:
    if build_service == null or heroes_root == null:
        return
    _tick_timers(delta)
    for room in build_service.built_rooms:
        if not is_instance_valid(room) or room.definition_id != &"room.spike_trap":
            continue
        _process_spike_trap(room)

func _tick_timers(delta: float) -> void:
    for key in cooldowns.keys():
        cooldowns[key] = max(0.0, float(cooldowns[key]) - delta)
    for key in disabled_for.keys():
        disabled_for[key] = max(0.0, float(disabled_for[key]) - delta)

func _process_spike_trap(room: RoomInstance) -> void:
    var room_id := room.instance_id
    var now_inside: Dictionary = {}
    for child in heroes_root.get_children():
        if not (child is Hero) or child.dead:
            continue
        var hero := child as Hero
        if room.contains_world_point(hero.global_position):
            var hid := hero.get_instance_id()
            now_inside[hid] = true
            var previous: Dictionary = occupants.get(room_id, {})
            if not previous.has(hid):
                _hero_entered_trap(room, hero)
    occupants[room_id] = now_inside

func _hero_entered_trap(room: RoomInstance, hero: Hero) -> void:
    var room_id := room.instance_id
    if float(disabled_for.get(room_id, 0.0)) > 0.0 or float(cooldowns.get(room_id, 0.0)) > 0.0:
        return
    var detection := clampf(hero.definition.trap_detect_chance, 0.0, 0.95)
    if rng.randf() < detection:
        if hero.definition.id == &"hero.thief":
            disabled_for[room_id] = 3.0
            trap_disarmed.emit(room_id, hero)
        return
    var level_mult := 1.0 + 0.22 * float(max(0, room.level - 1))
    var damage := 18.0 * level_mult * research.trap_damage_multiplier()
    var dealt := hero.apply_damage(damage)
    var level_reset_mult := max(0.25, 1.0 - 0.02 * float(max(0, room.level - 1)))
    cooldowns[room_id] = 4.0 * level_reset_mult * research.trap_reset_multiplier()
    if analytics:
        analytics.record_trap_hit(room_id, room.origin_cell, dealt)
    trap_triggered.emit(room_id, hero, dealt)
