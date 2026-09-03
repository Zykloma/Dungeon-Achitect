class_name RoomInstance
extends Node2D

var instance_id: int
var definition_id: StringName
var origin_cell: Vector2i
var size_cells: Vector2i
var level: int = 1
var fill_color := Color(0.25, 0.25, 0.28)

func setup(id_value: int, def: RoomDefinition, origin: Vector2i, room_level: int = 1) -> void:
    instance_id = id_value
    definition_id = def.id
    origin_cell = origin
    size_cells = def.size_cells
    level = clampi(room_level, 1, def.max_level)
    position = Vector2(origin.x * GridService.CELL_SIZE, origin.y * GridService.CELL_SIZE)
    match def.room_type:
        &"entrance": fill_color = Color(0.22, 0.45, 0.28)
        &"corridor": fill_color = Color(0.28, 0.28, 0.30)
        &"treasure": fill_color = Color(0.55, 0.42, 0.12)
        &"monster": fill_color = Color(0.38, 0.18, 0.18)
        &"trap": fill_color = Color(0.52, 0.20, 0.12)
        &"production": fill_color = Color(0.20, 0.34, 0.40)
        &"support": fill_color = Color(0.34, 0.22, 0.44)
        &"boss": fill_color = Color(0.48, 0.12, 0.34)
        _: fill_color = Color(0.20, 0.24, 0.32)
    queue_redraw()

func center_world() -> Vector2:
    return position + Vector2(size_cells.x, size_cells.y) * GridService.CELL_SIZE * 0.5

func contains_world_point(point: Vector2) -> bool:
    var local := to_local(point)
    return Rect2(Vector2.ZERO, Vector2(size_cells) * GridService.CELL_SIZE).has_point(local)

func serialize() -> Dictionary:
    return {
        "instance_id": instance_id,
        "definition_id": str(definition_id),
        "origin": [origin_cell.x, origin_cell.y],
        "level": level,
    }

func _draw() -> void:
    var rect := Rect2(Vector2.ZERO, Vector2(size_cells.x, size_cells.y) * GridService.CELL_SIZE)
    draw_rect(rect, fill_color, true)
    draw_rect(rect, Color(0.75, 0.75, 0.75, 0.45), false, 2.0)
    if level > 1:
        draw_string(ThemeDB.fallback_font, Vector2(8, 20), "L%d" % level, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
