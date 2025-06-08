extends Node

var scene_plugins: Dictionary[StringName, ScenePluginBase] = {}
signal scene_plugin_added(plugin_name: StringName)
signal scene_plugin_removed(plugin_name: StringName)

func add_scene_plugin(plugin_name: StringName, plugin: ScenePluginBase):
	scene_plugins[plugin_name] = plugin
	scene_plugin_added.emit(plugin_name)

func get_scene_plugin(plugin_name: StringName) -> ScenePluginBase:
	return scene_plugins[plugin_name]

func has_scene_plugin(plugin_name: StringName) -> bool:
	return plugin_name in scene_plugins.keys()

func remove_scene_plugin(plugin_name: StringName):
	scene_plugins.erase(plugin_name)
	scene_plugin_removed.emit(plugin_name)

# TODO: add support for several cars
var _car: Car
signal car_changed(new_car: Car)
var car: Car:
	get:
		return _car
	set(value):
		_car = value
		car_changed.emit(value)
