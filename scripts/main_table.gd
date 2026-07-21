extends Node2D

class_name MainTable

var new_ww
var UI: MainUI
var inst: PlayerTile
var players: Array[Node]
var live_villagers
var live_wherewolves
var game_params: Dictionary = {
	"day_night": "Nuit",
	"count": 1,
	"last_protected": ""
}

const NUMBER_OF_DROP_SPOTS = 22

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pl = preload("res://scenes/initial_menu.tscn")
	var init_menu = pl.instantiate()
	self.add_child(init_menu)
	UI = $main_UI
	
func next_phase():
	if game_params["day_night"] == "Nuit":
		game_params["day_night"] = "Jour"
		morning_routine()
		$night_overlay.visible = false
		$sun_sprite.visible = true
		update_dn_display()
	else:
		game_params["day_night"] = "Nuit"
		game_params["count"] += 1
		night_routine()
		$night_overlay.visible = true
		$sun_sprite.visible = false
		update_dn_display()

func morning_routine():
	reset_overlay_for_all("voted_ww")
	if check_role("Salvateur"):
		reset_overlay_for_all("protected_overlay")
		UI.log("La protection du Salvateur\nne fait plus effet!")

func night_routine():
	reset_overlay_for_all("voted_village")
	if check_role("Chevalier à l'épée Rouillée"):
		kill_player_with_tetanos()
	establish_night_text()
		
func kill_player_with_tetanos():
	players = get_tree().get_nodes_in_group("player_group")
	for p: PlayerTile in players:
		if p.tetanos_overlay:
			p.die()

func establish_night_text():
	pass

func prev_phase():
	if game_params["day_night"] == "Nuit":
		game_params["day_night"] = "Jour"
		game_params["count"] -= 1
		$night_overlay.visible = false
		$sun_sprite.visible = true
		update_dn_display()
	else:
		game_params["day_night"] = "Nuit"
		$night_overlay.visible = true
		$sun_sprite.visible = false
		update_dn_display()

		
func update_dn_display():
	UI.log("---%s %s---" % [game_params["day_night"], game_params["count"]])
	$dn_label.text = "%s %s" % [game_params["day_night"], game_params["count"]]
	if game_params["day_night"] == "Nuit" and game_params["count"] == 1:
		$prev_phase.visible = false
	else:
		$prev_phase.visible = true
	
	
func start_game():
	var td = Time.get_datetime_dict_from_system()
	game_params["game_start"] = td
	var y = td.year
	var m = td.month
	var d = td.day
	var h = td.hour
	var minutes = td.minute
	var savename = "gevaudan_save_%s_%s_%s_%s:%s" % [y,m,d,h,minutes]
	game_params["savename"] = savename
	UI.log("Game starts at: %s:%s" % [h, minutes])
	update_dn_display()
	$start_game.visible = false
	$next_phase.visible = true
	
func get_live_player_order() -> Array:
	var ds_name:String
	var ds: Area2D
	var p:PlayerTile
	var overlaps: Array
	var order: Array = []
	for i in range(1, NUMBER_OF_DROP_SPOTS+1):
		ds_name = "drop_spot%s"%i
		ds = get_node(ds_name)
		overlaps = ds.get_overlapping_areas()
		if len(overlaps) > 0:
			p = overlaps[0].get_parent()
			if p.alive:
				order.append(p)
	return order
		
func get_neighbors(p: PlayerTile):
	var live_players = get_live_player_order()
	var left: PlayerTile = live_players[0]
	var cursor: PlayerTile = live_players[0]
	var right: PlayerTile = live_players[0]
	
	for i in range(0, len(live_players)):
		cursor = live_players[i]
		if i == 0:
			left = live_players[len(live_players)-1]
		else:
			left = live_players[i-1]
		if i == len(live_players)-1:
			right = live_players[0]
		else:
			right = live_players[i+1]
		if cursor == p:
			return [left, right]
	return [] 
	
func neighbor_is_wherewolf(p: PlayerTile):
	if p.is_wherewolf:
		return true
	for player: PlayerTile in get_neighbors(p):
		if player.is_wherewolf:
			return true
	return false
	
func setup_table_for(n:int):
	@warning_ignore("integer_division")
	var ww_n = int(n/3)
	var loader = preload("res://scenes/player_tile.tscn")
	@warning_ignore("unused_variable")
	var drop_name: String = "drop_spot"
	var drop_pos: Vector2
	for i in range(0,n):
		drop_pos = get_node("drop_spot%s"% (i+1)).position
		var p:PlayerTile = loader.instantiate()
		p.global_position = drop_pos
		p.add_to_group("player_group")
		self.add_child(p)
		if i < ww_n:
			p.set_role("Loup Garou", false)
		else:
			p.set_role("Simple Villageois", false)
		p.set_player_name("Perso_%s"%i)
	UI.update_progress()
		
	
func add_player():
	if not arrival_spot_free():
		return
	var loader = preload("res://scenes/player_tile.tscn")
	var new_player:PlayerTile = loader.instantiate()
	new_player.global_position = Vector2(150,120)
	new_player.add_to_group("player_group")
	self.add_child(new_player, true)
	new_player.call_name_changer()
	UI.update_progress()
	
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
	
func check_role(r:String):
	players = get_tree().get_nodes_in_group("player_group")
	for p in players:
		if p.role == r:
			return true
	return false
	
func get_player_with_role(r:String) -> PlayerTile:
	players = get_tree().get_nodes_in_group("player_group")
	var found: PlayerTile
	for p in players:
		if p.role == r:
			found = p
			return p
	assert(found is PlayerTile)
	return PlayerTile.new()
	
func reset_overlay_for_all(overlay_name:String):
	players = get_tree().get_nodes_in_group("player_group")
	for p in players:
		p.set(overlay_name, false)
		p.update_overlays()

func _on_next_phase_pressed() -> void:
	next_phase()


func _on_prev_phase_pressed() -> void:
	prev_phase()


func _on_start_game_pressed() -> void:
	start_game()
