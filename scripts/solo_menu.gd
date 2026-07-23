extends Control

var ctx_btn: Button
var cancel: Button
var mayor_btn: Button
var UI: MainUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ctx_btn = $ReferenceRect/Context
	mayor_btn = $ReferenceRect/Elire_Maire
	cancel = $ReferenceRect/Cancel
	UI = get_tree().get_first_node_in_group("main_table").get_node("main_UI")
	change_context()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_context():
	var pr = get_parent().role
	var p = get_parent()
	var main_table: MainTable = get_tree().get_first_node_in_group("main_table")
	
	ctx_btn.text = ""
	mayor_btn.text = ""
	
	ctx_btn.visible = false
	mayor_btn.visible = false
	
	if p.get("mayor_overlay"):
		mayor_btn.text = "Abediquer"
		mayor_btn.visible = true
		
	if !main_table.check_overlay("mayor_overlay"):
		mayor_btn.text = "Elire Maire.sse"
		mayor_btn.visible = true
	
	if pr == "Renard":
		ctx_btn.text = "Perd Pouv."
		ctx_btn.visible = true
	if pr == "Innocent du Village":
		ctx_btn.text = "Révéler"
		ctx_btn.visible = true

func _on_cancel_pressed() -> void:
	visible = false


func _on_context_pressed() -> void:
	if ctx_btn.text == "Perd Pouv.":
		UI.log("%s <%s>\nperd son pouvoir!")
	if ctx_btn.text == "Révéler":
		UI.log("%s <%s>\nrévèle son rôle!")
	visible = false


func _on_elire_maire_pressed() -> void:
	var p: PlayerTile = get_parent()
	p.mayor_overlay = !p.mayor_overlay
	p.update_overlays()
	visible = false
