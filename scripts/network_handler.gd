extends Node

signal on_peer_connected(peer_id: int)
signal on_peer_disconnected(peer_id: int)
signal on_server_packet(peer_id: int, data: PackedByteArray)

signal on_connnect_to_server()
signal on_disconnect_from_server()
signal on_client_packet(data: PackedByteArray)

var available_peer_id: Array = range(255,-1,-1)
var client_peers: Dictionary[int, ENetPacketPeer] = {}  # initialize
var connected_peer_ids: Array[int] = []

var server_peer : ENetPacketPeer

var connection : ENetConnection
var is_server :bool = false

func _process(delta: float) -> void:
	if connection == null: return
	
	handle_events()

func handle_events()-> void:
	# Poll and process events until none remain.
	if connection == null:
		return

	while true:
		var packet_event: Array = connection.service()
		# connection.service() may return null or an empty array when no event available
		if packet_event == null or packet_event.size() == 0:
			break
		var event_type: ENetConnection.EventType = packet_event[0]
		if event_type == ENetConnection.EVENT_NONE:
			break

		var peer : ENetPacketPeer = packet_event[1]

		match event_type:
			ENetConnection.EVENT_ERROR:
				push_warning("unknown error source: event type")
				# continue processing remaining events
			ENetConnection.EVENT_CONNECT:
				if is_server:
					peer_connected(peer)
				else:
					connected_to_server()
			ENetConnection.EVENT_DISCONNECT:
				if is_server:
					peer_disconnected(peer)
				else:
					disconnected_from_server()
					# continue, but no more events necessarily
			ENetConnection.EVENT_RECEIVE:
				if is_server:
					# ensure meta id exists (GDScript conditional expression)
					var meta_id = peer.get_meta("id") if peer.has_meta("id") else -1
					var pkt: PackedByteArray = peer.get_packet()
					# Log packet info for debugging
					if pkt != null and pkt.size() > 0:
						var ptype = pkt.decode_u8(0)
						print("Server received packet from peer ", meta_id, " type=", ptype, " size=", pkt.size())
					else:
						print("Server received empty packet from peer ", meta_id)
					on_server_packet.emit(meta_id, pkt)
				else:
					var pkt: PackedByteArray = peer.get_packet()
					if pkt != null and pkt.size() > 0:
						var ptype = pkt.decode_u8(0)
						print("Client received packet from server type=", ptype, " size=", pkt.size())
					else:
						print("Client received empty packet from server")
					on_client_packet.emit(pkt)
			_:
				# unknown event - continue
				pass


func host_game():
	get_tree().change_scene_to_file("res://scenes/world.tscn")
	await get_tree().process_frame
	Start_server()


func Start_server(ip_address: String = "127.0.0.1", port: int = 42069):
	connection = ENetConnection.new()
	var error : Error= connection.create_host_bound(ip_address, port)
	if error:
		print("server startting failed")
		connection = null
		return
	print("server started")
	is_server = true
	

func peer_connected(peer: ENetPacketPeer)-> void:
	var peer_id : int = available_peer_id.pop_back()
	peer.set_meta("id", peer_id)
	client_peers[peer_id] = peer
	connected_peer_ids.append(peer_id)
	on_peer_connected.emit(peer_id)
	print("Peer connected: ", peer_id)

func peer_disconnected(peer: ENetPacketPeer)-> void:
	var peer_id : int = peer.get_meta("id")
	available_peer_id.push_back(peer_id)
	client_peers.erase(peer_id)

func _join_game():
	get_tree().change_scene_to_file("res://scenes/world.tscn")
	await get_tree().process_frame
	Start_client()


func Start_client(ip_address: String = "127.0.0.1", port: int = 42069):
	connection = ENetConnection.new()
	var error : Error= connection.create_host(1)
	if error:
		print("client startting failed")
		connection = null
		return
	print("client started")
	server_peer = connection.connect_to_host(ip_address,port)

func disconnect_client()->void:
	if is_server: return
	server_peer.peer_disconnect()

func connected_to_server()-> void:
	on_connnect_to_server.emit()

func disconnected_from_server()-> void:
	on_disconnect_from_server.emit()
	connection = null
