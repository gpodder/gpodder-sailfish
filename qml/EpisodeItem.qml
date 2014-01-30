
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

import 'constants.js' as Constants

ListItem {
    id: podcastItem

    Rectangle {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        width: parent.width * progress
        color: Theme.highlightColor
        opacity: .7
    }

    menu: Component {
        ContextMenu {
            MenuItem {
                text: 'Download'
                onClicked: {
                    py.call('main.download_episode', [id]);
                }
            }
            MenuItem {
                text: 'Play'
                onClicked: player.playbackEpisode(id);
            }
            MenuItem {
                text: 'Delete'
                onClicked: {
                    var ctx = { py: py, id: id };
                    podcastItem.remorseAction('Deleting', function () {
                        ctx.py.call('main.delete_episode', [ctx.id]);
                    });
                }
            }
        }
    }

    contentHeight: 80 * pgst.scalef

    anchors {
        left: parent.left
        right: parent.right
    }

    Label {
        id: titleItem

        anchors {
            left: parent.left
            right: downloadStatusIcon.left
            verticalCenter: parent.verticalCenter
            margins: 30 * pgst.scalef
        }

        elide: Text.ElideRight
        text: title

        opacity: {
            switch (downloadState) {
                case Constants.state.normal: return 0.8;
                case Constants.state.downloaded: return 1;
                case Constants.state.deleted: return 0.3;
            }
        }
    }

    Label {
        id: downloadStatusIcon

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 30 * pgst.scalef
        }

        font.pixelSize: parent.contentHeight
        font.bold: true

        opacity: titleItem.opacity

        text: {
            switch (downloadState) {
                case Constants.state.normal: return '';
                case Constants.state.downloaded: return '♫';
                case Constants.state.deleted: return '';
            }
        }
    }
}

