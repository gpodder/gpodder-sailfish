
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2015, Thomas Perl <m@thp.io>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import 'common'

Page {
    id: settingsPage
    allowedOrientations: Orientation.All

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            py.getConfig('plugins.youtube.api_key_v3', function (value) {
                youtube_api_key_v3.text = value;
            });
            py.getConfig('limit.episodes', function (value) {
                limit_episodes.value = value;
            });
            py.getConfig('update.scheduled_interval', function (value) {
                if(value) settingsPage.automaticUpdateTime = value;
            });
        } else if (status === PageStatus.Deactivating) {
            py.setConfig('plugins.youtube.api_key_v3', youtube_api_key_v3.text);
            py.setConfig('limit.episodes', parseInt(limit_episodes.value));
            youtube_api_key_v3.focus = false;
            if(settingsPage.automaticUpdateTime){
                py.call('main.set_scheduled_update',[settingsPage.automaticUpdateTime])
                console.info("setting scheduled updater to:",settingsPage.automaticUpdateTime)
            }
            else{
                py.call('main.disable_scheduled_update')
                console.info("disabling scheduled updater")
            }
        }
    }

    property var automaticUpdateTime

    SilicaFlickable {
        id: settingsList
        anchors.fill: parent

        VerticalScrollDecorator { flickable: settingsList }

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pgst.loadPage('AboutPage.qml');
            }
        }

        Column {
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("YouTube")
                horizontalAlignment: Text.AlignHCenter
            }

            TextField {
                id: youtube_api_key_v3
                label: qsTr("API Key (v3)")
                placeholderText: label
                width: parent.width
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                EnterKey.iconSource: (text.length > 0) ? "image://theme/icon-m-enter-accept" : "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }

            SectionHeader {
                text: qsTr("Limits")
                horizontalAlignment: Text.AlignHCenter
            }

            Slider {
                id: limit_episodes
                label: qsTr("Maximum episodes per feed")
                valueText: value
                width: parent.width
                minimumValue: 100
                maximumValue: 1000
                stepSize: 100
            }

            SectionHeader {
                text: qsTr("Automatic Updates")
                horizontalAlignment: Text.AlignHCenter
            }

            Label{
                text: settingsPage.automaticUpdateTime
            }

            Button {
                id: automatic_update_time
                text: qsTr("Choose Time")
                onClicked: {
                    var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                       hour: 6,
                       minute: 0,
                       hourMode: DateTime.TwelveHours
                   })
                   dialog.accepted.connect(function() {
                       settingsPage.automaticUpdateTime = "*-*-* "+dialog.hour+":"+dialog.minute+":*"
                   })
                }

            }
        }
    }
}
