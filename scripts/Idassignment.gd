class_name IdAssignment
extends PacketInfo

var id: int
var remoted_ids: Array[int]

static var MIN_SIZE := 2  # type (1 byte) + at least one id (1 byte)

static func create(id: int, remote_ids: Array[int]) -> IdAssignment:
	var info := IdAssignment.new()
	info.packet_type = PACKET_TYPE.ID_ASSIGNMENT
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = id
	info.remoted_ids = remote_ids.duplicate()  # Make a copy
	return info

static func create_form_data(data: PackedByteArray) -> IdAssignment:
	var info := IdAssignment.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()  # Get packet type byte
	
	# Calculate total size: 1 (type) + 1 (id) + 1 (count) + N (remote ids)
	var total_size = 1 + 1 + 1 + remoted_ids.size()
	data.resize(total_size)
	
	# Encode assigned ID
	data.encode_u8(1, id)
	
	# Encode count of remote IDs
	data.encode_u8(2, remoted_ids.size())
	
	# Encode each remote ID
	for i in remoted_ids.size():
		data.encode_u8(3 + i, remoted_ids[i])
	
	return data

func decode(data: PackedByteArray) -> void:
	if data.size() < MIN_SIZE:
		push_error("IdAssignment packet too small: " + str(data.size()))
		return
	
	super.decode(data)
	
	# Decode assigned ID
	id = data.decode_u8(1)
	
	# Decode count and remote IDs
	if data.size() >= 3:
		var count = data.decode_u8(2)
		remoted_ids.clear()
		
		for i in count:
			if data.size() > (3 + i):
				remoted_ids.append(data.decode_u8(3 + i))
	else:
		remoted_ids.clear()
	
	print("IdAssignment decoded: id=", id, " remoted_ids=", remoted_ids)
