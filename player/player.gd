extends KinematicBody

export var mouse_sensitivity = 0.5

onready var camera = $Camera

var dead: bool = false
var speed: int = 10
var velocity: Vector3 = Vector3()

var snap_vector: Vector3
var movement_vector: Vector3

puppet var puppet_dead: bool = false
puppet var puppet_position: Vector3 = Vector3()
puppet var puppet_velocity: Vector3 = Vector3()

func _ready():
	if is_network_master():
		print("me ", str(get_tree().get_network_unique_id()))
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		camera.current = true
	else:
		print("other ", str(get_network_master()))
		var player_id = get_network_master()
		
	# initialize player pisition
	puppet_position = global_transform.origin

func _process(delta):
	if is_network_master():
		if Input.is_action_just_pressed("exit"):
			get_tree().quit()
		
		movement_vector = Vector3()
		
		if Input.is_action_pressed("move_forward"):
			movement_vector += Vector3.FORWARD
		if Input.is_action_pressed("move_back"):
			movement_vector += Vector3.BACK
		if Input.is_action_pressed("move_left"):
			movement_vector += Vector3.LEFT
		if Input.is_action_pressed("move_right"):
			movement_vector += Vector3.RIGHT
		
		snap_vector = Vector3.DOWN
		
		velocity += movement_vector.normalized() * speed * delta
		velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP)
		
		rset_unreliable("puppet_position", global_transform.origin)
		rset_unreliable("puppet_velocity", velocity)
	else:
		# If we are not the ones controlling this player, 
		# sync to last known position and velocity
		global_transform.origin = puppet_position
		velocity = puppet_velocity
	
#	global_transform.origin += velocity * delta
	
	if not is_network_master():
		# It may happen that many frames pass before the controlling player sends
		# their position again. If we don't update puppet_pos to position after moving,
		# we will keep jumping back until controlling player sends next position update.
		# Therefore, we update puppet_pos to minimize jitter problems
		puppet_position = global_transform.origin

func _input(event):
	if is_network_master():
		if event is InputEventMouseMotion:
			rotation_degrees.y -= mouse_sensitivity * event.relative.x
			camera.rotation_degrees.x -= mouse_sensitivity * event.relative.y
			camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
