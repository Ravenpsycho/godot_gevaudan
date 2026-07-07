extends Node2D
var new_ww
var inst: PlayerTile
var players: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func add_player():
	if not arrival_spot_free():
		return
	var loader = preload("res://scenes/player_tile.tscn")
	var new_player:PlayerTile = loader.instantiate()
	new_player.global_position = Vector2(150, 120)
	new_player.add_to_group("player_group")
	self.add_child(new_player, true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func arrival_spot_free():
	return !self.get_node("arrival_spot").has_overlapping_areas()
