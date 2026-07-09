extends Control
var parent: PlayerTile
var pop_up: Window
var line_edit: LineEdit
var role_list: ItemList

const ALL_ROLES: Array = PlayerTile.ALL_ROLES

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = self.get_parent()
	pop_up = self.get_node("window")
	role_list = pop_up.get_node("container").get_node("role_list")
	line_edit = pop_up.get_node("container").get_node("LineEdit")
	if parent.player_name:
		line_edit.placeholder_text = parent.player_name
	line_edit.grab_focus()
	role_list.populate()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	if not line_edit.text:
		line_edit.add_theme_color_override("font_placeholder_color", Color(255,0,0))
		return
	parent.get_node("player_name_label").text = line_edit.text
	parent.name = line_edit.text
	pop_up.visible = false

func _on_item_list_item_selected(index: int) -> void:
	var it = role_list.get_item_text(index)
	parent.set_role(it)


func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text:
		parent.set_player_name(new_text)
	

func _on_line_edit_text_submitted(new_text: String) -> void:
	parent.set_player_name(new_text)
	DisplayServer.virtual_keyboard_hide()
