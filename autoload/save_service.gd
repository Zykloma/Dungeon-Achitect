extends Node

const SAVE_PATH := "user://save_v1.json"
const BACKUP_PATH := "user://save_v1.backup.json"

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
    if FileAccess.file_exists(SAVE_PATH):
        var old := FileAccess.get_file_as_string(SAVE_PATH)
        var backup := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
        if backup:
            backup.store_string(old)
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f == null:
        return false
    f.store_string(JSON.stringify(payload, "  "))
    return true

func load_game() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {}
    var raw := FileAccess.get_file_as_string(SAVE_PATH)
    var parsed = JSON.parse_string(raw)
    if parsed is Dictionary:
        return parsed
    return {}
