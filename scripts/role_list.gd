extends ItemList
const ALL_ROLES: Array = PlayerTile.ALL_ROLES

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func populate(with=""):
	self.clear()
	for r:String in ALL_ROLES:
		if r.to_lower().contains(with.to_lower()) or with == "":
			add_item(r)
			sort_items_by_text()



func _on_role_filter_text_changed(new_text: String) -> void:
	populate(new_text)
