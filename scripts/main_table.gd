extends Node2D

class_name MainTable

var new_ww
var inst: PlayerTile
var players: Array[Node]
var live_villagers
var live_wherewolves
var game_params: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pl = preload("res://scenes/initial_menu.tscn")
	var init_menu = pl.instantiate()
	self.add_child(init_menu)
	
	
func setup_table_for(n:int):
	var ww_n = int(n/3)
	var drop_pos: Vector2 = get_node("drop_spot").position
	var loader = preload("res://scenes/player_tile.tscn")
	var drop_incerment : int = int(22/n) 
	var drop_name: String = "drop_spot"
	var drop_n: int = 1
	for i in range(0,n):
		if i > 0:
			drop_pos = get_node("drop_spot%s"%drop_n).position
		var p:PlayerTile = loader.instantiate()
		p.global_position = drop_pos
		p.add_to_group("player_group")
		self.add_child(p)
		if i < ww_n:
			p.set_role("Loup Garou")
		else:
			p.set_role("Simple Villageois")
		p.set_player_name("Perso_%s"%i)
		drop_n += drop_incerment
		
	
func add_player():
	if not arrival_spot_free():
		return
	var loader = preload("res://scenes/player_tile.tscn")
	var new_player:PlayerTile = loader.instantiate()
	new_player.global_position = Vector2(150,120)
	new_player.add_to_group("player_group")
	self.add_child(new_player, true)
	new_player.call_name_changer()
	
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
