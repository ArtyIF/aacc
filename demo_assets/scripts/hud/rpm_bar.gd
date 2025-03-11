extends ProgressBar

func _process(_delta: float) -> void:
	value = AACCGlobal.car.get_param("RPMRatio", 0.0)
