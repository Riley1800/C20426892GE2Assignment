extends CanvasLayer

# Node References
@onready var cam_controller: CameraController = $"../Player/Camera3D/Camera3D Controller"
@onready var label: Label = $Control/MarginContainer2/Label

# Debug Display Configuration
@export var show_scene_name: bool = true
@export var show_camera_mode: bool = false
@export var update_interval: float = 0.1  # Seconds between updates

var _update_timer: float = 0.0

func _ready():
	# Verify nodes exist
	if not cam_controller:
		push_error("CameraController not found at expected path")
	if not label:
		push_error("Label not found at expected path")
	
	# Initial update
	_update_display()

func _process(delta):
	# Throttle updates for better performance
	_update_timer += delta
	if _update_timer >= update_interval:
		_update_timer = 0.0
		_update_display()

func _update_display():
	var display_text := ""
	
	if show_scene_name and SceneSwitcher:
		display_text += "Scene: %s\n" % SceneSwitcher.current_scene_name
	
	if show_camera_mode and cam_controller:
		# Safer enum conversion
		var mode_name = CameraController.Mode.keys()[cam_controller.mode] if \
					   cam_controller.mode < CameraController.Mode.size() else "UNKNOWN"
		display_text += "Cam: %s\n" % mode_name
	
	if label:
		label.text = display_text
