import QtQuick 2.0
import Nemo.Notifications 1.0

Item {
    Notification {
        id: core_notification

        appName: "gPodder"
        appIcon: "/usr/share/icons/hicolor/256x256/apps/harbour-org.gpodder.sailfish.png"

        summary: "gPodder Core Error"

    }
    Connections {
        target: py

        onCoreError: {
            core_notification.body = message;
            core_notification.replacesId = 0;
            core_notification.publish();
        }
    }

    Notification {
        id: playback_notification

        appName: "gPodder"
        appIcon: "/usr/share/icons/hicolor/256x256/apps/harbour-org.gpodder.sailfish.png"

        summary: "gPodder Playback Error"

    }
    Connections {
        target: player

        onError: {
            playback_notification.body = errorString + '\nURI: ' + player.source;
            playback_notification.replacesId = 0;
            playback_notification.publish();
        }
    }
}
