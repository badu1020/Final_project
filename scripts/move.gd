extends State
class_name Move



func enter(prev_state):
	var playback = character.animation_tree.get("parameters/playback")
	playback.travel("move")

func update(delta):
	# movement vector
	var input_vec = Vector2(
		Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left"),
		Input.get_action_strength("back") - Input.get_action_strength("forward")
	)

	# if no input -> return to idle
	if input_vec.length() < 0.1:
		return state_machine.get_node("Idle")

	# --- ROTATION (smooth turning) ---
	var target_angle = rad_to_deg(input_vec.angle())
	character.rotation_degrees = lerp_angle(
		character.rotation_degrees,
		target_angle,
		character.rotation_speed * delta
	)

	# --- MOVEMENT ---
	character.velocity = input_vec.normalized() * character.move_speed
	character.move_and_slide()

	return null
