extends PopupMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.add_radio_check_item("1")
	self.add_radio_check_item("2")
	self.add_radio_check_item("3")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
