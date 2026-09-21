extends "res://scripts/home.gd"
## Compatibility entry point for existing creator scene/checkpoints.
func _ready() -> void:
	super._ready()
	if profile == null: profile = SaveSlots.current_profile()
	_creator()
