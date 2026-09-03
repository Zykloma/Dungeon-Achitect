class_name FloorController
extends Node2D

var grid: GridService
var path_service: PathService
var economy: EconomySystem
var build_service: BuildService
var heroes_root: Node2D
var monsters_root: Node2D
var rooms_root: Node2D
var selected_build: StringName = &""
var entrance_room: RoomInstance

func setup(eco: EconomySystem) -> void:
    economy = eco
    rooms_root = Node2D.new(); rooms_root.name = "Rooms"; add_child(rooms_root)
    monsters_root = Node2D.new(); monsters_root.name = "Monsters"; add_child(monsters_root)
    heroes_root = Node2D.new(); heroes_root.name = "Heroes"; add_child(heroes_root)
    grid = GridService.new(); grid.name = "GridService"; add_child(grid)
    path_service = PathService.new(); path_service.name = "PathService"; add_child(path_service); path_service.setup(grid)
    build_service = BuildService.new(); build_service.name = "BuildService"; add_child(build_service); build_service.setup(grid, path_service, economy, rooms_root)
    build_service.room_built.connect(_on_room_built)
    entrance_room = build_service.place(&"room.entrance", Vector2i(4, 15), true)
    for x in range(9, 12): build_service.place(&"room.corridor", Vector2i(x, 17), true)
    queue_redraw()

func select_build(id: StringName) -> void:
    selected_build = id

func cancel_build() -> void:
    selected_build = &""

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and selected_build != &"":
        var cell := grid.world_to_cell(get_global_mouse_position())
        build_service.place(selected_build, cell)
        queue_redraw()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
        cancel_build()

func _process(delta: float) -> void:
    for room in build_service.built_rooms:
        var def := ContentDB.room(room.definition_id)
        if def and def.base_fame_per_second > 0.0:
            economy.add(&"fame", def.base_fame_per_second * delta)
    queue_redraw()

func _on_room_built(room: RoomInstance) -> void:
    var def := ContentDB.room(room.definition_id)
    if def and def.room_type == &"monster" and def.spawned_monster_id != &"":
        var slots := 3 if def.id == &"room.goblin_den" else 2
        for i in range(slots):
            var monster := Monster.new(); monsters_root.add_child(monster)
            var offset := Vector2((i % 2) * 26 - 13, (i / 2) * 24 - 8)
            monster.setup(ContentDB.monster(def.spawned_monster_id), room.level, room.center_world() + offset)
    queue_redraw()

func _draw() -> void:
    var total := Vector2(GridService.FLOOR_SIZE.x, GridService.FLOOR_SIZE.y) * GridService.CELL_SIZE
    draw_rect(Rect2(Vector2.ZERO, total), Color(0.06, 0.065, 0.075), true)
    for x in range(GridService.FLOOR_SIZE.x + 1):
        draw_line(Vector2(x * GridService.CELL_SIZE, 0), Vector2(x * GridService.CELL_SIZE, total.y), Color(0.2, 0.2, 0.22, 0.32), 1.0)
    for y in range(GridService.FLOOR_SIZE.y + 1):
        draw_line(Vector2(0, y * GridService.CELL_SIZE), Vector2(total.x, y * GridService.CELL_SIZE), Color(0.2, 0.2, 0.22, 0.32), 1.0)
    if selected_build != &"":
        var def := ContentDB.room(selected_build)
        if def:
            var cell := grid.world_to_cell(get_global_mouse_position())
            var rect := Rect2(Vector2(cell) * GridService.CELL_SIZE, Vector2(def.size_cells) * GridService.CELL_SIZE)
            var valid := grid.in_bounds(cell) and (def.room_type == &"corridor" or grid.can_place(cell, def.size_cells))
            draw_rect(rect, Color(0.25, 0.85, 0.35, 0.25) if valid else Color(0.9, 0.2, 0.2, 0.25), true)
