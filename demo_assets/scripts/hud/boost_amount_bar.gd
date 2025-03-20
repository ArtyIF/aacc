extends ProgressBar

func _process(_delta: float) -> void:
	value = AACCGlobal.car.get_meta(&"boost_amount", 0.0)
