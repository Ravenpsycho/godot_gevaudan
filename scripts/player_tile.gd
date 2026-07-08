extends Sprite2D

class_name PlayerTile

var UI: MainUI
var is_draggable:bool = false
var delay:float = 0.1
var mouse_offset
var card_overlay: Sprite2D
var drop_spots
var players: Array[Node]
var used_power: bool = false
var origin_pos
var opa
var target_pos
var in_love_with: PlayerTile
var mentor
var tween
var role: String = "Simple Villageois"
var line_edit:LineEdit
var alive = true
var cause_of_death: String = ""
var is_wherewolf: bool
var mentor_to: PlayerTile
const ALL_ROLES: Array = ['Enfant Sauvage', 'Juge Bègue', 'Abominable Sectaire', 
'Bouc Emissaire', 'Voleur', 'Salvateur', 'Loup Garou', 'Renard', 'Assassin', 'Ancien du Village', 
'Voyante', 'Petite Fille', 'Comédien', 'Simple Villageois', 'Joueur de flûte', 'Demi démon', 
'Corbeau', 'Cupidon', 'Sorcière', "Montreur d'Ours", 'Loup Garou Blanc', 'Pyromane', 
'Idiot du Village', 'Nécromancien', "Chevalier à l'épée Rouillée", 
'Chasseur', 'Ange', 'Chien Loup', 'Dictateur', 'Fossoyeur', 'Grand Méchant Loup',
'Infect Père des Loups']

const SHORTNAMES: Dictionary = {
	'Enfant Sauvage': "Enfant", 
	'Juge Bègue': "Juge", 
	'Abominable Sectaire': "Sectaire", 
	'Bouc Emissaire': "Bouc", 
	'Ancien du Village': "Ancien",
	'Petite Fille': "Petite", 
	'Simple Villageois': "Villageois", 
	'Joueur de flûte' : "Flûte", 
	"Montreur d'Ours": "Ours", 
	'Loup Garou Blanc': "Loup Blanc",
	'Idiot du Village': "Innocent", 
	"Chevalier à l'épée Rouillée": "Chevalier",
	'Grand Méchant Loup': "Grand Loup",
	'Infect Père des Loups': "Infect"
}

signal interact_with
signal role_changed

func _ready() -> void:
	drop_spots=get_tree().get_nodes_in_group("drop_spot_group")
	card_overlay = self.get_node("card_overlay")
	UI = self.get_parent().get_node("main_UI")
	z_index = 0
	
func _physics_process(delta: float) -> void:
	if is_draggable:
		tween = get_tree().create_tween()
		tween.tween_property(self,"position",get_global_mouse_position()-mouse_offset,delta*delay)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		players=get_tree().get_nodes_in_group("player_group")
		if event.is_pressed():
			origin_pos = self.position
			if get_rect().has_point(to_local(event.position)):
				is_draggable = true
				mouse_offset = get_global_mouse_position()-global_position
		elif event.is_released():
			if is_draggable:
				is_draggable = false
				for p in players:
					if overlaps_with(p):
						snap_back(origin_pos)
						interact_with.emit(self, p)
						return
				for drop_spot in drop_spots:
					process_dropspot(drop_spot)
							
			is_draggable = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func process_dropspot(drop_spot):
	if drop_spot.has_overlapping_areas() and drop_spot.get_overlapping_areas().has(self.get_node("collision_area")):
		tween = get_tree().create_tween()
		if drop_spot.name == "cemetary":
			self.toggle_death()
			tween.tween_property(self, "position", origin_pos, delay)
			if !alive:
				var pre = preload("res://scenes/death_menu.tscn")
				var death_menu = pre.instantiate()
				death_menu.player = self
				self.add_child(death_menu)
		elif drop_spot.name == "arrival_spot":
			tween.tween_property(self, "position", drop_spot.position, delay)
			self.get_node("name_changer").get_node("Popup").visible = true
		elif drop_spot.name == "delete_player":
			self.queue_free()
		else:
			tween.tween_property(self, "position", drop_spot.position, delay)
	
func die():
	self.alive = false
	self.get_node("dead_overlay").visible = true
	if self.in_love_with and self.in_love_with.alive:
		self.in_love_with.toggle_death()
	if self.mentor_to and self.mentor_to.alive:
		self.mentor_to.get_node("savage_overlay").visible=true
	

func come_back():
	self.alive = true
	self.get_node("dead_overlay").visible = false
	if self.in_love_with and !self.in_love_with.alive:
		self.in_love_with.toggle_death()
	if self.mentor_to:
		self.mentor_to.get_node("savage_overlay").visible=false

func toggle_death():
	if self.alive:
		self.die()
		UI.log("%s est mort!" % self.name)
		return true
	else:
		self.come_back()
		self.cause_of_death = ""
		UI.log("%s ramené à la vie!." % self.name)
		return false

func toggle_rage():
	pass

func get_first_player_at(pos):
	for p in players:
		if p.get_rect().has_point(to_local(pos)):
			return p

func fall_in_love(other_player):
	self.in_love_with = other_player
	self.get_node("love_overlay").visible = true

func reset_love():
	self.in_love_with = null
	self.get_node("love_overlay").visible = false

func reset_mentor():
	self.mentor = null
	self.mentor_to = null
	self.get_node("savage_overlay").visible = false
	self.get_node("mentor_overlay").visible = false
	
func overlaps_with(other):
	opa = other.get_node("collision_area")
	if opa.has_overlapping_areas() and opa.get_overlapping_areas().has(self.get_node("collision_area")):
		return true
	return false
					
func snap_back(to_pos):
	tween = get_tree().create_tween()
	tween.tween_property(self, "position", to_pos, delay)
						
func set_role(role_name:String):
	self.role = role_name
	card_overlay.texture = load("res://images/roles/"+unaccent(role_name)+".png")
	var short = SHORTNAMES.get(role_name)
	if short:
		role_changed.emit(short)
	else:	
		role_changed.emit(role_name)
		
func set_player_name(s:String):
	self.name = s
	self.get_node("player_name_label").text = s
	
func unaccent(s:String):
	s=s.replace("é", "e")
	s=s.replace("è", "e")
	s=s.replace("û", "u")
	s=s.replace("à", "a")
	return s
