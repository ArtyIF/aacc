extends Node

@export_range(0.0, 1.0) var shadow_intensity: float = 1.0

func _process(_delta: float) -> void:
	AACCGlobal.current_shadow_intensity = shadow_intensity
