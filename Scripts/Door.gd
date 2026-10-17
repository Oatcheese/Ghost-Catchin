extends Area2D

@export var next_room_scene: PackedScene
@export var spawn_marker_name: String = "SpawnPoint"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.room_change_requested.emit(next_room_scene, spawn_marker_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
