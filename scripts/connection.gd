extends Control



func _on_host_button_pressed() -> void:
	Multiplayermanager.become_host()
	get_tree().change_scene_to_file("res://scenes/world.tscn")
 

func _on_connect_button_pressed() -> void:
	Multiplayermanager.connect_to_server()
	get_tree().change_scene_to_file("res://scenes/world.tscn")
