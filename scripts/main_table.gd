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
	"dn_count": 1,
	"last_protected": ""
}
var growl: Sprite2D

const NUMBER_OF_DROP_SPOTS = 22

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UI = $main_UI
	growl = $growling_bear
	show_initial_menu()
	
func show_initial_menu(with_names:Array = []):
	var pl = preload("res://scenes/initial_menu.tscn")
	var init_menu = pl.instantiate()
	if len(with_names)>0:
		init_menu.preset_names(with_names)
	self.add_child(init_menu)

func next_phase():
	if game_params["day_night"] == "Nuit":
		game_params["day_night"] = "Jour"
		morning_routine()
		$night_overlay.visible = false
		$sun_sprite.visible = true
		update_dn_display()
	else:
		game_params["day_night"] = "Nuit"
		game_params["dn_count"] += 1
		night_routine()
		$night_overlay.visible = true
		$sun_sprite.visible = false
		update_dn_display()

func morning_routine():
	reset_overlay_for_all("voted_ww")
	if check_role("Montreur d'Ours"):
		var mo = get_player_with_role("Montreur d'Ours")
		if neighbor_is_wherewolf(mo) and mo.alive:
			growl.visible = true
	if check_role("Salvateur"):
		reset_overlay_for_all("protected_overlay")
		UI.log("La protection du Salvateur\nne fait plus effet!")
	establish_day_text()

func night_routine():
	reset_overlay_for_all("voted_village")
	growl.visible = false
	if check_role("Chevalier à l'épée Rouillée"):
		kill_player_with_tetanos()
	establish_night_text()

func kill_player_with_tetanos():
	players = get_tree().get_nodes_in_group("player_group")
	for p: PlayerTile in players:
		if p.tetanos_overlay:
			p.die()

func establish_night_text():
	var forced: Array = []
	var total_text: String = ""
	var counter: int = 0
	var night_num: int = game_params["dn_count"]
	var to_call:Array
	if night_num == 1:
		to_call = GMSpeech.FIRST_NIGHT_CALL
	elif night_num % 2 == 0:
		to_call = GMSpeech.EVEN_NIGHT_CALL
	else:
		to_call = GMSpeech.ODD_NIGHT_CALL
	if check_role("Cupidon Amoureux"):
		forced.append("Amoureux")
	for r in to_call:
		if check_role(r) or r in forced:
			if r in forced:
				total_text += r
				total_text += " >> "
				counter += 1
				if counter > 1:
					counter = 0
					total_text += "\n"
				continue
			var p = get_player_with_role(r)
			if p.alive:
				if r == "Joueur de Flûte":
					forced.append("Charmés")
				total_text += r
				total_text += " >> "
				counter += 1
				if counter > 1:
					counter = 0
					total_text += "\n"
	total_text = total_text.substr(0, len(total_text)-4)
	$role_calling_list.text = total_text

func establish_day_text():
	$role_calling_list.text = "Morts de la nuit >>\nLe Village Va délibérer."

func prev_phase():
	if game_params["day_night"] == "Nuit":
		game_params["day_night"] = "Jour"
		game_params["dn_count"] -= 1
		set_day()
		morning_routine()
		update_dn_display()
	else:
		game_params["day_night"] = "Nuit"
		set_night()
		night_routine()
		update_dn_display()
		
func set_day():
	$night_overlay.visible = false
	$sun_sprite.visible = true

func set_night():
	$night_overlay.visible = true
	$sun_sprite.visible = false

func update_dn_display():
	UI.log("---%s %s---" % [game_params["day_night"], int(game_params["dn_count"])])
	$dn_label.text = "%s %s" % [game_params["day_night"], int(game_params["dn_count"])]
	if game_params["day_night"] == "Nuit":
		set_night()
	else:
		set_day()
	if game_params["day_night"] == "Nuit" and game_params["dn_count"] == 1:
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
	$shuffle_roles.visible = false
	$next_phase.visible = true
	night_routine()

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

func shuffle_roles():
	var roles: Array = []
	players = get_tree().get_nodes_in_group("player_group")
	for p in players:
		roles.append(p.role)
	roles.shuffle()
	for i in range(0, len(players)):
		players[i].set_role(roles[i])

func setup_table_for(names:Array):
	players = get_tree().get_nodes_in_group("player_group")
	for p in players:
		p.queue_free()
	var base_roles: Array = Array(PlayerTile.BASE_VILLAGER_ROLES.duplicate())
	var n = len(names)
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
			var next_base = base_roles.pop_front()
			if next_base:
				p.set_role(next_base, false)
			else:
				p.set_role("Simple Villageois", false)
		p.set_player_name(names[i])
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

func check_role(r:String):
	players = get_tree().get_nodes_in_group("player_group")
	for p in players:
		if p.role == r:
			return true
	return false
	
func check_overlay(o:String, only_alive:bool=true):
	players = get_tree().get_nodes_in_group("player_group")
	var cond1:bool
	for p in players:
		if only_alive:
			cond1 = p.alive
		else:
			cond1 = true
		if cond1 and p.get(o):
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

func save():
	var savedict = {
		"filename" : "MAIN_TABLE",
		"game_params": game_params
	}
	return savedict


func _on_next_phase_pressed() -> void:
	save_game()
	next_phase()

func _on_prev_phase_pressed() -> void:
	prev_phase()

func _on_start_game_pressed() -> void:
	start_game()

func _on_shuffle_roles_pressed() -> void:
	shuffle_roles()

func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("save_group")
	for node in save_nodes:
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		var node_data = node.call("save")
		var json_string = JSON.stringify(node_data)

		save_file.store_line(json_string)

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	var save_nodes = get_tree().get_nodes_in_group("save_group")
	for i in save_nodes:
		if i.get_groups().has("player_group"):
			i.queue_free()
			UI.update_players()
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var node_data = json.data
		if node_data["filename"] == "MAIN_TABLE":
			game_params = node_data["game_params"]
			update_dn_display()
			continue
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		const SKIP_LOAD: Array = [
			"filename", "parent", "pos_x", "pos_y"
		]
		for i in node_data.keys():
			if i in SKIP_LOAD:
				continue
			new_object.set(i, node_data[i])
		if new_object.has_method("post_load_routine"):
			new_object.post_load_routine()
	get_tree()
