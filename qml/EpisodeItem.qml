
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
    id: episodeItem
    property bool isPlaying: ((player.episode == id) && player.isPlaying)

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

    onClicked: showMenu()

    menu: Component {
        IconContextMenu {
            IconMenuItem {
                text: episodeItem.isPlaying ? 'Pause' : 'Play'
                icon.source: 'image://theme/icon-m-' + (episodeItem.isPlaying ? 'pause' : 'play')
                onClicked: {
                    if (episodeItem.isPlaying) {
                        player.pause();
                    } else {
                        player.playbackEpisode(id);
                    }
                }
            }

            IconMenuItem {
                text: 'Download'
                icon.source: 'image://theme/icon-m-download'
                visible: downloadState != Constants.state.downloaded
                onClicked: {
                    episodeItem.hideMenu();
                    py.call('main.download_episode', [id]);
                }
            }

            IconMenuItem {
                text: 'Delete'
                icon.source: 'image://theme/icon-m-delete'
                visible: downloadState != Constants.state.deleted
                onClicked: {
                    episodeItem.hideMenu();
                    var ctx = { py: py, id: id };
                    episodeItem.remorseAction('Deleting', function () {
                        ctx.py.call('main.delete_episode', [ctx.id]);
                    });
                }
            }

            IconMenuItem {
                text: 'Toggle New'
                icon.source: 'image://theme/icon-m-favorite' + (isNew ? '-selected' : '')
                onClicked: py.call('main.toggle_new', [id]);
            }

            IconMenuItem {
                text: 'Shownotes'
                icon.source: 'image://theme/icon-m-message'
                onClicked: {
                    episodeItem.hideMenu();
                    pgst.loadPage('EpisodeDetail.qml', {episode_id: id, title: title});
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

        truncationMode: TruncationMode.Fade
        text: title

        // need to set opacity via color, as truncationMode overrides opacity
        color: Theme.rgba(isNew ? Theme.highlightColor : Theme.primaryColor, opacity)

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
            rightMargin: (20 * pgst.scalef) * (text != '')
        }

        font.pixelSize: episodeItem.contentHeight * 0.4
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

