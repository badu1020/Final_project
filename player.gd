extends CharacterBody2D
class_name Player

@export_group("Nodes")
@export var state_machine: Node

@export_group("Movement")
@export var move_speed: float = 350.0
@export var rotation_speed : float = 250.0
@export var max_health : float = 100.0

@onready var sprite: Sprite2D = $main_body
@onready var health_bar = $health_bar
@onready var corvette = preload("res://assets/Foozle_2DS0013_Void_EnemyFleet_2/Nairan/Designs - Base/PNGs/Nairan - Frigate - Base.png")
@onready var cruiser = preload("res://assets/Foozle_2DS0013_Void_EnemyFleet_2/Nairan/Designs - Base/PNGs/Nairan - Battlecruiser - Base.png")
@onready var destroyer = preload("res://assets/Foozle_2DS0013_Void_EnemyFleet_2/Nairan/Designs - Base/PNGs/Nairan - Dreadnought - Base.png")

var direction := Vector2.ZERO
var current_state
var health
var invincible := false

var invincibility_timer := 0.0
var is_authority : bool:
	get: return !NetworkHandler.is_server && owner_id == ClientNetworkGlobals.id

var owner_id: int

func _enter_tree() -> void:
	ServerNetworkGlobals.handle_player_position.connect(server_handle_player_position)
	ClientNetworkGlobals.handle_player_position.connect(client_handle_player_position)

func _exit_tree() -> void:
	ServerNetworkGlobals.handle_player_position.disconnect(server_handle_player_position)
	ClientNetworkGlobals.handle_player_position.disconnect(client_handle_player_position)


func _ready() -> void:
	_switch_sprite()
	
	# Initialize state machine
	current_state = state_machine.get_node("Idle")
	current_state.enter(null)
	$equipable.load_from_config()
	health_bar.max_value = max_health
	health = max_health
	set_health()

func _unhandled_input(event):
	var new_state = current_state.handle_input(event)
	if new_state:
		_switch_state(new_state)

func _physics_process(delta: float) -> void:
	# Handle rotation
	var turn_input = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	if abs(turn_input) > 0.01:
		rotation_degrees += turn_input * rotation_speed * delta

	
	# Update invincibility timer
	if invincible:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			invincible = false
	

	# Handle state machine

	var new_state = current_state.update(delta)
	if new_state:
		_switch_state(new_state)
	
	# Handle networked movement
	if is_authority:
		var move_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = move_input * move_speed
		move_and_slide()
		
		# Send position to server
		PlayerPosition.create(owner_id, global_position).send(NetworkHandler.server_peer)

func _switch_state(next_state):
	current_state.exit()
	var prev = current_state.name
	current_state = next_state

	current_state.character = self
	current_state.state_machine = state_machine
	current_state.enter(prev)

func _switch_sprite():
	match ConfigHandler.load_ship_size():
		0: 
			sprite.texture = corvette
			move_speed = 500
			rotation_speed = 400
			max_health = 150
		1: 
			sprite.texture = cruiser
			move_speed = 375
			rotation_speed = 250
			max_health = 350
		2: 
			sprite.texture = destroyer
			move_speed = 200
			rotation_speed = 175
			max_health = 500

func set_health():
	health_bar.value = health

# Networking callbacks
func server_handle_player_position(peer_id: int, player_position : PlayerPosition):
	if owner_id != peer_id: return
	global_position = player_position.position
	PlayerPosition.create(owner_id, global_position).broadcast(NetworkHandler.connection)

func client_handle_player_position(player_position: PlayerPosition):
	if is_authority || owner_id != player_position.id: return
	global_position = player_position.position

# Health / Damage
func take_damage(amount: int) -> void:
	if invincible:
		return

	health -= amount
	set_health()

	if health <= 0:
		print(health)
		_switch_state(state_machine.get_node("Death"))
	else:
		print(health)
		invincible = true
		invincibility_timer = state_machine.get_node("Damage").invincibility_duration
		_switch_state(state_machine.get_node("Damage"))

func _on_hitbox_area_entered(_area: Area2D) -> void:
	take_damage(25)
