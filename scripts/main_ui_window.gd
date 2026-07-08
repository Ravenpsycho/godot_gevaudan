extends Control
class_name MainUI
var players: Array[Node]
var status: VBoxContainer
var logger: ItemList

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	status = self.get_node("status_display")
	logger = status.get_node("log_stream")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func log(log_str:String):
	logger.add_item(log_str)
	logger.select(logger.item_count-1, true)
	logger.ensure_current_is_visible()

func _on_reset_lovers_pressed() -> void:
	players = get_tree().get_nodes_in_group("player_group")
	for p in players:
		p.reset_love()

func _on_reset_mentor_pressed() -> void:
	players = get_tree().get_nodes_in_group("player_group")
	for p:PlayerTile in players:
		p.reset_mentor()

func _on_add_player_button_up() -> void:
	var parent = self.get_parent()
	parent.add_player()
	release_focus()

func _on_reset_powers_pressed() -> void:
	players = get_tree().get_nodes_in_group("player_group")
	for p:PlayerTile in players:
		p.used_power = false
		p.disinfect()
	var main_table = get_tree().get_first_node_in_group("main_table")
	main_table.update_counts()
