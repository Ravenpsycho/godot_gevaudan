extends ItemList

var causes: Array[String] = [
	"Dévoré.e par les Loups!",
	"Lynché.e par le Village!",
	"Empoisonné.e par la sorcière!",
	"Tué.e par le chasseur!",
	"Percé.e à jour! (Petite Fille)"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for c in causes:
		self.add_item(c)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
