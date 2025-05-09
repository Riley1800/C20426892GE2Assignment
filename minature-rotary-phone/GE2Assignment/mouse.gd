extends CharacterBody3D

# Movement settings
@export var max_speed := 1.0
@export var max_force := 0.3
@export var wander_radius := 2.0

# Array of predators
var predator_nodes : Array = []

# Current velocity and wander angle
var _velocity := Vector3(0, 0, -1) * max_speed
var _wander_angle := 10.0

# The distance at which the mouse will flee
@export var flee_range := 5.0

# Flee speed multiplier
@export var flee_speed_multiplier := 20.0

func _ready() -> void:
	# Dynamically find all bird nodes (predators) in the scene
	var bird_nodes = get_tree().get_nodes_in_group("birds")  # Assuming birds are added to the "birds" group
	predator_nodes = bird_nodes
	
	# Debugging: Print the number of predators found
	print("Found ", predator_nodes.size(), " predators.")

func _physics_process(delta: float) -> void:
	# Default movement is wandering, unless we need to flee
	var steering := wander(delta)  # Wander if no predator is nearby

	# Check if any predator is within flee range
	var closest_predator : Node3D = get_closest_predator()
	if closest_predator:
		# Flee from the closest predator
		print("Fleeing from predator at position: ", closest_predator.global_position)  # Debugging line
		steering = flee(closest_predator.global_position)
	
	# Apply the steering force and limit it by max_force
	steering = steering.limit_length(max_force)
	_velocity = (_velocity + steering).limit_length(max_speed)
	
	# Move and animate
	velocity = _velocity  # Assign to CharacterBody3D's built-in velocity
	move_and_slide()
	_rotate_to_velocity(delta)

# --- BEHAVIORS ---
# Flee from the closest predator
func flee(target_pos: Vector3) -> Vector3:
	# Apply a stronger flee speed multiplier for faster fleeing
	var desired = (global_position - target_pos).normalized() * max_speed * flee_speed_multiplier
	print("Fleeing with desired velocity: ", desired)  # Debugging line to ensure it's getting multiplied correctly
	return (desired - _velocity).normalized()

# Wander randomly if no predators are in range
func wander(delta: float) -> Vector3:
	_wander_angle += randf_range(-0.5, 0.5) * delta * 10.0
	var circle_pos = _velocity.normalized() * wander_radius
	var displacement = Vector3(cos(_wander_angle), 0, sin(_wander_angle))
	var desired = (circle_pos + displacement).normalized() * max_speed
	return (desired - _velocity).normalized()

# --- ANIMATION/ROTATION ---
# Rotate to face the direction of movement
func _rotate_to_velocity(delta: float) -> void:
	if _velocity.length() > 0.1:
		# Face direction of movement
		rotation.y = lerp_angle(rotation.y, atan2(_velocity.x, -_velocity.z), delta * 5.0)
		rotation.z = lerp(rotation.z, _velocity.x * 0.05, delta * 3.0)

# Get the closest predator in range
func get_closest_predator() -> Node3D:
	var closest_predator : Node3D = null
	var closest_distance := flee_range  # Default distance to check is the flee range
	
	# Iterate over all predators and check distance
	for predator in predator_nodes:
		if predator:
			var dist = global_position.distance_to(predator.global_position)
			print("Checking predator at position: ", predator.global_position, " Distance: ", dist)  # Debugging line
			if dist < closest_distance:
				closest_predator = predator
				closest_distance = dist
	
	return closest_predator
