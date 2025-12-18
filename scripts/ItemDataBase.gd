extends Node
class_name ItemDatabase

var items : Dictionary = {}

func _ready():
	_register(preload("res://Items/Cannons.tres"))
	_register(preload("res://Items/Lasers.tres"))
	_register(preload("res://Items/Railgun.tres"))

func _register(item: ItemData) -> void:
	items[item.weapon_id] = item


func get_item(id) -> ItemData:
	return items.get(int(id), null)
