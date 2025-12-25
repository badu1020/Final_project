class_name PlayerPosition
extends PacketInfo

var id: int
var position: Vector2
var rotation_deg: float

static var MIN_SIZE := 1 + 4 + 4 + 4 + 4  # type + id + x + y + rotation = 17 bytes

# Create new PlayerPosition
static func create(id: int, position: Vector2, rotation_deg: float) -> PlayerPosition:
	var info := PlayerPosition.new()
	info.packet_type = PACKET_TYPE.PLAYER_POSITION
	info.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	info.id = id
	info.position = position
	info.rotation_deg = rotation_deg
	return info

# Decode from raw data
static func create_from_data(data: PackedByteArray) -> PlayerPosition:
	var info := PlayerPosition.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data := PackedByteArray()
	data.resize(MIN_SIZE)
	data.encode_u8(0, packet_type)          # 1 byte
	data.encode_s32(1, id)                  # 4 bytes (1-4)
	data.encode_float(5, position.x)        # 4 bytes (5-8)
	data.encode_float(9, position.y)        # 4 bytes (9-12)
	data.encode_float(13, rotation_deg)     # 4 bytes (13-16)
	return data

func decode(data: PackedByteArray) -> void:
	packet_type = data.decode_u8(0)
	id = data.decode_s32(1)
	position = Vector2(
		data.decode_float(5),
		data.decode_float(9)
	)
	rotation_deg = data.decode_float(13)
