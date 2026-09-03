extends Node

var session: GameSession
var camera: Camera2D
var dragging := false
var last_mouse := Vector2.ZERO

func _ready() -> void:
    var world := Node2D.new()
    world.name = "World2D"
    add_child(world)
    session = GameSession.new()
    session.name = "GameSession"
    add_child(session)
    session.setup(world)
    camera = Camera2D.new()
    camera.name = "Camera2D"
    world.add_child(camera)
    camera.position = Vector2(650, 1100)
    camera.zoom = Vector2(0.62, 0.62)
    camera.make_current()
    var hud := DungeonHUD.new()
    hud.name = "UI"
    add_child(hud)
    hud.setup(session)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_1: session.floor.select_build(&"room.corridor")
            KEY_2: session.floor.select_build(&"room.lure_treasure")
            KEY_3: session.floor.select_build(&"room.goblin_den")
            KEY_4: session.floor.select_build(&"room.spike_trap")
            KEY_5: session.floor.select_build(&"room.skeleton_crypt")
            KEY_6: session.floor.select_build(&"room.spider_nest")
            KEY_7: session.floor.select_build(&"room.gold_mine")
            KEY_8: session.floor.select_build(&"room.training_hall")
            KEY_9: session.floor.select_build(&"room.mana_source")
            KEY_0: session.floor.select_build(&"room.troll_post")
            KEY_B: session.floor.select_build(&"room.boss")
            KEY_U: session.floor.upgrade_selected_room()
            KEY_ESCAPE: session.floor.cancel_build()
            KEY_F5: SaveService.save_game(session)
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_MIDDLE:
            dragging = event.pressed
            last_mouse = event.position
        elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
            camera.zoom = (camera.zoom * 1.12).clamp(Vector2(0.35, 0.35), Vector2(2.0, 2.0))
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
            camera.zoom = (camera.zoom / 1.12).clamp(Vector2(0.35, 0.35), Vector2(2.0, 2.0))
    elif event is InputEventMouseMotion and dragging:
        var delta := event.position - last_mouse
        last_mouse = event.position
        camera.position -= delta / camera.zoom.x

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST and session:
        SaveService.save_game(session)
