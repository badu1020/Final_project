class_name AsteroidPosition
extends PacketInfo

var asteroid_id: int
var position: Vector2

static var MIN_SIZE := 1 + 4 + 4 + 4  # type + id + x + y

static func create(asteroid_id: int, pos: Vector2) -> AsteroidPosition:
	var info := AsteroidPosition.new()
	info.packet_type = PACKET_TYPE.ASTEROID_POSITION
	info.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	info.asteroid_id = asteroid_id
	info.position = pos
	return info

static func create_from_data(data: PackedByteArray) -> AsteroidPosition:
	var info := AsteroidPosition.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(MIN_SIZE)
	data.encode_u32(1, asteroid_id)
	data.encode_float(5, position.x)
	data.encode_float(9, position.y)
	return data

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	asteroid_id = data.decode_u32(1)
	position.x = data.decode_float(5)
	position.y = data.decode_float(9)
