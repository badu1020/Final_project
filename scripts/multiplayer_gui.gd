extends Control


func _on_host_pressed() -> void:
	NetworkHandler.host_game()


func _on_connect_pressed() -> void:
	NetworkHandler._join_game()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
