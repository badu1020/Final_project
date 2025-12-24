extends Node

const LOW_LEVEL_NETWORK_PLAYER = preload("res://assets/player.tscn")

func _ready() -> void:
	print("PlayerSpawner ready. Is server: ", NetworkHandler.is_server)
	if NetworkHandler.is_server:
		NetworkHandler.on_peer_connected.connect(spawn_player)
		print("Server: Connected to on_peer_connected")
	# Always connect to client ID assignment signals so a host (server+local client)
	# will spawn its local player when it receives the local ID assignment.
	ClientNetworkGlobals.handle_local_id_assignment.connect(spawn_player)
	ClientNetworkGlobals.handle_remote_id_assignment.connect(spawn_player)
	print("Connected to client ID assignment signals")
	
func spawn_player(id: int) -> void:
	print("spawn_player called with id: ", id)
	# Avoid creating duplicate player nodes for the same id
	var node_name := "player_" + str(id)
	if get_node_or_null(node_name) != null:
		print("Player already exists, skipping spawn: ", id)
		return

	var player = LOW_LEVEL_NETWORK_PLAYER.instantiate()
	player.owner_id = id
	player.name = node_name

	if NetworkHandler.is_server:
		player.set_multiplayer_authority(id)

	add_child(player)
	print("Player spawned: ", id)
