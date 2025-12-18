extends Node

var config := ConfigFile.new()
const SETTINGS_FILE := "user://settings.ini"

func _ready():
	_load_or_create()

	config.set_value("weapons", "port", -1)
	config.set_value("weapons", "port2", -1)
	config.set_value("weapons", "starbord", -1)
	config.set_value("weapons", "starbord2", -1)
	config.set_value("weapons", "keel", -1)
	config.save(SETTINGS_FILE)

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
	config.set_value("weapons","port",-1)
	config.set_value("weapons","port2",-1)
	config.set_value("weapons","starbord",-1)
	config.set_value("weapons","starbord2",-1)
	config.set_value("weapons","keel",-1)


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
	config.set_value("weapons", key, id)
	config.save(SETTINGS_FILE)
	
func load_weapons() -> Dictionary:
	_ensure_loaded()

	var weapon_ports := {}

	if config.has_section("weapons"):
		for key in config.get_section_keys("weapons"):
			weapon_ports[key] = config.get_value("weapons", key, -1)
			
	print(weapon_ports)
	return weapon_ports
