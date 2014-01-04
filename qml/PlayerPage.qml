
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

import 'constants.js' as Constants

SlidePage {
    id: playerPage

    property string episodeTitle

    Component.onCompleted: {
        py.call('main.show_episode', [player.episode], function (episode) {
            playerPage.episodeTitle = episode.title;
        });
    }

    Flickable {
        id: flickable
        anchors.fill: parent

        contentWidth: column.width
        contentHeight: column.height + column.spacing

        Column {
            id: column

            width: playerPage.width
            spacing: 10 * pgst.scalef

            SlidePageHeader {
                title: 'Now playing'
            }

            ButtonRow {
                width: playerPage.width
                model: [
                    { label: 'Play', clicked: function() {
                        player.play();
                    }},
                    { label: 'Pause', clicked: function() {
                        player.pause();
                    }},
                    { label: 'Details', clicked: function() {
                        pgst.loadPage('EpisodeDetail.qml', {
                            episode_id: player.episode,
                            title: playerPage.episodeTitle
                        });
                    }}
                ]
            }

            PSlider {
                width: playerPage.width
                value: player.playbackRate
                min: 0.5
                max: 3.0
                onValueChangeRequested: {
                    player.playbackRate = newValue
                    value = player.playbackRate
                }
            }
        }
    }
}
