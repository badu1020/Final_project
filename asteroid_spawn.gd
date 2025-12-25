# Update AsteroidSpawn to include a seed
class_name AsteroidSpawn
extends PacketInfo

var asteroid_id: int
var position: Vector2
var direction: Vector2
var scale_value: float
var seed_value: int  # NEW

static func create(asteroid_id: int, pos: Vector2, dir: Vector2, scale_val: float) -> AsteroidSpawn:
	var info := AsteroidSpawn.new()
	info.packet_type = PACKET_TYPE.ASTEROID_SPAWN
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.asteroid_id = asteroid_id
	info.position = pos
	info.direction = dir
	info.scale_value = scale_val
	return info

static func create_from_data(data: PackedByteArray) -> AsteroidSpawn:
	var info := AsteroidSpawn.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(1 + 4 + 4 + 4 + 4 + 4 + 4 )  # Added 4 bytes for seed
	data.encode_u32(1, asteroid_id)
	data.encode_float(5, position.x)
	data.encode_float(9, position.y)
	data.encode_float(13, direction.x)
	data.encode_float(17, direction.y)
	data.encode_float(21, scale_value)
	return data

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	asteroid_id = data.decode_u32(1)
	position.x = data.decode_float(5)
	position.y = data.decode_float(9)
	direction.x = data.decode_float(13)
	direction.y = data.decode_float(17)
	scale_value = data.decode_float(21)
