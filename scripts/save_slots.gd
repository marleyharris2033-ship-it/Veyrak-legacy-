extends Node

const SLOT_COUNT = 3
const CREATOR = "res://reference_creator.tscn"
var active_slot = 0
var return_to_slots = false
var storage_root = "user://"
var checkpoint: Dictionary = {}
var settings = {"muted": false, "volume": 0.8}

func _ready() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		settings.muted = bool(config.get_value("audio", "muted", false))
		settings.volume = clampf(float(config.get_value("audio", "volume", 0.8)), 0, 1)
	apply_audio()
	migrate_legacy()

func path_for(slot: int) -> String:
	return storage_root.path_join("save-slot-%d.json" % slot)

func read_slot(slot: int) -> Dictionary:
	if slot < 1 or slot > SLOT_COUNT: return {}
	var path = path_for(slot)
	if not FileAccess.file_exists(path): return {}
	var parser = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK: return {"invalid": true}
	var value = parser.data
	if not value is Dictionary or value.get("version") != 1 or not value.get("profile") is Dictionary:
		return {"invalid": true}
	if not value.get("checkpoint") is Dictionary: return {"invalid": true}
	value.profile = VeyrakProfile.validate(value.profile)
	return value

func write_slot(slot: int, profile: Dictionary, point: Dictionary) -> Error:
	if slot < 1 or slot > SLOT_COUNT: return ERR_INVALID_PARAMETER
	var value = {"version": 1, "profile": VeyrakProfile.validate(profile), "checkpoint": point.duplicate(true), "updated_at": Time.get_datetime_string_from_system()}
	var path = path_for(slot)
	var file = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null: return FileAccess.get_open_error()
	file.store_string(JSON.stringify(value, "\t"))
	file.flush()
	var error = file.get_error()
	file.close()
	if error != OK: return error
	return DirAccess.rename_absolute(path + ".tmp", path)

func save_character(profile: Dictionary) -> Error:
	if active_slot == 0: return VeyrakProfile.save(profile)
	checkpoint = {"scene": CREATOR, "label": "Character creation", "state": {}}
	return write_slot(active_slot, profile, checkpoint)

# World scenes can save a scene path plus position, quests and inventory in state.
# On resume, the scene reads SaveSlots.checkpoint.state to restore that state.
func save_checkpoint(profile: Dictionary, scene: String, label: String, state: Dictionary) -> Error:
	var point = {"scene": scene, "label": label, "state": state.duplicate(true)}
	var error = write_slot(active_slot, profile, point)
	if error == OK: checkpoint = point
	return error

func open_slot(slot: int) -> Error:
	if slot < 1 or slot > SLOT_COUNT: return ERR_INVALID_PARAMETER
	var value = read_slot(slot)
	if value.get("invalid", false): return ERR_FILE_CORRUPT
	var point: Dictionary = value.get("checkpoint", {"scene": CREATOR, "label": "Character creation", "state": {}})
	var scene = str(point.get("scene", ""))
	if not scene.begins_with("res://") or not scene.ends_with(".tscn") or not ResourceLoader.exists(scene): return ERR_FILE_NOT_FOUND
	active_slot = slot
	checkpoint = point
	return get_tree().change_scene_to_file(scene)

func current_profile() -> Dictionary:
	if active_slot == 0: return VeyrakProfile.load_saved()
	return read_slot(active_slot).get("profile", VeyrakProfile.defaults())

func migrate_legacy() -> void:
	if not FileAccess.file_exists(path_for(1)) and FileAccess.file_exists(VeyrakProfile.SAVE_PATH):
		var profile = VeyrakProfile.load_saved()
		if not profile.name.is_empty():
			write_slot(1, profile, {"scene": CREATOR, "label": "Character creation", "state": {}})

func apply_audio() -> void:
	AudioServer.set_bus_mute(0, settings.muted)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(0.001, settings.volume)))

func save_settings() -> Error:
	apply_audio()
	var config = ConfigFile.new()
	config.set_value("audio", "muted", settings.muted)
	config.set_value("audio", "volume", settings.volume)
	return config.save("user://settings.cfg")
