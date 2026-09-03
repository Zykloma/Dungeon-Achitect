class_name FloorController
extends Node2D

signal selected_room_changed(room: RoomInstance)

var grid: GridService
var path_service: PathService
var economy: EconomySystem
var research: ResearchSystem
var meta: MetaProgressionSystem
var build_service: BuildService
var heroes_root: Node2D
var monsters_root: Node2D
var rooms_root: Node2D
var selected_build: StringName = &""
var selected_room_id := -1
var entrance_room: RoomInstance
var restoring := false

func setup(eco: EconomySystem, research_system: ResearchSystem, meta_system: MetaProgressionSystem) -> void:
    economy = eco
    research = research_system
    meta = meta_system
    rooms_root = Node2D.new()
    rooms_root.name = "Rooms"
    add_child(rooms_root)
    monsters_root = Node2D.new()
    monsters_root.name = "Monsters"
    add_child(monsters_root)
    heroes_root = Node2D.new()
    heroes_root.name = "Heroes"
    add_child(heroes_root)
    grid = GridService.new()
    grid.name = "GridService"
    add_child(grid)
    path_service = PathService.new()
    path_service.name = "PathService"
    add_child(path_service)
    path_service.setup(grid)
    build_service = BuildService.new()
    build_service.name = "BuildService"
    add_child(build_service)
    build_service.setup(grid, path_service, economy, rooms_root, research, meta)
    build_service.room_built.connect(_on_room_built)
    create_starter_layout()
    queue_redraw()

func create_starter_layout() -> void:
    restoring = true
    entrance_room = build_service.place(&"room.entrance", Vector2i(4, 15), true)
    for x in range(9, 12):
        build_service.place(&"room.corridor", Vector2i(x, 17), true)
    restoring = false

func select_build(id: StringName) -> void:
    selected_build = id
    selected_room_id = -1
    selected_room_changed.emit(null)

func cancel_build() -> void:
    selected_build = &""

func selected_room() -> RoomInstance:
    return build_service.get_room(selected_room_id)

func upgrade_selected_room() -> bool:
    if selected_room_id < 0:
        return false
    return build_service.upgrade_room(selected_room_id)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if selected_build != &"":
            var cell := grid.world_to_cell(get_global_mouse_position())
            build_service.place(selected_build, cell)
            queue_redraw()
        else:
            _select_room_at(get_global_mouse_position())
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
        cancel_build()

func _select_room_at(world: Vector2) -> void:
    var cell := grid.world_to_cell(world)
    selected_room_id = int(grid.occupied.get(cell, -1))
    selected_room_changed.emit(selected_room())
    queue_redraw()

func _on_room_built(room: RoomInstance) -> void:
    if restoring:
        return
    if room.definition_id == &"room.boss":
        economy.add(&"fame", 15.0)
    queue_redraw()

func serialize() -> Dictionary:
    return build_service.serialize()

func restore(data: Dictionary) -> void:
    restoring = true
    build_service.clear_all()
    selected_room_id = -1
    var rows: Array = data.get("rooms", [])
    for row in rows:
        var origin_arr: Array = row.get("origin", [0, 0])
        if origin_arr.size() < 2:
            continue
        var origin := Vector2i(int(origin_arr[0]), int(origin_arr[1]))
        var def_id := StringName(str(row.get("definition_id", "")))
        var level := int(row.get("level", 1))
        var instance_id := int(row.get("instance_id", -1))
        var room := build_service.place_with_state(def_id, origin, level, instance_id, true)
        if room and def_id == &"room.entrance":
            entrance_room = room
    if build_service.built_rooms.is_empty():
        create_starter_layout()
    restoring = false
    path_service.rebuild()
    queue_redraw()

func _draw() -> void:
    var total := Vector2(GridService.FLOOR_SIZE.x, GridService.FLOOR_SIZE.y) * GridService.CELL_SIZE
    draw_rect(Rect2(Vector2.ZERO, total), Color(0.06, 0.065, 0.075), true)
    for x in range(GridService.FLOOR_SIZE.x + 1):
        draw_line(Vector2(x * GridService.CELL_SIZE, 0), Vector2(x * GridService.CELL_SIZE, total.y), Color(0.2, 0.2, 0.22, 0.32), 1.0)
    for y in range(GridService.FLOOR_SIZE.y + 1):
        draw_line(Vector2(0, y * GridService.CELL_SIZE), Vector2(total.x, y * GridService.CELL_SIZE), Color(0.2, 0.2, 0.22, 0.32), 1.0)
    var selected := selected_room()
    if selected:
        var r := Rect2(Vector2(selected.origin_cell) * GridService.CELL_SIZE, Vector2(selected.size_cells) * GridService.CELL_SIZE)
        draw_rect(r, Color(1.0, 0.85, 0.2, 0.85), false, 4.0)
    if selected_build != &"":
        var def := ContentDB.room(selected_build)
        if def:
            var cell := grid.world_to_cell(get_global_mouse_position())
            var rect := Rect2(Vector2(cell) * GridService.CELL_SIZE, Vector2(def.size_cells) * GridService.CELL_SIZE)
            var valid := grid.in_bounds(cell) and (def.room_type == &"corridor" or grid.can_place(cell, def.size_cells))
            draw_rect(rect, Color(0.25, 0.85, 0.35, 0.25) if valid else Color(0.9, 0.2, 0.2, 0.25), true)
