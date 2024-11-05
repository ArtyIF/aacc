extends ProgressBar
@export var car: Car

func _process(_delta: float) -> void:
	value = car.revs.get_current_value()
