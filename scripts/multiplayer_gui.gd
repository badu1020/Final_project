extends Control


func _on_host_pressed() -> void:
	NetworkHandler.host_game()


func _on_connect_pressed() -> void:
	NetworkHandler._join_game()
