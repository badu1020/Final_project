extends Node

const LOW_LEVEL_NETWORK_PLAYER = preload("res://assets/player.tscn")

var spawned_player_ids: Array[int] = []  # THIS LINE IS CRITICAL

func _ready() -> void:
	print("PlayerSpawner ready. Is server: ", NetworkHandler.is_server)
	
	ClientNetworkGlobals.handle_local_id_assignment.connect(spawn_local_player)
	ClientNetworkGlobals.handle_remote_id_assignment.connect(spawn_remote_player)
	print("Connected to client ID assignment signals")
	
	if NetworkHandler.is_server && ClientNetworkGlobals.id != -1:
		call_deferred("_enable_camera_for_local_player")

func spawn_local_player(id: int) -> void:
	print("Spawning LOCAL player with id: ", id)
	_spawn_player_internal(id, true)

func spawn_remote_player(id: int) -> void:
	print("Spawning REMOTE player with id: ", id)
	_spawn_player_internal(id, false)

func _spawn_player_internal(id: int, enable_camera: bool) -> void:
	print("_spawn_player_internal called with id: ", id)
	
	# THIS CHECK PREVENTS DUPLICATES
	if id in spawned_player_ids:
		print("Player ID already spawned, SKIPPING: ", id)
		return
	
	var node_name := "player_" + str(id)
	
	if get_node_or_null(node_name) != null:
		print("Player node already exists, SKIPPING: ", id)
		return
	
	var player = LOW_LEVEL_NETWORK_PLAYER.instantiate()
	player.owner_id = id
	player.name = node_name
	
	add_child(player)
	spawned_player_ids.append(id)  # THIS LINE MARKS IT AS SPAWNED
	print("Player spawned: ", id, " is_authority will be: ", (id == ClientNetworkGlobals.id))
	
	if enable_camera:
		call_deferred("_enable_camera_for_local_player")

func _enable_camera_for_local_player() -> void:
	var local_player = get_node_or_null("player_" + str(ClientNetworkGlobals.id))
	if !local_player:
		print("Cannot enable camera: local player not found")
		return
	
	if local_player.has_node("Camera2D"):
		local_player.get_node("Camera2D").enabled = true
		print("Camera enabled for local player ID:", ClientNetworkGlobals.id)
	else:
		print("Camera node not found in player scene")
