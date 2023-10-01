import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    Image {
        id: episodeArtArea
        visible: episode_art || cover_art ? true : false
        asynchronous: true

        anchors {
            left: parent.left
            top: parent.top
        }
        height: episode_art !== '' && cover_art !== '' ? parent.height * 0.9 : parent.height
        width: episode_art !== '' && cover_art !== '' ? parent.width * 0.9 : parent.width

        source: episode_art ? episode_art : cover_art
    }
    Image {
        id: podcastArtArea
        visible: episode_art && cover_art ? true : false
        asynchronous: true

        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        opacity: 0.75
        height: parent.height * 0.4
        width: parent.width * 0.4
        source: cover_art
    }
    Rectangle {
        anchors.fill: parent
        visible: cover_art === '' && episode_art === '' ? true : false
        color: Theme.rgba(Theme.highlightColor, 0.5)

        clip: true

        Label {
            anchors.centerIn: parent

            font.pixelSize: parent.height * 0.8
            text: title_char
            color: Theme.highlightColor
        }
    }
}
