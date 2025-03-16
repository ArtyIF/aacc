extends ProgressBar

func _process(_delta: float) -> void:
	value = 1.0 - AACCGlobal.car.get_param(&"rpm_limiter", 0.0)
