extends Node2D
var new_ww
var inst: PlayerTile
var players: Array[Node]
var live_villagers
var live_wherewolves

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
	
func update_counts(verbose:bool = false):
	players = get_tree().get_nodes_in_group("player_group")
	var villagers = 0
	var ww = 0
	for p:PlayerTile in players:
		if p.is_wherewolf and p.alive:
			ww += 1
		elif p.alive:
			villagers += 1
	if verbose:
		print([villagers, ww])
	live_villagers = villagers
	live_wherewolves = ww
	return [villagers, ww]
