extends CanvasLayer

var invSize = 6
var ItemsLoad = [
	"res://Items/Cannons.tres",
	"res://Items/Lasers.tres",
	"res://Items/Railgun.tres"
	
]


func _ready() -> void:
	for i in invSize:
		var slot = Inventory_slot.new()
		slot.init(ItemData.Type.STORAGE, Vector2(64,64))
		$weapons.add_child(slot)


	for i in ItemsLoad.size():
		var item = Inventory_item.new()
		item.init(load(ItemsLoad[i]))
		$weapons.get_child(i).add_child(item)
