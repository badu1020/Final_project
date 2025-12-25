extends Node

signal handle_player_position(peer_id: int, player_position: PlayerPosition)
signal handle_asteroid_spawn(spawn_info: AsteroidSpawn)

var peer_ids: Array[int] = []

func _ready() -> void:
	NetworkHandler.on_peer_connected.connect(on_peer_connected)
	NetworkHandler.on_peer_disconnected.connect(on_peer_disconnected)
	NetworkHandler.on_server_packet.connect(on_server_packet)

func on_peer_connected(peer_id: int) -> void:
	print("ServerNetworkGlobals.on_peer_connected: ", peer_id)
	peer_ids.append(peer_id)
	
	# Send ID assignment to the newly connected peer
	var target_peer = NetworkHandler.client_peers.get(peer_id)
	if target_peer:
		IdAssignment.create(peer_id, peer_ids).send(target_peer)
		NetworkHandler.connection.flush()
		print("Sent ID assignment to new peer ", peer_id, ". peer_ids=", peer_ids)
	
	# Notify ALL OTHER existing clients about the new player
	for existing_peer_id in NetworkHandler.client_peers.keys():
		if existing_peer_id != peer_id:
			var existing_peer = NetworkHandler.client_peers.get(existing_peer_id)
			if existing_peer:
				# Send an update with just the new player's ID
				IdAssignment.create(peer_id, [peer_id]).send(existing_peer)
				print("Notified peer ", existing_peer_id, " about new peer ", peer_id)
	
	# Debug
	var keys = []
	if NetworkHandler.client_peers != null:
		for k in NetworkHandler.client_peers.keys():
			keys.append(k)
	print("NetworkHandler.client_peers keys: ", keys)

func on_peer_disconnected(peer_id: int) -> void:
	peer_ids.erase(peer_id)

func on_server_packet(peer_id: int, data: PackedByteArray) -> void:
	if data == null or data.size() < 1:
		return
	
	var packet_type: int = data.decode_u8(0)
	
	match packet_type:
		PacketInfo.PACKET_TYPE.ASTEROID_SPAWN:
			var spawn_info := AsteroidSpawn.create_from_data(data)
			handle_asteroid_spawn.emit(spawn_info)
		
		PacketInfo.PACKET_TYPE.PLAYER_POSITION:
			if data.size() < PlayerPosition.MIN_SIZE:
				return
			
			var player_pos := PlayerPosition.create_from_data(data)
			
			# Broadcast to ALL OTHER clients (not back to sender)
			for client_id in NetworkHandler.client_peers.keys():
				if client_id != peer_id:
					player_pos.send(NetworkHandler.client_peers[client_id])
			
			# Also emit for server-side processing (arena clamping, etc.)
			handle_player_position.emit(peer_id, player_pos)
		
		_:
			pass
