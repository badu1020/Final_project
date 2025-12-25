extends CanvasLayer

func _ready():
	layer = 100

func _input(event):
	if event.is_action_pressed("pause"):
		resume()
		get_viewport().set_input_as_handled()

func resume():
	queue_free()
	
	var local_player = get_tree().get_first_node_in_group("local_player")
	if local_player:
		local_player.is_paused = false
		local_player.invincible = false

func _on_resume_pressed():
	resume()

func _on_quit_pressed():
	# First cleanup network
	NetworkHandler.cleanup()
	
	# Wait a frame to ensure cleanup is done
	await get_tree().process_frame
	
	# Then change scene (this will auto-cleanup the old scene)
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
