extends Node
class_name CameraManager

@export var default_camera : Camera3D
var current_camera : Camera3D
var registered_birds := []

func _ready():
	if default_camera:
		switch_to_camera(default_camera)

func register_bird(bird: Node3D):
	var cam = bird.get_node("Camera3D")
	if cam:
		registered_birds.append(bird)
		print("Registered bird: ", bird.name)
	else:
		printerr("No Camera3D found in ", bird.name)

func switch_to_bird(bird: Node3D):
	var cam = bird.get_node("Camera3D")
	if cam:
		switch_to_camera(cam)

func switch_to_camera(cam: Camera3D):
	if current_camera:
		current_camera.current = false
	cam.current = true
	current_camera = cam
