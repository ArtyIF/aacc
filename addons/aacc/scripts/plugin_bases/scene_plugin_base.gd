abstract class_name ScenePluginBase extends Node

var car: Car

func _enter_tree() -> void:
	AACCGlobal.add_scene_plugin(name, self)
	AACCGlobal.car_changed.connect(_on_car_changed)

func _exit_tree() -> void:
	AACCGlobal.remove_scene_plugin(name)
	AACCGlobal.car_changed.disconnect(_on_car_changed)

func _on_car_changed(new_car: Car) -> void:
	car = new_car
