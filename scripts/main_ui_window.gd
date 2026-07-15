extends Control
class_name MainUI
var players: Array[Node]
var status: VBoxContainer
var logger: ItemList
var prog: Label
var main_table: MainTable
var UI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	status = $status_display
	logger = $status_display/log_stream
	prog = $status_display/progress_status
	main_table = get_tree().get_first_node_in_group("main_table")
	UI = main_table.get_node("main_UI")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func log(log_str:String):
	logger.add_item(log_str)
	logger.select(logger.item_count-1, true)
	logger.ensure_current_is_visible()

func _on_reset_lovers_pressed() -> void:
	update_players()
	for p in players:
		p.reset_love()

func _on_reset_mentor_pressed() -> void:
	update_players()
	for p:PlayerTile in players:
		p.reset_mentor()

func _on_add_player_button_up() -> void:
	var parent = self.get_parent()
	parent.add_player()
	release_focus()

func _on_reset_powers_pressed() -> void:
	update_players()
	for p:PlayerTile in players:
		p.used_power = false
		p.disinfect()
	main_table.update_counts()
	
func count_villagers() -> String:
	var live_v: int = 0
	var total_v: int = 0
	for p: PlayerTile in players:
		if !p.is_wherewolf:
			if p.alive:
				live_v += 1
			total_v += 1
	if live_v == 0:
		var vic = "Les villageois sont morts! Victoire de la meute!"
		UI.log(vic)
		return vic
	return "villageois: %s / %s" % [live_v, total_v]

func count_ww() -> String:
	var live_ww: int = 0
	var total_ww: int = 0
	for p: PlayerTile in players:
		if p.is_wherewolf:
			if p.alive:
				live_ww += 1
			total_ww += 1
	if live_ww == 0:
		var vic = "La meute est morte! Le village gagne!"
		UI.log(vic)
		return vic
	return "meute: %s / %s" % [live_ww, total_ww]

func count_charmed() -> String:
	var live_p: int = 0
	var charmed: int = 0
	for p: PlayerTile in players:
		if p.alive:
			live_p += 1
			if p.flute_overlay == true:
				charmed += 1
	if charmed == live_p - 1:
		var vic = "Le village est sous le charme!\nVictoire du Joueur de Flûte!"
		UI.log(vic)
		return vic
	return "Charmés: %s / %s" % [charmed, live_p-1]

func killer(killer_name: String) -> String:
	var live_p: int = 0
	for p: PlayerTile in players:
		if p.alive:
			live_p += 1
	if live_p == 1:
		var vic = "Un seul survivant! %s gagne!" % killer_name
		UI.log(vic)
		return vic
	return "%s: %s / 1" % [killer_name, live_p]
	
	
func update_progress():
	update_players()
	var villagers_line = count_villagers()
	var ww_line = count_ww()
	prog.text = "%s \n %s" % [villagers_line, ww_line]
	if main_table.check_role("Assassin"):
		prog.text+="\n%s" % killer("Assassin")
	if main_table.check_role("Loup Garou Blanc"):
		prog.text+="\n%s" % killer("Loup Garou Blanc")
	if main_table.check_role("Joueur de flûte"):
		prog.text+="\n%s" % count_charmed()
	
func update_players():
	players = get_tree().get_nodes_in_group("player_group")
