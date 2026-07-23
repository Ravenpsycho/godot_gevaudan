extends Control

var ctx_btn: Button
var cancel: Button
var UI: MainUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ctx_btn = $ReferenceRect/Context
	cancel = $ReferenceRect/Cancel
	UI = get_tree().get_first_node_in_group("main_table").get_node("main_UI")
	change_context()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_context():
	var pr = get_parent().role
	if pr == "Renard":
		ctx_btn.text = "Perd Pouv."
		ctx_btn.visible = true
		return
	if pr == "Innocent du Village":
		ctx_btn.text = "Révéler"
		ctx_btn.visible = true
		return
	ctx_btn.text = ""
	ctx_btn.visible = false
	


func _on_cancel_pressed() -> void:
	visible = false


func _on_context_pressed() -> void:
	if ctx_btn.text == "Perd Pouv.":
		UI.log("%s <%s>\nperd son pouvoir!")
	if ctx_btn.text == "Révéler":
		UI.log("%s <%s>\nrévèle son rôle!")
	visible = false
