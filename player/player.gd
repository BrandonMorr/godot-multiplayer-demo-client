extends KinematicBody

onready var camera = $Camera
onready var graphics = $Graphics
onready var movement_manager = $MovementManager

export var mouse_sensitivity = 0.5

var dead = false

var move_vec: Vector3

puppetsync var puppet_rotation_deg: Vector3

func _ready():
	movement_manager.init(self)


func _process(delta):
	rotation_degrees = puppet_rotation_deg
	
	if is_network_master():
		if Input.is_action_just_pressed("exit"):
			get_tree().quit()
		
		if dead:
			return
		
		move_vec = Vector3()
		
		if Input.is_action_pressed("move_forward"):
			move_vec += Vector3.FORWARD
		if Input.is_action_pressed("move_back"):
			move_vec += Vector3.BACK
		if Input.is_action_pressed("move_left"):
			move_vec += Vector3.LEFT
		if Input.is_action_pressed("move_right"):
			move_vec += Vector3.RIGHT
		
		movement_manager.set_move_vec(move_vec)
		
		if Input.is_action_just_pressed("jump"):
			movement_manager.rpc_unreliable("jump")


func _input(event):
	if is_network_master():
		if event is InputEventMouseMotion:
			rotation_degrees.y -= mouse_sensitivity * event.relative.x
			rset_unreliable("puppet_rotation_deg", rotation_degrees)
			
			camera.rotation_degrees.x -= mouse_sensitivity * event.relative.y
			camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)

func activate():
	if is_network_master():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		camera.current = true
