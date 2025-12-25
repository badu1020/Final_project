extends State
class_name Idle

@onready var eng = $"../../thrusters"
var animation


func enter(prev_state):
	match ConfigHandler.load_ship_size():
		0:
			animation = "frig_engine_move"
		1:
			animation = "cuiser_engine_move"
		2:
			animation = "destroyer_engine_move"
		_:
			animation = "frig_engine_move"
	eng.play(animation)


func handle_input(event):
	if Input.is_action_pressed("forward") or Input.is_action_pressed("back"):
		return state_machine.get_node("Move")
	return null

func update(delta):
	return null
