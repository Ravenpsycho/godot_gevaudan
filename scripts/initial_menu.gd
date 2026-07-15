extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	if !$initial_window/container/MJ_input or !$initial_window/container/n_players_input:
		return 
	var main_table: MainTable = get_tree().get_first_node_in_group("main_table")
	main_table.game_params["MJ"] = $initial_window/container/MJ_input.text
	main_table.game_params["co_MJ"]= $initial_window/container/coMJ_input.text
	main_table.game_params["n_players"] = int($initial_window/container/n_players_input.text)
	main_table.setup_table_for(int($initial_window/container/n_players_input.text))
	self.queue_free()
	
