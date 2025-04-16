class_name ScenePluginBase extends Node

@onready var car: Car

func register_plugin() -> void:
	AACCGlobal.add_plugin(name, self)

func unregister_plugin() -> void:
	AACCGlobal.remove_plugin(name)

func update_car() -> void:
	car = AACCGlobal.car

func _enter_tree() -> void:
	register_plugin()

func _exit_tree() -> void:
	AACCGlobal.remove_plugin(name)
