class_name ScenePluginBase extends Node

@onready var car: Car

func register_plugin() -> void:
	AACCGlobal.scene_plugins.append(self)

func update_car() -> void:
	car = AACCGlobal.car

func _ready() -> void:
	register_plugin()
