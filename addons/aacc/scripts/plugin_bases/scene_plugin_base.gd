class_name ScenePluginBase extends Node

func register_plugin() -> void:
	AACCGlobal.add_plugin(name, self)

func unregister_plugin() -> void:
	AACCGlobal.remove_plugin(name)

func _enter_tree() -> void:
	register_plugin()

func _exit_tree() -> void:
	AACCGlobal.remove_plugin(name)

# TODO: add signal for when cars changed
