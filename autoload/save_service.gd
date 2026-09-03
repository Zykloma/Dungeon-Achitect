extends Node

const SAVE_PATH := "user://save_01.json"
const BACKUP_PATH := "user://save_01.bak"
const TEMP_PATH := "user://save_01.tmp"
const LEGACY_PATH := "user://save_v1.json"

func save_game(session: Node) -> bool:
    if session == null or not session.has_method("serialize_state"):
        return false
    var payload: Dictionary = session.serialize_state()
    payload["save_version"] = AppState.SAVE_VERSION
    payload["last_save_unix"] = Time.get_unix_time_from_system()
    payload["meta"] = {
        "dark_essence": AppState.dark_essence,
        "meta_upgrades": AppState.meta_upgrades,
        "lifetime_stats": AppState.lifetime_stats,
    }
    var text := JSON.stringify(payload, "  ")
    var temp := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
    if temp == null:
        return false
    if not temp.store_string(text):
        return false
    temp.flush()
    temp = null
    if FileAccess.file_exists(SAVE_PATH):
        if FileAccess.file_exists(BACKUP_PATH):
            DirAccess.remove_absolute(BACKUP_PATH)
        if DirAccess.rename_absolute(SAVE_PATH, BACKUP_PATH) != OK:
            return false
    if DirAccess.rename_absolute(TEMP_PATH, SAVE_PATH) != OK:
        if FileAccess.file_exists(BACKUP_PATH):
            DirAccess.rename_absolute(BACKUP_PATH, SAVE_PATH)
        return false
    return true

func load_game() -> Dictionary:
    var data := _load_path(SAVE_PATH)
    if data.is_empty():
        data = _load_path(BACKUP_PATH)
    if data.is_empty():
        data = _load_path(LEGACY_PATH)
    if data.is_empty():
        return {}
    return _migrate(data)

func _load_path(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var raw := FileAccess.get_file_as_string(path)
    var parsed = JSON.parse_string(raw)
    if parsed is Dictionary:
        return parsed
    return {}

func _migrate(data: Dictionary) -> Dictionary:
    var version := int(data.get("save_version", 1))
    if version < 2:
        if not data.has("research"):
            data["research"] = {"ranks": {}}
        if not data.has("prestige"):
            data["prestige"] = {"boss_kills": 0, "deepest_floor": 1}
        if not data.has("analytics"):
            data["analytics"] = {}
        version = 2
    data["save_version"] = version
    return data
