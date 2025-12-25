extends Node

signal on_peer_connected(peer_id: int)
signal on_peer_disconnected(peer_id: int)
signal on_server_packet(peer_id: int, data: PackedByteArray)

signal on_connnect_to_server()
signal on_disconnect_from_server()
signal on_client_packet(data: PackedByteArray)

var available_peer_id: Array = range(255, -1, -1)
var client_peers: Dictionary = {}
var connected_peer_ids: Array[int] = []

var server_peer: ENetPacketPeer
var connection: ENetConnection
var is_server: bool = false

func _process(delta: float) -> void:
	if connection == null: 
		return
	handle_events()

func handle_events() -> void:
	if connection == null:
		return

	while true:
		var packet_event: Array = connection.service()
		if packet_event == null or packet_event.size() == 0:
			break
		
		var event_type: ENetConnection.EventType = packet_event[0]
		if event_type == ENetConnection.EVENT_NONE:
			break

		var peer: ENetPacketPeer = packet_event[1]

		match event_type:
			ENetConnection.EVENT_ERROR:
				push_warning("Network error occurred")
			
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
			
			ENetConnection.EVENT_RECEIVE:
				var pkt: PackedByteArray = peer.get_packet()
				if pkt != null and pkt.size() > 0:
					if is_server:
						var peer_id: int = peer.get_meta("id")
						on_server_packet.emit(peer_id, pkt)
					else:
						on_client_packet.emit(pkt)

func host_game():
	get_tree().change_scene_to_file("res://scenes/world.tscn")
	await get_tree().process_frame
	Start_server()

func Start_server(ip_address: String = "127.0.0.1", port: int = 42069):
	connection = ENetConnection.new()
	var error: Error = connection.create_host_bound(ip_address, port)
	if error:
		print("Server starting failed")
		connection = null
		return
	
	print("Server started")
	is_server = true
	
	# Assign host player ID
	var host_id: int = available_peer_id.pop_back()
	ClientNetworkGlobals.id = host_id
	connected_peer_ids.append(host_id)
	print("Host assigned ID:", host_id)
	
	# Trigger host player spawn
	ClientNetworkGlobals.handle_local_id_assignment.emit(host_id)

func peer_connected(peer: ENetPacketPeer) -> void:
	var peer_id: int = available_peer_id.pop_back()
	peer.set_meta("id", peer_id)
	
	client_peers[peer_id] = peer
	connected_peer_ids.append(peer_id)
	
	on_peer_connected.emit(peer_id)
	print("Peer connected:", peer_id)

func peer_disconnected(peer: ENetPacketPeer) -> void:
	var peer_id: int = peer.get_meta("id")
	available_peer_id.push_back(peer_id)
	client_peers.erase(peer_id)
	connected_peer_ids.erase(peer_id)
	on_peer_disconnected.emit(peer_id)
	print("Peer disconnected:", peer_id)

func _join_game():
	get_tree().change_scene_to_file("res://scenes/world.tscn")
	await get_tree().process_frame
	Start_client()

func Start_client(ip_address: String = "127.0.0.1", port: int = 42069):
	connection = ENetConnection.new()
	var error: Error = connection.create_host()
	if error:
		print("Client starting failed")
		connection = null
		return
	
	print("Client started")
	
	# Wait to ensure autoloads are ready
	await get_tree().process_frame
	
	server_peer = connection.connect_to_host(ip_address, port)
	print("Connecting to server...")

func disconnect_client() -> void:
	if is_server: 
		return
	if server_peer:
		server_peer.peer_disconnect()

func connected_to_server() -> void:
	print("Connected to server!")
	on_connnect_to_server.emit()

func disconnected_from_server() -> void:
	print("Disconnected from server")
	on_disconnect_from_server.emit()
	connection = null
