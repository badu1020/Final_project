extends Node

var config := ConfigFile.new()
const SETTINGS_FILE := "user://settings.ini"

func _ready():
	_load_or_create()

# ----------------------------------------------------
# INTERNAL
# ----------------------------------------------------
func _ensure_loaded():
	# Loads settings file only if config has nothing
	if config.get_sections().is_empty():
		config.load(SETTINGS_FILE)

func _load_or_create():
	var err = config.load(SETTINGS_FILE)
	if err != OK:
		_create_defaults()
		config.save(SETTINGS_FILE)

func _create_defaults():
	config.set_value("audio", "volume", 0.25)
	config.set_value("video", "resolution", "1280x720")
	config.set_value("video", "fullscreen", false)
	config.set_value("ship", "size", 1)
	config.set_value("waepons","port",0)
	config.set_value("weapons","port2",0)
	config.set_value("weapons","starbord",0)
	config.set_value("weapons","starbord",0)
	config.set_value("weapons","keel",0)

# ----------------------------------------------------
# AUDIO
# ----------------------------------------------------
func save_audio(volume: float):
	_ensure_loaded()
	config.set_value("audio", "volume", clamp(volume, 0.0, 1.0))
	config.save(SETTINGS_FILE)

func load_audio() -> float:
	_ensure_loaded()
	return config.get_value("audio", "volume", 0.25)

# ----------------------------------------------------
# RESOLUTION
# ----------------------------------------------------
func save_resolution(res_string: String, fullscreen: bool):
	_ensure_loaded()
	config.set_value("video", "resolution", res_string)
	config.set_value("video", "fullscreen", fullscreen)
	config.save(SETTINGS_FILE)

func load_resolution() -> Dictionary:
	_ensure_loaded()
	return {
		"resolution": config.get_value("video", "resolution", "1280x720"),
		"fullscreen": config.get_value("video", "fullscreen", false)
	}

# ----------------------------------------------------
# SHIP SIZE
# ----------------------------------------------------
func save_ship_size(size: int):
	_ensure_loaded()
	config.set_value("ship", "size", size)
	config.save(SETTINGS_FILE)

func load_ship_size() -> int:
	_ensure_loaded()
	return config.get_value("ship", "size", 1)

func save_weapons(id :int, key: String):
	_ensure_loaded()
	print(id, key)
	config.set_value("waepons", key, id)
	config.save(SETTINGS_FILE)
	
func load_weapons():
	_ensure_loaded()
	if config.has_section("weapons"):
		for key in config.get_section_keys("weapons"):
			return config.get_value("weapons", key, 0)
