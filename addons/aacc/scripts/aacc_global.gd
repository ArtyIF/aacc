extends Node

var scene_plugins: Dictionary[StringName, ScenePluginBase] = {}

func add_plugin(name: StringName, plugin: ScenePluginBase):
	scene_plugins[name] = plugin

func get_plugin(name: StringName) -> ScenePluginBase:
	return scene_plugins[name]

func remove_plugin(name: StringName):
	scene_plugins.erase(name)

# TODO: add support for several cars
var car: Car
