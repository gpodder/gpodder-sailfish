
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

import 'common/constants.js' as Constants
import 'common/util.js' as Util

ListItem {
    id: episodeItem
    property bool isPlaying: ((player.episode == id) && player.isPlaying)
    property variant mime: mime_type.split('/')

    Rectangle {
        anchors.fill: parent
        color: Theme.highlightColor
        visible: (progress > 0) || isPlaying
        opacity: 0.1
    }

    Rectangle {
        anchors {
            top: parent.top
            left: parent.left
        }

        height: parent.height * 0.2
        width: parent.width * progress

        color: Theme.highlightColor
        opacity: .5
    }

    Rectangle {
        anchors {
            bottom: parent.bottom
            left: parent.left
        }

        height: parent.height * 0.2
        width: parent.width * playbackProgress

        color: isPlaying ? Theme.highlightColor : Theme.secondaryHighlightColor
        opacity: .5
    }

    onClicked: showMenu()

    menu: Component {
        IconContextMenu {
            IconMenuItem {
                text: episodeItem.isPlaying ? qsTr("Pause") : qsTr("Play")
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
                text: qsTr("Download")
                icon.source: 'image://theme/icon-m-download'
                visible: downloadState != Constants.state.downloaded
                onClicked: {
                    episodeItem.hideMenu();
                    py.call('main.download_episode', [id]);
                }
            }
            
            IconMenuItem {
				text: qsTr("Enqueue")
                icon.source: 'image://theme/icon-m-add'
				onClicked: {
                    player.enqueueEpisode(id, function () {
						if (player.episode==0) {
								player.jumpToQueueIndex(0);
						}
					});
					episodeItem.hideMenu();
                }
			}

            IconMenuItem {
                text: qsTr("Delete")
                icon.source: 'image://theme/icon-m-delete'
                visible: downloadState != Constants.state.deleted
                onClicked: {
                    episodeItem.hideMenu();
                    var ctx = { py: py, id: id };
                    episodeItem.remorseAction(qsTr("Deleting"), function () {
                        ctx.py.call('main.delete_episode', [ctx.id]);
                    });
                }
            }

            IconMenuItem {
                id: toggleNew
                text: qsTr("Toggle New")
                icon.source: 'image://theme/icon-m-favorite' + (isNew ? '-selected' : '')
                onClicked: Util.disableUntilReturn(toggleNew, py, 'main.toggle_new', [id]);
            }

            IconMenuItem {
                text: qsTr("Shownotes")
                icon.source: 'image://theme/icon-m-about'
                onClicked: {
                    episodeItem.hideMenu();
                    pgst.loadPage('EpisodeDetail.qml', {episode_id: id, title: title});
                }
            }
        }
    }

    contentHeight: Theme.itemSizeSmall

    anchors {
        left: parent.left
        right: parent.right
    }

    Column {
        anchors {
            left: parent.left
            right: downloadStatusIcon.left
            verticalCenter: parent.verticalCenter
            margins: Theme.paddingMedium
        }

        Label {
            id: titleItem

            anchors {
                left: parent.left
                right: parent.right
            }

            truncationMode: TruncationMode.Fade
            text: title

            // need to set opacity via color, as truncationMode overrides opacity
            color: {
                if (episodeItem.highlighted) {
                    return Theme.highlightColor
                } else {
                    Theme.rgba(isNew ? Theme.highlightColor : Theme.primaryColor, opacity)
                }
            }

            opacity: {
                switch (downloadState) {
                    case Constants.state.normal: return 0.8;
                    case Constants.state.downloaded: return 1;
                    case Constants.state.deleted: return 0.3;
                }
            }
        }

        Label {
            text: subtitle
            anchors {
                left: titleItem.left
                right: titleItem.right
            }
            truncationMode: TruncationMode.Fade
            opacity: titleItem.opacity
            visible: subtitle !== ''
            font.pixelSize: Theme.fontSizeExtraSmall
        }
    }

    Label {
        id: videoIcon

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: text ? Theme.paddingMedium : 0
        }

        font.pixelSize: Theme.fontSizeLarge
        font.bold: true

        opacity: titleItem.opacity

        color: titleItem.color

        text: mime[0] == 'video' ? '🎬' : '';
    }

    Label {
        id: downloadStatusIcon

        anchors {
            right: mime[0] == 'video' ? videoIcon.left : parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: text ? Theme.paddingMedium : 0
        }

        font.pixelSize: Theme.fontSizeLarge
        font.bold: true

        opacity: titleItem.opacity

        color: titleItem.color

        text: {
            switch (downloadState) {
                case Constants.state.normal: return '';
                case Constants.state.downloaded: return '♫';
                case Constants.state.deleted: return '';
            }
        }
    }
}

