extends CharacterBody2D
class_name Player

@export_group("Movement")
@export var move_speed : float = 150.0
@export var rotation_speed : float = 200.0   # degrees per second

@export_group("Nodes")
@export var animation_tree : AnimationTree

var direction := Vector2.ZERO


func _ready() -> void:
	if animation_tree:
		animation_tree.active = true


func _physics_process(delta: float) -> void:
	handle_rotation(delta)
	handle_movement(delta)
	update_animation()


# -------------------------------------------------------------
# ROTATION (independent from movement)
# -------------------------------------------------------------
func handle_rotation(delta: float) -> void:
	var turn_input := Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")

	# Smooth rotation input
	if abs(turn_input) > 0.01:
		rotation_degrees += turn_input * rotation_speed * delta


# -------------------------------------------------------------
# MOVEMENT (independent from rotation)
# -------------------------------------------------------------
func handle_movement(delta: float) -> void:
	var forward := Input.get_action_strength("forward") - Input.get_action_strength("back")

	# Move relative to facing direction
	var forward_vector := Vector2.UP.rotated(rotation)

	velocity = forward_vector * (forward * move_speed)
	move_and_slide()


# -------------------------------------------------------------
# ANIMATION
# -------------------------------------------------------------
func update_animation():
	if not animation_tree:
		return

	var playback = animation_tree["parameters/playback"]

	if velocity.length() < 0.1:
		playback.travel("Idle")
	else:
		playback.travel("move")
