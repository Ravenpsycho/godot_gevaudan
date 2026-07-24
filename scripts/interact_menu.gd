extends Control

class_name Interactor

var main_table: MainTable
var parent_player:PlayerTile #The parent player
var parent_target:PlayerTile #The parent target
var love
var chose_victim_btn: Button
var cancel
var ctx
var swap
var players
var ref
var delay = 0.25
var UI: MainUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_table = get_tree().get_first_node_in_group("main_table")
	UI = main_table.get_node("main_UI")
	ref = $ReferenceRect
	love = $ReferenceRect/Love
	cancel = $ReferenceRect/Cancel
	ctx = $ReferenceRect/Context
	swap = $ReferenceRect/Swap
	chose_victim_btn = $base_actions/Designer
	update_players()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if love.is_pressed():
		if test_lovers():
			reset_lovers()
			self.visible = false
		else:
			UI.log("%s aime %s" % [parent_player.name, parent_target.name])
			parent_player.fall_in_love(parent_target)
			parent_target.fall_in_love(parent_player)
			self.visible = false
			
	if swap.is_pressed():
		var tween = get_tree().create_tween()
		var origin = parent_player.position
		var destination = parent_target.position
		tween.tween_property(parent_player, "position", destination, delay)
		tween.tween_property(parent_target, "position", origin, delay)
		self.visible=false
	
	if cancel.is_pressed():
		self.visible = false
		
	if ctx.is_pressed():
		## Add test for savage child
		if ctx.text == "Mentor":
			parent_player.mentor = parent_target
			parent_target.mentor_to = parent_player
			parent_target.mentor_overlay = true
			UI.log("%s choisit %s comme Mentor!" % [parent_player.name, parent_target.name])
			parent_target.update_overlays()
			self.visible = false
		if ctx.text == "Plumes":
			reset_feathers()
			parent_target.raven_overlay = true
			UI.log("%s reçoit les plumes!" % parent_target.name)
			parent_target.update_overlays()
			self.visible = false
		if ctx.text == "Charmer":
			parent_target.flute_overlay = true
			UI.log("%s tombe sous le charme!" % parent_target.name)
			parent_target.update_overlays()
			self.visible = false
		if ctx.text == "Sauver":
			UI.log("La sorcière sauve %s!" % parent_target.name)
			self.visible = false
		if ctx.text == "Tétanos!":
			UI.log("%s est infecté par le Tétanos!" % parent_target.name)
			parent_target.tetanos_overlay = true
			parent_target.update_overlays()
			self.visible = false
		if ctx.text == "Protéger":
			if parent_target.name == main_table.game_params["last_protected"]:
				UI.log("Pas possible! Déja protégé en dernier!!")
				self.visible = false
				return
			reset_salvation()
			UI.log("%s est protégé pour la nuit!" % parent_target.name)
			main_table.game_params["last_protected"] = parent_target.name
			parent_target.protected_overlay = true
			parent_target.update_overlays()
			self.visible = false
		if ctx.text == "Prendre rôle":
			UI.log("%s échange son rôle avec %s!" % [parent_player.name, parent_target.name])
			UI.log("--> Iel devient %s!" % [parent_target.role])
			var temp = parent_player.role
			parent_player.role = parent_target.role
			parent_target.role = temp
			self.visible = false
		if ctx.text == "Vision":
			UI.log("%s a une vision de %s!" % [parent_player.name, parent_target.name])
			self.visible = false
		if ctx.text == "Infecter":
			parent_target.infect()
			UI.log("%s infecte %s!" % [parent_player.name, parent_target.name])
			UI.log("Iel est loup, désormais!" % [parent_player.name, parent_target.name])
			main_table.update_counts()
			self.visible = false
		

func _on_player_tile_interact_with(origin, target) -> void:
	update_players()
	parent_player = origin
	parent_target = target
	love.visible = !test_lovers()
	ctx.text = get_context()
	self.visible = true
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	if ctx.text == "":
		ctx.visible = false
	if !test_for_role("Cupidon Amoureux"):
		love.visible = false
	
func get_context():
	if parent_player.role == "Enfant Sauvage" and !test_mentor():
		return "Mentor"
	if parent_player.role == "Corbeau":
		return "Plumes"
	if parent_player.role == "Joueur de Flûte":
		return "Charmer"
	if parent_player.role == "Sorcière" and !parent_player.used_power:
		return "Sauver"
	if parent_player.role == "Chevalier à l'épée Rouillée":
		return "Tétanos!"
	if parent_player.role == "Salvateur":
		return "Protéger"
	if parent_player.role == "Servante Dévouée":
		return "Prendre rôle"
	if parent_player.role == "Voyante":
		return "Vision"
	if parent_player.role == "Infect Père des Loups":
		return "Infecter"
	return ""

func reset_lovers():
	print("lovers reset!")
	for p in players:
		p.reset_love()
		
func reset_salvation():
	for p in players:
		p.protected_overlay = false
		p.get_node("protected_overlay").visible = false
	

func reset_feathers():
	print("feathers reset!")
	for p in players:
		p.get_node("raven_overlay").visible = false
		
func test_lovers():
	for p in players:
		if p.in_love_with:
			return true
	return false

func reset_mentor():
	print("mentor reset!")
	for p in players:
		p.mentor = null
		
func test_mentor():
	for p in players:
		if p.mentor:
			return true
	return false
	
func update_players():
	players = get_tree().get_nodes_in_group("player_group")

func test_for_role(r:String):
	for p in players:
		if p.role == r:
			return true
	return false


func _on_designer_pressed() -> void:
	if main_table.game_params["day_night"] == "Nuit" :
		parent_target.voted_ww = true
		parent_target.update_overlays()
		UI.log("%s est désigné.e par la Meute!" % parent_target.name)
	else:
		parent_target.voted_village = true
		parent_target.update_overlays()
		UI.log("%s est désigné.e par la foule!" % parent_target.name)
		
