extends Control

@onready var slider = $VBoxContainer/vol/volume/MarginContainer/Control/volume
@onready var debtimer = $VBoxContainer/Timer

var vol : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var audio_settings = ConfigHandler.load_audio_settings()
	slider.value = min(audio_settings.volume, 0.25)*100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_resolution_item_selected(index: int) -> void:
	pass # Replace with function body.

func _on_controls_item_selected(index: int) -> void:
	pass # Replace with function body.

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")


func _on_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigHandler.save_audio_settings("volume", slider.value/100)
