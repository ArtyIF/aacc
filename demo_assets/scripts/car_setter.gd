extends Node
@export var car: Car

func _ready() -> void:
	AACCGlobal.current_car = car
