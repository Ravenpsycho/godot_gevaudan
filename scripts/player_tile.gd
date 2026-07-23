extends Sprite2D

class_name PlayerTile

var UI: MainUI
var main_table: MainTable
var is_draggable:bool = false
var delay:float = 0.1
var mouse_offset
var card_overlay: Sprite2D
var love_overlay: bool = false
var mentor_overlay: bool = false
var raven_overlay: bool = false
var savage_overlay: bool = false
var flute_overlay: bool = false
var protected_overlay: bool = false
var tetanos_overlay: bool = false
var voted_ww: bool = false
var voted_village: bool = false
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
var alive: bool = true
var cause_of_death: String = ""
var is_wherewolf: bool = false
var mentor_to: PlayerTile
var name_changer
var player_name: String

const OVERLAYS: Array = [
	"love_overlay",
	"mentor_overlay",
	"raven_overlay",
	"savage_overlay",
	"flute_overlay",
	"protected_overlay",
	"tetanos_overlay",
	"voted_village",
	"voted_ww"
]

const RELATIONS: Array = [
	"in_love_with",
	"mentor"
]

const WOLVES: Array =[
	"Loup Garou",
	"Loup Garou Blanc",
	"Grand Méchant Loup",
	"Infect Père des Loups"
]

const ALL_ROLES: Array = ['Enfant Sauvage', 'Juge Etourdi', 'Abominable Sectaire', "Deux Soeurs",
'Bouc Emissaire', 'Voleur', 'Salvateur', 'Loup Garou', 'Renard', 'Assassin', 'Ancien du Village', 
'Voyante', 'Petite Fille', 'Comédien', 'Simple Villageois', 'Joueur de Flûte', 'Demi démon', 
'Corbeau', 'Cupidon Amoureux', 'Sorcière', "Montreur d'Ours", 'Loup Garou Blanc', 'Pyromane', 
'Innocent du Village', 'Nécromancien', "Chevalier à l'épée Rouillée", "Trois Frères",
'Chasseur', 'Ange', 'Chien Loup', 'Dictateur', 'Fossoyeur', 'Grand Méchant Loup',
'Infect Père des Loups', "Servante Dévouée"]

const BASE_VILLAGER_ROLES: Array = ['Voyante', 'Petite Fille', 'Sorcière',
'Chasseur']

const SHORTNAMES: Dictionary = {
	'Enfant Sauvage': "Enfant", 
	'Juge Etourdi': "Juge", 
	'Abominable Sectaire': "Sectaire", 
	'Bouc Emissaire': "Bouc", 
	'Ancien du Village': "Ancien",
	'Petite Fille': "Petite", 
	'Simple Villageois': "Villageois", 
	'Joueur de Flûte' : "Flûte", 
	"Montreur d'Ours": "Ours", 
	'Loup Garou Blanc': "Loup Blanc",
	'Innocent du Village': "Innocent", 
	"Chevalier à l'épée Rouillée": "Chevalier",
	'Grand Méchant Loup': "Grand Loup",
	'Infect Père des Loups': "Infect",
	'Cupidon Amoureux': "Cupidon 💘",
	'Servante Dévouée': "Servant.e"
}

signal interact_with
signal role_changed
signal name_changed

func _ready() -> void:
	drop_spots=get_tree().get_nodes_in_group("drop_spot_group")
	card_overlay = get_node("card_overlay")
	main_table = get_tree().get_first_node_in_group("main_table")
	UI = get_parent().get_node("main_UI")
	
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
				print(self.position)
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
	
func update_overlays():
	if !alive:
		$dead_overlay.visible = true
	else:
		$dead_overlay.visible = false
	for o in OVERLAYS:
		var n = get_node(o)
		n.set("visible", self.get(o))
	UI.update_progress()
	
