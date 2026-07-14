extends PanelContainer
var player: PlayerTile
var line_edit: LineEdit
var role_list: ItemList

const ALL_ROLES: Array = PlayerTile.ALL_ROLES

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	role_list = $"container/role_list"
	line_edit = $"container/LineEdit"
	line_edit.grab_focus()
	role_list.populate()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_player(p:PlayerTile):
	player = p
	

func _on_button_pressed() -> void:
	if not line_edit.text:
		line_edit.add_theme_color_override("font_placeholder_color", Color(255,0,0))
		return
	player.get_node("player_name_label").text = line_edit.text
	player.name = line_edit.text
	queue_free()

func _on_item_list_item_selected(index: int) -> void:
	var it = role_list.get_item_text(index)
	player.set_role(it)


func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text:
		player.set_player_name(new_text)
	

func _on_line_edit_text_submitted(new_text: String) -> void:
	player.set_player_name(new_text)
	DisplayServer.virtual_keyboard_hide()
