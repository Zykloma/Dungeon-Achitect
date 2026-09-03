class_name PathService
extends Node

var astar := AStarGrid2D.new()
var grid: GridService
var path_cache: Dictionary = {}
var revision: int = 0

func setup(grid_service: GridService) -> void:
    grid = grid_service
    astar.region = Rect2i(Vector2i.ZERO, GridService.FLOOR_SIZE)
    astar.cell_size = Vector2(GridService.CELL_SIZE, GridService.CELL_SIZE)
    astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    astar.update()
    rebuild()

func rebuild() -> void:
    if grid == null: return
    astar.fill_solid_region(astar.region, true)
    for cell in grid.walkable.keys():
        astar.set_point_solid(cell, false)
    revision += 1
    path_cache.clear()

func get_cell_path(from_cell: Vector2i, to_cell: Vector2i) -> Array[Vector2i]:
    if not grid.in_bounds(from_cell) or not grid.in_bounds(to_cell): return []
    var key := "%s:%s:%d" % [from_cell, to_cell, revision]
    if path_cache.has(key): return path_cache[key].duplicate()
    if astar.is_point_solid(from_cell) or astar.is_point_solid(to_cell): return []
    var raw := astar.get_id_path(from_cell, to_cell)
    var result: Array[Vector2i] = []
    for p in raw: result.append(p)
    path_cache[key] = result
    return result
