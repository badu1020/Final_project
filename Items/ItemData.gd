class_name ItemData
extends Resource

enum Type {WEAPONS, STORAGE}

@export var type: Type
@export var name:String
@export_multiline var disc :String
@export var texture = Texture
@export var damage : int
@export var fire_rate : int
@export var power : int
@export var range : int
@export var weapon_id : int
