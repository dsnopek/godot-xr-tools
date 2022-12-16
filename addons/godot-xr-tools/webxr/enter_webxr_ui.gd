extends CanvasLayer

func _ready() -> void:
	visible = false

	if XRToolsWebXR.is_available():
		XRToolsWebXR.webxr_interface.session_supported.connect(self._on_webxr_session_supported)
		XRToolsWebXR.webxr_interface.session_started.connect(self._on_webxr_session_started)
		XRToolsWebXR.webxr_interface.session_ended.connect(self._on_webxr_session_ended)
		XRToolsWebXR.webxr_interface.session_failed.connect(self._on_webxr_session_failed)

		XRToolsWebXR.webxr_interface.is_session_supported("immersive-vr")


func _on_webxr_session_supported(session_mode: String, supported: bool) -> void:
	if session_mode == "immersive-vr":
		if supported:
			visible = true
		else:
			OS.alert("Your web browser doesn't support VR. Sorry!")


func _on_webxr_session_started() -> void:
	visible = false
	get_viewport().use_xr = true


func _on_webxr_session_ended() -> void:
	visible = true
	get_viewport().use_xr = false


func _on_webxr_session_failed(message: String) -> void:
	OS.alert("Unable to enter VR: " + message)
	visible = true


func _on_enter_vr_button_pressed():
	XRToolsWebXR.webxr_interface.session_mode = 'immersive-vr'
	XRToolsWebXR.webxr_interface.requested_reference_space_types = 'bounded-floor, local-floor, local'
	XRToolsWebXR.webxr_interface.required_features = 'local-floor'
	XRToolsWebXR.webxr_interface.optional_features = 'bounded-floor'

	if not XRToolsWebXR.webxr_interface.initialize():
		OS.alert("Failed to initialize")
