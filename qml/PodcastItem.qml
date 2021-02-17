
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2013, Thomas Perl <m@thp.io>
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

ListItem {
    id: podcastItem

    menu: Component {
        GpodderIconContextMenu {
            GpodderIconMenuItem {
                text: qsTr("Refresh")
                icon.source: 'image://theme/icon-m-sync'
                onClicked: {
                    podcastItem.closeMenu();
                    py.call('main.check_for_episodes', [url]);
                }
            }

            GpodderIconMenuItem {
                text: qsTr("Unsubscribe")
                icon.source: 'image://theme/icon-m-delete'
                onClicked: {
                    podcastItem.closeMenu();
                    var ctx = { py: py, id: id };
                    podcastItem.remorseAction(qsTr("Unsubscribing"), function () {
                        ctx.py.call('main.unsubscribe', [ctx.id]);
                    });
                }
            }

            GpodderIconMenuItem {
                text: qsTr("Rename")
                icon.source: 'image://theme/icon-m-edit'
                onClicked: {
                    podcastItem.closeMenu();
                    var ctx = { py: py, id: id };
                    pageStack.push('RenameDialog.qml', {
                        activityName: qsTr("Rename podcast"),
                        affirmativeAction: qsTr("Rename"),
                        inputLabel: qsTr("Podcast name"),
                        initialValue: title,
                        callback: function (new_title) {
                            ctx.py.call('main.rename_podcast', [ctx.id, new_title]);
                        }
                    });
                }
            }

            GpodderIconMenuItem {
                text: qsTr("Change section")
                icon.source: 'image://theme/icon-m-shuffle'
                onClicked: {
                    podcastItem.closeMenu();
                    var ctx = { py: py, id: id };
                    pageStack.push('RenameDialog.qml', {
                        activityName: qsTr("Change section"),
                        affirmativeAction: qsTr("Move"),
                        inputLabel: qsTr("Section"),
                        initialValue: section,
                        callback: function (new_section) {
                            ctx.py.call('main.change_section', [ctx.id, new_section]);
                        }
                    });
                }
            }

            GpodderIconMenuItem {
                text: qsTr("Podcast detail")
                icon.source: 'image://theme/icon-m-about'
                onClicked: {
                    podcastItem.closeMenu();
                    pgst.loadPage('PodcastDetail.qml', {podcast_id: id, title: title});
                }
            }
        }
    }

    contentHeight: Theme.itemSizeMedium

    anchors {
        left: parent.left
        right: parent.right
    }

    Image {
        id: cover
        visible: !updating && coverart
        asynchronous: true

        anchors {
            left: parent.left
            leftMargin: Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }

        sourceSize.width: width
        sourceSize.height: height

        width: Theme.iconSizeMedium
        height: Theme.iconSizeMedium

        source: coverart
    }

    Rectangle {
        anchors.fill: cover
        visible: !updating && !coverart
        color: Theme.rgba(Theme.highlightColor, 0.5)

        clip: true

        Label {
            anchors.centerIn: parent

            font.pixelSize: parent.height * 0.8
            text: title[0]
            color: Theme.highlightColor
        }
    }

    BusyIndicator {
        anchors.centerIn: cover
        visible: updating
        running: visible
    }

    Label {
        id: titleLabel
        anchors {
            left: cover.right
            leftMargin: Theme.paddingMedium
            rightMargin: Theme.paddingMedium
            right: downloadsLabel.left
            verticalCenter: parent.verticalCenter
        }

        truncationMode: TruncationMode.Fade
        text: title
        color: (newEpisodes || podcastItem.highlighted) ? Theme.highlightColor : Theme.primaryColor
    }

    Label {
        id: downloadsLabel
        anchors {
            right: parent.right
            rightMargin: Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }

        color: titleLabel.color
        text: downloaded ? downloaded : ''
    }
}

