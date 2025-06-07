class_name ScenePluginBase extends Node

var car: Car

func register_plugin() -> void:
	AACCGlobal.add_plugin(name, self)
	AACCGlobal.car_changed.connect(update_car)

func unregister_plugin() -> void:
	AACCGlobal.remove_plugin(name)
	AACCGlobal.car_changed.disconnect(update_car)

func _enter_tree() -> void:
	register_plugin()

func _exit_tree() -> void:
	unregister_plugin()

func update_car(new_car: Car) -> void:
	car = new_car
