extends Node

var session: GameSession
var camera: Camera2D
var dragging := false
var last_mouse := Vector2.ZERO

func _ready() -> void:
    var world := Node2D.new(); world.name = "World2D"; add_child(world)
    session = GameSession.new(); session.name = "GameSession"; add_child(session); session.setup(world)
    camera = Camera2D.new(); camera.name = "Camera2D"; world.add_child(camera); camera.position = Vector2(650, 1100); camera.zoom = Vector2(0.62, 0.62); camera.make_current()
    var hud := DungeonHUD.new(); hud.name = "UI"; add_child(hud); hud.setup(session.economy, session.floor)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_1: session.floor.select_build(&"room.corridor")
            KEY_2: session.floor.select_build(&"room.lure_treasure")
            KEY_3: session.floor.select_build(&"room.goblin_den")
            KEY_4: session.floor.select_build(&"room.spike_trap")
            KEY_ESCAPE: session.floor.cancel_build()
            KEY_F5: SaveService.save_game(session)
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_MIDDLE:
            dragging = event.pressed; last_mouse = event.position
        elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
            camera.zoom = (camera.zoom * 1.12).clamp(Vector2(0.35, 0.35), Vector2(2.0, 2.0))
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
            camera.zoom = (camera.zoom / 1.12).clamp(Vector2(0.35, 0.35), Vector2(2.0, 2.0))
    elif event is InputEventMouseMotion and dragging:
        var delta := event.position - last_mouse; last_mouse = event.position; camera.position -= delta / camera.zoom.x

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST and session:
        SaveService.save_game(session)
