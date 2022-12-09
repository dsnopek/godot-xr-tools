extends Node

var _webxr_interface: WebXRInterface

func _ready() -> void:
	_webxr_interface = XRServer.find_interface('WebXR')


func is_available() -> bool:
	return _webxr_interface != null


func convert_input_action(p_controller: XRController3D, p_input_action: String) -> String:
	if p_input_action == 'primary':
		var trackpad = p_controller.get_axis("trackpad")
		if not trackpad.is_zero_approx():
			return "trackpad"
		
		return "thumbstick"
	
	return p_input_action