func process_dropspot(drop_spot):
	var cond1 = drop_spot.has_overlapping_areas()
	var cond2 = drop_spot.get_overlapping_areas().has(self.get_node("collision_area"))
	if cond1 and cond2:
		tween = get_tree().create_tween()
		if drop_spot.name == "cemetary":
			if self.protected_overlay:
				tween.tween_property(self, "position", origin_pos, delay)
				UI.log("%s protégé par le salvateur!" % self.name)
				return
			self.toggle_death()
			tween.tween_property(self, "position", origin_pos, delay)
			if !alive:
				var pre = preload("res://scenes/death_menu.tscn")
				var death_menu = pre.instantiate()
				death_menu.player = self
				self.add_child(death_menu)
		elif drop_spot.name == "arrival_spot":
			tween.tween_property(self, "position", drop_spot.position, delay)
			call_name_changer()
		elif drop_spot.name == "delete_player":
			self.queue_free()
		else:
			tween.tween_property(self, "position", drop_spot.position, delay)
			var solo = $solo_menu
			var context_btn = $solo_menu/ReferenceRect/Context
			solo.change_context()
			if !(context_btn.text == ""):
				solo.visible = true

func call_name_changer():
	if get_node("name_changer"):
		return
	var nc = preload("res://scenes/name_changer.tscn").instantiate()
	nc.get_node("container/info_label").text = "infos pour %s" % self.name
	nc.set_player(self)
	nc.position = Vector2(0, 0)
	add_child(nc)
			
func infect():
	is_wherewolf = true
	savage_overlay = true
	update_overlays()

func disinfect():
	if role not in WOLVES:
		is_wherewolf = false
	self.savage_overlay = false
	update_overlays()
	
func die():
	alive = false
	var dead_ol = $dead_overlay
	dead_ol.visible = true
	UI.log("%s <%s> est mort!" % [name, role])
	if in_love_with and in_love_with.alive:
		in_love_with.toggle_death()
		UI.log("--> de chagrin!" % in_love_with.name)
	elif tetanos_overlay:
		UI.log("--> le tétanos l'emporte!" % name)
	if mentor_to and mentor_to.alive:
		mentor_to.savage_overlay=true
		mentor_to.is_wherewolf = true
		mentor_to.update_overlays()
	
func come_back():
	alive = true
	var dead_ol = $dead_overlay
	dead_ol.visible = false
	UI.log("%s <%s> ramené à la vie!" % [name, role])
	get_node("dead_overlay").visible = false
	if in_love_with and !in_love_with.alive:
		in_love_with.toggle_death()
	if mentor_to:
		mentor_to.get_node("savage_overlay").visible=false

func toggle_death():
	if alive:
		die()
		update_overlays()
		return true
	else:
		come_back()
		cause_of_death = ""
		update_overlays()
		return false

func toggle_rage():
	pass

func get_first_player_at(pos):
	for p in players:
		if p.get_rect().has_point(to_local(pos)):
			return p

func fall_in_love(other_player):
	in_love_with = other_player
	self.get_node("love_overlay").visible = true

func reset_love():
	in_love_with = null
	self.get_node("love_overlay").visible = false

func reset_mentor():
	mentor = null
	mentor_to = null
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
						
func set_role(role_name:String, with_update:bool=true):
	role = role_name
	if role_name in WOLVES:
		is_wherewolf = true
	else:
		is_wherewolf = false
	card_overlay.texture = load("res://images/roles/"+unaccent(role_name)+".png")
	var short = SHORTNAMES.get(role_name)
	if short:
		role_changed.emit(short)
	else:	
		role_changed.emit(role_name)
	if with_update:
		UI.update_progress()
		
func set_player_name(s:String):
	self.name = s
	self.player_name = s
	name_changed.emit(s)
	
func unaccent(s:String):
	s=s.replace("é", "e")
	s=s.replace("è", "e")
	s=s.replace("û", "u")
	s=s.replace("à", "a")
	return s
	
func set_relation_with_name(relation:String, with:String):
	players = get_tree().get_nodes_in_group("player_group")
	for p in players:
		if p.name == with and relation in RELATIONS:
			set(relation, p)
		
func save():
	var savedict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"player_name" : player_name,
		"role" : role,
		"is_wherewolf": is_wherewolf,
		"alive": alive,
	}
	for o in OVERLAYS:
		savedict[0] = self.get(o)
	if mentor:
		savedict["mentor_name"] = mentor.name
	if in_love_with:
		savedict["lover_name"] = mentor.name
	return savedict

func post_load_routine():
	set_role(role)
	set_player_name(player_name)
	update_overlays()
