extends ProgressBar

func _process(_delta: float) -> void:
	value = AACCGlobal.car.get_meta(&"rpm_ratio", 0.0)
