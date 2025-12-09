extends State
class_name Idle

func enter(prev_state):
	var engine = character.get_node("engine")
	engine.play("frig_engine_idle")


func handle_input(event):
	if Input.is_action_pressed("forward") or Input.is_action_pressed("back"):
		return state_machine.get_node("Move")
	return null

func update(delta):
	return null
