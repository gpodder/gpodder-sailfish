
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2013, 2014, Thomas Perl <m@thp.io>
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
import QtMultimedia 5.0

import 'common/util.js' as Util

CoverBackground {
    property bool cover_stat:true;
    property bool cover_player:true;
    Image {
        source: 'cover.png'
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: sourceSize.height * width / sourceSize.width
    }

    PodcastsCover {
        id: podcastsCover
        visible: !playerCover.visible || (cover_stat && !cover_player)
    }

    PlayerCover {
        id: playerCover
        width: parent.width
        height: width
        property string cover_art: player.cover_art
        property string episode_art: player.episode_art
        property string title_char: player.podcast_title[0]
        visible: cover_player && player.episode != 0 && (player.playbackState == MediaPlayer.PlayingState || player.playbackState == MediaPlayer.PausedState)
    }

    CoverActionList {
        enabled: cover_player && player.episode != 0 && player.playbackState == MediaPlayer.PlayingState

        CoverAction {
            iconSource: 'image://theme/icon-cover-pause'
            onTriggered: player.pause();
        }
        CoverAction {
            iconSource: 'icon-cover-forward.png'
            onTriggered: player.seekAndSync(player.position + 1000 * 30);
        }
    }

    CoverActionList {
        enabled: cover_player && player.episode != 0 && player.playbackState == MediaPlayer.PausedState

        CoverAction {
            iconSource: 'image://theme/icon-cover-play'
            onTriggered: player.play();

        }

        CoverAction {
            iconSource: 'image://theme/icon-cover-next'
            onTriggered: {
                cover_player=false;
                cover_stat=true;
            }
        }
    }

    CoverActionList {
        enabled: player.episode == 0 || (player.episode != 0 && player.playbackState == MediaPlayer.StoppedState)

        CoverAction {
            iconSource: 'image://theme/icon-cover-sync'
            onTriggered: {
                if (!py.refreshing) {
                    py.call('main.check_for_episodes');
                }
            }
        }
    }

    CoverActionList {
        enabled: cover_stat && !cover_player

        CoverAction {
            iconSource: 'image://theme/icon-cover-previous'
            onTriggered: {
                cover_stat=false;
                cover_player=true;
            }
        }

        CoverAction {
            iconSource: 'image://theme/icon-cover-sync'
            onTriggered: {
                if (!py.refreshing) {
                    py.call('main.check_for_episodes');
                }
            }
        }
    }
}
