import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets

Scope {
	id: root

	// Bind the pipewire node so its volume will be tracked
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}
	property real lastVolume: Pipewire.defaultAudioSink?.audio.volume ?? 0
	property bool wasMutedByUser: false

	Connections {
		id: volume
		target: Pipewire.defaultAudioSink?.audio

    	function onVolumeChanged() {
    	    // if muted and user changed volume, treat as unmute action:
    	    if (Pipewire.defaultAudioSink?.audio.muted) {
    	        // user adjusted volume while muted -> unmute and restore behavior
    	        Pipewire.defaultAudioSink.audio.muted = false
    	        root.wasMutedByUser = false
    	    }
    	    // when not muted, keep lastVolume up to date
    	    root.lastVolume = Pipewire.defaultAudioSink?.audio.volume ?? root.lastVolume
    	    root.shouldShowOsd = true
    	    hideTimer.restart()
    	}
		function onMutedChanged() {
        	if (Pipewire.defaultAudioSink?.audio.muted) {
        	    // remember last volume when muted and set flag
        	    root.lastVolume = Pipewire.defaultAudioSink?.audio.volume ?? root.lastVolume
        	    root.wasMutedByUser = true
        	} else {
        	    // unmuted: do nothing special (bar will show lastVolume)
        	    root.wasMutedByUser = false
        	}
        	root.shouldShowOsd = true
        	hideTimer.restart()
		}
	}

	property bool shouldShowOsd: false

	Timer {
		id: hideTimer
		interval: 1000
		onTriggered: root.shouldShowOsd = false
	}

	// The OSD window will be created and destroyed based on shouldShowOsd.
	// PanelWindow.visible could be set instead of using a loader, but using
	// a loader will reduce the memory overhead when the window isn't open.
	LazyLoader {
		active: root.shouldShowOsd

		PanelWindow {
			// Since the panel's screen is unset, it will be picked by the compositor
			// when the window is created. Most compositors pick the current active monitor.

			anchors.top: true
			margins.top: screen.height/12
			exclusiveZone: 0

			implicitWidth: 300
			implicitHeight: 50
			color: "transparent"

			// An empty click mask prevents the window from blocking mouse events.
			mask: Region {}

			Rectangle {
				anchors.fill: parent
				radius: height / 2
				color: "transparent"

				RowLayout {
					anchors {
						fill: parent
						leftMargin: 10
						rightMargin: 10
					}

					Rectangle {
						// Stretches to fill all left-over space
						Layout.fillWidth: true

						implicitHeight: 5
						radius: 10
						color: "#5090ff00"

						Rectangle {
							anchors {
								left: parent.left
								top: parent.top
								bottom: parent.bottom
							}
							color: "#a090ff00"
						    implicitWidth: (Pipewire.defaultAudioSink?.audio.muted && root.wasMutedByUser) ? 0 : parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? root.lastVolume)
							radius: parent.radius
						}
					}
				}
			}
		}
	}
}