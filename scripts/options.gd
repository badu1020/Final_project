extends Control

@onready var slider = $VBoxContainer/vol/volume/MarginContainer/Control/volume
@onready var res_option = $VBoxContainer/res/REsolution/resolution

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# AUDIO
	var audio_volume = ConfigHandler.load_audio()
	slider.value = audio_volume * 100  # slider uses 0-100

	# RESOLUTION
	var res_settings = ConfigHandler.load_resolution()
	match res_settings["resolution"]:
		"1920x1080":
			res_option.selected = 1
		"1280x720":
			res_option.selected = 0
		_:
			res_option.selected = 0
			ConfigHandler.save_resolution("1280x720", false)  # default fallback

# Called when resolution option is selected
func _on_resolution_item_selected(index: int) -> void:
	match index:
		0:
			ConfigHandler.save_resolution("1280x720", false)
		1:
			ConfigHandler.save_resolution("1920x1080", true)
	print("Resolution changed to: ", ConfigHandler.load_resolution()["resolution"])

# Called when volume slider drag ends
func _on_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigHandler.save_audio(slider.value / 100)

# Example button to return to main menu
func _on_button_pressed() -> void:
	var res_str = ConfigHandler.load_resolution()["resolution"]  # e.g. "1280x720"
	var parts = res_str.split("x")

# Create Vector2i correctly
	var res_vec = Vector2(int(parts[0]), int(parts[1]))
	DisplayServer.window_set_size(res_vec)
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")


func _on_controls_item_selected(index: int) -> void:
	pass # Replace with function body.
