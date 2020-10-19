
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
            cellularDownloadsEnabled.checked = configCellularDownloadsEnabled.value;
        } else if (status === PageStatus.Deactivating) {
            py.setConfig('plugins.youtube.api_key_v3', youtube_api_key_v3.text);
            py.setConfig('limit.episodes', parseInt(limit_episodes.value));
            youtube_api_key_v3.focus = false;
            configCellularDownloadsEnabled.value = cellularDownloadsEnabled.checked
        }
    }

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

            TextSwitch {
                id: cellularDownloadsEnabled
                text: qsTr("Allow Downloads via mobile data")
                checked: configCellularDownloadsEnabled.value
            }

        }
    }
}
