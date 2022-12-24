@tool
extends XRToolsSceneBase

func _update_demo_positions() -> void:
	var count = $Demos.get_child_count()
	if count > 1:
		var angle = 2.0 * PI / count
		for i in count:
			var t = Transform3D()
			t.origin = Vector3(0.0, 0.0, -7.0)
			t = t.rotated(Vector3.UP, angle * i)

			$Demos.get_child(i).transform = t


func _ready():
	_update_demo_positions()

	var webxr_interface = XRServer.find_interface("WebXR")
	if webxr_interface:
		XRToolsUserSettings.webxr_primary_changed.connect(self._on_webxr_primary_changed)
		_on_webxr_primary_changed(XRToolsUserSettings.get_real_webxr_primary())


func _on_webxr_primary_changed(webxr_primary: int) -> void:
	# Default to thumbstick.
	if webxr_primary == 0:
		webxr_primary = XRToolsUserSettings.WebXRPrimary.THUMBSTICK
	var action_name = XRToolsUserSettings.WebXRPrimaryName[webxr_primary]
	%LeftHand.get_node("MovementDirect").input_action = action_name
	%RightHand.get_node("MovementDirect").input_action = action_name
	%RightHand.get_node("MovementTurn").input_action = action_name


func _on_Demos_child_entered_tree(_node):
	_update_demo_positions()


func _on_Demos_child_exiting_tree(_node):
	_update_demo_positions()
