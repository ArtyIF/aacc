extends ProgressBar

func _process(_delta: float) -> void:
	value = 1.0 - AACCGlobal.car.get_param(&"rpm_max", 0.0)
