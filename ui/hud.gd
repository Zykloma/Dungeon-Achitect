class_name DungeonHUD
extends CanvasLayer

var economy: EconomySystem
var floor: FloorController
var stats_label: Label
var mode_label: Label

func setup(eco: EconomySystem, floor_controller: FloorController) -> void:
    economy = eco; floor = floor_controller
    var panel := PanelContainer.new(); panel.position = Vector2(12, 12); panel.size = Vector2(385, 180); add_child(panel)
    var box := VBoxContainer.new(); panel.add_child(box)
    stats_label = Label.new(); box.add_child(stats_label)
    mode_label = Label.new(); box.add_child(mode_label)
    var help := Label.new(); help.text = "1 Korridor (2G) | 2 Schatz (50G) | 3 Goblinhöhle (120G) | 4 Stacheln (60G)\nLMB bauen | RMB/Esc abbrechen | MMB ziehen | Mausrad Zoom"; help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; box.add_child(help)

func _process(_delta: float) -> void:
    if economy == null: return
    stats_label.text = "Gold: %.0f   Seelen: %.0f   Mana: %.0f   Ruf: %.1f\nKills: %d   Entkommen: %d" % [economy.gold, economy.souls, economy.mana, economy.fame, AppState.lifetime_stats.heroes_killed, AppState.lifetime_stats.heroes_escaped]
    mode_label.text = "Baumodus: %s" % ("—" if floor.selected_build == &"" else str(ContentDB.room(floor.selected_build).display_name))
