@tool
extends XRToolsStaging

## Introduction
#
# This is an example of using the staging system in XRTools
# to create an environment in which you can background load
# scenes and switch between them.
#
# There is also some example code here on how to react to 
# the player taking their headset on/off.
#
# The primary function here is to trigger the
# "Press to continue" dialog when switching scenes. 
# We do not want to enter our just loaded scene when the
# player is still thumbling around putting their headset on
# so if we detect they hadn't put their headset on yet 
# when we were scene switching, we prompt the user.
#
# Finally this shows an example of how to react to pause
# a game. This is not implemented in this demo (yet) but
# note that most XR runtimes stop giving us controller
# tracking data at this point.

var scene_is_loaded : bool = false

var webxr_interface: WebXRInterface
var webxr_vr_is_supported := false

# Called when this handle is added to the scene
func _ready() -> void:
	# In Godot 4 we must now manually call our super class ready function
	super._ready()

	webxr_interface = XRServer.find_interface('WebXR')
	if webxr_interface:
		webxr_interface.session_supported.connect(self._on_webxr_session_supported)
		webxr_interface.session_started.connect(self._on_webxr_session_started)
		webxr_interface.session_ended.connect(self._on_webxr_session_ended)
		webxr_interface.session_failed.connect(self._on_webxr_session_failed)

		webxr_interface.is_session_supported("immersive-vr")


func _on_webxr_session_supported(session_mode: String, supported: bool) -> void:
	if session_mode == "immersive-vr":
		webxr_vr_is_supported = supported
		if webxr_vr_is_supported:
			%WebXRLayer.visible = true
		else:
			OS.alert("Your web browser doesn't support VR. Sorry!")


func _on_webxr_session_started() -> void:
	%WebXRLayer.visible = false
	get_viewport().use_xr = true


func _on_webxr_session_ended() -> void:
	%WebXRLayer.visible = true
	get_viewport().use_xr = false


func _on_webxr_session_failed(message: String) -> void:
	OS.alert("Unable to enter VR: " + message)
	%WebXRLayer.visible = true


func _on_webxr_enter_vr_button_pressed():
	webxr_interface.session_mode = 'immersive-vr'
	webxr_interface.requested_reference_space_types = 'bounded-floor, local-floor, local'
	webxr_interface.required_features = 'local-floor'
	webxr_interface.optional_features = 'bounded-floor'

	if not webxr_interface.initialize():
		OS.alert("Failed to initialize")


func _on_Staging_scene_loaded(scene):
	# We only show the press to continue the first time we load a scene
	# to give the player time to put their headset on.
	prompt_for_continue = false
	scene_is_loaded = true


func _on_Staging_scene_exiting(scene):
	# We no longer have an active scene
	scene_is_loaded = false


func _on_XROrigin3D_focused_state():
	# We get the focussed state when the user puts on their headset,
	# or returns from the system menus.
	# If the user did so while we were already scene switching
	# we leave our prompt for continue on,
	# else we turn our prompt for continue off.
	if scene_is_loaded:
		# No longer need our prompt
		prompt_for_continue = false

		# This would be a good moment to unpause your game


func _on_XROrigin3D_session_synchronized():
	# We get the synchronized state at startup and whenever the player
	# removes their headset (or goes into the menu system).
	#
	# If the user doesn't put their headset on again before we load a
	# new scene, we'll want to show the prompt so we don't load the
	# next scene in while the player is still adjusting their position
	prompt_for_continue = true

	if scene_is_loaded:
		# This would be a good moment to pause your game
		pass

