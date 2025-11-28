extends State
class_name Idle

func enter(prev_state):
	character.velocity = Vector2.ZERO
	character.get_node("AnimationPlayer").play("idle")

func handle_input(event):
	if Input.is_action_pressed("move"):
		return state_machine.get_node("RunState")
	return null

func update(delta):
	return null
