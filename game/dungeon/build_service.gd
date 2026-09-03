class_name BuildService
extends Node

signal room_built(room: RoomInstance)
signal room_upgraded(room: RoomInstance)
signal build_failed(reason: String)

var grid: GridService
var path_service: PathService
var economy: EconomySystem
var research: ResearchSystem
var meta: MetaProgressionSystem
var rooms_root: Node2D
var next_room_id := 1
var built_rooms: Array[RoomInstance] = []

func setup(grid_service: GridService, path: PathService, eco: EconomySystem, root: Node2D, research_system: ResearchSystem = null, meta_system: MetaProgressionSystem = null) -> void:
    grid = grid_service
    path_service = path
    economy = eco
    rooms_root = root
    research = research_system
    meta = meta_system

func place(definition_id: StringName, origin: Vector2i, free := false) -> RoomInstance:
    return place_with_state(definition_id, origin, 1, -1, free)

func place_with_state(definition_id: StringName, origin: Vector2i, level: int = 1, forced_id: int = -1, free := false) -> RoomInstance:
    var def := ContentDB.room(definition_id)
    if def == null:
        build_failed.emit("Unbekannter Raum")
        return null
    if definition_id == &"room.mana_source" and research and not research.mana_unlocked() and not free:
        build_failed.emit("Manaquelle benötigt Forschung: Arkaner Brunnen")
        return null
    var is_corridor := def.room_type == &"corridor"
    if is_corridor:
        if not grid.in_bounds(origin) or grid.occupied.has(origin):
            build_failed.emit("Zelle belegt")
            return null
    else:
        if not grid.can_place(origin, def.size_cells):
            build_failed.emit("Fläche nicht frei")
            return null
        if definition_id != &"room.entrance" and not grid.has_adjacent_walkable(origin, def.size_cells):
            build_failed.emit("Raum braucht Verbindung zum Dungeon")
            return null
    if not free:
        var costs := build_cost(definition_id)
        if not economy.spend(float(costs["gold"]), float(costs["souls"])):
            build_failed.emit("Nicht genug Ressourcen")
            return null
    var room_id := forced_id if forced_id > 0 else next_room_id
    next_room_id = maxi(next_room_id, room_id + 1)
    var room := RoomInstance.new()
    room.name = "Room_%d" % room_id
    room.setup(room_id, def, origin, level)
    rooms_root.add_child(room)
    if is_corridor:
        grid.add_corridor(origin, room_id)
    else:
        grid.occupy(room_id, origin, def.size_cells, true)
    built_rooms.append(room)
    path_service.rebuild()
    room_built.emit(room)
    return room

func build_cost(definition_id: StringName) -> Dictionary:
    var def := ContentDB.room(definition_id)
    if def == null:
        return {"gold": INF, "souls": INF}
    var discount := combined_room_cost_discount()
    return {
        "gold": ceil(def.base_gold_cost * (1.0 - discount)),
        "souls": ceil(def.base_soul_cost * (1.0 - discount)),
    }

func upgrade_cost(room: RoomInstance) -> Dictionary:
    if room == null:
        return {"gold": INF, "souls": INF}
    var def := ContentDB.room(room.definition_id)
    if def == null or room.level >= def.max_level:
        return {"gold": INF, "souls": INF}
    var discount := combined_room_cost_discount()
    return {
        "gold": ceil(RoomMath.upgrade_cost(def.base_gold_cost, room.level) * (1.0 - discount)),
        "souls": ceil(RoomMath.upgrade_cost(def.base_soul_cost, room.level) * (1.0 - discount)),
    }

func upgrade_room(room_id: int) -> bool:
    var room := get_room(room_id)
    if room == null:
        return false
    var def := ContentDB.room(room.definition_id)
    if def == null or room.level >= def.max_level:
        return false
    var cost := upgrade_cost(room)
    if not economy.spend(float(cost["gold"]), float(cost["souls"])):
        return false
    room.level += 1
    room.queue_redraw()
    room_upgraded.emit(room)
    return true

func combined_room_cost_discount() -> float:
    var discount := 0.0
    if research:
        discount += research.room_cost_discount()
    if meta:
        discount += meta.room_cost_discount()
    return min(0.60, discount)

func clear_all() -> void:
    for room in built_rooms:
        if is_instance_valid(room):
            room.queue_free()
    built_rooms.clear()
    next_room_id = 1
    grid.reset()
    path_service.rebuild()

func get_room(room_id: int) -> RoomInstance:
    for room in built_rooms:
        if is_instance_valid(room) and room.instance_id == room_id:
            return room
    return null

func find_first(type: StringName) -> RoomInstance:
    for room in built_rooms:
        if not is_instance_valid(room):
            continue
        var def := ContentDB.room(room.definition_id)
        if def and def.room_type == type:
            return room
    return null

func rooms_are_adjacent(a: RoomInstance, b: RoomInstance) -> bool:
    if a == null or b == null:
        return false
    var a_cells := grid.rect_cells(a.origin_cell, a.size_cells)
    var b_set: Dictionary = {}
    for c in grid.rect_cells(b.origin_cell, b.size_cells):
        b_set[c] = true
    for cell in a_cells:
        for dir in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
            if b_set.has(cell + dir):
                return true
    return false

func serialize() -> Dictionary:
    var rows: Array = []
    for room in built_rooms:
        if is_instance_valid(room):
            rows.append(room.serialize())
    return {"next_room_id": next_room_id, "rooms": rows}
