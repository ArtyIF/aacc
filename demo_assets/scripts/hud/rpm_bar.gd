extends ProgressBar

func _process(_delta: float) -> void:
	value = AACCGlobal.car.get_param("rpm_ratio", 0.0)
