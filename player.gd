extends CharacterBody2D
class_name Player

@export_group("Nodes")
@export var animation_tree: AnimationTree
@export var state_machine: Node

@export_group("Movement")
@export var move_speed: float = 350.0
@export var rotation_speed : float = 250.0
@onready var sprite: Sprite2D = $main_body
@onready var corvette = preload("res://assets/Foozle_2DS0013_Void_EnemyFleet_2/Nairan/Designs - Base/PNGs/Nairan - Frigate - Base.png")
@onready var cruiser = preload("res://assets/Foozle_2DS0013_Void_EnemyFleet_2/Nairan/Designs - Base/PNGs/Nairan - Battlecruiser - Base.png")
@onready var destroyer = preload("res://assets/Foozle_2DS0013_Void_EnemyFleet_2/Nairan/Designs - Base/PNGs/Nairan - Dreadnought - Base.png")

var direction := Vector2.ZERO
var current_state


func _ready() -> void:
	_switch_sprite()
	print(sprite)
	if animation_tree:
		animation_tree.active = true

	# Initialize state machine
	current_state = state_machine.get_node("Idle")
	current_state.enter(null)


func _unhandled_input(event):
	var new_state = current_state.handle_input(event)
	if new_state:
		_switch_state(new_state)

func _physics_process(delta: float) -> void:
	var turn_input = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	if abs(turn_input) > 0.01:
		rotation_degrees += turn_input * rotation_speed * delta
	
	var new_state = current_state.update(delta)
	if new_state:
		_switch_state(new_state)
	


func _switch_state(next_state):
	current_state.exit()
	var prev = current_state
	current_state = next_state

	# IMPORTANT: give the state access to the player and statemachine
	current_state.character = self
	current_state.state_machine = state_machine
	current_state.enter(prev)

func _switch_sprite():
	match ConfigHandler.load_ship_size():
		0: 
			sprite.texture = corvette
			move_speed = 500
			rotation_speed = 400
		1: 
			sprite.texture = cruiser
			move_speed = 375
			rotation_speed = 250
		2: 
			sprite.texture = destroyer
			move_speed = 200
			rotation_speed = 175
