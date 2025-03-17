class_name CarWheelVisuals extends CarPluginBase

@export var wheel_meshes: Dictionary[CarWheelSuspension, Node3D] = {}
@export var steer_wheels: Array[CarWheelSuspension] = []
var initial_wheel_mesh_transforms: Dictionary[CarWheelSuspension, Transform3D] = {}

func _ready() -> void:
	for wheel in wheel_meshes.keys():
		initial_wheel_mesh_transforms[wheel] = wheel_meshes[wheel].transform

func process_plugin(delta: float) -> void:
	for wheel: CarWheelSuspension in wheel_meshes.keys():
		var new_transform: Transform3D = initial_wheel_mesh_transforms[wheel]

		var suspension_translation: Vector3 = wheel.suspension_length * Vector3.DOWN
		if wheel.is_landed:
			suspension_translation *= 1.0 - wheel.compression
		new_transform = new_transform.translated_local(suspension_translation)

		if wheel in steer_wheels:
			var steer_rotation: float = -car.get_param(&"input_steer", 0.0) * car.get_param(&"steer_velocity_base", 0.0)
			# TODO: ackermann simulation
			new_transform = new_transform.rotated_local(Vector3.UP, steer_rotation)

		# TODO: rolling

		wheel_meshes[wheel].transform = new_transform
