extends ProgressBar

func _process(_delta: float) -> void:
	value = AACCGlobal.current_car.revs.get_current_value()
