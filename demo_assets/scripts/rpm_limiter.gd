extends ProgressBar

func _process(_delta: float) -> void:
	value = 1.0 - AACCGlobal.car.get_param("RPMLimiter", 0.0)
