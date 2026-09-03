class_name MonsterSpawnerSystem
extends Node

signal monster_spawned(monster: Monster, room: RoomInstance)

var build_service: BuildService
var monsters_root: Node2D
var research: ResearchSystem
var meta: MetaProgressionSystem
var room_effects: RoomEffectSystem
var active_by_room: Dictionary = {}
var respawn_queue: Array[Dictionary] = []

func setup(build: BuildService, root: Node2D, research_system: ResearchSystem, meta_system: MetaProgressionSystem, room_effect_system: RoomEffectSystem) -> void:
    build_service = build
    monsters_root = root
    research = research_system
    meta = meta_system
    room_effects = room_effect_system
    build_service.room_built.connect(_on_room_built)
    build_service.room_upgraded.connect(_on_room_upgraded)
    research.research_bought.connect(_on_research_changed)
    meta.meta_upgrade_bought.connect(_on_meta_changed)
    for room in build_service.built_rooms:
        _on_room_built(room)

func _process(delta: float) -> void:
    for i in range(respawn_queue.size() - 1, -1, -1):
        var entry: Dictionary = respawn_queue[i]
        entry["time"] = float(entry.get("time", 0.0)) - delta
        respawn_queue[i] = entry
        if float(entry["time"]) <= 0.0:
            var room_id := int(entry.get("room_id", -1))
            respawn_queue.remove_at(i)
            var room := build_service.get_room(room_id)
            if room:
                _fill_room_slots(room)

func clear_all() -> void:
    respawn_queue.clear()
    active_by_room.clear()
    if monsters_root:
        for child in monsters_root.get_children():
            child.queue_free()

func _on_room_built(room: RoomInstance) -> void:
    var def := ContentDB.room(room.definition_id)
    if def and def.room_type == &"monster" and def.spawned_monster_id != &"":
        _fill_room_slots(room)
    elif def and def.room_type == &"support":
        _refresh_all_monsters()

func _on_room_upgraded(room: RoomInstance) -> void:
    if room.definition_id == &"room.training_hall":
        _refresh_all_monsters()
    else:
        _refresh_existing_monsters(room)
        _fill_room_slots(room)

func _on_research_changed(_id: StringName, _rank: int) -> void:
    _refresh_all_monsters()

func _on_meta_changed(_id: StringName, _rank: int) -> void:
    _refresh_all_monsters()

func _refresh_all_monsters() -> void:
    for room in build_service.built_rooms:
        if not is_instance_valid(room):
            continue
        var def := ContentDB.room(room.definition_id)
        if def and def.room_type == &"monster":
            _refresh_existing_monsters(room)
            _fill_room_slots(room)

func _fill_room_slots(room: RoomInstance) -> void:
    if not is_instance_valid(room):
        return
    var def := ContentDB.room(room.definition_id)
    if def == null or def.spawned_monster_id == &"":
        return
    _prune(room.instance_id)
    var active: Array = active_by_room.get(room.instance_id, [])
    var desired := _slot_count(room)
    while active.size() < desired:
        var monster := _spawn_one(room, active.size())
        if monster == null:
            break
        active.append(monster)
    active_by_room[room.instance_id] = active

func _spawn_one(room: RoomInstance, slot: int) -> Monster:
    var def := ContentDB.room(room.definition_id)
    var monster_def := ContentDB.monster(def.spawned_monster_id)
    if monster_def == null:
        return null
    var monster := Monster.new()
    monsters_root.add_child(monster)
    var columns := max(1, min(3, room.size_cells.x))
    var x := slot % columns
    var y := slot / columns
    var offset := Vector2((x - (columns - 1) * 0.5) * 28.0, (y - 0.5) * 26.0)
    var room_mult := RoomMath.room_stat_multiplier(room.level)
    var hp_mult := room_mult * research.monster_hp_multiplier() * meta.monster_hp_multiplier()
    var dmg_mult := room_mult * research.monster_damage_multiplier() * meta.monster_damage_multiplier()
    dmg_mult *= room_effects.training_damage_multiplier_for(room)
    monster.setup(monster_def, room.level, room.center_world() + offset, hp_mult, dmg_mult, room.instance_id)
    monster.died.connect(_on_monster_died.bind(room.instance_id))
    monster_spawned.emit(monster, room)
    return monster

func _on_monster_died(_unit: Combatant, room_id: int) -> void:
    _prune(room_id)
    var room := build_service.get_room(room_id)
    if room == null:
        return
    var respawn := _respawn_seconds(room)
    respawn_queue.append({"room_id": room_id, "time": respawn})

func _refresh_existing_monsters(room: RoomInstance) -> void:
    _prune(room.instance_id)
    var active: Array = active_by_room.get(room.instance_id, [])
    var room_mult := RoomMath.room_stat_multiplier(room.level)
    var hp_mult := room_mult * research.monster_hp_multiplier() * meta.monster_hp_multiplier()
    var dmg_mult := room_mult * research.monster_damage_multiplier() * meta.monster_damage_multiplier()
    dmg_mult *= room_effects.training_damage_multiplier_for(room)
    for m in active:
        if is_instance_valid(m) and m is Monster:
            m.apply_stat_multipliers(hp_mult, dmg_mult)

func _prune(room_id: int) -> void:
    var active: Array = active_by_room.get(room_id, [])
    var clean: Array = []
    for m in active:
        if is_instance_valid(m) and not m.dead:
            clean.append(m)
    active_by_room[room_id] = clean

func _slot_count(room: RoomInstance) -> int:
    match room.definition_id:
        &"room.goblin_den":
            var goblins := 3
            if room.level >= 3: goblins += 1
            if room.level >= 6: goblins += 1
            if room.level >= 9: goblins += 1
            return goblins
        &"room.skeleton_crypt", &"room.spider_nest":
            var creatures := 2
            if room.level >= 3: creatures += 1
            if room.level >= 6: creatures += 1
            if room.level >= 9: creatures += 1
            return creatures
        &"room.troll_post":
            var trolls := 1
            if room.level >= 5: trolls += 1
            if room.level >= 9: trolls += 1
            return trolls
    return 0

func _respawn_seconds(room: RoomInstance) -> float:
    match room.definition_id:
        &"room.goblin_den": return 12.0
        &"room.skeleton_crypt": return 18.0
        &"room.spider_nest": return 18.0
        &"room.troll_post": return 30.0
    return 15.0
