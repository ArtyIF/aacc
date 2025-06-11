class_name CarWheelVisuals extends CarPluginBase

enum WheelFlag {
	STEER = 1 << 0,
	DRIVE = 1 << 1,
	HANDBRAKE = 1 << 2,
}

@export_custom(PROPERTY_HINT_DICTIONARY_TYPE, "22/26:CarWheelSuspension;22/26:Node3D") var wheel_meshes: Dictionary[NodePath, NodePath] = {}
@export_custom(PROPERTY_HINT_DICTIONARY_TYPE, "22/26:CarWheelSuspension;2/6:Steer,Drive,Handbrake") var wheel_flags: Dictionary[NodePath, WheelFlag] = {}
@export var burnout_particles_scene: PackedScene

var initial_wheel_mesh_transforms: Dictionary[NodePath, Transform3D] = {}
var forward_rotations: Dictionary[NodePath, float] = {}
var burnout_particles: Dictionary[NodePath, GPUParticles3D] = {}

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")
@onready var plugin_engine: CarEngine = car.get_plugin(&"Engine")
@onready var plugin_steer: CarSteer = car.get_plugin(&"Steer")

func _ready() -> void:
	for wheel in wheel_meshes.keys():
		initial_wheel_mesh_transforms[wheel] = get_node(wheel_meshes[wheel]).transform
		forward_rotations[wheel] = 0.0

		var particles: GPUParticles3D = burnout_particles_scene.instantiate()
		burnout_particles[wheel] = particles
		add_child(particles)

func process_plugin(delta: float) -> void:
	var local_velocity_linear: Vector3 = plugin_lvp.local_velocity_linear
	var input_steer: float = plugin_steer.smooth_steer.get_value()
	var steer_velocity_base: float = plugin_steer.steer_velocity_base
	var input_handbrake: bool = car.get_meta(&"input_handbrake")

	for wheel_path: NodePath in wheel_meshes.keys():
		var wheel: CarWheelSuspension = get_node(wheel_path)
		var new_transform: Transform3D = initial_wheel_mesh_transforms[wheel_path]

		var suspension_translation: Vector3 = wheel.suspension_length * Vector3.DOWN
		if wheel.is_landed:
			suspension_translation *= 1.0 - wheel.compression
		new_transform = new_transform.translated_local(suspension_translation)

		if wheel_path in wheel_flags.keys():
			if wheel_flags[wheel_path] & WheelFlag.STEER:
				var steer_rotation: float = -input_steer * steer_velocity_base
				# TODO: ackermann simulation
				new_transform = new_transform.rotated_local(Vector3.UP, steer_rotation)

			var forward_rotation_speed: float = 0.0
			if wheel.is_landed: # TODO: keep rotating in air with some sort of resistance
				if not (wheel_flags[wheel_path] & WheelFlag.HANDBRAKE and input_handbrake):
					forward_rotation_speed -= local_velocity_linear.z * delta / wheel.wheel_radius
					if wheel_flags[wheel_path] & WheelFlag.DRIVE and plugin_engine.gear_current == 0:
						forward_rotation_speed += plugin_engine.engine_max_force * car.get_meta(&"slip_forward") * delta / wheel.wheel_radius / car.mass
			forward_rotations[wheel_path] += forward_rotation_speed

			if forward_rotations[wheel_path] > 2 * PI:
				forward_rotations[wheel_path] -= 2 * PI
			elif forward_rotations[wheel_path] < 2 * PI:
				forward_rotations[wheel_path] += 2 * PI
			new_transform = new_transform.rotated_local(Vector3.RIGHT, forward_rotations[wheel_path])

			burnout_particles[wheel_path].global_position = wheel.global_position
			if wheel.is_landed:
				if (plugin_engine.gear_current == 0 and forward_rotation_speed != 0.0) or (plugin_engine.gear_current != 0):
					burnout_particles[wheel_path].amount_ratio = car.get_meta(&"slip_total")
				else:
					burnout_particles[wheel_path].amount_ratio = 0.0
			else:
				burnout_particles[wheel_path].amount_ratio = 0.0
			burnout_particles[wheel_path].emitting = burnout_particles[wheel_path].amount_ratio > 0.0

		get_node(wheel_meshes[wheel_path]).transform = new_transform
