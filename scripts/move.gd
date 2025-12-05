extends State
class_name Move

var arena_center := Vector2.ZERO
var arena_radius := 2500

func enter(prev_state):
	var playback = character.animation_tree.get("parameters/playback")
	if playback:
		playback.travel("move")

func update(delta):
	# --- Rotation handled in Player.gd (independent) ---

	# --- Forward/back input ---
	var move_input = Input.get_action_strength("forward") - Input.get_action_strength("back")
	if abs(move_input) < 0.01:
		# Idle check
		var turn_input = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
		if abs(turn_input) < 0.01:
			return state_machine.get_node("Idle")
		return null

	var direction = Vector2.UP.rotated(deg_to_rad(character.rotation_degrees))
	var desired_move = direction * move_input * character.move_speed * delta

	# --- Clamp to circle ---
	var new_pos = character.global_position + desired_move
	var offset = new_pos - arena_center
	if offset.length() > arena_radius:
		# Keep the player inside: move along the edge if necessary
		var edge_pos = arena_center + offset.normalized() * arena_radius
		new_pos = edge_pos

	character.global_position = new_pos

	return null
