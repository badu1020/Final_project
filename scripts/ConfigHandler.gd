extends Node

var config := ConfigFile.new()
const SETTINGS_FILE := "user://settings.ini"

func _ready():
	_load_or_create()


# ----------------------------------------------------
# INTERNAL: Load config or create a new file
# ----------------------------------------------------
func _load_or_create():
	var err = config.load(SETTINGS_FILE)

	if err != OK:
		_create_defaults()
		config.save(SETTINGS_FILE)


# ----------------------------------------------------
# DEFAULT VALUES
# ----------------------------------------------------
func _create_defaults():
	# AUDIO
	config.set_value("audio", "volume", 0.25)

	# RESOLUTION (stored cleanly as a single key)
	config.set_value("video", "resolution", "1280x720")
	config.set_value("video", "fullscreen", false)


# ----------------------------------------------------
# AUDIO SAVE / LOAD
# ----------------------------------------------------
func save_audio(volume: float):
	config.set_value("audio", "volume", clamp(volume, 0.0, 1.0))
	config.save(SETTINGS_FILE)

func load_audio() -> float:
	if !config.has_section("audio"):
		_create_defaults()
		config.save(SETTINGS_FILE)

	return config.get_value("audio", "volume", 0.25)


# ----------------------------------------------------
# RESOLUTION SAVE / LOAD
# ----------------------------------------------------
func save_resolution(res_string: String, fullscreen: bool):
	config.set_value("video", "resolution", res_string)
	config.set_value("video", "fullscreen", fullscreen)
	config.save(SETTINGS_FILE)

func load_resolution() -> Dictionary:
	if !config.has_section("video"):
		_create_defaults()
		config.save(SETTINGS_FILE)

	return {
		"resolution": config.get_value("video", "resolution", "1280x720"),
		"fullscreen": config.get_value("video", "fullscreen", false)
	}
