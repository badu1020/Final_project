extends State
class_name Fire
# Reference to the bullet/projectile scene to spawn
@export var projectile_scene: PackedScene
# How long the firing animation/state lasts before returning to idle
@export var fire_duration: float = 0.3
# Speed of the projectile
@export var projectile_speed: float = 500.0
# Timer to track how long we've been in fire state
var timer := 0.0
# Called when entering the fire state
# _prev_state: the state we came from (like Idle or Move)
func enter(_prev_state: String) -> void:
	# Reset the timer
	timer = fire_duration
	# Spawn the projectile
	_spawn_projectile()
	# Play firing animation if available
	if owner.has_node("AnimationPlayer"):
		owner.get_node("AnimationPlayer").play("fire")
	# Optional: play shooting sound
	if owner.has_node("AudioStreamPlayer"):
		owner.get_node("AudioStreamPlayer").play()
# Called every frame while in fire state
# delta: time since last frame
func update(delta: float) -> void:
	# Count down the timer
	timer -= delta
	# When firing animation completes, return to idle/move state
	if timer <= 0:
		_finish_firing()
# Called when leaving the fire state
func exit() -> void:
	pass
# Spawns the projectile from the weapon's marker position
func _spawn_projectile() -> void:
	# Check if we have a projectile scene set
	if not projectile_scene:
		push_error("Fire state: No projectile_scene assigned!")
		return
	
	# Find the Marker2D node (weapon spawn point)
	var marker = owner.get_node_or_null("Marker2D")
	if not marker:
		push_error("Fire state: No Marker2D found on owner!")
		return
	
	# Create the projectile instance
	var projectile = projectile_scene.instantiate()
	
	# Set projectile position to marker position
	projectile.global_position = marker.global_position
	
	# Set projectile direction based on player facing direction
	# Assuming owner has a facing_direction or you can determine from sprite flip
	var direction = Vector2.RIGHT
	if owner.has_method("get_facing_direction"):
		direction = owner.get_facing_direction()
	elif owner.has_node("Sprite2D"):
		# If sprite is flipped, shoot left instead of right
		var sprite = owner.get_node("Sprite2D")
		if sprite.flip_h:
			direction = Vector2.LEFT
	
	# Apply velocity to projectile (if it has this property)
	if projectile.has_method("set_direction"):
		projectile.set_direction(direction)
	elif "velocity" in projectile:
		projectile.velocity = direction * projectile_speed
	elif "direction" in projectile:
		projectile.direction = direction
		projectile.speed = projectile_speed
	
	# Add projectile to the scene (not as child of player, but to the world)
	owner.get_parent().add_child(projectile)

# Called when firing completes and we should return to previous state
func _finish_firing() -> void:
	# TODO: Transition back to appropriate state
	# This depends on your state machine setup
	# Examples:
	# state_machine.change_state("Idle")
	# state_machine.change_state("Move")
	pass
