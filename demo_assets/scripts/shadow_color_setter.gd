extends Node

@export var shadow_color: Color = Color.BLACK
@export_range(0.0, 1.0) var shadow_color_amount: float = 0.5

func _process(_delta: float) -> void:
	AACCGlobal.current_shadow_color = shadow_color
	AACCGlobal.current_shadow_color_amount = shadow_color_amount
