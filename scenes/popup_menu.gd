extends PopupMenu

const ALL_ROLES: Array = PlayerTile.ALL_ROLES

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for r in ALL_ROLES:
		self.add_item(r)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
