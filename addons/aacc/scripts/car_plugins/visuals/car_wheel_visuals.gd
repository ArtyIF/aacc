class_name CarWheelVisuals extends CarPluginBase

const WHEEL_FLAG_STEER = 1 << 0
const WHEEL_FLAG_DRIVE = 1 << 1
const WHEEL_FLAG_HANDBRAKE = 1 << 2

@export_custom(PROPERTY_HINT_DICTIONARY_TYPE, "22/26:CarWheelSuspension;22/26:Node3D") var wheel_meshes: Dictionary[NodePath, NodePath] = {}
@export_custom(PROPERTY_HINT_DICTIONARY_TYPE, "22/26:CarWheelSuspension;2/6:Steer,Drive,Handbrake") var wheel_flags: Dictionary[NodePath, int] = {}
var initial_wheel_mesh_transforms: Dictionary[NodePath, Transform3D] = {}

func _ready() -> void:
	for wheel in wheel_meshes.keys():
		initial_wheel_mesh_transforms[wheel] = get_node(wheel_meshes[wheel]).transform

func process_plugin(delta: float) -> void:
	for wheel_path: NodePath in wheel_meshes.keys():
		var wheel: CarWheelSuspension = get_node(wheel_path)
		var new_transform: Transform3D = initial_wheel_mesh_transforms[wheel_path]

		var suspension_translation: Vector3 = wheel.suspension_length * Vector3.DOWN
		if wheel.is_landed:
			suspension_translation *= 1.0 - wheel.compression
		new_transform = new_transform.translated_local(suspension_translation)

		if wheel_path in wheel_flags.keys() and wheel_flags[wheel_path] & WHEEL_FLAG_STEER:
			var steer_rotation: float = -car.get_param(&"input_steer", 0.0) * car.get_param(&"steer_velocity_base", 0.0)
			# TODO: ackermann simulation
			new_transform = new_transform.rotated_local(Vector3.UP, steer_rotation)

		# TODO: rolling

		get_node(wheel_meshes[wheel_path]).transform = new_transform
