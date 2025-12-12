extends Control

func _ready():
	visible = false

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if visible:
			resume()
		else:
			pause()

func resume():
	get_tree().paused = false
	visible = false

func pause():
	visible = true
	get_tree().paused = true

func _on_resume_pressed() -> void:
	resume()

func _on_quit_pressed() -> void:
	#Multiplayermanager._del_player()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
