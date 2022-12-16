extends Node

enum WebXRPrimary {
	AUTO,
	THUMBSTICK,
	TRACKPAD,
}

## User setting for snap-turn
@export var snap_turning : bool = true

## User setting for player height adjust
@export var player_height_adjust : float = 0.0: set = set_player_height_adjust

## User setting for WebXR primary
@export_enum(WebXRPrimary) var webxr_primary : int = WebXRPrimary.AUTO: set = set_webxr_primary

## Settings file name to persist user settings
var settings_file_name : String = "user://xtools_user_settings.json"


## Called when the node enters the scene tree for the first time.
func _ready():
	_load()


## Reset to default values
func reset_to_defaults() -> void:
	# Reset to defaults
	snap_turning = XRTools.get_default_snap_turning()
	player_height_adjust = 0.0
	webxr_primary = WebXRPrimary.AUTO


## Set the player height adjust property
func set_player_height_adjust(new_value : float) -> void:
	player_height_adjust = clamp(new_value, -1.0, 1.0)


## Set the WebXR primary
func set_webxr_primary(new_value : int) -> void:
	webxr_primary = new_value


## Save the settings to file
func save() -> void:
	# Construct the settings dictionary
	var data = {
		"input" : {
			"default_snap_turning" : snap_turning,
			"webxr_primary" : webxr_primary,
		},
		"player" : {
			"height_adjust" : player_height_adjust
		}
	}

	# Save to file
	var file := FileAccess.open(settings_file_name, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(data))


## Load the settings from file
func _load() -> void:
	# First reset our values
	reset_to_defaults()

	# Now attempt to load our settings file
	if !FileAccess.file_exists(settings_file_name):
		return

	# Attempt to open the file
	var file := FileAccess.open(settings_file_name, FileAccess.READ)
	if not file:
		return

	# Read the file as text
	var text = file.get_as_text()

	# Parse the settings dictionary
	var data : Dictionary = JSON.parse_string(text)

	# Parse our input settings
	if data.has("input"):
		var input : Dictionary = data["input"]
		if input.has("default_snap_turning"):
			snap_turning = input["default_snap_turning"]
		if input.has("webxr_primary"):
			webxr_primary = input["webxr_primary"]

	# Parse our player settings
	if data.has("player"):
		var player : Dictionary = data["player"]
		if player.has("height_adjust"):
			player_height_adjust = player["height_adjust"]
