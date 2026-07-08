extends Control
var UI: MainUI
var player:PlayerTile
var popup : Popup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popup = self.get_node("Popup")
	UI = get_tree().get_first_node_in_group("main_table").get_node("main_UI")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_cause_list_item_selected(index: int) -> void:
	var itemlist: ItemList = self.get_node("Popup").get_node("ColorRect").get_node("cause_list")
	var cause = itemlist.get_item_text(index)
	UI.log(cause)
	player.cause_of_death = cause
	self.queue_free()
	
