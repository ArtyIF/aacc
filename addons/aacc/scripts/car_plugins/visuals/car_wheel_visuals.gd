class_name CarWheelVisuals extends CarPluginBase

const WHEEL_FLAG_STEER = 1 << 0
const WHEEL_FLAG_DRIVE = 1 << 1
const WHEEL_FLAG_HANDBRAKE = 1 << 2

@export_custom(PROPERTY_HINT_DICTIONARY_TYPE, "22/26:CarWheelSuspension;22/26:Node3D") var wheel_meshes: Dictionary[NodePath, NodePath] = {}
@export_custom(PROPERTY_HINT_DICTIONARY_TYPE, "22/26:CarWheelSuspension;2/6:Steer,Drive,Handbrake") var wheel_flags: Dictionary[NodePath, int] = {}
var initial_wheel_mesh_transforms: Dictionary[NodePath, Transform3D] = {}
var forward_rotations: Dictionary[NodePath, float] = {}

func _ready() -> void:
	for wheel in wheel_meshes.keys():
		initial_wheel_mesh_transforms[wheel] = get_node(wheel_meshes[wheel]).transform
		forward_rotations[wheel] = 0.0

func process_plugin(delta: float) -> void:
	var local_linear_velocity: Vector3 = car.get_meta(&"local_linear_velocity", Vector3.ZERO)
	var input_steer: float = car.get_meta(&"input_steer", 0.0)
	var steer_velocity_base: float = car.get_meta(&"steer_velocity_base", 0.0)
	var input_handbrake: bool = car.get_meta(&"input_handbrake", false)

	for wheel_path: NodePath in wheel_meshes.keys():
		var wheel: CarWheelSuspension = get_node(wheel_path)
		var new_transform: Transform3D = initial_wheel_mesh_transforms[wheel_path]

		var suspension_translation: Vector3 = wheel.suspension_length * Vector3.DOWN
		if wheel.is_landed:
			suspension_translation *= 1.0 - wheel.compression
		new_transform = new_transform.translated_local(suspension_translation)

		if wheel_path in wheel_flags.keys():
			if wheel_flags[wheel_path] & WHEEL_FLAG_STEER:
				var steer_rotation: float = -input_steer * steer_velocity_base
				# TODO: ackermann simulation
				new_transform = new_transform.rotated_local(Vector3.UP, steer_rotation)

			if wheel.is_landed: # TODO: keep rotating in air with some sort of resistance
				if not (wheel_flags[wheel_path] & WHEEL_FLAG_HANDBRAKE and input_handbrake):
					forward_rotations[wheel_path] -= local_linear_velocity.z * delta / wheel.wheel_radius
					# TODO: wheelspin

			if forward_rotations[wheel_path] > 2 * PI:
				forward_rotations[wheel_path] -= 2 * PI
			elif forward_rotations[wheel_path] < 2 * PI:
				forward_rotations[wheel_path] += 2 * PI
			new_transform = new_transform.rotated_local(Vector3.RIGHT, forward_rotations[wheel_path])

		get_node(wheel_meshes[wheel_path]).transform = new_transform
