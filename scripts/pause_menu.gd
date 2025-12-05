extends Control

func resume():
	get_tree().paused =false
	
	
func pause():
	get_tree().paused = true

func escape():
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()
		

func _on_resume_pressed() -> void:
	resume()


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
