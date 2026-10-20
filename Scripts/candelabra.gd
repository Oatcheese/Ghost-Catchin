extends Node2D

var anim: AnimatedSprite2D = null
var _interaction_area: Area2D = null
var room_name:String = ""
var candel_name:String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim = get_node_or_null("AnimatedSprite2D")
	_interaction_area = get_node_or_null("InteractionArea")
	room_name = get_parent().name
	candel_name = self.name
	
	anim.play("off")
	
	if _interaction_area:
		_interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		
	if GameManager.candelabras.has(room_name) and GameManager.candelabras[room_name].has(candel_name):
		anim.play("default")
	
func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		anim.play("default")
		_add_candelabra(room_name, candel_name)
		
func _add_candelabra(room: String, candelabra: String):
	if not GameManager.candelabras.has(room):
		GameManager.candelabras[room] = {}
		
	GameManager.candelabras[room][candelabra] = true
	
