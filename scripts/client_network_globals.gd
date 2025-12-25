extends Node

signal handle_local_id_assignment(local_id: int)
signal handle_remote_id_assignment(remote_id: int)
signal handle_player_position(player_position: PlayerPosition)
signal handle_asteroid_spawn(spawn_info: AsteroidSpawn)

var id: int = -1
var remote_ids: Array[int] = []

func _ready() -> void:
	NetworkHandler.on_client_packet.connect(on_client_packet)
	# print("ClientNetworkGlobals ready. Waiting for ID assignment...")
	
	

func on_client_packet(data: PackedByteArray):
	# print("ClientNetworkGlobals received packet. Size:", data.size())
	
	if data == null or data.size() < 1:
		return
	
	var packet_type: int = data.decode_u8(0)
	# print("Packet type:", packet_type)
	
	match packet_type:
		PacketInfo.PACKET_TYPE.ID_ASSIGNMENT:
			print("Processing ID_ASSIGNMENT packet")  # ADD
			if data.size() < IdAssignment.MIN_SIZE:
				print("ERROR: Packet too small!")  # ADD
				return
			
			var id_assignment := IdAssignment.create_form_data(data)
			print("ID assignment created, calling manage_ids")  # ADD
			manage_ids(id_assignment)
		
		PacketInfo.PACKET_TYPE.PLAYER_POSITION:
			if data.size() < PlayerPosition.MIN_SIZE:
				return
			handle_player_position.emit(PlayerPosition.create_from_data(data))
		
		PacketInfo.PACKET_TYPE.ASTEROID_SPAWN:
			var spawn_info := AsteroidSpawn.create_from_data(data)
			handle_asteroid_spawn.emit(spawn_info)
		
		_:
			print("Unknown packet type:", packet_type)  # ADD

func manage_ids(id_assignment: IdAssignment) -> void:
	print("manage_ids called. Current id:", id, " Assignment id:", id_assignment.id)
	
	if id == -1:
		# First time receiving ID - this is OUR id
		id = id_assignment.id
		print("Local ID assigned:", id)
		handle_local_id_assignment.emit(id)
		
		# Emit remote IDs (excluding self)
		remote_ids.clear()
		for remote_id in id_assignment.remoted_ids:
			if remote_id == id:
				continue
			remote_ids.append(remote_id)
			print("Remote ID:", remote_id)
			handle_remote_id_assignment.emit(remote_id)
	else:
		# We already have an ID, this is a notification about a new player
		var new_player_id = id_assignment.id
		
		if new_player_id == id:
			# It's about us, ignore
			return
		
		if new_player_id in remote_ids:
			# We already know about this player
			return
		
		# New remote player!
		remote_ids.append(new_player_id)
		print("New remote player joined:", new_player_id)
		handle_remote_id_assignment.emit(new_player_id)
