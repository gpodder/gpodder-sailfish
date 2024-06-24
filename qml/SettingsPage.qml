
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
import Sailfish.Pickers 1.0

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
            py.getConfig('ui.qml.playback_speed.stepSize', function (value) {
                speed_increment.value = value;
            });
            py.getConfig('ui.qml.playback_speed.minimumValue', function (value) {
                speed_min.text = value;
            });
            py.getConfig('ui.qml.playback_speed.maximumValue', function (value) {
                speed_max.text = value;
            });
            py.getConfig('fs.downloads', function (value) {
                downloads_folder_picker.value = value;
                py.call('main.get_path_media_status', [value], function(status) {
                    nomedia_toggle.checked = status; });
            });
        } else if (status === PageStatus.Deactivating) {
            py.setConfig('plugins.youtube.api_key_v3', youtube_api_key_v3.text);
            py.setConfig('limit.episodes', parseInt(limit_episodes.value));
            py.setConfig('ui.qml.playback_speed.stepSize', parseFloat(speed_increment.value));
            py.setConfig('ui.qml.playback_speed.minimumValue', parseFloat(speed_min.text));
            py.setConfig('ui.qml.playback_speed.maximumValue', parseFloat(speed_max.text));
            py.setConfig('fs.downloads', downloads_folder_picker.value);
            youtube_api_key_v3.focus = false;
        }
    }

    SilicaFlickable {
        id: settingsList
        anchors.fill: parent

        contentHeight: column.height + Theme.paddingLarge*2

        VerticalScrollDecorator { flickable: settingsList }

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pgst.loadPage('AboutPage.qml');
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Settings")
            }

            ValueButton {
                id: downloads_folder_picker
                anchors.horizontalCenter: parent.horizontalCenter
                label: qsTr("Downloads directory")
                onClicked: pageStack.push(folderPickerPage)
            }

            TextSwitch {
                id: nomedia_toggle
                text: qsTr("Prevent tracker scanning")
                description: qsTr("Set a .nomedia file in the Downloads folder to prevent gpodder media showing up in the gallery/mediaplayer.")
                onCheckedChanged: py.call('main.toggle_path_nomedia', [downloads_folder_picker.value, nomedia_toggle.checked]);
            }

            Component {
                id: folderPickerPage
                FolderPickerPage {
                    dialogTitle: qsTr("Download to")
                    onSelectedPathChanged: {
                        py.setConfig('fs.downloads', selectedPath);
                    }
                }
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
                text: qsTr("Playback Speed")
                horizontalAlignment: Text.AlignHCenter
            }

            Row {
                width: parent.width

                TextField {
                    id: speed_min
                    label: qsTr("Lower limit")
                    placeholderText: label
                    width: parent.width / 2
                    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhFormattedNumbersOnly
                    EnterKey.iconSource: (text.length > 0) ? "image://theme/icon-m-enter-accept" : "image://theme/icon-m-enter-close"
                    EnterKey.onClicked: focus = false
                    validator: DoubleValidator {
                        bottom: speed_increment.value
                        decimals: 2
                        notation: DoubleValidator.StandardNotation
                        top: parseFloat(speed_max.text) - speed_increment.stepSize
                    }
                }

                TextField {
                    id: speed_max
                    label: qsTr("Upper limit")
                    placeholderText: label
                    width: parent.width / 2
                    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhFormattedNumbersOnly
                    EnterKey.iconSource: (text.length > 0) ? "image://theme/icon-m-enter-accept" : "image://theme/icon-m-enter-close"
                    EnterKey.onClicked: focus = false
                    validator: DoubleValidator {
                        bottom: parseFloat(speed_min.text) + speed_increment.stepSize
                        decimals: 2
                        notation: DoubleValidator.StandardNotation
                        top: 5
                    }
                }
            }

            Slider {
                id: speed_increment
                label: qsTr("Increments")
                valueText: value
                width: parent.width
                minimumValue: speed_increment.stepSize
                maximumValue: 1.00
                stepSize: 0.05
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
        }
    }
}
