extends ItemList

var CAUSES_NIGHT: Array[String] = [
	"Dévoré.e par les Loups!",
]

var CAUSES_DAY: Array[String] = [
	"Lynché par le village!",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var causes: Array
	var main_table: MainTable = get_tree().get_first_node_in_group("main_table")
	
	if main_table.game_params["day_night"] == "Nuit":
		causes = CAUSES_NIGHT
		if main_table.check_role("Assassin"):
			causes.append("Assassiné sournoisement! (Assassin)")
		if main_table.check_role("Grand Méchant Loup"):
			causes.append("Proie du Grand Méchant Loup!")
		if main_table.check_role("Sorcière"):
			causes.append("Empoisonné.e par la sorcière!")
	
	else:
		causes = CAUSES_DAY
		if main_table.check_role("Chasseur"):
			causes.append("Tué.e par le chasseur!")
		if main_table.check_role("Petite Fille"):
			causes.append("Percé.e à jour! (Petite Fille)")
	for c in causes:
		self.add_item(c)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
