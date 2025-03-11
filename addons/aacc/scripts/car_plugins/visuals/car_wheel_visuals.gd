class_name CarWheelVisuals extends CarPluginBase

@export var wheel_meshes: Dictionary[CarWheelSuspension, Node3D] = {}
@export var limit_suspension_stretch: bool = true
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
			var compression_translation: float = 1.0 - wheel.compression
			if limit_suspension_stretch:
				compression_translation = max(0.0, compression_translation)
			suspension_translation *= compression_translation
		new_transform = new_transform.translated_local(suspension_translation)

		if wheel in steer_wheels:
			var steer_rotation: float = -car.get_input("Steer") * car.get_param("BaseSteerVelocity", 0.0)
			# TODO: ackermann simulation
			new_transform = new_transform.rotated_local(Vector3.UP, steer_rotation)

		wheel_meshes[wheel].transform = new_transform
