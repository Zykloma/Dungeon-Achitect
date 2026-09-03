class_name RoomInstance
extends Node2D

var instance_id: int
var definition_id: StringName
var origin_cell: Vector2i
var size_cells: Vector2i
var level: int = 1
var fill_color := Color(0.25, 0.25, 0.28)

func setup(id_value: int, def: RoomDefinition, origin: Vector2i) -> void:
    instance_id = id_value; definition_id = def.id; origin_cell = origin; size_cells = def.size_cells
    position = Vector2(origin.x * GridService.CELL_SIZE, origin.y * GridService.CELL_SIZE)
    match def.room_type:
        &"entrance": fill_color = Color(0.22, 0.45, 0.28)
        &"corridor": fill_color = Color(0.28, 0.28, 0.30)
        &"treasure": fill_color = Color(0.55, 0.42, 0.12)
        &"monster": fill_color = Color(0.38, 0.18, 0.18)
        &"trap": fill_color = Color(0.52, 0.20, 0.12)
        _: fill_color = Color(0.20, 0.24, 0.32)
    queue_redraw()

func center_world() -> Vector2:
    return position + Vector2(size_cells.x, size_cells.y) * GridService.CELL_SIZE * 0.5

func _draw() -> void:
    var rect := Rect2(Vector2.ZERO, Vector2(size_cells.x, size_cells.y) * GridService.CELL_SIZE)
    draw_rect(rect, fill_color, true)
    draw_rect(rect, Color(0.75, 0.75, 0.75, 0.45), false, 2.0)
