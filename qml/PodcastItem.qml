
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
        IconContextMenu {
            IconMenuItem {
                text: 'Unsubscribe'
                icon.source: 'image://theme/icon-m-delete'
                onClicked: {
                    podcastItem.hideMenu();
                    var ctx = { py: py, id: id };
                    podcastItem.remorseAction('Unsubscribing', function () {
                        ctx.py.call('main.unsubscribe', [ctx.id]);
                    });
                }
            }

            IconMenuItem {
                text: 'Rename'
                icon.source: 'image://theme/icon-m-edit'
                onClicked: {
                    podcastItem.hideMenu();
                    var ctx = { py: py, id: id };
                    pageStack.push('RenameDialog.qml', {
                        activityName: 'Rename podcast',
                        affirmativeAction: 'Rename',
                        inputLabel: 'Podcast name',
                        initialValue: title,
                        callback: function (new_title) {
                            ctx.py.call('main.rename_podcast', [ctx.id, new_title]);
                        }
                    });
                }
            }

            IconMenuItem {
                text: 'Change section'
                icon.source: 'image://theme/icon-m-shuffle'
                onClicked: {
                    podcastItem.hideMenu();
                    var ctx = { py: py, id: id };
                    pageStack.push('RenameDialog.qml', {
                        activityName: 'Change section',
                        affirmativeAction: 'Move',
                        inputLabel: 'Section',
                        initialValue: section,
                        callback: function (new_section) {
                            ctx.py.call('main.change_section', [ctx.id, new_section]);
                        }
                    });
                }
            }

            IconMenuItem {
                text: 'Podcast details'
                icon.source: 'image://theme/icon-m-message'
                onClicked: {
                    podcastItem.hideMenu();
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

