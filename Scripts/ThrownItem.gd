extends RigidBody2D

@export var sprites: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sprite = randi_range(0, sprites.size() - 1)
	get_node("Sprite2D").texture = sprites[sprite]
	get_node("Sprite2D").scale *= 4


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(linear_velocity == Vector2(0, 0)):
		get_node("CollisionShape2D").disabled = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "Damage Collisions":
		if (linear_velocity.x * -1 > 20 || linear_velocity.y * -1 > 20):
			GameManager.damage_player(1)
