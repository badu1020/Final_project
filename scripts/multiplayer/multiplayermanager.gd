extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var multiplayer_scene = preload("res://scenes/multiplayer_player.tscn")
var player_spawn_node
var pending_players := []

func become_host():
	# 1) Create server first
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = server_peer

	# 2) Load world AFTER peer is set
	var world = preload("res://scenes/world.tscn").instantiate()
	get_tree().root.add_child(world)
	get_tree().current_scene = world

	# 3) Get player spawn node
	player_spawn_node = world.get_node("players")

	# 4) connect signals AFTER spawn node exists
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_del_player)

	# 5) Add host player manually (peer_connected does NOT fire for host)
	_add_player(multiplayer.get_unique_id())


func connect_to_server():
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = client_peer

func _add_player(id):
	print("player joined:", id)

	var p = multiplayer_scene.instantiate()
	p.player_id = id
	p.name = str(id)

	player_spawn_node.add_child(p, true)

func _del_player(id):
	print("player left:", id)
