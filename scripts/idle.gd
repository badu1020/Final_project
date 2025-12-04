extends State
class_name Idle

func enter(prev_state):
	character.velocity = Vector2.ZERO
	# Play idle animation through AnimationTree StateMachine
	var playback = character.animation_tree.get("parameters/playback")
	playback.travel("Idle")

func handle_input(event):
	if Input.is_action_pressed("forward") or Input.is_action_pressed("back"):
		return state_machine.get_node("Move")
	return null

func update(delta):
	return null
