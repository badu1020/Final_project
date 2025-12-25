extends Node
class_name AsteroidSpawner

@export var asteroid_scene: PackedScene
@export var count: int = 25
@export var arena_radius: float = 2500.0
@export var arena_center: Vector2 = Vector2.ZERO

var next_asteroid_id: int = 0

func _ready() -> void:
	# Only server spawns initial asteroids
	if NetworkHandler.is_server:
		# Wait a moment for clients to be ready
		await get_tree().create_timer(0.5).timeout
		
		for i in range(count):
			var random_spawn_position = get_random_position_from_arena()
			spawn_asteroid(random_spawn_position)
	
	# All clients listen for asteroid spawn packets
	ClientNetworkGlobals.handle_asteroid_spawn.connect(spawn_asteroid_from_network)

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
	if !asteroid_scene:
		return
	
	var asteroid = asteroid_scene.instantiate()
	
	# Random scale and direction
	var random_scale = randf_range(0.5, 2.0)
	var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	asteroid.scale = Vector2(random_scale, random_scale)
	asteroid.direction = random_direction
	asteroid.is_networked = true  # Prevent re-randomizing in _ready
	asteroid.name = "asteroid_" + str(next_asteroid_id)
	
	# Add to scene
	get_tree().current_scene.call_deferred("add_child", asteroid)
	asteroid.set_deferred("global_position", position)
	
	next_asteroid_id += 1

func spawn_asteroid_from_network(spawn_info: AsteroidSpawn) -> void:
	# Avoid duplicate spawns
	if get_tree().current_scene.get_node_or_null("asteroid_" + str(spawn_info.asteroid_id)) != null:
		print("Asteroid ", spawn_info.asteroid_id, " already exists, skipping")
		return
	
	if !asteroid_scene:
		return
	
	var asteroid = asteroid_scene.instantiate()
	asteroid.name = "asteroid_" + str(spawn_info.asteroid_id)
	asteroid.setup_from_network(spawn_info.direction, spawn_info.scale_value)
	
	# Add to scene
	get_tree().current_scene.call_deferred("add_child", asteroid)
	asteroid.set_deferred("global_position", spawn_info.position)
	
	print("Client spawned asteroid ", spawn_info.asteroid_id, " at ", spawn_info.position)
