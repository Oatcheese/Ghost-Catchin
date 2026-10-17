extends RigidBody2D

var enemySpeed = 5
var playerPosition
var tooClose
var velocity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var enemyDirection
	#velocity = get_velocity()
	playerPosition = get_node("/root/Root").get_node("Player").position
	if tooClose:
		enemyDirection = position.direction_to(playerPosition * -1)
	else:
		enemyDirection = position.direction_to(playerPosition)
	apply_impulse(enemyDirection, Vector2(0,0))

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var min = Vector2(-50, -50)
	var max = Vector2(50, 50)
	linear_velocity = linear_velocity.clamp(min, max)
	print(linear_velocity)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		#print("True")
		tooClose = true
	
	if body.get_groups().has("Throwables"):
		body.apply_impulse(playerPosition * .5, Vector2(0,0))

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		#print("False")
		tooClose = false
