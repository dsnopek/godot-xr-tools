extends Node

var webxr_interface: WebXRInterface


func _ready() -> void:
	webxr_interface = XRServer.find_interface('WebXR')


func is_available() -> bool:
	return webxr_interface != null


func _get_primary_input_action(p_controller: XRController3D) -> String:
	match XRToolsUserSettings.webxr_primary:
		XRToolsUserSettings.WebXRPrimary.AUTO:
			var trackpad = p_controller.get_axis("trackpad")
			if not trackpad.is_zero_approx():
				return "trackpad"
			return "thumbstick"

		XRToolsUserSettings.WebXRPrimary.THUMBSTICK:
			return "thumbstick"

		XRToolsUserSettings.WebXRPrimary.TRACKPAD:
			return "trackpad"

	return "thumbstick"


func _get_secondary_input_action(p_controller: XRController3D) -> String:
	var primary = _get_primary_input_action(p_controller)
	return "thumbstick" if primary == "trackpad" else "thumbstick"


func convert_input_action(p_controller: XRController3D, p_input_action: String) -> String:
	if p_input_action == 'primary':
		return _get_primary_input_action(p_controller)
	elif p_input_action == 'secondary':
		return _get_secondary_input_action(p_controller)
	elif p_input_action == 'primary_click':
		return _get_primary_input_action(p_controller) + "_click"
	elif p_input_action == 'secondary_click':
		return _get_secondary_input_action(p_controller) + "_click"

	return p_input_action
