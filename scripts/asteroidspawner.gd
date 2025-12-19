extends Node
class_name AsteroidSpawner

@export var asteroid_scene: PackedScene
@export var count: int = 25
@export var arena_radius: float = 2500.0
@export var arena_center: Vector2 = Vector2.ZERO

func _ready() -> void:
	for i in range(count):
		var random_spawn_position = get_random_position_from_arena()
		spawn_asteroid(random_spawn_position)

# Generate a random position inside the circular arena
func get_random_position_from_arena() -> Vector2:
	var position: Vector2
	while true:
		# Random angle and radius within arena
		var angle = randf() * TAU
		var radius = randf() * arena_radius
		position = arena_center + Vector2(cos(angle), sin(angle)) * radius

		# If outside forbidden inner circle, return
		if position.distance_to(arena_center) > 200:
			return position

	# fallback (won't ever hit)
	return arena_center + Vector2(arena_radius, 0)


func spawn_asteroid(position: Vector2) -> void:
	if asteroid_scene:
		var asteroid = asteroid_scene.instantiate()
		
		# Random scale between 0.5x and 2x (you can adjust range)
		var random_scale = randf_range(0.5, 2.0)
		asteroid.scale = Vector2(random_scale, random_scale)
		
		# Add to scene safely
		get_tree().current_scene.call_deferred("add_child", asteroid)
		asteroid.global_position = position
