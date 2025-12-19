extends Node

const LOW_LEVEL_NETWORK_PLAYER = preload("res://assets/player.tscn")

func _ready() -> void:
	print("PlayerSpawner ready. Is server: ", NetworkHandler.is_server)
	if NetworkHandler.is_server:
		NetworkHandler.on_peer_connected.connect(spawn_player)
		print("Server: Connected to on_peer_connected")
	else:
		ClientNetworkGlobals.handle_local_id_assignment.connect(spawn_player)
		ClientNetworkGlobals.handle_remote_id_assignment.connect(spawn_player)
		print("Client: Connected to ID assignment signals")
	
func spawn_player(id: int) -> void:
	print("spawn_player called with id: ", id)
	var player = LOW_LEVEL_NETWORK_PLAYER.instantiate()
	player.owner_id = id
	player.name = str(id)
	
	if NetworkHandler.is_server:
		player.set_multiplayer_authority(id)
	
	add_child(player)
	print("Player spawned: ", id)
