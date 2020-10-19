
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
    property bool isPlaying: ((player.episode === id) && player.isPlaying)
    property variant mime: mime_type.split('/')
    property var downloaded: downloadState === 1

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

        height: parent.height * 0.1
        width: parent.width * progress

        color: Theme.highlightColor
        opacity: .5
    }

    Rectangle {
        anchors {
            bottom: parent.bottom
            left: parent.left
        }

        height: parent.height * 0.1
        width: parent.width * playbackProgress

        color: isPlaying ? Theme.highlightColor : Theme.secondaryHighlightColor
        opacity: .5
    }

    onClicked: openMenu()

    menu: Component {
        IconContextMenu {
            IconMenuItem {
                text: episodeItem.isPlaying ? qsTr("Pause") : qsTr("Play")
                icon.source: 'image://theme/icon-m-' + (episodeItem.isPlaying ? 'pause' : 'play')
                onClicked: {
                    if (episodeItem.isPlaying) {
                        player.pause();
                    } else {
                        if(downloaded === false){
                            connectionUtil.executeIfConnectionAllowed(doPlayback)
                        }else {
                            doPlayback();
                        }
                    }
                }

                function doPlayback(){
                    player.playbackEpisode(id);
                }
            }

            IconMenuItem {
                text: qsTr("Download")
                icon.source: 'image://theme/icon-m-download'
                visible: downloadState !== Constants.state.downloaded
                onClicked: {
                    episodeItem.closeMenu();
                    py.call('main.download_episode', [id]);
                }
            }
            
            IconMenuItem {
				text: qsTr("Enqueue")
                icon.source: 'image://theme/icon-m-add'
				onClicked: {
                    player.enqueueEpisode(id, function () {
                        if (player.episode === 0) {
								player.jumpToQueueIndex(0);
						}
					});
                    episodeItem.closeMenu();
                }
			}

            IconMenuItem {
                text: qsTr("Delete")
                icon.source: 'image://theme/icon-m-delete'
                visible: downloadState !== Constants.state.deleted
                onClicked: {
                    episodeItem.closeMenu();
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
                    episodeItem.closeMenu();
                    pgst.loadPage('EpisodeDetail.qml',
                                  {episode_id: id,
                                   title: title,
                                   cover_art: cover_art,
                                   episode_art: episode_art,
                                   podcast_title: podcast_title});
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
            left: artArea.right
            right: downloadStatusIndicator.left
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
            id: subtitleItem
            text: (mime[0] === 'video' ? '🎬' : '') + published + ' | ' + (total_time > 0 ?  Util.formatDuration(total_time) + (subtitle != '' ? ' | ' + subtitle :'') : subtitle)
            anchors {
                left: titleItem.left
                right: titleItem.right
            }
            truncationMode: TruncationMode.Fade
            opacity: titleItem.opacity
            visible: this.text !== ''
            font.pixelSize: Theme.fontSizeExtraSmall
        }
    }

    ArtArea {
        id: artArea
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        height: parent.height * 0.8
        width: parent.height * 0.8
        property string episode_art: ''
        property string title_char: podcast_title[0]
    }

    Rectangle {
        id: downloadStatusIndicator
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        height: parent.height * 0.8
        width: parent.height * 0.1

        visible: {
            switch (downloadState) {
                case Constants.state.normal: return false;
                case Constants.state.downloaded: return true;
                case Constants.state.deleted: return false;
            }
        }
        color: Theme.highlightColor
        opacity: .8
    }
}
