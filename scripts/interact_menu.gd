extends Control
var parent_player:PlayerTile #The parent player
var parent_target:PlayerTile #The parent target
var love
var cancel
var ctx
var swap
var players
var ref
var delay = 0.25
var UI: MainUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UI = get_tree().get_first_node_in_group("main_table").get_node("main_UI")
	ref = self.get_node("ReferenceRect")
	love = ref.get_node("Love")
	cancel = ref.get_node("Cancel")
	ctx = ref.get_node("Context")
	swap = ref.get_node("Swap")
	update_players()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if love.is_pressed():
		if test_lovers():
			reset_lovers()
			self.visible = false
		else:
			UI.log("%s loves %s" % [parent_player.name, parent_target.name])
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
			parent_target.get_node("mentor_overlay").visible = true
			self.visible = false
		if ctx.text == "Plumes":
			reset_feathers()
			parent_target.get_node("raven_overlay").visible = true
			self.visible = false
		if ctx.text == "Charmer":
			parent_target.get_node("flute_overlay").visible = true
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
	if !test_for_role("Cupidon"):
		love.visible = false
	
func get_context():
	if parent_player.role == "Enfant Sauvage" and !test_mentor():
		return "Mentor"
	if parent_player.role == "Corbeau":
		return "Plumes"
	if parent_player.role == "Joueur de flûte":
		return "Charmer"
	return ""

func reset_lovers():
	print("lovers reset!")
	for p in players:
		p.reset_love()

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
