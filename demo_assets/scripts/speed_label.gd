extends Label
@export var car: Car


func _physics_process(delta: float) -> void:
	text = "%d km/h" % (car.linear_velocity.length() * 3.6)
