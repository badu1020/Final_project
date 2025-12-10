class_name ItemData
extends Resource

enum Type {PORT,STARBORD, KEEL, STORAGE}

@export var type: Type
@export var name:String
@export_multiline var disc :String
@export var texture = Texture
