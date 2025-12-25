extends Node

@onready var ship_size = $ship_select
@onready var inventory = $Panel  # Change this - it's now a direct child

func _ready() -> void:
	AudioPlayer.apply_saved_volume()
	AudioPlayer.play_music_level()
	ship_size.current_tab = ConfigHandler.load_ship_size()
	reset_camera()
	# inventory is already assigned via @onready
	
func reset_camera():
	# Find and remove any world cameras that might still exist
	for node in get_tree().get_nodes_in_group("world_camera"):
		node.queue_free()
	
	# Reset viewport camera to default
	var viewport = get_viewport()
	if viewport:
		viewport.canvas_transform = Transform2D() 
func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_start_mouse_entered() -> void:
	$ButtonHover.play()

func _on_options_mouse_entered() -> void:
	$ButtonHover.play()

func _on_quit_mouse_entered() -> void:
	$ButtonHover.play()

func _on_start_pressed() -> void:
	AudioPlayer.stop_music()
	get_tree().change_scene_to_file("res://scenes/multiplayer_gui.tscn")

func _on_ship_select_tab_clicked(tab: int) -> void:
	$ButtonHover.play()
	if inventory:
		inventory.refresh()  # call the function in Panel script
	else:
		print("Panel node not found!")
	ConfigHandler.save_ship_size(tab)
