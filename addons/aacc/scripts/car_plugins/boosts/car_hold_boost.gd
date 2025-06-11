class_name CarHoldBoost extends CarPluginBase

@export var boost_force: float = 10000.0
@export var boost_top_speed: float = 55.0
@export var boost_fill_speed: float = 0.1
@export var boost_use_speed: float = 0.2

var boost_amount: SmoothedFloat = SmoothedFloat.new(0.0, boost_fill_speed, boost_use_speed)

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")
@onready var plugin_wp: CarWheelsProcessor = car.get_plugin(&"WheelsProcessor")

func _ready() -> void:
	car.set_meta(&"input_boost", false)

func process_plugin(delta: float) -> void:
	boost_amount.speed_up = boost_fill_speed
	boost_amount.speed_down = boost_use_speed

	if car.get_meta(&"input_boost", false):
		boost_amount.advance_to(0.0, delta)
		if abs(plugin_lvp.local_velocity_linear.z) <= boost_top_speed and boost_amount.get_value() > 0.0:
			var ground_coefficient: float = plugin_wp.ground_coefficient
			if ground_coefficient < 1.0:
				car.set_force(&"boost_air", -car.global_basis.z * boost_force * (1.0 - ground_coefficient), false, to_global(car.center_of_mass) - car.global_position)
			if ground_coefficient > 0.0:
				car.set_force(&"boost_ground", Vector3.FORWARD * boost_force * ground_coefficient, true)
	else:
		boost_amount.advance_to(1.0, delta)
	car.set_meta(&"boost_amount", boost_amount.get_value())
