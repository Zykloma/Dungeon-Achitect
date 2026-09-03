class_name DungeonHUD
extends CanvasLayer

var session: GameSession
var economy: EconomySystem
var floor: FloorController
var stats_label: Label
var mode_label: Label
var selected_label: Label
var upgrade_button: Button
var prestige_button: Button
var research_buttons: Dictionary = {}

const BUILD_IDS: Array[StringName] = [
    &"room.corridor", &"room.lure_treasure", &"room.goblin_den", &"room.spike_trap",
    &"room.skeleton_crypt", &"room.spider_nest", &"room.gold_mine", &"room.training_hall",
    &"room.mana_source", &"room.troll_post", &"room.boss"
]

const RESEARCH_IDS: Array[StringName] = [
    &"research.sharpened_weapons", &"research.thicker_hides", &"research.fast_repairs",
    &"research.cruel_spikes", &"research.better_lures", &"research.efficient_mines",
    &"research.soul_extraction", &"research.arcane_well", &"research.ritual_efficiency",
    &"research.faster_rumors", &"research.room_planning", &"research.dungeon_logistics"
]

func setup(game_session: GameSession) -> void:
    session = game_session
    economy = session.economy
    floor = session.floor
    _build_top_panel()
    _build_sidebar()
    floor.selected_room_changed.connect(_on_selected_room_changed)

func _build_top_panel() -> void:
    var panel := PanelContainer.new()
    panel.position = Vector2(12, 12)
    panel.size = Vector2(470, 145)
    add_child(panel)
    var box := VBoxContainer.new()
    panel.add_child(box)
    stats_label = Label.new()
    box.add_child(stats_label)
    mode_label = Label.new()
    box.add_child(mode_label)
    selected_label = Label.new()
    box.add_child(selected_label)
    var help := Label.new()
    help.text = "1-9 bauen | 0 Troll | B Boss | U Raum upgraden | F5 speichern | Esc abbrechen\nLMB bauen/auswählen | RMB abbrechen | MMB ziehen | Mausrad Zoom"
    help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    box.add_child(help)

func _build_sidebar() -> void:
    var panel := PanelContainer.new()
    panel.position = Vector2(990, 12)
    panel.size = Vector2(278, 696)
    add_child(panel)
    var main_box := VBoxContainer.new()
    panel.add_child(main_box)

    var build_title := Label.new()
    build_title.text = "BAUEN"
    main_box.add_child(build_title)
    for id in BUILD_IDS:
        var def := ContentDB.room(id)
        if def == null:
            continue
        var button := Button.new()
        button.text = def.display_name
        button.pressed.connect(floor.select_build.bind(id))
        main_box.add_child(button)

    upgrade_button = Button.new()
    upgrade_button.text = "Ausgewählten Raum upgraden"
    upgrade_button.disabled = true
    upgrade_button.pressed.connect(_upgrade_selected)
    main_box.add_child(upgrade_button)

    var separator := HSeparator.new()
    main_box.add_child(separator)
    var research_title := Label.new()
    research_title.text = "FORSCHUNG"
    main_box.add_child(research_title)

    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(250, 250)
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    main_box.add_child(scroll)
    var research_box := VBoxContainer.new()
    research_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(research_box)
    for id in RESEARCH_IDS:
        var button := Button.new()
        button.pressed.connect(_buy_research.bind(id))
        research_box.add_child(button)
        research_buttons[id] = button

    prestige_button = Button.new()
    prestige_button.text = "Dungeon versiegeln (Prestige)"
    prestige_button.pressed.connect(_prestige)
    main_box.add_child(prestige_button)

func _process(_delta: float) -> void:
    if economy == null:
        return
    stats_label.text = "Gold: %.0f   Seelen: %.0f   Mana: %.0f   Ruf: %.1f   DE: %d\nKills: %d   Entkommen: %d   RunScore: %.0f" % [
        economy.gold, economy.souls, economy.mana, economy.fame, AppState.dark_essence,
        AppState.lifetime_stats.heroes_killed, AppState.lifetime_stats.heroes_escaped,
        session.prestige_system.current_run_score()
    ]
    mode_label.text = "Baumodus: %s" % ("—" if floor.selected_build == &"" else str(ContentDB.room(floor.selected_build).display_name))
    _refresh_selected()
    _refresh_research()
    prestige_button.disabled = not session.prestige_system.can_prestige()
    prestige_button.text = "Prestige (+%d DE)" % session.prestige_system.available_dark_essence()

func _refresh_selected() -> void:
    var room := floor.selected_room()
    if room == null:
        selected_label.text = "Auswahl: —"
        upgrade_button.disabled = true
        return
    var def := ContentDB.room(room.definition_id)
    var cost := floor.build_service.upgrade_cost(room)
    selected_label.text = "Auswahl: %s L%d" % [def.display_name, room.level]
    upgrade_button.disabled = room.level >= def.max_level or float(cost["gold"]) == INF
    if not upgrade_button.disabled:
        upgrade_button.text = "Upgrade → L%d (%.0f G / %.0f S)" % [room.level + 1, float(cost["gold"]), float(cost["souls"])]
    else:
        upgrade_button.text = "Maximallevel / nicht upgradebar"

func _refresh_research() -> void:
    for id in RESEARCH_IDS:
        var button: Button = research_buttons.get(id)
        var def := ContentDB.research(id)
        if button == null or def == null:
            continue
        var rank := session.research.rank(id)
        if rank >= def.max_rank:
            button.text = "%s  MAX" % def.display_name
            button.disabled = true
            continue
        var cost := session.research.next_cost(id)
        button.text = "%s  %d/%d  [%.0fG %.0fS]" % [def.display_name, rank, def.max_rank, float(cost["gold"]), float(cost["souls"])]
        button.disabled = not session.research.can_buy(id)

func _on_selected_room_changed(_room: RoomInstance) -> void:
    _refresh_selected()

func _upgrade_selected() -> void:
    floor.upgrade_selected_room()

func _buy_research(id: StringName) -> void:
    session.research.buy(id)

func _prestige() -> void:
    session.perform_prestige()
