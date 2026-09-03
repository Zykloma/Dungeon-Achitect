class_name BuildService
extends Node

signal room_built(room: RoomInstance)
signal build_failed(reason: String)

var grid: GridService
var path_service: PathService
var economy: EconomySystem
var rooms_root: Node2D
var next_room_id := 1
var built_rooms: Array[RoomInstance] = []

func setup(grid_service: GridService, path: PathService, eco: EconomySystem, root: Node2D) -> void:
    grid = grid_service; path_service = path; economy = eco; rooms_root = root

func place(definition_id: StringName, origin: Vector2i, free := false) -> RoomInstance:
    var def := ContentDB.room(definition_id)
    if def == null:
        build_failed.emit("Unbekannter Raum")
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
    if not free and not economy.spend(def.base_gold_cost, def.base_soul_cost):
        build_failed.emit("Nicht genug Ressourcen")
        return null
    var room := RoomInstance.new()
    room.name = "Room_%d" % next_room_id
    room.setup(next_room_id, def, origin)
    rooms_root.add_child(room)
    if is_corridor: grid.add_corridor(origin, next_room_id)
    else: grid.occupy(next_room_id, origin, def.size_cells, true)
    next_room_id += 1
    built_rooms.append(room)
    path_service.rebuild()
    room_built.emit(room)
    return room

func find_first(type: StringName) -> RoomInstance:
    for room in built_rooms:
        var def := ContentDB.room(room.definition_id)
        if def and def.room_type == type: return room
    return null
