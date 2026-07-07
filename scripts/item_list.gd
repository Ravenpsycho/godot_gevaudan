extends ItemList

const ALL_ROLES: Array = ['Enfant Sauvage', 'Juge Bègue', 'Abominable Sectaire', 
'Bouc Emissaire', 'Voleur', 'Salvateur', 'Loup Garou', 'Renard', 'Assassin', 'Ancien du Village', 
'Voyante', 'Petite Fille', 'Comédien', 'Simple Villageois', 'Joueur de flûte', 'Demi démon', 
'Corbeau', 'Cupidon', 'Sorcière', "Montreur d'Ours", 'Loup Garou Blanc', 'Pyromane', 
'Idiot du Village', 'Plumes du corbeau', 'Nécromancien', "Chevalier à l'épée Rouillée", 
'Chasseur', 'Ange', 'Chien Loup', 'Dictateur', 'Fossoyeur', 'Grand Méchant Loup']

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for r in ALL_ROLES:
		self.add_item(r)
	self.sort_items_by_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
