extends RigidBody2D

var enemySpeed = 5
var playerPosition
var tooClose

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var enemyDirection
	playerPosition = get_parent().get_node("Player").position
	if tooClose:
		enemyDirection = position.direction_to(playerPosition * -1)
	else:
		enemyDirection = position.direction_to(playerPosition)
	apply_impulse(enemyDirection, Vector2(0,0))

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		#print("True")
		tooClose = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		#print("False")
		tooClose = false
