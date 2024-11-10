extends Label

func _process(_delta: float) -> void:
	text = "%d km/h" % (AACCGlobal.current_car.linear_velocity.length() * 3.6)
