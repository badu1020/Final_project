extends Node

signal handle_player_position(peer_id: int, player_position: PlayerPosition)

var peer_ids: Array[int] = []  # initialize

func _ready() -> void:
	NetworkHandler.on_peer_connected.connect(on_peer_connected)
	NetworkHandler.on_peer_disconnected.connect(on_peer_disconnected)
	NetworkHandler.on_server_packet.connect(on_server_packet)

func on_peer_connected(peer_id:int )-> void:
	print("ServerNetworkGlobals.on_peer_connected: ", peer_id)
	peer_ids.append(peer_id)
	
	# Build and broadcast the ID assignment packet
	IdAssignment.create(peer_id, peer_ids).broadcast(NetworkHandler.connection)
	print("Sent ID assignment for new peer ", peer_id, ". peer_ids=", peer_ids)

	# Debug: list known client_peers on NetworkHandler
	if has_node("/root"): # safe guard in case autoload setup differs
		# print keys safely (NetworkHandler may be autoloaded)
		var keys = []
		if NetworkHandler.client_peers != null:
			for k in NetworkHandler.client_peers.keys():
				keys.append(k)
		print("NetworkHandler.client_peers keys: ", keys)

func on_peer_disconnected(peer_id: int)-> void:
	peer_ids.erase(peer_id)

func on_server_packet(peer_id: int, data: PackedByteArray)-> void:
	var packet_type: int = data.decode_u8(0)
	match packet_type:
		PacketInfo.PACKET_TYPE.PLAYER_POSITION:
			handle_player_position.emit(peer_id, PlayerPosition.create_from_data(data))
		_: pass
