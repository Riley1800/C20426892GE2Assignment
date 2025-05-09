extends CharacterBody3D

@export var max_speed: float = 2.0  # Maximum normal speed
@export var flee_range: float = 15.0  # Flee range when a predator is too close
@export var flee_speed_multiplier: float = 2.0  # Speed multiplier for fleeing
@export var wander_radius: float = 2.0  # Wander radius when no predators are near

var predator_nodes: Array = []  # Array to store predator nodes (Birds)

var _velocity: Vector3 = Vector3.ZERO
var _wander_angle: float = 0.0

func _ready():
	# Dynamically find all bird nodes (predators) in the HuntingScene
	find_predators()

# Dynamically find all instances of birds in the HuntingScene
func find_predators():
	var hunting_scene = get_tree().root.get_node("HuntingScene")  # Get the current scene, assuming it's the HuntingScene
	for node in hunting_scene.get_children():
		if node.name.begins_with("Bird"):  # This will check for "Bird", "Bird2", "Bird3", etc.
			print("Found predator node: ", node.name)  # Debugging line
			predator_nodes.append(node)

	# Debugging: Check how many birds were found
	print("Predator nodes after search: ", predator_nodes.size(), " found.")

func _process(delta):
	# Default behavior: Wander if no predators are nearby
	var steering: Vector3 = wander(delta)
	
	# Check if any predator is within flee range
	var closest_predator = get_closest_predator()
	if closest_predator:
		# If a predator is close, flee from it
		print("Fleeing from predator at position: ", closest_predator.global_position)  # Debugging line
		steering = flee(closest_predator.global_position)
	
	# Apply the steering force and limit it by max_speed
	_velocity += steering * delta
	
	# Limit the velocity to the maximum speed
	_velocity = _velocity.limit_length(max_speed)
	
	# Apply movement using move_and_slide (built-in method)
	velocity = _velocity  # Use the calculated velocity
	move_and_slide()

	# Check if velocity is effectively zero to exit the simulation
	if _velocity.length() < 0.01:  # If the velocity length is very small (effectively zero)
		print("Velocity is zero, exiting simulation.")
		get_tree().quit()  # This will stop the simulation

# Flee behavior to move away from the predator
func flee(target_position: Vector3) -> Vector3:
	# Calculate desired fleeing velocity using the current predator position
	var desired_velocity = (global_position - target_position).normalized() * max_speed * flee_speed_multiplier
	
	# Debugging line to ensure we're fleeing with the correct velocity
	print("Fleeing with desired velocity: ", desired_velocity)
	
	# Apply a limit to the velocity even while fleeing to avoid going too fast
	desired_velocity = desired_velocity.limit_length(max_speed * flee_speed_multiplier)
	
	return (desired_velocity - _velocity).normalized()

# Wander behavior to move randomly when no predators are nearby
func wander(delta: float) -> Vector3:
	_wander_angle += randf_range(-0.5, 0.5) * delta * 10.0  # Adjust wander angle
	var circle_pos = _velocity.normalized() * wander_radius
	var displacement = Vector3(cos(_wander_angle), 0, sin(_wander_angle))
	var desired = (circle_pos + displacement).normalized() * max_speed
	return (desired - _velocity).normalized()

# Get the closest predator in range
func get_closest_predator() -> Node3D:
	var closest_predator: Node3D = null
	var closest_distance := flee_range  # Default distance to check is the flee range
	
	# Iterate over all predators and check distance
	for predator in predator_nodes:
		if predator:
			# Always use the current position of the predator
			var dist = global_position.distance_to(predator.global_position)
			print("Checking predator at position: ", predator.global_position, " Distance: ", dist)  # Debugging line
			if dist < closest_distance:
				closest_predator = predator
				closest_distance = dist
	
	return closest_predator
