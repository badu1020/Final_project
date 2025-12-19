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
	var packet_type :int = data.decode_u8(0)
	print("Client received packet type: ", packet_type)
	
	match packet_type:
		PacketInfo.PACKET_TYPE.ID_ASSIGNMENT:
			print("Received ID_ASSIGNMENT packet")
			manage_ids(IdAssignment.create_form_data(data))
		PacketInfo.PACKET_TYPE.PLAYER_POSITION:
			handle_player_position.emit(PlayerPosition.create_from_data(data))
		_: pass

func manage_ids(id_assignment: IdAssignment) -> void:
	print("manage_ids called. Current id: ", id, " Assignment id: ", id_assignment.id)
	if id == -1:
		id = id_assignment.id
		print("Local ID assigned: ", id)
		handle_local_id_assignment.emit(id_assignment.id)
		remote_ids = id_assignment.remoted_ids
		for remote_id in remote_ids:
			if remote_id == id: continue
			print("Remote ID: ", remote_id)
			handle_remote_id_assignment.emit(remote_id)
	else:
		remote_ids.append(id_assignment.id)
		print("New remote ID: ", id_assignment.id)
		handle_remote_id_assignment.emit(id_assignment.id)
