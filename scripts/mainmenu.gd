extends Node

@onready var ship_size = $ship_select
var inventory


func _ready() -> void:
	AudioPlayer.play_music_level()
	ship_size.current_tab =ConfigHandler.load_ship_size()
	inventory = get_node("/root/gui")
	



func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

#func _on_ship_select_tab_selected(tab: int) -> void:
#
	#


func _on_start_mouse_entered() -> void:
	$ButtonHover.play()


func _on_options_mouse_entered() -> void:
	$ButtonHover.play()


func _on_quit_mouse_entered() -> void:
	$ButtonHover.play()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_ship_select_tab_clicked(tab: int) -> void:
	$ButtonHover.play()
	if inventory:
		inventory.refresh()  # call the function in GUI script
	else:
		print("InventoryGUI node not found!")
	ConfigHandler.save_ship_size(tab)
