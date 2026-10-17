extends RigidBody2D

var enemySpeed = 5
var playerPosition
var tooClose
var velocity
var vacc

var being_sucked := false
@export var suck_speed := 200.0
@export var capture_distance := 40.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vacc = get_node("/root/Root/PlayerNode/Player/Vacuum2/Succ")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var enemyDirection
	playerPosition = get_node("/root/Root/PlayerNode/Player").global_position
	var ghost_pos = global_position

	# If the vacuum is sucking this ghost, pull it toward the player.
	if being_sucked and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		enemyDirection = ghost_pos.direction_to(playerPosition)
		apply_impulse(enemyDirection * suck_speed, Vector2(0, 0))
		if ghost_pos.distance_to(playerPosition) < capture_distance:
			capture()
		return
	elif being_sucked:
		# LMB was released before capture.
		being_sucked = false

	if tooClose:
		# Flee directly away from the player.
		enemyDirection = ghost_pos.direction_to(playerPosition) * -1
	else:
		# Chase the player.
		enemyDirection = ghost_pos.direction_to(playerPosition)
	apply_impulse(enemyDirection, Vector2(0, 0))

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var min = Vector2(-400, -400)
	var max = Vector2(400, 400)
	linear_velocity = linear_velocity.clamp(min, max)
	#print(linear_velocity)

func start_being_sucked() -> void:
	being_sucked = true

func stop_being_sucked() -> void:
	being_sucked = false

func capture() -> void:
	GameManager.capture_ghost(1)
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		tooClose = true
	
	if body.get_groups().has("Throwables"):
		body.apply_impulse(playerPosition * 0.5, Vector2(0, 0))

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		tooClose = false
