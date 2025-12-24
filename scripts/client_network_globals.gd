extends Node

signal handle_local_id_assignment(local_id:int)
signal handle_remote_id_assignment(remote_id: int)
signal handle_player_position(player_position: PlayerPosition)

var id: int = -1
var remote_ids :Array[int] = []  # initialize

func _ready() -> void:
	NetworkHandler.on_client_packet.connect(on_client_packet)
	print("ClientNetworkGlobals ready. Waiting for ID assignment...")
	
func on_client_packet(data: PackedByteArray):
	if data == null or data.size() < 1:
		return  # Safety: ignore empty packets

	var packet_type: int = data.decode_u8(0)

	match packet_type:
		PacketInfo.PACKET_TYPE.ID_ASSIGNMENT:
			# Only safe to call get_var() here
			if data.size() < IdAssignment.MIN_SIZE:
				return
			var buffer := StreamPeerBuffer.new()
			buffer.data_array = data
			buffer.seek(1)  # skip the type byte
			var id_assignment_data = buffer.get_var()
			manage_ids(IdAssignment.create_form_data(id_assignment_data))

		PacketInfo.PACKET_TYPE.PLAYER_POSITION:
			if data.size() < PlayerPosition.MIN_SIZE:
				return
			handle_player_position.emit(PlayerPosition.create_from_data(data))

		_:
			pass



func manage_ids(id_assignment: IdAssignment) -> void:
	print("manage_ids called. Current id:", id, "Assignment id:", id_assignment.id)

	if id == -1:
		id = id_assignment.id
		print("Local ID assigned:", id)
		handle_local_id_assignment.emit(id)

		remote_ids.clear()
		for remote_id in id_assignment.remoted_ids:
			if remote_id == id:
				continue
			remote_ids.append(remote_id)
			print("Remote ID:", remote_id)
			handle_remote_id_assignment.emit(remote_id)
	else:
		if id_assignment.id == id:
			return
		if id_assignment.id in remote_ids:
			return

		remote_ids.append(id_assignment.id)
		print("New remote ID:", id_assignment.id)
		handle_remote_id_assignment.emit(id_assignment.id)
