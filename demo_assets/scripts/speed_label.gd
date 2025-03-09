extends Label

func _process(_delta: float) -> void:
	text = "%d km/h" % round(AACCGlobal.car.linear_velocity.length() * 3.6)
	text += "\nFWD %d km/h" % round(-AACCGlobal.car.get_param("LocalLinearVelocity", Vector3.ZERO).z * 3.6)
