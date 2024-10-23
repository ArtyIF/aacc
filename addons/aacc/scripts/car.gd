## The AACC car class.
##
## This is the main class that stores and applies all the needed forces and
## torques set by the child plugins.
@icon("res://addons/aacc/icons/car.svg")
class_name AACCCar extends RigidBody3D

## The force inner class. Stores the force, its position, and whether or not
## it's an impulse.
class Force:
	## The force.
	var force: Vector3
	## The force's position.
	var position: Vector3
	## If [code]true[/code], the force is applied as an impulse
	## (i.e. time-independent). Else, it's applied normally.
	var is_impulse: bool
	
	## Creates a new force with required [param force] and optional
	## [param position] and [param is_impulse] parameters. See [member force],
	## [member position] and [member is_impulse].
	func _init(force: Vector3, position: Vector3 = Vector3.ZERO, is_impulse: bool = false):
		self.force = force
		self.position = position
		self.is_impulse = is_impulse

## The torque inner class. Stores the torque and whether or not it's an impulse.
class Torque:
	## The torque.
	var torque: Vector3
	## If [code]true[/code], the torque is applied as an impulse
	## (i.e. time-independent). Else, it's applied normally.
	var is_impulse: bool

	## Creates a new torque with required [param torque] and optional
	## [param is_impulse] parameters. See [member torque] and
	## [member is_impulse].
	func _init(torque: Vector3, is_impulse: bool = false):
		self.torque = torque
		self.is_impulse = is_impulse

## An array containing all forces to be applied the next physics tick.
var forces_to_apply: Array[Force] = []
## An array containing all torques to be applied the next physics tick.
var torques_to_apply: Array[Torque] = []
# TODO: add force limiters somehow

## A transformed linear velocity of a car.
var local_linear_velocity: Vector3 = Vector3()
## A transformed angular velocity of a car.
var local_angular_velocity: Vector3 = Vector3()

## Adds a new force to apply. See [class Car.Force] for details.
func add_force(force: Vector3, position: Vector3 = Vector3.ZERO, is_impulse: bool = false):
	forces_to_apply.append(Force.new(force, position, is_impulse))

## Adds a new torque to apply. See [class Car.Torque] for details.
func add_torque(torque: Vector3, is_impulse: bool = false):
	torques_to_apply.append(Torque.new(torque, is_impulse))

# TODO: check if this causes a one-frame lag
func _physics_process(delta: float) -> void:
	local_linear_velocity = global_transform.basis.inverse() * linear_velocity
	local_angular_velocity = global_transform.basis.inverse() * angular_velocity
	
	for force in forces_to_apply:
		if force.is_impulse:
			apply_impulse(force.force, force.position)
		else:
			apply_force(force.force, force.position)
	forces_to_apply.clear()
	
	for torque in torques_to_apply:
		if torque.is_impulse:
			apply_torque_impulse(torque.torque)
		else:
			apply_torque(torque.torque)
	torques_to_apply.clear()
