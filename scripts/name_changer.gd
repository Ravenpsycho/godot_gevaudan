extends Control
var parent: PlayerTile
var pop_up: Popup
var line_edit: LineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = self.get_parent()
	pop_up = self.get_node("Popup")
	print(self.get_children())
	line_edit = pop_up.get_node("ColorRect").get_node("LineEdit")
	line_edit.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	parent.get_node("player_name_label").text = line_edit.text
	parent.name = line_edit.text
	pop_up.visible = false

func _on_item_list_item_selected(index: int) -> void:
	var rl:ItemList = self.get_node("Popup").get_node("ColorRect").get_node("role_list")
	var it = rl.get_item_text(index)
	parent.set_role(it)
