extends PanelContainer
class_name Inventory_slot

@export var type: ItemData.Type
var player

func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")

func init(t: ItemData.Type, cms:Vector2) -> void:
	type = t
	custom_minimum_size = cms


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# Data must be an Inventory_item
	if not (data is Inventory_item):
		return false

	match type:
		ItemData.Type.WEAPONS:
			return true
		ItemData.Type.STORAGE:
		# STORAGE slots accept any item
			return true	
		_:
		# Default strict type matching
			return data.data.type == type


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if not (data is Inventory_item):
		return

	var dragged := data as Inventory_item

	# --- 1. Duplicate the dragged item ---
	var copy := dragged.duplicate() as Inventory_item

	# Copy item fields manually (duplicate() does not copy exported resources fully)
	copy.data = dragged.data
	copy.texture = dragged.texture
	copy.tooltip_text = dragged.tooltip_text

	# Prepare for adding
	if copy.get_parent():
		copy.get_parent().remove_child(copy)

	# --- 2. Remove existing item in the slot ---
	if get_child_count() > 0:
		var old := get_child(0)
		remove_child(old)
	

	# --- 3. Place the copy into this slot ---
	add_child(copy)

	if copy is Control:
		copy.position = Vector2.ZERO
