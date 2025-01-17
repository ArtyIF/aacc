@icon("res://addons/aacc/icons/car_wheel.svg")
class_name CarWheel extends Node3D

@export_group("Shape")
## The radius of the wheel. Half of the wheel's size.
@export var wheel_radius: float = 0.3
## The width of the wheel.
##
## AACC's wheels currently use 2 raycasts for the wheels.
@export var wheel_width: float = 0.3
# TODO: document
@export_flags_3d_physics var collision_mask: int = 1

@export_group("Suspension")
## The maximum length of the suspension.
##
## If the suspension length gets exceeded (because of the
## [member buffer_radius]), the suspension starts working in reverse, pulling
## the car to the ground instead of pushing it away from it. This can be useful
## to make the car stick to the ground better.
@export var suspension_length: float = 0.1
## The spring force the suspension applies.
@export var suspension_spring: float = 3000.0
## The damper applied to the spring force the suspension applies so it wasn't
## too springy and out of control.
@export var suspension_damper: float = 300.0

# TODO: document
@export_group("Visuals")
@export var visual_node: Node3D
@export_range(-1, 1) var steer_multiplier: float = 0.0
@export var limit_top: bool = false
@export var skid_trail: TrailRenderer
@export var burnout_particles: GPUParticles3D
@export var freeze_on_handbrake: bool = false
@export var block_wheelspin: bool = false

#== NODES ==#
var raycast_instance_1: RayCast3D
var raycast_instance_2: RayCast3D
var car: Car

#== COMPRESSION ==#
var compression: float = 0.0
var last_compression: float = 0.0
var last_compression_set: bool = false

#== VISUALS ==#
var initial_visual_node_transform: Transform3D
var current_forward_spin: float = 0.0

#== EXTERNAL ==#
var is_colliding: bool = false
var collision_point: Vector3 = Vector3.ZERO
var collision_normal: Vector3 = Vector3.ZERO
var distance: float = 0.0

func _ready() -> void:
	# TODO: use ShapeCast3D instead
	raycast_instance_1 = RayCast3D.new()
	add_child(raycast_instance_1)
	raycast_instance_2 = RayCast3D.new()
	add_child(raycast_instance_2)
	configure_raycasts()

	car = get_parent() as Car
	if visual_node:
		initial_visual_node_transform = visual_node.transform
	
	# The wheels don't need much from the car for physics stuff, but the car
	# does need stuff from the wheels for the physics stuff. It makes sense
	# to make the wheels execute slightly before the car.
	process_physics_priority = -1

func reset() -> void:
	#== COMPRESSION ==#
	compression = 0.0
	last_compression = 0.0
	last_compression_set = false

	#== VISUALS ==#
	current_forward_spin = 0.0

	#== EXTERNAL ==#
	is_colliding = false
	collision_point = Vector3.ZERO
	collision_normal = Vector3.ZERO
	distance = 0.0

func configure_raycasts() -> void:
	raycast_instance_1.target_position = (Vector3.DOWN * (wheel_radius + suspension_length))
	raycast_instance_1.enabled = true
	raycast_instance_1.hit_from_inside = false
	raycast_instance_1.hit_back_faces = false
	raycast_instance_1.collision_mask = collision_mask
	raycast_instance_1.process_physics_priority = -1000
	raycast_instance_1.position = Vector3.RIGHT * wheel_width

	raycast_instance_2.target_position = (Vector3.DOWN * (wheel_radius + suspension_length))
	raycast_instance_2.enabled = true
	raycast_instance_2.hit_from_inside = false
	raycast_instance_2.hit_back_faces = false
	raycast_instance_1.collision_mask = collision_mask
	raycast_instance_2.process_physics_priority = -1000

