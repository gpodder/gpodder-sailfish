
import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0


Item {

    MediaKey {
        enabled: true
        key: Qt.Key_MediaTogglePlayPause
        onReleased: player.togglePause()
    }
    MediaKey {
        enabled: true
        key: Qt.Key_MediaPlay
        onReleased: player.play()
    }
    MediaKey {
        enabled: true
        key: Qt.Key_MediaPause
        onReleased: player.pause()
    }
    MediaKey {
        enabled: true
        key: Qt.Key_ToggleCallHangup
        onReleased: player.togglePause()
    }
    MediaKey {
        enabled: true
        key: Qt.Key_MediaStop
        onReleased: player.stop()
    }

}