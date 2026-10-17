extends Node

signal ghost_captured(amount: int)
signal player_damaged(amount: int)
signal room_change_requested(next_scene: PackedScene, spawn_marker: String)
signal game_over()

var score := 0
var ghosts_captured := 0
var player_health := 3
var max_health := 3
var current_room_name := ""

func capture_ghost(amount: int = 1) -> void:
	ghosts_captured += amount
	score += amount * 100
	ghost_captured.emit(amount)

func damage_player(amount: int = 1) -> void:
	player_health -= amount
	player_damaged.emit(amount)
	if player_health <= 0:
		game_over.emit()

func heal(amount: int = 1) -> void:
	player_health = clamp(player_health + amount, 0, max_health)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