func set_raycast_values() -> void:
	# TODO: apply forces per raycast
	var collision_point_1: Vector3 = raycast_instance_1.get_collision_point()
	var collision_normal_1: Vector3 = raycast_instance_1.get_collision_normal()
	var distance_1: float = raycast_instance_1.global_position.distance_to(collision_point_1)

	var collision_point_2: Vector3 = raycast_instance_2.get_collision_point()
	var collision_normal_2: Vector3 = raycast_instance_2.get_collision_normal()
	var distance_2: float = raycast_instance_2.global_position.distance_to(collision_point_2)

	if raycast_instance_1.is_colliding() and raycast_instance_2.is_colliding():
		collision_point = (collision_point_1 + collision_point_2) / 2.0
		collision_normal = (collision_normal_1 + collision_normal_2).normalized()
		distance = lerp(distance_1, distance_2, 0.5)
	elif raycast_instance_1.is_colliding():
		collision_point = collision_point_1
		collision_normal = collision_normal_1
		distance = distance_1
	elif raycast_instance_2.is_colliding():
		collision_point = collision_point_2
		collision_normal = collision_normal_2
		distance = distance_2

func update_visuals(delta: float) -> void:
	if !visual_node: return

	var new_transform: Transform3D = initial_visual_node_transform

	var suspension_translation: Vector3 = suspension_length * Vector3.DOWN
	if is_colliding:
		var compression_translation = 1.0 - compression
		if limit_top:
			compression_translation = max(0.0, compression_translation)
		suspension_translation *= compression_translation

	var steer_rotation: float = -car.smooth_steer.get_current_value() * car.base_steer_velocity * steer_multiplier
	
	if not (freeze_on_handbrake and car.input_handbrake):
		if is_colliding: # TODO: smooth it out
			current_forward_spin -= car.local_linear_velocity.z * delta / wheel_radius
			if (not block_wheelspin) and car.local_linear_velocity.length() < 0.25:
				# BUG: when wheelspinning backwards the wheel spins forward after
				# letting go of the throttle
				current_forward_spin += (car.max_acceleration * delta * (1.0 if car.current_gear >= 0 else -1.0) * car.burnout_amount) / (car.mass * wheel_radius)

	if current_forward_spin > 2 * PI:
		current_forward_spin -= 2 * PI
	elif current_forward_spin < 2 * PI:
		current_forward_spin += 2 * PI

	var forward_spin: float = current_forward_spin

	new_transform = new_transform.translated_local(suspension_translation)
	new_transform = new_transform.rotated_local(Vector3.UP, steer_rotation)
	new_transform = new_transform.rotated_local(Vector3.RIGHT, forward_spin)

	visual_node.transform = new_transform

func update_burnout() -> void:
	if not is_colliding or car.freeze:
		skid_trail.is_emitting = false
		burnout_particles.amount_ratio = 0.0
		burnout_particles.emitting = false
		return

	var burnout_amount: float = car.burnout_amount
	if car.local_linear_velocity.length() < 0.25:
		if (freeze_on_handbrake and car.input_handbrake) or block_wheelspin:
			burnout_amount = 0.0

	if skid_trail:
		skid_trail.is_emitting = burnout_amount > 0.0
		skid_trail.global_position = collision_point + (collision_normal * 0.01)
		skid_trail.global_basis = skid_trail.global_basis.looking_at(-(collision_normal).cross(car.global_basis.z), car.global_basis.z)

	if burnout_particles:
		burnout_particles.amount_ratio = burnout_amount
		burnout_particles.emitting = burnout_particles.amount_ratio > 0 # to fix the random emissions
		burnout_particles.global_position = collision_point

func _physics_process(delta: float) -> void:
	if raycast_instance_1.is_colliding() or raycast_instance_2.is_colliding():
		is_colliding = true
		set_raycast_values()

		compression = 1.0 - ((distance - wheel_radius) / suspension_length)
		compression = clamp(compression, 0.0, 1.0)
		if not last_compression_set:
			last_compression = compression
			last_compression_set = true

		var suspension_magnitude: float = 0.0
		suspension_magnitude += compression * suspension_spring

		var compression_delta: float = (compression - last_compression) / delta
		suspension_magnitude += compression_delta * suspension_damper
		last_compression = compression

		suspension_magnitude *= collision_normal.dot(global_basis.y)
		
		if not car.do_not_apply_forces and not car.freeze:
			car.apply_force(collision_normal * suspension_magnitude, collision_point - car.global_position)
	else:
		is_colliding = false
		last_compression = 0.0

	update_visuals(delta)
	update_burnout()
