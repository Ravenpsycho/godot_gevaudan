extends Control
var players: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


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
	await get_tree().process_frame
