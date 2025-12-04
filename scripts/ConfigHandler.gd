extends Node

var config = ConfigFile.new()
const Settings_file_path = "user://settings.ini"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !FileAccess.file_exists(Settings_file_path):
		config.set_value("audio", "volume", 0.25)
		config.save(Settings_file_path)
	else:
		config.load(Settings_file_path)


func save_audio_settings(key: String, value):
	config.set_value("audio",key,value)
	config.save(Settings_file_path)

func load_audio_settings():
	var audio_settings = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
