extends Node
class_name AsteroidSpawner

@export var asteroid_scene: PackedScene
@export var count: int = 25
@export var arena_radius: float = 2500.0
@export var arena_center: Vector2 = Vector2.ZERO
@export var sync_interval: float = 1.0  # ADD: Initialize sync interval

var next_asteroid_id: int = 0
var spawned_asteroids: Dictionary = {}
var sync_timer: float = 0.0

func _ready() -> void:
	# All clients listen for asteroid packets
	ClientNetworkGlobals.handle_asteroid_spawn.connect(spawn_asteroid_from_network)  # ADD THIS
	ClientNetworkGlobals.handle_asteroid_position.connect(update_asteroid_position)
	
	# Only server spawns initial asteroids
	if NetworkHandler.is_server:
		NetworkHandler.on_peer_connected.connect(_send_asteroids_to_new_peer)
		await get_tree().process_frame
		
		for i in range(count):
			var random_spawn_position = get_random_position_from_arena()
			spawn_asteroid(random_spawn_position)

func _process(delta: float) -> void:
	if !NetworkHandler.is_server:
		return
	
	sync_timer += delta
	if sync_timer >= sync_interval:
		sync_timer = 0.0
		sync_asteroid_positions()

func sync_asteroid_positions() -> void:
	var asteroids = get_tree().get_nodes_in_group("asteroids")
	for asteroid in asteroids:
		if asteroid.name.begins_with("asteroid_"):
			var id_str = asteroid.name.replace("asteroid_", "")
			var asteroid_id = id_str.to_int()
			
			AsteroidPosition.create(asteroid_id, asteroid.global_position) \
				.broadcast(NetworkHandler.connection)
	
	if asteroids.size() > 0:
		NetworkHandler.connection.flush()

func update_asteroid_position(pos_info: AsteroidPosition) -> void:
	var asteroid = get_tree().current_scene.get_node_or_null("asteroid_" + str(pos_info.asteroid_id))
	if asteroid:
		asteroid.global_position = pos_info.position

func get_random_position_from_arena() -> Vector2:
	var position: Vector2
	while true:
		var angle = randf() * TAU
		var radius = randf() * arena_radius
		position = arena_center + Vector2(cos(angle), sin(angle)) * radius
		if position.distance_to(arena_center) > 200:
			return position
	return arena_center + Vector2(arena_radius, 0)

func spawn_asteroid(position: Vector2) -> void:
	if !asteroid_scene:
		return
	
	var asteroid = asteroid_scene.instantiate()
	
	var random_scale = randf_range(0.5, 2.0)
	var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	asteroid.scale = Vector2(random_scale, random_scale)
	asteroid.direction = random_direction
	asteroid.is_networked = true
	asteroid.name = "asteroid_" + str(next_asteroid_id)
	asteroid.add_to_group("asteroids")  # ADD THIS - Required for sync to find asteroids
	
	spawned_asteroids[next_asteroid_id] = {
		"position": position,
		"direction": random_direction,
		"scale": random_scale
	}
	
	get_tree().current_scene.call_deferred("add_child", asteroid)
	asteroid.set_deferred("global_position", position)
	
	if NetworkHandler.is_server:
		AsteroidSpawn.create(next_asteroid_id, position, random_direction, random_scale) \
			.broadcast(NetworkHandler.connection)
		NetworkHandler.connection.flush()
		print("Server spawned and broadcast asteroid ", next_asteroid_id)
	
	next_asteroid_id += 1

func spawn_asteroid_from_network(spawn_info: AsteroidSpawn) -> void:
	print("Client spawning asteroid from network: id=", spawn_info.asteroid_id)
	
	if get_tree().current_scene.has_node("asteroid_" + str(spawn_info.asteroid_id)):
		print("Asteroid ", spawn_info.asteroid_id, " already exists, skipping")
		return
	
	if !asteroid_scene:
		return
	
	var asteroid = asteroid_scene.instantiate()
	asteroid.name = "asteroid_" + str(spawn_info.asteroid_id)
	asteroid.setup_from_network(spawn_info.direction, spawn_info.scale_value)  # REMOVE seed parameter
	asteroid.add_to_group("asteroids")  # ADD THIS
	
	get_tree().current_scene.call_deferred("add_child", asteroid)
	asteroid.set_deferred("global_position", spawn_info.position)
	
	print("Client spawned asteroid ", spawn_info.asteroid_id, " at ", spawn_info.position)

func _send_asteroids_to_new_peer(peer_id: int) -> void:
	print("Sending ", spawned_asteroids.size(), " asteroids to new peer ", peer_id)
	var peer = NetworkHandler.client_peers.get(peer_id)
	if !peer:
		return
	
	for asteroid_id in spawned_asteroids.keys():
		var data = spawned_asteroids[asteroid_id]
		AsteroidSpawn.create(asteroid_id, data.position, data.direction, data.scale).send(peer)  # REMOVE seed parameter
	
	NetworkHandler.connection.flush()
